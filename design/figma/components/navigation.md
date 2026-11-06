# Navigation catalog

Accepted pilot bindings use canonical `After/Adopted` RootTab/RootTabs, context and chrome recipes. See the [2026-11-04 consolidation matrix](../research/consolidation_2026-11-04.md) for family links, state ownership and route boundaries. Older catalog specimens below retain historical geometry where superseded by the accepted pilots.

Historical hierarchy rollout, 2026-11-01: catalog Disclosure titles adopted itemTitle with an explicit Medium override. The current named nestedTitle resolver in [typography](../typography.md) supersedes that unbound recipe. Night ahead and Discover use the parent section tier; named Night/Moon/Weather rows use the nested-title tier. Ordinary ActionRow field-label/value semantics below remain applicable to inputs. See [workflow](../WORKFLOW.md).

Historical TEST-screen origin, 2026-11-01: Tonight adopted four equal root targets, a small-radius rectangular active surface and no extra selected-tab check. Geo/Date adopted 16px icons and hugging caption labels inside at least 48px targets. The later canonical selection below supersedes the local-only scope while preserving historical catalog specimens; see [workflow](../WORKFLOW.md).

Revision: AFTER-DARK-1.2. All `After/…` names are proposed Figma contracts. Nullable props/slots default null, lists default empty, required props have no default. Slot is a logical nested visual placeholder, not an existing Dart type. Reference IDs resolve in [reference_mapping](../reference_mapping.md).

Latest owner adoption, 2026-11-04: both current screen appearance controls are **icon-only Moon**, with no visible Field caption. All local Off/On masters use a centered 20px glyph at x14/y14 inside the preserved 48px target; retain explicit field-mode descriptions, reciprocal links, neutral active surface and On check. This supersedes the preceding labeled-Tonight distinction. The caption layer remains hidden for recovery rather than becoming visible UI copy.

Root navigation adopts official Lucide **Moon / Notebook Pen / Archive / Sliders Horizontal** for Tonight / Logbook / Library / Settings respectively, using the existing 1.8-unit stroke adaptation and semantic selected/inactive ink. Current screen/adopted-board slots remain 20px; catalog RootTab slots remain 24px. All 24 RootTab state masters and both current visible navigation specimens use this identity mapping; labels, targets, selection geometry, ordering and existing reactions are preserved. This is a scoped navigation adoption, not replacement of scientific/detail icons throughout the app.

Historical origin: the Moon adoption initially retained a Tonight caption and separate Plan icon-only masters. The current shared `99:41077` family supersedes both compositions: icon-only Moon centered at x14/y14 in 48px targets, with explicit field-mode naming, reciprocal links and the On cue. Hidden historical captions do not become new-screen UI copy.

For new screen composition, the adopted four equal labeled targets and small rectangular active surface supersede the older catalog pill/check recipe below. Preserve the existing catalog state specimens as historical coverage; do not copy their superseded selected geometry into new screens. The [navigation research](../research/pilot_readiness_2026-11-04.md) supplies icon alternatives and evidence limits; it does not adopt a global icon replacement.

## Shared visual recipe

AppBar and RootTabs use the page surface; root labels use navigationLabel and app-bar text uses screenTitle. The active root destination uses secondaryContainer/onSecondaryContainer and AppRadius.small, without a pill/check; inactive content uses textSecondary. Canonical context selectors retain their hugging caption labels. Generic Context retains its distinct label/value/caption fields. Ordinary ActionRow inputs use caption/rowTitle/caption; named record/detail rows use nestedTitle per the current typography resolver. Disclosure uses nestedTitle and an always-visible factual caption. Rows remain flat. Select current masters through the [authoring index](../AUTHORING_PROFILE.md).

Use AppSpacing.sm within bounded menus, AppSpacing.sm row vertical insets and AppSpacing.itemGap between an icon and text. Rows fill available width and hug content height with the minimum hit region. Menus use surfaceContainerHigh/AppRadius.menu. Hover/pressed row surfaces use ThemeData.hoverColor/highlightColor; focus uses the shared external ring. Disabled controls use textDisabled and suppress navigation; read-only data remains readable. Long values wrap and grow; no essential context is ellipsized. Icons retain the existing source identity.

## After/Navigation/AppBar

Current appearance uses the shared icon-only Moon family described above. The earlier Eye-plus-caption composition is historical evidence only. The intended action remains Red field mode with explicit Turn on/off naming; this prototype does not simulate global Field Red or validate native semantics. See [workflow](../WORKFLOW.md).

