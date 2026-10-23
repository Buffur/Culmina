// F07 (ADR-021 C7–C12) in the capture plan, on a real database: storage
// says what it rests on — a measured file, the rig's unassociated size, a
// theoretical payload with its assumption — or why it is Unknown, with
// "Choose one file" and "Enter a size". Choosing a file asks first, then
// records the file with the rig; Cancel writes nothing. An unread RAW counts
// by its length with the mode-unread wording. Decimal MB/GB throughout.

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/capture_evidence.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/presentation/widgets/capture_plan_widget.dart';
import 'package:astroplan/presentation/widgets/planner_sections.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_capture_file_access.dart';
import '../../support/fake_location_service.dart';
import '../../support/no_snapshot_weather.dart';
import '../../support/planner_harness.dart';
import '../../support/tiff_fixture.dart';

class _NoForecast with NoSnapshotWeather implements WeatherRepository {}

const _m42 = AstroTarget(
  id: 1,
  catalogId: 'M42',
  rightAscension: 83.82,
  declination: -5.39,
  type: 'Nebula',
);

EquipmentProfile _rig({
  int w = 4000,
  int h = 3000,
  double? rawMB,
  CaptureFormat? format,
  String? formatSource,
}) => EquipmentProfile(
  id: 1,
  name: 'Camera rig',
  sensorWidthMm: 23.5,
  sensorHeightMm: 15.6,
  pixelPitchUm: 3.76,
  resolutionWidthPx: w,
  resolutionHeightPx: h,
  focalLengthMm: 400,
  focalRatio: 5,
  averageRawFileSizeMB: rawMB,
  captureFormat: format,
  captureFormatSource: formatSource,
);

