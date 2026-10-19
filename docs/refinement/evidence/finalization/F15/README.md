# F15 — Browse Moon nights without changing a plan (evidence)

Run: full final-plan group (owner launch 2026-10-18), second cloud session, 2026-10-19.
Environment: Linux container, Flutter 3.47.4 / Dart 3.13.3 (the CI pin). Evidence layer: HOST
tests through the real app and database. **No phone or emulator** (no Android SDK here), so the
phone timing row of A4 is NEEDS ATTENTION, carried to G2.

## What changed

- **Domain.**
  - `night_view.dart` (new): one night as the detail browses it. It holds the timeline at the
    limit, the Sun track, the Moon on the same grid and the moon-free time (ADR-022 N1–N4). From
    these it builds the bar's segments (`SkyState` daylight/civil/nautical/astronomical/dark, Moon
    up) and the state at an instant (`NightInstant`: sky, dark, Moon, the next dark and Moon
    changes).
  - `moon_calendar.dart` (new): a month of nights (phase name, lit fraction, phase longitude,
    moon-free time), using the same `NightView`. Its `MoonCalendarRequest` is sendable and its key
    is N10's (cell, zone, limit, calculator version, month).
- **ViewModel.** `night_browser_viewmodel.dart` (new), per screen, holds the viewed night, the
  month shown and the slider's instant. It runs the month in an isolate (`compute`), caches by N10
  key, and survives a closed screen. A site, zone or limit change resets the cursor. It never writes
  the plan.
- **Presentation.**
  - `night_moon_screen.dart`: the viewed night, with "Viewing … · Your plan: …", "Plan this night"
    (`planThisNight`, N11) and "Back to your plan's night". `NightSummary` takes the dark span and
    the Moon.
  - `night_browser_sections.dart` (new): the shared bar with Moon-up hatched (field mode reads it
    too), a legend, a text alternative, the slider with its readout, and Now / Night start. Then
    the month grid of phase discs and moon-free hours, or the week list at ≥ 150 % text.
  - `sky_darkness_widget.dart`: `NightTimelineSection` and `MoonSection` take a browsed night.
  - `night_text.dart`: `NightBrowseText`.
- **Tests.**
  - new: `test/domain/services/night_view_test.dart` (6) and
    `test/presentation/screens/details/night_moon_browse_test.dart` (6);
  - updated: none.

## Criterion results

| Criterion | Result | Evidence |
| --- | --- | --- |
| CHK-F15.A1 | PASS (TEST); U at F25 | **Domain** (`night_view_test.dart`): segments tile the night, and their dark time equals the moon-free calculation's dark time. The calendar's 17 Dec equals that night's own view (kind, moon-free time, intervals, phase, illumination). N10's key changes with the cell, zone, limit and month, and carries the calculator version. **App** (`night_moon_browse_test.dart` A1): the bar has a legend and a text alternative ("Night bar: Daylight …"). The month grid is computed in an isolate. The calendar's plan night, the detail and the planner's own `moonFree` agree. Week list at 200 % text with no overflow. No-dark (60° N June) and the −12° limit are covered in the domain |
| CHK-F15.A2 | PASS (TEST) | **Browsing:** tapping 17 Dec shows "Viewing Thu, Dec 17 · Your plan: Tue, Dec 15". The plan's night and blocks are unchanged, and "Back to your plan's night" returns. **Adoption:** "Plan this night" on a saved plan makes a copy for the 17th. The saved session keeps its night and an identical snapshot (JSON). The never-saved and Save · Discard · Cancel paths are the shared `planThisNight` (F14 `forecast_nights_test.dart` A6) |
| CHK-F15.A3 | PASS (TEST) | `night_moon_browse_test.dart` A3: while viewing another night with the cursor moved, the site changes to a new active site. The cursor revalidates to the night start; the saved session keeps its night and identical snapshot. Reopening the detail starts on the plan's night, since browsing state is transient |
| CHK-F15.A4 | **NEEDS ATTENTION** (host part PASS) | **Host:** a month computes in about 170 ms synchronously on the container (Dec 2026, Ljubljana, 31 nights), off the UI isolate in the app. **Missing:** the phone timing against the runbook's criterion, on a device (G2). **Resumption:** measure on the phone at G2 |
| CHK-F15.A5 | PASS (TEST) | **Slider:** on another night it starts at the night start ("Night start" offered, "Now" not); on the plan's night "Now" is offered. The readout shows the site-local time, date and zone, the sky, the Moon, and "darkness in …" before the dark versus "dark for another … (until …)" inside it. Moving it changes no plan. **DST:** across 24/25 Oct 2026 the readout names CEST then CET. A site change resets the cursor. No simulator or playback |

## Commands (working tree before the F15 commit)

- `flutter test --no-pub test` → `+2179 ~2 -3`. The three failures were the accessibility sweep's `/night` at 100 % text (light, dark, field): a day cell overflowed by 0.143 px on a phone-width grid. The fix is a scale-down cell, with no other input changed. Then `accessibility_test.dart` and `test/presentation/screens/details` gave `+27: All tests passed!`; that is every test that renders the changed widget.
- `integration_test/core_loop_test.dart -d flutter-tester` → `+2`; `perf_scenarios_test.dart` → `+1`
- `flutter analyze --no-pub` → `No issues found!`; format 0 changed; encoding passed
