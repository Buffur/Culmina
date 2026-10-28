import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
import '../../core/theme/app_text_theme.dart';
import '../../core/theme/hybrid_tokens.dart';
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
        style: AppTextTheme.of(context).sectionHeading
            .copyWith(color: p.textPrimary),
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
            style: AppTextTheme.of(context).caption
                .copyWith(color: p.textSecondary),
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
              style: AppTextTheme.of(context).caption.copyWith(
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
              style: AppTextTheme.of(context).caption.copyWith(
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
      style: AppTextTheme.of(context)
          .resolve(AppTextTheme.of(context).caption, AppTextGeometry.emptyState)
          .copyWith(color: tertiary ? p.textTertiary : p.textSecondary),
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
      enabled: true,
      onTap: onTap,
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
                      style: AppTextTheme.of(context)
                          .resolve(
                            AppTextTheme.of(context).itemTitle,
                            AppTextGeometry.supporting,
                          )
                          .copyWith(color: p.textPrimary),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      value,
                      style: AppTextTheme.of(context)
                          .resolve(
                            AppTextTheme.of(context).value,
                            AppTextGeometry.standard,
                          )
                          .copyWith(color: p.textPrimary),
                    ),
                    if (caption != null) ...[
                      const SizedBox(height: 1),
                      Text(
                        caption!,
                        style: AppTextTheme.of(context)
                            .resolve(
                              AppTextTheme.of(context).caption,
                              AppTextGeometry.supporting,
                            )
                            .copyWith(color: p.textTertiary),
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
      enabled: true,
      onTap: onTap,
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
                                style: AppTextTheme.of(context)
                                    .resolve(
                                      AppTextTheme.of(context).itemTitle,
                                      AppTextGeometry.standard,
                                    )
                                    .copyWith(color: p.textPrimary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          value,
                          style: AppTextTheme.of(context)
                              .resolve(
                                AppTextTheme.of(context).value,
                                AppTextGeometry.reading,
                              )
                              .copyWith(
                                color: p.textPrimary,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                        ),
                        if (extra != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            extra!,
                            style: AppTextTheme.of(context).caption
                                .copyWith(color: p.textTertiary),
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
    this.noteKey,
  });

  final String label;
  final VoidCallback? onPressed;
  final String? note;
  final Key? buttonKey;
  final Key? noteKey;

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
                  key: noteKey,
                  style: AppTextTheme.of(context)
                      .resolve(
                        AppTextTheme.of(context).caption,
                        AppTextGeometry.supporting,
                      )
                      .copyWith(color: p.textSecondary),
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
                  textStyle: AppTextTheme.of(context).resolve(
                    AppTextTheme.of(context).itemTitle,
                    AppTextGeometry.standard,
                  ),
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
  const HybridRadio({super.key, required this.checked, this.size = 18});

  final bool checked;

  /// 18 in the plan's forms (plan.css); 24 in Settings (settings.css).
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return SizedBox.square(
      dimension: size,
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
    // Drawn for 18 px and scaled, as the browser scales its radio.
    final k = size.shortestSide / 18;
    if (!checked) {
      canvas.drawCircle(
        c,
        8.5 * k,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = k
          ..color = off,
      );
      return;
    }
    canvas.drawCircle(c, 9 * k, Paint()..color = on);
    canvas.drawCircle(c, 7 * k, Paint()..color = surface);
    canvas.drawCircle(c, 4.5 * k, Paint()..color = on);
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
/// subtle rule below; at least 56 tall (`.choice-list .choice`).
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
      enabled: true,
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: p.border)),
        ),
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
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
                          style: AppTextTheme.of(context)
                              .resolve(
                                AppTextTheme.of(context).body,
                                AppTextGeometry.standard,
                              )
                              .copyWith(
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: p.textPrimary,
                              ),
                        ),
                        if (caption != null)
                          Text(
                            caption!,
                            style: AppTextTheme.of(context).caption
                                .copyWith(color: p.textSecondary),
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
      style: AppTextTheme.of(context).caption
          .copyWith(color: AppPalette.of(context).textSecondary),
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

/// A select's closed-state arrow (the browser `select` chevron the web
/// reference shows, about 8 × 5 with a 2 px stroke): a small down chevron in
/// the primary text colour.
Widget hybridSelectIcon(BuildContext context) => Center(
  // The dropdown sizes its icon slot to 24: centre the arrow in it.
  widthFactor: 1,
  heightFactor: 1,
  child: RotatedBox(
    quarterTurns: 1,
    child: HybridIcon(
      HybridIcons.chevron,
      size: MediaQuery.textScalerOf(context).scale(14),
      strokeWidth: 3.2,
      color: AppPalette.of(context).textPrimary,
    ),
  ),
);

/// A select's padding: Chromium's `select` with 12 padding and a 1 px
/// border is 49 tall at 16 px (an input is 50).
const hybridSelectPadding = EdgeInsets.fromLTRB(13, 12.5, 13, 12.5);

/// Plan pages' fields (plan.css `.planner-page input::placeholder`): the
/// hint in italic secondary text.
class HybridPlanInputs extends StatelessWidget {
  const HybridPlanInputs({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        inputDecorationTheme: theme.inputDecorationTheme.copyWith(
          hintStyle: theme.inputDecorationTheme.hintStyle?.copyWith(
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
      child: child,
    );
  }
}

/// Hybrid's switch (settings.css `input[role=switch]`): a 52 × 32 pill with
/// a 2 px border and a 20 px knob 4 from the edge; off on the subtle
/// surface with the control border and a secondary knob, on in the action
/// colour with the on-action knob. Touch target 48.
class HybridSwitch extends StatelessWidget {
  const HybridSwitch({super.key, required this.value, this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final h = Theme.of(context).extension<HybridTokens>() ?? HybridTokens.light;
    final enabled = onChanged != null;
    final track = Container(
      width: 52,
      height: 32,
      decoration: BoxDecoration(
        color: value ? h.action : h.surfaceSubtle,
        border: Border.all(width: 2, color: value ? h.action : p.controlBorder),
        borderRadius: BorderRadius.circular(999),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 120),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: value ? h.onAction : p.textSecondary,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
    return Semantics(
      toggled: value,
      enabled: enabled,
      onTap: enabled ? () => onChanged!(!value) : null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? () => onChanged!(!value) : null,
        child: SizedBox(
          height: HybridTokens.minTarget,
          child: Center(
            child: Opacity(opacity: enabled ? 1 : 0.5, child: track),
          ),
        ),
      ),
    );
  }
}

/// A switch row (settings.css `.settings-switch`): a 15 px title and a
/// 13 px secondary description beside the switch, 16 apart; padding 10 0
/// and a subtle rule below. The whole row toggles.
class HybridSwitchRow extends StatelessWidget {
  const HybridSwitchRow({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.description,
    this.divider = true,
  });

  final String title;
  final String? description;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return MergeSemantics(
      child: InkWell(
        onTap: onChanged == null ? null : () => onChanged!(!value),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: divider
                ? Border(bottom: BorderSide(color: p.border))
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Text(
                        title,
                        style: AppTextTheme.of(context)
                            .resolve(
                              AppTextTheme.of(context).value,
                              AppTextGeometry.standard,
                            )
                            .copyWith(color: p.textPrimary),
                      ),
                      if (description case final d?)
                        Text(
                          d,
                          style: AppTextTheme.of(context)
                              .resolve(
                                AppTextTheme.of(context).caption,
                                AppTextGeometry.supporting,
                              )
                              .copyWith(color: p.textSecondary),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                HybridSwitch(value: value, onChanged: onChanged),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The browser checkbox the reference shows (logbook.css `.logbook-check`):
/// a 24 px square with a 1 px control border, radius 3; checked, filled in
/// the primary text with a check in the surface colour.
class HybridCheckbox extends StatelessWidget {
  const HybridCheckbox({super.key, required this.checked, this.size = 24});

  final bool checked;

  /// The square's side: 24, or 18 in a plan form's `.check-row`.
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final surface = Theme.of(context).scaffoldBackgroundColor;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: checked ? p.textPrimary : null,
        border: Border.all(color: checked ? p.textPrimary : p.controlBorder),
        borderRadius: BorderRadius.circular(3),
      ),
      child: checked
          ? HybridIcon(
              HybridIcons.check,
              size: size * 0.75,
              strokeWidth: 2.4,
              color: surface,
            )
          : null,
    );
  }
}

/// A checkbox row (`.logbook-check`): the box 4 in, its 14 px label 15
/// after; 48 tall; the whole row toggles.
class HybridCheckRow extends StatelessWidget {
  const HybridCheckRow({
    super.key,
    required this.label,
    required this.checked,
    required this.onChanged,
  }) : _box = 24,
       _inset = 4,
       _gap = 15;

  /// A plan form's check row (plan.css `.check-row`): an 18 px box at the
  /// edge, its label 12 after.
  const HybridCheckRow.plan({
    super.key,
    required this.label,
    required this.checked,
    required this.onChanged,
  }) : _box = 18,
       _inset = 0,
       _gap = 12;

  final String label;
  final bool checked;
  final ValueChanged<bool> onChanged;
  final double _box;
  final double _inset;
  final double _gap;

  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: Semantics(
      checked: checked,
      child: InkWell(
        onTap: () => onChanged(!checked),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: HybridTokens.minTarget),
          child: Row(
            children: [
              SizedBox(width: _inset),
              HybridCheckbox(checked: checked, size: _box),
              SizedBox(width: _gap),
              Expanded(
                child: Text(
                  label,
                  style: AppTextTheme.of(context)
                      .resolve(
                        AppTextTheme.of(context).body,
                        AppTextGeometry.standard,
                      )
                      .copyWith(color: AppPalette.of(context).textPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
