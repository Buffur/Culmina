# Web to Flutter migration — original Hybrid / Geist

Status: **IMPLEMENTED AND VERIFIED WITHIN THE STATED COVERAGE — AWAITING OWNER
ACCEPTANCE**. Updated 2026-10-21 after the resumed completion run (below).
Evidence levels stay separate: host tests, browser/host image pairs, Android
emulator and physical device are different claims; no physical-device or owner
acceptance is claimed.
## Hand-over (2026-10-20)

Codex stopped mid-way through step 2 of the completion sequence (the full gate
failed; repairs were in progress). The stage-by-stage state, the re-check run on
the committed tree and the next actions are in
[CONTINUATION_PROMPT_2026_10_20.md](migration/CONTINUATION_PROMPT_2026_10_20.md);
resume from there. The hand-over commit is a work-in-progress checkpoint, not
acceptance.

## Resumed completion run (2026-10-21)

Resumed by Claude Code from the hand-over on another Windows machine (Flutter
3.47.4 at `C:	oolslutter-3.47.4`), branch
`claude/owner-brief-2026-10-20-d413ba` fast-forwarded to `develop` `c224cf6`.
The seven-step sequence below now stands as follows.

| Step | Result | Evidence |
| --- | --- | --- |
| 1. Calendar, Planning Settings, stored Undo | Done (hand-over) and covered by G2 and N1 | `UNDO_IMPLEMENTATION.md`, N1 report |
| 2. Full gate, regressions | **PASS** after repairs: one real leak/use-after-dispose (scoped `NightConditionsViewModel` listener), guard-test fixes, tests moved to the Hybrid contract with values unchanged; one pre-existing Windows-only cleanup failure separated from regressions | `migration/evidence/STEP2_GATE_REPAIRS_2026_10_21.md`, `full-gate-2026-10-21.log`, final runs `full-gate-2026-10-21-final.log`, `after-review`, `open01`, `r4` and the clean closing run `full-gate-2026-10-21-closing.log` (G2) |
| 3. Android scenarios on 5582 | **PASS** — `flutter drive` of the native harness, all checks, 69 screenshots, eight roots × three themes × 100/200 %. The harness itself needed two fixes (hermetic preferences before catalogue seeding; a pump after `ensureVisible`); it had never been green before. The Kotlin cross-drive build failure is the documented `kotlin.incremental=false` case (RELEASE.md) | `migration/evidence/native/run-2026-10-21/`, `r2`, `r3-editor`, `r4` and, on the final code, `run-2026-10-21-r5/` (N1; failed attempts kept) |
| 4. Matched browser ↔ host pairs | **Reviewed**: fixture unchanged, host recaptured, 48 pairs regenerated, per-pair review; repairs made for the inverted Moon phase glyph (pre-existing F15 defect), the missing Moon primary number, Planning slider rows, app-bar action margins and "1 rigs" | `VISUAL_COMPARISON_AUDIT.md` final section (V1), `migration/evidence/matched/gallery/` |
| 5. Normal APK + hot reload on 5582 | **PASS** — `lib/main.dart` debug APK installed and started; a real source change hot-reloaded ("Reloaded 1 of 2788 libraries", code 0) and reverted. On the final code, `flutter build apk --debug -t lib/main.dart` built `build/app/outputs/flutter-apk/app-debug.apk` (SHA-256 `d12575b6…44dd244`), installed and launched to the first-run screen on 5582 | `migration/evidence/native/run-2026-10-21/hot-reload-main.log` (H1); `run-2026-10-21-r2/build-apk-debug.log`, `main-apk-launch.png` |
| 6. Matrices and JSON statuses | Done: every Matrix A row (84 + the accepted A-LIB-05 omission) and all 63 Matrix B rows cite G2/N1/V1/H1 and name what was not exercised; all 179 JSON leaves remain accounted (56 used, 2 transformed, 121 not applicable, 0 blocked) with `hybrid_tokens_test.dart` in G2 | Matrix A/B "Final evidence (2026-10-21)" |
| 7. Independent Claude CLI review | **Run** (read-only, exit 0); 12 findings, dispositions below; confirmed defects fixed and re-verified | `migration/evidence/final-claude-original-report.txt`, `final-claude-invocation.txt` |

### Independent review (Claude CLI, 2026-10-21) and dispositions

The CLI ran read-only on `02f5cdb` (Read/Grep/Glob only, exit 0, 06:36–06:47
UTC); its report is kept verbatim. It saw the report file empty only because
its own output was being written there. Its verdicts were: visual fidelity
FAIL, functional preservation PASS (host scope), persistence/compatibility PASS,
accessibility/native FAIL, evidence quality FAIL.

