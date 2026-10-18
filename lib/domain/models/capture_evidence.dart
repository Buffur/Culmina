import 'dart:convert';

/// The recorded capture settings and their evidence (ADR-021, F03): white
/// balance (C1), focus mode (C3), per-field origins (C4/C5) and file
/// evidence (C6), plus a rig's capture format (C7). Each is optional: absent
/// means *unrecorded*, never a default (shared rule 6). Values that cannot
/// be read back (an unknown stored name, a newer app's value) read as
/// unrecorded, never as something else (the future-enum rule).

/// C1: how the white balance was set.
enum WhiteBalanceMode {
  auto,
  preset,
  kelvin,
  custom;

  static WhiteBalanceMode? tryParse(Object? stored) => _byName(values, stored);
}

/// C1: a white-balance preset, for [WhiteBalanceMode.preset] only.
enum WhiteBalancePreset {
  daylight,
  cloudy,
  shade,
  tungsten,
  fluorescent,
  flash;

  static WhiteBalancePreset? tryParse(Object? stored) =>
      _byName(values, stored);
}

/// C1: a block's white balance, as the camera was set. Descriptive only: no
/// calculation, calibration identity or control uses it (ADR-021 C15).
class WhiteBalance {
  const WhiteBalance._(this.mode, this.preset, this.kelvinK, this.tint);

  /// Sanity bounds, not a device's range (C1).
  static const int minKelvin = 1000;
  static const int maxKelvin = 40000;
  static const double maxAbsTint = 1000;

  factory WhiteBalance.auto() =>
      const WhiteBalance._(WhiteBalanceMode.auto, null, null, null);

  factory WhiteBalance.preset(WhiteBalancePreset preset, {double? tint}) =>
      WhiteBalance._(WhiteBalanceMode.preset, preset, null, _tint(tint));

  factory WhiteBalance.kelvin(int kelvin, {double? tint}) {
    if (kelvin < minKelvin || kelvin > maxKelvin) {
      throw ArgumentError.value(
        kelvin,
        'kelvin',
        'must be in [$minKelvin, $maxKelvin] K',
      );
    }
    return WhiteBalance._(WhiteBalanceMode.kelvin, null, kelvin, _tint(tint));
  }

  factory WhiteBalance.custom({double? tint}) =>
      WhiteBalance._(WhiteBalanceMode.custom, null, null, _tint(tint));

  static double? _tint(double? tint) {
    if (tint == null) return null;
    if (!tint.isFinite || tint.abs() > maxAbsTint) {
      throw ArgumentError.value(tint, 'tint', 'must be in ±$maxAbsTint');
    }
    return tint;
  }

  /// From the stored columns; null (unrecorded) when the mode is absent or
  /// unknown, or its value is missing or out of bounds.
  static WhiteBalance? fromStored(
    Object? mode,
    Object? preset,
    Object? kelvin,
    Object? tint,
  ) {
    final m = WhiteBalanceMode.tryParse(mode);
    final t = tint is num ? tint.toDouble() : null;
    try {
      return switch (m) {
        null => null,
        WhiteBalanceMode.auto => WhiteBalance.auto(),
        WhiteBalanceMode.preset => switch (WhiteBalancePreset.tryParse(
          preset,
        )) {
          final p? => WhiteBalance.preset(p, tint: t),
          null => null,
        },
        WhiteBalanceMode.kelvin =>
          kelvin is num ? WhiteBalance.kelvin(kelvin.round(), tint: t) : null,
        WhiteBalanceMode.custom => WhiteBalance.custom(tint: t),
      };
    } on ArgumentError {
      return null;
    }
  }

  /// The snapshot form (C17): `{mode, preset, kelvinK, tint}`.
  static WhiteBalance? fromJson(Object? json) => json is Map
      ? fromStored(json['mode'], json['preset'], json['kelvinK'], json['tint'])
      : null;

  final WhiteBalanceMode mode;
  final WhiteBalancePreset? preset;
  final int? kelvinK;
  final double? tint;

  Map<String, Object?> toJson() => {
    'mode': mode.name,
    'preset': preset?.name,
    'kelvinK': kelvinK,
    'tint': tint,
  };

  @override
  bool operator ==(Object other) =>
      other is WhiteBalance &&
      mode == other.mode &&
      preset == other.preset &&
      kelvinK == other.kelvinK &&
      tint == other.tint;

  @override
  int get hashCode => Object.hash(mode, preset, kelvinK, tint);

  @override
  String toString() => 'WhiteBalance(${toJson()})';
}

/// C3 (AM-04): how the camera was focused. A descriptive record only: never
/// a numeric focus value, a control command, inferred from a file, or part
/// of timing or calibration identity.
enum FocusMode {
  af,
  mf;

