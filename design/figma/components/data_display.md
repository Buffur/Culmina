# Data Display catalog

The [2026-11-04 canonical binding matrix](../research/consolidation_2026-11-04.md) records accepted pilot Saved, FitAnswer, EstimateMetric, capture/tracking, NightAhead and Conditions masters under `After/Adopted`. Original timeline IDs/state links and existing catalog dependencies are retained; outer NightAhead variants own interactive reflow across the new pattern-instance boundary.

Historical hierarchy rollout, 2026-11-01: catalog Section and SkyDarkness headings adopted the section-first title tier, superseding the older quiet sectionHeading treatment for true parent headings. The current parent/nested resolver is owned by [typography](../typography.md). Plan Fits and working study figures retain the value tier below their section title; scientific answers, axis labels, provenance and field-label/value semantics remain distinct. Earlier working specimens are preserved in a hidden archive; see [workflow](../WORKFLOW.md).

Revision: AFTER-DARK-1.2. All After names and adapter props below are **proposed contracts**, not new Dart APIs. Required props have no default; optional nullable fields/slots default null, optional lists default empty. Slot means nested visual content. The source computes values; Figma displays fixed evidence fixtures. Reference IDs resolve in [reference_mapping](../reference_mapping.md).

## Shared visual recipe

Parent section headings use screenTitle; nested record/detail/disclosure titles use nestedTitle; metadata uses caption. FitAnswer uses screenTitle in the standalone Plan block and nestedTitle inside Tonight Your plan, with value for figures and body explanation; density changes which existing facts are shown in the source fixture, never their truth. Keep summary specimens distinct from the full-detail pilot content. PlanState uses caption and its distinct state role.

Record Section components use surfaceSubtle, small radius, sm horizontal and md vertical inset, and sm internal gap; other record contracts retain their specified spacing; plain sections have no fill/outline wrapper. Fact rows use textSecondary labels/textPrimary values; provenance uses textTertiary. Capture warnings use Notice. Notices use body plus caption detail, appropriate semantic ink/wash for caution/error/success, and a plain neutral surface for information. Scientific data is never styled disabled merely because a value is unknown.

Weather rows use rowTitle for metric labels, value for readings and caption for coverage/timing notes. The forecast answer uses answerHeading; time labels and table values use caption with tabular figures, chart axes use dense. Table cell inset uses AppSpacing.cellY vertically and AppSpacing.sm horizontally; headers use rowTitle and may wrap. Timeline and charts preserve source geometry/series structure while binding the separate chart/sky roles; no generated trend or decorative smoothing is permitted. Plotting geometry is data-driven, not an opportunity for local spacing tokens.

## After/Data/Section

- **Purpose/props:** required `body:Slot`; `heading:String?`, `summary:String?`, `trailing:Slot?`; `surface:plain|record=plain`; `join:independent|previous|next|both=independent`.
- **States/actions:** static or containing actionable children; section itself is not clickable. Empty content uses a meaningful empty-state message supplied by the caller.
- **Current API:** [DocumentSection](../../../lib/presentation/shared/document_section.dart) requires children:List<Widget>, padding defaults AppSpacing.md, joinPrevious/joinNext default false. [HybridSectionTitle](../../../lib/presentation/shared/hybrid_parts.dart) takes text and optional trailing:String. New plain/record distinction is an After composition decision.
- **Figma:** Surface, Join, HasHeading/HasSummary; Heading/Summary text, Body/Trailing swaps. Vertical Auto Layout; record gets surfaceSubtle, small radius, sm horizontal/md vertical inset and screenTitle parent heading; nested titles use nestedTitle. Matched compact records retain their canonical insets; plain uses page canvas.
- **Reference:** R01 S01 section rhythm and R03 S24 C05/C13 bounded records. Do not frame every scientific explanation.

## After/Data/FitAnswer

