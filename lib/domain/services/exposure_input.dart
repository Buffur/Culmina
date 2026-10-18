import '../models/capture_block.dart';

/// A sub-exposure as typed (ADR-021 C14; AM-04): positive decimal seconds
/// ("0.5", "60") or a familiar fraction ("1/14", "1 / 250 s"), stored as
/// canonical seconds within [CaptureBlock]'s bounds. The text itself is
/// never stored.
abstract final class ExposureInput {
  static final _fraction = RegExp(r'^(\d+)\s*/\s*(\d+)$');

  /// Canonical seconds, or null when [text] is not a positive exposure: a
  /// zero denominator, a zero or negative value, a non-number, or one above
  /// [CaptureBlock.maxExposureSeconds].
  static double? parse(String text) {
    var t = text.trim();
    if (t.endsWith('s')) t = t.substring(0, t.length - 1).trimRight();
    final double? seconds;
    if (_fraction.firstMatch(t) case final m?) {
      final numerator = int.parse(m.group(1)!);
      final denominator = int.parse(m.group(2)!);
      seconds = denominator == 0 ? null : numerator / denominator;
    } else {
      seconds = double.tryParse(t);
    }
    if (seconds == null || !seconds.isFinite || seconds <= 0) return null;
    if (seconds > CaptureBlock.maxExposureSeconds) return null;
    return seconds;
  }

  /// Why [text] is not an exposure, or null when it is.
  static String? problem(String text) {
    if (parse(text) != null) return null;
    final t = text.trim();
    if (_fraction.firstMatch(t.replaceFirst(RegExp(r's$'), '').trim())
        case final m? when int.parse(m.group(2)!) == 0) {
      return 'A fraction needs a denominator above 0';
    }
    final v = double.tryParse(t);
    if (v != null && v > CaptureBlock.maxExposureSeconds) {
      return 'At most ${CaptureBlock.maxExposureSeconds.round()} s';
    }
    return 'Enter seconds, e.g. 60, 0.5 or 1/14';
  }

  /// [seconds] as the field shows it: "1/14" for an exact reciprocal of a
  /// whole number below 1 s, otherwise decimal seconds without a trailing
  /// ".0". Parsing the result gives [seconds] back.
  static String format(double seconds) {
    if (seconds > 0 && seconds < 1) {
      final denominator = (1 / seconds).round();
      if (denominator >= 2 && 1 / denominator == seconds) {
        return '1/$denominator';
      }
    }
    return seconds == seconds.roundToDouble()
        ? seconds.toInt().toString()
        : seconds.toString();
  }
}
