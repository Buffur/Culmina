// F20 A3 (S16.5, UX-S R12): the AstroBin CSV is previewed before it is
// shared — its rows in the file's order with their filter names, and the
// entries that give none with the reason — and Share CSV shares exactly
// that; Cancel shares nothing. The existing manifest export is unchanged.

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/export/share_session_exporter.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/session_result.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/domain/services/astrobin_acquisitions.dart';
import 'package:astroplan/domain/services/session_exporter.dart';
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/fake_location_service.dart';
import '../../../support/fake_reverse_geocoder.dart';
import '../../../support/no_snapshot_weather.dart';
import '../../../support/planner_harness.dart';

class _NoForecast with NoSnapshotWeather implements WeatherRepository {}

class _Clock extends Clock {
  DateTime now = DateTime.utc(2026, 12, 15, 19);
  @override
  DateTime nowUtc() => now;
}

class _RecordingCsv implements AstroBinCsvExporter {
  final shared = <AstroBinExport>[];
  @override
  Future<void> share(AstroBinExport acquisitions) async =>
      shared.add(acquisitions);
}

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
);

void main() {
  late AppDatabase database;
  late DriftSessionRepository sessions;
  late PlannerHarness vm;
  late _RecordingCsv csv;
  late int resultId;
  late int planId;

  /// 15 Dec at Ljubljana: a result (Partly: 9 Ha, 4 OIII × 300 s) and a
  /// saved plan for a later night with no result.
  Future<void> seed(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      SharedPreferences.setMockInitialValues({});
      final clock = _Clock();
      csv = _RecordingCsv();
      database = AppDatabase(NativeDatabase.memory());
      sessions = DriftSessionRepository(database, clock: clock);
      await DriftTargetRepository(database).insertTarget(_m42);
      await DriftEquipmentRepository(database).insertEquipment(_rig);
      vm = PlannerHarness(
        DriftTargetRepository(database),
        DriftEquipmentRepository(database),
        _NoForecast(),
        DriftLocationRepository(database),
        locationService: FakeLocationService(),
        reverseGeocoder: FakeReverseGeocoder(),
        sessionRepository: sessions,
        clock: clock,
        csvExporter: csv,
      );
      await vm.ready;
      await vm.choosePlan();
      await vm.site.setLocation(46.05, 14.5);
      while (vm.plan.captureBlocks.isNotEmpty) {
        await vm.plan.removeCaptureBlock(0);
      }
      for (final f in ['Ha', 'OIII']) {
        await vm.plan.addCaptureBlock(
          CaptureBlock(
            frameType: FrameType.light,
            filterName: f,
            exposureTimeSeconds: 300,
            frameCount: 24,
          ),
        );
      }
      await vm.plan.idle;
      final saved = await vm.analysis.saveSession();
      resultId = saved.id;
      clock.now = DateTime.utc(2026, 12, 16, 7);
      await sessions.recordResult(
        resultId,
        PartlyDone({saved.blocks[0].id: 9, saved.blocks[1].id: 4}),
      );
      await vm.lifecycle.followNight();
      await vm.plan.idle;
      planId = (await vm.analysis.saveSession()).id;
    });
    addTearDown(() => tester.runAsync(database.close));
    AppRouter.router.go(AppRouter.sessions);
    await tester.pumpWidget(
      MultiProvider(providers: vm.providers, child: const AstroPlanApp()),
    );
    await settle(tester);
  }

  Future<void> tap(WidgetTester tester, String key) async {
    await tester.tap(find.byKey(Key(key)));
    await settle(tester);
  }

  testWidgets('the Logbook previews the rows and the entries without one; '
      'Cancel shares nothing, Share CSV shares what was shown', (tester) async {
    await seed(tester);
    await tap(tester, 'logbook.menu');
    await tap(tester, 'logbook.astrobin');
    expect(find.byKey(const Key('astrobin.preview')), findsOneWidget);
    expect(find.text('1. Ha · 2026-12-15 · 9 × 300 s'), findsOneWidget);
    expect(find.text('2. OIII · 2026-12-15 · 4 × 300 s'), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(Key('astrobin.skipped.$planId'))).data,
      endsWith(': no result recorded'),
    );
    await tap(tester, 'astrobin.cancel');
    expect(csv.shared, isEmpty);

    await tap(tester, 'logbook.menu');
    await tap(tester, 'logbook.astrobin');
    await tap(tester, 'astrobin.share');
    expect(csv.shared, hasLength(1));
    final a = csv.shared.single;
    expect(a.filterNames, ['Ha', 'OIII']);
    // A rig of unknown camera class: no ISO or gain recorded, no binning.
    expect(a.csv.split('\n').skip(1), [
      '2026-12-15,,9,300,,,,,5,,,,,,,,',
      '2026-12-15,,4,300,,,,,5,,,,,,,,',
    ]);
    expect(
      ShareAstroBinCsvExporter.shareText(a).split('\n').sublist(1, 3),
      a.rowLines,
      reason: 'the share text lists the previewed rows in order',
    );
    expect(find.text('AstroBin CSV created'), findsOneWidget);
  });

  testWidgets('an entry exports its own rows; one without a result says why '
      'and cannot be shared', (tester) async {
    await seed(tester);
    AppRouter.router.go(AppRouter.sessionDetail(planId));
    await settle(tester);
    // Hybrid: the entry's exports sit in "Export this entry".
    await tester.ensureVisible(find.text('Export this entry'));
    await tester.tap(find.text('Export this entry'));
    await settle(tester);
    await tester.ensureVisible(find.byKey(const Key('detail.astrobin')));
    await tap(tester, 'detail.astrobin');
    expect(find.byKey(const Key('astrobin.empty')), findsOneWidget);
    final share = tester.widget<FilledButton>(
      find.byKey(const Key('astrobin.share')),
    );
    expect(share.onPressed, isNull);
    await tap(tester, 'astrobin.cancel');

    AppRouter.router.go(AppRouter.sessions);
    await settle(tester);
    AppRouter.router.go(AppRouter.sessionDetail(resultId));
    await settle(tester);
    // Hybrid: the entry's exports sit in "Export this entry".
    await tester.ensureVisible(find.text('Export this entry'));
    await tester.tap(find.text('Export this entry'));
    await settle(tester);
    await tester.ensureVisible(find.byKey(const Key('detail.astrobin')));
    await tap(tester, 'detail.astrobin');
    await tap(tester, 'astrobin.share');
    expect(csv.shared.single.rows, hasLength(2));
    expect(csv.shared.single.skipped, isEmpty);
  });
}

/// Pumps fixed frames with real-time gaps (database writes).
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump(const Duration(milliseconds: 200));
  }
}
