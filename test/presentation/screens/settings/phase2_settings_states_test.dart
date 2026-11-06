import 'dart:async';

import 'package:astroplan/core/units/display_units.dart';
import 'package:astroplan/domain/models/planning_preferences.dart';
import 'package:astroplan/domain/repositories/display_preferences_repository.dart';
import 'package:astroplan/domain/repositories/display_settings_repository.dart';
import 'package:astroplan/domain/repositories/planning_preferences_repository.dart';
import 'package:astroplan/domain/repositories/privacy_preferences_repository.dart';
import 'package:astroplan/domain/repositories/storage_failure.dart';
import 'package:astroplan/domain/services/opt_in_reverse_geocoder.dart';
import 'package:astroplan/presentation/screens/settings/settings_screen.dart';
import 'package:astroplan/presentation/screens/settings/settings_parts.dart';
import 'package:astroplan/presentation/shared/hybrid_parts.dart';
import 'package:astroplan/presentation/viewmodels/display_settings_viewmodel.dart';
import 'package:astroplan/presentation/viewmodels/disclosure_viewmodel.dart';
import 'package:astroplan/presentation/viewmodels/settings_viewmodel.dart';
import 'package:astroplan/presentation/viewmodels/theme_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../../support/fake_reverse_geocoder.dart';
import '../../../support/phase2_state_capture.dart';
import '../../../support/wave1_capture.dart';

class _Planning implements PlanningPreferencesRepository {
  PlanningPreferences stored = PlanningPreferences();
  Completer<void>? gate;
  bool fail = false;
  int writes = 0;
  @override
  Future<PlanningPreferences> load() async => stored;
  @override
  Future<bool> lastSaveIncomplete() async => false;
  @override
  Future<void> save(PlanningPreferences p) async {
    writes++;
    if (gate case final held?) await held.future;
    if (fail) throw const StorageFailure('save planning fixture');
    stored = p;
  }
}

class _Privacy implements PrivacyPreferencesRepository {
  bool stored = false;
  bool fail = false;
  Completer<void>? gate;
  @override
  Future<bool> loadPlaceNameLookup() async => stored;
  @override
  Future<void> savePlaceNameLookup(bool value) async {
    if (gate case final held?) await held.future;
    if (fail) throw const StorageFailure('save consent fixture');
    stored = value;
  }
}

class _Display implements DisplaySettingsRepository {
  DisplaySettings stored = const DisplaySettings();
  bool fail = false;
  Completer<void>? gate;
  @override
  Future<DisplaySettings> load() async => stored;
  @override
  Future<bool> lastSaveIncomplete() async => false;
  @override
  Future<void> save(DisplaySettings value) async {
    if (gate case final held?) await held.future;
    if (fail) throw const StorageFailure('save display fixture');
    stored = value;
  }
}

class _Mode implements DisplayPreferencesRepository {
  _Mode(this.field);
  bool field;
  @override
  Future<bool> loadFieldMode() async => field;
  @override
  Future<void> saveFieldMode(bool value) async => field = value;
  @override
  Future<Map<String, bool>> loadSectionStates() async => {};
  @override
  Future<void> saveSectionState(String key, bool open) async {}
}

