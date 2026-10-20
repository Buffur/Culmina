# Reference extension completion audit — 2026-10-19

This records the extended lab, superseding the original three-concept/five-font evidence for current lab coverage. Scope is the owner's Design Lab request; production application source and acceptance criteria were not changed.

## Requirement-by-requirement audit

| Owner requirement | Inspected current evidence | Result |
| --- | --- | --- |
| Find and analyse applications with a related design philosophy | Five official-source-linked entries in `references.json`, rendered reference accordions, and `docs/design/REFERENCE_RESEARCH.md`; Linear, Things and Craft extend the original Notion/Google references | PASS |
| Add different design variations using reference traits | Seven actual rendered concepts: Hybrid, Paper, Focus, Journal, Line, Calm, Folio. New Line/Calm/Folio each has its own composition/density/type CSS and source-linked rationale | PASS |
| Use a Paper/Notion base and Journal's night section | Hybrid is the default; actual computed body is Manrope and native night heading is Source Serif 4, with Journal-like open rows. An explicit font override also replaces that heading, so comparisons remain independent | PASS |
| Keep designs in a one-level slider | All seven concept top coordinates equal at desktop and mobile. Scroll content exceeds rail width without widening the document. Next moved 452.7 px and updated the visible range; keyboard ArrowRight moved 450.7 px. Direct Folio selection survives expansion into wide view | PASS |
| Find popular clean fonts and add examples | Eleven manifest families, including six added choices; official Google Fonts popularity/subset data, 75 local WOFF2 files, eleven OFL licences, SHA-256 per asset, editable Ukrainian/Latin/numeral samples and independent font overrides | PASS |
| Analyse and expose existing design code | All source hashes and exact file content checked. All 35 AppPalette roles resolve in each theme; every ColorScheme mapping and raw AppColors value is shown; 15 type roles, six spacing steps, three radii, three motion durations, ten documented component contracts and 21 full source snapshots are present | PASS |
| Include spacing, fonts, buttons and other examples | Interactive catalogue tabs, geometric specimens, full type scale, primary/secondary/tertiary/destructive/icon/disabled/loading controls, fields, error validation, radio/checkbox/switch, fit/saved states, disclosure, ContextLine, confirmation, motion and icons | PASS |
| Avoid overloading the page | One horizontal design rail, one font specimen workbench, seven focused catalogue tabs, and disclosures for full source/code and detailed metadata | PASS |
| Deliver a reviewable working result | Live loopback server at `127.0.0.1:4173`, retained browser tab, current screenshots and structured browser evidence | PASS |

## Checks actually executed

- `node --check` on `app.js` and `catalog.js`: PASS after the final JavaScript changes.
- Both Python helper sources parsed; `build_inventory.py` executed successfully, with no unresolved palette entries.
- SHA-256 and exact UTF-8 content for all 21 exported local source files: PASS against the worktree.
- Font cmap and SHA-256 checks: all eleven families PASS for `ІіЇїЄєҐґ0123456789−×°`.
- Local HTTP byte equality for 96 page/data/style/font/licence assets: PASS.
- Skill Creator validation on all five updated design skills: PASS.
- Markdown references and added text whitespace checks: PASS; `git diff --check`: PASS.
- `dart run tool/check_encoding.dart`: PASS.
- The existing `flutter analyze --no-pub` PASS is reused from the initial lab validation (105.1 s); this extension changes no Dart/app source, dependency, asset, platform or Flutter tooling input. No application suite, build, CI or device evidence is claimed.
- Impeccable scan: three `overused-font` findings (Inter/Roboto); no other categories. These are intentional comparison choices for the owner's Notion/Google direction. Raw findings: [detector JSON](reference-extension-detector.json).

## Browser verification

See [structured browser checks](reference-extension-browser-checks.json).

- At 412 × 915 / 200% text, all seven wide concepts: document 402 px (scrollbar excluded); frame and content both 345 px. No horizontal overflow.
- At mobile width all seven catalogue tabs retain document width 402 px. Large tables and code scroll inside their own containers.
- Slider at 412 px: 362 px rail, 2678 px scroll content, all seven cards on the same top coordinate.
- Mobile header section links are visible and work after the responsive navigation correction.
- All eleven families were selected through the live control and their computed body/heading families inspected. Source Serif 4 deliberately keeps Inter body.
- Font workbench accepts edited Ukrainian text. Applying Golos Text through the specimen button changes the live selector and rendered app family to Golos Text.
- Token search `chart`: eleven matching rows; clearing restores all 35.
- Type table: fifteen rows. Geometry: six spacing samples and 6/12/999 radius values.
- Full DESIGN_SYSTEM.md viewer renders ten major sections and 44,542 content characters, with the unmodified raw Markdown also available in the source list. All 21 source panels exist.
- Empty Plan name marks the field invalid and exposes an error; entering a value clears invalid state.
- Loading button exposes `aria-busy=true`, disables temporarily, then restores. Destructive dialog has the accessible name “Delete example?”; Cancel closes it without effects. The switch can be checked.
- Motion disclosure expands/collapses. Reduced-motion behavior is implemented in CSS and documented from source; no OS accessibility preference was changed to claim platform testing.
- Field view uses black/red; non-field colour swatches become black while hex values remain available as text. This preserves the field view while documenting all themes.
- Final browser warning/error snapshot: empty. Viewport overrides reset; final state is the Hybrid slider, light theme, native fonts, 100% text.

## Captures

- [Hybrid and horizontal gallery](reference-extension-slider.jpg)
- [New Line, Calm and Folio concepts](reference-extension-new-variants.jpg)
- [Component catalogue](reference-extension-catalog.jpg)
- [Font workbench](reference-extension-fonts.jpg)
- [Mobile Hybrid, 200% dark](reference-extension-mobile.jpg)

These are browser concept examples with illustrative data. They do not establish real forecasting, scientific calculation, Flutter widget rendering, physical-device accessibility or independent human comprehension.
