import 'dart:async';

import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/execution.dart';
import 'package:astroplan/domain/models/session.dart';
import 'package:astroplan/domain/repositories/storage_failure.dart';
import 'package:astroplan/domain/services/candidate_evaluator.dart';
import 'package:astroplan/presentation/screens/library/library_screen.dart';
import 'package:astroplan/presentation/screens/logbook/session_detail_screen.dart';
import 'package:astroplan/presentation/screens/tonight/tonight_candidates_screen.dart';
import 'package:astroplan/presentation/viewmodels/candidates_viewmodel.dart';
import 'package:astroplan/presentation/viewmodels/library_viewmodels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../support/hybrid_transfer_shots.dart';
import '../../support/wave1_capture.dart';
import '../../support/wave2_fixture.dart';

class _Candidates implements CandidatesViewModel {
  final reads = <Completer<List<TonightCandidate>?>>[];
  @override
  Future<List<TonightCandidate>?> tonightCandidates() {
    final gate = Completer<List<TonightCandidate>?>();
    reads.add(gate);
    return gate.future;
  }
}

class _Targets extends DriftTargetRepository {
  _Targets(super.db);
  final reads = <Completer<StorageFailure?>>[];
  @override
  Future<List<AstroTarget>> searchTargets(String query) async {
    final gate = Completer<StorageFailure?>();
    reads.add(gate);
    final failure = await gate.future;
    if (failure != null) throw failure;
    return super.searchTargets(query);
  }
}

class _Detail extends DriftSessionRepository {
  _Detail(this.store) : super(store);
  final AppDatabase store;
  final reads = <({int id, Completer<void> gate})>[];
  @override
  Future<Session?> get(int id) async {
    final gate = Completer<void>();
    reads.add((id: id, gate: gate));
    await gate.future;
    return super.get(id);
  }

  @override
  Future<ExecutionState> execution(int id) =>
      DriftSessionRepository(store).execution(id);
}

