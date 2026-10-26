import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'hybrid_transfer_shots.dart';
import 'wave1_capture.dart';
import 'wave3_focus.dart';

class _InkSample {
  _InkSample(this.width, this.height, this.pixels, this.foreground);
  final int width;
  final int height;
  final List<int> pixels;
  final Color foreground;
  int get background {
    final counts = <int, int>{};
    for (final pixel in pixels) {
      counts[pixel] = (counts[pixel] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
}

Future<_InkSample> _sampleLabel(WidgetTester t, Finder label) async {
  final text = t.renderObject<RenderParagraph>(label);
  final boundary =
      wave1CaptureKey.currentContext!.findRenderObject()!
          as RenderRepaintBoundary;
  final rect = MatrixUtils.transformRect(
    text.getTransformTo(boundary),
    Offset.zero & text.size,
  );
  final foreground = text.text.style!.color!;
  return (await t.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    try {
      final data = (await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      ))!;
      final left = rect.left.floor().clamp(0, image.width);
      final top = rect.top.floor().clamp(0, image.height);
      final right = rect.right.ceil().clamp(0, image.width);
      final bottom = rect.bottom.ceil().clamp(0, image.height);
      return _InkSample(right - left, bottom - top, [
        for (var y = top; y < bottom; y++)
          for (var x = left; x < right; x++)
            (data.getUint8((y * image.width + x) * 4) << 16) |
                (data.getUint8((y * image.width + x) * 4 + 1) << 8) |
                data.getUint8((y * image.width + x) * 4 + 2),
      ], foreground);
    } finally {
      image.dispose();
    }
  }))!;
}

final _inkMetrics = <Map<String, Object?>>[];

int _distance(int a, int b) => [16, 8, 0]
    .map((shift) => (((a >> shift) & 255) - ((b >> shift) & 255)).abs())
    .reduce(math.max);

Future<void> _checkInk(
  WidgetTester t,
  Finder label,
  _InkSample baseline,
  String name,
  String theme,
) async {
  final actual = await _sampleLabel(t, label);
  expect((actual.width, actual.height), (baseline.width, baseline.height));
  final fg = actual.foreground.toARGB32() & 0xffffff;
  final background = baseline.background;
  final candidates = <int>{
    for (var i = 0; i < actual.pixels.length; i++)
      if (_distance(baseline.pixels[i], background) <= 2) actual.pixels[i],
  };
  expect(candidates, isNotEmpty);
  final luminance = actual.foreground.computeLuminance();
  double contrast(int rgb) {
    final back = Color(0xff000000 | rgb).computeLuminance();
    return (math.max(luminance, back) + .05) /
        (math.min(luminance, back) + .05);
  }

  final worst = candidates.reduce((a, b) => contrast(a) < contrast(b) ? a : b);
  final ratio = contrast(worst);
  final foregroundError = actual.pixels
      .map((pixel) => _distance(pixel, fg))
      .reduce(math.min);
  await captureWave1(t, name);
  _inkMetrics.add({
    'name': name,
    'theme': theme,
    'label': label.toString(),
    'foreground': fg.toRadixString(16).padLeft(6, '0'),
    'worstCompositedBackground': worst.toRadixString(16).padLeft(6, '0'),
    'contrast': ratio,
    'glyphCoreError': foregroundError,
    'backgroundSamples': candidates.length,
    'method': 'Actual Flutter layer, baseline glyph mask, worst active background; opaque foreground confirmed against rendered glyph pixels',
  });
  final output = Platform.environment['CULMINA_WAVE1_RENDER_DIR'];
  if (output != null) {
    await t.runAsync(() async {
      await File(
        '$output/contrast-metrics.json',
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(_inkMetrics));
      await File('$output/$name.json').writeAsString(
        const JsonEncoder.withIndent('  ').convert(_inkMetrics.last),
      );
    });
  }
  if (theme != 'field') {
    expect(
      foregroundError,
      lessThanOrEqualTo(8),
      reason: 'rendered glyph core must confirm the actual resolved foreground',
    );
    expect(
      ratio,
      greaterThanOrEqualTo(4.5),
      reason:
          '$name: actual enabled label contrast against the worst composited background',
    );
  }
}

Future<void> wave3FocusContrast(
  WidgetTester t,
  Finder label,
  String name,
  String theme,
) async {
  final baseline = await _sampleLabel(t, label);
  await _checkInk(t, label, baseline, name, theme);
}

Future<void> wave3HeldContrast(
  WidgetTester t,
  Finder control,
  Finder label,
  String name,
  String theme, {
  ui.PointerDeviceKind kind = ui.PointerDeviceKind.touch,
}) async {
  await wave3FocusContrast(t, label, '$name-rest', theme);
  await wave3TabTo(t, control);
  await t.ensureVisible(control);
  await hybridSettle(t);
  await wave3FocusContrast(t, label, '$name-focus', theme);
  await _heldInk(t, control, label, name, theme, kind);
  if (kind == ui.PointerDeviceKind.touch) {
    await wave3TabTo(t, control, freshTab: true);
    await t.ensureVisible(control);
    await hybridSettle(t);
    await _heldInk(
      t,
      control,
      label,
      '$name-mouse-combined',
      theme,
      ui.PointerDeviceKind.mouse,
    );
  }
}

Future<void> wave3UnfocusedHeldContrast(
  WidgetTester t,
  Finder control,
  Finder label,
  String name,
  String theme,
) async {
  await wave3TabTo(t, control);
  await t.sendKeyEvent(LogicalKeyboardKey.tab);
  await t.pump(const Duration(milliseconds: 240));
  expect(wave3FocusInside(t, control), isFalse);
  await _heldInk(
    t,
    control,
    label,
    name,
    theme,
    ui.PointerDeviceKind.mouse,
    requireUnfocused: true,
  );
}

List<Map<String, Object?>> get wave3InkMetrics =>
    List.unmodifiable(_inkMetrics);

Future<void> _heldInk(
  WidgetTester t,
  Finder control,
  Finder label,
  String name,
  String theme,
  ui.PointerDeviceKind kind, {
  bool requireUnfocused = false,
}) async {
  final gesture = await t.createGesture(kind: kind);
  final point = t.getCenter(control);
  if (kind == ui.PointerDeviceKind.mouse) {
    await gesture.addPointer(location: point);
    await gesture.moveTo(point);
    await t.pump(const Duration(milliseconds: 220));
  }
  final baseline = await _sampleLabel(t, label);
  try {
    await gesture.down(point);
    await t.pump();
    if (requireUnfocused && wave3FocusInside(t, control)) {
      // Mouse DOWN requests focus. Move it with an actual Tab while the
      // pointer remains held, rather than forcing a focus/highlight policy.
      await t.sendKeyEvent(LogicalKeyboardKey.tab);
      await t.pump();
    }
    await t.pump(const Duration(milliseconds: 110));
    await t.pump(const Duration(milliseconds: 200));
    if (requireUnfocused) expect(wave3FocusInside(t, control), isFalse);
    await _checkInk(t, label, baseline, name, theme);
  } finally {
    await gesture.cancel();
    if (kind == ui.PointerDeviceKind.mouse) await gesture.removePointer();
    await hybridSettle(t);
  }
}
