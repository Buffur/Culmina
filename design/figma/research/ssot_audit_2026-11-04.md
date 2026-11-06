# After SSOT audit and default-screen queue — 2026-11-04

## Decision

Subsequent owner authorization, 2026-11-04: resolve S1–S5, preserve accepted appearance and history, then create only Tonight. The implementation/current evidence is now in [authoring profile](../AUTHORING_PROFILE.md), [run record](../REDESIGN_RUN.md) and [WORKFLOW](../WORKFLOW.md). The HOLD and findings below describe the audit checkpoint before that authorized repair; they are retained as evidence, not the current generation instruction.

**HOLD at Phase 1.** The accepted Tonight/Plan compositions and their instance consolidation are usable. After is not yet an unambiguous single authoring source for every new product screen. The critical issue is choosing between simultaneously available recipes, not a request to redesign the accepted pilots. Per the owner's stop rule, no new redesign page or Screen 1 is created in this audit.

Scope: current After: Design System, its local modular contract/skills, original local Notion reference and current product source. Dark only. No BEFORE, Flutter, reference-original, commit or push changes. Phase 2 remains exactly one base-state screen per iteration, stopping for the owner's `Далі` or corrections. No empty/loading/error/offline/edge-case or modal substates in that phase.

## 1. Notion reference alignment

**Aligned as an explicit Culmina adaptation, not a pixel-identical Notion system.** The original reviewed Notion spec states that source type, padding, spacing grid and design tokens are unknown. Its observed samples support canvas #202020, bounded record #262626, main text #F0EFED, muted #ADA9A3 and blue #2783DE. The live 94 After variables match all 94 values in [semantic tokens](../tokens_semantic.md); no token-value differences were found.

Original native-resolution Notion navigation/database panels were inspected, together with the current DS comparison board, surface/text boards and typography board. The calm row hierarchy, restrained surfaces, wrapping identity and explicit actions are consistent with the [adoption map](../reference_mapping.md). Geist, 48px targets, astronomy encodings, four labeled root tabs and the accepted light primary commands are deliberate Culmina choices. Notion's bottom action bar is not imported as destination navigation; Adventure brown is not imported as an application accent. Source measurement uncertainty must remain explicit.

**Structural clutter remains a generation risk.** The current DS page has 168 top-level items, 45 component sets and 624 variants. These counts include internal, backup, historical and QA resources, not 624 approved current product states. Visible temporary-mutation boards and earlier unversioned catalog names coexist with `After/Adopted`. Their preservation is legitimate evidence retention, but their discoverability does not establish authoring approval.

## 2. Synchronization with Tonight and Plan

**The accepted compositions are consolidated; the whole catalog is not visually unified.** The [binding manifest](consolidation_bindings_2026-11-04.json) records canonical accepted recipes, nested ownership and preserved roots. The preceding consolidation's exact PNG/text/state checks are recorded in [its report](consolidation_2026-11-04.md). Fresh audit readback verifies all 45/45 instance-to-master bindings; current full Tonight/Plan PNGs are byte-identical to the accepted post-consolidation exports at 375×1367 / 375×2580.

Live contradictions that matter when selecting a component:

- `56:6381` / `After/Navigation/RootTabs` still offers the earlier pill/check treatment; `118:40042` / `After/Adopted/RootTabs` offers the accepted four rectangular states without that extra check. Both are available in DS.
- `58:17778` / `After/Data/CaptureBlock` still renders Edit, Move up, Move down and Remove as separate controls. Accepted CaptureBlock `118:37313` is the separate canonical recipe recorded in the binding manifest. The accepted pattern uses tap/edit and contextual dots, with no Move commands. This is a visual/semantic recipe conflict for future use, not a defect newly introduced into the accepted Plan.
- `58:32172` / `After/Data/NightTimeline` retains the earlier synthetic fixture and scrubber/arrow-key wording. Current adopted timelines `93:38045` / `93:38514` and outer NightAhead families `118:42629` / `118:43466` implement the accepted dated fixture and discrete Exact times selection. These are different authoring recipes, not interchangeable variants.
- Generic primary Action remains blue; adopted `118:37192` is light and shared by Open planner / Save plan. Both are intentional, but the rule for choosing one on a new screen is not resolved in a single current authoring table.

The appearance, information and state preservation of Tonight/Plan do not prove that picking the first generic family will reproduce their accepted design.

## 3. Skills and parameters

