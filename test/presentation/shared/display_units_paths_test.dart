// F21 A2/A3: the chosen units reach every text path that shows a
// temperature, wind speed or elevation — the forecast ranges, the dew
// heuristic (a difference), an entry's shared conditions, the site form's
// elevation check — while the values stay canonical.

import 'package:astroplan/core/units/display_units.dart';
import 'package:astroplan/domain/models/night_weather_summary.dart';
import 'package:astroplan/presentation/shared/night_text.dart';
import 'package:astroplan/presentation/shared/site_form_input.dart';
import 'package:flutter_test/flutter_test.dart';

const _imperial = DisplayUnits(
  temperature: TemperatureUnit.fahrenheit,
  wind: WindUnit.mph,
  elevation: ElevationUnit.feet,
);

void main() {
  test('forecast ranges: absolute temperatures and wind', () {
    const t = WeatherRange(-5, 10);
    expect(WeatherText.temperatureRange(t, DisplayUnits.metric), '-5–10 °C');
    expect(WeatherText.temperatureRange(t, _imperial), '23–50 °F');
    expect(WeatherText.temperatureRange(null, _imperial), 'no forecast');
    const w = WeatherRange(16.09344, 32.18688);
    expect(WeatherText.windRange(w, _imperial), '10–20 mph');
    expect(
      WeatherText.windRange(
        const WeatherRange(36, 36),
        const DisplayUnits(wind: WindUnit.ms),
      ),
      '10 m/s',
    );
  });

  test('the site form checks a typed elevation in feet against 9000 m', () {
    expect(SiteFormInput.validateElevation('29000', _imperial), isNull);
    expect(SiteFormInput.validateElevation('29600', _imperial), isNotNull);
    expect(SiteFormInput.validateElevation('9001'), isNotNull);
    expect(SiteFormInput.validateElevation('9001', _imperial), isNull);
  });
}
