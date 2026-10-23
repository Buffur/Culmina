// Shared frame steps for the Hybrid transfer's host renders and Android
// captures (2026-10-22). Each step reaches its state from Tonight through
// the real router and widgets. Test-only.
import 'dart:async';

import 'package:astroplan/core/units/display_units.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/weather_snapshot.dart';
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
    // Pages pushed on the root navigator (Settings groups) sit above the
    // router's pages: close them first.
    tester
        .state<NavigatorState>(find.byType(Navigator).first)
        .popUntil((r) => r.isFirst);
    await settle();
    AppRouter.router.go(route);
    await settle();
  }

  /// A detail route over Tonight, as the app opens it.
  Future<void> push(String route) async {
    // Close pages a previous frame left open (an editor over the plan).
    tester
        .state<NavigatorState>(find.byType(Navigator).first)
        .popUntil((r) => r.isFirst);
    await settle();
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

  /// Scrolls the current page's last scrollable (or the one under [key])
  /// by [dy].
  Future<void> scrollBy(double dy, {String? key}) async {
    final s = key == null
        ? find.byType(Scrollable).last
        : find
              .descendant(
                of: find.byKey(Key(key)),
                matching: find.byType(Scrollable),
              )
              .first;
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
  'night_b': (c) async {
    await c.push(AppRouter.nightMoon);
    await c.scrollBy(700, key: 'conditions.page.0');
  },
  'night_c': (c) async {
    await c.push(AppRouter.nightMoon);
    await c.scrollBy(1400, key: 'conditions.page.0');
  },
  'night_reading_open': (c) async {
    await c.push(AppRouter.nightMoon);
    await c.tapKey('section.conditions.reading');
    await c.scrollBy(-200, key: 'conditions.page.0');
  },
  'night_moon_open': (c) async {
    await c.push(AppRouter.nightMoon);
    await c.tapKey('section.conditions.moonIntervals');
    await c.scrollBy(260, key: 'conditions.page.0');
  },
  'night_sun_open': (c) async {
    await c.push(AppRouter.nightMoon);
    await c.tapKey('section.conditions.sun');
    await c.scrollBy(340, key: 'conditions.page.0');
  },
  'night_exact_open': (c) async {
    await c.push(AppRouter.nightMoon);
    await c.tap(
      find.descendant(
        of: find.byKey(const Key('nightMoon.exactTimes')),
        matching: find.byType(InkWell),
      ),
    );
    await c.scrollBy(260, key: 'conditions.page.0');
  },
  'moon': (c) => c.push(AppRouter.moon),
  'moon_b': (c) async {
    await c.push(AppRouter.moon);
    await c.scrollBy(700, key: 'conditions.page.1');
  },
  'weather': (c) => c.push(AppRouter.weather),
  // conditions.js scenario=offline: a refresh that fails keeps the cached
  // snapshot, labelled.
  'weather_offline': (c) async {
    await c.push(AppRouter.weather);
    c.fixture.forecast.failure = WeatherFailure.unavailable;
    await c.tapKey('weather.refresh');
    c.fixture.forecast.failure = null;
    await c.scrollBy(-2000);
  },
  'home_candidates': (c) => c.push(AppRouter.candidates),
  'home_sitesheet': (c) async {
    await c.go(AppRouter.tonight);
    await c.tapKey('context.site');
  },
  'home_nightsheet': (c) async {
    await c.go(AppRouter.tonight);
    await c.tapKey('context.night');
  },
  // app.js `unknown`: the forecast failed; Home's Weather row says so.
  'home_wxfail': (c) async {
    await c.push(AppRouter.weather);
    c.fixture.forecast.failure = WeatherFailure.unavailable;
    await c.tapKey('weather.refresh');
    c.fixture.forecast.failure = null;
    await c.go(AppRouter.tonight);
    await c.scrollBy(1000);
  },
  // conditions.js `stale` / `partial` / `no-dark` (HT-W03).
  'weather_stale': (c) async {
    c.fixture.forecast.age = const Duration(hours: 30);
    await c.push(AppRouter.weather);
    await c.tapKey('weather.refresh');
    c.fixture.forecast.age = Duration.zero;
    await c.scrollBy(-2000);
  },
  'weather_partial': (c) async {
    c.fixture.forecast
      ..missingFirstHours = 9
      ..cloudGapEvery = 3;
    await c.push(AppRouter.weather);
    await c.tapKey('weather.refresh');
    c.fixture.forecast
      ..missingFirstHours = 0
      ..cloudGapEvery = 0;
    await c.scrollBy(-2000);
  },
  'weather_nodark': (c) async {
    // At 50.4° N the Sun stays above −18° around the June solstice.
    await c.tester.runAsync(
      () => c.fixture.vm.plan.setEveningDate(CalendarDate(2026, 6, 20)),
    );
    await c.push(AppRouter.weather);
  },
  'weather_charts': (c) async {
    await c.tester.runAsync(
      () => c.fixture.vm.vms.displaySettings.setWeatherView(WeatherView.charts),
    );
    await c.push(AppRouter.weather);
  },
  'weather_charts_b': (c) async {
    await c.tester.runAsync(
      () => c.fixture.vm.vms.displaySettings.setWeatherView(WeatherView.charts),
    );
    await c.push(AppRouter.weather);
    await c.scrollBy(700, key: 'conditions.page.2');
  },
  'weather_b': (c) async {
    await c.push(AppRouter.weather);
    await c.scrollBy(700, key: 'conditions.page.2');
  },
  'weather_c': (c) async {
    await c.push(AppRouter.weather);
    await c.scrollBy(1400, key: 'conditions.page.2');
  },
  'logbook': (c) async {
    await c.tester.runAsync(c.fixture.seedLogbook);
    await c.go(AppRouter.sessions);
  },
  'logbook_b': (c) async {
    await c.tester.runAsync(c.fixture.seedLogbook);
    await c.go(AppRouter.sessions);
    await c.scrollBy(650);
  },
  'logbook_filters': (c) async {
    await c.tester.runAsync(c.fixture.seedLogbook);
    await c.go(AppRouter.sessions);
    await c.tapKey('logbook.filterToggle');
  },
  for (final (name, entry, dy) in [
    ('entry', 'M31 2026-10-12', 0.0),
    ('entry_b', 'M31 2026-10-12', 650.0),
    ('entry_c', 'M31 2026-10-12', 1300.0),
    ('entry_due', 'M33 2026-10-15', 0.0),
  ])
    name: (c) async {
      await c.tester.runAsync(c.fixture.seedLogbook);
      await c.go(AppRouter.sessions);
      unawaited(
        AppRouter.router.push(
          AppRouter.sessionDetail(c.fixture.logbookIds[entry]!),
        ),
      );
      await c.settle();
      if (dy > 0) await c.scrollBy(dy);
    },
  for (final (name, dy) in [('result', 0.0), ('result_b', 650.0)])
    name: (c) async {
      await c.tester.runAsync(c.fixture.seedLogbook);
      await c.go(AppRouter.sessions);
      unawaited(
        AppRouter.router.push(
          AppRouter.results(c.fixture.logbookIds['M31 2026-10-12']!),
        ),
      );
      await c.settle();
      if (dy > 0) await c.scrollBy(dy, key: 'results.scroll');
    },
  'library': (c) async {
    await c.tester.runAsync(c.fixture.seedLogbook);
    await c.go(AppRouter.library);
  },
  for (final (name, route) in [
    ('lib_rigs', AppRouter.libraryRigs),
    ('lib_targets', AppRouter.libraryTargets),
    ('lib_sites', AppRouter.librarySites),
  ])
    name: (c) async {
      await c.tester.runAsync(c.fixture.seedLogbook);
      await c.go(AppRouter.library);
      unawaited(AppRouter.router.push(route));
      await c.settle();
    },
  'lib_rig': (c) async {
    await c.tester.runAsync(c.fixture.seedLogbook);
    await c.go(AppRouter.library);
    unawaited(AppRouter.router.push(AppRouter.libraryRigs));
    await c.settle();
    await c.tap(find.text('DSLR · 135 mm lens'));
  },
  'lib_target': (c) async {
    await c.tester.runAsync(c.fixture.seedLogbook);
    await c.go(AppRouter.library);
    unawaited(AppRouter.router.push(AppRouter.libraryTargets));
    await c.settle();
    await c.tap(find.text('Andromeda Galaxy (M31)'));
  },
  'lib_target_new': (c) async {
    await c.tester.runAsync(c.fixture.seedLogbook);
    await c.go(AppRouter.library);
    unawaited(AppRouter.router.push(AppRouter.libraryTargets));
    await c.settle();
    await c.tapKey('targets.add');
  },
  'lib_site': (c) async {
    await c.tester.runAsync(c.fixture.seedLogbook);
    await c.go(AppRouter.library);
    unawaited(AppRouter.router.push(AppRouter.librarySites));
    await c.settle();
    await c.tap(find.text('Kyiv outskirts'));
  },
  'lib_rig_edit': (c) async {
    await c.tester.runAsync(c.fixture.seedLogbook);
    await c.go(AppRouter.library);
    unawaited(AppRouter.router.push(AppRouter.libraryRigs));
    await c.settle();
    await c.tap(find.text('DSLR · 135 mm lens'));
    await c.tapKey('rigDetail.edit');
  },
  'lib_rig_delete': (c) async {
    await c.tester.runAsync(c.fixture.seedLogbook);
    await c.go(AppRouter.library);
    unawaited(AppRouter.router.push(AppRouter.libraryRigs));
    await c.settle();
    await c.tap(find.text('DSLR · 135 mm lens'));
    await c.tapKey('rigDetail.delete');
  },
  'lib_rig_unsaved': (c) async {
    await c.tester.runAsync(c.fixture.seedLogbook);
    await c.go(AppRouter.library);
    unawaited(AppRouter.router.push(AppRouter.libraryRigs));
    await c.settle();
    await c.tap(find.text('DSLR · 135 mm lens'));
    await c.tapKey('rigDetail.edit');
    await c.tester.enterText(find.byType(TextFormField).first, 'Changed rig');
    await c.settle();
    await c.tapKey('rigEditor.cancel');
  },
  'lib_site_edit': (c) async {
    await c.tester.runAsync(c.fixture.seedLogbook);
    await c.go(AppRouter.library);
    unawaited(AppRouter.router.push(AppRouter.librarySites));
    await c.settle();
    await c.tap(find.text('Kyiv outskirts'));
    await c.tapKey('siteDetail.edit');
  },
  'lib_rig_full': (c) async {
    await c.tester.runAsync(c.fixture.seedLogbook);
    await c.go(AppRouter.library);
    unawaited(AppRouter.router.push(AppRouter.libraryRigs));
    await c.settle();
    await c.tap(find.text('DSLR · 135 mm lens'));
    await c.tapText('Full rig record and sources');
    await c.scrollBy(-2000);
  },
  'settings': (c) => c.go(AppRouter.settings),
  'plan_editor': (c) async {
    await c.push(AppRouter.session());
    await c.tapKey('capture.edit.0');
  },
  'plan_editor_bottom': (c) async {
    await c.push(AppRouter.session());
    await c.tapKey('capture.edit.0');
    await c.scrollBy(2000, key: 'blockEditor.scroll');
  },
  'plan_editor_dialog': (c) async {
    await c.push(AppRouter.session());
    await c.tapKey('capture.edit.0');
    await c.tester.enterText(find.byKey(const Key('blockDialog.count')), '121');
    await c.settle();
    await c.tapKey('blockDialog.cancel');
  },
  // With ASTROPLAN_HYBRID_NOSITE=1 (a first install without a site).
  'home_nosite': (c) => c.go(AppRouter.tonight),
  'plan_cal': (c) async {
    await c.push(AppRouter.session());
    await c.tapKey('capturePlan.buildCalibration');
  },
  'plan_cal_b': (c) async {
    await c.push(AppRouter.session());
    await c.tapKey('capturePlan.buildCalibration');
    await c.scrollBy(4000, key: 'calibration.scroll');
  },
  'plan_asm': (c) async {
    await c.push(AppRouter.session());
    await _openAssumptions(c);
  },
  'plan_asm_b': (c) async {
    await c.push(AppRouter.session());
    await _openAssumptions(c);
    await c.scrollBy(2000, key: 'planOverride.scroll');
  },
  'plan_menu': (c) async {
    await c.push(AppRouter.session());
    await c.tapKey('planner.menu');
  },
  'plan_target': (c) async {
    await c.push(AppRouter.session());
    await c.tapKey('planner.target');
  },
  'plan_rig': (c) async {
    await c.push(AppRouter.session());
    await c.tapKey('planner.rig');
  },
  'plan_context': (c) async {
    await c.push(AppRouter.session());
    await c.tapKey('planner.context');
  },
  for (final page in ['appearance', 'planning', 'privacy', 'backup', 'about'])
    'settings_$page': (c) async {
      await c.go(AppRouter.settings);
      await c.tapKey('settings.open.$page');
    },
  for (final page in ['appearance', 'planning'])
    'settings_${page}_b': (c) async {
      await c.go(AppRouter.settings);
      await c.tapKey('settings.open.$page');
      await c.scrollBy(650);
    },
};

/// Plan › Budget and assumptions › Edit assumptions, from the plan's top;
/// the disclosure stays open between frames.
Future<void> _openAssumptions(HybridRenderContext c) async {
  await c.scrollBy(-10000);
  // The header says whether it is open (the list builds lazily).
  const header = Key('section.planner.budgetDetails');
  await c.tap(find.byKey(header));
  final open = c.tester.widget<Semantics>(find.byKey(header)).properties;
  if (open.expanded != true) await c.tap(find.byKey(header));
  await c.tapKey('planOverride.edit');
}
