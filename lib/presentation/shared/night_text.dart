import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
import '../../core/units/display_units.dart';
import '../../core/utils/quantity_text.dart';

import '../../domain/models/moon_conditions.dart';
import '../../domain/models/night_weather.dart';
import '../../domain/models/night_timeline.dart';
import '../../domain/models/night_weather_summary.dart';
import '../../domain/models/weather_snapshot.dart';
import '../../domain/services/fit_analyzer.dart';
import '../../domain/services/night_view.dart';

/// Wording shared by Tonight and the planner (TASK 12.5; moved out of the
/// weather, sky and budget widgets so both say the same thing). Formatting
/// only — every value comes from the domain.
abstract final class WeatherText {
  /// "just now", "25 min ago", "3 h ago".
  static String ago(Duration d) {
    if (d.inMinutes < 1) return 'just now';
    if (d.inMinutes < 60) return '${d.inMinutes} min ago';
    return '${d.inHours} h ago';
  }

  /// "Updated 25 min ago", or the aging/stale wording (ADR-012 §6).
  static String freshness(NightWeatherAvailable state) {
    final ago = WeatherText.ago(state.ageDuration);
    return switch (state.age) {
      WeatherAge.current => 'Updated $ago',
      WeatherAge.aging => 'Aging forecast: updated $ago',
      WeatherAge.stale => 'Stale forecast: updated $ago. Refresh to update.',
    };
  }

  /// "10–40 %", "20 %", or "no forecast" — never 0 for unknown (SI-008).
  static String range(WeatherRange? r, String unit, {int digits = 0}) {
    if (r == null) return 'no forecast';
    final lo = r.min.toStringAsFixed(digits);
    final hi = r.max.toStringAsFixed(digits);
    return lo == hi ? '$lo $unit' : '$lo–$hi $unit';
  }

  /// F21: an absolute temperature range in the chosen unit.
  static String temperatureRange(WeatherRange? r, DisplayUnits u) => range(
    r == null
        ? null
        : WeatherRange(u.temperatureOf(r.min), u.temperatureOf(r.max)),
    u.temperature.symbol,
  );

  /// F21: a wind-speed range (stored in km/h) in the chosen unit.
  static String windRange(WeatherRange? r, DisplayUnits u) => range(
    r == null ? null : WeatherRange(u.windOf(r.min), u.windOf(r.max)),
    u.wind.symbol,
  );

  static String failure(WeatherFailure failure) => switch (failure) {
    WeatherFailure.unavailable => 'Offline or the service did not answer.',
    WeatherFailure.malformed => 'The forecast could not be read.',
    WeatherFailure.outOfRange => 'Beyond the 16-day forecast.',
  };

  /// The same words wherever the forecast loads or is out of range.
  static const loading = 'Loading the forecast…';
  static const outOfRange =
      'No forecast yet: the forecast covers only the next 16 days. '
      'Planning works without weather.';

  /// The span the night's weather covers (ADR-022 N6): the dark span at
  /// [limitDeg], or why there is none; [at] formats an instant.
  static String span(
    NightWeatherSummary s,
    double limitDeg,
    String Function(DateTime utc) at,
  ) {
    final sun = 'Sun below ${QuantityText.degrees(limitDeg)}';
    return switch (s.span) {
      NightWeatherSpan.dark => 'Dark ($sun): ${at(s.fromUtc)} – ${at(s.toUtc)}',
      NightWeatherSpan.polarNight =>
        'Dark ($sun) for the whole 24 h window: ${at(s.fromUtc)} – '
            '${at(s.toUtc)}',
      NightWeatherSpan.noDark =>
        'No dark time this night ($sun never); no hours are summarized.',
    };
  }

  /// What of the dark span the forecast has (N7, W2): null when every
  /// instant has every value. Never a zero for a missing value.
  static String? coverage(NightWeatherSummary s) {
    if (s.span == NightWeatherSpan.noDark) return null;
    if (s.totalHours == 0) return 'The dark span holds no whole hour.';
    if (s.coveredHours == 0) return 'No forecast for these hours.';
    final gaps = s.cloudGapHours - (s.totalHours - s.coveredHours);
    final parts = [
      if (!s.complete)
        'Forecast for ${s.coveredHours} of ${s.totalHours} dark hours; the '
            'rest have no forecast',
      if (gaps > 0) 'Cloud: $gaps h without forecast',
    ];
    return parts.isEmpty ? null : parts.join('. ');
  }

  /// The forecast's lead time (N9, W3), never a reliability score.
  static String lead(int days) => switch (days) {
    < 0 => 'Forecast made during this night',
    0 => 'Forecast made on the day',
    1 => 'Forecast made 1 day ahead',
    _ => 'Forecast made $days days ahead',
  };

