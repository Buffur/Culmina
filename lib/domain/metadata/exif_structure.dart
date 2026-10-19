import 'dart:typed_data';

import 'capture_metadata.dart';
import 'exif_values.dart';
import 'metadata_format.dart';
import 'metadata_source.dart';
import 'metadata_value.dart';

/// One EXIF/TIFF structure (a TIFF header, IFD0 and the EXIF IFD it points
/// to), read in a bounded way (ADR-017 §2, §4.3, §13). Every EXIF-bearing
/// container shares it: a DNG is one at offset 0; a JPEG, HEIF or PNG holds
/// one inside a segment, item or chunk, handed over as a
/// [MetadataSourceWindow] so the structure's offsets stay relative to its
/// own header, as EXIF defines them.
///
/// Only the contract's tags are kept. The GPS IFD, sub-IFDs, MakerNotes and
/// pixel data are never followed; a serial number or any other tag outside
/// the contract is never decoded. Every offset and count is checked against
/// the source before it is read.
class ExifStructure {
  ExifStructure._(
    this._source,
    this._endian,
    this._ifd0,
    this._ifd0Offset,
    this._format,
    this._container,
  );

  /// More entries than this in one IFD is treated as corruption (the
  /// owner's DNGs have 60).
  static const maxEntries = 1024;

  /// A text value longer than this is not read (make, model, lens and
  /// times are short).
  static const maxTextBytes = 256;

  final MetadataSource _source;
  final Endian _endian;
  final _Ifd _ifd0;
  final int _ifd0Offset;
  final MetadataFormat _format;
  final String? _container;

  /// Reads the header and IFD0 of the structure at offset 0 of [source].
  /// [format] and [container] label each value's origin: the location reads
  /// "IFD0", or "`container` IFD0" when the structure is embedded.
  ///
  /// Throws [MetadataReadException] or [ExifStructureCorrupt].
  static Future<ExifStructure> open(
    MetadataSource source, {
    required MetadataFormat format,
    String? container,
  }) async {
    if (source.length < 8) {
      throw const MetadataReadException(MetadataReadError.outOfRange);
    }
    final header = ByteData.sublistView(await source.read(0, 8));
    final Endian endian = switch ((header.getUint8(0), header.getUint8(1))) {
      (0x49, 0x49) => Endian.little,
      (0x4D, 0x4D) => Endian.big,
      _ => throw const ExifStructureCorrupt('byte order'),
    };
    if (header.getUint16(2, endian) != 42) {
      throw const ExifStructureCorrupt('magic');
    }
    final ifd0Offset = header.getUint32(4, endian);
    final ifd0 = await _Ifd.read(
      source,
      ifd0Offset,
      endian,
      _label(container, 'IFD0'),
      format,
      isIfd0: true,
    );
    return ExifStructure._(source, endian, ifd0, ifd0Offset, format, container);
  }

  static String _label(String? container, String ifd) =>
      container == null ? ifd : '$container $ifd';

  /// Whether IFD0 carries [tag] (only the contract's tags and
  /// [dngVersionTag] are kept).
  bool hasIfd0Tag(int tag) => _ifd0.entries.containsKey(tag);