**Strong foundations; incomplete universal authoring resolution.** [After routing](../../../.agents/skills/culmina-figma-after/SKILL.md) correctly gives the owner task and modular After contract precedence for authorized exploration. Production component/token/spacing/typography skills govern production code and semantics; their different visual values are not After defects and must not be globally rewritten. The After contract provides concrete colors, Geist metrics, dimensions, minimum targets, radii, wrapping, Unknown/provenance, Save/fit distinctions and component schemas.

The following issues block reliable generation of unmatched new patterns:

| ID | Severity / evidence | Required targeted correction |
| --- | --- | --- |
| S1 | Critical authoring ambiguity: [typography](../typography.md), main role table versus later parent/nested hierarchy adoption. Live base styles remain sectionHeading 14/20 Regular and itemTitle 18/26 Regular; accepted parent headings use screenTitle 20/26 SemiBold, while 42 text occurrences in the adopted resource board use 18/26 Medium with no text-style association. Occurrences include nested instances and are not 42 unique masters. | Add one current role-to-style resolver for new screens. Recommended: parent section 20/26/600, nested record/disclosure 18/26/500, ordinary fields/values/scientific answers retain their distinct roles. Add a named Medium nested-title style and bind the owning masters without changing pixels. Keep older role definitions explicitly scoped. |
| S2 | Critical composition ambiguity: [geometry](../spacing_and_border.md) generic 32px independent sections / 12px bounded insets versus later 12px block separation / compact accepted wrappers explicitly scoped to TEST Longreads. | Specify which matching pattern classes inherit accepted recipes, and which unmatched sections use generic defaults. Keep plain reading sections available; do not turn every screen into cards or normalize scientific layouts. |
| S3 | Critical component-selection ambiguity: old and adopted RootTabs/CaptureBlock/NightTimeline remain simultaneously available, with no primary current role-to-master index covering fallback use. [Target read order](../TARGET_DESIGN_SYSTEM.md) reaches older contracts before the research binding manifest. | Add a current canonical selection index to the main entrypoint. Resolve each role to master ID, use case and fallback. Mark superseded masters/descriptions as historical/do-not-use-for-new-screens, and group QA/proposals/history separately while preserving IDs, instances and evidence. Do not delete or globally restyle them. |
| S4 | Important action-role ambiguity: [Forms](../components/forms.md) still describes light commands as a local adaptation; generic primary tokens/Action remain blue. The light control is bound to textPrimary as its fill. | State exactly which new command classes use the light primary and where blue remains appropriate. Document its foreground/background role mapping; add a separate semantic action role only if that distinction is adopted. Do not silently recolor existing states. |
| S5 | Important run/source gap: the dated application map includes a removed PlanContext screen, and the current run's base-only / one-screen stop rule is not a persistent execution profile. | Use the source-reconciled queue below; record the run's viewport, fixture source, canonical selection, base-only scope, output and owner checkpoint. Exclude modal substates and the removed screen. |

Older prose also mentions the visible Field caption, pill selection, rowTitle button emphasis, Move commands or UI Lab-only timeline ownership. Later corrections exist, but a new generator should not have to resolve chronology across several files. Move obsolete imperative paragraphs into labeled history or replace them with the resolved current rule.

These are proposed corrections. This audit does not adopt new universal style values or alter live masters, because the owner explicitly requested a stop on critical mismatches.

## Evidence and limits

- Live Scripter inventory: all 168 top-level items, 45 component-set property schemas / 624 variants, all three local variable collections and 19 styles. After collection: 94; proposal: 16; QA: 6.
- Live value comparison: 94/94 semantic token values match; 19 style definitions inspected. Medium nested-title occurrences identified as above.
- Original 100% PNG exports visually inspected: the first existing catalog specimen of all 24 public families, seven adopted resources/patterns and four reference/foundation boards, 35 exports total. First specimens include missing/empty states where they are the catalog default; these are existing audit evidence, not newly generated Phase-2 screens. This does **not** claim visual inspection of all 624 variants.
- Notion reference: reviewed `notion.id/llm_ready/AI_DESIGN_SPEC.md`, `QA_REVIEW.md`, original `01_navigation_details.png` and `03_database_details.png` in the machine-local collection recorded by [reference mapping](../reference_mapping.md).
- Local evidence: `build/figma-ssot-audit-20261104/live-inventory.json`, `contract-comparison.json`, `default-render-index.json` and 35 full-scale PNGs. Fresh pilot-binding and render readback is saved in the same directory.
- Read-only parallel review covered local authority/parameter conflicts and current product routes/imperative pages. No native, screen-reader, 200%, continuous-scrubber or full-library visual acceptance is asserted. These are not invented gates for default-state Dark mockups.

