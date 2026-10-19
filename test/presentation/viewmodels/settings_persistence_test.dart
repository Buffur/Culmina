// F21 A5 (AM-02, UX32): an edit applies at once and is then stored; the
// state says which. A failed write keeps the edit applied and unsaved,
// never reported saved, with Retry of the newest complete configuration.
// Writes run in order and coalesce, so an older completion never marks a
// newer edit saved nor overwrites it; an unrelated field is kept; an
// interrupted multi-key save is reported after a restart. The same rule
// holds for Appearance and units.

import 'dart:async';

import 'package:astroplan/core/units/display_units.dart';
import 'package:astroplan/data/repositories/shared_prefs_display_settings_repository.dart';
import 'package:astroplan/data/repositories/shared_prefs_planning_preferences_repository.dart';
import 'package:astroplan/domain/models/planning_preferences.dart';
import 'package:astroplan/domain/repositories/display_settings_repository.dart';
import 'package:astroplan/domain/repositories/planning_preferences_repository.dart';
import 'package:astroplan/domain/repositories/storage_failure.dart';
import 'package:astroplan/domain/services/opt_in_reverse_geocoder.dart';
import 'package:astroplan/presentation/viewmodels/display_settings_viewmodel.dart';
import 'package:astroplan/presentation/viewmodels/settings_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_reverse_geocoder.dart';
import '../../support/in_memory_privacy_preferences.dart';

/// A store whose writes can be failed, or held one by one ([holding]):
/// each held save waits for its own completer, true to succeed.
class _Store implements PlanningPreferencesRepository {
  PlanningPreferences stored = PlanningPreferences();
  final saves = <PlanningPreferences>[];
  bool fail = false;
  bool holding = false;
  final held = <Completer<bool>>[];

  @override
  Future<PlanningPreferences> load() async => stored;

  @override
  Future<void> save(PlanningPreferences p) async {
    saves.add(p);
    var ok = !fail;
    if (holding) {
      final c = Completer<bool>();
      held.add(c);
      ok = await c.future;
    }
    if (!ok) throw const StorageFailure('save the planning preferences');
    stored = p;
  }

  @override
  Future<bool> lastSaveIncomplete() async => false;
}

class _DisplayStore implements DisplaySettingsRepository {
  DisplaySettings stored = const DisplaySettings();
  final saves = <DisplaySettings>[];
  bool fail = false;
  Completer<void>? hold;

  @override
  Future<DisplaySettings> load() async => stored;

  @override
  Future<void> save(DisplaySettings s) async {
    saves.add(s);
    if (hold case final h?) await h.future;
    if (fail) throw const StorageFailure('save the display settings');
    stored = s;
  }

  @override
  Future<bool> lastSaveIncomplete() async => false;
}

SettingsViewModel _vm(PlanningPreferencesRepository store) => SettingsViewModel(
  store,
  InMemoryPrivacyPreferences(),
  OptInReverseGeocoder(FakeReverseGeocoder()),
);

