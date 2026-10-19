import '../../core/units/display_units.dart';
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
      if (p.gain case final g?) 'Gain ${QuantityText.number(g.value.value!)}',
      if (p.filter case final f?) 'Filter ${f.value}',
      if (p.binning case final b?) 'Binning ${b.value} × ${b.value}',
      if (p.whiteBalance case final wb?)
        'White balance ${CaptureSettingsText.whiteBalance(wb.value)}',
    ];
    return parts.isEmpty
        ? 'Nothing to propose for this block.'
        : 'Proposed: ${parts.join(' · ')}.';
  }

  /// [units]: the chosen display units (F21); the file's values are °C.
  static String evidence(
    ProposalEvidence e, [
    DisplayUnits units = DisplayUnits.metric,
  ]) => switch (e) {
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
    GainEvidence(:final value, :final why) =>
      'Gain ${QuantityText.number(value)}: not proposed '
          '${switch (why) {
            GainNotProposed.recordsIso => '(this rig records ISO, and a gain is not an ISO)',
            GainNotProposed.classUnknown => "until the rig's camera type is set",
            GainNotProposed.outOfRange => '(above any gain setting)',
          }}',
    SettingEvidence(:final keyword, :final value) => switch (keyword) {
      'EGAIN' =>
        'Conversion gain ${QuantityText.number(value)} e⁻/ADU (shown only)',
      'OFFSET' => 'Offset ${QuantityText.number(value)} (shown only)',
      'CCD-TEMP' =>
        'Sensor temperature ${QuantityText.temperatureAsRecorded(value, units)} '
            '(shown only)',
      'SET-TEMP' =>
        'Cooler setpoint ${QuantityText.temperatureAsRecorded(value, units)} '
            '(shown only; not '
            'the measured temperature)',
      _ => '$keyword ${QuantityText.number(value)} (shown only)',
    },
    BinningEvidence(:final binning) =>
      'Binning ${binning.x} × ${binning.y}: not proposed'
          '${binning.isSymmetric ? '' : ' (not the same on both axes)'}',
  };

  /// Why the file's size is not used for this block, or null.
  static String? mode(BlockProposal p) => p.modeConflicts.isEmpty
      ? null
      : "Not the rig's mode (${p.modeConflicts.map(StorageText.conflict).join(', ')}): "
            'its size is not used for storage.';

  static String unreadable(BlockProposal p) =>
      "${p.label} can't be read for a block: it is not a DNG, JPEG, HEIC or "
      'FITS file this app reads. Nothing was changed.';
}
