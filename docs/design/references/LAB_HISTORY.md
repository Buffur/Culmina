# Design-lab history and comparison references

Historical/reference material relocated on 2026-10-24 from the working tree based on `4ac20a9519d3444f2877c1ba5a61dd1f219b4659`, including the preceding uncommitted design-skill reconciliation. Original wording below is retained; relative Markdown links are rebased for this location. These dated descriptions and example commands are not active tasks, production norms, permission to regenerate the frozen lab or new acceptance. Current routing is [WORKFLOW](../WORKFLOW.md); current sources/approval boundaries are [BASELINE](../BASELINE.md). No font assets, licences, evidence or reports were moved or changed.

Prepared 2026-10-19 from the owner's request and supplied notes for UI Collective's [Design with AI](https://www.youtube.com/watch?v=r-MPiu0E4W4). The video and attachment are references; their sample policies, model rankings and example debt exceptions are not repository instructions.

## Historical browser comparison and optional preview method

Run from the repository root:

```powershell
python -m http.server 4173 --bind 127.0.0.1 --directory design/home-lab
```

Open `http://127.0.0.1:4173`. It is a dependency-free static lab served on loopback, with local licensed font files. No network service or database is used by the page. Preferences are stored only in browser localStorage; the reset control clears the lab's own key.

- **Paper / Inter:** flat, Notion-inspired rows and restrained outlines; close to the current visual vocabulary.
- **Focus / Roboto:** Google-inspired tonal grouping, softer panels and a clearer split between conditions and action.
- **Journal / Source Serif 4 + Inter:** editorial headings and generous separation; compare heading character without sacrificing functional body text.
- **Hybrid / Manrope (early historical candidate):** the owner's then-preferred Paper-like base with Journal's The night ahead section; Source Serif 4 appears only in the section heading.
- **Line / Geist:** Linear-inspired alignment, compact metadata and section boundaries.
- **Calm / Onest:** Things-inspired breathing room and a clearly separated next action.
- **Folio / Source Sans 3:** Craft-inspired document rhythm and open sections.
- There are **eleven** independent font choices: the original five plus Open Sans, Noto Sans, Source Sans 3, Geist, Onest and Golos Text. The specimen workbench compares the same editable Ukrainian sample, Latin and measurements. Official metadata, licences and font hashes are bundled; font popularity is not treated as a quality score.

All seven concepts occupy a single horizontal slider with previous/next controls, keyboard arrows and direct concept selection. The single-screen mode shows one selected Android phone concept without expanding its app layout into desktop columns. That describes the initial 2026-10-19 experiment. The later final Hybrid / Geist reference was selected and transferred; BASELINE separates it from the other candidates.

Compare the same fixture in all variants. Controls include light/dark/field, font, text scale, scenario, a selected-night picker, a detail view, and a local planner draft with explicit save/cancel. These are prototype interactions, not real astronomy, weather, persistence or production routing.

Home source: `lib/presentation/screens/tonight/tonight_home_screen.dart`; tab contract: `lib/presentation/navigation/app_shell.dart`. The fixture covers context, conditions (night/Moon/weather), a due result, plan state/fit, Open planner and candidates. No Start, universal quality score or telescope control is introduced.

## Proposed design code

`design/home-lab/tokens.json` contains a dated colour snapshot, role descriptions and prototype-only proposal overlays. `app.js` applies these roles; CSS consumes them rather than scattering colour literals. All compositions share a fixture so content does not bias comparison. The prototype is not a replacement design-system source.

`scripts/build_inventory.py` exports the current local design sources into `inventory.json`: all 35 AppPalette roles in three themes, ColorScheme mappings, every raw AppColors constant, the typography, spacing and radius set recorded at export time, motion values, ten documented component contracts and 21 complete source files with SHA-256. The catalogue has focused tabs instead of expanding everything at once. Source snapshots include the entire DESIGN_SYSTEM.md, theme implementations and relevant shared components. Historical adoption text remains historical; the current local implementation and decisions retain authority.

Interactive HTML analogues include button hierarchy, disabled/loading/error states, input focus/error, single/multiple choice, status blocks, plan states, ContextLine, collapsible detail, confirmation and reduced-motion behavior. They are browser examples, not Flutter components.

Font sources and individual licences are in `design/home-lab/fonts/`. Sources for inspiration: [Notion Calendar](https://www.notion.com/product/calendar), [Material typography](https://m3.material.io/styles/typography/overview), and the official Google Fonts family repositories. No Google/Notion logos, proprietary fonts or visual assets are copied.

## Adoption and evidence

A selected variant needs a short delta against production: family, semantic colours, spacing/radii, composition, component reuse and affected states. Apply that delta inside the authorized task, then check actual Flutter widgets under existing U/W criteria. A browser screenshot is concept evidence only; it cannot close a Flutter, emulator or physical-device row.

For this lab, validate skill frontmatter/references, JavaScript syntax, loopback serving, local fonts, keyboard controls, the main interactions and responsive rendering. Record actual checks and limitations with the artifact. Do not claim application tests or accessibility certification from a browser concept.

Executed checks and concept captures: [Home lab evidence](../../../design/home-lab/evidence/README.md).

Research and the extension's acceptance checklist: [Reference research](../REFERENCE_RESEARCH.md).

Current extension completion evidence: [Requirement audit](../../../design/home-lab/evidence/REFERENCE_EXTENSION.md).

## Historical lab evolution — not current task instructions

The following dated sections preserve research/adoption provenance. Later native adoption and supersession are mapped in BASELINE.

### Hybrid refinement and gap repairs (2026-10-19)

The owner subsequently requested fixes from the video-guidance audit and a closer Notion/Apple study. See [research, component comparisons and the applied skill trial](../NOTION_APPLE_STUDY_2026_10_19.md). The lab now has ten concepts; the default collection contains the original Hybrid plus Page, Soft and Desk. All four retain Journal's serif night heading and share the same data. The “All concepts” control retains the earlier comparisons.

Token usage metadata covers all 13 proposal roles and all 35 AppPalette roles. The JSON spacing and radius maps drive the intended browser geometry through CSS variables. The inventory is a dated source snapshot. Compare its recorded input hashes before relying on it; mismatch means historical coverage. A separately authorized checker can report staleness, but does not authorize regeneration of the frozen reference. No such regeneration belongs to documentation cleanup.

The component skill has three on-demand API/state references. Its isolated native application example is `test/presentation/design_system/skill_application_test.dart`; the completion evidence records the actual run. The trial demonstrates one explicitly loaded workflow, not universal host discovery or production adoption. [Current refinement evidence](../../../design/home-lab/evidence/HYBRID_REFINEMENT.md) supersedes the prior extension record for the changed lab inputs.

## Official design-system research references

These sources supplement the earlier UI Collective video notes and the Notion, Google/Material, Linear, Things and Craft references; they do not replace them. Keep using the [earlier reference research](../REFERENCE_RESEARCH.md) and [Notion/Apple study](../NOTION_APPLE_STUDY_2026_10_19.md) for the relevant design decisions.

For future UI/UX documentation research, consult the [owner-supplied research brief](../DESIGN_SYSTEM_RESEARCH_BRIEF.md): Apple Human Interface Guidelines, Microsoft Fluent 2 and Adobe Spectrum are the primary official references. Load relevant topics selectively, verify current documentation through the available Context7/Firecrawl integrations, distinguish shared principles from platform conventions, and cite official source URLs. The brief is a research method; it does not replace Culmina's existing decisions or the preferred Hybrid Notion + Journal direction.

## Home priority and the Plan page (2026-10-19)

The owner requested a review using the additional sources, removal of the Hybrid plan edge and a project-grounded Plan page. See [the focused review and source comparison](../PLAN_CONCEPT_REVIEW_2026_10_19.md). The browser now compares plan-first and conditions-first explicitly; returning users with an existing plan are shown the plan-first recommendation by default. The four Hybrid plan summaries use open spacing, without borders, shadows or contrasting card fills. This sentence described the experiment's scope at that date; the later final transfer adopted the current plan-first native composition (BASELINE).

Open planner now navigates to `design/home-lab/plan.html`, a separate editable preview with selected context, target/rig, capture blocks, visible estimates, Details and persistent Save plan. Its dedicated localStorage sample can be saved/reopened and shown back on Home. Block Apply and plan Save remain distinct; unsaved changes, validation and failed-save/retry are demonstrated. All estimates use labelled fixture assumptions, not production astronomy or calibration-library calculations. [Current Plan/Home evidence](../../../design/home-lab/evidence/PLAN_PREVIEW.md) records the changed inputs; earlier captures remain historical.

## Android target correction (2026-10-19)

The owner's latest brief requires an Android application format. The existing app is a functional reference; preserve the agreed Hybrid visual direction. The browser lab is a delivery host, not a proposed web product. Plan now stays inside a 412 logical-pixel phone viewport on desktop, with an Android top app bar, independent scrolling content and persistent lower Save. Block editing occupies a separate phone screen with Cancel and Apply. Home single-screen mode retains its phone navigation and single content column. All earlier references remain available; platform-specific Android conventions take precedence over Apple/desktop styling.

See the [updated Plan review](../PLAN_CONCEPT_REVIEW_2026_10_19.md#android-format-correction) and [Android preview checks](../../../design/home-lab/evidence/ANDROID_PREVIEW.md). Browser evidence remains concept-level; production Flutter and actual Android validation are separate.

## Complete Android planning prototype (2026-10-20)

The owner confirmed the browser Android prototype as the implementation target. Plan now includes scoped camera-class editors, calibration proposals, editable assumptions, stable Save and guarded draft/copy flows. Night/Moon/Weather share a viewed night distinct from the active plan; Home links to these screens and adds a compact time rail. Five CLI-agent runs contributed research, implementation, tests and review; their findings were reconciled against domain source and verified in the browser.

Use the [source/decision map](../PLANNING_SCREENS_2026_10_19.md) and [P01–P12 completion evidence](../../../design/home-lab/evidence/PLANNING_SCREENS.md) for these changed inputs. Earlier capture sets remain historical. The current browser proof does not close native, science or release gates.

## Owner quality review refinement (2026-10-20)

The subsequent owner brief refines the same Android browser prototype. Shared sky/Moon lanes, Home weather, Night/Moon facts, Moon focus, Weather hierarchy and Plan's target/WB/filter/rig/gain presentation now follow the [quality decisions and model constraints](../QUALITY_REFINEMENT_2026_10_20.md). Three gain alternatives remain reviewable with the lab selector; the time curve is the default. No numeric focus control is invented for the AF/MF-only model.

Use [current quality completion evidence](../../../design/home-lab/evidence/QUALITY_REFINEMENT.md) for these changed inputs, including actual CLI contribution/review outcomes and the local no-cache preview launcher. The preceding references and historical evidence remain available.

## Hybrid implementation refinement (2026-10-20)

The owner's subsequent R1–R8 / V1–V10 / F1–F2 task selects Settings-aligned initial assumptions and authorizes the original Hybrid's implementation refinement, revision `20261020-hybrid7`. This supersedes the open R1 choice in the continuation handoff. The implemented browser scope, acceptance matrix, source-based native feature comparison, screenshot pairs and actual QA results are in [the refinement report](../HYBRID_REFINEMENT_2026_10_20.md). Weather stays compact on Home. Capture-file import is a labelled walkthrough, separate from real rig JSON import and backup restore; numeric MF remains unsupported by the model. Native adoption, tool installation, permissions and publication remain outside this pass.


## Token catalogue and early colour studies

Relocated from `.agents/skills/culmina-design-tokens/SKILL.md` (pre-routing file SHA-256 `921e0e82347dda24be18ad1a7f8bd74f7a6ee202fa5bfc4e3c3cf79c817457d3`). Dated reference; use the current skill and native definitions for production.

The Design code → Colours catalogue exposes all 35 AppPalette roles (including arrays), ColorScheme mappings and raw AppColors. `inventory.json` is generated from the local source with hashes using `scripts/build_inventory.py`. In field mode ColorScheme.surface is black while cardColor/fieldSurface is dark red; keep that distinction explicit. The source catalogue is evidence, not a second editable token authority.

The proposal file now describes every colour role and foreground/background pairing; `paletteUsage` explains every exported production palette role. The catalogue is a dated, frozen source export. Compare its recorded hashes with the relevant current sources before relying on it; a mismatch means historical coverage, not permission to regenerate it. Any explicitly authorized inventory check proves source/metadata consistency only, not visual or semantic acceptance.

- Quality brief 2026-10-20: neutral by default; colour only where grey cannot carry the information (sky state, Moon lanes, weather caution), each with a second non-colour cue. Exact browser values, boundaries and limits: `docs/design/QUALITY_COLOR_GUIDANCE_2026_10_20.md`. These are prototype variables in `design/home-lab/night.css`, not production tokens or entries in `tokens.json`.
- Original Hybrid `20261020-hybrid7` lightens the Dusk/Slate/Ink sky ramps only under `data-variant=blend` / `.variant-blend`. Field remains red/black; darkness boundaries and Moon lane geometry retain their meaning. The removed Dark-legend pseudo-element was decoration, not focus. See `docs/design/HYBRID_REFINEMENT_2026_10_20.md`; do not copy an early proposal into native tokens or other variants. Later approved native roles are already in HybridTokens; inspect that source and BASELINE.

## Spacing and browser-geometry studies

Relocated from `.agents/skills/culmina-design-spacing/SKILL.md` (pre-routing file SHA-256 `ccd7762df6728d50972c92dd1f31617bd52abaa3a9813593514dec30a958cd64`). Dated reference; use the current skill and native definitions for production.

- The lab retains historical Hybrid, Paper, Focus, Journal, Line, Calm and Folio comparisons. The final Hybrid is adopted under BASELINE; unrelated candidates and Soft's radius remain proposals. Inspect current native tokens/layouts before applying any proposal.

Historical browser implementation/reference notes (not current native instructions): the lab consumes JSON `space` as `--space-*`, `productionRadius` as `--radius-*`, and `proposalRadius` as each concept's `--concept-radius`. These control group rhythm and plan containers; remaining responsive chrome dimensions are local CSS choices. The Hybrid family adds Page / Soft / Desk; Soft's 14 radius remains a proposal.

Original Hybrid `20261020-hybrid7` keeps Save/Open planner full width and uses content-width secondary actions with at least 48 px targets. Plan context rows use whitespace and consistent icon-free leading alignment; navigation/data boundaries retain separators. Proposal motion tokens are 120 ms feedback and 180 ms view continuity, with reduced motion disabled. These browser-only rules live in `hybrid-refinement.css` / `tokens.json.hybridRefinement`; production `AppMotion` and other concepts remain unchanged.

At 200% browser text, the original Hybrid's four bottom destinations reflow into two rows, retaining full destination words and the requested 22 px labels instead of mid-word breaks or a text-size cap. Normal text keeps the established four-column bar. This describes the browser concept only; current native navigation and compact typography exceptions are mapped in BASELINE and AppTypography. Do not silently replace them.

## Historical candidate comparisons

Relocated from `.agents/skills/culmina-design-typography/SKILL.md` (pre-routing file SHA-256 `1418642be69ab60e7e5d1058e6179913c45d04e2940760c119d7a38eda6e3fcc`). Dated reference; use the current skill and native definitions for production.

| Family | Intended comparison | Useful sample |
| --- | --- | --- |
| Inter | Neutral workspace, Paper default | Tonight · Night of Oct 19 |
| Roboto | Familiar Google-like functional UI, Focus default | Your plan · Open planner |
| Manrope | Slightly warmer geometric alternative | Ніч спостереження · Обрати ціль |
| IBM Plex Sans | Distinctive, compact labels and scientific values | 120 × 60 s · 2 h · 3.6 GB |
| Source Serif 4 | Journal headings only, paired with Inter body | A little more time under the stars |
| Open Sans | Widely used open forms; compare long labels | Forecast unavailable · Прогноз недоступний |
| Noto Sans | Neutral multilingual option | Іі Її Єє Ґґ · Unknown |
| Source Sans 3 | Humanist compact alternative; Folio | Night conditions · Умови ночі |
| Geist | Precise UI option; Line | Needed 2 h 15 min · Usable 4 h 15 min |
| Onest | Softer functional alternative; Calm | Open planner · Переглянути план |
| Golos Text | Cyrillic and information density | Ніч спостереження · План зйомки |

Compare the same content and composition before attributing improvement to a font. The lab includes a dedicated specimen section and an independent font override. Source Serif 4 is an optional editorial comparison, not a blanket serif UI.

`design/home-lab/fonts/sources.json` records official source URLs, licences, hashes, subsets and the Google Fonts `popularity` field at the recorded date. Treat that field as service metadata, not a quality score or installation share. The current Google Fonts DM Sans was excluded because it lacks Cyrillic subsets. Refresh assets through `design/home-lab/scripts/sync_fonts.py` only when a font refresh is requested.

Historical preference (2026-10-19): Paper-like base with Journal's night section, initially compared with Manrope. That early candidate is superseded for production by the adopted Geist / Source Serif 4 final Hybrid reference; see BASELINE. Preserve its font assets/licences as reference.


Historical browser comparison: the Notion/Apple refinement used Inter for Hybrid Page, Onest for Soft and Manrope for Desk, each with Source Serif 4 only in the night heading. The study recorded NotionInter/Inter on Notion and SF Pro Text/Display on Apple. These observed CSS stacks are not licences or a guarantee of the rendered glyph face. Use the local candidates; read `docs/design/NOTION_APPLE_STUDY_2026_10_19.md` when comparing these references.

Historical earlier port: the original Hybrid (`blend`, browser revision `20261020-hybrid7`) uses opt-in `tokens.json.hybridRefinement` roles: 16 px body/data, 14 px support/actions and 13 px metadata, multiplied by text scale. Display headings retain their established sizes; this is a selective readability refinement, not a global font-size increase or a Flutter scale change. See `docs/design/HYBRID_REFINEMENT_2026_10_20.md` for theme/200% evidence.

## Component browser comparisons

Relocated from `.agents/skills/culmina-design-components/SKILL.md` (pre-routing file SHA-256 `769094067aa2ad847a738337a65c0dbbfc72779415634f98275c73d1af4f5672`). Dated reference; use the current skill and native definitions for production.

Historical comparison: the 2026-10-19 browser review explored plan-first/conditions-first and a separate Plan page. The later approved final Hybrid transfer adopted the current plan-first native composition; use BASELINE and the actual source rather than that early experiment as current authority. Plan editing follows the actual planner's fit/context/target/rig/blocks/estimates/Details/Save contracts. Read `docs/design/PLAN_CONCEPT_REVIEW_2026_10_19.md` for source links and the prototype boundary.

The local browser catalogue (`design/home-lab/`, Design code → Components) includes working button states, fields, radio/checkbox/switch, fit and saved-state labels, a collapsible section and ContextLine analogues. The full ten documented component contracts are included there. They are HTML analogues; check real Flutter widgets before claiming production acceptance.

## Product-reference provenance

Relocated from `.agents/skills/culmina-design-rules/SKILL.md` (pre-routing file SHA-256 `71ab3e71c2cc27c4d17024c6da8b1897bfb1a20b9972f37aff565a47fc58ef2e`). Dated reference; use the current skill and native definitions for production.

- The 2026-10-19 Notion/Paper + Journal preference is historical provenance. Hybrid/Geist was subsequently adopted and its final transfer accepted within its §9 contract. Other gallery concepts remain proposals; later TD-120/TD-121 and identity acceptance boundaries are in BASELINE.

The owner explicitly requires an **Android app** concept. The browser is only the preview host. Preserve the approved restrained Hybrid Notion + Journal direction; use the existing application for functions, data and workflows, not as a visual template. Android anatomy governs app bars, Back, Material controls, touch targets, scrolling, system/keyboard insets and text scaling. Keep lab controls outside the app viewport. A desktop browser must not turn the phone concept into a web dashboard. Prior Apple, Fluent and Spectrum research supplies transferable principles, not Android component styling. Browser captures do not prove native gestures, keyboard behavior or device acceptance.
