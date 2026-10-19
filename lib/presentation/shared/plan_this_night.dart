import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/calendar_date.dart';
import '../../domain/models/session.dart';
import '../viewmodels/plan_lifecycle_viewmodel.dart';
import '../viewmodels/session_plan_viewmodel.dart';
import 'failure_feedback.dart';
import 'night_time_formatter.dart';
import 'unsaved_plan_prompt.dart';

/// "Plan this night" (ADR-022 N11; D9 A; UXA-C3), the one action that
/// turns a browsed night into the plan's. Browsing never writes:
/// - a never-saved draft moves to [date] ("Plan moved to Fri 18 Dec");
/// - a saved plan is never retimed: Save · Discard · Cancel first when it
///   has unsaved changes (Cancel or a failed Save stops; Discard restores
///   what was saved), then a copy is made for [date] ("Copy made for Fri
///   18 Dec; the saved plan is unchanged").
///
/// Returns whether the plan's night is now [date].
Future<bool> planThisNight(BuildContext context, CalendarDate date) async {
  final plan = context.read<SessionPlanViewModel>();
  if (plan.eveningDate == date) return true;
  final label = NightTimeFormatter.eveningDate(date);
  final session = plan.activeSession;
  final neverSaved =
      session == null ||
      (session.status == SessionStatus.draft && session.plannedAtUtc == null);
  if (neverSaved) {
    final moved = await runWithFeedback(
      context,
      'move the plan',
      () => plan.setEveningDate(date),
    );
    if (moved && context.mounted) showDone(context, 'Plan moved to $label');
    return moved;
  }
  final lifecycle = context.read<PlanLifecycleViewModel>();
  final leaving = await askBeforeLeavingPlan(context);
  if (leaving == null || !context.mounted) return false;
  final copied = await runWithFeedback(
    context,
    'copy the plan',
    () => lifecycle.duplicateForNight(
      date,
      discard: leaving == LeavingPlan.discard,
    ),
  );
  if (copied && context.mounted) {
    showDone(context, 'Copy made for $label; the saved plan is unchanged');
  }
  return copied;
}
