import '../units/display_units.dart';

/// One written form for each quantity the app shows (S1.7; audit ENG-06,
/// UX-19), shared by the domain's reason texts and the presentation, so the
/// same value reads the same everywhere. Formatting only.
abstract final class QuantityText {
  /// Capture budgets keep whole seconds ("1 h 48 min 20 s"), including
  /// sub-second values at three significant figures. Night/calendar durations
  /// continue to use [duration]'s intentional minute rounding.
  static String budgetDuration(Duration d) {
    if (d.isNegative) return '−${budgetDuration(-d)}';
    final seconds = d.inMicroseconds / Duration.microsecondsPerSecond;
    if (seconds > 0 && seconds < 1) {
      return '${number(double.parse(seconds.toStringAsPrecision(3)))} s';
    }
    final total = seconds.round();
    final hours = total ~/ 3600;
    final minutes = total % 3600 ~/ 60;
    final remainder = total % 60;
    return [
      if (hours > 0) '$hours h',
      if (minutes > 0) '$minutes min',
      if (remainder > 0 || (hours == 0 && minutes == 0)) '$remainder s',
    ].join(' ');
  }

  /// A duration rounded to the nearest minute: "5 h 35 min", "45 min",
  /// "3 h", "0 min"; under a minute (but not zero) in seconds: "30 s".
  /// A negative duration gets a minus sign.
  static String duration(Duration d) {
    if (d.isNegative) return '−${duration(-d)}';
    if (d > Duration.zero && d < const Duration(minutes: 1)) {
      final s = (d.inMilliseconds / 1000).round();
      return s == 60 ? '1 min' : '${s < 1 ? 1 : s} s';
    }
    final minutes = (d.inMilliseconds / 60000).round();
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '$m min';
    return m == 0 ? '$h h' : '$h h $m min';
  }

  /// Exposure: "60 s", "2.5 s", "1/50 s". Sub-second values within 0.5%
  /// of an integer reciprocal use that fraction; non-exact equivalents
  /// carry an approximation sign. This is display rounding only: metadata,
  /// raw rationals and calculations retain the original value. A 1e-12
  /// relative tolerance ignores floating-point division noise.
  static String exposure(double seconds) {
    if (seconds > 0 && seconds < 1) {
      final reciprocal = 1 / seconds;
      if (reciprocal.isFinite) {
        final denominator = reciprocal.round();
        final relativeDifference = (seconds * denominator - 1).abs();
        if (denominator >= 2 && relativeDifference <= 0.005) {
          final approximation = relativeDifference <= 1e-12 ? '' : '≈';
          return '${approximation}1/$denominator s';
        }
      }
    }
    return '${number(seconds)} s';
  }

  /// Degrees with the typographic minus (U+2212): "−18°", "46.050°".
  static String degrees(double value, {int digits = 0}) =>
      '${signed(value, digits: digits)}°';

  /// [value] to [digits] decimals with the typographic minus (U+2212):
  /// "−3.0"; never "−0".
  static String signed(double value, {int digits = 0}) {
    final text = value.abs().toStringAsFixed(digits);
    final zero = double.parse(text) == 0;
    return '${value < 0 && !zero ? '−' : ''}$text';
  }

  /// A percentage with a space before the sign: "3 %".
  static String percent(num value) => '${value.round()} %';

  /// A range of percentages, rounded: "10–40 %", or "20 %" when both ends
  /// round alike.
  static String percentRange(num lo, num hi) =>
      lo.round() == hi.round() ? percent(lo) : '${lo.round()}–${hi.round()} %';

  /// [value] without a trailing ".0": "60", "2.5", "0.25".
  static String number(double value) =>
      value == value.roundToDouble() ? '${value.round()}' : '$value';

  /// A storage size in decimal units (ADR-021, F07: 1 MB = 10⁶ bytes,
  /// 1 GB = 10⁹ bytes), two decimals: "25.17 MB", "12.00 GB".
  static String storage(double bytes) => bytes >= 1e9
      ? '${(bytes / 1e9).toStringAsFixed(2)} GB'
      : '${(bytes / 1e6).toStringAsFixed(2)} MB';

  /// F21: an absolute temperature [celsius] in [units]: "−3 °C", "27 °F".
  static String temperature(
    double celsius,
    DisplayUnits units, {
    int digits = 0,
  }) =>
      '${signed(units.temperatureOf(celsius), digits: digits)} '
      '${units.temperature.symbol}';

  /// F21: a recorded temperature [celsius] as written ("-10 °C",
  /// "14 °F"), converted values to one decimal at most.
  static String temperatureAsRecorded(double celsius, DisplayUnits units) =>
      '${number(units.temperature == TemperatureUnit.celsius ? celsius : double.parse(units.temperatureOf(celsius).toStringAsFixed(1)))} '
      '${units.temperature.symbol}';

  /// F21: a temperature difference [celsius] (a dew margin) in [units]:
  /// 2 °C reads "3.6 °F", never "35.6 °F".
  static String temperatureDifference(
    double celsius,
    DisplayUnits units, {
    int digits = 1,
  }) =>
      '${signed(units.temperatureDifferenceOf(celsius), digits: digits)} '
      '${units.temperature.symbol}';

  /// F21: a wind speed [kmh] in [units]: "12 km/h", "7 mph", "3 m/s".
  static String wind(double kmh, DisplayUnits units, {int digits = 0}) =>
      '${signed(units.windOf(kmh), digits: digits)} ${units.wind.symbol}';

  /// F21: an elevation [metres] in [units], whole: "300 m", "984 ft".
  static String elevation(double metres, DisplayUnits units) =>
      '${signed(units.elevationOf(metres))} ${units.elevation.symbol}';
}
