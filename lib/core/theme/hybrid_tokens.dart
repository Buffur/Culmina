import 'package:flutter/material.dart';

/// Approved original Hybrid presentation roles absent from AppPalette.
/// Values: the final computed cascade of the accepted web reference
/// (`design/home-lab` at 86873ce: notion-hybrid.css, hybrid-data-tokens.css,
/// hybrid-refinement.css), Light / Dark / Field. These colours do not supply
/// astronomical intervals or change data semantics.
@immutable
class HybridTokens extends ThemeExtension<HybridTokens> {
  const HybridTokens({
    required this.action,
    required this.onAction,
    required this.selection,
    required this.surfaceSubtle,
    required this.surfaceSunken,
    required this.accent,
    required this.success,
    required this.successWash,
    required this.caution,
    required this.cautionWash,
    required this.errorText,
    required this.errorWash,
    required this.hourBackground,
    required this.hourText,
    required this.gainStart,
    required this.gainEnd,
    required this.skyDay,
    required this.skyCivil,
    required this.skyNautical,
    required this.skyAstronomical,
    required this.skyDark,
    required this.moonUp,
    required this.moonFree,
    required this.weatherCaution,
  });

  static const sourceRevision = '86873ce';
  static const fontFamily = 'Geist';
  static const transparent = Color(0x00000000);
  // Exact compact roles in the approved source. Large text uses full week rows.
  static const calendarCaptionSize = 10.0;
  static const navigationLabelSize = 11.0;
  static const minTarget = 48.0;
  static const appBarHeight = 64.0;

  /// Primary action fill (WQA-01: Field `#FF0000` with black text).
  final Color action;

  /// Text on [action].
  final Color onAction;

  /// Selected rows, segments and pressed fills.
  final Color selection;

  /// Subtle surface: selected navigation, quiet panels.
  final Color surfaceSubtle;

  /// Sunken surface behind raised panels.
  final Color surfaceSunken;

  /// Notion blue: weather icons, main chart lines, links.
  final Color accent;

  /// Saved / Completed text.
  final Color success;

  /// Saved / Completed compact background.
  final Color successWash;

  /// Not saved / Saved · changed / Partly / stale text.
  final Color caution;

  /// Caution compact background.
  final Color cautionWash;

  /// Data error text.
  final Color errorText;

  /// Error compact background.
  final Color errorWash;

  /// Selected weather hour fill.
  final Color hourBackground;

  /// Selected weather hour text.
  final Color hourText;

  /// Stacking-gain gradient start.
  final Color gainStart;

  /// Stacking-gain gradient end.
  final Color gainEnd;

  /// Timeline daylight.
  final Color skyDay;

  /// Timeline civil twilight.
  final Color skyCivil;

  /// Timeline nautical twilight.
  final Color skyNautical;

  /// Timeline astronomical twilight.
  final Color skyAstronomical;

  /// Timeline dark time: black in every theme (owner).
  final Color skyDark;

  /// Moon-above-horizon lane.
  final Color moonUp;

  /// Moon-free dark lane.
  final Color moonFree;

  /// Weather caution (dew, stale).
  final Color weatherCaution;

  List<Color> get sky => [
    skyDay,
    skyCivil,
    skyNautical,
    skyAstronomical,
    skyDark,
  ];

  static const light = HybridTokens(
    action: Color(0xFF37352F),
    onAction: Color(0xFFFFFFFF),
    selection: Color(0xFFE9E9E7),
    surfaceSubtle: Color(0xFFF7F7F5),
    surfaceSunken: Color(0xFFF0F0ED),
    accent: Color(0xFF0075DE),
    success: Color(0xFF27633D),
    successWash: Color(0xFFE4EEE7),
    caution: Color(0xFF754600),
    cautionWash: Color(0xFFF4ECDF),
    errorText: Color(0xFFB00020),
    errorWash: Color(0xFFF7E7E9),
    hourBackground: Color(0xFFE6F3FE),
    hourText: Color(0xFF005BAB),
    gainStart: Color(0xFF0075DE),
    gainEnd: Color(0xFF005BAB),
    skyDay: Color(0xFFE6F3FE),
    skyCivil: Color(0xFFA6D2F3),
    skyNautical: Color(0xFF599FD5),
    skyAstronomical: Color(0xFF285B90),
    skyDark: Color(0xFF000000),
    moonUp: Color(0xFF607D8B),
    moonFree: Color(0xFF37352F),
    weatherCaution: Color(0xFF754600),
  );

  static const dark = HybridTokens(
    action: Color(0xFFEBEBEA),
    onAction: Color(0xFF191919),
    selection: Color(0xFF343432),
    surfaceSubtle: Color(0xFF202020),
    surfaceSunken: Color(0xFF141414),
    accent: Color(0xFF62AFF3),
    success: Color(0xFF99C5A6),
    successWash: Color(0xFF2B352E),
    caution: Color(0xFFFFCA70),
    cautionWash: Color(0xFF3B3222),
    errorText: Color(0xFFFF9592),
    errorWash: Color(0xFF3C2929),
    hourBackground: Color(0xFF152D40),
    hourText: Color(0xFFA6D2F3),
    gainStart: Color(0xFF62AFF3),
    gainEnd: Color(0xFFA6D2F3),
    skyDay: Color(0xFFA6D2F3),
    skyCivil: Color(0xFF78B5E5),
    skyNautical: Color(0xFF4388BD),
    skyAstronomical: Color(0xFF244F7A),
    skyDark: Color(0xFF000000),
    moonUp: Color(0xFFB0BEC5),
    moonFree: Color(0xFFEBEBEA),
    weatherCaution: Color(0xFFFFCA70),
  );

