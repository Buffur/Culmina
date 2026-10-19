import '../metadata/capture_metadata.dart';
import '../metadata/metadata_value.dart';
import '../models/camera_class.dart';
import '../models/capture_block.dart';
import '../models/equipment_profile.dart';
import 'storage_estimate.dart';

/// One proposed block value from a file, with its origin (ADR-021 C4).
class ProposedValue<T> {
  const ProposedValue(this.value, this.origin);

  final T value;
  final FieldOrigin origin;
}

/// What one picked DNG, JPEG or HEIC proposes for a light block (F08;
/// ADR-021 C2, C4, C6, C13; PD-11). Proposals are local to the block
/// editor: nothing is stored until the user applies the block, and nothing
/// reaches the rig. Only fields the rig's class records are proposed; the
/// rest of what the file says is shown as evidence.
class BlockProposal {
  const BlockProposal({
    required this.label,
    this.exposure,
    this.iso,
    this.whiteBalance,
    this.gain,
    this.binning,
    this.filter,
    this.file,
    this.evidence = const [],
    this.modeConflicts = const {},
    this.unreadable = false,
    this.rig,
  });

  /// The file's basename (C5).
  final String label;

  /// Seconds, within the block bounds.
  final ProposedValue<double>? exposure;

  /// An ISO, only for a class that records ISO (C13; never as a gain).
  final ProposedValue<CaptureGain>? iso;

  /// Only Auto, from EXIF WhiteBalance = Auto (C2).
  final ProposedValue<WhiteBalance>? whiteBalance;

  /// A FITS GAIN, only for a class that records gain (C13, C21).
  final ProposedValue<CaptureGain>? gain;

  /// A FITS XBINNING = YBINNING, only where the class offers binning.
  final ProposedValue<int>? binning;

  /// A FITS FILTER, as written (trimmed; C21).
  final ProposedValue<String>? filter;

  /// The ISO or the gain, whichever the class records.
  ProposedValue<CaptureGain>? get sensitivity => iso ?? gain;

  /// The file as the block's storage evidence (C6).
  final FileEvidence? file;

  /// What the file says that is not proposed, in words' keys: the
  /// sensitivity kind, a manual white balance, the light source, the
  /// as-shot neutral vector, a value the class does not record.
  final List<ProposalEvidence> evidence;

  /// Why [file] does not fit the rig's mode for this block (C8): shown;
  /// the file's size is then not used for storage. At the binning the
  /// file proposes (or the block's); [conflictsAt] for another one.
  final Set<StorageConflict> modeConflicts;

  /// The rig the file was compared with.
  final EquipmentProfile? rig;

  /// [modeConflicts] for a block that keeps [binning] (TD-110): a binning
  /// kept against the file's is a conflict, as on Apply.
  Set<StorageConflict> conflictsAt(int binning) => switch (file) {
    null => const {},
    final f => StorageEstimate.conflicts(
      f,
      CaptureBlock(
        frameType: FrameType.light,
        exposureTimeSeconds: 1,
        frameCount: 1,
        binning: binning,
      ),
      rig,
    ),
  };

  /// The file could not be read for a block (unrecognized or damaged).
  final bool unreadable;

  bool get isEmpty =>
      exposure == null &&
      iso == null &&
      gain == null &&
      binning == null &&
      filter == null &&
      whiteBalance == null &&
      file == null;

