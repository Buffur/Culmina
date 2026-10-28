import 'package:astroplan/core/theme/app_palette.dart';
import 'package:astroplan/core/theme/app_theme.dart';
import 'package:astroplan/core/theme/app_text_theme.dart';
import 'package:astroplan/presentation/shared/plan_state.dart';
import 'package:astroplan/presentation/shared/hybrid_quiet_ink.dart';
import 'package:astroplan/core/theme/culmina_mark_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('copied field palette retains field-only ink behavior', (
    tester,
  ) async {
    WidgetStateProperty<Color?>? overlay;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.fieldTheme.copyWith(
          extensions: [
            ...AppTheme.fieldTheme.extensions.values.where(
              (e) => e is! AppPalette,
            ),
            AppPalette.field.copyWith(),
          ],
        ),
        home: Builder(
          builder: (context) {
            overlay = HybridQuietInk.overlay(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(overlay, isNull);
  });
  testWidgets('real state badge reads the active typography extension', (
    tester,
  ) async {
    final custom = AppTextTheme.standard.copyWith(
      caption: AppTextTheme.standard.caption.copyWith(fontSize: 27),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark.copyWith(
          extensions: [
            ...AppTheme.dark.extensions.values.where((e) => e is! AppTextTheme),
            custom,
          ],
        ),
        home: const Scaffold(body: PlanStateLabel(PlanState.saved)),
      ),
    );
    expect(tester.widget<Text>(find.text('Saved')).style!.fontSize, 27);
    final middle = AppTextTheme.standard.lerp(custom, .5);
    expect(
      middle.caption.fontSize,
      (AppTextTheme.standard.caption.fontSize! + 27) / 2,
    );
  });
  test('palette interpolation covers every role and Bortle entry', () {
    final palettes = [AppPalette.light, AppPalette.dark, AppPalette.field];
    for (final first in palettes) {
      for (final last in palettes) {
        expect(first.lerp(last, 0), same(first));
        expect(first.lerp(last, 1), same(last));
        for (final t in [.25, .5, .75]) {
          final actual = first.lerp(last, t).all;
          expect(actual, [
            for (var i = 0; i < first.all.length; i++)
              Color.lerp(first.all[i], last.all[i], t),
          ]);
        }
      }
    }
  });

  test('copyWith changes requested roles without mutating a preset', () {
    final original = AppPalette.dark;
    final copy = original.copyWith(
      textPrimary: original.caution,
      bortle: List.of(original.bortle.reversed),
    );
    expect(copy.textPrimary, original.caution);
    expect(copy.textSecondary, original.textSecondary);
    expect(copy.bortle, original.bortle.reversed.toList());
    expect(original.copyWith().all, original.all);
    expect(AppPalette.field.copyWith().fieldMode, isTrue);
    expect(AppPalette.dark.copyWith().brightness, Brightness.dark);
    expect(AppPalette.dark.lerp(AppPalette.field, .75).fieldMode, isTrue);
    expect(copyWithNull(original).all, original.all);
  });

  test('all themes install typed mark colors and interpolate them', () {
    for (final pair in [
      (AppTheme.light, CulminaMarkColors.light),
      (AppTheme.dark, CulminaMarkColors.dark),
      (AppTheme.fieldTheme, CulminaMarkColors.field),
    ]) {
      expect(pair.$1.extension<CulminaMarkColors>(), same(pair.$2));
    }
    final middle = CulminaMarkColors.light.lerp(CulminaMarkColors.dark, .5);
    expect(
      middle.orbit,
      Color.lerp(
        CulminaMarkColors.light.orbit,
        CulminaMarkColors.dark.orbit,
        .5,
      ),
    );
    expect(
      middle.background,
      Color.lerp(
        CulminaMarkColors.light.background,
        CulminaMarkColors.dark.background,
        .5,
      ),
    );
    expect(middle.copyWith(star: middle.orbit).star, middle.orbit);
    expect(middle.copyWith().starPeak, middle.starPeak);
  });
}

AppPalette copyWithNull(AppPalette palette) => palette.lerp(null, .5);
