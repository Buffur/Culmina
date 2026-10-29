// F18 A1/A5/A6 (S16.3; AM-01, AM-03): the planner leads with the plan
// night's answer and context; no target's-night chart; the target once;
// Save plan always there, disabled with the reason and the direct action
// while a prerequisite is missing; and on a plan night other than tonight
// no planner text says "tonight", while every fit value stays the same.

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/services/catalog_seeder.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:astroplan/presentation/shared/app_words.dart';
import 'package:astroplan/presentation/shared/plan_night_phrase.dart';
import 'package:astroplan/presentation/widgets/plan_status.dart';
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

class _NoWeather with NoSnapshotWeather implements WeatherRepository {}

void main() {
  late AppDatabase db;
  late PlannerHarness vm;

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 12; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> start(
    WidgetTester tester, {
    bool target = true,
    bool rig = true,
  }) async {
    tester.view.physicalSize = const Size(800, 6000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      db = AppDatabase(NativeDatabase.memory());
      await CatalogSeeder(DriftTargetRepository(db)).seedIfNeeded();
      await EquipmentSeeder(DriftEquipmentRepository(db)).seedIfNeeded();
      final id = await DriftLocationRepository(db).insertLocation(
        domain.LocationProfile(
          id: 0,
          name: 'Ljubljana',
          latitude: 46.05,
          longitude: 14.51,
          timeZoneId: 'Europe/Ljubljana',
        ),
      );
      SharedPreferences.setMockInitialValues({'activeLocationId': id});
      final clock = FixedClock(DateTime.utc(2026, 12, 15, 15));
      vm = PlannerHarness(
        DriftTargetRepository(db),
        DriftEquipmentRepository(db),
        _NoWeather(),
        DriftLocationRepository(db),
        locationService: FakeLocationService(),
        reverseGeocoder: FakeReverseGeocoder(),
        deviceTimeZone: FakeDeviceTimeZone(),
        clock: clock,
        sessionRepository: DriftSessionRepository(db, clock: clock),
      );
      await vm.ready;
      if (rig) {
        await vm.setEquipment(
          (await DriftEquipmentRepository(db).getAllEquipment()).first,
        );
      }
      if (target) {
        final m42 = (await DriftTargetRepository(db).searchTargets('M42'))
            .first;
        await vm.setTarget(m42);
      }
      // Far more than any night: what does not fit is said per block.
      await vm.plan.addCaptureBlock(
        CaptureBlock(
          frameType: FrameType.light,
          filterName: 'Ha',
          exposureTimeSeconds: 300,
          frameCount: 400,
        ),
      );
      await vm.plan.idle;
    });
    addTearDown(() => tester.runAsync(db.close));
    AppRouter.router.go(AppRouter.session());
    await tester.pumpWidget(
      MultiProvider(providers: vm.providers, child: const AstroPlanApp()),
    );
    await settle(tester);
  }

  List<String> texts(WidgetTester tester) => [
    for (final t in tester.widgetList<Text>(find.byType(Text)))
      t.data ?? t.textSpan?.toPlainText() ?? '',
  ];

  testWidgets('A6: another plan night says its date, never "tonight"; the '
      'fit values are the same words apart', (tester) async {
    await start(tester);
    final tonightFit = vm.fitAnalysis;
    expect(
      texts(tester).where((t) => t.toLowerCase().contains('tonight')),
      isNotEmpty,
      reason: 'the current night keeps its wording',
    );
    final other = vm.plan.tonightKey.addDays(2);
    await tester.runAsync(() => vm.plan.setEveningDate(other));
    await settle(tester);
    final fit = vm.fitAnalysis;
    final all = texts(tester);
    expect(
      all.where((t) => t.toLowerCase().contains('tonight')),
      isEmpty,
      reason: all.where((t) => t.toLowerCase().contains('tonight')).join(' | '),
    );
    expect(
      all,
      contains(PlanNightPhrase.apply(fit.reason, other, vm.plan.tonightKey)),
    );
    expect(fit.unplacedFramesByBlock, isNotEmpty, reason: 'still too long');
    // The night moved, so the window may differ; only the words are mapped.
    expect(tonightFit.state, isNotNull);
  });

  testWidgets('A1: no target\'s-night section; the target appears once', (
    tester,
  ) async {
    await start(tester);
    expect(find.text('Tonight for this target'), findsNothing);
    expect(find.byKey(const Key('chart.altitude')), findsNothing);
    expect(find.textContaining('Great Orion Nebula'), findsOneWidget);
  });

  testWidgets('A5: Save plan stays, disabled with the reason and the '
      'direct action while the target is missing; enabled once chosen', (
    tester,
  ) async {
    await start(tester, target: false);
    final save = find.byKey(const Key('planner.save'));
    expect(save, findsOneWidget);
    expect(tester.widget<ButtonStyleButton>(save).onPressed, isNull);
    expect(
      tester.widget<Text>(find.byKey(const Key('planner.saveReason'))).data,
      'To save: ${PlanStatus.targetReason}',
    );
    expect(find.byKey(const Key('planner.saveFix')), findsNothing);
    await tester.tap(find.byKey(const Key('status.choose')));
    await settle(tester);
    expect(find.text('Choose a target'), findsWidgets);
    await tester.runAsync(() async {
      final m42 = (await DriftTargetRepository(db).searchTargets('M42')).first;
      await vm.setTarget(m42);
    });
    AppRouter.router.go(AppRouter.session());
    await settle(tester);
    expect(tester.widget<ButtonStyleButton>(save).onPressed, isNotNull);
    expect(find.byKey(const Key('planner.saveReason')), findsNothing);
    await tester.tap(save);
    await settle(tester);
    expect(find.text('Plan saved'), findsOneWidget);
    expect(save, findsOneWidget, reason: 'it never disappears');
  });

  testWidgets('A5: Save plan stays, disabled with the reason and the '
      'direct action while the rig is missing; enabled once chosen', (
    tester,
  ) async {
    await start(tester, rig: false);
    expect(vm.plan.selectedTarget, isNotNull, reason: 'only the rig missing');
    final save = find.byKey(const Key('planner.save'));
    expect(save, findsOneWidget);
    expect(tester.widget<ButtonStyleButton>(save).onPressed, isNull);
    expect(
      tester.widget<Text>(find.byKey(const Key('planner.saveReason'))).data,
      'To save: ${PlanStatus.rigReason}',
    );
    final fix = find.byKey(const Key('planner.saveFix'));
    expect(
      find.descendant(of: fix, matching: find.text(AppWords.chooseRig)),
      findsOneWidget,
    );
    await tester.tap(fix);
    await settle(tester);
    // The plan's scoped rig chooser (plan.js rig): choose, then Apply.
    final rig = (await tester.runAsync(
      () => DriftEquipmentRepository(db).getAllEquipment(),
    ))!.first;
    await tester.tap(find.byKey(Key('planRig.choice.${rig.id}')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('planRig.apply')));
    await settle(tester);
    expect(vm.plan.selectedEquipment?.id, rig.id);
    AppRouter.router.go(AppRouter.session());
    await settle(tester);
    expect(tester.widget<ButtonStyleButton>(save).onPressed, isNotNull);
    expect(find.byKey(const Key('planner.saveReason')), findsNothing);
    expect(find.byKey(const Key('planner.saveFix')), findsNothing);
    await tester.tap(save);
    await settle(tester);
    expect(find.text('Plan saved'), findsOneWidget);
  });
}
