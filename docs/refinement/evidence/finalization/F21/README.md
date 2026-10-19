# F21 — Persist settings and units with honest save and retry state (evidence)

Run: full final-plan group (owner launch 2026-10-18), second cloud session, 2026-10-18.
Environment: Linux container, Flutter 3.47.4 / Dart 3.13.3 (the CI pin). No Android SDK.

A6 (AM-03, CRUX-02) was done first, on 2026-10-18 (section "A6" below). A1–A5 followed on
2026-10-19, after F03, F14 and F19 had set the presentation contracts they depend on (section
"A1–A5").

## A6 — changed files

- `lib/presentation/viewmodels/settings_viewmodel.dart`: `setPlaceNameLookup` — Off applies at
  once (no position is sent from the tap on) and, if it cannot be stored, stays applied and is
  marked `placeNameLookupUnsaved`; On applies only after it is stored, so while it is being
  stored and after a failed write lookups stay off. Writes are chained so they run in order,
  and only the newest request's outcome changes what is shown. Failures are rethrown for the
  screen's message.
- `lib/presentation/screens/settings/settings_screen.dart`: under the switch, an unsaved Off says
  "Off for now, but not saved: after a restart place names would be on again." with Retry.
- Tests: `test/presentation/viewmodels/place_name_switch_persistence_test.dart` (new);
  `settings_screen_test.dart` "the place-name switch turns lookups on" now lets the write finish
  before expecting On (the A6 contract: On applies once stored).

Default (off), consent wording, provider, attribution, call limits and `OptInReverseGeocoder`
are unchanged.

## A6 — criterion result

| Criterion | Result | Evidence |
| --- | --- | --- |
| CHK-F21.A6 | PASS (TEST); U render pending (F25) | `place_name_switch_persistence_test.dart`: an On that cannot be stored stays Off with no unsaved mark, sends nothing (also for a later position) and reloads Off; while On is being stored nothing is sent, then it applies and the position is looked up once; an Off that cannot be stored stays Off, marked unsaved, sends nothing, and Retry stores it (reload Off); after an unsaved Off a restart shows the stored On without an unsaved mark; On then Off with held writes: the writes run in order, the older completion never shows On, the final stored and shown choice is Off. Widget: Settings shows the unsaved line and Retry after a failed Off, with the failure message, and clears them once Retry stores it. All six failed with the previous `setPlaceNameLookup` (mutation run) |

## A6 — commands (working tree before its commit)

- `flutter test --no-pub test/presentation/viewmodels/place_name_switch_persistence_test.dart`
  → `+6: All tests passed!`
- `flutter test --no-pub test/presentation/screens/settings test/presentation/viewmodels
  test/presentation/screens/sites test/presentation/screens/home test/presentation/screens/tonight
  test/presentation/shared test/presentation/secondary_consistency_test.dart test/lifecycle`
  → one failure (the settings test above, which expected On before the write); after its update
  `test/presentation/screens/settings` → `+26: All tests passed!`
- `flutter analyze --no-pub` → `No issues found!`; changed-file format and encoding pass.

## A1–A5 (2026-10-19)

Evidence layer: HOST unit, ViewModel and widget tests through the real app, router and the
SharedPreferences mock. Verification class: **high risk** (persisted preference and write
semantics, the backup format) and shared behaviour (the theme, every unit display path).

### What changed

- `lib/core/units/display_units.dart` (new): `Appearance` (System, Light, Dark), `TemperatureUnit`,
  `WindUnit`, `ElevationUnit` (stored by name; unknown → default) and `DisplayUnits` with exact
  conversions: absolute °F = °C × 9/5 + 32, a **difference** × 9/5 only; 1 mph = 1.609344 km/h;
  1 m/s = 3.6 km/h; 1 ft = 0.3048 m; typed values back to °C and metres.
- `QuantityText.temperature`, `temperatureDifference`, `temperatureAsRecorded`, `wind`,
  `elevation`.
- `DisplaySettingsRepository` / `SharedPrefsDisplaySettingsRepository` (keys `appearance`,
  `units.temperature`, `units.wind`, `units.elevation`), `DisplaySettingsViewModel` (shown vs
  stored, chained and coalesced writes, `unsaved`/`saving`, `retry`, `idle`), wired in
  `AppViewModels`, loaded in `main.dart` before the first frame; `MaterialApp.themeMode` follows
  the Appearance; field mode still swaps both themes for the red one.
- `SettingsViewModel`: planning preferences shown vs stored, the same write rule,
  `planningPreferencesUnsaved`/`Saving`, `retryPlanningPreferences`, `planningIdle`;
  `PlanningPreferencesRepository.lastSaveIncomplete` with the `planningPreferencesWriting` mark
  (set before the keys are written, removed after; carried by the backup).
