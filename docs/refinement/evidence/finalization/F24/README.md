# F24 — finite reproducibility and diagnostics checklist (evidence, partial)

Environment: 2026-10-18 cloud container, Flutter 3.47.4 (Linux archive). Rows done so far:

| Row | Result | Evidence |
| --- | --- | --- |
| A3 / TD-103 | IMPLEMENTED, TEST PASS | `app_database.dart` orphan cleanup logs through `AppLog.warning('database', …)`; `schema_migration_test.dart` M8 asserts both log lines; `no_empty_catch_test.dart` scans `lib` for `print`/`debugPrint` calls. Both checks fail with the old `print` (2 failures) and pass now |
| A4 / TD-038 | IMPLEMENTED, analysis clean | `unawaited_futures: true`; 31 findings (5 in `lib`, 26 in tests). Each `lib` case is an intentional fire-and-forget: `context.push` navigation and list reloads (`_loadEquipment`, `_loadTargets`) that already catch and show their own failure (TASK 15.1); wrapped in `unawaited`. Tests wrapped the same way, behaviour unchanged: 396 tests of the touched files and their screens' areas pass; `flutter analyze --no-pub` → No issues |
| A6 / UX32-03 | IMPLEMENTED, TEST PASS | Reproduced first: `target_search_race_test.dart` (6 cases, answers completed by hand in reverse order) fails 5 cases on the previous screen (late older answer replaced the newer list, older failure shown, older list under newer text, cleared query overwritten). `TargetSelectionScreen` now numbers requests and applies only the newest; while a newer search runs it shows "Searching for …" instead of the older list. With the fix all 14 tests in `test/presentation/screens/target` pass |
| A1 / TD-096, A2 / TD-102 map, A5 / TD-002·020·025 | NOT STARTED | — |
