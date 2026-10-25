// S9.1 (RD-07, TD-053; E.1, D9-1, D9-2): the Library manages. A tap on a
// rig, target or site opens its record (library.js `detailView`) and never
// changes the plan or the active site; the same lists opened to choose
// (`/select/…`) still choose. "Plan this target" starts a new plan after the
// leave guard. Rigs, your own targets and sites are deleted through the
// shared confirmation, from the record's visible Delete or a swipe; a
// cancelled delete leaves everything as it was. The bundled catalogue is
// read-only (library.js catalogue record), so the plan's deletable target
// below is one of your own.

import 'dart:async';

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/services/catalog_seeder.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:astroplan/presentation/screens/library/library_parts.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/fake_device_time_zone.dart';
import '../../../support/fake_location_service.dart';
import '../../../support/fake_reverse_geocoder.dart';
import '../../../support/no_snapshot_weather.dart';
import '../../../support/planner_harness.dart';
import '../../../support/library_finders.dart';

class _NoForecast with NoSnapshotWeather implements WeatherRepository {}

void main() {
  late AppDatabase db;
  late PlannerHarness vm;
  late int homeId;

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  /// A Library row by its title.
  Finder row(String title) => find.widgetWithText(LibraryRow, title);

  /// Your own target, chosen for the plan: the catalogue cannot be deleted.
  Future<AstroTarget> ownPlanTarget(WidgetTester tester) async {
    final own = (await tester.runAsync(() async {
      final repo = DriftTargetRepository(db);
      final id = await repo.insertTarget(
        const AstroTarget(
          id: 0,
          catalogId: 'Own 1',
          commonName: 'Own nebula',
          rightAscension: 83.82,
          declination: -5.39,
          type: 'Nebula',
          source: 'user',
        ),
      );
      final t = (await repo.getTargetById(id))!;
      await vm.plan.setTarget(t);
      await vm.plan.idle;
      return t;
    }))!;
    return own;
  }

  Future<void> start(WidgetTester tester, String route) async {
    tester.view.physicalSize = const Size(800, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      db = AppDatabase(NativeDatabase.memory());
      await CatalogSeeder(DriftTargetRepository(db)).seedIfNeeded();
      await EquipmentSeeder(DriftEquipmentRepository(db)).seedIfNeeded();
      final sites = DriftLocationRepository(db);
      homeId = await sites.insertLocation(
        domain.LocationProfile(
          id: 0,
          name: 'Home',
          latitude: 46.05,
          longitude: 14.51,
          elevation: 300,
          timeZoneId: 'Europe/Ljubljana',
        ),
      );
      await sites.insertLocation(
        domain.LocationProfile(
          id: 0,
          name: 'Dark site',
          latitude: 45.9,
          longitude: 14.2,
          elevation: 900,
          timeZoneId: 'Europe/Ljubljana',
        ),
      );
      SharedPreferences.setMockInitialValues({'activeLocationId': homeId});
      final clock = FixedClock(DateTime.utc(2026, 11, 10, 18));
      vm = PlannerHarness(
        DriftTargetRepository(db),
        DriftEquipmentRepository(db),
        _NoForecast(),
        sites,
        locationService: FakeLocationService(),
        reverseGeocoder: FakeReverseGeocoder(),
        deviceTimeZone: FakeDeviceTimeZone(),
        clock: clock,
        sessionRepository: DriftSessionRepository(db, clock: clock),
      );
      await vm.ready;
      await vm.choosePlan(); // M42, the first rig, the example plan
      await vm.plan.idle;
    });
    addTearDown(() => tester.runAsync(db.close));
    AppRouter.router.go(route);
    await tester.pumpWidget(
      MultiProvider(providers: vm.providers, child: const AstroPlanApp()),
    );
    await settle(tester);
  }

  testWidgets('a tap on a rig in the Library opens it; the plan keeps its '
      'rig', (tester) async {
    await start(tester, AppRouter.libraryRigs);
    final rig = vm.plan.selectedEquipment!;
    expect(find.text('Chosen for this plan'), findsNothing);
    await tester.tap(row(rig.name));
    await settle(tester);
    expect(find.byKey(const Key('rigDetail.edit')), findsOneWidget);
    expect(find.byKey(const Key('rigDetail.delete')), findsOneWidget);
    await tester.binding.handlePopRoute();
    await settle(tester);
    expect(vm.plan.selectedEquipment!.id, rig.id);
    expect(find.text('Rigs'), findsWidgets);
  });

  testWidgets('a tap on a target in the Library opens it; the plan keeps its '
      'target; Plan this target asks first, then plans it', (tester) async {
    await start(tester, AppRouter.libraryTargets);
    final m42 = vm.plan.selectedTarget!;
    await tester.enterText(find.byType(TextField).first, 'M31');
    await settle(tester);
    await tester.tap(row('Andromeda Galaxy (M31)'));
    await settle(tester);
    expect(find.text('Catalogue record'), findsOneWidget);
    expect(
      vm.plan.selectedTarget!.id,
      m42.id,
      reason: 'browsing chose nothing',
    );

    await tester.tap(find.byKey(const Key('targetDetail.plan')));
    await settle(tester);
    // The plan has unsaved edits (choosePlan): Save · Discard · Cancel.
    expect(find.byKey(const Key('unsaved.discard')), findsOneWidget);
    await tester.tap(find.byKey(const Key('unsaved.discard')));
    await settle(tester);
    expect(vm.plan.selectedTarget!.catalogId, 'M31');
    expect(find.text('New plan for Andromeda Galaxy'), findsOneWidget);
  });

  testWidgets('a tap on a site in the Library opens it and never changes the '
      'active site; from /select/site it does', (tester) async {
    await start(tester, AppRouter.librarySites);
    expect(vm.site.activeSite!.id, homeId);
    await tester.tap(find.text('Dark site'));
    await settle(tester);
    expect(vm.site.activeSite!.id, homeId, reason: 'browsing selects nothing');
    expect(find.text('Dark site'), findsWidgets); // the editor, pre-filled

    AppRouter.router.go(AppRouter.selectSite);
    await settle(tester);
    expect(find.text('Manage sites'), findsOneWidget);
    await tester.tap(find.text('Dark site'));
    await settle(tester);
    expect(vm.site.activeSite!.name, 'Dark site');
  });

  // Hybrid (plan.js choiceView): /select/target is the plan's scoped
  // chooser; a choice applies only with Apply changes, Close keeps the plan.
  testWidgets('from /select/target a choice applies with Apply changes', (
    tester,
  ) async {
    await start(tester, AppRouter.tonight);
    unawaited(
      AppRouter.router.push(AppRouter.selectTarget),
    ); // as the planner opens it
    await settle(tester);
    expect(find.text('Choose a target'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('planTarget.search')), 'M31');
    await settle(tester);
    final m31 = find.text('M31 · Andromeda Galaxy');
    await tester.tap(m31);
    await settle(tester);
    expect(vm.plan.selectedTarget?.catalogId, isNot('M31'), reason: 'a draft');
    await tester.tap(find.byKey(const Key('scoped.close')));
    await settle(tester);
    expect(vm.plan.selectedTarget?.catalogId, isNot('M31'), reason: 'closed');

    unawaited(AppRouter.router.push(AppRouter.selectTarget));
    await settle(tester);
    await tester.enterText(find.byKey(const Key('planTarget.search')), 'M31');
    await settle(tester);
    await tester.tap(m31);
    await settle(tester);
    await tester.tap(find.byKey(const Key('planTarget.apply')));
    await settle(tester);
    expect(vm.plan.selectedTarget!.catalogId, 'M31');
    expect(find.byKey(const Key('planTarget.apply')), findsNothing);
  });

  testWidgets('deleting a rig: a cancelled swipe keeps it; the editor\'s '
      'Delete confirms, deletes and says so', (tester) async {
    await start(tester, AppRouter.libraryRigs);
    final before = await tester.runAsync(
      () => DriftEquipmentRepository(db).getAllEquipment(),
    );
    final last = before!.last;
    final rigRow = row(last.name);

    await tester.drag(rigRow, const Offset(-500, 0));
    await settle(tester);
    expect(find.text('Delete this rig?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('confirm.cancel')));
    await settle(tester);
    expect(rigRow, findsOneWidget, reason: 'the row springs back');

    await tester.tap(rigRow);
    await settle(tester);
    await tester.tap(find.byKey(const Key('rigDetail.delete')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('confirm.action')));
    await settle(tester);
    expect(find.text('Rig deleted'), findsOneWidget);
    expect(row(last.name), findsNothing);
    final after = await tester.runAsync(
      () => DriftEquipmentRepository(db).getAllEquipment(),
    );
    expect(after, hasLength(before.length - 1));
  });

  // F19 A4 (RD-09): the plan's own rig and target from the editor's visible
  // Delete. Cancel or a dismissal keeps the record, the selection and the
  // saved snapshot; a confirmed delete persists and the plan falls back to
  // "Needs a rig" / "Needs a target", its saved snapshot unchanged.
  testWidgets('F19 A4: deleting the plan\'s rig and target: Cancel and a '
      'dismissal keep them; Delete persists and clears the selection', (
    tester,
  ) async {
    await start(tester, AppRouter.libraryRigs);
    final target = await ownPlanTarget(tester);
    final saved = await tester.runAsync(() => vm.analysis.saveSession());
    final rig = vm.plan.selectedEquipment!;
    final rigs = DriftEquipmentRepository(db),
        targets = DriftTargetRepository(db);

    await tester.tap(row(rig.name));
    await settle(tester);
    await tester.tap(find.byKey(const Key('rigDetail.delete')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('confirm.cancel')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('rigDetail.delete')));
    await settle(tester);
    await tester.tapAt(const Offset(4, 4)); // outside the dialog
    await settle(tester);
    expect(find.text('Delete this rig?'), findsNothing);
    expect(
      await tester.runAsync(() => rigs.getEquipmentById(rig.id)),
      isNotNull,
    );
    expect(vm.plan.selectedEquipment?.id, rig.id);

    await tester.tap(find.byKey(const Key('rigDetail.delete')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('confirm.action')));
    await settle(tester);
    expect(await tester.runAsync(() => rigs.getEquipmentById(rig.id)), isNull);
    expect(vm.plan.selectedEquipment, isNull, reason: 'Needs a rig');

    AppRouter.router.go(AppRouter.libraryTargets);
    await settle(tester);
    await tester.enterText(find.byType(TextField).first, target.catalogId);
    await settle(tester);
    await tester.tap(row('Own nebula (Own 1)'));
    await settle(tester);
    await tester.tap(find.byKey(const Key('targetDetail.delete')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('confirm.cancel')));
    await settle(tester);
    expect(vm.plan.selectedTarget?.id, target.id);
    await tester.tap(find.byKey(const Key('targetDetail.delete')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('confirm.action')));
    await settle(tester);
    expect(
      await tester.runAsync(() => targets.getTargetById(target.id)),
      isNull,
    );
    expect(vm.plan.selectedTarget, isNull, reason: 'Needs a target');

    final entry = await tester.runAsync(
      () => DriftSessionRepository(db).get(saved!.id),
    );
    expect(entry!.planSnapshot!.json, saved!.planSnapshot!.json);
    expect(entry.planSnapshot!.rigName, rig.name);
    expect(
      entry.planSnapshot!.targetName,
      target.commonName ?? target.catalogId,
    );
  });

  // F19 A4: the shared delete confirmation, dismissed by system Back or by
  // a tap outside it, deletes nothing: from a rig's and a target's record
  // and from a swipe on the list.
  testWidgets('F19 A4: system Back and a tap outside dismiss a rig\'s and a '
      'target\'s delete confirmation; nothing is deleted', (tester) async {
    await start(tester, AppRouter.libraryRigs);
    final rigs = DriftEquipmentRepository(db),
        targets = DriftTargetRepository(db);
    final allRigs = (await tester.runAsync(rigs.getAllEquipment))!;
    final rig = vm.plan.selectedEquipment!;
    final target = await ownPlanTarget(tester);

    /// Opens the confirmation with [open], dismisses it with [dismiss].
    Future<void> dismissed(
      String question,
      Future<void> Function() open,
      Future<void> Function() dismiss,
    ) async {
      await open();
      await settle(tester);
      expect(find.text(question), findsOneWidget);
      await dismiss();
      await settle(tester);
      expect(find.text(question), findsNothing, reason: 'dismissed');
    }

    Future<void> back() async {
      await tester.binding.handlePopRoute();
    }

    Future<void> outside() => tester.tapAt(const Offset(4, 4));

    // A swipe on the plan's rig in the list.
    final rigRow = row(rig.name);
    await dismissed(
      'Delete this rig?',
      () => tester.drag(rigRow, const Offset(-500, 0)),
      back,
    );
    expect(rigRow, findsOneWidget, reason: 'the row springs back');
    await dismissed(
      'Delete this rig?',
      () => tester.drag(rigRow, const Offset(-500, 0)),
      outside,
    );
    expect(rigRow, findsOneWidget);

    // The same rig, from its record.
    await tester.tap(rigRow);
    await settle(tester);
    Future<void> deleteRig() async {
      await tester.ensureVisible(find.byKey(const Key('rigDetail.delete')));
      await tester.tap(find.byKey(const Key('rigDetail.delete')));
    }

    await dismissed('Delete this rig?', deleteRig, back);
    expect(
      find.byKey(const Key('rigDetail.delete')),
      findsOneWidget,
      reason: 'Back closed only the dialog',
    );
    await dismissed('Delete this rig?', deleteRig, outside);
    expect(find.byKey(const Key('rigDetail.delete')), findsOneWidget);
    expect(find.text('Rig deleted'), findsNothing);
    expect(
      (await tester.runAsync(rigs.getAllEquipment))!.map((r) => r.id),
      allRigs.map((r) => r.id),
    );
    expect(vm.plan.selectedEquipment?.id, rig.id);
    await back(); // closes the record
    await settle(tester);

    // The plan's target, from its record.
    AppRouter.router.go(AppRouter.libraryTargets);
    await settle(tester);
    await tester.enterText(find.byType(TextField).first, target.catalogId);
    await settle(tester);
    await tester.tap(row('Own nebula (Own 1)'));
    await settle(tester);
    Future<void> deleteTarget() =>
        tester.tap(find.byKey(const Key('targetDetail.delete')));
    await dismissed('Delete this target?', deleteTarget, back);
    expect(find.byKey(const Key('targetDetail.delete')), findsOneWidget);
    await dismissed('Delete this target?', deleteTarget, outside);
    expect(find.byKey(const Key('targetDetail.delete')), findsOneWidget);
    expect(find.text('Target deleted'), findsNothing);
    expect(
      await tester.runAsync(() => targets.getTargetById(target.id)),
      isNotNull,
    );
    expect(vm.plan.selectedTarget?.id, target.id);
  });

  // S9.8 (D9-5): a save says so.
  testWidgets('saving a rig, a target and a site says so', (tester) async {
    await start(tester, AppRouter.libraryRigs);
    await ownPlanTarget(tester);
    await tester.tap(row(vm.plan.selectedEquipment!.name));
    await settle(tester);
    await tester.tap(find.byKey(const Key('rigDetail.edit')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('rigEditor.save')));
    await settle(tester);
    expect(find.text('Rig saved'), findsOneWidget);

    AppRouter.router.go(AppRouter.libraryTargets);
    await settle(tester);
    await tester.enterText(find.byType(TextField).first, 'Own');
    await settle(tester);
    await tester.tap(row('Own nebula (Own 1)'));
    await settle(tester);
    await tester.tap(find.byKey(const Key('targetDetail.edit')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('targetEditor.save')));
    await settle(tester);
    expect(find.text('Target saved'), findsOneWidget);

    AppRouter.router.go(AppRouter.librarySites);
    await settle(tester);
    await tester.tap(find.text('Dark site'));
    await settle(tester);
    await tester.tap(find.byKey(const Key('siteDetail.edit')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('siteEditor.save')));
    await settle(tester);
    expect(find.text('Site saved'), findsOneWidget);
  });

  // TD-089: the target and site deletes' cancelled swipes and messages.
  testWidgets('deleting a target: a cancelled swipe keeps it; the editor\'s '
      'Delete confirms, deletes and says so', (tester) async {
    await start(tester, AppRouter.libraryTargets);
    await ownPlanTarget(tester);
    await tester.enterText(find.byType(TextField).first, 'Own');
    await settle(tester);
    final targetRow = row('Own nebula (Own 1)');
    await tester.drag(targetRow, const Offset(-500, 0));
    await settle(tester);
    expect(find.text('Delete this target?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('confirm.cancel')));
    await settle(tester);
    expect(targetRow, findsOneWidget, reason: 'the row springs back');

    await tester.tap(targetRow);
    await settle(tester);
    await tester.tap(find.byKey(const Key('targetDetail.delete')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('confirm.action')));
    await settle(tester);
    expect(find.text('Target deleted'), findsOneWidget);
    expect(targetRow, findsNothing);
  });

  testWidgets('a cancelled swipe on a site keeps it', (tester) async {
    await start(tester, AppRouter.librarySites);
    await tester.drag(find.text('Dark site'), const Offset(-500, 0));
    await settle(tester);
    expect(find.text('Delete this site?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('confirm.cancel')));
    await settle(tester);
    expect(find.text('Dark site'), findsOneWidget);
    expect(vm.site.sites, hasLength(2));
  });

  // TD-090 (S9V-02; D9-1): the Library manages sites; choosing the position
  // used for planning happens only where a site is chosen.
  testWidgets('the Library\'s Sites offer no position actions, and a site '
      'added there does not become the active one', (tester) async {
    await start(tester, AppRouter.librarySites);
    expect(find.text('Use current position'), findsNothing);
    expect(find.text('Pick on map'), findsNothing);
    await tester.tap(find.text('Add site'));
    await settle(tester);
    await tester.enterText(fieldLabeled('Name'), 'Hill');
    await tester.enterText(
      find.byKey(const Key('siteEditor.latitude')),
      '46.2',
    );
    await tester.enterText(
      find.byKey(const Key('siteEditor.longitude')),
      '14.7',
    );
    await tester.tap(find.byKey(const Key('siteEditor.save')));
    await settle(tester);
    expect(vm.site.sites.map((s) => s.name), contains('Hill'));
    final hill = vm.site.sites.singleWhere((s) => s.name == 'Hill');
    expect(hill.latitude, 46.2);
    expect(hill.longitude, 14.7);
    expect(vm.site.activeSite!.id, homeId, reason: 'the planning site stays');

    AppRouter.router.go(AppRouter.selectSite);
    await settle(tester);
    expect(find.text('Use current position'), findsOneWidget);
  });

  testWidgets(
    'saving a temporary position from Library does not select the saved record',
    (tester) async {
      await start(tester, AppRouter.librarySites);
      await tester.runAsync(() => vm.site.setLocation(44.5, 13.5));
      await settle(tester);
      await tester.tap(find.byKey(const Key('sites.saveTransient')));
      await settle(tester);
      await tester.enterText(fieldLabeled('Name'), 'Library temporary site');
      await tester.tap(find.byKey(const Key('siteEditor.save')));
      await settle(tester);
      expect(vm.site.activeSite, isNull);
      expect(vm.site.latitude, 44.5);
      expect(vm.site.longitude, 13.5);
      expect(
        vm.site.sites.map((s) => s.name),
        contains('Library temporary site'),
      );
    },
  );

  testWidgets('deleting a site confirms through the shared dialog', (
    tester,
  ) async {
    await start(tester, AppRouter.librarySites);
    await tester.tap(find.text('Dark site'));
    await settle(tester);
    await tester.ensureVisible(find.byKey(const Key('siteDetail.delete')));
    await tester.tap(find.byKey(const Key('siteDetail.delete')));
    await settle(tester);
    expect(find.text('Delete this site?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('confirm.action')));
    await settle(tester);
    expect(find.text('Site deleted'), findsOneWidget);
    expect(vm.site.sites.map((s) => s.name), ['Home']);
  });
}
