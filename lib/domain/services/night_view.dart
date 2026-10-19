import '../models/astro_target.dart';
import '../models/moon_conditions.dart';
import '../models/night_timeline.dart';
import '../models/session_night.dart';
import 'imaging_opportunity_calculator.dart';
import 'moon_calculator.dart';
import 'visibility_calculator.dart';

/// How dark the sky is at one grid instant (ADR-007 §8 thresholds), for the
/// shared night bar (F15 A1). [dark] is the plan's darkness limit; the
/// others are the standard twilights, so a −12° limit makes astronomical
/// twilight count as dark.
enum SkyState { daylight, civil, nautical, astronomical, dark }

/// One run of grid instants with the same sky state and Moon (F15 A1): the
/// shared bar draws these, and its text alternative names them.
class NightSegment {
  const NightSegment(this.startUtc, this.endUtc, this.sky, this.moonUp);

  final DateTime startUtc;
  final DateTime endUtc;
  final SkyState sky;
  final bool moonUp;
}

/// The state at a browsed instant (F15 A5): the sky, the Moon, and when
/// the current dark or not-dark interval ends. Facts on the 5-minute grid
/// (ADR-022 N3), never a simulation.
class NightInstant {
  const NightInstant({
    required this.instantUtc,
    required this.sky,
    required this.dark,
    required this.moonUp,
    required this.darkChangeUtc,
    required this.moonChangeUtc,
  });

  /// The grid instant at or before the browsed one.
  final DateTime instantUtc;
  final SkyState sky;

  /// The Sun at or below the darkness limit.
  final bool dark;
  final bool moonUp;

  /// When [dark] next changes in this night (darkness starts, or the dark
  /// time ends); null when it does not change before the night ends.
  final DateTime? darkChangeUtc;

  /// When the Moon next rises or sets in this night (N1); null if never.
  final DateTime? moonChangeUtc;

  /// Time until darkness (when not dark) or time left in it (when dark).
  Duration? get untilDarkChange => darkChangeUtc?.difference(instantUtc);
}

/// One night as the Night & Moon detail browses it (F15; ADR-022 N1–N5):
/// the Sun's timeline, the Moon on the same grid, the moon-free dark time
/// and the shared bar's segments. Pure and computed from the existing
/// calculators: the plan's night and a browsed night are the same function.
class NightView {
  NightView._({
    required this.night,
    required this.limitDeg,
    required this.timeline,
    required this.sun,
    required this.moon,
  });

  factory NightView.of(
    SessionNight night, {
    required double limitDeg,
    AstroTarget? target,
  }) => NightView._(
    night: night,
    limitDeg: limitDeg,
    timeline: VisibilityCalculator.calculateNightTimelineForNight(
      night,
      darknessLimitDeg: limitDeg,
    ),
    sun: SunTrack.forNight(night),
    moon: MoonCalculator.conditionsForNight(night, target: target),
  );

  final SessionNight night;
  final double limitDeg;
  final NightTimeline timeline;
  final SunTrack sun;
  final MoonConditions moon;

  /// The moon-free dark time (N4).
  late final MoonFreeNight moonFree = moon.moonFree(
    sunAltitudesDeg: sun.altitudesDeg,
    darknessLimitDeg: limitDeg,
  );

  SkyState _sky(double alt) => alt <= limitDeg
      ? SkyState.dark
      : alt < -12
      ? SkyState.astronomical
      : alt < -6
      ? SkyState.nautical
      : alt < -0.833
      ? SkyState.civil
      : SkyState.daylight;

  int get _n => sun.altitudesDeg.length;

  DateTime _at(int i) => ImagingOpportunityCalculator.instantAt(night, i);

  /// The night as runs of equal sky state and Moon, each from its first
  /// sample to the next run's first (the last to the night's end).
  late final List<NightSegment> segments = () {
    final out = <NightSegment>[];
    for (var i = 0; i < _n; i++) {
      final sky = _sky(sun.altitudesDeg[i]);
      final up = moon.samples[i].up;
      final end = i + 1 < _n ? _at(i + 1) : night.endUtc;
      final last = out.isEmpty ? null : out.last;
      if (last != null && last.sky == sky && last.moonUp == up) {
        out[out.length - 1] = NightSegment(last.startUtc, end, sky, up);
      } else {
        out.add(NightSegment(_at(i), end, sky, up));
      }
    }
    return out;
  }();

  /// The grid index at or before [utc], clamped to the night.
  int indexOf(DateTime utc) {
    final i =
        utc.difference(night.startUtc).inMinutes ~/
        VisibilityCalculator.sampleStep.inMinutes;
    return i.clamp(0, _n - 1);
  }

  /// Whether [utc] lies in this night's window.
  bool contains(DateTime utc) =>
      !utc.isBefore(night.startUtc) && !utc.isAfter(night.endUtc);

  /// The state at [utc] (clamped to the night).
  NightInstant at(DateTime utc) {
    final i = indexOf(utc);
    bool darkAt(int j) => sun.altitudesDeg[j] <= limitDeg;
    DateTime? next(bool Function(int) changed) {
      for (var j = i + 1; j < _n; j++) {
        if (changed(j)) return _at(j);
      }
      return null;
    }

    final dark = darkAt(i);
    final up = moon.samples[i].up;
    return NightInstant(
      instantUtc: _at(i),
      sky: _sky(sun.altitudesDeg[i]),
      dark: dark,
      moonUp: up,
      darkChangeUtc: next((j) => darkAt(j) != dark),
      moonChangeUtc: next((j) => moon.samples[j].up != up),
    );
  }
}
