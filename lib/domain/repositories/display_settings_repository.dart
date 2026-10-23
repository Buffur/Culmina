import '../../core/units/display_units.dart';
import 'storage_failure.dart';

/// The Appearance and units preferences (F21, S16.6, PD-20).
class DisplaySettings {
  const DisplaySettings({
    this.appearance = Appearance.system,
    this.units = DisplayUnits.metric,
    this.weatherView = WeatherView.rows,
  });

  final Appearance appearance;
  final DisplayUnits units;
  final WeatherView weatherView;

  DisplaySettings copyWith({
    Appearance? appearance,
    DisplayUnits? units,
    WeatherView? weatherView,
  }) => DisplaySettings(
    appearance: appearance ?? this.appearance,
    units: units ?? this.units,
    weatherView: weatherView ?? this.weatherView,
  );

  @override
  bool operator ==(Object other) =>
      other is DisplaySettings &&
      other.appearance == appearance &&
      other.units == units &&
      other.weatherView == weatherView;

  @override
  int get hashCode => Object.hash(appearance, units, weatherView);
}

/// Persistence for [DisplaySettings]: one stored value per setting. Throws
/// [StorageFailure] when the store cannot be read or written; an unknown
/// stored value reads as its default.
abstract class DisplaySettingsRepository {
  Future<DisplaySettings> load();

  /// Stores [settings] whole (each changed value is one write).
  Future<void> save(DisplaySettings settings);

  /// Whether the last [save] stopped part way (F21 A5): the stored values
  /// may then mix two configurations, so they are shown as unsaved.
  Future<bool> lastSaveIncomplete();
}
