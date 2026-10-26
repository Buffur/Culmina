import 'dart:ui' as ui;

import 'package:astroplan/presentation/shared/night_picker_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/wave1_capture.dart';

final wave4DateMetrics = <Map<String, Object?>>[];
String _case = '';

class _PickerProbe {
  DateTime? result;
  bool completed = false;
}

Future<_PickerProbe> _open(
  WidgetTester t,
  String theme,
  double width, {
  double? parentWidth,
  DateTime? firstDate,
  DateTime? lastDate,
}) async {
  if (wave1IsNative) {
    await t.binding.setSurfaceSize(Size(width, 812));
  } else {
    t.view.physicalSize = Size(width, 812);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
  }
  t.platformDispatcher.textScaleFactorTestValue = 1;
  addTearDown(t.platformDispatcher.clearAllTestValues);
  final probe = _PickerProbe();
  await t.pumpWidget(
    wave1App(
      theme,
      home: Builder(
        builder: (context) {
          return Scaffold(
            body: Center(
              child: TextButton(
                key: const Key('wave4.openPicker'),
                onPressed: () async {
                  probe.completed = false;
                  probe.result = await showDialog<DateTime>(
                    context: context,
                    builder: (_) {
                      final dialog = NightPickerDialog(
                        initialDate: DateTime(2026, 10, 19),
                        firstDate: firstDate ?? DateTime(2024),
                        lastDate: lastDate ?? DateTime(2030, 12, 31),
                      );
                      return parentWidth == null
                          ? dialog
                          : Center(
                              child: SizedBox(
                                width: parentWidth,
                                child: dialog,
                              ),
                            );
                    },
                  );
                  probe.completed = true;
                },
                child: const Text('Choose night'),
              ),
            ),
          );
        },
      ),
    ),
  );
  await t.tap(find.byKey(const Key('wave4.openPicker')));
  await t.pumpAndSettle();
  return probe;
}

Finder _day(WidgetTester t, DateTime date) => find.bySemanticsLabel(
  MaterialLocalizations.of(t.element(find.byType(NightPickerDialog)))
      .formatFullDate(date),
);

void _target(WidgetTester t, Finder day) {
  final button = find.descendant(of: day, matching: find.byType(TextButton));
  final pointer = t.getRect(button);
  final size = t.renderObject<RenderBox>(button).size;
  final semantic = t.getSemantics(day).rect;
  // Translated global/semantic edges can subtract to 47.99999999999994.
  // Keep the exact layout minimum, and separately reject clipping/scaling.
  expect(size.width, greaterThanOrEqualTo(48));
  expect(size.height, greaterThanOrEqualTo(48));
  expect(pointer.width, closeTo(size.width, 1e-9));
  expect(pointer.height, closeTo(size.height, 1e-9));
  expect(semantic.width, closeTo(size.width, 1e-9));
  expect(semantic.height, closeTo(size.height, 1e-9));
  expect(button.hitTestable(), findsOneWidget);
  wave4DateMetrics.add({
    'case': _case,
    'label': t.getSemantics(day).getSemanticsData().label,
    'pointerWidth': size.width,
    'pointerHeight': size.height,
    'globalPointerWidth': pointer.width,
    'globalPointerHeight': pointer.height,
    'coordinatePrecisionDp': 1e-9,
    'semanticWidth': semantic.width,
    'semanticHeight': semantic.height,
  });
}

