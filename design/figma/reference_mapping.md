# Reference evidence and transformations

Revision: AFTER-DARK-1.2. Primary package: **notion.id**. Revision 1.2 additionally uses **com.cron.calendar / Notion Calendar** for selected-row and switch reconstruction; the packages are distinct references. Culmina-specific astronomy/timing behavior comes from its source and BEFORE, not an invented external pattern.

`REFERENCE_ROOT` is the machine-local collection at:

```text
C:/Users/zalub/.codex/visualizations/2026/10/29/01a18540-fc19-7d30-a78c-581e611ffa11/android-ui-atlas
```

Pack base: `REFERENCE_ROOT/ui_atlas/notion.id/llm_ready/`. This is an external local dependency, not a Git asset; preserve it without regeneration. Collection README and QA_SUMMARY were read. QA_SUMMARY concerns the other ten packs; Notion has its own QA_REVIEW. Notion START_HERE, AI_DESIGN_SPEC and QA_REVIEW were read, with anatomy, the following clusters and native detail panels visually inspected. The package's C/S labels below are real indices, not D01 inventions.

| Evidence key | Package / file / actual indices | Observed pattern and scope |
| --- | --- | --- |
| R01 | notion.id / llm_ready/cluster_01_main_tabs.png / S01, S03, S04, S05; 00_ui_kit_anatomy.png / C03 S01 | Flat document hierarchy and collapsed/expanded sections; state coverage is a captured slice. |
| R02 | notion.id / llm_ready/01_navigation_details.png / C01 S01, C02 S01, C08 S07, C10 S08 | Workspace/tabs, separate action bar, quiet filter action and checked popover. |
| R03 | notion.id / llm_ready/cluster_03_lists_and_cards.png / S01, S02, S24, S25; 03_database_details.png / C04 S01, C05/C13/C14 S24 | Reading rows, compact record cards, full wrapping titles, one blue creation action. |
| R04 | notion.id / llm_ready/02_search_and_sheet_details.png / C06 S24, C11 S13, C12 S14, C09 S18 | Editable title distinct from search input; grouped sheet rows and switch geometry. |
| R05 | notion.id / llm_ready/AI_DESIGN_SPEC.md and QA_REVIEW.md / S01, S08, S14, S18, S24 | Color sample roles, measurement limits and corrected source semantics. |

## Adoption map

| Culmina component/pattern | Package / file / actual label | Borrow | Adapt for After | Preserve |
| --- | --- | --- | --- | --- |
| AppBar, Context | notion.id / 01_navigation_details.png / C01 S01 | Quiet header hierarchy | Labeled native Back/context targets | Router, site/night identity and appearance action |
| RootTabs | notion.id / 01_navigation_details.png / C01 S01 | Selected/unselected hierarchy | Four labeled Culmina destinations | Plan stays above shell; C02 is not navigation |
| Action, OverflowMenu | notion.id / 01_navigation_details.png / C08 S07, C10 S08; 03_database_details.png / C14 S24 | Quiet action and explicit accent action | Larger targets and full labels; wrapped menu labels | Existing enabled states, commands and feedback |
| ActionRow | notion.id / 03_database_details.png / C04 S01 | Flat row and separated secondary affordance | Remove unrelated tree/add controls | Chooser vs read-only semantics |
| Disclosure | notion.id / cluster_01_main_tabs.png / S01, S03; 00_ui_kit_anatomy.png / C03 | Light disclosure structure | Factual summary remains visible | Stable keys, remembered/controlled state |
| Section, CaptureBlock | notion.id / 03_database_details.png / C05, C13 S24 | Bounded coherent record; growing title | Capture settings, warnings and actions in readable rows | Every source block, setting, provenance and action |
| FitAnswer, PlanState | notion.id / 03_database_details.png / C05 S24 | Primary text with subordinate metadata | Separate fit answer and persistence label | Six fit states and eight lifecycle states |
| FactRow, WeatherMetric | notion.id / 03_database_details.png / C13 S24; 02_search_and_sheet_details.png / C12 S14 | Wrapping metadata and grouped rows | Tabular numbers, units and explicit gaps | Scientific values, coverage and selected hour |
| TextField | notion.id / 02_search_and_sheet_details.png / C11 S13 | Clear input affordance | Durable label, validation and unit | Editor parsing, keyboard, cancel/commit semantics |
| Choice | notion.id / 01_navigation_details.png / C10 S08 | One visible selected choice | Single/multiple semantics per source field | Actual options and constraints |
| Toggle | notion.id / 02_search_and_sheet_details.png / C09 S18 | Recognizable switch geometry | Explicit on/off variants with labels | Actual preference value; source C09 state is unresolved |
| Confirmation, CaptureBlockEditor, Notice | notion.id / 02_search_and_sheet_details.png / C12 S14 | Clear content grouping | Full-page editor stays full-page; prompt actions wrap | Save/discard/cancel, validation, origin and failure |
| ConditionsBrowser | notion.id / 01_navigation_details.png / C01 S01 | Peer-view selection hierarchy | Labeled Night/Moon/Weather plus date navigation | Transient viewed night; explicit adoption only |
| NightTimeline, WeatherTable, SkyDarkness | notion.id / cluster_01_main_tabs.png / S01 (surrounding hierarchy only) | Calm supporting layout | Original Culmina scientific encoding and table behavior | Scale, time zones, gaps, fixed time column, provenance |