  /// Reads the EXIF IFD, if IFD0 points to one, and the contract's values
  /// from both. Throws [MetadataReadException] or [ExifStructureCorrupt].
  Future<CaptureMetadata> extract() async {
    final source = _source;
    _Ifd? exif;
    final exifPointer = _ifd0.entries[_exifIfd];
    if (exifPointer != null) {
      if ((exifPointer.type != _long && exifPointer.type != _ifd) ||
          exifPointer.count != 1) {
        throw const ExifStructureCorrupt('EXIF IFD pointer');
      }
      final offset = exifPointer.inlineUint32(_endian);
      if (offset == _ifd0Offset) {
        throw const ExifStructureCorrupt('EXIF IFD loop');
      }
      exif = await _Ifd.read(
        source,
        offset,
        _endian,
        _label(_container, 'EXIF IFD'),
        _format,
        isIfd0: false,
      );
    }
    final ifds = [_ifd0, ?exif];

    Future<MetadataValue<T>> field<T>(
      Future<MetadataValue<T>> Function(_Ifd ifd) readIn,
    ) async =>
        MetadataValue.combine<T>([for (final ifd in ifds) await readIn(ifd)]);

    return CaptureMetadata(
      exposureSeconds: await field((i) => i.rational(source, 33434)),
      fNumber: await field((i) => i.rational(source, 33437)),
      focalLengthMm: await field((i) => i.rational(source, 37386)),
      focalLength35mmEquivalentMm: await field(
        (i) async => i.short(41989, ExifValues.focalLength35mm),
      ),
      sensitivity: await field((i) async => i.sensitivity()),
      captureTime: await field((i) => i.captureTime(source)),
      cameraMake: await field((i) => i.text(source, 271, ifd0Only: true)),
      cameraModel: await field((i) => i.text(source, 272, ifd0Only: true)),
      uniqueCameraModel: await field(
        (i) => i.text(source, 50708, ifd0Only: true),
      ),
      lensMake: await field((i) => i.text(source, 42035)),
      lensModel: await field((i) => i.text(source, 42036)),
      imageDimensions: _format == MetadataFormat.dng
          ? await _ifd0.dngDimensions(source)
          : MetadataValue.combine([
              _ifd0.pixelPair(256, 257),
              if (exif != null) exif.pixelPair(40962, 40963),
            ]),
      // F04 (ADR-021 C2, C10): a DNG's main-image storage layout from IFD0
      // only (sub-IFDs are never followed), its neutral vector, and the
      // camera's white-balance mode and light source wherever they are.
      bitsPerSample: _format == MetadataFormat.dng && _ifd0.isMainImage
          ? await _ifd0.bitsPerSample(source)
          : const AbsentValue(),
      compression: _format == MetadataFormat.dng && _ifd0.isMainImage
          ? _ifd0.compression()
          : const AbsentValue(),
      asShotNeutral: _format == MetadataFormat.dng
          ? await _ifd0.asShotNeutral(source)
          : const AbsentValue(),
      whiteBalance: await field((i) async => i.exifWhiteBalance()),
      lightSource: await field((i) async => i.lightSource()),
    );
  }
}

/// DNGVersion (50706): kept so a container can tell a DNG (ADR-017 §8).
const dngVersionTag = 50706;
const _exifIfd = 34665;

// TIFF field types (TIFF 6.0 §2; type 13 is the IFD type from TIFF
// Technical Note 1).
const _ascii = 2, _short = 3, _long = 4, _rational = 5, _sRational = 10;
const _ifd = 13;

int _typeSize(int type) => switch (type) {
  1 || 2 || 6 || 7 => 1,
  3 || 8 => 2,
  4 || 9 || 11 || 13 => 4,
  5 || 10 || 12 => 8,
  _ => 0, // unknown type: the entry is skipped
};

/// The contract's tags; nothing else is kept from an IFD, so nothing else can
/// be read (ADR-017 §2–§3).
const _contractTags = {
  271, 272, 50708, dngVersionTag, _exifIfd, // IFD0 only (identity, structure)
  33434, 33437, 34855, 34864, 36867, 36881, 37386, 41989, 42035, 42036,
  // Image dimensions (ADR-018 §3): NewSubfileType, ImageWidth, ImageLength
  // and DefaultCropSize in IFD0; PixelX/YDimension in the EXIF IFD.
  _newSubfileType, 256, 257, _defaultCropSize, 40962, 40963,
  // F04 (ADR-021): BitsPerSample, Compression and AsShotNeutral (IFD0 of a
  // DNG), WhiteBalance and LightSource.
  _bitsPerSample, _compression, _asShotNeutral, _whiteBalance, _lightSource,
};