  static const field = HybridTokens(
    action: Color(0xFFFF0000),
    onAction: Color(0xFF000000),
    selection: Color(0xFF330000),
    surfaceSubtle: Color(0xFF110000),
    surfaceSunken: Color(0xFF000000),
    accent: Color(0xFFFF0000),
    success: Color(0xFFFF0000),
    successWash: Color(0xFF110000),
    caution: Color(0xFFFF0000),
    cautionWash: Color(0xFF1A0000),
    errorText: Color(0xFFFF0000),
    errorWash: Color(0xFF1A0000),
    hourBackground: Color(0xFF330000),
    hourText: Color(0xFFFF0000),
    gainStart: Color(0xFF990000),
    gainEnd: Color(0xFFFF0000),
    skyDay: Color(0xFF800000),
    skyCivil: Color(0xFF650000),
    skyNautical: Color(0xFF4D0000),
    skyAstronomical: Color(0xFF340000),
    skyDark: Color(0xFF000000),
    moonUp: Color(0xFFB00000),
    moonFree: Color(0xFFFF0000),
    weatherCaution: Color(0xFFFF0000),
  );

  @override
  HybridTokens copyWith({
    Color? action,
    Color? onAction,
    Color? selection,
    Color? surfaceSubtle,
    Color? surfaceSunken,
    Color? accent,
    Color? success,
    Color? successWash,
    Color? caution,
    Color? cautionWash,
    Color? errorText,
    Color? errorWash,
    Color? hourBackground,
    Color? hourText,
    Color? gainStart,
    Color? gainEnd,
    Color? skyDay,
    Color? skyCivil,
    Color? skyNautical,
    Color? skyAstronomical,
    Color? skyDark,
    Color? moonUp,
    Color? moonFree,
    Color? weatherCaution,
  }) => HybridTokens(
    action: action ?? this.action,
    onAction: onAction ?? this.onAction,
    selection: selection ?? this.selection,
    surfaceSubtle: surfaceSubtle ?? this.surfaceSubtle,
    surfaceSunken: surfaceSunken ?? this.surfaceSunken,
    accent: accent ?? this.accent,
    success: success ?? this.success,
    successWash: successWash ?? this.successWash,
    caution: caution ?? this.caution,
    cautionWash: cautionWash ?? this.cautionWash,
    errorText: errorText ?? this.errorText,
    errorWash: errorWash ?? this.errorWash,
    hourBackground: hourBackground ?? this.hourBackground,
    hourText: hourText ?? this.hourText,
    gainStart: gainStart ?? this.gainStart,
    gainEnd: gainEnd ?? this.gainEnd,
    skyDay: skyDay ?? this.skyDay,
    skyCivil: skyCivil ?? this.skyCivil,
    skyNautical: skyNautical ?? this.skyNautical,
    skyAstronomical: skyAstronomical ?? this.skyAstronomical,
    skyDark: skyDark ?? this.skyDark,
    moonUp: moonUp ?? this.moonUp,
    moonFree: moonFree ?? this.moonFree,
    weatherCaution: weatherCaution ?? this.weatherCaution,
  );

  @override
  HybridTokens lerp(covariant HybridTokens? other, double t) {
    if (other == null) return this;
    return HybridTokens(
      action: Color.lerp(action, other.action, t)!,
      onAction: Color.lerp(onAction, other.onAction, t)!,
      selection: Color.lerp(selection, other.selection, t)!,
      surfaceSubtle: Color.lerp(surfaceSubtle, other.surfaceSubtle, t)!,
      surfaceSunken: Color.lerp(surfaceSunken, other.surfaceSunken, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      success: Color.lerp(success, other.success, t)!,
      successWash: Color.lerp(successWash, other.successWash, t)!,
      caution: Color.lerp(caution, other.caution, t)!,
      cautionWash: Color.lerp(cautionWash, other.cautionWash, t)!,
      errorText: Color.lerp(errorText, other.errorText, t)!,
      errorWash: Color.lerp(errorWash, other.errorWash, t)!,
      hourBackground: Color.lerp(hourBackground, other.hourBackground, t)!,
      hourText: Color.lerp(hourText, other.hourText, t)!,
      gainStart: Color.lerp(gainStart, other.gainStart, t)!,
      gainEnd: Color.lerp(gainEnd, other.gainEnd, t)!,
      skyDay: Color.lerp(skyDay, other.skyDay, t)!,
      skyCivil: Color.lerp(skyCivil, other.skyCivil, t)!,
      skyNautical: Color.lerp(skyNautical, other.skyNautical, t)!,
      skyAstronomical: Color.lerp(skyAstronomical, other.skyAstronomical, t)!,
      skyDark: Color.lerp(skyDark, other.skyDark, t)!,
      moonUp: Color.lerp(moonUp, other.moonUp, t)!,
      moonFree: Color.lerp(moonFree, other.moonFree, t)!,
      weatherCaution: Color.lerp(weatherCaution, other.weatherCaution, t)!,
    );
  }
}
