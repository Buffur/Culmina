// Hybrid migration mode: ASTROPLAN_MIGRATION_RENDERS=<directory> captures
// all eight roots in six theme/scale variants, with the bundled Geist font.
// Optional ASTROPLAN_RENDER_VARIANT=light_100 and
// ASTROPLAN_RENDER_SURFACES=home scope early checks. Host fixture only:
// Ljubljana / 2026-11-10 and deterministic weather. A test-only browser adapter
// consumes the exported canonical fixture; neither is native-device evidence.
// F25 A1 (roadmap §2 "U"): host renders of the surfaces F05–F23 changed,
// through the real app, router and database, at 412 × 915 with real fonts
// (Roboto and the Material icons from the SDK) — light at 100 %, dark at
// 200 % and field mode (through the app's red filter) at 100 %, plus the
// block editor at 200 % with the keyboard open. Since the re-audit
// (2026-10-19) also the error and feedback states those tasks added (the
// unsaved Settings lines, the site editor's place-name offer, lookup and
// not-found lines and its "Use position" message, the target search's
// pending and failed states, the deleted-plan fallback, an empty AstroBin
// export), About with its licence statement, the map picker, and the site
// editor and result form with the keyboard open. Opt-in, outside the
// quality gate like the gallery: set ASTROPLAN_U_RENDERS to an output
// directory (docs/refinement/evidence/finalization/F25/renders) and run
// this file alone. Host renders only: not device evidence and not the
// owner's visual acceptance.

import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/core/units/display_units.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/repositories/shared_prefs_display_settings_repository.dart';
import 'package:astroplan/data/repositories/shared_prefs_planning_preferences_repository.dart';
import 'package:astroplan/data/services/catalog_seeder.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/models/planning_preferences.dart';
import 'package:astroplan/domain/models/session_result.dart';
import 'package:astroplan/domain/models/weather_snapshot.dart';
import 'package:astroplan/domain/repositories/storage_failure.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/domain/services/astrobin_acquisitions.dart';
import 'package:astroplan/domain/services/location_service.dart';
import 'package:astroplan/domain/services/reverse_geocoder.dart';
import 'package:astroplan/domain/services/session_exporter.dart';
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:astroplan/presentation/screens/sites/site_editor_screen.dart';
import 'package:astroplan/presentation/shared/deleted_plan_fallback.dart';
import 'package:astroplan/presentation/viewmodels/display_settings_viewmodel.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_device_time_zone.dart';
import '../../support/fake_location_service.dart';
import '../../support/fake_reverse_geocoder.dart';
import '../../support/hybrid_comparison_fixture.dart';
import '../../support/in_memory_first_run.dart';
import '../../support/in_memory_privacy_preferences.dart';
import '../../support/planner_harness.dart';
import '../../support/sdk_fonts.dart';

const _variable = 'ASTROPLAN_U_RENDERS';
const _shot = Key('u.render');

/// A forecast with every value, on whole hours.
class _Forecast implements WeatherRepository {
  _Forecast(this.clock);
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

/// The target search, held or failed on demand (F24 A6 states).
class _Targets extends DriftTargetRepository {
  _Targets(super.db);
  Completer<void>? hold;
  bool fail = false;

  @override
  Future<List<AstroTarget>> searchTargets(String query) async {
    if (hold case final h?) await h.future;
    if (fail) throw const StorageFailure('search the targets');
    return super.searchTargets(query);
  }
}

/// Planning settings whose writes fail on demand (F21 A5).
class _Planning extends SharedPrefsPlanningPreferencesRepository {
  bool fail = false;

  @override
  Future<void> save(PlanningPreferences preferences) => fail
      ? Future.error(const StorageFailure('save the planning preferences'))
      : super.save(preferences);
}

/// The place-name choice, its writes failing on demand (F21 A6).
class _Privacy extends InMemoryPrivacyPreferences {
  bool fail = false;

