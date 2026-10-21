// D-06 (owner decision, 2026-10-21): in red field mode the primary action
// (a FilledButton such as "Save plan") is red text with a red outline on
// black, reaching WCAG AA (4.5:1) with red only. The JSON's black on #AA0000
// (about 2.7:1) stays the light and dark themes' rule only for those themes.

import 'package:astroplan/core/theme/app_palette.dart';
import 'package:astroplan/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  test('field mode: the primary action is red on black with a red outline, '
      'at least 4.5:1', () {
    final theme = AppTheme.fieldTheme;
    final style = theme.filledButtonTheme.style!;
    const enabled = <WidgetState>{};
    final fg = style.foregroundColor!.resolve(enabled)!;
    final bg = style.backgroundColor!.resolve(enabled)!;
    final side = style.side!.resolve(enabled)!;
    final palette = theme.extension<AppPalette>()!;
    expect(fg, palette.textPrimary);
    expect(bg, theme.scaffoldBackgroundColor);
    expect(side.color, palette.textPrimary);
    expect(_contrast(fg, bg), greaterThanOrEqualTo(4.5));
    // Red only: no green or blue light in the action.
    for (final c in [fg, bg, side.color]) {
      expect((c.g * 255).round(), 0);
      expect((c.b * 255).round(), 0);
    }
  });

  test('light and dark keep the filled Hybrid action', () {
    for (final theme in [AppTheme.light, AppTheme.dark]) {
      final style = theme.filledButtonTheme.style!;
      expect(style.side, isNull);
      final fg = style.foregroundColor!.resolve(const {})!;
      final bg = style.backgroundColor!.resolve(const {})!;
      expect(_contrast(fg, bg), greaterThanOrEqualTo(4.5));
    }
  });
}
