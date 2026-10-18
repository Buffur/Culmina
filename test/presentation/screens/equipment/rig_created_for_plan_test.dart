// F05 A1, A2, A5 (D8 A, UXA-C2) through the whole app over a real in-memory
// database: a rig created from the plan's missing-rig action (Tonight, the
// planner's card and status action, onboarding) is saved, chosen for that
// plan and reported, and the app returns to the caller; Cancel writes and
// chooses nothing; one created in the Library is only saved. The photo path
// carries the caller too, and a phone JPEG with focal length, aperture,
// 35 mm equivalent and dimensions saves a rig without typed sensor values.

import 'dart:async';

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/domain/models/camera_class.dart';
import 'package:astroplan/domain/models/spec_confidence.dart';
import 'package:astroplan/domain/models/spec_provenance.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:astroplan/presentation/shared/rig_input_text.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/add_rig.dart';
import '../../../support/fake_capture_file_access.dart';
import '../../../support/fake_location_service.dart';
import '../../../support/in_memory_first_run.dart';
import '../../../support/jpeg_fixture.dart';
import '../../../support/no_snapshot_weather.dart';
import '../../../support/planner_harness.dart';
import '../../../support/tiff_fixture.dart';

final _december = FixedClock(DateTime.utc(2026, 12, 15, 17));

class _NoForecast with NoSnapshotWeather implements WeatherRepository {}

const _m42 = AstroTarget(
  id: 1,
  catalogId: 'M42',
  commonName: 'Orion Nebula',
  type: 'Nebula',
  rightAscension: 83.82,
  declination: -5.39,
);

/// A phone JPEG: f 6.57 mm, f/1.6, f₃₅ 23 mm, 3072 × 4096 px.
List<int> _phoneJpeg() {
  final exif = phoneStyleJpegExif();
  exif.exif!.addAll([
    FixtureEntry.long(40962, 3072),
    FixtureEntry.long(40963, 4096),
  ]);
  return jpegFile([exifApp1(exif.build().bytes)]);
}

