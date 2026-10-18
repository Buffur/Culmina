import '../viewmodels/site_viewmodel.dart';

/// What a screen calls the position a plan uses (F23 A7, CRUX-04): a saved
/// site's name, a looked-up place name (its attribution is shown where the
/// name is), or, for a remembered unsaved position without a name,
/// [unsaved] with its coordinates. Never "Current position": a position
/// remembered from earlier is not where the device is now. Null when no
/// site is set.
class SiteLabel {
  const SiteLabel._();

  static const unsaved = 'Unsaved position';

  static String? of(SiteViewModel site, {bool withCoordinates = true}) {
    if (site.isDefaultLocation) return null;
    final name = site.activeSite?.name ?? site.locationName;
    if (name != null) return name;
    return withCoordinates
        ? '$unsaved (${coordinates(site.latitude, site.longitude)})'
        : unsaved;
  }

  /// "46.0500, 14.5100": decimal degrees, north and east positive, as the
  /// site editor takes them.
  static String coordinates(double latitude, double longitude) =>
      '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
}
