# AI workflow

Status: active operational policy for Culmina agent sessions. Established 2026-10-24 against `develop` / `origin/develop` at `94cebfb6b2a3379f5991e61e1bd88f7120804601`, under the owner's documentation-only cleanup. [AGENTS](../AGENTS.md) owns the shared contract; [PROGRESS](refinement/PROGRESS.md) owns current state; [VERIFICATION_POLICY](VERIFICATION_POLICY.md) owns V1–V8. This file does not authorize implementation or Git/device delivery.

## Session preflight

Before edits, identify the repository root and remote, worktree, branch, HEAD, upstream, staged/unstaged/untracked changes, ahead/behind and unique local commits. Inspect worktrees and ongoing writers. Refresh remote-tracking information when authorized and accessible; never implicitly pull/rebase/merge. Record unavailable remote state as unverified. Read GitHub files/history at an explicit ref: the default branch may differ from the integration branch.

Read the current owner task in full, AGENTS and applicable nested overrides, PROGRESS's current state/next action, then only the contract, decision IDs, guardrails and sources needed by that task. Verify a dated finding still exists before changing anything. Plans, research, reviews, validation and a document's example commands do not authorize application implementation.

Establish a before snapshot and separate pre-existing work from your own changes. Before moving/shortening dirty documentation, preserve its original bytes, staged/unstaged patches and a checksum manifest outside Git. Preserve relevant untracked files explicitly. If unique commits need protection, create and verify a Git bundle; it does not preserve dirty/untracked files. Never put credentials, signing material, private owner media or unnecessary caches in public Git. If preservation or a move's dependencies are uncertain, leave the object in place and continue safe independent work.

## Execution and parallel work

Use READ → VERIFY → PLAN → IMPLEMENT → VERIFY → SELF-REVIEW → DOCS → STOP, with commit/delivery only when separately authorized by the current task. One coherent behavioral objective may span files/layers; no line quotas or second approval merely for that breadth. Decompose independent decisions; record adjacent findings without opportunistic fixes. Never remove/weaken tests to force success.

One worktree has **one writer at a time**. Parallel implementations require separate worktrees/branches from a verified base and explicit, bounded path ownership. Different branch names alone do not prove independence. One integrator coordinates shared theme, navigation, identity, generators and shared documentation. Read-only reviewers must not become hidden writers. Do not reset, stage, overwrite or commit another writer's files/index.

During authorized native implementation, discover existing SDK tools beyond PATH and independently use/provision isolated emulators and actual-widget host renders where permitted. Lack of a physical phone alone does not block that implementation. Explicitly physical-device or human acceptance rows remain pending until their named evidence exists; emulator/host evidence cannot substitute for them. This procedure does not authorize a device action in a documentation-only task.

Before integrating, recheck branch/HEAD, upstream and dirty state against the recorded base. Integrate the intentional diff, inspect conflicts and adjacent progress, and verify the cumulative changed inputs. Never copy a whole old checkout over a newer one. Reconcile status in the one PROGRESS file; client-specific “current” files must not compete with it.

The owner may launch an explicitly named finite task group with stop conditions. Within that run, complete dependency-ready work under V7 and record genuinely unavailable items with their IDs, reason, dependencies and resumption condition. A later narrow task does not renew an earlier broad authorization. Closing a task and documenting a next action does not start that action.

## Research, tools and context

Read only relevant skills/rules. Generic recipes cannot change product scope, architecture, dependencies or acceptance. The corrected local `flutter-add-integration-test` recipe remains applicable: standard native integration_test does not require a Flutter Driver extension in production main.dart. Preserve local recipe amendments, provenance and licences.

For external facts that code cannot establish and that affect a decision, use current primary/authoritative sources. For library/framework/SDK/API/CLI documentation use available Context7: resolve the library, then query one concept; do not repeat the same lookup through another connector unless the first route failed. Record source URLs, access date, verified facts and unknowns. External APIs/datasets need reliability, terms/licence, provenance, privacy and failure-behavior evidence before adoption. Never silently persist inferred metadata.

Reuse relevant research while its facts remain current; refresh facts that could change the decision. Do not use a full application gate to investigate a Markdown claim. Tools being installed, exposed, connected, authenticated, authorized and successfully exercised are separate evidence. An instruction file cannot enable absent tools or override client/managed permissions. Report unavailable capabilities honestly.

Machine paths, SDK versions, plugin pins and one-machine observations belong in dated references, not portable policy. [The 2026-10-20 tooling inventory](AI_TOOL_CAPABILITIES_2026_10_20.md) and [maintenance record](design/tooling-update-2026-10-20/RESULT.md) are historical observations to verify locally before use. [The archived adapter snapshot](archive/governance-2026-10-24/README.md) preserves former client routing. No automatic plugin/model/SDK upgrades, permission changes or `/init` regeneration follow from reading those records.

## Instruction loading

Only the short shared core is imported at startup; detailed policy, progress, design and skills are read along the task route. Markdown links are navigation, not automatic content imports. No symlinks or history-import chain is required.

