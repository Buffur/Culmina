// S6.5: the planner's summary rows word the night and the forecast from
// domain values only: the dark span at the user's limit (TD-051), and the
// forecast's state with its age, stale wording or the reason there is none
// (ADR-012: no score, no good/bad word).

import 'package:astroplan/domain/models/moon_conditions.dart';
import 'package:astroplan/domain/models/night_timeline.dart';
import 'package:astroplan/domain/models/night_weather.dart';
import 'package:astroplan/domain/models/weather_snapshot.dart';
import 'package:astroplan/presentation/shared/night_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String at(DateTime utc) => '${utc.hour}:${utc.minute}';

  test('the dark span names its limit, and says when there is none', () {
    expect(
      DarkText.span(
        SunCrossing(
          -15,
          duskUtc: DateTime.utc(2026, 11, 10, 17, 5),
          dawnUtc: DateTime.utc(2026, 11, 11, 4, 40),
          belowAtStart: false,
          belowAtEnd: false,
        ),
        at,
      ),
      'Dark (Sun below −15°): 17:5 – 4:40',
    );
    expect(
      DarkText.span(const SunNeverBelow(-18), at),
      'Dark (Sun below −18°): not tonight',
    );
    expect(
      DarkText.span(const SunAlwaysBelow(-12), at),
      'Dark (Sun below −12°): all night',
    );
  });

  test('the forecast line: every state, with its age or its reason', () {
    final snapshot = WeatherSnapshot(
      provider: 'open-meteo',
      model: 'best_match',
      fetchedAtUtc: DateTime.utc(2026, 11, 10, 6),
      latitude: 46.05,
      longitude: 14.51,
      hours: const [],
    );
    NightWeatherAvailable available(WeatherAge age, Duration d) =>
        NightWeatherAvailable(
          snapshot: snapshot,
          age: age,
          ageDuration: d,
          fromCache: true,
        );

    expect(
      WeatherText.summary(
        available(WeatherAge.current, const Duration(minutes: 25)),
        null,
      ),
      'Cloud no forecast · Updated 25 min ago',
    );
    expect(
      WeatherText.summary(
        available(WeatherAge.stale, const Duration(hours: 13)),
        null,
      ),
      contains('Stale forecast: updated 13 h ago'),
    );
    expect(
      WeatherText.summary(
        const NightWeatherUnavailable(WeatherFailure.unavailable),
        null,
      ),
      'No forecast. Offline or the service did not answer.',
    );
    expect(
      WeatherText.summary(const NightWeatherOutOfRange(), null),
      contains('only the next 16 days'),
    );
    expect(
      WeatherText.summary(const NightWeatherLoading(), null),
      'Loading the forecast…',
    );
  });

  // S6.13 (UX-17): the Moon while it is dark, worded as the windows' note.
  test('the Moon during the dark span: down, all of it, or part', () {
    MoonDuringDark m(int upMin) => MoonDuringDark(
      dark: const Duration(hours: 7, minutes: 30),
      moonUp: Duration(minutes: upMin),
      illumination: 0.03,
    );
    expect(
      MoonText.duringDark(m(0)),
      'Moon down while dark (3 % lit at midnight)',
    );
    expect(
      MoonText.duringDark(m(450)),
      'Moon up all the dark time (3 % lit at midnight)',
    );
    expect(
      MoonText.duringDark(m(120)),
      'Moon up 2 h of the 7 h 30 min dark (3 % lit at midnight)',
    );
  });

  // ADR-022 N4/N5 (F13): the moon-free text for every class, and the names.
  test('the moon-free dark time, for every class', () {
    final t0 = DateTime.utc(2026, 12, 15, 18);
    String at(DateTime t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    MoonFreeNight m(MoonFreeKind kind, List<(int, int)> spans) => MoonFreeNight(
      kind: kind,
      intervals: [
        for (final (a, b) in spans)
          (t0.add(Duration(minutes: a)), t0.add(Duration(minutes: b))),
      ],
      moonFree: Duration(minutes: spans.fold(0, (sum, s) => sum + s.$2 - s.$1)),
      dark: const Duration(hours: 8),
    );
    expect(
      MoonText.moonFree(m(MoonFreeKind.noDark, []), at),
      'No dark time this night, so no moon-free time.',
    );
    expect(
      MoonText.moonFree(m(MoonFreeKind.none, []), at),
      'No moon-free dark time: the Moon is up all the 8 h dark.',
    );
    expect(
      MoonText.moonFree(m(MoonFreeKind.allNight, [(0, 480)]), at),
      'Moon-free all the dark time: 18:00–02:00 (8 h).',
    );
    expect(
      MoonText.moonFree(m(MoonFreeKind.evening, [(0, 150)]), at),
      'Moon-free in the evening: 18:00–20:30 (2 h 30 min).',
    );
    expect(
      MoonText.moonFree(m(MoonFreeKind.morning, [(300, 480)]), at),
      'Moon-free in the morning: 23:00–02:00 (3 h).',
    );
    expect(
      MoonText.moonFree(m(MoonFreeKind.middle, [(60, 120)]), at),
      'Moon-free in the middle of the night: 19:00–20:00 (1 h).',
    );
    expect(
      MoonText.moonFree(m(MoonFreeKind.mixed, [(0, 60), (300, 360)]), at),
      'Moon-free: 18:00–19:00, 23:00–00:00 (2 h in all).',
    );
  });

  test('the eight phase names', () {
    expect(
      [for (final p in MoonPhaseName.values) MoonText.phaseName(p)],
      [
        'New Moon',
        'Waxing crescent',
        'First quarter',
        'Waxing gibbous',
        'Full Moon',
        'Waning gibbous',
        'Last quarter',
        'Waning crescent',
      ],
    );
  });
}
