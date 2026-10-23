import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/feature_scope.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/hybrid_tokens.dart';
import '../../core/theme/hybrid_view_entrance.dart';
import '../shared/app_words.dart';
import '../shared/hybrid_icon.dart';
import '../../core/theme/app_typography.dart';

/// The bottom-navigation shell of ADR-015 (TASK 12.2): Tonight · Logbook ·
/// Library · Settings, one navigator per tab.
///
/// Back (ADR-015 §3): pops within the current tab first (go_router); at a
/// tab's root it returns to Tonight; at Tonight's root it leaves the app.
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.navigationShell,
    this.showNavigation = true,
  });

  final StatefulNavigationShell navigationShell;
  final bool showNavigation;

  /// The root navigation bar (for tests and the host renders).
  static const navigationKey = Key('app.navigation');

  /// The four roots with the reference's line icons (workspace.js `paths`).
  static List<({HybridIconData icon, String label})> get items => [
    (icon: HybridIcons.moon, label: 'Tonight'),
    if (FeatureScope.logbook)
      (icon: HybridIcons.book, label: AppWords.logbook), // S8.5 (RD-14)
    (icon: HybridIcons.library, label: 'Library'),
    (icon: HybridIcons.settings, label: 'Settings'),
  ];

  /// Kept for callers that list the destinations' labels.
  static List<NavigationDestination> get destinations => [
    for (final i in items)
      NavigationDestination(icon: HybridIcon(i.icon), label: i.label),
  ];

  @override
  Widget build(BuildContext context) {
    final onTonight = navigationShell.currentIndex == 0;
    void select(int i) => navigationShell.goBranch(
      i,
      initialLocation: i == navigationShell.currentIndex,
    );
    final largeText = MediaQuery.textScalerOf(context).scale(1) >= 1.5;
    final theme = Theme.of(context);
    final palette = AppPalette.of(context);
    final hybrid = theme.extension<HybridTokens>() ?? HybridTokens.light;
    // workspace.css `.app-nav` (Hybrid): a subtle top rule, padding 8 4,
    // four equal 56 px buttons 2 apart; the selected one on the subtle
    // surface (radius 6) in 600 primary, the others 400 secondary; a 19 px
    // icon 5 above the 11 px Roboto label. At large text, two per row.
    Widget button(int i) {
      final selected = i == navigationShell.currentIndex;
      final color = selected ? palette.textPrimary : palette.textSecondary;
      final item = items[i];
      return Semantics(
        selected: selected,
        button: true,
        label: item.label,
        excludeSemantics: true,
        child: Material(
          color: selected ? hybrid.surfaceSubtle : HybridTokens.transparent,
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            key: Key('nav.${item.label.toLowerCase()}'),
            borderRadius: BorderRadius.circular(6),
            onTap: () => select(i),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 56),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Center(
                  child: Wrap(
                    direction: largeText ? Axis.horizontal : Axis.vertical,
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: largeText ? 8 : 5,
                    children: [
                      HybridIcon(
                        item.icon,
                        size: MediaQuery.textScalerOf(context).scale(19),
                        color: color,
                      ),
                      Text(
                        item.label,
                        textAlign: TextAlign.center,
                        style: AppTypography.navigationLabel.copyWith(
                          color: color,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final perRow = largeText ? 2 : items.length;
    return PopScope(
      canPop: onTonight,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) navigationShell.goBranch(0);
      },
      child: Scaffold(
        body: HybridViewEntrance(
          trigger: navigationShell.currentIndex,
          child: navigationShell,
        ),
        bottomNavigationBar: !showNavigation
            ? null
            : DecoratedBox(
                key: navigationKey,
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  border: Border(top: BorderSide(color: palette.border)),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var row = 0; row < items.length; row += perRow)
                          Padding(
                            padding: EdgeInsets.only(top: row == 0 ? 0 : 2),
                            child: Row(
                              children: [
                                for (
                                  var i = row;
                                  i < row + perRow && i < items.length;
                                  i++
                                ) ...[
                                  if (i > row) const SizedBox(width: 2),
                                  Expanded(child: button(i)),
                                ],
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
