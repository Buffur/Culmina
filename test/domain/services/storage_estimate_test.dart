// F07 (ADR-021 C8–C12, D3–D5 = A; reference vectors V1–V11): a frame's size
// comes from the first compatible evidence — the block's file, the rig's
// file (or its unassociated size), a theoretical payload of an evidenced
// uncompressed format — else Unknown with the reason. A measured file is
// never rescaled; a changed mode invalidates it; camera class never chooses.

import 'package:astroplan/core/utils/quantity_text.dart';
import 'package:astroplan/domain/metadata/capture_metadata.dart';
import 'package:astroplan/domain/metadata/metadata_format.dart';
import 'package:astroplan/domain/metadata/metadata_value.dart';
import 'package:astroplan/domain/models/camera_class.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/capture_evidence.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/services/capture_budget_calculator.dart';
import 'package:astroplan/domain/services/storage_estimate.dart';
import 'package:flutter_test/flutter_test.dart';

EquipmentProfile _rig({
  int w = 6248,
  int h = 4176,
  CaptureFormat? format,
  String? formatSource,
  double? rawMB,
  FileEvidence? file,
  CameraClass cameraClass = CameraClass.unknown,
}) => EquipmentProfile(
  id: 1,
  name: 'Rig',
  cameraClass: cameraClass,
  sensorWidthMm: 23.5,
  sensorHeightMm: 15.7,
  pixelPitchUm: 3.76,
  resolutionWidthPx: w,
  resolutionHeightPx: h,
  focalLengthMm: 400,
  focalRatio: 5,
  averageRawFileSizeMB: rawMB,
  captureFormat: format,
  captureFormatSource: formatSource,
  rawFileSizeEvidence: file,
);

CaptureBlock _light({int binning = 1, FileEvidence? file, int count = 1}) =>
    CaptureBlock(
      frameType: FrameType.light,
      exposureTimeSeconds: 120,
      frameCount: count,
      binning: binning,
      fileEvidence: file,
    );

FileEvidence _fits(int bytes, {int? binning, int? w, int? h}) => FileEvidence(
  bytes: bytes,
  format: 'fits',
  read: true,
  width: w,
  height: h,
  bitsPerSample: 16,
  compression: FileCompression.none,
  binning: binning,
  label: 'L_0001.fits',
);

const _origin = MetadataOrigin(
  format: MetadataFormat.dng,
  location: 'IFD0',
  field: 'test',
);

