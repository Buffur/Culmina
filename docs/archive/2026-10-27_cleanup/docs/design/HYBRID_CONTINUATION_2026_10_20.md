# Hybrid continuation — 2026-10-20

Read this first in the continuation chat. It captures conversation decisions, not the architecture. Chat language: Ukrainian; repository documentation: English. Workspace and source files remain available. Do not reload every historical audit.

## Scope and owner preferences

- Work only on the original **Hybrid**, `variant=blend`, in `design/home-lab/`. The Android-format browser prototype is the current delivery target. Native Flutter adoption is a separate, unapproved task.
- Refine existing functionality; do not introduce new features or turn audit suggestions into an expanded roadmap. Preserve scientific meaning, explicit units, provenance and unknown values.
- Preserve the calm Notion + Journal / Google-inspired direction, open plan summaries, selective serif headings and readable body/data text. No wholesale redesign is requested.
- **Weather stays a compact widget on Home.** The owner rejected extra weather information on the main screen and asked to replace the cloud headline. Do not reintroduce a large cloud summary to raise an audit score. Full weather information belongs in Weather.
- Smooth sky gradients were requested. Dusk/Slate/Ink palette comparisons are implemented. No later owner choice among them is established here; do not invent one.
- Retain actual product behavior: editor Apply changes the draft; Save records the plan. Browsing another night does not silently change the active plan. Unknown cloud is not clear sky. AF/MF is descriptive; no invented numeric focus control.
- Use relevant Culmina skills, bounded subagents and CLI contribution/review when useful. The owner explicitly asked for Claude QA. Do not equate installed plugins with invoked skills or authenticated MCP access.
- No authorization to commit/push, publish, install/update tools, change permissions, migrate the native app or reset user data was granted by the handoff request.

## Completed work and current evidence

1. Compact Home Weather and smoother sky alternatives; interactive Logbook, Library and Settings were completed. Historical reference: [Android tabs](ANDROID_TABS_2026_10_20.md).
2. The seven requested Hybrid refinements are complete: Settings cause near Saved · changed; assumption provenance and margin semantics; compact Progress disclosure; Weather stale/coverage hierarchy; Night of / Ends dates; in-flow feedback; unchanged restore closes without a write. [Implementation and QA](HYBRID_SEVEN_REFINEMENTS_2026_10_20.md).
3. Final implementation revision: **`20261020-hybrid6`**. Claude's focused seven-item QA passed after a bounded correction; this was not a new whole-app score.
4. A subsequent **whole-Hybrid reassessment** covered all eight roots and child families, themes and selected 200% text states. **Claude CLI: 33/40; independent A: 31/40.** The preceding Claude score was 32/40. These are expert judgments, not measured usability improvements. [Current full reassessment](HYBRID_FULL_REASSESSMENT_2026_10_20.md).
5. The reassessment changed no application files. All 30 source hashes matched the hybrid6 manifest. It captured 116 screenshots; Claude read the selected 84 PNGs (its prose miscounts 82). Coverage and limitations are in the report/evidence, not inferred from a screenshot count.

Browser proof does not certify native Android, TalkBack, IME/Back, device performance, production astronomy/weather or real native persistence. The known field-theme secondary-text tradeoff was not treated as a newly discovered global AA defect.

## Where the conversation stopped

The owner received the reassessment, **not an implementation of its new recommendations**. The assistant asked which batch to prioritize and how to reconcile initial Plan/Settings assumptions; no answer was received before this handoff request. Neither branch of that decision is approved.

Five current priorities, all inside existing functionality:

