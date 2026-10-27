# Agent infrastructure cleanup — 2026-10-27

Completed the owner-authorized repository infrastructure audit, refactor and archive. No application source, business logic, dependency, executable tooling, workflow configuration, device or release changes. No commit or push. Three specialist agents performed read-only reviews; one integrator made all repository changes.

## Scope and baseline

Repository: Culmina, `develop`, HEAD `8ec241cd3e4e57a11d9133c7ec4541d4dbd7801a`. Local tracking comparison was 0 ahead / 0 behind; no remote fetch was performed, so remote freshness is not newly verified. Four worktrees were observed; this pass wrote only the main checkout. Pre-existing dirty paths: two Dart skills, README, ARCHITECTURE, PROGRESS, PROGRESS_HISTORY; untracked DESIGN_SYSTEM_PATCH_SPEC_2026_10_27 was preserved. No other writer's index entries existed at preflight.

Before edits, original bytes, SHA-256 inventory and staged/unstaged patches were saved outside Git in the current Codex task's `work/`. Twelve additional immutable prompt-evidence paths were inventoried during the prompt supplement. No private settings, signing material or personal samples were read. Private `.audit/` evidence was classified by directory/file counts and retained; raw private evidence was not content-audited or published. Global/personal skills and managed/cloud instructions are outside repository mutation scope.

## Accounting

- **4,277 original objects inventoried**, one status each: **4,142 KEEP / ACTIVE**, **28 UPDATE / REFACTOR**, **107 ARCHIVE** (75 newly moved originals and 32 existing archived objects retained). The archive README is an existing index updated in place rather than moved.
- The inventory includes **379 original Markdown files**; 12 supplemental historical prompt-evidence paths were added to the initial inventory. Binary/capture/log assets received retention/provenance classification; this is not a claim that 4,277 files received deep content or behavioral inspection.
- **75 originals moved with `git mv`**, retaining repository-relative structure below `docs/archive/2026-10-27_cleanup/`. **17 pre-refactor snapshots** are preserved separately. All **92 SHA-256 identities match** the pre-edit originals.
- **65 short historical report/critique redirects** remain at old paths to preserve immutable contract/decision references. Ten archived skill files have no active discovery stubs. No substantive original was deleted.
- **28 existing paths updated**, including **13 skill entrypoints**. Five skill directories were archived: Google ADK, native asset setup, ffigen, checks migration and localization setup. Their absent project stack/supporting workflows are documented in the manifest. `skills-lock.json` stays unchanged as upstream acquisition provenance; it is not a current installed-skill census.

The master manifest, backlog, cleanup report and archive index are new navigation/deliverable files, not part of the pre-edit triage denominator. The compact current handoff was inserted into PROGRESS; removing that marked block reconstructs its exact pre-task text. README, ARCHITECTURE, PROGRESS_HISTORY, the runtime-error skill and the untracked design proposal remain byte-identical to their pre-task snapshots. The static-analysis skill preserves its prior scope safeguards and its full pre-task original in the archive.

## Rules, skills and prompts changed

Guardrails retain every numbered trap 1–22 and the migration, snapshot, autosave, backup, scientific, lifecycle, privacy and signing invariants. Corrected source-backed facts: schema27 / nullable plan overrides; implemented F19 early reporting and consented F23 draft-name proposal; CI orchestration through `tool/ci.py`; Geist in the equipment fit fixture. Historical machine paths, copied schema chronology, obsolete implementation status and duplicate governance clauses were removed from current guidance.

The two supplemental rule routers now defer shared governance to AGENTS. AI_WORKFLOW retains operational procedures and removes repeated scope clauses. BASELINE routes the later Wave1–4 / UIA-0010 fixed 96-dp time-column delivery, with original native audit and acceptance boundaries preserved. FEATURE_STATUS and SCIENTIFIC_INTEGRITY no longer call the accepted roadmap proposed; TECH_DEBT no longer presents its mixed historical index as a verified open-item count.