- `BackupPreferences`: the additive `string` group (read, parse, restore); the display keys carried.
- Screens: Settings → Display (`DisplaySettingsSection`: Appearance and the three units, unsaved
  line with Retry); the planning "in use but not saved" card with Retry; the dew margin label as a
  difference. Units through the forecast widget (facts, details, hour strip and its legend, the
  selected hour's exact values, dew line), the coming nights, the entry detail (temperature,
  elevation) and its Share text, the Logbook row's Share, the result form's temperature (typed in
  the unit, stored in °C; unchanged = the stored value), the site editor's elevation (likewise,
  with a range check in the typed unit) and the metadata/proposal sensor temperatures.
- **D1 = A:** no token changed (`git diff -- lib/core/theme` is empty), so no AA pair changed; the
  existing light/dark AA vectors (`design_tokens_test.dart`, `controls_theme_test.dart`) and the
  documented field-mode exception stand. No navy/ice-blue redesign; new installs start on System.

### Criterion results

| Criterion | Result | Evidence |
| --- | --- | --- |
| CHK-F21.A1 | PASS (TEST) | `preferences_round_trip_test.dart`: every carried key (all 17 planning values, field mode, a section state, the active site, first run, Appearance and the three units) survives read → JSON → parse → restore on another device by type and value, and the repositories load them; a pre-F21 file (no `string` group) restores System/°C/km/h/m; an unknown future name restores and reads as its default; a malformed string refuses the file. `backup_restore_test.dart` (updated for the group): the carried set by type and the full round trip including display settings. `display_units_test.dart`: unknown names → defaults |
| CHK-F21.A2 | PASS (TEST); U at F25 | `display_units_test.dart` (wind, elevation, formatting); `display_units_paths_test.dart` (forecast temperature and wind ranges, the site form's feet check); `entry_share_text_test.dart` "the conditions in °F"; `results_screen_test.dart` "in °F the temperature is typed in °F and stored in °C" (50 °F → 10 °C stored); `display_settings_test.dart` A2/A3 (Settings stores the unit names; the stored dew margin unchanged) |
| CHK-F21.A3 | PASS (TEST) | `display_units_test.dart`: absolute 0 → 32, −40 → −40, 100 → 212, −3.5 → 25.7 and back; difference 2 → 3.6 (never 35.6), 0 → 0, 5 → 9; `display_settings_test.dart`: the Settings dew margin label × 9/5 without +32 |
| CHK-F21.A4 | PASS (TEST); U at F25 | `display_settings_test.dart` A4: `themeMode` System on a new install; Dark and Light apply at once, are stored, and a restart reads the stored choice; with field mode on both themes are the field theme. AA: no token changed (above) |
| CHK-F21.A5 | PASS (TEST) | `settings_persistence_test.dart`: a failed write keeps the edit applied and unsaved, never stored, and Retry stores the newest; held writes run in order and coalesce (saves 30, 45; B skipped), the older completion leaves the state "saving", the newest is stored; an older failure while a newer write is queued does not mark it unsaved and the newer stores both fields (unrelated-field preservation); the newest failing after an older success: unsaved, the older stored, Retry stores the newest; an interrupted multi-key save is reported after a restart and "Retry" clears the mark; a completed save leaves none; Appearance/units: failure stays shown and unsaved, a restart shows the stored choice, Retry stores; held display writes coalesce. `display_settings_test.dart` A5: the Settings unsaved line/card with the failure message and Retry for a unit and a planning edit. Snapshots keep their saved assumptions (unchanged code path); the place-name opt-in (A6) unchanged |

**Mutation checks** (each reverted afterwards; failures across the F21 test files): a difference
converted with +32 (2); a superseded planning write not skipped (1); a planning failure marked
unsaved for an older request (1); the backup's `string` group not restored (1); the
incomplete-save mark never removed (2); Dark mapped to System (1); a typed °F stored unconverted
(1); a forecast range not converted (1); a superseded display write not skipped (1); a display
failure never marked unsaved (2); the Share text in metric only (1). One survived: removing the
"newest request" check on a planning **success** (0) — redundant by design, since writes are
serialized and "saving" is derived from the shown vs stored values, so an older success cannot
mark a newer edit saved; kept as a guard.

### Commands (working tree before the F21 commit)

- `flutter analyze --no-pub` → `No issues found!`; format 0 changed; encoding passed
- `flutter test --no-pub test` → `+2232 ~2 -1`: `secondary_consistency_test.dart` caught a raw
  `TextStyle` in the new "not saved" card; it now uses `textTheme.bodyMedium`, then
  `secondary_consistency_test.dart` and `test/presentation/screens/settings` → `+32`
- `integration_test/core_loop_test.dart -d flutter-tester` → `+2`, `perf_scenarios_test.dart` → `+1`
- targeted: `display_units_test.dart` `+4`, `preferences_round_trip_test.dart` `+4`,
  `settings_persistence_test.dart` `+8`, `display_settings_test.dart` `+4`,
  `display_units_paths_test.dart` `+2`, `entry_share_text_test.dart` and
  `results_screen_test.dart` `+22`, `test/data/backup` `+46` (with the conversions)
