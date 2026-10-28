# Design system

This is a reference to the implemented Flutter UI in `lib/`.
It does not assert visual or accessibility acceptance.

## Design guidance structure

The five local Culmina design skills are the only project design authorities.
They cover all UI code, including screens, composed widgets, scientific displays,
dialogs, states and all themes; the gallery is only a scoped visual inventory.
Use the relevant skills during implementation. Supporting references and
implementation files are not additional rule sets. Extend the relevant Culmina
skill when guidance is missing. Technical and artifact helpers remain available
as described in [agent tooling](AGENT_TOOLING.md).
Shared product invariants remain in [AGENTS.md](../AGENTS.md).

| Local skill | Owns |
| --- | --- |
| [Components](../.agents/skills/culmina-design-components/SKILL.md) | Existing components, states, callbacks and actual adopters |
| [Product rules](../.agents/skills/culmina-design-rules/SKILL.md) | Scientific meaning, time, missing data and persistence distinctions |
| [Spacing](../.agents/skills/culmina-design-spacing/SKILL.md) | Local geometry, shape, density and reduced motion |
| [Tokens](../.agents/skills/culmina-design-tokens/SKILL.md) | Semantic colors and surfaces across all three themes |
| [Typography](../.agents/skills/culmina-design-typography/SKILL.md) | Adopted text roles, wrapping, scaling and numeric readability |

This document indexes the implementation. The skills' supporting references route
to current definitions and callers. Compatibility files in `.agents/rules/` point
back to shared guidance; external design playbooks and archived recipes are not
automatically adopted Culmina policy. A component specimen demonstrates appearance
in its captured state, not production adoption or device acceptance.

## Theme sources

- `core/theme/app_theme.dart`: Light, Dark and red Field `ThemeData`.
- `app_colors.dart`: raw colors; `app_palette.dart`: semantic theme extension.
- `hybrid_tokens.dart`: additional surfaces, selection, feedback, chart colors,
  compact type sizes, minimum target and app-bar height.
- `app_typography.dart`, `app_spacing.dart`, `app_radius.dart`,
  `app_motion.dart`: type, spacing, shape and transition values.
- `app_button_styles.dart`: shared button styling.

`DisplaySettingsViewModel` stores System/Light/Dark appearance and display
choices. `ThemeViewModel` stores field mode separately. `main.dart` selects
the theme and applies `AppTheme.fieldFilter` around app content in field mode.

## Base colors

| Role | Light | Dark | Field |
| --- | --- | --- | --- |
| Background | `#FFFFFF` | `#191919` | `#000000` |
| Surface | `#F7F7F5` | `#202020` | `#110000` |
| Raised surface | `#FFFFFF` | `#252525` | `#1A0000` |
| Primary text | `#37352F` | `#EBEBEA` | `#FF0000` |
| Secondary text | `#5A5955` | `#A5A5A3` | `#AA0000` |
| Border | `#E9E9E7` | `#2F2F2F` | `#330000` |

`AppPalette` adds semantic event/chart roles. `HybridTokens` supplies action,
accent, success/caution/error and selected-hour roles. These are separate
from base surfaces; component callers resolve the relevant token set.

## Typography

Production text roles use the bundled **Geist** family.
Source Serif 4 is bundled in `pubspec.yaml` but is not the production role family.

| `AppTypography` role | Size / line height | Weight |
| --- | --- | --- |
| `screenTitle` | 22 / 27.5 | 500 |
| `sectionHeading` | 20 / 28 | 600 |
| `sectionSubject` | 18 / 23.4 | 500 |
| `itemTitle` | 16 / 22.4 | 600 |
| `rowTitle` | 16 / 24 | 500 |
| `value` | 15 / 21.75 | 400 |
| `body` | 14 / 21.7 | 400 |
| `caption` | 13 / 19.5 | 400 |
| `dense` | 12 / 18 | 400 |
| `navigationLabel` | 11 / 16.5 | Caller selects 400/600 |

Additional heading roles are `homeHeading` (29), `nightHeading` (25)
and `answerHeading` (28). `AppTypography.scale` also defines the Material
`TextTheme`; it is distinct from the named screen roles.
Compact calendar/chart token sizes are 10/11 logical pixels.

## Layout, shape and motion

- `AppSpacing`: 4, 8, 16, 24, 32, 48; page gutter 20 and section gap 28.
  Additional compact steps are 2, 3, 6, 10, 12 and 14.
- `AppRadius`: small 6, menu 8, large 12 and pill 999.
- `HybridTokens`: minimum target 48; app bar height 64.
- `AppMotion`: short 120 ms, medium 180 ms, highlight 1500 ms;
  curve `Cubic(0.16, 1, 0.3, 1)`.
  Its duration helper returns zero when platform animations are disabled.
- `AppShell`: four navigation items with minimum height 56;
  at text scale 1.5 or greater it lays them out two per row.

## Shared UI

`presentation/shared/` contains the app bar, line icons, section headers,
collapsible sections, detail scaffold, status/failure feedback, confirmation
and deletion patterns, field-mode control and form-input helpers.
`presentation/widgets/` contains altitude/night/weather visualizations,
capture planning, budgets, fit/status and storage/gain presentation.
Screen-specific layouts live under `presentation/screens/`.

The current composition is Tonight → separate Plan/detail flows, with
Logbook, Library and Settings as other root destinations.
Labels, unknown-data messages and draft/result distinctions come from
shared text helpers and the relevant screen/ViewModel state.

See [Product specification](PRODUCT_SPEC.md) and [Architecture](ARCHITECTURE.md).