void main() {
  test('a failed write keeps the edit applied and unsaved; Retry stores the '
      'newest configuration', () async {
    final store = _Store()..fail = true;
    final vm = _vm(store);
    await vm.load();
    final edit = vm.planningPreferences.copyWith(minAltitudeDeg: 40);
    await expectLater(
      vm.setPlanningPreferences(edit),
      throwsA(isA<StorageFailure>()),
    );
    expect(vm.planningPreferences.minAltitudeDeg, 40, reason: 'still applied');
    expect(vm.planningPreferencesUnsaved, isTrue);
    expect(vm.planningPreferencesSaving, isFalse);
    expect(
      store.stored.minAltitudeDeg,
      PlanningPreferences.defaultMinAltitudeDeg,
    );

    store.fail = false;
    await vm.retryPlanningPreferences();
    expect(vm.planningPreferencesUnsaved, isFalse);
    expect(store.stored.minAltitudeDeg, 40);
  });

  test(
    'held writes: they run in order and coalesce; the older completion '
    'never marks the newer edit saved; the newest is what is stored',
    () async {
      final store = _Store()..holding = true;
      final vm = _vm(store);
      await vm.load();
      final p = vm.planningPreferences;
      final a = vm.setPlanningPreferences(p.copyWith(minAltitudeDeg: 30));
      await pumpEventQueue(); // A is writing
      final b = vm.setPlanningPreferences(p.copyWith(minAltitudeDeg: 35));
      final c = vm.setPlanningPreferences(p.copyWith(minAltitudeDeg: 45));
      store.held.removeAt(0).complete(true); // A completes
      await a;
      await pumpEventQueue(); // C starts; B was superseded and skipped
      expect(store.stored.minAltitudeDeg, 30);
      expect(vm.planningPreferencesSaving, isTrue, reason: 'not saved yet');
      expect(vm.planningPreferencesUnsaved, isFalse);
      store.held.removeAt(0).complete(true); // C completes
      await Future.wait([b, c]);
      expect(store.saves.map((s) => s.minAltitudeDeg), [30, 45]);
      expect(store.stored.minAltitudeDeg, 45);
      expect(vm.planningPreferencesSaving, isFalse);
      expect(vm.planningPreferencesUnsaved, isFalse);
    },
  );

  test('an older write that fails while a newer one is queued does not mark '
      'it unsaved; the newer stores both edits', () async {
    final store = _Store()..holding = true;
    final vm = _vm(store);
    await vm.load();
    final p = vm.planningPreferences;
    final a = vm.setPlanningPreferences(p.copyWith(minAltitudeDeg: 30));
    await pumpEventQueue();
    final b = vm.setPlanningPreferences(
      vm.planningPreferences.copyWith(darknessLimit: DarknessLimit.nautical),
    );
    store.held.removeAt(0).complete(false); // A fails
    await expectLater(a, throwsA(isA<StorageFailure>()));
    await pumpEventQueue();
    expect(vm.planningPreferencesUnsaved, isFalse, reason: 'B is pending');
    store.held.removeAt(0).complete(true);
    await b;
    expect(store.stored.minAltitudeDeg, 30, reason: 'the unrelated field kept');
    expect(store.stored.darknessLimit, DarknessLimit.nautical);
    expect(vm.planningPreferencesUnsaved, isFalse);
  });

  test('the newest write failing after an older success: unsaved, the older '
      'one stays stored, Retry stores the newest', () async {
    final store = _Store()..holding = true;
    final vm = _vm(store);
    await vm.load();
    final p = vm.planningPreferences;
    final a = vm.setPlanningPreferences(p.copyWith(minAltitudeDeg: 30));
    await pumpEventQueue();
    final b = vm.setPlanningPreferences(p.copyWith(minAltitudeDeg: 50));
    store.held.removeAt(0).complete(true);
    await a;
    await pumpEventQueue();
    store.held.removeAt(0).complete(false);
    await expectLater(b, throwsA(isA<StorageFailure>()));
    expect(vm.planningPreferencesUnsaved, isTrue);
    expect(vm.planningPreferences.minAltitudeDeg, 50);
    expect(store.stored.minAltitudeDeg, 30);
    store.holding = false;
    await vm.retryPlanningPreferences();
    expect(store.stored.minAltitudeDeg, 50);
    expect(vm.planningPreferencesUnsaved, isFalse);
  });

  test('an interrupted multi-key save is reported after a restart; Save '
      'these settings clears it', () async {
    SharedPreferences.setMockInitialValues({
      'minAltitude': 33.0,
      SharedPrefsPlanningPreferencesRepository.writingKey: true,
    });
    final repo = SharedPrefsPlanningPreferencesRepository();
    final vm = _vm(repo);
    await vm.load();
    expect(vm.planningPreferencesUnsaved, isTrue);
    expect(vm.minAltitude, 33.0);
    await vm.retryPlanningPreferences();
    expect(vm.planningPreferencesUnsaved, isFalse);
    expect(await repo.lastSaveIncomplete(), isFalse);
    final again = _vm(repo);
    await again.load();
    expect(again.planningPreferencesUnsaved, isFalse);
    expect(again.minAltitude, 33.0);
  });

  test('a completed save leaves no incomplete mark', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = SharedPrefsPlanningPreferencesRepository();
    await repo.save(PlanningPreferences(minAltitudeDeg: 25));
    expect(await repo.lastSaveIncomplete(), isFalse);
  });

  group('Appearance and units', () {
    test('a save stopped between two keys is unsaved after a restart, not a '
        'silent mix; Retry stores it whole', () async {
      SharedPreferences.setMockInitialValues({});
      var stopAt = SharedPrefsDisplaySettingsRepository.elevationKey;
      final repo = SharedPrefsDisplaySettingsRepository(
        beforeWrite: (key) async {
          if (key == stopAt) {
            throw const StorageFailure('save the display settings');
          }
        },
      );
      final vm = DisplaySettingsViewModel(repo);
      await vm.load();
      expect(vm.unsaved, isFalse);
      // Wind and elevation in one save (coalesced edits): it stops after
      // wind is written.
      await expectLater(
        vm.setUnits(
          vm.units.copyWith(wind: WindUnit.mph, elevation: ElevationUnit.feet),
        ),
        throwsA(isA<StorageFailure>()),
      );
      expect(await repo.lastSaveIncomplete(), isTrue);
      final restarted = DisplaySettingsViewModel(repo);
      await restarted.load();
      expect(restarted.units.wind, WindUnit.mph);
      expect(restarted.units.elevation, ElevationUnit.metres);
      expect(restarted.unsaved, isTrue, reason: 'a mix is never shown saved');
      stopAt = '';
      await restarted.retry();
      expect(restarted.unsaved, isFalse);
      expect(await repo.lastSaveIncomplete(), isFalse);
      // One changed key after a complete save needs no mark.
      await restarted.setUnits(
        restarted.units.copyWith(temperature: TemperatureUnit.fahrenheit),
      );
      expect(await repo.lastSaveIncomplete(), isFalse);
      final again = DisplaySettingsViewModel(repo);
      await again.load();
      expect(again.unsaved, isFalse);
      expect(again.units.temperature, TemperatureUnit.fahrenheit);
    });

    test('a failed choice stays shown, unsaved, with Retry; a restart shows '
        'the stored one', () async {
      final store = _DisplayStore()..fail = true;
      final vm = DisplaySettingsViewModel(store);
      await vm.load();
      await expectLater(
        vm.setUnits(vm.units.copyWith(temperature: TemperatureUnit.fahrenheit)),
        throwsA(isA<StorageFailure>()),
      );
      expect(vm.units.temperature, TemperatureUnit.fahrenheit);
      expect(vm.unsaved, isTrue);
      final restarted = DisplaySettingsViewModel(store);
      await restarted.load();
      expect(restarted.units.temperature, TemperatureUnit.celsius);

      store.fail = false;
      await vm.retry();
      expect(vm.unsaved, isFalse);
      expect(store.stored.units.temperature, TemperatureUnit.fahrenheit);
    });

    test('held writes coalesce; an older completion never marks the newer '
        'choice saved; unrelated settings kept', () async {
      final store = _DisplayStore();
      final vm = DisplaySettingsViewModel(store);
      await vm.load();
      store.hold = Completer();
      final a = vm.setAppearance(Appearance.dark);
      await Future<void>.delayed(Duration.zero);
      final b = vm.setUnits(vm.units.copyWith(wind: WindUnit.mph));
      final c = vm.setUnits(vm.units.copyWith(elevation: ElevationUnit.feet));
      final held = store.hold!;
      store.hold = null;
      held.complete();
      await a;
      expect(vm.saving, isTrue, reason: 'C is still to be stored');
      await Future.wait([b, c]);
      expect(store.saves, hasLength(2));
      expect(
        store.stored,
        const DisplaySettings(
          appearance: Appearance.dark,
          units: DisplayUnits(
            wind: WindUnit.mph,
            elevation: ElevationUnit.feet,
          ),
        ),
      );
      expect(vm.saving, isFalse);
    });
  });
}
