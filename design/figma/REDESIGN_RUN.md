# Dark redesign base-screen run

The historical Figma authorizations in this record did not authorize Flutter migration. That scope limit does not revoke separate, explicit owner authorization for Flutter work.

## Tab grouping — canvas checkpoint —2026-11-06

Owner request: organize the existing page into four horizontal rows by Tonight, Logbook, Library and Settings, then establish screen coverage against the application. Live preflight found41 product frames covering all40 numbered base contexts, with Weather5 represented by V1 and V2. There were no other page children. Existing overlapping canvas positions26–29 were resolved by the row organization; their product content was not changed.

| Canvas section | Section ID | Numbered contexts, left to right | Frames |
| --- | --- | --- | --- |
| Tonight | `206:20662` |1–13,22,27,31; both Weather5 versions adjacent |17 |
| Logbook | `206:20663` |14–17 |4 |
| Library | `206:20664` |18–21,23–26,28–30,32 |12 |
| Settings | `206:20665` |33–40 |8 |

Each section contains one top-aligned row with120px gaps between the original375px frames. Section rows stack Tonight→Logbook→Library→Settings. Canvas positions/parent sections changed; all41 root IDs, sizes, descendant node counts and captured interior text/style/layout/vector/prototype-property fingerprints matched before/after. No component master was edited or screen duplicated. Evidence: `build/figma-tab-groups-20261106/inventory.json`, `grouping.json`; live readback PASS,zero findings,41/41 interiors unchanged. Native editor overview confirmed four titled rows; Scripter was closed afterward. This placement-only check is not another product visual QA or prototype interaction pass.

Classification judgment: shared root-navigator screens belong to their primary originating workflow for this canvas. Scoped manage-rig22/manage-target27 and transient position31 follow the Tonight chooser flow; site coordinate picker32 stays with the Library site editor. Welcome40 is grouped with Settings as global setup, although its actual route is first-run `/welcome`, not a Settings child. This is canvas organization, not a navigation or route change. Existing stable numbering remains unchanged.

Coverage conclusion: all40 agreed default screen/context entries are present, plus the authorized Weather alternative, for41 frames. Current source review reconciled `lib/presentation/navigation/app_router.dart`, `lib/presentation/screens/home/session_planner_route.dart`, `lib/presentation/screens/settings/settings_screen.dart`, `lib/presentation/screens/home/plan_rig_screen.dart`, `lib/presentation/screens/home/plan_target_screen.dart`, `lib/presentation/screens/sites/sites_screen.dart`, `lib/presentation/screens/sites/site_editor_screen.dart`, `lib/presentation/screens/location/location_picker_screen.dart` and the full-page-class search under `lib/presentation/screens/`. Imperative editor/settings/license contexts remain included in the numbered queue. `HomeScreen` is the Plan body behind `SessionPlannerRoute`, not an additional missing base screen.

Literal all-state application coverage is not complete: `lib/main.dart` can launch `UnsupportedDatabaseApp` from `lib/presentation/screens/startup/unsupported_database_screen.dart`; that technical error screen is absent from this base-screen page and was explicitly excluded from the approved queue. Modal/system dialogs and alternate loading/empty/error/offline/scaled/theme states are not separate base frames here. No missing technical/state screen was created by this grouping request. The current page is ready for owner review; prior product QA limits below remain unchanged.

## Audit-fix waves — current checkpoint — 2026-11-06

Owner objective: `C:\Users\zalub\.codex\attachments\bb632de0-5cef-4f8a-9430-2a31cc7c8027\goal-objective.md`. This section owns the new work's status; the earlier base-screen dimensions and QA remain historical until replaced by a fresh wave receipt.

Approved structural decisions: catalogue roots6/8/24/27 become375×812 scrolling mobile frames while retaining96/164 ordered records;8 has a fixed bottom Apply action and a compact introduction;14 combines Search and Filters under one outline. Preserve data and explanatory meaning; the approved introduction shortening, compact duration/axis notation and duplicate Outcome16/Theme34 removal are recorded below. Tonight1, Plan2 and Privacy36 remain unchanged references; do not shorten Licenses39.

| Wave | Authorized scope | Current evidence / status |
| --- | --- | --- |
| 1 | Scoped ActionRow adaptation from56:4938 on33,18,19,22,28; short-value FactRow on20,25 and slider values35 | Applied. One property/content/protection pass: PASS, zero errors, four protected PNGs identical. One Terra crop review: PASS within recorded crop limits. |
| 2 | Mobile catalogues6,8,24,27; search hint24; one map31–32 and chooser-return27 check | Applied. One property/content pass PASS, zero errors,96/164/164/164 ordered rows retained. One Terra crop review scoped PASS. Preview confirmed end-of-list scrolling/fixed Apply and8→27→8 with restored scroll. Runtime map tiles remain unverified. |
| 3 | Forms10–13; result15–17; Welcome40; Night3; Moon4; Weather5V2; Search14; site actions30; Appearance34; About38 | Applied17 change groups, zero apply errors. One programmatic pass found44 inherited NONE-wrapper findings; targeted repair resolved7 owners and classified34 fixed-vector wrappers, zero unresolved findings. One Terra visual pass PASS over all15 native-width PNG heights. |

