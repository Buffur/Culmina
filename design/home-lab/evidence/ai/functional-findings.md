# Night / Moon / Weather / Home-timeline prototype contract

Read-only. I inspected the Flutter code, ADR-022, the roadmap and the prototype files. The Flutter code is a functional reference only. Items marked **[A]** are approved requirements, **[R]** are my recommendations, and **[G]** are gaps in the prototype.

## 1. Prototype gaps [G]

- `design/home-lab/app.js:77-82` has only a static "The night ahead" block: Night 21:15–04:45, Moon "Waning gibbous · 62% lit / Moon-free dark 00:30–04:45", and Weather "15–30% cloud in the dark".
- `app.js:197-199` opens three tiny detail dialogs made of `facts()` plus a demo note. These are not the Night & Moon, Weather or Moon screens.
- There is no timeline, slider, calendar, hourly strip, browse-versus-plan label or "Plan this night" in `app.js`, `plan.js` or `plan-model.js`.
- `app.js:28` and `app.js:51-54` already model plan night versus tonight. The title helpers `pageTitle()` and `nightLabel()` implement AM03-T = B, and the candidate action also follows the plan-night phrase.
- `scenario` already covers ready, unknown, empty, no-site, loading and error (`app.js:21`). Extend it with `no-dark`, `partial`, `stale` and `dst` fixtures. Do not invent a fake-live data source.

## 2. Real data fields to show [A]

**Night and Moon**
- `NightView` (`lib/domain/services/night_view.dart:62-163`) gives the night, `limitDeg` and `segments`. Each segment is `NightSegment{start, end, SkyState, moonUp}`.
- `SkyState` is daylight, civil, nautical, astronomical or dark (`night_view.dart:13`). "Dark" means the Sun is at or below the user's darkness limit, default −18°. It is not a fixed −18°.
- `NightInstant` (`night_view.dart:29-56`) holds the sky, `dark`, `moonUp`, `darkChangeUtc` and `moonChangeUtc`.
- `MoonConditions` (`lib/domain/models/moon_conditions.dart:41-99`) gives `illuminationAtMidnight`, `phaseLongitudeAtMidnightDeg`, `phaseName`, `riseSet` and `upIntervals`.
- `MoonFreeNight` (`moon_conditions.dart:235-302`) gives `kind`, `intervals`, `moonFree` and `dark`.
- `MoonFreeKind` has seven values (`moon_conditions.dart:209-230`): `noDark`, `none`, `allNight`, `evening`, `morning`, `middle` and `mixed`.
- The calendar day is `MoonCalendarDay{date, phase, illumination, phaseLongitudeDeg, moonFree}` (`lib/domain/services/moon_calendar.dart:12-32`).

**Weather**
- `NightWeatherSummary` gives `span` (dark, polarNight or noDark), `fromUtc`/`toUtc`, `coveredHours`, `totalHours` and `complete`. It also gives ranges for cloud (total, low, mid, high), temperature, dew point, wind, gusts, precipitation probability, humidity and visibility, plus the dew-risk hours and `slots`.
- A `NightWeatherSlot` has `timeUtc`, `hour?`, `instant`, `preceding`, `partial`, `precedingMinutes` and `dewRisk`.
- `ForecastNight` (`lib/domain/services/forecast_overview.dart:27-62`) has `coverage` (complete, partial, none or noDark), `leadDays`, `missingBefore`, `missingAfter` and `gaps`.
- `NightWeather` states are Idle, Loading, OutOfRange, Unavailable(failure) and Available (age, `refreshFailed`, snapshot with provider/model/`fetchedAtUtc`).

**Existing wording to reuse.** These strings are the prototype's source of truth for copy:
- `lib/presentation/shared/night_text.dart:72-148` covers `WeatherText`: span, coverage, lead, dew, `notSeeing`, loading and outOfRange.
- `night_text.dart:153-228` covers `DarkText` and `MoonText`: `phaseName`, `moonFree`, `duringDark`.
- `night_text.dart:257-305` covers `NightBrowseText`: `viewing`, `cursor`, `bar`.

## 3. Required visible hierarchy [A unless marked]

### Night & Moon detail (F15 A1/A5; SP07, AM-01)
Reference: `night_moon_screen.dart:50-128`, `night_browser_sections.dart:23-120`.

Order:
1. Header: "Night of Tue, Nov 10 · {site}" with the zone named once.
2. If the viewed night differs from the plan night: a **"Viewing Thu, Dec 17 · Your plan: Tue, Dec 15"** line, then **Plan this night** and **Back to your plan's night**.
3. Summary: the dark span ("Dark (Sun below −15°): …") and the Moon-up line.
4. **"The night at a glance"**: the shared bar, in two rows.
   - Top row: sky state by segment.
   - Bottom row: Moon-up, hatched as well as coloured, so it works in field mode.
   - Under the bar: start and end labels, then a legend (Daylight / Twilight / Dark / "Moon above the horizon (hatched)").
