# Home blocks and night-time controls — 2026-10-24

Status: **CONCEPT / NOT IMPLEMENTED**. This owner-requested exploration does not adopt a design or modify the frozen `design/home-lab/` reference. The independent spacing, disclosure and navigation corrections are native code fixes; the blocks and alternative jump controls remain proposals.

## Sources and method

- Input revision: `develop`, `a4798d667007a83e12de3c94d95bb68c22947748`, with this task's three native fixes. Source render: `flutter-home_blocks_source-dark-375.png`; its adjacent JSON records text geometry and resolved styles. Real app/router/ViewModels, bundled fonts, in-memory synthetic fixture, dark theme, 100% text, 375 × 1450 logical px, DPR 1. `home_blocks_source` in `test/support/hybrid_transfer_shots.dart` seeds existing QA history so Record result is present. No personal records or coordinates were sent to the generator.
- Owner references: the two annotated phone images supplied in this chat, retained at their original private attachment paths. They identify the reported defects; they are not committed or used as generation inputs.
- Owner workflow: `Culmina_visual_exploration_addendum_UK.md`, supplied from Downloads and explicitly adopted in this task. Fixes continue independently; proposals require the owner's selection and implementation instruction.
- Generated using the built-in `image_gen.imagegen` tool: A, B, then one targeted B refinement (three calls total). Exact prompts: [prompts.json](prompts.json). Actual PNGs: [A](concept-a.png), [initial B](concept-b-initial.png), [refined B](concept-b.png). The actual current screenshot was never redrawn by the generator.
- [Comparison](comparison.html) displays each complete image at the same nominal phone width, preserving aspect ratio. The images have different canvas heights; generated font metrics and layout are approximate. This is a structural comparison, not a pixel-parity or typography measurement.

## Hypotheses and disposition

| Proposal | Change and benefit | Tradeoff | Flutter feasibility / checks before adoption |
| --- | --- | --- | --- |
| A — quiet outlines | Enclose Your plan, The night ahead, and the next-action pair in three thin document outlines. Keep the current two jump buttons. Section ownership becomes easier to scan. | Insets reduce usable text width and can increase scrolling. Outlined jump controls inside the section can feel busy. | Straightforward caller-owned section decoration/padding; preserve existing widgets/callbacks. Check full-width primary action, long labels, no-site/empty/loading/error variants, 200% text and semantic color roles. |
| B — tonal sections | Three restrained flat surfaces and one two-action time strip. Grouping reads without additional outlines; compact jumps leave breathing room for the timeline. | The strip may be less visibly actionable than outlined buttons. It must retain two distinct 48 dp targets and focus/pressed states. | Reuse existing jump callbacks and exact boundary versus five-minute preview semantics. Check long/localized times, clipped/no-dark intervals, keyboard/semantics, Field red/black and 200% reflow. No timeline calculation changes. |

**Recommendation: B for an owner decision**, with flat native surfaces and the existing typography. Its quieter grouping fits the requested Notion character. A is the smaller implementation change if prominent outlined controls are preferred. Neither is implemented or owner-approved.

## Generation artifacts to exclude

A incorrectly renders Your plan in a serif face. Both proposals approximate text metrics, icon strokes, spacing, radii, timeline geometry and surface shading. B's refinement removed an invented arrow on the non-actionable cursor state, but residual background shading remains. None of those artifacts becomes a requirement. Use Geist for UI, Source Serif 4 only for adopted editorial/answer roles, existing semantic theme colors and flat fills in any later implementation. Preserve every value, action, condition and scientific warning.

Only dark/100% was explored, as the addendum requests before selecting a direction. These generated images prove no runtime, native layout, accessibility, data/provider, device or owner-acceptance condition. The future approved specification must define Light/Dark/Field, spacing, type roles, states and reflow before code adoption.
