import 'package:flutter/material.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/hybrid_tokens.dart';

/// A quiet, non-interactive group of existing document content.
///
/// Does not clip, merge semantics, impose a height or change focus order.
/// Joined pieces let a lazy list draw one continuous group without laying out
/// all its rows at once (the Logbook's month groups).
class DocumentSection extends StatelessWidget {
  const DocumentSection({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.joinPrevious = false,
    this.joinNext = false,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final bool joinPrevious;
  final bool joinNext;

  @override
  Widget build(BuildContext context) {
    const corner = Radius.circular(AppRadius.menu);
    return Material(
      color:
          Theme.of(context).extension<HybridTokens>()?.surfaceSubtle ??
          Theme.of(context).cardColor,
      borderRadius: BorderRadius.vertical(
        top: joinPrevious ? Radius.zero : corner,
        bottom: joinNext ? Radius.zero : corner,
      ),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }
}
