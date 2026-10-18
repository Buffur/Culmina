# Claude goal — implement the approved Culmina final completion plan

Prepared for the owner on 2026-10-18, after the project baseline was pushed to `develop` at `2b467b8fd1478b6f8f0fcd48e887a88bc819ad8e`. This is an executable implementation brief when the owner submits the launch command below. Its presence in Git, opening it for review, or the preparatory commit/push does **not** launch implementation.

## Launch and completion condition

Open this repository's `develop` checkout in Claude Code. Use a coding-capable session, not read-only Plan mode. Check that the installed client's command menu offers `/goal`; runtime trust, permissions, account limits and tools still apply. Do not install a client, alter permission settings or bypass managed controls merely to start this run.

Submit this single command as the owner's start instruction:

```text
/goal Read docs/refinement/prompts/CLAUDE_FINAL_PLAN_GOAL_IMPLEMENTATION.md completely and execute its bounded final-plan run on develop. I authorize sequential F01-F26 implementation, G1-G4 subject to their stated owner/resource gates, task commits and ordinary pushes to origin/develop; no main update, force-push, signing-secret access, owner-data operation or publication without its separate authorization. Continue every dependency-ready task without asking to start it again. Finish only with a transcript-supported COMPLETE report after all mandatory task/gate evidence, or a truthful BLOCKED handoff after exhausting eligible independent work and documenting the exact missing resource/owner decision. A blocked handoff is not project completion. Resume existing verified progress instead of restarting audits.
```

The command is deliberately shorter than the runtime's documented 4,000-character goal-condition limit; the detailed contract is this file. The evaluator sees the conversation: surface real commands, results, criterion counts, commit/CI identities and pending decisions in progress reports. A successful evaluator verdict is not an independent test or a substitute for the repository acceptance evidence.

If `/goal` is unavailable, report the actual client/runtime limitation. The owner may submit the same brief as an ordinary coding instruction and resume manually; do not claim an unattended goal loop exists. A restored chat or memory is not enough: reread current repository checkpoints. Runtime errors, credit limits and required owner decisions can interrupt a goal; no prompt guarantees uninterrupted completion.

## Authorized scope and authority

You are the implementation lead for the finite approved queue in `docs/refinement/FINAL_COMPLETION_ROADMAP.md`, version **P6-2026-10-18-07**, AM-01/AM-02/AM-03/AM-04. It contains **26 tasks, 127 A/CHK criterion pairs and four gates**, not 127 separate development tasks. Baseline content SHA-256: `7e75d60bbc8d97c444318fc8eb1c6285e32d850c9e2019e3854351661d0c51fa`. Later explicit owner amendments and verified task completions take precedence; never overwrite a newer authorized state to match these starting numbers.

The complete named group F01–F26/G1–G4 is authorized when the owner launches this prompt. A task boundary requires a checkpoint and coherent commit, then continuation to the next eligible task within this group. It does not require another start request. Apply `CLAUDE.md`'s grouped-run exception and roadmap §2/§6. A single-task prompt outside this run still stops at its own scope boundary. This brief changes neither acceptance criteria nor the canonical verification policy.

Ordinary engineering choices and all necessary multi-file work inside an authorized task are included. Genuine unresolved product/scientific/contract choices retain their named checkpoints. The already selected D1–D5/D7–D9, UX-S and AM03-T = B are not votes to repeat. D6 is intentionally decided after F26 measurements. Preparing decision options does not authorize approving them yourself.

Do not start another reassessment, P1–P8 cycle, global roadmap, exploratory stage or audit of this audit. Old S-IDs are traceability aliases, not another queue. CRUX-05/06 and other unselected recommendations remain proposals unless a current task already covers their relevant behavior or the owner explicitly selects them.

## Read the sources of truth in this order

At bootstrap read these entry points; at later tasks reread only changed/current relevant sections:

