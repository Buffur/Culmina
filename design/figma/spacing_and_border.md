# Spacing and border

Revision: AFTER-DARK-1.0. Values live in [semantic tokens](tokens_semantic.md), except explicitly local layout constraints below. Use tokens by name; do not maintain another numeric scale.

## Grid and composition

1. Author pilot frames at the original 375 px width. Use an unbounded vertical document flow for each full longread.
2. Use AppSpacing.gutter at each page edge, AppSpacing.section between independent sections, AppSpacing.itemGap between related blocks.
3. Use AppSpacing.md within a bounded record group; ordinary reading sections sit directly on the canvas without an extra container.
4. Use AppSpacing.sm for related inline items and AppSpacing.xs for label/value stacks. Never use blank text layers as spacers.
5. App bars and bottom bars grow beyond their token minimum when labels wrap. System insets are separate measured frame layers, not content padding.
6. Use fill-width rows and hug-height content. For a two-column fact row, divide available width equally with AppSpacing.md between; stack below 240 px of content width multiplied by text-scale factor.
7. Do not nest more than one bounded surface within another. A chart or input may use an inset well; it is not another decorative card.
8. Action groups wrap in reading order. Each independent action keeps HybridTokens.minTarget; expanding row height is preferred to hiding the label.
9. A fixed save bar belongs in the viewport comparison; reserve scroll-bottom space for its actual measured height plus safe inset. The longread shows it once as an annotated footer, not between content blocks.
10. Comparison boards use a **120 px horizontal gap** between each BEFORE and AFTER pair. This is canvas presentation geometry, not an app spacing token.

## Radius (5 rules)

1. Use AppRadius.small for bounded records, inputs and buttons.
2. Use AppRadius.menu for anchored menus.
3. Use AppRadius.large for modal/dialog or sheet outer corners.
4. Use AppRadius.pill only for selected-tab capsules and compact status labels; do not turn ordinary rows into pills.
5. Plain sections, charts, table cells and the page canvas have square boundaries; avoid gratuitous corner rounding.

## Border width (5 rules)

1. Use ThemeData.dividerTheme.thickness for separators and ordinary outlines.
2. Use AppPalette.border for quiet separation and AppPalette.controlBorder for an identifying control boundary.
3. Focus uses AfterGeometry.focusRingWidth and ThemeData.focusColor; reserve its space so it cannot clip.
4. A scientific series stroke is part of its chart specification and legend, never a decorative separator.
5. Do not border every row in a reading section. Use a separator only where grouping would otherwise be ambiguous.

## Elevation (4 rules)

1. Reading groups use ThemeData.cardTheme.elevation.
2. App bars use ThemeData.appBarTheme.elevation.
3. Menus and sheets separate through ThemeData.colorScheme.surfaceContainerHigh, outline and placement; no decorative shadow is required in this revision.
4. Never use elevation, blur or glow to imply fit, weather quality, saved state or scientific certainty.

## Figma layout contract

Use vertical Auto Layout for screen content, sections, notices, record cards and growing labels. Use horizontal Auto Layout for actions and row shells, with nested vertical text stacks. Absolute positioning is reserved for plotted coordinates, chart overlays and the presentation board. Clip only deliberately scrollable viewports; full longreads, component specimens and focus rings must not clip. Required layer names are semantic, e.g. `Summary/Heading`, `Fit/Reason`, `Forecast/UpdatedAt`, not `Frame 123`.
