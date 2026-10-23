# Culmina (formerly AstroPlan) — Post-Roadmap Refinement Plan

> **Current routing (2026-10-24):** this file preserves approved clauses/S-ID aliases and owns RG/RD registers. It does not activate work; [PROGRESS](PROGRESS.md) and the current owner task determine the next permitted action. [AGENTS](../../AGENTS.md) owns the shared contract, [AI_WORKFLOW](../AI_WORKFLOW.md) owns session/integration procedure, and [VERIFICATION_POLICY](../VERIFICATION_POLICY.md) is the sole V1–V8 policy. Earlier dated sequence/status paragraphs below are history, not a second current queue.

> **Owner AM-05 (2026-10-18):** current execution uses targeted Task/dependency tests and attention-item continuation under CLAUDE V1/V7 and FINAL_COMPLETION_ROADMAP version -08. Old blanket per-Task full-suite timing in the S-ID clauses below is superseded; meaningful domain probes and final G1/F26 checks remain. Do not treat historical S-clauses as a second active queue.

> **Status (2026-10-18):** the strategic plan and the RG/RD registers of post-roadmap refinement.
> **The approved F/G task contract is [`FINAL_COMPLETION_ROADMAP.md`](FINAL_COMPLETION_ROADMAP.md)**, approved
> by the owner on 2026-10-18 (P8 base P6-2026-10-18-02; current AM-01–AM-03 version P6-2026-10-18-06, DECISIONS E.1). §5, "Stages 12–17 — Culmina release roadmap (RA.P)" (approved at G3, 2026-10-17, and amended
> by C1–C6, AUD-01–AUD-17 and audit 09's M1–M16), was the queue until then; its remaining Task IDs are now
> the roadmap's aliases (its §4), and §5 stays as the record of the approved clauses they trace to. §7, §8
> and §9 (registers and workflow rules) stay in force. Each Task starts only on the owner's start instruction.
> **Where things stand** (Stage status, next allowed action, open decisions): [`PROGRESS.md`](PROGRESS.md).
> **Completed history:** [`POST_ROADMAP_PLAN_HISTORY.md`](POST_ROADMAP_PLAN_HISTORY.md) holds, verbatim and with the same section
> numbers, the Product Reassessment amendment, the plan's update log to 2026-09-29, §1 (the baseline at
> Stage 0), the Stage 0–11 definitions with their frozen Task sequences and acceptance clauses, §6
> (audit traceability to Stages 1–11) and Appendices A and B (moved there on 2026-10-18).
> **Authority:** the owner's Stage 0 prompt
> ([`archive/refinement-prompts/STAGE_0_REFINEMENT_BASELINE.md`](../archive/refinement-prompts/STAGE_0_REFINEMENT_BASELINE.md)),
> the owner's later decisions (DECISIONS E.1) and the post-roadmap governance in `CLAUDE.md`. Changing a
> Stage's definition, the Stage order or a gate needs the owner's approval.
> **Read with:** [`PRODUCT_DIRECTION.md`](PRODUCT_DIRECTION.md) (what and why) and `PROGRESS.md` (where
> things stand).

## Contents

1. Baseline at Stage 0 — *in the history file*
2. Evidence base and how to weigh it
3. Stage overview
4. Dependency order
5. Stage definitions: Stages 0–11 (an index; definitions in the history file) and **Stages 12–17 (the approved queue)**
6. Traceability: audit findings → Stages 1–11 — *in the history file* (Stage 12–17 traceability is inside §5)
7. Research gate register (RG)
8. Owner decision register (RD)
9. Workflow rules
10. Relationship to historical documents
- Appendix A — Manual dogfooding report (08) → Stages — *in the history file*
- Appendix B — Carried roadmap work — *in the history file* (its open device and owner items now run through the Stage 11 matrix into S17.5 and S17.7)
- Appendix C — Findings rejected or accepted as documented

**Identifiers.**
- **Stage N** (S0–S17) is a refinement Stage.
- **RG-##** is a research gate; **RD-##** is an owner decision raised by refinement. Both are
  stable and never renumbered. A resolved RG or RD keeps its ID and records the outcome, the
  date, and where the decision is written (an ADR or entry in `DECISIONS.md`).
- **ENG-##, SCI-##, RT-##, UX-##** are findings in `docs/audit/02`–`05`, as judged by
  `docs/audit/06_COUNTER_AUDIT.md`. **"08 §N"** is a section of
  `docs/audit/08_MANUAL_DOGFOODING.md`.
- The existing IDs (F-, TD-, SI-, CALC-, PD-, OD-, ADR-, DEV-) keep their meaning.

---

## 1. Baseline at Stage 0

Moved verbatim to [`POST_ROADMAP_PLAN_HISTORY.md`, §1](POST_ROADMAP_PLAN_HISTORY.md#1-baseline-at-stage-0): the verified state at `becae04`
(2026-09-25), the items carried from the master roadmap, and the thirteen discrepancies found at Stage 0.

---

## 2. Evidence base and how to weigh it

| Source | Nature | How to use it |
| --- | --- | --- |
| `docs/audit/01`–`05` | AI audit stages: roadmap compliance, engineering, scientific, runtime, UI/UX (2026-09-24/25, at `becae04`) | Structured technical evidence. Their classifications are inputs, not verdicts |
| `docs/audit/06_COUNTER_AUDIT.md` | AI adversarial re-check of 01–05 | Settles disputes between 01–05. **A finding 06 rejected is not revived** unless new repository evidence proves it (Appendix C) |
| `docs/audit/07_FINAL_AUDIT.md` | Synthesis of 01–06 | Its confirmed issues (§2, §3, §4.1) feed Stage 1. Its priority map (§9) and refinement candidates (§10) are recommendations and hypotheses, not decisions |
| `docs/audit/08_MANUAL_DOGFOODING.md` | The owner's hands-on report | Distinct evidence. Appendix A separates **human observation, author/product intent, proposed solution, research question and preference**. Proposed solutions are not approved architecture, and no observation may be lost because the AI audits did not mention it |
| Source-of-truth documents | Living registers and ADRs | Current state and accepted decisions. The audits are snapshots and are never edited |

**Limits of the evidence** (06 §D): no Android device or emulator run, no TalkBack walkthrough,
no darkness test, no user study; the audit probes were deleted after their runs. Every
finding is re-verified before it is fixed (§9.7).

---

## 3. Stage overview

Stages run in order. A Stage starts after the previous one is closed, unless the owner approves
an overlap. Research gates may run earlier than their Stage (§4).

| Stage | Name | Primary kind | Gates and decisions | Depends on |
| --- | --- | --- | --- | --- |
| 0 | Refinement Baseline | Documentation | — | — |
| 1 | Verified Fixes & Clean Baseline | Implementation, low research | RD-03; optional RD-02, RD-05 (interim), RD-17 | 0 |
| 2 | Metadata Foundation | Implementation after a research gate | RG-01; RD-16 | 1 |
| 3 | Metadata → Equipment / Device Import | Research and architecture gate, then implementation | RG-02, RG-03 | 2 |
| 4 | Product Flow & Information Architecture | Product/UX analysis and owner decisions | RG-04 to RG-06; RD-04 to RD-07, RD-14 | 3 |
| 5 | Design System Foundation | Implementation | RD-09 | 4 |
| 6 | Core Planner Redesign | Implementation | RD-06 (decided), RD-10, RD-11, S4-DEF-04; RD-08 before capture-plan work (P6.8, frozen as S6.9). Options prepared at Stage 6 planning (2026-09-27) | 4, 5 |
| 7 | Data Entry & Automation | Research gates, then implementation | RG-07 to RG-11; RG-03 (researched again, 2026-09-28); RD-08 (decided T3, built by S7.1). Frozen at Stage 7 planning (2026-09-28) | 3, 5, 6 |
| 8 | Sessions / Execution / Actuals / Logbook | Implementation after Stage 4's decisions; the tracker's retirement after an audit (2026-09-27) | RD-13 (RD-12 lapsed 2026-09-27) | 4, 6 (2 for assisted actuals) |
| 9 | Secondary UX & Product Polish | Implementation, plus licence research | RG-12, RG-13; RD-01, RD-11; the owner's logo choice | 5 (and 4 for the Library) |
| 10 | Performance & Application Size | Measurement first, then optimisation | RD-02 (dependency) | 6–9 |
| 11 | Full Validation & Beta Readiness | Independent validation | RD-15; owner actions | 1–10 |
| 12 | Release foundation (RA.P) | CI fix; owner actions | S11P-03; trademark search | 11 (S11.C2) |
| 13 | Identity: Culmina (RA.P) | Implementation; owner artwork approval | ID-1 to ID-6 | 12 |
| 14 | Capture Plan completeness (RA.P) | ADR-021, then implementation (v26) | Round 2A | 12 (13 for device evidence) |
| 15 | Night conditions (RA.P) | ADR-022, then implementation | Q2 (MF-c), PD-16, PD-17, Q3 | 12 |
| 16 | Screens and flow (RA.P) | Implementation | Round 2B, Q1, Q4 | 14, 15 |
| 17 | Final validation and GitHub release (RA.P; folds in S11.6, S11.7; GitHub-only distribution) | Independent validation; owner release actions | Go/no-go | 12–16 |

Current status of each Stage: `PROGRESS.md`.

---

## 4. Dependency order

The order is the owner's (Stage 0 prompt §11). The reasoning:

- **Stage 1 first.** Confirmed defects are fixed before structural work, so later Stages do not
  build on known-wrong outputs (such as a frozen forecast age) and later validation is not
  confounded by them.
- **Stages 2 and 3 before Stage 4.** Flow and IA decisions depend on which inputs can be
  automated reliably, equipment from metadata in particular. Metadata extraction and
  equipment identity mapping are different problems, so they are separate Stages, and Stage 3
  opens with a research and architecture gate.
- **Stage 4 before Stages 5–9.** Decide the flow and structure before building patterns into
  screens and redesigning them. No audit pattern (05 P0–P10, 07 §10) is preselected.
- **Stage 5 before Stage 6.** One reusable visual and interaction system instead of fixes
  screen by screen (08 §27, "Design System").
- **Stage 6 before Stages 7 and 8.** Planning is the primary job.
- **Research may run early.** Stage 7's gates shape the planner (RD-08 tracking, RG-10
  calibration, RG-11 capture parameters). Their research sessions may run during Stages 4–6,
  and RD-08 should be decided before Stage 6 reworks the capture plan. Implementation stays in
  its own Stage unless the owner moves it. In general, research may precede its implementation
  Stage; implementation never precedes its gate.
- **Stage 8 after the planning experience is stable** and after Stage 4 has decided Execution's
  role. Metadata-assisted actuals (the old 17.3) also need Stage 2.
- **Stage 10 measures after the main UI changes,** so optimisation is not wasted.
  Measurement-only work (for example, what the ~277 MB figure actually is) may run earlier.
- **Stage 11 was the final independent validation of the original sequence.** Since G3, Stage 17 is the final validation and release stage; the remaining Stage 11 checks are carried into it.
- **Owner actions that block release, not refinement,** can happen at any time: RD-01 (the
  account behind the app identity), the release signing key (S17.6; the Play upload key is deferred), publishing the privacy policy
  (16.3), and a device or emulator for testing.

---

## 5. Stage definitions

### Stages 0–11 (complete or closed)

