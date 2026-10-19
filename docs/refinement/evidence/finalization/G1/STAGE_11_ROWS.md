# G1 — the Stage 11 matrix rows: reused, invalidated, re-verified

Date 2026-10-19, a later cloud session, code at `e6a0376` (develop). Environment: Linux container,
Flutter 3.47.4 / Dart 3.13.3 (the CI pin); no Android SDK, emulator or phone; outbound hosts
limited by the environment's network policy (the same limits as the [G1 record](README.md)).
Documentation only: no application, test, dependency or tooling file is changed by this record;
one temporary probe (P-H2 below) was run and deleted, never committed.

**Why this record exists.** G1's first bullet (`FINAL_COMPLETION_ROADMAP.md`, "G1 — Freeze the
final acceptance rows and qualify the pre-packaging baseline") asks for "each F-task A-criterion
plus the relevant `STAGE_11_MATRIX.md` rows", unchanged evidence "reused with baseline and
reason", and invalidated or new rows enumerated "rather than re-running the historical matrix
wholesale". The [G1 record](README.md) covers the F rows and G1's own rows; this file covers
every row of [`STAGE_11_MATRIX.md`](../../../STAGE_11_MATRIX.md) §2 (groups A–Q, 130 rows), each
judged at the level the matrix states (its §1 rules: a host test never satisfies a DEVICE row, an
emulator run never satisfies a DEVICE row).

## Baselines

| Key | What | Inputs it ran on |
| --- | --- | --- |
| S11 | The Stage 11 evidence: [host](../../STAGE_11_HOST_EVIDENCE.md) (S11.2; the full gate at `9668a13`, 1,840 tests), [emulator](../../STAGE_11_EMULATOR_RUNS.md) (S11.3; release x86_64 APK, app code `43523bb`, id `io.github.chacha12.astroplanner`), [providers and compliance](../../STAGE_11_PROVIDERS_COMPLIANCE.md) (S11.4, `9668a13`); S11.C1 (S11F-01) and S11.C2 (S11H-01 to S11H-03) corrected | 2026-09-30 |
| S12/13 | [Stages 12–13 closure](../../../STAGE_12_13_CLOSURE.md): identity `io.github.buffur.culmina` and Culmina (S13.2), the policy and project pages live with the contact (S12.3), the first green remote CI (S12.1), R3-final icon and splash (S13.3) | `570581e`, 2026-10-17 |
| G | The G1 full gate (`dart run tool/check.dart`): `+2246 ~5`, host E2E `core_loop` `+2`, `perf_scenarios` `+1` ([G1 record](README.md), "Gate runs") | `e13eccc`, 2026-10-19 |
| R1 | **This record:** the matrix rows' named host test files (every file `STAGE_11_HOST_EVIDENCE.md` and the matrix name, all still present) plus the F-task files they now depend on: 111 files, `flutter test --no-pub <files>` → `+1274: All tests passed!` | `e6a0376` |
| R2 | **This record:** `flutter test --no-pub integration_test/core_loop_test.dart -d flutter-tester` → `+2: All tests passed!` | `e6a0376` |
| R3 | **This record:** 53 further test files named in the F evidence records (F03–F25) for the surfaces below → `+361: All tests passed!` | `e6a0376` |

**Why G alone does not cover `e6a0376`.** After the G1 gate, nine commits changed application or
test code (`9ac8d7b` F01, `c9ab23c` F04, `dd5dae7` F17/F18/F21, `ccc7fc2` F09/F10/F23, `47c8ee8`
F25 A2, `143fac0` and `17b260a` tests plus the F19 Logbook line, `1469731` F15, `e6a0376` F25 A1).
Under V3 the gate's result is not valid for those inputs; R1–R3 re-run the files of the rows those
commits touch. R1–R3 are targeted runs, not the full gate (encoding, format, analyze, the whole
suite and `perf_scenarios` were not re-run): row P1 records that.

