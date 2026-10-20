# Culmina Hybrid (variant=blend): full current design/UX reassessment, browser prototype, 2026-10-20

## 1. Coverage

**Screenshots read:** all 82 images on your list, at light, dark and field themes and at 1× and 2× text scale. I also read `SCREENSHOT_MANIFEST.md`. To check specific suspicions I read parts of `workspace.js`, `library.js`, `plan.js`, `preview-bridge.js` and `night-ui.js`.

**The 8 roots and their child families:**
- **Home (Tonight):** the 412 px top and bottom views in every theme; the site, night, candidates and welcome sheets; the empty, error, no-site and loading states.
- **Plan:** the root; the context, target, rig, block, calibration and assumptions editors.
- **Night:** the root and the twilight guide.
- **Moon:** the root, the guide and the calendar.
- **Weather:** the root, the guide and coming nights, the hourly view; the unknown, offline, stale, error, partial and missing-variable states.
- **Logbook:** the list; entry detail and export; progress by target; the result editor; the empty and error states.
- **Library:** the root; the rigs, targets and sites lists, their details and editors; a custom target's detail and edit; site position denied; reading rig metadata from JSON and its review; the empty and error states.
- **Settings:** the root; Appearance, Planning, Privacy, Backup and About; restore review; full prototype backup; the empty and error states.

**What I did not see:**
- The `*-storage-error` captures and the `sky-*` and `root-home-*` (356 px) images. They are in the manifest but not on your list.
- `plan-context.png`, which was superseded by `fresh-plan-context.png`.
- The lower half of the Plan screen as an image: capture plan list, estimate, budget, stacking-gain graphs, rig details and conditions. I judged those only from `plan.js`.
- The Plan screen's no-rig, save-error and unknown scenarios.
- Restore with a real replacement or a failure (only the "Already up to date" case was captured), delete confirmation and Undo, and the leave/discard dialogs.

I did not open the hybrid-seven evidence JSON files. Where I rely on them for Save/Cancel, restore and focus behaviour, that rests on your statement that they are still valid.

## 2. Nielsen heuristic scores (expert review, not a usability study)

| # | Heuristic | Score | Basis |
|---|---|---|---|
| 1 | Visibility of system status | **3** | Saved / Not saved / Saved · changed states, stale-data labels, coverage counts like "7/7", "Nothing applied or saved", explicit scenario notes. Weakened by the Library error root (W2) and a Save button that stays active on a saved plan. |
| 2 | Match to the task and domain | **3** | Strong domain language: "Night of / Ends", "(+1)", moon-free dark, J2000 coordinates, ISO vs gain chosen by camera type, √N gain described as relative only. Weakened by the "Night start" control (W3) and Home Weather leaving out cloud (W4). |
| 3 | User control and freedom | **4** | Cancel/Apply on every editor, "Apply updates the draft, Save plan records it", leave/discard dialog, Undo after delete, "Use global defaults", Copy to another night, a no-op restore that changes nothing. |
| 4 | Consistency and standards | **3** | One shared row/editor/footer grammar across all roots and themes. But: the Settings defaults and the Plan's defaults disagree (W1), three different error-state designs, one crescent icon carrying five meanings (W5), and the Home "Record result" row is styled differently from its neighbours. |
| 5 | Error prevention | **3** | Range-checked inputs, "Unknown values are never guessed", metadata applied only after a per-field review, Save blocked while an edit is open. Applying Plan assumptions turns all four values into overrides, and the Save plan button always looks ready. |
| 6 | Recognition rather than recall | **3** | Settings rows show their current values, the selected target/rig is restated, the timeline has a legend, the calendar shows moon-free minutes per night. The compact time browser has no time axis, and the crescent icon is ambiguous. |
| 7 | Flexibility and efficiency | **3** | Home opens the planner directly, there is a candidates list, the calendar is tap-to-view, calibration frames are added in one batch. Few shortcuts, and secondary screens put a lot of reading before the action. |
| 8 | Aesthetic and minimalist design | **3** | Home, Plan and Night are calm and well ordered; serif headlines are used sparingly; the Weather summary on Home stays compact. Library, Logbook and Settings repeat preview disclaimers. At 2× the Sites and Targets lists show 6–8 lines of disclaimer before the search field. Some messages appear twice (W5 notes). |
| 9 | Help users recover from errors | **4** | Every error state has a retry and says stored data is untouched. A failed save keeps the edits and offers "Retry save". Denied location permission says what to do next. The metadata error says the draft is unchanged. |
| 10 | Help and documentation | **4** | Built-in help where it is needed: twilight limits, what moon-free means, √N vs signal-to-noise, theoretical vs measured file size, what leaves the device, what the field-mode switch is. |

**Total: 33 / 40.** This is a score for the browser prototype as a whole, not for the native Flutter app.

## 3. Remaining weaknesses

### Correctness defects reproduced from source and images

