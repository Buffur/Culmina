import 'package:flutter/foundation.dart';

import '../../domain/services/backup_service.dart';

/// Backup and restore in Settings (TASK 14.4; F01, D2/D7). A restore is
/// checked when picked, confirmed by the user and applied at once: the app
/// restarts and the next instance reports the outcome ([outcome]).
class BackupViewModel extends ChangeNotifier {
  BackupViewModel(this._service);

  final BackupService _service;
  bool _busy = false;
  bool _restoring = false;
  RestoreOutcome? _outcome;

  bool get busy => _busy || _restoring;

  /// A confirmed restore is being applied; nothing can be changed now.
  bool get restoring => _restoring;

  /// The last restore's outcome, until [outcomeShown].
  RestoreOutcome? get outcome => _outcome;

  Future<void> load() async {
    _outcome = await _service.outcome();
    notifyListeners();
  }

  /// The outcome was reported: it is never reported again (F01 A5).
  Future<void> outcomeShown() async {
    if (_outcome == null) return;
    _outcome = null;
    notifyListeners();
    await _service.clearOutcome();
  }

  /// Backs up and shares; false when the share sheet was closed without
  /// sharing (F01 A4).
  Future<bool> backUp() async {
    var shared = false;
    await _run(() async => shared = await _service.backUpAndShare());
    return shared;
  }

  /// Picks and checks a backup; null if cancelled. Throws
  /// [BackupException] for a file that cannot be restored.
  Future<({BackupPreview preview, Object file})?> pick() async {
    _busy = true;
    notifyListeners();
    try {
      return await _service.pick();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  /// After the user confirmed: apply [file] now (D7 A). On success the app
  /// restarts and this instance is gone; a failure leaves the data as it
  /// was and is rethrown.
  Future<void> restoreAndRestart(Object file) async {
    _restoring = true;
    notifyListeners();
    try {
      await _service.restoreAndRestart(file);
    } catch (_) {
      _restoring = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    _busy = true;
    notifyListeners();
    try {
      await action();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}
