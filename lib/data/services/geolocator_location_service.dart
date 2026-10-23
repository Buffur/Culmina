import 'package:geolocator/geolocator.dart';

import '../../domain/services/location_service.dart';

/// [LocationService] backed by the `geolocator` plugin.
class GeolocatorLocationService implements LocationService {
  /// How long a position request may take before it fails (TD-112): a fix
  /// that never comes (for example after the system's location-accuracy
  /// prompt was declined) ends with an explained failure, not a silent wait.
  static const timeLimit = Duration(seconds: 20);

  @override
  Future<LocationResult> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const LocationUnavailable(LocationFailure.serviceDisabled);
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return const LocationUnavailable(LocationFailure.permissionDenied);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return const LocationUnavailable(LocationFailure.permissionDeniedForever);
    }

    // A TimeoutException after [timeLimit]; callers explain it.
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(timeLimit: timeLimit),
    );
    return LocationFound(
      DeviceLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      ),
    );
  }

  @override
  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  @override
  Future<bool> openAppSettings() => Geolocator.openAppSettings();
}
