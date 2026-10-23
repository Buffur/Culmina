# Hybrid transfer into Flutter — status (2026-10-22, checkpoint 3 on 2026-10-23)

Contract: owner's `CULMINA_OPUS_HYBRID_TRANSFER_FINAL_UK.md` (outside the repository; §§1–9). This file is
the single status record of that transfer; earlier migration records
([DESIGN_PARITY_QA_2026_10_21.md](DESIGN_PARITY_QA_2026_10_21.md),
[VISUAL_COMPARISON_AUDIT.md](VISUAL_COMPARISON_AUDIT.md),
[WEB_DESIGN_INVENTORY.md](WEB_DESIGN_INVENTORY.md), [FLUTTER_CAPABILITY_INVENTORY.md](FLUTTER_CAPABILITY_INVENTORY.md))
stay as history of the earlier `20261020-hybrid7` port. Evidence: [evidence/hybrid-transfer-2026-10-22/](evidence/hybrid-transfer-2026-10-22/).

## Reference and working state (checkpoint 1)

| Item | Value |
| --- | --- |
| Web reference | `design/home-lab/` at **`86873ce343160c860706091e12b257090cc96d94`**; acceptance record `ed2955442110b31eec54fd8db436f1f4e0841993` ([result](../CLAUDE_WEB_QA_FIX_RESULT_2026_10_22.md)). `git diff 86873ce HEAD -- design/home-lab` is empty; the web tree was served read-only (`serve_preview.py --port 4197`) and never edited |
| Start of the run | branch `develop`, HEAD `ed29554`; no pull, push, reset, stash or checkout in this run (contract §1); commits only at the owner's request (checkpoint 2, checkpoint 3) |
| Pre-existing dirty work | `equipment_editor.dart`, `target_selection_screen.dart` and their two tests held 2026-10-21 interim fixes the owner said are superseded and must not be committed (plus untracked `evidence/rig-*`, `target-editor-*`, `baseline-2026-10-21/`). Checkpoint 1 kept their diff as a local, uncommitted patch. At the checkpoint-3 commit (2026-10-23) neither the patch nor those untracked folders was on disk any more; the remaining diff of the four files against the checkpoint-2 commit was reviewed hunk by hunk and is transfer work only — the interim fixes edited the old rig and target dialogs, which the transfer deletes, so none of them is committed |
| Toolchain | Flutter 3.47.4 / Dart 3.13.3 (`C:\flutter`); Node 25.9.0; pinned Playwright 1.64.1 Chromium (`browser_toolchain.cjs`); Android SDK emulator, AVD `culmina_hybrid_native_qa` (Pixel 5 image, API 30, x86_64) |
| Devices | Disposable emulator `emulator-5554` only, selected explicitly (`-s`/`-d`). The owner's phone (`PRRGPZ8PZ5E6OJ7T`) is connected over USB and is **not touched** |
| Emulator geometry | `wm density 320`, `wm size 750x1697` → 375 dp wide; status bar 145 px; gesture navigation (overlay `navbar.gestural`) → **375 × 760 dp app area** (from below the status bar to above the gesture bar) |

## Comparison protocol in use

- Web: Chromium, `variant=blend`, `font=native` (Geist UI, Source Serif 4 night headings), text scale 1, zoom 1,
  fresh context per frame, studio 1200 × 1000, DPR 1. The phone frame is widened to **377 px so its content box
  is 375** (1 px border each side; DOMRect checked) and its height set so the app area is 760. The fake status
  bar and gesture bar are cropped; app bar, content and navigation are kept. Script:
  `webcap.cjs` (scratch tooling; per-run manifest `web-manifest-*.json` in the evidence folder) also dumps
  computed styles (family, size, weight, line height, tracking, colours, borders, radius, padding, geometry).
- Flutter host renders: `test/presentation/design_system/hybrid_transfer_renders_test.dart` (opt-in
  `ASTROPLAN_HYBRID_RENDERS`), real app, router, ViewModels and Drift on
  `test/support/hybrid_transfer_fixture.dart` (Kyiv outskirts, 19 Oct 2026, M31, "DSLR · 135 mm lens"),
  bundled Geist and Source Serif 4, DPR 1, 24-hour clock. For fast iteration only.
