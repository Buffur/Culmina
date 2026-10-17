# Culmina — Final completion roadmap

**Status: PROPOSED — owner approval required. Date: 2026-10-17.**

**Amended 2026-10-17 at the owner's request:** the UX audit's five critical fixes are applied as local task amendments under the IDs UXA-C1 to UXA-C5 (C1–C5 in [UX audit 10](../audit/10_UX_AUDIT.md); this roadmap already uses C1–C6 for the readiness-review corrections). They touch F01, F05, F06, F08, F09, F13–F18, the U rule and G2 row 4. Where a fix contains a choice, the recommended option is written in and the alternative is listed for the owner as D7–D9 (§5). No Stage or Task is added. The report's recommendations (R1–R13) and nice-to-haves are not roadmap work unless the owner adds them.

One execution baseline: **approve → implement sequentially → verify the named acceptance criteria → finish**. This document consolidates approved remaining work; it does not authorize application changes today. After approval it replaces the remaining-task queue in `POST_ROADMAP_PLAN.md` (§5, Stages 12–17). Original IDs remain traceability aliases, not a second queue. No further global planning or comprehensive roadmap review is required.

## 1. Assessment and evidence boundary

The existing application already supports planning, equipment, targets, saved snapshots and post-session results. The remaining work is to correct verified defects, finish previously approved Capture Plan and night-condition behavior, connect it to the existing screens, and qualify a signed GitHub release. Previously approved additions such as the Moon calendar, WB record and AstroBin CSV remain in scope; this consolidation adds no product capability.

The original plan's main problems are distributed acceptance clauses, a critical restore fix mixed with schema design, broad maintenance grouping, and historical status mixed with the active queue. Audit 09 amendments M1–M16 are **already incorporated**, not new proposed research. This document consolidates them, separates restore safety from v26, makes dependencies explicit, and gives every remaining outcome a bounded test.

**Inspected repository baseline:** HEAD `b6e8c1e`; application baseline `570581e`; schema v25. The pre-existing change to `macos/Flutter/GeneratedPluginRegistrant.swift` is outside this documentation task. No application tests, device checks, build, live provider checks or remote CI refresh were run for this consolidation. Historical passing evidence below is recorded evidence, not a new execution claim.

- Stage 12 is closed by [the bounded closure record](STAGE_12_13_CLOSURE.md). S12.1/3/4 and S13.1/2 are complete. S12.2 is optional, unperformed, and not a release gate.
- Stage 13 remains blocked by S13V-01 / TD-109. S13V-02 and S13V-03 remain named final-device rows. Naming, artwork, repository rename, published policy and accepted Play-services decision are not reopened.
- Current source confirms TD-106, TD-107 and TD-108 mechanisms. TD-109's incompatible resource reference is present; its device effect is not newly reproduced here.
- Old tests and successful stages are reused under CLAUDE.md V3; they do not establish correctness of future changes or prove human comprehension.

**Authority:** the owner's current instruction; this roadmap once approved; `PROGRESS.md` for current status; `PRODUCT_DIRECTION.md` and accepted decisions in `DECISIONS.md`; CLAUDE.md V1–V8 and relevant engineering guardrails. Source code establishes actual behavior. Historical inputs: [original remaining plan](POST_ROADMAP_PLAN.md#stages-1217--culmina-release-roadmap-rap-2026-10-17), [audit 09](../audit/09_COMPREHENSIVE_AUDIT.md), [AUD dispositions](STAGES_12_17_AUDIT_AMENDMENTS.md), [readiness corrections C1–C6](STAGES_12_17_READINESS_REVIEW.md), [approved requirements](research/RA_D_ROUND2_PACKAGE.md), [UX audit 10](../audit/10_UX_AUDIT.md) (critical fixes applied as UXA-C1–C5).

## 2. Execution rules and shared acceptance

1. **Approval and start are separate.** Approval freezes this proposed baseline. An explicit start instruction may authorize one task or the entire bounded sequence. Within an authorized sequence Claude advances in dependency order without requesting repeated task-start permission. Otherwise the existing one-task start rule applies. An implementation session does not start today.
2. Execute the numbered sequence. Resolve ordinary implementation details inside the task. A missing FITS sample pauses F10 only; continue independent tasks and return before G1. Other unmet dependencies pause only affected tasks. Stage labels organize work; they do not create artificial prerequisites beyond those listed.
3. **Change control:** amend only the affected task for a demonstrated blocker, contradictory repository evidence, omitted necessary dependency, inability to meet an approved requirement, or an explicit owner change. Record the reason and affected criteria. Non-blocking findings go to a short follow-up list; speculative expansion stays excluded. No general re-audit, validation-of-validation or new exploration stage.
4. Apply CLAUDE.md **V1–V8**, rather than a second verification policy. `H` below means high-risk: full `dart run tool/check.dart` on the task's final code plus named domain probes. `S` means shared behavior: affected regression areas, analysis, changed-file format and encoding; full gate only where explicitly stated or the affected set cannot be bounded. A broader valid run satisfies its constituent checks. A later task invalidates only relevant evidence. Do not rerun unchanged checks for a newer timestamp.
5. Each task closes with a compact record: task ID; criterion-by-criterion result; changed files; commands and results or justified evidence reuse; baseline/environment; limitations; next eligible task. A task with mandatory pending device/owner evidence is **implemented, acceptance pending**, not complete. Update `PROGRESS.md` and only registers invalidated by the change. Original IDs need aliases, not duplicate completion records.
6. Preserve planning-first behavior, offline core, immutable saved snapshots/results, Save/Discard/Cancel, user-confirmed proposals, canonical scientific units, unknown-as-unknown, metadata provenance, and existing valid calculations. Never reset a newer database, silently replace real inputs with examples, or remove working behavior to pass acceptance.

**U — applies to every changed UI surface.** Test at 412 px width, 100% and 200% text, light/dark/field themes; include the changed editor/dialog, keyboard and error states. All controls and primary actions must be reachable; labels must not clip. Use real fonts and Material glyphs in host renders, or native captures; placeholder glyphs are not typography evidence. Run affected accessibility checks and obtain the existing owner visual acceptance. Apply reduced motion through `AppMotion`. For the block editor specifically use **412 × 915, 200%, keyboard open**; if the alert dialog cannot satisfy this, move it to the site editor's full-screen route pattern (a persistent Save and a discard guard; `site_editor_screen.dart`). The code has no full-screen dialog, so that route is the existing pattern (UXA-C4). Before F05 and after each Capture Plan UI task, record reference-plan scroll extent at 412 px/100% (three light blocks with a filter change, darks, flats, bias), section deltas and the owner's review; this is a density record, not an invented maximum length.

**W — four finite workflow checks, accumulated across tasks and closed by F25/G2.** (1) Phone manual/photo-assisted setup; (2) DSLR proposal/edit/cancel; (3) astro-camera metadata/calibration; (4) returning multi-night save/result/progress. Record each screen, action, backtrack/dead end, external value lookup, and visible fit/Unknown/relative-gain explanation. An agent or owner may perform the functional walkthrough. Human comprehension is claimed only from a person other than the builder. The previously accepted S6.E independent-participant gap remains **UNVERIFIED** when no participant exists; it does not become a new mandatory recruitment project.

## 3. Ordered implementation

### Stage A — Protect existing data and startup

**Objective:** remove the current restore risk and finish the already accepted splash. No ADR-021, FITS or visual-brand decision blocks this stage's core fixes.

### TASK F01 — Reject unsafe restores and recover interrupted activation

**Problem / Current State:** S14.3 safety slice; TD-106, CA-01/16/23, AUD-01. `backup_archive.dart` accepts a SQLite header/version; `backup_staging.dart` changes preferences and swaps files before production open. The confirmation promises an inaccessible safety copy.