  /// The dew heuristic over the dark span (N6): about N h.
  /// The margin is a temperature difference (F21 A3: 2 °C reads 3.6 °F).
  static String dew(
    NightWeatherSummary s, [
    DisplayUnits units = DisplayUnits.metric,
  ]) {
    final margin = QuantityText.temperatureDifference(s.dewMarginC, units);
    if (s.dewKnownHours == 0) {
      return 'Dew risk: unknown (no temperature or dew point).';
    }
    if (s.dewRiskHours == 0) {
      return 'Dew risk (heuristic): none of ${s.dewKnownHours} dark hours has '
          'a temperature − dew point spread at or below $margin.';
    }
    return 'Dew risk (heuristic): about ${s.dewRiskHours} h of '
        '${s.dewKnownHours} dark hours with a temperature − dew point spread '
        'at or below $margin (the margin in Settings).';
  }

  /// Q3 (PD-18; F14 A5): the limitation, said where the forecast is.
  static const notSeeing =
      'Seeing and transparency are not forecast here. Visibility is '
      'horizontal visibility near the ground, not transparency.';

  /// One line for a summary row (S6.5): the night's cloud range with the
  /// forecast's age (and its aging or stale wording), or why there is no
  /// forecast. Never a score or a good/bad word (ADR-012).
  static String summary(NightWeather state, NightWeatherSummary? s) =>
      switch (state) {
        NightWeatherIdle() => 'Set a site to see the forecast.',
        NightWeatherLoading() => loading,
        NightWeatherOutOfRange() => outOfRange,
        NightWeatherUnavailable(:final failure) =>
          'No forecast. ${WeatherText.failure(failure)}',
        NightWeatherAvailable() =>
          'Cloud ${range(s?.cloudCover, '%')} · ${freshness(state)}',
      };
}

/// The dark span at the user's darkness limit (S6.5, TD-051): the Sun below
/// the limit the imaging opportunity uses, labelled with it.
abstract final class DarkText {
  /// "Dark (Sun below −15°): 6:02 PM – 5:40 AM (+1)", or "…: not tonight",
  /// "…: all night"; [at] formats an instant.
  static String span(SunThresholdResult r, String Function(DateTime utc) at) {
    final label = 'Dark (Sun below ${QuantityText.degrees(r.thresholdDeg)})';
    return switch (r) {
      SunCrossing(:final duskUtc, :final dawnUtc) =>
        '$label: ${duskUtc == null ? 'from the start' : at(duskUtc)} – '
            '${dawnUtc == null ? 'the end' : at(dawnUtc)}',
      SunNeverBelow() => '$label: not tonight',
      SunAlwaysBelow() => '$label: all night',
    };
  }
}

abstract final class MoonText {
  /// When the Moon is up this night; [at] formats an instant.
  static String up(MoonConditions c, String Function(DateTime utc) at) {
    if (c.riseSet.alwaysAbove) return 'Moon up all night.';
    if (c.riseSet.alwaysBelow) return 'Moon below the horizon all night.';
    final spans = c.upIntervals.map(
      (i) =>
          '${i.$1 == c.night.startUtc ? 'from noon' : at(i.$1)}–'
          '${i.$2 == c.night.endUtc ? 'noon' : at(i.$2)}',
    );
    return 'Moon up ${spans.join(', ')}.';
  }

  /// ADR-022 N5: the night's phase name.
  static String phaseName(MoonPhaseName p) => switch (p) {
    MoonPhaseName.newMoon => 'New Moon',
    MoonPhaseName.waxingCrescent => 'Waxing crescent',
    MoonPhaseName.firstQuarter => 'First quarter',
    MoonPhaseName.waxingGibbous => 'Waxing gibbous',
    MoonPhaseName.full => 'Full Moon',
    MoonPhaseName.waningGibbous => 'Waning gibbous',
    MoonPhaseName.lastQuarter => 'Last quarter',
    MoonPhaseName.waningCrescent => 'Waning crescent',
  };

  /// ADR-022 N4: when the dark time is moon-free, as intervals and a total,
  /// with [at] formatting an instant in the night's zone. "No dark time" is a
  /// known absence, never missing data.
  static String moonFree(MoonFreeNight m, String Function(DateTime) at) {
    String spans() =>
        m.intervals.map((i) => '${at(i.$1)}–${at(i.$2)}').join(', ');
    final total = QuantityText.duration(m.moonFree);
    return switch (m.kind) {
      MoonFreeKind.noDark => 'No dark time this night, so no moon-free time.',
      MoonFreeKind.none =>
        'No moon-free dark time: the Moon is up all the '
            '${QuantityText.duration(m.dark)} dark.',
      MoonFreeKind.allNight =>
        'Moon-free all the dark time: ${spans()} '
            '($total).',
      MoonFreeKind.evening => 'Moon-free in the evening: ${spans()} ($total).',
      MoonFreeKind.morning => 'Moon-free in the morning: ${spans()} ($total).',
      MoonFreeKind.middle =>
        'Moon-free in the middle of the night: '
            '${spans()} ($total).',
      MoonFreeKind.mixed => 'Moon-free: ${spans()} ($total in all).',
    };
  }

