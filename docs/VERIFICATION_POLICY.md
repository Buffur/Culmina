# Verification Policy (canonical)

Status: active, sole normative verification policy for Culmina. V1–V8 and the bounded analysis/decision-stage rules were relocated from `CLAUDE.md` at `94cebfb6b2a3379f5991e61e1bd88f7120804601` on 2026-10-24 under the owner's governance cleanup. V1's documentation-only class now explicitly includes Markdown AGENTS/CLAUDE/GEMINI adapters and agent rules; it does not exempt executable tooling. Other V1 classes and V2–V8 retain their substance unchanged.

All rules, plans, prompts and skills route here. Historical “CLAUDE.md V1–V8” and “Verification Policy (canonical)” citations resolve here through the CLAUDE adapter; historical “CLAUDE.md trap N” resolves to [ENGINEERING_GUARDRAILS](ENGINEERING_GUARDRAILS.md). Current task permissions come from the owner and [AGENTS](../AGENTS.md), operational state from [PROGRESS](refinement/PROGRESS.md). Older blanket per-task full-suite instructions do not override this policy. This relocation changes no frozen behavior/release criteria or evidence result.

**Principle:** verification is proportional to what changed and to what evidence the change could have invalidated. Rigor is kept where the risk is; repetition that cannot change the answer is removed.

<a id="v1"></a>

**V1 — Required verification by change class.** Classify by the files actually changed; the highest class present wins.

| Change class | Required verification |
| --- | --- |
| **Documentation / governance only**: only Markdown (`.md`) under `docs/`, `.agents/` or `.claude/`; root or nested Markdown instruction adapters `AGENTS.md`, `AGENTS.override.md`, `CLAUDE.md`, `GEMINI.md` and `README.md`; and probe `.patch` files under `docs/`. Any other file is outside this class, including executable tooling, CI/configuration, generators and `.dart` skill examples | References and IDs resolve; the changed text is consistent with the documents it cites; `git diff --check` (whitespace). No application test, analyzer or gate run. |
| **Localized code change** (one feature area, no shared contract) | Targeted tests for the changed behaviour (new or updated), the tests of the touched files' area, `flutter analyze --no-pub`, `dart format` on the changed files, and `dart run tool/check_encoding.dart`. |
| **Shared behaviour** (a ViewModel, shared widget, theme, router, repository interface, or anything several screens use) | The localized checks above plus meaningful regressions for every affected caller/area. Select by changed behavior and dependencies, not the whole repository by default. Broaden only when the affected set cannot be bounded; record why. |
| **High-risk surface**: schema/migrations, persistence and data integrity, scientific calculations, time/night semantics (UTC, zones, DST, SessionNight), metadata parsing and provenance, backup/export formats, dependencies/lockfiles, build or test tooling (`tool/`, `analysis_options.yaml`, `build.yaml`, CI steps or the CI Flutter version) | Targeted tests for the changed contract and affected dependents, plus all named domain probes (migration/production-open and recovery fixtures, real-sample metadata checks, science/time reference vectors, snapshot/export round trips as applicable), analysis, changed-file format and encoding. High risk does not automatically require the full suite per Task. For dependency/tooling changes check the actual affected build/test paths; CI trigger-only changes need syntax/path selection checks. Broaden with a concrete impact reason if the affected set cannot be bounded. |
| **Correction after a review** | See V5: the original finding(s), the criteria the correction touches, and the correction's own regression surface, at the class of the files it changes. |
| **Task completion** (any code) | Apply the class above to the cumulative diff after the last relevant code change and check every acceptance criterion. A targeted passing set can close the Task's local verification; do not wait for all unrelated tests or asynchronous remote CI at every Task boundary. A genuinely unavailable mandatory check remains pending/NEEDS ATTENTION, never PASS. |
| **Stage / release gate** | The frozen current gate checks, with V3 reuse. Consolidate the full quality gate and actual green remote CI at G1 and on F26 final changed release inputs; equivalent already passing evidence is reusable when its inputs are unchanged. No extra full-suite run solely for a Stage label, Task commit or Markdown update. |

**Owner AM-05 (2026-10-18):** select the tests needed by the changed Task and its real dependency impact; do not automatically run or wait for every test after every Task. G1 and F26 retain the consolidated final full-gate/remote-CI requirements. Automatic CI may run in the background while independent work continues; queued/running/cancelled is not green, and an observed real failure must be triaged. This supersedes older blanket per-high-risk-Task/full-gate wording in historical S-clauses and prompts, without removing meaningful regressions or domain probes.

<a id="v2"></a>

**V2 — A broader check satisfies a narrower one.** The full gate contains the encoding check, format, `flutter analyze`, all unit/widget tests and the host E2E suite. After it passes on the final inputs, do not rerun any of those separately. Targeted tests during development are for fast feedback; they are not required again after a passing broader run on unchanged inputs.

<a id="v3"></a>

**V3 — Evidence reuse.** Passing evidence stays valid while the inputs relevant to it are unchanged. The inputs of the full gate are: application code (`lib/`, `assets/`, `android/`, `ios/`, other platform folders), test code (`test/`, `integration_test/`), dependencies (`pubspec.yaml`, `pubspec.lock`), and tooling (`tool/`, `analysis_options.yaml`, `build.yaml`, the Flutter version in `.github/workflows/ci.yml`); for an environment-dependent result (device, platform, real samples), also that environment.
- A new commit hash, a new chat or session, a changed review document or a changed `PROGRESS.md` does **not** invalidate evidence.
- Do not rerun a check to obtain a newer timestamp or hash. Rerun it only when (a) a relevant input changed, (b) the previous run is known to be invalid or incomplete, or (c) the acceptance gate being judged explicitly requires a fresh run.
- To reuse, record one line: the result, the commit or state it ran on, and why nothing since invalidates it (for example: `git diff --stat <commit> HEAD -- . ':!docs' ':!CLAUDE.md'` is empty).