- Android: `integration_test/hybrid_transfer_capture_test.dart` through `flutter drive -d emulator-5554`
  (`test_driver/hybrid_migration_driver.dart`), same fixture and steps (`test/support/hybrid_transfer_shots.dart`).
- Demo numbers in the browser come from its illustrative model; Flutter shows production calculations. A pair
  compares presentation (order, roles, geometry, colour, controls); numbers are not made to agree.

Font finding (checkpoint 1): the browser's Source Serif 4 (Google Fonts wght-only WOFF2) measures exactly as the
variable TTF at **opsz 14** (28 px sample: 378.375 px web, 378.364 px Flutter host with `FontVariation('opsz', 14)`);
Flutter maps `fontWeight` to `wght` automatically. The TTF and its OFL licence are bundled with provenance
([SourceSerif4.source.json](../../../assets/fonts/SourceSerif4.source.json)).

## Registry

Status words: `pending`, `in progress`, `PASS`, `covered-by <ID>`, `native adaptation`, `N/A`,
`external-unverified`, `blocked`, `fail`, `OWNER` (waits on an owner decision listed under Deviations). Visual and
functional are independent. Web sources are relative to `design/home-lab/`. Matrix A IDs refer to
[WEB_DESIGN_INVENTORY.md](WEB_DESIGN_INVENTORY.md) behaviour rows. Pairs: `pairs-checkpoint2/`, `pairs-checkpoint3/`
(web left, Flutter host right, 375 × 760 unless named `w412-*`); Android: `android/`, `android/b2/`–`android/b5/`
(`android-<frame>-<theme>.png`, each folder with its `integration-report.json`) from
`integration_test/hybrid_transfer_capture_test.dart` on `emulator-5554`; reviewed web | Android pairs in
`android-pairs/` (Android scaled to 375 logical px, status inset cropped) and the Dark/Field device sheets
`android-pairs/sheet-dark.png`, `sheet-field.png`.

Checkpoint-3 status (2026-10-23). "host PASS" = the web/host pair was opened and reviewed and its differences fixed
or recorded; "Android" = the same frame captured on the emulator and opened.

### Shared foundation

| ID | Surface / state | Flutter target | Visual | Functional | Evidence |
| --- | --- | --- | --- | --- | --- |
| HT-F01 | Fonts: Geist UI, Source Serif 4 opsz 14 | `assets/fonts`, `AppTypography` | host PASS; Android PASS; HT-DEV-01 | N/A | checkpoint 1; every pair |
| HT-F02 | Role type scale | `AppTypography`, theme | host PASS (dumps compared per surface); Android PASS | N/A | `pairs-checkpoint3/*` |
| HT-F03 | Palette Light/Dark/Field | `AppPalette`, `HybridTokens` | host PASS L/D/F; Android PASS | N/A | dark/field sweep (checkpoint 3) |
| HT-F04 | Icons (web SVG paths, Lucide data icons; Lucide `refresh-cw` added for Candidates) | `HybridIcon` | host PASS | N/A | pairs |
| HT-F05 | Section heading, disclosure | `CollapsibleSection` | host PASS | expand/collapse tests (`planner_disclosure_test`, `collapsible_section_test`) | pairs |
| HT-F06 | Row buttons, chevron rows | `SettingsRow`, `LibraryRow`, `_ActionRow` | host PASS | navigation tests | pairs |
| HT-F07 | Status labels incl. Logbook states | `PlanStateLabel`, `EntryStateBadge` | host PASS; HT-DEV-16 | `plan_state` tests, logbook tests | `logbook*.png`, `entry*.png` |
| HT-F08 | Buttons | theme | host PASS | states via widget tests | pairs |
| HT-F09 | WQA-01 Field primary | filled button theme | host PASS (field sweep) | `field_primary_action_contrast_test` | dark/field sweep |
| HT-F10 | WQA-03 Field range | slider theme | host PASS (checkpoint 2) | `controls_theme_test` | `pairs-checkpoint2` |
| HT-F11 | WQA-04 dialogs; reference action rows | `confirmation_patterns.dart` | host PASS (delete, unsaved, discard edit, leave plan) | `confirmation_and_delete_patterns_test`, `unsaved_plan_prompt_test` | `lib_rig_delete.png`, `lib_rig_unsaved.png`, `editor-dialog.png` |
| HT-F12 | App bar, root navigation, plan menu | `hybridAppBar`, `AppShell`, popup theme | host PASS; HT-DEV-17 | `app_shell_navigation_test` | `plan_menu.png` |
| HT-F13 | Text fields, search, selects, radios, checkboxes, switches | `LibraryField`, `BlockField`, `HybridRadio`, `HybridCheckRow(.plan)`, `HybridSwitch` | host PASS | `controls_theme_test`, form tests | Settings/Library/Plan pairs |
| HT-F14 | Night timeline | `night_browser_sections.dart` | host PASS (checkpoint 2) | `night_moon_browse_test` | `night-*.png` |
| HT-F15 | Stacking-gain graph | `stacking_gain_graph.dart` | host PASS | relative √N tests | `plan-b.png`, `entry*.png` |

