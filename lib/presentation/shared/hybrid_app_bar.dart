import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'field_mode_button.dart';
import '../viewmodels/theme_viewmodel.dart';

import '../../core/theme/hybrid_tokens.dart';
import '../../core/theme/app_spacing.dart';

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
  // Scoped screens retain the web's global appearance action. Standalone
  // component hosts may omit the app's theme model.
  final effectiveActions = <Widget>[
    ...?actions,
    if (!(actions?.any((action) => action is FieldModeButton) ?? false) &&
        context.read<ThemeViewModel?>() != null)
      const FieldModeButton(),
  ];
  final hasLeading =
      leading != null ||
      (automaticallyImplyLeading &&
          (Navigator.maybeOf(context)?.canPop() ?? false));
  final spacing =
      titleSpacing ?? (hasLeading ? AppSpacing.sm : AppSpacing.gutter);
  final leadingWidth = hasLeading ? AppSpacing.gutter + 48 : 0.0;
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
                leadingWidth -
                48 * effectiveActions.length -
                AppSpacing.gutter -
                spacing * 2,
          ),
        );
    height = math.max(height, painter.height + 8);
    painter.dispose();
  }
  return AppBar(
    title: title == null
        ? null
        : Builder(
            builder: (context) => DefaultTextStyle(
              style: DefaultTextStyle.of(context).style,
              softWrap: true,
              overflow: TextOverflow.visible,
              // An explicit scaler outranks AppBar's clamped MediaQuery
              // without depending on every MediaQuery field (S10.3).
              child: title is Text && title.data != null
                  ? Text(
                      title.data!,
                      key: title.key,
                      style: title.style,
                      textAlign: title.textAlign,
                      maxLines: title.maxLines,
                      semanticsLabel: title.semanticsLabel,
                      textScaler: title.textScaler ?? scaler,
                    )
                  : title,
            ),
          ),
    leading: hasLeading
        ? Padding(
            padding: const EdgeInsetsDirectional.only(start: AppSpacing.gutter),
            child: leading ?? const BackButton(),
          )
        : null,
    leadingWidth: hasLeading ? leadingWidth : null,
    actions: effectiveActions,
    bottom: bottom,
    automaticallyImplyLeading: automaticallyImplyLeading,
    centerTitle: centerTitle,
    toolbarHeight: height,
    titleSpacing: spacing,
    actionsPadding: const EdgeInsetsDirectional.only(end: AppSpacing.gutter),
    backgroundColor: backgroundColor,
    foregroundColor: foregroundColor,
    elevation: elevation,
    scrolledUnderElevation: scrolledUnderElevation,
  );
}