**W1 — Medium. Settings and the Plan show different defaults.**
- **Where:** Settings → Planning summary row vs. Plan → ⋮ → Plan assumptions.
- **Images:** `settings-state-empty.png` and `matrix/settings-light-1.png` say "Nothing saved yet: the app's defaults are shown", with "15% margin · 5 s between frames". `fresh-plan-assumptions.png` shows 7.5 s between frames, a fixed 15 min margin and 15 min setup, labelled "Current: Example default".
- **Cause:** `planningBudget()` returns `null` when no Settings are stored (`preview-bridge.js:21`), so `assumptionSource` falls back to the Plan's example defaults (`plan.js:135-139`).
- **Consequence:** Home says "Time budget uses this plan's assumptions and current global defaults", but the "Fits / 2 h 15 min needed" verdict is computed with values that Settings does not show. This breaks the single source of truth for the budget.
- **Fix:** when nothing is stored, have the Plan use the defaults Settings displays. Or, if the fixture values are deliberate, have Settings say the example plan's assumptions apply until Planning is saved.

**W2 — Low–Medium. The Library error state doesn't show on the Library root.**
- **Image:** `library-state-error.png` looks like a normal Library, including "2 saved" sites.
- **Cause:** `rootView()` (`library.js:570-583`) never checks `S.loadFailed`; only `listView` does.
- **Consequence:** after a failed load the root still shows a record count, and the failure appears only after opening a list. Logbook and Settings show their errors at the root.
- **Fix:** render `loadFailureView` (or a short error above the rows) in `rootView`, and leave out the count when loading failed.

### Presentation opportunities

**W3 — Medium. "Night start" looks like a label but is a button.**
- **Where:** the time browser on Home and on Night and Moon.
- **Images:** `home-412-light-1-bottom.png`, `root-night-light-1.png`, `moon-calendar.png`, `root-night-field-1.png`.
- **Problem:** "19 Oct, 13:00 GMT+3  Night start" reads as "13:00 is when the night starts", while dark begins at 21:15. "Night start" is actually the reset button (`night-ui.js:61`), drawn as plain text. The compact rail also has no visible time axis.
- **Fix:** style it as a quiet button, for example "↺ Window start", with clear separation from the time, and show the rail's start and end labels in compact mode.

**W4 — Low–Medium. The Home Weather line leaves out cloud cover.**
- **Image:** `home-412-light-1-bottom.png` shows "5–6.2 °C · wind up to 18 km/h".
- **Problem:** the Weather screen headline and the Plan's own night row (`plan.js:631`) both lead with "Cloud 19–42% in the dark". Cloud cover is what decides whether imaging is possible.
- **Fix:** keep one compact line but lead with cloud, e.g. "Cloud 19–42% · 5–6.2 °C". Keep the stale/example label as it is.

**W5 — Low. Consistency debt.**
- **Three error-state designs:**
  - Home: icon, bold heading, full-width primary "Retry" (`home-state-error.png`).
  - Logbook and Settings: red inline text and an outlined "Try again" (`logbook-state-error.png`, `settings-state-error.png`).
  - Weather: an outlined "Retry forecast" (`weather-state-error.png`).
- **One crescent icon, five meanings:** brand, field-mode toggle, Tonight tab, Night row and Moon row (`home-412-light-1-top.png` and `-bottom.png`).
- **Smaller items:**
  - The Save plan button stays enabled on a saved plan (`root-plan-light-1.png`, `plan.js:643`).
  - The new-target form says "Values you leave untouched keep exactly what is stored" (`qa-inner-target-editor-200.png`, `library.js:1087`).
  - "Forecast unavailable" appears twice (`weather-state-unknown.png`).
  - The location-denied message appears twice (`site-position-denied.png`).
  - The title "Night of 19 Oct" repeats the date chip directly below it.

Field-theme secondary contrast is your documented tradeoff, so I did not score it. I did not measure the field-theme primary button ("Open planner"), so I make no contrast claim about it.

## 4. Strengths, and changes that would raise the score

**Strengths:**
- Saved vs draft vs viewed is enforced and stated everywhere: "Apply updates the draft. Save plan records it."; "Tap to view; your plan stays unchanged".
- Unknown stays truthful across every Weather state: the unknown state notes that unknown is not 0%; the missing-variable state shows "Cloud cover unknown" and "0 cloud values known".
- Time semantics are explicit: GMT+3, Europe/Kyiv, "(+1)", "Ends 20 Oct", and the twilight-limits footnote.
- Metadata import is reviewed per field (`metadata-review.png`).
- Restore never changes anything silently: the "Already up to date" no-op review.
- Typography stays restrained and works in all three themes and at 2×.

**Changes within existing features that would raise the score:**
- **+1 Consistency, +1 Visibility:** fix W1 and W2. One budget source of truth; the Library error shown at the root.
- **+1 Domain match:** W3 (a clear reset control plus an axis) and W4 (cloud first on Home).
- **Minimalist toward 4:** show each preview disclaimer once per root, in a single caption, and drop it from child lists. Also remove the duplicate messages listed in W5.
- **Error prevention toward 4:**
  - Disable or relabel Save plan when nothing has changed.
  - In Plan assumptions, mark as overrides only the fields the user actually changed.
  - Give error states one component and one wording ("Try again").