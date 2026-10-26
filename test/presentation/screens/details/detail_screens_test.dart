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
import 'package:astroplan/presentation/viewmodels/night_browser_viewmodel.dart';
import 'package:astroplan/domain/services/night_view.dart';
import 'package:astroplan/core/units/display_units.dart';
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
    // plan.js night rows: "7 h 30 min dark · 21:15–04:45", the Moon below.
    expect(
      find.descendant(of: nightRow, matching: find.textContaining(' dark · ')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: nightRow, matching: find.textContaining('%')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: weatherRow,
        matching: find.text('Cloud 40% in the dark'),
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
    // conditions.js nightBody: the dark span with the limit it rests on.
    expect(find.byKey(const Key('nightMoon.answerSpan')), findsOneWidget);
    expect(
      find.textContaining('Sun limit −18°', findRichText: true),
      findsOneWidget,
    );
    expect(find.byKey(const Key('night.dark')), findsNothing);
    expect(find.byKey(const Key('sky.moonUp')), findsNothing);
    await open(tester, find.text('Sun & twilight'));
    expect(find.byKey(const Key('nightMoon.sunEvents')), findsOneWidget);
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
    expect(find.text('Moon above horizon'), findsWidgets);
    expect(find.textContaining('illuminated at midnight'), findsOneWidget);
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
      find.textContaining('Sun limit −12°', findRichText: true),
      findsOneWidget,
      reason: 'the answer, once (TD-078)',
    );
  });

  testWidgets('Weather holds the whole forecast: the dark-span answer, '
      'statistics, model, age, attribution and refresh', (tester) async {
    await start(tester, AppRouter.session());
    await open(tester, weatherRow);
    expect(find.text('Weather'), findsWidgets);
    expect(find.byKey(const Key('conditions.page.2')), findsOneWidget);
    expect(find.byKey(const Key('weather.span')), findsOneWidget);
    expect(find.byKey(const Key('weather.rows')), findsOneWidget);
    expect(find.byKey(const Key('weather.refresh')), findsOneWidget);
    expect(find.byKey(const Key('weather.updated')), findsOneWidget);
    // F14 A3: the night's answer first; the full table, model and source in
    // Forecast details, one tap away.
    expect(find.byKey(const Key('weather.facts')), findsOneWidget);
    expect(find.byKey(const Key('weather.table')), findsNothing);
    await tester.ensureVisible(find.byKey(const Key('weather.details')));
    await tester.tap(find.text('Forecast details'));
    await settle(tester);
    expect(find.byKey(const Key('weather.table')), findsOneWidget);
    expect(find.byKey(const Key('weather.attribution')), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('weather.model'))).data,
      startsWith('Model: open-meteo / best_match.'),
    );
  });

  testWidgets('without a forecast the row says why, and the detail offers '
      'Retry', (tester) async {
    await start(tester, AppRouter.session(), fail: true);
    expect(
      find.descendant(
        of: weatherRow,
        matching: find.text('Offline or the service did not answer.'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: weatherRow,
        matching: find.text('Forecast unavailable'),
      ),
      findsOneWidget,
    );
    await open(tester, weatherRow);
    expect(find.text('Forecast unavailable'), findsOneWidget);
    expect(find.byKey(const Key('weather.unavailable')), findsOneWidget);
    expect(find.text('Retry forecast'), findsOneWidget);
  });

  // S9.6: the detail screens' secondary presentation. Hybrid: the dew
  // caution is words, not colour alone; the cloud range is a number.
  testWidgets('Weather: cloud as a range with its coverage; the dew caution '
      'in words, not colour alone; no "Tap to set location"', (tester) async {
    await start(tester, AppRouter.weather, dew: true);
    final rows = find.byKey(const Key('weather.rows'));
    expect(
      find.descendant(of: rows, matching: find.text('40%')),
      findsOneWidget,
    );
    final s = vm.conditions.nightWeatherSummary!;
    expect(
      find.descendant(
        of: rows,
        matching: find.text('${s.totalHours}/${s.totalHours} known'),
      ),
      findsWidgets,
    );
    expect(
      tester.widget<Text>(find.byKey(const Key('weather.dew'))).data,
      allOf(
        startsWith('${s.dewRiskHours} of ${s.dewKnownHours} samples'),
        endsWith('A caution, not a condensation forecast.'),
      ),
      reason: 'every hour is within the dew margin',
    );
    expect(find.text('Tap to set location'), findsNothing);
  });

  // H2 (G1-S11-01): an hour's button label replaces the InkWell's own
  // semantics, so the tap must be on the labelled node itself.
  testWidgets('Weather: each chart hour button can be activated by a screen '
      'reader', (tester) async {
    final handle = tester.ensureSemantics();
    await start(tester, AppRouter.weather);
    await tester.runAsync(
      () => vm.vms.displaySettings.setWeatherView(WeatherView.charts),
    );
    await settle(tester);
    final hours = find.bySemanticsLabel(RegExp(r'^Select '));
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

  // Hybrid (night-ui.js legend): the twilights are the rail's sky, from
  // daylight through each twilight to dark and back, named in the reading
  // key; the Sun events list their times.
  testWidgets('Night & Moon: the twilights in the rail, deepest in the '
      'middle, named in the reading key, with the times as text', (
    tester,
  ) async {
    await start(tester, AppRouter.nightMoon);
    final browser = Provider.of<NightBrowserViewModel>(
      tester.element(find.byKey(const Key('nightMoon.bar'))),
      listen: false,
    );
    final states = <SkyState>[];
    for (final s in browser.view.segments) {
      if (s.sky != SkyState.daylight &&
          (states.isEmpty || states.last != s.sky)) {
        states.add(s.sky);
      }
    }
    expect(states, [
      SkyState.civil,
      SkyState.nautical,
      SkyState.astronomical,
      SkyState.dark,
      SkyState.astronomical,
      SkyState.nautical,
      SkyState.civil,
    ]);
    await open(tester, find.text('Read the time browser'));
    for (final name in [
      'Civil twilight',
      'Nautical twilight',
      'Astronomical twilight',
    ]) {
      expect(find.text(name), findsWidgets, reason: name);
    }
    await open(tester, find.text('Sun & twilight'));
    expect(find.text(AppWords.astronomicalDusk), findsOneWidget);
  });

  // TD-089 (S9V-01): the visuals' unknown and empty states. Hybrid: an
  // unknown cloud value is counted out of the range, never drawn or read
  // as 0 % or 100 %.
  testWidgets('Weather: an hour with unknown cloud is unknown, never an '
      'empty or a full value', (tester) async {
    await start(tester, AppRouter.weather, unknownCloudAt: 22);
    final slots = vm.conditions.nightWeatherSummary!.slots;
    final eligible = slots.where((s) => s.instant).length;
    final known = slots
        .where((s) => s.instant && s.hour?.cloudCoverPct != null)
        .length;
    expect(known, lessThan(eligible), reason: 'one hour is unknown');
    final rows = find.byKey(const Key('weather.rows'));
    expect(
      find.descendant(of: rows, matching: find.text('$known/$eligible known')),
      findsOneWidget,
    );
    expect(find.descendant(of: rows, matching: find.text('40%')), findsOne);
    expect(
      find.text(
        '$known of $eligible hourly cloud samples known · gaps stay '
        'unknown.',
      ),
      findsOneWidget,
    );
    // The hour itself says Unknown.
    final unknown = slots.indexWhere((s) => s.timeUtc.hour == 22);
    final slider = tester.widget<Slider>(
      find.byKey(const Key('weather.hourSlider')),
    );
    slider.onChanged!(unknown.toDouble());
    await settle(tester);
    await tester.ensureVisible(find.text('Hourly values'));
    await tester.tap(find.text('Hourly values'));
    await settle(tester);
    final hour = find.byKey(const Key('weather.hourDetails'));
    expect(
      find.descendant(of: hour, matching: find.text('Unknown')),
      findsWidgets,
    );
    expect(find.descendant(of: hour, matching: find.text('0%')), findsNothing);
  });

  // F14 A3: a gap is its own row with no values; the preceding-hour values
  // of an hour only partly in the dark span are starred; the note explains
  // both, and every column names its unit.
  testWidgets('Weather table: a missing hour has no values; a partial hour '
      'is starred; columns with units and the note', (tester) async {
    // 10 Nov 2026, Ljubljana: dark from about 17:25 UTC, so 17:00–18:00 is
    // only partly dark; the 22:00 UTC row is absent.
    await start(tester, AppRouter.weather, missingAt: 22);
    final slots = vm.conditions.nightWeatherSummary!.slots;
    final gap = slots.indexWhere((s) => s.timeUtc.hour == 22);
    expect(slots[gap].hour, isNull);
    expect(slots.first.timeUtc, DateTime.utc(2026, 11, 10, 18));
    expect(slots.first.partial, isTrue);

    // The inspected gap says so.
    final slider = tester.widget<Slider>(
      find.byKey(const Key('weather.hourSlider')),
    );
    slider.onChanged!(gap.toDouble());
    await settle(tester);
    await tester.ensureVisible(find.text('Hourly values'));
    await tester.tap(find.text('Hourly values'));
    await settle(tester);
    expect(
      find.text('No sample at this hour. Missing values are unknown.'),
      findsOneWidget,
    );

    await tester.ensureVisible(find.byKey(const Key('weather.details')));
    await tester.tap(find.text('Forecast details'));
    await settle(tester);
    final table = tester.widget<Table>(
      find.descendant(
        of: find.byKey(const Key('weather.table')),
        matching: find.byWidgetPredicate((widget) => widget is Table),
      ),
    );
    List<String> row(int i) => [
      for (final cell in table.children[i + 1].children)
        ((cell as Padding).child! as Text).data!,
    ];
    // The gap: every value is "—", never invented.
    expect(row(gap).skip(1), everyElement(matches(r'^—( / —)*$')));
    // The dusk hour: starred, its gust and precipitation chance kept.
    expect(row(0).first, endsWith(' *'));
    expect(row(0)[5], '8 / 15');
    expect(row(0)[6], '5');
    // A whole dark hour: no star; only the dusk hour is partial here.
    expect(row(2).first, isNot(endsWith(' *')));
    expect(
      [for (var i = 0; i < slots.length; i++) row(i).first]
          .where((t) => t.endsWith(' *')),
      hasLength(1),
    );
    // Every column names its unit.
    expect(
      [
        for (final cell in table.children.first.children)
          ((cell as Padding).child! as Text).data!,
      ],
      containsAll([
        'Cloud %',
        'Temp °C',
        'Dew °C',
        'Wind / gust km/h',
        'Precip %',
      ]),
    );
    expect(
      tester.widget<Text>(find.byKey(const Key('weather.precipNote'))).data,
      contains('* marks partial dark-time overlap'),
    );
  });

  testWidgets('Night & Moon: a night the Sun never leaves says its '
      'events are not reached', (tester) async {
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
    expect(find.byKey(const Key('nightMoon.sunEvents')), findsOneWidget);
    expect(find.text('Not reached'), findsWidgets);
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
