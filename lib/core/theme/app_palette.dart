import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Semantic colour tokens that the Material [ColorScheme] has no role for
/// (TASK 12.4): muted text, the night's events, the altitude chart and the
/// Bortle scale. Widgets read them with [AppPalette.of]; `lib/presentation`
/// never names a colour itself (a test enforces it). Field mode's tokens
/// are red or black only.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    this.fieldMode = false,
    this.brightness = Brightness.light,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.surfaceRaised,
    required this.border,
    required this.controlBorder,
    required this.statusFits,
    required this.statusTight,
    required this.statusDoesNotFit,
    required this.statusNoWindow,
    required this.statusNeutral,
    required this.stateUnsaved,
    required this.stateSettled,
    required this.stateQuiet,
    required this.muted,
    required this.caution,
    required this.sunEvent,
    required this.twilightEvent,
    required this.moon,
    required this.selected,
    required this.chartDay,
    required this.chartTwilight,
    required this.chartDark,
    required this.chartWindow,
    required this.chartTarget,
    required this.chartMoon,
    required this.chartMinAltitude,
    required this.chartNow,
    required this.chartNowCentre,
    required this.chartGrid,
    required this.chartLabel,
    required this.swatchBorder,
    required this.bortle,
    required this.onBortle,
  });

  /// Semantic mode metadata retained when a palette is copied or interpolated.
  final bool fieldMode;
  final Brightness brightness;

  /// The text roles (S5.1; `docs/DESIGN_SYSTEM.md`): primary for the
  /// answer and values, secondary for labels and supporting text, tertiary
  /// for captions and metadata. In light and dark each is WCAG AA on the
  /// background, the surface and [surfaceRaised]; disabled is exempt (WCAG
  /// 1.4.3 excludes inactive controls).
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textDisabled;

  /// Dialogs, menus and sheets: one level above the card surface.
  final Color surfaceRaised;

  /// Card and section outlines; dividers (decorative).
  final Color border;

  /// The boundary of a control (S5.2): a text field's underline or
  /// outline, an outlined button. At least 3:1 in light and dark (WCAG
  /// 1.4.11); in field mode brighter than [border] (UX-39).
  final Color controlBorder;

  /// The verdict's colours (S5.4; UX-16): each `FitState` has one. A real
  /// verdict is coloured; a missing input ([statusNeutral]) is not. "Tight"
  /// is a caution at least as prominent as "Fits" (S1.9); in field mode all
  /// are red and the word carries the difference.
  final Color statusFits;
  final Color statusTight;
  final Color statusDoesNotFit;
  final Color statusNoWindow;
  final Color statusNeutral;

  /// The plan-state label's tones (S5.4; ADR-019 §3): unsaved work draws
  /// attention (Not saved, Saved · changed); a settled plan reads as
  /// primary text (Saved, Tracking, Completed); the rest is quiet (Partly,
  /// Not done, Old log). Tones, never verdicts.
  final Color stateUnsaved;
  final Color stateSettled;
  final Color stateQuiet;

  /// Secondary text and icons for empty or unknown states.
  final Color muted;

  /// A caution that is not an error, such as a "Tight" fit (S1.9): at least
  /// as prominent as body text.
  final Color caution;

  /// Sunset/sunrise and astronomical dusk/dawn icons.
  final Color sunEvent;
  final Color twilightEvent;

  /// The Moon icon.
  final Color moon;

  /// The check mark on the selected rig or target.
  final Color selected;

  /// Altitude chart: darkness bands, imaging windows, lines and labels.
  final Color chartDay;
  final Color chartTwilight;
  final Color chartDark;
  final Color chartWindow;
  final Color chartTarget;
  final Color chartMoon;
  final Color chartMinAltitude;
  final Color chartNow;
  final Color chartNowCentre;
  final Color chartGrid;
  final Color chartLabel;

  /// The outline of the chart legend's swatches and of the Bortle badge.
  final Color swatchBorder;

  /// Bortle badge background and text: index 0 is "unknown", 1–9 the class.
  final List<Color> bortle;
  final List<Color> onBortle;

  static AppPalette of(BuildContext context) =>
      Theme.of(context).extension<AppPalette>() ?? light;

  // The accepted web cascade's caution role (notion-hybrid.css, 86873ce).
  static const _lightCaution = Color(0xFF754600); // 8.0:1 on white
  static const _darkCaution = Color(0xFFFFCA70); // 11.7:1 on #191919

  static const light = AppPalette(
    statusFits: AppColors.lightTextPrimary,
    statusTight: _lightCaution,
    statusDoesNotFit: AppColors.lightError,
    statusNoWindow: AppColors.lightError,
    statusNeutral: AppColors.lightTextSecondary,
    stateUnsaved: _lightCaution,
    stateSettled: AppColors.lightTextPrimary,
    stateQuiet: AppColors.lightTextSecondary,
    textPrimary: AppColors.lightTextPrimary,
    textSecondary: AppColors.lightTextSecondary,
    textTertiary: AppColors.lightTextTertiary,
    textDisabled: AppColors.lightTextDisabled,
    surfaceRaised: AppColors.lightSurfaceRaised,
    border: AppColors.lightBorder,
    controlBorder: AppColors.lightControlBorder,
    muted: Colors.grey,
    caution: _lightCaution, // 5.4:1 on white, 5.0:1 on the surface (AA)
    sunEvent: Colors.orange,
    twilightEvent: Colors.indigo,
    moon: Colors.blueGrey,
    selected: Colors.blue,
    chartDay: Color(0xFFB3E5FC), // lightBlue.shade100
    chartTwilight: Color(0xFF7986CB), // indigo.shade300
    chartDark: Colors.black87,
    chartWindow: Color(0x6600C853),
    chartTarget: Colors.amber,
    chartMoon: Color(0xFFB0BEC5), // blueGrey.shade200
    chartMinAltitude: Colors.redAccent,
    chartNow: Colors.redAccent,
    chartNowCentre: Colors.white,
    chartGrid: Colors.white60,
    chartLabel: Colors.white,
    swatchBorder: Color(0xFFBDBDBD), // grey.shade400
    bortle: _bortleColours,
    onBortle: _onBortleColours,
  );

  static const dark = AppPalette(
    brightness: Brightness.dark,
    statusFits: AppColors.darkTextPrimary,
    statusTight: _darkCaution,
    statusDoesNotFit: AppColors.darkError,
    statusNoWindow: AppColors.darkError,
    statusNeutral: AppColors.darkTextSecondary,
    stateUnsaved: _darkCaution,
    stateSettled: AppColors.darkTextPrimary,
    stateQuiet: AppColors.darkTextSecondary,
    textPrimary: AppColors.darkTextPrimary,
    textSecondary: AppColors.darkTextSecondary,
    textTertiary: AppColors.darkTextTertiary,
    textDisabled: AppColors.darkTextDisabled,
    surfaceRaised: AppColors.darkSurfaceRaised,
    border: AppColors.darkBorder,
    controlBorder: AppColors.darkControlBorder,
    muted: Colors.grey,
    caution: _darkCaution,
    sunEvent: Colors.orange,
    twilightEvent: Colors.indigo,
    moon: Colors.blueGrey,
    selected: Colors.blue,
    chartDay: Color(0xFF37474F), // blueGrey.shade800
    chartTwilight: Color(0xFF1A237E), // indigo.shade900
    chartDark: Colors.black,
    chartWindow: Color(0x6600C853),
    chartTarget: Colors.amber,
    chartMoon: Color(0xFFB0BEC5),
    chartMinAltitude: Colors.redAccent,
    chartNow: Colors.redAccent,
    chartNowCentre: Colors.white,
    chartGrid: Colors.white30,
    chartLabel: Colors.white70,
    swatchBorder: Color(0xFFBDBDBD),
    bortle: _bortleColours,
    onBortle: _onBortleColours,
  );

  /// Red on black only: brightness, not hue, tells elements apart.
  static const field = AppPalette(
    fieldMode: true,
    brightness: Brightness.dark,
    statusFits: AppColors.fieldTextPrimary,
    statusTight: AppColors.fieldTextPrimary,
    statusDoesNotFit: AppColors.fieldTextPrimary,
    statusNoWindow: AppColors.fieldTextPrimary,
    statusNeutral: AppColors.fieldTextSecondary,
    stateUnsaved: AppColors.fieldTextPrimary,
    stateSettled: AppColors.fieldTextPrimary,
    stateQuiet: AppColors.fieldTextSecondary,
    textPrimary: AppColors.fieldTextPrimary,
    textSecondary: AppColors.fieldTextSecondary,
    textTertiary: AppColors.fieldTextTertiary,
    textDisabled: AppColors.fieldTextDisabled,
    surfaceRaised: AppColors.fieldSurfaceRaised,
    border: AppColors.fieldBorder,
    controlBorder: AppColors.fieldControlBorder,
    muted: AppColors.fieldTextSecondary,
    // As bright as "Fits": in red mode the word carries the caution.
    caution: AppColors.fieldTextPrimary,
    sunEvent: AppColors.fieldTextPrimary,
    twilightEvent: AppColors.fieldTextSecondary,
    moon: AppColors.fieldTextSecondary,
    selected: AppColors.fieldTextPrimary,
    chartDay: Color(0xFF3A0000),
    chartTwilight: Color(0xFF1C0000),
    chartDark: AppColors.fieldBackground,
    chartWindow: Color(0x55FF0000),
    chartTarget: AppColors.fieldTextPrimary,
    chartMoon: Color(0xFF990000),
    chartMinAltitude: Color(0xFFCC0000),
    chartNow: AppColors.fieldTextPrimary,
    chartNowCentre: AppColors.fieldBackground,
    chartGrid: Color(0x66FF0000),
    chartLabel: Color(0xFFCC0000),
    swatchBorder: AppColors.fieldBorder,
    bortle: [
      Color(0xFF330000),
      Color(0xFF110000),
      Color(0xFF220000),
      Color(0xFF330000),
      Color(0xFF440000),
      Color(0xFF660000),
      Color(0xFF880000),
      Color(0xFFAA0000),
      Color(0xFFCC0000),
      Color(0xFFFF0000),
    ],
    onBortle: [
      AppColors.fieldTextPrimary,
      AppColors.fieldTextPrimary,
      AppColors.fieldTextPrimary,
      AppColors.fieldTextPrimary,
      AppColors.fieldTextPrimary,
      AppColors.fieldTextPrimary,
      AppColors.fieldBackground,
      AppColors.fieldBackground,
      AppColors.fieldBackground,
      AppColors.fieldBackground,
    ],
  );

  /// The conventional Bortle map colours (unchanged from before TASK 12.4).
  static const _bortleColours = [
    Colors.grey,
    Colors.black,
    Color(0xFF263238), // blueGrey.shade900
    Color(0xFF0D47A1), // blue.shade900
    Color(0xFF388E3C), // green.shade700
    Color(0xFFFBC02D), // yellow.shade700
    Colors.orange,
    Colors.deepOrange,
    Colors.red,
    Colors.white,
  ];
  static const _onBortleColours = [
    Colors.white,
    Colors.white,
    Colors.white,
    Colors.white,
    Colors.white,
    Colors.black,
    Colors.white,
    Colors.white,
    Colors.white,
    Colors.red,
  ];

  /// Every token, for tests.
  List<Color> get all => [
    textPrimary,
    textSecondary,
    textTertiary,
    textDisabled,
    surfaceRaised,
    border,
    controlBorder,
    statusFits,
    statusTight,
    statusDoesNotFit,
    statusNoWindow,
    statusNeutral,
    stateUnsaved,
    stateSettled,
    stateQuiet,
    muted,
    caution,
    sunEvent,
    twilightEvent,
    moon,
    selected,
    chartDay,
    chartTwilight,
    chartDark,
    chartWindow,
    chartTarget,
    chartMoon,
    chartMinAltitude,
    chartNow,
    chartNowCentre,
    chartGrid,
    chartLabel,
    swatchBorder,
    ...bortle,
    ...onBortle,
  ];

  @override
  AppPalette copyWith({
    bool? fieldMode,
    Brightness? brightness,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textDisabled,
    Color? surfaceRaised,
    Color? border,
    Color? controlBorder,
    Color? statusFits,
    Color? statusTight,
    Color? statusDoesNotFit,
    Color? statusNoWindow,
    Color? statusNeutral,
    Color? stateUnsaved,
    Color? stateSettled,
    Color? stateQuiet,
    Color? muted,
    Color? caution,
    Color? sunEvent,
    Color? twilightEvent,
    Color? moon,
    Color? selected,
    Color? chartDay,
    Color? chartTwilight,
    Color? chartDark,
    Color? chartWindow,
    Color? chartTarget,
    Color? chartMoon,
    Color? chartMinAltitude,
    Color? chartNow,
    Color? chartNowCentre,
    Color? chartGrid,
    Color? chartLabel,
    Color? swatchBorder,
    List<Color>? bortle,
    List<Color>? onBortle,
  }) => AppPalette(
    fieldMode: fieldMode ?? this.fieldMode,
    brightness: brightness ?? this.brightness,
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    textTertiary: textTertiary ?? this.textTertiary,
    textDisabled: textDisabled ?? this.textDisabled,
    surfaceRaised: surfaceRaised ?? this.surfaceRaised,
    border: border ?? this.border,
    controlBorder: controlBorder ?? this.controlBorder,
    statusFits: statusFits ?? this.statusFits,
    statusTight: statusTight ?? this.statusTight,
    statusDoesNotFit: statusDoesNotFit ?? this.statusDoesNotFit,
    statusNoWindow: statusNoWindow ?? this.statusNoWindow,
    statusNeutral: statusNeutral ?? this.statusNeutral,
    stateUnsaved: stateUnsaved ?? this.stateUnsaved,
    stateSettled: stateSettled ?? this.stateSettled,
    stateQuiet: stateQuiet ?? this.stateQuiet,
    muted: muted ?? this.muted,
    caution: caution ?? this.caution,
    sunEvent: sunEvent ?? this.sunEvent,
    twilightEvent: twilightEvent ?? this.twilightEvent,
    moon: moon ?? this.moon,
    selected: selected ?? this.selected,
    chartDay: chartDay ?? this.chartDay,
    chartTwilight: chartTwilight ?? this.chartTwilight,
    chartDark: chartDark ?? this.chartDark,
    chartWindow: chartWindow ?? this.chartWindow,
    chartTarget: chartTarget ?? this.chartTarget,
    chartMoon: chartMoon ?? this.chartMoon,
    chartMinAltitude: chartMinAltitude ?? this.chartMinAltitude,
    chartNow: chartNow ?? this.chartNow,
    chartNowCentre: chartNowCentre ?? this.chartNowCentre,
    chartGrid: chartGrid ?? this.chartGrid,
    chartLabel: chartLabel ?? this.chartLabel,
    swatchBorder: swatchBorder ?? this.swatchBorder,
    bortle: bortle ?? this.bortle,
    onBortle: onBortle ?? this.onBortle,
  );

  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null || t == 0) return this;
    if (t == 1) return other;
    assert(bortle.length == other.bortle.length);
    assert(onBortle.length == other.onBortle.length);
    return AppPalette(
      fieldMode: t < .5 ? fieldMode : other.fieldMode,
      brightness: t < .5 ? brightness : other.brightness,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      border: Color.lerp(border, other.border, t)!,
      controlBorder: Color.lerp(controlBorder, other.controlBorder, t)!,
      statusFits: Color.lerp(statusFits, other.statusFits, t)!,
      statusTight: Color.lerp(statusTight, other.statusTight, t)!,
      statusDoesNotFit: Color.lerp(
        statusDoesNotFit,
        other.statusDoesNotFit,
        t,
      )!,
      statusNoWindow: Color.lerp(statusNoWindow, other.statusNoWindow, t)!,
      statusNeutral: Color.lerp(statusNeutral, other.statusNeutral, t)!,
      stateUnsaved: Color.lerp(stateUnsaved, other.stateUnsaved, t)!,
      stateSettled: Color.lerp(stateSettled, other.stateSettled, t)!,
      stateQuiet: Color.lerp(stateQuiet, other.stateQuiet, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      caution: Color.lerp(caution, other.caution, t)!,
      sunEvent: Color.lerp(sunEvent, other.sunEvent, t)!,
      twilightEvent: Color.lerp(twilightEvent, other.twilightEvent, t)!,
      moon: Color.lerp(moon, other.moon, t)!,
      selected: Color.lerp(selected, other.selected, t)!,
      chartDay: Color.lerp(chartDay, other.chartDay, t)!,
      chartTwilight: Color.lerp(chartTwilight, other.chartTwilight, t)!,
      chartDark: Color.lerp(chartDark, other.chartDark, t)!,
      chartWindow: Color.lerp(chartWindow, other.chartWindow, t)!,
      chartTarget: Color.lerp(chartTarget, other.chartTarget, t)!,
      chartMoon: Color.lerp(chartMoon, other.chartMoon, t)!,
      chartMinAltitude: Color.lerp(
        chartMinAltitude,
        other.chartMinAltitude,
        t,
      )!,
      chartNow: Color.lerp(chartNow, other.chartNow, t)!,
      chartNowCentre: Color.lerp(chartNowCentre, other.chartNowCentre, t)!,
      chartGrid: Color.lerp(chartGrid, other.chartGrid, t)!,
      chartLabel: Color.lerp(chartLabel, other.chartLabel, t)!,
      swatchBorder: Color.lerp(swatchBorder, other.swatchBorder, t)!,
      bortle: List.generate(
        bortle.length,
        (i) => Color.lerp(bortle[i], other.bortle[i], t)!,
      ),
      onBortle: List.generate(
        onBortle.length,
        (i) => Color.lerp(onBortle[i], other.onBortle[i], t)!,
      ),
    );
  }
}
