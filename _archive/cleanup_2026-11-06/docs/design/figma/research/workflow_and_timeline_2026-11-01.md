# Figma workflow and timeline research

Date: 2026-11-01. Three independent research agents consulted current official/product sources in parallel. This document records recommendations, not installed plugins, completed interaction tests or an adopted timeline redesign. Current implementation/check results belong to [WORKFLOW](../WORKFLOW.md).

## Plugins and built-in capabilities

| Tool | Recommended use | Boundary |
| --- | --- | --- |
| [Design Lint](https://github.com/destefanis/design-lint) | Missing style associations and inconsistent supported geometry checks | Does not understand Culmina's semantic heading hierarchy; local authorized overrides need explicit handling. |
| [Stark contrast checker](https://www.getstark.co/support/getting-started/using-the-contrast-checker/) | Check actual foreground/background pairs, rather than assuming a token pair is used correctly | Review suggested fixes before applying them to masters. [Typography analysis](https://www.getstark.co/support/getting-started/using-typography/) does not establish semantic hierarchy or a universal minimum font size. |
| [Specs 2, formerly EightShapes Specs](https://www.specsplugin.com/plugin/) | Anatomy, properties, layout, variables/styles and structured handoff | Generate specifications in a dedicated area; generated documentation is not UX acceptance. |
| [Scripter](https://github.com/rsms/scripter) | Retain the existing inspect/apply/verify workflow, custom hierarchy checks, bounds and protected fingerprints | Keep reproducible scripts in the repository. Browser-local saved scripts alone are insufficient evidence. |
| [Tokens Studio](https://docs.tokens.studio/figma/export/options) | Consider later if token export/synchronization becomes an explicit task | Culmina already has94 native variables. Define one source of truth before adopting another token system; no automatic migration or Flutter changes. |

Figma's built-in [Select all with same](https://help.figma.com/hc/en-us/articles/360040449873-Select-layers-and-objects) already covers many bulk selection needs. None of these recommendations proves that a Codex connector can write to the current file. No plugin was installed or connected in this task.

## Rules and current evidence

The 20/18/13 scheme is an owner-selected Culmina hierarchy, not a universal Figma rule. Figma guidance supports [Auto Layout](https://help.figma.com/hc/en-us/articles/360040451373-Guide-to-auto-layout-in-Figma), reusable [components](https://help.figma.com/hc/en-us/articles/360038662654-Guide-to-components-in-Figma), [styles](https://help.figma.com/hc/en-us/articles/360038746534-Create-and-edit-styles), [semantic naming](https://help.figma.com/hc/en-us/articles/360038663994-Name-and-organize-components) and [documented resources](https://help.figma.com/hc/en-us/articles/7938814091287-Add-descriptions-to-styles-components-and-variables).

Before this task's corrections, Culmina had a strong semantic-resource base (94variables/18styles), growing layouts and semantic layer names, but local compositions diverged from library specimens. The independent preceding QA found a33px Geo/Date wrapper containing48px controls and a3.90:1 Open planner label. These observations describe that snapshot; read the current workflow for subsequent corrections.

For normal text, [WCAG1.4.3](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html) uses4.5:1 as the AA benchmark. [Android guidance](https://developer.android.com/guide/topics/ui/accessibility/apps) recommends48×48dp touch targets; [WCAG2.5.8](https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html) concerns24×24CSSpx web targets with exceptions. Figma px are not proof of native hit regions. The excluded200% pass, native accessibility and [prototype flows](https://help.figma.com/hc/en-us/articles/360039823894-Create-and-manage-prototype-flows) remain distinct evidence gaps.

Hold-and-drag reordering has an unresolved non-drag alternative risk under [WCAG2.5.7](https://www.w3.org/WAI/WCAG22/Understanding/dragging-movements). Preserve the owner's exclusion of Move up/down; a future position picker or reorder mode is a possible alternative, requiring its own interaction design. This research does not change the approved menu. WCAG is web guidance; [WCAG2ICT](https://www.w3.org/WAI/standards-guidelines/wcag/non-web-ict/) explains its non-web interpretation and is informational.

## Timeline alternatives

All alternatives must use the same375px fixture, Geist, SessionNight, preview instant, site timezone, next-day markers and actual twilight/darkness/Moon/imaging-window intervals. Current source geometry/data remains the baseline. Do not add decorative altitude curves or synthetic astronomical events.

| Concept | Reference patterns to adapt | Culmina composition and tradeoff |
| --- | --- | --- |
| A: aligned horizontal lanes, recommended for Tonight | Shared phase background, time axis and cursor from [timeanddate graph guidance](https://www.timeanddate.com/sun/help); grid/shading from [airmass.org](https://airmass.org/) | Darkness, Moon and Imaging window lanes share one axis/cursor. Compact; visible thin bands need a larger interactive region and clear reading key. Do not copy a different Moon-brightness formula. |
| B: one vertical night | One-day grid, duration blocks and hour density from [Notion Calendar](https://www.notion.com/product/calendar) and its [view settings](https://www.notion.com/help/notion-calendar-settings) | Hours on the left, parallel science lanes, explicit Preview marker. Easier event overlap reading but taller; better suited to Night detail. |
| C: compact scrubber plus event list | [PhotoPills Time Bar](https://www.photopills.com/videos/planner-time-bar) and [TPE selected-event behavior](https://photoephemeris.com/en/help/photo-ephemeris-web/using-photo-ephemeris-web-part-2-beyond-the-basics/) | Small phase bar plus existing exact-time event rows. A selected event moves Preview. Strong balance of clarity and density; event rows must not be mistaken for a proportional axis. |

Compare Current/A/B/C using identical data and selection; include no-dark, unknown-event and no-window states in a later authorized mockup pass. A is recommended for Tonight, C for expanded exact times, B for a separate Night-detail exploration. These are design hypotheses, not usability results. Permission to adapt visual reference patterns does not establish a license to redistribute product raster assets. No timeline alternative was substituted into the current screen in this task.
