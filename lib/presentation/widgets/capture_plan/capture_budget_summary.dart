import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_palette.dart';
import '../../../domain/services/capture_budget_calculator.dart';
import '../../shared/app_words.dart';
import '../../shared/change_mark.dart';
import '../../shared/collapsible_section.dart';
import '../../shared/context_line.dart';
import '../../shared/night_time_formatter.dart';
import '../../shared/storage_text.dart';
import '../../viewmodels/metadata_import_viewmodel.dart';
import 'storage_actions.dart';
import '../planner_sections.dart';
import 'stacking_gain_graph.dart';
import '../../viewmodels/capture_analysis_viewmodel.dart';
import '../../viewmodels/night_conditions_viewmodel.dart';
import '../../viewmodels/session_plan_viewmodel.dart';
import '../../viewmodels/site_viewmodel.dart';
import '../../../core/utils/quantity_text.dart';

/// A millisecond capture budget, retaining seconds as the Hybrid plan does.
String formatBudgetDuration(int ms) =>
    QuantityText.budgetDuration(Duration(milliseconds: ms));

/// The capture plan's outputs (ADR-009 §2, §7; TASK 5.6): the budget
/// breakdown, relative stacking gain per group and storage. The fit, its
/// reason, its end and "fill the window" are the planner's status since S6.6
/// (`PlanStatus`), shown once. Since S6.7 (ADR-019 §7) the breakdown is in
/// Budget details and the √N explanation one tap away, each behind a
/// factual summary; the √N values and storage stay visible. Renders
/// ViewModel/domain values only — no calculations here.
class CaptureBudgetSummary extends StatelessWidget {
  const CaptureBudgetSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final analysis = context.watch<CaptureAnalysisViewModel>();
    final plan = context.watch<SessionPlanViewModel>();
    final budget = analysis.captureBudget;
    final frames = analysis.frameStorage;
    final fit = analysis.fitAnalysis;
    final night = plan.sessionNight;
    final windows = context.watch<NightConditionsViewModel>().visibilityWindows;
    final setupStart = budget.setupStartUtc(windows);

    final zoneId = context.watch<SiteViewModel>().displayZoneId;
    String clock(DateTime utc) => night == null
        ? NightTimeFormatter.clockTime(context, utc, zoneId: zoneId)
        : NightTimeFormatter.instant(
            context,
            utc,
            windowStartUtc: night.startUtc,
            zoneId: zoneId,
          );

