import 'package:flutter/material.dart';

/// A line icon of the Hybrid reference: the web's SVG body on a 24 × 24
/// view box, stroked with round caps and joins in the current icon colour.
/// The bodies are copied verbatim from `design/home-lab` (its own paths and
/// the Lucide subset in `icons.js`, ISC/MIT; see the licence registry).
@immutable
class HybridIconData {
  const HybridIconData(this.body, {this.viewBox = 24});

  /// SVG elements: `path`, `circle`, `rect` and `line`, with optional
  /// `fill="currentColor"`, `stroke="none"` and `stroke-dasharray`.
  final String body;
  final double viewBox;
}

/// The reference's icons by role. Names follow the web dictionaries.
abstract final class HybridIcons {
  // workspace.js `paths` (root navigation, Library, Logbook, Settings).
  static const moon = HybridIconData(
    '<path d="M20 15a8 8 0 0 1-11-11 8 8 0 1 0 11 11Z"/>',
  );
  static const book = HybridIconData(
    '<path d="M4 3h15v18H4V3Zm0 14h15M8 3v14"/>',
  );
  static const library = HybridIconData(
    '<path d="M4 7h16v14H4V7Zm-1-4h18v4H3V3Zm6 8h6"/>',
  );
  static const settings = HybridIconData(
    '<path d="M4 6h16M4 12h16M4 18h16M8 3v6m8 0v6m-6 0v6"/>',
  );
  static const plus = HybridIconData('<path d="M12 5v14M5 12h14"/>');
  static const back = HybridIconData('<path d="M20 12H4m7-7-7 7 7 7"/>');
  static const next = HybridIconData('<path d="m9 5 7 7-7 7"/>');
  static const camera = HybridIconData(
    '<path d="M3 7h4l2-3h6l2 3h4v14H3V7Zm13 7a4 4 0 1 1-8 0 4 4 0 0 1 8 0"/>',
  );
  static const pin = HybridIconData(
    '<path d="M20 10c0 6-8 12-8 12S4 16 4 10a8 8 0 1 1 16 0Zm-5 0a3 3 0 1 1-6 0 3 3 0 0 1 6 0"/>',
  );
  static const target = HybridIconData(
    '<path d="M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Zm-4 0a5 5 0 1 1-10 0 5 5 0 0 1 10 0M12 9v6m-3-3h6"/>',
  );
  static const edit = HybridIconData(
    '<path d="m4 16 12-12 4 4L8 20H4v-4ZM14 6l4 4"/>',
  );
  static const trash = HybridIconData(
    '<path d="M4 6h16M9 6V3h6v3M6 6l1 15h10l1-15M10 10v7m4-7v7"/>',
  );
  static const check = HybridIconData('<path d="m5 12 4 4L19 6"/>');
  static const download = HybridIconData(
    '<path d="M12 3v12m-5-5 5 5 5-5M4 16v5h16v-5"/>',
  );
  static const search = HybridIconData(
    '<path d="m16 16 5 5M18 10a8 8 0 1 1-16 0 8 8 0 0 1 16 0"/>',
  );
  static const filter = HybridIconData('<path d="M4 6h16M7 12h10M10 18h4"/>');

  // app.js `paths` (Tonight).
  static const homeMoon = HybridIconData(
    '<path d="M20.9 13A9 9 0 0 1 11 3.1 9 9 0 1 0 20.9 13Z"/>',
  );
  static const homeSun = HybridIconData(
    '<path d="M12 3v2m0 14v2M3 12h2m14 0h2M5.6 5.6 7 7m10 10 1.4 1.4M5.6 18.4 7 17M17 7l1.4-1.4M16 12a4 4 0 1 1-8 0 4 4 0 0 1 8 0Z"/>',
  );
  static const homeCloud = HybridIconData(
    '<path d="M6 18a4 4 0 0 1-.7-7.9A6 6 0 0 1 17 8a5 5 0 1 1 1 10H6Z"/>',
  );
  static const chevron = HybridIconData('<path d="m9 5 7 7-7 7"/>');
  static const down = HybridIconData('<path d="m6 9 6 6 6-6"/>');
  static const arrow = HybridIconData('<path d="M4 12h15m-6-6 6 6-6 6"/>');
  static const planner = HybridIconData(
    '<path d="M7 3v4m10-4v4M4 10h16M6 5h12a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V7a2 2 0 0 1 2-2Zm3 10h6"/>',
  );
  static const homePin = HybridIconData(
    '<path d="M19 10c0 5-7 11-7 11S5 15 5 10a7 7 0 1 1 14 0Zm-7-2a2 2 0 1 0 0 4 2 2 0 0 0 0-4Z"/>',
  );
  static const close = HybridIconData('<path d="m6 6 12 12M6 18 18 6"/>');
  static const info = HybridIconData(
    '<path d="M12 11v6m0-10v.1M22 12a10 10 0 1 1-20 0 10 10 0 0 1 20 0Z"/>',
  );