  /// Builds the proposal for a block at [binning] of a rig of [cameraClass].
  static BlockProposal of({
    required String? name,
    required MetadataReading reading,
    required int? lengthBytes,
    required CameraClass cameraClass,
    EquipmentProfile? rig,
    int binning = 1,
  }) {
    final label = FileEvidence.basename(
      (name == null || name.trim().isEmpty) ? 'file' : name,
    );
    final file = StorageEstimate.evidenceOf(label, reading, lengthBytes);
    if (reading is! MetadataRead) {
      return BlockProposal(label: label, file: file, unreadable: file == null);
    }
    final m = reading.metadata;
    FieldOrigin origin(MetadataOrigin o, [Map<String, Object?>? more]) =>
        FieldOrigin(
          OriginKind.file,
          label,
          evidence: {'tag': o.field, ...?more},
        );
    final evidence = <ProposalEvidence>[];

    ProposedValue<double>? exposure;
    if (m.exposureSeconds case KnownValue(:final value, origin: final o)
        when value > 0 && value <= CaptureBlock.maxExposureSeconds) {
      exposure = ProposedValue(value, origin(o));
    }

    ProposedValue<CaptureGain>? iso;
    if (m.sensitivity case KnownValue(:final value, origin: final o)) {
      final whole = value.value.round();
      final recordsIso = cameraClass.lightSensitivity == LightSensitivity.iso;
      if (recordsIso && whole >= 1 && whole <= 1000000) {
        iso = ProposedValue(
          CaptureGain.iso(whole),
          origin(o, {'kind': value.kind.name}),
        );
      }
      evidence.add(
        ProposalEvidence.sensitivity(
          value,
          proposed: iso != null,
          recordsGain: cameraClass.lightSensitivity == LightSensitivity.gain,
        ),
      );
    }

    ProposedValue<WhiteBalance>? wb;
    final offersWb = cameraClass.offersCameraRecords;
    if (m.whiteBalance case KnownValue(:final value, origin: final o)) {
      if (value == ExifWhiteBalance.auto && offersWb) {
        wb = ProposedValue(WhiteBalance.auto(), origin(o));
      } else {
        evidence.add(ProposalEvidence.whiteBalance(value));
      }
    }
    if (m.lightSource case KnownValue(:final value)) {
      evidence.add(ProposalEvidence.lightSource(value));
    }
    if (m.asShotNeutral case KnownValue(:final value)) {
      evidence.add(ProposalEvidence.neutral(value));
    }

    // FITS (F10, C21): GAIN for a gain class, symmetric binning where the
    // class bins, FILTER as written; the rest is evidence only.
    ProposedValue<CaptureGain>? gain;
    if (m.acquisitionGain case KnownValue(:final value, origin: final o)) {
      final why = switch (cameraClass.lightSensitivity) {
        LightSensitivity.iso => GainNotProposed.recordsIso,
        LightSensitivity.either => GainNotProposed.classUnknown,
        LightSensitivity.gain when value > 10000 => GainNotProposed.outOfRange,
        LightSensitivity.gain => null,
      };
      if (why == null) {
        gain = ProposedValue(CaptureGain.gain(value), origin(o));
      } else {
        evidence.add(ProposalEvidence.gain(value, why));
      }
    }
    ProposedValue<int>? binningValue;
    if (m.binning case KnownValue(:final value, origin: final o)) {
      if (cameraClass.offersLightBinning &&
          value.isSymmetric &&
          value.x >= 1 &&
          value.x <= 4) {
        binningValue = ProposedValue(value.x, origin(o));
      } else {
        evidence.add(ProposalEvidence.binning(value));
      }
    }
    ProposedValue<String>? filter;
    if (m.filterName case KnownValue(:final value, origin: final o)
        when value.trim().length <= 32) {
      filter = ProposedValue(value.trim(), origin(o));
    }
    for (final (keyword, v) in [
      ('EGAIN', m.conversionGainElectronsPerAdu),
      ('OFFSET', m.offset),
      ('CCD-TEMP', m.sensorTemperatureC),
      ('SET-TEMP', m.setpointTemperatureC),
    ]) {
      if (v case KnownValue(:final value)) {
        evidence.add(ProposalEvidence.setting(keyword, value));
      }
    }

    final block = CaptureBlock(
      frameType: FrameType.light,
      exposureTimeSeconds: 1,
      frameCount: 1,
      binning: binningValue?.value ?? binning,
    );
    return BlockProposal(
      label: label,
      exposure: exposure,
      iso: iso,
      whiteBalance: wb,
      gain: gain,
      binning: binningValue,
      filter: filter,
      file: file,
      evidence: evidence,
      modeConflicts: file == null
          ? const {}
          : StorageEstimate.conflicts(file, block, rig),
      rig: rig,
    );
  }
}

/// One fact from the file that is shown, not proposed (C2, C13, SI-004).
sealed class ProposalEvidence {
  const ProposalEvidence();

  const factory ProposalEvidence.sensitivity(
    Sensitivity value, {
    required bool proposed,
    required bool recordsGain,
  }) = SensitivityEvidence;
  const factory ProposalEvidence.whiteBalance(ExifWhiteBalance mode) =
      WhiteBalanceEvidence;
  const factory ProposalEvidence.lightSource(LightSource source) =
      LightSourceEvidence;
  const factory ProposalEvidence.neutral(NeutralVector vector) =
      NeutralEvidence;
  const factory ProposalEvidence.setting(String keyword, double value) =
      SettingEvidence;
  const factory ProposalEvidence.gain(double value, GainNotProposed why) =
      GainEvidence;
  const factory ProposalEvidence.binning(SensorBinning binning) =
      BinningEvidence;
}

/// A FITS value shown only (C21): OFFSET, temperatures, EGAIN.
final class SettingEvidence extends ProposalEvidence {
  const SettingEvidence(this.keyword, this.value);
  final String keyword;
  final double value;
}

/// Why a FITS GAIN is not proposed (C13, SI-004).
enum GainNotProposed {
  /// The rig's class records ISO, and a gain is not an ISO.
  recordsIso,

  /// The rig's camera type is not set.
  classUnknown,

  /// Above any camera's gain setting (more than 10000).
  outOfRange,
}

/// A FITS GAIN shown, not proposed, with [why].
final class GainEvidence extends ProposalEvidence {
  const GainEvidence(this.value, this.why);
  final double value;
  final GainNotProposed why;
}

/// A binning not proposed: asymmetric, out of range, or a class that does
/// not bin per exposure.
final class BinningEvidence extends ProposalEvidence {
  const BinningEvidence(this.binning);
  final SensorBinning binning;
}

final class SensitivityEvidence extends ProposalEvidence {
  const SensitivityEvidence(
    this.value, {
    required this.proposed,
    required this.recordsGain,
  });

  final Sensitivity value;

  /// Whether it became the block's ISO.
  final bool proposed;

  /// The rig records gain: an ISO is never relabelled as a gain.
  final bool recordsGain;
}

final class WhiteBalanceEvidence extends ProposalEvidence {
  const WhiteBalanceEvidence(this.mode);
  final ExifWhiteBalance mode;
}

final class LightSourceEvidence extends ProposalEvidence {
  const LightSourceEvidence(this.source);
  final LightSource source;
}

final class NeutralEvidence extends ProposalEvidence {
  const NeutralEvidence(this.vector);
  final NeutralVector vector;
}
