// F12 A1/A3 (S14.12; PD-10/14; SP11): the assumptions panel shows the values
// the calculation uses, exactly, and how often this plan's budget counts
// each included overhead; the focus reminder is words only, with no value
// or control, and the panel says the settings are global.

import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/planning_preferences.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/domain/services/capture_budget_calculator.dart';
import 'package:astroplan/domain/services/fit_analyzer.dart';
import 'package:astroplan/domain/models/visibility_window.dart';
import 'package:astroplan/presentation/widgets/capture_plan/capture_assumptions_panel.dart';
import 'package:astroplan/presentation/widgets/capture_plan_widget.dart';
import 'package:astroplan/presentation/widgets/planner_sections.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_location_service.dart';
import '../../support/no_snapshot_weather.dart';
import '../../support/planner_harness.dart';

class _NoForecast with NoSnapshotWeather implements WeatherRepository {}

CaptureBlock _light(String filter, int n) => CaptureBlock(
  frameType: FrameType.light,
  filterName: filter,
  exposureTimeSeconds: 60,
  frameCount: n,
);

void main() {
  late AppDatabase db;
  late PlannerHarness vm;

  Future<void> start(WidgetTester tester, PlanningPreferences p) async {
    tester.view.physicalSize = const Size(412, 5000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      SharedPreferences.setMockInitialValues({});
      db = AppDatabase(NativeDatabase.memory());
      vm = PlannerHarness(
        DriftTargetRepository(db),
        DriftEquipmentRepository(db),
        _NoForecast(),
        DriftLocationRepository(db),
        locationService: FakeLocationService(),
      );
      await vm.ready;
      await vm.setPlanningPreferences(p);
      for (final b in [_light('Ha', 10), _light('OIII', 10)]) {
        await vm.plan.addCaptureBlock(b);
      }
      await vm.disclosure.setOpen(PlannerSections.assumptions, true);
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
    await tester.pump(const Duration(seconds: 1));
  }

  String row(WidgetTester tester, String label) {
    final r = find.ancestor(of: find.text(label), matching: find.byType(Row));
    return tester
        .widgetList<Text>(
          find.descendant(of: r.first, matching: find.byType(Text)),
        )
        .last
        .data!;
  }

  testWidgets('A1: the effective values, written exactly, with how often '
      'this plan counts each', (tester) async {
    await start(
      tester,
      PlanningPreferences(
        perFrameOverheadSeconds: 2.5,
        ditherEveryNFrames: 3,
        ditherSettleSeconds: 15,
        refocusEveryMinutes: 10,
        refocusSeconds: 90,
        filterChangeSeconds: 30,
        meridianFlipSeconds: 300,
        setupMinutes: 30,
      ),
    );
    final p = vm.planningPreferences;
    final budget = vm.captureBudget;
    final o = CaptureOverheads.fromPreferences(p);
    // The value the budget uses (2,500 ms), not a rounded one ("3 s").
    expect(o.perFrameMs, 2500);
    expect(row(tester, 'Time between frames'), '2.5 s');
    final dithers = budget.countOf(BudgetEventKind.dither);
    final refocus = budget.countOf(BudgetEventKind.refocus);
    expect(dithers, greaterThan(1));
    expect(refocus, greaterThan(1));
    expect(
      row(tester, 'Dither'),
      'every 3 lights, 15 s · $dithers times in this plan',
    );
    expect(
      row(tester, 'Refocus'),
      'every 10 min, 90 s · $refocus times in this plan',
    );
    expect(budget.countOf(BudgetEventKind.filterChange), 1);
    expect(row(tester, 'Filter change'), '30 s · once in this plan');
    expect(budget.countOf(BudgetEventKind.meridianFlip), 0);
    expect(
      row(tester, 'Meridian flip'),
      '5 min · not counted: no meridian crossing in the window',
    );
    expect(row(tester, 'Setup'), '30 min before the first window');
    expect(row(tester, 'Feasibility margin'), '15 %');
    expect(
      CaptureAssumptionsPanel.rows(p, budget).map((r) => r.$2),
      containsAll([
        '2.5 s',
        'every 3 lights, 15 s · $dithers times in this plan',
        '30 s · once in this plan',
      ]),
    );
  });

  testWidgets('A1: off reads Not included; an included overhead the plan '
      'never reaches says so', (tester) async {
    await start(
      tester,
      PlanningPreferences(ditherEveryNFrames: 50, filterChangeSeconds: null),
    );
    expect(
      row(tester, 'Dither'),
      'every 50 lights, 15 s · not reached by this plan',
    );
    for (final off in ['Refocus', 'Filter change', 'Meridian flip', 'Setup']) {
      expect(row(tester, off), 'Not included', reason: off);
    }
  });

  // The optional Moon and cloud gates (ADR-013 G4/G5) shape the window the
  // fit uses: when on, the panel shows them with their thresholds; off,
  // they change nothing and are not listed.
  testWidgets('A1: the Moon and cloud gates, when on, with the thresholds '
      'the window uses', (tester) async {
    await start(
      tester,
      PlanningPreferences(
        moonGateEnabled: true,
        moonGateMinIlluminationPct: 40,
        cloudGateEnabled: true,
        cloudGateMaxPct: 70,
      ),
    );
    final gates = vm.planningPreferences.optionalGates;
    expect(gates.moonMinIlluminationPct, 40);
    expect(gates.cloudMaxPct, 70);
    expect(
      row(tester, 'Moon gate'),
      'excludes time when the Moon is up and at least 40 % lit',
    );
    expect(
      row(tester, 'Cloud gate'),
      'excludes forecast hours with more than 70 % cloud',
    );
  });

  testWidgets('A1: gates that are off are not listed', (tester) async {
    await start(tester, PlanningPreferences(cloudGateEnabled: true));
    expect(find.text('Moon gate'), findsNothing);
    expect(
      row(tester, 'Cloud gate'),
      'excludes forecast hours with more than 50 % cloud',
    );
  });

  testWidgets('A3: the focus reminder is words only; the scope is said', (
    tester,
  ) async {
    await start(tester, PlanningPreferences());
    final panel = find.byKey(const Key('capturePlan.assumptions'));
    expect(
      find.descendant(
        of: panel,
        matching: find.text(CaptureAssumptionsPanel.focusReminder),
      ),
      findsOneWidget,
    );
    expect(CaptureAssumptionsPanel.focusReminder, contains('star'));
    for (final control in [Slider, Switch, DropdownButton]) {
      expect(
        find.descendant(of: panel, matching: find.byType(control)),
        findsNothing,
        reason: '$control',
      );
    }
    expect(
      find.descendant(
        of: panel,
        matching: find.text(CaptureAssumptionsPanel.scope),
      ),
      findsOneWidget,
    );
    expect(find.text('Change in Settings'), findsOneWidget);
    // Four explicitly approved plan assumptions, none records focus.
    expect(find.byType(TextFormField), findsNothing);
    await tester.tap(find.byKey(const Key('planOverride.edit')));
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsNWidgets(4));
  });

  testWidgets('explicit plan overrides apply together, validate and reset', (
    tester,
  ) async {
    await start(tester, PlanningPreferences());
    final before = vm.analysis.captureBudget;
    final global = vm.planningPreferences.perFrameOverheadSeconds;
    await tester.tap(find.byKey(const Key('planOverride.edit')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('planOverride.0')), '7.5');
    await tester.enterText(find.byKey(const Key('planOverride.1')), '15');
    await tester.enterText(find.byKey(const Key('planOverride.2')), '10');
    await tester.enterText(find.byKey(const Key('planOverride.3')), '30');
    expect(vm.plan.planOverrides, isNull, reason: 'typing is a local draft');
    await tester.tap(find.byKey(const Key('planOverride.apply')));
    await tester.pumpAndSettle();
    expect(vm.plan.planOverrides!.interframeSeconds, 7.5);
    expect(vm.analysis.captureBudget.setupMs, 900000);
    expect(vm.analysis.captureBudget.integrationMs, before.integrationMs);
    expect(vm.planningPreferences.perFrameOverheadSeconds, global);
    expect(row(tester, 'Feasibility margin'), '600 s (this plan)');
    await tester.tap(find.byKey(const Key('planOverride.edit')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextFormField>(find.byKey(const Key('planOverride.1')))
          .controller!
          .text,
      '15',
    );
    await tester.enterText(find.byKey(const Key('planOverride.3')), '0');
    await tester.tap(find.byKey(const Key('planOverride.apply')));
    await tester.pumpAndSettle();
    expect(
      find.text('Enter a positive number or leave empty.'),
      findsOneWidget,
    );
    expect(vm.plan.planOverrides!.bytesPerFrame, 30000000);
    await tester.tap(find.byKey(const Key('planOverride.reset')));
    await tester.pumpAndSettle();
    expect(
      vm.plan.planOverrides,
      isNotNull,
      reason: 'Reset is local until Apply',
    );
    await tester.tap(find.byKey(const Key('planOverride.apply')));
    await tester.pumpAndSettle();
    expect(vm.plan.planOverrides, isNull);
    expect(vm.analysis.captureBudget.acquisitionMs, before.acquisitionMs);
  });
  testWidgets(
    'assumptions Cancel and Back preserve values with keyboard at 200%',
    (tester) async {
      await start(tester, PlanningPreferences());
      tester.view.physicalSize = const Size(412, 915);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pump();
      await tester.ensureVisible(find.byKey(const Key('planOverride.edit')));
      await tester.tap(find.byKey(const Key('planOverride.edit')));
      await tester.pumpAndSettle();
      final field = find.byKey(const Key('planOverride.0'));
      await tester.ensureVisible(field);
      await tester.enterText(field, '8');
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('planOverride.apply')).hitTestable(),
        findsOneWidget,
      );
      expect(vm.plan.planOverrides, isNull);
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('unsaved.cancel')));
      await tester.pumpAndSettle();
      expect(tester.widget<TextFormField>(field).controller!.text, '8');
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('unsaved.discard')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('planOverride.apply')), findsNothing);
      expect(vm.plan.planOverrides, isNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('200%: each override label wraps whole, with its unit, and '
      'names its field (migration review F2)', (tester) async {
    await start(tester, PlanningPreferences());
    tester.view.physicalSize = const Size(412, 915);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('planOverride.edit')));
    await tester.tap(find.byKey(const Key('planOverride.edit')));
    await tester.pumpAndSettle();
    final handle = tester.ensureSemantics();
    for (final label in [
      'Time between frames (seconds)',
      'Setup outside the window (minutes)',
      'Fit margin (minutes)',
      'File size per frame (MB)',
    ]) {
      final text = find.text(label);
      await tester.ensureVisible(text);
      final paragraph = tester.renderObject<RenderParagraph>(text);
      expect(paragraph.didExceedMaxLines, isFalse, reason: label);
      expect(find.bySemanticsLabel(label), findsWidgets, reason: label);
    }
    handle.dispose();
    expect(tester.takeException(), isNull);
  });

  test('A3: an AF or MF record (and white balance) changes no budget, group '
      'or fit', () {
    final plain = [_light('Ha', 30), _light('OIII', 30)];
    final windows = [
      VisibilityWindow(
        start: DateTime.utc(2026, 11, 10, 18),
        end: DateTime.utc(2026, 11, 10, 19),
      ),
    ];
    final o = CaptureOverheads.fromPreferences(
      PlanningPreferences(refocusEveryMinutes: 20),
    );
    (CaptureBudget, FitResult, int?) of(List<CaptureBlock> blocks) {
      final b = CaptureBudgetCalculator.calculate(blocks: blocks, overheads: o);
      return (
        b,
        FitAnalyzer.analyze(budget: b, windows: windows),
        FitAnalyzer.maxFramesForBlock(
          blocks: blocks,
          blockIndex: 1,
          windows: windows,
          overheads: o,
        ),
      );
    }

    final base = of(plain);
    for (final focus in FocusMode.values) {
      final recorded = of([
        for (final b in plain)
          b.copyWith(
            focusMode: () => focus,
            whiteBalance: () => WhiteBalance.kelvin(4000),
          ),
      ]);
      expect(
        recorded.$1.sequence.map((e) => '$e'),
        base.$1.sequence.map((e) => '$e'),
        reason: '$focus',
      );
      expect(recorded.$1.sessionBudgetMs, base.$1.sessionBudgetMs);
      expect(
        recorded.$1.lightGroups.map((g) => (g.frames, g.exposureMs)),
        base.$1.lightGroups.map((g) => (g.frames, g.exposureMs)),
      );
      expect(
        (recorded.$2.state, recorded.$2.placedMs, recorded.$2.reason),
        (base.$2.state, base.$2.placedMs, base.$2.reason),
      );
      expect(recorded.$3, base.$3);
    }
  });
}