- **Purpose/props:** required `state:FitState`; `needed:Duration?`, `usable:Duration?`, `reason:String?`, `missing:String?`; `keyNumbers:List<{label:String,value:String}>=[]`; `action:Slot?`; `density:summary|detail=detail`.
- **States/actions:** fits, tight, doesNotFit, noWindow, needsInput, nothingToFit; unknown durations stay unknown. Show numeric headline only when both durations are known; otherwise show the correct word and available facts. Remedies may choose missing input or fill/trim, using caller rules.
- **Current API:** [StatusBlock](../../../lib/presentation/shared/status_block.dart) requires state; needed/usable/reason/missing/action nullable; keyNumbers=[]; separateFigures=false; headingStyle/figuresBeforeReason nullable; fitLine=false. [PlanStatus](../../../lib/presentation/widgets/plan_status.dart) reads injected analysis/plan state and defaults showFillAction=true. It uses StatusBlock.headline; it is not simply an instance of StatusBlock.
- **Figma:** Verdict (all six states), Density, HasNeeded, HasUsable, HasReason, HasAction; Reason/Missing/Needed/Usable text; KeyNumbers nested FactRow and Action swaps. Use corresponding status role plus words/icon.
- **Reference:** R03 C05 hierarchy and C13 wrap behavior only. Fit semantics, remedies and scientific numbers are Culmina-owned; do not copy a Notion category tag as a verdict.

## After/Data/PlanState

- **Purpose/props:** required `state:PlanState`; `withIcon:bool=true`. No action slot.
- **States:** notSaved, saved, savedChanged, tracking, completed, partly, notDone, oldLog. Keep literal product wording from PlanState.word; never expose internal database вЂњdraftвЂќ as the user label.
- **Current API:** PlanState/PlanStateLabel in [plan_state](../../../lib/presentation/shared/plan_state.dart); PlanState.forWorkingPlan considers unsaved changes as well as stored state. withIcon=true here is an explicit After default, not a claim about the current constructor default.
- **Figma:** State variant (eight values), WithIcon boolean; state label is fixed per variant. Noninteractive, hug size; text remains readable without color.
- **Reference:** R03 C05 compact secondary metadata. Preserve saved/lifecycle meaning; never let a green label imply that a plan fits.

## After/Data/FactRow

- **Purpose/props:** required `label:String`, `value:String`; `emphasis:bool=false`, `caption:String?`, `provenance:String?`; `layout:auto|stacked=auto`.
- **States/actions:** known, unknown, partial, estimated and recorded are presented with words/provenance, never by numeric substitution. Read-only; navigation belongs in ActionRow.
- **Current API:** HybridFact(label,value,emphasis=false), HybridFacts(List<(String,String)>), HybridFactList(List<Widget>) in [hybrid_parts](../../../lib/presentation/shared/hybrid_parts.dart). Caption/provenance and layout are proposed composition slots/props, not current parameters.
- **Figma:** Layout, Emphasis, HasCaption, HasProvenance; Label/Value/Caption/Provenance text. Numeric value uses tabular figures. Auto layout follows the stacking rule in spacing_and_border.
- **Reference:** R03 S24 C13 for full wrapping, R04 S14 C12 for grouped row rhythm. Preserve units and evidence labels.

## After/Data/CaptureBlock

Current new-screen owner: `118:37313` and the named Capture/Tracking/command patterns in the [canonical index](../AUTHORING_PROFILE.md). The older `58:17778` family is historical state/API evidence. Its separate Edit/Move buttons are not a new-screen recipe. Tap-to-edit/hold-to-reorder remain design intent, with dots Edit/Remove + Undo; no new gestures are claimed implemented.

**Historical origin, local UI Lab study, 2026-11-01:** the owner-requested movable-block proposal replaces visible Edit/move buttons with tap-to-edit and hold-to-reorder. The latest owner decision limits the dots menu to **Edit block / Remove**, retaining Undo; Move up/down commands are excluded. One-block movement remains unavailable. Tracking is separate. Add block and Build calibration frames share a row; the full-width Fill the window action contains its own one-line proposal parameters. Estimate retains the paired 2Г—2 layout with four quiet metric surfaces. Its later owner correction binds inner surfaces to the existing scaffold role, shortens the local label to Relative gain and removes the spare label-line minimum; scientific qualifications remain intact. These local proposals do not change the shared catalog/API below or establish implemented gestures. See [workflow](../WORKFLOW.md) for acceptance scope and checks.

