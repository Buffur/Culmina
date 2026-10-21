// TASK 9.4: the night weather card shows the chosen night's hours (sunset
// to sunrise), ranges with units, the dew heuristic, the forecast's age and
// model, attribution, and the stale / unavailable / out-of-range states.

import 'dart:async';

import 'package:astroplan/core/utils/quantity_text.dart';
import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/models/weather_snapshot.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/domain/repositories/weather_snapshot_store.dart';
import 'package:astroplan/domain/services/night_weather_service.dart';

import '../../support/planner_harness.dart';

import 'package:astroplan/presentation/widgets/weather_forecast_widget.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_device_time_zone.dart';
import '../../support/fake_location_service.dart';
import '../../support/fake_reverse_geocoder.dart';

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

/// Serves every whole UTC hour of the requested interval, as the provider
/// does (temperature 10 °C, dew point 9 °C: a 1 °C spread), or fails with
/// [failWith].
class _Weather implements WeatherRepository {
  _Weather(this.clock);
  final _Clock clock;
  WeatherFailure? failWith;
  bool empty = false;
  double temperatureC = 10;
  double windSpeedKmh = 8;

  /// Cloud cover per UTC hour; 20 % throughout unless set.
  double Function(DateTime hourUtc)? cloudAt;

  @override
  Future<WeatherFetch> fetchSnapshot({
    required double latitude,
    required double longitude,
    required DateTime startUtc,
    required DateTime endUtc,
  }) async {
    final f = failWith;
    if (f != null) return WeatherFetchFailed(f);
    return WeatherFetched(
      WeatherSnapshot(
        provider: 'open-meteo',
        model: 'best_match',
        fetchedAtUtc: clock.nowUtc(),
        latitude: latitude,
        longitude: longitude,
        hours: empty
            ? const []
            : [
                for (
                  var t = DateTime.utc(
                    startUtc.year,
                    startUtc.month,
                    startUtc.day,
                    startUtc.hour,
                  );
                  t.isBefore(endUtc);
                  t = t.add(const Duration(hours: 1))
                )
                  WeatherHour(
                    timeUtc: t,
                    cloudCoverPct: cloudAt?.call(t) ?? 20,
                    windSpeedKmh: windSpeedKmh,
                    temperatureC: temperatureC,
                    dewPointC: 9,
                  ),
              ],
      ),
    );
  }
}

