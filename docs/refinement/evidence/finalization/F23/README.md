# F23 — Finish existing provider labels and bundled notices (evidence, partial)

Run: full final-plan group (owner launch 2026-10-18), continued in a second cloud session on
2026-10-18. Environment: Linux container, Flutter 3.47.4 / Dart 3.13.3 (official Linux archive,
the CI pin). No Android SDK, emulator or phone here.

Rows done in this session: A1, A5, A6, A7. A2–A4 are not started or partial (A2/A3 follow F14/F21
for the final notice/policy alignment).

## Changed files

- `lib/data/services/nominatim_reverse_geocoder.dart`: `placeNameKeys`, the first non-empty
  text of `city`, `town`, `village`, `municipality`, `county`, `state` (A1, TD-097).
- `lib/presentation/screens/sites/site_editor_screen.dart`: a fix from "Use current position"
  fills the coordinates only if neither changed since the tap; otherwise a persistent message
  offers it ("Use position"), and the edit stays (A6, CRUX-03).
- `lib/presentation/screens/sites/site_editor_screen.dart` and `site_viewmodel.dart`
  (`lookUpPlaceName`): after a fix fills the coordinates, an empty name is proposed through the
  opt-in lookup; with place names off an inline offer turns the same setting on (A5).
- `lib/presentation/shared/site_label.dart` (new) and its four callers
  (`home_screen.dart` planner context, `tonight_home_screen.dart` context, `welcome_screen.dart`
  site status, `sites_screen.dart` unsaved card): one label — a saved site's name, a looked-up
  name, or "Unsaved position (lat, lon)" (A7, CRUX-04). Welcome also stopped calling an active
  saved site "Current position" (it read only the looked-up name).
- Tests: `nominatim_reverse_geocoder_test.dart`, `sites_screen_test.dart`,
  `test/presentation/shared/site_label_test.dart` (new), `test/support/fake_location_service.dart`
  (an optional pending answer).

## Criterion results

