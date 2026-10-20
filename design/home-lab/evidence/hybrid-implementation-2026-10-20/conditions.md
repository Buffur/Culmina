# Conditions implementation — H1 / H3 and condition hierarchy

Scope: original Hybrid (`variant=blend`) HTML Android prototype only. Owner authorised the proposals in `docs/design/HYBRID_REVIEW_2026_10_20.md`. No production Flutter, night-model/scientific function, stored-plan format, palette or font-pair changes.

## Changes

- H1: viewed Night/Moon/Weather tab, night, preview cursor, selected weather hour, calendar month/week and display state live in this page's URL. Replacing the current history entry keeps Back directed to the source page rather than creating a history entry for every preview step. Refresh restores the viewed context. These handlers never save/adopt a plan or write its working draft.
- Date/calendar controls restore an equivalent control after rerender. When the action becomes disabled at an edge, focus moves to a meaningful calendar/date heading. A live status announces the viewed date or calendar month/week.
- H3 Moon: the exact model-derived moon-free duration/interval appears before the calendar. The calendar shows the available example dates rather than leading with three weeks of uncalculated October cells. All existing example dates remain available; 200% uses the existing readable weekly sentences. The compact time browser, full reading key and existing Moon facts remain reachable below, with a direct time-browser link.
- Night: the dark-time answer and compact interactive rail lead. The full reading guide, Moon intervals/phase and Sun/twilight events use labelled disclosures, preserving every existing fact and limit.
- Weather: coverage and snapshot age use a compact trust group before Hour by hour. Partial/unknown/stale/offline/error meanings remain visible. Detailed coverage counts, forecast lead versus retrieval age, the dew heuristic, full hourly values and source explanation remain in Forecast details. Known values are never replaced by zero or a score.

Files owned: `conditions.js`, `conditions.css`, `night-ui.js`. The only shared night-ui addition is `timelineReadingGuide`, reusing the existing legend without changing existing timeline callers. New composition/CSS and URL continuity are guarded to `variant=blend`. Existing non-Hybrid compositions remain on their previous body branches.

## Bounded verification

- JavaScript syntax: `node --check design/home-lab/conditions.js` and `node --check design/home-lab/night-ui.js` passed on the final code.
- `git diff --check -- design/home-lab/conditions.js design/home-lab/conditions.css design/home-lab/night-ui.js` returned clean. Files may still be untracked in the encompassing prototype change; parent owns final staging/review.
- Isolated headless Edge, fresh context, `localhost:4173`, 412×915: **20 targeted browser assertions passed**, six theme/scale captures, no pageerror events. Raw results: `conditions-browser.json`.
- The regression sample checks Next-night keyboard focus and live announcement; calendar day/month/week focus; reload of viewed tab/night/hour/cursor; Back to source; saved plan and navigation draft byte-for-byte unchanged while browsing; Weather partial/missing-cloud/stale/offline/unknown/error/no-dark; exact Moon intervals/none/no-dark for ready/mixed/moon-all/moon-below/moon-middle/no-dark.
- Visual inspection prompted one bounded adjustment: keep “Moon-free” together at large text, and show available month dates immediately. Confirmation: `conditions-confirm.json`, two scales, correct calendar selection/focus and 412px phone/document widths.
- Final month/week announcement correction was checked independently: `conditions-announcement.json` (November 2026; 26 Oct–1 Nov).
- An initial browser run reached the final geometry stage and transiently reported a missing Moon element during ongoing shared work. The repeated bounded batch completed all 20 assertions with zero page errors; no production/model failure was inferred from the incomplete run.

Captures: `conditions-moon.png`, `conditions-moon-200.png`, `conditions-night.png`, `conditions-weather.png`, `conditions-weather-dark.png`, `conditions-night-field.png`. Moon confirmation captures show a browsed night, with the preserved source-plan warning/adoption action; browsing did not adopt it.

Limitations: browser prototype evidence, not Android device/TalkBack/IME evidence; lab text 200%, not browser zoom 200%. Field contrast retains the documented red dark-adaptation exception. No full model/layout/Flutter suite or final broad design QA ran in this worker. Parent owns version bumps, shared-model integration and the requested final Claude design QA.

Cleanup: all worker Edge contexts closed in finally blocks. Owner's 127.0.0.1 tab/storage untouched; existing preview server left running. Temporary scripts removed; evidence here is retained deliberately.
