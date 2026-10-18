import '../../core/utils/quantity_text.dart';
import '../metadata/capture_metadata.dart';
import '../metadata/metadata_format.dart';
import '../metadata/metadata_value.dart';
import '../models/equipment_limits.dart';
import '../models/spec_confidence.dart';
import '../models/spec_provenance.dart';
import '../models/capture_evidence.dart';
import '../services/storage_estimate.dart';
import 'sensor_geometry_estimate.dart';

/// Why a candidate field has no proposed value (ADR-018 §4).
enum CandidateGap {
  /// The file does not carry it.
  notInFile,

  /// The file carries a value that cannot be read.
  unreadable,

  /// The file carries conflicting values.
  conflicting,

  /// The file's value is outside the plausible equipment range
  /// ([EquipmentLimits]).
  outOfRange,

  /// An estimate (CALC-40) needs inputs the file does not give, or its
  /// result is implausible.
  notEstimable,

  /// Never taken from metadata: the aperture diameter (ADR-011 §4), rotation,
  /// tracking (ADR-011 §5) and the maximum exposure.
  neverFromMetadata,
}

/// One proposed [EquipmentCandidate] field (ADR-018 §4): a value with its
/// source and confidence, or unknown with a reason. Nothing here is stored;
/// the user confirms or changes every value before a rig is saved.
sealed class CandidateField<T> {
  const CandidateField();

  T? get valueOrNull => switch (this) {
    ProposedField<T>(:final value) => value,
    UnknownField<T>() => null,
  };
}

/// A value proposed from the file.
final class ProposedField<T> extends CandidateField<T> {
  const ProposedField(
    this.value, {
    required this.source,
    required this.confidence,
    required this.origins,
  });

  final T value;

  /// A namespaced source id (ADR-008 §6): `metadata:<format>` for a value
  /// read from the file, `derived:calc-40/metadata:<format>` for the
  /// estimate.
  final String source;

  /// `reported` for a file value, `estimated` for a derivation; never
  /// `verified`.
  final SpecConfidence confidence;

  /// The tags it came from (several for a derivation).
  final List<MetadataOrigin> origins;

  @override
  String toString() => 'Proposed($value, $source, ${confidence.name})';
}

/// No value proposed, and why.
final class UnknownField<T> extends CandidateField<T> {
  const UnknownField(this.gap);

  final CandidateGap gap;

  @override
  String toString() => 'Unknown(${gap.name})';
}

/// What a capture file says about the equipment that made it (level 3 of
/// ADR-017 §13; ADR-018 §4): a proposed value per `EquipmentProfile` field,
/// plus the identity evidence matching needs (S3.3). Pure and in memory.
class EquipmentCandidate {
  const EquipmentCandidate({
    required this.format,
    required this.suggestedName,
    required this.manufacturer,
    required this.cameraModel,
    required this.resolutionWidthPx,
    required this.resolutionHeightPx,
    required this.focalLengthMm,
    required this.focalRatio,
    required this.sensorWidthMm,
    required this.sensorHeightMm,
    required this.pixelPitchUm,
    required this.averageRawFileSizeMB,
    this.rawFileEvidence,
    required this.evidence,
  });

  final MetadataFormat format;

  /// A suggested rig name (a label, always editable), or null without any
  /// identity or focal length.
  final String? suggestedName;

  /// Labels, as the file writes them (trimmed).
  final CandidateField<String> manufacturer;
  final CandidateField<String> cameraModel;

  /// The output mode's pixel counts: the long side as the width.
  final CandidateField<int> resolutionWidthPx;
  final CandidateField<int> resolutionHeightPx;

  final CandidateField<double> focalLengthMm;
  final CandidateField<double> focalRatio;

  /// CALC-40 estimates, `estimated` (offered, never applied silently).
  final CandidateField<double> sensorWidthMm;
  final CandidateField<double> sensorHeightMm;
  final CandidateField<double> pixelPitchUm;

  /// A DNG's file length as the average RAW size, MB (10⁶ bytes), only
  /// ever `estimated` (one file is one sample; compression varies), source
  /// `metadata:dng:file-size` (ADR-018 §4, D4). A JPEG or HEIC size is not a
  /// RAW size, so it is never proposed from them.
  final CandidateField<double> averageRawFileSizeMB;

