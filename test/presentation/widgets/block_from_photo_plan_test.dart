// F08 A1/A4 (host part) through the capture plan, the real ViewModels and an
// in-memory SQLite database: "Take from a photo" in a new light block reads a
// synthetic DNG through the app's picker and reader. Add block stores the
// proposed exposure, ISO and file with their origins. The rig is untouched.
// The saved plan reopens with the same values. (The physical-phone run with
// real DNG/JPEG/HEIC files is a G2 row.)

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/domain/models/camera_class.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/presentation/widgets/capture_plan_widget.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_capture_file_access.dart';
import '../../support/fake_location_service.dart';
import '../../support/no_snapshot_weather.dart';
import '../../support/planner_harness.dart';
import '../../support/tiff_fixture.dart';
import '../../support/block_editor_finders.dart';

class _NoForecast with NoSnapshotWeather implements WeatherRepository {}

const _m42 = AstroTarget(
  id: 1,
  catalogId: 'M42',
  rightAscension: 83.82,
  declination: -5.39,
  type: 'Nebula',
);

const _camera = EquipmentProfile(
  id: 1,
  name: 'Camera',
  cameraClass: CameraClass.dslrMirrorless,
  sensorWidthMm: 23.5,
  sensorHeightMm: 15.6,
  pixelPitchUm: 3.9,
  resolutionWidthPx: 4000,
  resolutionHeightPx: 3000,
  focalLengthMm: 200,
  focalRatio: 4,
);

void main() {
  testWidgets('pick, review, Add block, Save, reopen: the values and their '
      'origins are kept; the rig is not changed', (tester) async {
    late AppDatabase db;
    late PlannerHarness vm;
    late DriftSessionRepository sessions;
    final files = FakeCaptureFileAccess();
    final clock = FixedClock(DateTime.utc(2026, 11, 10, 16));
    late EquipmentProfile rigBefore;
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      db = AppDatabase(NativeDatabase.memory());
      sessions = DriftSessionRepository(db, clock: clock);
      final siteId = await DriftLocationRepository(db).insertLocation(
        domain.LocationProfile(
          id: 0,
          name: 'Ljubljana',
          latitude: 46.05,
          longitude: 14.51,
          timeZoneId: 'Europe/Ljubljana',
        ),
      );
      SharedPreferences.setMockInitialValues({'activeLocationId': siteId});
      vm = PlannerHarness(
        DriftTargetRepository(db),
        DriftEquipmentRepository(db),
        _NoForecast(),
        DriftLocationRepository(db),
        locationService: FakeLocationService(),
        clock: clock,
        sessionRepository: sessions,
        captureFiles: files,
      );
      await vm.ready;
      final targets = DriftTargetRepository(db);
      await vm.plan.setTarget(
        (await targets.getTargetById(await targets.insertTarget(_m42)))!,
      );
      final rigs = DriftEquipmentRepository(db);
      rigBefore = (await rigs.getEquipmentById(
        await rigs.insertEquipment(_camera),
      ))!;
      await vm.plan.setEquipment(rigBefore);
      await vm.plan.idle;
    });
    addTearDown(() => tester.runAsync(db.close));
    await tester.pumpWidget(
      MultiProvider(
        providers: vm.providers,
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: CapturePlanWidget()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    Future<void> settle() async {
      for (var i = 0; i < 6; i++) {
        await tester.runAsync(() => Future<void>.delayed(Duration.zero));
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    await tester.tap(find.byKey(const Key('capturePlan.addLights')));
    await tester.pumpAndSettle();
    final dng = (TiffFixture()..ifd0.addAll(phoneStyleDngIfd0())).build().bytes;
    files.file('DSC_0001.dng', dng, length: 24012345);
    await openBlockDisclosure(tester, 'blockDialog.photo');
    await tester.ensureVisible(find.byKey(const Key('blockDialog.fromPhoto')));
    await tester.tap(find.byKey(const Key('blockDialog.fromPhoto')));
    await settle();
    expect(find.byKey(const Key('blockDialog.review')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('blockDialog.count')), '40');
    await tester.ensureVisible(find.byKey(const Key('blockDialog.submit')));
    await tester.tap(find.byKey(const Key('blockDialog.submit')));
    await settle();

    final block = vm.captureBlocks.single;
    expect(block.exposureTimeSeconds, 30);
    expect(block.gain, CaptureGain.iso(50));
    expect(block.fileEvidence!.bytes, 24012345);
    expect(block.origins[CaptureField.exposure]!.descriptor, 'DSC_0001.dng');
    // F07: the block's own file sizes its storage (the file-size basis, in
    // Budget and assumptions).
    await tester.ensureVisible(find.text('Budget and assumptions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Budget and assumptions'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Measured from DSC_0001.dng'), findsOneWidget);

    late EquipmentProfile rigAfter;
    late CaptureBlock reopened;
    await tester.runAsync(() async {
      final saved = await vm.saveSession();
      reopened = (await sessions.get(saved.id))!.blocks.single;
      rigAfter = (await DriftEquipmentRepository(db).getAllEquipment()).single;
    });
    expect(reopened.fileEvidence, block.fileEvidence);
    expect(reopened.origins, block.origins);
    expect(reopened.gain, block.gain);
    expect(
      (rigAfter.averageRawFileSizeMB, rigAfter.rawFileSizeEvidence),
      (rigBefore.averageRawFileSizeMB, rigBefore.rawFileSizeEvidence),
      reason: 'no exposure, ISO or file reaches the rig',
    );
  });
}
