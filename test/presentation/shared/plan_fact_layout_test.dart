import 'package:astroplan/core/theme/app_theme.dart';
import 'package:astroplan/presentation/shared/document_section.dart';
import 'package:astroplan/presentation/shared/hybrid_parts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final (name, theme) in [
    ('light', AppTheme.light),
    ('dark', AppTheme.dark),
    ('field', AppTheme.fieldTheme),
  ]) {
    for (final width in [320.0, 375.0]) {
      for (final scale in [1.0, 2.0]) {
        testWidgets('facts align and grow: $name, $width, $scale', (
          tester,
        ) async {
          tester.view.physicalSize = Size(width, 2200);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          await tester.pumpWidget(
            MaterialApp(
              theme: theme,
              home: MediaQuery(
                data: MediaQueryData(textScaler: TextScaler.linear(scale)),
                child: const Scaffold(
                  body: Padding(
                    padding: EdgeInsets.all(20),
                    child: DocumentSection(
                      children: [
                        HybridFacts([
                          ('Setup', 'Not included'),
                          (
                            'Needed in imaging window',
                            '2 h 15 min of 4 h 30 min',
                          ),
                          ('Resolution', '6000 × 4000 px'),
                          (
                            'Recorded in blocks',
                            'ISO or gain: set the camera type to record it',
                          ),
                        ]),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
          final rows = tester
              .widgetList<HybridFact>(find.byType(HybridFact))
              .toList();
          final labels = [
            for (final row in rows) tester.getRect(find.text(row.label)),
          ];
          final values = [
            for (final row in rows) tester.getRect(find.text(row.value)),
          ];
          for (var i = 0; i < rows.length; i++) {
            expect(labels[i].left, labels.first.left);
            expect(values[i].left, values.first.left);
            expect(values[i].right, lessThanOrEqualTo(width - 36));
            if (scale == 1) {
              expect(values[i].top, labels[i].top);
              expect(values[i].left - labels[i].right, closeTo(16, .01));
            } else {
              expect(values[i].top - labels[i].bottom, closeTo(4, .01));
              expect(values[i].left, labels[i].left);
            }
            if (i > 0) {
              final previousBottom = values[i - 1].bottom > labels[i - 1].bottom
                  ? values[i - 1].bottom
                  : labels[i - 1].bottom;
              expect(labels[i].top - previousBottom, closeTo(16, .01));
            }
          }
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('dense Plan inputs keep full text and reachable tap areas', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    var taps = 0;
    const longValue =
        '\u0414\u043e\u0432\u0433\u0430 \u043d\u0430\u0437\u0432\u0430 \u043c\u0456\u0441\u0446\u044f \u0441\u043f\u043e\u0441\u0442\u0435\u0440\u0435\u0436\u0435\u043d\u044c: \u0406 \u0456 \u0407 \u0457 \u0404 \u0454 \u0490 \u0491';
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Scaffold(
            body: DocumentSection(
              children: [
                HybridPlanRow(
                  key: const Key('site'),
                  label: 'Site',
                  value: longValue,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  caption: 'Site zone: Europe/Kyiv',
                  onTap: () => taps++,
                ),
                const HybridPlanRow(
                  key: Key('night'),
                  label: 'Night',
                  value: 'No night without a site',
                  padding: EdgeInsets.symmetric(vertical: 8),
                  onTap: null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    expect(
      tester.getSize(find.byKey(const Key('site'))).height,
      greaterThanOrEqualTo(48),
    );
    final text = tester.widget<Text>(find.text(longValue));
    expect(text.maxLines, isNull);
    expect(text.overflow, isNull);
    await tester.tap(find.text(longValue));
    expect(taps, 1);
    expect(tester.takeException(), isNull);
  });
}
