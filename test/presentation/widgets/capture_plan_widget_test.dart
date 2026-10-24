// Widget tests for CapturePlanWidget (roadmap TASK 4.1, TD-012).
//
// Covers the two behaviors that weren't testable at the ViewModel level:
//   - the Add/Edit dialog rejects invalid exposure/frame-count input instead
//     of silently defaulting to 60 s x 30 frames;
//   - tapping an existing block opens a pre-filled Edit dialog whose Save
//     button calls updateCaptureBlock (previously unreachable from the UI).
// Reorder-index correctness (TD-010) is covered at the ViewModel level in
// planner_capture_blocks_test.dart, where it's deterministic and fast.

import 'dart:io';

import 'package:astroplan/domain/models/camera_class.dart';
import 'package:astroplan/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:drift/native.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astroplan/data/database/app_database.dart'
    hide CaptureBlock, AstroTarget;
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/tracking_type.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/repositories/weather_repository.dart';

import '../../support/planner_harness.dart';

import 'package:astroplan/presentation/widgets/capture_plan_widget.dart';

import '../../support/fake_location_service.dart';
import '../../support/no_snapshot_weather.dart';
import '../../support/block_editor_finders.dart';

class _MockWeather with NoSnapshotWeather implements WeatherRepository {}

/// A camera rig: its blocks record ISO (ADR-021 C13).
const _dslr = EquipmentProfile(
  id: 1,
  name: 'Camera',
  cameraClass: CameraClass.dslrMirrorless,
  sensorWidthMm: 23.5,
  sensorHeightMm: 15.6,
  pixelPitchUm: 3.9,
  resolutionWidthPx: 6000,
  resolutionHeightPx: 4000,
  focalLengthMm: 200,
  focalRatio: 4,
);

