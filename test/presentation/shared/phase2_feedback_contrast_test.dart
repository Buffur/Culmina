import 'package:astroplan/presentation/screens/settings/settings_parts.dart';
import 'package:astroplan/presentation/shared/action_row.dart';
import 'package:astroplan/presentation/shared/collapsible_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/wave1_capture.dart';
import '../../support/wave3_focus.dart';
import '../../support/wave3_ink.dart';

void main() {
  setUpAll(loadWave1Font);
  for (final theme in ['light', 'dark', 'field']) {
    for (final kind in ['action', 'link', 'disclosure']) {
      testWidgets(
        'Phase2 $kind focus and pressed text remains readable $theme',
        (t) async {
          t.view.physicalSize = const Size(375, 812);
          t.view.devicePixelRatio = 1;
          addTearDown(t.view.reset);
          var activations = 0;
          final Widget child = switch (kind) {
            'action' => ActionRow(
              title: 'Open saved record',
              description: 'Keep the complete source and units',
              onTap: () => activations++,
            ),
            'link' => const SettingsLink(
              label: 'OpenNGC on GitHub',
              url: 'https://github.com/mattiaverga/OpenNGC',
            ),
            _ => CollapsibleSection(
              sectionKey: 'phase2.feedback',
              title: 'Forecast details',
              summary: 'Hourly values, layers and source',
              open: false,
              onToggle: () => activations++,
              child: const Text('Details'),
            ),
          };
          final title = switch (kind) {
            'action' => 'Open saved record',
            'link' => 'OpenNGC on GitHub',
            _ => 'Forecast details',
          };
          await t.pumpWidget(
            wave1App(
              theme,
              home: Scaffold(
                body: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [child],
                ),
              ),
            ),
          );
          await t.pumpAndSettle();
          final control = find.byType(InkWell).first;
          final label = find.text(title);
          await wave3FocusContrast(
            t,
            label,
            'phase2-$kind-$theme-normal',
            theme,
          );
          await wave3TabTo(t, control);
          await wave3FocusContrast(
            t,
            label,
            'phase2-$kind-$theme-focus',
            theme,
          );
          await wave3HeldContrast(
            t,
            control,
            label,
            'phase2-$kind-$theme-held',
            theme,
          );
          expect(
            activations,
            0,
            reason: 'Holding or focusing must not activate',
          );
          if (kind != 'link') {
            await t.tap(control);
            await t.pumpAndSettle();
            expect(activations, 1);
          }
          expect(t.takeException(), isNull);
        },
      );
    }
  }
}
