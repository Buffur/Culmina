import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

import '../../core/diagnostics/app_log.dart';
import '../../domain/services/backup_service.dart';
import 'backup_preferences.dart';
import 'restore_candidate.dart';

/// A confirmed restore being applied (TASK 14.4; F01, owner decisions D2
/// and D7). The checked database is staged next to the live one; the app
/// then restarts at once and [apply] replaces the live database before it
/// opens. Since S8.9 the backup's settings come with it (TD-056, ENG-14).
///
/// [apply] checks the staged database again through the app's production
/// connection ([checkRestoreCandidate]) before anything live changes, then
/// follows a journal so that an interruption at any step ends in one
/// coherent state at the next start: the old database with the old
/// settings, or the checked new database with the backup's settings (F01
/// A3). The replaced database is kept as one safety copy; older safety
/// copies are removed only after a restore has completed (D2 A).
abstract final class BackupStaging {
  static const database = 'astroplan.sqlite';
  static const staged = 'astroplan.restore.sqlite';
  static const stagedPreferences = 'astroplan.restore.preferences.json';
  static const journal = 'astroplan.restore.journal.json';
  static const outcomeFile = 'astroplan.restore.outcome.json';

  /// The suffix of a replaced database kept as the safety copy.
  static const _safetyMark = '.before-restore-';

  /// SQLite's side files, which belong to one database file only.
  static const _sideSuffixes = ['-wal', '-shm', '-journal'];

  static File _file(Directory dir, String name) => File(p.join(dir.path, name));

  /// Stages [databaseBytes] and the settings the backup carries
  /// ([BackupPreferences.parse]d; null for a version 1 archive).
  static Future<void> stage(
    Directory dir,
    Uint8List databaseBytes, {
    Map<String, Object?>? preferences,
  }) async {
    final settings = _file(dir, stagedPreferences);
    if (preferences == null) {
      if (await settings.exists()) await settings.delete();
    } else {
      await settings.writeAsString(jsonEncode(preferences), flush: true);
    }
    final target = _file(dir, staged);
    final tmp = File('${target.path}.part');
    await tmp.writeAsBytes(databaseBytes, flush: true);
    await tmp.rename(target.path); // appears only when complete
  }

  static Future<bool> isStaged(Directory dir) => _file(dir, staged).exists();

  /// Removes a staged restore and its settings (a refused or abandoned
  /// one); the live database is not touched.
  static Future<void> cancel(Directory dir) async {
    for (final name in [
      staged,
      '$staged.part',
      stagedPreferences,
      for (final s in _sideSuffixes) '$staged$s',
    ]) {
      final f = _file(dir, name);
      if (await f.exists()) await f.delete();
    }
  }