## Observation is not the target contract

R05 records page/sheet shell #202020 (S01/S14), S24 record #262626, S24 heading #F0EFED, S01 muted glyph #ADA9A3, S24 action #2783DE, S14 inner rows #373C3F and S08 popover #202020. These are scoped samples, not an extracted global theme. Adventure brown #8E5835 is content/category color and is not an action accent.

After deliberately keeps a neutral canvas/record distinction, uses the observed blue for action fills/graphics, readable primary ink for small actions and dark labels on filled buttons, a separately legible input outline, and distinct scientific/fit/lifecycle roles. Exact target values are owned only by [tokens_semantic](tokens_semantic.md).

Notion C01/C02 are approximately 48 dp tall unions of targets; C08 and C14 are smaller visible/control bounds. Bounds do not prove declared padding, spacing tokens or ergonomic adequacy. After chooses its own tokenized minimum targets and growth rules.

Font family and exact source typography are unverified. [Typography](typography.md) makes explicit, normalized Geist decisions. C09's blue/right-knob pixels contradict checked=false in XML, so neither is promoted to a semantic truth. Notion QA's final 9/10 was focused delta verification, not a second complete audit and not acceptance of Culmina After.

## Coverage boundary

Subsequent owner adoption, 2026-11-04: the four researched Lucide root-navigation analogs are now applied in their scoped After adopters and RootTab state masters. Both appearance controls are icon-only Moon; the visible Field caption is removed. This supersedes the earlier analysis-only/retained-caption recommendation for these named controls, without adopting a global icon-family replacement. See Navigation and WORKFLOW for current evidence.

The [2026-11-04 navigation/readiness review](research/pilot_readiness_2026-11-04.md) distinguishes Notion top tabs and bottom actions from Stargazing Hub's actual bottom navigation. It records official Lucide icon analogs; only the owner-requested Moon for Field is adopted. Button SemiBold emphasis is a Culmina adaptation, not a claim to recover the source font weight. The approved Tonight/Plan composition and the adopted pilot board supersede older conflicting catalog geometry; retain the state and scientific-data boundaries below.

The three pilot longreads were inspected live. Neighboring Night/Moon/Logbook frames and the source page list were seen at overview level only. Other BEFORE screens, alternate states, modal contents and all Light/Field Red frames are not a claimed complete visual inventory. Catalog coverage for unseen dependent states is labeled source-backed or proposed. F01 must add a bounded inventory entry if it discovers a genuinely new component, rather than claiming the full Figma file was audited.

## Historical AFTER-DARK-1.1 — owner-authorized Notion alignment

The owner requested closer colors, typography and spacing while retaining Geist and protecting BEFORE/Flutter. Sampled blue is #2783DE; muted text #ADA9A3; menu/sheet shell #202020. Dark filled-action labels and neutral small action ink retain readable contrast; these are adaptations, not sampled Notion label colors. The S14 grouped-row sample #373C3F is not promoted into unrelated input/scientific roles.

S01/S24 text begins at x=78 source px / 3.25 = 24 logical px in the selected examples. S24 card separation is approximately 8–9 logical px; top-to-text-rectangle distance is approximately 12 logical px. Adopted group insets/gaps are screenshot reconstructions, not recovered padding properties or a global Notion spacing grid. Type reconstruction uses a 36/42 page heading, 14/20 regular section heading, 15/24 regular Geist row/body (calibrated from the initial 16/24 reconstruction) and 18/26 regular record title; exact Notion font, weights and line-height properties remain unknown.

Matched Figma specimens compare source pixel crops, detached historical 1.0 metrics and linked 1.1 resources with the same text. They are resource/composition checks, not complete pilot screens or full-library acceptance. The closed F01 1.0 QA remains historical and does not establish 1.1 acceptance.

## AFTER-DARK-1.2 — focused full-component refinement

Notion Calendar references: `com.cron.calendar/llm_ready/index.html`, reviewed AI_DESIGN_SPEC/QA_REVIEW, original S02 drawer selected-row C03 and S11 switch C05. Their crop colors and accessibility rectangles are observations, not a recovered theme or padding scale. Calendar's #262626 selected-row sample informs generic neutral selection; its switch informs the light-thumb shape reconstruction. Notion C10 informs a selected menu item with a check and no added fill.

The five-set refinement preserves required ActionRow label/value fields, single/multiple Choice semantics, Toggle state/target, source Plan commands and Section body/trailing slots. A 48px item target may produce a taller menu than the captured Notion popover. ActionRow uses a quiet label and regular full value; Section record has separate horizontal/vertical insets. Existing scientific time/sample roles stay distinct.

