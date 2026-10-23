# Geo flow v2 implementation — TD-121 — 2026-10-23

Owner-approved FIX package: implement the reviewed geo composition and visual refinements. Implemented; host and Android checks passed; final release/debug-signed APK installed on the owner's phone. Owner acceptance remains pending. No commit, push or publication.

## Baseline and boundaries

Task checkout `C:/Users/zalub/AppData/Local/Temp/culqa`, branch `codex/tonight-context-controls`, HEAD and final freshly fetched `origin/develop` both `2a43c89981c0f9e0f4d4eddc4a62484c470be928`; remote `https://github.com/Buffur/Culmina.git`. Preserve preceding uncommitted TD-120 Tonight work and seven pre-existing generated desktop files with line-ending-only changes. The owner checkout is separate, currently `744fe57` on `develop`, with equipment/target changes; it was not modified by this package. Do not assume its HEAD equals this build's baseline.

The owner approved [the geo design v2](../SITE_FLOW_DESIGN_2026_10_23.md) with “Погоджую, реалізуй у додаток”. This authorizes the described geo changes, including automatic naming, after the hierarchy/spacing/icon review. The earlier standing instruction authorizes rebuilding and updating the connected phone after fixes. Release uses rebuild/install, not hot reload. The read-only `design/home-lab/` reference remains unchanged. No P-1–P-6 replay, wider audit or roadmap work.

## Acceptance and implementation

TD-121 is one bounded owner refinement; the rows below are criteria, not another QA register.

| Surface and trigger | Cause → minimal change and files | Required behavior and evidence | Remaining risk / open point |
| --- | --- | --- | --- |
| Tonight → site; Manage sites | Equally prominent method buttons preceded the actual selection list. `sites_screen.dart` now groups current site, other saved choices/search/Add, then flat GPS/map actions. Shared local composition in new `geo_controls.dart`. | Current site appears once; search filters other choices and retains a recoverable no-match state. Selection and management stay distinct. Tests, host renders and phone inspection passed. | Final visual owner acceptance. |
| Pencil and GPS controls | Framed/poorly centered actions obscured hierarchy. Plain pencil in a 48dp target centers against the full text block; `hybrid_icon.dart` adds minimal outline locate/map glyphs. | 100/200% geometry tests cover trailing axis, row center and targets. Pencil still opens existing management/detail flow. No redundant Observing site route. | Physical TalkBack walkthrough not performed. |
| Add/Edit Site | Name-first layout and nested GPS disclosure interrupted the position task. `site_editor_screen.dart` puts visible position commands and coordinates before Name/zone/More, with local 20dp gutters, 24dp group and 12dp internal gaps. | Coordinates stack at large text; optional elevation/Bortle/SQM/provenance/notes remain available. Dirty guards, time-zone choice and Save contract retained. Physical More expanded, scrolled to bottom and restored closed. | Actual phone keyboard interaction was not exercised in this run; host editor/IME regressions remain the evidence for keyboard handling. |
| New valid position → name | GPS enrichment existed, but map/manual pairs lacked complete automatic assignment and an unavailable lookup forced typing. Generate a coordinate name locally, enrich only through the existing consented service, preserve an already resolved temporary name. | Save needs no manual name. Off sends no lookup. GPS/map results can enrich; typed pairs use an explicit lookup action. Manual names, stored names, newer coordinates and obsolete responses are protected. Focused tests include raw GPS precision and delayed opt-in races. | Real GPS and real settlement lookup were deliberately not requested on the owner's phone. Coordinate fallback is not a claimed municipality. |
| Library vs chooser Save | Transient Save as site inherited selection behavior too broadly. `sites_screen.dart` forwards `activate: choosing`; editor explains its entry context. | Library Save leaves the planning site unchanged; chooser Save selects. Regression tests passed. | No physical Save performed on owner data. |
| Map selection | Toolbar check provided weak confirmation; repeated GPS emphasis. `location_picker_screen.dart` provides selected coordinates, explicit Edit coordinates, full-width Use this point and one GPS command. Marker has a local semantic contrast backing. | Attribution remains visible. Editor return changes its draft; standalone apply uses feedback and closes only after success. Offline tile tests passed. Phone map opened and returned without applying. | Live tile loading is not proved by host screenshots, whose HTTP requests are intentionally unavailable. No map provider/style change. |
| 200% footer | Save wrapped taller than Cancel. `LibrarySaveBar` in `library_parts.dart` now stretches both within their intrinsic row height. | Equal widths/heights, centered labels, min48dp and existing SafeArea/IME container. Site regression, all-editor a11y variants and ordinary Android runtime screenshot confirm it. | This shared widget also serves equipment/target; their editor surfaces are covered by the a11y sweep. |

