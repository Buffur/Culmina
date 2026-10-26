import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/services/capture_budget_calculator.dart';
import '../../shared/app_words.dart';
import '../../shared/change_mark.dart';
import '../../shared/collapsible_section.dart';
import '../../shared/context_line.dart';
import '../../shared/hybrid_parts.dart';
import '../../shared/hybrid_quiet_ink.dart';
import 'capture_assumptions_panel.dart';
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
    final analysis = context.watch<CaptureAnalysisViewModel>();
    final plan = context.watch<SessionPlanViewModel>();
    final palette = AppPalette.of(context);
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
    final groups = budget.lightGroups;
    final storageNote = StorageText.plan(plan.captureBlocks, frames, [
      for (final b in budget.blocks) b.placement != BudgetPlacement.library,
    ], rig: plan.selectedEquipment);

    final library = budget.libraryBlockIndexes.length;
    final caption = AppTypography.caption.copyWith(
      height: 1.6,
      color: palette.textTertiary,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const HybridSectionTitle('Estimate'),
        const SizedBox(height: 10),
        // plan.js `estimate-grid`: two columns 20 apart, rows 16 apart.
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
                    note: 'light exposures only',
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _Estimate(
                    key: const Key('estimate.sessionTime'),
                    label: 'Total session time',
                    value: formatBudgetDuration(budget.sessionBudgetMs),
                    note: 'with overheads, setup and calibration',
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _Estimate(
                    key: const Key('capturePlan.storage'),
                    label: 'Storage',
                    value: budget.storageMB != null
                        ? QuantityText.storage(budget.storageMB! * 1e6)
                        : 'Unknown',
                    note: budget.storageMB != null
                        ? 'from the file sizes below, not measured'
                        : 'file size not known yet',
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _Estimate(
                    key: const Key('estimate.gain'),
                    label: 'Relative stacking gain',
                    value: groups.length == 1
                        ? '×${groups.single.relativeStackingGain.toStringAsFixed(2)}'
                        : groups.isEmpty
                        ? 'Unknown'
                        : '${groups.length} groups',
                    note: groups.length == 1
                        ? 'vs one comparable frame · ${groups.single.frames} frames'
                        : groups.isEmpty
                        ? 'needs light frames'
                        : 'per comparable group, listed below',
                  ),
                ),
              ],
            );
          },
        ),
        if (groups.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (i, g) in groups.indexed)
                  DecoratedBox(
                    key: Key('capturePlan.gain.$i'),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: palette.border)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  '×${g.relativeStackingGain.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: palette.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text:
                                  ' vs one comparable frame · ${g.frames} × '
                                  '${StackingGainGraph.groupName(g)}',
                            ),
                          ],
                        ),
                        style: AppTypography.caption.copyWith(
                          color: palette.textSecondary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        Text(
          'Relative gain is ideal √N within comparable light frames, not '
          'absolute signal-to-noise.',
          key: const Key('capturePlan.gainNote'),
          style: caption,
        ),
        const SizedBox(height: 8),
        // S6.7 (ADR-019 §7): every ADR-009 line one tap away; S6.10 (P6.9):
        // an edit that changes them marks the section briefly.
        ChangeMark(
          value: budgetSummary(budget),
          child: CollapsibleSection(
            key: const Key('capturePlan.assumptions'),
            sectionKey: PlannerSections.budgetDetails,
            title: 'Budget and assumptions',
            summary: 'Window time, overheads and file-size basis',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                HybridFactList([
                  HybridFact(
                    'Needed in imaging window',
                    fit.availableMs > 0
                        ? '${formatBudgetDuration(budget.windowLoadMs)} of '
                              '${formatBudgetDuration(fit.availableMs)}'
                        : formatBudgetDuration(budget.windowLoadMs),
                    key: const Key('budget.timeNeeded'),
                    emphasis: true,
                  ),
                  HybridFact(
                    '${AppWords.integration} (light exposure)',
                    formatBudgetDuration(budget.integrationMs),
                    key: const Key('budget.integration'),
                  ),
                  HybridFact(
                    '${AppWords.imagingTime} (lights + overheads)',
                    formatBudgetDuration(budget.acquisitionMs),
                    key: const Key('budget.imagingTime'),
                  ),
                  if (budget.inWindowCalibrationMs > 0)
                    HybridFact(
                      'Calibration during the window',
                      formatBudgetDuration(budget.inWindowCalibrationMs),
                      key: const Key('budget.calibrationIn'),
                    ),
                  // S7.3b (ADR-020 §8): the part the camera's noise
                  // reduction takes, one dark as long as each light.
                  if (budget.inCameraDarkMs > 0)
                    HybridFact(
                      'Of which in-camera darks',
                      formatBudgetDuration(budget.inCameraDarkMs),
                      key: const Key('budget.inCameraDarks'),
                    ),
                  HybridFact(
                    'Time outside the window',
                    budget.outsideWindowCalibrationMs > 0
                        ? formatBudgetDuration(
                            budget.outsideWindowCalibrationMs,
                          )
                        : 'None',
                    key: const Key('budget.calibrationOut'),
                  ),
                  HybridFact(
                    'Setup',
                    budget.setupMs == null
                        ? 'Not included'
                        : setupStart == null
                        ? formatBudgetDuration(budget.setupMs!)
                        : '${formatBudgetDuration(budget.setupMs!)} — start by '
                              '${clock(setupStart)}',
                    key: const Key('budget.setup'),
                  ),
                  HybridFact(
                    AppWords.totalTime,
                    formatBudgetDuration(budget.sessionBudgetMs),
                    key: const Key('budget.totalTime'),
                    emphasis: true,
                  ),
                  if (library > 0)
                    HybridFact(
                      'Library calibration',
                      '$library block${library == 1 ? '' : 's'}, no time needed',
                      key: const Key('budget.library'),
                    ),
                  MergeSemantics(
                    key: const Key('capturePlan.storageNote'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'File size basis',
                          style: AppTypography.caption.copyWith(
                            color: palette.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          storageNote,
                          textAlign: TextAlign.start,
                          style: AppTypography.caption.copyWith(
                            color: palette.textSecondary,
                            height: 1.7,
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
                // The assumptions behind the budget and the fit (ADR-009
                // §4; F12): every value the calculation uses, then the
                // reminders and the way to change them.
                const CaptureAssumptionsPanel(),
                if (setupStart != null && night != null) ...[
                  const SizedBox(height: 8),
                  HybridNote(
                    ContextLine.zoneRule(night.startUtc, zoneId: zoneId),
                  ),
                ],
                if (plan.selectedEquipment != null &&
                    frames.any((f) => !f.known))
                  Wrap(
                    spacing: 8,
                    children: [
                      if (context.watch<MetadataImportViewModel?>() != null)
                        TextButton(
                          key: const Key('capturePlan.chooseFile'),
                          style: HybridQuietInk.buttonStyle(context),
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
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        // The √N values stay relative (SI-003); F11 (ADR-021 C16): one line
        // per comparable group, never combined.
        CollapsibleSection(
          key: const Key('capturePlan.gainDetails'),
          sectionKey: PlannerSections.gainHelp,
          title: 'Stacking gain details',
          summary: gainSummary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (groups.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: HybridNote(
                    noLightGroups,
                    key: const Key('capturePlan.noGain'),
                  ),
                )
              else ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    'Ideal relative gain within each comparable light group',
                    style: AppTypography.dense.copyWith(
                      color: palette.textSecondary,
                    ),
                  ),
                ),
                _GainTable(groups: groups),
                for (final (i, g) in groups.indexed)
                  StackingGainGraph(
                    key: Key('capturePlan.gainGraph.$i'),
                    curve: g.gainCurve,
                    caption: '${i + 1} · ${StackingGainGraph.groupName(g)}',
                    groupLabel: StackingGainGraph.groupName(g),
                  ),
                if (groups.any((g) => !g.comparable))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: HybridNote(
                      notComparable,
                      key: const Key('capturePlan.gainNotComparable'),
                    ),
                  ),
              ],
              HybridNote(
                'Frames are comparable when exposure, filter, recorded ISO '
                'or gain and binning match. Groups with an unrecorded setting '
                'stay separate. √N describes ideal averaging of comparable '
                'frames: twice the time gives 1.41×, not 2×. It isn\'t '
                'absolute signal-to-noise and doesn\'t include sky, sensor '
                'or processing effects.',
                key: const Key('capturePlan.gainHelp'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }

  /// Budget details' summary, a fact in the glossary's words:
  /// "Time needed 2 h 5 min · Total time 3 h" (S6.7; S6.10).
  static String budgetSummary(CaptureBudget budget) =>
      '${AppWords.timeNeeded} ${formatBudgetDuration(budget.windowLoadMs)} · '
      '${AppWords.totalTime} ${formatBudgetDuration(budget.sessionBudgetMs)}';

  /// Stacking gain details' summary (plan.js `gainDisclosure`).
  static const gainSummary = 'Per-group table and time curve';

  static const noLightGroups =
      'No light frames yet: add light frames to see their relative gain.';

  /// C16: an unknown setting never proves two blocks alike.
  static const notComparable =
      'ISO or gain not recorded: each such block is shown on its own, never '
      'combined with another.';
}

/// The per-group gain table (plan.css `.gain-table`): 12 px, Group /
/// Frames / Gain vs one frame, rules below each row, 8 8 8 0 cells.
class _GainTable extends StatelessWidget {
  const _GainTable({required this.groups});

  final List<LightGroup> groups;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final head = AppTypography.dense.copyWith(color: p.textSecondary);
    final cell = AppTypography.dense.copyWith(
      color: p.textPrimary,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    TableRow row(List<String> texts, TextStyle style) => TableRow(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: p.border)),
      ),
      children: [
        for (final t in texts)
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
            child: Text(t, style: style),
          ),
      ],
    );
    return Table(
      key: const Key('capturePlan.gainTable'),
      columnWidths: const {
        0: FlexColumnWidth(),
        1: IntrinsicColumnWidth(),
        2: IntrinsicColumnWidth(),
      },
      children: [
        row(['Group', 'Frames', 'Gain vs one frame'], head),
        for (final (i, g) in groups.indexed)
          row([
            '${i + 1} · ${StackingGainGraph.groupName(g)}'
                '${g.comparable ? '' : ' · kept separate'}',
            '${g.frames}',
            '×${g.relativeStackingGain.toStringAsFixed(2)}',
          ], cell),
      ],
    );
  }
}

/// One estimate cell (plan.js `estimate-grid`): a subtle rule, 10 above the
/// 13 px label, the 20/500 value 2 below it, and a 13 px tertiary note.
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
              style: AppTypography.caption.copyWith(
                color: palette.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: AppTypography.sectionHeading.copyWith(
                fontWeight: FontWeight.w500,
                letterSpacing: 0,
                height: 1.3,
                color: palette.textPrimary,
              ),
            ),
            if (note.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                note,
                style: AppTypography.caption.copyWith(
                  height: 1.45,
                  color: palette.textTertiary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
