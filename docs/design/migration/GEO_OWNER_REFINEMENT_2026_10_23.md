# Geo screenshot refinement — TD-121 follow-up — 2026-10-23

Implemented the owner's four annotated screenshots, verified and installed on the connected phone. Final visual acceptance remains with the owner. No commit/push; logo work and main owner checkout untouched.

## Baseline and scope

Task worktree `C:/Users/zalub/AppData/Local/Temp/culqa`, branch `codex/tonight-context-controls`, HEAD and verified remote develop `2a43c89981c0f9e0f4d4eddc4a62484c470be928`. Previous uncommitted Tonight/geo implementation retained. Seven generated desktop files remain pre-existing line-ending-only changes. The screenshot feedback supersedes the earlier current-site-first and manual-coordinate explicit-lookup design decisions in [the preceding delivery](GEO_FLOW_IMPLEMENTATION_2026_10_23.md).

Reference: owner attachments `C:/Users/zalub/.codex/attachments/0e11e7f1-de1f-45e2-b2c4-f8dd184659ef/image-{1,2,4}.png` and `image-3.jpg`. These are the actual requested states, not a new transfer from the frozen web reference. Web reference and logo sources remain unchanged.

## Requirements, causes and changes

| Owner requirement | Cause → change | Evidence and disposition |
| --- | --- | --- |
| Tonight place and date must not wrap or display excessive names | Coordinates appended to a fallback name made Wrap put the date below. Tonight opts into a constrained Row, single-line ellipsis, short date, and display-only compact place label. Full names/coordinates stay in semantic labels, tooltip and details; no stored name is truncated. `context_line.dart`, `site_label.dart`, `tonight_home_screen.dart`. Other ContextLine adopters retain their layout. | New long Ukrainian-name tests at375dp,100/200%, accessible full labels and48dp targets pass. Final physical XML shows both controls at y431..587. This criterion covers the annotated place/date controls; informational paragraphs retain normal accessible wrapping. |
| Selected saved site belongs in the ordinary list; remove first block | Separate current-site section and transient summary duplicated hierarchy. `sites_screen.dart` renders all saved sites in normal order with selected radio. | Selection/search/manage regressions pass; selected site appears once and remains searchable. No separate Used for planning block. |
| Find a compact honest solution for unsaved coordinates | Replaced large summary+button with one row within the list: Position/resolved name, coordinates and Not saved, selected marker, explicit Save icon. | Proposal implemented as the minimal reversible presentation: no implicit saved record and no lost transient planning ability. Search includes that row; no false no-results message when only it matches. Physical and ordinary emulator200 inspected. Owner may accept or refine this presentation. |
| Map center marker must be much smaller, without large background | 40dp black disk and28dp locate glyph dominated tiles. `location_picker_screen.dart` uses a12dp dot with a2dp semantic contrast edge; no large background, no duplicate glyph. | Marker-size regression passes; dark/light/Field host shots and Android map captures inspected. GPS command remains a separate48dp button. Provider, tile skin and attribution unchanged. |
| New-site spacing, emphasis and placement | Persistent coordinate hints, source captions, standalone lookup button and third footer row broke rhythm. `site_editor_screen.dart` now uses compact visible position commands, paired coordinates with12dp separation,20dp Name/zone groups, compact suffix action and local status only when useful. Save-context copy scrolls with the form; Cancel/Save remain fixed and equal height. | Host all-theme100/200, whole accessibility sweep, phone form and normal emulator confirm geometry. At200% fields stack and body scrolls; fixed actions remain reachable. |
| Names should come automatically from geo | Previously inherited/manual coordinates kept a fallback until a button tap. New drafts automatically enrich inherited/GPS/map points, and valid manual coordinates700ms after typing stops. Existing known temporary name is reused. Manual/stored names are protected; latest generation wins. | New inherited/pristine, debounce, consent/cancel tests and existing precision/race/manual-name tests pass. Final phone Add opens with Kryvyi Rih without typing. Lookup remains default-off until explicit opt-in; disabled/offline/no-result keeps a savable coordinate label. No false promise of offline settlement data. |

Automatic naming uses the existing rate-limited/cached opt-in service; no new provider or dependency. Opening an existing saved site does not look it up. Unchanged inherited enrichment leaves Back pristine; deliberate coordinate/custom-name edits retain the existing dirty guard. No coordinate, zone, science, database or autosave contract changed.

## Actual verification

Shared behaviour class under `CLAUDE.md` V1: shared context display/name formatting plus site editor/list/map, bounded to those consumers. Final logs and fixture captures are in [evidence/geo-owner-refinement-2026-10-23](evidence/geo-owner-refinement-2026-10-23). Counts are separate overlapping sets, not a total.