1. `CLAUDE.md` — owner scope, precedence, workflow and Verification Policy V1–V8. It cannot grant tools or permissions absent from your runtime.
2. `docs/refinement/PROGRESS.md` — current state, active run, task/criterion evidence, blockers, reusable validation and next allowed action. Start from here after every compaction/restart.
3. `docs/refinement/PRODUCT_DIRECTION.md` — current direction and §9 supersession map; the primary product is an understandable Capture Plan.
4. `docs/refinement/FINAL_COMPLETION_ROADMAP.md` — read completely once: §2 shared U/W and execution; §3 each task/gate; §4 source/amendment mappings; §5 accepted choices, exclusions and local prerequisites; §6 accounting; §7 every CHK; §8 capture/night semantics; §9 UI annex/evidence/release rows.
5. `docs/DECISIONS.md` E.1 — approved completion baseline, D1–D9/UX-S, AM-01–AM-04, AM03-T; then only the ADR sections the task names. ADR-021 and ADR-022 are task-local acceptance checkpoints, not already accepted encodings.
6. `docs/refinement/FINALIZATION_REVIEW.md` — incorporated source ledger §§4–10 and active §20 SP01–SP11 UX contracts; use affected AM records §31/§33/§35–§37 and §34 finding evidence. Earlier alternative sketches, review-time proposals and dated snapshots are evidence, not competing requirements. Resolve conflicts to current approved F/A/CHK and owner amendments. Do not load all historical reports into every task.
7. `docs/Examples/README.md` and relevant images — including night slider, weather and `capture_parameters_reference.jpg`. Inspect actual images. Supplied Moonlit source is layout reference only; no imported astronomy engine/vendor dependency or copying arbitrary reference values into defaults.
8. `.agents/rules/00-project-governance.md` plus relevant rule files; `docs/ENGINEERING_GUARDRAILS.md` relevant persistence/time/metadata/UI/privacy/testing/release traps. Select relevant `.agents/skills/` only when helpful; do not assume they auto-load or override the user's scope.

Consult these topical contracts as named by the task:

| Work | Required relevant sources |
| --- | --- |
| Architecture, stored data, migration and restore | `docs/ARCHITECTURE.md`, `docs/DATA_MODEL.md`, accepted ADRs, actual schema/generated migrations/production connection and backup code |
| Scientific/time/weather/storage/calibration behavior | `docs/SCIENTIFIC_INTEGRITY.md`, ADR/reference vectors named in the task, roadmap §8, actual domain services and their tests |
| UI, accessibility and terminology | `docs/DESIGN_SYSTEM.md`, `.agents/rules/05-ui-design.md`, roadmap U/W, §9 and incorporated SP contracts; actual widgets/ViewModels/shared words |
| Export and saved history | `docs/EXPORT_MANIFEST.md`, actual snapshot/manifest/result repositories, current primary AstroBin CSV specification at F20 |
| Dependencies, notices and network behavior | `docs/COMPLIANCE.md`, actual dependencies/provider code, licences/notices and current primary terms where a task requires verification |
| Status and debt traceability | `docs/FEATURE_STATUS.md`, `docs/TECH_DEBT.md`, `docs/TEST_PLAN.md`; update only statements invalidated by your change |
| Older clause/ID resolution | `docs/refinement/POST_ROADMAP_PLAN.md` RG/RD registers, §9 and S-ID clauses through roadmap §4; archives only for a specific historical question |
| Final qualification and release | `docs/RELEASE.md`, `docs/refinement/STAGE_11_MATRIX.md`, `docs/refinement/STAGE_11_DEVICE_RUNBOOK.md`, named evidence/runbooks and roadmap REL-01–REL-13 |

All normative project paths are relative to the repository root. Resolve them yourself; no dependency on a particular Windows user directory, temporary attachment, private old chat or externally held original workflow file is permitted.

## Bootstrap once, then implement

