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
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/models/session.dart';
import 'package:astroplan/domain/models/session_snapshot.dart';
import 'package:astroplan/domain/models/weather_snapshot.dart';
import 'package:astroplan/domain/repositories/storage_failure.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/domain/services/forecast_overview.dart';
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:astroplan/presentation/shared/night_text.dart';
import 'package:astroplan/presentation/widgets/forecast_nights_section.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  _Horizon(
    this.clock, {
    this.cloudGapAt,
    this.rows,
    this.fetchedAgo = Duration.zero,
  });

  static const hours = 70;
  final Clock clock;
  final DateTime? cloudGapAt;

  /// The rows' UTC instants instead of the default 70 hours from 00:00 UTC.
  final List<DateTime> Function(DateTime todayUtc)? rows;

  /// How long before the clock's now the snapshot was made (a stale one).
  final Duration fetchedAgo;
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
        fetchedAtUtc: now.subtract(fetchedAgo),
        latitude: latitude,
        longitude: longitude,
        hours: [
          for (final t
              in rows?.call(today) ??
                  [
                    for (var h = 0; h < hours; h++)
                      today.add(Duration(hours: h)),
                  ])
            () {
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

/// The real sessions; [failSave] makes Save fail, as a full disk would.
class _Sessions extends DriftSessionRepository {
  _Sessions(super.db, {super.clock});

  bool failSave = false;

  @override
  Future<Session> savePlan(
    int id,
    SessionPlan plan,
    SessionSnapshot snapshot,
  ) => failSave
      ? Future.error(const StorageFailure('disk full'))
      : super.savePlan(id, plan, snapshot);
}

void main() {
  late AppDatabase db;
  late PlannerHarness vm;
  late _Horizon weather;
  late _Sessions sessions;
  final now = DateTime.utc(2026, 11, 10, 16);

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 12; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> start(
    WidgetTester tester, {
    DateTime? cloudGapAt,
    List<DateTime> Function(DateTime todayUtc)? rows,
    Duration fetchedAgo = Duration.zero,
    DateTime? at,
    ({String name, double lat, double lon, String zone})? site,
  }) async {
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
          name: site?.name ?? 'Ljubljana',
          latitude: site?.lat ?? 46.05,
          longitude: site?.lon ?? 14.51,
          elevation: 300,
          timeZoneId: site?.zone ?? 'Europe/Ljubljana',
        ),
      );
      SharedPreferences.setMockInitialValues({'activeLocationId': siteId});
      final clock = FixedClock(at ?? now);
      weather = _Horizon(
        clock,
        cloudGapAt: cloudGapAt,
        rows: rows,
        fetchedAgo: fetchedAgo,
      );
      vm = PlannerHarness(
        DriftTargetRepository(db),
        DriftEquipmentRepository(db),
        weather,
        DriftLocationRepository(db),
        locationService: FakeLocationService(),
        reverseGeocoder: FakeReverseGeocoder(),
        deviceTimeZone: FakeDeviceTimeZone(),
        clock: clock,
        sessionRepository: sessions = _Sessions(db, clock: clock),
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

  /// The coverage line of the card for [d], as rendered.
  String coverageOf(WidgetTester tester, CalendarDate d) =>
      tester.widget<Text>(find.byKey(Key(key(d, '.coverage')))).data!;

  testWidgets('A1: a forecast that starts after dusk says "starts later" '
      'with its own counts', (tester) async {
    // Ljubljana, 10 Nov 2026: dark (Sun below −18°) from about 17:25 to
    // 04:15 UTC, so the whole-hour instants 18:00–04:00 UTC: 11. Rows from
    // 20:00 UTC leave 18:00 and 19:00 without a forecast.
    await start(
      tester,
      rows: (today) => [
        for (var h = 20; h < 70; h++) today.add(Duration(hours: h)),
      ],
    );
    expect(
      coverageOf(tester, tonight),
      'Partial: 9 of 11 dark hours (the forecast starts later)',
    );
    expect(
      coverageOf(tester, tonight.addDays(1)),
      'Complete: 11 of 11 dark hours',
    );
  });

  testWidgets('A1: rows around a night that miss its dark span: "No '
      'forecast for the dark hours", never 0 %', (tester) async {
    await start(
      tester,
      rows: (today) => [
        for (var h = 0; h <= 12; h++) today.add(Duration(hours: h)),
        today.add(const Duration(hours: 36)), // noon on the 11th
      ],
    );
    expect(vm.conditions.forecastNights!.nights, hasLength(1));
    expect(coverageOf(tester, tonight), 'No forecast for the dark hours');
    final card = find.byKey(Key(key(tonight)));
    expect(
      find.descendant(of: card, matching: find.textContaining('Cloud ')),
      findsNothing,
      reason: 'no cloud range without a covered hour',
    );
    expect(find.byKey(const Key('weather.nights.beyond')), findsOneWidget);
  });

  testWidgets('A1: a June night at 60° N: "No dark time this night"', (
    tester,
  ) async {
    final june = CalendarDate(2026, 6, 20);
    await start(
      tester,
      at: DateTime.utc(2026, 6, 20, 12),
      site: (name: 'Helsinki', lat: 60.17, lon: 24.94, zone: 'Europe/Helsinki'),
    );
    final nights = vm.conditions.forecastNights!.nights;
    expect(nights, isNotEmpty);
    for (final n in nights) {
      expect(coverageOf(tester, n.eveningDate), 'No dark time this night');
    }
    expect(nights.first.eveningDate, june);
  });

  testWidgets('A1: a stale forecast: each card dates it from the fetch, '
      'never "on the day"; the stale label is shown once above', (
    tester,
  ) async {
    await start(tester, fetchedAgo: const Duration(days: 2));
    expect(
      find.text('Stale forecast: updated 48 h ago. Refresh to update.'),
      findsOneWidget,
    );
    for (final (i, lead) in [
      'Forecast made 2 days ahead',
      'Forecast made 3 days ahead',
    ].indexed) {
      final card = find.byKey(Key(key(tonight.addDays(i))));
      await tester.ensureVisible(card);
      expect(
        find.descendant(of: card, matching: find.text(lead)),
        findsOneWidget,
      );
    }
    expect(find.text('Forecast made on the day'), findsNothing);
  });

  testWidgets('A5: "Look at Clear Outside" launches the site\'s page, '
      'outside the app', (tester) async {
    const channel = MethodChannel('plugins.flutter.io/url_launcher');
    final calls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      call,
    ) async {
      calls.add(call);
      return true;
    });
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        null,
      ),
    );
    await start(tester);
    expect(calls, isEmpty, reason: 'nothing opens without a tap');
    final button = find.byKey(const Key('weather.clearOutside'));
    await tester.ensureVisible(button);
    await tester.tap(button);
    await settle(tester);
    final launches = calls.where((c) => c.method == 'launch').toList();
    expect(launches, hasLength(1));
    final args = launches.single.arguments as Map;
    expect(args['url'], 'https://clearoutside.com/forecast/46.05/14.51');
    expect(args['useWebView'], isFalse, reason: 'an external application');
  });

  // F14 A6, F15 A2, F18 A3 (D9 A; UXA-C3): "Plan this night" on a saved
  // plan with unsaved changes asks Save · Discard · Cancel first; Save or
  // Discard then copies, Cancel and a failed Save change nothing.
  group('D9: Plan this night on a saved, changed plan', () {
    final unsaved = find.text('Unsaved changes');
    final next = tonight.addDays(1);
    final extra = CaptureBlock(
      frameType: FrameType.light,
      filterName: 'Ha',
      exposureTimeSeconds: 300,
      frameCount: 7,
    );

    /// A saved plan for tonight, then changed (one more block, unsaved):
    /// the row as saved, and as stored after the change.
    Future<({Session saved, Session changed})> savedAndChanged(
      WidgetTester tester,
    ) async {
      await start(tester);
      final rows = (await tester.runAsync(() async {
        final target = (await DriftTargetRepository(db).getAllTargets()).first;
        final rig = (await DriftEquipmentRepository(
          db,
        ).getAllEquipment()).first;
        await vm.setTarget(target);
        await vm.setEquipment(rig);
        await vm.plan.idle;
        final id = (await vm.saveSession()).id;
        final saved = (await sessions.get(id))!;
        await vm.addCaptureBlock(extra);
        await vm.plan.idle;
        return (saved: saved, changed: (await sessions.get(id))!);
      }))!;
      await settle(tester);
      expect(rows.saved.status, SessionStatus.planned);
      expect(rows.saved.blocks.any((b) => b.frameCount == 7), isFalse);
      expect(rows.changed.blocks.last.frameCount, 7);
      expect(vm.plan.hasUnsavedChanges, isTrue);
      return rows;
    }

    Future<void> planNext(WidgetTester tester) async {
      final card = find.byKey(Key(key(next)));
      await tester.ensureVisible(card);
      await tester.tap(
        find.descendant(of: card, matching: find.byType(ListTile)).first,
      );
      await settle(tester);
      await tester.tap(find.byKey(Key(key(next, '.plan'))));
      await settle(tester);
      expect(unsaved, findsOneWidget, reason: 'asks before copying');
    }

    Future<int> rows(WidgetTester tester) async =>
        (await tester.runAsync(() => db.select(db.sessionLogs).get()))!.length;

    Future<Session> stored(WidgetTester tester, int id) async =>
        (await tester.runAsync(() => sessions.get(id)))!;

    testWidgets('Save saves the change, then copies; the saved plan keeps '
        'its night', (tester) async {
      final (:saved, changed: _) = await savedAndChanged(tester);
      final was = saved;
      final before = await rows(tester);
      await planNext(tester);
      await tester.tap(find.byKey(const Key('unsaved.save')));
      await settle(tester);
      await tester.runAsync(() => vm.plan.idle);
      final kept = await stored(tester, was.id);
      expect(kept.eveningDate, tonight, reason: 'never retimed');
      expect(kept.status, SessionStatus.planned);
      expect(kept.blocks.last.frameCount, 7, reason: 'saved as changed');
      expect(vm.eveningDate, next);
      expect(vm.activeSession!.id, isNot(was.id), reason: 'a copy');
      expect(await rows(tester), before + 1);
      expect(
        find.textContaining('the saved plan is unchanged'),
        findsOneWidget,
      );
    });

    testWidgets('Discard restores the saved plan, then copies', (tester) async {
      final (:saved, changed: _) = await savedAndChanged(tester);
      final was = saved;
      final before = await rows(tester);
      await planNext(tester);
      await tester.tap(find.byKey(const Key('unsaved.discard')));
      await settle(tester);
      await tester.runAsync(() => vm.plan.idle);
      final kept = await stored(tester, was.id);
      expect(kept.eveningDate, tonight);
      expect(kept.status, SessionStatus.planned, reason: 'reverted');
      expect(kept.blocks.any((b) => b.frameCount == 7), isFalse);
      expect(kept.blocks.length, was.blocks.length);
      expect(kept.planSnapshot!.json, was.planSnapshot!.json);
      expect(kept.plannedAtUtc, was.plannedAtUtc);
      expect(vm.eveningDate, next);
      expect(vm.activeSession!.id, isNot(was.id), reason: 'a copy');
      expect(await rows(tester), before + 1);
      expect(
        find.textContaining('the saved plan is unchanged'),
        findsOneWidget,
      );
    });

    testWidgets('Cancel: nothing changes', (tester) async {
      final (:saved, :changed) = await savedAndChanged(tester);
      final was = saved;
      final before = await rows(tester);
      await planNext(tester);
      await tester.tap(find.byKey(const Key('unsaved.cancel')));
      await settle(tester);
      await tester.runAsync(() => vm.plan.idle);
      expect(unsaved, findsNothing);
      expect(vm.eveningDate, tonight);
      expect(vm.activeSession!.id, was.id);
      expect(vm.captureBlocks.last.frameCount, 7, reason: 'the change stays');
      expect(vm.plan.hasUnsavedChanges, isTrue);
      final kept = await stored(tester, was.id);
      expect(kept.eveningDate, tonight);
      expect(kept.status, changed.status, reason: 'still Saved · changed');
      expect(kept.blocks.length, changed.blocks.length);
      expect(kept.planSnapshot!.json, was.planSnapshot!.json);
      expect(kept.plannedAtUtc, was.plannedAtUtc);
      expect(await rows(tester), before, reason: 'no copy');
      expect(find.textContaining('Copy made'), findsNothing);
    });

    testWidgets('a failing Save stops the copy and says so', (tester) async {
      final (:saved, :changed) = await savedAndChanged(tester);
      final was = saved;
      final before = await rows(tester);
      sessions.failSave = true;
      await planNext(tester);
      await tester.tap(find.byKey(const Key('unsaved.save')));
      await settle(tester);
      await tester.runAsync(() => vm.plan.idle);
      expect(find.textContaining('save the plan'), findsOneWidget);
      expect(find.textContaining('Copy made'), findsNothing);
      expect(vm.eveningDate, tonight);
      expect(vm.activeSession!.id, was.id);
      expect(vm.captureBlocks.last.frameCount, 7, reason: 'the change stays');
      final kept = await stored(tester, was.id);
      expect(kept.eveningDate, tonight);
      expect(kept.status, changed.status, reason: 'still Saved · changed');
      expect(kept.blocks.length, changed.blocks.length);
      expect(kept.planSnapshot!.json, was.planSnapshot!.json);
      expect(kept.plannedAtUtc, was.plannedAtUtc);
      expect(await rows(tester), before, reason: 'no copy');
    });
  });
}
