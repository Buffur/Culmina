import 'package:flutter/foundation.dart';

import '../../domain/models/planning_preferences.dart';
import '../../domain/repositories/planning_preferences_repository.dart';
import '../../domain/repositories/privacy_preferences_repository.dart';
import '../../domain/services/opt_in_reverse_geocoder.dart';

/// The user's planning thresholds and overhead defaults (TASK 5.2; split
/// out of the planner ViewModel in TASK 12.3). Defaults, rationale and
/// valid ranges are documented on [PlanningPreferences]. Since TASK 16.3
/// also the privacy choice of place-name lookups.
class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel(this._repository, this._privacy, this._placeNames);

  final PlanningPreferencesRepository _repository;
  final PrivacyPreferencesRepository _privacy;
  final OptInReverseGeocoder _placeNames;

  /// Called when place-name lookups are switched (the site looks its
  /// position up again, or clears the name).
  void Function()? onPlaceNameLookupChanged;

  /// Whether positions are sent to OpenStreetMap Nominatim for place names
  /// (off by default; TASK 16.3).
  bool get placeNameLookup => _placeNames.enabled;

  /// True when Off is shown and applied but could not be stored, so the
  /// stored choice is still On (F21 A6): the screen says so, with Retry.
  bool get placeNameLookupUnsaved => _placeNameOffUnsaved;
  bool _placeNameOffUnsaved = false;

  /// Writes run one after another; only the newest request's outcome
  /// changes what is shown.
  Future<void> _placeNameWrites = Future<void>.value();
  int _placeNameRequest = 0;

  PlanningPreferences _preferences = PlanningPreferences();

  PlanningPreferences get planningPreferences => _preferences;

  /// Minimum usable altitude, degrees (clamped to [5°, 60°]).
  double get minAltitude => _preferences.minAltitudeDeg;

  /// Temperature − dew point at or below which dew risk is flagged, °C.
  double get dewPointThreshold => _preferences.dewMarginC;

  Future<void> load() async {
    _preferences = await _repository.load();
    _placeNames.enabled = await _privacy.loadPlaceNameLookup();
    notifyListeners();
    if (_placeNames.enabled) onPlaceNameLookupChanged?.call();
  }

  /// F21 A6 (CRUX-02): the switch shows only a stored choice, or an Off
  /// that is marked unsaved. Off applies at once, so no position is sent
  /// from the tap on; if storing it fails it stays applied and unsaved,
  /// with Retry. On applies only once stored: until then, and after a failed
  /// write, lookups stay off and nothing is sent. A failure is rethrown for
  /// the screen's message.
  Future<void> setPlaceNameLookup(bool on) {
    final request = ++_placeNameRequest;
    if (!on && _placeNames.enabled) {
      _placeNames.enabled = false;
      notifyListeners();
      onPlaceNameLookupChanged?.call();
    }
    final write = _placeNameWrites.then(
      (_) => _privacy.savePlaceNameLookup(on),
    );
    _placeNameWrites = write.then((_) {}, onError: (Object _) {});
    return write.then(
      (_) {
        if (request != _placeNameRequest) return;
        _placeNameOffUnsaved = false;
        if (on && !_placeNames.enabled) {
          _placeNames.enabled = true;
          notifyListeners();
          onPlaceNameLookupChanged?.call();
        } else {
          notifyListeners();
        }
      },
      onError: (Object e, StackTrace s) {
        if (request == _placeNameRequest && !on) {
          _placeNameOffUnsaved = true;
          notifyListeners();
        }
        Error.throwWithStackTrace(e, s);
      },
    );
  }

  /// Replaces the planning preferences, persists them, and lets every value
  /// derived from them (windows, fit, dew risk) refresh.
  Future<void> setPlanningPreferences(PlanningPreferences preferences) async {
    _preferences = preferences;
    notifyListeners();
    await _repository.save(_preferences);
  }

  Future<void> setMinAltitude(double value) =>
      setPlanningPreferences(_preferences.copyWith(minAltitudeDeg: value));

  Future<void> setDewPointThreshold(double threshold) =>
      setPlanningPreferences(_preferences.copyWith(dewMarginC: threshold));
}