void main() {
  late AppDatabase database;
  late _Clock clock;
  late _Weather weather;
  late PlannerHarness vm;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    clock = _Clock();
    weather = _Weather(clock);
  });

  Future<void> pump(WidgetTester tester, {bool showZone = true}) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      database = AppDatabase(NativeDatabase.memory());
      final locations = DriftLocationRepository(database);
      final id = await locations.insertLocation(
        domain.LocationProfile(
          id: 0,
          name: 'Home',
          latitude: 46.05,
          longitude: 14.51,
          elevation: 300,
        ),
      );
      vm = PlannerHarness(
        DriftTargetRepository(database),
        DriftEquipmentRepository(database),
        weather,
        locations,
        locationService: FakeLocationService(),
        reverseGeocoder: FakeReverseGeocoder(),
        deviceTimeZone: FakeDeviceTimeZone(),
        clock: clock,
        nightWeatherService: NightWeatherService(
          repository: weather,
          store: _MemoryStore(),
          clock: clock,
          model: 'best_match',
        ),
      );
      await vm.ready;
      await vm.selectSite(id);
    });
    addTearDown(() => tester.runAsync(database.close));
    await tester.pumpWidget(
      MultiProvider(
        providers: vm.providers,
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: WeatherForecastWidget(showZone: showZone),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> run(WidgetTester tester, Future<void> Function() f) async {
    await tester.runAsync(f);
    await tester.pump();
  }

  // F14 (ADR-022 N6): the dark span at the plan's limit, not sunset to
  // sunrise; the table and model are in Details.
  testWidgets('shows the night\'s dark span, its facts, the dew heuristic; '
      'ranges with units and the model in Details; attribution', (
    tester,
  ) async {
    await pump(tester);

    expect(find.text('Night weather'), findsNothing);
    expect(find.byKey(const Key('weather.refresh')), findsOneWidget);
    expect(find.textContaining('Dark (Sun below −18°):'), findsOneWidget);
    expect(find.textContaining('Sunset to sunrise'), findsNothing);
    expect(find.textContaining('Times in device zone'), findsOneWidget);
    expect(find.textContaining('Updated just now'), findsOneWidget);
    expect(find.byKey(const Key('weather.facts')), findsOneWidget);
    expect(find.textContaining('Dew risk (heuristic)'), findsOneWidget);
    expect(find.textContaining('at or below 2.0 °C'), findsOneWidget);
    expect(
      find.text('Weather data by Open-Meteo.com (CC BY 4.0)'),
      findsOneWidget,
    );
    expect(find.text('Model: open-meteo / best_match'), findsNothing);
    await tester.ensureVisible(find.byKey(const Key('weather.details')));
    await tester.tap(find.byKey(const Key('weather.details')));
    await tester.pumpAndSettle();
    expect(find.text('Model: open-meteo / best_match'), findsOneWidget);
    expect(find.text('20 %'), findsOneWidget); // cloud cover range
    expect(find.text('8 km/h'), findsOneWidget); // wind range
    // Unknown variables are "no forecast", never 0.
    expect(find.text('no forecast'), findsWidgets);

    // The strip covers the dark span's whole hours, every one forecast.
    final s = vm.nightWeatherSummary!;
    expect(s.coveredHours, s.totalHours);
    expect(s.totalHours, inInclusiveRange(8, 12));
  });

  // OPEN-01 follow-up (Hybrid's weather answer): why, then how far to trust
  // it — the clearest and cloudiest dark hour, the dark span's length and
  // the coverage, always stated.
  testWidgets('the clearest and cloudiest dark hour, the span length and the '
      'coverage', (tester) async {
    weather.cloudAt = (t) => (t.hour * 7 % 100).toDouble();
    await pump(tester);
    final s = vm.nightWeatherSummary!;
    final clouds = [
      for (final slot in s.slots)
        if (slot.instant && slot.hour?.cloudCoverPct != null)
          slot.hour!.cloudCoverPct!,
    ];
    final min = clouds.reduce((a, b) => a < b ? a : b);
    final max = clouds.reduce((a, b) => a > b ? a : b);
    final trend = tester
        .widget<Text>(find.byKey(const Key('weather.trend')))
        .data!;
    expect(trend, startsWith('Clearest around '));
    expect(
      trend,
      contains('(${QuantityText.percent(min)}) · cloudiest around'),
    );
    expect(trend, endsWith('(${QuantityText.percent(max)})'));
    expect(
      tester.widget<Text>(find.byKey(const Key('weather.coverage'))).data,
      'Coverage: ${s.coveredHours}/${s.totalHours} hourly samples in dark '
      'time',
    );
    expect(
      tester.widget<Text>(find.byKey(const Key('weather.span'))).data,
      endsWith(' · ${QuantityText.duration(s.toUtc.difference(s.fromUtc))}'),
    );
  });

  testWidgets('one cloud value throughout: no trend line', (tester) async {
    await pump(tester);
    expect(find.byKey(const Key('weather.trend')), findsNothing);
    expect(find.byKey(const Key('weather.coverage')), findsOneWidget);
  });

  testWidgets('offline with an old cache: stale, labelled, never current', (
    tester,
  ) async {
    await pump(tester);
    weather.failWith = WeatherFailure.unavailable;
    clock.now = clock.now.add(const Duration(hours: 15));
    await run(tester, vm.refreshWeather);

    expect(
      find.textContaining('Offline, showing the cached forecast.'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Stale forecast: updated 15 h ago'),
      findsOneWidget,
    );
    expect(find.textContaining('Updated'), findsNothing);
  });

  testWidgets(
    'headline leads the span, fractions remain, shared zone can hide',
    (tester) async {
      weather.temperatureC = -2.5;
      weather.windSpeedKmh = 9.25;
      await pump(tester, showZone: false);
      expect(find.byKey(const Key('weather.zone')), findsNothing);
      expect(find.textContaining('Times in'), findsNothing);
      expect(find.text('-2.5 °C'), findsOneWidget);
      expect(find.text('9.3 km/h\nGusts no forecast'), findsOneWidget);
      expect(
        tester.getTopLeft(find.byKey(const Key('weather.facts'))).dy,
        lessThan(tester.getTopLeft(find.byKey(const Key('weather.span'))).dy),
      );
      expect(
        tester.getTopLeft(find.byKey(const Key('weather.span'))).dy,
        lessThan(tester.getTopLeft(find.text('Air temperature')).dy),
      );
      expect(
        vm.nightWeatherSummary!.temperature!.min,
        -2.5,
        reason: 'display rounding does not mutate the forecast',
      );
    },
  );

  testWidgets('offline with nothing cached: unavailable with a retry', (
    tester,
  ) async {
    weather.failWith = WeatherFailure.unavailable;
    await pump(tester);
    expect(find.text('No forecast.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('beyond the horizon: no forecast yet', (tester) async {
    weather.failWith = WeatherFailure.outOfRange;
    await pump(tester);
    expect(find.byKey(const Key('weather.outOfRange')), findsOneWidget);
  });

  // Acceptance: a night 5 days ahead shows its own hours, or "no forecast".
  testWidgets('a night 5 days ahead shows its own hours, or no forecast', (
    tester,
  ) async {
    await pump(tester);
    await run(tester, () async {
      unawaited(vm.setEveningDate(CalendarDate(2026, 9, 29)));
      await Future<void>.delayed(Duration.zero);
    });
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();
    final s = vm.nightWeatherSummary!;
    expect(s.fromUtc.day, 29);
    expect(s.slots.first.timeUtc.day, 29);
    expect(s.coveredHours, s.totalHours);

    weather.empty = true;
    await run(tester, vm.refreshWeather);
    expect(find.text('No forecast for these hours.'), findsOneWidget);
  });
}
