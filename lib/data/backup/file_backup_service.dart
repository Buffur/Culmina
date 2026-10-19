import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/config/app_identity.dart';
import '../../core/diagnostics/app_log.dart';
import '../../core/time/clock.dart';
import '../../domain/repositories/session_repository.dart';
import '../../domain/services/backup_service.dart';
import '../../domain/services/session_exporter.dart';
import '../database/app_database.dart';
import '../export/session_manifest_codec.dart';
import '../export/share_session_exporter.dart';
import 'backup_archive.dart';
import 'backup_preferences.dart';
import 'backup_staging.dart';
import 'restore_candidate.dart';

/// [BackupService] on the app's database file (TASK 14.4): `VACUUM INTO`
/// gives a consistent copy while the app runs; the share sheet saves it
/// where the user chooses; file_picker opens one for a restore.
class FileBackupService implements BackupService {
  FileBackupService(
    this._db,
    this._sessions, {
    this._clock = const SystemClock(),
    Future<Directory> Function()? dataDir,
    Future<Directory> Function()? tempDir,
    Future<Uint8List?> Function()? pickBytes,
    Future<void> Function()? clearPicked,
    Future<Map<String, Object?>> Function()? readPreferences,
    Future<void> Function(File candidate)? checkCandidate,
    this._restartApp,
  }) : _readPreferences = readPreferences ?? BackupPreferences.read,
       _checkCandidate = checkCandidate ?? checkRestoreCandidate,
       _dataDir = dataDir ?? getApplicationDocumentsDirectory,
       _tempDir = tempDir ?? getTemporaryDirectory,
       _pickBytes = pickBytes ?? _pickWithFilePicker,
       _clearPicked = clearPicked ?? FilePicker.clearTemporaryFiles;

  final AppDatabase _db;
  final SessionRepository _sessions;
  final Clock _clock;
  final Future<Directory> Function() _dataDir;
  final Future<Directory> Function() _tempDir;

  /// The settings a backup carries (S8.9, [BackupPreferences]).
  final Future<Map<String, Object?>> Function() _readPreferences;

  /// The picked backup's bytes, or null when cancelled.
  final Future<Uint8List?> Function() _pickBytes;

  /// Deletes the picker's copies of picked files (TD-065).
  final Future<void> Function() _clearPicked;

  /// The full candidate check ([checkRestoreCandidate]).
  final Future<void> Function(File candidate) _checkCandidate;

  /// Restarts the app so the staged restore is applied before the database
  /// opens again (`main.dart`); null in tests that stage only.
  final Future<void> Function()? _restartApp;

  static Future<Uint8List?> _pickWithFilePicker() async {
    final picked = await FilePicker.pickFiles(
      dialogTitle: '${AppIdentity.appName} backup',
    );
    if (picked.isEmpty) return null;
    return picked.first.xFile.readAsBytes();
  }

  /// The backup file's bytes (the testable part of [backUpAndShare]).
  Future<Uint8List> createBackup() async {
    final now = _clock.nowUtc();
    final tmp = await _tempDir();
    final copy = File(
      p.join(tmp.path, 'backup-${now.millisecondsSinceEpoch}.sqlite'),
    );
    if (await copy.exists()) await copy.delete();
    // A consistent snapshot of the live database, WAL included.
    await _db.customStatement('VACUUM INTO ?', [copy.path]);
    final database = await copy.readAsBytes();
    await copy.delete();
    final all = await _sessions.list();
    final exported = [
      for (final s in all)
        ExportedSession(s, s.legacy ? const [] : await _sessions.events(s.id)),
    ];
    return BackupArchive.build(
      database: database,
      manifestJson: jsonEncode(
        SessionManifestCodec.encode(
          exported,
          exportedAtUtc: now,
          appVersion: AppIdentity.version,
        ),
      ),
      preferences: await _readPreferences(),
      preview: BackupPreview(
        createdAtUtc: now,
        schemaVersion: _db.schemaVersion,
        appVersion: AppIdentity.version,
        sessionCount: all.length,
      ),
    );
  }

