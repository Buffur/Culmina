// TASK 9.4 / Hybrid HT-W01..W04: the Weather view answers for the plan's
// dark span (cloud range, span, trend), says how far to trust it (coverage,
// age, gaps, offline), shows ranges in the user's units as A · Compact rows
// or B · Hourly charts, and keeps the model, table and attribution in
// Forecast details; stale / unavailable / out-of-range states stay explicit.

import 'dart:async';

import 'package:astroplan/core/utils/quantity_text.dart';
import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/core/theme/app_theme.dart';
import 'package:astroplan/core/theme/app_palette.dart';
import 'package:astroplan/core/theme/hybrid_tokens.dart';
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

import 'package:astroplan/core/units/display_units.dart';
import 'package:astroplan/presentation/widgets/weather_hybrid_view.dart';
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

  Future<void> pump(WidgetTester tester, {ThemeData? theme}) async {
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
          theme: theme,
          home: Scaffold(
            body: SingleChildScrollView(child: HybridWeatherView()),
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
  // sunrise; the table and model are in Forecast details.
  testWidgets('answers for the dark span; ranges with units, the dew '
      'caution; model, table and attribution in Forecast details', (
    tester,
  ) async {
    await pump(tester);

    expect(find.text('Cloud 20% in the dark'), findsOneWidget);
    expect(find.byKey(const Key('weather.refresh')), findsOneWidget);
    expect(find.text('Refresh forecast'), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('weather.span'))).data,
      startsWith('Dark '),
    );
    expect(find.textContaining('Sunset to sunrise'), findsNothing);
    expect(find.byKey(const Key('weather.updated')), findsOneWidget);
    expect(find.byKey(const Key('weather.freshnessNotice')), findsNothing);
    expect(find.byKey(const Key('weather.rows')), findsOneWidget);
    expect(find.text('A · Compact rows · '), findsOneWidget);
    // A 1 °C spread: every known sample is a dew caution, not a forecast.
    expect(
      find.textContaining('A caution, not a condensation forecast.'),
      findsOneWidget,
    );
    expect(find.text('20%'), findsOneWidget); // cloud cover range
    expect(find.text('10 °C · dew point 9 °C'), findsOneWidget);
    expect(find.text('8 km/h · gusts Unknown'), findsOneWidget);
    // Unknown variables are "Unknown", never 0.
    expect(find.text('Unknown'), findsWidgets);
    expect(find.byKey(const Key('weather.model')), findsNothing);
    await tester.ensureVisible(find.byKey(const Key('weather.details')));
    await tester.tap(find.text('Forecast details'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const Key('weather.model'))).data,
      startsWith('Model: open-meteo / best_match.'),
    );
    expect(find.byKey(const Key('weather.table')), findsOneWidget);
    expect(
      find.text('Weather data by Open-Meteo.com (CC BY 4.0)'),
      findsOneWidget,
    );

    // The view covers the dark span's whole hours, every one forecast.
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
      find.text(
        'Offline · cached forecast. Offline or the service did not answer.',
      ),
      findsOneWidget,
    );
    expect(
      find.text('Stale snapshot · forecast, not current conditions.'),
      findsOneWidget,
    );
    expect(
      tester.widget<Text>(find.byKey(const Key('weather.updated'))).data,
      endsWith(' · 15 h old'),
    );
  });

  testWidgets('ranges keep fractions, convert to the user\'s units, and the '
      'answer leads the span', (tester) async {
    weather.temperatureC = -2.5;
    weather.windSpeedKmh = 9.25;
    await pump(tester);
    expect(find.text('-2.5 °C · dew point 9 °C'), findsOneWidget);
    expect(find.text('9.3 km/h · gusts Unknown'), findsOneWidget);
    expect(
      tester.getTopLeft(find.byKey(const Key('weather.facts'))).dy,
      lessThan(tester.getTopLeft(find.byKey(const Key('weather.span'))).dy),
    );
    expect(
      vm.nightWeatherSummary!.temperature!.min,
      -2.5,
      reason: 'display rounding does not mutate the forecast',
    );
    await tester.runAsync(
      () => vm.vms.displaySettings.setUnits(
        vm.vms.displaySettings.units.copyWith(
          temperature: TemperatureUnit.fahrenheit,
        ),
      ),
    );
    await tester.pump();
    expect(find.text('27.5 °F · dew point 48.2 °F'), findsOneWidget);
  });

  for (final entry in [
    (
      'light',
      AppTheme.light,
      const Color(0xFFC2E5FF),
      const Color(0xFF113264),
      const Color(0xFF0D74CE),
    ),
    (
      'dark',
      AppTheme.dark,
      const Color(0xFF004074),
      const Color(0xFFC2E6FF),
      const Color(0xFF70B8FF),
    ),
    (
      'field',
      AppTheme.fieldTheme,
      const Color(0xFF330000),
      const Color(0xFFFF0000),
      const Color(0xFFFF0000),
    ),
  ]) {
    testWidgets('P-6: selected chart hour matches reference in ${entry.$1}', (
      tester,
    ) async {
      await pump(tester, theme: entry.$2);
      await tester.runAsync(
        () => vm.vms.displaySettings.setWeatherView(WeatherView.charts),
      );
      await tester.pump();
      Container cell(int index) => tester.widget<Container>(
        find.descendant(
          of: find.byKey(Key('weather.hour.$index')),
          matching: find.byType(Container),
        ),
      );
      void expectSelected(int index) {
        final container = cell(index);
        final decoration = container.decoration! as BoxDecoration;
        final text = container.child! as Text;
        expect(decoration.color, entry.$3);
        expect(text.style!.color, entry.$4);
        expect((decoration.border! as Border).bottom.color, entry.$5);
        expect((decoration.border! as Border).bottom.width, 2);
      }

      expectSelected(0);
      await tester.ensureVisible(find.byKey(const Key('weather.hour.2')));
      await tester.tap(find.byKey(const Key('weather.hour.2')));
      await tester.pump();
      expectSelected(2);
      final previous = cell(0);
      expect(
        (previous.decoration! as BoxDecoration).color,
        HybridTokens.transparent,
      );
      expect(
        (previous.child! as Text).style!.color,
        entry.$2.extension<AppPalette>()!.textSecondary,
      );
    });
  }

  // HT-W04: the presentation preference shows the same data as charts.
  testWidgets('B · Hourly charts: the same hours, one selectable at a time', (
    tester,
  ) async {
    await pump(tester);
    await tester.runAsync(
      () => vm.vms.displaySettings.setWeatherView(WeatherView.charts),
    );
    await tester.pump();
    expect(find.byKey(const Key('weather.rows')), findsNothing);
    expect(find.byKey(const Key('weather.charts')), findsOneWidget);
    expect(find.text('B · Hourly charts · '), findsOneWidget);
    final before = tester
        .widget<Text>(find.byKey(const Key('weather.hourLabel')))
        .data;
    await tester.ensureVisible(find.byKey(const Key('weather.hour.2')));
    await tester.tap(find.byKey(const Key('weather.hour.2')));
    await tester.pump();
    expect(
      tester.widget<Text>(find.byKey(const Key('weather.hourLabel'))).data,
      isNot(before),
    );
  });

  testWidgets('offline with nothing cached: unavailable with a retry', (
    tester,
  ) async {
    weather.failWith = WeatherFailure.unavailable;
    await pump(tester);
    expect(find.text('Forecast unavailable'), findsOneWidget);
    expect(find.text('Offline or the service did not answer.'), findsOneWidget);
    expect(find.text('Retry forecast'), findsOneWidget);
    expect(find.byKey(const Key('weather.details')), findsNothing);
  });

  testWidgets('beyond the horizon: no forecast yet', (tester) async {
    weather.failWith = WeatherFailure.outOfRange;
    await pump(tester);
    expect(find.text('No forecast yet'), findsOneWidget);
    expect(find.byKey(const Key('weather.outOfRange')), findsOneWidget);
    expect(find.byKey(const Key('weather.refresh')), findsNothing);
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
    expect(find.text('Cloud cover unknown'), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('weather.coverage'))).data,
      'Coverage: 0/${s.totalHours} hourly samples in dark time',
    );
    expect(find.byKey(const Key('weather.gaps')), findsOneWidget);
  });
}
