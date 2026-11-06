// Narrow Android contract: real SQLite/WAL, filesystem and preference plugin.
// Run only in the .verification install (ORG_GRADLE_PROJECT_CULMINA_VERIFICATION=true).
import 'dart:io';
import 'dart:typed_data';

import 'package:astroplan/data/backup/backup_preferences.dart';
import 'package:astroplan/data/backup/backup_staging.dart';
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/domain/services/backup_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Killed extends Error {}

Future<AppDatabase> _database(File file, String site) async {
  final db = AppDatabase(NativeDatabase(file));
  await db.customStatement(
    "INSERT INTO location_profiles (id, name, latitude, longitude) "
    "VALUES (1, '$site', 45, 14)",
  );
  return db;
}

Future<String> _site(File file) async {
  final db = AppDatabase(openDatabaseConnection(() async => file));
  try {
    expect(
      await db
          .customSelect('PRAGMA integrity_check')
          .getSingle()
          .then((r) => r.data.values.single),
      'ok',
    );
    return await db
        .customSelect('SELECT name FROM location_profiles')
        .getSingle()
        .then((r) => r.read<String>('name'));
  } finally {
    await db.close();
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final recoveryStampUtc = DateTime.utc(2026, 11, 6);
  for (final mode in ['commitCleanup', 'resumeSwap', 'resumeRollback']) {
    testWidgets('native restore safety: $mode', (tester) async {
      expect(
        const bool.fromEnvironment('CULMINA_ISOLATED_VERIFY'),
        isTrue,
        reason: 'Use the isolated verification build, never a normal install.',
      );
      await tester.runAsync(() async {
        final documents = await getApplicationDocumentsDirectory();
        expect(
          documents.path,
          contains('/io.github.buffur.culmina.verification/'),
          reason: 'The native sandbox must belong to the verification install.',
        );
        final dir = await documents.createTemp('restore-safety');
        final before = await BackupPreferences.snapshot();
        final prefs = await SharedPreferences.getInstance();
        try {
          await prefs.setInt('activeLocationId', 7);
          final source = File('${dir.path}/old.sqlite');
          final old = await _database(source, 'Old site');
          final live = File('${dir.path}/${BackupStaging.database}');
          try {
            await old.customSelect('PRAGMA journal_mode=WAL').get();
            await old.customStatement('PRAGMA wal_autocheckpoint=0');
            await old.customStatement(
              "UPDATE location_profiles SET name='WAL site'",
            );
            await source.copy(live.path);
            final wal = File('${source.path}-wal');
            expect(await wal.length(), greaterThan(0));
            await wal.copy('${live.path}-wal');
          } finally {
            await old.close();
          }
          final candidate = File('${dir.path}/backup.sqlite');
          final next = await _database(candidate, 'Backup site');
          await next.close();
          final Uint8List bytes = await candidate.readAsBytes();
          await BackupStaging.stage(
            dir,
            bytes,
            preferences: BackupPreferences.parse({
              'version': 1,
              'int': {'activeLocationId': 1},
            }),
          );
          final killedStep = switch (mode) {
            'commitCleanup' => 'cleanupJournal',
            'resumeSwap' => 'moveSide',
            _ => 'rollbackSide',
          };
          await expectLater(
            BackupStaging.apply(
              dir,
              nowUtc: recoveryStampUtc,
              onStep: (step) async {
                if (mode == 'resumeRollback' && step == 'preferences') {
                  throw const FileSystemException(
                    'injected preference failure',
                  );
                }
                if (step == killedStep) throw _Killed();
              },
            ),
            throwsA(isA<_Killed>()),
          );
          final outcome = await BackupStaging.apply(
            dir,
            nowUtc: recoveryStampUtc,
          );
          await prefs.reload(); // read through the native plugin, not just its Dart cache
          if (mode == 'resumeRollback') {
            expect(outcome!.result, RestoreResult.refused);
            expect(await _site(live), 'WAL site');
            expect(prefs.getInt('activeLocationId'), 7);
          } else {
            expect(outcome!.result, RestoreResult.completedAfterInterruption);
            expect(await _site(live), 'Backup site');
            expect(prefs.getInt('activeLocationId'), 1);
          }
          expect(
            await File('${dir.path}/${BackupStaging.journal}').exists(),
            isFalse,
          );
          expect(
            await BackupStaging.apply(dir, nowUtc: recoveryStampUtc),
            isNull,
          );
        } finally {
          await BackupPreferences.putBack(before);
          await dir.delete(recursive: true);
        }
      });
    }, skip: !Platform.isAndroid);
  }
}