const _bitsPerSample = 258, _compression = 259, _asShotNeutral = 50728;
const _whiteBalance = 41987, _lightSource = 37384;

const _newSubfileType = 254, _defaultCropSize = 50720;

const _names = {
  271: 'Make',
  272: 'Model',
  33434: 'ExposureTime',
  33437: 'FNumber',
  34855: 'ISOSpeedRatings',
  36867: 'DateTimeOriginal',
  36881: 'OffsetTimeOriginal',
  37386: 'FocalLength',
  41989: 'FocalLengthIn35mmFilm',
  42035: 'LensMake',
  42036: 'LensModel',
  50708: 'UniqueCameraModel',
  _newSubfileType: 'NewSubfileType',
  _defaultCropSize: 'DefaultCropSize',
  _bitsPerSample: 'BitsPerSample',
  _compression: 'Compression',
  _asShotNeutral: 'AsShotNeutral',
  _whiteBalance: 'WhiteBalance',
  _lightSource: 'LightSource',
};

/// The field label of a width/height tag pair.
const _pairNames = {
  256: 'ImageWidth/ImageLength (256/257)',
  40962: 'PixelXDimension/PixelYDimension (40962/40963)',
};

/// The EXIF/TIFF structure is invalid (a loop, a repeated tag, too many
/// entries, a bad header or pointer).
class ExifStructureCorrupt implements Exception {
  const ExifStructureCorrupt(this.why);

  final String why;

  @override
  String toString() => 'corrupt EXIF/TIFF structure: $why';
}

class _Entry {
  _Entry(this.type, this.count, this.valueField);

  final int type;
  final int count;

  /// The 4-byte value/offset field as stored.
  final Uint8List valueField;

  int get size => _typeSize(type) * count;

  int inlineUint32(Endian endian) =>
      ByteData.sublistView(valueField).getUint32(0, endian);
}

class _Ifd {
  _Ifd(this.location, this.endian, this.entries, this.format, this.isIfd0);

  final String location;
  final Endian endian;
  final MetadataFormat format;
  final bool isIfd0;

  /// Contract tags only.
  final Map<int, _Entry> entries;

  static Future<_Ifd> read(
    MetadataSource source,
    int offset,
    Endian endian,
    String location,
    MetadataFormat format, {
    required bool isIfd0,
  }) async {
    final count = ByteData.sublistView(await source.read(offset, 2))
        .getUint16(0, endian);
    if (count > ExifStructure.maxEntries) {
      throw ExifStructureCorrupt('$location has $count entries');
    }
    final table = ByteData.sublistView(
      await source.read(offset + 2, 12 * count),
    );
    final entries = <int, _Entry>{};
    for (var i = 0; i < count; i++) {
      final at = 12 * i;
      final tag = table.getUint16(at, endian);
      if (!_contractTags.contains(tag)) continue;
      if (entries.containsKey(tag)) {
        throw ExifStructureCorrupt('$location repeats tag $tag');
      }
      entries[tag] = _Entry(
        table.getUint16(at + 2, endian),
        table.getUint32(at + 4, endian),
        Uint8List.fromList(
          table.buffer.asUint8List(table.offsetInBytes + at + 8, 4),
        ),
      );
    }
    return _Ifd(location, endian, entries, format, isIfd0);
  }

  MetadataOrigin origin(int tag) => MetadataOrigin(
    format: format,
    field: '${_names[tag] ?? 'Tag'} ($tag)',
    location: location,
  );

  /// The value bytes of [entry], or null when they cannot be read without
  /// leaving the file or reading more than [limit] bytes.
  Future<Uint8List?> _bytes(
    MetadataSource source,
    _Entry entry,
    int limit,
  ) async {
    final size = entry.size;
    if (size == 0 || size > limit) return null;
    if (size <= 4) return Uint8List.sublistView(entry.valueField, 0, size);
    final offset = entry.inlineUint32(endian);
    if (offset + size > source.length) return null;
    return source.read(offset, size);
  }

