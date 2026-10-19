// F08 (ADR-021 C2, C4, C6, C13; PD-11): what one picked file proposes for a
// light block, from the real readers on synthetic files. Only what the rig's
// class records is proposed. ISO is never a gain. White balance is proposed
// only as Auto from EXIF Auto; Manual, the light source and AsShotNeutral are
// shown, never converted. The file is the block's storage evidence, and a
// pixel count other than the rig's is flagged.

import 'package:astroplan/domain/metadata/capture_metadata.dart';
import 'package:astroplan/domain/metadata/capture_metadata_reader.dart';
import 'package:astroplan/domain/metadata/metadata_format.dart';
import 'package:astroplan/domain/models/camera_class.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/capture_evidence.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/services/block_proposal.dart';
import 'package:astroplan/domain/services/storage_estimate.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/heif_fixture.dart';
import '../../support/jpeg_fixture.dart';
import '../../support/memory_metadata_source.dart';
import '../../support/tiff_fixture.dart';

/// A phone JPEG: 9987236/10⁹ s, ISO 100 (ISO speed), 4096 × 3072,
/// WhiteBalance [wb] (0 Auto, 1 Manual) and LightSource [light].
List<int> _jpeg({int? wb = 0, int? light}) {
  final exif = phoneStyleJpegExif();
  exif.exif!.addAll([
    FixtureEntry.long(40962, 4096),
    FixtureEntry.long(40963, 3072),
    if (wb != null) FixtureEntry.short(41987, wb),
    if (light != null) FixtureEntry.short(37384, light),
  ]);
  return jpegFile([exifApp1(exif.build().bytes)]);
}

Future<BlockProposal> _propose(
  List<int> bytes, {
  String name = 'IMG_0845.jpg',
  CameraClass cameraClass = CameraClass.phone,
  EquipmentProfile? rig,
  int? length,
}) async => BlockProposal.of(
  name: name,
  reading: await CaptureMetadataReader.read(MemoryMetadataSource(bytes)),
  lengthBytes: length ?? bytes.length,
  cameraClass: cameraClass,
  rig: rig,
);

EquipmentProfile _rig(int w, int h) => EquipmentProfile(
  id: 1,
  name: 'Phone',
  sensorWidthMm: 9.8,
  sensorHeightMm: 7.4,
  pixelPitchUm: 2.4,
  resolutionWidthPx: w,
  resolutionHeightPx: h,
  focalLengthMm: 6.57,
  focalRatio: 1.6,
);

