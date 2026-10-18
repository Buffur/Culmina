// F09 A2–A6 in the capture plan (real ViewModels, in-memory SQLite):
// "Build calibration frames" opens the CAL-1 preview, also from the
// missing-flat warning. Counts are editable proposals; a flat's exposure must
// be entered. Cancel changes nothing; confirm adds the blocks with one Undo,
// and Undo after a newer edit keeps that edit. In-camera noise reduction
// means no darks. With no blocks, the plan names its next step with labelled
// actions instead of the example shortcut.

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
import 'package:astroplan/presentation/widgets/capture_plan/blocks_undo.dart';
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

class _NoForecast with NoSnapshotWeather implements WeatherRepository {}

const _m42 = AstroTarget(
  id: 1,
  catalogId: 'M42',
  rightAscension: 83.82,
  declination: -5.39,
  type: 'Nebula',
);

EquipmentProfile _rig(CameraClass c, {bool lenr = false}) => EquipmentProfile(
  id: 1,
  name: 'Rig',
  cameraClass: c,
  inCameraNoiseReduction: lenr,
  sensorWidthMm: 23.5,
  sensorHeightMm: 15.6,
  pixelPitchUm: 3.9,
  resolutionWidthPx: 6000,
  resolutionHeightPx: 4000,
  focalLengthMm: 200,
  focalRatio: 4,
);

CaptureBlock _light(String filter, {double exposure = 120}) => CaptureBlock(
  frameType: FrameType.light,
  filterName: filter,
  exposureTimeSeconds: exposure,
  frameCount: 30,
  gain: CaptureGain.iso(800),
);