## Numbered base-screen queue

This is the source-reconciled numbering from the audit checkpoint, not a live progress table. Read [REDESIGN_RUN](../REDESIGN_RUN.md) for current screen status, transferred root IDs and the next owner checkpoint; the historical inventory and findings above remain dated evidence.

The current source supports **40 screen/context entries**. The older map has 42 nodes: exclude removed `PlanContextScreen` and the Unsaved changes dialog. The map's 2026-10-28 captures (source `0e2130238f6d241cec270f65ff030d2ea67cf73f`) remain fixture/content evidence, not current runtime proof. Tonight and Plan are accepted source compositions to reuse when their turn is reached; neither has yet been created on a new redesign page by this audit.

1. Tonight — `/tonight`; reuse accepted canonical composition.
2. Capture Plan — `/session/:id`; reuse accepted canonical composition.
3. Night — `/night`.
4. Moon — `/moon`.
5. Weather — `/weather`.
6. What can I image? — `/tonight/candidates`.
7. Choose site — `/select/site`.
8. Choose target — `/select/target`.
9. Choose rig — `/select/rig`, preserving optional `?for=plan` context.
10. Capture block editor — imperative full page, `showCaptureBlockDialog`.
11. Build calibration frames — imperative full preview page, `showCalibrationPreview`.
12. Plan assumptions — imperative full page, `PlanOverridesEditor`.
13. Planning settings over Plan — `/plan/settings`, preserving scope and Back behavior.
14. Logbook — `/sessions`.
15. Saved plan / entry — `/sessions/:id`.
16. Record result — `/session/:id/results`.
17. Progress by target — `/sessions/progress`.
18. Library — `/library`.
19. Rigs — `/library/rigs`.
20. Rig record — imperative `RigDetailScreen`.
21. Rig editor — imperative full-page `showEquipmentEditor`; one populated base, not separate Add/Edit variants.
22. Manage rigs over chooser — `/manage/rigs`.
23. Add from a photo — `/equipment/import`.
24. Targets — `/library/targets`.
25. Target record — imperative `TargetDetailScreen`.
26. Target editor — imperative full-page `showTargetEditor`; one populated base.
27. Manage targets over chooser — `/manage/targets`.
28. Sites — `/library/sites`.
29. Site record — imperative `SiteDetailScreen`.
30. Site editor — `/site/edit`; one populated base.
31. Current / transient position — `/position`.
32. Site map coordinate picker — `/site/pick`, retaining confirm/return semantics.
33. Settings — `/settings`.
34. Appearance — imperative `/settings/appearance`.
35. Planning defaults — imperative `/settings/planning`.
36. Privacy — imperative `/settings/privacy`.
37. Backup & data — imperative `/settings/backup`.
38. About — `/settings/about`.
39. Open-source licenses — framework full page, `showLicensePage`.
40. Welcome / setup — `/welcome`; one populated/ready setup composition.

Primary route evidence: [router](../../../lib/presentation/navigation/app_router.dart). The removed Context composition is replaced by direct site choice and a calendar picker in [home context](../../../lib/presentation/screens/tonight/home_context_sheets.dart). Full-page capture and calibration owners are [capture editor](../../../lib/presentation/widgets/capture_plan/capture_block_dialog.dart) and [calibration preview](../../../lib/presentation/widgets/capture_plan/calibration_preview_dialog.dart); filenames containing `dialog` do not make these modal substates.

Preserve separate Library/scoped-Manage, Settings/over-Plan and coordinate-map contexts. Do not multiply Add/Edit, current/saved Plan, camera classes, Weather presentations or disclosure expansions into separate baseline iterations. Calendar/zone pickers, Add rig sheet, coordinate entry, tracking choice, unsaved/delete/restore/share prompts, storage confirmation, system pickers and permission flows are deferred modal/external states. Startup UnsupportedDatabase is an error state and excluded.

## Historical next permitted step at the audit checkpoint

The following instruction records the pre-repair stop point. It has been superseded for execution by the [current authoring profile](../AUTHORING_PROFILE.md) and [run checkpoint](../REDESIGN_RUN.md); it does not restart Screen 1 or authorize further generation.

Resolve S1–S3 and the action-selection rule with explicit current authoring scope, preserving accepted pixels and historical dependencies. Recheck the canonical resolver against live DS, then create one separate redesign page and **Screen 1 only**. Report its components and stop for `Далі` or corrections before Screen 2. No bulk generation and no secondary states.
