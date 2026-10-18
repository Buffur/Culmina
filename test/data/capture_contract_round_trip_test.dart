// CHK-F03.A3 (ADR-021 C1/C3/C4/C6/C7, C17, C18): the recorded white balance,
// focus mode, field origins and file evidence of a block, and a rig's
// capture format and measured-file association, survive save and reopen
// (also on a fresh connection to the same file), a rig edit, the plan
// snapshot (version 1, additive), the export manifest (version 2,
// additive) and a backup restore. Old data without them reads as
// unrecorded, never a default.

import 'dart:io';

import 'package:astroplan/data/backup/backup_staging.dart';
import 'package:astroplan/data/backup/file_backup_service.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/export/session_manifest_codec.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/capture_evidence.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/planning_preferences.dart';
import 'package:astroplan/domain/models/session.dart';
import 'package:astroplan/domain/models/session_snapshot.dart';
import 'package:astroplan/domain/models/site_time_context.dart';
import 'package:astroplan/domain/services/backup_service.dart';
import 'package:astroplan/domain/services/capture_budget_calculator.dart';
import 'package:astroplan/domain/services/saved_plan_reader.dart';
import 'package:astroplan/domain/services/session_exporter.dart';
import 'package:astroplan/domain/services/session_night_resolver.dart';
import 'package:astroplan/domain/services/session_snapshot_builder.dart';
import 'package:astroplan/presentation/shared/equipment_draft.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import '../support/test_clock.dart';

final _light = CaptureBlock(
  frameType: FrameType.light,
  filterName: 'Ha',
  exposureTimeSeconds: 300,
  frameCount: 12,
  binning: 2,
  gain: CaptureGain.gain(100),
  whiteBalance: WhiteBalance.kelvin(5600, tint: -2),
  focusMode: FocusMode.mf,
  origins: FieldOrigins({
    CaptureField.exposure: FieldOrigin(
      OriginKind.file,
      'L_0001.fits',
      evidence: {'tag': 'EXPTIME'},
    ),
    CaptureField.filter: FieldOrigin(OriginKind.entered, 'entered'),
  }),
  fileEvidence: FileEvidence(
    bytes: 13049280,
    format: 'fits',
    read: true,
    width: 3124,
    height: 2088,
    bitsPerSample: 16,
    compression: FileCompression.none,
    binning: 2,
    label: '/sdcard/Astro/L_0001.fits',
  ),
);

final _flat = CaptureBlock(
  frameType: FrameType.flat,
  filterName: 'Ha',
  exposureTimeSeconds: 2,
  frameCount: 20,
  whiteBalance: WhiteBalance.preset(WhiteBalancePreset.daylight),
  focusMode: FocusMode.af,
  origins: FieldOrigins({
    CaptureField.filter: FieldOrigin(OriginKind.inherited, 'from the Ha block'),
  }),
  fileEvidence: FileEvidence(
    bytes: 31457280,
    format: 'recognized:cr3',
    read: false,
    label: 'IMG_1.CR3',
  ),
);

/// A block without any of the new values (as before v26).
final _plain = CaptureBlock(
  frameType: FrameType.dark,
  exposureTimeSeconds: 300,
  frameCount: 10,
);

final _blocks = [_light, _flat, _plain];

final _rig = EquipmentProfile(
  id: 0,
  name: 'Refractor',
  cameraModel: 'ASI2600MM',
  sensorWidthMm: 23.5,
  sensorHeightMm: 15.7,
  pixelPitchUm: 3.76,
  resolutionWidthPx: 6248,
  resolutionHeightPx: 4176,
  focalLengthMm: 480,
  focalRatio: 6,
  averageRawFileSizeMB: 52.19,
  captureFormat: CaptureFormat.fits16,
  captureFormatSource: 'file:L_0001.fits',
  rawFileSizeEvidence: FileEvidence(
    bytes: 52188480,
    format: 'fits',
    read: true,
    width: 6248,
    height: 4176,
    bitsPerSample: 16,
    compression: FileCompression.none,
    binning: 1,
    label: 'L_0001.fits',
  ),
);

