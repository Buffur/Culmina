# Tonight context controls - TD-120 - 2026-10-23

Owner-directed FIX package. Implemented; host and isolated Android verified. Owner acceptance is pending. The subsequently authorized physical release installation succeeded (see update below). No commit or push.

## Baseline and scope

- Task checkout: `C:/Users/zalub/AppData/Local/Temp/culqa`, branch `codex/tonight-context-controls`, base HEAD and freshly fetched `origin/develop`: `2a43c89981c0f9e0f4d4eddc4a62484c470be928`.
- Main owner checkout stays on its earlier HEAD with its equipment/target edits untouched. Seven pre-existing generated desktop plugin files in the task checkout contain line-ending-only changes and are excluded from this package.
- The owner's annotated phone image authorizes tighter Tonight spacing, a direct calendar, and combined site selection/management. These intentionally amend the accepted web interaction/spacing. The read-only web reference at `86873ce`, accepted in `ed29554`, remains unchanged.
- Existing P-1 through P-6 are delivered, not repeated. QA-03, withdrawn QA-09, QA-10 and the wider roadmap are outside this package.

## Acceptance and implementation

One existing register ID, TD-120, covers this bounded owner refinement; rows below are acceptance criteria, not new QA IDs.

| Surface/state | Reproduction and expected behavior | Cause and minimal change | Verification/risk |
| --- | --- | --- | --- |
| Tonight, a site and night available | Open Tonight. Reduce the two annotated gaps without reducing the context controls' touch area. | Removed 10dp before context and 16dp after it in `tonight_home_screen.dart`. Internal 48dp targets and section spacing retained. | Geometry regression failed before (10 vs0), passes after. Total26dp reduction. Long content still wraps. |
| Tonight date | Tap date: calendar immediately. OK changes the plan night through existing autosave; Cancel preserves date, edits and fit. | `home_context_sheets.dart` now calls existing `pickNight` directly; removed the private intermediate date page and its Apply step. | Confirm/date persistence and Cancel preserving plan/results pass. Failure feedback remains. |
| Tonight site | Tap site: Manage sites directly. Tap a saved-site row to select; use its pencil action for management. | Removed private Observing site page. Reuse `/select/site`; `sites_screen.dart` exposes record management beside each selectable row. Existing add/search/GPS/map/transient/save/delete paths retained. | Direct-route test, manage-without-selection test, site selection/delete/editor tests pass. Library manage mode keeps its record-opening behavior. No GPS was requested on the owner's phone. |
| Tonight calendar at200% | Dates20-31 must remain readable on one line at375dp. | Platform grid with default day typography split digits. Tonight supplies the existing14dp body role via optional `pickNight` builder; user scaler stays2, effective28dp. Other callers keep the default null builder. | Geist-loaded RenderParagraph test checks a two-digit date uses one line and effective28dp. Month/year heading still uses platform ellipsis at200%; full day selection and input toggle remain available. |

Production files: `lib/presentation/screens/tonight/tonight_home_screen.dart`, `lib/presentation/screens/tonight/home_context_sheets.dart`, `lib/presentation/screens/sites/sites_screen.dart`, `lib/presentation/shared/context_line.dart`. Tests: the existing Tonight and Sites screen suites. No calculations, persistence contracts or theme tokens changed.

## Evidence and environment

All paths below are relative to [evidence/tonight-context](evidence/tonight-context). Original captures are retained; images have not been stretched or overpainted.

| Evidence | Files | Environment and state |
| --- | --- | --- |
| Owner observation | Original attachment: `C:/Users/zalub/AppData/Local/Temp/codex-clipboard-3f837e0d-37d9-4a65-bffd-02302df09cec.png` | Physical phone, dark Tonight, Kr/Crab Nebula; no new physical-after claim. |
| Read-only reference | `reference/reference-home-dark.png`, computed styles JSON and web manifest | Chromium,375px frame, DPR1, zoom/text1; Geist and Source Serif4 loaded. Existing capture tool removes1px left/right frame borders and simulated system bars, leaving373x808. No normalization/stretch. |
| Flutter before | `before/flutter-home-dark-375.png`, `before/flutter-home_sitesheet-dark-375.png`, `before/flutter-home_nightsheet-dark-375.png`, corresponding JSON | Baseline2a43c899; host375x760, DPR1, dark, text1. Old intermediate pages preserved as evidence. |
| Flutter after | `after/flutter-home-*-375.png`, `after/flutter-home_sitesheet-*-375.png`, `after/flutter-home_nightsheet-*-375.png`, corresponding JSON | Final uncommitted diff over2a43c899; host375x760, DPR1, light/dark/field, text1. |
| Large text after | Same three frame names in `after-200-final/` | Host375x760, dark, DPR1, text2; original scaler retained. Site page scrolls; calendar grid days stay single-line. |
| Android after | `native-375/android-home-dark.png`, `android-home_sitesheet-dark.png`, `android-home_nightsheet-dark.png`, `integration-report.json` | Isolated `culmina_hybrid_native_qa`, API30 x86_64, debug build, final diff;750x1632 Flutter view, DPR2 (375x816 logical), SafeArea top72.5dp, text1. Raw captures retain top inset; no crop/resize. |

