# Read-only review: Plan prototype vs the roadmap and the production app, plus Night/Moon/Weather and a Home timeline

I only used Read/Grep/Glob, and no files were changed. The browser fixtures are design evidence only. They don't prove anything about Flutter, the emulator or the device.

## 1. What Plan is missing, compared with the roadmap and the app

**Hierarchy**

- **G1 – The estimates sit too low.** `plan.css:22` sets `.plan-workspace{display:block}`, so on the phone the "Your estimate" panel renders *after* the Rig specifications and Assumptions disclosures (`plan.js:31`). AM-01/SP03 say Capture Plan leads with the frame rows, then four concise outputs (`FINALIZATION_REVIEW.md:1091`; roadmap F18 A1 at `FINAL_COMPLETION_ROADMAP.md:609`).
- **G2 – The target appears three times.** It shows in the identity strip, the Target select and the save bar (`plan.js:31,42`). Production deliberately shows only the night and state in the strip (`home_screen.dart:694-727`), and F18 A1 says "Target appears once".
- **G3 – Only the first missing input is shown.** The `missing` chain at `plan-model.js:74` stops at the first gap. F18 A1 and SP03 (`FINALIZATION_REVIEW.md:1093`) need a working checklist of site, target, rig and capture, each opening its own selector.
- **G4 – The fit answer is thin.** There is no capture end, no actionable limiting reason (only the generic text at `plan.js:31`), and no per-block "what fits" rows. Production has those rows at `capture_plan_widget.dart:331-386` (F12 A2, F18 A6).

**Save, apply and lifecycle**

- **G5 – An invented save rule.** Save is disabled until a light block exists (`plan-model.js:74`, `plan.js:42`). The real rule is site's night, target and rig only (`home_screen.dart:346-348`). F18 A5 and SP03 (`:1097`) forbid adding a new restriction on empty plans.
- **G6 – Edits in the block editor can be lost without warning.** The editor's app-bar ✕ is a plain cancel (`plan.js:29,55`), so a changed block is discarded with no prompt. F06 A6 requires the discard guard on Back for a changed editor. There are also two Apply buttons: one in the form and one in the bar (`plan.js:29` and `:40`).
- **G7 – Some editing actions are missing:**
  - Undo exists only for removal. Production also offers Undo after an edit and after adding calibration (`capture_plan_widget.dart:155-214`).
  - There is no reorder; production uses a reorderable list (`:320-326`).
  - There is no plan ⋮ menu with New plan and Copy to another night (`home_screen.dart:619-682`; F17 A2 keeps the guarded New plan on Planner).
- **G8 – The working draft doesn't survive a reload.** Production autosaves the working plan, and Apply changes the working plan, not the saved one (F06 A7). The prototype keeps the draft only in memory, so a reload drops it.

**Camera-class parameters (AM-04, F06 A5)**

- **G9 – AF/MF is in the wrong place.** It sits in Details (`plan.js:29`), but AM-04 makes it a basic field for Phone/DSLR (`FINALIZATION_REVIEW.md:1113`).
- **G10 – Unknown camera type has no fix.** It shows WB, no sensitivity field, and only "Choose a camera type" with no action (`plan.js:31`). F06 A5 requires a clear camera-class remedy.
- **G11 – Invented default values.** `defaultBlock` starts every block at ISO 800, WB Auto and 60 s (`plan-model.js:21-23`). Switching a new block to Flat or Bias keeps the 60 s exposure, which breaks F06 A3. It also invents ISO and WB records that should stay unrecorded (F06 A4/A5).

**Calibration and estimates**

- **G12 – No calibration workflow.** There is no empty-state "Add light frames" / "Take from a photo", no "Build calibration frames" action, and no missing-flat or mismatch warnings. Production has these at `capture_plan_widget.dart:284-318` and `:419-478` (F09 A2, A6).
- **G13 – Each block row lacks its own integration and a source summary** (SP03 `:1095`).
- **G14 – The fixture's settings aren't all shown.** The "Tight" margin of 15 min is applied silently (`plan-model.js:76`) but missing from Assumptions (F12 A1 analogue). The 30 MB per frame is used for every frame type and camera class without saying it isn't measured (CLAUDE.md: keep theoretical and measured file sizes apart). There is no gain curve or text table in Details (F11 A3) and no link to Settings (F12 A4).

**Conditions**

- **G15 – Plan's "The night ahead" is a static list** (`plan.js:31`). Production has two rows that open Night & Moon and Weather screens (`home_screen.dart:261-284`). Home's condition rows only open a three-fact modal (`app.js:197-199`), not screens.
- **G16 – The same values appear for every night, with no label saying so.** Night, Moon-free and target window all read 00:30–04:45 whichever night is selected.
- **G17 – Small issues on Home:**
  - The Moon row uses the sun icon (`app.js:81`).
  - The in-phone note and toasts mix Ukrainian into the English UI (`app.js:188,200,223,240`).

