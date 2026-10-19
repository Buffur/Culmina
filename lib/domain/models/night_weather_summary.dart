import 'weather_snapshot.dart';

/// Which part of the `SessionNight` window the weather summary covers
/// (ADR-022 N6, F14; it replaced TASK 9.4's sunset to sunrise).
enum NightWeatherSpan {
  /// The dark span: the Sun at or below the plan's darkness limit, from its
  /// dusk to its dawn (a window edge when it is already or still dark).
  dark,

  /// The Sun stays below the limit for the whole 24 h window (polar
  /// night): the whole window is the dark span, labelled as such.
  polarNight,

  /// No dark time at the limit this night (N6): no hour is summarized.
  /// `fromUtc`/`toUtc` are then sunset to sunrise, for the card's text
  /// only (the whole window under the midnight sun).
  noDark,
}

/// The smallest and largest value of one variable over the covered hours.
class WeatherRange {
  const WeatherRange(this.min, this.max);

  final double min;
  final double max;
}

/// One forecast hour of the night (ADR-022 N6): the row at [timeUtc], or
/// null for "no forecast" (beyond the horizon or missing from the response;
/// ADR-012 §5). Instantaneous variables (cloud, temperature, dew point,
/// humidity, wind, visibility) count when [instant] (the instant lies in the
/// span); preceding-hour variables (precipitation chance, gusts) describe
/// (t − 1 h, t] and count when [preceding] (that hour overlaps the span by
/// at least 30 min). A slot can be one, the other or both.
class NightWeatherSlot {
  const NightWeatherSlot({
    required this.timeUtc,
    required this.hour,
    required this.dewSpreadC,
    required this.dewRisk,
    this.instant = true,
    this.precedingMinutes = 60,
  });

  /// The row's instant, a whole UTC hour.
  final DateTime timeUtc;

  final WeatherHour? hour;

  /// Air temperature − dew point, °C; null when either is unknown or the
  /// instant is outside the span.
  final double? dewSpreadC;

  /// [dewSpreadC] ≤ the configured margin (a heuristic); null when unknown.
  final bool? dewRisk;

  /// Whether [timeUtc] lies in the span: instantaneous values count.
  final bool instant;

  /// Minutes of (t − 1 h, t] inside the span, 0 to 60.
  final int precedingMinutes;

  /// Preceding-hour values count: at least 30 min of their hour is in the
  /// span (N6).
  bool get preceding => precedingMinutes >= 30;

  /// The preceding hour is only partly in the span (shown as partial).
  bool get partial => preceding && precedingMinutes < 60;
}

/// The chosen night's weather as per-hour indicators and per-variable
/// ranges (ADR-012 §3: no score). Built by `NightWeatherSummarizer`.
class NightWeatherSummary {
  const NightWeatherSummary({
    required this.fromUtc,
    required this.toUtc,
    required this.span,
    required this.slots,
    required this.dewMarginC,
    required this.cloudCover,
    required this.cloudCoverLow,
    required this.cloudCoverMid,
    required this.cloudCoverHigh,
    required this.precipitationProbability,
    required this.windSpeed,
    required this.windGusts,
    required this.temperature,
    required this.dewPoint,
    required this.relativeHumidity,
    required this.visibility,
    required this.dewSpread,
  });

  /// The summarised span `[fromUtc, toUtc]`.
  final DateTime fromUtc;
  final DateTime toUtc;
  final NightWeatherSpan span;

  /// Every row that counts for the span (N6), in UTC order; empty for
  /// [NightWeatherSpan.noDark].
  final List<NightWeatherSlot> slots;

  /// The dew margin used, °C (`PlanningPreferences.dewMarginC`).
  final double dewMarginC;

  /// Ranges over the counted rows (instantaneous variables over the
  /// instants, precipitation chance and gusts over the preceding hours);
  /// null when no counted row has a value.
  /// Units: % for cloud, precipitation chance and humidity; km/h for wind
  /// and gusts; °C for temperature, dew point and spread; m for visibility.
  final WeatherRange? cloudCover;
  final WeatherRange? cloudCoverLow;
  final WeatherRange? cloudCoverMid;
  final WeatherRange? cloudCoverHigh;
  final WeatherRange? precipitationProbability;
  final WeatherRange? windSpeed;
  final WeatherRange? windGusts;
  final WeatherRange? temperature;
  final WeatherRange? dewPoint;
  final WeatherRange? relativeHumidity;
  final WeatherRange? visibility;
  final WeatherRange? dewSpread;

  Iterable<NightWeatherSlot> get _instants => slots.where((s) => s.instant);

  /// The span's instants (whole UTC hours in it).
  int get totalHours => _instants.length;

  /// Instants with a forecast row.
  int get coveredHours => _instants.where((s) => s.hour != null).length;

  /// Whether every instant of the span has a row (N7: a complete night).
  bool get complete => totalHours > 0 && coveredHours == totalHours;

  /// Instants without a total cloud value: a gap, never 0 % (W2).
  int get cloudGapHours =>
      _instants.where((s) => s.hour?.cloudCoverPct == null).length;

  /// Instants whose dew spread is known.
  int get dewKnownHours => _instants.where((s) => s.dewRisk != null).length;

  /// Instants at or below the dew margin, each standing for about an hour
  /// (N6; a heuristic, not a prediction of dew on the optics).
  int get dewRiskHours => _instants.where((s) => s.dewRisk == true).length;
}
