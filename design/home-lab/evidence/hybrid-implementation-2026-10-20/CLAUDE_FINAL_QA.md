I checked the eight images and the two optional evidence files that exist. `logbook-result-200-qa-fix.json` isn't on disk, so the result-editor verdict rests on its PNG alone. I edited nothing.

## Confirmed corrections

| Prior item | Status | Basis |
|---|---|---|
| P2-1 restore screen contradicts itself | **Resolved** | Image: the toast now reads "Settings file checked… Nothing restored yet", which matches the review. The scope copy now separates saved plans and Logbook (unchanged) from the working Plan budget (updated). The fix for slow or out-of-order file reads (an older read can't overwrite a newer review) is accepted from the focused check in `library-settings.md`; a screenshot can't show it. |
| P2-2 repeated title (target) | **Resolved** | The body heading is now "Catalogue record", not the name again. At 200% the app-bar title still wraps to three lines, which is acceptable at that text size. |
| P2-2 repeated title (result editor) | **Resolved** | The body shows "M31 · Mon 12 Oct" with "Plan context and light frames" collapsed. The "Outcome" legend and all three options are visible above Save at 200%. |
| P2-2 Planning header overlap | **Withdrawn** | `qa-header-geometry.json` shows the header bottom and the scroll top both at 253.671875, with no overlap. The new image shows the title on one line and the first slider fully visible. My earlier reading of a mid-scroll crop was wrong: the content was clipped at the edge of the scroll area, not drawn under the header. |
| P2-3 fit margin in two units | **Resolved** | The help text says the plan uses fixed minutes, the global margin is a percentage of the usable window, and the plan override takes priority. |
| P2-5 Weather polish | **Resolved** | A "Stale snapshot · example forecast, not current conditions" warning sits directly under the answer and is repeated near the coverage line. The rain line reads "0% in sampled hours". The button reads "Reload example". |

## Still open

1. **P2-4 is not resolved in the images I was given.** `qa-home-site.png` says "Choose for the working plan. Save plan records the change." `qa-home-date.png` says "Change the active plan's night. Cancel leaves the draft unchanged." The two sheets still describe different actions (Save vs Cancel) and use different terms ("working plan" vs "active plan"). If these are older captures, a fresh pair of both sheets would settle it. Either way, the correction list's "consistent" claim doesn't match these images.
2. **Small items I can't confirm or that weren't part of this round:**
   - "19 Oct–20" still appears on Weather and in the date picker, and can read as a date range. This wasn't on the correction list.
   - The field-mode icon is the moon on every inner screen, but the Home app bar isn't in these images, so I can't confirm the Home icon now matches.
   - No image shows the rig-name placeholder at 200%.
   - Pop-up messages covering Logbook data weren't re-captured.
   - Minor: "Replace settings" stays enabled when the review says the file matches the current settings. Replacing changes nothing, so this is harmless.

There are no P1 issues. The only actionable P2 is item 1.

## Nielsen heuristics: 32/40 (initial assessment 30, before implementation 29)

| Heuristic | Score /4 |
|---|---|
| Visibility of status | 3 (Weather now shows staleness; Unknown/offline Weather and Home's Weather row are still unseen) |
| Match to the task | 3 |
| Control and freedom | 3 |
| Consistency and standards | 3 (P2-4 is still visible) |
| Error prevention | 3 |
| Recognition over recall | 3 |
| Efficiency | 3 |
| Minimalist design | 4 (was 3; the repeated 200% titles were the stated reason, and they're gone) |
| Error recovery | 4 (was 3; the contradictory restore message was the stated reason, and it's fixed) |
| Help and explanation | 3 (the margin help is better, but not enough for a 4 on its own) |

Both increases follow the reasons I gave in the prior assessment; I haven't added any new scoring criteria. These are expert judgements from isolated localhost screenshots and source notes. They don't cover native or physical-device behaviour, AA contrast, touch-target size, keyboard focus, or the science engine.