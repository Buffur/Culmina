# Dark semantic tokens

Revision: AFTER-DARK-1.0 (D01, 2026-10-30). These are **chosen After targets**, not measurements of Culmina or a recovered Notion theme. Single value authority for colors and reusable geometry. Opaque HEX is #RRGGBB; dp maps to Figma logical px at 1:1. Typography has its own authority in [typography](typography.md).

Keep every semantic role independent even when its value equals another role. Do not alias fit, persistence, selection and action roles merely because they share a color. Only roles applied by this pilot contract are included; unlisted production roles remain outside After coverage.

| Token Name | Dark Mode HEX/dp | One-line usage rule |
| --- | --- | --- |
| ThemeData.scaffoldBackgroundColor | #202020 | Page canvas; the continuous reading surface. |
| ThemeData.colorScheme.surface | #202020 | Base Material surface; keep a separate binding from the page canvas. |
| ThemeData.colorScheme.onSurface | #F0EFED | Default readable content on a surface. |
| ThemeData.colorScheme.onSurfaceVariant | #C4C1BC | Secondary Material content, never disabled content. |
| ThemeData.colorScheme.primary | #75B6FF | Material primary action and selection affordances. |
| ThemeData.colorScheme.onPrimary | #142238 | Text and icons on a primary filled action. |
| ThemeData.colorScheme.secondaryContainer | #313B49 | Selected navigation and choice container. |
| ThemeData.colorScheme.onSecondaryContainer | #D8E7FF | Content on a selected navigation or choice container. |
| ThemeData.colorScheme.surfaceContainerHigh | #303030 | Menu and modal surface above the reading canvas. |
| ThemeData.colorScheme.outline | #8B8F93 | Control boundaries necessary to identify an input. |
| ThemeData.colorScheme.outlineVariant | #414141 | Nonessential separators between already grouped content. |
| ThemeData.colorScheme.error | #F39B95 | Material validation error; retain message and remedy. |
| ThemeData.focusColor | #B8D4FF | Visible focus outline; do not communicate focus by color alone. |
| ThemeData.hoverColor | #303030 | Opaque hover surface for a quiet row or action. |
| ThemeData.highlightColor | #3A3A3A | Opaque pressed surface for quiet controls. |
| ThemeData.dividerTheme.thickness | 1 dp | Decorative separator thickness. |
| ThemeData.cardTheme.elevation | 0 dp | Reading groups have no cast shadow. |
| ThemeData.appBarTheme.elevation | 0 dp | Top navigation stays flat. |
| AppPalette.textPrimary | #F0EFED | Primary text, values and headings. |
| AppPalette.textSecondary | #C4C1BC | Supporting descriptions and labels. |
| AppPalette.textTertiary | #ABA8A3 | Metadata that still must be readable. |
| AppPalette.textDisabled | #737373 | Unavailable controls only; never missing measurements. |
| AppPalette.surfaceRaised | #262626 | Bounded record groups, including the saved plan. |
| AppPalette.border | #414141 | Quiet group outline or divider, never an input boundary. |
| AppPalette.controlBorder | #8B8F93 | Unselected control outline on canvas, group and pressed surfaces. |
| AppPalette.statusFits | #8EC7A7 | Fit verdict Fits, with its word and icon. |
| AppPalette.statusTight | #E6C17A | Fit verdict Tight, with measured reason. |
| AppPalette.statusDoesNotFit | #F39B95 | Fit verdict Does not fit, with remedy. |
| AppPalette.statusNoWindow | #C0ACC9 | No imaging window; not an error or missing value. |
| AppPalette.statusNeutral | #C4C1BC | Needs input or nothing to fit; no implied failure. |
| AppPalette.stateUnsaved | #E6C17A | Unsaved or changed persistence state, separate from fit. |
| AppPalette.stateSettled | #8EC7A7 | Saved/completed lifecycle state, separate from fit. |
| AppPalette.stateQuiet | #ABA8A3 | Quiet lifecycle state; retain the state label. |
| AppPalette.muted | #ABA8A3 | Secondary noninteractive symbols. |
| AppPalette.caution | #E6C17A | Scientific or capability limitation, accompanied by explanation. |
| AppPalette.sunEvent | #E6C17A | Sun event marker with time/name. |
| AppPalette.twilightEvent | #B3A6D8 | Twilight event marker with phase label. |
| AppPalette.moon | #D5C8AD | Moon symbol and event series. |
| AppPalette.selected | #75B6FF | Selected scientific sample marker, not an action. |
| AppPalette.chartDay | #77705E | Day interval fill in a labeled time band. |
| AppPalette.chartTwilight | #524B69 | Twilight interval fill; boundary labels identify phase. |
| AppPalette.chartDark | #262D3C | Dark interval fill; no quality score. |
| AppPalette.chartWindow | #86BAD0 | Imaging-window interval with start/end labels. |
| AppPalette.chartTarget | #B5D6B6 | Target series and target interval. |
| AppPalette.chartMoon | #D5C8AD | Moon series, distinct legend and stroke pattern. |
| AppPalette.chartMinAltitude | #D8A98E | Minimum-altitude reference, with its actual threshold. |
| AppPalette.chartNow | #F0EFED | Current preview-time outer marker. |
| AppPalette.chartNowCentre | #202020 | Current preview-time inner marker. |
| AppPalette.chartGrid | #515151 | Chart grid only; never substitute for data. |
| AppPalette.chartLabel | #C4C1BC | Chart axis and legend text. |
| AppPalette.swatchBorder | #7B7F83 | Boundary of a scientific swatch. |
| HybridTokens.action | #75B6FF | Application action affordance. |
| HybridTokens.onAction | #142238 | Content on an action fill. |
| HybridTokens.selection | #313B49 | Selection background distinct from action fill. |
| HybridTokens.selectedHourFill | #313B49 | Selected weather hour surface. |
| HybridTokens.selectedHourText | #D8E7FF | Selected weather hour label. |
| HybridTokens.selectedHourRule | #75B6FF | Selected hour rule; keep the selection marker. |
| HybridTokens.surfaceSubtle | #262626 | Document or record grouping surface. |
| HybridTokens.surfaceSunken | #1A1A1A | Inset input/readout well, never an extra nested card layer. |
| HybridTokens.accent | #75B6FF | Existing accent role for intentional emphasis only. |
| HybridTokens.success | #8EC7A7 | Positive feedback with a textual outcome. |
| HybridTokens.successWash | #27382F | Background behind positive feedback. |
| HybridTokens.caution | #E6C17A | Caution feedback ink. |
| HybridTokens.cautionWash | #3B3326 | Background behind caution feedback. |
| HybridTokens.errorText | #F39B95 | Validation/failure ink. |
| HybridTokens.errorWash | #402D2C | Validation/failure background. |
| HybridTokens.hourBackground | #262626 | Unselected hour inspection surface. |
| HybridTokens.hourText | #C4C1BC | Unselected hour text. |
| HybridTokens.gainStart | #90B7CB | Relative-stacking-gain visual start, with a numeric value. |
| HybridTokens.gainEnd | #B5D6B6 | Relative-stacking-gain visual end; never absolute SNR. |
| HybridTokens.skyDay | #77705E | Day in detailed sky-phase bands. |
| HybridTokens.skyCivil | #66576D | Civil twilight with phase label. |
| HybridTokens.skyNautical | #4E4B70 | Nautical twilight with phase label. |
| HybridTokens.skyAstronomical | #393E58 | Astronomical twilight with phase label. |
| HybridTokens.skyDark | #262D3C | Dark phase in the detailed band. |
| HybridTokens.moonUp | #D5C8AD | Moon-above-horizon interval. |
| HybridTokens.moonFree | #86BAD0 | Moon-free interval, named explicitly. |
| HybridTokens.weatherCaution | #E6C17A | Weather limitation marker, not a global night score. |
| HybridTokens.weatherNotice | #A9C3DA | Weather information marker. |
| HybridTokens.minTarget | 48 dp | Minimum hit-target width and height for independent actions. |
| HybridTokens.appBarHeight | 56 dp | Minimum app-bar content height, excluding system insets. |
| AppSpacing.xs | 4 dp | Label-to-value and icon-caption micro gap. |
| AppSpacing.sm | 8 dp | Related inline elements and compact row padding. |
| AppSpacing.md | 16 dp | Bounded group and control horizontal inset. |
| AppSpacing.itemGap | 12 dp | Between related rows or blocks. |
| AppSpacing.gutter | 20 dp | Page side gutter at pilot width. |
| AppSpacing.section | 32 dp | Between independent document sections. |
| AppSpacing.cellY | 8 dp | Weather table vertical cell inset. |
| AppSpacing.notes | 12 dp | Chart-to-explanation gap. |
| AppRadius.small | 8 dp | Inputs, buttons and bounded record groups. |
| AppRadius.menu | 12 dp | Popover corners. |
| AppRadius.large | 20 dp | Dialog and sheet outer corners. |
| AppRadius.pill | 999 dp | Selected tab capsule and compact noninteractive status capsule only. |
| AfterGeometry.focusRingWidth | 2 dp | NEW proposed shared focus outline width; use with ThemeData.focusColor. |

`AfterGeometry.focusRingWidth` is a proposed design role, not an existing Dart class/member. All other owner/member names map in [flutter_mapping](flutter_mapping.md). No production value changes are authorized.
