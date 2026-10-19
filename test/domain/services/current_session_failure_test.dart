// TASK 15.1: a failed autosave is a state, not a jammed write chain. Before,
// one failed write left the chain failed, so every later edit was silently
// never saved.

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/planning_preferences.dart';
import 'package:astroplan/domain/models/session.dart';
import 'package:astroplan/domain/models/session_night.dart';
import 'package:astroplan/domain/repositories/storage_failure.dart';
import 'package:astroplan/domain/services/capture_budget_calculator.dart';
import 'package:astroplan/domain/services/current_session.dart';
import 'package:astroplan/domain/services/session_snapshot_builder.dart';
import 'package:drift/drift.dart'
    show QueryInterceptor, QueryExecutor, ApplyInterceptor;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class _FailingWrites extends QueryInterceptor {
  bool failing = false;

  @override
  Future<int> runInsert(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) => failing
      ? throw Exception('simulated disk full')
      : executor.runInsert(statement, args);

  @override
  Future<int> runUpdate(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) => failing
      ? throw Exception('simulated disk full')
      : executor.runUpdate(statement, args);
}

SessionPlan _plan(int frames) => SessionPlan(
  eveningDate: CalendarDate(2026, 9, 24),
  timeZoneId: 'Europe/Ljubljana',
  siteId: null,
  targetId: null,
  rigId: null,
  blocks: [
    CaptureBlock(
      id: 0,
      frameType: FrameType.light,
      exposureTimeSeconds: 300,
      frameCount: frames,
    ),
  ],
  targetLabel: 'M31',
  rigLabel: 'Rig',
);

void main() {
  late _FailingWrites interceptor;
  late AppDatabase db;
  late DriftSessionRepository repo;
  late CurrentSession current;
  late int changes;

  setUp(() async {
    interceptor = _FailingWrites();
    db = AppDatabase(NativeDatabase.memory().interceptWith(interceptor));
    repo = DriftSessionRepository(
      db,
      clock: FixedClock(DateTime.utc(2026, 9, 24, 18)),
    );
    current = CurrentSession(repo);
    changes = 0;
    current.onWriteFailureChanged = () => changes++;
    await current.startNew(_plan(10));
  });

  tearDown(() => db.close());

  test('a failed write is reported, not thrown, and the next one retries '
      'the whole plan', () async {
    interceptor.failing = true;
    await current.write(() => _plan(20)); // completes normally
    expect(current.writeFailure, isA<StorageFailure>());
    expect(changes, 1);

    interceptor.failing = false;
    await current.write(() => _plan(30));
    expect(current.writeFailure, isNull);
    expect(changes, 2);
    final stored = await repo.get(current.session!.id);
    expect(stored!.blocks.single.frameCount, 30);
  });

  test('later operations are not blocked by a failed write', () async {
    interceptor.failing = true;
    await current.write(() => _plan(20));
    interceptor.failing = false;
    await current.idle; // completes: the chain is not left failed
    final fresh = await current.startNew(_plan(5));
    expect(fresh.status, SessionStatus.draft);
  });

  test('each failure is reported; a success clears it once', () async {
    interceptor.failing = true;
    await current.write(() => _plan(20));
    await current.write(() => _plan(21));
    expect(changes, 2); // two distinct failures, each reported
    interceptor.failing = false;
    await current.write(() => _plan(22));
    await current.write(() => _plan(23));
    expect(changes, 3); // cleared once, then no change
  });

  // TD-095 (F18 A2): a successful Save writes the whole plan, so the
  // banner of an earlier failed autosave goes; a failed Save keeps it.
  test('a successful Save clears an earlier autosave failure', () async {
    interceptor.failing = true;
    await current.write(() => _plan(11));
    expect(current.writeFailure, isNotNull);
    final before = changes;
    final blocks = [
      CaptureBlock(
        frameType: FrameType.light,
        exposureTimeSeconds: 300,
        frameCount: 12,
      ),
    ];
    final prefs = PlanningPreferences();
    final snapshot = SessionSnapshotBuilder.build(
      takenAtUtc: DateTime.utc(2026, 9, 24, 18),
      night: SessionNight(
        eveningDate: CalendarDate(2026, 9, 24),
        startUtc: DateTime.utc(2026, 9, 24, 11),
        endUtc: DateTime.utc(2026, 9, 25, 11),
        latitude: 46.05,
        longitude: 14.51,
        timeContextId: 'Europe/Ljubljana',
      ),
      preferences: prefs,
      budget: CaptureBudgetCalculator.calculate(
        blocks: blocks,
        overheads: CaptureOverheads.fromPreferences(prefs),
      ),
      blocks: blocks,
    );
    await expectLater(current.save(_plan(12), snapshot), throwsA(anything));
    expect(current.writeFailure, isNotNull, reason: 'a failed Save keeps it');
    interceptor.failing = false;
    final saved = await current.save(_plan(12), snapshot);
    expect(saved.isSavedPlan, isTrue);
    expect(current.writeFailure, isNull);
    expect(changes, greaterThan(before), reason: 'the banner is told');
  });
}
