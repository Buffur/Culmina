# F06 — Preserve block settings, origins and white balance (evidence)

Run: full final-plan group (owner launch 2026-10-18), second cloud session, 2026-10-18.
Environment: Linux container, Flutter 3.47.4 / Dart 3.13.3 (the CI pin). No Android SDK, emulator
or phone. Evidence layer: HOST tests, including the real ViewModels over in-memory SQLite and the
whole app where stated. U renders and the owner's visual acceptance are collected in F25.

## What was wrong (found at F06's start)

- The block editor's Save built a new `CaptureBlock` from its fields only. Every F03 value was
  dropped on any edit: white balance, focus mode, field origins and file evidence.
  `CalibrationMatch.matched` ("Match the lights") dropped them too.
- A filter outside the picker became None (TD-108).
- A new flat or bias kept the light proposal's exposure after a type switch.
- Unknown offered a per-block ISO/gain choice, which ADR-021 C13 rejects.
- Exposure accepted decimals only.
- The editor had no discard guard, and its button said "Add" / "Save".

## Changed files

- `lib/domain/services/exposure_input.dart` (new, C14): `parse`, `problem` (the message for the
  field), `format`.
- `lib/domain/services/calibration_match.dart`: `matched` keeps the white balance, focus mode,
  origins and file evidence. With `origin`, it records `inherited` on the fields it takes.
- `lib/domain/models/camera_class.dart`: `offersCameraRecords` (Phone, DSLR/mirrorless, Unknown).
  The sensitivity doc follows C13.
- `lib/presentation/widgets/capture_plan/capture_block_dialog.dart`: the editor.
  - A custom filter is listed as itself.
  - The default filter follows the class: L for mono astro, otherwise none.
  - A light proposal's exposure is cleared when switching to flat, bias or dark flat, and comes
    back for a light.
  - Exposure takes fractions and decimals.
  - Unknown has no ISO/gain field. It shows the camera-type remedy, and a recorded or source-taken
    value is kept and named.
  - White balance (Not recorded / Auto / Preset / Kelvin / Custom; tint in Details) and Focus
    (Not recorded / AF / MF). An astro rig keeps these and names them.
  - Binning, the tint and "Where the values came from" are in Details.
  - Per-field origins:
    - an edit keeps each unchanged field's origin, and a changed field becomes `entered`;
    - a proposal or "Use other values" value is `copied` while it is unchanged;
    - a calibration match is `inherited`.
  - A field that holds a source's value says "From …" under it.
  - `PopScope` guard with the shared prompt.
  - Buttons are "Add block" / "Apply changes", with a scope line.
- `lib/presentation/widgets/capture_plan_widget.dart`: "Match the lights" records the inherited
  origin. An edit says "Changed in this plan: …" with Undo, as before.
- `lib/presentation/viewmodels/capture_analysis_viewmodel.dart`: Fill window marks the count
  `entered` and keeps the other origins.
- `lib/presentation/shared/capture_settings_text.dart` (new): WB, focus and origins in words.
- `lib/presentation/screens/logbook/session_detail_screen.dart` and
  `lib/presentation/shared/entry_share_text.dart`: a block's WB and focus follow its exposure.
- `lib/data/repositories/shared_prefs_planner_state_repository.dart`: the preferences fallback
  plan stores the same values additively (`DATA_MODEL.md`).
- Tests (new):
  - `test/domain/services/exposure_input_test.dart` (3);
  - `test/presentation/widgets/block_settings_test.dart` (28);
  - `test/presentation/widgets/block_values_in_plan_test.dart` (6);
  - +2 in `calibration_match_test.dart`;
  - +1 in `shared_prefs_planning_repositories_test.dart`.
- Updated to the accepted contract (C13 instead of Unknown's choice; binning in Details; the new
  labels and messages): `light_block_form_test.dart`, `calibration_blocks_test.dart`,
  `capture_plan_widget_test.dart`, `capture_blocks_test.dart`, `capture_blocks_undo_test.dart`.

## Criterion results