- Identify model/session, current HEAD/branch, remote target, dirty files and any other active writer. Verify you are in the intended project. Use the existing `develop` branch; do not work on or push `main`.
- Fetch/read `origin/develop`. Fast-forward only when it preserves local work. Never hard-reset, clean unknown files, overwrite another agent, force-push or replace a newer database. If the branch has diverged, reconcile the actual changes safely; do not stage unrelated work blindly.
- Read the latest checkpoint. At this handoff no F task or gate has passed; baseline application code is `322edbd`, schema v25. The docs/CI preparation commit is not F implementation. If later work exists, verify it and resume rather than assuming this initial state.
- Discover actual Flutter/Dart/Android/test/browser/device tools. The repository CI pin is Flutter 3.47.4; preserve the approved toolchain unless the task requires an approved change. Do not install/update dependencies, SDKs or owner apps opportunistically. The owner's subsequent clarification explicitly includes necessary isolated emulator setup and real-widget rendering in the authorized implementation/testing work; apply the execution procedure below rather than treating every such setup as a new approval request.
- Record the finite run authorization, lead/current task and next eligible task in PROGRESS. Verify prerequisites early: isolated old-schema restore fixtures; real DNG/JPEG/HEIC/FITS or licensed fixtures; API 26–30 emulator for F02; physical phone/IME/TalkBack for named carries; later public signing verification and owner-managed signing; network and remote CI visibility.
- Start **F01**, then **F02**, following the declared dependencies. Do not use environment inventory as a reason to spend the first session on more global planning.

### Independently use emulators and actual renders

Owner clarification, 2026-10-18: agents may independently run device emulation or produce renders. **The absence of a physical phone alone must not block implementation.** Use the strongest applicable available method, identify its evidence layer, and continue eligible work.

1. Discover configured SDK/tool locations from Flutter configuration, Android environment variables and the platform's standard SDK location. A missing `adb`, `emulator`, `sdkmanager` or `avdmanager` on PATH is not proof it is absent; look in the discovered SDK, including versioned command-line-tools directories. Check existing AVDs, system images and hardware acceleration.
2. Reuse an appropriate isolated test AVD or create one from an installed image. If absent, obtain the minimum required Android command-line tooling/system image and create a dedicated AVD as task-directed test setup, where current permissions, network and SDK terms permit. Do not upgrade the pinned Flutter/toolchain, accept new legal terms without authority, change unrelated SDK packages or touch owner-app data. API 26–30 evidence is specifically required for F02; a newer image cannot substitute for that row.
3. Start the isolated emulator independently; wait for actual Android boot readiness, then select its serial explicitly for builds/tests/ADB. Prefer headless mode when sufficient, preserve existing AVDs, and avoid visible helper windows unless needed by the user. Installing, clearing data or uninstalling within the dedicated test environment is included; connected owner devices are outside that authorization.
4. Exercise the actual app with available Flutter/integration/ADB/UI tools: navigation, permissions, mock location/network states, actual keyboard, process recreation, isolated install/update/restore and screenshots as the task requires. Label this EMULATOR evidence; it can satisfy emulator/native behavior rows, including F02, and prepare carried phone scenarios. It does not certify physical-device performance, field use, real device metadata access or a criterion explicitly requiring a phone.
5. Produce HOST RENDER evidence from actual production widgets with real fonts/icons and synthetic fixtures for affected U states: 412 px width, 100%/200% text, light/dark/field themes, error states and keyboard insets as applicable. A rendered keyboard inset is layout evidence, not an exercised native IME. Do not present reference photos, sketches or fabricated screenshots as implemented UI.
6. Save reproducible commands, fixture/source and nonprivate screenshots with toolchain/API/device/text/theme labels. Test an actual available alternative before declaring that surface blocked. If provisioning or launching fails, record the concrete failure, continue host renders/tests and other eligible tasks, and carry only the remaining specific evidence row. Do not repeatedly retry an unavailable resource or declare every task blocked by absence of a physical phone.

At preparation on 2026-10-18, the existing SDK's emulator and ADB ran, and `emulator -accel-check` reported WHPX installed and usable. `-list-avds` returned none, no system images were found in that SDK, and ADB listed no connected device. This inventory is not an app run or a permanent environment guarantee; rediscover it at execution. Necessary emulator provisioning remains implementation-time work, not completed evidence.

## Task order and expected outcomes

This table is navigation. The full task text and its matching A/CHK rows are normative, including every exclusion, invariant, verification, evidence and stop field.

