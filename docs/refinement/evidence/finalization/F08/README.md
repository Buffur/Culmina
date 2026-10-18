# F08 — Populate a light block from a reviewed photo proposal (evidence)

Run: full final-plan group (owner launch 2026-10-18), second cloud session, 2026-10-18.
Environment: Linux container, Flutter 3.47.4 / Dart 3.13.3 (the CI pin). No Android SDK, emulator
or phone. Evidence layer: HOST tests. The real readers run on synthetic DNG, JPEG and CR3 files, and
the capture plan runs over the real ViewModels and in-memory SQLite. FITS is F10.

## What changed

- `lib/domain/services/block_proposal.dart` (new): `BlockProposal.of` builds the proposal from one
  reading.
  - **Proposed:**
    - exposure (within the block bounds);
    - ISO, only for an ISO class (C13; never relabelled as a gain);
    - white balance Auto, only from EXIF Auto (C2);
    - the file as the block's storage evidence (C6, via `StorageEstimate.evidenceOf`).
  - **Origins:** each proposed value carries a `file` origin whose evidence is its tag; an ISO's
    origin also carries its kind.
  - **Shown as evidence only:** the sensitivity kind, a Manual white balance, the light source and
    the as-shot neutral vector.
  - **Flagged:** mode conflicts against the rig.
  - **Edge cases:** an unrecognized file is unreadable; a recognized RAW gives only its length.
- `MetadataImportViewModel.pickBlockFile`: the one import pipeline (`CaptureFileAccess` and
  `CaptureMetadataReader`).
- `capture_block_dialog.dart`: a light block offers "Take from a photo" / "Another photo" with an
  inline review.
  - **Review contents:** what is proposed, what is shown, the mode conflict, and "Kept what you
    typed: …".
  - **Which fields a pick fills:** only a field that is empty, still holds the edited block's own
    value, or holds a source's value (the light proposal or an earlier file). A typed value is kept
    and named. The same rule applies to every pick, so repeated picks are order-independent.
  - **Guard and failures:** the proposal and the file count for the discard guard. A failed pick is
    said through `runWithFeedback` and changes nothing.
  - **Applied block:** keeps `fileEvidence` and its origin.
- `capture_plan_widget.dart`: passes the picker where files can be read (`FeatureScope.metadataImport`).
- `proposal_text.dart` (new): the review's words.
- TD-072:
  - `equipment_matcher.dart`: orientation-free size conflicts;
  - `equipment_draft.dart`: a copied sensor takes the file's orientation (S3F-01).
- Tests (new):
  - `test/domain/services/block_proposal_test.dart` (7);
  - `test/presentation/widgets/block_from_photo_test.dart` (8);
  - `test/presentation/widgets/block_from_photo_plan_test.dart` (1);
  - `test/domain/equipment_import/size_orientation_test.dart` (2).

## Criterion results

| Criterion | Result | Evidence |
| --- | --- | --- |
| CHK-F08.A1 | PASS (TEST) | **Proposed values:** the review lists "From IMG_0845.jpg" and "Proposed: Exposure ≈1/14 s · ISO 800 · White balance Auto", with the kind "ISO 800 (ISO speed)". **Class rules** (`block_proposal_test.dart`): only class-applicable fields are proposed. An astro rig gets no ISO ("an ISO is not a gain"); Unknown gets no ISO until its class is set; Manual white balance, the light source and AsShotNeutral are shown and never converted. **Local until Apply:** after Apply, exposure, ISO, WB and file size carry `file` origins "IMG_0845.jpg" with their tags, and the count is `entered`. A typed exposure is kept and named. **Rig untouched:** through the plan (`block_from_photo_plan_test.dart`), the rig's size and file are unchanged after Save |
| CHK-F08.A2 | PASS (TEST) | **Nothing written:** Cancel returns nothing; a cancelled pick changes nothing; a picker failure says "Couldn't read the file" and changes nothing; a non-capture file is named and sets nothing. **Deterministic outcomes:** A then B gives B's values, origin and file; B then A gives A's. A typed value is kept and named. A pixel count other than the rig's shows "Not the rig's mode (another pixel count): its size is not used for storage", and the estimate then skips the block's file (`block_proposal_test.dart`). **Guard:** after a pick, Back asks (the discard prompt) |
| CHK-F08.A3 | PASS (TEST) | TD-072 resolved: a portrait-typed rig gets no resolution or sensor "conflict" from the same values stored landscape, while a real difference still conflicts. S3F-01: the copied sensor is landscape for a 4096 × 3072 file. Both failed without the fix. A custom filter ("Sloan r"), a recorded focus mode and its origin survive a pick |
| CHK-F08.A4 | PARTIAL: HOST PASS; device row carried to G2; U/W at F25 | Host: pick a synthetic DNG in a new block, review, Add block, Save, reopen. The exposure, ISO, file and origins come back equal, and the plan shows "Measured from DSC_0001.dng" (F07). **Carried:** the physical-phone DNG/JPEG/HEIC Save/reopen row (G2, REL-08) and U renders plus the W DSLR proposal/edit/cancel path (F25). These need a device and the owner's files |

## Commands (working tree before the F08 commit)

- `flutter test --no-pub test` → `+2111 ~2: All tests passed!`
- `integration_test/core_loop_test.dart -d flutter-tester` → `+2`; `perf_scenarios_test.dart` → `+1`
- `flutter analyze --no-pub` → `No issues found!`; format 0 changed; encoding passed
