# Forms catalog

The [2026-11-04 canonical binding matrix](../research/consolidation_2026-11-04.md) owns accepted pilot light primary Action, capture commands and contextual action recipes under `After/Adopted`. Existing catalog state masters below remain intact; the light primary adaptation does not globally restyle them.

Historical hierarchy rollout, 2026-11-01: Choice group labels adopted itemTitle with an explicit Medium override, distinguishing the group heading from rowTitle options. The current named nestedTitle resolver in [typography](../typography.md) supersedes that unbound recipe; field labels, options, descriptions and commands retain their distinct roles. See [workflow](../WORKFLOW.md).

Revision: AFTER-DARK-1.2. These are **proposed After component contracts**, not existing Dart classes. Coverage: actions visible in all three pilots, plus source-backed dependent editors/prompts. Editor, menu and dialog states were not opened as live BEFORE frames in D01.

Contract notation: `String`, `bool`, enum and `List<T>` are logical types; `Slot` is a nested visual-content slot, not a Dart type. Required props have no default. Optional nullable props/slots default to null; lists default to empty unless marked required. Common `interaction: default|hover|pressed|focused|disabled = default`. Required actions are callbacks; disabled means no dispatch. Figma cannot encode a function: use documented prototype intent and an annotation naming the actual caller.

All controls use [tokens](../tokens_semantic.md), [text styles](../typography.md), [geometry](../spacing_and_border.md). Hit regions use HybridTokens.minTarget even when a visible glyph is smaller.

## Shared visual recipe

Use actionLabel for explicit commands, rowTitle for ordinary control labels/options, body for entered text, caption for helper/error/provenance, screenTitle for parent/prompt titles and nestedTitle for nested/Choice-group titles. Inputs use surfaceSunken, textPrimary and controlBorder; errors use errorText with a complete message. Scientific hour selection uses selectedHourFill/selectedHourText; generic selection uses the separate neutral selection role; general choices use ThemeData.colorScheme.secondaryContainer/onSecondaryContainer. Toggle on uses action with a textPrimary thumb; off uses surfaceSunken fill and controlBorder outline with the same light thumb. Disabled uses its existing disabled roles. Thumb color is independent of filled-action label ink.

Current new-screen primary = canonical light Action `118:37192`, textPrimary fill/onAction ink. Use it for positive/commit commands; generic blue primary is historical/reference coverage, not the default for new commands. Secondary = transparent fill/textPrimary/controlBorder outline; quiet = transparent fill/textPrimary/no resting outline; destructive = errorWash fill/errorText text. Existing matched command recipes retain their exact insets; unmatched generic controls use AppRadius.small, AppSpacing.md horizontal and AppSpacing.sm vertical insets, with the minimum target taking precedence. Icon-only controls require a semantic label. Scientific blue accents and Toggle tracks retain their own roles. See [selection index](../AUTHORING_PROFILE.md).

Quiet/secondary control hover uses ThemeData.hoverColor; pressed uses ThemeData.highlightColor. Primary/destructive retain their base fill: hover adds a controlBorder outline, pressed uses an onAction/errorText inner outline; this is a declared state recipe, not a new color. Focus adds the shared external focus ring without replacing the state. Disabled uses surfaceSubtle/textDisabled/border and no activation; read-only content uses readable textSecondary, not textDisabled. Busy retains the default recipe and replaces the leading icon with a progress indicator plus truthful pending wording. Sheets/prompts use surfaceContainerHigh and AppRadius.large.

## After/Forms/Action

Current owner resolution, 2026-11-04: explicit Action/Label uses the [SemiBold action recipe](../typography.md). Open planner and Save plan now share the canonical light primary; it is the new-screen positive/commit default, not a local override. Secondary/quiet/destructive use `55:11`. Generic catalog primary interaction/busy/disabled specimens remain blue historical coverage and are not silently recolored. Only default screen states are authored in the current run.

Historical origin, 2026-11-03: light Open planner and Save plan began as local overrides. Their later canonical owner and new-screen selection rule supersede that local-only scope. Earlier blue masters retain their IDs and appearance; see [workflow](../WORKFLOW.md).

Purpose: labeled task action, including Open planner, Save plan, Refresh forecast, Add block and remedies.

