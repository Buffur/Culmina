# F10 — FITS through the existing paths (evidence, partial)

Run: full final-plan group (owner launch 2026-10-18), second cloud session, 2026-10-18.
Environment: Linux container, Flutter 3.47.4 / Dart 3.13.3 (the CI pin). No Android SDK, emulator
or phone, and **no real astro-camera FITS file**. None is in the repository or this container. A web
search (2026-10-18) found no licensed (CC0/public-domain) amateur sub-frame: forum-posted ZWO
headers have no stated reuse terms, and NASA/HEASARC samples are not camera frames. Evidence layer:
HOST tests on synthetic headers (`test/support/fits_fixture.dart`, N.I.N.A.-style keywords, neutral
values).

## What changed

- `lib/domain/metadata/fits_metadata_reader.dart` (new; registered in `CaptureMetadataReader`): the
  C21 keyword set, as summarized in DECISIONS ADR-021 "Implemented (F10)".
- `equipment_candidate.dart`: `_fitsGeometry`, the native geometry normalized once (C11).
- `storage_estimate.dart`: a read FITS as file evidence (written geometry, sample size, binning; a
  supported layout is uncompressed).
- `block_proposal.dart`: GAIN, binning and FILTER proposals, plus `SettingEvidence` /
  `BinningEvidence`.
- `capture_block_dialog.dart`: applies them under F08's rule.
- Labels (A4):
  - `rig_input_text.dart` and `add_rig_panel.dart`: photo first for every class; the formats named
    include FITS, and other RAW is described honestly;
  - `metadata_import_screen.dart`;
  - the block editor's photo line;
  - the empty plan offers "Take from a photo" to astro rigs.
- Tests:
  - new: `test/domain/metadata/fits_metadata_reader_test.dart` (13),
    `test/presentation/screens/metadata/fits_import_test.dart` (1);
  - updated: `tiff_metadata_reader_test.dart` (FITS is no longer "unsupported"),
    `metadata_import_screen_test.dart` (XISF is the unsupported example), `rig_creation_test.dart`
    (photo first since F10), `calibration_preview_test.dart` (an astro rig is offered a file).

## Criterion results

| Criterion | Result | Evidence |
| --- | --- | --- |
| CHK-F10.A1 | PASS (TEST, synthetic) | `fits_metadata_reader_test.dart` "A1". **Header limits:** a two-record header is read to END. A missing END is `truncated` within the file and `corrupt` past 64 records. The byte budget gives `overBudget`. **Axes and sample size:** BITPIX −32/−64/8/32 read as their sample size, BITPIX 12 is unparseable and its layout unsupported. A cube (NAXIS 3) is unsupported, with no dimensions. An absurd axis is unreadable. **Keyword outcomes:** EXPTIME = EXPOSURE is one value, and different values are an `AmbiguousValue` (a visible conflict). FILTER keeps its quotes: `'Sloan ''r'' 3nm'` → `Sloan 'r' 3nm`. A repeated keyword is unreadable. Absent and asymmetric binning: see A2 |
| CHK-F10.A2 | PASS (TEST, synthetic) | A bin-2 writer (3124 × 2088, XPIXSZ 7.52) and an unbinned one (6248 × 4176, 3.76) give the same native rig: 6248 × 4176 px, 3.76 µm, 23.49 × 15.70 mm. Absent binning proposes no native geometry (not taken as 1); asymmetric binning is `conflicting`. The file's size fits a bin-2 block (13,049,280 B, never rescaled); at bin 1 it is not used (binning and pixel count). Unsupported layouts stay explicit (`SampleLayout.isSupported` false; F07 gives no theoretical value) |
| CHK-F10.A3 | **NEEDS ATTENTION** (host part PASS) | **Host:** a synthetic FITS goes through the real picker/reader → review (FITS, Ha) → "New rig from this file". The editor shows 3.76 µm and 400 mm, and Cancel stores nothing. Save stores one rig: 6248 × 4176, astro mono class (chosen first), focal length source `metadata:fits` (`fits_import_test.dart`). The block proposal for an astro camera is exposure 300 s, gain 100, bin 2 and filter Ha, with OFFSET and the temperatures shown only. Storage of the file at bin 2: see A2. **Missing:** a real astro-camera FITS run through reader, saved rig, block proposal and storage. **Resumption:** the owner provides a local FITS sub-frame (kept out of Git) or names a licensed fixture. Then run the import and a block proposal on it, on the host and on a device (G2 REL-08) |
| CHK-F10.A4 | PASS (TEST); U at F25 | The add-rig panel names "a FITS sub-frame", and other RAW files (CR3, NEF, ARW …) "are not read" (`rig_creation_test.dart`). The import screen's intro names DNG, JPEG, HEIC or FITS. Photo-first ordering applies to every class. No new block control: gain, binning and filter were already fields |

## Commands (working tree before the F10 commit)

- `flutter test --no-pub test` → `+2141 ~2: All tests passed!`
- `integration_test/core_loop_test.dart -d flutter-tester` → `+2`; `perf_scenarios_test.dart` → `+1`
- `flutter analyze --no-pub` → `No issues found!`; format 0 changed; encoding passed

## Dependencies

G1 needs A3 closed, or an explicit owner deferral recording the PD-11/RG-03 consequences (roadmap
F10 "Dependencies / Risk"). F03 A5 waits on the same sample.
