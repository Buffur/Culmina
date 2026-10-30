# Data Display catalog

Revision: AFTER-DARK-1.0. All After names and adapter props below are **proposed contracts**, not new Dart APIs. Required props have no default; optional nullable fields/slots default null, optional lists default empty. Slot means nested visual content. The source computes values; Figma displays fixed evidence fixtures. Reference IDs resolve in [reference_mapping](../reference_mapping.md).

## Shared visual recipe

Section headings use sectionHeading; record titles use itemTitle (homeTarget for the Tonight target); metadata uses caption. FitAnswer uses sectionSubject for its verdict and value for figures, with body explanation; density changes which existing facts are shown in the source fixture, never their truth. Keep summary specimens distinct from the full-detail pilot content. PlanState uses caption and its distinct state role.

Record sections use surfaceSubtle, small radius and AppSpacing.md; plain sections have no fill/outline wrapper. Fact rows use textSecondary labels/textPrimary values; provenance uses textTertiary. Capture warnings use Notice. Notices use body plus caption detail, appropriate semantic ink/wash for caution/error/success, and a plain neutral surface for information. Scientific data is never styled disabled merely because a value is unknown.

Weather rows use rowTitle for metric labels, value for readings and caption for coverage/timing notes. The forecast answer uses answerHeading; time labels and table values use caption with tabular figures, chart axes use dense. Table cell inset uses AppSpacing.cellY vertically and AppSpacing.sm horizontally; headers use rowTitle and may wrap. Timeline and charts preserve source geometry/series structure while binding the separate chart/sky roles; no generated trend or decorative smoothing is permitted. Plotting geometry is data-driven, not an opportunity for local spacing tokens.

## After/Data/Section

- **Purpose/props:** required `body:Slot`; `heading:String?`, `summary:String?`, `trailing:Slot?`; `surface:plain|record=plain`; `join:independent|previous|next|both=independent`.
- **States/actions:** static or containing actionable children; section itself is not clickable. Empty content uses a meaningful empty-state message supplied by the caller.
- **Current API:** [DocumentSection](../../../lib/presentation/shared/document_section.dart) requires children:List<Widget>, padding defaults AppSpacing.md, joinPrevious/joinNext default false. [HybridSectionTitle](../../../lib/presentation/shared/hybrid_parts.dart) takes text and optional trailing:String. New plain/record distinction is an After composition decision.
- **Figma:** Surface, Join, HasHeading/HasSummary; Heading/Summary text, Body/Trailing swaps. Vertical Auto Layout; record gets surfaceSubtle and small radius; plain uses page canvas.
- **Reference:** R01 S01 section rhythm and R03 S24 C05/C13 bounded records. Do not frame every scientific explanation.

## After/Data/FitAnswer

- **Purpose/props:** required `state:FitState`; `needed:Duration?`, `usable:Duration?`, `reason:String?`, `missing:String?`; `keyNumbers:List<{label:String,value:String}>=[]`; `action:Slot?`; `density:summary|detail=detail`.
- **States/actions:** fits, tight, doesNotFit, noWindow, needsInput, nothingToFit; unknown durations stay unknown. Show numeric headline only when both durations are known; otherwise show the correct word and available facts. Remedies may choose missing input or fill/trim, using caller rules.
- **Current API:** [StatusBlock](../../../lib/presentation/shared/status_block.dart) requires state; needed/usable/reason/missing/action nullable; keyNumbers=[]; separateFigures=false; headingStyle/figuresBeforeReason nullable; fitLine=false. [PlanStatus](../../../lib/presentation/widgets/plan_status.dart) reads injected analysis/plan state and defaults showFillAction=true. It uses StatusBlock.headline; it is not simply an instance of StatusBlock.
- **Figma:** Verdict (all six states), Density, HasNeeded, HasUsable, HasReason, HasAction; Reason/Missing/Needed/Usable text; KeyNumbers nested FactRow and Action swaps. Use corresponding status role plus words/icon.
- **Reference:** R03 C05 hierarchy and C13 wrap behavior only. Fit semantics, remedies and scientific numbers are Culmina-owned; do not copy a Notion category tag as a verdict.

## After/Data/PlanState

- **Purpose/props:** required `state:PlanState`; `withIcon:bool=true`. No action slot.
- **States:** notSaved, saved, savedChanged, tracking, completed, partly, notDone, oldLog. Keep literal product wording from PlanState.word; never expose internal database “draft” as the user label.
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

