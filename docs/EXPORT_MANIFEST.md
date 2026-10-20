# AstroPlan export manifest — version 2

> **Verification stamp:** written 2026-09-24 for TASK 14.3 (commit recorded in
> `docs/ROADMAP.md`), against `lib/data/export/session_manifest_codec.dart`.
> The codec is the source of truth; this document describes it.
> **Updated 2026-09-29 (S8.6):** the `name` key, additive; still version 2.
> **Updated 2026-09-29 (S8.1):** the result keys and the `reported` event kind, additive; still version 2.

A manifest is a UTF-8 JSON file (`astroplan-sessions-<UTC date and time>.json`)
shared from a session's detail (**Export file**, one session) or the Sessions tab
(**Export all**, every saved session, legacy logs included). Import is deferred.

## Conventions

- **Instants** are UTC epoch milliseconds (`…_utc_ms`); never local time.
- **Night key**: `evening_date` (`YYYY-MM-DD`, ADR-007) with `time_zone_id` (IANA,
  or null for mean solar time). The night's UTC window is in the snapshots.
- **Units** are in the key (`exposure_s`, `temperature_c`, `humidity_pct`,
  `focal_length_mm`, …).
- **Unknown is null**, never 0 or a default (SI-008).
- **Snapshots** (`plan_snapshot`, `execution_start_snapshot`) are embedded exactly as
  stored (their own versioned format, `"v": 1`, ADR-014 §4).

## Top level

| Key | Type | Meaning |
| --- | --- | --- |
| `manifest_version` | int | `2` |
| `app` | string | `"AstroPlan"` |
| `app_version` | string | `pubspec.yaml` version without the build number |
| `exported_at_utc_ms` | int | when the file was written |
| `sessions` | array | one object per session, below |

## Session

| Key | Type | Meaning |
| --- | --- | --- |
| `id` | int | the session's id on the exporting device |
| `name` | string? | *(S8.6, additive)* the plan's optional name; null or absent = none (shown as target · night) |
| `status` | string | `draft`, `planned`, `inProgress`, `completed`, `abandoned` |
| `legacy` | bool | saved before v16 (or without a night key): stored text only |
| `evening_date`, `time_zone_id` | string? | the night key |
| `site_id`, `target_id`, `rig_id` | int? | references on the exporting device (may be null) |
| `tracking_override` | string? | *(S7.1, additive)* the plan's tracking override: `untracked`, `tracked` or `guided`; null or absent = the rig's default. A file written before S7.1 has no key and reads as none |
| `plan_overrides` | object? | *(2026-10-20, owner-approved additive)* optional `interframeSeconds`, `outsideSetupSeconds`, `fixedMarginSeconds`, `bytesPerFrame` numbers. Null/absent fields inherit global defaults or storage evidence. Time values are finite and nonnegative; bytes/frame is finite and positive. Fixed margin replaces the global percentage for fit classification. Older manifests without the object read as no overrides. |
| `created_at_utc_ms` … `completed_at_utc_ms` | int? | lifecycle instants (`created`, `updated`, `planned`, `started`, `completed`) |
| `labels` | object | `target`, `rig`, `site`, `session_date_utc_ms` — display labels, never used to resolve references |
| `blocks` | array | `id`, `frame_type` (`light`, `dark`, `flat`, `bias`; *(S7.3a, additive)* `darkFlat`: an app before S7.3a refuses a file that holds one, whole, and imports nothing from it), `filter_name`, `exposure_s`, `frame_count`, `binning`, `gain_kind`, `gain_value`, `calibration_policy`, `confirmed_frames`, `rejected_frames` (counts replayed from `events`; null when the events do not replay); *(F03, ADR-021 C18, additive)* `white_balance` (`{mode, preset, kelvinK, tint}`: mode `auto`/`preset`/`kelvin`/`custom`, preset for `preset` only, kelvins for `kelvin` only, tint as the camera shows it), `focus_mode` (`af`, `mf`), `field_origins` (`{field: {k, d}}`, field one of `frameType`, `filter`, `exposure`, `count`, `sensitivity`, `binning`, `wb`, `focusMode`, `fileSize`; kind `k` one of `entered`, `copied`, `inherited`, `file`, `declared`; descriptor `d`; no evidence values) and `file_evidence` (`{format, read, width, height, bytes, label}`, label a file's basename only). Each is null when unrecorded; a file written before F03 has none of these keys and reads them as unrecorded |
| `results` | object | `planned_light_frames`, `actual_light_frames`, `rejected_frames`, `environmental_notes`, `processing_notes`, `temperature_c`, `humidity_pct`, `cloud_cover_pct`; *(S8.1, additive)* `result_kind` (`asPlanned` = Completed as planned, reported by the user; `partly`; null for a session completed live or before S8.1) and `not_done_reason` (`clouds`, `wind`, `dew`, `equipment`, `other`; null when not given). A file without them reads as none |
| `legacy_values` | object | pre-v16 columns kept for legacy logs: `bortle_scale`, `focal_length_mm`, `aperture_f` (focal ratio), `integration_time_s`, `planned_dark_frames`, `planned_flat_frames`, `planned_bias_frames` |
| `plan_snapshot`, `execution_start_snapshot` | object? | the stored snapshots |
| `events` | array | the run's append-only events (ADR-016 §4), by `seq`: `seq`, `at_utc_ms`, `kind`, `block_id`, `delta`, `reason`, `clock_adjusted`. *(S8.1, additive)* kind `reported`: a result recorded after the night without a run, followed by its counts as `framesConfirmed`; an app before S8.1 refuses a file that holds one, whole, and imports nothing from it |

## Versions

- **v2** (TASK 14.3): this document.
- **v1** (before TASK 14.3; `SessionLog.toJson`): one session, local-time based, no
  status, night key, zone or snapshot. Still readable; it is read as one completed
  **legacy** log.
- Any other version is refused (`FormatException`), never guessed.

## Guarantees (tested)

- An exported file re-parses identically: encode → JSON text → decode → encode gives
  the same JSON (`test/data/export/session_manifest_codec_test.dart`).

## AstroBin acquisition CSV — mapping v1 (F20, 2026-10-19)

A second, separate file shared from the Logbook's menu (**Export for AstroBin (CSV)**, every saved
entry) or an entry (**Export for AstroBin (CSV)**, that entry). It is not a manifest version: the
manifest above is unchanged (TF-01). The app shows the rows in the file's order, with their filter
names and the entries that give none, before **Share CSV**; Cancel shares nothing. Source of truth:
`lib/domain/services/astrobin_acquisitions.dart`; file and share text:
`lib/data/export/share_session_exporter.dart` (`ShareAstroBinCsvExporter`).

