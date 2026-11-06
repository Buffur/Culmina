import 'package:flutter/material.dart';

/// The raw colours behind the three themes. Widgets never read these
/// directly: they use `Theme.of(context).colorScheme` or [AppPalette]
/// (TASK 12.4). The text roles (S5.1) are documented in
/// `docs/DESIGN_SYSTEM.md`: in light and dark every role is WCAG AA
/// (4.5:1) on the background, the surface and the raised surface, and each
/// is at least 1.3 times the next one's contrast. Control borders (S5.2)
/// are at least 3:1 (WCAG 1.4.11); the error colour is AA as text.
class AppColors {
  // The Culmina mark's colours are generated with its geometry
  // (lib/presentation/shared/culmina_mark_geometry.dart, tool/culmina_mark.py).

  // Light Theme
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF7F7F5);
  static const Color lightSurfaceRaised = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF37352F); // 11.4:1
  static const Color lightTextSecondary = Color(0xFF5A5955); // 6.5:1
  static const Color lightTextTertiary = Color(0xFF6E6D69); // 4.8:1
  static const Color lightTextDisabled = Color(0xFFA3A29F);
  static const Color lightBorder = Color(0xFFE9E9E7);
  static const Color lightControlBorder = Color(0xFF8F8E8A); // 3.1:1
  static const Color lightError = Color(0xFFB00020); // 6.8:1

  // AFTER-DARK-1.2 (design/figma/tokens_semantic.md).
  // Canvas and bounded record surfaces retain independent semantic roles.
  static const Color darkBackground = Color(0xFF202020);
  static const Color darkSurface = Color(0xFF202020);
  static const Color darkSurfaceRaised = Color(0xFF262626);
  static const Color darkTextPrimary = Color(0xFFF0EFED); // 13.17:1 on raised
  static const Color darkTextSecondary = Color(0xFFC4C1BC); // 8.43:1 on raised
  static const Color darkTextTertiary = Color(0xFFADA9A3); // 6.47:1 on raised
  static const Color darkTextDisabled = Color(0xFF737373);
  static const Color darkSelection = Color(0xFF262626);
  static const Color darkBorder = Color(0xFF414141);
  static const Color darkControlBorder = Color(0xFF8B8F93); // control boundary
  static const Color darkError = Color(0xFFF39B95); // validation text

  // Field Mode (Red): brightness, not hue, separates the roles.
  static const Color fieldBackground = Color(0xFF000000);
  static const Color fieldSurface = Color(0xFF110000);
  static const Color fieldSurfaceRaised = Color(0xFF1A0000);
  static const Color fieldTextPrimary = Color(0xFFFF0000);
  static const Color fieldTextSecondary = Color(0xFFAA0000);
  static const Color fieldTextTertiary = Color(0xFF880000);
  static const Color fieldTextDisabled = Color(0xFF660000);
  static const Color fieldBorder = Color(0xFF330000);
  // Brighter than a card border so controls stay visible (UX-39).
  static const Color fieldControlBorder = Color(0xFF880000);
}
