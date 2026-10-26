import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/domain/metadata/capture_file_access.dart';
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'fake_device_time_zone.dart';
import 'fake_location_service.dart';
import 'fake_reverse_geocoder.dart';
import 'hybrid_transfer_fixture.dart';
import 'hybrid_transfer_shots.dart';
import 'in_memory_first_run.dart';
import 'in_memory_privacy_preferences.dart';
import 'planner_harness.dart';
import 'wave1_capture.dart';

class Wave2Fixture {
  Wave2Fixture(this.seed, this.vm);
  final HybridTransferFixture seed;
  final PlannerHarness vm;
  AppDatabase get db => seed.db;
  bool _closed = false;

  Future<void> close(WidgetTester t) async {
    if (_closed) return;
    _closed = true;
    await t.pumpWidget(const SizedBox.shrink());
    await hybridSettle(t);
    await t.runAsync(() async {
      vm.dispose();
      if (!identical(vm, seed.vm)) seed.vm.dispose();
      await db.close();
    });
  }
}

Future<Wave2Fixture> mountWave2(
  WidgetTester t,
  String theme, {
  Widget Function(Wave2Fixture)? screen,
  List<SingleChildWidget> Function(Wave2Fixture)? overrides,
  WeatherRepository? weather,
  CaptureFileAccess? captureFiles,
}) async {
  if (!wave1IsNative) {
    t.view.physicalSize = const Size(375, 812);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
  }
  t.platformDispatcher.platformBrightnessTestValue = theme == 'light'
      ? Brightness.light
      : Brightness.dark;
  t.platformDispatcher.textScaleFactorTestValue = 1;
  addTearDown(t.platformDispatcher.clearAllTestValues);
  late Wave2Fixture f;
  await t.runAsync(() async {
    final seed = await HybridTransferFixture.create(
      AppDatabase(NativeDatabase.memory()),
    );
    final vm = weather == null && captureFiles == null
        ? seed.vm
        : PlannerHarness(
            DriftTargetRepository(seed.db),
            DriftEquipmentRepository(seed.db),
            weather ?? seed.forecast,
            DriftLocationRepository(seed.db),
            sessionRepository: seed.sessions,
            clock: FixedClock(hybridTransferNow),
            locationService: FakeLocationService(),
            reverseGeocoder: FakeReverseGeocoder(),
            deviceTimeZone: FakeDeviceTimeZone(),
            firstRun: InMemoryFirstRun(done: true),
            captureFiles: captureFiles,
            privacyPreferences: InMemoryPrivacyPreferences(),
          );
    await vm.ready;
    if (theme == 'field') await vm.theme.toggleFieldMode();
    f = Wave2Fixture(seed, vm);
  });
  addTearDown(() => f.close(t));
  AppRouter.router.go(AppRouter.tonight);
  await t.pumpWidget(
    MultiProvider(
      providers: [...f.vm.providers, ...?overrides?.call(f)],
      child: screen == null
          ? RepaintBoundary(key: wave1CaptureKey, child: const AstroPlanApp())
          : wave1App(theme, home: screen(f)),
    ),
  );
  await hybridSettle(t);
  return f;
}

Future<void> revealWave2(WidgetTester t, Finder target) async {
  if (target.evaluate().isEmpty) {
    await t.scrollUntilVisible(
      target,
      300,
      scrollable: find
          .byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          )
          .hitTestable()
          .first,
    );
  }
  await t.ensureVisible(target);
  await hybridSettle(t);
}