| Finding | Disposition | Re-verification |
| --- | --- | --- |
| F1 "Weather" tab clipped at 200 % | **Fixed**: the tab bar scrolls when 14 px labels exceed ~1.3x | New test fails without the fix, passes with it; host 200 % renders; N1 r2 |
| F2 override labels lose units at 200 % | **Fixed**: Hybrid label above each field, wrapping; the field keeps it as its accessible name | New 200 % test (whole label, semantics label) |
| F3 block editor: no gap between fields; editor composition not adopted (segmented type, label-above, examples, live integration line, From a photo disclosure, rig line, full-width Apply) | Gap **fixed**; composition **done as OPEN-01** (below) | Editor suites; editor pairs; N1 r3 |
| F4 boilerplate "VERIFIED" in Matrix A | **Fixed**: default rows now say host-verified, root reviewed, interactions not driven on the device; only rows N1 really drove say so | Matrix A/B text |
| F5 simulated text scale/theme, no system Back | Labels corrected (in-process test values). **Added** platform Back (route-pop message) on a dirty editor: asks; Cancel keeps; Discard leaves the plan unchanged | N1 r2 |
| F6 skipped host suite printed as PASS | Recorded: `hybrid_migration_smoke_test` is skipped on the host by design; the gate prints PASS for a skipped file. Tooling unchanged | — |
| F7 Settings sections keep the root navigation | **Adopted** (D-05): groups and About open above the tabs | `app_shell_navigation_test` |
| F8 field-mode action black on #AA0000 (~2.7:1), contrast unchecked in field mode | **OWNER DECISION D-06**: the pairing comes from `tokens.json`; widen the documented field exception or change the action colour | — |
| F9 Geist variable weights | **Verified**: `geist_weight_test.dart` shows w400 < w500 < w600 < w700 widths with the bundled font (real instances, not one outline) | G2 |
| F10 "Theoretical" bytes label | **Fixed**: "File size per frame (MB)", hint "A planning figure, not measured from your files. Empty: your file or rig evidence." | G2 |
| F11 DATA_MODEL still v25 | **Fixed**: DATA_MODEL v27 row and note; FEATURE_STATUS note | Docs |
| F12 minor gaps (Weather clearest/cloudiest line, coverage only when incomplete, "10 h 55 min dark" on Tonight, "M42" in the plan summary, rig editor dialog style) | **Adopted** (D-07), except the rig editor dialog | `weather_forecast_widget_test`, Tonight tests |

**OPEN-01 — done (2026-10-21, owner's go-ahead).** The block editor now
follows the web composition on its existing state (plan.js `blockView`): the
rig named above the form, the frame type as a segmented choice, "From a photo"
and Details (binning and planned timing, with their values in its summary) as
disclosures, labels above the fields with their hints at the field's edge, the
live "= … of integration" line (or a calibration block's planned time, "not
integration"), focus as a segmented record, and a footer that says what the
action does above a full-width Add block / Apply changes. Validation, origins,
proposals, calibration matching, file reading and the unsaved-changes guard
are unchanged. Evidence: `block_editor_hybrid_test.dart` and the editor suites
(158 tests), matched editor pairs `plan_editor` / `plan_editor_invalid` in the
gallery, native run `evidence/native/run-2026-10-21-r3-editor/` (all passed, 70 screenshots), full gate `evidence/full-gate-2026-10-21-open01.log` (2423 tests and host E2E pass; its one analyzer warning, an unused test import, was removed and re-checked in the same log). Kept native
(D-08, below).

### Independent re-review (V5 scope, 2026-10-21) and dispositions

A second read-only CLI run on `275d520` checked only F1–F12, the touched
criteria and the corrections' regressions (prompt `FINAL_CLAUDE_REREVIEW_PROMPT.md`,
report kept verbatim in `final-claude-rereview-report.txt`, exit 0). Result:
F1, F2, F3, F5, F7, F9, F10 (wording), F12 resolved; F4, F6, F11 partly; F8 =
D-06 open. Two new items, both addressed:

| Item | Disposition | Re-verification |
| --- | --- | --- |
| N1 an invalid white-balance tint in a closed Details was not checked (dead Apply for 2000, silent drop for "abc"); present since before the migration, since the tint field was already inside Details | **Fixed**: Apply opens Details first when its tint is invalid, so the field's check runs and shows; a recorded tint is named in the closed Details summary | `block_settings_test` "an invalid tint (2000 / abc) in a closed Details" — fails without the fix, passes with it |
| N2 no clean full gate on the final code; G2/N1 definitions stale | **Fixed**: `full-gate-2026-10-21-closing.log` passes uninterrupted on the final code (2429 tests, host E2E); Matrix A/B definitions name it and the final native run r5 | Matrix "Final evidence" |
| F4 leftover "pending" text | **Fixed**: 38 stale phrases in Matrix A and the ledger/audit leftovers now point to their evidence | Docs |
| F11 rules not in SCIENTIFIC_INTEGRITY / DECISIONS | **Fixed**: SI-006 and SI-013 addenda; ADR-023 records owner decisions 6–8 | Docs |
| Risk: screen-reader labels on fields | **Verified**: each label above a field is the text field's own semantics label | `block_editor_hybrid_test` "a screen reader hears each label on its text field" |
| Risk: the fit-line mark does not scale | **Fixed**: it scales with the text | Tonight tests, host renders |
| Risk: the gate-percentage slider kept tick marks | **Fixed**: every Settings slider uses the shared Hybrid slider | Settings tests |
| F5 hardware Back key, real font on the eight screens; F9 weights on Impeller | Not exercised beyond the recorded runs (L-6; Geist weights proven with the bundled font on the host) | — |

### Deviations kept on purpose (native authority)

- **D-01 — adopted 2026-10-21.** Tonight now uses the web's fit line (a check
  or info mark beside a 13 px verdict, the reason in 12 px below) and the
  web's condition rows (13 px label, 15 px value, 12 px supporting lines,
  including "10 h 55 min dark"). The Night value keeps the F17 wording
  "Dark (Sun below −18°): …" and the zone rule stays as a supporting line, so
  the darkness limit and zone are still named; the web's illustrative
  "example window" note stays browser-only.
