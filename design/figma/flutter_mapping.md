# Flutter and Figma bindings

Revision: AFTER-DARK-1.0. This is a binding inventory, **not an implementation patch**. [Semantic tokens](tokens_semantic.md) owns values. [Typography](typography.md) owns text geometry. Figma resources do not exist yet; every resource name below is planned, never a claimed node ID.

Create one new collection `After / AFTER-DARK-1.0` with a single `Dark` mode. A role `Owner.member` maps mechanically to `Owner/member` (nested member dots become slashes) within this collection. Do not bind After to BEFORE's variables or edit a shared style. Keep distinct roles as distinct variables, even for equal values.

| Target role | Planned Figma variable | Actual Flutter owner/member |
| --- | --- | --- |
| ThemeData.scaffoldBackgroundColor | ThemeData/scaffoldBackgroundColor | `ThemeData.scaffoldBackgroundColor` in [source](../../lib/core/theme/app_theme.dart) |
| ThemeData.colorScheme.surface | ThemeData/colorScheme/surface | `ThemeData.colorScheme.surface` in [source](../../lib/core/theme/app_theme.dart) |
| ThemeData.colorScheme.onSurface | ThemeData/colorScheme/onSurface | `ThemeData.colorScheme.onSurface` in [source](../../lib/core/theme/app_theme.dart) |
| ThemeData.colorScheme.onSurfaceVariant | ThemeData/colorScheme/onSurfaceVariant | `ThemeData.colorScheme.onSurfaceVariant` in [source](../../lib/core/theme/app_theme.dart) |
| ThemeData.colorScheme.primary | ThemeData/colorScheme/primary | `ThemeData.colorScheme.primary` in [source](../../lib/core/theme/app_theme.dart) |
| ThemeData.colorScheme.onPrimary | ThemeData/colorScheme/onPrimary | `ThemeData.colorScheme.onPrimary` in [source](../../lib/core/theme/app_theme.dart) |
| ThemeData.colorScheme.secondaryContainer | ThemeData/colorScheme/secondaryContainer | `ThemeData.colorScheme.secondaryContainer` in [source](../../lib/core/theme/app_theme.dart) |
| ThemeData.colorScheme.onSecondaryContainer | ThemeData/colorScheme/onSecondaryContainer | `ThemeData.colorScheme.onSecondaryContainer` in [source](../../lib/core/theme/app_theme.dart) |
| ThemeData.colorScheme.surfaceContainerHigh | ThemeData/colorScheme/surfaceContainerHigh | `ThemeData.colorScheme.surfaceContainerHigh` in [source](../../lib/core/theme/app_theme.dart) |
| ThemeData.colorScheme.outline | ThemeData/colorScheme/outline | `ThemeData.colorScheme.outline` in [source](../../lib/core/theme/app_theme.dart) |
| ThemeData.colorScheme.outlineVariant | ThemeData/colorScheme/outlineVariant | `ThemeData.colorScheme.outlineVariant` in [source](../../lib/core/theme/app_theme.dart) |
| ThemeData.colorScheme.error | ThemeData/colorScheme/error | `ThemeData.colorScheme.error` in [source](../../lib/core/theme/app_theme.dart) |
| ThemeData.focusColor | ThemeData/focusColor | `ThemeData.focusColor` in [source](../../lib/core/theme/app_theme.dart) |
| ThemeData.hoverColor | ThemeData/hoverColor | `ThemeData.hoverColor` in [source](../../lib/core/theme/app_theme.dart) |
| ThemeData.highlightColor | ThemeData/highlightColor | `ThemeData.highlightColor` in [source](../../lib/core/theme/app_theme.dart) |
| ThemeData.dividerTheme.thickness | ThemeData/dividerTheme/thickness | `ThemeData.dividerTheme.thickness` in [source](../../lib/core/theme/app_theme.dart) |
| ThemeData.cardTheme.elevation | ThemeData/cardTheme/elevation | `ThemeData.cardTheme.elevation` in [source](../../lib/core/theme/app_theme.dart) |
| ThemeData.appBarTheme.elevation | ThemeData/appBarTheme/elevation | `ThemeData.appBarTheme.elevation` in [source](../../lib/core/theme/app_theme.dart) |
| AppPalette.textPrimary | AppPalette/textPrimary | `AppPalette.textPrimary` in [source](../../lib/core/theme/app_palette.dart) |
| AppPalette.textSecondary | AppPalette/textSecondary | `AppPalette.textSecondary` in [source](../../lib/core/theme/app_palette.dart) |
| AppPalette.textTertiary | AppPalette/textTertiary | `AppPalette.textTertiary` in [source](../../lib/core/theme/app_palette.dart) |
| AppPalette.textDisabled | AppPalette/textDisabled | `AppPalette.textDisabled` in [source](../../lib/core/theme/app_palette.dart) |
| AppPalette.surfaceRaised | AppPalette/surfaceRaised | `AppPalette.surfaceRaised` in [source](../../lib/core/theme/app_palette.dart) |
| AppPalette.border | AppPalette/border | `AppPalette.border` in [source](../../lib/core/theme/app_palette.dart) |
| AppPalette.controlBorder | AppPalette/controlBorder | `AppPalette.controlBorder` in [source](../../lib/core/theme/app_palette.dart) |
| AppPalette.statusFits | AppPalette/statusFits | `AppPalette.statusFits` in [source](../../lib/core/theme/app_palette.dart) |
| AppPalette.statusTight | AppPalette/statusTight | `AppPalette.statusTight` in [source](../../lib/core/theme/app_palette.dart) |
| AppPalette.statusDoesNotFit | AppPalette/statusDoesNotFit | `AppPalette.statusDoesNotFit` in [source](../../lib/core/theme/app_palette.dart) |
| AppPalette.statusNoWindow | AppPalette/statusNoWindow | `AppPalette.statusNoWindow` in [source](../../lib/core/theme/app_palette.dart) |
| AppPalette.statusNeutral | AppPalette/statusNeutral | `AppPalette.statusNeutral` in [source](../../lib/core/theme/app_palette.dart) |
| AppPalette.stateUnsaved | AppPalette/stateUnsaved | `AppPalette.stateUnsaved` in [source](../../lib/core/theme/app_palette.dart) |
| AppPalette.stateSettled | AppPalette/stateSettled | `AppPalette.stateSettled` in [source](../../lib/core/theme/app_palette.dart) |
| AppPalette.stateQuiet | AppPalette/stateQuiet | `AppPalette.stateQuiet` in [source](../../lib/core/theme/app_palette.dart) |
| AppPalette.muted | AppPalette/muted | `AppPalette.muted` in [source](../../lib/core/theme/app_palette.dart) |
| AppPalette.caution | AppPalette/caution | `AppPalette.caution` in [source](../../lib/core/theme/app_palette.dart) |
| AppPalette.sunEvent | AppPalette/sunEvent | `AppPalette.sunEvent` in [source](../../lib/core/theme/app_palette.dart) |
| AppPalette.twilightEvent | AppPalette/twilightEvent | `AppPalette.twilightEvent` in [source](../../lib/core/theme/app_palette.dart) |
| AppPalette.moon | AppPalette/moon | `AppPalette.moon` in [source](../../lib/core/theme/app_palette.dart) |
| AppPalette.selected | AppPalette/selected | `AppPalette.selected` in [source](../../lib/core/theme/app_palette.dart) |
| AppPalette.chartDay | AppPalette/chartDay | `AppPalette.chartDay` in [source](../../lib/core/theme/app_palette.dart) |
| AppPalette.chartTwilight | AppPalette/chartTwilight | `AppPalette.chartTwilight` in [source](../../lib/core/theme/app_palette.dart) |
| AppPalette.chartDark | AppPalette/chartDark | `AppPalette.chartDark` in [source](../../lib/core/theme/app_palette.dart) |
| AppPalette.chartWindow | AppPalette/chartWindow | `AppPalette.chartWindow` in [source](../../lib/core/theme/app_palette.dart) |
| AppPalette.chartTarget | AppPalette/chartTarget | `AppPalette.chartTarget` in [source](../../lib/core/theme/app_palette.dart) |
| AppPalette.chartMoon | AppPalette/chartMoon | `AppPalette.chartMoon` in [source](../../lib/core/theme/app_palette.dart) |
| AppPalette.chartMinAltitude | AppPalette/chartMinAltitude | `AppPalette.chartMinAltitude` in [source](../../lib/core/theme/app_palette.dart) |
| AppPalette.chartNow | AppPalette/chartNow | `AppPalette.chartNow` in [source](../../lib/core/theme/app_palette.dart) |
| AppPalette.chartNowCentre | AppPalette/chartNowCentre | `AppPalette.chartNowCentre` in [source](../../lib/core/theme/app_palette.dart) |
| AppPalette.chartGrid | AppPalette/chartGrid | `AppPalette.chartGrid` in [source](../../lib/core/theme/app_palette.dart) |
| AppPalette.chartLabel | AppPalette/chartLabel | `AppPalette.chartLabel` in [source](../../lib/core/theme/app_palette.dart) |
| AppPalette.swatchBorder | AppPalette/swatchBorder | `AppPalette.swatchBorder` in [source](../../lib/core/theme/app_palette.dart) |
| HybridTokens.action | HybridTokens/action | `HybridTokens.action` in [source](../../lib/core/theme/hybrid_tokens.dart) |
| HybridTokens.onAction | HybridTokens/onAction | `HybridTokens.onAction` in [source](../../lib/core/theme/hybrid_tokens.dart) |
| HybridTokens.selection | HybridTokens/selection | `HybridTokens.selection` in [source](../../lib/core/theme/hybrid_tokens.dart) |
| HybridTokens.selectedHourFill | HybridTokens/selectedHourFill | `HybridTokens.selectedHourFill` in [source](../../lib/core/theme/hybrid_tokens.dart) |
| HybridTokens.selectedHourText | HybridTokens/selectedHourText | `HybridTokens.selectedHourText` in [source](../../lib/core/theme/hybrid_tokens.dart) |
| HybridTokens.selectedHourRule | HybridTokens/selectedHourRule | `HybridTokens.selectedHourRule` in [source](../../lib/core/theme/hybrid_tokens.dart) |
| HybridTokens.surfaceSubtle | HybridTokens/surfaceSubtle | `HybridTokens.surfaceSubtle` in [source](../../lib/core/theme/hybrid_tokens.dart) |
| HybridTokens.surfaceSunken | HybridTokens/surfaceSunken | `HybridTokens.surfaceSunken` in [source](../../lib/core/theme/hybrid_tokens.dart) |
| HybridTokens.accent | HybridTokens/accent | `HybridTokens.accent` in [source](../../lib/core/theme/hybrid_tokens.dart) |
| HybridTokens.success | HybridTokens/success | `HybridTokens.success` in [source](../../lib/core/theme/hybrid_tokens.dart) |
| HybridTokens.successWash | HybridTokens/successWash | `HybridTokens.successWash` in [source](../../lib/core/theme/hybrid_tokens.dart) |
| HybridTokens.caution | HybridTokens/caution | `HybridTokens.caution` in [source](../../lib/core/theme/hybrid_tokens.dart) |
| HybridTokens.cautionWash | HybridTokens/cautionWash | `HybridTokens.cautionWash` in [source](../../lib/core/theme/hybrid_tokens.dart) |
| HybridTokens.errorText | HybridTokens/errorText | `HybridTokens.errorText` in [source](../../lib/core/theme/hybrid_tokens.dart) |
| HybridTokens.errorWash | HybridTokens/errorWash | `HybridTokens.errorWash` in [source](../../lib/core/theme/hybrid_tokens.dart) |
| HybridTokens.hourBackground | HybridTokens/hourBackground | `HybridTokens.hourBackground` in [source](../../lib/core/theme/hybrid_tokens.dart) |
| HybridTokens.hourText | HybridTokens/hourText | `HybridTokens.hourText` in [source](../../lib/core/theme/hybrid_tokens.dart) |
| HybridTokens.gainStart | HybridTokens/gainStart | `HybridTokens.gainStart` in [source](../../lib/core/theme/hybrid_tokens.dart) |
| HybridTokens.gainEnd | HybridTokens/gainEnd | `HybridTokens.gainEnd` in [source](../../lib/core/theme/hybrid_tokens.dart) |
| HybridTokens.skyDay | HybridTokens/skyDay | `HybridTokens.skyDay` in [source](../../lib/core/theme/hybrid_tokens.dart) |
| HybridTokens.skyCivil | HybridTokens/skyCivil | `HybridTokens.skyCivil` in [source](../../lib/core/theme/hybrid_tokens.dart) |
| HybridTokens.skyNautical | HybridTokens/skyNautical | `HybridTokens.skyNautical` in [source](../../lib/core/theme/hybrid_tokens.dart) |
| HybridTokens.skyAstronomical | HybridTokens/skyAstronomical | `HybridTokens.skyAstronomical` in [source](../../lib/core/theme/hybrid_tokens.dart) |
| HybridTokens.skyDark | HybridTokens/skyDark | `HybridTokens.skyDark` in [source](../../lib/core/theme/hybrid_tokens.dart) |
| HybridTokens.moonUp | HybridTokens/moonUp | `HybridTokens.moonUp` in [source](../../lib/core/theme/hybrid_tokens.dart) |
| HybridTokens.moonFree | HybridTokens/moonFree | `HybridTokens.moonFree` in [source](../../lib/core/theme/hybrid_tokens.dart) |
| HybridTokens.weatherCaution | HybridTokens/weatherCaution | `HybridTokens.weatherCaution` in [source](../../lib/core/theme/hybrid_tokens.dart) |
| HybridTokens.weatherNotice | HybridTokens/weatherNotice | `HybridTokens.weatherNotice` in [source](../../lib/core/theme/hybrid_tokens.dart) |
| HybridTokens.minTarget | HybridTokens/minTarget | `HybridTokens.minTarget` in [source](../../lib/core/theme/hybrid_tokens.dart) |
| HybridTokens.appBarHeight | HybridTokens/appBarHeight | `HybridTokens.appBarHeight` in [source](../../lib/core/theme/hybrid_tokens.dart) |
| AppSpacing.xs | AppSpacing/xs | `AppSpacing.xs` in [source](../../lib/core/theme/app_spacing.dart) |
| AppSpacing.sm | AppSpacing/sm | `AppSpacing.sm` in [source](../../lib/core/theme/app_spacing.dart) |
| AppSpacing.md | AppSpacing/md | `AppSpacing.md` in [source](../../lib/core/theme/app_spacing.dart) |
| AppSpacing.itemGap | AppSpacing/itemGap | `AppSpacing.itemGap` in [source](../../lib/core/theme/app_spacing.dart) |
| AppSpacing.gutter | AppSpacing/gutter | `AppSpacing.gutter` in [source](../../lib/core/theme/app_spacing.dart) |
| AppSpacing.section | AppSpacing/section | `AppSpacing.section` in [source](../../lib/core/theme/app_spacing.dart) |
| AppSpacing.cellY | AppSpacing/cellY | `AppSpacing.cellY` in [source](../../lib/core/theme/app_spacing.dart) |
| AppSpacing.notes | AppSpacing/notes | `AppSpacing.notes` in [source](../../lib/core/theme/app_spacing.dart) |
| AppRadius.small | AppRadius/small | `AppRadius.small` in [source](../../lib/core/theme/app_radius.dart) |
| AppRadius.menu | AppRadius/menu | `AppRadius.menu` in [source](../../lib/core/theme/app_radius.dart) |
| AppRadius.large | AppRadius/large | `AppRadius.large` in [source](../../lib/core/theme/app_radius.dart) |
| AppRadius.pill | AppRadius/pill | `AppRadius.pill` in [source](../../lib/core/theme/app_radius.dart) |
| AfterGeometry.focusRingWidth | AfterGeometry/focusRingWidth | **Proposed only**; no current Dart owner. A future implementation may centralize the width alongside theme geometry. |

## Typography and component bridges

All named styles in [typography](typography.md) bind to `AppTextTheme.<role>` backed by [AppTypography](../../lib/core/theme/app_typography.dart). Figma names follow `After/AFTER-DARK-1.0/Text/<role>`. Named AppTextGeometry overrides are resolved centrally as that module specifies; do not inherit current numeric geometry accidentally.

Catalog names `After/Forms/…`, `After/Navigation/…`, `After/Data/…` are proposed Figma assets and logical contracts. They are **not Dart classes**. Each catalog gives the real callable owner and any adapter needed. A future migration must preserve constructor/callback types, Provider ownership and guards; it requires separate owner authorization.

ThemeData mappings refer to the installed Material theme built by AppTheme, not newly declared fields on AppTheme. AppPalette and HybridTokens are existing ThemeExtensions. `AfterGeometry.focusRingWidth` is the only new role in this revision: a shared, measurable focus indicator width has no named current project token.

## Existing roles deliberately outside this revision

Bortle/onBortle multi-value palettes, remaining spacing steps, Light, Field Red and nonpilot screen-specific metrics are not assigned new values here. Do not extrapolate this contract to them. Bortle values and source/provenance labels in the pilots remain textual in F01; a future categorical swatch expansion requires a revision and legibility check.
