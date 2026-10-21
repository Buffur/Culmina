import '../../domain/models/imaging_opportunity.dart';
import '../../domain/models/planning_preferences.dart';
import '../../domain/services/fit_analyzer.dart';
import 'night_conditions_viewmodel.dart';
import 'session_plan_viewmodel.dart';

/// Why the plan has no usable window tonight (TASK 5.5), for the fit: a
/// missing site or target first, then the optional Moon and cloud gates,
/// else what the night's timeline says.
String fitNoWindowReason(
  SessionPlanViewModel plan,
  NightConditionsViewModel conditions,
  PlanningPreferences prefs,
) {
  if (plan.sessionNight == null) {
    return "Set a site to see tonight's windows.";
  }
  if (plan.selectedTarget == null) {
    return "Choose a target to see tonight's windows.";
  }
  if (conditions.imagingOpportunity?.noWindowReason ==
      NoWindowReason.excludedByOptionalGates) {
    return 'No usable window: your Moon or cloud gate excludes all of '
        "tonight's dark time with the target high enough.";
  }
  return FitAnalyzer.noWindowReason(
    timeline: conditions.nightTimeline!,
    darknessLimitDeg: prefs.darknessLimit.degrees,
    minAltitudeDeg: prefs.minAltitudeDeg,
  );
}