  /// Applies a staged restore, or completes an interrupted one; call before
  /// opening the database. Returns what happened (also kept for
  /// [readOutcome]), or null when there was nothing to do.
  ///
  /// [check] is the candidate check ([checkRestoreCandidate] by default);
  /// [restorePreferences], [snapshotPreferences] and [putBackPreferences]
  /// write this device's settings ([BackupPreferences] by default). [onStep]
  /// is called before each step that changes a file or a setting, by name;
  /// tests use it to stop the restore there.
  static Future<RestoreOutcome?> apply(
    Directory dir, {
    required DateTime nowUtc,
    Future<void> Function(File candidate) check = checkRestoreCandidate,
    Future<void> Function(Map<String, Object?>? preferences)
        restorePreferences =
        BackupPreferences.restore,
    Future<Map<String, Object?>> Function() snapshotPreferences =
        BackupPreferences.snapshot,
    Future<void> Function(Map<String, Object?> snapshot) putBackPreferences =
        BackupPreferences.putBack,
    Future<void> Function(String step)? onStep,
  }) async {
    final step = onStep ?? (_) async {};
    final journalFile = _file(dir, journal);
    final live = _file(dir, database);
    final next = _file(dir, staged);
    Map<String, Object?>? started = await _readJson(journalFile);

    if (started == null) {
      final part = File('${next.path}.part');
      if (await part.exists()) await part.delete(); // never completed
      if (!await next.exists()) return null;
      // Activation repeats the pick-time check, on the staged file itself,
      // before anything live changes (F01 A1).
      try {
        await check(next);
      } on BackupException catch (e) {
        await cancel(dir);
        return _report(
          dir,
          RestoreOutcome(RestoreResult.refused, problem: e.problem),
        );
      } catch (e, s) {
        AppLog.error('backup', 'Restore check failed', error: e, stackTrace: s);
        await cancel(dir);
        return _report(
          dir,
          const RestoreOutcome(
            RestoreResult.refused,
            problem: BackupProblem.unusable,
          ),
        );
      }
      started = {
        'stamp': nowUtc.toIso8601String().replaceAll(RegExp('[:.]'), '-'),
        'previous_preferences': await snapshotPreferences(),
      };
      await step('journal');
      await _writeJson(journalFile, started);
      return _swap(
        dir,
        started,
        interrupted: false,
        restorePreferences: restorePreferences,
        putBackPreferences: putBackPreferences,
        step: step,
      );
    }
    // A journal: the last start stopped in the middle of a checked
    // restore. Finish it; the candidate was checked before the journal
    // was written.
    AppLog.warning('backup', 'Completing an interrupted restore');
    if (!await next.exists() && !await live.exists()) {
      // Nothing to finish with (an outside deletion): put the safety copy
      // back rather than start with no data.
      return _rollBack(dir, started, putBackPreferences, 'no database left');
    }
    return _swap(
      dir,
      started,
      interrupted: true,
      restorePreferences: restorePreferences,
      putBackPreferences: putBackPreferences,
      step: step,
    );
  }

  static Future<RestoreOutcome> _swap(
    Directory dir,
    Map<String, Object?> started, {
    required bool interrupted,
    required Future<void> Function(Map<String, Object?>?) restorePreferences,
    required Future<void> Function(Map<String, Object?>) putBackPreferences,
    required Future<void> Function(String) step,
  }) async {
    final live = _file(dir, database);
    final next = _file(dir, staged);
    final safety = _safety(dir, started['stamp']! as String);
    try {
      if (await next.exists()) {
        // The live database (if any) and its side files become the one
        // safety copy; a write-ahead log of the old database must never be
        // applied to the new one.
        if (await live.exists()) {
          await step('moveLive');
          await live.rename(safety.path);
        }
        for (final suffix in _sideSuffixes) {
          final side = File('${live.path}$suffix');
          if (await side.exists()) {
            await step('moveSide');
            await side.rename('${safety.path}$suffix');
          }
        }
        await step('swap');
        await next.rename(live.path);
      }
      await step('preferences');
      await restorePreferences(await _readStagedPreferences(dir));
    } on Exception catch (e, s) {
      AppLog.error('backup', 'Restore not applied', error: e, stackTrace: s);
      return _rollBack(dir, started, putBackPreferences, e);
    }
    await step('commit');
    final outcome = RestoreOutcome(
      interrupted
          ? RestoreResult.completedAfterInterruption
          : RestoreResult.applied,
    );
    await _writeOutcome(dir, outcome);
    await _deleteIfExists(_file(dir, stagedPreferences));
    await _deleteIfExists(_file(dir, journal));
    await _pruneSafetyCopies(dir, keep: safety);
    return outcome;
  }

  /// Puts the live database and settings back as they were before the
  /// journal was written; the restore is reported as not applied. If even
  /// that fails, the journal stays for the next start.
  static Future<RestoreOutcome> _rollBack(
    Directory dir,
    Map<String, Object?> started,
    Future<void> Function(Map<String, Object?>) putBackPreferences,
    Object reason,
  ) async {
    final live = _file(dir, database);
    final next = _file(dir, staged);
    final safety = _safety(dir, started['stamp']! as String);
    final rolledBack = _file(dir, '$staged.rolled-back');
    if (await safety.exists()) {
      if (await live.exists()) {
        // The new database already moved in: it goes back out so the
        // safety copy can return.
        await live.rename(rolledBack.path);
      }
      await safety.rename(live.path);
      for (final suffix in _sideSuffixes) {
        final side = File('${safety.path}$suffix');
        if (await side.exists()) await side.rename('${live.path}$suffix');
      }
    } else if (!await next.exists() && await live.exists()) {
      // There was no database before (a new install): the new one moved
      // in, so the old state is no database at all.
      await live.rename(rolledBack.path);
    }
    final previous = started['previous_preferences'];
    if (previous is Map) {
      await putBackPreferences(Map<String, Object?>.from(previous));
    }
    await cancel(dir);
    await _deleteIfExists(rolledBack);
    final outcome = const RestoreOutcome(
      RestoreResult.refused,
      problem: BackupProblem.notApplied,
    );
    AppLog.warning('backup', 'Restore rolled back: $reason');
    await _writeOutcome(dir, outcome);
    await _deleteIfExists(_file(dir, journal));
    return outcome;
  }