    final library = budget.libraryBlockIndexes.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text('Estimate', style: theme.textTheme.titleMedium),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final singleColumn =
                MediaQuery.textScalerOf(context).scale(14) >= 24 ||
                constraints.maxWidth < 280;
            final width = singleColumn
                ? constraints.maxWidth
                : (constraints.maxWidth - 20) / 2;
            return Wrap(
              spacing: 20,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: width,
                  child: _Estimate(
                    key: const Key('estimate.integration'),
                    label: 'Integration',
                    value: formatBudgetDuration(budget.integrationMs),
                    note: 'Light exposures only',
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _Estimate(
                    key: const Key('estimate.sessionTime'),
                    label: 'Total session time',
                    value: formatBudgetDuration(budget.sessionBudgetMs),
                    note: 'With overheads, setup and calibration',
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _Estimate(
                    key: const Key('capturePlan.storage'),
                    label: 'Estimated storage',
                    value: budget.storageMB != null
                        ? QuantityText.storage(budget.storageMB! * 1e6)
                        : 'Unknown',
                    note: '',
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _Estimate(
                    key: const Key('estimate.gain'),
                    label: 'Relative stacking gain',
                    value: budget.lightGroups.length == 1
                        ? '${budget.lightGroups.single.relativeStackingGain.toStringAsFixed(2)}×'
                        : budget.lightGroups.isEmpty
                        ? 'Unknown'
                        : '${budget.lightGroups.length} groups',
                    note: budget.lightGroups.isEmpty
                        ? 'Needs light frames'
                        : 'Against one frame of the same group',
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        Text(
          'Ideal √N within comparable light frames, not absolute signal-to-noise.',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 24),
        // S6.7 (ADR-019 §7): every ADR-009 line on its own line, one tap
        // away; the status above shows the answer's numbers.
        // S6.10 (P6.9): Time needed · Total time stay in view, marked
        // briefly when an edit changes them; every line is inside.
        ChangeMark(
          value: budgetSummary(budget),
          child: CollapsibleSection(
            sectionKey: PlannerSections.budgetDetails,
            title: AppWords.budgetDetails,
            summary: budgetSummary(budget),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Line(
                  '${AppWords.integration} (light exposure)',
                  formatBudgetDuration(budget.integrationMs),
                  key: const Key('budget.integration'),
                ),
                _Line(
                  '${AppWords.imagingTime} (lights + overheads)',
                  formatBudgetDuration(budget.acquisitionMs),
                  key: const Key('budget.imagingTime'),
                ),
                if (budget.inWindowCalibrationMs > 0)
                  _Line(
                    'Calibration during the window',
                    formatBudgetDuration(budget.inWindowCalibrationMs),
                    key: const Key('budget.calibrationIn'),
                  ),
                // S7.3b (ADR-020 §8): the part the camera's noise reduction
                // takes, one dark as long as each light.
                if (budget.inCameraDarkMs > 0)
                  _Line(
                    'Of which in-camera darks',
                    formatBudgetDuration(budget.inCameraDarkMs),
                    key: const Key('budget.inCameraDarks'),
                  ),
                _Line(
                  '${AppWords.timeNeeded} (in the window)',
                  fit.availableMs > 0
                      ? '${formatBudgetDuration(budget.windowLoadMs)} of '
                            '${formatBudgetDuration(fit.availableMs)}'
                      : formatBudgetDuration(budget.windowLoadMs),
                  key: const Key('budget.timeNeeded'),
                  emphasis: true,
                ),
                _Line(
                  'Calibration outside the window',
                  budget.outsideWindowCalibrationMs > 0
                      ? formatBudgetDuration(budget.outsideWindowCalibrationMs)
                      : 'None',
                  key: const Key('budget.calibrationOut'),
                ),
                _Line(
                  'Setup',
                  budget.setupMs == null
                      ? 'Not included'
                      : setupStart == null
                      ? formatBudgetDuration(budget.setupMs!)
                      : '${formatBudgetDuration(budget.setupMs!)} — start by '
                            '${clock(setupStart)}',
                  key: const Key('budget.setup'),
                ),
                _Line(
                  AppWords.totalTime,
                  formatBudgetDuration(budget.sessionBudgetMs),
                  key: const Key('budget.totalTime'),
                  emphasis: true,
                ),
                if (library > 0)
                  _Line(
                    'Library calibration',
                    '$library block${library == 1 ? '' : 's'}, no time needed',
                    key: const Key('budget.library'),
                  ),
                // The zone rule, once for the section's one time (trap 2).
                if (setupStart != null && night != null)
                  Text(
                    ContextLine.zoneRule(night.startUtc, zoneId: zoneId),
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // The √N values stay visible and relative (SI-003); the long
        // explanation is one tap away. F11 (ADR-021 C16): one line per
        // comparable group, never combined.
        CollapsibleSection(
          sectionKey: PlannerSections.gainHelp,
          title: AppWords.relativeStackingGain,
          summary: gainSummary,
          child: Text(
            '√N compares the random noise of a stack with one frame of the '
            'same filter, exposure, ISO or gain and binning. It only applies '
            'within such a group, assumes equal frames, is not a '
            'signal-to-noise ratio of your image, and ignores sky '
            'brightness, the target and your camera.',
            key: const Key('capturePlan.gainHelp'),
            style: theme.textTheme.bodySmall,
          ),
        ),
        if (budget.lightGroups.isEmpty)
          Text(
            noLightGroups,
            key: const Key('capturePlan.noGain'),
            style: theme.textTheme.bodySmall,
          )
        else ...[
          for (final (i, g) in budget.lightGroups.indexed)
            _Line(
              '${StackingGainGraph.groupName(g)} × ${g.frames}',
              '${g.relativeStackingGain.toStringAsFixed(1)}x',
              key: Key('capturePlan.gain.$i'),
            ),
          if (budget.lightGroups.any((g) => !g.comparable))
            Text(
              notComparable,
              key: const Key('capturePlan.gainNotComparable'),
              style: theme.textTheme.bodySmall,
            ),
          // S6.11 (P6.10) and O2b (PD-05): how the gain grows with
          // integration time, per group, normalized to the plan; in
          // Details, so the plan shows numbers before Save, not graphs.
          CollapsibleSection(
            sectionKey: PlannerSections.gainCurve,
            title: 'Over integration time',
            summary: 'Per group, relative to your plan',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (i, g) in budget.lightGroups.indexed) ...[
                  Text(
                    StackingGainGraph.groupName(g),
                    style: theme.textTheme.labelMedium,
                  ),
                  StackingGainGraph(
                    key: Key('capturePlan.gainGraph.$i'),
                    curve: g.gainCurve,
                    groupLabel: StackingGainGraph.groupName(g),
                  ),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        // F07 (ADR-021 C8–C12): each block's frame size from its first
        // compatible evidence; the total only when every block's is known.
        // S6.10 (P6.9; the trace's case C): a known value says what it
        // rests on; an unknown one says why, and how to supply it.
        Text(
          StorageText.plan(plan.captureBlocks, frames, [
            for (final b in budget.blocks)
              b.placement != BudgetPlacement.library,
          ], rig: plan.selectedEquipment),
          key: const Key('capturePlan.storageNote'),
          style: theme.textTheme.bodySmall,
        ),
        if (plan.selectedEquipment != null && frames.any((f) => !f.known))
          Wrap(
            spacing: 8,
            children: [
              if (context.watch<MetadataImportViewModel?>() != null)
                TextButton(
                  key: const Key('capturePlan.chooseFile'),
                  onPressed: () => chooseStorageFile(context),
                  child: const Text('Choose one file'),
                ),
              TextButton(
                key: const Key('capturePlan.setFileSize'),
                onPressed: () => enterStorageSize(context),
                child: const Text('Enter a size'),
              ),
            ],
          ),
      ],
    );
  }

  /// Budget details' collapsed summary, a fact in the glossary's words:
  /// "Time needed 2 h 5 min · Total time 3 h" (S6.7; S6.10).
  static String budgetSummary(CaptureBudget budget) =>
      '${AppWords.timeNeeded} ${formatBudgetDuration(budget.windowLoadMs)} · '
      '${AppWords.totalTime} ${formatBudgetDuration(budget.sessionBudgetMs)}';

  /// The gain section's collapsed summary: what a group's one frame is.
  static const gainSummary = 'Per group, against one of its frames';

  static const noLightGroups =
      'No light frames yet: add light frames to see their relative gain.';

  /// C16: an unknown setting never proves two blocks alike.
  static const notComparable =
      'ISO or gain not recorded: each such block is shown on its own, never '
      'combined with another.';
}

/// One responsive Hybrid estimate cell. Values come from the existing budget;
/// the presentation does not substitute the prototype's sample arithmetic.
class _Estimate extends StatelessWidget {
  const _Estimate({
    super.key,
    required this.label,
    required this.value,
    required this.note,
  });

  final String label;
  final String value;
  final String note;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = AppPalette.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: palette.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: text.bodySmall?.copyWith(color: palette.textSecondary),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: text.titleLarge?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (note.isNotEmpty)
              Text(
                note,
                style: text.bodySmall?.copyWith(color: palette.textSecondary),
              ),
          ],
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(this.label, this.value, {super.key, this.emphasis = false});

  final String label;
  final String value;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: emphasis ? FontWeight.bold : FontWeight.normal,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(label, style: style)),
          const SizedBox(width: 8),
          // TASK 15.3: the value wraps too at 200 % text.
          Flexible(
            child: Text(value, style: style, textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }
}