**Required Outcome:** only a usable, supported candidate becomes live; failure preserves a coherent original database/preferences pair and reachable recovery instructions.

**Implementation Scope:** `lib/data/backup/`, production connection in `lib/data/database/app_database.dart`, startup in `lib/main.dart`, `backup_viewmodel.dart`, settings `backup_section.dart`. Validate/migrate an isolated candidate through the production lazy/background connection before changing live state. Run that check when the file is picked, before the confirmation, so an unusable file is refused at once; activation repeats it (UXA-C1). Include WAL/SHM handling and interruption recovery. Repair the confirmation and TD-105's current-app/version and singular/plural wording without adding an archive field. D2 controls optional Undo only; the safety fix proceeds without it. D7 controls only how a confirmed restore is activated; validation and the outcome report proceed without it. The start that applies or refuses a staged restore says so once and clears the staged state (UXA-C1).

**Acceptance Criteria:** A1 valid ZIPs containing truncated SQLite, missing expected schema, and unsupported/newer versions are refused at pick time, before the confirmation and before live DB/preferences change; activation repeats the check. A2 a real supported old database migrates, passes integrity, applicable FK checks and expected repository reads, and restores identifiable content/settings. A3 interruption at each activation boundary recovers to a coherent old or fully validated new state; restart never leaves mismatched preferences. A4 confirmation recommends the existing backup action and states only recovery the user can perform; activation follows D7 and works as the screen says, including after returning from Recents. With D7's recommended option no edit can happen between confirmation and activation; with the alternative, every tab shows the pending restore, says that changes made now will be replaced, and offers Restart and Cancel. If D2 enables Undo, newest-copy restore uses the same validated path and chosen retention limit. A5 the start that applies or refuses a staged restore reports it once — for example “Restored the backup from 12 Oct.” or “The restore wasn't applied: <reason>. Your data is unchanged.” — and Settings never shows a pending restore that no longer exists (UXA-C1).

**Verification:** H; extend `test/data/backup/backup_restore_test.dart` with real SQLite fixtures and failure injection, production-open refusal tests, confirmation widget tests, pick-time refusal and outcome-message widget tests (applied, refused, interrupted); literal instruction/device row in G2. Header-only stubs cannot prove old-database recovery.

**Completion Evidence:** fixture provenance, preserved-content comparisons, failure/restart matrix and final gate result; device row explicitly carried to G2 if pending.

**Dependencies / Risk:** none for validation, activation safety and the outcome report; D7 decides only the activation UI. No v26 work here; no owner-data rehearsal. Never discard the original merely because its version is newer.

### TASK F02 — Make the approved static splash work before Android 12

**Problem / Current State:** S13V-01 / TD-109; both Android launch backgrounds use a bitmap over a mipmap that resolves to an adaptive-icon XML on API 26–30.

**Required Outcome:** the approved mark/background appear on supported pre-12 Android; the owner-approved Android 12+ behavior remains intact.

**Implementation Scope:** both `android/app/src/main/res/drawable*/launch_background.xml` resources, existing identity assets/generator only as needed, `test/core/config/app_identity_test.dart`. Keep R3-final, the accepted 1,000 ms animated hold and reduced-motion exception.

**Acceptance Criteria:** A1 resources no longer use the incompatible bitmap/adaptive-icon combination. A2 an API 26–30 launch shows the static mark, background and transition. A3 Android 12+ retains its approved animation/exit and animation-off behavior; first-frame and visible-content times are distinguished. API 24/25 coverage, if available, is recorded separately rather than inferred.

**Verification:** full gate required by the original S13.3 contract; host resource regression, Android compilation and API 26–30 launch. G2 carries physical reduced-motion and final timing rows S13V-02/03.

**Completion Evidence:** resource regression, runtime capture and a V5 closure of S13V-01 only. No repetition of Stage 12 or all Stage 13 acceptance.

**Dependencies / Risk:** approval of this roadmap selects the proposed focused correction instead of carrying the known defect to final stabilization; emulator/runtime availability is an execution prerequisite, not proof of a pass.

**Stage A exit:** F01/F02 implementation criteria pass; any specifically carried final-device row is named. No unresolved restore-safety or pre-12 splash implementation defect remains.

### Stage B — Finish reliable Capture Plan entry and calculations

**Objective:** one coherent persisted contract from rig/file inputs through blocks, calculations, saved snapshots and export. F03's local contract acceptance precedes schema work; it is not another product planning stage.

### TASK F03 — Freeze the capture contract and persist it compatibly

**Problem / Current State:** S14.1 plus S14.3 schema slice; PD-05–14/21, AUD-04/05/06/16, CA-03/06/07/22. v25 lacks the approved WB, field-source and format/mode evidence contract.

**Required Outcome:** accepted ADR-021 and a data-preserving v26 migration support every subsequent Capture Plan task.

**Implementation Scope:** first record a numbered ADR-021 decision sheet and obtain its existing owner acceptance. Specify field types/units/destinations, source/conflict/unsupported states, WB, measured-size persistence, mode compatibility, binning normalization, FITS→rig mapping, CAL-1 coverage and O2b comparability. Per required rig field list dependent calculations and manual/photo supply; preserve ADR-011. Then implement Drift columns, generated steps/schema snapshot, snapshot/manifest v2 additive keys and backup round trips. Amend ADR-009/017/018/020, SI-013, CALC-16/42 and DATA_MODEL only where affected.

**Acceptance Criteria:** A1 each contract choice has a concrete recommendation and accepted result, including D3–D5 below; missing legacy origins stay unrecorded. A2 v25→v26 preserves rigs, aliases, blocks, original snapshots/forecasts, results, legacy events and preferences; schema equality and repository reads pass. A3 WB/source/measurement-mode associations survive save/reopen, additive manifest and backup round trips; old data defaults are explicit, not invented. A4 pinned schema tests are updated; newer-schema refusal remains data-safe. A5 the FITS sample gate is raised at task start: identify an available owner file or licensed fixture; record absence early without blocking independent tasks.

**Verification:** H; `schema_migration_test.dart`, `unsupported_database_test.dart`, backup and `session_manifest_codec_test.dart`; content and derived-state comparisons, not row counts alone.

**Completion Evidence:** accepted ADR-021 decisions, generated migration evidence, field/round-trip matrix and final gate.

**Dependencies / Risk:** F01 before new-schema restore regression. D3–D5 and ADR acceptance gate only the dependent implementation. No partial/nullable rig model or second metadata pipeline.

### TASK F04 — Extend the existing typed metadata contract

**Problem / Current State:** S14.4; approved block/storage fields need extraction and provenance beyond the existing readers.

**Required Outcome:** DNG/JPEG/HEIC and the upcoming FITS reader share explicit values, units, origins and unsupported/conflict outcomes.

**Implementation Scope:** `lib/domain/metadata/capture_metadata.dart` and existing reader registry/readers. Add DNG BitsPerSample (258), Compression (259), AsShotNeutral; EXIF WhiteBalance (41987), LightSource (37384); common types for F10's approved FITS keywords. Preserve ISO kind; distinguish acquisition gain/conversion gain, X/Y binning, actual temperature/setpoint, supported axes/sample layouts. Extraction does not authorize extra planning controls.

**Acceptance Criteria:** A1 each field has tag-level provenance and correct absence/conflict/invalid handling. A2 DNG neutral values remain vectors; JPEG/HEIC modes do not invent Kelvin. A3 unsupported compression/layout/asymmetric binning is explicit; bounded reads remain bounded. A4 synthetic and local real DNG/JPEG/HEIC samples exercise the extension; the common FITS contract exists without requiring its reader yet.

**Verification:** H; existing `test/domain/metadata/` fixtures and local real-sample test, including absent, contradictory and out-of-range values.

**Completion Evidence:** field/tag fixture matrix, real-sample result without private metadata in Git, final gate.