Production files: `lib/presentation/screens/sites/{sites_screen,site_editor_screen}.dart`, `lib/presentation/screens/location/location_picker_screen.dart`, `lib/presentation/screens/library/library_parts.dart`, `lib/presentation/shared/{geo_controls,hybrid_icon}.dart`. No dependency, database schema, scientific calculation or global palette token changed. The predecessor Tonight changes remain in the cumulative diff.

Tests updated in the existing sites, location, failing-tiles, Library manage, Tonight and Welcome suites; focused fixture shots added in `test/support/hybrid_transfer_shots.dart`; native capture accepts optional `HYBRID_SCALE` (default unchanged) in `integration_test/hybrid_transfer_capture_test.dart`.

## Verification and reuse

Classification under `CLAUDE.md` V1: **shared behaviour**, because the action bar and icon primitives have bounded consumers. The cumulative package includes TD-120 context routing. Tests select geo behavior, those callers, editor accessibility and the existing core loop rather than the whole repository. Counts overlap and must not be added together.

All listed logs are copied under [the evidence directory](evidence/geo-implementation-2026-10-23).

| Result actually obtained | State and reuse rationale |
| --- | --- |
| `tests-verified.log`: 154 passed | Broad scoped sites/location/Library/Tonight/planner-site/planner-location/Welcome/Field checks on the implementation before the final footer/marker/name-carry refinements. Those refinements are covered by the fresh runs below; unchanged selection/navigation callers reuse this run under V3. |
| `footer-regressions.log`: 72 passed | Sites + Library manage after the equal-height shared footer correction. Includes scaled footer geometry and Library selection semantics. |
| `site-delivery.log`: 60 passed | Fresh full sites suite after the final temporary-name carry/helper change. Includes naming, races, custom-name preservation, search recovery and footer regression. |
| `accessibility-final.log`: 6 passed | Editors/dialogs/filter/map sweep, Light/Dark/Field at 100/200%, after the footer correction. Equipment/target editors are included. Later changes only add a map marker backing and carry an existing name; they do not alter shared footer geometry. Earlier passing main-screen a11y cases are reused, not described as a new full sweep. |
| `core-loop.log`: 2 passed | Actual host site → plan → execution → export/restart flow and zone/DST scenarios. Reused: later presentation-only footer, marker paint and initial-name propagation do not change calculations, persistence, zone or export contracts. |
| `native-final.log`: 4 passed; `native-200.log`: 2 passed | Isolated Android API30 debug capture: geo sites/add/map in 3 themes at 100%, dark at 200%. Later final refinements verified by ordinary Android runtime and final host captures, not relabelled as a rerun of this native matrix. |
| `renders-delivery.log`, `renders-delivery-200.log`: 3 passed each | Final Add/map in all 3 themes, both scales. Final sites/More use `renders-final` / `renders-200`: later changes do not alter their captured layout. |
| `analyze-delivery.log`: no issues; `analyze-map-final.log`, `analyze-sites-delivery.log`: no issues | Full `flutter analyze --no-pub` on delivery state before last map/name refinements; changed sources then analyzed directly. No remaining unanalyzed source delta. |
| Changed-file format, encoding and whitespace | 17 Dart files formatted, 0 changes; `dart run tool/check_encoding.dart` passed; `git diff --check` passed. Generated desktop line-ending differences remain excluded. |
| Final `flutter build apk --release` | Passed, 71.4MB; `release-installed.log` is the build log, not itself proof of installation. Package/cert and actual installation are recorded below. Existing CupertinoIcons tree-shaking warning remains; no Cupertino-based geo control was added. |

Earlier exploratory runs failed on an incomplete cache mock and a missing capture output directory; those were corrected. A mixed run with 166 passed and 1 failure is **not** claimed as passing. Final capture logs supersede the incomplete-directory attempt. No checks weakened, tests deleted, or golden references refreshed to obtain green.

Independent read-only review by `/root/review_geo` found three concrete issues (delayed opt-in lookup, transient Library activation, current-only search recovery); all were fixed and regression tested. Final re-review found no blockers, including shared footer, marker backing and carried name. The reviewer inspected source, images and run logs; it did not edit code or execute the tests itself.

## Visual and native evidence

Original images are preserved without stretching, overpainting or system-bar crop. No overlay is used as proof of full parity. Approved design changes intentionally differ from the frozen web reference; the generated concept is hierarchy guidance, not an exact tile/geometry reference.

