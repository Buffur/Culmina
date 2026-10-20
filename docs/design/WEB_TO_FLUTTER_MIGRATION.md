# Web to Flutter migration — original Hybrid / Geist

Status: **IN PROGRESS — NOT ACCEPTED**. Updated 2026-10-20 after the owner resumed
work following a model change. This ledger records actual evidence; focused host
checks, browser captures and native checks have different coverage.

## Hand-over (2026-10-20)

Codex stopped mid-way through step 2 of the completion sequence (the full gate
failed; repairs were in progress). The stage-by-stage state, the re-check run on
the committed tree and the next actions are in
[CONTINUATION_PROMPT_2026_10_20.md](migration/CONTINUATION_PROMPT_2026_10_20.md);
resume from there. The hand-over commit is a work-in-progress checkpoint, not
acceptance.

## Objective and authority

Implement the approved original Hybrid design in the existing Flutter/Dart app,
with Geist, while preserving every existing capability, real data source,
calculation, validation, persistence format and platform integration. The full
owner requirements are in the attached `pasted-text-1.txt`; both matrices below
are the working implementation and verification checklist.

| Source | Authority / frozen identity |
| --- | --- |
| Existing Flutter | Domain behavior, real providers, storage and native integrations. Git baseline `8048cfa4e7fd5eadc99cba708a02f055ceddd53f`, develop. Existing dirty/untracked work is preserved; baseline status is in `migration/evidence/baseline/git-status.txt`. |
| Approved web | `design/home-lab/`, original Hybrid `blend`, revision `20261020-hybrid7`, with the owner's `font=Geist` override. Frozen source hashes and 24 original eight-root reference captures are in `migration/evidence/reference/`. |
| JSON | `design/home-lab/tokens.json`, SHA-256 `0eae21439d1af5bd9cadd6805d329057da97c245519a61a2165e971950ddbb51`. Entire file read: 179 scalar leaves, 12 roots, no arrays/schema-version field. The older snapshot date is documented; current CSS refinements complete its presentation contract. |
| Local guidance | `docs/refinement/PRODUCT_DIRECTION.md`, `docs/DESIGN_SYSTEM.md`, `docs/DECISIONS.md`, `docs/design/WORKFLOW.md`, repository handoff and five Culmina design skills. Earlier prototype-only adoption limits are superseded by this explicit native-migration request. |

Web determines composition, hierarchy, components and represented interactions;
JSON determines exact values it actually contains; Flutter determines scientific
and data behavior. Browser fixtures never become production plan or weather data.
No architecture replacement or general dependency upgrade is part of this work.

## Matrices and detailed registers

- **Matrix A — Web to Flutter:** [85 source obligations](migration/WEB_DESIGN_INVENTORY.md).
- **Matrix B — Existing to updated Flutter:** [63 capability rows](migration/FLUTTER_CAPABILITY_INVENTORY.md).
- [All 179 JSON leaves](migration/JSON_FIELD_ACCOUNTING.md), including used,
  transformed, not-applicable and unresolved adoption statuses.
- [Plan implementation and compatibility](migration/PLAN_IMPLEMENTATION.md).
- [Preservation reconciliation](migration/evidence/PRESERVATION_RECONCILIATION.md).

A class remaining in the repository does not close a capability row. Closure
requires a reachable action and a verified result at its stated evidence level.
All eight roots and supporting editors, dialogs, details, errors, unknown states,
large text, themes and platform workflows belong to these registers.

## Accepted decisions

1. Preserve dirty/untracked owner work. No reset or clean. Until 2026-10-20 no
   commit or push was requested; after Codex ran out of limits the owner asked
   for a work-in-progress commit and push to `develop` (see "Hand-over" below).
2. Use the **original Hybrid**, not Page/manuscript, Soft or Desk. Geist replaces
   the prototype's old default families, including root navigation.
