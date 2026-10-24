import '../models/location_profile.dart';
import 'storage_failure.dart';

/// A saved site already has this exact latitude and longitude.
class DuplicateSite implements Exception {
  const DuplicateSite(this.existingName);

  final String existingName;
}

/// Every method throws [StorageFailure] when the store cannot be read or
/// written (TASK 15.1).
abstract class LocationRepository {
  /// Refuses an exact coordinate duplicate with [DuplicateSite].
  Future<int> insertLocation(LocationProfile location);
  Future<List<LocationProfile>> getLocations();
  Future<LocationProfile?> getLocationById(int id);

  /// Refuses changed coordinates matching another record with [DuplicateSite].
  Future<void> updateLocation(LocationProfile location);
  Future<void> deleteLocation(int id);
}
