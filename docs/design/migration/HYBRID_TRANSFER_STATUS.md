# Hybrid transfer into Flutter — status (2026-10-22)

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
| Start of the run | branch `develop`, HEAD `ed29554`; no commit, pull, push, reset, stash or checkout in this run (contract §1) |
| Pre-existing dirty work | `equipment_editor.dart`, `target_selection_screen.dart` and their two tests (2026-10-21 interim fixes the owner said are superseded and must not be committed) plus untracked `evidence/rig-*`, `target-editor-*`, `baseline-2026-10-21/`. Preserved unchanged as [preexisting-dirty-2026-10-21.patch](evidence/hybrid-transfer-2026-10-22/preexisting-dirty-2026-10-21.patch) (SHA-256 `d4595caa…74`) before any edit of those files |
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
`external-unverified`, `blocked`, `fail`. Visual and functional are independent. Web sources are relative to
`design/home-lab/`. Matrix A IDs refer to [WEB_DESIGN_INVENTORY.md](WEB_DESIGN_INVENTORY.md) behaviour rows.

### Shared foundation

| ID | Surface / state | Web source | Flutter target | Req. | Visual | Functional | Evidence |
| --- | --- | --- | --- | --- | --- | --- | --- |
| HT-F01 | Fonts: Geist UI, Source Serif 4 opsz 14 night/editorial headings | `fonts/fonts.css`, `--plan-night-font` | `assets/fonts`, `AppTypography` | required | in progress (host; Android pending) | N/A | checkpoint 1 |
| HT-F02 | Role type scale 22/500 · 20/600 · 18/500 · 16/600 · 15/400 · 14/400 · 13/400 · 12 dense | `hybrid-refinement.css`, `notion-hybrid.css` | `AppTypography`, theme | required | in progress (code + host) | N/A | |
| HT-F03 | Palette: neutral Light/Dark, Notion blue `#0075DE`/`#62AFF3`, success/caution/error washes, data tokens, Field red/black | `notion-hybrid.css`, `hybrid-data-tokens.css` | `AppColors`, `AppPalette`, `HybridTokens` | required | in progress (code + host) | N/A | |
| HT-F04 | Icons: web SVG paths (24 viewBox, round stroke 1.6–1.8), Lucide data icons | `*.js` `paths`, `icons.js` | `HybridIcon` | required | in progress (code + host) | N/A | |
| HT-F05 | Section heading, disclosure (20/600, caption, end chevron) | `hybrid-refinement.css` | `CollapsibleSection`, shared headings | required | in progress (code + host) | expand/collapse, semantics | |
| HT-F06 | Row button (icon + 16/600 label, 15 value, 13 caption, chevron), dividers | `plan.js rowButton`, `styles.css` | shared row widget | required | in progress (code + host) | navigation | |
| HT-F07 | Status labels: Saved / Saved · changed / Not saved / Completed / Partly / Not recorded / Not done | `notion-hybrid.css`, `logbook.css` | `PlanStatus`, Logbook state | required | in progress (code + host) | exact semantics | |
| HT-F08 | Buttons: primary filled, secondary outlined, full-width row actions, disabled/focus/pressed | `styles.css`, `plan.css` | theme button styles | required | in progress (code + host) | states | |
| HT-F09 | WQA-01 Field primary `#FF0000` / black text (also dialogs); hover underline, pressed selection | `hybrid-refinement.css` | filled button theme (replaces D-06 outline) | required | in progress (code + host) | contrast | |
| HT-F10 | WQA-03 Field range: red/black track, thumb, focus | `hybrid-refinement.css` | slider theme | required | in progress (code + host) | value/semantics | |
| HT-F11 | WQA-04 Dialogs: 20 edges, max-width 372, padding 24, actions ≥ 48 | `plan.css`, `hybrid-ui.js` | dialog theme / confirmation patterns | required | in progress (code + host) | Keep editing / Discard / Cancel | |
| HT-F12 | App bar (back, 22/500 title, field toggle, menu), root navigation (Roboto 11, selected 600 + subtle fill, top divider) | `plan.css`, `workspace.js` | `hybridAppBar`, `AppShell` | required | in progress (code + host) | Back, tabs, field toggle | |
| HT-F13 | Text fields, search field with filter/search icons, selects, radios, checkboxes, switches (Light/Dark/Field) | `styles.css`, `hybrid-refinement.css`, `library.css` | input theme, shared fields | required | pending | input, validation | |
| HT-F14 | Night timeline: gradient sky (blue ramp, black dark), Moon lanes 4 px under the sky, jump to dark start/end, opens at dark start | `night-ui.js`, `night.css`, `notion-hybrid.css` | `night_browser_sections.dart` | required | in progress (code + host) | real event positions, cursor, keys | |
| HT-F15 | Stacking-gain graph: blue gradient line/area, plan point, red in Field | `plan.css`, `hybrid-data-tokens.css` | `stacking_gain_graph.dart` | required | in progress (code + host) | relative √N only | |