| Criterion | Result | Evidence |
| --- | --- | --- |
| CHK-F23.A1 | PASS (TEST) | `nominatim_reverse_geocoder_test.dart` group "the place name, by key precedence": municipality-only → "Ljubljana" with attribution; village/town before municipality; municipality before county/state; existing city/town/village/county/state precedence; empty and non-text values fall through; no usable key → `PlaceNameNotFound` (coordinates shown). Three cases failed on the previous mapper. Key order checked against Nominatim `docs/api/Output.md` "addressdetails" (raw.githubusercontent.com/osm-search/Nominatim, read 2026-10-18; nominatim.org itself is refused by this container's network policy) |
| CHK-F23.A2 | NOT STARTED | — |
| CHK-F23.A3 | PASS (CODE/DOC check, 2026-10-18); one concrete release blocker reported (row 9, to G1) | TD-031 subitems, each against the current code: see the table below |
| CHK-F23.A4 | Partial: no provider change (A1 maps the existing Nominatim answer; opt-in, attribution, 1 request/s and cache unchanged). U renders for the changed pages are collected in F25 | — |
| CHK-F23.A5 | PASS (TEST); U renders pending (F25); phone row (real GPS + Nominatim) at G2 | `sites_screen_test.dart` group "a name for the position": with place names on, "Use current position" sends one lookup for the fix and proposes "Ljubljana" with "Suggested by © OpenStreetMap contributors"; nothing is saved before Save, then the site saves with that name. A name already typed, or an edited saved site's name, is kept and nothing is sent. A name typed while the lookup runs wins; an answer for coordinates changed meanwhile is ignored. Off: the inline offer explains what would be sent, no request is made, a typed name saves and the setting stays off; "Turn on place names" switches the same setting on and then proposes the name. Not found / failure: an honest line asks for a name, and Save works. All nine failed on the previous editor. `SiteViewModel.lookUpPlaceName` goes through the opt-in wrapper and changes no state. Copy updated: About privacy summary, `docs/privacy/index.md` (Nominatim row, update date), `docs/COMPLIANCE.md` |
| CHK-F23.A6 | PASS (TEST) | `sites_screen_test.dart` group "a fix that arrives after an edit", with a GPS answer the test completes: untouched fields filled; a typed edit kept, Save enabled while locating, the fix offered and applied only on "Use position"; the offer closed → the typed values saved; a map pick during locating kept and the fix offered; leaving the editor before the answer writes nothing (no site, position unchanged, no offer). Three cases failed on the previous editor |
| CHK-F23.A7 | PASS (TEST); U renders pending (F25) | `site_label_test.dart`: typed/picked and GPS-used unsaved positions with the lookup off read "Unsaved position (46.0500, 14.5100)" before and after a restart, with no GPS request on the restart; a looked-up name and its attribution; a saved site's name before and after a restart; the whole app after a restart shows no "Current position" on Home (Tonight), the planner, Welcome or Sites, and the unsaved label (Sites: title plus coordinates). The widget case failed on the previous screens ("Actual: 'Current position'") |

## Commands (working tree before the F23 commit)

- `flutter test --no-pub test/presentation/screens/home test/presentation/screens/tonight
  test/presentation/screens/sites test/presentation/screens/location test/presentation/shared
  test/lifecycle test/presentation/navigation test/presentation/secondary_consistency_test.dart
  test/presentation/viewmodels test/data/services test/core` → one failure, the Sites
  "deleting the active site keeps its position as unsaved" assertion on the old "not saved"
  subtitle; updated to the A7 label and coordinates (same unsaved meaning), then
  `test/presentation/screens/sites` → `+36: All tests passed!`
- `flutter test --no-pub test/presentation/shared/site_label_test.dart` → `+5: All tests passed!`
- `flutter analyze --no-pub` → `No issues found!`
- `dart format --set-exit-if-changed` on the changed Dart files → 0 changed
- `dart run tool/check_encoding.dart` → `Encoding check passed`

A5 commands: `flutter test --no-pub test/presentation/screens/about test/presentation/screens/sites
test/presentation/screens/settings test/presentation/viewmodels/place_name_lookup_test.dart
test/presentation/shared test/presentation/secondary_consistency_test.dart` → `+251: All tests
passed!`; analysis, changed-file format and encoding pass.

## TD-031 subitems (A3)

Checked against the code and lock file on 2026-10-18. Resolved = evidence below; limitation = kept,
non-blocking, stated in `COMPLIANCE.md`; blocker = must be resolved before release.

| # | Subitem (TD-031) | Disposition | Evidence |
| --- | --- | --- | --- |
| 1 | Once opted in, the Nominatim endpoint is built in and cannot be switched without an update | Limitation (non-blocking) | Opt-in, off by default (`settings_viewmodel.dart`, F21 A6 test), ≤ 1 request/s and cache (`nominatim_reverse_geocoder.dart`); a failure shows no name and nothing depends on it; recorded in `COMPLIANCE.md` (Nominatim row) |
| 2 | OSM tile servers are best-effort and may withdraw access; flutter_map's runtime warning about the public tile servers | Limitation (non-blocking) | Attribution on the map and About, the app's own user agent with a contact URL, tiles only for the visible map (`location_picker_screen.dart`; `location_picker_screen_test.dart` "the map shows the OpenStreetMap attribution"); the map picker is optional and typed coordinates work with every tile failing (F24 A2 test); `COMPLIANCE.md` tiles row |
| 3 | The privacy-policy URL is not live | Resolved (earlier evidence) | S13.2: project page, privacy policy and source answered HTTP 200 (PROGRESS "Remote"). Not rechecked here: `buffur.github.io` is refused by this container's network policy (403) |
| 4 | How a GPL-3.0 app ships the CC BY-SA 4.0 OpenNGC catalog | Resolved | `COMPLIANCE.md` licence section: CC's one-way compatibility declaration; the notice ships as `assets/catalog/OPENNGC_NOTICE.txt` and on the About screen |
| 5 | `flutter_timezone` (platform plugin) unverified on a device | Resolved (EMULATOR) | `STAGE_11_EMULATOR_RUNS.md` B6: a new site's zone defaulted to the emulator's America/Los_Angeles. A physical-phone run stays within G2's rows |
| 6 | `timezone` data set `latest_all` (~445 KB) | Resolved (informational) | Chosen so link zones resolve (TASK 7.3); no action |
| 7 | Nominatim user agent without a contact | Resolved | `AppIdentity.userAgent` carries the project URL (`nominatim_reverse_geocoder_test.dart` "sends the identifying user agent") |
| 8 | `sqlite3_flutter_libs 0.6.0+eol` | Resolved | No longer in `pubspec.yaml` or `pubspec.lock`; `sqlite3` 3.5.2 is locked |
| 9 | `material_ui` reported as retracted | **Release blocker, concrete (to G1)** | `pubspec.lock` pins `material_ui` 1.3.0 (transitive, via `go_router` 18.0.1 and `cupertino_ui` 1.1.0, both `^1.0.0`); pub.dev's API lists 1.3.0 as `retracted: true` (read 2026-10-18). 1.4.0–1.7.0 need Flutter ≥ 3.47.0, so the pinned 3.47.4 allows them; `flutter pub upgrade material_ui --dry-run` changes only that package, to 1.7.0. Not changed here: a lock change is a dependency change (V1 high risk) that needs the Android build and owner visual acceptance, which this container cannot provide. Resolve at G1: upgrade (or bound it to the smallest non-retracted version), then the full gate, an Android build and U renders |
| 10 | OSM tiles without attribution, mismatched user agent | Resolved | As row 2 (TASK 7.2, TASK 16.3) |
| 11 | Open-Meteo free tier is non-commercial | Resolved | Free app, no ads, no account (`COMPLIANCE.md`; About privacy summary) |
| 12 | iOS `Info.plist` lacks location/photo strings | Limitation (non-blocking) | `ios/Runner/Info.plist` has no `NSLocation*`/`NSPhoto*` strings; distribution is Android-only (GitHub APK, `RELEASE.md`). Required before any iOS build is distributed |
| 13 | Release signing uses the debug key | Resolved in code; signing itself owner-managed (F26) | `android/app/build.gradle.kts`: the upload key from `android/key.properties` when present; otherwise the debug key with a build warning |
| 14 | `sdk: ^3.13.3` | No issue | Matches the pinned toolchain (Dart 3.13.3) |
| 15 | Repository is GPL-3.0 | Resolved | S12.4 (a): the GPL-3.0 §7 additional permission for Google Play services location in `COMPLIANCE.md` and `README.md` |