  // plan.js `icons` and `classIcons`.
  static const rowChevron = HybridIconData('<path d="m9 6 6 6-6 6"/>');
  static const up = HybridIconData('<path d="M12 19V5m-6 6 6-6 6 6"/>');
  static const downArrow = HybridIconData('<path d="M12 5v14m-6-6 6 6 6-6"/>');
  static const classPhone = HybridIconData(
    '<rect x="7" y="3" width="10" height="18" rx="2"/><path d="M11 18h2"/>',
  );
  static const classDslr = HybridIconData(
    '<path d="M4 8h3l1.5-2h7L17 8h3v11H4z"/><circle cx="12" cy="13.5" r="3.5"/>',
  );
  static const classAstro = HybridIconData(
    '<circle cx="12" cy="12" r="8.5"/><rect x="9" y="9.5" width="6" height="5" rx=".5"/>',
  );
  static const classUnknown = HybridIconData(
    '<circle cx="12" cy="12" r="8.5" stroke-dasharray="3 2.4"/><path d="M9.8 9.6a2.3 2.3 0 1 1 3.3 2.1c-.7.3-1.1.8-1.1 1.5v.5M12 16.4v.1"/>',
  );

  // night-ui.js `symbols` (Night & Moon, Weather).
  static const previous = HybridIconData('<path d="m15 5-7 7 7 7"/>');
  static const nightSun = HybridIconData(
    '<path d="M12 3V1m0 22v-2M3 12H1m22 0h-2M5.6 5.6 4.2 4.2m15.6 15.6-1.4-1.4m-12.8 0-1.4 1.4M19.8 4.2l-1.4 1.4M16 12a4 4 0 1 1-8 0 4 4 0 0 1 8 0"/>',
  );
  static const more = HybridIconData(
    '<path d="M12 5h.01M12 12h.01M12 19h.01"/>',
  );

  /// plan.html `#plan-menu-button`: three stroked dots.
  static const planMore = HybridIconData(
    '<circle cx="12" cy="5" r="1.2"/><circle cx="12" cy="12" r="1.2"/><circle cx="12" cy="19" r="1.2"/>',
  );
  static const nightArrow = HybridIconData('<path d="M5 12h14m-6-6 6 6-6 6"/>');

  // logbook.js `MARKS` (entry states).
  static const markSaved = HybridIconData('<circle cx="12" cy="12" r="8.5"/>');
  static const markCompleted = HybridIconData(
    '<circle cx="12" cy="12" r="8.5"/><path d="m8.5 12.2 2.4 2.4 4.6-5"/>',
  );
  static const markPartly = HybridIconData(
    '<circle cx="12" cy="12" r="8.5"/><path d="M12 3.5v17a8.5 8.5 0 0 0 0-17z" fill="currentColor" stroke="none"/>',
  );
  static const markNotDone = HybridIconData(
    '<circle cx="12" cy="12" r="8.5"/><path d="m9 9 6 6m0-6-6 6"/>',
  );
  static const markDue = HybridIconData(
    '<rect x="5" y="4" width="14" height="16" rx="2"/><path d="M9 4v2h6V4M12 10v4l2.5 1.5"/>',
  );

  // icons.js: Lucide data icons (ISC/MIT), Weather rows.
  static const thermometer = HybridIconData(
    '<path d="M14 4v10.54a4 4 0 1 1-4 0V4a2 2 0 0 1 4 0Z"/>',
  );
  static const droplets = HybridIconData(
    '<path d="M7 16.3c2.2 0 4-1.83 4-4.05 0-1.16-.57-2.26-1.71-3.19S7.29 6.75 7 5.3c-.29 1.45-1.14 2.84-2.29 3.76S3 11.1 3 12.25c0 2.22 1.8 4.05 4 4.05z"/><path d="M12.56 6.6A10.97 10.97 0 0 0 14 3.02c.5 2.5 2 4.9 4 6.5s3 3.5 3 5.5a6.98 6.98 0 0 1-11.91 4.97"/>',
  );
  static const wind = HybridIconData(
    '<path d="M12.8 19.6A2 2 0 1 0 14 16H2"/><path d="M17.5 8a2.5 2.5 0 1 1 2 4H2"/><path d="M9.8 4.4A2 2 0 1 1 11 8H2"/>',
  );
  static const cloudRain = HybridIconData(
    '<path d="M4 14.899A7 7 0 1 1 15.71 8h1.79a4.5 4.5 0 0 1 2.5 8.242"/><path d="M16 14v6"/><path d="M8 14v6"/><path d="M12 16v6"/>',
  );
  static const lucideMoon = HybridIconData(
    '<path d="M20.985 12.486a9 9 0 1 1-9.473-9.472c.405-.022.617.46.402.803a6 6 0 0 0 8.268 8.268c.344-.215.825-.004.803.401"/>',
  );
  static const lucideSun = HybridIconData(
    '<circle cx="12" cy="12" r="4"/><path d="M12 2v2"/><path d="M12 20v2"/><path d="m4.93 4.93 1.41 1.41"/><path d="m17.66 17.66 1.41 1.41"/><path d="M2 12h2"/><path d="M20 12h2"/><path d="m6.34 17.66-1.41 1.41"/><path d="m19.07 4.93-1.41 1.41"/>',
  );
  static const lucideCloud = HybridIconData(
    '<path d="M17.5 19H9a7 7 0 1 1 6.71-9h1.79a4.5 4.5 0 1 1 0 9Z"/>',
  );

