# F17 — Home leads with night facts (evidence)

Run: full final-plan group (owner launch 2026-10-18), second cloud session, 2026-10-19.
Environment: Linux container, Flutter 3.47.4 / Dart 3.13.3 (the CI pin). Evidence layer: HOST
tests through the real app, router and database.

## What changed

- `tonight_home_screen.dart`:
  - **Header:** the title and the field-mode toggle share one wrapping header, replacing the app
    bar.
  - **Order:** title, context (site ▾ · night ▾ · zone), the night card, the result-due prompt,
    Your plan, then the secondary candidate action.
  - **Night card:** the dark interval at the limit, or "none tonight"/"none on …"; the phase, lit
    fraction and moon-free dark time (N4/N5); the cloud over the dark span (N6), with its
    coverage, the no-dark state and the forecast's age.
  - **Removed:** Home's New plan action, and the Sunset-to-sunrise line (it is on Night & Moon).
- `plan_night_phrase.dart` (new; shared with F18 A6): "tonight" only for the current night,
  else "on Fri, Dec 18". It also gives the title ("Tonight" / "Night of …", AM03-T = B), the
  candidate action and the candidates screen's title.
- `tonight_candidates_screen.dart`: its title names the plan's night.
- Tests:
  - new: `test/presentation/screens/tonight/home_night_card_test.dart` (2);
  - updated in `tonight_home_screen_test.dart` for the new contract: the order, the dark interval
    rather than sunset to sunrise, the Moon row as phase plus moon-free time, and taller views for
    taps below the night card;
  - new tests there: the New plan action removed and Open planner resumes the same plan; the
    plan-night phrase.
  - `unsaved_plan_prompt_test.dart`: the "Tonight's New" caller of the Save · Discard · Cancel matrix
    is removed with the button (A2). The planner's "New plan" caller keeps every answer, and a new
    test asserts Tonight has none and the planner's menu has it.

## Criterion results

| Criterion | Result | Evidence |
| --- | --- | --- |
| CHK-F17.A1 | PASS (TEST); U at F25 | **Order and header:** `tonight_home_screen_test.dart` checks title, context, night, Moon, weather, plan, candidates in that order; the field-mode toggle sits in the title's header. **Night card:** `home_night_card_test.dart` shows "Dark (Sun below −18°): …", the phase and lit fraction, and the moon-free line. A partial forecast gives "Cloud in the dark 30 %", "Forecast for N of M dark hours…" and "Updated just now", and the weather row opens its detail. Tromsø in June gives "none tonight", "No dark time tonight: no hours to forecast" and "No dark time this night, so no moon-free time.". Candidates stay a secondary action |
| CHK-F17.A2 | PASS (TEST) | "Home has no New plan; Open planner resumes the same plan": there is no `tonight.newSession` and no "New plan" on Home; Open planner opens the same session id, with the planner's own menu (`planner.menu`; its guarded New plan is tested by the planner's tests) |
| CHK-F17.A3 | PASS (TEST) | The night picker on Home edits the plan's night: the existing "the night picker changes the plan's night" test persists it to the stored session. The night card and Your plan read the same plan and site ViewModels. Viewing other nights is F14/F15's labelled browsing, which adopts only through "Plan this night" (F14 A6, F15 A2) |
| CHK-F17.A4 | PASS (TEST); U at F25 | **States:** empty (`tonight.noSite`), loading (`StartupMark`), offline ("no forecast: says so, never a number"), partial and no-dark (`home_night_card_test.dart`), and saved (`tonight.planState`). The accessibility sweep covers Tonight in every theme at 100 % and 200 % text |
| CHK-F17.A5 | PASS (TEST) | "another plan night is named; the tab stays Tonight": with the plan three nights ahead, the title reads "Night of …", the action "What can I image on …?" and the candidates screen "Candidates for …", while the navigation bar still says "Tonight". On the current night the words are "Tonight" and "What can I image tonight?" |

## Commands (working tree before the F17 commit)

- `flutter test --no-pub test` → `+2181 ~2 -6`. The six failures were the "Tonight's New" callers of the removed button. After that test was updated, `unsaved_plan_prompt_test.dart` gave `+28: All tests passed!`; no other input changed.
- `integration_test/core_loop_test.dart -d flutter-tester` → `+2`; `perf_scenarios_test.dart` → `+1`
- `flutter analyze --no-pub` → `No issues found!`; format 0 changed; encoding passed
