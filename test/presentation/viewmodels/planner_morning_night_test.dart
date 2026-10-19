// F24 A1 (TD-096): a committed morning instant beside `testEvening`. By the
// SessionNight rule (ADR-007 §5, L4) the default night is the one whose
// window (mean solar noon to mean solar noon) contains now: after midnight
// it is still the night in progress, between sunrise and solar noon the
// night that has just ended, and only after the site's mean solar noon the
// coming one. Literal dates; no wall clock.

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_device_time_zone.dart';
import '../../support/fake_location_service.dart';
import '../../support/fake_reverse_geocoder.dart';
import '../../support/no_snapshot_weather.dart';
import '../../support/planner_harness.dart';
import '../../support/test_clock.dart';

class _NoForecast with NoSnapshotWeather implements WeatherRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final evening10 = CalendarDate(2026, 11, 10);
  final evening11 = CalendarDate(2026, 11, 11);

  Future<(PlannerHarness, AppDatabase)> boot(
    Clock clock, {
    domain.LocationProfile? site,
  }) async {
    final db = AppDatabase(NativeDatabase.memory());
    var prefs = <String, Object>{};
    if (site != null) {
      final id = await DriftLocationRepository(db).insertLocation(site);
      prefs = {'activeLocationId': id};
    }
    SharedPreferences.setMockInitialValues(prefs);
    final vm = PlannerHarness(
      DriftTargetRepository(db),
      DriftEquipmentRepository(db),
      _NoForecast(),
      DriftLocationRepository(db),
      locationService: FakeLocationService(),
      reverseGeocoder: FakeReverseGeocoder(),
      deviceTimeZone: FakeDeviceTimeZone(),
      clock: clock,
      sessionRepository: DriftSessionRepository(db, clock: clock),
    );
    await vm.ready;
    return (vm, db);
  }

  final ljubljana = domain.LocationProfile(
    id: 0,
    name: 'Ljubljana',
    latitude: 46.05,
    longitude: 14.51,
    elevation: 300,
    timeZoneId: 'Europe/Ljubljana',
  );

  test('testMorning: the planner\'s night is the one that began the evening '
      'before (default position)', () async {
    final (vm, db) = await boot(testMorning);
    addTearDown(db.close);
    // No site: no night drives the plan (SI-008), but its key is that night.
    expect(vm.plan.eveningDate, isNull);
    expect(vm.plan.nightKey, evening10);
    expect(vm.plan.tonightKey, evening10);
    final night = vm.site.nightAt(null);
    final now = testMorning.nowUtc();
    expect(night.startUtc.isAfter(now), isFalse);
    expect(night.endUtc.isAfter(now), isTrue, reason: 'still in its window');
    // London (−0.1276°): mean solar noon about 12:00:31 UTC.
    expect(night.endUtc, DateTime.utc(2026, 11, 11, 12, 0, 30, 624));
  });

  test('testMorning at a site: 07:00 in Ljubljana is still the night of '
      '10 Nov', () async {
    final (vm, db) = await boot(testMorning, site: ljubljana);
    addTearDown(db.close);
    expect(vm.site.displayZoneId, 'Europe/Ljubljana');
    expect(vm.plan.eveningDate, evening10);
  });

  test('the night changes at the site\'s mean solar noon, not at midnight '
      'or dawn', () async {
    // Ljubljana (14.51° E): mean solar noon 12:00 − 58 min 2.4 s = 11:01:58
    // UTC.
    for (final (at, expected) in [
      (DateTime.utc(2026, 11, 10, 23, 30), evening10), // 00:30 local
      (DateTime.utc(2026, 11, 11, 5), evening10), // 06:00 local
      (DateTime.utc(2026, 11, 11, 11), evening10), // 12:00 local, before
      (DateTime.utc(2026, 11, 11, 11, 5), evening11), // just after
      (DateTime.utc(2026, 11, 11, 18), evening11), // the next evening
    ]) {
      final (vm, db) = await boot(FixedClock(at), site: ljubljana);
      expect(vm.plan.eveningDate, expected, reason: '$at');
      await db.close();
    }
  });
}
