> **Historical navigation copy — not active instructions.** Link destinations are rebased from `docs/design/VIDEO_GUIDANCE_AUDIT_2026_10_19.md`. Content and acceptance statements retain their original date/scope. [Immutable original](../../../docs/design/VIDEO_GUIDANCE_AUDIT_2026_10_19.md) · [Navigation index](../../../NAVIGATION.md). Original SHA-256: `1304265c54fa3421881fa8d61ebb54f95e7a99a4d893e5b06d829c89dfd7c71e`.

# Video guidance audit — 2026-10-19

Assessment of the current Culmina design skills and Home Lab against the owner's supplied extract of UI Collective's “AI + Design Systems: The Honest Truth Nobody's Telling You”. Input: attachment `081ac361-dffc-4d42-bf3c-92404cbe58f9/Pasted text.txt`. This assesses the supplied guidance; it does not independently verify the video's platform anecdotes or numerical claims.

Verdict: the modular workflow is substantially aligned. The lab is a useful comparison and source-inspection tool. Complete semantic metadata, a more explicit component API map and a demonstrated skill-to-Flutter workflow remain unfinished. No conformity percentage is justified by the available evidence.

Subsequent owner-authorized repairs are recorded in [the Notion/Apple study](NOTION_APPLE_STUDY_2026_10_19.md) and its completion evidence. Findings below retain their original assessment-time meaning.

## Criteria and evidence

“Aligned” means an inspected artifact implements the relevant practice. “Partial” identifies a concrete limitation. “Unverified” means no suitable evidence was found; it does not assert failure.

| Extracted practice | Result | Current repository evidence and limits |
| --- | --- | --- |
| Use modular skills rather than one universal design file | Aligned | Five small entrypoints: tokens, components, typography, spacing and rules. [Routing](../../../../../../.agents/skills/README.md) and [workflow](../../../../../design/WORKFLOW.md) specify selective reading. Keeping a canonical DESIGN_SYSTEM.md as a referenced contract is compatible with this practice. |
| Load only relevant context and component groups | Aligned in instructions; execution unverified | The component skill has Form elements, Navigation and Data display sections; CLAUDE.md explicitly avoids assuming automatic skill discovery. There is no recorded independent trial demonstrating reliable selection across agents or hosts. |
| Define token values and their intended use | Partial | The token skill maps semantic roles to actual Flutter sources. The catalogue exports 35 AppPalette roles for light/dark/field. The separate proposal JSON has 13 colour roles per theme but usage descriptions for only nine. See F1. |
| Distinguish raised, subtle and sunken surfaces | Mostly aligned | The token skill explicitly reserves sunken for the prototype and distinguishes field cardColor from ColorScheme.surface. The proposal metadata still labels surface-subtle generically as ColorScheme.surface, omitting that field exception. |
| Record variants, properties and component structure by category | Partial | Existing Flutter implementations and DESIGN_SYSTEM.md contain meaningful contracts: StatusBlock has state, durations, reason, key numbers and an action slot; CollapsibleSection has remembered and controlled operation. The new skill routes to those sources but is not a complete API/state matrix for every component it names. Ten exported narrative contracts do not establish complete component coverage. |
| Reuse real components instead of trusting generated appearances | Aligned as a rule; new adoption unverified | Actual shared Flutter components and their native gallery already exist. The browser demos are explicitly HTML analogues. No generated Home concept has been adopted into Flutter, so those demos cannot demonstrate native reuse or variant geometry. |
| Research references at component level as well as screen level | Partial | [Reference research](../../../../../design/REFERENCE_RESEARCH.md) explains hierarchy, density, typography and grouping from five official sources. It does not yet compare specific picker/menu/input alternatives with interaction and state tradeoffs. Such research is useful when a concrete component decision is open, not a mandatory new research project. |
| Preserve existing typography and inspect alternatives in HTML | Aligned | Typography skill uses the existing Material roles; source catalogue exposes all 15 roles. Eleven licensed local font candidates have Ukrainian/Latin/numeral specimens. Candidate fonts remain proposals. |
| Explain product rules and real debt exceptions | Aligned | Rules skill preserves scientific meaning, Unknown, draft boundaries and fit versus persistence. It cites the real field-mode contrast exception and live debt/decision registers. Video examples do not become company policy. |
| Keep design sources traceable and avoid an isolated source of truth | Partial | All 21 exported source files currently match their hashes and full text. Inventory refresh is manual; a later source edit can leave the browser catalogue stale. Geometry metadata and rendered CSS are also maintained separately. See F2. |
| Audit the result using appropriate system checks | Partial | Existing Flutter tests check theme wiring, text contrast, minimum type size, hard-coded presentation colours and real gallery controls. Prior lab evidence covers browser behavior. These are valuable checks but do not prove that a newly instructed agent applied all relevant rules. See F4. |
| Retain human judgment for semantics and final adoption | Aligned in workflow; adoption pending | Candidate comparisons, owner preference and approved production choices are explicitly distinguished. No fixed amount of manual polishing or “on-system” score has been measured. |

## Bounded follow-ups

