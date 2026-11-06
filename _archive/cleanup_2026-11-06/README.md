# Repository cleanup вЂ” 2026-11-06

This is preserved cleanup evidence, not an active instruction source. No file was permanently deleted. No commit or staging was performed.

`manifest.json` maps every relocated log/export/script to its original repository-relative path, byte size, SHA-256 and retention decision; `document-moves-manifest.json` records the three moved documents. These manifests are authoritative for moved files. `inventory.json` is a dated inventory with explicitly excluded runtime/cache trees, not the current post-move filesystem. Archived binary/log payloads and large machine inventories remain local through `.gitignore`.

| Area | Result |
| --- | --- |
| Rules | Removed duplicate index routing from `AGENTS.md`; compacted completed history in `design/figma/WORKFLOW.md` and `design/figma/REDESIGN_RUN.md`. Preserved current owners, heading targets, pending criteria and historical IDs. Clarified that historical Figma-only authorizations do not revoke separately authorized Flutter work and that completed waves are not an active task. |
| Documents | Moved the completed documentation-compaction receipt to `docs/docs/` and two superseded, unreferenced icon/timeline research reports to `docs/design/figma/research/`: three documents, 20,596 bytes / 129 lines. The old Eye/Field/check and unselected timeline proposals do not override current owners. Canonical binding matrices and the stable queue remain active. Preserved pre-edit workflow/run records under `docs/design/figma/`. |
| Artifacts | Moved 584 historical diagnostic/export/script files, 11,976,284 bytes, under `logs/`, preserving original relative structure. All SHA-256 values were verified after relocation. |
| Code/assets | Retained all files after import/asset and conservative transitive-reachability review. Preview entries, reference renderers, branding, license and font provenance records are developer evidence. |
| Dependencies | Retained all 22 direct declarations, including lint configuration and generation tools. `pubspec.yaml` and `pubspec.lock` were unchanged by this cleanup. |
| Configuration | Excluded `_archive/**` from analysis; ignored local archived payloads; refreshed two disabled skill paths in local `.codex/config.toml` to their installed version. No settings reload or discovery result is claimed. |

`summary.json` records counts and verification results. Supporting audits describe scope, decisions and limitations. Archived original Markdown keeps its original bytes and relative links; resolve those links from its original repository location. Use `manifest.json` when an old evidence path has moved. The archived `docs/AGENTS.md` is explicitly a reconstructed LF pre-compaction copy, not a byte-identical initial snapshot.

Moving files on the same filesystem frees **zero disk bytes**. The counts describe removal from active paths; preserved originals and audit evidence add storage. Runtime caches, generated code, database schemas/migrations, native Android configuration and active tests were not edited or relocated by this cleanup. Other chats changed application source and tests; their changes are not attributed to this cleanup.

Final local verification passed: dependency resolution with unchanged declarations/lockfile, zero-issue analysis, the complete Flutter host suite (3,835 passed / 7 skipped), instruction/contract validation and nine instruction tests. During the passing host run, only two Android integration fixtures and their new isolated-sandbox helper changed; no existing host-test or application source changed. The helper has only integration imports. Analysis and all four clock-invariant tests were rerun afterward, followed by a zero-drift comparison of 824 static inputs. Exact scopes, earlier failures and receipts are recorded in `summary.json` and the local `logs/`; this is not independent device or live-Figma acceptance.

## Completed reference-search and instruction follow-up

The remaining build-script search is complete: 34,178 unique text/script inputs read with zero unresolved read errors, including 1,159 build scripts, 93 archived scripts and a supplemental recipe/input pass. Explicit vendor/runtime/binary exclusions and conservative decisions for dynamic or external consumers are recorded in [build-reference-audit.md](build-reference-audit.md) and [build-retention-list.md](build-retention-list.md). Ten additional superseded render-smoke files were moved and hashed; combined move manifests now cover 587 files / 11,996,880 bytes. No files were permanently deleted.

The [official-guidance assessment](agent-instructions-review.md) evaluates shared instructions, progressive skill loading and client discovery. Four source-description owners were corrected after the [consistency review](instruction-source-consistency.md), with exact before versions in instruction-followup-before-manifest.json. Project constraints, native client configuration and external policy choices were preserved. Fresh instruction/skill/contract checks pass; no Flutter runtime code or tests changed in this follow-up, and earlier Flutter receipts are not reclassified as new app verification.