  static FocusMode? tryParse(Object? stored) => _byName(values, stored);
}

/// C4: how a block field got its value.
enum OriginKind {
  entered,

  /// Copied from another block.
  copied,

  /// A calibration value inherited from the lights.
  inherited,

  /// Read from a file the user picked.
  file,

  /// Declared by the user as a fact (a format, a size).
  declared;

  static OriginKind? tryParse(Object? stored) => _byName(values, stored);
}

/// C4: the block fields an origin can be recorded for.
enum CaptureField {
  frameType,
  filter,
  exposure,
  count,
  sensitivity,
  binning,
  wb,
  focusMode,
  fileSize;

  static CaptureField? tryParse(Object? stored) => _byName(values, stored);
}

/// C4/C5: one field's origin. [descriptor] is fixed when the value was
/// accepted ("from the Ha block · 300 s", "IMG_0845.dng"): at most 80
/// characters, a file's basename only. [evidence] is an optional small map
/// of plain values (a tag name, a vector). No live link to a source.
class FieldOrigin {
  FieldOrigin(this.kind, String descriptor, {Map<String, Object?>? evidence})
    : descriptor = _descriptor(descriptor),
      evidence = evidence == null ? null : Map.unmodifiable(evidence);

  static const int maxDescriptorLength = 80;

  static String _descriptor(String text) {
    final t = text.trim();
    if (t.isEmpty) {
      throw ArgumentError.value(text, 'descriptor', 'must not be empty');
    }
    return t.length <= maxDescriptorLength
        ? t
        : t.substring(0, maxDescriptorLength);
  }

  /// The user typed or chose it.
  static FieldOrigin entered() => FieldOrigin(OriginKind.entered, 'entered');

  final OriginKind kind;
  final String descriptor;
  final Map<String, Object?>? evidence;

  Map<String, Object?> toJson() => {
    'k': kind.name,
    'd': descriptor,
    if (evidence != null) 'e': evidence,
  };

