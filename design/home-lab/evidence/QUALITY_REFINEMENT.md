# Quality refinement — completion evidence, 2026-10-20

Historical milestone: the later owner request supersedes the expanded Home Weather and sky-palette presentation described here. See [current tabs/Weather evidence](TABS_PREVIEW.md); unchanged contracts and earlier captures remain historical evidence, not newly executed checks.

Scope: **Android browser prototype**. [Owner brief](ai/quality-owner-brief.md), [source/decision map and graph evaluation](../../../docs/design/QUALITY_REFINEMENT_2026_10_20.md), [colour guidance](../../../docs/design/QUALITY_COLOR_GUIDANCE_2026_10_20.md). Earlier planning captures remain historical for changed inputs. No production Dart, actual equipment data or application database was changed.

## Results against the brief

| Brief | Implemented and checked |
| --- | --- |
| 1 Colour | Neutral app surfaces retained. Sky, Moon and caution roles reuse existing palette values/derived steps in all three themes; colours have shape/text cues. The token skill links exact proposal guidance. |
| 2.1 Scale | Shared continuous sky ramp, exact dark bracket and solid Moon lanes appear on Home, Night and Moon. Five-minute time cursor still browses supplied intervals; colour does not claim measured brightness. |
| 2.2–2.3 Home | Night and its rail are grouped, then Moon and Weather. Weather includes sampled cloud trend, air, wind/gust, dew-margin samples and rain probability with coverage. Values come from eligible existing hourly data; no observing score. Twelve Home layout cases pass. |
| 3 Night/Moon | Shared fact grid fixes the competing flex widths. Structured From/Until intervals retain local dates/offsets; key labels/values have larger roles. Moon-free duration/range/classification stay together. |
| 4 Moon | Timeline and calendar lead. Optional Moon details is at the end and retains its open state on rerender. Large-text calendar uses seven-day sentence rows. |
| 5 Weather | Period answer, measurements, trust group and hourly detail are distinct. Missing cloud can coexist with known temperatures; unknown remains unknown, exact-hour/preceding-hour meanings remain separate. Ready, gaps, missing-variable, unavailable/loading/offline/no-dark states were inspected; model tests cover horizon and boundaries. |
| 6.1 Search | Real six-object catalogue subset, explicit sample size, names/designations/aliases and honest empty results. Query does not select or dirty a plan. Stable input node permits editing in the middle; Enter/Go does not silently apply the prior target. |
| 6.2 Rig | Camera-class SVG and only actual recorded properties. Astro metadata comes from the shipped equipment seed; estimated optics and missing values remain labelled. Switching to Astro retains and shows earlier WB/MF read-only. |
| 6.3/6.6 WB | Numeric Kelvin and applicable tint beside Mode; bounds/optional fields follow domain and editor. Custom is not Kelvin. Invalid input remains with its error, reload retains numeric fields, Apply updates the row, Undo and Save/reload work. |
| 6.4 Focus | AF/MF recording retained; numeric position/control is absent from the model, so no fabricated focus slider. This deliberate deviation is source-backed and stated in the editor. |
| 6.5 Filter | New Light/Flat filter is empty with a distinct placeholder; the existing recorded Broadband sample stays intact. |
| 6.7 Graphs | Three meaningful alternatives are selectable in the lab and comparable together: time curve (default), group bars, block steps. Units/reference/normalization/text equivalents remain explicit. Screenshots below show each alternative. |
| 6.8 Workflow | Dependencies and related block settings grouped; exactly one scoped Apply and main Save. Working checkpoint, guards and source-preserving copies retained. Phone height follows the remaining viewport when lab controls wrap; Save remains within the viewport. |

## Executed verification