| Criterion | Result | Evidence |
| --- | --- | --- |
| CHK-F06.A1 | PASS (TEST) | `block_settings_test.dart` "A1: filters": an unchanged custom light filter, the audit's L-eXtreme through a type switch and back, and a custom flat filter taken from its light and kept by "Use other values" all survive. Null stays null. The domain's 32-character bound stands. Mutation: listing it as None again fails two cases. TD-108 resolved |
| CHK-F06.A2 | PASS (TEST) | **Edit** (`block_settings_test.dart` "A2"): a changed count becomes `entered`, and the file and copied origins of the other fields stay. A changed sourced exposure becomes `entered`. A proposal's exposure and binning are `copied` "from Ha · 300 s × 20". A new dark records `inherited` with that descriptor. Cancel returns nothing. **Visible:** the field shows "IMG_0845.dng" / "From Ha · 300 s × 20", and Details lists every origin. **Operations** (`block_values_in_plan_test.dart`, real ViewModels and SQLite): reorder, delete-Undo, Save, the saved snapshot, reopen and a copy for another night keep every value. Backup and manifest round trips: F03's `capture_contract_round_trip_test.dart`. **Descriptors** are fixed text: editing or deleting the source changes nothing. **Match the lights** keeps the settings and records `inherited` (`calibration_match_test.dart`). Mutation: dropping the edit-keeps-origin rule fails two cases. No import conflict exists before F08, so none can be hidden |
| CHK-F06.A3 | PASS (TEST) | "A3": a 300 s proposal is cleared for Flat and Bias, comes back for Light, and a typed exposure survives a switch. The default filter is L for astro mono and none for astro colour, phone, DSLR and Unknown. Mutations: no clearing fails one case; always L fails four |
| CHK-F06.A4 | PASS (TEST) | **Entry:** Kelvin with tint, preset and MF are recorded and survive an unchanged edit, with origins equal. Out-of-range kelvins fail by the field. An old block reads "Not recorded" and stays unrecorded. An astro rig hides them, keeps and names a recorded value, and has no numeric focus field. **Snapshot, Logbook entry, Share text:** `block_values_in_plan_test.dart` (snapshot `wb`/`focusMode`; the detail's plan rows and `EntryShareText` read "Ha · 1/14 s · WB Cloudy, tint +2 · MF: 200 planned"). **Manifest/backup:** F03 round trips. **Calculations unchanged:** the budget's window load, storage and per-block exposure are equal with and without them, and a dark with other WB/focus still matches (`calibration_match_test.dart`, C15) |
| CHK-F06.A5 | PASS (TEST); U renders and owner acceptance at F25 | A phone light shows exposure, count, ISO, WB and focus, with no binning and no ISO/GAIN choice. Saving with only exposure "1/14" and a count stores 1/14 s with ISO, WB and focus unrecorded. `exposure_input_test.dart`: decimal/fraction/"s" vectors; 0, negative, 1/0, text, "1/", above 3600 s fail; the messages; format ↔ parse round trips ("1/250" reopens as "1/250"). The dialog shows "A fraction needs a denominator above 0" by the field. Class selects ISO/gain (`light_block_form_test.dart`); Unknown shows the remedy and records none. Binning is astro Details (`light_block_form_test.dart`, `calibration_blocks_test.dart`). **412 × 915, 200 % text, keyboard inset 320 px:** every field reachable, Add block above the keyboard, saves, no overflow (HOST). Density: reference plan unchanged at 3836 px (the planner rows did not change) |
| CHK-F06.A6 | PASS (TEST); U at F25 | "A6": changed + Back asks ('"L" has changes that are not saved.'); Cancel keeps the typed value; Discard returns nothing. A tap outside asks, and dismissing the prompt is Cancel. The prompt's Save applies. Unchanged Back and tap outside close at once. Explicit Cancel never applies and never asks. "Pending file proposals count as dirty": no block file proposal exists before F08 (F08 A1 adds it); the guard compares every field the dialog holds. The dialog keeps the AlertDialog: the 412 × 915/200 %/keyboard case passes, so the full-screen route is not needed. Mutation: no guard fails three cases |
| CHK-F06.A7 | PASS (TEST); RENDER/U at F25 | "A7": "Add block" for a new block, "Apply changes" for an edit, never "Save", with the scope line. `block_values_in_plan_test.dart`: on a saved plan, Apply changes says "Changed in this plan: OIII …", changes the working plan (unsaved changes on), and leaves the saved row's `plannedAtUtc` and snapshot JSON unchanged. Undo is unchanged (`capture_blocks_undo_test.dart`). New blocks keep the existing behaviour (no Undo, the new row marked), so a delete's Undo still owns its block (TD-082) |

## Commands (working tree before the F06 commit)

- `flutter test --no-pub test` → `+2064 ~2: All tests passed!` (the whole unit/widget suite)
- `flutter test --no-pub integration_test/core_loop_test.dart -d flutter-tester` → `+2`;
  `integration_test/perf_scenarios_test.dart` → `+1`
- `flutter analyze --no-pub` → `No issues found!`; `dart format --set-exit-if-changed lib test
  integration_test` → 0 changed; `dart run tool/check_encoding.dart` → passed
- Density: `reference_plan_density_test.dart` → `scrollExtent` 3836 (unchanged from F05's baseline)

## Remaining

- U renders (412 px, 100/200 %, light/dark/field, keyboard open) and the owner's review: F25.
- File proposals in the block editor and their conflicts: F08 (A6's "pending proposal" counts as
  dirty then).