- **Purpose/props:** required `block:CaptureBlock`, `summary:String`, `settings:List<{label,value,origin}>`; `index:int` required; `canMoveUp:bool=false`, `canMoveDown:bool=false`; `onEdit:()в†’void`, `onRemove:()в†’void` required; `onMoveUp:()в†’void?`, `onMoveDown:()в†’void?`; `warnings:List<String>=[]`.
- **States/actions:** preserve light/calibration type, proposed/recorded/missing settings, capability warning and position semantics. New layouts use the accepted contextual Edit/Remove arrangement and retain Undo, with no Move up/down controls. The adapter's move callbacks below describe existing source behavior, not controls to add. Do not infer acquisition completion from planned frame count.
- **Current API:** [CapturePlanWidget](../../../lib/presentation/widgets/capture_plan_widget.dart) has blockActions:Widget? and includeSummary=true. Its private _BlockList composes the block rows; there is no public widget with the adapter signature above. [showCaptureBlockDialog](../../../lib/presentation/widgets/capture_plan/capture_block_dialog.dart) returns a block to its caller.
- **Figma:** FrameType, Position(first/middle/last/only), HasWarnings, Provenance; Summary/Filter/Exposure/Count text and nested settings rows; action swaps. Keep supported source fields, including ISO/gain, WB, AF/MF and tracking limitations.
- **Reference:** R03 S24 C05/C13 for a readable record with growing text; action arrangement from Culmina. Use restrained grouping, not tags for every capture setting.

## After/Data/NightTimeline

Current new-screen owner: adopted `93:38045` / `93:38514`, nested in outer NightAhead families `118:42629` / `118:43466` for correct reflow. These now live on DS, not only UI Lab. Existing family `58:32172` is historical synthetic-fixture coverage; its scrubber wording is not the new default. The current Figma selection is discrete, not a continuous scrubber implementation.

**Historical integration origin, 2026-11-03:** current After Tonight and Plan Longreads use A updated. Tonight has Dark and Moon-free dark; Plan additionally has Imaging window. Each context has six local component variants (three event selections, Exact times closed/open) and twelve CHANGE_TO links. Event selection synchronizes dated Preview, all markers and remaining-dark readout; closing retains the selection. These UI Lab components preserve the 303px/24h scale and fixture provenance. They do not alter the shared catalog or Flutter API below. See [workflow](../WORKFLOW.md) for integration QA and limits.

- **Purpose/props:** required `view:NightView`, `previewUtc:DateTime`, `onPreview:(DateTime)в†’void`; `zoneId:String?`; `compact:bool=true`; `showReadingKey:bool=true`.
- **States/actions:** retain valid/no-site/no-dark/no-window, moon/unknown-event and preview semantics in the state inventory. Current adopted prototype uses Exact times to select source-defined events and retains selection when closing; source drag/step APIs below are not a claim of continuous Figma interaction. Preview never saves a plan. Only the base screen is newly authored in this run.
- **Current API:** [NightBarSection](../../../lib/presentation/widgets/night_browser_sections.dart) exposes compact=true/home=false and reads injected state. NightBarPainter consumes NightView/cursorIndex/palette; proposed preview props are an adapter view, not its public constructor. NightTimelineSection/TwilightBar also exist in sky_darkness_widget; do not conflate them.
- **Figma:** Density, DataState, PreviewState, ShowReadingKey; Time/Zone/Start/End/Explanation text; phase bands, window and moon rows nested. Preserve time scale, actual proportions, legend and labels. Series colors come from distinct chart/sky roles.
- **Reference:** no Notion astronomy equivalent was found or claimed. R01 supplies surrounding reading hierarchy only. Source scientific encoding is retained; this is explicitly an original After adaptation, not a borrowed Cxx component.

### Night detail adopted recipe — 2026-11-04

