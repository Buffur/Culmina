// Android emulator evidence for the Hybrid migration. Real Flutter widgets,
// router, ViewModels, astronomy and SQLite; explicit isolated test data.
// Network, GPS, preferences and first-run state are controlled fixtures.
// This does not exercise native file providers, share sheets or permissions.
import 'dart:async';
import 'dart:io';

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/core/units/display_units.dart';
import 'package:astroplan/data/backup/backup_staging.dart';
import 'package:astroplan/data/backup/file_backup_service.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/export/session_manifest_codec.dart';
import 'package:astroplan/data/metadata/file_metadata_source.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/services/catalog_seeder.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/domain/metadata/capture_metadata.dart';
import 'package:astroplan/domain/metadata/capture_metadata_reader.dart';
import 'package:astroplan/domain/metadata/metadata_format.dart';
import 'package:astroplan/domain/metadata/metadata_value.dart';
import 'package:astroplan/domain/models/location_profile.dart';
import 'package:astroplan/domain/models/night_weather.dart';
import 'package:astroplan/domain/models/session.dart';
import 'package:astroplan/domain/models/session_result.dart';
import 'package:astroplan/domain/models/weather_snapshot.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/domain/services/backup_service.dart';
import 'package:astroplan/domain/services/session_exporter.dart';
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:astroplan/presentation/viewmodels/night_conditions_viewmodel.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test/support/fake_device_time_zone.dart';
import '../test/support/fake_location_service.dart';
import '../test/support/fake_reverse_geocoder.dart';
import '../test/support/fits_fixture.dart';
import '../test/support/in_memory_first_run.dart';
import '../test/support/in_memory_privacy_preferences.dart';
import '../test/support/planner_harness.dart';

class _Forecast implements WeatherRepository {
  _Forecast(this.clock);
  final Clock clock;
  WeatherFailure? failure;