| Stage / ID | Implementation outcome |
| --- | --- |
| A / F01 | Candidate restore checked at pick and activation through the production connection; corruption/newer-schema refusal preserves live data; interruption recovery, coherent preferences, one safety copy, immediate confirmed activation/restart and one outcome report |
| A / F02 | Correct static identity splash before Android 12, approved held animation and reduced-motion behavior; actual API 26–30 launch evidence |
| B / F03 | Concrete numbered ADR-021 decision pack and its required acceptance; preserving v25→v26 migration, nullable WB/focus/source/mode fields, additive snapshot v1/manifest v2 round trips; raise FITS availability early |
| B / F04 | Extend the single typed metadata/reader contract, with kinds/units/conflict/unsupported states and bounded real-file evidence; no speculative control surface |
| B / F05 | Explicit camera class; equally visible photo/manual rig entry; valid required inputs, provenance, review/cancel; invoking plan/onboarding creation selects the rig, Library creation saves only |
| B / F06 | Stable custom filters, type-switch/default behavior, origins, WB and optional AF/MF; familiar class-specific basic form, fractional/decimal exposure, guard, local Add block/Apply changes versus parent Save plan |
| B / F07 | Compatible measured evidence first, supported theoretical storage otherwise, honest Unknown/remedy, mode association, decimal units and once-only binning |
| B / F08 | Existing photo pipeline supplies a reviewed light-block proposal; manual override, conflict/order handling and no writes on Cancel |
| B / F09 | Correct full-tuple calibration proposals and missing coverage; visible build/review/counts/Cancel/Undo; independent flat exposure and LENR policy; retire example action with a usable replacement empty state |
| B / F10 | Bounded FITS header integration into existing rig/block flows; supported geometry/binning semantics, actual real-file review/save and licensed/private evidence handling |
| B / F11 | Concise ideal relative stacking gain against one comparable light frame; preserve group/Unknown semantics; integration curve and planned-integration reference in Details, no absolute SNR claim |
| B / F12 | Effective assumptions, actionable fit/Unknown remedies, focus reminder plus descriptive mode only; grouped global Settings over the same plan with preserved return context |
| C / F13 | Accepted local ADR-022 contract and reference vectors; consistent Moon-up/moon-free intervals and D9 browse/adopt behavior without changing stored night meanings |
| C / F14 | Honest available multi-night forecast and selected-night hourly graphics: cloud, temperature/dew, wind/gust, precipitation, exact values, explicit gaps/source/age/lead time and offline states |
| C / F15 | Offline month/week Moon browsing, combined Sun/twilight/dark/Moon band and labelled read-only time slider with text alternative; adopt only via Plan this night |
| C / F16 | One stable optional setup screen, explicit permissions/manual fallback, class/rig flow and Start planning, without target step, flash or weather startup dependency |
| C / F17 | Home leads with actual plan-night context/current plan; candidate action secondary; tab stays Tonight, page title follows current versus selected plan night |
| C / F18 | Compact Planner/Capture Plan, explicit readiness/actions and stable Save reason/remedy; remove Tonight for this target UI while preserving fit/windows; shared plan-night phrase and draft/banner/return correctness |
| C / F19 | Logbook no-result/completed/partial/not-done status and direct result actions; planned/recorded integration, progress and stored forecast; explicit current-saved-night reporting before dawn with dirty/stale/concurrent safeguards |
| C / F20 | Recorded-acquisition AstroBin CSV using the checked primary contract, truthful counts/filters/compatibility and ordered preview; no auth, uploads or IDs lookup |
| C / F21 | Approved appearance/units and coherent persisted settings; visible pending/unsaved/Retry, latest complete edit wins; place-name opt-out never silently contradicts stored state |
| C / F22 | Actual route/process-restoration behavior and permanent kill/upgrade regression; preserve saved/draft/result/legacy state and fallback reasons |
| C / F23 | Current provider labels/municipality fallback and actual bundled notices; consented GPS-name proposal, later manual coordinate/name edits win, no late writes, honest unsaved-position labels |
| C / F24 | Exactly six maintenance rows: fixed clocks, all-tiles-fail regression, AppLog cleanup, planned async lint, registered startup/zone/test gaps and newest-query target-search ownership |
| C / F25 | Final affected-surface U/accessibility/quantity consistency and all four W records; repair observed failures, obtain required owner visual acceptance and classify genuine comprehension limits |
| D / G1 | Frozen finite final acceptance list, valid host/native/emulator/provider evidence and actual green remote CI on accepted inputs; no mandatory host blocker |
| D / F26 | Traceable correctly signed/identified/versioned/aligned APKs, real universal/arm64 sizes then owner D6 selection, checksums/public signer/release instructions and final-input qualification |
| D / G2 | Exact selected APK SHA on a phone: core/W/metadata, restore/Recents/interruption, TalkBack/motion/timing, clean install and same-key update; authorized owner migration where applicable |
| D / G3 | Reconcile finite evidence and optional debt; owner records release go/no-go; do not invent another audit or self-approve |
| D / G4 | Only after separate owner publication authorization: publish exactly qualified bytes and verify downloaded hash/signer plus required phone loop |

