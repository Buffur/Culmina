// TASK 15.3: accessibility guideline tests. Every main screen, scrolled top
// to bottom, in the light, dark and field (red) themes at 100 % and 200 %
// text: no layout exception (overflow), Android's 48 px tap targets, a label
// on every tappable element, and WCAG AA text contrast in the light and dark
// themes (S1.10: with a full forecast on screen, UX-32). Field mode's secondary red is below AA by design (dark
// adaptation; documented in ARCHITECTURE.md B16), so contrast is not
// asserted there. Plus the altitude chart's text alternative.

import 'dart:async';
import 'dart:io';

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/core/theme/hybrid_tokens.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/services/catalog_seeder.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/models/planning_preferences.dart';
import 'package:astroplan/domain/models/session.dart';
import 'package:astroplan/domain/models/session_night.dart';
import 'package:astroplan/domain/services/astrobin_acquisitions.dart';
import 'package:astroplan/domain/services/capture_budget_calculator.dart';
import 'package:astroplan/domain/services/session_exporter.dart';
import 'package:astroplan/domain/services/session_snapshot_builder.dart';
import 'package:astroplan/domain/models/weather_snapshot.dart';
import 'package:astroplan/presentation/widgets/planner_sections.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:astroplan/presentation/viewmodels/night_browser_viewmodel.dart';
import 'package:astroplan/presentation/viewmodels/night_conditions_viewmodel.dart';
import 'package:astroplan/presentation/viewmodels/session_plan_viewmodel.dart';
import 'package:astroplan/presentation/screens/library/library_parts.dart';
import 'package:drift/native.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fake_capture_file_access.dart';
import '../support/fake_device_time_zone.dart';
import '../support/jpeg_fixture.dart';
import '../support/fake_location_service.dart';
import '../support/fake_reverse_geocoder.dart';
import '../support/planner_harness.dart';
import '../support/tiff_fixture.dart';
import '../support/legacy_run.dart';

/// Every hour of the night with every variable filled, on whole UTC hours
/// as the provider serves them, so the sweep renders the weather card, its
/// ranges and the hour strip (S1.10; the blind spot UX-32).
class _FullForecast implements WeatherRepository {
  _FullForecast(this.clock);

  final Clock clock;

  @override
  Future<WeatherFetch> fetchSnapshot({
    required double latitude,
    required double longitude,
    required DateTime startUtc,
    required DateTime endUtc,
  }) async {
    final first = DateTime.utc(
      startUtc.year,
      startUtc.month,
      startUtc.day,
      startUtc.hour,
    );
    return WeatherFetched(
      WeatherSnapshot(
        provider: 'open-meteo',
        model: 'best_match',
        fetchedAtUtc: clock.nowUtc(),
        latitude: latitude,
        longitude: longitude,
        hours: [
          for (
            var t = first;
            t.isBefore(endUtc);
            t = t.add(const Duration(hours: 1))
          )
            WeatherHour(
              timeUtc: t,
              cloudCoverPct: 100,
              cloudCoverLowPct: 18,
              cloudCoverMidPct: 45,
              cloudCoverHighPct: 100,
              precipitationProbabilityPct: 35,
              windSpeedKmh: 12.5,
              windGustsKmh: 28.4,
              temperatureC: -12.5,
              dewPointC: -14.2,
              relativeHumidityPct: 88,
              visibilityM: 24140,
            ),
        ],
      ),
    );
  }
}

enum _Theme { light, dark, field }

class _NoShare implements AstroBinCsvExporter {
  @override
  Future<void> share(AstroBinExport export) async {}
}

