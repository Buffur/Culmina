import 'dart:convert';

import 'capture_metadata.dart';
import 'capture_metadata_reader.dart';
import 'metadata_format.dart';
import 'metadata_source.dart';
import 'metadata_value.dart';

/// FITS (ADR-021 C21; FITS 4.0 §3–§4; F10): the primary header, read in
/// 2,880-byte records of 36 80-character cards until `END`, within
/// [maxHeaderRecords] and the source's byte budget. Only the primary HDU's
/// image layout is described (C10: two axes, BITPIX 8/16/32/−32/−64);
/// another layout is read and reported as unsupported by
/// [SampleLayout.isSupported], never sized. Values keep their keyword in
/// their origin; nothing is converted: GAIN is the camera's setting (not
/// EGAIN), SET-TEMP is not CCD-TEMP, XPIXSZ is as written (C21: the binned
/// convention is resolved by the import, not here).
class FitsMetadataReader implements MetadataFormatReader {
  const FitsMetadataReader();

  static const recordBytes = 2880;
  static const cardBytes = 80;

  /// The most header records read (36 cards each): far above a capture
  /// program's header (a few records), far below the byte budget.
  static const maxHeaderRecords = 64;

  /// The longest axis read (a sanity bound, not a sensor's): it keeps every
  /// payload product far inside 64-bit integers.
  static const maxAxis = 100000;

  @override
  Set<MetadataFormat> get formats => const {MetadataFormat.fits};

  @override
  Future<MetadataReading> read(MetadataSource source) async {
    final cards = <String, _Card>{};
    final duplicates = <String>{};
    var records = 0;
    var ended = false;
    try {
      while (!ended) {
        if (records == maxHeaderRecords) {
          return const MetadataUnreadable(
            MetadataUnreadableReason.corrupt,
            'no END within the header limit',
            MetadataFormat.fits,
          );
        }
        final offset = records * recordBytes;
        if (offset + recordBytes > source.length) {
          return const MetadataUnreadable(
            MetadataUnreadableReason.truncated,
            'the header ends before END',
            MetadataFormat.fits,
          );
        }
        final bytes = await source.read(offset, recordBytes);
        records++;
        for (var i = 0; i < recordBytes; i += cardBytes) {
          final text = latin1.decode(bytes.sublist(i, i + cardBytes));
          final keyword = text.substring(0, 8).trimRight();
          if (keyword == 'END') {
            ended = true;
            break;
          }
          if (text.length < 10 || text.substring(8, 10) != '= ') continue;
          final card = _Card.parse(keyword, text.substring(10));
          if (card == null) continue;
          if (cards.containsKey(keyword)) duplicates.add(keyword);
          cards[keyword] = card;
        }
      }
    } on MetadataReadException catch (e) {
      return MetadataUnreadable.fromReadFailure(e, format: MetadataFormat.fits);
    }
    return MetadataRead(
      MetadataFormat.fits,
      _contract(cards, duplicates, records),
    );
  }

