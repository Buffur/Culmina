import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_motion.dart';
import '../../core/theme/app_palette.dart';
import '../../domain/models/camera_class.dart';
import '../../domain/models/capture_block.dart';
import '../../core/config/feature_scope.dart';
import '../../domain/services/block_proposal.dart';
import '../../domain/services/calibration_builder.dart';
import '../../domain/services/calibration_match.dart';
import '../../domain/services/capture_budget_calculator.dart';
import '../../domain/services/fit_analyzer.dart';
import '../shared/block_text.dart';
import '../shared/plan_night_phrase.dart';
import '../shared/calibration_text.dart';
import '../shared/capability_text.dart';
import '../shared/capture_settings_text.dart';
import '../shared/delete_patterns.dart';
import '../shared/example_text.dart';
import '../shared/failure_feedback.dart';
import '../viewmodels/capture_analysis_viewmodel.dart';
import '../viewmodels/disclosure_viewmodel.dart';
import '../viewmodels/metadata_import_viewmodel.dart';
import '../viewmodels/session_plan_viewmodel.dart';
import 'capture_plan/blocks_undo.dart';
import 'capture_plan/capture_assumptions_panel.dart';
import 'capture_plan/calibration_preview_dialog.dart';
import 'capture_plan/capture_block_dialog.dart';
import 'capture_plan/capture_budget_summary.dart';
import 'plan_tracking.dart';

/// The capture plan (TASK 5.6; S6.9): the blocks, then the outputs and the
/// assumptions. Since S6.9 the planner's "Capture plan" header is its one
/// heading (UX-09), and each row says what will be captured. Composes
/// smaller widgets; no calculations happen here.
class CapturePlanWidget extends StatelessWidget {
  const CapturePlanWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BlockList(),
            Divider(height: 32),
            CaptureBudgetSummary(),
            SizedBox(height: 8),
            CaptureAssumptionsPanel(),
          ],
        ),
      ),
    );
  }
}

class _BlockList extends StatefulWidget {
  const _BlockList();

  @override
  State<_BlockList> createState() => _BlockListState();
}

class _BlockListState extends State<_BlockList> {
  /// False until the list has been built once: rows built after that are
  /// blocks just added, edited or restored, and are briefly marked.
  bool _built = false;

  /// RD-09 (M + S1): the block goes at once, with Undo; Undo puts the
  /// identical block back at its index (the plan autosaves either way),
  /// without undoing a later edit (S6.V1, TD-082).
  void _delete(int index, CaptureBlock block) => unawaited(
    deleteBlockWithUndo(
      context,
      index: index,
      block: block,
      message: 'Deleted ${BlockText.row(block, null)}',
    ),
  );

  /// Calibration tips (S7.3a, H1): shown until hidden, remembered on the
  /// device.
  bool get _tipsShown => context.read<DisclosureViewModel>().isOpen(
    CalibrationText.tipsKey,
    initiallyOpen: true,
  );

  void _setTipsShown(bool shown) => unawaited(
    context.read<DisclosureViewModel>().setOpen(CalibrationText.tipsKey, shown),
  );

  /// "Match the lights" (or flats; ADR-020 §6): the values the block must
  /// match, copied from the default source, with Undo.
  Future<void> _match(int index, CaptureBlock block) async {
    final plan = context.read<SessionPlanViewModel>();
    final source = CalibrationMatch.defaultSource(block, plan.captureBlocks);
    if (source == null) return;
    // ADR-021 C4: the taken fields record where they came from.
    final matched = CalibrationMatch.matched(
      block,
      source,
      origin: FieldOrigin(
        OriginKind.inherited,
        CaptureSettingsText.fromBlock(BlockText.row(source, null)),
      ),
    );
    await runWithFeedback(
      context,
      'match the block',
      () => editBlocksWithUndo(
        context,
        message: 'Matched: ${BlockText.row(matched, null)}',
        change: () => plan.updateCaptureBlock(index, matched),
      ),
    );
  }

  /// The rig's camera class, which decides a light block's fields (S7.2b).
  CameraClass get _cameraClass =>
      context.read<SessionPlanViewModel>().selectedEquipment?.cameraClass ??
      CameraClass.unknown;

  /// F08: "Take from a photo" in the block editor, where files can be read.
  Future<BlockProposal?> Function(int binning)? get _fromPhoto {
    final files = context.read<MetadataImportViewModel?>();
    if (files == null || !FeatureScope.metadataImport) return null;
    final rig = context.read<SessionPlanViewModel>().selectedEquipment;
    return (binning) => files.pickBlockFile(
      cameraClass: _cameraClass,
      rig: rig,
      binning: binning,
    );
  }

