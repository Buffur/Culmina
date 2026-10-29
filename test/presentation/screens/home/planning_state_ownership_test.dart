import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:astroplan/domain/services/location_service.dart';
import 'package:astroplan/presentation/screens/details/night_moon_screen.dart';
import 'package:astroplan/presentation/screens/details/weather_detail_screen.dart';
import 'package:astroplan/presentation/screens/tonight/tonight_candidates_screen.dart';
import 'package:astroplan/presentation/shared/location_failure_text.dart';
import 'package:astroplan/presentation/shared/night_picker_dialog.dart';
import 'package:astroplan/presentation/viewmodels/night_browser_viewmodel.dart';

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/location_profile.dart';
import 'package:astroplan/domain/models/session.dart';
import 'package:astroplan/domain/models/target_alias.dart';
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:astroplan/presentation/screens/library/library_screen.dart';
import 'package:astroplan/presentation/screens/logbook/logbook_screen.dart';
import 'package:astroplan/presentation/screens/settings/settings_screen.dart';
import 'package:astroplan/presentation/screens/tonight/tonight_home_screen.dart';
import 'package:astroplan/presentation/shared/failure_feedback.dart';
import 'package:astroplan/presentation/shared/plan_state.dart';
import 'package:astroplan/presentation/viewmodels/library_viewmodels.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../../support/hybrid_transfer_fixture.dart';
import '../../../support/hybrid_transfer_shots.dart';
import '../../../support/sdk_fonts.dart';

class _TargetRead {
  _TargetRead(this.query);
  final String query;
  final result = Completer<List<AstroTarget>>();
}

class _ControlledTargets extends ChangeNotifier implements TargetsViewModel {
  _ControlledTargets(this.all);
  final List<AstroTarget> all;
  final reads = <_TargetRead>[];
  bool autoCatalogue = false;
  @override
  Future<List<AstroTarget>> search(String query) {
    if (query.isEmpty && autoCatalogue) return Future.value(all);
    final read = _TargetRead(query);
    reads.add(read);
    return read.result.future;
  }

  @override
  Future<Map<String, List<TargetAlias>>> aliases() async => {};
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _SessionRead {
  _SessionRead(this.id);
  final int id;
  final result = Completer<Session?>();
}

class _ControlledSessions extends SessionsViewModel {
  _ControlledSessions(super.repository)
    : super(clock: FixedClock(hybridTransferNow));
  final reads = <_SessionRead>[];
  @override
  Future<Session?> get(int id) {
    final read = _SessionRead(id);
    reads.add(read);
    return read.result.future;
  }
}

Future<void> _fonts() async {
  await (FontLoader('Geist')..addFont(
        File('assets/fonts/Geist.ttf').readAsBytes().then(ByteData.sublistView),
      ))
      .load();
  await (FontLoader('MaterialIcons')..addFont(
        sdkMaterialFont('materialicons-regular.otf')!
            .readAsBytes()
            .then(ByteData.sublistView),
      ))
      .load();
}

Future<HybridTransferFixture> _fixture(
  WidgetTester tester, {
  bool withSite = true,
  bool savePlan = true,
}) async {
  tester.view.physicalSize = const Size(375, 812);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
  tester.platformDispatcher.textScaleFactorTestValue = 1;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);
  late HybridTransferFixture fixture;
  await tester.runAsync(() async {
    await _fonts();
    fixture = await HybridTransferFixture.create(
      AppDatabase(NativeDatabase.memory()),
      withSite: withSite,
      savePlan: savePlan,
    );
  });
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    fixture.vm.dispose();
    await tester.runAsync(fixture.db.close);
  });
  return fixture;
}

Future<void> _mount(
  WidgetTester tester,
  HybridTransferFixture fixture, [
  List<SingleChildWidget> overrides = const [],
]) async {
  AppRouter.router.go(AppRouter.tonight);
  await tester.pumpWidget(
    MultiProvider(
      providers: [...fixture.vm.providers, ...overrides],
      child: const AstroPlanApp(),
    ),
  );
  await hybridSettle(tester);
}

Future<void> _push(WidgetTester tester, String route) async {
  unawaited(AppRouter.router.push(route));
  await hybridSettle(tester);
}

