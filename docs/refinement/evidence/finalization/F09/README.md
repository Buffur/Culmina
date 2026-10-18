# F09 — Calibration coverage, CAL-1 generation and the empty plan (evidence)

Run: full final-plan group (owner launch 2026-10-18), second cloud session, 2026-10-18.
Environment: Linux container, Flutter 3.47.4 / Dart 3.13.3 (the CI pin). No Android SDK, emulator
or phone. Evidence layer: HOST tests (domain, and the capture plan over real ViewModels and
in-memory SQLite), plus the host E2E `core_loop`.

## What changed

- `calibration_match.dart`:
  - `normalizedFilter` / `sameFilter` (trimmed, case-folded, no alias);
  - flat warnings correlated on (filter, binning) (TD-107);
  - `lightsWithoutFlats` (groups; the rig's class decides whether binning counts);
  - `covers` and `provenSameSensitivity`: CAL-1's strict coverage (C15).
- `calibration_builder.dart` (new): `CalibrationBuilder.propose` / `confirm` (CAL-1, PD-12). Inherited
  fields record `inherited` origins with a fixed descriptor; a flat's sensitivity is `copied`;
  entered exposures are `entered`.
- `calibration_preview_dialog.dart` (new): the preview.
  - Editable counts.
  - Entered flat/bias exposures (`ExposureInput`).
  - "Leave out" / "Include" per row; a dark flat follows its flat.
  - "No darks" note under in-camera noise reduction.
  - Cancel returns nothing.
- `capture_plan_widget.dart`:
  - the labelled "Build calibration frames" entry, which reads "…, with the missing flats" beside
    the missing-flat warning;
  - one-edit add with Undo (`SessionPlanViewModel.addCaptureBlocks`);
  - the empty state: next step in words, "Add light frames", and "Take from a photo" where F08
    supports the class (not astro before F10). It replaces "Start from the example plan".
- The block dialog's `pickOnOpen` serves the empty state's photo action.
- `ExampleText.startFromExample` is removed. `ExampleCapturePlan` stays a fixture
  (`vm.plan.useExamplePlan` in tests).
- `capture_analysis_viewmodel.dart`: `lightsWithoutFlats` (still 300 lines). `pixelScale` is
  compacted: the identity effective focal length is the focal length.
- Tests:
  - new: `test/domain/services/calibration_coverage_test.dart` (9),
    `test/presentation/widgets/calibration_preview_test.dart` (7);
  - updated to the accepted contract: `calibration_match_test.dart` (an unused filter is the one
    reason), `calibration_blocks_test.dart` (the group text), `capture_blocks_undo_test.dart` (CAL-1
    Undo replaces the removed example action's Undo), `planner_defaults_test.dart` (the example as a
    fixture), `accessibility_test.dart` (the empty state's action);
  - migrated: `integration_test/core_loop_test.dart` now starts from the empty state (Add light
    frames → Build calibration frames).

## Criterion results

| Criterion | Result | Evidence |
| --- | --- | --- |
| CHK-F09.A1 | PASS (TEST) | V13: Ha/bin1 + OIII/bin2 with flat Ha/bin2. `covers` is false for both lights; the flat warns `binningMatchesNoLight`; missing coverage lists (Ha, 1) and (OIII, 2). V14: "Ha" = " HA ", "H-alpha" ≠ "Ha"; the spelling is kept. Mutation: per-field flat checks fail V13. TD-107 resolved |
| CHK-F09.A2 | PASS (TEST) | **Unknown sensitivity:** no warning, but no proof (`covers` false either way); proven duplicates are left out; an unproven dark stays proposed. **Entry points:** the labelled entry and the warning shortcut open the preview. **Preview contents:** darks per exposure/ISO, flats per filter (L, R), one bias for a camera; dark flats and no bias for an astro camera. Counts are editable, and a flat's exposure must be entered ("Enter seconds…"; `confirm` throws without it). **Fields:** the same class-appropriate basic fields as F06 (count, exposure; the sensitivity shown and taken). The matching tuple excludes WB and focus (F06's test). No include-switch redesign: a row's "Leave out" is a local preview choice |
| CHK-F09.A3 | PASS (TEST) | In-camera noise reduction: no darks, with the note. Counts stay proposals. Confirmed blocks are `outsideWindow`; integration and window load are unchanged, and outside-window calibration grows (`calibration_coverage_test.dart`) |
| CHK-F09.A4 | PASS (TEST) | Preview Cancel changes nothing. Confirm adds the blocks as one edit ("Added 2 calibration blocks"). Undo restores the lights alone (`capture_blocks_undo_test.dart`). Undo after a newer edit says "Can't undo…" and keeps that edit (`calibration_preview_test.dart`) |
| CHK-F09.A5 | PASS (TEST); U at F25 | A custom filter ("Sloan r") is proposed in its spelling, and " l " folds into L. Hidden-class binning: a phone light's binning 2 is not compared, so a bin-1 flat covers it; an astro camera compares it. The example-action replacement E2E (`core_loop`) passes: `+2`, and `perf_scenarios` `+1` |
| CHK-F09.A6 | PASS (TEST); U at F25 | With no blocks: "No blocks yet. Start with your light frames; the calibration frames can be built from them afterwards." with labelled "Add light frames" and "Take from a photo" (phone rig with files). No example action, no "example" text. An astro rig gets no photo action before F10. The E2E starts from this state |

**Mutation checks** (each reverted): per-field flat checks; unknown proving coverage (the advisory
rule); in-camera noise reduction ignored; case-sensitive filters. Each made tests fail.

**Density record (roadmap U):** the reference plan's scroll extent is 3884 px at 412 px / 100 %,
+48 px against F05's 3836 px baseline: the "Build calibration frames" entry under the blocks. The
section deltas are Tonight 2720 → 2768 and Conditions 3376 → 3424. This is a record for the owner's
review, not a limit.

## Commands (working tree before the F09 commit)

- `flutter test --no-pub test` → `+2127 ~2: All tests passed!`
- `integration_test/core_loop_test.dart -d flutter-tester` → `+2` (migrated);
  `perf_scenarios_test.dart` → `+1`
- `flutter analyze --no-pub` → `No issues found!`; format 0 changed; encoding passed