The full-component board uses literal source crops beside linked instances, including icons, selected indicators, wrapped card content, on/off/disabled switches and focused/long/unknown states. Reference-only generic menu items reproduce the Notion labels; the actual Plan menu remains New plan and Copy to another night. A radio marker is retained for Culmina Choice rather than importing Calendar's layout-mode icon. These adaptations are labeled instead of being described as pixel-identical copies.

## Experimental 1.2 full Longreads — 2026-10-31

The Tonight/Plan test fixtures come from their immutable Figma sources, not from Notion content. The 1.2 document hierarchy and controls are applied with the source words, actions, missing states and measurements preserved. A named source-graphics adapter keeps Tonight's actual phase bands, moon interval and preview geometry/colors; no Notion chart or synthetic catalog series is substituted. Measured equal fact-label/caption slots align numeric baselines without changing shared style values. These named adaptations and remaining coverage limits are recorded in [workflow](WORKFLOW.md).


## Owner composition clarification — 2026-11-04

Owner correction, 2026-11-05: inspect the complete matching BEFORE as a functional reference, alongside current source and external style references. The supplied Moon screenshot establishes a complete month overview; the earlier week-list adaptation below loses that coverage and is superseded as a default recommendation. Follow the [functional-preservation rule](rules_and_constraints.md#functional-preservation--owner-correction-2026-11-05); ask the owner before a doubtful capability reduction. External references guide presentation, not removal of existing functions.

The source-backed month recipe now preserves the full overview using the [calendar-only geometry exception](spacing_and_border.md#moon-month-overview--local-geometry-exception-2026-11-05). Weather refinement uses the complete frozen BEFORE, including Coming nights, as the content/action inventory. Its compact aligned metric rows adapt source density inside the accepted bounded blocks; external Notion references do not supply weather values or justify removing lower sections. Exact resource selection and dated delivery evidence remain in AUTHORING_PROFILE and REDESIGN_RUN respectively.

The latest [Weather owner correction](screens/weather.md#owner-correction--selected-date-only-2026-11-05) keeps V2 graph-tap inspection, removes V1 Inspect an hour and removes night comparison from both versions. The date opens an ordinary calendar; each date's weather remains on its page. This explicitly supersedes C3's comparison inside the date picker, with the approved loss of simultaneous cross-night overview. These choices follow the [Step 4 UX exploration gate](REDESIGN_STRATEGY.md#ux-exploration--structural-alternatives-extension-of-step-4-gate), which requires alternatives and owner selection when a block's necessity is questioned. The rule and routine-QA exception are owned there.

Historical follow-up QA refinement, 2026-11-04–05 (Moon week-list selection superseded by the month repair above): the owner subsequently requested a larger peer-category highlight because the first compact version was too small. Keep it check-free; current dimensions belong to the geometry owner linked below. Night QA adds clear parent headings and removes a duplicate static Moon-free lane. Moon uses the same bounded group composition; its narrow week-list calendar follows current Culmina source, not borrowed calendar values or month-grid density. Canonical selection remains in AUTHORING_PROFILE; mutable output/checkpoint evidence remains in REDESIGN_RUN.

[Transferred Tonight](https://www.figma.com/design/OeDvjQ58cWoHOCSMd69GCG/Culmina?node-id=118-47298) and [transferred Plan](https://www.figma.com/design/OeDvjQ58cWoHOCSMd69GCG/Culmina?node-id=123-47546) are direct composition references for subsequent After Dark screens. The owner explicitly requires their block structure: one coherent bounded group for related content, compact flat rows inside, and clear gaps between groups. Do not flatten later screens into an uninterrupted sheet merely because the external Notion reference is document-oriented. Keep content/actions/Unknown facts source-backed.

For Night/Moon/Weather peer categories, the owner rejected the inherited selection check and large filled pill. Use the compact check-free selection defined by the [geometry owner](spacing_and_border.md#owner-correction--block-composition-and-peer-tabs-2026-11-04); [navigation](components/navigation.md#afternavigationconditionsbrowser) retains behavior. Current progress and the Night correction receipt remain solely in [REDESIGN_RUN](REDESIGN_RUN.md). Earlier external-reference observations and the plain Night construction remain historical evidence; this owner clarification supersedes their competing presentation guidance.


## Candidates search adoption — 2026-11-05

Owner-requested direct reference: Notion `02_search_and_sheet_details.png`, C11/S13, visually inspected together with START_HERE and AI_DESIGN_SPEC. The source shows a rounded shared control containing an actual editable search field and filter affordance (reported parent bounds approximately 283.4×48 logical px). Candidates borrows this shared outline and integrated trailing action, adapting width, Geist, semantic border/focus roles and independent 48px targets to Culmina. The existing filter glyph and inline expansion remain; Notion’s bottom placement and filter sheet are not adopted. The screen question moves to the top menu beside Close; date/site remains above search. Reference bounds do not establish source padding or font tokens. See [forms](components/forms.md) and [geometry](spacing_and_border.md#candidates-search--owner-selected-notion-shell-2026-11-05).
