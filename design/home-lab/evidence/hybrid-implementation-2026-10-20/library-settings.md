# Hybrid Library and Settings implementation — 2026-10-20

Scope: the owner-authorised proposals in `docs/design/HYBRID_REVIEW_2026_10_20.md`, original Hybrid Android browser prototype only. Owned source: `library.js`, `library.css`, `settings.js`, `settings.css`. No Flutter/native/science files or memory were changed by this work.

## Changes

- Catalogue titles use the actual bundled `id` (or custom `catalogId`), removing literal undefined. Bundled/read-only and own/editable meaning and J2000/arcminute units remain explicit.
- Rig inputs lead with name, compact camera-class choices, required sensor and optics. Optional manufacturer/model follow under More. Validation still requires the existing model values; no facts are guessed from the camera name/class.
- Rig detail foregrounds known camera/optics values and summarises wholly unknown groups. Full rig record and sources keeps every unknown, optional value and provenance reachable. Site coordinates and zone stay together; elevation, sky darkness and notes are disclosed.
- Local metadata JSON can be selected, validated, reviewed and explicitly applied to a rig draft. Initially only empty draft fields are checked for replacement. Invalid/unsupported inputs preserve edits. This reads real plain JSON only; photo/RAW/HEIC/FITS extraction requires the app. Save rig remains separate. Reviewed metadata provenance uses the existing record fields, without changing the v1 schema.
- Device location is requested only by an explicit button. Browser permission is required. Returned coordinates require another confirmation before replacing draft values; the zone is not inferred or changed. Denied/unavailable requests keep the coordinates. Manual coordinates remain usable; no map, geocoding, forecast or provider HTTP request is made by these flows. No simulated map selection is presented.
- Library query, collection/detail selection and scroll use an isolated session-storage navigation key across Back/tab remount/reload. Unsaved editor contents are never written to that key.
- Planning settings show a usable budget control on the first phone screen at 200%. Scope distinguishes supported global per-frame/margin/setup defaults, explicit Plan overrides and unchanged saved snapshots. Other window/gate/timing/guidance settings are explicitly stored-only in the fixture preview. Parent-owned bridge supplies the actual Plan connection; setup null means off/0 once preferences exist.
- Immediate settings use 52×32 switch tracks with the original checkbox/role=switch semantics. Field radios/checks use red/black geometry while retaining native keyboard selection. About links are separate targets at least 48 px high; Privacy has a short decision lead and a reachable full provider disclosure.
- Settings-only JSON retains checking, review and explicit restore. A separate Full prototype backup button dispatches `culmina-backup`; the parent owns its five-key backup dialog/rollback. App `.astroplan` database files are explicitly excluded from this browser format.

## Integration contracts

- `validateLibraryPayload(raw)` and `validateSettingsPayload(raw)` accept JSON text or a parsed v1 envelope and return a boolean without mutation.
- Full-prototype-backup trigger: bubbling `CustomEvent('culmina-backup', {detail: {source: 'settings'}})`.
- Existing persisted Library and Settings schemas remain version 1, with no required new fields.
- Optional navigation key: `culmina-library-navigation-v1` in sessionStorage. Contains view/id/query/scroll only, never an editor draft.

## Targeted verification

Fresh headless Edge contexts used `http://localhost:4173`, not the owner's `127.0.0.1` checkpoint. The owner tab/storage was untouched. Browser contexts were closed. Existing preview server was left running; this work started no server.

The initial bounded run passed eight checks. Three additional checks had ambiguous test selectors because identical error text correctly appeared in both the field area and live announcement; their focused rerun used main-scoped selectors and passed. These were harness corrections, not application failures. Edge's internal `edge://downloads-hub/` requests were observed during JSON download and excluded from external HTTP accounting.

Verified behaviours (11 checks): catalogue identity and full unknown record access; metadata review before explicit Apply and v1 save; unsupported/malformed metadata preserving drafts and required validation; explicit geolocation confirmation with unchanged zone; custom-target units/validation/editability; Library Back/remount/reload continuity; first Planning slider fully visible at 200%; 52×32 switch geometry; separated 48 px About links; failed privacy save retaining shown state and Retry; checked settings JSON and backup event dispatch; safe exported validators. The source script groups first-control/switch checks together.

Six focused final checks covered the subsequent local refinements: metadata review auto-scroll without implicit apply; checked metadata Apply; red-only radio rendering with keyboard selection in field mode; dark 200% rig form without horizontal overflow; denied/unavailable browser location preserving coordinates; 200% site form reflow. No browser page errors occurred. Corrected HTTP accounting recorded no external provider requests.

`node --check` passed for both module files. Scoped `git diff --check` returned no whitespace errors. No Flutter tests/build, native device acceptance, real physical GPS fix, image-header extraction or scientific calculation validation is claimed.

## Evidence

Isolated capture and result directory:

`C:/Users/zalub/.codex/visualizations/2026/10/20/01a15843-1ef5-77f1-9b70-c715b0607d72/hybrid-library-settings-implementation/`

- `results.json`: initial eight passes and the three duplicate-selector harness failures.
- `results-corrected-harness.json`: the three focused corrected checks, no failures/page errors/external HTTP requests.
- `final-results.json`: six focused final checks, no page errors.
- Final visual pack: `planning-200-first-control.png`, `final-metadata-review.png`, `final-settings-field-controls.png`, `final-rig-dark-200.png`, `final-site-200.png`, `final-position-permission-unavailable.png`, `about-separated-links.png`, `rig-full-record.png`, `settings-json-confirm.png`.

Location success evidence uses an explicitly configured browser geolocation fixture (50.41°, 30.61°, reported accuracy 25 m), not a physical-device location result. A separate unpermitted context exercised real browser refusal/unavailability. Metadata evidence used actual in-memory JSON file uploads to the browser file input; no extraction from image pixels/headers was simulated.

Parent integration verification owns Library-to-Plan selection, effective global defaults, the full prototype backup and final versioned entrypoint consistency. This report is bounded to the Library/Settings changes and checks above.

## Final Claude QA corrections

The final independent Claude visual/source check identified one confirmed P2: a previous invalid-settings-file live announcement could remain over the subsequent valid restore review. The successful check now announces the current checked-file/review state, replacing that stale error. A read revision guard also ignores older file-read completions and invalidates them when leaving the page. File checking, explicit confirmation, Cancel and unchanged pre-confirmation storage remain intact.

The optional Library typography refinement removes the repeated full target name in the body when the app bar already identifies the object. Body headings are Catalogue record / Your target; designation, bundled read-only versus own editable meaning, focus targets and all scientific fields remain unchanged.

Three focused checks passed with zero browser page errors: invalid→valid file replaces the old error and Cancel leaves storage unchanged; an older deliberately delayed invalid file cannot overwrite a newer valid review; catalogue app-bar identity remains correct with a concise body heading and no horizontal overflow at 200% text. The controlled delay wraps the browser File.text method for one test filename only; actual file contents still pass through the real parser. No wide suite or audit was rerun. Both module syntax checks and scoped whitespace check passed after the correction.

Evidence in the same isolated capture directory: `qa-corrections-results.json`, `qa-fixed-settings-json-confirm.png`, `qa-fixed-target-200.png`.

The restore confirmation scope copy was also reconciled with the parent-owned bridge: saved plans/Logbook remain unchanged, while restored global defaults update the working Plan budget. A focused final confirmation capture verifies this exact copy and the current checked-file announcement before any storage change. `qa-fixed-settings-json-confirm.png` now shows this final copy.
