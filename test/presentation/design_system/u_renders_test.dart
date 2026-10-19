// F25 A1 (roadmap §2 "U"): host renders of the surfaces F05–F23 changed,
// through the real app, router and database, at 412 × 915 with real fonts
// (Roboto and the Material icons from the SDK) — light at 100 %, dark at
// 200 % and field mode (through the app's red filter) at 100 %, plus the
// block editor at 200 % with the keyboard open. Opt-in, outside the
// quality gate like the gallery: set ASTROPLAN_U_RENDERS to an output
// directory (docs/refinement/evidence/finalization/F25/renders) and run
// this file alone. Host renders only: not device evidence and not the
// owner's visual acceptance.

import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/services/catalog_seeder.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/models/session_result.dart';
import 'package:astroplan/domain/models/weather_snapshot.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/domain/services/astrobin_acquisitions.dart';
import 'package:astroplan/domain/services/session_exporter.dart';
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:astroplan/presentation/screens/sites/site_editor_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_device_time_zone.dart';
import '../../support/fake_location_service.dart';
import '../../support/fake_reverse_geocoder.dart';
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
  await (FontLoader(
    'MaterialIcons',
  )..addFont(read('materialicons-regular.otf'))).load();
}

enum _Variant {
  light100(Brightness.light, 1.0, false),
  dark200(Brightness.dark, 2.0, false),
  field100(Brightness.dark, 1.0, true);

  const _Variant(this.brightness, this.scale, this.field);
  final Brightness brightness;
  final double scale;
  final bool field;

  String get suffix => switch (this) {
    light100 => 'light_100',
    dark200 => 'dark_200',
    field100 => 'field_100',
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
  final out = Platform.environment[_variable];

  for (final v in _Variant.values) {
    testWidgets('U renders: ${v.suffix}', skip: out == null, (tester) async {
      await tester.runAsync(_loadFonts);
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      tester.platformDispatcher.platformBrightnessTestValue = v.brightness;
      tester.platformDispatcher.textScaleFactorTestValue = v.scale;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearAllTestValues);
      AppRouter.router.go(AppRouter.tonight);

      late AppDatabase db;
      late PlannerHarness vm;
      late int resultId, planId;
      final clock = FixedClock(DateTime.utc(2026, 11, 10, 18));
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
        vm = PlannerHarness(
          DriftTargetRepository(db),
          DriftEquipmentRepository(db),
          _Forecast(clock),
          DriftLocationRepository(db),
          locationService: FakeLocationService(),
          reverseGeocoder: FakeReverseGeocoder(),
          deviceTimeZone: FakeDeviceTimeZone(),
          clock: clock,
          sessionRepository: sessions,
          csvExporter: _NoShare(),
        );
        await vm.ready;
        await vm.choosePlan();
        await vm.plan.idle;
        final saved = await vm.analysis.saveSession();
        resultId = saved.id;
        // A result recorded early (F19) for the Logbook and the entry.
        await sessions.recordResult(
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
            child: const AstroPlanApp(),
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
        AppRouter.router.go(route);
        await shot(name);
      }

      Future<void> tap(Finder f) async {
        await tester.ensureVisible(f.first);
        await tester.tap(f.first);
        await _settle(tester);
      }

      Future<void> close() async {
        Navigator.of(tester.element(find.byType(Dialog).last)).pop();
        await _settle(tester);
      }

      await at(AppRouter.tonight, 'home');
      await at(AppRouter.session(), 'planner');
      await at(AppRouter.candidates, 'candidates');
      await at(AppRouter.nightMoon, 'night');
      await at(AppRouter.weather, 'weather');
      await at(AppRouter.sessions, 'logbook');
      await at(AppRouter.sessionDetail(resultId), 'entry');
      await at(AppRouter.results(planId), 'results');
      await at(AppRouter.settings, 'settings');
      await tester.scrollUntilVisible(
        find.byKey(const Key('settings.appearance')),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await shot('settings_display');
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
    });
  }
}
