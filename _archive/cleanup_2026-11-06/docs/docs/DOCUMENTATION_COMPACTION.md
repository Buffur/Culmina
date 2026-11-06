# Documentation compaction — 2026-11-04

Baseline: `develop`, `96362287b3ce15559b3af3b3ec8e00cb9c3b134d`, including pre-existing Figma documentation/tooling changes and untracked research. This task changes documentation only; no commit or push was requested.

## Results

- [DONE] Inventoried 1,036 Markdown files, including 933 ignored archive documents and 15 private audit reports; scanned 2,674 text/log candidates separately from instructions (files: local `build/doc-compaction-20261104/baseline.json`, `log-inventory.json`).
- [DONE] Replaced repeated skill routing with the existing skill index; all active skill/reference bytes remain unchanged (files: `../AGENTS.md`, `../.agents/skills/README.md`).
- [DONE] Condensed dated planning/tooling/release narratives and Figma milestones; preserved accepted design decisions, F01 limits and pending F02/native criteria (files: `PLANNING_CONTEXT_2026-10-30.md`, `AGENT_TOOLING.md`, `RELEASE.md`, `../design/figma/WORKFLOW.md`, `../design/figma/qa_checklist.md`).
- [DONE] Consolidated 80 exact archive duplicates and retired 69 superseded instruction snapshots; these sets overlap, and original headings/explicit anchors remain as navigation targets (files: local `duplicates.json`, `retired-instructions.json` under `build/doc-compaction-20261104/`).
- [DONE] Condensed completed progress/stage history while retaining carried criteria and traceability; historical product-roadmap F01–F26 IDs remain distinct from Figma F01/F02 (files: local `archive/PROGRESS.md`, `archive/PROGRESS_HISTORY.md`, `archive/POST_ROADMAP_PLAN_HISTORY.md`).
- [DONE] Repaired stale active comparison-tool routing and all file links in changed archive documents (files: `../tool/design/comparison/README.md`, local archive routing files).

Existing modified documents: **149 files, 44,030 → 7,275 lines (−83.5%); 3,050,279 → 393,366 UTF-8 bytes (−87.1%)**. This is text-size reduction, not a measured model-token count. Seven tracked files changed in this task; the other changes are in the ignored local archive. Across the original Markdown inventory, line count fell from 352,420 to 315,665; this new receipt is additional.

## Preserved boundaries

Current source checks confirmed package `astroplan`, Dart `^3.13.3`, database schema 27, application ID and conditional release signing. Recent commits confirm removed dead UI classes, restored schema snapshots, F01 closure and later public documentation changes. Source/test ownership stays in [AGENTS](../AGENTS.md), [Architecture](ARCHITECTURE.md), [Product](PRODUCT_SPEC.md) and the current contracts.

Unique DECISIONS, TECH_DEBT, SCIENTIFIC_INTEGRITY and MANDATORY_STATES archive records remain byte-identical. Other unique specifications, unverified QA matrices, raw logs/transcripts, licenses, captures, manifests and source evidence were retained; they were not relabeled complete or reduced as expendable prose. Historical checksum receipts still describe original bytes; replacement archive navigation is identified in the archive index.

Recovery: local `build/doc-compaction-20261104/before.zip` contains all original Markdown bytes; `baseline.json` records hashes/counts; `git-before.patch` preserves pre-existing tracked edits. These ignored artifacts and archive changes are not part of Git delivery. The pre-existing `validate_contract.py` diff is unchanged.

## Verification

Contract validation passed: 15 modules, 94 tokens, 24 component contracts, 240 local links and 14 external evidence paths. Instruction validation passed: 27 skills / 49 Markdown files; all nine instruction tests passed. An additional file-target check covered 666 links across non-archive Markdown and changed archive documents with zero missing targets. `git diff --check` passed. No Flutter/device tests, remote URL checks or fresh Figma acceptance were performed by this documentation task.
