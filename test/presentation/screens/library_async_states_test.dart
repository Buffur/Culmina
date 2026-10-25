import 'dart:async';

import 'package:astroplan/core/theme/app_theme.dart';
import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/target_alias.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:astroplan/presentation/screens/home/plan_rig_screen.dart';
import 'package:astroplan/presentation/screens/target/target_detail_screen.dart';
import 'package:astroplan/presentation/viewmodels/library_viewmodels.dart';
import 'package:astroplan/presentation/viewmodels/session_plan_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../support/held_library_reads.dart';

const _target = AstroTarget(
  id: 1,
  catalogId: 'M31',
  commonName: 'Andromeda Galaxy',
  rightAscension: 10.68,
  declination: 41.27,
  type: 'Galaxy',
  source: 'catalog:synthetic',
);
const _rig = EquipmentProfile(
  id: 1,
  name: 'Synthetic refractor',
  sensorWidthMm: 23.5,
  sensorHeightMm: 15.6,
  pixelPitchUm: 3.76,
  resolutionWidthPx: 6000,
  resolutionHeightPx: 4000,
  focalLengthMm: 400,
  focalRatio: 5,
);
const _secondRig = EquipmentProfile(
  id: 2,
  name: 'Synthetic lens',
  sensorWidthMm: 23.5,
  sensorHeightMm: 15.6,
  pixelPitchUm: 3.76,
  resolutionWidthPx: 6000,
  resolutionHeightPx: 4000,
  focalLengthMm: 135,
  focalRatio: 2.8,
);

class _Plan extends ChangeNotifier implements SessionPlanViewModel {
  EquipmentProfile? chosen = _rig;
  int applied = 0;
  @override
  EquipmentProfile? get selectedEquipment => chosen;
  @override
  Future<void> setEquipment(EquipmentProfile rig) async {
    chosen = rig;
    applied++;
  }

