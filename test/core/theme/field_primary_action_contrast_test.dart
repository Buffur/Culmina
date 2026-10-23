// WQA-01 (owner-accepted Hybrid reference 86873ce, replacing D-06): in red
// field mode the primary action (a FilledButton such as "Save plan") is the
// bright red #FF0000 fill with black text, 5.25:1 and red only; pressed, it
// takes the selection fill with the primary text. Light and dark keep their
// filled action.

import 'package:astroplan/core/theme/app_palette.dart';
import 'package:astroplan/core/theme/app_theme.dart';
import 'package:astroplan/core/theme/hybrid_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  test('field mode (WQA-01): the primary action is black on #FF0000, at '
      'least 4.5:1, red only', () {
    final theme = AppTheme.fieldTheme;
    final style = theme.filledButtonTheme.style!;
    const enabled = <WidgetState>{};
    final fg = style.foregroundColor!.resolve(enabled)!;
    final bg = style.backgroundColor!.resolve(enabled)!;
    expect(bg, const Color(0xFFFF0000));
    expect(fg, const Color(0xFF000000));
    expect(style.side, isNull);
    expect(_contrast(fg, bg), greaterThanOrEqualTo(4.5));
    // Red only: no green or blue light in the action.
    for (final c in [fg, bg]) {
      expect((c.g * 255).round(), 0);
      expect((c.b * 255).round(), 0);
    }
    const pressed = {WidgetState.pressed};
    expect(
      style.backgroundColor!.resolve(pressed),
      theme.extension<HybridTokens>()!.selection,
    );
    expect(
      style.foregroundColor!.resolve(pressed),
      theme.extension<AppPalette>()!.textPrimary,
    );
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
