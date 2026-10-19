# F19 — Returning-plan and Logbook actions (evidence)

Run: full final-plan group (owner launch 2026-10-18), second cloud session, 2026-10-19.
Environment: Linux container, Flutter 3.47.4 / Dart 3.13.3 (the CI pin). Evidence layer: HOST
tests through the real app, router and in-memory database; repository and domain unit tests.
Verification class: **high risk** (result eligibility changes persisted lifecycle behaviour).

## What changed

- **Eligibility (A2/A5; AM-01 amends D8-1's eligibility only):**
  - `SavedNightEnd.startOf` / `hasStarted`: a saved night's result may be recorded from the
    stored SessionNight window's start (the snapshot's night; the execution-start snapshot for a
    run). Without a readable snapshot only the key is known: 00:00 UTC the day after the later of
    the key and the night the unreadable snapshot names — the latest start any site's night with
    that key can have, so never early. `hasEnded` (dawn) is unchanged and still drives the
    planner's transition, Upcoming/Past and Tonight's "how did it go?" line.
  - The same rule in the domain (`ResultAction.of`), the repository
    (`DriftSessionRepository.recordResult`: `NightNotStarted`, a subtype of `NightNotEnded`), the
    form (`ResultsViewModel.canRecord`, `onlyNotDone`) and the entry (`SessionsViewModel.isUpcoming`
    keeps "Open in planner" on tonight's saved plan beside Record result).
  - The form says when a future night can be reported ("This night hasn't started yet. You can
    record the result from <date>, <time> (<zone>)") and, during the night, that a result finishes
    it early. Nothing completes a night automatically.
- **Saved · changed during its night (A5):** `ResultsViewModel.pendingChanges` holds the form until
  the changes are resolved: **Save changes** (only the planner's own plan, through
  `CaptureAnalysisViewModel.saveSession`), **Discard changes** (after `confirmDestructive`;
  `PlanLifecycleViewModel.discardSavedChanges` for the planner's plan, else
  `SessionRepository.revertToSaved`), **Cancel** (nothing changes). Pending edits are never shown as
  the saved plan's blocks. After the night the entry is settled as before (D8-1, I-3).
- **Logbook cards (A1):** `PlanStateLabel` draws an icon beside Completed, Partly and Not done; a
  due report shows "Result not recorded" (`AppWords.resultNotRecorded`) with an icon; every Saved
  or Not done row shows its planned integration (`SessionReconciliation.plannedOnly`), "none
  recorded of … planned" while a report is due; Record result / Edit result stay on the row.
- **Entry forecast (A3):** the detail's Weather section reads the snapshot only: "as saved with the
  plan", source, fetch time, "Age when saved", the dark hours' cloud range and hours without a
  forecast (`SessionSnapshot.weatherAgeAtSave`, `weatherCloudPct`, `weatherHoursWithoutForecast`).
- **Stored-record Delete (A4):** no code change; the editor's visible Delete with
  `confirmDestructive` (S5.8/RD-09) now has an end-to-end test for the plan's own rig and target.

## Criterion results

| Criterion | Result | Evidence |
| --- | --- | --- |
| CHK-F19.A1 | PASS (TEST); U at F25 | `results_screen_test.dart` "the Logbook" F19 A1 ×2: during the night the card reads "Result not recorded" with `Icons.pending_actions`, "Integration: none recorded of 2 h planned" and Record result; after Partly 9 the card reads Partly with its icon, "Integration: 45 min of 2 h planned" and Edit result; a night ahead shows "Integration: 2 h planned" and no Record; Not done has its word and `Icons.cancel_outlined`. Entries/Progress and Plan this target keep their RD-07 places (`logbook.progress`, `targetEditor.plan`, unchanged) |
| CHK-F19.A2 | PASS (TEST) | `drift_session_results_test.dart`: every outcome refused before the stored start (`NightNotStarted`, nothing written); the current night before dawn records Partly, snapshot JSON unchanged, counters equal the replay, a new repository instance (restart) reads it. `results_screen_test.dart`: "before its night starts …" (the start's date in the message) and "during its night a result finishes it early" (status stays planned until Save result; the early result counts in Progress at once: 45 min, 1 session); the existing after-dawn, edit and stale-form tests pass unchanged |
| CHK-F19.A3 | PASS (TEST) | `session_detail_test.dart` "the entry's forecast is the one saved with the plan": a plan saved with an aging Open-Meteo forecast shows "as saved with the plan", its source, "Age when saved: aging", "Cloud cover (dark hours): 15–40 %" and hours without forecast, from the snapshot alone. `session_snapshot_builder_test.dart`: the same getters after a JSON round trip; none without a forecast |
| CHK-F19.A4 | PASS (TEST); U/W at F25/G2 | `library_manage_mode_test.dart` "F19 A4": the plan's rig — Cancel and a tap outside keep the record and the selection; Delete removes it and the plan needs a rig; the plan's target likewise; the saved entry's snapshot JSON is unchanged and still names both. No stored-record Undo added |
| CHK-F19.A5 | PASS (TEST) | One rule in domain/repository/UI (above; the saved snapshot's night, never the live site's). `results_screen_test.dart` "a Saved · changed plan during its night": Cancel changes nothing (still Saved · changed, no events); Save makes the edits the saved plan, which is reviewed and reported (30 frames); Discard after the confirmation (a cancelled one keeps the changes) reverts the entry and the planner and reports the saved 24. Unreadable plans keep Not done only, now from the night's start (`results_unreadable_plan_test.dart` passes unchanged; the key-only start is tested in `drift_session_results_test.dart`). Stale-form refusal unchanged |

**Mutation checks** (each reverted afterwards; failures in the named file): `ResultAction` back to
`hasEnded` (1); repository planned check back to `hasEnded` (1) and removed (1); `canRecord` back
to `hasEnded` (4); `pendingChanges` always false (3); "Age when saved" label (1); cloud range
values (1); key-fallback start one day early (1); the early note removed (1); the Logbook due flag
removed (1); Not done's icon removed (1); Save offered for no entry (1).

## Commands (working tree before the F19 commit)

- `flutter analyze --no-pub` → `No issues found!`; `dart format` 0 changed; encoding passed
- targeted: `results_screen_test.dart` `+17`, `drift_session_results_test.dart`, `session_detail_test.dart` with `session_snapshot_builder_test.dart` `+26`, `library_manage_mode_test.dart` `+11`, Logbook/ViewModel/shared folders `+205`
- `flutter test --no-pub test` → `+2200 ~2: All tests passed`
- `integration_test/core_loop_test.dart -d flutter-tester` → `+2`, `perf_scenarios_test.dart` → `+1`

## Not covered here

- U renders of the cards and the form (F25); the returning multi-night W journey on a phone (G2).
