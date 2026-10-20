# Android planning prototype — completion evidence

Validated 2026-10-20. Scope: the local browser prototype only. [Source and decision map](../../../docs/design/PLANNING_SCREENS_2026_10_19.md). The earlier Plan/Android capture sets remain historical; this record covers the cumulative planning-screen implementation.

## Delivered behavior

- Plan: one target, compact context rows, capture editor, camera-class fields, four estimates before Details, editable assumptions, proposed calibration, reorder/remove/Undo, stable Save, scoped Apply and guarded navigation. Empty capture plans can be saved when site, target and rig are present. A missing site disables night selection until a zone can be resolved.
- Night and Moon: one viewed context, 24 UTC-hour SessionNight, sky/Moon rails, five-minute browsing, meaningful countdown/remaining text, date/UTC offsets, Sun/twilight events, Moon phase and interval classifications. Calendar browsing never retimes a plan; at 200% text the month grid becomes a navigable seven-day sentence list.
- Weather: cloud bars, disconnected temperature/dew lines, wind/gust and precipitation strips, hourly selection, layers/humidity/visibility, source table, real row coverage, gaps and horizon. Snapshot age and forecast lead are separate. All values are explicit examples.
- Home: shared plan/night state, plan-first default, flat Your plan, compact interactive dark/Moon rail, full-screen links. Four navigation destinations remain on the phone at 200% text.

## Acceptance results

| ID | Result and current evidence |
| --- | --- |
| P01 | PASS. Roadmap/audit/visual-source map retained in the linked design record. Prior video, Notion/Google and Apple/Fluent/Spectrum references supplement each other. Hybrid Notion + Journal styling and Android phone anatomy retained. |
| P02 | PASS. Main DOM has one `M31` occurrence. Estimate heading precedes the first Details disclosure (measured tops 1733.60 vs 2639.40 at 200%). Actual missing-site/target/rig remedies exercised; empty capture Save succeeds, including when forecast is unknown. |
| P03 | PASS. Blank count, fractional exposure, Kelvin/MF/custom filter, DSLR ISO/WB and Astro gain/binning exercised. Unknown camera offers rig remedy. Reload retains explicit blank invalid count and the other editor fields. Close/Escape offers Keep editing/Discard; Apply changes draft separately from Save. |
| P04 | PASS. Actual add/edit/reorder/remove/Undo, newer edit Undo, calibration proposal and assumptions flows recorded. Calibration changes total/storage without inventing light integration. Overhead/file-size changes update estimates. Huge finite numeric budgets are rejected before Date/schedule overflow. |
| P05 | PASS. Cancel retains source/draft; failed save retains error and permits retry. Clean saved copy, dirty Save-and-copy, dirty Discard-and-copy, unsaved change-in-place and save/reload exercised. Original record preservation/archiving also verified by model tests with fake storage. |
| P06 | PASS. Keyboard Home/ArrowRight/End, Now/night-start reset and DST exercised. DST rail endpoints are 24 Oct 13:00 GMT+3 → 25 Oct 12:00 GMT+2: exactly 24 UTC hours. Last step is 11:55, not the exclusive end. Polar-dark last step remains dark with five minutes left. |
| P07 | PASS. All-Moon-up, below, split and middle-only cases rendered. Clipped summary says “up at window start” / “still up at window end”. Month selection, next week across November, return-to-plan and 200% seven-day rows exercised. |
| P08 | PASS. Ready, missing-variable, gaps, stale, offline, unavailable, loading, error, retry, no-dark, last partial night and horizon inspected. Cloud Unknown retains known temperature. At 05:00 after 04:45 dawn, instant fields say Outside dark span/— while preceding gust/precipitation retain eligible values. Missing trailing slots remain on the time axis. |
| P09 | PASS. Home rail Home/ArrowRight displays 19 Oct 13:05 and a darkness countdown; before/after plan text is identical. Shared Night and Home use the same fixture/context helpers. |
| P10 | PASS. Home/Plan reach full conditions; viewed vs plan night is explicit. Returning to Plan retains saved/draft meaning. Expanded budget and scroll position restored exactly: 1664.6666 px before and after. |
| P11 | PASS within browser scope. 48 cases: four screens × three themes × two text sizes × two actual viewports. 12 more cases cover Hybrid Home. No horizontal page/content overflow, screen width ≤412 px, stable lower action, and no measured product targets below 48 px. Home retains four navigation columns and no plan shadow. Short 412×520 editor at 200% has one reachable Apply and no horizontal overflow; this is not a real IME test. |
| P12 | PASS. Five actual Claude CLI runs returned successful JSON/exit results: functional research, Plan review, model tests, Plan implementation and independent conditions review. Main-session integration, source reconciliation and UI verification followed. |

