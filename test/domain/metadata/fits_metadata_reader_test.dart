// F10 A1/A2 (ADR-021 C10/C11/C21) on synthetic headers: FITS cards are read
// in 2,880-byte records up to END, within the record and byte limits. Each
// value keeps its keyword. Floating BITPIX, conflicting exposures, an
// arbitrary FILTER and absent or asymmetric binning have stated outcomes.
// Binned and unbinned writers give the same native rig geometry,
// normalized once. An unsupported layout is said, never sized.

import 'package:astroplan/domain/equipment_import/equipment_candidate.dart';
import 'package:astroplan/domain/metadata/capture_metadata.dart';
import 'package:astroplan/domain/metadata/capture_metadata_reader.dart';
import 'package:astroplan/domain/metadata/fits_metadata_reader.dart';
import 'package:astroplan/domain/metadata/metadata_format.dart';
import 'package:astroplan/domain/metadata/metadata_source.dart';
import 'package:astroplan/domain/metadata/metadata_value.dart';
import 'package:astroplan/domain/models/camera_class.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/services/block_proposal.dart';
import 'package:astroplan/domain/services/storage_estimate.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fits_fixture.dart';
import '../../support/memory_metadata_source.dart';

Future<MetadataReading> _read(List<int> bytes, {int? budget}) =>
    CaptureMetadataReader.read(
      budget == null
          ? MemoryMetadataSource(bytes)
          : BudgetedMetadataSource(
              MemoryMetadataSource(bytes),
              budgetBytes: budget,
            ),
    );

Future<CaptureMetadata> _meta(List<(String, Object)> cards) async =>
    switch (await _read(fitsFile(cards))) {
      MetadataRead(:final metadata) => metadata,
      final other => throw StateError('not read: $other'),
    };

