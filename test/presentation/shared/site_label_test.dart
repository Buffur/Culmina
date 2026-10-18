// F23 A7 (CRUX-04): a remembered unsaved position without a known place name
// is never called "Current position". Home (Tonight), the planner, Welcome
// and the Sites list call it an unsaved position, with its coordinates where
// space allows, before and after a restart; a saved site keeps its name and
// a looked-up name its attribution. Nothing here asks for GPS.

import 'dart:async';

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/models/location_profile.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/domain/services/location_service.dart';
import 'package:astroplan/domain/services/reverse_geocoder.dart';
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:astroplan/presentation/shared/site_label.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_location_service.dart';
import '../../support/fake_reverse_geocoder.dart';
import '../../support/in_memory_first_run.dart';
import '../../support/in_memory_privacy_preferences.dart';
import '../../support/no_snapshot_weather.dart';
import '../../support/planner_harness.dart';

class _NoForecast with NoSnapshotWeather implements WeatherRepository {}

void main() {
  late AppDatabase database;
  late FakeLocationService gps;

  const unsaved = 'Unsaved position (46.0500, 14.5100)';

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    database = AppDatabase(NativeDatabase.memory());
    gps = FakeLocationService();
  });
  tearDown(() => database.close());

  /// A harness over the same database and preferences, as after a restart.
  Future<PlannerHarness> open({
    bool lookup = false,
    ReverseGeocoder? geocoder,
  }) async {
    final vm = PlannerHarness(
      DriftTargetRepository(database),
      DriftEquipmentRepository(database),
      _NoForecast(),
      DriftLocationRepository(database),
      locationService: gps,
      reverseGeocoder: geocoder ?? FakeReverseGeocoder(),
      privacyPreferences: InMemoryPrivacyPreferences(placeNameLookup: lookup),
      sessionRepository: DriftSessionRepository(database),
      firstRun: InMemoryFirstRun(done: true),
      clock: FixedClock(DateTime.utc(2026, 12, 15, 17)),
    );
    await vm.ready;
    return vm;
  }

  group('the label', () {
    test(
      'a typed or picked unsaved position, before and after a restart',
      () async {
        final vm = await open();
        expect(SiteLabel.of(vm.site), isNull, reason: 'no site set');
        await vm.site.setLocation(46.05, 14.51);
        expect(SiteLabel.of(vm.site), unsaved);
        expect(
          SiteLabel.of(vm.site, withCoordinates: false),
          SiteLabel.unsaved,
        );

        final restarted = await open();
        expect((restarted.latitude, restarted.longitude), (46.05, 14.51));
        expect(SiteLabel.of(restarted.site), unsaved);
      },
    );

    test('a GPS position used as the current one, then restarted', () async {
      gps = FakeLocationService(
        location: const DeviceLocation(latitude: 46.05, longitude: 14.51),
      );
      final vm = await open();
      await vm.site.useCurrentLocation();
      expect(SiteLabel.of(vm.site), unsaved);
      expect(gps.calls, 1);

      final restarted = await open();
      expect(gps.calls, 1, reason: 'no GPS request on a restart');
      expect(SiteLabel.of(restarted.site), unsaved);
    });

    test('a looked-up name is the label, with its attribution', () async {
      final vm = await open(
        lookup: true,
        geocoder: FakeReverseGeocoder(
          result: const PlaceNameFound('Ljubljana', attribution: '© OSM'),
        ),
      );
      await vm.site.setLocation(46.05, 14.51);
      await Future<void>.delayed(Duration.zero);
      expect(SiteLabel.of(vm.site), 'Ljubljana');
      expect(vm.locationNameAttribution, isNotNull);
    });

    test('a saved site keeps its name', () async {
      final vm = await open();
      await vm.site.saveSite(
        LocationProfile(
          id: 0,
          name: 'Hilltop',
          latitude: 46.05,
          longitude: 14.51,
          timeZoneId: 'Europe/Ljubljana',
        ),
      );
      expect(SiteLabel.of(vm.site), 'Hilltop');
      final restarted = await open();
      expect(SiteLabel.of(restarted.site), 'Hilltop');
    });
  });

  // The four places that show it, after a restart with the lookup off.
  testWidgets('Home, the planner, Welcome and Sites never say "Current '
      'position"', (tester) async {
    late PlannerHarness vm;
    await tester.runAsync(() async {
      final before = await open();
      await before.site.setLocation(46.05, 14.51);
      vm = await open();
    });
    AppRouter.router.go(AppRouter.tonight);
    await tester.pumpWidget(
      MultiProvider(providers: vm.providers, child: const AstroPlanApp()),
    );

    Future<void> settle() async {
      for (var i = 0; i < 6; i++) {
        await tester.runAsync(() => Future<void>.delayed(Duration.zero));
        await tester.pump(const Duration(milliseconds: 200));
      }
    }

    String siteText() => tester
        .widgetList<Text>(
          find.descendant(
            of: find.byKey(const Key('context.site')),
            matching: find.byType(Text),
          ),
        )
        .map((t) => t.data ?? t.textSpan?.toPlainText() ?? '')
        .join();

    await settle();
    expect(siteText(), contains(unsaved), reason: 'Home');
    expect(find.textContaining('Current position'), findsNothing);

    unawaited(AppRouter.router.push(AppRouter.session()));
    await settle();
    expect(siteText(), contains(unsaved), reason: 'the planner');
    expect(find.textContaining('Current position'), findsNothing);

    AppRouter.router.go(AppRouter.welcome);
    await settle();
    expect(
      find.descendant(
        of: find.byKey(const Key('welcome.site')),
        matching: find.text(unsaved),
      ),
      findsOneWidget,
      reason: 'Welcome',
    );
    expect(find.textContaining('Current position'), findsNothing);

    AppRouter.router.go(AppRouter.librarySites);
    await settle();
    expect(find.text(SiteLabel.unsaved), findsOneWidget, reason: 'Sites');
    expect(find.text('46.0500, 14.5100'), findsOneWidget);
    expect(find.textContaining('Current position'), findsNothing);
  });
}