- `tests-delivery.log`:129 passed, sites/Tonight/location/offline-tiles/Library manage, including new regressions.
- `dependencies.log`:32 passed, shared ContextLine, planner sites/location and Welcome consumers.
- `accessibility.log`:16 passed, complete existing main-screen and editors/dialogs/map sweep in Light/Dark/Field at100/200% plus its existing checks.
- `after.log` and `after-200.log`:3 passed each,7 selected states across3 themes at each scale.
- `native.log`:2 passed, isolated Android API30 debug capture,6 dark states including long-name Tonight, saved/transient list, Add and map. Raw native integration screenshots retain the known toolbar-capture caveat; ordinary runtime images are separate confirmation.
- Full `flutter analyze --no-pub`: no issues (`analyze-final.log`). The subsequent transient no-results correction/test-fixture additions were checked by final scoped analyzer: no issues (`analyze-changed.log`).
- Changed-file format:18 Dart files,0 changes. Encoding check passed (`encoding-final.log`); final `git diff --check` passed. Ukrainian test strings use Unicode escapes because the repository encoding guard otherwise rejects Cyrillic source; rendered test input is unchanged.
- Ordinary Android debug app: hot reload succeeded, no runtime errors. The200% transient screenshot originally suspected of losing leading coordinate glyphs was checked in the normal runtime: full50.55000°,30.30000° render correctly (`normal-emulator/transient-200.png`). Map/coordinate entry and explicit apply were exercised only with example coordinates on the disposable emulator, never GPS. Emulator scale/size overrides restored; our debug session/emulator stopped.

Early exploratory runs failed due to intentionally changed selectors and incorrect physical-pixel/DPR setup in new tests. Corrected viewport is375dp atDPR1; final129-test run is passing. No failing exploratory run is represented as PASS, and tests/goldens were not removed or weakened.

Independent read-only review by `/root/review_geo`: source/test review and actual100/200% renders; found the transient-only search message defect, fixed and checked. No remaining confirmed blocker. Reviewer requested ordinary Android confirmation of the coordinate capture artifact, completed above. One writer; reviewer made no edits and ran no tests.

## Visual evidence and environment

Reference: four owner screenshots. Before: `before/flutter-{home,geo_sites,geo_add,geo_map}-dark-375.png`. After: `after/` and `after-200/`, `flutter-{home,geo_sites,geo_add,geo_map,geo_more,geo_transient,home_long}-{light,dark,field}-375.png`, geometry JSON alongside. No stretching, overpainting or system-bar cropping.

Host app area375x760,DPR1,text1/2, bundled Geist/Source Serif4 and SDK icon fonts, settled pumps/no hover. Existing Hybrid fixture: Kyiv50.4/30.6, night2026-10-19, clock2026-10-18T15:00Z; explicit transient example50.55/30.3 and Ukrainian long-name example. Initial-scroll captures except dedicated expanded More. Host tile HTTP failures mean tiles unavailable, not downloaded successfully. Native emulator750x1664,DPR2, API30; ordinary system text scale2, Light, full raw system bars retained. Native screenshots are supplementary Android evidence, not pixel parity proof.

Physical originals/XML remain outside Git under `C:/Users/zalub/CulminaQA/2026-10-23/geo-owner-refinement/phone/`, because they contain real owner data: `final-tonight`, `final-sites`, `final-add`, `final-return-tonight`. Xiaomi14T Pro Android16,1220x2712,DPR3.25,text1,dark. The plan Crab Nebula and visible29min10s/6h55min values remain. Current name is Kryvyi Rih; multiple saved records were already present when inspected. No test Save/Delete/GPS request, permission tap or setting change on the owner phone. Existing consented automatic lookup may execute through the app's existing normal behavior; no new permission or consent was granted by QA. Physical keyboard and TalkBack remain unverified.

## Installed artifact and manual acceptance

APK `C:/Users/zalub/CulminaQA/2026-10-23/geo-owner-refinement/culmina-geo-refined-release.apk`, release1.0.0+1, package `io.github.buffur.culmina`, SHA256 `82aeacc839af960ef560edc6216861013d10a5fa977788fd67356991ee4e6359`. Verified existing Android Debug certificate SHA256 `56d00b35cb297aceabc42aef7033d41a7b5c7a1939e7d14cf7329672f8902dbe`. `adb install -r`:Success; launch Status ok,COLD845ms. No uninstall/clear/restore. Phone left on Tonight. Build retains existing KGP/CupertinoIcons warnings, not new geo build failures.

Manual acceptance: inspect Tonight's short place/date row; open Manage sites and verify selected saved row plus temporary Not saved row; Add site and check name/zone/More rhythm, then Cancel; open map and inspect small dot/attribution. On disposable data with opt-in enabled, change coordinates and wait for automatic naming; type a custom name and confirm it survives a late response. At200%, scroll all form fields and verify keyboard/actions. Real GPS, physical TalkBack and physical keyboard are not asserted as tested.

Disposition: requested refinement implemented, host and native checked, physical release updated and visually inspected; final owner acceptance pending. No next screen/roadmap task launched. Continue working in `culqa`, not the separate logo checkout.
