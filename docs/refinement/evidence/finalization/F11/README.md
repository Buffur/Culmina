# F11 — Relative improvement over integration time (evidence)

Run: full final-plan group (owner launch 2026-10-18), second cloud session, 2026-10-18.
Environment: Linux container, Flutter 3.47.4 / Dart 3.13.3 (the CI pin). Evidence layer: HOST
tests (unit and widget). No device is needed for these criteria; owner visual acceptance is F25.

## What changed

- `lib/domain/services/capture_budget_calculator.dart`: `LightGroup` gains `sensitivity`,
  `binning`, `comparable` and `integrationMs`. The groups follow ADR-021 C16:
  - the key is the normalized filter (C15), the exposure in ms, the recorded ISO or gain (kind and
    value) and the binning;
  - a block whose ISO or gain is not recorded as one or the other is its own group;
  - calibration frames never count.
- `lib/domain/services/stacking_gain_curve.dart`: the curve takes the group's exposure.
  `relativeToPlan` gives √(T / T_plan): 0 for no integration, null with no plan. `relativeAt`,
  `integrationAt` and `planIntegrationMs` are new. The (n, √n) points are unchanged.
- `capture_budget_summary.dart`, `stacking_gain_graph.dart`, `planner_sections.dart`:
  - one primary line per group, which names its settings;
  - a note when a block stands alone;
  - a clearer empty state;
  - the graphs in a new collapsed section, "Over integration time" (`planner.gainCurve`), labelled
    in integration time with the plan at 1.00x;
  - a text alternative giving the plan, half its time and the end;
  - the help text names the group's settings and the equal-frames idealization.
- `capture_analysis_viewmodel.dart`: the unused summed √N of all lights is removed, since it
  combined groups.
- Tests:
  - new: `test/domain/services/light_groups_test.dart` (7);
  - rewritten for the new contract: `stacking_gain_graph_test.dart`;
  - updated with the reasons in comments: `fit_analyzer_test.dart` (the group test records one
    gain), `planner_disclosure_test.dart` (the new section and summary), `capture_blocks_test.dart`
    (group lines are outputs, not block rows), `capture_plan_widget_test.dart` (the label).

## Criterion results

| Criterion | Result | Evidence |
| --- | --- | --- |
| CHK-F11.A1 | PASS (TEST) | `light_groups_test.dart` A1. **R-O2-1 / V12:** a plan of 120 × 60 s (2 h) gives 0.7071 at 1 h, 1.0000 at 2 h and 1.4142 at 4 h, within ±0.0001. The group's curve is 1 at the plan and √2 at its end, and every point equals √(T / T_plan). **R-O2-2:** √N is 10.954 at 120 frames and 15.492 at 240. The existing `stacking_gain_curve_test.dart` (CALC-42 points) passes unchanged |
| CHK-F11.A2 | PASS (TEST) | `light_groups_test.dart` A2: zero integration gives 0, and no plan gives no reference (null). No light frames gives no group; darks, flats and bias never count. The filter is compared trimmed and case-folded, with no aliases (`HA` joins `Ha`; `H-alpha` stays apart). A different gain value, ISO versus gain, binning or exposure each split the group. An unrecorded ISO or gain (none, or a legacy value of unknown kind) never joins another block, and its own √N stands. Mutation check: dropping the unknown rule or the sensitivity from the key fails the tests. Empty-state text: `capturePlan.noGain` |
| CHK-F11.A3 | PASS (TEST); U at F25 | `stacking_gain_graph_test.dart`. **Primary lines:** "Ha · 60 s · gain 100 × 120 — 11.0x", "Ha · 300 s · gain 100 × 12 — 3.5x", "No filter · 30 s · ISO or gain not recorded × 1 — 1.0x", with the "shown on its own" note. The heading stays "Relative stacking gain (√N vs one frame)", with the help one tap away; no "SNR". **Details:** no graph is built before the section opens. Once open, there is one graph per group, drawing the domain's points. "Your plan: 2 h (120 frames) · 1.00x" and "For comparison: 4 h (240 frames) · 1.41x" are shown. The text alternative reads "…1.00x at your plan, 2 h (120 frames); 0.71x at half that time; 1.41x at 4 h (240 frames), for comparison. Relative to your plan, not a signal-to-noise ratio." No overflow at 200 % text in the light, dark and field themes. **W:** the reference-plan scroll extent drops from 3884 px to 3708 px (`reference_plan_density_test.dart`) |

## Commands (working tree before the F11 commit)

- `flutter test --no-pub test` → see PROGRESS row
- `integration_test/core_loop_test.dart -d flutter-tester` → `+2`; `perf_scenarios_test.dart` → `+1`
- `flutter analyze --no-pub` → `No issues found!`; format 0 changed; encoding passed

## Dependencies

F03 (persisted gain and binning) and F06 (recorded settings) are in place. F12's assumptions panel
can link to the gain help.
