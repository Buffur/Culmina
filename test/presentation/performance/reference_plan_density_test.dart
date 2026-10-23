// The roadmap's density record (FINAL_COMPLETION_ROADMAP U, before F05 and
// after each Capture Plan UI task): the reference plan's scroll extent in
// the planner at 412 px wide and 100 % text, with each section's offset, in
// the light theme with the SDK's Roboto. A record for the owner's review,
// not a maximum: the test prints the numbers (`DENSITY {...}`) and checks
// only that every section was measured.

import 'dart:convert';

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:drift/native.dart';
import 'package:astroplan/presentation/shared/hybrid_parts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_location_service.dart';
import '../../support/in_memory_first_run.dart';
import '../../support/no_snapshot_weather.dart';
import '../../support/planner_harness.dart';
import '../../support/sdk_fonts.dart';

final _december = FixedClock(DateTime.utc(2026, 12, 15, 17));

class _NoForecast with NoSnapshotWeather implements WeatherRepository {}

const _m42 = AstroTarget(
  id: 1,
  catalogId: 'M42',
  commonName: 'Orion Nebula',
  type: 'Nebula',
  rightAscension: 83.82,
  declination: -5.39,
);

const _rig = EquipmentProfile(
  id: 1,
  name: 'Refractor 400',
  focalRatio: 5.0,
  focalLengthMm: 400.0,
  sensorWidthMm: 23.5,
  sensorHeightMm: 15.6,
  resolutionWidthPx: 6000,
  resolutionHeightPx: 4000,
  pixelPitchUm: 3.76,
  averageRawFileSizeMB: 50.0,
);

/// Three lights with a filter change, then darks, flats and bias.
final _reference = [
  CaptureBlock(
    frameType: FrameType.light,
    filterName: 'L',
    exposureTimeSeconds: 120,
    frameCount: 40,
  ),
  CaptureBlock(
    frameType: FrameType.light,
    filterName: 'L',
    exposureTimeSeconds: 60,
    frameCount: 30,
  ),
  CaptureBlock(
    frameType: FrameType.light,
    filterName: 'Ha',
    exposureTimeSeconds: 300,
    frameCount: 20,
  ),
  CaptureBlock(
    frameType: FrameType.dark,
    exposureTimeSeconds: 120,
    frameCount: 20,
  ),
  CaptureBlock(
    frameType: FrameType.flat,
    filterName: 'L',
    exposureTimeSeconds: 2,
    frameCount: 20,
  ),
  CaptureBlock(
    frameType: FrameType.bias,
    exposureTimeSeconds: 0.001,
    frameCount: 50,
  ),
];

Future<void> _loadRoboto() async {
  final loader = FontLoader('Roboto');
  for (final f in ['roboto-regular.ttf', 'roboto-medium.ttf']) {
    final file = sdkMaterialFont(f);
    expect(file, isNotNull, reason: '$f not in the SDK');
    loader.addFont(file!.readAsBytes().then((b) => ByteData.sublistView(b)));
  }
  await loader.load();
}

void main() {
  testWidgets('the reference plan at 412 px, 100 % text', (tester) async {
    late AppDatabase database;
    late PlannerHarness vm;
    SharedPreferences.setMockInitialValues({});
    await tester.runAsync(() async {
      await _loadRoboto();
      database = AppDatabase(NativeDatabase.memory());
      final targets = DriftTargetRepository(database);
      final rigs = DriftEquipmentRepository(database);
      await targets.insertTarget(_m42);
      await rigs.insertEquipment(_rig);
      vm = PlannerHarness(
        targets,
        rigs,
        _NoForecast(),
        DriftLocationRepository(database),
        locationService: FakeLocationService(),
        sessionRepository: DriftSessionRepository(database, clock: _december),
        clock: _december,
        firstRun: InMemoryFirstRun(done: true),
      );
      await vm.ready;
      await vm.choosePlan();
      await vm.site.setLocation(46.05, 14.5);
      while (vm.plan.captureBlocks.isNotEmpty) {
        await vm.plan.removeCaptureBlock(0);
      }
      for (final b in _reference) {
        await vm.plan.addCaptureBlock(b);
      }
      await vm.plan.idle;
      await vm.conditions.idle;
    });
    addTearDown(() => tester.runAsync(database.close));
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    AppRouter.router.go(AppRouter.session());
    await tester.pumpWidget(
      MultiProvider(providers: vm.providers, child: const AstroPlanApp()),
    );
    for (var i = 0; i < 8; i++) {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump(const Duration(milliseconds: 200));
    }

    final list = find.byType(ListView).first;
    final scrollable = find
        .descendant(of: list, matching: find.byType(Scrollable))
        .first;
    ScrollPosition position() =>
        tester.state<ScrollableState>(scrollable).position;
    final listTop = tester.getTopLeft(list).dy;

    // Walk the list so every section is built once; record its offset.
    final sections = <String, double>{};
    // The Hybrid section titles (plan.js h2: HybridSectionTitle, and the
    // serif "The night ahead").
    final headers = find.byWidgetPredicate(
      (w) =>
          w is HybridSectionTitle || (w is Text && w.data == 'The night ahead'),
    );
    var last = -1.0;
    while (position().pixels != last) {
      last = position().pixels;
      for (final e in headers.evaluate()) {
        final title = e.widget is Text
            ? (e.widget as Text).data!
            : tester
                  .widgetList<Text>(
                    find.descendant(
                      of: find.byWidget(e.widget),
                      matching: find.byType(Text),
                    ),
                  )
                  .first
                  .data!;
        final box = e.renderObject! as RenderBox;
        sections.putIfAbsent(
          title,
          () => box.localToGlobal(Offset.zero).dy - listTop + position().pixels,
        );
      }
      position().jumpTo(
        (position().pixels + 300).clamp(0, position().maxScrollExtent),
      );
      await tester.pump();
    }
    final extent = position().maxScrollExtent + position().viewportDimension;
    final record = {
      'width': 412,
      'textScale': 1.0,
      'theme': 'light',
      'scrollExtent': extent.round(),
      'viewport': position().viewportDimension.round(),
      'sections': {
        for (final MapEntry(:key, :value) in sections.entries)
          key: value.round(),
      },
    };
    // ignore: avoid_print
    print('DENSITY ${jsonEncode(record)}');
    expect(sections.keys, containsAll(['Capture plan', 'The night ahead']));
    position().jumpTo(0);
    await tester.pump();
    expect(find.byKey(const Key('planner.target')), findsOneWidget);
    expect(find.byKey(const Key('planner.rig')), findsOneWidget);
    // Hybrid: the target's facts are in its row, the rig's in its row and
    // in Rig details below the estimate (built lazily, so walked above).
    expect(sections.keys, contains('Estimate'));
    expect(extent, greaterThan(position().viewportDimension));
  });
}
