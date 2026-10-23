// F24 A2 (TD-102, S11H-06): the Stage 11 probe P3, committed. With every map
// tile request failing, as on a phone without a connection, the picker stays
// usable: nothing throws, the map, its attribution and every control stay,
// and a typed position is shown and used.
//
// A file of its own: flutter_map's tile cache is one per process and asks
// path_provider for a folder when the first map is built. A map built in a
// test without real time leaves that cache never ready, and no later map in
// the same process would request a tile.

import 'dart:io';

import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/presentation/screens/location/location_picker_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/fake_location_service.dart';
import '../../../support/fake_reverse_geocoder.dart';
import '../../../support/no_snapshot_weather.dart';
import '../../../support/planner_harness.dart';

class _NoWeather with NoSnapshotWeather implements WeatherRepository {}

/// No network: every request fails as it does without a connection, and is
/// counted, so the test can tell the tiles were really asked for.
class _OfflineHttpClient implements HttpClient {
  int requests = 0;

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) {
    requests++;
    throw const SocketException('offline (test)');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _OfflineHttp extends HttpOverrides {
  _OfflineHttp(this.client);

  final _OfflineHttpClient client;

  @override
  HttpClient createHttpClient(SecurityContext? context) => client;
}

void main() {
  // The host has no path_provider plugin; a device has it.
  const pathProvider = MethodChannel('plugins.flutter.io/path_provider');
  late Directory cache;
  late _OfflineHttpClient http;
  HttpOverrides? previous;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    cache = Directory.systemTemp.createTempSync('picker_tiles_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProvider, (call) async => cache.path);
    http = _OfflineHttpClient();
    previous = HttpOverrides.current;
    HttpOverrides.global = _OfflineHttp(http);
  });

  tearDown(() {
    HttpOverrides.global = previous;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProvider, null);
    // Windows keeps flutter_map's process-wide tile cache file open until the
    // test process exits, so the folder may not be deletable yet; it is in
    // the system temp folder. Cleanup only: no assertion depends on it.
    try {
      cache.deleteSync(recursive: true);
    } on FileSystemException {
      // Left for the OS temp cleanup.
    }
  });

  // The tile loads need real time (the cache folder, the requests) and frames
  // in between to start and fail: wait for new requests to start (up to
  // 10 s), then a little longer for them to fail.
  Future<void> letTilesFail(WidgetTester tester) async {
    Future<void> step() async {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }

    final before = http.requests;
    for (var i = 0; i < 100 && http.requests == before; i++) {
      await step();
    }
    for (var i = 0; i < 5; i++) {
      await step();
    }
  }

  testWidgets('the map and its controls stay usable, and a typed position '
      'is shown and used', (tester) async {
    late AppDatabase database;
    late PlannerHarness vm;
    await tester.runAsync(() async {
      database = AppDatabase(NativeDatabase.memory());
      vm = PlannerHarness(
        DriftTargetRepository(database),
        DriftEquipmentRepository(database),
        _NoWeather(),
        DriftLocationRepository(database),
        locationService: FakeLocationService(),
        reverseGeocoder: FakeReverseGeocoder(),
      );
      await vm.ready;
    });
    addTearDown(() => tester.runAsync(database.close));
    await tester.pumpWidget(
      MultiProvider(
        providers: vm.providers,
        child: MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: '/pick',
            routes: [
              GoRoute(
                path: '/',
                builder: (_, _) => const Text('caller'),
                routes: [
                  GoRoute(
                    path: 'pick',
                    builder: (_, _) => const LocationPickerScreen(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    await letTilesFail(tester);

    final requested = http.requests;
    expect(requested, greaterThan(0), reason: 'tiles were requested');
    expect(tester.takeException(), isNull);
    expect(find.byType(TileLayer), findsOneWidget);
    expect(find.text('OpenStreetMap contributors'), findsOneWidget);
    expect(
      tester
          .widget<TextButton>(find.byKey(const Key('location.coordinates')))
          .onPressed,
      isNotNull,
    );
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('location.usePoint')))
          .onPressed,
      isNotNull,
    );
    expect(
      tester
          .widget<IconButton>(
            find.byKey(const Key('location.useCurrentPosition')),
          )
          .onPressed,
      isNotNull,
    );
    await tester.tap(find.byKey(const Key('location.coordinates')));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '46.05');
    await tester.enterText(fields.at(1), '14.51');
    await tester.tap(find.text('Use'));
    await tester.pumpAndSettle();
    await letTilesFail(tester);
    expect(http.requests, greaterThan(requested), reason: 'new tiles failed');

    final marker = tester.widget<MarkerLayer>(find.byType(MarkerLayer));
    expect(marker.markers.single.point.latitude, 46.05);
    expect(marker.markers.single.point.longitude, 14.51);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const Key('location.usePoint')));
    await tester.runAsync(() => vm.plan.idle);
    await tester.pumpAndSettle();
    expect((vm.latitude, vm.longitude), (46.05, 14.51));
    expect(find.text('caller'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
