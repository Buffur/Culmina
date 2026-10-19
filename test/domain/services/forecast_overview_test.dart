// F14 A1 (ADR-022 N6/N7/N9): one forecast of up to 16 days is never 16
// complete nights. Each night is cut to its own dark span; its coverage is
// complete, partial (the forecast starts later, ends before dawn, or has
// gaps), none or no dark time; nights after the forecast's last row are
// "beyond"; the lead time is the evening date − the site-local fetch date
// (W3). A DST night keeps its UTC instants.

import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/iana_time_context.dart';
import 'package:astroplan/domain/models/night_timeline.dart';
import 'package:astroplan/domain/models/site_time_context.dart';
import 'package:astroplan/domain/models/weather_snapshot.dart';
import 'package:astroplan/domain/services/forecast_overview.dart';
import 'package:astroplan/domain/services/night_weather_summarizer.dart';
import 'package:astroplan/domain/services/session_night_resolver.dart';
import 'package:astroplan/domain/services/visibility_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

const _lat = 46.05, _lon = 14.51;
final _zone = IanaTimeContext.tryCreate('Europe/Ljubljana')!;

NightTimeline _timeline(CalendarDate date, {double lat = _lat}) =>
    VisibilityCalculator.calculateNightTimelineForNight(
      SessionNightResolver.forEveningDate(
        date,
        latitude: lat,
        longitude: _lon,
        timeContext: _zone,
      ),
      darknessLimitDeg: -18,
    );

WeatherSnapshot _rows(
  DateTime from,
  DateTime to, {
  DateTime? fetched,
  Set<DateTime> missing = const {},
}) => WeatherSnapshot(
  provider: 'open-meteo',
  model: 'best_match',
  fetchedAtUtc: fetched ?? from,
  latitude: _lat,
  longitude: _lon,
  hours: [
    for (var t = from; !t.isAfter(to); t = t.add(const Duration(hours: 1)))
      if (!missing.contains(t)) WeatherHour(timeUtc: t, cloudCoverPct: 30),
  ],
);

void main() {
  final d0 = CalendarDate(2026, 12, 16);
  final nights = [for (var i = 0; i < 5; i++) _timeline(d0.addDays(i))];

  test('complete, partial before and after, gaps, and beyond', () {
    // Rows from 21:00 UTC on the 16th to 02:00 UTC on the 19th.
    final gap = DateTime.utc(2026, 12, 19, 0); // in the 18th's night
    final s = _rows(
      DateTime.utc(2026, 12, 16, 21),
      DateTime.utc(2026, 12, 19, 2),
      fetched: DateTime.utc(2026, 12, 16, 9),
      missing: {gap},
    );
    final o = ForecastOverview.of(s, nights, dewMarginC: 2, timeContext: _zone);
    expect(o.nights, hasLength(3));
    expect(o.firstBeyond, d0.addDays(3));
    final [first, second, third] = o.nights;
    // The 16th: dark from about 17:00 UTC; the rows start at 21:00.
    expect(first.coverage, ForecastCoverage.partial);
    expect(first.missingBefore, greaterThan(0));
    expect(first.missingAfter, 0);
    expect(first.gaps, 0);
    // The 17th: every dark hour has a row.
    expect(second.coverage, ForecastCoverage.complete);
    expect(second.summary.coveredHours, second.summary.totalHours);
    expect(second.missingBefore + second.missingAfter + second.gaps, 0);
    // The 18th: a gap at its midnight, and the rows end at 02:00.
    expect(third.coverage, ForecastCoverage.partial);
    expect(third.gaps, 1);
    expect(third.missingAfter, greaterThan(0));
    // W3 (N9): fetched 10:00 local on the 16th.
    expect([for (final n in o.nights) n.leadDays], [0, 1, 2]);
  });

  test('W3: fetched 2026-12-16 10:00 local, night 2026-12-18 → 2 days', () {
    final fetched = DateTime.utc(2026, 12, 16, 9); // 10:00 CET
    expect(ForecastOverview.localDate(fetched, _zone), d0);
    expect(ForecastOverview.daysBetween(d0, CalendarDate(2026, 12, 18)), 2);
    // Just after local midnight it is already the 17th.
    expect(
      ForecastOverview.localDate(DateTime.utc(2026, 12, 16, 23, 30), _zone),
      CalendarDate(2026, 12, 17),
    );
  });

  test("none: rows around a night that miss its dark span", () {
    final s = WeatherSnapshot(
      provider: 'open-meteo',
      model: 'best_match',
      fetchedAtUtc: DateTime.utc(2026, 12, 16, 9),
      latitude: _lat,
      longitude: _lon,
      hours: [
        WeatherHour(timeUtc: DateTime.utc(2026, 12, 16, 12), cloudCoverPct: 10),
        WeatherHour(timeUtc: DateTime.utc(2026, 12, 18, 12), cloudCoverPct: 10),
      ],
    );
    final o = ForecastOverview.of(
      s,
      nights.take(1).toList(),
      dewMarginC: 2,
      timeContext: _zone,
    );
    expect(o.nights.single.coverage, ForecastCoverage.none);
    expect(o.nights.single.summary.cloudCover, isNull, reason: 'never 0 %');
  });

  test('no dark time: a summer night at 60° N has no −18° darkness', () {
    final june = VisibilityCalculator.calculateNightTimelineForNight(
      SessionNightResolver.forEveningDate(
        CalendarDate(2026, 6, 20),
        latitude: 60,
        longitude: _lon,
        timeContext: _zone,
      ),
      darknessLimitDeg: -18,
    );
    final s = _rows(DateTime.utc(2026, 6, 20), DateTime.utc(2026, 6, 22));
    final n = ForecastOverview.of(
      s,
      [june],
      dewMarginC: 2,
      timeContext: _zone,
    ).nights.single;
    expect(n.coverage, ForecastCoverage.noDark);
    expect(n.summary.slots, isEmpty);
  });

  test('a DST night (25 Oct 2026, clocks back) keeps its UTC instants', () {
    final night = _timeline(CalendarDate(2026, 10, 24));
    final span = NightWeatherSummarizer.spanOf(night);
    final s = _rows(
      DateTime.utc(2026, 10, 24, 12),
      DateTime.utc(2026, 10, 25, 12),
    );
    final n = ForecastOverview.of(
      s,
      [night],
      dewMarginC: 2,
      timeContext: _zone,
    ).nights.single;
    final firstInstant = DateTime.utc(
      span.fromUtc.year,
      span.fromUtc.month,
      span.fromUtc.day,
      span.fromUtc.hour + 1,
    );
    final expected =
        span.toUtc.difference(firstInstant).inHours + 1; // whole UTC hours
    expect(n.summary.totalHours, expected);
    expect(n.coverage, ForecastCoverage.complete);
  });

  test('an empty snapshot serves no night', () {
    final s = WeatherSnapshot(
      provider: 'open-meteo',
      model: 'best_match',
      fetchedAtUtc: DateTime.utc(2026, 12, 16, 9),
      latitude: _lat,
      longitude: _lon,
      hours: const [],
    );
    final o = ForecastOverview.of(
      s,
      nights,
      dewMarginC: 2,
      timeContext: MeanSolarTimeContext(_lon),
    );
    expect(o.nights, isEmpty);
    expect(o.firstBeyond, d0);
  });
}