**Dependencies / Risk:** F03 accepted contract; real-file evidence is not replaced by synthetic fixtures.

### TASK F05 — Make manual and photo-assisted rig creation usable

**Problem / Current State:** S14.2, CA-02, AUD-04; photo import is an unlabeled secondary icon and required scientific inputs lack clear reasons.

**Required Outcome:** a user can choose class and reach the existing manual or photo-assisted rig flow wherever a rig is needed.

**Implementation Scope:** equipment editor/selection, existing `/equipment/import`, missing-rig actions on Planner/Tonight; F16 integrates onboarding. Class first, including explicit Unknown. Two equally visible labeled choices: From a photo / Enter by hand; photo first for Phone/DSLR, manual first for Astro until F10. State readable formats; explain why each required field is needed. Set the example class from cited seed evidence only for new installs. A rig saved from a plan's missing-rig action or from onboarding becomes that plan's rig, per D8 (UXA-C2); one created in the Library is only saved. A changed rig editor asks before discarding (UXA-C4).

**Acceptance Criteria:** A1 list, empty state and missing-rig actions expose both choices. A2 synthetic phone JPEG containing focal length, aperture, 35 mm-equivalent focal length and dimensions reaches a saved rig without typed sensor values. A3 incomplete metadata identifies missing inputs without guessed defaults; existing rigs retain their class. A4 class-specific block fields follow the accepted contract; U and the setup portion of W pass. A5 per D8, Save from a missing-rig action on Planner or Tonight, or from onboarding, returns the user to where they started with that rig chosen for the plan, the missing-rig status gone and a message (for example “Rig saved and chosen for this plan”); Cancel changes nothing; from the Library the rig is only saved (UXA-C2). A6 a changed rig editor asks before discarding on Back or a tap outside, with the existing Discard prompt or the site editor's full-screen route pattern (as TD-084 required of the site editor); an unchanged editor closes at once (UXA-C4).

**Verification:** S; equipment import/editor/selection and missing-rig widget tests, including create-then-chosen from each missing-rig entry point and discard-guard cases (Back, tap outside, unchanged), relevant block-form regressions; establish the reference-plan density baseline before changes.

**Completion Evidence:** route/required-input matrix, JPEG journey, U renders/acceptance and explicit remaining input barriers.

**Dependencies / Risk:** F03; D8 for A5's outcome. No specification service, relaxed required-input invariant or new equipment mode.

### TASK F06 — Preserve block settings, origins and white balance

**Problem / Current State:** S14.6/8, TD-108, RA-F05, CA-04/12; valid custom filters are coerced to None, light exposure leaks into other block types, and approved sources/WB are not persisted/displayed end to end.

**Required Outcome:** editing and reopening a block preserves its intended values and provenance; WB is an honest record.

**Implementation Scope:** `capture_block_dialog.dart`, capture block models/presentation, snapshot/detail/share/export paths using F03 fields. Preserve custom filters both on initial edit and Use other values; class-specific defaults; reset inappropriate proposals on type switch. WB modes: Auto, named preset, Kelvin, Custom, optional tint; Phone/DSLR/Unknown only. File modes and DNG neutral vectors remain distinct. Give the block editor the discard guard of F05 A6 (UXA-C4).

**Acceptance Criteria:** A1 unchanged valid custom light/flat filters survive edit and Use other values; null remains null; domain length validation stays. A2 origin markers survive switch/edit/reorder/delete-Undo/copy/save/reopen and snapshot/backup; user edits replace the applicable source and Cancel changes nothing. A3 flat/bias do not inherit an unintended light exposure; default filter follows class. A4 WB appears in snapshot, entry, manifest and share text; old missing values remain unrecorded; WB changes no exposure, budget or storage result. A5 U, including keyboard-open editor and density record, passes; wording says WB guarantees no identical colors. A6 a changed block editor asks before discarding on Back or a tap outside, as in F05 A6; an unchanged editor closes at once (UXA-C4).

**Verification:** H for persisted provenance; light/calibration form, capture Undo, round-trip and unchanged-calculation regressions; discard-guard cases.

**Completion Evidence:** value/source operation matrix, WB round trips, renders and gate.

**Dependencies / Risk:** F03–F05. No conversion of AsShotNeutral to Kelvin or device control.

### TASK F07 — Produce storage estimates from compatible evidence

**Problem / Current State:** S14.7, PD-06, CA-07/18, AUD-05; storage often stays Unknown and the new evidence chain needs mode/binning rules.

**Required Outcome:** use compatible measured size first, supported theoretical evidence second, otherwise explain Unknown and its remedy.

**Implementation Scope:** capture budget/storage calculation and `capture_budget_summary.dart`, rig/block file evidence and `QuantityText`. Scope evidence by format, dimensions/output mode, compression, binning and source. Use ADR-021's accepted unread-file and binning rules; recognize file length without pretending to parse it. Integrate F10's FITS branch when available.

**Acceptance Criteria:** A1 compatible measured file wins; mode changes invalidate or explicitly reconfirm it; an already-binned file is never scaled again. A2 theoretical output requires evidenced uncompressed DNG, supported FITS layout, or explicitly confirmed declared format; distinguish pixel payload and container bytes. Unknown compression/layout remains Unknown. A3 camera class never selects a size assumption; Unknown offers file/manual-size action. A4 unread-format behavior follows D3, with mode-unread/content-variation wording if accepted; CR3 length vector uses decimal MB. A5 S1–S4, compressed boundary and binning vectors pass; MB/GB use `QuantityText`, 10^6/10^9 bytes, visible source and assumption.

**Verification:** H; independent storage vectors for unbinned/already-binned measurements, changed modes, DNG sample layouts and integer/floating FITS payload/padding; U for display.

**Completion Evidence:** vector inputs/expected/actual, invalidation examples, source labels and gate; FITS runtime branch completed in F10.

**Dependencies / Risk:** F03/F04/F06. No proprietary RAW decoder, guessed compression ratio or class-derived sensor facts.

### TASK F08 — Populate a light block from a reviewed photo proposal

**Problem / Current State:** S14.9, TD-072, PD-11; file import exists for rigs but not the approved block workflow.

**Required Outcome:** a picked DNG/JPEG/HEIC proposes applicable block fields with sources; Save alone persists them.

**Implementation Scope:** existing `CaptureFileAccess`, registry and light editor. Propose exposure, ISO with kind, WB and format/size evidence; flag pixel-count/mode conflicts and make repeated picks order-independent. Use F10 for FITS later, without blocking non-FITS acceptance.

**Acceptance Criteria:** A1 preview shows only approved class-applicable fields and sources; no exposure/ISO change reaches the rig. A2 Cancel/read failure leaves stored block/rig unchanged; repeat picks, edited proposals and differing dimensions have deterministic visible outcomes; an unsaved proposal counts as a change for F06's discard guard (UXA-C4). A3 TD-072's size conflict is independent of pick order; custom filters and persisted sources survive. A4 DNG/JPEG/HEIC Save/reopen works on device; U and W's DSLR proposal/edit/cancel path pass.

**Verification:** H; parser→proposal→Save integration and widget tests, real-file/device DNG/JPEG/HEIC row. Required FITS evidence belongs to F10/G2, not a hidden blocker here.

**Completion Evidence:** proposal/conflict/cancel matrix, file-format/device results and gate.

**Dependencies / Risk:** F04/F06/F07. Reuse one import pipeline; never silently infer extra camera controls.

### TASK F09 — Build correct calibration proposals and retire the example action

**Problem / Current State:** S14.10/13, TD-107, CA-03, AUD-02; flat warnings use unrelated filter/binning membership and missing-flat detection is filter-only. Calibration generation is approved; the example action waits for real replacement flows.

**Required Outcome:** matching, missing coverage and preview generation agree on whole modeled settings; users can construct the plan without the example shortcut.