Default sequence: F01 → F02 → F03…F12 → F13…F25 → G1 → F26 → G2 → G3 → G4. Respect actual dependencies, not artificial stage barriers. F13 can proceed independently of FITS; missing F10 sample does not block unrelated tasks. Return to skipped mandatory work before its gate. Hard dependency implementation/contract checks must be satisfied; explicitly named phone evidence carried to G2 can remain pending without blocking permitted dependent code work. That carry never makes the originating task VERIFIED.

## Product requirements that must survive every task

- **Simple Capture Plan:** basic frame entry → concise integration/estimated total time/storage/relative gain → Save. Advanced charts/science remain accessible Details. Valid results stay visible when another output is Unknown.
- **AM-04 camera fields:** for Phone/DSLR, expose exposure/count/ISO/WB and optional AF/MF, plus applicable frame type/filter. Values may stay unrecorded; do not manufacture camera-specific presets or ranges. Explicit rig class selects ISO/gain; Unknown has a clear class remedy or unrecorded state. Binning belongs in applicable astro Details. Preserve hidden historical values. AF/MF is a descriptive record, not a numeric focus value, control command, new metadata decoder, timing model or calibration identity dimension.
- **Calibration:** preserve whole-tuple compatibility, separate actual recorded values from proposals, no invented exposure for flats, correct library/in-window/outside-window behavior and LENR. Simplify presentation without deleting the domain invariant.
- **Night/weather:** calculations and labels use the same selected site/night/zone; no hard-coded tonight for future-night plan facts. Slider/calendar/forecast browsing never mutates a saved plan. D9 adoption resolves Save/Discard/Cancel and preserves original history.
- **History and results:** immutable snapshots/forecasts, manual acquisition reports and correct derived progress. Current saved night can be explicitly reported before dawn under F19; future acquisition cannot. Browsing/cancel/import review cannot silently rewrite records.
- **Data/science/privacy:** preserve canonical units, explicit Unknown/provenance, supported legacy/future-enum behavior, offline core and existing approved models. No absolute SNR, new provider, partial-rig redesign, tracker, hardware controller, localization project or licence expansion. GPS/name proposals require the existing consent and preserve later user edits.
- **UI proof:** implement actual Flutter screens; sketches and reference photos are not acceptance. U includes real glyphs, 412 px, 100%/200%, light/dark/field, error/IME and reduced motion as applicable; the long block editor has reachable actions at 412×915/200% with keyboard. Use the existing full-screen route pattern when the dialog fails these criteria.

## Implementation, verification and review loop

For each task:

