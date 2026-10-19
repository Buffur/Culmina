/// The external Clear Outside forecast, opened at a position (ADR-022 /
/// RA.D Q3, PD-18; F14 A5): seeing and transparency are not forecast in
/// the app, so the user may look there. The app only links to it; nothing
/// is fetched. Only the coordinates in the URL leave the device, sent by
/// the browser when the user taps (as with the light-pollution map).
abstract final class ClearOutsideLink {
  /// The forecast page for [latitude]/[longitude] (WGS-84 decimal degrees),
  /// in the site's public URL form `/forecast/{lat}/{lon}` with two
  /// decimals (as its own pages use; about 1 km).
  static Uri at(double latitude, double longitude) => Uri.parse(
    'https://clearoutside.com/forecast/'
    '${latitude.toStringAsFixed(2)}/${longitude.toStringAsFixed(2)}',
  );
}
