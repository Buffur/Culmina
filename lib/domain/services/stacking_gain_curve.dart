import 'dart:math' as math;

import 'optical_calculator.dart';

/// One point of a [StackingGainCurve]: after [frames] frames of one group,
/// the random noise is [gain] times lower than in one frame of that group.
class GainPoint {
  const GainPoint(this.frames, this.gain);

  final int frames;
  final double gain;

  @override
  bool operator ==(Object other) =>
      other is GainPoint && other.frames == frames && other.gain == gain;

  @override
  int get hashCode => Object.hash(frames, gain);

  @override
  String toString() => 'GainPoint($frames, $gain)';
}

/// How the relative stacking gain grows with the frame count, for one group
/// of comparable light frames (S6.11; P6.10; CALC-42; ADR-021 C16). The
/// same formula as the figure it illustrates, √N (CALC-15), sampled from
/// one frame to [maxFrames] (twice the planned count, at least 4), so the
/// flattening is visible. O2b (PD-05; F11) draws it against integration
/// time T = N · t, normalized to the plan: [relativeToPlan] is √(T / T_plan),
/// 1 at the plan. Relative only (SI-003): never a signal-to-noise ratio, a
/// noise model or an image-quality prediction, and never combined across
/// groups. A graph draws these points and computes nothing.
class StackingGainCurve {
  StackingGainCurve._(
    this.frames,
    this.maxFrames,
    this.points, {
    required this.exposureMs,
  });

  /// The curve for a group of [frames] planned frames, with at most
  /// [samples] points (at least 2); always includes one frame, [frames]
  /// and [maxFrames]. Null-free: [frames] below 1 gives a curve with no
  /// marked point beyond the start. [exposureMs] is the group's one
  /// exposure, for the time axis (0: not known).
  factory StackingGainCurve.of(
    int frames, {
    int exposureMs = 0,
    int samples = 32,
  }) {
    final planned = math.max(frames, 1);
    final maxFrames = math.max(4, 2 * planned);
    final n = math.max(samples, 2);
    final counts = <int>{
      for (var i = 0; i < n; i++) 1 + ((maxFrames - 1) * i / (n - 1)).round(),
      planned,
    }.toList()..sort();
    return StackingGainCurve._(frames, maxFrames, exposureMs: exposureMs, [
      for (final c in counts)
        GainPoint(c, OpticalCalculator.calculateRelativeStackingGain(c)),
    ]);
  }

  /// O2b (PD-05; R-O2-1): √(T / T_plan), the improvement of integration
  /// [integrationMs] relative to the plan's [planMs], under the same
  /// idealization as √N (equal frames, random noise only). 0 for no
  /// integration; null without a plan to compare with (never a made-up
  /// reference).
  static double? relativeToPlan(int integrationMs, int planMs) =>
      planMs <= 0 || integrationMs < 0
      ? null
      : math.sqrt(integrationMs / planMs);

  /// The planned count (the marked point).
  final int frames;

  /// Where the curve ends: twice [frames], at least 4.
  final int maxFrames;

  /// Increasing in frames, from 1 to [maxFrames].
  final List<GainPoint> points;

  /// The marked value: √[frames] (0 without frames), as the group's figure.
  double get markedGain =>
      OpticalCalculator.calculateRelativeStackingGain(frames);

  /// The gain at [maxFrames], the curve's end.
  double get endGain => points.last.gain;

  /// The group's one exposure, in milliseconds (0: not known).
  final int exposureMs;

  /// T = N · t at [frames] frames.
  int integrationAt(int frames) => frames * exposureMs;

  /// The plan's integration, T_plan.
  int get planIntegrationMs => integrationAt(frames);

  /// [relativeToPlan] at [p]: 1 at the plan, √2 at twice its time. With the
  /// exposure not known it is √(N / N_plan), the same ratio.
  double? relativeAt(GainPoint p) => exposureMs > 0
      ? relativeToPlan(integrationAt(p.frames), planIntegrationMs)
      : relativeToPlan(p.frames, frames);
}