  @override
  Future<void> refreshSelectedEquipment() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('aliases distinguish pending, failure, retry, empty and names', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(412, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final aliases = HeldAliasReads();
    addTearDown(aliases.dispose);
    await tester.pumpWidget(
      ChangeNotifierProvider<TargetsViewModel>.value(
        value: aliases,
        child: MaterialApp(
          theme: AppTheme.dark,
          home: TargetDetailScreen(target: _target, onPlan: (_) async {}),
        ),
      ),
    );
    await settle(tester);
    expect(find.text('Loading aliases…'), findsOneWidget);
    expect(find.text('None recorded'), findsNothing);
    aliases.reads.single.completeError(StateError('private database detail'));
    await settle(tester);
    expect(find.text('Unavailable'), findsOneWidget);
    expect(find.text('None recorded'), findsNothing);
    expect(find.textContaining('private database detail'), findsNothing);
    await tester.tap(find.byKey(const Key('targetDetail.aliasRetry')));
    await settle(tester);
    expect(aliases.reads, hasLength(2));
    expect(find.text('Loading aliases…'), findsOneWidget);
    expect(find.text('Unavailable'), findsNothing);
    aliases.reads.last.complete({});
    await settle(tester);
    expect(find.text('None recorded'), findsOneWidget);
    expect(find.text('Loading aliases…'), findsNothing);
    expect(find.byKey(const Key('targetDetail.aliasRetry')), findsNothing);
    expect(
      find.text("OpenNGC, via the app's bundled catalogue"),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('populated aliases omit only the current name', (tester) async {
    final aliases = HeldAliasReads();
    addTearDown(aliases.dispose);
    await tester.pumpWidget(
      ChangeNotifierProvider<TargetsViewModel>.value(
        value: aliases,
        child: MaterialApp(
          home: TargetDetailScreen(target: _target, onPlan: (_) async {}),
        ),
      ),
    );
    aliases.reads.single.complete({
      'M31': [
        const TargetAlias(
          catalogId: 'M31',
          alias: 'Andromeda Galaxy',
          kind: TargetAliasKind.name,
        ),
        const TargetAlias(
          catalogId: 'M31',
          alias: 'NGC 224',
          kind: TargetAliasKind.designation,
        ),
      ],
    });
    await settle(tester);
    expect(find.text('NGC 224'), findsOneWidget);
    expect(find.text('Andromeda Galaxy, NGC 224'), findsNothing);
    expect(find.text('None recorded'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  Future<GoRouter> rigHost(
    WidgetTester tester,
    HeldGearReads rigs,
    _Plan plan, {
    bool forPlan = false,
  }) async {
    tester.view.physicalSize = const Size(412, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    addTearDown(rigs.dispose);
    addTearDown(plan.dispose);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('Caller')),
        ),
        GoRoute(
          path: '/rig',
          builder: (_, _) => PlanRigScreen(forPlanAction: forPlan),
        ),
        GoRoute(
          path: AppRouter.manageRigs,
          builder: (_, state) => Scaffold(
            body: Text(
              state.uri.queryParameters['for'] == 'plan'
                  ? 'Plan manage destination'
                  : 'Manage destination',
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<GearViewModel>.value(value: rigs),
          ChangeNotifierProvider<SessionPlanViewModel>.value(value: plan),
        ],
        child: MaterialApp.router(theme: AppTheme.dark, routerConfig: router),
      ),
    );
    await settle(tester);
    unawaited(router.push('/rig'));
    await settle(tester);
    return router;
  }

  testWidgets('rig read failure stays distinct from empty; Retry can recover', (
    tester,
  ) async {
    final rigs = HeldGearReads();
    final plan = _Plan();
    await rigHost(tester, rigs, plan);
    expect(find.byKey(const Key('planRig.loading')), findsOneWidget);
    expect(find.text('Loading rigs…'), findsOneWidget);
    expect(find.text('No rigs yet'), findsNothing);
    rigs.reads.single.completeError(StateError('private database detail'));
    await settle(tester);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('Add or manage rigs'), findsOneWidget);
    expect(find.text('Add rig'), findsNothing);
    expect(find.textContaining('private database detail'), findsNothing);
    await tester.tap(find.text('Retry'));
    await settle(tester);
    expect(find.byKey(const Key('planRig.loading')), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
    rigs.reads.last.complete([]);
    await settle(tester);
    expect(find.byKey(const Key('planRig.empty')), findsOneWidget);
    expect(find.text('Add rig'), findsOneWidget);
    expect(find.text('Manage destination'), findsNothing);
    expect(plan.applied, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('recovered rig list keeps choice staged until Apply', (
    tester,
  ) async {
    final rigs = HeldGearReads();
    final plan = _Plan();
    final router = await rigHost(tester, rigs, plan);
    rigs.reads.single.completeError(StateError('Synthetic failure'));
    await settle(tester);
    await tester.tap(find.text('Retry'));
    await settle(tester);
    rigs.reads.last.complete([_rig, _secondRig]);
    await settle(tester);
    await tester.tap(find.byKey(const Key('planRig.choice.2')));
    await settle(tester);
    expect(plan.chosen, _rig);
    expect(plan.applied, 0);
    await tester.tap(find.byKey(const Key('planRig.manage')));
    await settle(tester);
    expect(find.text('Manage destination'), findsOneWidget);
    router.pop();
    await settle(tester);
    rigs.reads.last.completeError(StateError('Synthetic reread failure'));
    await settle(tester);
    await tester.tap(find.text('Retry'));
    await settle(tester);
    rigs.reads.last.complete([_rig, _secondRig]);
    await settle(tester);
    await tester.tap(find.byKey(const Key('planRig.apply')));
    await settle(tester);
    expect(plan.chosen, _secondRig);
    expect(plan.applied, 1);
    expect(find.text('Caller'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final forPlan in [false, true]) {
    testWidgets('initial empty rig read keeps redirect forPlan=$forPlan', (
      tester,
    ) async {
      final rigs = HeldGearReads();
      final plan = _Plan();
      await rigHost(tester, rigs, plan, forPlan: forPlan);
      rigs.reads.single.complete([]);
      await settle(tester);
      expect(
        find.text(forPlan ? 'Plan manage destination' : 'Manage destination'),
        findsOneWidget,
      );
      expect(plan.applied, 0);
      expect(tester.takeException(), isNull);
    });
  }
}