| Client | Shared core route | How to verify |
| --- | --- | --- |
| Codex | Root `AGENTS.md`; directory discovery also considers global instructions and applicable `AGENTS.override.md` | Start a fresh session at the intended directory; inspect discovery/initial instructions, then independently read PROGRESS. Do not assume arbitrary Markdown imports are supported. |
| Claude Code | Root `CLAUDE.md` explicitly imports `@AGENTS.md`; scoped `.claude/rules` apply to their matching files | Inspect `/memory` and imported paths in a fresh session. Relative imports resolve beside the importing file. Unscoped rules auto-load; `.agents/rules` does not provide a universal auto-loader. |
| Gemini CLI | Root `GEMINI.md` imports `@./AGENTS.md` | Inspect `/memory list` and `/memory show` (refresh when appropriate). Validate the installed client's behavior. |
| Antigravity CLI | Official migration docs describe project GEMINI/AGENTS context; do not assume every Gemini capability/version is identical | Check the actual executable/version and loaded context. If unavailable, label this a documentation-backed static route, not a runtime result. |
| Other clients/cloud sessions | Explicitly read AGENTS and applicable local/managed instructions | Report unsupported imports and unknown external overrides. Do not claim absence merely because they cannot be inspected. |

Loading references checked 2026-10-24 through Context7 and primary documentation: [Codex discovery](https://learn.chatgpt.com/docs/agent-configuration/agents-md), [Claude memory/imports](https://code.claude.com/docs/en/memory), [Gemini context imports](https://github.com/google-gemini/gemini-cli/blob/main/docs/cli/gemini-md.md), [Gemini memory inspection](https://github.com/google-gemini/gemini-cli/blob/main/docs/cli/tutorials/memory-management.md), [Antigravity migration](https://antigravity.google/docs/cli/gcli-migration.md). Installed-client results and limitations belong in the [cleanup report](audit/AI_CONTEXT_CLEANUP_2026_10_24.md), not a permanent version promise.

Local/global instructions and auto-memory are useful navigation. Verify their remembered baseline, counts, schema and next action against repository truth. Do not copy private memory/settings values into tracked files or edit user memory without a direct request. Higher-priority runtime/managed rules may exist outside repository visibility; mark unknowns and surface material conflicts. Skills and memory cannot approve new scope.

## Verification and handoff

Apply only [V1–V8](VERIFICATION_POLICY.md) to the cumulative final diff and frozen task criteria. Keep test, host, browser, emulator, physical-device, real-sample, CI, human comprehension and owner acceptance distinct. Reused evidence must identify its input revision/state and why relevant inputs/environment remain unchanged; a newer commit/date/session alone does not invalidate it. A historical broad PASS does not close unrelated or newly changed surfaces.

A fresh validation session is useful at task/stage boundaries where practical (V8), but must not reopen passed criteria without V6 evidence or re-run unchanged checks for a newer timestamp. Validation-only sessions report findings and stop; corrections require their own scope. V4 bounds blockers and V5 bounds revalidation.

Minimum handoff:

- Task, approved scope/exclusions, frozen criteria and stop condition.
- Worktree/branch, base and head, upstream/remote freshness, pre-existing and new dirty changes, changed paths.
- Decisions and source references; implemented behavior versus owner acceptance.
- Checks with exact input revision or dirty fingerprint, result, evidence location, reuse reason and limitations.
- Pending criterion/finding IDs, concrete blockers/dependencies/resumption conditions.
- Next allowed action and current Git/device/publication permissions.

Update only documents invalidated by the task: relevant FEATURE_STATUS/TECH_DEBT, architecture/schema actual-state sections, scientific assumptions, export contract or ADRs as applicable. Stable IDs are never renumbered/deleted. PROGRESS remains a short current handoff; relocate superseded status verbatim with provenance to PROGRESS_HISTORY. Historical audits and immutable/hash-bound evidence retain their original bytes; label them from indexes/sidecars.

## Git, privacy and builds

Keep commits coherent when authorized. No `reset --hard`, force push, automatic stash/pop, branch/worktree deletion or unknown-file deletion from an agent recipe. Commit, push, merge, publication, installation and data operations follow the current owner's permissions, never a historical handoff. The governance cleanup itself authorizes no commit/push or device action.

Signing keys/passwords are owner-managed: never create, read, print, request or commit them. Keep private metadata/photos and signing material outside public Git. Adding data that leaves the device requires the relevant privacy/compliance updates and approved provider scope. Release procedures remain in [RELEASE](RELEASE.md) and relevant guardrails; this document is not release authorization.

For a future authorized build, keep a receipt with: source commit; dirty-input paths and content fingerprint where applicable; applicationId/package; build variant and entrypoint; version name/code; build toolchain/environment; artifact SHA-256; UTC build time and evidence location. Do not store signing secrets. A debug-signed test build is not an owner-signed release.

Before device validation, confirm the actually installed **and opened** package, its artifact hash/version where available, source/receipt and target device. `io.github.buffur.culmina` and `io.github.buffur.culmina.s2check` are separate apps: an old test app showing old screens does not prove canonical source rolled back. Preserve owner data; never repair a package mix-up by automatic uninstall, clearing data or replacing an APK. Visual differentiation of test apps is a separate possible task.

Finish the named work, report what passed and what remains, and stop. No automatic roadmap continuation or redesign follows a handoff.
