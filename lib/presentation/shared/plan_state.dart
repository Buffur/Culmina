import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_theme.dart';
import '../../core/theme/hybrid_tokens.dart';
import '../../domain/models/session.dart';
import '../../domain/models/session_result.dart';
import 'app_words.dart';
import 'hybrid_icon.dart';

/// A plan's state as the user sees it (S5.4; ADR-019 §3, RD-05, RG-04).
/// The stored statuses stay internal: "Draft" is never shown.
enum PlanState {
  notSaved,
  saved,
  savedChanged,
  tracking,
  completed,

  /// A partial result, recorded through the result form (S8.1–S8.2).
  partly,
  notDone,
  oldLog;

  /// The state the stored fields express: the status, whether the plan was
  /// ever saved (`plannedAtUtc != null`), whether it is a legacy log, and how
  /// a completed result was reported (S8.1). Pure.
  static PlanState from({
    required SessionStatus status,
    required bool savedBefore,
    required bool legacy,
    ResultKind? resultKind,
  }) {
    if (legacy) return oldLog;
    return switch (status) {
      SessionStatus.draft => savedBefore ? savedChanged : notSaved,
      SessionStatus.planned => saved,
      SessionStatus.inProgress => tracking,
      SessionStatus.completed =>
        resultKind == ResultKind.partly ? partly : completed,
      SessionStatus.abandoned => notDone,
    };
  }

  static PlanState of(Session s) => from(
    status: s.status,
    savedBefore: s.plannedAtUtc != null,
    legacy: s.legacy,
    resultKind: s.resultKind,
  );

  /// Current planner facts can be newer than the stored row while autosave
  /// is pending or failed. Only explicit Save plan settles those edits.
  static PlanState forWorkingPlan(
    Session s, {
    required bool hasUnsavedChanges,
  }) {
    final stored = of(s);
    return stored == saved && hasUnsavedChanges ? savedChanged : stored;
  }

  String get word => switch (this) {
    notSaved => AppWords.notSaved,
    saved => AppWords.saved,
    savedChanged => AppWords.savedChanged,
    tracking => AppWords.tracking,
    completed => AppWords.completed,
    partly => AppWords.partly,
    notDone => AppWords.notDone,
    oldLog => AppWords.oldLog,
  };

  /// F19 A1: a result's state carries an icon beside its word (never
  /// colour alone); the others are words only.
  IconData? get icon => switch (this) {
    completed => Icons.check_circle_outline,
    partly => Icons.incomplete_circle_outlined,
    notDone => Icons.cancel_outlined,
    _ => null,
  };

  /// Unsaved work draws attention; a settled plan reads as primary text;
  /// the rest is quiet. A tone, never a verdict.
  Color tone(AppPalette p) => switch (this) {
    notSaved || savedChanged => p.stateUnsaved,
    saved || tracking || completed => p.stateSettled,
    partly || notDone || oldLog => p.stateQuiet,
  };
}

/// The plan-state label (S5.4) as the Hybrid reference's compact status
/// (notion-hybrid.css): Saved, Tracking and Completed in the success role on
/// its wash; Not saved, Saved · changed and Partly in the caution role on
/// its wash (attention, not an error); Not done and Old log quiet on the
/// selection fill. 13 px, padding 3 × 6, radius 4. [withIcon]: Tonight's
/// check (saved) or pencil (unsaved work) mark, 13 px, also used in Plan's
/// identity strip. Without an icon the word has weight 500. It wraps at
/// large text; not tappable.
class PlanStateLabel extends StatelessWidget {
  const PlanStateLabel(this.state, {super.key, this.withIcon = false});

  final PlanState state;
  final bool withIcon;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final h = Theme.of(context).extension<HybridTokens>() ?? HybridTokens.light;
    final (fg, bg) = switch (state) {
      PlanState.saved ||
      PlanState.tracking ||
      PlanState.completed => (h.success, h.successWash),
      PlanState.notSaved ||
      PlanState.savedChanged ||
      PlanState.partly => (h.caution, h.cautionWash),
      PlanState.notDone || PlanState.oldLog => (p.textPrimary, h.selection),
    };
    final settled =
        state == PlanState.saved ||
        state == PlanState.tracking ||
        state == PlanState.completed;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (withIcon) ...[
              HybridIcon(
                settled ? HybridIcons.check : HybridIcons.edit,
                size: MediaQuery.textScalerOf(context).scale(13),
                color: fg,
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
            Flexible(
              child: Text(
                state.word,
                style: AppTextTheme.of(context)
                    .resolve(
                      AppTextTheme.of(context).caption,
                      (withIcon
                          ? AppTextGeometry.timelineDate
                          : AppTextGeometry.standard),
                    )
                    .copyWith(
                      color: fg,
                      fontWeight: withIcon ? FontWeight.w400 : FontWeight.w500,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A Logbook entry's state (logbook.js `logbook-status-badge`): the state's
/// 16 px mark and its word, 13/500, on the state's wash (padding 3 × 6,
/// radius 4); [due]: Not recorded, the due mark and the word at 400 on the
/// caution wash.
class EntryStateBadge extends StatelessWidget {
  const EntryStateBadge(
    this.state, {
    super.key,
    this.due = false,
    this.large = false,
    this.word,
  });

  /// Not recorded: a saved night that has ended without a result.
  const EntryStateBadge.due({super.key, this.large = false})
    : state = PlanState.saved,
      due = true,
      word = null;

  final PlanState state;
  final bool due;

  /// The entry's header (`.logbook-state-large`): 20/500 with a 22 px mark.
  final bool large;

  /// Words instead of the state's name ("Completed, reported as planned").
  final String? word;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final h = Theme.of(context).extension<HybridTokens>() ?? HybridTokens.light;
    final (fg, bg) = due
        ? (h.caution, h.cautionWash)
        : switch (state) {
            PlanState.saved ||
            PlanState.tracking ||
            PlanState.completed => (h.success, h.successWash),
            PlanState.notSaved ||
            PlanState.savedChanged ||
            PlanState.partly => (h.caution, h.cautionWash),
            PlanState.notDone ||
            PlanState.oldLog => (p.textPrimary, h.selection),
          };
    final mark = due
        ? HybridIcons.markDue
        : switch (state) {
            PlanState.completed ||
            PlanState.oldLog => HybridIcons.markCompleted,
            PlanState.partly => HybridIcons.markPartly,
            PlanState.notDone => HybridIcons.markNotDone,
            _ => HybridIcons.markSaved,
          };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            HybridIcon(
              mark,
              size: MediaQuery.textScalerOf(context).scale(large ? 22 : 16),
              strokeWidth: 1.7,
              color: fg,
            ),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                due ? 'Not recorded' : word ?? state.word,
                semanticsLabel: due ? AppWords.resultNotRecorded : null,
                style: AppTextTheme.of(context)
                    .resolve(
                      (large
                          ? AppTextTheme.of(context).sectionHeading
                          : AppTextTheme.of(context).caption),
                      AppTextGeometry.badge,
                    )
                    .copyWith(
                      color: fg,
                      fontWeight: due ? FontWeight.w400 : FontWeight.w500,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
