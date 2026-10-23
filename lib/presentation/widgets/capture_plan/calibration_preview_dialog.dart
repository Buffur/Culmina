import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/quantity_text.dart';
import '../../../domain/models/capture_block.dart';
import '../../../domain/services/calibration_builder.dart';
import '../../../domain/services/exposure_input.dart';
import '../../shared/block_text.dart';
import '../../shared/calibration_text.dart';
import '../../shared/confirmation_patterns.dart';
import '../../shared/hybrid_app_bar.dart';
import '../../shared/hybrid_icon.dart';
import '../../shared/hybrid_parts.dart';
import 'block_editor_parts.dart';

/// "Build calibration frames" (CAL-1, PD-12; F09 A2–A4): a preview of what
/// the plan's lights need and no block proves covered. Counts are editable
/// proposals; a flat's or bias's exposure is entered here, never taken from
/// a light; a row can be left out. Returns the blocks to add, or null on
/// Close (nothing changes). Binning is named only where the rig's class
/// offers it on a block ([withBinning]; ADR-020 §3, AM-04).
///
/// Hybrid (plan.js `calibrationView`): a scoped page, one fieldset per
/// proposed block with its "Add … frames" check, "Proposed frames" and the
/// proposal's source, and "Add selected frames" in the apply bar. The
/// native builder keeps its own rows (a dark per light exposure, a flat per
/// filter, dark flats) instead of the reference's three fixed types.
Future<List<CaptureBlock>?> showCalibrationPreview(
  BuildContext context,
  CalibrationProposal proposal, {
  bool withBinning = true,
}) => Navigator.of(context).push<List<CaptureBlock>>(
  MaterialPageRoute(
    builder: (_) => _CalibrationPreview(proposal, withBinning: withBinning),
  ),
);

class _CalibrationPreview extends StatefulWidget {
  const _CalibrationPreview(this.proposal, {required this.withBinning});

  final CalibrationProposal proposal;
  final bool withBinning;

  @override
  State<_CalibrationPreview> createState() => _CalibrationPreviewState();
}

class _CalibrationPreviewState extends State<_CalibrationPreview> {
  final _form = GlobalKey<FormState>();
  late final List<TextEditingController> _counts;
  late final List<TextEditingController?> _exposures;
  late final List<bool> _kept;
  bool _changed = false;
  bool _leaving = false;

  List<ProposedCalibration> get _rows => widget.proposal.blocks;

  /// The light blocks the proposal references, once each.
  List<CaptureBlock> get _lights {
    final seen = Set<CaptureBlock>.identity();
    return [
      for (final p in _rows)
        if (p.source.frameType == FrameType.light && seen.add(p.source))
          p.source,
    ];
  }

  @override
  void initState() {
    super.initState();
    _counts = [
      for (final p in _rows) TextEditingController(text: '${p.count}'),
    ];
    _exposures = [
      for (final p in _rows)
        p.exposureSeconds == null && p.flatIndex == null
            ? TextEditingController()
            : null,
    ];
    _kept = [for (final _ in _rows) true];
    for (final c in [..._counts, ..._exposures]) {
      c?.addListener(_markChanged);
    }
  }

  void _markChanged() => _changed = true;

  @override
  void dispose() {
    for (final c in [..._counts, ..._exposures]) {
      c?.dispose();
    }
    super.dispose();
  }

  /// The fieldset's legend (`${t} frames`).
  static String _legend(FrameType type) => switch (type) {
    FrameType.dark => 'Dark frames',
    FrameType.flat => 'Flat frames',
    FrameType.bias => 'Bias frames',
    FrameType.darkFlat => 'Dark flat frames',
    FrameType.light => 'Light frames',
  };