**Implementation Scope:** `calibration_match.dart`, its analysis/widget callers and existing block editing/Undo. Compare trimmed case-folded names without alias guessing; preserve recorded filter spelling. Propose darks per distinct exposure/sensitivity/binning, flats per compatible filter/binning, bias/dark flats by class. Remove the example UI action only after F08 and this workflow pass, together with the empty Capture Plan state that replaces it (A6, UXA-C5); retain `ExampleCapturePlan` as a test fixture and migrate affected E2E flows.

**Acceptance Criteria:** A1 lights Ha/bin1 + OIII/bin2 with flat Ha/bin2 do not satisfy either full tuple incorrectly; both warnings and missing coverage use that rule. Ha=HA; H-alpha≠Ha. A2 unknown sensitivity is not proof of known-value coverage; unresolved preview requirements are shown and proven duplicates omitted. A3 LENR suppresses dark proposals; counts stay proposals; library/timing policies and budget remain correct, calibration never counts as integration. A4 preview Cancel changes nothing; confirm persists; Undo after a newer edit preserves that edit. A5 custom/imported FILTER and hidden-class binning tests pass; example-action replacement E2E and U pass. A6 with no blocks, the Capture Plan names the next step with labelled actions — for example “Add light frames”, plus “Take from a photo” where F08 (for astro cameras, F10) supports the rig's class — and says calibration can be built from the lights afterwards; the empty state's actions are not icon-only; the E2E that replaces `capturePlan.useExample` starts from this state (UXA-C5).

**Verification:** H; `calibration_match_test.dart`, calibration widget/Undo tests, the empty-state widget test, capture-budget regressions and core-loop replacement path.

**Completion Evidence:** tuple/coverage fixture table, preview/Undo evidence, replacement journey and gate.

**Dependencies / Risk:** F06 and F08 before example removal. Advisory compatibility must not become proof of full calibration-library suitability.

### TASK F10 — Read FITS headers into the existing rig and block flows

**Problem / Current State:** S14.5 and conditional F07/F08 integration; CA-06/15, RG-03 Q1. FITS is recognized but unread.

**Required Outcome:** supported FITS supplies reviewed rig/block/storage evidence through existing paths, backed by a real astro-camera file.

**Implementation Scope:** existing metadata registry, F04 types, EquipmentCandidate→match→review→Save and F08 proposal path. Read SIMPLE/BITPIX/NAXIS/NAXISn; EXPTIME/EXPOSURE, GAIN, OFFSET, XBINNING/YBINNING, CCD-TEMP, FILTER, DATE-OBS, INSTRUME; rig XPIXSZ/YPIXSZ (µm), FOCALLEN (mm, softwareSetting), TELESCOP (identity only). Bound 2,880-byte header records through END. Use ADR-021's supported HDU/layout and once-only binning normalization.

**Acceptance Criteria:** A1 record boundaries, missing END, read/axis/overflow limits, floating BITPIX, conflicting exposure, arbitrary FILTER and absent/asymmetric binning have tested outcomes. A2 binned/unbinned writer vectors normalize geometry exactly once; unsupported meanings/layouts stay explicit. A3 real FITS runs through reader, reviewed saved rig, applicable block proposals and storage; Cancel stores nothing. A4 photo-choice labels now advertise FITS; recognized-only RAW remains honestly described. Only already approved block fields become controls.

**Verification:** H; synthetic headers plus at least one owner-provided local sample or licensed fixture; device rig/block check, storage/calibration integration and U.

**Completion Evidence:** fixture provenance/license, keyword/normalization matrix, real-file and device evidence, gate. Do not commit private samples or values.

**Dependencies / Risk:** F03/F04 plus F07–F09 for integration. Sample absence permits independent work to continue but blocks G1 until F10 completes or an explicit owner deferral records PD-11/RG-03 consequences.

### TASK F11 — Show relative improvement over integration time

**Problem / Current State:** S14.11, PD-05, AUD-16; the existing relative-gain calculation needs the approved O2b presentation and comparability rules.

**Required Outcome:** a curve and text alternative show ideal relative improvement against planned integration without implying physical SNR.

**Implementation Scope:** existing stacking-gain service/presentation; T=N·t, normalized √(T/T_plan), ADR-021 grouping. Split known incompatible gain/binning groups or explicitly label the accepted idealization; retain SI-003 explanation.

**Acceptance Criteria:** A1 ratios 0.5/1/2 yield 0.7071/1/1.4142 within the recorded vector tolerance. A2 zero integration, mixed and unknown settings yield truthful group/empty/text states; unknown never proves equivalence. A3 axes, reference point and text explain the relative quantity; no absolute-SNR claim or new exposure model. U and W's visible-explanation check pass.

**Verification:** H; independent R-O2 vectors and existing `stacking_gain_curve_test.dart`, chart semantics/text tests.

**Completion Evidence:** vectors, grouping decisions, rendered/text alternative and gate.

**Dependencies / Risk:** F03; F06 when using persisted settings. Preserve existing valid √N behavior.

### TASK F12 — Explain effective assumptions and actionable fit limits

**Problem / Current State:** S14.12, TD-074, PD-10/14; assumptions and the existing what-fits result are not consistently actionable.

**Required Outcome:** the plan explains the inputs that affect its current result, how to change them, and what fits for every evaluable block.

**Implementation Scope:** existing assumptions/budget UI and `FitAnalyzer` outputs; correct stale label, link to Settings, add the approved star-focus/recheck reminder. Keep the existing refocus overhead as the only timing concept.

**Acceptance Criteria:** A1 displayed assumptions are the effective calculation values. A2 evaluable blocks get FitAnalyzer-derived guidance; unavailable results name the missing inputs without hiding still-valid results. A3 focus has no numeric control/value and alters no calculation. A4 Settings navigation, fit/error/Unknown states, U and visible-explanation W checks pass.

**Verification:** S; affected fit/budget/viewmodel/widget regressions and navigation checks.

**Completion Evidence:** representative fits/non-fits/partial-input states, assertions against service outputs, U evidence.

**Dependencies / Risk:** F07; no new assumptions engine or invented rig specifications.

**Stage B exit:** F03–F12 criteria pass; data and source round trips and scientific vectors are demonstrated. Pending named final-device repeats remain listed for G2. F10 may stay blocked while independent Stage C work proceeds, but this stage cannot close with silently omitted FITS.

### Stage C — Connect night conditions, screens and saved records

**Objective:** finish approved night views and existing user journeys; preserve one plan lifecycle. Complete maintenance before the final consistency sweep.

### TASK F13 — Use one Moon-up rule and derive moon-free intervals

**Problem / Current State:** S15.1–3, SI-015, AUD-07; rise/set and Moon-up counts use different definitions.

**Required Outcome:** accepted ADR-022 and one frame-correct predicate drive rise/set, gates, counts, phase and moon-free intervals.

**Implementation Scope:** first obtain local ADR-022 acceptance covering MF-c, coordinate-frame equivalence, equality/sampling limits, phase longitude, interval classification, F14's forecast/cache/dark-span conventions and F15's cache contract, plus browse versus adopt as its own numbered interaction item (D9, UXA-C3), presented as a flow with renders. Then update Moon calculations, gates and `night_text`; amend ADR-010/012/013 and CALC-28/29/32/33/43 where affected. Reuse existing lunar model and authoritative reference fixtures.

**Acceptance Criteria:** A1 the topocentric sampling predicate is derived as equivalent to geocentric h₀, rather than copying the numeric threshold into the wrong frame. A2 rise/set, dark counts, gate and annotations agree at the boundary; high-latitude/polar cases and batch=single pass. A3 dark∩Moon-below intervals distinguish evening/morning/all-night/none/mixed-disjoint/no-dark; phase name follows phase longitude, never substitutes for interval calculation. A4 SI-015 and relevant vectors are reconciled; no universal good-night threshold. A5 ADR-022's browse/adopt item records, with renders: which controls browse and which edit (the Home and Planner context lines, a calendar day, an overview card); the adopt action's label and place; adoption on a never-saved and on a saved plan; how a browsed night is labelled; and the confirmation afterwards. The owner's acceptance names the D9 option chosen (UXA-C3).

