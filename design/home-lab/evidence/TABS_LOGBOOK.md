# Logbook tab module: browser prototype evidence (2026-10-20)

Scope: one bounded module of the existing Android browser prototype under `design/home-lab/`. No Flutter/native code, shell, navigation, shared styles, storage keys of other pages, skills, memory, observations or Git state were changed.

## Files

| File | Change |
| --- | --- |
| `design/home-lab/logbook.js` | `export function mountLogbook(root, api)`. The file already existed at the start of this run (an earlier, unreported write); it was reviewed against the production sources below, and one change was made: the snapshot's Rig section no longer shows a "Camera type" row, because the production `SessionSnapshot` detail has no such field. |
| `design/home-lab/logbook.css` | New. Every selector is scoped to `.logbook-view`. |
| `design/home-lab/evidence/TABS_LOGBOOK.md` | This report. |

## Production sources read (functional reference, read-only)

- `lib/presentation/screens/logbook/logbook_screen.dart`: `entryTitle`, `targetAndNight`, delete confirmation, Upcoming/Past groups, search hint, filter panel (Saved/Tracking/Completed/Not done, Target, Site, Nights), Progress row, due-report wording, `_resultWhen`, Record/Edit result actions.
- `lib/presentation/screens/logbook/session_detail_screen.dart` (`_SnapshotSections`): "Plan as saved · taken …", Night span/Times in/Darkness limit/Minimum altitude, Site (Name, Position, Elevation, Bortle, SQM), Target (Name, RA/Dec J2000), Rig (Name, Focal length, Focal ratio, Pixel pitch), `unknown` for missing values.
- `lib/presentation/screens/logbook/progress_screen.dart`: Progress by target, "… from N results", "Last imaged", per-filter totals, empty wording, no goals.
- `lib/presentation/screens/execution/results_screen.dart`: "How did it go?", saved-plan review, Completed as planned / Partly / Not done, per-light-block counts (`_frames`: integer ≥ 0, ≤ 100,000), optional Not done reasons (Clouds, Wind, Dew, Equipment, Other), notes (Conditions and events, Processing notes), the as-planned note, "not yet" start wording, `ResultsText.integration` / `plannedOnly`.
- `lib/presentation/viewmodels/sessions_viewmodel.dart`: `isUpcoming`, `searched` (name, target, site, environmental and processing notes; case-insensitive), `grouped` (Upcoming ascending, Past descending).
- `lib/domain/services/target_progress.dart` (CALC-38): completed, non-legacy entries only; light frames × exposure; per filter, `No filter` for empty names.

## Implemented interactions

- **List**: labelled preview note (example nights, local browser storage, fixed example clock Mon 19 Oct 2026 19:00 Kyiv). Stable search `<input type=search>`: typing only updates the results container, so the caret/IME stay in the field. The Filters disclosure holds State (Saved / Completed / Not done; Completed includes Partly, as in the app), Target, Site and a From/To evening-date range; an inverted range is explained and not applied. Count line, Clear filters, and "Nothing matches" with Clear search and filters. Upcoming (ascending), then Past grouped by month (descending).
- **Rows**: title (name, else target · night), state word plus a mark that only repeats the word, "Result not recorded" when the night has started without a result, rig · site, planned vs recorded integration line, the "from …" start wording for a night ahead, an "Example night" label, and a separate Record/Edit result button.
- **Detail** (`setHeader(title, back)`): the result first; planned integration and recorded integration are separate; "Plan as saved" read-only snapshot (Night, Site, Target, Rig) with `unknown` for missing values; per block, Planned and Recorded side by side; Notes; "This target so far"; Delete entry.
- **Result editor**: a full-screen form with the saved-plan review, outcome radios, per-light-block whole-number counts for Partly, optional reason for Not done, notes, and Cancel / Save result. Cancel and app-bar Back ask "Discard your changes?" when the draft differs; `beforeunload` also guards it. Validation is inline with `aria-invalid` and focus on the first error. Save replaces only `result`; the plan snapshot is deep-frozen and never rewritten. A form opened on an entry that another tab changed meanwhile writes nothing and reloads (S4-DEF-08 analogue).
- **Delete and Undo**: a modal confirmation, then one Undo message on the list. Undo puts back exactly the deleted entry, by id, at its earlier index against the freshest stored list, so later edits to other entries are kept; an id that already exists is never duplicated.
- **Progress by target**: from recorded results only (Completed as planned = the planned counts, labelled as the user's report; Partly = the entered counts; Not done and unrecorded nights add nothing). Totals per filter follow CALC-38. Below each filter, groups are split by exposure, sensitivity, binning and rig, and every block with an unrecorded sensitivity forms its own group with a stated limit. No percentages, goals or quality claims.
- **Scenarios** (`api.scenario`): `ready`; `empty` (no entries shown, storage untouched); `error` (simulated load failure with Try again); `storage-error` (save, delete and undo fail without changing anything until retried; the input is kept, and Try again, or Undo pressed again after its failure, clears the simulation).

## Example nights (fixtures, not measurements)

Six entries with `example-*` ids: M31 Partly (DSLR, two blocks); NGC 7000 Completed (astro camera, gain 100 and gain 200 kept apart, plus a Dark block that the result form does not count); M45 Not done (clouds; the phone has no recorded ISO); M31 Completed with one block whose ISO was not recorded; **M33, night ended, result not recorded**; M42 upcoming (Record result is not offered yet). Rig optics are illustrative and use `unknown` where not recorded.

## Persistence

- Only key: `culmina-logbook-preview-v1`, payload `{kind:'culmina-logbook-preview', version:1, entries}`. Before the first change no key exists and the examples are shown.
- Every read and write is in try/catch. A malformed or invalid payload is reported and **never overwritten** automatically; changes then stay in the tab. Replacing it needs an explicit confirmed action. If storage is unavailable, changes also stay in the tab.
- Writes apply the change to a fresh read of the key (no lost edits from another tab). A `storage` event reloads the list unless the editor is open.
- The module does not read or write `culmina-plan-preview-v1`, navigation checkpoints, other tabs' keys or any app database. It creates no production session IDs or routes; ids match `^(example|local)-[a-z0-9-]{1,64}$` and are escaped in selectors with `CSS.escape`.

## Deviations from production (recorded, not hidden)

- Production deletion says "This can't be undone" and has no Undo; this task requires Undo, so the prototype adds it.
- Production Progress lists per-filter totals only; the sub-groups by comparable settings are a prototype addition that this task requires, and they never merge unknown sensitivity.
- Not modelled: Tracking state, swipe to delete, Share, Export/AstroBin menu, the Budget and Weather snapshot sections, "At the start of imaging" snapshots, pending-changes resolution, the optional temperature/humidity/cloud fields, and dawn-based night end (CALC-44). The example night key's end stands in for that, and no example night falls in between.
- Notes are capped at 4,000 characters (a prototype guard only).

## Verification

Not run: no browser, Node or test execution was available or done in this run (the session had no shell or browser tool). The JS was reviewed by reading only; layout at 100%/200%, themes, focus and dialog behaviour are **unverified**. Next: the parent should load `workspace.html?tab=logbook` through `scripts/serve_preview.py` on `localhost` and check the scenarios, reload persistence and 412 px / 200% layout.