void main() {
  setUpAll(loadWave1Font);
  for (final theme in ['light', 'dark', 'field']) {
    late _Planning plans;
    late _Privacy privacy;
    late _Display display;
    late SettingsViewModel settings;
    late DisplaySettingsViewModel displayVm;
    late ThemeViewModel mode;

    Future<void> host(
      WidgetTester t,
      SettingsSection? section, {
      bool lookup = false,
    }) async {
      t.view.physicalSize = const Size(375, 900);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      plans = _Planning();
      privacy = _Privacy()..stored = lookup;
      display = _Display();
      settings = SettingsViewModel(
        plans,
        privacy,
        OptInReverseGeocoder(FakeReverseGeocoder()),
      );
      displayVm = DisplaySettingsViewModel(display);
      mode = ThemeViewModel(_Mode(theme == 'field'));
      final disclosure = DisclosureViewModel(_Mode(theme == 'field'));
      await settings.load();
      await displayVm.load();
      await mode.load();
      await disclosure.load();
      addTearDown(settings.dispose);
      addTearDown(displayVm.dispose);
      addTearDown(mode.dispose);
      addTearDown(disclosure.dispose);
      await t.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: settings),
            ChangeNotifierProvider.value(value: displayVm),
            ChangeNotifierProvider.value(value: mode),
            ChangeNotifierProvider.value(value: disclosure),
          ],
          child: MaterialApp(
            theme: phase2Theme(theme),
            builder: (_, child) => phase2Frame(theme: theme, child: child!),
            home: SettingsScreen(section: section),
          ),
        ),
      );
      await t.pumpAndSettle();
    }

    Future<void> capture(WidgetTester t, String state) =>
        capturePhase2State(t, package: 'package4', state: state, theme: theme);
    Future<void> tap(WidgetTester t, String key) async {
      final target = find.byKey(Key(key));
      if (target.evaluate().isEmpty) {
        final page = find
            .byWidgetPredicate(
              (widget) =>
                  widget is Scrollable &&
                  widget.axisDirection == AxisDirection.down,
            )
            .first;
        t.state<ScrollableState>(page).position.jumpTo(0);
        await t.pumpAndSettle();
        if (target.evaluate().isEmpty) {
          await t.scrollUntilVisible(target, 250, scrollable: page);
        }
      }
      await t.ensureVisible(target);
      await t.pumpAndSettle();
      await t.tap(target);
      await t.pump();
    }

    testWidgets('Phase2 privacy consent held, failure and retry $theme', (
      t,
    ) async {
      await host(t, SettingsSection.privacy);
      expect(settings.placeNameLookup, isFalse);
      expect(find.text(SettingsScreen.privacyText), findsNothing);
      await capture(t, 'privacy-off');
      privacy.gate = Completer<void>();
      await tap(t, 'settings.placeNames');
      expect(
        settings.placeNameLookup,
        isFalse,
        reason: 'On requires stored consent',
      );
      await capture(t, 'privacy-on-write-pending-stays-off');
      privacy.fail = true;
      privacy.gate!.complete();
      await t.pumpAndSettle();
      expect(settings.placeNameLookup, isFalse);
      expect(find.textContaining("Couldn't save"), findsOneWidget);
      await capture(t, 'privacy-on-write-failed-stays-off');
      privacy.fail = false;
      privacy.gate = null;
      await tap(t, 'settings.placeNames');
      await t.pumpAndSettle();
      expect(settings.placeNameLookup, isTrue);
      await capture(t, 'privacy-on-stored');
      await tap(t, 'settings.privacyApp');
      await t.pumpAndSettle();
      expect(find.text(SettingsScreen.privacyText), findsOneWidget);
      await capture(t, 'privacy-disclosure-open');
    });

    testWidgets(
      'Phase2 privacy Off is immediate and unsaved Retry recovers $theme',
      (t) async {
        await host(t, SettingsSection.privacy, lookup: true);
        privacy.gate = Completer<void>();
        privacy.fail = true;
        await tap(t, 'settings.placeNames');
        expect(
          settings.placeNameLookup,
          isFalse,
          reason: 'Off stops transmission immediately',
        );
        expect(privacy.stored, isTrue);
        await capture(t, 'privacy-off-pending-stored-on');
        privacy.gate!.complete();
        await t.pumpAndSettle();
        expect(
          find.byKey(const Key('settings.placeNames.unsaved')),
          findsOneWidget,
        );
        await capture(t, 'privacy-off-unsaved');
        privacy.fail = false;
        privacy.gate = null;
        await tap(t, 'settings.placeNames.retry');
        await t.pumpAndSettle();
        expect(privacy.stored, isFalse);
        expect(
          find.byKey(const Key('settings.placeNames.unsaved')),
          findsNothing,
        );
        await capture(t, 'privacy-off-retry-stored');
      },
    );

    testWidgets('Phase2 appearance unsaved choices and Retry $theme', (
      t,
    ) async {
      await host(t, SettingsSection.appearance);
      await capture(t, 'appearance-default');
      display.gate = Completer<void>();
      display.fail = true;
      await tap(t, 'settings.appearance.dark');
      expect(displayVm.appearance, Appearance.dark);
      expect(displayVm.saving, isTrue);
      await capture(t, 'appearance-write-pending');
      display.gate!.complete();
      await t.pumpAndSettle();
      expect(displayVm.unsaved, isTrue);
      await t.ensureVisible(find.byKey(const Key('settings.display.unsaved')));
      await t.pumpAndSettle();
      await capture(t, 'appearance-write-failed');
      display.fail = false;
      display.gate = null;
      await tap(t, 'settings.display.retry');
      await t.pumpAndSettle();
      expect(displayVm.unsaved, isFalse);
      expect(display.stored.appearance, Appearance.dark);
      await capture(t, 'appearance-retry-stored');
      for (final unit in TemperatureUnit.values) {
        await tap(t, 'settings.units.temperature.${unit.name}');
        await t.pumpAndSettle();
        expect(displayVm.units.temperature, unit);
        await capture(t, 'appearance-temperature-${unit.name}');
      }
      for (final unit in WindUnit.values) {
        await tap(t, 'settings.units.wind.${unit.name}');
        await t.pumpAndSettle();
        expect(displayVm.units.wind, unit);
        await capture(t, 'appearance-wind-${unit.name}');
      }
      for (final unit in ElevationUnit.values) {
        await tap(t, 'settings.units.elevation.${unit.name}');
        await t.pumpAndSettle();
        expect(displayVm.units.elevation, unit);
        await capture(t, 'appearance-elevation-${unit.name}');
      }
      for (final view in WeatherView.values) {
        await tap(t, 'settings.weatherView.${view.name}');
        await t.pumpAndSettle();
        expect(displayVm.weatherView, view);
        await capture(t, 'appearance-weather-${view.name}');
      }
    });

    testWidgets('Phase2 advanced controls at 200 percent $theme', (t) async {
      t.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
      await host(t, SettingsSection.planning);
      await tap(t, 'settings.advanced');
      await t.pumpAndSettle();
      for (final key in [
        'moonGate',
        'cloudGate',
        'dither',
        'refocus',
        'filterChange',
        'flip',
        'setup',
      ]) {
        final control = find.descendant(
          of: find.byKey(Key('settings.$key')),
          matching: find.byType(HybridSwitch),
        );
        await t.ensureVisible(control);
        await t.pumpAndSettle();
        await t.tap(control);
        await t.pumpAndSettle();
        expect(t.widget<HybridSwitch>(control).value, isTrue);
        expect(
          settings.planningPreferences,
          plans.stored,
          reason: 'Editor draft must stay local',
        );
        await capture(t, 'planning-advanced-$key-enabled-text200');
      }
      for (final limit in DarknessLimit.values) {
        await tap(t, 'settings.darknessLimit.${limit.name}');
        await t.pumpAndSettle();
        await capture(t, 'planning-darkness-${limit.name}-text200');
      }
      final expected = <String, double>{};
      for (final key in [
        'refocus.every',
        'refocus.duration',
        'filterChange.seconds',
        'flip.seconds',
        'setup.minutes',
      ]) {
        final field = find.byKey(Key('settings.$key'));
        if (field.evaluate().isEmpty) {
          final page = find
              .byWidgetPredicate(
                (widget) =>
                    widget is Scrollable &&
                    widget.axisDirection == AxisDirection.down,
              )
              .first;
          t.state<ScrollableState>(page).position.jumpTo(0);
          await t.pumpAndSettle();
          await t.scrollUntilVisible(field, 250, scrollable: page);
        }
        await t.ensureVisible(field);
        await t.pumpAndSettle();
        final before = t.widget<SettingsStepper>(field);
        expected[key] = before.value + before.step;
        await t.tap(
          find.descendant(
            of: field,
            matching: find.byTooltip('${before.label}: more'),
          ),
        );
        await t.pumpAndSettle();
        expect(t.widget<SettingsStepper>(field).value, expected[key]);
        await capture(t, 'planning-edited-${key.replaceAll('.', '-')}-text200');
      }
      for (final key in ['npfK', 'dewMargin']) {
        final field = find.byKey(Key('settings.$key'));
        if (field.evaluate().isEmpty) {
          await t.scrollUntilVisible(
            field,
            250,
            scrollable: find.byType(Scrollable).first,
          );
        }
        await t.ensureVisible(field);
        await t.pumpAndSettle();
        final slider = find.descendant(
          of: field,
          matching: find.byType(Slider),
        );
        await t.drag(slider, const Offset(2000, 0));
        await t.pumpAndSettle();
        await capture(t, 'planning-guidance-$key-edited-text200');
      }
      await tap(t, 'settings.savePlanning');
      await t.pumpAndSettle();
      expect(plans.stored.refocusEveryMinutes, expected['refocus.every']);
      expect(plans.stored.refocusSeconds, expected['refocus.duration']);
      expect(
        plans.stored.filterChangeSeconds,
        expected['filterChange.seconds'],
      );
      expect(plans.stored.meridianFlipSeconds, expected['flip.seconds']);
      expect(plans.stored.setupMinutes, expected['setup.minutes']);
      expect(plans.stored.npfK, PlanningPreferences.npfKRange.$2);
      expect(plans.stored.dewMarginC, PlanningPreferences.dewMarginRange.$2);
      expect(settings.planningPreferences, plans.stored);
      expect(t.takeException(), isNull);
    });

    testWidgets('Phase2 bounded stepper disables endpoints $theme', (t) async {
      t.view.physicalSize = const Size(375, 812);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      var value = 1.0;
      await t.pumpWidget(
        MaterialApp(
          theme: phase2Theme(theme),
          builder: (_, child) => phase2Frame(theme: theme, child: child!),
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(24),
              child: StatefulBuilder(
                builder: (_, update) => SettingsStepper(
                  label: 'Frames',
                  value: value,
                  range: (1, 3),
                  step: 1,
                  format: (v) => '${v.round()} frames',
                  onChanged: (next) => update(() => value = next),
                ),
              ),
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      OutlinedButton button(String direction) => t.widget<OutlinedButton>(
        find.descendant(
          of: find.byTooltip('Frames: $direction'),
          matching: find.byType(OutlinedButton),
        ),
      );
      expect(button('less').onPressed, isNull);
      expect(button('more').onPressed, isNotNull);
      await capture(t, 'settings-stepper-minimum-disabled');
      await t.tap(find.byTooltip('Frames: more'));
      await t.pumpAndSettle();
      expect(value, 2);
      expect(button('less').onPressed, isNotNull);
      expect(button('more').onPressed, isNotNull);
      await capture(t, 'settings-stepper-middle');
      await t.tap(find.byTooltip('Frames: more'));
      await t.pumpAndSettle();
      expect(value, 3);
      expect(button('more').onPressed, isNull);
      expect(button('less').onPressed, isNotNull);
      await capture(t, 'settings-stepper-maximum-disabled');
    });

    testWidgets(
      'Phase2 index shows current appearance units and text percent $theme',
      (t) async {
        t.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
        await host(t, null);
        final appearance = find.byKey(const Key('settings.open.appearance'));
        expect(
          find.descendant(
            of: appearance,
            matching: find.textContaining('text 200%'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: appearance,
            matching: find.textContaining(
              theme == 'field' ? 'Red field mode' : 'System',
            ),
          ),
          findsOneWidget,
        );
        final changed = displayVm.units.copyWith(
          temperature: TemperatureUnit.fahrenheit,
          wind: WindUnit.values.last,
          elevation: ElevationUnit.values.last,
        );
        await displayVm.setUnits(changed);
        await displayVm.setAppearance(Appearance.dark);
        await t.pumpAndSettle();
        final summary = t
            .widget<Text>(
              find.descendant(of: appearance, matching: find.byType(Text)).last,
            )
            .data!;
        expect(summary, contains(theme == 'field' ? 'Red field mode' : 'Dark'));
        expect(summary, contains('text 200%'));
        expect(summary, contains(changed.temperature.symbol));
        expect(summary, contains(changed.wind.symbol));
        expect(summary, contains(changed.elevation.symbol));
        await capture(t, 'settings-index-current-values-text200');
        await tap(t, 'settings.open.appearance');
        await t.pumpAndSettle();
        final textSize = find.byKey(const Key('settings.textSize'));
        await t.ensureVisible(textSize);
        await t.pumpAndSettle();
        expect(
          find.descendant(
            of: textSize,
            matching: find.textContaining(
              'Text follows Android’s font size (now 200%)',
            ),
          ),
          findsOneWidget,
        );
        await capture(t, 'appearance-system-text-size-readout-text200');
        await t.pageBack();
        await t.pumpAndSettle();
        await tap(t, 'settings.open.planning');
        await t.pumpAndSettle();
        expect(find.text('No changes'), findsOneWidget);
        expect(
          t
              .widget<FilledButton>(
                find.byKey(const Key('settings.savePlanning')),
              )
              .onPressed,
          isNotNull,
        );
        await tap(t, 'settings.savePlanning');
        await t.pumpAndSettle();
        expect(plans.writes, 0);
        expect(settings.planningPreferences, plans.stored);
        expect(
          find.byKey(const Key('settings.preferencesGroup')),
          findsOneWidget,
        );
        await capture(t, 'planning-clean-save-no-op-return');
      },
    );

    testWidgets('Phase2 planning pending failure Retry and guard $theme', (
      t,
    ) async {
      await host(t, SettingsSection.planning);
      await capture(t, 'planning-clean-default');
      final slider = find.descendant(
        of: find.byKey(const Key('settings.perFrame')),
        matching: find.byType(Slider),
      );
      t.widget<Slider>(slider).onChanged!(15);
      await t.pump();
      expect(settings.planningPreferences.perFrameOverheadSeconds, 5);
      expect(find.text('Changed · not saved'), findsOneWidget);
      await capture(t, 'planning-local-draft');
      plans.gate = Completer<void>();
      plans.fail = true;
      final staleSave = t
          .widget<FilledButton>(find.byKey(const Key('settings.savePlanning')))
          .onPressed!;
      await tap(t, 'settings.savePlanning');
      expect(find.text('Saving…'), findsOneWidget);
      await t.binding.handlePopRoute();
      await t.pump();
      expect(find.text('Discard your changes?'), findsNothing);
      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(
        t
            .widget<OutlinedButton>(
              find.byKey(const Key('settings.cancelPlanning')),
            )
            .onPressed,
        isNull,
      );
      staleSave();
      await t.pump();
      expect(
        plans.writes,
        1,
        reason: 'A stale Save callback cannot reenter a held write',
      );
      await capture(t, 'planning-save-pending');
      plans.gate!.complete();
      await t.pumpAndSettle();
      expect(settings.planningPreferences.perFrameOverheadSeconds, 15);
      expect(settings.planningPreferencesUnsaved, isTrue);
      await t.ensureVisible(find.byKey(const Key('settings.unsaved')));
      await t.pumpAndSettle();
      await capture(t, 'planning-applied-unsaved');
      plans.fail = false;
      plans.gate = null;
      await tap(t, 'settings.retry');
      await t.pumpAndSettle();
      expect(plans.stored.perFrameOverheadSeconds, 15);
      expect(find.byKey(const Key('settings.unsaved')), findsNothing);
      await capture(t, 'planning-retry-stored');
      await t.ensureVisible(slider);
      t.widget<Slider>(slider).onChanged!(20);
      await t.pump();
      await tap(t, 'settings.cancelPlanning');
      await t.pumpAndSettle();
      expect(find.text('Discard your changes?'), findsOneWidget);
      await capture(t, 'planning-discard-confirmation');
      await tap(t, 'confirm.cancel');
      await t.pumpAndSettle();
      expect(plans.stored.perFrameOverheadSeconds, 15);
      expect(t.widget<Slider>(slider).value, 20);
    });
  }
}
