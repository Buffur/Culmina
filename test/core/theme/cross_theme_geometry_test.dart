import 'package:astroplan/core/theme/app_theme.dart';
import 'package:astroplan/presentation/shared/hybrid_parts.dart';
import 'package:astroplan/presentation/shared/info_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final width in [320.0, 375.0]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('theme changes retain geometry at $width dp / $scale text', (
        tester,
      ) async {
        await tester.binding.setSurfaceSize(Size(width, 1600));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        List<Rect>? reference;
        for (final theme in [
          AppTheme.dark,
          AppTheme.light,
          AppTheme.fieldTheme,
        ]) {
          await tester.pumpWidget(
            MaterialApp(
              theme: theme,
              home: MediaQuery(
                data: MediaQueryData(
                  size: Size(width, 1600),
                  textScaler: TextScaler.linear(scale),
                ),
                child: Scaffold(
                  appBar: AppBar(title: const Text('Site and night')),
                  body: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const HybridSectionTitle('Capture plan'),
                          const HybridFact('Frames', '120'),
                          const HybridFact(
                            'Available integration time at the selected site',
                            'Unknown until a site and night are selected',
                          ),
                          const InfoRow(
                            label: 'Sensor',
                            value: 'Unknown',
                            trailing: Icon(Icons.info_outline, size: 20),
                          ),
                          const InfoRow(
                            label: 'Provenance of the storage estimate',
                            value: 'Based on the selected camera specification',
                          ),
                          FilledButton(
                            onPressed: () {},
                            child: const Text('Save plan'),
                          ),
                          const AlertDialog(
                            title: Text('Discard changes?'),
                            content: Text('Your saved plan is retained.'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          final geometry = [
            for (final element in find.byType(Text).evaluate())
              tester.getRect(find.byWidget(element.widget)),
            tester.getRect(find.byType(FilledButton)),
            tester.getRect(find.byType(InfoRow).first),
            tester.getRect(find.byType(HybridFact).last),
          ];
          if (reference == null) {
            reference = geometry;
          } else {
            expect(
              geometry,
              reference,
              reason: 'Palette changes must not reflow content',
            );
          }
        }
      });
    }
  }
}
