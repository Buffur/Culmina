// S6.10 (P6.9; 08 §17): the capture plan's outputs lead with Time needed ·
// Total time (Budget details holds every line); "what fits" comes only from
// the fit's own outputs; storage says what it rests on, or why it is
// unknown and how to supply it; an edit briefly marks what it changed.

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/models/planning_preferences.dart';
import 'package:astroplan/domain/models/spec_confidence.dart';
import 'package:astroplan/domain/models/spec_provenance.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/domain/services/capture_budget_calculator.dart';
import 'package:astroplan/domain/services/fit_analyzer.dart';
import 'package:astroplan/presentation/shared/block_text.dart';
import 'package:astroplan/presentation/shared/change_mark.dart';
import 'package:astroplan/presentation/widgets/capture_plan_widget.dart';
import 'package:astroplan/presentation/widgets/planner_sections.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_device_time_zone.dart';
import '../../support/fake_location_service.dart';
import '../../support/fake_reverse_geocoder.dart';
import '../../support/no_snapshot_weather.dart';
import '../../support/planner_harness.dart';

class _NoForecast with NoSnapshotWeather implements WeatherRepository {}

const _s = 1000; // ms per second

const _m42 = AstroTarget(
  id: 1,
  catalogId: 'M42',
  rightAscension: 83.82,
  declination: -5.39,
  type: 'Nebula',
);

EquipmentProfile _rig({
  double? rawMB,
  Map<EquipmentSpec, SpecProvenance> provenance = const {},
}) => EquipmentProfile(
  id: 1,
  name: 'Refractor',
  sensorWidthMm: 23.5,
  sensorHeightMm: 15.6,
  pixelPitchUm: 3.76,
  resolutionWidthPx: 6000,
  resolutionHeightPx: 4000,
  focalLengthMm: 400,
  focalRatio: 5,
  averageRawFileSizeMB: rawMB,
  specProvenance: provenance,
);

CaptureBlock _light(double s, int n, String filter) => CaptureBlock(
  frameType: FrameType.light,
  filterName: filter,
  exposureTimeSeconds: s,
  frameCount: n,
);