1. Read its full contract, every A/CHK pair, relevant actual code/tests and dependency evidence. Confirm what already exists; do not reimplement completed work or turn planned functionality into a duplicate defect.
2. State a short local engineering plan and the affected inputs. Implement the whole authorized behavior, including migrations/generated code/export/UI/callers where required. No new stand-alone planning document is needed.
3. Add/update meaningful regressions for the changed failure paths. Use independent fixtures/expected behavior; never weaken tests, replace production paths with fakes, assert only implementation structure, or confuse an observation of the old defect with proof of a fix.
4. Run exactly the verification required by **CLAUDE.md V1–V8** and the task's cumulative risk after its final code change. High-risk persistence/science/schema/metadata tasks require the full gate plus named probes; shared behavior requires affected regressions and escalates as V1 says. Reuse valid evidence; a passing broader check satisfies its parts. Do not rerun the full gate after Markdown-only completion edits.
5. Check every A/CHK explicitly. Use CODE/TEST/HOST RENDER/EMULATOR/DEVICE/HUMAN labels and real environment/baseline. Verify persistence **and derived UI** after relevant stale edit/Undo/copy/restart/cancel operations. A screenshot proves neither timing nor human understanding. Record current output rather than repeating historical test totals.
6. Self-review the cumulative diff against the exact task, data/science invariants and original finding. Fix actual in-scope failures. A later relevant fix invalidates affected evidence, not all prior tasks. Fresh-session/other-agent review where required must disclose authorship and cannot fabricate independence.
7. Update PROGRESS and only other invalidated registers. Record criterion disposition, commands/results or justified reuse, environment, evidence path, unresolved carry/owner decision and next eligible task. Store reproducible nonprivate evidence under `docs/refinement/evidence/finalization/` with a task-specific directory. Keep raw evidence intact; original observation patches are not permanent regression tests.
8. Commit a coherent tested task with a meaningful message, then normal push to **origin/develop** within this launched run. Check the actual push result. Read remote CI for that exact SHA when required; failing CI is a problem to resolve, queued/in-progress/missing CI is not green. Do not include unrelated edits, keys, private samples, real owner databases or generated build outputs.
9. Checkpoint and continue the next dependency-ready task in the authorized group. If mandatory evidence is pending, say **IMPLEMENTED / ACCEPTANCE PENDING**, not complete; continue only what that state permits. Do not ask whether to start an already authorized task.

For a pure CI trigger/path-selection edit, verify syntax/selection and unchanged execution steps as V1 allows. For any later CI toolchain/steps/dependency change, apply its actual higher risk. Run checks with the repository's pinned toolchain; describe any environmental mismatch honestly.

## Coordination across Claude agents and sessions

Use **one implementation lead and one active writer to the develop checkout**. Multiple independently launched goal agents must not all mutate this working tree, PROGRESS, migrations, generated files or task commits. Do not distribute F01–F26 as an unordered parallel list: most share contracts/ViewModels/persistence.

The launched run may delegate narrowly scoped reading, reproduction or review with explicit task/criterion ownership and no shared-checkout writes. Optional coding workers require isolated worktrees, stable accepted contracts and genuinely independent file ownership; the lead alone integrates, updates the canonical status and commits/pushes develop. Read current developer/runtime permissions before using helpers. Do not automatically enable experimental teams, change models or permission modes. A helper's verdict cannot approve an owner decision or replace required evidence.

Do not change branch under an active writer or run concurrent Git mutations. Before integration inspect every worker diff, resolve actual conflicts, rerun only affected integration evidence, and attribute the baseline correctly. An idle helper is not a completed task. Quiesce helpers before handoff. New sessions recover from committed repository state, not assumptions that earlier teammates still exist.

## Genuine owner/resource gates and blocked handoff

Prepare concrete review material before asking; bundle related numbered items where practical. Continue independent authorized work while an answer/resource is pending.

