// F06 A2/A4/A7 through the real ViewModels and an in-memory SQLite
// database: a block's white balance, focus mode and field origins survive
// reorder, delete-Undo, a copy for another night, Save, reopen and the
// Logbook entry and its Share text. An origin's descriptor is fixed: editing
// or deleting its source block changes nothing. Applying a block edit
// changes the working plan with Undo, never the saved plan.

import 'dart:convert';

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' hide CaptureBlock;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/services/catalog_seeder.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/domain/services/execution_machine.dart';
import 'package:astroplan/domain/services/session_reconciliation.dart';
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:astroplan/presentation/shared/entry_share_text.dart';
import 'package:astroplan/presentation/widgets/capture_plan_widget.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_location_service.dart';
import '../../support/no_snapshot_weather.dart';
import '../../support/planner_harness.dart';

class _NoWeather with NoSnapshotWeather implements WeatherRepository {}

final _file = FieldOrigin(OriginKind.file, 'IMG_0845.dng');

final _recorded = CaptureBlock(
  frameType: FrameType.light,
  filterName: 'Ha',
  exposureTimeSeconds: 1 / 14,
  frameCount: 200,
  whiteBalance: WhiteBalance.preset(WhiteBalancePreset.cloudy, tint: 2),
  focusMode: FocusMode.mf,
  origins: FieldOrigins({CaptureField.exposure: _file}),
);

final _plain = CaptureBlock(
  frameType: FrameType.light,
  filterName: 'OIII',
  exposureTimeSeconds: 300,
  frameCount: 20,
);

/// What F06 must keep of a block.
Object _values(CaptureBlock b) => (
  b.filterName,
  b.exposureTimeSeconds,
  b.whiteBalance,
  b.focusMode,
  b.origins,
);

