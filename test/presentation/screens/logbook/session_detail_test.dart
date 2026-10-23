// TASK 14.1: the Sessions list filters, and the session detail from its
// snapshot — a completed run (execution-start snapshot, plan vs actual,
// notes), a planned session (plan snapshot), a legacy log (stored text,
// badge) and a session without a snapshot. Acceptance: legacy and new
// sessions both render.

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/execution.dart';
import 'package:astroplan/domain/models/session.dart';
import 'package:astroplan/domain/models/night_weather.dart';
import 'package:astroplan/domain/models/weather_snapshot.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/domain/services/night_weather_summarizer.dart';
import 'package:astroplan/domain/services/session_snapshot_builder.dart';
import 'package:astroplan/domain/services/visibility_calculator.dart';
import 'package:astroplan/domain/services/session_exporter.dart';
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/fake_location_service.dart';
import '../../../support/fake_reverse_geocoder.dart';
import '../../../support/no_snapshot_weather.dart';
import '../../../support/planner_harness.dart';
import '../../../support/legacy_run.dart';

class _NoForecast with NoSnapshotWeather implements WeatherRepository {}

/// F19 A3: today's live forecast, unlike the one saved with the plan: another
/// source, fetched now, 85 % cloud over every requested hour.
class _LiveForecast implements WeatherRepository {
  _LiveForecast(this.clock);

  final Clock clock;
  int calls = 0;

  @override
  Future<WeatherFetch> fetchSnapshot({
    required double latitude,
    required double longitude,
    required DateTime startUtc,
    required DateTime endUtc,
  }) async {
    calls++;
    final first = DateTime.utc(
      startUtc.year,
      startUtc.month,
      startUtc.day,
      startUtc.hour,
    );
    return WeatherFetched(
      WeatherSnapshot(
        provider: 'live-provider',
        model: 'live_model',
        fetchedAtUtc: clock.nowUtc(),
        latitude: latitude,
        longitude: longitude,
        hours: [
          for (
            var t = first;
            t.isBefore(endUtc);
            t = t.add(const Duration(hours: 1))
          )
            WeatherHour(timeUtc: t, cloudCoverPct: 85),
        ],
      ),
    );
  }
}

/// Records what would be shared (TASK 14.3).
class _RecordingExporter implements SessionExporter {
  final List<List<ExportedSession>> shared = [];

  @override
  Future<void> share(List<ExportedSession> sessions) async =>
      shared.add(sessions);
}

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

