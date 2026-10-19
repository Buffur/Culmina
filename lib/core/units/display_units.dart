/// How the app looks and which units it shows (F21, S16.6, PD-20). Display
/// only: every stored value and calculation stays in its canonical unit
/// (°C, km/h, metres); these convert at the edge, on screen and in shared
/// text. Stored by name; an unknown name reads as the default.
library;

/// Appearance (PD-20): System (the default, D1 = A, new installs too),
/// Light or Dark. Field mode is separate and unchanged.
enum Appearance {
  system('System'),
  light('Light'),
  dark('Dark');

  const Appearance(this.label);

  final String label;

  static Appearance fromStorage(String? name) =>
      values.firstWhere((v) => v.name == name, orElse: () => system);
}

enum TemperatureUnit {
  celsius('°C'),
  fahrenheit('°F');

  const TemperatureUnit(this.symbol);

  final String symbol;

  static TemperatureUnit fromStorage(String? name) =>
      values.firstWhere((v) => v.name == name, orElse: () => celsius);
}

enum WindUnit {
  kmh('km/h'),
  mph('mph'),
  ms('m/s');

  const WindUnit(this.symbol);

  final String symbol;

  static WindUnit fromStorage(String? name) =>
      values.firstWhere((v) => v.name == name, orElse: () => kmh);
}

enum ElevationUnit {
  metres('m'),
  feet('ft');

  const ElevationUnit(this.symbol);

  final String symbol;

  static ElevationUnit fromStorage(String? name) =>
      values.firstWhere((v) => v.name == name, orElse: () => metres);
}

/// The units the app shows. Conversions are exact by definition: 1 mph =
/// 1.609344 km/h, 1 ft = 0.3048 m, °F = °C × 9/5 + 32 for a temperature but
/// × 9/5 alone for a temperature **difference** (a dew margin, a spread).
class DisplayUnits {
  const DisplayUnits({
    this.temperature = TemperatureUnit.celsius,
    this.wind = WindUnit.kmh,
    this.elevation = ElevationUnit.metres,
  });

  /// The defaults, as before F21: °C, km/h, m.
  static const metric = DisplayUnits();

  final TemperatureUnit temperature;
  final WindUnit wind;
  final ElevationUnit elevation;

  static const _kmhPerMph = 1.609344;
  static const _metresPerFoot = 0.3048;

  /// An absolute temperature [celsius] in the display unit.
  double temperatureOf(double celsius) =>
      temperature == TemperatureUnit.fahrenheit
      ? celsius * 9 / 5 + 32
      : celsius;

  /// A temperature difference [celsius] (kelvins) in the display unit.
  double temperatureDifferenceOf(double celsius) =>
      temperature == TemperatureUnit.fahrenheit ? celsius * 9 / 5 : celsius;

  /// A typed absolute temperature back to °C, the stored unit.
  double celsiusFrom(double shown) =>
      temperature == TemperatureUnit.fahrenheit ? (shown - 32) * 5 / 9 : shown;

  /// A wind speed [kmh] in the display unit.
  double windOf(double kmh) => switch (wind) {
    WindUnit.kmh => kmh,
    WindUnit.mph => kmh / _kmhPerMph,
    WindUnit.ms => kmh / 3.6,
  };

  /// An elevation [metres] in the display unit.
  double elevationOf(double metres) =>
      elevation == ElevationUnit.feet ? metres / _metresPerFoot : metres;

  /// A typed elevation back to metres, the stored unit.
  double metresFrom(double shown) =>
      elevation == ElevationUnit.feet ? shown * _metresPerFoot : shown;

  DisplayUnits copyWith({
    TemperatureUnit? temperature,
    WindUnit? wind,
    ElevationUnit? elevation,
  }) => DisplayUnits(
    temperature: temperature ?? this.temperature,
    wind: wind ?? this.wind,
    elevation: elevation ?? this.elevation,
  );

  @override
  bool operator ==(Object other) =>
      other is DisplayUnits &&
      other.temperature == temperature &&
      other.wind == wind &&
      other.elevation == elevation;

  @override
  int get hashCode => Object.hash(temperature, wind, elevation);
}
