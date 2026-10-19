// F21 A2/A3 (S16.6, PD-20): units convert only for display, exactly by
// definition; an absolute temperature and a temperature difference (a dew
// margin) convert differently; typed values go back to the stored unit;
// unknown stored names read as the defaults. Expected values are worked by
// hand from the definitions (°F = °C × 9/5 + 32; a difference × 9/5 only;
// 1 mph = 1.609344 km/h; 1 m/s = 3.6 km/h; 1 ft = 0.3048 m).

import 'package:astroplan/core/units/display_units.dart';
import 'package:astroplan/core/utils/quantity_text.dart';
import 'package:flutter_test/flutter_test.dart';

const _imperial = DisplayUnits(
  temperature: TemperatureUnit.fahrenheit,
  wind: WindUnit.mph,
  elevation: ElevationUnit.feet,
);

void main() {
  test('A3: absolute temperature: 0 °C = 32 °F, −40 = −40, 100 °C = 212 °F; '
      'back again', () {
    expect(_imperial.temperatureOf(0), 32);
    expect(_imperial.temperatureOf(-40), -40);
    expect(_imperial.temperatureOf(100), 212);
    expect(_imperial.temperatureOf(-3.5), closeTo(25.7, 1e-9));
    expect(_imperial.celsiusFrom(212), closeTo(100, 1e-9));
    expect(_imperial.celsiusFrom(25.7), closeTo(-3.5, 1e-9));
    expect(DisplayUnits.metric.temperatureOf(-3.5), -3.5);
  });

  test(
    'A3: a temperature difference: 2 °C = 3.6 °F, never 35.6; 0 stays 0',
    () {
      expect(_imperial.temperatureDifferenceOf(2), closeTo(3.6, 1e-9));
      expect(_imperial.temperatureDifferenceOf(0), 0);
      expect(_imperial.temperatureDifferenceOf(5), 9);
      expect(QuantityText.temperatureDifference(2, _imperial), '3.6 °F');
      expect(
        QuantityText.temperatureDifference(2, DisplayUnits.metric),
        '2.0 °C',
      );
      expect(QuantityText.temperature(2, _imperial), '36 °F');
    },
  );

  test('A2: wind and elevation', () {
    expect(_imperial.windOf(1.609344), closeTo(1, 1e-12));
    expect(
      const DisplayUnits(wind: WindUnit.ms).windOf(36),
      closeTo(10, 1e-12),
    );
    expect(_imperial.elevationOf(0.3048), closeTo(1, 1e-12));
    expect(_imperial.metresFrom(1000), closeTo(304.8, 1e-9));
    expect(QuantityText.wind(16.09344, _imperial), '10 mph');
    expect(
      QuantityText.wind(36, const DisplayUnits(wind: WindUnit.ms)),
      '10 m/s',
    );
    expect(QuantityText.elevation(300, _imperial), '984 ft');
    expect(QuantityText.elevation(-12, DisplayUnits.metric), '−12 m');
    expect(
      QuantityText.temperatureAsRecorded(-10, DisplayUnits.metric),
      '-10 °C',
    );
    expect(QuantityText.temperatureAsRecorded(-10, _imperial), '14 °F');
  });

  test('A1: unknown stored names read as the defaults', () {
    expect(Appearance.fromStorage('sepia'), Appearance.system);
    expect(Appearance.fromStorage(null), Appearance.system);
    expect(TemperatureUnit.fromStorage('kelvin'), TemperatureUnit.celsius);
    expect(WindUnit.fromStorage('knots'), WindUnit.kmh);
    expect(ElevationUnit.fromStorage(''), ElevationUnit.metres);
    for (final a in Appearance.values) {
      expect(Appearance.fromStorage(a.name), a);
    }
  });
}
