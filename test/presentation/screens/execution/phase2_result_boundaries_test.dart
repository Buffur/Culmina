import 'dart:async';

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/execution.dart';
import 'package:astroplan/domain/models/session.dart';
import 'package:astroplan/domain/services/astrobin_acquisitions.dart';
import 'package:astroplan/presentation/screens/execution/results_screen.dart';
import 'package:astroplan/presentation/screens/logbook/astrobin_export.dart';
import 'package:astroplan/presentation/screens/logbook/session_detail_screen.dart';
import 'package:astroplan/presentation/viewmodels/library_viewmodels.dart';
import 'package:astroplan/presentation/shared/action_row.dart';
import 'package:astroplan/presentation/viewmodels/astrobin_export_viewmodel.dart';
import 'package:astroplan/presentation/viewmodels/results_viewmodel.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../../support/hybrid_transfer_fixture.dart';
import '../../../support/hybrid_transfer_shots.dart' show hybridSettle;
import '../../../support/phase2_state_capture.dart';
import '../../../support/wave1_capture.dart' show loadWave1Font;
import '../../../support/legacy_run.dart';

class _Csv implements AstroBinExportViewModel {
  final preparations = <Completer<AstroBinExport>>[];
  final shares = <Completer<void>>[];
  @override
  Future<AstroBinExport> prepare({int? id}) {
    final read = Completer<AstroBinExport>();
    preparations.add(read);
    return read.future;
  }

  @override
  Future<void> share(AstroBinExport value) {
    final read = Completer<void>();
    shares.add(read);
    return read.future;
  }
}

