// Shared frame steps for the Hybrid transfer's host renders and Android
// captures (2026-10-22). Each step reaches its state from Tonight through
// the real router and widgets. Test-only.
import 'dart:async';

import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'hybrid_transfer_fixture.dart';

Future<void> hybridSettle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// One frame: a name and the steps that reach it from Tonight.
typedef HybridStep = Future<void> Function(HybridRenderContext c);

class HybridRenderContext {
  HybridRenderContext(this.tester, this.fixture);
  final WidgetTester tester;
  final HybridTransferFixture fixture;

  Future<void> settle() => hybridSettle(tester);

  Future<void> go(String route) async {
    AppRouter.router.go(route);
    await settle();
  }

  /// A detail route over Tonight, as the app opens it.
  Future<void> push(String route) async {
    AppRouter.router.go(AppRouter.tonight);
    await settle();
    unawaited(AppRouter.router.push(route));
    await settle();
  }

  Future<void> tap(Finder f) async {
    // A lazy list builds its rows near the viewport only: scroll the
    // page's main list until the target exists.
    if (f.evaluate().isEmpty) {
      await tester.scrollUntilVisible(
        f,
        300,
        scrollable: find
            .byWidgetPredicate(
              (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
            )
            .first,
      );
    }
    await tester.ensureVisible(f.first);
    await settle();
    await tester.tap(f.first);
    await settle();
  }

  Future<void> tapKey(String key) => tap(find.byKey(Key(key)));
  Future<void> tapText(String text) => tap(find.text(text));

  /// Scrolls the first scrollable of the current page by [dy].
  Future<void> scrollBy(double dy) async {
    final s = find.byType(Scrollable).last;
    tester
        .state<ScrollableState>(s)
        .position
        .jumpTo(tester.state<ScrollableState>(s).position.pixels + dy);
    await settle();
  }
}

final Map<String, HybridStep> hybridShots = {
  'home': (c) => c.go(AppRouter.tonight),
  'plan': (c) => c.push(AppRouter.session()),
  'night': (c) => c.push(AppRouter.nightMoon),
  'moon': (c) => c.push(AppRouter.moon),
  'weather': (c) => c.push(AppRouter.weather),
  'logbook': (c) => c.go(AppRouter.sessions),
  'library': (c) => c.go(AppRouter.library),
  'settings': (c) => c.go(AppRouter.settings),
  'plan_editor': (c) async {
    await c.push(AppRouter.session());
    await c.tapKey('capture.edit.0');
  },
  'plan_editor_dialog': (c) async {
    await c.push(AppRouter.session());
    await c.tapKey('capture.edit.0');
    await c.tester.enterText(find.byKey(const Key('blockDialog.count')), '121');
    await c.settle();
    await c.tapKey('blockDialog.cancel');
  },
  'plan_context': (c) async {
    await c.push(AppRouter.session());
    await c.tapKey('planner.context');
  },
};