  UnparseableValue<T> _bad<T>(int tag, _Entry e) => UnparseableValue<T>(
    raw: 'type ${e.type}, count ${e.count}',
    origin: origin(tag),
  );

  Future<MetadataValue<double>> rational(MetadataSource source, int tag) async {
    final e = entries[tag];
    if (e == null) return const AbsentValue();
    if ((e.type != _rational && e.type != _sRational) || e.count != 1) {
      return _bad(tag, e);
    }
    final bytes = await _bytes(source, e, 8);
    if (bytes == null) return _bad(tag, e);
    final data = ByteData.sublistView(bytes);
    final r = e.type == _rational
        ? ExifRational(data.getUint32(0, endian), data.getUint32(4, endian))
        : ExifRational(data.getInt32(0, endian), data.getInt32(4, endian));
    return ExifValues.positive(r, origin(tag));
  }

  /// A single inline SHORT (or LONG), never an array's offset. The contract
  /// holds one value; unsupported counts remain unparseable.
  int? _singleInteger(int tag) {
    final e = entries[tag];
    if (e == null || e.count != 1) return null;
    final data = ByteData.sublistView(e.valueField);
    return switch (e.type) {
      _short => data.getUint16(0, endian),
      _long => data.getUint32(0, endian),
      _ => null,
    };
  }

  MetadataValue<double> short(
    int tag,
    MetadataValue<double> Function(int?, MetadataOrigin) convert,
  ) {
    final e = entries[tag];
    if (e == null) return const AbsentValue();
    final value = _singleInteger(tag);
    if (value == null) return _bad(tag, e);
    return convert(value, origin(tag));
  }

  /// The stored form of a single-integer entry, for a raw text.
  String _rawInteger(int tag) {
    final e = entries[tag];
    if (e == null) return 'missing';
    return '${_singleInteger(tag) ?? 'type ${e.type}, count ${e.count}'}';
  }

  /// A width/height pair of single SHORT or LONG tags (ADR-018 §3): absent
  /// when neither is present; unparseable when one is missing or malformed.
  /// JPEG/HEIC read ImageWidth/ImageLength in IFD0 and
  /// PixelXDimension/PixelYDimension in the EXIF IFD, never the other way.
  MetadataValue<ImageDimensions> pixelPair(int widthTag, int heightTag) {
    final inThisIfd = isIfd0 ? widthTag == 256 : widthTag == 40962;
    if (!inThisIfd) return const AbsentValue();
    if (entries[widthTag] == null && entries[heightTag] == null) {
      return const AbsentValue();
    }
    return ExifValues.dimensions(
      _singleInteger(widthTag),
      _singleInteger(heightTag),
      MetadataOrigin(
        format: format,
        field: _pairNames[widthTag]!,
        location: location,
      ),
      raw: '${_rawInteger(widthTag)} x ${_rawInteger(heightTag)}',
    );
  }

  /// A DNG's image dimensions (ADR-018 §3), from IFD0 only and only when
  /// IFD0 is the main image (NewSubfileType absent or 0): DefaultCropSize
  /// when present and integral, else ImageWidth/ImageLength. A DNG whose
  /// raw image sits in a sub-IFD gives absent dimensions: sub-IFDs are never
  /// followed (ADR-017 §3).
  Future<MetadataValue<ImageDimensions>> dngDimensions(
    MetadataSource source,
  ) async {
    final subfile = entries[_newSubfileType];
    if (subfile != null) {
      final kind = _singleInteger(_newSubfileType);
      if (kind == null) return _bad(_newSubfileType, subfile);
      if (kind != 0) return const AbsentValue();
    }
    final crop = entries[_defaultCropSize];
    if (crop != null) {
      final fromCrop = await _cropSize(source, crop);
      if (fromCrop != null) return fromCrop;
    }
    return pixelPair(256, 257);
  }

