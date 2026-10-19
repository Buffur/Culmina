// TASK 9.3 (ADR-012 §6): caching, freshness and failure states for the
// chosen night's forecast, driven by a controllable clock.

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/night_weather.dart';
import 'package:astroplan/domain/models/session_night.dart';
import 'package:astroplan/domain/models/site_time_context.dart';
import 'package:astroplan/domain/models/weather_snapshot.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/domain/repositories/weather_snapshot_store.dart';
import 'package:astroplan/domain/services/night_weather_service.dart';
import 'package:astroplan/domain/services/session_night_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

class _Clock extends Clock {
  DateTime now = DateTime.utc(2026, 9, 24, 12);
  @override
  DateTime nowUtc() => now;
}

class _MemoryStore implements WeatherSnapshotStore {
  final Map<String, WeatherSnapshot> data = {};
  @override
  Future<WeatherSnapshot?> read(String key) async => data[key];
  @override
  Future<void> write(String key, WeatherSnapshot snapshot) async =>
      data[key] = snapshot;
}

/// Answers with a one-hour snapshot, or fails with [failWith]; counts calls.
class _Weather implements WeatherRepository {
  _Weather(this.clock);
  final _Clock clock;
  WeatherFailure? failWith;
  int calls = 0;

  @override
  Future<WeatherFetch> fetchSnapshot({
    required double latitude,
    required double longitude,
    required DateTime startUtc,
    required DateTime endUtc,
  }) async {
    calls++;
    final f = failWith;
    if (f != null) return WeatherFetchFailed(f);
    return WeatherFetched(
      WeatherSnapshot(
        provider: 'open-meteo',
        model: 'best_match',
        fetchedAtUtc: clock.nowUtc(),
        latitude: latitude,
        longitude: longitude,
        hours: [WeatherHour(timeUtc: startUtc, cloudCoverPct: 10)],
      ),
    );
  }
}