Execution limits: one sequential writer; exactly one programmatic verification and one Terra375×812 crop review per completed wave. A nested-node API failure allows at most one retry, then record the exact node and continue. Do not repeat a blocked whole-tree walk or promote a recorded limit to a pass. Authoring and review artifacts belong under `build/figma-audit-fixes-20261106/`; no Scripter-library export is required for PNG review.

Historical operational observation: a bounded live read produced `preflight-wave1.json`. A subsequent deep read/font setup did not complete and Scripter remained in the running state; Stop and close actions did not yield a confirmed closed plugin. The owner restarted Figma and Scripter. Fresh readback found no persisted audit-fix registry or adapted masters from that stalled attempt. Authoring resumed through short, native Plugin API scripts inside Scripter; a loopback-only task artifact bridge saves JSON/native1×PNG directly without exporting the Scripter script library. Cloud synchronization is not inferred from local readback.

**Historical preparation, superseded by applied wave receipts:** the first local scripts were guarded drafts, not Figma evidence; the Wave3 draft left3/5V2/10/13 unresolved. At that point all scripts passed syntax checks, instruction check passed27skills/49Markdown/zero errors and the contract validator passed482local links/zero errors. Those preparation checks did not prove live selection or completion. After the owner restart, bounded readback established the actual state before revised sequential writes; no blocked whole-wave retry was used.

Wave1 owners are scoped ActionRow `203:16476` (lineage56:4938/56:4898) and short-value FactRow `203:16572` (lineage57:6745/57:6721), preserving the original shared owners. New dimensions:18=535,19=704,20=862,22=510,25=912,28=426,33=681,35=1804, all375px wide. Source text counts/geometry passed; Tonight1, Plan2, Privacy36 and Licenses39 nativePNG fingerprints match baseline4/4. Evidence: `wave1-baseline.json`, `wave1-verification.json`, eight `wave1-screen-*.png`, `wave1-visual.json` in the task artifact directory. Terra inspected native375×812 crops;20/25 below812 and35 below1624 were outside that visual scope. No native accessibility or runtime acceptance is claimed.

Wave2 keeps the same registered roots6/8/24/27, now375×812. The full lists remain in their original source order; root6 scrolls its linked browser, while8/24/27 use a clipped vertical content flow. Apply8 is an Auto Layout sibling outside the scrolling flow; no absolute positioning or floating footer is used. The shortened8 introduction retains164bundled,0Library,164results, selectedM31/Andromeda and copy-to-plan meaning. Search24 places the complete examples below a single-line prompt. Screen27's readable two-line placeholder remains a nonblocking existing difference, outside the explicitly approved24 hint correction; Terra's report retains that observation without another visual pass. Existing map confirmations31=`198:67197`,32=`198:67325` and source375×535 map leaves remain intact. Evidence: `wave2-apply-report.json`, `wave2-verification.json`, six `wave2-screen-*.png`, `wave2-visual.json`, `wave2-preview.json`. This does not prove arbitrary input, live selection, map tiles, recomputation or native persistence.

Wave3 improves populated values/helpers10–13, groups Partly with actual integration15, hides one duplicate Outcome16 and Theme34, adds target/filter total headings17, compacts Welcome40's preserved introduction and separates selected site/rig facts. Search14 reuses the local6 contour around the existing input and Filters action; the separate centered Filters row is gone. Current position/Map30 are explicit outlined48px actions; About38's four source links are left aligned. These are local hierarchy/geometry choices, not changes to recorded results, plan adoption or runtime capability. Forms masters remain10=`193:12048`,11=`195:102125`,12=`195:102345`,13=`195:102505`,14=`195:103062`,15=`195:104692`,16=`195:105372`,17=`195:105668`,30=`198:66746`,34=`198:67572`,38=`198:68524`,40=`198:68904`.

Night3 time-browser family `126:37462` uses16px groups and places its quiet instruction after the timeline. Moon4 month master `134:38661` retains31dates, phases, selected night,48px day targets and exact computed minutes in single-line h/m notation with a legend. Weather5V2 family `145:5636` hides only odd-hour axis labels; all11hourly samples, guides, shared-cursor targets, scales, G2 geometry and exact T1 table remain. Graphics/hour-target hashes match their before baselines. Choosing two-hour label cadence while keeping one-hour data and using h/m compact text are disclosed authoring judgments within the requested density correction. Native root heights, all375px wide:3=1184,4=1924,5V2=2002,10=1464,11=1320,12=1062,13=1968,14=1593,15=1840,16=1584,17=1106,30=980,34=1472,38=1832,40=1328.

