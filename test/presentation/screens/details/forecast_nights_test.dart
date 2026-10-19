// F14 A1/A3/A5/A6 (ADR-022 N6/N7/N9/N11; D9 A; UXA-C3): the Weather detail
// leads with the plan night's facts on its dark span, an hourly strip whose
// hours show their exact values on a tap, the seeing limitation with a link
// the user opens, and Details for the full table and model. Below it, one
// card per coming night says how much of its dark span the forecast covers
// and how far ahead it was made; opening a card changes nothing, and "Plan
// this night" follows D9: a never-saved draft moves, a saved plan is copied
// and stays as it was. Through the real app and database.

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/services/catalog_seeder.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/models/weather_snapshot.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/domain/services/forecast_overview.dart';
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:astroplan/presentation/shared/night_text.dart';
import 'package:astroplan/presentation/widgets/forecast_nights_section.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/fake_device_time_zone.dart';
import '../../../support/fake_location_service.dart';
import '../../../support/fake_reverse_geocoder.dart';
import '../../../support/planner_harness.dart';

/// One horizon response: hourly rows from 00:00 UTC today for 70 hours
/// (until 21:00 UTC two days later), with an unknown cloud value at [cloudGapAt]; counts requests.
class _Horizon implements WeatherRepository {
  _Horizon(this.clock, {this.cloudGapAt});

  static const hours = 70;
  final Clock clock;
  final DateTime? cloudGapAt;
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
          for (var h = 0; h < hours; h++)
            () {
              final t = today.add(Duration(hours: h));
              return WeatherHour(
                timeUtc: t,
                cloudCoverPct: t == cloudGapAt ? null : 30,
                cloudCoverLowPct: 10,
                cloudCoverMidPct: 15,
                cloudCoverHighPct: 25,
                precipitationProbabilityPct: 5,
                windSpeedKmh: 8,
                windGustsKmh: 20,
                temperatureC: 3,
                dewPointC: -1,
                relativeHumidityPct: 75,
                visibilityM: 24000,
              );
            }(),
        ],
      ),
    );
  }
}

