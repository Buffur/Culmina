import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/hybrid_tokens.dart';

/// Hybrid's form field (plan.css `.block-input`): a 13 px label above the
/// control, which keeps the label as its accessible name.
class BlockField extends StatelessWidget {
  const BlockField({
    super.key,
    required this.label,
    required this.child,
    this.hint,
    this.note,
    this.noteKey,
  });

  final String label;
  final Widget child;

  /// How to fill the field (`.field-hint`), under it at its left edge.
  final String? hint;

  /// Where the value came from (`.field-source`), under the field.
  final String? note;
  final Key? noteKey;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      ExcludeSemantics(
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 13,
            color: AppPalette.of(context).textSecondary,
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.xs),
      Semantics(label: label, hint: hint, child: child),
      if (hint != null)
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: ExcludeSemantics(
            child: Text(
              hint!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: AppPalette.of(context).textSecondary,
              ),
            ),
          ),
        ),
      if (note != null)
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: Text(
            note!,
            key: noteKey,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: AppPalette.of(context).textSecondary),
          ),
        ),
    ],
  );
}

/// Hybrid's segmented radio group (plan.js `radioGroup`, plan.css
/// `.segmented`): a legend, then bordered 48 px choices that share each row
/// and wrap to fewer per row as text grows. One option is always selected.
class HybridSegmented<T> extends StatelessWidget {
  const HybridSegmented({
    super.key,
    required this.legend,
    required this.options,
    required this.value,
    required this.onChanged,
    required this.keyPrefix,
  });

  final String legend;

  /// Each option: its value, its label, and the suffix of its key
  /// (`'$keyPrefix.$suffix'`).
  final List<(T, String, String)> options;
  final T value;
  final ValueChanged<T> onChanged;
  final String keyPrefix;

  static const _gap = 6.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = AppPalette.of(context);
    final selection =
        theme.extension<HybridTokens>()?.selection ??
        theme.colorScheme.surfaceContainerHighest;
    final labelStyle = theme.textTheme.bodyMedium?.copyWith(fontSize: 14);
    final scaler = MediaQuery.textScalerOf(context);
    return Semantics(
      container: true,
      label: legend,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          ExcludeSemantics(
            child: Text(
              legend,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 13,
                color: palette.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: _gap),
          LayoutBuilder(
            builder: (context, constraints) {
              // The widest choice decides how many share a row (CSS
              // `flex: 1 1 auto; min-width: 72px`).
              var widest = 72.0;
              for (final (_, label, _) in options) {
                final painter = TextPainter(
                  text: TextSpan(text: label, style: labelStyle),
                  textDirection: Directionality.of(context),
                  textScaler: scaler,
                  maxLines: 1,
                )..layout();
                // Radio 18, gap 10, padding 2 × 12, border 2.
                final w = painter.width + 18 + 10 + 24 + 2;
                painter.dispose();
                if (w > widest) widest = w;
              }
              final perRow = ((constraints.maxWidth + _gap) / (widest + _gap))
                  .floor()
                  .clamp(1, options.length);
              final rows = <List<(T, String, String)>>[
                for (var i = 0; i < options.length; i += perRow)
                  options.sublist(i, (i + perRow).clamp(0, options.length)),
              ];
              return Column(
                mainAxisSize: MainAxisSize.min,
                spacing: _gap,
                children: [
                  for (final row in rows)
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: _gap,
                        children: [
                          for (final (option, label, suffix) in row)
                            Expanded(
                              child: _Choice(
                                key: Key('$keyPrefix.$suffix'),
                                label: label,
                                selected: option == value,
                                selection: selection,
                                border: palette.controlBorder,
                                style: labelStyle,
                                onTap: () => onChanged(option),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    super.key,
    required this.label,
    required this.selected,
    required this.selection,
    required this.border,
    required this.style,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color selection;
  final Color border;
  final TextStyle? style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      child: Material(
        color: selected ? selection : HybridTokens.transparent,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: border),
          borderRadius: BorderRadius.circular(6),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: HybridTokens.minTarget,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      label,
                      style: style?.copyWith(
                        fontWeight: selected ? FontWeight.w600 : null,
                      ),
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

/// Hybrid's disclosure (`.plan-disclosure` / `.photo-metadata` summary): a
/// top rule, a 56 px row with the title and an optional fact, and its
/// content below while open. Nothing in it is erased while closed.
class BlockDisclosure extends StatelessWidget {
  const BlockDisclosure({
    super.key,
    required this.title,
    this.summary,
    required this.open,
    required this.onToggle,
    required this.children,
  });

  final String title;
  final String? summary;
  final bool open;
  final VoidCallback onToggle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = AppPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(height: 1, color: palette.border),
        Semantics(
          expanded: open,
          button: true,
          child: InkWell(
            onTap: onToggle,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 56),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (summary != null)
                            Text(
                              summary!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: palette.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Icon(
                      open ? Icons.expand_less : Icons.expand_more,
                      color: palette.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (open)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              spacing: 20,
              children: children,
            ),
          ),
      ],
    );
  }
}
