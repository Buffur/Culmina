import 'package:astroplan/presentation/shared/async_state_view.dart';
import 'package:astroplan/core/theme/app_theme.dart';
import 'package:astroplan/presentation/shared/action_row.dart';
import 'package:astroplan/presentation/shared/fact_row.dart';
import 'package:astroplan/presentation/shared/search_filter_bar.dart';
import 'package:astroplan/presentation/shared/catalog_scaffold.dart';
import 'package:astroplan/presentation/shared/confirmation_patterns.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final scale in [1.0, 2.0]) {
    testWidgets('action, edit and filter stay reachable at $scale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearAllTestValues);
      final taps = <String>[];
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: CatalogScaffold(
            body: ListView(
              children: [
                ActionRow(
                  title: 'A complete long site name that wraps',
                  description: 'Unknown altitude and full source information remain readable.',
                  variant: ActionRowVariant.edit,
                  onTap: () => taps.add('select'),
                  onEdit: () => taps.add('edit'),
                ),
                SearchFilterBar(
                  onChanged: (v) => taps.add(v),
                  onFilter: () => taps.add('filter'),
                ),
              ],
            ),
            bottomAction: StickyBottomAction(
              child: FilledButton(
                onPressed: () => taps.add('apply'),
                child: const Text('Apply'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('A complete long site name that wraps'));
      await tester.tap(find.byTooltip('Edit'));
      await tester.enterText(find.byType(TextField), 'M31');
      await tester.tap(find.byTooltip('Filters'));
      await tester.tap(find.text('Apply'));
      expect(taps, ['select', 'edit', 'M31', 'filter', 'apply']);
      expect(
        tester.getSize(find.byTooltip('Edit')).height,
        greaterThanOrEqualTo(48),
      );
      expect(
        tester.getSize(find.byTooltip('Filters')).height,
        greaterThanOrEqualTo(48),
      );
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('short facts align right and long values grow below labels', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: SizedBox(
            width: 280,
            child: Column(
              children: const [
                FactRow(label: 'Duration', value: '2 h'),
                FactRow(
                  label: 'Source',
                  value: 'A full source description that requires more than one line and must remain visible',
                ),
              ],
            ),
          ),
        ),
      ),
    );
    expect(
      tester.getTopLeft(find.text('Duration')).dy,
      tester.getTopLeft(find.text('2 h')).dy,
    );
    expect(tester.getBottomRight(find.text('2 h')).dx, 280);
    expect(
      tester
          .getTopLeft(
            find.text(
              'A full source description that requires more than one line and must remain visible',
            ),
          )
          .dy,
      greaterThan(tester.getBottomLeft(find.text('Source')).dy),
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'dismissal is cancellation; destructive action remains explicit',
    (tester) async {
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  result = await confirmDestructive(
                    context,
                    title: 'Delete rig?',
                    message: 'Saved plans keep their values.',
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm.cancel')));
      await tester.pumpAndSettle();
      expect(result, false);
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm.action')));
      await tester.pumpAndSettle();
      expect(result, true);
    },
  );
  testWidgets('joined search contour displays focus without changing bounds', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(body: SearchFilterBar()),
      ),
    );
    final contour = find
        .descendant(
          of: find.byType(SearchFilterBar),
          matching: find.byType(DecoratedBox),
        )
        .first;
    final before = tester.getRect(contour);
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    final decoration =
        tester.widget<DecoratedBox>(contour).decoration as BoxDecoration;
    expect((decoration.border! as Border).top.color, AppTheme.dark.focusColor);
    expect((decoration.border! as Border).top.width, 2);
    expect(tester.getRect(contour), before);
  });
  testWidgets('asynchronous states keep loading, missing and retry distinct', (
    tester,
  ) async {
    var retries = 0;
    Future<void> show(Widget child) => tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(body: child),
      ),
    );
    await show(const AsyncStateView.loading(message: 'Loading records'));
    expect(find.text('Loading records'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await show(
      const AsyncStateView.empty(
        title: 'No records',
        message: 'Add a record to start.',
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Add a record to start.'), findsOneWidget);
    await show(
      AsyncStateView.error(
        title: 'Records unavailable',
        onRetry: () => retries++,
      ),
    );
    await tester.tap(find.text('Retry'));
    expect(retries, 1);
  });
}
