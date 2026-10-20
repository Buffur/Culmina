---
name: culmina-design-spacing
description: Apply Culmina spacing, shape, border and motion semantics. Use for density, alignment, responsive layouts or controlled shape comparisons.
---

# Culmina spacing and shape

Read `docs/design/WORKFLOW.md`; use `lib/core/theme/app_spacing.dart`, `app_radius.dart`, `app_motion.dart` and the relevant layout as truth.

## Existing rhythm

| Token | Logical px | Decision |
| --- | --- | --- |
| `AppSpacing.xs` | 4 | A label and its value, closely related inline content |
| `AppSpacing.sm` | 8 | Rows or controls inside a group |
| `AppSpacing.md` | 16 | Phone side padding and group content padding |
| `AppSpacing.lg` | 24 | Separation between sections |
| `AppSpacing.xl` | 32 | Major separation where hierarchy warrants it |
| `AppSpacing.xxl` | 48 | Large-scale layout rhythm, not a default card gap |

Production radii: `small = 6` for cards/fields/buttons, `large = 12` for dialogs/sheets, `pill = 999` for appropriate compact controls. Keep a 1 px decorative boundary where the existing flat system needs it; do not add both a heavy border and a large shadow.

## Density and responsive decisions

- Tighten relationships before shrinking text: group label/value, remove duplicate headings, reduce redundant wrappers.
- Give sections more separation than items within them. Preserve the main result and action without making every item a card.
- Use content-driven reflow. At 412 logical px, no horizontal page scrolling or clipped primary action; the desktop browser must retain the Android phone viewport. Tablet/foldable adaptations require a separately named device scope; desktop columns are not the current phone proposal.
- Minimum existing interaction target: 48 logical px. Visual density is not permission to reduce targets.
- At 200% text use natural wrapping and document scrolling. Avoid fixed-height card content and clipped line clamps.
- No decorative star fields, gradients, glass or oversized astronomy artwork. Use line icons, whitespace and typography.
- Prefer no elevation for ordinary groups. Elevation explains overlays; a subtle surface change can explain grouping without a shadow.
- The browser lab compares Hybrid, Paper, Focus, Journal, Line, Calm and Folio in one horizontal rail. Their density/radii are local proposals; do not write them into `AppRadius` until selected. Hybrid combines Paper's base with Journal's night section, following the owner's concept preference.
- Keep functional motion restrained; use `AppMotion` in Flutter and `prefers-reduced-motion` in browser concepts. Avoid recurring animation in a planning tool.

For a UI proposal, state the changed density/shape choices. For production changes, reuse existing tokens and verify affected layouts under the active task criteria.

The current browser lab consumes JSON `space` as `--space-*`, `productionRadius` as `--radius-*`, and `proposalRadius` as each concept's `--concept-radius`. These control group rhythm and plan containers; remaining responsive chrome dimensions are local CSS choices. The Hybrid family adds Page / Soft / Desk; Soft's 14 radius remains a proposal.

Original Hybrid `20261020-hybrid7` keeps Save/Open planner full width and uses content-width secondary actions with at least 48 px targets. Plan context rows use whitespace and consistent icon-free leading alignment; navigation/data boundaries retain separators. Proposal motion tokens are 120 ms feedback and 180 ms view continuity, with reduced motion disabled. These browser-only rules live in `hybrid-refinement.css` / `tokens.json.hybridRefinement`; production `AppMotion` and other concepts remain unchanged.

At 200% browser text, the original Hybrid's four bottom destinations reflow into two rows, retaining full destination words and the requested 22 px labels instead of mid-word breaks or a text-size cap. Normal text keeps the established four-column bar. This is an accessibility refinement of the browser concept, not an approved replacement for native Android navigation.
