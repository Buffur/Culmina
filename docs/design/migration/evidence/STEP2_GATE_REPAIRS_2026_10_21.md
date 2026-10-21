# Step 2 — full-gate repairs after the hand-over (2026-10-21)

Resumed by Claude Code from `CONTINUATION_PROMPT_2026_10_20.md` §4–§5 on a
different Windows machine (Flutter **3.47.4** / Dart 3.13.3 at
`C:\tools\flutter-3.47.4`, the CI-pinned version). Branch
`claude/owner-brief-2026-10-20-d413ba`, fast-forwarded to `develop` at
`c224cf6` before any edit. Every failure listed at the hand-over was
re-run on this tree and classified below as a **real defect** (code fixed) or
a **pin of pre-migration presentation** that the approved Hybrid design
replaced (test updated to the Hybrid contract, with the reason in the test).
No guard test was deleted or loosened; no limit was raised.

## Analyzer (5 infos)

`curly_braces_in_flow_control_structures` in `hybrid_view_entrance.dart`,
`night_moon_screen.dart` and `hybrid_focus_highlight.dart` (three): braces
added. `flutter analyze --no-pub`: no issues.

## Guard tests (project invariants) — code fixed

| Guard | Offender | Fix |
| --- | --- | --- |
| `media_query_aspects_test` (S10.3) | `hybrid_app_bar.dart` rebuilt the title under `MediaQuery.of(context).copyWith(textScaler:)`, a dependency on every MediaQuery field (keyboard inset included) of every screen with an app bar | The title `Text` is rebuilt with an explicit `textScaler` (the user's unclamped scaler), which outranks AppBar's clamped MediaQuery without the broad dependency. All 25 callers pass a `Text` title |
| `quantity_text_usage_test` (F25 A2) | `plan_overrides_editor.dart` `'Global: …%'`; `night_browser_sections.dart` `'Sun below ${limit.toStringAsFixed(0)}°'` (hyphen-minus for −18°) | `QuantityText.percent` / `QuantityText.degrees` (typographic minus) |
| `secondary_consistency_test` | `night_moon_screen.dart` tab indicator `EdgeInsets.symmetric(horizontal: 12)` | `AppSpacing.sm + AppSpacing.xs` |
| `viewmodel_rules_test` (≤ 300 physical / ≈ 250 code lines) | `capture_analysis` 308, `night_conditions` 301, `session_plan` 305, `site` 306 | Cohesive pieces moved out, none of the limit raised: the fit's no-window reason to `fit_no_window_reason.dart`; the scoped browser's wait for the plan's shared forecast into the existing `night_forecast_loading.dart` part; block restore into the existing `session_plan_block_undo.dart` part; the site's stored-record Undo into a new `site_deletion_undo.dart` part. Now 291 / 296 / 298 / 288 |

## Real defect found by the accessibility sweep — code fixed

`accessibility_test` ("every screen meets the guidelines", all six theme ×
text variants) failed on **"A NightConditionsViewModel was used after being
disposed"** while the sweep made a new plan after visiting Night/Moon.
Cause: Codex moved `_onInputsChanged` into the `_ForecastLoading` extension.
Each tear-off of an extension method is a new closure, so the scoped
browser instance's `removeListener(_onInputsChanged)` in `dispose` never
matched what the constructor added: every visit to Night/Moon/Weather left a
listener on the site, plan and settings ViewModels (a leak), and a later plan
change notified the disposed instance. Fix: one stored listener object
(`_inputsListener`) used for every add and remove. Regression test
`test/presentation/viewmodels/night_conditions_scoped_dispose_test.dart`:
**fails on the unfixed source, passes with the fix** (both runs on this
tree). Other `addListener` sites in `lib/` were checked: all pass class
methods, which tear off equal.

## Pins of pre-migration presentation — tests updated to the Hybrid contract

| Test | What it pinned | Hybrid contract (source) | Science unchanged? |
| --- | --- | --- | --- |
| `capture_outputs_test` "Time needed · Total time equal the calculator" | `3 h 19 min` (minute rounding) | Capture budgets are written to the second (`QuantityText.budgetDuration`); the approved web shows "1 h 48 min 20 s" (`matched/browser-capture-manifest.json`) | Yes: `integrationMs`, `windowLoadMs`, `sessionBudgetMs` assertions unchanged; only the string is `3 h 18 min 40 s` (11 920 s) |
| `planner_structure_test` (three themes + "status says what FitAnalyzer and the budget say") | `QuantityText.duration` for the status figures | Same, `QuantityText.budgetDuration` | Yes: the figures still come from `fitAnalysis` / `captureBudget` |
| `tonight_home_screen_test` "a huge plan doesn't fit" | Same | Same | Yes |
| `stage11_host_fixes_test` S11H-02 and F18 A1 | "Altitude now" and the current-sky section in the Target row's always-visible data | Hybrid Plan keeps a compact target row; its measurements are in the remembered **Target details** disclosure (`PlannerSummaryCard`). Tests open it first; the typographic-minus and labelled-detail assertions are unchanged | n/a |
| `planner_disclosure_test` "collapsed, each section states a fact" | `section.planner.rigDetails` directly on the rig row | Specifications sit inside the **Rig details** disclosure; the test opens it, then checks every section collapsed with its fact | n/a |
| `settings_screen_test` "all workspace roots expose the same field-mode action" (new in the migration) | Harness had no session repository, so the Logbook root could not build | Harness gets `DriftSessionRepository` for this test only | n/a |
| `integration_test/perf_scenarios_test.dart` (host E2E) | Closing a modal filter panel by tapping its barrier | Hybrid Logbook filters are an inline panel (visible search, inline filters, count — audit row "Logbook light 100%"): closed with its **Done** button; the entry is scrolled into view before the tap. Timed steps unchanged | n/a |

## Pre-existing environment failure — cleanup made Windows-tolerant

`location_picker_tiles_failing_test` failed only in `tearDown`
(`PathAccessException`, errno 32: flutter_map's process-wide tile cache keeps
its file open on Windows). **It fails identically on the baseline `8048cfa`**
(run in a temporary detached worktree on this machine), so it is not a
migration regression. The temporary folder deletion now tolerates the lock;
no assertion changed.

## Verification

- Targeted reruns: every file above passes (logs in this session; the full
  gate supersedes them, V2).
- Full gate: `full-gate-2026-10-21.log` in this directory (result recorded in
  the ledger).