void main() {
  test('a phone JPEG proposes exposure, ISO and Auto white balance, each '
      'with its tag', () async {
    final p = await _propose(_jpeg(), rig: _rig(4096, 3072));
    expect(p.exposure!.value, 9987236 / 1000000000);
    expect(p.exposure!.origin.kind, OriginKind.file);
    expect(p.exposure!.origin.descriptor, 'IMG_0845.jpg');
    expect(p.exposure!.origin.evidence, {'tag': 'ExposureTime (33434)'});
    expect(p.iso!.value, CaptureGain.iso(100));
    expect(p.iso!.origin.evidence!['kind'], 'isoSpeed');
    expect(p.whiteBalance!.value, WhiteBalance.auto());
    expect(p.file!.format, 'jpeg');
    expect(p.modeConflicts, isEmpty);
  });

  test('an astro rig gets no ISO (an ISO is never a gain); Unknown gets '
      'none until its class is set (C13)', () async {
    final astro = await _propose(_jpeg(), cameraClass: CameraClass.astroMono);
    expect(astro.iso, isNull);
    expect(
      astro.evidence.whereType<SensitivityEvidence>().single.recordsGain,
      isTrue,
    );
    expect(astro.whiteBalance, isNull, reason: 'no WB record on astro');
    final unknown = await _propose(_jpeg(), cameraClass: CameraClass.unknown);
    expect(unknown.iso, isNull);
    expect(
      unknown.evidence.whereType<SensitivityEvidence>().single.proposed,
      isFalse,
    );
    expect(unknown.whiteBalance!.value, WhiteBalance.auto());
  });

  test('Manual white balance and the light source are shown, not '
      'proposed (C2)', () async {
    final p = await _propose(_jpeg(wb: 1, light: 1));
    expect(p.whiteBalance, isNull);
    expect(
      p.evidence.whereType<WhiteBalanceEvidence>().single.mode,
      ExifWhiteBalance.manual,
    );
    expect(
      p.evidence.whereType<LightSourceEvidence>().single.source.name,
      'Daylight',
    );
  });

  test(
    "a DNG's as-shot neutral vector is evidence only, never a Kelvin",
    () async {
      final ifd0 = phoneStyleDngIfd0()
        ..add(FixtureEntry.rationals(50728, [(47, 100), (1, 1), (62, 100)]));
      final dng = (TiffFixture()..ifd0.addAll(ifd0)).build().bytes;
      final p = await _propose(dng, name: 'IMG.dng', length: 24012345);
      expect(p.whiteBalance, isNull);
      expect(p.evidence.whereType<NeutralEvidence>().single.vector.values, [
        0.47,
        1,
        0.62,
      ]);
      expect(p.exposure!.value, 30);
      expect(p.file!.compression, FileCompression.none);
      expect(p.file!.bytes, 24012345);
    },
  );

  test("another pixel count than the rig's is flagged; its size is not "
      'used', () async {
    final p = await _propose(_jpeg(), rig: _rig(4064, 3056));
    expect(p.modeConflicts, {StorageConflict.dimensions});
    final block = CaptureBlock(
      frameType: FrameType.light,
      exposureTimeSeconds: 1,
      frameCount: 1,
      fileEvidence: p.file,
    );
    expect(StorageEstimate.of(block, _rig(4064, 3056)).skipped.keys, [
      StorageBasis.blockFile,
    ]);
  });

  test(
    'an unread CR3 gives its size only; a non-capture file nothing',
    () async {
      final cr3 = await _propose(
        [
          0,
          0,
          0,
          24,
          ...'ftypcrx '.codeUnits,
          0,
          0,
          0,
          0,
          ...List.filled(64, 0),
        ],
        name: 'IMG_0001.CR3',
        length: 31457280,
      );
      expect(cr3.unreadable, isFalse);
      expect((cr3.exposure, cr3.iso, cr3.whiteBalance), (null, null, null));
      expect((cr3.file!.read, cr3.file!.bytes), (false, 31457280));
      final text = await _propose('hello'.codeUnits, name: 'notes.txt');
      expect(text.unreadable, isTrue);
      expect(text.isEmpty, isTrue);
    },
  );

  // F08 / CHK-F08.A4 (host part): a phone HEIC goes the same light-block
  // path as a JPEG. Its format is recognized as HEIC, its measured length
  // is the block's storage evidence and is used as measured: a lossy file
  // is never rescaled and never gets a theoretical size (C6, C10).
  test('a phone HEIC: recognized, its measured size is the evidence, used '
      'as measured, never rescaled', () async {
    final exif = phoneStyleJpegExif();
    exif.exif!.addAll([
      FixtureEntry.long(40962, 4096),
      FixtureEntry.long(40963, 3072),
      FixtureEntry.short(41987, 0),
    ]);
    final heic = (HeifFixture()..addExif(2, exif.build().bytes)).build();
    final rig = _rig(4096, 3072);
    final p = await _propose(
      heic,
      name: '/DCIM/IMG_0846.HEIC',
      rig: rig,
      length: 2876543,
    );
    expect(p.unreadable, isFalse);
    expect(p.exposure!.value, closeTo(0.009987236, 1e-12));
    expect(p.exposure!.origin.descriptor, 'IMG_0846.HEIC');
    expect(p.iso!.value, CaptureGain.iso(100));
    expect(p.whiteBalance!.value, WhiteBalance.auto());
    expect(p.file!.toJson(), {
      'bytes': 2876543,
      'format': 'heic',
      'read': true,
      'width': 4096,
      'height': 3072,
      'bitsPerSample': null,
      'compression': 'lossy',
      'binning': null,
      'label': 'IMG_0846.HEIC',
    });
    expect(p.modeConflicts, isEmpty);

    final block = CaptureBlock(
      frameType: FrameType.light,
      exposureTimeSeconds: 1,
      frameCount: 10,
      fileEvidence: p.file,
    );
    final frame = StorageEstimate.of(block, rig);
    expect(
      (frame.basis, frame.bytes, frame.label, frame.read),
      (StorageBasis.blockFile, 2876543.0, 'IMG_0846.HEIC', true),
    );
    expect(StorageEstimate.theoretical(block, rig), isNull, reason: 'lossy');
    // A rig declared as JPEG/HEIC takes the HEIC as its own format.
    final declared = rig.withCaptureEvidence(
      captureFormat: () => CaptureFormat.jpegHeic,
    );
    expect(StorageEstimate.conflicts(p.file!, block, declared), isEmpty);
    expect(StorageEstimate.of(block, declared).bytes, 2876543.0);
    // Without the file, that rig's size is Unknown, never a guess.
    expect(
      StorageEstimate.of(
        CaptureBlock(
          frameType: FrameType.light,
          exposureTimeSeconds: 1,
          frameCount: 10,
        ),
        declared,
      ).gap,
      StorageGap.compressed,
    );
  });

  test('a HEIF without a reader (an image sequence) counts by its length '
      'only, recognized as HEIF', () {
    final p = BlockProposal.of(
      name: 'BURST_0001.HEIC',
      reading: const MetadataUnsupported(MetadataFormat.heifSequence),
      lengthBytes: 5123456,
      cameraClass: CameraClass.phone,
      rig: _rig(4096, 3072),
    );
    expect(p.unreadable, isFalse);
    expect((p.exposure, p.iso, p.whiteBalance), (null, null, null));
    expect(
      (p.file!.format, p.file!.read, p.file!.bytes, p.file!.width),
      ('recognized:heif', false, 5123456, null),
    );
  });

  test('a path is never kept, only the basename (C5)', () async {
    final p = await _propose(_jpeg(), name: '/storage/DCIM/IMG_0845.jpg');
    expect(p.label, 'IMG_0845.jpg');
    expect(p.file!.label, 'IMG_0845.jpg');
  });
}
