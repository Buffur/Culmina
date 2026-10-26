import 'dart:io';

import 'package:astroplan/presentation/screens/location/location_picker_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/hybrid_transfer_shots.dart';
import '../../support/wave1_capture.dart';
import '../../support/wave2_fixture.dart';

void main() {
  setUpAll(loadWave1Font);
  for (final theme in ['light', 'dark', 'field']) {
    testWidgets(
      'UIA-0015 $theme: inset owns one reachable calibration footer',
      (t) async {
        final f = await mountWave2(t, theme);
        final saved = f.vm.plan.activeSession!;
        final before = f.vm.captureBlocks.toList();
        await t.tap(find.byKey(const Key('tonight.openPlanner')));
        await hybridSettle(t);
        final build = find.byKey(const Key('capturePlan.buildCalibration'));
        await revealWave2(t, build);
        await t.tap(build);
        await hybridSettle(t);
        final count = find.byKey(const Key('calibration.count.0'));
        await revealWave2(t, count);
        await t.tap(count);
        await t.pump();
        t.view.viewInsets = const FakeViewPadding(bottom: 300);
        await hybridSettle(t);
        final button = find.byKey(const Key('calibration.confirm'));
        final note = find.text(
          'Apply updates the draft. Save plan records it.',
        );
        expect(t.getRect(button).bottom, lessThanOrEqualTo(512));
        expect(button.hitTestable(), findsOneWidget);
        expect(t.getRect(note).bottom, lessThan(t.getRect(button).top));
        expect(t.getRect(count).bottom, lessThan(t.getRect(note).top));
        await captureWave1(t, 'wave3-calibration-$theme-inset');
        t.view.viewInsets = const FakeViewPadding();
        FocusManager.instance.primaryFocus?.unfocus();
        await hybridSettle(t);
        expect(t.getRect(button).bottom, greaterThan(700));
        await captureWave1(t, 'wave3-calibration-$theme-hidden');
        await t.tap(find.byKey(const Key('calibration.cancel')));
        await hybridSettle(t);
        expect(find.byKey(const Key('discardEdit.discard')), findsOneWidget);
        await t.tap(find.byKey(const Key('discardEdit.keep')));
        await hybridSettle(t);
        expect(find.byKey(const Key('calibration.confirm')), findsOneWidget);
        await t.tap(find.byKey(const Key('calibration.cancel')));
        await hybridSettle(t);
        await t.tap(find.byKey(const Key('discardEdit.discard')));
        await hybridSettle(t);
        expect(find.byKey(const Key('calibration.confirm')), findsNothing);
        expect(f.vm.captureBlocks, before);
        expect(f.vm.plan.activeSessionId, saved.id);
        await t.runAsync(() async {
          final stored = (await f.seed.sessions.get(saved.id))!;
          expect(stored.planSnapshot!.json, saved.planSnapshot!.json);
        });
      },
    );

    for (final width in [320.0, 375.0, 412.0]) {
      testWidgets(
        'UIA-0005 $theme/$width: attribution pointer and semantics fit',
        (t) async {
          const channel = MethodChannel('plugins.flutter.io/path_provider');
          t.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            channel,
            (_) async => Directory.systemTemp.path,
          );
          addTearDown(
            () => t.binding.defaultBinaryMessenger.setMockMethodCallHandler(
              channel,
              null,
            ),
          );
          final f = await mountWave2(
            t,
            theme,
            screen: (_) => const LocationPickerScreen(pickOnly: true),
          );
          t.view.physicalSize = Size(width, 812);
          await hybridSettle(t);
          final text = find.text('OpenStreetMap contributors');
          final attribution = find.ancestor(
            of: text,
            matching: find.byType(InkWell),
          );
          final pointer = t.getRect(attribution);
          final semantic = t.getSemantics(attribution).rect;
          expect(pointer.width, greaterThanOrEqualTo(48));
          expect(pointer.height, greaterThanOrEqualTo(48));
          expect(semantic.width, greaterThanOrEqualTo(48));
          expect(semantic.height, greaterThanOrEqualTo(48));
          expect(t.widget<InkWell>(attribution).onTap, isNotNull);
          expect(find.text('© '), findsOneWidget);
          expect(
            pointer.overlaps(
              t.getRect(find.byKey(const Key('location.useCurrentPosition'))),
            ),
            isFalse,
          );
          expect(
            pointer.bottom,
            lessThanOrEqualTo(t.getRect(find.byType(FlutterMap)).bottom),
          );
          expect(
            find.byKey(const Key('location.usePoint')).hitTestable(),
            findsOneWidget,
          );
          await captureWave1(t, 'wave3-attribution-$theme-${width.toInt()}');
          final before = (f.vm.latitude, f.vm.longitude);
          await t.tap(find.byKey(const Key('location.coordinates')));
          await t.pumpAndSettle();
          final fields = find.byType(TextFormField);
          await t.enterText(fields.at(0), '46.05');
          await t.enterText(fields.at(1), '14.51');
          await t.tap(find.text('Use'));
          await t.pumpAndSettle();
          expect(find.byType(AlertDialog), findsNothing);
          final marker = t
              .widget<MarkerLayer>(find.byType(MarkerLayer))
              .markers
              .single;
          expect(
            (marker.point.latitude, marker.point.longitude),
            (46.05, 14.51),
          );
          expect((f.vm.latitude, f.vm.longitude), before);
          final map = find.byType(FlutterMap);
          await t.drag(map, const Offset(45, 30));
          await hybridSettle(t);
          expect(t.takeException(), isNull);
          expect(
            find.byKey(const Key('location.usePoint')).hitTestable(),
            findsOneWidget,
          );
        },
      );
    }
  }
}