void main() {
  late AppDatabase database;
  late PlannerHarness vm;
  late FakeCaptureFileAccess files;

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  /// The app at [route] with a site and M42 chosen, and no rig.
  Future<void> start(
    WidgetTester tester,
    String route, {
    bool target = true,
  }) async {
    AppRouter.router.go(route);
    SharedPreferences.setMockInitialValues({});
    files = FakeCaptureFileAccess();
    await tester.runAsync(() async {
      database = AppDatabase(NativeDatabase.memory());
      final targets = DriftTargetRepository(database);
      await targets.insertTarget(_m42);
      vm = PlannerHarness(
        targets,
        DriftEquipmentRepository(database),
        _NoForecast(),
        DriftLocationRepository(database),
        locationService: FakeLocationService(),
        sessionRepository: DriftSessionRepository(database, clock: _december),
        clock: _december,
        firstRun: InMemoryFirstRun(done: true),
        captureFiles: files,
      );
      await vm.ready;
      if (target) await vm.choosePlan();
      await vm.site.setLocation(46.05, 14.5);
      await vm.tonight.load();
      await vm.plan.idle;
    });
    addTearDown(() => tester.runAsync(database.close));
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MultiProvider(providers: vm.providers, child: const AstroPlanApp()),
    );
    await settle(tester);
  }

  Future<void> tapKey(WidgetTester tester, String key) async {
    final f = find.byKey(Key(key));
    await tester.ensureVisible(f);
    await settle(tester);
    await tester.tap(f);
    await settle(tester);
  }

  /// Fills the required inputs by hand.
  Future<void> fillByHand(WidgetTester tester, String name) async {
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Rig name'),
      name,
    );
    await tester.enterText(find.widgetWithText(TextFormField, '6248'), '6000');
    await tester.enterText(find.widgetWithText(TextFormField, '4176'), '4000');
    await tester.enterText(
      find.byKey(const Key('equipmentEditor.pixelSize')),
      '3.76',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Effective focal length (mm)'),
      '400',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Focal ratio (f/)'),
      '5',
    );
    await tester.pump();
  }

  Future<int> rigRows(WidgetTester tester) async => (await tester.runAsync(
    () async =>
        (await DriftEquipmentRepository(database).getAllEquipment()).length,
  ))!;

  /// The by-hand journey from the rigs screen the caller opened.
  Future<void> createByHand(WidgetTester tester, String name) async {
    expect(find.byKey(const Key('rigs.empty')), findsOneWidget);
    await startAddRig(tester, cameraClass: CameraClass.dslrMirrorless);
    await settle(tester);
    await fillByHand(tester, name);
    await tapKey(tester, 'rigEditor.save');
  }

  void expectChosen(String name, CameraClass cameraClass) {
    expect(vm.plan.selectedEquipment?.name, name);
    expect(vm.plan.selectedEquipment?.cameraClass, cameraClass);
    expect(find.text(RigInputText.savedAndChosen), findsOneWidget);
    expect(find.byKey(const Key('rigs.empty')), findsNothing);
  }

  testWidgets('from Tonight: saved, chosen once, back on Tonight', (
    tester,
  ) async {
    await start(tester, AppRouter.tonight);
    await tapKey(tester, 'tonight.chooseRig');
    await createByHand(tester, 'Tonight rig');

    expectChosen('Tonight rig', CameraClass.dslrMirrorless);
    expect(find.byKey(const Key('tonight.chooseRig')), findsNothing);
    expect(await rigRows(tester), 1);
  });

  testWidgets("from the planner's no-rig card: back in the planner", (
    tester,
  ) async {
    await start(tester, AppRouter.tonight);
    unawaited(AppRouter.router.push(AppRouter.session()));
    await settle(tester);
    await tapKey(tester, 'planner.noRig');
    await createByHand(tester, 'Planner rig');

    expectChosen('Planner rig', CameraClass.dslrMirrorless);
    expect(find.byKey(const Key('planner.noRig')), findsNothing);
    expect(await rigRows(tester), 1);
  });

  testWidgets("from the plan status's action", (tester) async {
    await start(tester, AppRouter.tonight);
    unawaited(AppRouter.router.push(AppRouter.session()));
    await settle(tester);
    await tapKey(tester, 'status.choose');
    await createByHand(tester, 'Status rig');

    expectChosen('Status rig', CameraClass.dslrMirrorless);
    expect(find.byKey(const Key('status.choose')), findsNothing);
  });

  testWidgets('from onboarding (Welcome): back on Welcome', (tester) async {
    await start(tester, AppRouter.welcome, target: false);
    await tapKey(tester, 'welcome.chooseRig');
    await createByHand(tester, 'First rig');

    expectChosen('First rig', CameraClass.dslrMirrorless);
    expect(find.byKey(const Key('welcome.chooseRig')), findsOneWidget);
  });

  testWidgets('Cancel writes and chooses nothing', (tester) async {
    await start(tester, AppRouter.tonight);
    await tapKey(tester, 'tonight.chooseRig');
    await startAddRig(tester);
    await settle(tester);
    await fillByHand(tester, 'Not kept');
    await tester.tap(find.text('Cancel'));
    await settle(tester);

    expect(vm.plan.selectedEquipment, isNull);
    expect(await rigRows(tester), 0);
    expect(find.byKey(const Key('rigs.empty')), findsOneWidget);
    expect(find.text(RigInputText.savedAndChosen), findsNothing);
  });

  testWidgets('in the Library a new rig is only saved', (tester) async {
    await start(tester, AppRouter.libraryRigs);
    await createByHand(tester, 'Library rig');

    expect(vm.plan.selectedEquipment, isNull);
    expect(find.text('Rig saved'), findsOneWidget);
    expect(find.text(RigInputText.savedAndChosen), findsNothing);
    expect(find.text('Library rig'), findsOneWidget, reason: 'still listed');
  });

  testWidgets('From a photo: a phone JPEG saves a rig with no typed sensor '
      'values, chosen for the plan', (tester) async {
    await start(tester, AppRouter.tonight);
    await tapKey(tester, 'tonight.chooseRig');
    await startAddRig(tester, cameraClass: CameraClass.phone, fromPhoto: true);
    await settle(tester);
    files.file('IMG.jpg', _phoneJpeg());
    await tapKey(tester, 'metadata.pick');
    await tapKey(tester, 'import.new');
    // Nothing typed: the file's values and the CALC-40 estimate.
    await tapKey(tester, 'rigEditor.save');

    final rig = vm.plan.selectedEquipment!;
    expect(find.text(RigInputText.savedAndChosen), findsOneWidget);
    expect(find.byKey(const Key('metadata.pick')), findsNothing);
    expect(rig.cameraClass, CameraClass.phone);
    expect((rig.focalLengthMm, rig.focalRatio), (6.57, 1.6));
    expect((rig.resolutionWidthPx, rig.resolutionHeightPx), (4096, 3072));
    // 43.27 mm × 6.57 / 23 over 5120 px: an estimate, labelled so.
    expect(rig.sensorWidthMm, closeTo(9.89, 0.01));
    expect(rig.pixelPitchUm, closeTo(2.414, 0.001));
    expect(
      rig.provenanceOf(EquipmentSpec.pixelPitch)?.confidence,
      SpecConfidence.estimated,
    );
    expect(
      rig.provenanceOf(EquipmentSpec.sensorSize)?.confidence,
      SpecConfidence.estimated,
    );
    expect(await rigRows(tester), 1);
  });
}