  @override
  Future<void> savePlaceNameLookup(bool on) async {
    if (fail) throw const StorageFailure('save the place-name setting');
    placeNameLookup = on;
  }
}

class _NoShare implements AstroBinCsvExporter {
  @override
  Future<void> share(AstroBinExport export) async {}
}

Future<void> _loadFonts() async {
  Future<ByteData> read(String f) {
    final file = sdkMaterialFont(f);
    if (file == null) throw StateError('$f not in the SDK');
    return file.readAsBytes().then((b) => ByteData.sublistView(b));
  }

  // Roboto under its name, and as the test's default family: a style that
  // names no family draws the device default (Roboto on Android), not the
  // test font's blocks.
  for (final family in ['Roboto', 'FlutterTest']) {
    final roboto = FontLoader(family);
    for (final f in [
      'roboto-regular.ttf',
      'roboto-medium.ttf',
      'roboto-bold.ttf',
    ]) {
      roboto.addFont(read(f));
    }
    await roboto.load();
  }
  await (FontLoader('Geist')..addFont(
        File('assets/fonts/Geist.ttf').readAsBytes().then(ByteData.sublistView),
      ))
      .load();
  await (FontLoader(
    'MaterialIcons',
  )..addFont(read('materialicons-regular.otf'))).load();
}

enum _Variant {
  light100(Brightness.light, 1.0, false),
  light200(Brightness.light, 2.0, false),
  dark100(Brightness.dark, 1.0, false),
  dark200(Brightness.dark, 2.0, false),
  field100(Brightness.dark, 1.0, true),
  field200(Brightness.dark, 2.0, true);

  const _Variant(this.brightness, this.scale, this.field);
  final Brightness brightness;
  final double scale;
  final bool field;

  String get suffix => switch (this) {
    light100 => 'light_100',
    light200 => 'light_200',
    dark100 => 'dark_100',
    dark200 => 'dark_200',
    field100 => 'field_100',
    field200 => 'field_200',
  };
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  final migrationOut = Platform.environment['ASTROPLAN_MIGRATION_RENDERS'];
  final out = migrationOut ?? Platform.environment[_variable];
  final migration = migrationOut != null;
  final wantedVariant = Platform.environment['ASTROPLAN_RENDER_VARIANT'];
  final wantedSurfaces = Platform.environment['ASTROPLAN_RENDER_SURFACES']
      ?.split(',');

  for (final v in _Variant.values) {
    if (!migration &&
        ![_Variant.light100, _Variant.dark200, _Variant.field100].contains(v)) {
      continue;
    }
    if (wantedVariant != null && v.suffix != wantedVariant) continue;
    testWidgets('U renders: ${v.suffix}', skip: out == null, (tester) async {
      await tester.runAsync(_loadFonts);
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      tester.platformDispatcher.platformBrightnessTestValue = v.brightness;
      tester.platformDispatcher.textScaleFactorTestValue = v.scale;
      if (migration) {
        tester.platformDispatcher.alwaysUse24HourFormatTestValue = true;
      }
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearAllTestValues);
      AppRouter.router.go(AppRouter.tonight);

      late AppDatabase db;
      late PlannerHarness vm;
      late _Targets targets;
      late int resultId, planId;
      late Future<void> Function() recordResult;
      final planning = _Planning();
      final privacy = _Privacy();
      var displayFails = false;
      final display = SharedPrefsDisplaySettingsRepository(
        beforeWrite: (_) async {
          if (displayFails) {
            throw const StorageFailure('save the display settings');
          }
        },
      );
      Future<LocationResult> Function()? fix;
      final location = FakeLocationService(
        answer: () =>
            fix?.call() ??
            Future.value(
              const LocationFound(
                DeviceLocation(latitude: 46.0569, longitude: 14.5058),
              ),
            ),
      );
      Completer<ReverseGeocodeResult>? lookup;
      final geocoder = FakeReverseGeocoder(answer: () => lookup!.future);
      final clock = FixedClock(DateTime.utc(2026, 11, 10, 18));
      final forecast = _Forecast(clock);
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
        SharedPreferences.setMockInitialValues({
          'activeLocationId': siteId,
          'firstRunDone': true,
        });
        final sessions = DriftSessionRepository(db, clock: clock);
        targets = _Targets(db);
        vm = PlannerHarness(
          targets,
          DriftEquipmentRepository(db),
          forecast,
          DriftLocationRepository(db),
          locationService: location,
          reverseGeocoder: geocoder,
          deviceTimeZone: FakeDeviceTimeZone(),
          clock: clock,
          sessionRepository: sessions,
          csvExporter: _NoShare(),
          preferencesRepository: planning,
          displaySettings: display,
          // The app's default: place names off until chosen.
          privacyPreferences: privacy,
          firstRun: migration ? InMemoryFirstRun(done: true) : null,
        );
        await vm.ready;
        await vm.choosePlan();
        await vm.plan.idle;
        final saved = await vm.analysis.saveSession();
        resultId = saved.id;
        // A result recorded early (F19) for the Logbook and the entry,
        // after the empty AstroBin export is shot.
        recordResult = () => sessions.recordResult(
          resultId,
          PartlyDone({
            saved.blocks.first.id: saved.blocks.first.frameCount ~/ 2,
          }),
        );
        await vm.lifecycle.newSession();
        await vm.plan.idle;
        await vm.choosePlan();
        await vm.plan.idle;
        planId = (await vm.analysis.saveSession()).id;
        if (v.field) await vm.theme.toggleFieldMode();
      });
      addTearDown(() => tester.runAsync(db.close));
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
      await tester.pumpWidget(
        RepaintBoundary(
          key: _shot,
          child: MultiProvider(
            providers: vm.providers,
            child: migration
                ? Builder(
                    builder: (context) => MediaQuery(
                      data: MediaQuery.of(context)
                          .copyWith(alwaysUse24HourFormat: true),
                      child: const AstroPlanApp(),
                    ),
                  )
                : const AstroPlanApp(),
          ),
        ),
      );
      await _settle(tester);

