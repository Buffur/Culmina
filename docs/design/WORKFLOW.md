# Culmina design workflow

<a id="culmina-design-skills-and-local-design-lab"></a>

## Authority and scope

Use [AGENTS](../../AGENTS.md), the current owner task and [PROGRESS](../refinement/PROGRESS.md) for scope/state; [AI_WORKFLOW](../AI_WORKFLOW.md) for execution; [VERIFICATION_POLICY](../VERIFICATION_POLICY.md) for checks. [BASELINE](BASELINE.md) maps the accepted Hybrid/native sources and later refinements. [DESIGN_SYSTEM](../DESIGN_SYSTEM.md), actual theme/components and relevant decisions supply the contract. Code proves implemented behavior; decisions prove accepted intent. A mismatch is a finding, not permission to rewrite either.

For a production task, read the relevant sections and source/callers, not this workflow's historical references. Links are navigation, not recursive imports. A skill does not authorize changing scope, dependencies, navigation, the frozen browser reference or acceptance.

## Read the needed contract

For production work, use BASELINE to identify the accepted source, choose the relevant skill below, then read only its current DESIGN_SYSTEM section and native definition/caller. Use the heading index or a named anchor to locate the section before reading its body. A request to read DESIGN_SYSTEM, including generic UI project-context guidance, is satisfied by this scoped contract read; a full-file dump also loads historical adoption/update logs and is not the default route.

