// F17 A1/A4 (S16.2; ADR-022 N6): Home's night card leads with the night's
// facts: the dark interval, the phase and moon-free time, the cloud over
// the dark span with its coverage and age, each row opening its detail.
// No dark time and a partial forecast say so, never a clear or zero value.

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/models/weather_snapshot.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/fake_device_time_zone.dart';
import '../../../support/fake_location_service.dart';
import '../../../support/fake_reverse_geocoder.dart';
import '../../../support/planner_harness.dart';

/// Rows from 00:00 UTC today until [untilHour] UTC tomorrow.
class _Partial implements WeatherRepository {
  _Partial(this.clock, this.untilHour);
  final Clock clock;
  final int untilHour;

  @override
  Future<WeatherFetch> fetchSnapshot({
    required double latitude,
    required double longitude,
    required DateTime startUtc,
    required DateTime endUtc,
  }) async {
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
          for (var h = 0; h <= 24 + untilHour; h++)
            WeatherHour(
              timeUtc: today.add(Duration(hours: h)),
              cloudCoverPct: 30,
            ),
        ],
      ),
    );
  }
}

void main() {
  late AppDatabase db;
  late PlannerHarness vm;

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
    required domain.LocationProfile site,
    required DateTime now,
    int untilHour = 23,
  }) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      db = AppDatabase(NativeDatabase.memory());
      final id = await DriftLocationRepository(db).insertLocation(site);
      SharedPreferences.setMockInitialValues({'activeLocationId': id});
      final clock = FixedClock(now);
      vm = PlannerHarness(
        DriftTargetRepository(db),
        DriftEquipmentRepository(db),
        _Partial(clock, untilHour),
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
    AppRouter.router.go(AppRouter.tonight);
    await tester.pumpWidget(
      MultiProvider(providers: vm.providers, child: const AstroPlanApp()),
    );
    await settle(tester);
    await tester.runAsync(() => vm.conditions.idle);
    await settle(tester);
  }

  List<String> lines(WidgetTester tester, String key) => [
    for (final t in tester.widgetList<Text>(
      find.descendant(of: find.byKey(Key(key)), matching: find.byType(Text)),
    ))
      t.data ?? '',
  ];

  testWidgets('a partial forecast: cloud in the dark, what is covered, its '
      'age', (tester) async {
    await start(
      tester,
      site: domain.LocationProfile(
        id: 0,
        name: 'Ljubljana',
        latitude: 46.05,
        longitude: 14.51,
        timeZoneId: 'Europe/Ljubljana',
      ),
      now: DateTime.utc(2026, 12, 15, 15),
      untilHour: 1, // rows end at 01:00 UTC: the night is cut short
    );
    final weather = lines(tester, 'tonight.weather');
    // night-ui.js weatherWidgetSummary: temperature and wind, or
    // "Measurements incomplete"; never 0 for unknown. The known cloud value
    // remains reachable in the detail.
    expect(weather, contains('Measurements incomplete'));
    expect(
      weather.any(
        (l) => l.startsWith('Forecast for ') && l.contains('dark hours'),
      ),
      isTrue,
      reason: weather.join(' | '),
    );
    expect(weather.any((l) => l.contains('Partial coverage')), isTrue);
    final night = lines(tester, 'tonight.night');
    // app.js conditions: the dark span, then how long it is dark.
    expect(night.any((l) => l.contains('–')), isTrue, reason: night.join());
    expect(
      night.any((l) => RegExp(r'^\d+ h( \d+ min)? dark( · |$)').hasMatch(l)),
      isTrue,
      reason: night.join(' | '),
    );
    final moon = lines(tester, 'tonight.moon');
    expect(moon.any((l) => l.contains('% lit')), isTrue);
    expect(
      moon.any((l) => l.startsWith('Moon-free') || l.startsWith('Moon above')),
      isTrue,
    );
    // Each row opens its detail.
    await tester.tap(find.byKey(const Key('tonight.weather')));
    await settle(tester);
    expect(find.byKey(const Key('conditions.page.2')), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('weather.facts'))).data,
      startsWith('Cloud 30%'),
    );
  });

  testWidgets('no dark time: said in the night and weather rows', (
    tester,
  ) async {
    await start(
      tester,
      site: domain.LocationProfile(
        id: 0,
        name: 'Tromsø',
        latitude: 69.65,
        longitude: 18.96,
        timeZoneId: 'Europe/Oslo',
      ),
      now: DateTime.utc(2026, 6, 20, 12),
    );
    expect(lines(tester, 'tonight.night'), contains('No dark time tonight'));
    expect(
      lines(tester, 'tonight.night'),
      contains('Sun stays above −18° · Europe/Oslo'),
    );
    expect(lines(tester, 'tonight.weather'), contains('No dark-time forecast'));
    expect(
      lines(tester, 'tonight.moon'),
      contains('No dark time, so no moon-free dark'),
    );
  });
}
