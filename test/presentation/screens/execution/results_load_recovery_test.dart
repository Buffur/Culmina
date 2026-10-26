import 'dart:async';

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/session.dart';
import 'package:astroplan/domain/models/execution.dart';
import 'package:astroplan/domain/repositories/storage_failure.dart';
import 'package:astroplan/presentation/screens/execution/results_screen.dart';
import 'package:astroplan/presentation/viewmodels/results_viewmodel.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../../support/wave1_capture.dart';

class _HeldReads extends DriftSessionRepository {
  _HeldReads(this.store) : super(store);
  final AppDatabase store;
  final reads = <Completer<void>>[];
  Completer<void>? executionGate;

  @override
  Future<Session?> get(int id) async {
    final gate = Completer<void>();
    reads.add(gate);
    await gate.future;
    return super.get(id);
  }

  @override
  Future<ExecutionState> execution(int id) async {
    await executionGate?.future;
    return DriftSessionRepository(store).execution(id);
  }
}

SessionPlan _plan(String name) => SessionPlan(
  eveningDate: CalendarDate(2026, 10, 19),
  timeZoneId: 'Europe/Kyiv',
  siteId: null,
  targetId: null,
  rigId: null,
  blocks: [],
  targetLabel: name,
  rigLabel: 'QA rig',
);

void main() {
  setUpAll(loadWave1Font);
  for (final theme in ['light', 'dark', 'field']) {
    testWidgets(
      'UIA-0002: $theme pending, failure, Retry, success and id replacement',
      (t) async {
        if (!wave1IsNative) {
          t.view.physicalSize = const Size(375, 812);
          t.view.devicePixelRatio = 1;
          addTearDown(t.view.reset);
        }
        final db = AppDatabase(NativeDatabase.memory());
        final repo = _HeldReads(db);
        final vm = ResultsViewModel(
          repo,
          FixedClock(DateTime.utc(2026, 10, 20)),
        );
        addTearDown(vm.dispose);
        addTearDown(() => t.runAsync(db.close));
        late Session first, second;
        await t.runAsync(() async {
          final seed = DriftSessionRepository(db);
          first = await seed.create(_plan('First'));
          second = await seed.create(_plan('Second'));
        });
        Future<void> mount(int id) => t.pumpWidget(
          ChangeNotifierProvider.value(
            value: vm,
            child: wave1App(theme, home: ResultsScreen(sessionId: id)),
          ),
        );
        await mount(first.id);
        await t.pump();
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(vm.isLoading, isTrue);
        await captureWave1(t, 'results-$theme-pending');
        repo.reads.last.completeError(const StorageFailure('read the result'));
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
        expect(find.text('Retry'), findsOneWidget);
        expect(find.textContaining("Couldn't load the result"), findsOneWidget);
        await captureWave1(t, 'results-$theme-failure');
        await t.tap(find.text('Retry'));
        await t.pump();
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Retry'), findsNothing);
        await captureWave1(t, 'results-$theme-retry-pending');
        await t.runAsync(() async {
          repo.reads.last.complete();
          await Future<void>.delayed(const Duration(milliseconds: 60));
        });
        await t.pumpAndSettle();
        expect(vm.session?.id, first.id);
        expect(vm.loadError, isNull);
        expect(find.byType(CircularProgressIndicator), findsNothing);
        await captureWave1(t, 'results-$theme-success');

        // A same-State route replacement starts a new owned read and form.
        await mount(second.id);
        await t.pump();
        expect(vm.requestedId, second.id);
        expect(vm.session, isNull);
        await t.runAsync(() async {
          repo.reads.last.complete();
          await Future<void>.delayed(const Duration(milliseconds: 60));
        });
        await t.pumpAndSettle();
        expect(vm.session?.id, second.id);
        expect(find.byType(CircularProgressIndicator), findsNothing);
        await t.runAsync(() async {
          final stored = await DriftSessionRepository(db).get(first.id);
          expect(stored!.status, first.status);
          expect(stored.planSnapshot, first.planSnapshot);
          expect(stored.updatedAtUtc, first.updatedAtUtc);
        });
      },
    );
  }

  for (final obsoleteError in [false, true]) {
    test(
      'UIA-0002: obsolete ${obsoleteError ? 'failure' : 'missing'} cannot replace newer success',
      () async {
        final db = AppDatabase(NativeDatabase.memory());
        addTearDown(db.close);
        final repo = _HeldReads(db);
        final vm = ResultsViewModel(
          repo,
          FixedClock(DateTime.utc(2026, 10, 20)),
        );
        addTearDown(vm.dispose);
        final s = await DriftSessionRepository(db).create(_plan('Current'));
        final old = vm.load(99999);
        final current = vm.load(s.id);
        repo.reads.last.complete();
        await current;
        if (obsoleteError) {
          repo.reads.first.completeError(const StorageFailure('obsolete read'));
        } else {
          repo.reads.first.complete();
        }
        await old;
        expect(vm.session?.id, s.id);
        expect(vm.loadError, isNull);
        expect(vm.missingId, isNull);
        expect(vm.isLoading, isFalse);
        final missing = vm.load(99999);
        repo.reads.last.complete();
        await missing;
        expect(vm.missingId, 99999);
        expect(vm.loadError, isNull);
      },
    );
  }

  test(
    'UIA-0002: late execution read and dispose cannot publish obsolete state',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = _HeldReads(db);
      final seed = DriftSessionRepository(db);
      final first = await seed.create(_plan('First'));
      final second = await seed.create(_plan('Second'));
      final vm = ResultsViewModel(repo, FixedClock(DateTime.utc(2026, 10, 20)));
      repo.executionGate = Completer<void>();
      final old = vm.load(first.id);
      repo.reads.last.complete();
      await Future<void>.delayed(const Duration(milliseconds: 30));
      final execution = repo.executionGate!;
      repo.executionGate = null;
      final current = vm.load(second.id);
      repo.reads.last.complete();
      await current;
      execution.complete();
      await old;
      expect(vm.session?.id, second.id);
      final pending = vm.load(first.id);
      vm.dispose();
      repo.reads.last.completeError(const StorageFailure('late disposed read'));
      await pending;
    },
  );

  test('UIA-0002: same-id stale failure and execution failure retain request ownership', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = _HeldReads(db);
    final session = await DriftSessionRepository(db).create(_plan('Current'));
    final vm = ResultsViewModel(repo, FixedClock(DateTime.utc(2026, 10, 20)));
    addTearDown(vm.dispose);
    final old = vm.load(session.id);
    final retry = vm.load(session.id);
    repo.reads.last.complete();
    await retry;
    repo.reads.first.completeError(
      const StorageFailure('obsolete same-id read'),
    );
    await old;
    expect(vm.session?.id, session.id);
    expect(vm.loadError, isNull);
    repo.executionGate = Completer<void>();
    final broken = vm.load(session.id);
    repo.reads.last.complete();
    await Future<void>.delayed(const Duration(milliseconds: 30));
    repo.executionGate!.completeError(const StorageFailure('execution read'));
    await broken;
    expect(vm.session, isNull);
    expect(vm.loadError, isA<StorageFailure>());
    expect(vm.missingId, isNull);
    expect(vm.isLoading, isFalse);
    repo.executionGate = null;
    final recovered = vm.load(session.id);
    repo.reads.last.complete();
    await recovered;
    expect(vm.session?.id, session.id);
    expect(vm.loadError, isNull);
  });
}
