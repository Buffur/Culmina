import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
import '../../core/theme/app_spacing.dart';
import '../../domain/models/session.dart';
import '../../domain/models/session_result.dart';
import 'app_words.dart';

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

/// The plan-state label (S5.4): the state's word in its tone, in a quiet
/// quiet icon and label. It wraps at large text sizes; it is not tappable.
class PlanStateLabel extends StatelessWidget {
  const PlanStateLabel(this.state, {super.key});

  final PlanState state;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (state.icon case final icon?) ...[
          Icon(icon, size: 14, color: state.tone(p)),
          const SizedBox(width: AppSpacing.xs),
        ],
        Flexible(
          child: Text(
            state.word,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: state.tone(p)),
          ),
        ),
      ],
    );
  }
}
