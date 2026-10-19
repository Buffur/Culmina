import 'package:shared_preferences/shared_preferences.dart';

import '../../core/units/display_units.dart';
import '../../domain/repositories/display_settings_repository.dart';
import 'storage_guard.dart';

/// [DisplaySettingsRepository] backed by SharedPreferences (F21): each
/// setting is a string key holding its name; an absent key is the default
/// (System, °C, km/h, m), as on an install from before F21.
class SharedPrefsDisplaySettingsRepository
    implements DisplaySettingsRepository {
  static const appearanceKey = 'appearance';
  static const temperatureKey = 'units.temperature';
  static const windKey = 'units.wind';
  static const elevationKey = 'units.elevation';

  /// Every key this repository stores, for the backup.
  static const keys = {appearanceKey, temperatureKey, windKey, elevationKey};

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
        for (final (key, name) in [
          (appearanceKey, settings.appearance.name),
          (temperatureKey, u.temperature.name),
          (windKey, u.wind.name),
          (elevationKey, u.elevation.name),
        ]) {
          if (p.getString(key) != name) await p.setString(key, name);
        }
      });
}
