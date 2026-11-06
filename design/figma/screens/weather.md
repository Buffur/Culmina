# Weather pilot

Revision: AFTER-DARK-1.2.

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

Both versions use accepted Tonight/Plan blocks: context, answer/trust, statistics (rows in V1; graphs in V2), limitations and Forecast details. The latest owner correction below supersedes the original hour-inspection and Coming nights composition. Keep internal rows flat, metric columns readable and secondary disclosures clearly labeled. Preserve source/BEFORE capabilities except for explicitly approved reductions. Expanded table, stale/offline/no-dark and chart variants are source/test-backed; they were not opened as separate live BEFORE states in D01. Canonical recipes are selected by [AUTHORING_PROFILE](../AUTHORING_PROFILE.md); current output/status remain in [REDESIGN_RUN](../REDESIGN_RUN.md).

No confirmed semantic mismatch between the inspected metric content and current source was found in this bounded review. This is not a pixel-by-pixel parity audit or a native behavior test. Historical F01 scope called for a full Longread and a 375 × 812 first viewport without dropping lower sections. The current [base-screen run](../REDESIGN_RUN.md) requires one full Longread and defers the second viewport unless separately requested.


## Owner-requested V2 proposal — 2026-11-05

**Historical first V2 proposal, superseded by the owner's I2+C3 selection below.** This was an explicit charts alternative alongside the rows baseline. Output and execution status belong to [REDESIGN_RUN](../REDESIGN_RUN.md).

**Hour inspection:** Inspect an hour is a source block, not a navigation tab. Both charts and details consume the selected hour; inspection does not save or adopt a plan. Integrate its selector, slider and complete Hourly values disclosure into Hourly forecast. Keep low/middle/high cloud and visibility in the disclosure because the five charts do not cover them. Full-night-fit mini plots reduce horizontal browsing, but point positions are not 48px tap targets; retain the 11 separate 48px hour targets in a horizontally scrolling selector and the original slider alternative. Common selected markers are a proposed interaction; static Figma specimens must not imply functional hour selection without verified prototype wiring. Keep independent scales, units, gust/dew-point legends, gaps and the instantaneous versus preceding-hour distinction visible.

**Coming nights:** Detailed hourly content explains the selected night; Coming nights compares forecast coverage across other nights and provides View this night browsing. Therefore it is not generally redundant. The frozen fixture has only an unknown previous night and the current plan's night, which weakens its immediate benefit. Preferred later simplification is a compact collapsible comparison or coverage inside the date picker. Such a move must preserve all night rows, unknown/partial coverage, current-plan identity, browsing actions and the forecast-limit caveat. V2 currently keeps the existing block; no removal or filter has been approved. Browsing must remain transient and distinct from Plan this night adoption.

## Owner-selected I2+C3 — 2026-11-05

**Historical decision, superseded in part by the correction below.** I2 graph inspection remains selected; C3 comparison inside the date picker is rejected.

