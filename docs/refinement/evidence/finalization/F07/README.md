# F07 — Produce storage estimates from compatible evidence (evidence)

Run: full final-plan group (owner launch 2026-10-18), second cloud session, 2026-10-18.
Environment: Linux container, Flutter 3.47.4 / Dart 3.13.3 (the CI pin). No Android SDK, emulator
or phone. Evidence layer: HOST tests (pure domain vectors; the capture plan over the real
ViewModels and in-memory SQLite). U renders and the owner's review are in F25. The FITS reader
branch is F10 (no FITS sample).

## What changed

- `lib/domain/services/storage_estimate.dart` (new; CALC-45; ADR-021 C8–C12):
  - `StorageEstimate.of`: the evidence order, conflicts (binning, pixel count, format), the theoretical payload and Unknown with its gap;
  - `evidenceOf`: one picked file as `FileEvidence`. A read DNG/JPEG/HEIC carries its geometry and compression; a recognized file without a reader carries its length only (`read: false`).
- `capture_budget_calculator.dart`: an optional per-block `frameBytes`. Library blocks are 0. The total is known only when every counted block's size is, and is never a fabricated 0.
- `capture_analysis_viewmodel.dart`: `frameStorage` feeds the budget (still 300 lines; the rule test passes).
- `quantity_text.dart`: `storage` — decimal MB/GB, two decimals.
- `capture_budget_summary.dart` and `storage_text.dart` (new): the total, then the basis with its assumption, or the reason. Unknown offers "Choose one file" and "Enter a size".
- `storage_actions.dart` (new):
  - "Choose one file" picks a file, reads it on the device and shows what was read. It warns when the file does not fit the plan's lights, then saves only on "Use for this rig" (`EquipmentProfile.withMeasuredFile`: the size, `estimated`, and the file).
  - "Enter a size" opens the rig in its editor.
- Rig editor: "Capture format (optional)" in More. A chosen format is `declared` (C7); an unchanged one keeps its source.
- Import:
  - `EquipmentCandidate.rawFileEvidence` (a DNG's file, basename only);
  - `EquipmentDraft.rawFileSizeEvidence` keeps that file with the rig while the RAW size is unchanged, both for a new rig and for "Open" with the size filled;
  - `MetadataImportViewModel.pickStorageFile`.
- Tests (new):
  - `test/domain/services/storage_estimate_test.dart` (19);
  - `test/presentation/widgets/storage_display_test.dart` (7);
  - `test/presentation/shared/equipment_draft_storage_test.dart` (3).
- Tests updated for the new wording and units: `capture_outputs_test.dart` ("1.50 GB", the basis note, "Enter a size"), `rig_form_test.dart` (the More summary).

## Criterion results

| Criterion | Result | Evidence |
| --- | --- | --- |
| CHK-F07.A1 | PASS (TEST) | **Compatible measured file wins:** V1 (a measured 25,172,524 B DNG wins over its 25,165,824 B payload); the block's file comes before the rig's. **Mode changes invalidate it:** a changed rig resolution (dimensions) or capture format (format) makes the rig's file "not used". Choosing a file again, or entering a size, reconfirms it; a typed size drops the association (`equipment_draft_storage_test.dart`). **Already-binned files are never scaled:** V8 (13,049,280 B at bin 2 → 13.05 MB, never ÷ 4) and V9 (incompatible at bin 1 → theoretical V2, or Unknown, with the reason). Mutations: no binning conflict, no dimension conflict, and ÷ bin² each fail tests |
| CHK-F07.A2 | PASS (TEST) | The theoretical value needs an evidenced format: a declared or file-sourced capture format, or a read DNG with Compression = 1 and its bits. **DNG** = pixel data only, labelled "the file adds a small header that depends on the camera's software" (V1 25.17 MB; the widget's 24.00 MB). **FITS** = data in 2,880-byte records, plus one header record when declared (V2 52.19 MB, V5 13.05 MB, V6 5.80 MB, V7 104.37 MB); a file-sourced FITS says its header is not counted. **Unknown stays Unknown:** a compressed RAW (V4), a lossless DNG (V10) and JPEG/HEIC give none. A declared format is the user's explicit choice in the editor (`captureFormatSource` `declared`). Mutation: a theoretical value for a compressed format fails two tests |
| CHK-F07.A3 | PASS (TEST) | The same rig under every camera class gives one identical result for each evidence state (`storage_estimate_test.dart`, "camera class never chooses"). A phone rig with nothing measured is Unknown. Unknown offers "Choose one file" and "Enter a size" (`capture_outputs_test.dart`, `storage_display_test.dart`). Enter a size opens the rig's editor |
| CHK-F07.A4 | PASS (TEST) | D3 A: an unread CR3 of 31,457,280 B is 31.46 MB a frame, "From the size of IMG_0001.CR3: … (mode not read; compressed sizes vary with content)". It is recorded `read: false` and carries no dimensions or compression, so it never feeds C10 (V11; `storage_display_test.dart` picks a synthetic `ftypcrx ` file). A file that is not a capture file is refused and nothing is written |
| CHK-F07.A5 | PASS (TEST); U at F25 | S1 = V1, S2 = V2, S3 = V3 (12,003,350,400 B = 12.00 GB) and S4 = V4, plus the compressed boundary (V10) and the binning vectors (V5, V6, V8, V9) pass. `QuantityText.storage`: 10⁶/10⁹ bytes, "1000.00 MB" below 10⁹ B and "1.00 GB" at it. The source and assumption are visible under the figure: measured file name; "which file it came from was not recorded"; theoretical geometry and header rule; or the reason. Not-used files are named |

## Commands (working tree before the F07 commit)

- `flutter test --no-pub test` → `+2093 ~2: All tests passed!` (the whole unit/widget suite)
- `flutter test --no-pub integration_test/core_loop_test.dart -d flutter-tester` → `+2`;
  `integration_test/perf_scenarios_test.dart` → `+1`
- `flutter analyze --no-pub` → `No issues found!`; changed-file format (0 changed); encoding passed

## Remaining

- FITS read from a file (its header count and layout) and a FITS block file: F10 (FITS sample).
- U renders of the storage note and the "Choose one file" dialog: F25.
