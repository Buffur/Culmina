import 'dart:async';

import 'package:astroplan/core/units/display_units.dart';
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:astroplan/presentation/screens/home/home_screen.dart';
import 'package:astroplan/presentation/screens/settings/settings_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../../support/hybrid_transfer_fixture.dart';
import '../../../support/hybrid_transfer_shots.dart';
import '../../../support/phase2_state_capture.dart';
import '../../../support/wave1_capture.dart';

void main() {
  setUpAll(loadWave1Font);
  for (final theme in ['light', 'dark', 'field']) {
    testWidgets(
      'Phase2 over-plan settings return and saved snapshot stay exact $theme',
      (t) async {
        t.view.physicalSize = const Size(375, 900);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.reset);
        late HybridTransferFixture f;
        await t.runAsync(() async {
          f = await HybridTransferFixture.create(
            AppDatabase(NativeDatabase.memory()),
          );
          await f.vm.vms.displaySettings.setAppearance(
            theme == 'light' ? Appearance.light : Appearance.dark,
          );
          if (theme == 'field') await f.vm.theme.toggleFieldMode();
        });
        addTearDown(() async {
          await t.pumpWidget(const SizedBox.shrink());
          f.vm.dispose();
          await t.runAsync(f.db.close);
        });
        AppRouter.router.go(AppRouter.tonight);
        await t.pumpWidget(
          MultiProvider(
            providers: f.vm.providers,
            child: phase2Frame(
              theme: theme,
              applyFieldFilter: false,
              child: const AstroPlanApp(),
            ),
          ),
        );
        await hybridSettle(t);
        await HybridRenderContext(t, f).push(AppRouter.session());
        final original = f.vm.plan.activeSession!;
        final snapshot = original.planSnapshot!.json;
        final initial = f.vm.settings.planningPreferences;
        Future<void> open() async {
          unawaited(AppRouter.router.push(AppRouter.planSettings));
          await hybridSettle(t);
          expect(find.byType(SettingsScreen), findsOneWidget);
        }

        Future<void> tap(String key) async {
          await t.ensureVisible(find.byKey(Key(key)));
          await hybridSettle(t);
          await t.tap(find.byKey(Key(key)));
          await hybridSettle(t);
        }

        Future<void> capture(String state) => capturePhase2State(
          t,
          package: 'package4',
          state: state,
          theme: theme,
        );
        await open();
        expect(find.text('Planning settings'), findsOneWidget);
        expect(find.text('No changes'), findsOneWidget);
        expect(
          t
              .widget<FilledButton>(
                find.byKey(const Key('settings.savePlanning')),
              )
              .onPressed,
          isNotNull,
        );
        await capture('planning-over-plan-clean');
        await tap('settings.savePlanning');
        expect(find.byType(HomeScreen), findsOneWidget);
        expect(f.vm.settings.planningPreferences, initial);
        expect(f.vm.plan.activeSession!.planSnapshot!.json, snapshot);
        await open();
        await tap('settings.scope');
        expect(find.text(SettingsScreen.scopeNotice), findsOneWidget);
        await capture('planning-over-plan-scope-open');
        final slider = find.descendant(
          of: find.byKey(const Key('settings.perFrame')),
          matching: find.byType(Slider),
        );
        await t.ensureVisible(slider);
        await hybridSettle(t);
        t.widget<Slider>(slider).onChanged!(
          initial.perFrameOverheadSeconds + 5,
        );
        await t.pump();
        expect(f.vm.settings.planningPreferences, initial);
        await tap('settings.cancelPlanning');
        expect(find.text('Discard your changes?'), findsOneWidget);
        await tap('confirm.action');
        expect(find.byType(HomeScreen), findsOneWidget);
        expect(f.vm.settings.planningPreferences, initial);
        await open();
        t.widget<Slider>(slider).onChanged!(
          initial.perFrameOverheadSeconds + 5,
        );
        await t.pump();
        await tap('settings.savePlanning');
        expect(find.byType(HomeScreen), findsOneWidget);
        expect(
          f.vm.settings.planningPreferences.perFrameOverheadSeconds,
          initial.perFrameOverheadSeconds + 5,
        );
        final stored = await t.runAsync(() => f.sessions.get(original.id));
        expect(stored!.planSnapshot!.json, snapshot);
        expect(stored.eveningDate, original.eveningDate);
        expect(stored.updatedAtUtc, original.updatedAtUtc);
        expect(f.vm.plan.activeSessionId, original.id);
        await capture('planning-over-plan-saved-return-keeps-stored-snapshot');
        expect(t.takeException(), isNull);
      },
    );
  }
}
