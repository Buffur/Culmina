I read all 14 screenshots and the 5 check files. I opened only `workspace.css:1-31`, to confirm how the Hybrid feedback row is styled. I couldn't find where the Home night picker is defined without searching broadly, so I didn't trace that finding to its source.

## Seven-criterion table

| # | Criterion | Result | Basis |
|---|---|---|---|
| 1 | Settings vs saved budget explanation | **PASS** | **Visual:** at 100% and 200%, "Settings defaults differ from the saved budget." sits directly under "Saved · changed", above and apart from "Tight". **Recorded:** `checks.json` says canonical bytes are untouched and a night-only edit is not blamed on Settings. `continuity` says Settings changes don't touch the saved plan. |
| 2 | Assumption sources, Apply/reset, summary | **PASS** (one part unverified) | **Visual:** each field shows "Current: Global default", and the intro says Apply sets all four overrides and global defaults remove them. Summary rows show their sources: Global default, Saved budget, Plan override. The math checks out: 15% of 4 h 15 min is 38 min 15 s, shown as "15% → 38 min 15 s", and "Fixed · 15 min" shows when overridden. **Recorded:** pending sources, reset keeping the saved fallback, Unknown for custom windows, and override removal. **Unverified:** the 4th field and the "example" source label don't appear in any supplied image. |
| 3 | Progress at 200% | **PASS** (disclosure unverified visually) | **Visual (light/dark):** one short intro line, then a clear target → filter → settings hierarchy (M31 4 h 36 min → Broadband 4 h 36 min → setting rows). "ISO not recorded" is kept. **Recorded:** the disclosure starts closed and opens, both filter-group lists match Paper exactly, and Unknown sensitivity stays separate. The open disclosure isn't shown in any image. |
| 4 | Weather age and coverage; Home compact | **PASS** for detail; **UNVERIFIED** for Home | **Visual:** one prominent warning ("Stale snapshot · example forecast, not current conditions."). Coverage reads "7/7 hourly samples in dark time" and age reads "Example updated 19 Oct, 01:00 GMT+3 · 18 h old". The 7 h 30 min figure is the dark window, never "seven hours" of samples. The field-mode 200% render keeps the warning. **Recorded:** ready, stale, partial, offline, unknown, error, loading, missing-variable and no-dark semantics. **No image or check covers the Home Weather widget.** |
| 5 | Evening/following-date labels | **PASS** | **Visual:** "Night of 19 Oct · Ends 20 Oct" on Plan, Weather and the Home picker. Month end shows "Night of 31 Oct / Ends 1 Nov". "(+1)" is kept, and GMT+2 after the DST change is correct. **Recorded:** DST dates, (+1), no plan or draft writes, Paper unchanged. |
| 6 | Hybrid feedback in its own row | **PASS** (one part recorded only) | **Visual:** "Filters cleared." sits between the scroll area and the nav. The long download message at 200% wraps in its own row below the actions. **Recorded:** geometry shows `position: static`, no overlap (scroll bottom equals note top, note bottom equals nav or gesture top) for 3 themes × 2 scales plus the long message. Paper keeps its floating feedback. Inline error/Retry is evidenced only by the Settings restore-failure check, not by a workspace-wide one. |
| 7 | Identical settings file | **PASS** | **Visual:** "Already up to date" with only Close, no Replace. **Recorded:** reordered keys count as identical with no writes. 5.1 vs 5 still offers Replace even though the rounded labels match. Cancel doesn't write, explicit restore writes, and failure/Try again works. Paper keeps Replace. |

## Concrete defects

- **P2: Home "Choose a night" picker scales text unevenly** (`home-date-2.png`, Home → choose night, apparently at 200%). "Apply night" is drawn at roughly twice the size of "Cancel". The intro, the "Evening date" label and the select stay near 100% size. The buttons look mismatched, and most of the dialog doesn't seem to follow the text scale. The check "Hybrid Home/date100/200 labels" verifies the wording, not the sizes. This is from the image only; I didn't find the CSS cause.

No P1 defects.

## Preferences (not failures)

- Identical-settings screen says it's unchanged three times: "Nothing needs to be replaced", "Nothing changed." and the status row's "File checked. Nothing changed." One body line would do.
- Plan shows "Saved · changed" and "Changes are not saved yet." together. It's correct but repetitive.
- Progress at 200% draws a focus outline around the intro paragraph. It's probably programmatic focus on navigation and shows up in the screenshot; it isn't a defect.
- The Fit margin field prefills 38.25 (minutes) while showing a global % source. A hint like "15% of usable window" would make the conversion clearer before Apply locks it as a fixed override.

## Result and limitations

All seven refinements meet their criteria. Two parts are unverified: the Home Weather widget's compactness (criterion 4) and the example-source label (criterion 2). Neither has evidence. The only concrete defect is the P2 picker text-scale mismatch. Remaining limitations:
- This is a browser prototype (headless Edge), not native device acceptance.
- No supplied image shows the opened compatibility disclosure, the 4th assumption field, a non-Hybrid feedback render, or a workspace inline error/Retry state.

## Heuristic re-assessment

Seven flows aren't enough evidence for a new app-wide /40 score, so I'm not giving one. The previous 32/40 stands as the last app-wide baseline. Scoped to these flows only:
- **Status visibility:** the Settings-vs-saved line, factual sample coverage and data age, and the in-flow feedback row all support a 3 → 4 *for these flows*.
- **Error prevention:** the identical-file no-op, plus exact 5.1 vs 5 equality, supports a 3 → 4 *for these flows*.
- **Consistency:** stays 3, since the picker's uneven text scaling works against it.
- **Minimalism:** stays 4, with minor repetition on the identical-settings and Plan status copy.
- **Error recovery:** stays 4 (the Retry path is kept).
- **Others:** no specific new evidence, so they stay unchanged.