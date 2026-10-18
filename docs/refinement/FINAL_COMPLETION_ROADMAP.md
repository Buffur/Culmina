# Culmina — Final completion roadmap

**Status: APPROVED BASELINE WITH OWNER-AUTHORIZED AMENDMENTS AM-01/AM-02/AM-03/AM-04 (2026-10-18). Version: P6-2026-10-18-07. Active execution queue: F01–F26, G1–G4. P8 approved base -02; explicit owner instructions authorized AM-01 (-03), AM-02 (-04), AM-03 (-05) and AM-03's Home title choice AM03-T = B (-06). AM-04 (-07) records the owner's familiar capture-parameter hierarchy. The owner subsequently authorized committing and pushing the prepared project to develop; this does not start application implementation or authorize publication.**



**AM-04 — familiar camera parameters (owner, 2026-10-18):** for Phone/DSLR, show exposure, count, ISO, WB and optional AF/MF recording in the basic block editor, with applicable frame type/filter. Choose ISO versus gain from the explicitly selected rig class; do not require a technical ISO/GAIN selector in each block. Binning belongs in applicable astro-camera Details; preserve recorded values and calibration identity. Accept familiar fractional seconds as well as decimal seconds, storing canonical seconds. Focus mode is an optional descriptive record, not numeric focus, camera control or a calibration-match dimension. F03/F06/F09/F12 and SP05 carry the exact changes; no new task or gate. See FINALIZATION_REVIEW §37 and DECISIONS E.1 AM-04.

