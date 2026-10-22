import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_palette.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/models/calendar_date.dart';
import '../../core/utils/quantity_text.dart';
import '../../domain/services/fit_analyzer.dart';
import '../navigation/app_router.dart';
import '../shared/plan_night_phrase.dart';
import '../shared/app_words.dart';
import '../shared/change_mark.dart';
import '../shared/failure_feedback.dart';
import '../shared/night_text.dart';
import '../shared/night_time_formatter.dart';
import '../shared/status_block.dart';
import '../viewmodels/capture_analysis_viewmodel.dart';
import '../viewmodels/session_plan_viewmodel.dart';
import '../viewmodels/site_viewmodel.dart';
import 'capture_plan/blocks_undo.dart';

/// What the plan's answer waits for (S6.6; TD-075): the headline, its own
/// reason, and the action that supplies it (null for a site: the banner and
/// the context line offer it).
typedef MissingInput = ({
  String headline,
  String reason,
  String? action,
  String? route,
});

/// The planner's answer, first (S6.6; ADR-019 §6.2; UX-01): the verdict with
/// its relationship ("Fits: 2 h 5 min needed of 4 h 20 min usable"), its key
/// reason, when capture ends, the integration, and the next action — fill or
/// trim from the fit, or the missing input to choose. Every value comes from
/// `FitAnalyzer` and `CaptureBudget` through the ViewModel; no percentage,
/// score or good/bad rating. A missing site, target or rig is neutral.
class PlanStatus extends StatelessWidget {
  const PlanStatus({super.key, this.showFillAction = true});
  final bool showFillAction;

  /// The missing-input headlines for a site and a rig (S6.6).
  static const needsSite = 'Needs a site';
  static const needsRig = 'Needs a rig';

  /// Each missing input's own reason (TD-075, S6.16): the fit's reason
  /// answers another question (an empty plan is decided before a missing
  /// window), so it is shown only once nothing is missing.
  static const siteReason =
      "Set a site to see the night and the target's windows.";
  static const targetReason = "Choose a target to see tonight's windows.";
  static const rigReason =
      'A rig is needed to save the plan and to check exposures.';

  /// The input the answer waits for, in the order it is needed: its
  /// headline, its reason, the action's label and route, or null when
  /// nothing is missing. Shared with Tonight's plan card (S6.13). The
  /// glossary's "Needs a …" pattern (a target, a block) is applied to a site
  /// and a rig here; the site's action is the banner's and the context
  /// line's, so it is not repeated.
  static MissingInput? missingInput(SessionPlanViewModel plan) =>
      plan.sessionNight == null
      ? (headline: needsSite, reason: siteReason, action: null, route: null)
      : plan.selectedTarget == null
      ? (
          headline: AppWords.needsTarget,
          reason: targetReason,
          action: 'Choose a target',
          route: AppRouter.selectTarget,
        )
      : plan.selectedEquipment == null
      ? (
          headline: needsRig,
          reason: rigReason,
          action: AppWords.chooseRig,
          // D8 A: a rig created from this action becomes the plan's.
          route: AppRouter.selectRigForPlan,
        )
      : null;

