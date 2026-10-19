// F14 A5 (RA.D Q3, PD-18): the external Clear Outside forecast opens at the
// site, in its public `/forecast/{lat}/{lon}` form with two decimals; only
// the coordinates are in the URL. Literal expectations.

import 'package:astroplan/presentation/shared/clear_outside_link.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('two decimals, /forecast/{lat}/{lon}', () {
    expect(
      ClearOutsideLink.at(46.0512, 14.5068).toString(),
      'https://clearoutside.com/forecast/46.05/14.51',
    );
    // Whole degrees still carry two decimals.
    expect(
      ClearOutsideLink.at(51, 0).toString(),
      'https://clearoutside.com/forecast/51.00/0.00',
    );
  });

  test('negative coordinates keep their sign, south and west', () {
    expect(
      ClearOutsideLink.at(-33.8688, 151.2093).toString(),
      'https://clearoutside.com/forecast/-33.87/151.21',
    );
    expect(
      ClearOutsideLink.at(40.7128, -74.006).toString(),
      'https://clearoutside.com/forecast/40.71/-74.01',
    );
    expect(ClearOutsideLink.at(-22.9519, -43.2105).pathSegments, [
      'forecast',
      '-22.95',
      '-43.21',
    ]);
  });

  test('nothing but the position: no query, https, the public host', () {
    final uri = ClearOutsideLink.at(46.05, 14.51);
    expect(uri.scheme, 'https');
    expect(uri.host, 'clearoutside.com');
    expect(uri.query, isEmpty);
  });
}