void main() {
  late AppDatabase db;
  late PlannerHarness vm;
  late FakeCaptureFileAccess files;

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> start(WidgetTester tester, EquipmentProfile rig) async {
    tester.view.physicalSize = const Size(412, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    files = FakeCaptureFileAccess();
    await tester.runAsync(() async {
      db = AppDatabase(NativeDatabase.memory());
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
      SharedPreferences.setMockInitialValues({'activeLocationId': siteId});
      final clock = FixedClock(DateTime.utc(2026, 11, 10, 16));
      vm = PlannerHarness(
        DriftTargetRepository(db),
        DriftEquipmentRepository(db),
        _NoForecast(),
        DriftLocationRepository(db),
        locationService: FakeLocationService(),
        clock: clock,
        sessionRepository: DriftSessionRepository(db, clock: clock),
        captureFiles: files,
      );
      await vm.ready;
      final targets = DriftTargetRepository(db);
      await vm.plan.setTarget(
        (await targets.getTargetById(await targets.insertTarget(_m42)))!,
      );
      final rigs = DriftEquipmentRepository(db);
      await vm.plan.setEquipment(
        (await rigs.getEquipmentById(await rigs.insertEquipment(rig)))!,
      );
      await vm.plan.addCaptureBlock(
        CaptureBlock(
          frameType: FrameType.light,
          filterName: 'L',
          exposureTimeSeconds: 120,
          frameCount: 10,
        ),
      );
      await vm.plan.idle;
      // Hybrid: the file-size basis and its actions are inside Budget and
      // assumptions.
      await vm.disclosure.setOpen(PlannerSections.budgetDetails, true);
    });
    addTearDown(() => tester.runAsync(db.close));
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
    await settle(tester);
  }

  // The File size basis fact's value.
  String note(WidgetTester tester) => tester
      .widgetList<Text>(
        find.descendant(
          of: find.byKey(const Key('capturePlan.storageNote')),
          matching: find.byType(Text),
        ),
      )
      .last
      .data!;

  // The Storage estimate's value (label, value, note).
  String total(WidgetTester tester) => tester
      .widgetList<Text>(
        find.descendant(
          of: find.byKey(const Key('capturePlan.storage')),
          matching: find.byType(Text),
        ),
      )
      .elementAt(1)
      .data!;

  Future<EquipmentProfile> storedRig(WidgetTester tester) async =>
      (await tester.runAsync(
        () async =>
            (await DriftEquipmentRepository(db).getAllEquipment()).single,
      ))!;

  testWidgets('a declared 16-bit FITS gives the theoretical size with its '
      'assumption', (tester) async {
    await start(
      tester,
      _rig(
        w: 6248,
        h: 4176,
        format: CaptureFormat.fits16,
        formatSource: 'declared',
      ),
    );
    expect(total(tester), '521.88 MB');
    expect(
      note(tester),
      'Theoretical FITS: 6248 × 4176 px × 16 bits in 2,880-byte records with '
      'one header record = 52.19 MB a frame.',
    );
    expect(find.byKey(const Key('capturePlan.chooseFile')), findsNothing);
  });

  testWidgets('a declared uncompressed DNG says it is pixel data only', (
    tester,
  ) async {
    await start(
      tester,
      _rig(format: CaptureFormat.dngUncompressed16, formatSource: 'declared'),
    );
    expect(note(tester), contains('= 24.00 MB of pixel data a frame'));
    expect(note(tester), contains('the file adds a small header'));
  });

  testWidgets('Unknown offers a file or a size; choosing a DNG asks, then '
      'records the file with the rig', (tester) async {
    await start(tester, _rig());
    expect(total(tester), 'Unknown');
    expect(note(tester), contains('no file measured'));
    expect(find.text('Choose one file'), findsOneWidget);
    expect(find.text('Enter a size'), findsOneWidget);

    final dng = (TiffFixture()..ifd0.addAll(phoneStyleDngIfd0())).build().bytes;
    files.file('IMG_0845.dng', dng, length: 24012345);
    await tester.tap(find.byKey(const Key('capturePlan.chooseFile')));
    await settle(tester);
    expect(
      find.textContaining('IMG_0845.dng: 24.01 MB a frame.'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Read: 4000 × 3000 px, 16-bit, uncompressed.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Cancel'));
    await settle(tester);
    expect((await storedRig(tester)).averageRawFileSizeMB, isNull);
    expect(total(tester), 'Unknown', reason: 'Cancel writes nothing');

    files.file('IMG_0845.dng', dng, length: 24012345);
    await tester.tap(find.byKey(const Key('capturePlan.chooseFile')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('storageFile.use')));
    await settle(tester);
    final rig = await storedRig(tester);
    expect(rig.averageRawFileSizeMB, 24.01);
    expect(rig.rawFileSizeEvidence!.label, 'IMG_0845.dng');
    expect(rig.rawFileSizeEvidence!.compression, FileCompression.none);
    expect(note(tester), 'Measured from IMG_0845.dng: 24.01 MB a frame.');
    expect(total(tester), '240.12 MB');
    expect(find.byKey(const Key('capturePlan.chooseFile')), findsNothing);
  });

  testWidgets('a file of another pixel count is recorded but not used, and '
      'the plan says why', (tester) async {
    await start(tester, _rig(w: 6000, h: 4000));
    final dng = (TiffFixture()..ifd0.addAll(phoneStyleDngIfd0())).build().bytes;
    files.file('IMG_0845.dng', dng, length: 24012345);
    await tester.tap(find.byKey(const Key('capturePlan.chooseFile')));
    await settle(tester);
    expect(
      find.textContaining(
        "does not fit this plan's light blocks (another "
        'pixel count)',
      ),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('storageFile.use')));
    await settle(tester);
    // The file's DNG is uncompressed 16-bit: a theoretical value for the
    // rig's own 6000 × 4000, and the file named as not used.
    expect(note(tester), contains('Theoretical: 6000 × 4000 px × 16 bits'));
    expect(
      note(tester),
      contains("Not used: the rig's file (another pixel count)."),
    );
  });

  testWidgets('an unread CR3 counts by its length, with the mode-unread '
      'wording', (tester) async {
    await start(tester, _rig());
    files.file('IMG_0001.CR3', [
      0, 0, 0, 24, //
      ...'ftypcrx '.codeUnits,
      0, 0, 0, 0, ...List.filled(64, 0),
    ], length: 31457280);
    await tester.tap(find.byKey(const Key('capturePlan.chooseFile')));
    await settle(tester);
    expect(
      find.textContaining(
        'Its mode is not read; compressed sizes vary with '
        'content.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('storageFile.use')));
    await settle(tester);
    expect(
      note(tester),
      'From the size of IMG_0001.CR3: 31.46 MB a frame (mode not read; '
      'compressed sizes vary with content).',
    );
    expect((await storedRig(tester)).rawFileSizeEvidence!.read, isFalse);
  });

  testWidgets('a file that is not a capture file is refused, nothing '
      'written', (tester) async {
    await start(tester, _rig());
    files.file('notes.txt', 'hello'.codeUnits, length: 5);
    await tester.tap(find.byKey(const Key('capturePlan.chooseFile')));
    await settle(tester);
    expect(find.textContaining("can't give a frame size"), findsOneWidget);
    expect((await storedRig(tester)).averageRawFileSizeMB, isNull);
  });

  testWidgets('Enter a size opens the rig in its editor', (tester) async {
    await start(tester, _rig());
    await tester.tap(find.byKey(const Key('capturePlan.setFileSize')));
    await settle(tester);
    expect(find.text('Edit rig'), findsOneWidget);
  });
}