void main() {
  group('the reference vectors', () {
    test('V1: an uncompressed 16-bit DNG, 4096 × 3072', () {
      final file = FileEvidence(
        bytes: 25172524,
        format: 'dng',
        read: true,
        width: 4096,
        height: 3072,
        bitsPerSample: 16,
        compression: FileCompression.none,
        label: 'IMG_0001.dng',
      );
      final rig = _rig(w: 4096, h: 3072, rawMB: 25.17, file: file);
      final t = StorageEstimate.theoretical(_light(), rig)!;
      expect(t.bytes, 25165824);
      expect(t.pixelDataOnly, isTrue);
      expect(QuantityText.storage(t.bytes.toDouble()), '25.17 MB');
      final measured = StorageEstimate.of(_light(), rig);
      expect(measured.basis, StorageBasis.rigFile, reason: 'measured wins');
      expect(measured.bytes, 25172524);
      expect(QuantityText.storage(measured.bytes!), '25.17 MB');
    });

    test('V2/V3: a declared 16-bit FITS, 6248 × 4176, one header record', () {
      final rig = _rig(format: CaptureFormat.fits16, formatSource: 'declared');
      final f = StorageEstimate.of(_light(), rig);
      expect(f.basis, StorageBasis.theoretical);
      expect(f.bytes, 52188480);
      expect(f.headerCounted, isTrue);
      expect(QuantityText.storage(f.bytes!), '52.19 MB');
      expect(f.bytes! * 230, 12003350400);
      expect(QuantityText.storage(f.bytes! * 230), '12.00 GB');
    });

    test('V4: a compressed RAW without a file is Unknown', () {
      final rig = _rig(
        w: 6000,
        h: 4000,
        format: CaptureFormat.compressedRaw,
        formatSource: 'declared',
      );
      final f = StorageEstimate.of(_light(), rig);
      expect(f.basis, StorageBasis.unknown);
      expect(f.gap, StorageGap.compressed);
      expect(StorageEstimate.theoretical(_light(), rig), isNull);
    });

    test('V5/V6: theoretical at bin 2 and bin 3, binned once', () {
      final rig = _rig(format: CaptureFormat.fits16, formatSource: 'declared');
      expect(StorageEstimate.of(_light(binning: 2), rig).bytes, 13049280);
      expect(StorageEstimate.of(_light(binning: 3), rig).bytes, 5800320);
      expect(
        QuantityText.storage(
          StorageEstimate.of(_light(binning: 2), rig).bytes!,
        ),
        '13.05 MB',
      );
      expect(
        QuantityText.storage(
          StorageEstimate.of(_light(binning: 3), rig).bytes!,
        ),
        '5.80 MB',
      );
    });

    test('V7: a declared 32-bit float FITS', () {
      final rig = _rig(
        format: CaptureFormat.fits32float,
        formatSource: 'declared',
      );
      expect(StorageEstimate.of(_light(), rig).bytes, 104371200);
    });

    test('V8/V9: a bin-2 file is used as measured at bin 2, never ÷ 4, and '
        'is incompatible at bin 1', () {
      final file = _fits(13049280, binning: 2);
      final rig = _rig(format: CaptureFormat.fits16, formatSource: 'declared');
      final at2 = StorageEstimate.of(_light(binning: 2, file: file), rig);
      expect((at2.basis, at2.bytes), (StorageBasis.blockFile, 13049280));
      final at1 = StorageEstimate.of(_light(file: file), rig);
      expect(at1.basis, StorageBasis.theoretical, reason: 'falls to V2');
      expect(at1.bytes, 52188480);
      expect(at1.skipped[StorageBasis.blockFile], {StorageConflict.binning});
      final none = StorageEstimate.of(_light(file: file), _rig());
      expect(none.basis, StorageBasis.unknown);
      expect(none.skipped[StorageBasis.blockFile], {StorageConflict.binning});
    });

    test('V10: a lossless-JPEG DNG gives no theoretical value', () {
      final file = FileEvidence(
        bytes: 18000000,
        format: 'dng',
        read: true,
        width: 6248,
        height: 4176,
        bitsPerSample: 16,
        compression: FileCompression.lossless,
        label: 'IMG.dng',
      );
      // Incompatible (another pixel count) so the theoretical branch runs.
      final rig = _rig(w: 6000, h: 4000, rawMB: 18, file: file);
      final f = StorageEstimate.of(_light(), rig);
      expect(f.basis, StorageBasis.unknown);
      expect(f.gap, StorageGap.compressed);
      expect(f.skipped[StorageBasis.rigFile], {StorageConflict.dimensions});
    });

    test('V11: an unread CR3 counts by its length, decimal MB', () {
      final file = FileEvidence(
        bytes: 31457280,
        format: 'recognized:cr3',
        read: false,
        label: 'IMG_0001.CR3',
      );
      final f = StorageEstimate.of(_light(file: file), _rig());
      expect((f.basis, f.read), (StorageBasis.blockFile, false));
      expect(QuantityText.storage(f.bytes!), '31.46 MB');
    });
  });

  group('C8: the order, and what is compatible', () {
    test("the block's file comes before the rig's", () {
      final block = _light(file: _fits(52188480, binning: 1));
      final rig = _rig(rawMB: 60, file: _fits(60000000, binning: 1));
      expect(StorageEstimate.of(block, rig).basis, StorageBasis.blockFile);
      expect(StorageEstimate.of(_light(), rig).bytes, 60000000);
    });

    test(
      'an older rig size without a file is used, association unrecorded',
      () {
        final f = StorageEstimate.of(_light(binning: 2), _rig(rawMB: 50));
        expect((f.basis, f.bytes), (StorageBasis.rigSize, 50e6));
      },
    );

    test("a changed rig resolution or format invalidates the rig's file "
        'until it is chosen again', () {
      final file = _fits(52188480, binning: 1, w: 6248, h: 4176);
      expect(
        StorageEstimate.of(_light(), _rig(rawMB: 52.19, file: file)).basis,
        StorageBasis.rigFile,
      );
      final cropped = StorageEstimate.of(
        _light(),
        _rig(w: 3000, h: 2000, rawMB: 52.19, file: file),
      );
      expect(cropped.skipped[StorageBasis.rigFile], {
        StorageConflict.dimensions,
      });
      final other = StorageEstimate.of(
        _light(),
        _rig(
          rawMB: 52.19,
          file: file,
          format: CaptureFormat.jpegHeic,
          formatSource: 'declared',
        ),
      );
      expect(other.skipped[StorageBasis.rigFile], {StorageConflict.format});
      expect(other.basis, StorageBasis.unknown);
    });

    test('a portrait file of the same mode is the same pixel count', () {
      final file = _fits(52188480, w: 4176, h: 6248);
      expect(StorageEstimate.conflicts(file, _light(), _rig()), isEmpty);
    });

    test('no rig: Unknown, with that reason', () {
      expect(StorageEstimate.of(_light(), null).gap, StorageGap.noRig);
    });

    test('a file-sourced FITS format does not count a header it did not '
        'read', () {
      final f = StorageEstimate.of(
        _light(),
        _rig(format: CaptureFormat.fits16, formatSource: 'file:L_0001.fits'),
      );
      expect((f.bytes, f.headerCounted), (52185600, false));
    });
  });

  test('C8 (A3): camera class never chooses a branch or a size', () {
    for (final rigOf in [
      (CameraClass c) => _rig(cameraClass: c),
      (CameraClass c) => _rig(cameraClass: c, rawMB: 50),
      (CameraClass c) => _rig(
        cameraClass: c,
        format: CaptureFormat.fits16,
        formatSource: 'declared',
      ),
    ]) {
      final results = {
        for (final c in CameraClass.values)
          StorageEstimate.of(_light(), rigOf(c)),
      };
      expect(results, hasLength(1));
    }
    expect(
      StorageEstimate.of(_light(), _rig(cameraClass: CameraClass.phone)).basis,
      StorageBasis.unknown,
    );
  });

  group('a picked file as evidence', () {
    MetadataRead dng({int compression = 1}) => MetadataRead(
      MetadataFormat.dng,
      CaptureMetadata(
        imageDimensions: const KnownValue(
          ImageDimensions(4096, 3072),
          raw: '4096 3072',
          origin: _origin,
        ),
        bitsPerSample: const KnownValue(16, raw: '16', origin: _origin),
        compression: KnownValue(
          PixelCompression(compression),
          raw: '$compression',
          origin: _origin,
        ),
      ),
    );

    test('a read DNG carries its geometry and compression', () {
      final e = StorageEstimate.evidenceOf('a/IMG.dng', dng(), 25172524)!;
      expect(e.toJson(), {
        'bytes': 25172524,
        'format': 'dng',
        'read': true,
        'width': 4096,
        'height': 3072,
        'bitsPerSample': 16,
        'compression': 'none',
        'binning': null,
        'label': 'IMG.dng',
      });
      expect(
        StorageEstimate.evidenceOf(
          'x.dng',
          dng(compression: 7),
          1,
        )!.compression,
        FileCompression.lossless,
      );
    });

    test('a recognized format without a reader counts by its length only; '
        'an unknown or unreadable one gives none', () {
      final cr3 = StorageEstimate.evidenceOf(
        'IMG.CR3',
        const MetadataUnsupported(MetadataFormat.cr3),
        31457280,
      )!;
      expect(
        (cr3.format, cr3.read, cr3.width),
        ('recognized:cr3', false, null),
      );
      expect(
        StorageEstimate.evidenceOf(
          'x',
          const MetadataUnsupported(MetadataFormat.unknown),
          100,
        ),
        isNull,
      );
      expect(
        StorageEstimate.evidenceOf(
          'x',
          const MetadataUnreadable(MetadataUnreadableReason.corrupt),
          100,
        ),
        isNull,
      );
      expect(StorageEstimate.evidenceOf('x.dng', dng(), null), isNull);
    });
  });

  group('the plan total (ADR-009 §7 as amended by C8)', () {
    test('per block, never a fabricated total', () {
      final blocks = [
        _light(count: 230),
        CaptureBlock(
          frameType: FrameType.dark,
          exposureTimeSeconds: 120,
          frameCount: 20,
          calibrationPolicy: CalibrationPolicy.library,
        ),
      ];
      final known = CaptureBudgetCalculator.calculate(
        blocks: blocks,
        frameBytes: [52188480, null],
      );
      expect(known.storageMB, closeTo(12003.3504, 1e-6), reason: 'library 0');
      final unknown = CaptureBudgetCalculator.calculate(
        blocks: [_light(count: 3), _light(count: 2)],
        frameBytes: [1e6, null],
      );
      expect(unknown.storageMB, isNull);
      expect(unknown.blocks.first.storageMB, 3);
      expect(
        CaptureBudgetCalculator.calculate(
          blocks: const [],
          frameBytes: const [],
        ).storageMB,
        isNull,
      );
    });
  });

  test('QuantityText.storage: decimal MB and GB, two decimals', () {
    expect(QuantityText.storage(25165824), '25.17 MB');
    expect(QuantityText.storage(999999999), '1000.00 MB');
    expect(QuantityText.storage(1e9), '1.00 GB');
    expect(QuantityText.storage(12003350400), '12.00 GB');
  });
}
