import '../models/weather_snapshot.dart';
import 'storage_failure.dart';

/// Persistent cache of weather snapshots (TASK 9.3; ADR-022 N8). Keys are built by
/// [WeatherSnapshotStore.keyFor]; the store only saves and returns them.
///
/// Every method throws [StorageFailure] when the store cannot be read or
/// written (TASK 15.1).
abstract class WeatherSnapshotStore {
  Future<WeatherSnapshot?> read(String key);
  Future<void> write(String key, WeatherSnapshot snapshot);

  /// The cache format in the key (ADR-022 N8): version 2 holds one
  /// snapshot per site for the whole horizon. Version-1 keys (one per
  /// night, TD-049) are deleted by the store, never migrated.
  static const keyVersion = 2;

  /// Cache key for a site (coordinates rounded to 0.01°), a model and the
  /// requested horizon in days (N8): data for another site, model or
  /// horizon is never returned for this one (ADR-012 §6). The site's id is
  /// not part of it, so an edited site's coordinates get their own key.
  static String keyFor({
    required double latitude,
    required double longitude,
    required String model,
    required int forecastDays,
  }) =>
      'weather$keyVersion:${latitude.toStringAsFixed(2)}:'
      '${longitude.toStringAsFixed(2)}:$model:$forecastDays';
}