void main() {
  setUpAll(loadWave1Font);
  for (final theme in ['light', 'dark', 'field']) {
    Future<void> capture(WidgetTester t, String state) =>
        capturePhase2State(t, package: 'package2', state: state, theme: theme);
    Widget host(Widget screen) => MaterialApp(
      theme: phase2Theme(theme),
      builder: (_, child) => phase2Frame(theme: theme, child: child!),
      home: screen,
    );
    void phone(WidgetTester t) {
      t.view.physicalSize = const Size(375, 812);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
    }

    testWidgets(
      '$theme rejected frames and calibration retain distinct recorded meaning',
      (t) async {
        t.view.physicalSize = const Size(375, 812);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.reset);
        late HybridTransferFixture fixture;
        late Session session;
        await t.runAsync(() async {
          fixture = await HybridTransferFixture.create(
            AppDatabase(NativeDatabase.memory()),
          );
          await fixture.vm.plan.addCaptureBlock(
            CaptureBlock(
              frameType: FrameType.dark,
              exposureTimeSeconds: 120,
              frameCount: 2,
            ),
          );
          await fixture.vm.plan.idle;
          final saved = await fixture.vm.analysis.saveSession();
          session = await startLegacyRun(fixture.sessions, saved);
          final light = session.blocks.firstWhere(
            (b) => b.frameType == FrameType.light,
          );
          await fixture.sessions.record(
            session.id,
            ExecutionEventKind.framesConfirmed,
            blockId: light.id,
            delta: 10,
          );
          await fixture.sessions.record(
            session.id,
            ExecutionEventKind.framesRejected,
            blockId: light.id,
            delta: 2,
          );
          await fixture.sessions.complete(session.id);
        });
        final vm = ResultsViewModel(
          fixture.sessions,
          FixedClock(DateTime.utc(2026, 10, 20, 18)),
        );
        final sessions = SessionsViewModel(fixture.sessions);
        addTearDown(vm.dispose);
        addTearDown(sessions.dispose);
        addTearDown(
          () => t.runAsync(() async {
            fixture.vm.dispose();
            await fixture.db.close();
          }),
        );
        await t.pumpWidget(
          ChangeNotifierProvider.value(
            value: vm,
            child: host(ResultsScreen(sessionId: session.id)),
          ),
        );
        await hybridSettle(t);
        expect(find.byKey(const Key('results.rejected')), findsOneWidget);
        expect(find.text('2 light frames rejected earlier'), findsOneWidget);
        await capture(t, 'results-existing-rejected-frames');
        await t.pumpWidget(
          MultiProvider(
            providers: [
              ...fixture.vm.providers,
              ChangeNotifierProvider<SessionsViewModel>.value(value: sessions),
            ],
            child: host(SessionDetailScreen(sessionId: session.id)),
          ),
        );
        await hybridSettle(t);
        await t.scrollUntilVisible(
          find.text('Not counted: the result form records light frames only'),
          250,
        );
        expect(
          find.text('Not counted: the result form records light frames only'),
          findsOneWidget,
        );
        await capture(t, 'detail-calibration-not-counted');
        expect(t.takeException(), isNull);
      },
    );
    testWidgets('$theme result unreadable snapshot and no light blocks', (
      t,
    ) async {
      phone(t);
      final db = AppDatabase(NativeDatabase.memory());
      final repo = DriftSessionRepository(db);
      late Session session;
      await t.runAsync(() async {
        session = await repo.create(
          SessionPlan(
            eveningDate: CalendarDate(2026, 11, 5),
            timeZoneId: 'Europe/Kyiv',
            siteId: null,
            targetId: null,
            rigId: null,
            blocks: [],
            targetLabel: 'Synthetic unavailable context',
            rigLabel: 'Unknown rig',
          ),
        );
      });
      final vm = ResultsViewModel(
        repo,
        FixedClock(DateTime.utc(2026, 11, 6, 18)),
      );
      addTearDown(vm.dispose);
      addTearDown(() => t.runAsync(db.close));
      await t.pumpWidget(
        ChangeNotifierProvider.value(
          value: vm,
          child: host(ResultsScreen(sessionId: session.id)),
        ),
      );
      await hybridSettle(t);
      await t.tap(find.byKey(const Key('results.review')));
      await t.pumpAndSettle();
      expect(
        find.byKey(const Key('results.reviewUnavailable')),
        findsOneWidget,
      );
      expect(find.text('This plan has no light blocks.'), findsOneWidget);
      expect(find.textContaining('Site unknown'), findsOneWidget);
      await capture(t, 'results-unreadable-no-light-review');
      await t.runAsync(() async {
        await db.customStatement(
          'UPDATE session_logs SET planned_at_utc_ms = 1 WHERE id = ?',
          [session.id],
        );
        await vm.load(session.id);
      });
      await t.pumpAndSettle();
      expect(vm.onlyNotDone, isTrue);
      for (final outcome in ['asPlanned', 'partly']) {
        final row = t.widget<ActionRow>(
          find.descendant(
            of: find.byKey(Key('results.outcome.$outcome')),
            matching: find.byType(ActionRow),
          ),
        );
        expect(row.onTap, isNull);
      }
      await t.ensureVisible(find.byKey(const Key('results.outcome.notDone')));
      await t.tap(find.byKey(const Key('results.outcome.notDone')));
      await t.pumpAndSettle();
      expect(find.byKey(const Key('results.reasonGroup')), findsOneWidget);
      await capture(t, 'results-unreadable-only-not-done');
      expect(t.takeException(), isNull);
    });

    testWidgets('$theme another changed saved plan cannot save from results', (
      t,
    ) async {
      phone(t);
      late HybridTransferFixture fixture;
      late int id;
      await t.runAsync(() async {
        fixture = await HybridTransferFixture.create(
          AppDatabase(NativeDatabase.memory()),
        );
        id = fixture.vm.plan.activeSessionId!;
        await fixture.db.customStatement(
          "UPDATE session_logs SET status = 'draft' WHERE id = ?",
          [id],
        );
      });
      final vm = ResultsViewModel(
        fixture.sessions,
        FixedClock(DateTime.utc(2026, 10, 19, 18)),
      );
      addTearDown(vm.dispose);
      addTearDown(
        () => t.runAsync(() async {
          fixture.vm.dispose();
          await fixture.db.close();
        }),
      );
      await t.pumpWidget(
        ChangeNotifierProvider.value(
          value: vm,
          child: host(ResultsScreen(sessionId: id)),
        ),
      );
      await hybridSettle(t);
      expect(vm.pendingChanges, isTrue);
      expect(vm.canSaveChanges, isFalse);
      expect(find.byKey(const Key('results.pending.save')), findsNothing);
      expect(find.byKey(const Key('results.pending.discard')), findsOneWidget);
      expect(
        find.textContaining('To keep them, open the plan and save it.'),
        findsOneWidget,
      );
      await capture(t, 'results-changed-cannot-save-here');
      expect(t.takeException(), isNull);
    });

    testWidgets(
      '$theme AstroBin prepare and share failures preserve action recovery',
      (t) async {
        phone(t);
        final vm = _Csv();
        await t.pumpWidget(
          Provider<AstroBinExportViewModel>.value(
            value: vm,
            child: host(
              Scaffold(
                body: Builder(
                  builder: (context) => TextButton(
                    onPressed: () => exportForAstroBinFlow(context),
                    child: const Text('Export'),
                  ),
                ),
              ),
            ),
          ),
        );
        await t.tap(find.text('Export'));
        await t.pump();
        expect(vm.preparations, hasLength(1));
        vm.preparations.single.completeError(StateError('private marker'));
        await t.pumpAndSettle();
        expect(
          find.textContaining("Couldn't prepare the AstroBin CSV"),
          findsOneWidget,
        );
        expect(find.textContaining('private marker'), findsNothing);
        expect(find.byKey(const Key('astrobin.preview')), findsNothing);
        await capture(t, 'astrobin-prepare-error');
        await t.pump(const Duration(seconds: 5));
        await t.pumpAndSettle();
        await t.tap(find.text('Export'));
        await t.pump();
        vm.preparations.last.complete(
          const AstroBinExport([
            AstroBinRow(
              date: '2026-11-05',
              filterName: 'Ha',
              number: 2,
              durationS: 300,
            ),
          ], []),
        );
        await t.pumpAndSettle();
        expect(find.byKey(const Key('astrobin.preview')), findsOneWidget);
        await capture(t, 'astrobin-preview-after-prepare-error');
        await t.tap(find.byKey(const Key('astrobin.share')));
        await t.pumpAndSettle();
        expect(vm.shares, hasLength(1));
        vm.shares.single.completeError(StateError('private share marker'));
        await t.pumpAndSettle();
        expect(
          find.textContaining("Couldn't share the AstroBin CSV"),
          findsOneWidget,
        );
        expect(find.text('AstroBin CSV created'), findsNothing);
        expect(find.textContaining('private share marker'), findsNothing);
        await capture(t, 'astrobin-share-error');
        expect(t.takeException(), isNull);
      },
    );
  }
}
