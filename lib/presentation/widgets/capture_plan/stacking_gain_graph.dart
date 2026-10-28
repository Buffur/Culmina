import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_text_theme.dart';
import '../../../core/theme/hybrid_tokens.dart';
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
    this.caption,
    this.recorded,
  });

  /// The panel's caption ("1 · L · 60 s · gain 100"), when shown.
  final String? caption;

  /// A recorded result's comparable frame count (Logbook), as a ring.
  final int? recorded;

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
      relative == null ? 'Unknown' : '${relative.toStringAsFixed(2)}×';

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
      'Comparison: ${_time(c, c.maxFrames)} · ${_x(c.relativeAt(c.points.last))}';

  /// A recorded result on the plan's curve (logbook.js): "Recorded: 1 h 50
  /// min (110 frames) · 0.96×", √(recorded / planned).
  static String recordedLabel(StackingGainCurve c, int frames) =>
      'Recorded: ${_time(c, frames)} · '
      '${_x(StackingGainCurve.relativeToPlan(frames, c.frames))}';

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
    final hybrid =
        Theme.of(context).extension<HybridTokens>() ?? HybridTokens.light;
    final note = AppTextTheme.of(context)
        .resolve(AppTextTheme.of(context).caption, AppTextGeometry.reading)
        .copyWith(color: palette.textSecondary);
    // plan.js `curvePanel` (Hybrid): caption, y title, the 320 × 150 plot,
    // x title and the legend; 12 above and below the panel.
    return Semantics(
      label: describe(curve, groupLabel),
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (caption != null) ...[
              Text(
                caption!,
                style: AppTextTheme.of(context)
                    .resolve(
                      AppTextTheme.of(context).body,
                      AppTextGeometry.standard,
                    )
                    .copyWith(
                      fontWeight: FontWeight.w600,
                      color: palette.textPrimary,
                    ),
              ),
              const SizedBox(height: 10),
            ],
            Text('Relative to your planned time (1.00×)', style: note),
            const SizedBox(height: 4),
            AspectRatio(
              aspectRatio:
                  StackingGainPainter.width / StackingGainPainter.height,
              child: CustomPaint(
                painter: StackingGainPainter(
                  typography: AppTextTheme.of(context),
                  curve,
                  palette,
                  hybrid: hybrid,
                  surface: Theme.of(context).scaffoldBackgroundColor,
                  recorded: recorded,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Integration time for this group',
              style: note,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // `.gain-legend`: 18 in, 6 between items.
            Padding(
              padding: const EdgeInsets.only(left: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _LegendItem(
                    key: const Key('gainGraph.plan'),
                    swatch: PlanPointSwatch(palette, hybrid: hybrid),
                    text: planLabel(curve),
                    style: note,
                  ),
                  if (recorded case final r?) ...[
                    const SizedBox(height: 6),
                    _LegendItem(
                      key: const Key('gainGraph.recorded'),
                      swatch: RecordedPointSwatch(
                        palette,
                        hybrid: hybrid,
                        surface: Theme.of(context).scaffoldBackgroundColor,
                      ),
                      text: recordedLabel(curve, r),
                      style: note,
                    ),
                  ],
                  const SizedBox(height: 6),
                  _LegendItem(
                    key: const Key('gainGraph.comparison'),
                    swatch: _SquareSwatch(palette),
                    text: comparisonLabel(curve),
                    style: note,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    super.key,
    required this.swatch,
    required this.text,
    required this.style,
  });

  final CustomPainter swatch;
  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 4.4),
        child: SizedBox(
          width: 12,
          height: 12,
          child: CustomPaint(painter: swatch),
        ),
      ),
      const SizedBox(width: 6),
      Expanded(child: Text(text, style: style)),
    ],
  );
}

/// The comparison key: a 12 px square in a 1 px secondary border.
class _SquareSwatch extends CustomPainter {
  _SquareSwatch(this.palette);

  final AppPalette palette;

  @override
  void paint(Canvas canvas, Size size) => canvas.drawRect(
    (Offset.zero & size).deflate(0.5),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = palette.textSecondary,
  );