The owner reviewed three hour-inspection alternatives and three night-comparison alternatives, then explicitly selected I2+C3. This satisfies the [Step 4 exploration gate](../REDESIGN_STRATEGY.md#ux-exploration--structural-alternatives-extension-of-step-4-gate); proceed with the selected structure without another approval request.

**I2:** Remove the permanent hour strip, slider, selected-hour heading and separate Hourly values disclosure. The initial state is a night overview. Tapping a plot selects the nearest hourly position and synchronizes the cursor and values across all five panels. Selected-only previous/next controls have 48px targets; reset restores overview. Exact local date/time and +1-day identity stay visible. Do not imply every series has a reading at the cursor: excluded dark-span endpoints say Outside dark span, and missing measurements remain Unknown. Continuous scrubbing requires its own actual implementation/verification; a tap prototype is not proof of a drag gesture.

Complete hourly values, low/middle/high cloud, visibility, model, retrieval/coverage facts and attribution belong in Forecast details, backed by the full hourly table with pinned 96px local-time column and horizontal overflow. The table contains all hours, rather than retaining an obsolete fixed 20:00 inspection body after another hour is selected.

**C3:** Remove Coming nights from the main document and move its complete comparison data into the date picker opened from the viewed date. Preserve both 18/19 October records, cloud Unknown versus 0–59%, no/full dark-time coverage, current-plan identity, browsing actions and the no-forecast-from-20-October caveat. Viewing a night does not adopt or save it. Browsing an uncovered night must update the viewed context and show the truthful unavailable forecast state, with a return to the plan's night; never leave the previous night's charts under a new date.

The intended benefit is a shorter main document with details exposed at the point of use. Observable success: no permanent hour-selection controls or Coming nights list in overview; shared hour selection and reset work; date-picker browsing changes the displayed night truthfully; complete source-backed data remains reachable. Output IDs, before/after dimensions and actual verification belong to REDESIGN_RUN.

## Owner correction — selected date only, 2026-11-05

After reviewing explicit alternatives, the owner selected: retain V2 hour selection by tapping a graph; remove only the newly created night list from the date interaction; remove night comparison entirely from **both** Weather pages. The page explains one selected date. The approved loss is simultaneous overview/comparison of other nights; their individual data remain reachable by changing the date. Do not relocate the comparison elsewhere or add forecast badges to calendar days.

The date trigger opens an ordinary calendar. Source `NightPickerDialog` uses a temporary selected date, month navigation and Cancel/OK; Cancel preserves the viewed night and OK applies the chosen date. Browsing does not save or adopt a plan. An uncovered date must display its own unavailable state rather than the previous date's measurements. No forecast boundary should restrict the date controls. Preserve the native month/year chooser and manual-entry affordance; the scoped Figma prototype may leave those destinations unauthored, but must not silently remove their entry points.

V1 removes the separate Inspect an hour block, slider and selected-hour disclosure. Its complete hourly values remain in Forecast details, including cloud layers, visibility, units, dates, source and partial/excluded samples. V2 keeps its shared plot selection, selected-only previous/next controls and Reset. Forecast details in both versions uses the canonical disclosure layout: title and summary at the leading edge, a separate trailing vector chevron, and the complete table in the expanded body. A typed `v`, `⌄` or `⌃` inside the title is not an icon substitute.

This owner choice satisfies Step 4 for the specific removals above. It does not authorize removing trust, unknown states, scientific qualifications or provider attribution. Output status and verification limits belong to REDESIGN_RUN.

## Copy review — corrected Weather exports, 2026-11-05

Reviewed the corrected full-scale V1 (375×1409) and V2 (375×1942) exports, expanded tables and calendar against current HybridWeatherView and the NightWeatherSummary eligibility rule. **Historical review scope:** these broad wording changes were initially proposals, because the owner requested analysis. The owner subsequently approved the copy optimizations on 2026-11-05; the table below is now the approved treatment. Execution and output status belong to REDESIGN_RUN. The scientific key/footer corrections described below preceded that approval. This is Figma/static evidence, not native acceptance.

The answer block already supplies the decision sequence: cloud range, dark window, clearest/cloudiest times, coverage and freshness. Keep those distinct facts, but remove repetitive sentence framing. Detailed metrics explain the conditions; they should not repeat a second narrative conclusion or invent a suitability score.

| Location | Current wording / issue | Proposed wording / treatment |
| --- | --- | --- |
| Both: answer | `Cloud 0–59% in the dark` repeats the window label below | `Cloud cover 0–59%`; keep the exact dark window immediately below. |
| Both: trend | `Clearest around 03:00 (+1) (0%) · cloudiest around 20:00 (59%)` has nested parentheses and prose | `Lowest hourly cloud: 03:00 (+1) · 0%` and `Highest hourly cloud: 20:00 · 59%`. Explicitly identify hourly samples, or retain “around”; avoid implying continuous-time precision. |
| Both: coverage | `Coverage: 10/10 hourly samples in dark time` is long | `Dark-time coverage: 10/10 hourly samples`. Preserve per-metric counts when they differ. |
| V1: presentation | `A · Compact rows` plus a long Appearance command compete with the content heading | `View: Compact rows`; command `Change view in Appearance`. Keep the actual Settings → Appearance destination. Do not silently remove the presentation action. |
| V1: definitions | One dense paragraph explains ranges, four instantaneous metrics, two preceding-hour metrics, partial samples and probability | Use two short paragraphs: `Ranges use known dark-time samples. Temperature, humidity, cloud and wind are instantaneous.` Then `Gusts and precipitation probability cover the preceding hour. * marks partial dark-time overlap. Probability (%) is not rainfall amount.` |
| V2: overview | Repeated `Night:` can imply the entire night rather than included dark-span samples | Use `Dark time:` consistently in the five overview summaries; selected-hour states keep the exact selected time. |
| V2: instruction | `Tap a graph to inspect an hour.` | `Tap a graph to select an hour.` Keep once above the five plots. |
| V2: legends | Units appear in title/summary/legend, while paired series need a clear key | Keep units on the metric/axis role and one explicit `Air / dashed dew point` or `Wind / dashed gusts` key. Remove duplicate unit prefixes only when the remaining association is unambiguous. |
| Both: limitation | `This forecast does not predict astronomical seeing or transparency.` | `No forecast of astronomical seeing or transparency.` Keep the limitation visible. Action: `Open Clear Outside`. |
| Both: details | `Hourly values, layers and source` leaves the kind of layers implicit | `All hourly values, cloud layers and source`. Keep pinned time, dates, units and provider attribution in the expanded body. |

QA correction applied: the V2 footer now states that readings are instantaneous except gusts and precipitation probability, which describe the preceding hour and require at least 30 minutes of dark-time overlap. At 06:00 the preceding hour has 42 minutes of darkness. The 20:00 gust/probability point is excluded for insufficient overlap, so “outside darkness” was not a sufficient key. Both table bodies now use `— = excluded by the dark-time rule; Unknown = missing data`, and selected 20:00 labels say `Excluded (<30 min dark)`. Probability remains distinct from rainfall amount. No series, counts, timestamp or threshold changed.

Forecast details should separate the table key, timing definitions and provider/retrieval metadata into readable paragraphs. Snapshot age and forecast lead time are different; retain the frozen `18 Oct, 18:00 GMT+3` / `0 min old` evidence without implying a refresh occurred. A shorter label is safe only when it preserves this distinction. Cross-night comparison copy becomes unnecessary under the approved removal; this does not remove unavailable/error/Unknown messages for the selected date.


Density assessment after the structural correction: V1 is 600px shorter than its 2009px predecessor (29.9%) because the two unwanted blocks are gone. V2 remains taller because five independent scientific plots dominate its height; removing a list that was only inside the date interaction cannot shorten its closed overview. Its additional 40px relative to the 1902px historical version comes from the proper disclosure header and restored scientific qualification. Copy shortening can improve scanning, but should not be presented as solving the graph layout's height.

Historical additional opportunities, subsequently approved for the copy pass: the V1 letter `A` and long Settings command drew attention away from the metrics; “View: Compact rows” plus a shorter Appearance action communicates the useful choice. Repeated 10/10 counts may share a common coverage sentence only while all corresponding counts agree; per-metric missing/partial counts must reappear when they differ. In V2, `Dark time:` describes the actual aggregation span. Keep separate per-metric numeric scales and paired-series legends. Omit the implementation-oriented “No reliability score” phrase while retaining actual model, retrieval age and attribution. The limitations block keeps its visible caveat and action; no removal, merge or role change was approved by this copy selection.

### Approved copy details and coverage condition

The current V1 fixture uses `All metrics: 10/10 known samples` once above the five rows. This covers seven displayed series, including dew point and gusts. The row instances retain their original coverage properties; only the equal-count fixture's repeated coverage labels are hidden. Restore per-series counts and suppress the common caption whenever any known/eligible pair differs or is Unknown. Count dew-point readings directly, not `dewKnownHours` (dew-risk/spread coverage), and do not treat `coveredHours` (rows present) as measurement completeness. Equal counts do not imply equal timestamps: instantaneous and preceding-hour eligibility differ.

Both detail bodies separate coverage/age, model/retrieval and the temperature-minus-dew-point fact into readable paragraphs. The fixed snapshot remains 18 Oct, 18:00 GMT+3, age 0 min; no refresh is implied. Short legends retain Air/dew point and Wind/gusts distinctions, with units in the adjacent value. All scientific values, tables and qualifications remain governed by the source, not by the reference examples below.

### Weather reference findings — bounded analysis, 2026-11-05

An independent subagent read the LLM packs' AI_DESIGN_SPEC/QA_REVIEW and inspected nine original PNGs from the existing local Android atlas. Useful patterns within the accepted composition are: (1) MIUI Weather's short label → prominent value → secondary explanation; (2) Good To Stargaze's aligned time positions across independent chart scales; (3) Stargazing Hub's adjacent temperature/dew-point and wind/gust information; (4) an exact numeric table alongside a graphical overview; and (5) provider attribution separate from interpretation. These support hierarchy/alignment/readability QA, not new weather data or a new suitability verdict.

Original evidence, relative to the local atlas root recorded in [reference mapping](../reference_mapping.md): `ui_atlas/com.miui.weather2/screens/02_weather_scrolled_02.png`, `ui_atlas/com.goodtostargaze/screens/05_charts_three_days.png`, `ui_atlas/com.goodtostargaze/screens/02_forecast.png`, and `ui_atlas/com.twtapp/screens/02_observe_scroll_02.png`. Good To Stargaze explicitly labels its values demo / Not a Real Forecast. The original PNGs establish visible layout, not interactive synchronization. New two-column/gauge layouts, a transposed hourly matrix, multi-night controls, seeing/transparency values and threshold-based ratings are not selected. Structural alternatives still require Step 4; source completeness and scientific meaning take precedence.

### Owner-selected reference implementation — 2026-11-05

The owner explicitly selected all five findings for the existing mockups. V1 uses short labels and canonical value/caption hierarchy. Temperature and wind retain their primary values, with adjacent secondary dew-point/gust values. Humidity explicitly says Relative humidity; Precipitation always carries Probability · preceding hour beside the percentage. The conditional seven-series coverage rule above remains in force. These are dark-time summaries, not necessarily simultaneous observations.

V2 keeps the same11 hourly positions and independent scales. **Historical axis instruction,2026-11-05; superseded by the audit density refinement below:** the owner requested every hour label20 through06*, with quiet hourly guides. Those hourly guides, data and tap regions remain; the2026-11-06 refinement changes label visibility only. A guide is a time coordinate, not a measured reading or selection. The selected cursor remains distinct. Primary values use the canonical value style; dew point and gusts use adjacent caption lines with an explicit dashed-series label. The same hierarchy applies to overview and selected-hour states; the final excluded temperature slot retains its truthful exclusion message rather than an invented secondary value.

Both Forecast details bodies retain the complete pinned-time table, introduce a clear Hourly values subheading and group provider/model/retrieval/snapshot metadata with the original attribution action under Data source. Coverage, the dew-spread fact, timing qualifications and excluded-versus-Unknown key remain separately readable. Top-level freshness remains visible. This selection does not authorize a transposed table, new navigation, extra meteorological fields, thresholds or multi-night comparison. Output and actual verification belong to REDESIGN_RUN.

### Hourly visibility, table density and pending alternatives — 2026-11-05

The owner requested hourly axis labels plus a denser, centered textual table on2026-11-05. The eleven-label requirement is historical and superseded by the2026-11-06 density refinement below; data and selection remain hourly. Preserve GMT+3/date context,+1 and partial-overlap keys. Both tables retain the current [read-only density rule](../spacing_and_border.md#weather-read-only-table-density--2026-11-05), centered headers/values and complete source text. It does not reduce interaction targets.

Historical graph alternatives presented before the owner's G2+T1 selection: **G1** all five line charts (the previous baseline, familiar and fully visible, but repetitive for constant series); **G2** hybrid narrow centered instantaneous cloud bars and preceding-hour probability bars, with paired temperature/dew and wind/gust lines and an RH line (distinguishes point readings from preceding-hour probabilities, but needs explicit interval keys); **G3** one larger chart plus a metric selector (shorter page and larger plot, but hides cross-metric comparison; retain the chosen hour across switches). G2 is now selected below; G3 remains unbuilt.

Historical table alternatives: **T1** dense centered table (exact, familiar, requires horizontal browsing); **T2** transposed matrix with hours across columns and pinned metric/unit labels (easier within-hour comparison, but needs scrolling date/hour headers and replaces the existing pinned-time layout); **T3** exact numbers with small percentage bars confined to applicable cells (easier magnitude scanning, but adds visual noise and may look like a quality rating unless explicitly neutral). The owner selected T1. All preserve the eight weather columns' meaning, cloud layers/visibility, units, Unknown versus excluded and provider data. T2/T3 remain unbuilt and require another owner selection.

### Owner-selected G2+T1 — 2026-11-05

Apply G2 in the existing five-panel Weather V2 family: temperature/dew point, wind/gusts and relative humidity remain line charts with their existing source paths and independent scales. Cloud cover uses narrow bars centered on the hourly instantaneous samples. A known 0% uses a short baseline mark; missing/excluded readings have no bar. Precipitation probability uses a full preceding-hour interval ending at the labeled tick, with a small visual separator between intervals and unchanged 0–100% scale. At 06:00, 42 minutes of darkness govern inclusion of the complete preceding-hour 5% probability; do not shorten the interval to 42 minutes or scale its value. At 20:00 it remains excluded for insufficient overlap. These are probabilities, not rainfall amounts or a quality score.

Retain all eleven hourly data/tap positions and the shared cursor. Taps select the nearest hour, including across interval bars; instruction copy must describe nearest-hour selection rather than promise that any part of a bar selects its ending hour. Label cadence follows the current density refinement below. The centered read-only table T1 remains unchanged in both versions. Preserve timing/exclusion/Unknown keys, exact table data, model/retrieval/attribution and ordinary selected-date-only browsing. G2+T1 is explicitly authorized; no further structural gate applies to this selected implementation. Other graph/table alternatives remain deferred.

### Audit density refinement —2026-11-06

The owner authorized reducing hourly-axis label density without reducing data. The implementation hides only odd-hour labels21/23/01/03/05 across the five aligned panels and existing selection variants; visible labels are20/22/00/02/04/06*. Preserve all11 hourly series positions, guides, nearest-hour targets, individual scales and exact hourly Forecast details. The instruction says `Tap a plot for any hour · axis labels every 2 h.` This label-cadence choice is author judgment within the authorized density correction, not a return to two-hour forecast sampling. Current output and verification belong to [REDESIGN_RUN](../REDESIGN_RUN.md#audit-fix-waves--current-checkpoint--2026-11-06).
