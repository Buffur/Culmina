import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
import '../../core/theme/app_typography.dart';
import 'hybrid_icon.dart';

/// Shared pieces of the accepted Hybrid reference (design/home-lab 86873ce;
/// plan.css, hybrid-refinement.css, hybrid-data-tokens.css), so the screens
/// use one geometry for the same role.

/// A section heading (20/600, -0.3 tracking) with an optional trailing
/// caption on its baseline ("1 block · 120 frames").
class HybridSectionTitle extends StatelessWidget {
  const HybridSectionTitle(this.text, {super.key, this.trailing});

  final String text;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final title = Semantics(
      header: true,
      child: Text(
        text,
        style: AppTypography.sectionHeading.copyWith(color: p.textPrimary),
      ),
    );
    if (trailing == null) return title;
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 12,
      runSpacing: 4,
      children: [
        title,
        Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Text(
            trailing!,
            style: AppTypography.caption.copyWith(color: p.textSecondary),
          ),
        ),
      ],
    );
  }
}

/// One label/value pair (`dl` in a disclosure): a 13/400 secondary label
/// at the start and the 13/500 primary value at the end; a long value
/// wraps beside its label.
class HybridFact extends StatelessWidget {
  const HybridFact(this.label, this.value, {super.key, this.emphasis = false});

  final String label;
  final String value;

  /// The budget's answer lines read in the primary text at 600.
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return MergeSemantics(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Text(
              label,
              style: AppTypography.caption.copyWith(
                color: emphasis ? p.textPrimary : p.textSecondary,
                fontWeight: emphasis ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTypography.caption.copyWith(
                color: p.textPrimary,
                fontWeight: emphasis ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Label/value pairs, 16 apart (see [HybridFact]).
class HybridFacts extends StatelessWidget {
  const HybridFacts(this.rows, {super.key});

  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) =>
      HybridFactList([for (final (l, v) in rows) HybridFact(l, v)]);
}

/// Facts already built (with their keys), 16 apart.
class HybridFactList extends StatelessWidget {
  const HybridFactList(this.facts, {super.key});

  final List<Widget> facts;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final (i, f) in facts.indexed)
        Padding(
          padding: EdgeInsets.only(top: i == 0 ? 0 : 16),
          child: f,
        ),
    ],
  );
}

/// An explanatory note in a disclosure: 13/400 secondary at 1.7.
class HybridNote extends StatelessWidget {
  const HybridNote(this.text, {super.key, this.tertiary = false});

  final String text;
  final bool tertiary;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Text(
      text,
      style: AppTypography.caption.copyWith(
        height: 22.1 / 13,
        color: tertiary ? p.textTertiary : p.textSecondary,
      ),
    );
  }
}

/// A plan row (plan.js `rowButton`; hybrid-refinement.css `.plan-row`): the
/// 16/600 label over the 15/400 value and a 13 px tertiary caption, 1 apart,
/// a 16 px chevron centred; 12 above and below, no rule.
class HybridPlanRow extends StatelessWidget {
  const HybridPlanRow({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.caption,
    this.semanticsHint,
  });

