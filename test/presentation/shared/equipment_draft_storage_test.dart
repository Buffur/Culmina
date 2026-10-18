// F07 (ADR-021 C7): the rig's storage evidence through its form model. A
// rig drafted from a DNG keeps the file its RAW size came from while that
// size is unchanged. A capture format chosen in the editor is "declared";
// an unchanged one keeps its source.

import 'package:astroplan/domain/equipment_import/equipment_candidate.dart';
import 'package:astroplan/domain/metadata/capture_metadata.dart';
import 'package:astroplan/domain/metadata/metadata_format.dart';
import 'package:astroplan/domain/metadata/metadata_value.dart';
import 'package:astroplan/domain/models/capture_evidence.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/tracking_type.dart';
import 'package:astroplan/presentation/shared/equipment_draft.dart';
import 'package:flutter_test/flutter_test.dart';

const _o = MetadataOrigin(format: MetadataFormat.dng, field: 'test');

EquipmentCandidate _dng() => EquipmentCandidate.fromReading(
  const MetadataRead(
    MetadataFormat.dng,
    CaptureMetadata(
      cameraMake: KnownValue('TestMake', raw: 'TestMake', origin: _o),
      focalLengthMm: KnownValue(8.8, raw: '88/10', origin: _o),
      fNumber: KnownValue(2.0, raw: '2/1', origin: _o),
      focalLength35mmEquivalentMm: KnownValue(60, raw: '60', origin: _o),
      imageDimensions: KnownValue(
        ImageDimensions(4000, 3000),
        raw: '4000 3000',
        origin: _o,
      ),
      bitsPerSample: KnownValue(16, raw: '16', origin: _o),
      compression: KnownValue(PixelCompression(1), raw: '1', origin: _o),
    ),
  ),
  fileLengthBytes: 24012345,
  fileName: 'DCIM/IMG_0845.dng',
);

EquipmentFormTexts _with(EquipmentFormTexts t, {String? rawFileSize}) =>
    EquipmentFormTexts(
      name: t.name.isEmpty ? 'Phone' : t.name,
      manufacturer: t.manufacturer,
      cameraModel: t.cameraModel,
      resolutionWidth: t.resolutionWidth,
      resolutionHeight: t.resolutionHeight,
      pixelPitch: t.pixelPitch,
      sensorWidth: t.sensorWidth,
      sensorHeight: t.sensorHeight,
      focalLength: t.focalLength,
      focalRatio: t.focalRatio,
      diameter: t.diameter,
      rawFileSize: rawFileSize ?? t.rawFileSize,
      rotation: t.rotation,
      maxExposure: t.maxExposure,
    );

void main() {
  test('a DNG candidate carries its file as the RAW size evidence', () {
    final c = _dng();
    expect(c.rawFileEvidence!.label, 'IMG_0845.dng', reason: 'basename only');
    expect(c.rawFileEvidence!.bytes, 24012345);
    expect(c.rawFileEvidence!.compression, FileCompression.none);
    expect((c.rawFileEvidence!.width, c.rawFileEvidence!.height), (4000, 3000));
  });

  test('saved with the rig while the RAW size is unchanged; a typed size '
      'drops it (the association would be false)', () {
    final draft = EquipmentDraft.fromCandidate(_dng());
    final kept = draft
        .build(_with(draft.initial), TrackingType.unknown)
        .profile!;
    expect(kept.rawFileSizeEvidence, _dng().rawFileEvidence);
    final typed = draft
        .build(_with(draft.initial, rawFileSize: '30'), TrackingType.unknown)
        .profile!;
    expect(typed.averageRawFileSizeMB, 30);
    expect(typed.rawFileSizeEvidence, isNull);
  });

  group('the capture format (C7)', () {
    final rig = EquipmentProfile(
      id: 3,
      name: 'Astro',
      sensorWidthMm: 23.5,
      sensorHeightMm: 15.7,
      pixelPitchUm: 3.76,
      resolutionWidthPx: 6248,
      resolutionHeightPx: 4176,
      focalLengthMm: 400,
      focalRatio: 5,
      captureFormat: CaptureFormat.fits16,
      captureFormatSource: 'file:L_0001.fits',
    );
    final draft = EquipmentDraft.fromProfile(rig);
    EquipmentProfile save(CaptureFormat? Function()? format) => draft
        .build(draft.initial, TrackingType.unknown, captureFormat: format)
        .profile!;

    test('unchanged keeps its source; chosen is declared; cleared is none', () {
      expect(
        (save(null).captureFormat, save(null).captureFormatSource),
        (CaptureFormat.fits16, 'file:L_0001.fits'),
      );
      expect(
        save(() => CaptureFormat.fits16).captureFormatSource,
        'file:L_0001.fits',
      );
      final declared = save(() => CaptureFormat.fits32float);
      expect(
        (declared.captureFormat, declared.captureFormatSource),
        (CaptureFormat.fits32float, 'declared'),
      );
      final cleared = save(() => null);
      expect(
        (cleared.captureFormat, cleared.captureFormatSource),
        (null, null),
      );
    });
  });
}