**Verification:** H; independent synthetic and USNO-referenced vectors, astronomy/Moon/visibility regression, text-state tests. Consult primary external references only if an unresolved local technical point requires it.

**Completion Evidence:** accepted ADR-022 including the D9 flow and renders, predicate derivation, vector comparison and gate.

**Dependencies / Risk:** existing approved MF-c decision; independent of FITS. ADR acceptance is a bounded checkpoint — the technical items plus the one D9 interaction item — not a product reassessment.

### TASK F14 — Show honest multi-night weather coverage

**Problem / Current State:** S15.4/5, TD-049, CA-09, AUD-08; current weather is one night, and the summary uses sunset-to-sunrise rather than the required dark span.

**Required Outcome:** one existing-provider request serves the available horizon, with accurate per-night cards, coverage, freshness and lead time.

**Implementation Scope:** existing Open-Meteo repository/cache, `NightWeatherSummarizer`, weather views. Slice returned UTC hours; cache identity includes coordinates, model, range/version. Preserve offline/freshness semantics; safely drop/migrate old entries and TD-049 keys. Apply ADR-022's partial-hour, preceding-hour/instantaneous and dew-duration conventions. Update privacy/COMPLIANCE alongside actual data behavior. Overview cards only browse; adopting a night from them follows ADR-022's D9 item (UXA-C3).

**Acceptance Criteria:** A1 an up-to-16-day response is not presented as 16 complete nights; first/last partial, DST, absent-variable, no-dark, stale/offline and out-of-range states are explicit, never zero/clear defaults. A2 same-ID coordinate changes and late responses cannot attach data to the wrong site. A3 cards lead with dark-span cloud range and moon-free hours, with precipitation/wind/gust/dew secondary; hourly strip includes cloud layers, gusts, humidity and dew point. A4 snapshot-relative “forecast N days ahead” is separate from retrieval age; no reliability score. A5 seeing/transparency limitation and user-opened Clear Outside link are explicit; request budget recorded; U passes. A6 opening a night's card changes no plan; adopting that night follows D9 (UXA-C3).

**Verification:** H; repository race/cache tests, dark-span summarizer vectors including partial hours, card/strip tests and affected privacy contract checks; live service evidence in G1.

**Completion Evidence:** coverage/cache matrix, request-budget and duration vectors, UI/wording evidence and gate.

**Dependencies / Risk:** F13; no additional provider, quality score or forecast-accuracy promise.

### TASK F15 — Browse Moon nights without changing a saved plan

**Problem / Current State:** S15.6, AUD-07/09; approved calendar and combined night bar must share calculations and lifecycle with existing details.

**Required Outcome:** offline calendar and night/Moon detail are consistent; browsing becomes a plan change only on explicit adoption.

**Implementation Scope:** `night_moon_screen.dart`, existing services and lifecycle viewmodel. Compute month in an isolate, cache relevant site/night-definition inputs, week view at large text; combined bar, legend, text alternative and field hatching.

**Acceptance Criteria:** A1 calendar/detail predicates and values agree; cache changes with relevant context. A2 browsing/back leaves current and saved plans/results intact; a browsed night is labelled against the plan's night (for example “Viewing Fri 14 Nov · your plan: Tue 10 Nov”); explicit adoption follows ADR-022's D9 item and uses existing Save/Discard/Cancel for dirty/saved states (UXA-C3). A3 site change and restart preserve original snapshot/results. A4 U passes; phone timing is measured against the applicable existing runbook criterion, with no invented performance PASS.

**Verification:** S; calculation integration, lifecycle/cache/route tests, accessibility/text alternative, phone calendar timing (G2 may carry final measurement).

**Completion Evidence:** browse/adopt state matrix, cache evidence, renders and device timing status.

**Dependencies / Risk:** F13. No second plan store or automatic retiming.

### TASK F16 — Enter planning through one stable first-run screen

**Problem / Current State:** S16.1, RA-B01–06; Tonight draws before Welcome; Skip/Done duplicate behavior.

**Required Outcome:** first-run routing is correct before the first frame and optional setup is reachable without a dead end.

**Implementation Scope:** `app_router.dart`, startup/Welcome and F05 rig choices. One screen: optional site (GPS on tap or choose), class→rig, title, concise permission rationale, Start planning; no target step/Skip.

**Acceptance Criteria:** A1 loaded first-run flag determines the first frame; no Tonight flash. A2 both setup steps can be omitted and planning remains reachable; location is never requested automatically. A3 class-specific labeled manual/photo paths and cancellation work; a rig saved there becomes the plan's rig per D8 and the setup screen shows it (UXA-C2); missing required inputs are explained without fake defaults. A4 first-run/returning-run core-loop, U and W setup checks pass.

**Verification:** full gate for router/startup shared behavior; first-frame/router/widget and updated core-loop tests.

**Completion Evidence:** first-run state table, launch observation, setup journey and gate.

**Dependencies / Risk:** F05; F10 only for advertising FITS as readable. Startup must not wait for weather.

### TASK F17 — Put night context and the existing plan first on Home

**Problem / Current State:** S16.2, PD-03/Q1, RA-D; current hierarchy duplicates actions and underuses existing night information.

**Required Outcome:** Home leads with night facts and returns clearly to the same plan.

**Implementation Scope:** Tonight/Home presentation; title with field mode, tappable site/night subtitle, night card, Your plan/Open planner, secondary target-candidate action. Remove the redundant Home New plan action while retaining the established plan lifecycle.

**Acceptance Criteria:** A1 night card shows dark window, phase/moon-free hours, cloud coverage/freshness and detail links; partial data remains honest. A2 plan card opens the current plan; no duplicate context/store. A3 browsing conditions versus adopting context follows ADR-022's D9 item (UXA-C3): with the recommended option the site/night subtitle stays the plan's own context, so the night card and Your plan always describe the same night; dirty-plan Cancel preserves values/results. A4 empty/loading/offline/error/saved states, U and relevant W path pass.

**Verification:** S; Home states, navigation and lifecycle regressions, affected core-loop keys.

**Completion Evidence:** state captures, browse/adopt assertions and owner visual acceptance.

**Dependencies / Risk:** F13–F15; preserve target-candidate functionality as the approved secondary action.

### TASK F18 — Make Planner status, next actions and conditions unambiguous

**Problem / Current State:** S16.3, TD-095, RA-F01–03, CA-05/12; repeated context, long form and stale autosave banner obscure the next action.

**Required Outcome:** empty/partial plans show actionable requirements; computable plans show one status and coherent editing/saving.

**Implementation Scope:** existing planner screen: site/target/rig/capture checklist with working actions, target once, compact altitude chart, remove duplicate weather row while retaining window annotations and detail links; clear autosave banner after successful save.

**Acceptance Criteria:** A1 each missing item opens the right selector, the capture item opening F09's empty Capture Plan state (UXA-C5); fit status appears when computable with explicit Unknown reasons. A2 save success clears banner; error keeps recoverable draft and correct status. A3 cancel/back/browse/adopt behavior follows ADR-022's D9 item (UXA-C3), agrees with Home/calendar and never overwrites saved timing/results. A4 fit and relative gain explanations are visible in W; U and before/after reference-plan scroll record pass.

**Verification:** S; planner empty/partial/saved/dirty/error tests, saved-plan transitions and fit presentation regressions.

**Completion Evidence:** state/journey matrix, service-backed labels, scroll deltas and visual acceptance.

**Dependencies / Risk:** F06–F12, F15/F17 for shared navigation; FITS absence blocks only FITS-specific row, not unrelated hierarchy work.

