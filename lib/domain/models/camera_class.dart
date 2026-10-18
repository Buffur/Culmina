/// What kind of camera a rig uses (ADR-020 §2; S7.2a). It decides which
/// capture settings a light block offers (ISO or gain, binning; S7.2b) and
/// feeds no calculation. Stored by [name] in `camera_modules.camera_class`;
/// anything unrecognised reads as [unknown]. Chosen by the user only: never
/// inferred from a name, a Make or Model string, or a file's format.
enum CameraClass {
  phone('Phone'),
  dslrMirrorless('DSLR or mirrorless'),
  astroColour('Astro camera (colour)'),
  astroMono('Astro camera (mono)'),
  unknown('Unknown');

  const CameraClass(this.label);

  final String label;

  static CameraClass fromStorage(String? value) => CameraClass.values
      .firstWhere((c) => c.name == value, orElse: () => CameraClass.unknown);

  /// Which sensitivity a light block records for this class (ADR-020 §3):
  /// ISO for phones and cameras, gain for astro cameras. For Unknown
  /// ([LightSensitivity.either]) the block offers no ISO/gain field since
  /// ADR-021 C13 (F06): the remedy is the rig's camera type, and a value
  /// already recorded is kept. Never both on one block; never converted
  /// (SI-004).
  LightSensitivity get lightSensitivity => switch (this) {
    phone || dslrMirrorless => LightSensitivity.iso,
    astroColour || astroMono => LightSensitivity.gain,
    unknown => LightSensitivity.either,
  };

  /// Whether a light block offers binning (ADR-020 §3, B1): only where it is
  /// chosen per exposure (astro cameras) or the class is unknown. A phone's
  /// binning is its rig's mode; cameras offer none.
  bool get offersLightBinning =>
      this == astroColour || this == astroMono || this == unknown;

  /// Whether the rig editor offers in-camera long-exposure noise reduction
  /// (ADR-020 §8): cameras and Unknown. Phones and astro cameras do not take
  /// an automatic dark per frame.
  bool get offersInCameraNoiseReduction =>
      this == dslrMirrorless || this == unknown;

  /// Whether a block offers the white-balance and focus-mode records
  /// (ADR-021 C1, C3; AM-04): phones, cameras and Unknown. An astro rig's
  /// block keeps a recorded value and shows it, read-only.
  bool get offersCameraRecords =>
      this == phone || this == dslrMirrorless || this == unknown;
}

/// The sensitivity field a light block shows (ADR-020 §3).
enum LightSensitivity { iso, gain, either }
