// F21 A2/A4/A5 (S16.6, PD-20; D1 = A): Settings offers Appearance (System
// by default, also on a new install) and units; a choice applies to the
// app at once, persists, survives a restart and changes what is shown (the
// dew margin as a difference; a result's temperature as typed), never a
// stored value. Field mode keeps its red theme whatever the Appearance. A
// choice or a planning edit that cannot be stored stays shown, marked
// unsaved, with Retry.

import 'package:astroplan/core/theme/app_theme.dart';
import 'package:astroplan/core/units/display_units.dart';
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/repositories/shared_prefs_display_settings_repository.dart';
import 'package:astroplan/domain/models/planning_preferences.dart';
import 'package:astroplan/domain/repositories/display_settings_repository.dart';
import 'package:astroplan/domain/repositories/planning_preferences_repository.dart';
import 'package:astroplan/domain/repositories/storage_failure.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/fake_location_service.dart';
import '../../../support/no_snapshot_weather.dart';
import '../../../support/planner_harness.dart';

class _NoWeather with NoSnapshotWeather implements WeatherRepository {}

/// A display store that refuses writes until [fail] is cleared.
class _FlakyDisplay extends SharedPrefsDisplaySettingsRepository {
  bool fail = true;
  @override
  Future<void> save(DisplaySettings settings) async {
    if (fail) throw const StorageFailure('save the display settings');
    return super.save(settings);
  }
}

class _FlakyPlanning implements PlanningPreferencesRepository {
  PlanningPreferences stored = PlanningPreferences();
  bool fail = true;
  @override
  Future<PlanningPreferences> load() async => stored;
  @override
  Future<void> save(PlanningPreferences p) async {
    if (fail) throw const StorageFailure('save the planning preferences');
    stored = p;
  }

  @override
  Future<bool> lastSaveIncomplete() async => false;
}

