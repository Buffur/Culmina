# Culmina design skills and local design lab

Prepared 2026-10-19 from the owner's request and supplied notes for UI Collective's [Design with AI](https://www.youtube.com/watch?v=r-MPiu0E4W4). The video and attachment are references; their sample policies, model rankings and example debt exceptions are not repository instructions.

## Authority and scope

Status: active workflow reconciled 2026-10-24 against the integration baseline in [PROGRESS](../refinement/PROGRESS.md). Read [BASELINE](BASELINE.md) for approved final Hybrid, production sources, later P-1–P-6 / TD-120 / TD-121 / identity refinements, evidence and owner-acceptance limits. Geist and Source Serif 4 are adopted native families; other lab candidates remain proposals.

[AGENTS](../../AGENTS.md) defines current scope/permissions, [VERIFICATION_POLICY](../VERIFICATION_POLICY.md) owns V1–V8, [AI_WORKFLOW](../AI_WORKFLOW.md) owns coordination and handoff, [DESIGN_SYSTEM](../DESIGN_SYSTEM.md) and actual theme/components describe visual/interaction contracts. Read the owner's named task/decisions, not an assumed roadmap queue. Code proves implementation; an approved decision proves intent. Record a mismatch; neither a generic design skill nor a browser preference authorizes changing production.

The rest of this workflow retains the design-lab methods and dated evolution. Early descriptions of Manrope, proposal-only Hybrid and conditions-first Home are historical where superseded by BASELINE. Do not interpret a historical instruction as an active adoption or regeneration request.

## Five skills, loaded selectively

| Skill | Load when |
| --- | --- |
| [Tokens](../../.agents/skills/culmina-design-tokens/SKILL.md) | Mapping semantic roles to light/dark/field colours and control boundaries |
| [Components](../../.agents/skills/culmina-design-components/SKILL.md) | Choosing a form, navigation or data-display pattern |
| [Typography](../../.agents/skills/culmina-design-typography/SKILL.md) | Selecting a family, text role, line height or number treatment |
| [Spacing and shape](../../.agents/skills/culmina-design-spacing/SKILL.md) | Changing density, grouping, radii or responsive composition |
| [Rules and technical debt](../../.agents/skills/culmina-design-rules/SKILL.md) | Applying product decisions, scientific constraints or documented exceptions |

These are repository-local `.agents/skills` entrypoints with valid skill frontmatter. Read the relevant path explicitly if the host does not discover them; this change does not claim to register skills in every agent product. Example: “Read `.agents/skills/culmina-design-rules/SKILL.md` and `.agents/skills/culmina-design-components/SKILL.md`, then implement the named task using its frozen criteria.”

The actual workflow is: task/context → relevant skills and source contracts → a bounded comparison if a decision is open → implementation → scenario and token checks → evidence/handoff. Component documentation uses purpose, anatomy, variants, states, inputs, interactions, accessibility, exclusions and an actual adopter.

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

Executed checks and concept captures: [Home lab evidence](../../design/home-lab/evidence/README.md).

Research and the extension's acceptance checklist: [Reference research](REFERENCE_RESEARCH.md).

Current extension completion evidence: [Requirement audit](../../design/home-lab/evidence/REFERENCE_EXTENSION.md).

## Historical lab evolution — not current task instructions

The following dated sections preserve research/adoption provenance. Later native adoption and supersession are mapped in BASELINE.

### Hybrid refinement and gap repairs (2026-10-19)

The owner subsequently requested fixes from the video-guidance audit and a closer Notion/Apple study. See [research, component comparisons and the applied skill trial](NOTION_APPLE_STUDY_2026_10_19.md). The lab now has ten concepts; the default collection contains the original Hybrid plus Page, Soft and Desk. All four retain Journal's serif night heading and share the same data. The “All concepts” control retains the earlier comparisons.

Token usage metadata covers all 13 proposal roles and all 35 AppPalette roles. The JSON spacing and radius maps drive the intended browser geometry through CSS variables. The inventory is a dated source snapshot. Compare its recorded input hashes before relying on it; mismatch means historical coverage. A separately authorized checker can report staleness, but does not authorize regeneration of the frozen reference. No such regeneration belongs to documentation cleanup.

The component skill has three on-demand API/state references. Its isolated native application example is `test/presentation/design_system/skill_application_test.dart`; the completion evidence records the actual run. The trial demonstrates one explicitly loaded workflow, not universal host discovery or production adoption. [Current refinement evidence](../../design/home-lab/evidence/HYBRID_REFINEMENT.md) supersedes the prior extension record for the changed lab inputs.

## Official design-system research references

These sources supplement the earlier UI Collective video notes and the Notion, Google/Material, Linear, Things and Craft references; they do not replace them. Keep using the [earlier reference research](REFERENCE_RESEARCH.md) and [Notion/Apple study](NOTION_APPLE_STUDY_2026_10_19.md) for the relevant design decisions.

For future UI/UX documentation research, consult the [owner-supplied research brief](DESIGN_SYSTEM_RESEARCH_BRIEF.md): Apple Human Interface Guidelines, Microsoft Fluent 2 and Adobe Spectrum are the primary official references. Load relevant topics selectively, verify current documentation through the available Context7/Firecrawl integrations, distinguish shared principles from platform conventions, and cite official source URLs. The brief is a research method; it does not replace Culmina's existing decisions or the preferred Hybrid Notion + Journal direction.

## Home priority and the Plan page (2026-10-19)

The owner requested a review using the additional sources, removal of the Hybrid plan edge and a project-grounded Plan page. See [the focused review and source comparison](PLAN_CONCEPT_REVIEW_2026_10_19.md). The browser now compares plan-first and conditions-first explicitly; returning users with an existing plan are shown the plan-first recommendation by default. The four Hybrid plan summaries use open spacing, without borders, shadows or contrasting card fills. This sentence described the experiment's scope at that date; the later final transfer adopted the current plan-first native composition (BASELINE).

Open planner now navigates to `design/home-lab/plan.html`, a separate editable preview with selected context, target/rig, capture blocks, visible estimates, Details and persistent Save plan. Its dedicated localStorage sample can be saved/reopened and shown back on Home. Block Apply and plan Save remain distinct; unsaved changes, validation and failed-save/retry are demonstrated. All estimates use labelled fixture assumptions, not production astronomy or calibration-library calculations. [Current Plan/Home evidence](../../design/home-lab/evidence/PLAN_PREVIEW.md) records the changed inputs; earlier captures remain historical.

## Android target correction (2026-10-19)

The owner's latest brief requires an Android application format. The existing app is a functional reference; preserve the agreed Hybrid visual direction. The browser lab is a delivery host, not a proposed web product. Plan now stays inside a 412 logical-pixel phone viewport on desktop, with an Android top app bar, independent scrolling content and persistent lower Save. Block editing occupies a separate phone screen with Cancel and Apply. Home single-screen mode retains its phone navigation and single content column. All earlier references remain available; platform-specific Android conventions take precedence over Apple/desktop styling.

See the [updated Plan review](PLAN_CONCEPT_REVIEW_2026_10_19.md#android-format-correction) and [Android preview checks](../../design/home-lab/evidence/ANDROID_PREVIEW.md). Browser evidence remains concept-level; production Flutter and actual Android validation are separate.

## Complete Android planning prototype (2026-10-20)

The owner confirmed the browser Android prototype as the implementation target. Plan now includes scoped camera-class editors, calibration proposals, editable assumptions, stable Save and guarded draft/copy flows. Night/Moon/Weather share a viewed night distinct from the active plan; Home links to these screens and adds a compact time rail. Five CLI-agent runs contributed research, implementation, tests and review; their findings were reconciled against domain source and verified in the browser.

Use the [source/decision map](PLANNING_SCREENS_2026_10_19.md) and [P01–P12 completion evidence](../../design/home-lab/evidence/PLANNING_SCREENS.md) for these changed inputs. Earlier capture sets remain historical. The current browser proof does not close native, science or release gates.

## Owner quality review refinement (2026-10-20)

The subsequent owner brief refines the same Android browser prototype. Shared sky/Moon lanes, Home weather, Night/Moon facts, Moon focus, Weather hierarchy and Plan's target/WB/filter/rig/gain presentation now follow the [quality decisions and model constraints](QUALITY_REFINEMENT_2026_10_20.md). Three gain alternatives remain reviewable with the lab selector; the time curve is the default. No numeric focus control is invented for the AF/MF-only model.

Use [current quality completion evidence](../../design/home-lab/evidence/QUALITY_REFINEMENT.md) for these changed inputs, including actual CLI contribution/review outcomes and the local no-cache preview launcher. The preceding references and historical evidence remain available.

## Hybrid implementation refinement (2026-10-20)

The owner's subsequent R1–R8 / V1–V10 / F1–F2 task selects Settings-aligned initial assumptions and authorizes the original Hybrid's implementation refinement, revision `20261020-hybrid7`. This supersedes the open R1 choice in the continuation handoff. The implemented browser scope, acceptance matrix, source-based native feature comparison, screenshot pairs and actual QA results are in [the refinement report](HYBRID_REFINEMENT_2026_10_20.md). Weather stays compact on Home. Capture-file import is a labelled walkthrough, separate from real rig JSON import and backup restore; numeric MF remains unsupported by the model. Native adoption, tool installation, permissions and publication remain outside this pass.
