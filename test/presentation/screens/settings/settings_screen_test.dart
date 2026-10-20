import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/models/planning_preferences.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/presentation/screens/settings/settings_screen.dart';
import 'package:astroplan/presentation/screens/library/library_screen.dart';
import 'package:astroplan/presentation/screens/logbook/logbook_screen.dart';

import '../../../support/planner_harness.dart';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/fake_location_service.dart';
import '../../../support/no_snapshot_weather.dart';

class _NoWeather with NoSnapshotWeather implements WeatherRepository {}

void main() {
  late AppDatabase database;
  late PlannerHarness vm;

  Future<void> pump(WidgetTester tester, {String? section = 'planning'}) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MultiProvider(
        providers: vm.providers,
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pump();
    if (section != null) {
      await tester.tap(find.byKey(Key('settings.open.$section')));
      await tester.pumpAndSettle();
    }
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> build(WidgetTester tester) async {
    await tester.runAsync(() async {
      database = AppDatabase(NativeDatabase.memory());
      vm = PlannerHarness(
        DriftTargetRepository(database),
        DriftEquipmentRepository(database),
        _NoWeather(),
        DriftLocationRepository(database),
        locationService: FakeLocationService(),
      );
      await vm.ready;
    });
    addTearDown(() => tester.runAsync(database.close));
  }

  testWidgets(
    'all workspace roots expose the same persistent field-mode action',
    (tester) async {
      await build(tester);
      for (final screen in const [
        SettingsScreen(),
        LibraryScreen(),
        LogbookScreen(),
      ]) {
        await tester.pumpWidget(
          MultiProvider(
            providers: vm.providers,
            child: MaterialApp(home: screen),
          ),
        );
        await tester.pump();
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pump();
        final previous = vm.theme.isFieldMode;
        await tester.tap(find.byKey(const Key('fieldMode.toggle')));
        await tester.pump();
        expect(vm.theme.isFieldMode, !previous);
      }
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('Planning summary names the actual Sun darkness limit', (
    tester,
  ) async {
    await build(tester);
    await pump(tester, section: null);
    expect(find.textContaining('18° Sun'), findsOneWidget);
  });

  testWidgets('shows defaults, and off overheads as "Not included"', (
    tester,
  ) async {
    await build(tester);
    await pump(tester);
    expect(find.text('20°'), findsOneWidget);
    expect(find.text('15 %'), findsOneWidget);
    expect(find.text('5 s'), findsOneWidget);
    // F12 (AM-01): the optional times are in the collapsed advanced group,
    // whose summary counts them.
    expect(
      find.text('Gates: 0 of 2 on · optional times: 0 of 5 included'),
      findsOneWidget,
    );
    expect(find.text('Not included'), findsNothing);
    await tester.tap(find.byKey(const Key('settings.advanced')));
    await tester.pumpAndSettle();
    expect(find.text('Not included'), findsNWidgets(5));
    expect(find.textContaining('not scientific laws'), findsOneWidget);
    // S1.8 (UX-20): overheads are applied since TASK 5.4.
    expect(
      find.textContaining("added to the capture plan's budget"),
      findsOneWidget,
    );
    expect(find.textContaining('later update'), findsNothing);
  });

  // S3.7 (ADR-018 §7): the import moved to the equipment screen.
  testWidgets('Settings no longer has an Import metadata entry', (
    tester,
  ) async {
    await build(tester);
    await pump(tester, section: null);
    expect(find.text('Import metadata'), findsNothing);
    expect(find.text('About & data sources'), findsOneWidget);
  });

  // TASK 16.3: place names are opt-in, and the switch says what is sent.
  testWidgets('the place-name switch turns lookups on', (tester) async {
    await build(tester);
    await tester.runAsync(() => vm.settings.setPlaceNameLookup(false));
    await pump(tester, section: 'privacy');
    final tile = find.byKey(const Key('settings.placeNames'));
    await tester.ensureVisible(tile);
    expect(find.textContaining('OpenStreetMap Nominatim'), findsOneWidget);
    expect(tester.widget<SwitchListTile>(tile).value, isFalse);
    await tester.tap(tile);
    await tester.pump();
    // F21 A6: On applies once it is stored, not before.
    await tester.runAsync(() => pumpEventQueue());
    await tester.pump();
    expect(vm.settings.placeNameLookup, isTrue);
    expect(tester.widget<SwitchListTile>(tile).value, isTrue);
  });

  testWidgets(
    'moving a slider stays local until Save, then persists and reopens',
    (tester) async {
      await build(tester);
      await pump(tester);
      final slider = find.descendant(
        of: find.byKey(const Key('settings.minAltitude')),
        matching: find.byType(Slider),
      );
      // Drag to the far right: the range maximum (60°).
      await tester.drag(slider, const Offset(2000, 0));
      await tester.pump();
      expect(vm.minAltitude, 20.0);
      expect(find.text('Changed · not saved'), findsOneWidget);
      await tester.tap(find.byKey(const Key('settings.savePlanning')));
      await tester.runAsync(() => pumpEventQueue());
      await tester.pumpAndSettle();
      expect(vm.minAltitude, 60.0);
      expect(find.text('Preferences'), findsOneWidget);
      await tester.tap(find.byKey(const Key('settings.open.planning')));
      await tester.pumpAndSettle();
      expect(tester.widget<Slider>(slider).value, 60.0);
      await tester.runAsync(() async {
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getDouble('minAltitude'), 60.0);
      });
    },
  );

  testWidgets('choosing a darkness limit and switching an overhead on', (
    tester,
  ) async {
    await build(tester);
    await pump(tester);
    await tester.tap(find.text('−12°'));
    await tester.pump();
    expect(vm.planningPreferences.darknessLimit, DarknessLimit.astronomical);

    await tester.tap(find.byKey(const Key('settings.advanced')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('settings.dither')),
        matching: find.byType(Switch),
      ),
    );
    await tester.pump();
    expect(vm.planningPreferences.ditherEveryNFrames, isNull);
    expect(find.text('Every 3 lights, 15 s to settle each'), findsOneWidget);
    await tester.tap(find.byKey(const Key('settings.savePlanning')));
    await tester.runAsync(() => pumpEventQueue());
    await tester.pumpAndSettle();
    expect(vm.planningPreferences.darknessLimit, DarknessLimit.nautical);
    expect(vm.planningPreferences.ditherEveryNFrames, 3);
  });
  testWidgets('Hybrid root keeps every settings group reachable with Back', (
    tester,
  ) async {
    await build(tester);
    await pump(tester, section: null);
    expect(find.text('Preferences'), findsOneWidget);
    expect(find.text('Data and about'), findsOneWidget);
    for (final section in ['appearance', 'planning', 'privacy', 'backup']) {
      final entry = find.byKey(Key('settings.open.$section'));
      await tester.ensureVisible(entry);
      await tester.tap(entry);
      await tester.pumpAndSettle();
      expect(find.byType(BackButton), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Preferences'), findsOneWidget);
    }
    expect(find.byKey(const Key('settings.open.about')), findsOneWidget);
  });

  testWidgets('settings groups and controls remain reachable at 200% text', (
    tester,
  ) async {
    await build(tester);
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MultiProvider(
        providers: vm.providers,
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: const SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    for (final section in ['appearance', 'planning', 'privacy', 'backup']) {
      final entry = find.byKey(Key('settings.open.$section'));
      await tester.ensureVisible(entry);
      await tester.tap(entry);
      await tester.pumpAndSettle();
      final scrollable = find.byType(Scrollable).last;
      for (var i = 0; i < 8; i++) {
        await tester.drag(scrollable, const Offset(0, -450));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      if (section == 'planning') {
        expect(
          find.byKey(const Key('settings.savePlanning')).hitTestable(),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('settings.cancelPlanning')).hitTestable(),
          findsOneWidget,
        );
      }
      await tester.pageBack();
      await tester.pumpAndSettle();
    }
  });

  testWidgets(
    'dirty Cancel and Back guard the draft; Discard never applies it',
    (tester) async {
      await build(tester);
      await pump(tester);
      final before = vm.planningPreferences;
      await tester.tap(find.text('−12°'));
      await tester.pump();
      await tester.tap(find.byKey(const Key('settings.cancelPlanning')));
      await tester.pumpAndSettle();
      expect(find.text('Discard your changes?'), findsOneWidget);
      await tester.tap(find.byKey(const Key('confirm.cancel')));
      await tester.pumpAndSettle();
      expect(find.text('Changed · not saved'), findsOneWidget);
      expect(vm.planningPreferences, before);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm.action')));
      await tester.pumpAndSettle();
      expect(find.text('Preferences'), findsOneWidget);
      expect(vm.planningPreferences, before);
      await tester.tap(find.byKey(const Key('settings.open.planning')));
      await tester.pumpAndSettle();
      expect(find.text('No changes'), findsOneWidget);
      expect(vm.planningPreferences, before);
    },
  );
}
