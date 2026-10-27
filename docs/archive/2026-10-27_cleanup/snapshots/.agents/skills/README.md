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

## Reading-route examples: before and after

Common preflight (AGENTS, PROGRESS, applicable overrides, relevant AI_WORKFLOW/verification and BASELINE) applies to both columns. These are source-based routing walkthroughs, not measured token savings or runtime client-loading tests.

| Request | Before this routing change | Current route |
| --- | --- | --- |
| Focused typography correction | WORKFLOW mixed production routing with the full lab chronology; typography entrypoint included candidate/font/specimen history | WORKFLOW mode → typography skill → DESIGN_SYSTEM §3 + AppTypography + affected text caller. No font research unless that decision is explicitly open. |
| Local phone layout error | Spacing entrypoint mixed native rhythm with browser variants; the generic layout recipe prescribed Expanded by error signature | WORKFLOW mode → spacing/affected contract → layout diagnostic recipe → causal ancestors/constraints/scroll owner. Read typography only if text roles are affected; no adaptive navigation or preview requirement. |
| Explicitly authorized new-variant study | WORKFLOW and skills interleaved current contracts with dated concepts and comparison instructions | WORKFLOW Explore → named open decision + BASELINE constraints → relevant skill(s) → only relevant lab/research references. Record proposal/evidence/owner choice; production adoption stays separate. |
