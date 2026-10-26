import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'wave1_capture.dart';

bool wave3FocusInside(WidgetTester t, Finder control) {
  final owner = t.element(control);
  final focused = FocusManager.instance.primaryFocus?.context;
  if (focused is! Element) return false;
  if (identical(owner, focused)) return true;
  var inside = false;
  focused.visitAncestorElements((element) {
    if (!identical(element, owner)) return true;
    inside = true;
    return false;
  });
  return inside;
}

Future<int> wave3TabTo(
  WidgetTester t,
  Finder control, {
  bool freshTab = false,
}) async {
  var tabs = 0;
  if (freshTab) {
    await t.sendKeyEvent(LogicalKeyboardKey.tab);
    await t.pump(const Duration(milliseconds: 40));
    tabs++;
  }
  while (!wave3FocusInside(t, control) && tabs < 80) {
    await t.sendKeyEvent(LogicalKeyboardKey.tab);
    await t.pump(const Duration(milliseconds: 40));
    tabs++;
  }
  expect(wave3FocusInside(t, control), isTrue);
  expect(FocusManager.instance.highlightMode, FocusHighlightMode.traditional);
  await t.pump(const Duration(milliseconds: 240));
  return tabs;
}

/// Sample the already-composited outer stroke, not a manual painter call.
/// No frame/dirty notification is injected before reading the layer.
Future<void> expectWave3PaintedRing(WidgetTester t, Finder field) async {
  final decorator = find
      .ancestor(
        of: find.byType(EditableText),
        matching: find.byType(InputDecorator),
      )
      .last;
  final boundary =
      wave1CaptureKey.currentContext!.findRenderObject()!
          as RenderRepaintBoundary;
  final box = t.renderObject<RenderBox>(decorator);
  final rect = MatrixUtils.transformRect(
    box.getTransformTo(boundary),
    Offset.zero & box.size,
  );
  final color = Theme.of(t.element(field)).colorScheme.primary;
  final expected = [
    (color.r * 255).round(),
    (color.g * 255).round(),
    (color.b * 255).round(),
  ];
  final sample = await t.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    try {
      final bytes = (await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      ))!;
      var columns = 0;
      var hits = 0;
      for (
        var x = (rect.left + 12).ceil();
        x < (rect.right - 12).floor();
        x++
      ) {
        if (x < 0 || x >= image.width) continue;
        columns++;
        for (var y = (rect.top - 6).floor(); y <= (rect.top - 2).ceil(); y++) {
          if (y < 0 || y >= image.height) continue;
          final offset = (y * image.width + x) * 4;
          if (List.generate(
            3,
            (channel) =>
                (bytes.getUint8(offset + channel) - expected[channel]).abs(),
          ).every((error) => error <= 8)) {
            hits++;
            break;
          }
        }
      }
      return (columns: columns, hits: hits);
    } finally {
      image.dispose();
    }
  });
  expect(sample!.columns, greaterThan(30));
  expect(
    sample.hits / sample.columns,
    greaterThan(0.8),
    reason:
        'the painted outer ring must follow the current post-layout field rect $rect',
  );
}