### Screens and states

| ID | Surface / state | Web source | Flutter target | Req. | Visual | Functional | Evidence |
| --- | --- | --- | --- | --- | --- | --- | --- |
| HT-H01 | Tonight/Home ready (title, subtitle, site/night chips, four sections, no Welcome link) | `app.js`, `catalog.css`, `notion-hybrid.css` | `tonight_home_screen.dart` | required | in progress (host pair L/D/F reviewed; Android pending) | A-HOME-01…11 | `web/web-home-light-375.png`, `flutter-home-light-375.png`, `android-home-light.png` |
| HT-H02 | Home states: no site, loading, error/retry, empty plan, unknown inputs, no dark, partial/stale/offline weather | `app.js` scenarios | same | required | pending | A-HOME-10 | |
| HT-H03 | Home site sheet and night sheet (WQA-06 full-width 48 actions, chevron candidate rows) | `app.js`, `styles.css` | site/night pickers | required | pending | Apply/Cancel keep draft | |
| HT-H04 | First-run onboarding (real, kept) | — | `welcome_screen.dart` | required | native adaptation | first-run flow | |
| HT-H05 | Candidates ("What can I image …?") | `catalog.js` | `tonight_candidates_screen.dart` | required | pending | choose target | |
| HT-P01 | Plan main (status line, Fits answer, Site/Target/Rig rows, Capture plan, Estimate, disclosures, night rows, Save bar) | `plan.js`, `plan.css` | `home_screen.dart` (planner), `capture_plan_widget.dart` | required | in progress (code + host) | A-PLAN-01…16 | |
| HT-P02 | Plan context screen (site + night), target chooser, rig chooser | `plan.js` context/target/rig | `plan_context_screen.dart` (new), selection screens | required | in progress (context screen built; target/rig pending) | Apply/Cancel draft | |
| HT-P03 | Block editor (light/calibration, invalid, dirty → Discard dialog) | `plan.js` block | `capture_block_dialog.dart` | required | in progress (code + host) | validation/Apply/Cancel/Back | |
| HT-P04 | Calibration builder | `plan.js` calibration | `calibration_preview_dialog.dart` | required | pending | Apply + Undo | |
| HT-P05 | Budget/assumptions overrides editor | `plan.js` assumptions | `plan_overrides_editor.dart` | required | pending | overrides persist | |
| HT-P06 | Plan menu, Unsaved changes and Plan this night dialogs, save error/retry | `plan.html` dialogs | lifecycle UI | required | pending | Save/Discard/Cancel, new/copy/Undo | |
| HT-N01 | Night & Moon — Night tab (answer, timeline, disclosures) | `conditions.js`, `night.css` | `night_moon_screen.dart` | required | pending | A-NIGHT-01…07 | |
| HT-N02 | Moon tab (answer, calendar, timeline) | `conditions.js`, `conditions.css` | same | required | pending | A-MOON-01…06 | |
| HT-W01 | Weather A · Compact rows (statistics rows, Inspect an hour, Hourly values, details, Coming nights) | `weather-variants.js/.css`, `conditions.js` | weather widgets | required | pending | A-WX-01…09 | |
| HT-W02 | Weather B · Hourly charts (WQA-05 repeated hour labels, selected hour) | `weather-variants.js/.css` | `weather_hourly_charts.dart` | required | pending | same data as A | |
| HT-W03 | Weather states: partial, stale, offline, error/retry, no dark, gaps | `conditions.js` | same | required | pending | retry, stale reply | |
| HT-W04 | Weather view preference (Settings → Appearance, default rows, persisted, backup without the field reads rows) | `settings.js`, `notion-hybrid.css` | display settings | required | pending | pending | |
| HT-L01 | Logbook list (search + filter icon, months, state column, Progress row) | `logbook.js`, `logbook.css` | `logbook_screen.dart` | required | pending | A-LOG-01…03 | |
| HT-L02 | Logbook filters open, empty, no match, load error | `logbook.js` | same | required | pending | clear/retry | |
| HT-L03 | Entry detail (status header, grid, gain disclosure, Plan as saved, export buttons, Delete) | `logbook.js` detail | `session_detail_screen.dart` | required | pending | A-LOG-04, 06, 07 | |
| HT-L04 | Result editor (outcome, counts, reason, notes, dirty guard) | `logbook.js` edit | `results_screen.dart` | required | pending | A-LOG-05 | |
| HT-L05 | Progress by target | `logbook.js` progress | `progress_screen.dart` | required | pending | A-LOG-08 | |
| HT-B01 | Library root | `library.js` root | `library_screen.dart` | required | pending | A-LIB-01 | |
| HT-B02 | Rigs list, Targets list, Sites list (+ search, no match, empty, error) | `library.js` | selection/list screens | required | pending | A-LIB-02 | |
| HT-B03 | Rig / target / site details | `library.js` detail | detail screens | required | pending | Edit/Delete/Undo | |
| HT-B04 | Rig editor (+ More, photo walkthrough, JSON import, invalid) | `library.js` edit | `equipment_editor.dart` | required | pending | A-LIB-03…06, 10 | |
| HT-B05 | Target editor | `library.js` edit | `target_selection_screen.dart` | required | pending | A-LIB-07, 08, 10 | |
| HT-B06 | Site editor (+ device position, More) | `library.js` edit | `site_editor_screen.dart` | required | pending | A-LIB-09, 10 | |
| HT-B07 | Library dialogs: unsaved changes, delete, Undo | `library.js` | delete/confirmation patterns | required | pending | A-LIB-11 | |
| HT-S01 | Settings root | `settings.js` root | `settings_screen.dart` | required | fail (checkpoint 1 pair) | A-SET-01 | `web/web-settings-light-375.png` |
| HT-S02 | Appearance (theme, text, units, Weather view) | `settings.js` appearance | same | required | pending | A-SET-02, HT-W04 | |
| HT-S03 | Planning (+ two disclosures, unsaved dialog) | `settings.js` planning | same | required | pending | A-SET-03, 04 | |
| HT-S04 | Privacy | `settings.js` | same | required | pending | A-SET-05 | |
| HT-S05 | Backup & data, restore review/result | `settings.js`, `preview-backup.js` | `backup_section.dart` | required | native adaptation (format) | A-SET-06, 08 | |
| HT-S06 | About | `settings.js` | `about_screen.dart` | required | pending | A-SET-07 | |
| HT-X01 | Native-only: GPS/permissions, file import, export/share, backup files, metadata import, map picker | — | existing native screens | required | native adaptation | existing tests | |
| HT-X02 | Release APK built from normal `lib/main.dart`, smoke on emulator | — | Android build | required | N/A | pending | |

Excluded (contract §3): studio shell, concept/palette/gain-variant selectors, font gallery, phone frame, fake
status/gesture bars, browser-only preview notes ("saved in this browser").

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
