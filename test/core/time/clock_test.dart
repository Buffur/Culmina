import 'dart:io';

import 'package:astroplan/core/time/clock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('FixedClock returns its instant and requires UTC', () {
    final instant = DateTime.utc(2026, 9, 22, 1, 30);
    expect(FixedClock(instant).nowUtc(), instant);
    expect(() => FixedClock(DateTime(2026, 9, 22)), throwsArgumentError);
  });

  test('SystemClock returns UTC', () {
    expect(const SystemClock().nowUtc().isUtc, isTrue);
  });

  // TASK 2.2 acceptance / MASTER_ROADMAP AC2: "now" in the domain comes from a
  // Clock, never from DateTime.now().
  test('no DateTime.now() in lib/domain', () {
    final offenders = Directory('lib/domain')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => f.readAsStringSync().contains('DateTime.now('))
        .map((f) => f.path)
        .toList();
    expect(offenders, isEmpty);
  });

  // F24 A1 (TD-096): tests take "now" from a clock they give, or from
  // test/support/test_clock.dart's evening, never from the wall clock, so a
  // result never depends on the hour or the date of the run. This file is
  // the one exception (it tests SystemClock itself).
  test('no wall-clock reads in the tests', () {
    final offenders = [
      for (final dir in ['test', 'integration_test'])
        ...Directory(dir)
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'))
            .where((f) => !f.path.endsWith('clock_test.dart'))
            .where((f) {
              final code = f
                  .readAsLinesSync()
                  .where((l) => !l.trimLeft().startsWith('//'))
                  .join('\n');
              return code.contains('DateTime.now(') ||
                  code.contains('SystemClock(');
            })
            .map((f) => f.path),
    ];
    expect(offenders, isEmpty);
  });
}
