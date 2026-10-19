# F14 — Honest multi-night weather coverage (evidence)

Run: full final-plan group (owner launch 2026-10-18), second cloud session, 2026-10-19.
Environment: Linux container, Flutter 3.47.4 / Dart 3.13.3 (the CI pin). Evidence layer: HOST
tests (unit, widget, the real app and database with fake providers). The live service is not
called here; live provider evidence is G1's ("Verification: … live service evidence in G1").

## What changed

- **Domain.**
  - `night_weather_summarizer.dart` (N6): the dark span at the plan's limit; instants in the closed
    span; preceding-hour rows with ≥ 30 min in the span; no rows without dark time.
  - `night_weather_summary.dart`: the spans `dark`, `polarNight` and `noDark`; slot fields
    `instant`, `precedingMinutes`, `partial`; `complete` and `cloudGapHours`.
  - `forecast_overview.dart` (new; N7/N9): per-night coverage, the gaps before and after, the
    first night beyond the forecast, and the lead days from the site-local fetch date.
- **Data.**
  - `open_meteo_weather_repository.dart` (N7): one request, `forecast_days=16`, `timezone=UTC`.
  - `weather_snapshot_store.dart` (N8): the key `weather2:<lat>:<lon>:<model>:16`.
  - `shared_prefs_weather_snapshot_store.dart`: the legacy `weather:` and `weather_cache_` keys
    are deleted on first access (TD-049).
  - `night_weather_service.dart`: one snapshot serves every night it has rows for; a night
    without a row is asked again.
- **ViewModel.** `forecast_nights.dart` (new) and `NightConditionsViewModel.forecastNights`: tonight
  and 15 nights, cached per snapshot, night, zone, limit and margin.
- **Presentation.**
  - `weather_forecast_widget.dart`: the facts first, then coverage and gaps, the lead (separate
    from the age), the dew heuristic in about-hours, and the hourly strip. The strip shows cloud,
    temperature, dew point, wind/gusts and precipitation, with partial hours marked; tapping an hour
    shows its exact values, and a text alternative is provided. Then the seeing limitation, the
    Clear Outside link, and Details (table, model, retrieval).
  - `forecast_nights_section.dart` (new) on the Weather detail.
  - `plan_this_night.dart` (new; N11).
  - `clear_outside_link.dart` (new).
  - `night_text.dart`: span, coverage, lead, dew and the seeing wording.
- **Snapshot.** Additive weather-hour keys (`precedingOnly`, `precedingMinutes`; snapshot `v` 1).
- **Docs.**
  - DECISIONS: ADR-022 "Implemented (F14)" and the ADR-012 index;
  - SCIENTIFIC_INTEGRITY: CALC-32;
  - DATA_MODEL, FEATURE_STATUS (F-30);
  - TECH_DEBT: TD-049 resolved;
  - COMPLIANCE (the Open-Meteo cadence; clearoutside.com) and privacy (one horizon request).

## Criterion results

| Criterion | Result | Evidence |
| --- | --- | --- |
| CHK-F14.A1 | PASS (TEST) | `forecast_overview_test.dart`. **Coverage:** a three-night response gives the 16th partial ("the forecast starts later"), the 17th complete, and the 18th partial with one gap and an end before dawn; the 19th is the first beyond. A night whose rows miss its dark span is none, with a null cloud range. **No dark time:** a 60° N June night has no −18° dark time and no rows. **DST:** the 24/25 Oct 2026 night keeps its whole UTC hours, complete. An empty snapshot serves no night. `forecast_nights_test.dart` A1: one request serves three cards. Each card's coverage text matches the domain ("Complete: N of N dark hours", "… the forecast ends before dawn"), and the lead days are 0/1/2. "No forecast from …: beyond the 16-day forecast" is shown; "16 nights" never is. Stale/offline/out-of-range keep their existing states (`weather_forecast_widget_test.dart`, `night_weather_service_test.dart`) |
| CHK-F14.A2 | PASS (TEST) | **Key:** `night_weather_service_test.dart` "the key separates site, model and horizon, not nights" gives `weather2:46.05:14.51:best_match:16`, with no site id. **Reuse:** one snapshot serves the next night without a request, and a night with no row is asked again. **Legacy keys:** `shared_prefs_weather_snapshot_store_test.dart`: v1 and `weather_cache_` keys are deleted, never migrated, and other preferences stay. **Race:** `weather_site_race_test.dart`: the active site keeps its id, its coordinates change, and the old position's answer arrives after the new one. The new forecast stays on the card, the summary and the overview. Mutation-checked: without the request guard it fails |
| CHK-F14.A3 | PASS (TEST); U at F25 | **Facts first:** `forecast_nights_test.dart` A3/A5 shows the span, then "Cloud 30 % · Temperature 3 °C · Dew point -1 °C", then W2's "Cloud: 1 h without forecast" for an unknown value, never 0 %. **Strip:** a text alternative ("Hourly forecast for the dark span: …") and per-hour labels. Tapping an hour shows the exact values with the cloud layers, humidity, visibility and gusts. **Details:** the ranges table and the model are hidden until Details opens. `detail_screens_test.dart` covers the cloud bars, the dew icon (semantic label) and an unknown cloud drawing no bar; `weather_forecast_widget_test.dart` covers the dark span ("Dark (Sun below −18°)", not sunset to sunrise). No UV, AQI, feels-like or score |
| CHK-F14.A4 | PASS (TEST) | `forecast_overview_test.dart` W3: fetched 10:00 local on 16 Dec, the 18th is 2 days ahead, and 23:30 UTC is already the 17th locally. The widget shows "Forecast made on the day" apart from "Updated … ago" (`weather.lead`, `weather.freshness`). No "score" or "reliab…" wording |
| CHK-F14.A5 | PASS (TEST/DOC); U at F25 | "Seeing and transparency are not forecast here…" and "Look at Clear Outside" (`clear_outside_link.dart`, user-opened, coordinates only, no import; `planner_sky_darkness_test.dart`). **Request budget** (below): one request per site cell per 3 h of use, against Open-Meteo's 10 000/day |
| CHK-F14.A6 | PASS (TEST) | `forecast_nights_test.dart` A6. Opening a card changes nothing: the plan's night stays tonight. "Plan this night" moves a never-saved draft ("Plan moved to …"). For a saved plan it makes a copy for that night with a new id ("Copy made for …; the saved plan is unchanged"), and the stored saved session keeps its evening date. The Save · Discard · Cancel path is the existing `askBeforeLeavingPlan` (its own tests) |

## Request budget (A5)

Per site cell (0.01°), model and horizon: one request for 16 days. It is reused for every night
for 3 hours, and asked again when older, on Refresh, on resume with an outdated forecast, or for a
night it has no row for. Before F14, each night was one request. A day of continuous use at one
site is therefore at most about 8 automatic requests plus manual refreshes, far below Open-Meteo's
600/min, 5 000/h and 10 000/day (COMPLIANCE).

## Commands (working tree before the F14 commit)

- `flutter test --no-pub test` → `+2170 ~2: All tests passed!`
- `integration_test/core_loop_test.dart -d flutter-tester` → `+2`; `perf_scenarios_test.dart` → `+1`
- `flutter analyze --no-pub` → `No issues found!`; format 0 changed; encoding passed
