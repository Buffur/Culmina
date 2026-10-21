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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    FocusManager.instance.addListener(repaint.refresh);
    FocusManager.instance.addHighlightModeListener(_highlightChanged);
  }

  void _highlightChanged(FocusHighlightMode mode) => repaint.refresh();

  @override
  void didChangeMetrics() => repaint.refresh();

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    FocusManager.instance.removeListener(repaint.refresh);
    FocusManager.instance.removeHighlightModeListener(_highlightChanged);
    repaint.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      NotificationListener<ScrollNotification>(
        onNotification: (_) {
          repaint.refresh();
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
    if (FocusManager.instance.highlightMode != FocusHighlightMode.traditional) {
      return;
    }
    final focused = FocusManager.instance.primaryFocus;
    final focusContext = focused?.context;
    final rootBox = root.currentContext?.findRenderObject();
    if (focusContext == null || rootBox is! RenderBox || !rootBox.hasSize) {
      return;
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
    if (box is! RenderBox ||
        !box.attached ||
        !box.hasSize ||
        box.size.isEmpty) {
      return;
    }
    // A route can leave between focus notification and paint.
    RenderObject? ancestor = box;
    while (ancestor != null && !identical(ancestor, rootBox)) {
      ancestor = ancestor.parent;
    }
    if (ancestor == null) return;
    final offset = box.localToGlobal(Offset.zero, ancestor: rootBox);
    final rect = (offset & box.size).inflate(4);
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

class _FocusRepaint extends ChangeNotifier {
  void refresh() => notifyListeners();
}
