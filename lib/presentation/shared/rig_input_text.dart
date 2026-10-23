import '../../domain/models/camera_class.dart';
import '../../domain/models/capture_evidence.dart';
import '../../domain/models/spec_confidence.dart';
import '../../domain/models/spec_provenance.dart';

/// Why the rig editor asks for each required input, and the words of the
/// class-first add flow (F05; ADR-021 C20). Each reason names the
/// calculations that use the input; nothing here supplies a value.
abstract final class RigInputText {
  /// The calculations that need [spec] (ADR-021 C20).
  static String reason(EquipmentSpec spec) => switch (spec) {
    EquipmentSpec.resolution =>
      'Needed for the pixel-size check and the storage estimate',
    EquipmentSpec.pixelPitch =>
      'Needed for the image scale and the exposure guide (NPF)',
    EquipmentSpec.sensorSize => 'Needed for the field of view and framing',
    EquipmentSpec.focalLength =>
      'Needed for the field of view, image scale and exposure guide (NPF)',
    EquipmentSpec.focalRatio => 'Needed for the exposure guide (NPF)',
    EquipmentSpec.rawFileSize => 'Optional: makes the storage estimate real',
  };

  /// The input's name in a "missing" line.
  static String name(EquipmentSpec spec) => switch (spec) {
    EquipmentSpec.resolution => 'Resolution',
    EquipmentSpec.pixelPitch => 'Pixel size',
    EquipmentSpec.sensorSize => 'Sensor size',
    EquipmentSpec.focalLength => 'Focal length',
    EquipmentSpec.focalRatio => 'Focal ratio',
    EquipmentSpec.rawFileSize => 'RAW file size',
  };

  static const missingIntro =
      'Not in this file. Type these in the rig editor; nothing is guessed:';

  static const classQuestion = 'What takes the pictures?';

  /// "Not sure" stores [CameraClass.unknown].
  static String classLabel(CameraClass c) =>
      c == CameraClass.unknown ? 'Not sure' : c.label;

  static const chooseClassFirst = 'Choose the camera type first.';

  static const notSure =
      'The type stays Unknown. The app does not work out sensor facts from '
      'it; you can set it later in the rig.';

  static const fromPhoto = 'From a photo';
  static const byHand = 'Enter by hand';

  /// The capture-file formats whose metadata is read (F04, F10). Other RAW
  /// files are recognized, never read (RG-14).
  static String readableFormats(CameraClass c) =>
      c == CameraClass.astroColour || c == CameraClass.astroMono
      ? 'A file can be a FITS sub-frame, or a JPEG, HEIC or DNG; it is read '
            'on this device.'
      : 'A photo can be a JPEG, HEIC or DNG file (or a FITS sub-frame); it is '
            'read on this device. Other RAW files (CR3, NEF, ARW …) are not '
            'read.';

  static const savedAndChosen = 'Rig saved and chosen for this plan';

  /// A capture format in words (ADR-021 C7).
  static String captureFormat(CaptureFormat f) => switch (f) {
    CaptureFormat.dngUncompressed16 => 'Uncompressed DNG, 16-bit',
    CaptureFormat.fits16 => 'FITS, 16-bit integer',
    CaptureFormat.fits32float => 'FITS, 32-bit float',
    CaptureFormat.compressedRaw => 'Compressed RAW (CR3, NEF, ARW …)',
    CaptureFormat.jpegHeic => 'JPEG or HEIC',
  };

  /// Where a group of specs came from (ADR-008 §6), in words: "Entered by
  /// you", "From a file (DNG)", "Example values shipped with the app";
  /// never a guess.
  static String source(String? source, SpecConfidence? confidence) {
    final from = switch (source) {
      null => 'Not recorded',
      'user' => 'Entered by you',
      final s when s.startsWith('seed:') =>
        'Example values shipped with the app',
      final s when s.startsWith('metadata:') =>
        'From a file (${s.substring('metadata:'.length).split(':').first.toUpperCase()})',
      final s => s,
    };
    return switch (confidence) {
      SpecConfidence.verified => '$from · verified',
      SpecConfidence.reported => '$from · reported',
      SpecConfidence.estimated => '$from · estimated',
      null => from,
    };
  }
}