- `node --test design/home-lab/scripts/check_night.mjs design/home-lab/scripts/check_plan.mjs design/home-lab/scripts/check_quality.mjs`: **72 passed**, [output](quality-review-2026-10-20/model-tests.txt).
- **48 final screen cases**: four screens × three themes × two text sizes × two actual viewports (1280×1040, 412×915). Plan includes all graph alternatives open; Moon includes its expanded details. No horizontal page/content overflow, phone width ≤412 px, no measured product target below 48 px, phone and Save within the viewport.
- **12 final Home cases**: three themes × two text sizes × two actual viewports. Four navigation destinations, plan-first order, no plan shadow or horizontal content overflow.
- [Current DOM/layout and interaction evidence](quality-review-2026-10-20/browser-evidence.json) records requested and actual dimensions. Final matrix entries have `currentAssets:true`, asset revision `20261020-quality2` and server `Cache-Control: no-store`.
- Focused browser interactions: alias/empty search; query-only close remains Saved; invalid Kelvin; WB/MF reload and Apply/Undo; Custom tint adjacency; empty filter; calibration WB absence; Save/reload; guarded adoption Cancel retains source night and edited frames; the four independent-review regressions below. Actual Android IME/TalkBack behavior is not claimed.
- [Syntax, inventory, links, UTF-8 and whitespace verification](quality-review-2026-10-20/verification.txt). No native build or tests claimed.

## CLI contributions and review disposition

Four actual CLI invocations belong to this refinement (separate from the previous planning task):

1. Sonnet completed Home/Night/Moon/Weather implementation: [findings](ai/quality-conditions-findings.md), request/result JSON retained alongside it.
2. Opus implemented part of Plan, then returned `is_error:true` for a session limit. Main-session integration completed target/WB/graph event wiring/styles, guarded old records, syntax and runtime checks. This run is not labelled successful completion.
3. A focused review attempt also returned the session-limit error; it supplied no completed review.
4. After the owner renewed limits, a fresh Opus read-only review completed: [original findings](ai/quality-integration-review-findings.md). It found no P1 or data-loss/science defect, one P2 and three P3 items. Main-session browser checks confirmed the following repairs:

| Finding | Repair / concrete evidence |
| --- | --- |
| P2-1 Search input rebuilt per key | Only result count/list update. Typing `9` then `8` before the last digit of `NGC 224` yields `NGC 22984`, preserving middle insertion. Input itself is not replaced. Native IME acceptance remains outside browser proof. |
| P3-1 Enter applies old target | Search Enter key and form-submit guards; heading remains Target and input remains present after Enter. Explicit Apply still applies a selected radio. |
| P3-2 Astro hides saved WB/MF | Kept values are appended read-only. Recorded row: `Gain unrecorded · Binning 1×1 · WB 5600 K · Focus MF (kept record)`. |
| P3-3 Moon details closes | Transient disclosure-open flag and toggle listener; `open` remains set after changing text to 200%. |

The original CLI source review is not represented as a browser/test run. Later parent fixes are documented here without rewriting that independent report.

## Cache correction and local server

The resumed browser initially kept old JavaScript through HTTP heuristic caching after the long interruption. Files on disk and direct HTTP served the new code, but the browser did not request updated modules; initial confirmation attempts therefore exercised old handlers. These observations remain identifiable in the interaction log. They are superseded by the `current asset` confirmations and final matrix, not counted as passes.

The lab now versions entrypoints and their relative module imports, and `scripts/serve_preview.py` sends `Cache-Control: no-store`. It binds `127.0.0.1:4173`, serves only this lab and runs independently in a hidden background process. To restart from the repository: `python design/home-lab/scripts/serve_preview.py --port 4173`. The test origin `localhost:4173` isolates test storage from the owner's `127.0.0.1:4173` working checkpoint. No application database was opened or reset.

## Captures

- [Home scale](quality-review-2026-10-20/home-after.png), [Home weather](quality-review-2026-10-20/home-weather-after.png).
- [Night](quality-review-2026-10-20/night-after.png), [Moon](quality-review-2026-10-20/moon-after.png), [structured Moon facts](quality-review-2026-10-20/moon-facts-after.png).
- [Weather answer](quality-review-2026-10-20/weather-after.png), [hourly view](quality-review-2026-10-20/weather-hourly-after.png).
- [Target search](quality-review-2026-10-20/target-search.png), [Custom WB](quality-review-2026-10-20/wb-custom.png), [Plan](quality-review-2026-10-20/plan-after.png).
- [A — time curve](quality-review-2026-10-20/gain-curve.png), [B — group bars](quality-review-2026-10-20/gain-bars.png), [C — block steps](quality-review-2026-10-20/gain-steps.png).

Browser examples remain fixtures. This evidence does not certify production ephemeris/weather, native gestures, real IME, TalkBack, Android-device performance or release gates. Existing roadmap/audit defects retain their own scope.