5. Time slider on a 5-minute grid with a live-region readout:
   - Format: `{time}, {date} ({zone}): {sky} · Moon above/below the horizon · dark for another X (until T)` or `darkness in X (from T)`. Then "; the Moon sets/rises at T".
   - Button: **Now** only when now lies inside the viewed night; otherwise **Night start**.
6. Sun timeline with the twilight names, then the Moon section.
7. Moon calendar: month grid with Mon-first weekday headers. Each cell shows the day, a phase glyph (drawn from phase longitude) and the moon-free hours ("1.5 h", "0 h", "no dark"). Selected and plan-night cells are marked, the plan night with "•". At text scale ≥ 1.5 the grid becomes a week list of full sentences (`dayLabel`, `night_browser_sections.dart:251-262`).

### Weather detail (F14 A3; SP07)
Reference: `weather_detail_screen.dart`, `weather_forecast_widget.dart:202-348`, `forecast_nights_section.dart`.

Order:
1. Summary line.
2. Selected night's dark span plus a "Times in {zone}" caption.
3. Facts line: cloud range, temperature, dew point.
4. Coverage line, only if partial or none.
5. Lead time, shown separately from the freshness/age line.
6. Dew line.
7. **Hourly visualization** on the night/dark time axis:
   - Cloud graphic.
   - Temperature with dew point.
   - Compact wind/gust row.
   - Precipitation row.
   - Selecting an hour shows its exact values in a live region. This includes the low/mid/high cloud layers, humidity and visibility.
   - A trailing note says precipitation and gusts are for the preceding hour, and `*` marks a partial hour.
8. `notSeeing` text plus a user-opened **"Look at Clear Outside"** link.
9. **Details** collapsible: full ranges table, model/provider, retrieved time and age, and Open-Meteo attribution (CC BY 4.0).
10. **"Coming nights"** cards below the detail. Each card has a title, "· your plan's night" when it matches, the dark span, coverage text and a cloud range. The lead time and a **Plan this night** button sit in the expanded body.
    - The button is absent on the plan's own night.
    - The cards stop at the forecast's last row, with a "No forecast from {date}: beyond the 16-day forecast" line.

### Moon
There is no separate Moon route. Moon content lives on Night & Moon, plus the Home Moon row. Do not invent a standalone Moon screen. The phase name is a label only and never substitutes for the moon-free intervals (N5).

### Home night card (F17 A1/A5; SP02)
- Title: "Tonight" on the current night, otherwise "Night of Oct 20" (AM03-T = B). The tab label stays "Tonight".
- Next: the tappable site / night / zone context, then the night card, then Your plan / Open planner, then the secondary candidates action.
- Night card rows (`tonight_home_screen.dart:433-489`):
  - **Night**: dark interval plus "Times in {zone}".
  - **Moon**: phase and "% lit at midnight", then the `moonFree` sentence.
  - **Weather**: "Cloud in the dark X–Y%", the coverage line and the freshness line.
  - Each row opens its detail.
- Wind, gust and dew stay secondary (SP02).
- Home has no New plan action.

### Home timeline [R]
SP02 and F17 do not require a Home timeline. The user asked for one, so I recommend it as follows, keeping F15's contract:
- Place it inside the night card, after the dark/Moon rows. It is a compact version of the same shared bar: one band for dark, twilight and daylight, with Moon-up hatching.
- Add a single read-only slider and the same readout sentence as `NightBrowseText.cursor`.
- Keep a legend, a text alternative and a Now/Night start button. Keep the bar's text alternative equal to the readout facts.
- Moving the slider writes no state beyond transient view state.
- Show it only for the plan's night on Home.

## 4. Browse versus adopt boundaries [A: N11 / SP08 / D9 A]

| Action | Effect |
|---|---|
| Home subtitle site/night picker; Planner context | Edits the active plan. Picker Cancel changes nothing. |
| Calendar day, month/week navigation, slider, "View this night", forecast card open/expand | Transient viewing only. Writes no plan, snapshot or result. |
| **Plan this night** (only in a browse view) | The only adoption action. |

Adoption outcomes (`DECISIONS.md:5285`, `5291`; N11):
- **Never-saved draft:** the night changes. Feedback: "Plan moved to Fri 18 Dec".
- **Saved, unchanged plan:** a guarded copy. Feedback: "Copy made for …; the saved plan is unchanged".
- **Saved with unsaved changes:** Save / Discard / Cancel first.
  - Cancel and a Save failure stop the operation.
  - Discard restores the saved state, then copies.
  - Save writes normally, then copies.
  - The source is never retimed.
- Back without adopting changes nothing.

Always show both contexts when they differ: "Viewing … · Your plan: …". Under D9 A the Home card and Your plan always describe the plan's own night. Do not show a browsed night's forecast beside an unlabeled plan.

## 5. State behaviors

**Missing / Unknown**
- No site: the Home prompt reads "Set up your observing site to see tonight…" with **Use current position** and **Set site**. Night & Moon shows "Set a site to see the night." No night is computed for a default location.
- Weather states and their copy (`WeatherText`):
  - Idle: "Set a site…".
  - Loading: `loading` text.
  - OutOfRange: `outOfRange`; planning still works.
  - Unavailable: "No forecast." plus the failure reason and a **Retry** button.