### TASK F19 — Complete returning-plan and Logbook actions

**Problem / Current State:** S16.4, PD-19, RA-G; existing records need visible management, saved forecast and target-progress entry points.

**Required Outcome:** a returning user can reuse a target/night, record results and inspect per-target progress while preserving prior records.

**Implementation Scope:** Logbook segment for progress by target, target-row Plan this target, stored forecast in entry, visible rig/target Delete with RD-09 Undo. Preserve RD-07 Library/Logbook roles.

**Acceptance Criteria:** A1 create/copy another night's plan without changing original snapshot/result. A2 completed/partial/not-done results save, reopen and affect progress consistently. A3 entry forecast is the stored snapshot with its original age/source, not current weather substituted silently. A4 visible Delete/Undo preserves newer intervening edits; U and W returning multi-night journey pass.

**Verification:** S; records/result/progress and immutable-snapshot tests, delete/Undo interaction and persistence checks.

**Completion Evidence:** saved-content comparisons, result/progress journey and U acceptance.

**Dependencies / Risk:** F03/F06 for new snapshot fields; no live tracker or new record type.

### TASK F20 — Export recorded acquisitions using the AstroBin CSV contract

**Problem / Current State:** S16.5, CA-08, AUD-11; Culmina filter names are not the receiver's numeric equipment IDs.

**Required Outcome:** existing share/export produces a truthful acquisition CSV with correct unknown and grouping semantics.

**Implementation Scope:** read and cite the current primary CSV contract at task start; freeze receiving field/status/date/count/rejection semantics and map saved snapshot/results. Use the existing export/share plumbing and version the mapping in EXPORT_MANIFEST. Current approved rule: numeric filter column empty; separate light rows by filter, names in row order in share text; compatible calibration counts only. If the receiver contract materially contradicts that rule, amend this task locally before implementation.

**Acceptance Criteria:** A1 fixtures cover completed/partial/not-done/no-result/legacy/mixed-group/multiple-night records; unsupported acquisition data is explicitly unavailable, not fabricated from a plan. A2 unknown stays blank, never invented zero/date; escaping and units match the cited contract. A3 names never occupy a numeric-ID field; row order/share-text association is deterministic. A4 dark/flat/flatDark/bias counts attach only through proven F09 whole-tuple coverage, otherwise blank; existing manifest export remains compatible.

**Verification:** H; independently expected CSV fixtures, parser/format validation and share/export integration.

**Completion Evidence:** dated source URL, field/status mapping, fixtures and gate.

**Dependencies / Risk:** F03/F09/F19. No AstroBin authentication, ID lookup/store, upload integration or new export mode.

### TASK F21 — Persist Appearance and units across views and backups

**Problem / Current State:** S16.6, PD-20, AUD-12, CA-10; preferences are approved, but BackupPreferences currently serializes only bool/int/double values.

**Required Outcome:** System/Light/Dark and temperature/wind/elevation choices survive restart/restore and consistently affect presentation.

**Implementation Scope:** settings/theme, `QuantityText`, backup preferences; compatible enum encoding or explicit serializer extension. Apply D1's approved token/default choice and document changed AA pairs; field mode remains unchanged.

**Acceptance Criteria:** A1 every preference value round-trips; old backups get documented defaults, unknown future values safe fallback. A2 °C/°F, km/h/mph/m/s, m/ft flow through affected UI/share paths; scientific storage and calculations remain canonical. A3 absolute temperature conversion and temperature-difference/dew-margin conversion are separately tested. A4 D1 token pairs meet AA; U, restart and backup tests pass.

**Verification:** full gate for cross-screen behavior; backup/enum, conversion and theme regressions.

**Completion Evidence:** preference/backup and display coverage tables, conversion vectors, contrast evidence and gate.

**Dependencies / Risk:** D1 and F03/F14/F19 presentation contracts. No localization or new scientific thresholds.

### TASK F22 — Restore the open route without corrupting saved or draft state

**Problem / Current State:** S16.8 slice, TD-094 and TD-102's durability probe; data returns after process death but the route does not.

**Required Outcome:** process recreation returns to a valid prior screen and preserves the established data lifecycle.

**Implementation Scope:** router/restoration and existing restorable editor state as needed. Convert the existing plan-name/result/legacy-event kill-and-upgrade probe into a permanent regression; preserve original TD-094 scope without adding a second draft persistence system.

**Acceptance Criteria:** A1 background process death on Planner and representative existing form returns to the intended route or an explicit valid fallback if its referenced entity was deleted. A2 restored arguments never adopt another site/night or overwrite a saved result; cancel remains safe. A3 named plan and every existing result field, including not-done reason and supported reported events, survive relevant kill and v24→v25→v26 paths. Any unsupported unsaved-form restoration is documented against the existing contract before claiming completion.

**Verification:** S, escalated to H if persistence/migrations change; lifecycle matrix, permanent durability regression and emulator process-death test; physical row in G2.

**Completion Evidence:** route/state matrix, old-schema content comparison, process-death results.

**Dependencies / Risk:** F16–F19/F21 before final shared-navigation edits; do not invent restoration behavior for a new form model.

### TASK F23 — Finish existing provider labels and bundled notices

**Problem / Current State:** S16.8 slice; TD-097/098/031, C4/S12.4. Municipality names and native-library attribution are incomplete; some compliance register statements are stale.

**Required Outcome:** existing location lookup displays supported names, and About/licences reflect the actual approved Android dependencies and distribution.

**Implementation Scope:** existing Nominatim mapper, About/licence registry, COMPLIANCE and relevant TD-031 entries. Add municipality fallback with documented key precedence. Include actual bundled Android notices and the already accepted Google Play services GPL additional-permission statement. Reconcile policy/provider/dependency claims against current code; preserve opt-in, attribution and call limits.

**Acceptance Criteria:** A1 municipality-only response names the place; absent/invalid values still fall back to coordinates; existing precedence stays tested. A2 Dart/native notices and accepted permission are visible and match the build dependencies. A3 each TD-031 subitem is resolved with evidence, retained as an explicit non-blocking limitation, or reported as a concrete release blocker; no generic “all legal risks fixed.” A4 provider changes are not invented to close the register; U passes for changed pages.

**Verification:** S for mapping/UI; primary provider/licence references only where the active check needs them; native dependency/notice comparison and G1 live checks. Highest actual V1 class applies if dependencies change.

**Completion Evidence:** mapper fixtures, notice inventory, bounded TD-031 disposition and visual evidence.

**Dependencies / Risk:** F14/F21 before final notice/policy alignment; no provider replacement, licence change, no-Play-services project or Android CI expansion.

### TASK F24 — Close the finite reproducibility and diagnostics checklist

**Problem / Current State:** remaining S16.8 maintenance has named test/diagnostic gaps; several older debt entries describe obsolete code.

**Required Outcome:** current regression evidence is deterministic and the specified diagnostics contracts are enforced, without a general cleanup project.

**Implementation Scope / Acceptance Criteria:** this is the complete bounded checklist; add no adjacent debt:

| Criterion / original ID | Required result | Minimum verification |
| --- | --- | --- |
| A1 / TD-096 | Harness/repository tests that depend on night/date use fixed injected clocks | Relevant cases at formerly failing morning/evening instants; no wall-clock flakiness claim based on one run |
| A2 / TD-102 (map half) | Existing all-tiles-fail probe becomes a committed test, with host path_provider fake | Failed tiles preserve usable controls/coordinates and an honest state |
| A3 / TD-103 | Orphan cleanup uses AppLog | Relevant log/cleanup regression and source check |
| A4 / TD-038 | Enable the already planned unawaited_futures rule and resolve actual findings | Analysis; affected async failure-path tests; no unrelated cast/lint campaign |
| A5 / TD-002, TD-020, TD-025 | Recheck only the registered startup/network barrier, site/zone behavior and named historical test gaps | Cite current implementation/tests; close obsolete assertions; fix only a reproduced violation of an established requirement, with a focused regression |

