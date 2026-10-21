// S6.5 (P6.5; UX-06, UX-10; TD-051; ADR-012; ADR-019 §5, §9): the planner
// keeps one factual row each for the night and the forecast; the Night &
// Moon and Weather details hold everything the planner used to show, with
// nothing lost; Tonight's rows open them. Through the real app, with the
// real database and a full forecast.

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/services/catalog_seeder.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/models/planning_preferences.dart';
import 'package:astroplan/domain/models/weather_snapshot.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:astroplan/presentation/shared/app_words.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/fake_device_time_zone.dart';
import '../../../support/fake_location_service.dart';
import '../../../support/fake_reverse_geocoder.dart';
import '../../../support/planner_harness.dart';

/// A whole-night forecast on whole UTC hours, as the provider serves it; or,
/// with [fail], no forecast at all.
class _Weather implements WeatherRepository {
  _Weather(
    this.clock, {
    this.fail = false,
    this.dew = false,
    this.unknownCloudAt,
    this.missingAt,
  });

  final Clock clock;
  final bool fail;

  /// F14 A3: the UTC hour whose row is absent (a gap), if any.
  final int? missingAt;

  /// TD-089: the hour whose total cloud is unknown (null), if any.
  final int? unknownCloudAt;

  /// S9.6: a dew point 0.5 °C under the air (within the 2 °C margin).
  final bool dew;

  @override
  Future<WeatherFetch> fetchSnapshot({
    required double latitude,
    required double longitude,
    required DateTime startUtc,
    required DateTime endUtc,
  }) async {
    if (fail) return const WeatherFetchFailed(WeatherFailure.unavailable);
    final first = DateTime.utc(
      startUtc.year,
      startUtc.month,
      startUtc.day,
      startUtc.hour,
    );
    return WeatherFetched(
      WeatherSnapshot(
        provider: 'open-meteo',
        model: 'best_match',
        fetchedAtUtc: clock.nowUtc(),
        latitude: latitude,
        longitude: longitude,
        hours: [
          for (
            var t = first;
            t.isBefore(endUtc);
            t = t.add(const Duration(hours: 1))
          )
            if (t.hour != missingAt)
              WeatherHour(
                timeUtc: t,
                cloudCoverPct: t.hour == unknownCloudAt ? null : 40,
                cloudCoverLowPct: 10,
                cloudCoverMidPct: 20,
                cloudCoverHighPct: 40,
                precipitationProbabilityPct: 5,
                windSpeedKmh: 8,
                windGustsKmh: 15,
                temperatureC: 2,
                dewPointC: dew ? 1.5 : -3,
                relativeHumidityPct: 70,
                visibilityM: 24000,
              ),
        ],
      ),
    );
  }
}

