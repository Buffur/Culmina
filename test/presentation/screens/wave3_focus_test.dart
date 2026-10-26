import 'dart:async';

import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:astroplan/presentation/screens/details/night_moon_screen.dart';
import 'package:astroplan/presentation/shared/night_picker_dialog.dart';
import 'package:astroplan/presentation/viewmodels/night_browser_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../support/hybrid_transfer_fixture.dart';
import '../../support/hybrid_transfer_shots.dart';
import '../../support/wave1_capture.dart';
import '../../support/wave2_fixture.dart';
import '../../support/wave3_focus.dart';

void main() {
  setUpAll(loadWave1Font);
  for (final theme in ['light', 'dark', 'field']) {
    testWidgets(
      'UIA-0016 $theme: actual forward Tab reveals viewed-night controls',
      (t) async {
        final f = await mountWave2(t, theme);
        final saved = f.vm.plan.activeSession!;
        await t.tap(find.byKey(const Key('tonight.openPlanner')));
        await hybridSettle(t);
        final night = find.byKey(const Key('planner.night'));
        await revealWave2(t, night);
        await t.tap(night);
        await hybridSettle(t);
        expect(find.byType(NightMoonScreen), findsOneWidget);
        final picker = find.byKey(const Key('nightMoon.pickNight'));
        await t.tap(picker);
        await t.pumpAndSettle();
        expect(find.byType(NightPickerDialog), findsOneWidget);
        await t.tap(find.byKey(const Key('nightPicker.inputMode')));
        await t.pumpAndSettle();
        await t.enterText(find.byType(TextFormField), '10/20/2026');
        await t.tap(find.widgetWithText(TextButton, 'OK'));
        await hybridSettle(t);
        final browser = t.element(picker).read<NightBrowserViewModel>();
        expect(browser.viewedDate, hybridTransferNight.addDays(1));
        final next = find.byTooltip('Next night');
        await wave3TabTo(t, next);
        expect(next.hitTestable(), findsOneWidget);
        await t.tap(next);
        await t.pumpAndSettle();
        expect(browser.viewedDate, hybridTransferNight.addDays(2));
        final previous = find.byTooltip('Previous night');
        await wave3TabTo(t, previous);
        final scroll = t
            .element(previous)
            .findAncestorStateOfType<ScrollableState>()!;
        final viewport = t.getRect(find.byWidget(scroll.widget));
        expect(t.getRect(previous).top, greaterThanOrEqualTo(viewport.top));
        expect(previous.hitTestable(), findsOneWidget);
        await t.pump(const Duration(seconds: 2));
        await t.pump();
        expect(previous.hitTestable(), findsOneWidget);
        await captureWave1(t, 'wave3-night-$theme-previous-focus');
        final back = find.byKey(const Key('nightMoon.backToPlan'));
        await wave3TabTo(t, back);
        expect(back.hitTestable(), findsOneWidget);
        await captureWave1(t, 'wave3-night-$theme-back-focus');
        expect(f.vm.plan.activeSessionId, saved.id);
        expect(f.vm.eveningDate, hybridTransferNight);
        await t.tap(back);
        await hybridSettle(t);
        expect(browser.viewedDate, hybridTransferNight);
        await t.runAsync(() async {
          expect(
            (await f.seed.sessions.get(saved.id))!.planSnapshot!.json,
            saved.planSnapshot!.json,
          );
        });
      },
    );

    testWidgets(
      'UIA-0017 $theme: actual painted name ring follows inset layout',
      (t) async {
        final f = await mountWave2(t, theme);
        expect(
          FocusManager.instance.highlightStrategy,
          FocusHighlightStrategy.automatic,
        );
        await t.runAsync(f.seed.seedLogbook);
        AppRouter.router.go(AppRouter.sessions);
        await hybridSettle(t);
        final id = f.seed.logbookIds['M31 2026-10-12']!;
        unawaited(AppRouter.router.push(AppRouter.sessionDetail(id)));
        await hybridSettle(t);
        final name = find.byKey(const Key('detail.name'));
        await revealWave2(t, name);
        final before = await t.runAsync(() => f.seed.sessions.get(id));
        await t.tap(name);
        await hybridSettle(t);
        final field = find.byKey(const Key('detail.nameField'));
        await wave3TabTo(t, field, freshTab: true);
        for (final inset in [300.0, 0.0, 300.0]) {
          t.view.viewInsets = FakeViewPadding(bottom: inset);
          await hybridSettle(t);
          await expectWave3PaintedRing(t, field);
          await captureWave1(t, 'wave3-name-$theme-empty-${inset.toInt()}');
        }
        final long = 'M31 ${List.filled(76, 'x').join()}';
        await t.enterText(field, long);
        await hybridSettle(t);
        expect(t.widget<TextField>(field).controller!.text, long);
        await wave3TabTo(t, field, freshTab: true);
        await expectWave3PaintedRing(t, field);
        await captureWave1(t, 'wave3-name-$theme-long-300');
        t.testTextInput.hide();
        t.view.viewInsets = const FakeViewPadding();
        await hybridSettle(t);
        final cancel = find.descendant(
          of: find.byType(AlertDialog),
          matching: find.widgetWithText(TextButton, 'Cancel'),
        );
        await t.tap(cancel);
        await hybridSettle(t);
        expect(field, findsNothing);
        await t.runAsync(() async {
          final after = (await f.seed.sessions.get(id))!;
          expect(after.name, before!.name);
          expect(after.planSnapshot!.json, before.planSnapshot!.json);
          expect(after.updatedAtUtc, before.updatedAtUtc);
        });
      },
    );
  }
}