- **Purpose/props:** required `title:String`; `leading:Slot?`, `actions:List<Slot>=[]`, `bottom:Slot?`; `backEnabled:bool=true`, `onBack:()→void?`. Title wraps; height has a token minimum, never a fixed cap.
- **Variants/states/actions:** root/detail, one/two-line title, action default/focus/pressed/disabled. Detail Back goes through existing router guards. Preserve the visible appearance action even though its Light/Field destinations are outside this design scope.
- **Current API:** [hybridAppBar](../../../lib/presentation/shared/hybrid_app_bar.dart) is a function returning AppBar, with optional Widget title/leading, List<Widget> actions, PreferredSizeWidget bottom, automaticallyImplyLeading=true and nullable geometry/color overrides. It also adds FieldModeButton when a ThemeViewModel is available.
- **Figma:** Level(root/detail), TitleLines, ShowLeading, ShowBottom; Title text; Leading/Action/Bottom swaps.
- **Reference/transformation:** R02 C01 restrained header hierarchy; preserve native Back and existing actions, not Notion workspace tabs.

## After/Navigation/RootTabs

- **Purpose/props:** required `selected:tonight|logbook|library|settings`, `onSelect:(destination)→void`. Fixed labeled destination set; optional `safeInset:Slot?`.
- **Variants/states/actions:** each destination selected/unselected, focus and pressed. No disabled destination without source behavior. Plan is not a fifth tab.
- **Current API/caller:** [app_shell](../../../lib/presentation/navigation/app_shell.dart) and [app_router](../../../lib/presentation/navigation/app_router.dart) own shell navigation; adapt existing shell widgets, do not invent a new routing API.
- **Figma:** current `118:40042` Selected variant has four values; destination labels/icons stay fixed. Equal flexible widths and independent targets; active item uses the accepted 8px rectangle with no extra check. The retained capsule family is Historical/Superseded evidence only.
- **Reference/transformation:** R02 S01 C01 for quiet selected/unselected hierarchy. C02 is Search/Ask AI/Compose, **not a bottom navigation reference**.

## After/Navigation/Context

- **Purpose/props:** required `siteName:String?`, `night:CalendarDate?`, `onSite:()→void`, `onNight:()→void`; `zoneId:String?`, `nightStartUtc:DateTime?`, `siteDescription:String?`; `layout:inline|stacked=inline`; `noSiteLabel:String='No site set'`.
- **States/actions:** selected-site/night, no site, unknown zone, long name. No site means no night selection. Site/night targets stay separate; captions grow. The caller determines working-plan mutation vs transient browsing.
- **Current API:** [ContextLine](../../../lib/presentation/shared/context_line.dart) has the corresponding nullable source data/callbacks, noSiteLabel default noSite, framed=false, compact=false. Tonight uses a compact variant; Plan currently uses separate HybridPlanRow inputs in [HomeScreen](../../../lib/presentation/screens/home/home_screen.dart).
- **Figma:** Layout, HasSite, HasNight, HasZone; SiteName/Night/ZoneCaption text; separate SiteAction/NightAction instances. Layout is a proposed presentation prop, not a current ContextLine parameter.
- **Reference/transformation:** R02/C01 and R03/C04 compact grouped navigation; preserve full Culmina identity and zone rather than compressing it to unlabeled chips.

## After/Navigation/ActionRow

- **Purpose/props:** required `label:String`, `value:String`; `caption:String?`, `leading:Slot?`, `trailing:Slot?`, `onActivate:()→void?`; `enabled:bool=true`; `semanticHint:String?`.
- **States/actions:** actionable, read-only, disabled, missing value, focus/pressed; show chevron only for navigation/disclosure intent. A null callback does not magically become an action.
- **Current API:** HybridPlanRow(label,value,caption,onTap,semanticsHint,valueColor,padding) and HybridNightRow(icon,label,value,onTap,extra,iconColor) in [hybrid_parts](../../../lib/presentation/shared/hybrid_parts.dart). The former has nullable onTap; the latter's callback is required. After consolidates visual structure, not the Dart constructors.
- **Figma:** Mode(action/readOnly/disabled), HasCaption, HasLeading, Interaction; Label/Value/Caption text; Leading/Trailing swaps.
- **Reference/transformation:** R03 S01 C04 for a reading row with distinct secondary affordances; do not copy tree nesting or unrelated plus/overflow controls.

## After/Navigation/Disclosure

