import 'package:flutter/material.dart';

/// Semantic presentation roles absent from AppPalette.
/// Dark adopts AFTER-DARK-1.2; Light and Field retain their source palettes.
/// These colors never supply astronomical intervals or change data meaning.
@immutable
class HybridTokens extends ThemeExtension<HybridTokens> {
  const HybridTokens({
    required this.action,
    required this.onAction,
    required this.selection,
    required this.selectedHourFill,
    required this.selectedHourText,
    required this.selectedHourRule,
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
    required this.weatherNotice,
  });

  static const sourceRevision = 'AFTER-DARK-1.2';
  static const fontFamily = 'Geist';
  static const transparent = Color(0x00000000);
  // Exact compact roles in the approved source. Large text uses full week rows.
  static const calendarCaptionSize = 10.0;
  static const navigationLabelSize = 11.0;

  /// Chart tick labels (plan.css `.gain-graph text`, 11 px).
  static const chartLabelSize = 11.0;
  static const minTarget = 48.0;
  static const appBarHeight = 56.0;

  /// Primary action fill (WQA-01: Field `#FF0000` with black text).
  final Color action;

  /// Text on [action].
  final Color onAction;

  /// Selected rows, segments and pressed fills.
  final Color selection;

  /// Weather B hour-axis selection fill (weather-radix.css blue5).
  final Color selectedHourFill;

  /// Text on [selectedHourFill] (blue12; Field retains primary red).
  final Color selectedHourText;

  /// Bottom rule of the selected Weather B hour (blue11).
  final Color selectedHourRule;

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

  /// Timeline dark interval; a semantic fill, not a quality score.
  final Color skyDark;

  /// Moon-above-horizon lane.
  final Color moonUp;

  /// Moon-free dark lane.
  final Color moonFree;

  /// Weather caution (dew, stale).
  final Color weatherCaution;

  /// The Weather page's freshness and gap notices (conditions.css
  /// `--wx-caution`).
  final Color weatherNotice;

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
    selectedHourFill: Color(0xFFC2E5FF),
    selectedHourText: Color(0xFF113264),
    selectedHourRule: Color(0xFF0D74CE),
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
    weatherNotice: Color(0xFF9A5B00),
  );

  static const dark = HybridTokens(
    action: Color(0xFF2783DE),
    onAction: Color(0xFF101010),
    selection: Color(0xFF262626),
    selectedHourFill: Color(0xFF313B49),
    selectedHourText: Color(0xFFD8E7FF),
    selectedHourRule: Color(0xFF75B6FF),
    surfaceSubtle: Color(0xFF262626),
    surfaceSunken: Color(0xFF1A1A1A),
    accent: Color(0xFF2783DE),
    success: Color(0xFF8EC7A7),
    successWash: Color(0xFF27382F),
    caution: Color(0xFFE6C17A),
    cautionWash: Color(0xFF3B3326),
    errorText: Color(0xFFF39B95),
    errorWash: Color(0xFF402D2C),
    hourBackground: Color(0xFF262626),
    hourText: Color(0xFFC4C1BC),
    gainStart: Color(0xFF90B7CB),
    gainEnd: Color(0xFFB5D6B6),
    skyDay: Color(0xFF77705E),
    skyCivil: Color(0xFF66576D),
    skyNautical: Color(0xFF4E4B70),
    skyAstronomical: Color(0xFF393E58),
    skyDark: Color(0xFF262D3C),
    moonUp: Color(0xFFD5C8AD),
    moonFree: Color(0xFF86BAD0),
    weatherCaution: Color(0xFFE6C17A),
    weatherNotice: Color(0xFFA9C3DA),
  );

  static const field = HybridTokens(
    action: Color(0xFFFF0000),
    onAction: Color(0xFF000000),
    selection: Color(0xFF330000),
    selectedHourFill: Color(0xFF330000),
    selectedHourText: Color(0xFFFF0000),
    selectedHourRule: Color(0xFFFF0000),
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
    weatherNotice: Color(0xFFFF0000),
  );

  @override
  HybridTokens copyWith({
    Color? action,
    Color? onAction,
    Color? selection,
    Color? selectedHourFill,
    Color? selectedHourText,
    Color? selectedHourRule,
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
    Color? weatherNotice,
  }) => HybridTokens(
    action: action ?? this.action,
    onAction: onAction ?? this.onAction,
    selection: selection ?? this.selection,
    selectedHourFill: selectedHourFill ?? this.selectedHourFill,
    selectedHourText: selectedHourText ?? this.selectedHourText,
    selectedHourRule: selectedHourRule ?? this.selectedHourRule,
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
    weatherNotice: weatherNotice ?? this.weatherNotice,
  );

  @override
  HybridTokens lerp(covariant HybridTokens? other, double t) {
    if (other == null) return this;
    return HybridTokens(
      action: Color.lerp(action, other.action, t)!,
      onAction: Color.lerp(onAction, other.onAction, t)!,
      selection: Color.lerp(selection, other.selection, t)!,
      selectedHourFill: Color.lerp(
        selectedHourFill,
        other.selectedHourFill,
        t,
      )!,
      selectedHourText: Color.lerp(
        selectedHourText,
        other.selectedHourText,
        t,
      )!,
      selectedHourRule: Color.lerp(
        selectedHourRule,
        other.selectedHourRule,
        t,
      )!,
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
      weatherNotice: Color.lerp(weatherNotice, other.weatherNotice, t)!,
    );
  }
}
