# F16 — First-run Welcome before the first frame (evidence)

Run: full final-plan group (owner launch 2026-10-18), second cloud session, 2026-10-19.
Environment: Linux container, Flutter 3.47.4 / Dart 3.13.3 (the CI pin). Evidence layer: HOST
tests through the real app and router (no device).

## What changed

- `tonight_viewmodel.dart`:
  - `load({hasStoredSite})` reads the flag before the first frame;
  - `startsAtWelcome` replaces the post-frame `firstRunDue`/`markOffered` offer.
- `app_router.dart`: `firstLocation(tonight)` returns `/welcome` or `/tonight`.
- `main.dart`: reads the flag and whether an active site or a transient position is stored, then
  routes to `firstLocation` before `runApp`.
- `tonight_home_screen.dart`: the post-frame push of `/welcome` is removed. It drew Tonight first,
  which was the flash.
- `welcome_screen.dart`: one page.
  - The purpose and the permission rationale.
  - "Your observing site (optional)": Use current position or Choose or add a site.
  - "Your rig (optional)": F05's class-first panel, "Enter by hand" opening the rig editor with its
    required-input reasons, "From a photo" opening the import. The rig saved there becomes the
    plan's rig (D8) and the step shows it. "Or choose a saved rig" is offered too.
  - Start planning. Back closes the page as Start planning does.
  - No target step and no Skip.
- Tests updated for the new contract: `tonight_home_screen_test.dart` (first-run group rewritten),
  `lifecycle_matrix_test.dart` L1 and `integration_test/core_loop_test.dart` (route chosen as
  `main` does; Start planning instead of Skip).

## Criterion results

| Criterion | Result | Evidence |
| --- | --- | --- |
| CHK-F16.A1 | PASS (TEST) | `tonight_home_screen_test.dart` "a first run starts on Welcome: Tonight is never built": on the first pump the setup is shown, with neither Tonight's prompt nor the navigation bar. Mutation-checked: always routing to Tonight fails the first-run group. A stored site, or the flag already done, starts on Tonight ("not offered when a site is already set", "not offered again once done") |
| CHK-F16.A2 | PASS (TEST) | **Page:** "one page with two optional steps": the permission rationale is shown; the site and rig steps are there; the target step, `welcome.skip` and any "Skip" are not. Start planning closes the page for good and Tonight's site prompt follows. Back does the same. **Location:** GPS stays on "Use current position" only, and a denial changes nothing with planning reachable (`lifecycle_matrix_test.dart` L1, with permission denied and then a typed site) |
| CHK-F16.A3 | PASS (TEST) | "class → by hand". DSLR then Enter by hand opens the editor with the reasons ("Needed for the field of view …"). Cancel saves and chooses nothing. A filled rig saved there becomes the plan's rig, of the class chosen first, and the rig step shows its name. The photo path is F05's import (`rig_created_for_plan_test.dart`, `fits_import_test.dart`); "Or choose a saved rig" opens the normal picker and returns |
| CHK-F16.A4 | PASS (TEST); U at F25 | First run: `integration_test/core_loop_test.dart` starts on Welcome, Start planning, site, plan, save, report, restart, export. Returning run: the restart in the same test, and lifecycle L1–L8. The accessibility sweep covers `/welcome` in every theme at 100 % and 200 % text |

## Commands (working tree before the F16 commit)

- `flutter test --no-pub test` → `+2184 ~2: All tests passed`
- `integration_test/core_loop_test.dart -d flutter-tester` → `+2`; `perf_scenarios_test.dart` → `+1`
- `flutter analyze --no-pub` → `No issues found!`; format clean on the F16 files; encoding passed