  /// The file [averageRawFileSizeMB] comes from (ADR-021 C7, F07): kept
  /// with the rig's size while that size is unchanged; null otherwise.
  final FileEvidence? rawFileEvidence;

  /// The source id of [averageRawFileSizeMB].
  static const rawFileSizeSource = 'metadata:dng:file-size';

  /// The precision estimates are proposed at, which is also what the rig
  /// editor stores (S3.9, TD-068): far finer than the estimates'
  /// uncertainty (CALC-40: a few per cent), so the rounding loses nothing,
  /// and a rig saved from a file compares equal to that file.
  static const sensorDecimals = 2, pixelPitchDecimals = 3, rawSizeDecimals = 1;

  static double _round(double v, int decimals) =>
      double.parse(v.toStringAsFixed(decimals));

  /// The raw metadata behind the candidate, for matching (S3.3).
  final EquipmentEvidence evidence;

  /// Never taken from metadata (ADR-011 §4, §5; ADR-018 §4).
  CandidateField<double> get apertureDiameterMm =>
      const UnknownField(CandidateGap.neverFromMetadata);
  CandidateField<double> get rotationDeg =>
      const UnknownField(CandidateGap.neverFromMetadata);
  CandidateField<double> get maxExposureS =>
      const UnknownField(CandidateGap.neverFromMetadata);

  /// The required rig inputs (ADR-021 C20) this file does not give. The
  /// user types them in the rig editor; none is defaulted (F05 A3).
  List<EquipmentSpec> get missingRequired => [
    if (resolutionWidthPx is! ProposedField ||
        resolutionHeightPx is! ProposedField)
      EquipmentSpec.resolution,
    if (pixelPitchUm is! ProposedField) EquipmentSpec.pixelPitch,
    if (sensorWidthMm is! ProposedField || sensorHeightMm is! ProposedField)
      EquipmentSpec.sensorSize,
    if (focalLengthMm is! ProposedField) EquipmentSpec.focalLength,
    if (focalRatio is! ProposedField) EquipmentSpec.focalRatio,
  ];

  /// True when the file names a camera or gives its optics; false means
  /// there is nothing to propose a rig from.
  bool get hasEnoughEvidence =>
      manufacturer is ProposedField ||
      cameraModel is ProposedField ||
      focalLengthMm is ProposedField ||
      focalRatio is ProposedField;

  /// Builds the candidate from a reading (ADR-018 §4). Exposure,
  /// sensitivity and capture time are ignored: they describe one frame,
  /// not the equipment. [fileLengthBytes], the picked file's length, gives
  /// the average RAW size for a DNG (S3.8).
  factory EquipmentCandidate.fromReading(
    MetadataRead reading, {
    int? fileLengthBytes,
    String? fileName,
  }) {
    final m = reading.metadata;
    final source = 'metadata:${reading.format.name}';

    CandidateField<T> field<T>(
      MetadataValue<T> value, [
      bool Function(T)? plausible,
    ]) => switch (value) {
      KnownValue<T>(:final value, :final origin) =>
        plausible != null && !plausible(value)
            ? UnknownField<T>(CandidateGap.outOfRange)
            : ProposedField<T>(
                value,
                source: source,
                confidence: SpecConfidence.reported,
                origins: [origin],
              ),
      AbsentValue<T>() => UnknownField<T>(CandidateGap.notInFile),
      UnparseableValue<T>() => UnknownField<T>(CandidateGap.unreadable),
      AmbiguousValue<T>() => UnknownField<T>(CandidateGap.conflicting),
    };

    final focal = field(
      m.focalLengthMm,
      EquipmentLimits.focalLengthMm.contains,
    );
    final ratio = field(m.fNumber, EquipmentLimits.focalRatio.contains);
    final dims = field(
      m.imageDimensions,
      (d) =>
          EquipmentLimits.resolutionPx.contains(d.longSidePx.toDouble()) &&
          EquipmentLimits.resolutionPx.contains(d.shortSidePx.toDouble()),
    );
    CandidateField<int> side(int Function(ImageDimensions) of) =>
        switch (dims) {
          ProposedField(:final value, :final source, :final origins) =>
            ProposedField(
              of(value),
              source: source,
              confidence: SpecConfidence.reported,
              origins: origins,
            ),
          UnknownField(:final gap) => UnknownField(gap),
        };

    final fits = reading.format == MetadataFormat.fits
        ? _fitsGeometry(m, source)
        : null;
    final estimate = switch (fits) {
      final f? => (width: f.width, height: f.height, pitch: f.pitch),
      null => _estimate(m, focal, dims, source),
    };
    final rawSize = _rawFileSize(reading.format, fileLengthBytes);
    final make = field(m.cameraMake);
    final model = field(m.cameraModel);

    return EquipmentCandidate(
      format: reading.format,
      suggestedName: _name(
        make.valueOrNull,
        model.valueOrNull,
        m.lensModel.valueOrNull,
        focal.valueOrNull,
      ),
      manufacturer: make,
      cameraModel: model,
      resolutionWidthPx: fits?.longPx ?? side((d) => d.longSidePx),
      resolutionHeightPx: fits?.shortPx ?? side((d) => d.shortSidePx),
      focalLengthMm: focal,
      focalRatio: ratio,
      sensorWidthMm: estimate.width,
      sensorHeightMm: estimate.height,
      pixelPitchUm: estimate.pitch,
      averageRawFileSizeMB: rawSize,
      rawFileEvidence: rawSize is ProposedField
          ? StorageEstimate.evidenceOf(fileName, reading, fileLengthBytes)
          : null,
      evidence: EquipmentEvidence(
        cameraMake: m.cameraMake.valueOrNull,
        cameraModel: m.cameraModel.valueOrNull,
        uniqueCameraModel: m.uniqueCameraModel.valueOrNull,
        lensMake: m.lensMake.valueOrNull,
        lensModel: m.lensModel.valueOrNull,
        focalLength35mmEquivalentMm: m.focalLength35mmEquivalentMm.valueOrNull,
        imageDimensions: m.imageDimensions.valueOrNull,
      ),
    );
  }

