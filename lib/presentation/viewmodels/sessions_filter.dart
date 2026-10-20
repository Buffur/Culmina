import '../../domain/models/calendar_date.dart';
import '../../domain/models/session.dart';
import '../../domain/services/session_reconciliation.dart';
import '../../domain/services/target_progress.dart';

/// The Sessions list's status chips (TASK 14.1). Planned includes a saved
/// plan edited since ("unsaved changes"); legacy logs are completed.
enum SessionListStatus {
  planned({SessionStatus.draft, SessionStatus.planned}),
  inProgress({SessionStatus.inProgress}),
  completed({SessionStatus.completed}),
  abandoned({SessionStatus.abandoned});

  const SessionListStatus(this.stored);
  final Set<SessionStatus> stored;
}

/// The Sessions list's filters; empty means "all" (TASK 14.1).
class SessionFilter {
  const SessionFilter({
    this.statuses = const {},
    this.targetId,
    this.siteId,
    this.from,
    this.to,
  });

  final Set<SessionListStatus> statuses;
  final int? targetId;
  final int? siteId;
  final CalendarDate? from;
  final CalendarDate? to;

  bool get isEmpty =>
      statuses.isEmpty &&
      targetId == null &&
      siteId == null &&
      from == null &&
      to == null;

  /// How many filters are set (S8.5: the Filters button's badge).
  int get count =>
      statuses.length +
      (targetId == null ? 0 : 1) +
      (siteId == null ? 0 : 1) +
      (from == null && to == null ? 0 : 1);
}

/// A session for its detail page: the planned vs actual of its run (null
/// for legacy) and its target's progress so far (TASK 14.2).
typedef SessionDetail = ({
  Session session,
  SessionReconciliation? reconciliation,
  TargetProgress? progress,
});