void main() {
  late AppDatabase db;
  late PlannerHarness vm;

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> start(
    WidgetTester tester, {
    required EquipmentProfile rig,
    List<CaptureBlock> blocks = const [],
    bool files = false,
  }) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final clock = FixedClock(DateTime.utc(2026, 11, 10, 16));
    await tester.runAsync(() async {
      db = AppDatabase(NativeDatabase.memory());
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
        sessionRepository: DriftSessionRepository(db, clock: clock),
        captureFiles: files ? FakeCaptureFileAccess() : null,
      );
      await vm.ready;
      final targets = DriftTargetRepository(db);
      await vm.plan.setTarget(
        (await targets.getTargetById(await targets.insertTarget(_m42)))!,
      );
      final rigs = DriftEquipmentRepository(db);
      await vm.plan.setEquipment(
        (await rigs.getEquipmentById(await rigs.insertEquipment(rig)))!,
      );
      for (final b in blocks) {
        await vm.plan.addCaptureBlock(b);
      }
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
    await settle(tester);
  }

  Future<void> openPreview(WidgetTester tester) async {
    await tester.ensureVisible(
      find.byKey(const Key('capturePlan.buildCalibration')),
    );
    await tester.tap(find.byKey(const Key('capturePlan.buildCalibration')));
    await settle(tester);
  }

  Future<void> enterExposures(WidgetTester tester, String value) async {
    final keys = tester
        .widgetList<TextFormField>(find.byType(TextFormField))
        .map((f) => f.key)
        .whereType<ValueKey<String>>()
        .where((k) => k.value.startsWith('calibration.exposure.'))
        .toList();
    for (final k in keys) {
      await tester.enterText(find.byKey(k), value);
    }
  }

  testWidgets('the preview lists what the lights need; Cancel changes '
      'nothing', (tester) async {
    await start(
      tester,
      rig: _rig(CameraClass.dslrMirrorless),
      blocks: [_light('L'), _light('R', exposure: 60)],
    );
    await openPreview(tester);
    expect(find.text('Build calibration frames'), findsWidgets);
    expect(find.textContaining('Dark · 2 min'), findsNothing);
    expect(find.textContaining('Dark · 120 s'), findsOneWidget);
    expect(find.textContaining('Dark · 60 s'), findsOneWidget);
    expect(find.textContaining('Flat (L)'), findsOneWidget);
    expect(find.textContaining('Flat (R)'), findsOneWidget);
    expect(find.textContaining('Bias · ISO 800'), findsOneWidget);
    expect(find.text('Add 5 blocks'), findsOneWidget);
    await tester.tap(find.byKey(const Key('calibration.cancel')));
    await settle(tester);
    expect(vm.captureBlocks, hasLength(2));
  });

  testWidgets("a flat's exposure must be entered; counts are editable; a "
      'row can be left out', (tester) async {
    await start(
      tester,
      rig: _rig(CameraClass.dslrMirrorless),
      blocks: [_light('L')],
    );
    await openPreview(tester);
    await tester.tap(find.byKey(const Key('calibration.confirm')));
    await settle(tester);
    expect(
      find.text('Enter seconds, e.g. 60, 0.5 or 1/14'),
      findsWidgets,
      reason: 'nothing is taken from the light',
    );
    expect(vm.captureBlocks, hasLength(1));
    await enterExposures(tester, '2');
    await tester.enterText(find.byKey(const Key('calibration.count.0')), '12');
    await tester.tap(find.byKey(const Key('calibration.toggle.2'))); // bias
    await settle(tester);
    expect(find.text('Add 2 blocks'), findsOneWidget);
    await tester.tap(find.byKey(const Key('calibration.confirm')));
    await settle(tester);
    final added = vm.captureBlocks.skip(1).toList();
    expect(added.map((b) => b.frameType), [FrameType.dark, FrameType.flat]);
    expect(added.first.frameCount, 12);
    expect(added.first.exposureTimeSeconds, 120);
    expect(added.last.exposureTimeSeconds, 2);
    expect(find.text('Added 2 calibration blocks'), findsOneWidget);
  });

  testWidgets('Undo after a newer edit keeps that edit', (tester) async {
    await start(
      tester,
      rig: _rig(CameraClass.dslrMirrorless),
      blocks: [_light('L')],
    );
    await openPreview(tester);
    await enterExposures(tester, '2');
    await tester.tap(find.byKey(const Key('calibration.confirm')));
    await settle(tester);
    final added = vm.captureBlocks.length;
    await tester.runAsync(() => vm.plan.removeCaptureBlock(added - 1));
    await settle(tester);
    await tester.tap(find.text('Undo'));
    await settle(tester);
    expect(find.text(notUndone), findsOneWidget);
    expect(vm.captureBlocks, hasLength(added - 1), reason: 'the edit stays');
  });

  testWidgets('in-camera noise reduction: no darks, and the preview says '
      'why', (tester) async {
    await start(
      tester,
      rig: _rig(CameraClass.dslrMirrorless, lenr: true),
      blocks: [_light('L')],
    );
    await openPreview(tester);
    expect(find.byKey(const Key('calibration.noDarks')), findsOneWidget);
    expect(find.textContaining('Dark ·'), findsNothing);
  });

  testWidgets('the missing-flat warning offers the preview', (tester) async {
    await start(
      tester,
      rig: _rig(CameraClass.dslrMirrorless),
      blocks: [
        _light('L'),
        _light('R'),
        CaptureBlock(
          frameType: FrameType.flat,
          filterName: 'L',
          exposureTimeSeconds: 2,
          frameCount: 20,
          calibrationPolicy: CalibrationPolicy.outsideWindow,
        ),
      ],
    );
    expect(find.text('No flats for: R'), findsOneWidget);
    expect(
      find.text('Build calibration frames, with the missing flats'),
      findsOneWidget,
    );
    await openPreview(tester);
    Finder inPreview(String text) => find.descendant(
      of: find.byType(AlertDialog),
      matching: find.textContaining(text),
    );
    expect(inPreview('Flat (R)'), findsOneWidget);
    expect(inPreview('Flat (L)'), findsNothing, reason: 'covered');
  });

  group('the empty plan (A6, UXA-C5)', () {
    testWidgets('names the next step with labelled actions; no example', (
      tester,
    ) async {
      await start(tester, rig: _rig(CameraClass.phone), files: true);
      expect(
        find.textContaining(
          'Start with your light frames; the calibration '
          'frames can be built from them afterwards.',
        ),
        findsOneWidget,
      );
      expect(find.text('Add light frames'), findsOneWidget);
      expect(find.text('Take from a photo'), findsOneWidget);
      expect(find.byKey(const Key('capturePlan.useExample')), findsNothing);
      expect(find.textContaining('example'), findsNothing);
      await tester.tap(find.byKey(const Key('capturePlan.addLights')));
      await settle(tester);
      expect(find.text('Add capture block'), findsOneWidget);
    });

    testWidgets('an astro rig is offered a file too, since FITS is read '
        '(F10)', (tester) async {
      await start(tester, rig: _rig(CameraClass.astroMono), files: true);
      expect(find.text('Add light frames'), findsOneWidget);
      expect(find.text('Take from a photo'), findsOneWidget);
    });
  });
}