These are recommendations from this assessment, not newly approved release gates or a replacement roadmap. No fixes were applied during this audit.

### F1 — Complete and reconcile token usage metadata

Evidence: [tokens.json](../../../../../../design/home-lab/tokens.json) has values but no `roles` usage descriptions for `action`, `on-action`, `selection` and `error`. Its surface-subtle description omits the field mapping already documented correctly in the [token skill](../../../../../../.agents/skills/culmina-design-tokens/SKILL.md).

For a follow-up, describe each role's permitted use, foreground/background pairing and exceptions; reconcile the field alias. Acceptance: every proposal role has a meaningful description and consistent theme-specific mapping. Existing functional chart colours need their domain meaning preserved; a generic “scientific chart” label alone is not a full usage contract.

### F2 — Connect metadata to rendering and check snapshot freshness

Evidence: `space`, `productionRadius` and `proposalRadius` exist in proposal JSON, but neither [app.js](../../../../../../design/home-lab/app.js) nor [catalog.js](../../../../../../design/home-lab/catalog.js) reads those properties. [styles.css](../../../../../../design/home-lab/styles.css) independently contains spacing and radius literals. This establishes duplicate maintenance, not a demonstrated current numerical mismatch. [build_inventory.py](../../../../../../design/home-lab/scripts/build_inventory.py) refreshes the source snapshot only when explicitly run.

For a follow-up, consume declared geometry through CSS variables where it is intended to control the UI, or remove misleading duplicate configuration and document the actual owner. Add a narrow read-only freshness check that names changed source files. Acceptance: changing a declared preview token changes its intended sample; a stale inventory is detected. Prototype proposals must remain distinguishable from production constants.

### F3 — Make relevant component contracts easier to apply

Evidence: [component skill](../../../../../../.agents/skills/culmina-design-components/SKILL.md) provides good category routing and documentation requirements, but properties, slots and allowed combinations still require reading several original files. The inventory covers selected shared components, not every input referenced by the skill.

For the components touched by an actual task, add a compact source-linked index of variants, required/optional inputs, slots, controlled state, accessibility behavior and a real adopter/check. Use original Flutter types as authority; avoid duplicating the entire library or generating a second set of components. Acceptance: the relevant category explains which existing API handles the scenario and which state combinations need verification.

### F4 — Demonstrate skill application on one bounded task

Existing checks are substantive: [design_tokens_test.dart](../../../../../../test/core/theme/design_tokens_test.dart), [presentation_style_rules_test.dart](../../../../../../test/presentation/theme/presentation_style_rules_test.dart), [design_system_gallery_test.dart](../../../../../../test/presentation/design_system/design_system_gallery_test.dart), and [gallery_entries.dart](../../../../../../test/presentation/design_system/gallery_entries.dart) use actual production tokens and widgets. These are not evidence that the new skills caused a correct implementation.

When an authorized Flutter UI task is available, record the relevant skill selection, actual component instances, semantic token mapping, intentional deviations and affected state checks. Review that result against the task and CLAUDE.md V1–V8. A small isolated trial may instead be used if explicitly requested. Acceptance: a reviewer can trace requirement → skill/contract → actual widget/token → appropriate evidence. Do not change production merely to manufacture a demonstration for this audit.

## Advice that should not become a literal requirement

- Single versus multiple selection follows the data model: option count alone never changes radio/select into checkboxes. The component skill already corrects the extract's example.
- Mobbin and Figma are optional tools. Flutter constructors, slots and theme contracts are the relevant equivalents of component properties and instances in this repository. No Figma/GitHub synchronization was exercised here.
- “About 10% manual polish” is an illustrative claim, not our measured workload or acceptance threshold. A conformity percentage requires an agreed scope, denominator, allowed exceptions and a repeatable check.
- A four-unit typography example does not authorize replacing the existing 14 sp roles. Existing styles and actual widget readability take precedence.
- A long reference document is not itself a violation. Loading the whole document for every trivial edit would defeat selective context; the current routing does not require that.

## Checks and evidence boundary

Executed during this assessment:

- Read the supplied extract, all five design skills, routing/workflow, reference analysis, relevant canonical component contracts, native widget APIs, generator and browser sources.
- Recomputed SHA-256 and compared exact decoded content for all 21 exported source files: PASS, no drift.
- Inspected inventory coverage: 35 palette roles in three themes, 15 type roles, six spacing steps, three radii and ten documented contracts. These are coverage counts, not conformity scores.
- Compared proposal theme keys against usage descriptions and traced geometry configuration consumers; findings F1/F2 are reproducible from current files.
- Inspected existing Flutter test sources. They were not executed in this documentation-only assessment; no fresh native-test PASS is claimed.

The [previous browser verification](../../../../../../design/home-lab/evidence/REFERENCE_EXTENSION.md) remains evidence of the unchanged lab's recorded interactions, fonts and responsive layouts. This assessment did not repeat that browser run. Skill frontmatter validation and an aesthetic detector scan do not establish semantic or component conformance. No Flutter implementation, tests, production tokens, skills or lab behavior were changed by this audit.
