// Widget tests for the sites list and editor (TASK 7.3): the active site is
// marked and switchable; deleting the active site keeps the position; the
// editor validates, pre-fills the device zone, and saves. S7.5 (RG-08 = E2,
// RG-09 = S3/M2, UX-21): elevation optional and unknown when empty; "Use
// current position" fills the form only; Bortle and SQM in a collapsed,
// remembered section with the map link; back with changes asks.

import 'dart:async';
import 'dart:io';

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/services/location_service.dart';
import 'package:astroplan/domain/services/reverse_geocoder.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:astroplan/presentation/screens/location/location_picker_screen.dart';
import 'package:astroplan/presentation/screens/sites/site_editor_screen.dart';
import 'package:astroplan/presentation/screens/sites/sites_screen.dart';
import 'package:astroplan/presentation/shared/geo_controls.dart';

import '../../../support/planner_harness.dart';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/fake_device_time_zone.dart';
import '../../../support/fake_location_service.dart';
import '../../../support/fake_reverse_geocoder.dart';
import '../../../support/in_memory_privacy_preferences.dart';
import '../../../support/no_snapshot_weather.dart';
import '../../../support/library_finders.dart';

class _NoWeather with NoSnapshotWeather implements WeatherRepository {}

class _DelayedPrivacy extends InMemoryPrivacyPreferences {
  final write = Completer<void>();
  @override
  Future<void> savePlaceNameLookup(bool on) async {
    await write.future;
    await super.savePlaceNameLookup(on);
  }
}

