# Prompt — Continue the current work

> A reusable session prompt (created 2026-09-27, governance correction). The rules are
> [AGENTS](../../../AGENTS.md), [AI_WORKFLOW](../../AI_WORKFLOW.md) and [VERIFICATION_POLICY](../../VERIFICATION_POLICY.md); this file is
> only the procedure.

1. Verify repository/worktree, branch/HEAD, upstream and dirty state under AI_WORKFLOW. Read `docs/refinement/PROGRESS.md`: current state, reusable validation evidence, blockers and
   the **Next allowed action**. That action must fit the current owner request. A wait/review-only action does not authorize implementation; an older launch or Git permission does not restart.
2. Read only what that action names: its definition in the active queue (`FINAL_COMPLETION_ROADMAP.md`,
   approved 2026-10-18; older S-IDs resolve through its §4), the ADRs, finding IDs and files it
   references, then the relevant code and tests. Do not re-audit the repository or reread earlier
   Stages' history.
3. If the current owner instruction activates a frozen Task, use its frozen sequence within that scope: `READ → VERIFY → PLAN →
   IMPLEMENT → VERIFY → SELF-REVIEW → DOCS → COMMIT IF AUTHORIZED → CHECKPOINT`. A single-task scope stops
   here; an explicitly authorized finite group continues to its next dependency-ready task under
   its launch brief (for the full plan, `CLAUDE_FINAL_PLAN_GOAL_IMPLEMENTATION.md`). A prompt file's
   presence does not activate a grouped run. Verify by change class and reuse
   valid evidence (Verification Policy V1–V3, owner AM-05): each Task runs changed-behavior and
   affected-dependency tests plus applicable named probes, rather than all tests by default. Full
   integration/release gates are consolidated at G1/F26; asynchronous CI need not delay each Task.
4. If the action is a research or owner-decision gate, do not implement; prepare the decision.
5. If the action is a Stage validation, use `INDEPENDENT_STAGE_VALIDATION.md`.
6. Update `PROGRESS.md` by its "How to update this file" rules and commit if authorized. Stop at the
   end of a single-task scope. Within a launched finite group, mark genuinely unavailable items
   NEEDS ATTENTION with reason/dependencies/resumption action and continue safe independent work;
   finish with the done/not-done report when all items are accounted for and no eligible work remains.
   Do not start another Task or Stage outside the authorized scope. Within the owner's explicitly launched finite group, checkpoint and continue
   eligible independent work without asking for duplicate start approval. Git permissions follow the
   current owner instruction rather than this reusable template.
