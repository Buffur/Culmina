import 'dart:io';

import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/models/equipment_profile.dart' as domain;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

const _tables = [
  'devices',
  'camera_modules',
  'optical_rigs',
  'astro_targets',
  'target_aliases',
  'location_profiles',
  'session_logs',
  'capture_blocks',
  'session_events',
];

Future<Map<String, Object>> _graph(AppDatabase db) async => {
  for (final table in _tables)
    table: (await db.customSelect('SELECT * FROM "$table" ORDER BY id').get())
        .map((row) => row.data)
        .toList(),
};

Future<void> _seed(AppDatabase db) async {
  await DriftEquipmentRepository(db).insertEquipment(
    const domain.EquipmentProfile(
      id: 0,
      name: 'Known rig',
      sensorWidthMm: 36,
      sensorHeightMm: 24,
      pixelPitchUm: 6,
      resolutionWidthPx: 6000,
      resolutionHeightPx: 4000,
      focalLengthMm: 50,
      focalRatio: 2,
    ),
  );
  await db.customStatement(
    "INSERT INTO astro_targets (id,catalog_id,common_name,right_ascension,declination,type,source) VALUES (1,'M31','Andromeda',10.7,41.3,'Galaxy','user')",
  );
  await db.customStatement(
    "INSERT INTO target_aliases (id,catalog_id,alias,kind,catalog_version) VALUES (9,'M31','NGC224','designation',1)",
  );
  await db.customStatement(
    "INSERT INTO location_profiles (id,name,latitude,longitude,time_zone,bortle_class,notes) VALUES (1,'Home',50,30,'Europe/Kyiv',4,'Preserve notes')",
  );
  await db.customStatement('''
    INSERT INTO session_logs
      (id,target_name,equipment_name,session_date,planned_light_frames,
       status,site_id,target_id,rig_id,created_at_utc_ms,updated_at_utc_ms,
       planned_at_utc_ms,started_at_utc_ms,completed_at_utc_ms,
       plan_snapshot,execution_start_snapshot,plan_overrides,
       result_kind,actual_light_frames,rejected_frames,environmental_notes,processing_notes)
    VALUES (31,'M31','Known rig',123456,5,'completed',1,1,1,100,200,110,120,200,
      '{"schemaVersion":1,"unknownLegacyField":"untouched"}',
      '{"frozen":true}', '{"interframeSeconds":2,"bytesPerFrame":2000000}',
      'partly',4,1,'Clouds','Stack later')
  ''');
  await db.customStatement('''
    INSERT INTO capture_blocks
      (id,session_log_id,frame_type,filter_name,exposure_time_seconds,
       frame_count,binning,position,gain_kind,gain_value,completed_frames,
       rejected_frames,wb_mode,wb_kelvin,focus_mode,field_origins,file_evidence)
    VALUES (41,31,'light','Ha',60,5,2,3,'iso',800,4,1,'kelvin',4500,
      'mf','{"future":"preserve"}','{"legacy":"preserve"}')
  ''');
  await db.customStatement(
    "INSERT INTO session_events (id,session_log_id,seq,at_utc_ms,kind,block_id,delta,clock_adjusted) VALUES (51,31,1,120,'started',41,NULL,0),(52,31,2,200,'reported',41,4,1)",
  );
}