void main() {
  late AppDatabase database;
  late PlannerHarness vm;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    final locationRepo = DriftLocationRepository(database);
    final locId = await locationRepo.insertLocation(
      domain.LocationProfile(
        id: 0,
        name: 'Test',
        latitude: 51.5,
        longitude: -0.1,
        elevation: 10,
      ),
    );
    SharedPreferences.setMockInitialValues({'activeLocationId': locId});

    vm = PlannerHarness(
      DriftTargetRepository(database),
      DriftEquipmentRepository(database),
      _MockWeather(),
      locationRepo,
      locationService: FakeLocationService(),
    );
    await vm.ready;
    // TASK 12.3: the plan is read-only outside the ViewModel.
    while (vm.captureBlocks.isNotEmpty) {
      await vm.removeCaptureBlock(0);
    }
  });

  tearDown(() async {
    await database.close();
  });

  Widget wrap() {
    return MultiProvider(
      providers: vm.providers,
      // Home hosts the card inside a scrolling ListView; since TASK 5.6 the
      // card is taller than the 800x600 test surface, so scroll it here too.
      child: const MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: CapturePlanWidget())),
      ),
    );
  }

  testWidgets('large text stacks capture actions within a document group', (
    tester,
  ) async {
    // Use the shipped face for the constrained-width regression. Ahem's
    // equal-width glyphs do not represent the production button geometry.
    final bytes = File('assets/fonts/Geist.ttf').readAsBytesSync();
    await (FontLoader(
      'Geist',
    )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
    tester.view.physicalSize = const Size(375, 1000);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    await vm.addCaptureBlock(
      CaptureBlock(
        frameType: FrameType.light,
        exposureTimeSeconds: 60,
        frameCount: 120,
      ),
    );
    await tester.pumpWidget(
      MultiProvider(
        providers: vm.providers,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 36),
                child: CapturePlanWidget(includeSummary: false),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final add = find.byKey(const Key('capturePlan.addBlock'));
    final calibration = find.byKey(const Key('capturePlan.buildCalibration'));
    final addRect = tester.getRect(add);
    final calibrationRect = tester.getRect(calibration);
    expect(addRect.width, 303);
    expect(calibrationRect.width, addRect.width);
    expect(calibrationRect.top, greaterThanOrEqualTo(addRect.bottom + 8));
    expect(addRect.height, greaterThanOrEqualTo(48));
    expect(calibrationRect.height, greaterThanOrEqualTo(48));
    await tester.ensureVisible(add);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'capture actions');
    await tester.tap(add);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('blockEditor.screen')), findsOneWidget);
    expect(vm.captureBlocks, hasLength(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty exposure and frame count are rejected, not defaulted', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());
    await tester.tap(find.byKey(const Key('capturePlan.addLights')));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Add block'));
    await tester.pumpAndSettle();

    // The dialog is still open (validation failed) and no block was added.
    expect(find.byKey(const Key('blockEditor.screen')), findsOneWidget);
    expect(find.text('Enter seconds, e.g. 60, 0.5 or 1/14'), findsOneWidget);
    expect(find.text('Enter a whole number of at least 1'), findsOneWidget);
    expect(vm.captureBlocks, isEmpty);
  });

  testWidgets('a zero or negative exposure is rejected', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.tap(find.byKey(const Key('capturePlan.addLights')));
    await tester.pumpAndSettle();

    await tester.enterText(blockField('Exposure (seconds)'), '0');
    await tester.enterText(blockField('Frames'), '10');
    await tester.tap(find.widgetWithText(FilledButton, 'Add block'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('blockEditor.screen')), findsOneWidget);
    expect(vm.captureBlocks, isEmpty);
  });

  testWidgets('valid input adds a block and closes the dialog', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.tap(find.byKey(const Key('capturePlan.addLights')));
    await tester.pumpAndSettle();

    await tester.enterText(blockField('Exposure (seconds)'), '120');
    await tester.enterText(blockField('Frames'), '15');
    await tester.tap(find.widgetWithText(FilledButton, 'Add block'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('blockEditor.screen')), findsNothing);
    expect(vm.captureBlocks, hasLength(1));
    expect(vm.captureBlocks.single.exposureTimeSeconds, 120.0);
    expect(vm.captureBlocks.single.frameCount, 15);
  });

  testWidgets(
    'tapping a block opens a pre-filled edit dialog that updates it',
    (tester) async {
      await vm.addCaptureBlock(
        CaptureBlock(
          frameType: FrameType.light,
          filterName: 'L',
          exposureTimeSeconds: 60.0,
          frameCount: 30,
        ),
      );
      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();
      // S1.7 (UX-19): "60 s", not "60.0s". Hybrid block (plan.js
      // blockRow): the title, then count × exposure = integration.
      expect(find.text('Light · L'), findsOneWidget);
      expect(find.text('30 × 60 s = 30 min integration'), findsOneWidget);

      await tester.tap(find.byKey(const Key('capture.edit.0')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('blockEditor.screen')), findsOneWidget);
      expect(find.text('60'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);

      await tester.enterText(blockField('Frames'), '45');
      await tester.tap(find.widgetWithText(FilledButton, 'Apply changes'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('blockEditor.screen')), findsNothing);
      expect(vm.captureBlocks, hasLength(1));
      expect(vm.captureBlocks.single.frameCount, 45);
      expect(vm.captureBlocks.single.exposureTimeSeconds, 60.0);
      expect(find.text('45 × 60 s = 45 min integration'), findsOneWidget);
    },
  );

  testWidgets('stacking gain is labeled as relative, not SNR', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.text('Relative stacking gain'), findsOneWidget);
    expect(
      find.text(
        'Relative gain is ideal √N within comparable light frames, not '
        'absolute signal-to-noise.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('SNR'), findsNothing);
  });

  testWidgets('unknown storage renders as Unknown, not a fabricated 0.0 MB', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(vm.estimatedStorageMB, isNull);
    expect(
      find.descendant(
        of: find.byKey(const Key('capturePlan.storage')),
        matching: find.text('Unknown'),
      ),
      findsOneWidget,
    );
    expect(find.textContaining('0.0 MB'), findsNothing);
  });

  // S1.8 (RD-03, SCI-05; UX-20): the ISO/gain label, and its helper wraps
  // instead of being cut off (the audit saw it cut at one line on a 412 dp
  // phone). The test font draws every glyph a full em wide, so it is more
  // pessimistic than Roboto; one line overflows here too.
  testWidgets('the ISO/gain field is labelled neutrally; its helper wraps', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await vm.plan.setEquipment(_dslr);
    await tester.pumpWidget(wrap());
    await tester.tap(find.byKey(const Key('capturePlan.addLights')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('blockDialog.gainValue')));
    await tester.pumpAndSettle();
    expect(find.text('ISO (optional)'), findsOneWidget);
    expect(find.textContaining('ensitivity'), findsNothing);
    final helper = find.text('Leave blank to keep it unrecorded.');
    expect(
      tester.renderObject<RenderParagraph>(helper).didExceedMaxLines,
      isFalse,
    );
  });

  // ADR-021 C13: without a camera type no ISO or gain kind is offered.
  testWidgets('without a rig the dialog names the camera-type remedy', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());
    await tester.tap(find.byKey(const Key('capturePlan.addLights')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('blockDialog.gainKind')), findsNothing);
    expect(find.byKey(const Key('blockDialog.chooseClass')), findsOneWidget);
    expect(find.textContaining('ensitivity'), findsNothing);
  });

  testWidgets('the dialog saves a calibration policy and a typed gain', (
    tester,
  ) async {
    await vm.plan.setEquipment(_dslr);
    await tester.pumpWidget(wrap());
    await tester.tap(find.byKey(const Key('capturePlan.addLights')));
    await tester.pumpAndSettle();

    await chooseSegment(tester, 'blockDialog.frameType', 'Dark');

    // Hybrid: the planned timing is in Details.
    await openBlockDisclosure(tester, 'blockDialog.details');
    await tester.ensureVisible(find.byKey(const Key('blockDialog.policy')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('blockDialog.policy')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('During the window').last);
    await tester.pumpAndSettle();

    // The calibration tip (S7.3a) sits above the fields.
    await tester.ensureVisible(find.byKey(const Key('blockDialog.gainValue')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('blockDialog.gainValue')),
      '800',
    );

    await tester.enterText(blockField('Exposure (seconds)'), '60');
    await tester.enterText(blockField('Frames'), '10');
    await tester.tap(find.widgetWithText(FilledButton, 'Add block'));
    await tester.pumpAndSettle();

    final b = vm.captureBlocks.single;
    expect(b.frameType, FrameType.dark);
    expect(b.calibrationPolicy, CalibrationPolicy.inWindow);
    expect(b.gain, CaptureGain.iso(800));
  });

  testWidgets('breakdown, "Not included" assumptions and gain help render', (
    tester,
  ) async {
    await vm.addCaptureBlock(
      CaptureBlock(
        frameType: FrameType.light,
        filterName: 'Ha',
        exposureTimeSeconds: 300,
        frameCount: 20,
      ),
    );
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    // S6.7: the breakdown and the √N help are one tap away (Hybrid: Budget
    // and assumptions, Stacking gain details); the gain stays visible in
    // the estimate. The lines carry the glossary's names (RD-14).
    expect(
      find.descendant(
        of: find.byKey(const Key('estimate.gain')),
        matching: find.text('×4.47'),
      ),
      findsOneWidget,
    );
    expect(find.text('Integration (light exposure)'), findsNothing);
    await tester.ensureVisible(find.text('Budget and assumptions'));
    await tester.tap(find.text('Budget and assumptions'));
    await tester.pumpAndSettle();
    expect(find.text('Integration (light exposure)'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('budget.integration')),
        matching: find.text('1 h 40 min'),
      ),
      findsOneWidget,
    ); // 20 x 300 s, also shown in the estimate.
    expect(find.text('Imaging time (lights + overheads)'), findsOneWidget);
    expect(find.text('Total time'), findsOneWidget);
    // The assumptions sit in the same disclosure: setup in the facts, then
    // dither, refocus, filter change, flip and setup in the panel.
    expect(find.text('Not included'), findsNWidgets(6));
    expect(find.text('5 s'), findsOneWidget); // per-frame default
    expect(find.text('15%'), findsOneWidget);

    await tester.ensureVisible(find.text('Stacking gain details'));
    await tester.tap(find.text('Stacking gain details'));
    await tester.pumpAndSettle();
    // F11 (C16): the group names its ISO or gain, here not recorded.
    expect(
      find.textContaining('Ha · 300 s · ISO or gain not recorded'),
      findsWidgets,
    );
    expect(find.byKey(const Key('capturePlan.gainHelp')), findsOneWidget);
    expect(
      find.textContaining("isn't absolute signal-to-noise"),
      findsOneWidget,
    );
  });

  // TASK 8.6 acceptance: a phone with a 30 s block shows the NPF value and a
  // warning. Guidance only: the block stays in the plan.
  testWidgets('a phone on a tripod with a 30 s light block is warned', (
    tester,
  ) async {
    const phone = EquipmentProfile(
      id: 1,
      name: 'Phone',
      sensorWidthMm: 9.8,
      sensorHeightMm: 7.3,
      pixelPitchUm: 1.22,
      resolutionWidthPx: 8064,
      resolutionHeightPx: 6048,
      focalLengthMm: 6.86,
      focalRatio: 1.78,
      trackingType: TrackingType.untracked,
    );
    const target = AstroTarget(
      id: 1,
      catalogId: 'M42',
      rightAscension: 83.82,
      declination: -5.39,
      type: 'Nebula',
    );
    await tester.runAsync(() async {
      await vm.setEquipment(phone);
      await vm.setTarget(target);
      await vm.addCaptureBlock(
        CaptureBlock(
          frameType: FrameType.light,
          exposureTimeSeconds: 30,
          frameCount: 20,
        ),
      );
      await vm.addCaptureBlock(
        CaptureBlock(
          frameType: FrameType.light,
          exposureTimeSeconds: 2,
          frameCount: 100,
        ),
      );
    });
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    final npf = vm.rigCapability!.npf!;
    expect(npf.seconds, lessThan(30));
    expect(
      find.byKey(const Key('capture.subWarning')),
      findsOneWidget,
      reason: 'only the 30 s block, not the 2 s one',
    );
    expect(
      find.textContaining('Longer than the recommended max sub'),
      findsOneWidget,
    );
    expect(vm.captureBlocks, hasLength(2), reason: 'never blocks the plan');
  });

  testWidgets('a guided rig without a maximum exposure gets no warning', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await vm.setEquipment(
        const EquipmentProfile(
          id: 2,
          name: 'Guided scope',
          sensorWidthMm: 23.5,
          sensorHeightMm: 15.7,
          pixelPitchUm: 3.76,
          resolutionWidthPx: 6248,
          resolutionHeightPx: 4176,
          focalLengthMm: 400,
          focalRatio: 5.6,
          trackingType: TrackingType.guided,
        ),
      );
      await vm.addCaptureBlock(
        CaptureBlock(
          frameType: FrameType.light,
          exposureTimeSeconds: 600,
          frameCount: 10,
        ),
      );
    });
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('capture.subWarning')), findsNothing);
  });
}
