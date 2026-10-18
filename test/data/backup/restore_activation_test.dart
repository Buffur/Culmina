// F01 (TD-106, CA-01/16/23, AUD-01, UXA-C1; D2/D7 A): only a usable,
// supported backup becomes the live database. Real SQLite files throughout:
// a header that merely says the right version proves nothing.
//
// CHK-F01.A1  truncated / schema-less / newer databases inside valid ZIPs
//             are refused when picked and again on activation; the live
//             database and settings are unchanged, the check copy deleted.
// CHK-F01.A2  a real v24 database (an older supported schema, with content)
//             migrates through the production connection, passes integrity
//             and foreign-key checks and the repository reads, and restores
//             its content and settings.
// CHK-F01.A3  a restore stopped at each step (process death) ends, at the
//             next start, in the checked new state with its settings; a
//             failed step (an I/O error) puts back the old database and the
//             old settings. Never a mixed pair.
// CHK-F01.A4  (data part) one newest safety copy; older ones are removed
//             only after a completed restore, never by a refusal.
// CHK-F01.A5  (data part) the outcome is recorded once and cleared; a
//             refusal says unchanged, an interrupted one says completed.

import 'dart:io';
import 'dart:typed_data';

import 'package:astroplan/core/config/app_identity.dart';
import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/backup/backup_archive.dart';
import 'package:astroplan/data/backup/backup_staging.dart';
import 'package:astroplan/data/backup/file_backup_service.dart';
import 'package:astroplan/data/backup/restore_candidate.dart';
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/database/generated_migrations/schema.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/domain/models/session_result.dart';
import 'package:astroplan/domain/services/backup_service.dart';
import 'package:drift/drift.dart'
    show GeneratedDatabase, MigrationStrategy, TableInfo;
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

final _clock = FixedClock(DateTime.utc(2026, 12, 16, 8));

/// Process death at a step: not an [Exception], so the restore does not
/// handle it, exactly as if the app had been killed there.
class _Killed extends Error {}

/// A database with no tables of its own, for writing files outside the
/// app's schema: SQL runs as written and `user_version` becomes [version].
class _Raw extends GeneratedDatabase {
  _Raw(super.e, this.version);

  final int version;

  @override
  int get schemaVersion => version;

  @override
  Iterable<TableInfo> get allTables => const [];

  @override
  MigrationStrategy get migration =>
      MigrationStrategy(onCreate: (_) async {}, onUpgrade: (_, _, _) async {});
}

/// Runs [sql] on the file [file] and stamps it at [version].
Future<void> _rawEdit(File file, int version, List<String> sql) async {
  final db = _Raw(NativeDatabase(file), version);
  await db.customSelect('SELECT 1').get(); // opens: stamps the version
  for (final statement in sql) {
    await db.customStatement(statement);
  }
  await db.close();
}

/// A carried planning preference (a double).
const _frameKey = 'perFrameOverheadSeconds';

/// The device's settings before any restore.
const _deviceSettings = <String, Object>{
  'activeLocationId': 7,
  'editedSessionId': 5,
  _frameKey: 4.0,
};

/// The settings the backup carries ([BackupPreferences] format).
Map<String, Object?> _backupSettings() => {
  'version': 1,
  'bool': <String, bool>{},
  'int': <String, int>{'activeLocationId': 1},
  'double': <String, double>{_frameKey: 9.0},
};

Future<Map<String, Object?>> _settingsNow() async {
  final prefs = await SharedPreferences.getInstance();
  return {for (final k in prefs.getKeys()) k: prefs.get(k)};
}

/// A real database file at the current schema with one site and one
/// named plan; its bytes, as a backup carries them.
Future<Uint8List> _currentDatabase(Directory dir, String siteName) async {
  final file = File(p.join(dir.path, 'source-$siteName.sqlite'));
  final db = AppDatabase(NativeDatabase(file));
  await db.customStatement(
    "INSERT INTO location_profiles (id, name, latitude, longitude, "
    "elevation, time_zone) VALUES (1, '$siteName', 46.05, 14.51, 300, "
    "'Europe/Ljubljana');",
  );
  await db.customStatement(
    "INSERT INTO session_logs (id, target_name, equipment_name, "
    "session_date, planned_light_frames, status, legacy, evening_date, "
    "name) VALUES (1, 'M42', 'Rig', 1790000000, 10, 'planned', 0, "
    "'2026-12-15', 'Orion from $siteName');",
  );
  await db.close();
  final bytes = await file.readAsBytes();
  await file.delete();
  return bytes;
}