  /// What the row's exposure is and what it is for (`.field-source`).
  String _source(ProposedCalibration p) {
    final source = BlockText.row(p.source, null);
    return switch (p.type) {
      FrameType.dark =>
        'Exposure ${QuantityText.exposure(p.exposureSeconds!)}, matching '
            '$source.',
      FrameType.flat =>
        'Flat (${p.filterName ?? 'no filter'}) for $source. Set its '
            'exposure for your light source.',
      FrameType.bias => 'Use the shortest exposure your camera allows.',
      FrameType.darkFlat =>
        p.flatIndex == null
            ? 'Exposure ${QuantityText.exposure(p.exposureSeconds!)}, '
                  'matching the flat.'
            : 'The exposure of the flat above.',
      FrameType.light => '',
    };
  }

  /// Its sensitivity and binning, outside the window (`.field-source`).
  String _settings(ProposedCalibration p) {
    final gain = CalibrationText.sensitivity(p.gain);
    final bin = widget.withBinning ? ' · ${p.binning} × ${p.binning}' : '';
    return '$gain$bin · outside the imaging window';
  }

  void _confirm() {
    if (!(_form.currentState?.validate() ?? false)) return;
    final keptIndexes = [
      for (var i = 0; i < _rows.length; i++)
        if (_kept[i] && !_leftOutByFlat(i)) i,
    ];
    final proposal = CalibrationProposal([
      for (final i in keptIndexes) _rows[i],
    ], darksByCamera: widget.proposal.darksByCamera);
    // Dark flats point at their flat by index: re-point into the kept list.
    final exposures = <double?>[
      for (final i in keptIndexes)
        switch (_exposures[i]) {
          final c? => ExposureInput.parse(c.text),
          null when _rows[i].flatIndex != null => ExposureInput.parse(
            _exposures[_rows[i].flatIndex!]!.text,
          ),
          null => null,
        },
    ];
    final blocks = CalibrationBuilder.confirm(
      proposal,
      counts: [for (final i in keptIndexes) int.parse(_counts[i].text.trim())],
      exposures: exposures,
      descriptor: (source) => 'from ${BlockText.row(source, null)}',
    );
    _leaving = true;
    Navigator.pop(context, blocks);
  }

  /// Close or Back (plan.js `requestCloseScreen`): an unchanged builder
  /// closes; a changed one asks "Discard this edit?" first.
  Future<void> _leave() async {
    if (_changed && !await askDiscardEdit(context)) return;
    if (!mounted) return;
    _leaving = true;
    Navigator.pop(context);
  }

