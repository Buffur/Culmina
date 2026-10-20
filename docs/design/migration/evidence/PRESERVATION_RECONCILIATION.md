# Read-only preservation reconciliation

Checkpoint: after the v27 nullable per-plan override implementation, before the
final native/matched-render and full quality pass. No Flutter command was run
for this reconciliation. This is a source review and evidence ledger update,
not independent final acceptance.

## Override and old-save semantics inspected

- Every production `SessionPlan` construction path propagates overrides:
  current-plan capture, repository settle working copy, existing-reference
  resolver and saved-snapshot reader. The lifecycle applies the session's own
  nullable overrides; New clears them and Copy retains them.
- Schema v27 only adds nullable JSON. Existing database rows are not rewritten.
  Existing snapshot JSON is opaque stored data and is not recomputed during
  migration. An old saved plan opened for editing continues to inherit current
  global defaults, matching the previous editing behavior; its historical saved
  snapshot keeps its original calculation until an explicit new Save.
- An old snapshot/manifest without overrides reads as null. A present malformed
  override is refused, not converted into guessed defaults. A saved Discard reads
  explicit overrides from the saved snapshot. Repository settle keeps working
  overrides in the copy while restoring the original saved values.
- Calculation uses the nullable fields at the same existing budget/fit boundary.
  Setup is outside-window; per-frame gap does not affect light integration;
  margin only classifies spare time; manual bytes are a separate storage basis.
- Existing serialized CurrentSession autosave/failure handling is reused.
  New override controls are locally buffered until Apply; Reset returns to
  inherited values. Global Settings objects are not mutated.

No new source-grounded override regression was confirmed in this inspection.
Host tests cover these paths in the exact artifacts cited in Matrix B E3.
The existing complete schema guardrail suite and Android backup/restart remain
separate required checks.

## Full-page capture editor inspected

The route returns a CaptureBlock or null to the same caller. It retains the
original scoped controller/form state, typed camera-class controls, calibration
source/proposals and photo acceptance logic. `_leave` handles dirty Back/Close
through the existing Save/Discard/Cancel prompt. Explicit Cancel returns null;
submission validates and returns the built block. The caller applies it with
the existing Undo action. The full-page route has no outside-tap exit; visible
Close is the documented replacement. Fixed actions use safe-area and keyboard
insets. The129-test editor bundle covers host forms, guards and200% keyboard.

No new source-grounded editor regression was confirmed. Native Android
predictive/system Back, platform keyboard/file picker and visual scroll behavior
are not proved by that host result.

## Row-level evidence handling

Matrix B now gives each of63 rows a current access path and either a narrowly
scoped executed-host result or explicit pending evidence. It retains the actual
failed attempts rather than treating a `final` filename as success. At this
checkpoint the v27 conditions/navigation log had53 passes/2 failures and Weather
had29 passes/5 failures. Subsequent evidence was read: `library-slider-recheck.txt`
passes the Library refresh test while still failing the old slider assertion;
`weather-tests.log` now passes46 tests including the corrected keyboard slider,
Weather charts/200%, detail/forecast scoped browsing and Night/Moon polar/week-list.
The Weather log path was reused; its earlier failed raw output is not separately
present. Matrix B now cites these precise superseding subsets. Library/Logbook
and Settings results predate v27 and remain labelled accordingly.

The final Claude CLI prompt/preparation is staged alongside this file. It has
not been executed and cannot be cited as post-implementation QA.
