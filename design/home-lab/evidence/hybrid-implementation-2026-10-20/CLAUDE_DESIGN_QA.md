# Hybrid (`variant=blend`) design QA, 2026-10-20

I read all 35 screenshots. I checked three suspected issues in the source: `preview-bridge.js` in full, plus the first lines of `plan.js` and `settings.js`. I edited nothing and ran no commands.

## What this covers
- **Seen:** Home in light, dark and field mode; the site, date, candidate and Welcome sheets; Plan at 100% and 200%; the block, calibration and assumptions editors; Night, Moon and Weather; the Logbook list, detail, result editor at 200% and Progress; Library; the rig, target and site editors at 200%; metadata review; location permission denied (field mode); Settings and its Appearance, Planning, Privacy and Backup pages at 200%; About; the settings-file restore screen; the full backup review.
- **Not seen:** keyboard focus, announcements and URL reload (C02, C14); editing a custom target; optional rig and site fields; text and JSON export; stale-file and rollback failures; the window shown for custom coordinates (C17); Home at 200%; Library pickers inside the Plan; any Unknown, offline or stale Weather state; "Total session time". Several 200% screenshots only show the top of a scrolling form, so I don't count unseen controls as missing.
- The screenshots can't show 48 px touch targets or AA contrast. Field-mode contrast 2.71 is existing documented debt, not a new problem.

## C01–C17
Each line says whether the verdict rests on the screenshots, the source, or inference.

| ID | Result | Basis |
|---|---|---|
| C01 | **Pass** (bundled targets) | Seen: title "Dumbbell Nebula (M27)", no "undefined"; "Bundled catalogue · read-only"; RA labelled J2000. Editing a custom target is unseen. |
| C02 | **Partial** | Seen: Moon calendar says "Tap to view; your plan stays unchanged"; the date sheet exists. Focus and reload can't be judged from images. |
| C03 | **Partial** | Seen: site, date and candidate sheets fill the phone, controls are in English, Cancel is next to Apply. The cancel wording differs between the two sheets (P2-4). Home at 200% is unseen. |
| C04 | **Pass** | Seen: "Moon-free dark 4 h 15 min, 00:30 → 04:45 (+1)" with the calendar on the first screen. Night has disclosures for "Read the time browser" and "Moon intervals & phase", and keeps Europe/Kyiv and (+1). |
| C05 | **Partial** | Seen: Weather opens with its answer; "7/7 hourly rows · snapshot age 23 h 11 min" is shown with Refresh. No stale label is visible on a 23-hour-old snapshot, and the Unknown and offline states are unseen. Home's Weather row is below the first screen. |
| C06 | **Pass** (first screen) | Seen: outcome "Partly" and "1 h 42 min of 3 h planned" come first, then Planned/Recorded per group. The full snapshot further down is unseen. |
| C07 | **Partial** | Seen: Progress groups by target, then filter, then settings; "ISO not recorded" is kept separate; no goals or scores. Future entries are short. At 200% the result editor's title and identity fill about 60% of the screen before the outcome (P2-2). |
| C08 | **Partial** | Seen: name and "What takes the pictures?" come first. Optional manufacturer/model and the full Unknown record are unseen. |
| C09 | **Partial** | Seen: "Coordinates and time zone" group; "choose it separately in the Plan", so no automatic activation. Sky darkness and provenance are unseen. |
| C10 | **Partial** | Seen: assumptions copy separates "Overrides for this plan" from global settings; real switches on Appearance and Privacy; "What leaves the device" disclosure; About links on separate lines. The Planning 200% screenshot is mid-scroll, so the first control is unconfirmed, and its header overlaps the content (P2-2). |
| C11 | **Partial** | Seen: "Needed in imaging window: 2 h 15 min" is distinct from "2 h integration"; Apply changes, Save plan and Save result are distinct; provenance ("Records: Recorded example") sits below the main text. "Total session time" doesn't appear in any screenshot. |
| C12 | **Partial** (pass on source) | Source: `preview-bridge.js:29-38` copies the chosen record into the plan as a snapshot, and IDs carry a `library:` prefix, so later Library edits can't change the plan. The pickers themselves are unseen. |
| C13 | **Pass on source** | `preview-bridge.js:20-28`: no saved preferences returns `null`, so the old fixture stays; setup switched off counts as 0 when preferences exist; only the three named preferences are applied; the margin percentage is taken of the usable window. That override values win was not checked (`assumptionsFor`). The screenshots are consistent: Settings shows "Nothing saved yet" and Plan shows "Saved". |
| C14 | **Unseen** | Can't be judged from screenshots. |
| C15 | **Partial** | Seen: Welcome; the JSON review shows "Unknown → 6248 …", "Nothing applied or saved" and "Save rig is still required"; location denied leaves coordinates unchanged, offers manual entry, and says there are no map tiles. Export is unseen. |
| C16 | **Partial** | Seen: the review lists the five records with counts, says "Not stored" means defaults and that other browser keys stay unchanged, offers "Download current data first" and Cancel/Confirm, and shows "Nothing has been restored". The settings-file restore is a separate screen. Stale-file and rollback failures are unseen. That restore screen also contradicts itself (P2-1). |
| C17 | **Inferred pass, visually unseen** | `preview-bridge.js:28`: a custom target or site passes no usable window, so no fit margin is calculated. Not checked in any screenshot. |