  @override
  Widget build(BuildContext context) {
    final analysis = context.watch<CaptureAnalysisViewModel>();
    final plan = context.watch<SessionPlanViewModel>();
    final site = context.watch<SiteViewModel>();
    final fit = analysis.fitAnalysis;
    final night = plan.sessionNight;

    final missing = missingInput(plan);
    final state = missing != null ? FitState.needsInput : fit.state;
    // F18 A6 (AM-03): the plan's night in the words, never its values.
    String words(String text) => PlanNightPhrase.apply(
      text,
      plan.eveningDate ?? plan.tonightKey,
      plan.tonightKey,
    );

    final measured =
        missing == null &&
        (fit.state == FitState.fits ||
            fit.state == FitState.tight ||
            fit.state == FitState.doesNotFit);
    final end = fit.endUtc;
    final action = missing?.action;
    final palette = AppPalette.of(context);
    final body = AppTypography.body.copyWith(height: 1.6);
    final verdict = StatusBlock.headline(state, missing: missing?.headline);
    final zoneId = site.displayZoneId;
    String captureEnd(DateTime utc) {
      final wall = NightTimeFormatter.wallClock(utc, zoneId: zoneId);
      return '${NightTimeFormatter.recordedDate(CalendarDate.fromDateTimeFields(wall))}, '
          '${NightTimeFormatter.clockTime(context, utc, zoneId: zoneId)} '
          '${NightTimeFormatter.shortZone(utc, zoneId: zoneId)}';
    }

    // plan.js `answer` (Hybrid): the verdict 22/500 in its status colour,
    // "Needed in imaging window: …" with "… usable" below it, the reason and
    // the capture end, 6 apart; the missing input's action below.
    return Padding(
      key: const Key('planner.status'),
      padding: const EdgeInsets.only(top: 12),
      // S6.10 (P6.9's cause and effect): an edit that changes the verdict or
      // its numbers marks the status briefly.
      child: ChangeMark(
        key: const Key('planner.statusMark'),
        value: (
          state,
          missing?.headline,
          fit.windowLoadMs,
          fit.availableMs,
          analysis.captureBudget.integrationMs,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(
                verdict,
                key: const Key('status.headline'),
                style: AppTypography.screenTitle.copyWith(
                  height: 1.4,
                  letterSpacing: -0.33,
                  color: FitText.color(
                    state,
                    Theme.of(context).colorScheme,
                    palette,
                  ),
                ),
              ),
            ),
            if (measured) ...[
              const SizedBox(height: 2),
              Text(
                'Needed in imaging window: '
                '${QuantityText.budgetDuration(Duration(milliseconds: fit.windowLoadMs))}',
                key: const Key('status.number.Needed in imaging window'),
                style: body.copyWith(color: palette.textPrimary),
              ),
              if (fit.availableMs > 0)
                Text(
                  '${QuantityText.budgetDuration(Duration(milliseconds: fit.availableMs))} usable',
                  key: const Key('status.number.Usable'),
                  style: body.copyWith(
                    fontWeight: FontWeight.w500,
                    color: palette.textSecondary,
                  ),
                ),
            ],
            const SizedBox(height: 6),
            // TD-075: a missing input's own reason, else the fit's.
            Text(
              words(missing?.reason ?? fit.reason),
              key: const Key('status.reason'),
              style: body.copyWith(color: palette.textSecondary),
            ),
            if (missing == null &&
                end != null &&
                night != null &&
                (fit.state == FitState.fits ||
                    fit.state == FitState.tight)) ...[
              const SizedBox(height: 6),
              Text(
                'Capture end: ${captureEnd(end)}.',
                key: const Key('status.number.Capture ends'),
                style: body.copyWith(color: palette.textSecondary),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppSpacing.md),
              OutlinedButton(
                key: const Key('status.choose'),
                onPressed: () => context.push(missing!.route!),
                child: Text(action),
              ),
            ] else if (measured && showFillAction) ...[
              const SizedBox(height: AppSpacing.md),
              FillWindowAction(fit: fit),
            ],
          ],
        ),
      ),
    );
  }
}

/// "Fill tonight's window" or "Trim … to fit tonight" (TASK 5.6): one action
/// that sets the plan's last light block to the largest frame count that
/// still places. Moved into the status in S6.6; values from the ViewModel.
/// Since S6.16 (TD-079) it says what it did, with Undo.
class FillWindowAction extends StatelessWidget {
  const FillWindowAction({super.key, required this.fit});

  final FitResult fit;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CaptureAnalysisViewModel>();
    final index = viewModel.fillWindowBlockIndex;
    final target = viewModel.fillWindowFrameCount;
    if (index == null || target == null) return const SizedBox.shrink();
    final plan = context.watch<SessionPlanViewModel>();
    final block = plan.captureBlocks[index];
    // F18 A6: the plan's night in the words.
    String words(String text) => PlanNightPhrase.apply(
      text,
      plan.eveningDate ?? plan.tonightKey,
      plan.tonightKey,
    );
    final label =
        '${block.filterName ?? 'Light'} '
        '${QuantityText.exposure(block.exposureTimeSeconds)}';
    if (target < 1) {
      return Text(
        words('Not even one $label frame fits tonight.'),
        style: Theme.of(context).textTheme.bodySmall,
      );
    }
    if (target == block.frameCount) return const SizedBox.shrink();
    final trim = target < block.frameCount;
    return Align(
      alignment: Alignment.centerLeft,
      child: OutlinedButton.icon(
        key: const Key('capturePlan.fillWindow'),
        icon: Icon(trim ? Icons.content_cut : Icons.open_in_full),
        label: Text(
          words(
            trim
                ? 'Trim $label to $target frames to fit tonight'
                : 'Fill tonight\'s window: $label × $target',
          ),
        ),
        onPressed: () => runWithFeedback(
          context,
          trim ? 'trim the block' : "fill tonight's window",
          () => editBlocksWithUndo(
            context,
            message: trim
                ? 'Trimmed $label to $target frames'
                : 'Filled $label to $target frames',
            change: viewModel.fillWindow,
          ),
        ),
      ),
    );
  }
}
