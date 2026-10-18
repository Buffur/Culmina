# Culmina — Refinement Progress

> The handoff contract for post-roadmap refinement: where work stands, what binds it, which evidence
> can be reused, and the next allowed action. Read it after [`CLAUDE.md`](../../CLAUDE.md); the
> documentation map is [`docs/README.md`](../README.md).
> - **Active execution queue:** [`FINAL_COMPLETION_ROADMAP.md`](FINAL_COMPLETION_ROADMAP.md), **approved by the owner 2026-10-18** (P8 base -02, owner amendments AM-01/AM-02/AM-03/AM-04/AM-05; current version P6-2026-10-18-08): Stages A–D, F01–F26, G1–G4.
> - **Registers and earlier plan:** [`POST_ROADMAP_PLAN.md`](POST_ROADMAP_PLAN.md) §7 (RG), §8 (RD), §9 (workflow rules); its §5 Stage 12–17 Task IDs are now the roadmap's aliases (its §4).
> - **Direction:** [`PRODUCT_DIRECTION.md`](PRODUCT_DIRECTION.md). **Decisions:** [`DECISIONS.md`](../DECISIONS.md) E.1 and the ADRs.
> - **Verification rules:** `CLAUDE.md`, "Verification Policy (canonical)".
> - **History:** [`PROGRESS_HISTORY.md`](PROGRESS_HISTORY.md) (every earlier entry, verbatim) and the `STAGE_N_*.md` reports.
>
> **Latest amendment:** AM-05 (2026-10-18): impossible-now items become NEEDS ATTENTION with reason/dependencies/resumption action, then independent work continues; final done/not-done report. Targeted tests per changed Task/dependencies; consolidated G1/F26 full checks. Version P6-2026-10-18-08; 26 tasks / 127 criteria, no F task started.
>
> **Earlier amendment:** AM-04 (2026-10-18): familiar exposure/ISO/WB and optional AF/MF, class-selected sensitivity and advanced astro binning, bound in F03/F06/F09/F12; recorded at P6-2026-10-18-07, 26 tasks / 127 criteria. Git preparation is authorized; no F task has started.
>
> **Prior amendment:** 2026-10-18, AM-03: four findings of the repeat Claude UI/UX review (FINALIZATION_REVIEW §34) accepted — CRUX-01–CRUX-04; 26 Tasks and 127 criteria. The owner then chose AM03-T = B (Home's title follows the plan's night; the tab stays “Tonight”): recorded at P6-2026-10-18-06; latest version is above. AM-01 and AM-02 remain incorporated; CRUX-05/06 stay proposals.
>
> **P8 baseline record:** 2026-10-18 (finalization workflow P8: the owner approved the final completion
> roadmap, version P6-2026-10-18-02, after P6 and the P7 check; documentation only, no application
> change, gate, build or device run. The same day's earlier cleanup moved the chronological entries to
> `PROGRESS_HISTORY.md`).

## Current state