  @override
  Future<WeatherFetch> fetchSnapshot({
    required double latitude,
    required double longitude,
    required DateTime startUtc,
    required DateTime endUtc,
  }) async {
    if (failure case final value?) return WeatherFetchFailed(value);
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
              cloudCoverPct: (t.hour * 7 % 100).toDouble(),
              cloudCoverLowPct: 10,
              cloudCoverMidPct: 20,
              cloudCoverHighPct: 30,
              precipitationProbabilityPct: 5,
              windSpeedKmh: 9,
              windGustsKmh: 18,
              temperatureC: -2.5,
              dewPointC: -4,
              relativeHumidityPct: 82,
              visibilityM: 24000,
            ),
        ],
      ),
    );
  }
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 40)),
    );
    await tester.pump(const Duration(milliseconds: 80));
  }
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Hybrid native roots, save/reopen, settings and night browsing',
    (tester) async {
      final clock = FixedClock(DateTime.utc(2026, 11, 10, 18));
      final forecast = _Forecast(clock);
      late AppDatabase db;
      late DriftSessionRepository sessions;
      late PlannerHarness vm;
      await tester.runAsync(() async {
        // Hermetic preferences before seeding: the seeder skips a catalog
        // version it finds stored, and a previous run's real preferences
        // would leave this in-memory database without its catalogue.
        SharedPreferences.setMockInitialValues({'firstRunDone': true});
        db = AppDatabase(NativeDatabase.memory());
        final targets = DriftTargetRepository(db);
        final rigs = DriftEquipmentRepository(db);
        final sites = DriftLocationRepository(db);
        await CatalogSeeder(targets).seedIfNeeded();
        await EquipmentSeeder(rigs).seedIfNeeded();
        final siteId = await sites.insertLocation(
          LocationProfile(
            id: 0,
            name: 'Ljubljana',
            latitude: 46.05,
            longitude: 14.51,
            elevation: 300,
            timeZoneId: 'Europe/Ljubljana',
          ),
        );
        SharedPreferences.setMockInitialValues({
          'activeLocationId': siteId,
          'firstRunDone': true,
        });
        sessions = DriftSessionRepository(db, clock: clock);
        vm = PlannerHarness(
          targets,
          rigs,
          forecast,
          sites,
          clock: clock,
          sessionRepository: sessions,
          locationService: FakeLocationService(),
          reverseGeocoder: FakeReverseGeocoder(),
          deviceTimeZone: FakeDeviceTimeZone(),
          firstRun: InMemoryFirstRun(done: true),
          privacyPreferences: InMemoryPrivacyPreferences(),
        );
        await vm.ready;
        await vm.choosePlan();
        await vm.plan.idle;
        // Match the host canonical fixture's first saved entry, then leave
        // the second plan draft for the visible Save interaction below.
        await vm.analysis.saveSession();
        await vm.lifecycle.newSession();
        await vm.plan.idle;
        await vm.choosePlan();
        await vm.plan.idle;
        await vm.vms.displaySettings.load();
        await vm.tonight.load(hasStoredSite: true);
      });
      addTearDown(() => tester.runAsync(db.close));
      addTearDown(tester.platformDispatcher.clearAllTestValues);
      tester.platformDispatcher.alwaysUse24HourFormatTestValue = true;
      AppRouter.router.go(AppRouter.tonight);
      await tester.pumpWidget(
        MultiProvider(
          providers: vm.providers,
          child: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(alwaysUse24HourFormat: true),
              child: const AstroPlanApp(),
            ),
          ),
        ),
      );
      await _settle(tester);
      await binding.convertFlutterSurfaceToImage();
      await tester.pump();

      Future<void> at(String route) async {
        if ([
          AppRouter.session(),
          AppRouter.nightMoon,
          AppRouter.moon,
          AppRouter.weather,
        ].contains(route)) {
          AppRouter.router.go(AppRouter.tonight);
          await _settle(tester);
          unawaited(AppRouter.router.push(route));
        } else {
          AppRouter.router.go(route);
        }
        await _settle(tester);
        final scrolls = find.byType(Scrollable);
        if (scrolls.evaluate().isNotEmpty) {
          tester.state<ScrollableState>(scrolls.first).position.jumpTo(0);
          await _settle(tester);
        }
        expect(tester.takeException(), isNull, reason: route);
        expect(
          MediaQuery.of(tester.element(find.byType(Scaffold).first))
              .alwaysUse24HourFormat,
          isTrue,
          reason: 'Native fixture uses the canonical 24-hour display.',
        );
      }

      Future<void> shot(String name) async {
        await _settle(tester);
        expect(tester.takeException(), isNull, reason: name);
        await binding.takeScreenshot(name);
      }

      Future<void> reveal(Finder finder) async {
        if (finder.evaluate().isEmpty) {
          await tester.scrollUntilVisible(
            finder,
            350,
            scrollable: find.byType(Scrollable).first,
            maxScrolls: 30,
          );
        }
        await tester.ensureVisible(finder.first);
        // Lay the scrolled list out before a tap or capture uses its position.
        await tester.pump();
      }

      Future<void> tap(Finder finder) async {
        await reveal(finder);
        await tester.tap(finder.first);
        await _settle(tester);
      }

      Future<void> captureAppearance(String suffix) async {
        await at(AppRouter.settings);
        await tap(find.byKey(const Key('settings.open.appearance')));
        await shot('settings-appearance-$suffix');
        final choice = find.byKey(const Key('settings.appearance'));
        expect(
          tester.getSize(choice).width,
          closeTo(MediaQuery.sizeOf(tester.element(choice)).width - 32, 1),
        );
        await tester.pageBack();
        await _settle(tester);
      }

      // Bounded re-verification after a Settings-only control correction.
      // The full flow below remains the default native acceptance run.
      if (const bool.fromEnvironment('CULMINA_SETTINGS_ONLY')) {
        for (final (appearance, field) in [
          (Appearance.light, false),
          (Appearance.dark, false),
          (Appearance.dark, true),
        ]) {
          await tester.runAsync(() async {
            if (vm.theme.isFieldMode != field) await vm.theme.toggleFieldMode();
            await vm.vms.displaySettings.setAppearance(appearance);
          });
          for (final scale in [1.0, 2.0]) {
            tester.platformDispatcher.textScaleFactorTestValue = scale;
            await captureAppearance(
              '${field ? 'field' : appearance.name}_${(scale * 100).round()}',
            );
          }
        }
        binding.reportData ??= <String, dynamic>{};
        binding.reportData!['evidence'] = {
          'type': 'Scoped Android emulator Settings control verification',
          'checks': [
            'Appearance uses full column width in all three themes at '
                '100 and 200 percent text',
            'No widget exceptions during navigation',
          ],
          'limits':
              'Controlled theme/text values and fixtures; no real IME or '
              'physical-device claim',
        };
        return;
      }

      // Exercise the visible Save action, then read the actual repository.
      await at(AppRouter.session());
      final originalCount = vm.plan.captureBlocks.first.frameCount;
      await tap(find.byKey(const Key('capture.edit.0')));
      expect(find.byKey(const Key('blockEditor.screen')), findsOneWidget);
      final countField = find.byKey(const Key('blockDialog.count'));
      await reveal(countField);
      await tester.enterText(countField, '${originalCount + 1}');
      await _settle(tester);
      await tap(find.byKey(const Key('fieldMode.toggle')));
      expect(vm.theme.isFieldMode, isTrue);
      expect(
        tester.widget<TextFormField>(countField).controller!.text,
        '${originalCount + 1}',
      );
      await shot('block-editor-field-draft');
      await tap(find.byKey(const Key('fieldMode.toggle')));
      expect(vm.theme.isFieldMode, isFalse);
      await shot('block-editor-keyboard-light_100');
      // The platform's Back (the route-pop message Android sends) on the
      // dirty editor asks first; Cancel keeps the editor and its edit.
      await tester.binding.handlePopRoute();
      await _settle(tester);
      expect(find.byKey(const Key('unsaved.discard')), findsOneWidget);
      await shot('block-editor-system-back-guard-light_100');
      await tap(find.byKey(const Key('unsaved.cancel')));
      expect(find.byKey(const Key('blockEditor.screen')), findsOneWidget);
      // Back again and Discard: the editor closes and the plan is unchanged.
      await tester.binding.handlePopRoute();
      await _settle(tester);
      await tap(find.byKey(const Key('unsaved.discard')));
      expect(vm.plan.captureBlocks.first.frameCount, originalCount);
      expect(find.byKey(const Key('blockEditor.screen')), findsNothing);
      // The explicit Cancel on a dirty edit leaves the plan unchanged too.
      await tap(find.byKey(const Key('capture.edit.0')));
      await reveal(countField);
      await tester.enterText(countField, '${originalCount + 2}');
      await _settle(tester);
      await tap(find.byKey(const Key('blockDialog.cancel')));
      if (find.byKey(const Key('unsaved.discard')).evaluate().isNotEmpty) {
        await tap(find.byKey(const Key('unsaved.discard')));
      }
      expect(vm.plan.captureBlocks.first.frameCount, originalCount);
      expect(find.byKey(const Key('blockEditor.screen')), findsNothing);
      await tap(find.byKey(const Key('planner.save')));
      final saved = await tester.runAsync(() => sessions.mostRecentOpen());
      expect(saved, isNotNull);
      expect(saved!.status, SessionStatus.planned);
      expect(saved.blocks, isNotEmpty);
      final savedId = saved.id;
      final savedDate = saved.eveningDate;
      final savedCounts = saved.blocks.map((b) => b.frameCount).toList();
      await at(AppRouter.sessions);
      await tap(find.byKey(Key('logbook.title.$savedId')));
      expect(find.byKey(const Key('detail.result')), findsOneWidget);
      await tap(find.text('Open in planner'));
      expect(vm.plan.activeSession?.id, savedId);
      expect(vm.plan.captureBlocks.map((b) => b.frameCount), savedCounts);
      await shot('save-reopen-light_100');

      // Browsing a different night must not mutate the saved plan.
      await at(AppRouter.nightMoon);
      await tap(find.byTooltip('Next night'));
      expect(find.byKey(const Key('nightMoon.viewing')), findsOneWidget);
      expect(vm.plan.eveningDate, savedDate);
      expect(
        (await tester.runAsync(() => sessions.get(savedId)))!.eveningDate,
        savedDate,
      );
      await shot('night-browse-light_100');
      await tap(find.byKey(const Key('nightMoon.backToPlan')));

      // Navigate the real Settings index and apply a display-only change.
      await at(AppRouter.settings);
      await tap(find.byKey(const Key('settings.open.appearance')));
      await tap(
        find.descendant(
          of: find.byKey(const Key('settings.units.temperature')),
          matching: find.text('°F'),
        ),
      );
      expect(
        vm.vms.displaySettings.units.temperature,
        TemperatureUnit.fahrenheit,
      );
      await tester.pageBack();
      await _settle(tester);
      await tap(find.byKey(const Key('settings.open.planning')));
      expect(find.byKey(const Key('settings.perFrame')), findsOneWidget);
      final previousPreferences = vm.settings.planningPreferences;
      final previousAcquisition = vm.captureBudget.acquisitionMs;
      final overhead = find.descendant(
        of: find.byKey(const Key('settings.perFrame')),
        matching: find.byType(Slider),
      );
      await reveal(overhead);
      await tester.drag(overhead, const Offset(80, 0));
      await _settle(tester);
      expect(vm.settings.planningPreferences, previousPreferences);
      expect(vm.captureBudget.acquisitionMs, previousAcquisition);
      await shot('settings-planning-draft-light_100');
      await tap(find.byKey(const Key('settings.cancelPlanning')));
      await tap(find.byKey(const Key('confirm.action')));
      expect(vm.settings.planningPreferences, previousPreferences);
      expect(vm.captureBudget.acquisitionMs, previousAcquisition);
      await tap(find.byKey(const Key('settings.open.planning')));
      await reveal(overhead);
      await tester.drag(overhead, const Offset(80, 0));
      await _settle(tester);
      await tap(find.byKey(const Key('settings.savePlanning')));
      expect(
        vm.settings.planningPreferences.perFrameOverheadSeconds,
        isNot(previousPreferences.perFrameOverheadSeconds),
      );
      expect(vm.captureBudget.acquisitionMs, isNot(previousAcquisition));
      expect(
        (await tester.runAsync(() => sessions.get(savedId)))!
            .planSnapshot!
            .json,
        saved.planSnapshot!.json,
        reason: 'A global preference edit must not rewrite a saved snapshot.',
      );
      await tap(find.byKey(const Key('settings.open.planning')));
      await shot('settings-planning-fahrenheit-light_100');
      await tap(find.byKey(const Key('settings.cancelPlanning')));
      await tester.runAsync(
        () => vm.vms.displaySettings.setUnits(
          vm.vms.displaySettings.units.copyWith(
            temperature: TemperatureUnit.celsius,
          ),
        ),
      );
      await tester.runAsync(
        () => vm.settings.setPlanningPreferences(previousPreferences),
      );

      // All eight native roots, in the three supported themes at both scales.
      for (final field in [false, true]) {
        for (final appearance
            in field
                ? [Appearance.dark]
                : [Appearance.light, Appearance.dark]) {
          await tester.runAsync(() async {
            if (vm.theme.isFieldMode != field) await vm.theme.toggleFieldMode();
            await vm.vms.displaySettings.setAppearance(Appearance.system);
          });
          tester.platformDispatcher.platformBrightnessTestValue =
              appearance == Appearance.dark
              ? Brightness.dark
              : Brightness.light;
          for (final scale in [1.0, 2.0]) {
            tester.platformDispatcher.textScaleFactorTestValue = scale;
            final suffix =
                '${field ? 'field' : appearance.name}_${(scale * 100).round()}';
            for (final (route, name) in [
              (AppRouter.tonight, 'tonight'),
              (AppRouter.session(), 'plan'),
              (AppRouter.nightMoon, 'night'),
              (AppRouter.moon, 'moon'),
              (AppRouter.weather, 'weather'),
              (AppRouter.sessions, 'logbook'),
              (AppRouter.library, 'library'),
              (AppRouter.settings, 'settings'),
            ]) {
              await at(route);
              await shot('$name-$suffix');
            }
            await captureAppearance(suffix);
          }
        }
      }

      // Record a result only after the baseline captures; the plan snapshot
      // remains the saved plan while actual frame counts are stored separately.
      tester.platformDispatcher.textScaleFactorTestValue = 1;
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
      await tester.runAsync(() async {
        if (vm.theme.isFieldMode) await vm.theme.toggleFieldMode();
        await vm.vms.displaySettings.setAppearance(Appearance.light);
      });
      await at(AppRouter.nightMoon);
      await tap(find.text('Read the time browser'));
      expect(find.byKey(const Key('nightMoon.readingLegend')), findsOneWidget);
      await shot('night-reading-disclosure-light_100');
      await tap(find.text('Sun & twilight'));
      await shot('night-sun-disclosure-light_100');
      await at(AppRouter.moon);
      await tap(find.byKey(const Key('nightMoon.previewMoon')));
      expect(
        tester
            .state<ScrollableState>(find.byType(Scrollable).first)
            .position
            .pixels,
        greaterThan(0),
        reason: 'The Moon preview action scrolls to the existing time browser.',
      );
      await shot('moon-preview-jump-light_100');
      await tap(find.text('Moon details'));
      await shot('moon-details-disclosure-light_100');
      await at(AppRouter.weather);
      final refresh = find.byKey(const Key('weather.refresh'));
      await reveal(refresh);
      final viewedConditions = tester
          .element(refresh)
          .read<NightConditionsViewModel>();
      forecast.failure = WeatherFailure.unavailable;
      await tap(refresh);
      expect(
        (viewedConditions.nightWeather as NightWeatherAvailable).refreshFailed,
        WeatherFailure.unavailable,
      );
      await shot('weather-cached-refresh-failed-light_100');
      forecast.failure = WeatherFailure.outOfRange;
      await tester.runAsync(viewedConditions.refreshWeather);
      await _settle(tester);
      expect(find.byKey(const Key('weather.outOfRange')), findsOneWidget);
      await shot('weather-out-of-range-light_100');
      forecast.failure = null;
      await tester.runAsync(viewedConditions.refreshWeather);
      await _settle(tester);

      // The explicit per-plan buffer must not alter defaults while typing,
      // and persisted overrides must survive the real Logbook reopen action.
      await at(AppRouter.session());
      await tap(find.byKey(const Key('section.planner.assumptions')));
      final globalDefaults = vm.settings.planningPreferences;
      final inheritedAcquisition = vm.captureBudget.acquisitionMs;
      Future<void> fillOverrides() async {
        for (final (index, value) in [
          (0, '7'),
          (1, '2'),
          (2, '.75'),
          (3, '24'),
        ]) {
          final field = find.byKey(Key('planOverride.$index'));
          await reveal(field);
          await tester.enterText(field, value);
        }
        await _settle(tester);
      }

      await tap(find.byKey(const Key('planOverride.edit')));
      await fillOverrides();
      expect(
        vm.plan.planOverrides,
        isNull,
        reason: 'Typing is a local buffer.',
      );
      await tap(find.byKey(const Key('planOverride.apply')));
      expect(vm.plan.planOverrides!.interframeSeconds, 7);
      expect(vm.plan.planOverrides!.outsideSetupSeconds, 120);
      expect(vm.plan.planOverrides!.fixedMarginSeconds, 45);
      expect(vm.plan.planOverrides!.bytesPerFrame, 24000000);
      expect(vm.captureBudget.acquisitionMs, isNot(inheritedAcquisition));
      expect(vm.settings.planningPreferences, same(globalDefaults));
      await shot('plan-overrides-applied-light_100');
      await tap(find.byKey(const Key('planOverride.edit')));
      await tap(find.byKey(const Key('planOverride.reset')));
      expect(
        vm.plan.planOverrides,
        isNotNull,
        reason: 'Use defaults is buffered until Apply.',
      );
      await tap(find.byKey(const Key('planOverride.apply')));
      expect(vm.plan.planOverrides, isNull);
      expect(vm.captureBudget.acquisitionMs, inheritedAcquisition);
      expect(vm.settings.planningPreferences, same(globalDefaults));
      await tap(find.byKey(const Key('planOverride.edit')));
      await fillOverrides();
      await tap(find.byKey(const Key('planOverride.apply')));
      await tap(find.byKey(const Key('planner.save')));
      final overrideSaved = (await tester.runAsync(
        () => sessions.get(savedId),
      ))!;
      expect(overrideSaved.planOverrides!.interframeSeconds, 7);
      expect(overrideSaved.planOverrides!.bytesPerFrame, 24000000);
      await at(AppRouter.sessions);
      await tap(find.byKey(Key('logbook.title.$savedId')));
      await tap(find.text('Open in planner'));
      expect(vm.plan.planOverrides!.interframeSeconds, 7);
      expect(vm.plan.planOverrides!.fixedMarginSeconds, 45);
      await shot('plan-overrides-reopened-light_100');
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      await _settle(tester);
      await tap(find.byKey(const Key('planOverride.edit')));
      await reveal(find.byKey(const Key('planOverride.0')));
      await shot('plan-overrides-reopened-light_200');
      await tester.pageBack();
      await _settle(tester);
      tester.platformDispatcher.textScaleFactorTestValue = 1;
      await _settle(tester);
      await tap(find.byKey(const Key('planner.save')));
      // Saving replaces capture-block rows; use the current persisted IDs.
      final resultPlan = (await tester.runAsync(() => sessions.get(savedId)))!;
      final resultBlock = resultPlan.blocks.first;
      await at(AppRouter.results(savedId));
      await tap(find.byKey(const Key('results.outcome.partly')));
      final reportedCount = resultBlock.frameCount ~/ 2;
      final resultCount = find.byKey(Key('results.count.${resultBlock.id}'));
      await reveal(resultCount);
      await tester.enterText(resultCount, '$reportedCount');
      final notes = find.byKey(const Key('results.environment'));
      await reveal(notes);
      await tester.enterText(notes, 'Native migration test result');
      await _settle(tester);
      await shot('result-editor-keyboard-light_100');
      await tester.binding.handlePopRoute();
      await _settle(tester);
      expect(find.text('Discard result changes?'), findsOneWidget);
      await shot('result-discard-guard-light_100');
      await tap(find.byKey(const Key('confirm.cancel')));
      expect(
        tester.widget<TextFormField>(notes).controller!.text,
        'Native migration test result',
      );
      expect(
        tester.widget<TextFormField>(resultCount).controller!.text,
        '$reportedCount',
      );
      await tap(find.byKey(const Key('results.save')));
      final recorded = await tester.runAsync(() => sessions.get(savedId));
      expect(recorded!.status, SessionStatus.completed);
      expect(recorded.resultKind, ResultKind.partly);
      expect(
        recorded.record.environmentalNotes,
        'Native migration test result',
      );
      expect(
        (await tester.runAsync(() => sessions.execution(savedId)))!
            .completedFor(resultBlock.id),
        reportedCount,
      );
      await at(AppRouter.sessionDetail(savedId));
      await shot('recorded-result-light_100');
      await at(AppRouter.logbookProgress);
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byKey(const Key('fieldMode.toggle')), findsOneWidget);
      expect(find.byKey(Key('progress.${saved.targetId}')), findsOneWidget);
      await shot('recorded-progress-light_100');

      // A stored result's complete graph must survive delete and Undo.
      final manifestBeforeUndo = await tester.runAsync(
        () async => SessionManifestCodec.encode(
          [ExportedSession(recorded, await sessions.events(savedId))],
          exportedAtUtc: clock.nowUtc(),
          appVersion: 'native-migration-fixture',
        ),
      );
      await at(AppRouter.sessions);
      await tap(find.byKey(Key('logbook.title.$savedId')));
      await tap(find.byKey(const Key('detail.delete')));
      await tap(find.byKey(const Key('confirm.action')));
      expect(await tester.runAsync(() => sessions.get(savedId)), isNull);
      expect(find.text('Entry deleted'), findsOneWidget);
      await tap(find.text('Undo'));
      expect(find.text('Deletion undone'), findsOneWidget);
      final manifestAfterUndo = await tester.runAsync(
        () async => SessionManifestCodec.encode(
          [
            ExportedSession(
              (await sessions.get(savedId))!,
              await sessions.events(savedId),
            ),
          ],
          exportedAtUtc: clock.nowUtc(),
          appVersion: 'native-migration-fixture',
        ),
      );
      expect(
        manifestAfterUndo,
        manifestBeforeUndo,
        reason:
            'Undo restores IDs, snapshot, result, notes, blocks and events.',
      );
      await shot('logbook-delete-undone-light_100');

      final siteBeforeUndo = vm.site.activeSite!;
      await at(AppRouter.librarySites);
      await tap(find.byTooltip('Delete site'));
      await tap(find.byKey(const Key('confirm.action')));
      expect(find.text('Site deleted'), findsOneWidget);
      expect(
        find.text('Add site').hitTestable(),
        findsOneWidget,
        reason: 'Inline feedback does not cover the persistent Add action.',
      );
      await tap(find.text('Undo'));
      expect(find.text('Deletion undone'), findsOneWidget);
      expect(vm.site.activeSite!.id, siteBeforeUndo.id);
      expect(vm.site.activeSite!.latitude, siteBeforeUndo.latitude);
      expect(vm.site.activeSite!.longitude, siteBeforeUndo.longitude);
      expect(vm.site.activeSite!.timeZoneId, siteBeforeUndo.timeZoneId);
      await shot('site-delete-undone-light_100');

      // Inspect the real-font numeric layout on Android as well as in the
      // dedicated host clipping test. Cancel leaves the rig unchanged.
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      await at(AppRouter.libraryRigs);
      await tap(find.byType(ListTile));
      expect(find.byType(AlertDialog), findsOneWidget);
      await reveal(find.text('Resolution'));
      await shot('rig-resolution-light_200');
      await reveal(find.text('Sensor size'));
      await shot('rig-sensor-size-light_200');
      await tap(find.text('Cancel'));
      tester.platformDispatcher.textScaleFactorTestValue = 1;
      await _settle(tester);

      // Actual Android file I/O using an explicitly synthetic FITS sample.
      // This exercises the production parser/source, not a camera or picker.
      final fileEvidence = await tester.runAsync(() async {
        final root = await (await getApplicationDocumentsDirectory())
            .createTemp('hybrid-migration-test-');
        try {
          final fits = File(p.join(root.path, 'synthetic-light.fits'));
          await fits.writeAsBytes(
            fitsFile(ninaLight(width: 16, height: 16), dataBytes: 2880),
            flush: true,
          );
          final source = await FileMetadataSource.open(fits);
          try {
            final reading = await CaptureMetadataReader.read(source);
            expect(reading, isA<MetadataRead>());
            expect(reading.format, MetadataFormat.fits);
            final metadata = (reading as MetadataRead).metadata;
            expect(metadata.exposureSeconds.valueOrNull, 300);
            expect(metadata.acquisitionGain.valueOrNull, 100);
            expect(metadata.filterName.valueOrNull, 'Ha');
            expect(
              (metadata.exposureSeconds as KnownValue).origin.field,
              'EXPTIME',
            );
          } finally {
            await source.close();
          }

          // Use production backup/check/staging and an isolated restored SQLite
          // file. No live application database or native chooser is replaced.
          final destination = await Directory(p.join(root.path, 'restore'))
              .create();
          final temporary = await Directory(p.join(root.path, 'tmp')).create();
          final service = FileBackupService(
            db,
            sessions,
            clock: clock,
            dataDir: () async => destination,
            tempDir: () async => temporary,
          );
          final bytes = await service.createBackup();
          final checked = await service.checkFully(bytes);
          expect(checked.preview.schemaVersion, db.schemaVersion);
          await service.stage(checked);
          expect(await BackupStaging.isStaged(destination), isTrue);
          final outcome = await BackupStaging.apply(
            destination,
            nowUtc: clock.nowUtc(),
          );
          expect(outcome!.result, RestoreResult.applied);
          final restoredDb = AppDatabase(
            NativeDatabase(
              File(p.join(destination.path, BackupStaging.database)),
            ),
          );
          try {
            final restoredRepo = DriftSessionRepository(
              restoredDb,
              clock: clock,
            );
            final restored = await restoredRepo.get(savedId);
            expect(restored!.status, recorded.status);
            expect(restored.resultKind, recorded.resultKind);
            expect(restored.planSnapshot!.json, recorded.planSnapshot!.json);
            expect(
              restored.planOverrides!.toJson(),
              recorded.planOverrides!.toJson(),
            );
            expect(
              restored.record.environmentalNotes,
              recorded.record.environmentalNotes,
            );
            expect(
              restored.blocks.map((b) => b.frameCount),
              recorded.blocks.map((b) => b.frameCount),
            );
            expect(
              (await restoredRepo.execution(savedId))
                  .completedFor(resultBlock.id),
              reportedCount,
            );
            expect(
              (await restoredRepo.events(savedId)).length,
              (await sessions.events(savedId)).length,
            );
          } finally {
            await restoredDb.close();
          }
          expect(await BackupStaging.isStaged(destination), isFalse);
          return {
            'fits': 'Synthetic FITS through FileMetadataSource and production reader',
            'backup': 'Production archive, full candidate check, stage/apply and reopened SQLite',
            'backupBytes': bytes.length,
            'schemaVersion': db.schemaVersion,
          };
        } finally {
          await root.delete(recursive: true);
        }
      });
      binding.reportData ??= <String, dynamic>{};
      binding.reportData!['evidence'] = {
        'type': 'Android emulator integration test with controlled fixtures',
        'fixture':
            'Ljubljana / 2026-11-10 18:00 UTC / M42 / example rig and blocks',
        'savedRecordId': savedId,
        'fileEvidence': fileEvidence,
        'checks': [
          'Visible Save writes planned record with capture blocks',
          'Full-screen block editor keyboard input and Cancel leave plan unchanged',
          'Platform Back (route-pop message) on a dirty block editor asks first; '
              'Cancel keeps the editor, Discard leaves the plan unchanged',
          'Text scale and light/dark are in-process test values, not the '
              'Android system font or dark setting',
          'Logbook detail reopens same plan ID and frame counts',
          'Night browsing leaves active and stored plan date unchanged',
          'Settings unit selection changes display state',
          'Planning draft leaves globals/budget unchanged; Cancel discards; Save updates working budget without rewriting saved snapshot',
          'Eight real routes in light/dark/field at 100%/200%',
          'Night reading/Sun disclosures and Moon preview jump/details remain reachable',
          'Cached forecast retains typed refresh failure; out-of-range is explicit',
          'Per-plan buffer, Apply, defaults reset, Save and reopen preserve overrides without changing globals',
          'Partial result saves reported count and notes, then appears in target progress',
          'Stored result delete/Undo restores the exact portable manifest including IDs, blocks and events',
          'Active site delete/Undo restores ID, coordinates and zone; inline feedback leaves Add site hit-testable',
          'Synthetic FITS file parsed via Android file I/O with keyword provenance',
          'Backup roundtrip preserves saved snapshot, result, blocks and event count',
        ],
        'exclusions': [
          'physical device',
          'live weather or GPS',
          'native file providers, permissions or share sheet',
          'real camera-file metadata',
          'process restart persistence (database isolated in memory)',
          'pixel parity with web fixture',
        ],
      };
    },
    // The host quality gate discovers this file too. Android surface capture
    // and file-I/O evidence require the explicitly selected isolated emulator.
    skip: !Platform.isAndroid,
    timeout: const Timeout(Duration(minutes: 12)),
  );
}