- **D-02** Plan keeps active rig capability warnings (NPF / max sub when
  tracking is unknown) visible above the capture list (TASK 8.6, PD-11); the
  first capture block can start below the first screen.
- **D-03 — adopted 2026-10-21.** Night/Moon/Weather show the web's one context
  line: "Ljubljana · Europe/Ljubljana, CET, UTC+01:00" (the abbreviation and
  offset kept; a device-zone caption keeps its words); a screen reader hears
  the full zone rule.
- **D-04** Dates use the app's existing `NightTimeFormatter` (device locale:
  "Tue, Nov 10"), not the web's "10 Nov".
- **D-05 — adopted 2026-10-21.** Settings groups and About open above the tabs
  (root navigator), like Plan and Night/Moon/Weather; Back returns to the
  Settings root (`app_shell_navigation_test`). Their sliders now use the
  web's full-width solid track without division ticks. Evidence: native run
  `evidence/native/run-2026-10-21-r4/` (all passed) and full gate
  `evidence/full-gate-2026-10-21-r4.log` (2425 passed; the one guard failure, a raw
  slider inset, was replaced by a spacing token and re-checked in the same log;
  the native run predates that 2 px inset change).
- **D-06 (owner decision, open)** Field mode's primary action is black on
  `#AA0000` (about 2.7:1) and the accessibility sweep does not check contrast
  in field mode; the documented exception covers secondary text only.
- **D-07 — adopted 2026-10-21 except the rig editor.** Weather adds the web's
  "Clearest around … · cloudiest around …" line, the dark span's length and
  an always-stated "Coverage: n/m hourly samples in dark time"; Tonight's rig
  line leads with the catalogue ID ("M42 · …"). The rig editor stays a
  dialog (unchanged).
- **D-08** Block editor, kept native: a fifth frame type (Dark flat) makes the
  segmented choice two rows; "From a photo" appears only where files can be
  read (not on the host renders); validation messages sit under their field
  instead of the web's "Check the highlighted fields" toast; the footer keeps
  an explicit Cancel beside its explanation; the filter stays a list with
  None and any custom filter, not free text.


### Not exercised (limits)

L-1 system file/photo pickers and real camera files; L-2 GPS permission, live
fix and live map tiles on a device; L-3 physical phone; L-4 platform share sheet
and external browser; L-5 process death/app restart and route recreation; L-6
human screen-reader and hardware-keyboard acceptance, motion timing on device.
L-6 in part checked on 2026-10-21: the real `lib/main.dart` app on the emulator
follows the Android system font scale 200 % and the system dark setting
(`evidence/native/run-2026-10-21-r4-system/`), restored afterwards.
A release build was not made: release signing is owner-managed.

## Objective and authority

Implement the approved original Hybrid design in the existing Flutter/Dart app,
with Geist, while preserving every existing capability, real data source,
calculation, validation, persistence format and platform integration. The full
owner requirements are in the attached `pasted-text-1.txt`, kept verbatim as
[OWNER_BRIEF_2026_10_20.md](migration/OWNER_BRIEF_2026_10_20.md); both matrices below
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
   the initial permanent-delete adaptation. Implemented with focused storage/UI/state/schema evidence; on 2026-10-21 covered by the full gate, the emulator drive (entry and site delete/Undo) and the independent review (rig and target Undo are host-verified only).
9. Planning Settings needs local draft Save/Cancel, matching actual web scope.
   Appearance and Privacy are immediate in both sources. Android system font
   scaling replaces the browser-only preview-size control.

## Implementation checkpoint (2026-10-20, historical)

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
  retained. (2026-10-20 text; verified since by the full gate and the emulator drive's Undo and failure screenshots.)

## Evidence ledger (2026-10-20, historical — superseded by the resumed run above)

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

## Native evidence and current limits (2026-10-20, historical — superseded above)

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

## Completion sequence as planned on 2026-10-20 (now executed; see the resumed run above)

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
