/// What a backup file says about itself, shown before a restore (TASK 14.4).
class BackupPreview {
  const BackupPreview({
    required this.createdAtUtc,
    required this.schemaVersion,
    required this.appVersion,
    required this.sessionCount,
  });

  final DateTime createdAtUtc;
  final int schemaVersion;
  final String appVersion;
  final int sessionCount;
}

/// Why a backup cannot be restored (TASK 14.4).
enum BackupProblem {
  /// Not an AstroPlan backup, or damaged.
  notABackup,

  /// Made by a newer app with a newer database schema: refused (roadmap).
  newerSchema,

  /// Older than the oldest schema this app can upgrade (ADR-008 floor).
  tooOld,

  /// The archive is well formed, but its database cannot become the live
  /// one: damaged, truncated, missing tables or columns, or unreadable rows
  /// (F01, TD-106).
  unusable,

  /// The checked backup could not replace the live files; everything was
  /// put back as it was (F01 A3).
  notApplied,
}

class BackupException implements Exception {
  const BackupException(this.problem);
  final BackupProblem problem;

  @override
  String toString() => 'BackupException: ${problem.name}';
}

/// What happened to the last confirmed restore, reported once by the app
/// instance that starts after it (F01 A5).
enum RestoreResult {
  /// The backup is now the app's data.
  applied,

  /// The backup was refused when the app restarted to apply it; the data
  /// from before is unchanged.
  refused,

  /// The restore was interrupted and, at the next start, completed: the
  /// data is the backup's.
  completedAfterInterruption,
}

class RestoreOutcome {
  const RestoreOutcome(this.result, {this.problem});

  final RestoreResult result;

  /// Why it was refused; null otherwise.
  final BackupProblem? problem;
}

/// Manual backup and restore (TASK 14.4; F01, owner decisions D2/D7): one
/// `.astroplan` file (database copy + manifest v2 + header) shared to a
/// place the user picks. A restore is checked when the file is picked,
/// confirmed, then applied at once: the app restarts, checks the backup
/// again before anything changes, and replaces its data.
abstract class BackupService {
  /// Creates a backup and opens the share sheet.
  Future<void> backUpAndShare();

  /// Lets the user pick a backup file and checks it completely, the
  /// database included; null if cancelled. Throws [BackupException] when
  /// it cannot be restored; nothing has changed then.
  Future<({BackupPreview preview, Object file})?> pick();

  /// Applies a picked, checked, confirmed backup now: the app restarts
  /// into a screen that cannot be edited, and the next app instance reports
  /// the outcome ([outcome]).
  Future<void> restoreAndRestart(Object file);

  /// The outcome of the last restore, if not yet reported.
  Future<RestoreOutcome?> outcome();

  /// Forgets the outcome once it has been reported.
  Future<void> clearOutcome();
}
