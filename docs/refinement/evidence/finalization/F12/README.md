# F12 — Effective assumptions and actionable fit limits (evidence)

Run: full final-plan group (owner launch 2026-10-18), second cloud session, 2026-10-19.
Environment: Linux container, Flutter 3.47.4 / Dart 3.13.3 (the CI pin). Evidence layer: HOST
tests (unit, widget and the real `AppRouter`). Owner visual acceptance is F25.

## What changed

- `capture_assumptions_panel.dart`:
  - `rows(p, budget)`: every value as the calculation uses it (`QuantityText.number`, no rounding);
  - an included overhead with its count in this plan's budget (`CaptureBudget.countOf`), or why it
    is not counted;
  - the PD-10 focus reminder (`focusReminder`, words only) and the global-scope line;
  - "Change in Settings" (was "Change in Planning Settings") pushes `AppRouter.planSettings`.
- `app_router.dart`: `/plan/settings` above the tabs, building `SettingsScreen(overPlan: true)`.
- `settings_screen.dart`:
  - `overPlan` mode: titled "Planning settings", with `scopeNotice`, the planning groups only;
  - groups, per AM-01: Imaging window (minimum altitude, darkness), then Fit and capture time
    (margin, time between frames), then Advanced. Advanced is a collapsed `settings.advanced` with
    the Moon and cloud gates and the five optional times, and the summary
    `advancedSummary` ("Gates: n of 2 on · optional times: m of 5 included");
  - Guidance (NPF, dew) next; Display, Privacy, Data and About only on the tab.
- `capture_analysis_viewmodel.dart`: `framesThatFit(index)` and `spareFrames(index)`, the
  per-block `FitAnalyzer.maxFramesForBlock` cached per generation; "Fill" reads the same cache.
- `block_text.dart` and `capture_plan_widget.dart`: every light block's line, with "(other
  blocks as planned)" when other blocks share the window (TD-074 part 1).
- Tests:
  - new: `test/presentation/widgets/capture_assumptions_test.dart` (4), plus the "F12 A2" test in
    `capture_outputs_test.dart` and the R3 navigation test in `app_shell_navigation_test.dart`;
  - updated: `settings_screen_test.dart`, `settings_rebuilt_test.dart` (open Advanced; its
    heading), `accessibility_test.dart` (Advanced opened; the over-plan screen audited);
    `capture_outputs_test.dart` (every block's line equals the service's output).

## Criterion results

| Criterion | Result | Evidence |
| --- | --- | --- |
| CHK-F12.A1 | PASS (TEST) | `capture_assumptions_test.dart` A1. A 2.5 s time between frames reads "2.5 s", which is `CaptureOverheads.perFrameMs` 2500; the old rounding to "3 s" fails it (mutation-checked). Dither and refocus give their counts from `CaptureBudget.countOf`. One filter change gives "30 s · once in this plan". A flip that is on but not counted says so. Setup reads "30 min before the first window" and the margin "15 %". With the overheads off, each reads "Not included", and an included dither the plan never reaches says "not reached by this plan" |
| CHK-F12.A2 | PASS (TEST) | `capture_outputs_test.dart`: each block's line equals `BlockText.whatFits` built from `FitAnalyzer.maxFramesForBlock` called directly, and `framesThatFit` equals it. "F12 A2" shows two light filters each with "+N frames still fit tonight (other blocks as planned)"; a dark gets no count (null) and no line. A plan that does not fit keeps "N frames do not fit tonight · up to M × 300 s fit (other blocks as planned)". When the fit cannot measure the plan, no block gets a fit line ("nothing is said while the fit cannot measure the plan"). A missing site or target is named once, by the plan status (`FitState.needsInput`, `StatusBlock`), and the budget, gain and storage stay shown |
| CHK-F12.A3 | PASS (TEST) | `capture_assumptions_test.dart` A3: the reminder is text inside the panel, with no Slider, TextField, Switch or dropdown. An AF or MF record (with a Kelvin white balance) on every light leaves the budget sequence, the total time, the light groups, the fit (state, placed time, reason) and `maxFramesForBlock` identical; nothing operates a camera |
| CHK-F12.A4 | PASS (TEST); U at F25 | `app_shell_navigation_test.dart` "Change in Settings opens over the plan". From the planner, with a block and the Assumptions section open, the link opens "Planning settings" with no navigation bar, the scope notice and the four planning groups, and none of Display, Privacy, Data or About. A margin change is applied, then Back returns to the same plan: blocks unchanged, the section still open, the panel showing the new 25 %. `context.go(settings)` fails it (mutation-checked). The route map includes `/plan/settings`. Settings groups: `settings_rebuilt_test.dart` (the headings in order, Advanced collapsed and opened) and `settings_screen_test.dart` (the Advanced summary, five "Not included" inside it). Accessibility: the Settings tab with Advanced open and the over-plan screen are audited in every theme at 100 % and 200 % text |

## Commands (working tree before the F12 commit)

- `flutter test --no-pub test` → `+2154 ~2: All tests passed!` (before the fourth A3 test was added; that file then passes `+4`)
- `integration_test/core_loop_test.dart -d flutter-tester` → `+2`; `perf_scenarios_test.dart` → `+1`
- `flutter analyze --no-pub` → `No issues found!`; format 0 changed; encoding passed

## Notes

TD-074 parts (2)–(4) remain FOLLOW-UP: a joint filter split, a calibration block's count and a
margin-aware maximum. Each needs a domain answer, and the owner has not asked for one.