- **Props:** required `label:String`, `onActivate:()→void`; `kind:primary|secondary|quiet|destructive = secondary`; `busy:bool=false`; `enabled:bool=true`; `icon:Slot?`; `width:hug|fill= hug`; `feedback:String?`.
- **States/actions:** default, hover, pressed, focus, disabled, busy; show busy label without changing measured button width; block repeat activation only while operation is actually pending. Failure stays visible beside its action and permits retry. No implicit success.
- **Usage:** one primary local action per decision group; Save remains explicit. Destructive uses words plus error ink, never an ambiguous red icon alone.
- **Current API/callers:** Material FilledButton, OutlinedButton and TextButton take `onPressed` (nullable) and `child`; actual composition in [HomeScreen](../../../lib/presentation/screens/home/home_screen.dart), [Tonight](../../../lib/presentation/screens/tonight/tonight_home_screen.dart), [HybridWeatherView](../../../lib/presentation/widgets/weather_hybrid_view.dart). Busy/feedback are proposed composition props, not claimed constructors on these widgets.
- **Figma:** generic catalog Kind, Interaction, Busy, Enabled, Width and Label/Feedback/Icon schemas are retained. Its blue primary uses HybridTokens.action/onAction for historical coverage. New positive/commit defaults use the canonical light master and its text properties/width; quiet uses primary text ink on a neutral surface.
- **Reference:** R03/C14 for a focused accent action; R02/C08 for quiet icon action. Increase to the project target minimum and retain meaningful Culmina labels. Do not copy C14's small split-button dimensions.

## After/Forms/TextField

Purpose: labeled text/numeric entry in dependent forms.

- **Props:** required `label:String`, `value:String`, `onChange:(String)→void`; `kind:text|decimal|integer|search=text`; `helper:String?`, `error:String?`, `unit:String?`; `required:bool=false`, `enabled:bool=true`, `readOnly:bool=false`; `leading:Slot?`, `trailing:Slot?`; `multiline:bool=false`.
- **States/actions:** empty, filled, focused, invalid, disabled, read-only; clear is explicit; editing preserves original values until the owning form commits. Helper and error wrap below, never overlay input content.
- **Usage:** keep durable labels. Search is not a page-title editor. Numeric keyboard is a hint, not validation; exposure accepts the source's decimal/fraction formats. Unrecorded AF/MF is a missing descriptive record, not a number field.
- **Current API/callers:** TextFormField/TextField composition in [capture_block_dialog](../../../lib/presentation/widgets/capture_plan/capture_block_dialog.dart); the public entry is `showCaptureBlockDialog`, which returns `Future<CaptureBlock?>`. Its validation and typed controllers own domain parsing.
- **Figma:** Kind, Content(empty/filled), Interaction, Invalid, ReadOnly, Multiline; Label, Value, Helper, Error, Unit text; Leading/Trailing swaps.
- **Reference:** R04/S13 C11 for contained search affordance; S24 C06 is an editable title and **not** evidence for an input style. After uses AppRadius.small for ordinary fields; search may use the same geometry for consistency.

### Candidates search adaptation — owner-selected A, 2026-11-05

