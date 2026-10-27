# Product specification

Culmina plans astrophotography sessions and records their outcomes.
This document describes implemented behavior in `lib/`, not a release plan.

## Main flow

Choose site and evening date → choose target and rig → inspect the night →
edit capture blocks → review budget/fit → save → image outside the app →
record a result and review it in Logbook.

## Screens

| Screen | Current behavior |
| --- | --- |
| Welcome | First-run setup and entry into planning. |
| Tonight | Site/night context, Night/Moon/Weather summaries, target selection/candidates, planner access and results due for recording. |
| Plan | Site/night, target and rig selection, capture blocks, opportunity/fit analysis, save, new plan and copy to another night. |
| Target candidates | Evaluates catalog targets against the selected night's conditions and preferences. |
| Night / Moon | Night timeline, darkness and altitude context, Moon information and calendar/night browsing. |
| Weather | Hourly forecast in compact rows or charts, details, local time, provenance, freshness and unavailable/partial data states. |
| Logbook | Saved sessions/results, filters, entry details, result recording, sharing/export and target progress. |
| Progress | Integration and session totals by target/filter from completed non-legacy sessions with recorded block counts. |
| Library | Manage rigs, targets and sites; detail/edit screens and scoped selection flows. |
| Metadata import | Android file selection, metadata review and equipment matching/confirmation before saving a rig. |
| Settings | Appearance, units, planning defaults, privacy, backup/data and About/licenses. |
| Database recovery | Reports unsupported database versions and offers an explicit reset flow. |

Bottom navigation contains Tonight, Logbook, Library and Settings.
Plan and detail/selection flows open separately above those tabs.

## Capture planning

- Ordered light, dark, flat, bias and dark-flat blocks with exposure/count,
  filter and contextual ISO/gain/binning settings.
- Calibration timing policies: in-window, outside-window or reused library.
  Helpers expose inherited settings and mismatch warnings.
- Budget includes integration, frame overheads and applicable optional
  setup, dither, refocus, filter-change and meridian-flip times.
- Camera class, tracking choice/override and applicable in-camera noise
  reduction affect the relevant planning calculations.
- Visibility/darkness/Moon and optional cloud gates determine usable windows.
  Fit compares plan load with opportunity and configured margins.
- Storage distinguishes file evidence, declared/measured sizes and theoretical
  estimates. Relative stacking gain does not claim absolute physical SNR.
- White balance, AF/MF and field provenance can be recorded.
  ISO/gain and AF/MF remain descriptive.
- Draft edits, saved snapshots and changed saved plans are distinct;
  leaving a changed plan offers Save/Discard/Cancel.

## Catalogs, sites and rigs

Targets support designation/common-name/alias search and custom entries.
Coordinates are J2000; unknown size and magnitude stay absent.
Rigs store camera/sensor/optics data, tracking, limits and provenance.
Sites store coordinates, optional elevation/time zone and manual Bortle/SQM.
GPS and a map can select a position; place-name lookup is optional.

Metadata readers cover DNG, JPEG, HEIF still images and FITS.
Recognition of a format does not imply a reader exists for it; unsupported
formats and unreadable files return explicit outcomes. Metadata is reviewed
before it creates or changes equipment.

## Results and data portability

Users report completed-as-planned, partial frame counts, or not done with an
optional reason; notes and observed conditions are optional.
Session snapshots retain saved context for history. Legacy logs remain readable.
There is no dedicated live-tracker screen.

Logbook supports text sharing, portable session-file export and AstroBin
acquisition CSV preview/sharing. AstroBin export is a file workflow.
Settings provides local backup and confirmed restore through a staged restart.

## Offline and presentation

Saved data, bundled catalogs and astronomy/planning calculations work offline.
Forecast retrieval, map tiles and optional place-name lookup use the network.
Weather retains source/fetch-time/cache information and missing-data states.
Night calculations use UTC; local display respects the site's time context.

Appearance supports System/Light/Dark plus a separate red field mode.
Display units and weather presentation are configurable.
The app plans and records; it does not acquire images or control hardware.

See [Architecture](ARCHITECTURE.md) for models/storage and
[Design system](DESIGN_SYSTEM.md) for the implemented visual system.
