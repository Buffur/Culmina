// Presentation style rules (TASK 12.4): colours come from theme tokens
// (`ColorScheme`, `AppPalette`), never from `Colors.*` or colour literals,
// and no text is set under 12 sp.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final files = Directory('lib/presentation')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  List<String> offenders(RegExp pattern) => [
    for (final f in files)
      for (final (i, line) in f.readAsLinesSync().indexed)
        if (!line.trimLeft().startsWith('//') && pattern.hasMatch(line))
          '${f.path}:${i + 1}: ${line.trim()}',
  ];

  test('no hard-coded colour in lib/presentation', () {
    expect(offenders(RegExp(r'\bColors\.|\bColor\(0x')), isEmpty);
  });

  test('no font size under 12 sp in lib/presentation', () {
    expect(offenders(RegExp(r'fontSize:\s*(\d|1[01])(\.\d+)?\b')), isEmpty);
  });

  test('presentation reads typography through the theme', () {
    expect(offenders(RegExp(r'\bAppTypography\s*\.')), isEmpty);
    expect(offenders(RegExp(r'\bfontSize\s*:')), isEmpty);
    expect(offenders(RegExp(r'\bTextStyle\s*\(')), isEmpty);
  });

  test('text geometry is not overridden inside presentation copyWith', () {
    final violations = <String>[];
    for (final file in files) {
      final source = file.readAsStringSync();
      for (final call in RegExp(r'\.copyWith\([\s\S]*?\)').allMatches(source)) {
        if (RegExp(r'\b(fontSize|height|letterSpacing|fontFamily)\s*:')
            .hasMatch(call.group(0)!)) {
          violations.add('${file.path}: ${call.group(0)}');
        }
      }
    }
    expect(violations, isEmpty);
  });

  test('no shrink-wrapped tap target (keeps 48 dp)', () {
    expect(offenders(RegExp(r'MaterialTapTargetSize\.shrinkWrap')), isEmpty);
  });
}
