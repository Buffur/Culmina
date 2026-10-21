// TASK 12.2 (ADR-015): the navigation shell — every screen is reachable per
// the route map, each tab keeps its state, Android back pops within a tab
// and then returns to Tonight, and the planner opens above the tabs.

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/services/catalog_seeder.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/repositories/equipment_repository.dart';
import 'package:astroplan/domain/repositories/location_repository.dart';
import 'package:astroplan/domain/repositories/session_repository.dart';
import 'package:astroplan/domain/repositories/target_repository.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/main.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/repositories/storage_failure.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:astroplan/presentation/screens/settings/settings_screen.dart';
import 'package:astroplan/presentation/widgets/planner_sections.dart';

import '../../support/planner_harness.dart';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_device_time_zone.dart';
import '../../support/fake_location_service.dart';
import '../../support/fake_reverse_geocoder.dart';
import '../../support/no_snapshot_weather.dart';
import '../../support/route_paths.dart';

import 'package:astroplan/presentation/viewmodels/library_viewmodels.dart';

import '../../support/test_clock.dart';

class _NoWeather with NoSnapshotWeather implements WeatherRepository {}

class _GearRepository extends DriftEquipmentRepository {
  _GearRepository(super.db);
  bool failReads = false;

  @override
  Future<List<EquipmentProfile>> getAllEquipment() {
    if (failReads) throw const StorageFailure('load library rigs');
    return super.getAllEquipment();
  }
}

