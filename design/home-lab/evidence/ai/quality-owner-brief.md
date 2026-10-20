# UI/UX Quality Review and Improvement Tasks

Review the following UI/UX issues and implement justified improvements. Treat these points as identified weaknesses and areas requiring further investigation, not as rigid implementation specifications.

The design direction has already been agreed upon. Preserve the approved visual direction while improving the usability, information hierarchy, layout, consistency, and presentation of the existing functionality.

**Important:** Carefully inspect the actual project implementation, data models, technical capabilities, and existing application logic before making changes. We are refining the design around the real application, not designing in isolation. Do not introduce fictitious data, unsupported functionality, or purely decorative elements without a clear purpose.

## 1. Color Palette and Visual Consistency

Review the color usage in the approved design references and identify opportunities to apply colors where they improve information hierarchy, readability, or the interpretation of data.

- Investigate the color palettes and their intended usage in the approved references.
- Apply colors selectively where they add functional or visual value. Avoid unnecessary decoration or excessive use of accent colors.
- Maintain consistency with the approved design direction and the project's existing color system.
- If you decide to introduce new colors or modify the project's color palette, update the relevant project skills and documentation that define the project's colors. Ensure that subsequent implementation work follows the updated color guidance.

Do not introduce new colors without considering their impact on the rest of the application.

## 2. Main Screen

### 2.1. Scale Visualization

- Replace the current segmented color scale with a smooth gradient where appropriate.
- Rework the lower scale. Its current dashed-line appearance does not look good and should be replaced with a more polished, coherent visualization.
- Apply the lower-scale improvement consistently everywhere this component or visualization is used throughout the application.
- Inspect how the revised scale communicates its information and ensure that it remains legible, meaningful, and consistent with the actual data.

### 2.2. "The Night Ahead" Section

Review the arrangement of blocks and spacing within this section.

- Reconsider the positioning, grouping, and visual hierarchy of the information.
- Improve spacing between elements and ensure that related information is visually connected.
- Avoid awkward gaps, overcrowding, and inconsistent alignment.
- Evaluate whether the current arrangement communicates the most important information clearly at a glance.

### 2.3. Weather Summary

Review the information currently presented in the weather summary:

`Weather`
`19–42% cloud in covered dark hours`
`Full dark-time coverage · example snapshot`

The current presentation does not communicate enough useful information.

Investigate what additional or alternative information could be displayed using the data and calculations the application actually supports.

Consider which weather indicators are most relevant to an observing session, how they relate to the available dark period, and what information would help users evaluate observing conditions quickly.

Improve both the information content and its presentation. Do not simply add more values; prioritize meaningful, actionable information.

## 3. Night-Moon Screen

Conduct a dedicated layout and typography QA review of the Night-Moon screen.

### 3.1. Text Positioning and Overflow

Investigate the layout issue affecting the following text:

`Moon above horizon`

`19 Oct, 16:30 GMT+3 → 20 Oct, 00:30 GMT+3`

The text appears to shift or become misaligned in certain situations, making the presentation confusing.

- Identify the actual cause rather than applying an arbitrary visual workaround.
- Check alignment, wrapping, available width, component constraints, and behavior across supported screen sizes.
- Fix the issue at the component level so that the layout remains stable under different content conditions.

### 3.2. Typography and Readability

Review the font sizes and visual hierarchy of the following elements:

- `Moon above horizon`
- `Moon-free dark`

Their text currently appears too small.

Evaluate appropriate typography adjustments, spacing, and emphasis without compromising the overall hierarchy or causing new layout problems.

### 3.3. Alternative Presentation

Review the current presentation of:

`Moon-free in the morning 00:30–04:45`

Consider whether this information could be presented more clearly through a better label, compact time range, timeline segment, or another appropriate representation.

Choose the solution that communicates the meaning most clearly within the existing design.

## 4. Moon Screen

Simplify the Moon screen to focus on two primary elements:

1. A slider or timeline that presents the relevant lunar information.
2. The Moon calendar.

Move secondary or supplementary information to an optional block at the end of the section.

The primary screen content should remain focused and easy to understand. Users who need additional details should still be able to access them without allowing secondary information to dominate the main experience.

Inspect the existing data and interactions before deciding what belongs in the primary view and what should be moved into the optional block.

## 5. Weather Screen

Conduct a comprehensive QA review of the Weather screen.

Evaluate:

- Text positioning, alignment, and wrapping.
- Typography and readability.
- The hierarchy and informativeness of the displayed data.
- The logical order and grouping of elements.
- Relationships between weather conditions, observing conditions, and the relevant time period.
- Whether the most important information is immediately visible.
- Whether any information is redundant, ambiguous, or unnecessarily prominent.

Pay particular attention to how users interpret the data and understand its relevance to an observing session.

Make improvements to both the information architecture and the visual presentation where justified by the available functionality.

