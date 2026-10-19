// F18 A2 (TD-095): the planner's "couldn't be saved" banner shows while an
// autosave has failed, and goes once Save plan succeeds, because Save writes
// the whole plan. Through the real app and database; only the autosave's
// update fails, as a full disk would for that write.

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/services/catalog_seeder.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/models/session.dart';
import 'package:astroplan/domain/repositories/storage_failure.dart';
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
import '../../../support/no_snapshot_weather.dart';
import '../../../support/planner_harness.dart';

class _NoForecast with NoSnapshotWeather implements WeatherRepository {}

/// The real sessions; while [failAutosave], the autosave's update fails.
class _Sessions extends DriftSessionRepository {
  _Sessions(super.db, {super.clock});

  bool failAutosave = false;

  @override
  Future<Session> updatePlan(int id, SessionPlan plan) => failAutosave
      ? Future.error(const StorageFailure('disk full'))
      : super.updatePlan(id, plan);
}

void main() {
  testWidgets('the autosave-failure banner goes after a successful Save '
      'plan', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    late AppDatabase db;
    late PlannerHarness vm;
    late _Sessions sessions;
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
      final clock = FixedClock(DateTime.utc(2026, 11, 10, 18));
      sessions = _Sessions(db, clock: clock);
      vm = PlannerHarness(
        DriftTargetRepository(db),
        DriftEquipmentRepository(db),
        _NoForecast(),
        DriftLocationRepository(db),
        locationService: FakeLocationService(),
        reverseGeocoder: FakeReverseGeocoder(),
        deviceTimeZone: FakeDeviceTimeZone(),
        clock: clock,
        sessionRepository: sessions,
      );
      await vm.ready;
      await vm.choosePlan(); // a target and a rig, so Save can save
      await vm.plan.idle;
    });
    addTearDown(() => tester.runAsync(db.close));
    AppRouter.router.go(AppRouter.session());
    await tester.pumpWidget(
      MultiProvider(providers: vm.providers, child: const AstroPlanApp()),
    );
    await settle(tester);
    final banner = find.byKey(const Key('planner.autosaveFailure'));
    expect(banner, findsNothing);

    // An edit whose autosave fails: the banner says so.
    sessions.failAutosave = true;
    await tester.runAsync(() async {
      await vm.plan.addCaptureBlock(
        CaptureBlock(
          frameType: FrameType.light,
          filterName: 'Ha',
          exposureTimeSeconds: 300,
          frameCount: 7,
        ),
      );
      await vm.plan.idle;
    });
    await settle(tester);
    expect(banner, findsOneWidget);
    expect(
      find.textContaining("Your latest changes couldn't be saved"),
      findsOneWidget,
    );

    // Save plan writes the whole plan (no autosave meanwhile): it succeeds
    // and the banner goes; the stored plan holds the edit.
    final save = find.byKey(const Key('planner.save'));
    await tester.ensureVisible(save);
    await tester.tap(save);
    await settle(tester);
    await tester.runAsync(() => vm.plan.idle);
    await settle(tester);
    expect(find.textContaining("Couldn't save the plan"), findsNothing);
    expect(banner, findsNothing);
    final stored = await tester.runAsync(
      () => sessions.get(vm.plan.activeSessionId!),
    );
    expect(stored!.status, SessionStatus.planned);
    expect(stored.blocks.last.frameCount, 7);
  });
}

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }
}
