> **Historical navigation copy — not active instructions.** Link destinations are rebased from `docs/design/PLANNING_SCREENS_2026_10_19.md`. Content and acceptance statements retain their original date/scope. [Immutable original](../../../docs/design/PLANNING_SCREENS_2026_10_19.md) · [Navigation index](../../../NAVIGATION.md). Original SHA-256: `2bbc2c25d6d3d42179562a0f3d80cfcdc9edd12d3a5c8d7a0674324a8578eb39`.

# Android planning screens — 2026-10-19

Subsequent owner-requested refinement: [quality decisions](QUALITY_REFINEMENT_2026_10_20.md) and [current evidence](../../../../../../design/home-lab/evidence/QUALITY_REFINEMENT.md) supersede the earlier visual captures for changed inputs. The underlying scope/science boundaries below remain.

Status: **completed and verified as a browser prototype, 2026-10-20**. Scope confirmed by the owner: **Android prototype in the browser**, not production Flutter. Goal: assess the project roadmap/audits/references, complete the Plan design, implement Night/Moon/Weather, add a concise Moon/dark-time browser to Home, and use CLI agents. [Current acceptance evidence](../../../../../../design/home-lab/evidence/PLANNING_SCREENS.md) covers P01–P12.

## Evidence and decisions

The operational PROGRESS header predates parts of the implementation ledger. The [2026-10-19 implementation review](../../../../../refinement/DEVELOP_IMPLEMENTATION_REVIEW_2026_10_19.md) identifies the reviewed `8048cfa` source, implementation of F01–F25 and remaining qualification gaps. We use current source and the dated audit, not the stale “no F task started” header, to understand functionality. This prototype closes no F/CHK or release gate and fixes no production defect.

| Input | Applicable contract | Prototype decision |
| --- | --- | --- |
| [Roadmap F06/F12/F18](../../../../../refinement/FINAL_COMPLETION_ROADMAP.md), SP03/SP05 in [FINALIZATION_REVIEW](../../../../../refinement/FINALIZATION_REVIEW.md) | Intended frames, four visible estimates, scoped Apply vs Save, camera-class parameters, reachable details, stable Save and all missing prerequisites | Frames/estimates precede disclosures; target once; optional camera records stay unrecorded; empty capture plan does not create a new Save restriction |
| F13 A5, F15 A5, SP08, ADR-022 in [DECISIONS](../../../../../DECISIONS.md) | Browsing changes no saved plan/result. Explicit Plan this night alone adopts; saved source is copied after the guard. Slider browses 5-minute UTC instants | Shared context/checkpoint and guarded draft/copy flow; local-time labels include date and UTC offset; no playback or plan-start editing |
| F14 A1/A3/A4 | Real coverage, hourly cloud/temperature/dew/wind/gust/precipitation, gaps, exact-hour inspection, lead separate from retrieval age | One explicit example snapshot, three covered/partial nights; no 16-night completeness claim, no zero-filled gaps, forecast horizon stated |
| F15 A1/A5; `night_view.dart`, `moon_conditions.dart`, `night_timeline.dart` | Sky segments, Moon-up, moon-free intervals and classifications; phase does not determine intervals; no-dark and polar states distinct | Shared technical time bar and text alternative; month selection only browses; large text switches the calendar to full-sentence rows |
| F17/AM03-T | Home context and plan describe one selected night, secondary candidates, no Home New plan; Tonight tab stays Tonight | Preserve reversible plan-first comparison; shared data drives Home, Plan and conditions. The owner-requested compact Home slider is a deliberate prototype addition |
| [Develop audit](../../../../../refinement/DEVELOP_IMPLEMENTATION_REVIEW_2026_10_19.md), R2 | Fractional exposure/large numeric input needs honest validation; reviewed production defects remain open | Browser validation retains invalid text and errors. This is not a production fix or Android runtime proof |
| [Video audit](VIDEO_GUIDANCE_AUDIT_2026_10_19.md), [reference research](../../../../../design/REFERENCE_RESEARCH.md), [Notion/Apple study](NOTION_APPLE_STUDY_2026_10_19.md), [Plan review](PLAN_CONCEPT_REVIEW_2026_10_19.md) | Semantic tokens, grouped components, text/spacing roles, explicit rules/debt; preserve owner’s Hybrid Notion + Journal | Flat restrained surfaces, Manrope body and Journal night heading; Android bars/touch targets/scrolling. Apple/Fluent/Spectrum principles do not transplant their platform controls |

Night and Moon are two sections/tabs of the **same conditions route and night context**. They do not introduce a second lunar engine or independently editable Moon plan. Weather shares that viewed context. Flutter remains a functional reference, not the appearance to copy.

## Model boundaries

`night-model.js` contains dated, explicit browser fixtures matching domain data shapes. It is not a new astronomy engine or provider. Intersections, Moon-below subtraction, elapsed-time cursor facts and formatting operate on supplied intervals. The fixture includes a DST fall-back night with the project’s fixed 24-hour UTC SessionNight, no-dark, all-Moon-up, Moon-below and split intervals. Repeated wall times remain distinguishable by offset; the fixture wall-time helper chooses the first occurrence of an ambiguous time.

