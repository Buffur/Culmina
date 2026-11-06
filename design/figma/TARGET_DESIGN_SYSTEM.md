# Culmina After — Dark design-system contract

**Current revision AFTER-DARK-1.2 · 2026-10-30 — Notion component refinement.** Owner-authorized refinement of the completed and accepted F01 base, AFTER-DARK-1.0. Geist is retained; typography and spacing are screenshot reconstructions. See [workflow and QA scope](WORKFLOW.md). **Flutter migration is not authorized.** Historical D01 instructions below retain their original revision.

The target is a calm document-oriented Dark UI: neutral surfaces, strong but compact text hierarchy, growing content rows, restrained record containers and a readable blue action accent. Local Notion references guide visual grammar; Culmina retains its own scientific semantics, complete data, actions and states. Existing production skills remain authoritative for production work; D01 owner decisions authorize different After visual values and composition.

## Current delivery and next stage

F01 delivered 94 variables, 18 Geist text styles, 24 catalog sets and 417 variants on the [After Design System page](https://www.figma.com/design/OeDvjQ58cWoHOCSMd69GCG/Culmina?node-id=53-482), with three locked BEFORE copies in the [Before & After UI Lab](https://www.figma.com/design/OeDvjQ58cWoHOCSMd69GCG/Culmina?node-id=53-484). Figma authoring and Geist loading were verified through the supported Codex desktop input → Web Figma → Scripter route. This does not assert Figma MCP/server write access.

The accepted F01 base passed its final structural audits. Its historical visual coverage is 93/514 regions at 100%; 200% QA was excluded by the owner, and native checks were not performed. The owner accepted F01 with these recorded limits. See [WORKFLOW](WORKFLOW.md) for the authoritative final status and [QA checklist](qa_checklist.md) for stage-specific evidence and active future criteria.

The current 1.2 refinement is recorded separately in the workflow; the original F01 evidence does not validate revised resources. On 2026-11-04 the owner designated current Tonight and Plan as approved composition references after the requested polish. They establish page hierarchy and composition; After: Design System supplies reusable components and state coverage, with the latest documented owner adaptations taking precedence over older specimens. The [adopted pilot board](https://www.figma.com/design/OeDvjQ58cWoHOCSMd69GCG/Culmina?node-id=111-34801) makes these adaptations visible. Further Dark screen mockups can use these combined authorities in a separately scoped task. This composition acceptance does not certify every alternate state, first viewport, 200% text, native behavior or accessibility, and does not authorize Flutter migration. See [workflow](WORKFLOW.md) and [readiness research](research/pilot_readiness_2026-11-04.md).

## Read in order

For new screen authoring, start with the [current resolved profile and canonical master index](AUTHORING_PROFILE.md) and [current run/checkpoint](REDESIGN_RUN.md). They resolve the 2026-11-04 audit's applicability/selection conflicts; older base catalog recipes below remain source/state references, not competing visual defaults. Typography and geometry own the current values. No production Flutter migration is authorized.

Then use the [redesign strategy](REDESIGN_STRATEGY.md) for the iteration procedure and stage order. Read the following supporting modules only as needed for the authorized screen:

Questions about removing, merging or retaining source/BEFORE blocks follow the strategy's [Step 4 UX exploration gate](REDESIGN_STRATEGY.md#ux-exploration--structural-alternatives-extension-of-step-4-gate) before Figma editing. Routine visual QA follows its direct-execution exception.

1. [Reference evidence and transformations](reference_mapping.md) — observations, exact pack indices and evidence limits.
2. [Semantic tokens](tokens_semantic.md), [typography](typography.md), [spacing and border](spacing_and_border.md) — single authorities for target values.
3. [Rules and constraints](rules_and_constraints.md) — control semantics, parity and BEFORE protection.
4. [Forms](components/forms.md), [Navigation](components/navigation.md), [Data Display](components/data_display.md) — proposed contracts, actual APIs and required states.
5. [Flutter/Figma bindings](flutter_mapping.md) — existing owners vs proposed role, without duplicated values.
6. Pilot contracts: [Tonight](screens/tonight.md), [Plan](screens/plan.md), [Weather](screens/weather.md).
7. [QA checklist](qa_checklist.md), [workflow record](WORKFLOW.md), [verification evidence](verification.json).

## Combining accepted screens and the Design System

Tonight and Plan establish accepted composition; the Design System owns reusable visual resources and states. Use the latest owner decisions in the owning modules and adopted pilot board when older specimens conflict. Keep the original sources/BEFORE and historical evidence independent.

The [authoring profile](AUTHORING_PROFILE.md) owns canonical role selection; its linked modules own visual values. The [source-reconciled queue](research/ssot_audit_2026-11-04.md#numbered-base-screen-queue) owns stable numbering and source/route contexts. The [strategy](REDESIGN_STRATEGY.md) owns stage order and the one-base-screen procedure. The [run record](REDESIGN_RUN.md) alone owns current progress, page/root IDs and the owner checkpoint. Use those current records rather than restarting the completed consolidation.

The 2026-11-04 owner-authorized consolidation supplies [canonical bindings and a screen/state/component/route matrix](research/consolidation_2026-11-04.md). Accepted recipes live under `After/Adopted` on DS; Tonight and Plan use linked instances. Existing catalog states and historical specimens remain available. Further work requires explicit screen or batch authorization; apply the current pipeline procedure in REDESIGN_STRATEGY. The queue alone is not authorization.

### Historical — superseded composition plan

The following plan is retained as decision history. Consolidation/rebinding has since been completed; its batch, extra-state and paired-viewport instructions do not govern the current base-screen run. Follow the strategy and run record above.

1. **Consolidate the accepted deltas first.** Reuse existing catalog masters wherever they already match; promote accepted local recipes for navigation, appearance, context, fit, capture/tracking, estimate and conditions into their canonical After components. Preserve the earlier specimens as labeled history. The adoption board records the target; it does not claim every local frame has already been rebound to a master.
2. **Rebind the two reference screens carefully.** Replace matching detached/local compositions with canonical component instances without changing their accepted content or geometry. A component change should then appear consistently in the system and both screen references. Validate before/after at the same fixture before extending it elsewhere.
3. **Inventory actual screens and states.** Use the current [router](../../lib/presentation/navigation/app_router.dart), screen owners and application-map evidence. Map each screen to its components, entry/Back paths and relevant loading, empty, missing, unknown, stale, failure and success states. Distinguish root-tab shells from detail/Plan overlays; do not add Plan as a fifth tab.
4. **Build in coherent flows.** Start with related Night/Moon/Weather details, then Library entities/editors and Logbook flows, followed by Settings and shared prompts. This is a suggested sequence for a separately authorized mockup task, not an automatic implementation queue. New state needs must come from actual product behavior.
5. **Deliver usable screen specimens.** Pair the complete content Longread with a 375×812 first viewport, actual chrome/footer/safe-inset treatment and connected prototype routes. Preserve all scientific facts, provenance and explicit Save/Cancel/Undo distinctions; show realistic source-backed states rather than inventing measurements.
6. **Review each batch against the references.** Check hierarchy, spacing, all relevant component states, long text, accessible alternatives and prototype navigation. Update the owning component when a reusable pattern changes, then recheck Tonight/Plan before accepting the batch. Native, Light/Field Red and Flutter migration remain separate authorized work.

## Historical D01 — scope and source boundary

The following observations describe D01 at its recorded baseline, before F01 construction. They are historical evidence, not current access or delivery status.

Read-only source inspection on `develop`, HEAD `55d07528d4e6107bcd504bef632a869f2a85c434`. The pre-existing untracked [planning handoff](../../docs/PLANNING_CONTEXT_2026-10-30.md) was preserved. Its old UI Lab IDs and former visual restrictions are not current After authority.

Read root [AGENTS](../../AGENTS.md); relevant current Culmina skills for components, product rules, tokens, typography and spacing; their component references; theme owners AppTheme, AppPalette, HybridTokens, AppTextTheme, AppTypography, AppSpacing and AppRadius; relevant pilot widgets/callers and selected tests. Persistent documents are in English.

Live Web Figma reads confirmed file **Culmina** and page **Dark · current screens**. The available page list has Light, Dark and Field Red current-screen pages; the old UI Lab is absent. Baselines:

| Pilot | Exact live source | Node | Width × height |
| --- | --- | --- | --- |
| Tonight | 001 · home · Dark · Longread | 9:135229 | 375 × 1351 |
| Plan | 002 · plan · Dark · Longread | 9:135698 | 375 × 2275 |
| Weather | 005 · weather · Dark · Longread | 9:140569 | 375 × 2214 |

Figma Plugin catalog inspection exposed metadata, design-context, screenshot, general use_figma and embedded-app opening actions. Their exposure does not prove usable authentication/quota. Following the stated MCP constraint, D01 did not invoke those server endpoints or attempt writes; source verification used the already open authenticated Web Figma. At D01, read access was verified and write capability had not yet been tested. F01 subsequently verified authoring through the route recorded above.

The main external evidence is the local notion.id LLM-ready pack documented in [reference_mapping](reference_mapping.md). Read collection README/QA_SUMMARY and Notion START_HERE/AI_DESIGN_SPEC/QA_REVIEW, with anatomy, clusters 01/03 and native detail panels 01–03. No new capture or regeneration was performed. Other packages were not used to blend visual directions.

## Historical D01 — original F01 build specification

The instructions below preserve the original specification. F01 is now complete; they are not a request to restart it. Reuse pilot comparison criteria only within the current owner-authorized scope: the base-screen strategy defers the second viewport, additional states and expanded scaling checks. The final F01 QA scope supersedes the original 200% requirement for F01 only.

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

## Current coverage and readiness

The original 24 catalog component contracts were constructed in Figma and F01 1.0 is owner-accepted. The current documented count is 25, including the source-backed [CandidateRow extension](components/data_display.md#afteradoptedcandidaterow); this addition does not change the historical F01 catalog count. Current visual values follow the owner-authorized 1.2 Notion refinement. Its scoped structural and visual evidence is recorded in [WORKFLOW](WORKFLOW.md); full-file visual coverage and native behavior/accessibility are not established. The [QA checklist](qa_checklist.md) retains active parity, layout and scientific-data criteria for future AFTER screens.

The two Longreads are owner-designated composition baselines as recorded in WORKFLOW. Remaining state, viewport, scaling and interaction criteria require their own evidence; preserve BEFORE and shared dependencies. Flutter migration requires separate authorization and native verification.
