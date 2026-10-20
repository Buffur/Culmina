import 'dart:ui';

import 'package:astroplan/presentation/shared/sky_color_interpolation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Oklab neutral midpoint matches CSS perceptual mixing, not sRGB mean',
    () {
      final color = mixSkyColors(
        const Color(0xFF000000),
        const Color(0xFFFFFFFF),
        .5,
      );
      // Oklab L=.5 gives linear-light RGB=.125, hence sRGB≈.388573.
      for (final channel in [color.r, color.g, color.b]) {
        expect(channel, closeTo(.388573, .00001));
      }
      expect(color.a, 1);
    },
  );

  test('approved sky endpoints survive conversion without changing alpha', () {
    const first = Color(0xFFDFE9E9);
    const last = Color(0xFF475A72);
    for (final (fraction, expected) in [(0.0, first), (1.0, last)]) {
      final actual = mixSkyColors(first, last, fraction);
      expect(actual.r, closeTo(expected.r, .00001));
      expect(actual.g, closeTo(expected.g, .00001));
      expect(actual.b, closeTo(expected.b, .00001));
      expect(actual.a, 1);
    }
  });
}