  /// The useful fact for Tonight (S6.13; UX-17), worded as the imaging
  /// windows' Moon note: "Moon down while dark (3 % lit at midnight)",
  /// "Moon up all the dark time (…)", or "Moon up 2 h of the 7 h 30 min
  /// dark (…)". Null means there is no dark span to speak of.
  static String duringDark(MoonDuringDark m) {
    final lit = '${QuantityText.percent(m.illumination * 100)} lit at midnight';
    if (m.moonDown) return 'Moon down while dark ($lit)';
    if (m.upAllDark) return 'Moon up all the dark time ($lit)';
    return 'Moon up ${QuantityText.duration(m.moonUp)} of the '
        '${QuantityText.duration(m.dark)} dark ($lit)';
  }
}

abstract final class FitText {
  static String label(FitState state) => switch (state) {
    FitState.fits => 'Fits',
    FitState.tight => 'Tight',
    FitState.doesNotFit => "Doesn't fit",
    FitState.noWindow || FitState.needsInput => 'No window',
    FitState.nothingToFit => 'Nothing to fit',
  };

  /// A real verdict in its colour; a missing input neutral (S1.9; UX-16,
  /// UX-15(2)): "Tight" is a caution at least as prominent as "Fits". Since
  /// S5.4 the colours are the palette's status tokens (the same values as
  /// before: `scheme.primary`, `caution`, `scheme.error`, the secondary
  /// text); [scheme] is kept for the callers.
  static Color color(FitState state, ColorScheme scheme, AppPalette palette) =>
      switch (state) {
        FitState.fits => palette.statusFits,
        FitState.tight => palette.statusTight,
        FitState.doesNotFit => palette.statusDoesNotFit,
        FitState.noWindow => palette.statusNoWindow,
        FitState.nothingToFit || FitState.needsInput => palette.statusNeutral,
      };
}

/// Wording for browsing nights (F15; ADR-022 N11): the viewed versus the
/// plan's night, the sky states of the shared bar, and the time slider's
/// readout. Facts only.
abstract final class NightBrowseText {
  /// "Viewing Thu, Dec 17 · Your plan: Tue, Dec 15" (N11).
  static String viewing(String viewed, String plan) =>
      'Viewing $viewed · Your plan: $plan';

  static String sky(SkyState s, double limitDeg) => switch (s) {
    SkyState.daylight => 'Daylight',
    SkyState.civil => 'Civil twilight',
    SkyState.nautical => 'Nautical twilight',
    SkyState.astronomical => 'Astronomical twilight',
    SkyState.dark => 'Dark (Sun below ${QuantityText.degrees(limitDeg)})',
  };

  /// The slider's readout (A5): the sky, the Moon, and the dark interval's
  /// end — time until darkness, or time left in it, kept apart.
  static String cursor(
    NightInstant i,
    double limitDeg,
    String Function(DateTime utc) at,
  ) {
    final moon = i.moonUp ? 'Moon above the horizon' : 'Moon below the horizon';
    final change = i.darkChangeUtc;
    final dark = switch ((i.dark, change)) {
      (true, final c?) =>
        'dark for another ${QuantityText.duration(c.difference(i.instantUtc))} '
            '(until ${at(c)})',
      (true, null) => 'dark until the night ends',
      (false, final c?) =>
        'darkness in ${QuantityText.duration(c.difference(i.instantUtc))} '
            '(from ${at(c)})',
      (false, null) => 'no more dark time this night',
    };
    final moonChange = switch (i.moonChangeUtc) {
      final c? => '; the Moon ${i.moonUp ? 'sets' : 'rises'} at ${at(c)}',
      null => '',
    };
    return '${sky(i.sky, limitDeg)} · $moon · $dark$moonChange';
  }

  /// The shared bar's text alternative: each run with its times.
  static String bar(
    List<NightSegment> segments,
    double limitDeg,
    String Function(DateTime utc) at,
  ) => [
    for (final g in segments)
      '${sky(g.sky, limitDeg)}${g.moonUp ? ', Moon up' : ''} '
          '${at(g.startUtc)}–${at(g.endUtc)}',
  ].join('; ');
}
