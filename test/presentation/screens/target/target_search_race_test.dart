// F24 A6 (UX32-03, AM-02): target search answers only the newest query.
// Reproduction first: before F24 a late answer to an older query replaced
// the newer list (and an older failure the newer success), and the older
// list stayed on screen under the newer text while it ran. Every answer here
// is completed by hand, in reverse order, so the outcome is deterministic.

import 'dart:async';

import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/domain/repositories/target_repository.dart';
import 'package:astroplan/presentation/screens/target/target_selection_screen.dart';
import 'package:astroplan/presentation/shared/list_mode.dart';
import 'package:astroplan/presentation/viewmodels/library_viewmodels.dart';
import 'package:astroplan/presentation/viewmodels/session_plan_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Each search waits until the test completes it.
class _HeldSearches implements TargetRepository {
  final pending = <String, List<Completer<List<AstroTarget>>>>{};

  @override
  Future<List<AstroTarget>> searchTargets(String query) {
    final c = Completer<List<AstroTarget>>();
    pending.putIfAbsent(query, () => []).add(c);
    return c.future;
  }

  void answer(String query, List<AstroTarget> targets) =>
      pending[query]!.removeAt(0).complete(targets);

  void fail(String query) =>
      pending[query]!.removeAt(0).completeError(StateError('db gone'));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Plan extends ChangeNotifier implements SessionPlanViewModel {
  AstroTarget? chosen;

  @override
  AstroTarget? get selectedTarget => chosen;

  @override
  Future<void> setTarget(AstroTarget target) async => chosen = target;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

AstroTarget _t(int id, String name) => AstroTarget(
  id: id,
  catalogId: 'C$id',
  commonName: name,
  rightAscension: 10,
  declination: 41,
  type: 'Galaxy',
);

final _andromeda = _t(1, 'Andromeda');
final _orion = _t(2, 'Orion Nebula');

void main() {
  late _HeldSearches repo;
  late _Plan plan;

  Future<void> start(
    WidgetTester tester, {
    ListMode mode = ListMode.choose,
  }) async {
    repo = _HeldSearches();
    plan = _Plan();
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, _) => Scaffold(
            body: TextButton(
              onPressed: () => context.push('/select'),
              child: const Text('open'),
            ),
          ),
        ),
        GoRoute(
          path: '/select',
          builder: (_, _) => TargetSelectionScreen(mode: mode),
        ),
      ],
    );
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TargetsViewModel(repo)),
          ChangeNotifierProvider<SessionPlanViewModel>.value(value: plan),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.tap(find.text('open'));
    // The first search is held: its spinner never settles.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    repo.answer('', [_andromeda, _orion]);
    await tester.pumpAndSettle();
  }

  Future<void> type(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    await tester.pump();
  }

  testWidgets('a late answer to an older query never replaces the newer list', (
    tester,
  ) async {
    await start(tester);
    await type(tester, 'And');
    await type(tester, 'Ori');
    repo.answer('Ori', [_orion]);
    await tester.pump();
    expect(find.text('Orion Nebula (C2)'), findsOneWidget);
    repo.answer('And', [_andromeda]); // late, older
    await tester.pump();
    expect(find.text('Orion Nebula (C2)'), findsOneWidget);
    expect(find.text('Andromeda (C1)'), findsNothing);
  });

  testWidgets('a late failure of an older query is ignored', (tester) async {
    await start(tester);
    await type(tester, 'And');
    await type(tester, 'Ori');
    repo.answer('Ori', [_orion]);
    await tester.pump();
    repo.fail('And');
    await tester.pump();
    expect(find.byKey(const Key('loadFailure.message')), findsNothing);
    expect(find.text('Orion Nebula (C2)'), findsOneWidget);
  });

  testWidgets('the newest query failing is shown, not an older success', (
    tester,
  ) async {
    await start(tester);
    await type(tester, 'And');
    await type(tester, 'Ori');
    repo.fail('Ori');
    await tester.pump();
    repo.answer('And', [_andromeda]);
    await tester.pump();
    expect(find.byKey(const Key('loadFailure.message')), findsOneWidget);
    expect(find.text('Andromeda (C1)'), findsNothing);
  });

  testWidgets('while the newer search runs, the older list is not shown '
      'under the newer text', (tester) async {
    await start(tester);
    await type(tester, 'And');
    repo.answer('And', [_andromeda]);
    await tester.pump();
    expect(find.text('Andromeda (C1)'), findsOneWidget);
    await type(tester, 'Andx');
    expect(find.text('Andromeda (C1)'), findsNothing);
    expect(find.byKey(const Key('targets.searching')), findsOneWidget);
    repo.answer('Andx', const []);
    await tester.pump();
    expect(find.text('No results for "Andx".'), findsOneWidget);
  });

  testWidgets('clearing the query: a late answer for the old text is ignored', (
    tester,
  ) async {
    await start(tester);
    await type(tester, 'Ori');
    await type(tester, '');
    repo.answer('', [_andromeda, _orion]);
    await tester.pump();
    repo.answer('Ori', [_orion]);
    await tester.pump();
    expect(find.text('Andromeda (C1)'), findsOneWidget);
    expect(find.text('Orion Nebula (C2)'), findsOneWidget);
  });

  testWidgets('choosing picks from the newest list; an answer after leaving '
      'changes nothing', (tester) async {
    await start(tester);
    await type(tester, 'And');
    await type(tester, 'Ori');
    repo.answer('Ori', [_orion]);
    await tester.pump();
    await tester.tap(find.text('Orion Nebula (C2)'));
    await tester.pumpAndSettle();
    expect(plan.chosen, _orion);
    expect(find.byType(TargetSelectionScreen), findsNothing);
    repo.answer('And', [_andromeda]); // after the screen is gone
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(plan.chosen, _orion);
  });

  // F24 A6: the same rule in the Library's manage mode, where a tap opens
  // the target's editor instead of choosing it.
  testWidgets('manage mode (Library targets): a late older answer never '
      'replaces the newer list; a tap edits the newest list\'s target', (
    tester,
  ) async {
    await start(tester, mode: ListMode.manage);
    expect(find.byIcon(Icons.chevron_right), findsNWidgets(2));
    await type(tester, 'And');
    await type(tester, 'Ori');
    expect(find.byKey(const Key('targets.searching')), findsOneWidget);
    repo.answer('Ori', [_orion]);
    await tester.pump();
    repo.answer('And', [_andromeda]); // late, older
    await tester.pump();
    expect(find.text('Orion Nebula (C2)'), findsOneWidget);
    expect(find.text('Andromeda (C1)'), findsNothing);
    await tester.tap(find.text('Orion Nebula (C2)'));
    await tester.pumpAndSettle();
    expect(find.text('Catalog ID: C2'), findsOneWidget);
    expect(plan.chosen, isNull, reason: 'managing never chooses');
  });

  testWidgets('manage mode: a late failure of an older query is ignored', (
    tester,
  ) async {
    await start(tester, mode: ListMode.manage);
    await type(tester, 'And');
    await type(tester, 'Ori');
    repo.answer('Ori', [_orion]);
    await tester.pump();
    repo.fail('And');
    await tester.pump();
    expect(find.byKey(const Key('loadFailure.message')), findsNothing);
    expect(find.text('Orion Nebula (C2)'), findsOneWidget);
  });

  testWidgets('an empty newest answer stays empty when an older one with '
      'results arrives late', (tester) async {
    await start(tester);
    await type(tester, 'And');
    await type(tester, 'Andx');
    repo.answer('Andx', const []);
    await tester.pump();
    expect(find.text('No results for "Andx".'), findsOneWidget);
    repo.answer('And', [_andromeda]); // late, older, not empty
    await tester.pump();
    expect(find.text('No results for "Andx".'), findsOneWidget);
    expect(find.text('Andromeda (C1)'), findsNothing);
  });

  testWidgets('an empty older answer arriving late never empties the newer '
      'list', (tester) async {
    await start(tester, mode: ListMode.manage);
    await type(tester, 'Orx');
    await type(tester, 'Ori');
    repo.answer('Ori', [_orion]);
    await tester.pump();
    repo.answer('Orx', const []); // late, older, empty
    await tester.pump();
    expect(find.text('Orion Nebula (C2)'), findsOneWidget);
    expect(find.text('No results for "Orx".'), findsNothing);
    expect(find.textContaining('No results'), findsNothing);
  });
}