void main() {
  late AppDatabase db;
  late PlannerHarness vm;
  late _GearRepository gearRepository;

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(900, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    AppRouter.router.go(AppRouter.tonight);
    late DriftSessionRepository sessions;
    await tester.runAsync(() async {
      db = AppDatabase(NativeDatabase.memory());
      gearRepository = _GearRepository(db);
      await CatalogSeeder(DriftTargetRepository(db)).seedIfNeeded();
      await EquipmentSeeder(DriftEquipmentRepository(db)).seedIfNeeded();
      final siteId = await DriftLocationRepository(db).insertLocation(
        domain.LocationProfile(
          id: 0,
          name: 'Ljubljana',
          latitude: 46.05,
          longitude: 14.51,
          elevation: 300,
        ),
      );
      SharedPreferences.setMockInitialValues({'activeLocationId': siteId});
      sessions = DriftSessionRepository(db, clock: testEvening);
      vm = PlannerHarness(
        DriftTargetRepository(db),
        gearRepository,
        _NoWeather(),
        DriftLocationRepository(db),
        locationService: FakeLocationService(),
        reverseGeocoder: FakeReverseGeocoder(),
        deviceTimeZone: FakeDeviceTimeZone(),
        clock: FixedClock(DateTime.utc(2026, 11, 10, 18)),
        sessionRepository: sessions,
      );
      await vm.ready;
    });
    addTearDown(() => tester.runAsync(db.close));
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AppDatabase>.value(value: db),
          Provider<TargetRepository>.value(value: DriftTargetRepository(db)),
          ChangeNotifierProvider(
            create: (_) => TargetsViewModel(DriftTargetRepository(db)),
          ),
          Provider<EquipmentRepository>.value(value: gearRepository),
          ChangeNotifierProvider(create: (_) => GearViewModel(gearRepository)),
          Provider<LocationRepository>.value(
            value: DriftLocationRepository(db),
          ),
          Provider<SessionRepository>.value(value: sessions),
          ChangeNotifierProvider(
            create: (_) => SessionsViewModel(sessions, clock: testEvening),
          ),
          ...vm.providers,
        ],
        child: const AstroPlanApp(),
      ),
    );
    await settle(tester);
  }

  /// The visible page's app-bar title (a pushed route does not change
  /// the router's `uri`, so tests look at what is on screen). Since S6.16
  /// Tonight's title is its page's own header, not the app bar's.
  Finder title(String text) => text == 'Tonight'
      ? find.byKey(const Key('tonight.title'))
      : find.widgetWithText(AppBar, text);

  Future<void> back(WidgetTester tester) async {
    await tester.binding.handlePopRoute();
    await settle(tester);
  }

  Future<void> tapTab(WidgetTester tester, String label) async {
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(label),
      ),
    );
    await settle(tester);
  }

  testWidgets('the app opens on Tonight with four tabs', (tester) async {
    await pumpApp(tester);
    expect(title('Tonight'), findsOneWidget);
    final bar = find.byType(NavigationBar);
    expect(bar, findsOneWidget);
    for (final tab in ['Tonight', 'Logbook', 'Library', 'Settings']) {
      expect(
        find.descendant(of: bar, matching: find.text(tab)),
        findsOneWidget,
      );
    }
  });

  // D-05 (Hybrid migration): a Settings group and About open as details
  // above the tabs, with no root navigation underneath; Back returns to
  // the Settings root with its tabs.
  testWidgets('Settings groups and About open above the tabs', (tester) async {
    await pumpApp(tester);
    await tapTab(tester, 'Settings');
    for (final (key, heading) in [
      ('settings.open.planning', 'Planning'),
      ('settings.open.appearance', 'Appearance'),
    ]) {
      await tester.tap(find.byKey(Key(key)));
      await settle(tester);
      expect(title(heading), findsOneWidget, reason: heading);
      expect(find.byType(NavigationBar), findsNothing, reason: heading);
      await back(tester);
      expect(title('Settings'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
    }
    final about = find.byKey(const Key('settings.open.about'));
    await tester.ensureVisible(about);
    await tester.tap(about);
    await settle(tester);
    expect(title('About & data sources'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing, reason: 'About');
    await back(tester);
    expect(title('Settings'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  // The count reads in the singular for one rig.
  String rigCount(int n) => '$n ${n == 1 ? 'rig' : 'rigs'} ·';

  testWidgets('Library counts refresh after edits and a failed read offers '
      'retry without presenting stale counts', (tester) async {
    await pumpApp(tester);
    await tapTab(tester, 'Library');
    final rigs = (await tester.runAsync(gearRepository.getAllEquipment))!;
    expect(find.textContaining(rigCount(rigs.length)), findsOneWidget);
    final gear = Provider.of<GearViewModel>(
      tester.element(title('Library')),
      listen: false,
    );
    gearRepository.failReads = true;
    await tester.runAsync(() => gear.update(rigs.first));
    await settle(tester);
    expect(find.textContaining(rigCount(rigs.length)), findsNothing);
    expect(find.byKey(const Key('library.retryCounts')), findsOneWidget);
    expect(title('Library'), findsOneWidget);
    gearRepository.failReads = false;
    await tester.tap(find.byKey(const Key('library.retryCounts')));
    await settle(tester);
    expect(find.textContaining(rigCount(rigs.length)), findsOneWidget);
    expect(find.byKey(const Key('library.retryCounts')), findsNothing);
    await tester.runAsync(() => gear.delete(rigs.last.id));
    await settle(tester);
    expect(find.textContaining(rigCount(rigs.length - 1)), findsOneWidget);
  });

  // Acceptance: every screen is reachable per the map.
  testWidgets('every route in the map opens its screen', (tester) async {
    await pumpApp(tester);
    final expected = {
      AppRouter.tonight: 'Open planner',
      AppRouter.candidates: "Tonight's candidates",
      AppRouter.sessions: 'Logbook',
      AppRouter.logbookProgress: 'Progress by target', // S8.5
      AppRouter.library: 'Library',
      AppRouter.libraryRigs: 'Rigs',
      AppRouter.libraryTargets: 'Targets',
      AppRouter.librarySites: 'Sites',
      AppRouter.settings: 'Settings', // S9.4
      AppRouter.about: 'About & data sources',
      AppRouter.planSettings: 'Planning settings', // F12
      AppRouter.session(): 'Plan',
      AppRouter.selectTarget: 'Choose a target',
      AppRouter.selectRig: 'Choose a rig',
      AppRouter.selectSite: 'Choose a site',
    };
    for (final entry in expected.entries) {
      AppRouter.router.go(entry.key);
      await settle(tester);
      expect(
        find.text(entry.value),
        findsWidgets,
        reason: '${entry.key} shows "${entry.value}"',
      );
    }
    expect(
      allRoutePaths(),
      containsAll([
        AppRouter.siteEdit,
        AppRouter.sitePick,
        AppRouter.position,
        '/session/:id',
      ]),
    );
    for (final old in ['/logbook', '/equipment', '/target', '/about']) {
      expect(allRoutePaths(), isNot(contains(old)), reason: old);
    }
  });

  testWidgets('back pops within a tab, then returns to Tonight', (
    tester,
  ) async {
    await pumpApp(tester);
    await tapTab(tester, 'Library');
    await tester.tap(find.text('Rigs'));
    await settle(tester);
    expect(title('Rigs'), findsOneWidget); // S9.1: the Library manages

    await back(tester);
    expect(title('Rigs'), findsNothing);
    expect(title('Library'), findsOneWidget);
    await back(tester);
    expect(title('Tonight'), findsOneWidget);
  });

  testWidgets('each tab keeps its place', (tester) async {
    await pumpApp(tester);
    await tapTab(tester, 'Library');
    await tester.tap(find.text('Sites'));
    await settle(tester);
    await tapTab(tester, 'Settings');
    expect(title('Settings'), findsOneWidget);
    await tapTab(tester, 'Library');
    expect(title('Sites'), findsOneWidget, reason: 'the pushed page is kept');
  });

  testWidgets('the planner opens above the tabs and back returns to Tonight', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.byKey(const Key('tonight.openPlanner')));
    await settle(tester);
    expect(find.text('Plan'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    await back(tester);
    expect(title('Tonight'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
  // F12 A4 (UX-S R3): "Change in Settings" opens the planning settings over
  // the plan, with their global scope said; Back returns to the same plan
  // and its open section, the blocks and results kept, the change applied.
  testWidgets('Change in Settings opens over the plan; Back returns to the '
      'same plan and section', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byKey(const Key('tonight.openPlanner')));
    await settle(tester);
    await tester.runAsync(
      () => vm.addCaptureBlock(
        CaptureBlock(
          frameType: FrameType.light,
          filterName: 'Ha',
          exposureTimeSeconds: 120,
          frameCount: 12,
        ),
      ),
    );
    await tester.runAsync(
      () => vm.disclosure.setOpen(PlannerSections.assumptions, true),
    );
    await settle(tester);
    final blocks = vm.captureBlocks;
    final change = find.byKey(const Key('capturePlan.changeSettings'));
    await tester.ensureVisible(change);
    await settle(tester);
    expect(find.text('Change in Settings'), findsOneWidget);
    expect(find.text('Change in Planning Settings'), findsNothing);
    await tester.tap(change);
    await settle(tester);

    expect(title('Planning settings'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing, reason: 'over the plan');
    expect(find.text(SettingsScreen.scopeNotice), findsOneWidget);
    for (final kept in [
      'Imaging window',
      'Capture budget',
      'Advanced',
      'Guidance',
    ]) {
      expect(find.text(kept), findsWidgets, reason: kept);
    }
    for (final other in ['Display', 'Privacy', 'Data', 'About']) {
      expect(find.text(other), findsNothing, reason: other);
    }
    await tester.runAsync(
      () => vm.settings.setPlanningPreferences(
        vm.planningPreferences.copyWith(feasibilityMarginPercent: 25),
      ),
    );
    await settle(tester);

    await back(tester);
    expect(find.text('Plan'), findsOneWidget, reason: 'the same plan');
    expect(vm.captureBlocks, blocks, reason: 'the edits are kept');
    expect(vm.disclosure.isOpen(PlannerSections.assumptions), isTrue);
    expect(find.byKey(const Key('capturePlan.changeSettings')), findsOneWidget);
    expect(find.text('25 %'), findsOneWidget, reason: 'the change applied');
  });
}

/// Lets database and isolate futures complete and page transitions finish.
/// Fixed frames rather than `pumpAndSettle`: the candidates screen shows a
/// progress indicator while its background isolate runs.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }
}
