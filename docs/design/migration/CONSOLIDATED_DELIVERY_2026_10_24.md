# Consolidated design, geo and identity delivery — 2026-10-24

Owner scope: combine the current Flutter design and geo refinements with the approved rounded Culmina mark and complete launch gesture, verify preservation, update the connected phone without clearing data, remove obsolete local Git states after preserving recovery material, and push the current project to `develop`.

## Git inventory and selected baseline

Remote: `https://github.com/Buffur/Culmina.git`. Freshly fetched `origin/develop` was `2a43c89981c0f9e0f4d4eddc4a62484c470be928`. The `culqa` task checkout contains that completed Hybrid transfer, P-1–P-6 and the later uncommitted TD-120/TD-121 Tonight/geo refinements. This is the delivery base.

The owner checkout's local `develop` was `744fe5781a756e9af6a7e1580710e15cbd5e655d`, ahead one/behind twelve relative to remote develop. Its only unique unpublished commit is the initial identity implementation, based on partial-transfer checkpoint `01b8049`. Later full-launch refinements there were uncommitted. Merging that entire older checkout would reintroduce old screens; selected identity files and the latest full-launch implementation were composed onto the current base instead. The original commit also contains private phone evidence, so its commit object is not part of this public delivery's ancestry.

| Local state before delivery | Disposition |
| --- | --- |
| `744fe57`, local develop | Superseded by the combined delivery, with latest approved identity content retained; original commit recoverable from the external Git bundle. |
| `codex/tonight-context-controls` at `2a43c899` plus current work | Source of the current design/geo; combined delivery written here. |
| `fix/qa-02-save-status` at `2a43c899` | Redundant local branch; its work is already on remote develop. |
| Local main `322edbd6`, three commits ahead of origin/main | All three are already ancestors of origin/develop; no unique unpublished work. Remote main is outside this delivery. |
| Detached `cwt` and `cwt0` at `744fe57` | Obsolete identity comparison/test checkouts; the `.s2check` application-ID override is excluded. |
| Old owner-checkout equipment/target dialog edits | Superseded partial-transfer dialog layout; current completed-transfer page editors retained. Original edits preserved outside Git. |
| Seven generated desktop plugin files | Pre-existing CRLF-only differences; no logical change included. |

Before any cleanup, every dirty/untracked file from all four checkouts was copied and SHA256-verified. All committed refs were saved with `git bundle create --all` and the bundle verified. Recovery material: `C:/Users/zalub/CulminaQA/2026-10-24/consolidation/`, including `preservation-manifest.json`, `preserved/`, `all-local-refs.bundle` and the file-by-file `merge/merge-inventory.json`. No reset-hard, force-push or history garbage collection is required.

## Preserved behavior and merged files

- Completed-transfer Settings/About/Privacy, Logbook, Library, weather and full-page editors remain based on current develop. [The preceding build-selection investigation](DESIGN_BUILD_SELECTION_2026_10_24.md) explains the old screens in the separately installed identity-test package.
- TD-120 compact Tonight context, direct calendar and direct Manage sites remain. TD-121 selected-site list, unsaved Position row, search, automatic reverse-geocoded name, map/editor hierarchy, minimalist locate and icon-only edit remain. Their existing IDs and owner-acceptance boundary are preserved; see [Tonight](TONIGHT_CONTEXT_FIXES_2026_10_23.md), [geo implementation](GEO_FLOW_IMPLEMENTATION_2026_10_23.md) and [latest geo refinement](GEO_OWNER_REFINEMENT_2026_10_23.md).
- Approved rounded mark, launcher layers/PNGs, theme-aware still Android splash, full 1,400ms Flutter gesture and one reveal are integrated. Android sends the splash handover; Flutter owns the gesture. Reduced motion, delayed readiness, failure/retry and background pause retain dedicated regressions. `tool/culmina_mark.py` remains the generator; generated raw colours reside in `lib/core/theme/culmina_mark_colors.dart`, re-exported beside the generated geometry. The preview uses semantic project tokens.
- Integration review found a recovery-root restart hazard and a Retry accessibility gap. `lib/main.dart` creates a fresh keyed launch state on intentional database reset; `launch_gate.dart` exposes the Retry semantic tap and prevents overlapping initialization attempts. Focused tests exercise actual semantic actions, intentional keyed restarts and a real fixture-backed app revealing the current Tonight, geo and About surfaces after the full gesture.
- Canonical package stays `io.github.buffur.culmina`. No `.s2check` suffix, dependency update, schema/calculation/data-contract change or web-reference rewrite is included.

Private owner screenshots and launcher crops are retained externally, not published. Historical installation evidence remains dated; its earlier no-commit/no-push statements describe those earlier runs. The current owner request explicitly authorizes this delivery.

## Verification and delivery record

Required verification is complete for the combined source. Public fixture evidence and a hash manifest are in [evidence/consolidated-2026-10-24/](evidence/consolidated-2026-10-24/verification.json). Raw logs, original private captures and the APK are in the external recovery/evidence directory above.