Future<void> _settle(WidgetTester tester) async {
  // Keep the original twelve frames/600 ms of animation time, but await the
  // actual IO instead of sleeping 240 ms at every route/dialog transition.
  // Snapshot futures before runAsync: awaiting them neither repeats queries
  // nor changes the FutureBuilder's own error presentation.
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 50));
    final futures = tester.allWidgets
        .whereType<FutureBuilder<dynamic>>()
        .map((widget) => widget.future)
        .whereType<Future<dynamic>>()
        .toSet();
    final builderFutures = {...futures};
    final context = tester.element(find.byType(AstroPlanApp));
    final plan = context.read<SessionPlanViewModel>();
    final conditions = context.read<NightConditionsViewModel>();
    final calendar = find.byKey(const Key('nightMoon.calendarLoading'));
    final browser = calendar.evaluate().isEmpty
        ? null
        : tester.element(calendar).read<NightBrowserViewModel>();
    futures.addAll([
      plan.idle,
      conditions.idle,
      if (browser != null) browser.idle,
    ]);
    var pending = futures.length;
    Object? pendingError;
    StackTrace? pendingStack;
    for (final future in futures) {
      // Register in the test zone, then pump it while IO progresses in the
      // real zone. Awaiting the chain inside runAsync can deadlock a future
      // whose intermediate continuations belong to FakeAsync.
      unawaited(
        future.then<void>(
          (_) {
            pending--;
          },
          onError: (Object error, StackTrace stack) {
            // FutureBuilder owns its own error UI; VM failures must still fail
            // this fixture rather than becoming successful synchronization.
            if (!builderFutures.contains(future)) {
              pendingError = error;
              pendingStack = stack;
            }
            pending--;
          },
        ),
      );
    }
    final deadline = Stopwatch()..start();
    await tester.pump();
    while (pending > 0) {
      if (deadline.elapsed > const Duration(seconds: 30)) {
        fail('Accessibility fixture still has $pending pending IO operations.');
      }
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 5)),
      );
      await tester.pump(const Duration(milliseconds: 5));
    }
    if (pendingError != null) {
      Error.throwWithStackTrace(pendingError!, pendingStack!);
    }
  }
}

/// A phone-width view with the app on a site, the catalog, the seeded rig,
/// a planned session and a run in progress. The view is 412 logical px wide
/// (a phone) and tall enough for a whole page: a node half scrolled under an
/// app bar reports a clipped size to the tap-target guideline, which would
/// be a false failure.
Future<({PlannerHarness vm, int running, int planned, int ended})> _pumpApp(
  WidgetTester tester, {
  required _Theme theme,
  required double textScale,
}) async {
  tester.view.physicalSize = const Size(412, 10000);
  tester.view.devicePixelRatio = 1.0;
  tester.platformDispatcher.platformBrightnessTestValue = theme == _Theme.light
      ? Brightness.light
      : Brightness.dark;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);
  AppRouter.router.go(AppRouter.tonight);
  late AppDatabase db;
  late PlannerHarness vm;
  late int running, planned, ended;
  await tester.runAsync(() async {
    db = AppDatabase(NativeDatabase.memory());
    await CatalogSeeder(DriftTargetRepository(db)).seedIfNeeded();
    await EquipmentSeeder(DriftEquipmentRepository(db)).seedIfNeeded();
    final siteId = await DriftLocationRepository(db).insertLocation(
      domain.LocationProfile(
        id: 0,
        name: 'Ljubljana',
        latitude: 46.05,
        longitude: 14.51,
        elevation: 300,
        timeZoneId: 'Europe/Ljubljana',
      ),
    );
    SharedPreferences.setMockInitialValues({'activeLocationId': siteId});
    final clock = FixedClock(DateTime.utc(2026, 11, 10, 18));
    vm = PlannerHarness(
      DriftTargetRepository(db),
      DriftEquipmentRepository(db),
      _FullForecast(clock),
      DriftLocationRepository(db),
      locationService: FakeLocationService(),
      reverseGeocoder: FakeReverseGeocoder(),
      deviceTimeZone: FakeDeviceTimeZone(),
      clock: clock,
      sessionRepository: DriftSessionRepository(db, clock: clock),
      // S3.6: a file matching the seeded rig, so the import review shows a
      // match, its reasons, a conflict switch and every action.
      captureFiles: FakeCaptureFileAccess()..file('light.jpg', _seedJpeg()),
      // F25: the AstroBin export, so the sweep sees its preview.
      csvExporter: _NoShare(),
    );
    await vm.ready;
    await vm.choosePlan(); // S6.8: nothing is preselected
    planned = (await vm.analysis.saveSession()).id;
    // S8.4: an old run in progress (the tracker left); its result form.
    running = (await startLegacyRun(
      DriftSessionRepository(db, clock: clock),
      (await DriftSessionRepository(db, clock: clock).get(planned))!,
    )).id;
    // TD-087: a Saved plan whose night (9 Nov) has ended, awaiting its
    // result, so the sweep sees the Saved-plan result form too.
    ended = (await _savedEndedPlan(
      DriftSessionRepository(db, clock: clock),
      (await DriftSessionRepository(db, clock: clock).get(planned))!,
    )).id;
    if (theme == _Theme.field) await vm.theme.toggleFieldMode();
  });
  addTearDown(() => tester.runAsync(db.close));
  await tester.pumpWidget(
    MultiProvider(providers: vm.providers, child: const AstroPlanApp()),
  );
  await _settle(tester);
  return (vm: vm, running: running, planned: planned, ended: ended);
}

