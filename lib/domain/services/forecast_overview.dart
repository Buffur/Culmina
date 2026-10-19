import '../models/calendar_date.dart';
import '../models/night_timeline.dart';
import '../models/night_weather_summary.dart';
import '../models/session_night.dart';
import '../models/site_time_context.dart';
import '../models/weather_snapshot.dart';
import 'night_weather_summarizer.dart';

/// How much of a night's dark span one forecast covers (ADR-022 N7).
enum ForecastCoverage {
  /// Every instant of the dark span has a row.
  complete,

  /// Some instants have rows, some not: the forecast starts after the span
  /// begins, ends before it ends, or has gaps.
  partial,

  /// The forecast has no row for the span.
  none,

  /// No dark time at the limit (N6): nothing to cover.
  noDark,
}

/// One night of a multi-night forecast (F14): its dark-span summary, its
/// coverage and the forecast's lead time (N9). Facts only, no score.
class ForecastNight {
  const ForecastNight({
    required this.night,
    required this.summary,
    required this.leadDays,
    required this.missingBefore,
    required this.missingAfter,
  });

  final SessionNight night;
  final NightWeatherSummary summary;

  /// The night's evening date − the site-local date of the fetch, in whole
  /// days (N9; 0 = made on the day). Not a reliability score.
  final int leadDays;

  /// Instants of the span before the forecast's first row (past hours).
  final int missingBefore;

  /// Instants of the span after the forecast's last row (its horizon).
  final int missingAfter;

  CalendarDate get eveningDate => night.eveningDate;

  ForecastCoverage get coverage => summary.span == NightWeatherSpan.noDark
      ? ForecastCoverage.noDark
      : summary.complete
      ? ForecastCoverage.complete
      : summary.coveredHours == 0
      ? ForecastCoverage.none
      : ForecastCoverage.partial;

  /// Missing instants inside the forecast's range (absent rows).
  int get gaps =>
      summary.totalHours - summary.coveredHours - missingBefore - missingAfter;
}

/// The nights one forecast serves (ADR-022 N6/N7/N9; F14 A1). Pure: UTC in,
/// typed coverage out. A response of up to 16 days is never 16 complete
/// nights: each night's dark span is sliced on its own, and its coverage
/// says what is there.
abstract final class ForecastOverview {
  /// The site-local date of [utc] (N9), read through the site's civil time
  /// rule (never the device's).
  static CalendarDate localDate(DateTime utc, SiteTimeContext context) =>
      CalendarDate.fromDateTimeFields(utc.toUtc().add(context.offsetAt(utc)));

  /// Whole days from [from] to [to].
  static int daysBetween(CalendarDate from, CalendarDate to) =>
      to.atUtcHour(12).difference(from.atUtcHour(12)).inHours ~/ 24;

  /// One [ForecastNight] per timeline, in their order, up to the last night
  /// whose span starts at or before the forecast's last row; later nights
  /// are left out (the caller says "beyond the forecast" from
  /// [firstBeyond]).
  static ({List<ForecastNight> nights, CalendarDate? firstBeyond}) of(
    WeatherSnapshot snapshot,
    List<NightTimeline> timelines, {
    required double dewMarginC,
    required SiteTimeContext timeContext,
  }) {
    final hours = [for (final h in snapshot.hours) h.timeUtc.toUtc()]..sort();
    final first = hours.isEmpty ? null : hours.first;
    final last = hours.isEmpty ? null : hours.last;
    final fetched = localDate(snapshot.fetchedAtUtc, timeContext);
    final nights = <ForecastNight>[];
    for (final timeline in timelines) {
      final span = NightWeatherSummarizer.spanOf(timeline);
      if (last == null || span.fromUtc.isAfter(last)) {
        return (nights: nights, firstBeyond: timeline.night.eveningDate);
      }
      final summary = NightWeatherSummarizer.summarize(
        snapshot,
        fromUtc: span.fromUtc,
        toUtc: span.toUtc,
        dewMarginC: dewMarginC,
        span: span.span,
      );
      final missing = [
        for (final s in summary.slots)
          if (s.instant && s.hour == null) s.timeUtc,
      ];
      nights.add(
        ForecastNight(
          night: timeline.night,
          summary: summary,
          leadDays: daysBetween(fetched, timeline.night.eveningDate),
          missingBefore: missing.where((t) => t.isBefore(first!)).length,
          missingAfter: missing.where((t) => t.isAfter(last)).length,
        ),
      );
    }
    return (nights: nights, firstBeyond: null);
  }
}
