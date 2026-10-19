import 'package:flutter/material.dart';

import '../../../core/utils/quantity_text.dart';
import '../../../domain/models/capture_block.dart';
import '../../../domain/services/calibration_builder.dart';
import '../../../domain/services/exposure_input.dart';
import '../../shared/block_text.dart';
import '../../shared/calibration_text.dart';

/// "Build calibration frames" (CAL-1, PD-12; F09 A2–A4): a preview of what
/// the plan's lights need and no block proves covered. Counts are editable
/// proposals; a flat's or bias's exposure is entered here, never taken from
/// a light; a row can be left out. Returns the blocks to add, or null on
/// Cancel (nothing changes). Binning is named only where the rig's class
/// offers it on a block ([withBinning]; ADR-020 §3, AM-04).
Future<List<CaptureBlock>?> showCalibrationPreview(
  BuildContext context,
  CalibrationProposal proposal, {
  bool withBinning = true,
}) => showDialog<List<CaptureBlock>>(
  context: context,
  builder: (_) => _CalibrationPreview(proposal, withBinning: withBinning),
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

  List<ProposedCalibration> get _rows => widget.proposal.blocks;

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
  }

  @override
  void dispose() {
    for (final c in [..._counts, ..._exposures]) {
      c?.dispose();
    }
    super.dispose();
  }

  /// What the row takes, in words.
  String _describe(ProposedCalibration p) {
    final source = BlockText.row(p.source, null);
    final gain = CalibrationText.sensitivity(p.gain);
    final bin = widget.withBinning ? ' · ${p.binning} × ${p.binning}' : '';
    return switch (p.type) {
      FrameType.dark =>
        'Dark · ${QuantityText.exposure(p.exposureSeconds!)} · $gain$bin, '
            'for $source',
      FrameType.flat =>
        'Flat (${p.filterName ?? 'no filter'})$bin, for $source; its '
            'exposure is set for its light source',
      FrameType.bias => 'Bias · $gain$bin, the shortest exposure',
      FrameType.darkFlat =>
        p.flatIndex == null
            ? 'Dark flat · ${QuantityText.exposure(p.exposureSeconds!)} · '
                  '$gain, for the flat'
            : 'Dark flat · the exposure of the flat above · $gain',
      FrameType.light => '',
    };
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
    Navigator.pop(context, blocks);
  }

  /// A dark flat for a flat that was left out is left out with it.
  bool _leftOutByFlat(int i) {
    final f = _rows[i].flatIndex;
    return f != null && !_kept[f];
  }

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.bodySmall;
    final kept = [
      for (var i = 0; i < _rows.length; i++)
        if (_kept[i] && !_leftOutByFlat(i)) i,
    ].length;
    return AlertDialog(
      title: const Text('Build calibration frames'),
      content: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _rows.isEmpty
                    ? 'Every light block already has the calibration it '
                          'needs in this plan.'
                    : 'From your light blocks. The counts are proposals: '
                          'change them as you need. Nothing is added until '
                          'you confirm.',
                style: muted,
              ),
              if (widget.proposal.darksByCamera)
                Padding(
                  key: const Key('calibration.noDarks'),
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    "No darks: the camera's long-exposure noise reduction "
                    'takes one after each light.',
                    style: muted,
                  ),
                ),
              for (var i = 0; i < _rows.length; i++)
                if (!_leftOutByFlat(i))
                  Padding(
                    key: Key('calibration.row.$i'),
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                _describe(_rows[i]),
                                style: _kept[i]
                                    ? null
                                    : muted?.copyWith(
                                        decoration: TextDecoration.lineThrough,
                                      ),
                              ),
                            ),
                            TextButton(
                              key: Key('calibration.toggle.$i'),
                              onPressed: () =>
                                  setState(() => _kept[i] = !_kept[i]),
                              child: Text(_kept[i] ? 'Leave out' : 'Include'),
                            ),
                          ],
                        ),
                        if (_kept[i]) ...[
                          TextFormField(
                            key: Key('calibration.count.$i'),
                            controller: _counts[i],
                            decoration: const InputDecoration(
                              labelText: 'Frame count',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              final n = int.tryParse((v ?? '').trim());
                              if (n == null || n < 1) {
                                return 'Enter a whole number of at least 1';
                              }
                              if (n > CaptureBlock.maxFrameCount) {
                                return 'At most ${CaptureBlock.maxFrameCount}';
                              }
                              return null;
                            },
                          ),
                          if (_exposures[i] case final c?)
                            TextFormField(
                              key: Key('calibration.exposure.$i'),
                              controller: c,
                              decoration: InputDecoration(
                                labelText: 'Exposure (seconds)',
                                hintText: _rows[i].type == FrameType.bias
                                    ? 'The shortest your camera allows'
                                    : 'e.g. 2 or 1/50',
                              ),
                              keyboardType: TextInputType.text,
                              autocorrect: false,
                              validator: (v) => ExposureInput.problem(v ?? ''),
                            ),
                        ],
                      ],
                    ),
                  ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          key: const Key('calibration.cancel'),
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('calibration.confirm'),
          onPressed: kept == 0 ? null : _confirm,
          child: Text(kept == 1 ? 'Add 1 block' : 'Add $kept blocks'),
        ),
      ],
    );
  }
}