  /// Lucide `refresh-cw` (ISC): the candidates' native Refresh.
  static const refresh = HybridIconData(
    '<path d="M3 12a9 9 0 0 1 9-9 9.75 9.75 0 0 1 6.74 2.74L21 8"/><path d="M21 3v5h-5"/><path d="M21 12a9 9 0 0 1-9 9 9.75 9.75 0 0 1-6.74-2.74L3 16"/><path d="M8 16H3v5"/>',
  );
}

/// Paints [data] at [size] logical pixels with a [strokeWidth] in view-box
/// units (the web's `stroke-width`). Decorative: callers give the label.
class HybridIcon extends StatelessWidget {
  const HybridIcon(
    this.data, {
    super.key,
    this.size = 20,
    this.strokeWidth = 1.7,
    this.color,
  });

  final HybridIconData data;
  final double size;
  final double strokeWidth;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c =
        color ??
        IconTheme.of(context).color ??
        DefaultTextStyle.of(context).style.color!;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _HybridIconPainter(
            _SvgBody.parse(data),
            c,
            strokeWidth,
            data.viewBox,
          ),
        ),
      ),
    );
  }
}

class _Shape {
  _Shape(this.path, {this.fill = false, this.stroke = true, this.dash});
  final Path path;
  final bool fill;
  final bool stroke;
  final List<double>? dash;
}

class _SvgBody {
  _SvgBody(this.shapes);
  final List<_Shape> shapes;

  static final _cache = <String, _SvgBody>{};
  static final _element = RegExp(r'<(path|circle|rect|line)\s([^>]*?)/?>');
  static final _attribute = RegExp(r'([\w-]+)="([^"]*)"');

  static _SvgBody parse(HybridIconData data) => _cache.putIfAbsent(
    data.body,
    () {
      final shapes = <_Shape>[];
      for (final m in _element.allMatches(data.body)) {
        final a = {
          for (final x in _attribute.allMatches(m.group(2)!))
            x.group(1)!: x.group(2)!,
        };
        double n(String k, [double d = 0]) => double.tryParse(a[k] ?? '') ?? d;
        final path = switch (m.group(1)) {
          'path' => svgPath(a['d'] ?? ''),
          'circle' =>
            Path()..addOval(
              Rect.fromCircle(center: Offset(n('cx'), n('cy')), radius: n('r')),
            ),
          'rect' =>
            Path()..addRRect(
              RRect.fromRectAndRadius(
                Rect.fromLTWH(n('x'), n('y'), n('width'), n('height')),
                Radius.circular(n('rx', n('ry'))),
              ),
            ),
          _ =>
            Path()
              ..moveTo(n('x1'), n('y1'))
              ..lineTo(n('x2'), n('y2')),
        };
        final dash = a['stroke-dasharray']
            ?.split(RegExp(r'[\s,]+'))
            .map(double.parse)
            .toList();
        shapes.add(
          _Shape(
            path,
            fill: a['fill'] == 'currentColor',
            stroke: a['stroke'] != 'none',
            dash: dash,
          ),
        );
      }
      return _SvgBody(shapes);
    },
  );
}

