# Hybrid Weather and night labels — seven refinements

Implemented items 4 and 5 for `variant=blend` only. Changes are in `conditions.js`, `conditions.css` and an opt-in `nightDateLabels(date)` export in `night-ui.js`.

- Weather has one freshness warning directly beneath its answer. Coverage says how many hourly samples exist in dark time; it no longer calls coverage “Full” as a standalone quality-looking status. Retrieval timestamp, offset and age remain immediately below coverage. Partial gaps, offline cache, unknown, loading, error, out-of-range and no-dark meanings remain.
- Wording deliberately says `7/7 hourly samples in dark time`, not `7/7 dark-time hours`: the example has seven point samples over a 7 h 30 min dark span.
- A missing forecast or no-dark state does not describe a retained forecast as stale. Retry and unknown values remain.
- The date browser names the evening (`Night of 19 Oct`) and next date (`Ends 20 Oct`). Upcoming nights, calendar accessible labels, browse messages and adoption confirmation use evening wording. Model date/time calculations, (+1), zone, UTC spans and DST are unchanged.
- Other variants retain their existing strings and layout. The helper is opt-in; no global `nightLabel` behavior changed. Home Weather is untouched.

Read/applied Culmina design rules and typography, Workflow and existing typography roles, relevant engineering guards, and Impeccable craft floor. Used the Playwright CLI skill with an isolated headless Edge session on localhost, not the owner profile.

`check_seven_conditions.cli.js` passed 15 behavior/scaling/comparison groups with zero page errors. The clock is pinned in that isolated test profile for deterministic freshness scenarios. The script checks unknown never becomes zero; exactly one stale/aging warning; three themes at 200%; date rollover/DST/next-night/reload; no storage writes; and unchanged Paper presentation. `conditions-results.json` records the returned results and five screenshots. The stale 100% and light 200% captures were visually inspected. JavaScript syntax checks passed. No native device or provider acceptance is claimed.