Future<void> _semanticTap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  final node = tester.getSemantics(finder);
  expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
  tester.semantics.tap(
    find.semantics.byPredicate((candidate) => candidate.id == node.id),
  );
  await hybridSettle(tester);
}

String _text(WidgetTester tester, String key) =>
    tester.widget<Text>(find.byKey(Key(key))).data!;

Future<_ControlledTargets> _chooser(
  WidgetTester tester,
  HybridTransferFixture fixture,
) async {
  final first = fixture.vm.plan.selectedTarget!;
  final second = (await tester.runAsync(
    () => fixture.vm.vms.targetList.search('M42'),
  ))!.single;
  final targets = _ControlledTargets([first, second]);
  addTearDown(targets.dispose);
  await _mount(tester, fixture, [
    ChangeNotifierProvider<TargetsViewModel>.value(value: targets),
  ]);
  await _push(tester, AppRouter.selectTarget);
  return targets;
}

void main() {
  testWidgets(
    'obsolete named opening cannot adopt a plan after switching to current',
    (tester) async {
      final fixture = await _fixture(tester);
      final original = fixture.vm.plan.activeSession!;
      late Session requested;
      await tester.runAsync(() async {
        final m42 = (await fixture.vm.vms.targetList.search('M42')).single;
        await fixture.vm.lifecycle.duplicateForNight(
          hybridTransferNight.addDays(1),
        );
        await fixture.vm.plan.setTarget(m42);
        requested = await fixture.vm.analysis.saveSession();
        await fixture.vm.lifecycle.openSession(original);
      });
      final sessions = _ControlledSessions(fixture.sessions);
      addTearDown(sessions.dispose);
      await _mount(tester, fixture, [
        ChangeNotifierProvider<SessionsViewModel>.value(value: sessions),
      ]);
      AppRouter.router.go(AppRouter.session(requested.id));
      await hybridSettle(tester);
      expect(sessions.reads.single.id, requested.id);
      AppRouter.router.go(AppRouter.session());
      await hybridSettle(tester);
      sessions.reads.single.result.complete(requested);
      await hybridSettle(tester);
      expect(fixture.vm.plan.activeSessionId, original.id);
      expect(fixture.vm.plan.selectedTarget!.catalogId, 'M31');
      expect(find.byKey(const Key('planner.save')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Q1 root navigation can activate each real destination semantically',
    (tester) async {
      final fixture = await _fixture(tester);
      final handle = tester.ensureSemantics();
      try {
        await _mount(tester, fixture);
        for (final entry in <(String, Type)>[
          ('library', LibraryScreen),
          ('settings', SettingsScreen),
          ('logbook', LogbookScreen),
          ('tonight', TonightHomeScreen),
        ]) {
          await _semanticTap(tester, find.byKey(Key('nav.${entry.$1}')));
          expect(find.byType(entry.$2), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
      } finally {
        handle.dispose();
      }
    },
  );

  testWidgets(
    'Q2 target pending failure and retry never claim settled empty data',
    (tester) async {
      final fixture = await _fixture(tester);
      final targets = await _chooser(tester, fixture);
      expect(_text(tester, 'planTarget.count'), 'Searching…');
      expect(_text(tester, 'planTarget.note'), isNot(contains('0 bundled')));
      expect(find.textContaining('No matches.'), findsNothing);
      targets.reads.single.result.completeError(
        StateError('private-database-marker'),
      );
      await hybridSettle(tester);
      expect(find.byType(LoadFailureView), findsOneWidget);
      expect(_text(tester, 'planTarget.count'), 'Results unavailable');
      expect(find.textContaining('private-database-marker'), findsNothing);
      await tester.ensureVisible(find.widgetWithText(OutlinedButton, 'Retry'));
      await tester.tap(find.widgetWithText(OutlinedButton, 'Retry'));
      await hybridSettle(tester);
      expect(targets.reads, hasLength(2));
      expect(_text(tester, 'planTarget.count'), 'Searching…');
      expect(find.byType(LoadFailureView), findsNothing);
      targets.reads.last.result.complete(targets.all);
      await hybridSettle(tester);
      expect(_text(tester, 'planTarget.count'), '2 results');
      expect(_text(tester, 'planTarget.note'), contains('2 bundled targets'));
      expect(tester.takeException(), isNull);
    },
  );

  for (final lateFails in [false, true]) {
    testWidgets(
      'Q2 latest target request owns results after late ${lateFails ? 'failure' : 'success'}',
      (tester) async {
        final fixture = await _fixture(tester);
        final targets = await _chooser(tester, fixture);
        targets.reads.single.result.complete(targets.all);
        targets.autoCatalogue = true;
        await hybridSettle(tester);
        await tester.enterText(
          find.byKey(const Key('planTarget.search')),
          'M31',
        );
        await hybridSettle(tester);
        final older = targets.reads.last;
        expect(older.query, 'M31');
        expect(_text(tester, 'planTarget.count'), 'Searching…');
        expect(
          find.byKey(Key('planTarget.choice.${targets.all.first.id}')),
          findsNothing,
        );
        await tester.enterText(
          find.byKey(const Key('planTarget.search')),
          'M42',
        );
        await hybridSettle(tester);
        final newer = targets.reads.last;
        expect(newer.query, 'M42');
        newer.result.complete([targets.all.last]);
        await hybridSettle(tester);
        if (lateFails) {
          older.result.completeError(StateError('late-private-marker'));
        } else {
          older.result.complete([targets.all.first]);
        }
        await hybridSettle(tester);
        expect(_text(tester, 'planTarget.count'), '1 result');
        expect(
          find.byKey(Key('planTarget.choice.${targets.all.last.id}')),
          findsOneWidget,
        );
        expect(
          find.byKey(Key('planTarget.choice.${targets.all.first.id}')),
          findsNothing,
        );
        expect(find.byType(LoadFailureView), findsNothing);
        expect(find.textContaining('late-private-marker'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'Q2 staged target summary survives filtering and Apply adopts that choice',
    (tester) async {
      final fixture = await _fixture(tester);
      final originalId = fixture.vm.plan.selectedTarget!.id;
      final handle = tester.ensureSemantics();
      try {
        final targets = await _chooser(tester, fixture);
        targets.reads.single.result.complete(targets.all);
        targets.autoCatalogue = true;
        await hybridSettle(tester);
        final chosen = targets.all.last;
        await _semanticTap(
          tester,
          find.byKey(Key('planTarget.choice.${chosen.id}')),
        );
        expect(_text(tester, 'planTarget.note'), contains('Selected: M42'));
        expect(fixture.vm.plan.selectedTarget!.id, originalId);
        await tester.enterText(
          find.byKey(const Key('planTarget.search')),
          'M31',
        );
        await hybridSettle(tester);
        expect(_text(tester, 'planTarget.note'), contains('Selected: M42'));
        targets.reads.last.result.complete([targets.all.first]);
        await hybridSettle(tester);
        expect(find.byKey(Key('planTarget.choice.${chosen.id}')), findsNothing);
        expect(_text(tester, 'planTarget.note'), contains('Selected: M42'));
        await tester.tap(find.byKey(const Key('planTarget.apply')));
        await hybridSettle(tester);
        expect(fixture.vm.plan.selectedTarget!.id, chosen.id);
        expect(find.byKey(const Key('planTarget.apply')), findsNothing);
        expect(tester.takeException(), isNull);
      } finally {
        handle.dispose();
      }
    },
  );

  testWidgets(
    'Plan opens shared site management directly; Back cancels and selection updates its context',
    (tester) async {
      final fixture = await _fixture(tester);
      final originalId = fixture.vm.site.activeSite!.id;
      final originalNight = fixture.vm.plan.eveningDate;
      final originalSession = fixture.vm.plan.activeSessionId!;
      final originalTarget = fixture.vm.plan.selectedTarget!.id;
      final originalRig = fixture.vm.plan.selectedEquipment!.id;
      final originalBlocks = fixture.vm.plan.captureBlocks;
      final originalSnapshot =
          fixture.vm.plan.activeSession!.planSnapshot!.json;
      late int newYork;
      late int unknown;
      await tester.runAsync(() async {
        newYork = await fixture.vm.site.saveSite(
          LocationProfile(
            id: 0,
            name: 'Synthetic New York',
            latitude: 40.7,
            longitude: -74,
            timeZoneId: 'America/New_York',
          ),
          activate: false,
        );
        unknown = await fixture.vm.site.saveSite(
          LocationProfile(
            id: 0,
            name: 'Synthetic unknown zone',
            latitude: 40.8,
            longitude: -74.1,
          ),
          activate: false,
        );
      });
      final handle = tester.ensureSemantics();
      try {
        await _mount(tester, fixture);
        await _push(tester, AppRouter.session());
        await _semanticTap(tester, find.byKey(const Key('planner.site')));
        expect(find.text('Manage sites'), findsOneWidget);
        expect(find.byKey(const Key('planContext.apply')), findsNothing);
        expect(fixture.vm.site.activeSite!.id, originalId);
        expect(fixture.vm.plan.hasUnsavedChanges, isFalse);
        await tester.pageBack();
        await hybridSettle(tester);
        expect(find.byKey(const Key('planner.site')), findsOneWidget);
        expect(fixture.vm.site.activeSite!.id, originalId);
        expect(fixture.vm.plan.eveningDate, originalNight);
        expect(fixture.vm.plan.hasUnsavedChanges, isFalse);

        await _semanticTap(tester, find.byKey(const Key('planner.site')));
        await _semanticTap(tester, find.byKey(ValueKey('site-$newYork')));
        await tester.runAsync(() => fixture.vm.plan.idle);
        expect(fixture.vm.site.activeSite!.id, newYork);
        expect(fixture.vm.site.displayZoneId, 'America/New_York');
        expect(fixture.vm.plan.eveningDate, originalNight);
        expect(fixture.vm.plan.activeSessionId, originalSession);
        expect(fixture.vm.plan.selectedTarget!.id, originalTarget);
        expect(fixture.vm.plan.selectedEquipment!.id, originalRig);
        expect(fixture.vm.plan.captureBlocks, originalBlocks);
        expect(fixture.vm.plan.hasUnsavedChanges, isTrue);
        await tester.pageBack();
        await hybridSettle(tester);
        final siteRow = find.byKey(const Key('planner.site'));
        expect(
          find.descendant(
            of: siteRow,
            matching: find.text('Synthetic New York'),
          ),
          findsOneWidget,
        );
        expect(find.textContaining('America/New_York'), findsWidgets);
        final stored = await tester.runAsync(
          () => fixture.sessions.get(originalSession),
        );
        expect(stored!.siteId, newYork);
        expect(stored.timeZoneId, 'America/New_York');
        expect(stored.eveningDate, originalNight);
        expect(stored.planSnapshot!.json, originalSnapshot);

        await _semanticTap(tester, siteRow);
        await _semanticTap(tester, find.byKey(ValueKey('site-$unknown')));
        await tester.runAsync(() => fixture.vm.plan.idle);
        await tester.pageBack();
        await hybridSettle(tester);
        expect(fixture.vm.site.activeSite!.id, unknown);
        expect(fixture.vm.site.displayZoneId, isNull);
        expect(fixture.vm.plan.eveningDate, originalNight);
        expect(fixture.vm.plan.sessionNight!.timeContextId, 'solar');
        expect(tester.takeException(), isNull);
      } finally {
        handle.dispose();
      }
    },
  );

  testWidgets(
    'Q3 missing named plan is explicit and cannot expose unrelated Save',
    (tester) async {
      final fixture = await _fixture(tester);
      final original = fixture.vm.plan.activeSessionId;
      final sessions = _ControlledSessions(fixture.sessions);
      addTearDown(sessions.dispose);
      await _mount(tester, fixture, [
        ChangeNotifierProvider<SessionsViewModel>.value(value: sessions),
      ]);
      await _push(tester, AppRouter.session(999999));
      expect(sessions.reads.single.id, 999999);
      expect(find.byKey(const Key('planner.save')), findsNothing);
      sessions.reads.single.result.complete(null);
      await hybridSettle(tester);
      expect(find.text('This plan could not be found.'), findsOneWidget);
      expect(find.byKey(const Key('fieldMode.toggle')), findsOneWidget);
      expect(find.byKey(const Key('planner.status')), findsNothing);
      expect(find.byKey(const Key('planner.save')), findsNothing);
      expect(fixture.vm.plan.activeSessionId, original);
      await tester.tap(find.text('Back to Tonight'));
      await hybridSettle(tester);
      expect(find.byType(TonightHomeScreen), findsOneWidget);
      expect(fixture.vm.plan.activeSessionId, original);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Q3 first-open failed read Retry adopts the actual requested existing plan',
    (tester) async {
      final fixture = await _fixture(tester);
      final original = fixture.vm.plan.activeSession!;
      late Session requested;
      await tester.runAsync(() async {
        final m42 = (await fixture.vm.vms.targetList.search('M42')).single;
        await fixture.vm.lifecycle.duplicateForNight(
          hybridTransferNight.addDays(1),
        );
        await fixture.vm.plan.setTarget(m42);
        requested = await fixture.vm.analysis.saveSession();
        await fixture.vm.lifecycle.openSession(original);
      });
      expect(fixture.vm.plan.activeSessionId, original.id);
      final sessions = _ControlledSessions(fixture.sessions);
      addTearDown(sessions.dispose);
      await _mount(tester, fixture, [
        ChangeNotifierProvider<SessionsViewModel>.value(value: sessions),
      ]);
      await _push(tester, AppRouter.session(requested.id));
      expect(find.byKey(const Key('planner.save')), findsNothing);
      sessions.reads.single.result.completeError(
        StateError('private-session-marker'),
      );
      await hybridSettle(tester);
      expect(find.byType(LoadFailureView), findsOneWidget);
      expect(find.textContaining('private-session-marker'), findsNothing);
      expect(find.byKey(const Key('planner.save')), findsNothing);
      await tester.tap(find.widgetWithText(OutlinedButton, 'Retry'));
      await hybridSettle(tester);
      expect(sessions.reads, hasLength(2));
      expect(find.byType(LoadFailureView), findsNothing);
      expect(find.byKey(const Key('planner.save')), findsNothing);
      sessions.reads.last.result.complete(requested);
      await hybridSettle(tester);
      expect(fixture.vm.plan.activeSessionId, requested.id);
      expect(fixture.vm.plan.selectedTarget!.catalogId, 'M42');
      expect(find.byKey(const Key('planner.save')), findsOneWidget);
      final retained = await tester.runAsync(
        () => fixture.sessions.get(original.id),
      );
      expect(retained!.record.targetName, original.record.targetName);
      expect(retained.status, original.status);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'Q3 replacing a missing named route with current updates the displayed outcome',
    (tester) async {
      final fixture = await _fixture(tester);
      final sessions = _ControlledSessions(fixture.sessions);
      addTearDown(sessions.dispose);
      await _mount(tester, fixture, [
        ChangeNotifierProvider<SessionsViewModel>.value(value: sessions),
      ]);
      AppRouter.router.go(AppRouter.session(999999));
      await hybridSettle(tester);
      sessions.reads.single.result.complete(null);
      await hybridSettle(tester);
      expect(find.text('This plan could not be found.'), findsOneWidget);
      AppRouter.router.go(AppRouter.session());
      await hybridSettle(tester);
      expect(find.text('This plan could not be found.'), findsNothing);
      expect(find.byKey(const Key('planner.save')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'Q1 Tonight action and condition rows and actual Candidate activate semantically',
    (tester) async {
      final fixture = await _fixture(tester);
      await tester.runAsync(() async {
        await fixture.vm.lifecycle.newSession();
        await fixture.vm.plan.idle;
      });
      final handle = tester.ensureSemantics();
      try {
        await _mount(tester, fixture);
        expect(fixture.vm.plan.selectedTarget, isNull);

        await _semanticTap(
          tester,
          find.byKey(const Key('tonight.chooseTarget')),
        );
        expect(find.byKey(const Key('planTarget.search')), findsOneWidget);
        expect(fixture.vm.plan.selectedTarget, isNull);
        AppRouter.router.pop();
        await hybridSettle(tester);

        await _semanticTap(
          tester,
          find.byKey(const Key('tonight.planCandidates')),
        );
        expect(find.byType(TonightCandidatesScreen), findsOneWidget);
        final candidates = find.byWidgetPredicate((widget) {
          final key = widget.key;
          return key is ValueKey<String> &&
              key.value.startsWith('tonight.row.');
        });
        // Allow the existing candidate isolate to finish. No pumpAndSettle on
        // an active progress indicator and no fixed wall-clock assumption.
        for (
          var attempt = 0;
          attempt < 20 && candidates.evaluate().isEmpty;
          attempt++
        ) {
          await hybridSettle(tester);
        }
        expect(candidates, findsWidgets);
        final first = candidates.first;
        final key = tester.widget(first).key! as ValueKey<String>;
        final expectedId = int.parse(
          key.value.substring('tonight.row.'.length),
        );
        await _semanticTap(tester, first);
        expect(find.byType(TonightCandidatesScreen), findsNothing);
        expect(find.byType(TonightHomeScreen), findsOneWidget);
        expect(fixture.vm.plan.selectedTarget!.id, expectedId);

        for (final entry in <(String, int)>[
          ('tonight.night', 0),
          ('tonight.moon', 1),
          ('tonight.weather', 2),
        ]) {
          await _semanticTap(tester, find.byKey(Key(entry.$1)));
          expect(find.byType(NightMoonScreen), findsOneWidget);
          final controller = DefaultTabController.of(
            tester.element(find.byType(TabBar)),
          );
          expect(controller.index, entry.$2);
          if (entry.$2 == 2) {
            expect(find.byType(WeatherDetailScreen), findsOneWidget);
          }
          AppRouter.router.pop();
          await hybridSettle(tester);
          expect(find.byType(TonightHomeScreen), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
      } finally {
        handle.dispose();
      }
    },
  );

  testWidgets(
    'Q1 semantic Night jumps preview boundaries and Plan opens the shared calendar directly',
    (tester) async {
      final fixture = await _fixture(tester);
      final originalNight = fixture.vm.plan.eveningDate;
      final originalBlocks = fixture.vm.plan.captureBlocks;
      final originalSession = fixture.vm.plan.activeSessionId;
      final handle = tester.ensureSemantics();
      try {
        await _mount(tester, fixture);
        await _push(tester, AppRouter.nightMoon);
        final browser = tester
            .element(find.byKey(const Key('nightMoon.slider')))
            .read<NightBrowserViewModel>();
        final view = browser.view;
        expect(view.darkInterval, isNotNull);
        browser.setCursor(view.night.startUtc);
        await hybridSettle(tester);
        await _semanticTap(
          tester,
          find.byKey(const Key('nightMoon.jumpStart')),
        );
        expect(browser.cursorUtc, view.gridAt(view.darkInterval!.$1));
        await _semanticTap(tester, find.byKey(const Key('nightMoon.jumpEnd')));
        expect(browser.cursorUtc, view.gridAt(view.darkInterval!.$2));
        expect(fixture.vm.plan.eveningDate, originalNight);
        expect(fixture.vm.plan.captureBlocks, originalBlocks);
        expect(fixture.vm.plan.activeSessionId, originalSession);
        AppRouter.router.pop();
        await hybridSettle(tester);

        await _push(tester, AppRouter.session());
        await _semanticTap(
          tester,
          find.byKey(const Key('planner.nightChoice')),
        );
        expect(find.byType(NightPickerDialog), findsOneWidget);
        expect(fixture.vm.plan.eveningDate, originalNight);
        await tester.tap(find.text('20'));
        await tester.tap(find.text('Cancel'));
        await hybridSettle(tester);
        expect(find.byType(NightPickerDialog), findsNothing);
        expect(find.byKey(const Key('planner.nightChoice')), findsOneWidget);
        expect(fixture.vm.plan.eveningDate, originalNight);
        expect(fixture.vm.plan.captureBlocks, originalBlocks);
        expect(fixture.vm.plan.activeSessionId, originalSession);
        expect(fixture.vm.plan.hasUnsavedChanges, isFalse);

        // The unchanged confirmation must not turn a saved plan into an edit.
        await _semanticTap(
          tester,
          find.byKey(const Key('planner.nightChoice')),
        );
        await tester.tap(find.text('OK'));
        await hybridSettle(tester);
        expect(fixture.vm.plan.hasUnsavedChanges, isFalse);
        expect(fixture.vm.plan.activeSession!.status, SessionStatus.planned);

        // Back dismisses the dialog, including a highlighted but unconfirmed day.
        await _semanticTap(
          tester,
          find.byKey(const Key('planner.nightChoice')),
        );
        await tester.tap(find.text('20'));
        await tester.binding.handlePopRoute();
        await hybridSettle(tester);
        expect(find.byType(NightPickerDialog), findsNothing);
        expect(fixture.vm.plan.eveningDate, originalNight);
        expect(fixture.vm.plan.captureBlocks, originalBlocks);
        expect(fixture.vm.plan.hasUnsavedChanges, isFalse);

        // Cancel also keeps edits already present on the working plan.
        await tester.runAsync(() async {
          await fixture.vm.plan.addCaptureBlock(originalBlocks.first);
          await fixture.vm.plan.idle;
        });
        await hybridSettle(tester);
        final editedBlocks = fixture.vm.plan.captureBlocks;
        expect(fixture.vm.plan.hasUnsavedChanges, isTrue);
        await _semanticTap(
          tester,
          find.byKey(const Key('planner.nightChoice')),
        );
        await tester.tap(find.text('20'));
        await tester.tap(find.text('Cancel'));
        await hybridSettle(tester);
        expect(fixture.vm.plan.eveningDate, originalNight);
        expect(fixture.vm.plan.captureBlocks, editedBlocks);
        expect(fixture.vm.plan.activeSessionId, originalSession);
        expect(fixture.vm.plan.hasUnsavedChanges, isTrue);
        expect(tester.takeException(), isNull);
      } finally {
        handle.dispose();
      }
    },
  );

  for (final savedBefore in [false, true]) {
    testWidgets(
      'Plan calendar confirms into ${savedBefore ? 'a saved plan as modified' : 'a new draft'}, restores it and saves explicitly',
      (tester) async {
        final fixture = await _fixture(tester, savePlan: savedBefore);
        final original = fixture.vm.plan.activeSession!;
        final originalTarget = fixture.vm.plan.selectedTarget!.id;
        final originalRig = fixture.vm.plan.selectedEquipment!.id;
        final originalSite = fixture.vm.site.activeSite!.id;
        final originalBlocks = [
          for (final b in fixture.vm.plan.captureBlocks)
            (b.frameType, b.frameCount, b.exposureTimeSeconds),
        ];
        final picked = CalendarDate(2026, 10, 20);
        final handle = tester.ensureSemantics();
        try {
          await _mount(tester, fixture);
          await _push(tester, AppRouter.session());
          await _semanticTap(
            tester,
            find.byKey(const Key('planner.nightChoice')),
          );
          expect(find.byType(NightPickerDialog), findsOneWidget);
          await tester.tap(find.text('20'));
          // Selecting a day is a preview until the shared calendar's OK.
          expect(fixture.vm.plan.eveningDate, hybridTransferNight);
          await tester.tap(find.text('OK'));
          await hybridSettle(tester);
          await tester.runAsync(() => fixture.vm.plan.idle);
          expect(find.byType(NightPickerDialog), findsNothing);
          expect(fixture.vm.plan.eveningDate, picked);
          expect(fixture.vm.plan.activeSessionId, original.id);
          expect(fixture.vm.plan.selectedTarget!.id, originalTarget);
          expect(fixture.vm.plan.selectedEquipment!.id, originalRig);
          expect(fixture.vm.site.activeSite!.id, originalSite);
          expect(fixture.vm.site.displayZoneId, 'Europe/Kyiv');
          expect(fixture.vm.plan.hasUnsavedChanges, isTrue);
          final stored = await tester.runAsync(
            () => fixture.sessions.get(original.id),
          );
          expect(stored!.eveningDate, picked);
          expect(stored.status, SessionStatus.draft);
          expect(stored.timeZoneId, 'Europe/Kyiv');
          expect(stored.planSnapshot?.json, original.planSnapshot?.json);
          expect(
            PlanState.of(stored),
            savedBefore ? PlanState.savedChanged : PlanState.notSaved,
          );

          // Exercise the actual restore path against the autosaved row.
          late Future<void> restored;
          var restoreComplete = false;
          await tester.runAsync(() async {
            restored = fixture.vm.lifecycle.load().whenComplete(
              () => restoreComplete = true,
            );
          });
          for (var attempt = 0; attempt < 20 && !restoreComplete; attempt++) {
            await hybridSettle(tester);
          }
          expect(restoreComplete, isTrue);
          await tester.runAsync(() => restored);
          await hybridSettle(tester);
          expect(fixture.vm.plan.activeSessionId, original.id);
          expect(fixture.vm.plan.eveningDate, picked);
          expect(fixture.vm.plan.hasUnsavedChanges, isTrue);
          expect(fixture.vm.plan.selectedTarget!.id, originalTarget);
          expect(fixture.vm.plan.selectedEquipment!.id, originalRig);
          expect([
            for (final b in fixture.vm.plan.captureBlocks)
              (b.frameType, b.frameCount, b.exposureTimeSeconds),
          ], originalBlocks);
          await tester.drag(
            find.byKey(const Key('planner.scroll')),
            const Offset(0, 1500),
          );
          await hybridSettle(tester);
          final state = find.descendant(
            of: find.byKey(const Key('planner.identity')),
            matching: find.byType(PlanStateLabel),
          );
          expect(
            tester.widget<PlanStateLabel>(state).state,
            savedBefore ? PlanState.savedChanged : PlanState.notSaved,
          );

          await _semanticTap(tester, find.byKey(const Key('planner.save')));
          await tester.runAsync(() => fixture.vm.plan.idle);
          await hybridSettle(tester);
          final saved = await tester.runAsync(
            () => fixture.sessions.get(original.id),
          );
          expect(saved!.status, SessionStatus.planned);
          expect(saved.eveningDate, picked);
          expect(saved.planSnapshot!.eveningDate, picked);
          expect(fixture.vm.plan.hasUnsavedChanges, isFalse);
          expect(tester.widget<PlanStateLabel>(state).state, PlanState.saved);
          expect(tester.takeException(), isNull);
        } finally {
          handle.dispose();
        }
      },
    );
  }

  testWidgets(
    'Q1 no-site position semantics invokes safe fake and unavailable night stays disabled',
    (tester) async {
      final fixture = await _fixture(tester, withSite: false);
      final handle = tester.ensureSemantics();
      try {
        await _mount(tester, fixture);
        expect(fixture.vm.site.isDefaultLocation, isTrue);
        await _semanticTap(
          tester,
          find.byKey(const Key('tonight.useCurrentPosition')),
        );
        // The existing fixture's FakeLocationService returns permissionDenied.
        // Observing its feedback proves the real callback ran without GPS.
        expect(
          find.text(
            LocationFailureText.message(LocationFailure.permissionDenied),
          ),
          findsOneWidget,
        );
        expect(fixture.vm.site.isDefaultLocation, isTrue);
        expect(fixture.vm.site.sites, isEmpty);

        // Remove only the diagnostic snackbar before the next interaction.
        ScaffoldMessenger.of(tester.element(find.byType(TonightHomeScreen)))
            .removeCurrentSnackBar();
        await hybridSettle(tester);
        await _push(tester, AppRouter.session());
        final node = tester.getSemantics(
          find.byKey(const Key('planner.nightChoice')),
        );
        final data = node.getSemanticsData();
        expect(data.hasAction(SemanticsAction.tap), isFalse);
        expect(data.flagsCollection.isEnabled, ui.Tristate.isFalse);
        expect(fixture.vm.plan.sessionNight, isNull);
        await _semanticTap(tester, find.byKey(const Key('planner.site')));
        expect(find.text('Manage sites'), findsOneWidget);
        await tester.pageBack();
        await hybridSettle(tester);
        expect(fixture.vm.plan.sessionNight, isNull);
        expect(tester.takeException(), isNull);
      } finally {
        handle.dispose();
      }
    },
  );
}