Weather values are explicit samples shaped like existing provider data, with no network request. Coverage counts hourly instants inside the dark span, following `night_weather_summarizer.dart`; it is not overlap-weighted elapsed coverage. The UI distinguishes instantaneous variables from preceding-hour gust/precipitation, which require at least 30 minutes of overlap; partial hours are marked. Missing visibility is not converted through `null / 1000` into a false 0 km. Lead uses site-calendar dates at retrieval, following `forecast_overview.dart`; age uses the actual current clock against the stated fixture retrieval timestamp. No seeing/transparency, reliability or universal good-night score is invented.

Plan uses the shared `plan-model.js` fixture budget. The saved record holds an active snapshot and immutable archived originals; the separate working checkpoint is a draft, not a competing saved-plan source. Home/Plan/conditions share those helpers. Scope is the lab’s own browser keys; no application database, equipment catalogue, acquired calibration or image metadata is read. Proposed calibration frames are not an acquired library or compatibility result. Full photo parsing, actual provider/cache, ephemeris, export/release and native gestures remain production functionality outside this design task.

## CLI work actually executed

- Claude Code 2.1.303 was verified locally. Context7 official Claude documentation confirmed print/JSON/read-only tool usage. Antigravity was not found on PATH; it was not used.
- Sonnet (`claude-sonnet-5-5`) returned a source-linked Night/Moon/Weather functional contract; Opus (`claude-opus-5-5`) returned a Plan gap review. Both were restricted to Read/Grep/Glob.
- Sonnet wrote only `scripts/check_night.mjs`, using Read/Write/Grep/Glob. Main-session review/run found two real model defects (DST conversion, falsely reporting a clipped Moon interval as a moonset) and corrected them. A mixed-interval assertion had incorrect arithmetic; it was reconciled to dark time remaining plus separately labelled moon-free time. Lead-day expectations were updated to the verified calendar-date contract after the implementation changed concurrently. The agent’s civil-noon 25-hour test assumption was also corrected against `SessionNight` and `SessionNightResolver`: the actual project window is always 24 UTC hours, even across DST. Original agent output remains intact.
- Opus completed Plan HTML/CSS/JS under exclusive file ownership during its run; the lead integrated the shared models/Home/conditions. Main-session source and browser verification found and repaired a restored-editor field overwrite, preserved explicit blanks, removed an extra editor Save, and verified empty-plan Save, guards, class-specific fields and budget changes.
- A final read-only Sonnet review identified cursor endpoint, clipped-event, weather sampling, missing-value and direct-URL context issues. Accepted fixes and rejected assumptions are recorded in the acceptance evidence; CLI reports were reviewed against domain source rather than accepted as authority.

Requests, actual JSON responses and stderr are under `design/home-lab/evidence/ai/`. No agent usage, remaining limit or successful check is inferred from intent alone.

## Acceptance for this prototype

| ID | Required result | Proof |
| --- | --- | --- |
| P01 | Roadmap, audits and visual references inform the change; approved visual direction and Android target remain | This source/decision map, current skills, rendered phone screens |
| P02 | Plan has one target, capture-first editing, four visible outputs before Details, all missing remedies, stable eligible Save including an empty capture plan | Source inspection and browser empty/partial/saved states |
| P03 | Camera-class fields, optional records, fractions and invalid input; scoped Apply ≠ Save; changed editor guard | Model tests and editor interactions/reload |
| P04 | Add/edit/remove/reorder/Undo, proposed calibration and editable explicit assumptions | Browser state transitions and budget checks |
| P05 | Save/Discard/Cancel, failed save/retry, working draft reload and original-preserving copy | Model tests plus actual browsing/adoption UI flows |
| P06 | Night has sky/Moon timeline, local dates/zone, truthful countdown vs remaining, reset and Sun/twilight facts | Interval/cursor tests, keyboard slider, DST/no-dark renders |
| P07 | Moon has phase/illumination, Moon-up and moon-free intervals, calendar browse with selected vs plan night, large-text list | Model classifications and calendar/Back interactions |
| P08 | Weather has cloud/temperature/dew visualization, wind/gust/precipitation, exact-hour values/layers/table/source, gaps and coverage | Model/DOM/UI checks including partial, absent, stale, offline, horizon and no-dark |
| P09 | Home uses a concise interactive Moon/dark-time slider on the same selected night; moving it writes no plan | Home/conditions readout comparison and plan-state preservation |
| P10 | Home and Plan link to full conditions screens; Back preserves context, draft and saved meaning | Navigation/guard checks |
| P11 | 412px phone format at desktop and mobile, 48px controls, no horizontal page/content overflow, light/dark/field and 200% text | Bounded browser matrix and screenshots, not native acceptance |
| P12 | CLI agents actually contribute and their results are reviewed | Recorded CLI exit/result data, accepted/rejected finding dispositions, resulting tests/code |

All twelve rows have current evidence in the linked acceptance record: 60 model tests, a 48-case verified-viewport screen matrix, 12 Home cases, actual editor/navigation/save interactions and screenshots. Browser checks cannot certify Flutter, TalkBack, predictive Back, real IME, emulator/device performance, production science or release gates.