void main() {
  late AppDatabase db;
  late PlannerHarness vm;

  /// The capture plan on a real database: a site, M42 and [rig] (none when
  /// null), with no blocks.
  Future<void> start(WidgetTester tester, {EquipmentProfile? rig}) async {
    tester.view.physicalSize = const Size(412, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      db = AppDatabase(NativeDatabase.memory());
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
      final clock = FixedClock(DateTime.utc(2026, 11, 10, 16));
      vm = PlannerHarness(
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
      final targets = DriftTargetRepository(db);
      final id = await targets.insertTarget(_m42);
      await vm.plan.setTarget((await targets.getTargetById(id))!);
      if (rig != null) {
        final rigs = DriftEquipmentRepository(db);
        final rigId = await rigs.insertEquipment(rig);
        await vm.plan.setEquipment((await rigs.getEquipmentById(rigId))!);
      }
      await vm.plan.idle;
      // Hybrid: the budget facts and the file-size basis are inside Budget
      // and assumptions.
      await vm.disclosure.setOpen(PlannerSections.budgetDetails, true);
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
    await tester.pump();
  }

  Future<void> blocks(WidgetTester tester, List<CaptureBlock> b) async {
    await tester.runAsync(() async {
      while (vm.plan.captureBlocks.isNotEmpty) {
        await vm.plan.removeCaptureBlock(0);
      }
      for (final block in b) {
        await vm.plan.addCaptureBlock(block);
      }
      await vm.plan.idle;
    });
    await tester.pump();
    await tester.pump(const Duration(seconds: 2)); // past any change mark
  }

  // A Text's own words, or a fact's value (its last Text).
  String textOf(WidgetTester tester, Key key) {
    final w = tester.widget(find.byKey(key));
    if (w is Text) return w.data!;
    return tester
        .widgetList<Text>(
          find.descendant(of: find.byKey(key), matching: find.byType(Text)),
        )
        .last
        .data!;
  }

  testWidgets('the window load and the total equal the calculator (ADR-009 '
      '§8 E1)', (tester) async {
    await start(tester, rig: _rig());
    await tester.runAsync(
      () => vm.setPlanningPreferences(
        PlanningPreferences(
          perFrameOverheadSeconds: 2,
          ditherEveryNFrames: 3,
          ditherSettleSeconds: 20,
          refocusEveryMinutes: 60,
          refocusSeconds: 120,
        ),
      ),
    );
    await blocks(tester, [_light(120, 90, 'Ha')]);
    final b = vm.captureBudget;
    expect(b.integrationMs, 10800 * _s);
    expect(b.windowLoadMs, 11920 * _s);
    expect(b.sessionBudgetMs, 11920 * _s);
    // The approved Hybrid design writes capture budgets to the second
    // (`QuantityText.budgetDuration`); 11 920 s is 3 h 18 min 40 s.
    // Budget and assumptions: the window load and the total, each as the
    // calculator gives it.
    String fact(String key) => tester
        .widgetList<Text>(
          find.descendant(
            of: find.byKey(Key(key)),
            matching: find.byType(Text),
          ),
        )
        .last
        .data!;
    expect(fact('budget.timeNeeded'), startsWith('3 h 18 min 40 s'));
    expect(fact('budget.totalTime'), '3 h 18 min 40 s');
  });

  group('storage', () {
    testWidgets('known: equals the budget, with what it rests on', (
      tester,
    ) async {
      await start(tester, rig: _rig(rawMB: 50));
      await blocks(tester, [
        _light(60, 20, 'L'),
        CaptureBlock(
          frameType: FrameType.dark,
          exposureTimeSeconds: 60,
          frameCount: 10,
        ),
      ]);
      expect(vm.captureBudget.storageMB, 1500);
      expect(
        tester
            .widgetList<Text>(
              find.descendant(
                of: find.byKey(const Key('capturePlan.storage')),
                matching: find.byType(Text),
              ),
            )
            .elementAt(1)
            .data,
        // F07: decimal units, two decimals (QuantityText.storage).
        '1.50 GB',
      );
      expect(
        textOf(tester, const Key('capturePlan.storageNote')),
        allOf(
          contains("The rig's RAW size: 50.00 MB a frame"),
          contains('which file it came from was not recorded'),
          isNot(contains('itself')),
        ),
      );
      expect(find.byKey(const Key('capturePlan.setFileSize')), findsNothing);
    });

    testWidgets('known from an estimated RAW size: says so', (tester) async {
      await start(
        tester,
        rig: _rig(
          rawMB: 25,
          provenance: const {
            EquipmentSpec.rawFileSize: SpecProvenance(
              'metadata:dng:file-size',
              SpecConfidence.estimated,
            ),
          },
        ),
      );
      await blocks(tester, [_light(60, 4, 'L')]);
      expect(vm.captureBudget.storageMB, 100);
      expect(
        textOf(tester, const Key('capturePlan.storageNote')),
        contains('It is itself an estimate, from one file.'),
      );
    });

    testWidgets('unknown: says why and how to supply it', (tester) async {
      await start(tester, rig: _rig());
      await blocks(tester, [_light(60, 4, 'L')]);
      expect(vm.captureBudget.storageMB, isNull);
      expect(find.text('Unknown'), findsOneWidget);
      expect(
        textOf(tester, const Key('capturePlan.storageNote')),
        allOf(
          contains('no file measured and no capture format declared'),
          contains('Choose one file'),
          contains("rig's editor"),
        ),
      );
      // F07 A3: a file or a size, never an assumption by camera class.
      expect(find.byKey(const Key('capturePlan.setFileSize')), findsOneWidget);
      expect(find.text('Enter a size'), findsOneWidget);
    });

    testWidgets('unknown without a rig: says there is none', (tester) async {
      await start(tester);
      await blocks(tester, [_light(60, 4, 'L')]);
      expect(
        textOf(tester, const Key('capturePlan.storageNote')),
        contains('no rig chosen'),
      );
      expect(find.byKey(const Key('capturePlan.setFileSize')), findsNothing);
    });
  });

  group('what fits equals the fit\'s outputs', () {
    // F12 (TD-074): every block's answer is the service's own output,
    // `FitAnalyzer.maxFramesForBlock` with every other block as planned.
    void expectRowsMatchTheFit(WidgetTester tester) {
      final fit = vm.fitAnalysis;
      final others =
          vm.captureBudget.blocks
              .where((b) => b.placement == BudgetPlacement.window)
              .length >
          1;
      for (final (i, block) in vm.captureBlocks.indexed) {
        final upTo = FitAnalyzer.maxFramesForBlock(
          blocks: vm.captureBlocks,
          blockIndex: i,
          windows: vm.visibilityWindows,
          overheads: CaptureOverheads.fromPreferences(vm.planningPreferences),
        );
        expect(vm.analysis.framesThatFit(i), upTo, reason: 'block $i');
        if (!block.isLight) continue; // a calibration block's placement
        final expected = BlockText.whatFits(
          block,
          unplaced: fit.unplacedFramesByBlock[i] ?? 0,
          upTo: upTo,
          others: others,
        );
        expect(textOf(tester, Key('capture.whatFits.$i')), expected);
      }
    }

    testWidgets('a short plan: how many more still fit', (tester) async {
      await start(tester, rig: _rig());
      await blocks(tester, [_light(60, 2, 'L')]);
      expect(vm.fitAnalysis.state, FitState.fits);
      final max = vm.analysis.fillWindowFrameCount!;
      expect(max, greaterThan(2));
      expect(vm.analysis.fillWindowSpareFrames, max - 2);
      expect(
        textOf(tester, const Key('capture.whatFits.0')),
        "Fits: room for up to $max frames like this in tonight's window",
      );
      expectRowsMatchTheFit(tester);
    });

    testWidgets('a plan that does not fit: what does not fit, and up to how '
        'many do', (tester) async {
      await start(tester, rig: _rig());
      await blocks(tester, [_light(300, 20, 'Ha'), _light(300, 400, 'OIII')]);
      final fit = vm.fitAnalysis;
      expect(fit.state, FitState.doesNotFit);
      final unplaced = fit.unplacedFramesByBlock[1]!;
      expect(unplaced, greaterThan(0));
      final max = vm.analysis.fillWindowFrameCount!;
      expect(max, greaterThan(0), reason: 'part of the last block fits');
      expect(
        textOf(tester, const Key('capture.whatFits.1')),
        "Only $max of 400 frames fit tonight's window",
      );
      expectRowsMatchTheFit(tester);
    });

    testWidgets('F12 A2: every light block says what fits with the others '
        'as planned; a calibration block only what does not', (tester) async {
      await start(tester, rig: _rig());
      await blocks(tester, [
        _light(60, 4, 'Ha'),
        _light(60, 4, 'OIII'),
        CaptureBlock(
          frameType: FrameType.dark,
          exposureTimeSeconds: 60,
          frameCount: 5,
        ),
      ]);
      expect(vm.fitAnalysis.state, FitState.fits);
      for (final i in [0, 1]) {
        final max = vm.analysis.framesThatFit(i)!;
        expect(max, greaterThan(4));
        expect(
          textOf(tester, Key('capture.whatFits.$i')),
          "Fits: room for up to $max frames like this in tonight's window "
          '(other blocks as planned)',
        );
      }
      expect(vm.analysis.framesThatFit(2), isNull, reason: 'a dark');
      // The dark (taken outside the window) says only where its time goes.
      expect(
        textOf(tester, const Key('capture.whatFits.2')),
        'Outside the imaging window · adds to total time',
      );
      expectRowsMatchTheFit(tester);
    });

    testWidgets('nothing is said while the fit cannot measure the plan', (
      tester,
    ) async {
      await start(tester); // no rig: the target and night are there
      await blocks(tester, [
        CaptureBlock(
          frameType: FrameType.dark,
          exposureTimeSeconds: 60,
          frameCount: 10,
        ),
      ]);
      expect(vm.fitAnalysis.state, FitState.nothingToFit);
      // No fit is claimed; a dark taken outside the window says only where
      // its time goes (plan.js fitLine).
      expect(
        tester.widget<Text>(find.byKey(const Key('capture.whatFits.0'))).data,
        'Outside the imaging window · adds to total time',
      );
    });
  });

  group('cause and effect: a changed value is briefly marked', () {
    double tintOf(WidgetTester tester, Finder mark) =>
        (tester.widget<DecoratedBox>(mark).decoration as BoxDecoration)
            .color!
            .a;

    Future<void> pumpMark(WidgetTester tester, int value, {bool? reduced}) =>
        tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(disableAnimations: reduced ?? false),
              child: ChangeMark(value: value, child: const Text('value')),
            ),
          ),
        );

    final mark = find.byKey(const Key('changeMark'));

    testWidgets('not on the first build; on a change, then fading', (
      tester,
    ) async {
      await pumpMark(tester, 1);
      expect(tintOf(tester, mark), 0);
      await pumpMark(tester, 1);
      expect(tintOf(tester, mark), 0, reason: 'same value');
      await pumpMark(tester, 2);
      await tester.pump(const Duration(milliseconds: 50));
      expect(tintOf(tester, mark), greaterThan(0));
      await tester.pump(const Duration(seconds: 2));
      expect(tintOf(tester, mark), 0);
    });

    testWidgets('never with reduced motion', (tester) async {
      await pumpMark(tester, 1, reduced: true);
      await pumpMark(tester, 2, reduced: true);
      await tester.pump(const Duration(milliseconds: 50));
      expect(tintOf(tester, mark), 0);
    });

    testWidgets('an edit marks Budget and assumptions', (tester) async {
      await start(tester, rig: _rig());
      await blocks(tester, [_light(60, 10, 'L')]);
      final budgetMark = find.ancestor(
        of: find.text('Budget and assumptions'),
        matching: find.byKey(const Key('changeMark')),
      );
      expect(tintOf(tester, budgetMark.first), 0);
      await tester.runAsync(() => vm.plan.addCaptureBlock(_light(60, 5, 'R')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      final changed = find.ancestor(
        of: find.text('Budget and assumptions'),
        matching: find.byKey(const Key('changeMark')),
      );
      expect(tintOf(tester, changed.first), greaterThan(0));
      await tester.runAsync(() => vm.plan.idle);
    });
  });
}