SessionPlan _plan({int? rigId}) => SessionPlan(
  eveningDate: CalendarDate(2026, 11, 10),
  timeZoneId: 'Europe/Ljubljana',
  siteId: null,
  targetId: null,
  rigId: rigId,
  blocks: _blocks,
  targetLabel: '(no target)',
  rigLabel: 'Refractor',
);

/// The ADR-021 values of [b], for comparison.
(WhiteBalance?, FocusMode?, FieldOrigins, FileEvidence?) _evidence(
  CaptureBlock b,
) => (b.whiteBalance, b.focusMode, b.origins, b.fileEvidence);

void main() {
  late Directory dir;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    dir = Directory.systemTemp.createTempSync('capture_contract');
  });
  tearDown(() => dir.deleteSync(recursive: true));

  File dbFile() => File(p.join(dir.path, 'app.sqlite'));

  test('blocks keep their values through save, reopen and a new '
      'connection; a block without them stays unrecorded', () async {
    var db = AppDatabase(NativeDatabase(dbFile()));
    final created = await DriftSessionRepository(
      db,
      clock: testEvening,
    ).create(_plan());
    final reopened = (await DriftSessionRepository(
      db,
      clock: testEvening,
    ).get(created.id))!;
    expect(reopened.blocks.map(_evidence), _blocks.map(_evidence));
    expect(reopened.blocks.first.fileEvidence!.label, 'L_0001.fits');
    expect(reopened.blocks[1].fileEvidence!.width, isNull);
    final plain = reopened.blocks.last;
    expect(
      (plain.whiteBalance, plain.focusMode, plain.fileEvidence),
      (null, null, null),
    );
    expect(plain.origins.isEmpty, isTrue);
    await db.close();

    db = AppDatabase(NativeDatabase(dbFile()));
    final again = (await DriftSessionRepository(
      db,
      clock: testEvening,
    ).get(created.id))!;
    expect(again.blocks.map(_evidence), _blocks.map(_evidence));
    // An edit of the plan's blocks keeps the untouched block's values.
    final edited = await DriftSessionRepository(db, clock: testEvening)
        .updatePlan(
          created.id,
          SessionPlan(
            eveningDate: again.eveningDate!,
            timeZoneId: 'Europe/Ljubljana',
            siteId: null,
            targetId: null,
            rigId: null,
            blocks: [
              again.blocks.first.copyWith(frameCount: 30),
              ...again.blocks.skip(1),
            ],
            targetLabel: '(no target)',
            rigLabel: 'Refractor',
          ),
        );
    expect(edited.blocks.first.frameCount, 30);
    expect(edited.blocks.map(_evidence), _blocks.map(_evidence));
    await db.close();
  });

  test('a rig keeps its capture format and measured file; an edit keeps '
      'the file only while its size is unchanged', () async {
    final db = AppDatabase(NativeDatabase(dbFile()));
    final repo = DriftEquipmentRepository(db);
    final id = await repo.insertEquipment(_rig);
    var rig = (await repo.getAllEquipment()).single;
    expect(rig.id, id);
    expect(
      (rig.captureFormat, rig.captureFormatSource, rig.rawFileSizeEvidence),
      (_rig.captureFormat, _rig.captureFormatSource, _rig.rawFileSizeEvidence),
    );

    // Opened in the rig editor and saved unchanged: kept.
    final draft = EquipmentDraft.fromProfile(rig);
    final unchanged = draft.build(draft.initial, rig.trackingType).profile!;
    expect(unchanged.captureFormat, CaptureFormat.fits16);
    expect(unchanged.rawFileSizeEvidence, _rig.rawFileSizeEvidence);
    await repo.updateEquipment(unchanged);
    rig = (await repo.getAllEquipment()).single;
    expect(rig.rawFileSizeEvidence, _rig.rawFileSizeEvidence);

    // A typed new size: the old file no longer describes it.
    final t = draft.initial;
    final changed = draft
        .build(
          EquipmentFormTexts(
            name: t.name,
            manufacturer: t.manufacturer,
            cameraModel: t.cameraModel,
            resolutionWidth: t.resolutionWidth,
            resolutionHeight: t.resolutionHeight,
            pixelPitch: t.pixelPitch,
            sensorWidth: t.sensorWidth,
            sensorHeight: t.sensorHeight,
            focalLength: t.focalLength,
            focalRatio: t.focalRatio,
            diameter: t.diameter,
            rawFileSize: '60',
            rotation: t.rotation,
            maxExposure: t.maxExposure,
          ),
          rig.trackingType,
        )
        .profile!;
    expect(changed.averageRawFileSizeMB, 60);
    expect(changed.rawFileSizeEvidence, isNull);
    expect(changed.captureFormat, CaptureFormat.fits16);
    await repo.updateEquipment(changed);
    rig = (await repo.getAllEquipment()).single;
    expect((rig.averageRawFileSizeMB, rig.rawFileSizeEvidence), (60, null));
    expect(rig.captureFormat, CaptureFormat.fits16);
    await db.close();
  });

  group('the plan snapshot (version 1, additive)', () {
    final night = SessionNightResolver.forEveningDate(
      CalendarDate(2026, 11, 10),
      latitude: 46.05,
      longitude: 14.51,
      timeContext: MeanSolarTimeContext(14.51),
    );
    SessionSnapshot snapshot() {
      final prefs = PlanningPreferences();
      return SessionSnapshotBuilder.build(
        takenAtUtc: DateTime.utc(2026, 11, 10, 18),
        night: night,
        timeZoneId: 'Europe/Ljubljana',
        preferences: prefs,
        budget: CaptureBudgetCalculator.calculate(
          blocks: _blocks,
          overheads: CaptureOverheads.fromPreferences(prefs),
          targetTransitsInWindow: false,
        ),
        blocks: _blocks,
        rig: _rig,
      );
    }

    test('records the values; a saved plan reads them back', () {
      final s = snapshot();
      expect(s.json['v'], SessionSnapshot.currentVersion);
      expect(SessionSnapshot.currentVersion, 1);
      final rig = s.json['rig']! as Map;
      expect(rig['captureFormat'], 'fits16');
      expect(rig['captureFormatSource'], 'file:L_0001.fits');
      expect(
        FileEvidence.fromJson(rig['rawFileSizeEvidence']),
        _rig.rawFileSizeEvidence,
      );
      final read = SavedPlanReader.read(SessionSnapshot.tryRead(s.json)!)!;
      expect(read.blocks.map(_evidence), _blocks.map(_evidence));
    });

    test('a snapshot taken before v26 reads them as unrecorded', () {
      final json = Map<String, Object?>.from(snapshot().json);
      json['blocks'] = [
        for (final b in json['blocks']! as List)
          Map<String, Object?>.from(b as Map)
            ..remove('wb')
            ..remove('focusMode')
            ..remove('origins')
            ..remove('fileEvidence'),
      ];
      final read = SavedPlanReader.read(SessionSnapshot.tryRead(json)!)!;
      for (final b in read.blocks) {
        expect(
          (b.whiteBalance, b.focusMode, b.fileEvidence),
          (null, null, null),
        );
        expect(b.origins.isEmpty, isTrue);
      }
    });
  });

  group('the export manifest (version 2, additive)', () {
    Future<Session> saved() async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = DriftSessionRepository(db, clock: testEvening);
      return (await repo.get((await repo.create(_plan())).id))!;
    }

    test('round trips; origins carry kind and descriptor only', () async {
      final session = await saved();
      final json = SessionManifestCodec.encode(
        [ExportedSession(session, const [])],
        exportedAtUtc: DateTime.utc(2026, 11, 11, 8),
        appVersion: 'test',
      );
      expect(json['manifest_version'], 2);
      final block =
          ((json['sessions']! as List).single as Map)['blocks'] as List;
      final light = block.first as Map;
      expect(light['white_balance'], {
        'mode': 'kelvin',
        'preset': null,
        'kelvinK': 5600,
        'tint': -2.0,
      });
      expect(light['focus_mode'], 'mf');
      expect((light['field_origins'] as Map)['exposure'], {
        'k': 'file',
        'd': 'L_0001.fits',
      });
      expect((light['file_evidence'] as Map)['label'], 'L_0001.fits');
      expect((block.last as Map)['white_balance'], isNull);

      final decoded = SessionManifestCodec.decode(json)
          .sessions
          .single
          .session
          .blocks;
      expect(decoded.map((b) => (b.whiteBalance, b.focusMode)), [
        for (final b in _blocks) (b.whiteBalance, b.focusMode),
      ]);
      expect(
        decoded.first.origins[CaptureField.exposure]?.descriptor,
        'L_0001.fits',
      );
      expect(decoded.first.origins[CaptureField.exposure]?.evidence, isNull);
      expect(decoded.first.fileEvidence?.bytes, 13049280);
      expect(decoded.last.origins.isEmpty, isTrue);
    });

    test('a manifest written before v26 reads them as unrecorded', () async {
      final json = SessionManifestCodec.encode(
        [ExportedSession(await saved(), const [])],
        exportedAtUtc: DateTime.utc(2026, 11, 11, 8),
        appVersion: 'test',
      );
      for (final b
          in ((json['sessions']! as List).single as Map)['blocks'] as List) {
        (b as Map)
          ..remove('white_balance')
          ..remove('focus_mode')
          ..remove('field_origins')
          ..remove('file_evidence');
      }
      for (final b in SessionManifestCodec.decode(
        json,
      ).sessions.single.session.blocks) {
        expect(
          (b.whiteBalance, b.focusMode, b.fileEvidence),
          (null, null, null),
        );
        expect(b.origins.isEmpty, isTrue);
      }
    });
  });

  test('a backup restore keeps every value of blocks and rigs', () async {
    final oldPhone = Directory(p.join(dir.path, 'old'))..createSync();
    final newPhone = Directory(p.join(dir.path, 'new'))..createSync();
    final tmp = Directory(p.join(dir.path, 'tmp'))..createSync();
    final oldDb = AppDatabase(
      NativeDatabase(File(p.join(oldPhone.path, BackupStaging.database))),
    );
    final oldRepo = DriftSessionRepository(oldDb, clock: testEvening);
    final rigId = await DriftEquipmentRepository(oldDb).insertEquipment(_rig);
    final created = await oldRepo.create(_plan(rigId: rigId));
    final service = FileBackupService(
      oldDb,
      oldRepo,
      clock: testEvening,
      dataDir: () async => newPhone,
      tempDir: () async => tmp,
    );
    final bytes = await service.createBackup();
    await oldDb.close();

    await service.stage(service.check(bytes));
    expect(
      (await BackupStaging.apply(
        newPhone,
        nowUtc: testEvening.nowUtc(),
      ))!.result,
      RestoreResult.applied,
    );
    final newDb = AppDatabase(
      NativeDatabase(File(p.join(newPhone.path, BackupStaging.database))),
    );
    final restored = (await DriftSessionRepository(
      newDb,
      clock: testEvening,
    ).get(created.id))!;
    expect(restored.blocks.map(_evidence), _blocks.map(_evidence));
    final rig = (await DriftEquipmentRepository(
      newDb,
    ).getAllEquipment()).single;
    expect(
      (rig.captureFormat, rig.captureFormatSource, rig.rawFileSizeEvidence),
      (_rig.captureFormat, _rig.captureFormatSource, _rig.rawFileSizeEvidence),
    );
    await newDb.close();
  });
}
