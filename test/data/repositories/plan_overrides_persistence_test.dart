import 'dart:io';

import 'package:astroplan/data/backup/restore_candidate.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/database/generated_migrations/schema.dart';
import 'package:astroplan/data/export/session_manifest_codec.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/plan_overrides.dart';
import 'package:astroplan/domain/models/planning_preferences.dart';
import 'package:astroplan/domain/models/session.dart';
import 'package:astroplan/domain/models/session_night.dart';
import 'package:astroplan/domain/services/capture_budget_calculator.dart';
import 'package:astroplan/domain/services/saved_plan_reader.dart';
import 'package:astroplan/domain/services/session_exporter.dart';
import 'package:astroplan/domain/services/session_snapshot_builder.dart';
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final overrides = PlanOverrides(
    interframeSeconds: 7.5,
    outsideSetupSeconds: 900,
    fixedMarginSeconds: 600,
    bytesPerFrame: 30000000,
  );
  final night = SessionNight(
    eveningDate: CalendarDate(2026, 12, 15),
    startUtc: DateTime.utc(2026, 12, 15, 11),
    endUtc: DateTime.utc(2026, 12, 16, 11),
    latitude: 46,
    longitude: 14,
    timeContextId: 'test',
  );
  SessionPlan plan(PlanOverrides? values) => SessionPlan(
    eveningDate: night.eveningDate,
    timeZoneId: null,
    siteId: null,
    targetId: null,
    rigId: null,
    blocks: [
      CaptureBlock(
        frameType: FrameType.light,
        exposureTimeSeconds: 60,
        frameCount: 10,
      ),
    ],
    targetLabel: 'Target',
    rigLabel: 'Rig',
    planOverrides: values,
  );
  final prefs = PlanningPreferences();
  final snapshot = SessionSnapshotBuilder.build(
    takenAtUtc: DateTime.utc(2026, 12, 15, 18),
    night: night,
    preferences: prefs,
    budget: CaptureBudgetCalculator.calculate(
      blocks: plan(overrides).blocks,
      overheads: CaptureOverheads.fromPreferences(
        prefs,
        planOverrides: overrides,
      ),
      frameBytes: [overrides.bytesPerFrame],
    ),
    blocks: plan(overrides).blocks,
    planOverrides: overrides,
  );

  test(
    'save, reopen, edit, discard and manifest retain explicit assumptions',
    () async {
      final root = await Directory.systemTemp.createTemp('plan-overrides');
      addTearDown(() => root.delete(recursive: true));
      final file = File('${root.path}/plan.sqlite');
      var db = AppDatabase(NativeDatabase(file));
      var repo = DriftSessionRepository(db);
      final draft = await repo.create(plan(overrides));
      await repo.savePlan(draft.id, plan(overrides), snapshot);
      await db.close();
      db = AppDatabase(NativeDatabase(file));
      addTearDown(db.close);
      repo = DriftSessionRepository(db);
      final saved = (await repo.get(draft.id))!;
      expect(saved.planOverrides!.toJson(), overrides.toJson());
      expect(saved.planSnapshot!.perFrameOverheadSeconds, 7.5);
      expect(
        SavedPlanReader.read(saved.planSnapshot!)!.planOverrides!.toJson(),
        overrides.toJson(),
      );
      await repo.updatePlan(saved.id, plan(null));
      expect((await repo.get(saved.id))!.planOverrides, isNull);
      final reverted = await repo.revertToSaved(saved.id);
      expect(reverted.planOverrides!.toJson(), overrides.toJson());
      final encoded = SessionManifestCodec.encode(
        [ExportedSession(reverted, [])],
        exportedAtUtc: DateTime.utc(2026),
        appVersion: 'test',
      );
      final decoded = SessionManifestCodec.decode(encoded)
          .sessions
          .single
          .session;
      expect(decoded.planOverrides!.toJson(), overrides.toJson());
      ((encoded['sessions'] as List).single as Map).remove('plan_overrides');
      expect(
        SessionManifestCodec.decode(encoded)
            .sessions
            .single
            .session
            .planOverrides,
        isNull,
      );
      await repo.updatePlan(
        saved.id,
        plan(PlanOverrides(interframeSeconds: 0)),
      );
      final copy = (await repo.settleSavedPlan(saved.id))!;
      expect(copy.planOverrides!.interframeSeconds, 0);
      expect(
        (await repo.get(saved.id))!.planOverrides!.toJson(),
        overrides.toJson(),
      );
    },
  );

  test('every supported schema upgrades to v27', () async {
    final verifier = SchemaVerifier(GeneratedHelper());
    for (var from = 8; from < 27; from++) {
      final db = AppDatabase(await verifier.startAt(from));
      await verifier.migrateAndValidate(db, 27);
      await db.close();
    }
  });

  test(
    'a real old backup migrates without changing plans or snapshots',
    () async {
      final root = await Directory.systemTemp.createTemp('plan-v26-backup');
      addTearDown(() => root.delete(recursive: true));
      final schema = await SchemaVerifier(GeneratedHelper()).schemaAt(26);
      const oldSnapshot =
          '{"v":1,"night":{"eveningDate":"2026-12-15"},'
          '"blocks":[],"preferences":{"perFrameOverheadS":5}}';
      schema.rawDatabase.execute(
        "INSERT INTO session_logs (id,target_name,equipment_name,session_date,"
        "planned_light_frames,status,legacy,evening_date,plan_snapshot) "
        "VALUES(1,'M42','Rig',1790000000,10,'planned',0,'2026-12-15',?);",
        [oldSnapshot],
      );
      final file = File('${root.path}/old.sqlite');
      schema.rawDatabase.execute("VACUUM INTO '${file.path}';");
      await checkRestoreCandidate(file);
      final db = AppDatabase(NativeDatabase(file));
      addTearDown(db.close);
      final s = (await DriftSessionRepository(db).get(1))!;
      expect(s.record.targetName, 'M42');
      expect(s.planOverrides, isNull);
      expect(s.planSnapshot!.perFrameOverheadSeconds, 5);
      expect(SavedPlanReader.read(s.planSnapshot!)!.planOverrides, isNull);
      expect(
        (await db.customSelect('PRAGMA integrity_check').getSingle())
            .data
            .values,
        ['ok'],
      );
      expect(
        (await db.customSelect('PRAGMA user_version').getSingle()).data.values,
        [27],
      );
    },
  );
}
