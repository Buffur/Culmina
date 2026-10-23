# Culmina documentation map

Status: active navigation and responsibility map. Current state belongs only to [refinement/PROGRESS](refinement/PROGRESS.md); this page deliberately does not duplicate schema/tool versions, test counts or delivery hashes. Culmina is a planning-first astrophotography organizer. `index.md` and `privacy/` are the published GitHub Pages site.

## Start a session

1. [AGENTS](../AGENTS.md): shared product constraints, authority, permissions, reading routes and stop boundary. [CLAUDE](../CLAUDE.md) and [GEMINI](../GEMINI.md) are thin client adapters to that same core.
2. [PROGRESS](refinement/PROGRESS.md): current integration baseline, authorized scope, implemented versus owner-accepted, pending criteria, reusable evidence and the next allowed action. Historical launches never automatically restart.
3. [AI_WORKFLOW](AI_WORKFLOW.md): repository preflight, preservation, one-writer coordination, integration, handoff and build/package receipts. [VERIFICATION_POLICY](VERIFICATION_POLICY.md): the sole canonical V1–V8 policy.
4. Read only the task's named approved contract, decisions/finding IDs and relevant [ENGINEERING_GUARDRAILS](ENGINEERING_GUARDRAILS.md), then relevant code/evidence. UI work also starts with [design/BASELINE](design/BASELINE.md).

## Intent, contracts and state

| Source | Responsibility |
| --- | --- |
| [PRODUCT_DIRECTION](refinement/PRODUCT_DIRECTION.md) | Accepted product direction; later owner decisions supersede only their named clauses |
| [DECISIONS](DECISIONS.md) | Accepted ADRs and owner decisions, with provenance/supersession; each status block is authoritative |
| [FINAL_COMPLETION_ROADMAP](refinement/FINAL_COMPLETION_ROADMAP.md) | Approved frozen F01–F26/G1–G4 criteria, not an automatically active queue |
| [FINALIZATION_REVIEW](refinement/FINALIZATION_REVIEW.md) | P1–P8 preparation/decision evidence and hash-bound annexes; preserve bytes/IDs |
| [POST_ROADMAP_PLAN](refinement/POST_ROADMAP_PLAN.md) | RG/RD registers and approved earlier S-ID aliases; session workflow routes to AI_WORKFLOW |
| [FEATURE_STATUS](FEATURE_STATUS.md), [TECH_DEBT](TECH_DEBT.md), [SCIENTIFIC_INTEGRITY](SCIENTIFIC_INTEGRITY.md) | Feature, defect and calculation registers; inspect exact partial-resolution boundaries before acting |
| [ARCHITECTURE](ARCHITECTURE.md), [DATA_MODEL](DATA_MODEL.md) | Intent and actual architecture/schema; verify actual schema from `app_database.dart`, not a copied navigation value |
| [EXPORT_MANIFEST](EXPORT_MANIFEST.md) | Versioned session export contract and SessionManifestCodec association |
| [IA_WIREFRAMES](IA_WIREFRAMES.md), [IA_WIREFRAMES_ADDENDUM](IA_WIREFRAMES_ADDENDUM.md) | Approved information-architecture intent, subject to later named amendments |
| [PRODUCT_SPEC](PRODUCT_SPEC.md) | Phase 0 intent; current product direction has the explicit successor above |

## Design and evidence

| Source | Responsibility / limit |
| --- | --- |
| [design/BASELINE](design/BASELINE.md) | Current native tokens/typography/components, final frozen Hybrid reference, later approved refinements and acceptance boundaries |
| [DESIGN_SYSTEM](DESIGN_SYSTEM.md), [design/WORKFLOW](design/WORKFLOW.md), [local skills](../.agents/skills/README.md) | Shared visual contracts and task-specific methods; code owns implemented values, skills cannot approve scope |
| [Hybrid transfer record](design/migration/HYBRID_TRANSFER_STATUS.md) | Completed bounded transfer and explicit §9 owner confirmation; later delivery acceptance remains separate |
| [Consolidation delivery](design/migration/CONSOLIDATED_DELIVERY_2026_10_24.md) | Integrated design/geo/identity preservation and dated test/build/physical observations; current next action still comes from PROGRESS |
| [Earlier web-to-Flutter migration](design/WEB_TO_FLUTTER_MIGRATION.md) | Historical earlier port and coverage; its embedded continuation instructions are superseded by the final transfer record, not current work |
| [STAGE_11_MATRIX](refinement/STAGE_11_MATRIX.md), [device runbook](refinement/STAGE_11_DEVICE_RUNBOOK.md), [TEST_PLAN](TEST_PLAN.md) | Frozen device/human/lifecycle checks and test methods; required checks are selected only under VERIFICATION_POLICY and the current task |
| [RELEASE](RELEASE.md), [COMPLIANCE](COMPLIANCE.md) | Authorized release/signing and terms/privacy procedures; no signing secrets belong in agent context |
| [privacy/index](privacy/index.md), [project page](index.md) | Published pages; changes need the appropriate task and guardrails |
| [Tooling inventory](AI_TOOL_CAPABILITIES_2026_10_20.md), [maintenance results](design/tooling-update-2026-10-20/RESULT.md) | Dated machine/client observations; verify local availability/loading/authorization before relying on them |

## Procedures and historical material

| Location | Responsibility / successor |
| --- | --- |
| [Reusable prompts](refinement/prompts/README.md) | Procedures activated only by current owner scope; no implicit full-plan launch |
| [PROGRESS_HISTORY](refinement/PROGRESS_HISTORY.md) | Verbatim superseded progress, including the complete pre-cleanup snapshot and its contradictions |
| [POST_ROADMAP_PLAN_HISTORY](refinement/POST_ROADMAP_PLAN_HISTORY.md), `refinement/STAGE_N_*.md` | Approved earlier stage definitions and immutable dated validation outcomes |
| [Independent develop review](refinement/DEVELOP_IMPLEMENTATION_REVIEW_2026_10_19.md), [PROJECT_AUDIT](PROJECT_AUDIT.md), `audit/` | Dated audits/findings; not a current task queue or automatic repair permission |
| `refinement/evidence/`, `design/migration/evidence/`, `../design/home-lab/evidence/` | Immutable input-specific logs, captures, fixtures and criterion mappings; browser/host/native/device/owner levels remain distinct |
| `refinement/research/`, `design/` dated studies | Research/decision provenance; later intent and actual implementation are mapped in BASELINE |
| [Archive index](archive/README.md) | Superseded materials and objects intentionally retained in place; open findings remain in canonical registers |
| [Governance cleanup report](audit/AI_CONTEXT_CLEANUP_2026_10_24.md) | This cleanup's inventory, conflicts, verification, limitations and preservation evidence; not another current-state file |

Old “CLAUDE.md V1–V8” citations route to VERIFICATION_POLICY through the adapter; old numbered traps route to ENGINEERING_GUARDRAILS. Historical schema/count/version/hash observations stay in their original evidence. A discrepancy between code and approved intent is a finding, not authority to rewrite either.
