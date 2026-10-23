// F16 A2/A3 (S16.1, RA-B01–06): the Welcome page asks for the position only
// on "Use current position" — never while it is merely shown — and once
// per tap; a denial leaves choosing a saved site and entering one by hand.
// Its own photo path opens the metadata import for a new rig that comes
// back to Welcome (`NewRigArgs(returnsNewRig: true)`); leaving it without
// saving creates and chooses nothing. Through the real app and an
// in-memory database.

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/models/camera_class.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/domain/services/location_service.dart';
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:astroplan/presentation/shared/location_failure_text.dart';
import 'package:astroplan/presentation/shared/rig_input_text.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/fake_capture_file_access.dart';
import '../../../support/fake_device_time_zone.dart';
import '../../../support/fake_location_service.dart';
import '../../../support/fake_reverse_geocoder.dart';
import '../../../support/in_memory_first_run.dart';
import '../../../support/jpeg_fixture.dart';
import '../../../support/no_snapshot_weather.dart';
import '../../../support/planner_harness.dart';
import '../../../support/tiff_fixture.dart';
import '../../../support/library_finders.dart';

const welcomeSite = Key('welcome.site');

final _december = FixedClock(DateTime.utc(2026, 12, 15, 17));

class _NoForecast with NoSnapshotWeather implements WeatherRepository {}

/// A phone JPEG: f 6.57 mm, f/1.6, f₃₅ 23 mm, 3072 × 4096 px.
List<int> _phoneJpeg() {
  final exif = phoneStyleJpegExif();
  exif.exif!.addAll([
    FixtureEntry.long(40962, 3072),
    FixtureEntry.long(40963, 4096),
  ]);
  return jpegFile([exifApp1(exif.build().bytes)]);
}

