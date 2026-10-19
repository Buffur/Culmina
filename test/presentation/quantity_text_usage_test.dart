// F25 A2: no hand-formatted covered quantity bypasses QuantityText. Bounded
// to the quantities QuantityText has one written form for — a percentage,
// an angle in degrees, a storage size, a temperature, a wind speed and an
// elevation (and their unit symbols) — in `lib/presentation`. A number
// formatted on the spot and followed by one of those units is a bypass.
// (Seconds and minutes in Settings' slider labels are the settings' own
// units, written whole on purpose, and are not covered here.)

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

final _bypass = RegExp(
  r'(toStringAsFixed\(\d*\)|\.round\(\)|\.toInt\(\))\}\s?'
  r'(%|°|MB\b|GB\b|km/h|mph\b|m/s\b|ft\b)',
);

/// Hard-coded unit symbols the display units replace (F21).
final _fixedUnit = RegExp(r"""['"](°C|°F|km/h)['"]""");

/// The bypasses in [source], by line.
List<String> bypasses(String source) => [
  for (final (i, line) in source.split('\n').indexed)
    if (!line.trimLeft().startsWith('//') &&
        (_bypass.hasMatch(line) || _fixedUnit.hasMatch(line)))
      'line ${i + 1}: ${line.trim()}',
];

void main() {
  test('lib/presentation formats covered quantities through QuantityText', () {
    final problems = {
      for (final f
          in Directory('lib/presentation')
              .listSync(recursive: true)
              .whereType<File>()
              .where((f) => f.path.endsWith('.dart')))
        if (bypasses(f.readAsStringSync()) case final found
            when found.isNotEmpty)
          f.path: found,
    };
    expect(problems, isEmpty);
  });

  test('the check sees what it forbids, and allows QuantityText', () {
    expect(bypasses(r"label: '${p.margin.round()} %',"), hasLength(1));
    expect(bypasses(r"'${v.toStringAsFixed(2)}°'"), hasLength(1));
    expect(bypasses(r"'${(b / 1e6).toStringAsFixed(2)} MB'"), hasLength(1));
    expect(bypasses(r"'${w.round()} km/h'"), hasLength(1));
    expect(bypasses("WeatherText.range(s.temperature, '°C')"), hasLength(1));
    expect(bypasses('label: QuantityText.percent(p.margin),'), isEmpty);
    expect(bypasses(r"'${QuantityText.degrees(v)} away'"), isEmpty);
    expect(bypasses(r"// '${v.round()} %' in a comment"), isEmpty);
  });
}
