// F04 (ADR-021 C2, C6, C10, C21): the extended typed contract. Each new value
// keeps its tag in its origin; absent, contradictory, invalid and unsupported
// values are explicit; a neutral vector stays a vector and nothing invents a
// colour temperature; reads stay bounded; the FITS types exist for F10.

import 'dart:typed_data';

import 'package:astroplan/domain/metadata/capture_metadata.dart';
import 'package:astroplan/domain/metadata/capture_metadata_reader.dart';
import 'package:astroplan/domain/metadata/metadata_format.dart';
import 'package:astroplan/domain/metadata/metadata_source.dart';
import 'package:astroplan/domain/metadata/metadata_value.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/heif_fixture.dart';
import '../../support/jpeg_fixture.dart';
import '../../support/memory_metadata_source.dart';
import '../../support/tiff_fixture.dart';

Future<(CaptureMetadata, BudgetedMetadataSource)> _read(
  Uint8List bytes, {
  int? length,
}) async {
  final source = BudgetedMetadataSource(
    MemoryMetadataSource(bytes, length: length),
  );
  final reading = await CaptureMetadataReader.read(source);
  expect(reading, isA<MetadataRead>());
  return ((reading as MetadataRead).metadata, source);
}

/// The phone-style DNG with [replace]'s tags put in place of its own.
Uint8List _dng(List<FixtureEntry> replace, {List<int> drop = const []}) {
  final tags = {for (final e in replace) e.tag};
  final ifd0 = [
    for (final e in phoneStyleDngIfd0())
      if (!tags.contains(e.tag) && !drop.contains(e.tag)) e,
    ...replace,
  ];
  return (TiffFixture()..ifd0.addAll(ifd0)).build().bytes;
}

