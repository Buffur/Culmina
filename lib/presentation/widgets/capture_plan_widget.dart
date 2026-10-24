import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_motion.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/quantity_text.dart';
import '../shared/hybrid_icon.dart';
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
import '../shared/failure_feedback.dart';
import '../viewmodels/capture_analysis_viewmodel.dart';
import '../viewmodels/disclosure_viewmodel.dart';
import '../viewmodels/metadata_import_viewmodel.dart';
import '../viewmodels/session_plan_viewmodel.dart';
import 'capture_plan/blocks_undo.dart';
import 'capture_plan/calibration_preview_dialog.dart';
import 'capture_plan/capture_block_dialog.dart';
import 'capture_plan/capture_budget_summary.dart';
import 'plan_tracking.dart';

/// The capture plan (TASK 5.6; S6.9): the blocks, then the outputs and the
/// assumptions. Since S6.9 the planner's "Capture plan" header is its one
/// heading (UX-09), and each row says what will be captured. Composes
/// smaller widgets; no calculations happen here.
class CapturePlanWidget extends StatelessWidget {
  const CapturePlanWidget({
    super.key,
    this.blockActions,
    this.includeSummary = true,
  });
  final Widget? blockActions;
  final bool includeSummary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _BlockList(),
          ?blockActions,
          if (includeSummary) ...[
            const SizedBox(height: 28),
            const CaptureBudgetSummary(),
          ],
        ],
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
      // plan.js removeBlock: "Block removed." (Undo beside it).
      message: 'Block removed.',
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
    final added = await showCalibrationPreview(
      context,
      proposal,
      withBinning: _cameraClass.offersLightBinning,
    );
    if (added == null || added.isEmpty || !mounted) return;
    await runWithFeedback(
      context,
      'add the calibration blocks',
      () => editBlocksWithUndo(
        context,
        // plan.js applyCalibration: the undo row's words.
        message: 'Calibration frames added.',
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
      rigName: context.read<SessionPlanViewModel>().selectedEquipment?.name,
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
      rigName: context.read<SessionPlanViewModel>().selectedEquipment?.name,
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
        // plan.js applyBlock: "Block edited.", with Undo.
        message: 'Block edited.',
        change: () => plan.updateCaptureBlock(index, edited),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
    final cameraClass = viewModel.selectedEquipment?.cameraClass;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // RD-04 (S6.8): a plan starts empty. F09 A6 (UXA-C5): the next step
        // in words, with labelled actions (plan.js `empty-blocks`).
        if (blocks.isEmpty)
          Padding(
            key: const Key('capturePlan.empty'),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No frames planned yet. You can still save this plan and '
                  'add frames later; the calibration frames can be built '
                  'from your lights afterwards.',
                  style: AppTypography.body.copyWith(
                    height: 1.6,
                    color: palette.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton(
                      key: const Key('capturePlan.addLights'),
                      onPressed: _add,
                      child: const Text('Add light frames'),
                    ),
                    // F10: FITS is read, so every class has a file to take.
                    if (_fromPhoto != null)
                      OutlinedButton(
                        key: const Key('capturePlan.addFromPhoto'),
                        onPressed: () => _add(pickPhoto: true),
                        child: const Text('Take from a photo'),
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
            buildDefaultDragHandles: false,
            itemCount: blocks.length,
            onReorderItem: (oldIndex, newIndex) {
              viewModel.reorderCaptureBlocks(oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final block = blocks[index];
              final budget = index < budgets.length ? budgets[index] : null;
              final placement = BlockText.placement(block, budget);
              final unplaced = fit.unplacedFramesByBlock[index] ?? 0;
              final upTo = measured ? analysis.framesThatFit(index) : null;
              // plan.js `fitLine`: what this block's frames leave room for,
              // from the fit's own outputs; calibration outside the window
              // says so instead.
              final fits = placement == 'Outside the imaging window'
                  ? 'Outside the imaging window · adds to total time'
                  : !measured
                  ? (block.frameType != FrameType.light
                        ? null
                        : switch (fit.state) {
                            FitState.needsInput =>
                              'Window capacity unknown until site and '
                                  'target are set',
                            FitState.noWindow => PlanNightPhrase.apply(
                              'No imaging window tonight',
                              viewModel.eveningDate ?? viewModel.tonightKey,
                              viewModel.tonightKey,
                            ),
                            _ => 'Window capacity unknown for this plan',
                          })
                  : block.frameType != FrameType.light
                  ? placement
                  : PlanNightPhrase.apply(
                      BlockText.whatFits(
                        block,
                        unplaced: unplaced,
                        upTo: upTo,
                        others: shared,
                      ),
                      viewModel.eveningDate ?? viewModel.tonightKey,
                      viewModel.tonightKey,
                    );
              final mismatch = index < mismatches.length
                  ? mismatches[index]
                  : const <CalibrationMismatch>[];
              // TASK 8.6: guidance only — never blocks the plan.
              final exceeds =
                  block.frameType == FrameType.light &&
                  capability != null &&
                  capability.exceedsRecommendation(block.exposureTimeSeconds);
              final source = _source(block);
              TextStyle small(Color c) =>
                  AppTypography.caption.copyWith(height: 1.55, color: c);
              return _ChangeMark(
                // TD-010/TD-012: ObjectKey tracks this block instance
                // regardless of position, and stays stable across a drag.
                // The same instance added twice gets its own key per
                // occurrence (a reused key would break the list).
                key: switch ([
                  for (var j = 0; j < index; j++)
                    if (identical(blocks[j], block)) j,
                ].length) {
                  0 => ObjectKey(block),
                  final n => ValueKey((identityHashCode(block), n)),
                },
                fresh: fresh,
                // plan.js `.capture-block`: a subtle rule above, 14 above
                // and 10 below the content.
                builder: (tint) => ColoredBox(
                  color: tint,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: palette.border)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 14, bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Semantics(
                            header: true,
                            child: Text(
                              BlockText.title(block),
                              key: Key('capture.title.$index'),
                              style: AppTypography.itemTitle.copyWith(
                                color: palette.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            BlockText.math(block),
                            style: AppTypography.value.copyWith(
                              fontWeight: FontWeight.w500,
                              height: 1.55,
                              color: palette.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _records(block, cameraClass),
                            key: Key('capture.records.$index'),
                            style: small(palette.textSecondary),
                          ),
                          if (source != null) ...[
                            const SizedBox(height: 2),
                            Text(source, style: small(palette.textTertiary)),
                          ],
                          if (fits != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              fits,
                              key: Key('capture.whatFits.$index'),
                              style: small(
                                unplaced > 0
                                    ? palette.statusDoesNotFit
                                    : palette.textTertiary,
                              ),
                            ),
                          ],
                          // S6.9 (UX-15 (1); RD-08): a known tracking's
                          // exceedance is a warning, in words and the
                          // status colour; unknown tracking is a missing
                          // input, neutral, with the way to set it.
                          if (exceeds &&
                              !capability.recommendationIsConditional) ...[
                            const SizedBox(height: 2),
                            Text(
                              CapabilityText.subWarningFor(
                                capability,
                                viewModel.effectiveTracking,
                              ),
                              key: const Key('capture.subWarning'),
                              style: small(palette.statusDoesNotFit),
                            ),
                          ],
                          if (exceeds &&
                              capability.recommendationIsConditional) ...[
                            const SizedBox(height: 2),
                            Text(
                              CapabilityText.unknownTracking(capability),
                              key: const Key('capture.trackingUnknown'),
                              style: small(palette.statusNeutral),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton(
                                key: const Key('capture.setTracking'),
                                onPressed: () => pickPlanTracking(context),
                                child: const Text(
                                  'Set the tracking for this plan',
                                ),
                              ),
                            ),
                          ],
                          for (final m in mismatch) ...[
                            const SizedBox(height: 2),
                            Text(
                              CalibrationText.mismatch(m, block.frameType),
                              key: Key('capture.mismatch.$index.${m.name}'),
                              style: small(palette.statusTight),
                            ),
                          ],
                          if (mismatch.any((m) => m.fixable) &&
                              CalibrationMatch.defaultSource(block, blocks) !=
                                  null)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton(
                                key: Key('capture.match.$index'),
                                onPressed: () => _match(index, block),
                                child: Text(
                                  CalibrationText.match(block.frameType),
                                ),
                              ),
                            ),
                          const SizedBox(height: 8),
                          // plan.js `.block-actions`: Edit (120), then the
                          // moves and Remove pushed to the end, 8 apart; on
                          // a narrow line (large text) the group wraps below.
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            runSpacing: 8,
                            children: [
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  minWidth: 120,
                                ),
                                child: OutlinedButton(
                                  key: Key('capture.edit.$index'),
                                  onPressed: () => _edit(index, block),
                                  child: Semantics(
                                    label:
                                        'Edit block ${index + 1}, ${BlockText.type(block.frameType)}',
                                    excludeSemantics: true,
                                    child: const Text('Edit'),
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _MoveButton(
                                    key: Key('capture.moveUp.$index'),
                                    icon: HybridIcons.up,
                                    tooltip: 'Move block ${index + 1} up',
                                    onPressed: index == 0
                                        ? null
                                        : () => viewModel.reorderCaptureBlocks(
                                            index,
                                            index - 1,
                                          ),
                                  ),
                                  const SizedBox(width: 8),
                                  _MoveButton(
                                    key: Key('capture.moveDown.$index'),
                                    icon: HybridIcons.downArrow,
                                    tooltip: 'Move block ${index + 1} down',
                                    onPressed: index == blocks.length - 1
                                        ? null
                                        : () => viewModel.reorderCaptureBlocks(
                                            index,
                                            index + 1,
                                          ),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton(
                                    key: Key('capture.delete.$index'),
                                    onPressed: () => _delete(index, block),
                                    style: TextButton.styleFrom(
                                      foregroundColor: palette.textSecondary,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      minimumSize: const Size(48, 48),
                                    ),
                                    child: Semantics(
                                      label:
                                          'Remove block ${index + 1}, ${BlockText.type(block.frameType)}',
                                      excludeSemantics: true,
                                      child: const Text('Remove'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        // Keep paired actions equal-width. At large text they stack so
        // calibration words can wrap at spaces within the document group.
        if (blocks.isNotEmpty)
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: palette.border)),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final actions = <Widget>[
                    OutlinedButton(
                      key: const Key('capturePlan.addBlock'),
                      onPressed: _add,
                      child: const Text(
                        'Add block',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (blocks.any((b) => b.isLight))
                      OutlinedButton(
                        key: const Key('capturePlan.buildCalibration'),
                        onPressed: _buildCalibration,
                        child: Text(
                          flatsMissing.isEmpty ? 'Build calibration frames' : 'Build calibration frames, with the missing flats',
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ];
                  if (MediaQuery.textScalerOf(context).scale(1) >= 1.5 ||
                      constraints.maxWidth < 280) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        actions.first,
                        if (actions.length > 1) ...[
                          const SizedBox(height: 8),
                          actions.last,
                        ],
                      ],
                    );
                  }
                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: actions.first),
                        if (actions.length > 1) ...[
                          const SizedBox(width: 8),
                          Expanded(child: actions.last),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        if (flatsMissing.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              CalibrationText.flatsMissing(
                flatsMissing,
                withBinning: _cameraClass.offersLightBinning,
              ),
              key: const Key('capture.flatsMissing'),
              style: AppTypography.caption.copyWith(
                height: 1.55,
                color: palette.statusTight,
              ),
            ),
          ),
      ],
    );
  }
}

/// A block move (plan.js `.block-actions .android-icon-button`): a 48 px
/// round target with a 20 px arrow at stroke 1.8; disabled at .3 opacity.
class _MoveButton extends StatelessWidget {
  const _MoveButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final HybridIconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Opacity(
        opacity: onPressed == null ? 0.3 : 1,
        child: HybridIcon(
          icon,
          size: MediaQuery.textScalerOf(context).scale(20),
          strokeWidth: 1.8,
          color: p.textPrimary,
        ),
      ),
    );
  }
}

/// plan.js `sourceLine`: where the block's exposure came from, when the
/// block records it (ADR-021 C4).
String? _source(CaptureBlock block) =>
    switch (block.origins[CaptureField.exposure]) {
      null => null,
      final o when o.kind == OriginKind.entered => 'Exposure entered by you',
      final o => 'Exposure: ${CaptureSettingsText.origin(o)}',
    };

/// plan.js `recordsLine`: the rig's sensitivity (ISO for phones and
/// cameras, gain and binning for astro cameras), then white balance and
/// focus for lights; a recorded value of another type is kept and named.
String _records(CaptureBlock block, CameraClass? cameraClass) {
  final gain = block.gain;
  final light = block.frameType == FrameType.light;
  final kept = block.whiteBalance != null || block.focusMode != null;
  final camera = light || kept
      ? ' · WB ${block.whiteBalance == null ? 'unrecorded' : CaptureSettingsText.whiteBalance(block.whiteBalance!)}'
            ' · Focus ${block.focusMode == null ? 'unrecorded' : CaptureSettingsText.focus(block.focusMode!)}'
      : '';
  // plan.js recordsLine; a value already recorded on the block is never
  // hidden while no rig is chosen (it is kept, and said).
  if (cameraClass == null) {
    final v = gain.value;
    final kept = [
      if (v != null)
        '${switch (gain.kind) {
          GainKind.iso => 'ISO',
          GainKind.gain => 'Gain',
          GainKind.unknown => 'ISO or gain',
        }} ${QuantityText.number(v)}',
      if (block.binning != 1) 'Binning ${block.binning}×${block.binning}',
    ];
    return [
      'Choose a rig to record ISO or gain',
      if (kept.isNotEmpty) '${kept.join(' · ')} kept',
    ].join(' · ');
  }
  return switch (cameraClass.lightSensitivity) {
    LightSensitivity.iso =>
      'ISO ${gain.kind == GainKind.iso ? gain.value!.toInt() : 'unrecorded'}$camera',
    LightSensitivity.gain =>
      'Gain ${gain.kind == GainKind.gain ? QuantityText.number(gain.value!) : 'unrecorded'}'
          ' · Binning ${block.binning}×${block.binning}'
          '${kept ? '$camera (kept record)' : ''}',
    LightSensitivity.either =>
      gain.value == null
          ? 'Camera type not recorded · no ISO or gain record$camera'
          : 'Camera type not recorded · ISO or gain ${QuantityText.number(gain.value!)} (type unknown)$camera',
  };
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
