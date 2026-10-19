// TASK 9.4 (ADR-012 §3–§5) and F14 (ADR-022 N6): the night's weather summary
// is a pure function — sliced to the dark span at the plan's darkness limit,
// instantaneous values at the instants in the span, preceding-hour values
// (precipitation chance, gusts) when at least 30 min of their hour is in it,
// "no forecast" gaps never 0, and the dew heuristic against the configured
// margin. W1/W2 are ADR-022's vectors.

import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/night_timeline.dart';
import 'package:astroplan/domain/models/night_weather_summary.dart';
import 'package:astroplan/domain/models/session_night.dart';
import 'package:astroplan/domain/models/site_time_context.dart';
import 'package:astroplan/domain/models/weather_snapshot.dart';
import 'package:astroplan/domain/services/night_weather_summarizer.dart';
import 'package:astroplan/domain/services/session_night_resolver.dart';
import 'package:astroplan/domain/services/visibility_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

WeatherSnapshot _snapshot(List<WeatherHour> hours) => WeatherSnapshot(
  provider: 'open-meteo',
  model: 'best_match',
  fetchedAtUtc: DateTime.utc(2026, 9, 24, 12),
  latitude: 46.05,
  longitude: 14.51,
  hours: hours,
);

DateTime _h(int day, int hour) => DateTime.utc(2026, 9, day, hour);

final _night = SessionNight(
  eveningDate: CalendarDate(2026, 9, 24),
  startUtc: _h(24, 11),
  endUtc: _h(25, 11),
  latitude: 46.05,
  longitude: 14.51,
  timeContextId: 'test',
);

NightTimeline _timeline(
  SunThresholdResult dark, {
  SunThresholdResult sunriseSunset = const SunNeverBelow(-0.833),
}) => NightTimeline(
  night: _night,
  sunriseSunset: sunriseSunset,
  civilTwilight: const SunNeverBelow(-6),
  nauticalTwilight: const SunNeverBelow(-12),
  astronomicalTwilight: dark,
  darkAtLimit: dark,
);

