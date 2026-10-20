import 'package:flutter/material.dart';

/// Approved original Hybrid presentation roles absent from AppPalette.
/// JSON: design/home-lab/tokens.json; chart colors: night.css:72–78.
/// These colors do not supply astronomical intervals or change data semantics.
@immutable
class HybridTokens extends ThemeExtension<HybridTokens> {
  const HybridTokens({
    required this.action,
    required this.onAction,
    required this.selection,
    required this.skyDay,
    required this.skyCivil,
    required this.skyNautical,
    required this.skyAstronomical,
    required this.skyDark,
    required this.moonUp,
    required this.moonFree,
    required this.weatherCaution,
  });

  static const sourceRevision = '20261020-hybrid7';
  static const fontFamily = 'Geist';
  static const transparent = Color(0x00000000);
  // Exact compact roles in the approved source. Large text uses full week rows.
  static const calendarCaptionSize = 10.0;
  static const navigationLabelSize = 11.0;
  static const minTarget = 48.0;
  static const appBarHeight = 64.0;
  final Color action;
  final Color onAction;
  final Color selection;
  final Color skyDay;
  final Color skyCivil;
  final Color skyNautical;
  final Color skyAstronomical;
  final Color skyDark;
  final Color moonUp;
  final Color moonFree;
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
    skyDay: Color(0xFFDFE9E9),
    skyCivil: Color(0xFFCECDE0),
    skyNautical: Color(0xFFA5B2CA),
    skyAstronomical: Color(0xFF7585A1),
    skyDark: Color(0xFF475A72),
    moonUp: Color(0xFF607D8B),
    moonFree: Color(0xFF37352F),
    weatherCaution: Color(0xFF9A5B00),
  );

  static const dark = HybridTokens(
    action: Color(0xFFEBEBEA),
    onAction: Color(0xFF191919),
    selection: Color(0xFF343432),
    skyDay: Color(0xFFA0B2B8),
    skyCivil: Color(0xFF9B98B0),
    skyNautical: Color(0xFF778AA9),
    skyAstronomical: Color(0xFF526984),
    skyDark: Color(0xFF2D435D),
    moonUp: Color(0xFFB0BEC5),
    moonFree: Color(0xFFEBEBEA),
    weatherCaution: Color(0xFFFFB74D),
  );

  static const field = HybridTokens(
    action: Color(0xFFAA0000),
    onAction: Color(0xFF000000),
    selection: Color(0xFF330000),
    skyDay: Color(0xFF800000),
    skyCivil: Color(0xFF650000),
    skyNautical: Color(0xFF4D0000),
    skyAstronomical: Color(0xFF340000),
    skyDark: Color(0xFF180000),
    moonUp: Color(0xFFB00000),
    moonFree: Color(0xFFFF0000),
    weatherCaution: Color(0xFFFF0000),
  );

  @override
  HybridTokens copyWith({
    Color? action,
    Color? onAction,
    Color? selection,
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