The single Wave3 property/content gate initially returned HOLD for44 inherited NONE wrappers. Local instance layout setters did not persist. A targeted owner read and one correction changed selected-tab masters `58:4006`/`58:4018`/`58:4030` and four empty calendar slots `134:38681`/`134:38682`/`134:38683`/`134:38998`; no whole-wave gate was repeated. The other34 findings are proven fixed vector-only wrappers:31phase glyphs20×20 and three48×48 appearance controls with a20×20 vector child, without UI text. Existing source timelines/plots retain their scientific drawing coordinates; no manual UI x/y was added. The exact exception/finding IDs are in `wave3-targeted-repair.json` (PASS,zero unresolved errors), not silently treated as ordinary UI Auto Layout. Protected PNGs still match4/4 after the master correction.

Wave3 evidence: `wave3-forms-apply-report.json`, `wave3-science-apply-report.json`, original `wave3-verification.json`, `wave3-targeted-repair.json`,15 original `wave3-screen-*.png` and SHA-bound `wave3-visual.json`. Terra's one pass covers full PNG heights with overlapping375×812 crops and found no visible clipping/overlap. Search14's readable two-line hint is nonblocking. PNG15/16/17/30/34 have transparent export tails beyond their frame height; offline `wave3-export-bounds.json` proves all excess alpha is0 and alpha bounds equal the recorded root dimensions. Original PNGs were preserved; this is export evidence, not a second Figma gate or viewport test.

| Available manual check | Result / remaining boundary |
| --- | --- |
|8 fixed Apply at start/end of complete catalogue | Observed in actual Preview; footer stays visible after scrolling to the final record. |
|8→27→8 chooser return | Observed in actual Preview, including restored scroll. Arbitrary input/selection/adoption not tested. |
|31/32 selected coordinate and confirmation | Static point/coordinate/control checked once; existing explicit Use point retained. External map tiles, live panning and geolocation remain unverified runtime work. |
|Targeted visual/layout corrections in the three waves | One property pass and one scoped Terra pass per wave; targeted repairs retain their original HOLD/error history. No repeated full-wave or visual loop. |

Source ownership inspected in this audit-fix work (root and delegated read-only preparation): `lib/presentation/screens/settings/settings_screen.dart`, `lib/presentation/screens/library/library_screen.dart`, `lib/presentation/screens/equipment/equipment_selection_screen.dart`, `lib/presentation/screens/equipment/rig_detail_screen.dart`, `lib/presentation/screens/target/target_detail_screen.dart`, `lib/presentation/screens/sites/sites_screen.dart`, `lib/presentation/screens/home/plan_target_screen.dart`, `lib/presentation/screens/target/target_selection_screen.dart`, `lib/presentation/screens/location/location_picker_screen.dart`, `lib/presentation/navigation/app_router.dart`, `lib/presentation/screens/execution/results_screen.dart`, `lib/presentation/screens/logbook/session_detail_screen.dart`, `lib/presentation/screens/logbook/progress_screen.dart`, `lib/presentation/screens/sites/site_editor_screen.dart`, `lib/presentation/screens/about/about_screen.dart`, `lib/presentation/screens/welcome/welcome_screen.dart`, `lib/presentation/widgets/capture_plan/capture_block_dialog.dart`, `lib/presentation/widgets/capture_plan/calibration_preview_dialog.dart`, `lib/presentation/widgets/capture_plan/plan_overrides_editor.dart`. Existing scientific fixture/drawing baselines establish preservation here; no fresh astronomical recomputation is claimed. Source or fixture facts remain distinct from the disclosed hierarchy/notation choices above.

**Checkpoint:** all three authorized audit-fix waves are applied across29 numbered screens, within the scoped checks and limits above. All40 base-screen entries remain built; no extra screen/state or Flutter migration was created. Current work is ready for owner review. Native behavior, accessibility/text scaling, live map tiles, other prototype flows and cloud synchronization are not certified. The historical construction inventory below does not override these current dimensions or reopen an old stop instruction.

Final documentation checks,2026-11-06: instruction validator27skills/49Markdown/zero errors; contract validator485local links/zero errors; nine instruction unit tests passed; git diff --check passed. All19 listed source paths exist. Separate semantic review reconciled the current375×812 catalogue exception, navigation owner selection and two-hour-label/one-hour-data distinction across profile/strategy/geometry/Weather entrypoints; old dimensions and commands are explicitly historical. Structural validators do not establish that semantic result or live/native acceptance.

