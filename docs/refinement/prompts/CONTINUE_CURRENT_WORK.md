# Prompt — Continue the current work

> A reusable session prompt (created 2026-09-27, governance correction). The rules are
> `CLAUDE.md` ("Post-Roadmap Workflow Governance", including the Verification Policy); this file is
> only the procedure.

1. Read `docs/refinement/PROGRESS.md`: current state, reusable validation evidence, blockers and
   the **Next allowed action**. That action is the whole scope of this session.
2. Read only what that action names: its definition in the active queue (`FINAL_COMPLETION_ROADMAP.md`,
   approved 2026-10-18; older S-IDs resolve through its §4), the ADRs, finding IDs and files it
   references, then the relevant code and tests. Do not re-audit the repository or reread earlier
   Stages' history.
3. If the action is a frozen Task, the frozen sequence is the approval: `READ → VERIFY → PLAN →
   IMPLEMENT → VERIFY → SELF-REVIEW → DOCS → COMMIT → CHECKPOINT`. A single-task scope stops
   here; an explicitly authorized finite group continues to its next dependency-ready task under
   its launch brief (for the full plan, `CLAUDE_FINAL_PLAN_GOAL_IMPLEMENTATION.md`). A prompt file's
   presence does not activate a grouped run. Verify by change class and reuse
   valid evidence (Verification Policy V1–V3): a high-risk Task ends with one full-gate pass after
   its last code change; a shared-behaviour Task ends with its affected regression checks, and
   escalates to the full gate only as V1 says.
4. If the action is a research or owner-decision gate, do not implement; prepare the decision.
5. If the action is a Stage validation, use `INDEPENDENT_STAGE_VALIDATION.md`.
6. Update `PROGRESS.md` by its "How to update this file" rules and commit if authorized. Stop at the
   end of the named scope or a genuine unresolved gate/resource; do not start another Task or Stage
   outside that scope. Within the owner's explicitly launched finite group, checkpoint and continue
   eligible independent work without asking for duplicate start approval. Git permissions follow the
   current owner instruction rather than this reusable template.
