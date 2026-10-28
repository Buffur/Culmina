// QA-02 (phone QA 2026-10-23): the line above Save plan says what the plan's
// persistence is. After the first edit of a saved plan it kept saying "Saved
// on this device." while the identity said "Saved · changed": the planner
// was notified before the autosave turned the saved session back into a
// draft, and not after it. On a device the frame is built in between; here
// a frame is pumped before the write lands, as it is there. Real database.
// The service side (also a site change's autosave): current_session_state_test.

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
import 'package:astroplan/presentation/shared/plan_state.dart';
import 'package:astroplan/presentation/shared/status_block.dart';
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

class _NoForecast with NoSnapshotWeather implements WeatherRepository {}

final _extra = CaptureBlock(
  frameType: FrameType.light,
  filterName: 'Ha',
  exposureTimeSeconds: 300,
  frameCount: 7,
);

final _ljubljana = domain.LocationProfile(
  id: 0,
  name: 'Ljubljana',
  latitude: 46.05,
  longitude: 14.51,
  elevation: 300,
  timeZoneId: 'Europe/Ljubljana',
);

void main() {
  late AppDatabase db;
  late PlannerHarness vm;

  Future<void> start(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      db = AppDatabase(NativeDatabase.memory());
      await CatalogSeeder(DriftTargetRepository(db)).seedIfNeeded();
      await EquipmentSeeder(DriftEquipmentRepository(db)).seedIfNeeded();
      final locations = DriftLocationRepository(db);
      final siteId = await locations.insertLocation(_ljubljana);
      SharedPreferences.setMockInitialValues({'activeLocationId': siteId});
      final clock = FixedClock(DateTime.utc(2026, 11, 10, 18));
      vm = PlannerHarness(
        DriftTargetRepository(db),
        DriftEquipmentRepository(db),
        _NoForecast(),
        locations,
        locationService: FakeLocationService(),
        reverseGeocoder: FakeReverseGeocoder(),
        deviceTimeZone: FakeDeviceTimeZone(),
        clock: clock,
        sessionRepository: DriftSessionRepository(db, clock: clock),
      );
      await vm.ready;
      await vm.choosePlan();
    });
    addTearDown(() => tester.runAsync(db.close));
    AppRouter.router.go(AppRouter.session());
    await tester.pumpWidget(
      MultiProvider(providers: vm.providers, child: const AstroPlanApp()),
    );
    await settle(tester);
  }

  Future<void> save(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('planner.save')));
    await settle(tester);
    await tester.runAsync(() => vm.plan.idle);
    await settle(tester);
  }

  final identity = find.byKey(const Key('planner.identity'));
  Finder inIdentity(String text) =>
      find.descendant(of: identity, matching: find.text(text));

  void expectPlanStateAndFit(WidgetTester tester, PlanState state) {
    final stateLabel = find.descendant(
      of: identity,
      matching: find.byType(PlanStateLabel),
    );
    expect(stateLabel, findsOneWidget);
    final label = tester.widget<PlanStateLabel>(stateLabel);
    expect(label.state, state);
    expect(
      label.withIcon,
      isTrue,
      reason: 'persistence has its own visual cue',
    );
    expect(inIdentity(state.word), findsOneWidget);

    final verdict = StatusBlock.headline(vm.fitAnalysis.state);
    final headline = find.byKey(const Key('status.headline'));
    expect(tester.widget<Text>(headline).data, verdict);
    final fitLabel = tester.getSemantics(headline).label;
    expect(
      fitLabel,
      startsWith('Imaging-window fit: $verdict'),
      reason: 'time fit is named independently from plan persistence',
    );
    expect(fitLabel, isNot(contains(state.word)));
  }

  testWidgets('the first edit of a saved plan says its changes are not saved '
      'yet, also when a frame is built before the autosave lands', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await start(tester);
      expectPlanStateAndFit(tester, PlanState.notSaved);
      await save(tester);
      expect(find.text('Saved on this device.'), findsOneWidget);
      expectPlanStateAndFit(tester, PlanState.saved);

      // Started, not awaited: the frame below is built before the write lands.
      late Future<void> edit;
      await tester.runAsync(() async {
        edit = vm.addCaptureBlock(_extra);
      });
      // The device's frame between the edit and its autosave.
      await tester.pump();
      await tester.runAsync(() => edit);
      await settle(tester);

      expect(find.text('Changes are not saved yet.'), findsOneWidget);
      expect(find.text('Saved on this device.'), findsNothing);
      expectPlanStateAndFit(tester, PlanState.savedChanged);

      await save(tester);
      expect(find.text('Saved on this device.'), findsOneWidget);
      expectPlanStateAndFit(tester, PlanState.saved);
    } finally {
      semantics.dispose();
    }
  });
}

/// Pumps fixed frames with real-time gaps (database work; TASK 12.2).
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump(const Duration(milliseconds: 200));
  }
}
