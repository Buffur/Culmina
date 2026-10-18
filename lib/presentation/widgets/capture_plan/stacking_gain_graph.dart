import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/quantity_text.dart';
import '../../../domain/services/capture_budget_calculator.dart';
import '../../../domain/services/stacking_gain_curve.dart';
import '../../shared/app_words.dart';
import '../../shared/calibration_text.dart';

/// "How does the relative improvement change with integration time?"
/// (S6.11; P6.10; PD-05 O2b; F11), for one comparable group (ADR-021 C16):
/// the curve from one frame to twice the planned count against integration
/// time T = N · t, normalized to the plan: √(T / T_plan), 1.00x at the plan.
/// It draws the domain's points ([StackingGainCurve], CALC-42) and computes
/// nothing; the group's √N against one frame stays in the line above, out
/// of Details. Relative only (SI-003).
///
/// S6.16 (TD-076): the plan's own point is named — "Your plan", its time and
/// value, beside a swatch drawn like the dot — and the curve's end is
/// named as a comparison, so it never reads as a target or a recommendation.
class StackingGainGraph extends StatelessWidget {
  const StackingGainGraph({
    super.key,
    required this.curve,
    required this.groupLabel,
  });

  final StackingGainCurve curve;

  /// The group, e.g. "Ha · 60 s · gain 100", for the text alternative.
  final String groupLabel;

  /// The group's name in the plan's outputs (C16): filter, exposure, the
  /// recorded ISO or gain and, above 1, binning, so that groups split by a
  /// setting say which.
  static String groupName(LightGroup g) => [
    g.filterName ?? 'No filter',
    QuantityText.exposure(g.exposureMs / 1000),
    CalibrationText.sensitivity(g.sensitivity),
    if (g.binning > 1) 'bin ${g.binning}',
  ].join(' · ');

  static String _x(double? relative) =>
      relative == null ? 'Unknown' : '${relative.toStringAsFixed(2)}x';

  static String _time(StackingGainCurve c, int frames) {
    final n = '$frames frame${frames == 1 ? '' : 's'}';
    return c.exposureMs > 0
        ? '${QuantityText.duration(Duration(milliseconds: c.integrationAt(frames)))} ($n)'
        : n;
  }

  /// The plan's point, as its label says it: "Your plan: 2 h (120 frames)
  /// · 1.00x" (TD-076; O2b).
  static String planLabel(StackingGainCurve c) =>
      '${AppWords.yourPlan}: ${_time(c, c.frames)} · '
      '${_x(c.relativeAt(GainPoint(c.frames, c.markedGain)))}';

  /// The curve's end, named as a comparison (TD-076).
  static String comparisonLabel(StackingGainCurve c) =>
      'For comparison: ${_time(c, c.maxFrames)} · ${_x(c.relativeAt(c.points.last))}';

  /// The text alternative: the plan's point, half its time (R-O2-1) and
  /// where the curve ends, for comparison; relative to the plan only.
  static String describe(StackingGainCurve c, String groupLabel) {
    final half = c.planIntegrationMs > 0
        ? StackingGainCurve.relativeToPlan(
            c.planIntegrationMs ~/ 2,
            c.planIntegrationMs,
          )
        : StackingGainCurve.relativeToPlan(c.frames, c.frames * 2);
    return 'Relative improvement over integration time, $groupLabel: '
        '1.00x at your plan, ${_time(c, c.frames)}; ${_x(half)} at half '
        'that time; ${_x(c.relativeAt(c.points.last))} at '
        '${_time(c, c.maxFrames)}, for comparison. Relative to your plan, '
        'not a signal-to-noise ratio.';
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final text = Theme.of(context).textTheme;
    final small = text.bodySmall?.copyWith(color: palette.textTertiary);
    return Semantics(
      label: describe(curve, groupLabel),
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 48,
              child: CustomPaint(painter: StackingGainPainter(curve, palette)),
            ),
            // The axis' ends, as text so it scales and wraps (200 %).
            Row(
              children: [
                Expanded(child: Text(_time(curve, 1), style: small)),
                Flexible(
                  child: Text(
                    comparisonLabel(curve),
                    key: const Key('gainGraph.comparison'),
                    style: small,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            // The plan's point, keyed to the dot by the same drawing.
            Row(
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CustomPaint(painter: PlanPointSwatch(palette)),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    planLabel(curve),
                    key: const Key('gainGraph.plan'),
                    style: text.bodySmall?.copyWith(color: palette.textPrimary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The plan's point as the graph draws it (S6.16, TD-076), for its label.
class PlanPointSwatch extends CustomPainter {
  PlanPointSwatch(this.palette);

  final AppPalette palette;

  @override
  void paint(Canvas canvas, Size size) =>
      StackingGainPainter.paintPoint(canvas, size.center(Offset.zero), palette);

  @override
  bool shouldRepaint(PlanPointSwatch old) => old.palette != palette;
}

/// Paints [curve]: integration time along x (from one frame to its end;
/// one exposure, so in proportion to the frame count), √(T / T_plan) along y
/// (from 0); the plan as a guide line and a dot. Public for tests, which
/// check that it draws exactly the domain's points.
class StackingGainPainter extends CustomPainter {
  StackingGainPainter(this.curve, this.palette);

  final StackingGainCurve curve;
  final AppPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final span = (curve.maxFrames - 1).toDouble();
    final top = curve.relativeAt(curve.points.last) ?? 0;
    Offset at(GainPoint p) => Offset(
      span <= 0 ? 0 : (p.frames - 1) / span * size.width,
      size.height -
          (top <= 0 ? 0 : (curve.relativeAt(p) ?? 0) / top) * (size.height - 4),
    );

    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      Paint()
        ..color = palette.chartGrid
        ..strokeWidth = 1,
    );
    final path = Path();
    for (final (i, p) in curve.points.indexed) {
      final o = at(p);
      i == 0 ? path.moveTo(o.dx, o.dy) : path.lineTo(o.dx, o.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = palette.chartTarget
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    if (curve.frames >= 1) {
      final mark = at(GainPoint(curve.frames, curve.markedGain));
      canvas.drawLine(
        Offset(mark.dx, size.height),
        mark,
        Paint()
          ..color = palette.chartGrid
          ..strokeWidth = 1,
      );
      paintPoint(canvas, mark, palette);
    }
  }

  /// The plan's point: the altitude chart's "now" dot (S6.11); its label's
  /// swatch draws the same (S6.16).
  static void paintPoint(Canvas canvas, Offset at, AppPalette palette) {
    canvas.drawCircle(at, 5, Paint()..color = palette.chartNow);
    canvas.drawCircle(at, 2, Paint()..color = palette.chartNowCentre);
  }

  @override
  bool shouldRepaint(StackingGainPainter old) =>
      old.curve.frames != curve.frames ||
      old.curve.exposureMs != curve.exposureMs ||
      old.palette != palette;
}
