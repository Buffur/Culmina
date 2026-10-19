# F25 A3 — the four W journeys (step records)

Date 2026-10-19, code at the F25 commit. Roadmap §2 "W": record each screen, action, backtrack or
dead end, external value lookup, and the visible fit / Unknown / relative-gain explanation. The
walkthrough below is **functional**, performed by the agent through the real app on the host:
each step is executed by the named automated test (HOST), and the screens are in
`renders/` (F25 A1). **Human comprehension is UNVERIFIED**: no participant other than the builder
took part (the accepted S6.E gap; not a new recruitment project). Phone rows stay at G2.

Issue classes: **none** (step works as specified), **limitation** (accepted, documented),
**attention** (needs input not available here; tracked in PROGRESS).

## W1 — Phone: manual and photo-assisted setup

| # | Screen → action | Visible explanation | Executed by | Issue |
| --- | --- | --- | --- | --- |
| 1 | Welcome (first run, before the first frame) → read purpose and permission line | What the app does; no target step, no Skip (F16) | `integration_test/core_loop_test.dart` (first run), `rig_created_for_plan_test.dart` "from onboarding (Welcome): back on Welcome" | none |
| 2 | Welcome → Add rig → class **Phone** | Each required input says which calculations need it (F05 A4) | `rig_creation_test.dart` "each required input says which calculations need it" | none |
| 3 | Rig: **From a photo** (phone JPEG) | Read values with their source; unknowns stay Unknown (no typed sensor needed) | `rig_created_for_plan_test.dart` "From a photo: a phone JPEG saves a rig with no typed sensor …" | none |
| 4 | Rig: **by hand** instead (backtrack) | Cancel writes and chooses nothing | `rig_created_for_plan_test.dart` "Cancel writes and chooses nothing", "by hand: chosen exactly once, back at the caller" | none |
| 5 | Planner → status "Needs a target" → Choose a target | One actionable place per missing input; Save disabled with "To save: …" (F18) | `planner_f18_test.dart` A5 | none |
| 6 | Capture plan → **Add from a photo** → review → Add block | What is proposed vs only shown; a typed value is kept and named (F08) | `block_from_photo_test.dart` A1/A2, `block_from_photo_plan_test.dart` | none |
| 7 | Read the answer | Fit verdict with "needed of usable"; integration; relative stacking gain as √N vs one frame, never absolute SNR (F11); effective assumptions near the plan (F12) | `planner_f18_test.dart`, `light_groups_test.dart` and `stacking_gain_graph_test.dart` (F11), `capture_assumptions_test.dart` (F12) | none |
| 8 | Save plan | "Plan saved"; the autosave banner cleared (F18 A2) | `planner_f18_test.dart` A5, `current_session_failure_test.dart` | none |

External value lookups: none required (the photo supplies the class-applicable values; the rest
stay Unknown). Phone GPS/photo on a device: G2.

## W2 — DSLR: proposal, edit, cancel

| # | Screen → action | Visible explanation | Executed by | Issue |
| --- | --- | --- | --- | --- |
| 1 | Library → Rigs → Add rig → class **DSLR or mirrorless** → From a photo (DNG) | DNG values with units, sources and unknowns | `metadata_import_screen_test.dart` "a DNG shows its values with units, sources and unknowns" | none |
| 2 | Review the match → change a value → Save | The conflict switch; the saved rig keeps the file's provenance | `metadata_import_review_db_test.dart` (F05), `rig_creation_test.dart` "from a photo: the saved identity comes back and is chosen" | none |
| 3 | Planner → a light block → edit ISO/WB/AF-MF → Cancel | Cancel keeps the block; the discard guard asks before losing edits (F06) | `block_settings_test.dart` and `light_block_form_test.dart` (F06 A2/A7), `block_from_photo_test.dart` "an unsaved proposal is a change for the guard; Cancel …" | none |
| 4 | Repeat a photo pick in either order | The same end values; a different pixel count is flagged | `block_from_photo_test.dart` A2 | none |
| 5 | Storage line | Estimate from compatible evidence; measured file sizes never rescaled; decimal MB/GB (F07) | `storage_estimate_test.dart`, `storage_display_test.dart` (F07) | none |
| 6 | Read the answer | Fit, integration, relative gain per setting group (ISO groups never merged with unknown ones, F11) | `light_groups_test.dart` (F11) | none |

