import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../shared/deleted_plan_fallback.dart';

import '../../viewmodels/library_viewmodels.dart';
import '../../viewmodels/plan_lifecycle_viewmodel.dart';
import '../../viewmodels/session_plan_viewmodel.dart';
import '../../viewmodels/startup_viewmodel.dart';
import 'home_screen.dart';

/// `/session/:id` (ADR-015): the session planner. `current` shows the
/// current session directly; a stored session id is opened first
/// (`PlanLifecycleViewModel.openSession`: a frozen session becomes a copy in a
/// new draft, TASK 11.4).
class SessionPlannerRoute extends StatefulWidget {
  const SessionPlannerRoute({super.key, required this.id});

  final String id;

  @override
  State<SessionPlannerRoute> createState() => _SessionPlannerRouteState();
}

class _SessionPlannerRouteState extends State<SessionPlannerRoute>
    with RestorationMixin {
  Future<void>? _opening;

  /// F22 A2: set once the route has opened its plan. A route restored after
  /// a process death never opens it again: the planner shows its current
  /// plan as restored, so no other site, night or saved plan is adopted.
  final _opened = RestorableBool(false);
  bool _started = false;

  @override
  String get restorationId => 'planner';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_opened, 'opened');
    if (_started) return;
    _started = true;
    final id = int.tryParse(widget.id);
    if (_opened.value) {
      // Restored: only check that the plan still exists (A1).
      if (id != null) _opening = _stillThere(id);
      return;
    }
    _opened.value = true;
    final plan = context.read<SessionPlanViewModel>();
    if (id != null && id != plan.activeSessionId) {
      _opening = _open(
        context.read<StartupViewModel>(),
        context.read<PlanLifecycleViewModel>(),
        context.read<SessionsViewModel>(),
        id,
      );
    }
  }

  /// A1: the plan a restored route names was deleted: Tonight, and why.
  Future<void> _stillThere(int id) async {
    final sessions = context.read<SessionsViewModel>();
    await context.read<StartupViewModel>().ready;
    if (await sessions.get(id) == null && mounted) {
      showDeletedPlanFallback(context);
    }
  }

  @override
  void dispose() {
    _opened.dispose();
    super.dispose();
  }

  static Future<void> _open(
    StartupViewModel startup,
    PlanLifecycleViewModel lifecycle,
    SessionsViewModel sessions,
    int id,
  ) async {
    await startup.ready;
    final session = await sessions.get(id);
    if (session != null) await lifecycle.openSession(session);
  }

  @override
  Widget build(BuildContext context) {
    final opening = _opening;
    if (opening == null) return const HomeScreen();
    return FutureBuilder<void>(
      future: opening,
      builder: (context, snapshot) =>
          snapshot.connectionState == ConnectionState.done
          ? const HomeScreen()
          : const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}