| Task surface | Current contract to inspect |
| --- | --- |
| Weather selection, surfaces or colour semantics | [§2 Colour](../DESIGN_SYSTEM.md#2-colour), then the relevant rows of the token skill's semantic map |
| Tonight site/night actions and states | [Context line](../DESIGN_SYSTEM.md#context-line), then the components navigation reference |
| Local text hierarchy | [§3 Type scale](../DESIGN_SYSTEM.md#3-type-scale-apptypographyscale), then the affected text caller |
| Padding/density or a constraint problem | [§4 Spacing](../DESIGN_SYSTEM.md#4-spacing-and-radius), plus the diagnostic recipe only for constraint mechanics |
| Another component | Its named §6/§7a component subsection and only the matching form/navigation/data-display reference |

Do not follow optional historical links or read every component group to complete an ordinary fix/review. A pure Git/status request does not need this design context. These are content boundaries, not a mandated exact command order or a line quota.

## Work modes

This is the canonical design-mode routing for the five Culmina design skills and the supporting Flutter recipes. Select the mode from the owner's current task before choosing a method.

| Mode | Entry condition | Work and stopping boundary |
| --- | --- | --- |
| **Explore** | The owner explicitly leaves a design decision open or authorizes alternatives research | Identify the open decision and accepted constraints, then compare only relevant alternatives using existing research where useful. Record options, source/licence facts, tradeoffs and unresolved owner choice. A recommendation or browser study does not adopt a new production design. |
| **Implement/Fix** | Implementation or a focused correction within the current accepted design is requested | Inspect the affected role/component and actual callers; make the authorized change while preserving existing functions and data/science contracts. Ordinary typography or phone-layout fixes do not reopen font selection, navigation or the design system. Record a genuine decision conflict; continue independent in-scope work. |
| **Review** | The owner requests inspection against defined criteria | Compare current sources and, where required/authorized, actual renders/interactions against those criteria. Report evidence, limits and findings, then stop. Do not silently implement fixes. A separate explicit correction request can change the mode. |

No mode grants Git delivery, build, installation or device/data permissions. Use the current task's permissions and V1–V8 rather than a recipe's example workflow.

## Five skills, loaded selectively

Start with the task's surface; open one relevant skill and only its applicable references. Load another skill only when the actual change crosses its contract.

| Need | Read next | Production sources |
| --- | --- | --- |
| Text role, wrapping, weight or numeric readability | [Typography](../../.agents/skills/culmina-design-typography/SKILL.md) | DESIGN_SYSTEM §3, `lib/core/theme/app_typography.dart`, affected text callers |
| Colour/surface meaning or theme drift | [Tokens](../../.agents/skills/culmina-design-tokens/SKILL.md) | DESIGN_SYSTEM §2, AppPalette/HybridTokens/AppTheme and affected callers |
| Density, alignment, padding, shape or motion | [Spacing](../../.agents/skills/culmina-design-spacing/SKILL.md) | DESIGN_SYSTEM §4/§6.2, spacing/radius/motion definitions and local constraints |
| Existing control, context/navigation or data display | [Components](../../.agents/skills/culmina-design-components/SKILL.md) → only forms, navigation or data-display reference as needed | DESIGN_SYSTEM's named component section and its implementation/callers |
| Product meaning, scientific/data invariants or documented exceptions | [Rules](../../.agents/skills/culmina-design-rules/SKILL.md) | Named decision/guardrail/TECH_DEBT clauses; do not read a historical task queue |

For a constraint error, the [layout diagnostic recipe](../../.agents/skills/flutter-fix-layout-issues/SKILL.md) supplies Flutter mechanics. [Adaptive layouts](../../.agents/skills/flutter-build-responsive-layout/SKILL.md) and [widget previews](../../.agents/skills/flutter-add-widget-preview/SKILL.md) have their own task-entry conditions; availability does not require either one.

## Adoption and evidence

Deliver the bounded diff or review findings with: task/mode and input state; chosen existing roles/components and actual callers; decision/source references; checks required by V1–V8; evidence limits, pending owner/device criteria and the next permitted action. For Explore, include the proposal and unresolved choice rather than claiming adoption. For Review, keep the result read-only.

Current UI typography is Geist throughout production UI, including editorial/answer roles and root navigation, under the [approved Concept B task](CONCEPT_B_IMPLEMENTATION_2026_10_24.md). Documented compact sizes remain explicit. The Android phone composition and current native behavior remain authoritative under BASELINE; a local layout fix does not introduce tablet/desktop composition. Preserve Unknown, provenance/units/time semantics, Save/Discard/Cancel and fit versus persistence/result states. Browser or widget previews do not establish Android/device or owner acceptance.

## Keep related guidance current

When an authorized implementation changes a shared token or component contract, inspect the directly related skill/reference in the same change and update only statements that the changed definition/callers invalidate. A caller-specific variant is documented for that caller; it does not redefine every caller's contract. Record any mismatch with accepted intent instead of inferring approval from code.

An unchanged relevant contract keeps its guidance/evidence: a new HEAD alone does not stale every skill. No automatic skill version bump, all-skills sweep, second status registry or extra checker/CI/dependency follows from this rule. Scope comes from AGENTS/the owner task, current state from PROGRESS and checks only from V1–V8.

## Historical references (optional)

Only open [lab history and comparison methods](references/LAB_HISTORY.md) when the task needs research/provenance or work on that explicitly authorized reference. It preserves the original video, font/licence sources, browser concepts, fixture methods and dated evolution. It is not part of Implement/Fix's required reading. Existing reports/evidence and frozen assets are unchanged.


<a id="historical-browser-comparison-and-optional-preview-method"></a>
- [Historical browser comparison and optional preview method](references/LAB_HISTORY.md#historical-browser-comparison-and-optional-preview-method)

<a id="proposed-design-code"></a>
- [Proposed design code](references/LAB_HISTORY.md#proposed-design-code)

<a id="historical-lab-evolution--not-current-task-instructions"></a>
- [Historical lab evolution — not current task instructions](references/LAB_HISTORY.md#historical-lab-evolution--not-current-task-instructions)

<a id="hybrid-refinement-and-gap-repairs-2026-10-19"></a>
- [Hybrid refinement and gap repairs (2026-10-19)](references/LAB_HISTORY.md#hybrid-refinement-and-gap-repairs-2026-10-19)

<a id="official-design-system-research-references"></a>
- [Official design-system research references](references/LAB_HISTORY.md#official-design-system-research-references)

<a id="home-priority-and-the-plan-page-2026-10-19"></a>
- [Home priority and the Plan page (2026-10-19)](references/LAB_HISTORY.md#home-priority-and-the-plan-page-2026-10-19)

<a id="android-target-correction-2026-10-19"></a>
- [Android target correction (2026-10-19)](references/LAB_HISTORY.md#android-target-correction-2026-10-19)

<a id="complete-android-planning-prototype-2026-10-20"></a>
- [Complete Android planning prototype (2026-10-20)](references/LAB_HISTORY.md#complete-android-planning-prototype-2026-10-20)

<a id="owner-quality-review-refinement-2026-10-20"></a>
- [Owner quality review refinement (2026-10-20)](references/LAB_HISTORY.md#owner-quality-review-refinement-2026-10-20)

<a id="hybrid-implementation-refinement-2026-10-20"></a>
- [Hybrid implementation refinement (2026-10-20)](references/LAB_HISTORY.md#hybrid-implementation-refinement-2026-10-20)
