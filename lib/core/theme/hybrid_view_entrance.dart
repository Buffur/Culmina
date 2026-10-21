import 'package:flutter/material.dart';

import 'app_motion.dart';

/// Hybrid's one-shot view entrance. Input changes do not restart it.
class HybridViewEntrance extends StatefulWidget {
  const HybridViewEntrance({
    super.key,
    required this.trigger,
    required this.child,
  });

  final Object trigger;
  final Widget child;

  @override
  State<HybridViewEntrance> createState() => _HybridViewEntranceState();
}

class _HybridViewEntranceState extends State<HybridViewEntrance>
    with SingleTickerProviderStateMixin {
  late final controller = AnimationController(
    vsync: this,
    duration: AppMotion.medium,
  )..forward();

  @override
  void didUpdateWidget(HybridViewEntrance oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trigger != widget.trigger) controller.forward(from: 0);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      return widget.child;
    }
    return _entrance(controller, widget.child);
  }
}

Widget _entrance(Animation<double> animation, Widget child) => AnimatedBuilder(
  animation: animation,
  child: child,
  builder: (context, child) {
    final progress = AppMotion.curve.transform(animation.value);
    return Opacity(
      opacity: .72 + .28 * progress,
      child: Transform.translate(
        offset: Offset(0, 4 * (1 - progress)),
        child: child,
      ),
    );
  },
);

/// Material routes use the same logical-pixel entrance as the root views.
/// Cupertino's interactive edge-back transition is retained by the theme.
class HybridPageTransitionsBuilder extends PageTransitionsBuilder {
  const HybridPageTransitionsBuilder();

  @override
  Duration get transitionDuration => AppMotion.medium;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => (MediaQuery.maybeDisableAnimationsOf(context) ?? false)
      ? child
      : _entrance(animation, child);
}
