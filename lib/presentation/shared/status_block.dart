import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/quantity_text.dart';
import '../../domain/services/fit_analyzer.dart';
import 'app_words.dart';
import 'night_text.dart';

/// The answer first (S5.4; ADR-019 §6, addendum §3.1–§3.2): the verdict
/// headline in its status colour ("Fits: 2 h 5 min needed of 4 h 20 min
/// usable"), its reason, optional key numbers and an optional action (fill
/// or trim). It calculates nothing: the state, the durations, the reason
/// and the key numbers come from the ViewModel (the fit analysis); values
/// are formatted with `QuantityText`.
class StatusBlock extends StatelessWidget {
  const StatusBlock({
    super.key,
    required this.state,
    this.needed,
    this.usable,
    this.reason,
    this.missing,
    this.keyNumbers = const [],
    this.action,
    this.separateFigures = false,
    this.headingStyle,
    this.figuresBeforeReason,
    this.fitLine = false,
  });

  /// Tonight's Hybrid fit line (app.js `.fit-line`, `.plan-reason`): a
  /// check (or an info mark for a missing input) beside a 13 px verdict, the
  /// reason in 14 px secondary below it.
  final bool fitLine;

  final FitState state;

  /// Time needed and usable time; the headline names them only when both
  /// are known (unknown stays unknown).
  final Duration? needed;
  final Duration? usable;

  final String? reason;

  /// For a missing input: [AppWords.needsTarget] (the default) or another
  /// glossary word the adopting screen chooses.
  final String? missing;

  /// Label and already formatted value pairs, e.g. ("Capture ends",
  /// "01:40").
  final List<(String, String)> keyNumbers;

  final Widget? action;

  /// Hybrid shows the verdict, then labelled measurements rather than a
  /// sentence that repeats both values in the heading.
  final bool separateFigures;
  final TextStyle? headingStyle;

  /// Plan shows figures before its explanation; Tonight retains its summary
  /// reason above them. Existing sentence-headline adopters keep their order.
  final bool? figuresBeforeReason;

  /// The headline in the glossary's words (RD-14). Pure.
  static String headline(
    FitState state, {
    Duration? needed,
    Duration? usable,
    String? missing,
  }) {
    String measured(String word) => needed == null || usable == null
        ? word
        : AppWords.headline(
            word,
            QuantityText.budgetDuration(needed),
            QuantityText.budgetDuration(usable),
          );
    return switch (state) {
      FitState.fits => measured(AppWords.fits),
      FitState.tight => measured(AppWords.tight),
      FitState.doesNotFit => measured(AppWords.doesNotFit),
      FitState.noWindow => AppWords.noWindow,
      FitState.needsInput => missing ?? AppWords.needsTarget,
      FitState.nothingToFit => AppWords.needsBlock,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = AppPalette.of(context);
    final text = theme.textTheme;
    final figures = [
      if (separateFigures && needed != null)
        ('Needed in imaging window', QuantityText.budgetDuration(needed!)),
      if (separateFigures && usable != null)
        ('Usable', QuantityText.budgetDuration(usable!)),
      ...keyNumbers,
    ];
    final figuresFirst = figuresBeforeReason ?? separateFigures;
    final explanation = Text(
      reason ?? '',
      style: fitLine
          ? text.bodySmall?.copyWith(
              fontSize: 14,
              height: 1.55,
              color: p.textSecondary,
            )
          : text.bodyMedium?.copyWith(color: p.textSecondary),
    );
    final verdictStyle =
        (fitLine
                ? text.bodySmall?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  )
                : (headingStyle ?? text.titleMedium))
            ?.copyWith(color: FitText.color(state, theme.colorScheme, p));
    final verdict = Text(
      headline(
        state,
        needed: separateFigures ? null : needed,
        usable: separateFigures ? null : usable,
        missing: missing,
      ),
      key: const Key('status.headline'),
      style: verdictStyle,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: fitLine
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 1, right: 7),
                      child: Icon(
                        state == FitState.needsInput ||
                                state == FitState.nothingToFit
                            ? Icons.info_outline
                            : state == FitState.fits || state == FitState.tight
                            ? Icons.check
                            : Icons.close,
                        // 17 px at 100 %, growing with the text it marks.
                        size: MediaQuery.textScalerOf(context).scale(17),
                        color: verdictStyle?.color,
                      ),
                    ),
                    Expanded(child: verdict),
                  ],
                )
              : verdict,
        ),
        if (reason != null && !figuresFirst) ...[
          // Hybrid fit line: the reason 6 below the verdict.
          SizedBox(height: fitLine ? 6 : AppSpacing.xs),
          explanation,
        ],
        if (figures.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          // S6.16: each number as a label above its value, so the answer's
          // figures read as a set (the scale's caption and group roles).
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.sm,
            children: [
              for (final (label, value) in figures)
                MergeSemantics(
                  child: Column(
                    key: Key('status.number.$label'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        // Hybrid `.plan-measures dt`: 13 at normal leading.
                        style: text.bodySmall?.copyWith(
                          color: p.textTertiary,
                          fontSize: fitLine ? 13 : null,
                          height: fitLine ? 17 / 13 : null,
                        ),
                      ),
                      if (fitLine) const SizedBox(height: AppSpacing.xs),
                      Text(
                        value,
                        style: fitLine
                            ? text.bodyMedium?.copyWith(
                                color: p.textPrimary,
                                fontSize: 15,
                                height: 19 / 15,
                                fontWeight: FontWeight.w500,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              )
                            : text.titleSmall?.copyWith(color: p.textPrimary),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
        if (reason != null && figuresFirst) ...[
          const SizedBox(height: AppSpacing.sm),
          explanation,
        ],
        if (action != null) ...[const SizedBox(height: AppSpacing.md), action!],
      ],
    );
  }
}
