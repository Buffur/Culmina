# F18 — Planner hierarchy, stable Save and the plan-night phrase (evidence)

Run: full final-plan group (owner launch 2026-10-18), second cloud session, 2026-10-19.
Environment: Linux container, Flutter 3.47.4 / Dart 3.13.3 (the CI pin). Evidence layer: HOST
tests through the real app, router and database.

## What changed

- `home_screen.dart` (the planner):
  - **AM-01:** the "Tonight for this target" section (chart, window list, no-site placeholder) is
    removed from the plan. `TonightOpportunityWidget` and `AltitudeChartWidget` stay in the code
    with their own tests.
  - **Target once:** the identity strip no longer repeats the target.
  - **Altitude:** "Altitude now (not on the plan's night)" on another night. "Max altitude in
    windows" uses the phrase.
  - **`_SaveBar`:** Save plan is always shown after loading. With a missing prerequisite it is
    disabled, with "To save: <reason>" and the direct action (Choose a target / Choose a rig /
    Set a site) wrapping at large text. The eligibility rule is unchanged (`PlanStatus.missingInput`:
    a site's night, a target, a rig).
- `current_session.dart` (TD-095): a successful Save clears `writeFailure` and tells the banner.
- `plan_night_phrase.dart`: `apply` rewords "tonight" / "tonight's window(s)/dark time" for
  another plan night, capitalized at a sentence start. Values are untouched.
- `plan_status.dart` and `capture_plan_widget.dart`: the status reason (`FitAnalyzer`/opportunity
  strings), fill/trim, "not even one frame" and every per-block what-fits line go through it.
- `night_moon_screen.dart`: `NightSummary` takes a `words` mapping, used by the planner, and by
  Night & Moon for a viewed night.
- Tests:
  - new: `test/presentation/screens/home/planner_f18_test.dart` (3),
    `test/presentation/shared/plan_night_phrase_test.dart` (2), and the TD-095 test in
    `current_session_failure_test.dart`;
  - updated for AM-01: `planner_structure_test.dart` (no chart; the opportunity and fit still
    computed) and `home_screen_test.dart` (no "Tonight for this target", no chart placeholder,
    Save shown and disabled without a site);
  - updated for the target-once rule: `plan_identity_actions_test.dart`;
  - `integration_test/core_loop_test.dart`: the plan no longer lists the windows; it checks the
    opportunity is still computed and the status shown;
  - moved: the chart's text alternative from `accessibility_test.dart` to
    `tonight_opportunity_widget_test.dart`; the sweep now asserts the plan has no chart.

## Criterion results

| Criterion | Result | Evidence |
| --- | --- | --- |
| CHK-F18.A1 | PASS (TEST); U at F25 | `planner_f18_test.dart` A1: no "Tonight for this target" and no chart, and the target's name once. `planner_structure_test.dart`: the order is status, context, target, rig, capture plan, conditions; the opportunity's windows, the fit's end and the usable time are still computed. The simple flow (frames → integration, total, storage, relative gain → Save) is F06–F12's capture plan, unchanged |
| CHK-F18.A2 | PASS (TEST) | `current_session_failure_test.dart` "a successful Save clears an earlier autosave failure": a failed autosave sets the failure, a failed Save keeps it, and a successful Save clears it and notifies |
| CHK-F18.A3 | PASS (TEST) | Cancel, back, browse and adopt follow D9 through the shared `planThisNight` and `askBeforeLeavingPlan`: F14 `forecast_nights_test.dart` A6, F15 `night_moon_browse_test.dart` A2/A3 (the saved snapshot is identical after a copy) and `unsaved_plan_prompt_test.dart` (every answer at New plan, Copy and Open) |
| CHK-F18.A4 | PASS (TEST); U at F25 | Fit and relative-gain explanations stay visible (F11/F12 tests). The accessibility sweep, in every theme at 100 % and 200 % text, covers the planner with the Save bar's wrapped reason. Reference-plan scroll extent: 3708 px before (F11), **3152 px** after (`reference_plan_density_test.dart`; −556 px, the target's-night section removed) |
| CHK-F18.A5 | PASS (TEST) | `planner_f18_test.dart` A5: without a target, Save plan is shown and disabled, with "To save: Choose a target to see tonight's windows." The direct action opens the target picker. With a target, Save is enabled, saves ("Plan saved") and stays. `home_screen_test.dart`: without a site, Save is shown and disabled, with the site reason and "Set a site" |
| CHK-F18.A6 | PASS (TEST) | `planner_f18_test.dart` A6: with the plan two nights ahead, no planner text contains "tonight", and the status shows `apply(fit.reason)`. On the current night the wording keeps "tonight". Mutation-checked: an identity `apply` fails it. `plan_night_phrase_test.dart`: every FitAnalyzer, status and what-fits form is reworded with its numbers kept, unchanged on the current night |

## Commands (working tree before the F18 commit)

- `flutter test --no-pub test` → `+2189 ~2: All tests passed`
- `integration_test/core_loop_test.dart -d flutter-tester` → `+2` (after the AM-01 update), `perf_scenarios_test.dart` → `+1`
- `flutter analyze --no-pub` → `No issues found!`; format 0 changed; encoding passed
- `reference_plan_density_test.dart` → `scrollExtent 3152`
