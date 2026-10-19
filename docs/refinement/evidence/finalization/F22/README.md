# F22 — Restore the open route without corrupting saved or draft state (evidence)

Run: full final-plan group (owner launch 2026-10-18), second cloud session, 2026-10-18.
Environment: Linux container, Flutter 3.47.4 / Dart 3.13.3 (the CI pin). No Android SDK or
emulator here, so no process-death run on Android.

Row worked: **A3**, its kill and v24 → v25 parts (TD-102's durability half, the Stage 11 probes
P1/P2). A1/A2 (route restoration, TD-094) are not started: the roadmap puts F16–F19/F21 before
the final shared-navigation edits, and A1's process-death test needs an emulator.

## Changed files (tests only)

- `test/lifecycle/lifecycle_matrix_test.dart`: **L4b**, probe P1 committed. On a file database a
  plan is saved and named "Orion trip" and two more are saved for the same night; the process is
  killed; after the night's dawn a new graph on the file sees the name and records Not done
  (clouds), Partly (7 frames) and Completed as planned; killed again; a third graph reads the
  name, `abandoned` with reason `clouds`, `partly` with 7 counted from the events, and
  `asPlanned`; the Logbook search for "orion" finds exactly the named entry.
- `test/data/database/schema_migration_test.dart`: probe P2 committed. A v24 file with a Not
  done row (reason `clouds`) and an `asPlanned` row with a `reported` and a `framesConfirmed`
  event, opened by `AppDatabase` (v24 → v25): status, kind, reason, no name, both events in
  order, and the replayed count (10) through `DriftSessionRepository`.

## Criterion results

| Criterion | Result | Evidence |
| --- | --- | --- |
| CHK-F22.A1 | Superseded by the 2026-10-19 rows below | — |
| CHK-F22.A2 | Superseded by the 2026-10-19 rows below | — |
| CHK-F22.A3 | PARTIAL on 2026-10-18 (kill and v24 → v25); completed 2026-10-19 below | L4b and the v24 → v25 test above. Mutation: writing no not-done reason in `recordResult` fails L4b (`Expected: NotDoneReason.clouds, Actual: null`) |

## Commands

- `flutter test --no-pub test/lifecycle test/data test/core` → `+517 ~1: All tests passed!`
- `flutter test --no-pub test/lifecycle/lifecycle_matrix_test.dart` → `+8: All tests passed!`
- `flutter analyze --no-pub` → `No issues found!`; format and encoding pass.

## A1/A2 and A3's v26 path (2026-10-19)

Dependencies met (F16–F19, F21 committed). Evidence layer: **HOST** — the framework's own
restoration data (`WidgetTester.getRestorationData`/`restoreFrom`) captured from one app graph
and restored into a new graph on the same database and preferences, with the router first put
back at its start, so a pass means the route really came back. The Android process-death run
("Don't keep activities" or `am kill` on an emulator) is **NEEDS ATTENTION**: no Android SDK or
emulator in this container (see F02).

### Changed files

- `lib/main.dart`: `MaterialApp.router(restorationScopeId: 'app')`.
- `lib/presentation/navigation/app_router.dart`: `GoRouter(restorationScopeId: 'router',
  extraCodec: RestoredArgsCodec())`; the site editor, the map picker and the metadata import
  build `RestoredArgsLostRedirect` (to Library → Sites / Rigs) when their `extra` was lost.
  Shell and branch scopes were tried and removed: go_router 18.0.1 asserts that never-built
  branches re-register their restorable locations, so only the router's location is restored.
- `lib/presentation/screens/home/session_planner_route.dart`: a `RestorationMixin` state; a
  restored route does not open its plan again (A2) and, when that plan was deleted, falls back.
- `lib/presentation/shared/deleted_plan_fallback.dart` (new): Tonight and "The plan you had open
  was deleted. Showing Tonight."
- `ResultsViewModel.missingId`; `ResultsScreen` uses the fallback for a deleted entry (it showed
  a spinner for ever).
- Test: `test/lifecycle/route_restoration_test.dart` (5).

Typed but unsaved fields of an open form are **not** restored: TD-094's contract is the route;
no second draft store is added (roadmap scope). A restored result form reloads the stored entry,
so its stale-form guard and Save rules hold.

### Criterion results

| Criterion | Result | Evidence |
| --- | --- | --- |
| CHK-F22.A1 | PASS (HOST); Android process-death row NEEDS ATTENTION | `route_restoration_test.dart`: the planner (`/session/current`) comes back on the plan it showed; the result form (`/session/<id>/results`, the representative form) comes back on its entry; a restored result form whose entry was deleted meanwhile shows Tonight with the message |
| CHK-F22.A2 | PASS (HOST) | A restored `/session/<id>` with the planner since moved to another plan keeps that plan (not adopted again) and leaves the entry Saved; a restored result form writes nothing until Save (no event, status Saved after leaving); a restored site editor (its site not restorable) returns to the Sites list, with no site added or activated |
| CHK-F22.A3 | PASS (TEST) | Kill: L4b (2026-10-18). Upgrade: since F03 the "v24 → v25: every result field and event is kept" test opens the v24 file with the current `AppDatabase` (schema 26), i.e. v24 → v25 → v26, and still reads the not-done reason, the `asPlanned` kind, the `reported` event and the replayed count; "v25 → v26: … plans with their snapshots, blocks, results and events kept" covers a named plan (`Cygnus wall`) with a `partly` result |

**Mutation checks** (each reverted; failures in `route_restoration_test.dart`): no
`restorationScopeId` on the app (5); none on the router (1); a restored planner opening its plan
again (1); no fallback for a deleted entry (1); a restored site editor opened without its site (1).

### Commands

- `flutter test --no-pub test/lifecycle/route_restoration_test.dart` → `+5`
- the affected areas (sites, library, metadata, equipment, navigation, lifecycle, home,
  execution, logbook) → `+236`
- `flutter test --no-pub test` → `+2238 ~2: All tests passed!`; host E2E `core_loop` `+2`, `perf_scenarios` `+1`
