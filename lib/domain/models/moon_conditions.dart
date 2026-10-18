import '../services/moon_calculator.dart';
import 'night_timeline.dart';
import 'session_night.dart';

/// The Moon at one instant of the night grid.
class MoonSample {
  const MoonSample({
    required this.instantUtc,
    required this.altitudeDeg,
    required this.up,
    required this.separationDeg,
    required this.targetAltitudeDeg,
  });

  final DateTime instantUtc;

  /// Topocentric geometric (airless) altitude of the Moon's centre, degrees.
  final double altitudeDeg;

  /// Whether the Moon is up by the one predicate (ADR-022 N1): its upper
  /// limb on the apparent horizon, never `altitudeDeg > 0`.
  final bool up;

  /// Topocentric Moon–target separation, degrees; null without a target.
  final double? separationDeg;

  /// The target's altitude at this instant, degrees; null without a target.
  final double? targetAltitudeDeg;
}

/// The closest approach of Moon and target while both are up: the Moon by
/// ADR-022 N1, the target above 0°.
class MoonApproach {
  const MoonApproach({required this.separationDeg, required this.instantUtc});
  final double separationDeg;
  final DateTime instantUtc;
}

/// Moon context for one night and (optionally) one target — annotations
/// only, never an "impact %" (ADR-010, TASK 6.4).
class MoonConditions {
  const MoonConditions({
    required this.night,
    required this.samples,
    required this.riseSet,
    required this.illuminationAtMidnight,
    required this.closestApproachWhileBothUp,
    this.phaseLongitudeAtMidnightDeg,
  });

  final SessionNight night;

  /// On the night's 5-minute grid, inclusive of both ends (ADR-007 §9).
  final List<MoonSample> samples;

  /// Moonrise/moonset within the night (Meeus ch. 15 convention).
  final MoonRiseSet riseSet;

  /// Illuminated fraction 0–1 at mean solar midnight (`startUtc + 12 h`),
  /// the night's single evaluation instant for night-level scalars (ADR-007
  /// §9 candidate, adopted by TASK 6.4). It changes by at most about 6
  /// percentage points across one night.
  final double illuminationAtMidnight;

  /// Null when there is no target, or the Moon and the target are never
  /// above the horizon at the same time during the night.
  final MoonApproach? closestApproachWhileBothUp;

  /// The Moon − Sun apparent ecliptic longitude at mean solar midnight,
  /// degrees, the phase's measure (ADR-022 N5); null when not computed.
  final double? phaseLongitudeAtMidnightDeg;

  /// The night's phase name (N5); null without a phase longitude. A name,
  /// never a substitute for [moonFree].
  MoonPhaseName? get phaseName => switch (phaseLongitudeAtMidnightDeg) {
    final l? => MoonPhaseName.of(l),
    null => null,
  };

  /// ADR-022 N4: the night's dark time with the Moon down. Dark samples are
  /// those with the Sun at or below [darknessLimitDeg] ([sunAltitudesDeg],
  /// on the same grid as [samples]); moon-free ones are also not [MoonSample.up].
  MoonFreeNight moonFree({
    required List<double> sunAltitudesDeg,
    required double darknessLimitDeg,
  }) {
    if (sunAltitudesDeg.length != samples.length) {
      throw ArgumentError.value(
        sunAltitudesDeg.length,
        'sunAltitudesDeg',
        'must match the ${samples.length} Moon samples',
      );
    }
    return MoonFreeNight.classify(
      instants: [for (final s in samples) s.instantUtc],
      dark: [for (final a in sunAltitudesDeg) a <= darknessLimitDeg],
      moonUp: [for (final s in samples) s.up],
    );
  }

  /// Intervals when the Moon is up within the night, from [riseSet].
  List<(DateTime, DateTime)> get upIntervals {
    final out = <(DateTime, DateTime)>[];
    DateTime? start = riseSet.aboveAtStart ? night.startUtc : null;
    for (final e in riseSet.events) {
      if (e.kind == MoonEventKind.rise) {
        start = e.utc;
      } else if (start != null) {
        out.add((start, e.utc));
        start = null;
      }
    }
    if (start != null) out.add((start, night.endUtc));
    return out;
  }

  /// The Moon during the night's dark span [dark] (S6.13; UX-17; CALC-43):
  /// the same measure as the imaging windows' Moon note (ADR-013): the
  /// samples on the night's 5-minute grid inside the dark span, and those
  /// with the Moon up (ADR-022 N1), each worth one step.
  /// Null when there is no dark span.
  MoonDuringDark? duringDark(SunThresholdResult dark) {
    final spans = _darkSpans(dark);
    if (spans.isEmpty || samples.length < 2) return null;
    final step = samples[1].instantUtc.difference(samples[0].instantUtc);
    bool inDark(DateTime t) =>
        spans.any((s) => !t.isBefore(s.$1) && t.isBefore(s.$2));
    var darkSamples = 0;
    var up = 0;
    for (final s in samples) {
      if (!inDark(s.instantUtc)) continue;
      darkSamples++;
      if (s.up) up++;
    }
    if (darkSamples == 0) return null;
    return MoonDuringDark(
      dark: step * darkSamples,
      moonUp: step * up,
      illumination: illuminationAtMidnight,
    );
  }

