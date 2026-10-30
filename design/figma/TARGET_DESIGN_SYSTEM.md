# Culmina After — Dark design-system contract

**Revision AFTER-DARK-1.0 · 2026-10-30.** F01 is fully complete by explicit owner decision; see the [final workflow status and QA coverage](WORKFLOW.md). **Flutter migration is not authorized.** The D01 specification and its historical source observations below are preserved; subsequent F01 construction and verification are recorded in the workflow.

The target is a calm document-oriented Dark UI: neutral surfaces, strong but compact text hierarchy, growing content rows, restrained record containers and a readable blue action accent. Local Notion references guide visual grammar; Culmina retains its own scientific semantics, complete data, actions and states. Existing production skills remain authoritative for production work; D01 owner decisions authorize different After visual values and composition.

## Read in order

1. [Reference evidence and transformations](reference_mapping.md) — observations, exact pack indices and evidence limits.
2. [Semantic tokens](tokens_semantic.md), [typography](typography.md), [spacing and border](spacing_and_border.md) — single authorities for target values.
3. [Rules and constraints](rules_and_constraints.md) — control semantics, parity and BEFORE protection.
4. [Forms](components/forms.md), [Navigation](components/navigation.md), [Data Display](components/data_display.md) — proposed contracts, actual APIs and required states.
5. [Flutter/Figma bindings](flutter_mapping.md) — existing owners vs proposed role, without duplicated values.
6. Pilot contracts: [Tonight](screens/tonight.md), [Plan](screens/plan.md), [Weather](screens/weather.md).
7. [QA checklist](qa_checklist.md), [workflow record](WORKFLOW.md), [verification evidence](verification.json).

## Scope and source boundary

Read-only source inspection on `develop`, HEAD `55d07528d4e6107bcd504bef632a869f2a85c434`. The pre-existing untracked [planning handoff](../../docs/PLANNING_CONTEXT_2026-10-30.md) was preserved. Its old UI Lab IDs and former visual restrictions are not current After authority.

Read root [AGENTS](../../AGENTS.md); relevant current Culmina skills for components, product rules, tokens, typography and spacing; their component references; theme owners AppTheme, AppPalette, HybridTokens, AppTextTheme, AppTypography, AppSpacing and AppRadius; relevant pilot widgets/callers and selected tests. Persistent documents are in English.

Live Web Figma reads confirmed file **Culmina** and page **Dark · current screens**. The available page list has Light, Dark and Field Red current-screen pages; the old UI Lab is absent. Baselines:

| Pilot | Exact live source | Node | Width × height |
| --- | --- | --- | --- |
| Tonight | 001 · home · Dark · Longread | 9:135229 | 375 × 1351 |
| Plan | 002 · plan · Dark · Longread | 9:135698 | 375 × 2275 |
| Weather | 005 · weather · Dark · Longread | 9:140569 | 375 × 2214 |

Figma Plugin catalog inspection exposed metadata, design-context, screenshot, general use_figma and embedded-app opening actions. Their exposure does not prove usable authentication/quota. Following the stated MCP constraint, D01 did not invoke those server endpoints or attempt writes; source verification used the already open authenticated Web Figma. Read access is verified; future write capability remains untested.

The main external evidence is the local notion.id LLM-ready pack documented in [reference_mapping](reference_mapping.md). Read collection README/QA_SUMMARY and Notion START_HERE/AI_DESIGN_SPEC/QA_REVIEW, with anatomy, clusters 01/03 and native detail panels 01–03. No new capture or regeneration was performed. Other packages were not used to blend visual directions.

## Future F01 build specification — do not execute in D01

Create the page **After: Design System** with clearly labeled sections:

- Revision/scope banner and immutable source links.
- One independent Dark variable collection; semantic swatches with role labels and actual foreground/background specimens.
- Typography specimens for each named style, long strings, Ukrainian glyphs, tabular numbers, units and 200% text-size examples.
- Geometry specimens: plain vs record sections, hit regions, focus rings, wrapping action groups, menu and sheet boundaries.
- Forms, Navigation and Data Display component sets with the catalog's named properties, defaults, states and source-adapter annotations. Build supporting dependency specimens separately from pilot screens.
- Correct/incorrect pairs: unknown vs fabricated zero; saved vs fit conflation; full wrapped title vs clipped title; genuine action vs decorative chip; labeled gap vs fabricated chart line. Incorrect examples must be visibly marked “Do not use”.

Create a **new** page **UI Lab: Before & After**. Do not reuse a deleted page's ID. Read actual created IDs from Figma only after authorized creation. Use independent After components/variables/styles; verify none are dependencies of BEFORE. Source comparisons may be locked independent copies, labeled with the immutable original source link.

For each pilot, place BEFORE on the left and AFTER on the right, at identical 375-px width and 1:1 canvas scale, aligned at their top edges with **120 px clear horizontal gap**. Keep two comparison types: full longread (hug content height, show all content) and first viewport (375 × 812, annotated visible fold/scroll/footer). Longread heights may differ because typography/composition changes; never stretch the original or compress After to match its height. Keep the same content, state, theme and date fixture.

Name frames `<Pilot> / Before / Longread`, `<Pilot> / After V1 / Longread / AFTER-DARK-1.0` and corresponding `Viewport` frames. If V2 is requested, use the same revision; an experiment with different rules must have a distinct revision with an explicit delta, not hidden overrides. Do not create unrequested alternatives automatically.

F01 must check source nodes still exist and retain the recorded names/dimensions; report drift instead of silently substituting another baseline. It must check available Figma write tooling and Geist, then implement the already specified system and run static QA. This recheck is operational validation, not an invitation to reinvent the visual direction.

## Coverage and readiness

The catalog contains 24 proposed component contracts across three categories. Detailed evidence concerns three pilot longreads; full-file coverage is explicitly not claimed. Additional states are annotated as source-backed. Native behavior, font availability inside Figma, server write access, owner acceptance and Flutter migration approval are not established.

F01 has defined values, bindings, components, source nodes, layout instructions and a QA gate. It can start after its normal source/access/font check. If writes are unavailable, retain this contract and report the specific access gap; do not alter BEFORE through another mechanism.