/// A copy of [saved]'s plan saved for 9 Nov, whose night has ended by the
/// sweep's clock (10 Nov, 18:00 UTC).
Future<Session> _savedEndedPlan(
  DriftSessionRepository repo,
  Session saved,
) async {
  final night = CalendarDate(2026, 11, 9);
  final plan = SessionPlan(
    eveningDate: night,
    timeZoneId: 'Europe/Ljubljana',
    siteId: saved.siteId,
    targetId: saved.targetId,
    rigId: saved.rigId,
    blocks: saved.blocks,
    targetLabel: saved.record.targetName,
    rigLabel: saved.record.equipmentName,
    siteLabel: saved.record.locationName,
  );
  final prefs = PlanningPreferences();
  final row = await repo.create(plan);
  return repo.savePlan(
    row.id,
    plan,
    SessionSnapshotBuilder.build(
      takenAtUtc: DateTime.utc(2026, 11, 9, 18),
      night: SessionNight(
        eveningDate: night,
        startUtc: DateTime.utc(2026, 11, 9, 11),
        endUtc: DateTime.utc(2026, 11, 10, 11),
        latitude: 46.05,
        longitude: 14.51,
        timeContextId: 'Europe/Ljubljana',
      ),
      timeZoneId: 'Europe/Ljubljana',
      preferences: prefs,
      budget: CaptureBudgetCalculator.calculate(
        blocks: saved.blocks,
        overheads: CaptureOverheads.fromPreferences(prefs),
        targetTransitsInWindow: false,
      ),
      blocks: saved.blocks,
    ),
  );
}

