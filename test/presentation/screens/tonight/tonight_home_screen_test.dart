// The Tonight dashboard and first-run flow (TASK 12.5): the states for no
// site, no rig, no forecast, fits and doesn't fit; no overflow at 200 %
// text on a small phone; the first-run setup is offered once, only without
// a site, and Skip / Done close it for good.

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/core/theme/app_typography.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/domain/models/location_profile.dart';
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
import 'package:astroplan/domain/models/night_timeline.dart';
import 'package:astroplan/domain/models/planning_preferences.dart';
import 'package:astroplan/presentation/shared/app_words.dart';
import 'package:astroplan/presentation/shared/night_text.dart';
import 'package:astroplan/presentation/shared/night_time_formatter.dart';
import 'package:astroplan/presentation/navigation/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/fake_location_service.dart';
import '../../../support/in_memory_first_run.dart';
import '../../../support/no_snapshot_weather.dart';
import '../../../support/planner_harness.dart';
import '../../../support/library_finders.dart';

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

  Future<void> reveal(WidgetTester tester, String key) async {
    await tester.scrollUntilVisible(
      find.byKey(Key(key)),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await settle(tester);
  }

  testWidgets('no site: the site prompt replaces the night rows', (
    tester,
  ) async {
    await start(tester, site: false);
    await reveal(tester, 'tonight.noSite');
    expect(find.byKey(const Key('tonight.noSite')), findsOneWidget);
    expect(find.byKey(const Key('tonight.night')), findsNothing);
    expect(find.byKey(const Key('tonight.fit')), findsNothing);
    expect(find.text('Use current position'), findsOneWidget);
  });

  testWidgets('with a site: night, Moon and weather rows', (tester) async {
    await start(tester);
    expect(find.byKey(const Key('tonight.noSite')), findsNothing);
    await reveal(tester, 'tonight.night');
    expect(find.byKey(const Key('tonight.night')), findsOneWidget);
    // F17 A1: the dark interval, not sunset to sunrise (on Night & Moon);
    // app.js conditions: the span, then its length.
    expect(find.textContaining('Sunset to sunrise:'), findsNothing);
    expect(
      find.descendant(
        of: find.byKey(const Key('tonight.night')),
        matching: find.textContaining(' dark'),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('tonight.moon')), findsOneWidget);
    // app.js conditions: the phase and the night's illumination; the hour
    // it applies to is on Night & Moon (SCI-09).
    expect(
      find.descendant(
        of: find.byKey(const Key('tonight.moon')),
        matching: find.textContaining('% lit'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('no forecast: says so, never a number', (tester) async {
    await start(tester);
    await reveal(tester, 'tonight.weather');
    final weather = find.byKey(const Key('tonight.weather'));
    expect(weather, findsOneWidget);
    expect(
      find.descendant(
        of: weather,
        matching: find.textContaining(
          RegExp('Forecast unavailable|No forecast yet'),
        ),
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
    expect(find.text(StatusBlock.headline(fit.state)), findsOneWidget);
    expect(find.text('Usable'), findsOneWidget);
    expect(
      find.text(QuantityText.duration(Duration(milliseconds: fit.availableMs))),
      findsOneWidget,
    );
    expect(find.text(fit.reason), findsOneWidget);
  });

  testWidgets("a huge plan doesn't fit, with the reason", (tester) async {
    await start(tester, lightFrames: 2000);
    final fit = vm.fitAnalysis;
    expect(fit.state, FitState.doesNotFit);
    expect(find.text(StatusBlock.headline(fit.state)), findsOneWidget);
    // The Hybrid status writes the needed time to the second.
    expect(
      find.text(
        QuantityText.budgetDuration(Duration(milliseconds: fit.windowLoadMs)),
      ),
      findsOneWidget,
    );
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
    testWidgets('Hybrid order: site and night, plan, night rows, next action', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await start(tester, lightFrames: 10);
      double y(String key) => tester.getTopLeft(find.byKey(Key(key))).dy;
      final order = [
        'tonight.title',
        'tonight.context',
        'tonight.plan',
        'tonight.night',
        'tonight.moon',
        'tonight.weather',
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
        'context is open with independent actions', (tester) async {
      await start(tester, lightFrames: 10);
      final handle = tester.ensureSemantics();
      final title = find.byKey(const Key('tonight.title'));
      expect(title, findsOneWidget);
      expect(
        tester.widget<Text>(title).style?.fontSize,
        AppTypography.homeHeading.fontSize,
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
        findsNothing,
      );
    });

    testWidgets('TD-077: "Your plan" is the card\'s heading; the target and '
        'rig read below it', (tester) async {
      tester.view.physicalSize = const Size(412, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await start(tester, lightFrames: 10);
      final handle = tester.ensureSemantics();
      final heading = find.byKey(const Key('tonight.planHeading'));
      final style = tester.widget<Text>(heading).style!;
      expect(tester.widget<Text>(heading).data, AppWords.yourPlan);
      // Approved Hybrid (hybrid-refinement.css): the section heading role,
      // 20/600 at 1.4, -0.15.
      expect(style.fontSize, 20);
      expect(style.fontWeight, FontWeight.w600);
      expect(style.height, 1.4);
      expect(style.letterSpacing, -0.15);
      expect(
        tester.getSemantics(heading),
        matchesSemantics(label: AppWords.yourPlan, isHeader: true),
      );
      handle.dispose();
      final target = tester
          .widget<Text>(find.byKey(const Key('tonight.planTarget')))
          .style!;
      // The section subject role, 18/500 at 1.3.
      expect(target.fontSize, 18);
      expect(target.fontWeight, FontWeight.w500);
      expect(target.height, closeTo(1.3, 0.001));
      expect(target.letterSpacing, 0);
      final rig = tester.widget<Text>(find.byKey(const Key('tonight.planRig')));
      expect(rig.style?.fontSize, 14);
      expect(rig.style?.height, 1.55);
      final nightHeading = tester.widget<Text>(find.text('The night ahead'));
      expect(nightHeading.style?.fontSize, 25);
      expect(nightHeading.style?.fontFamily, 'Geist');
      expect(nightHeading.style?.fontWeight, FontWeight.w500);
      expect(nightHeading.style?.letterSpacing, -0.5);
      final title = tester.widget<Text>(find.byKey(const Key('tonight.title')));
      expect(title.style?.height, closeTo(1.2, 0.001));
      // The accepted Home has no wordmark and no Welcome link (contract
      // §2; first-run onboarding stays).
      expect(find.text('culmina'), findsNothing);
      expect(find.text('Welcome & setup'), findsNothing);
      // Hybrid's rig line leads with the catalogue ID of a named target.
      expect(
        tester.widget<Text>(find.byKey(const Key('tonight.planRig'))).data,
        startsWith('M42 · '),
      );
      // Hybrid's fit line: a mark beside a 13 px verdict.
      final verdict = tester
          .widget<Text>(
            find.descendant(
              of: find.byKey(const Key('tonight.status')),
              matching: find.byKey(const Key('status.headline')),
            ),
          )
          .style!;
      expect(verdict.fontSize, 13);
      expect(verdict.fontWeight, FontWeight.w500);
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
      // app.js `candidates` detail: the sheet's title is the action.
      expect(find.byKey(const Key('tonight.header')), findsOneWidget);
      expect(find.text('What can I image tonight?'), findsWidgets);
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

    testWidgets('Tonight context opens site management directly', (
      tester,
    ) async {
      await start(tester, lightFrames: 10);
      await tester.tap(find.byKey(const Key('context.site')));
      await settle(tester);
      expect(find.text('Manage sites'), findsOneWidget);
      expect(find.byKey(const Key('sites.search')), findsNothing);
      expect(find.text('Sites'), findsOneWidget);
      expect(find.byKey(const Key('sites.add')), findsOneWidget);
      expect(find.text('Observing site'), findsNothing);
      expect(find.byKey(const Key('homeSite.apply')), findsNothing);
    });

    for (final scale in [1.0, 2.0]) {
      testWidgets('Tonight keeps a long site and night on one line at $scale', (
        tester,
      ) async {
        await start(tester, lightFrames: 10);
        const name =
            '\u0414\u0443\u0436\u0435 \u0434\u043e\u0432\u0433\u0430 \u043d\u0430\u0437\u0432\u0430 \u043c\u0456\u0441\u0446\u044f \u0434\u043b\u044f \u0430\u0441\u0442\u0440\u043e\u043d\u043e\u043c\u0456\u0447\u043d\u0438\u0445 \u0441\u043f\u043e\u0441\u0442\u0435\u0440\u0435\u0436\u0435\u043d\u044c \u0431\u0456\u043b\u044f \u043c\u0456\u0441\u0442\u0430';
        await tester.runAsync(
          () => vm.site.saveSite(
            LocationProfile(
              id: 0,
              name: name,
              latitude: 46.05,
              longitude: 14.51,
            ),
          ),
        );
        tester.view.physicalSize = const Size(375, 760);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearAllTestValues);
        await settle(tester);
        final site = tester.getRect(find.byKey(const Key('context.site')));
        final night = tester.getRect(find.byKey(const Key('context.night')));
        expect(site.top, night.top);
        expect(site.height, 48);
        expect(night.height, 48);
        expect(site.right, lessThanOrEqualTo(night.left));
        final title = tester.widget<Text>(find.text(name));
        expect(title.maxLines, 1);
        expect(title.overflow, TextOverflow.ellipsis);
        final handle = tester.ensureSemantics();
        expect(
          tester.getSemantics(find.byKey(const Key('context.site'))).label,
          contains(name),
        );
        handle.dispose();
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets(
      'Tonight shows a compact position label without coordinate text',
      (tester) async {
        await start(tester, lightFrames: 10);
        final context = find.byKey(const Key('tonight.context'));
        expect(
          find.descendant(of: context, matching: find.text('Position')),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: context,
            matching: find.textContaining('46.0500'),
          ),
          findsNothing,
        );
        final site = tester.getRect(find.byKey(const Key('context.site')));
        final night = tester.getRect(find.byKey(const Key('context.night')));
        expect(site.top, night.top);
      },
    );

    testWidgets('Tonight context stays compact with 48 dp touch targets', (
      tester,
    ) async {
      await start(tester, lightFrames: 10);
      final subtitle = tester.getRect(
        find.text('A clear plan for the night ahead.'),
      );
      final row = tester.getRect(find.byKey(const Key('tonight.context')));
      expect(row.top - subtitle.bottom, 0);
      expect(
        tester.getSize(find.byKey(const Key('context.site'))).height,
        greaterThanOrEqualTo(48),
      );
      expect(
        tester.getSize(find.byKey(const Key('context.night'))).height,
        greaterThanOrEqualTo(48),
      );
      final section = tester.getRect(find.byKey(const Key('tonight.plan')));
      expect(section.top - row.bottom, 0);
    });

    testWidgets(
      'Tonight calendar keeps two-digit days on one line at 200 percent',
      (tester) async {
        await (FontLoader(
          'Geist',
        )..addFont(rootBundle.load('assets/fonts/Geist.ttf'))).load();
        tester.view.physicalSize = const Size(375, 760);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearAllTestValues);
        await start(tester, lightFrames: 10);
        await tester.tap(find.byKey(const Key('context.night')));
        await settle(tester);
        final day = find.descendant(
          of: find.byType(DatePickerDialog),
          matching: find.text('20'),
        );
        final paragraph = tester.renderObject<RenderParagraph>(day);
        expect(
          paragraph.getBoxesForSelection(
            const TextSelection(baseOffset: 0, extentOffset: 2),
          ),
          hasLength(1),
        );
        expect(MediaQuery.textScalerOf(tester.element(day)).scale(14), 28);
        await tester.tap(find.text('Cancel'));
        await settle(tester);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets("the night picker changes the plan's night, and the plan "
        'autosaves', (tester) async {
      await start(tester, lightFrames: 10);
      expect(vm.plan.eveningDate, CalendarDate(2026, 12, 15));
      await tester.tap(find.byKey(const Key('context.night')));
      await settle(tester);
      expect(find.byType(DatePickerDialog), findsOneWidget);
      expect(find.byKey(const Key('homeNight.apply')), findsNothing);
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

    // F17 A3 (D9 A): Cancel in Home's night picker keeps the plan as it
    // was, an unsaved edit included: the same night, the same blocks and
    // the same fit and its text.
    testWidgets("the night picker's Cancel keeps the plan, its edit and its "
        'results', (tester) async {
      await start(tester, lightFrames: 10);
      await tester.runAsync(() async {
        await vm.plan.addCaptureBlock(
          CaptureBlock(
            frameType: FrameType.light,
            filterName: 'Ha',
            exposureTimeSeconds: 300,
            frameCount: 7,
          ),
        );
        await vm.plan.idle;
      });
      await settle(tester);
      final status = find.byKey(const Key('tonight.status'));
      List<String> texts(Finder of) => [
        for (final t in tester.widgetList<Text>(
          find.descendant(of: of, matching: find.byType(Text)),
        ))
          t.data ?? t.textSpan!.toPlainText(),
      ];
      List<(String?, int, double, FrameType)> blocks() => [
        for (final b in vm.plan.captureBlocks)
          (b.filterName, b.frameCount, b.exposureTimeSeconds, b.frameType),
      ];
      final night = vm.plan.eveningDate;
      expect(night, CalendarDate(2026, 12, 15));
      final before = blocks();
      expect(before, [
        ('L', 10, 60.0, FrameType.light),
        ('Ha', 7, 300.0, FrameType.light),
      ]);
      final fit = vm.analysis.fitAnalysis;
      final statusText = texts(status);
      final contextText = texts(find.byKey(const Key('tonight.context')));
      expect(statusText, isNotEmpty);
      // 10 × 60 s + 7 × 300 s = 45 min of light frames.
      expect(
        vm.analysis.captureBudget.integration,
        const Duration(minutes: 45),
      );

      await tester.tap(find.byKey(const Key('context.night')));
      await settle(tester);
      expect(find.byType(DatePickerDialog), findsOneWidget);
      await tester.tap(find.text('20')); // highlighted, then cancelled
      await tester.tap(find.text('Cancel'));
      await settle(tester);
      await tester.runAsync(() => vm.plan.idle);
      expect(find.byKey(const Key('homeNight.apply')), findsNothing);

      expect(vm.plan.eveningDate, night);
      expect(blocks(), before);
      expect(vm.analysis.fitAnalysis.state, fit.state);
      expect(vm.analysis.fitAnalysis.windowLoadMs, fit.windowLoadMs);
      expect(vm.analysis.fitAnalysis.availableMs, fit.availableMs);
      expect(vm.analysis.fitAnalysis.reason, fit.reason);
      expect(texts(status), statusText);
      expect(texts(find.byKey(const Key('tonight.context'))), contextText);
      expect(
        vm.analysis.captureBudget.integration,
        const Duration(minutes: 45),
      );
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
        await reveal(tester, 'tonight.night');
        final ctx = tester.element(find.byKey(const Key('tonight.night')));
        final night = vm.conditions.nightTimeline!.night;
        String at(DateTime utc) => NightTimeFormatter.instant(
          ctx,
          utc,
          windowStartUtc: night.startUtc,
          zoneId: vm.site.displayZoneId,
        );
        // app.js conditions: the dark span at the user's limit.
        final (from, to) = switch (dark) {
          SunCrossing(:final duskUtc, :final dawnUtc) => (
            duskUtc ?? night.startUtc,
            dawnUtc ?? night.endUtc,
          ),
          _ => (night.startUtc, night.endUtc),
        };
        expect(
          find.descendant(
            of: find.byKey(const Key('tonight.night')),
            matching: find.text('${at(from)}–${at(to)}'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byKey(const Key('tonight.night')),
            matching: find.textContaining(
              '${QuantityText.duration(to.difference(from))} dark',
            ),
          ),
          findsOneWidget,
        );
      });
    }

    // F17 A1 (ADR-022 N4/N5): the phase and the moon-free dark time.
    testWidgets('the Moon row gives the phase and the moon-free dark time', (
      tester,
    ) async {
      await start(tester, lightFrames: 10);
      await reveal(tester, 'tonight.moon');
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
      String at(DateTime utc) => NightTimeFormatter.instant(
        ctx,
        utc,
        windowStartUtc: moon.night.startUtc,
        zoneId: vm.site.displayZoneId,
      );
      // app.js conditions: "Moon-free 00:30–04:45 (+1) · 4 h 15 min".
      expect(
        find.descendant(
          of: row,
          matching: find.text(
            'Moon-free ${free.intervals.map((i) => '${at(i.$1)}–${at(i.$2)}').join(', ')}'
            ' · ${QuantityText.duration(free.moonFree)}',
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
          of: find.byKey(AppShell.navigationKey),
          matching: find.text('Tonight'),
        ),
        findsOneWidget,
      );
      // The plan card's status (fit or missing input) names that night too.
      final card = find.descendant(
        of: find.byKey(const Key('tonight.plan')),
        matching: find.byType(Text),
      );
      final words = [
        for (final t in tester.widgetList<Text>(card))
          t.data ?? t.textSpan?.toPlainText() ?? '',
      ].join(' | ');
      expect(words.toLowerCase(), isNot(contains('tonight')), reason: words);
      await tester.tap(find.byKey(const Key('tonight.candidates')));
      await settle(tester);
      expect(find.text('What can I image on $named?'), findsOneWidget);
    });

    testWidgets('a missing target on another plan night names that night', (
      tester,
    ) async {
      await start(tester);
      await tester.runAsync(() async {
        await vm.lifecycle.newSession();
        await vm.plan.idle;
        await vm.plan.setEveningDate(vm.plan.tonightKey.addDays(2));
      });
      await settle(tester);
      final named = NightTimeFormatter.eveningDate(
        vm.plan.tonightKey.addDays(2),
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('tonight.status')),
          matching: find.text('Choose a target to see the windows on $named.'),
        ),
        findsOneWidget,
      );
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
      expect(find.byKey(AppShell.navigationKey), findsNothing);
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
      await reveal(tester, 'tonight.noSite');
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
      // The scoped chooser closes with its × (plan.js scoped pages).
      await tester.tap(find.byKey(const Key('scoped.close')));
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
      await tester.enterText(fieldLabeled('Rig name'), 'Garden DSLR');
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
        fieldLabeled('Effective focal length (mm)'),
        '135',
      );
      await tester.enterText(fieldLabeled('Focal ratio (f/)'), '2.8');
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
