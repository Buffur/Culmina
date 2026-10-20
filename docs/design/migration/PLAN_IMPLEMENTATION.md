# Plan implementation checkpoint

2026-10-20. Scope: `lib/presentation/screens/home/`, `planner_summary_card.dart`, `capture_plan_widget.dart`, `capture_plan/capture_budget_summary.dart`, `capture_plan/capture_block_dialog.dart`, `plan_status.dart`, and their focused regression tests. Main agent owns the shared theme/Geist assets, routing, Tonight and conditions. The owner subsequently approved all four per-plan assumptions, including data migration and compatibility tests. This checkpoint now also covers the bounded domain, snapshot, persistence and export work described below.

## Web to Flutter mapping

| Web requirement | Source | Flutter implementation | Evidence/status |
|---|---|---|---|
| Open identity and fit before editable context | plan.js identityStrip/answerSection/contextRows; plan.css | HomeScreen identity scrolls with page; existing PlanStatus and ContextLine remain connected to real site/night and fit | Implemented, focused tests in evidence/plan |
| Compact target and rig rows | plan.js contextRows; hybrid-refinement.css plan-row | PlannerSummaryCard label/value/caption/chevron; original picker callback; reference measurements under details | Implemented; current sky retained separately when viewing another night |
| Capture blocks with edit/reorder/remove | plan.js blockRow/captureSection | Existing ListTile editor action plus explicit Edit/up/down/delete controls; existing reorder API, delete/Undo, fit and calibration guidance | Implemented; new move-control regression test preserves values; drag also remains available |
| Recorded block settings | plan.js recordsLine | Existing typed CaptureGain and CaptureSettingsText rendered beside each block; unknown kind remains explicit | Implemented; no gain/ISO arithmetic introduced |
| Always-visible estimate grid | plan.js estimateSection; plan.css estimate-grid | Integration, total session time, storage, relative stacking gain from CaptureBudget; 2 columns normally, 1 column at large text/narrow width | Implemented; retained all budget details and separate comparable-group results |
| Detailed budget/relative gain graph/assumptions | plan.js budgetDisclosure/gainDisclosure | Existing persisted CollapsibleSection keys, StackingGainGraph and CaptureAssumptionsPanel | Preserved, graph uses real group curve data |
| The night ahead | plan.js conditionsSection | Open Night & Moon and Weather rows, existing computed summaries, zone rule and SkyDarknessWidget | Implemented; selected-night semantics retained |
| Stable Save / missing prerequisites | plan.html plan-savebar | Existing _SaveBar, saveSession feedback, disabled reason + corrective route | Preserved; page background, no raised chrome |

## Existing Flutter capability preservation

| Capability | Path after change | Preservation |
|---|---|---|
| Choose site/date, target, equipment | Open context and target/rig row | Same routes/ViewModels; actual values retained |
| Advanced target altitude/current-sky and equipment FOV/pixel-scale/size | Target/Rig details; existing Specifications and Current sky sections | No removed measurements; active capability warnings remain visible |
| Tracking override | Existing PlanTrackingRow | Same per-plan tracking control |
| Add/edit blocks, camera-class fields, calibration generation, match-light suggestions, delete/Undo | Capture plan | Existing guarded editor and validation; no changed calibration or exposure logic |
| Photo/FITS metadata review; explicit storage-size input | Existing editor/file entry points and storage actions | Existing metadata providers, provenance and confirmation remain |
| Budget components, storage source, incomparable groups, normalized gain curves | Estimate and detailed disclosures | Existing calculator/output objects, no fixture substitution |
| Global assumptions and per-plan tracking override | Existing Assumptions section and tracking row | Existing persistence scope remains explicit |
| Save/New/Copy, unsaved guard and autosave failure | Stable savebar, Plan action menu, failure banner | Existing callbacks and draft/saved distinctions unchanged |

## Explicit differences and unresolved parity

1. The owner explicitly approved all four web per-plan assumption overrides. `PlanOverrides` stores nullable `interframeSeconds`, `outsideSetupSeconds`, `fixedMarginSeconds`, and `bytesPerFrame`. Blank inherits the existing global/evidence defaults; zero is explicit for time values. The Assumptions section exposes local input buffers with Apply to this plan and Use defaults. Validation refuses non-finite/negative inputs and zero bytes. Global Settings are unchanged.
2. The capture-block editor now uses a full-page native MaterialPageRoute and Scaffold, matching the scoped web editor composition. It retains the same form state, camera-class controls, validation, metadata review and unsaved-change confirmation. Close/Back asks when dirty; explicit Cancel returns no block. Cancel/Add/Apply stay above the keyboard with safe-area padding. The former outside-tap exit is replaced by the visible close button because the editor fills the screen.
3. Scientific guidance and reference measurements absent from the compact web sample remain reachable in native disclosures. NPF/max-sub guidance and review/example warnings stay visible.
4. Native reorder supports both explicit up/down buttons and the retained drag gesture. Undo uses an accessible layout-row message; capture-block edit timing and scoped restoration remain unchanged. Stored-record Undo is documented separately.
5. First U renders in evidence/baseline were early partial-migration HOST captures (31 light PNGs), not an untouched Tonight baseline. Final Geist/native render and device evidence are coordinated by the main agent; this checkpoint does not claim emulator or physical acceptance.