  /// Null when unreadable: an unknown kind or no descriptor.
  static FieldOrigin? fromJson(Object? json) {
    if (json is! Map) return null;
    final kind = OriginKind.tryParse(json['k']);
    final d = json['d'];
    final e = json['e'];
    if (kind == null || d is! String || d.trim().isEmpty) return null;
    return FieldOrigin(
      kind,
      d,
      evidence: e is Map ? e.cast<String, Object?>() : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is FieldOrigin &&
      kind == other.kind &&
      descriptor == other.descriptor &&
      jsonEncode(evidence) == jsonEncode(other.evidence);

  @override
  int get hashCode => Object.hash(kind, descriptor, jsonEncode(evidence));

  @override
  String toString() => 'FieldOrigin(${toJson()})';
}

/// C4: a block's recorded field origins. A field without an entry is
/// *unrecorded*, never [OriginKind.entered]; a legacy block has none.
class FieldOrigins {
  FieldOrigins([Map<CaptureField, FieldOrigin> origins = const {}])
    : _origins = Map.unmodifiable(origins);

  static final FieldOrigins none = FieldOrigins();

  final Map<CaptureField, FieldOrigin> _origins;

  Map<CaptureField, FieldOrigin> get all => _origins;
  bool get isEmpty => _origins.isEmpty;

  FieldOrigin? operator [](CaptureField field) => _origins[field];

  /// With [field]'s origin replaced (null removes it: unrecorded).
  FieldOrigins withOrigin(CaptureField field, FieldOrigin? origin) {
    final next = Map.of(_origins);
    if (origin == null) {
      next.remove(field);
    } else {
      next[field] = origin;
    }
    return FieldOrigins(next);
  }

  /// A user edit of [field]: its origin becomes [OriginKind.entered]; the
  /// other fields keep theirs (C4).
  FieldOrigins edited(CaptureField field) =>
      withOrigin(field, FieldOrigin.entered());

  Map<String, Object?> toJson() => {
    for (final e in _origins.entries) e.key.name: e.value.toJson(),
  };

  /// Tolerant: an unknown field or unreadable origin is skipped.
  static FieldOrigins fromJson(Object? json) {
    if (json is! Map) return none;
    final read = <CaptureField, FieldOrigin>{};
    for (final e in json.entries) {
      final field = CaptureField.tryParse(e.key);
      final origin = FieldOrigin.fromJson(e.value);
      if (field != null && origin != null) read[field] = origin;
    }
    return FieldOrigins(read);
  }

  /// The column text: null when there is nothing recorded.
  String? encode() => isEmpty ? null : jsonEncode(toJson());

  static FieldOrigins decode(String? text) {
    if (text == null || text.isEmpty) return none;
    try {
      return fromJson(jsonDecode(text));
    } on FormatException {
      return none;
    }
  }

  @override
  bool operator ==(Object other) =>
      other is FieldOrigins &&
      _origins.length == other._origins.length &&
      _origins.entries.every((e) => other._origins[e.key] == e.value);

  @override
  int get hashCode => Object.hashAllUnordered(
    _origins.entries.map((e) => Object.hash(e.key, e.value)),
  );

  @override
  String toString() => 'FieldOrigins(${toJson()})';
}

/// C6: how a file's pixels are stored, when it was read.
enum FileCompression {
  none,
  lossless,
  lossy,
  unknown;

  static FileCompression? tryParse(Object? stored) => _byName(values, stored);
}

/// C6/C12: one picked file's evidence for a block's or a rig's storage.
/// [bytes] is the file's length, used as it is (never rescaled, C9).
/// [format] is `dng`, `jpeg`, `heic`, `fits`, `tiff`, or
/// `recognized:<ext>` for a recognized file that was not read. An unread
/// file ([read] false, D3 A) carries no dimensions or compression.
class FileEvidence {
  FileEvidence({
    required this.bytes,
    required String format,
    required this.read,
    int? width,
    int? height,
    this.bitsPerSample,
    FileCompression? compression,
    this.binning,
    required String label,
  }) : format = _format(format),
       width = read ? width : null,
       height = read ? height : null,
       compression = read ? compression : null,
       label = basename(label) {
    if (bytes <= 0) {
      throw ArgumentError.value(bytes, 'bytes', 'must be > 0');
    }
    for (final (name, v) in [
      ('width', this.width),
      ('height', this.height),
      ('bitsPerSample', bitsPerSample),
      ('binning', binning),
    ]) {
      if (v != null && v <= 0) {
        throw ArgumentError.value(v, name, 'must be > 0');
      }
    }
    if (this.label.isEmpty) {
      throw ArgumentError.value(label, 'label', 'must name the file');
    }
  }

  static const List<String> readFormats = [
    'dng',
    'jpeg',
    'heic',
    'fits',
    'tiff',
  ];

  static String _format(String format) {
    final f = format.trim().toLowerCase();
    if (readFormats.contains(f)) return f;
    if (f.startsWith('recognized:') && f.length > 'recognized:'.length) {
      return f;
    }
    throw ArgumentError.value(format, 'format', 'unknown file format');
  }

  /// C5: the last path segment only, never a path or URI.
  static String basename(String name) {
    final t = name.trim();
    final cut = t.lastIndexOf(RegExp(r'[/\\]'));
    return (cut < 0 ? t : t.substring(cut + 1)).trim();
  }

  final int bytes;
  final String format;
  final bool read;
  final int? width;
  final int? height;
  final int? bitsPerSample;
  final FileCompression? compression;
  final int? binning;
  final String label;

  Map<String, Object?> toJson() => {
    'bytes': bytes,
    'format': format,
    'read': read,
    'width': width,
    'height': height,
    'bitsPerSample': bitsPerSample,
    'compression': compression?.name,
    'binning': binning,
    'label': label,
  };

  /// Null when unreadable (a missing or invalid required value).
  static FileEvidence? fromJson(Object? json) {
    if (json is! Map) return null;
    final bytes = json['bytes'];
    final format = json['format'];
    final read = json['read'];
    final label = json['label'];
    if (bytes is! int || format is! String || read is! bool) return null;
    if (label is! String) return null;
    int? opt(Object? v) => v is int ? v : null;
    try {
      return FileEvidence(
        bytes: bytes,
        format: format,
        read: read,
        width: opt(json['width']),
        height: opt(json['height']),
        bitsPerSample: opt(json['bitsPerSample']),
        compression: FileCompression.tryParse(json['compression']),
        binning: opt(json['binning']),
        label: label,
      );
    } on ArgumentError {
      return null;
    }
  }

  String encode() => jsonEncode(toJson());

  static FileEvidence? decode(String? text) {
    if (text == null || text.isEmpty) return null;
    try {
      return fromJson(jsonDecode(text));
    } on FormatException {
      return null;
    }
  }

  @override
  bool operator ==(Object other) =>
      other is FileEvidence &&
      jsonEncode(toJson()) == jsonEncode(other.toJson());

  @override
  int get hashCode => jsonEncode(toJson()).hashCode;

  @override
  String toString() => 'FileEvidence(${toJson()})';
}

/// C7 (PD-06): a rig's capture format, the only formats with a defined
/// theoretical-size rule (C10) plus the two without one.
enum CaptureFormat {
  dngUncompressed16,
  fits16,
  fits32float,
  compressedRaw,
  jpegHeic;

  static CaptureFormat? tryParse(Object? stored) => _byName(values, stored);
}

T? _byName<T extends Enum>(List<T> values, Object? name) {
  for (final v in values) {
    if (v.name == name) return v;
  }
  return null;
}