## Verification artifacts

- [DOM/layout measurements and actual interaction observations](planning-screens/browser-evidence.json): `layout` and `homeLayout` are the final matrix. Both requested **and actual** sizes are recorded: 1280×1040 and 412×915. An earlier viewport attempt affected a different tab; those duplicate/incorrect-size attempts are excluded from this final matrix.
- `node --test design/home-lab/scripts/check_night.mjs design/home-lab/scripts/check_plan.mjs`: **60 passed, 0 failed** (46 Night/shared-state tests; 14 Plan tests).
- JavaScript syntax checks, source inventory/self-test (21 files, 13 proposal roles, 35 palette roles), UTF-8/link/whitespace checks: see [verification output](planning-screens/verification.txt).
- Screenshots: [Plan](planning-screens/plan.png), [estimates](planning-screens/plan-estimate.png), [Night](planning-screens/night.png), [Moon](planning-screens/moon.png), [calendar](planning-screens/moon-calendar.png), [seven-day list at 200%](planning-screens/moon-week-200.png), [weather chart](planning-screens/weather-hourly.png), [exact values](planning-screens/weather-values.png), [Home slider](planning-screens/home-slider.png), [short editor at 200%](planning-screens/editor-short-200.png).

The Plan tab's retained console history includes the pre-fix `applyBlock`/`trim` exception at 2026-10-19 21:22:31 UTC. It came from the restored-editor overwrite described above; the subsequent recorded fixed-reload case retains exposure/type/ISO/WB and the explicit blank count, followed by successful Apply/Undo/Save flows. It is not represented as a clean historical console. Final Home and conditions diagnostics returned no errors.

## CLI review dispositions

Original requests/results remain in [ai/](ai/). They are evidence of work, not approval or independent proof that UI behavior passed.

Accepted and verified: five-minute half-open cursor endpoint; DST offsets; clipped rise/set wording; instant-based weather row coverage; preceding-hour overlap eligibility; missing visibility/cloud preservation; trailing weather slots; no-dark Home wording; calendar-relative lead; month-crossing labels; direct URL must not mutate saved context; editor raw-state restoration; numeric overflow limits.

Reconciled or rejected against source:

- A 25-hour civil-noon window conflicts with `SessionNight`/`SessionNightResolver`, which require fixed 24 UTC hours. Tests and fixtures follow project source.
- Overlap-weighted weather coverage conflicts with `night_weather_summarizer.dart`, which counts instantaneous hourly samples. The summaries/tests follow that contract; preceding gust/precipitation has a separate overlap rule.
- Freezing “Now” at the fixture timestamp would mislabel the actual current time. Now uses the actual clock and snaps to the same five-minute grid as the thumb. Historical/future nights offer Night start; retrieval age also follows the actual clock.
- An extra disabled Save inside the scoped editor weakened Apply/Save separation. The editor now has one Apply; main Plan owns Save.

## Limits and preserved scope

No production Dart or native functionality was changed for this task. No Flutter analyzer/tests/build, TalkBack, predictive Back, real keyboard/insets, emulator, physical device, live astronomy/weather/provider/cache or release qualification is claimed. The dated audit's production defects remain in its own queue. This implementation uses only the lab's browser storage and explicit examples; it does not touch the application database or calibration library.
