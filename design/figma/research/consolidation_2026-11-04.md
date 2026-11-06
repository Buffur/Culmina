# Accepted pilot component consolidation — 2026-11-04

Scope: consolidate the accepted AFTER-DARK-1.2 Tonight and Plan compositions into canonical After resources and linked instances. Preserve appearance, content, hidden content, existing states, source/BEFORE and Flutter. No new screen batch or production migration.

## Canonical ownership

Exact live IDs and nested placement ownership are recorded in the [binding manifest](consolidation_bindings_2026-11-04.json). Placement IDs inside subsequently composed patterns belong to their canonical masters; the screen instances inherit those nested bindings.

The [adopted canonical resources](https://www.figma.com/design/OeDvjQ58cWoHOCSMd69GCG/Culmina?node-id=118-37186) live on After: Design System under `After/Adopted`. These supersede conflicting older pilot recipes for the two accepted compositions. The earlier catalog remains available with its state coverage and historical visual treatment; it was not globally restyled. Existing matching ActionRow, Disclosure, icon/action and other dependencies remain linked to their catalog masters.

The initial conversion replaced 45 placements with instances backed by 38 accepted recipes. These include shared light primary Action, compact Saved, inset SectionHeading and four text-configurable EstimateMetric instances; contextual FitAnswer, capture block, tracking/remedy, command group, estimate disclosures, context selectors and chrome; and composed screen patterns. Nested layout frames remain inside their masters. The two screen roots and document flow frames retain their IDs. Direct visible document sections are instances rather than detached local compositions.

The shared light primary Action retains Open planner / Save plan content, widths and existing reactions. It does not restyle the 48 existing catalog Action variants. Text properties expose accepted own text, including hidden text; nested instances retain their own component properties. Distinct semantic/contextual recipes are not forced into one visual variant solely because their bounding boxes match.

Navigation has a canonical [RootTab set](https://www.figma.com/design/OeDvjQ58cWoHOCSMd69GCG/Culmina?node-id=118-39921), 24 states: four destinations × selected/unselected × default/focused/pressed. The accepted 20px Lucide glyphs, 8px rectangular active surface, labels and equal targets are retained. Focus/pressed paint recipes reuse the existing catalog states. The [RootTabs set](https://www.figma.com/design/OeDvjQ58cWoHOCSMd69GCG/Culmina?node-id=118-40042) has four selected variants configurable in the Design panel. No new tab-selection prototype links are added to the accepted Tonight; the original catalog links remain intact. Destination labels are fixed by the destination variant, avoiding merged text-property defaults.

Both appearance controls now use one two-state Moon master family (`99:41065`, `99:41070`) on the DS page. The duplicate Plan family is retained as labeled history. The original 12 timeline masters retain their IDs and 24 links on the DS page (`93:38045`, `93:38514`). NightAhead patterns own the outer six-state transitions in each context so interactive height changes cross the new instance boundary. The timeline content and three event choices remain unchanged.

## Screen / state / component / route matrix

Routes below are read from the current [router](../../../lib/presentation/navigation/app_router.dart). They describe product destinations; component-state playback is not evidence that every route has a completed Figma destination.

| Surface | Canonical binding | Retained state/content | Product entry / destination |
| --- | --- | --- | --- |
| Tonight identity | Tonight identity → heading, shared appearance, ContextSelectors → Site/Night controls | Viewed night, selected site, zone; appearance Off/On | `/tonight`; site chooser `/select/site`; night detail `/night` |
| Tonight saved plan | Your plan → PlanRecord, shared Saved, Tonight FitAnswer, shared light primary Action | Saved distinct from fit; target/rig, needed/usable time; Open planner | `/session/current`, root overlay above tabs |
| Tonight night ahead | NightAhead / Tonight → ActionRow + existing timeline | Three selected events × Exact times closed/open; dated markers, remaining dark | Night detail `/night`; component-state playback local |
| Tonight Moon/Weather | Moon and weather → existing ActionRow instances | Phase, illumination, moon-free interval, forecast and provenance | `/moon`, `/weather` |
| Tonight Discover | Existing ActionRow instance | Accepted title and prompt | `/tonight/candidates` |
| Root navigation | RootTabs → RootTab variants | Four labeled destinations, selected/focus/pressed | `/tonight`, `/sessions`, `/library`, `/settings` |
| Plan chrome/identity | Plan app bar, shared appearance, Plan identity → shared Saved | Back, menu, viewed/end night, Saved | `/session/:id`; Back/draft guards remain product behavior |
| Plan fit/inputs | Plan FitAnswer; Plan inputs → four existing ActionRow instances | Fit figures and capture end; site/night/target/rig, warnings and provenance | `/select/site`, `/night`, `/select/target`, `/select/rig?for=plan` |
| Plan capture | Capture plan → CaptureBlock, Tracking, CaptureCommands | Full block facts; warning/remedy; Add/calibration/contextual Fill; existing hidden content | Plan editing/menu semantics retained; no new gestures implemented |
| Plan estimate | Estimate → shared EstimateMetric + three detail disclosures | Timing/storage/gain values, units, qualifications and hidden bodies | Local disclosure contracts; no invented calculations |
| Plan night ahead | NightAhead / Plan → ActionRow + existing timeline | Imaging lane plus Dark/Moon-free; same six event/disclosure combinations | `/night`; component-state playback local |
| Plan Conditions | Conditions → heading + existing Weather ActionRow and Sky Disclosure | Separate card, weather/provenance and Sky darkness closed/open | `/weather`; Sky darkness disclosure remains local |
| Plan persistence footer | Persistence footer → shared light primary Action | Explicit Save plan and supporting copy | Save/draft persistence remains separate from fit and recorded results |

Current fixture states are preserved. Catalog loading, empty, missing-input, Unknown, stale, error, changed/draft and other states remain in their existing families; this consolidation does not manufacture new full-screen fixtures or certify their visual adaptation to the accepted compositions.

## Verification and evidence

Control exports, structural snapshots, mutation scripts and receipts are saved locally in `build/figma-consolidation-20261104/`. Figma stores the chunked pre-change record as `ConsolidationBase*` and the canonical binding receipt as `ConsolidationReceipt` on UI Lab. Hidden recovery copies preserve the prior compositions. These records supplement the existing polish/navigation evidence rather than replacing it.

The first closed-state comparison produced byte-identical complete PNGs at 100%: Tonight 375×1367 and Plan 375×2580. All six source/BEFORE structural snapshots matched; all 116 variables and 19 text-style definitions matched. Verification is repeated after state repair and final restoration; the workflow records the final result.

Interactive verification must include the outer NightAhead state boundary, not only swapping the nested timeline master in the editor. The first Preview pass exposed merged tab text defaults and an inherited fixed-height nested transition; these were repaired before the final pass. Native, screen-reader, 200%, full-library visual acceptance and global Field Red propagation remain outside this task.

Final restored comparison passed: both complete PNGs byte-identical, 188/188 text records equal, six protected frames equal, variable/style definitions equal, 12/12 outer state layouts passed and 24/24 links valid. Scoped web Preview passed both Moon controls and both Exact times open/select/close flows. The editor was left at Plan Conditions at 100%, showing its canonical instance and Hug sizing. DS visual inspection covered the 24 adopted RootTab states; it does not certify every historical catalog specimen.

Decision record: the problem was detached accepted pilot recipes diverging from reusable DS resources. The benefit is one editable canonical owner with unchanged accepted appearance and content. Observable success is linked instance ownership plus matched exports and retained state playback, established above. Implementation checks pass; owner review of the consolidated artifact remains separate from the prior composition acceptance. Contract validation passed with 275 local links before this manifest link; instruction validation passed (27 skills, 49 files), all nine instruction-validator tests passed, and `git diff --check` passed. No Flutter checks were needed or claimed.
