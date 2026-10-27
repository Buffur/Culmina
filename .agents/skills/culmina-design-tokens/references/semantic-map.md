# Native semantic role map

Current mapping guidance carried forward from the 2026-10-24 token/source reconciliation, not a new token authority. Read only the roles needed by the task and inspect their definition and actual caller. Repository paths below are relative to the root. [AGENTS](../../../../AGENTS.md) describes the shared source routes and evidence limits.

| Semantic role | Production source | When to use |
| --- | --- | --- |
| `surface-default` | `Theme.of(context).scaffoldBackgroundColor` (`ThemeData`) | The page canvas |
| `surface-subtle` | `HybridTokens.surfaceSubtle`; generic theme surfaces remain `ColorScheme.surface` and field `cardColor` | Quiet Hybrid grouping; selected root navigation and Concept B `DocumentSection` use this role. Field `ColorScheme.surface` is black, while `surfaceSubtle` and `cardColor` use the dark-red grouping surface |
| `surface-raised` | `AppPalette.surfaceRaised`, `surfaceContainerHigh` | Dialogs, menus and sheets above the page |
| `surface-sunken` | `HybridTokens.surfaceSunken` | Recessed Moon-lane tracks and the Moon-up legend well in `night_browser_sections.dart`; distinct from raised overlays |
| `text-primary` | `AppPalette.textPrimary` | Answers, values and meaningful headings |
| `text-secondary` | `AppPalette.textSecondary` | Labels and supporting explanations |
| `text-tertiary` | `AppPalette.textTertiary` | Provenance, time zone and freshness; never hide necessary instructions here |
| `text-disabled` | `AppPalette.textDisabled` | Disabled controls only, not normal metadata |
| `border-subtle` | `AppPalette.border` | Decorative dividers and group outlines |
| `border-control` | `AppPalette.controlBorder`, `ColorScheme.outline` | A boundary needed to recognise a control |
| `status-*` | `AppPalette.statusFits/Tight/DoesNotFit/NoWindow/Neutral` via `FitText.color` | Fit verdicts in `StatusBlock`; retain the status word and reason |
| `state-*` | `AppPalette.stateUnsaved/Settled/Quiet` for `PlanState.tone`; compact badges use the Hybrid pairs below | Persistence/result state, distinct from fit; a tone helper is not the badge's current colour map |
| Compact persistence/result badges | `HybridTokens.success/successWash`, `caution/cautionWash`, `selection` with `AppPalette.textPrimary` | `PlanStateLabel` and `EntryStateBadge`: Saved/Tracking/Completed use success; Not saved/Saved · changed/Partly use caution; Not done/Old log use neutral selection. Not recorded (`EntryStateBadge.due`) uses caution. These are state words, not fit or image-quality verdicts |
| Selected weather hour | `HybridTokens.selectedHourFill/selectedHourText/selectedHourRule` | `weather_hybrid_view.dart` hour axis: fill, text and bottom rule, with selected semantics. `hourBackground/hourText` exist but have no presentation callers at this baseline; do not substitute them |
| `sky-day/civil/nautical/astro/dark` | `HybridTokens.skyDay/skyCivil/skyNautical/skyAstronomical/skyDark` | Native night-browser timeline and legend in `night_browser_sections.dart`; existing sky intervals own the geometry. `AppPalette.chartDay/chartTwilight/chartDark` still serve the altitude chart, not this five-role ramp |
| `moon-up`, `moon-free` | `HybridTokens.moonUp/moonFree` | Native night-browser lanes and legend; preserve position, thickness and text cues. `AppPalette.chartMoon` remains the altitude chart's Moon line; it is not the Moon-up lane token |
| Weather dew caution | `HybridTokens.caution` | `weather_hybrid_view.dart` dew-margin heuristic text, not a condensation forecast or fit verdict. `weatherCaution` is defined but has no presentation callers at this baseline |
| Weather freshness/gap notices | `HybridTokens.weatherNotice` | `weather_hybrid_view.dart` aging/stale, unknown-gap and offline-cache notices; preserve their text and source/freshness meaning |

Read actual values from `lib/core/theme/app_colors.dart`, `app_palette.dart`, `hybrid_tokens.dart` and `app_theme.dart`; historical Visual Atlas files under `.audit/atlas/` are reference evidence, not production constants.

Caller map (under `lib/presentation/`): `navigation/app_shell.dart` and `shared/document_section.dart` read `surfaceSubtle`; `widgets/night_browser_sections.dart` reads sunken/sky/Moon roles; `widgets/weather_hybrid_view.dart` reads selected-hour and weather-notice roles; `shared/plan_state.dart` defines both the palette tone helper and Hybrid badges; `shared/night_text.dart` defines `FitText.color`, used by `shared/status_block.dart`; `widgets/altitude_chart_widget.dart` retains AppPalette chart roles. `AppTheme._withTokens` installs both extensions for light/dark/field. Similar values or names do not make these APIs interchangeable or require migrating every AppPalette caller.
