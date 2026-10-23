import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../../core/theme/app_motion.dart';
import 'culmina_mark_geometry.dart';

/// The Culmina mark, still, as the launch leaves it: the generated geometry
/// and colours (`tool/culmina_mark.py`), the launch size, centred. Shown
/// only when startup is retried after an error; no progress is implied and
/// nothing repeats while it waits.
class StartupMark extends StatelessWidget {
  const StartupMark({super.key, this.canvas = CulminaLaunchTimeline.canvas});

  /// The side of the 108-unit canvas, in logical pixels.
  final double canvas;

  @override
  Widget build(BuildContext context) {
    final colours = Theme.of(context).brightness == Brightness.dark
        ? CulminaMarkColors.dark
        : CulminaMarkColors.light;
    return Semantics(
      label: 'Loading',
      liveRegion: true,
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: canvas,
          child: CustomPaint(painter: CulminaMarkPainter(colours)),
        ),
      ),
    );
  }
}

/// Covers the whole app with [StartupMark] on the first screen's background
/// while [loading] (a retried startup), centred on the screen as the launch
/// mark is, and fades out when loading ends (at once under reduced motion).
class StartupCover extends StatelessWidget {
  const StartupCover({super.key, required this.loading});

  final bool loading;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppMotion.duration(context, AppMotion.medium),
      child: loading
          ? ColoredBox(
              key: const ValueKey('startup.cover'),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: const Center(child: StartupMark()),
            )
          : const SizedBox.shrink(),
    );
  }
}

/// The launch gesture at one moment (owner, 2026-10-23): a pure function of
/// its progress through [CulminaLaunchTimeline.gesture], so the app, the
/// preview and the tests draw the same frames. At 0 and at 1 it is the
/// static mark.
@immutable
class LaunchGestureFrame {
  const LaunchGestureFrame._(
    this.glintStart,
    this.glintEnd,
    this.glintOpacity,
    this.starAccent,
    this.starScale,
  );

  /// The static mark.
  static const still = LaunchGestureFrame._(0, 0, 0, 0, 1);

  /// The frame at [t], 0 to 1.
  factory LaunchGestureFrame.at(double t) {
    double phase((double, double) p, Curve curve) {
      final (a, b) = p;
      return curve.transform(((t - a) / (b - a)).clamp(0.0, 1.0));
    }

    final head = phase(CulminaLaunchTimeline.glintHead, Curves.easeInOutCubic);
    final tail = phase(CulminaLaunchTimeline.glintTail, Curves.easeInOutCubic);
    final opacity = t < CulminaLaunchTimeline.glintOut.$1
        ? phase(CulminaLaunchTimeline.glintIn, Curves.linear)
        : 1 - phase(CulminaLaunchTimeline.glintOut, Curves.linear);
    final accent = t < CulminaLaunchTimeline.starDown.$1
        ? phase(CulminaLaunchTimeline.starUp, Curves.easeOutCubic)
        : 1 - phase(CulminaLaunchTimeline.starDown, Curves.easeInOutCubic);
    return LaunchGestureFrame._(
      tail,
      head,
      head > tail ? opacity : 0,
      accent,
      lerpDouble(1, CulminaLaunchTimeline.starScale, accent)!,
    );
  }

  /// The light along the inner arc: its trailing and leading ends as
  /// fractions of the arc's length, and its opacity.
  final double glintStart;
  final double glintEnd;
  final double glintOpacity;

  /// The star's accent, 0 (static) to 1 (peak colour), and its scale.
  final double starAccent;
  final double starScale;

  bool get isStill => glintOpacity == 0 && starAccent == 0 && starScale == 1;
}

/// Paints the mark on its 108-unit canvas, scaled to the painted size; with
/// a [frame], that moment of the launch gesture.
class CulminaMarkPainter extends CustomPainter {
  const CulminaMarkPainter(
    this.colours, {
    this.frame = LaunchGestureFrame.still,
  });

  final CulminaMarkColors colours;
  final LaunchGestureFrame frame;

  static double _rad(double degrees) => degrees * math.pi / 180;

  static const _centre = Offset(54, 54);

  /// A counter-clockwise arc (y up) as Flutter's clockwise angles (y down),
  /// as a path that runs from `start` to `end`.
  static Path _arc(double radius, double start, double end) => Path()
    ..addArc(
      Rect.fromCircle(center: _centre, radius: radius),
      _rad(-start),
      _rad(-(end - start)),
    );

  static final _inner = _arc(
    CulminaMarkGeometry.innerRadius,
    CulminaMarkGeometry.innerStart,
    CulminaMarkGeometry.innerEnd,
  );

  static final _outer = _arc(
    CulminaMarkGeometry.outerRadius,
    CulminaMarkGeometry.outerStart,
    CulminaMarkGeometry.outerEnd,
  );

  static final _star = () {
    const s = CulminaMarkGeometry.star;
    final path = Path()..moveTo(s[0], s[1]);
    for (var i = 2; i + 3 < s.length; i += 4) {
      path.quadraticBezierTo(s[i], s[i + 1], s[i + 2], s[i + 3]);
    }
    return path..close();
  }();

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.shortestSide / CulminaMarkGeometry.canvas);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      _inner,
      stroke
        ..color = colours.inner
        ..strokeWidth = CulminaMarkGeometry.innerStroke,
    );
    if (frame.glintOpacity > 0) {
      // The light keeps the inner arc's own width and caps: the silhouette
      // never changes.
      final metric = _inner.computeMetrics().first;
      canvas.drawPath(
        metric.extractPath(
          metric.length * frame.glintStart,
          metric.length * frame.glintEnd,
        ),
        stroke..color = colours.glint.withValues(alpha: frame.glintOpacity),
      );
    }
    canvas.drawPath(
      _outer,
      stroke
        ..color = colours.orbit
        ..strokeWidth = CulminaMarkGeometry.outerStroke,
    );
    const centre = Offset(CulminaMarkGeometry.starX, CulminaMarkGeometry.starY);
    canvas
      ..save()
      ..translate(centre.dx, centre.dy)
      ..scale(frame.starScale)
      ..translate(-centre.dx, -centre.dy)
      ..drawPath(
        _star,
        Paint()
          ..color = Color.lerp(
            colours.star,
            colours.starPeak,
            frame.starAccent,
          )!,
      )
      ..restore()
      ..restore();
  }

  @override
  bool shouldRepaint(CulminaMarkPainter old) =>
      old.colours != colours || old.frame != frame;
}