void main() {
  late AppDatabase database;
  late PlannerHarness vm;

  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> start(
    WidgetTester tester, {
    DisplaySettingsRepository? display,
    PlanningPreferencesRepository? planning,
    String section = 'appearance',
  }) async {
    // A restart discards the previous native settings subpage as well.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    tester.view.physicalSize = const Size(800, 5000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      database = AppDatabase(NativeDatabase.memory());
      vm = PlannerHarness(
        DriftTargetRepository(database),
        DriftEquipmentRepository(database),
        _NoWeather(),
        DriftLocationRepository(database),
        locationService: FakeLocationService(),
        displaySettings: display,
        preferencesRepository: planning,
      );
      await vm.ready;
      await vm.vms.displaySettings.load(); // as main does
    });
    addTearDown(() => tester.runAsync(database.close));
    AppRouter.router.go(AppRouter.settings);
    await tester.pumpWidget(
      MultiProvider(providers: vm.providers, child: const AstroPlanApp()),
    );
    await settle(tester);
    await tester.tap(find.byKey(Key('settings.open.$section')));
    await settle(tester);
  }

  MaterialApp app(WidgetTester tester) =>
      tester.widget<MaterialApp>(find.byType(MaterialApp));

  Future<void> tapText(WidgetTester tester, String key, String label) async {
    final f = find.descendant(
      of: find.byKey(Key(key)),
      matching: find.text(label),
    );
    await tester.ensureVisible(f);
    await tester.tap(f);
    await settle(tester);
  }

  testWidgets('A4: System by default on a new install; Dark and Light apply '
      'at once and survive a restart; field mode stays red', (tester) async {
    await start(tester);
    expect(app(tester).themeMode, ThemeMode.system);
    await tapText(tester, 'settings.appearance', 'Dark');
    expect(app(tester).themeMode, ThemeMode.dark);
    await tester.runAsync(() => vm.vms.displaySettings.idle);
    final stored = await tester.runAsync(
      () => SharedPrefsDisplaySettingsRepository().load(),
    );
    expect(stored!.appearance, Appearance.dark);

    await tester.runAsync(() => vm.vms.theme.toggleFieldMode());
    await settle(tester);
    expect(app(tester).darkTheme, AppTheme.fieldTheme);
    expect(app(tester).theme, AppTheme.fieldTheme);
    await tester.runAsync(() => vm.vms.theme.toggleFieldMode());
    await settle(tester);

    await tapText(tester, 'settings.appearance', 'Light');
    expect(app(tester).themeMode, ThemeMode.light);
    expect(app(tester).theme, AppTheme.light);
    await tester.runAsync(() => vm.vms.displaySettings.idle);

    // A restart reads the stored choice.
    await start(tester);
    expect(app(tester).themeMode, ThemeMode.light);
  });

  testWidgets('A2/A3: °F shows the dew margin as a difference and a typed '
      'temperature in °F; the stored margin stays in °C', (tester) async {
    await start(tester);
    final margin = vm.settings.planningPreferences.dewMarginC;
    await tapText(tester, 'settings.units.temperature', '°F');
    expect(vm.settings.planningPreferences.dewMarginC, margin);
    await tapText(tester, 'settings.units.wind', 'mph');
    await tapText(tester, 'settings.units.elevation', 'ft');
    await tester.runAsync(() => vm.vms.displaySettings.idle);
    final p = await tester.runAsync(SharedPreferences.getInstance);
    expect(p!.getString('units.temperature'), 'fahrenheit');
    expect(p.getString('units.wind'), 'mph');
    expect(p.getString('units.elevation'), 'feet');
    expect(p.getDouble('dewPointThreshold'), isNull, reason: 'not rewritten');
    await tester.pageBack();
    await settle(tester);
    await tester.tap(find.byKey(const Key('settings.open.planning')));
    await settle(tester);
    expect(
      find.text('${(margin * 9 / 5).toStringAsFixed(1)} °F'),
      findsOneWidget,
      reason: 'a difference: × 9/5, no +32',
    );
  });

  testWidgets('A5: a unit choice that cannot be stored stays shown, marked '
      'unsaved; Retry stores it', (tester) async {
    final display = _FlakyDisplay();
    await start(tester, display: display);
    await tapText(tester, 'settings.units.temperature', '°F');
    expect(
      vm.vms.displaySettings.units.temperature,
      TemperatureUnit.fahrenheit,
    );
    expect(find.byKey(const Key('settings.display.unsaved')), findsOneWidget);
    expect(
      find.textContaining("Couldn't save the display setting"),
      findsOneWidget,
    );
    await tester.ensureVisible(find.byKey(const Key('settings.display.retry')));
    await tester.pump();
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    display.fail = false;
    await tester.ensureVisible(find.byKey(const Key('settings.display.retry')));
    await tester.tap(find.byKey(const Key('settings.display.retry')));
    await settle(tester);
    expect(find.byKey(const Key('settings.display.unsaved')), findsNothing);
    final stored = await tester.runAsync(() => display.load());
    expect(stored!.units.temperature, TemperatureUnit.fahrenheit);
  });

  testWidgets('A5: a planning edit that cannot be stored stays applied, the '
      'screen says it is not saved; Retry stores the newest', (tester) async {
    final planning = _FlakyPlanning();
    await start(tester, planning: planning, section: 'planning');
    await tester.ensureVisible(find.text('−12°'));
    await tester.tap(find.text('−12°'));
    await settle(tester);
    expect(
      vm.settings.planningPreferences.darknessLimit,
      DarknessLimit.astronomical,
    );
    expect(planning.stored.darknessLimit, DarknessLimit.astronomical);
    await tester.tap(find.byKey(const Key('settings.savePlanning')));
    await settle(tester);
    expect(
      vm.settings.planningPreferences.darknessLimit,
      DarknessLimit.nautical,
    );
    expect(find.byKey(const Key('settings.unsaved')), findsOneWidget);
    expect(planning.stored.darknessLimit, DarknessLimit.astronomical);
    // Its text and its Retry are readable on the error colour.
    await tester.ensureVisible(find.byKey(const Key('settings.retry')));
    await tester.pump();
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    planning.fail = false;
    await tester.ensureVisible(find.byKey(const Key('settings.retry')));
    await tester.tap(find.byKey(const Key('settings.retry')));
    await settle(tester);
    expect(find.byKey(const Key('settings.unsaved')), findsNothing);
    expect(planning.stored.darknessLimit, DarknessLimit.nautical);
  });
}

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump(const Duration(milliseconds: 200));
  }
}
