# Hybrid / Geist design parity audit — 2026-10-21

Status: **COMPLETE WITHIN THE COVERAGE BELOW — confirmed gaps repaired and QA
passed; owner visual acceptance remains separate**.

Owner scope: inspect the latest local application against the web studio across
placement, typography, spacing, colours, navigation, workspace, layout, controls
and forms; repair confirmed gaps and run QA after the repairs. Starting HEAD:
`1aceb65`; working tree clean at audit start. The owner authorized delivery to
`origin/develop` on 2026-10-21; this report accompanies the delivery commit.
The actual checked-out branch for this audit is `develop`; the earlier migration
report's named Claude branch is historical context, not the current checkout.

## Authority and method

Original Hybrid `blend`, revision `20261020-hybrid7`, with the selected Geist
override is the reference. The current owner request and the native migration
brief supersede the older prototype-only limits in the local skills. All five
Culmina skills, their form/navigation/data contracts and Impeccable's native
audit/craft/Android guidance were read. Flutter accessibility and integration
test documentation was retrieved through Context7.

Verified the hashes of **all 145 original web source files** against the browser
capture manifest: none changed. The canonical fixture remains SHA-256
`39b1dfa55e396d3a82d04776439b125e26896e12d8578ea915c4d0a19cd1f849`.
Existing browser captures can therefore be reused for identical inputs. The
browser's illustrative calculations never replace production science or data.

## Confirmed gaps and repairs

| ID | Gap | Repair and regression evidence |
| --- | --- | --- |
| QA-01 | Tonight inherited generic type roles instead of the reference: plan heading 16 instead of 14; target 20/400 instead of 21/500; rig 13 instead of 14; night heading 24 instead of 25; title leading 1.3 instead of 1.2; both wordmark lines used one action style | Source-derived `AppTypography` Home roles, existing `nightHeading` wired in; explicit sizes, weights, leading, tracking and semantic-header checks in `tonight_home_screen_test` |
| QA-02 | Home heading/target and target/rig relationships were too tight; measure values were 14/600 with no caption gap or tabular numerals | 12 dp heading/target separation; 4 dp target/rig separation; fit-line measure captions 12, values 15/500 tabular, 4 dp inner / 20 dp group gaps. Other StatusBlock variants retain their roles; `status_block_test` |
| QA-03 | Field-mode action absent on scoped editors and workspace details | `hybridAppBar` supplies the existing shared action exactly once when the global theme capability is present; measured title space includes it. Block-editor test proves toggling persists without losing typed exposure; navigation tests check lists/progress |
| QA-04 | Library and Logbook detail pages retained root tabs, unlike the reference | Hide root chrome on non-root shell paths without moving routes or replacing branch navigators. Back restores tabs; retained branch stacks tested in `app_shell_navigation_test` |
| QA-05 | Selected navigation lacked the source weight/colour hierarchy, used selection rather than subtle surface, and omitted the top divider | Selected 600/primary, unselected 400/secondary; subtle surface including field-mode card surface; decorative palette border. Both normal and large-text navigation use the same roles |
| QA-06 | Result editor silently lost typed input on Back; no explicit Cancel; touching outlined fields; Save scrolled away | Snapshot-based dirty check including outcome, reason, counts and optional notes/conditions; Back/Cancel confirm discard; dismissal keeps input. Persistent IME-safe Cancel/Save footer, 20 dp form gaps. Existing save, stale, reconciliation and stored-data tests retained |
| QA-07 | Site Save stayed below the IME; consecutive outlined fields had no grouping space | Footer respects `viewInsets`; form gaps use existing spacing tokens. Host regression measures Save above a 300 dp simulated IME and coordinate gaps |
| QA-08 | Escape did not invoke full-screen editor exit guards | Block, result, site and plan-overrides editors bind Escape to their existing guarded leave action; block keyboard test preserves its dirty input on cancelled confirmation |
| QA-09 | Planning explanation inherited prominent primary body style | Secondary 13 sp metadata role; existing wording and settings behavior retained |
| QA-10 | Design-system guidance described pre-migration typography, underline fields and motion; base-scale comments contradicted named compact exceptions | Updated current typography, Home roles, outlined fields and 120/180 ms motion in `DESIGN_SYSTEM.md`; comments explicitly distinguish the base scale from compact navigation/calendar tokens |
| QA-11 | Re-review found two missed Hybrid CSS overrides | Fit-line explanation 14 sp / 1.55 and Home condition values 16 sp, from `hybrid-refinement.css:12-13` |
| QA-12 | Detailed 200% Appearance render revealed that vertical Material segments became narrow ellipses and clipped System; the automated accessibility sweep had missed the shape clipping | Display choices fill the content column; shared segmented-control theme uses the source's 6 dp rectangle, palette roles and 48 dp targets. A width/shape/label-geometry regression and 86 Settings/theme tests pass; all 24 Settings-section images refreshed |