/// Checks the page; one taller than the view is scrolled a screen at a time
/// and checked again. Returns every problem found.
Future<List<String>> _audit(
  WidgetTester tester, {
  required bool contrast,
}) async {
  final problems = <String>[];
  for (var page = 0; page < 60; page++) {
    Object? error;
    while ((error = tester.takeException()) != null) {
      // The message and, for a layout error, the widget that caused it.
      final lines = error.toString().split('\n');
      final where = lines.where((l) => l.contains('.dart:')).take(1);
      problems.add('exception: ${[lines.first, ...where].join(' at ')}');
    }
    for (final g in [
      androidTapTargetGuideline,
      labeledTapTargetGuideline,
      if (contrast) textContrastGuideline,
    ]) {
      final result = await g.evaluate(tester);
      if (!result.passed) problems.add('${g.description}: ${result.reason}');
    }
    final lists = find.byWidgetPredicate(
      (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
    );
    if (lists.evaluate().isEmpty) break;
    final position = tester.state<ScrollableState>(lists.first).position;
    if (position.pixels >= position.maxScrollExtent) break;
    position.jumpTo(
      (position.pixels + 9000).clamp(0.0, position.maxScrollExtent),
    );
    await tester.pump();
  }
  return problems;
}

/// A camera JPEG naming the seeded rig's camera and optics, with a rounded
/// f/5.6 (a listed difference from the seed's f/5.56).
Uint8List _seedJpeg() {
  final exif = TiffFixture()
    ..ifd0.addAll([
      FixtureEntry.ascii(271, 'ZWO'),
      FixtureEntry.ascii(272, 'ASI2600MC'),
    ])
    ..exif = [
      FixtureEntry.rational(37386, 400, 1),
      FixtureEntry.rational(33437, 56, 10),
      FixtureEntry.long(40962, 6248),
      FixtureEntry.long(40963, 4176),
    ];
  return jpegFile([exifApp1(exif.build().bytes)]);
}

void main() {
  for (final entry in [
    ('light', HybridTokens.light),
    ('dark', HybridTokens.dark),
  ]) {
    test('P-6: selected hour has AA text contrast in ${entry.$1}', () {
      final background = entry.$2.selectedHourFill.computeLuminance();
      final text = entry.$2.selectedHourText.computeLuminance();
      final ratio =
          (text > background ? text + 0.05 : background + 0.05) /
          (text > background ? background + 0.05 : text + 0.05);
      expect(ratio, greaterThanOrEqualTo(4.5));
    });
  }

  for (final theme in _Theme.values) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('every screen meets the guidelines: ${theme.name}, '
          '${(scale * 100).round()} % text', (tester) async {
        final app = await _pumpApp(tester, theme: theme, textScale: scale);
        final handle = tester.ensureSemantics();
        final routes = [
          AppRouter.tonight,
          AppRouter.candidates,
          AppRouter.sessions,
          AppRouter.sessionDetail(app.planned),
          AppRouter.library,
          AppRouter.libraryRigs,
          AppRouter.libraryTargets,
          AppRouter.librarySites,
          AppRouter.selectRig, // S9.1: the same lists, choosing
          AppRouter.selectTarget,
          AppRouter.selectSite,
          AppRouter.logbookProgress,
          AppRouter.settings,
          AppRouter.about,
          AppRouter.session(),
          AppRouter.siteEdit,
          AppRouter.results(app.running),
          AppRouter.results(app.planned), // TD-087: its night not ended yet
          AppRouter.results(app.ended), // TD-087: no outcome chosen yet
          AppRouter.welcome,
          AppRouter.metadata,
          AppRouter.nightMoon, // S6.5
          AppRouter.weather, // S6.5
        ];
        final report = <String>[];
        for (final route in routes) {
          AppRouter.router.go(route);
          await _settle(tester);
          if (route == AppRouter.metadata) {
            await tester.runAsync(app.vm.vms.metadataImport!.pickAndRead);
            await _settle(tester);
            expect(find.byKey(const Key('import.open.1')), findsOneWidget);
          }
          final problems = await _audit(
            tester,
            contrast: theme != _Theme.field,
          );
          if (problems.isNotEmpty) {
            report.add('$route:\n${problems.join('\n')}');
          }
        }
        // S9.4: Settings with every gate and overhead on, so the sweep sees
        // their thresholds and steppers.
        await tester.runAsync(
          () => app.vm.settings.setPlanningPreferences(
            app.vm.planningPreferences
                .copyWith(moonGateEnabled: true, cloudGateEnabled: true)
                .withOptionalOverheads(
                  ditherEveryNFrames: (3,),
                  refocusEveryMinutes: (60.0,),
                  filterChangeSeconds: (30.0,),
                  meridianFlipSeconds: (300.0,),
                  setupMinutes: (30.0,),
                ),
          ),
        );
        AppRouter.router.go(AppRouter.settings);
        await _settle(tester);
        await tester.tap(find.byKey(const Key('settings.open.planning')));
        await _settle(tester);
        // F12: optional gates remain reachable in Planning settings.
        await tester.tap(find.byKey(const Key('settings.advanced')));
        await _settle(tester);
        expect(find.byTooltip('Settle: more'), findsOneWidget);
        final settingsOn = await _audit(
          tester,
          contrast: theme != _Theme.field,
        );
        if (settingsOn.isNotEmpty) {
          report.add('settings, all on:\n${settingsOn.join('\n')}');
        }
        // F12 (UX-S R3): the planning settings over the plan.
        unawaited(AppRouter.router.push(AppRouter.planSettings));
        await _settle(tester);
        expect(find.byKey(const Key('settings.scope')), findsOneWidget);
        final overPlan = await _audit(tester, contrast: theme != _Theme.field);
        if (overPlan.isNotEmpty) {
          report.add('planning settings:\n${overPlan.join('\n')}');
        }
        AppRouter.router.pop();
        await _settle(tester);
        // TD-087: the Saved plan's form with Not done chosen, so the sweep
        // sees the reason chips.
        AppRouter.router.go(AppRouter.results(app.ended));
        await _settle(tester);
        final notDone = find.byKey(const Key('results.outcome.notDone'));
        await tester.ensureVisible(notDone);
        await tester.tap(notDone);
        await _settle(tester);
        expect(find.byKey(const Key('results.reason.clouds')), findsOneWidget);
        final reasons = await _audit(tester, contrast: theme != _Theme.field);
        if (reasons.isNotEmpty) {
          report.add('result form, Not done:\n${reasons.join('\n')}');
        }
        // S6.7: the planner again with every section open, so the sweep
        // sees the detail that is one tap away too.
        for (final key in PlannerSections.all) {
          await app.vm.disclosure.setOpen(key, true);
        }
        AppRouter.router.go(AppRouter.session());
        await _settle(tester);
        final open = await _audit(tester, contrast: theme != _Theme.field);
        if (open.isNotEmpty) {
          report.add('planner, sections open:\n${open.join('\n')}');
        }
        // S6.8: a new plan: no target, and an empty capture plan with its
        // next step (F09 A6, UXA-C5).
        await tester.runAsync(app.vm.newSession);
        AppRouter.router.go(AppRouter.session());
        await _settle(tester);
        expect(find.byKey(const Key('capturePlan.addLights')), findsOneWidget);
        final fresh = await _audit(tester, contrast: theme != _Theme.field);
        if (fresh.isNotEmpty) {
          report.add('planner, new plan:\n${fresh.join('\n')}');
        }
        handle.dispose();
        expect(report, isEmpty, reason: report.join('\n\n'));
      });
    }
  }

  // F25 A1 (U): the changed editors, dialogs and sheets, the filter panel,
  // the AstroBin preview and the map picker, in every theme at 100 % and
  // 200 % text.
  for (final theme in _Theme.values) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('editors, dialogs, the filter panel and the map picker meet '
          'the guidelines: ${theme.name}, ${(scale * 100).round()} % text', (
        tester,
      ) async {
        await _pumpApp(tester, theme: theme, textScale: scale);
        final handle = tester.ensureSemantics();
        final report = <String>[];
        Future<void> check(String name) async {
          final p = await _audit(tester, contrast: theme != _Theme.field);
          if (p.isNotEmpty) report.add('$name:\n${p.join('\n')}');
        }

        Future<void> tap(Finder f) async {
          await tester.ensureVisible(f.first);
          await tester.tap(f.first);
          await _settle(tester);
        }

        // The Logbook's filter panel.
        AppRouter.router.go(AppRouter.sessions);
        await _settle(tester);
        await tap(find.byKey(const Key('logbook.filterToggle')));
        expect(find.byKey(const Key('logbook.filters')), findsOneWidget);
        await check('logbook filter panel');
        await tap(find.byKey(const Key('logbook.filterToggle')));

        // The AstroBin preview.
        await tap(find.byKey(const Key('logbook.menu')));
        await tap(find.byKey(const Key('logbook.astrobin')));
        expect(find.byKey(const Key('astrobin.preview')), findsOneWidget);
        await check('AstroBin preview');
        await tap(find.byKey(const Key('astrobin.cancel')));

        // A rig's record and its editor; a catalogue target's record and
        // the target editor (library.js: records open first).
        AppRouter.router.go(AppRouter.libraryRigs);
        await _settle(tester);
        await tap(find.byType(LibraryRow));
        expect(find.byKey(const Key('rigDetail.edit')), findsOneWidget);
        await check('rig record');
        await tap(find.byKey(const Key('rigDetail.edit')));
        expect(find.byKey(const Key('rigEditor.save')), findsOneWidget);
        await check('rig editor');
        await tap(find.byKey(const Key('rigEditor.cancel'))); // unchanged
        AppRouter.router.go(AppRouter.libraryTargets);
        await _settle(tester);
        await tester.enterText(find.byType(TextField).first, 'M42');
        await _settle(tester);
        await tap(find.byType(LibraryRow));
        expect(find.byKey(const Key('targetDetail.facts')), findsOneWidget);
        await check('target record');
        await tester.binding.handlePopRoute();
        await _settle(tester);
        await tap(find.byKey(const Key('targets.add')));
        expect(find.byKey(const Key('targetEditor.save')), findsOneWidget);
        await check('target editor');
        await tap(find.byKey(const Key('targetEditor.cancel'))); // unchanged

        // The block editor.
        AppRouter.router.go(AppRouter.session());
        await _settle(tester);
        await tap(find.byKey(const Key('capture.edit.0')));
        expect(find.byKey(const Key('blockDialog.cancel')), findsOneWidget);
        await check('block editor');
        await tap(find.byKey(const Key('blockDialog.cancel')));

        // The map picker; the host has no path_provider plugin (flutter_map's
        // tile cache asks it for a folder).
        const pathProvider = MethodChannel('plugins.flutter.io/path_provider');
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          pathProvider,
          (call) async => Directory.systemTemp.path,
        );
        addTearDown(
          () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            pathProvider,
            null,
          ),
        );
        unawaited(
          AppRouter.router.push(
            AppRouter.sitePick,
            extra: const LatLng(46.05, 14.51),
          ),
        );
        await _settle(tester);
        await check('map picker');
        AppRouter.router.pop();
        await _settle(tester);

        handle.dispose();
        expect(report, isEmpty, reason: report.join('\n\n'));
      });
    }
  }

  // S1.10 (UX-32): the sweep would miss a weather-card overflow again if the
  // forecast stopped rendering.
  testWidgets('the sweep renders a forecast', (tester) async {
    await _pumpApp(tester, theme: _Theme.light, textScale: 2.0);
    // S6.5: the full forecast is on the Weather detail.
    AppRouter.router.go(AppRouter.weather);
    await _settle(tester);
    // Hybrid A · Compact rows: each variable's range over the dark hours.
    final rows = find.byKey(const Key('weather.rows'));
    expect(rows, findsOneWidget);
    // UX-31: a range label never runs into its value; at 200 % the value
    // goes under its name.
    final label = tester.getRect(
      find.descendant(of: rows, matching: find.text('Cloud cover')),
    );
    // The cloud row's value: the first percentage at or below its name.
    final value =
        [
              for (final e
                  in find
                      .descendant(
                        of: rows,
                        matching: find.byWidgetPredicate(
                          (w) =>
                              w is Text &&
                              (w.data?.endsWith('%') ?? false) &&
                              !(w.data?.contains('known') ?? true),
                        ),
                      )
                      .evaluate())
                tester.getRect(find.byWidget(e.widget)),
            ]
            .where((r) => r.top >= label.top - 4)
            .reduce((a, b) => a.top <= b.top ? a : b);
    expect(
      value.top >= label.bottom || value.left - label.right >= 8,
      isTrue,
      reason: '$label / $value',
    );
    // S1.13 (SCI-02): precipitation covers the preceding hour.
    expect(find.text('Precipitation probability'), findsOneWidget);
    expect(find.textContaining('preceding hour'), findsWidgets);
    expect(find.byKey(const Key('weather.precipNote')), findsOneWidget);
    // F14 A3: the full table is in Forecast details.
    await tester.ensureVisible(find.byKey(const Key('weather.details')));
    await tester.tap(find.text('Forecast details'));
    await _settle(tester);
    expect(find.byKey(const Key('weather.table')), findsOneWidget);
  });

  // F18 A1 (AM-01): the altitude chart is out of the plan for this
  // release; its text alternative is tested on the widget
  // (`tonight_opportunity_widget_test.dart`).
  testWidgets('the plan has no altitude chart', (tester) async {
    await _pumpApp(tester, theme: _Theme.light, textScale: 1.0);
    AppRouter.router.go(AppRouter.session());
    await _settle(tester);
    expect(find.byKey(const Key('chart.altitude')), findsNothing);
  });
}
