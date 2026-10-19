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

## A2 — QuantityText and theme

- `test/presentation/quantity_text_usage_test.dart` (new, bounded): in `lib/presentation` no
  number formatted on the spot may be followed by a covered unit (%, °, MB, GB, km/h, mph, m/s,
  ft), and no hard-coded `°C`/`°F`/`km/h` symbol may remain (F21's units); a self-check proves it
  sees each form. It found 14 bypasses, now through `QuantityText.percent`, the new
  `QuantityText.percentRange` and `QuantityText.degrees` (capability text, opportunity reasons,
  share text, Settings, candidates, altitude chart, sky darkness, the result form's range
  symbols). Seconds/minutes in Settings' slider labels are those settings' own whole units and
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
| CHK-F25.A1 | PASS (HOST renders + TEST) | `renders/` (52), the extended sweep (6 variants pass), three fixes above. Device captures: G2 |
| CHK-F25.A2 | PASS (TEST) | `quantity_text_usage_test.dart` (+ self-check), 14 bypasses removed; theme/field tests pass |
| CHK-F25.A3 | PASS functional (HOST); comprehension UNVERIFIED | `W_JOURNEYS.md` |
| CHK-F25.A4 | NEEDS ATTENTION (owner) | the owner's visual acceptance of the renders |

## Commands (working tree before the F25 commit)

- `ASTROPLAN_U_RENDERS=docs/refinement/evidence/finalization/F25/renders flutter test --no-pub test/presentation/design_system/u_renders_test.dart` → `+3`
- `flutter test --no-pub test/presentation/accessibility_test.dart --plain-name "editors, dialogs"` → `+6` (failed before the fixes: target editor overflow; map picker overflow and unlabelled map)
- `flutter test --no-pub test/presentation/quantity_text_usage_test.dart …` with shared, settings, tonight, widgets, execution, core → `+542`
- `flutter test --no-pub test/core/theme test/presentation/theme` → `+46`
- `flutter test --no-pub test` → `+2246 ~5: All tests passed!` (the 3 opt-in render tests skipped); host E2E `core_loop` `+2`, `perf_scenarios` `+1`
