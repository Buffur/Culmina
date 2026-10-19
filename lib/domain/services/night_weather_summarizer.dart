import '../models/night_timeline.dart';
import '../models/night_weather_summary.dart';
import '../models/weather_snapshot.dart';

/// Builds a night's weather summary (ADR-012 §3–§5; TASK 9.4; ADR-022 N6,
/// F14). Pure and deterministic: UTC instants in, UTC instants out.
abstract final class NightWeatherSummarizer {
  static const Duration _hour = Duration(hours: 1);

  /// The span the summary covers (N6): the dark span at the plan's
  /// darkness limit ([NightTimeline.darkAtLimit]; astronomical darkness
  /// when the timeline has no limit), from its dusk to its dawn, a window
  /// edge standing in for one outside the window. With no dark time the
  /// span is [NightWeatherSpan.noDark] and its interval is sunset to
  /// sunrise, for the card's text only.
  static ({DateTime fromUtc, DateTime toUtc, NightWeatherSpan span}) spanOf(
    NightTimeline timeline,
  ) {
    final night = timeline.night;
    final whole = (fromUtc: night.startUtc, toUtc: night.endUtc);
    final dark = timeline.darkAtLimit ?? timeline.astronomicalTwilight;
    switch (dark) {
      case SunAlwaysBelow():
        return (
          fromUtc: whole.fromUtc,
          toUtc: whole.toUtc,
          span: NightWeatherSpan.polarNight,
        );
      case SunCrossing(:final duskUtc, :final dawnUtc):
        final from = duskUtc ?? night.startUtc;
        final to = dawnUtc ?? night.endUtc;
        // Dark at both edges of the window and not in between: the whole
        // window, never one invented interval.
        return to.isAfter(from)
            ? (fromUtc: from, toUtc: to, span: NightWeatherSpan.dark)
            : (
                fromUtc: whole.fromUtc,
                toUtc: whole.toUtc,
                span: NightWeatherSpan.dark,
              );
      case SunNeverBelow():
        final (from, to) = switch (timeline.sunriseSunset) {
          SunCrossing(:final duskUtc, :final dawnUtc)
              when (dawnUtc ?? whole.toUtc).isAfter(duskUtc ?? whole.fromUtc) =>
            (duskUtc ?? whole.fromUtc, dawnUtc ?? whole.toUtc),
          _ => (whole.fromUtc, whole.toUtc),
        };
        return (fromUtc: from, toUtc: to, span: NightWeatherSpan.noDark);
    }
  }

  /// The rows that count for `[fromUtc, toUtc]` (N6), matched to the
  /// snapshot's rows at the same UTC instant ("no forecast" otherwise):
  /// - an instant t in the span carries its instantaneous values;
  /// - the preceding hour (t − 1 h, t] carries precipitation chance and
  ///   gusts when at least 30 min of it is in the span (partial below 60).
  ///
  /// Ranges are over those rows only. A dew spread (temperature − dew point)
  /// at or below [dewMarginC] °C at an instant is a dew risk — a heuristic
  /// (CALC-32), unknown when either value is missing. [NightWeatherSpan.noDark]
  /// gives no rows.
  static NightWeatherSummary summarize(
    WeatherSnapshot snapshot, {
    required DateTime fromUtc,
    required DateTime toUtc,
    required double dewMarginC,
    NightWeatherSpan span = NightWeatherSpan.dark,
  }) {
    final from = fromUtc.toUtc();
    final to = toUtc.toUtc();
    final byTime = {
      for (final h in snapshot.hours)
        h.timeUtc.toUtc().millisecondsSinceEpoch: h,
    };

    int overlapMinutes(DateTime t) {
      final start = t.subtract(_hour).isAfter(from) ? t.subtract(_hour) : from;
      final end = t.isBefore(to) ? t : to;
      return end.isAfter(start) ? end.difference(start).inMinutes : 0;
    }

    final slots = <NightWeatherSlot>[];
    if (span != NightWeatherSpan.noDark) {
      var t = DateTime.utc(from.year, from.month, from.day, from.hour);
      final last = to.add(_hour);
      while (!t.isAfter(last)) {
        final instant = !t.isBefore(from) && !t.isAfter(to);
        final minutes = overlapMinutes(t);
        if (instant || minutes >= 30) {
          final hour = byTime[t.millisecondsSinceEpoch];
          final temp = instant ? hour?.temperatureC : null;
          final dew = instant ? hour?.dewPointC : null;
          final spread = (temp != null && dew != null) ? temp - dew : null;
          slots.add(
            NightWeatherSlot(
              timeUtc: t,
              hour: hour,
              dewSpreadC: spread,
              dewRisk: spread == null ? null : spread <= dewMarginC,
              instant: instant,
              precedingMinutes: minutes,
            ),
          );
        }
        t = t.add(_hour);
      }
    }

    WeatherRange? range(
      double? Function(WeatherHour h) value, {
      bool preceding = false,
    }) {
      double? lo;
      double? hi;
      for (final s in slots) {
        final h = s.hour;
        if (h == null || !(preceding ? s.preceding : s.instant)) continue;
        final v = value(h);
        if (v == null) continue;
        if (lo == null || v < lo) lo = v;
        if (hi == null || v > hi) hi = v;
      }
      return lo == null ? null : WeatherRange(lo, hi!);
    }

    double? lo;
    double? hi;
    for (final s in slots) {
      final v = s.dewSpreadC;
      if (v == null) continue;
      if (lo == null || v < lo) lo = v;
      if (hi == null || v > hi) hi = v;
    }

    return NightWeatherSummary(
      fromUtc: from,
      toUtc: to,
      span: span,
      slots: slots,
      dewMarginC: dewMarginC,
      cloudCover: range((h) => h.cloudCoverPct),
      cloudCoverLow: range((h) => h.cloudCoverLowPct),
      cloudCoverMid: range((h) => h.cloudCoverMidPct),
      cloudCoverHigh: range((h) => h.cloudCoverHighPct),
      precipitationProbability: range(
        (h) => h.precipitationProbabilityPct,
        preceding: true,
      ),
      windSpeed: range((h) => h.windSpeedKmh),
      windGusts: range((h) => h.windGustsKmh, preceding: true),
      temperature: range((h) => h.temperatureC),
      dewPoint: range((h) => h.dewPointC),
      relativeHumidity: range((h) => h.relativeHumidityPct),
      visibility: range((h) => h.visibilityM),
      dewSpread: lo == null ? null : WeatherRange(lo, hi!),
    );
  }
}
