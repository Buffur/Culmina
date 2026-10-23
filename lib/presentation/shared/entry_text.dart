import '../../core/utils/quantity_text.dart';
import '../../domain/models/camera_class.dart';
import '../../domain/models/capture_block.dart';

/// The Logbook's block wording (logbook.js `blockLabel`, `sensitivityText`):
/// "Broadband · 60 s · ISO 800", with the rig's sensitivity named when a
/// block's value was not recorded.
abstract final class EntryText {
  /// "ISO 800", "Gain 100", or which one was not recorded ("ISO not
  /// recorded" for a camera, "Sensitivity not recorded" when the rig's class
  /// is unknown). Never converted (SI-004).
  static String sensitivity(CaptureGain g, CameraClass? rig) {
    final v = g.value;
    if (v != null && g.kind == GainKind.iso) return 'ISO ${_trim(v)}';
    if (v != null && g.kind == GainKind.gain) return 'Gain ${_trim(v)}';
    return switch (rig?.lightSensitivity) {
      LightSensitivity.iso => 'ISO not recorded',
      LightSensitivity.gain => 'Gain not recorded',
      _ => 'Sensitivity not recorded',
    };
  }

  /// The block's filter (or frame type), exposure, sensitivity and, above
  /// 1, binning.
  static String block(CaptureBlock b, CameraClass? rig) => [
    switch (b.filterName?.trim()) {
      final f? when f.isNotEmpty => f,
      _ => frames(b.frameType),
    },
    QuantityText.exposure(b.exposureTimeSeconds),
    sensitivity(b.gain, rig),
    if (b.binning > 1) 'bin ${b.binning}×${b.binning}',
  ].join(' · ');

  static String frames(FrameType t) => switch (t) {
    FrameType.light => 'Lights',
    FrameType.dark => 'Darks',
    FrameType.flat => 'Flats',
    FrameType.bias => 'Bias',
    FrameType.darkFlat => 'Dark flats',
  };

  static String plural(int n, String one) => '$n ${n == 1 ? one : '${one}s'}';

  static String _trim(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();
}