**Verification:** full gate at the end, as required for S16.8/tooling changes. F22 owns TD-102's other half. Preserve all existing tests; no coverage-percentage target or repeated global test-gap audit.

**Completion Evidence:** five-row checklist with files, evidence, classification of surviving non-blocking items and final gate.

**Dependencies / Risk:** affected feature tasks complete; TD-045's harmless Drift rename workaround remains excluded. A confirmed blocker found in A5 receives a localized task amendment, not an open-ended cleanup mandate.

### TASK F25 — Close consistency, accessibility and workflow acceptance

**Problem / Current State:** S16.7, TD-100/101, CA-05/11/12; the prior sweep misses editors/filter panel/map and cannot prove a keyboard-open dialog fits.

**Required Outcome:** the final changed surfaces satisfy the finite U/W contract with one coherent quantity/theme system.

**Implementation Scope:** repair only observed failures in the named surfaces; extend accessibility coverage to all changed screens, editors, filter panel and map picker; enforce QuantityText usage with a bounded source test. Apply no unapproved visual direction.

**Acceptance Criteria:** A1 every changed surface has U evidence including real glyphs and relevant error/keyboard states. A2 no hand-formatted covered quantity bypasses QuantityText; field mode and approved contrast remain correct. A3 all four W journeys have step records, with fit/Unknown/relative-gain explanations and issues classified; comprehension remains separately labeled. A4 owner final visual acceptance is recorded; no unresolved functional/accessibility blocker remains. Later relevant changes invalidate only affected rows.

**Verification:** full gate explicitly required by S16.7; complete affected accessibility/render inventory and W integration walkthroughs. Reuse valid earlier task evidence rather than replaying every row.

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

**Problem / Current State:** S17.6, CA-13, AUD-15; Play-era packaging/size assumptions do not qualify an APK delivered directly from GitHub.

**Required Outcome:** release tooling fails closed on wrong signing/identity/version and produces traceable APKs and install/update instructions.

**Implementation Scope:** existing release scripts/checks, RELEASE.md, version/AppIdentity and CI integration as needed. Verify the expected public certificate fingerprint, not merely absence of debug signing. Owner supplies/manages signing outside the repository; never request/read/commit secrets. Measure universal and arm64 download and installed sizes from the release commit before D6 chooses distribution. Add a stable artifact name, SHA256SUMS, published certificate fingerprint, change/known-issue/data notes, installation/checksum/update and old-id migration instructions.

**Acceptance Criteria:** A1 absent/debug/wrong certificate is refused; selected APKs use `io.github.buffur.culmina`, expected signer, matching pubspec/AppIdentity version, increasing versionCode, required SDK settings and 16 KB native-library alignment. A2 D6 uses actual measured sizes; every selected APK is checked and hashed. A3 final code/tooling/version inputs pass the full gate and actual remote CI on the release commit; native build/Kotlin results are valid for those inputs. A4 commit/toolchain/id/version/certificate/APK SHA-256 and live policy URL are recorded. A5 signature-mismatch instructions require a verified independent backup before any owner-authorized uninstall; no destructive action is automated as a packaging shortcut.

**Verification:** H; release-check rejection/success cases, native build/Kotlin checks, artifact metadata/signature/alignment/hash inspection and remote CI. Public CI needs no private release key; local production-artifact evidence is recorded separately.

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
| S17.6 | CA-13; AUD-15/17 | Implement / Decision Required | F26/D6 | Package before phone; measure before ABI choice |
| S17.5; S11.6 | CA-14/16; C2 | Verify Within Task | G2 | Exact artifact, migration and phone evidence |
| S17.7/8; S11.7 | C1; AUD-15 | Merge | G3/G4 | Go/no-go then authorized publication |

### Audit/review dispositions

| Original ID | Review Finding | Decision | Final Task ID | Reason |
| --- | --- | --- | --- | --- |
| CA-01/16/23; M1; AUD-01; TD-106 | Unsafe activation and unreachable recovery promise | Implement; D2 for optional Undo | F01/G2 | Production validation, coherent restart, truthful instructions |
| CA-02; M2; AUD-04 | Hidden photo rig path / required-input barrier | Implement / Verify Within Task | F03/F05/F16 | Expose existing import; preserve required-input invariant |
| CA-03; M3; AUD-02; TD-107 | Tuple matching and filter identity | Implement | F03/F09 | Whole tuple, normalized comparison, no alias guessing |
| CA-04; AUD-03; TD-108; RA-F05 | Filter loss and exposure leakage | Implement | F06/F08/F10 | Preserve values through manual and imported edits |
| CA-05; M4; AUD-10 | Unjudgeable UX claims | Merge | U/W, F25/G2 | Observable steps separated from human understanding |
| CA-06; M5 | FITS rig mapping missing | Implement | F03/F04/F10/G2 | Already approved RG-03 path, once-only normalization |
| CA-07; M6; AUD-05 | Unread RAW size / storage assumptions | Decision Required, then Implement | D3–D5, F03/F07 | File length is not decoded mode evidence |
| CA-08; M7; AUD-11 | Numeric AstroBin filter IDs and calibration counts | Implement / Verify Within Task | F20 | Blank ID, ordered name annotation, proven calibration match |
| CA-09; M8; AUD-08 | Forecast lead/coverage and dark-span meaning | Implement | F13/F14 | UTC slicing, per-variable coverage, visible lead time |
| CA-10; M9 | Brand tokens/default appearance | Decision Required | D1/F21/F25 | No inferred brand approval |
| CA-11; M10 | Placeholder-glyph review renders | Merge | U/F25 | Real typography evidence |
| CA-12; M11 | Planner/editor density | Merge | U/F06/F18/F25 | Measured growth and reachable controls, no new redesign |
| CA-13; M12; AUD-17 | APK sizes under GitHub delivery | Decision Required | D6/F26 | Measured ABI choice; Play-delivery premise superseded |
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
| UXA-C1 (UX audit C1) | Restore waits indefinitely; its outcome is never shown | Implement; D7 for the activation mode | F01/G2 | Pick-time refusal, a visible pending state, the outcome reported once |
| UXA-C2 (UX audit C2) | A rig created from a missing-rig action is saved, not chosen | Implement; D8 | F05/F16 | Finishing the action gives the plan its rig |
| UXA-C3 (UX audit C3) | Browse versus adopt never designed | Implement; D9 in ADR-022 | F13/F14/F15/F17/F18 | One rule for every night and site control |
| UXA-C4 (UX audit C4) | Rig and block editors discard input on Back or a tap outside | Implement | U/F05/F06/F08 | The site editor's guard (TD-084) for the two longer editors |
| UXA-C5 (UX audit C5) | No labelled next step in the empty Capture Plan once the example action goes | Implement | F09/F18 | The replacement empty state ships with the removal |

**Earlier owner-review coverage remains explicit:** RA-A01/05/07/08/09→U/W/F25; A02/03/F10→F11; A04→F03/04/07/10; A06→F17/18; A10/I01→this consolidation; B01–06→F16; C01/02→completed identity plus optional S12.2; C03/04→F02/F14 and existing AppMotion; D01–06→F17; E01→F13/15; E02–05→F14; E06→F19; F01–03→F18; F04→F09; F05→F06; F06→F05/16; F07→F04/06/08/12; F08→F09; F09→F12; F11→F03's record-only contract; G01–04→F19; G05→G2; H01–03→F21, localization excluded; I02→completed S12.1; I03/04→completed identity/decision plus F23/F26/G4, optional trademark and deferred licence change; I05→execution order/G1. K1/K2 are already closed, K13 remains historical; K3–K12/K14 are covered by these corresponding RA findings.