Uint8List _zip(Uint8List database, {int? headerVersion}) => BackupArchive.build(
  database: database,
  manifestJson: '{}',
  preferences: _backupSettings(),
  preview: BackupPreview(
    createdAtUtc: _clock.nowUtc(),
    schemaVersion: headerVersion ?? BackupArchive.sqliteUserVersion(database)!,
    appVersion: '1.0.0',
    sessionCount: 1,
  ),
);

/// The site names stored in the database file at [path].
Future<List<String>> _siteNames(String path) async {
  final db = AppDatabase(NativeDatabase(File(path)));
  final names = [
    for (final l in await DriftLocationRepository(db).getLocations()) l.name,
  ];
  await db.close();
  return names;
}

void main() {
  late Directory root;
  late Directory phone;
  late Directory tmp;
  late File live;

  setUp(() async {
    SharedPreferences.setMockInitialValues(Map.of(_deviceSettings));
    root = await Directory.systemTemp.createTemp('culmina_f01');
    phone = await Directory(p.join(root.path, 'phone')).create();
    tmp = await Directory(p.join(root.path, 'tmp')).create();
    live = File(p.join(phone.path, BackupStaging.database));
    await live.writeAsBytes(await _currentDatabase(tmp, 'Old site'));
  });
  tearDown(() => root.delete(recursive: true));

  FileBackupService service(Uint8List picked) => FileBackupService(
    AppDatabase(NativeDatabase.memory()),
    DriftSessionRepository(AppDatabase(NativeDatabase.memory()), clock: _clock),
    clock: _clock,
    dataDir: () async => phone,
    tempDir: () async => tmp,
    pickBytes: () async => picked,
    clearPicked: () async {},
    restartApp: () async {},
  );

  group(
    'CHK-F01.A1: unusable databases are refused before anything changes',
    () {
      late Map<String, Uint8List> unusable;

      setUp(() async {
        final good = await _currentDatabase(tmp, 'Backup site');
        // Cut after the header and the first pages: the header still says
        // version 25, the file is a SQLite file, its tables are gone.
        final truncated = Uint8List.sublistView(good, 0, good.length ~/ 2);
        // A real SQLite file stamped at the current version with no tables.
        final emptyFile = File(p.join(tmp.path, 'empty.sqlite'));
        await _rawEdit(emptyFile, 25, ['CREATE TABLE unrelated (x INTEGER);']);
        // A current database with one table's column removed.
        final partialFile = File(p.join(tmp.path, 'partial.sqlite'));
        await partialFile.writeAsBytes(good);
        await _rawEdit(partialFile, 25, [
          'ALTER TABLE session_logs DROP COLUMN name;',
        ]);
        unusable = {
          'truncated': truncated,
          'without the expected schema': await emptyFile.readAsBytes(),
          'missing a column': await partialFile.readAsBytes(),
        };
      });

      for (final kind in [
        'truncated',
        'without the expected schema',
        'missing a column',
      ]) {
        test('$kind: refused at pick time and on activation', () async {
          final liveBefore = await live.readAsBytes();
          final settingsBefore = await _settingsNow();
          final bytes = _zip(unusable[kind]!);

          // The header check alone would accept it (TD-106).
          expect(service(bytes).check(bytes).preview.schemaVersion, 25);
          await expectLater(
            service(bytes).pick(),
            throwsA(
              isA<BackupException>().having(
                (e) => e.problem,
                'problem',
                BackupProblem.unusable,
              ),
            ),
          );
          expect(await live.readAsBytes(), liveBefore);
          expect(await _settingsNow(), settingsBefore);
          expect(
            tmp.listSync().where((f) => f.path.contains('restore-check')),
            isEmpty,
            reason: 'the isolated check copy is deleted',
          );

          // Activation repeats the check: the same file staged directly (as
          // a restore interrupted before its check would leave it).
          await BackupStaging.stage(
            phone,
            unusable[kind]!,
            preferences: _backupSettings(),
          );
          final outcome = await BackupStaging.apply(
            phone,
            nowUtc: _clock.nowUtc(),
          );
          expect(outcome!.result, RestoreResult.refused);
          expect(outcome.problem, BackupProblem.unusable);
          expect(await live.readAsBytes(), liveBefore);
          expect(await _settingsNow(), settingsBefore);
          expect(await BackupStaging.isStaged(phone), isFalse);
          expect(
            File(p.join(phone.path, BackupStaging.stagedPreferences))
                .existsSync(),
            isFalse,
          );
        });
      }

      test(
        'a newer database is refused at pick time and on activation',
        () async {
          final liveBefore = await live.readAsBytes();
          final newerFile = File(p.join(tmp.path, 'newer.sqlite'));
          await newerFile.writeAsBytes(await _currentDatabase(tmp, 'Future'));
          await _rawEdit(newerFile, 26, const []);
          final bytes = await newerFile.readAsBytes();
          await expectLater(
            service(_zip(bytes)).pick(),
            throwsA(
              isA<BackupException>().having(
                (e) => e.problem,
                'problem',
                BackupProblem.newerSchema,
              ),
            ),
          );
          // A header that hides the newer database is refused too.
          await expectLater(
            service(_zip(bytes, headerVersion: 25)).pick(),
            throwsA(isA<BackupException>()),
          );
          await BackupStaging.stage(
            phone,
            bytes,
            preferences: _backupSettings(),
          );
          final outcome = await BackupStaging.apply(
            phone,
            nowUtc: _clock.nowUtc(),
          );
          expect(outcome!.problem, BackupProblem.newerSchema);
          expect(await live.readAsBytes(), liveBefore);
          expect(await _settingsNow(), _deviceSettings);
        },
      );
    },
  );

  test('CHK-F01.A2: a real v24 database migrates, checks and restores its '
      'content and settings', () async {
    final verifier = SchemaVerifier(GeneratedHelper());
    final schema = await verifier.schemaAt(24);
    schema.rawDatabase
      ..execute(
        "INSERT INTO location_profiles (id, name, latitude, longitude, "
        "elevation, time_zone) VALUES (3, 'Dark site', 45.5, 13.9, 650, "
        "'Europe/Ljubljana');",
      )
      ..execute(
        "INSERT INTO session_logs (id, target_name, equipment_name, "
        "session_date, planned_light_frames, status, legacy, evening_date, "
        "result_kind, not_done_reason) VALUES "
        "(1, 'M42', 'Rig', 1790000000, 10, 'abandoned', 0, '2026-12-15', "
        "NULL, 'clouds'), "
        "(2, 'M45', 'Old rig', 1690000000, 7, 'completed', 1, NULL, NULL, "
        "NULL), "
        "(3, 'M31', 'Rig', 1790100000, 20, 'completed', 0, '2026-12-16', "
        "'partly', NULL);",
      );
    final v24 = File(p.join(tmp.path, 'v24.sqlite'));
    schema.rawDatabase.execute("VACUUM INTO '${v24.path}';");
    final bytes = await v24.readAsBytes();
    expect(BackupArchive.sqliteUserVersion(bytes), 24);

    final picked = await service(_zip(bytes)).pick();
    expect(picked!.preview.schemaVersion, 24);
    await service(_zip(bytes)).restoreAndRestart(picked.file);
    final outcome = await BackupStaging.apply(phone, nowUtc: _clock.nowUtc());
    expect(outcome!.result, RestoreResult.applied);

    final db = AppDatabase(openDatabaseConnection(() async => live));
    expect(await refusedSchemaVersion(db), isNull);
    expect(
      await db
          .customSelect('PRAGMA user_version')
          .getSingle()
          .then((r) => r.data.values.single),
      25,
    );
    expect(await db.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
    expect(
      [
        for (final l in await DriftLocationRepository(db).getLocations())
          l.name,
      ],
      ['Dark site'],
    );
    final sessions = await DriftSessionRepository(db, clock: _clock).list();
    sessions.sort((a, b) => a.id.compareTo(b.id));
    expect(
      sessions.map(
        (s) => (s.record.targetName, s.legacy, s.resultKind, s.notDoneReason),
      ),
      [
        ('M42', false, null, NotDoneReason.clouds),
        ('M45', true, null, null),
        ('M31', false, ResultKind.partly, null),
      ],
    );
    expect(await DriftEquipmentRepository(db).getAllEquipment(), isEmpty);
    await db.close();
    final settings = await _settingsNow();
    expect(settings[_frameKey], 9.0);
    expect(settings['activeLocationId'], 1);
    expect(settings.containsKey('editedSessionId'), isFalse);
  });

  group('CHK-F01.A3: an interrupted activation ends in one coherent state', () {
    late Uint8List backup;
    late Uint8List liveBefore;

    setUp(() async {
      backup = await _currentDatabase(tmp, 'Backup site');
      liveBefore = await live.readAsBytes();
      // An old write-ahead log beside the live database.
      await File('${live.path}-wal').writeAsString('old wal');
    });

    Future<void> stage() =>
        BackupStaging.stage(phone, backup, preferences: _backupSettings());

    Future<void> expectNewState() async {
      expect(await _siteNames(live.path), ['Backup site']);
      final settings = await _settingsNow();
      expect(settings[_frameKey], 9.0);
      expect(settings['activeLocationId'], 1);
      expect(settings.containsKey('editedSessionId'), isFalse);
      expect(
        File('${live.path}-wal').existsSync(),
        isFalse,
        reason: 'the old log is never applied to the new database',
      );
      expect(
        File(p.join(phone.path, BackupStaging.journal)).existsSync(),
        isFalse,
      );
      expect(await BackupStaging.isStaged(phone), isFalse);
    }

    Future<void> expectOldState() async {
      expect(await live.readAsBytes(), liveBefore);
      expect(await File('${live.path}-wal').readAsString(), 'old wal');
      expect(await _settingsNow(), _deviceSettings);
      expect(
        File(p.join(phone.path, BackupStaging.journal)).existsSync(),
        isFalse,
      );
      expect(await BackupStaging.isStaged(phone), isFalse);
    }

    for (final step in [
      'journal',
      'moveLive',
      'moveSide',
      'swap',
      'preferences',
      'commit',
    ]) {
      test('killed at "$step": the next start completes the restore', () async {
        await stage();
        await expectLater(
          BackupStaging.apply(
            phone,
            nowUtc: _clock.nowUtc(),
            onStep: (s) async {
              if (s == step) throw _Killed();
            },
          ),
          throwsA(isA<_Killed>()),
        );
        final outcome = await BackupStaging.apply(
          phone,
          nowUtc: _clock.nowUtc(),
        );
        // Before the journal the restore had not started: it runs again
        // in full. After it, the next start completes it.
        expect(
          outcome!.result,
          step == 'journal'
              ? RestoreResult.applied
              : RestoreResult.completedAfterInterruption,
        );
        await expectNewState();
        // Applying again changes nothing: the outcome is all that is left.
        expect(
          await BackupStaging.apply(phone, nowUtc: _clock.nowUtc()),
          isNull,
        );
        await expectNewState();
      });
    }

    for (final step in ['moveLive', 'moveSide', 'swap', 'preferences']) {
      test(
        'a failed "$step" puts back the old database and settings',
        () async {
          await stage();
          final outcome = await BackupStaging.apply(
            phone,
            nowUtc: _clock.nowUtc(),
            onStep: (s) async {
              if (s == step) throw const FileSystemException('disk full');
            },
          );
          expect(outcome!.result, RestoreResult.refused);
          expect(outcome.problem, BackupProblem.notApplied);
          await expectOldState();
        },
      );
    }

    test(
      'a failed settings write half way is rolled back as a whole',
      () async {
        await stage();
        final outcome = await BackupStaging.apply(
          phone,
          nowUtc: _clock.nowUtc(),
          restorePreferences: (carried) async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setDouble(_frameKey, 9.0);
            throw const FileSystemException('settings not written');
          },
        );
        expect(outcome!.problem, BackupProblem.notApplied);
        await expectOldState();
      },
    );
  });

  group('CHK-F01.A4 (D2 A): one newest safety copy', () {
    List<String> safetyCopies() => [
      for (final f in phone.listSync().whereType<File>())
        if (p.basename(f.path).contains('.before-restore-')) p.basename(f.path),
    ]..sort();

    test(
      'older copies go after a completed restore, never the new one',
      () async {
        // Two copies left by earlier restores (the pre-F01 names included).
        await File('${live.path}.before-restore-2026-01-01.bak')
            .writeAsString('older');
        await File('${live.path}-wal.before-restore-2026-01-01.bak')
            .writeAsString('older wal');
        final backup = await _currentDatabase(tmp, 'Backup site');

        // A refused restore removes no safety copy.
        await BackupStaging.stage(phone, Uint8List.fromList([1, 2, 3]));
        await BackupStaging.apply(phone, nowUtc: _clock.nowUtc());
        expect(safetyCopies(), hasLength(2));

        await BackupStaging.stage(phone, backup);
        await BackupStaging.apply(phone, nowUtc: _clock.nowUtc());
        final copies = safetyCopies();
        expect(copies, hasLength(1));
        expect(await _siteNames(p.join(phone.path, copies.single)), [
          'Old site',
        ], reason: 'the one copy is the database just replaced');

        // The next restore keeps only its own copy: the backup just applied.
        await BackupStaging.stage(
          phone,
          await _currentDatabase(tmp, 'Third site'),
        );
        await BackupStaging.apply(
          phone,
          nowUtc: _clock.nowUtc().add(const Duration(minutes: 1)),
        );
        final next = safetyCopies();
        expect(next, hasLength(1));
        expect(await _siteNames(p.join(phone.path, next.single)), [
          'Backup site',
        ]);
      },
    );

    test(
      'an interrupted restore keeps its pending copy until it completes',
      () async {
        await BackupStaging.stage(
          phone,
          await _currentDatabase(tmp, 'Backup site'),
        );
        await expectLater(
          BackupStaging.apply(
            phone,
            nowUtc: _clock.nowUtc(),
            onStep: (s) async {
              if (s == 'swap') throw _Killed();
            },
          ),
          throwsA(isA<_Killed>()),
        );
        expect(safetyCopies(), hasLength(1));
        expect(live.existsSync(), isFalse);
        await BackupStaging.apply(phone, nowUtc: _clock.nowUtc());
        expect(safetyCopies(), hasLength(1));
        expect(await _siteNames(live.path), ['Backup site']);
      },
    );
  });

  group('CHK-F01.A5 (data part): the outcome is kept until reported', () {
    test('applied, then cleared once reported', () async {
      final s = service(Uint8List(0));
      expect(await s.outcome(), isNull);
      await BackupStaging.stage(phone, await _currentDatabase(tmp, 'B'));
      await BackupStaging.apply(phone, nowUtc: _clock.nowUtc());
      expect((await s.outcome())!.result, RestoreResult.applied);
      await s.clearOutcome();
      expect(await s.outcome(), isNull);
      expect(
        await BackupStaging.apply(phone, nowUtc: _clock.nowUtc()),
        isNull,
        reason: 'nothing staged: no new outcome',
      );
      expect(await s.outcome(), isNull);
    });

    test(
      'a refusal on activation is recorded as refused, with its reason',
      () async {
        await BackupStaging.stage(phone, Uint8List.fromList([1, 2, 3]));
        await BackupStaging.apply(phone, nowUtc: _clock.nowUtc());
        final o = await service(Uint8List(0)).outcome();
        expect(o!.result, RestoreResult.refused);
        expect(o.problem, BackupProblem.unusable);
      },
    );

    test('restoreAndRestart stages and restarts; a staging failure stages '
        'nothing and does not restart', () async {
      final bytes = _zip(await _currentDatabase(tmp, 'Backup site'));
      var restarts = 0;
      FileBackupService withRestart(Directory dir) => FileBackupService(
        AppDatabase(NativeDatabase.memory()),
        DriftSessionRepository(
          AppDatabase(NativeDatabase.memory()),
          clock: _clock,
        ),
        clock: _clock,
        dataDir: () async => dir,
        tempDir: () async => tmp,
        pickBytes: () async => bytes,
        clearPicked: () async {},
        restartApp: () async => restarts++,
      );
      final ok = withRestart(phone);
      await ok.restoreAndRestart((await ok.pick())!.file);
      expect(restarts, 1);
      expect(await BackupStaging.isStaged(phone), isTrue);
      await BackupStaging.cancel(phone);

      final gone = Directory(p.join(root.path, 'missing'));
      final failing = withRestart(gone);
      await expectLater(
        failing.restoreAndRestart((await failing.pick())!.file),
        throwsA(isA<FileSystemException>()),
      );
      expect(restarts, 1);
      expect(await live.readAsBytes(), isNotEmpty);
      expect(await _siteNames(live.path), ['Old site']);
    });
  });

  test('the candidate check touches only its own file', () async {
    final copy = File(p.join(tmp.path, 'copy.sqlite'));
    await copy.writeAsBytes(await _currentDatabase(tmp, 'Copy'));
    final before = await live.readAsBytes();
    await checkRestoreCandidate(copy);
    expect(await live.readAsBytes(), before);
    expect(AppIdentity.appName, isNotEmpty);
  });
}
