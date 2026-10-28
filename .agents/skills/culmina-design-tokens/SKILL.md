---
name: culmina-design-tokens
description: Map Culmina semantic colors and surfaces to native roles/callers for focused Light, Dark and Field Red fixes or review.
---

# Culmina semantic colors and surfaces

Use for theme/surface meaning, Field Red behavior and token drift. Read [AGENTS](../../../AGENTS.md), the needed rows of the [semantic map](references/semantic-map.md), and affected definitions/callers in `lib/core/theme/app_colors.dart`, `app_palette.dart`, `hybrid_tokens.dart` and `app_theme.dart`.

1. Identify the role: page/group/overlay surface, text, control boundary, science display, fit or persistence/result state. Follow the actual caller to its theme owner; a token declaration is not proof of use.
2. Reuse the existing semantic role before adding an alias. Similar names/values in AppPalette and HybridTokens do not require migrating every caller.
   Keep raw color values and preset construction inside `lib/core/theme/`. Runtime custom roles, including the launch mark, are ThemeExtensions installed in ThemeData; presentation reads the active extension. Implement field-preserving copyWith and continuous lerp for custom theme properties. The launch gate supplies a theme before the main app is ready; do not recreate a separate presentation palette.
3. Preserve words, icons and geometry alongside functional colors. Unknown, freshness, fit and saved/result meanings remain distinct.
4. Inspect affected foreground/background pairs in Light, Dark and Field Red. Keep red/black field presentation and the production filter in `lib/main.dart`; evaluate accessibility against actual rendered uses rather than assuming all themes meet a threshold.
5. For an explicitly requested palette exploration, compare identical content/state and record the proposal separately from implementation. `design/reference/atlas/` is historical visual evidence; `design/reference/` documents source-owned tokens and is not a separate token authority.

Report the semantic role, definition/caller, affected theme pairings, changes or findings, checks and limits. Browser specimens and host renders do not establish Android/device or owner acceptance.