void main() {
  late AppDatabase db;
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await _seed(db);
  });
  tearDown(() => db.close());

  test('session Undo restores exact graph, IDs, frozen results and unknown JSON once', () async {
    final before = await _graph(db);
    final receipt = await DriftSessionRepository(db).deleteWithUndo(31);
    expect(await db.select(db.sessionLogs).get(), isEmpty);
    expect(await db.select(db.captureBlocks).get(), isEmpty);
    expect(await db.select(db.sessionEvents).get(), isEmpty);
    await Future.wait([receipt.restore(), receipt.restore()]);
    await receipt.restore();
    expect(receipt.restored, isTrue);
    expect(await _graph(db), before);
    expect(await db.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
    expect(
      (await db.customSelect('PRAGMA user_version').getSingle()).read<int>(
        'user_version',
      ),
      27,
    );
  });

  for (final kind in ['rig', 'target', 'site']) {
    test(
      '$kind Undo restores IDs, saved references and all metadata',
      () async {
        final before = await _graph(db);
        final receipt = switch (kind) {
          'rig' => await DriftEquipmentRepository(db).deleteWithUndo(1),
          'target' => await DriftTargetRepository(db).deleteWithUndo(1),
          _ => await DriftLocationRepository(db).deleteWithUndo(1),
        };
        final column = switch (kind) {
          'rig' => 'rig_id',
          'target' => 'target_id',
          _ => 'site_id',
        };
        expect(
          (await db
                  .customSelect('SELECT "$column" FROM session_logs')
                  .getSingle())
              .data[column],
          isNull,
        );
        await receipt.restore();
        expect(await _graph(db), before);
        expect(
          await db.customSelect('PRAGMA foreign_key_check').get(),
          isEmpty,
        );
      },
    );
  }

  test(
    'shared camera/device stays live and newer edits are not overwritten',
    () async {
      await db.customStatement(
        "INSERT INTO optical_rigs (id,name,camera_module_id,focal_length_mm,aperture) VALUES (2,'Shared',1,100,4)",
      );
      final receipt = await DriftEquipmentRepository(db).deleteWithUndo(1);
      expect(await db.select(db.cameraModules).get(), hasLength(1));
      await db.customStatement(
        "UPDATE camera_modules SET model='Newer model' WHERE id=1",
      );
      await receipt.restore();
      expect(
        (await db.select(db.cameraModules).getSingle()).model,
        'Newer model',
      );
      expect(await db.select(db.opticalRigs).get(), hasLength(2));
    },
  );

  test(
    'later session edit with the same timestamp wins over FK restoration',
    () async {
      final receipt = await DriftTargetRepository(db).deleteWithUndo(1);
      await db.customStatement(
        "UPDATE session_logs SET name='Newer edit' WHERE id=31",
      );
      await receipt.restore();
      final session = await db.select(db.sessionLogs).getSingle();
      expect(session.targetId, isNull);
      expect(session.name, 'Newer edit');
      expect(session.updatedAtUtcMs, 200);
    },
  );

  test('a new reference is preserved instead of overwritten by Undo', () async {
    final receipt = await DriftLocationRepository(db).deleteWithUndo(1);
    await db.customStatement(
      "INSERT INTO location_profiles (id,name,latitude,longitude) VALUES (2,'New site',1,2)",
    );
    await db.customStatement('UPDATE session_logs SET site_id=2 WHERE id=31');
    await receipt.restore();
    expect((await db.select(db.sessionLogs).getSingle()).siteId, 2);
    expect(await db.select(db.locationProfiles).get(), hasLength(2));
  });

  test(
    'identity conflict rolls back every inserted ancestor; retry restores',
    () async {
      final receipt = await DriftEquipmentRepository(db).deleteWithUndo(1);
      // Conflict in the second row: the device insertion must roll back too.
      await db.customStatement(
        "INSERT INTO devices (id,name) VALUES (9,'Other device')",
      );
      await db.customStatement(
        "INSERT INTO camera_modules (id,device_id,name,sensor_width_mm,sensor_height_mm,resolution_width_px,resolution_height_px,pixel_pitch_um) VALUES (1,9,'Other camera',1,1,1,1,1)",
      );
      await expectLater(receipt.restore(), throwsA(anything));
      expect(receipt.restored, isFalse);
      expect(
        await (db.select(db.devices)..where((row) => row.id.equals(1))).get(),
        isEmpty,
      );
      expect(
        (await db.select(db.cameraModules).getSingle()).name,
        'Other camera',
      );
      await (db.delete(
        db.cameraModules,
      )..where((row) => row.id.equals(1))).go();
      await receipt.restore();
      expect(await db.select(db.opticalRigs).get(), hasLength(1));
      expect(await db.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
    },
  );

  test(
    'legacy pre-snapshot row remains legacy with null overrides after Undo',
    () async {
      await db.customStatement(
        "INSERT INTO session_logs (id,target_name,equipment_name,session_date,planned_light_frames,status,legacy) VALUES (99,'Old target','Old rig',1,10,'completed',1)",
      );
      final before =
          (await db
                  .customSelect('SELECT * FROM session_logs WHERE id=99')
                  .getSingle())
              .data;
      final receipt = await DriftSessionRepository(db).deleteWithUndo(99);
      await receipt.restore();
      expect(
        (await db
                .customSelect('SELECT * FROM session_logs WHERE id=99')
                .getSingle())
            .data,
        before,
      );
      final session = (await DriftSessionRepository(db).get(99))!;
      expect(session.legacy, isTrue);
      expect(session.planOverrides, isNull);
      expect(session.planSnapshot, isNull);
    },
  );

  test(
    'restored graph persists through closing and reopening physical SQLite',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'culmina-delete-undo-',
      );
      final file = File('${directory.path}/undo.sqlite');
      var physical = AppDatabase(NativeDatabase(file));
      try {
        await _seed(physical);
        final before = await _graph(physical);
        final receipt = await DriftSessionRepository(physical)
            .deleteWithUndo(31);
        await receipt.restore();
        await physical.close();
        physical = AppDatabase(NativeDatabase(file));
        expect(await _graph(physical), before);
        expect(
          (await physical.customSelect('PRAGMA integrity_check').getSingle())
              .data
              .values
              .single,
          'ok',
        );
        expect(
          await physical.customSelect('PRAGMA foreign_key_check').get(),
          isEmpty,
        );
      } finally {
        await physical.close();
        await directory.delete(recursive: true);
      }
    },
  );
}
