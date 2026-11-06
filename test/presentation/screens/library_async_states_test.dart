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
import '../../support/phase2_state_capture.dart';
import '../../support/wave1_capture.dart' show loadWave1Font;

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
  setUpAll(loadWave1Font);
  for (final mode in ['light', 'dark', 'field']) {
    group('Package 2 $mode', () {
      final theme = switch (mode) {
        'dark' => AppTheme.dark,
        'field' => AppTheme.fieldTheme,
        _ => AppTheme.light,
      };
      Widget fieldFilter(BuildContext context, Widget? child) =>
          phase2Frame(child: child!, theme: mode);
      Future<void> capture(WidgetTester t, String state) =>
          capturePhase2State(t, package: 'package2', state: state, theme: mode);
      Future<void> settle(WidgetTester tester) async {
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
      }

      testWidgets(
        'aliases distinguish pending, failure, retry, empty and names',
        (tester) async {
          tester.view.physicalSize = const Size(412, 1600);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          final aliases = HeldAliasReads();
          addTearDown(aliases.dispose);
          await tester.pumpWidget(
            ChangeNotifierProvider<TargetsViewModel>.value(
              value: aliases,
              child: MaterialApp(
                theme: theme,
                builder: fieldFilter,
                home: TargetDetailScreen(target: _target, onPlan: (_) async {}),
              ),
            ),
          );
          await settle(tester);
          expect(find.text('Loading aliases…'), findsOneWidget);
          expect(find.text('None recorded'), findsNothing);
          await capture(tester, 'target-alias-pending');
          aliases.reads.single.completeError(
            StateError('private database detail'),
          );
          await settle(tester);
          expect(find.text('Unavailable'), findsOneWidget);
          expect(find.text('None recorded'), findsNothing);
          expect(find.textContaining('private database detail'), findsNothing);
          await capture(tester, 'target-alias-error');
          await tester.tap(find.byKey(const Key('targetDetail.aliasRetry')));
          await settle(tester);
          expect(aliases.reads, hasLength(2));
          expect(find.text('Loading aliases…'), findsOneWidget);
          expect(find.text('Unavailable'), findsNothing);
          await capture(tester, 'target-alias-retry-pending');
          aliases.reads.last.complete({});
          await settle(tester);
          expect(find.text('None recorded'), findsOneWidget);
          expect(find.text('Loading aliases…'), findsNothing);
          expect(
            find.byKey(const Key('targetDetail.aliasRetry')),
            findsNothing,
          );
          await capture(tester, 'target-alias-empty');
          expect(
            find.text("OpenNGC, via the app's bundled catalogue"),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        },
      );

      testWidgets('populated aliases omit only the current name', (
        tester,
      ) async {
        final aliases = HeldAliasReads();
        addTearDown(aliases.dispose);
        await tester.pumpWidget(
          ChangeNotifierProvider<TargetsViewModel>.value(
            value: aliases,
            child: MaterialApp(
              theme: theme,
              builder: fieldFilter,
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
        await capture(tester, 'target-alias-populated');
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
            child: MaterialApp.router(
              theme: theme,
              builder: fieldFilter,
              routerConfig: router,
            ),
          ),
        );
        await settle(tester);
        unawaited(router.push('/rig'));
        await settle(tester);
        return router;
      }

      testWidgets(
        '164 rig choices keep staged Apply visible above the safe inset',
        (tester) async {
          final rigs = HeldGearReads();
          final plan = _Plan();
          await rigHost(tester, rigs, plan);
          tester.view.physicalSize = const Size(375, 812);
          final list = [
            for (var i = 1; i <= 164; i++)
              EquipmentProfile(
                id: i,
                name: 'Synthetic rig $i',
                sensorWidthMm: _rig.sensorWidthMm,
                sensorHeightMm: _rig.sensorHeightMm,
                pixelPitchUm: _rig.pixelPitchUm,
                resolutionWidthPx: _rig.resolutionWidthPx,
                resolutionHeightPx: _rig.resolutionHeightPx,
                focalLengthMm: _rig.focalLengthMm,
                focalRatio: _rig.focalRatio,
              ),
          ];
          rigs.reads.single.complete(list);
          await settle(tester);
          final apply = find.byKey(const Key('planRig.apply'));
          final initialFooter = tester.getRect(apply);
          expect(initialFooter.bottom, lessThanOrEqualTo(812));
          expect(initialFooter.height, greaterThanOrEqualTo(48));
          expect(plan.applied, 0);
          final last = find.byKey(const Key('planRig.choice.164'));
          await tester.scrollUntilVisible(
            last,
            600,
            scrollable: find
                .descendant(
                  of: find.byKey(const Key('planRig.scroll')),
                  matching: find.byType(Scrollable),
                )
                .first,
          );
          await tester.tap(last);
          await settle(tester);
          expect(plan.chosen, _rig);
          expect(plan.applied, 0);
          expect(tester.getRect(apply), initialFooter);
          await capture(tester, 'rig-staged-164');
          await tester.tap(apply);
          await settle(tester);
          expect(plan.chosen, list.last);
          expect(plan.applied, 1);
          expect(find.text('Caller'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );

      testWidgets(
        'rig read failure stays distinct from empty; Retry can recover',
        (tester) async {
          final rigs = HeldGearReads();
          final plan = _Plan();
          await rigHost(tester, rigs, plan);
          expect(find.byKey(const Key('planRig.loading')), findsOneWidget);
          expect(find.text('Loading rigs…'), findsOneWidget);
          await capture(tester, 'rig-pending');
          expect(find.text('No rigs yet'), findsNothing);
          rigs.reads.single.completeError(
            StateError('private database detail'),
          );
          await settle(tester);
          expect(find.text('Retry'), findsOneWidget);
          expect(find.text('Add or manage rigs'), findsOneWidget);
          expect(find.text('Add rig'), findsNothing);
          expect(find.textContaining('private database detail'), findsNothing);
          await capture(tester, 'rig-error');
          await tester.tap(find.text('Retry'));
          await settle(tester);
          expect(find.byKey(const Key('planRig.loading')), findsOneWidget);
          expect(find.text('Retry'), findsNothing);
          await capture(tester, 'rig-retry-pending');
          rigs.reads.last.complete([]);
          await settle(tester);
          expect(find.byKey(const Key('planRig.empty')), findsOneWidget);
          await capture(tester, 'rig-empty-after-retry');
          expect(find.text('Add rig'), findsOneWidget);
          expect(find.text('Manage destination'), findsNothing);
          expect(plan.applied, 0);
          expect(tester.takeException(), isNull);
        },
      );

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
            find.text(
              forPlan ? 'Plan manage destination' : 'Manage destination',
            ),
            findsOneWidget,
          );
          expect(plan.applied, 0);
          expect(tester.takeException(), isNull);
        });
      }
    });
  }
}