void main() {
  late _Clock clock;
  late _MemoryStore store;
  late _Weather weather;
  late NightWeatherService service;
  late SessionNight night;

  setUp(() {
    clock = _Clock();
    store = _MemoryStore();
    weather = _Weather(clock);
    service = NightWeatherService(
      repository: weather,
      store: store,
      clock: clock,
      model: 'best_match',
    );
    night = SessionNightResolver.forEveningDate(
      CalendarDate(2026, 9, 24),
      latitude: 46.05,
      longitude: 14.51,
      timeContext: MeanSolarTimeContext(14.51),
    );
  });

  Future<NightWeather> load({bool force = false, double lat = 46.05}) =>
      service.load(night, latitude: lat, longitude: 14.51, forceRefresh: force);

  test('age thresholds: under 3 h current, 3-12 h aging, 12 h+ stale', () {
    final t0 = DateTime.utc(2026, 9, 24);
    WeatherAge at(Duration d) => WeatherFreshness.ageOf(t0, t0.add(d));
    expect(at(Duration.zero), WeatherAge.current);
    expect(at(const Duration(hours: 2, minutes: 59)), WeatherAge.current);
    expect(at(const Duration(hours: 3)), WeatherAge.aging);
    expect(at(const Duration(hours: 11, minutes: 59)), WeatherAge.aging);
    expect(at(const Duration(hours: 12)), WeatherAge.stale);
  });

  test('a first load fetches, caches and is current', () async {
    final s = await load() as NightWeatherAvailable;
    expect(s.fromCache, isFalse);
    expect(s.age, WeatherAge.current);
    expect(s.refreshFailed, isNull);
    expect(weather.calls, 1);
    expect(store.data, hasLength(1));
  });

  test('a current cache is used without a request', () async {
    await load();
    clock.now = clock.now.add(const Duration(hours: 2));
    final s = await load() as NightWeatherAvailable;
    expect(s.fromCache, isTrue);
    expect(s.ageDuration, const Duration(hours: 2));
    expect(weather.calls, 1);
  });

  test('an aging cache is refreshed', () async {
    await load();
    clock.now = clock.now.add(const Duration(hours: 4));
    final s = await load() as NightWeatherAvailable;
    expect(weather.calls, 2);
    expect(s.fromCache, isFalse);
    expect(s.age, WeatherAge.current);
  });

  // Acceptance: airplane mode shows cached data with its age — never as
  // current.
  test('offline: the cached forecast is shown with its age', () async {
    await load();
    weather.failWith = WeatherFailure.unavailable;

    clock.now = clock.now.add(const Duration(hours: 5));
    final aging = await load() as NightWeatherAvailable;
    expect(aging.fromCache, isTrue);
    expect(aging.age, WeatherAge.aging);
    expect(aging.ageDuration, const Duration(hours: 5));
    expect(aging.refreshFailed, WeatherFailure.unavailable);

    clock.now = clock.now.add(const Duration(hours: 10));
    final stale = await load() as NightWeatherAvailable;
    expect(stale.age, WeatherAge.stale);
    expect(stale.refreshFailed, WeatherFailure.unavailable);
  });

  test('offline without a cache is unavailable', () async {
    weather.failWith = WeatherFailure.unavailable;
    final s = await load();
    expect(s, isA<NightWeatherUnavailable>());
    expect((s as NightWeatherUnavailable).failure, WeatherFailure.unavailable);
  });

  test('beyond the horizon is out of range', () async {
    weather.failWith = WeatherFailure.outOfRange;
    expect(await load(), isA<NightWeatherOutOfRange>());
  });

  test('a forced refresh bypasses a current cache', () async {
    await load();
    await load(force: true);
    expect(weather.calls, 2);
  });

  test('another site never gets this site\'s cache', () async {
    await load();
    weather.failWith = WeatherFailure.unavailable;
    expect(await load(lat: 45.0), isA<NightWeatherUnavailable>());
  });

  // F14 A2 (ADR-022 N8): one key per site cell, model and horizon, format
  // version 2; no night and no site id in it.
  test('the key separates site, model and horizon, not nights', () {
    String key({
      double lat = 46.05,
      String model = 'best_match',
      int days = 16,
    }) => WeatherSnapshotStore.keyFor(
      latitude: lat,
      longitude: 14.51,
      model: model,
      forecastDays: days,
    );
    expect(key(), 'weather2:46.05:14.51:best_match:16');
    expect(key(), key(lat: 46.054)); // same 0.01 degree cell
    expect(key(), isNot(key(lat: 46.06)));
    expect(key(), isNot(key(model: 'icon_seamless')));
    expect(key(), isNot(key(days: 7)));
  });

  // F14 A1 (N7): one request serves every night of its horizon.
  test('one snapshot serves the next night without a request; a night it '
      'has no row for is asked again', () async {
    final horizon = _Horizon(clock);
    final s = NightWeatherService(
      repository: horizon,
      store: store,
      clock: clock,
      model: 'best_match',
    );
    final next = SessionNightResolver.forEveningDate(
      CalendarDate(2026, 9, 25),
      latitude: 46.05,
      longitude: 14.51,
      timeContext: MeanSolarTimeContext(14.51),
    );
    final far = SessionNightResolver.forEveningDate(
      CalendarDate(2026, 10, 20),
      latitude: 46.05,
      longitude: 14.51,
      timeContext: MeanSolarTimeContext(14.51),
    );
    Future<NightWeather> at(SessionNight n) =>
        s.load(n, latitude: 46.05, longitude: 14.51);
    expect(await at(night), isA<NightWeatherAvailable>());
    expect(horizon.calls, 1);
    final second = await at(next) as NightWeatherAvailable;
    expect(horizon.calls, 1, reason: 'the same snapshot');
    expect(second.fromCache, isTrue);
    await at(far);
    expect(horizon.calls, 2, reason: 'no row for that night');
  });
}

/// Answers with three days of hourly rows from the start of today, as one
/// horizon request does (N7).
class _Horizon implements WeatherRepository {
  _Horizon(this.clock);
  final _Clock clock;
  int calls = 0;

  @override
  Future<WeatherFetch> fetchSnapshot({
    required double latitude,
    required double longitude,
    required DateTime startUtc,
    required DateTime endUtc,
  }) async {
    calls++;
    final now = clock.nowUtc();
    final today = DateTime.utc(now.year, now.month, now.day);
    return WeatherFetched(
      WeatherSnapshot(
        provider: 'open-meteo',
        model: 'best_match',
        fetchedAtUtc: now,
        latitude: latitude,
        longitude: longitude,
        hours: [
          for (var h = 0; h < 72; h++)
            WeatherHour(
              timeUtc: today.add(Duration(hours: h)),
              cloudCoverPct: 20,
            ),
        ],
      ),
    );
  }
}