- **Purpose/props:** required `block:CaptureBlock`, `summary:String`, `settings:List<{label,value,origin}>`; `index:int` required; `canMoveUp:bool=false`, `canMoveDown:bool=false`; `onEdit:()→void`, `onRemove:()→void` required; `onMoveUp:()→void?`, `onMoveDown:()→void?`; `warnings:List<String>=[]`.
- **States/actions:** light/calibration type, proposed/recorded/missing settings, capability warning, first/middle/last position. Keep Edit, move and Remove available with original constraints; preserve Undo. Do not infer acquisition completion from planned frame count.
- **Current API:** [CapturePlanWidget](../../../lib/presentation/widgets/capture_plan_widget.dart) has blockActions:Widget? and includeSummary=true. Its private _BlockList composes the block rows; there is no public widget with the adapter signature above. [showCaptureBlockDialog](../../../lib/presentation/widgets/capture_plan/capture_block_dialog.dart) returns a block to its caller.
- **Figma:** FrameType, Position(first/middle/last/only), HasWarnings, Provenance; Summary/Filter/Exposure/Count text and nested settings rows; action swaps. Keep supported source fields, including ISO/gain, WB, AF/MF and tracking limitations.
- **Reference:** R03 S24 C05/C13 for a readable record with growing text; action arrangement from Culmina. Use restrained grouping, not tags for every capture setting.

## After/Data/NightTimeline

- **Purpose/props:** required `view:NightView`, `previewUtc:DateTime`, `onPreview:(DateTime)→void`; `zoneId:String?`; `compact:bool=true`; `showReadingKey:bool=true`.
- **States/actions:** valid night, no site, no dark interval, no window, moon above/below, unknown event, selected preview instant. Drag/step preview; exact-time actions jump to source-defined boundaries. Preview never saves a plan.
- **Current API:** [NightBarSection](../../../lib/presentation/widgets/night_browser_sections.dart) exposes compact=true/home=false and reads injected state. NightBarPainter consumes NightView/cursorIndex/palette; proposed preview props are an adapter view, not its public constructor. NightTimelineSection/TwilightBar also exist in sky_darkness_widget; do not conflate them.
- **Figma:** Density, DataState, PreviewState, ShowReadingKey; Time/Zone/Start/End/Explanation text; phase bands, window and moon rows nested. Preserve time scale, actual proportions, legend and labels. Series colors come from distinct chart/sky roles.
- **Reference:** no Notion astronomy equivalent was found or claimed. R01 supplies surrounding reading hierarchy only. Source scientific encoding is retained; this is explicitly an original After adaptation, not a borrowed Cxx component.

## After/Data/WeatherSummary

- **Purpose/props:** required `state:NightWeather`; `summary:NightWeatherSummary?`, `updatedAt:String?`, `coverage:String?`, `source:String?`; `onRefresh:()→void?`; `refreshing:bool=false`.
- **States/actions:** idle/loading, available fresh/stale/cache with partial hours, unavailable, out-of-range, no dark hours, cloud unknown; retry/refresh where source permits. Keep source, age, coverage and limitation adjacent to the answer.
- **Current API:** [HybridWeatherView](../../../lib/presentation/widgets/weather_hybrid_view.dart) has no custom required constructor data; it reads NightConditionsViewModel and related providers. Sealed states are defined in [night_weather](../../../lib/domain/models/night_weather.dart). The proposed adapter does not replace those owners.
- **Figma:** Availability, Freshness, Coverage(full/partial/none), Refreshing; Answer/Span/UpdatedAt/Age/Coverage/Source/Remedy text and Refresh action swap.
- **Reference:** R01 hierarchy and R03 wrapping. No third-party weather values, trend or quality score may be substituted.

## After/Data/WeatherMetric

- **Purpose/props:** required `label:String`, `value:String`; `detail:String?`, `coverage:String?`; `presentation:rows|hourlyChart=rows`; `series:List<{time,value?}>=[]`; `selectedIndex:int?=null`; `onInspect:(int)→void?`; `icon:Slot?`.
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

- **Purpose/props:** required `message:String`; `tone:information|caution|error|success=information`; `title:String?`, `action:Slot?`, `details:Slot?`; `dismissible:bool=false`; `onDismiss:()→void?`.
- **States/actions:** visible, expanded details, pending remedy, failed remedy; do not dismiss a blocking input or scientific limitation just to reduce clutter.
- **Current API/callers:** inline messages and failure_feedback helpers in Plan/Weather, not a single universal public Notice widget. Wrapper props are proposed. Preserve each caller's actual retry/Undo/dismiss behavior.
- **Figma:** Tone, HasTitle, HasAction, Expanded, Dismissible; Title/Message text; Action/Details swaps.
- **Reference:** R04 C12 separated supporting content; meanings come from source. Neutral missing input uses readable secondary text, never an error wash by default.

## After/Data/SkyDarkness

- **Purpose/props:** required `hasSite:bool`; `bortle:int?`, `sqm:String?`, `provenance:String?`; `onOpenMap:()→void?`, `onEdit:()→void?`; `open:bool=false`.
- **States/actions:** no site, unknown, recorded, partial; disclose source/method and open existing map/edit controls. Do not derive a value from the palette.
- **Current API:** [SkyDarknessWidget](../../../lib/presentation/widgets/sky_darkness_widget.dart) has embedded=false and reads state; private Bortle control is not a public adapter.
- **Figma:** HasSite, DataState, Open; Bortle/SQM/Provenance text; Map/Edit swaps. In F01 show labeled values and existing provenance; new Bortle swatch recoloring is deferred.
- **Reference:** R01 disclosure hierarchy plus source semantics; no fabricated astronomy reference ID.