| ID | Finding | Bounded refinement / decision |
|---|---|---|
| R1, P2 | Unsaved Settings shows 5 s between frames / 15% margin; example Plan uses 7.5 s / fixed 15 min. Plan labels Example default but Home broadly mentions current global defaults. | Choose aligned initial values **or** consistently explicit example-plan provenance. Do not silently choose or call this a proven production calculation bug. |
| R2, P2 | Library's simulated load failure appears in a child list while the root still shows ordinary counts. | Expose existing error/retry at root; qualify unreliable counts. |
| R3, P2 | Time rail resembles a static chart; Night start resembles a label beside the previewed time although it is a reset button. | Clarify existing interaction/reset affordance and wording. |
| R4, P2 | Partial Weather cloud headline reads as a whole-night range; 5/7 qualification appears lower down. | Qualify known/sampled hours at the headline. Keep Home compact. |
| R5, P3 | Repeated disclaimers/messages delay search and actions, especially at 200%. | Consolidate repeated text while retaining essential domain/privacy/source meaning. |

Secondary observations: Welcome purpose is hidden behind the wordmark; empty Logbook can point to its existing planning prerequisite; new-target wording sometimes implies stored values already exist. These are proposals, not extra approved tasks.

Rejected or qualified review suggestions: Claude's cloud-first Home expansion conflicts with the owner's widget constraint; do not adopt it. Applying all four assumption fields as overrides is explicitly documented, so it is not automatically a defect. Detector font popularity warnings do not justify replacing the approved type system; missing-data hatching has semantic meaning.

## Next concrete task

Prepare **one short implementation brief for R1–R5**, using the current reassessment and only targeted source checks. Record exact acceptance criteria and a bounded browser/Claude QA plan. Recommend one R1 option with its consequence, and ask the owner for that unresolved choice. Do not repeat the whole-app audit, implement audit recommendations, install/update tools or start native adoption before an owner implementation instruction. The handoff request authorizes preparation and continuation, not those changes.

## Tools and practical restart

**Later authorized tooling maintenance:** see the newest section of [AI tool capabilities](../AI_TOOL_CAPABILITIES_2026_10_20.md) and [maintenance result](tooling-update-2026-10-20/RESULT.md). Tool versions/routes in the older bullets below are historical where they conflict; maintenance did not authorize R1–R5 implementation or native adoption.

- Read the **latest checked section** in [AI tool capabilities](../AI_TOOL_CAPABILITIES_2026_10_20.md); older sections in that file are historical. It records official-source comparisons and current failures.
- Culmina workflow: [WORKFLOW.md](WORKFLOW.md), then relevant `.agents/skills/culmina-design-*/SKILL.md`. Load only what the task needs. One Impeccable instruction source per task; local skill 4.6.0 and plugin 4.3.1 currently overlap, while upstream is 4.7.0. Updates are proposals only.
- Claude executable: `C:/Users/zalub/.local/bin/claude.exe`; AntiGravity: `C:/Users/zalub/AppData/Local/agy/bin/agy.exe` (1.4.3). Claude whole-app QA actually succeeded. AntiGravity supplied useful no-tools review; its earlier headless implementation hit RunCommand permission denial. Do not bypass permissions or keep retrying that task.
- When a Claude worker must invoke a plugin skill, its allowed tools must include `Skill`; the latest read-only whole-app Claude QA used Read and **did not invoke plugin skills**. Parent/subagents used the design skills separately.
- Existing loopback preview was running at port 4173. Verify before starting a second server. Launcher: `python design/home-lab/scripts/serve_preview.py --port 4173`. Preserve owner browser storage; use isolated contexts for fixture edits.
- Preserve existing dirty/untracked files. The working tree contains prior design/docs/skills changes; do not clean or revert them. No commit was made for this handoff.
- Evidence: `design/home-lab/evidence/hybrid-seven-2026-10-20/` and `hybrid-full-reassessment-2026-10-20/`. Use focused artifacts, not complete stream/image logs unless a factual dispute needs them.

This handoff is grounded in the accessible conversation, current files and audit output. Older [chat handoff](CHAT_HANDOFF_2026_10_20.md) remains historical context; the present file supersedes its current-state claims for Hybrid.

Continuation chat created in the same local Astro Planner project: `01a159f5-b843-7a62-8599-e2295e76ff58`. Its initial task is the bounded R1–R5 implementation brief above. [Exact start prompt](handoff-2026-10-20/START_PROMPT.txt). Do not create another continuation automatically.
