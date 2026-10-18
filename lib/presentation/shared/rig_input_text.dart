import '../../domain/models/camera_class.dart';
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

  /// The capture-file formats whose metadata is read (F04; FITS is F10).
  static String readableFormats(CameraClass c) =>
      c == CameraClass.astroColour || c == CameraClass.astroMono
      ? 'A photo can be a JPEG, HEIC or DNG file. FITS files are not read '
            'yet, so an astro camera is usually entered by hand.'
      : 'A photo can be a JPEG, HEIC or DNG file; it is read on this device.';

  static const savedAndChosen = 'Rig saved and chosen for this plan';
}
