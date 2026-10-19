// F14 A2 (ADR-022 N8): the forecast belongs to coordinates, not to a site
// id. Editing the active site's coordinates (same id) loads a forecast for
// the new position, and a slow answer for the old position that arrives
// afterwards is dropped: nothing attaches to the wrong site.

import 'dart:async';

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/models/night_weather.dart';
import 'package:astroplan/domain/models/weather_snapshot.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_device_time_zone.dart';
import '../../support/fake_location_service.dart';
import '../../support/planner_harness.dart';

/// Holds each answer until [release]; tells requests apart by latitude.
class _Gated implements WeatherRepository {
  _Gated(this.clock);
  final Clock clock;
  final pending = <double, Completer<WeatherFetch>>{};

  @override
  Future<WeatherFetch> fetchSnapshot({
    required double latitude,
    required double longitude,
    required DateTime startUtc,
    required DateTime endUtc,
  }) => (pending[latitude] ??= Completer<WeatherFetch>()).future;

  void release(double latitude) {
    final t = DateTime.utc(2026, 11, 10);
    pending[latitude]!.complete(
      WeatherFetched(
        WeatherSnapshot(
          provider: 'open-meteo',
          model: 'best_match',
          fetchedAtUtc: clock.nowUtc(),
          latitude: latitude,
          longitude: 14.51,
          hours: [
            for (var h = 0; h < 48; h++)
              WeatherHour(
                timeUtc: t.add(Duration(hours: h)),
                cloudCoverPct: latitude,
              ),
          ],
        ),
      ),
    );
  }
}

void main() {
  testWidgets('a same-id coordinate edit loads the new position; the old '
      'answer, arriving late, is dropped', (tester) async {
    late PlannerHarness vm;
    late _Gated weather;
    late AppDatabase db;
    late domain.LocationProfile site;
    await tester.runAsync(() async {
      db = AppDatabase(NativeDatabase.memory());
      final sites = DriftLocationRepository(db);
      final id = await sites.insertLocation(
        domain.LocationProfile(
          id: 0,
          name: 'Field',
          latitude: 46.05,
          longitude: 14.51,
          timeZoneId: 'Europe/Ljubljana',
        ),
      );
      site = (await sites.getLocationById(id))!;
      SharedPreferences.setMockInitialValues({'activeLocationId': id});
      final clock = FixedClock(DateTime.utc(2026, 11, 10, 16));
      weather = _Gated(clock);
      vm = PlannerHarness(
        DriftTargetRepository(db),
        DriftEquipmentRepository(db),
        weather,
        sites,
        locationService: FakeLocationService(),
        deviceTimeZone: FakeDeviceTimeZone(),
        clock: clock,
      );
      await vm.ready;
    });
    addTearDown(() => tester.runAsync(db.close));
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    for (var i = 0; i < 5 && !weather.pending.containsKey(46.05); i++) {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump();
    }
    expect(weather.pending.keys, [46.05], reason: 'the first request');

    // The same site (same id), moved 30 km north.
    await tester.runAsync(
      () => vm.site.saveSite(
        domain.LocationProfile(
          id: site.id,
          name: site.name,
          latitude: 46.32,
          longitude: 14.51,
          timeZoneId: 'Europe/Ljubljana',
        ),
      ),
    );
    await tester.pump();
    expect(weather.pending.keys, containsAll([46.05, 46.32]));
    await tester.runAsync(() async {
      weather.release(46.32);
      await vm.conditions.idle; // the new position's forecast is shown
      weather.release(46.05); // then the late answer for the old one
      // Long enough for the old answer's load to finish too.
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    // Let the old answer's load finish too.
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump();
    }
    final w = vm.conditions.nightWeather as NightWeatherAvailable;
    expect(w.snapshot.latitude, 46.32);
    expect(vm.conditions.nightWeatherSummary!.cloudCover!.max, 46.32);
    expect(
      vm.conditions.forecastNights!.nights.first.summary.cloudCover!.max,
      46.32,
    );
  });
}
