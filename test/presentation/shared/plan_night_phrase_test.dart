// F17 A5 / F18 A6 (AM-03; AM03-T = B): one plan-night phrase. "tonight"
// only when the plan's night is the current night; otherwise the night's
// date, in every "tonight" the text has; the words change, never a value.

import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/presentation/shared/plan_night_phrase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tonight = CalendarDate(2026, 12, 15);
  final other = CalendarDate(2026, 12, 18);

  test('tonight stays tonight; another night is named', () {
    expect(PlanNightPhrase.of(tonight, tonight), 'tonight');
    expect(PlanNightPhrase.of(other, tonight), 'on Fri, Dec 18');
    expect(PlanNightPhrase.title(tonight, tonight), 'Tonight');
    expect(PlanNightPhrase.title(null, tonight), 'Tonight');
    expect(PlanNightPhrase.title(other, tonight), 'Night of Fri, Dec 18');
    expect(
      PlanNightPhrase.candidatesTitle(other, tonight),
      'Candidates for Fri, Dec 18',
    );
  });

  test('apply rewords every tonight, keeps numbers, and leaves the current '
      'night as it is', () {
    const texts = [
      '3 frames don\'t fit tonight',
      'Fill tonight\'s window: Ha 300 s × 42',
      'Trim Ha 300 s to 12 frames to fit tonight',
      'Not even one L 60 s frame fits tonight.',
      'No usable window: the Sun never gets below -18° tonight.',
      "Choose a target to see tonight's windows.",
      "your Moon or cloud gate excludes all of tonight's dark time",
      'Tonight the Moon is up.',
      '+4 frames still fit tonight (other blocks as planned)',
    ];
    for (final t in texts) {
      expect(PlanNightPhrase.apply(t, tonight, tonight), t);
      final out = PlanNightPhrase.apply(t, other, tonight);
      expect(out.toLowerCase(), isNot(contains('tonight')), reason: t);
      expect(out, contains('Fri, Dec 18'), reason: t);
      // Every number survives unchanged.
      final digits = RegExp(r'[0-9]+');
      expect(
        digits.allMatches(out.replaceAll('18', '')).map((m) => m[0]),
        containsAll(digits.allMatches(t.replaceAll('18', '')).map((m) => m[0])),
        reason: t,
      );
    }
    expect(
      PlanNightPhrase.apply("Fill tonight's window: L × 3", other, tonight),
      'Fill the window on Fri, Dec 18: L × 3',
    );
    expect(
      PlanNightPhrase.apply('Tonight the Moon is up.', other, tonight),
      'On Fri, Dec 18 the Moon is up.',
    );
  });
}
