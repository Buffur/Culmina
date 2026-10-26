import 'package:flutter/material.dart';

/// The web focus-visible ring in logical pixels, independent of hit geometry.
/// The platform FocusManager retains traversal and route-return ownership.
class HybridFocusHighlight extends StatefulWidget {
  const HybridFocusHighlight({super.key, required this.child});
  final Widget child;

  @override
  State<HybridFocusHighlight> createState() => _HybridFocusHighlightState();
}

class _HybridFocusHighlightState extends State<HybridFocusHighlight>
    with WidgetsBindingObserver {
  final repaint = _FocusRepaint();
  final root = GlobalKey();
  bool _geometryCheckPending = false;
  Rect? _lastRect;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    FocusManager.instance.addListener(_refresh);
    FocusManager.instance.addHighlightModeListener(_highlightChanged);
  }

  void _highlightChanged(FocusHighlightMode mode) => _refresh();

  @override
  void didChangeMetrics() => _refresh();

  void _refresh() {
    repaint.refresh();
    _checkGeometryAfterLayout();
  }

  void _checkGeometryAfterLayout() {
    if (_geometryCheckPending || !mounted) return;
    _geometryCheckPending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _geometryCheckPending = false;
      if (!mounted) return;
      final rect = _focusRingRect(root);
      if (rect != _lastRect) {
        _lastRect = rect;
        repaint.refresh();
      }
      // Descendant inset/route animations can relayout within their own
      // boundary without invalidating this sibling painter. Observe frames
      // while a ring exists, but request paint only when its geometry moves.
      // addPostFrameCallback does not itself schedule another frame.
      if (rect != null) _checkGeometryAfterLayout();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    FocusManager.instance.removeListener(_refresh);
    FocusManager.instance.removeHighlightModeListener(_highlightChanged);
    repaint.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      NotificationListener<ScrollNotification>(
        onNotification: (_) {
          _refresh();
          return false;
        },
        child: Stack(
          key: root,
          fit: StackFit.expand,
          children: [
            widget.child,
            Positioned.fill(
              child: IgnorePointer(
                child: ExcludeSemantics(
                  child: CustomPaint(
                    key: const Key('hybrid.keyboardFocusRing'),
                    painter: _FocusRingPainter(
                      root: root,
                      color: Theme.of(context).colorScheme.primary,
                      repaint: repaint,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}

class _FocusRingPainter extends CustomPainter {
  _FocusRingPainter({
    required this.root,
    required this.color,
    required Listenable repaint,
  }) : super(repaint: repaint);
  final GlobalKey root;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = _focusRingRect(root);
    if (rect == null) return;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_FocusRingPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.root != root;
}

Rect? _focusRingRect(GlobalKey root) {
  if (FocusManager.instance.highlightMode != FocusHighlightMode.traditional) {
    return null;
  }
  final focused = FocusManager.instance.primaryFocus;
  final focusContext = focused?.context;
  final rootBox = root.currentContext?.findRenderObject();
  if (focusContext == null || rootBox is! RenderBox || !rootBox.hasSize) {
    return null;
  }
  RenderObject? target = focusContext.findRenderObject();
  // EditableText's Focus wraps only the text; highlight its whole field.
  focusContext.visitAncestorElements((element) {
    final widget = element.widget;
    if (widget is InputDecorator ||
        widget is ButtonStyleButton ||
        widget is Slider ||
        widget is IconButton) {
      target = element.findRenderObject();
      return false;
    }
    if (widget is Scaffold || widget is Navigator) return false;
    return true;
  });
  final box = target;
  if (box is! RenderBox || !box.attached || !box.hasSize || box.size.isEmpty) {
    return null;
  }
  // A route can leave between focus notification and paint.
  RenderObject? ancestor = box;
  while (ancestor != null && !identical(ancestor, rootBox)) {
    ancestor = ancestor.parent;
  }
  if (ancestor == null) return null;
  final offset = box.localToGlobal(Offset.zero, ancestor: rootBox);
  return (offset & box.size).inflate(4);
}

class _FocusRepaint extends ChangeNotifier {
  void refresh() => notifyListeners();
}
