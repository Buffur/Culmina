# Home lab validation — 2026-10-19

Current extended-lab coverage (seven concepts, eleven fonts and the full catalogue): [Reference extension audit](REFERENCE_EXTENSION.md). The checks below describe the initial three-concept/five-font pass.

Scope: five repository-local skills, documentation integration and the isolated static browser lab. No Flutter application source, dependency, database, production font or roadmap criterion changed.

## Executed checks

- Skill Creator `quick_validate.py`: **5 / 5 PASS**. The system Python lacked PyYAML; validation dependencies were installed in a task-specific temporary directory, not in the repository or app dependencies.
- Local Markdown references in the workflow and skill index: **PASS**.
- `node --check design/home-lab/app.js`: **PASS**.
- Local HTTP requests for HTML, JavaScript, CSS, JSON and every bundled WOFF2 asset: **PASS**.
- FontTools cmap checks across each family's local subsets: **5 / 5 PASS** for `ІіЇїЄєҐґ0123456789−×°`. Actual browser specimens include Latin and Ukrainian.
- Browser computed family checks: Inter, Roboto, Manrope and IBM Plex Sans apply to body and headings; Source Serif 4 applies to headings with Inter body.
- `flutter analyze --no-pub`: **PASS**, “No issues found”, 105.1 seconds.
- `dart run tool/check_encoding.dart`: **PASS**, no mojibake.
- `git diff --check` and added text whitespace/reference inspection: **PASS**.

## Observed browser behavior

ChatGPT in-app browser, desktop 1440 px and mobile 412 × 915 CSS px:

- Planner: selecting M42 then Cancel leaves Andromeda unchanged; Save changes the displayed example to Orion.
- Selected night: Oct 20 changes the page to “Night of Oct 20” and the candidate action to “What can I image on Oct 20?”.
- Unavailable forecast: displays “Forecast unavailable” and Unknown, not 0% cloud.
- Missing site: “Needs a site”, with no calculated night/conditions group or fit verdict.
- At 412 px / 200% text, Paper, Focus and Journal have document width 402 px (scrollbar excluded) and frame content width equal to frame width, 345 px. No horizontal overflow observed.
- Field theme: the frame is black and the heading red; the documented production field-mode contrast exception remains explicit.
- Wide navigation: rail's right edge equals content's left edge after correcting its containing block; no overlap.
- Final sampled body/link/control text: no visible values below 12 px. The mechanical Impeccable scan originally flagged undersized metadata, which was corrected. Its Inter/Roboto familiarity warnings are intentionally retained choices for this owner's Notion/Google comparison, not blockers.
- Browser console warning/error snapshot: empty at the final check.

## Captures

- [Three concepts](desktop-comparison.jpg)
- [Wide Focus, light](desktop-focus-light.jpg)
- [Wide Focus, dark](desktop-focus-dark.jpg)
- [Mobile Journal, dark, 200% text](mobile-journal-dark-200.jpg)
- [Mobile Focus, field](mobile-focus-field.jpg)

The browser screenshot API returned JPEG bytes; filenames match that format. Viewport overrides were reset after testing. The local server is bound to `127.0.0.1:4173` and the gallery tab is retained as a deliverable.

## Evidence limits

These are HTML concept and simulated interaction checks. They do not establish real forecasting, astronomical accuracy, Flutter widget accessibility, phone behavior or human comprehension. No unit/widget/device suite, release build or CI run was performed for this artifact. Actual production adoption still uses the existing task's U/W criteria and applicable canonical verification.
