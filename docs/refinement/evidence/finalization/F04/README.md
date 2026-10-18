# F04 — Extend the existing typed metadata contract (evidence)

Run: full final-plan group, second cloud session, 2026-10-18. Linux container, Flutter 3.47.4.

## Changed files

- `lib/domain/metadata/capture_metadata.dart`: new fields `bitsPerSample`, `compression`
  (`PixelCompression` with kind none/lossless/lossy/unknown), `asShotNeutral` (`NeutralVector`),
  `whiteBalance` (`ExifWhiteBalance`), `lightSource` (`LightSource`), and the common FITS fields
  `pixelSizeUm` (`PixelSize`), `binning` (`SensorBinning`), `acquisitionGain`,
  `conversionGainElectronsPerAdu`, `offset`, `sensorTemperatureC`, `setpointTemperatureC`,
  `filterName`, `telescope`, `sampleLayout` (`SampleLayout`, `isSupported` = C10's layouts).
- `lib/domain/metadata/exif_structure.dart`: the new tags in the contract (nothing else is read);
  258/259 only for a DNG's main IFD0; 50728 only in a DNG's IFD0; 41987/37384 in either IFD,
  combined (contradiction → ambiguous).
- Tests: `test/domain/metadata/capture_metadata_f04_test.dart`, `test/support/tiff_fixture.dart`
  (`shorts`, `rationals`), `test/data/metadata/real_samples_test.dart` (new keys checked when the
  owner's `expected.json` lists them).

## Criterion results

| Criterion | Result | Evidence |
| --- | --- | --- |
| CHK-F04.A1 | PASS (TEST) | Each new value's origin names its tag and IFD (e.g. `dng:IFD0/BitsPerSample (258)`, `jpeg:APP1 EXIF IFD/WhiteBalance (41987)`); absent tags absent; a WhiteBalance in both IFDs with different values ambiguous; invalid codes (Compression 0, WhiteBalance 2) unparseable; LightSource 0 ("unknown") absent |
| CHK-F04.A2 | PASS (TEST) | AsShotNeutral read as `NeutralVector([0.47, 1, 0.62])` with its raw rationals; a zero is unparseable; it never sets the white-balance mode or any Kelvin; JPEG and HEIC never carry one; JPEG/HEIC give only auto/manual and the light source |
| CHK-F04.A3 | PASS (TEST) | Differing BitsPerSample (16 12 16) unparseable (unsupported layout); compression codes 7/8/34892/52546/other are explicit kinds (only 1 = none allows C10); asymmetric `SensorBinning` and unsupported `SampleLayout` (3 axes, BITPIX 12) say so; a preview IFD0 (NewSubfileType 1) gives no layout; the read stays inside the file and the default budget |
| CHK-F04.A4 | PARTIAL: synthetic PASS; real-file NEEDS ATTENTION | Synthetic DNG, JPEG and HEIC exercise every new field (15 cases); the FITS types exist without a reader. The owner's real DNG/JPEG/HEIC samples are outside Git and not in this container: `real_samples_test.dart` now checks the new keys too; resume by running it locally with `ASTROPLAN_METADATA_SAMPLES` and the new keys in `expected.json` |

## Commands

- `flutter test --no-pub -r failures-only test/domain test/data test/presentation/screens/metadata
  test/presentation/screens/equipment` → `+1134 ~1: All other tests passed!`
- `flutter test --no-pub test/domain/metadata/capture_metadata_f04_test.dart` → `+15`
- `flutter analyze --no-pub` → `No issues found!`