  @override
  bool shouldRepaint(_SquareSwatch old) => old.palette != palette;
}

/// The plan's key (`.gain-key-plan`): a 12 px disc in the gradient's end.
class PlanPointSwatch extends CustomPainter {
  PlanPointSwatch(this.palette, {this.hybrid});

  final AppPalette palette;
  final HybridTokens? hybrid;

  @override
  void paint(Canvas canvas, Size size) => canvas.drawCircle(
    size.center(Offset.zero),
    size.shortestSide / 2,
    Paint()..color = (hybrid ?? HybridTokens.light).gainEnd,
  );

  @override
  bool shouldRepaint(PlanPointSwatch old) =>
      old.palette != palette || old.hybrid != hybrid;
}

/// The recorded result's key (logbook.js): a ring in the gradient's end.
class RecordedPointSwatch extends CustomPainter {
  RecordedPointSwatch(this.palette, {this.hybrid, required this.surface});

  final AppPalette palette;
  final HybridTokens? hybrid;
  final Color surface;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    canvas.drawCircle(c, size.shortestSide / 2 - 1, Paint()..color = surface);
    canvas.drawCircle(
      c,
      size.shortestSide / 2 - 1,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = (hybrid ?? HybridTokens.light).gainEnd,
    );
  }

  @override
  bool shouldRepaint(RecordedPointSwatch old) =>
      old.palette != palette || old.hybrid != hybrid || old.surface != surface;
}

/// Paints [curve] in the reference's 320 × 150 box (plan.js `curvePanel`):
/// time along x (one frame to the curve's end), √(T / T_plan) along y from
/// 0; grid lines and labels at 0, 1.00× and the top; the axis; the soft area
/// and the gradient line; a dashed guide and the plan's point. Draws exactly
/// the domain's points (tests check). Public for tests.
class StackingGainPainter extends CustomPainter {
  StackingGainPainter(
    this.curve,
    this.palette, {
    this.hybrid,
    this.typography,
    this.surface,
    this.recorded,
  });

  final StackingGainCurve curve;
  final AppPalette palette;
  final AppTextTheme? typography;
  final HybridTokens? hybrid;
  final Color? surface;

  /// A recorded result's frame count, drawn as a ring on the curve.
  final int? recorded;

  static const width = 320.0, height = 150.0;
  static const _l = 48.0, _r = 16.0, _t = 12.0, _b = 30.0;