void main() {
  late AppDatabase database;
  late DriftLocationRepository locations;
  late PlannerHarness vm;

  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async => Directory.systemTemp.path,
        );
  });
  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          null,
        ),
  );

  late FakeLocationService gps;
  late FakeReverseGeocoder names;

  Future<void> build(
    WidgetTester tester, {
    List<domain.LocationProfile> sites = const [],
    FakeLocationService? locationService,
    FakeReverseGeocoder? geocoder,
    bool placeNames = true,
    InMemoryPrivacyPreferences? privacy,
  }) async {
    gps = locationService ?? FakeLocationService();
    names = geocoder ?? FakeReverseGeocoder();
    await tester.runAsync(() async {
      database = AppDatabase(NativeDatabase.memory());
      locations = DriftLocationRepository(database);
      for (final site in sites) {
        await locations.insertLocation(site);
      }
      vm = PlannerHarness(
        DriftTargetRepository(database),
        DriftEquipmentRepository(database),
        _NoWeather(),
        locations,
        locationService: gps,
        reverseGeocoder: names,
        privacyPreferences:
            privacy ?? InMemoryPrivacyPreferences(placeNameLookup: placeNames),
        deviceTimeZone: FakeDeviceTimeZone('Europe/Ljubljana'),
        clock: FixedClock(DateTime.utc(2026, 9, 23, 12)),
      );
      await vm.ready;
    });
    addTearDown(() => tester.runAsync(database.close));
  }

  Future<void> pump(
    WidgetTester tester, {
    String at = '/sites',
    Object? extra,
  }) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, _) => const Scaffold()),
        GoRoute(path: '/sites', builder: (_, _) => const SitesScreen()),
        GoRoute(
          path: AppRouter.siteEdit,
          builder: (_, state) => SiteEditorScreen(
            args: state.extra as SiteEditorArgs? ?? const SiteEditorArgs(),
          ),
        ),
        GoRoute(
          path: AppRouter.sitePick,
          builder: (_, state) => LocationPickerScreen(
            pickOnly: true,
            initial: state.extra as LatLng?,
          ),
        ),
      ],
    );
    await tester.pumpWidget(
      MultiProvider(
        providers: vm.providers,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    unawaited(router.push(at, extra: extra));
    await tester.pumpAndSettle();
  }

  domain.LocationProfile site(String name, double lat, double lon) =>
      domain.LocationProfile(
        id: 0,
        name: name,
        latitude: lat,
        longitude: lon,
        elevation: 300,
        timeZoneId: 'Europe/Ljubljana',
      );

  /// "Use current position", inside "Use device position" (library.js
  /// `locationView`), which opens first when closed.
  Future<void> useCurrentPosition(WidgetTester tester) async {
    final button = find.byKey(const Key('siteEditor.useCurrentPosition'));
    if (button.evaluate().isEmpty) {
      await tester.tap(find.text('Use device position'));
      await tester.pumpAndSettle();
    }
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
  }

  /// Opens "More (optional)" (elevation, sky darkness, notes) when closed.
  Future<void> openMore(WidgetTester tester) async {
    if (find.byKey(const Key('siteEditor.elevation')).evaluate().isNotEmpty) {
      return;
    }
    final header = find.byKey(
      const Key('section.${SiteEditorScreen.skyDarknessSection}'),
    );
    await tester.ensureVisible(header);
    await tester.tap(header);
    await tester.pumpAndSettle();
  }

  Future<void> save(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('siteEditor.save')));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
  }

  Future<void> typeSite(WidgetTester tester) async {
    await tester.enterText(fieldLabeled('Name'), 'Backyard');
    await tester.enterText(fieldLabeled('Latitude (°)'), '46.05');
    await tester.enterText(fieldLabeled('Longitude (°)'), '14.51');
  }

  /// Whether the row of site [id] says it is the one used for planning.
  bool marked(WidgetTester tester, int id) => find
      .descendant(
        of: find.byKey(ValueKey('site-$id')),
        matching: find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.selected == true,
        ),
      )
      .evaluate()
      .isNotEmpty;

  testWidgets(
    'site Save stays above the IME and coordinate fields are spaced',
    (tester) async {
      await build(tester);
      await pump(tester, at: AppRouter.siteEdit);
      tester.view.physicalSize = const Size(412, 915);
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pumpAndSettle();
      final save = tester.getRect(find.byKey(const Key('siteEditor.save')));
      expect(save.bottom, lessThanOrEqualTo(615));
      final latitude = fieldLabeled('Latitude (°)');
      final longitude = fieldLabeled('Longitude (°)');
      await tester.ensureVisible(latitude);
      await tester.pumpAndSettle();
      // library.js `library-pair`: side by side, 12 apart (stacked at large
      // text, a label's height apart).
      final a = tester.getRect(latitude), b = tester.getRect(longitude);
      expect(
        b.left - a.right >= 12 || b.top - a.bottom >= 20,
        isTrue,
        reason: '$a / $b',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Escape leaves a pristine site without a false discard prompt', (
    tester,
  ) async {
    await build(tester);
    await pump(tester, at: AppRouter.siteEdit);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(SiteEditorScreen), findsNothing);
    expect(find.byKey(const Key('unsaved.discard')), findsNothing);
  });

  testWidgets('the active site is marked, and tapping another selects it', (
    tester,
  ) async {
    await build(
      tester,
      sites: [site('Home', 46.05, 14.51), site('Dark site', 46.2, 14.1)],
    );
    await tester.runAsync(() => vm.selectSite(1));
    await pump(tester);

    expect(marked(tester, 1), isTrue);
    expect(marked(tester, 2), isFalse);

    await tester.tap(find.text('Dark site'));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();

    expect(vm.activeSite?.id, 2);
    expect(marked(tester, 2), isTrue);
  });

  testWidgets('Manage site opens details without selecting another site', (
    tester,
  ) async {
    await build(
      tester,
      sites: [site('Home', 46.05, 14.51), site('Dark site', 46.2, 14.1)],
    );
    await tester.runAsync(() => vm.selectSite(1));
    await pump(tester);
    await tester.tap(find.byKey(const ValueKey('site-manage-2')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('siteDetail.edit')), findsOneWidget);
    expect(vm.activeSite?.id, 1);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('sites.search')), findsOneWidget);
    expect(marked(tester, 1), isTrue);
  });

  testWidgets('selected site appears once in the ordinary saved list', (
    tester,
  ) async {
    await build(
      tester,
      sites: [site('Home', 46.05, 14.51), site('Dark site', 46.2, 14.1)],
    );
    await tester.runAsync(() => vm.selectSite(2));
    await pump(tester);
    expect(find.text('Used for planning'), findsNothing);
    expect(find.text('Dark site'), findsOneWidget);
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('site-1'))).dy,
      lessThan(tester.getTopLeft(find.byKey(const ValueKey('site-2'))).dy),
    );
    expect(marked(tester, 2), isTrue);
  });

  testWidgets('temporary position is a compact list row with explicit save', (
    tester,
  ) async {
    await build(tester, sites: [site('Home', 46.05, 14.51)]);
    await tester.runAsync(() => vm.site.setLocation(44.5, 13.5));
    await pump(tester);
    expect(find.byKey(const Key('sites.transient')), findsOneWidget);
    expect(find.textContaining('Not saved'), findsOneWidget);
    expect(find.text('Save as site'), findsNothing);
    expect(find.byTooltip('Save as site'), findsOneWidget);
    expect(
      tester.getTopLeft(find.byKey(const Key('sites.search'))).dy,
      lessThan(tester.getTopLeft(find.byKey(const Key('sites.transient'))).dy),
    );
    expect(vm.sites.length, 1, reason: 'the row does not silently save a site');
  });

  testWidgets(
    'inherited coordinates look up a name automatically and stay pristine',
    (tester) async {
      await build(
        tester,
        geocoder: FakeReverseGeocoder(
          result: const PlaceNameFound('Kyiv', attribution: 'test source'),
        ),
      );
      await pump(
        tester,
        at: AppRouter.siteEdit,
        extra: const SiteEditorArgs(latitude: 50.4, longitude: 30.6),
      );
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();
      expect(names.lookups, [(50.4, 30.6)]);
      expect(
        tester.widget<TextFormField>(fieldLabeled('Name')).controller!.text,
        'Kyiv',
      );
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Unsaved changes'), findsNothing);
      expect(find.byKey(const Key('siteEditor.name')), findsNothing);
      expect(vm.sites, isEmpty);
    },
  );

  testWidgets(
    'automatic naming off never sends inherited coordinates; consent can cancel',
    (tester) async {
      await build(tester, placeNames: false);
      await pump(
        tester,
        at: AppRouter.siteEdit,
        extra: const SiteEditorArgs(latitude: 50.4, longitude: 30.6),
      );
      expect(names.lookups, isEmpty);
      expect(find.text('Place names are off.'), findsOneWidget);
      await tester.tap(find.byKey(const Key('siteEditor.lookupName')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('siteEditor.placeNameOffer')),
        findsOneWidget,
      );
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Cancel'),
        ),
      );
      await tester.pumpAndSettle();
      expect(vm.settings.placeNameLookup, isFalse);
      expect(names.lookups, isEmpty);
    },
  );

  testWidgets('Cancel and Save site share height at 200 percent text', (
    tester,
  ) async {
    await build(tester);
    await pump(tester, at: AppRouter.siteEdit);
    tester.view.physicalSize = const Size(375, 760);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    await tester.pumpAndSettle();
    final save = tester.getRect(find.byKey(const Key('siteEditor.save')));
    final cancel = tester.getRect(find.byKey(const Key('siteEditor.cancel')));
    expect(save.height, cancel.height);
    expect(save.top, cancel.top);
    expect(save.height, greaterThanOrEqualTo(48));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Add site keeps an already resolved temporary place name', (
    tester,
  ) async {
    await build(
      tester,
      geocoder: FakeReverseGeocoder(
        result: const PlaceNameFound(
          'Known settlement',
          attribution: 'test source',
        ),
      ),
    );
    await tester.runAsync(() => vm.site.setLocation(44.5, 13.5));
    await pump(tester);
    await tester.pumpAndSettle();
    expect(vm.site.locationName, 'Known settlement');
    await tester.tap(find.byKey(const Key('sites.add')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextFormField>(fieldLabeled('Name')).controller!.text,
      'Known settlement',
    );
    expect(names.lookups, [(44.5, 13.5)]);
    expect(find.textContaining('Automatically assigned'), findsNothing);
  });

  for (final scale in [1.0, 2.0]) {
    testWidgets('geo rows center icon-only management at $scale text', (
      tester,
    ) async {
      await build(
        tester,
        sites: [
          site('Long observing site name with wrapping metadata', 46.05, 14.51),
        ],
      );
      await tester.runAsync(() => vm.selectSite(1));
      await pump(tester);
      tester.view.physicalSize = const Size(375, 760);
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.platformDispatcher.clearAllTestValues);
      await tester.pumpAndSettle();
      final row = tester.getRect(find.byKey(const ValueKey('site-1')));
      final action = tester.getRect(
        find.byKey(const ValueKey('site-manage-1')),
      );
      expect(action.width, greaterThanOrEqualTo(48));
      expect(action.height, greaterThanOrEqualTo(48));
      expect(action.center.dy, closeTo(row.center.dy, .1));
      expect(
        find.text('Long observing site name with wrapping metadata'),
        findsOneWidget,
      );
      expect(find.byType(OutlinedButton), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'a position changed during opt-in persistence never looks up the old point',
    (tester) async {
      final privacy = _DelayedPrivacy();
      await build(
        tester,
        privacy: privacy,
        placeNames: false,
        locationService: FakeLocationService(
          location: const DeviceLocation(latitude: 45.8123, longitude: 15.9771),
        ),
      );
      await pump(tester, at: AppRouter.siteEdit);
      await useCurrentPosition(tester);
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const Key('siteEditor.lookupName')),
      );
      await tester.tap(find.byKey(const Key('siteEditor.lookupName')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Turn on place names'));
      await tester.pump();
      await tester.enterText(fieldLabeled('Latitude (°)'), '44.5');
      privacy.write.complete();
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();
      expect(names.lookups, isEmpty);
      expect(
        tester.widget<TextFormField>(fieldLabeled('Name')).controller!.text,
        'Site - 44.50000, 15.97710',
      );
      expect(vm.settings.placeNameLookup, isTrue);
    },
  );

  testWidgets('the selected saved site remains searchable in the same list', (
    tester,
  ) async {
    await build(
      tester,
      sites: [site('Home', 46.05, 14.51), site('Dark site', 46.2, 14.1)],
    );
    await tester.runAsync(() => vm.selectSite(1));
    await pump(tester);
    await tester.enterText(find.byType(TextField).first, 'Home');
    await tester.pumpAndSettle();
    expect(find.textContaining('Nothing matches'), findsNothing);
    expect(find.byKey(const ValueKey('site-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('site-2')), findsNothing);
    expect(marked(tester, 1), isTrue);
    await tester.enterText(find.byType(TextField).first, 'missing');
    await tester.pumpAndSettle();
    expect(find.textContaining('Nothing matches'), findsOneWidget);
    await tester.tap(find.text('Clear search'));
    await tester.pumpAndSettle();
    expect(find.text('Dark site'), findsOneWidget);
  });

  testWidgets('GPS with lookup off saves an automatic label without typing', (
    tester,
  ) async {
    await build(
      tester,
      placeNames: false,
      locationService: FakeLocationService(
        location: const DeviceLocation(latitude: 45.8123, longitude: 15.9771),
      ),
    );
    await pump(tester, at: AppRouter.siteEdit);
    await useCurrentPosition(tester);
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
    expect(names.lookups, isEmpty);
    await save(tester);
    expect(vm.sites.single.name, 'Site - 45.81230, 15.97710');
    expect(vm.settings.placeNameLookup, isFalse);
  });

  testWidgets('manual position automatically enriches after typing stops', (
    tester,
  ) async {
    await build(
      tester,
      geocoder: FakeReverseGeocoder(
        result: const PlaceNameFound('Ljubljana', attribution: 'test source'),
      ),
    );
    await pump(tester, at: AppRouter.siteEdit);
    await tester.enterText(fieldLabeled('Latitude (°)'), '46.05');
    await tester.enterText(fieldLabeled('Longitude (°)'), '14.51');
    await tester.pumpAndSettle();
    expect(names.lookups, isEmpty, reason: 'no lookup per keystroke');
    expect(
      tester.widget<TextFormField>(fieldLabeled('Name')).controller!.text,
      'Site - 46.05000, 14.51000',
    );
    await tester.pump(const Duration(milliseconds: 750));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
    expect(names.lookups, [(46.05, 14.51)]);
    expect(
      tester.widget<TextFormField>(fieldLabeled('Name')).controller!.text,
      'Ljubljana',
    );
    await save(tester);
    expect(vm.sites.single.name, 'Ljubljana');
  });

  testWidgets('map point automatically names the draft without using it yet', (
    tester,
  ) async {
    await build(
      tester,
      geocoder: FakeReverseGeocoder(
        result: const PlaceNameFound(
          'Map settlement',
          attribution: 'test source',
        ),
      ),
    );
    await pump(tester, at: AppRouter.siteEdit);
    final before = (vm.latitude, vm.longitude);
    await tester.tap(find.byKey(const Key('siteEditor.pickOnMap')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('location.coordinates')));
    await tester.pumpAndSettle();
    final fields = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(fields.at(0), '44.5');
    await tester.enterText(fields.at(1), '13.5');
    await tester.tap(find.text('Use'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('location.usePoint')));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextFormField>(fieldLabeled('Name')).controller!.text,
      'Map settlement',
    );
    expect((vm.latitude, vm.longitude), before);
    expect(vm.sites, isEmpty);
    expect(find.text('From map · not saved'), findsOneWidget);
    await save(tester);
    expect(vm.sites.single.latitude, 44.5);
  });

  testWidgets('GPS precision and newest name response are preserved', (
    tester,
  ) async {
    final first = Completer<ReverseGeocodeResult>(),
        second = Completer<ReverseGeocodeResult>();
    var request = 0, fix = 0;
    await build(
      tester,
      locationService: FakeLocationService(
        answer: () async => LocationFound(
          DeviceLocation(
            latitude: ++fix == 1 ? 45.8123456 : 46.0512345,
            longitude: 14.5123456,
          ),
        ),
      ),
      geocoder: FakeReverseGeocoder(
        answer: () => ++request == 1 ? first.future : second.future,
      ),
    );
    await pump(tester, at: AppRouter.siteEdit);
    await useCurrentPosition(tester);
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
    await useCurrentPosition(tester);
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
    second.complete(const PlaceNameFound('Newest', attribution: 'test source'));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
    first.complete(
      const PlaceNameFound('Obsolete', attribution: 'test source'),
    );
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextFormField>(fieldLabeled('Name')).controller!.text,
      'Newest',
    );
    await save(tester);
    expect(vm.sites.single.name, 'Newest');
    expect(vm.sites.single.latitude, 46.05123);
  });

  testWidgets('deleting the active site keeps its position as unsaved', (
    tester,
  ) async {
    await build(tester, sites: [site('Home', 46.05, 14.51)]);
    await tester.runAsync(() => vm.selectSite(1));
    await pump(tester);

    // A swipe deletes from the list (the record's Delete site too).
    await tester.drag(find.text('Home'), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(find.textContaining('is the active site'), findsOneWidget);
    await tester.tap(find.byKey(const Key('confirm.action'))); // S9.1
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();

    expect(vm.sites, isEmpty);
    expect(vm.activeSite, isNull);
    // F23 A7: an unnamed unsaved position reads as one, with coordinates.
    expect(find.text('Position'), findsOneWidget);
    expect(find.text('46.05000°, 14.51000° · Not saved'), findsOneWidget);
    expect(find.byTooltip('Save as site'), findsOneWidget);
    expect(
      find.text('No saved sites yet. Add one with “Add site”.'),
      findsNothing,
    );
  });

  testWidgets('the editor rejects missing and out-of-range values', (
    tester,
  ) async {
    await build(tester);
    await pump(tester, at: AppRouter.siteEdit);

    await tester.tap(find.byKey(const Key('siteEditor.save')));
    await tester.pumpAndSettle();
    expect(find.text('Name is required'), findsOneWidget);
    expect(find.text('Latitude is required'), findsOneWidget);
    // S7.5 (RG-08 = E2): elevation is optional; empty is unknown.
    expect(find.text('Elevation is required'), findsNothing);

    await tester.enterText(fieldLabeled('Latitude (°)'), '91');
    await tester.tap(find.byKey(const Key('siteEditor.save')));
    await tester.pumpAndSettle();
    expect(find.text('Latitude must be between -90 and 90'), findsOneWidget);
    expect(vm.sites, isEmpty);
  });

  testWidgets('a new site defaults to the device zone and becomes active', (
    tester,
  ) async {
    await build(tester);
    await pump(tester, at: AppRouter.siteEdit);

    expect(find.text('Europe/Ljubljana'), findsOneWidget);
    expect(
      find.textContaining('From device — check for this site.'),
      findsOneWidget,
    );
    await tester.enterText(fieldLabeled('Name'), 'Backyard');
    await tester.enterText(fieldLabeled('Latitude (°)'), '46.05');
    await tester.enterText(fieldLabeled('Longitude (°)'), '14,51');
    await openMore(tester);
    await tester.enterText(fieldLabeled('Elevation (m, optional)'), '295');
    await tester.tap(find.byKey(const Key('siteEditor.save')));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();

    final saved = vm.sites.single;
    expect(saved.name, 'Backyard');
    expect(saved.longitude, 14.51);
    expect(saved.timeZoneId, 'Europe/Ljubljana');
    expect(vm.activeSite?.id, saved.id);
    expect(find.byType(SiteEditorScreen), findsNothing, reason: 'popped');
  });

  testWidgets('"Save as site" starts from the current position', (
    tester,
  ) async {
    await build(tester);
    await tester.runAsync(() => vm.setLocation(45.5, 13.7));
    await pump(tester);

    await tester.tap(find.byKey(const Key('sites.saveTransient')));
    await tester.pumpAndSettle();

    expect(find.text('New site'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '45.50000'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '13.70000'), findsOneWidget);
  });

  testWidgets('editing a site keeps what was not changed', (tester) async {
    await build(tester, sites: [site('Home', 46.05, 14.51)]);
    await tester.runAsync(() => vm.selectSite(1));
    await pump(
      tester,
      at: AppRouter.siteEdit,
      extra: SiteEditorArgs(site: vm.sites.single),
    );
    expect(find.text('Edit site'), findsOneWidget);
    expect(find.text('Europe/Ljubljana'), findsOneWidget);
    await tester.enterText(fieldLabeled('Name'), 'Garden');
    await tester.tap(find.byKey(const Key('siteEditor.save')));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();

    final saved = vm.sites.single;
    expect(saved.name, 'Garden');
    expect(saved.latitude, 46.05);
    expect(saved.elevation, 300);
    expect(saved.timeZoneId, 'Europe/Ljubljana');
    expect(vm.locationName, 'Garden');
  });

  // TASK 7.4 (PD-05 option B): manual Bortle/SQM, recorded as "user" with
  // the date of the edit.
  testWidgets('Bortle and SQM entered in the editor are stored as user', (
    tester,
  ) async {
    await build(tester, sites: [site('Home', 46.05, 14.51)]);
    await tester.runAsync(() => vm.selectSite(1));
    await pump(
      tester,
      at: AppRouter.siteEdit,
      extra: SiteEditorArgs(site: vm.sites.single),
    );
    await openMore(tester); // S7.5: collapsed by default
    await tester.tap(
      find.widgetWithText(DropdownButtonFormField<int?>, 'Unknown'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bortle 5').last);
    await tester.pumpAndSettle();
    await tester.enterText(fieldLabeled('SQM (mag/arcsec²)'), '20.4');
    await tester.tap(find.byKey(const Key('siteEditor.save')));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();

    final saved = vm.sites.single;
    expect(saved.bortleClass, 5);
    expect(saved.bortleSource, 'user');
    expect(saved.bortleDate, vm.today);
    expect(saved.sqm, 20.4);
    expect(saved.sqmSource, 'user');
    expect(saved.sqmDate, vm.today);
    expect(vm.skyDarkness.bortleClass, 5);
  });

  testWidgets('an out-of-range SQM is rejected', (tester) async {
    await build(tester);
    await pump(tester, at: AppRouter.siteEdit);
    await openMore(tester); // S7.5: collapsed by default

    await tester.enterText(fieldLabeled('SQM (mag/arcsec²)'), '30');
    await tester.tap(find.byKey(const Key('siteEditor.save')));
    await tester.pumpAndSettle();
    expect(find.text('SQM must be between 15 and 23'), findsOneWidget);
  });

  group('S7.5: the site form', () {
    testWidgets('an empty elevation is saved as unknown, never 0; a stored '
        'one is kept', (tester) async {
      await build(tester);
      await pump(tester, at: AppRouter.siteEdit);
      await typeSite(tester);
      await save(tester);
      final saved = vm.sites.single;
      expect(saved.elevation, isNull);
      expect(saved.name, 'Backyard');
    });

    testWidgets('an edited site with an unknown elevation shows it empty and '
        'keeps it unknown', (tester) async {
      await build(
        tester,
        sites: [
          domain.LocationProfile(
            id: 0,
            name: 'Hill',
            latitude: 46.1,
            longitude: 14.6,
            timeZoneId: 'Europe/Ljubljana',
          ),
        ],
      );
      await tester.runAsync(() => vm.selectSite(1));
      await pump(
        tester,
        at: AppRouter.siteEdit,
        extra: SiteEditorArgs(site: vm.sites.single),
      );
      await openMore(tester);
      final field = tester.widget<TextFormField>(
        fieldLabeled('Elevation (m, optional)'),
      );
      expect(field.controller!.text, isEmpty);
      await tester.enterText(fieldLabeled('Name'), 'Hilltop');
      await save(tester);
      expect(vm.sites.single.elevation, isNull);
      expect(vm.sites.single.name, 'Hilltop');
    });

    testWidgets('"Use current position" asks only on the tap, fills the '
        'coordinates, and stores nothing until Save', (tester) async {
      await build(
        tester,
        locationService: FakeLocationService(
          location: const DeviceLocation(latitude: 45.8123, longitude: 15.9771),
        ),
      );
      await pump(tester, at: AppRouter.siteEdit);
      expect(gps.calls, 0);
      final before = (vm.site.latitude, vm.site.longitude);

      await useCurrentPosition(tester);
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();
      expect(gps.calls, 1);
      expect(find.widgetWithText(TextFormField, '45.81230'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '15.97710'), findsOneWidget);
      expect(vm.sites, isEmpty, reason: 'nothing saved');
      expect(
        (vm.site.latitude, vm.site.longitude),
        before,
        reason: 'the fix only fills the form (trap 2)',
      );

      await tester.enterText(fieldLabeled('Name'), 'Field');
      await save(tester);
      expect(vm.sites.single.latitude, 45.8123);
    });

    // F23 A6 (CRUX-03): a fix fills the coordinates only if neither changed
    // while it was found; otherwise the edit is kept and the fix offered.
    // TD-112: the list's request says it is running, and one that never
    // gets a fix ends with an explained failure (the service's time limit
    // throws), the button usable again.
    testWidgets('the list says a position request is running; a timeout is '
        'explained', (tester) async {
      final fix = Completer<LocationResult>();
      await build(
        tester,
        locationService: FakeLocationService(answer: () => fix.future),
      );
      await pump(tester);
      final button = find.byKey(const Key('sites.useCurrentPosition'));
      await tester.tap(button);
      await tester.pump();
      expect(find.text('Getting position…'), findsOneWidget);
      expect(tester.widget<GeoActionRow>(button).onTap, isNull);
      fix.completeError(TimeoutException('no fix'));
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();
      expect(
        find.text("Couldn't get your position. Please try again."),
        findsOneWidget,
      );
      expect(find.text('Use current position'), findsOneWidget);
      expect(tester.widget<GeoActionRow>(button).onTap, isNotNull);
    });

    group('a fix that arrives after an edit', () {
      late Completer<LocationResult> fix;
      const found = LocationFound(
        DeviceLocation(latitude: 45.8123, longitude: 15.9771),
      );

      Future<void> startLocating(WidgetTester tester) async {
        fix = Completer<LocationResult>();
        await build(
          tester,
          locationService: FakeLocationService(answer: () => fix.future),
        );
        await pump(tester, at: AppRouter.siteEdit);
        await useCurrentPosition(tester);
        await tester.pump();
        expect(gps.calls, 1);
      }

      Future<void> answer(WidgetTester tester) async {
        fix.complete(found);
        await tester.runAsync(() => Future<void>.delayed(Duration.zero));
        await tester.pumpAndSettle();
      }

      testWidgets('unchanged coordinates are filled', (tester) async {
        await startLocating(tester);
        await answer(tester);
        expect(find.widgetWithText(TextFormField, '45.81230'), findsOneWidget);
        expect(find.byKey(const Key('siteEditor.positionFound')), findsNothing);
      });

      testWidgets('a typed edit is kept, typing and Save stay available, and '
          'the fix is used only on request', (tester) async {
        await startLocating(tester);
        await tester.enterText(fieldLabeled('Latitude (°)'), '46.1');
        await tester.enterText(fieldLabeled('Longitude (°)'), '14.2');
        await tester.enterText(fieldLabeled('Name'), 'Typed');
        expect(
          tester
              .widget<FilledButton>(find.byKey(const Key('siteEditor.save')))
              .onPressed,
          isNotNull,
          reason: 'Save while locating',
        );

        await answer(tester);
        expect(find.widgetWithText(TextFormField, '46.1'), findsOneWidget);
        expect(find.widgetWithText(TextFormField, '14.2'), findsOneWidget);
        expect(
          find.byKey(const Key('siteEditor.positionFound')),
          findsOneWidget,
        );

        await tester.tap(find.text('Use position'));
        await tester.pumpAndSettle();
        expect(find.widgetWithText(TextFormField, '45.81230'), findsOneWidget);
        expect(find.widgetWithText(TextFormField, '15.97710'), findsOneWidget);
        expect(vm.sites, isEmpty, reason: 'still nothing saved');
      });

      testWidgets('the edit is saved as typed when the offer is closed', (
        tester,
      ) async {
        await startLocating(tester);
        await tester.enterText(fieldLabeled('Latitude (°)'), '46.1');
        await tester.enterText(fieldLabeled('Longitude (°)'), '14.2');
        await answer(tester);
        await tester.tap(
          find.descendant(
            of: find.byKey(const Key('siteEditor.positionFound')),
            matching: find.byIcon(Icons.close),
          ),
        );
        await tester.pumpAndSettle();
        await tester.enterText(fieldLabeled('Name'), 'Typed');
        await save(tester);
        expect(vm.sites.single.latitude, 46.1);
        expect(vm.sites.single.longitude, 14.2);
      });

      testWidgets('a map pick is kept', (tester) async {
        await startLocating(tester);
        await tester.ensureVisible(
          find.byKey(const Key('siteEditor.pickOnMap')),
        );
        await tester.tap(find.byKey(const Key('siteEditor.pickOnMap')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('location.coordinates')));
        await tester.pumpAndSettle();
        final fields = find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextFormField),
        );
        await tester.enterText(fields.at(0), '44.5');
        await tester.enterText(fields.at(1), '13.5');
        await tester.tap(find.text('Use'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('location.usePoint')));
        await tester.pumpAndSettle();
        expect(find.widgetWithText(TextFormField, '44.50000'), findsOneWidget);

        await answer(tester);
        expect(find.widgetWithText(TextFormField, '44.50000'), findsOneWidget);
        expect(find.widgetWithText(TextFormField, '13.50000'), findsOneWidget);
        expect(
          find.byKey(const Key('siteEditor.positionFound')),
          findsOneWidget,
        );
      });

      testWidgets('a fix after leaving the editor writes nothing', (
        tester,
      ) async {
        await startLocating(tester);
        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(find.byType(SiteEditorScreen), findsNothing);
        final before = (vm.site.latitude, vm.site.longitude);

        await answer(tester);
        expect(tester.takeException(), isNull);
        expect(find.byKey(const Key('siteEditor.positionFound')), findsNothing);
        expect(vm.sites, isEmpty);
        expect((vm.site.latitude, vm.site.longitude), before);
      });
    });

    // F23 A5 (AM-01): "Use current position" proposes a name for an empty
    // name through the consented lookup; off, it offers the opt-in and sends
    // nothing; a name already there, typed meanwhile, or a position changed
    // meanwhile is never overwritten; not finding one never blocks Save.
    group('a name for the position', () {
      const at = DeviceLocation(latitude: 45.8123, longitude: 15.9771);
      const ljubljana = PlaceNameFound(
        'Ljubljana',
        attribution: '© OpenStreetMap contributors',
      );

      Future<void> locate(WidgetTester tester) async {
        await useCurrentPosition(tester);
        for (var i = 0; i < 3; i++) {
          await tester.runAsync(() => Future<void>.delayed(Duration.zero));
          await tester.pump();
        }
        await tester.pumpAndSettle();
      }

      String nameText(WidgetTester tester) => tester
          .widget<TextFormField>(find.byKey(const Key('siteEditor.name')))
          .controller!
          .text;

      testWidgets('found: the name is proposed with its source, and saved', (
        tester,
      ) async {
        await build(
          tester,
          locationService: FakeLocationService(location: at),
          geocoder: FakeReverseGeocoder(result: ljubljana),
        );
        await pump(tester, at: AppRouter.siteEdit);
        await locate(tester);

        expect(names.lookups, [(45.8123, 15.9771)]);
        expect(nameText(tester), 'Ljubljana');
        expect(
          find.textContaining(
            'Filled automatically · © OpenStreetMap contributors',
          ),
          findsOneWidget,
        );
        expect(vm.sites, isEmpty, reason: 'nothing saved before Save');
        await save(tester);
        expect(vm.sites.single.name, 'Ljubljana');
        expect(vm.sites.single.latitude, 45.8123);
      });

      testWidgets('a name already there is kept and nothing is sent', (
        tester,
      ) async {
        await build(
          tester,
          locationService: FakeLocationService(location: at),
          geocoder: FakeReverseGeocoder(result: ljubljana),
        );
        await pump(tester, at: AppRouter.siteEdit);
        await tester.enterText(
          find.byKey(const Key('siteEditor.name')),
          'Back garden',
        );
        await locate(tester);
        expect(names.lookups, isEmpty);
        expect(nameText(tester), 'Back garden');
      });

      testWidgets('a saved site being edited keeps its name', (tester) async {
        await build(
          tester,
          sites: [site('Home', 46.05, 14.51)],
          locationService: FakeLocationService(location: at),
          geocoder: FakeReverseGeocoder(result: ljubljana),
        );
        await pump(
          tester,
          at: AppRouter.siteEdit,
          extra: SiteEditorArgs(site: vm.sites.single),
        );
        await locate(tester);
        expect(names.lookups, isEmpty);
        expect(nameText(tester), 'Home');
      });

      testWidgets('a name typed while the lookup runs wins', (tester) async {
        final pending = Completer<ReverseGeocodeResult>();
        await build(
          tester,
          locationService: FakeLocationService(location: at),
          geocoder: FakeReverseGeocoder(answer: () => pending.future),
        );
        await pump(tester, at: AppRouter.siteEdit);
        await locate(tester);
        expect(find.text('Looking up a place name…'), findsOneWidget);
        await tester.enterText(
          find.byKey(const Key('siteEditor.name')),
          'Typed',
        );
        pending.complete(ljubljana);
        await tester.runAsync(() => Future<void>.delayed(Duration.zero));
        await tester.pumpAndSettle();
        expect(nameText(tester), 'Typed');
        expect(find.textContaining('Suggested by'), findsNothing);
      });

      testWidgets('Save while the lookup runs saves the typed name; the late '
          'answer never overwrites it', (tester) async {
        final pending = Completer<ReverseGeocodeResult>();
        await build(
          tester,
          locationService: FakeLocationService(location: at),
          geocoder: FakeReverseGeocoder(answer: () => pending.future),
        );
        await pump(tester, at: AppRouter.siteEdit);
        await locate(tester);
        expect(find.text('Looking up a place name…'), findsOneWidget);
        await tester.enterText(
          find.byKey(const Key('siteEditor.name')),
          'Typed',
        );
        await save(tester);
        // Saved with the typed name and the fix, without waiting.
        expect(vm.sites.single.name, 'Typed');
        expect(vm.sites.single.latitude, 45.8123);
        expect(vm.sites.single.longitude, 15.9771);
        expect(find.byType(SiteEditorScreen), findsNothing, reason: 'left');

        pending.complete(ljubljana);
        for (var i = 0; i < 3; i++) {
          await tester.runAsync(() => Future<void>.delayed(Duration.zero));
          await tester.pump();
        }
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(vm.sites.single.name, 'Typed');
        final stored = await tester.runAsync(locations.getLocations);
        expect(stored!.single.name, 'Typed', reason: 'never overwritten');
        expect(find.text('Ljubljana'), findsNothing);
      });

      testWidgets('an answer for coordinates changed meanwhile is ignored', (
        tester,
      ) async {
        final pending = Completer<ReverseGeocodeResult>();
        await build(
          tester,
          locationService: FakeLocationService(location: at),
          geocoder: FakeReverseGeocoder(answer: () => pending.future),
        );
        await pump(tester, at: AppRouter.siteEdit);
        await locate(tester);
        await tester.enterText(fieldLabeled('Latitude (°)'), '44.1');
        pending.complete(ljubljana);
        await tester.runAsync(() => Future<void>.delayed(Duration.zero));
        await tester.pumpAndSettle();
        expect(nameText(tester), 'Site - 44.10000, 15.97710');
        expect(find.textContaining('Filled automatically'), findsNothing);
      });

      testWidgets('off: the opt-in is offered, nothing is sent, typing a '
          'name and Save still work', (tester) async {
        await build(
          tester,
          locationService: FakeLocationService(location: at),
          geocoder: FakeReverseGeocoder(result: ljubljana),
          placeNames: false,
        );
        await pump(tester, at: AppRouter.siteEdit);
        await locate(tester);
        expect(find.byTooltip('Turn on place names'), findsOneWidget);
        expect(names.lookups, isEmpty, reason: 'nothing sent while off');
        expect(vm.settings.placeNameLookup, isFalse);

        await tester.enterText(
          find.byKey(const Key('siteEditor.name')),
          'Field',
        );
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('siteEditor.placeNameOffer')),
          findsNothing,
        );
        await save(tester);
        expect(vm.sites.single.name, 'Field');
        expect(names.lookups, isEmpty);
        expect(vm.settings.placeNameLookup, isFalse);
      });

      testWidgets('off, then turned on from the offer: the setting is on and '
          'the name is proposed', (tester) async {
        await build(
          tester,
          locationService: FakeLocationService(location: at),
          geocoder: FakeReverseGeocoder(result: ljubljana),
          placeNames: false,
        );
        await pump(tester, at: AppRouter.siteEdit);
        await locate(tester);
        await tester.tap(find.byKey(const Key('siteEditor.lookupName')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Turn on place names'));
        for (var i = 0; i < 3; i++) {
          await tester.runAsync(() => Future<void>.delayed(Duration.zero));
          await tester.pump();
        }
        await tester.pumpAndSettle();
        expect(vm.settings.placeNameLookup, isTrue);
        expect(names.lookups, contains((45.8123, 15.9771)));
        expect(nameText(tester), 'Ljubljana');
        expect(vm.sites, isEmpty);
      });

      for (final (label, result, helper) in [
        (
          'not found',
          const PlaceNameNotFound() as ReverseGeocodeResult,
          'No place name found. The coordinate name can be saved.',
        ),
        (
          'a failure',
          const ReverseGeocodeFailed('offline') as ReverseGeocodeResult,
          'Name lookup failed. The coordinate name can be saved.',
        ),
      ]) {
        testWidgets('$label: says so, and the automatic name saves', (
          tester,
        ) async {
          await build(
            tester,
            locationService: FakeLocationService(location: at),
            geocoder: FakeReverseGeocoder(result: result),
          );
          await pump(tester, at: AppRouter.siteEdit);
          await locate(tester);
          expect(find.text(helper), findsOneWidget);
          expect(nameText(tester), 'Site - 45.81230, 15.97710');
          await save(tester);
          expect(vm.sites.single.name, 'Site - 45.81230, 15.97710');
          expect(vm.sites.single.latitude, 45.8123);
        });
      }
    });

    testWidgets('a GPS failure says why and changes no field', (tester) async {
      await build(tester);
      await pump(tester, at: AppRouter.siteEdit);
      await useCurrentPosition(tester);
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();
      expect(find.byType(MaterialBanner), findsOneWidget);
      final lat = tester.widget<TextFormField>(fieldLabeled('Latitude (°)'));
      expect(lat.controller!.text, isEmpty);
    });

    // S7V-02 / TD-084 (S7.V2): Back asks about an edit to any one field.
    Future<void> editOnly(
      WidgetTester tester,
      String label,
      String text,
    ) async {
      if (label != 'Name') await openMore(tester);
      final field = fieldLabeled(label);
      await tester.ensureVisible(field);
      await tester.enterText(field, text);
      await tester.pumpAndSettle();
    }

    Future<void> back(WidgetTester tester, {required bool system}) async {
      if (system) {
        await tester.binding.handlePopRoute();
      } else {
        await tester.pageBack();
      }
      await tester.pumpAndSettle();
    }

    const edits = [
      ('Name', 'Changed name'),
      ('Elevation (m, optional)', '450'),
      ('Notes (optional)', 'Private note'),
    ];
    for (final existing in [true, false]) {
      for (final system in [false, true]) {
        for (final item in edits) {
          testWidgets('back guards a ${item.$1}-only edit '
              '(${existing ? 'existing' : 'new'} site, '
              '${system ? 'system' : 'app bar'} Back)', (tester) async {
            await build(
              tester,
              sites: existing ? [site('Original', 46, 14)] : const [],
            );
            await pump(
              tester,
              at: AppRouter.siteEdit,
              extra: existing ? SiteEditorArgs(site: vm.sites.single) : null,
            );
            await editOnly(tester, item.$1, item.$2);
            await back(tester, system: system);
            expect(find.text('Unsaved changes'), findsOneWidget);
            expect(find.byType(SiteEditorScreen), findsOneWidget);
          });
        }
      }
    }

    testWidgets('an edit typed back to the original leaves without asking', (
      tester,
    ) async {
      await build(tester, sites: [site('Original', 46, 14)]);
      await pump(
        tester,
        at: AppRouter.siteEdit,
        extra: SiteEditorArgs(site: vm.sites.single),
      );
      await editOnly(tester, 'Name', 'Changed name');
      await editOnly(tester, 'Name', 'Original');
      await editOnly(tester, 'Elevation (m, optional)', '450');
      await editOnly(tester, 'Elevation (m, optional)', '300');
      await back(tester, system: false);
      expect(find.text('Unsaved changes'), findsNothing);
      expect(find.byType(SiteEditorScreen), findsNothing);
    });

    testWidgets('a new site with only the device zone filled in leaves '
        'without asking', (tester) async {
      await build(tester);
      await pump(tester, at: AppRouter.siteEdit);
      expect(find.text('Europe/Ljubljana'), findsOneWidget);
      await back(tester, system: true);
      expect(find.text('Unsaved changes'), findsNothing);
      expect(find.byType(SiteEditorScreen), findsNothing);
    });

    testWidgets('a name-only edit: Cancel keeps it, Discard stores nothing, '
        'Save stores it', (tester) async {
      await build(tester, sites: [site('Original', 46, 14)]);
      await pump(
        tester,
        at: AppRouter.siteEdit,
        extra: SiteEditorArgs(site: vm.sites.single),
      );
      await editOnly(tester, 'Name', 'Changed name');
      await back(tester, system: false);
      await tester.tap(find.byKey(const Key('unsaved.cancel')));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextFormField, 'Changed name'), findsOne);

      await back(tester, system: false);
      await tester.tap(find.byKey(const Key('unsaved.discard')));
      await tester.pumpAndSettle();
      expect(find.byType(SiteEditorScreen), findsNothing);
      expect(vm.sites.single.name, 'Original');

      await pump(
        tester,
        at: AppRouter.siteEdit,
        extra: SiteEditorArgs(site: vm.sites.single),
      );
      await editOnly(tester, 'Notes (optional)', 'Private note');
      await back(tester, system: false);
      await tester.tap(find.byKey(const Key('unsaved.save')));
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();
      expect(find.byType(SiteEditorScreen), findsNothing);
      expect(vm.sites.single.notes, 'Private note');
      expect(vm.sites.single.name, 'Original');
    });

    testWidgets('back without changes leaves; with changes it asks: Cancel '
        'stays, Discard leaves without saving', (tester) async {
      await build(tester);
      await pump(tester, at: AppRouter.siteEdit);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(SiteEditorScreen), findsNothing);

      await pump(tester, at: AppRouter.siteEdit);
      await typeSite(tester);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Unsaved changes'), findsOneWidget);
      await tester.tap(find.byKey(const Key('unsaved.cancel')));
      await tester.pumpAndSettle();
      expect(find.byType(SiteEditorScreen), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Backyard'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('unsaved.discard')));
      await tester.pumpAndSettle();
      expect(find.byType(SiteEditorScreen), findsNothing);
      expect(vm.sites, isEmpty);
    });

    testWidgets('Save in the prompt saves and leaves', (tester) async {
      await build(tester);
      await pump(tester, at: AppRouter.siteEdit);
      await typeSite(tester);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('unsaved.save')));
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();
      expect(vm.sites.single.name, 'Backyard');
      expect(find.byType(SiteEditorScreen), findsNothing);
    });

    testWidgets('sky darkness: collapsed, its summary states what is '
        'stored, remembered; the map link needs valid coordinates', (
      tester,
    ) async {
      await build(
        tester,
        sites: [
          domain.LocationProfile(
            id: 0,
            name: 'Home',
            latitude: 46.05,
            longitude: 14.51,
            bortleClass: 4,
            bortleSource: 'user',
            timeZoneId: 'Europe/Ljubljana',
          ),
        ],
      );
      await tester.runAsync(() => vm.selectSite(1));
      await pump(
        tester,
        at: AppRouter.siteEdit,
        extra: SiteEditorArgs(site: vm.sites.single),
      );
      expect(find.text('More (optional)'), findsOneWidget);
      expect(find.text('Bortle 4'), findsOneWidget, reason: 'the summary');
      expect(find.text('SQM (mag/arcsec²)'), findsNothing, reason: 'closed');

      await openMore(tester);
      expect(
        vm.disclosure.isOpen(SiteEditorScreen.skyDarknessSection),
        isTrue,
        reason: 'remembered like the planner sections',
      );
      TextButton link() => tester.widget<TextButton>(
        find.byKey(const Key('siteEditor.mapLink')),
      );
      expect(link().onPressed, isNotNull);
      await tester.enterText(fieldLabeled('Latitude (°)'), '95');
      await tester.pump();
      expect(link().onPressed, isNull);
    });

    testWidgets('a new site: sky darkness Unknown; an out-of-range SQM in the '
        'closed section opens it and shows the message', (tester) async {
      await build(tester);
      await pump(tester, at: AppRouter.siteEdit);
      expect(
        find.text('Elevation, sky darkness and notes'),
        findsOneWidget,
        reason: 'the summary: nothing set',
      );
      await openMore(tester);
      await tester.enterText(fieldLabeled('SQM (mag/arcsec²)'), '30');
      // Close it again.
      await tester.tap(
        find.byKey(const Key('section.${SiteEditorScreen.skyDarknessSection}')),
      );
      await tester.pumpAndSettle();
      await typeSite(tester);
      await save(tester);
      expect(find.text('SQM must be between 15 and 23'), findsOneWidget);
      expect(vm.sites, isEmpty);
    });
  });
}
