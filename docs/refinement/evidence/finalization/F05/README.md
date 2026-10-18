# F05 — Make manual and photo-assisted rig creation usable (evidence)

Run: full final-plan group (owner launch 2026-10-18), second cloud session, 2026-10-18.
Environment: Linux container, Flutter 3.47.4 / Dart 3.13.3 (the CI pin). No Android SDK, emulator
or phone here. Evidence layer: HOST tests (widget tests over the real app and an in-memory SQLite
database where stated). Renders (U) and the owner's visual acceptance are collected in F25.

## Density baseline (roadmap U, "before F05")

`test/presentation/performance/reference_plan_density_test.dart` records the planner holding the
reference plan: three light blocks with a filter change (L 120 s × 40, L 60 s × 30, Ha 300 s × 20),
darks, flats and bias. Measured at 412 px wide, 100 % text, light theme, the SDK's Roboto. F05
leaves the planner's sections unchanged, so this is the pre-Capture-Plan-UI baseline:

`DENSITY {"width":412,"textScale":1.0,"theme":"light","scrollExtent":3836,"viewport":759,
"sections":{"Target":388,"Rig":712,"Capture plan":1216,"Tonight for this target":2720,
"Conditions":3376}}`

This is a record for the owner's review, not a maximum. F06–F12 repeat it after each Capture Plan
UI change.

## Changed files

- `lib/presentation/screens/equipment/add_rig_panel.dart` (new): the class first (Phone, DSLR or
  mirrorless, Astro colour, Astro mono, **Not sure** = Unknown), then **From a photo** and
  **Enter by hand** as two equal tonal buttons, inactive until a class is chosen. Photo comes first
  for Phone/DSLR/Unknown and manual first for astro cameras. The readable formats are named
  (JPEG, HEIC, DNG; FITS not read yet, F10).
- `lib/presentation/shared/rig_input_text.dart` (new): each required input's reason (ADR-021 C20)
  and the flow's words.
- `equipment_selection_screen.dart`: the empty list shows the panel inline; a list with rigs has
  an "Add rig" button that opens the same panel in a sheet. The small icon-only photo button is
  gone. `forPlanAction` (D8 A): a rig created there is chosen once with `setEquipment`, the screen
  pops to its caller, and "Rig saved and chosen for this plan" shows. Otherwise "Rig saved".
- `app_router.dart`: `selectRigForPlan` (`/select/rig?for=plan`); the import route takes
  `NewRigArgs`.
- The missing-rig callers use it: `home_screen.dart` (`planner.noRig`), `plan_status.dart` (the
  status action), `tonight_home_screen.dart` (`tonight.chooseRig`), `welcome_screen.dart`
  (`welcome.chooseRig`, onboarding). Changing an existing choice (the rig card) and
  `capturePlan.setFileSize` keep `selectRig`.
- `metadata_import_screen.dart`: `NewRigArgs` (the chosen class and whether a new rig's Save
  returns its id). A new rig drafted from the file takes the chosen class; for a plan action its
  Save pops the import with the saved id. A file that lacks required inputs lists them with their
  reasons.