**Receiving contract.** AstroBin, "Importing acquisitions from CSV"
(<https://welcome.astrobin.com/importing-acquisitions-from-csv>), read 2026-10-17 (audit 09 CA-08;
RA.R2a's field list). On 2026-10-19 the page itself could not be fetched from the implementing
container (the network policy refuses the host); its rules were re-confirmed the same day from
search results quoting it: a header line first; comma-separated with no spaces around the commas;
`date` as `YYYY-MM-DD`; `filter` the numeric ID of a filter in AstroBin's equipment database, not
a name; `number` (whole) and `duration` (seconds, at most 4 decimals) mandatory; `binning` 1–4;
`gain` at most 2 decimals; `sensorCooling` the chip temperature in °C, whole; `meanSqm` as
measured by a Sky Quality Meter; values are not validated and invalid ones are ignored.
Corroborating community writers use the same header names (psf-guard PR #454,
<https://github.com/theatrus/psf-guard/pull/454>, read 2026-10-19).

**File.** `astroplan-astrobin-<local date and time>.csv`, UTF-8, lines joined by `\n`. Header:
`date,filter,number,duration,iso,binning,gain,sensorCooling,fNumber,darks,flats,flatDarks,bias,bortle,meanSqm,meanFwhm,temperature`.
Every cell is a date, a number or blank, so none is quoted; numbers use a dot, no grouping,
trailing zeros dropped.

**What becomes a row.** Only a recorded acquisition: a completed, non-legacy entry. Its light
frames are the confirmed counts its events replay to (Completed as planned, Partly or a tracked
run). One row per night and light setting: blocks with the same normalized filter (C15), exposure
(integer ms), recorded ISO or gain and, on an astro camera class, binning are one row with their
counts summed; others are separate rows, in plan order. Nights in date order, an unknown date last,
then by entry. A block with no confirmed frame gives no row. Entries that give none, listed in the
preview with the reason: a saved plan or draft ("no result recorded"), a run in progress ("result
not recorded"), Not done ("nothing recorded as acquired"), an old log ("no per-block record"), a
result with no light frame.

| Column | Value | Blank when |
| --- | --- | --- |
| `date` | the saved night's evening date (the snapshot's, else the row's key) | unknown |
| `filter` | always blank: Culmina stores names, not AstroBin IDs (CA-08, M7); the names are in the preview and the share text, in row order ("No filter" for none) | always |
| `number` | the row's confirmed light frames | — (no row without frames) |
| `duration` | seconds per frame | — |
| `iso` / `gain` | the block's recorded ISO or gain (never converted, SI-004) | unrecorded |
| `binning` | the block's binning on an astro camera class (the saved rig's) | other classes, no snapshot |
| `fNumber` | the saved rig's focal ratio | unknown |
| `darks`, `flats`, `flatDarks`, `bias` | confirmed frames of a calibration block (recorded by a tracked run; a manual result records lights only) that covers exactly one row by the whole C15 tuple (`CalibrationMatch.covers`, the saved rig's class; a dark flat through the night's recorded flats) | unrecorded, no snapshot, mismatched or covering several rows |
| `sensorCooling`, `meanFwhm` | — | always (not recorded) |
| `bortle`, `meanSqm` | — | always (the site's values are planning inputs, not measurements of the night) |
| `temperature` | the result's recorded temperature, °C | not recorded |

No AstroBin account, ID lookup, stored mapping or upload is added. Tests:
`test/domain/services/astrobin_acquisitions_test.dart` (hand-written expected lines),
`test/presentation/screens/logbook/astrobin_export_test.dart` (preview, Cancel, Share CSV).
