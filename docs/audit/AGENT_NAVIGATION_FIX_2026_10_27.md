# Archive navigation correction — 2026-10-27

Status: **COMPLETE** for the owner's bounded navigation-only correction. REV-01 and REV-02 from the cleanup verification are resolved in the maintained browsing routes. No application source, dependency, executable tooling, workflow/configuration, device, commit or push change.

## What changed

- Restored `android-format-correction` at the existing Plan-review stub. Its section link opens the matching section in the historical navigation copy; the immutable original remains separately available.
- Restored `reading-route-examples-before-and-after` in the active skill README as a compact compatibility anchor pointing to the preserved snapshot section. PROGRESS_HISTORY remains byte-identical.
- Added **92 explicitly historical navigation copies** under `docs/archive/2026-10-27_cleanup/navigation/`: one per moved original/pre-refactor snapshot. Each carries its original logical path, SHA-256, immutable-original link and navigation-index link. These are browsing documents, not active skills/rules or newly adopted designs.
- Rebased **229 relative link destinations** from each original source directory. Links between relocated documents open navigation copies; retained evidence/source links resolve to actual repository paths. All **189 broken archive-link occurrences** identified by the review now resolve through the browsing layer.
- Updated all **65 compatibility stubs** and the archive index to offer navigation copies as the reading route, while keeping explicit immutable-original links. Added [NAVIGATION](../archive/2026-10-27_cleanup/NAVIGATION.md) as the browse/original map.
- Corrected one pre-existing internal contents-link typo in the CLI skill snapshot's **navigation copy only**: `#2-streams-diagnostics--formatting` now targets its actual preserved `Output` heading. Original wording and original bytes remain unchanged.

## Verification

- **92/92 original/snapshot SHA-256 identities match** the cleanup receipts. No immutable archived file was written.
- Both legacy incoming links now resolve to restored anchors and onward to the exact preserved section. The immutable LAB_HISTORY and PROGRESS_HISTORY sources remain unchanged.
- All189 review-listed archive-link occurrences map to existing targets in the navigation copies. The original archive Markdown intentionally retains historical relative URLs; the new browse links are the corrected route. Raw originals are provided for provenance and hash verification.
- Every navigation copy was compared to its immutable original after masking link destinations and removing its provenance banner: **zero other content differences**. This includes code samples and historical acceptance wording; no missing evidence was invented.
- Full maintained-document scan, including navigation copies, found **zero newly missing file targets and zero missing Markdown section fragments**. All92 navigation copies have zero missing file/section targets. The23 previously documented active-file missing-target occurrences remain unchanged and are outside this correction.
- Both staged and unstaged `git diff --check` pass. The existing staged index is byte-identical to its pre-correction listing. Git HEAD remains `8ec241cd3e4e57a11d9133c7ec4541d4dbd7801a`; previous cleanup renames remain staged. No commit, push or extra staging occurred.
- Tracked application/test/platform/assets/tool/dependency/lock/workflow/config inputs remain unchanged from HEAD. Relevant existing owner work and pre-correction PROGRESS text are preserved. New navigation copies retain their source formatting; they are not new executable inputs.

Only Markdown documentation/navigation changed. Under [V1/V5](../VERIFICATION_POLICY.md), verification was limited to the two findings, affected file/fragment links, original hashes, content preservation and whitespace. Application tests/analyzer/build/device runs were not required or performed. Link resolution was checked locally; no live external-URL availability claim is made.

## Current routes and boundary

[Archive index](../archive/2026-10-27_cleanup/ARCHIVE_INDEX.md) → [navigation map](../archive/2026-10-27_cleanup/NAVIGATION.md) → historical browsing copy → original hash-bound file where needed. Existing contract/decision references remain valid through compatibility anchors/stubs.

The [initial cleanup report](AGENT_INFRASTRUCTURE_CLEANUP_2026_10_27.md) and external recheck report retain their dated results; this is the later correction receipt. [PROGRESS](../refinement/PROGRESS.md) records current state; [BACKLOG_FROM_AUDITS](../BACKLOG_FROM_AUDITS.md) keeps unrelated carried criteria and unavailable historical evidence. No backlog repair, source change, owner acceptance or release gate is implied.