  static CaptureMetadata _contract(
    Map<String, _Card> cards,
    Set<String> duplicates,
    int records,
  ) {
    MetadataOrigin origin(String keyword, {bool software = false}) =>
        MetadataOrigin(
          format: MetadataFormat.fits,
          location: 'primary header',
          field: keyword,
          provenance: software
              ? MetadataProvenance.softwareSetting
              : MetadataProvenance.captureDevice,
        );

    MetadataValue<T> value<T>(
      String keyword,
      T? Function(_Card) read, {
      bool Function(T)? plausible,
      bool software = false,
    }) {
      final card = cards[keyword];
      if (card == null) return const AbsentValue();
      final o = origin(keyword, software: software);
      if (duplicates.contains(keyword)) {
        return UnparseableValue(raw: card.raw, origin: o);
      }
      final v = read(card);
      if (v == null || (plausible != null && !plausible(v))) {
        return UnparseableValue(raw: card.raw, origin: o);
      }
      return KnownValue(v, raw: card.raw, origin: o);
    }

    MetadataValue<double> number(
      String k, {
      bool Function(double)? plausible,
      bool software = false,
    }) => value(k, (c) => c.number, plausible: plausible, software: software);
    MetadataValue<String> text(String k) =>
        value(k, (c) => c.text?.trim().isEmpty ?? true ? null : c.text!.trim());
    MetadataValue<int> whole(String k, {bool Function(int)? plausible}) =>
        value(k, (c) => c.integer, plausible: plausible);

    // EXPTIME, else EXPOSURE; both and different: a visible conflict.
    final exptime = number('EXPTIME', plausible: (v) => v > 0);
    final exposure = number('EXPOSURE', plausible: (v) => v > 0);
    final MetadataValue<double> seconds = switch ((exptime, exposure)) {
      (
        KnownValue(value: final a, raw: final ra, origin: final oa),
        KnownValue(value: final b, raw: final rb, origin: final ob),
      ) =>
        a == b
            ? exptime
            : AmbiguousValue([(raw: ra, origin: oa), (raw: rb, origin: ob)]),
      (AbsentValue(), _) => exposure,
      _ => exptime,
    };

    MetadataValue<T> pair<T>(
      String xKey,
      String yKey,
      T Function(double x, double y) make,
      bool Function(double) plausible,
    ) {
      final x = number(xKey, plausible: plausible);
      final y = number(yKey, plausible: plausible);
      return switch ((x, y)) {
        (
          KnownValue(value: final xv, raw: final xr, origin: final o),
          KnownValue(value: final yv, raw: final yr),
        ) =>
          KnownValue(make(xv, yv), raw: '$xr $yr', origin: o),
        // Only the X axis written: the writer means square (FITS practice).
        (
          KnownValue(value: final xv, raw: final xr, origin: final o),
          AbsentValue(),
        ) =>
          KnownValue(make(xv, xv), raw: xr, origin: o),
        (AbsentValue(), AbsentValue()) => const AbsentValue(),
        (UnparseableValue(raw: final r, origin: final o), _) ||
        (_, UnparseableValue(raw: final r, origin: final o)) ||
        (
          AbsentValue(),
          KnownValue(raw: final r, origin: final o),
        ) => UnparseableValue(raw: r, origin: o),
        _ => const AbsentValue(),
      };
    }

    final bitpix = whole('BITPIX');
    final naxis = whole('NAXIS', plausible: (n) => n >= 0 && n <= 999);
    final axes = <int>[];
    var axesKnown = naxis is KnownValue<int>;
    if (naxis case KnownValue(:final value)) {
      for (var i = 1; i <= value; i++) {
        final a = whole('NAXIS$i', plausible: (n) => n >= 0 && n <= maxAxis);
        if (a case KnownValue(value: final n)) {
          axes.add(n);
        } else {
          axesKnown = false;
        }
      }
    }
    final MetadataValue<SampleLayout> layout = switch (bitpix) {
      KnownValue(:final value, :final raw, :final origin) when axesKnown =>
        KnownValue(
          SampleLayout(bitpix: value, axes: axes, headerRecords: records),
          raw: '$raw ${axes.join(' ')}',
          origin: origin,
        ),
      AbsentValue() => const AbsentValue(),
      _ => UnparseableValue(
        raw: cards['BITPIX']?.raw ?? '',
        origin: origin('BITPIX'),
      ),
    };
    final MetadataValue<ImageDimensions> dims =
        axes.length == 2 && axesKnown && axes.every((a) => a > 0)
        ? KnownValue(
            ImageDimensions(axes[0], axes[1]),
            raw: '${axes[0]} ${axes[1]}',
            origin: origin('NAXIS1'),
          )
        : const AbsentValue();

    return CaptureMetadata(
      exposureSeconds: seconds,
      captureTime: value('DATE-OBS', (c) => _utc(c.text)),
      cameraModel: text('INSTRUME'),
      telescope: text('TELESCOP'),
      filterName: text('FILTER'),
      focalLengthMm: number(
        'FOCALLEN',
        plausible: (v) => v > 0,
        software: true,
      ),
      imageDimensions: dims,
      bitsPerSample: switch (bitpix) {
        KnownValue(:final value, :final raw, :final origin)
            when const [8, 16, 32, -32, -64].contains(value) =>
          KnownValue(value.abs(), raw: raw, origin: origin),
        AbsentValue() => const AbsentValue(),
        _ => UnparseableValue(
          raw: cards['BITPIX']?.raw ?? '',
          origin: origin('BITPIX'),
        ),
      },
      sampleLayout: layout,
      pixelSizeUm: pair(
        'XPIXSZ',
        'YPIXSZ',
        (x, y) => PixelSize(x, y),
        (v) => v > 0 && v < 100,
      ),
      binning: pair(
        'XBINNING',
        'YBINNING',
        (x, y) => SensorBinning(x.round(), y.round()),
        (v) => v >= 1 && v <= 16 && v == v.roundToDouble(),
      ),
      acquisitionGain: number('GAIN', plausible: (v) => v >= 0),
      conversionGainElectronsPerAdu: number('EGAIN', plausible: (v) => v > 0),
      offset: number('OFFSET', plausible: (v) => v >= 0),
      sensorTemperatureC: number('CCD-TEMP', plausible: (v) => v > -273.15),
      setpointTemperatureC: number('SET-TEMP', plausible: (v) => v > -273.15),
    );
  }

  /// DATE-OBS as UTC (FITS 4.0 §9.1.1: UTC unless TIMESYS says otherwise;
  /// capture programs write UTC). Seconds are truncated.
  static CaptureTime? _utc(String? text) {
    final m = RegExp(
      r'^(\d{4})-(\d{2})-(\d{2})(?:T(\d{2}):(\d{2}):(\d{2})(?:\.\d+)?)?$',
    ).firstMatch(text?.trim() ?? '');
    if (m == null) return null;
    int g(int i) => int.parse(m.group(i) ?? '0');
    return CaptureTime(
      year: g(1),
      month: g(2),
      day: g(3),
      hour: g(4),
      minute: g(5),
      second: g(6),
      utcOffset: Duration.zero,
    );
  }
}

/// One `KEYWORD = value / comment` card's value (FITS 4.0 §4.2).
class _Card {
  const _Card(this.raw, {this.text, this.number, this.integer});

  final String raw;
  final String? text;
  final double? number;
  final int? integer;

  static _Card? parse(String keyword, String field) {
    final t = field.trimLeft();
    if (t.startsWith("'")) {
      // A string: '' is a quote; trailing spaces are not significant.
      final out = StringBuffer();
      var i = 1;
      while (i < t.length) {
        if (t[i] == "'") {
          if (i + 1 < t.length && t[i + 1] == "'") {
            out.write("'");
            i += 2;
            continue;
          }
          final s = out.toString().trimRight();
          return _Card(s, text: s);
        }
        out.write(t[i]);
        i++;
      }
      return null; // an unterminated string
    }
    final slash = t.indexOf('/');
    final v = (slash < 0 ? t : t.substring(0, slash)).trim();
    if (v.isEmpty) return null;
    if (v == 'T' || v == 'F') return _Card(v, text: v);
    final integer = int.tryParse(v);
    final number = double.tryParse(v.replaceAll(RegExp('[dD]'), 'E'));
    if (number == null || !number.isFinite) return _Card(v);
    return _Card(v, number: number, integer: integer);
  }
}