Thirteen skill rewrites route actual source/configuration and existing test fakes instead of nonexistent scaffold paths, unconditional package installs, manual lockfile edits or a parallel architecture. Optional examples remain labelled and referenced on demand; frontmatter names and upstream metadata fields are retained while discovery descriptions are narrowed. Shared verification remains in VERIFICATION_POLICY. Integration tests preserve the existing production-main/no-Driver correction and actual host/driver routes. Reusable prompts no longer require an unconditional commit, auto-start the next Stage or treat a commit-only diff as proof that dirty/untracked inputs are unchanged.

Bounded independent review caught and corrected one overbroad catch-policy phrase and one encoding artifact before final verification. The reports did not expand the acceptance surface or change source behavior.

## Context reduction

Measured pool: root AGENTS/CLAUDE/GEMINI adapters, supplemental rule files, skill SKILL.md entrypoints, AI_WORKFLOW, VERIFICATION_POLICY, ENGINEERING_GUARDRAILS and design/BASELINE. Removed entrypoints count as zero in the active pool; immutable snapshots and supporting references do not. Measurements compare the preserved dirty pre-task state with final files.

| Metric | Before | After | Reduction |
| --- | ---: | ---: | ---: |
| Physical lines | 5,164 | 1,619 | 3,545 / 68.65% |
| Whitespace-delimited words | 38,404 | 17,828 | 20,576 / 53.58% |
| UTF-8 bytes | 306,972 | 143,861 | 163,111 / 53.14% |

Root startup adapters are byte-identical. These are reductions in on-demand instruction-file content, not measured runtime prompt/token savings. Guardrails grew in physical line count because long paragraphs were separated; word/byte metrics avoid presenting line count as a token proxy.

## Verification and limits

- All92 moved/snapshot byte identities verified; no substance deletion or original archival rewrite.
- All26 remaining skills pass the supplied skill-creator `quick_validate.py`, with names/frontmatter parsed using PyYAML isolated in the task's scratch directory. The first attempt lacked PyYAML; it was resolved without changing project dependencies. Additional checks confirm skill entrypoints are below200 lines and all trap IDs remain stable. Runtime invocation/client loading and new behavioral skill probes were not exercised.
- Active Markdown file-target scan finds **zero newly broken targets**. Old-path redirects resolve moved historical originals. No active rule/skill operational dependency on archived skill recipes remains. Existing provenance links to archives are historical navigation, not execution requirements.
- `git diff --check` and `git diff --cached --check` pass. Tracked application/test/platform/assets/tool/config/dependency inputs have no diff from HEAD. `git mv` stages archival renames; updated files, snapshots and compatibility redirects remain reviewable in the worktree. No staging or commit of pre-existing dirty owner files occurred.
- Required verification is documentation/reference/hash integrity. The three critique Markdown relocations lie outside V1's enumerated Markdown directories, but contain no executable input: move integrity was checked directly; no application test or runtime result is claimed. No full application test/analyzer/build/device/CI run was needed to validate this infrastructure-only diff.
- Original archive Markdown is byte-preserved and keeps relative references in its original source coordinates. Use its old-path redirect or ARCHIVE_INDEX mapping when following those historical references; archived documents are not standalone rewritten publications.
- **23 pre-existing missing local file targets** remain as honest historical evidence gaps:20 rig/target comparison captures/logs and3 retired Weather source/test links. They predate cleanup and were not caused by moves. Originals and frozen evidence were not rewritten, and unavailable proof was not invented. Details follow.

