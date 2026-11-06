---
name: culmina-design-spacing
description: Apply Culmina spacing, shape and motion to focused density, alignment or layout corrections within the accepted composition. Adaptive navigation or alternative visual studies require their named task.
---

# Culmina spacing, shape and motion

Use for local spacing, alignment, density, radius, border and functional-motion work. Read [AGENTS](../../../AGENTS.md), the affected widget/callers and the relevant definitions in `lib/core/theme/app_spacing.dart`, `app_radius.dart` and `app_motion.dart`.

- Distinguish scale values, component padding and screen gutters. Resolve named `AppSpacing` roles such as `md`, `gutter` and `section` from [their source](../../../lib/core/theme/app_spacing.dart); available tokens are not instructions to normalize every screen.
- Inspect actual screen padding and chart/calendar width constraints before adjusting a gap. [DocumentSection](../../../lib/presentation/shared/document_section.dart) supplies flat grouping with default `AppSpacing.sm` padding and `AppRadius.small` corners; caller overrides remain explicit. Preserve child actions, focus and natural text height.
- Improve grouping before shrinking text. Diagnose width/height and scrolling ownership before adding flex or wrapping; use [layout diagnosis](../flutter-fix-layout-issues/SKILL.md) for an actual constraint error.
- Preserve reachable controls, full labels, text scaling and large-content scrolling. Avoid clipping, fixed text-card heights or a smaller user scaler as overflow repairs.
- Resolve shape roles from [AppRadius](../../../lib/core/theme/app_radius.dart), then inspect the caller's current role before changing it. Do not copy numerical radii from an older reference snapshot.
- Use AppMotion and its reduced-motion handling. Source-owned scientific sky ramps and stacking-gain gradients are functional data presentation, not permission to add decorative effects.

A phone overflow does not call for new navigation or an adaptive shell. Use the named adaptive-layout skill only for that task.

Report the geometry/source/caller, chosen correction, actual checks and limits. A static render establishes only its captured theme, size, scale and state.

## Historical/Superseded — numeric snapshot preserved 2026-11-06

The [pre-maintenance version](../../../_archive/cleanup_2026-11-06/docs/instruction-followup-before/.agents/skills/culmina-design-spacing/SKILL.md) preserves the earlier numeric descriptions and their scope. Current definitions and constructor defaults linked above own the values; the archived snapshot does not prescribe new geometry.