  static CandidateField<double> _rawFileSize(
    MetadataFormat format,
    int? lengthBytes,
  ) {
    if (format != MetadataFormat.dng || lengthBytes == null) {
      return const UnknownField(CandidateGap.notInFile);
    }
    // Checked before rounding: rounding never makes a value plausible.
    final mb = lengthBytes / 1e6;
    if (!EquipmentLimits.rawFileSizeMB.contains(mb)) {
      return const UnknownField(CandidateGap.outOfRange);
    }
    return ProposedField(
      _round(mb, rawSizeDecimals),
      source: rawFileSizeSource,
      confidence: SpecConfidence.estimated,
      origins: const [
        MetadataOrigin(format: MetadataFormat.dng, field: 'File size'),
      ],
    );
  }

  /// ADR-021 C11/C21 (F10): a FITS file's native geometry. NAXISn is the
  /// written (binned) output and XPIXSZ the binned pixel size, so with a
  /// symmetric XBINNING = YBINNING = k the native pixel count is NAXISn × k
  /// and the native pixel size XPIXSZ / k, normalized once. Absent binning
  /// is not taken as 1 (some writers omit it for binned frames), and
  /// asymmetric binning or pixels are a conflict: nothing is proposed then.
  static ({
    CandidateField<double> width,
    CandidateField<double> height,
    CandidateField<double> pitch,
    CandidateField<int> longPx,
    CandidateField<int> shortPx,
  })
  _fitsGeometry(CaptureMetadata m, String source) {
    final dims = m.imageDimensions;
    final bin = m.binning;
    final size = m.pixelSizeUm;
    final gap = switch (bin) {
      AbsentValue() => CandidateGap.notInFile,
      KnownValue(:final value) when !value.isSymmetric =>
        CandidateGap.conflicting,
      KnownValue() => null,
      _ => CandidateGap.unreadable,
    };
    if (gap != null ||
        dims is! KnownValue<ImageDimensions> ||
        bin is! KnownValue<SensorBinning>) {
      final g = gap ?? CandidateGap.notInFile;
      return (
        width: UnknownField(g),
        height: UnknownField(g),
        pitch: UnknownField(g),
        longPx: UnknownField(g),
        shortPx: UnknownField(g),
      );
    }
    final k = bin.value.x;
    final origins = [dims.origin, bin.origin];
    ProposedField<T> proposed<T>(T v, [List<MetadataOrigin> more = const []]) =>
        ProposedField(
          v,
          source: source,
          confidence: SpecConfidence.reported,
          origins: [...origins, ...more],
        );
    final long = dims.value.longSidePx * k;
    final short = dims.value.shortSidePx * k;
    final longPx = EquipmentLimits.resolutionPx.contains(long.toDouble())
        ? proposed(long)
        : const UnknownField<int>(CandidateGap.outOfRange);
    final shortPx = EquipmentLimits.resolutionPx.contains(short.toDouble())
        ? proposed(short)
        : const UnknownField<int>(CandidateGap.outOfRange);
    if (size is! KnownValue<PixelSize> || !size.value.isSquare) {
      final g = size is KnownValue<PixelSize>
          ? CandidateGap.conflicting
          : CandidateGap.notInFile;
      return (
        width: UnknownField(g),
        height: UnknownField(g),
        pitch: UnknownField(g),
        longPx: longPx,
        shortPx: shortPx,
      );
    }
    final pitch = size.value.xUm / k;
    final pitchField = EquipmentLimits.pixelPitchUm.contains(pitch)
        ? proposed(_round(pitch, pixelPitchDecimals), [size.origin])
        : const UnknownField<double>(CandidateGap.outOfRange);
    return (
      width: proposed(_round(long * pitch / 1000, sensorDecimals), [
        size.origin,
      ]),
      height: proposed(_round(short * pitch / 1000, sensorDecimals), [
        size.origin,
      ]),
      pitch: pitchField,
      longPx: longPx,
      shortPx: shortPx,
    );
  }

