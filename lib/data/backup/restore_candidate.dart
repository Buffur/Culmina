import 'dart:io';

import '../../core/diagnostics/app_log.dart';
import '../../domain/services/backup_service.dart';
import '../database/app_database.dart';
import '../repositories/drift_equipment_repository.dart';
import '../repositories/drift_location_repository.dart';
import '../repositories/drift_session_repository.dart';
import '../repositories/drift_target_repository.dart';

/// Checks that a restore candidate is a database this app can actually use
/// (F01 A1/A2, TD-106): the file is opened through the app's own production
/// connection ([openDatabaseConnection]: lazy, on a background isolate), so
/// an older supported schema is migrated exactly as the live database would
/// be; then SQLite's integrity and foreign-key checks run, every expected
/// table and column must exist, and the repositories must read every row.
///
/// Throws [BackupException] when the candidate cannot become the live
/// database: [BackupProblem.newerSchema] or [BackupProblem.tooOld] for a
/// version this app refuses, [BackupProblem.unusable] for a damaged,
/// truncated or incomplete one. [file] is the only file touched (it may be
/// migrated in place, with SQLite's own side files); the live database never
/// is. The caller owns [file] and decides whether it is kept.
Future<void> checkRestoreCandidate(File file) async {
  final database = AppDatabase(openDatabaseConnection(() async => file));
  try {
    final UnsupportedSchemaVersionException? refused;
    try {
      refused = await refusedSchemaVersion(database);
    } catch (e) {
      AppLog.warning('backup', 'Restore candidate did not open', error: e);
      throw const BackupException(BackupProblem.unusable);
    }
    if (refused != null) {
      throw BackupException(
        refused.isNewerThanApp
            ? BackupProblem.newerSchema
            : BackupProblem.tooOld,
      );
    }
    try {
      await _checkContents(database);
    } on BackupException {
      rethrow;
    } catch (e) {
      AppLog.warning('backup', 'Restore candidate unreadable', error: e);
      throw const BackupException(BackupProblem.unusable);
    }
  } finally {
    try {
      await database.close();
    } catch (e) {
      AppLog.warning('backup', 'Restore candidate not closed', error: e);
    }
  }
}

Future<void> _checkContents(AppDatabase database) async {
  final integrity = await database
      .customSelect('PRAGMA integrity_check;')
      .get();
  final verdict = [for (final r in integrity) r.data.values.first.toString()];
  if (verdict.length != 1 || verdict.single != 'ok') {
    AppLog.warning('backup', 'Restore candidate integrity: $verdict');
    throw const BackupException(BackupProblem.unusable);
  }
  final orphans = await database
      .customSelect('PRAGMA foreign_key_check;')
      .get();
  if (orphans.isNotEmpty) {
    AppLog.warning(
      'backup',
      'Restore candidate has ${orphans.length} dangling reference(s)',
    );
    throw const BackupException(BackupProblem.unusable);
  }
  // Every table and column this build reads must be there: a database that
  // only *says* it is at the current version is not one (CHK-F01.A1).
  for (final table in database.allTables) {
    final columns = {
      for (final row
          in await database
              .customSelect('PRAGMA table_info("${table.actualTableName}");')
              .get())
        row.read<String>('name'),
    };
    final missing = [
      for (final c in table.$columns)
        if (!columns.contains(c.name)) c.name,
    ];
    if (missing.isNotEmpty) {
      AppLog.warning(
        'backup',
        'Restore candidate lacks ${table.actualTableName}: $missing',
      );
      throw const BackupException(BackupProblem.unusable);
    }
    // Every row maps to the generated row class (types and NOT NULLs).
    await database.select(table).get();
  }
  // The reads the app itself starts with.
  await DriftLocationRepository(database).getLocations();
  await DriftEquipmentRepository(database).getAllEquipment();
  await DriftTargetRepository(database).getAllTargets();
  final sessions = DriftSessionRepository(database);
  for (final s in await sessions.list()) {
    if (!s.legacy) await sessions.events(s.id);
  }
}