- `equipment_editor.dart`: returns the saved rig's id (null: nothing saved). A failed save keeps
  the dialog and its edits. Each required input shows its reason. A `PopScope` guard: on Back or a
  tap outside, an unchanged editor closes at once; a changed one asks with the existing
  `askUnsavedChanges` prompt (Cancel keeps the editor, Discard closes and writes nothing, Save runs
  the editor's Save). Cancel stays an explicit close.
- `equipment_draft.dart`: `EquipmentFormTexts.sameAs` (the "changed" test) and
  `EquipmentDraft.withCameraClass` (only a new rig takes the chosen class).
- `equipment_candidate.dart`: `missingRequired`, the required inputs a file does not give.
- `equipment_seeder.dart`: the example rig is `astroColour`, with its evidence cited (see A3).
- Tests: `rig_creation_test.dart` (new, 16), `rig_created_for_plan_test.dart` (new, 7, whole app
  over SQLite), `metadata_import_review_db_test.dart` (+1). `test/support/add_rig.dart` (new) is
  the shared "start a new rig" step, used by the existing editor, import, secondary-forms and
  perf-scenario tests in place of the removed button. `in_memory_equipment_repository.dart` now
  keeps the class, the noise-reduction flag and the F03 fields. `camera_class_test.dart` follows
  PD-07.

## Criterion results

| Criterion | Result | Evidence |
| --- | --- | --- |
| CHK-F05.A1 | PASS (TEST); U renders at F25 | `rig_creation_test.dart` "A1" group: the empty list shows the question, all five classes, "Not sure", and both choices inactive until a class is chosen. Photo above manual for Phone and DSLR, manual above photo for both astro classes, with the format line. A list with rigs offers both from Add rig's sheet. Missing-rig entry points (Tonight, the planner's card, the status action, Welcome) open the rigs screen with the panel: `rig_created_for_plan_test.dart` (each starts from that action) |
| CHK-F05.A2 | PASS (TEST, synthetic) | `rig_created_for_plan_test.dart` "From a photo": a synthetic phone JPEG (f 6.57 mm, f/1.6, f₃₅ 23 mm, 3072 × 4096 px) goes from Tonight's missing-rig action through Phone → From a photo → New rig from this file → Save with **nothing typed**. One rig is stored and chosen: class Phone, 6.57 mm f/1.6, 4096 × 3072 px, sensor 9.89 mm, pixel pitch 2.414 µm, and both sensor values marked `estimated` (CALC-40). A real phone JPEG on a device is a G2 row |
| CHK-F05.A3 | PASS (TEST) | **Missing inputs:** `metadata_import_review_db_test.dart` "incomplete metadata…": a JPEG without a 35 mm equivalent lists exactly "Pixel size" and "Sensor size" with their reasons. Save of that draft stays refused ("Required"), and no row is written (no guessed pixel size). A complete file lists nothing. **Reasons in the editor:** `rig_creation_test.dart`, one reason per required input (resolution, pixel size, sensor size, focal length, focal ratio), and a name-only Save writes nothing. **Not sure:** it shows "The type stays Unknown. The app does not work out sensor facts…" and saves `CameraClass.unknown`. **Existing rigs keep their class:** an edited astro-mono rig is updated as astro mono. **Example class:** `EquipmentSeeder.defaults` has `astroColour` with cited sources: ZWO sells the ASI2600 as MC (colour) and MM (mono), with separate colour and mono QE figures and a colour model with an IR-cut window (https://us.zwoastro.com/products/new-asi2600mc-mm-pro; https://i.zwoastro.com/zwo-website/manuals/ZWO_ASI2600_Manual_EN.pdf; found by web search 2026-10-18; the pages could not be fetched from this container, whose network policy refuses zwoastro.com). Seeding on an empty table sets it; an existing install's example row (Unknown) is neither updated nor re-inserted. This follows DECISIONS PD-07 (RA.D 2A), which superseded ADR-020 §2's "the example rig stays Unknown" (RG-11). `camera_class_test.dart`'s old RG-11 assertion was updated with that reason |
| CHK-F05.A4 | PASS (TEST) for the field contract; U renders and the W setup path at F25 | The class→block-field matrix regressions pass unchanged (`calibration_blocks_test.dart` per class × type, `camera_class_test.dart`, `in_camera_noise_reduction_ui_test.dart`, within the `test/presentation` run below). The seed-class case: the example rig's class records gain and offers binning, with no in-camera noise reduction (`rig_creation_test.dart`). New rigs carry the class chosen first (by hand and from a photo), so the block editor offers that class's fields |
| CHK-F05.A5 | PASS (TEST) | Whole app over SQLite (`rig_created_for_plan_test.dart`): from **Tonight**, the **planner's no-rig card**, the **plan status's action** and **Welcome** (onboarding). Save returns to the caller with the rig chosen (name and class), the missing-rig action gone, one row stored, and "Rig saved and chosen for this plan" shown. **Cancel** stores and chooses nothing and stays on the rigs list. In the **Library**, a new rig is only saved ("Rig saved", nothing chosen, still listed). With a counting plan stand-in (`rig_creation_test.dart`): by hand, `setEquipment` is called exactly once with the saved id; from a photo, the import's saved id comes back and is chosen once with the chosen class. The Library is save-only on both paths. A **failed save** keeps the editor and its text, and chooses nothing |
| CHK-F05.A6 | PASS (TEST); U renders at F25 | `rig_creation_test.dart` "A6": a changed editor on system Back asks ('"Half typed" has changes that are not saved.'). Cancel keeps the editor and its text. Discard closes and writes nothing. A tap outside asks too. The prompt's Save saves through the editor. An unchanged editor closes at once on Back and on a tap outside, with no prompt and no write. A changed camera type alone counts as a change. The existing prompt is used (the roadmap's first option); the full-screen route is not needed for this criterion |

**Mutation checks** (each change reverted after the run; the two new test files rerun): removing
`setEquipment` from the D8 path, `canPop: true` (no guard), and dropping the chosen class
(`withCameraClass` returning the draft unchanged) each made tests fail (the D8, A6 and class
cases respectively).

## Commands (working tree before the F05 commit)

- `flutter test --no-pub test/presentation test/lifecycle test/data test/domain/equipment_import`
  → `+1353 ~2: All tests passed!`
- `flutter test --no-pub integration_test/perf_scenarios_test.dart -d flutter-tester` → `+1`
  (its rig-editor step now opens through the class panel). `integration_test/core_loop_test.dart`
  → `+2`
- `flutter analyze --no-pub` → `No issues found!`; `dart format --set-exit-if-changed lib test
  integration_test` → 0 changed; `dart run tool/check_encoding.dart` → passed

## Remaining

- U (412 px, 100 %/200 % text, light/dark/field, the editor with the keyboard open) and the W
  setup path: F25, with the owner's visual acceptance.
- A real phone JPEG and the photo picker on a device: G2.
- F16 integrates onboarding into one screen. The Welcome entry point already carries D8.