  static File _safety(Directory dir, String stamp) =>
      _file(dir, '$database$_safetyMark$stamp.bak');

  /// D2 A: one safety copy, the newest. Older ones (and their side files)
  /// go only after a restore has completed; [keep] is never removed.
  static Future<void> _pruneSafetyCopies(
    Directory dir, {
    required File keep,
  }) async {
    // Before F01 a side file was kept as `<side>.before-restore-…`.
    final prefixes = [
      for (final side in ['', ..._sideSuffixes]) '$database$side$_safetyMark',
    ];
    final keepName = p.basename(keep.path);
    await for (final entity in dir.list()) {
      if (entity is! File) continue;
      final name = p.basename(entity.path);
      if (!prefixes.any(name.startsWith) || name.startsWith(keepName)) {
        continue;
      }
      try {
        await entity.delete();
      } on FileSystemException catch (e) {
        AppLog.warning('backup', 'Old safety copy not removed', error: e);
      }
    }
  }

  /// The outcome of the last restore, until [clearOutcome].
  static Future<RestoreOutcome?> readOutcome(Directory dir) async {
    final json = await _readJson(_file(dir, outcomeFile));
    if (json == null) return null;
    final result = RestoreResult.values.asNameMap()[json['result']];
    if (result == null) return null;
    return RestoreOutcome(
      result,
      problem: BackupProblem.values.asNameMap()[json['problem']],
    );
  }

  static Future<void> clearOutcome(Directory dir) =>
      _deleteIfExists(_file(dir, outcomeFile));

  static Future<RestoreOutcome> _report(
    Directory dir,
    RestoreOutcome outcome,
  ) async {
    await _writeOutcome(dir, outcome);
    return outcome;
  }

  static Future<void> _writeOutcome(Directory dir, RestoreOutcome o) =>
      _writeJson(_file(dir, outcomeFile), {
        'result': o.result.name,
        if (o.problem != null) 'problem': o.problem!.name,
      });

  /// Written whole, then renamed into place: a reader sees the old or the
  /// new file, never part of one.
  static Future<void> _writeJson(File file, Map<String, Object?> json) async {
    final tmp = File('${file.path}.part');
    await tmp.writeAsString(jsonEncode(json), flush: true);
    await tmp.rename(file.path);
  }

  static Future<Map<String, Object?>?> _readJson(File file) async {
    if (!await file.exists()) return null;
    try {
      final json = jsonDecode(await file.readAsString());
      return json is Map ? Map<String, Object?>.from(json) : null;
    } on FormatException catch (e) {
      AppLog.warning('backup', '${p.basename(file.path)} unreadable', error: e);
      return null;
    }
  }

  static Future<void> _deleteIfExists(File file) async {
    if (await file.exists()) await file.delete();
  }

  /// The staged settings; null when none were staged, or (logged) when
  /// they cannot be read: the restore then keeps the device's settings
  /// and still clears its stale ids, as for a version 1 archive.
  static Future<Map<String, Object?>?> _readStagedPreferences(
    Directory dir,
  ) async {
    final settings = _file(dir, stagedPreferences);
    if (!await settings.exists()) return null;
    try {
      return BackupPreferences.parse(jsonDecode(await settings.readAsString()));
    } on FormatException catch (e) {
      AppLog.warning('backup', 'Staged settings unreadable', error: e);
      return null;
    }
  }
}
