import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// A measured bottom sibling: scroll content never extends behind the action.
class CatalogScaffold extends StatelessWidget {
  const CatalogScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.searchBar,
    this.bottomAction,
  });
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? searchBar;
  final Widget? bottomAction;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: appBar,
    body: SafeArea(
      bottom: bottomAction == null,
      child: Column(
        children: [
          if (searchBar != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                AppSpacing.sm,
                AppSpacing.gutter,
                AppSpacing.md,
              ),
              child: searchBar!,
            ),
          Expanded(child: body),
        ],
      ),
    ),
    bottomNavigationBar: bottomAction,
  );
}

class StickyBottomAction extends StatelessWidget {
  const StickyBottomAction({super.key, required this.child, this.note});
  final Widget child;
  final Widget? note;

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).scaffoldBackgroundColor,
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.gutter,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (note != null) ...[note!, const SizedBox(height: AppSpacing.sm)],
            child,
          ],
        ),
      ),
    ),
  );
}
