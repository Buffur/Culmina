// Uses actual LogbookScreen and the existing synthetic Hybrid fixture.
import 'dart:async';

import 'package:astroplan/core/theme/app_theme.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/domain/models/session.dart';
import 'package:astroplan/domain/services/result_action.dart';
import 'package:astroplan/domain/services/session_reconciliation.dart';
import 'package:astroplan/presentation/screens/execution/results_screen.dart';
import 'package:astroplan/presentation/screens/logbook/logbook_screen.dart';
import 'package:astroplan/presentation/viewmodels/library_viewmodels.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../../support/hybrid_transfer_fixture.dart';

typedef _Options = ({Map<int, String> targets, Map<int, String> sites});

class _HeldSessions extends ChangeNotifier implements SessionsViewModel {
  _HeldSessions(this.delegate);
  final SessionsViewModel delegate;
  final reads = <Completer<List<Session>>>[];
  final reconciliationsReads = <Completer<Map<int, SessionReconciliation>>>[];
  final optionsReads = <Completer<_Options>>[];
  int _revision = 0;

  @override
  int get revision => _revision;
  @override
  void markChanged() {
    _revision++;
    notifyListeners();
  }

  @override
  SessionFilter get filter => const SessionFilter();
  @override
  String get query => '';
  @override
  bool get canExport => false;
  @override
  List<Session> searched(List<Session> sessions) => sessions;
  @override
  ResultAction resultAction(Session session) => delegate.resultAction(session);

  @override
  Future<List<Session>> saved([SessionFilter filter = const SessionFilter()]) {
    final pending = Completer<List<Session>>();
    reads.add(pending);
    return pending.future;
  }

  @override
  Future<Map<int, SessionReconciliation>> reconciliations(
    List<Session> sessions,
  ) {
    final pending = Completer<Map<int, SessionReconciliation>>();
    reconciliationsReads.add(pending);
    return pending.future;
  }

  @override
  Future<_Options> filterOptions() {
    final pending = Completer<_Options>();
    optionsReads.add(pending);
    return pending.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('late Logbook A cannot replace newer B companion data', (
    t,
  ) async {
    late AppDatabase db;
    late HybridTransferFixture fixture;
    late SessionsViewModel real;
    late Session a;
    late Session b;
    late Map<int, SessionReconciliation> actualResults;
    await t.runAsync(() async {
      db = AppDatabase(NativeDatabase.memory());
      fixture = await HybridTransferFixture.create(db);
      await fixture.seedLogbook();
      real = SessionsViewModel(fixture.sessions);
      final completed = (await real.saved())
          .where((s) => !s.legacy && s.status == SessionStatus.completed)
          .toList();
      a = completed.first;
      b = completed.firstWhere((s) => s.targetId != a.targetId);
      actualResults = await real.reconciliations([a, b]);
    });
    addTearDown(() => t.runAsync(db.close));
    final held = _HeldSessions(real);
    addTearDown(held.dispose);
    addTearDown(real.dispose);
    t.view.physicalSize = const Size(412, 1400);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);

    Future<void> flush() async {
      for (var i = 0; i < 4; i++) {
        await t.pump();
      }
    }

    await t.pumpWidget(
      MultiProvider(
        providers: [
          ...fixture.vm.providers,
          ChangeNotifierProvider<SessionsViewModel>.value(value: held),
        ],
        child: MaterialApp(theme: AppTheme.dark, home: const LogbookScreen()),
      ),
    );
    await flush();
    expect(held.reads, hasLength(1));

    // A begins first. Its reconciliation resolves and its filter-options
    // request starts before B exists, representing the earlier snapshot.
    held.reads[0].complete([a]);
    await flush();
    expect(held.reconciliationsReads, hasLength(1));
    held.reconciliationsReads[0].complete({a.id: actualResults[a.id]!});
    await flush();
    expect(held.optionsReads, hasLength(1));

    // Real screen revision handling starts B; B completes first.
    held.markChanged();
    await flush();
    expect(held.reads, hasLength(2));
    held.reads[1].complete([b]);
    await flush();
    expect(held.reconciliationsReads, hasLength(2));
    held.reconciliationsReads[1].complete({b.id: actualResults[b.id]!});
    await flush();
    expect(held.optionsReads, hasLength(2));
    held.optionsReads[1].complete((
      targets: {b.targetId!: b.record.targetName},
      sites: const <int, String>{},
    ));
    await flush();
    final bTitle = find.byKey(Key('logbook.title.${b.id}'));
    final bIntegration = find.byKey(Key('logbook.integration.${b.id}'));
    expect(bTitle, findsOneWidget);
    expect(bIntegration, findsOneWidget);
    expect(
      t.widget<Text>(bIntegration).data,
      ResultsText.integration(actualResults[b.id]!),
    );
    await t.tap(find.byKey(const Key('logbook.filterToggle')));
    await flush();
    final beforeDropdown = t.widget<DropdownButton<int>>(
      find.descendant(
        of: find.byKey(const Key('logbook.filter.target')),
        matching: find.byType(DropdownButton<int>),
      ),
    );
    expect(
      beforeDropdown.items!.map((item) => item.value),
      contains(b.targetId),
    );
    expect(
      beforeDropdown.items!.map((item) => item.value),
      isNot(contains(a.targetId)),
    );
    await t.tap(find.byKey(const Key('logbook.filterToggle')));
    await flush();

    // The earlier in-flight A options request now resolves with its earlier
    // snapshot. Both its obsolete list and its companion data must be ignored.
    held.optionsReads[0].complete((
      targets: {a.targetId!: a.record.targetName},
      sites: const <int, String>{},
    ));
    await flush();
    expect(bTitle, findsOneWidget, reason: 'B remains the latest visible list');
    expect(find.byKey(Key('logbook.title.${a.id}')), findsNothing);
    expect(
      bIntegration,
      findsOneWidget,
      reason: 'The newer B reconciliation remains bound to the visible B list',
    );
    expect(
      t.widget<Text>(bIntegration).data,
      ResultsText.integration(actualResults[b.id]!),
    );

    // Filter choices must remain part of B's published data bundle too.
    await t.tap(find.byKey(const Key('logbook.filterToggle')));
    await flush();
    final dropdown = t.widget<DropdownButton<int>>(
      find.descendant(
        of: find.byKey(const Key('logbook.filter.target')),
        matching: find.byType(DropdownButton<int>),
      ),
    );
    expect(
      dropdown.items!.map((item) => item.value),
      isNot(contains(a.targetId)),
    );
    expect(
      dropdown.items!.map((item) => item.value),
      contains(b.targetId),
      reason: 'The newer B options remain bound to the visible B list',
    );

    await t.pumpWidget(const SizedBox.shrink());
  });
}
