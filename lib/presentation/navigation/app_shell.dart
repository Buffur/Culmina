import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/feature_scope.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/hybrid_tokens.dart';
import '../../core/theme/hybrid_view_entrance.dart';
import '../shared/app_words.dart';

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

  static List<NavigationDestination> get destinations => [
    const NavigationDestination(
      icon: Icon(Icons.nights_stay_outlined),
      selectedIcon: Icon(Icons.nights_stay),
      label: 'Tonight',
    ),
    if (FeatureScope.logbook)
      const NavigationDestination(
        icon: Icon(Icons.book_outlined),
        selectedIcon: Icon(Icons.book),
        label: AppWords.logbook, // S8.5 (RD-14)
      ),
    const NavigationDestination(
      icon: Icon(Icons.inventory_2_outlined),
      selectedIcon: Icon(Icons.inventory_2),
      label: 'Library',
    ),
    const NavigationDestination(
      icon: Icon(Icons.tune_outlined),
      selectedIcon: Icon(Icons.tune),
      label: 'Settings',
    ),
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
    final selectedSurface =
        identical(theme.extension<HybridTokens>(), HybridTokens.field)
        ? theme.cardColor
        : theme.colorScheme.surface;
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
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: palette.border)),
                ),
                child: largeText
                    ? SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (
                                var row = 0;
                                row < destinations.length;
                                row += 2
                              )
                                Row(
                                  children: [
                                    for (
                                      var i = row;
                                      i < row + 2 && i < destinations.length;
                                      i++
                                    )
                                      Expanded(
                                        child: Semantics(
                                          selected:
                                              i == navigationShell.currentIndex,
                                          child: TextButton(
                                            onPressed: () => select(i),
                                            style: TextButton.styleFrom(
                                              minimumSize: const Size(48, 56),
                                              backgroundColor:
                                                  i ==
                                                      navigationShell
                                                          .currentIndex
                                                  ? selectedSurface
                                                  : null,
                                              foregroundColor:
                                                  i ==
                                                      navigationShell
                                                          .currentIndex
                                                  ? palette.textPrimary
                                                  : palette.textSecondary,
                                            ),
                                            child: Wrap(
                                              alignment: WrapAlignment.center,
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.center,
                                              spacing: 8,
                                              children: [
                                                destinations[i].icon,
                                                Text(
                                                  destinations[i].label,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        fontSize: HybridTokens
                                                            .navigationLabelSize,
                                                        color:
                                                            i ==
                                                                navigationShell
                                                                    .currentIndex
                                                            ? palette
                                                                  .textPrimary
                                                            : palette
                                                                  .textSecondary,
                                                        fontWeight:
                                                            i ==
                                                                navigationShell
                                                                    .currentIndex
                                                            ? FontWeight.w600
                                                            : FontWeight.w400,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      )
                    : NavigationBar(
                        height: 64,
                        labelTextStyle: WidgetStateProperty.resolveWith(
                          (states) => theme.textTheme.bodySmall?.copyWith(
                            fontSize: HybridTokens.navigationLabelSize,
                            fontWeight: states.contains(WidgetState.selected)
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: states.contains(WidgetState.selected)
                                ? palette.textPrimary
                                : palette.textSecondary,
                          ),
                        ),
                        backgroundColor: Theme.of(context)
                            .scaffoldBackgroundColor,
                        indicatorShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        indicatorColor: selectedSurface,
                        selectedIndex: navigationShell.currentIndex,
                        destinations: destinations,
                        // Tapping the current tab again returns to its root.
                        onDestinationSelected: select,
                      ),
              ),
      ),
    );
  }
}