## Requested dimensions

| Dimension | Review and acceptance boundary |
| --- | --- |
| Placement / layout / workspace | Eight root pairs plus four Settings sections and two editor states, three themes × two text scales; native/scientific additions remain explicit below |
| Typography | Bundled Geist, semantic body scale, source Home roles, tracking/leading, weights, wrapping and tabular measurements; host font tests and renders |
| Spacing / shape | Existing 4/8/16/24/32/48 rhythm, 6/12 radii and 48 dp targets; source-specific 12/20 relationships expressed through token sums; outlined form spacing repaired |
| Colours | Exact applicable JSON roles checked by `hybrid_tokens_test`; light/dark contrast and red-only field tests; accepted D-06 outline preserved |
| Navigation | Root/detailed chrome, independent branch stacks, Back, scoped Settings, selected states and 200% reflow; navigation suite and native flow |
| Controls | Global field action, button states, sliders, disclosures, labels/semantics, tap targets, Escape and reduced motion; component and accessibility suites |
| Forms | Dirty drafts, invalid input, field gaps, primary actions, Cancel/Discard/Save distinctions, IME geometry and preservation of actual data; editor/result/site/override tests |

## Independent CLI QA

Original read-only report: [claude-review.txt](evidence/audit-2026-10-21/claude-review.txt).
It inspected code and selected actual image pairs; it explicitly did not inspect
all themes or roots. Its five strongest findings are QA-03 through QA-07 plus
the wordmark part of QA-01. The original report is preserved verbatim.

The correction-only re-review and its prompt are saved beside it. No CLI pass
is treated as owner acceptance or as a substitute for executing native tests.

The [re-review](evidence/audit-2026-10-21/claude-rereview.txt) found all five
strong findings resolved in code. Its remaining corrections were handled by
the lead and checked in `correction-tests.log` (136 passed):

- Site Escape now checks whether anything changed before asking to discard.
- Each editor has an initial focus target inside its shortcut handler, without
  adding an extra Tab stop. Escape works before any field is clicked.
- Results allow normal Back for pristine input; dirty fields rebuild the guard.
  Refill after stale data suppresses intermediate form-change notifications.
- Two CSS type overrides were corrected (QA-11).
- Its DPR objection was a **false positive**: both existing test setup helpers
  explicitly set `devicePixelRatio = 1.0` before the geometry assertions. The
  412 × 915 view and 300 dp inset are logical pixels, not a 137 × 305 view.
  These are nevertheless host geometry checks, not real Android IME evidence.

Lower-priority dispositions: Escape, Planning explanation and contradictory
type-floor wording addressed. Multiple **valid** exposure examples are not a
parsing or validation defect. Fit-state colours retain the existing product
decision, separate from generic error meaning; changing that decision is outside
this parity repair. D-02 capability warnings, D-04 native dates, D-06 red outline,
D-08 editor adaptations, native data/provenance text and the rig dialog remain
intentional. Field secondary contrast retains its documented exception.

## QA evidence

Directory: [audit-2026-10-21](evidence/audit-2026-10-21/).

- Baseline: 79 targeted accessibility/theme/navigation/editor tests passed;
  five browser fixture-adapter tests passed.
- Initial fixes: 55 Tonight/status/editor tests passed.
- Review corrections: 79 result/site/editor tests passed, including synthetic
  IME geometry and Escape. The preceding 96-test attempt had one test-fixture
  failure (a lazy unbuilt field); corrected by scrolling it into the tree.
- Complete gate: 2437 tests passed, five optional tests skipped; core-loop host
  E2E and performance scenario passed. The Android harness is **skipped on the
  host**, separately from the real Android execution.
- After the keyboard/CSS re-review corrections: 136 targeted regressions plus
  80 accessibility/theme/navigation/style checks passed; final analysis clean.
