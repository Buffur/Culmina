# F01 — Reject unsafe restores and recover interrupted activation (evidence)

Run: full final-plan group (owner launch 2026-10-18, cloud session). Environment: Linux
container, Flutter 3.47.4 / Dart 3.13.3 (official Linux archive, the CI pin), system SQLite
3.45.1. No Android SDK, emulator or phone in this environment (see PROGRESS attention register).

## Changed files

- `lib/data/backup/restore_candidate.dart` (new): `checkRestoreCandidate` — production
  connection (`openDatabaseConnection`), version refusal, `PRAGMA integrity_check`,
  `PRAGMA foreign_key_check`, every expected table/column, every row through the generated row
  classes, repository reads.
- `lib/data/backup/backup_staging.dart`: activation check, journal with a settings snapshot,
  roll-forward after process death, roll-back after an I/O failure, one newest safety copy,
  durable outcome.
- `lib/data/backup/backup_preferences.dart`: `snapshot`/`putBack` of every key a restore may
  change (carried keys and plan ids).
- `lib/data/backup/file_backup_service.dart`: pick-time full check on an isolated temporary
  copy; `restoreAndRestart`; outcome read/clear.
- `lib/domain/services/backup_service.dart`: `BackupProblem.unusable/notApplied`,
  `RestoreOutcome`, the D7 contract (no staged/pending API).
- `lib/presentation/viewmodels/backup_viewmodel.dart`,
  `lib/presentation/screens/settings/backup_section.dart`: confirmation (version, singular/
  plural, no Undo/safety-copy promise, Back up first, Restore and restart), refusal wording,
  `RestoreOutcomeNotice`, `RestoringBackupApp`.
- `lib/main.dart`: `_restartForRestore` (non-editable screen → close → `_start`), outcome
  notice in the app builder.

## Criterion results

| Criterion | Result | Evidence |
| --- | --- | --- |
| CHK-F01.A1 | PASS (TEST) | `restore_activation_test.dart` group A1: truncated, schema-less and column-missing real SQLite inside valid ZIPs refused at pick (header check alone accepts them) and on activation; newer DB refused both ways; live bytes and settings unchanged; check copy deleted |
| CHK-F01.A2 | PASS (TEST) | populated generated v24 database → pick → restore → production open at v25: integrity/FK/sites/results (not-done reason, partly)/legacy entry/settings |
| CHK-F01.A3 | PASS (TEST) | process death at `journal`, `moveLive`, `moveSide`, `swap`, `preferences`, `commit` → next start completes to checked new DB + its settings + no old WAL; I/O failure at each step and a half-written settings write → old DB, old WAL and exact old settings |
| CHK-F01.A4 | IMPLEMENTED; host PASS, device row carried to G2 (REL-10) | widget tests: no Undo/safety-copy promise, Back up first → same confirmation only after success, failure/Cancel never restore, Restore and restart applies at once with no pending state; data tests: one newest safety copy, refusal prunes nothing, interrupted pending copy kept. The literal phone path (Recents during activation) is not host-testable |
| CHK-F01.A5 | IMPLEMENTED; host PASS, device row carried to G2 | outcome recorded once and cleared; applied/refused/completed-after-interruption texts (refused says unchanged; completed never does); `restore_outcome_notice_test.dart` |

U (renders at 412 px, 200%, themes) for the changed confirmation and restoring screen and
owner visual acceptance are collected in F25's sweep; not claimed here.

## Commands (all on the working tree before the F01 commit)

- `flutter test --no-pub test/data/backup test/presentation/screens/settings
  test/data/repositories/live_runs_survive_test.dart test/data/export/file_names_test.dart
  test/data/database test/widget_test.dart test/lifecycle` → `+283: All tests passed!`
- Source-rule tests (`app_messages_test`, `retired_terms_test`,
  `presentation_style_rules_test`, `media_query_aspects_test`, `viewmodel_rules_test`,
  `clock_test`, `no_empty_catch_test`) → `+23: All tests passed!`
- `flutter analyze --no-pub` → `No issues found!`
- `dart format --set-exit-if-changed` on the 12 changed Dart files → 0 changed
- `dart run tool/check_encoding.dart` → `Encoding check passed`