void main() {
  setUpAll(loadWave1Font);
  for (final theme in ['light', 'dark', 'field']) {
    testWidgets(
      'UIA-0006 $theme: held refresh preserves labelled results, then failure/recovery',
      (t) async {
        final source = _Candidates();
        final f = await mountWave2(
          t,
          theme,
          screen: (_) => const TonightCandidatesScreen(),
          overrides: (_) => [
            Provider<CandidatesViewModel>.value(value: source),
          ],
        );
        final row = CandidateEvaluator.candidateOf(
          f.vm.selectedTarget!,
          f.vm.imagingOpportunity!,
        );
        expect(row.hasWindow, isTrue);
        source.reads.single.complete([row]);
        await hybridSettle(t);
        expect(find.textContaining('1 of 1 targets'), findsOneWidget);
        final sort = find.byType(DropdownButtonFormField<CandidateSort>);
        await revealWave2(t, sort);
        await t.tap(sort);
        await t.pumpAndSettle();
        await t.tap(find.text('Name').last);
        await t.pumpAndSettle();
        await t.tap(find.byTooltip('Refresh candidates'));
        await t.pump();
        expect(source.reads, hasLength(2));
        expect(find.byKey(const Key('candidates.refreshing')), findsOneWidget);
        expect(find.textContaining('1 of 1 targets'), findsOneWidget);
        expect(
          t.state<FormFieldState<CandidateSort>>(sort).value,
          CandidateSort.name,
        );
        await captureWave1(t, 'wave2-candidates-$theme-refresh-pending');
        source.reads.last.completeError(
          const StorageFailure('private-candidate-marker'),
        );
        await hybridSettle(t);
        expect(find.textContaining("Couldn't evaluate"), findsOneWidget);
        expect(find.textContaining('private-candidate-marker'), findsNothing);
        await t.tap(find.byTooltip('Refresh candidates'));
        await t.pump();
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.textContaining("Couldn't evaluate"), findsNothing);
        source.reads.last.complete([row]);
        await hybridSettle(t);
        expect(find.byKey(const Key('candidates.refreshing')), findsNothing);
        expect(find.textContaining('1 of 1 targets'), findsOneWidget);
        expect(
          t.state<FormFieldState<CandidateSort>>(sort).value,
          CandidateSort.name,
        );
        await t.runAsync(
          () => f.vm.plan.setEveningDate(CalendarDate(2026, 10, 20)),
        );
        await t.pump();
        expect(source.reads, hasLength(4));
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(
          find.textContaining('1 of 1 targets'),
          findsNothing,
          reason: 'a new night cannot retain the previous night results',
        );
        source.reads.last.complete([]);
        await hybridSettle(t);
      },
    );

    testWidgets(
      'UIA-0007 $theme: own/type/window filters never invent the empty cause',
      (t) async {
        final source = _Candidates();
        final f = await mountWave2(
          t,
          theme,
          screen: (_) => const TonightCandidatesScreen(),
          overrides: (_) => [
            Provider<CandidatesViewModel>.value(value: source),
          ],
        );
        final row = CandidateEvaluator.candidateOf(
          f.vm.selectedTarget!,
          f.vm.imagingOpportunity!,
        );
        expect(row.hasWindow, isTrue);
        source.reads.single.complete([row]);
        await hybridSettle(t);
        for (final windowless in [false, true]) {
          if (windowless) {
            await revealWave2(t, find.byKey(const Key('tonight.all')));
            await t.tap(find.byKey(const Key('tonight.all')));
            await hybridSettle(t);
          } else {
            await revealWave2(t, find.byKey(const Key('tonight.own')));
            await t.tap(find.byKey(const Key('tonight.own')));
            await hybridSettle(t);
          }
          final empty = find.byKey(const Key('tonight.empty'));
          await revealWave2(t, empty);
          expect(
            t.widget<Text>(empty).data,
            'No targets match these filters. Try changing the filters.',
          );
          await captureWave1(
            t,
            'wave2-candidates-$theme-own-empty-$windowless',
          );
        }
        expect(
          source.reads,
          hasLength(1),
          reason: 'filters do not rerun or alter the evaluator',
        );
      },
    );

    testWidgets(
      'UIA-0014 $theme: count failure, held Retry, failure again, actual counts',
      (t) async {
        late _Targets repo;
        late TargetsViewModel targets;
        final f = await mountWave2(
          t,
          theme,
          screen: (_) => const LibraryScreen(),
          overrides: (f) {
            repo = _Targets(f.db);
            targets = TargetsViewModel(repo);
            return [
              ChangeNotifierProvider<TargetsViewModel>.value(value: targets),
            ];
          },
        );
        addTearDown(targets.dispose);
        repo.reads.single.complete(
          const StorageFailure('private-count-marker'),
        );
        await hybridSettle(t);
        for (var i = 0; i < 2; i++) {
          await t.tap(find.byKey(const Key('library.retryCounts')));
          await t.pump();
          expect(repo.reads, hasLength(i + 2));
          expect(
            find.byKey(const Key('library.countsPending')),
            findsOneWidget,
          );
          expect(find.byKey(const Key('library.retryCounts')), findsNothing);
          expect(
            find.textContaining("Couldn't load library counts"),
            findsNothing,
          );
          expect(find.textContaining('private-count-marker'), findsNothing);
          await captureWave1(t, 'wave2-library-$theme-retry-$i');
          if (i == 0) {
            repo.reads.last.complete(
              const StorageFailure('private-count-marker'),
            );
          } else {
            repo.reads.last.complete();
          }
          await hybridSettle(t);
        }
        await t.runAsync(() async {
          final count = (await DriftTargetRepository(f.db).searchTargets(''))
              .length;
          expect(
            find.text(
              '$count targets · the catalogue and the targets you added',
            ),
            findsOneWidget,
          );
        });
        expect(find.byKey(const Key('library.countsPending')), findsNothing);
        await captureWave1(t, 'wave2-library-$theme-recovered');
      },
    );

    testWidgets(
      'UIA-0008 $theme: detail failure, held Retry, exact entry recovery',
      (t) async {
        late _Detail repo;
        late SessionsViewModel sessions;
        final f = await mountWave2(
          t,
          theme,
          screen: (f) =>
              SessionDetailScreen(sessionId: f.vm.plan.activeSessionId!),
          overrides: (f) {
            repo = _Detail(f.db);
            sessions = SessionsViewModel(repo);
            return [
              ChangeNotifierProvider<SessionsViewModel>.value(value: sessions),
            ];
          },
        );
        addTearDown(sessions.dispose);
        final before = f.vm.plan.activeSession!;
        repo.reads.single.gate.completeError(
          const StorageFailure('private-entry-marker'),
        );
        await hybridSettle(t);
        await t.tap(find.text('Retry'));
        await t.pump();
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Retry'), findsNothing);
        expect(find.textContaining("Couldn't load the entry"), findsNothing);
        await captureWave1(t, 'wave2-entry-$theme-retry-pending');
        repo.reads.last.gate.complete();
        await hybridSettle(t);
        expect(find.byKey(const Key('detail.scroll')), findsOneWidget);
        expect(repo.reads.every((r) => r.id == before.id), isTrue);
        await t.runAsync(() async {
          final stored = (await f.seed.sessions.get(before.id))!;
          expect(stored.planSnapshot!.json, before.planSnapshot!.json);
          expect(stored.updatedAtUtc, before.updatedAtUtc);
        });
        await captureWave1(t, 'wave2-entry-$theme-recovered');
      },
    );
  }

  testWidgets('UIA-0008: held Retry resolves a deleted entry as missing', (
    t,
  ) async {
    late _Detail repo;
    late SessionsViewModel sessions;
    final f = await mountWave2(
      t,
      'light',
      screen: (f) => SessionDetailScreen(sessionId: f.vm.plan.activeSessionId!),
      overrides: (f) {
        repo = _Detail(f.db);
        sessions = SessionsViewModel(repo);
        return [
          ChangeNotifierProvider<SessionsViewModel>.value(value: sessions),
        ];
      },
    );
    addTearDown(sessions.dispose);
    final id = f.vm.plan.activeSessionId!;
    repo.reads.single.gate.completeError(
      const StorageFailure('synthetic read failure'),
    );
    await hybridSettle(t);
    await t.tap(find.text('Retry'));
    await t.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await t.runAsync(() => f.seed.sessions.delete(id));
    repo.reads.last.gate.complete();
    await hybridSettle(t);
    expect(find.text('This entry no longer exists.'), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
    expect(repo.reads.every((r) => r.id == id), isTrue);
  });
}
