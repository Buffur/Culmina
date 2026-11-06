import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_theme.dart';
import 'hybrid_icon.dart';
import 'hybrid_quiet_ink.dart';
import 'hybrid_parts.dart' show HybridRadio;

enum ActionRowVariant { navigation, radio, edit }

/// A flat, wrapping action with an independently reachable edit affordance.
class ActionRow extends StatelessWidget {
  const ActionRow({
    super.key,
    required this.title,
    this.description,
    this.titleKey,
    this.descriptionKey,
    this.onTap,
    this.variant = ActionRowVariant.navigation,
    this.selected = false,
    this.onEdit,
    this.editKey,
    this.editTooltip = 'Edit',
    this.leading,
    this.trailing,
  });

  final String title;
  final String? description;
  final Key? titleKey;
  final Key? descriptionKey;
  final VoidCallback? onTap;
  final ActionRowVariant variant;
  final bool selected;
  final VoidCallback? onEdit;
  final Key? editKey;
  final String editTooltip;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final t = AppTextTheme.of(context);
    final titleWidget = Text(
      title,
      key: titleKey,
      style: t.rowTitle.copyWith(
        color: variant == ActionRowVariant.radio
            ? p.textPrimary
            : p.textSecondary,
      ),
    );
    final action = Semantics(
      button: onTap != null,
      checked: variant == ActionRowVariant.radio ? selected : null,
      selected: variant == ActionRowVariant.radio ? selected : null,
      inMutuallyExclusiveGroup: variant == ActionRowVariant.radio,
      child: InkWell(
        overlayColor: HybridQuietInk.overlay(context),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: AppSpacing.itemGap),
                ],
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (variant == ActionRowVariant.radio)
                        Row(
                          children: [
                            HybridRadio(checked: selected),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(child: titleWidget),
                          ],
                        )
                      else
                        titleWidget,
                      if (description != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Padding(
                          padding: EdgeInsetsDirectional.only(
                            start: variant == ActionRowVariant.radio
                                ? AppSpacing.sm * 2
                                : 0,
                          ),
                          child: Text(
                            description!,
                            key: descriptionKey,
                            style: t.caption.copyWith(color: p.textSecondary),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(child: trailing!),
                ] else if (variant == ActionRowVariant.navigation &&
                    onTap != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: Center(
                      child: HybridIcon(
                        HybridIcons.rowChevron,
                        size: 16,
                        color: p.textSecondary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
    if (variant != ActionRowVariant.edit && onEdit == null) return action;
    return Row(
      children: [
        Expanded(child: action),
        IconButton(
          key: editKey,
          tooltip: editTooltip,
          onPressed: onEdit,
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          icon: HybridIcon(HybridIcons.edit, size: 20, color: p.textSecondary),
        ),
      ],
    );
  }
}