void main() {
  group('summarize (N6)', () {
    test('W1: dark 19:10–04:50 — instants 20:00…04:00; the 20:00 and 05:00 '
        'preceding hours included (50 min each), partial', () {
      final rows = [
        for (
          var t = _h(24, 18);
          !t.isAfter(_h(25, 6));
          t = t.add(const Duration(hours: 1))
        )
          WeatherHour(timeUtc: t, cloudCoverPct: 20, windGustsKmh: 30),
      ];
      final s = NightWeatherSummarizer.summarize(
        _snapshot(rows),
        fromUtc: DateTime.utc(2026, 9, 24, 19, 10),
        toUtc: DateTime.utc(2026, 9, 25, 4, 50),
        dewMarginC: 2,
      );
      final instants = [
        for (final x in s.slots)
          if (x.instant) x.timeUtc.hour,
      ];
      expect(instants, [20, 21, 22, 23, 0, 1, 2, 3, 4]);
      expect(s.totalHours, 9);
      final preceding = [
        for (final x in s.slots)
          if (x.preceding) x.timeUtc.hour,
      ];
      expect(preceding, [20, 21, 22, 23, 0, 1, 2, 3, 4, 5]);
      final first = s.slots.first, last = s.slots.last;
      expect(
        (first.timeUtc, first.precedingMinutes, first.partial),
        (_h(24, 20), 50, true),
      );
      expect(
        (last.timeUtc, last.instant, last.precedingMinutes),
        (_h(25, 5), false, 50),
      );
      expect(s.slots.where((x) => x.partial), hasLength(2));
      expect(s.complete, isTrue);
      expect(s.slots.every((x) => x.timeUtc.isUtc), isTrue);
    });

    test('an hour with under 30 min in the span carries no preceding values; '
        'an instant on the boundary counts', () {
      final s = NightWeatherSummarizer.summarize(
        _snapshot([
          WeatherHour(timeUtc: _h(24, 20), precipitationProbabilityPct: 90),
          WeatherHour(timeUtc: _h(24, 21), precipitationProbabilityPct: 10),
          WeatherHour(timeUtc: _h(24, 22), precipitationProbabilityPct: 70),
        ]),
        fromUtc: _h(24, 20), // exactly on the hour: (19, 20] is outside
        toUtc: DateTime.utc(2026, 9, 24, 21, 20), // (21, 22] 20 min: out
        dewMarginC: 2,
      );
      expect(s.slots.map((x) => (x.timeUtc.hour, x.instant, x.preceding)), [
        (20, true, false),
        (21, true, true),
      ]);
      expect(s.precipitationProbability!.min, 10);
      expect(s.precipitationProbability!.max, 10, reason: '90 and 70 out');
    });

    test('ranges use only the counted rows; missing values are ignored, '
        'never 0', () {
      final s = NightWeatherSummarizer.summarize(
        _snapshot([
          WeatherHour(timeUtc: _h(24, 16), cloudCoverPct: 100), // before
          WeatherHour(
            timeUtc: _h(24, 18),
            cloudCoverPct: 40,
            windSpeedKmh: 12,
            visibilityM: 24000,
          ),
          WeatherHour(timeUtc: _h(24, 19), cloudCoverPct: 10),
          WeatherHour(timeUtc: _h(24, 20), cloudCoverPct: 25),
          WeatherHour(timeUtc: _h(24, 22), cloudCoverPct: 90), // after
        ]),
        fromUtc: _h(24, 18),
        toUtc: _h(24, 20),
        dewMarginC: 2,
      );
      expect(s.totalHours, 3);
      expect(s.coveredHours, 3);
      expect(s.cloudCover!.min, 10);
      expect(s.cloudCover!.max, 40);
      expect(s.windSpeed!.min, 12);
      expect(s.windSpeed!.max, 12);
      expect(s.visibility!.max, 24000);
      expect(s.precipitationProbability, isNull, reason: 'unknown, not 0');
      expect(s.cloudCoverHigh, isNull);
    });

    test('rows the snapshot lacks are "no forecast" (partial coverage)', () {
      final s = NightWeatherSummarizer.summarize(
        _snapshot([WeatherHour(timeUtc: _h(24, 18), cloudCoverPct: 5)]),
        fromUtc: _h(24, 18),
        toUtc: _h(24, 20),
        dewMarginC: 2,
      );
      expect(s.coveredHours, 1);
      expect(s.complete, isFalse);
      expect(s.slots[1].hour, isNull);
      expect(s.slots[2].hour, isNull);
      expect(s.cloudCover!.min, 5);
    });

    test('W2: a null cloud value at 23:00 is a gap of 1 h, never 0 %', () {
      final s = NightWeatherSummarizer.summarize(
        _snapshot([
          for (final h in [21, 22, 23, 0])
            WeatherHour(
              timeUtc: h == 0 ? _h(25, 0) : _h(24, h),
              cloudCoverPct: h == 23 ? null : 30,
            ),
        ]),
        fromUtc: _h(24, 21),
        toUtc: _h(25, 0),
        dewMarginC: 2,
      );
      expect(s.complete, isTrue, reason: 'every row is there');
      expect(s.cloudGapHours, 1);
      expect(s.cloudCover!.min, 30, reason: 'the gap is not 0 %');
    });

    test('dew spread is flagged at or below the margin, unknown without '
        'both values; about one hour per instant', () {
      final s = NightWeatherSummarizer.summarize(
        _snapshot([
          WeatherHour(timeUtc: _h(24, 18), temperatureC: 10, dewPointC: 7),
          WeatherHour(timeUtc: _h(24, 19), temperatureC: 9, dewPointC: 7),
          WeatherHour(timeUtc: _h(24, 20), temperatureC: 8.5, dewPointC: 7),
          WeatherHour(timeUtc: _h(24, 21), temperatureC: 8),
        ]),
        fromUtc: _h(24, 18),
        toUtc: _h(24, 21),
        dewMarginC: 2,
      );
      expect(s.slots.map((x) => x.dewSpreadC), [3, 2, 1.5, null]);
      expect(s.slots.map((x) => x.dewRisk), [false, true, true, null]);
      expect(s.dewKnownHours, 3);
      expect(s.dewRiskHours, 2);
      expect(s.dewSpread!.min, 1.5);
      expect(s.dewSpread!.max, 3);
      expect(s.dewMarginC, 2);
    });

    test('the margin is the configured one', () {
      final snap = _snapshot([
        WeatherHour(timeUtc: _h(24, 18), temperatureC: 10, dewPointC: 7),
      ]);
      bool? risk(double margin) => NightWeatherSummarizer.summarize(
        snap,
        fromUtc: _h(24, 18),
        toUtc: _h(24, 18),
        dewMarginC: margin,
      ).slots.single.dewRisk;
      expect(risk(2), isFalse);
      expect(risk(3), isTrue);
    });

    test('no dark time: no row is summarized', () {
      final s = NightWeatherSummarizer.summarize(
        _snapshot([WeatherHour(timeUtc: _h(24, 20), cloudCoverPct: 50)]),
        fromUtc: _h(24, 18),
        toUtc: _h(25, 4),
        dewMarginC: 2,
        span: NightWeatherSpan.noDark,
      );
      expect(s.slots, isEmpty);
      expect(s.cloudCover, isNull);
      expect(s.complete, isFalse);
    });
  });

  group('spanOf (the dark span, N6)', () {
    test('a normal night runs from dusk to dawn at the limit', () {
      final span = NightWeatherSummarizer.spanOf(
        _timeline(
          SunCrossing(
            -18,
            duskUtc: DateTime.utc(2026, 9, 24, 19, 10),
            dawnUtc: DateTime.utc(2026, 9, 25, 4, 50),
          ),
        ),
      );
      expect(span.fromUtc, DateTime.utc(2026, 9, 24, 19, 10));
      expect(span.toUtc, DateTime.utc(2026, 9, 25, 4, 50));
      expect(span.span, NightWeatherSpan.dark);
    });

    test('an edge outside the window falls back to the window edge', () {
      final span = NightWeatherSummarizer.spanOf(
        _timeline(
          SunCrossing(
            -18,
            dawnUtc: DateTime.utc(2026, 9, 25, 4),
            belowAtStart: true,
          ),
        ),
      );
      expect(span.fromUtc, _night.startUtc);
      expect(span.toUtc, DateTime.utc(2026, 9, 25, 4));
    });

    test('no dark time: sunset to sunrise for the text only; polar night: '
        'the whole window', () {
      final none = NightWeatherSummarizer.spanOf(
        _timeline(
          const SunNeverBelow(-18),
          sunriseSunset: SunCrossing(
            -0.833,
            duskUtc: DateTime.utc(2026, 9, 24, 20, 30),
            dawnUtc: DateTime.utc(2026, 9, 25, 3, 30),
          ),
        ),
      );
      expect(none.span, NightWeatherSpan.noDark);
      expect(none.fromUtc, DateTime.utc(2026, 9, 24, 20, 30));
      expect(none.toUtc, DateTime.utc(2026, 9, 25, 3, 30));
      final midnightSun = NightWeatherSummarizer.spanOf(
        _timeline(const SunNeverBelow(-18)),
      );
      expect(midnightSun.span, NightWeatherSpan.noDark);
      expect(midnightSun.fromUtc, _night.startUtc);
      final polar = NightWeatherSummarizer.spanOf(
        _timeline(const SunAlwaysBelow(-18)),
      );
      expect(polar.span, NightWeatherSpan.polarNight);
      expect(polar.toUtc.difference(polar.fromUtc), const Duration(hours: 24));
    });

    test('a real night: Ljubljana on 2026-09-24 is dark (−18°) from about '
        '18:50 to 03:20 UTC', () {
      final night = SessionNightResolver.forEveningDate(
        CalendarDate(2026, 9, 24),
        latitude: 46.05,
        longitude: 14.51,
        timeContext: MeanSolarTimeContext(14.51),
      );
      final span = NightWeatherSummarizer.spanOf(
        VisibilityCalculator.calculateNightTimelineForNight(
          night,
          darknessLimitDeg: -18,
        ),
      );
      expect(span.span, NightWeatherSpan.dark);
      expect(span.fromUtc.day, 24);
      expect(span.fromUtc.hour, anyOf(18, 19));
      expect(span.toUtc.day, 25);
      expect(span.toUtc.hour, anyOf(3, 4));
    });
  });

  // Acceptance: a night 5 days ahead shows its own hours, or "no forecast".
  test('a night 5 days ahead shows its own hours, or no forecast', () {
    final ahead = SessionNightResolver.forEveningDate(
      CalendarDate(2026, 9, 29),
      latitude: 46.05,
      longitude: 14.51,
      timeContext: MeanSolarTimeContext(14.51),
    );
    final span = NightWeatherSummarizer.spanOf(
      VisibilityCalculator.calculateNightTimelineForNight(
        ahead,
        darknessLimitDeg: -18,
      ),
    );
    NightWeatherSummary summarize(List<WeatherHour> hours) =>
        NightWeatherSummarizer.summarize(
          _snapshot(hours),
          fromUtc: span.fromUtc,
          toUtc: span.toUtc,
          dewMarginC: 2,
        );
    final own = summarize([
      for (
        var t = span.fromUtc.subtract(const Duration(hours: 1));
        !t.isAfter(span.toUtc.add(const Duration(hours: 1)));
        t = t.add(const Duration(hours: 1))
      )
        WeatherHour(
          timeUtc: DateTime.utc(t.year, t.month, t.day, t.hour),
          cloudCoverPct: 30,
        ),
    ]);
    expect(own.slots.first.timeUtc.day, 29);
    expect(own.complete, isTrue);

    // Today's hours (another night) never stand in for that night.
    final other = summarize([
      WeatherHour(timeUtc: DateTime.utc(2026, 9, 24, 20), cloudCoverPct: 0),
    ]);
    expect(other.coveredHours, 0);
    expect(other.cloudCover, isNull);
  });
}
