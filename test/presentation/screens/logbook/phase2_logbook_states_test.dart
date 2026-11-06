import 'dart:async';

import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/session.dart';
import 'package:astroplan/domain/services/session_reconciliation.dart';
import 'package:astroplan/presentation/screens/logbook/logbook_screen.dart';
import 'package:astroplan/presentation/screens/logbook/session_detail_screen.dart';
import 'package:astroplan/presentation/viewmodels/library_viewmodels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../../support/phase2_state_capture.dart';
import '../../../support/wave1_capture.dart' show loadWave1Font;

class _Sessions extends ChangeNotifier implements SessionsViewModel {
  final reads = <Completer<List<Session>>>[];
  final details = <Completer<SessionDetail?>>[];
  SessionFilter currentFilter = const SessionFilter();
  String currentQuery = '';
  @override
  SessionFilter get filter => currentFilter;
  @override
  String get query => currentQuery;
  @override
  int get revision => 0;
  @override
  bool get canExport => false;
  @override
  void setQuery(String value) {
    currentQuery = value;
    notifyListeners();
  }

  @override
  void setFilter(SessionFilter value) {
    currentFilter = value;
    notifyListeners();
  }

  @override
  List<Session> searched(List<Session> list) => list;
  @override
  Future<List<Session>> saved([SessionFilter filter = const SessionFilter()]) {
    final read = Completer<List<Session>>();
    reads.add(read);
    return read.future;
  }

  @override
  Future<Map<int, SessionReconciliation>> reconciliations(
    List<Session> sessions,
  ) async => {};
  @override
  Future<({Map<int, String> targets, Map<int, String> sites})>
  filterOptions() async => (targets: <int, String>{}, sites: <int, String>{});
  @override
  Future<SessionDetail?> detail(int id) {
    final read = Completer<SessionDetail?>();
    details.add(read);
    return read.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(loadWave1Font);
  for (final theme in ['light', 'dark', 'field']) {
    Future<void> mount(WidgetTester t, _Sessions vm, Widget screen) async {
      t.view.physicalSize = const Size(375, 812);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      addTearDown(vm.dispose);
      await t.pumpWidget(
        ChangeNotifierProvider<SessionsViewModel>.value(
          value: vm,
          child: MaterialApp(
            theme: phase2Theme(theme),
            builder: (_, child) => phase2Frame(theme: theme, child: child!),
            home: screen,
          ),
        ),
      );
      await t.pump();
    }

    Future<void> capture(WidgetTester t, String state) =>
        capturePhase2State(t, package: 'package2', state: state, theme: theme);

    testWidgets('$theme Logbook loading/error/retry/empty', (t) async {
      final vm = _Sessions();
      await mount(t, vm, const LogbookScreen());
      expect(find.text('Loading Logbook…'), findsOneWidget);
      await capture(t, 'logbook-pending');
      vm.reads.single.completeError(StateError('private marker'));
      await t.pumpAndSettle();
      expect(find.text('Retry'), findsOneWidget);
      expect(find.textContaining('private marker'), findsNothing);
      await capture(t, 'logbook-error');
      await t.tap(find.text('Retry'));
      await t.pump();
      expect(find.text('Loading Logbook…'), findsOneWidget);
      await capture(t, 'logbook-retry-pending');
      vm.reads.last.complete([]);
      await t.pumpAndSettle();
      expect(find.byKey(const Key('logbook.openPlanner')), findsOneWidget);
      expect(find.byKey(const Key('logbook.clearAll')), findsNothing);
      await capture(t, 'logbook-empty');
      await t.enterText(find.byKey(const Key('logbook.search')), 'missing');
      await t.pumpAndSettle();
      expect(find.byKey(const Key('logbook.clearAll')), findsOneWidget);
      expect(
        find.text('Nothing matches the search or the filters.'),
        findsOneWidget,
      );
      await capture(t, 'logbook-search-empty');
      await t.tap(find.byKey(const Key('logbook.clearAll')));
      await t.pump();
      vm.reads.last.complete([]);
      await t.pumpAndSettle();
      expect(vm.query, isEmpty);
      expect(vm.filter.isEmpty, isTrue);
      expect(find.byKey(const Key('logbook.openPlanner')), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('$theme Logbook combined statuses and inverted night range', (
      t,
    ) async {
      final vm = _Sessions()
        ..currentFilter = SessionFilter(
          statuses: {SessionListStatus.planned, SessionListStatus.completed},
          from: CalendarDate(2026, 11, 9),
          to: CalendarDate(2026, 11, 1),
        );
      await mount(t, vm, const LogbookScreen());
      vm.reads.single.complete([]);
      await t.pump();
      await t.pump();
      // The narrowed list requests a separate unfiltered count.
      if (vm.reads.length > 1) vm.reads.last.complete([]);
      await t.pumpAndSettle();
      await t.tap(find.byKey(const Key('logbook.filterToggle')));
      await t.pumpAndSettle();
      await t.scrollUntilVisible(
        find.byKey(const Key('logbook.filter.dates')),
        250,
        scrollable: find
            .descendant(
              of: find.byType(CustomScrollView),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await t.pumpAndSettle();
      expect(
        find.byKey(const Key('logbook.filter.rangeError')),
        findsOneWidget,
      );
      expect(vm.filter.statuses, hasLength(2));
      await t.ensureVisible(find.byKey(const Key('logbook.filter.rangeError')));
      await t.pumpAndSettle();
      await capture(t, 'logbook-multiselect-inverted-range');
      expect(t.takeException(), isNull);
    });

    testWidgets('$theme detail pending/error/retry/missing', (t) async {
      final vm = _Sessions();
      await mount(t, vm, const SessionDetailScreen(sessionId: 99));
      expect(find.text('Loading saved entry…'), findsOneWidget);
      await capture(t, 'detail-pending');
      vm.details.single.completeError(StateError('private marker'));
      await t.pumpAndSettle();
      expect(find.text('Retry'), findsOneWidget);
      await capture(t, 'detail-error');
      await t.tap(find.text('Retry'));
      await t.pump();
      expect(find.text('Loading saved entry…'), findsOneWidget);
      await capture(t, 'detail-retry-pending');
      vm.details.last.complete(null);
      await t.pumpAndSettle();
      expect(find.text('This entry no longer exists.'), findsOneWidget);
      expect(find.text('Retry'), findsNothing);
      await capture(t, 'detail-missing');
      expect(t.takeException(), isNull);
    });
  }
}
