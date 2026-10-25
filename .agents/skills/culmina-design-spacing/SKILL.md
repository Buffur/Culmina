---
name: culmina-design-spacing
description: Apply Culmina spacing, shape and motion to focused density, alignment or layout corrections within the accepted composition. Adaptive navigation or alternative visual studies require their named task.
---

# Culmina spacing and shape

Use for spacing, alignment, density, radius, borders and functional motion. Do not turn a phone overflow into a navigation/sidebar redesign. Use [WORKFLOW modes](../../../docs/design/WORKFLOW.md#work-modes).

## Read for this layout

Read [BASELINE](../../../docs/design/BASELINE.md), [DESIGN_SYSTEM §4](../../../docs/DESIGN_SYSTEM.md#4-spacing-and-radius) (and §6.2 only for motion), `lib/core/theme/app_spacing.dart`, `app_radius.dart`, `app_motion.dart` as applicable, and the affected layout/callers. For constraint errors read the [diagnostic recipe](../flutter-fix-layout-issues/SKILL.md).

<a id="existing-rhythm"></a>

## Choose spacing and shape

- Separate scale, component padding and screen geometry. `md=16` is not a universal screen gutter. Existing `gutter=20` and `section=28` are scale steps, not commands to replace every layout gap. Tonight currently uses literal `(20,20,20,24)` list padding; the planner uses `(20,8,20,32)`. `DetailScaffold` uses `md` for page sides/summary padding. Preserve these source-specific choices rather than normalizing to 16.
- Tighten relationships before shrinking text: group label/value, remove duplicate headings/wrappers, and give sections more separation than items. Keep the answer and primary action clear. The approved Concept B composition groups related existing sections with `DocumentSection`: flat `surfaceSubtle`, 16 dp default padding, 8 dp radius and generally 16 dp between groups. Preserve source-owned chart/calendar widths and current page gutters; individual rows do not all become separate cards. The delivered VQA-030 Moon exception uses 19.5 dp outer gutters at 375 dp to fit seven 48 dp day targets, retains 20 dp on wider phones, and falls back to the existing week view when the month cannot fit (`night_moon_screen.dart`, `MoonCalendarSection`). This is not a global gutter change.
- Diagnose local width/height and scrolling before choosing flex/wrapping/reflow. Preserve reachable 48 logical px targets, natural content growth and scrolling at large text; no fixed-height text cards or clipped line clamps as a repair.
- Read radii from AppRadius (`small=6`, `menu=8`, `large=12`, `pill=999`). Keep functional/decorative boundaries distinct, ordinary groups flat, and overlays meaningful. No decorative star fields, glass, oversized artwork or unrelated visual effects.
- Existing functional sky ramps (`night_browser_sections.dart`) and stacking-gain gradients (`capture_plan/stacking_gain_graph.dart`) are part of the adopted Hybrid presentation. The decorative-effects restriction does not ban these source-owned scientific/data displays; preserve their field palette and text/geometry cues.
- Use AppMotion and preserve reduced motion. For an authorized browser comparison use its reduced-motion contract; [historical geometry studies](../../../docs/design/references/LAB_HISTORY.md#spacing-and-browser-geometry-studies) are optional and do not replace native tokens.

<a id="density-and-responsive-decisions"></a>

## Finish

Record the affected spacing/shape decision, source/caller and checks under [V1–V8](../../../docs/VERIFICATION_POLICY.md). Separate a proposal from an implemented correction. Native layout/device and owner acceptance remain distinct.
