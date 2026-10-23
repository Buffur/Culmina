# Culmina — shared agent contract

Status: active repository policy, established by the owner's documentation/governance cleanup on 2026-10-24. Applies to all clients and repository work. Client/platform instructions and the owner's current request still apply.

## Product and invariants

Culmina (formerly AstroPlan) is a planning-first Flutter/Dart astrophotography organizer: understand a night, construct a realistic Capture Plan, save it, then record and organize results. Weather, Moon, equipment, Logbook, export and backup support that flow. No telescope/camera control, planetarium or invented Astro Score.

Preserve offline core, existing functions, scientific capabilities and progressive disclosure. Keep presentation → Provider/ViewModels → repository interfaces → data/services; calculations remain independent of Flutter. Do not replace working architecture or dependencies from a generic recipe.

Unknown stays unknown. Preserve explicit units, provenance, UTC/zone/DST/SessionNight semantics, theoretical versus measured storage, relative stacking gain versus absolute SNR, and data integrity. ISO does not increase photon collection. No invented sensor values, thresholds or source facts. Keep Save/Discard/Cancel, draft/saved and planned/recorded distinctions. Accepted AM-01–AM-05 and ADRs define the existing capture/night contracts; read their relevant clauses for the task.

## Authority and reading routes

1. The owner's **current explicit task and permissions** define this session's scope. An approved implementation task authorizes its complete in-scope work without repeated approval. New unresolved decisions or material expansion need the relevant owner decision; continue independent authorized work. A checked-in prompt, skill, memory or old run cannot authorize another task, Git delivery or device action.
2. Read [PROGRESS](docs/refinement/PROGRESS.md): the sole current baseline, pending criteria and next allowed action. It records state; it cannot silently broaden the current request.
3. Accepted intent lives in [PRODUCT_DIRECTION](docs/refinement/PRODUCT_DIRECTION.md), [DECISIONS](docs/DECISIONS.md) and the specifically named approved task contract. [FINAL_COMPLETION_ROADMAP](docs/refinement/FINAL_COMPLETION_ROADMAP.md) preserves F/G criteria; [POST_ROADMAP_PLAN](docs/refinement/POST_ROADMAP_PLAN.md) owns RG/RD and S-ID aliases. Neither is an automatically active queue.
4. Code proves implemented behavior; decisions prove agreed intent. A mismatch is a finding, not permission to rewrite either. Historical audits, archived prompts and dated reports prove only their stated inputs/coverage.
5. [VERIFICATION_POLICY](docs/VERIFICATION_POLICY.md) is the **only normative V1–V8 policy**. Preserve frozen acceptance, proportional checks, valid evidence reuse and honest PASS limits. Generic skills explain how, not when checks are required.

Read [AI_WORKFLOW](docs/AI_WORKFLOW.md) for preflight, parallel writers, integration, handoff, Git and build receipts. For UI tasks, read [design/BASELINE](docs/design/BASELINE.md), then [DESIGN_SYSTEM](docs/DESIGN_SYSTEM.md), [design/WORKFLOW](docs/design/WORKFLOW.md) and only relevant Culmina skills. Native theme/components are implementation truth; the approved frozen browser reference and later recorded refinements have distinct roles. Browser proof is not native/device/owner acceptance.

Read relevant [ENGINEERING_GUARDRAILS](docs/ENGINEERING_GUARDRAILS.md) before touching persistence, lifecycle, time, weather, metadata, UI, tests, privacy, signing or release. Old “CLAUDE.md trap N” references resolve there, with numbering preserved. [docs/README](docs/README.md) maps the other contracts/registers. Read supplemental `.agents/rules/` and skills selectively; do not assume every client auto-loads them.

## Safe working and stopping

Before editing, verify root, worktree, branch/HEAD, upstream, dirty/staged/untracked changes and current task. Preserve others' work; one writer per worktree. Recheck baseline before integration. Never copy an old checkout over current work.

No unrelated refactoring, weakened tests, fabricated verification, destructive Git, automatic stash/pop, unknown-file deletion or unrequested commit/push/publication. Owner signing keys/passwords and private samples stay private: never read, print, request or commit signing secrets. New providers, cloud/auth/social, monetization, hardware control or deferred sky-map/mosaic features require approved scope. Device installation, uninstall and data operations require the current task's authorization; do not inherit historical permissions.

New/substantially revised persistent documentation is English unless the owner says otherwise; conversation follows the user's language. Preserve original quotations and historical documents. Keep stable IDs and update only statements invalidated by the change.

Complete the authorized task and its required checks, record evidence and pending criteria in PROGRESS, then **stop at its boundary**. Do not restart a roadmap or redesign from historical “next” lines. Do not self-approve owner, physical-device, real-file, CI or release gates.