- A missing variable shows "—" or "no forecast". It is never 0% or clear.

**Partial / gaps**
- Coverage text reads "Forecast for X of Y dark hours; the rest have no forecast", or "Cloud: N h without forecast".
- Hour-strip gaps render as "no forecast" columns. Do not interpolate.
- Partial hours carry `*` and "N min of that hour in the dark span".

**Stale / offline**
- Show the retrieval age ("Updated 3 h ago") and the lead time ("Forecast made 2 days ahead") as two separate facts. Neither is a reliability score.
- A failed refresh with a cached forecast reads "Offline, showing the cached forecast." or "Refresh failed, showing the cached forecast." The freshness line carries a history icon and is bold.

**No-dark**
- This is a known absence, not missing data. Examples:
  - "No dark time this night (Sun below … never); no hours are summarized."
  - "No dark time this night, so no moon-free time."
  - Home: "none {phrase}".
  - Calendar cell: "no dark".
- Polar night reads "Dark … for the whole 24 h window".
- Moon cases: "Moon up all night", "Moon below the horizon all night", "from noon" and "noon" at the ends of the window.

**DST**
- All times are rendered in the site zone with the zone named once. Dates use `eveningDate` / `wallClock`. A time on the next calendar day gets a "(+1)" suffix (see the `DarkText.span` example).
- The prototype fixture should include a night crossing a DST change (23 or 25 hours). Check that the bar's x-axis is proportional to real minutes, not the wall clock, and that slider steps are real 5-minute UTC steps.

**Cursor reset**
- A site, zone or darkness-limit change resets the cursor to Now (when inside the night) or to Night start. The viewed date stays (`night_browser_viewmodel.dart:62-72`).

## 6. Do not invent

- No score, "good night" threshold, impact %, colored good/bad cloud bands, reliability %, or seeing/transparency forecast.
- No playback, simulator or animation of the sky.
- No UV/AQI/feels-like dashboard and no new provider.
- Clear Outside opens only on explicit user tap.
- No fixed −18° in text. Use the user's limit.
- No standalone Moon screen, "Astro Score", or Home-subtitle browsing (that is the rejected D9 alternative).
- No second plan store.
- Visuals: follow the approved restrained Hybrid Notion + Journal direction. Do not copy Flutter's Material card/chart look.

## 7. Finite acceptance checklist

1. Home has the title rule (Tonight / "Night of …"), a tappable site/night/zone context, a night card with Night + Moon + Weather rows, Your plan / Open planner, and a secondary candidates action. No New plan.
2. Home timeline: compact bar with legend, text alternative, a read-only slider, a readout sentence and a Now / Night start button.
3. The dark interval and the readout use the user's limit.
4. The Night & Moon screen follows the section order in §3.
5. The shared bar is hatched and coloured, so it reads in field mode and in the red, light and dark themes.
6. The slider covers time-until-dark versus time-left-in-dark, and the Moon rise/set text.
7. The calendar has weekday headers, phase glyph, moon-free hours, plan and selected markers, and previous/next month. At 125% and 200% text it becomes a week list of full sentences.
8. A "Viewing … · Your plan: …" line appears whenever the viewed night differs from the plan night, with **Plan this night** and **Back**.
9. The adopt dialogs cover draft, saved-unchanged and saved-dirty, including Cancel and Discard, with the three exact feedback strings.
10. Back, Cancel, restart and a site change leave the plan unchanged and the derived UI consistent.
11. Weather leads with the selected night's facts and the hourly graphic (cloud, temperature with dew point, wind/gust, precipitation) with hour selection and exact values. The Details collapsible holds layers, humidity, visibility, model and age.
12. Weather shows the lead time and the freshness separately; the Details section carries the attribution. The Clear Outside link and the seeing/transparency disclaimer are present.
13. Coming nights cards are browse only, with partial and beyond-horizon labels.
14. Fixtures render all of: ready, loading, no-site, error/unavailable, out-of-range, partial coverage, stale/offline cached, no-dark, polar, Moon-up-all-night, `mixed` moon-free intervals, and a DST night.
15. Keyboard operation, semantic labels and a text alternative for every graphic; 200% text produces no clipping.
16. Demo-only labelling: values are fixtures, not live calculations (matches the README line 7 disclaimer).

## 8. Caveats

- ADR-022 N11 and the SP08 renders are the contract. Prototype renders do not count as Flutter acceptance (F13–F18 "UX/state contract" lines).
- The Flutter weather strip is a numeric column table with a cloud bar (`weather_forecast_widget.dart:459-741`). AM-01 and F14 A3 ask for a more readable graphic (temperature and dew-point graphics on the dark axis). That is the room for the prototype to improve on.
- I did not read the 2026-10-18 and 2026-10-19 review files in full. The relevant lines are in the 10-19 table (rows F13, F14, F15, F17 and F18): all are "implemented, awaiting visual/owner acceptance". The Flutter sources I cite match that.