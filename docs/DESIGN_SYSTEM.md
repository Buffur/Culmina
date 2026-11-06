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

[AppColors](../lib/core/theme/app_colors.dart) owns raw Light, Dark and Field
values; [AppPalette](../lib/core/theme/app_palette.dart) and
[HybridTokens](../lib/core/theme/hybrid_tokens.dart) expose semantic roles.
[AppTheme](../lib/core/theme/app_theme.dart) installs each appearance's actual
surfaces and control colors. Inspect the runtime role and caller rather than
copying a hexadecimal snapshot from this index or the historical Atlas.

Dark currently adopts AFTER-DARK-1.2; Light and Field retain their source
palettes. The existence of a role, including a selected-hour color, does not
establish that the current view reads it. The tokens skill's caller map and
actual source distinguish declarations from adoption.

## Typography

Production text roles use the bundled **Geist** family.
Source Serif 4 is bundled in `pubspec.yaml` but is not the production role family.

[AppTypography](../lib/core/theme/app_typography.dart) defines the base scale
and the adopted `afterDarkRoles` / `afterDarkScale`.
[AppTextTheme](../lib/core/theme/app_text_theme.dart) provides runtime named
roles and central `AppTextGeometry` resolution. Current `AppTheme._withTokens`
installs `AppTextTheme.afterDark` and merges `afterDarkScale` for all three
appearances: geometry is shared while colors remain appearance-specific.
The resolver's name does not limit its current installation to Dark.

Presentation reads Material roles through `Theme.of(context).textTheme` and
Culmina roles through `AppTextTheme.of(context)`. Direct base declarations are
not proof of the rendered role; inspect the installed resolver and caller.
Compact calendar/chart exceptions remain source-owned, not a general text-size
prescription.

## Layout, shape and motion

- [AppSpacing](../lib/core/theme/app_spacing.dart) owns named spacing roles.
  Component padding, page gutters and section gaps are distinct; inspect each
  constructor and caller override before using a token.
- [AppRadius](../lib/core/theme/app_radius.dart) owns shape roles; the caller
  chooses which role applies.
- [HybridTokens](../lib/core/theme/hybrid_tokens.dart) owns minimum-target and
  app-bar constants; a constant is not a measurement of every control.
- [AppMotion](../lib/core/theme/app_motion.dart) owns durations and the curve.
  Its duration helper returns zero when platform animations are disabled.
- [AppShell](../lib/presentation/navigation/app_shell.dart) owns the four peer
  destinations and their current text-scale-dependent arrangement.

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

## Historical/Superseded — implementation snapshots preserved 2026-11-06

The [pre-maintenance index](../_archive/cleanup_2026-11-06/docs/instruction-followup-before/docs/DESIGN_SYSTEM.md)
retains the former palette/type/geometry tables. Those numeric snapshots are not
current production prescriptions. The definitions, installed resolver and
callers linked above own the current values; no Flutter value or behavior was
changed by this documentation correction.