  /// DefaultCropSize (two SHORT, LONG or RATIONAL values), or null when its
  /// rationals are not whole numbers, so ImageWidth/ImageLength apply.
  Future<MetadataValue<ImageDimensions>?> _cropSize(
    MetadataSource source,
    _Entry e,
  ) async {
    const tag = _defaultCropSize;
    if (e.count != 2 ||
        (e.type != _short && e.type != _long && e.type != _rational)) {
      return _bad(tag, e);
    }
    final bytes = await _bytes(source, e, 16);
    if (bytes == null) return _bad(tag, e);
    final data = ByteData.sublistView(bytes);
    final List<int> sides;
    switch (e.type) {
      case _short:
        sides = [data.getUint16(0, endian), data.getUint16(2, endian)];
      case _long:
        sides = [data.getUint32(0, endian), data.getUint32(4, endian)];
      default:
        final rationals = [
          for (final at in [0, 8])
            ExifRational(
              data.getUint32(at, endian),
              data.getUint32(at + 4, endian),
            ),
        ];
        if (rationals.any((r) => r.denominator == 0)) return _bad(tag, e);
        if (rationals.any((r) => r.numerator % r.denominator != 0)) {
          return null;
        }
        sides = [for (final r in rationals) r.numerator ~/ r.denominator];
    }
    return ExifValues.dimensions(
      sides[0],
      sides[1],
      origin(tag),
      raw: '${sides[0]} x ${sides[1]}',
    );
  }

  /// Whether this IFD is the main image (NewSubfileType absent or 0).
  bool get isMainImage {
    if (entries[_newSubfileType] == null) return true;
    return _singleInteger(_newSubfileType) == 0;
  }

  /// SHORT or LONG values, at most [maxCount] of them, or null when the
  /// entry has another type or count or cannot be read in bounds.
  Future<List<int>?> _integers(
    MetadataSource source,
    _Entry e,
    int maxCount,
  ) async {
    if ((e.type != _short && e.type != _long) ||
        e.count < 1 ||
        e.count > maxCount) {
      return null;
    }
    final bytes = await _bytes(source, e, 4 * maxCount);
    if (bytes == null) return null;
    final data = ByteData.sublistView(bytes);
    return [
      for (var i = 0; i < e.count; i++)
        e.type == _short
            ? data.getUint16(2 * i, endian)
            : data.getUint32(4 * i, endian),
    ];
  }

  /// BitsPerSample (258): the depth of a one-sample (colour filter array)
  /// main image. More than one sample per pixel is an unsupported layout
  /// (unparseable, F04 A3): the theoretical payload (C10) counts one
  /// sample per pixel, so a three-sample image would be a third of its
  /// size.
  Future<MetadataValue<int>> bitsPerSample(MetadataSource source) async {
    final e = entries[_bitsPerSample];
    if (e == null) return const AbsentValue();
    final values = await _integers(source, e, 4);
    if (values == null) return _bad(_bitsPerSample, e);
    final raw = values.join(' ');
    if (values.length != 1 || values.first < 1 || values.first > 32) {
      return UnparseableValue(raw: raw, origin: origin(_bitsPerSample));
    }
    return KnownValue(values.first, raw: raw, origin: origin(_bitsPerSample));
  }

  /// Compression (259), a single SHORT code.
  MetadataValue<PixelCompression> compression() {
    final e = entries[_compression];
    if (e == null) return const AbsentValue();
    final code = _singleInteger(_compression);
    if (code == null || code == 0) return _bad(_compression, e);
    return KnownValue(
      PixelCompression(code),
      raw: '$code',
      origin: origin(_compression),
    );
  }

