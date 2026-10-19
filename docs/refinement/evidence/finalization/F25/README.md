# F25 — Consistency, accessibility and workflow acceptance (evidence)

Run: full final-plan group (owner launch 2026-10-18), second cloud session, 2026-10-19, after
F05–F24. Environment: Linux container, Flutter 3.47.4 / Dart 3.13.3 (the CI pin). Evidence
layers: HOST tests and HOST renders (real Roboto and Material icons from the SDK); no device.

## A1 — U evidence for every changed surface

- **Renders** (`renders/`, 52 PNG, 412 × 915): `test/presentation/design_system/u_renders_test.dart`
  (opt-in: `ASTROPLAN_U_RENDERS=<dir>`, outside the gate like the gallery) boots the real app,
  router and database and shoots each surface in **light 100 %**, **dark 200 %** and **field
  100 %** (through the app's red filter): Home (Tonight), the planner, candidates, Night & Moon,
  Weather, the Logbook (result states), an entry (saved forecast), the result form (early
  report), Settings and its Display section (Appearance and units), Sites, the site editor, the
  rig editor, the block editor, Welcome, the AstroBin preview and the Logbook filter panel; plus
  the **block editor at 200 % with the keyboard open** (`block_editor_inset300_dark_200.png`,
  300 px inset: the dialog scrolls, its actions stay reachable).
- **Real glyphs:** the first pass drew app-bar titles as the test font's blocks, because the
  theme's hand-built `titleTextStyle` (and field mode's snackbar `contentTextStyle`) named no
  family; they now name Roboto (Android's system font, so the app looks as before on a device)
  and every render shows real text.
- **Accessibility sweep extended** (`accessibility_test.dart`, new test "editors, dialogs, the
  filter panel and the map picker meet the guidelines", light/dark/field × 100/200 %): the
  Logbook filter panel, the AstroBin preview, the rig editor, the target editor, the block
  editor and the map picker. It found and this task fixed:
  - the **target editor** overflowed at 200 % (226 px; 2.4 px at 100 %): the object-type
    dropdown is now `isExpanded` with an ellipsis;
  - the **map picker**: flutter_map's one-line attribution overflowed at large text — replaced by
    the app's own "© OpenStreetMap contributors" line, which wraps and keeps the link; the
    tappable map had no label — "Map. Tap to choose a point".
  After the fixes all six variants pass. The existing sweep (every screen, Settings with all
  options, planning settings, the result form's reasons, the planner with sections open and a
  new plan) passes unchanged.

### Re-audit additions (2026-10-19, `e6a0376`)

The re-audit of the plan found that the renders covered default states only and that two changed
surfaces (About after F23 A5, the map picker after F25's own fix) had no current render. The
render test now also shoots, in all three variants: the unsaved Settings lines (planning, place
names, units; F21 A5/A6), the site editor's place-name offer, "Looking up a place name…", the
not-found line and the "Use position" message (F23 A5/A6), the target search running and failed
(F24 A6), the deleted-plan fallback (F22 A1), an empty AstroBin export (F20), About with the
licence and the Play services permission (F23 A2) and the map picker (F24 A2); at 200 % with the
keyboard open also the site editor and the result form. **96 renders.** They found one defect:
the planning card's Retry on the error colour at **1.67:1**; it now uses `onErrorContainer`, and
`display_settings_test.dart` checks text contrast on both unsaved states (it failed before).

### Surface / criterion matrix

| Surface (task) | Criterion | Renders (`renders/<name>_{light_100,dark_200,field_100}.png`) | Host test |
| --- | --- | --- | --- |
| Home / Tonight (F17) | F17 A1–A5 | `home` | `tonight_home_screen_test.dart` |
| Planner (F06–F12, F18) | F18 A1–A6, F11, F12 | `planner` | `planner_f18_test.dart`, `planner_structure_test.dart` |
| Block editor (F06, F08, F10) | F06, F08, F10 | `block_editor`, `block_editor_inset300` (dark 200) | `block_settings_test.dart`, `block_from_photo_test.dart`, `block_from_fits_test.dart` |
| Rig editor (F05) | F05 A1–A6 | `rig_editor` | `rig_creation_test.dart` |
| Candidates (F17 A5) | F17 A5 | `candidates` | `tonight_home_screen_test.dart` |
| Night & Moon (F13, F15) | F15 A1–A5 | `night` | `night_moon_browse_test.dart` |
| Weather (F14) | F14 A1–A6 | `weather` | `forecast_nights_test.dart`, `weather_forecast_widget_test.dart` |
| Logbook, entry, result form (F19) | F19 A1–A5 | `logbook`, `entry`, `results`, `results_inset300` (dark 200) | `results_screen_test.dart`, `session_detail_test.dart` |
| AstroBin export (F20) | F20 A1–A4 | `astrobin_preview`, `astrobin_empty` | `astrobin_export_test.dart` |
| Logbook filters (F19) | F19 A1 | `logbook_filters` | `logbook_screen_test.dart` |
| Settings and units (F21) | F21 A1–A6 | `settings`, `settings_display`, `settings_unsaved`, `settings_place_names_unsaved`, `settings_display_unsaved` | `display_settings_test.dart`, `settings_persistence_test.dart` |
| Sites, site editor (F23) | F23 A5–A7 | `sites`, `site_editor`, `site_editor_offer`, `site_editor_looking`, `site_editor_not_found`, `site_editor_position_found`, `site_editor_inset300` (dark 200) | `sites_screen_test.dart`, `site_label_test.dart` |
| Target search (F24 A6) | F24 A6 | `target_searching`, `target_search_failed` | `target_search_race_test.dart` |
| Restored route (F22) | F22 A1 | `deleted_plan_fallback` | `route_restoration_test.dart` |
| Welcome (F16) | F16 A1–A4 | `welcome` | `welcome_screen_test.dart`, `tonight_home_screen_test.dart` |
| About (F23 A2/A5) | F23 A2, A5 | `about`, `about_licence` | `about_screen_test.dart` |
| Map picker (F24 A2, F25) | F24 A2 | `map_picker` (host: no tiles) | `location_picker_tiles_failing_test.dart` |

Keyboard-open evidence: the block editor, the site editor and the result form (dark 200 %, 300 px
inset). The rig and target editors are covered by the accessibility sweep at 200 % (no overflow),
not by a keyboard render.

## A2 — QuantityText and theme

- `test/presentation/quantity_text_usage_test.dart` (new, bounded): in `lib/presentation` no
  number formatted on the spot may be followed by a covered unit (%, °, MB, GB, km/h, mph, m/s,
  ft), and no hard-coded `°C`/`°F`/`km/h` symbol may remain (F21's units); a self-check proves it
  sees each form. It found 14 bypasses, now through `QuantityText.percent`, the new
  `QuantityText.percentRange` and `QuantityText.degrees` (capability text, opportunity reasons,
  share text, Settings, candidates, altitude chart, sky darkness, the result form's range
  symbols).
  *(Re-audit 2026-10-19, `47c8ee8`:)* the check missed values interpolated straight before a unit
  (`'$h %'`, `'${n(v)} MB'`, `'$limit°'`) and did not read `lib/domain`, whose reasons are shown
  as written. Widened to both, it found nine more: the fit's darkness reason ("-18°" with a hyphen,
  now "−18°"), its margin, the entry's humidity ("82.0 %"), cloud and saved-forecast range, the
  share text, the forecast's cloud semantics and the import's RAW size (now decimal MB). A
  field's own text echoed as typed is marked `// as typed`. Seconds/minutes in Settings' slider labels are those settings' own whole units and
  are left out of the covered set on purpose.
- Field mode and approved contrast: unchanged tokens (F21 A4); the theme tests
  (`test/core/theme`, `test/presentation/theme`, `+46`) and the field-mode darkness checks pass.

## A3 — W journeys

`W_JOURNEYS.md`: the four journeys step by step with the screen, action, backtrack, lookup and the
visible fit/Unknown/relative-gain explanation, each executed by a named HOST test. No dead end.
Human comprehension **UNVERIFIED** (no independent participant; the accepted S6.E gap). Carried
inputs: real FITS / owner camera samples (F03 A5, F04 A4, F10 A3), the Android process-death run
(F22), the live AstroBin import.

## A4 — owner final visual acceptance

**NEEDS ATTENTION / OWNER**: the renders above and the earlier tasks' renders are ready for the
owner's review; the acceptance itself is the owner's and is not claimed here. No functional or
accessibility blocker is open from this sweep.

## Criterion results

| Criterion | Result | Evidence |
| --- | --- | --- |
| CHK-F25.A1 | PASS (HOST renders + TEST) | `renders/` (96 since the re-audit), the matrix above, the extended sweep (6 variants pass), four fixes above. Device captures: G2 |
| CHK-F25.A2 | PASS (TEST) | `quantity_text_usage_test.dart` (+ self-check), 14 bypasses removed; theme/field tests pass |
| CHK-F25.A3 | PASS functional (HOST); comprehension UNVERIFIED | `W_JOURNEYS.md` |
| CHK-F25.A4 | NEEDS ATTENTION (owner) | the owner's visual acceptance of the renders |

## Commands (working tree before the F25 commit)

- `ASTROPLAN_U_RENDERS=docs/refinement/evidence/finalization/F25/renders flutter test --no-pub test/presentation/design_system/u_renders_test.dart` → `+3`
- `flutter test --no-pub test/presentation/accessibility_test.dart --plain-name "editors, dialogs"` → `+6` (failed before the fixes: target editor overflow; map picker overflow and unlabelled map)
- `flutter test --no-pub test/presentation/quantity_text_usage_test.dart …` with shared, settings, tonight, widgets, execution, core → `+542`
- `flutter test --no-pub test/core/theme test/presentation/theme` → `+46`
- `flutter test --no-pub test` → `+2246 ~5: All tests passed!` (the 3 opt-in render tests skipped); host E2E `core_loop` `+2`, `perf_scenarios` `+1`