The dedicated CandidateSearchField remains a central linked adaptation of the search contract. Owner correction on 2026-11-05: the full-width context row is one rounded search/filter shell inspired by Notion C11/S13, with an inset input and a separate 48px filter target inside the same outline. The row fills the 311px inner block width; its input fills remaining space and keeps the independent clear target in entered-query states. The previous separate outlined field and external filter are superseded. Text and icons remain centered; both actions have minimum48px height within a56px shell. The outer shell owns resting/focused outline; the inner field has no duplicate border. Original catalog TextField instances remain untouched. Use rowTitle, readable placeholder/entered-text roles and semantic control/focus colors; durable name is `Search targets`. Search narrows filtered candidate membership and preserves sorting, never writes a plan target; clear restores the currently filtered list. The source service is [TargetSearch](../../../lib/domain/services/target_search.dart), but the current Candidates Flutter screen does not integrate search. Finite Figma key samples do not prove arbitrary query/alias entry. Canonical IDs belong to [authoring profile](../AUTHORING_PROFILE.md); evidence and limits to [REDESIGN_RUN](../REDESIGN_RUN.md#candidates-notion-search--2026-11-05).

## After/Forms/Choice

Purpose: choose a single member of a labeled finite set or select an independent item.

- **Props:** required `label:String`, `options:List<{id:String,label:String,enabled:bool}>`, `selectedIds:Set<String>`, `onChange:(Set<String>)→void`; `mode:single|multiple=single`; `presentation:rows|segments=rows`; `helper:String?`, `error:String?`.
- **States/actions:** selected/unselected, disabled option, keyboard focus, invalid required selection; single emits at most one ID, multiple preserves independent choices. Selection does not imply form submission.
- **Usage:** use rows for long or variable labels. Segments only for a small peer set that fits while retaining the full label. Do not express a one-time action as a choice.
- **Current API/callers:** radio/dropdown/selection composition inside capture block editor; options depend on CameraClass and FrameType. No existing `AfterChoice` Dart class. Inspect the concrete control before migration rather than converting every chooser to segments.
- **Figma:** Mode, Presentation, Selected, Enabled, Interaction; OptionLabel text per nested option; GroupLabel/Helper/Error text.
- **1.2 selection:** neutral selected surface, readable neutral ink and retained dot/check. Resting segments have no extra outline; focus remains explicit.
- **Reference:** R02/S08 C10 checked single-choice menu; adapt to source field semantics, not Notion's inbox filters.

## After/Forms/Toggle

Purpose: an immediate binary preference, used only when the source has such a setting.

- **Props:** required `label:String`, `value:bool`, `onChange:(bool)→void`; `enabled:bool=true`, `description:String?`.
- **States/actions:** on/off, focus, pressed, disabled; whole labeled row has one semantic action and one value; show persistence failure rather than silently claiming a change.
- **Current API/caller:** Material Switch/SwitchListTile in settings/editor composition; there is no visible toggle in the three frozen pilot longreads. Proposed supporting component, native adopter must be checked when used.
- **Figma:** Value(on/off), Enabled, Interaction; Label/Description text.
- **1.2 geometry:** intrinsic track 48 × 28, thumb 24, optical clearance 2; the enclosing labeled target remains at least 48. This is a reconstruction informed by Calendar C05, not recovered source dimensions.
- **Reference:** R04/S18 C09 supports visible switch geometry only: source XML reports checked=false despite blue pixels, so D01 does not infer that particular source's true state.

## After/Forms/Confirmation

Purpose: preserve Save/Discard/Cancel and destructive confirmation.

- **Props:** required `title:String`, `message:String`; `kind:unsaved|destructive=unsaved`; required `actions:List<{id,label,kind,onActivate}>`; `content:Slot?`; `dismissResult:cancel='cancel'` (fixed, not configurable to a destructive result).
- **Result contract:** unsaved returns `save|discard|cancel`; destructive returns `confirm|cancel`. Back/outside dismissal returns cancel. Only the caller performs Save/Delete; a prompt does not mutate records.
- **States/actions:** open, action pending, failure; long content scrolls independently while actions remain reachable. Wrap action groups; do not compress labels.
- **Current API:** [confirmation_patterns](../../../lib/presentation/shared/confirmation_patterns.dart): `askUnsavedChanges(context,{required plan,message='',saveLabel='Save and leave',library=false}) → Future<UnsavedChoice>`; `confirmDestructive` returns bool. Preserve exact caller-specific labels.
- **Figma:** Kind, Pending, Failure variants; Title/Message/ActionLabel text; Content swap. Annotate dismissal result on the component.
- **Reference:** R04/S14 C12 for separated sheet body; actual three-way decision semantics come from Culmina, not Notion.

## After/Forms/CaptureBlockEditor

Purpose: dependency specification for editing the blocks visible in Plan; a full-page editor, not a new modal invented for F01.

- **Props:** `initial:CaptureBlock?=null`; `cameraClass:CameraClass=unknown`; `proposal:CaptureBlock?=null`; `blocks:List<CaptureBlock>=[]`; `tipsShown:bool=true`; `rigName:String?`; `fromPhoto:(binning:int)→Future<BlockProposal?>?`; `pickOnOpen:bool=false`; `onTipsShown:(bool)→void?`. The result is `CaptureBlock?`, null on cancel.
- **States/actions:** new/edit; light/dark/flat/bias/dark-flat; camera-class-specific fields; proposed/imported/user-entered provenance; invalid fields; dirty-back confirmation; successful Add/Apply; cancel. Preserve custom filter names, unsupported-but-recorded values, calibration matching and Undo at the caller.
- **Slots:** header, typed field groups, calibration provenance, details disclosure, error, commit/cancel action area.
- **Current API:** the same named parameters are verified on `showCaptureBlockDialog` in [source](../../../lib/presentation/widgets/capture_plan/capture_block_dialog.dart); its private widget is not a public reusable component API.
- **Figma:** Mode, CameraClass, FrameType, Dirty, Validation, Provenance; nested field component instances; RigName and action labels text. Document actual data separately; do not model an arbitrary block list as one Figma text property.
- **Reference:** R04 grouped fields plus R03 wrapping content; source defines fields and behavior. **Code-backed dependency only**, not a fully inspected BEFORE editor frame and not an F01 pilot-screen requirement unless explicitly added.


## Stage C populated chooser/editor recipes —2026-11-05

Choose site retains immediate active selection without closing and a separate manage action; Plan Target/Rig stage a choice until explicit Apply changes. Capture editor returns a validated block to the working draft; Save plan is separate. Use the [canonical profile](../AUTHORING_PROFILE.md) for exact resources and [run](../REDESIGN_RUN.md) for actual output/QA.

The batch-specific search control adapts the existing linked Candidate search resource into a conventional48px control with8px corner radius, durable external label and complete source hint. This resolves the catalog TextField’s narrowed zero-width value slot locally; generic catalog masters and protected screens remain unchanged. It has no embedded filter or finite-query Candidate interaction states. Text, numeric inputs, radio choices and optional-field Unknown values retain source meaning. New glyph/appearance/back adapters only replace non-Auto-Layout legacy wrappers, retaining the source paths and actual48px targets; no selected-tab or Appearance check is added.


Stage C editor base uses canonical single-choice rows (`56:3922`) for Unrecorded/AF/MF so the full Unrecorded label fits with a48px target. The compact segment attempt is superseded after PNG QA. Details remains Open=false with its retained body hidden; closed-state content must not leak below the header. Current frame IDs and verification remain owned by REDESIGN_RUN.
