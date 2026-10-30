# Weather pilot

Revision: AFTER-DARK-1.0.

## Frozen BEFORE

- File: Culmina, key `OeDvjQ58cWoHOCSMd69GCG`; page `Dark · current screens` (`3:2`).
- Exact frame: **005 · weather · Dark · Longread**.
- Verified live node: **9:140569**, **375 × 2214 px**.
- [Open BEFORE](https://www.figma.com/design/OeDvjQ58cWoHOCSMd69GCG/Culmina?node-id=9-140569).
- Live Web Figma full-longread overview, dimensions and readable metric-region inspection on 2026-10-30.

## Visible fixture and parity inventory

| Group | Evidence to preserve | After component |
| --- | --- | --- |
| Navigation | Weather title/Back, appearance action; Night / Moon / Weather peer tabs; site/zone, previous/next/date controls | AppBar/ConditionsBrowser |
| Answer | Night of 19 Oct; Cloud 0–59% in the dark; dark interval/duration; clearest/cloudiest times | WeatherSummary |
| Trust/action | Coverage 10/10 hourly samples in dark time; updated timestamp/age; Refresh forecast | WeatherSummary/Action |
| Mode note | A · Compact rows; Change in Settings → Appearance | FactRow |
| Dark-time statistics | Temperature 6.5°C / dew point 2°C; relative humidity 78%; cloud 0–59%; wind 9 / gusts 18 km/h; precipitation probability 5%; known-hour counts | WeatherMetric |
| Definitions | Ranges across known dark-time samples; instantaneous vs preceding-hour meaning; probability is not rainfall amount | Notice |
| Hour inspection | Inspect an hour slider; selected hourly values disclosure (20:00 in inspected fixture) | WeatherMetric/Disclosure |
| Limitation | Does not predict astronomical seeing; external transparency/Clear Outside link | Notice/Action |
| Forecast details | Collapsed disclosure for hourly values/layers/source | Disclosure/WeatherTable |
| Coming nights | Forecast coverage caveat, night rows and View this night actions; current-plan identity where present | Section/ActionRow |

Retain the original timestamp/age text even if a frozen fixture looks inconsistent. This document does not update the forecast and does not claim its weather data is current.

## Behavior and states from source

[WeatherDetailScreen](../../../lib/presentation/screens/details/weather_detail_screen.dart) opens [NightMoonScreen](../../../lib/presentation/screens/details/night_moon_screen.dart) with initialPage:2. [HybridWeatherView](../../../lib/presentation/widgets/weather_hybrid_view.dart) consumes NightConditionsViewModel; NightBrowserViewModel owns the viewed night. Browsing another night does not change the active plan; only the explicit Plan this night action may adopt it.

The sealed NightWeather states are Idle, Loading, Available, OutOfRange and Unavailable. Available may be stale/cached or partial. Additionally preserve no dark hours, unknown cloud cover, unknown individual values, single-value series and no-site states. Never draw zero-height data for unknown samples. Refresh must preserve truthful busy/cache/failure states.

Rows and hourly charts are existing alternative presentations of the same data. This baseline is rows; F01 must not silently switch it to charts. Hour selection affects inspection only. Gust and precipitation timing semantics remain visible.

Expanded forecast details use [WeatherDetailsTable](../../../lib/presentation/widgets/weather_details_table.dart), with an actual pinned 96-dp Local time column, horizontal scrolling and shared row layout/semantics. The column must preserve dates, offsets, DST repeats and unknown cells. Read [weather_fixed_time_test](../../../test/presentation/widgets/weather_fixed_time_test.dart) and [weather_hybrid_view_test](../../../test/presentation/widgets/weather_hybrid_view_test.dart) for future native verification.

## After composition intent / limits

Use a flat answer and trust block, a grouped but low-decoration metric list, and clearly labeled secondary disclosures. Keep hour inspection, seeing limitation, source details and coming nights reachable in the full document. Expanded table, stale/offline/no-dark and chart variants are source/test-backed; they were not opened as separate live BEFORE states in D01.

No confirmed semantic mismatch between the inspected metric content and current source was found in this bounded review. This is not a pixel-by-pixel parity audit or a native behavior test. F01 compares full longread and a 375 × 812 first viewport without dropping lower sections.