3. Use locally bundled licensed Geist assets, registered licence and typed Dart
   presentation tokens. Real calculations/providers/repositories remain native.
4. Keep four root destinations: Tonight, Logbook, Library and Settings. Plan and
   Night/Moon/Weather remain reachable detail routes; `/moon` selects Moon.
5. Keep native legacy capabilities absent from web in reachable secondary
   details/actions, with minimal Hybrid presentation. Do not replace real file
   import/export or restore with illustrative browser walkthroughs.
6. **Owner approved:** all four per-plan overrides, migration and compatibility
   tests: time between frames, setup outside window, fixed margin and bytes per
   frame. Implemented using nullable schema v27; explicit zero differs from
   inheritance, and old snapshots/backups keep their previous semantics.
7. **Owner declined:** standalone rig JSON import/export. Preserve existing photo
   metadata and full backup/restore; Matrix A-LIB-05 is an accepted scope omission.
8. **Owner approved:** full Undo after deleting Logbook entries, rigs, targets or
   sites, including storage restoration and compatibility tests. This supersedes
   the initial permanent-delete adaptation. Implemented with focused storage/UI/state/schema evidence; final native and independent QA remain pending.
9. Planning Settings needs local draft Save/Cancel, matching actual web scope.
   Appearance and Privacy are immediate in both sources. Android system font
   scaling replaces the browser-only preview-size control.

## Implementation checkpoint

- Geist assets, licence registration, exact three-theme Hybrid color roles,
  geometry, typography, control themes and 120/180 ms motion tokens are present.
- Tonight uses plan-first hierarchy, flat condition rows, live estimates and
  working routes. Plan uses existing scoped editors, capture validation, real
  budget/storage/stacking calculations, guarded Save/Discard/Cancel and a
  keyboard-aware fullscreen capture-block editor.
- Shared Night/Moon/Weather browsing uses a transient viewed night without
  changing the working plan. Explicit Plan this night retains adoption guards.
  All three tabs expose the shared date browser. Night/Moon primary content is
  compact; scientific readouts, Moon facts and Sun/twilight remain reachable
  through disclosures. Moon preview jump targets the real timeline.
- Sky colors use Oklab interpolation without moving scientific boundaries.
  Moon-up and moon-free lanes remain separate. Weather uses real hourly slots,
  separate temperature/dew and humidity scales, unknown gaps, isolated points,
  exact-hour selection, source age/coverage and retained numeric details.
- Library/Logbook/Settings root composition is flat and grouped; existing
  editors, result recording, progress, metadata, exports, backup and About routes
  remain assigned to preservation checks.
- Current bounded edits: calendar week boundaries/retry/selection and durations;
  Planning Settings buffered Save/Cancel; full stored-record Undo.
- View entrance uses 180 ms, cubic(.16,1,.3,1), opacity .72 to 1 and 4 logical
  pixels to zero. View changes trigger it; typing does not. Reduced motion shows
  complete content immediately. Cupertino interactive Back is retained.
- Feedback now uses a MaterialBanner layout row below the native app bar, so it
  does not cover records or fixed actions. Existing action/expiry outcomes are
  retained. Verification of this shared adaptation is pending.

## Evidence ledger

[Baseline report](migration/evidence/baseline/BASELINE.md): analyzer passed and
94 selected existing tests passed before production edits. Initial host renders
were captured after the first Tonight edit and are explicitly partial migration,
not an untouched visual baseline.

The actual independent Claude CLI **preflight** completed read-only and its
original output/invocation are preserved under `migration/evidence/baseline/`.
It is not the final post-implementation review.

Focused implementation evidence, with precise scope in each log:

- Fullscreen editor/Plan bundle: **129 passed**, `migration/evidence/plan/editor-tests.txt`.
- Tonight/conditions/routes/interpolation: 70 passed and one obsolete combined
  headline assertion failed; its corrected separate-verdict/window-load check
  passed in `migration/evidence/tonight-large-plan-recheck.txt`.
