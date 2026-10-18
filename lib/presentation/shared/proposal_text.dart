import '../../core/utils/quantity_text.dart';
import '../../domain/metadata/capture_metadata.dart';
import '../../domain/services/block_proposal.dart';
import 'capture_settings_text.dart';
import 'metadata_text.dart';
import 'storage_text.dart';

/// A block's file proposal in words (F08; ADR-021 C2, C13): what it
/// proposes, and what it only shows.
abstract final class ProposalText {
  static String title(BlockProposal p) => 'From ${p.label}';

  /// "Exposure 1/14 s · ISO 100 · White balance Auto", or why nothing.
  static String proposed(BlockProposal p) {
    final parts = [
      if (p.exposure case final e?)
        'Exposure ${QuantityText.exposure(e.value)}',
      if (p.iso case final i?) 'ISO ${i.value.value!.round()}',
      if (p.whiteBalance case final wb?)
        'White balance ${CaptureSettingsText.whiteBalance(wb.value)}',
    ];
    return parts.isEmpty
        ? 'Nothing to propose for this block.'
        : 'Proposed: ${parts.join(' · ')}.';
  }

  static String evidence(ProposalEvidence e) => switch (e) {
    SensitivityEvidence(:final value, :final proposed, :final recordsGain) =>
      recordsGain
          ? '${MetadataText.sensitivity(value)}: an ISO is not a gain, so '
                'nothing is proposed.'
          : proposed
          ? MetadataText.sensitivity(value)
          : '${MetadataText.sensitivity(value)}: not proposed until the '
                "rig's camera type is set.",
    WhiteBalanceEvidence(:final mode) => switch (mode) {
      ExifWhiteBalance.auto => 'White balance Auto',
      ExifWhiteBalance.manual =>
        'White balance Manual (not proposed: the setting is not recorded)',
    },
    LightSourceEvidence(:final source) =>
      'Light source ${source.name} (shown only)',
    NeutralEvidence(:final vector) =>
      'As-shot neutral ${vector.values.map(QuantityText.number).join(' · ')} '
          '(a neutral vector, not a colour temperature)',
  };

  /// Why the file's size is not used for this block, or null.
  static String? mode(BlockProposal p) => p.modeConflicts.isEmpty
      ? null
      : "Not the rig's mode (${p.modeConflicts.map(StorageText.conflict).join(', ')}): "
            'its size is not used for storage.';

  static String unreadable(BlockProposal p) =>
      "${p.label} can't be read for a block: it is not a DNG, JPEG or HEIC "
      'this app reads. Nothing was changed.';
}
