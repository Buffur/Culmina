# F22 — Restore the open route without corrupting saved or draft state (evidence, partial)

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
| CHK-F22.A1 | NOT STARTED | Needs F16–F19/F21 and an emulator process-death run (no Android SDK here) |
| CHK-F22.A2 | NOT STARTED | — |
| CHK-F22.A3 | PARTIAL: kill and v24 → v25 PASS (TEST); the v25 → v26 path waits for F03 (ADR-021, schema v26) | L4b and the v24 → v25 test above. Mutation: writing no not-done reason in `recordResult` fails L4b (`Expected: NotDoneReason.clouds, Actual: null`) |

## Commands

- `flutter test --no-pub test/lifecycle test/data test/core` → `+517 ~1: All tests passed!`
- `flutter test --no-pub test/lifecycle/lifecycle_matrix_test.dart` → `+8: All tests passed!`
- `flutter analyze --no-pub` → `No issues found!`; format and encoding pass.
