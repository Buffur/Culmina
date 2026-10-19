import 'package:flutter/foundation.dart';

import '../../core/diagnostics/app_log.dart';
import '../../domain/repositories/first_run_repository.dart';
import 'site_viewmodel.dart';
import 'startup_viewmodel.dart';

/// The Tonight tab's own state (TASK 12.5): whether the app starts on the
/// first-run setup. Everything the dashboard shows comes from the other
/// ViewModels.
///
/// Owner decision: the setup is offered once, on a start with no stored
/// site or position, until it is finished; users who already have a site
/// never see it. Since F16 (A1) the stored flag, read before the first
/// frame, decides the first route: Welcome opens instead of Tonight, never
/// over it after a frame.
class TonightViewModel extends ChangeNotifier {
  TonightViewModel({
    required this._site,
    required this._startup,
    required this._firstRun,
  }) {
    _site.addListener(notifyListeners);
    _startup.addListener(notifyListeners);
  }

  final SiteViewModel _site;
  final StartupViewModel _startup;
  final FirstRunRepository _firstRun;

  /// Treated as done until [load] reads the stored flag, so nothing is
  /// offered before it is known.
  bool _done = true;

  /// Reads the stored flag, before the first frame; a failed read offers
  /// nothing. [hasStoredSite]: a site or position is already stored.
  Future<void> load({bool hasStoredSite = false}) async {
    try {
      _done = await _firstRun.isDone();
    } catch (e) {
      _done = true;
      AppLog.warning('startup', 'First-run state unreadable', error: e);
    }
    _startsAtWelcome = !_done && !hasStoredSite;
    notifyListeners();
  }

  bool _startsAtWelcome = false;

  /// Whether the first route is the setup (F16 A1).
  bool get startsAtWelcome => _startsAtWelcome;

  /// Finished or skipped: never offered again.
  Future<void> finishFirstRun() async {
    _done = true;
    notifyListeners();
    await _firstRun.markDone();
  }

  @override
  void dispose() {
    _site.removeListener(notifyListeners);
    _startup.removeListener(notifyListeners);
    super.dispose();
  }
}