Revision AFTER-DARK-1.2. Completed owner authorization (2026-11-06): three sequential Figma waves covering DS/navigation/facts, mobile catalogues/maps, and forms/value hierarchy/local polish. The [audit-fix checkpoint](#audit-fix-waves--current-checkpoint--2026-11-06) records their applied scope, evidence and remaining limits; the later canvas grouping is also complete. The next Figma checkpoint is owner review, not another construction or audit pass. Preserve the palette, Tonight1, Plan2, Privacy36, Licenses39 baseline, all catalogue entries/order, source meaning and protected BEFORE. These Figma authorizations did not include Flutter migration or new state-screen expansion.

Historical construction authorization (2026-11-05): build ALL remaining default Dark screens11–40 with one sequential Figma Desktop/Scripter writer and rolling Terra review. That construction is complete; its inventory and scoped receipts below remain dated evidence. Candidates6 Preview contour remains a separately recorded unresolved limit under stop-loss.


### Historical authorization — 2026-11-04 transfer iterations

The owner authorized resolution of audited DS/skill mismatches, preservation of Tonight/Plan appearance and historical IDs, and transfer of Tonight to a separate page. The subsequent instruction authorized transfer of the ready Plan and a strategy for the remaining screens. Those transfer iterations are complete; they do not authorize creating Night.

Use [current authoring profile](AUTHORING_PROFILE.md), [source-reconciled numbered queue](research/ssot_audit_2026-11-04.md#numbered-base-screen-queue) and current source/fixture evidence. One default frame per numbered screen in the authorized batch; no additional state screens or modal substates. An existing component may retain its DS variants; that does not authorize new screen-state specimens.

For the owner-authorized Weather correction only, scoped DS interaction variants may represent ordinary date selection, uncovered-date content, V2 shared hour selection and complete details tables. They remain inside the two existing Weather roots; no extra queue entry or base-screen root is authorized.

### Historical construction inventory — dimensions superseded by audit-fix checkpoint above

| Item | Construction scope / dated state |
| --- | --- |
| Queue | 40 source-reconciled screen/context entries; removed PlanContext and Unsaved dialog excluded. |
| Screen 1 | Tonight, source `84:34120`; continued by owner to Plan, not a native/release acceptance claim. |
| Screen 2 | Plan, source `84:34506`; copy `123:47546`; owner continued to Night. Same 19 Oct 2026 Kyiv fixture. |
| Screen 3 | Night, `/night`; root `126:1679`, 375×1172 Hug-content after critical QA; owner authorized continuation to Moon. |
| Screen 4 | Moon, `/moon`; same root `126:37897`, 375×1894 Hug-content; full-month overview restored; owner authorized continuation to Weather. |
| Screen 5 | Weather V1 `134:39493`, 375×1373; V2 `143:2357`, G2 hybrid 375×2002 Hug-content. Both retain T1; the edge-clearance and cross-screen QA receipt below records current verification. |
| Screen 6 | What can I image?, `/tonight/candidates`; root `173:54116`, 375×10166, option A with corrected Weather-style chrome and glyphs; Preview contour defect remains, all 96 source-backed rows; inline filters closed and query blank by default. In review. |
| Screen7 | Choose site, root `193:10810`, master `193:9685`,375×508; built; final scoped Terra PNG QA passed. |
| Screen8 | Choose target, root `193:10882`, master `193:9769`,375×12702; complete164 rows; built; final scoped Terra PNG QA passed. |
| Screen9 | Choose rig, root `193:11918`, master `193:11997`,375×470; built; final scoped Terra PNG QA passed. |
| Screen10 | Capture block editor, root `193:12576`, master `193:12048`,375×1464; built; final scoped Terra PNG QA passed. |
| Output | Forty numbered default Longreads plus one authorized Weather alternative; all 375 px wide. All 30 new final PNGs have exact-SHA256-bound scoped Terra passes. Historical output evidence remains preserved. |
| Default | Saved record, accepted site/target/rig and forecast facts; appearance Off; dark-start selected; Exact times closed. Preserve truthful Unknown/provenance. |
| Components | Tonight uses canonical identity, Your plan, NightAhead, Moon/Weather, RootTabs and existing Discover ActionRow. Plan uses canonical app bar, identity, FitAnswer, Inputs, Capture plan, Estimate, NightAhead, Conditions and persistence footer. |
| Verification | Fresh source/BEFORE/resource guards; both accepted pilot PNGs unchanged; new Tonight PNG matches source; actual master links; visible full-screen review and scoped Preview. |
| New page / roots | `118:47297` — Redesign · Dark · Base screens. Tonight `118:47298`; Plan `123:47546`; Night `126:1679`; Moon `126:37897`; Weather V1 `134:39493`; Weather V2 `143:2357`; Candidates `173:54116`; Choose site `193:10810`; Choose target `193:10882`; Choose rig `193:11918`; Capture block editor `193:12576`; The additional30 roots/masters are owned by the current11–40 receipt below;41roots represent40queue entries including the authorized Weather alternative. |
| Checkpoint | All 40 numbered defaults are built and ready for owner review. New 11–40 inventory: 30 screens, zero errors; source text: 994/994; actual catalogues: 164 rows each; closed DS bodies: 17/17; geometry/completeness: zero errors. Final 14 AppBar has a verified 48×48 action, no painted overflow and a fresh scoped PNG pass. Candidates 6 Preview contour remains a separate explicit limit. |
| Preparation | Moon mapping and final semantic review used GPT-6 Astra medium; Terra reviewed final PNGs. Historical Night high-effort receipts are superseded for future model selection by the strategy low/medium rule. |

The earlier audit HOLD, S1–S5 resolution and per-screen/batch authorizations are historical evidence in [WORKFLOW](WORKFLOW.md) and the archived receipts. The completed construction statuses below do not override the current checkpoint above or authorize another batch. A document validator does not establish product acceptance; future explicitly authorized Figma tasks follow the [strategy](REDESIGN_STRATEGY.md).

Historical receipt index: the headings below preserve existing link targets. Their completed instructions and intermediate statuses are superseded by the current checkpoint above; original IDs, decisions, evidence and limitations remain in the linked receipts. Current selections belong to [the profile](AUTHORING_PROFILE.md), scientific displays to [data display](components/data_display.md), Weather to [its screen contract](screens/weather.md), and search/navigation to [forms](components/forms.md) and [navigation](components/navigation.md). Candidates6 Preview contour remains unresolved as recorded above.

## Plan review receipt — 2026-11-04

[Archived receipt](../../_archive/cleanup_2026-11-06/docs/design/figma/REDESIGN_RUN.md#plan-review-receipt--2026-11-04).

## Historical Night (3) analytical preparation — superseded by authorized construction below

[Archived receipt](../../_archive/cleanup_2026-11-06/docs/design/figma/REDESIGN_RUN.md#historical-night-3-analytical-preparation--superseded-by-authorized-construction-below).

### Step 1 — current source and dependencies

[Archived receipt](../../_archive/cleanup_2026-11-06/docs/design/figma/REDESIGN_RUN.md#step-1--current-source-and-dependencies).

### Step 2 — selected populated fixture

[Archived receipt](../../_archive/cleanup_2026-11-06/docs/design/figma/REDESIGN_RUN.md#step-2--selected-populated-fixture).

### Step 3 — Advisor-reviewed canonical mapping

[Archived receipt](../../_archive/cleanup_2026-11-06/docs/design/figma/REDESIGN_RUN.md#step-3--advisor-reviewed-canonical-mapping).

## Historical Night (3) construction receipt — 2026-11-04; superseded checkpoint

[Archived receipt](../../_archive/cleanup_2026-11-06/docs/design/figma/REDESIGN_RUN.md#historical-night-3-construction-receipt--2026-11-04-superseded-checkpoint).

## Historical owner correction — Tonight/Plan block structure, 2026-11-04; superseded selection size/checkpoint

[Archived receipt](../../_archive/cleanup_2026-11-06/docs/design/figma/REDESIGN_RUN.md#historical-owner-correction--tonightplan-block-structure-2026-11-04-superseded-selection-sizecheckpoint).

## Night critical QA and Moon (4) receipt — 2026-11-04 to 2026-11-05

[Archived receipt](../../_archive/cleanup_2026-11-06/docs/design/figma/REDESIGN_RUN.md#night-critical-qa-and-moon-4-receipt--2026-11-04-to-2026-11-05).

## Historical owner correction — BEFORE functional preservation, 2026-11-05; repair completed below

[Archived receipt](../../_archive/cleanup_2026-11-06/docs/design/figma/REDESIGN_RUN.md#historical-owner-correction--before-functional-preservation-2026-11-05-repair-completed-below).

## Moon month repair and Weather (5) delivery — 2026-11-05

[Archived receipt](../../_archive/cleanup_2026-11-06/docs/design/figma/REDESIGN_RUN.md#moon-month-repair-and-weather-5-delivery--2026-11-05).

## Historical Weather V2 preparation and browser recovery — 2026-11-05; superseded by delivery below

[Archived receipt](../../_archive/cleanup_2026-11-06/docs/design/figma/REDESIGN_RUN.md#historical-weather-v2-preparation-and-browser-recovery--2026-11-05-superseded-by-delivery-below).

## Historical first Weather V2 delivery — 2026-11-05; owner requested structural revision

[Archived receipt](../../_archive/cleanup_2026-11-06/docs/design/figma/REDESIGN_RUN.md#historical-first-weather-v2-delivery--2026-11-05-owner-requested-structural-revision).

## Historical owner-selected I2+C3 revision — 2026-11-05

[Archived receipt](../../_archive/cleanup_2026-11-06/docs/design/figma/REDESIGN_RUN.md#historical-owner-selected-i2c3-revision--2026-11-05).

## Historical correction preparation — 2026-11-05; Desktop execution below supersedes the access blocker

[Archived receipt](../../_archive/cleanup_2026-11-06/docs/design/figma/REDESIGN_RUN.md#historical-correction-preparation--2026-11-05-desktop-execution-below-supersedes-the-access-blocker).

## Weather selected-date correction — 2026-11-05

[Archived receipt](../../_archive/cleanup_2026-11-06/docs/design/figma/REDESIGN_RUN.md#weather-selected-date-correction--2026-11-05).

## Weather approved copy pass — 2026-11-05

[Archived receipt](../../_archive/cleanup_2026-11-06/docs/design/figma/REDESIGN_RUN.md#weather-approved-copy-pass--2026-11-05).

## Weather selected-reference implementation — 2026-11-05

[Archived receipt](../../_archive/cleanup_2026-11-06/docs/design/figma/REDESIGN_RUN.md#weather-selected-reference-implementation--2026-11-05).

## Weather hourly labels and table density — 2026-11-05

[Archived receipt](../../_archive/cleanup_2026-11-06/docs/design/figma/REDESIGN_RUN.md#weather-hourly-labels-and-table-density--2026-11-05).

## Weather G2+T1 selected implementation — 2026-11-05

[Archived receipt](../../_archive/cleanup_2026-11-06/docs/design/figma/REDESIGN_RUN.md#weather-g2t1-selected-implementation--2026-11-05).

## Weather edge clearance and cross-screen QA — 2026-11-05

[Archived receipt](../../_archive/cleanup_2026-11-06/docs/design/figma/REDESIGN_RUN.md#weather-edge-clearance-and-cross-screen-qa--2026-11-05).

## Historical Candidates (6) initial implementation — superseded by option A

[Archived receipt](../../_archive/cleanup_2026-11-06/docs/design/figma/REDESIGN_RUN.md#historical-candidates-6-initial-implementation--superseded-by-option-a).

## Candidates option A — selected implementation, 2026-11-05

[Archived receipt](../../_archive/cleanup_2026-11-06/docs/design/figma/REDESIGN_RUN.md#candidates-option-a--selected-implementation-2026-11-05).

## Candidates context search and geometry QA — 2026-11-05

[Archived receipt](../../_archive/cleanup_2026-11-06/docs/design/figma/REDESIGN_RUN.md#candidates-context-search-and-geometry-qa--2026-11-05).

## Candidates Notion search — 2026-11-05

[Archived receipt](../../_archive/cleanup_2026-11-06/docs/design/figma/REDESIGN_RUN.md#candidates-notion-search--2026-11-05).

### Historical/Superseded construction hold — active Preview contour remains unresolved

[Archived receipt](../../_archive/cleanup_2026-11-06/docs/design/figma/REDESIGN_RUN.md#historicalsuperseded-construction-hold--active-preview-contour-remains-unresolved).

## Candidates chrome and icon QA — 2026-11-05

[Archived receipt](../../_archive/cleanup_2026-11-06/docs/design/figma/REDESIGN_RUN.md#candidates-chrome-and-icon-qa--2026-11-05).

### Historical/Superseded screen7 conditional preparation

[Archived receipt](../../_archive/cleanup_2026-11-06/docs/design/figma/REDESIGN_RUN.md#historicalsuperseded-screen7-conditional-preparation).

## Stage C batch1 — pipeline authorization2026-11-05

[Archived receipt](../../_archive/cleanup_2026-11-06/docs/design/figma/REDESIGN_RUN.md#stage-c-batch1--pipeline-authorization2026-11-05).

## Stage C batch1 delivery and QA — 2026-11-05

[Archived receipt](../../_archive/cleanup_2026-11-06/docs/design/figma/REDESIGN_RUN.md#stage-c-batch1-delivery-and-qa--2026-11-05).

## All remaining screens11–40 — owner authorization2026-11-05

Historical/Superseded: this authorization covered the now-completed 11–40 Figma construction, including parallel preparation, one UI writer and rolling Terra review. Its complete instructions and evidence remain in the [original run record](../../_archive/cleanup_2026-11-06/docs/design/figma/REDESIGN_RUN.md); the current owner-review checkpoint above governs this Figma run. It is not a request to start another batch.


## Remaining screens 11–40 — current verification checkpoint — 2026-11-06

**Historical construction receipt:** the heading/anchor is retained for existing evidence links. Its output IDs remain preserved, but dimensions, selected navigation masters and active work status are superseded where changed by the audit-fix checkpoint at the top of this file. It does not authorize another batch or override the later scoped verification limits.

All 30 authorized remaining default Dark frames are built and ready for owner review. They were authored sequentially in Figma Desktop/Scripter after parallel current-source and complete-BEFORE preparation. These use dated synthetic fixtures; no fresh Flutter/native execution is claimed. The page contains 41 product roots: 40 numbered defaults plus the authorized Weather alternative.

One current original 1× PNG per screen is selected in `build/figma-remaining-20261105/final-png-manifest.json`, with dimensions, byte lengths, SHA256 and exact matching scoped Terra receipts. Corrected 13/15/21 use their `-qa` exports. Historical PNGs, pre-map-repair exports and failed authoring evidence remain preserved. No Flutter migration, extra product state, commit or push was performed.

| Screen | Root / adopted central master | Final original 1× PNG | Dimensions |
| --- | --- | --- | --- |
| 11 | `195:102262` / `195:102125` | `build/figma-remaining-20261105/after/11-build-calibration-frames.png` | 375×1386 |
| 12 | `195:102441` / `195:102345` | `build/figma-remaining-20261105/after/12-plan-assumptions.png` | 375×1014 |
| 13 | `195:102835` / `195:102505` | `build/figma-remaining-20261105/after/13-planning-settings-qa.png` | 375×2108 |
| 14 | `195:103274` / `195:103062` | `build/figma-remaining-20261105/after/14-logbook.png` | 375×1619 |
| 15 | `195:105202` / `195:104692` | `build/figma-remaining-20261105/after/15-andromeda-galaxy-qa.png` | 375×1844 |
| 16 | `195:105559` / `195:105372` | `build/figma-remaining-20261105/after/16-how-did-it-go.png` | 375×1618 |
| 17 | `195:105790` / `195:105668` | `build/figma-remaining-20261105/after/17-progress-by-target.png` | 375×986 |
| 18 | `195:103579` / `195:103491` | `build/figma-remaining-20261105/after/18-library.png` | 375×535 |
| 19 | `195:103752` / `195:103650` | `build/figma-remaining-20261105/after/19-rigs.png` | 375×686 |
| 20 | `195:104105` / `195:103814` | `build/figma-remaining-20261105/after/20-rig-record.png` | 375×1082 |
| 21 | `195:104524` / `195:104235` | `build/figma-remaining-20261105/after/21-rig-editor-qa.png` | 375×2058 |
| 22 | `197:9540` / `197:9454` | `build/figma-remaining-20261105/after/22-manage-rigs-over-chooser.png` | 375×504 |
| 23 | `197:9622` / `197:9592` | `build/figma-remaining-20261105/after/23-add-from-a-photo.png` | 375×342 |
| 24 | `197:12166` / `197:9650` | `build/figma-remaining-20261105/after/24-targets.png` | 375×11968 |
| 25 | `197:13636` / `197:13518` | `build/figma-remaining-20261105/after/25-target-record.png` | 375×1088 |
| 26 | `198:62508` / `198:13707` | `build/figma-remaining-20261105/after/26-target-editor.png` | 375×1090 |
| 27 | `198:65093` / `198:62578` | `build/figma-remaining-20261105/after/27-manage-targets-over-chooser.png` | 375×11968 |
| 28 | `198:66504` / `198:66445` | `build/figma-remaining-20261105/after/28-sites.png` | 375×436 |
| 29 | `198:66676` / `198:66547` | `build/figma-remaining-20261105/after/29-kyiv-outskirts.png` | 375×686 |
| 30 | `198:66995` / `198:66746` | `build/figma-remaining-20261105/after/30-edit-site.png` | 375×976 |
| 31 | `198:67202` / `198:67125` | `build/figma-remaining-20261105/after/31-choose-a-position.png` | 375×1001 |
| 32 | `198:67330` / `198:67253` | `build/figma-remaining-20261105/after/32-pick-on-map.png` | 375×1001 |
| 33 | `198:67489` / `198:67381` | `build/figma-remaining-20261105/after/33-settings.png` | 375×817 |
| 34 | `198:67677` / `198:67572` | `build/figma-remaining-20261105/after/34-appearance.png` | 375×1506 |
| 35 | `198:68089` / `198:67761` | `build/figma-remaining-20261105/after/35-planning-defaults.png` | 375×1944 |
| 36 | `198:68309` / `198:68253` | `build/figma-remaining-20261105/after/36-privacy.png` | 375×354 |
| 37 | `198:68486` / `198:68432` | `build/figma-remaining-20261105/after/37-backup-data.png` | 375×488 |
| 38 | `198:68674` / `198:68524` | `build/figma-remaining-20261105/after/38-about.png` | 375×1832 |
| 39 | `198:68790` / `198:68764` | `build/figma-remaining-20261105/after/39-open-source-licences.png` | 375×198 |
| 40 | `198:69019` / `198:68904` | `build/figma-remaining-20261105/after/40-welcome-setup.png` | 375×1352 |

Strict live inventory readback passed 30 screens with zero errors: actual registered root/master IDs, frame names, exact dimensions, page ownership and direct master links match the local export inventory. The expected inventory initially transcribed two masters incorrectly; actual 25 master `197:13518` and 28 master `198:66445` are now recorded correctly. `live-readback.json` and `verify-live-readback.js` preserve the check; actual evidence is in page pluginData `RemainingLiveReadback`. The final 14 AppBar correction retained the same registered output IDs, frame name and dimensions.

Actual visible TEXT comparison passed 994/994 source-required fragments using whitespace normalization only. The 16 Integration label and its complete recorded/planned value are separate source nodes; their association remains a distinct group check rather than an invented colon. Catalogues 24 and 27 each match all 164 ordered source labels and type captions. Actual closed Disclosure Body instance-swap components, rather than annotation text, match all 17 prepared source inventories. Contracts, source paths, fixtures, full BEFORE evidence and conditional capabilities remain in the existing six `specs-*.json` and three `content-audit-*.json` files. Chunked actual readback is stored as `RemainingContentAudit` and `RemainingCompleteness` on page `118:47297`.

Two final structural repairs matter for reuse. The 15 Plan-as-saved object inventory had not produced a real Body; actual component `198:69633` now contains 61 TEXT nodes across Night, Site, Target, Rig, Budget and Weather, including the Taken/read-only disclaimer. Values come from the saved source/BEFORE fixture, preserving dated +6 markers, unknowns and saved weather provenance. The final 14 Appearance swap initially retained a 14.99×20 instance override despite its 48×48 main component. A fresh proven 33 AppBar clone (`198:70015`) with Logbook/no-leading resolved the defect. Actual Appearance target bounds are now 48×48 with no painted overflow.

`build/figma-remaining-20261105/final-structural-ui.png` records geometry zero errors/zero warnings, completeness zero errors, closed bodies 17/17 and the actual 48×48 action. Scientific/map/slider vectors are excluded from glyph-only bounds assertions and retain their source geometry and scoped visual checks. Maps 31/32 use the actual 375×535 native map leaf below AppBar, outside the 24 px reading gutters; no tiles or geographic data were fabricated. Protected guards pass 14/14 using the authoritative reviewed Capture-block-editor baseline (55,885 bytes). The earlier 54,215-byte comparison was an obsolete baseline, not a product regression. Loose failed-authoring nodes and the failed 40 master remain hidden recovery evidence in the DS page. No Flutter diff is present.

All 30 current PNGs have exact-SHA256-bound scoped Terra passes. The last 14 export is bound to `qa-final14-proven-bar.json`, SHA256 `18213ea6bab36ce53e5bb96d19f362580322d693a0df4162565ddbad8bfd107c`. Previous 14/21/31/32 blocker receipts remain explicitly historical beside their targeted correction receipts. The 15 closed-body repair leaves its default PNG unchanged; its body completeness is separate structural evidence, not proof of expanded visual or prototype behavior.

Presentation judgments include source-specific adopted masters, source-backed choice rows, quiet actions, 24 px document gutters and raised groups. Settings 33 uses canonical ActionRow `56:4938` for five destinations with complete captions and trailing chevrons; absent source leading icons remain a visual qualification. Screen 35 endpoints preserve source units and decimal formatting. Screen 40 keeps all new-rig classes unchosen and both creation methods disabled despite an existing saved rig. Screen 39 matches the empty frozen-host licence registry; the separately extracted production build registry is dated evidence rather than default product content.

Static PNG review, actual Figma properties, source/BEFORE reconciliation and runtime evidence remain separate. Missing Enabled properties cannot prove callbacks through full opacity. The focal-ratio field's 0.7 opacity does not establish read-only enforcement. Screen 26's collapsed Galaxy value is actual TEXT; six alternate options remain source inventory until expansion is tested. Actual root-tab parent/child properties must be distinguished from visible tab labels. `verify-static-state-limits.js` records this evidence without promoting annotations or presentation to behavior.

No full-route callbacks, arbitrary input, live recomputation, persistence, swipe/confirmation, expanded-dialog behavior, Android runtime, accessibility, 200% text or owner acceptance is established. Candidates 6's earlier Preview contour limit remains separately unresolved. This completed static batch does not silently satisfy those criteria or authorize more product states.
