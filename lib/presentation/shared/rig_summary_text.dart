import '../../domain/models/equipment_profile.dart';
import '../../domain/models/tracking_type.dart';
import 'example_text.dart';

/// A rig in one line, as the Hybrid plan says it (plan.js `rigSummary`):
/// "DSLR or mirrorless · 135 mm f/2 · tracking not recorded". The Plan's
/// Rig row and the rig chooser share it.
abstract final class RigSummaryText {
  /// "f/5.6", "f/4" (plan.js `fNumber`: one decimal, no trailing zero).
  static String fNumber(double ratio) =>
      'f/${_trim(double.parse(ratio.toStringAsFixed(1)))}';

  /// The focal length and ratio; a stored ratio that needs review says so
  /// (TASK 8.4, trap 3).
  static String optics(EquipmentProfile rig) =>
      '${_trim(rig.focalLengthMm)} mm '
      '${rig.needsApertureReview ? 'f/${_trim(rig.focalRatio)} — please review' : fNumber(rig.focalRatio)}';

  /// A known tracking's label, or "tracking not recorded".
  static String tracking(TrackingType t) =>
      t == TrackingType.unknown ? 'tracking not recorded' : t.label;

  /// The line; [tracking] is the plan's effective tracking where it has
  /// one (RD-08), else the rig's. An example rig says so first (RD-04).
  static String of(EquipmentProfile rig, {TrackingType? tracking}) => [
    if (rig.isExample) ExampleText.rig,
    rig.cameraClass.label,
    optics(rig),
    RigSummaryText.tracking(tracking ?? rig.trackingType),
  ].join(' · ');

  static String _trim(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : '$v';
}
