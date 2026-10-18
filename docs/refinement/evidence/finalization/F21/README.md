# F21 — Persist settings and units with honest save and retry state (evidence, partial)

Run: full final-plan group (owner launch 2026-10-18), second cloud session, 2026-10-18.
Environment: Linux container, Flutter 3.47.4 / Dart 3.13.3 (the CI pin). No Android SDK.

Row done: **A6** (AM-03, CRUX-02). A1–A5 are not started: they depend on the F03 (ADR-021),
F14 and F19 presentation contracts (roadmap F21 dependencies); A6 is self-contained.

## Changed files

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

## Criterion result

| Criterion | Result | Evidence |
| --- | --- | --- |
| CHK-F21.A6 | PASS (TEST); U render pending (F25) | `place_name_switch_persistence_test.dart`: an On that cannot be stored stays Off with no unsaved mark, sends nothing (also for a later position) and reloads Off; while On is being stored nothing is sent, then it applies and the position is looked up once; an Off that cannot be stored stays Off, marked unsaved, sends nothing, and Retry stores it (reload Off); after an unsaved Off a restart shows the stored On without an unsaved mark; On then Off with held writes: the writes run in order, the older completion never shows On, the final stored and shown choice is Off. Widget: Settings shows the unsaved line and Retry after a failed Off, with the failure message, and clears them once Retry stores it. All six failed with the previous `setPlaceNameLookup` (mutation run) |

## Commands (working tree before the commit)

- `flutter test --no-pub test/presentation/viewmodels/place_name_switch_persistence_test.dart`
  → `+6: All tests passed!`
- `flutter test --no-pub test/presentation/screens/settings test/presentation/viewmodels
  test/presentation/screens/sites test/presentation/screens/home test/presentation/screens/tonight
  test/presentation/shared test/presentation/secondary_consistency_test.dart test/lifecycle`
  → one failure (the settings test above, which expected On before the write); after its update
  `test/presentation/screens/settings` → `+26: All tests passed!`
- `flutter analyze --no-pub` → `No issues found!`; changed-file format and encoding pass.