  /// "Build calibration frames" (CAL-1, F09): the preview of what the
  /// lights need; confirmed blocks are added at once, with Undo.
  Future<void> _buildCalibration() async {
    final plan = context.read<SessionPlanViewModel>();
    final proposal = CalibrationBuilder.propose(
      plan.captureBlocks,
      plan.selectedEquipment,
    );
    final added = await showCalibrationPreview(context, proposal);
    if (added == null || added.isEmpty || !mounted) return;
    await runWithFeedback(
      context,
      'add the calibration blocks',
      () => editBlocksWithUndo(
        context,
        message: added.length == 1
            ? 'Added 1 calibration block'
            : 'Added ${added.length} calibration blocks',
        change: () => plan.addCaptureBlocks(added),
      ),
    );
  }

  /// A new block from the dialog, starting from the plan's last light block
  /// as a proposal (S7.2b, ADR-020 §5).
  Future<void> _add({bool pickPhoto = false}) async {
    final block = await showCaptureBlockDialog(
      context,
      pickOnOpen: pickPhoto,
      cameraClass: _cameraClass,
      proposal: context.read<SessionPlanViewModel>().lightProposal,
      blocks: context.read<SessionPlanViewModel>().captureBlocks,
      tipsShown: _tipsShown,
      onTipsShown: _setTipsShown,
      fromPhoto: _fromPhoto,
    );
    if (block == null || !mounted) return;
    final plan = context.read<SessionPlanViewModel>();
    // F06 A7 (AM-02): the working plan changes (the new row is marked);
    // the plan's own Save stays separate.
    await runWithFeedback(
      context,
      'add the block',
      () => plan.addCaptureBlock(block),
    );
  }

