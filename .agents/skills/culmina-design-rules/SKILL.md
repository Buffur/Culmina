---
name: culmina-design-rules
description: Apply Culmina product/data invariants and documented exception boundaries to a named design task or review. Use the relevant decision clauses; do not reopen a roadmap or start design research.
---

# Culmina design rules and technical debt

Use when a design decision touches product meaning, scientific/data invariants or a documented exception. Do not load historical reports as another task queue or infer approval from code. [WORKFLOW](../../../docs/design/WORKFLOW.md#work-modes) owns the work modes.

## Read the relevant contract

Read the owner task, [BASELINE](../../../docs/design/BASELINE.md), and only relevant entries in [DECISIONS](../../../docs/DECISIONS.md), [ENGINEERING_GUARDRAILS](../../../docs/ENGINEERING_GUARDRAILS.md) and [TECH_DEBT](../../../docs/TECH_DEBT.md). [PROGRESS](../../../docs/refinement/PROGRESS.md) owns current status/permissions.

## Product rules that change decisions

- Planning first: understand a night, build a realistic Capture Plan, save, then record results. No telescope/camera control or invented Astro Score.
- Answer first, details reachable. Preserve existing camera-class/AM-04 behavior and calculations; do not simplify away scientific capabilities.
- Current Home: title/place/night → Your plan/action → The night ahead → next actions, with no-site/loading/error branches. Preserve compact Weather, guarded drafts and the current native composition. No unguarded New plan or Start action.
- Use selected-night wording and the existing UTC/zone/DST/SessionNight contracts. Remembered coordinates are not a live position; do not overwrite edited inputs silently.
- Unknown is not zero. Preserve explicit units, source/freshness, theoretical versus measured storage, and relative stacking gain versus absolute SNR. Settings supplies initial Plan assumptions; AF/MF is descriptive, without an invented numeric MF control.
- Fit and persistence/result state have different meanings. Keep words/reasons, draft/saved and planned/recorded boundaries, and Save/Discard/Cancel. Autosave of working edits is not explicit Save plan.
- Offline core stays meaningful. Any illustrative fixture must be identified as an example. Field mode's intentional secondary contrast is a bounded dark-adaptation exception, not a defect to remove or general AA evidence.

<a id="target-platform-and-reference-boundaries"></a>

Current native and Android anatomy/behavior come from BASELINE and actual components. [Earlier product-reference studies](../../../docs/design/references/LAB_HISTORY.md#product-reference-provenance) are optional provenance, not current adoption instructions.

## Debt handling

| Evidence | Disposition within the current task |
| --- | --- |
| Existing invariant or accepted exclusion | Preserve and cite the relevant decision |
| Documented temporary exception | Preserve its exact reason/boundary and remediation ID |
| Regression or approved criterion failure | Report in Review; correct only within an authorized Implement/Fix task |
| Adjacent unrelated issue | Record a precise finding without expanding implementation |
| New behavior or style preference | Proposal/owner decision; do not invent acceptance |

An example in an external guide is not a Culmina debt exception. Stable IDs and pending owner/device criteria remain.

<a id="product-rules-that-change-design-decisions"></a>
<a id="handoff-and-review"></a>

## Finish

Return the decision/invariant, actual affected source/caller, implemented versus accepted state, findings and [V1–V8](../../../docs/VERIFICATION_POLICY.md) evidence/limits. Browser, host, emulator, physical-device and owner acceptance are distinct.
