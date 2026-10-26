import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/hybrid_tokens.dart';
import '../../shared/collapsible_section.dart';
import '../../shared/hybrid_parts.dart';

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

  // plan.css `.block-input` gap 4; the label 13/1.5, the hint and the
  // source 13 (hybrid-refinement.css) at 1.55 and 1.5, all secondary.
  @override
  Widget build(BuildContext context) {
    final secondary = AppPalette.of(context).textSecondary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(
          child: Text(
            label,
            style: AppTypography.caption.copyWith(color: secondary),
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
                style: AppTypography.caption.copyWith(
                  height: 1.55,
                  color: secondary,
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
              style: AppTypography.caption.copyWith(color: secondary),
            ),
          ),
      ],
    );
  }
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
    this.legendStyle,
    this.showLegend = true,
    this.gap = _gap,
    this.runGap = _gap,
    this.radioSize = 18,
    this.radioGap = 10,
    this.stackLargeText = false,
  });

  /// Settings' choices (settings.css `.settings-view .segmented`): 16 apart
  /// in a line and 4 between lines, a 24 px radio 12 before its label, one
  /// choice per line at large text.
  const HybridSegmented.settings({
    super.key,
    required this.legend,
    required this.options,
    required this.value,
    required this.onChanged,
    required this.keyPrefix,
    this.legendStyle,
    this.showLegend = true,
  }) : gap = 16,
       runGap = 4,
       radioSize = 24,
       radioGap = 12,
       stackLargeText = true;

  final String legend;

  /// The legend's style; the plan's 13 px secondary label when null.
  final TextStyle? legendStyle;

  /// False when a heading above already names the choice (the legend is
  /// then only spoken).
  final bool showLegend;
  final double gap;
  final double runGap;
  final double radioSize;
  final double radioGap;
  final bool stackLargeText;

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
          if (showLegend) ...[
            ExcludeSemantics(
              child: Text(
                legend,
                style:
                    legendStyle ??
                    theme.textTheme.bodySmall?.copyWith(
                      fontSize: 13,
                      color: palette.textSecondary,
                    ),
              ),
            ),
            SizedBox(height: legendStyle == null ? _gap : 4),
          ],
          LayoutBuilder(
            builder: (context, constraints) {
              // CSS `flex: 1 1 auto; min-width: 72px` in a wrapping row:
              // each choice's base is its content (the selected one's
              // label at 600); a line takes choices while they fit, and its
              // free space is shared equally.
              final max = constraints.maxWidth;
              final bases = [
                for (final (option, label, _) in options)
                  () {
                    final painter = TextPainter(
                      text: TextSpan(
                        text: label,
                        style: labelStyle?.copyWith(
                          fontWeight: option == value ? FontWeight.w600 : null,
                        ),
                      ),
                      textDirection: Directionality.of(context),
                      textScaler: scaler,
                      maxLines: 1,
                    )..layout();
                    // Radio, its gap, padding 2 × 12, border 2.
                    final w = painter.width + radioSize + radioGap + 24 + 2;
                    painter.dispose();
                    return w < 72.0 ? 72.0 : (w > max ? max : w);
                  }(),
              ];
              final rows = <List<int>>[];
              var used = 0.0;
              final stack = stackLargeText && scaler.scale(1) >= 1.5;
              for (var i = 0; i < options.length; i++) {
                final extra = (rows.isEmpty || rows.last.isEmpty ? 0 : gap);
                if (rows.isEmpty ||
                    stack ||
                    used + extra + bases[i] > max + 0.01) {
                  rows.add([i]);
                  used = bases[i];
                } else {
                  rows.last.add(i);
                  used += extra + bases[i];
                }
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                spacing: runGap,
                children: [
                  for (final row in rows)
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: gap,
                        children: [
                          for (final i in row)
                            SizedBox(
                              width:
                                  bases[i] +
                                  (max -
                                          gap * (row.length - 1) -
                                          row.fold(
                                            0.0,
                                            (s, j) => s + bases[j],
                                          )) /
                                      row.length,
                              child: _Choice(
                                key: Key('$keyPrefix.${options[i].$3}'),
                                label: options[i].$2,
                                selected: options[i].$1 == value,
                                selection: selection,
                                border: palette.controlBorder,
                                style: labelStyle,
                                radioSize: radioSize,
                                radioGap: radioGap,
                                onTap: () => onChanged(options[i].$1),
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
    required this.radioSize,
    required this.radioGap,
  });

  final double radioSize;
  final double radioGap;
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
                  HybridRadio(checked: selected, size: radioSize),
                  SizedBox(width: radioGap),
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

/// Hybrid's disclosures in a scoped form: `.plan-disclosure` (Details:
/// the 20/600 section title, a 13 px caption) and `.photo-metadata` (From
/// a photo: 18/600, no caption), each with a top rule, the end chevron and
/// 8 px more space above (hybrid-refinement.css); From a photo also 8
/// below. Open, the content sits 20 apart with 16 below. Nothing in it is
/// erased while closed.
class BlockDisclosure extends StatelessWidget {
  const BlockDisclosure({
    super.key,
    required this.title,
    this.summary,
    required this.open,
    required this.onToggle,
    required this.children,
    this.small = false,
    this.topRule = true,
    this.readableFeedback = false,
  });

  final String title;
  final String? summary;
  final bool open;
  final VoidCallback onToggle;
  final List<Widget> children;

  /// The From a photo summary (18/600) instead of the section title.
  final bool small;
  final bool topRule;
  final bool readableFeedback;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(top: 8, bottom: small ? 8 : 0),
    child: CollapsibleSection(
      readableFeedback: readableFeedback,
      sectionKey: 'blockEditor.$title',
      topRule: topRule,
      title: title,
      summary: summary,
      open: open,
      onToggle: onToggle,
      titleStyle: small
          ? AppTypography.sectionSubject.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.4,
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          spacing: 20,
          children: children,
        ),
      ),
    ),
  );
}
