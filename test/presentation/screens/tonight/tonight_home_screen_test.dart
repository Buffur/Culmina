// The Tonight dashboard and first-run flow (TASK 12.5): the states for no
// site, no rig, no forecast, fits and doesn't fit; no overflow at 200 %
// text on a small phone; the first-run setup is offered once, only without
// a site, and Skip / Done close it for good.

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:drift/native.dart';
import 'package:astroplan/domain/services/fit_analyzer.dart';
import 'package:astroplan/presentation/shared/status_block.dart';
import 'package:astroplan/presentation/widgets/plan_status.dart';
import 'package:astroplan/core/utils/quantity_text.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/planning_preferences.dart';
import 'package:astroplan/presentation/shared/app_words.dart';
import 'package:astroplan/presentation/shared/night_text.dart';
import 'package:astroplan/presentation/shared/night_time_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/fake_location_service.dart';
import '../../../support/in_memory_first_run.dart';
import '../../../support/no_snapshot_weather.dart';
import '../../../support/planner_harness.dart';

/// The tests' now, for the planner and the saved plans alike (F24 A1).
final _december = FixedClock(DateTime.utc(2026, 12, 15, 17));

class _NoForecast with NoSnapshotWeather implements WeatherRepository {}

const _m42 = AstroTarget(
  id: 1,
  catalogId: 'M42',
  commonName: 'Orion Nebula',
  type: 'Nebula',
  rightAscension: 83.82,
  declination: -5.39,
);

const _rig = EquipmentProfile(
  id: 1,
  name: 'Refractor 400',
  focalRatio: 5.0,
  focalLengthMm: 400.0,
  sensorWidthMm: 23.5,
  sensorHeightMm: 15.6,
  resolutionWidthPx: 6000,
  resolutionHeightPx: 4000,
  pixelPitchUm: 3.76,
  averageRawFileSizeMB: 50.0,
);

CaptureBlock _lights(int count) => CaptureBlock(
  frameType: FrameType.light,
  filterName: 'L',
  exposureTimeSeconds: 60,
  frameCount: count,
);

