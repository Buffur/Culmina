import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;

import 'app_colors.dart';
import 'app_palette.dart';
import 'app_radius.dart';
import 'app_typography.dart';
import 'app_motion.dart';
import 'hybrid_tokens.dart';
import 'hybrid_view_entrance.dart';

/// The app's three themes (TASK 12.4): light, dark and red field mode.
/// Colours come from [AppColors] and [AppPalette] tokens; text is never
/// smaller than 12 sp in the base scale (HybridTokens names the compact
/// navigation/calendar exceptions). Since S5.1 text roles drive the colour scheme
/// (`onSurface` is the primary text, `onSurfaceVariant` and `secondary`
/// the secondary text), `surfaceContainerHigh` is the raised surface, and
/// [AppTypography.scale] sets every style's size and weight.
class AppTheme {
  /// The family of the styles the theme builds by hand (F25).
  static const _family = HybridTokens.fontFamily;

  static final ThemeData light = _withTokens(
    ThemeData(
      fontFamily: _family,
      brightness: Brightness.light,
      primaryColor: AppColors.lightTextPrimary,
      scaffoldBackgroundColor: AppColors.lightBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: HybridTokens.appBarHeight,
        titleTextStyle: TextStyle(
          // Owner-selected bundled family, including Ukrainian glyphs.
          fontFamily: _family,
          color: AppColors.lightTextPrimary,
          fontSize: 22,
          height: 1.25,
          fontWeight: FontWeight.w500,
        ),
      ),
      colorScheme: const ColorScheme.light(
        primary: AppColors.lightTextPrimary,
        onPrimary: AppColors.lightBackground,
        secondary: AppColors.lightTextSecondary,
        // Selected segments and the navigation indicator: a light fill
        // with primary text (Material would derive them from secondary).
        secondaryContainer: AppColors.lightBorder,
        onSecondaryContainer: AppColors.lightTextPrimary,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextPrimary,
        onSurfaceVariant: AppColors.lightTextSecondary,
        surfaceContainerHigh: AppColors.lightSurfaceRaised,
        // S5.2: Material falls back to black for both (the prominent
        // field underline of 08 §6).
        outline: AppColors.lightControlBorder,
        outlineVariant: AppColors.lightBorder,
        error: AppColors.lightError,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightBorder,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.small),
          side: const BorderSide(color: AppColors.lightBorder),
        ),
        margin: EdgeInsets.zero,
      ),
    ),
    AppPalette.light,
  );

  static final ThemeData dark = _withTokens(
    ThemeData(
      fontFamily: _family,
      brightness: Brightness.dark,
      primaryColor: AppColors.darkTextPrimary,
      scaffoldBackgroundColor: AppColors.darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: HybridTokens.appBarHeight,
        titleTextStyle: TextStyle(
          // Owner-selected bundled family, including Ukrainian glyphs.
          fontFamily: _family,
          color: AppColors.darkTextPrimary,
          fontSize: 22,
          height: 1.25,
          fontWeight: FontWeight.w500,
        ),
      ),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkTextPrimary,
        onPrimary: AppColors.darkBackground,
        secondaryContainer: AppColors.darkSelection,
        onSecondaryContainer: AppColors.darkTextPrimary,
        secondary: AppColors.darkTextSecondary,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        onSurfaceVariant: AppColors.darkTextSecondary,
        surfaceContainerHigh: AppColors.darkSurfaceRaised,
        // S5.2: Material falls back to white for both.
        outline: AppColors.darkControlBorder,
        outlineVariant: AppColors.darkBorder,
        error: AppColors.darkError,
        onError: AppColors.darkBackground,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.small),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
        margin: EdgeInsets.zero,
      ),
    ),
    AppPalette.dark,
  );

  /// Every colour role is red or black (TASK 12.4), so dialogs, date
  /// pickers, snackbars, menus and the navigation bar stay red too.
  static const ColorScheme fieldColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.fieldTextPrimary,
    onPrimary: AppColors.fieldBackground,
    primaryContainer: AppColors.fieldBorder,
    onPrimaryContainer: AppColors.fieldTextPrimary,
    secondary: AppColors.fieldTextSecondary,
    onSecondary: AppColors.fieldBackground,
    secondaryContainer: AppColors.fieldBorder,
    onSecondaryContainer: AppColors.fieldTextPrimary,
    tertiary: AppColors.fieldTextSecondary,
    onTertiary: AppColors.fieldBackground,
    tertiaryContainer: AppColors.fieldBorder,
    onTertiaryContainer: AppColors.fieldTextPrimary,
    error: AppColors.fieldTextPrimary,
    onError: AppColors.fieldBackground,
    errorContainer: AppColors.fieldBorder,
    onErrorContainer: AppColors.fieldTextPrimary,
    surface: AppColors.fieldBackground,
    onSurface: AppColors.fieldTextPrimary,
    onSurfaceVariant: AppColors.fieldTextSecondary,
    surfaceDim: AppColors.fieldBackground,
    surfaceBright: AppColors.fieldBorder,
    surfaceContainerLowest: AppColors.fieldBackground,
    surfaceContainerLow: AppColors.fieldSurface,
    surfaceContainer: AppColors.fieldSurface,
    surfaceContainerHigh: AppColors.fieldSurfaceRaised,
    surfaceContainerHighest: Color(0xFF220000),
    outline: AppColors.fieldControlBorder,
    outlineVariant: AppColors.fieldBorder,
    shadow: AppColors.fieldBackground,
    scrim: AppColors.fieldBackground,
    inverseSurface: AppColors.fieldTextSecondary,
    onInverseSurface: AppColors.fieldBackground,
    inversePrimary: AppColors.fieldBackground,
    surfaceTint: AppColors.fieldBackground,
  );

  static final ThemeData fieldTheme = _withTokens(
    ThemeData(
      fontFamily: _family,
      colorScheme: fieldColorScheme,
      primaryColor: AppColors.fieldTextPrimary,
      scaffoldBackgroundColor: AppColors.fieldBackground,
      canvasColor: AppColors.fieldBackground,
      cardColor: AppColors.fieldSurface,
      dividerColor: AppColors.fieldBorder,
      hintColor: AppColors.fieldTextSecondary,
      disabledColor: AppColors.fieldTextDisabled,
      unselectedWidgetColor: AppColors.fieldTextSecondary,
      hoverColor: const Color(0x1FFF0000),
      focusColor: const Color(0x1FFF0000),
      highlightColor: const Color(0x1FFF0000),
      splashColor: const Color(0x33FF0000),
      shadowColor: AppColors.fieldBackground,
      secondaryHeaderColor: AppColors.fieldSurface,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.fieldBackground,
        foregroundColor: AppColors.fieldTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: HybridTokens.appBarHeight,
        titleTextStyle: TextStyle(
          // Owner-selected bundled family, including Ukrainian glyphs.
          fontFamily: _family,
          color: AppColors.fieldTextPrimary,
          fontSize: 22,
          height: 1.25,
          fontWeight: FontWeight.w500,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.fieldBorder,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: AppColors.fieldSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.small),
          side: const BorderSide(color: AppColors.fieldBorder),
        ),
        margin: EdgeInsets.zero,
      ),
      iconTheme: const IconThemeData(color: AppColors.fieldTextPrimary),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.fieldBorder,
        contentTextStyle: TextStyle(
          fontFamily: _family,
          color: AppColors.fieldTextPrimary,
        ),
        actionTextColor: AppColors.fieldTextPrimary,
      ),
    ),
    AppPalette.field,
    textColor: AppColors.fieldTextPrimary,
    field: true,
  );

  /// Red field mode's safety net (owner decision, TASK 12.4): applied over
  /// the whole app, it maps every pixel to red by brightness — R' = R +
  /// 0.7152 G + 0.0722 B (Rec. 709 luma weights for G and B), G' = B' = 0 —
  /// so map tiles and anything a token misses stay red. Pure red is
  /// unchanged.
  static const ColorFilter fieldFilter = ColorFilter.matrix(fieldFilterMatrix);

  /// The 4×5 RGBA matrix of [fieldFilter], row by row.
  static const List<double> fieldFilterMatrix = <double>[
    1, 0.7152, 0.0722, 0, 0, //
    0, 0, 0, 0, 0, //
    0, 0, 0, 0, 0, //
    0, 0, 0, 1, 0, //
  ];

  /// Adds the palette and the shared type scale (no text under 12 sp).
  /// The scale's sizes and weights override Material's geometry; the
  /// colours stay the theme's.
  static ThemeData _withTokens(
    ThemeData base,
    AppPalette palette, {
    Color? textColor,
    bool field = false,
  }) {
    final hybrid = field
        ? HybridTokens.field
        : base.brightness == Brightness.dark
        ? HybridTokens.dark
        : HybridTokens.light;
    TextTheme readable(TextTheme t) {
      final scaled = t.merge(AppTypography.scale);
      return textColor == null
          ? scaled
          : scaled.apply(bodyColor: textColor, displayColor: textColor);
    }

    return _withControls(
      base.copyWith(
        extensions: [palette, hybrid],
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: HybridPageTransitionsBuilder(),
            TargetPlatform.windows: HybridPageTransitionsBuilder(),
            TargetPlatform.linux: HybridPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        textTheme: readable(base.textTheme),
        primaryTextTheme: readable(base.primaryTextTheme),
      ),
      palette,
      field: field,
    );
  }

  /// The controls' look (S5.2; `docs/DESIGN_SYSTEM.md`): the button roles,
  /// text fields, dialogs, sheets, menus and messages, from the tokens
  /// only, so field mode stays red or black.
  static ThemeData _withControls(
    ThemeData t,
    AppPalette p, {
    required bool field,
  }) {
    final s = t.colorScheme;
    final hybrid = t.extension<HybridTokens>()!;
    final text = t.textTheme;
    final shape = WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
    );
    final label = WidgetStatePropertyAll(text.labelLarge);
    const tall = WidgetStatePropertyAll(Size(64, 48));

    // Pressed feedback stronger than Material's 10 % (08 §5, §8).
    WidgetStateProperty<Color?> overlay(Color c) =>
        WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return c.withValues(alpha: pressedOverlay);
          }
          if (states.contains(WidgetState.focused)) {
            return c.withValues(alpha: 0.12);
          }
          if (states.contains(WidgetState.hovered)) {
            return c.withValues(alpha: 0.08);
          }
          return null;
        });
    WidgetStateProperty<Color> onOff(Color on) =>
        WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.disabled) ? p.textDisabled : on,
        );
    final secondary = ButtonStyle(
      minimumSize: tall,
      animationDuration: AppMotion.short,
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      shape: shape,
      textStyle: label,
      foregroundColor: onOff(p.textPrimary),
      iconColor: onOff(p.textPrimary),
      backgroundColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.pressed) ? hybrid.selection : null,
      ),
      // The selection fill is the pressed feedback; no extra overlay.
      overlayColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.pressed)
            ? HybridTokens.transparent
            : overlay(p.textPrimary).resolve(states),
      ),
      side: WidgetStateProperty.resolveWith(
        (states) => BorderSide(
          color: states.contains(WidgetState.disabled)
              ? p.border
              : p.controlBorder,
        ),
      ),
    );

    // Primary action (styles.css, hybrid-refinement.css): the action fill
    // with its on-action text in every theme. WQA-01 (owner-accepted web
    // reference 86873ce): field mode's action is the bright red role with
    // black text (5.25:1), replacing the D-06 red outline; hover underlines
    // instead of darkening. Pressed: every Hybrid button takes the selection
    // fill with primary text (`button:active`). Disabled: opacity .55.
    final field = identical(hybrid, HybridTokens.field);
    Color disabled(Color c) => c.withValues(alpha: c.a * 0.55);
    return t.copyWith(
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: tall,
          shape: shape,
          textStyle: WidgetStateProperty.resolveWith(
            (states) => text.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              height: 1.5,
              decoration: field && states.contains(WidgetState.hovered)
                  ? TextDecoration.underline
                  : TextDecoration.none,
            ),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          animationDuration: AppMotion.short,
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return disabled(hybrid.action);
            }
            if (states.contains(WidgetState.pressed)) return hybrid.selection;
            if (!field && states.contains(WidgetState.hovered)) {
              return Color.lerp(hybrid.action, const Color(0xFF000000), 0.13);
            }
            return hybrid.action;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return disabled(hybrid.onAction);
            }
            if (states.contains(WidgetState.pressed)) return p.textPrimary;
            return hybrid.onAction;
          }),
          iconColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return disabled(hybrid.onAction);
            }
            if (states.contains(WidgetState.pressed)) return p.textPrimary;
            return hybrid.onAction;
          }),
          overlayColor: const WidgetStatePropertyAll(HybridTokens.transparent),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(style: secondary),
      // The flat design has no elevation: an elevated button is the
      // secondary role, on the surface.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: secondary.copyWith(
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? t.scaffoldBackgroundColor
                : s.surface,
          ),
          elevation: const WidgetStatePropertyAll(0),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          minimumSize: tall,
          animationDuration: AppMotion.short,
          shape: shape,
          textStyle: label,
          foregroundColor: onOff(p.textPrimary),
          iconColor: onOff(p.textPrimary),
          overlayColor: overlay(p.textPrimary),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
          overlayColor: overlay(p.textPrimary),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: shape,
          minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
          textStyle: label,
          side: WidgetStatePropertyAll(BorderSide(color: p.controlBorder)),
          foregroundColor: onOff(p.textPrimary),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? hybrid.selection
                : t.scaffoldBackgroundColor,
          ),
        ),
      ),
      // A quiet underline (08 §6): the enabled line is the control border
      // (colorScheme.outline, which Material reads); focus draws it 2 px in
      // the primary colour. Labels and hints are text roles (AA).
      inputDecorationTheme: InputDecorationThemeData(
        contentPadding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(minHeight: 48),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.small),
          borderSide: BorderSide(color: p.controlBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.small),
          borderSide: BorderSide(color: p.textPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.small),
          borderSide: BorderSide(color: s.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.small),
          borderSide: BorderSide(color: s.error, width: 2),
        ),
        labelStyle: TextStyle(color: p.textSecondary),
        floatingLabelStyle: WidgetStateTextStyle.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.error)
                ? s.error
                : states.contains(WidgetState.focused)
                ? s.primary
                : p.textSecondary,
          ),
        ),
        hintStyle: TextStyle(color: p.textTertiary),
        helperStyle: TextStyle(color: p.textTertiary),
        errorStyle: TextStyle(color: s.error),
        prefixIconColor: p.textSecondary,
        suffixIconColor: p.textSecondary,
        fillColor: s.surface,
      ),
      // plan.css `.planner-page dialog` (WQA-04): 20 from the app's edges
      // (so 335 wide at 375 and 372 at 412), radius 12, a control-border
      // outline, no shadow, 24 padding; the title 22/500, the message
      // 14 secondary 16 below it, the actions 24 below, 8 apart, at the end.
      dialogTheme: DialogThemeData(
        backgroundColor: p.surfaceRaised,
        surfaceTintColor: HybridTokens.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        barrierColor: const Color(0x55000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
          side: BorderSide(color: p.controlBorder),
        ),
        titleTextStyle: text.titleLarge?.copyWith(
          fontSize: 22,
          height: 1.25,
          fontWeight: FontWeight.w500,
          color: p.textPrimary,
        ),
        contentTextStyle: text.bodyMedium?.copyWith(
          fontSize: 14,
          height: 1.5,
          color: p.textSecondary,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surfaceRaised,
        modalBackgroundColor: p.surfaceRaised,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.large),
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: p.surfaceRaised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.small),
          side: BorderSide(color: p.border),
        ),
        labelTextStyle: WidgetStatePropertyAll(
          text.bodyMedium?.copyWith(color: p.textPrimary),
        ),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(p.surfaceRaised),
        ),
      ),
      // Field mode keeps its dim red message; light and dark invert.
      snackBarTheme: field
          ? t.snackBarTheme
          : SnackBarThemeData(
              backgroundColor: p.textPrimary,
              contentTextStyle: text.bodyMedium?.copyWith(
                color: t.scaffoldBackgroundColor,
              ),
              actionTextColor: t.scaffoldBackgroundColor,
            ),
    );
  }

  /// The pressed overlay's opacity on every button (S5.2).
  static const double pressedOverlay = 0.16;
}
