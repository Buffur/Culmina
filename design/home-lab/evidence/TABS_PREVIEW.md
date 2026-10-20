# Compact Weather, sky palette and tab prototype — completion evidence

Current Hybrid behaviour is documented in [the subsequent implementation and QA](../../../docs/design/HYBRID_IMPLEMENTATION_2026_10_20.md). This dated record describes the earlier tabs baseline; its separate-Plan/backup limitations are superseded where explicitly implemented there.

Date: 2026-10-20. Scope: the owner's browser Android prototype request, recovered after sign-out. [Decision/source map](../../../docs/design/ANDROID_TABS_2026_10_20.md). No production Flutter file, application database, global configuration, memory or skill was changed; no commit/push/publication was performed.

## Results and boundaries

- Home Weather is one temperature/wind summary and one example/status line. Its full row opens Weather; detailed meteorology stays there. Unknown is never zero. Home's outstanding example result now opens the working Logbook editor and disappears after that result is saved.
- Shared sky ramp uses eased Oklab mixing, with three outside-phone colour options: Dusk/Slate/Ink. Exact night/Moon/cursor facts remain model-owned. Field mode remains red/black regardless of palette.
- Logbook, Library and Settings are separate interactive destinations with real local persistence, validation, guarded drafts, storage errors and reachable actions. [Logbook](TABS_LOGBOOK.md), [Library](TABS_LIBRARY.md), [Settings](TABS_SETTINGS.md) specify implemented functions and production differences. No claim of complete native feature parity.
- Browser Back returns within the current detail/editor and respects its Cancel/discard decision. Actual Android system gestures, IME, TalkBack, insets and device performance have not been verified.

## Executed checks

| Evidence | Scope/result |
| --- | --- |
| [Model tests](tabs-2026-10-20/model-tests.txt) | 60 passed: affected night/time/weather contracts and quality checks, including compact Weather missing-data behaviour and ordered smooth stops/exact dark bounds. No native tests are claimed. |
| [Browser matrix](tabs-2026-10-20/browser-matrix.json) | 36 tab-root cases: 3 tabs × 3 themes × 100/200% × 1280×1040 / 412×915. 51 inner-screen cases at 200% across 3 themes: Logbook detail/editor/progress; Library's three lists/details/editors; Settings' five pages with advanced Planning open. No measured horizontal content overflow or product controls below 48 px. |
| Same browser matrix | 12 Home layout cases, 9 explicit state cases, 9 theme/palette captures. All actual screens mounted; error fallback alone cannot pass the matrix. |
| [Interactions](tabs-2026-10-20/interactions.json) | 11 grouped scenarios: search/filter, result validation/Save/reload/snapshot invariance, browser Back/dirty Cancel/delete/Undo/progress, Library CRUD/coordinates/rig fields, Settings/display/privacy/download/checked restore, malformed and denied stores, failed Save/Retry, untouched Plan/checkpoint, missing token resource Retry. No browser page errors. |
| [Final Home integration](tabs-2026-10-20/home-logbook-integration.json) | Home result → M33 editor → Save → Home due row removed; Weather/Night links and gradient work; all loaded versioned JS uses `20261020-tabs2`. |
| [Verification](tabs-2026-10-20/verification.json) | Final syntax, source facts, links, UTF-8/whitespace and source hashes. Inventory self-test: PASS (21 sources, 35 palette usage roles). |
| [Mechanical design scan](tabs-2026-10-20/design-detection.json) | Three font-popularity warnings (existing Inter/Roboto). Retained: the established font comparison and Android functional typography are owner-pinned; this task does not replace them. |

Run the scripts against `scripts/serve_preview.py` with an available Playwright module (`CULMINA_PLAYWRIGHT`) and installed Edge (`CULMINA_BROWSER=msedge`, the default). Automation uses a fresh profile and `localhost:4173`; it never clears or edits the owner's `127.0.0.1` storage. Earlier broad captures that only displayed the error fallback were rejected; the matrix now explicitly requires the actual module screen.

## CLI contribution and review disposition

Claude tasks were bounded to their own module files and relevant source/skill reads. Initial long-running workers were interrupted; the first left partial Logbook JS. Resumed workers disabled automatic external MCP connection and returned streaming logs. [Logbook](tabs-2026-10-20/claude-logbook-result.json) completed source review/CSS/report. [Library](tabs-2026-10-20/claude-library-result.json) and [Settings](tabs-2026-10-20/claude-settings-result.json) returned session-limit errors after writing JS. Parent completed and verified them. No successful plugin Skill-tool invocation or agent-run browser test is claimed; Culmina skill files were explicitly read and applied.

AntiGravity's first implementation attempt was denied its headless `RunCommand` permission and produced no implementation. A second, source-supplied read-only request completed without tools: [original review](tabs-2026-10-20/antigravity-review.md), [returned result](tabs-2026-10-20/antigravity-review-result.json). Its severity labels are retained as the reviewer's original opinions, not validated defect severity:

| Review item | Parent disposition |
| --- | --- |
| Token fetch error | Added visible load failure/Retry; actual routed failure verified. |
| Storage errors/simulation | Modules already catch errors and implement their own simulations. Denied/corrupt/failed-save scenarios verified; no silent overwrite. |
| Browser Back/cleanup | Added Back interception with draft guard and cleanup-type checking; exercised actual browser Back from a dirty editor. Native acceptance remains open. |
| Missing field theme | Rejected assumption: tokens contain field theme; all three themes ran successfully. |
| Unavailable residual weather | Added explicit unavailable gate before a headline can use values. |
| Missing link wording | Rejected: whole Weather row is a button with a chevron; its navigation was tested. |
| Preceding-hour/degenerate night/keyboard claims | No reproduced defect in valid fixed-24-hour inputs. Missing instantaneous data stays incomplete; no weather semantics were changed. Actual Android keyboard behaviour remains unverified. |
| Cloud-gated headline recommendation | Not adopted: conflicts with the owner's compact replacement direction and introduces unapproved qualitative thresholds. |

The parent fixed a separate reproduced integration defect: a root view's focus expression returned boolean false, so all tabs initially threw `target?.focus is not a function`. It now resolves to null or a DOM node; actual-screen assertions and interaction tests protect that boundary.

## Captures

- Roots: [Logbook](tabs-2026-10-20/logbook-light-1.png), [Library](tabs-2026-10-20/library-dark-1.png), [Settings](tabs-2026-10-20/settings-light-1.png).
- Details: [result/snapshot](tabs-2026-10-20/logbook-detail.png), [progress](tabs-2026-10-20/logbook-progress.png), [rig](tabs-2026-10-20/library-rig.png), [rig editor](tabs-2026-10-20/library-rig-editor.png), [appearance 200%](tabs-2026-10-20/settings-appearance-200.png), [planning 200%](tabs-2026-10-20/settings-planning-200.png).
- Sky comparisons: [Dusk](tabs-2026-10-20/sky-dark-dusk.png), [Slate](tabs-2026-10-20/sky-dark-slate.png), [Ink](tabs-2026-10-20/sky-dark-ink.png). All theme/palette captures are in the same directory.

Owner visual acceptance and palette choice remain decisions; Dusk is a reversible preview default. The work stops at this bounded prototype request.