The [canonical authoring index](../AUTHORING_PROFILE.md) selects the Night detail outer time-browser family. It combines the adopted dated scientific timeline with a static, token-bound Moon-above-horizon interval overview. The static overview has no preview cursor; the existing discrete event selection owns preview and remaining-dark readouts. Outer variants own open/closed reflow. Night detail presents darkness at the selected Sun limit, not the native continuous sky gradient; reading copy must describe the displayed encoding. Source fixture and scoped verification remain in [REDESIGN_RUN](../REDESIGN_RUN.md#night-critical-qa-and-moon-4-receipt--2026-11-04-to-2026-11-05). The original Tonight/Plan families remain unchanged.

### Moon detail / narrow calendar recipe

The [canonical authoring index](../AUTHORING_PROFILE.md) selects the Moon answer, calendar, row family and two-disclosure details. Preserve Tonight/Plan block composition: context, answer, calendar, time browser and details. The quiet answer action scrolls to the actual time-browser instance; preview changes never save or adopt a plan.

Preserve the BEFORE full-month overview: month navigation, weekday/date grid, phase glyphs and moon-free dark duration for every day, day selection and the plan-night marker. Adapt the enclosing block geometry while retaining readable content. The [functional-preservation rule](../rules_and_constraints.md#functional-preservation--owner-correction-2026-11-05) governs doubtful tradeoffs. Glyphs follow source MoonPhasePainter and computed phase longitude, with semantic fills/strokes. Values come from [MoonCalendar](../../../lib/domain/services/moon_calendar.dart), never from visual references. A computed none interval says No moon-free dark time; unavailable remains Unknown. Current fixture and verification receipts live in [REDESIGN_RUN](../REDESIGN_RUN.md).

The restored canonical month recipe uses the [calendar-only geometry exception](../spacing_and_border.md#moon-month-overview--local-geometry-exception-2026-11-05), including the2026-11-06 single-line h/m notation. Its compact grid displays a computed none duration as0m (historically0 min), while prose uses No moon-free dark time; this does not turn unavailable values into zero.

**Historical / Superseded — week-list decision, 2026-11-04–05:** MoonCalendarSection has a below-336px week fallback, and the authored 327px block left 311px inside its insets. This motivated the seven-row recipe, but the owner identified its loss of the BEFORE month overview on 2026-11-05. It is not the approved default calendar replacement; retain its resources as historical dependencies until the scoped repair.

## After/Data/WeatherSummary

- **Purpose/props:** required `state:NightWeather`; `summary:NightWeatherSummary?`, `updatedAt:String?`, `coverage:String?`, `source:String?`; `onRefresh:()в†’void?`; `refreshing:bool=false`.
- **States/actions:** idle/loading, available fresh/stale/cache with partial hours, unavailable, out-of-range, no dark hours, cloud unknown; retry/refresh where source permits. Keep source, age, coverage and limitation adjacent to the answer.
- **Current API:** [HybridWeatherView](../../../lib/presentation/widgets/weather_hybrid_view.dart) has no custom required constructor data; it reads NightConditionsViewModel and related providers. Sealed states are defined in [night_weather](../../../lib/domain/models/night_weather.dart). The proposed adapter does not replace those owners.
- **Figma:** Availability, Freshness, Coverage(full/partial/none), Refreshing; Answer/Span/UpdatedAt/Age/Coverage/Source/Remedy text and Refresh action swap.
- **Reference:** R01 hierarchy and R03 wrapping. No third-party weather values, trend or quality score may be substituted.

## After/Data/WeatherMetric

### Weather detail adopted recipe — 2026-11-05

The [canonical index](../AUTHORING_PROFILE.md) selects bounded context, answer/trust, compact statistics, limitations and Forecast details. The latest [owner correction](../screens/weather.md#owner-correction--selected-date-only-2026-11-05) removes V1 hour inspection and Coming nights from both versions, including comparison inside the date picker. The summary preserves the actual trend, coverage, unchanged snapshot timestamp and Refresh. Compact Label/Value/Coverage rows keep every metric's sample count and preceding-hour qualifiers. Complete hourly values, cloud layers and visibility remain in Forecast details; no backend refresh simulation is implied. Historical slider/20:00 inspection and coming-night recipes retain their IDs and evidence, but are not current authoring choices. Record actual interaction coverage in REDESIGN_RUN.

- **Purpose/props:** required `label:String`, `value:String`; `detail:String?`, `coverage:String?`; `presentation:rows|hourlyChart=rows`; `series:List<{time,value?}>=[]`; `selectedIndex:int?=null`; `onInspect:(int)в†’void?`; `icon:Slot?`.
- **States/actions:** known/partial/missing, selected hour, single known value, source-defined preceding-hour values. Gaps remain gaps; a single value does not become a fabricated trend. Hour selection changes inspection only.
- **Current API:** private _Metric and metric rendering inside HybridWeatherView; source metrics are Temperature/dew point, Relative humidity, Cloud cover, Wind/gusts, Precipitation probability. DisplaySettingsViewModel.weatherView chooses rows vs charts; both use the same data.
- **Figma:** Presentation, DataState, SelectedHour, HasDetail/HasCoverage; Label/Value/Detail/Coverage text; chart slot with separate series/selected marker. Do not introduce a new UI switch into the baseline simply to expose this property.
- **Reference:** R03 readable metadata rows; chart encoding is Culmina-specific. Retain gust/preceding-hour explanations and the astronomical-seeing limitation.

## After/Data/WeatherTable

- **Purpose/props:** required `columns:List<{id,label,unit?}>`, `rows:List<{localTime,values}>`; `scrollOffset:double=0`; `backgroundRole:String='ThemeData.colorScheme.surface'`.
- **States/actions:** populated, missing cells, horizontal scroll, repeated DST local hour, long zone labels; no independent clickable cells unless the current caller supplies one.
- **Current API:** [WeatherDetailsTable](../../../lib/presentation/widgets/weather_details_table.dart) requires rows:List<TableRow> and background:Color. Private file-level _timeWidth fixes the first column at **96 dp**; one RenderTable owns layout, hit tests and semantics. Keep that source-backed width in this pilot contract; it is a local table constraint, not a new general token.
- **Figma:** ScrollPosition(start/middle/end), MissingCells, DSTRepeat; column/header/cell text instances; first column fixed, remaining columns in a horizontal viewport. Two dates with equal clock text must keep their offset labels.
- **Reference:** no tabular weather component claimed in Notion. R03 wraps text; the pinned time-column behavior comes from Culmina. The frozen Weather frame has Forecast details collapsed, so this is code/test-backed coverage, not a claim of a visible expanded BEFORE table.

## After/Data/Notice

- **Purpose/props:** required `message:String`; `tone:information|caution|error|success=information`; `title:String?`, `action:Slot?`, `details:Slot?`; `dismissible:bool=false`; `onDismiss:()в†’void?`.
- **States/actions:** visible, expanded details, pending remedy, failed remedy; do not dismiss a blocking input or scientific limitation just to reduce clutter.
- **Current API/callers:** inline messages and failure_feedback helpers in Plan/Weather, not a single universal public Notice widget. Wrapper props are proposed. Preserve each caller's actual retry/Undo/dismiss behavior.
- **Figma:** Tone, HasTitle, HasAction, Expanded, Dismissible; Title/Message text; Action/Details swaps.
- **Reference:** R04 C12 separated supporting content; meanings come from source. Neutral missing input uses readable secondary text, never an error wash by default.

## After/Data/SkyDarkness

- **Purpose/props:** required `hasSite:bool`; `bortle:int?`, `sqm:String?`, `provenance:String?`; `onOpenMap:()в†’void?`, `onEdit:()в†’void?`; `open:bool=false`.
- **States/actions:** no site, unknown, recorded, partial; disclose source/method and open existing map/edit controls. Do not derive a value from the palette.
- **Current API:** [SkyDarknessWidget](../../../lib/presentation/widgets/sky_darkness_widget.dart) has embedded=false and reads state; private Bortle control is not a public adapter.
- **Figma:** HasSite, DataState, Open; Bortle/SQM/Provenance text; Map/Edit swaps. In F01 show labeled values and existing provenance; new Bortle swatch recoloring is deferred.
- **Reference:** R01 disclosure hierarchy plus source semantics; no fabricated astronomy reference ID.

## Experimental Longread adapters вЂ” 2026-10-31

The Tonight/Plan 1.2 tests compose eight fact rows locally from the existing text/color/spacing roles, with measured equal label/caption slots for numeric alignment; shared FactRow masters remain unchanged. Tonight retains its actual source phase/interval graphics in a deliberately clipped, named source-geometry adapter. Original plot colors and geometry are preserved instead of substituting synthetic catalog intervals. This is bounded test evidence, not complete tokenized chart coverage or a new reusable chart contract. See [workflow](../WORKFLOW.md).

## Weather V2 chart proposal — 2026-11-05

**Historical initial proposal, superseded by I2+C3 below.** The [authoring profile](../AUTHORING_PROFILE.md) resolves current selection; [REDESIGN_RUN](../REDESIGN_RUN.md) owns output/status. The initial proposal composed one raised Hourly forecast block around five source-backed panel masters, shared hour selector/slider and complete hourly disclosure. Each plot retained an independent labeled physical scale and full-night-fit positions. The permanent controls were later rejected as too dense; their source fields remain preserved in the selected design.

The proposal body swap requires an explicitly hidden body instance in the closed default; changing the swap alone exposed its content. This correction belongs to the new proposal master and does not alter the generic disclosure family. Generic placeholder-opening reactions are disabled. The static Figma specimen does not implement hour selection or disclosure expansion; the isolated local preview has separate interaction evidence. See the [Weather UX rationale](../screens/weather.md#owner-requested-v2-proposal--2026-11-05) for inspection integration and preserved Coming nights.

## Weather V2 graph inspection — selected structure

Use the [latest owner-selected Weather contract](../screens/weather.md#owner-correction--selected-date-only-2026-11-05) and current authoring profile. Initial chart view is a night overview without permanent hour controls. Tapping a plot selects one of 11 source hourly positions across all five panels; selected values, one dated time label and a shared cursor distinguish inspection from summaries. Previous/next controls and Reset appear only during inspection. Their targets are 48px; plot positions remain nearest-hour selection regions, not 48px point buttons. The Figma prototype implements discrete taps, not continuous dragging.

The date trigger must open ordinary calendar date selection, with no forecast rows, coverage badges or cross-night comparison. A temporary date is committed with OK; Cancel keeps the viewed date. Changing the viewed date changes its forecast content truthfully, including unavailable coverage. No save or plan adoption is implied. The previous C3 comparison-list choice is superseded.

Forecast details has closed/open variants with the full source-backed hourly table, 96px pinned local-time column, horizontal weather-column scrolling, low/middle/high clouds, visibility, units, model/retrieval facts, attribution and the Appearance entry. Excluded intervals use a defined absence marker; missing data remains Unknown. Both versions must use the complete details body; remove V1's separate inspection block. The header uses a canonical trailing vector chevron, never a typed arrow inside the title. These scoped interaction variants do not authorize additional base-screen roots. IDs/status/evidence stay in REDESIGN_RUN.

### Weather reference hierarchy extension

The owner-selected [reference treatment](../screens/weather.md#owner-selected-reference-implementation--2026-11-05) extends the existing Weather metric row with optional `Secondary` text and `HasSecondary` visibility properties. Existing Label/Value/Coverage properties remain intact. Use canonical value for the primary number and caption for adjacent paired values or an explicit metric qualifier; keep units and eligibility meaning. The optional secondary line does not authorize hiding unequal or Unknown per-series coverage. Charts use the same primary/secondary hierarchy and quiet time guides behind original series/hit regions, without modifying readings or scales. Inside the existing details body, Hourly values and Data source distinguish exact data from attribution; this is not a new top-level block or product destination.

### Weather G2 hybrid rendering

The owner-selected [G2+T1 contract](../screens/weather.md#owner-selected-g2t1--2026-11-05) supersedes the all-line rendering for cloud cover and precipitation probability only. Keep the same chart family and hourly selection state. Instantaneous cloud bars are centered at source times; preceding-hour probability bars end at the corresponding tick. Retain source vectors/IDs as hidden historical visuals rather than deleting them; unchanged line panels, guides and cursor remain current. Bind bars to the existing HybridTokens.accent and visual interval separators to surfaceRaised. Zero baseline markers are distinct from no-data gaps. The existing full 0–100% scale remains; do not enlarge low probability bars to imply a higher value. Table T1 uses the existing read-only density rule and complete pinned-time data.

## After/Adopted/CandidateRow

Source owner: [TonightCandidatesScreen / _CandidateRow](../../../lib/presentation/screens/tonight/tonight_candidates_screen.dart). Reusable default chooser row: Name (rowTitle, wrapping), independent Usable duration (value, tabular) and canonical trailing chevron in one header; complete Caption (caption) below. Entire row represents one target-selection action; duration is the sum of usable intervals, while endpoints can span gaps. Preserve max altitude, minimum Moon separation while Moon is up, frame-fill percentage/Unknown and next-day notation. No score, recommendation, Save or confirmation is added. Flat separated rows belong to one raised Results group; no decorative card per target. Props Name/Usable/Caption are source-backed text properties. Canonical IDs and current state are owned by the [authoring profile](../AUTHORING_PROFILE.md) and [run](../REDESIGN_RUN.md).

### Candidates option A composition

Owner-selected refinement: retain one coherent context group, optional inline filters group and flat Results group. The question is the single top-menu heading beside Close. Date/site stays in the context group above a full-width shared search/filter pill. This owner-selected arrangement supersedes the previous question-in-context and external-filter layouts. Culmina identity is omitted here. Date/site context, result count and current sort are each shown once in their owning position. A collapsed filter summary includes the default with-window restriction. Refresh belongs beside the result count; adoption meaning belongs before rows. CandidateRow keeps type/window range on one caption line group and the remaining full scientific facts below, preserving every value and qualifier. Expanding filters preserves query and selected settings. This source-backed composition is a Figma contract, not an existing Flutter implementation.
