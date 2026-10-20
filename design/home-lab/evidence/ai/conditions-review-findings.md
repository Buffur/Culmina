I found no write path in browsing, and the adopt/save flow is correct. The defects are in the time-slider end, Moon interval ends, weather semantics and Home text. I read the code only and ran nothing. Line numbers are in the files under `design/home-lab/`.

## Verified correct (no action)
- **Browsing is read-only.** Night, calendar, step and slider changes only touch the module variables `viewed` and `cursor` (`conditions.js:36,39–41`). Nothing writes storage until `completeAdoption`.
- **`SessionNight` is right.** `night-model.js:26` uses 10:00Z + 24 h, which matches `meanSolarNoonUtc` at 30°E. The Oct 24 DST night is 24 h UTC, and `localInstant` picks correctly across the Oct 25 change.
- **Adopt/save guard holds.** `requestAdoption` and `adoptViewedNight` give the Save/Discard/Cancel guard only for a saved plan with unsaved changes. A failed save throws before `adoptViewedNight` runs, so no copy is made. The original stays in storage and the archive.
- **Missing vs zero.** `Number.isFinite(null)` is false, so null becomes "Unknown" and a real 0 stays "0".
- **Lead days.** `leadDays` is a calendar-date difference, which matches `ForecastOverview.daysBetween`.

## Defects

**1. Medium. The slider's last position is outside the half-open window.**
- `night-ui.js:10` sets `max = 1440`, which is exactly `night.end`. `SessionNight.contains` and `inside()` are `[start,end)`.
- Trigger: drag to the far right, or run `polar-dark` or `moon-all`.
- Result: `cursorFacts` finds no dark, moon or sky segment, so it reports "Daylight · Moon below horizon" and "Dark time has ended".
- `polar-dark` is therefore wrong, and any night from 25 Oct on (Moon up through `end`, `night-model.js:31`) shows "Moon below horizon". `check_night.mjs:208` asserts clamping to `n.end`, which contradicts the exclusive end.
- Fix: use `max = (dayMs/60000) - 5` and clamp the cursor to `end − 300000` at `night-model.js:50` and `conditions.js:35`.

**2. Medium. Clipped Moon interval ends are shown as real rise/set times.**
- `conditions.js:25` (`moonSummary`) prints `timeLabel(max(x.start,night.start))–timeLabel(min(x.end,night.end))` for every interval.
- Trigger: any night from 25 Oct on (Moon up to `end`) shows "20:35–12:00", implying a set at noon. `moon-middle` shows "12:00–23:00, 02:00–12:00", implying a rise at noon. This is the trap you flagged.
- `cursorFacts` and the rail already exclude clipped ends; only this summary does not.
- Fix: for `x.start<=night.start` print "up from window start", and for `x.end>=night.end` print "still up at window end", with a time only for unclipped ends.

**3. Medium. Weather rows outside the dark span show instantaneous values.**
- `conditions.js:34` (table) prints `value(h.cloud/temp/dew/humidity/visibility/low/mid/high)` for every row from `weatherRows`. That list includes non-instant "preceding-hour only" rows, such as the 05:00 local row after dark ends at 04:45.
- `conditions.js:32` (`selectedHour`) does the same for the "Low / middle / high" and "Humidity / visibility" rows.
- Domain behaviour (`night_weather_summarizer.dart:89–93`): only an instant inside `[from,to]` carries instantaneous values. Elsewhere the same screen already says "Outside dark span".
- The gust and precipitation cells in the table (`:34`) and the strip (`:31`) also skip the ≥30 min overlap check that `selectedHour` applies.
- Fix: gate the instantaneous cells on `h.instant`, and gust/precip on `precedingMinutes>=30`, falling back to "—".