  @override
  void paint(Canvas canvas, Size size) {
    final h = hybrid ?? HybridTokens.light;
    canvas.save();
    canvas.scale(size.width / width, size.height / height);
    const w = width - _l - _r, ph = height - _t - _b;
    final span = (curve.maxFrames - 1).toDouble();
    final top = curve.relativeAt(curve.points.last) ?? 0;
    double x(int frames) => _l + (span <= 0 ? 0 : (frames - 1) / span * w);
    double y(double r) => _t + ph - (top <= 0 ? 0 : r / top * ph);
    Offset at(GainPoint p) => Offset(x(p.frames), y(curve.relativeAt(p) ?? 0));
    void label(String text, Offset anchor, TextAlign align) {
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: (typography ?? AppTextTheme.standard)
              .resolve(
                (typography ?? AppTextTheme.standard).inherited,
                AppTextGeometry.chartLabel,
              )
              .copyWith(color: palette.textSecondary),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final dx = switch (align) {
        TextAlign.end => anchor.dx - tp.width,
        TextAlign.center => anchor.dx - tp.width / 2,
        _ => anchor.dx,
      };
      // SVG text sits on its baseline.
      tp.paint(
        canvas,
        Offset(
          dx,
          anchor.dy -
              tp.computeDistanceToActualBaseline(TextBaseline.alphabetic),
        ),
      );
    }

    final grid = Paint()
      ..color = palette.border
      ..strokeWidth = 1;
    for (final (v, t) in [
      (0.0, '0'),
      (1.0, '1.00×'),
      (top, '${top.toStringAsFixed(2)}×'),
    ]) {
      canvas.drawLine(Offset(_l, y(v)), Offset(_l + w, y(v)), grid);
      label(t, Offset(_l - 6, y(v) + 4), TextAlign.end);
    }
    canvas.drawPath(
      Path()
        ..moveTo(_l, _t)
        ..lineTo(_l, _t + ph)
        ..lineTo(_l + w, _t + ph),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = palette.controlBorder,
    );
    final line = Path();
    for (final (i, p) in curve.points.indexed) {
      final o = at(p);
      i == 0 ? line.moveTo(o.dx, o.dy) : line.lineTo(o.dx, o.dy);
    }
    final area = Path.from(line)
      ..lineTo(x(curve.maxFrames), _t + ph)
      ..lineTo(x(1), _t + ph)
      ..close();
    final areaBox = area.getBounds();
    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            h.gainEnd.withValues(alpha: 0.28),
            h.gainEnd.withValues(alpha: 0),
          ],
        ).createShader(areaBox),
    );
    if (curve.frames >= 1) {
      final mark = at(GainPoint(curve.frames, curve.markedGain));
      // `.gain-guide`: dashed 3 3 in the control border.
      final guide = Paint()
        ..strokeWidth = 1
        ..color = palette.controlBorder;
      for (var yy = _t + ph; yy > mark.dy; yy -= 6) {
        canvas.drawLine(
          Offset(mark.dx, yy),
          Offset(mark.dx, (yy - 3).clamp(mark.dy, _t + ph)),
          guide,
        );
      }
    }
    final lineBox = line.getBounds();
    canvas.drawPath(
      line,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..shader = LinearGradient(colors: [h.gainStart, h.gainEnd])
            .createShader(lineBox.width < 1 ? lineBox.inflate(1) : lineBox),
    );
    if (recorded case final r? when r >= 1 && r <= curve.maxFrames) {
      final o = Offset(
        x(r),
        y(
          curve.relativeAt(GainPoint(r, curve.markedGain)) ??
              StackingGainCurve.relativeToPlan(r, curve.frames) ??
              0,
        ),
      );
      canvas.drawCircle(o, 5.5, Paint()..color = surface ?? h.onAction);
      canvas.drawCircle(
        o,
        5.5,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = h.gainEnd,
      );
    }
    if (curve.frames >= 1) {
      final mark = at(GainPoint(curve.frames, curve.markedGain));
      paintPoint(canvas, mark, palette, hybrid: h, surface: surface);
    }
    final exposure = Duration(milliseconds: curve.exposureMs);
    if (curve.exposureMs > 0) {
      if (curve.frames > 4) {
        label(
          QuantityText.duration(exposure),
          const Offset(_l, height - 10),
          TextAlign.start,
        );
      }
      label(
        QuantityText.duration(
          Duration(milliseconds: curve.integrationAt(curve.frames)),
        ),
        Offset(x(curve.frames), height - 10),
        TextAlign.center,
      );
      label(
        QuantityText.duration(
          Duration(milliseconds: curve.integrationAt(curve.maxFrames)),
        ),
        const Offset(_l + w, height - 10),
        TextAlign.end,
      );
    }
    canvas.restore();
  }

  /// The plan's point (`.gain-point`): r 5.5 in the gradient's end with a
  /// 1.5 surface stroke.
  static void paintPoint(
    Canvas canvas,
    Offset at,
    AppPalette palette, {
    HybridTokens? hybrid,
    Color? surface,
  }) {
    final h = hybrid ?? HybridTokens.light;
    canvas.drawCircle(at, 5.5, Paint()..color = h.gainEnd);
    canvas.drawCircle(
      at,
      5.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = surface ?? h.onAction,
    );
  }

  @override
  bool shouldRepaint(StackingGainPainter old) =>
      old.typography != typography ||
      old.curve.frames != curve.frames ||
      old.curve.exposureMs != curve.exposureMs ||
      old.palette != palette ||
      old.hybrid != hybrid ||
      old.recorded != recorded;
}
