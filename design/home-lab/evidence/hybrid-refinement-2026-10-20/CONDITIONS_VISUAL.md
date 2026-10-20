# Hybrid conditions and time-browser refinement

2026-10-20. Scope: `conditions.js`, `night-ui.js`, `conditions.css`, `night.css`; original Hybrid only. Plain HTML/CSS/JavaScript browser prototype. Parent integrates the fifth `timeline(..., hybrid)` argument for Tonight and revisions the assets.

## Implemented contracts

| Requirement | Change / acceptance | Evidence |
|---|---|---|
| R3 | Visible `Return to night start` / `Return to now` control, 48 px minimum target, separate from preview time; visible drag/arrow-key hint and displayed endpoint labels. Arrow keys retain five-minute steps and reset restores the model's current baseline. | Keyboard/reset assertions for Night and Moon in all three themes at 100% and 200%; parent checks Tonight caller. |
| R4 | Partial cloud headline explicitly says `in known dark hours`; adjacent qualification names 5 of 7 cloud samples. Missing values remain null and hatched; gap cells show a dash with `Unknown` in the accessible label. | Partial-weather headline, coverage and two gap assertions; the existing model gives 5/7. |
| R5 | Unavailable forecast status occurs once in the selected night's answer. Other coming-night cards still name their individual unavailable states. Error-specific alert/retry remains. | Unknown-state assertion scoped to `.weather-answer`. |
| V1, V8 | One horizontal hourly grid aligns cloud, temperature/dew and humidity. Humidity uses its own explicitly labelled 0–100% panel with dotted line; temperature is solid and dew point dashed on a °C scale. Removed redundant wind/gust/rain strips from Hybrid's primary plot; exact values remain in selected-hour facts and Forecast details. Data gaps split lines; isolated known samples render as points. | Humidity segmentation assertions, selected-hour model data unchanged; `humidity-light.png`, `humidity-dark.png`, `humidity-field.png`. |
| V2 | Lightened sky-state palette for Dusk/Slate/Ink, each scoped to Hybrid and all three themes. Field remains red/black. Removed the legend swatch's `.key-dark::after` pseudo-element: this was an illustrative bracket beneath the word, **not** focus styling. Exact dark-time bracket remains on the rail. Keyboard focus outline remains separate. | Pseudo-element assertion for Hybrid and legacy preservation for Paper. Screenshots show the exact-time rail bracket remains. |
| V9 | Time + next-day marker are kept together; number/unit groups use nonbreaking spacing. Long dates and sentences retain natural wrapping. Month actions can wrap; facts remain label-over-value cells. | 360/412 px at 200% without horizontal page overflow; `conditions-night-200.png`, `conditions-moon-200.png`. |
| V10 | Shared 120 ms control selection feedback and brief detail disclosure feedback; no recurring or page-load choreography. Reduced motion disables transitions/animations. Parent's shared reduced-motion rule also applies. | Computed reduced-motion transition `0s`, animation `none`. |

Only `variant=blend` receives the new plot/labels/markup. The timeline's fifth argument defaults to `false`. Legacy palettes and the legacy hourly chart remain available to other variants. A Paper scenario verifies absence of the new hint and preservation of its legacy legend bracket.

## Executed verification

- `node --check design/home-lab/conditions.js` and `node --check design/home-lab/night-ui.js`: PASS.
- `node design/home-lab/scripts/check_night.mjs`: **46/46 PASS** (time windows, DST, cursor, Moon, forecast gaps, persistence/adoption model invariants).
- `node design/home-lab/scripts/check_quality.mjs`: **15/15 PASS** (weather digest eligibility, unknowns, day tags and sky-gradient boundaries among other existing checks).
- `node design/home-lab/evidence/hybrid-refinement-2026-10-20/conditions-check.cjs`: **31 checks PASS**, no page errors. Exact data in [conditions-check.json](conditions-check.json).
- `git diff --check -- design/home-lab/conditions.js design/home-lab/night-ui.js design/home-lab/conditions.css design/home-lab/night.css`: PASS. These files were already untracked in the shared checkout; model/browser results supply the substantive checks.

Browser runtime: pinned Playwright **1.64.1**, bundled Chromium 1248, fresh isolated context, no permissions and no owner storage touched. The script records the executable/toolchain paths. Current API guidance was fetched through Context7 `/microsoft/playwright` for isolated contexts, reduced motion, screenshots and keyboard actions, including [official emulation guidance](https://github.com/microsoft/playwright/blob/main/docs/src/emulation.md).

Coverage: Night, Moon and partial Weather × light/dark/field × 100%/200% at 412 px (18 combinations); all three views at 360/412 px and 200% (six checks); Weather unknown, missing-variable, error, no-dark and DST (five checks); reduced motion and Paper preservation (two checks). Screenshots capture each view in each theme at 100%, the hourly panels in each theme, and representative Night/Moon at 200%.

Initial test assumptions were corrected before the final run: a final isolated humidity value is a point, not a second polyline; repeated unavailable text in independent coming-night cards is legitimate, so the duplicate check targets the selected night's answer. Final JSON contains only the successful final run. No data/model change was needed for either assertion correction.

## Independent composition recommendations sent to parent

- Keep full-width Save/Open planner; use content-width secondary actions.
- Give Site/Target/Rig a consistent leading-icon rule, including selection rows.
- Improve supporting/data type roles selectively (14/16 px); do not increase already large display headings indiscriminately.
- Use whitespace between content groups; retain separators where they mark navigation or data boundaries.
- Root reduced-motion override should cover newly added controls as well as existing screens.

Skills used: repository Culmina tokens/spacing/components/rules and workflow; local Impeccable 4.7.0 context, clarify, animate and craft-floor. This is scoped Operate refinement from the supplied brief; missing PRODUCT.md is not a request to start a new product/visual-world interview. No tool installation/update or native changes were performed.

Limitations: browser interaction/layout proof only; no TalkBack, native Android, device performance, actual forecast or astronomy certification. Attached images (2)–(10) were not present in the accessible attachment directory; existing current captures and source were used, and the parent was notified.