## 6. Plan Screen

Review the Plan screen as a complete workflow rather than treating each component as an isolated visual element.

Verify that the order, grouping, dependencies, and presentation of the planning controls make sense for the actual tasks users need to complete.

### 6.1. Target Selection

The Target control should include a search field or search functionality.

Inspect the existing target-selection implementation and determine the appropriate way to integrate search into the current workflow. Ensure that this works with the application's actual target data and selection logic.

### 6.2. Rig

The Rig component should have the appropriate icon, with the relevant information populated from the application's actual metadata.

Inspect the existing metadata model and implementation carefully. Ensure that the icon and displayed information accurately reflect the selected equipment and its associated metadata instead of using arbitrary or hardcoded values.

Pay attention to these functional details throughout the entire Plan screen. Visual refinement must not break or misrepresent the underlying technical functionality.

### 6.3. Add Block — Calibration Frames and WB

Review the calibration-frame controls within Add Block.

- White balance (WB) should be represented numerically where applicable, rather than relying on an ambiguous or purely textual indication.
- Verify which WB values are supported by the actual data model and relevant capture workflow before deciding how to display or edit them.

### 6.4. Focus Control

When the user selects manual focus (MF), consider replacing or supplementing the current focus control with a slider.

The proposed slider should include clearly distinguishable graduations or tick marks to make focus adjustments easier to interpret.

Research suitable references for manual-focus sliders and camera focus controls before choosing the interaction pattern.

Consider the actual focus representation, precision requirements, available input values, and technical limitations of the project. Do not introduce a slider that implies precision or functionality the underlying implementation cannot support.

### 6.5. Filter Input

The Filter control should not contain actual prefilled information as it currently does.

Review the intended behavior and choose an appropriate solution:
- Keep the field empty and use a placeholder to communicate the expected value.
- Alternatively, use subdued placeholder styling if that better fits the approved design.

Placeholder text must be visually distinct from entered content and must not be treated as a real value.

Preserve any legitimate defaults that are required by the underlying functionality, but do not misrepresent placeholder text as selected or configured filter data.

### 6.6. WB Placement When Using Custom Settings

The WB control is currently available under Details, but it is too far removed from the relevant WB interaction.

Consider placing the WB option closer to the existing WB control when the user selects the Custom configuration.

Investigate the existing conditional logic, grouping, and settings dependencies. The goal is to make the relevant adjustment easier to discover without duplicating controls or introducing inconsistent sources of truth.

### 6.7. Stacking Gain Details Graph

Explore and develop several alternative visual variations for the Stacking Gain Details graph.

Compare different presentation approaches, including their:
- Readability and information hierarchy.
- Ability to communicate the meaning of stacking gain.
- Axis labels, units, scales, and data interpretation.
- Use of annotations, emphasis, and visual indicators where appropriate.
- Fit within the existing layout and overall design.
- Suitability for the actual data and calculations supported by the project.

Present and evaluate meaningful alternatives rather than making only minor cosmetic adjustments to the existing graph.

Select the strongest approach based on clarity, correctness, and usefulness. Ensure that any visualization accurately represents the underlying calculations and does not suggest unsupported conclusions.

### 6.8. Overall Plan Workflow

Perform a broader review of the Plan screen to determine whether its elements are arranged logically.

Evaluate the sequence in which users configure targets, equipment, capture settings, calibration frames, focus, filters, and other relevant parameters.

Determine whether:
- Related controls are grouped together.
- The order reflects actual dependencies and the user's natural workflow.
- Important controls are easy to discover.
- Secondary details are appropriately positioned.
- Conditional settings appear in the right context.
- The screen remains understandable without unnecessary scrolling or excessive visual density.

Propose and implement improvements where the current arrangement creates friction or makes the configuration process unnecessarily difficult.

## 7. Execution and Validation

Approach these tasks as a structured review and improvement process.

1. Inspect the existing implementation and identify the affected screens and shared components.
2. Review the relevant functionality, data sources, and technical constraints.
3. Investigate design references when useful, especially for the color system, timeline visualizations, manual-focus controls, and graph alternatives.
4. Identify the root cause of layout or information-design problems before changing the implementation.
5. Compare alternative approaches where there are meaningful design choices.
6. Implement the most appropriate improvements while preserving existing functionality and the approved design direction.
7. Reuse or update shared components where necessary to maintain consistency across screens.
8. Verify that changes work with the actual data and interactions.
9. Check supported screen sizes, text wrapping, alignment, and component states.
10. Review the affected screens again after implementation to identify regressions or inconsistencies.

Do not make every proposed idea mandatory if investigation shows that it would be unsuitable for the actual application. Exercise informed judgment, but explain significant deviations from the requested direction.

The objective is to improve the application's usability, information clarity, and implementation quality while ensuring that the interface accurately reflects the project's real functionality.