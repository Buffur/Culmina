import '../../core/units/display_units.dart';
import 'coordinate_input.dart';
import 'light_pollution_map_link.dart';

/// Parsing and validation for the site editor's non-coordinate fields
/// (TASK 7.3), usable as `TextFormField` validators. Ranges match
/// `LocationProfile`; coordinates use [CoordinateInput].
abstract final class SiteFormInput {
  static String? validateName(String? text) =>
      (text == null || text.trim().isEmpty) ? 'Name is required' : null;

  /// Metres above mean sea level, -500..9000; empty means unknown (RG-08 =
  /// E2, S7.5), never 0. F21: typed in [units]' elevation unit, checked in
  /// metres, the range said in the typed unit.
  static String? validateElevation(
    String? text, [
    DisplayUnits units = DisplayUnits.metric,
  ]) {
    if (text == null || text.trim().isEmpty) return null;
    final value = CoordinateInput.parse(text);
    final feet = units.elevation == ElevationUnit.feet;
    if (value == null) {
      return feet ? 'Enter feet, e.g. 968' : 'Enter metres, e.g. 295';
    }
    final metres = units.metresFrom(value);
    if (metres < -500 || metres > 9000) {
      return feet
          ? 'Elevation must be between -1640 and 29527 ft'
          : 'Elevation must be between -500 and 9000 m';
    }
    return null;
  }

  /// Sky quality in mag/arcsec², 15..23; empty means unknown.
  static String? validateSqm(String? text) {
    if (text == null || text.trim().isEmpty) return null;
    final value = CoordinateInput.parse(text);
    if (value == null) return 'Enter mag/arcsec², e.g. 21.2';
    if (value < 15 || value > 23) return 'SQM must be between 15 and 23';
    return null;
  }

  /// A value the site refused (`LocationProfile` throws [ArgumentError] for
  /// one out of range), in the validators' words, never the raw error. The
  /// validators normally catch it first.
  static String refused(ArgumentError e) => switch (e.name) {
    'latitude' => 'Latitude must be between -90 and 90',
    'longitude' => 'Longitude must be between -180 and 180',
    'elevation' => 'Elevation must be between -500 and 9000 m',
    'bortleClass' => 'Bortle class must be between 1 and 9',
    'sqm' => 'SQM must be between 15 and 23',
    _ => "The site can't be saved: check its values.",
  };

  /// The light-pollution map at the typed coordinates (RG-09 = M2, S7.5),
  /// or null until both are valid.
  static Uri? mapLink(String latitude, String longitude) {
    if (CoordinateInput.validateLatitude(latitude) != null ||
        CoordinateInput.validateLongitude(longitude) != null) {
      return null;
    }
    return LightPollutionMapLink.at(
      CoordinateInput.parse(latitude)!,
      CoordinateInput.parse(longitude)!,
    );
  }

  /// The trimmed text, or null when empty.
  static String? optionalText(String text) {
    final trimmed = text.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
