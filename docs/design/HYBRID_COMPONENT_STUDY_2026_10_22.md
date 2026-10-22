# Hybrid component study — 2026-10-22

Follow-up: [Home separation and Radix Weather trial](HYBRID_COLOR_SEPARATION_2026_10_22.md) fixes the marked Home boundary and supersedes **Weather Light/Dark colours only**. The palette table below records the preceding candidate; its other screen/Field values and the component alternatives remain unchanged.

**Implemented and browser-verified proposal, awaiting owner selection/acceptance.** Only `design/home-lab` presentation/assets and this note changed in this package. No production tokens, calculations, models, Flutter, dependencies or CI were changed. No commit/push or reference freeze was performed.

Open the [interactive comparison](http://127.0.0.1:4173/hybrid-studies.html): three timeline choices and two independent Weather choices, shared Light/Dark/Field and measured 375/412 CSS-pixel phone controls, fixed 100% text. Links also exist in Home studio, Plan and Conditions. The existing preview on port 4173 was reused. Browsing the study writes only its own URL, never owner storage.

## A. Five original images and requirement map

All five originals below were opened and visually reviewed. Numbering is exact; none was reconstructed from descriptions. Attachment folder: `C:/Users/zalub/.codex/attachments/d3b0c44b-fef2-4096-85f1-53b71a60c743/`.

| Photo → exact file / fragment | Observation / class | Cause: confirmed or hypothesis | Priority | Decision | Implementation / evidence | Status |
| --- | --- | --- | --- | --- | --- | --- |
| 1 → `image-1.png`, crossed brand and field toggle | Repeated brand competes with night heading; owner requests relocation. Style request | Confirmed previous header composition | P3 | Remove redundant top brand; keep Welcome reachable below; place Field toggle by night title | `app.js`, `hybrid-refinement.css`; prior [photo-fix evidence](../../design/home-lab/evidence/web-fixes-2026-10-22/index.html) | Previously closed; preserved |
| 1–2 → `image-2.png`, Night/Moon/Weather arrows | Icons before titles; values/captions align to section left, following owner's explicit clarification. Alignment request | Confirmed old leading-icon column indented all content | P2 | Title-only icon grouping; data stay left | Existing Home rows; new Plan icons inside `.night-row-label`; [real Plan](../../design/home-lab/evidence/component-study-2026-10-22/real-plan-light-375.png) | Closed/preserved; Plan adopter verified |
| 2 → `image-2.png`, grey band and upper shortcuts | Grey band and icon-only jumps insufficiently expressive. Style/usability request | Confirmed earlier grey sky roles and unlabeled controls | P2 | Three shared presentations; black night in every choice, restrained blue/cyan twilight in Gradient/Detailed; labelled Dark starts/ends + exact time | `night-ui.js`, `night.css`, `hybrid-studies.*`; comparison and matching timeline captures | Implemented/verified; variant choice pending |
| 1–2 → marked trailing chevrons | Same navigation role should have consistent size | Confirmed earlier different SVG boxes | P3 | Retain preceding fix: trailing Home chevrons 18×18/stroke 1.7; new data glyphs 20×20/stroke 1.7 are a separate role | Existing Home anatomy; new icons do not replace navigation globally | Previously closed; preserved |
| 2 → lines under sections | Boundaries and spacing need restraint. Style observation | Hypothesis: marks might suggest divider removal; no explicit instruction to delete every divider | P3 | Keep boundaries that separate semantic groups; do not infer blanket deletion | Shared row styles; new Weather rows use quiet single dividers | Resolved as a documented interpretation |
| 3 → `image-3.png`, Moon-free dark and calendar | Title + 4 h 15 min should share a line when they fit; calendar captions/date/phase need alignment | Confirmed earlier layout/target constraints | P2 | Preserve content-driven wrapping, 12px calendar captions and ≥48px day targets; add quantity colour without changing phase graphic | `hybrid-refinement.css`, `hybrid-data-tokens.css`; [Moon 412 Dark](../../design/home-lab/evidence/component-study-2026-10-22/real-moon-dark-412.png) | Earlier layout fix preserved; new palette verified |
| 4 → `image-4.jpg`, five-day forecast graph | Neutral surface, aligned time positions, distinct series and selected column. Inspiration, not a five-day feature request | No Culmina bug inferred; reference has daily high/low rather than our hourly temperature/dew | — | Reuse alignment/series distinction with existing hourly samples; no daily high/low invention | Weather B, solid temperature/dashed dew, shared x positions, selected hour and exact disclosure | Implemented/verified; presentation choice pending |
| 5 → `image-5.jpg`, hourly strip and metric cards | Separate labelled metrics, units and restrained accents aid scanning. Inspiration | No defect inferred from absent reference-only metrics | — | Weather A separates existing metrics; B provides hourly panels. Do not copy UV/AQI/pressure/real-feel gauges or invent their values; keep Home compact | `weather-variants.*`; A/B captures and runtime Home check | Implemented/verified; presentation choice pending |

Prior Plan requests (Site and night, Capture plan, Light, leading Edit and equal-height actions) remain covered by the preceding [web-fix record](HYBRID_WEB_FIXES_2026_10_22.md); they were not reimplemented here. Required outcome is refinement of existing data/functions, not copying decorative details or adding weather suitability thresholds.

## B. Applied Culmina palette inspired by Notion

These are **Culmina values**, not official Notion HEX. Existing neutrals/actions are reused. Prefix names with `--`; aliases reference the existing shared token. New roles live in `hybrid-data-tokens.css`, loaded after `hybrid-refinement.css` in Home/Plan/Conditions and the study. Adopters are Weather metrics/lines, Moon facts, Plan fit/graph/condition labels, and the study's explicitly illustrative state examples. Home Weather composition and colours stay compact and unchanged.

| Token / alias | Role | Light HEX | Dark HEX | Text/background/line | Application rule |
| --- | --- | --- | --- | --- | --- |
| data-surface → surface-default | Canvas | #FFFFFF | #191919 | background | Existing page |
| data-surface-subtle → surface-subtle | Group | #F7F7F5 | #202020 | background | Related content |
| surface-raised | Overlay | #FFFFFF | #252525 | background | Existing overlays |
| surface-sunken | Preview well | #F0F0ED | #141414 | background | Studio well |
| data-text → text-primary | Main text | #37352F | #EBEBEA | text | Answers/values |
| data-text-support → text-secondary | Supporting | #5A5955 | #A5A5A3 | text | Labels/explanations |
| text-tertiary | Provenance | #6E6D69 | #8F8F8D | text | Existing metadata |
| data-divider → border-subtle | Divider | #E9E9E7 | #2F2F2F | line | Decorative separation |
| data-control-edge → border-control | Boundary | #8F8E8A | #6F6F6D | line | Recognisable control |
| data-action → action | Action | #37352F | #EBEBEA | background | Explicit verb |
| data-on-action → on-action | On action | #FFFFFF | #191919 | text | Only on action |
| data-selected → selection | Selection | #E9E9E7 | #343432 | background | Neutral primary text + selected state |
| data-temperature | Temperature | #8C4B2E | #DFA388 | icon/line | Quantity, not suitability |
| data-moisture | Humidity/dew/precipitation | #316C88 | #86B9CF | icon/line | Separate labelled units; dew dashed |
| data-cloud | Cloud | #61615D | #B6B6AF | icon/line | Labelled coverage % |
| data-wind | Wind | #316C88 | #86B9CF | icon/line | Separate panel; gust dashed/hollow dots |
| data-moon | Moon | #7561A4 | #BEACDE | text/icon | Facts, not phase or quality |
| data-success | Operation completed | #386A4B | #99C5A6 | text | Explicit success word; not Fits |
| data-caution | Warning | #9A5B00 | #FFB74D | text/line | Existing caution + reason |
| data-error → error | Operation/validation error | #B00020 | #F28B82 | text | Failure + recovery |
| data-unknown | Unknown field | #61615D | #B6B6AF | text/line | Unknown is not zero |
| data-no-data → data-unknown | No sample | #61615D | #B6B6AF | text/line | Explicit no-data wording/gaps |
| data-stale → data-caution | Old snapshot | #9A5B00 | #FFB74D | text/line | Age + stale wording; study dashed underline |
| data-disabled | Inactive | #A3A29F | #6B6B69 | text/icon | Disabled only, exempt contrast |
| data-fit-fits → text-primary | Fits | #37352F | #EBEBEA | text | Existing verdict/reason |
| data-fit-tight / data-fit-does-not-fit / data-fit-no-window → data-caution | Existing constrained fit | #9A5B00 | #FFB74D | text | Warning, separate from operation error; no new thresholds |
| data-fit-needs-input → text-secondary | Missing window/input | #5A5955 | #A5A5A3 | text | Unknown is not a poor fit |
| data-plan-gain-start → data-moisture | Gain line start | #316C88 | #86B9CF | line | More contrast than the prior pale endpoint |
| data-plan-gain-end | Gain line end/point | #2465AD | #7DD3FC | line | Existing mathematical curve, new presentation only |

All foreground tokens are opaque, alpha **1**. Disabled study button additionally inherits existing whole-control opacity **.55**. Weather has no new translucent chart fill; hollow points use the canvas. Optional `data-series-wash:10%` is defined but unused and must not be treated as a meaningful boundary. Existing Plan area is a vertical gradient of `data-plan-gain-end` at **0% / alpha .28 → 100% / alpha 0**; its line is **0% gain-start → 100% gain-end**, alpha 1.

Default Hybrid Dusk sky roles, Light / Dark: day **#C8EDFA / #7DD3FC**; civil **#83CDEA / #46B6E8**; nautical **#439ED6 / #278CCB**; astronomical **#2465AD / #1D5EA8**; dark **#000000 / #000000**. Exact 24h-fixture knots (%): day **0, 10.417**; civil **22.049**; nautical **25**; astronomical **30.556**; dark **34.375, 65.625**; astronomical **67.361**; nautical **70.833**; civil **73.785**; day **87.5, 100**. Between different neighbours, seven stops at j/8 use Oklab weights `x*x*(3-2*x)`, rounded to three decimals. The [full exact generated string and interval timestamps](../../design/home-lab/evidence/component-study-2026-10-22/timeline-gradient-stops.json) include every intermediate stop. Stops follow fixture events, not measured brightness. Unknown spans have an opaque hatch; no known colour is inferred. Minimal replaces sky colour with neutral, retains black dark spans and boundary cues. Moon lanes retain existing up/free Light **#607D8B/#37352F**, Dark **#B0BEC5/#EBEBEA**.

Field is preserved: quantity/Moon/success **#FF0000**; cloud/unknown/no-data **#AA0000**; caution/stale/error **#FF0000**; disabled **#660000**; Plan gain **#990000 → #FF0000**. Existing dim-secondary tradeoff remains; no general Field AA claim. Do not place normal-size Moon/caution text on Light selection grey (4.316/4.463:1); selected controls retain neutral primary text. Colour also has words, exact values, units, boundaries, line styles or point shapes.

## C–D. Comparisons and recommendation

| Timeline | Readability / information / visual tradeoff |
| --- | --- |
| Minimal | Quiet neutral band, black exact dark interval and both Moon lanes. Sky/event/target details remain in Exact times; least colour, requires disclosure for sky categories. |
| Gradient — preliminary recommendation | Same geometry and details; blue/cyan categories make dusk/dawn easier to scan. Dark stays black; no glow/rainbow/quality score. |
| Detailed | Same gradient plus known Sun-event ticks and an existing target-window lane; more immediate information at the cost of density. |

One `timeline()` implementation, exactly three IDs. Same fixture, noon-to-noon range, five-minute cursor, width/theme/text scale across choices. Switches retain the selected instant; exact disclosure exposes sky, Sun, dark, Moon and target facts in every variant. Existing `jumpCursor` is reused; clipped/no-dark labels retain their existing meanings. Study reset follows Hybrid opening semantics: Now when in the night, otherwise dark start (timeline start without dark time). No model changes.

| Weather | Presentation / recommendation |
| --- | --- |
| A — compact rows | Five separated metrics: temperature/dew, RH, cloud, wind/gust, precipitation probability. Best default for quick scanning. |
| B — hourly panels | Same ranges/coverage and existing hourly samples; aligned time positions with independent physical units/y scales. Best for temporal comparison. |

Both expose exact hourly values, source/retrieval age/lead/coverage and Europe/Kyiv. Gust/precipitation keep preceding-hour eligibility; instantaneous variables remain separate. Probability is %, never mm. Missing samples disconnect lines and show `?`, never zero/interpolated weather. Solid/dashed lines and filled/hollow markers separate temperature/dew and wind/gust. Existing dew caution is reused, not a new threshold. Main Weather retains retry, full table, coming nights and provenance. The component uses caller-owned selection and no element IDs; comparison choices are independent, not six combinations. Actual Home Weather stays a summary. Existing real Moon phase graphics are unchanged.

## E. Icon comparison and implementation map

Existing research was reused; only missing concrete assets/licence details were refreshed. Lucide and Tabler both offer consistent portable SVGs. Iconify is catalogue/tooling across sets, not one visual family.

| Option | Style / required symbols | Licence / portability / decision |
| --- | --- | --- |
| Lucide | Rounded outline, 24 viewBox; the seven IDs below | Selected subset. ISC plus the full Feather-derived MIT notice. Same local geometry can be reused in a later authorized platform migration. |
| Tabler | Outline, 24 viewBox, default stroke 2; same seven exact IDs available | MIT; equally portable local SVG. No need for a second family in this package. |
| Iconify | `lucide:*`, `tabler:*` and other sets have separate styles | Licence follows each set. No runtime API/package introduced. |

Every selected glyph uses **20×20 / 1.7 CSS-pixel non-scaling stroke**; visible labels provide accessible meaning. Helper `icons.js` embeds the original asset bodies, `aria-hidden=true`, `focusable=false`. Existing navigation/action icons are preserved; no new icon-only action was added.

| Place → role | Exact set:ID | Visible label | Local asset under `design/home-lab/` |
| --- | --- | --- | --- |
| Weather temperature | lucide:thermometer | Temperature · °C | icons/lucide/thermometer.svg |
| Weather humidity | lucide:droplets | Relative humidity · % | icons/lucide/droplets.svg |
| Weather wind/gust | lucide:wind | Wind / gusts · km/h | icons/lucide/wind.svg |
| Weather precipitation | lucide:cloud-rain | Precipitation probability · % | icons/lucide/cloud-rain.svg |
| Weather cloud / Plan weather row | lucide:cloud | Cloud cover · % / Weather | icons/lucide/cloud.svg |
| Night/Moon disclosure / Plan night row | lucide:moon | Moon intervals & phase / Moon details / Night & Moon | icons/lucide/moon.svg |
| Night Sun disclosure | lucide:sun | Sun & twilight | icons/lucide/sun.svg |

The [complete unmodified upstream LICENSE](../../design/home-lab/icons/lucide/LICENSE) includes ISC copyright 2026 Lucide Icons and Contributors and Feather MIT copyright 2013-present Cole Bemis (including moon). [Asset provenance](../../design/home-lab/icons/lucide/README.md) records source/date. The seven raw SVGs keep upstream metadata; only presentation size/stroke changes. No CDN, entire icon library or Flutter package.

Sources refreshed 2026-10-22: [Lucide licence](https://lucide.dev/license), [upstream LICENSE](https://github.com/lucide-icons/lucide/blob/main/LICENSE), [Lucide SVGs](https://github.com/lucide-icons/lucide/tree/main/icons), [Tabler](https://tabler.io/icons), [Tabler SVGs](https://github.com/tabler/tabler-icons/tree/main/icons/outline), [Iconify set licences](https://github.com/iconify/icon-sets/blob/master/collections.md). These sources support icon facts; colour HEX values are our proposal. Context7 resolution/query preceded Lucide API/documentation use.

## Verification, corrections and acceptance boundary

- One combined browser pass in an isolated Playwright session, using existing tools/server: Timeline three ways and Weather two ways **independently**, 375 Light and 412 Dark, 100%; selective actual Plan/Night/Moon/Weather adopters, plus Field role/Weather/Plan regressions. Partial/cloud-unknown/no-forecast/no-dark states were checked without a Cartesian matrix. Owner browser storage was untouched.
- [Initial results](../../design/home-lab/evidence/component-study-2026-10-22/final-qa.json): 73/74 assertions passed. The single false assertion expected plural `Timeline starts`; actual existing label is singular `Timeline start`. Corrected semantic recheck passed; the original failure is retained. Switches, exact values, slider keyboard, reset/jumps, source/units/coverage, Home compactness and runtime checks passed. No runtime errors, failed requests or external runtime requests in this pass.
- Visual review found genuine presentation issues: Minimal's dark-theme night was white; Detailed's target lane overlapped endpoint labels because the later shared compact-stack rule won. **Correction 1** makes the interval black with boundary cues and reserves an extra lane. Actual Plan gain's pale endpoint also failed intended graphic contrast, so its scoped gradient was adjusted. [13 targeted assertions passed](../../design/home-lab/evidence/component-study-2026-10-22/correction-1-qa.json), including no-dark and a separately labelled synthetic unknown-sky renderer probe.
- **Correction 2** removes inherited fixed-height phone-page layout from the study host; its canvas now covers the full document. [Light/Dark height/width check passed](../../design/home-lab/evidence/component-study-2026-10-22/correction-2-qa.json). No further correction rounds were used. Final actual captures were personally viewed, including [Light overview](../../design/home-lab/evidence/component-study-2026-10-22/final-page-light.png) and [Dark overview](../../design/home-lab/evidence/component-study-2026-10-22/final-page-dark.png), each timeline variant, Weather A/B/gaps and real-screen adopters. Final timeline stills share 21:15; live switching preserves any chosen instant.
- Actual computed pairs: new sampled text minimum **5.426:1 Light / 7.125:1 Dark**; Weather lines **5.783 / 8.148**; Moon facts **8.494** Dark. Plan line endpoints against canvas and strongest composited area fill: **3.816 / 4.179**; Plan graph labels **7.012 / 7.125**. New opaque role arithmetic also passes text 4.5/control-graphic 3 on intended canvas/subtle/raised surfaces. Sky blending is not a numeric brightness scale; labels, exact boundaries and accessible facts carry meaning. Decorative dividers/disabled controls are not falsely required to reach 3/4.5. This is bounded pair evidence, not whole-product WCAG certification.
- [Pointer and horizontal-keyboard interaction check](../../design/home-lab/evidence/component-study-2026-10-22/interaction-check.json) passed: time-preview pointer input updates the value, the hourly strip scrolls with ArrowRight, and the last 05:00 slot exposes preceding-hour gust/precipitation without presenting instantaneous values outside dark time. Its first temporary harness command used an invalid unquoted numeric attribute selector; the corrected selector passed without an application change.
- JS syntax, existing **46 Night + 16 quality checks**, 11-scenario Weather presentation/data assertions, checks of seven icon bodies/assets/decorative attributes and whitespace checks pass. No Flutter build/tests, performance audit, CI repair, phone use, installation or dependency change occurred.
- [One scoped Impeccable scan](../../design/home-lab/evidence/component-study-2026-10-22/design-detect.json): three reviewed findings, not a clean-scan claim. Geist is explicitly pinned by the existing design; stripes encode unknown data, not decoration; reported 2.1:1 text is the explicitly disabled example's hover style and falls under the inactive-control exception. No reason to change the pinned font or conceal missing data.
- [Completion inventory](../../design/home-lab/evidence/component-study-2026-10-22/completion-audit.json): 13 final source/evidence checks passed, including exact current gradient equality, seven SVG geometries, notices, photo availability, palette imports and local report links. This supplements the actual visual review rather than replacing it.

All five tasks have implemented deliverables and scoped evidence. **Owner choice remains open:** timeline presentation, Weather A/B preference and acceptance of the proposed palette/icon subset. Recommendation is Gradient + A, with B available for time comparison. No choice has been recorded as owner-approved; the web reference remains unfrozen and Flutter transfer has not started. Stop here for owner review.
