import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_theme.dart';

/// Short facts align at the trailing edge; long facts retain their full text.
class FactRow extends StatelessWidget {
  const FactRow({
    super.key,
    required this.label,
    required this.value,
    this.emphasis = false,
    this.caption,
    this.provenance,
    this.stacked = false,
    this.leading,
    this.valueKey,
  });

  final String label;
  final String value;
  final bool emphasis;
  final String? caption;
  final String? provenance;
  final bool stacked;
  final Widget? leading;
  final Key? valueKey;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final t = AppTextTheme.of(context);
    final labelStyle = t.body.copyWith(
      color: emphasis ? p.textPrimary : p.textSecondary,
    );
    final valueStyle = (emphasis ? t.value : t.rowTitle).copyWith(
      color: p.textPrimary,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final name = leading == null
        ? Text(label, style: labelStyle)
        : Row(
            children: [
              SizedBox.square(dimension: 20, child: leading!),
              const SizedBox(width: AppSpacing.sm),
              Flexible(child: Text(label, style: labelStyle)),
            ],
          );
    return MergeSemantics(
      child: LayoutBuilder(
        builder: (context, constraints) {
          double width(String text, TextStyle style) {
            final painter = TextPainter(
              text: TextSpan(text: text, style: style),
              textDirection: Directionality.of(context),
              textScaler: MediaQuery.textScalerOf(context),
            )..layout();
            final result = painter.width;
            painter.dispose();
            return result;
          }

          final inline =
              !stacked &&
              !value.contains('\n') &&
              width(label, labelStyle) +
                      (leading == null ? 0 : 20 + AppSpacing.sm) +
                      width(value, valueStyle) +
                      AppSpacing.md <=
                  constraints.maxWidth;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (inline)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: name),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      value,
                      key: valueKey,
                      style: valueStyle,
                      textAlign: TextAlign.end,
                    ),
                  ],
                )
              else ...[
                name,
                const SizedBox(height: AppSpacing.xs),
                Text(value, key: valueKey, style: valueStyle),
              ],
              if (caption != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  caption!,
                  style: t.caption.copyWith(color: p.textSecondary),
                ),
              ],
              if (provenance != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  provenance!,
                  style: t.caption.copyWith(color: p.textTertiary),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
