# Navigation catalog

Revision: AFTER-DARK-1.0. All `After/…` names are proposed Figma contracts. Nullable props/slots default null, lists default empty, required props have no default. Slot is a logical nested visual placeholder, not an existing Dart type. Reference IDs resolve in [reference_mapping](../reference_mapping.md).

## Shared visual recipe

AppBar and RootTabs use the page surface; root labels use navigationLabel and app-bar text uses screenTitle. The active destination uses secondaryContainer/onSecondaryContainer, inactive content textSecondary. Context and ActionRow use rowTitle for labels, value for the chosen value and caption for supporting context. Disclosure uses sectionSubject, with caption for its always-visible factual summary. Rows are flat; only the active tab gets the pill geometry.

Use AppSpacing.md within bounded menus, AppSpacing.sm row vertical insets and AppSpacing.itemGap between an icon and text. Rows fill available width and hug content height with the minimum hit region. Menus use surfaceContainerHigh/AppRadius.menu. Hover/pressed row surfaces use ThemeData.hoverColor/highlightColor; focus uses the shared external ring. Disabled controls use textDisabled and suppress navigation; read-only data remains readable. Long values wrap and grow; no essential context is ellipsized. Icons retain the existing source identity.

## After/Navigation/AppBar

- **Purpose/props:** required `title:String`; `leading:Slot?`, `actions:List<Slot>=[]`, `bottom:Slot?`; `backEnabled:bool=true`, `onBack:()→void?`. Title wraps; height has a token minimum, never a fixed cap.
- **Variants/states/actions:** root/detail, one/two-line title, action default/focus/pressed/disabled. Detail Back goes through existing router guards. Preserve the visible appearance action even though its Light/Field destinations are outside this design scope.
- **Current API:** [hybridAppBar](../../../lib/presentation/shared/hybrid_app_bar.dart) is a function returning AppBar, with optional Widget title/leading, List<Widget> actions, PreferredSizeWidget bottom, automaticallyImplyLeading=true and nullable geometry/color overrides. It also adds FieldModeButton when a ThemeViewModel is available.
- **Figma:** Level(root/detail), TitleLines, ShowLeading, ShowBottom; Title text; Leading/Action/Bottom swaps.
- **Reference/transformation:** R02 C01 restrained header hierarchy; preserve native Back and existing actions, not Notion workspace tabs.

## After/Navigation/RootTabs

- **Purpose/props:** required `selected:tonight|logbook|library|settings`, `onSelect:(destination)→void`. Fixed labeled destination set; optional `safeInset:Slot?`.
- **Variants/states/actions:** each destination selected/unselected, focus and pressed. No disabled destination without source behavior. Plan is not a fifth tab.
- **Current API/caller:** [app_shell](../../../lib/presentation/navigation/app_shell.dart) and [app_router](../../../lib/presentation/navigation/app_router.dart) own shell navigation; adapt existing shell widgets, do not invent a new routing API.
- **Figma:** Selected variant with four values; labels and icon swaps locked to the four destinations. Equal flexible widths, independent minimum hit regions, capsule only around active item.
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
- **Reference/transformation:** R02 S08 C10; preserve actual Plan commands rather than importing inbox choices.
