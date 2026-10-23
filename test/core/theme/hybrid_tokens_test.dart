import 'dart:convert';
import 'dart:io';

import 'package:astroplan/core/theme/app_motion.dart';
import 'package:astroplan/core/theme/app_palette.dart';
import 'package:astroplan/core/theme/app_theme.dart';
import 'package:astroplan/core/theme/hybrid_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final json = jsonDecode(
    File('design/home-lab/tokens.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  // The colour roles come from the reference's final computed cascade
  // (hybrid-transfer evidence, plan.html at 86873ce), not tokens.json's
  // first declarations: WQA-01's field action #FF0000 overrides the JSON's
  // #AA0000 there.
  final computed = jsonDecode(
    File(
      'docs/design/migration/evidence/hybrid-transfer-2026-10-22/web/'
      'computed-theme-vars.json',
    ).readAsStringSync(),
  ) as Map<String, dynamic>;
  final themes = {
    'light': AppTheme.light,
    'dark': AppTheme.dark,
    'field': AppTheme.fieldTheme,
  };

  for (final entry in themes.entries) {
    test(
      '${entry.key}: native semantic colors match every applicable JSON role',
      () {
        final theme = entry.value;
        final p = theme.extension<AppPalette>()!;
        final h = theme.extension<HybridTokens>()!;
        final cascade = computed['${entry.key}:plan.html'] as Map;
        final expected = <String, dynamic>{
          for (final role in (json['themes'][entry.key] as Map).keys)
            role: cascade['--$role'] ?? json['themes'][entry.key][role],
        };
        final actual = <String, Color>{
          'surface-default': theme.scaffoldBackgroundColor,
          'surface-subtle': entry.key == 'field'
              ? theme.cardColor
              : theme.colorScheme.surface,
          'surface-raised': p.surfaceRaised,
          'text-primary': p.textPrimary,
          'text-secondary': p.textSecondary,
          'text-tertiary': p.textTertiary,
          'border-subtle': p.border,
          'border-control': p.controlBorder,
          'action': h.action,
          'on-action': h.onAction,
          'selection': h.selection,
          'error': theme.colorScheme.error,
        };
        expect(
          actual.keys.toSet(),
          expected.keys.toSet()..remove('surface-sunken'),
        );
        for (final role in actual.entries) {
          final argb = int.parse(
            'FF${(expected[role.key] as String).substring(1)}',
            radix: 16,
          );
          expect(
            role.value.toARGB32(),
            argb,
            reason: '${entry.key}.${role.key}',
          );
        }
        // WQA-01: every theme's primary action is the action fill with
        // its on-action text (field: black on #FF0000).
        expect(
          theme.filledButtonTheme.style!.backgroundColor!.resolve({}),
          h.action,
        );
        expect(
          theme.filledButtonTheme.style!.foregroundColor!.resolve({}),
          h.onAction,
        );
        expect(theme.colorScheme.secondaryContainer, h.selection);
        expect(theme.textTheme.bodyMedium!.fontFamily, 'Geist');
        expect(theme.textTheme.bodyMedium!.fontSize, 16);
        expect(theme.textTheme.bodySmall!.fontSize, 13);
        expect(theme.textTheme.labelLarge!.fontSize, 14);
        expect(
          theme.inputDecorationTheme.enabledBorder,
          isA<OutlineInputBorder>(),
        );
      },
    );
  }

  test(
    'motion is transferred with units and all field chart colors stay red',
    () {
      final tokens = json['hybridRefinement'];
      expect('${AppMotion.short.inMilliseconds}ms', tokens['feedback']);
      expect('${AppMotion.medium.inMilliseconds}ms', tokens['transition']);
      for (final c in [
        ...HybridTokens.field.sky,
        HybridTokens.field.moonUp,
        HybridTokens.field.moonFree,
        HybridTokens.field.weatherCaution,
      ]) {
        expect(c.g, 0);
        expect(c.b, 0);
      }
    },
  );

  testWidgets(
    'Geist form at 200 percent retains text, input and usable primary action',
    (tester) async {
      final font = FontLoader('Geist')
        ..addFont(
          Future.value(
            ByteData.sublistView(
              File('assets/fonts/Geist.ttf').readAsBytesSync(),
            ),
          ),
        );
      await font.load();
      await tester.binding.setSurfaceSize(const Size(360, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      var saved = '';
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(360, 800),
              textScaler: TextScaler.linear(2),
              disableAnimations: true,
            ),
            child: Scaffold(
              body: Builder(
                builder: (context) => ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text(
                      '\u041D\u0456\u0447 \u0441\u043F\u043E\u0441\u0442\u0435\u0440\u0435\u0436\u0435\u043D\u043D\u044F · \u0406\u0456 \u0407\u0457 \u0404\u0454 \u0490\u0491 · 12 × 60 s · −18°',
                    ),
                    TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        labelText: 'Target',
                        helperText: 'Keep unknown values unrecorded',
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () {
                        saved = controller.text;
                      },
                      child: const Text('Save plan'),
                    ),
                    Text(
                      '${AppMotion.duration(context, AppMotion.medium).inMilliseconds} ms',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'M31');
      await tester.ensureVisible(find.text('Save plan'));
      await tester.tap(find.text('Save plan'));
      await tester.pump();
      expect(saved, 'M31');
      expect(find.text('0 ms'), findsOneWidget);
      expect(
        tester.getSize(find.byType(FilledButton)).height,
        greaterThanOrEqualTo(48),
      );
      expect(tester.takeException(), isNull);
    },
  );
}