void main() {
  late AppDatabase database;
  late PlannerHarness vm;
  late InMemoryFirstRun firstRun;

  /// Builds the app. [site] sets a transient position at 46° N, 14.5° E;
  /// the clock is a December evening, when M42 is well placed.
  Future<void> start(
    WidgetTester tester, {
    bool site = true,
    bool rig = true,
    bool firstRunDone = true,
    int? lightFrames,
  }) async {
    AppRouter.router.go(AppRouter.tonight);
    SharedPreferences.setMockInitialValues({});
    firstRun = InMemoryFirstRun(done: firstRunDone);
    await tester.runAsync(() async {
      database = AppDatabase(NativeDatabase.memory());
      final targets = DriftTargetRepository(database);
      final rigs = DriftEquipmentRepository(database);
      await targets.insertTarget(_m42);
      if (rig) await rigs.insertEquipment(_rig);
      vm = PlannerHarness(
        targets,
        rigs,
        _NoForecast(),
        DriftLocationRepository(database),
        locationService: FakeLocationService(),
        sessionRepository: DriftSessionRepository(database, clock: _december),
        clock: _december,
        firstRun: firstRun,
      );
      await vm.ready;
      // S6.8: nothing is preselected; a first run has chosen nothing yet.
      if (firstRunDone) await vm.choosePlan();
      // F16 A1: as main does, the stored flag and site decide the first
      // route before the first frame.
      if (site) await vm.site.setLocation(46.05, 14.5);
      await vm.tonight.load(hasStoredSite: site);
      if (lightFrames != null) {
        while (vm.plan.captureBlocks.isNotEmpty) {
          await vm.plan.removeCaptureBlock(0);
        }
        await vm.plan.addCaptureBlock(_lights(lightFrames));
      }
      await vm.plan.idle;
      await vm.conditions.idle;
    });
    addTearDown(() => tester.runAsync(database.close));
    AppRouter.router.go(AppRouter.firstLocation(vm.tonight));
    await tester.pumpWidget(
      MultiProvider(providers: vm.providers, child: const AstroPlanApp()),
    );
    await settle(tester);
  }

  testWidgets('no site: the site prompt replaces the night rows', (
    tester,
  ) async {
    await start(tester, site: false);
    expect(find.byKey(const Key('tonight.noSite')), findsOneWidget);
    expect(find.byKey(const Key('tonight.night')), findsNothing);
    expect(find.byKey(const Key('tonight.fit')), findsNothing);
    expect(find.text('Use current position'), findsOneWidget);
  });

  testWidgets('with a site: night, Moon and weather rows', (tester) async {
    await start(tester);
    expect(find.byKey(const Key('tonight.noSite')), findsNothing);
    expect(find.byKey(const Key('tonight.night')), findsOneWidget);
    // F17 A1: the dark interval, not sunset to sunrise (on Night & Moon).
    expect(find.textContaining('Sunset to sunrise:'), findsNothing);
    expect(find.textContaining('Dark (Sun below −18°):'), findsOneWidget);
    expect(find.byKey(const Key('tonight.moon')), findsOneWidget);
    // S1.13 (SCI-09): the night's value, and when it applies.
    expect(find.textContaining('% lit at midnight'), findsOneWidget);
  });

  testWidgets('no forecast: says so, never a number', (tester) async {
    await start(tester);
    final weather = find.byKey(const Key('tonight.weather'));
    expect(weather, findsOneWidget);
    expect(
      find.descendant(
        of: weather,
        matching: find.textContaining('No forecast'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: weather, matching: find.textContaining('%')),
      findsNothing,
    );
  });

  // S6.13: the plan card's status says what is missing, in the planner's
  // words, and offers the picker (before: its own "No rig chosen" line).
  testWidgets('no rig: says so and offers the rig picker', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await start(tester, rig: false);
    final status = find.byKey(const Key('tonight.status'));
    expect(
      find.descendant(of: status, matching: find.text(PlanStatus.needsRig)),
      findsOneWidget,
    );
    await tester.ensureVisible(find.byKey(const Key('tonight.chooseRig')));
    await tester.tap(find.byKey(const Key('tonight.chooseRig')));
    await settle(tester);
    expect(find.text('Choose a rig'), findsWidgets);
  });

  testWidgets('a small plan fits, with the reason and usable time', (
    tester,
  ) async {
    await start(tester, lightFrames: 10);
    // S6.13: the StatusBlock verdict, as in the planner: the headline
    // carries the usable time.
    final fit = vm.fitAnalysis;
    expect(fit.state, FitState.fits);
    expect(
      find.text(
        StatusBlock.headline(
          fit.state,
          needed: Duration(milliseconds: fit.windowLoadMs),
          usable: Duration(milliseconds: fit.availableMs),
        ),
      ),
      findsOneWidget,
    );
    expect(find.textContaining('usable'), findsWidgets);
    expect(find.text(fit.reason), findsOneWidget);
  });

  testWidgets("a huge plan doesn't fit, with the reason", (tester) async {
    await start(tester, lightFrames: 2000);
    final fit = vm.fitAnalysis;
    expect(fit.state, FitState.doesNotFit);
    expect(find.textContaining("Doesn't fit:"), findsOneWidget);
    expect(find.text(fit.reason), findsOneWidget);
  });

  group('200 % text on a 360 × 640 dp phone: no overflow', () {
    Future<void> big(WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    }

    testWidgets('with a site and a plan', (tester) async {
      await big(tester);
      await start(tester, lightFrames: 2000);
      await tester.drag(find.byType(ListView).first, const Offset(0, -2000));
      await settle(tester);
      expect(tester.takeException(), isNull);
    });

    testWidgets('without a site or rig', (tester) async {
      await big(tester);
      await start(tester, site: false, rig: false);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the first-run page', (tester) async {
      await big(tester);
      await start(tester, site: false, firstRunDone: false);
      expect(find.text('Welcome to Culmina'), findsOneWidget);
      await tester.drag(find.byType(ListView).last, const Offset(0, -3000));
      await settle(tester);
      expect(tester.takeException(), isNull);
    });
  });

  // S6.13 (P6.6; ADR-019 §5): plan first.
  group('plan first (S6.13)', () {
    // F17 (S16.2): the night's facts lead, Your plan follows, then the
    // secondary candidate action; Home has no New plan.
    testWidgets('the order: site and night, the night rows, the plan with its '
        'answer, then the secondary action', (tester) async {
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await start(tester, lightFrames: 10);
      double y(String key) => tester.getTopLeft(find.byKey(Key(key))).dy;
      final order = [
        'tonight.title',
        'tonight.context',
        'tonight.night',
        'tonight.moon',
        'tonight.weather',
        'tonight.plan',
        'tonight.candidates',
      ];
      for (var i = 1; i < order.length; i++) {
        expect(y(order[i]), greaterThan(y(order[i - 1])), reason: order[i]);
      }
      expect(find.byKey(const Key('tonight.status')), findsOneWidget);
      expect(find.byKey(const Key('tonight.planState')), findsOneWidget);
      expect(find.byKey(const Key('tonight.openPlanner')), findsOneWidget);
      expect(find.byKey(const Key('tonight.start')), findsNothing);
      // Tonight's own status words are gone ("Draft", S5.3's baseline).
      expect(find.text('Draft'), findsNothing);
    });

    testWidgets('without a target: Choose a target and What can I image '
        'tonight?', (tester) async {
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await start(tester, firstRunDone: false);
      final plan = find.byKey(const Key('tonight.plan'));
      expect(
        find.descendant(of: plan, matching: find.text(AppWords.needsTarget)),
        findsOneWidget,
      );
      expect(find.byKey(const Key('tonight.chooseTarget')), findsOneWidget);
      expect(find.byKey(const Key('tonight.planCandidates')), findsOneWidget);
      await tester.ensureVisible(find.byKey(const Key('tonight.chooseTarget')));
      await tester.tap(find.byKey(const Key('tonight.chooseTarget')));
      await settle(tester);
      expect(find.text('Choose a target'), findsWidgets);
    });

    // S6.16 (the owner's decisions, DECISIONS E.1 "Stage 6 corrective pass
    // decided"): the finish of the core screen.
    testWidgets('the title is a header in the scale\'s headline role; the '
        'context is on a card', (tester) async {
      await start(tester, lightFrames: 10);
      final handle = tester.ensureSemantics();
      final title = find.byKey(const Key('tonight.title'));
      expect(title, findsOneWidget);
      final ctx = tester.element(title);
      expect(
        tester.widget<Text>(title).style?.fontSize,
        Theme.of(ctx).textTheme.headlineSmall?.fontSize,
      );
      expect(
        tester.getSemantics(title),
        matchesSemantics(label: 'Tonight', isHeader: true),
      );
      handle.dispose();
      expect(
        find.descendant(
          of: find.byKey(const Key('tonight.context')),
          matching: find.byKey(const Key('context.card')),
        ),
        findsOneWidget,
      );
    });

    testWidgets('TD-077: "Your plan" is the card\'s heading; the target and '
        'rig read below it', (tester) async {
      await start(tester, lightFrames: 10);
      final handle = tester.ensureSemantics();
      final heading = find.byKey(const Key('tonight.planHeading'));
      final theme = Theme.of(tester.element(heading));
      final style = tester.widget<Text>(heading).style!;
      expect(tester.widget<Text>(heading).data, AppWords.yourPlan);
      expect(style.fontSize, theme.textTheme.titleMedium?.fontSize);
      expect(style.fontWeight, theme.textTheme.titleMedium?.fontWeight);
      expect(
        tester.getSemantics(heading),
        matchesSemantics(label: AppWords.yourPlan, isHeader: true),
      );
      handle.dispose();
      final target = tester
          .widget<Text>(find.byKey(const Key('tonight.planTarget')))
          .style!;
      expect(target.fontSize, theme.textTheme.bodyLarge?.fontSize);
      expect(target.fontWeight, theme.textTheme.bodyLarge?.fontWeight);
    });

    for (final chosen in [true, false]) {
      testWidgets('Open planner is the plan card\'s filled action (a target '
          'chosen: $chosen)', (tester) async {
        await start(tester, firstRunDone: chosen);
        final open = find.byKey(const Key('tonight.openPlanner'));
        expect(open, findsOneWidget);
        expect(tester.widget(open), isA<FilledButton>());
        expect(
          find.descendant(
            of: find.byKey(const Key('tonight.plan')),
            matching: open,
          ),
          findsOneWidget,
        );
      });
    }

    testWidgets('TD-080: without a target, each way to a target says what it '
        'offers, and What can I image tonight? is shown once', (tester) async {
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await start(tester, firstRunDone: false);
      final choose = find.byKey(const Key('tonight.chooseTarget'));
      final candidates = find.byKey(const Key('tonight.planCandidates'));
      expect(
        find.descendant(
          of: choose,
          matching: find.text('Any object in the catalog'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: candidates,
          matching: find.text(
            'Candidates for this site and night, by usable time',
          ),
        ),
        findsOneWidget,
      );
      expect(find.text('What can I image tonight?'), findsOneWidget);
      expect(find.byKey(const Key('tonight.candidates')), findsNothing);
      await tester.ensureVisible(candidates);
      await tester.tap(candidates);
      await settle(tester);
      expect(find.text("Tonight's candidates"), findsWidgets);
    });

    testWidgets('TD-080: with a target, What can I image tonight? stays in the '
        'secondary actions', (tester) async {
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await start(tester, lightFrames: 10);
      expect(find.byKey(const Key('tonight.planCandidates')), findsNothing);
      expect(find.byKey(const Key('tonight.chooseTarget')), findsNothing);
      expect(find.byKey(const Key('tonight.candidates')), findsOneWidget);
      expect(find.text('What can I image tonight?'), findsOneWidget);
    });

    testWidgets(
      "TD-075: the reason names the missing site or target, never the "
      "empty plan's",
      (tester) async {
        // No site and an empty plan: the case TD-075 was seen in.
        await start(tester, site: false);
        await tester.runAsync(() async {
          while (vm.plan.captureBlocks.isNotEmpty) {
            await vm.plan.removeCaptureBlock(0);
          }
          await vm.plan.idle;
        });
        await settle(tester);
        final status = find.byKey(const Key('tonight.status'));
        Finder inStatus(String text) =>
            find.descendant(of: status, matching: find.text(text));
        expect(inStatus(PlanStatus.needsSite), findsOneWidget);
        expect(inStatus(PlanStatus.siteReason), findsOneWidget);
        expect(find.textContaining('no light frames'), findsNothing);
      },
    );

    testWidgets('TD-075: without a target, the target\'s reason', (
      tester,
    ) async {
      await start(tester, firstRunDone: false);
      final status = find.byKey(const Key('tonight.status'));
      expect(vm.plan.captureBlocks, isEmpty);
      expect(
        find.descendant(of: status, matching: find.text(AppWords.needsTarget)),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: status,
          matching: find.text(PlanStatus.targetReason),
        ),
        findsOneWidget,
      );
      expect(find.textContaining('no light frames'), findsNothing);
    });

    testWidgets("the night picker changes the plan's night, and the plan "
        'autosaves', (tester) async {
      await start(tester, lightFrames: 10);
      expect(vm.plan.eveningDate, CalendarDate(2026, 12, 15));
      await tester.tap(find.byKey(const Key('context.night')));
      await settle(tester);
      expect(find.text('Choose a night'), findsOneWidget);
      await tester.tap(find.text('20'));
      await tester.tap(find.text('OK'));
      await settle(tester);
      await tester.runAsync(() => vm.plan.idle);
      expect(vm.plan.eveningDate, CalendarDate(2026, 12, 20));
      final stored = await tester.runAsync(
        () => DriftSessionRepository(
          database,
          clock: _december,
        ).get(vm.plan.activeSessionId!),
      );
      expect(stored!.eveningDate, CalendarDate(2026, 12, 20));
    });

    for (final limit in DarknessLimit.values) {
      testWidgets('the Dark row is the dark span at the user\'s limit '
          '(${limit.degrees.round()}°; TD-054)', (tester) async {
        await start(tester, lightFrames: 10);
        await tester.runAsync(
          () => vm.setPlanningPreferences(
            vm.planningPreferences.copyWith(darknessLimit: limit),
          ),
        );
        await settle(tester);
        final dark = vm.conditions.nightTimeline!.darkAtLimit!;
        expect(dark.thresholdDeg, limit.degrees);
        final ctx = tester.element(find.byKey(const Key('tonight.night')));
        final expected = DarkText.span(
          dark,
          (utc) => NightTimeFormatter.instant(
            ctx,
            utc,
            windowStartUtc: vm.conditions.nightTimeline!.night.startUtc,
            zoneId: vm.site.displayZoneId,
          ),
        );
        expect(
          find.descendant(
            of: find.byKey(const Key('tonight.night')),
            matching: find.text(expected),
          ),
          findsOneWidget,
        );
        expect(expected, contains(QuantityText.degrees(limit.degrees)));
      });
    }

    // F17 A1 (ADR-022 N4/N5): the phase and the moon-free dark time.
    testWidgets('the Moon row gives the phase and the moon-free dark time', (
      tester,
    ) async {
      await start(tester, lightFrames: 10);
      final moon = vm.conditions.moonConditions!;
      final free = vm.conditions.moonFree!;
      final row = find.byKey(const Key('tonight.moon'));
      expect(
        find.descendant(
          of: row,
          matching: find.textContaining(MoonText.phaseName(moon.phaseName!)),
        ),
        findsOneWidget,
      );
      final ctx = tester.element(row);
      expect(
        find.descendant(
          of: row,
          matching: find.text(
            MoonText.moonFree(
              free,
              (utc) => NightTimeFormatter.instant(
                ctx,
                utc,
                windowStartUtc: moon.night.startUtc,
                zoneId: vm.site.displayZoneId,
              ),
            ),
          ),
        ),
        findsOneWidget,
      );
      // The noon-to-noon rise/set intervals are on Night & Moon only.
      expect(find.textContaining('from noon'), findsNothing);
    });

    // F17 A2: Home has no New plan; the planner keeps its guarded menu.
    testWidgets('Home has no New plan; Open planner resumes the same plan', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await start(tester, lightFrames: 10);
      expect(find.byKey(const Key('tonight.newSession')), findsNothing);
      expect(find.text(AppWords.newPlan), findsNothing);
      final id = vm.plan.activeSessionId;
      await tester.tap(find.byKey(const Key('tonight.openPlanner')));
      await settle(tester);
      expect(vm.plan.activeSessionId, id, reason: 'the same plan');
      expect(find.byKey(const Key('planner.menu')), findsOneWidget);
    });

    // F17 A5 (AM03-T = B): "tonight" only for the current night; another
    // night of the plan is named, in the title, the night card and the
    // candidate action and screen; the tab stays "Tonight".
    testWidgets('another plan night is named; the tab stays Tonight', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await start(tester, lightFrames: 10);
      expect(find.text('Tonight'), findsWidgets);
      expect(find.text('What can I image tonight?'), findsOneWidget);
      final other = vm.plan.tonightKey.addDays(3);
      await tester.runAsync(() => vm.plan.setEveningDate(other));
      await settle(tester);
      final named = NightTimeFormatter.eveningDate(other);
      expect(
        tester.widget<Text>(find.byKey(const Key('tonight.title'))).data,
        'Night of $named',
      );
      expect(find.text('What can I image on $named?'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Tonight'),
        ),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('tonight.candidates')));
      await settle(tester);
      expect(find.text('Candidates for $named'), findsOneWidget);
    });
  });

  group('first run (owner decisions; F16)', () {
    // A1: the first frame is the setup, never Tonight first.
    testWidgets('a first run starts on Welcome: Tonight is never built', (
      tester,
    ) async {
      await start(tester, site: false, firstRunDone: false);
      expect(find.text('Welcome to Culmina'), findsOneWidget);
      expect(find.byKey(const Key('tonight.noSite')), findsNothing);
      expect(find.byType(NavigationBar), findsNothing);
    });

    // A2: one page, purpose and permission, two optional steps, no target
    // step, no Skip; Start planning closes it for good.
    testWidgets('one page with two optional steps; Start planning closes it '
        'for good', (tester) async {
      await start(tester, site: false, firstRunDone: false);
      expect(find.textContaining('asks for location permission'), findsOne);
      expect(find.byKey(const Key('welcome.site')), findsOneWidget);
      expect(find.byKey(const Key('welcome.rig')), findsOneWidget);
      expect(find.byKey(const Key('welcome.target')), findsNothing);
      expect(find.byKey(const Key('welcome.skip')), findsNothing);
      expect(find.text('Skip'), findsNothing);
      expect(find.byKey(const Key('addRig.panel')), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byKey(const Key('welcome.start')),
        300,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.byKey(const Key('welcome.start')));
      await settle(tester);
      expect(find.text('Welcome to Culmina'), findsNothing);
      expect(find.byKey(const Key('tonight.noSite')), findsOneWidget);
      expect(firstRun.done, isTrue);
    });

    testWidgets('back closes it for good too', (tester) async {
      await start(tester, site: false, firstRunDone: false);
      await tester.binding.handlePopRoute();
      await settle(tester);
      expect(find.text('Welcome to Culmina'), findsNothing);
      expect(firstRun.done, isTrue);
    });

    testWidgets('a saved rig is chosen from the normal picker and comes '
        'back', (tester) async {
      await start(tester, site: false, firstRunDone: false);
      await tester.ensureVisible(find.byKey(const Key('welcome.chooseRig')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('welcome.chooseRig')));
      await settle(tester);
      expect(find.text('Choose a rig'), findsWidgets);
      await tester.pageBack();
      await settle(tester);
      expect(find.text('Welcome to Culmina'), findsOneWidget);
    });

    // A3 (D8; UXA-C2): a rig typed in from the class-first panel becomes
    // the plan's rig and the page shows it; Cancel saves and chooses
    // nothing.
    testWidgets('class → by hand: Cancel changes nothing; Save chooses the '
        'rig and the page shows it', (tester) async {
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await start(tester, site: false, rig: false, firstRunDone: false);
      await tester.tap(find.byKey(const Key('addRig.class.dslrMirrorless')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('addRig.byHand')));
      await settle(tester);
      expect(find.byKey(const Key('rigEditor.save')), findsOneWidget);
      expect(
        find.textContaining('Needed for the field of view'),
        findsWidgets,
        reason: 'missing inputs are explained, never defaulted',
      );
      await tester.tap(find.text('Cancel'));
      await settle(tester);
      expect(vm.plan.selectedEquipment, isNull);

      await tester.tap(find.byKey(const Key('addRig.class.dslrMirrorless')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('addRig.byHand')));
      await settle(tester);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Rig name'),
        'Garden DSLR',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, '6248'),
        '6000',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, '4176'),
        '4000',
      );
      await tester.enterText(
        find.byKey(const Key('equipmentEditor.pixelSize')),
        '3.9',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Effective focal length (mm)'),
        '135',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Focal ratio (f/)'),
        '2.8',
      );
      await tester.pump();
      await tester.ensureVisible(find.byKey(const Key('rigEditor.save')));
      await tester.tap(find.byKey(const Key('rigEditor.save')));
      await settle(tester);
      expect(vm.plan.selectedEquipment?.name, 'Garden DSLR');
      expect(vm.plan.selectedEquipment?.cameraClass.name, 'dslrMirrorless');
      expect(
        find.descendant(
          of: find.byKey(const Key('welcome.rig')),
          matching: find.text('Garden DSLR'),
        ),
        findsOneWidget,
      );
      expect(find.text('Welcome to Culmina'), findsOneWidget);
    });

    // S6.8 (RD-04, UX-24): no step reads as done that the user did not do;
    // the example rig, once chosen, says it is one.
    testWidgets('the page shows nothing as chosen that the user did not '
        'choose', (tester) async {
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await start(tester, site: false, firstRunDone: false);
      String status(String step) => tester
          .widgetList<Text>(
            find.descendant(
              of: find.byKey(Key('welcome.$step')),
              matching: find.byType(Text),
            ),
          )
          .elementAt(1)
          .data!;
      expect(status('site'), 'Not set');
      expect(status('rig'), 'Not chosen');

      await tester.runAsync(() async {
        final rigs = DriftEquipmentRepository(database);
        final id = await rigs.insertEquipment(EquipmentSeeder.defaults.first);
        await vm.plan.setEquipment((await rigs.getEquipmentById(id))!);
      });
      await settle(tester);
      expect(status('rig'), endsWith('(example rig)'));
    });

    testWidgets('not offered when a site is already set', (tester) async {
      await start(tester, firstRunDone: false);
      expect(find.text('Welcome to Culmina'), findsNothing);
    });

    testWidgets('not offered again once done', (tester) async {
      await start(tester, site: false);
      expect(find.text('Welcome to Culmina'), findsNothing);
    });
  });
}

/// Pumps fixed frames with real-time gaps: database writes and the
/// candidates isolate never let pumpAndSettle finish (TASK 12.2).
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump(const Duration(milliseconds: 200));
  }
}
