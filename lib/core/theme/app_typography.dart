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

  /// Editorial night section, using the owner's Geist override.
  static final TextStyle nightHeading = _style(
    25,
    32.5,
    FontWeight.w400,
  ).copyWith(letterSpacing: -0.5);

  static final TextStyle homeHeading = _style(
    29,
    34.8,
    FontWeight.w500,
  ).copyWith(letterSpacing: -0.87);

  /// Hybrid Home roles from styles.css and hybrid-refinement.css.
  static final TextStyle homePlanHeading = _style(
    14,
    21,
    FontWeight.w600,
  ).copyWith(letterSpacing: -0.15);

  static final TextStyle homeTarget = _style(
    21,
    27.3,
    FontWeight.w500,
  ).copyWith(letterSpacing: -0.5);

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
