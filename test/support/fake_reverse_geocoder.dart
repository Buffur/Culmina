import 'package:astroplan/domain/services/reverse_geocoder.dart';

/// Test double for [ReverseGeocoder]: never touches the network. Answers
/// every lookup with [result] and records the coordinates asked for.
class FakeReverseGeocoder implements ReverseGeocoder {
  FakeReverseGeocoder({this.result = const PlaceNameNotFound(), this.answer});

  ReverseGeocodeResult result;

  /// When set, each lookup waits for this answer instead (the test
  /// completes it).
  Future<ReverseGeocodeResult> Function()? answer;

  final List<(double, double)> lookups = [];

  @override
  Future<ReverseGeocodeResult> placeNameFor(
    double latitude,
    double longitude,
  ) async {
    lookups.add((latitude, longitude));
    if (answer case final pending?) return pending();
    return result;
  }
}
