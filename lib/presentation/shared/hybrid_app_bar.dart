import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/hybrid_tokens.dart';

/// Standard native AppBar with the approved uncapped title and wrapping height.
/// Captures the user's scale before AppBar's internal title-only scale clamp.
AppBar hybridAppBar(
  BuildContext context, {
  Widget? title,
  Widget? leading,
  List<Widget>? actions,
  PreferredSizeWidget? bottom,
  bool automaticallyImplyLeading = true,
  bool? centerTitle,
  double? toolbarHeight,
  double? titleSpacing,
  Color? backgroundColor,
  Color? foregroundColor,
  double? elevation,
  double? scrolledUnderElevation,
}) {
  final scaler = MediaQuery.textScalerOf(context);
  final theme = Theme.of(context);
  final hasLeading =
      leading != null ||
      (automaticallyImplyLeading &&
          (Navigator.maybeOf(context)?.canPop() ?? false));
  final spacing = titleSpacing ?? (hasLeading ? 8.0 : 16.0);
  var height = math.max(HybridTokens.appBarHeight, toolbarHeight ?? 0);
  if (title is Text && title.data != null) {
    final style =
        theme.appBarTheme.titleTextStyle ?? theme.textTheme.titleLarge;
    final painter =
        TextPainter(
          text: TextSpan(text: title.data, style: style?.merge(title.style)),
          textDirection: Directionality.of(context),
          textScaler: title.textScaler ?? scaler,
        )..layout(
          maxWidth: math.max(
            48,
            MediaQuery.sizeOf(context).width -
                (hasLeading ? 56 : 0) -
                48 * (actions?.length ?? 0) -
                spacing * 2,
          ),
        );
    height = math.max(height, painter.height + 8);
    painter.dispose();
  }
  return AppBar(
    title: title == null
        ? null
        : MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: scaler),
            child: Builder(
              builder: (context) => DefaultTextStyle(
                style: DefaultTextStyle.of(context).style,
                softWrap: true,
                overflow: TextOverflow.visible,
                child: title,
              ),
            ),
          ),
    leading: leading,
    actions: actions,
    bottom: bottom,
    automaticallyImplyLeading: automaticallyImplyLeading,
    centerTitle: centerTitle,
    toolbarHeight: height,
    titleSpacing: spacing,
    backgroundColor: backgroundColor,
    foregroundColor: foregroundColor,
    elevation: elevation,
    scrolledUnderElevation: scrolledUnderElevation,
  );
}
