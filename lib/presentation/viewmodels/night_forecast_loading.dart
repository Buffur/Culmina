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

  /// Startup and a directly opened conditions route can begin in the same
  /// frame. A scoped browser lets the plan's identical request populate the
  /// shared cache before it asks; viewing needs no duplicate fetch.
  Future<void> _loadAfterSource() async {
    final source = _forecastSource;
    if (source != null &&
        source._active &&
        source._currentWeatherKey() == _currentWeatherKey()) {
      await source.idle;
    }
    if (!_disposed) unawaited(_loadWeather());
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
