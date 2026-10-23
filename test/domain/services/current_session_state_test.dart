// QA-02 (phone QA 2026-10-23): an autosave that changes the current
// session's state — a saved plan returning to a draft (Saved · changed), a
// first write that creates the draft — is announced after it lands, so the
// planner's listeners never keep the state they read before the write. A
// write that leaves the state as it was announces nothing (the memoized
// budget and fit are not invalidated per edit, trap 16).

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/planning_preferences.dart';
import 'package:astroplan/domain/models/session.dart';
import 'package:astroplan/domain/models/session_night.dart';
import 'package:astroplan/domain/services/capture_budget_calculator.dart';
import 'package:astroplan/domain/services/current_session.dart';
import 'package:astroplan/domain/services/session_snapshot_builder.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

List<CaptureBlock> _blocks(int frames) => [
  CaptureBlock(
    frameType: FrameType.light,
    exposureTimeSeconds: 300,
    frameCount: frames,
  ),
];

SessionPlan _plan(int frames) => SessionPlan(
  eveningDate: CalendarDate(2026, 9, 24),
  timeZoneId: 'Europe/Ljubljana',
  siteId: null,
  targetId: null,
  rigId: null,
  blocks: _blocks(frames),
  targetLabel: 'M31',
  rigLabel: 'Rig',
);

void main() {
  late AppDatabase db;
  late DriftSessionRepository repo;
  late CurrentSession current;
  late List<SessionStatus?> heard;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftSessionRepository(
      db,
      clock: FixedClock(DateTime.utc(2026, 9, 24, 18)),
    );
    current = CurrentSession(repo);
    heard = [];
    current.onSessionChanged = () => heard.add(current.session?.status);
  });

  tearDown(() => db.close());

  Future<Session> save(int frames) {
    final prefs = PlanningPreferences();
    final blocks = _blocks(frames);
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
    return current.save(_plan(frames), snapshot);
  }

  test('the first edit of a saved plan is announced after the write, with '
      'the session already back in draft', () async {
    await current.startNew(_plan(10));
    final saved = await save(10);
    expect(saved.status, SessionStatus.planned);
    heard.clear();

    await current.write(() => _plan(11));

    expect(heard, [SessionStatus.draft]);
    expect(current.session!.isSavedChanged, isTrue);
  });

  test('a site change on a saved plan (edit: false) is announced the same '
      'way', () async {
    await current.startNew(_plan(10));
    await save(10);
    heard.clear();

    await current.write(() => _plan(10), edit: false);

    expect(heard, [SessionStatus.draft]);
  });

  test('a write that leaves the state as it was announces nothing', () async {
    await current.startNew(_plan(10));
    await save(10);
    await current.write(() => _plan(11));
    heard.clear();

    await current.write(() => _plan(12));
    await current.write(() => _plan(13));

    expect(heard, isEmpty);
  });

  test('a first write without a session creates the draft and announces '
      'it', () async {
    await current.write(() => _plan(10));

    expect(heard, [SessionStatus.draft]);
    expect(current.session, isNotNull);
  });
}