- HOST: full unit/widget suite **2509 passed, 6 skipped**. Host core-loop E2E **2 passed**; performance scenarios **1 passed**. The two Android-only smoke/capture files are skipped on host by their existing platform guards, not counted as exercised there.
- After correcting the Retry test's deprecated semantics dispatch API and removing its redundant import: focused launch/real-app regressions **16 passed**; fresh full analyzer **no issues**, format **645 files/0 changes**, encoding **passed**. The earlier full-gate log retains its analyzer failure; its passing suite/E2E results are reused because only this test dispatch/import changed, with final regressions rerun. No failing result is relabelled as a passing full-gate invocation.
- EMULATOR: API30 x86_64, native view750x1632,DPR2,text1,dark, bundled fonts and the existing Hybrid fixture (Kyiv50.4/30.6, night2026-10-19, clock2026-10-18T15:00Z). Seven targeted states captured: Tonight, saved/transient sites, Add, map, About and Privacy. Native drive **passed**. Fixture tile HTTP failures are expected offline data, not successful downloads. The known integration-screenshot toolbar crop persists; raw captures are retained and actual physical UI independently inspected. No stretching/cropping was applied to these originals.
- The first debug attempt lacked the default launch drawable in stale incremental merged resources; forcing resource regeneration restored it. The next capture lacked the generated integration-test plugin after switching from release; an offline pub refresh regenerated the registrant. The third drive passed. Production resources were already present in the installed release; no production workaround was added for these build-cache failures. Dependency lockfile unchanged.
- Ordinary Android `main.dart` launch and Dart MCP hot reload **succeeded**, runtime errors **none**. Generator rerun plus formatting reproduced **all377 production input hashes exactly**; no post-build source drift. Independent read-only review by `/root/review_geo` found **no remaining blocker**; the reviewer made no edits and ran no tests/device actions.
- PHYSICAL: Xiaomi14T Pro, Android16,1220x2712,DPR3.25,text1,dark. Release/debug-signed canonical package installed with `adb install -r`: **Success**. Pulled installed APK matches the new APK hash. Visible saved/changed Crab Nebula plan, rig, night and time budgets remained after update. Read-only navigation checked direct calendar/cancel, direct Manage sites, Add, record management, Settings/About/Privacy. No Save/Delete, GPS request, permission changes, uninstall or data clearing.
- APK `culmina-combined-release-debug-signed.apk`, version1.0.0+1, SHA256 `6a3637c688e50e3dd186b631bd1e9010810b6b46ce48c33675d476368353e47e`. Certificate SHA256 `56d00b35cb297aceabc42aef7033d41a7b5c7a1939e7d14cf7329672f8902dbe`, identical to the previous installed geo build. This is an owner test build, not a store-signed release.
- Private original physical evidence: `phone/canonical-before-settled.png`, `combined-tonight.png`, `combined-sites.png`, `combined-add.png`, `combined-about-settled.png`, `combined-privacy-settled.png`, `combined-calendar.png` and cancellation capture. `phone/launch.mp4` retains the complete cold-start recording. `launch-contact.png` is a derived8fps/183px-wide contact sheet for inspection; originals unchanged. Physical checks establish the visible state and inspected flows, not exhaustive database integrity or owner acceptance.

Existing before/reference/100–200% light/dark/field geo evidence is reused from the linked TD-120/TD-121 reports: reviewed geo sources are byte-identical except an equivalent14dp token expression; Tonight only moves its loading mark to the root gate. The frozen web reference remains read-only. This is a consolidation, not a new visual transfer.

The obsolete detached `cwt`/`cwt0` worktrees and redundant `fix/qa-02-save-status` branch were removed after verified recovery copies. The combined delivery is a normal descendant of `2a43c899`; remote main is unchanged. Final develop-ref reconciliation, remaining task-checkout cleanup and push receipts are recorded externally beside `preservation-manifest.json`. The separately installed `.s2check` phone application is left untouched to preserve its data; canonical Culmina is the updated working application.

Earlier public log copies have trailing whitespace normalized for Git; their original raw files remain in the preservation archive. No test/golden baseline was weakened or replaced.

## Manual owner acceptance

1. Open the canonical Culmina application: inspect the rounded launcher mark, full launch gesture and single transition into the current Tonight design.
2. Check that the existing plan/site remains; site and date controls share one compact row. Date opens the calendar; site opens Manage sites directly.
3. Inspect saved-site selection and icon-only edit. Open Add site and map; check spacing and hierarchy. Back out without saving. GPS/permissions are not required for this check.
4. Open Settings → About and Privacy; inspect the compact source disclosure and current privacy layout. Library/Logbook retain their completed-transfer design.
5. Owner visual acceptance remains pending until explicitly given. Automated HOST, native EMULATOR and physical read-only verification are reported separately.
