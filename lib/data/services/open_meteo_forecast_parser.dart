import '../../domain/models/weather_snapshot.dart';

/// Parses an Open-Meteo `/v1/forecast` response requested with
/// `timeformat=unixtime` (ADR-012 §4; TASK 9.2). Pure: no clock, no I/O.
///
/// - Times are UNIX seconds in GMT+0 → `DateTime.utc`; the device's time
///   zone plays no part.
/// - A null value, or an array shorter than `time`, is **unknown** (null),
///   never 0 (SI-008).
/// - `{"error": true, "reason": …}` becomes a [WeatherFetchFailed].
abstract final class OpenMeteoForecastParser {
  static const String provider = 'open-meteo';

  /// The hourly variables requested, in ADR-012 §3 order.
  static const List<String> hourlyVariables = [
    'cloud_cover',
    'cloud_cover_low',
    'cloud_cover_mid',
    'cloud_cover_high',
    'precipitation_probability',
    'wind_speed_10m',
    'wind_gusts_10m',
    'temperature_2m',
    'dew_point_2m',
    'relative_humidity_2m',
    'visibility',
  ];

  static WeatherFetch parse(
    Object? json, {
    required String model,
    required DateTime fetchedAtUtc,
    required double latitude,
    required double longitude,
  }) {
    if (json is! Map<String, dynamic>) {
      return const WeatherFetchFailed(
        WeatherFailure.malformed,
        'not an object',
      );
    }
    if (json['error'] == true) {
      final reason = json['reason']?.toString();
      final outOfRange =
          reason != null && reason.contains('out of allowed range');
      return WeatherFetchFailed(
        outOfRange ? WeatherFailure.outOfRange : WeatherFailure.unavailable,
        reason,
      );
    }
    final hourly = json['hourly'];
    if (hourly is! Map<String, dynamic>) {
      return const WeatherFetchFailed(WeatherFailure.malformed, 'no hourly');
    }
    final times = hourly['time'];
    if (times is! List || times.isEmpty) {
      return const WeatherFetchFailed(WeatherFailure.malformed, 'no time');
    }

    double? value(String variable, int i) {
      final list = hourly[variable];
      if (list is! List || i >= list.length) return null;
      return WeatherHour.value(
        list[i],
        percent:
            variable.startsWith('cloud_cover') ||
            variable == 'precipitation_probability' ||
            variable == 'relative_humidity_2m',
        nonNegative: variable.startsWith('wind_') || variable == 'visibility',
      );
    }

    final hours = <WeatherHour>[];
    final seenTimes = <int>{};
    for (var i = 0; i < times.length; i++) {
      final t = times[i];
      // DateTime supports at most 100 million days from the epoch.
      if (t is! int || t.abs() > 8640000000000 || !seenTimes.add(t)) {
        return WeatherFetchFailed(WeatherFailure.malformed, 'time[$i]');
      }
      hours.add(
        WeatherHour(
          timeUtc: DateTime.fromMillisecondsSinceEpoch(t * 1000, isUtc: true),
          cloudCoverPct: value('cloud_cover', i),
          cloudCoverLowPct: value('cloud_cover_low', i),
          cloudCoverMidPct: value('cloud_cover_mid', i),
          cloudCoverHighPct: value('cloud_cover_high', i),
          precipitationProbabilityPct: value('precipitation_probability', i),
          windSpeedKmh: value('wind_speed_10m', i),
          windGustsKmh: value('wind_gusts_10m', i),
          temperatureC: value('temperature_2m', i),
          dewPointC: value('dew_point_2m', i),
          relativeHumidityPct: value('relative_humidity_2m', i),
          visibilityM: value('visibility', i),
        ),
      );
    }
    hours.sort((a, b) => a.timeUtc.compareTo(b.timeUtc));
    return WeatherFetched(
      WeatherSnapshot(
        provider: provider,
        model: model,
        fetchedAtUtc: fetchedAtUtc.toUtc(),
        latitude: latitude,
        longitude: longitude,
        hours: hours,
      ),
    );
  }
}
