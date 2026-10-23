# Culmina — Claude Code adapter

Status: active client adapter, 2026-10-24. The shared repository contract is explicitly imported below. Read only its task routes; do not import all policy/history at startup.

@AGENTS.md

## Post-Roadmap Workflow Governance

Scope and permissions: [AGENTS](AGENTS.md). Preflight, integration, handoff and build receipts: [AI_WORKFLOW](docs/AI_WORKFLOW.md). Current state and next allowed action: [PROGRESS](docs/refinement/PROGRESS.md). A fresh session must verify memory against these sources. A prior full-plan launch or delivery permission does not restart in a new bounded task.

## Verification Policy (canonical)

The sole normative policy is [docs/VERIFICATION_POLICY.md](docs/VERIFICATION_POLICY.md), preserving V1–V8. This heading remains as a compatibility route for historical citations, not a second policy. Numbered “CLAUDE.md trap N” references resolve to [ENGINEERING_GUARDRAILS](docs/ENGINEERING_GUARDRAILS.md).

## Commands and operational state

Read the relevant V1 class before running checks. Documentation-only work needs reference/ID consistency and `git diff --check`; no application gate. Commands and environment belong to their task-specific sources, not machine assumptions in this adapter. Inspect `/memory` in a fresh Claude session to verify this file and AGENTS loading. Scoped `.claude/rules` supplement applicable tasks; `.agents/rules` and skills are read selectively. Never run `/init` to create competing rules.
