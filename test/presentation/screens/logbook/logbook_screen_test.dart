// The Logbook list (S8.5; ADR-019 §2, §8, §10; UX-30; 08 §24): saved plans
// and results, never drafts, each with its state; Upcoming and Past; a
// search over the target, the site and the notes; the filters in one panel,
// kept by the ViewModel, combining with the search; delete after a
// confirmation (S5.8); Progress by target at the top. Hybrid (owner sketch
// 2026-10-21): one list grouped by month, the filters behind the button in
// the search field. (Since TASK 4.2 and 11.3 in earlier forms.)

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/domain/repositories/session_repository.dart';
import 'package:astroplan/presentation/screens/logbook/logbook_screen.dart';
import 'package:astroplan/presentation/viewmodels/library_viewmodels.dart';
import 'package:astroplan/presentation/viewmodels/session_plan_viewmodel.dart';
import 'package:astroplan/presentation/viewmodels/theme_viewmodel.dart';

import '../../../support/in_memory_display_preferences.dart';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _MockSessionPlanViewModel extends ChangeNotifier
    implements SessionPlanViewModel {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late AppDatabase db;
  late DriftSessionRepository repo;
  late SessionsViewModel vm;

  Widget wrap() => MultiProvider(
    providers: [
      Provider<SessionRepository>.value(value: repo),
      ChangeNotifierProvider.value(value: vm),
      ChangeNotifierProvider(
        create: (_) => ThemeViewModel(InMemoryDisplayPreferences()),
      ),
      ChangeNotifierProvider<SessionPlanViewModel>(
        create: (_) => _MockSessionPlanViewModel(),
      ),
    ],
    child: const MaterialApp(home: LogbookScreen()),
  );

  /// Rows written directly: a legacy log (M31), a Saved plan ahead (M42),
  /// a completed result with notes (M45, Home), a draft never saved (M1).
  /// Today is 31 Dec 2025.
  Future<void> seed(WidgetTester tester) => tester.runAsync(() async {
    db = AppDatabase(NativeDatabase.memory());
    final today = FixedClock(DateTime.utc(2025, 12, 31, 18));
    repo = DriftSessionRepository(db, clock: today);
    vm = SessionsViewModel(repo, clock: today);
    await db.customStatement(
      "INSERT INTO session_logs (id, target_name, equipment_name, "
      "session_date, planned_light_frames, status, legacy, evening_date, "
      "location_name, environmental_notes) VALUES "
      "(1, 'M31', 'Rig', 1767225600, 10, 'completed', 1, NULL, NULL, NULL), "
      "(2, 'M42', 'Rig', 1767225600, 10, 'planned', 0, '2026-01-01', "
      "'Dark Site', NULL), "
      "(3, 'M45', 'Rig', 1767225600, 10, 'completed', 0, '2025-12-20', "
      "'Home', 'Dew on the lens at 2 am'), "
      "(4, 'M1', 'Rig', 1767225600, 10, 'draft', 0, '2026-01-01', NULL, "
      "NULL);",
    );
  });

  Future<int> rows(WidgetTester tester) async =>
      (await tester.runAsync(() => db.select(db.sessionLogs).get()))!.length;

  tearDown(() async => db.close());

  Future<void> pumpList(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(wrap());
    await settle(tester);
  }

  Finder title(int id) => find.byKey(Key('logbook.title.$id'));

  // Owner sketch 2026-10-21 (logbook.js renderResults): one list, newest
  // night first, grouped by month only.
  testWidgets('saved entries and old logs are listed with their state, '
      'newest night first under their month; drafts are not', (tester) async {
    await seed(tester);
    await pumpList(tester);

    expect(find.text('Logbook'), findsOneWidget);
    expect(find.byKey(const Key('logbook.progress')), findsOneWidget);
    expect(title(1), findsOneWidget);
    expect(title(2), findsOneWidget);
    expect(title(3), findsOneWidget);
    expect(title(4), findsNothing);
    expect(
      find.descendant(
        of: find.byKey(const Key('logbook.status.1')),
        matching: find.text('Old log'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('logbook.status.2')),
        matching: find.text('Saved'),
      ),
      findsOneWidget,
    );
    final january = tester.getTopLeft(find.text('January 2026'));
    final december = tester.getTopLeft(find.text('December 2025'));
    expect(
      tester.getTopLeft(title(2)).dy,
      inExclusiveRange(january.dy, december.dy),
    );
    expect(tester.getTopLeft(title(3)).dy, greaterThan(december.dy));
    expect(find.byKey(const Key('logbook.upcoming')), findsNothing);
    expect(find.textContaining('Legacy'), findsNothing);
    expect(find.textContaining('Draft'), findsNothing);
  });

  testWidgets('search finds the target, the site and the notes; nothing '
      'matching says so', (tester) async {
    await seed(tester);
    await pumpList(tester);
    await tester.tap(find.byKey(const Key('logbook.searchToggle')));
    await tester.pump();

    await tester.enterText(find.byKey(const Key('logbook.search')), 'm42');
    await settle(tester);
    expect(title(2), findsOneWidget);
    expect(title(3), findsNothing);

    await tester.enterText(find.byKey(const Key('logbook.search')), 'dew');
    await settle(tester);
    expect(title(3), findsOneWidget);
    expect(title(2), findsNothing);

    await tester.enterText(find.byKey(const Key('logbook.search')), 'home');
    await settle(tester);
    expect(title(3), findsOneWidget);

    await tester.enterText(find.byKey(const Key('logbook.search')), 'xyz');
    await settle(tester);
    expect(find.byKey(const Key('logbook.empty')), findsOneWidget);

    await tester.tap(find.byKey(const Key('logbook.searchToggle')));
    await settle(tester);
    expect(
      title(1),
      findsOneWidget,
      reason: 'clearing the visible search restores all rows',
    );
  });

  testWidgets('the filters sit in one panel; they combine with the search, '
      'show a count, survive a rebuild and clear', (tester) async {
    await seed(tester);
    await pumpList(tester);
    await tester.tap(find.byKey(const Key('logbook.filterToggle')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('logbook.filter.completed')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('logbook.filterToggle')));
    await settle(tester);
    expect(find.byKey(const Key('logbook.filters')), findsNothing);

    expect(title(2), findsNothing, reason: 'Saved is filtered out');
    expect(title(3), findsOneWidget);
    expect(title(1), findsOneWidget, reason: 'an old log counts as completed');
    // The count rides on the Filters button.
    expect(
      find.descendant(
        of: find.byKey(const Key('logbook.filterCount')),
        matching: find.text('1'),
      ),
      findsOneWidget,
    );
    expect(find.text('2 of 3 entries'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('logbook.search')), 'm45');
    await settle(tester);
    expect(title(1), findsNothing);
    expect(title(3), findsOneWidget);

    // Another visit (a new screen) keeps both, as the tab's state does.
    await tester.pumpWidget(const SizedBox());
    await pumpList(tester);
    expect(title(1), findsNothing);
    expect(title(3), findsOneWidget);
    expect(vm.filter.count, 1);

    await tester.tap(find.byKey(const Key('logbook.filterToggle')));
    await settle(tester);
    await tester.ensureVisible(find.byKey(const Key('logbook.filters.clear')));
    await tester.tap(find.byKey(const Key('logbook.filters.clear')));
    await settle(tester);
    expect(vm.filter.isEmpty, isTrue);
    expect(title(3), findsOneWidget);
  });

  testWidgets(
    'visible search keeps its caret and focus while the result count updates',
    (tester) async {
      await seed(tester);
      await pumpList(tester);
      final search = find.byKey(const Key('logbook.search'));
      expect(search, findsOneWidget);
      expect(find.text('3 entries'), findsOneWidget);
      await tester.tap(search);
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: 'M42',
          selection: TextSelection.collapsed(offset: 1),
        ),
      );
      await settle(tester);
      final field = tester.widget<TextField>(search);
      expect(field.controller!.selection.baseOffset, 1);
      expect(field.focusNode!.hasFocus, isTrue);
      expect(find.text('1 of 3 entries'), findsOneWidget);
      expect(title(2), findsOneWidget);
      await tester.tap(find.byKey(const Key('logbook.searchToggle')));
      await settle(tester);
      expect(find.text('3 entries'), findsOneWidget);
      expect(field.focusNode!.hasFocus, isTrue);
      await tester.tap(find.byKey(const Key('logbook.filterToggle')));
      await settle(tester);
      expect(find.byType(BottomSheet), findsNothing);
      expect(find.byKey(const Key('logbook.filter.completed')), findsOneWidget);
      await tester.tap(find.byKey(const Key('logbook.filterToggle')));
      await settle(tester);
      expect(find.byKey(const Key('logbook.filter.completed')), findsNothing);
    },
  );

  testWidgets('a swipe asks before deleting; Cancel keeps the entry', (
    tester,
  ) async {
    await seed(tester);
    await pumpList(tester);
    await tester.drag(title(2), const Offset(-500, 0));
    await settle(tester);
    expect(find.text('Delete this entry?'), findsOneWidget);
    expect(await rows(tester), 4);
    await tester.tap(find.text('Cancel'));
    await settle(tester);
    expect(await rows(tester), 4);
    expect(title(2), findsOneWidget);
  });

  testWidgets('confirming deletes the entry', (tester) async {
    await seed(tester);
    await pumpList(tester);
    await tester.drag(title(2), const Offset(-500, 0));
    await settle(tester);
    await tester.tap(find.byKey(const Key('confirm.action')));
    await settle(tester);
    expect(await rows(tester), 3);
    expect(title(2), findsNothing);
  });
}

/// Pumps fixed frames with real-time gaps (database work).
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump(const Duration(milliseconds: 200));
  }
}
