import 'dart:math' as math;
import 'dart:ui';

/// Matches the approved web sky's `color-mix(in oklab, ...)`.
/// Inputs and output are sRGB; interpolation takes place in Oklab.
Color mixSkyColors(Color first, Color second, double fraction) {
  double linear(double c) =>
      c <= .04045 ? c / 12.92 : math.pow((c + .055) / 1.055, 2.4).toDouble();
  double srgb(double c) =>
      (c <= .0031308 ? 12.92 * c : 1.055 * math.pow(c, 1 / 2.4) - .055)
          .clamp(0.0, 1.0)
          .toDouble();
  double cubeRoot(double v) => v.sign * math.pow(v.abs(), 1 / 3);
  (double, double, double) lab(Color c) {
    final r = linear(c.r), g = linear(c.g), b = linear(c.b);
    final l = cubeRoot(.4122214708 * r + .5363325363 * g + .0514459929 * b);
    final m = cubeRoot(.2119034982 * r + .6806995451 * g + .1073969566 * b);
    final s = cubeRoot(.0883024619 * r + .2817188376 * g + .6299787005 * b);
    return (
      .2104542553 * l + .7936177850 * m - .0040720468 * s,
      1.9779984951 * l - 2.4285922050 * m + .4505937099 * s,
      .0259040371 * l + .7827717662 * m - .8086757660 * s,
    );
  }

  final a = lab(first), b = lab(second);
  double mix(double a, double b) => a + (b - a) * fraction;
  final light = mix(a.$1, b.$1);
  final green = mix(a.$2, b.$2);
  final blue = mix(a.$3, b.$3);
  final l = math.pow(light + .3963377774 * green + .2158037573 * blue, 3);
  final m = math.pow(light - .1055613458 * green - .0638541728 * blue, 3);
  final s = math.pow(light - .0894841775 * green - 1.2914855480 * blue, 3);
  return Color.from(
    alpha: mix(first.a, second.a),
    red: srgb(
      (4.0767416621 * l - 3.3077115913 * m + .2309699292 * s).toDouble(),
    ),
    green: srgb(
      (-1.2684380046 * l + 2.6097574011 * m - .3413193965 * s).toDouble(),
    ),
    blue: srgb(
      (-.0041960863 * l - .7034186147 * m + 1.7076147010 * s).toDouble(),
    ),
  );
}