<a id="v4"></a>

**V4 — The acceptance surface is frozen before a review starts.** A Task review, Stage validation or sign-off judges only: the approved Task or Stage acceptance criteria; the approved owner decisions; the explicit invariants (the relevant traps in `docs/ENGINEERING_GUARDRAILS.md`, ADRs); and the verification this policy requires. A finding is a **BLOCKER** only if it shows:
- A. evidence that one of those criteria, decisions or invariants is not met;
- B. a regression caused by the work under review; or
- C. a severe correctness, data-loss, data-integrity, privacy or safety defect exposed by the work (state the concrete failure, not a hypothetical).

Everything else — a hypothetical edge case, an alternative design, an unspecified implementation detail, a preference, a newly invented policy — is recorded as `FOLLOW-UP`, `DEFERRED / IMPLEMENTATION DECISION` or `OWNER DECISION` (or in `TECH_DEBT.md` / `SCIENTIFIC_INTEGRITY.md`), and does not block. A review never adds acceptance criteria to the work it is judging, and never presents an inferred rule as an owner decision.

<a id="v5"></a>

**V5 — Revalidation after a correction.** After a corrective Task fixes a blocker, the next validation checks only:
1. the original blocking finding(s);
2. the acceptance criteria the correction touches;
3. regressions plausibly caused by the correction (its own diff, at its V1 class).

It does not restart open exploration of the Stage; everything else keeps its PASS. A complete Stage revalidation is chosen only when the correction changes the Stage's approved design or acceptance contract, or touches enough of the implementation that the earlier evidence is invalid under V3. Whoever chooses it records why in one line.

<a id="v6"></a>

**V6 — When a PASS may reopen.** Only on (a) new contradictory evidence (a failing test, a reproduced defect, a quoted contradiction), (b) a change to a relevant input under V3, or (c) an approved change to the criterion. A new session is not evidence; a different validator's reading of the same evidence is not by itself evidence.

<a id="v7"></a>

**V7 — Stop and converge.**
- Inside an authorized finite run, an item genuinely impossible now is recorded as **NEEDS ATTENTION / Варто звернути увагу** in PROGRESS with F/G/CHK ID, implemented versus missing behavior/evidence, concrete reason/attempt, affected dependencies and condition for resumption. Continue the next safely executable independent item; do not wait, repeat futile attempts or self-approve missing evidence. Dependent items stay pending with their prerequisite named. Preserve blocker severity and data/science invariants; a label does not waive a requirement.
- A run ends when all named items have an honest disposition and no safe eligible work remains. Report **COMPLETE** only if every mandatory acceptance/release condition passed; otherwise report **PARTIAL_WITH_ATTENTION**, with the full done/not-done register and next actions. A finished finite pass is not a claim that the product is complete. Isolate incomplete changes that would break the shared baseline before continuing; preserve their work without resetting user files.
- When every frozen criterion passes and no V4 blocker remains, the Task or Stage **closes**: record it and advance the Next Allowed Action. Do not validate the validation.
- If two consecutive validations of the same Task or Stage fail on interpretation or scope (findings that restate or reinterpret criteria already judged, rather than new contradictory evidence under V6), stop automatic revalidation of that item. Record the disagreement as NEEDS ATTENTION with the exact owner question, continue independent authorized work, and include it in the final report. (Stages 1–4 each needed the owner after two failed validations.)
- Validation-only sessions never fix what they find; surviving blockers become focused corrective Tasks.

<a id="v8"></a>

**V8 — Fresh sessions.** Stage validation runs in a fresh session where practical, for independent reasoning. A fresh session reconstructs state from `PROGRESS.md` (its Next Allowed Action and reusable evidence), the frozen criteria and the sources they reference. It does not rerun tests whose inputs are unchanged (V3), reread historical audits or validation reports beyond those referenced, reopen passed criteria (V6), or reconstruct project history.

**Analysis-and-decision Stages** (research, owner decisions, ADRs and provisional Tasks; no
application code) are validated against a **bounded scope** — the V4 surface for such a Stage. The validation checks only:
- that the Stage's research Tasks were completed;
- that every required research gate has an explicit owner decision;
- that the ADR or specification faithfully records those decisions;
- that companion documents (wireframes, addenda) are consistent with it;
- that the decisions are mapped to later implementation Stages;
- that no direct contradiction makes an approved core flow impossible;
- that no Stage acceptance criterion is unmet.

A finding is blocking only when it demonstrates a direct contradiction with an approved owner
decision or an explicit Stage acceptance criterion. These are recorded as `DEFERRED /
IMPLEMENTATION DECISION`, not as blockers:
- an unspecified implementation detail;
- a hypothetical edge case;
- an alternative design;
- a policy that can safely be decided in the implementing Stage.

Neither a validation nor its corrective Task creates new product requirements, or presents inferred
rules as owner decisions. If the bounded validation passes, the Stage closes. If it fails, the
report names only the exact approved decision or acceptance criterion that is contradicted, with
evidence, and the Stage's scope is not expanded. (Owner, 2026-09-27; DECISIONS E.1, "Bounded
validation for analysis and decision Stages".)