void main() {
  setUpAll(loadWave1Font);
  for (final theme in ['light', 'dark', 'field']) {
    for (final width in [320.0, 375.0, 412.0]) {
      testWidgets(
        'UIA-0009 $theme/$width: 31 independent dates and local modal ownership',
        (t) async {
          _case = '$theme/$width';
          final probe = await _open(t, theme, width);
          final selected = _day(t, DateTime(2026, 10, 19));
          await captureWave1(t, 'wave4-date-$theme-${width.toInt()}-initial');
          _target(t, selected);
          final list = find.byKey(const Key('nightPicker.dates'));
          expect(list, width < 368 ? findsOneWidget : findsNothing);
          expect(
            find.byType(GridView),
            width < 368 ? findsNothing : findsOneWidget,
          );
          final scroll = find.descendant(
            of: list,
            matching: find.byType(Scrollable),
          );
          if (width < 368) {
            await t.scrollUntilVisible(
              _day(t, DateTime(2026, 10, 1)),
              -200,
              scrollable: scroll,
            );
          }
          for (var d = 1; d <= 31; d++) {
            final day = _day(t, DateTime(2026, 10, d));
            if (width < 368) {
              await t.scrollUntilVisible(day, 160, scrollable: scroll);
              // ensureVisible jumps after the final drag frame; commit the
              // resulting layout and semantic clip before measuring it.
              await t.pumpAndSettle();
            }
            _target(t, day);
            if (d > 1) {
              final previous = _day(t, DateTime(2026, 10, d - 1));
              if (previous.hitTestable().evaluate().isNotEmpty) {
                // Seven fractional columns share exact mathematical edges.
                // Disregard only sub-nanodp floating-point boundary noise.
                expect(
                  t
                      .getRect(day)
                      .deflate(1e-9)
                      .overlaps(t.getRect(previous).deflate(1e-9)),
                  isFalse,
                );
              }
            }
          }
          await t.tap(_day(t, DateTime(2026, 10, 31)));
          await t.pumpAndSettle();
          expect(probe.completed, isFalse);
          await captureWave1(
            t,
            'wave4-date-$theme-${width.toInt()}-selected31',
          );
          await t.tap(find.widgetWithText(TextButton, 'OK'));
          await t.pumpAndSettle();
          expect(probe.completed, isTrue);
          expect(probe.result, DateTime(2026, 10, 31));
          expect(probe.result!.isUtc, isFalse);

          for (final back in [false, true]) {
            await t.tap(find.byKey(const Key('wave4.openPicker')));
            await t.pumpAndSettle();
            if (back) {
              Navigator.of(t.element(find.byType(NightPickerDialog))).pop();
            } else {
              await t.tap(find.widgetWithText(TextButton, 'Cancel'));
            }
            await t.pumpAndSettle();
            expect(probe.completed, isTrue);
            expect(probe.result, isNull);
          }

          await t.tap(find.byKey(const Key('wave4.openPicker')));
          await t.pumpAndSettle();
          await t.tap(find.byKey(const Key('nightPicker.year')));
          await t.pumpAndSettle();
          await t.tap(find.text('2028'));
          await t.pumpAndSettle();
          expect(find.text('October 2028'), findsOneWidget);
          await t.tap(find.byTooltip('Previous month'));
          await t.pumpAndSettle();
          expect(find.text('September 2028'), findsOneWidget);
          await t.tap(find.byTooltip('Next month'));
          await t.pumpAndSettle();
          expect(find.text('October 2028'), findsOneWidget);
          await t.tap(find.byKey(const Key('nightPicker.inputMode')));
          await t.pumpAndSettle();
          await t.enterText(find.byType(TextFormField), 'invalid');
          await t.tap(find.widgetWithText(TextButton, 'OK'));
          await t.pumpAndSettle();
          expect(find.byType(NightPickerDialog), findsOneWidget);
          expect(probe.completed, isFalse);
          await t.enterText(find.byType(TextFormField), '02/29/2028');
          await t.tap(find.byKey(const Key('nightPicker.inputMode')));
          await t.pumpAndSettle();
          expect(find.text('February 2028'), findsOneWidget);
          _target(t, _day(t, DateTime(2028, 2, 29)));
          await t.tap(find.widgetWithText(TextButton, 'OK'));
          await t.pumpAndSettle();
          expect(probe.result, DateTime(2028, 2, 29));
          expect(probe.result!.isUtc, isFalse);
          expect(t.takeException(), isNull);
        },
      );
    }
  }
  testWidgets(
    'UIA-0009: actual parent constraints choose list at a 412dp window',
    (t) async {
      _case = 'light/412/parent332';
      await _open(t, 'light', 412, parentWidth: 332);
      _target(t, _day(t, DateTime(2026, 10, 19)));
      expect(find.byKey(const Key('nightPicker.dates')), findsOneWidget);
      expect(find.byType(GridView), findsNothing);
    },
  );
  for (final theme in ['light', 'dark', 'field']) {
    testWidgets(
      'UIA-0009 $theme: narrow date bounds disable pointer and semantic actions',
      (t) async {
        final probe = await _open(
          t,
          theme,
          320,
          firstDate: DateTime(2026, 10, 15),
          lastDate: DateTime(2026, 10, 20),
        );
        final disabled = _day(t, DateTime(2026, 10, 21));
        expect(
          t
              .widget<TextButton>(
                find.descendant(
                  of: disabled,
                  matching: find.byType(TextButton),
                ),
              )
              .onPressed,
          isNull,
        );
        expect(
          t
              .getSemantics(disabled)
              .getSemanticsData()
              .hasAction(ui.SemanticsAction.tap),
          isFalse,
        );
        expect(
          t
              .widget<IconButton>(
                find.byWidgetPredicate(
                  (w) => w is IconButton && w.tooltip == 'Previous month',
                ),
              )
              .onPressed,
          isNull,
        );
        expect(
          t
              .widget<IconButton>(
                find.byWidgetPredicate(
                  (w) => w is IconButton && w.tooltip == 'Next month',
                ),
              )
              .onPressed,
          isNull,
        );
        await captureWave1(t, 'wave4-date-$theme-320-bounds');
        await t.tap(_day(t, DateTime(2026, 10, 20)));
        await t.pumpAndSettle();
        await t.tap(find.widgetWithText(TextButton, 'OK'));
        await t.pumpAndSettle();
        expect(probe.result, DateTime(2026, 10, 20));
        expect(t.takeException(), isNull);
      },
    );
  }
}