  /// A dark flat for a flat that was left out is left out with it.
  bool _leftOutByFlat(int i) {
    final f = _rows[i].flatIndex;
    return f != null && !_kept[f];
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final secondary = AppTypography.caption.copyWith(
      height: 1.5,
      color: p.textSecondary,
    );
    final kept = [
      for (var i = 0; i < _rows.length; i++)
        if (_kept[i] && !_leftOutByFlat(i)) i,
    ].length;
    return PopScope(
      canPop: _leaving,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leave();
      },
      child: Scaffold(
        appBar: hybridAppBar(
          context,
          leading: IconButton(
            key: const Key('calibration.cancel'),
            tooltip: 'Close',
            onPressed: _leave,
            icon: HybridIcon(
              HybridIcons.close,
              size: MediaQuery.textScalerOf(context).scale(24),
              strokeWidth: 1.8,
            ),
          ),
          title: const Text('Calibration frames'),
        ),
        body: HybridPlanInputs(
          child: Form(
            key: _form,
            child: SingleChildScrollView(
              key: const Key('calibration.scroll'),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                AppSpacing.itemGap,
                AppSpacing.gutter,
                AppSpacing.gutter,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // plan.css `.screen-intro`: 14 at 1.6, secondary.
                  Text(
                    _rows.isEmpty
                        ? 'Every light block already has the calibration it '
                              'needs in this plan.'
                        : 'Add proposed frames to this plan. Review counts '
                              'before applying.',
                    style: AppTypography.body.copyWith(
                      height: 1.6,
                      color: p.textSecondary,
                    ),
                  ),
                  // plan.css `.reference-light`: 13 at 1.6, primary. The
                  // native builder references every light at once.
                  if (_lights case final lights when lights.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.gutter),
                      child: Text(
                        lights.length == 1
                            ? 'References ${BlockText.row(lights.single, null)}'
                            : 'References ${lights.length} light blocks; each '
                                  'set names its light.',
                        key: const Key('calibration.reference'),
                        style: AppTypography.caption.copyWith(
                          height: 1.6,
                          color: p.textPrimary,
                        ),
                      ),
                    ),
                  if (widget.proposal.darksByCamera)
                    Padding(
                      key: const Key('calibration.noDarks'),
                      padding: const EdgeInsets.only(top: AppSpacing.gutter),
                      child: Text(
                        "No darks: the camera's long-exposure noise "
                        'reduction takes one after each light.',
                        style: AppTypography.caption.copyWith(
                          height: 1.6,
                          color: p.textPrimary,
                        ),
                      ),
                    ),
                  for (var i = 0; i < _rows.length; i++)
                    if (!_leftOutByFlat(i))
                      Padding(
                        key: Key('calibration.row.$i'),
                        padding: const EdgeInsets.only(top: AppSpacing.gutter),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _Legend(_legend(_rows[i].type)),
                            // The legend's 18 px below its rule.
                            const SizedBox(
                              height: AppSpacing.md + AppSpacing.hair,
                            ),
                            HybridCheckRow.plan(
                              key: Key('calibration.toggle.$i'),
                              label:
                                  'Add ${_legend(_rows[i].type).toLowerCase()}',
                              checked: _kept[i],
                              onChanged: (v) => setState(() {
                                _kept[i] = v;
                                _changed = true;
                              }),
                            ),
                            if (_kept[i]) ...[
                              const SizedBox(height: AppSpacing.sm),
                              BlockField(
                                label: 'Proposed frames',
                                child: TextFormField(
                                  key: Key('calibration.count.$i'),
                                  controller: _counts[i],
                                  keyboardType: TextInputType.number,
                                  validator: (v) {
                                    final n = int.tryParse((v ?? '').trim());
                                    if (n == null || n < 1) {
                                      return 'Enter a whole number of at '
                                          'least 1';
                                    }
                                    if (n > CaptureBlock.maxFrameCount) {
                                      return 'At most '
                                          '${CaptureBlock.maxFrameCount}';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              if (_exposures[i] case final c?) ...[
                                const SizedBox(height: AppSpacing.itemGap),
                                BlockField(
                                  label: 'Exposure (seconds)',
                                  child: TextFormField(
                                    key: Key('calibration.exposure.$i'),
                                    controller: c,
                                    decoration: InputDecoration(
                                      hintText: _rows[i].type == FrameType.bias
                                          ? 'The shortest your camera allows'
                                          : 'e.g. 2 or 1/50',
                                    ),
                                    keyboardType: TextInputType.text,
                                    autocorrect: false,
                                    validator: (v) =>
                                        ExposureInput.problem(v ?? ''),
                                  ),
                                ),
                              ],
                            ],
                            const SizedBox(height: AppSpacing.sm),
                            Text(_source(_rows[i]), style: secondary),
                            const SizedBox(height: AppSpacing.sm),
                            Text(_settings(_rows[i]), style: secondary),
                          ],
                        ),
                      ),
                  const SizedBox(height: AppSpacing.gutter),
                  // plan.css `.editor-help`: 13 at 1.6, secondary.
                  Text(
                    'These add session time and storage, not integration. '
                    'No calibration files are checked or acquired.',
                    style: AppTypography.caption.copyWith(
                      height: 1.6,
                      color: p.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: HybridApplyBar(
          buttonKey: const Key('calibration.confirm'),
          label: 'Add selected frames',
          onPressed: kept == 0 ? null : _confirm,
        ),
      ),
    );
  }
}

/// A fieldset's legend on its top rule (plan.css `.cal-row`): 13 px
/// secondary, the subtle rule running on after it.
class _Legend extends StatelessWidget {
  const _Legend(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Semantics(
      header: true,
      child: Row(
        children: [
          Text(
            text,
            style: AppTypography.caption.copyWith(
              height: 1.5,
              color: p.textSecondary,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(child: Divider(height: 1, thickness: 1, color: p.border)),
        ],
      ),
    );
  }
}