void main() {
  group('A1: the header', () {
    test('a N.I.N.A.-style header: every keyword with its origin', () async {
      final r = await _read(fitsFile(ninaLight(), dataBytes: 100));
      expect(r, isA<MetadataRead>());
      expect(r.format, MetadataFormat.fits);
      final m = (r as MetadataRead).metadata;
      expect(m.exposureSeconds.valueOrNull, 300);
      expect((m.exposureSeconds as KnownValue).origin.field, 'EXPTIME');
      expect(m.acquisitionGain.valueOrNull, 100);
      expect(m.offset.valueOrNull, 50);
      expect(m.sensorTemperatureC.valueOrNull, -9.8);
      expect(m.setpointTemperatureC.valueOrNull, -10);
      expect(m.filterName.valueOrNull, 'Ha');
      expect(m.cameraModel.valueOrNull, 'TestAstro 2600MM');
      expect(m.telescope.valueOrNull, 'Test 400 mm refractor');
      expect(m.focalLengthMm.valueOrNull, 400);
      expect(
        (m.focalLengthMm as KnownValue).origin.provenance,
        MetadataProvenance.softwareSetting,
      );
      expect(m.imageDimensions.valueOrNull, const ImageDimensions(3124, 2088));
      expect(m.binning.valueOrNull, const SensorBinning(2, 2));
      expect(m.pixelSizeUm.valueOrNull, const PixelSize(7.52, 7.52));
      final t = m.captureTime.valueOrNull!;
      expect(
        (t.year, t.hour, t.second, t.utcOffset),
        (2026, 21, 5, Duration.zero),
      );
      final layout = m.sampleLayout.valueOrNull!;
      expect((layout.bitpix, layout.headerRecords), (16, 1));
      expect(layout.axes, [3124, 2088]);
      expect(layout.isSupported, isTrue);
    });

    test('a header across two records is read to END', () async {
      final cards = [
        ...ninaLight(),
        for (var i = 0; i < 30; i++) ('COMMENT$i', 'x'),
        ('OBJECT', 'M 42'),
      ];
      final m = await _meta(cards);
      expect(m.sampleLayout.valueOrNull!.headerRecords, 2);
      expect(m.filterName.valueOrNull, 'Ha');
    });

    test(
      'a missing END: truncated, or corrupt past the record limit',
      () async {
        final short = await _read(fitsFile(ninaLight(), end: false));
        expect(
          (short as MetadataUnreadable).reason,
          MetadataUnreadableReason.truncated,
        );
        final long = await _read(
          fitsFile(
            ninaLight(),
            end: false,
            records: FitsMetadataReader.maxHeaderRecords + 1,
          ),
        );
        expect(
          (long as MetadataUnreadable).reason,
          MetadataUnreadableReason.corrupt,
        );
      },
    );

    test('the byte budget stops the read', () async {
      final cards = [
        ...ninaLight(),
        for (var i = 0; i < 40; i++) ('HISTORY$i', 'x'),
      ];
      final r = await _read(fitsFile(cards), budget: 2880);
      expect(
        (r as MetadataUnreadable).reason,
        MetadataUnreadableReason.overBudget,
      );
    });

    test('floating BITPIX reads as its sample size', () async {
      for (final (bitpix, bits) in [(-32, 32), (-64, 64), (8, 8), (32, 32)]) {
        final m = await _meta(ninaLight(bitpix: bitpix));
        expect(m.bitsPerSample.valueOrNull, bits, reason: '$bitpix');
        expect(m.sampleLayout.valueOrNull!.isSupported, isTrue);
      }
      final odd = await _meta(ninaLight(bitpix: 12));
      expect(odd.bitsPerSample, isA<UnparseableValue<int>>());
      expect(odd.sampleLayout.valueOrNull!.isSupported, isFalse);
    });

    test(
      'axis limits: a cube is unsupported; an absurd axis is unreadable',
      () async {
        final cube = await _meta([
          ('SIMPLE', true),
          ('BITPIX', 16),
          ('NAXIS', 3),
          ('NAXIS1', 100),
          ('NAXIS2', 100),
          ('NAXIS3', 3),
        ]);
        expect(cube.sampleLayout.valueOrNull!.isSupported, isFalse);
        expect(cube.imageDimensions, isA<AbsentValue<ImageDimensions>>());
        final huge = await _meta(ninaLight(width: 99999999999));
        expect(huge.imageDimensions, isA<AbsentValue<ImageDimensions>>());
        expect(huge.sampleLayout, isA<UnparseableValue<SampleLayout>>());
      },
    );

    test(
      'EXPTIME and EXPOSURE: equal is one value, different a conflict',
      () async {
        final equal = await _meta([...ninaLight(), ('EXPOSURE', 300.0)]);
        expect(equal.exposureSeconds.valueOrNull, 300);
        final differ = await _meta([...ninaLight(), ('EXPOSURE', 299.0)]);
        expect(differ.exposureSeconds, isA<AmbiguousValue<double>>());
        final only = await _meta([
          for (final c in ninaLight())
            if (c.$1 != 'EXPTIME') c,
          ('EXPOSURE', 120.0),
        ]);
        expect(only.exposureSeconds.valueOrNull, 120);
      },
    );

    test('an arbitrary FILTER is kept as written, quotes and all', () async {
      final m = await _meta([
        for (final c in ninaLight())
          if (c.$1 != 'FILTER') c,
        ('FILTER', "'Sloan ''r'' 3nm   '"),
      ]);
      expect(m.filterName.valueOrNull, "Sloan 'r' 3nm");
    });

    test(
      'a repeated keyword is unreadable, never the last one silently',
      () async {
        final m = await _meta([...ninaLight(), ('GAIN', 200)]);
        expect(m.acquisitionGain, isA<UnparseableValue<double>>());
      },
    );
  });

  group('A2: geometry normalized once', () {
    Future<EquipmentCandidate> candidate(List<(String, Object)> cards) async =>
        EquipmentCandidate.fromReading(
          MetadataRead(MetadataFormat.fits, await _meta(cards)),
        );

    test(
      'binned (bin 2) and unbinned writers give the same native rig',
      () async {
        final binned = await candidate(ninaLight());
        final unbinned = await candidate(
          ninaLight(width: 6248, height: 4176, binning: 1, pixelSize: 3.76),
        );
        for (final c in [binned, unbinned]) {
          expect(c.resolutionWidthPx.valueOrNull, 6248);
          expect(c.resolutionHeightPx.valueOrNull, 4176);
          expect(c.pixelPitchUm.valueOrNull, 3.76);
          expect(c.sensorWidthMm.valueOrNull, 23.49);
          expect(c.sensorHeightMm.valueOrNull, 15.7);
          expect(c.cameraModel.valueOrNull, 'TestAstro 2600MM');
          expect(c.focalLengthMm.valueOrNull, 400);
        }
      },
    );

    test('absent or asymmetric binning proposes no native geometry', () async {
      final absent = await candidate(ninaLight(binning: null));
      expect(absent.resolutionWidthPx, isA<UnknownField<int>>());
      expect(absent.pixelPitchUm, isA<UnknownField<double>>());
      final asym = await candidate([
        for (final c in ninaLight())
          if (c.$1 != 'YBINNING') c,
        ('YBINNING', 1),
      ]);
      expect((asym.pixelPitchUm as UnknownField).gap, CandidateGap.conflicting);
    });

    test(
      "the file's size fits a bin-2 block, once; a bin-1 block not",
      () async {
        final rig = EquipmentProfile(
          id: 1,
          name: 'Astro',
          cameraClass: CameraClass.astroMono,
          sensorWidthMm: 23.49,
          sensorHeightMm: 15.7,
          pixelPitchUm: 3.76,
          resolutionWidthPx: 6248,
          resolutionHeightPx: 4176,
          focalLengthMm: 400,
          focalRatio: 5,
        );
        final reading = MetadataRead(
          MetadataFormat.fits,
          await _meta(ninaLight()),
        );
        final file = StorageEstimate.evidenceOf('L.fits', reading, 13049280)!;
        expect((file.width, file.height, file.binning), (3124, 2088, 2));
        expect(file.compression, FileCompression.none);
        CaptureBlock at(int b) => CaptureBlock(
          frameType: FrameType.light,
          exposureTimeSeconds: 300,
          frameCount: 1,
          binning: b,
          fileEvidence: file,
        );
        expect(StorageEstimate.of(at(2), rig).bytes, 13049280);
        expect(
          StorageEstimate.of(at(1), rig).skipped[StorageBasis.blockFile],
          containsAll([StorageConflict.binning, StorageConflict.dimensions]),
        );
      },
    );

    test('a block proposal: exposure, gain, binning, filter for an astro '
        'camera; the rest is evidence only', () async {
      final reading = MetadataRead(
        MetadataFormat.fits,
        await _meta(ninaLight()),
      );
      final p = BlockProposal.of(
        name: 'L_0001.fits',
        reading: reading,
        lengthBytes: 13049280,
        cameraClass: CameraClass.astroMono,
      );
      expect(p.exposure!.value, 300);
      expect(p.gain!.value, CaptureGain.gain(100));
      expect(p.binning!.value, 2);
      expect(p.filter!.value, 'Ha');
      expect(p.iso, isNull);
      expect(p.evidence.whereType<SettingEvidence>().map((e) => e.keyword), [
        'OFFSET',
        'CCD-TEMP',
        'SET-TEMP',
      ]);
      final phone = BlockProposal.of(
        name: 'L_0001.fits',
        reading: reading,
        lengthBytes: 13049280,
        cameraClass: CameraClass.phone,
      );
      expect(phone.gain, isNull, reason: 'a gain is never an ISO');
      expect(phone.binning, isNull);
      // Each not-proposed gain says why, in its own words.
      GainNotProposed? why(CameraClass c) {
        final p = BlockProposal.of(
          name: 'L_0001.fits',
          reading: reading,
          lengthBytes: 13049280,
          cameraClass: c,
        );
        return p.evidence.whereType<GainEvidence>().singleOrNull?.why;
      }

      expect(why(CameraClass.phone), GainNotProposed.recordsIso);
      expect(why(CameraClass.dslrMirrorless), GainNotProposed.recordsIso);
      expect(why(CameraClass.unknown), GainNotProposed.classUnknown);
      expect(why(CameraClass.astroMono), isNull);
      final high = BlockProposal.of(
        name: 'L_0001.fits',
        reading: MetadataRead(
          MetadataFormat.fits,
          await _meta([
            for (final e in ninaLight())
              if (e.$1 != 'GAIN') e,
            ('GAIN', 20000),
          ]),
        ),
        lengthBytes: 13049280,
        cameraClass: CameraClass.astroColour,
      );
      expect(high.gain, isNull);
      expect(
        high.evidence.whereType<GainEvidence>().single.why,
        GainNotProposed.outOfRange,
      );
    });
  });

  // F10 (CHK-F10.A2; ADR-021 C10/C11): a layout the reader does not support
  // (a 3-axis cube) stays explicit as storage evidence: no geometry, its
  // compression unknown, never the pixel payload of its first plane.
  group('an unsupported layout (3 axes) as storage evidence', () {
    final cubeCards = <(String, Object)>[
      ('SIMPLE', true),
      ('BITPIX', 16),
      ('NAXIS', 3),
      ('NAXIS1', 100),
      ('NAXIS2', 80),
      ('NAXIS3', 3),
      ('EXPTIME', 60.0),
    ];
    // One 2,880-byte header record, then 100 × 80 × 3 planes × 2 bytes.
    const length = 2880 + 100 * 80 * 3 * 2;

    Future<FileEvidence> cube() async {
      final reading = await _read(
        fitsFile(cubeCards, dataBytes: 100 * 80 * 3 * 2),
      );
      expect(reading, isA<MetadataRead>());
      expect(reading.format, MetadataFormat.fits);
      return StorageEstimate.evidenceOf('cube.fits', reading, length)!;
    }

    test('evidenceOf: the file and its length, no geometry, compression '
        'unknown', () async {
      final e = await cube();
      expect(e.format, 'fits');
      expect(e.read, isTrue);
      expect(e.bytes, length);
      expect(e.label, 'cube.fits');
      expect((e.width, e.height), (null, null), reason: 'not one image');
      expect(e.compression, FileCompression.unknown);
      expect(e.binning, isNull);
    });

    test('never counted as a theoretical size', () async {
      final e = await cube();
      // A rig of the plane's size with no format and no measured size: the
      // cube's evidence gives no theoretical payload (100 × 80 × 2 = 16,000
      // bytes, or 17,280 in FITS records).
      final rig = EquipmentProfile(
        id: 1,
        name: 'Astro',
        cameraClass: CameraClass.astroMono,
        sensorWidthMm: 3.76,
        sensorHeightMm: 3.008,
        pixelPitchUm: 37.6,
        resolutionWidthPx: 100,
        resolutionHeightPx: 80,
        focalLengthMm: 400,
        focalRatio: 5,
        rawFileSizeEvidence: e,
      );
      final block = CaptureBlock(
        frameType: FrameType.light,
        exposureTimeSeconds: 60,
        frameCount: 1,
      );
      expect(StorageEstimate.theoretical(block, rig), isNull);
      final asRig = StorageEstimate.of(block, rig);
      expect(asRig.basis, isNot(StorageBasis.theoretical));
      expect(asRig.basis, StorageBasis.unknown);
      expect(asRig.bytes, isNull);
      // As the block's own file it is the measured length, as read.
      final own = StorageEstimate.of(
        CaptureBlock(
          frameType: FrameType.light,
          exposureTimeSeconds: 60,
          frameCount: 1,
          fileEvidence: e,
        ),
        EquipmentProfile(
          id: 2,
          name: 'Astro',
          cameraClass: CameraClass.astroMono,
          sensorWidthMm: 3.76,
          sensorHeightMm: 3.008,
          pixelPitchUm: 37.6,
          resolutionWidthPx: 100,
          resolutionHeightPx: 80,
          focalLengthMm: 400,
          focalRatio: 5,
        ),
      );
      expect(own.basis, StorageBasis.blockFile);
      expect(own.bytes, length.toDouble());
      expect(own.bytes, isNot(anyOf(16000, 17280)));
    });
  });
}