**Why almost no Stage 11 host row is plain REUSED.** The application code changed from
`9668a13` to `e6a0376` in nearly every area (S11.C2, the S13.2 rename, the UX-copy pass `322edbd`,
F01–F25 and the audits). A row is REUSED only where no change touched its surface or its evidence
is an owner decision or a dated fact that nothing since contradicts. Every other HOST row is
INVALIDATED and re-verified on `e6a0376` (R1–R3); every invalidated EMULATOR, PHONE or HUMAN row is
UNVERIFIED here, because this environment has no emulator, phone or participant, and is carried to
G2 (or to G1's environment rows, which need an Android SDK or network access).

## Status vocabulary

As in the [G1 record](README.md): **VERIFIED (host)** — the row's required evidence is complete at
its stated host level; **VERIFIED (documented)** — a DOCUMENTED row's dated record holds;
**IMPLEMENTED** — behaviour and host evidence exist, the row's own level is not reached;
**UNVERIFIED** — required evidence missing for a reason outside the code (named); **OWNER
ACTION** — needs the owner; **DEFERRED** — deferred by an approved decision (cited). **NOT MET**
marks a row whose re-verification found a contradiction (a finding below).

Dispositions: **REUSED** (baseline, reason); **INVALIDATED → re-verified** (the F task that changed
the surface; the new host evidence); **INVALIDATED → UNVERIFIED** (reason; destination);
**OWNER ACTION**; **DEFERRED** (decision). "As amended" names an approved decision that changed the
row's criterion; the row is judged against the amended criterion and the original wording is not
edited (the matrix stays frozen).

## Rows

### A — Core planning answer and comprehension

| ID | Check (short) | Level / env | Affected by | Disposition | Status |
| --- | --- | --- | --- | --- | --- |
| A1 | Planner first screen (412 × 915, three themes): target, night, site, rig, state, verdict, needed/usable time, integration, limiting reason, next action | TEST / HOST | F11, F12, F18 (hierarchy; the target chart left the plan), `dd5dae7` | **INVALIDATED → re-verified:** `planner_structure_test.dart` (status, context, target, rig, capture plan, conditions; opportunity and fit still computed), `planner_defaults_test.dart` (R1); `planner_f18_test.dart`, `reference_plan_density_test.dart` (R3); F25 A1 renders | VERIFIED (host) |
| A2 | A missing site, target or light block gives its own neutral reason; integration stays visible | TEST / HOST | F05 (missing-input reasons), F12 A2, F18 A5 (the save reason) | **INVALIDATED → re-verified:** `planner_structure_test.dart`, `planner_defaults_test.dart` (R1); `planner_f18_test.dart`, `capture_plan_widget_test.dart` (R3) | VERIFIED (host) |
| A3 | Every pre-Stage-6 value reachable one level down (ADR-009 lines, assumptions, rig specifications, sky detail, twilight names, excluded-interval reasons) | TEST / HOST | F12 (effective assumptions), F15 (Night & Moon), F18 A1 (the target's window list left the plan) | **INVALIDATED → re-verified** as amended by F18 A1 (windows stay computed and in Night & Moon, not drawn in the plan): `planner_disclosure_test.dart`, `detail_screens_test.dart`, `twilight_bands_test.dart` (R1); `capture_assumptions_test.dart`, `night_moon_browse_test.dart` (R3) | VERIFIED (host) |
| A4 | One-level disclosure with factual summaries; the "never hidden" list visible; nothing essential only in a tooltip | TEST / HOST | F11 (O2b curve in collapsed Details), F12, F18 A1 (current sky as a labelled detail, `dd5dae7`) | **INVALIDATED → re-verified:** `planner_disclosure_test.dart`, `stacking_gain_graph_test.dart` (R1); `planner_f18_test.dart` (R3) | VERIFIED (host) |
| A5 | Tonight leads with the current plan; Night and Moon, Weather and result rows open their own destinations; no "Draft" or "Analytics" | TEST / HOST | F17 (Home leads with the night's facts, then "Your plan"; AM03-T = B), F14, F15 | **INVALIDATED → re-verified** as amended by F17 A1–A5 (the night card precedes "Your plan"): `tonight_home_screen_test.dart`, `detail_screens_test.dart`, `retired_terms_test.dart` (R1); `home_night_card_test.dart`, `plan_night_phrase_test.dart` (R3) | VERIFIED (host) |
| A6 | App bar target · night · state; New plan, Copy, Open, Save confirm; Save · Discard · Cancel; Discard reverts or deletes only a never-saved draft | TEST / HOST | F17 (Home's New plan removed; the planner's guarded menu kept), F18 (stable Save), F19 (Saved · changed during its night) | **INVALIDATED → re-verified:** `plan_identity_actions_test.dart`, `unsaved_plan_prompt_test.dart`, `drift_session_discard_test.dart` (R1) | VERIFIED (host) |
| A7 | "What can I image tonight?" by usable time, frame fill (unknown last), name; header names the order; no score | TEST / HOST | F13 (one Moon-up predicate in `candidate_evaluator.dart`), F17 (candidates secondary, plan-night phrase) | **INVALIDATED → re-verified:** `candidate_evaluator_test.dart`, `tonight_candidates_screen_test.dart` (R1) | VERIFIED (host) |
| A8 | Five-second test by a participant who has not worked on the product | HUMAN (PHONE) | F17, F18 (both first screens changed) | **INVALIDATED → UNVERIFIED:** never verified (S6.E, gap accepted by the owner, not D11-2); no participant here. Carried to G2/G3 as the recorded gap | UNVERIFIED |
| A9 | The owner's comprehension scenarios on the final build | HUMAN (PHONE) | F05–F21 (every scenario's surface) | **INVALIDATED → UNVERIFIED:** no earlier evidence; F25 A3's four W journeys pass on the host, comprehension is UNVERIFIED there too. Carried to G2 | UNVERIFIED |
| A10 | TASK 12.5 walkthrough: fresh install first-run page, GPS after the rationale and by hand, second install, Tonight at large text | HUMAN (PHONE) | F16 (Welcome replaces the first-run page), F05, F23 | **INVALIDATED → UNVERIFIED:** host `welcome_screen_test.dart` (R1) only. Carried to G2 | UNVERIFIED |

### B — Night, timeline and opportunity

| ID | Check (short) | Level / env | Affected by | Disposition | Status |
| --- | --- | --- | --- | --- | --- |
| B1 | The timeline's drawn intervals equal `imagingOpportunity` and the fit's end; no continuity across a gap | TEST / HOST | F18 A1 (the target chart and window list left the plan; `TonightOpportunityWidget` now has no caller in `lib/`), F13 | **INVALIDATED → re-verified** for what remains (on-screen part superseded by F18 A1): `timeline_test.dart`, `planner_structure_test.dart`, `imaging_opportunity_calculator_test.dart` (R1); `tonight_opportunity_widget_test.dart`, `altitude_chart_widget_test.dart` (R3). Follow-up G1-S11-02 | VERIFIED (host) |
| B2 | UX-08 axis: 12/24 h, site zone, whole-hour ticks (half-hour zone, DST), labels at 100/200 %, field-mode band edges | TEST / HOST | F18 A1 (chart not shown); F15 (the shared night bar, DST zone names) | **INVALIDATED → re-verified** at widget level: `timeline_test.dart` (R1); `night_moon_browse_test.dart`, `night_view_test.dart` (R3) | VERIFIED (host) |
| B3 | Text alternatives: timeline, √N graph, Weather's cloud bars, Night & Moon's twilight timeline, with unknown and empty states | TEST / HOST | F11 (O2b curve), F14 (night card, hour strip), F15 (shared bar, slider `1469731`) | **INVALIDATED → re-verified:** `timeline_test.dart`, `stacking_gain_graph_test.dart`, `detail_screens_test.dart`, `twilight_bands_test.dart`, `accessibility_test.dart` (R1); `night_moon_browse_test.dart`, `forecast_nights_test.dart` (R3) | VERIFIED (host) |
| B4 | The dark span and Tonight's Dark row use the user's darkness limit, not a fixed −18° | TEST / HOST | F14 (dark-span slicing), F17 (Home's night card) | **INVALIDATED → re-verified:** `dark_span_test.dart`, `tonight_home_screen_test.dart`, `night_weather_summarizer_test.dart` (R1); `home_night_card_test.dart` (R3) | VERIFIED (host) |
| B5 | Excluded periods keep reasons; unknown never excludes; Moon and cloud gates off by default, set in Settings, change usable time | TEST / HOST | F13 (MF-c Moon-up predicate for the Moon gate), F12 (Settings grouping) | **INVALIDATED → re-verified:** `imaging_opportunity_calculator_test.dart`, `moon_up_predicate_test.dart`, `settings_rebuilt_test.dart` (R1); `settings_screen_test.dart` (R3) | VERIFIED (host) |
| B6 | TASK 2.4: device zone America/Los_Angeles at 18:30; Tonight and the planner show that evening as tonight | RUNTIME (emulator) / EMULATOR | F17 (title follows the plan's night), F18 (plan-night phrase), app id and build (S13.2) | **INVALIDATED → UNVERIFIED** (no emulator). Host: `session_night_resolver_test.dart`, `night_time_formatter_zone_test.dart` (R1), `planner_session_date_test.dart` (R3), R2's zone test. Carried to the G1 emulator row / G2 | UNVERIFIED |
| B7 | Times only from SessionNight with the zone rule; no `DateTime.now()` in `lib/domain`; no night from a `DateTime`'s Y/M/D | TEST / HOST | F19 (`saved_night_end.dart`, `session_reconciliation.dart`), F24 A1 (tests never read the wall clock) | **INVALIDATED → re-verified:** `clock_test.dart`, `session_night_resolver_test.dart`, `night_time_formatter_zone_test.dart` (R1) | VERIFIED (host) |
| B8 | Weather detail: age, stale label, unknowns, units, attribution, horizontal-visibility wording; no score; no "Tap to set location" without an action | TEST / HOST | F14 (coverage, lead time apart from age, Details), F21 (units), F25 A2 (`47c8ee8`) | **INVALIDATED → re-verified:** `weather_forecast_widget_test.dart`, `detail_screens_test.dart`, `night_summary_text_test.dart`, `display_units_paths_test.dart` (R1); `forecast_nights_test.dart` (R3) | VERIFIED (host) |
| B9 | Sky darkness value first (Bortle, SQM) with source and local date; unknown with the way to set it; no inference or conversion | TEST / HOST | F15 (`sky_darkness_widget.dart`), F25 A2 | **INVALIDATED → re-verified:** `sky_darkness_context_test.dart` (R1); `sky_darkness_moon_test.dart`, `planner_sky_darkness_test.dart` (R3) | VERIFIED (host) |

### C — Budget, fit, √N and storage

| ID | Check (short) | Level / env | Affected by | Disposition | Status |
| --- | --- | --- | --- | --- | --- |
| C1 | Status and outputs equal `CaptureBudgetCalculator` and `FitAnalyzer` on ADR-009 E1–E8c | TEST / HOST | F07, F11 (`capture_budget_calculator.dart`), F25 A2 (`fit_analyzer.dart` reason text) | **INVALIDATED → re-verified:** `capture_budget_calculator_test.dart`, `fit_analyzer_test.dart`, `in_camera_noise_reduction_test.dart`, `planner_structure_test.dart` (R1) | VERIFIED (host) |
| C2 | Integration ≠ imaging ≠ total time; every ADR-009 line in Budget details; calibration never integration | TEST / HOST | F12 (effective assumptions), F09 (calibration) | **INVALIDATED → re-verified:** `planner_disclosure_test.dart`, `capture_budget_calculator_test.dart` (R1); `capture_assumptions_test.dart` (R3) | VERIFIED (host) |
| C3 | "What fits" only from `maxFramesForBlock` / `unplacedFramesByBlock`; honest where the API cannot answer | TEST / HOST | F12 (every light block's fit; TD-074 part 1 resolved) | **INVALIDATED → re-verified:** `capture_outputs_test.dart` (R1); `capture_plan_widget_test.dart` (R3); F12 evidence | VERIFIED (host) |
| C4 | Relative stacking gain √N vs one frame per group, never combined, never SNR; plan's point identified; text alternative | TEST / HOST | F11 (groups by recorded settings, C16; O2b in Details) | **INVALIDATED → re-verified** as amended by PD-05 = O2b and ADR-021 C16 (groups by normalized filter, exposure, recorded ISO/gain, binning; SI-003 holds): `stacking_gain_curve_test.dart`, `stacking_gain_graph_test.dart` (R1); `light_groups_test.dart` (R3); F11 vectors R-O2-1/V12 | VERIFIED (host) |
| C5 | Storage: known RAW size with unit; unknown with reason and remedy; "no theoretical RAW payload anywhere" | TEST / HOST | F07 (evidence, then theory, else Unknown), F10, `c9ab23c` | **INVALIDATED → re-verified** as amended by PD-06 and ADR-021 (a theoretical size only from an evidenced uncompressed format; SI-013 resolved): `storage_estimate_test.dart`, `capture_outputs_test.dart` (R1); `storage_display_test.dart`, `equipment_draft_storage_test.dart`, `capture_evidence_test.dart` (R3) | VERIFIED (host) |
| C6 | Capability guidance reads the plan's effective tracking; unknown neutral; never blocks | TEST / HOST | F25 A2 (`capability_text.dart` formatting only) | **INVALIDATED → re-verified:** both `plan_tracking_test.dart` files (R1) | VERIFIED (host) |
| C7 | No composite score, percentage or good/bad rating; thresholds stay preferences with units and ranges | TEST / HOST | F14, F17 (night card), F12 (Settings) | **INVALIDATED → re-verified:** `tonight_candidates_screen_test.dart`, `candidate_evaluator_test.dart`, `night_summary_text_test.dart`, `planning_preferences_test.dart` (R1); `home_night_card_test.dart` (R3) | VERIFIED (host) |
| C8 | No calculation in widgets; quantities through `QuantityText`; colours through tokens | TEST / HOST | S11.C2 (S11H-02), F25 A2 (TD-101: `quantity_text_usage_test.dart`; widened by `47c8ee8`) | **INVALIDATED → re-verified:** `quantity_text_usage_test.dart`, `quantity_text_test.dart`, `presentation_style_rules_test.dart`, `app_theme_test.dart` (R1); `design_tokens_test.dart` (R3) | VERIFIED (host) |

### D — Capture and calibration forms

| ID | Check (short) | Level / env | Affected by | Disposition | Status |
| --- | --- | --- | --- | --- | --- |
| D1 | Light block fields by camera class; binning by class; a hidden stored value kept, named, exported, never converted | TEST / HOST | F03 (v26), F06 (AM-04: familiar fields, C13 sensitivity), F09 audit (`ccc7fc2`: binning by class) | **INVALIDATED → re-verified** as amended by AM-04 (binning an astro-only advanced field; Unknown records no sensitivity, C13): `light_block_form_test.dart`, `camera_class_test.dart`, `calibration_blocks_test.dart` (R1); `block_settings_test.dart` (R3) | VERIFIED (host) |
| D2 | A new light block proposes the previous one's values, marked, stored only by Save; "Time between frames" label and help only | TEST / HOST | F06 (origins through edits), F08 (photo proposals) | **INVALIDATED → re-verified:** `light_block_form_test.dart` (R1); `block_values_in_plan_test.dart`, `block_from_photo_test.dart` (R3) | VERIFIED (host) |
| D3 | Calibration matrix per type and class; inherited values with origin; "Use other values"; non-blocking match warnings with fix and Undo | TEST / HOST | F09 (whole-tuple matching, CAL-1 preview, `ccc7fc2`) | **INVALIDATED → re-verified:** `calibration_blocks_test.dart`, `calibration_match_test.dart` (R1); `calibration_coverage_test.dart`, `calibration_preview_test.dart` (R3) | VERIFIED (host) |
| D4 | Dark flat round-trips through store, snapshot, export; tips one line, hideable, hide no warning | TEST / HOST | F03 (v26 contract), F09 | **INVALIDATED → re-verified:** `calibration_blocks_test.dart`, `session_manifest_codec_test.dart` (R1); `capture_contract_round_trip_test.dart` (R3) | VERIFIED (host) |
| D5 | In-camera noise reduction only for DSLR/mirrorless and Unknown, off by default; E8–E8c hold; "darks twice" | TEST / HOST | F09 (LENR in the CAL-1 preview) | **INVALIDATED → re-verified:** `in_camera_noise_reduction_test.dart`, `in_camera_noise_reduction_ui_test.dart` (R1) | VERIFIED (host) |
| D6 | Rig form: pixel size once; optional fields under "More"; class the user's choice; nothing lost; fits at 200 % | TEST / HOST | F05 (class-first creation, PD-07 C1-b), F07 (storage fields), F10 | **INVALIDATED → re-verified:** `rig_form_test.dart`, `equipment_editor_fit_test.dart`, `camera_class_test.dart` (R1); `rig_creation_test.dart`, `rig_created_for_plan_test.dart` (R3) | VERIFIED (host) |
| D7 | Block rows lead with identity and quantities; delete with exact Undo; Fill, Trim and "Start from the example plan" undoable | TEST / HOST | F09 A6 (the empty plan's next step replaced "Start from the example plan"), F06 | **INVALIDATED → re-verified** as amended by F09 A6: `capture_blocks_test.dart`, `capture_blocks_undo_test.dart` (R1); `capture_plan_widget_test.dart` (R3) | VERIFIED (host) |

### E — Automation honesty

| ID | Check (short) | Level / env | Affected by | Disposition | Status |
| --- | --- | --- | --- | --- | --- |
| E1 | Target search by designation, alias, common name, offline; `catalogId` unchanged; deleted stays deleted | TEST / HOST | F24 A6 (newest-query search) | **INVALIDATED → re-verified:** `target_search_test.dart`, `catalog_aliases_test.dart` (R1); `target_search_race_test.dart` (R3) | VERIFIED (host) |
| E2 | Site form: elevation null when unknown; GPS only on tap, only into the form; no write without Save; Bortle/SQM manual; leave guard | TEST / HOST | F23 A1/A5/A6/A7 (names, kept coordinate edits, consented lookup, labels), F21 (m/ft) | **INVALIDATED → re-verified:** `sites_screen_test.dart`, `display_units_paths_test.dart` (R1); `site_label_test.dart` (R3); F23 evidence | VERIFIED (host) |
| E3 | "Add from a photo": per-field provenance, never a class; nothing written before Save; existing rig recognised; snapshot provenance | TEST / HOST | F04 (`c9ab23c`), F05, F08, F10 (FITS) | **INVALIDATED → re-verified:** `metadata_import_review_test.dart`, `equipment_add_from_photo_test.dart`, `equipment_editor_prefill_test.dart`, `session_snapshot_builder_test.dart`, `fits_metadata_reader_test.dart` (R1); `metadata_import_review_db_test.dart`, `fits_import_test.dart`, `capture_metadata_f04_test.dart`, `tiff_metadata_reader_test.dart` (R3) | VERIFIED (host) |
| E4 | Unknown stays unknown: example rig's tracking and class Unknown; no default elevation, Bortle or file size | TEST / HOST | F05 A3 (the example rig is `astroColour` with cited sources) | **INVALIDATED → re-verified** as amended by PD-07 C1-d (superseding ADR-020 §2's Unknown example class; tracking, elevation, Bortle, size still unknown): `equipment_example_test.dart`, `camera_class_test.dart`, `capture_outputs_test.dart` (R1); `rig_creation_test.dart` (R3) | VERIFIED (host) |
| E5 | M1–M3: a picked DNG, JPEG and HEIC read in place, bounded, no cache copy | DEVICE / PHONE | F04 (metadata contract, `c9ab23c`), F10 (reader dispatch) | **INVALIDATED → UNVERIFIED:** the 2026-09-26 run and S13.2's 2026-10-17 DNG/HEIC run predate F04. Host synthetic tests pass (R1, R3); owner samples (F04 A4) and the phone (G2) | UNVERIFIED |
| E6 | M4 on the final build: Library → Rigs → "Add from a photo" (DNG and JPEG/HEIC), Save, "You already have this rig", no cache copy | DEVICE / PHONE | F05 (class-first panel), F08 | **INVALIDATED → UNVERIFIED** (S13.2's M4 run predates F05). Carried to G2 | UNVERIFIED |
| E7 | S2V-06: a non-seekable provider pick and a cancelled real-backup preview leave no picker copy | DEVICE / PHONE | F01 (restore candidates, `9ac8d7b`) | **INVALIDATED → UNVERIFIED** (never run on a phone). Carried to G2 | UNVERIFIED |

### F — Saved plan → result → Logbook; legacy runs; portability

| ID | Check (short) | Level / env | Affected by | Disposition | Status |
| --- | --- | --- | --- | --- | --- |
| F1 | A saved night ends at CALC-44; the planner continues on one copy; saved entry and snapshot unchanged, open and after restart | TEST / HOST | F19 (`saved_night_end.dart`, `session_reconciliation.dart`) | **INVALIDATED → re-verified:** `saved_plan_transition_test.dart`, `drift_session_results_test.dart` (R1); R2 | VERIFIED (host) |
| F2 | Result form: Completed / Partly / Not done; reviews the snapshot; Back writes nothing; stale form and failed write; "no result before the night ends" | TEST / HOST | F19 (early results; AM-01), F22 (a restored form writes nothing until Save) | **INVALIDATED → re-verified** as amended by AM-01 / F19 A2 (the current saved night can be reported from its stored window's start; a future night is refused): `results_screen_test.dart`, `lifecycle_matrix_test.dart` (R1); `results_unreadable_plan_test.dart` (R3) | VERIFIED (host) |
| F3 | Tonight's "Last night: … How did it go?" only when due; opens the form; gone after Save result | TEST / HOST | F17 (Home), F19 | **INVALIDATED → re-verified:** `saved_plan_transition_test.dart`, `tonight_home_screen_test.dart` (R1); R2 | VERIFIED (host) |
| F4 | No live tracking anywhere; in-progress, corrected and abandoned legacy runs open, list, export, back up; in-progress recordable | TEST / HOST | F03 (v26 migration) | **INVALIDATED → re-verified:** `live_runs_survive_test.dart`, `schema_migration_test.dart` (R1) | VERIFIED (host) |
| F5 | Logbook: Upcoming/Past, search, one filter panel, delete confirmation, Progress by target | TEST / HOST | F19 (result states), F20 (AstroBin), `17b260a` (the "when a result can be recorded" line) | **INVALIDATED → re-verified:** `logbook_screen_test.dart`, `logbook_comes_back_test.dart` (R1) | VERIFIED (host) |
| F6 | Optional name: never asked at Save, not copied, not in the snapshot; listed, searched, exported, backed up; id unchanged | TEST / HOST | F03 (v26), F22 A3 (kills) | **INVALIDATED → re-verified:** `schema_migration_test.dart`, `session_detail_test.dart`, `backup_restore_test.dart`, `lifecycle_matrix_test.dart` (R1) | VERIFIED (host) |
| F7 | Entry: identity, night, target, site, rig, result, planned vs actual, blocks, notes, conditions; actions by state; legacy "Old log" | TEST / HOST | F06 (WB/AF-MF records), F19 (saved forecast), F20, F21 (units), `47c8ee8` | **INVALIDATED → re-verified:** `session_detail_test.dart`, `entry_share_text_test.dart` (R1) | VERIFIED (host) |
| F8 | Share text without notes or coordinates; Export as file the one-session manifest v2, apart from Share | TEST / HOST | F03 (additive manifest keys, `manifest_version` still 2 in `session_manifest_codec.dart`), F20 (CSV kept apart), F21, `47c8ee8` | **INVALIDATED → re-verified:** `entry_share_text_test.dart`, `session_manifest_codec_test.dart` (R1); R2 (re-parses the export) | VERIFIED (host) |
| F9 | Every supported schema (v8 → v25) upgrades keeping rows, events, counters, snapshots; below-floor and newer refused before any statement | TEST / HOST | F03 (schema **v26**) | **INVALIDATED → re-verified** as v8 → **v26**: `test/data/database/schema_migration_test.dart` (every version to v26), `test/data/database/unsupported_database_test.dart`, `test/data/database/app_database_test.dart` (R1); `capture_contract_round_trip_test.dart` (R3) | VERIFIED (host) |
| F10 | Export round-trips `result_kind`, `not_done_reason`, `reported`, `name`, `tracking_override`; a pre-S8.1 file reads; `manifest_version` 2 | TEST / HOST | F03 (block keys), F20 | **INVALIDATED → re-verified:** `session_manifest_codec_test.dart` (R1); `capture_contract_round_trip_test.dart` (R3) | VERIFIED (host) |
| F11 | Backup format 2 carries planning and display preferences, active site, first-run flag, not transient state; restore and reset clear plan ids; a version 1 archive restores | TEST / HOST | F01 (restore candidates, activation at once, `9ac8d7b`), F21 (every preference value; units, appearance) | **INVALIDATED → re-verified** (`BackupArchive.formatVersion` still 2): `backup_restore_test.dart`, `preferences_round_trip_test.dart`, `restore_activation_test.dart` (R1) | VERIFIED (host) |
| F12 | Names and result fields survive a process restart (host harness) and the migration path | TEST / HOST | F22 A3 (TD-102's kill/upgrade half committed: `lifecycle_matrix_test.dart` L4b; S11H-07 resolved) | **INVALIDATED → re-verified**, now by committed tests instead of S11.2's probes: `lifecycle_matrix_test.dart`, `route_restoration_test.dart`, `schema_migration_test.dart` (R1) | VERIFIED (host) |
| F13 | TASK 14.4 round trip on the emulator: back up, uninstall, reinstall, restore, reopen; a newer backup refused | RUNTIME (emulator) / EMULATOR | F01 (restore applied at once), F21 (preferences), S13.2 (id) | **INVALIDATED → UNVERIFIED** (no emulator). Host round trip VERIFIED in the G1 record (R1 re-runs it). Carried to the G1 emulator row and G2 (REL-10 rehearsal) | UNVERIFIED |
| F14 | Android Auto Backup as `DATA_MODEL.md` B7 documents | RUNTIME (emulator) / EMULATOR | S13.2 (id), F14/F21 (new preference stores) | **INVALIDATED → UNVERIFIED** (no emulator). Carried to the G1 emulator row | UNVERIFIED |
| F15 | Share opens the system sheet (no notes, no coordinates); Export as file a `.json` in the local date | RUNTIME (emulator) / EMULATOR | F20 (CSV share added), F21 (units in the text) | **INVALIDATED → UNVERIFIED** (no emulator). Host: `entry_share_text_test.dart`, `file_names_test.dart` (R1), `share_astrobin_csv_exporter_test.dart` (R1). Carried | UNVERIFIED |
| F16 | Refused-database flow: newer database explained with no reset; below-floor asks, keeps `.v<N>.bak`, restarts fresh | RUNTIME (emulator) / EMULATOR | F03 (v26 ceiling), F01 | **INVALIDATED → UNVERIFIED** (no emulator). Host: `unsupported_database_test.dart` (R1). Carried | UNVERIFIED |

### G — Library, Settings, About, branding, licence

| ID | Check (short) | Level / env | Affected by | Disposition | Status |
| --- | --- | --- | --- | --- | --- |
| G1 | A Library tap opens the editor, plan and active site unchanged; `/select/…` chooses; "Plan this target" under the guard | TEST / HOST | F05 (Library save-only; D8 selection) | **INVALIDATED → re-verified:** `library_manage_mode_test.dart` (R1); `app_shell_navigation_test.dart` (R3) | VERIFIED (host) |
| G2 | Rigs, targets, sites delete through Delete and swipe with one confirmation; snapshots keep values | TEST / HOST | F19 A5 (the plan's rig/target Delete, dismissal deletes nothing) | **INVALIDATED → re-verified:** `library_manage_mode_test.dart` (R1) | VERIFIED (host) |
| G3 | Editors use `AppWords` and one primary Save; the retired-terms baseline is empty | TEST / HOST | F19 (`app_words.dart`), F05 | **INVALIDATED → re-verified:** `retired_terms_test.dart`, `secondary_forms_test.dart` (R1); `secondary_consistency_test.dart` (R3) | VERIFIED (host) |
| G4 | Settings: sections; value, unit, consequence; interval to 120 s; overheads; gates; writes through `runWithFeedback`; Restore confirmed | TEST / HOST | F12 (basic/advanced/guidance), F21 (Appearance and units; shown vs stored with Retry), `dd5dae7`, `e6a0376` | **INVALIDATED → re-verified:** `settings_rebuilt_test.dart`, `backup_section_test.dart` (R1); `settings_screen_test.dart`, `settings_persistence_test.dart`, `display_settings_test.dart`, `place_name_switch_persistence_test.dart` (R3) | VERIFIED (host) |
| G5 | About: author block first, version, each credit linked; source, project, policy links "unchanged until RD-01" | TEST / HOST | S13.2 (RD-01 decided: Buffur/Culmina URLs), F23 A2 audit (`ccc7fc2`: the GPL-3.0 §7 statement), F14 | **INVALIDATED → re-verified:** `about_screen_test.dart` (R1) | VERIFIED (host) |
| G6 | About's links open their pages from the emulator; source, project, policy state recorded | RUNTIME (emulator) / EMULATOR | S13.2 (URLs), F23 | **INVALIDATED → UNVERIFIED:** no emulator; host reads in the G1 record: `github.com/Buffur/Culmina` 200, the other hosts refused by the network policy. Carried to the G1 link row | UNVERIFIED |
| G7 | Branding as built: launcher "Astro Planner", today's icon, night-navy splash, `io.github.chacha12.astroplanner` | RUNTIME (emulator) / EMULATOR | S13.2/S13.3 (Culmina, `io.github.buffur.culmina`, R3-final, animated splash), F02 (the pre-Android-12 splash) | **INVALIDATED → UNVERIFIED** as amended by ID-1–ID-6 and S13.3: host `app_identity_test.dart` (R1; F02 A1); the API 26–30 launch (F02 A2/A3) needs an Android SDK; physical S13V-02/03 at G2 | UNVERIFIED |
| G8 | Licence GPL-3.0 in `LICENSE` and About; OpenNGC CC BY-SA 4.0 notice shipped and shown; nothing changed by an agent | TEST / HOST | F23 A2 audit (About states the S12.4 §7 permission); `LICENSE` and `OPENNGC_NOTICE.txt` unchanged since `2b467b8` | **INVALIDATED → re-verified:** `about_screen_test.dart` (R1) | VERIFIED (host) |
| G9 | `showDone` after saves, deletes, backup, staged/cancelled restore, rename, export; none where the effect shows; local-date names | TEST / HOST | F01 (`9ac8d7b`: a dismissed share is not a backup), F20, F21 | **INVALIDATED → re-verified:** `app_messages_test.dart`, `backup_section_test.dart`, `file_names_test.dart`, `restore_outcome_notice_test.dart` (R1) | VERIFIED (host) |

### H — Accessibility

| ID | Check (short) | Level / env | Affected by | Disposition | Status |
| --- | --- | --- | --- | --- | --- |
| H1 | The sweep covers every new or changed screen, three themes × 100/200 % at 412 px: overflow, targets, labels, contrast | TEST / HOST | S11.C2 (S11H-01), F25 A1 (sweep extended to editors, dialogs, filter panel, AstroBin preview, map picker; TD-100), F15 (`/night` overflows fixed), `e6a0376` (Retry contrast) | **INVALIDATED → re-verified:** `accessibility_test.dart` (R1); F25 A1 renders | VERIFIED (host) |
| H2 | Every icon-only button has a tooltip; a relabelling `Semantics(excludeSemantics: true)` passes `onTap` and `enabled` | TEST / HOST | F14 (`weather_forecast_widget.dart` hour slot), F15 (`night_browser_sections.dart` calendar day) | **INVALIDATED → NOT MET** (finding G1-S11-01): all 17 `IconButton`s in `lib` have a `tooltip` (code), `collapsible_section_test.dart` and `context_line_test.dart` pass (R1); two new relabelling `Semantics` buttons pass no `onTap` (probe P-H2) | NOT MET |
| H3 | At 200 % the answer, verdict, rows, filters, dialogs, Settings, Logbook wrap and grow; a squeezed graphic gives way to text | TEST / HOST | F14–F21 (new screens), F25 A1 (200 % renders, keyboard at 200 %) | **INVALIDATED → re-verified:** `accessibility_test.dart`, `capture_blocks_test.dart`, `light_block_form_test.dart`, `equipment_editor_fit_test.dart`, `session_detail_test.dart`, `timeline_test.dart` (R1); F25 A1 renders | VERIFIED (host) |
| H4 | Reduced motion: messages do not slide, no change emphasis, nothing only in motion, nothing waits for an animation | TEST / HOST | S13.3 (animated splash), F15 (slider) | **INVALIDATED → re-verified** on the host: `app_messages_test.dart`, `capture_blocks_test.dart`, `capture_blocks_undo_test.dart` (R1). The splash under reduced motion is S13V-02 (physical, G2) | VERIFIED (host) |
| H5 | Colour never carries a verdict, warning, stale state or selection alone | CODE + TEST / HOST | S11.C2 (S11H-03), F14 (selected hour: border), F15 (viewed day: border width; hatched Moon-up with legend), F19 (result states in words and an icon) | **INVALIDATED → re-verified:** the new selections carry a border and `selected` semantics (code); `night_moon_browse_test.dart`, `forecast_nights_test.dart` (R3); `logbook_screen_test.dart`, `weather_forecast_widget_test.dart` (R1). No global colour-only rule test exists (per-task tests) | VERIFIED (host) |
| H6 | TalkBack on the core flow at the largest font, and in field mode | DEVICE / PHONE (**D11-2**) | F16–F22 (every step of the flow); G1-S11-01 | **INVALIDATED → UNVERIFIED** (never run). Carried to G2 | UNVERIFIED |
| H7 | TalkBack on the other flows (Logbook search and filters, delete confirmations, Library, Settings) | DEVICE / PHONE | F19, F21, F23; G1-S11-01 | **INVALIDATED → UNVERIFIED** (never run). Carried to G2 | UNVERIFIED |

### I — Field (red) mode

| ID | Check (short) | Level / env | Affected by | Disposition | Status |
| --- | --- | --- | --- | --- | --- |
| I1 | Field tokens red or black only; `AppTheme.fieldFilter`; survives a restart | TEST / HOST | F21 (Appearance System/Light/Dark; field mode unchanged), F25 (`app_theme.dart`), `e6a0376` | **INVALIDATED → re-verified:** `app_theme_test.dart`, `field_mode_darkness_test.dart` (R1); `controls_theme_test.dart` (R3) | VERIFIED (host) |
| I2 | TASK 12.4 darkness checklist in real darkness | HUMAN (PHONE) | F14–F21 (new screens) | **INVALIDATED → UNVERIFIED** (never run). Carried to G2 | UNVERIFIED |
| I3 | Field mode readable in real darkness; colour never the only carrier; B16 exceptions noted | HUMAN (PHONE) | F14–F21 | **INVALIDATED → UNVERIFIED** (never run). Carried to G2 | UNVERIFIED |

### J — Degraded and offline states

| ID | Check (short) | Level / env | Affected by | Disposition | Status |
| --- | --- | --- | --- | --- | --- |
| J1 | Weather unavailable: planning continues, Retry, no number; stale labelled with age and re-ages; never stale as fresh | TEST / HOST | F14 (site-cell cache, coverage), `e6a0376` | **INVALIDATED → re-verified:** `weather_forecast_widget_test.dart`, `night_weather_service_test.dart`, `forecast_freshness_test.dart`, `lifecycle_matrix_test.dart` L1 (R1); `shared_prefs_weather_snapshot_store_test.dart`, `weather_site_race_test.dart` (R3) | VERIFIED (host) |
| J2 | Place names off: nothing sent; on and failing: name empty and editable; never for a saved site or the default position | TEST / HOST | F23 A1/A5 (municipality names; the new-site offer), F21 A6 (the switch shows what is stored) | **INVALIDATED → re-verified:** `place_name_lookup_test.dart`, `planner_location_test.dart`, `planner_sites_test.dart`, `nominatim_reverse_geocoder_test.dart` (R1); `place_name_switch_persistence_test.dart` (R3) | VERIFIED (host) |
| J3 | Nothing optional blocks startup: no network at startup; weather after the first frame; bootstrap failure retry | TEST / HOST | F16 (first route before the first frame), F01 (restore at startup), F22 (restoration), F24 A5 (startup network barrier) | **INVALIDATED → re-verified:** `planner_bootstrap_test.dart`, `home_screen_test.dart`, `lifecycle_matrix_test.dart` (R1); `current_session_failure_test.dart`, `widget_test.dart` (R3); R2 | VERIFIED (host) |
| J4 | GPS denied or off leaves the site form usable; target search offline; missing tiles do not break the map | TEST / HOST | F24 A2 (committed all-tiles-fail test; S11H-06 resolved), F23, F25 A1 (map attribution) | **INVALIDATED → re-verified:** `location_picker_screen_test.dart`, `sites_screen_test.dart`, `target_search_test.dart` (R1); `location_picker_tiles_failing_test.dart` (R3) | VERIFIED (host) |
| J5 | Airplane mode with data: Tonight, planner, Save, result, Logbook, backup work; weather unavailable or stale; map without tiles | RUNTIME (emulator) / EMULATOR | F14, F16–F19, F01 | **INVALIDATED → UNVERIFIED** (no emulator). Host: `lifecycle_matrix_test.dart` L1 (R1). Carried to the G1 emulator/offline row | UNVERIFIED |

### K — Errors and storage failure

| ID | Check (short) | Level / env | Affected by | Disposition | Status |
| --- | --- | --- | --- | --- | --- |
| K1 | Every changed write reports failure through `runWithFeedback` / `StorageFailure` with the shared text | TEST / HOST | F01 (backup/restore), F19, F20, F21 (settings: unsaved with Retry) | **INVALIDATED → re-verified:** `storage_failure_test.dart`, `failure_feedback_test.dart`, `settings_rebuilt_test.dart`, `lifecycle_matrix_test.dart` L8 (R1); `settings_persistence_test.dart` (R3) | VERIFIED (host) |
| K2 | No empty or comment-only `catch`; errors through `AppLog`; no raw error text | TEST / HOST | F24 A3 (the v10 orphan cleanup through `AppLog`; S11H-08 resolved) | **INVALIDATED → re-verified:** `no_empty_catch_test.dart`, `failure_feedback_test.dart` (R1) | VERIFIED (host) |

### L — Lifecycle and the end-to-end suite

| ID | Check (short) | Level / env | Affected by | Disposition | Status |
| --- | --- | --- | --- | --- | --- |
| L0 | Host lifecycle rows and `core_loop_test.dart` follow Save → result; persistence invariants | TEST / HOST | F09, F16, F18 (`core_loop_test.dart` changed), F22, F24 A1 | **INVALIDATED → re-verified:** `lifecycle_matrix_test.dart`, `route_restoration_test.dart` (R1); R2 (`core_loop` `+2`) | VERIFIED (host) |
| L1 | Fresh install in airplane mode: first-run page, typed site, no forecast with Retry, no crash | RUNTIME or DEVICE / EMULATOR (**D11-2**) | F16 (Welcome), F14, S13.2 (id) | **INVALIDATED → UNVERIFIED** (no emulator). Host L1 (R1). Carried to the G1 emulator row (REL-02) | UNVERIFIED |
| L2 | "Use current position" denied, denied forever, services off: explained after the rationale; site unchanged | RUNTIME or DEVICE / EMULATOR (**D11-2**) | F16 (Welcome's position step), F23 | **INVALIDATED → UNVERIFIED** (no emulator). Host: `location_picker_screen_test.dart`, `planner_location_test.dart`, `welcome_screen_test.dart` (R1). Carried (REL-02) | UNVERIFIED |
| L3 | "Don't keep activities" and `am kill`: plan, field mode and the screen restored | RUNTIME or DEVICE / EMULATOR (**D11-2**) | F22 (the route is now restored; S11.3's follow-up) | **INVALIDATED → UNVERIFIED:** host `route_restoration_test.dart` (R1); the Android process-death run is F22 A1, NEEDS ATTENTION (no emulator). Carried (REL-02) | UNVERIFIED |
| L4 | Save, kill during the night, reopen after dawn: "Last night …", a copy, the saved plan in the Logbook; one copy after a second kill | RUNTIME or DEVICE / EMULATOR (**D11-2**) | F19 (early results), F22 | **INVALIDATED → UNVERIFIED** (no emulator). Host L4/L4b (R1). Carried (REL-02) | UNVERIFIED |
| L5 | Rotation, dark mode and field mode lose nothing typed, cut nothing off | RUNTIME or DEVICE / EMULATOR (**D11-2**) | F21 (Appearance), F14–F19 (new layouts) | **INVALIDATED → UNVERIFIED** (no emulator). Host L5 (R1). Carried (REL-02) | UNVERIFIED |
| L6 | A device zone change after the night leaves the result form's night and times in the site's zone | RUNTIME or DEVICE / EMULATOR (**D11-2**) | F19 (result eligibility from the stored window) | **INVALIDATED → UNVERIFIED** (no emulator). Host L6 (R1) and R2's zone test. Carried (REL-02) | UNVERIFIED |
| L7 | Install the next build over the beta (`adb install -r`): everything kept | DEVICE / PHONE | — | **DEFERRED:** the row applies "once one exists" (matrix); no public build exists (S13.2 §3.10). Becomes the update check after the first GitHub release (F26 A5, G2/G4) | DEFERRED |
| L8 | Storage full: edits, Save, result and backup report failure without a crash; recovery after freeing space | RUNTIME or DEVICE / EMULATOR (**D11-2**) | F18 (TD-095: a successful Save clears the banner), F01, F21 | **INVALIDATED → UNVERIFIED** (no emulator). Host L8 and `storage_failure_test.dart` (R1). Carried (REL-02) | UNVERIFIED |
| L9 | Core-loop E2E on the emulator | RUNTIME (emulator) / EMULATOR (TASK 15.5) | F09, F16, F18 (the E2E itself changed) | **INVALIDATED → UNVERIFIED** (no emulator). Host R2 passes. Carried (REL-02) | UNVERIFIED |
| L10 | The core loop on the physical phone, first run to Export as file | DEVICE / PHONE (**D11-2**) | F16–F22 | **INVALIDATED → UNVERIFIED** (never run). Carried to G2 | UNVERIFIED |

### M — Performance

| ID | Check (short) | Level / env | Affected by | Disposition | Status |
| --- | --- | --- | --- | --- | --- |
| M1 | Stage 10 baselines: 24.8 MB arm64 APK, 27.8 MB installed; scenario numbers | RUNTIME (emulator) / EMULATOR | F01–F25, `e13eccc` (lock), GitHub-only distribution (D10-3's per-ABI premise superseded, CA-13) | **INVALIDATED → UNVERIFIED:** application and assets changed; F26 A2 measures the actual universal and arm64 sizes (Android SDK needed) | UNVERIFIED |
| M2 | Deterministic performance tests: planner memoization, candidates under 1 s (host), rig editor rebuilds, `MediaQuery` by aspect | TEST / HOST | F05 (rig editor), F13 (candidate evaluator), F18 (planner) | **INVALIDATED → re-verified:** `planner_memoization_test.dart`, `candidate_evaluator_test.dart`, `rig_editor_rebuilds_test.dart`, `media_query_aspects_test.dart` (R1) | VERIFIED (host) |
| M3 | `perf_scenarios_test.dart` on the phone in profile mode | DEVICE / PHONE | F05, F18, F19 | **INVALIDATED → UNVERIFIED** (S10V-04, never run). Host `perf_scenarios` `+1` at G. Carried to G2 | UNVERIFIED |
| M4 | Tonight's candidates for the whole catalog under 1 s on the phone | DEVICE / PHONE | F13 | **INVALIDATED → UNVERIFIED** (never run). Carried to G2 | UNVERIFIED |
| M5 | Profile traces without jank on a low-end phone | DEVICE / PHONE (low-end; none exists) | — | **REUSED:** the recorded UNVERIFIED stands (D10-1; no low-end phone exists; not in D11-2) | UNVERIFIED |
| M6 | Play's reported download and install size | DOCUMENTED / OWNER | — | **DEFERRED:** GitHub-only distribution (DECISIONS E.1, "Distribution: GitHub Releases only", 2026-10-17); replaced by F26 A2's measured sizes | DEFERRED |

### N — Release, signing, install and identity

| ID | Check (short) | Level / env | Affected by | Disposition | Status |
| --- | --- | --- | --- | --- | --- |
| N1 | `pubspec.yaml` `X.Y.Z+N` equals `AppIdentity.version`; Gradle, manifest, `MainActivity` agree with `AppIdentity` | TEST / HOST | S13.2 (id); F02 (the identity test extended); version `1.0.0+1` unchanged | **INVALIDATED → re-verified:** `app_identity_test.dart`, `release_config_test.dart` (R1). F26 A1 adds the release checks | VERIFIED (host) |
| N2 | A release build installs on the emulator and the core loop is walked once | RUNTIME (emulator) / EMULATOR | everything since `43523bb`; `e13eccc` (lock) | **INVALIDATED → UNVERIFIED** (no Android SDK). Carried to the G1 native/emulator rows and F26 | UNVERIFIED |
| N3 | `tool/check_bundle.dart` on a fresh AAB: 16 KB alignment, no debug sections, debug signer refused | RUNTIME (host tool) / HOST | GitHub-only distribution | **DEFERRED:** the AAB and `check_bundle` as a release requirement (DECISIONS E.1, 2026-10-17); the APK check with alignment and the expected certificate is F26 A1 | DEFERRED |
| N4 | The owner's upload key and a signed AAB; "Bundle check passed" | DOCUMENTED / OWNER (D11-2) | GitHub-only distribution | **DEFERRED** (upload key, AAB, same decision). Successor: the owner-managed release key and F26 A1 (OWNER ACTION there) | DEFERRED |
| N5 | The signed release installs on a physical phone and runs the core loop | DEVICE / OWNER (PHONE) (D11-2) | F26 (the artifact does not exist yet) | **OWNER ACTION:** needs the owner's release key and F26's APK; then G2 | OWNER ACTION |
| N6 | Android SDK command-line tools installed; `flutter doctor` clean | DOCUMENTED / OWNER | — | **OWNER ACTION:** not recorded; this environment has no SDK (`dl.google.com` refused). Needed for F26 and the native rows | OWNER ACTION |
| N7 | RD-01 decided and TD-088 resolved; id, policy, source, project URLs, user agent final | DOCUMENTED / OWNER | — | **REUSED:** decided and done 2026-10-17 (S12.3, S13.2; closure at `570581e`); no F task changed the id, URLs or user agent (`app_identity.dart` untouched by F01–F25) | VERIFIED (documented) |
| N8 | A formal trademark search before the first upload | DOCUMENTED / OWNER | — | **DEFERRED** as a gate: GitHub-only distribution made S12.2 a recommended owner check, not a prerequisite (DECISIONS E.1, 2026-10-17) | DEFERRED |
| N9 | A Play Console account and the app's entry; Play App Signing | DOCUMENTED / OWNER | — | **DEFERRED** (Play Console, same decision) | DEFERRED |
| N10 | Target API and 16 KB re-checked against Play's current policy | DOCUMENTED / HOST (web) | — | **DEFERRED** (store part, same decision; S11.4 PASS 2026-09-30 kept as history). Target API 36 stays a quality baseline; 16 KB alignment is F26 A1 | DEFERRED |

### O — Compliance, privacy, providers, AC7

| ID | Check (short) | Level / env | Affected by | Disposition | Status |
| --- | --- | --- | --- | --- | --- |
| O1 | Open-Meteo live from the emulator: HTTPS, user agent, attribution, cache reuse | RUNTIME (emulator) / EMULATOR | F14 (one 16-day request in UTC, site-cell cache) | **INVALIDATED → UNVERIFIED:** no emulator; `api.open-meteo.com` refused here (G1 record). Host contract: `open_meteo_forecast_test.dart`, `night_weather_service_test.dart` (R1). Carried to the G1 live row | UNVERIFIED |
| O2 | Nominatim live: nothing while off; with it on a name with attribution, ≤ 1/s, user agent; never for a saved site | RUNTIME (emulator) / EMULATOR | F23 A1/A5 (municipality; the new-site offer; S11P-01) | **INVALIDATED → UNVERIFIED:** host refused (G1 record). Host: `nominatim_reverse_geocoder_test.dart`, `place_name_lookup_test.dart` (R1). Carried | UNVERIFIED |
| O3 | OSM tiles live with attribution and user agent; no bulk download | RUNTIME (emulator) / EMULATOR | F24 A2, F25 A1 (attribution layout) | **INVALIDATED → UNVERIFIED:** host refused (G1 record). Host: `location_picker_tiles_failing_test.dart` (R3). Carried | UNVERIFIED |
| O4 | The light-pollution link opens at the site's coordinates; nothing fetched | RUNTIME (emulator) / EMULATOR | F15 (`sky_darkness_widget.dart`) | **INVALIDATED → UNVERIFIED:** host refused (G1 record). Host: `light_pollution_map_link_test.dart` (R1). Carried | UNVERIFIED |
| O5 | Providers' terms re-checked and date-stamped in `COMPLIANCE.md` | DOCUMENTED / HOST (web) | F14 (Clear Outside link; the 16-day request) | **INVALIDATED → UNVERIFIED:** the terms were last re-read 2026-09-30 (S11.4); `COMPLIANCE.md` describes F14's use, but the terms pages are refused here. Third-party terms stay mandatory under GitHub-only distribution. Carried to the G1 provider row | UNVERIFIED |
| O6 | AC7: every runtime dependency's licence recorded, compatible with GPL-3.0, on the licence page | CODE / HOST | `e13eccc` (`material_ui` 1.3.0 → 1.7.0, the only lock change since `2b467b8`), F23 A2 | **INVALIDATED → UNVERIFIED** (partly): the Dart part holds (`material_ui` 1.7.0's `LICENSE` is the same Flutter BSD-3 text as 1.3.0's, read from the pub cache); the Android libraries' notices are F23 A2, NEEDS ATTENTION (dependency graph needs `dl.google.com`) | UNVERIFIED |
| O7 | AC7: no key or secret in the repository; signing files ignored; every network call HTTPS | CODE / HOST | F14 (Clear Outside), F20 (CSV share), F23 | **INVALIDATED → re-verified (code, 2026-10-19):** no `http://` in `lib/`; no `key.properties`, `*.jks` or `*.keystore` tracked (`git ls-files`) | VERIFIED (host) |
| O8 | `COMPLIANCE.md` and the privacy policy match the code; permissions; backups | CODE / HOST (mandatory) | F14, F21, F23 A5 (both documents edited with them), F23 A2 | **INVALIDATED → UNVERIFIED** (partly): the documents were updated in the same commits as F14 and F23 A5 (G1 record: "Partly"); the native notices are open (F23 A2). Carried to the G1 policy/notices row | UNVERIFIED |
| O9 | The policy published at its URL with the contact, and the URL opens | DOCUMENTED + RUNTIME / OWNER (mandatory) | F14, F23 A5 (`docs/privacy/index.md` changed after S12.3) | **INVALIDATED → UNVERIFIED:** live and complete on 2026-10-17 (S12.3); the text changed since, and `buffur.github.io` is refused here. After the owner's push and Pages build, read the live page against `docs/privacy/index.md` | UNVERIFIED |
| O10 | The Data Safety form filled in from `COMPLIANCE.md` | DOCUMENTED / OWNER | — | **DEFERRED** (Data Safety form; GitHub-only distribution) | DEFERRED |
| O11 | The source repository is public | DOCUMENTED / OWNER | — | **REUSED:** public since S12.3 (2026-10-17); `github.com/Buffur/Culmina` answered 200 on 2026-10-19 (G1 record) | VERIFIED (documented) |

### P — CI and process

| ID | Check (short) | Level / env | Affected by | Disposition | Status |
| --- | --- | --- | --- | --- | --- |
| P1 | The full quality gate passes on the final inputs | TEST / HOST (TASK 16.4) | the nine post-gate commits `9ac8d7b`–`e6a0376` | **INVALIDATED → UNVERIFIED** at `e6a0376`: G passed at `e13eccc`; R1–R3 cover the matrix rows' files, not the whole gate. The full gate on the final release inputs is F26 A3 (or a G1 re-run) | UNVERIFIED |
| P2 | RD-17: the CI workflow pushed and a first run observed | DOCUMENTED / OWNER | — | **REUSED:** the first green run 39020770255 (S12.1, 2026-10-17); a dated fact. Green CI on the accepted code is the G1 remote-CI row (UNVERIFIED, push 403) | VERIFIED (documented) |
| P3 | `TEST_PLAN.md`'s end-to-end section and trap 18 describe the current flow | DOCUMENTED / HOST | F16 (Welcome), F19 (early results), F22 (route restoration), F03 (v26) | **INVALIDATED → UNVERIFIED:** `TEST_PLAN.md` changed only with F01; its L3 omits the restored route and its L7 still names v8–v24 → v25. Documentation drift, follow-up G1-S11-03 | UNVERIFIED |
| P4 | Every device and emulator run recorded in `TEST_PLAN.md` with build, device, commit, date, result | DOCUMENTED / HOST (the Exit) | — | **INVALIDATED → UNVERIFIED:** no device or emulator run in the final plan yet. Carried to G2 | UNVERIFIED |

### Q — Owner decisions and go/no-go

| ID | Check (short) | Level / env | Affected by | Disposition | Status |
| --- | --- | --- | --- | --- | --- |
| Q1 | No P0 or P1 open | DOCUMENTED / HOST (D11-2) | all | **INVALIDATED → UNVERIFIED:** judged at G3 (S17.7); open at this record: G1-S11-01 (below) and the G1 record's open rows | UNVERIFIED |
| Q2 | Play's closed-testing rules re-verified | DOCUMENTED / HOST (web) | — | **DEFERRED** (Play closed test; GitHub-only distribution, DECISIONS E.1, 2026-10-17) | DEFERRED |
| Q3 | The owner's dogfooding on real nights with a go/no-go (M3) | HUMAN / OWNER (D11-2) | — | **OWNER ACTION** (G3) | OWNER ACTION |
| Q4 | The readiness record in four groups; UNVERIFIED never a pass | DOCUMENTED / HOST (the Exit) | — | **INVALIDATED → UNVERIFIED:** G3's record; this file and the G1 record are its inputs | UNVERIFIED |
| Q5 | The owner's go/no-go recorded | DOCUMENTED / OWNER (D11-2) | — | **OWNER ACTION** (G3) | OWNER ACTION |

## Runs

| Run | Command | Result |
| --- | --- | --- |
| R1 | `flutter test --no-pub` with 111 files: every test file the matrix and `STAGE_11_HOST_EVIDENCE.md` name, plus `route_restoration_test.dart`, `restore_activation_test.dart`, `restore_outcome_notice_test.dart`, `preferences_round_trip_test.dart`, `unsupported_database_test.dart`, `app_database_test.dart`, `nominatim_reverse_geocoder_test.dart`, `light_pollution_map_link_test.dart`, `open_meteo_forecast_test.dart`, `display_units_test.dart`, `display_units_paths_test.dart`, `quantity_text_test.dart`, `quantity_text_usage_test.dart`, `storage_estimate_test.dart`, `fits_metadata_reader_test.dart`, `block_from_fits_test.dart`, `moon_up_predicate_test.dart`, `forecast_overview_test.dart`, `night_weather_summarizer_test.dart`, `astrobin_acquisitions_test.dart`, `astrobin_export_test.dart`, `share_astrobin_csv_exporter_test.dart`, `welcome_screen_test.dart` | `+1274: All tests passed!` (05:42) |
| R2 | `flutter test --no-pub integration_test/core_loop_test.dart -d flutter-tester` | `+2: All tests passed!` |
| R3 | `flutter test --no-pub` with 53 files named in the F evidence records (every file cited "(R3)" above, and among the rest `block_from_photo_plan_test.dart`, `block_proposal_test.dart`, `metadata_import_screen_test.dart`, `metadata_text_test.dart`, `size_orientation_test.dart`) | `+361: All tests passed!` (02:25) |
| P-H2 | A temporary widget test (written, run, deleted): `Semantics(button: true, selected: …, excludeSemantics: true, label: …, child: InkWell(onTap: …))`, the pattern of both new call sites | The node has **no** `SemanticsAction.tap` (`hasTap=false`), while a pointer tap reaches the `InkWell` (`pointerTaps=1`) |

Not run (V1–V3; the G1 record's environment): the full gate at `e6a0376`, `perf_scenarios`,
analyze/format/encoding (no file under their inputs changes here), the opt-in render and
real-sample tests, anything native, on an emulator or a phone, or against a live provider.

## Findings

### G1-S11-01 — BLOCKER (V4 A against H2; V4 B, a regression of F14 and F15): two relabelling `Semantics` buttons pass no `onTap`

`lib/presentation/widgets/weather_forecast_widget.dart` (the hour slot, `Semantics(button: true,
selected: …, excludeSemantics: true, label: '… Shows its exact values', child: InkWell(onTap: …))`,
from F14 `0ee2ee8`) and `lib/presentation/widgets/night_browser_sections.dart` (the calendar's day
cell, `_DayCell`, the same shape, from F15 `189bdb9`) replace their child's semantics without
giving the node `onTap`. Probe P-H2 shows that this shape exposes no tap action: TalkBack announces
a button that a double tap cannot activate. H2 states the rule as written (trap 17, S1.11/UX-28);
the existing `hasTapAction` tests cover only `collapsible_section.dart` and `context_line.dart`, and
the sweep's `labeledTapTargetGuideline` does not see a node without a tap action. The probe used
the pattern, not the two private widgets; the code reading shows both sites have that pattern.
Data and calculations are unaffected; the hour's values and the day are reachable by other
controls (the slider, the night browser), so it is an accessibility defect, not data loss.
**Direction:** pass `onTap` (and `enabled`) on both `Semantics`, with a `hasTapAction` test each.
**Destination:** a corrective change in the authorized run, then V5 recheck of H2 only; H6/H7's
TalkBack walkthrough (G2) covers the same controls. Not fixed here (this record is
documentation only).

**Resolved 2026-10-19 (corrective change after this record; V5 recheck of H2 only):** both
`Semantics` now pass `onTap` and `enabled`. `detail_screens_test.dart` "Weather: each hour button
can be activated by a screen reader" and `night_moon_browse_test.dart` "A5: a calendar day can be
activated by a screen reader" (which performs the semantics tap and sees the night viewed) fail
on the old code and pass. **H2: re-verified (host).**

### G1-S11-02 — FOLLOW-UP (B1, B2): the planner's timeline widget has no caller

Since F18 A1 removed "Tonight for this target" and its chart from the plan,
`TonightOpportunityWidget` (and through it `AltitudeChartWidget`) is imported by no file in
`lib/`; only tests use it. B1/B2's widget checks still pass, but they guard code no screen shows.
**Destination:** `TECH_DEBT.md` (remove the widget or reuse it where a decision places it), not a
release blocker. Recorded as TD-111.

### G1-S11-03 — FOLLOW-UP (P3): `TEST_PLAN.md` lags the final plan

L3 does not expect the restored route (F22), L7 names "every schema v8–v24 → v25" (now v26, F03),
and L1/A10's steps say "first-run page" for F16's Welcome. Documentation drift, not a code defect.
**Destination:** a documentation update with the G2 runbook. *Done 2026-10-19:* `TEST_PLAN.md` L1, L3 and L7 carry dated notes.

## Summary

**Counts (130 rows).**

| Disposition | Rows | Count |
| --- | --- | --- |
| REUSED | M5, N7, O11, P2 | 4 |
| INVALIDATED → re-verified | A1–A7, B1–B5, B7–B9, C1–C8, D1–D7, E1–E4, F1–F12, G1–G5, G8, G9, H1, H3, H4, H5, I1, J1–J4, K1, K2, L0, M2, N1, O7 | 68 |
| INVALIDATED → NOT MET | H2 | 1 |
| INVALIDATED → UNVERIFIED | A8–A10, B6, E5–E7, F13–F16, G6, G7, H6, H7, I2, I3, J5, L1–L6, L8–L10, M1, M3, M4, N2, O1–O6, O8, O9, P1, P3, P4, Q1, Q4 | 44 |
| OWNER ACTION | N5, N6, Q3, Q5 | 4 |
| DEFERRED | L7, M6, N3, N4, N8, N9, N10, O10, Q2 | 9 |

Status: VERIFIED (host) 68 (the re-verified rows); VERIFIED (documented) 3 (N7, O11, P2, all
REUSED); UNVERIFIED 45 (the 44 invalidated rows and M5, REUSED as UNVERIFIED); NOT MET 1 (H2);
OWNER ACTION 4; DEFERRED 9. No row is IMPLEMENTED-only: where a row's level is not reached the
row is UNVERIFIED and its host evidence is named in the row.

**Blocking at this record:** H2 (G1-S11-01) — the only row whose host re-verification fails. *Since resolved (see G1-S11-01): no host row blocks.*
Every other HOST row passes on `e6a0376` (R1–R3), except P1, which needs the full gate on the
final inputs.

**Carried to G2 (phone, human):** A8 (owner-accepted S6.E gap), A9, A10, E5, E6, E7, H6 and L10
(D11-2), H7, I2, I3, M3, M4, P4; and N5 after F26 (owner).

**Carried to G1's environment rows (an Android SDK, an emulator or network access):** B6, F13,
F14, F15, F16, G6, G7, J5, L1–L6, L8, L9 (D11-2's lifecycle rows L1–L6 and L8; L9 TASK 15.5), M1
and N2 (with F26), O1–O6, O8 and O9; P1 (the full gate on the final inputs, F26 A3).

**Owner:** N5, N6, Q3, Q5; O9 needs the owner's push before the live page can be compared; Q1 and
Q4 are G3's.

**Not carried (decided):** L7, M6, N3, N4, N8, N9, N10, O10, Q2 (GitHub-only distribution, or no
earlier public build); M5 stays UNVERIFIED under D10-1.
