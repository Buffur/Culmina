# Quality brief §1–§6.8: independent integration review

Date: 2026-10-20. Reviewer: Claude (Opus), in a fresh session. Scope: the finished browser prototype in `design/home-lab/` (no production Dart). I did a bounded review of the current source against `evidence/ai/quality-owner-brief.md`, and checked its semantic claims against `lib/domain` and the production capture dialog, target search, stacking curve, equipment seed and bundled catalogue.

**Evidence class: source review only.** I ran nothing: no `node --test`, no browser and no screenshots. The main session reports 72 passing model cases and 48 layout cases. I did not reproduce those counts here. `quality-conditions-findings.md` is treated as one agent's account of its work, not as proof.

## Verdict

**No P1 issue and no persistence, data-loss, time, gradient, Moon, graph-normalisation or metadata-claim defect found.** There is one P2 usability defect in the new target search, plus three low (P3) items. Every brief item from §1 to §6.8 is present, or is a deviation the domain model supports (see the table below).

## Defects

### P2-1 Target search rebuilds its own input on every keystroke
- **Source:** `plan.js:701`. The `input` handler for `#target-query` sets `screen.query` and then calls `render()`. That call replaces `#block-screen.innerHTML`, which includes the input itself. `render()` restores focus through `focusKeyOf` (`#target-query`), but it does not restore the caret, the selection or IME composition.
- **Trigger:** editing in the middle of a query (for example, changing "NGC 224" to "NGC 2244"), or typing with a composing keyboard such as Android Gboard word composition or a CJK IME. After each keystroke the caret moves to the browser's default position on the new element, and an active composition is broken off.
- **Why it matters:** search is the brief's §6.1 deliverable. The ranking matches `TargetSearch` exactly, but the field is not reliable to type in.
- **Minimal fix:** for `#target-query`, rerender only the result count and the result fieldset, not the whole screen. Or, keeping `render()`: return early while `event.isComposing` (rerender on `compositionend`), and after `render()` reapply `selectionStart`/`selectionEnd` to the new `#target-query`.

### P3-1 Enter/Go in the search field applies the old selection and closes the screen
- **Source:** `plan.js:698` with `choiceView` (`plan.js:633`). The Apply button is the form's default button (`form="scoped-form"`), so pressing Enter in `#target-query` submits the form. That runs `applyChoice` with the current `draft.target`, which may still be the previously applied target. The screen closes with no message and the typed query is lost.
- **Not corruption:** no unselected target is ever assigned.
- **Minimal fix:** in the submit handler, ignore a submission when `document.activeElement.id==='target-query'`, or when `event.submitter` is not `[data-apply-screen]`. Do not auto-pick the first result.

### P3-2 An astro rig hides a block's existing WB/focus records
- **Source:** `recordsLine` in `plan.js:442`. The gain branch returns only gain and binning.
- **Production rule:** `CameraClass.offersCameraRecords` (`lib/domain/models/camera_class.dart:44-48`) says: "An astro rig's block keeps a recorded value and shows it, read-only."
- **Trigger:** record WB Kelvin 5600 on a DSLR light block, then switch the rig to the astro example. The value is kept in storage (`applyBlock` never touches hidden records) but is no longer shown anywhere.
- **Minimal fix:** in the gain branch, append the same ` · WB … · Focus …` suffix when either value is not `Unrecorded`.

### P3-3 "Moon details" collapses on any rerender
- **Source:** `conditions.js:54`. `render()` rebuilds `#conditions-main`, but the open state of the `<details class="moon-more">` disclosure is not tracked. Clicking Reset, the month or week arrows, or changing the text scale closes the disclosure the user opened.
- **Minimal fix:** keep a `moonMoreOpen` flag set from a `toggle` listener, and emit `open` from it, as `plan.js` already does with `openDisclosures`.

## Brief coverage and deviations