  /// The dark span's intervals within the night: one, or two when the Sun
  /// is already below the limit at the start and sets below it again later.
  List<(DateTime, DateTime)> _darkSpans(SunThresholdResult dark) =>
      switch (dark) {
        SunNeverBelow() => const [],
        SunAlwaysBelow() => [(night.startUtc, night.endUtc)],
        SunCrossing(:final duskUtc, :final dawnUtc) => switch ((
          duskUtc,
          dawnUtc,
        )) {
          (final dusk?, final dawn?) when dusk.isBefore(dawn) => [(dusk, dawn)],
          (final dusk?, final dawn?) => [
            (night.startUtc, dawn),
            (dusk, night.endUtc),
          ],
          (final dusk?, null) => [(dusk, night.endUtc)],
          (null, final dawn?) => [(night.startUtc, dawn)],
          (null, null) => const [],
        },
      };
}

/// The Moon while it is dark at the user's limit (S6.13; CALC-43): how
/// long the dark span is, how much of it the Moon is up, and its
/// illumination at mean solar midnight (the night's value, SCI-09). A fact,
/// never an "impact" (ADR-010).
class MoonDuringDark {
  const MoonDuringDark({
    required this.dark,
    required this.moonUp,
    required this.illumination,
  });

  /// The dark span, on the night's grid.
  final Duration dark;

  /// How much of [dark] the Moon is above the horizon.
  final Duration moonUp;

  /// Illuminated fraction 0–1 at mean solar midnight.
  final double illumination;

  bool get moonDown => moonUp == Duration.zero;
  bool get upAllDark => moonUp >= dark;
}

/// ADR-022 N5: the eight phase names, in 45° bins of the phase longitude
/// centred on 0°, 45°, … 315° (New is 337.5°–22.5°).
enum MoonPhaseName {
  newMoon,
  waxingCrescent,
  firstQuarter,
  waxingGibbous,
  full,
  waningGibbous,
  lastQuarter,
  waningCrescent;

  static MoonPhaseName of(double phaseLongitudeDeg) {
    final l = phaseLongitudeDeg % 360;
    final bin = ((l + 22.5) % 360) ~/ 45;
    return values[bin];
  }
}

/// ADR-022 N4: how the night's moon-free dark time falls.
enum MoonFreeKind {
  /// No dark sample at all: a known absence, not missing data.
  noDark,

  /// Dark time exists, but the Moon is up through all of it.
  none,

  /// Every dark sample is moon-free (one interval).
  allNight,

  /// One interval from the first dark sample, ending before the last.
  evening,

  /// One interval ending at the last dark sample, starting after the first.
  morning,

  /// One interval touching neither end of the dark time.
  middle,

  /// Two or more intervals.
  mixed,
}

/// ADR-022 N4: the night's dark ∧ Moon-down intervals on the 5-minute grid.
/// Each interval runs from its first sample to one step after its last;
/// durations are sample counts × the step.
class MoonFreeNight {
  const MoonFreeNight({
    required this.kind,
    required this.intervals,
    required this.moonFree,
    required this.dark,
  });

  final MoonFreeKind kind;
  final List<(DateTime, DateTime)> intervals;
  final Duration moonFree;
  final Duration dark;

  /// Pure: [instants] on an even grid, [dark] and [moonUp] per instant.
  static MoonFreeNight classify({
    required List<DateTime> instants,
    required List<bool> dark,
    required List<bool> moonUp,
  }) {
    final n = instants.length;
    if (dark.length != n || moonUp.length != n) {
      throw ArgumentError('the three lists must have the same length');
    }
    final step = n < 2 ? Duration.zero : instants[1].difference(instants[0]);
    final darkIndices = [
      for (var i = 0; i < n; i++)
        if (dark[i]) i,
    ];
    if (darkIndices.isEmpty) {
      return const MoonFreeNight(
        kind: MoonFreeKind.noDark,
        intervals: [],
        moonFree: Duration.zero,
        dark: Duration.zero,
      );
    }
    final runs = <(int, int)>[]; // first and last index, inclusive
    int? start;
    for (var i = 0; i < n; i++) {
      final free = dark[i] && !moonUp[i];
      if (free) {
        start ??= i;
      } else if (start != null) {
        runs.add((start, i - 1));
        start = null;
      }
    }
    if (start != null) runs.add((start, n - 1));
    final freeCount = runs.fold(0, (sum, r) => sum + r.$2 - r.$1 + 1);
    final firstDark = darkIndices.first;
    final lastDark = darkIndices.last;
    final kind = switch (runs.length) {
      0 => MoonFreeKind.none,
      1 when freeCount == darkIndices.length => MoonFreeKind.allNight,
      1 when runs.single.$1 == firstDark => MoonFreeKind.evening,
      1 when runs.single.$2 == lastDark => MoonFreeKind.morning,
      1 => MoonFreeKind.middle,
      _ => MoonFreeKind.mixed,
    };
    return MoonFreeNight(
      kind: kind,
      intervals: List.unmodifiable([
        for (final (a, b) in runs) (instants[a], instants[b].add(step)),
      ]),
      moonFree: step * freeCount,
      dark: step * darkIndices.length,
    );
  }
}
