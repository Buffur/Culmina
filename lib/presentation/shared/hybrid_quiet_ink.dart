import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/hybrid_tokens.dart';

/// Opt-in ink for the confirmed enabled controls with quiet labels.
/// Keeps their text/surface roles, ripple, geometry and callbacks intact.
class HybridQuietInk extends StatelessWidget {
  const HybridQuietInk({super.key, required this.child});
  final Widget child;

  // The pinned SDK paints both pressed highlight and splash. Two equal
  // layers compose to the documented total 16% foreground feedback.
  static final _pressedLayerAlpha = 1 - math.sqrt(1 - AppTheme.pressedOverlay);

  static WidgetStateProperty<Color?>? overlay(BuildContext context) {
    final p = AppPalette.of(context);
    if (p.fieldMode) return null;
    final canvas = Theme.of(context).scaffoldBackgroundColor;
    return WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) return null;
      if (states.contains(WidgetState.pressed)) {
        return p.textSecondary.withValues(alpha: _pressedLayerAlpha);
      }
      if (states.contains(WidgetState.focused)) {
        return canvas.withValues(alpha: 0.12);
      }
      if (states.contains(WidgetState.hovered)) {
        return canvas.withValues(alpha: 0.08);
      }
      return HybridTokens.transparent;
    });
  }

  static ButtonStyle? buttonStyle(BuildContext context) {
    final feedback = overlay(context);
    return feedback == null ? null : ButtonStyle(overlayColor: feedback);
  }

  @override
  Widget build(BuildContext context) {
    final feedback = overlay(context);
    if (feedback == null) return child;
    return Theme(
      data: Theme.of(context).copyWith(
        highlightColor: feedback.resolve({WidgetState.pressed}),
        splashColor: feedback.resolve({WidgetState.pressed}),
        focusColor: feedback.resolve({WidgetState.focused}),
        hoverColor: feedback.resolve({WidgetState.hovered}),
      ),
      child: child,
    );
  }
}
