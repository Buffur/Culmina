I read only the prior QA, the two check files and the five new images.

**The original P2 is resolved.** In `home-date-confirm-2.png` the whole dialog is at the same larger size: title, intro, the "Evening date" label, the select, "Ends 1 Nov", and both buttons. "Cancel" and "Apply night" now match. `feedback-home-checks.json` records 14 px at 100% and 28 px at 200% for the intro text, label, select and both buttons. The select shows only "Night of 31 Oct", and "Ends 1 Nov" sits on its own line below it. Cancel not writing is recorded only (check 10); no image shows it.

**The missing visual evidence is now supplied:**
- **Home Weather compact (criterion 4):** a single widget with one summary line and the stale/example warning. It has no expanded metrics, hourly table or chips. The 200% scale comes from the check record; the cropped image doesn't show it.
- **4th assumption field and Example label (criterion 2):** "Theoretical file size per frame (MB)" is visible, and each visible field shows "Current: Example default". This matches the legacy-plan case in `plan-clarity/checks.json`.
- **Open grouping disclosure (criterion 3):** the "How totals are grouped" text is shown open. It keeps the "integration time, not a measure of signal or image quality" wording.
- **Fixed margin with unknown window:** "Fit margin · Plan override: Fixed · 15 min. Fit unknown until an imaging window is calculated." appears next to "Example usable window: Unknown for custom coordinates". The fixed value is kept and fit stays explicitly unknown.

**Remaining concrete defects in these corrections:** none.

I couldn't verify one thing from the images. In the Example-default case, the Fit margin field shows "15" under "(minutes)". The field's hint says the global value is a percentage. No image shows whether the Example default really is 15 minutes, as opposed to 15% shown as minutes, so I'm not calling it a defect.

**The seven original criteria:**

| # | Status |
|---|---|
| 1 Settings vs saved budget | PASS (unchanged) |
| 2 Sources, Apply/reset, summary | PASS. The 4th field and Example label are now visually confirmed. |
| 3 Progress at 200% | PASS. The open disclosure is now visually confirmed. |
| 4 Weather age/coverage; Home compact | PASS. Home compact is now confirmed visually and by check 10. |
| 5 Evening/following-date labels | PASS. The picker's text scaling is now consistent (P2 closed). |
| 6 Hybrid feedback row | PASS (unchanged). The non-Hybrid render and workspace inline error/Retry are still evidenced only by the check records, not by images. |
| 7 Identical settings file | PASS (unchanged) |

No P1 or P2 defects remain. The prior limitations still apply: this is headless browser prototype evidence, not native device acceptance. I'm not giving a new app-wide score; 32/40 remains the last app-wide baseline. The only effect on the scoped heuristic notes is that consistency in these flows is no longer reduced by the picker mismatch.