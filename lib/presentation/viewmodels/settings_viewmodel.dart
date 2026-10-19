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

  /// The planning preferences in force: the newest edit, applied at once
  /// even before it is stored (F21 A5).
  PlanningPreferences get planningPreferences => _preferences;

  /// F21 A5: the newest edit could not be stored (or a save before a
  /// restart did not finish): the screen says so, with Retry. What is
  /// stored is [_stored]; nothing reports it as saved meanwhile.
  bool get planningPreferencesUnsaved => _planningFailed || _incomplete;
  bool _planningFailed = false;
  bool _incomplete = false;
  PlanningPreferences _stored = PlanningPreferences();

  /// Whether the newest edit is still being stored.
  bool get planningPreferencesSaving =>
      !planningPreferencesUnsaved && _preferences != _stored;

  /// Null until the first write, so the chain starts in the caller's zone.
  Future<void>? _planningWrites;
  int _planningRequest = 0;

  /// Minimum usable altitude, degrees (clamped to [5°, 60°]).
  double get minAltitude => _preferences.minAltitudeDeg;

  /// Temperature − dew point at or below which dew risk is flagged, °C.
  double get dewPointThreshold => _preferences.dewMarginC;

  Future<void> load() async {
    _preferences = _stored = await _repository.load();
    _incomplete = await _repository.lastSaveIncomplete();
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

  /// Replaces the planning preferences, lets every value derived from them
  /// (windows, fit, dew risk) refresh, and stores them (F21 A5). Writes run
  /// in order, each of the whole configuration; only the newest request's
  /// outcome changes the saved/unsaved state, so an older completion never
  /// marks a newer edit saved or overwrites it. A failure keeps the edit applied and
  /// unsaved, and is rethrown for the screen's message.
  Future<void> setPlanningPreferences(PlanningPreferences preferences) {
    _preferences = preferences;
    notifyListeners();
    return _writePlanning();
  }

  /// Stores the newest complete configuration again (Retry, or "Save these
  /// settings" after an incomplete save).
  Future<void> retryPlanningPreferences() => _writePlanning();

  /// Completes when every started planning write has finished.
  Future<void> get planningIdle => _planningWrites ?? Future<void>.value();

  Future<void> _writePlanning() {
    final request = ++_planningRequest;
    // Coalesced: a write superseded before it starts is skipped; the newer
    // one stores the newest configuration (a slider's drag is one write).
    final write = (_planningWrites ?? Future<void>.value()).then((_) async {
      if (request != _planningRequest) return;
      final target = _preferences;
      await _repository.save(target);
      _stored = target;
    });
    _planningWrites = write.then((_) {}, onError: (Object _) {});
    return write.then(
      (_) {
        if (request != _planningRequest) return;
        _planningFailed = _incomplete = false;
        notifyListeners();
      },
      onError: (Object e, StackTrace s) {
        if (request == _planningRequest) {
          _planningFailed = true;
          notifyListeners();
        }
        Error.throwWithStackTrace(e, s);
      },
    );
  }

  Future<void> setMinAltitude(double value) =>
      setPlanningPreferences(_preferences.copyWith(minAltitudeDeg: value));

  Future<void> setDewPointThreshold(double threshold) =>
      setPlanningPreferences(_preferences.copyWith(dewMarginC: threshold));
}