  /// AsShotNeutral (50728): one to four positive RATIONAL or SHORT values,
  /// kept as a vector (ADR-021 C2; never a colour temperature).
  Future<MetadataValue<NeutralVector>> asShotNeutral(
    MetadataSource source,
  ) async {
    final e = entries[_asShotNeutral];
    if (e == null || !isIfd0) return const AbsentValue();
    if (e.count < 1 || e.count > 4) return _bad(_asShotNeutral, e);
    final List<ExifRational> parts;
    if (e.type == _rational) {
      final bytes = await _bytes(source, e, 32);
      if (bytes == null) return _bad(_asShotNeutral, e);
      final data = ByteData.sublistView(bytes);
      parts = [
        for (var i = 0; i < e.count; i++)
          ExifRational(
            data.getUint32(8 * i, endian),
            data.getUint32(8 * i + 4, endian),
          ),
      ];
    } else if (e.type == _short) {
      final values = await _integers(source, e, 4);
      if (values == null) return _bad(_asShotNeutral, e);
      parts = [for (final v in values) ExifRational(v, 1)];
    } else {
      return _bad(_asShotNeutral, e);
    }
    final raw = parts.join(' ');
    if (parts.any((r) => r.denominator == 0 || r.numerator == 0)) {
      return UnparseableValue(raw: raw, origin: origin(_asShotNeutral));
    }
    return KnownValue(
      NeutralVector([for (final r in parts) r.numerator / r.denominator]),
      raw: raw,
      origin: origin(_asShotNeutral),
    );
  }

  /// WhiteBalance (41987): 0 auto, 1 manual; any other code unparseable.
  MetadataValue<ExifWhiteBalance> exifWhiteBalance() {
    final e = entries[_whiteBalance];
    if (e == null) return const AbsentValue();
    final code = _singleInteger(_whiteBalance);
    final mode = switch (code) {
      0 => ExifWhiteBalance.auto,
      1 => ExifWhiteBalance.manual,
      _ => null,
    };
    if (mode == null) return _bad(_whiteBalance, e);
    return KnownValue(mode, raw: '$code', origin: origin(_whiteBalance));
  }

  /// LightSource (37384); 0 is EXIF's "unknown", read as absent.
  MetadataValue<LightSource> lightSource() {
    final e = entries[_lightSource];
    if (e == null) return const AbsentValue();
    final code = _singleInteger(_lightSource);
    if (code == null) return _bad(_lightSource, e);
    if (code == 0) return const AbsentValue();
    return KnownValue(
      LightSource(code),
      raw: '$code',
      origin: origin(_lightSource),
    );
  }

  MetadataValue<Sensitivity> sensitivity() {
    final e = entries[34855];
    if (e == null) return const AbsentValue();
    final value = _singleInteger(34855);
    if (value == null) return _bad(34855, e);
    final kind = entries[34864];
    final kindValue = _singleInteger(34864);
    if (kind != null && kindValue == null) return _bad(34864, kind);
    return ExifValues.sensitivity(value, kindValue, origin(34855));
  }

  Future<String?> _asciiText(MetadataSource source, _Entry? e) async {
    if (e == null || e.type != _ascii) return null;
    final bytes = await _bytes(source, e, ExifStructure.maxTextBytes);
    if (bytes == null) return null;
    return String.fromCharCodes([for (final b in bytes) b < 0x80 ? b : 0x3F]);
  }

  Future<MetadataValue<CaptureTime>> captureTime(MetadataSource source) async {
    final e = entries[36867];
    if (e == null) return const AbsentValue();
    final dateTime = await _asciiText(source, e);
    if (dateTime == null) return _bad(36867, e);
    final offset = await _asciiText(source, entries[36881]);
    return ExifValues.captureTime(dateTime, offset, origin(36867));
  }

  Future<MetadataValue<String>> text(
    MetadataSource source,
    int tag, {
    bool ifd0Only = false,
  }) async {
    final e = entries[tag];
    if (e == null || (ifd0Only && !isIfd0)) {
      return const AbsentValue();
    }
    final value = await _asciiText(source, e);
    if (value == null) return _bad(tag, e);
    return ExifValues.text(value, origin(tag));
  }
}
