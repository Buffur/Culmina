import 'dart:io';

import 'package:astroplan/core/units/display_units.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:astroplan/presentation/viewmodels/night_browser_viewmodel.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../support/hybrid_transfer_fixture.dart';
import '../../support/hybrid_transfer_shots.dart';
import '../../support/sdk_fonts.dart';

Future<HybridRenderContext> _start(
  WidgetTester tester,
  String theme, {
  double width = 375,
  double scale = 1,
}) async {
  tester.view.physicalSize = Size(width, 1600);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  tester.platformDispatcher.platformBrightnessTestValue = theme == 'light'
      ? Brightness.light
      : Brightness.dark;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);
  late HybridTransferFixture fixture;
  await tester.runAsync(() async {
    for (final entry in {
      'Geist': File('assets/fonts/Geist.ttf'),
      'MaterialIcons': sdkMaterialFont('materialicons-regular.otf')!,
    }.entries) {
      final loader = FontLoader(entry.key);
      loader.addFont(entry.value.readAsBytes().then(ByteData.sublistView));
      await loader.load();
    }
    fixture = await HybridTransferFixture.create(
      AppDatabase(NativeDatabase.memory()),
    );
    if (theme == 'field') await fixture.vm.theme.toggleFieldMode();
  });
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    fixture.vm.dispose();
    await tester.runAsync(fixture.db.close);
  });
  AppRouter.router.go(AppRouter.tonight);
  await tester.pumpWidget(
    MultiProvider(providers: fixture.vm.providers, child: const AstroPlanApp()),
  );
  final context = HybridRenderContext(tester, fixture);
  await context.settle();
  return context;
}

void main() {
  for (final theme in ['light', 'dark', 'field']) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('$theme $scale calibration selected labels remain visible', (
        tester,
      ) async {
        final c = await _start(tester, theme, scale: scale);
        await hybridShots['plan_editor']!(c);
        await c.tapText('Dark');
        await c.tapKey('section.blockEditor.Details');
        final policy = find.byKey(const Key('blockDialog.policy'));
        await tester.ensureVisible(policy);
        await c.settle();
        for (final (value, label) in [
          (
            CalibrationPolicy.outsideWindow,
            'Outside the window (twilight/dawn)',
          ),
          (CalibrationPolicy.inWindow, 'During the window'),
          (CalibrationPolicy.library, 'From your library (no window time)'),
        ]) {
          final field = tester
              .widget<DropdownButtonFormField<CalibrationPolicy>>(policy);
          field.onChanged!(value);
          tester
              .state<FormFieldState<CalibrationPolicy>>(policy)
              .didChange(value);
          await c.settle();
          final text = find.descendant(of: policy, matching: find.text(label));
          final paragraph = tester.renderObject<RenderParagraph>(
            find.descendant(of: text, matching: find.byType(RichText)).first,
          );
          final boxes = paragraph.getBoxesForSelection(
            TextSelection(baseOffset: 0, extentOffset: label.length),
          );
          expect(boxes, isNotEmpty);
          for (final box in boxes) {
            expect(box.bottom, lessThanOrEqualTo(paragraph.size.height + .01));
            expect(box.right, lessThanOrEqualTo(paragraph.size.width + .01));
          }
          expect(paragraph.didExceedMaxLines, isFalse);
        }
        expect(
          c.fixture.vm.plan.captureBlocks.first.isLight,
          isTrue,
          reason: 'Editing the dialog must not apply it to the plan.',
        );
        expect(tester.takeException(), isNull);
      });
    }

    for (final width in [375.0, 412.0]) {
      testWidgets(
        '$theme $width Moon day targets are separate and at least 48dp',
        (tester) async {
          final semantics = tester.ensureSemantics();
          final c = await _start(tester, theme, width: width);
          final planNight = c.fixture.vm.plan.eveningDate;
          await hybridShots['moon']!(c);
          final days = find.byWidgetPredicate(
            (w) =>
                w is InkWell &&
                (w.key as ValueKey?)?.value.toString().startsWith(
                      'nightMoon.day.',
                    ) ==
                    true,
          );
          expect(days, findsAtLeastNWidgets(28));
          final rects = <Rect>[];
          for (final element in days.evaluate()) {
            final finder = find.byWidget(element.widget);
            final rect = tester.getRect(finder);
            rects.add(rect);
            expect(rect.width, greaterThanOrEqualTo(48));
            expect(rect.height, greaterThanOrEqualTo(48));
            expect(rect.left, greaterThanOrEqualTo(0));
            expect(rect.right, lessThanOrEqualTo(width));
            final semantic = tester.getSemantics(finder).parent!;
            expect(semantic.rect.width, greaterThanOrEqualTo(48));
          }
          for (var i = 0; i < rects.length; i++) {
            for (var j = i + 1; j < rects.length; j++) {
              expect(rects[i].overlaps(rects[j]), isFalse);
            }
          }
          final day = days.at(16);
          await tester.ensureVisible(day);
          await c.settle();
          final rect = tester.getRect(day);
          await tester.tapAt(Offset(rect.right - .1, rect.center.dy));
          await c.settle();
          final browser = tester.element(day).read<NightBrowserViewModel>();
          expect(browser.viewedDate, isNot(planNight));
          expect(
            c.fixture.vm.plan.eveningDate,
            planNight,
            reason: 'Browsing another night does not adopt it into the plan.',
          );
          expect(tester.takeException(), isNull);
          semantics.dispose();
        },
      );
    }

    testWidgets('$theme narrow Moon uses the existing week view', (
      tester,
    ) async {
      final c = await _start(tester, theme, width: 320);
      await hybridShots['moon']!(c);
      expect(find.byKey(const Key('nightMoon.week')), findsOneWidget);
      expect(find.byKey(const Key('nightMoon.month')), findsNothing);
      expect(
        tester.getRect(find.byKey(const Key('moon.answerGroup'))).left,
        closeTo(20, .01),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('$theme Appearance units stay together at 375dp', (
      tester,
    ) async {
      final c = await _start(tester, theme);
      await c.go(AppRouter.settings);
      for (final wind in WindUnit.values) {
        await tester.runAsync(
          () => c.fixture.vm.vms.displaySettings.setUnits(
            DisplayUnits(wind: wind),
          ),
        );
        await c.settle();
        final row = find.byKey(const Key('settings.open.appearance'));
        final text = find.descendant(
          of: row,
          matching: find.byWidgetPredicate(
            (w) => w is Text && (w.data?.contains(wind.symbol) ?? false),
          ),
        );
        final paragraph = tester.renderObject<RenderParagraph>(
          find.descendant(of: text, matching: find.byType(RichText)).first,
        );
        final label = paragraph.text.toPlainText();
        final start = label.indexOf(wind.symbol);
        final boxes = paragraph.getBoxesForSelection(
          TextSelection(
            baseOffset: start,
            extentOffset: start + wind.symbol.length,
          ),
        );
        expect(
          boxes,
          hasLength(1),
          reason: 'The complete wind unit is on one line.',
        );
        expect(tester.takeException(), isNull);
      }
    });
  }
}
