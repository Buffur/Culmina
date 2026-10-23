import 'package:flutter/foundation.dart';

import '../../core/diagnostics/app_log.dart';
import '../../core/units/display_units.dart';
import '../../domain/repositories/display_settings_repository.dart';

/// Appearance and units (F21, S16.6, PD-20; D1 = A: System by default and
/// neutral tokens). A choice applies at once and is then stored; only the
/// newest request's outcome changes what is reported (A5): an older
/// completion never marks a newer choice saved, a failure keeps the choice
/// applied and visibly unsaved with Retry, and nothing is silently reverted.
/// Load before the first frame so a restart never flashes another theme.
class DisplaySettingsViewModel extends ChangeNotifier {
  DisplaySettingsViewModel(this._repository);

  final DisplaySettingsRepository _repository;

  DisplaySettings _shown = const DisplaySettings();
  DisplaySettings _stored = const DisplaySettings();
  bool _failed = false;

  /// Null until the first write, so the chain starts in the caller's zone.
  Future<void>? _writes;
  int _request = 0;

  DisplaySettings get settings => _shown;
  Appearance get appearance => _shown.appearance;
  DisplayUnits get units => _shown.units;
  WeatherView get weatherView => _shown.weatherView;

  /// The newest choice could not be stored: shown with Retry.
  bool get unsaved => _failed;

  /// The newest choice is still being stored.
  bool get saving => !_failed && _shown != _stored;

  /// Restores the stored choices; an unreadable store keeps the defaults
  /// (logged), as field mode does. After a save that stopped part way the
  /// stored values are shown as unsaved, with Retry (F21 A5).
  Future<void> load() async {
    try {
      _shown = _stored = await _repository.load();
      _failed = await _repository.lastSaveIncomplete();
    } catch (e) {
      AppLog.warning('display', 'Display settings unreadable', error: e);
    }
    notifyListeners();
  }

  Future<void> setAppearance(Appearance a) =>
      _set(_shown.copyWith(appearance: a));

  Future<void> setUnits(DisplayUnits u) => _set(_shown.copyWith(units: u));

  Future<void> setWeatherView(WeatherView v) =>
      _set(_shown.copyWith(weatherView: v));

  /// Stores the newest choices again.
  Future<void> retry() => _write();

  Future<void> _set(DisplaySettings next) {
    _shown = next;
    notifyListeners();
    return _write();
  }

  /// Completes when every started write has finished.
  Future<void> get idle => _writes ?? Future<void>.value();

  Future<void> _write() {
    final request = ++_request;
    // Coalesced: a write superseded before it starts is skipped.
    final write = (_writes ?? Future<void>.value()).then((_) async {
      if (request != _request) return;
      final target = _shown;
      await _repository.save(target);
      _stored = target;
    });
    _writes = write.then((_) {}, onError: (Object _) {});
    return write.then(
      (_) {
        if (request != _request) return;
        _failed = false;
        notifyListeners();
      },
      onError: (Object e, StackTrace s) {
        if (request == _request) {
          _failed = true;
          notifyListeners();
        }
        Error.throwWithStackTrace(e, s);
      },
    );
  }
}
