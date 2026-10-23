---
name: culmina-design-tokens
description: Map Culmina semantic colours and surfaces to native roles/callers for theme fixes or review. Read the relevant DESIGN_SYSTEM section and semantic-map rows, not the whole history; palette research requires an open decision.
---

# Culmina design tokens

Use for colour/surface meaning, light/dark/field behavior and token drift. Do not invent aliases, copy browser values into native code or migrate every AppPalette role merely because HybridTokens exists. Use [WORKFLOW modes](../../../docs/design/WORKFLOW.md#work-modes).

## Read the relevant role

Read [BASELINE](../../../docs/design/BASELINE.md), follow the [section-reading route](../../../docs/design/WORKFLOW.md#read-the-needed-contract), then [DESIGN_SYSTEM §2](../../../docs/DESIGN_SYSTEM.md#2-colour), the needed rows of the [native semantic map](references/semantic-map.md), and the relevant definitions/callers in `lib/core/theme/app_colors.dart`, `app_palette.dart`, `hybrid_tokens.dart`, `app_theme.dart`.

<a id="map-meaning-before-values"></a>

## Choose by meaning

1. Identify the role (surface, control boundary, text, scientific presentation, fit or persistence/result state), then follow its actual caller to its theme owner. A declared token is not proof that a widget uses it.
2. Preserve the calm accepted hierarchy: type/spacing/surfaces first, functional colour plus words/icons/geometry. Unknown, source/freshness, fit and saved/result meaning must stay distinct.
3. Inspect each affected foreground/background pairing in the relevant themes. Light/dark functional text requires 4.5:1 and control boundaries 3:1; decorative borders and disabled controls have different roles. Field mode retains its red/black and documented secondary-contrast exception; no general AA claim or new white/green/blue.
4. Distinguish existing roles, proposals and explicit adoption. Read the [catalogue/colour-study history](../../../docs/design/references/LAB_HISTORY.md#token-catalogue-and-early-colour-studies) only for the corresponding research/reference task; dated exports are not production constants and do not authorize regeneration.

<a id="colour-decisions"></a>

## Finish

Report the role, definition and actual caller, affected pairings/themes, bounded diff or review finding and [V1–V8](../../../docs/VERIFICATION_POLICY.md) checks. Preserve data/error/caution words and the field exception. A browser specimen is not Flutter/device acceptance.