Host and native use existing `hybridTransferFixture`: Kyiv outskirts50.4/30.6, Europe/Kyiv, evening19Oct2026, M31/Andromeda, DSLR135mm, deterministic weather. Geist and Source Serif4 are bundled/loaded. Home starts at top; sheet shots follow real taps. The shared capture tap helper may scroll Tonight to reveal a chip before opening the calendar; the visible background scroll is harness behavior. All animations settle; no pointer hover. Browser data is illustrative, not a numeric production oracle.

## Checks actually run

- Targeted Tonight/Sites areas + shared context picker + Field darkness: **106 passed** (`tests-final.log`). Includes direct calendar confirmation/autosave, cancellation preserving edits/results, direct site route, site management without selecting it, search/edit/delete existing scenarios and48dp geometry.
- Host renders: **3 theme tests passed /9 frames**, plus **1 large-text test /3 frames**. Final calendar day style was separately recaptured at200% after correcting digit wrapping. Screens were visually inspected; no golden baselines changed.
- Hot reload on the final normal debug app succeeded through Dart MCP on the isolated emulator.
- Native capture on isolated emulator: **passed**,3 relevant frames at375dp; inspected all three. Earlier wider540dp run also passed but is not the compact-phone acceptance evidence.
- `flutter analyze --no-pub`: **no issues** on final code. Changed-file format and encoding checks passed; `git diff --check` passed.
- Independent subagent read-only review and follow-up: no blocking regression found; reviewed current diff,106-test log and actual375dp/200% renders. Calendar compact month header ellipsis at200% remains a recorded platform limitation.
- No historical full-suite result is presented as a fresh result. Verification is CLAUDE V1 shared behavior: scoped checks plus existing default-calendar/Field regressions; other callers' builder defaults and their data behavior remain unchanged.
- Harness retry: initial before capture failed because output directory did not exist; rerun passed after creating it. One simultaneous host-test startup could not replace a loaded sqlite3.dll; sequential rerun passed. Neither failure is counted as passing evidence.

## Manual owner acceptance

1. Tonight: compare the annotated gaps; both chips must remain easy to tap.
2. Tap date. Calendar should appear immediately. Select a different date and OK; return to Tonight and verify the night and saved plan. Reopen, select another day and Cancel; the plan must stay unchanged.
3. Tap site. Manage sites should open immediately with saved sites and Add site/search. Select a site row and return; Tonight uses it. Open another row's pencil action: its details/edit/delete are available without selecting it. Back returns to the same list.
4. In Light/Dark/Field and large text, verify labels and controls remain readable. Do not grant GPS permission or request actual coordinates for this acceptance scenario.

Stop after this package. At initial implementation completion, physical installation had not been authorized/performed. The subsequent owner instruction authorizes it as recorded below. Owner acceptance, commit and push remain unclaimed.


## Owner-authorized physical update (same day)

The owner explicitly instructed release-build updates on the connected phone after fixes. Release builds do not support hot reload; this chat now uses rebuild + install-in-place + launch for each completed authorized fix. This does not authorize clearing data, uninstalling, GPS requests, Git delivery or publication.

- Built `flutter build apk --release` from the tested task checkout; success. APK archived at `C:/Users/zalub/CulminaQA/2026-10-23/tonight-context/install/culmina-tonight-release-debug-signed.apk`.
- Package `io.github.buffur.culmina`, version1.0.0+1. SHA256 `faa96548f9631863642150a88b053d6b843187a5d6f5578d79cf2cf945a34434`.
- Verified APK certificate against the pulled installed APK: same Android Debug certificate SHA256 `56d00b35cb297aceabc42aef7033d41a7b5c7a1939e7d14cf7329672f8902dbe`. The pulled APK is an installation artifact, not a backup of user data.
- Xiaomi14T Pro: `adb install -r` returned Success; launch returned Status ok,861ms. No uninstall, data clearing, system-setting change or GPS request.
- Before/after private phone screenshots (archived outside Git at `C:/Users/zalub/CulminaQA/2026-10-24/consolidation/private-evidence/`; see `evidence/tonight-context/physical-install/README.md`) retain the same Kr site,23Oct night, Crab Nebula plan, rig and budget values. Compact spacing is visible after update. This confirms launch and the visible plan state, not exhaustive persistence or physical interaction QA.
- Physical date/site interactions remain untested in this update; previously recorded host and isolated native interaction evidence remains applicable. Owner acceptance is pending.
