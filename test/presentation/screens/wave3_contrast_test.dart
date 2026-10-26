import 'dart:ui' as ui;

import 'package:astroplan/domain/models/tracking_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/hybrid_transfer_shots.dart';
import '../../support/fake_capture_file_access.dart';
import '../../support/wave1_capture.dart';
import '../../support/wave2_fixture.dart';
import '../../support/wave3_focus.dart';
import '../../support/wave3_ink.dart';

void main() {
  setUpAll(loadWave1Font);
  for (final theme in ['light', 'dark', 'field']) {
    testWidgets('UIA-0013 C01 $theme: Tracking actual focus and held ink', (
      t,
    ) async {
      final f = await mountWave2(t, theme);
      await t.tap(find.byKey(const Key('tonight.openPlanner')));
      await hybridSettle(t);
      final trigger = find.byKey(const Key('planner.tracking'));
      // Open the existing rig disclosure before using its production caller.
      if (trigger.evaluate().isEmpty) {
        final rig = find.byKey(const Key('section.planner.rigDetails'));
        await revealWave2(t, rig);
        await t.tap(rig);
        await hybridSettle(t);
      }
      await revealWave2(t, trigger);
      await t.tap(trigger);
      await hybridSettle(t);
      final option = find.byKey(const Key('planTracking.guided'));
      final label = find.descendant(of: option, matching: find.text('Guided'));
      await wave3FocusContrast(t, label, 'wave3-C01-$theme-normal', theme);
      await wave3UnfocusedHeldContrast(
        t,
        option,
        label,
        'wave3-C01-$theme-mouse-unfocused-held',
        theme,
      );
      await wave3TabTo(t, option);
      await wave3FocusContrast(t, label, 'wave3-C01-$theme-focus', theme);
      await wave3HeldContrast(
        t,
        option,
        label,
        'wave3-C01-$theme-mouse-focused-held',
        theme,
        kind: ui.PointerDeviceKind.mouse,
      );
      expect(f.vm.plan.trackingOverride, isNull);
      expect(f.vm.plan.selectedEquipment!.trackingType, TrackingType.unknown);
      await t.tap(option);
      await hybridSettle(t);
      expect(f.vm.plan.trackingOverride, TrackingType.guided);
      expect(f.vm.plan.selectedEquipment!.trackingType, TrackingType.unknown);
    });

    testWidgets('UIA-0013 C02/C16 $theme: actual block Details and photo ink', (
      t,
    ) async {
      final files = FakeCaptureFileAccess();
      final f = await mountWave2(t, theme, captureFiles: files);
      await t.tap(find.byKey(const Key('tonight.openPlanner')));
      await hybridSettle(t);
      final edit = find.byKey(const Key('capture.edit.0'));
      await revealWave2(t, edit);
      await t.tap(edit);
      await hybridSettle(t);
      final details = find.byKey(const Key('blockDialog.details'));
      await revealWave2(t, details);
      final timing = find.descendant(
        of: details,
        matching: find.text('Timing'),
      );
      expect(timing, findsOneWidget);
      await wave3HeldContrast(
        t,
        find.descendant(of: details, matching: find.byType(InkWell)).first,
        timing,
        'wave3-C02-$theme-held',
        theme,
      );
      final photo = find.byKey(const Key('blockDialog.fromPhoto'));
      if (photo.evaluate().isEmpty) {
        final disclosure = find.text('From a photo');
        await revealWave2(t, disclosure);
        await t.tap(disclosure);
        await hybridSettle(t);
      }
      await revealWave2(t, photo);
      final label = find.descendant(
        of: photo,
        matching: find.text('Take from a photo'),
      );
      await wave3HeldContrast(
        t,
        photo,
        label,
        'wave3-C16-$theme-mouse-held',
        theme,
        kind: ui.PointerDeviceKind.mouse,
      );
      expect(f.vm.plan.captureBlocks, hasLength(1));
      expect(find.byKey(const Key('blockDialog.review')), findsNothing);
      expect(files.picks, 0);
    });
  }
}
