import '../models/camera_class.dart';
import '../models/capture_block.dart';
import '../models/equipment_profile.dart';
import 'calibration_match.dart';

/// One proposed calibration block (CAL-1, PD-12; F09). [exposureSeconds] is
/// null where the user must enter it (a flat's for its illumination, a
/// bias's shortest): never inherited from a light. [count] is a proposal.
class ProposedCalibration {
  const ProposedCalibration({
    required this.type,
    required this.source,
    required this.filterName,
    required this.binning,
    required this.gain,
    required this.exposureSeconds,
    this.count = defaultCount,
    this.flatIndex,
  });

  /// A starting count, always editable; not a recommendation.
  static const defaultCount = 20;

  final FrameType type;

  /// The light (or flat) block it derives from, for its origin.
  final CaptureBlock source;
  final String? filterName;
  final int binning;
  final CaptureGain gain;
  final double? exposureSeconds;
  final int count;

  /// A dark flat for a flat proposed in the same preview: its exposure is
  /// that flat's, once entered.
  final int? flatIndex;
}

/// The CAL-1 preview's proposal for a plan (PD-12; ADR-020 §6, ADR-021
/// C15; F09 A2/A3): what the lights need and no existing block proves it
/// covers, each once.
class CalibrationProposal {
  const CalibrationProposal(this.blocks, {required this.darksByCamera});

  final List<ProposedCalibration> blocks;

  /// No darks: the rig's in-camera noise reduction takes one per light.
  final bool darksByCamera;
}

/// Builds [CalibrationProposal]s (CAL-1). Pure.
abstract final class CalibrationBuilder {
  /// Darks per distinct (exposure, ISO or gain, binning) of the lights,
  /// unless in-camera noise reduction applies; flats per distinct (filter,
  /// binning); bias per (ISO or gain, binning) for phones, cameras and
  /// Unknown, dark flats per flat for astro cameras (RG-10 §3.3–§3.4: bias
  /// is optional for every class; dark flats are the astro alternative).
  /// A tuple an existing block proves covered (C15) is not proposed.
  static CalibrationProposal propose(
    List<CaptureBlock> blocks,
    EquipmentProfile? rig,
  ) {
    final c = rig?.cameraClass ?? CameraClass.unknown;
    final lenr = rig?.noiseReductionApplies ?? false;
    final lights = blocks.where((b) => b.isLight).toList();
    final existing = blocks.where((b) => !b.isLight).toList();
    final out = <ProposedCalibration>[];
    // A block proposed here covers a later light of the same tuple.
    bool proposed(ProposedCalibration p, CaptureBlock light) =>
        p.type != FrameType.darkFlat &&
        CalibrationMatch.covers(_asBlock(p, light), light, c);

    bool coveredBy(FrameType type, CaptureBlock light) =>
        existing.any(
          (b) => b.frameType == type && CalibrationMatch.covers(b, light, c),
        ) ||
        out.any((p) => p.type == type && proposed(p, light));

    if (!lenr) {
      for (final l in lights) {
        if (coveredBy(FrameType.dark, l)) continue;
        out.add(
          ProposedCalibration(
            type: FrameType.dark,
            source: l,
            filterName: null,
            binning: l.binning,
            gain: l.gain,
            exposureSeconds: l.exposureTimeSeconds,
          ),
        );
      }
    }
    for (final l in lights) {
      if (coveredBy(FrameType.flat, l)) continue;
      out.add(
        ProposedCalibration(
          type: FrameType.flat,
          source: l,
          filterName: l.filterName,
          binning: l.binning,
          // RG-10 §4: a flat's ISO or gain is proposed from its light.
          gain: l.gain,
          exposureSeconds: null,
        ),
      );
    }
    final astro = c == CameraClass.astroColour || c == CameraClass.astroMono;
    if (!astro) {
      for (final l in lights) {
        if (coveredBy(FrameType.bias, l)) continue;
        out.add(
          ProposedCalibration(
            type: FrameType.bias,
            source: l,
            filterName: null,
            binning: l.binning,
            gain: l.gain,
            exposureSeconds: null,
          ),
        );
      }
    } else {
      // Dark flats for every flat: the plan's own (not yet covered) and the
      // ones proposed here.
      for (final f in existing.where((b) => b.frameType == FrameType.flat)) {
        if (existing.any(
          (b) =>
              b.frameType == FrameType.darkFlat &&
              CalibrationMatch.covers(b, f, c),
        )) {
          continue;
        }
        out.add(
          ProposedCalibration(
            type: FrameType.darkFlat,
            source: f,
            filterName: null,
            binning: f.binning,
            gain: f.gain,
            exposureSeconds: f.exposureTimeSeconds,
          ),
        );
      }
      final flats = [
        for (var i = 0; i < out.length; i++)
          if (out[i].type == FrameType.flat) i,
      ];
      for (final i in flats) {
        final f = out[i];
        out.add(
          ProposedCalibration(
            type: FrameType.darkFlat,
            source: f.source,
            filterName: null,
            binning: f.binning,
            gain: f.gain,
            exposureSeconds: null,
            flatIndex: i,
          ),
        );
      }
    }
    return CalibrationProposal(out, darksByCamera: lenr);
  }

  /// [p] as a block, for the coverage check of a proposal not yet confirmed
  /// (a placeholder exposure where the user enters one).
  static CaptureBlock _asBlock(ProposedCalibration p, CaptureBlock light) =>
      CaptureBlock(
        frameType: p.type,
        filterName: p.filterName,
        exposureTimeSeconds: p.exposureSeconds ?? light.exposureTimeSeconds,
        frameCount: 1,
        binning: p.binning,
        gain: p.gain,
        calibrationPolicy: CalibrationPolicy.outsideWindow,
      );

  /// The confirmed blocks: [counts] and [exposures] per proposal (an entered
  /// exposure, or the inherited one), with each inherited field's origin
  /// fixed as [descriptor] gives it.
  static List<CaptureBlock> confirm(
    CalibrationProposal proposal, {
    required List<int> counts,
    required List<double?> exposures,
    required String Function(CaptureBlock source) descriptor,
  }) {
    final out = <CaptureBlock>[];
    for (var i = 0; i < proposal.blocks.length; i++) {
      final p = proposal.blocks[i];
      final exposure =
          exposures[i] ??
          p.exposureSeconds ??
          (p.flatIndex == null ? null : exposures[p.flatIndex!]);
      if (exposure == null) {
        throw ArgumentError.value(i, 'exposures', 'missing an exposure');
      }
      final inherited = FieldOrigin(OriginKind.inherited, descriptor(p.source));
      final entered = FieldOrigin.entered();
      out.add(
        CaptureBlock(
          frameType: p.type,
          filterName: p.filterName,
          exposureTimeSeconds: exposure,
          frameCount: counts[i],
          binning: p.binning,
          gain: p.gain,
          calibrationPolicy: CalibrationPolicy.outsideWindow,
          origins: FieldOrigins({
            CaptureField.frameType: entered,
            CaptureField.count: entered,
            CaptureField.binning: inherited,
            if (p.type == FrameType.flat) CaptureField.filter: inherited,
            if (p.gain != CaptureGain.none)
              CaptureField.sensitivity: p.type == FrameType.flat
                  ? FieldOrigin(OriginKind.copied, descriptor(p.source))
                  : inherited,
            CaptureField.exposure:
                p.exposureSeconds != null && exposures[i] == null
                ? inherited
                : entered,
          }),
        ),
      );
    }
    return out;
  }
}