## 2. Proposed phone composition

Keep the visual direction: restrained Hybrid style, Journal serif only for night headings, open sections with no card borders, tonal greys, existing status tokens only, red-only field mode.

**Plan screen (412 px wide, one column)**

1. **App bar:** ← Plan · field-mode toggle · ⋮ (New plan, Copy to another night; both guarded).
2. **Identity strip:** "Night of Mon, Oct 19 · Saved · changed". No target here.
3. **Answer:**
   - When computable: "Fits · 2 h 31 min needed of 4 h 15 min usable", then the capture end and one limiting reason.
   - When inputs are missing: a checklist of Site / Target / Rig / Light frames, each a 48 dp row that opens its selector. Valid partial results stay visible.
4. **Context rows:** Site and Night as tappable list rows (a bottom-sheet choice and a date picker, not bare selects), plus a single time-zone caption.
5. **Target row** (the only place the target appears).
6. **Rig row**, with a camera-type caption. Unknown shows "Set camera type". A Rig details disclosure holds field of view, pixel scale, specs and the plan's tracking.
7. **Capture plan:**
   - Each block row reads like "Light · L-eXtreme", then "120 × 60 s = 2 h", then "ISO 800 · WB Auto · MF", then a "what fits" line.
   - Each row has an overflow menu: Edit, Move up, Move down, Remove.
   - Below the rows: "Add block", and "Build calibration frames" once lights exist.
   - When there are no blocks: the F09 A6 empty state.
8. **Estimate, directly under the blocks:** a 2×2 grid of Integration · Total time · Storage (example) · Relative stacking gain "×10.95 vs one comparable frame". When there are several comparable groups, show one gain line per group.
9. **One disclosure, "Budget and assumptions":** time inside vs outside the window, overheads, file-size basis, fit margin, the gain table, and a Settings stub that states its global scope.
10. **Conditions:** "Night & Moon" and "Weather" rows that navigate to their screens.
11. **Persistent bottom bar:** the save reason as adjacent text, plus Save plan. It sits above the keyboard.

**Block editor (full-screen route)**

- **Top bar:** ✕ (asks to discard if anything changed) and the title "Add block" or "Edit block".
- **Bottom bar:** a single "Add block" or "Apply changes" button, with the note "Apply changes this plan; Save plan records it."
- **Basic fields by camera type:**
  - **Phone/DSLR:** frame type (segmented), exposure (accepts fractions), frames, ISO, white balance (+ Kelvin), AF/MF/Unrecorded, filter, and a live "= 2 h integration" line.
  - **Astro:** type, exposure, frames, gain, filter.
  - **Unknown:** type, exposure, frames, filter, WB, plus a "Camera type not recorded — Set camera type" remedy and no guessed ISO/gain.
- **Details:**
  - Tint and source (Phone/DSLR).
  - Binning (Astro).
  - Placement (calibration frames only).
- **New blocks:** ISO and WB start unrecorded, or come from the previous light block labelled as a proposal. Switching type resets the exposure for Flat/Bias.

**Night & Moon screen** (functional reference: `night_moon_screen.dart:58-127`, `night_browser_sections.dart:23-149`)

- Header "Night of … · site", the zone caption, and two summary lines (dark span, Moon up).
- If browsing another night: "Viewing Thu · Your plan: Mon", with **Plan this night** (guarded) and **Back to your plan's night**.
- A night bar of tonal steps (daylight, twilight, dark) with a hatched Moon-up row, a legend and a text alternative.
- A cursor slider with a readout: local time, date, zone, current dark/Moon state, and time to or remaining in that interval. "Now" is offered only inside the viewed night; otherwise "Night start".
- Moon section: phase, illumination, rise/set, and moon-free dark intervals (evening / morning / all-night / none).
- A month calendar that switches to a week view at 200% text; tapping a day only browses.

**Weather screen** (F14 A3–A6; `weather_forecast_widget.dart`)

- Cloud in the dark with its coverage.
- "Forecast made N days ahead" kept separate from "updated 1 h ago".
- An hourly strip on the night's time axis with rows for cloud, temperature with dew point, wind/gust and precipitation. Tapping an hour shows exact values. Gaps stay visible as gaps.
- Details: low/mid/high cloud, humidity, the full table, model and source.
- A note that seeing and transparency are not available, plus a Clear Outside link that the lab only describes and never fetches (`WORKFLOW.md:33`).
- Multi-night cards whose action is "View this night" only.
- States: unavailable (Unknown is not 0%), offline/stale, out of range, no dark.

