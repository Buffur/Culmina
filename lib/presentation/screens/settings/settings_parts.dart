import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/hybrid_tokens.dart';
import '../../shared/hybrid_icon.dart';

/// The pieces of Hybrid's Settings pages (settings.js, settings.css), so
/// every page uses one geometry for the same role.

/// A Settings page's padding: 12 below the app bar, 20 at the sides.
const settingsPagePadding = EdgeInsets.fromLTRB(
  AppSpacing.gutter,
  AppSpacing.itemGap,
  AppSpacing.gutter,
  AppSpacing.xl,
);

/// A group or section heading (20/600), 4 above its first row; [top] is
/// the gap from what comes before (12 between sections).
class SettingsHeading extends StatelessWidget {
  const SettingsHeading(this.text, {super.key, this.top = AppSpacing.itemGap});

  final String text;
  final double top;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(top: top, bottom: AppSpacing.xs),
    child: Semantics(
      header: true,
      child: Text(
        text,
        style: AppTypography.sectionHeading.copyWith(
          color: AppPalette.of(context).textPrimary,
        ),
      ),
    ),
  );
}

/// Explanatory copy (`.workspace-copy`): 14/22.4 secondary.
class SettingsCopy extends StatelessWidget {
  const SettingsCopy(
    this.text, {
    super.key,
    this.top = 0,
    this.primary = false,
  });

  final String text;
  final double top;

  /// The page's lead line (`.settings-intro`) reads in the primary text.
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Padding(
      padding: EdgeInsets.only(top: top),
      child: Text(
        text,
        style: AppTypography.body.copyWith(
          height: primary ? 1.5 : 1.6,
          color: primary ? p.textPrimary : p.textSecondary,
        ),
      ),
    );
  }
}

/// A hint under a control (`.field-hint`): 13/1.55 secondary.
class SettingsHint extends StatelessWidget {
  const SettingsHint(this.text, {super.key, this.top = 2, this.color});

  final String text;
  final double top;
  final Color? color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(top: top),
    child: Text(
      text,
      style: AppTypography.caption.copyWith(
        height: 1.55,
        color: color ?? AppPalette.of(context).textSecondary,
      ),
    ),
  );
}

/// The legend of a group of choices (`.settings-units > legend`): 15/400.
TextStyle settingsLegendStyle(BuildContext context) => AppTypography.value
    .copyWith(height: 1.5, color: AppPalette.of(context).textPrimary);