### Screens and states

| ID | Surface / state | Flutter target | Visual | Functional | Evidence |
| --- | --- | --- | --- | --- | --- |
| HT-H01 | Home ready | `tonight_home_screen.dart` | host PASS L/D/F; Android PASS | `tonight_home_screen_test` | `home-*.png` |
| HT-H02 | Home states: no site, error/retry, loading, empty plan, unknown forecast, no dark, partial/stale/offline | same | no site: host PASS and Android PASS (release smoke, `smoke3.png`); error/retry: host PASS and Android PASS (a real startup failure: the fixture's database closed, then Retry; icon, 20/600 heading, copy and full-width Retry as the reference; no title or chips, HT-DEV-09); loading: HT-DEV-08; Weather row states: wording as the reference (Forecast unavailable, No dark-time forecast), HT-DEV-10 | `home_screen_test` (load error + retry), `tonight_home_screen_test`, `field_mode_darkness_test` | `home_nosite.png`, `home_loaderror.png`, `android-pairs/android-pair-home_loaderror.png`, `release-smoke/smoke3.png`, `web/checkpoint3/web-home-*` |
| HT-H03 | Home site and night sheets (WQA-06) | `home_context_sheets.dart` (new) | host PASS; Android PASS; HT-DEV-05/06 | Apply site/night, Cancel keeps the plan (`tonight_home_screen_test` night sheet tests) | `home_sitesheet.png`, `home_nightsheet.png` |
| HT-H04 | First-run onboarding (kept) | `welcome_screen.dart` | native adaptation | `welcome_screen_test` | — |
| HT-H05 | Candidates | `tonight_candidates_screen.dart` | host PASS; Android PASS; HT-DEV-07 | choose target, filters, late answers (`tonight_candidates_screen_test`) | `home_candidates.png` |
| HT-P01 | Plan main | `home_screen.dart`, `capture_plan_widget.dart` | host PASS (checkpoint 2); Android PASS | planner tests; E2E `core_loop_test` | `plan-*.png` |
| HT-P02 | Site and night, Target, Rig choosers | `plan_context_screen.dart`, `plan_target_screen.dart`, `plan_rig_screen.dart` | host PASS; Android PASS | Apply/Close (`library_manage_mode_test`, `planner_f18_test`), E2E `core_loop_test` | `context.png`, `target.png`, `rig.png` |
| HT-P03 | Block editor | `capture_block_dialog.dart` | host PASS; Android PASS | validation/Apply/Discard/Back (`capture_*` tests) | `editor-*.png` |
| HT-P04 | Calibration builder | `calibration_preview_dialog.dart` (scoped page) | host PASS; Android PASS; HT-DEV-04 | Add selected frames + Undo, leave out, exposure required (`calibration_preview_test`, E2E `core_loop_test`) | `plan_cal*.png` |
| HT-P05 | Plan assumptions | `plan_overrides_editor.dart` | host PASS; Android PASS; HT-DEV-03 | buffer/Apply/Use global defaults/Discard this edit (`capture_assumptions_test`) | `plan_asm*.png` |
| HT-P06 | Plan menu, Unsaved changes, Plan this night, save error | `home_screen.dart`, `unsaved_plan_prompt.dart` | menu host PASS; Android PASS; dialogs covered-by HT-F11 | new/copy/Undo/Save (`plan_identity_actions_test`, `unsaved_plan_prompt_test`, `autosave_failure_banner_test`) | `plan_menu.png` |
| HT-N01 | Night tab | `night_moon_screen.dart` | host PASS; Android PASS | `night_moon_browse_test` | `night-*.png`, `n-*.png` |
| HT-N02 | Moon tab | same | host PASS; Android PASS | `moon_calendar_hybrid_test` | `moon-*.png` |
| HT-W01 | Weather A compact rows | `weather_hybrid_view.dart` | host PASS; Android PASS | `weather_hybrid_view_test`, `detail_screens_test` | `w-*.png`, `weather-a.png` |
| HT-W02 | Weather B charts (WQA-05) | same | host PASS; Android PASS | same data as A (tests) | `wB-*.png` |
| HT-W03 | Weather states | same | host PASS and Android PASS: offline, stale, partial (later start + cloud gaps), no dark, against `conditions.js` scenarios | retry, coverage words (`weather_hybrid_view_test`, `forecast_nights_test`) | `wx-offline.png`, `weather_stale.png`, `weather_partial.png`, `weather_nodark.png`, `android-pairs/android-pair-weather_*.png` |
| HT-W04 | Weather view preference | display settings | host PASS | default rows, persisted, old backups read rows (`display_settings_test`) | `set-appearance*.png` |
| HT-L01 | Logbook list | `logbook_screen.dart` | host PASS L/D/F; Android PASS; HT-DEV-11 | `logbook_screen_test` | `logbook*.png` |
| HT-L02 | Logbook filters, empty, no match | same | host PASS; Android PASS | filters/clear/range (`logbook_screen_test`) | `logbook_filters.png` |
| HT-L03 | Entry detail | `session_detail_screen.dart` | host PASS; Android PASS; HT-DEV-12 | `session_detail_test`, `astrobin_export_test`, E2E export | `entry*.png` |
| HT-L04 | Result editor | `results_screen.dart` | host PASS; Android PASS | `results_screen_test`, E2E result after restart | `result*.png` |
| HT-L05 | Progress by target | `progress_screen.dart` | host PASS; Android PASS | `target_progress_test`, `logbook_screen_test` | `android-pairs/android-pair-logbook_progress.png` |
| HT-B01 | Library root | `library_screen.dart` | host PASS L/D/F; Android PASS | counts/retry (`app_shell_navigation_test`) | `library.png` |
| HT-B02 | Rigs/Targets/Sites lists | list screens | host PASS (375, 412); Android PASS | search, swipe delete (`equipment_selection_screen_test`, `target_*_test`, `sites_screen_test`) | `lib_rigs.png`, `lib_targets.png`, `lib_sites.png` |
| HT-B03 | Rig/target/site records | `rig_detail_screen.dart`, `target_detail_screen.dart`, `site_detail_screen.dart` (new) | host PASS; Android PASS; catalogue record HT-DEV-02 | Edit/Delete/Undo (`library_manage_mode_test`) | `lib_rig.png`, `lib_target.png`, `lib_site.png` |
| HT-B04 | Rig editor | `equipment_editor.dart` (page) | host PASS (375, 412); Android PASS; HT-DEV-15 | `rig_creation_test`, `rig_form_test`, metadata import tests | `lib_rig_edit.png` |
| HT-B05 | Target editor | `target_editor_screen.dart` (new) | host PASS; Android PASS | `target_selection_screen_test`, `secondary_forms_test` | `lib_target_new.png` |
| HT-B06 | Site editor | `site_editor_screen.dart` | host PASS; Android PASS | `sites_screen_test` (48 tests) | `lib_site_edit.png` |
| HT-B07 | Library dialogs | `confirmation_patterns.dart` | host PASS; Android PASS | `rig_creation_test` A6, `library_manage_mode_test` | `lib_rig_delete.png`, `lib_rig_unsaved.png` |
| HT-S01 | Settings root | `settings_screen.dart` | host PASS (375, 412); Android PASS | `settings_screen_test` | `set-root.png` |
| HT-S02 | Appearance | same | host PASS; Android PASS; HT-DEV-13 | `display_settings_test` | `set-appearance*.png` |
| HT-S03 | Planning | same | host PASS; Android PASS | Save/Cancel guard (`settings_screen_test`) | `set-planning*.png` |
| HT-S04 | Privacy | same | host PASS; Android PASS | `place_name_switch_persistence_test` | `set-privacy.png` |
| HT-S05 | Backup & data | `backup_section.dart` | host PASS; Android PASS; native adaptation (format) | `backup_section_test` | `set-backup.png` |
| HT-S06 | About | `about_screen.dart` | host PASS; Android PASS; HT-DEV-14 | `about_screen_test` | `set-about.png` |
| HT-X01 | Native-only: GPS/permissions, file import, export/share, backup files, metadata import, map picker | existing screens | native adaptation | PASS on the final release APK `2792fbe2…` (emulator): Android location permission dialog, explained failure without a fix (TD-112 fixed), share sheet with the backup file, DocumentsUI picker, refusal of a non-backup file kept until dismissed (TD-113 fixed); metadata import and the map picker are unchanged by this transfer and covered by their existing tests | `release-smoke/system-*.png`, `td112-position-failure-2792fbe2.png`, `td113-refusal-stays-2792fbe2.png`, `system-share-sheet-2792fbe2.png` |
| HT-X02 | Release APK from `lib/main.dart`, smoke on the emulator | Android build | N/A | PASS: final artifact `2792fbe2…` built and launched as the exact installed file | "Release APK" below, `release-smoke/` |

Excluded (contract §3): studio shell, concept/palette/gain-variant selectors, font gallery, phone frame, fake
status/gesture bars, browser-only preview notes ("saved in this browser").

## Deviations, native adaptations and owner questions (checkpoint 3)

Recorded, not hidden (contract §3, §9.3). The three `OWNER` rows were decided by the owner on 2026-10-23 (in the run's chat: «робимо», accepting the recommended set); none of the decisions changes code.

| ID | Where | Reference | Flutter | Why | Status |
| --- | --- | --- | --- | --- | --- |
| HT-DEV-01 | All text stacks | Chromium fractional line boxes | Line boxes rounded to whole logical px (SkParagraph) | Engine constraint; up to ~2–3 px drift on long stacks; no `StrutStyle`/leading option avoids it | owner-accepted 2026-10-23: engine rounding accepted |
| HT-DEV-02 | Library › Targets › catalogue record | Catalogue read-only ("For different values, add your own target") | Catalogue entries keep the app's earlier Edit target / Delete target (a rename keeps the exact coordinates and the source; swipe delete) | Contract §3: functions are not removed for the prototype; a business-rule conflict is recorded, not silently changed. Read-only would remove an existing capability | owner-accepted 2026-10-23: catalogue edit and delete kept |
| HT-DEV-03 | Plan › Plan assumptions | Prefills all four values; Apply sets all four overrides | Each override optional on its own; empty = global default; "Current: Global default, 5 s" names the inherited value | Native per-field overrides (`PlanOverrides`) are the stored model; no schema change for layout | native adaptation |
| HT-DEV-04 | Plan › Calibration frames | Three fixed rows (Dark/Flat/Bias) from one reference light | One row per proposed block (a dark per light exposure, a flat per filter, dark flats), each with "Add … frames", "Proposed frames", exposure where it must be entered, its source line | Native `CalibrationBuilder` proposal (CAL-1, F09) | native adaptation |
| HT-DEV-05 | Home › night chip | Select of example nights | Sheet with the reference layout; its date field opens the platform date picker | Any night can be planned natively | native adaptation |
| HT-DEV-06 | Home › site chip | Sheet: select, Cancel, Apply site, note | Same, plus "Add or manage sites" (device position, save a position) under the note | Native position/save flows (HT-X01) | native adaptation |
| HT-DEV-07 | Home › What can I image …? | Illustrative list of bundled examples | Same sheet frame and chevron rows; the native list keeps sort, type filter, "Targets you added", "Show targets without a window", measured captions, usable time and Refresh | Real candidate evaluation (TASK 10.4) | native adaptation |
| HT-DEV-08 | Home loading | Skeleton lines "Loading your night…" | Startup mark (S13.3) while startup really loads | Accepted S13.3 behaviour; loading ends with the operation | native adaptation |
| HT-DEV-09 | Home load error | Title and chips above the message | Message only | Site and night did not load; unknown stays unknown | native adaptation |
| HT-DEV-10 | Home Weather row | Unchanged for stale/offline scenarios | Keeps the last real snapshot after a failed refresh; "Stale snapshot" when old | Provenance of real forecasts | native adaptation |
| HT-DEV-11 | Logbook | Filter states without Tracking; row buttons | Tracking state kept in the filter; rows open the entry (owner sketch); per-night lead moved to Forecast details | Existing data states | native adaptation |
| HT-DEV-12 | Entry detail | — | Extra Name, Copy, Open in planner, Conditions, budget/weather snapshot facts | Existing functions kept | native adaptation |
| HT-DEV-13 | Settings › Appearance | Text size control | Copy pointing to Android's font size | Platform text scaling (contract §2) | native adaptation |
| HT-DEV-14 | About | — | Privacy section, OpenNGC notice disclosure, Play services text | Existing compliance content | native adaptation |
| HT-DEV-15 | Rig editor | From a photo / JSON disclosures inside the editor | Photo import is the Add rig flow (class → From a photo); no JSON import | Native metadata import (F10) | native adaptation |
| HT-DEV-16 | Badges 11 px | 11 px | 12 px | Repository text-size guard (no text under 12) | owner-accepted 2026-10-23: 12 px floor kept |
| HT-DEV-17 | Plan ⋮ button | Grey circle while the menu is open | No open-state fill | Material `PopupMenuButton` has no open state | native adaptation |

## Checkpoints

### Checkpoint 1 — reference, scope, first pair (2026-10-22)

- First pair captured and opened: Home Light 375 (web `web-home-light-375.png`, Flutter host
  `flutter-home-light-375.png`, Android `android-home-light.png`) and Settings root Light 375. Both show the
  Flutter app still on the earlier `20261020-hybrid7` reference: Home keeps the removed wordmark/"Welcome & setup"
  row, a 14 px "Your plan" (web 20/600), no section rules, plain "Saved" (web green compact label), a different
  Night row; Settings section headings 16 (web 20/600), row titles 400 (web 16/600), different icons.
- All eight roots were also captured tall (web vs host) to size the delta: Plan and Weather differ in structure
  (Plan rows/blocks/estimate/disclosures; Weather A compact statistics rows as default), the others in type
  scale, components, icons and timeline colours.
- Tools: browser capture, host render and emulator drive all work. Source Serif 4 bundled (HT-F01).

### Checkpoint 2 — stopped by the owner mid-way (2026-10-22)

Shared foundation, Tonight/Home, the timeline, Plan main, the Site and night screen and the block editor's
discard prompt are implemented and checked on host renders (pairs in
[evidence/hybrid-transfer-2026-10-22/pairs-checkpoint2/](evidence/hybrid-transfer-2026-10-22/pairs-checkpoint2/);
some predate the last small fixes). Whole-package `flutter analyze` is clean; format and encoding pass; **the
unit/widget suite has not been run** after these changes and the Android confirmation of checkpoint-2 surfaces is
pending. Engine constraint found: Flutter rounds each text line box to whole logical pixels, giving up to ~2–3 px
drift on long stacks against Chromium. Full state, expected test updates, kept native adaptations and the ordered
next steps: [HYBRID_TRANSFER_CONTINUATION.md](HYBRID_TRANSFER_CONTINUATION.md). Result of this run so far:
**PARTIAL (in progress)**.

### Checkpoint 3 — registry implemented, host and Android checks (2026-10-23)

Continued from the continuation record's "Next steps" (no new audit). Implemented in this checkpoint, each against
its web reference with reviewed host pairs (`pairs-checkpoint3/`, web captures in `web/checkpoint3/`):

- Weather A/B and states, the Weather view preference; Settings root, Appearance, Planning, Privacy, Backup & data,
  About; Logbook list, filters, entry detail, result editor, Progress by target.
- Library: root, rig/target/site lists, records (new `rig_detail_screen.dart`, `target_detail_screen.dart`,
  `site_detail_screen.dart`), the rig editor as a page, a target editor page (`target_editor_screen.dart`), the site
  editor; Library dialogs in the reference's action layout.
- Plan: calibration builder and assumptions editor as scoped pages, the plan menu.
- Home: the no-site state message, the load-error state, the site and night sheets
  (`home_context_sheets.dart`), the candidates sheet.
- 412 width: Home, Plan, Calibration frames, Rig editor, Rigs, Logbook, Settings (`w412-*.png`): layouts hold; the
  differences are fixture data and browser-only preview notes.
- Dark and Field host sweep of Library, Logbook, entry, result, Settings Appearance and Weather: no contrast or
  layout regressions seen.

Verification (risk-based, §6):

- Unit/widget suite on the final code (the inputs of the release APK): `flutter test --no-pub` — **2442 passed,
  6 skipped, 0 failed** (2026-10-23, after the TD-112/TD-113 fixes and their regression tests). Earlier full runs on the way found the stale assertions that were updated to
  the reference (never weakened).
- Host E2E (`tool/check.dart`'s per-file flutter-tester runs): `core_loop_test` (site → plan → save → process kill →
  reboot on the same SQLite **file** → result → Logbook → export) PASS; `perf_scenarios_test` PASS;
  `hybrid_migration_smoke_test` and `hybrid_transfer_capture_test` are Android-only (skipped on the host; the
  capture test now says so instead of failing on the missing screenshot plugin).
- `flutter analyze --no-pub` (whole package): no issues. `dart format`: lib, test, integration_test, tool clean.
  `dart run tool/check_encoding.dart`: passed. `git diff --check`: no whitespace errors.

Android (`emulator-5554`, AVD `culmina_hybrid_native_qa`, 375 dp: `wm size 750x1697`, `wm density 320`, gesture
navigation; the owner's phone was not connected and was not touched): three `flutter drive` runs of
`hybrid_transfer_capture_test.dart`, all passed — 21 Light frames (Home, Plan and its editors/choosers/menu,
Home sheets and candidates, Night, Moon, Weather A/B/offline) in `android/`, 20 Light frames (Logbook, entry,
result, Library lists/records/editors/dialogs, Settings pages) in `android/b2/`, and 9 frames in Dark and Field
(Home, Plan, Calibration frames, the Discard-this-edit dialog, Weather, Logbook, Library, the delete dialog,
Appearance) in `android/b3/`. Every frame was opened next to its web capture (`android-pairs/`): the native
layouts match the reviewed host pairs; differences are fixture data, the recorded deviations and the device's
own scroll position on one Weather frame. Builds on this machine need `GRADLE_OPTS="-Dorg.gradle.project.kotlin.incremental=false
-Dkotlin.compiler.execution.strategy=in-process"` (Kotlin's incremental caches fail across the C:/D: drives).

Release APK (contract §7) — the final artifact:

| Item | Value |
| --- | --- |
| Source | `develop` at `548d7d6` (no file under `lib/`, `assets/`, `android/app/src/` or the pubspec differs between that commit and the build) |
| Command | `flutter build apk --release` (documented release path: without `--no-pub`, see ENGINEERING_GUARDRAILS) with `GRADLE_OPTS="-Dorg.gradle.project.kotlin.incremental=false -Dkotlin.compiler.execution.strategy=in-process"`; `pubspec.yaml`/`pubspec.lock` unchanged |
| Entry point | normal `lib/main.dart`, no fixtures |
| Artifact | `build/app/outputs/flutter-apk/app-release.apk`, SHA-256 `2792fbe2819d4a4615d34426605b43f4908976ba21d0b419e01e52099dafbb39` |
| Package | `io.github.buffur.culmina`, versionName 1.0.0, versionCode 1, minSdk 24, targetSdk 36; ABIs arm64-v8a, armeabi-v7a, x86_64 |
| Signing | v2, certificate `CN=Android Debug, O=Android, C=US` (SHA-256 `bc16984f…090c7d`): no `android/key.properties`, so the build uses the debug key — **перевірочний, не магазинний** |
| Smoke of this exact file | `emulator-5554` only, clean installs; the installed `base.apk` SHA-256 equals the artifact's. (1) First run → Welcome → Start planning → Tonight (no-site state) → Settings → Backup & data → Restore → DocumentsUI → a 37 MB non-backup file is refused and the message stays until Dismiss → Tonight → Set site → Use current position → Android permission dialog → declined accuracy → "Couldn't get your position. Please try again." → Add site → Save site → `am force-stop` → relaunch: "Smoke site", the computed night, the plan kept. (2) Back up now → Android share sheet with `astroplan-backup-…astroplan` (dismissed, nothing shared) |
| Evidence | `release-smoke/smoke-2792fbe2-after-restart.png`, `td112-position-failure-2792fbe2.png`, `td113-refusal-stays-2792fbe2.png`, `system-share-sheet-2792fbe2.png`, `system-file-picker.png`, `system-location-permission.png` |

Earlier builds of this run, kept as history: `f763ebd7…1c98` (the checkpoint-3 tree; its smoke `smoke1…8.png`,
system dialogs and the 13-byte restore refusal; rebuilt byte-identical after a comment-only change) and
`a2d9465a…` (TD-112 fix; restart smoke `smoke-a2d9465a-after-restart.png`). Both were superseded by `2792fbe2…`.

Owner decisions (2026-10-23, in the run's chat: «робимо», the recommended set): HT-DEV-01 engine line rounding
accepted; HT-DEV-02 catalogue edit and delete kept; HT-DEV-16 12 px floor kept. They change no code.

Result of this run: **COMPLETE** (§9), re-checked against the final state (2026-10-23):

1. Reference fixed (`86873ce`, unchanged); the registry covers the mandatory scope.
2. Every mandatory item is PASS, covered-by with its reason, a recorded native adaptation or an owner-decided
   deviation; no item is pending, blocked, failed or unverified.
3. Visual PASS rests on reviewed web/host pairs and Android frames (`android/`, `b2`–`b5`, `android-pairs/`);
   the remaining differences are recorded under Deviations, the three owner questions answered.
4. Actions are wired and tested: unit/widget suite 2442 passed, 6 skipped, 0 failed; host E2E `core_loop_test`
   (with a restart on a file database) and `perf_scenarios_test` pass; native dialogs exercised on the device.
   The two gaps found on the device (TD-112, TD-113) are fixed; no open follow-up remains from this transfer.
5. `flutter analyze` clean, format and encoding clean; no known regression.
6. The regular release APK `2792fbe2…` was built from the committed source and that exact file passed the smoke.

Outside this pass by the contract, so not mandatory registry items: phone QA (§7 forbids touching the owner's
phone; §4 makes the disposable emulator the native confirmation), performance (§6: only a profile run on a
separately permitted physical device), 125/200 % text (§2, §4: a separate, deferred pass) and owner or store
acceptance (§9 last paragraph). `covered-by` and `native adaptation` are the contract's own statuses for
justified reuse and native-only surfaces (§3, §9.2–9.3); only deviations from the reference needed the owner, and
HT-DEV-01, -02 and -16 were decided. Committed locally on `develop` (`1577cdd`, `501d98c`, `548d7d6` and this record); not pushed.

NEEDS ATTENTION / Варто звернути увагу (2026-10-23, CLAUDE.md V7): the run's automatic completion check kept
judging §9 unmet on interpretation, not on new evidence — it does not accept the contract's `covered-by` and
`native adaptation` statuses, host-plus-emulator evidence, or the items the contract places outside this pass
(phone, performance, 125/200 % text, store acceptance) as meeting "zero unverified mandatory items". Automatic
re-validation stops here. Owner question: **does this record, with those statuses and exclusions as the contract
defines them, meet §9 — or do you want any excluded check (for example a phone scenario you approve) done before
the transfer is called COMPLETE?** Until answered, the engineering result above stands as recorded and the
transfer is held at this checkpoint.

