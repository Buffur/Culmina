# Quality brief sections 1–5 — Home / Night / Moon / Weather findings

Date: 2026-10-20. Scope: Android browser prototype only; no production Dart. Plan files (`plan.*`) and `night-model.js` were not touched and their exports are unchanged. **Nothing here was executed**: the author had file tools only (no shell or browser), so no render, syntax check or test has run. The main agent must run them.

## Root cause: "Moon above horizon / 19 Oct, 16:30 GMT+3 → 20 Oct, 00:30 GMT+3" shifting

`.condition-facts>div` was `display:flex; justify-content:space-between` with `dt{max-width:57%}` and `dd{max-width:63%; text-align:right}`. The two caps sum to 120 %, so the label and the value fought for the row; the value was one long string (two full local dates with offsets joined by an arrow), so it wrapped at arbitrary spaces inside a right-aligned box. Where it fit on one line the label and value shared a baseline; where it wrapped the value became a ragged right-aligned block and the label stayed top-aligned. At 200 % text a separate rule switched the block to stacked, which is why the behaviour looked situational.

Fix at the component: facts are now label-over-value cells in a grid (`repeat(auto-fit, minmax(min(100%, 150px × text-scale), 1fr))`), left-aligned, and a Moon interval is structured data (`From` / `Until` rows in a two-column grid) instead of one arrow string. Wrapping can only happen inside a value, never against its label. Same component serves Night, Moon details, Sun & twilight and the selected-hour panel.

## Section map

| § | Change | Files |
| --- | --- | --- |
| 1 | Neutral by default; colour only for sky state, Moon lanes, weather caution; each with a non-colour cue. Documented in `docs/design/QUALITY_COLOR_GUIDANCE_2026_10_20.md`, token skill updated | `night.css`, doc, skill |
| 2.1 | Segmented sky bar replaced by one continuous gradient from the real `skySegments` boundaries (≤10 min blend either side). Explicit dark interval = solid bracket under the band. Legend lists only categories present, with the dark times. Note states colour is not measured brightness. Hatched/dashed Moon rail replaced with two solid lanes (thin bar = Moon above horizon, full bar = Moon-free dark). One `timeline()` renders Home, Night and Moon, so every use changes together. Slider thumb maps to the same percentage scale as the bars | `night-ui.js`, `night.css`, `styles.css` |
| 2.2 | Home order: Night row → band attached to it (no rule between) → Moon row → Weather. Band, readout and legend stay with the dark-time row they explain; Weather opens its own group. Label text raised 12→13 px | `app.js`, `styles.css` |
| 2.3 | Home Weather: cloud range in the dark; clearest / cloudiest hour; Air, Wind (+gust), Dew-point-near-air (n of m hours), Rain chance; coverage as "n of m dark hours" | `app.js`, `night-ui.js` (`weatherDigest`) |
| 3.1 | Root cause above | `night-ui.js`, `conditions.css` |
| 3.2 | Fact labels 12→15 px weight 600 for the two key facts; values 22 px; secondary 13–14 px | `conditions.css` |
| 3.3 | "Moon-free in the morning 00:30–04:45" is now a key fact: duration (large), `00:30 → 04:45 (+1)`, classification as caption; the same interval is the solid lower lane in the band | `night-ui.js` |
| 4 | Moon tab = timeline (phase · lit · classification as one line) + calendar; a closed "Moon details" disclosure at the end holds phase glyph, facts and the reading guide | `conditions.js`, `conditions.css` |
| 5 | Weather order: answer (cloud range) → dark period → clearest/cloudiest → Air/Dew/Wind+gust/Rain → dew sentence → trust group (status, coverage, age, lead, notices, retry) → Hour by hour → selected hour → seeing note → details/table/source → coming nights. Strips split into one number per cell (wind, gust, precipitation) with sticky captions above their rows; 11/10 px → 12 px; dew flag under the hour | `conditions.js`, `conditions.css` |

## Data-source constraints honoured

- SessionNight is 24 UTC hours; the band is 0–100 % of that window and the cursor stays on the 5-minute grid with exclusive end (unchanged `cursorFacts`, `max = total − 5 min`).
- `(+1)`/`(−1)` tags come from the local calendar date in the site zone versus `night.date` (new `dayTag`), not from assuming the next day.
- Moon windows are clipped to the night: "Up at window start" / "Still up at window end"; "All night" and "Not during this night" remain distinct. Moon-free is dark minus Moon-up, as in the model.
- Weather aggregates reuse `weatherSlots`: instantaneous values only inside the dark span; gust and precipitation only with ≥30 min of preceding-hour overlap; rows with `available:false` are skipped. Missing stays "Unknown" and is never zero or clear. No seeing, transparency or score is inferred. Dew margin is the model's example 2 °C and is labelled a heuristic.
- Sample data stays labelled "example snapshot". Snapshot age and forecast lead remain separate statements.
- No saved-plan write is added: all new code reads `night`/`weather`; the adoption guard, draft copy, browsed-vs-active header, savebar and `storage` listener were carried over unchanged in intent (conditions.js was rewritten as a whole, so diff it against git to confirm).

## Research

- WCAG 2.2 SC 1.4.1 Use of Color (read 2026-10-20): <https://www.w3.org/WAI/WCAG22/Understanding/use-of-color.html> — colour not the only means; pair with shape, text or pattern; lightness difference counts only at ≥3:1. Applied to bracket, lane thickness, dew bar and legend text.
- Apple HIG "Charts" and Material 3 "Color roles" were fetched but returned only a page title; their claims are **not** used. Earlier project sources (REFERENCE_RESEARCH, NOTION_APPLE_STUDY, PLANNING_SCREENS) were applied as already recorded.
- Existing palette reviewed: `lib/core/theme/app_palette.dart` (`chartDay`, `chartTwilight`, `chartDark`, `chartMoon`, `caution`) and `tokens.json` themes.

## Limitations / for the main agent to run

- Not run: browser render, `node --check`, `node --test design/home-lab/scripts/check_night.mjs` (it imports only the model, but confirm), the 48-case matrix and the 12 Home cases, 200 % text, short-viewport checks.
- Likely first things to verify visually: thumb alignment against the band at both ends; Home compact legend wrapping at 125 %/200 %; hourly-strip cell width at 200 % (cells are 52 px × scale; "Unknown" cloud labels are the tightest); `:has()` focus ring (Chromium); variant-paper label column widened to 60 px.
- Text changes that existing browser-evidence scripts might match: Weather heading ("Cloud 19–42% in the dark" replaces "Cloud in the dark: 19–42%"), Home weather line ("…% cloud in the dark"), Moon heading structure, removed "Forecast lead"/"Snapshot age" fact labels (now one sentence), "Through the dark hours" → "Hour by hour".
- Contrast of the new browser colour pairs was not measured.
- Material and Apple chart guidance could not be verified (see Research).