  @override
  Future<bool> backUpAndShare() async {
    final bytes = await createBackup();
    final now = _clock.nowUtc();
    final file = File(p.join((await _tempDir()).path, fileName(now)));
    await file.writeAsBytes(bytes, flush: true);
    final result = await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/zip')],
        text: shareText(now),
      ),
    );
    // Dismissed: nothing kept the file. "Unavailable" (a platform that
    // cannot tell) still opened the sheet with the file, so it counts.
    return result.status != ShareResultStatus.dismissed;
  }

  /// The backup's file name in the device's local date and time (S9.8):
  /// `astroplan-backup-2026-09-29-2130.astroplan`.
  static String fileName(DateTime nowUtc) =>
      'astroplan-backup-${ShareSessionExporter.localFileStamp(nowUtc)}.astroplan';

  /// The share sheet's text, with the local time and its offset (S9.8).
  static String shareText(DateTime nowUtc) =>
      '${AppIdentity.appName} backup, '
      '${ShareSessionExporter.localStampWithOffset(nowUtc)}. Keep this file '
      'to restore.';

  /// Checks backup [bytes]' archive and header against this app.
  CheckedBackup check(Uint8List bytes) => BackupArchive.read(
    bytes,
    appSchemaVersion: _db.schemaVersion,
    minSchemaVersion: kMinSupportedSchemaVersion,
  );

  /// The complete pick-time check (F01 A1, UXA-C1): the archive, then its
  /// database on an isolated copy in the temporary folder, opened through
  /// the app's production connection. The copy is always deleted; nothing
  /// else is touched. Throws [BackupException].
  Future<CheckedBackup> checkFully(Uint8List bytes) async {
    final checked = check(bytes);
    final dir = await _tempDir();
    final copy = File(
      p.join(
        dir.path,
        'restore-check-${_clock.nowUtc().microsecondsSinceEpoch}.sqlite',
      ),
    );
    try {
      await copy.writeAsBytes(checked.database, flush: true);
      await _checkCandidate(copy);
    } finally {
      for (final f in [
        copy,
        for (final s in ['-wal', '-shm', '-journal']) File('${copy.path}$s'),
      ]) {
        try {
          if (await f.exists()) await f.delete();
        } on FileSystemException catch (e) {
          AppLog.warning('backup', 'Check copy not deleted', error: e);
        }
      }
    }
    return checked;
  }

  @override
  Future<({BackupPreview preview, Object file})?> pick() async {
    try {
      final bytes = await _pickBytes();
      if (bytes == null) return null;
      final checked = await checkFully(bytes);
      return (preview: checked.preview, file: checked);
    } finally {
      // TD-065 (ADR-017 §6): on Android the picker copies the whole file
      // into the app's cache. This flow owns that copy and deletes it once
      // the pick is consumed, cancelled or refused.
      try {
        await _clearPicked();
      } catch (e) {
        AppLog.warning('backup', 'Picked-file copies not cleared', error: e);
      }
    }
  }

  /// Stages a picked, checked backup next to the live database. At the
  /// next start (at once, through [restoreAndRestart]) [BackupStaging.apply]
  /// checks it again and replaces the live data.
  Future<void> stage(Object file) async {
    final checked = file as CheckedBackup;
    await BackupStaging.stage(
      await _dataDir(),
      checked.database,
      preferences: checked.preferences,
    );
  }

  /// D7 A: no editable gap. A failure to stage removes what was written and
  /// is reported where the user confirmed; nothing live has changed.
  @override
  Future<void> restoreAndRestart(Object file) async {
    final restart = _restartApp;
    if (restart == null) {
      throw StateError('No app restart available for a restore');
    }
    try {
      await stage(file);
    } catch (_) {
      await BackupStaging.cancel(await _dataDir());
      rethrow;
    }
    await restart();
  }

  @override
  Future<RestoreOutcome?> outcome() async =>
      BackupStaging.readOutcome(await _dataDir());

  @override
  Future<void> clearOutcome() async =>
      BackupStaging.clearOutcome(await _dataDir());
}
