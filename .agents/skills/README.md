# Culmina agent skills

Use only guidance relevant to the current approved task. [AGENTS](../../AGENTS.md) owns scope, [PROGRESS](../../docs/refinement/PROGRESS.md) current state, [AI_WORKFLOW](../../docs/AI_WORKFLOW.md) execution and [VERIFICATION_POLICY](../../docs/VERIFICATION_POLICY.md) checks. Skill availability is not a task queue or permission to change architecture, dependencies, navigation or devices. Existing upstream metadata, licences and local amendments remain applicable.

## Culmina design routing

Read [BASELINE](../../docs/design/BASELINE.md) and select the task surface below; follow [WORKFLOW's section-reading route](../../docs/design/WORKFLOW.md#read-the-needed-contract). Reading DESIGN_SYSTEM means its relevant current section and actual caller, not a whole-file dump of adoption/update history. This also supplies project context requested by generic UI guidance; a Git-only query needs no design route. [WORKFLOW modes](../../docs/design/WORKFLOW.md#work-modes) remain the single Explore / Implement-Fix / Review definition. Open only the skill needed by the surface:

| Task | Entrypoint |
| --- | --- |
| Text roles, wrapping, weights or numeric readability | [Typography](culmina-design-typography/SKILL.md) |
| Colours/surfaces and light/dark/field mappings | [Tokens](culmina-design-tokens/SKILL.md) |
| Local density, alignment, padding, shape or motion | [Spacing](culmina-design-spacing/SKILL.md) |
| An existing control or display | [Components](culmina-design-components/SKILL.md), then only the affected form/navigation/data-display reference |
| Product meaning, scientific/data invariants or an exception | [Rules](culmina-design-rules/SKILL.md), then only the relevant decision/guardrail |
| Visual comparison, relevant external patterns or screenshot/source freshness | Read only needed [inspected reference patterns](../../docs/design/references/UI_REFERENCE_LIBRARY.md#local-fig-inspection) or [image-provenance rows](../../docs/design/references/UI_REFERENCE_LIBRARY.md#verification-addendum); follow [visual comparisons](../../docs/design/WORKFLOW.md#visual-comparisons) and the [Figma MCP/local-export route](../../docs/design/WORKFLOW.md#figma-access-and-inspection-depth) when relevant. Local exports prove declared structure, not live rendering/interaction; external examples are inspiration, not approved native rules. |

For a separately owner-authorized systemic review, follow [WORKFLOW's systemic route](../../docs/design/WORKFLOW.md#systemic-review-route): comprehensive review → root-cause grouping → bounded owner decision → implementation → native visual QA. Start with composition and shared-component contracts/callers, then load the existing skills as findings cross their surfaces. The [reference library](../../docs/design/references/UI_REFERENCE_LIBRARY.md) connects principles to sources/evidence; [OWNER_INBOX](../../docs/design/qa/OWNER_INBOX.md) owns finding dispositions and PROGRESS remains the sole current handoff. This route introduces no sixth skill, duplicate process, automatic audit or implementation permission.

Historical font/browser comparisons are linked on demand; production fixes do not require the lab history or every component group. Discovery differs by client: read the intended skill explicitly when needed rather than loading this entire directory.

## Supporting Flutter recipes

- [Layout diagnosis](flutter-fix-layout-issues/SKILL.md): diagnose a concrete constraint/overflow/ParentData problem before selecting flex, wrapping or scrolling.
- [Adaptive layout](flutter-build-responsive-layout/SKILL.md): only for a named adaptive-layout task; a phone overflow does not authorize a sidebar/grid or orientation/navigation changes.
- [Widget preview](flutter-add-widget-preview/SKILL.md): only for a named preview task; inspect existing native gallery/render fixtures and actual SDK support first.

Other Dart/Flutter recipes remain available for their specific task. Their examples never override current contracts or verification requirements.

## Inventory and provenance

The current installation consists of the SKILL.md files present in this directory. The [cleanup manifest](../../AUDIT_MANIFEST.md) records the per-file audit and [archive index](../../docs/archive/2026-10-27_cleanup/ARCHIVE_INDEX.md) preserves original recipes and pre-refactor metadata. `skills-lock.json` is retained upstream acquisition provenance; local amendments and archived recipes mean it is not an installed-skill census or a claim that local hashes match upstream.

ADK, native-asset/ffigen setup, checks-package migration and localization scaffolding were archived intact because their required stack or supporting workflow is absent. They are no longer active discovery entrypoints. Retained generic examples are explicitly optional references; they do not install dependencies or authorize another architecture. The existing integration-test correction and scope safeguards in the two previously dirty Dart recipes remain in force.

<a id="reading-route-examples-before-and-after"></a>

Historical reading-route comparisons: [preserved before/after section](../../docs/archive/2026-10-27_cleanup/navigation/snapshots/.agents/skills/README.md#reading-route-examples-before-and-after). The comparisons are historical evidence; current routing remains above.
