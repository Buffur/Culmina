import 'dart:async';

import 'package:astroplan/core/units/display_units.dart';
import 'package:astroplan/core/theme/app_theme.dart';
import 'package:astroplan/presentation/shared/culmina_mark_geometry.dart';
import 'package:astroplan/presentation/shared/launch_gate.dart';
import 'package:astroplan/presentation/shared/startup_mark.dart';
import 'package:astroplan/presentation/screens/about/about_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/phase2_state_capture.dart';
import '../../support/wave1_capture.dart';

void main() {
  setUpAll(loadWave1Font);
  for (final appearance in [null, Appearance.system]) {
    for (final brightness in Brightness.values) {
      testWidgets(
        'launch ${appearance?.name ?? "unset"} resolves platform ${brightness.name}',
        (t) async {
          t.platformDispatcher.platformBrightnessTestValue = brightness;
          addTearDown(t.platformDispatcher.clearPlatformBrightnessTestValue);
          final ready = Completer<Widget>();
          await t.pumpWidget(
            LaunchGate(
              look: LaunchLook(appearance: appearance),
              initialize: () => ready.future,
            ),
          );
          final paint = t.widget<CustomPaint>(
            find.descendant(
              of: find.byKey(const Key('launch.mark')),
              matching: find.byType(CustomPaint),
            ),
          );
          final colors = (paint.painter! as CulminaMarkPainter).colours;
          expect(
            colors,
            brightness == Brightness.dark
                ? CulminaMarkColors.dark
                : CulminaMarkColors.light,
          );
          ready.complete(const SizedBox.shrink());
          await t.pumpAndSettle();
          expect(t.takeException(), isNull);
        },
      );
    }
  }

  for (final theme in ['light', 'dark', 'field']) {
    testWidgets(
      '$theme About source links use the centered quiet action role',
      (t) async {
        t.view.physicalSize = const Size(375, 812);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.reset);
        await t.pumpWidget(
          MaterialApp(
            theme: phase2Theme(theme),
            builder: (_, child) => phase2Frame(child: child!, theme: theme),
            home: AboutScreen(loadNotice: () async => 'Synthetic notice'),
          ),
        );
        await t.pumpAndSettle();
        final label = find.descendant(
          of: find.byKey(const Key('about.reddit')),
          matching: find.byType(Text),
        );
        final text = t.widget<Text>(label);
        expect(text.style!.fontSize, 15);
        expect(text.style!.fontWeight, FontWeight.w600);
        expect(text.style!.decoration, isNot(TextDecoration.underline));
        expect(text.textAlign, TextAlign.center);
        expect(t.getCenter(label).dx, closeTo(187.5, 0.5));
        expect(
          t.getSize(find.byKey(const Key('about.reddit'))).height,
          greaterThanOrEqualTo(48),
        );
        await capturePhase2State(
          t,
          package: 'package4-startup',
          state: 'about-centered-quiet-source-actions',
          theme: theme,
        );
        expect(t.takeException(), isNull);
      },
    );

    testWidgets(
      '$theme launch pending error retry and reveal use native state frames',
      (t) async {
        t.view.physicalSize = const Size(375, 812);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.reset);
        final attempts = <Completer<Widget>>[];
        var shown = 0;
        await t.pumpWidget(
          MediaQuery(
            data: MediaQueryData.fromView(t.view),
            child: phase2Frame(
              theme: theme,
              applyFieldFilter: false,
              child: LaunchGate(
                look: LaunchLook(
                  fieldMode: theme == 'field',
                  appearance: theme == 'light'
                      ? Appearance.light
                      : Appearance.dark,
                ),
                waitHint: const Duration(milliseconds: 50),
                onShown: () => shown++,
                initialize: () {
                  final next = Completer<Widget>();
                  attempts.add(next);
                  return next.future;
                },
              ),
            ),
          ),
        );
        Future<void> capture(String state) => capturePhase2State(
          t,
          package: 'package4-startup',
          state: state,
          theme: theme,
        );
        expect(find.byKey(const Key('launch.mark')), findsOneWidget);
        expect(shown, 0);
        await capture('launch-still-before-gesture');
        await t.pump();
        await t.pump(const Duration(milliseconds: 400));
        await capture('launch-gesture-active');
        await t.pump(CulminaLaunchTimeline.gesture);
        await t.pump(const Duration(milliseconds: 60));
        expect(find.byKey(const Key('launch.waiting')), findsOneWidget);
        expect(shown, 0);
        await capture('launch-ready-pending-waiting');
        attempts.single.completeError(
          StateError('synthetic unavailable startup'),
        );
        await t.pumpAndSettle();
        expect(find.byKey(const Key('launch.error')), findsOneWidget);
        expect(shown, 0);
        await capture('launch-failed-retry');
        await t.tap(find.byKey(const Key('launch.retry')));
        await t.pump();
        expect(attempts, hasLength(2));
        expect(find.byKey(const Key('launch.error')), findsNothing);
        await capture('launch-retry-pending');
        attempts.last.complete(
          MaterialApp(
            theme: phase2Theme(theme),
            builder: (_, child) => theme == 'field'
                ? ColorFiltered(
                    colorFilter: AppTheme.fieldFilter,
                    child: child!,
                  )
                : child!,
            home: const Scaffold(body: Text('Ready application')),
          ),
        );
        await t.pumpAndSettle();
        expect(find.text('Ready application'), findsOneWidget);
        expect(find.byKey(const Key('launch.mark')), findsNothing);
        expect(shown, 1);
        await capture('launch-revealed-once');
        expect(t.takeException(), isNull);
      },
    );
  }
}
