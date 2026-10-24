import 'package:astroplan/core/theme/app_theme.dart';
import 'package:astroplan/core/theme/app_typography.dart';
import 'package:astroplan/core/theme/hybrid_tokens.dart';
import 'package:astroplan/presentation/shared/document_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final theme in [AppTheme.light, AppTheme.dark, AppTheme.fieldTheme]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('document content grows and both actions remain reachable '
          '${theme.brightness} / ${theme.cardColor} / $scale', (tester) async {
        tester.view.physicalSize = const Size(320, 700);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearAllTestValues);
        final taps = <String>[];
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              body: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  DocumentSection(
                    key: const Key('group'),
                    children: [
                      Text(
                        'A long section heading that must remain fully readable',
                        style: AppTypography.sectionHeading,
                      ),
                      Text(
                        'Unknown remains unknown. A long explanation keeps its '
                        'units, source and full content when text grows.',
                        style: AppTypography.body,
                      ),
                      FilledButton(
                        onPressed: () => taps.add('first'),
                        child: const Text('First action'),
                      ),
                      OutlinedButton(
                        onPressed: () => taps.add('second'),
                        child: const Text('Second action'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
        final bounds = tester.getRect(find.byKey(const Key('group')));
        expect(bounds.width, 280);
        for (final name in ['First action', 'Second action']) {
          final action = find
              .ancestor(
                of: find.text(name),
                matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
              )
              .first;
          await tester.ensureVisible(action);
          await tester.pumpAndSettle();
          await tester.tap(action);
          expect(tester.getSize(action).height, greaterThanOrEqualTo(48));
        }
        expect(taps, ['first', 'second']);
        final box = tester.widget<Material>(
          find
              .descendant(
                of: find.byKey(const Key('group')),
                matching: find.byType(Material),
              )
              .first,
        );
        expect(box.color, theme.extension<HybridTokens>()!.surfaceSubtle);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