  static ({
    CandidateField<double> width,
    CandidateField<double> height,
    CandidateField<double> pitch,
  })
  _estimate(
    CaptureMetadata m,
    CandidateField<double> focal,
    CandidateField<ImageDimensions> dims,
    String source,
  ) {
    const none = UnknownField<double>(CandidateGap.notEstimable);
    final f35 = m.focalLength35mmEquivalentMm;
    if (focal is! ProposedField<double> ||
        dims is! ProposedField<ImageDimensions> ||
        f35 is! KnownValue<double>) {
      return (width: none, height: none, pitch: none);
    }
    final e = SensorGeometryEstimate.of(
      focalLengthMm: focal.value,
      focalLength35mmEquivalentMm: f35.value,
      longSidePx: dims.value.longSidePx,
      shortSidePx: dims.value.shortSidePx,
    );
    if (e == null) return (width: none, height: none, pitch: none);
    ProposedField<double> proposed(double v) => ProposedField(
      v,
      source: 'derived:calc-40/$source',
      confidence: SpecConfidence.estimated,
      origins: [...focal.origins, f35.origin, ...dims.origins],
    );
    return (
      width: proposed(_round(e.widthMm, sensorDecimals)),
      height: proposed(_round(e.heightMm, sensorDecimals)),
      pitch: proposed(_round(e.pixelPitchUm, pixelPitchDecimals)),
    );
  }

  /// "Make Model · lens" or "Make Model · 6.57 mm"; the make is not
  /// repeated when the model already starts with it.
  static String? _name(
    String? make,
    String? model,
    String? lens,
    double? focalLengthMm,
  ) {
    final camera = switch ((make, model)) {
      (final mk?, final md?)
          when md.toLowerCase().startsWith(mk.toLowerCase()) =>
        md,
      (final mk?, final md?) => '$mk $md',
      (final mk?, null) => mk,
      (null, final md?) => md,
      (null, null) => null,
    };
    final optics =
        lens ??
        (focalLengthMm == null
            ? null
            : '${QuantityText.number(focalLengthMm)} mm');
    return switch ((camera, optics)) {
      (final c?, final o?) => '$c · $o',
      (final c?, null) => c,
      (null, final o?) => o,
      (null, null) => null,
    };
  }
}

/// The raw identity and optics evidence behind a candidate, kept for
/// matching (ADR-018 §6). Never serials or location (ADR-017 §3).
class EquipmentEvidence {
  const EquipmentEvidence({
    this.cameraMake,
    this.cameraModel,
    this.uniqueCameraModel,
    this.lensMake,
    this.lensModel,
    this.focalLength35mmEquivalentMm,
    this.imageDimensions,
  });

  final String? cameraMake;
  final String? cameraModel;
  final String? uniqueCameraModel;
  final String? lensMake;
  final String? lensModel;
  final double? focalLength35mmEquivalentMm;
  final ImageDimensions? imageDimensions;
}