## P2 issues still open (no P0/P1 found)
1. **The restore-settings screen contradicts itself** (`qa-settings-json-confirm.png`). The review says "Nothing: the file matches your current preview settings" with "Replace settings" enabled. At the same time a message reads "The file was not applied: this file is not a Culmina preview settings file, or it is damaged". This is probably a leftover message from an earlier invalid file (inferred, not traced in `settings.js`). Either way the user can't tell which state is true. Clear the message when a new review starts.
2. **Headers at 200% text.** Titles wrap onto two or three lines and then repeat as the body heading: target detail ("Dumbbell Nebula (M27)" twice), result editor ("How did it go?" twice), Backup. On Planning at 200%, the scrolled "−15°" option shows under the "Planning" title, so the header overlaps the content.
3. **Fit margin uses two different units.** Settings says "15% margin"; the plan's assumptions say "Fit margin (minutes) 15". The source converts on purpose (percentage × usable window), but the screen doesn't explain the conversion or say which value applies.
4. **The Home sheets word Cancel differently.** The site sheet says "Save plan records the change"; the date sheet says "Cancel leaves the draft unchanged". They do the same thing, so the wording should match.
5. **Small polish items:**
   - Weather "Rain chance up to 0%" reads oddly.
   - A 23-hour snapshot labelled "Full dark-time coverage" has no stale wording in view; check the stale threshold.
   - Pop-up messages cover data on Logbook detail and Progress.
   - The red-mode toggle shows a sun icon on Home but a moon on inner screens.
   - At 200% the rig-name placeholder is cut off.
   - "19 Oct–20" can read as a range.

The current global settings marking a saved plan as changed is intended behaviour (C13), not a bug.

## Nielsen heuristics: 30/40 (prior 29/40)
These are my expert judgement from screenshots and source, not measured usability.

| Heuristic | Score /4 |
|---|---|
| Visibility of status | 3 |
| Match to the task | 3 |
| Control and freedom | 3 |
| Consistency and standards | 3 (was 2: Home sheets now fit the phone; issues 4 and 5 remain) |
| Error prevention | 3 |
| Recognition over recall | 3 |
| Efficiency | 3 |
| Minimalist design | 3 (not 4 because of the 200% title duplication) |
| Error recovery | 3 (issue 1 stops a 4) |
| Help and explanation | 3 |

The one-point gain comes from consistency. Nothing here supports claims about native behaviour, the science engine, real devices or AA contrast.