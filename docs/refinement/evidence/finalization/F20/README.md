# F20 — AstroBin acquisition CSV (evidence)

Run: full final-plan group (owner launch 2026-10-18), second cloud session, 2026-10-19.
Environment: Linux container, Flutter 3.47.4 / Dart 3.13.3 (the CI pin). Evidence layer: HOST
unit tests (hand-written expected CSV lines) and widget tests through the real app, router and
in-memory database. Verification class: **high risk** (an export format).

## Receiving contract (refreshed at task start)

- Primary: AstroBin, "Importing acquisitions from CSV",
  <https://welcome.astrobin.com/importing-acquisitions-from-csv>. Read 2026-10-17 for audit 09
  CA-08 and RA.R2a (field list: date, filter (ID), number, duration, iso, binning, gain,
  sensorCooling, darks, flats, flatDarks, bias, bortle, meanSqm, meanFwhm, temperature).
- 2026-10-19: a direct fetch from this container failed (`getaddrinfo ENOTFOUND` in WebFetch;
  curl through the agent proxy: `CONNECT tunnel failed, response 403`, connect_rejected — the
  environment's network policy). The page's rules were re-confirmed the same day from two web
  searches quoting it: header line first; no spaces around commas; `date` `YYYY-MM-DD`; `filter`
  the numeric ID of the filter's equipment-database entry (from the filter page's address), not a
  name; `number` mandatory whole; `duration` mandatory seconds, at most 4 decimals; `binning`
  1–4; `gain` at most 2 decimals; `sensorCooling` °C whole, −274 to 100; `meanSqm` as measured by
  an SQM; values not validated, invalid ones ignored. `fNumber` appears in community files built
  for this import (psf-guard PR #454, <https://github.com/theatrus/psf-guard/pull/454>, read
  2026-10-19; a Cloudy Nights example header).
- **Unknowns:** the exact current column order on the page (immaterial: the import is
  header-keyed) and `temperature`'s stated range/unit beyond "temperature" (mapped from the
  result's °C value; an out-of-range value would be ignored by AstroBin, never mis-stored here).
  Nothing contradicts the approved rule, so the Task was not amended.
- Recorded in `docs/EXPORT_MANIFEST.md`, "AstroBin acquisition CSV — mapping v1".

## What changed

- `lib/domain/services/astrobin_acquisitions.dart` (pure): `AstroBinExport.of` — recorded
  acquisitions only (completed, non-legacy; counts from the event replay), rows per night and
  light setting (normalized filter, ms exposure, recorded ISO/gain, astro-class binning), nights
  in date order; `AstroBinSkip` reasons; calibration counts only from confirmed calibration frames
  that `CalibrationMatch.covers` exactly one row (dark flats through the night's recorded flats);
  `rowLines`, `filterNames`; `AstroBinCsv` (header, blank-for-unknown cells, number
  formatting).
- `SessionSnapshot.cameraClass` (the saved rig's class).
- `AstroBinCsvExporter` (domain interface) and `ShareAstroBinCsvExporter` (data: the
  `.csv` file in the temporary folder, `text/csv`, the share text with the rows in order).
- `AstroBinExportViewModel` (prepare one entry or every saved entry; share exactly what was
  prepared), wired in `AppViewModels` and `main.dart`.
- `screens/logbook/astrobin_export.dart`: the preview dialog (rows in the file's order with their
  filter names; "Not included" with reasons; Cancel; Share CSV disabled without rows); the
  Logbook menu item `logbook.astrobin` and the entry button `detail.astrobin` (not on an old log).
- The manifest codec is untouched (TF-01).

## Criterion results

| Criterion | Result | Evidence |
| --- | --- | --- |
| CHK-F20.A1 | PASS (TEST) | `astrobin_acquisitions_test.dart`: completed/partial fixture (rows per filter, a re-spelled filter merged); planned, draft, in-progress, not-done, legacy and zero-frame entries give no rows, each with its reason, and the CSV is the header only; a mixed group (gain, binning, exposure) over two nights given out of order. Nothing comes from planned counts |
| CHK-F20.A2 | PASS (TEST) | The same fixtures' hand-written lines: unknown ISO/gain, binning, focal ratio, date, sensorCooling, bortle, meanSqm, meanFwhm and calibration are blank, never `0`; no `,0,` in the mixed CSV; `0.25` s and `139.5` gain with a dot; `number` helper: at most the contract's decimals, trailing zeros dropped, no `-0`. No cell needs quoting (dates and numbers only) |
| CHK-F20.A3 | PASS (TEST); U at F25 | The `filter` cell is empty in every expected line; `filterNames` in row order. `astrobin_export_test.dart`: the Logbook menu previews "1. Ha · 2026-12-15 · 9 × 300 s", "2. OIII · …" and the saved plan without a result; Cancel shares nothing; Share CSV shares exactly the previewed rows, and the share text lists the same `rowLines`. An entry without a result shows "Nothing to export" with Share disabled. No ID lookup, account or mapping store |
| CHK-F20.A4 | PASS (TEST) | `astrobin_acquisitions_test.dart` A4: confirmed darks, flats and dark flats proving the Ha row's whole tuple attach to it; bias covering both rows (ambiguous), a 600 s dark matching no row and the planned-but-unconfirmed OIII flat stay blank; without a readable snapshot (no camera class) no calibration and no binning. A manual result records lights only, so its calibration stays blank. The manifest export is unchanged (`session_manifest_codec_test.dart` passes) |

**Mutation checks** (each reverted afterwards; failures in the two F20 test files): the filter
name in the `filter` cell (4); calibration attached when it covers several rows (1); Not done as a
result (1); binning for an unknown class (1); dark flats through unrecorded flats (1); no
tie-break by entry (0 at first, so the "same night … by id" test was added: then 1); unknown date
first (1); calibration without a camera class (2); trailing zeros kept (6); sharing after Cancel
(2); Share CSV enabled without rows (1).

## Privacy

The CSV holds dates, counts, exposures, settings, the focal ratio and the recorded temperature: no
site name, coordinates or notes. It leaves the device only through the user's own share action,
as the manifest does; nothing is sent automatically. No compliance document changes.

## Commands (working tree before the F20 commit)

- `flutter analyze --no-pub` → `No issues found!`; format 0 changed; encoding passed
- `flutter test --no-pub test` → `+2207 ~2 -2`: the two `retired_terms_test.dart` cases caught
  the retired UI term "Acquisition" (class names and two strings); renamed to `AstroBinExport`,
  `AstroBinCsvExporter`, `ShareAstroBinCsvExporter`, the strings reworded ("recorded frames"),
  then `retired_terms_test.dart`, the F20 domain test and `test/presentation/screens/logbook/` →
  `+39` (the rename touched only those files' identifiers and strings)
- `integration_test/core_loop_test.dart -d flutter-tester` → `+2`, `perf_scenarios_test.dart` → `+1`
- targeted: `astrobin_acquisitions_test.dart` `+7`, `astrobin_export_test.dart` `+2`