**Home Moon/darkness timeline**

One compact bar under "The night ahead", spanning sunset to sunrise:

- tonal twilight → dark segments, with the Moon-up time hatched above them;
- the moon-free dark span outlined, with start and end times in the site zone below the bar;
- a "Now" tick only when now falls inside the plan's night;
- one hidden text sentence for screen readers ("Dark 21:15–04:45; Moon up until 00:30; moon-free 00:30–04:45");
- the whole bar is one link to Night & Moon.

There is no altitude curve or sky map, and no colour beyond tone and hatching.

## 3. Prioritized acceptance checklist for the browser prototype

R = required to meet the roadmap/AM contracts as translated into the browser. S = my suggestion. Check everything at 412×915, at 100% and 200% text, in light, dark and field themes, and using the keyboard only. Passing these closes no Flutter, emulator or physical-device row.

**P0**

| ID | Kind | Check |
|---|---|---|
| P0-1 | R | The four estimate outputs come straight after the block list, ahead of every disclosure. They are visible without expanding anything (G1). |
| P0-2 | R | Save is enabled with site + target + rig only. An empty capture plan can still be saved, and the reason text sits next to the button (G5). |
| P0-3 | R | The checklist lists every missing input, and each item focuses or opens its control (G3). |
| P0-4 | R | The target appears exactly once on Plan (G2). |
| P0-5 | R | Basic Phone/DSLR fields are type, exposure, frames, ISO, WB and AF/MF (+ filter). Astro shows gain, with binning in Details. Unknown offers a class remedy. There is never a per-block ISO/gain switch (G9, G10). |
| P0-6 | R | ISO and WB stay unrecorded unless entered or proposed with a label. Flat/Bias never inherit the light exposure. Fractions such as 1/14, decimals, 0 denominators and huge values all give a field error, never an exception. Production R2 is the cautionary case (`DEVELOP_IMPLEMENTATION_REVIEW_2026_10_19.md:55-57`) (G11). |
| P0-7 | R | Apply ≠ Save. A changed editor's ✕ or Escape triggers the discard prompt, and an unchanged one closes at once. There is one persistent Apply, and typed values survive validation errors (G6). |
| P0-8 | R | Night & Moon and Weather open as full phone screens from both Home and Plan. Back returns to the same plan and scroll position, and the plan is unchanged (G15). |
| P0-9 | R | The Home timeline has the same values as the Night card and the Plan night. It works without colour (hatching + text), and the "Now" tick is shown only inside the night. |

**P1**

| ID | Kind | Check |
|---|---|---|
| P1-1 | R | Browsing another night shows "Viewing … · Your plan …". Only "Plan this night" changes the plan, and it goes through the Save/Discard/Cancel guard. Back or Cancel changes nothing (SP08 `:1153`). |
| P1-2 | R | The slider readout covers time, date, zone, state and time remaining; Now vs Night start behaves as specified; a no-dark fixture state exists. |
| P1-3 | R | Weather: Unknown is never shown as 0%. Lead time and retrieval age are separate. Gaps stay visible. Tapping an hour shows exact values. Clear Outside makes no network request. |
| P1-4 | R | There is an empty state with "Add light frames", and "Build calibration frames" appears once lights exist. The preview has editable counts, and Cancel writes nothing (G12). |
| P1-5 | R | Undo after edit and after remove. A newer edit invalidates the Undo. Move up/down is keyboard-reachable (G7). |
| P1-6 | R | Every example value says it is an example. Values that don't change between nights are labelled as such. The fit margin and file-size basis are listed in Assumptions (G14, G16). |
| P1-7 | R | Gain is shown per comparable group as "vs one comparable frame", with no SNR wording. |

**P2**

| ID | Kind | Check |
|---|---|---|
| P2-1 | S | ⋮ menu with New plan and Copy to another night, both guarded (G7). |
| P2-2 | S | Persist the working draft under a separate lab key so it behaves like autosave (G8). |
| P2-3 | S | Each block row shows its integration and a short source summary; per-block "what fits" lines (G4, G13). |
| P2-4 | S | Rig details show field of view, pixel scale and the plan's tracking; a gain text table in Details; a Settings stub with a global-scope notice. |
| P2-5 | S | Use Android pickers (bottom sheet, date picker) instead of underlined selects. |
| P2-6 | S | Fix the Moon icon and keep the in-phone text in a single language (G17). |

Out of scope: telescope or camera control, real astronomy or weather calculation in the lab, quality scores, new providers, planetarium views.