External value lookups: none. A real camera's DNG/JPEG/HEIC run with owner samples: F04 A4
(**attention**, owner samples outside Git).

## W3 — Astro camera: metadata and calibration

| # | Screen → action | Visible explanation | Executed by | Issue |
| --- | --- | --- | --- | --- |
| 1 | Add rig → class **Astro camera (mono)** → From a file (FITS) | "FITS is read"; native geometry proposed, binning normalized once (F10) | `fits_import_test.dart` "a FITS sub-frame proposes a rig with its native geometry …", `calibration_preview_test.dart` "an astro rig is offered a file too …" | synthetic headers only: **attention** (no licensed real FITS sample, F03 A5/F10 A3) |
| 2 | Capture plan: light blocks with filters, gain, binning | Gain, not ISO, for the class (C13); binning only where offered | `block_settings_test.dart` (F06), `calibration_blocks_test.dart` (F09), `camera_class_test.dart` | none |
| 3 | **Build calibration** → preview → Cancel / Add | The preview lists what the lights need (darks/flats/dark flats/bias by the whole tuple, C15); Cancel changes nothing; one Undo | `calibration_preview_test.dart` "the preview lists what the lights need; Cancel changes …", "Undo after a newer edit keeps that edit" | none |
| 4 | A flat missing for a filter | The missing-flat warning offers the preview | `calibration_preview_test.dart` "the missing-flat warning offers the preview" | none |
| 5 | In-camera noise reduction on | No darks, and the preview says why | `calibration_preview_test.dart` "in-camera noise reduction: no darks …" | none |
| 6 | Read the answer | Fit and total time with calibration's own budget (inside/outside the window); Unknown sensitivity never proves coverage | `calibration_coverage_test.dart` (F09) | none |

External value lookups: none. The AstroBin CSV of such a night (F20): filter names listed by row;
the numeric filter IDs are looked up on AstroBin by the user (accepted, CA-08).

## W4 — Returning, multi-night: save, result, progress

| # | Screen → action | Visible explanation | Executed by | Issue |
| --- | --- | --- | --- | --- |
| 1 | Tonight → night card → coming nights → **Plan this night** | Facts first; lead time apart from age; browse never changes the plan until chosen (F14/F15) | `forecast_nights_test.dart` A6, `night_moon_browse_test.dart` A2/A3 | none |
| 2 | Save the plan; kill; reopen | The named plan and its state come back | `lifecycle_matrix_test.dart` L4b, `route_restoration_test.dart` (F22) | Android process death: **attention** (no emulator) |
| 3 | During the night → Logbook → **Result not recorded** → Record result | "This night is still under way … finishes it early" (F19 A2) | `results_screen_test.dart` "during its night a result finishes it early", the Logbook F19 A1 tests | none |
| 4 | A changed saved plan during its night | Save / Discard / Cancel first; the result reviews the saved plan (F19 A5) | `results_screen_test.dart` group "a Saved · changed plan during its night" | none |
| 5 | Next morning → Tonight "Last night: … How did it go?" → Partly | Planned vs recorded integration on the card | `integration_test/core_loop_test.dart` (result after dawn), F19 Logbook tests | none |
| 6 | Logbook → Progress by target | Integration so far from results (CALC-38), the early result included | `results_screen_test.dart` (progress after the early result), `target_progress_test.dart` | none |
| 7 | Entry → saved forecast; Export for AstroBin (CSV) | The forecast as saved with its age then (F19 A3); rows previewed with filter names (F20) | `session_detail_test.dart` A3, `astrobin_export_test.dart` | live AstroBin import: owner (G2/G3) |
| 8 | Copy to another night (backtrack) | A new unsaved plan; the entry unchanged | `saved_plan_transition_test.dart` S8.7 | none |

## Summary

All four journeys complete functionally on the host with no dead end; every step shows its fit,
Unknown or relative-gain explanation where one applies. Open items are inputs, not defects:
real FITS / owner camera samples, the Android process-death run, the live AstroBin import and the
human-comprehension check (UNVERIFIED).
