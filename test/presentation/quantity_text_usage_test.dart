// F25 A2: no hand-formatted covered quantity bypasses QuantityText. Bounded
// to the quantities QuantityText has one written form for — a percentage,
// an angle in degrees, a storage size, a temperature, a wind speed and an
// elevation (and their unit symbols) — in `lib/presentation` and in
// `lib/domain` (whose reasons are shown as they are). A number formatted
// on the spot, or any value interpolated other than through QuantityText,
// followed by one of those units is a bypass; a field's own text echoed as
// typed is marked `// as typed`. (Seconds and minutes in Settings' slider
// labels are the settings' own units, written whole on purpose, and are
// not covered here.)

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _units = r'(%|°|MB\b|GB\b|km/h|mph\b|m/s\b|ft\b)';

final _bypass = RegExp(
  r'(toStringAsFixed\(\d*\)|\.round\(\)|\.toInt\(\))\}\s?' + _units,
);

/// A value interpolated directly before a unit, other than a QuantityText
/// call: `'$h %'`, `'${n(v)} MB'`, `'$limit°'`.
final _interpolated = RegExp(
  r'\$(\{(?!QuantityText\.)[^}]*\}|[A-Za-z_]\w*(?!\w))\s?' + _units,
);

/// Hard-coded unit symbols the display units replace (F21).
final _fixedUnit = RegExp(r"""['"](°C|°F|km/h)['"]""");

/// The bypasses in [source], by line.
List<String> bypasses(String source) => [
  for (final (i, line) in source.split('\n').indexed)
    if (!line.trimLeft().startsWith('//') &&
        !line.trimRight().endsWith('// as typed') &&
        (_bypass.hasMatch(line) ||
            _interpolated.hasMatch(line) ||
            _fixedUnit.hasMatch(line)))
      'line ${i + 1}: ${line.trim()}',
];

void main() {
  test('lib/presentation and lib/domain format covered quantities through '
      'QuantityText', () {
    final problems = {
      for (final f in [
        for (final dir in ['lib/presentation', 'lib/domain'])
          ...Directory(dir).listSync(recursive: true),
      ].whereType<File>().where((f) => f.path.endsWith('.dart')))
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
    expect(bypasses(r"'Humidity': '$h %',"), hasLength(1));
    expect(bypasses(r"'${n(v)} MB'"), hasLength(1));
    expect(bypasses(r"'below $limit° tonight'"), hasLength(1));
    expect(bypasses(r"'$time (+$dayShift)'"), isEmpty, reason: 'not a unit');
    expect(bypasses(r"'RAW ${raw.trim()} MB', // as typed"), isEmpty);
  });
}
