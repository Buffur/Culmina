# G1 — Frozen final acceptance rows and the pre-packaging baseline

Date 2026-10-19, second cloud session, code at `2dcb000` (F25) plus the G1 dependency fix below.
Environment: Linux container, Flutter 3.47.4 / Dart 3.13.3 (the CI pin); no Android SDK,
emulator or phone; outbound hosts limited by the environment's network policy.

**G1 prerequisites (roadmap §3 Stage D):** F01–F25 implementation complete — **yes** (every
task has a commit; open rows are listed below). F10 complete or explicitly deferred by the owner —
**no**: F10 A3 needs a licensed real FITS sample (OWNER ACTION). All locally required
ADR/visual acceptances recorded — ADR-021/022 **yes** (2026-10-18); visual acceptance (F25 A4)
**no** (OWNER ACTION). G1 therefore runs its host rows now and lists the rest; it does **not**
pass as a whole.

**Re-audit (2026-10-19, after this record's first version):** the owner asked whether everything
in the plan is really implemented. The answer is in [`REAUDIT.md`](REAUDIT.md): 16 behaviour gaps (H2 included; TD-110 also resolved)
found and fixed, and the untested or weakly tested clauses covered. The relevant
`STAGE_11_MATRIX.md` rows (roadmap G1: "each F-task A-criterion plus the relevant
`STAGE_11_MATRIX.md` rows") are dispositioned one by one in
[`STAGE_11_ROWS.md`](STAGE_11_ROWS.md). Its one failing host row, H2, is fixed (`c9cd965`).

## Status vocabulary

- **VERIFIED (host)**: the criterion's required evidence is complete on the host layer.
- **IMPLEMENTED**: behavior and its host tests pass; a device/owner/U row is carried.
- **UNVERIFIED**: required evidence missing for a reason outside the code (named).
- **OWNER ACTION**: needs the owner's input, decision or acceptance.
- **DEFERRED**: explicitly deferred by an approved decision.

## Frozen F rows

| Task | Rows | State | Carried rows (where verified) |
| --- | --- | --- | --- |
| F01 | A1–A5 | IMPLEMENTED (A1–A3 TEST, A4/A5 host) | Phone restore rows → G2; U → F25 (done) |
| F02 | A1; A2/A3 | A1 VERIFIED (host); A2/A3 UNVERIFIED | API 26–30 launch, native resources (no Android SDK) |
| F03 | A1–A4; A5 | A1–A4 VERIFIED (host/owner ADR); A5 UNVERIFIED | Real FITS sample (OWNER ACTION) |
| F04 | A1–A3; A4 | A1–A3 VERIFIED (host); A4 UNVERIFIED | Owner DNG/JPEG/HEIC run (`real_samples_test.dart`, OWNER ACTION) |
| F05–F09 | all A | IMPLEMENTED | U (F25 done), W (F25 done), device rows → G2 |
| F10 | A1, A2, A4; A3 | IMPLEMENTED; A3 UNVERIFIED | Real FITS sample (OWNER ACTION) |
| F11, F12 | all A | IMPLEMENTED | U (F25), owner visual acceptance |
| F13 | A1–A5 | VERIFIED (host; ADR-022 owner) | — |
| F14 | A1–A6 | IMPLEMENTED | Live Open-Meteo horizon (below) |
| F15 | A1–A3, A5; A4 | IMPLEMENTED; A4 UNVERIFIED | Phone calendar timing → G2 |
| F16–F21 | all A | IMPLEMENTED | U (F25), W journeys (F25), owner visual acceptance |
| F22 | A1–A3 | IMPLEMENTED (host restoration) | Android process-death run (no emulator) |
| F23 | A1, A3–A7; A2 | IMPLEMENTED; A2 UNVERIFIED | Native notices: Android dependency graph (dl.google.com refused) |
| F24 | A1–A6 | VERIFIED (host; closed 2026-10-19) | — |
| F25 | A1–A3; A4 | IMPLEMENTED; A4 OWNER ACTION | Owner visual acceptance |
| F26 | A1–A5 | not started | Needs G1, an Android build, D6 and owner signing |

## G1 rows

| Row | Result | Evidence / reason |
| --- | --- | --- |
| Host full gate (`dart run tool/check.dart`) | PASS (twice: before and after the dependency fix) | see "Gate runs" |
| Actual green remote CI on the accepted code | UNVERIFIED | The session cannot push (403: the Claude GitHub App is not installed for `Buffur/Culmina`); commits travel as git bundles for the owner to push. After the owner's push, read the CI run for the pushed head |
| Native Android compilation, Kotlin tests | UNVERIFIED | No Android SDK; `dl.google.com` refused (AGP artifacts redirect there) |
| Emulator L1–L6/L8, permissions, offline, release-build behavior | UNVERIFIED | No emulator. Host equivalents pass: `lifecycle_matrix_test.dart` (L1–L5, L4b), `route_restoration_test.dart`, offline map/forecast tests |
| Backup round trip | VERIFIED (host) | `backup_restore_test.dart`, `preferences_round_trip_test.dart` (F21), F01 restore tests |
| Live Open-Meteo horizon | UNVERIFIED | `api.open-meteo.com` refused by the network policy (CONNECT 403, 2026-10-19); host contract tests pass (`forecast_days=16`, `timezone=UTC`) |
| Opt-in Nominatim | UNVERIFIED | `nominatim.openstreetmap.org` refused (403); mapper tested against the documented keys (F23 A1) |
| OSM tiles | UNVERIFIED | `tile.openstreetmap.org` refused; all-tiles-fail behavior tested (F24 A2) |
| User-opened links and About URLs | Partly | `github.com/Buffur/Culmina` 200; `buffur.github.io/Culmina/` (project/privacy), `open-meteo.com`, `openstreetmap.org/copyright`, `lightpollutionmap.app`, `clearoutside.com`, `reddit.com` refused by the policy here (not a site failure) |
| Policy/notices/S12.4 reconciliation with the code | Partly | Privacy and compliance docs updated with F21/F23 changes; native notices pending (F23 A2) |
| TD-031 row 9: retracted `material_ui` 1.3.0 | RESOLVED (host); Android build UNVERIFIED | see "Dependency fix" |

## Dependency fix (TD-031 row 9)

`pubspec.lock` pinned `material_ui` 1.3.0, which pub.dev lists as **retracted** (read
2026-10-19 from `https://pub.dev/api/packages/material_ui`; 1.4.0–1.7.0 are not). `flutter pub
upgrade --dry-run material_ui` changed that one package only; `flutter pub upgrade material_ui`
moved it to **1.7.0** (the lock's Flutter floor to 3.47.0; CI pins 3.47.4). Changelog 1.4.0–1.7.0
(pub.dev, read 2026-10-19): bug fixes and additive APIs (text-scaled SnackBar action overflow,
discrete Slider rounding, semantics fixes, M3 expressive IconButton). Checks: the full gate after
the change passes; the 52 F25 U renders re-shot after it are byte-identical to those before it
(no visual change on any changed surface). The Android build with the new lock is part of the
native row (UNVERIFIED here).

## Gate runs

| Inputs | Command | Result |
| --- | --- | --- |
| `2dcb000` (F25) | `dart run tool/check.dart` | Encoding, Format, Analyze PASS; Test `+2246 ~5: All tests passed!` (the 3 opt-in render tests skipped); E2E `core_loop` `+2`, `perf_scenarios` `+1`; "Quality gate passed." |
| `2dcb000` + `material_ui` 1.7.0 (`e13eccc`) | `dart run tool/check.dart` | the same: all six steps PASS, `+2246 ~5`, "Quality gate passed." |
| `da0f226` (after the re-audit) | `dart run tool/check.dart` | Encoding, Analyze, Test (`+2336 ~5: All tests passed!`), E2E `core_loop` `+2` and `perf_scenarios` `+1` PASS; Format FAIL on one file (`backup_section_test.dart`, whitespace from `9ac8d7b`) |
| `fba6dc9` (that file formatted) | `dart format --output=none --set-exit-if-changed lib test integration_test` (0 changed), `flutter analyze --no-pub` (no issues), `flutter test --no-pub` on the changed file (`+12`) | PASS. The other steps' evidence is reused (V3): the change is whitespace in one test file, whose tests were rerun |

## Disposition

G1 is **not passed**: its prerequisites F10 (FITS sample or owner deferral) and F25 A4 (owner
visual acceptance) are open, and remote CI, native Android, emulator and live-provider rows are
UNVERIFIED in this environment. Every host row that can run here has run and passes; nothing on
the host blocks. Next: the owner pushes the bundle (CI then runs on the pushed head), decides on
the FITS sample / F10 deferral, reviews the renders; then an environment with the Android SDK
runs the native/emulator rows, F23 A2 and F26.