| Historical source | Missing target |
| --- | --- |
| `docs/design/migration/VISUAL_COMPARISON_AUDIT.md` | `evidence/rig-editor-375-before.png` |
| `docs/design/migration/VISUAL_COMPARISON_AUDIT.md` | `evidence/rig-editor-375-after.png` |
| `docs/design/migration/VISUAL_COMPARISON_AUDIT.md` | `evidence/rig-editor-375-android.png` |
| `docs/design/migration/VISUAL_COMPARISON_AUDIT.md` | `evidence/rig-editor-375-tests.log` |
| `docs/design/migration/VISUAL_COMPARISON_AUDIT.md` | `evidence/rig-editor-cycle2-regression.log` |
| `docs/design/migration/VISUAL_COMPARISON_AUDIT.md` | `evidence/rig-model-200-before.png` |
| `docs/design/migration/VISUAL_COMPARISON_AUDIT.md` | `evidence/rig-model-200-after.png` |
| `docs/design/migration/VISUAL_COMPARISON_AUDIT.md` | `evidence/rig-model-200-android.png` |
| `docs/design/migration/VISUAL_COMPARISON_AUDIT.md` | `evidence/rig-editor-cycle2-tests.log` |
| `docs/design/migration/VISUAL_COMPARISON_AUDIT.md` | `evidence/target-editor-100-before.png` |
| `docs/design/migration/VISUAL_COMPARISON_AUDIT.md` | `evidence/target-editor-100-after.png` |
| `docs/design/migration/VISUAL_COMPARISON_AUDIT.md` | `evidence/target-editor-100-android.png` |
| `docs/design/migration/VISUAL_COMPARISON_AUDIT.md` | `evidence/target-editor-100-keyboard.png` |
| `docs/design/migration/VISUAL_COMPARISON_AUDIT.md` | `evidence/target-editor-100-tests.log` |
| `docs/design/migration/VISUAL_COMPARISON_AUDIT.md` | `evidence/target-editor-100-cycle2-phone.png` |
| `docs/design/migration/VISUAL_COMPARISON_AUDIT.md` | `evidence/target-editor-100-cycle2-keyboard.png` |
| `docs/design/migration/VISUAL_COMPARISON_AUDIT.md` | `evidence/target-editor-100-cycle2-light.png` |
| `docs/design/migration/VISUAL_COMPARISON_AUDIT.md` | `evidence/target-editor-100-cycle2-tests.log` |
| `docs/design/migration/VISUAL_COMPARISON_AUDIT.md` | `evidence/target-editor-100-full-width-phone.png` |
| `docs/design/migration/VISUAL_COMPARISON_AUDIT.md` | `evidence/target-editor-100-full-width-tests.log` |
| `docs/refinement/DEVELOP_IMPLEMENTATION_REVIEW_2026_10_19.md` | `../../lib/presentation/widgets/weather_forecast_widget.dart` |
| `docs/refinement/evidence/finalization/develop_review_20261019/CRITERION_MATRIX.md` | `../../../../../test/presentation/widgets/weather_forecast_widget_test.dart` |
| `docs/refinement/evidence/finalization/develop_review_20261019/CRITERION_MATRIX.md` | `../../../../../test/presentation/widgets/weather_forecast_widget_test.dart` |

## Carried findings and boundary

BACKLOG_FROM_AUDITS preserves R1–R4 reproduction routes, PBR-01 behavioral uncertainty, RV-01 and browser verification follow-ups, historical missing evidence, exact TD/SI partial remainders, RD/RG housekeeping and native/human/release criteria. WQA-01–06 and earlier R1–R5 browser critiques retain their recorded DONE/implemented dispositions. This cleanup does not reopen those as defects.

All18 native correction findings are separately delivered; original971 unverified contracts remain unverified. W1/VQA-029 and C1 stay deferred. Owner visual, physical200%/TalkBack, private real-file, signing and release gates retain their named requirements. No backlog repair or design adoption starts automatically. Next action is the owner's next explicit task.

## Navigation

- [Complete triage manifest](../../AUDIT_MANIFEST.md)
- [Archive identities and successor map](../archive/2026-10-27_cleanup/ARCHIVE_INDEX.md)
- [Consolidated carried findings](../BACKLOG_FROM_AUDITS.md)
- [Current handoff](../refinement/PROGRESS.md)
