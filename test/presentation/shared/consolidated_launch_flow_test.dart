// The identity launch and the completed Hybrid/geo app must work together.
import 'package:astroplan/core/units/display_units.dart';

import '../../support/wave1_capture.dart';

import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:astroplan/presentation/shared/culmina_mark_geometry.dart';
import 'package:astroplan/presentation/shared/launch_gate.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../support/hybrid_transfer_fixture.dart';
import '../../support/hybrid_transfer_shots.dart';

late String _phase2Theme;

void main() {
  setUpAll(loadWave1Font);
  for (final theme in ['light', 'dark', 'field']) {
    group('Phase2 $theme', () {
      setUp(() => _phase2Theme = theme);
      testWidgets(
        'full launch reveals the current app, compact geo and About',
        (tester) async {
          tester.view.physicalSize = const Size(375, 760);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          late HybridTransferFixture fixture;
          await tester.runAsync(() async {
            fixture = await HybridTransferFixture.create(
              AppDatabase(NativeDatabase.memory()),
            );
          });
          await tester.runAsync(() async {
            await fixture.vm.vms.displaySettings.setAppearance(
              _phase2Theme == 'light' ? Appearance.light : Appearance.dark,
            );
            if (_phase2Theme == 'field') {
              await fixture.vm.theme.toggleFieldMode();
            }
          });
          addTearDown(() => tester.runAsync(fixture.db.close));
          AppRouter.router.go(AppRouter.tonight);
          var shown = 0;
          await tester.pumpWidget(
            LaunchGate(
              look: LaunchLook(
                fieldMode: _phase2Theme == 'field',
                appearance: _phase2Theme == 'light'
                    ? Appearance.light
                    : Appearance.dark,
              ),
              onShown: () => shown++,
              initialize: () async => MultiProvider(
                providers: fixture.vm.providers,
                child: const AstroPlanApp(),
              ),
            ),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));
          expect(find.byKey(const Key('tonight.context')), findsNothing);
          expect(
            shown,
            0,
            reason: 'ready data cannot cut the full gesture short',
          );
          await tester.pump(CulminaLaunchTimeline.gesture);
          await tester.pump();
          await hybridSettle(tester);
          expect(shown, 1);
          final site = tester.getRect(find.byKey(const Key('context.site')));
          final night = tester.getRect(find.byKey(const Key('context.night')));
          expect(site.top, night.top);
          expect(site.height, greaterThanOrEqualTo(48));
          await tester.tap(find.byKey(const Key('context.site')));
          await hybridSettle(tester);
          expect(find.text('Manage sites'), findsOneWidget);
          expect(find.text('Sites'), findsOneWidget);
          expect(find.text('Used for planning'), findsNothing);
          AppRouter.router.go(AppRouter.about);
          await hybridSettle(tester);
          expect(find.text('About'), findsOneWidget);
          expect(find.text('Data sources in the app'), findsOneWidget);
          expect(find.byKey(const Key('about.notice')), findsOneWidget);
          expect(shown, 1, reason: 'navigation must never replay the launch');
          expect(tester.takeException(), isNull);
        },
      );
    });
  }
}
