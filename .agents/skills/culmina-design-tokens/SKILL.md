---
name: culmina-design-tokens
description: Map semantic colours and surfaces to Culmina Flutter tokens or its local design prototypes. Use when choosing colours, applying light/dark/field themes, or checking token drift.
---

# Culmina design tokens

Status: active task guidance, reconciled 2026-10-24. Read `docs/design/BASELINE.md` first for the adopted Hybrid/native sources and later refinements; `docs/VERIFICATION_POLICY.md` owns checks. Skills cannot authorize new scope.

Read `docs/design/WORKFLOW.md` for authority and proposal boundaries, then the relevant colour section of `docs/DESIGN_SYSTEM.md`. Resolve paths from the repository root.

## Map meaning before values

| Semantic role | Production source | When to use |
| --- | --- | --- |
| `surface-default` | `Theme.of(context).scaffoldBackgroundColor` (`ThemeData`) | The page canvas |
| `surface-subtle` | `ColorScheme.surface` in light/dark; `cardColor` / `AppColors.fieldSurface` for field grouping | Group related information without making it another elevation level |
| `surface-raised` | `AppPalette.surfaceRaised`, `surfaceContainerHigh` | Dialogs, menus and sheets above the page |
| `surface-sunken` | No dedicated production token | An optional recessed preview well in the browser lab; never invent a Flutter mapping or use it interchangeably with raised |
| `text-primary` | `AppPalette.textPrimary` | Answers, values and meaningful headings |
| `text-secondary` | `AppPalette.textSecondary` | Labels and supporting explanations |
| `text-tertiary` | `AppPalette.textTertiary` | Provenance, time zone and freshness; never hide necessary instructions here |
| `text-disabled` | `AppPalette.textDisabled` | Disabled controls only, not normal metadata |
| `border-subtle` | `AppPalette.border` | Decorative dividers and group outlines |
| `border-control` | `AppPalette.controlBorder`, `ColorScheme.outline` | A boundary needed to recognise a control |
| `status-*` | `AppPalette.statusFits/Tight/DoesNotFit/NoWindow/Neutral` | Fit verdicts; retain the status word and reason |
| `state-*` | `AppPalette.stateUnsaved/Settled/Quiet` | Persistence/progress state, distinct from fit |
| `sky-day/civil/nautical/astro/dark` | `AppPalette.chartDay/chartTwilight/chartDark` (civil, astro are derived midpoints; browser variables) | Only the sky-state band and its legend; one continuous ramp, never UI chrome |
| `moon-up`, `moon-free` | `AppPalette.moon` / `chartMoon`; `textPrimary` | The two Moon lanes; always paired with lane position and bar thickness |
| `wx-caution` | `AppPalette.caution` | Weather dew-margin flag and stale/offline notices, paired with text; not fit verdicts |

Read actual values from `lib/core/theme/app_colors.dart`, `app_palette.dart`, `hybrid_tokens.dart` and `app_theme.dart`; the browser lab's `tokens.json` is an explicitly dated proposal snapshot, not a source of production constants.

The Design code → Colours catalogue exposes all 35 AppPalette roles (including arrays), ColorScheme mappings and raw AppColors. `inventory.json` is generated from the local source with hashes using `scripts/build_inventory.py`. In field mode ColorScheme.surface is black while cardColor/fieldSurface is dark red; keep that distinction explicit. The source catalogue is evidence, not a second editable token authority.

## Colour decisions

- Owner direction, 2026-10-19: calm Notion/Google-inspired surfaces; avoid loud, saturated decoration. Use type, spacing and surface contrast for hierarchy. Do not copy either brand's identity.
- Preserve error/caution semantics and their words. A quiet palette does not mean making a failure look disabled or removing meaning from scientific charts.
- Presentation reads semantic tokens, never copied hex literals. Read raw colours only while editing the theme itself.
- Evaluate text contrast on every surface it actually sits on. Light/dark body and supporting text: at least 4.5:1; functional control boundaries: at least 3:1. Decorative borders need not meet control contrast.
- Field mode is an existing red/black adaptation with intentionally different secondary contrast. Preserve this documented exception; never claim general WCAG AA for it or introduce white/green/blue into field UI.

The proposal file now describes every colour role and foreground/background pairing; `paletteUsage` explains every exported production palette role. The catalogue is a dated, frozen source export. Compare its recorded hashes with the relevant current sources before relying on it; a mismatch means historical coverage, not permission to regenerate it. Any explicitly authorized inventory check proves source/metadata consistency only, not visual or semantic acceptance.

- Quality brief 2026-10-20: neutral by default; colour only where grey cannot carry the information (sky state, Moon lanes, weather caution), each with a second non-colour cue. Exact browser values, boundaries and limits: `docs/design/QUALITY_COLOR_GUIDANCE_2026_10_20.md`. These are prototype variables in `design/home-lab/night.css`, not production tokens or entries in `tokens.json`.
- Original Hybrid `20261020-hybrid7` lightens the Dusk/Slate/Ink sky ramps only under `data-variant=blend` / `.variant-blend`. Field remains red/black; darkness boundaries and Moon lane geometry retain their meaning. The removed Dark-legend pseudo-element was decoration, not focus. See `docs/design/HYBRID_REFINEMENT_2026_10_20.md`; do not copy an early proposal into native tokens or other variants. Later approved native roles are already in HybridTokens; inspect that source and BASELINE.

## Finish

State whether each changed value is existing, proposed, or approved for production. For a token change, check all three themes and affected callers under `docs/VERIFICATION_POLICY.md` V1–V8. For prototype-only work, verify the browser artifact; do not call it Flutter acceptance evidence.
