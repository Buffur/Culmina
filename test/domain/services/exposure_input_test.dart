// F06 A5 (ADR-021 C14, AM-04): an exposure is typed as decimal seconds or a
// familiar fraction and stored as canonical seconds within the existing
// bounds; anything else fails with a reason for the field.

import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/services/exposure_input.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('decimal seconds and fractions give canonical seconds', () {
    expect(ExposureInput.parse('60'), 60);
    expect(ExposureInput.parse(' 0.5 '), 0.5);
    expect(ExposureInput.parse('1/14'), 1 / 14);
    expect(ExposureInput.parse('1 / 250 s'), 1 / 250);
    expect(ExposureInput.parse('1/14s'), 1 / 14);
    expect(ExposureInput.parse('30 s'), 30);
    expect(ExposureInput.parse('3/2'), 1.5);
    expect(ExposureInput.parse('3600'), CaptureBlock.maxExposureSeconds);
  });

  test('zero, negative, a zero denominator, text and too long fail', () {
    for (final bad in [
      '',
      '0',
      '-1',
      '0/5',
      '1/0',
      'abc',
      '1/',
      '/4',
      '3601',
      '1/-4',
      '1.5/2',
      'NaN',
      'Infinity',
    ]) {
      expect(ExposureInput.parse(bad), isNull, reason: bad);
      expect(ExposureInput.problem(bad), isNotNull, reason: bad);
    }
    expect(
      ExposureInput.problem('1/0'),
      'A fraction needs a denominator above 0',
    );
    expect(ExposureInput.problem('3601'), 'At most 3600 s');
    expect(ExposureInput.problem('abc'), 'Enter seconds, e.g. 60, 0.5 or 1/14');
    expect(ExposureInput.problem('1/14'), isNull);
  });

  test('the field shows an exact reciprocal as a fraction, and parsing it '
      'gives the stored value back', () {
    for (final s in [1 / 14, 1 / 250, 0.5, 60.0, 2.5, 0.3, 1 / 3]) {
      final text = ExposureInput.format(s);
      expect(ExposureInput.parse(text), s, reason: text);
    }
    expect(ExposureInput.format(1 / 14), '1/14');
    expect(ExposureInput.format(0.5), '1/2');
    expect(ExposureInput.format(60), '60');
    expect(ExposureInput.format(2.5), '2.5');
    expect(ExposureInput.format(0.3), '0.3');
  });
}
