// F21 A1 (S16.6; trap 5): every carried preference value survives a backup
// round trip (read → JSON → parse → restore on another device); a backup
// from before F21 restores the documented defaults for Appearance and
// units; an unknown future value reads as its default; a backup file with
// a malformed value is refused whole.

import 'dart:convert';

import 'package:astroplan/core/units/display_units.dart';
import 'package:astroplan/data/backup/backup_preferences.dart';
import 'package:astroplan/data/repositories/shared_prefs_display_settings_repository.dart';
import 'package:astroplan/data/repositories/shared_prefs_planning_preferences_repository.dart';
import 'package:astroplan/domain/models/planning_preferences.dart';
import 'package:astroplan/domain/repositories/display_settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Every carried key with a non-default value.
const _everything = <String, Object>{
  'minAltitude': 35.0,
  'dewPointThreshold': 3.5,
  'darknessLimitDeg': -12.0,
  'feasibilityMarginPercent': 15.0,
  'perFrameOverheadSeconds': 4.0,
  'ditherEveryNFrames': 5,
  'ditherSettleSeconds': 12.0,
  'refocusEveryMinutes': 45.0,
  'refocusSeconds': 90.0,
  'filterChangeSeconds': 8.0,
  'meridianFlipSeconds': 300.0,
  'setupMinutes': 20.0,
  'npfK': 400.0,
  'moonGateEnabled': true,
  'moonGateMinIlluminationPct': 40.0,
  'cloudGateEnabled': true,
  'cloudGateMaxPct': 30.0,
  'fieldMode': true,
  'section.planner.budget': false,
  'activeLocationId': 4,
  'firstRunDone': true,
  'appearance': 'light',
  'units.temperature': 'fahrenheit',
  'units.wind': 'ms',
  'units.elevation': 'feet',
  'weather.view': 'charts',
};

Future<Map<String, Object?>> _throughFile() async => BackupPreferences.parse(
  jsonDecode(jsonEncode(await BackupPreferences.read())),
);

void main() {
  test(
    'every carried value survives the round trip, by type and value',
    () async {
      SharedPreferences.setMockInitialValues(_everything);
      final carried = await _throughFile();
      SharedPreferences.setMockInitialValues({'minAltitude': 10.0});
      await BackupPreferences.restore(carried);
      final p = await SharedPreferences.getInstance();
      for (final MapEntry(:key, :value) in _everything.entries) {
        expect(p.get(key), value, reason: key);
      }
      final planning = await SharedPrefsPlanningPreferencesRepository().load();
      expect(planning.darknessLimit, DarknessLimit.nautical);
      expect(planning.ditherEveryNFrames, 5);
      expect(
        await SharedPrefsDisplaySettingsRepository().load(),
        const DisplaySettings(
          appearance: Appearance.light,
          units: DisplayUnits(
            temperature: TemperatureUnit.fahrenheit,
            wind: WindUnit.ms,
            elevation: ElevationUnit.feet,
          ),
          weatherView: WeatherView.charts,
        ),
      );
    },
  );

  // Hybrid HT-W04: the Weather view travels with the backup; a backup
  // from before it (no weather.view) restores the default, rows.
  test('a backup without the Weather view restores rows', () async {
    final before = {
      'version': 1,
      'string': {'appearance': 'dark'},
    };
    SharedPreferences.setMockInitialValues({'weather.view': 'charts'});
    await BackupPreferences.restore(BackupPreferences.parse(before));
    final s = await SharedPrefsDisplaySettingsRepository().load();
    expect(s.appearance, Appearance.dark);
    expect(s.weatherView, WeatherView.rows);
  });

  test('a backup from before F21 (no string group) restores the defaults: '
      'System, °C, km/h, m', () async {
    final old = {
      'version': 1,
      'bool': {'fieldMode': true},
      'int': <String, int>{},
      'double': {'minAltitude': 30.0},
    };
    SharedPreferences.setMockInitialValues({
      'appearance': 'dark',
      'units.temperature': 'fahrenheit',
    });
    await BackupPreferences.restore(BackupPreferences.parse(old));
    expect(
      await SharedPrefsDisplaySettingsRepository().load(),
      const DisplaySettings(),
    );
    final p = await SharedPreferences.getInstance();
    expect(p.getDouble('minAltitude'), 30.0);
  });

  test('an unknown future value restores, then reads as its default', () async {
    final future = {
      'version': 1,
      'string': {'appearance': 'sepia', 'units.wind': 'knots'},
    };
    SharedPreferences.setMockInitialValues({});
    await BackupPreferences.restore(BackupPreferences.parse(future));
    final s = await SharedPrefsDisplaySettingsRepository().load();
    expect(s.appearance, Appearance.system);
    expect(s.units.wind, WindUnit.kmh);
  });

  test('a malformed string value refuses the file whole', () {
    expect(
      () => BackupPreferences.parse({
        'version': 1,
        'string': {'appearance': 3},
      }),
      throwsFormatException,
    );
  });
}