void main() {
  late AppDatabase db;
  late PlannerHarness vm;

  Future<void> start(
    WidgetTester tester,
    String location, {
    bool fail = false,
    bool dew = false,
    int? unknownCloudAt,
    int? missingAt,
    domain.LocationProfile? site,
    DateTime? now,
  }) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      db = AppDatabase(NativeDatabase.memory());
      await CatalogSeeder(DriftTargetRepository(db)).seedIfNeeded();
      await EquipmentSeeder(DriftEquipmentRepository(db)).seedIfNeeded();
      final siteId = await DriftLocationRepository(db).insertLocation(
        site ??
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
      final clock = FixedClock(now ?? DateTime.utc(2026, 11, 10, 16));
      vm = PlannerHarness(
        DriftTargetRepository(db),
        DriftEquipmentRepository(db),
        _Weather(
          clock,
          fail: fail,
          dew: dew,
          unknownCloudAt: unknownCloudAt,
          missingAt: missingAt,
        ),
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
    AppRouter.router.go(location);
    await tester.pumpWidget(
      MultiProvider(providers: vm.providers, child: const AstroPlanApp()),
    );
    await settle(tester);
    await tester.runAsync(() => vm.conditions.idle);
    await settle(tester);
  }

  Future<void> open(WidgetTester tester, Finder row) async {
    await tester.ensureVisible(row);
    await settle(tester);
    await tester.tap(row);
    await settle(tester);
  }

  final nightRow = find.byKey(const Key('planner.night'));
  final weatherRow = find.byKey(const Key('planner.weather'));

  testWidgets('the planner keeps one factual row for the night and one for '
      'the forecast', (tester) async {
    await start(tester, AppRouter.session());
    expect(
      find.descendant(
        of: nightRow,
        matching: find.textContaining('Dark (Sun below −18°): '),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: nightRow,
        matching: find.byKey(const Key('nightSummary.moon')),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: weatherRow,
        matching: find.textContaining('Cloud 40 % · Updated'),
      ),
      findsOneWidget,
    );
    // The full forecast and the night's timeline are no longer on the
    // planner; the sky darkness stays.
    expect(find.byKey(const Key('weather.hours')), findsNothing);
    expect(find.text(AppWords.astronomicalDusk), findsNothing);
    expect(find.text('Sky darkness'), findsOneWidget);
  });

  testWidgets('Night & Moon holds the dark span at the user\'s limit, the '
      'twilight names, the Moon, and the zone rule once', (tester) async {
    await start(tester, AppRouter.session());
    await open(tester, nightRow);
    expect(find.text('Night & Moon'), findsOneWidget);
    expect(find.textContaining('Night of '), findsWidgets);
    // Hybrid's one context line names the zone once; a screen reader hears
    // the full zone rule.
    final handle = tester.ensureSemantics();
    expect(find.bySemanticsLabel(RegExp(r'\. Times in ')), findsOneWidget);
    handle.dispose();
    expect(find.byKey(const Key('detail.context')), findsOneWidget);
    // Hybrid: darkness belongs to Night, Moon facts to the reachable Moon
    // tab. Each fact is presented once on its own surface.
    expect(find.byKey(const Key('nightSummary.dark')), findsOneWidget);
    expect(find.textContaining('Dark (Sun below −18°): '), findsOneWidget);
    expect(find.byKey(const Key('nightSummary.moon')), findsNothing);
    expect(find.byKey(const Key('night.dark')), findsNothing);
    expect(find.byKey(const Key('sky.moonUp')), findsNothing);
    await open(tester, find.text('Sun & twilight'));
    expect(find.text('Sun and twilight'), findsOneWidget);
    expect(find.text('Moon'), findsOneWidget);
    for (final name in [
      'Sunset',
      AppWords.civilDusk,
      AppWords.nauticalDusk,
      AppWords.astronomicalDusk,
      AppWords.astronomicalDawn,
      AppWords.nauticalDawn,
      AppWords.civilDawn,
      'Sunrise',
    ]) {
      expect(find.text(name), findsOneWidget, reason: name);
    }
    await tester.tap(find.widgetWithText(Tab, 'Moon'));
    await settle(tester);
    await open(tester, find.text('Moon details'));
    expect(find.textContaining('Moon up'), findsOneWidget);
    expect(find.textContaining('Illumination at midnight'), findsOneWidget);
    await tester.tap(find.widgetWithText(Tab, 'Night'));
    await settle(tester);

    // TD-051: the span follows the user's darkness limit.
    await tester.runAsync(
      () => vm.setPlanningPreferences(
        vm.planningPreferences.copyWith(darknessLimit: DarknessLimit.nautical),
      ),
    );
    await settle(tester);
    expect(
      find.textContaining('Dark (Sun below −12°): '),
      findsOneWidget,
      reason: 'the summary, once (TD-078)',
    );
  });

  testWidgets('Weather holds the whole forecast: hours, ranges, model, age, '
      'attribution and refresh', (tester) async {
    await start(tester, AppRouter.session());
    await open(tester, weatherRow);
    expect(find.text('Weather'), findsWidgets);
    expect(find.byKey(const Key('conditions.page.2')), findsOneWidget);
    expect(find.byKey(const Key('weather.span')), findsOneWidget);
    expect(find.byKey(const Key('weather.hours')), findsOneWidget);
    expect(find.byKey(const Key('weather.attribution')), findsOneWidget);
    expect(find.byKey(const Key('weather.refresh')), findsOneWidget);
    expect(find.textContaining('Updated'), findsWidgets);
    // F14 A3: the night's facts first; the full table, model and source in
    // Details, one tap away.
    expect(find.byKey(const Key('weather.facts')), findsOneWidget);
    expect(find.byKey(const Key('weather.ranges')), findsNothing);
    await tester.ensureVisible(find.byKey(const Key('weather.details')));
    await tester.tap(find.byKey(const Key('weather.details')));
    await settle(tester);
    expect(find.byKey(const Key('weather.ranges')), findsOneWidget);
    expect(find.text('Model: open-meteo / best_match'), findsOneWidget);
  });

  testWidgets('without a forecast the row says why, and the detail offers '
      'Retry', (tester) async {
    await start(tester, AppRouter.session(), fail: true);
    expect(
      find.descendant(
        of: weatherRow,
        matching: find.text(
          'No forecast. Offline or the service did not answer.',
        ),
      ),
      findsOneWidget,
    );
    await open(tester, weatherRow);
    expect(find.text('No forecast.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  // S9.6: the detail screens' secondary presentation.
  testWidgets('Weather: a cloud bar per forecast hour under its number; dew '
      'risk marked by an icon, not colour alone; no "Tap to set location"', (
    tester,
  ) async {
    await start(tester, AppRouter.weather, dew: true);
    final bars = find.byKey(const Key('weather.cloudBar'));
    expect(bars, findsWidgets);
    for (final bar in tester.widgetList<FractionallySizedBox>(bars)) {
      expect(bar.heightFactor, 0.4); // 40 % cloud
    }
    expect(
      find.bySemanticsLabel(RegExp('dew risk')),
      findsWidgets,
      reason: 'every hour is within the dew margin',
    );
    expect(find.text('Tap to set location'), findsNothing);
  });

  // H2 (G1-S11-01): an hour's button label replaces the InkWell's own
  // semantics, so the tap must be on the labelled node itself.
  testWidgets('Weather: each hour button can be activated by a screen '
      'reader', (tester) async {
    final handle = tester.ensureSemantics();
    await start(tester, AppRouter.weather);
    final hours = find.bySemanticsLabel(RegExp(r'Shows its exact values$'));
    expect(hours, findsWidgets);
    for (final e in hours.evaluate()) {
      final data = tester
          .getSemantics(find.byWidget(e.widget))
          .getSemanticsData();
      expect(data.hasAction(SemanticsAction.tap), isTrue, reason: data.label);
      expect(data.flagsCollection.isButton, isTrue);
    }
    handle.dispose();
  });

  testWidgets('Night & Moon: the twilights as a bar from sunset to sunrise, '
      'deepest in the middle, with the times as its text', (tester) async {
    await start(tester, AppRouter.nightMoon);
    final sun = find.byKey(const PageStorageKey('conditions.sun'));
    await tester.ensureVisible(sun);
    await tester.tap(sun);
    await settle(tester);
    expect(find.byKey(const Key('night.twilightBar')), findsOneWidget);
    // Seven bands, keyed by position and depth: 1, 2, 3, 4, 3, 2, 1.
    for (final (i, depth) in [1, 2, 3, 4, 3, 2, 1].indexed) {
      expect(find.byKey(Key('night.band.$i.$depth')), findsOneWidget);
    }
    expect(find.text(AppWords.astronomicalDusk), findsOneWidget);
  });

  // TD-089 (S9V-01): the visuals' unknown and empty states.
  testWidgets('Weather: an hour with unknown cloud draws no bar, never an '
      'empty or a full one', (tester) async {
    await start(tester, AppRouter.weather, unknownCloudAt: 22);
    final slots = vm.conditions.nightWeatherSummary!.slots;
    final known = slots.where((s) => s.hour?.cloudCoverPct != null).length;
    expect(known, lessThan(slots.length), reason: 'one hour is unknown');
    expect(find.byKey(const Key('weather.cloudBar')), findsNWidgets(known));
  });

  // F14 A3: a gap is its own "no forecast" column; the preceding-hour
  // values of an hour only partly in the dark span carry "*"; the wind/gust
  // and precipitation rows are labelled by the legend and the note.
  testWidgets('Weather strip: a missing hour says "no forecast"; a partial '
      'hour is starred; wind/gust and precipitation rows with their legend', (
    tester,
  ) async {
    // 10 Nov 2026, Ljubljana: dark from about 17:25 UTC, so 17:00–18:00 is
    // only partly dark; the 22:00 UTC row is absent.
    await start(tester, AppRouter.weather, missingAt: 22);
    await tester.ensureVisible(find.byKey(const Key('weather.details')));
    await tester.tap(find.byKey(const Key('weather.details')));
    await settle(tester);
    final slots = vm.conditions.nightWeatherSummary!.slots;
    Finder column(int i) => find.byKey(Key('weather.hour.$i'));
    Finder inColumn(int i, String text) =>
        find.descendant(of: column(i), matching: find.text(text));

    // The gap: exactly one column, at 22:00 UTC, and it says so.
    final gap = slots.indexWhere((s) => s.timeUtc.hour == 22);
    expect(slots[gap].hour, isNull);
    expect(find.text('no\nforecast'), findsNWidgets(2));
    expect(inColumn(gap, 'no\nforecast'), findsOneWidget);
    expect(inColumn(gap, '8/15'), findsNothing, reason: 'never invented');
    final handle = tester.ensureSemantics();
    expect(
      tester.getSemantics(column(gap)).label,
      allOf(contains('no forecast'), isNot(contains('cloud'))),
    );
    expect(
      tester.getSemantics(column(gap + 1)).label,
      contains('cloud 40 %'),
      reason: 'the next hour has its row',
    );
    handle.dispose();
    await tester.ensureVisible(column(gap));
    await tester.tap(column(gap));
    await settle(tester);
    expect(
      tester
          .widget<Text>(find.byKey(const Key('weather.tableHourDetail')))
          .data,
      endsWith(': no forecast for this hour.'),
    );

    // The first column: 18:00 UTC, whose preceding hour (17:00, 18:00] is
    // only partly dark: its gust and precipitation chance are starred.
    expect(slots.first.timeUtc, DateTime.utc(2026, 11, 10, 18));
    expect(slots.first.partial, isTrue);
    expect(inColumn(0, '8/15*'), findsOneWidget);
    expect(inColumn(0, '5*'), findsOneWidget);
    // A whole dark hour: the same values without the star.
    expect(inColumn(2, '8/15'), findsOneWidget);
    expect(inColumn(2, '5'), findsOneWidget);
    expect(inColumn(2, '8/15*'), findsNothing);
    // Only the dusk hour is partial here: one starred gust, one starred
    // precipitation chance in the whole strip.
    expect(find.text('8/15*'), findsOneWidget);
    expect(find.text('5*'), findsOneWidget);

    // The legend names each row and its unit; the note explains both.
    for (final label in [
      'cloud %',
      'temp. °C',
      'dew pt. °C',
      'wind/gust km/h',
      'precip. %',
    ]) {
      expect(
        find.descendant(
          of: find.byKey(const Key('weather.tableHours')),
          matching: find.text(label),
        ),
        findsOneWidget,
        reason: label,
      );
    }
    expect(
      tester.widget<Text>(find.byKey(const Key('weather.precipNote'))).data,
      'Precipitation and gusts are for the hour before each time; '
      '* marks an hour only partly in the dark span.',
    );
  });

  testWidgets('Night & Moon: a night the Sun never leaves has no twilight '
      'bar; the table still says so', (tester) async {
    await start(
      tester,
      AppRouter.nightMoon,
      site: domain.LocationProfile(
        id: 0,
        name: 'Tromsø',
        latitude: 69.65,
        longitude: 18.96,
        elevation: 10,
        timeZoneId: 'Europe/Oslo',
      ),
      now: DateTime.utc(2026, 6, 21, 12),
    );
    await open(tester, find.text('Sun & twilight'));
    expect(find.byKey(const Key('night.twilightBar')), findsNothing);
    expect(find.byKey(const Key('night.timelineTitle')), findsOneWidget);
    expect(find.text('not tonight'), findsWidgets);
  });

  testWidgets("Tonight's Night, Moon and Weather rows open the details", (
    tester,
  ) async {
    await start(tester, AppRouter.tonight);
    await open(tester, find.byKey(const Key('tonight.night')));
    expect(find.text('Night & Moon'), findsOneWidget);
    AppRouter.router.go(AppRouter.tonight);
    await settle(tester);
    await open(tester, find.byKey(const Key('tonight.moon')));
    expect(find.text('Night & Moon'), findsOneWidget);
    AppRouter.router.go(AppRouter.tonight);
    await settle(tester);
    await open(tester, find.byKey(const Key('tonight.weather')));
    expect(find.byKey(const Key('conditions.page.2')), findsOneWidget);
  });
}

/// Pumps fixed frames with real-time gaps (database work; TASK 12.2).
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump(const Duration(milliseconds: 200));
  }
}
