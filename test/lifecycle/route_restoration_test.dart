// F22 A1/A2 (TD-094): after the system kills the app in the background, the
// open route comes back through Flutter state restoration (HOST: the
// framework's restoration data, captured and restored in a new app graph
// on the same database; the Android process-death run is an emulator row).
// A restored planner never adopts the plan its route named; a route whose
// plan was deleted shows Tonight and says why; a route whose arguments
// cannot be restored goes back to its list; a restored result form writes
// nothing until the user saves. Typed but unsaved form fields are not
// restored (documented, TD-094's contract).

import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/services/catalog_seeder.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/models/session.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:astroplan/presentation/screens/sites/site_editor_screen.dart';
import 'package:astroplan/presentation/shared/deleted_plan_fallback.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fake_device_time_zone.dart';
import '../support/fake_location_service.dart';
import '../support/fake_reverse_geocoder.dart';
import '../support/no_snapshot_weather.dart';
import '../support/planner_harness.dart';
import '../support/test_clock.dart';

class _NoForecast with NoSnapshotWeather implements WeatherRepository {}

void main() {
  late AppDatabase db;
  late DriftSessionRepository sessions;
  late PlannerHarness vm;

  /// A new app graph on the same database and preferences: what a restart
  /// after a process death builds.
  Future<void> boot(WidgetTester tester, {bool first = false}) async {
    await tester.runAsync(() async {
      if (first) {
        SharedPreferences.setMockInitialValues({});
        db = AppDatabase(NativeDatabase.memory());
        await CatalogSeeder(DriftTargetRepository(db)).seedIfNeeded();
        await EquipmentSeeder(DriftEquipmentRepository(db)).seedIfNeeded();
        final id = await DriftLocationRepository(db).insertLocation(
          domain.LocationProfile(
            id: 0,
            name: 'Home',
            latitude: 46.05,
            longitude: 14.51,
            timeZoneId: 'Europe/Ljubljana',
          ),
        );
        final p = await SharedPreferences.getInstance();
        await p.setInt('activeLocationId', id);
      }
      sessions = DriftSessionRepository(db, clock: testEvening);
      vm = PlannerHarness(
        DriftTargetRepository(db),
        DriftEquipmentRepository(db),
        _NoForecast(),
        DriftLocationRepository(db),
        locationService: FakeLocationService(),
        reverseGeocoder: FakeReverseGeocoder(),
        deviceTimeZone: FakeDeviceTimeZone(),
        sessionRepository: sessions,
        clock: testEvening,
      );
      await vm.ready;
      if (first) {
        await vm.choosePlan();
        await vm.plan.idle;
      }
    });
    await tester.pumpWidget(
      MultiProvider(providers: vm.providers, child: const AstroPlanApp()),
    );
    await settle(tester);
  }

  /// Kills and restarts: the restoration data the system would keep, a new
  /// graph (the router back at its start), then the data restored.
  Future<void> killAndRestore(WidgetTester tester) async {
    final data = await tester.getRestorationData();
    AppRouter.router.go(AppRouter.tonight);
    await settle(tester);
    await boot(tester);
    await tester.restoreFrom(data);
    await settle(tester);
  }

  String location() =>
      AppRouter.router.routerDelegate.currentConfiguration.uri.toString();

  setUp(() {
    // Each test starts on Tonight, as a fresh start would.
    AppRouter.router.go(AppRouter.tonight);
  });

  testWidgets('A1: the planner comes back after a process death, on the '
      'plan it showed', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    addTearDown(tester.view.reset);
    await boot(tester, first: true);
    addTearDown(() => tester.runAsync(db.close));
    final saved = await tester.runAsync(() => vm.analysis.saveSession());
    AppRouter.router.go(AppRouter.session());
    await settle(tester);
    expect(location(), AppRouter.session());

    await killAndRestore(tester);
    expect(location(), AppRouter.session());
    expect(find.byKey(const Key('planner.status')), findsOneWidget);
    expect(vm.plan.activeSessionId, saved!.id);
  });

  testWidgets('A2: a restored planner never adopts the plan its route named', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2400);
    addTearDown(tester.view.reset);
    await boot(tester, first: true);
    addTearDown(() => tester.runAsync(db.close));
    final x = await tester.runAsync(() => vm.analysis.saveSession());
    AppRouter.router.go(AppRouter.session(x!.id));
    await settle(tester);
    // Meanwhile the planner moved on to another plan (a new one).
    await tester.runAsync(() async {
      await vm.lifecycle.newSession();
      await vm.plan.idle;
    });
    final current = vm.plan.activeSessionId;
    expect(current, isNot(x.id));

    await killAndRestore(tester);
    expect(location(), AppRouter.session(x.id));
    expect(vm.plan.activeSessionId, current, reason: 'not adopted again');
    final stored = await tester.runAsync(() => sessions.get(x.id));
    expect(stored!.status, SessionStatus.planned);
  });

  testWidgets('A1: a restored result form for a plan deleted meanwhile shows '
      'Tonight and says why', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    addTearDown(tester.view.reset);
    await boot(tester, first: true);
    addTearDown(() => tester.runAsync(db.close));
    final s = await tester.runAsync(() => vm.analysis.saveSession());
    AppRouter.router.go(AppRouter.results(s!.id));
    await settle(tester);
    expect(find.byKey(const Key('results.review')), findsOneWidget);
    final data = await tester.getRestorationData();
    await tester.runAsync(() => sessions.delete(s.id));

    AppRouter.router.go(AppRouter.tonight);
    await settle(tester);
    await boot(tester);
    await tester.restoreFrom(data);
    await settle(tester);
    expect(location(), AppRouter.tonight);
    expect(find.text(deletedPlanMessage), findsOneWidget);
  });

  testWidgets('A1: a restored planner route for a saved plan deleted '
      'meanwhile shows Tonight and says why', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    addTearDown(tester.view.reset);
    await boot(tester, first: true);
    addTearDown(() => tester.runAsync(db.close));
    final x = await tester.runAsync(() => vm.analysis.saveSession());
    AppRouter.router.go(AppRouter.session(x!.id));
    await settle(tester);
    expect(location(), AppRouter.session(x.id));
    expect(find.byKey(const Key('planner.status')), findsOneWidget);
    final data = await tester.getRestorationData();
    await tester.runAsync(() => sessions.delete(x.id));

    AppRouter.router.go(AppRouter.tonight);
    await settle(tester);
    await boot(tester);
    await tester.restoreFrom(data);
    await settle(tester);
    expect(location(), AppRouter.tonight);
    expect(find.text(deletedPlanMessage), findsOneWidget);
    expect(await tester.runAsync(() => sessions.get(x.id)), isNull);
  });

  testWidgets('A1: a restored planner route whose plan still exists stays '
      'on the planner and says nothing', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    addTearDown(tester.view.reset);
    await boot(tester, first: true);
    addTearDown(() => tester.runAsync(db.close));
    final x = await tester.runAsync(() => vm.analysis.saveSession());
    AppRouter.router.go(AppRouter.session(x!.id));
    await settle(tester);

    await killAndRestore(tester);
    expect(location(), AppRouter.session(x.id));
    expect(find.byKey(const Key('planner.status')), findsOneWidget);
    expect(find.text(deletedPlanMessage), findsNothing);
  });

  testWidgets('A1/A2: a restored result form reloads the stored entry; Back '
      'writes nothing (typed values are not restored)', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    addTearDown(tester.view.reset);
    await boot(tester, first: true);
    addTearDown(() => tester.runAsync(db.close));
    final s = await tester.runAsync(() => vm.analysis.saveSession());
    AppRouter.router.go(AppRouter.results(s!.id));
    await settle(tester);

    await killAndRestore(tester);
    expect(location(), AppRouter.results(s.id));
    expect(find.byKey(const Key('results.review')), findsOneWidget);
    AppRouter.router.go(AppRouter.sessions); // leaving the form
    await settle(tester);
    final stored = await tester.runAsync(() => sessions.get(s.id));
    expect(stored!.status, SessionStatus.planned);
    expect(await tester.runAsync(() => sessions.events(s.id)), isEmpty);
  });

  testWidgets('A2: a restored site editor, whose site cannot be restored, '
      'returns to the sites list; nothing is added or activated', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2400);
    addTearDown(tester.view.reset);
    await boot(tester, first: true);
    addTearDown(() => tester.runAsync(db.close));
    final home = vm.site.activeSite!;
    // ignore: unawaited_futures, the editor stays open
    AppRouter.router.push(
      AppRouter.siteEdit,
      extra: SiteEditorArgs(site: home),
    );
    await settle(tester);
    expect(find.text('Home'), findsWidgets);

    await killAndRestore(tester);
    expect(location(), AppRouter.librarySites);
    expect(vm.site.sites, hasLength(1));
    expect(vm.site.activeSite!.id, home.id);
  });
}

/// Pumps fixed frames with real-time gaps (database writes).
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump(const Duration(milliseconds: 200));
  }
}
