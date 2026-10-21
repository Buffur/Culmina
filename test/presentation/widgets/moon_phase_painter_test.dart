// The Moon calendar's phase glyph lights the right part of the disc: almost
// nothing at New Moon, all of it at Full Moon, the right half at First
// Quarter and the left half at Last Quarter. (The migration's visual audit
// found the terminator drawn the wrong way round: New Moon as a full disc.)

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:astroplan/presentation/widgets/night_browser_sections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _lit = Color(0xFF000000);
const _shadow = Color(0xFFFFFFFF);

Future<ByteData> _render(double phaseLongitudeDeg) async {
  final recorder = ui.PictureRecorder();
  MoonPhasePainter(
    phaseLongitudeDeg: phaseLongitudeDeg,
    lit: _lit,
    dark: const Color(0xFF808080),
    shadow: _shadow,
  ).paint(Canvas(recorder), const Size(40, 40));
  final image = await recorder.endRecording().toImage(40, 40);
  return (await image.toByteData())!;
}

/// Whether the pixel at ([x], [y]) is (mostly) the lit colour.
bool _litAt(ByteData rgba, int x, int y) =>
    rgba.getUint8((y * 40 + x) * 4) < 64;

void main() {
  test(
    'New Moon is dark, Full Moon lit, quarters lit on their own side',
    () async {
      final newMoon = await _render(2);
      expect(_litAt(newMoon, 20, 20), isFalse, reason: 'New Moon centre');
      expect(_litAt(newMoon, 10, 20), isFalse);

      final full = await _render(180);
      expect(_litAt(full, 20, 20), isTrue, reason: 'Full Moon centre');
      expect(_litAt(full, 8, 20), isTrue);
      expect(_litAt(full, 32, 20), isTrue);

      final firstQuarter = await _render(90);
      expect(_litAt(firstQuarter, 30, 20), isTrue, reason: 'waxing: right lit');
      expect(_litAt(firstQuarter, 10, 20), isFalse);

      final lastQuarter = await _render(270);
      expect(_litAt(lastQuarter, 10, 20), isTrue, reason: 'waning: left lit');
      expect(_litAt(lastQuarter, 30, 20), isFalse);

      final waxingCrescent = await _render(45);
      expect(_litAt(waxingCrescent, 34, 20), isTrue, reason: 'thin right limb');
      expect(_litAt(waxingCrescent, 20, 20), isFalse);

      final waxingGibbous = await _render(135);
      expect(_litAt(waxingGibbous, 20, 20), isTrue);
      expect(_litAt(waxingGibbous, 5, 20), isFalse, reason: 'left limb dark');
    },
  );
}