- **Purpose/props:** required `id:String`, `title:String`, `body:Slot`; `summary:String?`; `open:bool=false`; `onToggle:()→void` required; `persistence:remembered|controlled=remembered`.
- **States/actions:** closed/open, focus/pressed; title and factual summary stay visible in both. Stable id maps to existing sectionKey; controlled state requires both actual open and onToggle.
- **Current API:** [CollapsibleSection](../../../lib/presentation/shared/collapsible_section.dart): required sectionKey/title/child; summary optional; initiallyOpen=false; open/onToggle nullable; topRule=true; titleStyle/icon/iconColor optional; readableFeedback=false.
- **Figma:** Open, HasSummary, Interaction; Title/Summary text; Body instance swap. Prototype toggles only the nested After instance.
- **Reference/transformation:** R01 S01/S03/C03 for disclosure rhythm, R03/C13 for vertical growth. Retain current remembered keys and accurate summaries.

## After/Navigation/ConditionsBrowser

Current owner correction, 2026-11-04: Night/Moon/Weather peer selection uses a compact highlight and no check, while preserving the full independent hit regions. The [geometry owner](../spacing_and_border.md#owner-correction--block-composition-and-peer-tabs-2026-11-04) specifies dimensions. Apply this centrally through the existing ConditionsTab family; preserve transient browsing and actual selected-tab meaning. Earlier pill/check specimens are historical presentation evidence, not the current peer-tab recipe.

- **Purpose/props:** required `selectedTab:night|moon|weather`, `viewedNight:CalendarDate`, `planNight:CalendarDate?`, `onTab:(tab)→void`, `onPrevious:()→void`, `onNext:()→void`, `onPickDate:()→void`; `onReturnToPlanNight:()→void?`; `onPlanThisNight:()→void?`; `siteLabel:String?`.
- **States/actions:** current plan night vs another viewed night, no site, date limits from caller, loading. Arrows/calendar change preview context only. Only the explicit Plan this night action may adopt it.
- **Current API:** [NightMoonScreen](../../../lib/presentation/screens/details/night_moon_screen.dart) accepts computeMonth optional and initialPage=0; WeatherDetailScreen sets initialPage=2. Private viewed-night header reads NightBrowserViewModel; callbacks above are a proposed adapter contract, not constructor parameters on NightMoonScreen.
- **Figma:** SelectedTab, Viewing(planNight/otherNight/noSite), Loading; ViewedNight/PlanNight/Site text; Return/PlanAction booleans. Arrows and date selector are distinct hit regions.
- **Reference/transformation:** R02 C01 for peer view selection, plus Culmina source for calendar/time behavior. No claim that Notion supplies an astronomy date browser.

## After/Navigation/OverflowMenu

- **Purpose/props:** required `items:List<{id,label,enabled,onActivate}>`; `open:bool=false`; `onDismiss:()→void` required; optional `selectedId:String?`.
- **States/actions:** closed/open, focused/disabled item, destructive item; escape/outside closes without action.
- **Current API/caller:** Plan's existing menu composition in HomeScreen, with New plan/Copy and lifecycle behavior verified by plan_identity_actions_test. This is not a new public Dart widget.
- **Figma:** Open, ItemState, Selected; item Label and optional icon swap; menu width hugs longest label within available viewport and grows vertically.
- **1.2 menu geometry:** sm outer inset, sm item horizontal inset, zero gap between item targets; each target remains at least 48 high. Selected items keep a visible light check without an extra selected fill; focused/pressed/disabled/destructive states remain distinct.
- **Reference/transformation:** R02 S08 C10; preserve actual Plan commands rather than importing inbox choices.

### Appearance indicator correction — owner rule, 2026-11-05

The canonical Appearance Moon family uses no checkmark in either Off or Field Red On. Preserve the 48px target, Moon icon and distinguishable state/accessibility semantics; an appearance selection is not represented by a checkbox badge. This does not remove the actual check indicators from independent filter choices. Existing default Dark anchor appearance should remain pixel-identical where the check was already hidden; verify rather than assume.


### Candidates chrome correction — 2026-11-05

Candidates uses the standard Weather-style56px toolbar, screenTitle20/26,24px horizontal/4px vertical insets and8px gap. Preserve its one trailing Close command and durable name; styling alignment does not authorize a second Back or Appearance action. Dedicated glyph wrappers must accommodate actual painted strokes without clipping; inspect absoluteRenderBounds as well as layout bounds. Canonical composition IDs and QA evidence remain in [authoring profile](../AUTHORING_PROFILE.md) and [run](../REDESIGN_RUN.md#candidates-chrome-and-icon-qa--2026-11-05).