| Item | State |
| --- | --- |
| Phase | Final completion. P8 approved base P6-2026-10-18-02 (historical content SHA-256 `a68b6b898f670430a80acaac6240049cc05e584101bf75519f95c001e1cff954`). The owner explicitly authorized bounded AM-01/AM-02/AM-03/AM-04/AM-05; current active roadmap is **P6-2026-10-18-08** (DECISIONS E.1 AM-01–AM-05 and AM03-T; FINALIZATION_REVIEW §31/§33/§35/§36/§37/§40). Stage12 and earlier closure remain; old S-IDs remain aliases. No F implementation starts from this documentation instruction |
| AM-01 | Simple Capture Plan, visual night/weather, Plan block removal, grouped Settings, consented GPS/name and early manual results. Historical -03 had118 criteria; AM-02 then brought it to 122 and AM-03 to the current 127 |
| AM-02 | UX32-01–05 now accepted: stable Save, scoped block apply, newest-query search, honest settings retry/persistence, selected-night hierarchy (122 criteria at -04). The repeat Claude assessment ran on 2026-10-18 as FINALIZATION_REVIEW §34 (assessment only; UX32-03/04 reproduced on the host) |
| AM-05 | Targeted changed-behavior/dependency tests and named probes per Task; full checks at G1/F26. Record attention items and continue safe independent work; report every done/not-done item at the end |
| Goal run | **Launched 2026-10-18** by the owner ("виконай цей план" with the brief [`CLAUDE_FINAL_PLAN_GOAL_IMPLEMENTATION.md`](prompts/CLAUDE_FINAL_PLAN_GOAL_IMPLEMENTATION.md), as an ordinary coding instruction in a Claude Code cloud session; `/goal` not used). Authorized: F01–F26/G1–G4, task commits and ordinary pushes to origin/develop; not main, force-push, signing secrets, owner data or publication. One lead/writer. Ledger: "Run ledger" below |
| Emulator/render execution | Owner clarification 2026-10-18: agents independently use/provision isolated emulators and render actual production widgets during authorized implementation. Inventory: emulator/ADB available in SDK, WHPX usable, no AVD/system image or connected device found. No emulator app run performed. Absence of a phone does not block host/emulator implementation; explicitly physical G2 rows remain |
| AM-04 | Familiar camera parameter hierarchy and optional AF/MF descriptive recording; F03/F06/F09/F12 and SP05. No new task, gate, calculation, hardware control or automatic metadata inference |
| AM-03 | CRUX-01–04 accepted: one plan-night phrase for Planner/Home (F18 A6, F17 A5), honest place-name switch persistence (F21 A6), a position fix never overwrites edited coordinates (F23 A6), no “Current position” label for a remembered position (F23 A7). 26 F tasks / 127 criteria. AM03-T decided B: the tab stays “Tonight”, the page title follows the plan's night (F17 A5; version -06). CRUX-05/06 not selected |
| Current document fingerprint | AM-05, P6-2026-10-18-08, SHA-256 `6ab29ddda5fbea5097a03df04338a4062d5060e133e8c85a075dab7c88e6b6f9`; §20 UX SHA-256 `80dbab0a0f484a461b78d9bd809dc75912bea1534b84fc7a2530e8a586afb7f6`. Earlier fingerprints in FINALIZATION_REVIEW remain historical; no new app acceptance claim |
| How it was prepared | The owner-invoked finalization workflow (`CULMINA_FINALIZATION_WORKFLOW_AND_PROMPTS_UK.md`, held outside the repository), recorded in [`FINALIZATION_REVIEW.md`](FINALIZATION_REVIEW.md): P1–P5 (Codex) §1–§27; the owner's D1–D9/UX-S answers (D1–D5 and D7–D9 = A, D6 deferred to the measured F26 sizes, UX-S = A); P6 §28 (begun by Codex, completed by Claude after Codex's usage limit); P7 §29 (a fresh Claude session: READY FOR OWNER APPROVAL, no blockers, six non-blocking follow-ups); P8 §30 |
| Git delivery | Baseline `2b467b8fd1478b6f8f0fcd48e887a88bc819ad8e` committed and pushed normally to origin/develop on 2026-10-18. Remote main unchanged; local main remains `322edbd`. Canonical origin is https://github.com/Buffur/Culmina.git. The goal handoff is in the subsequent documentation commit (resolve actual hash from Git); no F implementation or publication |
| UX-copy pass (owner, 2026-10-18) | Not a roadmap Task: the owner asked for the fixes of a UX-copy review of `lib/presentation`, except what F01/F12/F16/F17 cover and without glossary changes; committed on its own, without the uncommitted documentation cleanup. **Changed (wording only):** "session"/"location" left in the UI → plan, result, site, position; "Invalid" and the raw `Invalid site: …` → messages that say what to enter; the bootstrap failure names what failed; forecast loading/out-of-range wording shared in `WeatherText`; sentence case and frame types from `BlockText.type` in the block editor (the optional N2 of `docs/audit/10_UX_AUDIT.md`, otherwise optional F06 copy); "your" instead of "my"; candidates' "size in frame"; shorter Settings explanations (Off overheads still "left out", never zero); fallbacks. **Not changed:** `AppWords`, any stored value or calculation; "Moon gate"/"Cloud gate" (an owner decision); the plan labels "(no target)"/"(no rig)", which are written to the database. **Left to the roadmap:** the restore confirmation (F01), "Change in Planning Settings" (F12), Welcome (F16), the planner's no-site banner, its "Set site" button and "No night without a site", and Tonight's no-site prompt (the owner listed them as F17; they are planner/Home surfaces of F17/F18). Verification: see "Reusable validation evidence" |
| Current Stage | Roadmap **Stage A** (F01–F02) next, **not started**. Stage 12 closed (bounded closure PASS at `570581e`, [report](STAGE_12_13_CLOSURE.md)). Stage 13's open S13V-01 / TD-109 (the splash before Android 12) is now F02; S13V-02/03 are G2 rows. Stage 11 closed as superseded |
| Current Task | See "Run ledger". No task is VERIFIED while a mandatory device/owner row is open |
| Code baseline | `322edbd` (2026-10-18 UX-copy pass), now included in published develop baseline `2b467b8`; its earlier commits `b6e8c1e`/`1f10121` are documentation. Current schema/application inputs are unchanged by the preparation. The earlier apparent macOS registrant modification had no content diff and disappeared after staging |
| Remote | `Buffur/Culmina` (public). The Stage 12–13 closure read CI run [39042823307](https://github.com/Buffur/Culmina/actions/runs/39042823307) as `success` at `570581e` (GitHub REST API, 2026-10-17); not re-read since. Project page, privacy policy and source answered HTTP 200 (S13.2 evidence) |
| Schema | **v26** since F03 (`app_database.dart`, `schemaVersion`; 2026-10-18) |
| Toolchain | Flutter **3.47.4** (the CI's pinned version; Dart 3.13.3) at `C:\flutter`. Linux reproduction: WSL Ubuntu with the official 3.47.4 Linux archive at `~/ci/flutter` (S12.1). The 2026-10-18 run's cloud containers (two sessions): the same official archive at `/opt/flutter-sdk/flutter`, no Android SDK (`dl.google.com`, also the target of `maven.google.com`'s redirect, is refused by the network policy: 403, rechecked in the second session) |

**Stages 12–13, per Task** (detail in the [closure report](STAGE_12_13_CLOSURE.md) and `PROGRESS_HISTORY.md`):
- **S12.1 done** (`461e38c`; TD-104 and RD-17 resolved; remote CI passed after the owner-authorized push).
- **S12.2** optional (the owner's trademark check); not performed; not a gate.
- **S12.3 done:** repository renamed to `Buffur/Culmina`; Pages, the policy with the owner's contact, and the project index published (TD-099 resolved).
- **S12.4 decided (a)** (DECISIONS E.1): Play services location accepted with a GPL-3.0 §7 additional permission in `COMPLIANCE.md` and `README.md`; the About statement follows in S16.8 (C4).
- **S13.1 done:** the owner approved `R3-final` and the splash-animation concept ([`evidence/identity/round5/`](evidence/identity/round5/README.md)).
- **S13.2 done** (`b29ec34`): id `io.github.buffur.culmina`, label Culmina, channel and URLs renamed (TD-088, TD-093 resolved); device checks [PASS](evidence/S13_2_DEVICE_CHECKS.md). Follow-up TD-105.
- **S13.3 implemented** (`f89c7c3`, `570581e`): the R3-final launcher icon, the monochrome layer and the Android 12+ animated splash held for 1,000 ms (owner decision amending ID-6). [Evidence](evidence/S13_3_DEVICE_CHECKS.md). **Not met:** the static icon before Android 12 (S13V-01 / TD-109). **UNVERIFIED on a device:** reduced motion (S13V-02); final cold-start numbers (S13V-03); both carried to S17.5 (roadmap G2). S13V-01 is roadmap F02.

## Run ledger (full final-plan group, launched 2026-10-18)

States: IN PROGRESS · IMPLEMENTED-ACCEPTANCE-PENDING · VERIFIED · NEEDS ATTENTION · NOT STARTED.
Evidence: `evidence/finalization/<task>/README.md`. Commit hashes are recorded after the commit
exists (the row of the next task's commit carries the previous one).

| Task | State | Criteria | Verification (this run) | Carry / attention |
| --- | --- | --- | --- | --- |
| F01 (`8ad566d`; fix `2479bca`) | IMPLEMENTED-ACCEPTANCE-PENDING | A1–A3 PASS (TEST); A4/A5 host PASS, phone rows carried | 283 targeted tests + 23 source-rule tests, analyze clean, format/encoding ([evidence](evidence/finalization/F01/README.md)). CI run [39136907512](https://github.com/Buffur/Culmina/actions/runs/39136907512) at `52bf796` FAILED: the restoring screen's `EdgeInsets.all(24)` broke `secondary_consistency_test.dart` (1891 passed, 1 failed; not in F01's targeted set). Fixed by `2479bca` (spacing tokens); suite then green locally | REL-10 phone rehearsal (Recents during activation, literal outcome) at G2; U/visual in F25 |
| F02 | IMPLEMENTED; A2/A3 NEEDS ATTENTION | A1 PASS (TEST, fails on the old resources); A2/A3 not observable here | `app_identity_test.dart` ([evidence](evidence/finalization/F02/README.md)) | No Android SDK/emulator in this container (network policy refuses dl.google.com) |
| F03 (`55fef9b`) | IMPLEMENTED-ACCEPTANCE-PENDING | A1 PASS (OWNER: ADR-021 accepted); A2–A4 PASS (TEST: v26 migration, round trips, refusal); A5 NEEDS ATTENTION (no FITS sample) | [evidence](evidence/finalization/F03/README.md); full suite `+1968 ~2`, host E2E `core_loop` `+2` | FITS sample (F10 only) |
| F04 (`65233d8`, fix `33c6da5`) | IMPLEMENTED-ACCEPTANCE-PENDING | A1–A3 PASS (TEST); A4 synthetic PASS, real DNG/JPEG/HEIC run NEEDS ATTENTION (owner samples outside Git) | [evidence](evidence/finalization/F04/README.md); `+1134 ~1` affected areas | Owner runs `real_samples_test.dart` locally with `ASTROPLAN_METADATA_SAMPLES` |
| F05 (F05 commit) | IMPLEMENTED-ACCEPTANCE-PENDING | A1–A6 PASS (TEST: class-first panel, D8 from Tonight/planner/status/Welcome, Library save-only, Cancel, failed save, discard guard, missing-input reasons, cited example class); U/W at F25 | [evidence](evidence/finalization/F05/README.md); `+1353 ~2` affected areas, host E2E `core_loop` `+2`, `perf_scenarios` `+1`; density baseline recorded (3836 px at 412 px) | U renders and owner visual acceptance (F25); real phone JPEG (G2). F04 fix `33c6da5`: the review's rows for the F04 fields (a failure F04's targeted run missed) |
| F13 (`bdc9f6b`) | VERIFIED (host) | A1–A4 PASS (TEST/DOC: one Moon-up predicate, M1–M7, USNO, SI-015); A5 PASS (OWNER: ADR-022 N11/N12) | [evidence](evidence/finalization/F13/README.md); full suite `+1982 ~2`, host E2E `+2`/`+1` | Renders of the implemented D9 screens belong to F15/F17/F18 |
| F24 (`52bf796`, `1b07ce3`, `6215b50`) | IMPLEMENTED-ACCEPTANCE-PENDING | A1–A6 implemented and tested (A1: wall-clock sweep at five instants, then `TestClock`/`testEvening` defaults, repositories share the test's clock, a no-wall-clock rule; A2 all-tiles-fail test; A5 TD-002/020/025 rechecked) | [evidence](evidence/finalization/F24/README.md); full unit/widget suite `+1925 ~2` and host E2E `core_loop` `+2` after A1 | Roadmap: maintenance closure after F01–F23 (their later changes may need the rows rechecked) |
| F22 (`6215b50`) | IN PROGRESS | A3 partial: kill and v24 → v25 durability regressions PASS (TEST); v26 path after F03; A1/A2 not started | [evidence](evidence/finalization/F22/README.md) | A1 emulator process-death run (no Android SDK here); A1/A2 after F16–F19/F21 |
| F21 (`3a31019`) | IN PROGRESS | A6 PASS (TEST; U render at F25); A1–A5 not started (depend on F03/F14/F19 contracts) | [evidence](evidence/finalization/F21/README.md) | A1–A5 after ADR-021/F14/F19 |
| F23 (`4689a08`, `f25da48`, `fe33b7b`) | IN PROGRESS | A1, A5, A6, A7 PASS (TEST; U renders at F25; A5 phone row at G2); A3 PASS (every TD-031 subitem dispositioned; one release blocker to G1); A4 partial (no provider change); A2 NEEDS ATTENTION | [evidence](evidence/finalization/F23/README.md) | A2 needs the resolved Android dependency list (no Android SDK/Gradle repository here); final notice/policy alignment after F14/F21 per the roadmap |

## Pass checkpoint (2026-10-18, second session)

Interim disposition of the finite run: **PARTIAL_WITH_ATTENTION** if stopped here. Independent
eligible work still exists (F19 A2/A5, the early report of the current saved night), so the run
continues after this checkpoint. No F task is VERIFIED; no gate has started.

| Disposition | Items |
| --- | --- |
| Implemented, acceptance pending | F01 (phone rows at G2, U at F25), F02 (API 26–30 launch NEEDS ATTENTION), F24 (all six rows; closure after F01–F23) |
| In progress, partial | F03 and F13 (decision sheets only; owner acceptance), F21 (A6), F22 (A3 kill and v24 → v25), F23 (A1, A3, A5–A7; A2 NEEDS ATTENTION) |
| Not started — waiting on ADR-021 / F03 | F04–F12 (F10 also the FITS sample), F16 (via F05), F20 |
| Not started — waiting on ADR-022 / F13 | F14, F15, F17; F18 (also F06–F12) |
| Not started — eligible | F19 A2/A5 (next) |
| Not started — later | F25, G1, F26 (D6, owner signing), G2, G3, G4 |

## Next allowed action

The full final-plan run is in progress (launched 2026-10-18; see "Run ledger"). Continue the next
dependency-ready task of F01–F26/G1–G4 in the roadmap's order; record genuinely impossible-now
items in the attention register and continue independent work. A dated "Next" line in
`PROGRESS_HISTORY.md` or in an older report is not an instruction.

## Open owner decisions

Every RG and RD not listed here is decided, answered or lapsed: `POST_ROADMAP_PLAN.md` §7 and §8.

| ID | Decision | Needed before | Defined in |
| --- | --- | --- | --- |
| Start instruction | Full-plan launch command prepared, not yet submitted; alternatively a narrower named scope with Git/stop conditions | F01 | Roadmap §2, rule 1; prompts/CLAUDE_FINAL_PLAN_GOAL_IMPLEMENTATION.md |
| D6 (= CA-OD2) | APK packaging, chosen with the measured sizes (deferred there by the owner, 2026-10-18) | F26 (alias S17.6) | Roadmap §5; `POST_ROADMAP_PLAN.md` §5, "Shared rules for Stages 12–17" |
| ~~ADR-021, ADR-022 acceptance~~ | **Decided 2026-10-18**: both accepted in full (DECISIONS ADR-021, ADR-022) | — | Roadmap §5 and §8 |
| RD-02 | The TASK 0.3 holdovers: the ADK skill, `skills-lock.json`, `docs/archive/` (the dependency part done by S10.6) | Nothing (housekeeping outside the release) | `POST_ROADMAP_PLAN.md` §8 |
| RG-12 | Licence research, deferred by the owner on 2026-09-30: GPL-3.0 stays (the §7 additional permission of S12.4 is recorded) | Nothing scheduled | `POST_ROADMAP_PLAN.md` §7 |

## Attention register for the implementation run

The run is prepared, not launched: no actual task is classified as failed or skipped by this documentation update. During execution the lead records every genuinely incomplete/unverified item here, continues dependency-ready work and returns to an item only when its blocking input changes. Preserve severity and all mandatory criteria. The terminal report includes every F01–F26/G1–G4 disposition and distinguishes COMPLETE from PARTIAL_WITH_ATTENTION.

| Item / F-G-CHK | Implemented versus missing | Reason / attempt / evidence / severity | Affected dependencies | Resumption action / responsible input | State |
| --- | --- | --- | --- | --- | --- |
| Git push (all tasks) | Commits are made on local `develop` and reach origin only when the owner pushes them: the first session's four (through `52bf796`), and the second session's seven (`2479bca`–`fe33b7b`, handed over as a git bundle and pushed by the owner on 2026-10-18; origin/develop = `fe33b7b`, checked) | `git push -u origin develop` → HTTP 403 "Claude doesn't have GitHub access to Buffur/Culmina for your organization" (first session twice; second session twice, 2026-10-18). GitHub reads (CI runs, job logs) work. Severity: high (unpushed work is lost if the container is reclaimed; remote CI cannot run on it, and develop's CI stays red until `2479bca` is pushed) | Every task's push; G1/F26 remote CI | Owner reconnects GitHub (claude.ai/connect-github) and/or installs the Claude GitHub App on Buffur/Culmina; until then the owner pushes each session's commits (bundle) | OPEN (workaround in use) |
| F03 A1 → F04–F12 (dependent persistence/science) | ADR-021 decision sheet written with recommendations and vectors | Owner local acceptance required by roadmap §5 before dependent implementation; asked 2026-10-18 | F03 A2–A4, F04–F12, F16 (via F05), F18–F20 parts | Owner accepts (or amends numbered items of) `ADR_021_DECISION_SHEET.md` | **CLOSED 2026-10-18**: accepted in full (DECISIONS ADR-021) |
| F13 A1–A5 → F14/F15/F17/F18 night parts | ADR-022 decision sheet written | Owner local acceptance required (roadmap §5) | F13–F15, F17, F18 A3/A6 | Owner accepts `ADR_022_DECISION_SHEET.md` | **CLOSED 2026-10-18**: accepted in full (DECISIONS ADR-022) |
| F03 A5 / F10 (FITS sample) | Reader work possible only after F04 | No real astro-camera FITS in the repository or this container (searched 2026-10-18); public samples not licence-checked | F10, F07 FITS branch, G1 (unless owner deferral) | Owner provides a local FITS sub-frame (kept out of Git) or names a licensed fixture | OPEN |
| F23 A2 (Android notices) | The licence page lists the Dart packages; the native notices are not yet added | The Android libraries the build actually bundles (AndroidX, Kotlin coroutines, Play services location, their versions) come from Gradle's resolved dependency graph, which needs `dl.google.com`/`maven.google.com` (refused here, 403). A list guessed from plugin build files would not prove "match the build dependencies". Severity: medium (attribution completeness, release-relevant) | F23 close; G1 notices row | In an environment with the Android SDK: resolve `./gradlew :app:dependencies` (release runtime classpath), add the notices, compare against the licence page | OPEN |
| TD-031 row 9 / G1 (`material_ui` retracted) | Found and recorded by F23 A3; the lock file is unchanged | `pubspec.lock` pins the retracted `material_ui` 1.3.0 (transitive via `go_router`, `cupertino_ui`); `flutter pub upgrade material_ui` would move it to 1.7.0, a dependency change needing the full gate, an Android build and visual acceptance. Severity: release blocker | G1 dependency/notice rows; F26 | At G1, with an Android build: upgrade or bound it to the smallest non-retracted version, run the full gate and U renders | OPEN |
| F02 A2/A3; every native Android/emulator row (G1 REL-02, F26, F22 process death) | F02 resources fixed and host-tested; no native build, launch or capture | The container has no Android SDK and cannot get one: `dl.google.com` (SDK repository; `maven.google.com` redirects there) is refused by the network policy (403, 2026-10-18). Remote CI builds no Android. Severity: blocks F02 VERIFIED and native gate rows, not host implementation | F02 close; G1 REL-02; F26 | Run in an environment with the Android SDK (owner machine with the existing SDK, or a cloud environment whose network policy allows dl.google.com): API 26–30 emulator launch capture, Android 12+ animation-off observation | OPEN |

## Owner actions outstanding

These block the release, not documentation or planning.
- **Agents handle emulator/renders independently:** discover existing SDK tools even when missing from PATH; reuse/create an isolated AVD and provision minimal required tooling/image where permitted; generate actual-widget host renders and emulator captures. See the goal prompt's execution procedure. These are implementation/testing actions, not owner-only phone prerequisites.
- **A physical phone** for the carried device rows (G2, alias S17.5): S13V-02, S13V-03, the Stage 11
  matrix's phone and human rows (`STAGE_11_MATRIX.md`, `STAGE_11_DEVICE_RUNBOOK.md`), S2V-06, S3V-08
  and S10V-04's profile run. Emulator evidence does not replace a physical-phone or human check. An
  API 26–30 launch (emulator or device) is needed for F02 (S13V-01's correction).
- **A FITS sample** (F10, alias S14.5; requested at F03's start). Optional: a DSLR/mirrorless JPEG or RAW (useful for the DSLR
  workflow check) and PNG or AVIF samples. The owner's DNG, JPEG and HEIC samples stay outside Git.
- **The release keystore and `android/key.properties`** (owner-managed, trap 21; F26, alias S17.6). The Play
  upload key and the AAB are deferred (GitHub-only distribution).
- **Release-signed install / signature mismatch:** use an isolated clean profile where possible. Never automatically uninstall an owner app. Before any explicitly owner-authorized uninstall, verify an independent backup and complete the named rehearsal (F26 A5/G2). The historical `.s2check` package observation (S13V-04) is not current install/uninstall authorization.
- The owner's visual review of UI Tasks; ADR-021/022 local acceptance; D6 from actual measurements;
  the go/no-go (G3) and separate GitHub Release publication authorization (G4). When the owner submits
  the full-plan launch command, ordinary task commits and pushes to develop are authorized for that
  finite run; main, force-push, signing secrets and owner-data operations are not included.
- Optional: S12.2.

## Known blockers and open risks

- **S13V-01 / TD-109** (the static splash before Android 12): open, scheduled as F02.
- **Open release defects, scheduled and not fixed:** TD-106 (Critical: an invalid SQLite payload can
  become the live database) → F01 and G2 (aliases S14.3, S17.5); TD-107 and TD-108 (High) → F09 and
  F06 (aliases S14.10, S14.6). Every open item: `TECH_DEBT.md`, "Open items".
- **Evidence gaps:** S6.E UNVERIFIED (no independent participant; owner-accepted); "responsive on
  representative hardware" UNVERIFIED until S10V-04's phone run; the Stage 11 phone and human rows
  (S11.6) are carried into S17.5.

## Carried items

| Item | State | Destination |
| --- | --- | --- |
| S13V-02, S13V-03 | Reduced motion and final cold-start numbers, UNVERIFIED on a device | S17.5 (G2) |
| S11.6, S11.7 | The phone, human and owner rows of `STAGE_11_MATRIX.md`; readiness | S17.5, S17.7 (G2, G3) |
| S10V-04 | `integration_test/perf_scenarios_test.dart` on a physical phone, profile mode | Stage 11 matrix → S17.5 |
| S1.5, S1.11 device checks; S2V-06; S3V-08 | Device rechecks (an older build over a newer database; TalkBack; a non-seekable provider and a real backup's preview cancel; the corrected Stage 3 flow) | Stage 11 matrix → S17.5 |
| S6.E | The five-second test with an independent participant: UNVERIFIED, owner-accepted gap | Stays a recorded gap (proposal: W rule) |
| TD-072 (S3S-03, deferred by the owner) with S3F-01; S3F-02 (a note on TD-071) | Open | S14.9 (F08, F10) |
| TD-074 | Open | S14.12 (F12) |
| Other open TD items | Open | `POST_ROADMAP_PLAN.md` §5, "Open technical-debt items" |

## Reusable validation evidence

Per `CLAUDE.md`, Verification Policy V3: reuse while the relevant inputs are unchanged. Earlier rows
(S12.1's Linux and Windows gates back to Stage 7's probes) are kept in `PROGRESS_HISTORY.md` as the
closing evidence of their Stages; later gates supersede them.

| Evidence | Ran at | Still valid because |
| --- | --- | --- |
| **Current develop CI PASS**, run [39124553324](https://github.com/Buffur/Culmina/actions/runs/39124553324) | `2b467b8fd1478b6f8f0fcd48e887a88bc819ad8e` | GitHub REST API confirmed completed/success on 2026-10-18 after the baseline push. Reusable for goal-handoff commit `2134a2b` and this evidence-record commit: subsequent changes are Markdown only, with no application/test/dependency/tooling/platform change. Full-gate success is not F-task, device, visual or release acceptance |
| **Remote CI PASS**, run [39146586823](https://github.com/Buffur/Culmina/actions/runs/39146586823): the full gate on `ubuntu-24.04`, Flutter 3.47.4 — Encoding, Format, Analyze, Test (1,928 passed, 2 skipped), host E2E `core_loop` (2) and `perf_scenarios` (1) | **`fe33b7b`** (2026-10-18) | Read from the GitHub API and job log on 2026-10-18. Covers every code input to `fe33b7b`. Not an Android build (the CI builds none). The earlier run 39136907512 at `52bf796` failed on the F01 spacing regression fixed by `2479bca` |
| **Remote CI PASS**, run [39042823307](https://github.com/Buffur/Culmina/actions/runs/39042823307): the workflow's gate on `ubuntu-24.04`, Flutter 3.47.4 | **`570581e`** | Read by the Stage 12–13 closure. Covers `570581e` only: `322edbd` (the UX-copy pass) changed `lib/`, `test/` and `integration_test/`, so this historical run does not cover the current code; the local gate row below covers it. The earlier apparent macOS registrant modification had no content diff at delivery |
| **Local full quality gate PASS** (Windows, Flutter 3.47.4; 1,852 tests passed, 2 skipped; host E2E `core_loop_test.dart` and `perf_scenarios_test.dart` passed) | The UX-copy pass's code (run on the working tree just before its commit, 2026-10-18) | Its `lib/`, `test/` and `integration_test/` are what that commit holds; valid while they stay unchanged. Not a device, CI or visual check: the new wording is not yet seen on a phone or by the owner |
| **Local full quality gate PASS** (Windows; 1,851 tests) | `f89c7c3` (S13.3) | The last local full gate. `570581e` then changed the splash, verified by `app_identity_test.dart`, `startup_mark_test.dart`, a release build and a phone recording (the owner's targeted-test instruction); the CI row above covers `570581e` |
| **S13.2 device checks PASS** ([evidence](evidence/S13_2_DEVICE_CHECKS.md)): M1/M4 with a DNG and a HEIC on `io.github.buffur.culmina.s2check`; a backup made on the old id restored on the new id (9 tables equal, preferences restored) | `b29ec34` | Device evidence for those flows until they change |
| **S13.3 phone checks** ([evidence](evidence/S13_3_DEVICE_CHECKS.md)): the Android 12+ splash; first-frame median 272 → 290 ms (the non-held build) | `f89c7c3` | Valid for the first frame under V3 (closure report, S13.3 (4)); the held second's numbers are S13V-03 |
| Local real-sample metadata test PASS (DNG, JPEG, HEIC) | After S3.V4 (`2447962`) | Environment-dependent (the owner's sample folder). Valid while the metadata readers are unchanged; not re-checked at this cleanup |
| Device checks M1–M4 (the owner's Xiaomi 14T Pro, `.s2check`) | `79f392c`, `237c55f`, `2b045eb` | Valid for the flows covered until they change; M1/M4 repeated under the new id by S13.2 |

## Stage status

Vocabulary: Not started · Planning · In progress · In validation · Complete.

| Stage | Name | Status | Opened | Closed | Stage validation |
| --- | --- | --- | --- | --- | --- |
| 0 | Refinement Baseline | Complete | 2026-09-25 | 2026-09-25 | Self-review against the Stage 0 prompt's §22 checklist (`PROGRESS_HISTORY.md`, "Validation status"). The prompt asks for no separate validation session |
| 1 | Verified Fixes & Clean Baseline | Complete (owner waiver) | 2026-09-25 | 2026-09-26 | **Did not pass**: independent validation failed at `4e653fb` (TD-059–TD-062, fixed), then at `c99bd7f` (TD-063, X2). The owner closed the Stage anyway: TD-063 goes to Stage 8; X2 and W1 are carried |
| 2 | Metadata Foundation | Complete (owner waiver) | 2026-09-26 | 2026-09-26 | **Did not pass independently**: it failed at `79f392c` (fixed, `ffaff57`) and at `5d8bdbb` (S2R-01/TD-067; fixed by S2.V4/S2.V5, `d8e792c`/`435b3ce`). The owner then waived a third validation (E.1, "Stage 2 closed by the owner") |
| 3 | Metadata → Equipment / Device Import | Complete | 2026-09-26 | 2026-09-27 | **Fresh-session final sign-off PASS** at `92ebf2a` (`STAGE_3_FINAL_SIGNOFF.md`; S3F-01, S3F-02 non-blocking). Before that: FAIL at `387e54b`; a same-chat technical PASS at `d5e2b60` (`STAGE_3_REVALIDATION.md`); a fresh-session FAIL at `74026ca` (`STAGE_3_SIGNOFF_VALIDATION.md`, fixed by S3.V7/S3.V8). Device recheck S3V-08 unverified |
| 4 | Product Flow & Information Architecture | Complete | 2026-09-27 | 2026-09-27 | **Final, bounded validation PASS** at `09a7f06` (`STAGE_4_FINAL_VALIDATION.md`; the owner's seven questions; run in the authoring session at the owner's request, disclosed). Before that: **FAIL** at `adb5d95` (`STAGE_4_VALIDATION.md`, S4V-01), corrected by S4.V1. The fresh-session revalidation **FAILED** at `5ad69c4` (`STAGE_4_REVALIDATION.md`): S4R-01 and S4R-02 blocking, S4R-03 and S4R-04 low, all addressed by S4.V2 (the owner's R2 + D1). S4.V3 bounded the final validation, which then passed. S4V-02 is non-blocking and S4V-03 unverified |
| 5 | Design System Foundation | Complete | 2026-09-27 | 2026-09-27 | **FAIL** at `8a6c5d8` on one narrow blocker, S5V-01; S5.V1 (`178acbe`); **revalidation PASS** at `178acbe` ([report](STAGE_5_VALIDATION.md); same chat at the owner's request, disclosed) |
| 6 | Core Planner Redesign | Complete | 2026-09-27 | 2026-09-28 | **BLOCKED** at `6b50369` on one blocker, S6V-01 / TD-082; S6.V1 (`da4c53d`); **V5 revalidation PASS** at `da4c53d` ([report](STAGE_6_VALIDATION.md); same chat at the owner's request, disclosed). S6.E UNVERIFIED, a gap the owner accepted |
| 7 | Data Entry & Automation | Complete | 2026-09-28 | 2026-09-29 | **BLOCKED** at `d13fdab` (fresh-session independent validation): S7V-01 / TD-083 and S7V-02 / TD-084; S7.V1 (`46e7688`) and S7.V2 (`d28f5a8`); **V5 revalidation PASS** at `21e9cb1` ([report](STAGE_7_VALIDATION.md); same chat at the owner's request, disclosed) |
| 8 | Sessions / Execution / Actuals / Logbook | Complete | 2026-09-29 | 2026-09-29 | **PASS** at `690b94a` (fresh-session independent validation, [report](STAGE_8_VALIDATION.md)); no blocker; S8V-01 to S8V-03 recorded as TD-085 to TD-087 (non-blocking; fixed 2026-09-29) |
| 9 | Secondary UX & Product Polish | Complete | 2026-09-29 | 2026-09-30 | **S9.1–S9.9 PASS** at `8e53479` (fresh-session independent validation, [report](STAGE_9_VALIDATION.md)); no blocker; S9V-01 to S9V-03 recorded as TD-089 to TD-091 and fixed (`0f09608`). S9.10–S9.12 **deferred by the owner** 2026-09-30 (the logo and the identity were later decided by RA.D and S13.1; S9.11's licence question, RG-12, stays deferred) |
| 10 | Performance & Application Size | Complete | 2026-09-30 | 2026-09-30 | **PASS** at `3cb67be` (fresh-session independent validation, [report](STAGE_10_VALIDATION.md)); no blocker; S10V-01 to S10V-03 fixed, S10V-04 carried to Stage 11 |
| 11 | Full Validation & Beta Readiness | **Closed — superseded by Stage 17** (G3): S11.1–S11.5, S11.C1, S11.C2 done; S11.6 → S17.5, S11.7 → S17.7 | 2026-09-30 | 2026-10-17 | No readiness claimed; the final validation is S17.7 |
| 12 | Release foundation | Complete | 2026-10-17 | 2026-10-17 | **Bounded closure PASS** at `570581e` ([report](STAGE_12_13_CLOSURE.md)); S12.2 optional, not performed; S12V-01/02 follow-ups (both documentation, both since corrected: §8's RD-17 row and this table) |
| 13 | Identity: Culmina | Superseded by the approved roadmap (2026-10-18): S13V-01 / TD-109 → **F02**, S13V-02/03 → G2 | 2026-10-17 | — | S13.1, S13.2 PASS; S13.3 all but (2) before Android 12; reduced motion UNVERIFIED (S13V-02) ([report](STAGE_12_13_CLOSURE.md)) |
| 14–17 | Capture Plan, night conditions, screens, release | Superseded by the approved roadmap (2026-10-18) before starting; their Task IDs are aliases (roadmap §4) | — | — | — |

**Approved final completion roadmap** ([`FINAL_COMPLETION_ROADMAP.md`](FINAL_COMPLETION_ROADMAP.md), approved 2026-10-18): one row per roadmap Stage; Task completion rows go under "Current state".

| Roadmap Stage | Scope | Status | Tasks done |
| --- | --- | --- | --- |
| A | Protect existing data and startup: F01, F02 | In progress (run launched 2026-10-18); F01 implemented, acceptance pending | 0 / 2 verified |
| B | Capture Plan entry and calculations: F03–F12 | Not started | 0 / 10 |
| C | Night conditions, screens and saved records: F13–F25 | Not started | 0 / 13 |
| D | Qualify and deliver one signed GitHub release: G1, F26, G2, G3, G4 | Not started | 0 / 1 Task, 0 / 4 gates |

## How to update this file

- **Replace, don't append.** "Current state" and "Next allowed action" describe now. When they
  change, replace the old text; move anything worth keeping to `PROGRESS_HISTORY.md` verbatim. Do
  not keep superseded entries here.
- **At the end of every Task:** one line under "Current state" (Task, commit, finding IDs
  resolved, verification per the policy or the reused evidence); update the next Task; update any
  RG or RD it touched (resolved: date, and where the decision is written); update "Reusable
  validation evidence" if a check ran or its inputs changed.
- **At every Stage boundary:** update the Stage status table (dates, validation result in one
  line, with a link to the report); set the next allowed action; refresh "Known blockers" and
  "Carried items"; drop the closed Stage's detail from "Current state".
- **Registers live elsewhere:** RG and RD in `POST_ROADMAP_PLAN.md` §7–§8, TD in `TECH_DEBT.md`;
  this file lists only what is open and blocks or schedules work.
- **Validation results** go in the Stage's `STAGE_N_*.md` report; this file gets one line and the
  link. Record evidence reuse in one line (what, where it ran, why it still holds).
- Keep it short enough to read at the start of every session.