## Verification and open work

Pre-migration analyzer passed and 94 theme/navigation/Tonight tests passed; original Claude CLI preflight and native environment inventory are in evidence/baseline/BASELINE.md. The first Plan run reached 145 passes and 14 failures, then was interrupted because the new move test awaited a fake-time draft write before pumping frames. The original incomplete log is preserved. A real block-count overflow at 200% was repaired with Wrap; old single-value/shape assertions are being adapted to specific semantic keys without relaxing domain assertions. Move-control test now pumps writes before checking the values.

Composition rerun: evidence/plan/targeted-rerun.txt records 58 passing and 3 failing tests; the final failed-area rerun evidence/plan/focused-final.txt passes all 31 tests, including move/reorder, stored values, 200% block rows, input validation, and reachable empty-plan actions. Scoped analysis passes with no issues (scoped-analysis.txt). Subsequent full-page editor and separated status figures are implemented and separately analyze cleanly (editor-analysis.txt); their full regression bundle passed 129 tests (editor-tests.txt), including guarded Close/Back, explicit Cancel, 200% keyboard layout, photo metadata, calibration, Undo, and real SQLite/export. Full final app analysis/build/render and post-implementation Claude QA remain part of the main migration task.



## Approved per-plan assumptions: storage and behavior

- SQLite schema **v27** adds nullable JSON `session_logs.plan_overrides`. The versioned migration is additive; existing plans keep NULL and inherit their prior global defaults. Drift generated row classes, v27 schema export, migration steps and verification schemas are generated alongside source in the working tree.
- Draft autosave, Save, reopening, Copy to night, Saved-changed Discard and settle retain the explicit overrides. New plan clears them. Snapshots retain explicit `planOverrides` plus effective per-frame/setup values and `fixedMarginS`. The manifest v2 additive `plan_overrides` object is optional; older manifests and snapshots remain readable.
- Interframe seconds feed the same overhead calculator and fit placement. Setup remains outside the window. Fixed margin replaces the percentage only for Fits/Tight classification; it does not change integration or atomic-frame placement. Bytes/frame uses a distinct **Plan estimate (user entered)** basis, not measured provenance. Clearing it restores existing file/rig/theoretical/unknown storage rules.
- Physical SQLite reopen, saved Discard and settle-copy, manifest compatibility, all supported versions v8..v26 upgrading to v27, a real v26 backup candidate migration, immutable global defaults, recompute/save/reopen/reset, and UI buffered Apply/validation are covered by new tests.

## Override verification

`evidence/plan/overrides-tests.txt`: initial targeted suite **120 passed / 3 failed**. All new domain, persistence, migration, VM and UI tests passed. The failures were three existing backup tests hard-coded to current schema v26 / future v27. Fixtures now use current v27 / future v28; no application recovery behavior was weakened.

- `overrides-backup-final.txt`: **37/37 passed**, including malformed, too old/new, dangling-reference and old-schema restore checks.
- `overrides-backup-roundtrip.txt`: **20/20 passed** after extending the backup fixture with all four explicit overrides and their saved snapshot. Full manifest comparison confirms values survive a clean-install backup restore with results/events/settings.
- `overrides-analysis-final.txt`: scoped analysis of all affected source and tests passes with **No issues found**. The earlier log retains the three style infos subsequently corrected. Full final app analysis and native evidence belong to the migration's final verification pass.

The scope is implemented and host-tested; emulator/physical-device acceptance and the independent post-implementation CLI review remain separately labelled by the main migration evidence.


## Final assumptions presentation adapter

The approved four fields now open a dedicated **Plan assumptions** screen from
`planOverride.edit`, matching the web scoped-editor composition. The native model
continues to store seconds/bytes; the form displays seconds, minutes, minutes and
decimal MB, exactly as the source. Explicit conversions are 60 seconds per minute
and 1,000,000 bytes per MB. Source upper bounds are enforced in the form.

Apply commits all four values together and returns. Use defaults edits only the
local buffer until Apply. Cancel/Back uses the existing Save/Discard/Cancel guard.
Actions are fixed above keyboard/system insets; the one-column form scrolls at
200%. Blank means inherited defaults and explicit zero retains its old meaning.
Domain, schema, snapshot, manifest and backup code were not changed by this UI
adapter. `evidence/plan/overrides-fullscreen-tests.log` passed the seven existing
assumption cases; a new 200% keyboard/Cancel/Back case and the final gate follow.
