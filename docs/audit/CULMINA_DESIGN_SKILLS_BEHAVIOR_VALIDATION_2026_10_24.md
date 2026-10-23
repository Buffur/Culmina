# Culmina design-skill behavior validation — 2026-10-24

Result: **PARTIAL_WITH_ATTENTION**. Five fresh live sessions completed. Natural selection of the relevant skill and answer correctness passed; A/B failed the bounded-context criterion because they read the entire DESIGN_SYSTEM, including its historical appendix. C/D/E passed their bounded probes. No correction was implemented.

## Inputs, client and rubric

Source: `develop`, HEAD `4ac20a9519d3444f2877c1ba5a61dd1f219b4659`, upstream `origin/develop`; one worktree. Before probes: 13 modified tracked Markdown files, three untracked Markdown references, empty index. Local refs agreed; this validation did not refresh the remote. The 16 dirty inputs were the current skills/router/references, DESIGN_SYSTEM, WORKFLOW, lab-history reference and PROGRESS. Their aggregate SHA-256 was `6dca672973371059fd48c103d1f346e719b9be78fc697f13a7b886afd26bd1aa` (sorted repository-relative path + NUL + raw file bytes + NUL).

The actual 13-file routing-guidance fingerprint was recomputed as `55fa5da65cc0394334d266fabbda9b454aff5c26e3ee75b41c010579c9d1ad94` (path + NUL + LF-normalized UTF-8 text + NUL). It matches the preceding handoff: selective entrypoints, canonical [work modes](../design/WORKFLOW.md#work-modes), [semantic map](../../.agents/skills/culmina-design-tokens/references/semantic-map.md), optional lab history and corrected Flutter recipes are present in the filesystem, not merely in an old prompt.

Primary client: **Codex CLI 0.163.0**, checked with `codex --version` and installed help. Each invocation used `codex exec --sandbox read-only --ephemeral --json -`, the same live worktree, no resume/fork, and no model/profile override. Five distinct `thread.started` IDs, `turn.completed` events and process exit 0 confirm fresh completed sessions. The safety wrapper prohibited edits, gates/builds, installations, settings/authentication/permission/memory changes, Git delivery, device/data operations, secrets and delegation; it supplied no skill paths, symbols or rubric. Existing client startup instructions/configuration remained in effect.

Reviewer rubric was frozen **before** all probes (SHA-256 `eb21fe6517eb2fc9bb69572a1813421cb05463cbf5735938707d06ecdb07459d`), using AGENTS, PROGRESS, AI_WORKFLOW, [V1–V8](../VERIFICATION_POLICY.md), BASELINE, current skills/references and actual native definitions/callers:

- A: current selected-hour roles and real Weather caller; declared-but-unused roles distinguished; bounded plan with field/selection semantics retained.
- B: component capabilities versus Tonight adoption; compact/framed defaults, no-site/night/zone data, full accessible labels/actions and current acceptance limits.
- C: adopted Material/named roles and a real Plan caller; local change boundary, no global font increase or new font research.
- D: unbounded vertical maximum versus finite viewport; tight flex remainder, scrolling ownership and conditional remedies.
- E: actual Git state, without an unjustified design-body/history read.

All probes also required relevant observed source reads, current implementation/intent/acceptance distinctions, and no scope expansion. No exact read order, command quota, wording match or token-saving target was imposed.

## Natural prompts

These are the actual user-language prompts after the common read-only wrapper:

| Probe | Prompt |
| --- | --- |
| A | «Потрібно уточнити стиль виділеної години на Weather. Знайди поточні джерела стилю та запропонуй мінімальний план зміни в межах чинного дизайну. Нічого не змінюй». |
| B | «Розбери поточний site/night control на Tonight: які варіанти, стани та доступність треба врахувати перед точковою зміною? Нічого не змінюй». |
| C | «Потрібно уточнити ієрархію тексту в одному блоці Plan. Знайди релевантні чинні текстові ролі та поясни, як обмежити зміну цим блоком без глобального збільшення шрифтів. Нічого не змінюй». |
| D | «У вертикальному ListView є Column з Expanded, і виникає помилка unbounded vertical constraints. Поясни причину, які умови потрібно перевірити та як вибрати мінімальне рішення. Код не змінюй». |
| E | «Покажи поточні branch, HEAD і git status. Нічого не змінюй». |

## Observed reads and outcomes

Sources below are principal successful tool reads; searches/enumerations alone are not counted as loading every matched file. A–D also read current operational context. Some consulted existing user memory or user-installed Impeccable guidance; their final native claims were checked against repository sources. No private paths or raw logs are included here.

| Probe | Principal observed reads | Natural discovery / answer / bounded context | Overall |
| --- | --- | --- | --- |
| A | Token SKILL and semantic-map reference; `lib/core/theme/hybrid_tokens.dart`, AppTheme and AppTypography; `lib/presentation/widgets/weather_hybrid_view.dart`; full DESIGN_SYSTEM/WORKFLOW; P-6 reports and targeted test/CSS provenance searches | **PASS / PASS / FAIL**. Identified `selectedHourFill/Text/Rule`, actual 48px cells/2px rule and selection semantics; distinguished unused `hourBackground/hourText`. Proposed a local weight refinement explicitly as a proposal, with no code or runtime claim. Whole DESIGN_SYSTEM read in A/item_3 included historical material unrelated to the selected-hour task. | **FAIL** |
| B | Components SKILL → navigation reference; `lib/presentation/shared/context_line.dart`, Tonight screen/home-context handlers, SiteLabel and ViewModels; site and planner-context sources; test-source reads, TD-120/121 reports; full DESIGN_SYSTEM | **PASS / PASS / FAIL**. Correctly found compact unframed Tonight, Set site/no-night state, omitted night instant/no inline zone caption, full semantics/tooltips and 48px actions. Kept direct Tonight actions distinct from planner Apply/Close and owner/TalkBack/200% limits. Whole DESIGN_SYSTEM read in B/item_3 included the historical appendix. | **FAIL** |
| C | Typography SKILL; `lib/core/theme/app_typography.dart`, AppTheme; targeted DESIGN_SYSTEM sections/searches; `plan_status.dart`, capture-plan/budget sources, `status_block.dart`; current BASELINE/WORKFLOW and Impeccable typesetting guidance | **PASS / PASS / PASS**. Distinguished Material bodyMedium 16 from named body 14, identified real Plan uses, acknowledged the unspecified block and kept changes at caller level. No global scale/family change or lab-history reading proposed. | **PASS** |
| D | Layout diagnostic SKILL and dated Flutter source reference; operational context; targeted searches in BASELINE/DESIGN_SYSTEM/WORKFLOW; successful Context7 resolve/query calls and official Flutter API/source lookups | **PASS / PASS / PASS**. Explained that a bounded ListView viewport can give its Column unbounded content height; Expanded needs a finite remainder. Distinguished content-sized children, a bounded outer Column/list and a justified subviewport; rejected mechanical Flexible/minHeight/shrinkWrap cures. No runtime defect reproduction was claimed. | **PASS** |
| E | Only `git branch --show-current`, `git rev-parse HEAD`, `git status --short --branch`, `git status --porcelain=v1 --untracked-files=all` | **PASS / PASS / PASS**. Reported develop/full HEAD and 13 modified plus three untracked files, with no staged changes. No design-skill/body/history read was observed. | **PASS** |

Natural discovery means the unhinted client selected and actually read the relevant entrypoint/reference. **Explicit-path controls: NOT RUN**, because relevant entrypoints were found naturally in A–D; E correctly needed none. These traces do not separately prove an automatic activation mechanism or discovery in another client.

## Surviving finding and evidence limits

**PBR-01 — bounded-context loading remains incomplete in A/B.** The successful commands were `Get-Content docs/DESIGN_SYSTEM.md` (A) and its LiteralPath equivalent (B), without section selection. Their captured output includes dated adoption/update history. Both subsequently reached the correct current references and native callers; no obsolete both-framed or missing-sunken/old selected-hour mapping was adopted. No probe opened the relocated LAB_HISTORY or used a frozen inventory as native truth. The finding concerns observed loading, not a numerical token-saving claim or a requirement for one exact command sequence.

Narrow next task, requiring its own authorization: reconcile the first UI-context route with section-level DESIGN_SYSTEM reading, including interaction with existing generic UI guidance, then re-probe A/B. No skill/governance fix or application redesign belongs to this validation. C/D/E are not reopened by that follow-up without a changed relevant input or contradictory evidence.

Local JSONL traces and a frozen rubric/snapshot manifest were retained outside Git. Prompt/event aggregate SHA-256: `f243d69e7de6151024338f04df4f0f44f024c07cd704a437c426f45164fa6b25`. A–D/E used 10/28/13/4/1 completed shell calls respectively; these identify the evidence set, not quality scores. D additionally used documentation tools. Client startup emitted an unrelated Firecrawl authentication warning; filesystem probes and D's documentation tools worked. No authentication repair or permission change was attempted. A source search in B failed on a glob, then the agent located the existing paths and read them; it is not passing runtime/test evidence.

After all probes, the entire original tracked diff, empty index and all 16 dirty-file hashes still matched the pre-probe snapshot. Only this report and the current PROGRESS handoff were then edited. Final V1 checks cover links/anchors/paths/IDs, report-to-trace consistency, scope and `git diff --check`; application and skills inputs remain unchanged.

This validates one client's routing, live file reading and bounded reasoning. It establishes no pixel parity, new Flutter implementation correctness, phone accessibility, physical-device result, owner acceptance or F/G/product/release gate closure. Stop after the report/handoff; PBR-01 remains open.