void main() {
  group('DNG storage layout (258, 259)', () {
    test('known, with tag-level origins', () async {
      final (m, _) = await _read(_dng([]), length: 25 << 20);
      expect(m.bitsPerSample.valueOrNull, 16);
      expect(
        (m.bitsPerSample as KnownValue).origin,
        const MetadataOrigin(
          format: MetadataFormat.dng,
          field: 'BitsPerSample (258)',
          location: 'IFD0',
        ),
      );
      expect(m.compression.valueOrNull, const PixelCompression(1));
      expect(m.compression.valueOrNull!.kind, PixelCompressionKind.none);
      expect((m.compression as KnownValue).origin.field, 'Compression (259)');
    });

    test('one sample is one depth; more than one sample per pixel is an '
        'unsupported layout', () async {
      var (m, _) = await _read(
        _dng([
          FixtureEntry.shorts(258, [14]),
        ]),
      );
      expect(m.bitsPerSample.valueOrNull, 14);
      // Three samples (a linear, demosaiced DNG): a one-sample payload
      // would be a third of the file's pixel data.
      (m, _) = await _read(
        _dng([
          FixtureEntry.shorts(258, [16, 16, 16]),
        ]),
      );
      expect(m.bitsPerSample, isA<UnparseableValue<int>>());
      expect((m.bitsPerSample as UnparseableValue).raw, '16 16 16');
      (m, _) = await _read(
        _dng([
          FixtureEntry.shorts(258, [16, 12, 16]),
        ]),
      );
      expect(m.bitsPerSample, isA<UnparseableValue<int>>());
      expect((m.bitsPerSample as UnparseableValue).raw, '16 12 16');
    });

    test('compression codes are explicit, unknown ones too', () async {
      for (final (code, kind) in [
        (7, PixelCompressionKind.lossless),
        (8, PixelCompressionKind.lossless),
        (34892, PixelCompressionKind.lossy),
        (52546, PixelCompressionKind.unknown),
        (32767, PixelCompressionKind.unknown),
      ]) {
        final (m, _) = await _read(_dng([FixtureEntry.short(259, code)]));
        expect(m.compression.valueOrNull?.code, code);
        expect(m.compression.valueOrNull?.kind, kind, reason: '$code');
      }
      final (m, _) = await _read(_dng([FixtureEntry.short(259, 0)]));
      expect(m.compression, isA<UnparseableValue<PixelCompression>>());
    });

    test('absent tags are absent; a preview IFD0 gives no layout', () async {
      var (m, _) = await _read(_dng([], drop: [258, 259]));
      expect(m.bitsPerSample, isA<AbsentValue<int>>());
      expect(m.compression, isA<AbsentValue<PixelCompression>>());
      (m, _) = await _read(_dng([FixtureEntry.long(254, 1)]));
      expect(m.bitsPerSample, isA<AbsentValue<int>>());
      expect(m.compression, isA<AbsentValue<PixelCompression>>());
    });
  });

  group('AsShotNeutral (50728) stays a vector', () {
    test('rationals', () async {
      final (m, _) = await _read(
        _dng([
          FixtureEntry.rationals(50728, [(4700, 10000), (1, 1), (6200, 10000)]),
        ]),
      );
      expect(m.asShotNeutral.valueOrNull, NeutralVector([0.47, 1, 0.62]));
      expect((m.asShotNeutral as KnownValue).raw, '4700/10000 1/1 6200/10000');
      expect(
        (m.asShotNeutral as KnownValue).origin.field,
        'AsShotNeutral (50728)',
      );
      // C2: nothing is converted to kelvins or a block's white balance.
      expect(m.whiteBalance, isA<AbsentValue<ExifWhiteBalance>>());
    });

    test('a zero value or denominator is unparseable', () async {
      final (m, _) = await _read(
        _dng([
          FixtureEntry.rationals(50728, [(1, 0), (1, 1), (1, 2)]),
        ]),
      );
      expect(m.asShotNeutral, isA<UnparseableValue<NeutralVector>>());
    });

    test('a JPEG never carries one', () async {
      final exif = phoneStyleJpegExif()
        ..ifd0.add(FixtureEntry.rationals(50728, [(1, 2), (1, 1), (1, 2)]));
      final (m, _) = await _read(jpegFile([exifApp1(exif.build().bytes)]));
      expect(m.asShotNeutral, isA<AbsentValue<NeutralVector>>());
    });
  });

  group('EXIF WhiteBalance (41987) and LightSource (37384)', () {
    Future<CaptureMetadata> jpeg(List<FixtureEntry> extra) async {
      final exif = phoneStyleJpegExif()..exif!.addAll(extra);
      return (await _read(jpegFile([exifApp1(exif.build().bytes)]))).$1;
    }

    test('auto and manual, with their origins; no kelvins anywhere', () async {
      var m = await jpeg([FixtureEntry.short(41987, 0)]);
      expect(m.whiteBalance.valueOrNull, ExifWhiteBalance.auto);
      expect(
        (m.whiteBalance as KnownValue).origin,
        const MetadataOrigin(
          format: MetadataFormat.jpeg,
          field: 'WhiteBalance (41987)',
          location: 'APP1 EXIF IFD',
        ),
      );
      m = await jpeg([FixtureEntry.short(41987, 1)]);
      expect(m.whiteBalance.valueOrNull, ExifWhiteBalance.manual);
      m = await jpeg([FixtureEntry.short(41987, 2)]);
      expect(m.whiteBalance, isA<UnparseableValue<ExifWhiteBalance>>());
    });

    test('a light source is named; 0 (unknown) is absent', () async {
      var m = await jpeg([FixtureEntry.short(37384, 10)]);
      expect(m.lightSource.valueOrNull, const LightSource(10));
      expect(m.lightSource.valueOrNull!.name, 'Cloudy weather');
      m = await jpeg([FixtureEntry.short(37384, 0)]);
      expect(m.lightSource, isA<AbsentValue<LightSource>>());
      m = await jpeg([FixtureEntry.short(37384, 200)]);
      expect(m.lightSource.valueOrNull!.name, 'Light source 200');
    });

    test('in both IFDs with different values: contradictory', () async {
      final exif = phoneStyleJpegExif()
        ..ifd0.add(FixtureEntry.short(41987, 0))
        ..exif!.add(FixtureEntry.short(41987, 1));
      final (m, _) = await _read(jpegFile([exifApp1(exif.build().bytes)]));
      expect(m.whiteBalance, isA<AmbiguousValue<ExifWhiteBalance>>());
    });

    test('the JPEG layout tags (258, 259) are not a raw layout', () async {
      final exif = phoneStyleJpegExif()
        ..ifd0.addAll([FixtureEntry.short(258, 8), FixtureEntry.short(259, 6)]);
      final (m, _) = await _read(jpegFile([exifApp1(exif.build().bytes)]));
      expect(m.bitsPerSample, isA<AbsentValue<int>>());
      expect(m.compression, isA<AbsentValue<PixelCompression>>());
    });
  });

  test('a HEIC carries the same white-balance mode, never a layout or a '
      'neutral vector', () async {
    final exif =
        (TiffFixture()
              ..ifd0.addAll([
                FixtureEntry.ascii(271, 'TestMake'),
                FixtureEntry.short(258, 8),
              ])
              ..exif = [
                FixtureEntry.short(41987, 1),
                FixtureEntry.short(37384, 21),
              ])
            .build()
            .bytes;
    final (m, _) = await _read((HeifFixture()..addExif(2, exif)).build());
    expect(m.whiteBalance.valueOrNull, ExifWhiteBalance.manual);
    expect((m.whiteBalance as KnownValue).origin.format, MetadataFormat.heif);
    expect(m.lightSource.valueOrNull?.name, 'D65');
    expect(m.bitsPerSample, isA<AbsentValue<int>>());
    expect(m.asShotNeutral, isA<AbsentValue<NeutralVector>>());
  });

  test(
    'reads stay bounded: the new values read only their own bytes',
    () async {
      final tiff =
          (TiffFixture()
                ..ifd0.addAll([
                  for (final e in phoneStyleDngIfd0())
                    if (e.tag != 258) e,
                  FixtureEntry.shorts(258, [16, 16, 16]),
                  FixtureEntry.rationals(50728, [(1, 2), (1, 1), (1, 2)]),
                ]))
              .build();
      final (_, source) = await _read(tiff.bytes, length: 25 << 20);
      final total = source.reads.fold(0, (sum, r) => sum + r.count);
      expect(total, lessThan(BudgetedMetadataSource.defaultBudgetBytes));
      expect(
        source.reads.every((r) => r.offset + r.count <= tiff.bytes.length),
        isTrue,
      );
    },
  );

  group('the common FITS types (for F10)', () {
    test('binning, pixel size and layout state what they are', () {
      expect(const SensorBinning(2, 2).isSymmetric, isTrue);
      expect(const SensorBinning(2, 1).isSymmetric, isFalse);
      expect(const PixelSize(3.76, 3.76).isSquare, isTrue);
      expect(SampleLayout(bitpix: 16, axes: [6248, 4176]).isSupported, isTrue);
      expect(SampleLayout(bitpix: 16, axes: [6248, 4176]).bytesPerSample, 2);
      expect(SampleLayout(bitpix: -32, axes: [10, 10]).bytesPerSample, 4);
      expect(SampleLayout(bitpix: 16, axes: [10, 10, 3]).isSupported, isFalse);
      expect(SampleLayout(bitpix: 12, axes: [10, 10]).isSupported, isFalse);
    });

    test(
      'a reading without FITS keywords leaves every FITS field absent',
      () async {
        final (m, _) = await _read(_dng([]), length: 25 << 20);
        for (final v in [
          m.pixelSizeUm,
          m.binning,
          m.acquisitionGain,
          m.conversionGainElectronsPerAdu,
          m.offset,
          m.sensorTemperatureC,
          m.setpointTemperatureC,
          m.filterName,
          m.telescope,
          m.sampleLayout,
        ]) {
          expect(v, isA<AbsentValue>());
        }
      },
    );
  });
}
