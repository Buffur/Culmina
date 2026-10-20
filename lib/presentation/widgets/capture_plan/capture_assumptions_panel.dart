import 'plan_overrides_editor.dart';
import '../../../domain/models/plan_overrides.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/quantity_text.dart';
import '../../../domain/models/planning_preferences.dart';
import '../../../domain/services/capture_budget_calculator.dart';
import '../../shared/app_words.dart';
import '../../shared/collapsible_section.dart';
import '../../viewmodels/capture_analysis_viewmodel.dart';
import '../../viewmodels/session_plan_viewmodel.dart';
import '../../viewmodels/settings_viewmodel.dart';
import '../../navigation/app_router.dart';
import '../planner_sections.dart';

/// Every assumption behind the capture budget and the fit (ADR-009 §4;
/// TASK 5.6). An overhead that is off reads "Not included" — never a hidden
/// zero (SI-008). Since S6.7 (ADR-019 §7) the panel is one tap away; its
/// summary keeps the constraints that shape the window in view.
///
/// F12 (S14.12; PD-10/14; SP11): each value is the one the calculation
/// uses, written exactly, and an overhead that is on says how often this
/// plan's budget counts it (`CaptureBudget.countOf`). "Change in Settings"
/// opens the planning settings over the plan (UX-S R3), which say that they
/// are global; Back returns here. The focus reminder is words only (PD-10
/// F2): no value, no control, no calculation.
class CaptureAssumptionsPanel extends StatelessWidget {
  const CaptureAssumptionsPanel({super.key});

  /// The collapsed summary, a fact: "Darkness limit −18° · minimum
  /// altitude 30° · margin 15 %".
  static String summary(PlanningPreferences p, [PlanOverrides? overrides]) =>
      '${AppWords.darknessLimit} ${QuantityText.degrees(p.darknessLimit.degrees)}'
      ' · minimum altitude ${QuantityText.degrees(p.minAltitudeDeg)}'
      ' · margin ${overrides?.fixedMarginSeconds == null ? QuantityText.percent(p.feasibilityMarginPercent) : _s(overrides!.fixedMarginSeconds!)}';

  /// PD-10 (F2): a reminder in the plan, nothing more.
  static const focusReminder =
      'Focus on a star before the first frame, and recheck it after a '
      'filter change or as the temperature changes. A reminder only: no '
      'focus value is used, and the refocus time above is the only time it '
      'adds.';

  static const scope =
      'Settings are global defaults. This plan uses them unless an override '
      'is entered for this plan. Each Save keeps the effective values and explicit '
      'overrides with the saved plan.';

  static String _s(double s) => '${QuantityText.number(s)} s';
  static String _min(double m) => '${QuantityText.number(m)} min';

  /// How often the budget counts an included overhead: "4 times in this
  /// plan", or why it is not (an effective value, A1).
  static String _times(int n, String none) => n == 0
      ? none
      : n == 1
      ? 'once in this plan'
      : '$n times in this plan';

