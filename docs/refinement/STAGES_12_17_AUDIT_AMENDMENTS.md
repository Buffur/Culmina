# Stages 12–17 — independent audit integration

> **Date:** 2026-10-17. **Application baseline:** 570581e.
> **Authority:** the owner asked to incorporate the independent audit into the roadmap, with the explicit constraint: «Важно, что мы не должны придумывать что-то новое, мы доводим до ума существующие функции» (“Do not invent something new; finish and polish the existing functions”).
> **Change class:** documentation/governance only. No application implementation, new feature, Stage or Task, commit or push is part of this change.
> **Active plan:** [POST_ROADMAP_PLAN.md, Stages 12–17](POST_ROADMAP_PLAN.md#stages-1217--culmina-release-roadmap-rap-2026-10-17). C1–C6 and all 42 Task IDs are retained.

## Scope and source

The independent audit reviewed the actual code, existing decisions/research and all 42 Tasks. Its complete English report is the local owner-visible artifact named CULMINA_INDEPENDENT_AUDIT.md in the audit output directory for chat 01a14998-48f7-7fd2-aae9-1a94b6169a3b. This document preserves the actionable evidence and dispositions in the repository; the local artifact is not a portable repository dependency.

The audit's final baseline was 570581e. It recorded 518 existing targeted tests plus 9 identity/startup tests passing, four external observation probes, eight host renders and remote CI run [39042823307](https://github.com/Buffur/Culmina/actions/runs/39042823307). Those are dated audit evidence, not new test results from this documentation change. Host renders do not certify phone behaviour or usability.

The application already has the planning engine, Capture Plan, calibration advice, metadata import, site/target/equipment management, Logbook, backup and export. The amendments correct defects and finish the interactions/contracts already assigned to Stages 12–17. Previously approved FITS, WB records, forecast overview, Moon calendar, AstroBin CSV and appearance/units remain in their existing Tasks; they are not new proposals from this audit.

No new provider, speculative equipment-spec database, second parser, second plan store, camera/controller function, physical SNR model, distribution channel, or extra research phase is added. Required-field usability is assessed in the existing rig editor. The audit's proposed partial-rig mode/nullable equipment contract is **not approved by this integration**; an actual change to the earlier required-input invariant needs the already scheduled ADR-021 owner decision.

## Finding disposition

“Applied” below means assigned/clarified in the plan. It does not mean the application defect has been fixed or an acceptance test has passed.

| ID | Evidence level / issue | Existing Task placement | Disposition |
| --- | --- | --- | --- |
| AUD-01 / TD-106 | Reproduced: invalid SQLite is accepted and activated during restore | S14.3; S17.5 | Applied: validate the candidate before changing DB/preferences, preserve originals, test failed/interrupted activation |
| AUD-02 / TD-107 | Reproduced flat tuple-warning inconsistency; permissive unknown match is not proof of CAL-1 coverage | S14.1; S14.10 | Applied: correlated filter/binning checks, distinct coverage rule, preview/Undo and budget regression |
| AUD-03 / TD-108 | Reproduced: unchanged custom filter becomes null | S14.6; S14.5/S14.9 integration | Applied: preserve every domain-valid filter through existing editor/import/snapshot flows |
| AUD-04 | Code-confirmed required-spec barrier; proposed partial-rig model is a product/model change | S14.1/S14.2; S16.1 | Partially applied: review required/derived inputs and honest missing-data guidance in existing flows. No separate mode or nullable-rig migration is approved. Record any remaining barrier; changing ADR-011 needs explicit ADR-021 acceptance |
| AUD-05 | Existing rig-level size is coarse; future evidence needs a mode/layout scope | S14.1/S14.3/S14.4/S14.7/S14.9 | Applied: measured versus theoretical payload, binning once, mode conflict/invalidation, unsupported stays Unknown |
| AUD-06 | Existing shared metadata type cannot yet carry several already approved FITS fields | S14.1/S14.4/S14.5/S14.6/S14.9 | Applied: common typed contract before reader/UI, source/conflict states and round trips; extraction does not automatically create a control |
| AUD-07 / SI-015 | Code-confirmed inconsistent Moon-up definitions, already planned | S15.1/S15.2/S15.3/S15.6 | Clarified: coordinate-frame equivalence, one semantic predicate, boundary/polar/batch checks |
| AUD-08 | Existing sunset–sunrise summary differs from planned dark span; horizon/variable coverage risk | S15.1/S15.4/S15.5 | Clarified: CALC-32 amendment, actual UTC coverage, cache identity/races, no invented clear/zero values |
| AUD-09 | Future calendar/Home browsing versus plan-edit semantics are not frozen | S15.6; S16.2/S16.3/S16.4 | Applied as an existing-lifecycle contract: browsing does not silently edit a saved plan; explicit adoption uses existing protections |
| AUD-10 | Render review cannot establish comprehension/completion | Shared UI rule; S16.1–S16.4/S16.7; S17.5 | Applied: four bounded existing-workflow observations. No new research cycle or mandatory independent-participant gate; unavailable evidence stays UNVERIFIED |
| AUD-11 | Acquisition CSV needs explicit snapshot/result/status/date/count sources | S16.5 | Clarified: receiving-contract mapping and representative fixtures, no invented acquisition or unapproved export mode |
| AUD-12 | BackupPreferences currently carries bool/int/double, not arbitrary string enums | S16.6 | Clarified: serialize preference values, round-trip old/new defaults; canonical scientific units and correct difference conversion |
| AUD-13 | S16.8 can invalidate S16.7's final sweep | S16.8 → S16.7 | Applied: existing follow-ups have a finite checklist; final sweep follows the UI/router/notices work |
| AUD-14 / TD-105 | Operational summary and S13 briefs lag behind completed identity work/held splash decision | Current records; S13.3; S16.8 | Documentation corrected. TD-105 assigned to existing follow-up Task; pending device rows remain open |
| AUD-15 | Native/release evidence must identify one checked APK and expected signer | S17.2; S17.6 → S17.5 → S17.8 | Clarified: native checks, expected public certificate fingerprint, SHA-256 and fail-closed packaging; owner key remains private |
| AUD-16 | Existing relative-curve groups key filter/exposure; comparability of other settings needs wording | S14.1/S14.11 | Clarified within O2b: split known incompatible settings or explicitly label idealization; no physical SNR |
| AUD-17 | Optional ABI-specific downloads | Existing S17.6 optional clause only | No new work: universal APK remains default, splits only if the owner asks |

## Reproduced defects: concrete evidence

### TD-106 — invalid restore activation (P0)

- Sources: [BackupArchive.read](../../lib/data/backup/backup_archive.dart), especially the SQLite magic/user_version check; [BackupStaging.apply](../../lib/data/backup/backup_staging.dart); [FileBackupService](../../lib/data/backup/file_backup_service.dart).
- Probe: create a genuine v25 SQLite database in an isolated temporary directory; truncate it to its first 100 bytes; build a valid ZIP using the production archive builder; read, stage and apply it.
- Observation: archive validation succeeds; the damaged file becomes live; a session_logs read fails. The original safety copy survives. This demonstrates failed restoration/data availability, **not proven irreversible loss**.
- Existing test gap: header-only synthetic SQLite fixtures test archive/version handling without establishing that the restored database can open and serve the application's tables.
- Acceptance in S14.3: production-path validation of an isolated candidate before live DB/preferences replacement, integrity/expected schema/domain reads, applicable foreign-key checks, unchanged originals on refusal, recoverable interrupted activation and a successful old-schema path. S17.5 rehearses the final identity/schema combination before owner data.

### TD-107 — flat warning loses tuple correlation (P1)

- Source: [CalibrationMatch](../../lib/domain/services/calibration_match.dart), matches(), of() and lightFiltersWithoutFlats().
- Probe: lights Ha/bin1 and OIII/bin2; a flat Ha/bin2.
- Observation: matches() finds no matching light, but of() reports no mismatch because it finds filter and binning independently.
- Related limit: unknown sensitivity intentionally does not produce a conflict warning. That existing advisory policy is not itself reclassified as a defect, and must not prove duplicate coverage for CAL-1.
- Acceptance in S14.10: whole-tuple consistency, compatible flat requirements by filter/binning, separate proven-coverage rule, unknown/known sensitivity cases, existing policies, preview/cancel/Undo and unchanged time/integration semantics. No expanded calibration-library subsystem.

### TD-108 — unchanged custom filter is lost (P1)

- Sources: [CaptureBlock](../../lib/domain/models/capture_block.dart) permits a trimmed filter name up to 32 characters; [CaptureBlockDialog](../../lib/presentation/widgets/capture_plan/capture_block_dialog.dart) changes unlisted initial filters to None.
- Probe: open a block whose filter is L-eXtreme and press Save without changes.
- Observation: returned filterName is null. The ordinary fixed picker does not currently create custom names; affected inputs are valid legacy/domain-provided values and future already approved FITS imports.
- Acceptance in S14.6: preserve valid existing/custom text through unchanged edits, type switches and accepted imported proposals; validate the current domain limit; cancellation changes nothing; test save/reopen/snapshot/export grouping. No new filter catalog is added.

## Implementation order and evidence

- The existing schema/metadata work uses the completed ADR-021 contract: S14.1 → data/common types → FITS/recorded origins → storage/WB → photo proposals. S14.9 still depends on S14.7/S14.8 under C3.
- Stage 15 freezes the correct Moon coordinate-frame predicate and CALC-32/forecast semantics before the matching implementation.
- Within Stage 16, S16.1–S16.6 → **S16.8 → S16.7**. IDs are unchanged; finishing existing router/notices/UI fixes before the final sweep prevents avoidable invalidation.
- Stage 17 remains **S17.1 → S17.2/S17.3/S17.4 → S17.6 → S17.5 → S17.7 → S17.8**. C1/C2 remain binding.
- Prior passed work is not re-reviewed against newly invented criteria. Relevant future Task criteria are amended prospectively under the owner's current instruction; V3/V5 govern evidence reuse.
- Current identity facts: R3-final is approved; Google-based location stays; S12.3/S13.2 completion is recorded; Android 12+ splash holds the approved second. Earlier non-held first-frame measurements do not establish unchanged time to visible content.
- Pre-12/reduced-motion device rows are still UNVERIFIED in S13.3 evidence. They are retained for Stage 13 reconciliation and, where still pending, named final matrix/phone checks. This document does not close them or assert a Stage validation that did not occur.

## Verification of this integration

Only Markdown documents were changed. Required verification is reference/ID consistency, all 42 Task IDs retained, an acyclic explicit dependency graph, complete AUD-01–AUD-17 dispositions, preserved owner decisions/C1–C6, and git diff --check. No app tests, analyzer, build, device runs or full gate are required or claimed for this documentation change (CLAUDE.md V1/V3).

**Result:** all 42 unique Task IDs retained, no dependency cycle, all AUD-01–AUD-17 dispositions present, TD-106/107/108 defined once, 26 added/local references checked with no broken target, and git diff --check PASS. HEAD remains 570581e; the pre-existing CLAUDE.md and macOS registrant contents are unchanged. No commit or push was made.