      Future<void> shot(String name) async {
        await _settle(tester);
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(_shot),
        );
        await tester.runAsync(() async {
          final image = await boundary.toImage();
          final png = await image.toByteData(format: ui.ImageByteFormat.png);
          image.dispose();
          await File('$out/${name}_${v.suffix}.png')
              .writeAsBytes(png!.buffer.asUint8List());
        });
      }

      Future<void> at(String route, String name) async {
        if (migration &&
            [
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
        await shot(name);
      }

      Future<void> tap(Finder f) async {
        await tester.ensureVisible(f.first);
        await tester.tap(f.first);
        await _settle(tester);
      }

      Future<void> close() async {
        final dialogs = find.byType(Dialog);
        final surface = dialogs.evaluate().isNotEmpty
            ? dialogs.last
            : find.byType(Scaffold).last;
        Navigator.of(tester.element(surface)).pop();
        await _settle(tester);
      }

      if (migration) {
        expect(
          MediaQuery.of(tester.element(find.byType(Scaffold).first))
              .alwaysUse24HourFormat,
          isTrue,
          reason: 'The canonical comparison fixture declares 24-hour display.',
        );
        if (v == _Variant.light100) {
          await tester.runAsync(
            () => exportHybridComparisonFixture(
              vm: vm,
              db: db,
              weather: forecast,
              destination: File(
                Platform.environment['ASTROPLAN_COMPARISON_FIXTURE'] ?? 'docs/design/migration/evidence/matched/canonical-fixture.json',
              ),
            ),
          );
        }
        // Real repository/calculation fixture exported above for the isolated
        // browser adapter. Shared input alone does not prove pixel parity.
        for (final (route, name) in [
          (AppRouter.tonight, 'home'),
          (AppRouter.session(), 'plan'),
          (AppRouter.nightMoon, 'night'),
          (AppRouter.moon, 'moon'),
          (AppRouter.weather, 'weather'),
          (AppRouter.sessions, 'logbook'),
          (AppRouter.library, 'library'),
          (AppRouter.settings, 'settings'),
        ]) {
          if (wantedSurfaces != null && !wantedSurfaces.contains(name)) {
            continue;
          }
          await at(route, name);
          expect(tester.takeException(), isNull, reason: '$name ${v.suffix}');
        }
        if (wantedSurfaces == null ||
            wantedSurfaces.contains('settings_sections')) {
          for (final section in [
            'appearance',
            'planning',
            'privacy',
            'backup',
          ]) {
            AppRouter.router.go(AppRouter.settings);
            await _settle(tester);
            await tap(find.byKey(Key('settings.open.$section')));
            await shot('settings_$section');
            expect(
              tester.takeException(),
              isNull,
              reason: 'settings $section ${v.suffix}',
            );
            Navigator.of(tester.element(find.byType(Scaffold).last)).pop();
            await _settle(tester);
          }
        }
        if (wantedSurfaces == null || wantedSurfaces.contains('plan_editor')) {
          // OPEN-01: the first block's editor, as the web's plan_editor
          // reference, then with an invalid exposure submitted.
          // The plan's list is lazy: a tall view builds the first block's
          // Edit; the editor is then shot at phone size.
          tester.view.physicalSize = const Size(412, 6000);
          await at(AppRouter.session(), 'plan');
          await tap(find.byKey(const Key('capture.edit.0')));
          tester.view.physicalSize = const Size(412, 915);
          await shot('plan_editor');
          await tester.enterText(
            find.byKey(const Key('blockDialog.exposure')),
            'invalid',
          );
          await tap(find.byKey(const Key('blockDialog.submit')));
          final scroll = find.byKey(const Key('blockEditor.scroll'));
          tester
              .state<ScrollableState>(
                find
                    .descendant(of: scroll, matching: find.byType(Scrollable))
                    .first,
              )
              .position
              .jumpTo(0);
          await shot('plan_editor_invalid');
          expect(tester.takeException(), isNull, reason: 'editor ${v.suffix}');
          await tap(find.byKey(const Key('blockDialog.cancel')));
        }
        return;
      }

      // F20: no entry has recorded frames yet.
      AppRouter.router.go(AppRouter.sessions);
      await _settle(tester);
      await tap(find.byKey(const Key('logbook.menu')));
      await tap(find.byKey(const Key('logbook.astrobin')));
      await shot('astrobin_empty');
      await close();
      await tester.runAsync(recordResult);

      await at(AppRouter.tonight, 'home');
      await at(AppRouter.session(), 'planner');
      await at(AppRouter.candidates, 'candidates');
      await at(AppRouter.nightMoon, 'night');
      await at(AppRouter.weather, 'weather');
      await at(AppRouter.sessions, 'logbook');
      await at(AppRouter.sessionDetail(resultId), 'entry');
      await at(AppRouter.results(planId), 'results');
      await at(AppRouter.settings, 'settings');
      await tap(find.byKey(const Key('settings.open.appearance')));
      await tester.scrollUntilVisible(
        find.byKey(const Key('settings.appearance')),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await shot('settings_display');
      Navigator.of(tester.element(find.byType(Scaffold).last)).pop();
      await _settle(tester);
      await at(AppRouter.librarySites, 'sites');
      await at(AppRouter.welcome, 'welcome');

      AppRouter.router.go(AppRouter.sessions);
      await _settle(tester);
      await tap(find.byKey(const Key('logbook.menu')));
      await tap(find.byKey(const Key('logbook.astrobin')));
      await shot('astrobin_preview');
      await tap(find.byKey(const Key('astrobin.cancel')));
      await tap(find.byKey(const Key('logbook.filters')));
      await shot('logbook_filters');
      await tap(find.byKey(const Key('logbook.filters.done')));

      AppRouter.router.go(AppRouter.libraryRigs);
      await _settle(tester);
      await tap(find.byType(ListTile));
      await shot('rig_editor');
      await close();

      unawaited(
        AppRouter.router.push(
          AppRouter.siteEdit,
          extra: SiteEditorArgs(site: vm.site.activeSite),
        ),
      );
      await shot('site_editor');
      AppRouter.router.pop();
      await _settle(tester);

      // The planner builds its list lazily: a tall view finds the capture
      // plan's first block; the editor is then shot at phone size.
      tester.view.physicalSize = const Size(412, 6000);
      AppRouter.router.go(AppRouter.session());
      await _settle(tester);
      await tap(
        find.ancestor(
          of: find.textContaining('×'),
          matching: find.byType(ListTile),
        ),
      );
      tester.view.physicalSize = const Size(412, 915);
      await shot('block_editor');
      if (v == _Variant.dark200) {
        // U: the block editor at 200 % with the keyboard open.
        tester.view.viewInsets = const FakeViewPadding(bottom: 300);
        await shot('block_editor_inset300');
        tester.view.resetViewInsets();
      }
      await tap(find.byKey(const Key('blockDialog.cancel')));

      // F23: About, with the licence and the accepted permission.
      await at(AppRouter.about, 'about');
      await tester.scrollUntilVisible(
        find.byKey(const Key('about.playServices')),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await shot('about_licence');

      // F24/F25: the map picker (host: no tiles load, the controls and the
      // attribution stay).
      unawaited(
        AppRouter.router.push(
          AppRouter.sitePick,
          extra: const LatLng(46.05, 14.51),
        ),
      );
      await shot('map_picker');
      AppRouter.router.pop();
      await _settle(tester);

      // F24 A6: the search while it runs, then failed.
      AppRouter.router.go(AppRouter.selectTarget);
      await _settle(tester);
      targets.hold = Completer<void>();
      await tester.enterText(find.byType(TextField).last, 'Orion');
      await shot('target_searching');
      targets.fail = true;
      targets.hold!.complete();
      targets.hold = null;
      await shot('target_search_failed');
      targets.fail = false;
      AppRouter.router.go(AppRouter.tonight);
      await _settle(tester);

      // F23 A5/A6: a new site from the position: the place-name offer, the
      // lookup, not found; then a fix found after the coordinates changed.
      unawaited(
        AppRouter.router.push(
          AppRouter.siteEdit,
          extra: const SiteEditorArgs(),
        ),
      );
      await _settle(tester);
      await tap(find.byKey(const Key('siteEditor.useCurrentPosition')));
      await shot('site_editor_offer');
      lookup = Completer();
      await tap(find.text('Turn on place names'));
      await shot('site_editor_looking');
      lookup.complete(const PlaceNameNotFound());
      await shot('site_editor_not_found');
      final later = Completer<LocationResult>();
      fix = () => later.future;
      await tap(find.byKey(const Key('siteEditor.useCurrentPosition')));
      final latitude = find.widgetWithText(TextFormField, 'Latitude (°)');
      await tester.scrollUntilVisible(
        latitude,
        -200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.enterText(latitude, '46.1');
      later.complete(
        const LocationFound(
          DeviceLocation(latitude: 46.0569, longitude: 14.5058),
        ),
      );
      await shot('site_editor_position_found');
      ScaffoldMessenger.of(tester.element(find.byType(Scaffold).last))
          .clearSnackBars();
      if (v == _Variant.dark200) {
        // The latitude field still has the focus.
        tester.view.viewInsets = const FakeViewPadding(bottom: 300);
        await shot('site_editor_inset300');
        tester.view.resetViewInsets();
      }
      AppRouter.router.pop();
      await _settle(tester);

      if (v == _Variant.dark200) {
        // The result form with the keyboard open.
        AppRouter.router.go(AppRouter.results(planId));
        await _settle(tester);
        tester.view.viewInsets = const FakeViewPadding(bottom: 300);
        await shot('results_inset300');
        tester.view.resetViewInsets();
      }

      // F21 A5/A6: Settings whose writes fail: each unsaved line with Retry.
      planning.fail = true;
      privacy.fail = true;
      displayFails = true;
      final scope = tester.element(find.byType(Scaffold).first);
      // In the test's zone, like a tap: each fails and is shown unsaved.
      for (final write in [
        () => vm.settings.setMinAltitude(25),
        () => vm.settings.setPlaceNameLookup(false),
        () {
          final d = scope.read<DisplaySettingsViewModel>();
          return d.setUnits(d.units.copyWith(wind: WindUnit.mph));
        },
      ]) {
        unawaited(write().then((_) {}, onError: (Object _) {}));
      }
      await _settle(tester);
      AppRouter.router.go(AppRouter.settings);
      await _settle(tester);
      for (final (key, name, section) in [
        ('settings.unsaved', 'settings_unsaved', 'planning'),
        (
          'settings.placeNames.unsaved',
          'settings_place_names_unsaved',
          'privacy',
        ),
        ('settings.display.unsaved', 'settings_display_unsaved', 'appearance'),
      ]) {
        await tap(find.byKey(Key('settings.open.$section')));
        // From the top each time.
        await tester.fling(
          find.byType(Scrollable).first,
          const Offset(0, 20000),
          5000,
        );
        await _settle(tester);
        await tester.scrollUntilVisible(
          find.byKey(Key(key)),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        await shot(name);
        Navigator.of(tester.element(find.byType(Scaffold).last)).pop();
        await _settle(tester);
      }

      // F22 A1: a restored plan that was deleted meanwhile: Tonight, and
      // why.
      AppRouter.router.go(AppRouter.tonight);
      await _settle(tester);
      showDeletedPlanFallback(
        tester.element(find.byKey(const Key('tonight.title'))),
      );
      // On a restore the call comes during a build; here a frame is asked
      // for, and the message comes after it.
      tester.binding.scheduleFrame();
      await tester.pump();
      await shot('deleted_plan_fallback');
    });
  }
}