/// A row of the Settings root (`.settings-row`): the 24 px icon, 16 before
/// a 16/500 title over a 14 px summary, the chevron; padding 16 0 and a
/// rule below.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.icon,
    required this.title,
    required this.summary,
    required this.onTap,
    this.divider = true,
  });

  final HybridIconData icon;
  final String title;
  final String summary;
  final VoidCallback onTap;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final scale = MediaQuery.textScalerOf(context);
    return MergeSemantics(
      child: Semantics(
        button: true,
        child: InkWell(
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: divider
                  ? Border(bottom: BorderSide(color: p.border))
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Row(
                children: [
                  HybridIcon(
                    icon,
                    size: scale.scale(24),
                    strokeWidth: 1.7,
                    color: p.textPrimary,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: AppSpacing.xs,
                      children: [
                        Text(
                          title,
                          style: AppTypography.rowTitle.copyWith(
                            color: p.textPrimary,
                          ),
                        ),
                        Text(
                          summary,
                          style: AppTypography.body.copyWith(
                            height: 1.6,
                            color: p.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  HybridIcon(
                    HybridIcons.next,
                    size: scale.scale(18),
                    strokeWidth: 1.7,
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

/// A value on a slider (`.settings-field`): the 15 px name with its 15/500
/// value on one line, the hint, the 48 px range, then the range's ends.
class SettingsSlider extends StatelessWidget {
  const SettingsSlider({
    super.key,
    required this.title,
    required this.help,
    required this.value,
    required this.range,
    required this.divisions,
    required this.label,
    required this.format,
    required this.onChanged,
    this.top = AppSpacing.itemGap,
  });

  /// 12 from what comes before; 8 right under a heading (its 4 below and
  /// the field's 12 collapse to 12, as CSS margins do).
  final double top;
  final String title;
  final String help;
  final double value;
  final (double, double) range;
  final int divisions;
  final String label;

  /// Writes the range's ends under the slider, in the value's own form.
  final String Function(double) format;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final ends = AppTypography.caption.copyWith(color: p.textSecondary);
    return Padding(
      padding: EdgeInsets.only(top: top),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              Text(title, style: settingsLegendStyle(context)),
              Text(
                label,
                style: settingsLegendStyle(context).copyWith(
                  fontWeight: FontWeight.w500,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          SettingsHint(help),
          const SizedBox(height: AppSpacing.xs),
          HybridSlider(
            slider: Slider(
              value: value.clamp(range.$1, range.$2),
              min: range.$1,
              max: range.$2,
              divisions: divisions,
              label: label,
              onChanged: onChanged,
            ),
          ),
          const SizedBox(height: AppSpacing.cellY),
          ExcludeSemantics(
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                for (final end in [range.$1, range.$2])
                  Text(format(end), style: ends),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Hybrid's range control (settings.css): the full width of the column, a
/// solid track, no division ticks, 48 px tall to touch. The thumb's radius
/// is the inset, so it stays inside the column's edges.
class HybridSlider extends StatelessWidget {
  const HybridSlider({super.key, required this.slider});

  final Slider slider;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return SizedBox(
      height: HybridTokens.minTarget,
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          trackHeight: 6,
          activeTrackColor: palette.textPrimary,
          inactiveTrackColor: palette.border,
          thumbColor: palette.textPrimary,
          tickMarkShape: SliderTickMarkShape.noTickMark,
          thumbShape: const RoundSliderThumbShape(
            enabledThumbRadius: AppSpacing.sm,
          ),
        ),
        child: slider,
      ),
    );
  }
}

/// One value stepped within the model's [range] (`.settings-stepper`): the
/// 15 px label, then − and + as 48 px outlined squares around the 15/500
/// value.
class SettingsStepper extends StatelessWidget {
  const SettingsStepper({
    super.key,
    required this.label,
    required this.value,
    required this.range,
    required this.step,
    required this.format,
    required this.onChanged,
  });

  final String label;
  final double value;
  final (double, double) range;
  final double step;
  final String Function(double) format;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final shown = format(value);
    Widget button(String sign, String tip, double? next) => SizedBox.square(
      dimension: HybridTokens.minTarget,
      child: Tooltip(
        message: '$label: $tip',
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size.square(HybridTokens.minTarget),
          ),
          onPressed: next == null ? null : () => onChanged(next),
          child: Text(sign),
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label, style: settingsLegendStyle(context)),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              button(
                '−',
                'less',
                value > range.$1
                    ? (value - step).clamp(range.$1, range.$2)
                    : null,
              ),
              Expanded(
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    shown,
                    textAlign: TextAlign.center,
                    style: settingsLegendStyle(context)
                        .copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              button(
                '+',
                'more',
                value < range.$2
                    ? (value + step).clamp(range.$1, range.$2)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A link that opens outside the app (`.settings-link`): 14 px primary,
/// underlined, 48 tall.
class SettingsLink extends StatelessWidget {
  const SettingsLink({super.key, required this.label, required this.url});

  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Semantics(
      link: true,
      child: InkWell(
        onTap: () =>
            launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: HybridTokens.minTarget),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: AppTypography.body.copyWith(
                height: 1.5,
                color: p.textPrimary,
                decoration: TextDecoration.underline,
                decorationColor: p.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// An outlined, full-width action with its icon (`.settings-icon-button`).
class SettingsAction extends StatelessWidget {
  const SettingsAction({
    super.key,
    this.icon,
    required this.label,
    required this.onPressed,
  });

  final HybridIconData? icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.gutter),
    child: OutlinedButton(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(HybridTokens.minTarget),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        spacing: AppSpacing.itemGap,
        children: [
          if (icon case final i?)
            HybridIcon(
              i,
              size: MediaQuery.textScalerOf(context).scale(20),
              strokeWidth: 1.7,
            ),
          Flexible(child: Text(label, textAlign: TextAlign.center)),
        ],
      ),
    ),
  );
}

/// Label and value rows (`.workspace-facts`): the 14 px secondary label at
/// the start, the 14 px value at the end; an optional 13 px note under the
/// value. A narrow column wraps the value under its label.
class FactRows extends StatelessWidget {
  const FactRows(this.rows, {super.key});

  /// (label, value, note).
  final List<(String, String, String?)> rows;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final label = AppTypography.body.copyWith(
      height: 1.55,
      color: p.textSecondary,
    );
    final value = AppTypography.body.copyWith(
      height: 1.5,
      color: p.textPrimary,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (l, v, note) in rows)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: MergeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    // The label at the start, the value at the end; each
                    // wraps within its share when long.
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(child: Text(l, style: label)),
                      const SizedBox(width: AppSpacing.itemGap),
                      Flexible(
                        child: Text(v, textAlign: TextAlign.end, style: value),
                      ),
                    ],
                  ),
                  if (note != null && note.isNotEmpty)
                    Text(
                      note,
                      textAlign: TextAlign.end,
                      style: AppTypography.caption.copyWith(
                        height: 1.5,
                        color: p.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