| § | State in source | Notes |
| --- | --- | --- |
| 1 Colour | Present | Semantic variables in `night.css:4-6`. Guidance at `docs/design/QUALITY_COLOR_GUIDANCE_2026_10_20.md` (file exists). Each colour cue is paired with shape or text: the dark bracket, the thin Moon-up bar versus the full Moon-free bar, legend text. |
| 2.1 Scale | Present, consistent | One `timeline()` serves Home, Night and Moon. Gradient stops come from `skySegments`, and the ≤10 min blend is labelled as presentation. The legend lists only the classes that are present. No other night-scale renderer remains (the dashed and hatched rules left in `conditions.css` are weather-chart keys). Thumb alignment checked by arithmetic: input width = W·(max/total)+6 px at −3 px with a 6 px thumb, so the thumb centre sits at value/total·W. |
| 2.2 Night ahead | Present | Night row, then the band attached to it, then the Moon row, then Weather (`app.js:92-97`). |
| 2.3 Weather summary | Present | Built only from eligible `weatherSlots` rows. Gust and precipitation need ≥30 preceding minutes. Unknown stays unknown, and `available:false` rows are excluded. "Rain chance" is the preceding-hour precipitation probability, as the Weather strip states. |
| 3.1–3.3 Night-Moon | Present | Facts are a label-over-value grid; the old flex/space-between rule is gone from every CSS file. Moon intervals are From/Until pairs, clipped at the window edges. `(+1)` comes from the site-zone calendar date (`dayTag`), and the DST night is covered by the model test. Moon-free is shown as a duration plus a clock range plus a classification. |
| 4 Moon | Present | Timeline and calendar first; details are in a closed disclosure at the end. |
| 5 Weather | Present | Order: answer, then trend, then facts, then trust group, then hourly view, then details. Snapshot age and forecast lead stay separate. |
| 6.1 Target search | Present (see P2-1, P3-1) | `searchTargets` mirrors `TargetSearch.designationKey`/`search`/`compareIds` (`lib/domain/services/target_search.dart`). The six sample rows match `assets/catalog/catalog_v2.json` (version 3, 164 `id` entries). The `change` handler excludes `text` and `search` inputs, so the search box cannot assign a target. |
| 6.2 Rig | Present | Icon per `cameraClass`. The astro rig matches `EquipmentSeeder.defaults`: ASI2600MC, 23.5 × 15.7 mm, 6248 × 4176 px, 3.76 µm, 400 mm, 72 mm, f/5.56; optics labelled as estimated. `tracking:null` corresponds to the model's default `TrackingType.unknown`, shown as "not recorded". No invented values. |
| 6.3 / 6.6 WB | Present; **deviation justified** | WB is numeric in Kelvin mode, with 1000–40000 K as sanity bounds. Custom is "measured" with optional tint and no kelvin value, because `WhiteBalance.custom` has no `kelvinK`. Tint (±1000) is offered for every mode except Auto, matching `_tintApplies`. Bounds are enforced at edit time only when WB is touched, so earlier records stay readable. **Camera records appear only on Light blocks.** This matches production: `capture_block_dialog.dart:196` (`offersCameraRecords && _type == FrameType.light`). The mode, Kelvin and tint fields now sit together in the main editor, not under Details, with one source of truth. |
| 6.4 Focus | **Deviation justified**: no slider | `FocusMode` is `{af, mf}`. Its doc (`capture_evidence.dart:132-134`) says "never a numeric focus value, a control command". A graduated slider would imply precision the model does not store. The editor says so when MF is chosen (`plan.js:602`). |
| 6.5 Filter | Present | `newBlock` starts with an empty filter and a placeholder in distinct styling (`plan.css:76`). The recorded example's `Broadband` is kept as a legitimate stored value. |
| 6.7 Gain graph | Present | Three alternatives plus "compare all". A (default) is `StackingGainCurve.of`: 1 frame to max(4, 2N), plan count always sampled, 1.00× at the plan. B and C stay within comparable groups and never combine across groups. Copy keeps "not absolute SNR". |
| 6.8 Workflow | Present | Order: context, then target, then rig, then capture blocks, then estimate, then disclosures, then night. In the editor: type, exposure, frames, filter, ISO/gain, WB, focus, then Details (binning and timing). |

## Checked with no issue found (source)

- **Optional-field migration:**
  - Saved plans or drafts without `kelvin`, `tint` or `focus` validate: `blockProblems` does not require them, and `whiteBalanceText`/`recordsLine` show them as unrecorded.
  - `restoreStack` fills block-draft keys that are missing from `base` (`plan.js:91`).
  - Nothing new is persisted outside `validPlan`.
- **Data integrity:** fields hidden for a class or frame type keep their stored values (`applyBlock`). Save, adoption and the archive paths are unchanged in this pass.
- **No new metadata or science claims:** the storage figure stays "theoretical"; √N stays relative and per group; weather says no seeing or transparency is inferred.