- After QA-12: 86 Settings/theme checks passed and all 24 affected host images
  recaptured. Domain and unrelated callers were unchanged, so their passing
  gate evidence is reused under CLAUDE.md V3/V5.
- Full Android drive: **PASS**, 72 screenshots, 7 min 14 s, eight roots across
  three themes and 100/200% text, plus save/reopen, draft guards, result counts
  and notes, delete/Undo, synthetic FITS and production backup/reopen. This
  full run precedes only the bounded QA-12 Settings correction, verified by the
  separate final Settings run below. It uses a 1080 px screen with the
  existing 320 dpi override (540 logical px), not the 412 px matched host view.
- The Android log's non-fatal `AccessibilityBridge: transform has not been
  initialized` diagnostics also occur in the pre-audit r6 log. No Flutter test
  exception resulted; this is not a TalkBack or performance certification.
- Final Settings Android drive: **PASS**, six actual captures across all three
  themes at 100/200% (`native-settings-final.log`, 48 seconds). Full-column
  geometry is asserted on device, with the rectangle visually inspected.
- Normal final-code `lib/main.dart` debug APK built, installed and launched;
  hot reload succeeded (`normal-run-hot-reload.log`: 0 libraries, 383 ms).
  APK: `build/app/outputs/flutter-apk/app-debug.apk`, 222172309 bytes, SHA-256
  `f0338ed111488877a5b46dd8f763d9aced0ce779471a589e73557d9fc6b4447e`.
- Actual Android IME and Back: normal app, emulator density temporarily 420 dpi
  (about 411 dp wide), typed `QA-site-draft` without saving. `mInputShown=true`
  and `site-real-ime.png` show the full Save site action above the keyboard.
  Android Back hides the keyboard, then asks about unsaved changes; Cancel
  preserves the text (`site-real-back-cancel.xml`). Discard exits; the previous
  320 dpi override was restored. No physical phone was touched.
- Final source analysis clean (`analyze-settings-final.log`); 617 Dart files
  formatted without changes; encoding and `git diff --check` pass. Integration
  test additions compile and run on Android; no production code changed after
  these checks.

## Visual evidence and conclusion

[Interactive comparison gallery](evidence/audit-2026-10-21/index.html): **84
matched pairs**, all source images 412 × 915. Fourteen surfaces × three themes ×
two text scales: eight roots, four Settings groups, and normal/invalid block
editors. The whole set was inspected in six contact sheets for composition and
clipping, with full-size inspection of Tonight, the editor, Appearance at 200%,
and native result guard, field draft and Progress. Contact-sheet review is not
a pixel-by-pixel audit. The small geometric source overrides were checked
against CSS and widget styles, not inferred from thumbnails.

Final image hashes and per-pair capture runs are in `manifest.json`; source
fingerprints in `source-verification-final.json`. The 24 Settings-section
captures were refreshed after QA-12; other rendered inputs did not change.
Diagnostic differences include antialiasing, native glyphs, scientific/native
content and layout adaptations and have no invented similarity percentage.

The approved visual direction, semantic palette, main hierarchy and reachable
workflows are reproduced within this checked phone scope. The confirmed type,
spacing, navigation, control and form defects above are repaired. This is not
pixel identity: the app retains native controls, useful additional data, native
date formatting, the explicit D-06 field action and the documented adaptations.

Failed/transient attempts are kept as diagnostic evidence: the first render
invocation lacked its destination directory; concurrent Windows test/render
processes locked sqlite3.dll; an intermediate gate overlapped subsequent edits
and failed loading the performance harness during an incomplete wrapper edit.
These are not counted as successful final verification. Final runs are named
explicitly rather than treating every log in this directory as a pass.

## Limits

Host accessibility uses synthetic 100/200% text and controlled data. Emulator
screenshots are a separate evidence layer. A host IME rectangle is not evidence
of Android keyboard behavior; the separate actual site-IME check above is the
only new real-IME claim. Result-footer IME evidence remains host geometry.
Native test input alone is not a hardware keyboard or TalkBack rehearsal.
No connected physical phone is modified. Live
providers, native photo/file pickers, real files, share sheets and release
signing are outside this design-parity acceptance. No claim of pixel identity,
physical-device validation or owner acceptance is made.