| Kind | Reference / before / after and environment |
| --- | --- |
| Reference | `evidence/geo-design-2026-10-23/geo-concept-v2.png` relative to this report; see [approved brief](../SITE_FLOW_DESIGN_2026_10_23.md) for precise criteria. No new owner amendment found beyond approval of v2. |
| HOST before | `before/flutter-geo_{sites,add,map}-dark-375.png` + geometry JSON: task state before geo implementation, with TD-120 already present. 375x760 logical app area, DPR1, text1, no system bars. |
| HOST after | `renders-final/flutter-geo_sites-{light,dark,field}-375.png` and corresponding `geo_more`; final Add/map in `renders-delivery/`. Large-text counterparts in `renders-200/` and final `renders-delivery-200/`. 375x760, DPR1, text1/2. |
| Fixture and state | `hybrid_transfer_fixture.dart` / focused shots: seeded Kyiv coordinates50.4/30.6, rural example, M31, plan night2026-10-19, fixed clock2026-10-18T15:00Z, Kyiv/device-zone fixture. Bundled Geist/Source Serif4 and SDK icon fonts loaded; settled pumps; no hover. Sites/Add/Map at initial scroll, More expanded for its dedicated shot. Map HTTP errors mean unavailable tiles, not a successful tile download. |
| EMULATOR integration | `native/` and `native-200/`: API30 x86_64, DPR2, 375dp width. Some screenshot frames shift/crop the standard app bar inconsistently. Retained as bounded native execution evidence; **not** exact toolbar geometry proof. |
| EMULATOR ordinary runtime | `normal-emulator/{sites-200,add-200}.png`: standard `lib/main.dart`, real Android system font_scale2, Light theme. Raw screenshot750x1664, Flutter view750x1632, DPR2. Intact standard header, equal footer and wrapped content confirmed; successful hot reload and no runtime errors. Our emulator's size/font overrides were restored, DTD disconnected and emulator stopped. |
| PHYSICAL final | Originals/XML remain outside Git at `C:/Users/zalub/CulminaQA/2026-10-23/geo-implementation/phone/`: `final-sites`, `final-add`, `final-installed`, `final-return-tonight`. Xiaomi14T Pro Android16,1220x2712,DPR3.25,text1,dark. Earlier same-source map/More checks: `map`, `more-bottom`, `more-restored`. Real stored coordinates are not copied into repository evidence. |

## Installed build and data boundary

Final APK: `C:/Users/zalub/CulminaQA/2026-10-23/geo-implementation/culmina-geo-v2-release-debug-signed.apk`.

- SHA256: `471541bfd73f93b7b1c77b7db0904b721a2c7c513f6244d3933bebe9e03496af`.
- Package `io.github.buffur.culmina`, version `1.0.0+1`, release build with existing Android Debug signer.
- Verified certificate SHA256 `56d00b35cb297aceabc42aef7033d41a7b5c7a1939e7d14cf7329672f8902dbe`, matching installed predecessor. `adb install -r` returned **Success**; launch **Status ok**, cold589ms.
- No uninstall, data clear, restore, permission or system-setting change on the phone. Pulling the old APK was not a user-data backup. Installation used the authorized preserving update path.
- Before installation the initial observed screen was Welcome; after launch the existing Crab Nebula plan was visible, with Xiaomi14T Pro8.8mm,29min10s needed/6h55min usable. Final Tonight retains these visible values. Saved Kr remains in Manage sites; active context is an unsaved position. These observations are not a complete database-integrity claim.
- Read-only phone QA opened sites/Add/More/map, returned without Save/apply, restored More closed and left the phone on Tonight. No real GPS, settlement lookup, OS location permission or owner-data mutation was requested as a test.

## Manual acceptance and disposition

1. Tonight → site: verify current position, saved site rows and separate centered pencil; open pencil and Back without selecting another site.
2. Add site: inspect visible position commands, coordinate/name/zone order and More spacing. With a valid point, verify auto name is present; a custom name is optional. Cancel without saving if using owner data.
3. On a disposable test record, choose a map point, verify coordinates and automatic name, then Save. Chooser selects it; creating through Library must leave the current planning site unchanged.
4. At 200% text, scroll the whole form, open More and keyboard, verify every value is reachable and Cancel/Save stay equal height above the keyboard. Inspect map attribution and coordinate editor.
5. Only when deliberately authorized, test real GPS and consented settlement lookup; verify failed/offline lookup keeps a savable coordinate name and a manual name survives late results.

Disposition: **implemented / host verified / Android emulator verified / physical release installed and visually inspected / owner acceptance pending**. Real GPS/lookup, physical TalkBack and physical keyboard behavior remain unverified. Stop after this package; do not start the next screen or historical roadmap automatically.