void main() {
  late AppDatabase database;
  late PlannerHarness vm;
  late FakeLocationService location;
  late FakeCaptureFileAccess files;

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  /// A first run: no site, no rig, the Welcome page open.
  Future<void> start(WidgetTester tester) async {
    AppRouter.router.go(AppRouter.welcome);
    SharedPreferences.setMockInitialValues({});
    files = FakeCaptureFileAccess();
    location = FakeLocationService(); // a denied permission
    await tester.runAsync(() async {
      database = AppDatabase(NativeDatabase.memory());
      vm = PlannerHarness(
        DriftTargetRepository(database),
        DriftEquipmentRepository(database),
        _NoForecast(),
        DriftLocationRepository(database),
        locationService: location,
        reverseGeocoder: FakeReverseGeocoder(),
        deviceTimeZone: FakeDeviceTimeZone(),
        sessionRepository: DriftSessionRepository(database, clock: _december),
        clock: _december,
        firstRun: InMemoryFirstRun(),
        captureFiles: files,
      );
      await vm.ready;
    });
    addTearDown(() => tester.runAsync(database.close));
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MultiProvider(providers: vm.providers, child: const AstroPlanApp()),
    );
    await settle(tester);
  }

  Future<void> tapKey(WidgetTester tester, String key) async {
    final f = find.byKey(Key(key));
    await tester.ensureVisible(f);
    await settle(tester);
    await tester.tap(f);
    await settle(tester);
  }

  String currentRoute() =>
      AppRouter.router.routerDelegate.currentConfiguration.uri.toString();

  Future<int> rigRows(WidgetTester tester) async => (await tester.runAsync(
    () async =>
        (await DriftEquipmentRepository(database).getAllEquipment()).length,
  ))!;

  testWidgets('A2: shown, Welcome never asks for the position; a tap asks '
      'once', (tester) async {
    await start(tester);
    expect(find.byKey(const Key('welcome.site')), findsOneWidget);
    expect(location.calls, 0, reason: 'showing the page asks nothing');
    // Rebuilds (a scroll, the rig step) do not ask either.
    await tester.ensureVisible(find.byKey(const Key('welcome.start')));
    await settle(tester);
    expect(location.calls, 0);

    await tapKey(tester, 'welcome.useCurrentPosition');
    expect(location.calls, 1, reason: 'one request per tap');
  });

  testWidgets('A3: after a denial the reason is shown and choosing or '
      'entering a site still works, without asking again', (tester) async {
    await start(tester);
    await tapKey(tester, 'welcome.useCurrentPosition');
    expect(location.calls, 1);
    expect(
      find.text(LocationFailureText.message(LocationFailure.permissionDenied)),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('welcome.site')),
        matching: find.text('Not set'),
      ),
      findsOneWidget,
      reason: 'a denial sets no site',
    );
    final choose = tester.widget<ButtonStyleButton>(
      find.byKey(const Key('welcome.chooseSite')),
    );
    expect(choose.onPressed, isNotNull);

    // Choose or add a site → Add site → typed by hand.
    await tapKey(tester, 'welcome.chooseSite');
    expect(find.text('Manage sites'), findsOneWidget);
    await tester.tap(find.text('Add site'));
    await settle(tester);
    await tester.enterText(find.byKey(const Key('siteEditor.name')), 'Garden');
    await tester.enterText(fieldLabeled('Latitude (°)'), '46.05');
    await tester.enterText(fieldLabeled('Longitude (°)'), '14.51');
    await tapKey(tester, 'siteEditor.save');
    expect(vm.site.activeSite?.name, 'Garden', reason: 'chosen to plan with');
    // Back from the sites list (the editor closed itself on Save).
    for (var i = 0; i < 2 && find.byKey(welcomeSite).evaluate().isEmpty; i++) {
      await tester.pageBack();
      await settle(tester);
    }
    expect(currentRoute(), AppRouter.welcome);
    expect(
      find.descendant(
        of: find.byKey(const Key('welcome.site')),
        matching: find.textContaining('Garden'),
      ),
      findsOneWidget,
    );
    expect(location.calls, 1, reason: 'nothing asked again');
  });

  testWidgets("A3: Welcome's photo path opens the metadata import; leaving "
      'it without saving returns to Welcome with no rig', (tester) async {
    await start(tester);
    await startPhoto(tester);
    expect(find.byKey(const Key('metadata.pick')), findsOneWidget);
    expect(find.text('Add from a photo'), findsOneWidget);
    expect(find.byKey(welcomeSite), findsNothing, reason: 'covered');

    files.file('IMG.jpg', _phoneJpeg());
    await tapKey(tester, 'metadata.pick');
    await tapKey(tester, 'import.new');
    expect(find.byKey(const Key('rigEditor.save')), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await settle(tester);
    expect(
      find.byKey(const Key('metadata.pick')),
      findsOneWidget,
      reason: "the editor's Cancel goes back to the import",
    );
    await tester.pageBack();
    await settle(tester);

    expect(currentRoute(), AppRouter.welcome);
    expect(find.byKey(welcomeSite), findsOneWidget, reason: 'back on Welcome');
    expect(await rigRows(tester), 0);
    expect(vm.plan.selectedEquipment, isNull);
    expect(find.text(RigInputText.savedAndChosen), findsNothing);
    expect(
      find.descendant(
        of: find.byKey(const Key('welcome.rig')),
        matching: find.text('Not chosen'),
      ),
      findsOneWidget,
    );
  });

  testWidgets("A3: Welcome's photo path: a saved new rig comes back to "
      'Welcome and is the plan\'s', (tester) async {
    await start(tester);
    await startPhoto(tester);
    files.file('IMG.jpg', _phoneJpeg());
    await tapKey(tester, 'metadata.pick');
    await tapKey(tester, 'import.new');
    await tapKey(tester, 'rigEditor.save');

    expect(find.byKey(welcomeSite), findsOneWidget, reason: 'back on Welcome');
    expect(find.byKey(const Key('metadata.pick')), findsNothing);
    expect(find.text(RigInputText.savedAndChosen), findsOneWidget);
    expect(vm.plan.selectedEquipment?.cameraClass, CameraClass.phone);
    expect(await rigRows(tester), 1);
  });
}

/// Welcome's own rig step: the Phone class, then From a photo.
Future<void> startPhoto(WidgetTester tester) async {
  final chip = find.byKey(Key('addRig.class.${CameraClass.phone.name}'));
  await tester.ensureVisible(chip);
  await tester.tap(chip);
  await tester.pumpAndSettle();
  final photo = find.byKey(const Key('addRig.fromPhoto'));
  await tester.ensureVisible(photo);
  await tester.pumpAndSettle();
  await tester.tap(photo);
  for (var i = 0; i < 8; i++) {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump(const Duration(milliseconds: 200));
  }
}
