// Isolated application of the owner-requested design skills. This composes
// real shared widgets; it does not adopt any browser concept into production.
import 'package:astroplan/core/theme/app_palette.dart';
import 'package:astroplan/core/theme/app_spacing.dart';
import 'package:astroplan/core/theme/app_theme.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/services/fit_analyzer.dart';
import 'package:astroplan/presentation/shared/collapsible_section.dart';
import 'package:astroplan/presentation/shared/context_line.dart';
import 'package:astroplan/presentation/shared/plan_state.dart';
import 'package:astroplan/presentation/shared/status_block.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final (name, theme) in [
    ('light', AppTheme.light),
    ('dark', AppTheme.dark),
    ('field', AppTheme.fieldTheme),
  ]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('skill composition: $name at $scale', (tester) async {
        tester.view.physicalSize = const Size(412, 1600);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        var open = false;
        var known = false;
        var siteTaps = 0;
        var nightTaps = 0;
        var plannerTaps = 0;
        late StateSetter change;
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            ),
            home: StatefulBuilder(
              builder: (context, setState) {
                change = setState;
                return Scaffold(
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ContextLine(
                          siteName: 'Kyiv outskirts',
                          night: CalendarDate(2026, 10, 19),
                          framed: true,
                          onSite: () => siteTaps++,
                          onNight: () => nightTaps++,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const PlanStateLabel(PlanState.savedChanged),
                        const SizedBox(height: AppSpacing.sm),
                        StatusBlock(
                          state: known ? FitState.fits : FitState.needsInput,
                          missing: 'Needs a target',
                          needed: known ? const Duration(hours: 2) : null,
                          usable: known ? const Duration(hours: 4) : null,
                          reason: known
                              ? 'The plan fits the available window.'
                              : 'Choose a target before calculating fit.',
                          action: OutlinedButton(
                            onPressed: () => plannerTaps++,
                            child: const Text('Open planner'),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        CollapsibleSection(
                          sectionKey: 'skillTrial.details',
                          title: 'Plan details',
                          summary: 'Demonstration inputs',
                          open: open,
                          onToggle: () => setState(() => open = !open),
                          child: const Text(
                            'No forecast or science is computed.',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
        expect(find.byType(ContextLine), findsOneWidget);
        expect(find.byType(StatusBlock), findsOneWidget);
        expect(find.byType(CollapsibleSection), findsOneWidget);
        expect(find.text('Saved · changed'), findsOneWidget);
        expect(find.text('Needs a target'), findsOneWidget);
        expect(find.textContaining('0 min'), findsNothing);
        expect(find.text('No forecast or science is computed.'), findsNothing);
        final statusText = tester.widget<Text>(find.text('Needs a target'));
        expect(
          statusText.style!.color,
          theme.extension<AppPalette>()!.statusNeutral,
        );
        await tester.tap(find.byKey(const Key('context.site')));
        await tester.tap(find.byKey(const Key('context.night')));
        expect((siteTaps, nightTaps), (1, 1));
        await tester.ensureVisible(find.text('Open planner'));
        await tester.tap(find.text('Open planner'));
        expect(plannerTaps, 1);
        await tester.ensureVisible(find.text('Plan details'));
        await tester.tap(find.text('Plan details'));
        await tester.pumpAndSettle();
        expect(
          find.text('No forecast or science is computed.'),
          findsOneWidget,
        );
        expect(find.text('Demonstration inputs'), findsOneWidget);
        change(() => known = true);
        await tester.pumpAndSettle();
        const verdict = 'Fits: 2 h needed of 4 h usable';
        expect(find.text(verdict), findsOneWidget);
        expect(find.text('Saved · changed'), findsOneWidget);
        final measured = tester.widget<Text>(find.text(verdict));
        expect(
          measured.style!.color,
          theme.extension<AppPalette>()!.statusFits,
        );
        expect(tester.takeException(), isNull);
      });
    }
  }
}
