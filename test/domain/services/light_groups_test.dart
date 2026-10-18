// F11 (PD-05 O2b; ADR-021 C16; R-O2-1/V12): relative-gain groups and the
// improvement over integration time, normalized to the plan.
// A1: √(T / T_plan) for ratios 0.5, 1 and 2 (±0.0001).
// A2: zero integration, no plan, mixed and unknown settings have stated
// outcomes; an unknown ISO or gain never proves two blocks one group, and
// calibration frames never count.

import 'dart:math' as math;

import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/services/capture_budget_calculator.dart';
import 'package:astroplan/domain/services/stacking_gain_curve.dart';
import 'package:flutter_test/flutter_test.dart';

CaptureBlock _b(
  double s,
  int n, {
  String? filter = 'Ha',
  CaptureGain? gain,
  int binning = 1,
  FrameType type = FrameType.light,
}) => CaptureBlock(
  frameType: type,
  filterName: filter,
  exposureTimeSeconds: s,
  frameCount: n,
  gain: gain ?? CaptureGain.gain(100),
  binning: binning,
);

List<LightGroup> _groups(List<CaptureBlock> blocks) =>
    CaptureBudgetCalculator.calculate(blocks: blocks).lightGroups;

void main() {
  group('A1: R-O2-1, plan 120 × 60 s (T_plan = 2 h)', () {
    const hour = 3600000;
    test('1 h, 2 h, 4 h → 0.7071, 1.0000, 1.4142', () {
      for (final (t, expected) in [
        (1 * hour, 0.7071),
        (2 * hour, 1.0),
        (4 * hour, 1.4142),
      ]) {
        expect(
          StackingGainCurve.relativeToPlan(t, 2 * hour),
          closeTo(expected, 0.0001),
          reason: '$t',
        );
      }
    });

    test("the group's curve: 1 at the plan, √2 at its end (twice the time); "
        'R-O2-2 keeps √N against one frame', () {
      final g = _groups([_b(60, 120)]).single;
      expect(g.integrationMs, 2 * hour);
      final c = g.gainCurve;
      expect(c.planIntegrationMs, 2 * hour);
      final plan = c.points.firstWhere((p) => p.frames == 120);
      expect(c.relativeAt(plan), 1);
      expect(c.relativeAt(c.points.last), closeTo(1.4142, 0.0001));
      expect(c.integrationAt(c.maxFrames), 4 * hour);
      expect(g.relativeStackingGain, closeTo(10.954, 0.001));
      expect(c.endGain, closeTo(15.492, 0.001));
      for (final p in c.points) {
        expect(
          c.relativeAt(p),
          closeTo(math.sqrt(p.frames * 60000 / (2 * hour)), 1e-12),
        );
      }
    });
  });

  group('A2: truthful groups and states', () {
    test('zero integration is 0; with no plan there is no reference', () {
      expect(StackingGainCurve.relativeToPlan(0, 3600000), 0);
      expect(StackingGainCurve.relativeToPlan(3600000, 0), isNull);
      expect(StackingGainCurve.of(0).relativeAt(const GainPoint(1, 1)), isNull);
    });

    test('no light frames: no group (calibration never counts)', () {
      expect(_groups([]), isEmpty);
      expect(
        _groups([
          _b(60, 20, type: FrameType.dark),
          _b(1, 20, type: FrameType.flat),
          _b(0.001, 20, type: FrameType.bias),
        ]),
        isEmpty,
      );
      final g = _groups([_b(60, 20), _b(60, 20, type: FrameType.dark)]).single;
      expect(g.frames, 20);
    });

    test('the filter is compared trimmed and case-folded, no aliases', () {
      final g = _groups([
        _b(60, 10),
        _b(60, 5, filter: ' HA '),
        _b(60, 7, filter: 'H-alpha'),
      ]);
      expect(g.map((g) => (g.filterName, g.frames)), [
        ('Ha', 15),
        ('H-alpha', 7),
      ]);
    });

    test('a known different ISO or gain, its kind, exposure or binning '
        'splits the group', () {
      final g = _groups([
        _b(60, 10),
        _b(60, 10, gain: CaptureGain.gain(200)),
        _b(60, 10, gain: CaptureGain.iso(100)),
        _b(60, 10, binning: 2),
        _b(120, 10),
        _b(60, 4),
      ]);
      expect(g.map((g) => (g.sensitivity, g.binning, g.exposureMs, g.frames)), [
        (CaptureGain.gain(100), 1, 60000, 14),
        (CaptureGain.gain(200), 1, 60000, 10),
        (CaptureGain.iso(100), 1, 60000, 10),
        (CaptureGain.gain(100), 2, 60000, 10),
        (CaptureGain.gain(100), 1, 120000, 10),
      ]);
      expect(g.every((g) => g.comparable), isTrue);
    });

    test('an unknown ISO or gain never proves two blocks one group', () {
      final g = _groups([
        _b(60, 10, gain: CaptureGain.none),
        _b(60, 10, gain: CaptureGain.none),
        _b(60, 10, gain: CaptureGain.unknown(800)),
        _b(60, 10),
      ]);
      expect(g.map((g) => (g.comparable, g.frames)), [
        (false, 10),
        (false, 10),
        (false, 10),
        (true, 10),
      ]);
      // Within one block the frames are alike: its √N stands.
      expect(g.first.relativeStackingGain, math.sqrt(10));
    });
  });
}