void main() {
  late AppDatabase db;
  late PlannerHarness vm;
  late _Horizon weather;
  final now = DateTime.utc(2026, 11, 10, 16);

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 12; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> start(WidgetTester tester, {DateTime? cloudGapAt}) async {
    tester.view.physicalSize = const Size(800, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      db = AppDatabase(NativeDatabase.memory());
      await CatalogSeeder(DriftTargetRepository(db)).seedIfNeeded();
      await EquipmentSeeder(DriftEquipmentRepository(db)).seedIfNeeded();
      final siteId = await DriftLocationRepository(db).insertLocation(
        domain.LocationProfile(
          id: 0,
          name: 'Ljubljana',
          latitude: 46.05,
          longitude: 14.51,
          elevation: 300,
          timeZoneId: 'Europe/Ljubljana',
        ),
      );
      SharedPreferences.setMockInitialValues({'activeLocationId': siteId});
      final clock = FixedClock(now);
      weather = _Horizon(clock, cloudGapAt: cloudGapAt);
      vm = PlannerHarness(
        DriftTargetRepository(db),
        DriftEquipmentRepository(db),
        weather,
        DriftLocationRepository(db),
        locationService: FakeLocationService(),
        reverseGeocoder: FakeReverseGeocoder(),
        deviceTimeZone: FakeDeviceTimeZone(),
        clock: clock,
        sessionRepository: DriftSessionRepository(db, clock: clock),
      );
      await vm.ready;
    });
    addTearDown(() => tester.runAsync(db.close));
    AppRouter.router.go(AppRouter.weather);
    await tester.pumpWidget(
      MultiProvider(providers: vm.providers, child: const AstroPlanApp()),
    );
    await settle(tester);
    await tester.runAsync(() => vm.conditions.idle);
    await settle(tester);
  }

  final tonight = CalendarDate(2026, 11, 10);
  String key(CalendarDate d, [String suffix = '']) =>
      'weather.night.${d.toIso8601String()}$suffix';

  testWidgets('A3/A5: the night\'s facts first; an hour shows its exact '
      'values; the seeing limitation and a link; the table in Details', (
    tester,
  ) async {
    await start(tester, cloudGapAt: DateTime.utc(2026, 11, 10, 22));
    final s = vm.conditions.nightWeatherSummary!;
    expect(find.byKey(const Key('weather.span')), findsOneWidget);
    expect(
      find.text(
        'Cloud 30 % · Temperature 3 °C · Dew point −1 °C'.replaceAll('−', '-'),
      ),
      findsOneWidget,
    );
    // W2: the unknown cloud value is a gap of 1 h, never 0 %.
    expect(
      tester.widget<Text>(find.byKey(const Key('weather.partial'))).data,
      'Cloud: 1 h without forecast',
    );
    expect(
      tester.widget<Text>(find.byKey(const Key('weather.lead'))).data,
      'Forecast made on the day',
    );
    expect(find.textContaining('Updated'), findsWidgets);
    // The strip: a text alternative, one column per counted row; a tap
    // shows the exact values.
    final handle = tester.ensureSemantics();
    expect(
      find.bySemanticsLabel(RegExp('^Hourly forecast for the dark span: ')),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(RegExp('no forecast|cloud 30 %')),
      findsWidgets,
    );
    handle.dispose();
    expect(find.byKey(const Key('weather.hourDetail')), findsNothing);
    await tester.tap(find.byKey(const Key('weather.hour.1')));
    await settle(tester);
    final detail = tester
        .widget<Text>(find.byKey(const Key('weather.hourDetail')))
        .data!;
    expect(
      detail,
      allOf(
        contains('low 10 %, mid 15 %, high 25 %'),
        contains('humidity 75 %'),
        contains('visibility 24.0 km'),
        contains('gusts up to 20 km/h'),
      ),
    );
    expect(s.slots, isNotEmpty);
    // Q3: the limitation, and a page the user opens.
    expect(find.text(WeatherText.notSeeing), findsOneWidget);
    expect(find.byKey(const Key('weather.clearOutside')), findsOneWidget);
    // Details: the full table and the model.
    expect(find.byKey(const Key('weather.ranges')), findsNothing);
    await tester.ensureVisible(find.byKey(const Key('weather.details')));
    await tester.tap(find.byKey(const Key('weather.details')));
    await settle(tester);
    expect(find.byKey(const Key('weather.ranges')), findsOneWidget);
    expect(find.text('Model: open-meteo / best_match'), findsOneWidget);
    expect(find.textContaining('SNR'), findsNothing);
    expect(find.textContaining('score'), findsNothing);
  });

  testWidgets('A1: one card per night the forecast serves, with its own '
      'coverage and lead; later nights are beyond it; one request', (
    tester,
  ) async {
    await start(tester); // rows until 21:00 UTC on the 12th
    final overview = vm.conditions.forecastNights!;
    expect(weather.calls, 1);
    expect(overview.nights.map((n) => n.eveningDate), [
      tonight,
      tonight.addDays(1),
      tonight.addDays(2),
    ]);
    expect(overview.firstBeyond, tonight.addDays(3));
    final [first, second, third] = overview.nights;
    expect(first.coverage, ForecastCoverage.complete);
    expect(second.coverage, ForecastCoverage.complete);
    expect(third.coverage, ForecastCoverage.partial);
    expect(third.missingAfter, greaterThan(0), reason: 'ends before dawn');
    expect(
      ForecastNightsSection.coverage(third),
      contains('the forecast ends before dawn'),
    );
    for (final n in overview.nights) {
      final coverage = find.byKey(Key(key(n.eveningDate, '.coverage')));
      await tester.ensureVisible(coverage);
      expect(
        tester.widget<Text>(coverage).data,
        ForecastNightsSection.coverage(n),
      );
    }
    expect(
      ForecastNightsSection.coverage(first),
      startsWith('Complete: ${first.summary.totalHours} of '),
    );
    expect([for (final n in overview.nights) n.leadDays], [0, 1, 2]);
    expect(find.textContaining("your plan's night"), findsOneWidget);
    expect(find.byKey(const Key('weather.nights.beyond')), findsOneWidget);
    expect(find.textContaining('16 nights'), findsNothing);
  });

  testWidgets('A6: opening a card changes nothing; Plan this night moves a '
      'never-saved draft', (tester) async {
    await start(tester);
    final next = tonight.addDays(1);
    expect(vm.eveningDate, tonight);
    final card = find.byKey(Key(key(next)));
    await tester.ensureVisible(card);
    await tester.tap(
      find.descendant(of: card, matching: find.byType(ListTile)).first,
    );
    await settle(tester);
    expect(vm.eveningDate, tonight, reason: 'viewing is not adopting');
    expect(find.byKey(Key(key(next, '.plan'))), findsOneWidget);
    await tester.tap(find.byKey(Key(key(next, '.plan'))));
    await settle(tester);
    expect(vm.eveningDate, next);
    expect(find.textContaining('Plan moved to'), findsOneWidget);
  });

  testWidgets('A6: Plan this night copies a saved plan; the saved plan '
      'keeps its night', (tester) async {
    await start(tester);
    await tester.runAsync(() async {
      final target = (await DriftTargetRepository(db).getAllTargets()).first;
      final rig = (await DriftEquipmentRepository(db).getAllEquipment()).first;
      await vm.setTarget(target);
      await vm.setEquipment(rig);
      await vm.plan.idle;
      await vm.saveSession();
    });
    await settle(tester);
    final saved = vm.activeSession!;
    expect(saved.plannedAtUtc, isNotNull);
    final next = tonight.addDays(1);
    final card = find.byKey(Key(key(next)));
    await tester.ensureVisible(card);
    await tester.tap(
      find.descendant(of: card, matching: find.byType(ListTile)).first,
    );
    await settle(tester);
    await tester.tap(find.byKey(Key(key(next, '.plan'))));
    await settle(tester);
    expect(vm.eveningDate, next);
    expect(vm.activeSession?.id, isNot(saved.id), reason: 'a copy');
    final kept = await tester.runAsync(
      () => DriftSessionRepository(db).get(saved.id),
    );
    expect(kept!.eveningDate, tonight, reason: 'never retimed');
    expect(find.textContaining('the saved plan is unchanged'), findsOneWidget);
  });
}
