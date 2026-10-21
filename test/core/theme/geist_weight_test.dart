// Geist is bundled as one variable font (wght 100–900). The Hybrid roles use
// weights 400, 500 and 600; each must select its own instance of the font,
// not one regular outline (or a synthetic bold), or the hierarchy of the
// approved design flattens. A heavier instance sets wider glyphs, so the
// same text measures wider at each step.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

double _width(FontWeight weight) {
  final painter = TextPainter(
    text: TextSpan(
      text: 'Needed in imaging window 1 h 48 min 20 s',
      style: TextStyle(fontFamily: 'Geist', fontSize: 16, fontWeight: weight),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  final width = painter.width;
  painter.dispose();
  return width;
}

void main() {
  setUpAll(() async {
    final bytes = File('assets/fonts/Geist.ttf').readAsBytesSync();
    await (FontLoader(
      'Geist',
    )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
  });

  test('w400 < w500 < w600 < w700: each weight is its own Geist instance', () {
    final widths = [
      for (final w in [
        FontWeight.w400,
        FontWeight.w500,
        FontWeight.w600,
        FontWeight.w700,
      ])
        _width(w),
    ];
    for (var i = 1; i < widths.length; i++) {
      expect(widths[i], greaterThan(widths[i - 1]), reason: '$widths');
    }
  });
}