**AM-03 — four findings of the repeat review, owner 2026-10-18:** the owner selected CRUX-01–CRUX-04 of FINALIZATION_REVIEW §34 for the plan and asked for the Home title choice to be proposed separately. Incorporated as F17 A5 and F18 A6 (one plan-night phrase: “tonight” only for the current night; CRUX-01), F21 A6 (the place-name switch's honest persistence; CRUX-02), F23 A6 (a position fix never overwrites coordinates edited after the tap; CRUX-03) and F23 A7 (a remembered position is not labelled “Current position”; CRUX-04). These are accepted future outcomes, not implementations; their HOST evidence stays as recorded in §34. The Home page title was the separate owner choice **AM03-T** (§5); the owner chose **B** the same day (version -06): the tab label stays “Tonight” and the page title shows “Tonight” for the current night and the plan's night otherwise. CRUX-05/06 were not selected and stay proposals. Mapping: §4 AM-03 and FINALIZATION_REVIEW §35.

**AM-02 — five adjacent UX/function actions, owner 2026-10-18:** the owner explicitly requested that the five proposed actions in FINALIZATION_REVIEW §32 be included in the plan and requested a repeat Claude assessment prompt. Incorporate UX32-01–05 into F06/F18/F21/F24 below; these are accepted future outcomes, not confirmed fixes or newly executed reproductions. Settings retain the latest edited values visibly unsaved on failure, with retry of the newest full configuration and explicit persistence/restart consistency. Further findings from the requested assessment remain proposals until selected. Prompt: [CLAUDE_UI_UX_REVIEW_AM02.md](prompts/CLAUDE_UI_UX_REVIEW_AM02.md), assessment only; preparing it does not dispatch another agent.

**AM-01 — Capture Plan simplicity and supporting UX, owner 2026-10-18:** the owner accepted the preceding seven-point assessment and requested these plan corrections. Capture Plan is the primary simple workflow: enter intended frames, see estimated integration/total duration/storage and ideal relative stacking gain, then save. No advanced scientific input, graph or detailed breakdown is required just to understand the estimate; preserve working domain calculations and make their assumptions available in Details. “Approximate SNR” is represented honestly by existing relative stacking gain against one comparable frame, not invented absolute physical SNR. Exact changes and aliases are in §4 AM-01 and FINALIZATION_REVIEW §31; the five adjacent §32 actions were subsequently accepted by AM-02; their original evidence remains CODE/potential as recorded. Further assessment adds no scope automatically.

All normative project paths are relative to the repository root; Markdown links resolve relative to their containing document. Visual references are indexed in [docs/Examples/README.md](../Examples/README.md), including the owner's time-slider image. They guide hierarchy/interaction only, never replace Culmina science, provider contracts or accessibility. Captured historical logs may retain their original host paths; those are not executable project dependencies.

**P6 documentation finalization:** owner response on 2026-10-18: `D1–D5, D7–D9: A; D6: після вимірювань; UX-S: A` [“D6: after measurements”]. P6 was started by Codex, whose usage limit ended its session right after it wrote the interrupted intermediate `P6-2026-10-18-01`; Claude completed P6 at the owner's instruction («продовж його роботу», “continue its work”), as recorded in FINALIZATION_REVIEW §28. The accepted semantic choices and bounded optional refinements are recorded in §5 and DECISIONS E.1. This incorporates P1–P4's COV-01/02/03/05/06/07 and TF-01 corrections without adding F tasks or deleting approved outcomes. The underlying audits and P1–P5 report remain evidence, not execution queues. Layout sketches are proposals; final implementation visual acceptance remains required.

**Approval boundary:** P8 approved base -02; explicit owner instructions authorized AM-01, AM-02 and AM-03 as documentation amendments. P7's earlier verdict applies to -02, not silently to changed criteria. Verify AM-01 and its affected references/checks under V5–V7; do not restart a comprehensive audit. A separate start still names the authorized finite implementation scope. No commit, push, signing-secret access, owner-data operation or publication is authorized here.

One execution baseline: **approve → implement sequentially → verify the named acceptance criteria → finish**. This document consolidates approved remaining work; it does not authorize application changes today. The approved base replaced the remaining-task queue in `POST_ROADMAP_PLAN.md` (§5, Stages 12–17). Original IDs remain traceability aliases, not a second queue. No further global planning or comprehensive roadmap review is required.

## 1. Assessment and evidence boundary

The existing application already supports planning, equipment, targets, saved snapshots and post-session results. The remaining work is to correct verified defects, finish previously approved Capture Plan and night-condition behavior, connect it to the existing screens, and qualify a signed GitHub release. Previously approved additions such as the Moon calendar, WB record and AstroBin CSV remain in scope; this consolidation adds no product capability.

The original plan's main problems are distributed acceptance clauses, a critical restore fix mixed with schema design, broad maintenance grouping, and historical status mixed with the active queue. Audit 09 amendments M1–M16 are **already incorporated**, not new proposed research. This document consolidates them, separates restore safety from v26, makes dependencies explicit, and gives every remaining outcome a bounded test.

**Inspected repository baseline:** original P1–P8 baseline HEAD `1f10121` / application `570581e`; current AM-01 inspection HEAD `322edbd` (owner UX-copy pass), schema v25. The pre-existing change to `macos/Flutter/GeneratedPluginRegistrant.swift` is outside this documentation task. P2 ran isolated observation tests and P3 ran static proposal-render QA, as distinguished in FINALIZATION_REVIEW §14–§24. P4 was a separate read-only Codex feasibility pass, explicitly not Claude or human validation. No production implementation, device/build/live-provider acceptance or remote CI refresh was run for P6. Historical passing evidence below is recorded evidence, not a new execution claim.

- Stage 12 is closed by [the bounded closure record](STAGE_12_13_CLOSURE.md). S12.1/3/4 and S13.1/2 are complete. S12.2 is optional, unperformed, and not a release gate.
- Stage 13 remains blocked by S13V-01 / TD-109. S13V-02 and S13V-03 remain named final-device rows. Naming, artwork, repository rename, published policy and accepted Play-services decision are not reopened.
- Current source confirms TD-106, TD-107 and TD-108 mechanisms. TD-109's incompatible resource reference is present; its device effect is not newly reproduced here.
- Old tests and successful stages are reused under CLAUDE.md V3; they do not establish correctness of future changes or prove human comprehension.

**Authority:** the owner's current instruction; this approved roadmap and its explicit amendments; `PROGRESS.md` for current status; `PRODUCT_DIRECTION.md` and accepted decisions in `DECISIONS.md`; CLAUDE.md V1–V8 and relevant engineering guardrails. Source code establishes actual behavior. Historical inputs: [original remaining plan](POST_ROADMAP_PLAN.md#stages-1217--culmina-release-roadmap-rap-2026-10-17), [audit 09](../audit/09_COMPREHENSIVE_AUDIT.md), [AUD dispositions](STAGES_12_17_AUDIT_AMENDMENTS.md), [readiness corrections C1–C6](STAGES_12_17_READINESS_REVIEW.md), [approved requirements](research/RA_D_ROUND2_PACKAGE.md), [UX audit 10](../audit/10_UX_AUDIT.md) (critical fixes applied as UXA-C1–C5).

## 2. Execution rules and shared acceptance

1. **Approval and start are separate.** P8 approved base -02; the explicit owner instructions amend it as AM-01/AM-02. Approval/amendment freezes the named scope. An explicit start instruction may authorize one task or the entire bounded sequence. Within an authorized sequence Claude advances in dependency order without requesting repeated task-start permission. Otherwise the existing one-task start rule applies. An implementation session does not start today.
2. Execute the numbered sequence. Resolve ordinary implementation details inside the task. A missing FITS sample pauses F10 only; continue independent tasks and return before G1. Other unmet dependencies pause only affected tasks. Stage labels organize work; they do not create artificial prerequisites beyond those listed.
3. **Change control:** amend only the affected task for a demonstrated blocker, contradictory repository evidence, omitted necessary dependency, inability to meet an approved requirement, or an explicit owner change. Record the reason and affected criteria. Non-blocking findings go to a short follow-up list; speculative expansion stays excluded. No general re-audit, validation-of-validation or new exploration stage.
4. Apply CLAUDE.md **V1–V8**, rather than a second verification policy. `H` below means high-risk: full `dart run tool/check.dart` on the task's final code plus named domain probes. `S` means shared behavior: affected regression areas, analysis, changed-file format and encoding; full gate only where explicitly stated or the affected set cannot be bounded. A broader valid run satisfies its constituent checks. A later task invalidates only relevant evidence. Do not rerun unchanged checks for a newer timestamp.
5. Each task closes with a compact record: task ID; criterion-by-criterion result; changed files; commands and results or justified evidence reuse; baseline/environment; limitations; next eligible task. A task with mandatory pending device/owner evidence is **implemented, acceptance pending**, not complete. Update `PROGRESS.md` and only registers invalidated by the change. Original IDs need aliases, not duplicate completion records.
6. Preserve planning-first behavior, offline core, immutable saved snapshots/results, Save/Discard/Cancel, user-confirmed proposals, canonical scientific units, unknown-as-unknown, metadata provenance, and existing valid calculations. Never reset a newer database, silently replace real inputs with examples, or remove working behavior to pass acceptance.

**U — applies to every changed UI surface.** Test at 412 px width, 100% and 200% text, light/dark/field themes; include the changed editor/dialog, keyboard and error states. All controls and primary actions must be reachable; labels must not clip. Use real fonts and Material glyphs in host renders, or native captures; placeholder glyphs are not typography evidence. Run affected accessibility checks and obtain the existing owner visual acceptance. Apply reduced motion through `AppMotion`. For the block editor specifically use **412 × 915, 200%, keyboard open**; if the alert dialog cannot satisfy this, move it to the site editor's full-screen route pattern (a persistent primary action and a discard guard; block labels follow F06 A7, `site_editor_screen.dart`). The code has no full-screen dialog, so that route is the existing pattern (UXA-C4). Before F05 and after each Capture Plan UI task, record reference-plan scroll extent at 412 px/100% (three light blocks with a filter change, darks, flats, bias), section deltas and the owner's review; this is a density record, not an invented maximum length.

**W — four finite workflow checks, accumulated across tasks and closed by F25/G2.** (1) Phone manual/photo-assisted setup; (2) DSLR proposal/edit/cancel; (3) astro-camera metadata/calibration; (4) returning multi-night save/result/progress. Record each screen, action, backtrack/dead end, external value lookup, and visible fit/Unknown/relative-gain explanation. An agent or owner may perform the functional walkthrough. Human comprehension is claimed only from a person other than the builder. The previously accepted S6.E independent-participant gap remains **UNVERIFIED** when no participant exists; it does not become a new mandatory recruitment project.

## 3. Ordered implementation

### Stage A — Protect existing data and startup

**Objective:** remove the current restore risk and finish the already accepted splash. No ADR-021, FITS or later packaging prerequisite blocks this stage's core fixes.

### TASK F01 — Reject unsafe restores and recover interrupted activation

**Priority / status:** P0 data/startup safety; NOT STARTED. No F acceptance is passed by documentation.

**Sources / decisions:** S14.3(7-9), TD-106/105, CA-01/16/23, M1, AUD-01, UXA-C1. Accepted choices (§5): D2 and D7 = A; UX-S R1.

**Problem / Current State:** S14.3 safety slice; TD-106, CA-01/16/23, AUD-01. `backup_archive.dart` accepts a SQLite header/version; `backup_staging.dart` changes preferences and swaps files before production open. The confirmation promises an inaccessible safety copy.

**Required Outcome:** only a usable, supported candidate becomes live; failure preserves a coherent original database/preferences pair and reachable recovery instructions.

**Implementation Scope:** `lib/data/backup/`, production connection in `lib/data/database/app_database.dart`, startup in `lib/main.dart`, `backup_viewmodel.dart`, settings `backup_section.dart`. Validate/migrate an isolated candidate through the production lazy/background connection before changing live state. Run that check when the file is picked, before the confirmation, so an unusable file is refused at once; activation repeats it (UXA-C1). Include WAL/SHM handling and interruption recovery. Repair the confirmation and TD-105's current-app/version and singular/plural wording without adding an archive field. Accepted D2 supplies recovery/retention; D7 supplies immediate confirmation/activation. Core validation/outcome safety remains independently implementable; no further vote on these selected options. The start that applies or refuses a staged restore says so once and clears the staged state (UXA-C1).

**Acceptance Criteria:** A1 valid ZIPs containing truncated SQLite, missing expected schema, and unsupported/newer versions are refused at pick time, before the confirmation and before live DB/preferences change; activation repeats the check. A2 a real supported old database migrates, passes integrity, applicable FK checks and expected repository reads, and restores identifiable content/settings. A3 interruption at each activation boundary recovers to a coherent old or fully validated new state; restart never leaves mismatched preferences. A4 Confirmation states recoverable actions truthfully and follows accepted D2/D7: no new Undo control, one newest safety copy retained with deterministic interruption recovery; prune only after safe successful activation and never the pending/only recovery copy. Back up first runs existing backup and returns to the same candidate confirmation only after success; backup failure/Cancel never activates. Restore and restart immediately enters a non-editable activation path, with no edit gap, including on returning from Recents. An activation refusal/failure preserves a coherent recoverable state. A5 The new running instance reports the actual durable applied/refused/recovered outcome once and clears consumed staging; Settings never shows a nonexistent pending restore. Pre-activation refusal says current data is unchanged; interrupted recovery reports the coherent selected old/new state rather than falsely claiming unchanged data after a new state committed.

**Layer responsibility / files:** `lib/presentation/screens/settings/backup_section.dart`; `lib/presentation/viewmodels/backup_viewmodel.dart`; `lib/data/backup/backup_archive.dart`; `lib/data/backup/backup_staging.dart`; `lib/data/database/app_database.dart`; `lib/main.dart`. Presentation owns interaction/labels; existing ViewModels serialize state; domain owns the applicable pure rules; data owns compatible persistence/provider/format behavior. Use only the relevant listed layers, never calculations in widgets.

**UX/state contract:** §9 incorporates SP09, with exact labels/visible-versus-detail hierarchy, applicable empty/loading/error/Unknown/conflict and draft/saved/dirty states, Save/Back/Cancel and outcome feedback. U/W apply; proposals do not count as runtime or owner visual acceptance.

**Data/science invariant:** §8 CP/NC and shared rule 6 apply where relevant: preserve canonical units, Unknown, reviewed local proposals and original history; no provenance or result is invented.

**Verification:** H; extend `test/data/backup/backup_restore_test.dart` with real SQLite fixtures and failure injection, production-open refusal tests, confirmation widget tests, pick-time refusal and outcome-message widget tests (applied, refused, interrupted); literal instruction/device row in G2. Header-only stubs cannot prove old-database recovery.

**Criterion checks:** §7 `CHK-F01.A1…An` binds every A to a meaningful check and evidence layer; all start PLANNED.

**Stop condition:** close only after every A has evidence or an explicitly named permitted carry; mandatory pending evidence means implemented, acceptance pending. Stop at unresolved local acceptance/resource or the end of authorized scope; continue only independent authorized tasks. No automatic next-task start outside that scope.

**Completion Evidence:** fixture provenance, preserved-content comparisons, failure/restart matrix and final gate result; device row explicitly carried to G2 if pending.

**Dependencies / Risk:** none for validation, activation safety and the outcome report; D7 immediate activation is accepted; local journal mechanics are engineering details. No v26 work here; no owner-data rehearsal. Never discard the original merely because its version is newer.

### TASK F02 — Make the approved static splash work before Android 12

**Priority / status:** P0 data/startup safety; NOT STARTED. No F acceptance is passed by documentation.

**Sources / decisions:** S13.3/S13V-01/TD-109, accepted R3-final and held-splash decision. Existing accepted requirements; no new product choice.

**Problem / Current State:** S13V-01 / TD-109; both Android launch backgrounds use a bitmap over a mipmap that resolves to an adaptive-icon XML on API 26–30.

**Required Outcome:** the approved mark/background appear on supported pre-12 Android; the owner-approved Android 12+ behavior remains intact.

**Implementation Scope:** both `android/app/src/main/res/drawable*/launch_background.xml` resources, existing identity assets/generator only as needed, `test/core/config/app_identity_test.dart`. Keep R3-final, the accepted 1,000 ms animated hold and reduced-motion exception.

**Acceptance Criteria:** A1 resources no longer use the incompatible bitmap/adaptive-icon combination. A2 an API 26–30 launch shows the static mark, background and transition. A3 Android 12+ retains its approved animation/exit and animation-off behavior; first-frame and visible-content times are distinguished. API 24/25 coverage, if available, is recorded separately rather than inferred.

**Layer responsibility / files:** `android/app/src/main/res/drawable/launch_background.xml`; `android/app/src/main/res/drawable-v21/launch_background.xml`; `lib/core/config/app_identity.dart`. Presentation owns interaction/labels; existing ViewModels serialize state; domain owns the applicable pure rules; data owns compatible persistence/provider/format behavior. Use only the relevant listed layers, never calculations in widgets.

**Data/science invariant:** §8 CP/NC and shared rule 6 apply where relevant: preserve canonical units, Unknown, reviewed local proposals and original history; no provenance or result is invented.

**Verification:** full gate required by the original S13.3 contract; host resource regression, Android compilation and API 26–30 launch. G2 carries physical reduced-motion and final timing rows S13V-02/03.

**Criterion checks:** §7 `CHK-F02.A1…An` binds every A to a meaningful check and evidence layer; all start PLANNED.

**Stop condition:** close only after every A has evidence or an explicitly named permitted carry; mandatory pending evidence means implemented, acceptance pending. Stop at unresolved local acceptance/resource or the end of authorized scope; continue only independent authorized tasks. No automatic next-task start outside that scope.

**Completion Evidence:** resource regression, runtime capture and a V5 closure of S13V-01 only. No repetition of Stage 12 or all Stage 13 acceptance.

**Dependencies / Risk:** approval of this roadmap selects the proposed focused correction instead of carrying the known defect to final stabilization; emulator/runtime availability is an execution prerequisite, not proof of a pass.

**Stage A exit:** F01/F02 implementation criteria pass; any specifically carried final-device row is named. No unresolved restore-safety or pre-12 splash implementation defect remains.

### Stage B — Finish reliable Capture Plan entry and calculations

**Objective:** one coherent persisted contract from rig/file inputs through blocks, calculations, saved snapshots and export. F03's local contract acceptance precedes schema work; it is not another product planning stage.

### TASK F03 — Freeze the capture contract and persist it compatibly

**Priority / status:** P1 approved completion; NOT STARTED. No F acceptance is passed by documentation.

**Sources / decisions:** S14.1/S14.3(1-6), PD-05-14/21, AUD-04/05/06/16, C3, M3/M5/M6, CA-22. Accepted choices (§5): D3–D5 = A; the ADR-021 local acceptance retained.

**Problem / Current State:** S14.1 plus S14.3 schema slice; PD-05–14/21, AUD-04/05/06/16, CA-03/06/07/22. v25 lacks the approved WB, field-source and format/mode evidence contract.

**Required Outcome:** accepted ADR-021 and a data-preserving v26 migration support every subsequent Capture Plan task.

**Implementation Scope:** first record a numbered ADR-021 decision sheet and obtain its existing owner acceptance. Specify field types/units/destinations, source/conflict/unsupported states, WB, optional unrecorded/AF/MF focus-mode encoding, measured-size persistence, mode compatibility, binning normalization, FITS→rig mapping, CAL-1 coverage and O2b comparability. Per required rig field list dependent calculations and manual/photo supply; preserve ADR-011. Then implement Drift columns, generated steps/schema snapshot, additive snapshot keys under current snapshot version 1 and manifest version 2 (these are distinct contracts) and backup round trips. Amend ADR-009/017/018/020, SI-013, CALC-16/42 and DATA_MODEL only where affected.

**Acceptance Criteria:** A1 each contract choice has a concrete recommendation and accepted result, including D3–D5 below; missing legacy origins stay unrecorded. A2 v25→v26 preserves rigs, aliases, blocks, original snapshots/forecasts, results, legacy events and preferences; schema equality and repository reads pass. A3 WB/focus-mode/source/measurement-mode associations survive save/reopen, additive manifest and backup round trips; old data defaults are explicit, not invented. A4 pinned schema tests are updated; newer-schema refusal remains data-safe. A5 the FITS sample gate is raised at task start: identify an available owner file or licensed fixture; record absence early without blocking independent tasks.

**Layer responsibility / files:** `lib/data/database/app_database.dart`; `lib/data/repositories/drift_session_repository.dart`; `lib/domain/services/session_snapshot_builder.dart`; `lib/data/export/session_manifest_codec.dart`; `lib/data/backup/backup_preferences.dart`. Presentation owns interaction/labels; existing ViewModels serialize state; domain owns the applicable pure rules; data owns compatible persistence/provider/format behavior. Use only the relevant listed layers, never calculations in widgets.

**Data/science invariant:** §8 CP/NC and shared rule 6 apply where relevant: preserve canonical units, Unknown, reviewed local proposals and original history; no provenance or result is invented.

**Verification:** H; `schema_migration_test.dart`, `unsupported_database_test.dart`, backup and `session_manifest_codec_test.dart`; content and derived-state comparisons, not row counts alone.

**Criterion checks:** §7 `CHK-F03.A1…An` binds every A to a meaningful check and evidence layer; all start PLANNED.

**Stop condition:** close only after every A has evidence or an explicitly named permitted carry; mandatory pending evidence means implemented, acceptance pending. Stop at unresolved local acceptance/resource or the end of authorized scope; continue only independent authorized tasks. No automatic next-task start outside that scope.

**Completion Evidence:** accepted ADR-021 decisions, generated migration evidence, field/round-trip matrix and final gate.

**Dependencies / Risk:** F01 before new-schema restore regression. D3–D5 semantics are accepted; exact ADR-021 encoding/reference-vector acceptance gates only dependent implementation. No partial/nullable rig model or second metadata pipeline.

### TASK F04 — Extend the existing typed metadata contract

**Priority / status:** P1 approved completion; NOT STARTED. No F acceptance is passed by documentation.

**Sources / decisions:** S14.4, PD-11, AUD-05/06, RA.D A.2 tags. Existing accepted requirements; no new product choice.

**Problem / Current State:** S14.4; approved block/storage fields need extraction and provenance beyond the existing readers.

**Required Outcome:** DNG/JPEG/HEIC and the upcoming FITS reader share explicit values, units, origins and unsupported/conflict outcomes.

**Implementation Scope:** `lib/domain/metadata/capture_metadata.dart` and existing reader registry/readers. Add DNG BitsPerSample (258), Compression (259), AsShotNeutral; EXIF WhiteBalance (41987), LightSource (37384); common types for F10's approved FITS keywords. Preserve ISO kind; distinguish acquisition gain/conversion gain, X/Y binning, actual temperature/setpoint, supported axes/sample layouts. Extraction does not authorize extra planning controls.

**Acceptance Criteria:** A1 each field has tag-level provenance and correct absence/conflict/invalid handling. A2 DNG neutral values remain vectors; JPEG/HEIC modes do not invent Kelvin. A3 unsupported compression/layout/asymmetric binning is explicit; bounded reads remain bounded. A4 synthetic and local real DNG/JPEG/HEIC samples exercise the extension; the common FITS contract exists without requiring its reader yet.

**Layer responsibility / files:** `lib/domain/metadata/capture_metadata.dart`; `lib/domain/metadata/capture_metadata_reader.dart`. Presentation owns interaction/labels; existing ViewModels serialize state; domain owns the applicable pure rules; data owns compatible persistence/provider/format behavior. Use only the relevant listed layers, never calculations in widgets.

**Data/science invariant:** §8 CP/NC and shared rule 6 apply where relevant: preserve canonical units, Unknown, reviewed local proposals and original history; no provenance or result is invented.

**Verification:** H; existing `test/domain/metadata/` fixtures and local real-sample test, including absent, contradictory and out-of-range values.

**Criterion checks:** §7 `CHK-F04.A1…An` binds every A to a meaningful check and evidence layer; all start PLANNED.

**Stop condition:** close only after every A has evidence or an explicitly named permitted carry; mandatory pending evidence means implemented, acceptance pending. Stop at unresolved local acceptance/resource or the end of authorized scope; continue only independent authorized tasks. No automatic next-task start outside that scope.

**Completion Evidence:** field/tag fixture matrix, real-sample result without private metadata in Git, final gate.

**Dependencies / Risk:** F03 accepted contract; real-file evidence is not replaced by synthetic fixtures.

### TASK F05 — Make manual and photo-assisted rig creation usable

**Priority / status:** P1 approved completion; NOT STARTED. No F acceptance is passed by documentation.

**Sources / decisions:** S14.2, PD-07, CA-02/M2, AUD-04, UXA-C2/C4. Accepted choices (§5): D8 = A.

**Problem / Current State:** S14.2, CA-02, AUD-04; photo import is an unlabeled secondary icon and required scientific inputs lack clear reasons.

**Required Outcome:** a user can choose class and reach the existing manual or photo-assisted rig flow wherever a rig is needed.

**Implementation Scope:** equipment editor/selection, existing `/equipment/import`, missing-rig actions on Planner/Tonight; F16 integrates onboarding. Class first, including explicit Unknown. Two equally visible labeled choices: From a photo / Enter by hand; photo first for Phone/DSLR, manual first for Astro until F10. State readable formats; explain why each required field is needed. Set the example class from cited seed evidence only for new installs. A rig saved from a plan's missing-rig action or from onboarding becomes that plan's rig, per D8 (UXA-C2); one created in the Library is only saved. A changed rig editor asks before discarding (UXA-C4).

**Acceptance Criteria:** A1 list, empty state and missing-rig actions expose both choices. A2 synthetic phone JPEG containing focal length, aperture, 35 mm-equivalent focal length and dimensions reaches a saved rig without typed sensor values. A3 Incomplete metadata names missing inputs and explains which calculations require each, without guessed defaults; Not sure selects explicit Unknown and explains that it does not infer sensor facts. Existing rigs retain class. New-install example class has cited seed evidence and changes no existing row. A4 class-specific block fields follow the accepted contract; U and the setup portion of W pass. A5 Accepted D8: Save from a plan missing-rig action on Planner/Tonight or onboarding returns to its caller with that saved rig selected exactly once, missing-rig status cleared and Rig saved and chosen for this plan feedback; Cancel changes/selects nothing. Library creation only saves. Both manual and photo paths carry caller and saved identity; a Save failure preserves edits without selection. A6 a changed rig editor asks before discarding on Back or a tap outside, with the existing Discard prompt or the site editor's full-screen route pattern (as TD-084 required of the site editor); an unchanged editor closes at once (UXA-C4).

**Layer responsibility / files:** `lib/presentation/screens/equipment/equipment_selection_screen.dart`; `lib/presentation/screens/metadata/metadata_import_screen.dart`; `lib/presentation/screens/equipment/equipment_editor.dart`; `lib/presentation/shared/equipment_draft.dart`; `lib/presentation/viewmodels/library_viewmodels.dart`; `lib/presentation/viewmodels/session_plan_viewmodel.dart`. Presentation owns interaction/labels; existing ViewModels serialize state; domain owns the applicable pure rules; data owns compatible persistence/provider/format behavior. Use only the relevant listed layers, never calculations in widgets.

**UX/state contract:** §9 incorporates SP04, with exact labels/visible-versus-detail hierarchy, applicable empty/loading/error/Unknown/conflict and draft/saved/dirty states, Save/Back/Cancel and outcome feedback. U/W apply; proposals do not count as runtime or owner visual acceptance.

**Data/science invariant:** §8 CP/NC and shared rule 6 apply where relevant: preserve canonical units, Unknown, reviewed local proposals and original history; no provenance or result is invented.

**Verification:** S; equipment import/editor/selection and missing-rig widget tests, including create-then-chosen from each missing-rig entry point and discard-guard cases (Back, tap outside, unchanged), relevant block-form regressions; establish the reference-plan density baseline before changes.

**Criterion checks:** §7 `CHK-F05.A1…An` binds every A to a meaningful check and evidence layer; all start PLANNED.

**Stop condition:** close only after every A has evidence or an explicitly named permitted carry; mandatory pending evidence means implemented, acceptance pending. Stop at unresolved local acceptance/resource or the end of authorized scope; continue only independent authorized tasks. No automatic next-task start outside that scope.

**Completion Evidence:** route/required-input matrix, JPEG journey, U renders/acceptance and explicit remaining input barriers.

**Dependencies / Risk:** F03; D8 for A5's outcome. No specification service, relaxed required-input invariant or new equipment mode.

### TASK F06 — Preserve block settings, origins and white balance

**Owner amendment AM-02:** UX32 actions accepted2026-10-18; see §4 AM-02 and FINALIZATION_REVIEW §33.

**Priority / status:** P1 approved completion; NOT STARTED. No F acceptance is passed by documentation.

**Owner amendment:** AM-01 (2026-10-18), FINALIZATION_REVIEW §31; applicable existing source clauses amended only as explicitly stated.

**Sources / decisions:** S14.6/8, PD-08/09, TD-108, RA-F05, AUD-03/06, UXA-C4. Accepted choices (§5): D5 = A; UX-S R6/R9.

**Problem / Current State:** S14.6/8, TD-108, RA-F05, CA-04/12; valid custom filters are coerced to None, light exposure leaks into other block types, and approved sources/WB are not persisted/displayed end to end.

**Required Outcome:** editing and reopening a block preserves its intended values and provenance; WB is an honest record.

**Implementation Scope:** `capture_block_dialog.dart`, capture block models/presentation, snapshot/detail/share/export paths using F03 fields. Preserve custom filters both on initial edit and Use other values; class-specific defaults; reset inappropriate proposals on type switch. WB modes: Auto, named preset, Kelvin, Custom, optional tint; Phone/DSLR/Unknown only. AM-04 exposes ISO and WB in basic Phone/DSLR entry, adds optional descriptive AF/MF with unrecorded as default, and keeps binning in applicable astro Details. Unknown class asks for a camera class or retains an honest unrecorded sensitivity; never infer Phone from the running platform. Parse positive fractional/decimal exposure to canonical seconds; do not invent device-specific ISO/WB limits or supported-value lists. File modes and DNG neutral vectors remain distinct. Give the block editor the discard guard of F05 A6 (UXA-C4); local Add block/Apply changes is distinct from parent Save plan (AM-02).

**Acceptance Criteria:** A1 unchanged valid custom light/flat filters survive edit and Use other values; null remains null; domain length validation stays. A2 Origin markers survive switch/edit/reorder/delete-Undo/copy/save/reopen and snapshot/backup. User edits replace only the applicable origin; Cancel changes nothing. Inline reviewed proposals and compact visible source/Unknown/conflict labels lead to detailed provenance/WB/storage; no critical conflict is hidden. Immutable source descriptors survive source edit/deletion without changing copied values or historical snapshots. A3 flat/bias do not inherit an unintended light exposure; default filter follows class. A4 WB and optional AF/MF focus mode appear in snapshot, entry, manifest and share text and survive copy, save/reopen and backup; old missing values remain unrecorded. Neither changes exposure, budget, storage, relative gain or calibration matching; there is no numeric focus input or camera control. A5 Basic Phone/DSLR entry exposes frame type, exposure, count, ISO, WB and optional AF/MF recording, plus applicable filter and a concise estimate. Exposure accepts positive decimal seconds and familiar fractions (for example 1/14 s); invalid/zero-denominator fractions fail by the field, canonical seconds and existing bounds stay unchanged. ISO/WB/focus may remain unrecorded and never block an otherwise valid save. The explicit rig class selects ISO for Phone/DSLR and gain for astro cameras, without a per-block ISO/GAIN choice; Unknown offers a clear camera-class remedy or honest unrecorded state, never a guessed ISO/gain kind. Binning is applicable astro-camera Details, not mandatory basic Phone/DSLR input; source/storage and expert WB details stay reachable. Preserve hidden historical values, actual validation/Unknown/conflict reasons and all calculations. Charts are not a prerequisite; U covers 412x915, 200% text, keyboard and density. WB guarantees no identical colors. A6 Changed block editor Back/tap outside uses the existing discard guard, dismissal = Cancel; pending file proposals count as dirty. Explicit local Cancel never applies; unchanged closes immediately. At 412×915/200%/keyboard use the full-screen route pattern if needed, with reachable persistent Apply changes and preserved typed values on errors. A7 Use Add block for creation and Apply changes for editing a block; reserve Save plan for recording the parent plan. Block apply still changes the working plan/autosave with existing Undo, not an implicit parent Save or a second persistence mechanism. Context and concise feedback explain the scope without extra confirmation. Cancel/guard dismissal applies nothing; primary labels and semantics remain reachable at200%/IME; update affected interaction keys/copy tests.

**Layer responsibility / files:** `lib/presentation/widgets/capture_plan/capture_block_dialog.dart`; `lib/domain/models/capture_block.dart`; `lib/data/repositories/drift_session_repository.dart`; `lib/domain/services/session_snapshot_builder.dart`; `lib/data/export/session_manifest_codec.dart`. Presentation owns interaction/labels; existing ViewModels serialize state; domain owns the applicable pure rules; data owns compatible persistence/provider/format behavior. Use only the relevant listed layers, never calculations in widgets.

**UX/state contract:** §9 incorporates SP05, with exact labels/visible-versus-detail hierarchy, applicable empty/loading/error/Unknown/conflict and draft/saved/dirty states, Save/Back/Cancel and outcome feedback. U/W apply; proposals do not count as runtime or owner visual acceptance.

**Data/science invariant:** §8 CP/NC and shared rule 6 apply where relevant: preserve canonical units, Unknown, reviewed local proposals and original history; no provenance or result is invented.

**Verification:** H for persisted provenance; light/calibration form, capture Undo, round-trip and unchanged-calculation regressions; discard-guard cases.

**Criterion checks:** §7 `CHK-F06.A1…An` binds every A to a meaningful check and evidence layer; all start PLANNED.

**Stop condition:** close only after every A has evidence or an explicitly named permitted carry; mandatory pending evidence means implemented, acceptance pending. Stop at unresolved local acceptance/resource or the end of authorized scope; continue only independent authorized tasks. No automatic next-task start outside that scope.

**Completion Evidence:** value/source operation matrix, WB round trips, renders and gate.

**Dependencies / Risk:** F03–F05. No conversion of AsShotNeutral to Kelvin or device control.

### TASK F07 — Produce storage estimates from compatible evidence

**Priority / status:** P1 approved completion; NOT STARTED. No F acceptance is passed by documentation.

**Sources / decisions:** S14.7, PD-06, AUD-05, CA-07/18, M6/M16. Accepted choices (§5): D3–D5 = A.

**Problem / Current State:** S14.7, PD-06, CA-07/18, AUD-05; storage often stays Unknown and the new evidence chain needs mode/binning rules.

**Required Outcome:** use compatible measured size first, supported theoretical evidence second, otherwise explain Unknown and its remedy.

**Implementation Scope:** capture budget/storage calculation and `capture_budget_summary.dart`, rig/block file evidence and `QuantityText`. Scope evidence by format, dimensions/output mode, compression, binning and source. Use ADR-021's accepted unread-file and binning rules; recognize file length without pretending to parse it. Integrate F10's FITS branch when available.

**Acceptance Criteria:** A1 compatible measured file wins; mode changes invalidate or explicitly reconfirm it; an already-binned file is never scaled again. A2 theoretical output requires evidenced uncompressed DNG, supported FITS layout, or explicitly confirmed declared format; distinguish pixel payload and container bytes. Unknown compression/layout remains Unknown. A3 camera class never selects a size assumption; Unknown offers file/manual-size action. A4 unread-format behavior follows accepted D3 A, with mode-unread/content-variation wording; CR3 length vector uses decimal MB. A5 S1–S4, compressed boundary and binning vectors pass; MB/GB use `QuantityText`, 10^6/10^9 bytes, visible source and assumption.

**Layer responsibility / files:** `lib/presentation/viewmodels/capture_analysis_viewmodel.dart`; `lib/domain/services/capture_budget_calculator.dart`; `lib/presentation/widgets/capture_plan/capture_budget_summary.dart`; `lib/core/utils/quantity_text.dart`. Presentation owns interaction/labels; existing ViewModels serialize state; domain owns the applicable pure rules; data owns compatible persistence/provider/format behavior. Use only the relevant listed layers, never calculations in widgets.

**UX/state contract:** §9 incorporates SP03/SP05, with exact labels/visible-versus-detail hierarchy, applicable empty/loading/error/Unknown/conflict and draft/saved/dirty states, Save/Back/Cancel and outcome feedback. U/W apply; proposals do not count as runtime or owner visual acceptance.

**Data/science invariant:** §8 CP/NC and shared rule 6 apply where relevant: preserve canonical units, Unknown, reviewed local proposals and original history; no provenance or result is invented.

**Verification:** H; independent storage vectors for unbinned/already-binned measurements, changed modes, DNG sample layouts and integer/floating FITS payload/padding; U for display.

**Criterion checks:** §7 `CHK-F07.A1…An` binds every A to a meaningful check and evidence layer; all start PLANNED.

**Stop condition:** close only after every A has evidence or an explicitly named permitted carry; mandatory pending evidence means implemented, acceptance pending. Stop at unresolved local acceptance/resource or the end of authorized scope; continue only independent authorized tasks. No automatic next-task start outside that scope.

**Completion Evidence:** vector inputs/expected/actual, invalidation examples, source labels and gate; FITS runtime branch completed in F10.

**Dependencies / Risk:** F03/F04/F06. No proprietary RAW decoder, guessed compression ratio or class-derived sensor facts.

### TASK F08 — Populate a light block from a reviewed photo proposal

**Priority / status:** P1 approved completion; NOT STARTED. No F acceptance is passed by documentation.

**Sources / decisions:** S14.9, PD-11, TD-072, SI-014, C3, AUD-03/05/06, UXA-C4. Accepted choices (§5): D5 = A; UX-S R6/R9.

**Problem / Current State:** S14.9, TD-072, PD-11; file import exists for rigs but not the approved block workflow.

**Required Outcome:** a picked DNG/JPEG/HEIC proposes applicable block fields with sources; Save alone persists them.

**Implementation Scope:** existing `CaptureFileAccess`, registry and light editor. Propose exposure, ISO with kind, WB and format/size evidence; flag pixel-count/mode conflicts and make repeated picks order-independent. Use F10 for FITS later, without blocking non-FITS acceptance.

**Acceptance Criteria:** A1 Inline review shows only approved class-applicable fields, values/sources and visible conflicts before Save; no exposure/ISO change reaches the rig. Proposed values remain local; explicit acceptance/edits preserve per-field origin under F03/F06. A2 Cancel/read failure leaves stored block/rig unchanged; repeat picks, edited proposals and differing dimensions have deterministic visible outcomes; an unsaved proposal counts as a change for F06's discard guard (UXA-C4). A3 TD-072's size conflict is independent of pick order; custom filters and persisted sources survive. A4 DNG/JPEG/HEIC Save/reopen works on device; U and W's DSLR proposal/edit/cancel path pass.

**Layer responsibility / files:** `lib/domain/metadata/capture_file_access.dart`; `lib/domain/metadata/capture_metadata_reader.dart`; `lib/presentation/widgets/capture_plan/capture_block_dialog.dart`; `lib/presentation/viewmodels/session_plan_viewmodel.dart`. Presentation owns interaction/labels; existing ViewModels serialize state; domain owns the applicable pure rules; data owns compatible persistence/provider/format behavior. Use only the relevant listed layers, never calculations in widgets.

**UX/state contract:** §9 incorporates SP05, with exact labels/visible-versus-detail hierarchy, applicable empty/loading/error/Unknown/conflict and draft/saved/dirty states, Save/Back/Cancel and outcome feedback. U/W apply; proposals do not count as runtime or owner visual acceptance.

**Data/science invariant:** §8 CP/NC and shared rule 6 apply where relevant: preserve canonical units, Unknown, reviewed local proposals and original history; no provenance or result is invented.

**Verification:** H; parser→proposal→Save integration and widget tests, real-file/device DNG/JPEG/HEIC row. Required FITS evidence belongs to F10/G2, not a hidden blocker here.

**Criterion checks:** §7 `CHK-F08.A1…An` binds every A to a meaningful check and evidence layer; all start PLANNED.

**Stop condition:** close only after every A has evidence or an explicitly named permitted carry; mandatory pending evidence means implemented, acceptance pending. Stop at unresolved local acceptance/resource or the end of authorized scope; continue only independent authorized tasks. No automatic next-task start outside that scope.

**Completion Evidence:** proposal/conflict/cancel matrix, file-format/device results and gate.

**Dependencies / Risk:** F04/F06/F07. Reuse one import pipeline; never silently infer extra camera controls.

### TASK F09 — Build correct calibration proposals and retire the example action

**Priority / status:** P1 approved completion; NOT STARTED. No F acceptance is passed by documentation.

**Sources / decisions:** S14.10/13, PD-12/13, TD-107, AUD-02, CA-03/M3, UXA-C5. Accepted choices (§5): UX-S R8.

**Problem / Current State:** S14.10/13, TD-107, CA-03, AUD-02; flat warnings use unrelated filter/binning membership and missing-flat detection is filter-only. Calibration generation is approved; the example action waits for real replacement flows.

**Required Outcome:** matching, missing coverage and preview generation agree on whole modeled settings; users can construct the plan without the example shortcut.

**Implementation Scope:** `calibration_match.dart`, its analysis/widget callers and existing block editing/Undo. Compare trimmed case-folded names without alias guessing; preserve recorded filter spelling. Propose darks per distinct exposure/sensitivity/binning, flats per compatible filter/binning, bias/dark flats by class. Remove the example UI action only after F08 and this workflow pass, together with the empty Capture Plan state that replaces it (A6, UXA-C5); retain `ExampleCapturePlan` as a test fixture and migrate affected E2E flows.

**Acceptance Criteria:** A1 lights Ha/bin1 + OIII/bin2 with flat Ha/bin2 do not satisfy either full tuple incorrectly; both warnings and missing coverage use that rule. Ha=HA; H-alpha≠Ha. A2 Unknown sensitivity does not prove known-value coverage; unresolved preview requirements remain visible and proven duplicates omitted. A labelled Build calibration frames entry and relevant missing-flat warning shortcut open CAL-1 preview. Counts remain editable proposals; generated flat exposure is entered for the flat, never inherited blindly from a light. Calibration review uses the same class-appropriate basic fields as F06; matching still uses the established modeled tuple, never WB or focus mode. No optional include-switch redesign is introduced. A3 LENR suppresses dark proposals; counts stay proposals; library/timing policies and budget remain correct, calibration never counts as integration. A4 preview Cancel changes nothing; confirm persists; Undo after a newer edit preserves that edit. A5 custom/imported FILTER and hidden-class binning tests pass; example-action replacement E2E and U pass. A6 with no blocks, the Capture Plan names the next step with labelled actions — for example “Add light frames”, plus “Take from a photo” where F08 (for astro cameras, F10) supports the rig's class — and says calibration can be built from the lights afterwards; the empty state's actions are not icon-only; the E2E that replaces `capturePlan.useExample` starts from this state (UXA-C5).

**Layer responsibility / files:** `lib/domain/services/calibration_match.dart`; `lib/presentation/widgets/capture_plan_widget.dart`; `lib/domain/models/capture_block.dart`; `lib/presentation/viewmodels/session_plan_viewmodel.dart`. Presentation owns interaction/labels; existing ViewModels serialize state; domain owns the applicable pure rules; data owns compatible persistence/provider/format behavior. Use only the relevant listed layers, never calculations in widgets.

**UX/state contract:** §9 incorporates SP03/SP06, with exact labels/visible-versus-detail hierarchy, applicable empty/loading/error/Unknown/conflict and draft/saved/dirty states, Save/Back/Cancel and outcome feedback. U/W apply; proposals do not count as runtime or owner visual acceptance.

**Data/science invariant:** §8 CP/NC and shared rule 6 apply where relevant: preserve canonical units, Unknown, reviewed local proposals and original history; no provenance or result is invented.

**Verification:** H; `calibration_match_test.dart`, calibration widget/Undo tests, the empty-state widget test, capture-budget regressions and core-loop replacement path.

**Criterion checks:** §7 `CHK-F09.A1…An` binds every A to a meaningful check and evidence layer; all start PLANNED.

**Stop condition:** close only after every A has evidence or an explicitly named permitted carry; mandatory pending evidence means implemented, acceptance pending. Stop at unresolved local acceptance/resource or the end of authorized scope; continue only independent authorized tasks. No automatic next-task start outside that scope.

**Completion Evidence:** tuple/coverage fixture table, preview/Undo evidence, replacement journey and gate.

**Dependencies / Risk:** F06 and F08 before example removal. Advisory compatibility must not become proof of full calibration-library suitability.

### TASK F10 — Read FITS headers into the existing rig and block flows

**Priority / status:** P1 approved completion; NOT STARTED. No F acceptance is passed by documentation.

**Sources / decisions:** S14.5, RG-03 Q1, PD-11, CA-06/15, M5/M14, AUD-06. Existing accepted requirements; no new product choice.

**Problem / Current State:** S14.5 and conditional F07/F08 integration; CA-06/15, RG-03 Q1. FITS is recognized but unread.

**Required Outcome:** supported FITS supplies reviewed rig/block/storage evidence through existing paths, backed by a real astro-camera file.

**Implementation Scope:** existing metadata registry, F04 types, EquipmentCandidate→match→review→Save and F08 proposal path. Read SIMPLE/BITPIX/NAXIS/NAXISn; EXPTIME/EXPOSURE, GAIN, OFFSET, XBINNING/YBINNING, CCD-TEMP, FILTER, DATE-OBS, INSTRUME; rig XPIXSZ/YPIXSZ (µm), FOCALLEN (mm, softwareSetting), TELESCOP (identity only). Bound 2,880-byte header records through END. Use ADR-021's supported HDU/layout and once-only binning normalization.

**Acceptance Criteria:** A1 record boundaries, missing END, read/axis/overflow limits, floating BITPIX, conflicting exposure, arbitrary FILTER and absent/asymmetric binning have tested outcomes. A2 binned/unbinned writer vectors normalize geometry exactly once; unsupported meanings/layouts stay explicit. A3 real FITS runs through reader, reviewed saved rig, applicable block proposals and storage; Cancel stores nothing. A4 photo-choice labels now advertise FITS; recognized-only RAW remains honestly described. Only already approved block fields become controls.

**Layer responsibility / files:** `lib/domain/metadata/capture_metadata_reader.dart`; `lib/domain/metadata/capture_metadata.dart`; `lib/domain/equipment_import/equipment_candidate.dart`; `lib/presentation/screens/metadata/metadata_import_screen.dart`; `lib/presentation/widgets/capture_plan/capture_block_dialog.dart`. Presentation owns interaction/labels; existing ViewModels serialize state; domain owns the applicable pure rules; data owns compatible persistence/provider/format behavior. Use only the relevant listed layers, never calculations in widgets.

**UX/state contract:** §9 incorporates SP04/SP05, with exact labels/visible-versus-detail hierarchy, applicable empty/loading/error/Unknown/conflict and draft/saved/dirty states, Save/Back/Cancel and outcome feedback. U/W apply; proposals do not count as runtime or owner visual acceptance.

**Data/science invariant:** §8 CP/NC and shared rule 6 apply where relevant: preserve canonical units, Unknown, reviewed local proposals and original history; no provenance or result is invented.

**Verification:** H; synthetic headers plus at least one owner-provided local sample or licensed fixture; device rig/block check, storage/calibration integration and U.

**Criterion checks:** §7 `CHK-F10.A1…An` binds every A to a meaningful check and evidence layer; all start PLANNED.

**Stop condition:** close only after every A has evidence or an explicitly named permitted carry; mandatory pending evidence means implemented, acceptance pending. Stop at unresolved local acceptance/resource or the end of authorized scope; continue only independent authorized tasks. No automatic next-task start outside that scope.

**Completion Evidence:** fixture provenance/license, keyword/normalization matrix, real-file and device evidence, gate. Do not commit private samples or values.

**Dependencies / Risk:** F03/F04 plus F07–F09 for integration. Sample absence permits independent work to continue but blocks G1 until F10 completes or an explicit owner deferral records PD-11/RG-03 consequences.

### TASK F11 — Show relative improvement over integration time

**Priority / status:** P1 approved completion; NOT STARTED. No F acceptance is passed by documentation.

**Owner amendment:** AM-01 (2026-10-18), FINALIZATION_REVIEW §31; applicable existing source clauses amended only as explicitly stated.

**Sources / decisions:** S14.11, PD-05 O2b, AUD-16, SI-003. Existing accepted requirements; no new product choice.

**Problem / Current State:** S14.11, PD-05, AUD-16; the existing relative-gain calculation needs the approved O2b presentation and comparability rules.

**Required Outcome:** a concise primary estimate shows ideal relative gain against one comparable light frame; the integration-time curve and text alternative remain in Details without implying absolute physical SNR.

**Implementation Scope:** existing stacking-gain service/presentation; T=N·t, normalized √(T/T_plan), ADR-021 grouping. Split known incompatible gain/binning groups or explicitly label the accepted idealization; retain SI-003 explanation.

**Acceptance Criteria:** A1 ratios 0.5/1/2 yield 0.7071/1/1.4142 within the recorded vector tolerance. A2 zero integration, mixed and unknown settings yield truthful group/empty/text states; unknown never proves equivalence. A3 Primary Capture Plan output shows a concise estimated relative stacking gain against one comparable light frame, with its reference explicit and a short assumptions link. It never claims absolute physical SNR. Integration-time curve/reference and text remain available in Details, not repeated large graphs before Save. Known incompatible groups remain separate; unknown comparability is explained rather than combined. U and W visible-explanation checks pass.

**Layer responsibility / files:** `lib/domain/services/stacking_gain_curve.dart`; `lib/presentation/widgets/capture_plan/stacking_gain_graph.dart`; `lib/presentation/viewmodels/capture_analysis_viewmodel.dart`. Presentation owns interaction/labels; existing ViewModels serialize state; domain owns the applicable pure rules; data owns compatible persistence/provider/format behavior. Use only the relevant listed layers, never calculations in widgets.

**UX/state contract:** §9 incorporates SP03, with exact labels/visible-versus-detail hierarchy, applicable empty/loading/error/Unknown/conflict and draft/saved/dirty states, Save/Back/Cancel and outcome feedback. U/W apply; proposals do not count as runtime or owner visual acceptance.

**Data/science invariant:** §8 CP/NC and shared rule 6 apply where relevant: preserve canonical units, Unknown, reviewed local proposals and original history; no provenance or result is invented.

**Verification:** H; independent R-O2 vectors and existing `stacking_gain_curve_test.dart`, chart semantics/text tests.

**Criterion checks:** §7 `CHK-F11.A1…An` binds every A to a meaningful check and evidence layer; all start PLANNED.

**Stop condition:** close only after every A has evidence or an explicitly named permitted carry; mandatory pending evidence means implemented, acceptance pending. Stop at unresolved local acceptance/resource or the end of authorized scope; continue only independent authorized tasks. No automatic next-task start outside that scope.

**Completion Evidence:** vectors, grouping decisions, rendered/text alternative and gate.

**Dependencies / Risk:** F03; F06 when using persisted settings. Preserve existing valid √N behavior.

### TASK F12 — Explain effective assumptions and actionable fit limits

**Priority / status:** P1 approved completion; NOT STARTED. No F acceptance is passed by documentation.

**Owner amendment:** AM-01 (2026-10-18), FINALIZATION_REVIEW §31; applicable existing source clauses amended only as explicitly stated.

**Sources / decisions:** S14.12, PD-10/14, TD-074, K12. Accepted choices (§5): UX-S R3.

**Problem / Current State:** S14.12, TD-074, PD-10/14; assumptions and the existing what-fits result are not consistently actionable.

**Required Outcome:** the plan explains the inputs that affect its current result, how to change them, and what fits for every evaluable block.

**Implementation Scope:** existing assumptions/budget UI and `FitAnalyzer` outputs; correct stale label, link/return to grouped basic/advanced/guidance Settings with global scope explicit, add the approved star-focus/recheck reminder. Keep the existing refocus overhead as the only timing concept.

**Acceptance Criteria:** A1 displayed assumptions are the effective calculation values. A2 evaluable blocks get FitAnalyzer-derived guidance; unavailable results name the missing inputs without hiding still-valid results. A3 focus guidance remains a reminder; the optional AF/MF record of F06 has no numeric control/value, alters no calculation and operates no camera. A4 Change in Settings opens planning Settings over the current plan with an explicit global-scope notice; Back returns to the same plan/section and preserves edits/results. Main settings retain darkness/minimum-altitude, frame interval and feasibility margin. Advanced groups contain optional Moon/cloud gates and dither/refocus/filter/flip/setup time; NPF is guidance for untracked exposure and dew margin is weather guidance. Display/privacy/backup/About remain distinct. Every retained setting has a visible consequence; U and fit/error/Unknown/W checks pass.

**Layer responsibility / files:** `lib/domain/services/fit_analyzer.dart`; `lib/domain/models/planning_preferences.dart`; `lib/presentation/screens/settings/settings_screen.dart`. Presentation owns interaction/labels; existing ViewModels serialize state; domain owns the applicable pure rules; data owns compatible persistence/provider/format behavior. Use only the relevant listed layers, never calculations in widgets.

**UX/state contract:** §9 incorporates SP11, with exact labels/visible-versus-detail hierarchy, applicable empty/loading/error/Unknown/conflict and draft/saved/dirty states, Save/Back/Cancel and outcome feedback. U/W apply; proposals do not count as runtime or owner visual acceptance.

**Data/science invariant:** §8 CP/NC and shared rule 6 apply where relevant: preserve canonical units, Unknown, reviewed local proposals and original history; no provenance or result is invented.

**Verification:** S; affected fit/budget/viewmodel/widget regressions and navigation checks.

**Criterion checks:** §7 `CHK-F12.A1…An` binds every A to a meaningful check and evidence layer; all start PLANNED.

**Stop condition:** close only after every A has evidence or an explicitly named permitted carry; mandatory pending evidence means implemented, acceptance pending. Stop at unresolved local acceptance/resource or the end of authorized scope; continue only independent authorized tasks. No automatic next-task start outside that scope.

**Completion Evidence:** representative fits/non-fits/partial-input states, assertions against service outputs, U evidence.

**Dependencies / Risk:** F07; no new assumptions engine or invented rig specifications.

**Stage B exit:** F03–F12 criteria pass; data and source round trips and scientific vectors are demonstrated. Pending named final-device repeats remain listed for G2. F10 may stay blocked while independent Stage C work proceeds, but this stage cannot close with silently omitted FITS.

### Stage C — Connect night conditions, screens and saved records

**Objective:** finish approved night views and existing user journeys; preserve one plan lifecycle. Complete maintenance before the final consistency sweep.

### TASK F13 — Use one Moon-up rule and derive moon-free intervals

**Priority / status:** P1 approved completion; NOT STARTED. No F acceptance is passed by documentation.

**Sources / decisions:** S15.1-3, PD-15/Q2 MF-c, SI-015, AUD-07/08/09, UXA-C3. Accepted choices (§5): D9 = A; the ADR-022 local acceptance retained.

**Problem / Current State:** S15.1–3, SI-015, AUD-07; rise/set and Moon-up counts use different definitions.

**Required Outcome:** accepted ADR-022 and one frame-correct predicate drive rise/set, gates, counts, phase and moon-free intervals.

**Implementation Scope:** first obtain local ADR-022 acceptance covering MF-c, coordinate-frame equivalence, equality/sampling limits, phase longitude, interval classification, F14's forecast/cache/dark-span conventions and F15's cache contract, plus browse versus adopt as its own numbered interaction item (D9, UXA-C3), presented as a flow with renders. Then update Moon calculations, gates and `night_text`; amend ADR-010/012/013 and CALC-28/29/32/33/43 where affected. Reuse existing lunar model and authoritative reference fixtures.

**Acceptance Criteria:** A1 the topocentric sampling predicate is derived as equivalent to geocentric h₀, rather than copying the numeric threshold into the wrong frame. A2 rise/set, dark counts, gate and annotations agree at the boundary; high-latitude/polar cases and batch=single pass. A3 dark∩Moon-below intervals distinguish evening/morning/all-night/none/mixed-disjoint/no-dark; phase name follows phase longitude, never substitutes for interval calculation. A4 SI-015 and relevant vectors are reconciled; no universal good-night threshold. A5 ADR-022 records accepted D9 A with exact controls/renders: Home/Planner context edits the active plan; calendar/day/forecast View this night only browse with viewed-versus-plan labels. Plan this night alone adopts a never-saved draft or guarded saved-plan copy. Save failure/Cancel stops replacement; Discard restores saved state before copy. Explicit pre-copy Save has its ordinary write effect; adoption/copy does not retime or rewrite the source as saved after that Save. Back without adoption changes no plan/result; feedback names draft change versus copy. The scientific/reference-vector local acceptance remains explicit.

**Layer responsibility / files:** `lib/domain/services/moon_calculator.dart`; `lib/domain/services/imaging_opportunity_calculator.dart`; `lib/presentation/shared/night_text.dart`; `lib/domain/models/session_night.dart`. Presentation owns interaction/labels; existing ViewModels serialize state; domain owns the applicable pure rules; data owns compatible persistence/provider/format behavior. Use only the relevant listed layers, never calculations in widgets.

**UX/state contract:** A5's browse/adopt flow is §9's SP08, recorded in ADR-022 with its control matrix and renders; F14/F15/F17/F18 implement its callers. F13 itself changes calculations and `night_text` wording, not screen layout. Proposals do not count as runtime or owner visual acceptance.

**Data/science invariant:** §8 CP/NC and shared rule 6 apply where relevant: preserve canonical units, Unknown, reviewed local proposals and original history; no provenance or result is invented.

**Verification:** H; independent synthetic and USNO-referenced vectors, astronomy/Moon/visibility regression, text-state tests. Consult primary external references only if an unresolved local technical point requires it.

**Criterion checks:** §7 `CHK-F13.A1…An` binds every A to a meaningful check and evidence layer; all start PLANNED.

**Stop condition:** close only after every A has evidence or an explicitly named permitted carry; mandatory pending evidence means implemented, acceptance pending. Stop at unresolved local acceptance/resource or the end of authorized scope; continue only independent authorized tasks. No automatic next-task start outside that scope.

**Completion Evidence:** accepted ADR-022 including the D9 flow and renders, predicate derivation, vector comparison and gate.

**Dependencies / Risk:** existing approved MF-c decision; independent of FITS. ADR acceptance is a bounded checkpoint — the technical items plus the one D9 interaction item — not a product reassessment.

### TASK F14 — Show honest multi-night weather coverage

**Priority / status:** P1 approved completion; NOT STARTED. No F acceptance is passed by documentation.

**Owner amendment:** AM-01 (2026-10-18), FINALIZATION_REVIEW §31; applicable existing source clauses amended only as explicitly stated.

**Sources / decisions:** S15.4/5, PD-16/18/Q3, TD-049, AUD-08, CA-09/M8, UXA-C3. Accepted choices (§5): D9 = A.

**Problem / Current State:** S15.4/5, TD-049, CA-09, AUD-08; current weather is one night, and the summary uses sunset-to-sunrise rather than the required dark span.

**Required Outcome:** one existing-provider request serves the available horizon, with accurate per-night cards, coverage, freshness and lead time.

**Implementation Scope:** existing Open-Meteo repository/cache, `NightWeatherSummarizer`, weather views. Slice returned UTC hours; cache identity includes coordinates, model, range/version. Preserve offline/freshness semantics; safely drop/migrate old entries and TD-049 keys. Apply ADR-022's partial-hour, preceding-hour/instantaneous and dew-duration conventions. Update privacy/COMPLIANCE alongside actual data behavior. Overview cards only browse; adopting a night from them follows ADR-022's D9 item (UXA-C3).

**Acceptance Criteria:** A1 an up-to-16-day response is not presented as 16 complete nights; first/last partial, DST, absent-variable, no-dark, stale/offline and out-of-range states are explicit, never zero/clear defaults. A2 same-ID coordinate changes and late responses cannot attach data to the wrong site. A3 Night weather leads with selected-night facts and a readable hourly visualization on the night/darkness time axis: cloud cover, temperature with dew point, compact wind/gust and precipitation rows, and selection of an hour for exact values. Low/mid/high cloud layers and humidity remain reachable in detail. Gaps/no forecast have explicit discontinuities, never fabricated clear weather or smoothed certainty; legend, units and text alternative are provided. Full table/model/source/age stays in Details; no decorative UV/AQI/feels-like dashboard or new provider. A4 snapshot-relative “forecast N days ahead” is separate from retrieval age; no reliability score. A5 seeing/transparency limitation and user-opened Clear Outside link are explicit; request budget recorded; U passes. A6 opening a night's card changes no plan; adopting that night follows D9 (UXA-C3).

**Layer responsibility / files:** `lib/data/repositories/open_meteo_weather_repository.dart`; `lib/domain/services/night_weather_service.dart`; `lib/domain/services/night_weather_summarizer.dart`; `lib/domain/repositories/weather_snapshot_store.dart`. Presentation owns interaction/labels; existing ViewModels serialize state; domain owns the applicable pure rules; data owns compatible persistence/provider/format behavior. Use only the relevant listed layers, never calculations in widgets.

**UX/state contract:** §9 incorporates SP07, with exact labels/visible-versus-detail hierarchy, applicable empty/loading/error/Unknown/conflict and draft/saved/dirty states, Save/Back/Cancel and outcome feedback. U/W apply; proposals do not count as runtime or owner visual acceptance.

**Data/science invariant:** §8 CP/NC and shared rule 6 apply where relevant: preserve canonical units, Unknown, reviewed local proposals and original history; no provenance or result is invented.

**Verification:** H; repository race/cache tests, dark-span summarizer vectors including partial hours, card/strip tests and affected privacy contract checks; live service evidence in G1.

**Criterion checks:** §7 `CHK-F14.A1…An` binds every A to a meaningful check and evidence layer; all start PLANNED.

**Stop condition:** close only after every A has evidence or an explicitly named permitted carry; mandatory pending evidence means implemented, acceptance pending. Stop at unresolved local acceptance/resource or the end of authorized scope; continue only independent authorized tasks. No automatic next-task start outside that scope.

**Completion Evidence:** coverage/cache matrix, request-budget and duration vectors, UI/wording evidence and gate.

**Dependencies / Risk:** F13; no additional provider, quality score or forecast-accuracy promise.

### TASK F15 — Browse Moon nights without changing a saved plan

**Priority / status:** P1 approved completion; NOT STARTED. No F acceptance is passed by documentation.

**Owner amendment:** AM-01 (2026-10-18), FINALIZATION_REVIEW §31; applicable existing source clauses amended only as explicitly stated.

**Sources / decisions:** S15.6, PD-17, AUD-07/09, UXA-C3; COV-02. Accepted choices (§5): D9 = A.

**Problem / Current State:** S15.6, AUD-07/09; approved calendar and combined night bar must share calculations and lifecycle with existing details.

**Required Outcome:** offline calendar and night/Moon detail are consistent; browsing becomes a plan change only on explicit adoption.

**Implementation Scope:** `night_moon_screen.dart`, existing services and lifecycle viewmodel. Compute month in an isolate, cache relevant site/night-definition inputs, week view at large text; shared bar/time-slider, selected-instant/interval labels, legend, text alternative and field hatching. Slider state is transient viewing, never a plan write.

**Acceptance Criteria:** A1 Offline month computation runs in an isolate with relevant site/zone/night-definition/model cache identity; calendar/detail values agree and invalidate with context. Weekday/date/selection and large-text week view remain. The primary selected-night view has a labelled shared daylight/twilight/darkness and Moon-up timeline, legend and text alternative; preserve disjoint/no-dark/Unknown and field hatching distinctions. A2 Browsing/back leaves current and saved plans/results intact and labels viewed versus plan night. Accepted D9 adoption follows F13 A5, including guarded Save/Discard/Cancel and source comparison after any explicit pre-copy Save; no silent retiming or second plan store. A3 site change and restart preserve original snapshot/results. A4 U passes; phone timing is measured against the applicable existing runbook criterion, with no invented performance PASS. A5 A time slider browses an instant inside the viewed SessionNight without editing the plan, its start or saved results. Show the site-local time/date/zone and the corresponding dark/Moon state and end of the relevant interval; clearly distinguish time until darkness from time remaining in it. Reset to Now only when now lies in the viewed night; otherwise offer the night start. Date/site changes reset or revalidate the cursor. Keyboard/semantics/large text, DST labels and no-dark/polar cases pass; text offers the same facts. No simulator/playback or new astronomy engine.

**Layer responsibility / files:** `lib/presentation/screens/details/night_moon_screen.dart`; `lib/presentation/viewmodels/night_conditions_viewmodel.dart`; `lib/presentation/viewmodels/plan_lifecycle_viewmodel.dart`. Presentation owns interaction/labels; existing ViewModels serialize state; domain owns the applicable pure rules; data owns compatible persistence/provider/format behavior. Use only the relevant listed layers, never calculations in widgets.

**UX/state contract:** §9 incorporates SP07/SP08, with exact labels/visible-versus-detail hierarchy, applicable empty/loading/error/Unknown/conflict and draft/saved/dirty states, Save/Back/Cancel and outcome feedback. U/W apply; proposals do not count as runtime or owner visual acceptance.

**Data/science invariant:** §8 CP/NC and shared rule 6 apply where relevant: preserve canonical units, Unknown, reviewed local proposals and original history; no provenance or result is invented.

**Verification:** S; calculation integration, lifecycle/cache/route tests, accessibility/text alternative, phone calendar timing (G2 may carry final measurement).

**Criterion checks:** §7 `CHK-F15.A1…An` binds every A to a meaningful check and evidence layer; all start PLANNED.

**Stop condition:** close only after every A has evidence or an explicitly named permitted carry; mandatory pending evidence means implemented, acceptance pending. Stop at unresolved local acceptance/resource or the end of authorized scope; continue only independent authorized tasks. No automatic next-task start outside that scope.

**Completion Evidence:** browse/adopt state matrix, cache evidence, renders and device timing status.

**Dependencies / Risk:** F13. No second plan store or automatic retiming.

### TASK F16 — Enter planning through one stable first-run screen

**Priority / status:** P1 approved completion; NOT STARTED. No F acceptance is passed by documentation.

**Sources / decisions:** S16.1, PD-02, RA-B01-06, M2, AUD-04/10, UXA-C2. Accepted choices (§5): D8 = A.

**Problem / Current State:** S16.1, RA-B01–06; Tonight draws before Welcome; Skip/Done duplicate behavior.

**Required Outcome:** first-run routing is correct before the first frame and optional setup is reachable without a dead end.

**Implementation Scope:** `app_router.dart`, startup/Welcome and F05 rig choices. One screen: optional site (GPS on tap or choose), class→rig, title, concise permission rationale, Start planning; no target step/Skip.

**Acceptance Criteria:** A1 loaded first-run flag determines the first frame; no Tonight flash. A2 One Welcome to Culmina screen has concise purpose/permission rationale, optional site and class→rig setup, no target step and no Skip. Both setup steps may be omitted through Start planning; GPS is requested only on explicit tap; denial retains choose/manual paths and planning stays reachable. A3 class-specific labeled manual/photo paths and cancellation work; a rig saved there becomes the plan's rig per D8 and the setup screen shows it (UXA-C2); missing required inputs are explained without fake defaults. A4 first-run/returning-run core-loop, U and W setup checks pass.

**Layer responsibility / files:** `lib/presentation/navigation/app_router.dart`; `lib/presentation/screens/welcome/welcome_screen.dart`; `lib/main.dart`. Presentation owns interaction/labels; existing ViewModels serialize state; domain owns the applicable pure rules; data owns compatible persistence/provider/format behavior. Use only the relevant listed layers, never calculations in widgets.

**UX/state contract:** §9 incorporates SP01, with exact labels/visible-versus-detail hierarchy, applicable empty/loading/error/Unknown/conflict and draft/saved/dirty states, Save/Back/Cancel and outcome feedback. U/W apply; proposals do not count as runtime or owner visual acceptance.

**Data/science invariant:** §8 CP/NC and shared rule 6 apply where relevant: preserve canonical units, Unknown, reviewed local proposals and original history; no provenance or result is invented.

**Verification:** full gate for router/startup shared behavior; first-frame/router/widget and updated core-loop tests.

**Criterion checks:** §7 `CHK-F16.A1…An` binds every A to a meaningful check and evidence layer; all start PLANNED.

**Stop condition:** close only after every A has evidence or an explicitly named permitted carry; mandatory pending evidence means implemented, acceptance pending. Stop at unresolved local acceptance/resource or the end of authorized scope; continue only independent authorized tasks. No automatic next-task start outside that scope.

**Completion Evidence:** first-run state table, launch observation, setup journey and gate.

**Dependencies / Risk:** F05; F10 only for advertising FITS as readable. Startup must not wait for weather.

### TASK F17 — Put night context and the existing plan first on Home

**Owner amendment AM-03:** CRUX-01 accepted 2026-10-18 (Home part), with owner choice AM03-T = B for the page title; see §4 AM-03 and FINALIZATION_REVIEW §35–§36.

**Priority / status:** P1 approved completion; NOT STARTED. No F acceptance is passed by documentation.

**Sources / decisions:** S16.2, PD-03/Q1, RA-D01-06, AUD-09/10, UXA-C3. Accepted choices (§5): D9 = A.

**Problem / Current State:** S16.2, PD-03/Q1, RA-D; current hierarchy duplicates actions and underuses existing night information.

**Required Outcome:** Home leads with night facts and returns clearly to the same plan.

**Implementation Scope:** Tonight/Home presentation; title with field mode, tappable site/night subtitle, night card, Your plan/Open planner, secondary target-candidate action. Remove the redundant Home New plan action while retaining the established plan lifecycle. Home text that describes the plan's night uses the shared plan-night phrase defined with F18 A6 (AM-03).

**Acceptance Criteria:** A1 Title and field-mode toggle share a compact wrapping header; tappable site/night/zone context precedes the night card. Card shows dark interval, phase/moon-free hours, dark-span cloud coverage/freshness and detail links with honest missing/partial/stale/no-dark states. Candidate selection remains a secondary action. A2 Your plan/Open planner resumes the current plan with one context/store. Home has no New plan action; Planner keeps its distinct guarded New plan menu lifecycle. A3 Accepted D9 A keeps Home/Planner subtitle editing the active plan; the night card and Your plan describe the same site/night. Picker Cancel preserves edits/results; separate calendar/forecast viewing is labelled and adopts only through F13 A5. A4 empty/loading/offline/error/saved states, U and relevant W path pass. A5 Home uses the shared plan-night phrase: “tonight” only when the active plan's SessionNight is the current SessionNight, otherwise that night's date (for example “on Fri, Dec 18”). This covers the night card's lines, the candidate action and the candidates screen's title, whose list is for the plan's night. By owner choice AM03-T = B (§5) the bottom-navigation tab label stays “Tonight”, and the page title reads “Tonight” for the current night and the plan's night otherwise (for example “Night of Fri, Dec 18”). Calculations and accepted D9 A context editing are unchanged.

**Additional AM-03 owners:** `lib/presentation/screens/tonight/tonight_candidates_screen.dart`, `lib/presentation/shared/night_text.dart`; one shared phrase helper, no per-screen date logic.

**Layer responsibility / files:** `lib/presentation/screens/tonight/tonight_home_screen.dart`; `lib/presentation/shared/context_line.dart`; `lib/presentation/viewmodels/night_conditions_viewmodel.dart`; `lib/presentation/viewmodels/session_plan_viewmodel.dart`. Presentation owns interaction/labels; existing ViewModels serialize state; domain owns the applicable pure rules; data owns compatible persistence/provider/format behavior. Use only the relevant listed layers, never calculations in widgets.

**UX/state contract:** §9 incorporates SP02/SP08, with exact labels/visible-versus-detail hierarchy, applicable empty/loading/error/Unknown/conflict and draft/saved/dirty states, Save/Back/Cancel and outcome feedback. U/W apply; proposals do not count as runtime or owner visual acceptance.

**Data/science invariant:** §8 CP/NC and shared rule 6 apply where relevant: preserve canonical units, Unknown, reviewed local proposals and original history; no provenance or result is invented.

**Verification:** S; Home states, navigation and lifecycle regressions, affected core-loop keys.

**Criterion checks:** §7 `CHK-F17.A1…An` binds every A to a meaningful check and evidence layer; all start PLANNED.

**Stop condition:** close only after every A has evidence or an explicitly named permitted carry; mandatory pending evidence means implemented, acceptance pending. Stop at unresolved local acceptance/resource or the end of authorized scope; continue only independent authorized tasks. No automatic next-task start outside that scope.

**Completion Evidence:** state captures, browse/adopt assertions and owner visual acceptance.

**Dependencies / Risk:** F13–F15; preserve target-candidate functionality as the approved secondary action. AM03-T was decided B on 2026-10-18; A5 has no remaining owner choice.

### TASK F18 — Make Planner status, next actions and conditions unambiguous

**Owner amendment AM-03:** CRUX-01 accepted 2026-10-18 (Planner part and the shared plan-night phrase); see §4 AM-03 and FINALIZATION_REVIEW §35.

**Owner amendment AM-02:** UX32 actions accepted2026-10-18; see §4 AM-02 and FINALIZATION_REVIEW §33.

**Priority / status:** P1 approved completion; NOT STARTED. No F acceptance is passed by documentation.

**Owner amendment:** AM-01 (2026-10-18), FINALIZATION_REVIEW §31; applicable existing source clauses amended only as explicitly stated.

**Sources / decisions:** S16.3, PD-04/Q1, TD-095, RA-F01-03, M11, AUD-09/10, UXA-C3/C5. Accepted choices (§5): D9 = A.

**Problem / Current State:** S16.3, TD-095, RA-F01–03, CA-05/12; repeated context, long form and stale autosave banner obscure the next action.

**Required Outcome:** empty/partial plans show actionable requirements; computable plans show one status and coherent editing/saving.

**Implementation Scope:** existing planner screen: compact context and actionable site/target/rig/capture readiness, simple capture entry/outputs/Save, target once. AM-01 removes Tonight for this target and its chart/window-list/placeholder from Plan; retain domain fit/window calculations, compact availability/limiting reason and detail links. Remove duplicate weather row; clear the autosave banner after successful save. AM-03 defines one shared plan-night phrase (also used by F17 A5) and applies it to Planner wording; FitAnalyzer/opportunity reason strings are mapped or parameterized without changing any computed value.

**Acceptance Criteria:** A1 The primary simple workflow is intended frames → estimated integration/total duration/storage/relative stacking gain → Save, with compact site/night/target/rig context and working missing-input checklist. Remove Tonight for this target and its chart/window-list/placeholder from Plan for this release; retain ImagingOpportunity/FitAnalyzer, compact availability/fit reason and night/weather detail access. Target appears once; selected-plan-night facts lead. Altitude now belongs in explicitly labelled secondary detail when the selected night differs from now, never presented as an altitude at the planned time. Advanced details remain reachable; only identical global warnings merge. A2 save success clears banner; error keeps recoverable draft and correct status. A3 Cancel/back/browse/adopt follows accepted D9/F13 A5 and agrees with Home/calendar. Adoption/copy preserves the original snapshot/result as saved after any explicit pre-copy Save; Save failure/Cancel stops replacement and derived UI remains consistent. A4 fit and relative gain explanations are visible in W; U and before/after reference-plan scroll record pass. A5 After Planner loads, keep a stable visible Save plan affordance. When existing site/target/rig or other actual save prerequisites are missing, show a readable reason with the direct corrective action; disabled state has adjacent accessible text, not tooltip-only explanation. Eligibility remains the existing domain/lifecycle rule, with no partial-rig model or new restriction on empty plans. Missing weather/network alone is not a new prerequisite. Once eligible, saving/error/retry preserves the draft and correct state; the button never disappears merely because an input is missing. A6 Planner text that describes the plan's night uses one shared plan-night phrase: “tonight” only when the plan's SessionNight is the current SessionNight, otherwise that night's date. This covers status and fit actions (fill or trim to the window, not even one frame fits), per-block what-fits rows, no-window and missing-input reasons including FitAnalyzer and opportunity reason strings, target-card window labels and conditions text. With a plan night other than the current night no Planner text says “tonight”; with the current night the existing wording stays. Windows, fit results and every displayed value are unchanged.

**Additional AM-03 owners:** `lib/presentation/widgets/plan_status.dart`, `lib/presentation/shared/block_text.dart`, `lib/presentation/shared/opportunity_text.dart`, `lib/presentation/screens/home/home_screen.dart`, `lib/presentation/widgets/sky_darkness_widget.dart`; `lib/domain/services/fit_analyzer.dart` for its reason strings only.

**Layer responsibility / files:** `lib/presentation/widgets/capture_plan_widget.dart`; `lib/presentation/viewmodels/capture_analysis_viewmodel.dart`; `lib/presentation/viewmodels/session_plan_viewmodel.dart`; `lib/domain/services/current_session.dart`. Presentation owns interaction/labels; existing ViewModels serialize state; domain owns the applicable pure rules; data owns compatible persistence/provider/format behavior. Use only the relevant listed layers, never calculations in widgets.

**UX/state contract:** §9 incorporates SP03/SP08, with exact labels/visible-versus-detail hierarchy, applicable empty/loading/error/Unknown/conflict and draft/saved/dirty states, Save/Back/Cancel and outcome feedback. U/W apply; proposals do not count as runtime or owner visual acceptance.

**Data/science invariant:** §8 CP/NC and shared rule 6 apply where relevant: preserve canonical units, Unknown, reviewed local proposals and original history; no provenance or result is invented.

**Verification:** S; planner empty/partial/saved/dirty/error tests, saved-plan transitions and fit presentation regressions; AM-03 current-night and other-night wording fixtures with identical fit/window values.

**Criterion checks:** §7 `CHK-F18.A1…An` binds every A to a meaningful check and evidence layer; all start PLANNED.

**Stop condition:** close only after every A has evidence or an explicitly named permitted carry; mandatory pending evidence means implemented, acceptance pending. Stop at unresolved local acceptance/resource or the end of authorized scope; continue only independent authorized tasks. No automatic next-task start outside that scope.

**Completion Evidence:** state/journey matrix, service-backed labels, scroll deltas and visual acceptance.

**Dependencies / Risk:** F06–F09, F11–F12, F15/F17 for general hierarchy/navigation. F10 is conditional only for FITS-specific rows; unavailable FITS never blocks unrelated hierarchy.

### TASK F19 — Complete returning-plan and Logbook actions

**Priority / status:** P1 approved completion; NOT STARTED. No F acceptance is passed by documentation.

**Owner amendment:** AM-01 (2026-10-18), FINALIZATION_REVIEW §31; applicable existing source clauses amended only as explicitly stated.

**Sources / decisions:** S16.4, PD-19, RD-07/RD-09, RA-G01-04, AUD-09/10; COV-01 corrects unsupported Undo. Existing accepted requirements; no new product choice.

**Problem / Current State:** S16.4, PD-19, RA-G; existing records need visible management, saved forecast and target-progress entry points.

**Required Outcome:** a returning user can reuse a target/night, record results and inspect per-target progress while preserving prior records.

**Implementation Scope:** Logbook segment for progress by target, target-row Plan this target, stored forecast in entry, visible rig/target Delete with RD-09 destructive confirmation. Preserve RD-07 Library/Logbook roles.

**Acceptance Criteria:** A1 Each Logbook card distinguishes Result not recorded from Completed/Partly/Not done, with text plus an appropriate icon/tone; never color alone and never elapsed time as completion. Provide direct Record result/Edit result and planned versus recorded integration. Entries/Progress and Plan this target retain RD-07 roles; guarded copies preserve original snapshot/result. A2 Completed/partial/not-done reports save, reopen and update progress consistently. A user may explicitly finish and record the current saved night before dawn; never auto-complete. Current means now is within the stored SessionNight window; future means now precedes that stored start. Future saved nights cannot be marked acquired in advance. This amends only the old report-after-night-end eligibility, not SessionNight/astronomical darkness or automatic saved-plan rollover. Results remain manual reports, not measured acquisition. A3 entry forecast is the stored snapshot with its original age/source, not current weather substituted silently. A4 Visible stored rig/target Delete uses confirmDestructive under RD-09; Cancel/Back/dismissal preserves record/selection/snapshot, confirmed deletion persists and yields a valid derived selection/fallback. No stored-record Undo is added. In-plan Undo remains F06/F09. U and W returning multi-night journey pass. A5 The same early-report eligibility is enforced by domain/repository and UI, using the saved night, not the live selected site/night. A saved-changed plan first resolves explicit Save/Discard/Cancel and reviews the exact saved snapshot; Save failure/Cancel changes no result. Unreadable/legacy records retain honest limitations, no fabricated counts. Stale-form/concurrent-update guards, transaction/event counters, original forecast, corrections and progress remain consistent; future-night refusal, current-before-dawn success, ended-night success, process restart and derived UI checks pass. Show an explanatory unavailable state instead of an unexplained missing action.

**Layer responsibility / files:** `lib/presentation/screens/logbook/session_detail_screen.dart`; `lib/data/repositories/drift_session_repository.dart`; `lib/domain/services/target_progress.dart`; `lib/presentation/shared/delete_patterns.dart`. Presentation owns interaction/labels; existing ViewModels serialize state; domain owns the applicable pure rules; data owns compatible persistence/provider/format behavior. Use only the relevant listed layers, never calculations in widgets.

**UX/state contract:** §9 incorporates SP10, with exact labels/visible-versus-detail hierarchy, applicable empty/loading/error/Unknown/conflict and draft/saved/dirty states, Save/Back/Cancel and outcome feedback. U/W apply; proposals do not count as runtime or owner visual acceptance.

**Data/science invariant:** §8 CP/NC and shared rule 6 apply where relevant: preserve canonical units, Unknown, reviewed local proposals and original history; no provenance or result is invented.

**Verification:** H because result eligibility/reconciliation changes persisted lifecycle behavior; full gate plus targeted early-report, stale-form, saved-context and result event/content/derived-UI checks; records/result/progress and immutable-snapshot tests, stored-record confirmation/Cancel/delete persistence and derived-selection checks; in-plan edit Undo stays in F06/F09.

**Criterion checks:** §7 `CHK-F19.A1…An` binds every A to a meaningful check and evidence layer; all start PLANNED.

**Stop condition:** close only after every A has evidence or an explicitly named permitted carry; mandatory pending evidence means implemented, acceptance pending. Stop at unresolved local acceptance/resource or the end of authorized scope; continue only independent authorized tasks. No automatic next-task start outside that scope.

**Completion Evidence:** saved-content comparisons, result/progress journey and U acceptance.

**Dependencies / Risk:** F03/F06 for new snapshot fields; ResultAction, ResultsViewModel, SavedNightEnd callers and DriftSessionRepository.recordResult must agree on the AM-01 early-report rule. Preserve astronomy/rollover boundaries; no live tracker or new record type.

### TASK F20 — Export recorded acquisitions using the AstroBin CSV contract

**Priority / status:** P1 approved completion; NOT STARTED. No F acceptance is passed by documentation.

**Sources / decisions:** S16.5, Q4, AUD-11, CA-08/M7; receiving contract to refresh at task start. Accepted choices (§5): UX-S R12. TF-01 consistency correction.

**Problem / Current State:** S16.5, CA-08, AUD-11; Culmina filter names are not the receiver's numeric equipment IDs.

**Required Outcome:** existing share/export produces a truthful acquisition CSV with correct unknown and grouping semantics.

**Implementation Scope:** read and cite the current primary CSV contract at task start; freeze receiving field/status/date/count/rejection semantics and map saved snapshot/results. Use the existing export/share plumbing and version the mapping in EXPORT_MANIFEST. Current approved rule: numeric filter column empty; separate light rows by filter, names in row order in share text; compatible calibration counts only. If the receiver contract materially contradicts that rule, amend this task locally before implementation.

**Acceptance Criteria:** A1 fixtures cover completed/partial/not-done/no-result/legacy/mixed-group/multiple-night records; unsupported acquisition data is explicitly unavailable, not fabricated from a plan. A2 unknown stays blank, never invented zero/date; escaping and units match the cited contract. A3 Names never occupy numeric-ID fields; separate filter rows and share-text name order are deterministic. Before sharing, show the same ordered CSV row/filter-name list; no equipment-ID lookup/account/mapping store is added. A4 Calibration counts require supported recorded acquisition evidence AND proven F09 whole-tuple association. A planned or compatible library block never establishes acquired count; ordinary unrecorded manual-result calibration stays blank. Supported historical evidence may supply recorded counts. Mismatched/Unknown coverage stays blank; existing manifest export remains compatible (TF-01).

**Layer responsibility / files:** `lib/data/export/session_manifest_codec.dart`; `lib/data/export/share_session_exporter.dart`; `lib/data/repositories/drift_session_repository.dart`. Presentation owns interaction/labels; existing ViewModels serialize state; domain owns the applicable pure rules; data owns compatible persistence/provider/format behavior. Use only the relevant listed layers, never calculations in widgets.

**UX/state contract:** §9 incorporates SP10, with exact labels/visible-versus-detail hierarchy, applicable empty/loading/error/Unknown/conflict and draft/saved/dirty states, Save/Back/Cancel and outcome feedback. U/W apply; proposals do not count as runtime or owner visual acceptance.

**Data/science invariant:** §8 CP/NC and shared rule 6 apply where relevant: preserve canonical units, Unknown, reviewed local proposals and original history; no provenance or result is invented.

**Verification:** H; independently expected CSV fixtures, parser/format validation and share/export integration.

**Criterion checks:** §7 `CHK-F20.A1…An` binds every A to a meaningful check and evidence layer; all start PLANNED.

**Stop condition:** close only after every A has evidence or an explicitly named permitted carry; mandatory pending evidence means implemented, acceptance pending. Stop at unresolved local acceptance/resource or the end of authorized scope; continue only independent authorized tasks. No automatic next-task start outside that scope.

**Completion Evidence:** dated source URL, field/status mapping, fixtures and gate.

**Dependencies / Risk:** F03/F09/F19. No AstroBin authentication, ID lookup/store, upload integration or new export mode.

### TASK F21 — Persist settings and units with honest save and retry state

**Owner amendment AM-03:** CRUX-02 accepted 2026-10-18; see §4 AM-03 and FINALIZATION_REVIEW §35.

**Owner amendment AM-02:** UX32 actions accepted2026-10-18; see §4 AM-02 and FINALIZATION_REVIEW §33.

**Priority / status:** P1 approved completion; NOT STARTED. No F acceptance is passed by documentation.

**Sources / decisions:** S16.6, PD-20/21, AUD-12, CA-10/M9. Accepted choices (§5): D1 = A.

**Problem / Current State:** S16.6, PD-20, AUD-12, CA-10; preferences are approved, but BackupPreferences currently serializes only bool/int/double values.

**Required Outcome:** Appearance/units and planning preferences have truthful edit/persistence feedback; confirmed values survive restart/restore and consistently affect presentation, with unsaved edits explicitly retryable after failure.

**Implementation Scope:** settings/theme, SettingsViewModel and the preferences repository write/acknowledgement path, `QuantityText`, backup preferences; compatible enum encoding or explicit serializer extension. Apply accepted D1 A neutral/System treatment and document changed AA pairs; field mode remains unchanged. AM-03 applies the same honest-failure rule to the place-name lookup switch.

**Acceptance Criteria:** A1 every preference value round-trips; old backups get documented defaults, unknown future values safe fallback. A2 °C/°F, km/h/mph/m/s, m/ft flow through affected UI/share paths; scientific storage and calculations remain canonical. A3 absolute temperature conversion and temperature-difference/dew-margin conversion are separately tested. A4 Accepted D1 A keeps neutral tokens and System default, including new installs; field mode remains accepted behavior. Light/dark AA vectors and documented existing field-mode exception, U, restart and backup checks pass. No navy/ice-blue redesign or new-install Dark default is inferred. A5 Planning preferences and F21 display/unit updates distinguish in-memory edits from durably confirmed settings. Keep latest edits visibly pending/unsaved when persistence fails; provide actionable failure and Retry of the newest complete configuration. Do not falsely report saved or silently discard edits. Serialize/coalesce completion so older requests cannot mark newer values saved or overwrite them; do not require an architecture/debounce redesign. Reload/restart/backup must expose a coherent confirmed configuration or an explicit recoverable failure, never silently mix partially saved fields. Preserve legacy defaults, snapshot history and existing privacy opt-in semantics. Inject failure at relevant write boundaries, reverse delayed completions and verify retry/latest-value/unrelated-field preservation plus derived UI. Exact compatible write strategy is an implementation detail. A6 The place-name lookup switch follows the same honest-persistence rule: after a failed write the screen never shows a choice different from the stored one unless it is visibly unsaved with Retry, or it restores the stored choice and says so. While Off is shown, no position is sent. Reload and restart show the stored choice. The default (off), consent wording, provider, attribution and call limits are unchanged.

**Additional AM-03 owners:** `lib/domain/repositories/privacy_preferences_repository.dart`, `lib/data/repositories/shared_prefs_privacy_preferences_repository.dart`, with `SettingsViewModel.setPlaceNameLookup` and `OptInReverseGeocoder`; no new privacy setting or policy.

**Additional AM-02 owners:** `lib/presentation/viewmodels/settings_viewmodel.dart`, `lib/domain/repositories/planning_preferences_repository.dart`, `lib/data/repositories/shared_prefs_planning_preferences_repository.dart`; coordinate pending/confirmed UI state, write completion and compatible persisted/backup values through existing boundaries.

**Layer responsibility / files:** `lib/presentation/screens/settings/settings_screen.dart`; `lib/core/utils/quantity_text.dart`; `lib/data/backup/backup_preferences.dart`; `lib/core/theme/app_theme.dart`. Presentation owns interaction/labels; existing ViewModels serialize state; domain owns the applicable pure rules; data owns compatible persistence/provider/format behavior. Use only the relevant listed layers, never calculations in widgets.

**UX/state contract:** §9 incorporates SP11, with exact labels/visible-versus-detail hierarchy, applicable empty/loading/error/Unknown/conflict and draft/saved/dirty states, Save/Back/Cancel and outcome feedback. U/W apply; proposals do not count as runtime or owner visual acceptance.

**Data/science invariant:** §8 CP/NC and shared rule 6 apply where relevant: preserve canonical units, Unknown, reviewed local proposals and original history; no provenance or result is invented.

**Verification:** H when changing persisted preference/write semantics; full gate and injected persistence/concurrency/restart checks; backup/enum, conversion and theme regressions.

**Criterion checks:** §7 `CHK-F21.A1…An` binds every A to a meaningful check and evidence layer; all start PLANNED.

**Stop condition:** close only after every A has evidence or an explicitly named permitted carry; mandatory pending evidence means implemented, acceptance pending. Stop at unresolved local acceptance/resource or the end of authorized scope; continue only independent authorized tasks. No automatic next-task start outside that scope.

**Completion Evidence:** preference/backup and display coverage tables, conversion vectors, contrast evidence and gate.

**Dependencies / Risk:** D1 and F03/F14/F19 presentation contracts. No localization or new scientific thresholds.

### TASK F22 — Restore the open route without corrupting saved or draft state

**Priority / status:** P1 approved completion; NOT STARTED. No F acceptance is passed by documentation.

**Sources / decisions:** S16.8, TD-094/TD-102 durability, AUD-09/13. Accepted choices (§5): UX-S R11.

**Problem / Current State:** S16.8 slice, TD-094 and TD-102's durability probe; data returns after process death but the route does not.

**Required Outcome:** process recreation returns to a valid prior screen and preserves the established data lifecycle.

**Implementation Scope:** router/restoration and existing restorable editor state as needed. Convert the existing plan-name/result/legacy-event kill-and-upgrade probe into a permanent regression; preserve original TD-094 scope without adding a second draft persistence system.

**Acceptance Criteria:** A1 Background process death on Planner and a representative existing form returns to the intended valid route. If its referenced plan was deleted, use a valid fallback and report The plan you had open was deleted. Showing Tonight. Preserve all existing lifecycle/data rules; no second draft store. A2 restored arguments never adopt another site/night or overwrite a saved result; cancel remains safe. A3 named plan and every existing result field, including not-done reason and supported reported events, survive relevant kill and v24→v25→v26 paths. Any unsupported unsaved-form restoration is documented against the existing contract before claiming completion.

**Layer responsibility / files:** `lib/presentation/navigation/app_router.dart`; `lib/presentation/viewmodels/plan_lifecycle_viewmodel.dart`; `lib/domain/services/current_session.dart`; `lib/data/repositories/drift_session_repository.dart`. Presentation owns interaction/labels; existing ViewModels serialize state; domain owns the applicable pure rules; data owns compatible persistence/provider/format behavior. Use only the relevant listed layers, never calculations in widgets.

**UX/state contract:** §9 incorporates SP08/SP10, with exact labels/visible-versus-detail hierarchy, applicable empty/loading/error/Unknown/conflict and draft/saved/dirty states, Save/Back/Cancel and outcome feedback. U/W apply; proposals do not count as runtime or owner visual acceptance.

**Data/science invariant:** §8 CP/NC and shared rule 6 apply where relevant: preserve canonical units, Unknown, reviewed local proposals and original history; no provenance or result is invented.

**Verification:** S, escalated to H if persistence/migrations change; lifecycle matrix, permanent durability regression and emulator process-death test; physical row in G2.

**Criterion checks:** §7 `CHK-F22.A1…An` binds every A to a meaningful check and evidence layer; all start PLANNED.

**Stop condition:** close only after every A has evidence or an explicitly named permitted carry; mandatory pending evidence means implemented, acceptance pending. Stop at unresolved local acceptance/resource or the end of authorized scope; continue only independent authorized tasks. No automatic next-task start outside that scope.

**Completion Evidence:** route/state matrix, old-schema content comparison, process-death results.

**Dependencies / Risk:** F16–F19/F21 before final shared-navigation edits; do not invent restoration behavior for a new form model.

### TASK F23 — Finish existing provider labels and bundled notices

**Owner amendment AM-03:** CRUX-03 and CRUX-04 accepted 2026-10-18; see §4 AM-03 and FINALIZATION_REVIEW §35.

**Priority / status:** P1 approved completion; NOT STARTED. No F acceptance is passed by documentation.

**Owner amendment:** AM-01 (2026-10-18), FINALIZATION_REVIEW §31; applicable existing source clauses amended only as explicitly stated.

**Sources / decisions:** S16.8, TD-097/098/031, accepted S12.4(a), C4, AUD-13/14. Existing accepted requirements; no new product choice.

**Problem / Current State:** S16.8 slice; TD-097/098/031, C4/S12.4. Municipality names and native-library attribution are incomplete; some compliance register statements are stale.

**Required Outcome:** existing location lookup displays supported names, and About/licences reflect the actual approved Android dependencies and distribution.

**Implementation Scope:** existing GPS/site-editor and consented reverse-geocoding path plus Nominatim mapper, About/licence registry, COMPLIANCE and relevant TD-031 entries. Add municipality fallback with documented key precedence. Include actual bundled Android notices and the already accepted Google Play services GPL additional-permission statement. Reconcile policy/provider/dependency claims against current code; preserve opt-in, attribution and call limits. AM-03 adds the coordinate-edit guard for position fixes and the unsaved-position label.

**Acceptance Criteria:** A1 municipality-only response names the place; absent/invalid values still fall back to coordinates; existing precedence stays tested. A2 Dart/native notices and accepted permission are visible and match the build dependencies. A3 each TD-031 subitem is resolved with evidence, retained as an explicit non-blocking limitation, or reported as a concrete release blocker; no generic “all legal risks fixed.” A4 provider changes are not invented to close the register; U passes for changed pages. A5 Use current position in the new-site/editor flow obtains GPS coordinates and automatically proposes a place name through the existing consented lookup. If lookup is disabled, offer its existing opt-in explanation/action without sending coordinates until accepted; coordinates-only/manual entry still works. Lookup never overwrites a manual/existing name or a later name/position edit; ignore stale responses. Loading/offline/not-found/failure never blocks coordinate entry/Save; use an honest coordinate fallback. No site is saved or active saved site looked up until its approved explicit operation. Preserve attribution and update actual privacy/help copy when implemented. A6 In the site editor a position fix from Use current position fills the coordinates only if both coordinate fields are unchanged since the tap. A typed edit or a map pick made while the fix is pending is kept, and the fix is not applied without the user's explicit choice. A reply after leaving the editor writes nothing. Locating never blocks typing, picking on the map or Save. A7 A remembered transient position without a known place name is never labelled “Current position”. Wherever it is shown (Home and Planner context, the Welcome site status, the Sites list) it reads as an unsaved position, with its coordinates where space allows, before and after restart. A saved site keeps its name and a looked-up name keeps its attribution. No automatic GPS request and no change to how a position is chosen or stored.

**Additional GPS/name owners:** `lib/presentation/screens/sites/site_editor_screen.dart`, `lib/presentation/viewmodels/site_viewmodel.dart`, `lib/domain/services/opt_in_reverse_geocoder.dart`; add a narrow draft proposal seam, not a second provider or writes to the active site.

**Additional AM-03 owners:** the transient-position label in `lib/presentation/screens/home/home_screen.dart`, `lib/presentation/screens/tonight/tonight_home_screen.dart`, `lib/presentation/screens/welcome/welcome_screen.dart` and `lib/presentation/screens/sites/sites_screen.dart`, from one shared label; A6's edit check stays inside the site editor's existing state.

**Layer responsibility / files:** `lib/data/services/nominatim_reverse_geocoder.dart`; `lib/presentation/screens/about/about_screen.dart`; `docs/COMPLIANCE.md`. Presentation owns interaction/labels; existing ViewModels serialize state; domain owns the applicable pure rules; data owns compatible persistence/provider/format behavior. Use only the relevant listed layers, never calculations in widgets.

**Data/science invariant:** §8 CP/NC and shared rule 6 apply where relevant: preserve canonical units, Unknown, reviewed local proposals and original history; no provenance or result is invented.

**Verification:** S for mapping/UI; primary provider/licence references only where the active check needs them; native dependency/notice comparison and G1 live checks. Highest actual V1 class applies if dependencies change.

**Criterion checks:** §7 `CHK-F23.A1…An` binds every A to a meaningful check and evidence layer; all start PLANNED.

**Stop condition:** close only after every A has evidence or an explicitly named permitted carry; mandatory pending evidence means implemented, acceptance pending. Stop at unresolved local acceptance/resource or the end of authorized scope; continue only independent authorized tasks. No automatic next-task start outside that scope.

**Completion Evidence:** mapper fixtures, notice inventory, bounded TD-031 disposition and visual evidence.

**Dependencies / Risk:** F14/F21 before final notice/policy alignment; no provider replacement, silent opt-in, licence change, no-Play-services project or Android CI expansion. A7 changes labels on F16–F18 surfaces, which precede F23 in the numbered sequence; no new dependency edge.

### TASK F24 — Close the finite reproducibility and diagnostics checklist

**Priority / status:** P1 approved completion; NOT STARTED. No F acceptance is passed by documentation.

**Sources / decisions:** S16.8, TD-096/102 map/103/038 and bounded 002/020/025 recheck, C6, AUD-13. Existing accepted requirements; no new product choice.

**Problem / Current State:** remaining S16.8 maintenance has named test/diagnostic gaps; several older debt entries describe obsolete code.

**Required Outcome:** current regression evidence is deterministic and the specified diagnostics contracts are enforced, without a general cleanup project.

**Implementation Scope / Acceptance Criteria:** this is the complete bounded six-row checklist including owner-selected UX32-03; add no adjacent debt:

| Criterion / original ID | Required result | Minimum verification |
| --- | --- | --- |
| A1 / TD-096 | Harness/repository tests that depend on night/date use fixed injected clocks | Relevant cases at formerly failing morning/evening instants; no wall-clock flakiness claim based on one run |
| A2 / TD-102 (map half) | Existing all-tiles-fail probe becomes a committed test, with host path_provider fake | Failed tiles preserve usable controls/coordinates and an honest state |
| A3 / TD-103 | Orphan cleanup uses AppLog | Relevant log/cleanup regression and source check |
| A4 / TD-038 | Enable the already planned unawaited_futures rule and resolve actual findings | Analysis; affected async failure-path tests; no unrelated cast/lint campaign |
| A5 / TD-002, TD-020, TD-025 | Recheck only the registered startup/network barrier, site/zone behavior and named historical test gaps | Cite current implementation/tests; close obsolete assertions; fix only a reproduced violation of an established requirement, with a focused regression |
| A6 / UX32-03 (AM-02) | Target search accepts success/error/loading/empty results only for the newest requested query and current mounted generation. A late old response/failure cannot replace a newer list or selection; pending results cannot masquerade as belonging to new text. Respect choose/manage modes and disposal; debounce is optional. Record current reproduction first; if already safe, prove it without unnecessary refactoring | deterministic delayed A/B success and error in reverse order, clear query, disposal/navigation and selection; old result ignored and newest query alone authoritative |

**Additional AM-02 owners:** `lib/presentation/screens/target/target_selection_screen.dart`, `lib/presentation/viewmodels/library_viewmodels.dart`, `lib/domain/repositories/target_repository.dart`; request-generation acceptance belongs in the existing selector/search path, not a second catalog or search service.

**Layer responsibility / files:** `lib/data/database/app_database.dart`; `tool/check.dart`; `analysis_options.yaml`. Presentation owns interaction/labels; existing ViewModels serialize state; domain owns the applicable pure rules; data owns compatible persistence/provider/format behavior. Use only the relevant listed layers, never calculations in widgets.

**Data/science invariant:** §8 CP/NC and shared rule 6 apply where relevant: preserve canonical units, Unknown, reviewed local proposals and original history; no provenance or result is invented.

**Verification:** full gate at the end, as required for S16.8/tooling changes. F22 owns TD-102's other half. Preserve all existing tests; no coverage-percentage target or repeated global test-gap audit.

**Criterion checks:** §7 `CHK-F24.A1…An` binds every A to a meaningful check and evidence layer; all start PLANNED.

**Stop condition:** close only after every A has evidence or an explicitly named permitted carry; mandatory pending evidence means implemented, acceptance pending. Stop at unresolved local acceptance/resource or the end of authorized scope; continue only independent authorized tasks. No automatic next-task start outside that scope.

**Completion Evidence:** six-row checklist with files, evidence, classification of surviving non-blocking items and final gate.

**Dependencies / Risk:** F01–F09 and F11–F23 precede affected maintenance closure; F10 only for FITS-specific checks. F25/F26 are not prerequisites. TD-045's harmless Drift rename workaround remains excluded. A confirmed blocker found in A5 receives a localized task amendment, not an open-ended cleanup mandate.

### TASK F25 — Close consistency, accessibility and workflow acceptance

**Priority / status:** P1 approved completion; NOT STARTED. No F acceptance is passed by documentation.

**Sources / decisions:** S16.7, TD-100/101, K14, M4/M10/M11, AUD-10/13; U/W. Existing accepted requirements; no new product choice.

**Problem / Current State:** S16.7, TD-100/101, CA-05/11/12; the prior sweep misses editors/filter panel/map and cannot prove a keyboard-open dialog fits.

**Required Outcome:** the final changed surfaces satisfy the finite U/W contract with one coherent quantity/theme system.

**Implementation Scope:** repair only observed failures in the named surfaces; extend accessibility coverage to all changed screens, editors, filter panel and map picker; enforce QuantityText usage with a bounded source test. Apply no unapproved visual direction.

**Acceptance Criteria:** A1 every changed surface has U evidence including real glyphs and relevant error/keyboard states. A2 no hand-formatted covered quantity bypasses QuantityText; field mode and approved contrast remain correct. A3 all four W journeys have step records, with fit/Unknown/relative-gain explanations and issues classified; comprehension remains separately labeled. A4 owner final visual acceptance is recorded; no unresolved functional/accessibility blocker remains. Later relevant changes invalidate only affected rows.

**Layer responsibility / files:** `lib/core/utils/quantity_text.dart`; `lib/core/theme/app_theme.dart`; `integration_test/core_loop_test.dart`. Presentation owns interaction/labels; existing ViewModels serialize state; domain owns the applicable pure rules; data owns compatible persistence/provider/format behavior. Use only the relevant listed layers, never calculations in widgets.

**Data/science invariant:** §8 CP/NC and shared rule 6 apply where relevant: preserve canonical units, Unknown, reviewed local proposals and original history; no provenance or result is invented.

**Verification:** full gate explicitly required by S16.7; complete affected accessibility/render inventory and W integration walkthroughs. Reuse valid earlier task evidence rather than replaying every row.

**Criterion checks:** §7 `CHK-F25.A1…An` binds every A to a meaningful check and evidence layer; all start PLANNED.

**Stop condition:** close only after every A has evidence or an explicitly named permitted carry; mandatory pending evidence means implemented, acceptance pending. Stop at unresolved local acceptance/resource or the end of authorized scope; continue only independent authorized tasks. No automatic next-task start outside that scope.

**Completion Evidence:** surface/criterion matrix, W records, owner visual decision, explicit non-blocking/UNVERIFIED gaps and gate.

**Dependencies / Risk:** F05–F24 affected UI work, especially F22–F24, precedes the sweep. FITS-specific W completion requires F10; unrelated checks can proceed earlier.

**Stage C exit:** F13–F25 close; no mandatory UI, lifecycle, science or data-contract blocker remains. Named physical-device repeats and owner release actions continue in Stage D; accepted independent-usability limits stay visible.

### Stage D — Qualify and deliver one signed GitHub release

**Objective:** finish finite integration evidence and publish exactly the artifact tested. Sequence: **G1 → F26 → G2 → G3 → G4**. G1–G4 are acceptance/delivery gates, not extra implementation or research stages.

### G1 — Freeze the final acceptance rows and qualify the pre-packaging baseline

**Aliases:** S17.1–4. Prerequisites: F01–F25 implementation complete; F10 complete or explicitly deferred by the owner; all locally required ADR/visual acceptances recorded. Carried final-device rows need not already pass, but must be listed before evidence collection.

- Use each F-task A-criterion plus the relevant `STAGE_11_MATRIX.md` rows. Mark unchanged evidence reused with baseline and reason; enumerate invalidated/new rows, rather than re-running the historical matrix wholesale. Separate IMPLEMENTED, VERIFIED, UNVERIFIED, OWNER ACTION and DEFERRED.
- Host full gate and corresponding green remote CI on the accepted code; native Android compilation and relevant Kotlin tests. Read actual remote result after authorized push; do not infer it from local success. CA-19's new Android CI job is optional, not a prerequisite.
- Re-run affected emulator L1–L6/L8, backup round trip, permissions, offline and release-build behavior. Retain API 26–30 evidence from F02 if still valid.
- Live Open-Meteo horizon, opt-in Nominatim, OSM tiles, user-opened links and About URLs; reconcile policy/notices/accepted S12.4 with current code. A transient unavailable provider yields recorded failure behavior and an outstanding live row, not an invented success.

**Exit evidence:** frozen finite row list; host/native/emulator/provider results or valid reuse; no host blocker. Required physical rows explicitly assigned to G2. This gate does not demand another roadmap audit.

### TASK F26 — Build and verify the GitHub release artifact

**Priority / status:** P1 approved completion; NOT STARTED. No F acceptance is passed by documentation.

**Sources / decisions:** S17.6, C1, AUD-15/17, CA-13/M12, GitHub distribution. D6 deferred by the owner to the actual measurements (§5).

**Problem / Current State:** S17.6, CA-13, AUD-15; Play-era packaging/size assumptions do not qualify an APK delivered directly from GitHub.

**Required Outcome:** release tooling fails closed on wrong signing/identity/version and produces traceable APKs and install/update instructions.

**Implementation Scope:** existing release scripts/checks, RELEASE.md, version/AppIdentity and CI integration as needed. Verify the expected public certificate fingerprint, not merely absence of debug signing. Owner supplies/manages signing outside the repository; never request/read/commit secrets. Measure universal and arm64 download and installed sizes from the release commit before D6 chooses distribution. Add a stable artifact name, SHA256SUMS, published certificate fingerprint, change/known-issue/data notes, installation/checksum/update and old-id migration instructions.

**Acceptance Criteria:** A1 absent/debug/wrong certificate is refused; selected APKs use `io.github.buffur.culmina`, expected signer, matching pubspec/AppIdentity version, increasing versionCode, required SDK settings and 16 KB native-library alignment. A2 D6 uses actual measured sizes; every selected APK is checked and hashed. A3 final code/tooling/version inputs pass the full gate and actual remote CI on the release commit; native build/Kotlin results are valid for those inputs. A4 commit/toolchain/id/version/certificate/APK SHA-256 and live policy URL are recorded. A5 signature-mismatch instructions require a verified independent backup before any owner-authorized uninstall; no destructive action is automated as a packaging shortcut.

**Layer responsibility / files:** `tool/check_bundle.dart`; `docs/RELEASE.md`; `lib/core/config/app_identity.dart`; `pubspec.yaml`. Presentation owns interaction/labels; existing ViewModels serialize state; domain owns the applicable pure rules; data owns compatible persistence/provider/format behavior. Use only the relevant listed layers, never calculations in widgets.

**Data/science invariant:** §8 CP/NC and shared rule 6 apply where relevant: preserve canonical units, Unknown, reviewed local proposals and original history; no provenance or result is invented.

**Verification:** H; release-check rejection/success cases, native build/Kotlin checks, artifact metadata/signature/alignment/hash inspection and remote CI. Public CI needs no private release key; local production-artifact evidence is recorded separately.

**Criterion checks:** §7 `CHK-F26.A1…An` binds every A to a meaningful check and evidence layer; all start PLANNED.

**Stop condition:** close only after every A has evidence or an explicitly named permitted carry; mandatory pending evidence means implemented, acceptance pending. Stop at unresolved local acceptance/resource or the end of authorized scope; continue only independent authorized tasks. No automatic next-task start outside that scope.

**Completion Evidence:** reproducible release manifest, selected checked APKs, checksums, public fingerprint, release notes/instructions and green final-input gate/CI.

**Dependencies / Risk:** G1, D6 measured-size choice and owner-managed signing. Packaging precedes phone qualification. Any changed/rebuilt artifact needs its affected G2 checks again.

### G2 — Qualify the actual release candidate on the phone

**Aliases:** S17.5; carried S11.6, S2V-06, S3V-08, S13V-02/03. Prerequisites: F26; actual APK SHA-256 recorded. Production artifact runs on a clean device/profile or explicitly approved installation. Development and cross-id rehearsals use isolated test packages; neither substitutes for the other's evidence.

Required finite rows:

1. Core loop L10: setup → site/night/target/rig → photo/manual block proposal → calibration → fit/storage → Save → restart → reopen → record/edit result → progress; all four W journeys completed, no saved-data mutation from browsing/cancel.
2. Add and Take from a photo: real DNG/JPEG/HEIC and FITS where mandatory; review and save a FITS rig. Existing M1/M4, S2V-06 and S3V-08 outcomes carried by exact runbook criteria.
3. TalkBack H6/H7, field mode in darkness, changed controls and reduced motion. Runbook M3/M4 performance plus calendar/forecast overview. Record device/settings/data volume and applicable existing thresholds; first-frame and visible-content startup times separately, preserving the accepted held splash. No screenshots-only timing or comprehension PASS.
4. Literal restore activation per D7, including returning from Recents; the outcome message after an applied and after a refused restore (UXA-C1); corrupt candidate refusal at pick time and preservation; interruption/restart path. Isolated old-id/shipped-old-schema→new-id/final-schema rehearsal includes aliases, rig/block values/origins, snapshots/forecasts, all result statuses, supported legacy events and preferences. Compare contents **and derived UI** before touching owner data.
5. Clean install and same-key update of the actual selected production artifact(s). If no previous public build exists, use a release-signed lower-versionCode precursor, create representative data, install candidate over it and verify preservation. Otherwise use previous public release. A debug-key installation is not update evidence.
6. After all rehearsal checks pass, the owner performs the documented old-app backup/restore migration, if owner data needs migration; record completed or genuinely not applicable with the owner's confirmation. Never uninstall an owner app or move its data without that authorization.

**Exit evidence:** artifact hashes linked to device observations and content comparisons; every mandatory phone/manual row VERIFIED. Unavailable device/person/owner action stays outstanding; no functional-completion claim substitutes for release readiness. The accepted S6.E independent-participant limitation remains separate.

### G3 — Record one release go/no-go

**Alias:** S17.7/S11.7. In a fresh session where practical, inspect the frozen rows and evidence. Readiness requires all mandatory F-criteria and G1/G2 rows verified, no unresolved release-blocking defect, and explicit disposition of optional/deferred rows. List accepted non-critical debt and the independent-usability limitation. The owner records go/no-go. This is evidence reconciliation, not another audit or new acceptance criteria.

### G4 — Publish and verify the tested download

**Alias:** S17.8. Only after owner go and explicit publication authorization: tag `vX.Y.Z` on the release commit; publish selected APKs, SHA256SUMS, certificate fingerprint and notes; update README installation link. Download from the published release, compare hash and expected signer with G2, install on the phone and run the core loop once. Record release URL/tag/hash/result in PROGRESS. A rebuilt binary is a new candidate, not the previously tested artifact.

**Stage D / roadmap exit:** F01–F26 and G1–G4 complete, or an explicit owner scope amendment removes a named requirement. All remaining limitations are non-blocking/accepted or out of scope; no mandatory row is silently waived. If publication is intentionally postponed, record **implementation/qualification complete; publication pending**, not roadmap finished.

## 4. Reconciliation matrix

**Criterion-level source register:** [FINALIZATION_REVIEW](FINALIZATION_REVIEW.md) §§4–10 is an integral, immutable source/disposition annex of this execution version: concatenate those complete numbered sections in order, UTF-8/LF; SHA-256 `6540a122600e619fefe76bd1de8bfdd7a2be24b6b127c593c916a24d4b219996`. It individually accounts for original review/A09/CA/M/AUD/readiness/UXA/PD decisions, 42 old task aliases and their 167 clauses, optional/excluded/completed rows, every F reverse source, debt and carried release rows. These are clause records, never a second execution queue. Original source wording and P1 evidence/status are historical; accepted D/UX-S in §5 and corrected current F/A/CHK contracts here supersede only their affected dispositions. The source ID → F/A mapping remains explicit in each annex row; resolve that A to §7 for its current behavior/check. Changes to a bound annex section require an explicit affected-baseline amendment, not silent edits. P7/future appendices outside the bound sections do not change the hash.

The concise matrix below is an index only. Generic F25 coverage never replaces a specific behavioral A. COV-01/02/03/05/06/07 and TF-01 are bound in the affected task criteria, this register and §8/§9; no unassigned source is dismissed merely because it appears in a broad group. The inverse F→source→A→check path is supplied by every task's Sources and §7. Existing aliases and declined/merged/completed dispositions are retained without reopening closed research/stages.

Decisions: **Implement**, **Verify Within Task**, **Complete**, **Merge**, **Exclude**, **Decision Required**. “Complete” refers to current repository records, not a new test run. Grouped ranges below include every ID in that range.

### Original task aliases

| Original ID | Review finding / issue | Decision | Final Task ID | Reason |
| --- | --- | --- | --- | --- |
| S12.1/3/4; S13.1/2 | C4; AUD-14; CA-17 | Complete | F23/G1 only for already assigned residual notices | CI/identity/policy/decision work closed; do not redo |
| S12.2 | Trademark check | Exclude from mandatory work | — | Optional existing owner action |
| S13.3; S13V-01/02/03 | TD-109 and carried device evidence | Implement / Verify Within Task | F02/G2 | Correct only failed criterion; retain other PASS |
| S14.1; S14.3(1–6) | AUD-04/05/06/16; CA-22 | Merge | F03 | One accepted capture contract and compatible persistence outcome |
| S14.3(7–9) | TD-106; CA-01/16/23 | Implement | F01 | Safety independent of schema design |
| S14.2 | CA-02 | Implement | F05/F16 | Shared rig path and its onboarding caller |
| S14.4 | AUD-06 | Implement | F04 | Common typed reader contract |
| S14.5 | CA-06/15 | Implement | F10 | Sample-gated end-to-end FITS integration |
| S14.6/8 | CA-04/12; AUD-03/06 | Merge | F06 | Block values, origins and WB share edit/round-trip outcome |
| S14.7 | CA-07/18; AUD-05 | Implement | F07 | Compatible storage evidence |
| S14.9 | TD-072; C3 | Implement | F08/F10 | Non-FITS path proceeds before sample-gated FITS |
| S14.10/13 | CA-03; AUD-02 | Merge | F09 | Calibration closes replacement flow before example action removal |
| S14.11 | AUD-16 | Implement | F11 | Relative curve with comparability boundaries |
| S14.12 | TD-074 | Implement | F12 | Effective assumptions and fit guidance |
| S15.1/2/3 | SI-015; AUD-07 | Merge | F13 | Accepted night contract and one lunar definition |
| S15.4/5 | CA-09; AUD-08 | Merge | F14 | Request/cache/summary/cards form one weather outcome |
| S15.6 | AUD-07/09 | Implement | F15 | Consistent calendar with safe browsing |
| S16.1/2/3/4/5/6 | AUD-09–12 | Implement | F16/F17/F18/F19/F20/F21 respectively | Preserve each independently verifiable flow |
| S16.8 | AUD-13; C4/C6 | Merge into bounded slices | F01/F22/F23/F24 | Wording, lifecycle, provider notices, finite regressions |
| S16.7 | CA-05/10/11/12; AUD-10/13 | Implement | F25 | Final sweep follows maintenance |
| S17.1/2/3/4 | C1; AUD-14/15 | Merge | G1 | One finite pre-packaging evidence gate |
| S17.6 | CA-13; AUD-15/17 | Implement / Decision Required at F26 (D6 deferred to measured sizes, owner 2026-10-18) | F26/D6 | Package before phone; measure before ABI choice |
| S17.5; S11.6 | CA-14/16; C2 | Verify Within Task | G2 | Exact artifact, migration and phone evidence |
| S17.7/8; S11.7 | C1; AUD-15 | Merge | G3/G4 | Go/no-go then authorized publication |

### Audit/review dispositions

| Original ID | Review Finding | Decision | Final Task ID | Reason |
| --- | --- | --- | --- | --- |
| CA-01/16/23; M1; AUD-01; TD-106 | Unsafe activation and unreachable recovery promise | Implement; D2 A (no Undo control, one newest safety copy) | F01/G2 | Production validation, coherent restart, truthful instructions |
| CA-02; M2; AUD-04 | Hidden photo rig path / required-input barrier | Implement / Verify Within Task | F03/F05/F16 | Expose existing import; preserve required-input invariant |
| CA-03; M3; AUD-02; TD-107 | Tuple matching and filter identity | Implement | F03/F09 | Whole tuple, normalized comparison, no alias guessing |
| CA-04; AUD-03; TD-108; RA-F05 | Filter loss and exposure leakage | Implement | F06/F08/F10 | Preserve values through manual and imported edits |
| CA-05; M4; AUD-10 | Unjudgeable UX claims | Merge | U/W, F25/G2 | Observable steps separated from human understanding |
| CA-06; M5 | FITS rig mapping missing | Implement | F03/F04/F10/G2 | Already approved RG-03 path, once-only normalization |
| CA-07; M6; AUD-05 | Unread RAW size / storage assumptions | Implement (D3–D5 A, owner 2026-10-18); exact encoding/vectors at ADR-021 | F03/F07 | File length is not decoded mode evidence |
| CA-08; M7; AUD-11 | Numeric AstroBin filter IDs and calibration counts | Implement / Verify Within Task | F20 | Blank ID, ordered name annotation, proven calibration match |
| CA-09; M8; AUD-08 | Forecast lead/coverage and dark-span meaning | Implement | F13/F14 | UTC slicing, per-variable coverage, visible lead time |
| CA-10; M9 | Brand tokens/default appearance | Implement (D1 A, owner 2026-10-18: neutral tokens, System default) | F21/F25 | No navy/ice-blue token change or new-install Dark default |
| CA-11; M10 | Placeholder-glyph review renders | Merge | U/F25 | Real typography evidence |
| CA-12; M11 | Planner/editor density | Merge | U/F06/F18/F25 | Measured growth and reachable controls, no new redesign |
| CA-13; M12; AUD-17 | APK sizes under GitHub delivery | Decision Required at F26 (D6 deferred to measured sizes, owner 2026-10-18) | D6/F26 | Measured ABI choice; Play-delivery premise superseded |
| CA-14; M13 | First-release update path | Verify Within Task | G2 | Lower-version same-key precursor when no public predecessor |
| CA-15; M14 | FITS sample stalls unrelated work | Merge | F03/F10 dependency rule | Only FITS and final close wait |
| CA-17; M15; AUD-14 | Stale registers and severity | Complete | Current PROGRESS; F02/G2 residual | Applied at b6e8c1e; do not recreate documentation task |
| CA-18; M16 | Storage units | Merge | F07/F25 | Decimal QuantityText MB/GB |
| CA-19 | New Android CI job | Exclude | G1/F26 still require native evidence | Optional infrastructure, not a missing build check |
| CA-20 | Releases link/updater | Exclude | — | Optional new UI; no automatic updater |
| CA-21 | No-Play-services documentation/check | Exclude | — | Optional expansion; preserve accepted location decision |
| CA-22 | Numbered technical decisions | Merge | F03 | Bounded decision presentation within implementation |
| CA-24 | Planning/documentation overhead | Merge | This roadmap / handoff | One active queue, compact evidence, no new audit |
| AUD-06 | Shared metadata/provenance semantics | Implement | F03/F04/F06/F08/F10 | One contract, not a second parser |
| AUD-07; SI-015 | Moon frame/predicate/interval consistency | Implement | F13/F15 | Shared definition and reference vectors |
| AUD-09 | Browsing overwrites saved context | Verify Within Task | F15/F17–F19/F22 | Existing lifecycle preserved across new entry points |
| AUD-12 | Preference serializer and units | Implement | F21 | Typed restore and canonical calculations |
| AUD-13 | Maintenance after final sweep | Merge | F22–F24 before F25 | Avoid invalidating final acceptance unnecessarily |
| AUD-15 | Signing/native/artifact continuity | Implement / Verify Within Task | G1/F26/G2/G4 | Expected signer and actual tested download |
| AUD-16 | Relative graph grouping | Implement | F03/F11 | Honest normalized quantity, no physical SNR |
| C1/C2/C3 | Release order / migration / photo dependencies | Merge | G1→F26→G2→G3→G4; F03–F10 | Retain accepted corrections |
| C4/C5/C6 | Notices / direction / traceability | Merge / Complete | F23; source authority; F24 | Preserve accepted direction and finite debt scope |
| UXA-C1 (UX audit C1) | Restore waits indefinitely; its outcome is never shown | Implement; D7 A (immediate activation) | F01/G2 | Pick-time refusal, immediate non-editable activation with no pending state, the outcome reported once |
| UXA-C2 (UX audit C2) | A rig created from a missing-rig action is saved, not chosen | Implement; D8 A | F05/F16 | Finishing the action gives the plan its rig |
| UXA-C3 (UX audit C3) | Browse versus adopt never designed | Implement; D9 A, recorded in ADR-022 | F13/F14/F15/F17/F18 | One rule for every night and site control |
| UXA-C4 (UX audit C4) | Rig and block editors discard input on Back or a tap outside | Implement | U/F05/F06/F08 | The site editor's guard (TD-084) for the two longer editors |
| UXA-C5 (UX audit C5) | No labelled next step in the empty Capture Plan once the example action goes | Implement | F09/F18 | The replacement empty state ships with the removal |

**Earlier owner-review coverage remains explicit:** RA-A01/05/07/08/09→U/W/F25; A02/03/F10→F11; A04→F03/04/07/10; A06→F17/18; A10/I01→this consolidation; B01–06→F16; C01/02→completed identity plus optional S12.2; C03/04→F02/F14 and existing AppMotion; D01–06→F17; E01→F13/15; E02–05→F14; E06→F19; F01–03→F18; F04→F09; F05→F06; F06→F05/16; F07→F04/06/08/12; F08→F09; F09→F12; F11→F03's record-only contract; G01–04→F19; G05→G2; H01–03→F21, localization excluded; I02→completed S12.1; I03/04→completed identity/decision plus F23/F26/G4, optional trademark and deferred licence change; I05→execution order/G1. K1/K2 are already closed, K13 remains historical; K3–K12/K14 are covered by these corresponding RA findings.

**Debt accounting:** TD-106→F01; 109→F02; 108→F06; 072→F08; 107→F09; 074→F12; 049→F14; 095→F18; 094 and 102 durability→F22; 097/098/031→F23; 096/102 map/103/038/002/020/025→F24; 100/101→F25; 105→F01. TD-104/088/093 and TD-099's published wording are completed; F14/G1 check the changed forecast implementation against that policy. TD-045 excluded. No unrelated debt-cleanup requirement is created.


### AM-01 source → criterion → check reconciliation

| Owner requirement / disposition | Current task criteria | Check / compatible consequence |
| --- | --- | --- |
| Portable project paths and Examples references / ACCEPTED | shared AM-01 rule; §9.1; Examples index | Local links resolve; no normative user-profile path; supplied JPEG copied unmodified and hash-checked |
| Simple core Capture Plan / ACCEPTED, existing science retained | F06 A5, F11 A3, F18 A1; §8 CP | Basic frame entry/four outputs/Save; relative gain baseline and Details; no absolute SNR/no opaque defaults |
| Interactive Night & Moon time exploration / ACCEPTED | F15 A1/A5; F13 A1–A5 unchanged | Cursor-only state with local zone/date, interval truth, text/field/large-text and original-plan preservation |
| Visual Night Weather / ACCEPTED | F14 A3/A5 | Real hourly graphics/selection and gaps; coverage/age/provider invariants retained |
| Temporarily remove Tonight for this target from Plan / ACCEPTED, supersedes compact-chart UI clause | F18 A1; SP03 | Block and placeholder absent; ImagingOpportunity/FitAnalyzer and compact availability/reason remain |
| Group Settings by necessity/consequence / ACCEPTED | F12 A1/A4, F21 unchanged persistence | Basic/advanced/guidance groups; unchanged effects/values and same-plan Back/global notice |
| GPS automatically proposes name with consent / ACCEPTED | F23 A1/A5 | Existing provider/opt-in, blank-only proposal, manual-edit/position race, offline fallback; no write before Save |
| Visible Logbook outcome and explicit early completion / ACCEPTED, amends report-after-night-end eligibility only | F19 A1/A2/A5 | Distinct no-result vs not-done; UI/repository parity, saved snapshot/dirty/counter/progress/history safeguards |
| Original adjacent findings / accepted later by AM-02 | UX32-01–05 → AM-02 table below | Preserve original evidence level; new subsequent review findings remain proposals |


### AM-02 accepted actions → criterion → check

| Accepted action / source | Current task / criterion | Required outcome / boundary |
| --- | --- | --- |
| UX32-01 stable Save readiness | F18 A5 | Save remains visible after load with an accessible reason/direct action; retain actual save eligibility, no partial-rig model |
| UX32-02 distinguish block versus plan apply | F06 A6/A7 | Add block/Apply changes versus Save plan, existing working-plan autosave/Undo and Cancel semantics |
| UX32-03 newest-query search | F24 A6 | Controlled reverse-completion reproduction/check; stale success/error ignored, no forced refactor if already correct |
| UX32-04 honest settings persistence | F21 A5 | Keep newest edits visibly unsaved/pending with Retry; coherent confirmed state and latest-write acknowledgement, no invented current corruption |
| UX32-05 planning-time context | F18 A1 | Selected-night facts lead; explicitly labelled current-sky altitude is secondary where unrelated to that plan |

These five actions are now accepted scope, while the original evidence remains CODE or an unexecuted potential scenario. Exact compatible write/request-generation mechanisms are local engineering choices. No new provider, data model, partial rig, scientific calculation or automatic implementation start is approved. Future Claude findings are assessment-only proposals unless the owner explicitly selects them.

### AM-03 accepted findings → criterion → check

| Accepted finding / source | Current task / criterion | Required outcome / boundary |
| --- | --- | --- |
| CRUX-01 plan-night wording (FINALIZATION_REVIEW §34.4) | F18 A6 (shared phrase, Planner); F17 A5 (Home, candidates) | “tonight” only for the current night, otherwise the date; no value, window or fit change; D9 A unchanged |
| CRUX-01 Home title | Owner choice AM03-T = B (§5), in F17 A5 | Tab label stays “Tonight”; page title “Tonight” for the current night, the plan's night otherwise; no IA, route or tab change |
| CRUX-02 place-name opt-out failure | F21 A6 | No shown choice different from the stored one without an unsaved cue and Retry or a stated restore; nothing sent while Off is shown; default and consent unchanged |
| CRUX-03 GPS fix after a manual edit | F23 A6 | Fix applies only to unchanged coordinates; typed or map-picked values kept; no write after leaving |
| CRUX-04 “Current position” label | F23 A7 | Unsaved-position label with coordinates where space allows; no automatic GPS or storage change |

CRUX-05 and CRUX-06 were not selected: they stay proposals in §34 (CRUX-06 is covered by F09's example retirement). The HOST evidence for the four accepted findings stays as recorded in FINALIZATION_REVIEW §34 and its evidence directory; it is not acceptance of any criterion. No new task, dependency edge, provider, data model, calculation or release gate.

### AM-04 familiar capture parameters → criterion → check

| Owner clarification | Existing criterion / check | Boundary |
| --- | --- | --- |
| Familiar exposure, ISO, WB and AF/MF; no mandatory binning or ISO/GAIN choice for ordinary camera users | F06 A5 / CHK-F06.A5; SP05 | Explicit class chooses sensitivity; optional basic Phone/DSLR values, fractional/decimal exposure; astro binning in Details; preserve Unknown and hidden history |
| Optional descriptive focus record and round trips | F03 A1/A3, F06 A4, F12 A3 and their CHK rows; §8 CP | Unrecorded/AF/MF, no numeric focus/control, no guessed metadata or new matching/science dimension; v26 encoding in ADR-021 |
| Calibration remains simple and correct | F09 A2 / CHK-F09.A2 | Same familiar review fields; preserve the modeled tuple, LENR, proposal/Cancel/Undo and separate flat exposure |

## 5. Accepted choices, exclusions and local prerequisites

**Owner answer, 2026-10-18:** `D1–D5, D7–D9: A; D6: після вимірювань; UX-S: A` [“D6: after measurements”] to FINALIZATION_REVIEW §26. These were semantic P6 decisions; P8 subsequently approved base -02, and AM-01 amends only the explicitly listed outcomes. Recommendations in historical audits do not override this answer. DECISIONS E.1 records the same bounded acceptance.

| ID / prior authority | Accepted behavior / retained checkpoint | Dependent scope |
| --- | --- | --- |
| D1 / CA-OD1 | A: neutral tokens and System default, including new installs; existing field mode retained. No navy/ice-blue treatment or new-install Dark default | F21 A4/F25 visual rows |
| D2 / CA-OD3 | A: no Undo-last-restore UI; truthful Back up first recovery; one newest safety copy with deterministic interrupted-activation recovery. Prune only after safe successful activation, never the pending/only recovery copy | F01 A3/A4 and ADR-021 reconciliation |
| D3 / CA-07 | A: positive length of one recognized-but-unread picked file may estimate one-frame measured storage, with unread-mode/content-variable-size warning; no inferred geometry/compression, manual remedy remains | F03 A1/A3; F07 A4 |
| D4 / PD-06, CA-06 | A: normalize evidenced native/output binning once for theoretical geometry; never rescale measured output; ambiguous writer conventions remain Unknown. Concrete independent vectors/acceptance still local to ADR-021 | F03 A1; F07 A1/A2/A5; F10 A2 |
| D5 / PD-08, C3 | A: persist per-field origins and block measured bytes with format/mode/source association, additive to legacy snapshots/manifest; missing legacy origin unrecorded. Exact encoding/migration remains ADR-021 | F03 A1–A4; F06 A2; F07/F08/F10 associations |
| D6 / CA-OD2 | Deferred as explicitly answered: universal-only versus arm64 primary plus universal after actual download/installed-size measurements. No variant/size chosen now | F26 A2 and downstream selected-artifact gates; measurement candidates may be produced first |
| D7 / UXA-C1; TASK 14.4 amendment | A: confirmation Restore and restart enters immediate non-editable activation/restart in-process. This supersedes TASK 14.4's next-start timing for this completion implementation. Report actual durable outcome once; no editable pending gap | F01 A4/A5 and G2 row 4 |
| D8 / UXA-C2; RD-04 | A: rig created from invoking plan's missing-rig/onboarding action is saved and selected for that plan, returns to caller and reports result. Library creation saves only; Cancel selects/writes nothing | F05 A5; F16 A3 |
| D9 / UXA-C3; ADR-019 §5 | A: Home/Planner context edits active plan; calendar/day/forecast-card views browse with viewed-versus-plan labels. Only Plan this night adopts. Draft edit or guarded saved-plan copy, explicit Save/Discard/Cancel semantics and original preservation as in F13 A5; no second store | F13 A5; F14 A6; F15 A2/A3; F17 A3; F18 A3 |
| UX-S / UX10 bounded set | A: R1 backup-first button; R3 same-plan Settings return; R6/R9 inline proposal/source and detailed disclosure; R8 labelled CAL-1/missing-flat entry only; R11 deleted-plan fallback message; R12 ordered CSV row-name preview | Explicitly bound into F01 A4/F06 A2/F08 A1/F09 A2/F12 A4/F20 A3/F22 A1 |

UX-S does not include R8 include switches, all remaining R/N, a release updater, extra provider, recruitment or a new research stage. The remaining optional/excluded dispositions remain in the incorporated source ledger (§4).

**AM-01 decisions:** the owner accepted the seven-point assessment and simple Capture Plan emphasis; current/task-specific AM-01 criteria override the affected prior clauses. D1–D9/UX-S otherwise remain as recorded. This is not a new implementation start.

**AM-04 decision:** the owner prioritizes familiar capture parameters (exposure, ISO, WB, AF) and removes mandatory technical selection from the simple flow; F03/F06/F09/F12 implement the bounded record/UI contract above. No hardware-control feature or automatic setting recommendation is introduced.

**AM-03 decisions:** the owner selected CRUX-01–CRUX-04 (§4 AM-03) and asked for the Home title choice to be proposed separately. The owner then chose **B** on 2026-10-18 («AM03-T: обираю варіант B (вкладка лишається Tonight, заголовок сторінки показує ніч плану)» [“I choose option B: the tab stays Tonight, the page title shows the plan's night”]); the options stay recorded:

| ID | Choice | Options | Recommendation | Status |
| --- | --- | --- | --- | --- |
| AM03-T | What Home's page title says when the active plan's night is not the current night (D9 A keeps Home editing that plan; SP02 drew the title “Tonight”) | **A** keep “Tonight” as tab label and page title, and add a line under it naming the plan's night. **B** keep the tab label “Tonight”; the page title is “Tonight” for the current night and the plan's night otherwise (for example “Night of Fri, Dec 18”). **C** rename tab and title to one neutral name for every night, which changes the ADR-015 tab naming, glossary and navigation tests | **B**: honest, the smallest change that removes the contradiction, and no IA change | **Decided B** (owner, 2026-10-18); bound in F17 A5 |

**Local checkpoints, not new global planning:** F03 obtains the numbered ADR-021 encoding/migration/source-vector acceptance before dependent persistence/science work. F13 obtains ADR-022 frame-equivalence/reference/forecast-rounding/cache contract acceptance, incorporating already accepted D9; it does not ask D9 again without a demonstrated conflict. P3 sketches are layout fixtures, not scientific vectors or owner final visual acceptance. F03 raises real FITS availability early; missing sample blocks only F10/FITS-specific completion and eventual G1 unless explicitly deferred with consequences. DNG/JPEG/HEIC real samples, physical phone/native/IME/process-death and owner visual rows remain named evidence requirements. Signing is owner-managed externally; agent never accesses secrets. Commit/push, owner data operations and publication require their separate authorizations.

**Excluded:** new partial-rig model, specification/catalog expansion, proprietary RAW decoding, absolute SNR or new exposure science, additional weather/seeing provider, hardware control/live tracking, project goals, sky map/framing/mosaic, localization, notifications/updater, speculative architecture cleanup, optional CA-19/20/21, TD-045, RD-02 housekeeping. GPL stays with recorded additional permission. App-store upload keys/App Signing, AAB requirements, Data Safety/store listing and Play testing remain deferred. Trademark remains optional. Keep valid science and capabilities; remove only approved UI actions with their replacements, preserve data/export compatibility.

## 6. Claude handoff and progress accounting

At task start read `PROGRESS.md`'s current state and next action, the named task here, U/W if UI is touched, its accepted ADR/requirement sections, and relevant guardrails. Inspect only the affected code/tests. The task specification is the implementation brief; do not reconstruct audits or create a new task-planning document. Ordinary local engineering planning stays inside the task.

Implement → verify at the cumulative diff's V1 class → check each A-criterion → self-review → update affected records → coherent commit if authorized → advance or stop according to the authorized run. Push/publication require their existing explicit authorization. Present owner reviews as concrete renders or numbered contract choices, not open-ended design sessions. If a genuine unresolved product/data/scientific choice appears, ask only that local question and continue independent authorized work. Accepted behavior is not reopened because a new agent prefers another design.

**Current authority:** P8 and AM-01–AM-04 are recorded in PROGRESS/DECISIONS; this file is the execution queue and old Stage/task IDs remain aliases. Keep historical reports intact. Maintain one current task/status table and compact completion rows in PROGRESS; do not paste the entire roadmap there. Record an evidence carry once, then close it at the named gate.

| Accounting item | Proposed baseline |
| --- | --- |
| Remaining stages | **4**: A safety/startup; B Capture Plan; C night/screens/records; D release |
| Mandatory implementation tasks | **26**: F01–F26 (A: 2; B: 10; C: 13; D: 1) |
| Additional acceptance/delivery gates | **4**: G1 pre-packaging; G2 phone/artifact; G3 go/no-go; G4 published download |
| Complete new tasks at proposal time | **0/26**; this consolidation implements nothing |
| Immediate task after the separate start | **F01**, then F02; F03 contract/schema follows |
| Main dependency chains | F03→F04/F05→F06→F07→F08→F09; F10 joins with real sample; F13→F14/F15→F17; F22–F24→F25; G1→F26→G2→G3→G4 |
| Unresolved owner-choice entries | **1**: D6, deferred by the owner to the measured F26 sizes. AM03-T (the Home title) was decided B on 2026-10-18 (§5). D1–D5 and D7–D9 were answered A on 2026-10-18 (§5). The ADR-021 (F03) and ADR-022 (F13) local acceptance checkpoints remain; they settle exact encodings and reference vectors, not new product choices |
| Global replanning/review prerequisites | **None** |
| Finished | All mandatory task/gate criteria evidenced; no release blocker; tested artifact published/checked; outstanding optional limits explicitly classified |

**One focused consistency pass:** verify original-task/review coverage, approved scope, dependency order, objective criteria, proportional checks and finite closure; correct material omissions once before presenting for approval. After that, stop planning. Future corrections use the local change-control rule, never a standing request to review the whole roadmap again.

## 7. Criterion verification register

This register is normative for check allocation, not execution evidence. Every row is **PLANNED / NOT EXECUTED for the future implementation**. The A text in its task is authoritative; this register binds the same ID to an objective check. Existing named test files are reused/extended during the authorized task; no test existence is called PASS. Task Verification plus CLAUDE.md V1–V8 determines the command/risk class. U adds real-font renders/accessibility and applicable actual keyboard/device/owner rows to changed surfaces; W records functional steps separately from human understanding. CODE alone never closes behavioral, migration, device or human criteria. Allowed final-device carries are named G2 rows, not waived acceptance.

Commands already present in the repository: `dart run tool/check.dart` (full gate); the task's existing tests via Flutter test runner; targeted analysis/format/encoding as required by CLAUDE. Do not invent release-tool flags or signing commands; inspect the implemented tool's help/RELEASE procedure when it exists. Historical evidence reuse is governed by V3, with baseline/input justification.

| Criterion | Required behavior (current contract) | Meaningful check / independent expected outcome | Evidence layer; status |
| --- | --- | --- | --- |
| CHK-F01.A1 | valid ZIPs containing truncated SQLite, missing expected schema, and unsupported/newer versions are refused at pick time, before the confirmation and before live DB/preferences change; activation repeats the check. | valid ZIPs with truncated/missing/newer DB: pick-time AND activation refusal, compare unchanged live DB/preferences | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F01.A2 | a real supported old database migrates, passes integrity, applicable FK checks and expected repository reads, and restores identifiable content/settings. | real old-schema SQLite through production lazy/background open: integrity/FK/schema/repository contents/settings | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F01.A3 | interruption at each activation boundary recovers to a coherent old or fully validated new state; restart never leaves mismatched preferences. | failure injection at each preferences/file/WAL swap boundary; restart yields coherent old or validated new pair | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F01.A4 | Confirmation states recoverable actions truthfully and follows accepted D2/D7: no new Undo control, one newest safety copy retained with deterministic interruption recovery; prune only after safe successful activation and never the pending/only recovery copy. Back up first runs existing backup and returns to the same candidate confirmation only after success; backup failure/Cancel never activates. Restore and restart immediately enters a non-editable activation path, with no edit gap, including on returning from Recents. An activation refusal/failure preserves a coherent recoverable state. | confirmation widget + literal D7 phone Recents path; no Undo control (D2 A); backup-first success→same confirmation; Cancel/failure→no activation; immediate no-edit activation/Recents; safe-retention interruption fixtures | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F01.A5 | The new running instance reports the actual durable applied/refused/recovered outcome once and clears consumed staging; Settings never shows a nonexistent pending restore. Pre-activation refusal says current data is unchanged; interrupted recovery reports the coherent selected old/new state rather than falsely claiming unchanged data after a new state committed. | applied/refused/interrupted outcome widget appears once; staged state cleared; applied/refused/recovered old/new outcomes exactly once; interrupted committed-new does not claim unchanged | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F02.A1 | resources no longer use the incompatible bitmap/adaptive-icon combination. | resource regression rejects bitmap/adaptive-icon combination | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F02.A2 | an API 26–30 launch shows the static mark, background and transition. | API 26–30 compiled-app native launch capture, static mark/background/transition | DEVICE/emulator native launch; PLANNED |
| CHK-F02.A3 | Android 12+ retains its approved animation/exit and animation-off behavior; first-frame and visible-content times are distinguished. API 24/25 coverage, if available, is recorded separately rather than inferred. | Android 12+ animation-off/on device observation; first-frame/content timings separately; final G2 repeats explicit | TEST + native DEVICE; physical timing/reduced-motion G2; PLANNED |
| CHK-F03.A1 | each contract choice has a concrete recommendation and accepted result, including D3–D5 below; missing legacy origins stay unrecorded. | numbered accepted ADR-021 sheet including D3-D5, required field dependencies/sources and legacy unrecorded | OWNER local ADR-021 contract + source/reference fixtures; PLANNED |
| CHK-F03.A2 | v25→v26 preserves rigs, aliases, blocks, original snapshots/forecasts, results, legacy events and preferences; schema equality and repository reads pass. | v25-v26 schema equality and repository/derived-state preservation fixtures for all named content | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F03.A3 | WB/focus-mode/source/measurement-mode associations survive save/reopen, additive manifest and backup round trips; old data defaults are explicit, not invented. | WB/source/mode save/reopen, manifest v2 additive and backup round-trip matrix | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F03.A4 | pinned schema tests are updated; newer-schema refusal remains data-safe. | pinned-version/refusal regressions; unsupported newer DB and bytes/version unchanged | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F03.A5 | the FITS sample gate is raised at task start: identify an available owner file or licensed fixture; record absence early without blocking independent tasks. | sample identity/licence/absence record at task start; missing FITS does not stall independent tasks | DOCUMENTED resource availability (no private values); PLANNED |
| CHK-F04.A1 | each field has tag-level provenance and correct absence/conflict/invalid handling. | tag-level source/absent/conflict/invalid fixtures per approved field | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F04.A2 | DNG neutral values remain vectors; JPEG/HEIC modes do not invent Kelvin. | DNG neutral-vector and JPEG/HEIC mode fixtures; no Kelvin invention | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F04.A3 | unsupported compression/layout/asymmetric binning is explicit; bounded reads remain bounded. | bounded compressed/layout/axis/asymmetry/invalid-value fixtures | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F04.A4 | synthetic and local real DNG/JPEG/HEIC samples exercise the extension; the common FITS contract exists without requiring its reader yet. | synthetic PLUS local real DNG/JPEG/HEIC result; common FITS types separate from reader | TEST EXECUTED with synthetic + local REAL FILE; PLANNED |
| CHK-F05.A1 | list, empty state and missing-rig actions expose both choices. | list/empty/Planner/Tonight/onboarding labelled dual-choice widget matrix | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F05.A2 | synthetic phone JPEG containing focal length, aperture, 35 mm-equivalent focal length and dimensions reaches a saved rig without typed sensor values. | synthetic phone JPEG FocalLength/FNumber/35mm/dimensions -> saved rig, no typed sensor inputs | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F05.A3 | Incomplete metadata names missing inputs and explains which calculations require each, without guessed defaults; Not sure selects explicit Unknown and explains that it does not infer sensor facts. Existing rigs retain class. New-install example class has cited seed evidence and changes no existing row. | incomplete metadata -> named missing inputs/no guessing; existing class preserved; missing-field→reason→dependent calculation; Not sure→Unknown; sourced new-install seed, existing rig class unchanged | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F05.A4 | class-specific block fields follow the accepted contract; U and the setup portion of W pass. | class-specific block field regressions + U captures/W1 path; proposed A+ seed-class case | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F05.A5 | Accepted D8: Save from a plan missing-rig action on Planner/Tonight or onboarding returns to its caller with that saved rig selected exactly once, missing-rig status cleared and Rig saved and chosen for this plan feedback; Cancel changes/selects nothing. Library creation only saves. Both manual and photo paths carry caller and saved identity; a Save failure preserves edits without selection. | D8 create-save-return/select/message widgets per entry; Library save-only; Cancel unchanged; manual/photo/from-existing invoking caller vs Library; saved identity selects once; save failure/Cancel no selection | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F05.A6 | a changed rig editor asks before discarding on Back or a tap outside, with the existing Discard prompt or the site editor's full-screen route pattern (as TD-084 required of the site editor); an unchanged editor closes at once (UXA-C4). | dirty/unchanged Back/tap-outside guard widgets; fullscreen route if required by U | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F06.A1 | unchanged valid custom light/flat filters survive edit and Use other values; null remains null; domain length validation stays. | custom/null filter unchanged edit AND Use other values; domain length/type-switch cases, reopen/snapshot; Task verification and original checks remain applicable | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F06.A2 | Origin markers survive switch/edit/reorder/delete-Undo/copy/save/reopen and snapshot/backup. User edits replace only the applicable origin; Cancel changes nothing. Inline reviewed proposals and compact visible source/Unknown/conflict labels lead to detailed provenance/WB/storage; no critical conflict is hidden. Immutable source descriptors survive source edit/deletion without changing copied values or historical snapshots. | source operations: switch/edit/reorder/delete-Undo/newer edit/copy/save/reopen/backup; Cancel unchanged; inline field review; compact source/Unknown/conflict remains visible; source edit/delete immutable descriptor and saved derived-state round trips; Task verification and original checks remain applicable | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F06.A3 | flat/bias do not inherit an unintended light exposure; default filter follows class. | flat/bias type switch exposure and class-filter-default widgets; Task verification and original checks remain applicable | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F06.A4 | WB and optional AF/MF focus mode appear in snapshot, entry, manifest and share text and survive copy, save/reopen and backup; old missing values remain unrecorded. Neither changes exposure, budget, storage, relative gain or calibration matching; there is no numeric focus input or camera control. | WB/focus snapshot/entry/manifest/share/copy/reopen/backup/legacy round trips; budget/exposure/storage/gain/calibration unchanged; Task verification and original checks remain applicable | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F06.A5 | Basic Phone/DSLR entry exposes frame type, exposure, count, ISO, WB and optional AF/MF recording, plus applicable filter and a concise estimate. Exposure accepts positive decimal seconds and familiar fractions (for example 1/14 s); invalid/zero-denominator fractions fail by the field, canonical seconds and existing bounds stay unchanged. ISO/WB/focus may remain unrecorded and never block an otherwise valid save. The explicit rig class selects ISO for Phone/DSLR and gain for astro cameras, without a per-block ISO/GAIN choice; Unknown offers a clear camera-class remedy or honest unrecorded state, never a guessed ISO/gain kind. Binning is applicable astro-camera Details, not mandatory basic Phone/DSLR input; source/storage and expert WB details stay reachable. Preserve hidden historical values, actual validation/Unknown/conflict reasons and all calculations. Charts are not a prerequisite; U covers 412x915, 200% text, keyboard and density. WB guarantees no identical colors. | Phone/DSLR ISO/WB/AF-MF visible and optional; explicit class selects sensitivity; astro-only advanced binning; fractional/decimal exposure including invalid/zero-denominator vectors; 412x915 at 200% with keyboard, U/density record and no identical-colour promise; AM-04 supersedes the affected AM-01 Details hierarchy; all essential estimates readable before charts; keyboard/200% reachable Save | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F06.A6 | Changed block editor Back/tap outside uses the existing discard guard, dismissal = Cancel; pending file proposals count as dirty. Explicit local Cancel never applies; unchanged closes immediately. At 412×915/200%/keyboard use the full-screen route pattern if needed, with reachable persistent Apply changes and preserved typed values on errors. | dirty/pending-proposal/unchanged Back and explicit Cancel; Apply changes above IME and correct guard labels; no parent Save | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F06.A7 | Use Add block for creation and Apply changes for editing a block; reserve Save plan for recording the parent plan. Block apply still changes the working plan/autosave with existing Undo, not an implicit parent Save or a second persistence mechanism. Context and concise feedback explain the scope without extra confirmation. Cancel/guard dismissal applies nothing; primary labels and semantics remain reachable at200%/IME; update affected interaction keys/copy tests. | Add block/Apply changes/Save plan scope; apply→Undo→Back/reopen→explicit parent Save; Cancel no change; semantics200%/IME | TEST interaction + RENDER/U/W; PLANNED |
| CHK-F07.A1 | compatible measured file wins; mode changes invalidate or explicitly reconfirm it; an already-binned file is never scaled again. | measured priority and changed-mode invalidation/reconfirm; already-binned measurement unchanged | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F07.A2 | theoretical output requires evidenced uncompressed DNG, supported FITS layout, or explicitly confirmed declared format; distinguish pixel payload and container bytes. Unknown compression/layout remains Unknown. | DNG uncompressed evidence/FITS supported layout/declared format vectors; payload vs container distinction | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F07.A3 | camera class never selects a size assumption; Unknown offers file/manual-size action. | no class-derived size; Unknown reason and file/manual action widgets | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F07.A4 | unread-format behavior follows accepted D3 A, with mode-unread/content-variation wording; CR3 length vector uses decimal MB. | D3 unread synthetic CR3 length/decimal MB and honest mode/content wording | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F07.A5 | S1–S4, compressed boundary and binning vectors pass; MB/GB use `QuantityText`, 10^6/10^9 bytes, visible source and assumption. | independent S1-S4/compressed/binning/integer-floating FITS/padding vectors + QuantityText/source labels | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F08.A1 | Inline review shows only approved class-applicable fields, values/sources and visible conflicts before Save; no exposure/ISO change reaches the rig. Proposed values remain local; explicit acceptance/edits preserve per-field origin under F03/F06. | class-applicable proposal/source preview; rig exposure/ISO unchanged; inline applicable field/source/conflict review; no stored or rig mutation before Save | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F08.A2 | Cancel/read failure leaves stored block/rig unchanged; repeat picks, edited proposals and differing dimensions have deterministic visible outcomes; an unsaved proposal counts as a change for F06's discard guard (UXA-C4). | Cancel/read error/repeat/edited proposal/dimension conflict deterministic; dirty proposal guard | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F08.A3 | TD-072's size conflict is independent of pick order; custom filters and persisted sources survive. | size conflict both pick orders, custom filter/source persist | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F08.A4 | DNG/JPEG/HEIC Save/reopen works on device; U and W's DSLR proposal/edit/cancel path pass. | real DNG/JPEG/HEIC phone Save/reopen + DSLR W2; FITS separately F10 | TEST + DEVICE real DNG/JPEG/HEIC + U/W; PLANNED |
| CHK-F09.A1 | lights Ha/bin1 + OIII/bin2 with flat Ha/bin2 do not satisfy either full tuple incorrectly; both warnings and missing coverage use that rule. Ha=HA; H-alpha≠Ha. | Ha/bin1 + OIII/bin2 + flat Ha/bin2; warnings and coverage agree; HA=Ha, H-alpha distinct | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F09.A2 | Unknown sensitivity does not prove known-value coverage; unresolved preview requirements remain visible and proven duplicates omitted. A labelled Build calibration frames entry and relevant missing-flat warning shortcut open CAL-1 preview. Counts remain editable proposals; generated flat exposure is entered for the flat, never inherited blindly from a light. Calibration review uses the same class-appropriate basic fields as F06; matching still uses the established modeled tuple, never WB or focus mode. No optional include-switch redesign is introduced. | unknown/known sensitivity not proven coverage; duplicate omission/unresolved preview; labelled CAL-1 and missing-flat shortcut; counts editable; positive flat-specific exposure, never inherited light exposure; no unknown proof | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F09.A3 | LENR suppresses dark proposals; counts stay proposals; library/timing policies and budget remain correct, calibration never counts as integration. | LENR/no darks; class/count/library/timing; unchanged integration/budget | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F09.A4 | preview Cancel changes nothing; confirm persists; Undo after a newer edit preserves that edit. | preview Cancel/confirm persistence and Undo after a newer edit preserves it | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F09.A5 | custom/imported FILTER and hidden-class binning tests pass; example-action replacement E2E and U pass. | custom/imported filter/class-hidden binning + replacement E2E/U | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F09.A6 | with no blocks, the Capture Plan names the next step with labelled actions — for example “Add light frames”, plus “Take from a photo” where F08 (for astro cameras, F10) supports the rig's class — and says calibration can be built from the lights afterwards; the empty state's actions are not icon-only; the E2E that replaces `capturePlan.useExample` starts from this state (UXA-C5). | no blocks -> labelled Add light/Take from photo supported-class actions and calibration explanation; E2E starts here | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F10.A1 | record boundaries, missing END, read/axis/overflow limits, floating BITPIX, conflicting exposure, arbitrary FILTER and absent/asymmetric binning have tested outcomes. | record/END/read/axis/overflow/floating/conflicting tags/custom filter/asymmetry synthetic cases | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F10.A2 | binned/unbinned writer vectors normalize geometry exactly once; unsupported meanings/layouts stay explicit. | binned/unbinned writer fixtures normalize geometry once; unsupported stays explicit | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F10.A3 | real FITS runs through reader, reviewed saved rig, applicable block proposals and storage; Cancel stores nothing. | owner or licensed real FITS through reader->review rig->block->storage; Cancel stores nothing; phone evidence | TEST + REAL FILE + DEVICE; licensed provenance; PLANNED |
| CHK-F10.A4 | photo-choice labels now advertise FITS; recognized-only RAW remains honestly described. Only already approved block fields become controls. | readable-format label changes; recognized-only RAW honest; approved controls only | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F11.A1 | ratios 0.5/1/2 yield 0.7071/1/1.4142 within the recorded vector tolerance. | independent ratio 0.5/1/2 -> 0.7071/1/1.4142 vectors with explicit tolerance; Task verification and original checks remain applicable | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F11.A2 | zero integration, mixed and unknown settings yield truthful group/empty/text states; unknown never proves equivalence. | zero/mixed/unknown groups empty/group/text states; unknown not proof of equivalence; Task verification and original checks remain applicable | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F11.A3 | Primary Capture Plan output shows a concise estimated relative stacking gain against one comparable light frame, with its reference explicit and a short assumptions link. It never claims absolute physical SNR. Integration-time curve/reference and text remain available in Details, not repeated large graphs before Save. Known incompatible groups remain separate; unknown comparability is explained rather than combined. U and W visible-explanation checks pass. | axes/planned point/relative-label/text/semantics; no absolute SNR; U/W visible explanation; AM-01 concise gain/reference and honest relative label; detailed curves reachable without blocking Save; mixed/unknown groups not merged | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F12.A1 | displayed assumptions are the effective calculation values. | effective-assumption labels equal actual calculation inputs, not stale Settings defaults; Task verification and original checks remain applicable | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F12.A2 | evaluable blocks get FitAnalyzer-derived guidance; unavailable results name the missing inputs without hiding still-valid results. | all evaluable blocks FitAnalyzer guidance; missing input named, valid results remain; Task verification and original checks remain applicable | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F12.A3 | focus guidance remains a reminder; the optional AF/MF record of F06 has no numeric control/value, alters no calculation and operates no camera. | focus reminder plus optional AF/MF record has no numeric input, hardware effect or calculation change; Task verification and original checks remain applicable | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F12.A4 | Change in Settings opens planning Settings over the current plan with an explicit global-scope notice; Back returns to the same plan/section and preserves edits/results. Main settings retain darkness/minimum-altitude, frame interval and feasibility margin. Advanced groups contain optional Moon/cloud gates and dither/refocus/filter/flip/setup time; NPF is guidance for untracked exposure and dew margin is weather guidance. Display/privacy/backup/About remain distinct. Every retained setting has a visible consequence; U and fit/error/Unknown/W checks pass. | Settings link/return/fit/error/Unknown widgets and U/W visible explanation; open Settings over dirty/saved plan, global notice, Back same plan/section; effective values unchanged by navigation; AM-01 basic/advanced/guidance/privacy/data groups; every setting retains effect and values; same-plan return/global notice | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F13.A1 | the topocentric sampling predicate is derived as equivalent to geocentric h₀, rather than copying the numeric threshold into the wrong frame. | independent coordinate-frame derivation accepted in ADR-022; topocentric predicate equivalent to geocentric h0 | DERIVATION + independent TEST reference vectors; OWNER local ADR-022; PLANNED |
| CHK-F13.A2 | rise/set, dark counts, gate and annotations agree at the boundary; high-latitude/polar cases and batch=single pass. | rise/set/gate/count/annotations boundary+polar+batch=single tests | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F13.A3 | dark∩Moon-below intervals distinguish evening/morning/all-night/none/mixed-disjoint/no-dark; phase name follows phase longitude, never substitutes for interval calculation. | dark intersection classifications none/evening/morning/all/mixed/disjoint/no-dark and phase longitude vectors | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F13.A4 | SI-015 and relevant vectors are reconciled; no universal good-night threshold. | SI-015/CALC reconciliation and independent reference vectors, no universal score | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F13.A5 | ADR-022 records accepted D9 A with exact controls/renders: Home/Planner context edits the active plan; calendar/day/forecast View this night only browse with viewed-versus-plan labels. Plan this night alone adopts a never-saved draft or guarded saved-plan copy. Save failure/Cancel stops replacement; Discard restores saved state before copy. Explicit pre-copy Save has its ordinary write effect; adoption/copy does not retime or rewrite the source as saved after that Save. Back without adoption changes no plan/result; feedback names draft change versus copy. The scientific/reference-vector local acceptance remains explicit. | accepted D9 rendered flow: every control browse/edit, unsaved/saved/dirty/adopt/confirmation table; every control assigned edit/browse/adopt; draft/saved/dirty Save/Discard/Cancel/failure; compare source after explicit pre-copy Save | TEST + RENDER control matrix; OWNER ADR-022; PLANNED |
| CHK-F14.A1 | an up-to-16-day response is not presented as 16 complete nights; first/last partial, DST, absent-variable, no-dark, stale/offline and out-of-range states are explicit, never zero/clear defaults. | UTC horizon first/last partial, DST/missing variable/no-dark/stale/offline/out-of-range fixtures; no zero defaults; Task verification and original checks remain applicable | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F14.A2 | same-ID coordinate changes and late responses cannot attach data to the wrong site. | same-id coordinate edit and out-of-order response/cache-identity tests; Task verification and original checks remain applicable | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F14.A3 | Night weather leads with selected-night facts and a readable hourly visualization on the night/darkness time axis: cloud cover, temperature with dew point, compact wind/gust and precipitation rows, and selection of an hour for exact values. Low/mid/high cloud layers and humidity remain reachable in detail. Gaps/no forecast have explicit discontinuities, never fabricated clear weather or smoothed certainty; legend, units and text alternative are provided. Full table/model/source/age stays in Details; no decorative UV/AQI/feels-like dashboard or new provider. | card hierarchy/hourly layer/gust/humidity/dew widgets and dark-span vectors; AM-01 hourly cloud/temp/dew/wind/precip visual and selected-hour exact values; unknown gaps/text/field/200% tests | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F14.A4 | snapshot-relative “forecast N days ahead” is separate from retrieval age; no reliability score. | snapshot lead-time vs retrieval-age text assertions; Task verification and original checks remain applicable | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F14.A5 | seeing/transparency limitation and user-opened Clear Outside link are explicit; request budget recorded; U passes. | seeing limitation/manual link/privacy/request budget and U; G1 actual service; Task verification and original checks remain applicable | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F14.A6 | opening a night's card changes no plan; adopting that night follows D9 (UXA-C3). | overview opens without plan mutation; explicit D9 adopt test; Task verification and original checks remain applicable | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F15.A1 | Offline month computation runs in an isolate with relevant site/zone/night-definition/model cache identity; calendar/detail values agree and invalidate with context. Weekday/date/selection and large-text week view remain. The primary selected-night view has a labelled shared daylight/twilight/darkness and Moon-up timeline, legend and text alternative; preserve disjoint/no-dark/Unknown and field hatching distinctions. | calendar/detail numeric agreement and relevant cache-input invalidation; offline month isolate/cache; readable month/week; bar/legend/text/disjoint/no-dark and field hatching; calendar/detail parity; AM-01 shared night and Moon timeline plus unchanged calendar/detail equivalence | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F15.A2 | Browsing/back leaves current and saved plans/results intact and labels viewed versus plan night. Accepted D9 adoption follows F13 A5, including guarded Save/Discard/Cancel and source comparison after any explicit pre-copy Save; no silent retiming or second plan store. | browse/back/dirty/saved/adopt lifecycle with browse label and Save/Discard/Cancel; read-only browse/back and explicit adoption; pre-copy Save normal effect, Cancel preserves contents and derived UI; Task verification and original checks remain applicable | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F15.A3 | site change and restart preserve original snapshot/results. | site change/restart content+derived-state original snapshot/result comparison; Task verification and original checks remain applicable | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F15.A4 | U passes; phone timing is measured against the applicable existing runbook criterion, with no invented performance PASS. | U real-font/native capture and phone calendar timing per existing threshold, not HOST timing; Task verification and original checks remain applicable | RENDER/U + measured PHONE timing (G2 permitted carry); PLANNED |
| CHK-F15.A5 | A time slider browses an instant inside the viewed SessionNight without editing the plan, its start or saved results. Show the site-local time/date/zone and the corresponding dark/Moon state and end of the relevant interval; clearly distinguish time until darkness from time remaining in it. Reset to Now only when now lies in the viewed night; otherwise offer the night start. Date/site changes reset or revalidate the cursor. Keyboard/semantics/large text, DST labels and no-dark/polar cases pass; text offers the same facts. No simulator/playback or new astronomy engine. | AM-01 cursor-only time scrub; site-zone/date/reset/Now bounds, midnight/DST/no-dark/disjoint, semantics/field/200%; saved and draft contents/results unchanged | TEST + RENDER/U; named PHONE/OWNER rows retained; PLANNED |
| CHK-F16.A1 | loaded first-run flag determines the first frame; no Tonight flash. | first rendered route determined by loaded firstRun flag; no post-frame Tonight flash | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F16.A2 | One Welcome to Culmina screen has concise purpose/permission rationale, optional site and class→rig setup, no target step and no Skip. Both setup steps may be omitted through Start planning; GPS is requested only on explicit tap; denial retains choose/manual paths and planning stays reachable. | both optional setup steps omitted/permission denied still enter planning; GPS only on tap; one-screen/title/concise rationale/no target/no Skip; optional omissions, explicit GPS denied/manual/Back states | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F16.A3 | class-specific labeled manual/photo paths and cancellation work; a rig saved there becomes the plan's rig per D8 and the setup screen shows it (UXA-C2); missing required inputs are explained without fake defaults. | manual/photo/class/cancel/D8 chosen rig and visible setup status; no fake inputs | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F16.A4 | first-run/returning-run core-loop, U and W setup checks pass. | first-run/returning E2E+U/W1; proposed A+ one-screen/no target/no Skip/title/rationale | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F17.A1 | Title and field-mode toggle share a compact wrapping header; tappable site/night/zone context precedes the night card. Card shows dark interval, phase/moon-free hours, dark-span cloud coverage/freshness and detail links with honest missing/partial/stale/no-dark states. Candidate selection remains a secondary action. | empty/partial night card values, detail links, coverage/freshness states; title/toggle/context/order/candidates; missing/partial/stale/no-dark state renders 100/200 all themes | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F17.A2 | Your plan/Open planner resumes the current plan with one context/store. Home has no New plan action; Planner keeps its distinct guarded New plan menu lifecycle. | Open planner opens same active/saved plan, one store; same-plan Open; Home New plan absent, guarded Planner New plan remains distinct | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F17.A3 | Accepted D9 A keeps Home/Planner subtitle editing the active plan; the night card and Your plan describe the same site/night. Picker Cancel preserves edits/results; separate calendar/forecast viewing is labelled and adopts only through F13 A5. | D9 night/plan context consistency + dirty Cancel content/results unchanged; active plan context on Home; picker Cancel; browse separate; saved/dirty copy original after Save | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F17.A4 | empty/loading/offline/error/saved states, U and relevant W path pass. | empty/loading/offline/error/saved U/W; proposed A+ title/context/candidates/no New plan | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F17.A5 | Home uses the shared plan-night phrase: “tonight” only when the active plan's SessionNight is the current SessionNight, otherwise that night's date (for example “on Fri, Dec 18”). This covers the night card's lines, the candidate action and the candidates screen's title, whose list is for the plan's night. By owner choice AM03-T = B (§5) the bottom-navigation tab label stays “Tonight”, and the page title reads “Tonight” for the current night and the plan's night otherwise (for example “Night of Fri, Dec 18”). Calculations and accepted D9 A context editing are unchanged. | plan night = current night keeps the existing Home wording; plan night ≠ current night: no “tonight” in the night card, candidate action or candidates title, the date phrase present and the candidate list for the plan's night; tab label “Tonight” in both cases; page title “Tonight” for the current night and the plan's night otherwise | TEST with independent fixture/interaction expectation + RENDER/U; PLANNED |
| CHK-F18.A1 | The primary simple workflow is intended frames → estimated integration/total duration/storage/relative stacking gain → Save, with compact site/night/target/rig context and working missing-input checklist. Remove Tonight for this target and its chart/window-list/placeholder from Plan for this release; retain ImagingOpportunity/FitAnalyzer, compact availability/fit reason and night/weather detail access. Target appears once; selected-plan-night facts lead. Altitude now belongs in explicitly labelled secondary detail when the selected night differs from now, never presented as an altitude at the planned time. Advanced details remain reachable; only identical global warnings merge. | simple outputs; Plan block/placeholder absent; future selected night vs current altitude; secondary current-sky detail and original domain results preserved | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F18.A2 | save success clears banner; error keeps recoverable draft and correct status. | successful Save clears autosave banner; failure retains recoverable draft/status; Task verification and original checks remain applicable | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F18.A3 | Cancel/back/browse/adopt follows accepted D9/F13 A5 and agrees with Home/calendar. Adoption/copy preserves the original snapshot/result as saved after any explicit pre-copy Save; Save failure/Cancel stops replacement and derived UI remains consistent. | Home/calendar/Planner browse/back/dirty Save/Discard/Cancel snapshot/results unchanged; draft/saved/dirty browse/adopt/cancel/restart/site change; original after pre-copy Save plus derived-state comparisons; Task verification and original checks remain applicable | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F18.A4 | fit and relative gain explanations are visible in W; U and before/after reference-plan scroll record pass. | W visible fit/gain, U and reference-plan scroll/section deltas; AM-01 target/Plan-chart removal/weather; Task verification and original checks remain applicable | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F18.A5 | After Planner loads, keep a stable visible Save plan affordance. When existing site/target/rig or other actual save prerequisites are missing, show a readable reason with the direct corrective action; disabled state has adjacent accessible text, not tooltip-only explanation. Eligibility remains the existing domain/lifecycle rule, with no partial-rig model or new restriction on empty plans. Missing weather/network alone is not a new prerequisite. Once eligible, saving/error/retry preserves the draft and correct state; the button never disappears merely because an input is missing. | loaded Planner missing site/target/rig separately and combined; stable visible Save plus action/reason; valid state, offline weather, failed save/retry,200%/keyboard | TEST interaction + RENDER/U/W; PLANNED |
| CHK-F18.A6 | Planner text that describes the plan's night uses one shared plan-night phrase: “tonight” only when the plan's SessionNight is the current SessionNight, otherwise that night's date. This covers status and fit actions (fill or trim to the window, not even one frame fits), per-block what-fits rows, no-window and missing-input reasons including FitAnalyzer and opportunity reason strings, target-card window labels and conditions text. With a plan night other than the current night no Planner text says “tonight”; with the current night the existing wording stays. Windows, fit results and every displayed value are unchanged. | fixed clock with plan night ≠ current night: no built Planner text contains “tonight” across status, block rows, target card, reasons and conditions, and the date phrase is present; a current-night fixture keeps the existing wording; fit, window and budget values identical in both | TEST with independent fixture/interaction expectation; applicable U/W; PLANNED |
| CHK-F19.A1 | Each Logbook card distinguishes Result not recorded from Completed/Partly/Not done, with text plus an appropriate icon/tone; never color alone and never elapsed time as completion. Provide direct Record result/Edit result and planned versus recorded integration. Entries/Progress and Plan this target retain RD-07 roles; guarded copies preserve original snapshot/result. | copy/other-night reuse: original snapshot/result bytes and derived UI unchanged; Entries/Progress segment and row Plan this target; Library manages, Logbook records; copy/source after Save; AM-01 distinct no-result/completed/partial/not-done cards, direct action, icons+text and current-before-dawn card placement | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F19.A2 | Completed/partial/not-done reports save, reopen and update progress consistently. A user may explicitly finish and record the current saved night before dawn; never auto-complete. Current means now is within the stored SessionNight window; future means now precedes that stored start. Future saved nights cannot be marked acquired in advance. This amends only the old report-after-night-end eligibility, not SessionNight/astronomical darkness or automatic saved-plan rollover. Results remain manual reports, not measured acquisition. | all result statuses save/reopen and progress totals agree; AM-01 current saved-night manual early result, future refusal, no time-based auto-completion; progress/snapshot preservation | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F19.A3 | entry forecast is the stored snapshot with its original age/source, not current weather substituted silently. | entry forecast equals original snapshot/source/age, not live substitution; Task verification and original checks remain applicable | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F19.A4 | Visible stored rig/target Delete uses confirmDestructive under RD-09; Cancel/Back/dismissal preserves record/selection/snapshot, confirmed deletion persists and yields a valid derived selection/fallback. No stored-record Undo is added. In-plan Undo remains F06/F09. U and W returning multi-night journey pass. | stored record confirmation/Cancel/delete persists with correct derived selection; U and returning W; stored Delete confirmation/dismiss/Cancel/confirm/reopen selection; no stored Undo; in-plan stale Undo covered F06/F09; Task verification and original checks remain applicable | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F19.A5 | The same early-report eligibility is enforced by domain/repository and UI, using the saved night, not the live selected site/night. A saved-changed plan first resolves explicit Save/Discard/Cancel and reviews the exact saved snapshot; Save failure/Cancel changes no result. Unreadable/legacy records retain honest limitations, no fabricated counts. Stale-form/concurrent-update guards, transaction/event counters, original forecast, corrections and progress remain consistent; future-night refusal, current-before-dawn success, ended-night success, process restart and derived UI checks pass. Show an explanatory unavailable state instead of an unexplained missing action. | AM-01 UI+repository parity, saved-context vs live-context, dirty Save/Discard/Cancel/failure, unreadable/legacy/stale form, event counters and derived UI after restart | TEST production repository/persistence/reconciliation + UI/derived state; H/full gate; PLANNED |
| CHK-F20.A1 | fixtures cover completed/partial/not-done/no-result/legacy/mixed-group/multiple-night records; unsupported acquisition data is explicitly unavailable, not fabricated from a plan. | independent completed/partial/not-done/no-result/legacy/mixed/multinight acquisition CSV fixtures | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F20.A2 | unknown stays blank, never invented zero/date; escaping and units match the cited contract. | blank unknown/date/count semantics and escaping/units vs refreshed primary contract | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F20.A3 | Names never occupy numeric-ID fields; separate filter rows and share-text name order are deterministic. Before sharing, show the same ordered CSV row/filter-name list; no equipment-ID lookup/account/mapping store is added. | numeric filter column empty; deterministic separated rows/name-share ordering; numeric ID blank; per-filter separate rows; preview and share ordered row/name association plus escaping | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F20.A4 | Calibration counts require supported recorded acquisition evidence AND proven F09 whole-tuple association. A planned or compatible library block never establishes acquired count; ordinary unrecorded manual-result calibration stays blank. Supported historical evidence may supply recorded counts. Mismatched/Unknown coverage stays blank; existing manifest export remains compatible (TF-01). | TF-01: supported recorded acquisition count AND proven F09 tuple, otherwise blank; completed-light/planned-only/library-only/unknown-tuple negative cases; existing manifest export unchanged; TF-01 completed/partial lights plus compatible planned/library calibration→blank; supported recorded calibration plus proven tuple→recorded; unknown/mismatch→blank | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F21.A1 | every preference value round-trips; old backups get documented defaults, unknown future values safe fallback. | every preference/default/unknown-future enum restart+backup round trip | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F21.A2 | °C/°F, km/h/mph/m/s, m/ft flow through affected UI/share paths; scientific storage and calculations remain canonical. | canonical storage unchanged, temperature/wind/elevation all display/share paths matrix | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F21.A3 | absolute temperature conversion and temperature-difference/dew-margin conversion are separately tested. | separate absolute C/F and temperature-difference/dew-margin conversion vectors | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F21.A4 | Accepted D1 A keeps neutral tokens and System default, including new installs; field mode remains accepted behavior. Light/dark AA vectors and documented existing field-mode exception, U, restart and backup checks pass. No navy/ice-blue redesign or new-install Dark default is inferred. | accepted D1 AA changed pairs, field mode and U/restart/backup; neutral/System initial/default/restart/backup; light/dark contrast and existing field exception; no unapproved brand/default | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F21.A5 | Planning preferences and F21 display/unit updates distinguish in-memory edits from durably confirmed settings. Keep latest edits visibly pending/unsaved when persistence fails; provide actionable failure and Retry of the newest complete configuration. Do not falsely report saved or silently discard edits. Serialize/coalesce completion so older requests cannot mark newer values saved or overwrite them; do not require an architecture/debounce redesign. Reload/restart/backup must expose a coherent confirmed configuration or an explicit recoverable failure, never silently mix partially saved fields. Preserve legacy defaults, snapshot history and existing privacy opt-in semantics. Inject failure at relevant write boundaries, reverse delayed completions and verify retry/latest-value/unrelated-field preservation plus derived UI. Exact compatible write strategy is an implementation detail. | injected write failures and reopen/backup; persistent unsaved cue and Retry newest configuration; delayed A/B completions reversed; no stale saved acknowledgement/torn config; canonical values/history unchanged | TEST production preferences/failure/concurrency/restart/backup + derived UI; H/full gate; PLANNED |
| CHK-F21.A6 | The place-name lookup switch follows the same honest-persistence rule: after a failed write the screen never shows a choice different from the stored one unless it is visibly unsaved with Retry, or it restores the stored choice and says so. While Off is shown, no position is sent. Reload and restart show the stored choice. The default (off), consent wording, provider, attribution and call limits are unchanged. | injected place-name write failure for Off and for On; shown choice equals the stored one or is visibly unsaved with Retry; no lookup request while Off is shown; reload/restart shows the stored choice; default and consent copy unchanged | TEST production privacy preference/failure/restart + derived UI; H with F21; PLANNED |
| CHK-F22.A1 | Background process death on Planner and a representative existing form returns to the intended valid route. If its referenced plan was deleted, use a valid fallback and report The plan you had open was deleted. Showing Tonight. Preserve all existing lifecycle/data rules; no second draft store. | emulator/phone background process death Planner/form -> intended route or explicit deleted-item fallback; process death representative form/planner; deleted-plan valid Tonight fallback plus explicit message; no stale-context adoption | TEST + emulator process death; physical repeat G2; PLANNED |
| CHK-F22.A2 | restored arguments never adopt another site/night or overwrite a saved result; cancel remains safe. | restored args never adopt another night/site or overwrite result; Cancel safe | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F22.A3 | named plan and every existing result field, including not-done reason and supported reported events, survive relevant kill and v24→v25→v26 paths. Any unsupported unsaved-form restoration is documented against the existing contract before claiming completion. | named plan and all result statuses/reasons/legacy events kill+v24-v25-v26 comparisons | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F23.A1 | municipality-only response names the place; absent/invalid values still fall back to coordinates; existing precedence stays tested. | municipality-only/absent/invalid/precedence mapper fixtures -> name or coordinates; Task verification and original checks remain applicable | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F23.A2 | Dart/native notices and accepted permission are visible and match the build dependencies. | Dart/native dependency-notice comparison and About accepted permission visible; Task verification and original checks remain applicable | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F23.A3 | each TD-031 subitem is resolved with evidence, retained as an explicit non-blocking limitation, or reported as a concrete release blocker; no generic “all legal risks fixed.” | each TD-031 registered subitem resolved/limited/blocker with concrete evidence; Task verification and original checks remain applicable | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F23.A4 | provider changes are not invented to close the register; U passes for changed pages. | no provider replacement; changed pages U/opt-in/call limits preserved; Task verification and original checks remain applicable | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F23.A5 | Use current position in the new-site/editor flow obtains GPS coordinates and automatically proposes a place name through the existing consented lookup. If lookup is disabled, offer its existing opt-in explanation/action without sending coordinates until accepted; coordinates-only/manual entry still works. Lookup never overwrites a manual/existing name or a later name/position edit; ignore stale responses. Loading/offline/not-found/failure never blocks coordinate entry/Save; use an honest coordinate fallback. No site is saved or active saved site looked up until its approved explicit operation. Preserve attribution and update actual privacy/help copy when implemented. | AM-01 GPS→consent→name proposal with manual edit/position race; disabled consent sends no request; offline/failure coordinates Save succeeds; saved site untouched before Save | TEST + RENDER/U; named PHONE/OWNER rows retained; PLANNED |
| CHK-F23.A6 | In the site editor a position fix from Use current position fills the coordinates only if both coordinate fields are unchanged since the tap. A typed edit or a map pick made while the fix is pending is kept, and the fix is not applied without the user's explicit choice. A reply after leaving the editor writes nothing. Locating never blocks typing, picking on the map or Save. | controlled GPS completer: untouched fields filled; typed edit and map pick during locating kept and the fix not applied without a choice; reply after leaving writes nothing; typing, map pick and Save available while locating | TEST interaction; PLANNED |
| CHK-F23.A7 | A remembered transient position without a known place name is never labelled “Current position”. Wherever it is shown (Home and Planner context, the Welcome site status, the Sites list) it reads as an unsaved position, with its coordinates where space allows, before and after restart. A saved site keeps its name and a looked-up name keeps its attribution. No automatic GPS request and no change to how a position is chosen or stored. | transient position from GPS, map pick and typed coordinates with lookup off, before and after restart: no “Current position” label on Home, Planner, Welcome or Sites; unsaved-position label with coordinates where space allows; saved-site name and looked-up attribution unchanged | TEST + RENDER/U; PLANNED |
| CHK-F24.A1 | Harness/repository tests that depend on night/date use fixed injected clocks | fixed injected clocks at formerly failing morning/evening cases | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F24.A2 | Existing all-tiles-fail probe becomes a committed test, with host path_provider fake | permanent all-tiles-fail test with path_provider fake; controls/coordinates usable | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F24.A3 | Orphan cleanup uses AppLog | AppLog cleanup source assertion + failure/log regression | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F24.A4 | Enable the already planned unawaited_futures rule and resolve actual findings | unawaited_futures analysis and affected async failure tests; no unrelated campaign | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F24.A5 | Recheck only the registered startup/network barrier, site/zone behavior and named historical test gaps | current TD-002/020/025 evidence; obsolete close or focused reproduced invariant fix only | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F24.A6 | Target search accepts success/error/loading/empty results only for the newest requested query and current mounted generation. A late old response/failure cannot replace a newer list or selection; pending results cannot masquerade as belonging to new text. Respect choose/manage modes and disposal; debounce is optional. Record current reproduction first; if already safe, prove it without unnecessary refactoring | deterministic delayed A/B success and error in reverse order, clear query, disposal/navigation and selection; old result ignored and newest query alone authoritative | TEST deterministic async selector regression; CODE scenario must not be called executed reproduction; PLANNED |
| CHK-F25.A1 | every changed surface has U evidence including real glyphs and relevant error/keyboard states. | all changed screens/editors/filter/map U rows, keyboard/errors with real glyphs/native evidence | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F25.A2 | no hand-formatted covered quantity bypasses QuantityText; field mode and approved contrast remain correct. | bounded QuantityText source-enforcement test + approved AA/field mode | TEST with independent fixture/interaction expectation; applicable U/W and named G2 carries; PLANNED |
| CHK-F25.A3 | all four W journeys have step records, with fit/Unknown/relative-gain explanations and issues classified; comprehension remains separately labeled. | four W action/issue/visible explanation records; comprehension separately HUMAN/UNVERIFIED | W step records/functional TEST; HUMAN comprehension separately UNVERIFIED where accepted; PLANNED |
| CHK-F25.A4 | owner final visual acceptance is recorded; no unresolved functional/accessibility blocker remains. Later relevant changes invalidate only affected rows. | owner final visual decision; no unresolved functional/accessibility blocker; V3 invalidation by affected row | OWNER final visual acceptance + blocker disposition; PLANNED |
| CHK-F26.A1 | absent/debug/wrong certificate is refused; selected APKs use `io.github.buffur.culmina`, expected signer, matching pubspec/AppIdentity version, increasing versionCode, required SDK settings and 16 KB native-library alignment. | absent/debug/wrong signer rejected; id/version/versionCode/SDK/native 16 KB checks | TEST rejection cases + actual APK signer/metadata/alignment; PLANNED |
| CHK-F26.A2 | D6 uses actual measured sizes; every selected APK is checked and hashed. | measure universal/arm64 download+installed bytes then explicit D6; every selected APK hash/check | MEASURED APK download/installed sizes + OWNER D6 + artifact checks/hash; PLANNED |
| CHK-F26.A3 | final code/tooling/version inputs pass the full gate and actual remote CI on the release commit; native build/Kotlin results are valid for those inputs. | final-input full gate/native Kotlin/actual remote CI on release commit; no key needed in public CI | final-input full gate/native/Kotlin + actual remote CI; PLANNED |
| CHK-F26.A4 | commit/toolchain/id/version/certificate/APK SHA-256 and live policy URL are recorded. | manifest commit/toolchain/id/version/public cert/SHA256/live-policy URL | artifact provenance/live URL record; PLANNED |
| CHK-F26.A5 | signature-mismatch instructions require a verified independent backup before any owner-authorized uninstall; no destructive action is automated as a packaging shortcut. | signature mismatch backup instructions; no automated uninstall or secret access | DOCUMENT instructions + isolated recovery rehearsal; no owner uninstall implied; PLANNED |

## 8. Capture and night semantic contracts

The following CP/NC clauses bound the existing F tasks, with owner-selected D semantics (§5). Exact encoding/reference derivation/rounding details explicitly left to ADR-021/022 remain local acceptance checkpoints, not facts fabricated by this proposal. Illustrative P3 values are excluded from scientific validation. Preserve existing domain limits; no new universal threshold/default or proprietary decoding is authorized.

### CP contract — F03/F04/F06/F07/F08/F09/F10/F11

| Field / association | Bounded semantic contract / local checkpoint | Round-trip / negative check |
| --- | --- | --- |
| Block parameters | Retain CaptureBlock bounds/type/class rules: finite positive exposure, existing count/binning/filter limits, sensitivity kind distinct. No new physical controls/nullable rig model | Existing constructor/form limits, type-switch, class-inapplicable preserved historical values and Cancel |
| Per-field origin (D5) | Nullable field-keyed record: kind entered / copied from block / inherited / file / explicitly declared; immutable display descriptor and applicable source/evidence reference. Missing legacy record means origin unrecorded, never entered/file by default | Switch/edit/reorder/delete-Undo/copy/save/reopen/snapshot/backup; user edit replaces only that field's origin. Source block edit/deletion must not retroactively change copied values or invalidate history |
| Origin references | Block/file labels describe the proposal at the time it was accepted, not a live calculation dependency. Remap copied block references where applicable; retain a descriptive origin if the source no longer exists. No dangling FK may make a historical snapshot unreadable | Delete/rename/source-edit/copy then reopen shows the same copied value and honest descriptor. Do not implement a reactive inheritance graph |
| Metadata/source privacy | Preserve tag/provenance/format meaning and known basename/source label where already approved. No absolute path/URI, raw header dump, inferred GPS or extra sensor/control introduced merely to store origin | Invalid/unknown/conflicting fields explicit; bounded reader limits; exported/source descriptors contain only approved data |
| Focus mode (AM-04) | Optional descriptive unrecorded/AF/MF; visible basic Phone/DSLR control; explicit entry only, no inferred EXIF/FITS value, numeric focus, hardware control, new timing or calibration identity dimension | Copy/save/reopen/entry/share/manifest/backup and legacy Unknown; all numerical calculations and calibration coverage unchanged |
| White balance | Optional Auto/named preset/Kelvin/Custom with optional tint for Phone/DSLR/Unknown; file Auto/Manual and DNG neutral vector remain distinct typed evidence. No neutral-vector→Kelvin conversion. Legacy unrecorded | Save/reopen/entry/share/additive manifest/backup; WB must leave exposure/budget/storage unchanged. Astro controls hidden, retained historic records not erased |
| Measured file-size evidence (D3/D5) | Positive byte length, format/read status, source label and known dimensions/layout/compression/binning/mode association. Measured compatible output wins; mode change invalidates or explicitly reconfirms. Do not scale measured bytes by binning | Already-binned/unbinned measured vectors, changed output mode, multiple-file pick order, block/rig association and preserved snapshots |
| Recognized but unread file (D3) | Accepted D3 A (owner, 2026-10-18): user-selected one-file byte length may estimate one frame, explicitly “mode not read; compressed sizes vary with content”; it supplies no dimensions/compression. Manual-size remedy remains. Alternative B (refuse this branch) was not chosen | Synthetic CR3 byte-length→decimal MB; no phantom tag values; unread mode cannot support theoretical payload |
| Theoretical payload (D4) | Only evidenced supported uncompressed DNG/FITS layout or explicit confirmed declared format. Normalize known native/output geometry once; ambiguous writer conventions remain unsupported/Unknown. Distinguish pixel payload from container/padding | Source S1–S4 and independent integer/float/FITS-padding/compression/binning vectors; no class-derived bit depth or compression ratio |
| Schema/snapshot/manifest | One compatible v25→v26 migration for accepted nullable fields/associations; additive snapshot/manifest keys under existing version contract. Missing/future-unknown values parse safely without invented origins. Old snapshots/results/forecasts remain immutable | Schema equality + content and derived-state comparisons, all named legacy/result/alias/preferences preserved; backup/manifest round trips and newer-schema data-safe refusal |
| FITS reuse | One registry/typed contract into EquipmentCandidate→match→review→Save and approved block fields; geometry keyword units and actual-vs-setpoint/gain kinds explicit. No hardware control or decoder expansion | END/read/axis/overflow/conflict/asymmetry fixtures plus real licensed/owner frame and device row; missing file blocks only the named FITS scope/final close |
| Calibration identity/coverage | Existing class applicability; whole modeled tuple, trimmed/case-folded filter equality, no alias guessing. Unknown advisory compatibility never proves known-value duplicate coverage. Counts/exposure examples are proposals only | Ha/bin1/OIII/bin2/flat-Ha-bin2, HA/Ha/H-alpha, known/unknown sensitivity, LENR, library/timing, preview/Cancel/Undo and budget invariance |
| Primary relative estimate | For comparable equal-exposure light frames, existing ideal sqrt(N) versus one equal frame is the concise primary figure, with reference and assumptions stated; keep incompatible groups separate and exclude calibration from gain | Existing independent sqrt(N) vectors and source grouping; N100 gives10x under the stated idealization. This is not absolute physical SNR; O2b detail keeps its separate planned-integration reference |
| O2b comparability | T=N·t and normalized ideal √(T/Tplan), separate known incompatible sensitivity/binning groups or explicitly label approved idealization; unknown does not prove equivalence. Empty/zero group has text, not a fabricated gain | Independent R-O2 values/tolerance from the existing source; zero/mixed/unknown groups; axes/reference point/text and no absolute-SNR claim |

Exact column/JSON names, IDs and future-enum encoding are engineering decisions in the accepted ADR, not a product choice silently settled by this table. D5 semantic association is accepted on 2026-10-18; exact schema/encoding and independent vectors still require the named local ADR-021 acceptance. A screenshot is not migration evidence. Domain limits and source-vector tolerance remain those of the repository, not newly invented here.

### NC contract — F13/F14/F15 plus navigation callers

| Item | Bounded semantic contract / local checkpoint | Check / boundary |
| --- | --- | --- |
| MF-c / coordinate frame | One semantic Moon-up definition everywhere; derive topocentric sampling equivalence to geocentric h₀, including equality/refraction/upper-limb assumptions. Do not copy a geocentric threshold beside a different-frame altitude | ADR-022 derivation, independent SI-015/boundary/polar/reference vectors and batch=single. Sketches do not supply the derivation |
| Moon-free intervals | Intersect the selected SessionNight's dark interval with Moon-below intervals. Distinguish evening/morning/all-night/none/mixed-disjoint/no-dark and missing-input states. No-dark is known absence of darkness, not the same as missing weather or an unknown value | Interval vectors including high latitude/no rise/set; same values in details/calendar/gate/text; phase never substitutes for interval calculation |
| Phase and calendar | Name phase from phase longitude at the existing model's defined reference instant; ADR names it explicitly. Offline month computation in isolate, cached by relevant site/zone/night-definition/model inputs; large-text week rendering and field hatching/text legend | Calendar/detail agreement and cache invalidation; physical timing measured at the existing gate. No Moonlit implementation reuse or universal good-night threshold |
| Weather time/coverage | Slice actual UTC hours for each resolved site night and selected dark span. Preserve instantaneous vs preceding-hour semantics; freeze partial-hour/dew-duration conventions in ADR-022. Up to 16 returned days is not 16 complete nights | First/last partial, absent-variable/no-dark/DST/out-of-range/stale/offline vectors; unknown never becomes zero/clear |
| Weather cache/races | Identity includes relevant coordinates/model/range/version, not site ID alone. Reuse/migrate/drop old keys safely; a late response cannot attach to a new edited site/night | Same-ID coordinate changes/out-of-order results/legacy key cleanup and correct stored forecast association |
| Two time labels | Retrieval age says how old this snapshot is; lead time says how far its forecasted night is from its source snapshot, under the exact ADR-022 rounding convention. They are not a reliability score | Source/age/lead labels and boundary fixtures; 1/2/3-day labels in sketches are illustrative only |
| Browse/adopt D9 | Browse date/month/forecast card is read-only; explicitly label viewed and active-plan context. Home/Planner editing remains current behavior under the accepted option. Adoption calls existing guarded draft/copy paths; saved originals/results are immutable | Control/state matrix SP08; contents **and derived UI** after Cancel/Back/restart/copy/site change; no second plan store or implicit retiming |
| Providers/privacy | Same Open-Meteo data and opt-in existing services; Clear Outside only on explicit user link. Update actual request/privacy/COMPLIANCE together when implemented | Call budget/live G1 checks, notices/policy consistency and no new seeing/provider/score |

The unresolved local derivation/encoding/rounding items are the already scheduled technical ADR checkpoints, not promises that no technical decision remains. Their dependent implementation cannot claim completion until accepted and evidenced. They do not block independent restore-safety or startup correction work.


## 9. UI contracts, evidence reuse and frozen release rows

### 9.1 Exact UI specifications and sketches

[FINALIZATION_REVIEW](FINALIZATION_REVIEW.md) §20 SP01–SP11 is an integral proposed UX contract annex, UTF-8/LF complete numbered section SHA-256 `80dbab0a0f484a461b78d9bd809dc75912bea1534b84fc7a2530e8a586afb7f6`. It gives each affected user decision, exact labels, minimum data, hierarchy/details, negative states, entry/return/Save/Cancel and layer owners. §22 simplification retains science/provenance/history; only owner-selected UX-S refinements from §5 are added. Resolve D/UX wording to current §5 and corrected F criteria; abandoned alternatives in the review are historical, not concurrent requirements. P3 images/manifest (§19) remain PROPOSAL fixtures; current application P2 captures and future production acceptance are distinct. U/owner final visual acceptance remains mandatory as frozen; P8 approval of a plan is not proof that implementation matches it.

### 9.2 Evidence reuse and future checks

Application baseline 570581e, schema 25, closed Stage 12/S13.1/S13.2 and RA research remain historical evidence. Existing successful checks may be reused only for unchanged relevant inputs under V3; no historical count/commit-distance is a current gate result. P2's two host observation tests and 71 renders reproduce limited current behavior; P3's one proposal-render QA and 62 sketches establish fixture layout only. P4's code review establishes feasibility, never implementation/device/comprehension PASS. No F task is implemented by this documentation. Independent-usability S6.E limitation stays explicitly UNVERIFIED as previously accepted; owner final visual acceptance and other mandatory rows remain mandatory. Live-provider/package facts are refreshed at the existing F/G checkpoint, not by another global research cycle.

### 9.3 Finite release artifact/evidence register

The following rows bind the gates in §3. All are PLANNED/OUTSTANDING. Each implementation A and the carried Stage 11 runbook rows remain individually referenced; this finite register never substitutes a broad green check for missing phone/data evidence.

| Row | Gate / actual evidence required | Dependency / immutable identity |
| --- | --- | --- |
| REL-01 | G1: F01–F25 A→result/evidence register, relevant Stage 11 matrix rows, local ADR/visual decisions and named physical carries | F10 complete or explicit owner deferral with PD-11/RG-03 consequences; host/full gate/native/Kotlin and accepted baseline evidence valid for inputs |
| REL-02 | G1: affected emulator L1–L6/L8; backup roundtrip, permission/offline/release behavior; retained valid F02 API 26–30 observation | Record environment/fixtures/baseline; no actual owner DB |
| REL-03 | G1: live Open-Meteo horizon/call budget, opt-in Nominatim, OSM, explicit links and policy/notices/accepted permission | Current implementation and dated primary evidence; provider failure remains failure/remaining row |
| REL-04 | F26: measure universal/arm64 download and installed sizes, then owner D6 variant selection | Measurement candidates from release inputs; measurement is not G2 qualification |
| REL-05 | F26: selected APK identity/versionCode/pubspec/AppIdentity/SDK/ELF 16 KB/expected public certificate fingerprint; negative signer/verifier tests | Owner signs outside agent access; debug/non-debug subject alone insufficient; absent verifier/evidence fails closed |
| REL-06 | F26: release commit/toolchain/version/signer/size/SHA-256/stable filename/SHA256SUMS and live policy; final-input gate/native/Kotlin/actual remote CI | Recheck only inputs invalidated by F26 tooling/version changes. CI after separately authorized push, no private keys in public CI |
| REL-07 | G2: actual selected APK clean install and same-key update from prior public release or signed lower-versionCode precursor | Record candidate and precursor hash/versionCode; precursor is not release candidate; isolated test profile or explicit owner install authorization |
| REL-08 | G2: four W/core loop L10, DNG/JPEG/HEIC and mandatory FITS rig/block review/save; original contents plus derived UI after browse/Cancel/copy/result | Exact selected candidate SHA; real files privately local, no raw metadata committed; S2V-06/S3V-08/M1/M4 mapped |
| REL-09 | G2: TalkBack H6/H7, field mode, motion, M3/M4 timing, calendar/forecast; first frame versus visible content and held splash S13V-02/03 | Same APK/device/settings/volume and original runbook thresholds; screenshots do not prove timing/comprehension |
| REL-10 | G2: literal immediate restore/Recents/applied/refused/outcome once; corrupt pick refusal; interruption; isolated old-id/old-schema→new-id/v26 recovery | Preserve aliases/values/origins/snapshots/forecasts/results/events/preferences and derived UI. Header/open/row-count alone insufficient |
| REL-11 | G2: owner old-app backup/migration completed or explicitly genuinely not applicable | Only after isolated rehearsals and separate owner-data authorization; verified independent backup before authorized uninstall; no automatic destructive workaround |
| REL-12 | G3: finite row reconciliation, no mandatory blockers, explicit optional/deferred debt and accepted usability limitation, owner go/no-go | F/G proofs actual, no new comprehensive audit or new criteria |
| REL-13 | G4: owner-authorized tag/release with selected APK bytes/checksums/public signer/notes, published download hash and signer comparison, phone core loop | Same REL-05/07 hashes. Rebuild creates new candidate and invalidates affected G2 evidence; publication requires separate explicit authorization |

### 9.4 Stop/change control

P7 checked base -02 and P8 approved it. AM-01 is version -03, AM-02 is version -04, AM-03 is version -05 version -06 records AM-03's decided Home title choice AM03-T = B, and current version -07 incorporates AM-04 familiar parameters; its changed criteria/annex are checked proportionally under V5–V7, without claiming a new independent global review. Approval/amendment does not start coding. Named implementation authorization advances only eligible tasks and stops at its finite end, unresolved local decision/resource or required independent validation. V5–V7 bound corrections/rechecks to original blockers and affected criteria. No endless audit/replanning or hidden expansion. Push/publication, signing secrets and owner-data actions retain their explicit boundaries.
