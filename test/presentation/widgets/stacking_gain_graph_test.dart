// S6.11 (P6.10) and F11 (PD-05 O2b; ADR-021 C16): one relative √N line per
// comparable group stays in the plan's outputs; the graph, one per group,
// is in Details (collapsed, so no graph before Save). Each draws the
// domain's points against integration time, normalized to the plan (1.00x
// at the plan), names its points, gives a text alternative, and does not
// overflow at 200 % text in the light, dark and field themes.

import 'package:astroplan/core/theme/app_theme.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/presentation/shared/app_words.dart';
import 'package:astroplan/presentation/widgets/capture_plan/capture_budget_summary.dart';
import 'package:astroplan/presentation/widgets/capture_plan/stacking_gain_graph.dart';
import 'package:astroplan/presentation/widgets/capture_plan_widget.dart';
import 'package:astroplan/presentation/widgets/planner_sections.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_location_service.dart';
import '../../support/no_snapshot_weather.dart';
import '../../support/planner_harness.dart';

class _NoForecast with NoSnapshotWeather implements WeatherRepository {}

CaptureBlock _light(double s, int n, String? filter, [CaptureGain? gain]) =>
    CaptureBlock(
      frameType: FrameType.light,
      filterName: filter,
      exposureTimeSeconds: s,
      frameCount: n,
      gain: gain ?? CaptureGain.none,
    );

void main() {
  late AppDatabase db;
  late PlannerHarness vm;

  Future<void> start(WidgetTester tester, {ThemeData? theme}) async {
    tester.view.physicalSize = const Size(412, 4000);
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
      final g100 = CaptureGain.gain(100);
      for (final b in [
        _light(60, 100, 'Ha', g100),
        _light(60, 20, ' HA', g100), // same group (C15 filter): 120 frames
        _light(300, 12, 'Ha', g100), // another exposure: another group
        _light(30, 1, null), // gain not recorded: on its own
      ]) {
        await vm.plan.addCaptureBlock(b);
      }
    });
    addTearDown(() => tester.runAsync(db.close));
    await tester.pumpWidget(
      MultiProvider(
        providers: vm.providers,
        child: MaterialApp(
          theme: theme,
          home: const Scaffold(
            body: SingleChildScrollView(child: CapturePlanWidget()),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
  }

  Future<void> openCurves(WidgetTester tester) async {
    await tester.tap(
      find.byKey(const Key('section.${PlannerSections.gainCurve}')),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('one graph per group, never combined; each draws the domain\'s '
      'points and marks the group\'s value', (tester) async {
    await start(tester);
    expect(find.byType(StackingGainGraph), findsNothing, reason: 'Details');
    await openCurves(tester);
    final groups = vm.captureBudget.lightGroups;
    expect(groups, hasLength(3));
    final graphs = tester
        .widgetList<StackingGainGraph>(find.byType(StackingGainGraph))
        .toList();
    expect(graphs, hasLength(groups.length));
    for (final (i, g) in groups.indexed) {
      final curve = graphs[i].curve;
      expect(curve.frames, g.frames);
      expect(curve.markedGain, g.relativeStackingGain);
      expect(curve.points, g.gainCurve.points);
      final painter =
          tester
                  .widget<CustomPaint>(
                    find.descendant(
                      of: find.byWidget(graphs[i]),
                      // S6.16: the plan's swatch is a second painter.
                      matching: find.byWidgetPredicate(
                        (w) =>
                            w is CustomPaint &&
                            w.painter is StackingGainPainter,
                      ),
                    ),
                  )
                  .painter!
              as StackingGainPainter;
      expect(painter.curve.points, g.gainCurve.points);
    }
    expect(groups.first.frames, 120, reason: 'the two Ha 60 s blocks');
  });

  testWidgets('the label is unchanged and the number stays, per group with '
      'its reference; the text alternative is relative to the plan', (
    tester,
  ) async {
    await start(tester);
    final handle = tester.ensureSemantics();
    expect(find.text(AppWords.relativeStackingGain), findsOneWidget);
    expect(find.textContaining('SNR'), findsNothing);
    final rows = [
      ('Ha · 60 s · gain 100 × 120', '11.0x'),
      ('Ha · 300 s · gain 100 × 12', '3.5x'),
      ('No filter · 30 s · ISO or gain not recorded × 1', '1.0x'),
    ];
    for (final (i, (label, value)) in rows.indexed) {
      final row = find.byKey(Key('capturePlan.gain.$i'));
      expect(
        find.descendant(of: row, matching: find.text(label)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: row, matching: find.text(value)),
        findsOneWidget,
      );
    }
    expect(
      find.text(CaptureBudgetSummary.notComparable),
      findsOneWidget,
      reason: 'the unrecorded block says why it stands alone',
    );
    await openCurves(tester);
    expect(
      find.bySemanticsLabel(
        RegExp(
          RegExp.escape(
            'Relative improvement over integration time, Ha · 60 s · gain 100: '
            '1.00x at your plan, 2 h (120 frames); 0.71x at half that time; '
            '1.41x at 4 h (240 frames), for comparison. Relative to your plan, '
            'not a signal-to-noise ratio.',
          ),
        ),
      ),
      findsOneWidget,
    );
    handle.dispose();
  });

  // TD-076 (S6.16): the plan's own point is named with its count and value,
  // beside a swatch drawn like the dot; the curve's end is a comparison,
  // never a target or a recommendation. √N and the points are unchanged.
  testWidgets("each graph names the plan's point, and its end as a "
      'comparison, in integration time', (tester) async {
    await start(tester);
    await openCurves(tester);
    final graphs = tester
        .widgetList<StackingGainGraph>(find.byType(StackingGainGraph))
        .toList();
    final labels = [
      (
        'Your plan: 2 h (120 frames) · 1.00x',
        'For comparison: 4 h (240 frames) · 1.41x',
      ),
      (
        'Your plan: 1 h (12 frames) · 1.00x',
        'For comparison: 2 h (24 frames) · 1.41x',
      ),
      (
        'Your plan: 30 s (1 frame) · 1.00x',
        'For comparison: 2 min (4 frames) · 2.00x',
      ),
    ];
    for (final (i, (plan, comparison)) in labels.indexed) {
      final graph = find.byWidget(graphs[i]);
      expect(
        tester
            .widget<Text>(
              find.descendant(
                of: graph,
                matching: find.byKey(const Key('gainGraph.plan')),
              ),
            )
            .data,
        plan,
      );
      expect(
        tester
            .widget<Text>(
              find.descendant(
                of: graph,
                matching: find.byKey(const Key('gainGraph.comparison')),
              ),
            )
            .data,
        comparison,
      );
      // The swatch beside the plan's label draws the plan's dot.
      expect(
        find.descendant(
          of: graph,
          matching: find.byWidgetPredicate(
            (w) => w is CustomPaint && w.painter is PlanPointSwatch,
          ),
        ),
        findsOneWidget,
      );
    }
    for (final word in ['target', 'recommend', 'SNR', 'potential']) {
      expect(
        find.descendant(
          of: find.byType(StackingGainGraph),
          matching: find.textContaining(word),
        ),
        findsNothing,
        reason: word,
      );
    }
  });

  for (final (name, theme) in [
    ('light', AppTheme.light),
    ('dark', AppTheme.dark),
    ('field', AppTheme.fieldTheme),
  ]) {
    testWidgets('no overflow at 200 % text ($name)', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await start(tester, theme: theme);
      await openCurves(tester);
      expect(find.byType(StackingGainGraph), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    });
  }
}
