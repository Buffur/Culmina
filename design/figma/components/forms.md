# Forms catalog

Revision: AFTER-DARK-1.0. These are **proposed After component contracts**, not existing Dart classes. Coverage: actions visible in all three pilots, plus source-backed dependent editors/prompts. Editor, menu and dialog states were not opened as live BEFORE frames in D01.

Contract notation: `String`, `bool`, enum and `List<T>` are logical types; `Slot` is a nested visual-content slot, not a Dart type. Required props have no default. Optional nullable props/slots default to null; lists default to empty unless marked required. Common `interaction: default|hover|pressed|focused|disabled = default`. Required actions are callbacks; disabled means no dispatch. Figma cannot encode a function: use documented prototype intent and an annotation naming the actual caller.

All controls use [tokens](../tokens_semantic.md), [text styles](../typography.md), [geometry](../spacing_and_border.md). Hit regions use HybridTokens.minTarget even when a visible glyph is smaller.

## Shared visual recipe

Use rowTitle for action/control labels, body for entered text, caption for helper/error/provenance, and screenTitle for prompt titles. Inputs use surfaceSunken, textPrimary and controlBorder; errors use errorText with a complete message. Selection uses selection/selectedHourText only for a selected hour; general choices use ThemeData.colorScheme.secondaryContainer/onSecondaryContainer. Toggle on uses action/onAction; off uses controlBorder with a textPrimary thumb.

Action recipes: primary = action fill/onAction text; secondary = transparent fill/action text/controlBorder outline; quiet = transparent fill/action text/no resting outline; destructive = errorWash fill/errorText text. All use AppRadius.small, AppSpacing.md horizontal inset and AppSpacing.sm vertical inset with the minimum hit region taking precedence. Icon-only controls still require a semantic label. Icon glyphs retain the source icon identity and fit within the hit region; do not invent new meanings.

Quiet/secondary control hover uses ThemeData.hoverColor; pressed uses ThemeData.highlightColor. Primary/destructive retain their base fill: hover adds a controlBorder outline, pressed uses an onAction/errorText inner outline; this is a declared state recipe, not a new color. Focus adds the shared external focus ring without replacing the state. Disabled uses surfaceSubtle/textDisabled/border and no activation; read-only content uses readable textSecondary, not textDisabled. Busy retains the default recipe and replaces the leading icon with a progress indicator plus truthful pending wording. Sheets/prompts use surfaceContainerHigh and AppRadius.large.

## After/Forms/Action

Purpose: labeled task action, including Open planner, Save plan, Refresh forecast, Add block and remedies.

- **Props:** required `label:String`, `onActivate:()→void`; `kind:primary|secondary|quiet|destructive = secondary`; `busy:bool=false`; `enabled:bool=true`; `icon:Slot?`; `width:hug|fill= hug`; `feedback:String?`.
- **States/actions:** default, hover, pressed, focus, disabled, busy; show busy label without changing measured button width; block repeat activation only while operation is actually pending. Failure stays visible beside its action and permits retry. No implicit success.
- **Usage:** one primary local action per decision group; Save remains explicit. Destructive uses words plus error ink, never an ambiguous red icon alone.
- **Current API/callers:** Material FilledButton, OutlinedButton and TextButton take `onPressed` (nullable) and `child`; actual composition in [HomeScreen](../../../lib/presentation/screens/home/home_screen.dart), [Tonight](../../../lib/presentation/screens/tonight/tonight_home_screen.dart), [HybridWeatherView](../../../lib/presentation/widgets/weather_hybrid_view.dart). Busy/feedback are proposed composition props, not claimed constructors on these widgets.
- **Figma:** Kind, Interaction, Busy, Enabled, Width variants/booleans; Label/Feedback text; Icon instance swap. Primary uses HybridTokens.action/onAction; quiet uses action ink on a neutral surface.
- **Reference:** R03/C14 for a focused accent action; R02/C08 for quiet icon action. Increase to the project target minimum and retain meaningful Culmina labels. Do not copy C14's small split-button dimensions.

## After/Forms/TextField

Purpose: labeled text/numeric entry in dependent forms.

- **Props:** required `label:String`, `value:String`, `onChange:(String)→void`; `kind:text|decimal|integer|search=text`; `helper:String?`, `error:String?`, `unit:String?`; `required:bool=false`, `enabled:bool=true`, `readOnly:bool=false`; `leading:Slot?`, `trailing:Slot?`; `multiline:bool=false`.
- **States/actions:** empty, filled, focused, invalid, disabled, read-only; clear is explicit; editing preserves original values until the owning form commits. Helper and error wrap below, never overlay input content.
- **Usage:** keep durable labels. Search is not a page-title editor. Numeric keyboard is a hint, not validation; exposure accepts the source's decimal/fraction formats. Unrecorded AF/MF is a missing descriptive record, not a number field.
- **Current API/callers:** TextFormField/TextField composition in [capture_block_dialog](../../../lib/presentation/widgets/capture_plan/capture_block_dialog.dart); the public entry is `showCaptureBlockDialog`, which returns `Future<CaptureBlock?>`. Its validation and typed controllers own domain parsing.
- **Figma:** Kind, Content(empty/filled), Interaction, Invalid, ReadOnly, Multiline; Label, Value, Helper, Error, Unit text; Leading/Trailing swaps.
- **Reference:** R04/S13 C11 for contained search affordance; S24 C06 is an editable title and **not** evidence for an input style. After uses AppRadius.small for ordinary fields; search may use the same geometry for consistency.

## After/Forms/Choice

Purpose: choose a single member of a labeled finite set or select an independent item.

- **Props:** required `label:String`, `options:List<{id:String,label:String,enabled:bool}>`, `selectedIds:Set<String>`, `onChange:(Set<String>)→void`; `mode:single|multiple=single`; `presentation:rows|segments=rows`; `helper:String?`, `error:String?`.
- **States/actions:** selected/unselected, disabled option, keyboard focus, invalid required selection; single emits at most one ID, multiple preserves independent choices. Selection does not imply form submission.
- **Usage:** use rows for long or variable labels. Segments only for a small peer set that fits while retaining the full label. Do not express a one-time action as a choice.
- **Current API/callers:** radio/dropdown/selection composition inside capture block editor; options depend on CameraClass and FrameType. No existing `AfterChoice` Dart class. Inspect the concrete control before migration rather than converting every chooser to segments.
- **Figma:** Mode, Presentation, Selected, Enabled, Interaction; OptionLabel text per nested option; GroupLabel/Helper/Error text.
- **Reference:** R02/S08 C10 checked single-choice menu; adapt to source field semantics, not Notion's inbox filters.

## After/Forms/Toggle

Purpose: an immediate binary preference, used only when the source has such a setting.

- **Props:** required `label:String`, `value:bool`, `onChange:(bool)→void`; `enabled:bool=true`, `description:String?`.
- **States/actions:** on/off, focus, pressed, disabled; whole labeled row has one semantic action and one value; show persistence failure rather than silently claiming a change.
- **Current API/caller:** Material Switch/SwitchListTile in settings/editor composition; there is no visible toggle in the three frozen pilot longreads. Proposed supporting component, native adopter must be checked when used.
- **Figma:** Value(on/off), Enabled, Interaction; Label/Description text.
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