void main() {
  late AppDatabase database;
  late DriftSessionRepository sessions;
  late DriftLocationRepository locations;
  late DriftTargetRepository targets;
  final clock = FixedClock(DateTime.utc(2026, 3, 1, 18));

  Future<PlannerHarness> harness() async {
    final vm = PlannerHarness(
      targets,
      DriftEquipmentRepository(database),
      _NoWeather(),
      locations,
      locationService: FakeLocationService(),
      clock: clock,
      sessionRepository: sessions,
    );
    await vm.ready;
    return vm;
  }

  Future<PlannerHarness> start() async {
    database = AppDatabase(NativeDatabase.memory());
    sessions = DriftSessionRepository(database, clock: clock);
    targets = DriftTargetRepository(database);
    await CatalogSeeder(targets).seedIfNeeded();
    await EquipmentSeeder(DriftEquipmentRepository(database)).seedIfNeeded();
    locations = DriftLocationRepository(database);
    final id = await locations.insertLocation(
      domain.LocationProfile(
        id: 0,
        name: 'London',
        latitude: 51.5,
        longitude: -0.1,
        elevation: 10,
      ),
    );
    SharedPreferences.setMockInitialValues({'activeLocationId': id});
    final vm = await harness();
    await vm.choosePlan();
    while (vm.captureBlocks.isNotEmpty) {
      await vm.removeCaptureBlock(0);
    }
    await vm.addCaptureBlock(_plain);
    await vm.addCaptureBlock(_recorded);
    await vm.plan.idle;
    return vm;
  }

  tearDown(() => database.close());

  test('reorder, delete-Undo, Save and reopen keep every value', () async {
    final vm = await start();
    await vm.reorderCaptureBlocks(1, 0);
    expect(_values(vm.captureBlocks.first), _values(_recorded));

    final block = vm.captureBlocks.first;
    final deletion = await vm.plan.recordBlocksEdit(
      () => vm.plan.removeCaptureBlock(0),
    );
    await vm.plan.restoreCaptureBlock(0, block, deletion: deletion);
    expect(_values(vm.captureBlocks.first), _values(_recorded));

    final saved = await vm.saveSession();
    await vm.plan.idle;
    final stored = (await sessions.get(saved.id))!;
    expect(_values(stored.blocks.first), _values(_recorded));
    final snapshotBlock = (stored.planSnapshot!.json['blocks'] as List).first;
    expect(snapshotBlock['focusMode'], 'mf');
    expect(snapshotBlock['wb'], _recorded.whiteBalance!.toJson());

    final reopened = await harness();
    expect(_values(reopened.captureBlocks.first), _values(_recorded));
    expect(_values(reopened.captureBlocks.last), _values(_plain));
  });

  test('a copy for another night keeps them', () async {
    final vm = await start();
    await vm.saveSession();
    await vm.lifecycle.duplicateForNight(CalendarDate(2026, 3, 5));
    await vm.plan.idle;
    expect(vm.captureBlocks.map(_values), [
      _values(_plain),
      _values(_recorded),
    ]);
    expect(vm.plan.activeSession!.plannedAtUtc, isNull, reason: 'a new copy');
  });

  test('an origin descriptor survives an edit or deletion of its source', () {
    // The descriptor is text fixed when the value was accepted (C4): there
    // is no link to the source block to follow.
    final source = CaptureBlock(
      frameType: FrameType.light,
      filterName: 'Ha',
      exposureTimeSeconds: 300,
      frameCount: 20,
    );
    final inherited = FieldOrigin(OriginKind.inherited, 'from Ha · 300 s × 20');
    final dark = CaptureBlock(
      frameType: FrameType.dark,
      exposureTimeSeconds: 300,
      frameCount: 20,
      origins: FieldOrigins({CaptureField.exposure: inherited}),
    );
    final plan = [source, dark];
    final edited = [source.copyWith(exposureTimeSeconds: 120), dark];
    final deleted = [dark];
    for (final blocks in [plan, edited, deleted]) {
      expect(blocks.last.origins[CaptureField.exposure], inherited);
      expect(blocks.last.exposureTimeSeconds, 300, reason: 'value kept');
    }
  });

  test("the Logbook entry's Share text names them", () async {
    final vm = await start();
    final saved = await vm.saveSession();
    final entry = (await sessions.get(saved.id))!;
    final text = EntryShareText.of(
      entry,
      reconciliation: SessionReconciliation.of(
        entry.blocks,
        ExecutionMachine.fold({for (final b in entry.blocks) b.id}, const []),
      ),
    );
    expect(
      text,
      contains('Ha · 1/14 s · WB Cloudy, tint +2 · MF: 200 planned'),
    );
    expect(text, contains('OIII · 300 s: 20 planned'), reason: 'none: none');
  });

  testWidgets('Apply changes edits the working plan with Undo; the saved '
      'plan and its snapshot are untouched', (tester) async {
    late PlannerHarness vm;
    await tester.runAsync(() async {
      vm = await start();
      await vm.saveSession();
      await vm.plan.idle;
    });
    final id = vm.plan.activeSessionId!;
    final before = (await tester.runAsync(() => sessions.get(id)))!;
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MultiProvider(
        providers: vm.providers,
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: CapturePlanWidget()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('OIII · 300 s × 20 ·'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('blockDialog.count')), '30');
    await tester.tap(find.byKey(const Key('blockDialog.submit')));
    for (var i = 0; i < 4; i++) {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.textContaining('Changed in this plan: OIII'), findsOneWidget);
    expect(vm.captureBlocks.first.frameCount, 30);
    expect(vm.plan.hasUnsavedChanges, isTrue);
    final after = (await tester.runAsync(() => sessions.get(id)))!;
    expect(after.plannedAtUtc, before.plannedAtUtc);
    expect(
      jsonEncode(after.planSnapshot!.json),
      jsonEncode(before.planSnapshot!.json),
    );
    // The untouched block keeps its values through the edit.
    expect(_values(vm.captureBlocks.last), _values(_recorded));
  });

  testWidgets("the Logbook entry's plan rows name them", (tester) async {
    late int id;
    late PlannerHarness vm;
    await tester.runAsync(() async {
      vm = await start();
      id = (await vm.saveSession()).id;
      await vm.plan.idle;
    });
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    AppRouter.router.go(AppRouter.sessionDetail(id));
    await tester.pumpWidget(
      MultiProvider(providers: vm.providers, child: const AstroPlanApp()),
    );
    for (var i = 0; i < 8; i++) {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump(const Duration(milliseconds: 200));
    }
    final rows = find.descendant(
      of: find.byKey(const Key('detail.planVsActual')),
      matching: find.byType(RichText),
    );
    final texts = [
      for (final r in tester.widgetList<RichText>(rows)) r.text.toPlainText(),
    ];
    expect(
      texts,
      contains('Ha · 1/14 s · WB Cloudy, tint +2 · MF: 200 planned'),
    );
    expect(texts, contains('OIII · 300 s: 20 planned'));
  });
}