  /// TD-079 (S6.16): an edit saved in the dialog applies at once and says
  /// so, with Undo back to the block as it was.
  Future<void> _edit(int index, CaptureBlock block) async {
    final edited = await showCaptureBlockDialog(
      context,
      initial: block,
      cameraClass: _cameraClass,
      blocks: context.read<SessionPlanViewModel>().captureBlocks,
      tipsShown: _tipsShown,
      onTipsShown: _setTipsShown,
      fromPhoto: _fromPhoto,
    );
    if (edited == null || !mounted) return;
    final plan = context.read<SessionPlanViewModel>();
    await runWithFeedback(
      context,
      'change the block',
      () => editBlocksWithUndo(
        context,
        message: 'Changed in this plan: ${BlockText.row(edited, null)}',
        change: () => plan.updateCaptureBlock(index, edited),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = AppPalette.of(context);
    final viewModel = context.watch<SessionPlanViewModel>();
    final analysis = context.watch<CaptureAnalysisViewModel>();
    final blocks = viewModel.captureBlocks;
    final budgets = analysis.captureBudget.blocks;
    final capability = analysis.rigCapability;
    // S6.10: what fits, only where the fit measured the plan.
    final fit = analysis.fitAnalysis;
    final measured =
        fit.state == FitState.fits ||
        fit.state == FitState.tight ||
        fit.state == FitState.doesNotFit;
    // F12 (TD-074): each light block's answer holds with the others as
    // planned; say so when other blocks share the window.
    final shared =
        budgets.where((b) => b.placement == BudgetPlacement.window).length > 1;
    // S7.3a (ADR-020 §6): warnings in words; they never block the plan.
    final mismatches = analysis.calibrationMismatches;
    final flatsMissing = analysis.lightsWithoutFlats;
    final fresh = _built;
    _built = true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // TASK 15.3: the badge wraps rather than push the add button off
            // a narrow screen.
            Expanded(
              child: Wrap(
                children: [
                  if (viewModel.isExampleCapturePlan)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        ExampleText.plan,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Add capture block',
              icon: const Icon(Icons.add_circle),
              color: scheme.primary,
              onPressed: _add,
            ),
          ],
        ),
        // RD-04 (S6.8): a plan starts empty. F09 A6 (UXA-C5): the next step
        // in words, with labelled actions; the example shortcut is gone
        // (it stays a test fixture).
        if (blocks.isEmpty)
          Padding(
            key: const Key('capturePlan.empty'),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'No blocks yet. Start with your light frames; the '
                  'calibration frames can be built from them afterwards.',
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    FilledButton.tonalIcon(
                      key: const Key('capturePlan.addLights'),
                      onPressed: _add,
                      icon: const Icon(Icons.add),
                      label: const Text('Add light frames'),
                    ),
                    // F10: FITS is read, so every class has a file to take.
                    if (_fromPhoto != null)
                      OutlinedButton.icon(
                        key: const Key('capturePlan.addFromPhoto'),
                        onPressed: () => _add(pickPhoto: true),
                        icon: const Icon(Icons.add_photo_alternate_outlined),
                        label: const Text('Take from a photo'),
                      ),
                  ],
                ),
              ],
            ),
          )
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: blocks.length,
            onReorderItem: (oldIndex, newIndex) {
              viewModel.reorderCaptureBlocks(oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final block = blocks[index];
              final budget = index < budgets.length ? budgets[index] : null;
              final placement = BlockText.placement(block, budget);
              final fitsText = measured
                  ? BlockText.whatFits(
                      block,
                      unplaced: fit.unplacedFramesByBlock[index] ?? 0,
                      upTo: analysis.framesThatFit(index),
                      spare: analysis.spareFrames(index),
                      others: shared,
                    )
                  : null;
              // F18 A6: the plan's night in the words, never its values.
              final fits = fitsText == null
                  ? null
                  : PlanNightPhrase.apply(
                      fitsText,
                      viewModel.eveningDate ?? viewModel.tonightKey,
                      viewModel.tonightKey,
                    );
              final unplaced = (fit.unplacedFramesByBlock[index] ?? 0) > 0;
              final mismatch = index < mismatches.length
                  ? mismatches[index]
                  : const <CalibrationMismatch>[];
              // TASK 8.6: guidance only — never blocks the plan.
              final exceeds =
                  block.frameType == FrameType.light &&
                  capability != null &&
                  capability.exceedsRecommendation(block.exposureTimeSeconds);
              return _ChangeMark(
                // TD-010/TD-012: ObjectKey tracks this block instance
                // regardless of position, and stays stable across a drag.
                key: ObjectKey(block),
                fresh: fresh,
                builder: (tint) => ListTile(
                  tileColor: tint,
                  contentPadding: EdgeInsets.zero,
                  onTap: () => _edit(index, block),
                  title: Text(BlockText.row(block, budget)),
                  subtitle:
                      placement == null &&
                          !exceeds &&
                          fits == null &&
                          mismatch.isEmpty
                      ? null
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (placement != null) Text(placement),
                            if (fits != null)
                              Text(
                                fits,
                                key: Key('capture.whatFits.$index'),
                                style: TextStyle(
                                  color: unplaced
                                      ? palette.statusDoesNotFit
                                      : palette.textSecondary,
                                ),
                              ),
                            // S6.9 (UX-15 (1); RD-08): a known tracking's
                            // exceedance is a warning, in words and the
                            // status colour; unknown tracking is a missing
                            // input, neutral, with the way to set it.
                            if (exceeds &&
                                !capability.recommendationIsConditional)
                              Text(
                                CapabilityText.subWarningFor(
                                  capability,
                                  viewModel.effectiveTracking,
                                ),
                                key: const Key('capture.subWarning'),
                                style: TextStyle(
                                  color: palette.statusDoesNotFit,
                                ),
                              ),
                            if (exceeds &&
                                capability.recommendationIsConditional) ...[
                              Text(
                                CapabilityText.unknownTracking(capability),
                                key: const Key('capture.trackingUnknown'),
                                style: TextStyle(color: palette.statusNeutral),
                              ),
                              // S7.1: the plan's own tracking (RD-08 = T3).
                              TextButton(
                                key: const Key('capture.setTracking'),
                                onPressed: () => pickPlanTracking(context),
                                child: const Text(
                                  'Set the tracking for this plan',
                                ),
                              ),
                            ],
                            for (final m in mismatch)
                              Text(
                                CalibrationText.mismatch(m, block.frameType),
                                key: Key('capture.mismatch.$index.${m.name}'),
                                style: TextStyle(color: palette.statusTight),
                              ),
                            if (mismatch.any((m) => m.fixable) &&
                                CalibrationMatch.defaultSource(block, blocks) !=
                                    null)
                              TextButton(
                                key: Key('capture.match.$index'),
                                onPressed: () => _match(index, block),
                                child: Text(
                                  CalibrationText.match(block.frameType),
                                ),
                              ),
                          ],
                        ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DeleteButton(
                        tooltip: 'Delete block',
                        onPressed: () => _delete(index, block),
                      ),
                      Icon(Icons.drag_indicator, color: palette.textTertiary),
                    ],
                  ),
                ),
              );
            },
          ),
        if (flatsMissing.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              CalibrationText.flatsMissing(
                flatsMissing,
                withBinning: _cameraClass.offersLightBinning,
              ),
              key: const Key('capture.flatsMissing'),
              style: TextStyle(color: palette.statusTight),
            ),
          ),
        // CAL-1 (F09 A2): the labelled entry, also the missing-flat
        // warning's shortcut.
        if (blocks.any((b) => b.isLight))
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              key: const Key('capturePlan.buildCalibration'),
              onPressed: _buildCalibration,
              icon: const Icon(Icons.auto_awesome_motion_outlined),
              label: Text(
                flatsMissing.isEmpty
                    ? 'Build calibration frames'
                    : 'Build calibration frames, with the missing flats',
              ),
            ),
          ),
      ],
    );
  }
}

/// Briefly marks a row an edit just changed (S6.9; P6.9's notes): a tint
/// on the tile that fades over [AppMotion.highlight]; none with reduced
/// motion.
class _ChangeMark extends StatelessWidget {
  const _ChangeMark({super.key, required this.fresh, required this.builder});

  final bool fresh;
  final Widget Function(Color tint) builder;

  @override
  Widget build(BuildContext context) {
    final tint = Theme.of(context).colorScheme.primaryContainer;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: fresh ? 1 : 0, end: 0),
      duration: AppMotion.duration(context, AppMotion.highlight),
      curve: AppMotion.curve,
      builder: (context, v, _) => builder(tint.withValues(alpha: 0.6 * v)),
    );
  }
}