class _HybridIconPainter extends CustomPainter {
  _HybridIconPainter(this.body, this.color, this.strokeWidth, this.viewBox);
  final _SvgBody body;
  final Color color;
  final double strokeWidth;
  final double viewBox;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / viewBox, size.height / viewBox);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;
    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = color;
    for (final s in body.shapes) {
      if (s.fill) canvas.drawPath(s.path, fill);
      if (!s.stroke) continue;
      canvas.drawPath(
        s.dash == null ? s.path : _dashed(s.path, s.dash!),
        stroke,
      );
    }
    canvas.restore();
  }

  static Path _dashed(Path source, List<double> pattern) {
    final out = Path();
    for (final metric in source.computeMetrics()) {
      var d = 0.0;
      var i = 0;
      while (d < metric.length) {
        final len = pattern[i % pattern.length];
        if (i.isEven) out.addPath(metric.extractPath(d, d + len), Offset.zero);
        d += len;
        i++;
      }
    }
    return out;
  }

  @override
  bool shouldRepaint(_HybridIconPainter old) =>
      old.body != body || old.color != color || old.strokeWidth != strokeWidth;
}

/// Parses SVG path data (all commands, relative and absolute, implicit
/// repeats and packed arc flags) into a [Path].
Path svgPath(String d) {
  final path = Path();
  final tokens = RegExp(
    r'[MmLlHhVvCcSsQqTtAaZz]|[-+]?(?:\d*\.\d+|\d+\.?)(?:[eE][-+]?\d+)?',
  ).allMatches(d).map((m) => m.group(0)!).toList();
  var i = 0;
  var cmd = '';
  var x = 0.0, y = 0.0, sx = 0.0, sy = 0.0;
  double? cx2, cy2, qx, qy; // last control points for S and T
  bool isCmd(String t) => RegExp(r'^[A-Za-z]$').hasMatch(t);
  double num() => double.parse(tokens[i++]);
  // Arc flags may be packed ("011"): read one digit at a time.
  double flag() {
    final t = tokens[i];
    if (t.length > 1 && (t[0] == '0' || t[0] == '1') && !t.contains('.')) {
      tokens[i] = t.substring(1);
      return double.parse(t[0]);
    }
    i++;
    return double.parse(t);
  }

  while (i < tokens.length) {
    if (isCmd(tokens[i])) cmd = tokens[i++];
    final rel = cmd == cmd.toLowerCase();
    final ox = rel ? x : 0.0, oy = rel ? y : 0.0;
    switch (cmd.toUpperCase()) {
      case 'M':
        x = ox + num();
        y = oy + num();
        path.moveTo(x, y);
        sx = x;
        sy = y;
        cmd = rel ? 'l' : 'L'; // following pairs are line-tos
        cx2 = qx = null;
      case 'L':
        x = ox + num();
        y = oy + num();
        path.lineTo(x, y);
        cx2 = qx = null;
      case 'H':
        x = ox + num();
        path.lineTo(x, y);
        cx2 = qx = null;
      case 'V':
        y = oy + num();
        path.lineTo(x, y);
        cx2 = qx = null;
      case 'C':
        final x1 = ox + num(), y1 = oy + num();
        final x2 = ox + num(), y2 = oy + num();
        x = ox + num();
        y = oy + num();
        path.cubicTo(x1, y1, x2, y2, x, y);
        cx2 = x2;
        cy2 = y2;
        qx = null;
      case 'S':
        final x1 = cx2 == null ? x : 2 * x - cx2;
        final y1 = cy2 == null ? y : 2 * y - cy2;
        final x2 = ox + num(), y2 = oy + num();
        x = ox + num();
        y = oy + num();
        path.cubicTo(x1, y1, x2, y2, x, y);
        cx2 = x2;
        cy2 = y2;
        qx = null;
      case 'Q':
        final x1 = ox + num(), y1 = oy + num();
        x = ox + num();
        y = oy + num();
        path.quadraticBezierTo(x1, y1, x, y);
        qx = x1;
        qy = y1;
        cx2 = null;
      case 'T':
        final x1 = qx == null ? x : 2 * x - qx;
        final y1 = qy == null ? y : 2 * y - qy;
        x = ox + num();
        y = oy + num();
        path.quadraticBezierTo(x1, y1, x, y);
        qx = x1;
        qy = y1;
        cx2 = null;
      case 'A':
        final rx = num(), ry = num(), rotation = num();
        final large = flag() != 0, sweep = flag() != 0;
        x = ox + num();
        y = oy + num();
        path.arcToPoint(
          Offset(x, y),
          radius: Radius.elliptical(rx, ry),
          rotation: rotation,
          largeArc: large,
          clockwise: sweep,
        );
        cx2 = qx = null;
      case 'Z':
        path.close();
        x = sx;
        y = sy;
        cx2 = qx = null;
      default:
        i++;
    }
  }
  return path;
}

/// Kept for tests that compare an icon's drawn bounds.
@visibleForTesting
Rect hybridIconBounds(HybridIconData data) {
  var r = Rect.zero;
  for (final s in _SvgBody.parse(data).shapes) {
    r = r.isEmpty ? s.path.getBounds() : r.expandToInclude(s.path.getBounds());
  }
  return r;
}
