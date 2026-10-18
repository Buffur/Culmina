import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/quantity_text.dart';
import '../../../domain/models/capture_evidence.dart';
import '../../../domain/models/equipment_limits.dart';
import '../../../domain/services/storage_estimate.dart';
import '../../screens/equipment/equipment_editor.dart';
import '../../shared/app_messages.dart';
import '../../shared/failure_feedback.dart';
import '../../shared/storage_text.dart';
import '../../viewmodels/library_viewmodels.dart';
import '../../viewmodels/metadata_import_viewmodel.dart';
import '../../viewmodels/session_plan_viewmodel.dart';

/// "Choose one file" (ADR-021 C6/C7/C12, F07): one capture file's length
/// becomes the plan's rig's RAW size, with the file recorded, after the
/// user confirms what was read. A recognized file without a reader counts
/// by its length only. Nothing is written on Cancel.
Future<void> chooseStorageFile(BuildContext context) async {
  final files = context.read<MetadataImportViewModel?>();
  final plan = context.read<SessionPlanViewModel>();
  final rig = plan.selectedEquipment;
  if (files == null || rig == null) return;
  ({String? name, FileEvidence? evidence})? pick;
  final picked = await runWithFeedback(
    context,
    'read the file',
    () async => pick = await files.pickStorageFile(),
  );
  final chosen = pick;
  if (!picked || chosen == null || !context.mounted) return;
  final file = chosen.evidence;
  final mb = file == null ? null : file.bytes / 1e6;
  if (file == null || !EquipmentLimits.rawFileSizeMB.contains(mb!)) {
    ScaffoldMessenger.of(context).showMessage(
      SnackBar(
        content: Text(
          file == null
              ? "${chosen.name ?? 'That file'} can't give a frame size: it is "
                    'not a capture file the app recognizes.'
              : "${file.label} can't give a frame size: "
                    '${QuantityText.storage(file.bytes.toDouble())} is outside '
                    'the range a RAW size can have.',
        ),
      ),
    );
    return;
  }
  final lights = plan.captureBlocks.where((b) => b.isLight);
  final misfit = lights.isEmpty
      ? const <StorageConflict>{}
      : StorageEstimate.conflicts(file, lights.first, rig);
  final use = await showDialog<bool>(
    context: context,
    builder: (dialog) => AlertDialog(
      title: const Text('Use this file for the rig?'),
      content: Text(
        [
          '${file.label}: ${QuantityText.storage(file.bytes.toDouble())} a '
              'frame.',
          if (!file.read)
            'Its mode is not read; compressed sizes vary with content.'
          else if ((file.width, file.height) case (final w?, final h?))
            'Read: $w × $h px'
                '${file.bitsPerSample == null ? '' : ', ${file.bitsPerSample}-bit'}'
                '${switch (file.compression) {
                  null => '',
                  FileCompression.none => ', uncompressed',
                  FileCompression.lossless => ', lossless compression',
                  FileCompression.lossy => ', lossy compression',
                  FileCompression.unknown => ', compression not recognized',
                }}.',
          if (misfit.isNotEmpty)
            'It does not fit this plan\'s light blocks '
                '(${misfit.map(StorageText.conflict).join(', ')}), so it '
                'will not be used for them.',
          'It becomes the RAW size of "${rig.name}".',
        ].join('\n'),
        key: const Key('storageFile.summary'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialog, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('storageFile.use'),
          onPressed: () => Navigator.pop(dialog, true),
          child: const Text('Use for this rig'),
        ),
      ],
    ),
  );
  if (use != true || !context.mounted) return;
  final saved = await runWithFeedback(
    context,
    'save the rig',
    () => context.read<GearViewModel>().update(rig.withMeasuredFile(file)),
  );
  if (!saved || !context.mounted) return;
  await plan.refreshSelectedEquipment();
  if (context.mounted) {
    showDone(context, "Rig's frame size set from ${file.label}");
  }
}

/// "Enter a size": the plan's rig in its editor (the RAW size and the
/// capture format are in More).
Future<void> enterStorageSize(BuildContext context) async {
  final plan = context.read<SessionPlanViewModel>();
  final rig = plan.selectedEquipment;
  if (rig == null) return;
  final saved = await showEquipmentEditor(context, existing: rig);
  if (saved == null || !context.mounted) return;
  await plan.refreshSelectedEquipment();
  if (context.mounted) showDone(context, 'Rig saved');
}
