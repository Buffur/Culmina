# Stored deletion Undo checkpoint

Owner-approved scope: Logbook entry, rig, target and site deletion. Confirmation
remains before deletion; the resulting inline message offers one Undo until
Dismiss or replacement by another message. It has no automatic expiry, matching
Hybrid's stored-record affordance. Capture-block Undo keeps its existing
six-second timeout.
The receipt lives in process memory only; there is no persistent trash/history
or cross-process Undo. Schema remains v27 and backup formats are unchanged.

## Storage and state

`UndoableDeletionRepository` is an additive capability implemented by all four
production Drift repositories. Existing repository interfaces and test fakes
retain their delete contract. A non-capable store does not show a false Undo.

`DriftDeletion` captures exact storage rows and executes deletion in one
transaction. Restoration uses plain INSERT in dependency order, preserving IDs,
unknown/legacy JSON, snapshots, lifecycle/result columns, capture blocks and
execution events. It never replaces a conflicting row. A conflict rolls back
the entire restoration; the same receipt can retry. Rig snapshots retain only
camera/device rows actually removed, so shared live hardware and later edits
are not overwritten. Target aliases are catalog-keyed independent rows and
remain untouched.

Saved-session references are restored only when still null and the remaining
row matches the captured values. A later edit wins, including edits made with
the same timestamp. No saved scientific snapshot is recomputed.

CurrentSession serializes deletion/restoration with autosaves. Deleting its
current entry detaches the ID and unsaved mark, so a later edit creates a new
draft. Undo restores the old identity/mark only when no newer identity or edit
has intervened. Library selection restoration is scoped to the same plan and
selection revision. Active-site Undo restores the site/zone/sky and persisted
selection only if a later position/sky selection has not superseded it.

The captured ScaffoldMessenger keeps Undo available after the entry detail or
editor closes. Failed restoration reports failure and retains **Retry Undo**;
it never shows success. A post-delete list refresh failure cannot discard the
receipt. All visible delete/swipe/editor paths use the shared helper.

## Executed evidence

- `evidence/undo-storage-calendar-tests.log`: 15 passed, initial storage/calendar
  checkpoint. Includes exact graph, same IDs, shared hardware, rollback/retry,
  same-timestamp edit guard, nullable legacy row and physical SQLite reopening.
- `evidence/undo-ui-state-schema-tests.log`: 239 passed. Includes scoped Undo UI,
  route-pop continuation, failed restoration/retry, active selections/current
  session, full existing schema migration/downgrade/floor/rollback guardrails,
  shared confirmation/feedback and selection-refresh tests.
- `evidence/undo-final-tests.log`: 53 passed after final fixes, across the new
  storage/UI/VM tests, calendar and all four existing repository test files.
  Adds refresh-failure Undo retention and edits made while a rig is deleted.
  This log predates the final stored-message lifetime correction; its old
  timeout case has been replaced with Dismiss/replacement tests that also
  assert Undo remains after 30 seconds. Execution of those updated assertions
  is pending the serialized quality gate.
- `evidence/undo-analysis.log`: all 21 owned source/test files clean.

Calendar checks in those logs cover h/min durations, zero/no-dark cases,
selected Hybrid fill in light/dark/field, actual font-width-aware cell height,
200% Monday-aligned weeks across December/January, no accidental adoption,
cache deduplication and explicit adjacent-month error retry.

These are host tests and physical local SQLite readback. Native Android
deletion/Undo and final matching visual evidence remain separate checks owned
by the native validation worker. No final Claude review or owner acceptance
is implied here.