**4. Medium. Weather coverage treats hourly instants as hour-long intervals.**
- `night-model.js:75–78,85` computes `covered`, `status` and the weighted `cloud` from `intersect(h,d)` over `[start,end)`. `ForecastOverview` and `NightWeatherSummarizer` count only instants `t ∈ [from,to]`.
- The status can contradict "N of M hourly samples", which comes from the instant-based `coveredSamples`. Example: dark starts 21:15 local and the 21:00 row is missing. Interval logic says "Partial" (the 45 min after 21:15 is attributed to the 21:00 row), instants say 7 of 7.
- The `polar-dark` night on 20 Oct is a visible case. `sampleCount` (`:81`) is inclusive of both ends, but `:72` drops the row at `h.start == night.end`. It shows "24 of 25" next to "Full dark-time coverage".
- `cloudMin/Max` (`:77`) is a hybrid: overlap first, then a start filter. It also drops a row sitting exactly on the dark end.
- Fix: use `instantRows` for status, `cloudMin/Max` and the cloud mean, and make `status` follow `coveredSamples===sampleCount`. Change `:72` to `h.start<=night.end`.

**5. Medium. "Now" reset uses the wall clock and an off-grid instant.**
- `night-model.js:61` defaults to `Date.now()`, and no caller passes `fixtureNow`.
- Tonight is hard-coded to 19 Oct, so the label depends on when the prototype is opened. Today is 20 Oct, so it shows "Night start".
- `app.js:210` computes `minutes=Math.round(...)` for a non-multiple of 5. A `step=5` range input snaps its thumb while `updateTimeline` draws the cursor and label at the unsnapped minute. They disagree by up to 2.5 min.
- Home's `homeCursors` stores the unsnapped instant, and the next `timeline()` render floors it instead.
- Fix: have `resetCursor` floor to the 5-minute grid from `night.start`, pass `fixtureNow` explicitly, and use the same instant for the slider value, cursor and label.

**6. Low. Home weather line says "Forecast unavailable" when there is no dark time.**
- `app.js:91` keys on `cloudMin===null`. For `no-dark`, `status` is "No dark time" and `unavailable` is true, so Home renders "Forecast unavailable · No dark time · Unknown, not clear".
- Fix: branch on `w.darkMs===0` to "No dark time to cover", and on `loading` or `error` to the status text.

**7. Low. Home and Details disagree under `dst`.**
- Home's `homeNight()` ignores `dst` and shows the plan night, while `conditions.js:18,41` forces 24 Oct.
- Fix: have Home pass the same night, or have Conditions only force 24 Oct when `night` is absent.

**8. Low. A direct URL can fake an unsaved change.**
- `conditions.js:12–13` mutates `active.plan.night/site` from `planNight/site` when no checkpoint exists. `savedSnapshot` was taken before that.
- Opening `conditions.html?planNight=2026-10-21` by hand makes the plan look unsaved, so "Plan this night" shows Save/Discard/Cancel. Save would persist a night the user never chose.
- Fix: apply those params to both `plan` and `savedSnapshot`, or ignore them when a saved plan exists. Home always passes matching values, so this only affects hand-edited URLs.

**9. Low. The night label drops the month across a month change.**
- `night-model.js:17` gives "31 Oct–1" for the night ending 1 Nov.
- Fix: include the month when `nextDate` falls in a different month.

## Test assumptions that contradict the domain source
- `check_night.mjs:21` says the DST night is "25-hour". `SessionNight` is always 24 UTC hours, and `:128–134` correctly asserts 24 h. Only the comment is wrong.
- `:251–258,263–268,275–281` assert the overlap-weighted mean and interval coverage. Example: the 21:00 row weighted for 45 min before dark. `NightWeatherSummarizer` uses instants in `[from,to]` only, so these tests lock in defect 4.
- `:313` asserts `near.ageHours===18` and `retrievedAt-near.retrievedAt===17*H`. `weatherForNight` returns no `ageHours`, and `retrievedAt` is a constant. That test cannot pass as written.
- `:207–209` and `:241` accept `cursorFacts` at `n.end`, which is outside the half-open window (defect 1).
- `:236–248` inject `fixtureNow`, but the app never does (defect 5).
- No test covers the Moon-summary clipping in defect 2. `:230` covers only `cursorFacts` on `moon-all`.

I did not check slider thumb versus SVG cursor pixel alignment, because that depends on the CSS.