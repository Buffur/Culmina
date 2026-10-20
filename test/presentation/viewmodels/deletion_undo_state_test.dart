import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/repositories/shared_prefs_planner_state_repository.dart';
import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/location_profile.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_device_time_zone.dart';
import '../../support/fake_location_service.dart';
import '../../support/fake_reverse_geocoder.dart';
import '../../support/no_snapshot_weather.dart';
import '../../support/planner_harness.dart';

class _Weather with NoSnapshotWeather implements WeatherRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;
  late PlannerHarness vm;
  late DriftSessionRepository sessions;
  late DriftLocationRepository sites;
  final state = SharedPrefsPlannerStateRepository();
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase(NativeDatabase.memory());
    final targets = DriftTargetRepository(db);
    final equipment = DriftEquipmentRepository(db);
    sites = DriftLocationRepository(db);
    sessions = DriftSessionRepository(db);
    await targets.insertTarget(
      const AstroTarget(
        id: 0,
        catalogId: 'M31',
        rightAscension: 10,
        declination: 40,
        type: 'Galaxy',
      ),
    );
    await equipment.insertEquipment(
      const EquipmentProfile(
        id: 0,
        name: 'Rig',
        sensorWidthMm: 36,
        sensorHeightMm: 24,
        resolutionWidthPx: 6000,
        resolutionHeightPx: 4000,
        pixelPitchUm: 6,
        focalLengthMm: 50,
        focalRatio: 2,
      ),
    );
    final site = await sites.insertLocation(
      LocationProfile(
        id: 0,
        name: 'Home',
        latitude: 50,
        longitude: 30,
        elevation: 200,
        timeZoneId: 'Europe/Kyiv',
        bortleClass: 4,
        bortleSource: 'user',
      ),
    );
    await state.setActiveLocationId(site);
    vm = PlannerHarness(
      targets,
      equipment,
      _Weather(),
      sites,
      sessionRepository: sessions,
      stateRepository: state,
      locationService: FakeLocationService(),
      reverseGeocoder: FakeReverseGeocoder(),
      deviceTimeZone: FakeDeviceTimeZone(),
      clock: FixedClock(DateTime.utc(2026, 10, 20, 15)),
    );
    await vm.ready;
    await vm.choosePlan(target: 'M31');
  });
  tearDown(() async {
    await vm.plan.idle;
    vm.dispose();
    await db.close();
  });

  test(
    'active site Undo restores zone, sky, persisted selection and same ID',
    () async {
      final before = vm.site.activeSite!;
      final receipt = (await vm.site.deleteWithUndo(before.id))!;
      expect(vm.site.activeSite, isNull);
      expect(await state.getActiveLocationId(), isNull);
      expect(vm.site.latitude, before.latitude);
      await receipt.restore();
      await vm.plan.idle;
      expect(vm.site.activeSite!.id, before.id);
      expect(vm.site.displayZoneId, before.timeZoneId);
      expect(vm.site.bortleClass, 4);
      expect(await state.getActiveLocationId(), before.id);
      expect((await sessions.get(vm.plan.activeSessionId!))!.siteId, before.id);
    },
  );

  test('later position and sky choice win over active-site Undo', () async {
    final receipt = (await vm.site.deleteWithUndo(vm.site.activeSite!.id))!;
    await vm.site.setLocation(1, 2);
    await vm.site.setBortleClass(8);
    await receipt.restore();
    expect(vm.site.activeSite, isNull);
    expect(vm.site.latitude, 1);
    expect(vm.site.longitude, 2);
    expect(vm.site.bortleClass, 8);
    expect(await state.getActiveLocationId(), isNull);
    expect(vm.site.sites, hasLength(1));
  });

  test(
    'rig and target Undo restore original selection, never a new plan',
    () async {
      final rig = vm.plan.selectedEquipment!;
      final restoreRig = vm.plan.rememberEquipmentForUndo(rig.id);
      final receipt = (await vm.vms.gear.deleteWithUndo(rig.id))!;
      await vm.plan.refreshSelectedEquipment();
      expect(vm.plan.selectedEquipment, isNull);
      await receipt.restore();
      await restoreRig();
      expect(vm.plan.selectedEquipment!.id, rig.id);

      final target = vm.plan.selectedTarget!;
      final restoreTarget = vm.plan.rememberTargetForUndo(target.id);
      final targetReceipt = (await vm.vms.targetList.deleteWithUndo(
        target.id,
      ))!;
      await vm.plan.refreshSelectedTarget();
      vm.plan.replaceContents(
        target: null,
        rig: null,
        blocks: [],
        isExample: false,
      );
      await targetReceipt.restore();
      await restoreTarget();
      expect(vm.plan.selectedTarget, isNull);
    },
  );

  test(
    'current entry Undo restores identity and unsaved mark without a new draft',
    () async {
      final id = vm.plan.activeSessionId!;
      final before = await sessions.get(id);
      expect(vm.plan.hasUnsavedChanges, isTrue);
      final receipt = (await vm.vms.sessionList!.deleteWithUndo(id))!;
      expect(vm.plan.activeSessionId, isNull);
      expect(await state.getEditedSessionId(), isNull);
      expect(await sessions.get(id), isNull);
      await receipt.restore();
      expect(vm.plan.activeSessionId, id);
      expect(vm.plan.hasUnsavedChanges, isTrue);
      expect(await state.getEditedSessionId(), id);
      expect((await sessions.get(id))!.blocks.length, before!.blocks.length);
    },
  );

  test('plan edits made while a rig is deleted survive Undo and persist restored rig', () async {
    final rig = vm.plan.selectedEquipment!;
    final restoreSelection = vm.plan.rememberEquipmentForUndo(rig.id);
    final receipt = (await vm.vms.gear.deleteWithUndo(rig.id))!;
    await vm.plan.refreshSelectedEquipment();
    await vm.plan.removeCaptureBlock(0);
    final remaining = vm.plan.captureBlocks.length;
    await receipt.restore();
    await restoreSelection();
    final stored = (await sessions.get(vm.plan.activeSessionId!))!;
    expect(stored.rigId, rig.id);
    expect(stored.blocks.length, remaining);
    expect(vm.plan.captureBlocks.length, remaining);
  });

  test('editing after current deletion creates draft and Undo preserves newer identity', () async {
    final id = vm.plan.activeSessionId!;
    final receipt = (await vm.vms.sessionList!.deleteWithUndo(id))!;
    await vm.plan.setEquipment(vm.plan.selectedEquipment!);
    final newer = vm.plan.activeSessionId!;
    expect(newer, isNot(id));
    expect(vm.plan.autosaveFailure, isNull);
    await receipt.restore();
    expect(vm.plan.activeSessionId, newer);
    expect(await state.getEditedSessionId(), newer);
    expect(await sessions.get(id), isNotNull);
    expect(await sessions.get(newer), isNotNull);
  });
}