| Gate/resource | Required handling |
| --- | --- |
| ADR-021 / F03 | Present concrete field/encoding/source/migration/reference choices, including AM-04 mode recording; obtain the required local acceptance before dependent persistence/science implementation. Do not ask D3–D5 again without a demonstrated conflict |
| ADR-022 / F13 | Present numbered coordinate/frame/interval/forecast/cache checks and the D9 flow/renders; obtain its required local acceptance. D9's already accepted semantics stay fixed |
| Missing real metadata files / F10 | Identify an available authorized owner sample or licensed fixture early, verify licence/provenance and do not commit private values/files. Synthetic tests do not replace the named real-file check; use only the roadmap's explicit deferral route |
| Owner visual acceptance / U/F25 | Show implemented screens with the relevant text/theme/IME states; retain the owner's actual decision. Do not claim that reading a reference image is final visual acceptance |
| Phone/emulator/native/provider evidence | Independently discover/provision/launch the isolated emulator and produce actual-widget renders as above; no-phone alone does not block implementation. Exercise available isolated fixtures/environments. Never silently install/uninstall an owner app or activate a real backup. Keep only truly unavailable named rows UNVERIFIED; neither mocks nor emulator results substitute for explicitly mandatory physical-phone evidence |
| Signing and D6 / F26 | Prepare tooling and measurements; owner manages signing outside agent access. Verify only public certificate/produced artifact. Request the D6 distribution choice from actual measurements; no reading/printing/requesting private keys/passwords |
| Owner data / G2 | Separate explicit authorization before moving data or uninstalling an owner app; independent verified backup and isolated rehearsal first. A newer database is not permission to reset it |
| Release go/publication / G3/G4 | Obtain actual owner go/no-go and separate explicit publication authorization; preparing release assets and pushing code are not publication permission |

When no eligible independent work remains, stop repeated retries/reviews. Produce a **BLOCKED handoff**, keeping unfinished tasks/gates pending, with: completed implementation; verified versus carried criteria; exact missing decision/resource; material already prepared; next eligible task/action; branch/HEAD/CI state; dirty files if any. Do not mark the project complete, weaken a criterion, fabricate acceptance, spin indefinitely or create a new roadmap to evade the gate. If the user pauses/stops, checkpoint and honor that instruction.

On the next owner reply/session, reread PROGRESS and evidence, incorporate that answer, and resume the same finite queue. Do not rerun valid checks merely because the session/commit hash changed. A blocked goal may need the owner to submit the launch command again; the repository checkpoint remains the recovery mechanism.

## Checkpoint and terminal report

PROGRESS is the sole operational ledger. Keep compact task/criterion rows rather than duplicating this roadmap:

```text
Run: full final-plan group; develop; launch authority/date/session
Task: Fxx; state: IN PROGRESS / IMPLEMENTED-ACCEPTANCE-PENDING / VERIFIED / BLOCKED
Criteria: CHK-Fxx.A1 ... A(n), each result and evidence reference
Inputs/environment: actual code/toolchain/device/sample baseline
Verification: commands + exit/result OR valid reused evidence and why
Owner/resource carries: exact gate, prepared material and required action
Git/CI: actual commit/push SHA, remote CI URL/status; no invented future hash
Next: next eligible named task, or blocked handoff and why none can proceed
```

Give concise Ukrainian progress updates and owner questions; persistent documentation stays English unless instructed otherwise. Surface important changes and real failures promptly; do not narrate every routine command. Before a commit/handoff inspect the actual diff and repository state and preserve unrelated user work.

Final output must include: all F01–F26 and G1–G4 dispositions; implemented/verified/pending counts without conflating them; remaining stages; criterion/evidence links; test and exact remote-CI results; release APK identity/hash/signer/device checks where reached; owner decisions still needed; Git branch/commit/push state; next action. **COMPLETE** means all mandatory criteria and gates evidenced, including the authorized published download. Everything else is a truthful partial/blocked result, even if all currently runnable host tests pass.

## Runtime references and handoff check

The execution design was checked against the repository's group-authorization, evidence and checkpoint rules and these primary runtime references on 2026-10-18:

- [Claude goal documentation](https://code.claude.com/docs/en/goal): the goal loop has runtime permission/trust and interruption limits; its evaluator uses surfaced conversation evidence. This file does not change the client's controls.
- [Claude agent-team documentation](https://code.claude.com/docs/en/agent-teams): concurrent writers can overwrite shared files; use clear ownership and isolation. Agent teams are optional for this plan.

Claude CLI was not found on the preparing shell's PATH, so an actual local Claude goal session was not launched or certified. The goal prompt, source links, finite queue/criteria, Git delivery, CI trigger and resume/stop boundaries are verifiable preparation; they are not F implementation, runtime acceptance or a promise that all owner/device gates can complete unattended.
