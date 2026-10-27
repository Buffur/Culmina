---
name: culmina-design-typography
description: Apply adopted Culmina text roles, weight, wrapping and numeric typography. Use for focused typography fixes or review; font-family research applies only to an explicitly open design decision.
---

# Culmina typography

Use for text hierarchy, roles, weight, line height, wrapping and readable measurements. Read [AGENTS](../../../AGENTS.md), `lib/core/theme/app_typography.dart`, relevant compact roles in `hybrid_tokens.dart`, bundled assets in `pubspec.yaml` and affected text callers.

- Production text roles use Geist. Source Serif 4 remains bundled; its availability is not evidence of current role adoption. Preserve MaterialIcons and the separate line-icon rendering path.
- Select the existing named or Material role before changing size/weight/height/tracking. Named screen roles and AppTypography.scale's Material TextTheme have different purposes; inspect their actual definitions.
- Diagnose available width, wrapping and padding before shrinking text. Preserve the user's text scaler and full accessible labels. Compact chart/calendar/navigation roles are explicit exceptions in current source, not a global size prescription.
- Check long names, errors, units and signs, ambiguous digits, and relevant Ukrainian glyphs (І і Ї ї Є є Ґ ґ). Use actual bundled fonts for visual evidence and tabular numerals where comparative measurements need them.
- Font-family selection applies only to a named family/design task. Compare identical content/composition, retain license/provenance and verify fallback; do not download or refresh assets as a side effect of a wrapping fix.

Report the role/caller, bounded correction or finding, checks and remaining limits. CSS specimens do not prove Flutter scaling, and static renders do not establish device or owner acceptance.
