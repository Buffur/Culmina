import 'dart:async';

import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/target_alias.dart';
import 'package:astroplan/presentation/screens/home/plan_target_screen.dart';
import 'package:astroplan/presentation/screens/target/target_selection_screen.dart';
import 'package:astroplan/presentation/screens/equipment/equipment_selection_screen.dart';
import 'package:astroplan/presentation/shared/list_mode.dart';
import 'package:astroplan/presentation/viewmodels/library_viewmodels.dart';
import 'package:astroplan/presentation/viewmodels/session_plan_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../../support/wave1_capture.dart';
import '../../../support/phase2_state_capture.dart';
import '../../../support/held_library_reads.dart';

class _Targets extends ChangeNotifier implements TargetsViewModel {
  final reads = <Completer<List<AstroTarget>>>[];
  @override
  Future<List<AstroTarget>> search(String query) {
    final read = Completer<List<AstroTarget>>();
    reads.add(read);
    return read.future;
  }

  @override
  Future<Map<String, List<TargetAlias>>> aliases() async => {};
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Plan extends ChangeNotifier implements SessionPlanViewModel {
  AstroTarget? chosen;
  EquipmentProfile? rig;
  int applied = 0;
  @override
  AstroTarget? get selectedTarget => chosen;
  @override
  EquipmentProfile? get selectedEquipment => rig;
  @override
  Future<void> setTarget(AstroTarget target) async {
    chosen = target;
    applied++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(loadWave1Font);
  for (final theme in ['light', 'dark', 'field']) {
    testWidgets(
      '$theme target search hides staged choice and ignores obsolete answers',
      (t) async {
        t.view.physicalSize = const Size(375, 812);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.reset);
        final targets = _Targets();
        final plan = _Plan();
        final navigator = GlobalKey<NavigatorState>();
        addTearDown(targets.dispose);
        addTearDown(plan.dispose);
        await t.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<TargetsViewModel>.value(value: targets),
              ChangeNotifierProvider<SessionPlanViewModel>.value(value: plan),
            ],
            child: phase2Frame(
              theme: theme,
              applyFieldFilter: false,
              child: wave1App(
                theme,
                navigatorKey: navigator,
                home: const Scaffold(body: Text('Caller')),
              ),
            ),
          ),
        );
        unawaited(
          navigator.currentState!.push(
            MaterialPageRoute<void>(builder: (_) => const PlanTargetScreen()),
          ),
        );
        await t.pump();
        await t.pump(const Duration(milliseconds: 400));
        const selected = AstroTarget(
          id: 1,
          catalogId: 'Synthetic staged target',
          rightAscension: 10,
          declination: 20,
          type: 'Galaxy',
          source: 'user',
        );
        targets.reads.single.complete([selected]);
        await t.pumpAndSettle();
        await t.tap(find.byKey(const Key('planTarget.choice.1')));
        await t.pumpAndSettle();
        await t.enterText(find.byKey(const Key('planTarget.search')), 'old');
        await t.pump();
        final oldAll = targets.reads.last;
        await t.enterText(find.byKey(const Key('planTarget.search')), 'new');
        await t.pump();
        final newAll = targets.reads.last;
        newAll.complete([selected]);
        await t.pump();
        targets.reads.last.complete([]);
        await t.pumpAndSettle();
        expect(find.text('0 results'), findsOneWidget);
        expect(find.byKey(const Key('planTarget.choice.1')), findsNothing);
        oldAll.complete([selected]);
        await t.pump();
        targets.reads.last.complete([selected]);
        await t.pumpAndSettle();
        expect(find.text('0 results'), findsOneWidget);
        expect(find.byKey(const Key('planTarget.choice.1')), findsNothing);
        expect(plan.applied, 0);
        t.testTextInput.hide();
        await t.pumpAndSettle();
        await capturePhase2State(
          t,
          package: 'package2',
          state: 'target-search-hidden-staged-choice',
          theme: theme,
        );
        await t.tap(find.byKey(const Key('planTarget.apply')));
        await t.pumpAndSettle();
        expect(plan.chosen, selected);
        expect(plan.applied, 1);
        expect(find.text('Caller'), findsOneWidget);
        expect(t.takeException(), isNull);
      },
    );
    for (final mode in [ListMode.manage, ListMode.choose]) {
      testWidgets('$theme $mode target library loading/error/empty/search', (
        t,
      ) async {
        t.view.physicalSize = const Size(375, 812);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.reset);
        final targets = _Targets();
        final plan = _Plan();
        addTearDown(targets.dispose);
        addTearDown(plan.dispose);
        await t.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<TargetsViewModel>.value(value: targets),
              ChangeNotifierProvider<SessionPlanViewModel>.value(value: plan),
            ],
            child: phase2Frame(
              theme: theme,
              applyFieldFilter: false,
              child: wave1App(theme, home: TargetSelectionScreen(mode: mode)),
            ),
          ),
        );
        Future<void> capture(String state) => capturePhase2State(
          t,
          package: 'package2',
          state: 'library-target-${mode.name}-$state',
          theme: theme,
        );
        expect(find.text('Loading targets…'), findsOneWidget);
        await capture('pending');
        targets.reads.single.completeError(StateError('private marker'));
        await t.pumpAndSettle();
        expect(find.text('Retry'), findsOneWidget);
        expect(find.textContaining('private marker'), findsNothing);
        await capture('error');
        await t.tap(find.text('Retry'));
        await t.pump();
        expect(find.text('Loading targets…'), findsOneWidget);
        expect(find.text('Retry'), findsNothing);
        await capture('retry-pending');
        targets.reads.last.complete([]);
        await t.pumpAndSettle();
        expect(find.text('No targets found.'), findsOneWidget);
        expect(find.textContaining('None added yet.'), findsOneWidget);
        await capture('empty');
        final search = find.descendant(
          of: find.byKey(const Key('targets.search')),
          matching: find.byType(TextField),
        );
        await t.enterText(search, 'missing');
        await t.pump();
        expect(find.byKey(const Key('targets.searching')), findsOneWidget);
        await capture('search-pending');
        targets.reads.last.complete([]);
        await t.pumpAndSettle();
        expect(find.text('None of your targets match.'), findsOneWidget);
        expect(find.text('No results for "missing".'), findsOneWidget);
        await capture('search-empty');
        await t.enterText(search, '');
        await t.pump();
        const own = AstroTarget(
          id: 1,
          catalogId: 'Synthetic own target',
          rightAscension: 10,
          declination: 20,
          type: 'Galaxy',
          source: 'user',
        );
        const bundled = AstroTarget(
          id: 2,
          catalogId: 'Synthetic catalogue',
          rightAscension: 10,
          declination: 20,
          type: 'Galaxy',
          source: 'catalog:synthetic',
        );
        plan.chosen = own;
        targets.reads.last.complete([own, bundled]);
        await t.pumpAndSettle();
        expect(find.byKey(const Key('targets.row.1')), findsOneWidget);
        await t.ensureVisible(find.byKey(const Key('targets.row.2')));
        expect(find.byKey(const Key('targets.row.2')), findsOneWidget);
        expect(
          find.text('Chosen for this plan'),
          mode == ListMode.choose ? findsOneWidget : findsNothing,
        );
        await capture('populated');
        expect(plan.applied, 0);
        expect(t.takeException(), isNull);
      });

      testWidgets('$theme $mode rigs loading/error/empty/search', (t) async {
        t.view.physicalSize = const Size(375, 812);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.reset);
        final rigs = HeldGearReads();
        final plan = _Plan();
        addTearDown(rigs.dispose);
        addTearDown(plan.dispose);
        await t.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<GearViewModel>.value(value: rigs),
              ChangeNotifierProvider<SessionPlanViewModel>.value(value: plan),
            ],
            child: phase2Frame(
              theme: theme,
              applyFieldFilter: false,
              child: wave1App(
                theme,
                home: EquipmentSelectionScreen(mode: mode),
              ),
            ),
          ),
        );
        Future<void> capture(String state) => capturePhase2State(
          t,
          package: 'package2',
          state: 'library-rig-${mode.name}-$state',
          theme: theme,
        );
        expect(find.text('Loading rigs…'), findsOneWidget);
        await capture('pending');
        rigs.reads.single.completeError(StateError('private marker'));
        await t.pumpAndSettle();
        expect(find.text('Retry'), findsOneWidget);
        await capture('error');
        await t.tap(find.text('Retry'));
        await t.pump();
        expect(find.text('Loading rigs…'), findsOneWidget);
        expect(find.text('Retry'), findsNothing);
        await capture('retry-pending');
        rigs.reads.last.complete([]);
        await t.pumpAndSettle();
        expect(find.byKey(const Key('rigs.empty')), findsOneWidget);
        await capture('empty');
        // Remount a distinct screen State to exercise the loaded list branch.
        await t.pumpWidget(const SizedBox.shrink());
        await t.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<GearViewModel>.value(value: rigs),
              ChangeNotifierProvider<SessionPlanViewModel>.value(value: plan),
            ],
            child: phase2Frame(
              theme: theme,
              applyFieldFilter: false,
              child: wave1App(
                theme,
                home: EquipmentSelectionScreen(mode: mode),
              ),
            ),
          ),
        );
        const selectedRig = EquipmentProfile(
          id: 1,
          name: 'Synthetic rig',
          sensorWidthMm: 23.5,
          sensorHeightMm: 15.6,
          pixelPitchUm: 3.76,
          resolutionWidthPx: 6000,
          resolutionHeightPx: 4000,
          focalLengthMm: 400,
          focalRatio: 5,
        );
        plan.rig = selectedRig;
        rigs.reads.last.complete([selectedRig]);
        await t.pumpAndSettle();
        expect(find.byKey(const Key('rigs.row.1')), findsOneWidget);
        expect(
          find.text('Chosen for this plan'),
          mode == ListMode.choose ? findsOneWidget : findsNothing,
        );
        await capture('populated');
        final search = find.descendant(
          of: find.byKey(const Key('rigs.search')),
          matching: find.byType(TextField),
        );
        await t.enterText(search, 'missing');
        await t.pumpAndSettle();
        expect(find.text('0 of 1 shown'), findsOneWidget);
        await capture('search-empty');
        await t.tap(find.byKey(const Key('rigs.clearSearch')));
        await t.pumpAndSettle();
        expect(find.byKey(const Key('rigs.row.1')), findsOneWidget);
        expect(plan.applied, 0);
        expect(t.takeException(), isNull);
      });
    }
    testWidgets('$theme target pending/error/retry/empty distinguish states', (
      t,
    ) async {
      t.view.physicalSize = const Size(375, 812);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      final targets = _Targets();
      final plan = _Plan();
      addTearDown(targets.dispose);
      addTearDown(plan.dispose);
      await t.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<TargetsViewModel>.value(value: targets),
            ChangeNotifierProvider<SessionPlanViewModel>.value(value: plan),
          ],
          child: phase2Frame(
            theme: theme,
            applyFieldFilter: false,
            child: wave1App(theme, home: const PlanTargetScreen()),
          ),
        ),
      );
      await t.pump();
      expect(find.text('Searching…'), findsWidgets);
      await capturePhase2State(
        t,
        package: 'package2',
        state: 'package2-target-$theme-pending',
        theme: theme,
      );
      targets.reads.single.completeError(StateError('synthetic store error'));
      await t.pumpAndSettle();
      expect(find.text('Results unavailable'), findsOneWidget);
      expect(find.textContaining('synthetic store error'), findsNothing);
      await capturePhase2State(
        t,
        package: 'package2',
        state: 'package2-target-$theme-error',
        theme: theme,
      );
      await t.tap(find.text('Retry'));
      await t.pump();
      expect(find.text('Results unavailable'), findsNothing);
      targets.reads.last.complete([]);
      await t.pumpAndSettle();
      expect(find.text('0 results'), findsOneWidget);
      expect(find.textContaining('No matches.'), findsOneWidget);
      expect(plan.applied, 0);
      expect(t.takeException(), isNull);
      await capturePhase2State(
        t,
        package: 'package2',
        state: 'package2-target-$theme-empty',
        theme: theme,
      );
    });

    testWidgets('$theme 164 target choices keep Apply staged and reachable', (
      t,
    ) async {
      t.view.physicalSize = const Size(375, 812);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      final targets = _Targets();
      final plan = _Plan();
      final navigator = GlobalKey<NavigatorState>();
      addTearDown(targets.dispose);
      addTearDown(plan.dispose);
      await t.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<TargetsViewModel>.value(value: targets),
            ChangeNotifierProvider<SessionPlanViewModel>.value(value: plan),
          ],
          child: phase2Frame(
            theme: theme,
            applyFieldFilter: false,
            child: wave1App(
              theme,
              navigatorKey: navigator,
              home: const Scaffold(body: Text('Caller')),
            ),
          ),
        ),
      );
      unawaited(
        navigator.currentState!.push(
          MaterialPageRoute<void>(builder: (_) => const PlanTargetScreen()),
        ),
      );
      await t.pump();
      await t.pump(const Duration(milliseconds: 400));
      final list = [
        for (var i = 1; i <= 164; i++)
          AstroTarget(
            id: i,
            catalogId: 'Synthetic target $i',
            rightAscension: 10,
            declination: 20,
            type: 'Galaxy',
            source: 'user',
          ),
      ];
      targets.reads.single.complete(list);
      await t.pumpAndSettle();
      final apply = find.byKey(const Key('planTarget.apply'));
      final footer = t.getRect(apply);
      expect(footer.bottom, lessThanOrEqualTo(812));
      expect(footer.height, greaterThanOrEqualTo(48));
      final last = find.byKey(const Key('planTarget.choice.164'));
      await t.scrollUntilVisible(
        last,
        600,
        scrollable: find.byType(Scrollable).first,
      );
      await t.tap(last);
      await t.pumpAndSettle();
      expect(plan.chosen, isNull);
      expect(plan.applied, 0);
      expect(t.getRect(apply), footer);
      await capturePhase2State(
        t,
        package: 'package2',
        state: 'package2-target-$theme-staged-164',
        theme: theme,
      );
      await t.tap(apply);
      await t.pumpAndSettle();
      expect(plan.chosen, list.last);
      expect(plan.applied, 1);
      expect(find.text('Caller'), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  }
}