  final String label;
  final String value;
  final String? caption;
  final VoidCallback onTap;
  final String? semanticsHint;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Semantics(
      button: true,
      label: [label, value, ?caption].join(', '),
      hint: semanticsHint,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTypography.itemTitle.copyWith(
                        height: 1.55,
                        color: p.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      value,
                      style: AppTypography.value.copyWith(
                        height: 1.5,
                        color: p.textPrimary,
                      ),
                    ),
                    if (caption != null) ...[
                      const SizedBox(height: 1),
                      Text(
                        caption!,
                        style: AppTypography.caption.copyWith(
                          height: 1.55,
                          color: p.textTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              HybridIcon(
                HybridIcons.rowChevron,
                size: 16,
                strokeWidth: 1.6,
                color: p.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A conditions row on Plan (plan.css `.night-row`, hybrid-data-tokens.css):
/// the 20 px data icon 10 before the 16/600 label, the 15/400 value and a
/// 13 px tertiary extra, 2 apart; a 16 px chevron; 12 above and below and a
/// subtle rule below.
class HybridNightRow extends StatelessWidget {
  const HybridNightRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.extra,
    this.iconColor,
  });

  final HybridIconData icon;
  final String label;
  final String value;
  final String? extra;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Semantics(
      button: true,
      label: [label, value, ?extra].join(', '),
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: p.border)),
        ),
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 64),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            HybridIcon(
                              icon,
                              size: 20,
                              color: iconColor ?? p.textPrimary,
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                label,
                                style: AppTypography.itemTitle.copyWith(
                                  height: 1.5,
                                  color: p.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          value,
                          style: AppTypography.value.copyWith(
                            height: 1.6,
                            color: p.textPrimary,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        if (extra != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            extra!,
                            style: AppTypography.caption.copyWith(
                              color: p.textTertiary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  HybridIcon(
                    HybridIcons.rowChevron,
                    size: 16,
                    strokeWidth: 1.6,
                    color: p.textSecondary,
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

/// The scoped screens' bottom bar (plan.css `.plan-savebar` on Site and
/// night, Target, Rig): a subtle rule, padding 12 20 8, the note in 13 px
/// secondary and the 48 px primary action (16/600).
class HybridApplyBar extends StatelessWidget {
  const HybridApplyBar({
    super.key,
    required this.label,
    required this.onPressed,
    this.note = 'Apply updates the draft. Save plan records it.',
    this.buttonKey,
  });

  final String label;
  final VoidCallback? onPressed;
  final String? note;
  final Key? buttonKey;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      shape: Border(top: BorderSide(color: p.border)),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (note != null) ...[
                Text(
                  note!,
                  style: AppTypography.caption.copyWith(
                    height: 1.55,
                    color: p.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              FilledButton(
                key: buttonKey,
                onPressed: onPressed,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  textStyle: AppTypography.itemTitle.copyWith(height: 1.5),
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The browser radio of the reference (accent = primary text): an 18 px
/// ring; checked, a 2 px ring, a surface gap and a dot. Field mode draws a
/// 2 px red ring and dot (hybrid-refinement.css). Decorative: the row
/// carries the semantics.
class HybridRadio extends StatelessWidget {
  const HybridRadio({super.key, required this.checked});

  final bool checked;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return SizedBox.square(
      dimension: 18,
      child: CustomPaint(
        painter: _RadioPainter(
          checked: checked,
          on: p.textPrimary,
          off: p.controlBorder,
          surface: Theme.of(context).scaffoldBackgroundColor,
        ),
      ),
    );
  }
}

class _RadioPainter extends CustomPainter {
  const _RadioPainter({
    required this.checked,
    required this.on,
    required this.off,
    required this.surface,
  });

  final bool checked;
  final Color on;
  final Color off;
  final Color surface;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    if (!checked) {
      canvas.drawCircle(
        c,
        8.5,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = off,
      );
      return;
    }
    canvas.drawCircle(c, 9, Paint()..color = on);
    canvas.drawCircle(c, 7, Paint()..color = surface);
    canvas.drawCircle(c, 4.5, Paint()..color = on);
  }

  @override
  bool shouldRepaint(_RadioPainter old) =>
      old.checked != checked ||
      old.on != on ||
      old.off != off ||
      old.surface != surface;
}

/// A choice row (plan.css `.choice`): the radio, 10 before a 14 px title
/// (600 when chosen) and a 13 px secondary caption; padding 10 0 and a
/// subtle rule below.
class HybridChoiceRow extends StatelessWidget {
  const HybridChoiceRow({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
    this.caption,
  });

  final String title;
  final String? caption;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      label: [title, ?caption].join(', '),
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: p.border)),
        ),
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  HybridRadio(checked: selected),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTypography.body.copyWith(
                            height: 1.5,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: p.textPrimary,
                          ),
                        ),
                        if (caption != null)
                          Text(
                            caption!,
                            style: AppTypography.caption.copyWith(
                              color: p.textSecondary,
                            ),
                          ),
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

/// A 13 px secondary field label (`legend`, `label`).
class HybridFieldLabel extends StatelessWidget {
  const HybridFieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Text(
      text,
      style: AppTypography.caption.copyWith(
        color: AppPalette.of(context).textSecondary,
      ),
    ),
  );
}

/// An app bar close (×) button (night-ui.js `close`, 24 px, stroke 1.8).
class HybridCloseButton extends StatelessWidget {
  const HybridCloseButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    key: const Key('scoped.close'),
    tooltip: 'Close',
    onPressed: onPressed,
    icon: HybridIcon(
      HybridIcons.close,
      size: MediaQuery.textScalerOf(context).scale(24),
      strokeWidth: 1.8,
    ),
  );
}