**Debt accounting:** TD-106→F01; 109→F02; 108→F06; 072→F08; 107→F09; 074→F12; 049→F14; 095→F18; 094 and 102 durability→F22; 097/098/031→F23; 096/102 map/103/038/002/020/025→F24; 100/101→F25; 105→F01. TD-104/088/093 and TD-099's published wording are completed; F14/G1 check the changed forecast implementation against that policy. TD-045 excluded. No unrelated debt-cleanup requirement is created.

## 5. Decisions, exclusions and prerequisites

These choices are **not silently decided by this proposal**. The recommended outcomes minimize expansion and give Claude a concrete path. They can be answered with roadmap approval or at the named local checkpoint; only dependent work waits.

| ID / prior authority | Decision and recommendation | Needed before |
| --- | --- | --- |
| D1 / CA-OD1 | A: retain neutral tokens and System default (**recommended for this completion-only pass**); B: approved navy/ice-blue token treatment with AA vectors; C: B plus Dark default for new installs. Audit 09 recommended B; that recommendation is not approval. Field mode unchanged in every option. | F21 |
| D2 / CA-OD3 | **Recommend no new Undo-last-restore UI**, truthful Back up first recovery, and keep one newest safety copy with deterministic interrupted-activation recovery; agree retention before pruning any copy. Alternative: explicitly approve Undo through the same validated path and choose retention. Core candidate validation must not wait. | Optional F01 recovery UI/retention; reconcile in F03 ADR |
| D3 / CA-07 | **Recommend accepting a recognized-but-unread picked file's length as measured one-frame storage**, with mode unread and variable-content-size warning; never infer image dimensions/compression. Alternative: retain manual-size remedy and explain refusal. | F03 acceptance / F07 |
| D4 / PD-06, CA-06 | **Recommend normalizing known binned geometry once and applying binning to theoretical storage only when native/output mode semantics are evidenced; never rescale measured output.** Ambiguous writer conventions stay Unknown. F03 supplies binned/unbinned vectors before owner acceptance. | F03 contract / F07/F10 |
| D5 / PD-08, C3 | **Recommend persisting per-field origins and the measured block size with format/mode/source association**, additive to legacy snapshots/manifest; legacy origin unrecorded. F03 supplies exact encoding/migration. | F03 schema acceptance |
| D6 / CA-OD2 | Choose universal-only or arm64 primary plus universal **after F26 measures download/installed sizes**. No size or variant decision is invented now. | F26 packaging selection |
| D7 / UXA-C1; TASK 14.4 | **Recommend applying a confirmed restore at once: the confirmation's action restores and restarts the app in-process** (startup already re-runs in-process after the database-recovery screen's reset), so nothing can be edited between confirmation and activation. This changes TASK 14.4's owner decision that a restore is “applied at the next start”. Alternative: keep the next start, correct the instruction (CA-16), and show the pending restore on every tab — changes made now will be replaced — with Restart and Cancel. | F01 activation UI; validation and the outcome report proceed without it |
| D8 / UXA-C2; RD-04 | **Recommend: a rig saved from a plan's missing-rig action (Planner, Tonight) or from onboarding becomes that plan's rig**; the user returns to where they started, with the status updated and a message. It is the user's own action for that plan, so RD-04's rule that nothing the user did not choose is selected still holds. A rig created in the Library is only saved. Alternative: return to the choose list with the new rig highlighted; the user taps it to choose. | F05 (with F16) |
| D9 / UXA-C3; ADR-019 §5 | **Recommend: the Home and Planner context lines (Site ▾ · night ▾) stay the plan's own context and edit it, as today** (ADR-019 §5, UX-11; S6.3's saved-plan rule unchanged), so Home's night card and Your plan always describe the same night. The Moon calendar and the 16-night overview only browse: a browsed night is labelled against the plan's (“Viewing Fri 14 Nov · your plan: Tue 10 Nov”), and one action, “Plan this night”, adopts it. A never-saved plan moves to that night; a saved plan goes through the existing Copy to another night (Save · Discard · Cancel first if it has unsaved changes), so the saved plan and its result stay unchanged. Each ends with the existing `showDone` message; Back without adopting changes nothing. Alternative: Home's subtitle browses too, and the plan's night changes only in the Planner or through “Plan this night”; Home's night card can then describe a night other than Your plan's. | F13's ADR-022 acceptance (then F14, F15, F17, F18) |

The retained ADR-021 and ADR-022 owner acceptances are two **local checkpoints** inside F03/F13, with explicit numbered choices and vectors; ADR-022 also carries D9's interaction item. They do not authorize another global roadmap review. This proposal itself has **no unresolved blocker to being delivered**; execution has the named local decision/resource gates above. FITS sample, phone/manual participation, owner visual review, signing, authorized push and final publication are external prerequisites, not implementation achievements.

**Excluded:** new partial-rig model, specification/catalog expansion, proprietary RAW decoding, absolute SNR or new exposure science, additional weather/seeing provider, hardware control/live tracking, project goals, sky map/framing/mosaic, localization, notifications/updater, speculative architecture cleanup, optional CA-19/20/21, TD-045, RD-02 housekeeping. GPL stays with the recorded additional permission. App-store upload keys/App Signing, AAB requirements, Data Safety/store listing and Play testing remain deferred. Optional trademark work is not promoted to mandatory. No already working science or workflow is removed except the two explicitly approved UI actions, replaced by their named flows.

## 6. Claude handoff and progress accounting

At task start read `PROGRESS.md`'s current state and next action, the named task here, U/W if UI is touched, its accepted ADR/requirement sections, and relevant guardrails. Inspect only the affected code/tests. The task specification is the implementation brief; do not reconstruct audits or create a new task-planning document. Ordinary local engineering planning stays inside the task.

Implement → verify at the cumulative diff's V1 class → check each A-criterion → self-review → update affected records → coherent commit if authorized → advance or stop according to the authorized run. Push/publication require their existing explicit authorization. Present owner reviews as concrete renders or numbered contract choices, not open-ended design sessions. If a genuine unresolved product/data/scientific choice appears, ask only that local question and continue independent authorized work. Accepted behavior is not reopened because a new agent prefers another design.

**After approval:** record its date and decisions in PROGRESS/DECISIONS; make this file the execution queue and the old Stage/task IDs aliases. Keep historical reports intact. Maintain one current task/status table and compact completion rows in PROGRESS; do not paste the entire roadmap there. Record an evidence carry once, then close it at the named gate.

| Accounting item | Proposed baseline |
| --- | --- |
| Remaining stages | **4**: A safety/startup; B Capture Plan; C night/screens/records; D release |
| Mandatory implementation tasks | **26**: F01–F26 (A: 2; B: 10; C: 13; D: 1) |
| Additional acceptance/delivery gates | **4**: G1 pre-packaging; G2 phone/artifact; G3 go/no-go; G4 published download |
| Complete new tasks at proposal time | **0/26**; this consolidation implements nothing |
| Immediate task after approval and start | **F01**, then F02; F03 contract/schema follows |
| Main dependency chains | F03→F04/F05→F06→F07→F08→F09; F10 joins with real sample; F13→F14/F15→F17; F22–F24→F25; G1→F26→G2→G3→G4 |
| Unresolved owner-choice entries | **9**: D1–D9; D4/D5 are technical choices inside ADR-021, not new product research; D7–D9 come from the UX audit (UXA-C1–C3) |
| Global replanning/review prerequisites | **None** |
| Finished | All mandatory task/gate criteria evidenced; no release blocker; tested artifact published/checked; outstanding optional limits explicitly classified |

**One focused consistency pass:** verify original-task/review coverage, approved scope, dependency order, objective criteria, proportional checks and finite closure; correct material omissions once before presenting for approval. After that, stop planning. Future corrections use the local change-control rule, never a standing request to review the whole roadmap again.
