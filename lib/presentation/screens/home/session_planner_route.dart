import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../navigation/app_router.dart';
import '../../shared/deleted_plan_fallback.dart';
import '../../shared/failure_feedback.dart';
import '../../shared/field_mode_button.dart';
import '../../shared/hybrid_app_bar.dart';

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

enum _PlannerOpenResult { ready, missing }

class _SessionPlannerRouteState extends State<SessionPlannerRoute>
    with RestorationMixin {
  Future<_PlannerOpenResult>? _opening;
  bool _restoredCheck = false;
  int _generation = 0;

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
      _restoredCheck = true;
      // Restored: only check that the plan still exists (A1).
      if (id != null) _opening = _stillThere(id);
      if (id == null && widget.id != 'current') {
        _opening = Future.value(_PlannerOpenResult.missing);
      }
      return;
    }
    _opened.value = true;
    _beginOpening();
  }

  @override
  void didUpdateWidget(SessionPlannerRoute oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id == widget.id) return;
    // A new route parameter is an explicit opening, not process restoration.
    _restoredCheck = false;
    _beginOpening();
  }

  void _beginOpening() {
    final generation = ++_generation;
    _opening = null;
    final id = int.tryParse(widget.id);
    if (id == null && widget.id != 'current') {
      _opening = Future.value(_PlannerOpenResult.missing);
      return;
    }
    final plan = context.read<SessionPlanViewModel>();
    if (id != null && id != plan.activeSessionId) {
      _opening = _open(
        context.read<StartupViewModel>(),
        context.read<PlanLifecycleViewModel>(),
        context.read<SessionsViewModel>(),
        id,
        generation,
      );
    }
  }

  /// A1: the plan a restored route names was deleted: Tonight, and why.
  Future<_PlannerOpenResult> _stillThere(int id) async {
    final generation = ++_generation;
    final sessions = context.read<SessionsViewModel>();
    await context.read<StartupViewModel>().ready;
    if (await sessions.get(id) == null) {
      if (mounted && generation == _generation) {
        showDeletedPlanFallback(context);
      }
      return _PlannerOpenResult.missing;
    }
    return _PlannerOpenResult.ready;
  }

  void _retry() {
    final id = int.tryParse(widget.id);
    if (id == null) return;
    setState(() {
      _opening = _restoredCheck
          ? _stillThere(id)
          : _open(
              context.read<StartupViewModel>(),
              context.read<PlanLifecycleViewModel>(),
              context.read<SessionsViewModel>(),
              id,
              ++_generation,
            );
    });
  }

  @override
  void dispose() {
    _opened.dispose();
    super.dispose();
  }

  Future<_PlannerOpenResult> _open(
    StartupViewModel startup,
    PlanLifecycleViewModel lifecycle,
    SessionsViewModel sessions,
    int id,
    int generation,
  ) async {
    await startup.ready;
    final session = await sessions.get(id);
    if (session == null || !mounted || generation != _generation) {
      return _PlannerOpenResult.missing;
    }
    await lifecycle.openSession(session);
    return _PlannerOpenResult.ready;
  }

  @override
  Widget build(BuildContext context) {
    final opening = _opening;
    if (opening == null) return const HomeScreen();
    return FutureBuilder<_PlannerOpenResult>(
      future: opening,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasError && snapshot.data == _PlannerOpenResult.ready) {
          return const HomeScreen();
        }
        return Scaffold(
          appBar: hybridAppBar(
            context,
            title: const Text('Plan'),
            actions: const [FieldModeButton()],
          ),
          body: snapshot.hasError
              ? LoadFailureView(
                  action: 'open the plan',
                  error: snapshot.error!,
                  onRetry: _retry,
                )
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.gutter),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('This plan could not be found.'),
                        const SizedBox(height: AppSpacing.sm),
                        TextButton(
                          onPressed: () => context.go(AppRouter.tonight),
                          child: const Text('Back to Tonight'),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}
