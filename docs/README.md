# Culmina documentation map

Culmina (formerly AstroPlan) is a planning-first Flutter/Dart astrophotography app: build a realistic
Capture Plan for a target, rig, site and night, see whether it fits the imaging opportunity, then save
it and record the result. This page says what to read and where each kind of fact lives. It holds no
status itself. (`index.md` and `privacy/` are the published GitHub Pages site, not this map.)

## A new session reads, in order

1. [`../CLAUDE.md`](../CLAUDE.md): product constraints, scope and approval rules, the canonical
   Verification Policy (V1–V8).
2. [`refinement/PROGRESS.md`](refinement/PROGRESS.md): current state, **the next allowed action**, open
   owner decisions, blockers, carried items and reusable evidence.
3. Only what that action names: its Task in the active queue (below), the ADRs and finding IDs it cites,
   the relevant traps in [`ENGINEERING_GUARDRAILS.md`](ENGINEERING_GUARDRAILS.md), then the code.

Do not reconstruct history to find the current task: dated "Next" lines in history files, audits and
archived prompts are not instructions.

## Plans and direction

| Document | Role |
| --- | --- |
| [`refinement/FINAL_COMPLETION_ROADMAP.md`](refinement/FINAL_COMPLETION_ROADMAP.md) | **The approved execution queue** (owner, 2026-10-18, P8): the remaining work as Tasks F01–F26 and gates G1–G4 in Stages A–D, with the owner's D1–D9 answers, a check per acceptance criterion and the release rows |
| [`refinement/FINALIZATION_REVIEW.md`](refinement/FINALIZATION_REVIEW.md) | The finalization workflow's record (P1–P8): coverage and UX findings, decisions, the P7 check. Its §§4–10 and §20 are hash-bound annexes of the roadmap; the rest is evidence, not a queue |
| [`refinement/POST_ROADMAP_PLAN.md`](refinement/POST_ROADMAP_PLAN.md) | The RG and RD registers (§7, §8) and workflow rules (§9); §5, Stages 12–17 (G3, 2026-10-17, with C1–C6, AUD-01–AUD-17 and audit 09's M1–M16), was the queue until 2026-10-18 and its Task IDs are now the roadmap's aliases |
| [`refinement/PRODUCT_DIRECTION.md`](refinement/PRODUCT_DIRECTION.md) | The accepted product direction; §9 lists what later owner decisions superseded |
| [`refinement/STAGES_12_17_READINESS_REVIEW.md`](refinement/STAGES_12_17_READINESS_REVIEW.md), [`refinement/STAGES_12_17_AUDIT_AMENDMENTS.md`](refinement/STAGES_12_17_AUDIT_AMENDMENTS.md) | Inputs already applied to Stages 12–17 (corrections C1–C6; AUD-01–AUD-17 dispositions) |
| [`audit/09_COMPREHENSIVE_AUDIT.md`](audit/09_COMPREHENSIVE_AUDIT.md), [`audit/10_UX_AUDIT.md`](audit/10_UX_AUDIT.md) | The audits behind the M1–M16 amendments and the proposal's UXA-C1–C5 fixes (evidence, not tasks) |
| [`refinement/STAGE_11_MATRIX.md`](refinement/STAGE_11_MATRIX.md), [`refinement/STAGE_11_DEVICE_RUNBOOK.md`](refinement/STAGE_11_DEVICE_RUNBOOK.md) | The validation matrix and device runbook still used by S17.5 and S17.7 (the proposal's G1–G2) |
| [`refinement/prompts/`](refinement/prompts/README.md) | Reusable session procedures (continue the current work; independent Stage validation) |

## Decisions, rules and registers

| Document | Holds |
| --- | --- |
| [`DECISIONS.md`](DECISIONS.md) | ADRs (index at the top; ADR-021 and ADR-022 planned), owner decisions in E.1, and a table of superseded decisions |
| [`ENGINEERING_GUARDRAILS.md`](ENGINEERING_GUARDRAILS.md) | The numbered traps ("CLAUDE.md trap N") for persistence, lifecycle, time, weather, metadata, UI, tests, privacy, signing and release |
| [`SCIENTIFIC_INTEGRITY.md`](SCIENTIFIC_INTEGRITY.md) | Scientific issues SI-### (open and closed), the calculation register CALC-##, rules for scientific changes |
| [`TECH_DEBT.md`](TECH_DEBT.md) | Defects and debt TD-### (open items first, with their scheduled Task) |
| [`FEATURE_STATUS.md`](FEATURE_STATUS.md) | What exists, feature by feature (F-##) |
| [`ARCHITECTURE.md`](ARCHITECTURE.md), [`DATA_MODEL.md`](DATA_MODEL.md) | Design intent (Part A) and the actual architecture and schema (Part B; schema v25) |
| [`DESIGN_SYSTEM.md`](DESIGN_SYSTEM.md) | UI tokens, accessibility and interaction patterns |
| [`design/WORKFLOW.md`](design/WORKFLOW.md) | Project design skills, restrained visual direction, font examples and the isolated Home browser lab |
| [`design/WEB_TO_FLUTTER_MIGRATION.md`](design/WEB_TO_FLUTTER_MIGRATION.md) | In-progress Hybrid / Geist web → Flutter migration ledger; resume via [`design/migration/CONTINUATION_PROMPT_2026_10_20.md`](design/migration/CONTINUATION_PROMPT_2026_10_20.md) |
| [`IA_WIREFRAMES.md`](IA_WIREFRAMES.md), [`IA_WIREFRAMES_ADDENDUM.md`](IA_WIREFRAMES_ADDENDUM.md) | Accepted information-architecture intent (ADR-015, ADR-019) |
| [`PRODUCT_SPEC.md`](PRODUCT_SPEC.md) | The Phase 0 product specification (design intent; the current direction is `PRODUCT_DIRECTION.md`) |

## Contracts, release and compliance

| Document | Holds |
| --- | --- |
| [`EXPORT_MANIFEST.md`](EXPORT_MANIFEST.md) | The session export contract (`SessionManifestCodec`, manifest v2) |
| [`TEST_PLAN.md`](TEST_PLAN.md) | Test types, the lifecycle matrix (L1–L8) and device checks |
| [`RELEASE.md`](RELEASE.md) | Release build, signing and the move from Astro Planner (GitHub Releases; the Play procedure is deferred) |
| [`COMPLIANCE.md`](COMPLIANCE.md) | Third-party terms, licences (GPL-3.0 with the §7 additional permission), permissions, privacy record |
| [`privacy/index.md`](privacy/index.md), [`index.md`](index.md) | The published privacy policy and project page (GitHub Pages; edit only through a Task, trap 22) |

## History and evidence

| Location | Contents |
| --- | --- |
| [`refinement/PROGRESS_HISTORY.md`](refinement/PROGRESS_HISTORY.md) | Every earlier PROGRESS entry, verbatim |
| [`refinement/POST_ROADMAP_PLAN_HISTORY.md`](refinement/POST_ROADMAP_PLAN_HISTORY.md) | Stage 0–11 definitions, frozen Task sequences and acceptance; the plan's update log; audit traceability to Stages 1–11 |
| `refinement/STAGE_N_*.md`, [`refinement/STAGE_12_13_CLOSURE.md`](refinement/STAGE_12_13_CLOSURE.md) | Stage validation reports (FAIL/BLOCKED records stay as written; later corrections and revalidations are separate reports) |
| `refinement/evidence/` | Device checks, measurements, probe patches, renders and the identity artwork rounds (`tool/make_launcher_icons.py` reads `identity/round5/`) |
| `refinement/research/` | Research reports behind RG, RA and S-research decisions |
| `audit/` | Audits 01–08 (baseline `becae04` and the owner's dogfooding report; evidence for ENG-/SCI-/RT-/UX- IDs and "08 §N"); 09 and 10 (above) |
| [`PROJECT_AUDIT.md`](PROJECT_AUDIT.md) | The 2026-09-21 takeover audit (point-in-time evidence) |
| [`archive/`](archive/README.md) | Superseded documents: the master roadmap, the Phase 0 roadmap, the takeover handoff, completed prompts, the pre-condensation `CLAUDE.md`, the previous agent's documents |