void main() {
  late AppDatabase database;
  late DriftSessionRepository sessions;
  late PlannerHarness vm;
  late int completedId;
  late int plannedId;
  late _RecordingExporter exporter;
  const legacyId = 900;
  const noSnapshotId = 901;

  /// A completed run (10 of 24 × 300 s, with notes), a planned session, a
  /// legacy log and a planned session saved without a snapshot.
  Future<void> seed(WidgetTester tester, {WeatherRepository? weather}) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      SharedPreferences.setMockInitialValues({});
      exporter = _RecordingExporter();
      final clock = FixedClock(DateTime.utc(2026, 12, 15, 19));
      database = AppDatabase(NativeDatabase.memory());
      sessions = DriftSessionRepository(database, clock: clock);
      await DriftTargetRepository(database).insertTarget(_m42);
      await DriftEquipmentRepository(database).insertEquipment(_rig);
      vm = PlannerHarness(
        DriftTargetRepository(database),
        DriftEquipmentRepository(database),
        weather ?? _NoForecast(),
        DriftLocationRepository(database),
        locationService: FakeLocationService(),
        reverseGeocoder: FakeReverseGeocoder(),
        sessionRepository: sessions,
        clock: clock,
        exporter: exporter,
      );
      await vm.ready;
      await vm.choosePlan(); // S6.8: nothing is preselected
      await vm.site.setLocation(46.05, 14.5);
      while (vm.plan.captureBlocks.isNotEmpty) {
        await vm.plan.removeCaptureBlock(0);
      }
      await vm.plan.addCaptureBlock(
        CaptureBlock(
          frameType: FrameType.light,
          filterName: 'L',
          exposureTimeSeconds: 300,
          frameCount: 24,
        ),
      );
      await vm.plan.idle;
      final run = await startLegacyRun(
        sessions,
        await vm.analysis.saveSession(),
      );
      completedId = run.id;
      await sessions.record(
        run.id,
        ExecutionEventKind.framesConfirmed,
        blockId: run.blocks.single.id,
        delta: 10,
      );
      await sessions.complete(run.id);
      await sessions.updateResults(
        run.id,
        const SessionResults(
          actualLightFrames: 10,
          environmentalNotes: 'Wind after 23:00',
          temperatureC: -3,
        ),
      );
      plannedId = (await vm.analysis.saveSession()).id;
      await database.customStatement(
        "INSERT INTO session_logs (id, target_name, equipment_name, "
        "session_date, planned_light_frames, actual_light_frames, status, "
        "legacy) VALUES ($legacyId, 'M31', 'Old rig', 1767225600, 40, 35, "
        "'completed', 1), ($noSnapshotId, 'M45', 'Rig', 1767225600, 5, NULL, "
        "'planned', 0);",
      );
      await database.customStatement(
        "UPDATE session_logs SET evening_date = '2026-12-10' "
        'WHERE id = $noSnapshotId;',
      );
    });
    addTearDown(() => tester.runAsync(database.close));
  }

  Future<void> pumpAt(WidgetTester tester, String location) async {
    AppRouter.router.go(location);
    await tester.pumpWidget(
      MultiProvider(providers: vm.providers, child: const AstroPlanApp()),
    );
    await settle(tester);
  }

  /// The label/value rows under [key] as "Label: value" lines joined by
  /// " | " (the Hybrid facts are two texts per row).
  String facts(WidgetTester tester, String key) {
    final texts = [
      for (final t in tester.widgetList<Text>(
        find.descendant(of: find.byKey(Key(key)), matching: find.byType(Text)),
      ))
        t.data ?? t.textSpan!.toPlainText(),
    ];
    return [
      for (var i = 0; i + 1 < texts.length; i += 2)
        '${texts[i]}: ${texts[i + 1]}',
    ].join(' | ');
  }

  /// Every text under [key], joined by " | ".
  String texts(WidgetTester tester, String key) => [
    for (final t in tester.widgetList<Text>(
      find.descendant(of: find.byKey(Key(key)), matching: find.byType(Text)),
    ))
      t.data ?? t.textSpan!.toPlainText(),
  ].join(' | ');

  /// Opens the entry's disclosure titled [title].
  Future<void> open(WidgetTester tester, String title) async {
    await tester.ensureVisible(find.text(title));
    await tester.tap(find.text(title));
    await settle(tester);
  }

  testWidgets('the Completed filter (in the panel, S8.5) filters the list in '
      'the query', (tester) async {
    await seed(tester);
    await pumpAt(tester, AppRouter.sessions);
    expect(find.byKey(Key('logbook.status.$plannedId')), findsOneWidget);
    await tester.tap(find.byKey(const Key('logbook.filterToggle')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('logbook.filter.completed')));
    await settle(tester);
    expect(find.byKey(Key('logbook.status.$completedId')), findsOneWidget);
    expect(find.byKey(const Key('logbook.status.$legacyId')), findsOneWidget);
    expect(find.byKey(Key('logbook.status.$plannedId')), findsNothing);
    await tester.ensureVisible(find.byKey(const Key('logbook.filters.clear')));
    await tester.tap(find.byKey(const Key('logbook.filters.clear')));
    await settle(tester);
    expect(find.byKey(Key('logbook.status.$plannedId')), findsOneWidget);
  });

  testWidgets('the target filter keeps only that target (legacy excluded)', (
    tester,
  ) async {
    await seed(tester);
    await pumpAt(tester, AppRouter.sessions);
    await tester.tap(find.byKey(const Key('logbook.filterToggle')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('logbook.filter.target')));
    await settle(tester);
    await tester.tap(find.text('Orion Nebula').last);
    await settle(tester);
    expect(
      find.descendant(
        of: find.byKey(const Key('logbook.filter.target')),
        matching: find.text('Orion Nebula'),
      ),
      findsOneWidget,
      reason: 'the panel',
    );
    expect(find.byKey(Key('logbook.status.$completedId')), findsOneWidget);
    expect(find.byKey(const Key('logbook.status.$legacyId')), findsNothing);
  });

  testWidgets('the legacy row reads Old log (S8.5); a tap opens the detail', (
    tester,
  ) async {
    await seed(tester);
    await pumpAt(tester, AppRouter.sessions);
    expect(
      find.descendant(
        of: find.byKey(const Key('logbook.status.$legacyId')),
        matching: find.text('Old log'),
      ),
      findsOneWidget,
    );
    await tester.tap(find.textContaining('M31'));
    await settle(tester);
    expect(find.byKey(const Key('detail.legacy')), findsOneWidget);
  });

  testWidgets('S8.6: a name is set on the entry, never asked at Save; the '
      'Logbook shows it and searches it; removing it shows target · night', (
    tester,
  ) async {
    await seed(tester);
    await pumpAt(tester, AppRouter.sessionDetail(plannedId));
    await tester.tap(find.byKey(const Key('detail.name')));
    await settle(tester);
    await tester.enterText(
      find.byKey(const Key('detail.nameField')),
      '  Orion, first light ',
    );
    await tester.tap(find.byKey(const Key('detail.nameSave')));
    await settle(tester);
    expect(find.text('Orion, first light'), findsWidgets);
    expect(find.text('Name saved'), findsOneWidget); // S9.8

    AppRouter.router.go(AppRouter.sessions);
    await settle(tester);
    expect(
      tester.widget<Text>(find.byKey(Key('logbook.title.$plannedId'))).data,
      'Orion, first light',
    );
    await tester.tap(find.byKey(const Key('logbook.searchToggle')));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('logbook.search')), 'first l');
    await settle(tester);
    expect(find.byKey(Key('logbook.title.$plannedId')), findsOneWidget);
    expect(find.byKey(Key('logbook.title.$completedId')), findsNothing);
    await tester.tap(find.byKey(const Key('logbook.searchToggle')));
    await settle(tester);

    AppRouter.router.go(AppRouter.sessionDetail(plannedId));
    await settle(tester);
    await tester.tap(find.byKey(const Key('detail.name')));
    await settle(tester);
    await tester.enterText(find.byKey(const Key('detail.nameField')), '');
    await tester.tap(find.byKey(const Key('detail.nameSave')));
    await settle(tester);
    expect(find.text('Name removed'), findsOneWidget); // S9.8
    AppRouter.router.go(AppRouter.sessions);
    await settle(tester);
    final title = tester
        .widget<Text>(find.byKey(Key('logbook.title.$plannedId')))
        .data;
    expect(title, isNot('Orion, first light'));
    expect(title, contains(' · '), reason: 'target · night');
  });
  testWidgets('acceptance: a completed run renders from its execution-start '
      'snapshot with plan vs actual and notes', (tester) async {
    await seed(tester);
    await pumpAt(tester, AppRouter.sessionDetail(completedId));
    expect(find.text('At the start of imaging'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('detail.status')),
        matching: find.textContaining('Completed'),
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Orion Nebula'), findsWidgets);
    // Planned and recorded: the block's plan and its count.
    expect(find.textContaining('L · 300 s'), findsWidgets);
    expect(
      texts(tester, 'detail.block.0'),
      allOf(
        contains('Planned | 24 × 300 s · 2 h'),
        contains('10 frames · 50 min'),
      ),
    );
    // S8.7: the result's summary; the totals in planned and recorded.
    expect(find.text('Integration: 50 min of 2 h planned'), findsOneWidget);
    expect(
      texts(tester, 'detail.planVsActual'),
      contains('Recorded integration | 50 min'),
    );
    expect(find.text('Wind after 23:00'), findsOneWidget);
    expect(
      facts(tester, 'detail.conditions'),
      contains('Temperature: −3.0 °C'),
    );
    await open(tester, 'At the start of imaging');
    expect(find.byKey(const Key('detail.night')), findsOneWidget);
    expect(facts(tester, 'detail.night'), contains('Times in: '));
    expect(find.textContaining('Refractor 400'), findsWidgets);
    expect(find.byKey(const Key('detail.editResults')), findsOneWidget);
    // S8.7 (I-6): a result offers Edit result and Copy to another night.
    expect(find.text('Copy to another night'), findsOneWidget);
    expect(find.byKey(const Key('detail.openInPlanner')), findsNothing);
    // S1.7 (UX-19): RA/Dec as in the target editor; typographic minus.
    expect(facts(tester, 'detail.target'), contains('05h35m16.8s, −05°23′24″'));
    expect(facts(tester, 'detail.night'), contains('Darkness limit: −18°'));
  });

  testWidgets('a planned session renders from its plan snapshot', (
    tester,
  ) async {
    await seed(tester);
    await pumpAt(tester, AppRouter.sessionDetail(plannedId));
    expect(find.text('Plan as saved'), findsOneWidget);
    expect(
      texts(tester, 'detail.block.0'),
      contains('Planned | 24 × 300 s · 2 h'),
    );
    expect(find.text('Open in planner'), findsOneWidget);
    expect(find.byKey(const Key('detail.editResults')), findsNothing);
    // Notes and conditions: none recorded, said once; never "Notes: none".
    expect(find.text('None recorded.'), findsOneWidget);
    expect(find.textContaining('Notes: '), findsNothing);
    // S1.8 (UX-20, UX-18): no raw double, and the night key is not called
    // a window.
    await open(tester, 'Plan as saved');
    expect(facts(tester, 'detail.rig'), contains('Focal ratio: f/5.0'));
    expect(facts(tester, 'detail.night'), contains('Night span: '));
    expect(facts(tester, 'detail.night'), isNot(contains('Window: ')));
  });

  // F19 A3: the entry shows the forecast saved with the plan — its source,
  // fetch time and age then — never today's in its place.
  testWidgets('the entry\'s forecast is the one saved with the plan', (
    tester,
  ) async {
    await seed(tester);
    await tester.runAsync(() async {
      final night = vm.plan.sessionNight!;
      final prefs = vm.settings.planningPreferences;
      final span = NightWeatherSummarizer.spanOf(
        VisibilityCalculator.calculateNightTimelineForNight(night),
      );
      final forecast = WeatherSnapshot(
        provider: 'open-meteo',
        model: 'best_match',
        fetchedAtUtc: DateTime.utc(2026, 12, 15, 9),
        latitude: 46.05,
        longitude: 14.5,
        hours: [
          for (var h = 17; h < 24; h++)
            WeatherHour(
              timeUtc: DateTime.utc(2026, 12, 15, h),
              cloudCoverPct: h < 20 ? 15 : 40,
            ),
        ],
      );
      await sessions.savePlan(
        plannedId,
        vm.plan.currentPlan(),
        SessionSnapshotBuilder.build(
          takenAtUtc: DateTime.utc(2026, 12, 15, 19),
          night: night,
          timeZoneId: 'Europe/Ljubljana',
          preferences: prefs,
          budget: vm.analysis.captureBudget,
          blocks: vm.plan.captureBlocks,
          site: vm.site.activeSite,
          target: vm.plan.selectedTarget,
          rig: vm.plan.selectedEquipment,
          weather: NightWeatherAvailable(
            snapshot: forecast,
            age: WeatherAge.aging,
            ageDuration: const Duration(hours: 10),
            fromCache: true,
          ),
          weatherSummary: NightWeatherSummarizer.summarize(
            forecast,
            fromUtc: span.fromUtc,
            toUtc: span.toUtc,
            dewMarginC: prefs.dewMarginC,
          ),
        ),
      );
    });
    await pumpAt(tester, AppRouter.sessionDetail(plannedId));
    await open(tester, 'Plan as saved');
    final weather = facts(tester, 'detail.weather');
    for (final text in [
      'Forecast: as saved with the plan',
      'Source: open-meteo / best_match',
      'Age when saved: aging',
      'Cloud cover (dark hours): 15–40%',
    ]) {
      expect(weather, contains(text), reason: text);
    }
    expect(
      weather,
      contains('Hours without forecast: '),
      reason: 'the saved hours after midnight had none',
    );
  });

  // F19 A3, with a live forecast that differs: the entry keeps the saved
  // one (its source, its fetch time and its age then), never today's.
  testWidgets('the entry keeps the saved forecast while a different live '
      'one is loaded', (tester) async {
    final live = _LiveForecast(FixedClock(DateTime.utc(2026, 12, 15, 19)));
    await seed(tester, weather: live);
    await tester.runAsync(() async {
      final night = vm.plan.sessionNight!;
      final prefs = vm.settings.planningPreferences;
      final span = NightWeatherSummarizer.spanOf(
        VisibilityCalculator.calculateNightTimelineForNight(night),
      );
      final forecast = WeatherSnapshot(
        provider: 'open-meteo',
        model: 'best_match',
        fetchedAtUtc: DateTime.utc(2026, 12, 15, 9),
        latitude: 46.05,
        longitude: 14.5,
        hours: [
          for (var h = 17; h < 24; h++)
            WeatherHour(
              timeUtc: DateTime.utc(2026, 12, 15, h),
              cloudCoverPct: h < 20 ? 15 : 40,
            ),
        ],
      );
      await sessions.savePlan(
        plannedId,
        vm.plan.currentPlan(),
        SessionSnapshotBuilder.build(
          takenAtUtc: DateTime.utc(2026, 12, 15, 19),
          night: night,
          timeZoneId: 'Europe/Ljubljana',
          preferences: prefs,
          budget: vm.analysis.captureBudget,
          blocks: vm.plan.captureBlocks,
          site: vm.site.activeSite,
          target: vm.plan.selectedTarget,
          rig: vm.plan.selectedEquipment,
          weather: NightWeatherAvailable(
            snapshot: forecast,
            age: WeatherAge.aging,
            ageDuration: const Duration(hours: 10),
            fromCache: true,
          ),
          weatherSummary: NightWeatherSummarizer.summarize(
            forecast,
            fromUtc: span.fromUtc,
            toUtc: span.toUtc,
            dewMarginC: prefs.dewMarginC,
          ),
        ),
      );
      await vm.conditions.refreshWeather();
      await vm.conditions.idle;
    });
    // The live forecast is loaded, and it is different.
    expect(live.calls, greaterThan(0));
    final now = vm.conditions.nightWeather;
    expect(now, isA<NightWeatherAvailable>());
    now as NightWeatherAvailable;
    expect(now.snapshot.provider, 'live-provider');
    expect(now.age, WeatherAge.current);
    expect(now.snapshot.fetchedAtUtc, DateTime.utc(2026, 12, 15, 19));

    await pumpAt(tester, AppRouter.sessionDetail(plannedId));
    await open(tester, 'Plan as saved');
    final text = facts(tester, 'detail.weather');
    for (final saved in [
      'as saved with the plan',
      'open-meteo / best_match',
      '15–40%',
    ]) {
      expect(text, contains(saved), reason: saved);
    }
    // The fetch time as saved: 09:00 UTC is 10:00 in Ljubljana (CET).
    expect(text, contains('Fetched'));
    expect(
      text,
      matches(RegExp(r'Fetched:\s*10:00 AM \| Age when saved: aging')),
    );
    // Its age when saved, not the live forecast's.
    expect(text, contains('aging'));
    expect(text, isNot(contains('current')));
    // Nothing of the live forecast in the entry.
    expect(text, isNot(contains('live-provider')));
    expect(text, isNot(contains('live_model')));
    expect(text, isNot(contains('85')));
  });

  testWidgets('acceptance: a legacy log renders its stored text only', (
    tester,
  ) async {
    await seed(tester);
    await pumpAt(tester, AppRouter.sessionDetail(legacyId));
    expect(find.byKey(const Key('detail.legacy')), findsOneWidget);
    expect(find.byKey(const Key('detail.night')), findsNothing);
    expect(
      texts(tester, 'detail.planVsActual'),
      allOf(
        contains('Actual light frames | 35'),
        contains('Rejected frames | unknown'),
      ),
    );
    expect(find.textContaining('unknown'), findsWidgets);
    // S8.7 (I-6): an old log offers Share and Export as file only.
    expect(find.byKey(const Key('detail.copy')), findsNothing);
    expect(find.byKey(const Key('detail.openInPlanner')), findsNothing);
    await open(tester, 'Export this entry');
    expect(find.byKey(const Key('detail.share')), findsOneWidget);
  });

  testWidgets('a session without a snapshot says so, never zeros', (
    tester,
  ) async {
    await seed(tester);
    await pumpAt(tester, AppRouter.sessionDetail(noSnapshotId));
    expect(find.byKey(const Key('detail.noSnapshot')), findsOneWidget);
  });

  testWidgets('TASK 14.2: the detail shows the target so far; Library → '
      'Progress lists it', (tester) async {
    await seed(tester);
    await pumpAt(tester, AppRouter.sessionDetail(completedId));
    expect(find.text('This target so far'), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('progress.total.1'))).data,
      '50 min',
    );
    expect(
      tester.widget<Text>(find.byKey(const Key('progress.results.1'))).data,
      startsWith('1 result · Last imaged '),
    );
    expect(find.text('L'), findsOneWidget);
    AppRouter.router.go(AppRouter.logbookProgress);
    await settle(tester);
    expect(find.byKey(const Key('progress.1')), findsOneWidget);
    expect(find.text('Orion Nebula'), findsWidgets);
  });

  testWidgets('TASK 14.2: Progress says so when nothing is completed', (
    tester,
  ) async {
    await seed(tester);
    await tester.runAsync(() => sessions.delete(completedId));
    await pumpAt(tester, AppRouter.logbookProgress);
    expect(find.byKey(const Key('progress.empty')), findsOneWidget);
  });

  testWidgets('TASK 14.3: Export file shares that session with its events', (
    tester,
  ) async {
    await seed(tester);
    await pumpAt(tester, AppRouter.sessionDetail(completedId));
    await open(tester, 'Export this entry');
    await tester.ensureVisible(find.byKey(const Key('detail.export')));
    await tester.tap(find.byKey(const Key('detail.export')));
    await settle(tester);
    expect(find.text('Export file created'), findsOneWidget); // S9.8
    final shared = exporter.shared.single.single;
    expect(shared.session.id, completedId);
    expect(shared.events.first.kind, ExecutionEventKind.started);
    expect(shared.events.last.kind, ExecutionEventKind.finished);
  });

  testWidgets('TASK 14.3: Export all shares every saved session', (
    tester,
  ) async {
    await seed(tester);
    await pumpAt(tester, AppRouter.sessions);
    // S9.8: a labelled item in the Logbook's menu; it says it is done.
    await tester.tap(find.byKey(const Key('logbook.menu')));
    await settle(tester);
    expect(find.text('Export all as file'), findsOneWidget);
    await tester.tap(find.byKey(const Key('logbook.exportAll')));
    await settle(tester);
    final ids = {for (final e in exporter.shared.single) e.session.id};
    expect(ids, {completedId, plannedId, legacyId, noSnapshotId});
    expect(find.text('Export file created'), findsOneWidget);
  });

  testWidgets('no overflow at 200 % text on a 360 × 640 dp phone', (
    tester,
  ) async {
    await seed(tester);
    tester.view.physicalSize = const Size(360, 640);
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpAt(tester, AppRouter.sessionDetail(completedId));
    await tester.drag(find.byType(ListView).first, const Offset(0, -4000));
    await settle(tester);
    expect(tester.takeException(), isNull);
    AppRouter.router.go(AppRouter.sessions);
    await settle(tester);
    expect(tester.takeException(), isNull);
  });
}

/// Pumps fixed frames with real-time gaps (database reads; TASK 12.2).
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump(const Duration(milliseconds: 200));
  }
}
