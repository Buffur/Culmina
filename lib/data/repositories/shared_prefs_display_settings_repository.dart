import 'package:shared_preferences/shared_preferences.dart';

import '../../core/units/display_units.dart';
import '../../domain/repositories/display_settings_repository.dart';
import 'storage_guard.dart';

/// [DisplaySettingsRepository] backed by SharedPreferences (F21): each
/// setting is a string key holding its name; an absent key is the default
/// (System, °C, km/h, m), as on an install from before F21.
class SharedPrefsDisplaySettingsRepository
    implements DisplaySettingsRepository {
  /// [beforeWrite] is called before each setting's key is written; tests
  /// use it to stop a save part way.
  SharedPrefsDisplaySettingsRepository({this.beforeWrite});

  final Future<void> Function(String key)? beforeWrite;

  static const appearanceKey = 'appearance';
  static const temperatureKey = 'units.temperature';
  static const windKey = 'units.wind';
  static const elevationKey = 'units.elevation';

  /// F21 A5: set while a save writes its keys, removed once all are
  /// written; still set after a failed or interrupted save, whose keys may
  /// then mix two configurations.
  static const writingKey = 'displaySettingsWriting';

  /// Every key this repository stores, for the backup.
  static const keys = {
    appearanceKey,
    temperatureKey,
    windKey,
    elevationKey,
    writingKey,
  };

  @override
  Future<DisplaySettings> load() => guardStorage(
    'read the display settings',
    () async {
      final p = await SharedPreferences.getInstance();
      return DisplaySettings(
        appearance: Appearance.fromStorage(p.getString(appearanceKey)),
        units: DisplayUnits(
          temperature: TemperatureUnit.fromStorage(p.getString(temperatureKey)),
          wind: WindUnit.fromStorage(p.getString(windKey)),
          elevation: ElevationUnit.fromStorage(p.getString(elevationKey)),
        ),
      );
    },
  );

  @override
  Future<void> save(DisplaySettings settings) =>
      guardStorage('save the display settings', () async {
        final p = await SharedPreferences.getInstance();
        final u = settings.units;
        final changed = [
          for (final (key, name) in [
            (appearanceKey, settings.appearance.name),
            (temperatureKey, u.temperature.name),
            (windKey, u.wind.name),
            (elevationKey, u.elevation.name),
          ])
            if (p.getString(key) != name) (key, name),
        ];
        // One changed key is one write: a mix needs two.
        final marked = changed.length > 1 || (p.getBool(writingKey) ?? false);
        if (marked) await p.setBool(writingKey, true);
        for (final (key, name) in changed) {
          await beforeWrite?.call(key);
          await p.setString(key, name);
        }
        if (marked) await p.remove(writingKey);
      });

  @override
  Future<bool> lastSaveIncomplete() => guardStorage(
    'read the display settings',
    () async =>
        (await SharedPreferences.getInstance()).getBool(writingKey) ?? false,
  );
}
