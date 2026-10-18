// F21 A6 (AM-03, CRUX-02): the place-name switch is honest about what is
// stored. After a failed write it never shows a choice other than the stored
// one, unless that choice is visibly unsaved with Retry; while Off is shown
// no position is sent; reload and restart show the stored choice.

import 'dart:async';

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/repositories/privacy_preferences_repository.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/domain/services/reverse_geocoder.dart';
import 'package:astroplan/presentation/screens/settings/settings_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_device_time_zone.dart';
import '../../support/fake_location_service.dart';
import '../../support/fake_reverse_geocoder.dart';
import '../../support/no_snapshot_weather.dart';
import '../../support/planner_harness.dart';

class _NoWeather with NoSnapshotWeather implements WeatherRepository {}

/// Stored privacy choice whose writes can fail or be held by the test.
class _Privacy implements PrivacyPreferencesRepository {
  _Privacy(this.stored);

  bool stored;
  bool failWrites = false;

  /// Writes the test releases by hand (with [hold] on).
  bool hold = false;
  final List<(bool, Completer<void>)> held = [];

  @override
  Future<bool> loadPlaceNameLookup() async => stored;

  @override
  Future<void> savePlaceNameLookup(bool on) async {
    if (hold) {
      final c = Completer<void>();
      held.add((on, c));
      await c.future;
    }
    if (failWrites) throw StateError('disk full (test)');
    stored = on;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late FakeReverseGeocoder geocoder;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    database = AppDatabase(NativeDatabase.memory());
    geocoder = FakeReverseGeocoder(
      result: const PlaceNameFound('Ljubljana', attribution: 'OSM'),
    );
  });
  tearDown(() => database.close());

  Future<PlannerHarness> build(_Privacy privacy) async {
    final vm = PlannerHarness(
      DriftTargetRepository(database),
      DriftEquipmentRepository(database),
      _NoWeather(),
      DriftLocationRepository(database),
      locationService: FakeLocationService(),
      reverseGeocoder: geocoder,
      deviceTimeZone: FakeDeviceTimeZone('Europe/Ljubljana'),
      clock: FixedClock(DateTime.utc(2026, 9, 23, 12)),
      privacyPreferences: privacy,
    );
    await vm.ready;
    await pumpEventQueue();
    return vm;
  }

  test(
    'On that cannot be stored stays Off, says so, and sends nothing',
    () async {
      final privacy = _Privacy(false)..failWrites = true;
      final vm = await build(privacy);
      await vm.setLocation(46.05, 14.51);

      await expectLater(vm.settings.setPlaceNameLookup(true), throwsStateError);
      await pumpEventQueue();
      expect(vm.settings.placeNameLookup, isFalse, reason: 'the stored Off');
      expect(vm.settings.placeNameLookupUnsaved, isFalse);
      expect(geocoder.lookups, isEmpty);

      await vm.setLocation(46.10, 14.60);
      await pumpEventQueue();
      expect(geocoder.lookups, isEmpty, reason: 'still off: nothing sent');
      expect((await build(privacy)).settings.placeNameLookup, isFalse);
    },
  );

  test(
    'while On is being stored nothing is sent; once stored it applies',
    () async {
      final privacy = _Privacy(false)..hold = true;
      final vm = await build(privacy);
      await vm.setLocation(46.05, 14.51);

      final on = vm.settings.setPlaceNameLookup(true);
      await pumpEventQueue();
      expect(vm.settings.placeNameLookup, isFalse);
      expect(geocoder.lookups, isEmpty);

      privacy.held.single.$2.complete();
      await on;
      await pumpEventQueue();
      expect(vm.settings.placeNameLookup, isTrue);
      expect(geocoder.lookups, [(46.05, 14.51)]);
      expect(privacy.stored, isTrue);
    },
  );

  test('Off applies at once; if it cannot be stored it stays Off, marked '
      'unsaved, and Retry stores it', () async {
    final privacy = _Privacy(true);
    final vm = await build(privacy);
    await vm.setLocation(46.05, 14.51);
    await pumpEventQueue();
    geocoder.lookups.clear();
    privacy.failWrites = true;

    await expectLater(vm.settings.setPlaceNameLookup(false), throwsStateError);
    await pumpEventQueue();
    expect(vm.settings.placeNameLookup, isFalse);
    expect(vm.settings.placeNameLookupUnsaved, isTrue);
    expect(privacy.stored, isTrue, reason: 'the stored choice is still On');
    await vm.setLocation(46.10, 14.60);
    await pumpEventQueue();
    expect(geocoder.lookups, isEmpty, reason: 'Off shown: nothing sent');

    privacy.failWrites = false;
    await vm.settings.setPlaceNameLookup(false); // Retry
    expect(vm.settings.placeNameLookupUnsaved, isFalse);
    expect(privacy.stored, isFalse);
    expect((await build(privacy)).settings.placeNameLookup, isFalse);
  });

  test(
    'an unsaved Off is honest across a restart: the stored On returns',
    () async {
      final privacy = _Privacy(true);
      final vm = await build(privacy);
      privacy.failWrites = true;
      await expectLater(
        vm.settings.setPlaceNameLookup(false),
        throwsStateError,
      );
      expect(vm.settings.placeNameLookupUnsaved, isTrue);

      privacy.failWrites = false;
      final restarted = await build(privacy);
      expect(restarted.settings.placeNameLookup, isTrue);
      expect(restarted.settings.placeNameLookupUnsaved, isFalse);
    },
  );

  test('writes run in order and only the newest request decides what is '
      'shown', () async {
    final privacy = _Privacy(false)..hold = true;
    final vm = await build(privacy);
    await vm.setLocation(46.05, 14.51);

    final on = vm.settings.setPlaceNameLookup(true);
    final off = vm.settings.setPlaceNameLookup(false);
    await pumpEventQueue();
    expect(privacy.held, hasLength(1), reason: 'the second waits its turn');
    privacy.held[0].$2.complete();
    await on;
    await pumpEventQueue();
    expect(vm.settings.placeNameLookup, isFalse, reason: 'the newer Off');
    expect(geocoder.lookups, isEmpty);
    privacy.held[1].$2.complete();
    await off;
    expect(privacy.stored, isFalse);
    expect(vm.settings.placeNameLookup, isFalse);
    expect(vm.settings.placeNameLookupUnsaved, isFalse);
  });

  testWidgets('Settings shows an unsaved Off with Retry, and clears it once '
      'stored', (tester) async {
    final privacy = _Privacy(true);
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    late PlannerHarness vm;
    await tester.runAsync(() async => vm = await build(privacy));
    await tester.pumpWidget(
      MultiProvider(
        providers: vm.providers,
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pump();
    final tile = find.byKey(const Key('settings.placeNames'));
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();

    privacy.failWrites = true;
    await tester.tap(find.descendant(of: tile, matching: find.byType(Switch)));
    await tester.runAsync(() => pumpEventQueue());
    await tester.pumpAndSettle();
    expect(tester.widget<SwitchListTile>(tile).value, isFalse);
    expect(
      find.byKey(const Key('settings.placeNames.unsaved')),
      findsOneWidget,
    );
    expect(find.textContaining('save the place-name setting'), findsOneWidget);

    privacy.failWrites = false;
    await tester.ensureVisible(
      find.byKey(const Key('settings.placeNames.retry')),
    );
    await tester.tap(find.byKey(const Key('settings.placeNames.retry')));
    await tester.runAsync(() => pumpEventQueue());
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('settings.placeNames.unsaved')), findsNothing);
    expect(privacy.stored, isFalse);
  });
}
