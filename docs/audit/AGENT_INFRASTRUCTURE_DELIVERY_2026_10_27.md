# Selective agent-infrastructure delivery — 2026-10-27

The owner explicitly authorized committing and pushing the cleanup and navigation corrections to `develop`, excluding unrelated work and application source changes. Base: `8ec241cd3e4e57a11d9133c7ec4541d4dbd7801a`; freshly fetched `origin/develop` matched that base before preparation. No pull, rebase, force push, reset, stash, device operation or application edit is part of this delivery.

## Selected package

- Rules,13 refactored skill entrypoints, current documentation routes/register navigation, carried audit backlog, complete triage manifest and cleanup/correction reports.
-75 relocated historical originals,17 pre-refactor snapshots,92 explicitly historical navigation copies,65 compatibility stubs and both restored legacy section anchors.
- An archive-local `.gitattributes` with `-text` only for originals/snapshots. This checkout has `core.autocrlf=true`:25 previously staged moved originals were normalized and did not match their raw-byte receipts. Explicit restaging under the scoped attributes fixes that mismatch. All92 **Git blob** SHA-256 values now match the original preservation receipts; checkout filters cannot silently normalize these protected archive payloads. Navigation copies and active application files receive no new EOL rule.
- PROGRESS contains only this task's cleanup, navigation and delivery receipts over its committed baseline. Its unrelated pre-existing reorganization/content additions remain in the worktree. The complete pre-task local state was preserved outside Git before the cleanup.

## Explicit exclusions

`README.md`, `docs/ARCHITECTURE.md`, `docs/refinement/PROGRESS_HISTORY.md`, `.agents/skills/dart-fix-runtime-errors/SKILL.md` and untracked `docs/refinement/DESIGN_SYSTEM_PATCH_SPEC_2026_10_27.md` are excluded. Their working bytes stay intact. The static-analysis skill is included because this task substantially refactored it; its pre-existing scope safeguards survive, and its pre-refactor original is retained as archival provenance. Archive snapshots may preserve old local text as evidence; that is distinct from adopting unrelated active-file edits.

The4,277-row manifest records the original audited **working-tree** state, including named pre-existing dirty objects. It is not a fingerprint of the selectively published tree. Likewise, earlier instruction-size and local-link counts describe their recorded inputs, not excluded dirty content as if it had been committed.

## Verification of the selected tree

The staged Git tree, not the full dirty checkout, was inspected independently. Every selected/excluded path and all92 archive-blob identities were checked. All maintained Markdown in that tree, including the navigation layer, was scanned for file and section targets against its actual Git blobs. No new missing file target or section was introduced relative to HEAD. Existing historical missing references were not fabricated or silently reclassified. No tracked application, test, platform, asset, executable tooling, dependency/lock or CI/config input is changed; the archive-local attributes are the sole new repository metadata configuration and affect no application path.

Whitespace verification is scoped honestly: active changed documentation has no new whitespace errors. With CRLF recognized for byte-preserved payloads, the full staged check reports48 inherited formatting notices:24 in immutable originals and24 in their navigation copies. Each was traced to the identical preserved source line. They are retained under the original-byte/content-preservation requirement; no formatter was applied to historical evidence and no application check was weakened. Earlier working-tree-only whitespace receipts do not claim that these newly staged archival additions were absent.

No application suite/analyzer/build/device run was required to verify these unchanged application inputs. The archive metadata was checked by its effective Git attributes and exact staged blob identities. Automatic CI is allowed to classify the actual diff normally; neither workflow configuration nor CI triggers are bypassed. Git/remote/CI results for the delivered commit are reported by the final delivery receipt rather than inserting a self-referential commit hash into this file.

## Sources and boundary

[Cleanup](AGENT_INFRASTRUCTURE_CLEANUP_2026_10_27.md), [navigation correction](AGENT_NAVIGATION_FIX_2026_10_27.md), [manifest](../../AUDIT_MANIFEST.md), [archive index](../archive/2026-10-27_cleanup/ARCHIVE_INDEX.md) and [current handoff](../refinement/PROGRESS.md). Original971 unverified native contracts and all unrelated owner/TalkBack/real-file/release criteria retain their exact dispositions. This package grants no further implementation or publication scope.
