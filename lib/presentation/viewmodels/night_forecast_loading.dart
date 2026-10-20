part of 'night_conditions_viewmodel.dart';

/// Request identity and stale-response handling for active or browsed nights.
extension _ForecastLoading on NightConditionsViewModel {
  Object? _currentWeatherKey() {
    final night = sessionNight;
    return night == null ? null : (night, _site.latitude, _site.longitude);
  }

  void _onInputsChanged() {
    _announceWeatherChange();
    final key = _currentWeatherKey();
    if (!_active || key == _weatherKey) return;
    _weatherKey = key;
    unawaited(_loadWeather());
  }

  /// Loads the night's forecast (cache → fetch → typed states, TASK 9.3); a
  /// slow answer for a previous site or night is dropped.
  Future<void> _loadWeather({bool forceRefresh = false}) =>
      _weatherLoad = () async {
        final night = sessionNight;
        final request = ++_weatherRequest;
        if (night == null) {
          _nightWeather = const NightWeatherIdle();
          _announceWeatherChange();
          return;
        }
        _nightWeather = const NightWeatherLoading();
        _announceWeatherChange();
        final result = await _weatherService.load(
          night,
          latitude: _site.latitude,
          longitude: _site.longitude,
          forceRefresh: forceRefresh,
        );
        if (request != _weatherRequest) return;
        _nightWeather = result;
        _announceWeatherChange();
      }();
}
