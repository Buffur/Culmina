# Reference evidence and transformations

Revision: AFTER-DARK-1.0. Primary package: **notion.id** only. No secondary app style was needed for this revision. Culmina-specific astronomy/timing behavior comes from its source and BEFORE, not an invented external pattern.

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

After deliberately keeps a neutral canvas/record distinction, chooses a brighter action ink/fill for readable contrast, a separately legible input outline, and distinct scientific/fit/lifecycle roles. Exact target values are owned only by [tokens_semantic](tokens_semantic.md).

Notion C01/C02 are approximately 48 dp tall unions of targets; C08 and C14 are smaller visible/control bounds. Bounds do not prove declared padding, spacing tokens or ergonomic adequacy. After chooses its own tokenized minimum targets and growth rules.

Font family and exact source typography are unverified. [Typography](typography.md) makes explicit, normalized Geist decisions. C09's blue/right-knob pixels contradict checked=false in XML, so neither is promoted to a semantic truth. Notion QA's final 9/10 was focused delta verification, not a second complete audit and not acceptance of Culmina After.

## Coverage boundary

The three pilot longreads were inspected live. Neighboring Night/Moon/Logbook frames and the source page list were seen at overview level only. Other BEFORE screens, alternate states, modal contents and all Light/Field Red frames are not a claimed complete visual inventory. Catalog coverage for unseen dependent states is labeled source-backed or proposed. F01 must add a bounded inventory entry if it discovers a genuinely new component, rather than claiming the full Figma file was audited.
