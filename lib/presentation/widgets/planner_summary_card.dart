import '../../core/theme/app_text_theme.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_palette.dart';
import '../../core/theme/hybrid_tokens.dart';
import '../shared/info_row.dart';
import '../viewmodels/disclosure_viewmodel.dart';

/// Compact identity row with a separate, remembered reference disclosure.
class PlannerSummaryCard extends StatelessWidget {
  const PlannerSummaryCard({
    super.key,
    required this.title,
    required this.data,
    this.onTap,
    this.below,
    this.label,
    this.caption,
  });

  final String title;
  final Map<String, String> data;
  final VoidCallback? onTap;
  final Widget? below;
  final String? label;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = AppPalette.of(context);
    final key = label == null
        ? null
        : 'planner.${label!.toLowerCase()}.reference';
    final disclosure = key == null
        ? null
        : context.watch<DisclosureViewModel>();
    final open = key == null || disclosure!.isOpen(key);
    bool warning(String name) =>
        const {'NPF (untracked)', 'Max sub (guide)'}.contains(name) ||
        (label == 'Target' && name == 'Note');
    Widget value(MapEntry<String, String> entry) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InfoRow(label: entry.key, value: entry.value),
    );
    return Material(
      color: HybridTokens.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (label != null)
                          Text(
                            label!,
                            style: text.bodySmall?.copyWith(
                              color: palette.textSecondary,
                            ),
                          ),
                        Text(
                          title,
                          style: AppTextTheme.of(context)
                              .resolve(
                                text.bodyLarge,
                                AppTextGeometry.summaryTitle,
                              )
                              .copyWith(fontWeight: FontWeight.w400),
                        ),
                        if (caption != null)
                          Text(
                            caption!,
                            style: text.bodySmall?.copyWith(
                              color: palette.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (key != null)
                    Semantics(
                      key: Key('section.$key'),
                      expanded: open,
                      child: IconButton(
                        tooltip: '$label details',
                        onPressed: () => disclosure!.setOpen(key, !open),
                        icon: Icon(
                          open ? Icons.expand_less : Icons.info_outline,
                          color: palette.textSecondary,
                        ),
                      ),
                    ),
                  if (onTap != null)
                    Icon(Icons.chevron_right, color: palette.textSecondary),
                ],
              ),
            ),
          ),
          // Safety guidance remains visible; measurements and provenance are
          // reachable without adding another full-height header to the plan.
          for (final entry in data.entries.where((e) => warning(e.key)))
            value(entry),
          if (open) ...[
            for (final entry in data.entries.where((e) => !warning(e.key)))
              value(entry),
            ?below,
          ],
        ],
      ),
    );
  }
}
