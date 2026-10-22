import 'package:flutter/material.dart';

import 'hybrid_tokens.dart';

/// The type scale (S5.1): size, line height and weight for every style,
/// shared by the three themes. Colours come from the theme (the text roles
/// in [AppPalette]); the owner-selected Geist family uses neutral tracking. Nothing is under
/// 12 sp in this base scale. Compact web navigation/calendar exceptions live
/// in HybridTokens. Roles are documented in `docs/DESIGN_SYSTEM.md`.
abstract final class AppTypography {
  static TextStyle _style(double size, double lineHeight, FontWeight weight) =>
      TextStyle(
        fontFamily: HybridTokens.fontFamily,
        fontSize: size,
        height: lineHeight / size,
        fontWeight: weight,
        letterSpacing: 0,
      );

  /// Supporting copy, distinct from the 16 sp data/body role.
  static final TextStyle support = _style(14, 22, FontWeight.w400);

  /// Source Serif 4 as the browser loads it (Google Fonts wght-only file =
  /// the variable font at opsz 14; measured, see SourceSerif4.source.json).
  static const serifFamily = 'Source Serif 4';
  static const serifVariations = [FontVariation('opsz', 14)];

  static TextStyle serif(double size, double lineHeight, double tracking) =>
      TextStyle(
        fontFamily: serifFamily,
        fontVariations: serifVariations,
        fontSize: size,
        height: lineHeight / size,
        fontWeight: FontWeight.w400,
        letterSpacing: tracking,
      );

  /// Editorial night section ("The night ahead"): serif 25/32.5, -0.5.
  static final TextStyle nightHeading = serif(25, 32.5, -0.5);

  /// Night, Moon and Weather answers: serif 28/36.4, -0.02 em.
  static final TextStyle answerHeading = serif(28, 36.4, -0.56);

  // The Hybrid role scale (owner-accepted 2026-10-22, a594837/93e0eb6):
  // a label never reads smaller than the content it introduces.
  /// Screen title and screen answer: 22/500.
  static final TextStyle screenTitle = _style(22, 27.5, FontWeight.w500);

  /// Section heading, disclosures included: 20/600.
  static final TextStyle sectionHeading = _style(
    20,
    28,
    FontWeight.w600,
  ).copyWith(letterSpacing: -0.3);

  /// Section subject (Home target): 18/500.
  static final TextStyle sectionSubject = _style(18, 23.4, FontWeight.w500);

  /// Item title and sub-heading: 16/600.
  static final TextStyle itemTitle = _style(16, 22.4, FontWeight.w600);

  /// List-row title (Settings, Library, Logbook rows): 16/500.
  static final TextStyle rowTitle = _style(16, 24, FontWeight.w500);

  /// Primary value: 15/400.
  static final TextStyle value = _style(15, 21.75, FontWeight.w400);

  /// Body: 14/400.
  static final TextStyle body = _style(14, 21.7, FontWeight.w400);

  /// Caption, hint and note: 13/400.
  static final TextStyle caption = _style(13, 19.5, FontWeight.w400);

  /// Dense data only (tables, hourly strip, calendar, chart axes): 12/400.
  static final TextStyle dense = _style(12, 18, FontWeight.w400);

  /// Root navigation labels: the platform face (Roboto), 11.
  static const TextStyle navigationLabel = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 11,
    height: 1.5,
    letterSpacing: 0,
  );

  static final TextStyle homeHeading = _style(
    29,
    34.8,
    FontWeight.w500,
  ).copyWith(letterSpacing: -0.87);

  /// Hybrid Home roles from styles.css and hybrid-refinement.css.
  static final TextStyle homePlanHeading = _style(
    20,
    28,
    FontWeight.w600,
  ).copyWith(letterSpacing: -0.15);

  static final TextStyle homeTarget = _style(18, 23.4, FontWeight.w500);

  static final TextStyle homeWordmark = _style(
    13,
    17.55,
    FontWeight.w600,
  ).copyWith(letterSpacing: -0.4);

  static final TextStyle homeWelcome = _style(13, 17.55, FontWeight.w400);

  static final TextTheme scale = TextTheme(
    displayLarge: _style(57, 64, FontWeight.w400),
    displayMedium: _style(45, 52, FontWeight.w400),
    displaySmall: _style(36, 44, FontWeight.w400),
    headlineLarge: _style(32, 40, FontWeight.w400),
    headlineMedium: _style(28, 36, FontWeight.w400),
    headlineSmall: _style(24, 32, FontWeight.w400),
    // Titles carry the hierarchy: heavier than Material's defaults.
    titleLarge: _style(20, 28, FontWeight.w600),
    titleMedium: _style(16, 24, FontWeight.w600),
    titleSmall: _style(14, 20, FontWeight.w600),
    bodyLarge: _style(16, 24, FontWeight.w400),
    bodyMedium: _style(16, 24, FontWeight.w400),
    bodySmall: _style(13, 20, FontWeight.w400),
    labelLarge: _style(14, 20, FontWeight.w500),
    labelMedium: _style(14, 21, FontWeight.w500),
    labelSmall: _style(13, 20, FontWeight.w500),
  );
}
