import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_theme.dart';
import 'hybrid_icon.dart';

/// Search and optional filter share one contour and retain separate actions.
class SearchFilterBar extends StatefulWidget {
  const SearchFilterBar({
    super.key,
    this.controller,
    this.textFieldKey,
    this.focusNode,
    this.filterKey,
    this.clearKey,
    this.onClear,
    this.clearTooltip = 'Clear search',
    this.filterLabel,
    this.filterCount = 0,
    this.filterCountKey,
    this.labelText,
    this.autocorrect = false,
    this.autofocus = false,
    this.textInputAction = TextInputAction.search,
    this.onChanged,
    this.hintText = 'Search',
    this.onFilter,
    this.filterTooltip = 'Filters',
    this.filtersActive = false,
  });
  final TextEditingController? controller;
  final Key? textFieldKey;
  final FocusNode? focusNode;
  final Key? filterKey;
  final Key? clearKey;
  final VoidCallback? onClear;
  final String clearTooltip;
  final String? filterLabel;
  final int filterCount;
  final Key? filterCountKey;
  final String? labelText;
  final bool autocorrect;
  final bool autofocus;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onChanged;
  final String hintText;
  final VoidCallback? onFilter;
  final String filterTooltip;
  final bool filtersActive;

  @override
  State<SearchFilterBar> createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends State<SearchFilterBar> {
  bool _focused = false;

  Widget _filterIcon(BuildContext context, AppPalette palette) => Badge(
    key: widget.filterCountKey,
    isLabelVisible: widget.filterCount > 0,
    backgroundColor: palette.textPrimary,
    textColor: Theme.of(context).scaffoldBackgroundColor,
    label: Text('${widget.filterCount}'),
    child: HybridIcon(
      HybridIcons.filter,
      size: 20,
      color: widget.filtersActive ? palette.textPrimary : palette.textSecondary,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final shell = Focus(
      onFocusChange: (focused) => setState(() => _focused = focused),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: _focused ? Theme.of(context).focusColor : p.controlBorder,
            width: _focused ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(
            widget.onFilter == null ? AppRadius.small : AppRadius.searchFilter,
          ),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Row(
            children: [
              SizedBox(
                width: widget.onFilter == null ? AppSpacing.md : AppSpacing.lg,
              ),
              HybridIcon(HybridIcons.search, size: 20, color: p.textSecondary),
              Expanded(
                child: Semantics(
                  label: widget.labelText,
                  child: TextField(
                    key: widget.textFieldKey,
                    focusNode: widget.focusNode,
                    autocorrect: widget.autocorrect,
                    autofocus: widget.autofocus,
                    textInputAction: widget.textInputAction,
                    controller: widget.controller,
                    onChanged: widget.onChanged,
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintMaxLines: 2,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: widget.onFilter == null
                            ? AppSpacing.sm
                            : AppSpacing.md + 1,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                    ),
                  ),
                ),
              ),
              if (widget.onClear != null)
                IconButton(
                  key: widget.clearKey,
                  tooltip: widget.clearTooltip,
                  onPressed: widget.onClear,
                  icon: const Icon(Icons.close),
                ),
              if (widget.onFilter != null)
                Semantics(
                  toggled: widget.filtersActive,
                  child: widget.filterLabel != null
                      ? TextButton(
                          key: widget.filterKey,
                          onPressed: widget.onFilter,
                          child: Badge(
                            key: widget.filterCountKey,
                            isLabelVisible: widget.filterCount > 0,
                            backgroundColor: p.textPrimary,
                            textColor: Theme.of(context)
                                .scaffoldBackgroundColor,
                            label: Text('${widget.filterCount}'),
                            child: Text(widget.filterLabel!),
                          ),
                        )
                      : IconButton(
                          key: widget.filterKey,
                          onPressed: widget.onFilter,
                          tooltip: widget.filterTooltip,
                          constraints: const BoxConstraints(
                            minWidth: 48,
                            minHeight: 48,
                          ),
                          icon: _filterIcon(context, p),
                        ),
                ),
              if (widget.onFilter != null) const SizedBox(width: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
    if (widget.labelText == null) return shell;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.labelText!,
          style: AppTextTheme.of(context).body.copyWith(color: p.textPrimary),
        ),
        const SizedBox(height: AppSpacing.sm),
        shell,
      ],
    );
  }
}
