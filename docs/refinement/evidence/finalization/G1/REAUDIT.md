# Re-audit of the final plan against the code (2026-10-19)

The owner asked whether everything in the plan is really implemented ("перечитай план ще раз. чи
точно все з плану реалізовано?"). Every F01–F25 acceptance row of
`FINAL_COMPLETION_ROADMAP.md` §7 was read again against the code and its tests. Four read-only
audits did the reading (F01–F07, F08–F13, F14–F19, F20–F25), and each finding was checked here
before acting on it. Code at `7b5e54f` before the re-audit. Environment and toolchain as in
`README.md`: Flutter 3.47.4 / Dart 3.13.3, host only.

Classes: **GAP**, where the code did not meet a clause; **UNTESTED**, implemented but no test
exercised it; **WEAK**, a test exists but could not fail for the stated behaviour. Every new test
was mutation-checked: the guarded code was broken, the test failed, and the code was restored.

## Gaps in behaviour (fixed)

| Row | Finding | Fix | Commit | Test (fails on the old code) |
| --- | --- | --- | --- | --- |
| F01 (backup) | "Back up now" and "Back up first" reported success when the share sheet was closed without sharing, so nothing kept the file | `backUpAndShare` returns whether the file was shared; the screen says no backup was saved | `9ac8d7b` | `backup_section_test.dart` (dismissed share, both buttons) |
| F01 A3 | A start killed during a rollback (after a failed swap) left the journal. The next start then completed the refused restore over the old database | The journal records `had_live` and is marked `rolling_back` first. Every rollback step can be repeated, and a marked journal finishes the rollback | `9ac8d7b` | `restore_activation_test.dart`: a kill at each rollback step after a failed swap or preferences step; new install, killed |
| F04 A3 | DNG BitsPerSample `[16,16,16]` (a linear, demosaiced DNG) was read as 16 bits and fed C10's one-sample payload, a third of the real pixel data | More than one sample per pixel is unparseable (an unsupported layout), with the raw value kept | `c9ab23c` | `capture_metadata_f04_test.dart` |
| F17 A5 | Home's plan status (the fit, or a missing input's reason) said "tonight" for a later plan night | The plan-night phrase is applied to it | `dd5dae7` | `tonight_home_screen_test.dart` "a missing target on another plan night names that night" |
| F18 A1 | On another plan night, "Altitude now" stayed a row of the target summary (only relabelled) | Moved into a collapsed, labelled "Current sky (not the plan's night)" detail | `dd5dae7` | `stage11_host_fixes_test.dart` "F18 A1: on another night…" |
| F21 A5 | A display-settings save of several keys that stopped part way left a silent mix after a restart | A writing mark is set before a multi-key save and removed after; on load the values show as unsaved, with Retry | `dd5dae7` | `settings_persistence_test.dart` "a save stopped between two keys…" |
| F09 / AM-04 | The calibration preview named binning for phones and cameras, which offer none on a block | It follows the class (`offersLightBinning`) | `ccc7fc2` | `calibration_preview_test.dart`, per class |
| F10 (C13) | A FITS GAIN that was not proposed said "this rig records ISO", even for an unset class or an out-of-range gain | `GainEvidence` carries the actual reason | `ccc7fc2` | `fits_metadata_reader_test.dart`, `proposal_text_test.dart` |
| F23 A2 | The owner's GPL-3.0 §7 permission for Google Play services was not shown in the app; it was only in `COMPLIANCE.md` and `README.md` | Shown on About beside the licence | `ccc7fc2` | `about_screen_test.dart` (word for word against `README.md`) |
| F25 A2 | The QuantityText check missed values interpolated before a unit and did not read `lib/domain`. Bypasses included "-18°" with a hyphen, humidity shown as "82.0 %", cloud and the RAW size | The check is widened; nine sites now use `QuantityText` | `47c8ee8` | `quantity_text_usage_test.dart` (with a self-check) |
| F19 A5 | An Upcoming card for a future night showed neither a Record action nor a reason | It says when a result can be recorded, in the entry's words | `17b260a` | `results_screen_test.dart` "a night ahead says when…" |
| F15 A5 | The Night & Moon slider announced the current time for the next and previous steps (its formatter ignored the value) | Each step announces its own instant | `1469731` | `night_moon_browse_test.dart` (increased/decreased value) |
| F25 A1 | The renders covered default states only; About (after F23 A5) and the map picker had no current render | 44 renders of the error and feedback states, About and the map picker (96 in all), plus a surface/criterion matrix | `e6a0376` | `u_renders_test.dart` (opt-in) |
| F21 A5 (found by the renders) | The planning "not saved" card's Retry was at 1.67:1 on the error colour | `onErrorContainer` | `e6a0376` | `display_settings_test.dart` text-contrast checks |

## Untested or weakly tested clauses (tests added)

| Rows | Tests | Commit |
| --- | --- | --- |
| F06 A2, A6, relative gain; F08 A1/A2 (edit after a pick, pick again); F10 FITS in the block dialog (gain, custom filter, binning rule, kept values); F11 empty state; F12 A2 (blocks without a target or a site); F13 Moon-up boundary (−0.84°…0°, real nights); HEIC through the block path | `block_settings_test.dart`, `block_from_photo_test.dart`, `block_from_fits_test.dart` (new), `stacking_gain_graph_test.dart`, `capture_blocks_test.dart`, `planner_structure_test.dart`, `moon_up_predicate_test.dart`, `block_proposal_test.dart` | `143fac0` |
| F15 A5 (polar nights, readout texts, keyboard and semantics); F16 A2/A3 (Welcome: GPS only on tap, denial, photo path and Cancel); F18 A5 (missing rig); F19 A1 (Completed icon), A4 (Back and tap-outside on delete confirmations); F20 A1 (two known nights in date order; the CSV share file); F21 A5 (the writing mark comes before the keys); F22 A1 (a deleted plan behind a restored planner route) | `night_moon_browse_test.dart`, `welcome_screen_test.dart` (new), `planner_f18_test.dart`, `results_screen_test.dart`, `library_manage_mode_test.dart`, `astrobin_acquisitions_test.dart`, `share_astrobin_csv_exporter_test.dart` (new), `planning_preferences_write_mark_test.dart` (new), `route_restoration_test.dart` | `17b260a` |

## Found by the G1 Stage 11 rows (`STAGE_11_ROWS.md`)

| Row | Finding | Fix | Commit | Test |
| --- | --- | --- | --- | --- |
| H2 (F14, F15) | The weather hour button and the calendar day cell replaced their InkWell's semantics with a label but passed no tap: TalkBack announced buttons a double tap could not activate | Both pass `onTap` and `enabled` | `c9cd965` | `detail_screens_test.dart`, `night_moon_browse_test.dart` (semantics tap) |

## Follow-ups

- **TD-110, resolved:** the block dialog's review now says that a kept binning other than the
  file's makes its size unusable (computed at the block's binning).
- **TD-111 (open, low):** `TonightOpportunityWidget` and its chart have no caller since F18 A1.
- `TEST_PLAN.md` L1/L3/L7 carry dated notes (Welcome, route restoration, schema v26).

## What the re-audit did not change

The carried rows stay as they were: F02 A2/A3, F03 A5 and F10 A3 (FITS sample), F04 A4 (owner
samples), F15 A4 (phone timing), F22 A1 (Android process death), F23 A2 native notices, F25 A4
(owner visual acceptance), F25 A3 human comprehension (UNVERIFIED), and every device, emulator,
remote CI and live-provider row of G1. F26 and G2–G4 are not started: they need an Android build,
a phone and the owner.