  /// The rows, label and effective value, for [p] and [budget].
  static List<(String, String)> rows(
    PlanningPreferences p,
    CaptureBudget budget, {
    String? inCameraNoiseReduction,
    PlanOverrides? overrides,
  }) => [
    (
      'Time between frames',
      _s(overrides?.interframeSeconds ?? p.perFrameOverheadSeconds),
    ),
    (
      'Dither',
      p.ditherEveryNFrames == null
          ? 'Not included'
          : 'every ${p.ditherEveryNFrames} lights, '
                '${_s(p.ditherSettleSeconds)} · '
                '${_times(budget.countOf(BudgetEventKind.dither), 'not reached by this plan')}',
    ),
    (
      'Refocus',
      p.refocusEveryMinutes == null
          ? 'Not included'
          : 'every ${_min(p.refocusEveryMinutes!)}, ${_s(p.refocusSeconds)} · '
                '${_times(budget.countOf(BudgetEventKind.refocus), 'not reached by this plan')}',
    ),
    (
      'Filter change',
      p.filterChangeSeconds == null
          ? 'Not included'
          : '${_s(p.filterChangeSeconds!)} · '
                '${_times(budget.countOf(BudgetEventKind.filterChange), 'no change of filter in this plan')}',
    ),
    (
      'Meridian flip',
      p.meridianFlipSeconds == null
          ? 'Not included'
          : '${_min(p.meridianFlipSeconds! / 60)} · '
                '${_times(budget.countOf(BudgetEventKind.meridianFlip), 'not counted: no meridian crossing in the window')}',
    ),
    (
      'Setup',
      overrides?.outsideSetupSeconds != null
          ? '${_s(overrides!.outsideSetupSeconds!)} before the first window (this plan)'
          : p.setupMinutes == null
          ? 'Not included'
          : '${_min(p.setupMinutes!)} before the first window',
    ),
    // S7.3b (ADR-020 §8): the rig's setting, for the types that have it.
    if (inCameraNoiseReduction != null)
      ('In-camera noise reduction', inCameraNoiseReduction),
    (
      'Feasibility margin',
      overrides?.fixedMarginSeconds == null
          ? QuantityText.percent(p.feasibilityMarginPercent)
          : '${_s(overrides!.fixedMarginSeconds!)} (this plan)',
    ),
    (AppWords.darknessLimit, QuantityText.degrees(p.darknessLimit.degrees)),
    ('Minimum target altitude', QuantityText.degrees(p.minAltitudeDeg)),
    // F12 A1: the optional gates (ADR-013 G4/G5) shape the window the fit
    // uses; when on, their thresholds are listed as the calculation takes
    // them ([PlanningPreferences.optionalGates]).
    if (p.optionalGates.moonMinIlluminationPct case final pct?)
      (
        'Moon gate',
        'excludes time when the Moon is up and at least '
            '${QuantityText.percent(pct)} lit',
      ),
    if (p.optionalGates.cloudMaxPct case final pct?)
      (
        'Cloud gate',
        'excludes forecast hours with more than '
            '${QuantityText.percent(pct)} cloud',
      ),
  ];

  @override
  Widget build(BuildContext context) {
    final p = context.watch<SettingsViewModel>().planningPreferences;
    final budget = context.watch<CaptureAnalysisViewModel>().captureBudget;
    final plan = context.watch<SessionPlanViewModel>();
    final rig = plan.selectedEquipment;
    final overrides = plan.planOverrides;
    final small = Theme.of(context).textTheme.bodySmall;
    return CollapsibleSection(
      key: const Key('capturePlan.assumptions'),
      sectionKey: PlannerSections.assumptions,
      title: 'Assumptions',
      summary: summary(p, overrides),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OutlinedButton(
            key: const Key('planOverride.edit'),
            onPressed: () => Navigator.of(context).push<void>(
              MaterialPageRoute(builder: (_) => const PlanOverridesEditor()),
            ),
            child: const Text('Edit plan assumptions'),
          ),
          Text('Preferences, not laws — measure your rig.', style: small),
          for (final (label, value) in rows(
            p,
            budget,
            overrides: overrides,
            inCameraNoiseReduction:
                rig != null && rig.cameraClass.offersInCameraNoiseReduction
                ? rig.inCameraNoiseReduction
                      ? "a dark as long as each light (the rig's setting)"
                      : 'Not included'
                : null,
          ))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(child: Text(label)),
                  const SizedBox(width: 8),
                  Flexible(child: Text(value, textAlign: TextAlign.end)),
                ],
              ),
            ),
          Text(
            'Frames are placed one after another and never span a gap '
            'between windows. Calibration taken outside the window or from '
            'your library does not use window time.',
            style: small,
          ),
          const SizedBox(height: 4),
          Text(
            focusReminder,
            key: const Key('capturePlan.focusReminder'),
            style: small,
          ),
          const SizedBox(height: 4),
          Text(
            scope,
            key: const Key('capturePlan.assumptionsScope'),
            style: small,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              key: const Key('capturePlan.changeSettings'),
              // UX-S R3: over the plan; Back returns to this section.
              onPressed: () => context.push(AppRouter.planSettings),
              child: const Text('Change in Settings'),
            ),
          ),
        ],
      ),
    );
  }
}