- Overrides: domain, repository, VM/UI atomic Apply, v8-v26 migration and backup
  compatibility bundles are linked in the Plan notes. Existing complete schema
  guardrails and final native round trips are still required.
- Weather/Night/Moon bundle: **46 passed**, `migration/evidence/weather-tests.log`,
  before the newest composition/calendar/message changes. A new run is required.
- Settings first pass: **34 passed**, `migration/evidence/settings-tests-final.log`,
  before the buffered Planning form. A new run is required.
- Interim host renders: 6 passed / 72 PNGs, eight roots plus Settings sections,
  three themes at 100/200%. Some sources changed during that pass; superseding
  stable captures are required.
- Matched canonical fixture: 30 real native-computed nights; weather slot arrays
  are identical and audited aggregate counts/ranges match. The browser adapter
  is isolated under `tool/design/comparison/`; original source remains frozen.
  24 Night/Moon/Weather browser captures and corrected 24-hour host PNGs are in
  `migration/evidence/matched/`. Remaining-root DTO/adapter work is in progress.

One concurrent Flutter attempt failed because Windows held sqlite3.dll in
another test process. Flutter test/build/render commands are now serialized;
no files were deleted or permissions changed to bypass the lock.

## Native evidence and current limits

The first Android test-entry APK compiled and installed, then the harness failed
before its first interaction because its lazy scroll finder was incorrect. That
helper is fixed. The attempt remains in `migration/evidence/native/drive.log` and
is not successful workflow acceptance.

Android Studio now owns the initial isolated emulator 5580. A second isolated
AVD `culmina_hybrid_native_qa` on **5582** is prepared for migration QA, with
412x915 logical display and 24-hour formatting. The IDE session and attached
physical phone are preserved. Every QA adb command explicitly names 5582.

Prepared native harness uses actual widgets/router/ViewModels, real astronomy
and isolated SQLite, with simulated network/GPS/preferences. It covers eight
roots/three themes/100-200%, editor keyboard/Back, saved/reopened plan, all four
assumptions, result/progress, synthetic FITS through production Android file I/O
and backup stage/apply/reopen. Actual provider pickers, live GPS/weather, real
camera files, share receivers, process death and human accessibility acceptance
must not be inferred from those checks.

No final production APK, final native workflow pass, complete matched visual
acceptance or final independent Claude review is claimed at this checkpoint.

## Remaining completion sequence

1. Finish and verify Calendar, Planning Settings and owner-approved stored Undo.
2. Run full analyzer, appropriate repository/presentation tests and existing
   host integration/schema/compatibility gates serially; resolve regressions.
3. Execute Android scenarios on 5582; inspect screenshots at 100/200% in all
   themes and correct confirmed layout/interaction issues.
4. Regenerate canonical fixtures/pairs for all roots and material states; record
   visual differences separately from native system-inset adaptations.
5. Build normal `lib/main.dart` APK and perform an actual hot reload on the QA
   emulator. The test-entry APK is not the deliverable.
6. Update every matrix row and JSON adoption status from actual evidence.
7. Run the prepared final Claude CLI review read-only, preserve its original
   report and exact coverage, fix confirmed findings and verify touched paths.

The goal remains active. Resume from this ledger, worker ownership and actual
source/evidence rather than restarting the baseline or treating elapsed effort
as acceptance.


Latest bounded evidence: `focus-feedback-metadata-sites-recheck.log` passed59,
`undo-final-tests.log` passed53, and `undo-ui-state-schema-tests.log` passed239.
The shared focus ring includes2dp stroke/3dp gap and verified keyboard route
return. Stored Undo exact behavior is in `migration/UNDO_IMPLEMENTATION.md`.
The Plan assumptions UI now has its own guarded fullscreen form with source
seconds/minutes/minutes/MB units; existing model units and data stay unchanged.