Their definitions, frozen Task sequences, gates, acceptance clauses and corrective Tasks are kept
verbatim in [`POST_ROADMAP_PLAN_HISTORY.md`](POST_ROADMAP_PLAN_HISTORY.md#5-stage-definitions-stages-011). Their IDs (S1.1, P6.3, S4-DEF-01, S7.V2, …)
keep their meaning. Validation results: `PROGRESS.md`, "Stage status", and the `STAGE_N_*.md` reports.

| Stage | Name | Outcome | Definition |
| --- | --- | --- | --- |
| 0 | Refinement Baseline | Complete | [definition](POST_ROADMAP_PLAN_HISTORY.md#stage-0--refinement-baseline-complete) |
| 1 | Verified Fixes & Clean Baseline | Complete (owner waiver) | [definition](POST_ROADMAP_PLAN_HISTORY.md#stage-1--verified-fixes--clean-baseline) |
| 2 | Metadata Foundation | Complete (owner waiver) | [definition](POST_ROADMAP_PLAN_HISTORY.md#stage-2--metadata-foundation) |
| 3 | Metadata → Equipment / Device Import | Complete | [definition](POST_ROADMAP_PLAN_HISTORY.md#stage-3--metadata--equipment--device-import) |
| 4 | Product Flow & Information Architecture | Complete | [definition](POST_ROADMAP_PLAN_HISTORY.md#stage-4--product-flow--information-architecture) |
| 5 | Design System Foundation | Complete | [definition](POST_ROADMAP_PLAN_HISTORY.md#stage-5--design-system-foundation) |
| 6–11 | Shared rules for Stages 6–11 (ownership, information hierarchy, disclosure, visualisations, look, words, exclusions) | Superseded where RA.D decided otherwise (`PRODUCT_DIRECTION.md` §9; for example PD-06's format-aware storage replaces the "theoretical RAW storage payload" exclusion). The standing principles are in `PRODUCT_DIRECTION.md` §5 and `DESIGN_SYSTEM.md` | [definition](POST_ROADMAP_PLAN_HISTORY.md#stages-611-shared-rules-amended-after-stage-5-2026-09-27) |
| 6 | Core Planner Redesign | Complete | [definition](POST_ROADMAP_PLAN_HISTORY.md#stage-6--core-planner-redesign) |
| 7 | Data Entry & Automation | Complete | [definition](POST_ROADMAP_PLAN_HISTORY.md#stage-7--data-entry--automation) |
| 8 | Sessions / Execution / Actuals / Logbook | Complete | [definition](POST_ROADMAP_PLAN_HISTORY.md#stage-8--sessions--execution--actuals--logbook) |
| 9 | Secondary UX & Product Polish | Complete (S9.10–S9.12 deferred, later taken up by RA.D and Stage 13; RG-12 still deferred) | [definition](POST_ROADMAP_PLAN_HISTORY.md#stage-9--secondary-ux--product-polish) |
| 10 | Performance & Application Size | Complete | [definition](POST_ROADMAP_PLAN_HISTORY.md#stage-10--performance--application-size) |
| 11 | Full Validation & Beta Readiness | Closed, superseded by Stage 17 (G3): S11.6 → S17.5, S11.7 → S17.7; `STAGE_11_MATRIX.md` and `STAGE_11_DEVICE_RUNBOOK.md` stay in use | [definition](POST_ROADMAP_PLAN_HISTORY.md#stage-11--full-validation--beta-readiness) |

### Stages 12–17 — Culmina release roadmap (RA.P, 2026-10-17)

> **Status: APPROVED by the owner (gate G3), 2026-10-17:** "Approve G3: the RA.P roadmap (Stages 12–17) as proposed. Do not start S12.1 until I send its start instruction."
> Each Task runs one at a time, under its own start instruction from the owner (CLAUDE.md: no
> automatic next Task). Approval of the roadmap is not a start instruction for any Task.
>
> **Sources:**
> - the decisions in DECISIONS E.1: "RA.D — ID-1", "RA.D — round 1 identity", "RA.D — release scope
>   principle", "RA.D round 2A — Capture Plan", "RA.D round 2B/2C", "RA.D — Q1 to Q4";
> - the requirements in `refinement/research/RA_D_ROUND2_PACKAGE.md` (Parts A, B, D) and
>   `refinement/research/RA_D_IDENTITY_TRANSITION.md`;
> - the evidence in RA.R1 and RA.R2.
>
> **Distribution amendment (GitHub-only distribution, 2026-10-17; DECISIONS E.1):** the release is a signed APK on GitHub Releases. Store-only
> requirements are marked **Deferred (store distribution)** in place; every quality, privacy, licensing, accessibility and
> device requirement stays. New: S17.6 is GitHub release packaging, S17.8 publishes the release.
>
> **Readiness review corrections (owner-approved, 2026-10-17; DECISIONS E.1; [report](STAGES_12_17_READINESS_REVIEW.md)):**
> C1 S17.6 precedes S17.5 and adds a remote CI run on the release commit; C2 the cross-id, cross-schema
> backup rehearsal in S17.5; C3 S14.9 depends on S14.7 and S14.8, with S14.1/S14.3/S14.7 wording;
> C4 S12.4 (a)'s About statement in S16.8; C6 TD-002, TD-099 and two traceability dispositions. No
> functionality added, no decision reopened, no Task renumbered.
>
> **Independent audit integrated, owner instruction 2026-10-17:** refine the existing functions and already approved Tasks; add no new product capability, Stage or Task. Defect fixes and acceptance clarifications below retain C1–C6 and all 42 Task IDs. [Audit dispositions](STAGES_12_17_AUDIT_AMENDMENTS.md) distinguish reproduced defects from contract risks, the unapproved partial-rig proposal and optional ABI ideas. Changes to frozen future criteria are recorded in DECISIONS E.1; earlier PASS evidence is reused under V3/V5.
>
> **Audit 09 amendments applied (owner, 2026-10-17):** «Можешь внести эти правки в план» [“apply these amendments to the plan”]. M1–M16 of [`audit/09_COMPREHENSIVE_AUDIT.md`](../audit/09_COMPREHENSIVE_AUDIT.md) §H are written into the Tasks below, marked "Audit 09"; the owner decisions CA-OD1 to CA-OD3 stay open ("Shared rules"). No Stage or Task is added or renumbered; C1–C6 and the AUD-01–AUD-17 integration stay. Stage 12 is closed, and Stage 13 is blocked at its closure on S13V-01 ([`STAGE_12_13_CLOSURE.md`](STAGE_12_13_CLOSURE.md)).
>
> **Stage 11:** S11.1–S11.5, S11.C1 and S11.C2 are done and their evidence stays reusable under V3.
> The open S11.6 and S11.7 are **folded into Stage 17** (S17.5, S17.7): the redesign changes the
> inputs of their rows, so they must run on the final build. **Since G3 (2026-10-17) Stage 11 is closed
> as "superseded by Stage 17"**; no earlier PASS is reopened without V3/V6 grounds.

#### Shared rules for Stages 12–17

- **Workflow.** One Task per cycle: READ → VERIFY → PLAN → IMPLEMENT → VERIFY → SELF-REVIEW → DOCS →
  COMMIT → STOP. The next Task waits for the owner's start instruction.
- **Verification class.** Each Task's V1 class is stated below; the highest class among the files
  it changes wins (CLAUDE.md). "Full gate" means `dart run tool/check.dart` after the last change.
- **UI Tasks (K14).**
  - Host renders of every changed screen: light, dark and field themes; 100 % and 200 % text; 412 px.
  - The renders are reviewed by the owner before the Task closes.
  - Every review render draws all visible text in a real font: either the host harness loads Roboto and the Material icons for every text style (the theme names its font family), or the screen is captured natively (Windows) or on the phone. A render with placeholder glyph blocks is not visual evidence for the affected elements (CA-11, audit 09 M10).
  - The accessibility sweep covers the changed screens (trap 17).
  - Separately observe four bounded **existing workflows** across S16.1–S16.4/S16.7: phone manual/photo-assisted setup; DSLR proposal/edit/cancel; astro-camera metadata/calibration; returning multi-night save/result/progress. Run each workflow as a scripted walkthrough, by the owner or an agent, on the phone or a host E2E harness, and record per step: the screen; the action; any backtrack or dead end; any value the user had to look up elsewhere; whether the screen itself states the fit verdict, the reason for each Unknown and what relative gain means, without opening help. A claim that a person understood something is recorded only from a person other than the builder; otherwise it is UNVERIFIED (audit 09 M4 (a)). This is functional acceptance, not a new research cycle or a statistical usability claim; independent-participant evidence remains UNVERIFIED when unavailable (AUD-10).
- **Device checks.**
  - Development checks and identity-migration rehearsals run on separate `.s2check` test packages, never on the owner's data (the runbook's rules).
  - Exception: S17.5's release-artifact checks and S17.8's published-download check use the actual signed APK with its production application id and release key, on a clean device/profile or an owner-approved installation. A test-package rebuild does not substitute for release-artifact evidence. The owner's data moves only after the test-package rehearsal passes, as the last step of S17.5.
  - From S13.2 onward, under the new id.
- **Registers in the same change.** Decisions in DECISIONS E.1 and ADRs; calculations in
  SCIENTIFIC_INTEGRITY (new CALCs with hand-computed vectors, Part C); findings in TECH_DEBT;
  FEATURE_STATUS, DATA_MODEL and EXPORT_MANIFEST where touched; privacy and COMPLIANCE for anything
  that leaves the device (trap 22). English preferred, per CLAUDE.md's language policy (revised 2026-10-17).
- **Stage close.** Each Stage ends with a bounded validation in a fresh session where practical
  (V4, V8), against that Stage's acceptance only. Corrections follow V5.
- **Start rule (audit 09 M14).** A Task may start when its listed dependencies are met. A pending S14.5 (the FITS sample) blocks only S14.5 and Stage 14's close, not Stage 15 or Stage 16 Tasks that do not list it. S17.1 starts only when S14.5 is done or the owner explicitly defers FITS reading, recorded in DECISIONS E.1 with its PD-11 and RG-03 consequences.
- **Open owner decisions from audit 09** (each decided before the Task named; none is decided by this amendment):
  - **CA-OD1**, the brand in the UI tokens, before S16.6: (A) neutral, as today; (B, recommended by the audit) dark-theme surfaces tinted toward navy and the ice-blue family (`#8CCBFF`) as the accent for primary actions, links, selection and focus, the light theme gaining the accent only, AA vectors for every changed pair, field mode unchanged, tokens only; (C) B plus Dark as the default Appearance for new installs.
  - **CA-OD2**, APK packaging, at S17.6 with measured sizes: universal only, or arm64-v8a plus universal.
  - **CA-OD3**, at S14.1: 'Undo the last restore' in S14.3, and how many safety copies are kept.
  - *Later (2026-10-18):* answered with the proposal's D-choices (DECISIONS E.1, "Final completion roadmap: D1 to D9 and UX-S answered"): CA-OD1 = (A) neutral, System default; CA-OD3 = no Undo control, one newest safety copy with deterministic recovery; CA-OD2 stays with the measured sizes at S17.6 (F26).
- **Stop conditions, every Task:**
  - its acceptance is met and committed;
  - or a new unresolved product, scientific, provider or data decision appears — STOP, present the
    options to the owner;
  - or a prerequisite owner action is missing — STOP, report it.

#### Stage 12 — Release foundation

| Task | Objective | Depends on | Acceptance | V1 class |
| --- | --- | --- | --- | --- |
| **S12.1** | **TD-104: make the remote CI gate pass** | The failing job's log: the owner downloads it while signed in, or authorizes `gh`. Fallback: reproduce on Linux (WSL or a container) if available | (1) The failing test is named, citing the log. (2) The root cause is recorded in TD-104 (and in TD-096 if the wall clock is involved). (3) The cause is fixed; no test is skipped or weakened. (4) The workflow's announced breakages are handled: `actions/checkout` on Node 20, and the runner image pinned instead of `ubuntu-latest` (moving to Ubuntu 26). (5) The local full gate passes. (6) After an owner-authorized push, a remote run on `main` passes, read from GitHub. (7) TD-104 and RD-17 are updated with the run | Full gate (tests or tooling change); a CI-only change also needs its syntax and path logic checked |
| **S12.2** | **(Owner, recommended) formal trademark search for "Culmina"**: classes 9 and 42; WIPO GBD, EUIPO, USPTO; optionally UKRNOIVI. *Amended (GitHub-only distribution, 2026-10-17): no longer a store-publication gate; recommended before the public rename (S12.3) because the name is used publicly on GitHub* | — | The result is recorded in DECISIONS E.1. A conflict is put to the owner, who decides whether to reopen ID-1 (and ID-3, ID-4) before S13.2. If the owner skips the search, the documented naming risk stays the record (`RA_R2D_IDENTITY.md` §2–§3) | Owner action |
| **S12.3** | **Privacy-policy text and the URL transition**: the agent prepares the text; the owner renames and publishes (`RA_D_IDENTITY_TRANSITION.md` §4, steps 1–5). The policy stays mandatory under GitHub-only distribution: the app sends data to third parties and links the policy | — (S12.2 recommended before the rename; amended GitHub-only distribution, 2026-10-17) | (1) `docs/privacy/index.md` corrected: TD-099's weather wording; the 16-night request (PD-16); links the user opens (Clear Outside, Q3); the contact email supplied by the owner. (2) (Owner) the repository is renamed `Buffur/Culmina`, Pages are enabled, and the policy, project and source URLs answer 200 (recorded). (3) Never recreate `Astro-Planner` | Documentation; owner actions |
| **S12.4** | **(Owner decision) S11P-03:** `geolocator_android` bundles Google Play services location in a GPL-3.0 app. Unchanged by GitHub-only distribution: the APK is still distributed under GPL-3.0 | Options from S11.4's evidence | **Decided (a), 2026-10-17:** retain `geolocator` and Google Play services location; the additional permission is stated in COMPLIANCE and README (DECISIONS E.1). S16.8 implements the About statement and Android notices; S17.4 verifies them. No location-provider replacement is authorized. | Owner decision; documentation |

#### Stage 13 — Identity: Culmina

| Task | Objective | Depends on | Acceptance | V1 class |
| --- | --- | --- | --- | --- |
| **S13.1** | **Approved artwork and review evidence — R3-final** (completed; supersedes ID-5's original A + C brief) | ID-5 | (1) The owner's R3-final approval in DECISIONS E.1 is the authority: `evidence/identity/round5/R3-final-colour.svg` and `R3-final-monochrome.svg`; navy `#0B1230`, orbit-centred geometry. (2) Keep the adaptive-mask and small-size review evidence; no new concept round or artwork selection. (3) Final launcher/monochrome/device rendering belongs to S13.3. The earlier A + C/amber/red variants remain historical evidence, not the active brief. P9.4 remains: the owner chooses the mark. | Documentation and assets outside the app |
| **S13.2** | **Application id, name and URLs:** `io.github.buffur.culmina`, "Culmina", `AppIdentity` pointing at S12.3's live URLs; TD-088 and TD-093 closed. The id and the signing key become permanent at the first public GitHub release (updates need both unchanged) | S12.1, S12.3 (S12.2 recommended) | `RA_D_IDENTITY_TRANSITION.md` §3, criteria 1–10, including: (1) no old id left in code; (2) the metadata channel works on a device, M1 and M4; (3) backup and restore across ids on test packages, counts and fields equal; (4) the owner's migration path documented in the release notes and the runbook; (5) the restore confirmation shows the backup's date (TD-093); (6) trap 20, COMPLIANCE, RELEASE, README and the runbook updated | **High-risk:** full gate, device checks |
| **S13.3** | **Launcher icon and splash (S2)** | S13.1 (approved artwork), S13.2 | (1) R3-final in `ic_launcher_foreground.xml`, `tool/make_launcher_icons.py`, the separate monochrome layer, legacy PNGs and `icon_512.png` (trap 20). (2) Android 12+: the owner-approved 1,000 ms animation is held until played, then the mark fades on navy (120 ms) and the background fades into the app (150 ms); with animations off, no hold. The static icon remains before Android 12. This follows DECISIONS E.1's later amendment of ID-6. (3) Flutter shows the mark only while startup actually loads, static with reduced motion, no simulated progress or extra pre-frame work. (4) Record first-frame time **and time to visible app content** separately; the earlier 272/290 ms comparison is for the non-held variant and is not evidence of unchanged visible startup. (5) No new package. (6) Pre-12 and reduced-motion device behaviour remain UNVERIFIED until observed; carry their named rows into S17.1/S17.5 if not closed earlier, without reopening unrelated PASS evidence. Carrying a pending row does not mark it VERIFIED or waive a mandatory Stage criterion; any deferral uses the existing owner-decision rule. | Shared behaviour + platform assets: full gate; device measurement |

#### Stage 14 — Capture Plan completeness (round 2A)

| Task | Objective | Depends on | Acceptance | V1 class |
| --- | --- | --- | --- | --- |
| **S14.1** | **ADR-021 "Capture Plan completeness"**, the technical design of PD-05 to PD-14 and PD-21 | RA.D round 2A | The ADR records:<br>• the white-balance model;<br>• per-field value sources and their persistence;<br>• the storage evidence chain, with the **binning-in-storage rule and its vectors**, and whether a block's measured file size is persisted (readiness review C3, 2026-10-17);<br>• the metadata contract extension, with the tags and their provenance;<br>• the FITS keywords and limits;<br>• CAL-1's rules;<br>• O2b's axis and normalisation;<br>• the v26 schema design.<br>It names its amendments: ADR-009 §7/L6, ADR-017, ADR-018 D4, ADR-020 §2/§3/§5/§10, SI-013, CALC-16, CALC-42, and the superseded Stage 11 storage row. **The owner accepts the ADR** (the binning rule and the persistence choice are the technical points to confirm)<br>**Audit clarification:** Freeze one contract for the already approved metadata, per-field origins, storage and calibration paths before v26: field types/units/destinations and unsupported/conflict states; mode-scoped measured size and theoretical payload; calibration tuple matching versus proven duplicate coverage; O2b group comparability and zero-integration behaviour. ADR-021 lists, per required rig field, the calculations that need it and whether the editor or a photo can supply it; the editor shows that reason beside each required field (AUD-04; audit 09 M4 (d)). This amendment does not approve a partial-rig mode, nullable-rig migration, a spec service or a new equipment model; any change to ADR-011's required-input invariant must be explicitly decided when the owner accepts ADR-021. Legacy values without a source remain 'origin unrecorded'. Reuse existing services and the already approved FITS reader; no second metadata pipeline or new scientific model. AUD-02/04/05/06/16.<br>**Audit 09 (owner-approved 2026-10-17):** The ADR also records: (a) the FITS → rig mapping (XPIXSZ/YPIXSZ, FOCALLEN, TELESCOP) and its binning normalisation for binned and unbinned writers (CA-06, M5); (b) whether the length of a picked file whose format is recognised but not read (CR2, CR3, NEF, ARW, RAF, RW2, ORF, XISF, AVIF, PNG) is measured storage evidence (CA-07, M6); (c) CAL-1 filter identity: names compared after trimming and case folding, no alias guessing — `Ha` equals `HA`; `H-alpha` does not equal `Ha` and is reported, not merged (CA-03, M3); (d) the owner question **CA-OD3**: whether S14.3 adds 'Undo the last restore', and how many safety copies are kept. It is presented as a numbered decision sheet, one recommendation per point (CA-22). At S14.1's start the owner is asked for the FITS sample (an owner file or a licensed public fixture), so the gate is known before S14.4 (CA-15, M14). | Documentation |
| **S14.2** | **Camera class first (PD-07)** | S14.1 | (1) The rig editor asks the class first; "Not sure" is an explicit Unknown. (2) The example rig's class comes from its cited source, for new installs only, with the source cited in the seeder; existing rows are never reinterpreted. (3) The block form shows only the class's fields (ADR-020 §3). (4) Sweep and regression tests of the editor and the block form<br>**Audit clarification:** Verify the current manual and photo-assisted rig paths for a phone/JPEG, DSLR and astro camera: ask only fields required by the accepted existing calculations, explain what is missing, and never substitute example/guessed sensor values. Record any remaining required-spec barrier under AUD-04; implement a changed completeness rule only if explicitly accepted in S14.1. No separate equipment mode is added.<br>**Audit 09 (owner-approved 2026-10-17):** (5) Rig creation offers two labelled choices of equal weight wherever a rig is created — the rig list and its empty state, the 'Needs a rig' action of the planner and of Tonight, and onboarding (S16.1): 'From a photo' (the existing `/equipment/import` flow, unchanged; it says which files work: JPEG, HEIC and DNG, FITS after S14.5; a camera's native RAW is not read) and 'Enter by hand' (the editor). For Phone and DSLR/mirrorless the photo choice comes first; for Astro camera manual entry comes first until S14.5's FITS mapping exists. Test: a synthetic phone JPEG with FocalLength, FNumber, FocalLengthIn35mmFilm and pixel dimensions reaches a saved rig without any sensor value typed; the accessibility sweep covers the choices (CA-02, M2). | Shared behaviour |
| **S14.3** | **Schema v26 and safe activation of an existing backup** | S14.1 for items (1)–(6); items (7)–(9) depend on nothing and may be committed first, as their own commit within S14.3, once the owner starts S14.3; (9)'s Undo variant needs CA-OD3 (audit 09 M1) | (1) The columns ADR-021 defines, including: block white balance and value sources; camera-module capture format, bits per sample and compression, with provenance (wording: readiness review C3, 2026-10-17). (2) The `drift_schemas` snapshot, the generated steps, `from25To26` written against the step's shapes. (3) Additive snapshot keys; export manifest v2 additive (`EXPORT_MANIFEST.md`); backup by table. (4) Schema-equality and data-preservation tests; the pinned versions in `backup_restore_test` and `unsupported_database_test`. (5) DATA_MODEL updated<br>**Audit clarification:** (6) Preserve accepted block size/mode/source associations and all existing snapshots/results through v26, manifest and backup; no partial-rig schema change is implied. (7) Fix AUD-01 / TD-106 in the existing restore path: validate an isolated candidate through the production connection/migration path, integrity and expected schema/domain reads (and applicable foreign-key checks) **before** replacing the live database or preferences. (8) Failure leaves the original DB/preferences intact; interrupted activation has a deterministic recovery path. Tests include a valid ZIP with truncated SQLite, invalid expected schema, unsupported/newer version refusal and a successful old-schema restore. Never reset newer owner data. Rehearse the final path again in S17.5.<br>**Audit 09 (owner-approved 2026-10-17):** (9) The restore confirmation describes only recovery the user can perform and recommends 'Back up first' (the existing backup action) before restoring. It mentions the safety copy only if CA-OD3 adds 'Undo the last restore': the newest safety copy staged through the same validated path (7)–(8), with no archive-format change. CA-OD3 also sets how many safety copies are kept (CA-01, CA-23, M1). | **High-risk:** full gate, migration tests |
| **S14.4** | **Metadata contract extension** | S14.1 | (1) `CaptureMetadata` gains DNG BitsPerSample (258), Compression (259), AsShotNeutral, and EXIF WhiteBalance (41987) and LightSource (37384), each with tag provenance, through the existing readers. No second parser. (2) Synthetic fixtures. (3) The local real-sample test extended and passing. (4) The ADR-017 amendment applied<br>**Audit clarification:** Implement the **common contract already required by S14.5**, including types/units for its approved FITS keywords, without making every extracted field a new planning control. Preserve ISO kind; distinguish acquisition gain from physical conversion gain, X/Y binning from an unsupported asymmetric case, and actual sensor temperature from a setpoint. Define supported dimension/sample layouts for the storage calculation; unsupported/compressed layouts stay explicit. Synthetic and real fixtures cover absent, conflicting, invalid and out-of-range values. AUD-05/06. | **High-risk:** full gate, real-sample test |
| **S14.5** | **FITS header reader** | S14.1, S14.4 (common metadata contract); **at least one real astro-camera FITS file**, outside Git or a licensed public fixture (ADR-017 §9) | (1) Reads the mandatory keywords (SIMPLE, BITPIX, NAXIS, NAXISn), plus EXPTIME/EXPOSURE, GAIN, OFFSET, XBINNING/YBINNING, CCD-TEMP, FILTER, DATE-OBS and INSTRUME where present, and, for the rig, XPIXSZ and YPIXSZ (µm), FOCALLEN (mm, `softwareSetting` provenance, never "from the lens") and TELESCOP (identity evidence only) (audit 09 M5). (2) Bounded reads: 2,880-byte records up to END, with limits against untrusted input (as S2.V4). (3) Recognition becomes reading in the registry. (4) Tests: synthetic headers and the real-sample test. **If no sample exists when Stage 14's other Tasks are done, this Task blocks Stage 14's close**, and the owner is asked for a sample<br>**Audit clarification:** Use S14.4's typed contract and the existing registry; state the supported HDU/layout, keyword meanings and limits. Unsupported layouts need an honest outcome, not a new decoder. Cover END across record boundaries, read/axis/overflow limits, floating-point BITPIX, conflicting exposure tags, arbitrary FILTER and absent/asymmetric binning. The real-file gate stays. AUD-03/05/06.<br>**Audit 09 (owner-approved 2026-10-17):** (5) The equipment fields feed the existing EquipmentCandidate → match → review → Save path ('Add from a photo') under ADR-018: proposals with per-field provenance, nothing stored without Save, no new screen. Pixel size and dimensions are normalised for binning exactly once, by ADR-021's rule and vectors (binned and unbinned writers). Completes RG-03 Q1, "FITS remains the path for astro cameras" (CA-06, M5). | **High-risk:** full gate |
| **S14.6** | **Provenance of proposed and inherited values (PD-08)** | S14.2, S14.3 | (1) Every proposed or inherited field shows its origin until changed. (2) Value sources persisted per ADR-021. (3) The filter default follows the class. (4) RA-F05 (exposure kept after a type switch) verified, then fixed. (5) Widget tests<br>**Audit clarification:** Fix AUD-03 / TD-108: an unchanged edit preserves any domain-valid custom filter (including future FITS values), never coercing it to None. Sources stay associated with the intended fields through type switch, edit, reorder, delete/Undo, copy, save/reopen and snapshot/backup round trips; legacy origins are unrecorded. Cancel changes nothing. AUD-06.<br>**Audit 09 (owner-approved 2026-10-17):** (6) Record the planner's scroll extent at 412 px and 100 % text for a reference plan (three light blocks with a filter change, darks, flats and bias) before S14.2 and after each Stage 14 UI Task; each Task's record lists the growth per section, reviewed with its renders. The block editor is checked at 412 × 915, 200 % text and the keyboard open: every control reachable, the primary action reachable, no clipped label; the accessibility sweep opens it (TD-100). If an `AlertDialog` cannot meet this once S14.8 and S14.9 add their fields, the editor moves to the existing full-screen dialog pattern (CA-12, M11). | **High-risk (persisted provenance):** full gate; widget and round-trip tests |
| **S14.7** | **Storage evidence chain (PD-06)** | S14.3, S14.4 (S14.5 for FITS) | (1) Measured size from any readable format, for the rig, or for a block once S14.9 provides the block's file (readiness review C3, 2026-10-17). (2) A format-aware theoretical size only from evidence: an uncompressed DNG (Compression = 1 and its BitsPerSample), FITS BITPIX/NAXIS with its 2,880-byte records, or a format the user declares and confirms. (3) Unknown otherwise, with "pick one file". (4) Labels that name the source and the assumption. (5) Camera class never selects a branch. (6) Vectors S1–S4 and the compressed → Unknown boundary; the binning rule's vectors. (7) SI-013 and CALC-16 updated<br>**Audit clarification:** Scope measurement by format, dimensions/output mode, compression, binning and origin; explicitly reconfirm or invalidate incompatible evidence. A measured already-binned file is never scaled again. Separate theoretical pixel payload from exact container bytes; use only supported sample/axis layouts and relevant FITS padding. Unknown compression/layout stays Unknown. Tests include unbinned/already-binned measurements, changed modes, supported DNG layouts, integer/floating FITS and compressed/unsupported boundaries. No new format support or compression guesses. AUD-05.<br>**Audit 09 (owner-approved 2026-10-17):** (3a) A picked file whose format is recognised but not read (CR2, CR3, NEF, ARW, RAF, RW2, ORF, XISF, AVIF, PNG) is measured per-frame evidence only if ADR-021 accepts it. Then it is labelled 'measured from one <format> file; image mode not read; compressed RAW sizes vary with content' and never supplies dimensions, bit depth or compression. If ADR-021 rejects it, the storage note says why and points to the rig's manual size. Vector: a synthetic CR3 file's length → MB per frame (10⁶ bytes) (CA-07, M6). (4a) Values through `QuantityText`, in MB or GB by magnitude, decimal (10⁶ and 10⁹ bytes) and stated (TD-101; CA-18, M16). | **High-risk (scientific):** full gate |
| **S14.8** | **White-balance record (PD-09)** | S14.3, S14.6 | (1) Fields per class: Phone, DSLR/mirrorless, Unknown; hidden for astro cameras. (2) A proposal from a file: JPEG/HEIC give the mode only; a DNG's AsShotNeutral is stored as read, never converted to Kelvin. (3) Shown in the snapshot, the entry, the export and the share text. (4) Wording that it is recorded only and guarantees no identical colours<br>**Audit clarification:** Keep mode, DNG neutral vector and missing value distinct across record/export/backup round trips. WB is recorded only; it never changes the budget, exposure guidance or storage calculation. | Shared behaviour |
| **S14.9** | **"Take from a photo" in the light block (PD-11)** | S14.4, S14.6, S14.7, S14.8 (S14.5 for FITS; S14.7 and S14.8 added by readiness review C3, 2026-10-17) | (1) It reuses `CaptureFileAccess` and the reader registry, the path of "Add from a photo". (2) It proposes exposure, ISO with its kind, the white-balance mode, and the file's size and format evidence for S14.7, all with P2b markers, stored only by Save. (3) Exposure and ISO never touch the rig (ADR-018 §4). (4) A pixel count different from the rig's is flagged (SI-014). (5) TD-072's order-sensitive size conflicts are fixed on this path. (6) Device check with DNG, JPEG and HEIC ; FITS parts are conditional on S14.5 and do not block S14.9's acceptance or S14.13 (audit 09 M14)<br>**Audit clarification:** Preview only the approved fields applicable to the class, using S14.4/S14.5's types; document where FITS findings such as gain/binning/filter can be used and where they remain unsupported. No automatic extra control or silent conversion. Preserve custom filters and per-field sources. Cancel/read failure leaves the stored block/rig unchanged; repeated picks, mode/dimension conflicts and edited proposals have deterministic outcomes. AUD-03/05/06. | **High-risk (metadata):** full gate, device |
| **S14.10** | **"Build calibration from lights" (PD-12)** | S14.6 | (1) A preview before anything is added: a dark per distinct (exposure, sensitivity, binning) triple; a flat per compatible (filter, binning) requirement where binning applies; bias and dark flats offered by class. (2) No darks with in-camera noise reduction on. (3) No duplicate of a block with **proven coverage** of the required modelled settings; a permissive advisory match is not proof of coverage. (4) Counts are proposals. (5) Stored on confirmation; Undo (RD-09). (6) The budget reads the blocks unchanged (calibration never becomes integration). (7) Tests for each rule<br>**Audit clarification:** Fix AUD-02 / TD-107: warnings match the whole tuple, not independent filter/binning membership. Unknown sensitivity must not silently cover a known value for generation; show unresolved requirements in preview. Test lights Ha/bin1 + OIII/bin2 with flat Ha/bin2, unknown/known gain, class-hidden binning, distinct dark triples, library/timing policies, preview cancel and Undo after an intervening edit. Calibration remains planning advice, not full library certification; no new calibration subsystem.<br>**Audit 09 (owner-approved 2026-10-17):** Tests also cover case-only filter differences between lights and flats, and an imported FITS `FILTER` value, under S14.1's filter-identity rule (CA-03, M3). | **High-risk (matching and persistence):** full gate; budget regression |
| **S14.11** | **Relative improvement over integration time (PD-05)** | S14.1 | (1) CALC-42 plotted against T = N · t per group, normalised to the plan. (2) Never the word "SNR"; SI-003's help kept. (3) A text alternative. (4) Vectors R-O2 (0.5 → 0.7071, 1 → 1, 2 → 1.4142)<br>**Audit clarification:** Use ADR-021's comparability rule: split known incompatible gain/binning groups or explicitly describe the idealized grouping; unknown settings do not prove equivalence. Cover zero integration, mixed/unknown groups and an honest empty/text state. No absolute SNR or new exposure model. AUD-16. | **High-risk (scientific presentation):** full gate |
| **S14.12** | **Effective assumptions, fit guidance and focus (PD-14, PD-10, TD-074, K12)** | S14.7 | (1) The panel shows the assumptions that affect the result, with a "Change in Settings" link; the stale label fixed. (2) The focus reminder, with no value. (3) TD-074: "what fits" answers for every block the fit can evaluate, with wording only from `FitAnalyzer` outputs<br>**Audit clarification:** Missing inputs and unavailable derived results are explained without inventing rig specifications; retain valid block-derived results under the existing accepted model. No focus-position control or new assumptions system. | Shared behaviour |
| **S14.13** | **Remove the example-plan action (PD-13)** | S14.6, S14.9 and S14.10 accepted | (1) The action is gone from the UI; `ExampleCapturePlan` stays as a test fixture. (2) Tests that used `capturePlan.useExample` move to the replacement flows; the E2E updated | Shared behaviour |

#### Stage 15 — Night conditions (weather and Moon)

| Task | Objective | Depends on | Acceptance | V1 class |
| --- | --- | --- | --- | --- |
| **S15.1** | **ADR-022 "Night conditions"** | RA.D Q2, PD-16, PD-17, Q3 | The ADR records:<br>• MF-c: the Moon is up while its upper limb is above the horizon with standard refraction (h₀), everywhere — amending ADR-010, ADR-013 G4 and CALC-28/29/33/43;<br>• moon-free hours and their evening/morning/all-night classification;<br>• the phase name from the phase longitude;<br>• the 16-night request/cache and coverage, amending ADR-012 §4/§6 and **CALC-32** for S15.5's dark-span summary;<br>• the seeing/transparency statement and link;<br>• the monthly calendar's computation and cache.<br>Hand-computed vectors, including SI-015's synthetic case and a USNO-referenced case. **The owner accepts the ADR**<br>**Audit clarification:** Derive equivalence between geocentric h₀ and the topocentric predicate used by samples; define threshold equality/sampling limits, none/mixed/disjoint/no-dark Moon-free states, per-variable forecast coverage and partial-hour/dew-duration interpretation. Freeze cache/context inputs and browsing versus adopting a night for the existing plan. No new lunar model, weather provider or score. AUD-07/08/09. | Documentation |
| **S15.2** | **One Moon-up definition (MF-c)** | S15.1 | (1) The Moon-up predicate of CALC-29/33/43 and the Moon gate use h₀. (2) ADR-013's affected vectors re-derived independently and documented. (3) SI-015 resolved. (4) The batch-equals-single test kept (trap 2)<br>**Audit clarification:** Use a semantically equivalent predicate in the correct coordinate frame, not the same numeric geocentric h₀ copied beside topocentric altitude. Test rise/set, dark-time counting, gate, annotations and calendar consistently at the boundary, high latitudes and polar cases; preserve batch = single. AUD-07 / SI-015. | **High-risk (scientific):** full gate |
| **S15.3** | **Moon-free hours and phase** | S15.2 | (1) A new CALC: dark span ∩ Moon below h₀, classified evening ↘, morning ↗ or all night •. (2) The phase name. (3) Wording through `night_text`. (4) Vectors. (5) No fixed "good night" threshold<br>**Audit clarification:** Classify from the computed intervals, including none, mixed/disjoint and no-dark outcomes rather than forcing every case into evening/morning/all-night. Include boundary and polar vectors; never infer Moon-free duration from phase alone. AUD-07. | **High-risk:** full gate |
| **S15.4** | **16-night forecast overview** | S15.1 | (1) One Open-Meteo request per site covers the horizon; nights are slices. (2) The cache keyed per site; the freshness states unchanged. (3) Old cache entries migrated or dropped safely, with TD-049's legacy keys removed. (4) Offline and out-of-range behaviour kept. (5) The call budget recorded. (6) Privacy and COMPLIANCE wording in the same change (trap 22)<br>**Audit clarification:** The API horizon is up to 16 days, not a promise of 16 complete site nights. Slice returned UTC hours and retain per-variable coverage/lead time separately from retrieval age. Cache identity includes relevant coordinates, model, range/version; site edits and late responses cannot attach old data to a new context. Test first/last partial night, DST/date boundaries, missing variables, stale/offline and same-id coordinate changes. AUD-08. | **High-risk (persistence):** full gate |
| **S15.5** | **Weather details** | S15.4, S15.3 (moon-free hours) | (1) Per-night cards: cloud in the dark span, precipitation, wind and gusts, dew hours, Moon % and moon-free hours; values only, no verdict (ADR-012). (2) The hourly strip extended: cloud layers, gusts, humidity and dew point. (3) "Seeing and transparency are not forecast here" plus the Clear Outside link (Q3; privacy "links you open"). (4) Icons: Material first; a targeted set only if Material lacks the metaphor (licence and the full gate if a dependency)<br>**Audit clarification:** Amend/reuse `NightWeatherSummarizer` under CALC-32 for the named dark span; show actual coverage and partial/absent/no-dark states, never default clear or zero. Preserve instantaneous versus preceding-hour meanings and label the accepted partial-hour/dew-duration convention. No additional weather data/service is added. AUD-08.<br>**Audit 09 (owner-approved 2026-10-17):** (5) Each night of the overview states its lead time, 'forecast N days ahead', counted from the snapshot's time to the night's start (RA.R2c §4.2); no reliability score, colour or threshold. (6) Each per-night card leads with the dark-span cloud range and the Moon (moon-free hours); precipitation, wind and gusts, and dew hours are secondary text; checked at 412 px and 200 % text (CA-09, M8). | Shared behaviour (full gate if a dependency) |
| **S15.6** | **Night & Moon details** | S15.3 | (1) The monthly calendar: offline, in an isolate, cached per month, a week view at large text. (2) The combined night bar with a Moon layer and a legend; the text alternative; field-mode hatching. (3) Calendar timing on the phone is an acceptance check<br>**Audit clarification:** Cache by the relevant site/night-definition inputs and use the same Moon predicate as the details. Date/month browsing is read-only context until the user explicitly adopts it for the existing plan; adoption uses the existing Save/Discard/Cancel lifecycle, not a second plan store. Test browsing back, dirty/saved plans, site changes and restart with original snapshot/results intact. AUD-07/09. | Shared behaviour; device timing |

#### Stage 16 — Screens and flow

| Task | Objective | Depends on | Acceptance | V1 class |
| --- | --- | --- | --- | --- |
| **S16.1** | **Onboarding (PD-02) and the first-frame route (RA-B01)** | S14.2 | (1) The route is chosen before the first frame from the loaded first-run flag; no flash of Tonight. (2) One screen: site (GPS on tap, or choose) and "What do you shoot with?" (class → rig, through S14.2's two labelled choices; audit 09 M2), both optional; no target step; a large title; short texts that keep the permission rationale; "Start planning"; no Skip. (3) First-run tests and `core_loop_test` updated<br>**Audit clarification:** Observe the existing phone setup/manual/photo-assisted path and record remaining required-input barriers honestly (AUD-04). No onboarding data-model workaround or invented default is introduced. Include the applicable bounded workflow checks in the shared UI rule (AUD-10). | Shared behaviour (router): full gate |
| **S16.2** | **Home (PD-03, Q1)** | S15.3–S15.6 (night values and existing detail routes) | (1) The title row with field mode; no empty app bar. (2) The site and night as a compact, tappable subtitle. (3) The night card first: dark window, Moon phase and moon-free hours, cloud range with freshness, the values row, a link to the details. (4) Your plan with Open planner. (5) "What can I image tonight?" as a secondary action. (6) No New plan<br>**Audit clarification:** Distinguish browsing conditions from adopting site/night for the current plan; retain existing dirty-plan protections and one clear route back to Planner. No second plan context/store. AUD-09/10. | Shared behaviour |
| **S16.3** | **Planner hierarchy (PD-04, Q1, RA-F01–F03, TD-095)** | S14.12 | (1) The empty state is a checklist (site · target · rig · capture), each item leading to its choice. (2) Status once computable; one mention of the target. (3) The duplicated weather row removed; window cloud annotations kept; one link to Night & Moon and Weather. (4) The altitude chart compact. (5) TD-095: the autosave banner clears on a successful save<br>**Audit clarification:** Test empty/partial/saved/dirty/error states and consistent preview/adopt-night behaviour with Home/calendar. Cancel/back/browsing must not retime a saved plan or overwrite its result. Check what the screens state about fit, Unknown and relative gain through the shared rule's walkthrough, not through screenshots alone (audit 09 M4 (b)). AUD-09/10.<br>**Audit 09 (owner-approved 2026-10-17):** (6) The reference plan's scroll extent (S14.6 (6)) is recorded before and after S16.3 and reviewed with the renders (CA-12, M11). | Shared behaviour |
| **S16.4** | **Records (PD-19)** | — | (1) Progress by target as a Logbook segment. (2) RA-G03 verified, then a visible Delete for rigs and targets (RD-09). (3) Plan this target on the target row. (4) The stored night forecast in the entry. (5) RD-07's roles kept<br>**Audit clarification:** Validate multi-night reuse, record-result/reopen/progress, stored forecast age/source and visible Delete/Undo. Preserve the original snapshot/result when creating another plan. No new record type or live execution flow. AUD-09/10. | Shared behaviour |
| **S16.5** | **AstroBin acquisition CSV export (Q4)** | S14.3 (fields); S14.10 (whole-tuple matching for calibration counts; audit 09 M7) | (1) The current CSV contract read at the Task's start and cited, with the date. (2) A field mapping from the snapshot and the result: date, filter, number, duration, binning, gain/ISO and the rest the contract defines; unknown is empty, never 0. (3) Versioned in `EXPORT_MANIFEST.md`. (4) Exported through the existing share and export path. (5) Fixture tests<br>**Audit clarification:** Before mapping, document whether supported output represents a plan or recorded acquisition; define status, date/time basis, count/rejection source and grouping under the receiving contract. No invented timestamps/zero-for-unknown or unapproved export mode. Fixtures cover completed/partial/not-done/no-result/legacy/mixed-group data, escaping and multiple nights. Reuse existing share/export plumbing. AUD-11.<br>**Audit 09 (owner-approved 2026-10-17):** `filter` holds AstroBin's numeric equipment-database ID (AstroBin, 'Importing acquisitions from CSV', read 2026-10-17). Culmina stores names only, so the column stays empty (never a name, which AstroBin ignores without an error), and each filter's lights stay separate rows, listed with their filter names, in row order, in the export's share text. Calibration counts (`darks`, `flats`, `flatDarks`, `bias`) are attached to a light row only through S14.10's whole-tuple matching, otherwise empty. No AstroBin ID entry, lookup or stored mapping is added (CA-08, M7). | **High-risk (export format):** full gate |
| **S16.6** | **Settings (PD-20)** | CA-OD1 (owner decision, audit 09 M9) | (1) Appearance: System, Light or Dark, persisted and backed up. (2) A units preference: temperature °C/°F, wind km/h, mph or m/s, elevation m/ft, through `QuantityText` everywhere. (3) New keys join `BackupPreferences` (trap 5)<br>**Audit clarification:** Choose a compatible persisted enum encoding or extend the existing serializer explicitly: an allowlisted key alone does not carry a string value through bool/int/double-only `BackupPreferences`. Test values/old-backup defaults/unknown future values through restore. Keep canonical scientific units internally; test absolute versus difference °C/°F conversions, dew margins, wind/elevation and all display/share paths. AUD-12. | Shared behaviour across screens: **full gate** |
| **S16.8** | **Existing defects and bounded follow-ups** | S16.1–S16.6 (affected existing flows) | Fix:<br>• TD-094 (restore the open screen after a process death);<br>• TD-096 (wall-clock tests);<br>• TD-097 (`municipality`);<br>• TD-098 (Android notices on the licence page);<br>• TD-102 (probes become tests);<br>• TD-103 (`AppLog`);<br>• TD-038 (`unawaited_futures`);<br>• S12.4 (a), already chosen: the About statement (C4);<br>• TD-105: truthful backup-version wording and singular/plural count, without adding an archive field for this cosmetic fix.<br>Re-check and close or update TD-002, TD-020, TD-025 and TD-031 against the code (TD-002 added by readiness review C6). TD-045 (Drift renames) is **excluded**: the documented workaround has no user impact<br>**Audit clarification:** Use a finite per-item checklist with affected files, acceptance, risk class and focused verification; UI/router/notice work finishes before S16.7. Preserve the original purpose of each debt item; no general refactoring/new functionality. AUD-13/14. | Per item; full gate at the end |
| **S16.7** | **Consistency and accessibility (K14, TD-100, TD-101)** | S16.1–S16.6 **and S16.8** (final sweep follows shared UI/router/notice fixes) | (1) The sweep covers the editors, the filter panel, the map picker and every new screen (TD-100). (2) A source test enforces `QuantityText` (TD-101). (3) The owner's final visual review of all changed screens<br>**Audit clarification:** Apply CA-OD1 (audit 09 M9): either (A) the UI keeps its neutral tokens and the mark appears in the icon, the splash and About only; or (B) the token changes listed in DESIGN_SYSTEM, each with its AA contrast vector. Field mode is unchanged in both cases. Render review proves visual acceptance only; separately record bounded observed workflow evidence per the shared rule. Repeat affected rows if later changes invalidate them (V3). AUD-10/13. | Shared behaviour: full gate |

#### Stage 17 — Final validation and GitHub release (folds in S11.6 and S11.7)

| Task | Objective | Depends on | Acceptance | V1 class |
| --- | --- | --- | --- | --- |
| **S17.1** | **Re-baseline the validation matrix** | Stages 12–16 closed | (1) Rows from `STAGE_11_MATRIX.md` whose inputs changed are marked for re-run (V3); unchanged rows keep PASS with a one-line reuse record. (2) New rows for every Stage 12–16 acceptance and RA.D decision. (3) Frozen before evidence (V4)<br>Include the applied audit criteria and all named pending device rows before freezing. Mark implemented, verified, unverified and deferred separately; do not retrospectively reopen unrelated accepted work. AUD-01–AUD-16 dispositions are in `STAGES_12_17_AUDIT_AMENDMENTS.md`. | Documentation |
| **S17.2** | **Host evidence on the accepted pre-packaging baseline** | S17.1 | The full gate and host rows on the accepted Stage 12–16 inputs; the corresponding green remote CI result. This establishes the pre-packaging baseline, not the final release artifact. S17.6 covers its later version/tooling inputs with the gate/remote CI required by C1 and V3. AUD-15. | Full gate |
| **S17.3** | **Emulator evidence** | S17.1 | The invalidated emulator rows re-run: lifecycle L1–L6 and L8, the backup round trip, permissions, offline, the release build | Runtime |
| **S17.4** | **Providers and compliance** | S17.1 | Live Open-Meteo (the 16-night request), Nominatim (opt-in), OSM tiles, the opened links, About's pages; COMPLIANCE and the policy against the code (Play's Data Safety form **deferred**, store distribution); the licences (TD-098 done); S12.4 reflected | Documentation, runtime |
| **S17.5** | **Phone runs** (the runbook updated for Culmina) | S17.1, **S17.6** (the signed release candidate; readiness review C1, 2026-10-17), the phone | Run on the signed release-candidate APK from S17.6 (C1). The core loop (L10); TalkBack (H6, H7); field mode in darkness; perf M3, M4 and the new heavy screens (calendar, overview); metadata (Add and Take from a photo; DNG, JPEG, HEIC, FITS); CAL-1; S2V-06 and S3V-08; lifecycle on the phone; **the signed release APK from S17.6 installed from its release artifact, and installed as an update over the previous public build when one exists (same id and key; data kept)** (N5, amended GitHub-only distribution, 2026-10-17); the cold start and splash; **the identity migration rehearsal on the release candidate: a backup from the old-id build at its shipped schema restored into the new-id build on test packages, counts and fields equal (`RA_D_IDENTITY_TRANSITION.md` §3, criteria 4–6), before the owner's data step** (readiness review C2, 2026-10-17). **Last, (owner):** the owner's data moved from the old app by backup and restore (transition §3, item 5; moved here from S17.6 by C1)<br>**Audit clarification:** Record the SHA-256 of the **actual checked APK**. The isolated cross-id/old-schema → final-schema seed includes aliases, rig/block origins and values, saved forecast/snapshot, completed/partial/not-done results, supported legacy events and preferences; compare contents plus derived UI. Rehearse corrupt-candidate refusal/original-data preservation before owner migration. Complete pending pre-12/reduced-motion and user-visible splash evidence without substituting first-frame timing. No test-package rebuild substitutes for production artifact checks. AUD-01/10/14/15.<br>**Audit 09 (owner-approved 2026-10-17):** Also: (a) follow the restore confirmation's instruction literally on the phone, including returning from Recents: the staged restore is applied, or S14.3's instruction text is corrected (CA-16, M1); (b) 'Add from a photo' with the FITS sample: the rig is reviewed and saved (M5); (c) for the first public release, when no earlier public build exists: install a release-signed build with a lower versionCode from the same key, create data, then install the release candidate over it; the update is accepted and the data kept. Later releases use the previous public build (CA-14, M13); (d) the carried Stage 13 rows: reduced motion (S13V-02) and the final build's first-frame and visible-content times (S13V-03) (`STAGE_12_13_CLOSURE.md`). | Device; owner action |
| **S17.6** | **GitHub release packaging** (amended GitHub-only distribution, 2026-10-17) | S17.1–S17.4 (C1; packaging precedes phone runs) | (1) **(Owner)** the release keystore created and backed up by the owner, never in the repository (trap 21); losing it makes later updates impossible. (2) A signed release APK built from the release commit (`flutter build apk --release`; a universal APK, split per ABI only if the owner asks). (3) A release check replacing `check_bundle` for APKs: signed with the release key, never the debug key (`apksigner verify --print-certs`); `versionName` equals `pubspec.yaml`'s X.Y.Z and `AppIdentity.version`; `versionCode` greater than the previous release's; the application id; min and target SDK; 16 KB page alignment of native libraries. (4) `RELEASE.md` rewritten for GitHub: semantic versions and the tag `vX.Y.Z` matching the `pubspec.yaml` `X.Y.Z+N`; the artifact name `culmina-X.Y.Z.apk`; a `SHA256SUMS` file; the signing certificate's SHA-256 fingerprint published for verification; a release-notes template (changes, known issues, data notes); installation instructions (allow installs from this source; verify the checksum and the fingerprint); update instructions (install over the existing app; on a signature mismatch: back up, uninstall, reinstall, restore); the migration from the old id (`RA_D_IDENTITY_TRANSITION.md` §3). (5) The policy live (S12.3). (6) A green remote CI run on the release commit, read from GitHub (the release version and the APK check are in it); any later application change rebuilds the APK and re-runs the affected rows (V3). *(Readiness review C1, 2026-10-17: item (6) was "the owner's data moved from the old app", now the last step of S17.5.)* **Deferred (store distribution):** the upload key for Play and Play App Signing, the AAB and `check_bundle` as a release requirement, the Data Safety form, the store listing (16.5), the Play closed test with at least 12 testers for 14 days (Q2)<br>**Audit clarification:** A fail-closed packaging/check path verifies the **expected owner certificate fingerprint**, not merely a non-debug signature, and refuses absent/debug/wrong signing. Native Android compilation and relevant Kotlin tests pass; record commit/toolchain/id/version and APK SHA-256. Public CI needs no private signing key. Record actual universal APK size; optional ABI variants remain owner-requested only. Any rebuilt/changed APK invalidates affected S17.5 evidence. AUD-15; AUD-17 adds no work.<br>**Audit 09 (owner-approved 2026-10-17):** Before packaging, record from the release commit the download and installed sizes of the universal APK and of the arm64-v8a APK; the owner chooses with these numbers (**CA-OD2**): universal only, or arm64-v8a as the main download plus universal. Every published APK passes (3) and is listed in `SHA256SUMS`. Stage 10's D10-3 premise (Play's per-ABI delivery) is recorded as superseded by GitHub-only distribution (CA-13, M12). | Release tooling (`tool/`) is **high-risk**: full gate; packaging documents; owner actions |
| **S17.7** | **Readiness record and go/no-go** (fresh session) | S17.2–S17.6 | VERIFIED, UNVERIFIED, OWNER ACTION and DEFERRED; readiness claimed only when every mandatory row is VERIFIED; the store-only rows recorded as DEFERRED (store distribution), never as passed; the owner's go/no-go recorded | Documentation |
| **S17.8** | **(Owner) publish the GitHub Release** (added GitHub-only distribution, 2026-10-17) | S17.7 "go" | (1) The tag `vX.Y.Z` on the release commit. (2) The release with the signed APK, `SHA256SUMS`, the certificate fingerprint and the notes from S17.6's template. (3) The published APK downloaded from the release page, its checksum verified, installed on the phone, and the core loop run once. (4) The README's install link. (5) Recorded in PROGRESS<br>**Audit clarification:** The published download's hash equals the artifact tested in S17.5 and its certificate matches the expected signer. Rebuilds or application changes require affected checks again (V3). AUD-15. | Owner action; device check |

#### Starting Task

**S12.1 — TD-104, remote CI green.** *Done 2026-10-17 (`461e38c`; the remote run 39020770255 passed).*

**Historical sequence (after audit 09 and the Stage 12–13 closure, 2026-10-17):** **Stage 12 closed** (bounded closure PASS at `570581e`; S12.2 optional, not performed). **Stage 13 blocked** at its closure on S13V-01 / TD-109: the splash before Android 12 cannot draw its icon on Android 8–11. The owner chooses a corrective S13.V1 (recommended) or carrying it to S16.8 and S17.5. Reduced motion (S13V-02) and the final cold-start numbers (S13V-03) are carried to S17.5. Then S14.1 (ADR-021) on the owner's start instruction, with the FITS-sample request.

*Earlier:* **Current sequence (reconciled 2026-10-17):** S12.1, S12.3, S12.4, S13.1 and S13.2 are recorded done; S12.2 remains optional. S13.3 is implemented at `570581e`, with pre-12/reduced-motion device rows still UNVERIFIED. Reconcile/validate the Stage 12–13 closure record against that evidence; do not restart email, naming or logo research. Then S14.1 on the owner's start instruction. This documentation amendment starts no application Task.

#### Traceability (every RA.R1 finding)

| Findings | Planned in | Disposition |
| --- | --- | --- |
| RA-A01, A05, A07, A08, A09; K14 | S16.7, every UI Task's shared rule; S17.5 | Owner render review is visual acceptance; bounded observed workflows are separate usability evidence. No independent-participant PASS is invented (AUD-10) |
| RA-A02, A03, F10; K5 | S14.11 | O2b; absolute SNR excluded (DECISIONS: PD-05) |
| RA-A04; K6 | S14.3, S14.4, S14.5, S14.7 | The storage evidence chain |
| RA-A06; K4 | S16.2, S16.3 (Q1: keep, demoted) | — |
| RA-A10, I01 | This roadmap | — |
| RA-B01–B06 | S16.1 (B01 the route; B02 no Skip; B03 the title; B04 site and class; B05 texts; B06 the owner's review) | — |
| RA-C01 | S12.2, S13.2 | — |
| RA-C02 | S13.1, S13.3 | — |
| RA-C03, C04 | S13.3 (splash); S15.5 (icons) | RA-C04's small animations: within `AppMotion` per UI Task (reduced motion honoured); no separate Task (readiness review C6, 2026-10-17) |
| RA-D01–D06; K9 | S16.2 (D04: New plan removed; D06: the candidates demoted) | — |
| RA-E01 | S15.1, S15.2, S15.3, S15.6 | — |
| RA-E02, E03, E04 | S15.4, S15.5 | Seeing and transparency: no provider (Q3), a link |
| RA-E05 | Invariant in S15.4, S15.5 | — |
| RA-E06 | S16.4 | — |
| RA-F01–F03 | S16.3 | — |
| RA-F04; K8 | S14.13 | — |
| RA-F05 | S14.6 | — |
| RA-F06 | S14.2, S16.1 | — |
| RA-F07; K7 | S14.4, S14.8, S14.9, S14.12 | WB recorded; focus reminder; no focus value (F3 excluded, no evidence) |
| RA-F08 | S14.10 | — |
| RA-F09; K12 | S14.12 | — |
| RA-F11 | S14.1 (ADR-021 records the scope: records, not device control) | — |
| RA-G01, G02, G04 | S16.4 | — |
| RA-G03; K11 | S16.4 | — |
| RA-G05 | S17.5 | — |
| RA-H01–H03 | S16.6; PD-21 (I1) | RA-H03's language: localisation stays deferred (`PRODUCT_DIRECTION.md` §8; readiness review C6, 2026-10-17) |
| RA-I02; K3 | S12.1 | — |
| RA-I03 | S12.2 (recommended), S12.3, S12.4, S17.6, S17.8 | Store items deferred (GitHub-only distribution) |
| RA-I04; K10 | S12.2, S13.1–S13.3; licence: GPL-3.0 stays (RG-12, owner deferral) | — |
| RA-I05 | Stage order 12 → 17; S17.1 | — |
| K1, K2 | Closed (`333e1e8`) | — |
| K13 | Historical record; not rewritten | — |

Open technical-debt items:
- Resolved foundation items, retained for traceability: TD-104 → S12.1; TD-099 → published S12.3 policy; TD-088 and TD-093 → S13.2.
- TD-106 (AUD-01, invalid restore activation) → S14.3 and S17.5; TD-107 (AUD-02, flat tuple warning) → S14.10; TD-108 (AUD-03, custom filter loss) → S14.6;
- TD-072 → S14.9;
- TD-074 → S14.12;
- TD-049 → S15.4;
- TD-095 → S16.3;
- TD-100, TD-101 → S16.7;
- TD-094, TD-096, TD-097, TD-098, TD-102, TD-103, TD-105, TD-038, TD-002, TD-020, TD-025, TD-031 → S16.8 (TD-002 and TD-099 added by readiness review C6, 2026-10-17);
- TD-045 excluded (S16.8).
- Carried device items S2V-06 and S3V-08 → S17.5.
- RD-02's remaining holdovers (an ADK skill, `skills-lock.json`, `docs/archive/`) stay owner housekeeping, outside the release.

#### Independent audit disposition (2026-10-17)

The [integration record](STAGES_12_17_AUDIT_AMENDMENTS.md) maps AUD-01–AUD-17 to the existing Tasks and preserves the distinction between defects, future contract risks and proposals. No finding is marked fixed by this plan edit.

| Audit findings | Existing Tasks | Scope |
| --- | --- | --- |
| AUD-01 / TD-106 | S14.3, S17.5 | Validate and safely activate the existing backup restore |
| AUD-02 / TD-107; AUD-03 / TD-108 | S14.10; S14.6, S14.5/S14.9 | Correct calibration tuples and preserve valid filters |
| AUD-04 | S14.1/S14.2, S16.1 | Review existing required-input barrier; a new partial-rig model is **not approved** |
| AUD-05, AUD-06, AUD-16 | S14.1, S14.3–S14.9, S14.11 | Complete the already approved metadata/storage/provenance/relative-graph contracts |
| AUD-07 (SI-015), AUD-08 | S15.1–S15.6 | Consistent Moon predicates and honest forecast interval/coverage |
| AUD-09, AUD-10 | S15.6, S16.1–S16.4/S16.7, S17.5 | Existing plan lifecycle and observed workflow acceptance |
| AUD-11, AUD-12 | S16.5, S16.6 | Existing export source semantics and preference-value restore |
| AUD-13, AUD-14 | S16.8 → S16.7; current records/S13.3 | Correct ordering, bounded debt checklist and superseded status/timing |
| AUD-15 | S17.2, S17.5/S17.6/S17.8 | Native build, expected signer and one tested APK artifact |
| AUD-17 | Existing optional S17.6 clause only | No new APK variant or distribution task |

#### Comprehensive audit 09 disposition (2026-10-17)

[`audit/09_COMPREHENSIVE_AUDIT.md`](../audit/09_COMPREHENSIVE_AUDIT.md) §G–§H, applied at the owner's instruction. "Applied" means written into the Task; nothing is implemented.

| Finding | Amendment | Tasks |
| --- | --- | --- |
| CA-01 (TD-106 order, truthful recovery wording), CA-16, CA-23 | M1 | S14.3, S17.5; CA-OD3 at S14.1 |
| CA-02 (photo-first rig path) | M2 | S14.2, S16.1 |
| CA-03 (filter identity) | M3 | S14.1, S14.10 |
| CA-04 (TD-108, RA-F05, filter default) | None (already covered) | S14.6 |
| CA-05 (testable wording) | M4 | Shared UI rule, S14.1, S16.3, S16.7 |
| CA-06 (FITS → rig, RG-03 Q1) | M5 | S14.1, S14.5, S17.5 |
| CA-07 (unread RAW as storage evidence) | M6 | S14.1, S14.7 |
| CA-08 (AstroBin numeric filter IDs) | M7 | S16.5 |
| CA-09 (lead time, card hierarchy) | M8 | S15.5 |
| CA-10 (brand in the UI tokens) | M9 (CA-OD1) | S16.6, S16.7 |
| CA-11 (faithful review renders) | M10 | Shared UI rule |
| CA-12 (density, editor form factor) | M11 | S14.6, S16.3 |
| CA-13 (APK size decision) | M12 (CA-OD2) | S17.6 |
| CA-14 (first-release update path) | M13 | S17.5 |
| CA-15 (FITS-sample gate) | M14 | S14.1, S14.9, shared start rule |
| CA-17 (registers) | M15 | TECH_DEBT, PROGRESS (applied) |
| CA-18 (storage display) | M16 | S14.7 |
| CA-19, CA-20, CA-21, CA-22, CA-24 | Optional (P3); CA-22 written into S14.1 | — |
| S13V-01 / TD-109 (pre-12 splash) | Owner choice: S13.V1, or carry to S16.8 and S17.5 | Stage 13 closure |
| S13V-02, S13V-03 | Carried | S17.5 |

---

## 6. Traceability: audit findings → Stages

Moved verbatim to [`POST_ROADMAP_PLAN_HISTORY.md`, §6](POST_ROADMAP_PLAN_HISTORY.md#6-traceability-audit-findings--stages): the Final Audit (07) and
counter-audit (06) findings mapped to Stages 1–11. The traceability of the Stage 12–17 work (RA.R1
findings, open TD items, the AUD and CA findings) is inside §5 above.

---

## 7. Research gate register (RG)

A gate follows the research workflow (§9.6). Research sessions do not modify production code.
Each gate ends in an owner decision, plus an ADR or specification where one is needed, before
any implementation Task is created.

| ID | Question | Evidence and reason | Stage | Constraints |
| --- | --- | --- | --- | --- |
| RG-01 | **DECIDED 2026-09-26 (S2.R1; ADR-017; DECISIONS E.1).** Which metadata formats are supported, with which libraries and which file-selection path, verified on which real samples? (Resolves PD-21) | TD-018, F-45; MASTER_ROADMAP 17.1–17.2; Stage 0 prompt §7 | 2 (entry) | Header-only, bounded reads; I/O in the data layer; library licences; owner samples only |
| RG-02 | Which metadata identifies the camera, device and optics reliably; what cannot be derived; how are candidates matched to existing equipment, with provenance, confidence and conflict rules? | 08 §11; Stage 0 prompt §7 and §11 | 3 (entry) | No silent writes; unknown stays unknown; ADR-011, ADR-008 §6. **Decided 2026-09-26 (S3.D, ADR-018)** after S3.R1 (`research/RG-02_EQUIPMENT_IDENTITY.md`) |
| RG-03 | Is a sourced catalog of equipment specifications needed, and which source is acceptable (licence, provenance, offline size) under the verified-seed policy? | 08 §11 ("only ZWO"; from the device name or links); UX-22; 05 R13/P8; TASK 8.5 | 3 (informs 7) | No scraping; "reported" provenance; licence terms. **Deferred by the owner 2026-09-26 (S3.D, D2; ADR-018 §8)**. *2026-09-28 (Stage 7 planning):* researched again as **S7.R5**, at the owner's request in the Stage 7 prompt (`prompts/STAGE_7_PLANNING.md` §3); the research adopts nothing, and adoption stays the owner's decision; it blocks only S7.6's source path. *2026-09-29:* S7.R5 done (`research/RG-03_EQUIPMENT_SPECS.md`; one owner question, §8). **Decided 2026-09-29: Q1** (no source; lensfun crop factors the candidate with RG-12 in Stage 9; DECISIONS E.1, "RG-03 decided") |
| RG-04 | **DECIDED 2026-09-27 (S4.R2; DECISIONS E.1): B, the Logbook first and the tracker optional; G2 results after the session.** *Its optional tracker is superseded (owner, 2026-09-27; E.1, "Stages 6–11 amended after Stage 5"): the tracker leaves the target product, and P8.4 retires it.* What role should Execution play (primary, optional, simplified or post-session only), and how are actuals captured without frame-by-frame reporting? | 08 §3, §19, §24; UX-25, UX-27; ADR-016; CALC-37 and CALC-38 | 4 | Keep data and event history; nothing removed before the decision; Android constraints (ADR-016) |
| RG-05 | **DECIDED 2026-09-27 (S4.R4; DECISIONS E.1): Tonight plan-first with a site · night context line; Night & Moon and Weather detail screens; no new tab.** How should Home/Tonight be ordered, where should the Night, Moon and Weather drill-downs lead, and is a separate "Analytics" destination warranted? | 08 §2; UX-10, UX-11; 05 P1/P4 | 4 | PD-14 (no customisable dashboard); no score |
| RG-06 | **DECIDED 2026-09-27 (S4.R4; DECISIONS E.1): progressive disclosure (one tap away, factual summaries); no modes, no density preference for now.** Are separate Basic/Advanced modes needed, or does progressive disclosure suffice? | 05 P6/P7 and §8 decision 1; 07 §10; Stage 0 prompt §8 | 4 | Integrity text reachable in every mode; experts keep access |
| RG-07 | How should the target catalog expand and search improve: sources and licences, common names, cross-identifiers, size on the device, suggestions; an offline catalog or an online name resolver? | 08 §4, §9 | 7 | Offline-first; CC BY-SA handling; the catalog is generated by `tool/build_catalog.dart` and versioned, never hand-edited, and deleted targets must not come back; no scraping. *2026-09-27:* the goal is that choosing a known object never requires looking up RA and Dec elsewhere; custom entry stays where it serves a real case; a large expansion is not assumed approved; no moving objects (ADR-010 §3); no unsourced object data. *2026-09-28 (Stage 7 planning):* researched by **S7.R3**; blocks S7.4. *2026-09-29:* S7.R3 done (`research/RG-07_TARGET_CATALOG.md`); the owner's three questions are its §9. **Decided 2026-09-29 (DECISIONS E.1, "RG-07 decided"):** T1 only (aliases from the pinned OpenNGC, normalised search; no new objects, no online lookup) |
| RG-08 | Should elevation be retrieved automatically (source, accuracy, licence, privacy), made optional, or dropped, given that no calculation uses it? | 08 §6; SCI-08; UX-21; F-07 | 7 | Unknown is not 0; privacy (a position leaves the device). *2026-09-27:* no automatic source is claimed before one is found reliable; no prominence while no calculation uses elevation. *2026-09-28 (Stage 7 planning):* researched by **S7.R4** (with RG-09); blocks S7.5's elevation. *2026-09-29:* S7.R4 done (`research/RG-08_09_SITE_AUTOMATION.md`, §8 questions). **Decided 2026-09-29 (E.1, "RG-08 and RG-09 decided"):** E2, optional and Unknown by default |
| RG-09 | Can Bortle or SQM be obtained reliably (a dataset or API; the uncertainty of conversions)? Does SQM need to be a user field at all? Should the external map move to lightpollutionmap.app? | 08 §6, §13; PD-05 options C and D (deferred); SI-007 | 7 | No scraping; no Bortle↔SQM conversion without a cited source; secrets outside the code (PD-05 D); privacy and compliance documents updated. *2026-09-27:* no Bortle inferred from coordinates; SQM's purpose settled before it is shown; another map link or an embed only through this gate (Stage 9 presents the result). *2026-09-28 (Stage 7 planning):* researched by **S7.R4** (with RG-08); blocks S7.5's sky darkness and link. *2026-09-29:* S7.R4 done (`research/RG-08_09_SITE_AUTOMATION.md`, §8 questions). **Decided 2026-09-29 (E.1):** S3 (manual, optional, one collapsed section; no automatic source) and M2 (lightpollutionmap.app) |
| RG-10 | How do manual imagers actually take darks, flats, bias frames and dark flats; what can inherit from the light frames; how can it be explained briefly, with tips that can be dismissed? | 08 §16; ADR-009 §3; F-39 | 7 | ADR-009's budget semantics stand unless the owner amends them. *2026-09-27:* each workflow separately and per supported camera class, from primary or technical sources. The output is Stage 7's parameter matrix (inherited · prefilled and overridable · independent · not applicable, with the budget effect), before any form changes. No flat-exposure or target-ADU guidance unless separately approved; a hidden tip never hides a warning. *2026-09-28 (Stage 7 planning):* researched by **S7.R2**, after RG-11's decision; recorded in ADR-020 (S7.D); blocks S7.3. *2026-09-29:* S7.R2 done (`research/RG-10_CALIBRATION_WORKFLOWS.md`); the owner's six questions are its §10. **Decided 2026-09-29 (DECISIONS E.1, "RG-10 decided"; ADR-020):** L1, D1, T0, O0, N1, H1 |
| RG-11 | Which capture parameters matter for each camera type (ISO or gain, binning, white balance, focus, interval); which feed a calculation and which are records only; how are they labelled? | 08 §15; SI-004; SCI-05 | 7 | ISO or gain is never "sensitivity"; no camera control; descriptive fields stay descriptive unless a formula is documented. *2026-09-27:* each light input classed (required · optional · known automatically · context-dependent · not applicable); focus's meaning settled before any control is chosen (a slider is only a proposal); the interval reconciled with ADR-009's per-frame overhead, never counted twice; FACT, OWNER PREFERENCE and IMPLEMENTATION OPTION kept apart. *2026-09-28 (Stage 7 planning):* researched by **S7.R1**; recorded in ADR-020 (S7.D); blocks S7.R2 and S7.2. *2026-09-29:* S7.R1 done (`research/RG-11_CAPTURE_PARAMETERS.md`); the owner's six questions are its §11. **Decided 2026-09-29 (DECISIONS E.1, "RG-11 decided"):** C1 (a camera class on the rig; the example rig stays Unknown), B1, W1, F1, I1, P2 |
| RG-12 | *Planned 2026-09-29: S9.11 prepares the research; the owner decides; P9.5 implements. Deferred by the owner 2026-09-30 (GPL-3.0 stays until a decision).* Does GPL-3.0 meet the owner's new requirements (free; no monetisation; no modification without the author's permission)? If not, which licence would, and what follows for the bundled CC BY-SA 4.0 data, the dependencies' licences, the store listing and copies already shared? | 08 §23; PD-12 (GPL-3.0 confirmed 2026-09-24); TASK 16.3 | 9 | A dedicated legal/licensing research decision; no change before the owner decides; not legal advice. *2026-09-27:* the steps: the current licence and distribution; its permissions and obligations against the owner's intent; the incompatibilities; approaches from authoritative licensing sources; the consequences for source availability, redistribution, modification, commercial use, the dependencies' and data licences, and store distribution; alternatives for the owner. No licence chosen from memory and no custom licence text; P9.5 implements the decision |
| RG-13 | Which settings match real amateur and professional needs, are they understandable, and does each belong in Settings or in context? *Planned 2026-09-29: S9.3 (research), built by S9.4.* **Answered 2026-09-29 (S9.3; `research/S9.3_SETTINGS.md`; E.1, D9-3).** | 08 §18; TD-050 | 9 | Thresholds stay configurable; no score. *2026-09-27:* every visible setting classed as in P9.3; astrophotography facts from reliable sources, not anecdote; the owner is asked only for real product choices |
| RG-14 | **DECIDED 2026-09-26 (DECISIONS E.1):** none in Stage 2; per-format adapters afterwards, only with samples; `ExifInterface` and LibRaw rejected. Proprietary RAW (CR2/CR3, NEF, ARW, RAF, RW2, ORF): which formats matter, whether their EXIF values are reachable in a bounded way, and which library or platform facility (if any) meets ADR-017 instead of ad hoc parsers? | Owner, 2026-09-26 (DECISIONS E.1, "Stage 2 format priorities"); `STAGE_2_ARCHITECTURE_REVIEW.md` | 2 (S2.R3) | No ad hoc parsers; bounded I/O; privacy exclusions; licence against GPL-3.0; no image decoding |

---

## 8. Owner decision register (RD)

| ID | Decision | Evidence and known options | Stage | Blocks |
| --- | --- | --- | --- | --- |
| RD-01 | **DECIDED 2026-10-17 (RA.D ID-2 = B, `Buffur`; DECISIONS E.1, "RA.D — round 1 identity"); implemented by S13.2 (`b29ec34`: `io.github.buffur.culmina`, the `Buffur/Culmina` URLs; TD-088 resolved).** *Planned 2026-09-29: S9.12 prepares the options; the owner decides. Deferred by the owner 2026-09-30 (still required before any store upload; TD-088).* Which GitHub account carries the project identity: `chacha12` (the application id `io.github.chacha12.astroplanner`, the `AppIdentity` source and policy URLs, the user agent, the git user) or `Buffur` (the remote `github.com/Buffur/Astro-Planner`; the owner's links in 08 §23)? | OD-07 asked for confirmation before the first upload; the application id is permanent once published | Before any store upload; before Stage 9's About and links | Upload; privacy-policy URL; About links; the CI remote. *2026-09-27:* the author's own profile links (08 §23) do not wait for it |
| RD-02 | The TASK 0.3 holdovers: the Google ADK skill and `skills-lock.json`; retaining `docs/archive/`; `sqlite3_flutter_libs ^0.6.0+eol` *(the dependency part decided and removed by S10.6, 2026-09-30, under the owner's delegation, D10-5; the other parts stay open)* | 01 TASK 0.3; `TECH_DEBT.md`'s cleanup list | 1 (hygiene); 10 (the dependency, with a device check) | — |
| RD-03 | **RESOLVED 2026-09-25 (Stage 1 planning; DECISIONS E.1).** SCI-05: neutral label "ISO / gain (for your records)" now (S1.8). SCI-04: documentation only (S1.13). *(Was: wording rulings: the ISO/gain "Sensitivity setting" label (SCI-05); a resolution caveat for times on the 5-minute grid (SCI-04).)* | 07 §6 item 8 | 1 | B7 |
| RD-04 | **DECIDED 2026-09-27 (S4.R3; DECISIONS E.1): nothing preselected on the first run; New keeps the site and rig and asks for the target; an empty capture plan with "Start from the example plan".** New-draft defaults: should a new draft pre-select M42 and the first rig, and how are defaults and the "Example plan" labelled or offered? 08 §14 asks whether the example plan adds value | ENG-15, SCI-12, UX-24; TASK 4.4 | 4 | Stage 6 |
| RD-05 | **DECIDED 2026-09-27 (S4.R3; DECISIONS E.1): L1 (Draft internal; Not saved / Saved / Saved · changed; Save explicit), Y2 (yesterday's saved plan stays on its night; the planner continues on a copy), U1 (Save · Discard · Cancel; Discard deletes; V3 and W1 count as unsaved).** Drafts and "New session": is a separate draft stage needed (08 §2)? Are unsaved drafts listed, confirmed before being replaced, or cleaned up (UX-12)? What do "+", New Session and Duplicate do, and how is the state shown (08 §5)? | TASK 11.3's owner decision (drafts are not listed); ADR-014. **Interim decided 2026-09-25 (Stage 1 planning):** confirm before a draft with unsaved changes is replaced (S1.6); the rest stays open for Stage 4. **Input from Stage 1 validation (V3, owner, 2026-09-25):** a site change on a saved plan turns the stored session into a draft ("Planned, unsaved changes", still listed) but does not count as unsaved while the app runs, so New does not ask; after a restart it does. Decide whether a site change edits a saved plan | 4 (an interim safeguard can be decided in Stage 1) | A7; Stage 6 |
| RD-06 | **DECIDED 2026-09-27 (S4.R4; DECISIONS E.1): answer first, then decision order (amends ADR-015 §2); the budget breakdown, √N help, assumptions, weather variables and rig rows one tap away (ADR-009 §2's "own line" within the budget details).** May the planner's section order change (ADR-015 §2)? May assumptions, the √N help and heuristic notes be one tap away instead of always expanded? | UX-02, UX-05, UX-06; 08 §16–§17 prefer collapsible, on-tap explanations | 4 | Stage 6 |
| RD-07 | **DECIDED 2026-09-27 (S4.R5; DECISIONS E.1): the Library manages (a tap never changes the plan; "Plan this target"); choosing happens in the planner, Tonight's context line and the first run; Progress moves to the Logbook.** The Library's role: should its lists select for the current plan (TD-053), keep target selection, and where does Progress live (08 §19)? | ADR-015 §7; TASK 14.2 | 4 | Stages 6 and 9 |
| RD-08 | Tracking per rig (ADR-011 §5) or per plan/session (08 §21)? What does the seeded rig declare (UX-15(1))? | PD-11: NPF guidance keys on the rig's tracking. **Options prepared 2026-09-27 (Stage 6 planning; §5, "Stage 6 gates"):** T1 per rig / T2 per plan / **T3 the rig's default with a per-plan override (recommended)**. **Decided 2026-09-28: T3** (DECISIONS E.1, "RD-08 decided"); the seeded rig stays `unknown` | 7, decided before Stage 6's capture-plan work | Stage 6 capture plan (P6.8, frozen as **S6.9**); Stage 7; P9.3. *2026-09-27:* `Tracked` is not Track live; a plan-level choice, if chosen, is built in Stage 7; it never goes back into global Settings. *2026-09-28 (Stage 7 planning):* built by **S7.1** (ungated; the plan field, the effective value, the planner's control, the snapshot keys, the export) |
| RD-09 | Destructive interactions: confirm or undo, including deleting a capture block and swipe-to-delete. **Options prepared 2026-09-27 (Stage 5 planning; §5, "RD-09 — confirm or undo"):** Q1 C / **M (recommended)** / U; Q2 **S1 (recommended)** / S2. **Decided 2026-09-27 (owner): M + S1** (DECISIONS E.1, "RD-09 decided") | UX-09, UX-38; 08 §14, §20; `IA_WIREFRAMES.md` §3 (no destructive action without confirmation) | 5 | S5.8; Stages 6–9 |
| RD-10 | Ordering Tonight's candidates without a score: a secondary sort, thresholds, or grouping of ties | UX-29; ADR-013 §5. **Options prepared 2026-09-27 (Stage 6 planning; §5, "Stage 6 gates"):** **O1 usable time, then frame fill (recommended)** / O2 usable time, then max altitude / O3 thresholds and groups. **Decided 2026-09-28: O1** (DECISIONS E.1) | 6 | S6.14 |
| RD-11 | Where the ADR-013 optional Moon and cloud gate controls live (TD-050): in Settings (Stage 9) or earlier, in the planner | 01; 07 §6 item 10. **Options prepared 2026-09-27 (Stage 6 planning; §5, "Stage 6 gates"):** **S9 Settings in Stage 9 with RG-13 (recommended)** / S6 Settings now, as S6.15 / P the planner. **Decided 2026-09-28: S9** (DECISIONS E.1); no S6.15 | 6 or 9 | P9.3 if Stage 9 (2026-09-27); S6.15 if Stage 6 |
| RD-12 | **LAPSED 2026-09-27** (the tracker's retirement; DECISIONS E.1, "Stages 6–11 amended after Stage 5"): the resume prompt goes with the tracker. ADR-019 §4 already expected Finish to lead to the result form; how a run still in progress at the upgrade reaches it is P8.4's audit. *(Was: should the resume prompt's Finish complete the session at once, or open reconciliation like the tracker's Finish?)* | RT-10, UX-26; ADR-016 §11 | 8 | — |
| RD-13 | **DECIDED 2026-09-29 (Stage 8 planning; delegated by the owner; DECISIONS E.1, "Stage 8 decisions", D8-3):** "Reported as planned" labels Completed-as-planned counts; existing accepted estimates cannot be told apart and are not relabelled; CALC-37/38 note that counts are the user's statements. Built by S8.1. *(Was: should an accepted frame estimate carry "estimated" provenance (ADR-008 §6) instead of being stored as a confirmation (ADR-016 §3)? Narrowed 2026-09-27 to the existing accepted-estimate events and the "reported as planned" label.)* | SCI-07 | 8 | — |
| RD-14 | **DECIDED 2026-09-27 (S4.R5; DECISIONS E.1): Rig; Plan; Logbook; the glossary in `research/S4.R5_LIBRARY_AND_VOCABULARY.md` §5.** Vocabulary: rig or equipment; Sessions or Logbook; the names of the dark window and the night key | UX-18; 08 uses "Logbook" and "Planner" | 4 | Stage 5's shared vocabulary; limits C4 |
| RD-15 | Does the beta need a local diagnostics export (`AppLog`)? *Decided 2026-09-30 (Stage 11 planning, delegated; E.1, D11-4): not for the beta.* | ENG-13; crash reporting is deferred for privacy | 11 (planning) | Beta triage |
| RD-16 | **RESOLVED (owner, 2026-09-26, S3.D; ADR-018 §7):** visible at the end of Stage 3 (S3.7), as "Add from a photo" on the equipment screen. Earlier: **resolved for Stage 2 (owner, 2026-09-26):** hidden throughout Stage 2; Stage 3 decides visibility. *(Was: when and where the metadata feature becomes visible (the PD-06 gate): at the end of Stage 2, or Stage 3.)* | PD-06; `FeatureScope` | 2 (3) | — |
| RD-17 | Push the CI workflow to the remote and observe a first run (TASK 1.3), given RD-01 and the repository's visibility. **Included in Stage 1 (owner, 2026-09-25) as S1.14**; **the push was deferred by the owner when S1.14 ran (2026-09-25)**: open again, for Stage 11 or an owner request; **Resolved 2026-10-17** (S12.1; run 39020770255; S12V-01) | 06 §2; 07 §9 | 1 (optional) or 11 | — |

**Answered in part by Stage 0:** the direction part of 07 §6 item 11 (the primary 1.0 user),
in `PRODUCT_DIRECTION.md` §2. The focus stays on manual and semi-automated imagers, and less
experienced users are served by removing unnecessary expert entry. The question of separate
modes stays open as RG-06.

**Owner actions** (not decisions; they block the release, not refinement): the current list is
`PROGRESS.md`, "Owner actions outstanding". The list written here at Stage 0 (the upload key, the policy,
the trademark search, a device, metadata samples) is kept in the history file; its policy, repository
and identity items are done (S12.3, S13.2), and the Play upload key is deferred (GitHub-only distribution).

---

## 9. Workflow rules

This section preserves Stage-work methods under the shared [AGENTS](../../AGENTS.md) contract. [AI_WORKFLOW](../AI_WORKFLOW.md) is the canonical preflight/coordination/handoff procedure; [VERIFICATION_POLICY](../VERIFICATION_POLICY.md) alone defines required checks. The owner’s current scope and Git permissions govern every step. No model/version choice or next-stage authorization is implied.

### 9.1 Stage workflow (default)

```text
1. Fresh session where practical under V8
2. Read the current Stage and the repository state
3. Verify the prerequisites
4. Create the Stage execution plan
5. Identify research gates and owner decisions
6. Freeze the approved Task sequence
7. Execute the Tasks sequentially
8. One coherent Task per implementation session or chat, where practical
9. Verify each Task (docs/VERIFICATION_POLICY.md V1–V3)
10. Commit coherent completed work only if currently authorized
11. Fresh, independent Stage validation against the frozen criteria (V4, V8)
12. Focused corrective Tasks for blockers only; revalidate the affected surface (V5)
13. Close the Stage when every frozen criterion passes (V7)
14. Update PROGRESS.md
15. Stop; start another Stage only under current explicit authorization
```

### 9.2 Task sizing

A good implementation Task normally has one primary behavioural objective, one coherent
scope, explicit dependencies, an explicit out-of-scope list, objective acceptance criteria,
and one complete validation loop.

- Do not optimise for the most lines changed.
- Do not create artificially tiny Tasks when one coherent behaviour spans several layers.
  Cross-layer work is acceptable when every change serves the same behavioural objective.
- Decompose a Task that combines several independent decisions or needs unresolved research.
- As a rough continuity with the previous roadmap: **S**, a focused, local Task; **M**, one
  coherent cross-layer behaviour; **L**, usually decomposed unless highly cohesive; **XL**,
  never an implementation Task.

### 9.3 Prompts and context for future sessions

Prompts do not paste the entire repository history or all the audits. Each prompt names:

```text
Task ID
Objective
Why
Read first
Important current-state facts
Scope
Out of scope
Constraints
Acceptance criteria
Required validation
Stop condition
```

The agent then inspects implementation files just in time. The repository documentation is the
persistent memory. Do not repeatedly paste the full Master Roadmap, all the audit reports, old
chat transcripts or large architecture summaries; refer to exact files and finding IDs instead.
Owner-supplied prompt files are kept in `docs/refinement/prompts/` while they are in use; completed
ones are archived in `docs/archive/refinement-prompts/`. A prompt is the scope of its own session only.

### 9.4 Standard implementation workflow

```text
READ
→ VERIFY CURRENT STATE
→ PLAN
→ IMPLEMENT
→ VERIFY (docs/VERIFICATION_POLICY.md: by change class, reusing valid evidence)
→ SELF-REVIEW
→ UPDATE REQUIRED DOCS
→ COMMIT ONLY IF AUTHORIZED
→ STOP
```

The agent does not stop after planning if the approved Task can be implemented, and does not
begin the next Task automatically.

### 9.5 Scope-drift rule

> If an adjacent issue is discovered, document it but do not fix it unless fixing it is
> necessary to satisfy the current task's acceptance criteria.

> If the current task turns out to require a materially larger architectural change than its
> approved scope, stop before implementing the out-of-scope portion, document the reason, and
> propose a decomposition.

Ordinary implementation complexity alone is **not** a reason to stop. If the Task is coherent
and achievable within scope, complete it fully.

### 9.6 Research workflow

```text
QUESTION
→ CURRENT CONSTRAINTS
→ PRIMARY / AUTHORITATIVE EVIDENCE
→ VERIFIED FACTS
→ UNKNOWNS
→ OPTIONS
→ TRADE-OFFS
→ RECOMMENDED DIRECTION
→ OWNER DECISION
→ ADR / SPEC IF NEEDED
→ IMPLEMENTATION TASKS
```

Research and implementation normally happen in separate sessions. Research does not silently
modify production code. A hypothesis does not become an implementation Task because one
solution looks practical.

### 9.7 Stale-finding rule

> Before modifying code for an audit finding, verify the cited mechanism still exists. If later
> changes already resolved or materially changed it, report the discrepancy rather than
> implementing an obsolete fix.

### 9.8 Validation model

The validation model is defined once, in [VERIFICATION_POLICY](../VERIFICATION_POLICY.md):
- V1: the verification each change class needs (Task validation);
- V2, V3: when a broader check satisfies a narrower one, and when passing evidence is reused;
- V4: the frozen acceptance surface, and what may block (analysis-and-decision Stages use the
  bounded list there);
- V5: what is revalidated after a correction;
- V6: when a PASS may reopen;
- V7: when work closes, and when repeated failures go to the owner;
- V8: what a fresh session reads and reruns.

This section used to restate a Task-validation list (always the full gate) and an open-ended
Stage-validation instruction ("look for regressions, scope drift, … missing evidence"). Both are
replaced by the policy (governance correction, 2026-09-27). The Stage-validation procedure is
`docs/refinement/prompts/INDEPENDENT_STAGE_VALIDATION.md`.

### 9.9 Documentation duties

- After every Task, update `PROGRESS.md`: the Task, its commit, and the finding IDs it resolved.
- Update only the living-register statements invalidated by the task, as AGENTS/AI_WORKFLOW require:
  - `FEATURE_STATUS.md`;
  - `TECH_DEBT.md` (mark items resolved with the date and commit; never delete them);
  - `ARCHITECTURE.md` and `DATA_MODEL.md` Part B;
  - `SCIENTIFIC_INTEGRITY.md` for any calculation;
  - `DECISIONS.md` for any formula, architecture or product decision, including resolved RG
    and RD items.
- When a Task takes an audit finding, record the audit ID in the relevant living register.
- Never edit `docs/audit/*`, `PROJECT_AUDIT.md`, the archived `MASTER_ROADMAP.md` and `ROADMAP.md`
  (`docs/archive/master-roadmap/`), or anything else in `docs/archive/`.

### 9.10 Reading older governance after Stage 0

- `.agents/rules/00-project-governance.md` says "treat the roadmap phase as the active scope".
  After Stage 0 that means the approved refinement Stage and Task.
- OD-06's "one roadmap TASK per cycle" continues as "one approved refinement Task per cycle".
- Approval follows `CLAUDE.md`: an owner-supplied implementation Task prompt approves that
  Task completely. A new, unresolved architecture, data-model, scientific, product,
  external-provider, licensing or scope decision still needs its gate and the owner.

---

## 10. Relationship to historical documents

The documentation map is [`docs/README.md`](../README.md).
- **Historical, preserved and not rewritten:** the master-roadmap phase in `docs/archive/master-roadmap/`
  (`MASTER_ROADMAP.md`; `ROADMAP.md`, its "Active task" line frozen at "Next: TASK 16.4";
  `PROJECT_HANDOFF.md`, the takeover-era orientation, archived on 2026-10-18), with forwarding stubs at
  their old paths; `PRODUCT_SPEC.md` (Phase 0 design intent); `IA_WIREFRAMES.md` (ADR-015 intent);
  `PROJECT_AUDIT.md`; `docs/audit/*`; `docs/archive/`; this plan's history file, `PROGRESS_HISTORY.md` and
  the `STAGE_N_*.md` reports.
- **Living, updated by refinement Tasks under `CLAUDE.md`'s conventions:** Parts B and C of
  `ARCHITECTURE.md` and `DATA_MODEL.md`; `FEATURE_STATUS.md`; `TECH_DEBT.md`; `DECISIONS.md`;
  `SCIENTIFIC_INTEGRITY.md`; `DESIGN_SYSTEM.md`; `ENGINEERING_GUARDRAILS.md`; `TEST_PLAN.md`;
  `EXPORT_MANIFEST.md`; `COMPLIANCE.md`; `RELEASE.md`; the published pages `docs/index.md` and
  `docs/privacy/`.
- **Superseded as operational guidance:** see `PRODUCT_DIRECTION.md` §9 (the roadmap as the
  task queue; Plan → Execute → Log as the central loop; G17's timing; the RA.D supersessions).

---

## Appendix A — Manual dogfooding report (08) → Stages

Moved verbatim to [`POST_ROADMAP_PLAN_HISTORY.md`](POST_ROADMAP_PLAN_HISTORY.md#appendix-a--manual-dogfooding-report-08--stages), with its A.1 owner
table (every 08 section mapped to Stages 4–11).

---

## Appendix B — Carried roadmap work

Moved verbatim to [`POST_ROADMAP_PLAN_HISTORY.md`](POST_ROADMAP_PLAN_HISTORY.md#appendix-b--carried-roadmap-work). Its open device and owner items were
carried into the Stage 11 matrix and now run in S17.5 and S17.7 (`PROGRESS.md`, "Carried items").

---

## Appendix C — Findings rejected or accepted as documented

None of these is scheduled as a defect. Findings 06 rejected are not revived without new
repository evidence (§2). Findings 06 accepted as documented are handled only where the last
column says so.

| Finding | 06 verdict | Condition for reopening, or where it is handled |
| --- | --- | --- |
| ENG-07 unused repository providers | Rejected (no rule broken) | A tidy-up only alongside related work |
| ENG-09, its performance half | Rejected (no evidence at realistic volumes) | A measurement in Stage 10 |
| ENG-10 weather cache never evicted | Rejected | A measurement of the preferences file's size (Stage 10) |
| ENG-11 N+1 queries, as a defect | Rejected (host: 198 ms for 200 sessions) | A device timing (Stage 10) |
| UX-15(3) "Current Altitude −27.5°" | Rejected (the label says "current") | — |
| UX-27 "window opens in" countdown | Rejected (outside TASK 13.3's scope) | Only as new scope requested by the owner (Stage 8). *(2026-09-27: moot, since the tracker retires, P8.4)* |
| UX-33 heading inflation | Rejected (a preference) | Typography is Stage 5 design work driven by 08 §7, not a revived defect |
| UX-35 icon-only app-bar actions | Rejected (a preference) | 08 §5 and §8 supply human evidence about "+"; handled in Stages 4 and 6 as owner-observed UX |
| UX-36 card affordance; UX-37 white snackbar; UX-40 top-of-screen toggle | Rejected (preferences) | New evidence only |
| SCI-04 grid bias | Documented and acceptable | Only its wording (RD-03) |
| SCI-07 accepted estimates | Documented (ADR-016 §3) | RD-13 |
| SCI-08 elevation | Documented (F-07) | RG-08 |
| SCI-13 darkness limit | Documented (TD-051, TD-054) | Stage 6 presentation |
| UX-14 Library lists act as pickers | Documented (TD-053) | RD-07 |
| UX-23 typing in plan editing | Documented (a trade-off) | Stage 7 forms |
| UX-30 Sessions filter bar | Documented (required by TASK 14.1) | The owner's 08 §24 preference, Stage 8 |
| UX-39 red-mode limits | Documented (ARCHITECTURE B16) | Stage 11 darkness test |
| ENG-16 ViewModel at its size cap | Documented | A Stage 6 planning note. **Resolved 2026-09-27 by S6.1** |
| AC5 preferences exception | Documented (the owner's TASK 11.4 decision) | — |
