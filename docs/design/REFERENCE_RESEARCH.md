# Design Lab reference extension — 2026-10-19

Owner request: find related design philosophies, create more quiet Home variations, add clean/popular font candidates, combine a Notion/Paper base with Journal's The night ahead, keep concepts in one horizontal level, and expose the existing design code on the page.

## References and interpretation

These are design interpretations of official public pages and UI material, not reverse-engineered official token systems or claims about proprietary fonts.

| Reference and primary source | Useful characteristic | Translation into Culmina | Boundary |
| --- | --- | --- | --- |
| [Notion Calendar](https://www.notion.com/product/calendar) | Quiet workspace, concise context and direct access to details | Paper and the Hybrid base | No workspace feature expansion or copied brand assets |
| [Google Material typography](https://m3.material.io/styles/typography/overview) | Named semantic roles and familiar functional hierarchy | Focus and the existing Roboto scale | No bright brand palette or wholesale Expressive makeover |
| [Linear UI redesign](https://linear.app/now/how-we-redesigned-the-linear-ui) | Alignment, neutral panels, clearer chrome and density; the article explicitly distinguishes navigation scope | Line, with compact rows and section boundaries | Keep 48 dp controls and existing Culmina navigation/behavior |
| [Things](https://culturedcode.com/things/) | A focused personal-planning surface and low-noise task grouping | Calm, with open lists and a distinct next action | No imported task workflow or coloured scientific verdicts |
| [Craft](https://www.craft.do/) | Document-oriented content and a clear reading rhythm | Folio, with open sections and larger headings | No decorative covers, background illustration or nested card wall |

Hybrid follows the owner's explicit preference: retain the restrained Paper canvas and use Journal's night section layout/heading. Other new variants explore distinct grouping, density and typography while keeping the same data, action order, four tabs and simulated interactions. The primary links are also available in the lab; there is no dependency on a third-party account.

## Fonts and evidence

Official [Google Fonts metadata](https://fonts.google.com/metadata/fonts) was inspected on 2026-10-19. The lab includes eleven families with local WOFF2 assets, official OFL licences, source URLs, subsets and SHA-256 hashes. Existing: Inter, Roboto, Manrope, IBM Plex Sans, Source Serif 4. Added: Open Sans, Noto Sans, Source Sans 3, Geist, Onest, Golos Text. [Geist's publisher page](https://vercel.com/font) provides an additional first-party reference for its interface-oriented design.

The metadata's `popularity` field is retained verbatim, not converted into an invented score, traffic estimate or installation count. Open Sans, Noto Sans and Source Sans 3 were chosen as established clean alternatives; Geist, Onest and Golos Text widen the comparison. DM Sans was considered but excluded: the current Google Fonts metadata exposes only Latin subsets. A silent Ukrainian fallback would make its comparison misleading.

All eleven families passed actual cmap checks for `ІіЇїЄєҐґ0123456789−×°`. The browser has an editable Ukrainian sample and equal-size Latin/numeral specimens, with font choice independent of composition. A family being clean or popular does not make it the owner's selected production font.

## Existing code analysis

- Actual `AppTheme._family` is Roboto; candidate Inter/Manrope are not the current production font.
- `AppSpacing`: 4, 8, 16, 24, 32, 48; `AppRadius`: 6, 12, 999.
- Fifteen text roles are exported with their actual size, line height and weight, plus app-bar 18/600.
- Buttons use a minimum 64 × 48 for filled/outlined, labelLarge, pressed 16%, focus 12%, hover 8%. Destructive colour is separate from ordinary hierarchy.
- Fields use semantic label/helper/error colours; the source contract specifies a 1 px control underline and 2 px focus treatment. Explicit screen borders retain their own contract.
- Motion: 150 / 250 / 1500 ms, easeOutCubic, with reduced-motion behavior and the AnimatedSize exception documented.
- All 35 AppPalette roles, including chart and Bortle arrays, are exported per theme. All ColorScheme mappings and raw AppColors are shown separately.
- Field-mode ColorScheme.surface is black; field cardColor/fieldSurface is dark red. The earlier conceptual surface alias was corrected in the token skill to retain this distinction.
- Ten documented shared-component contracts and 21 complete source files are bundled with hashes. The full DESIGN_SYSTEM.md includes words, confirmation/Undo rules, adoption and historical gaps; those dated records do not supersede current code or operational state.

The generated inventory is a read-only snapshot. `build_inventory.py` re-reads source files and fails if palette expressions or the type scale cannot be exported completely. It does not change the Flutter app. The separate font script refreshes licensed browser assets only when explicitly invoked.

## Completion evidence required

| Requirement | Evidence to inspect |
| --- | --- |
| More designs based on related applications | Seven rendered concepts, five source-linked reference analyses |
| Paper + Journal combination | Hybrid base and its night-section computed typography/layout |
| One-level gallery | Same-height horizontal rail, previous/next, direct selection and mobile behavior |
| More fonts | Eleven manifest families, actual assets/licences, glyph/hash checks, live browser overrides |
| All existing design-code information | Source hashes, generated inventory coverage, full Markdown/source viewer and focused catalogue tabs |
| Spacing, font and button examples | Live geometry/type specimens and functional component demonstrations |
| Reviewable final output | Current browser captures and the extension validation record in the lab evidence folder |

No production adoption, application acceptance or release claim follows from this lab extension.
