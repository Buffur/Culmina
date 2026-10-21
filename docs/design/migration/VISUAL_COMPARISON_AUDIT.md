# Matched Hybrid / Flutter visual audit

This audit is being assembled after the bounded composition, Planning Settings,
calendar and feedback corrections. The earlier conditions comparison remains
archived under `evidence/matched/history/conditions-ab6308520925/`; its defects
are historical findings, not an assessment of the latest sources.

## Comparison contract

- Eight roots: Tonight, Plan, Night, Moon, Weather, Logbook, Library, Settings.
- Three themes: light, dark, red field. Text scaling: 100% and 200%.
- Shared initial fixture exported from actual native models/repositories:
  Ljubljana, evening 10 November 2026, fixed clock, metric units, 24-hour time.
- Both browser and host canvas: 412 ×915 logical pixels, actual Geist.
- Original approved Hybrid source remains frozen. The isolated browser adapter
  replaces initial data only; its source/generated hashes and fixture hash must
  be recorded. Edits inside the copied browser still use its illustrative model.
- Browser fake status/gesture bars and lab controls are excluded with recorded
  capture-only framing CSS. Native system bar, keyboard, permission and file
  behavior require the separate Android evidence.

## Artifacts

Latest owner-requested local follow-up (2026-10-21, baseline `1aceb65`):
[design parity QA](DESIGN_PARITY_QA_2026_10_21.md) and its
[84-pair current gallery](evidence/audit-2026-10-21/index.html).
It records additional source typography, navigation, editor/IME and 200%
segmented-control repairs; the dated checkpoints below remain historical.

- [Paired gallery](evidence/matched/gallery/index.html).
- [Pair hashes, dimensions and review status](evidence/matched/gallery/manifest.json).
- [Browser capture manifest](evidence/matched/browser-capture-manifest.json).
- [Original and generated source manifest](evidence/matched/browser-source-manifest.json).
- [Canonical fixture](evidence/matched/canonical-fixture.json).

The gallery generator does not resize, align, crop or edit source PNGs.
Diagnostic overlays blend original RGB pixels at 50%; difference images use
absolute channel difference. Those include text antialiasing and composition
differences and have no automatic pass/fail threshold.

## Review status: intermediate composition checkpoint (2026-10-20, superseded below)

Browser capture completed at 2026-10-20T18:43:47Z: 90 PNGs, all 412 × 915,
zero browser diagnostics, 145 original source hashes reverified unchanged.
The fixture SHA-256 is `39b1dfa55e396d3a82d04776439b125e26896e12d8578ea915c4d0a19cd1f849`.
Platform media is light/dark alongside the requested theme so the stored System
appearance preference is displayed honestly. Local/session storage resets before
each document; invalid editor experiments cannot change later root captures.

The gallery currently pairs 48 roots and 24 Settings sections with the **intermediate**
Flutter host run, archived in
`evidence/matched/history/host-allroots-39b1dfa55e39-before-final-polish/`.
(2026-10-20 checkpoint, superseded by the final section below.) These
images identify defects; they are not acceptance of the latest production tree.

| Inspected surface | Confirmed composition difference | Bounded response |
| --- | --- | --- |
| Tonight light 100% | Plan begins about 45 px lower; Open CTA and Night ahead similarly displaced; needed duration drops seconds. | Parent/QA own context, spacing and duration precision repair. |
| Plan light 100% | Capture plan below viewport because rig note and detail rows consume vertical space; original first block visible. | Parent owns compact selectors and accessible detail disclosures. |
| Night/Moon/Weather light 100% | Site/zone and date-browser metadata consume an extra row. | Parent owns single-line context and centered date block; full zone remains accessible. |
| Logbook light 100% | Search hidden in app bar, filters modal, result count absent, share icon replaces row chevron; metadata larger than source. | Visible stable search, inline filters, count and 14 px metadata implemented; existing detail Share preserved. Focused tests pending. |
| Library/Settings light 100% | Root field-mode action absent; Planning summary omits Sun limit. | Field action added to all three workspace roots; actual darkness limit included. Focused tests pending. |
| Root app bars 200% | Material title clamp prevents source-equivalent scaling. | Parent owns measured title-height factory with preserved standard AppBar type. |
| Bottom navigation 200% | Label size exceeds source 11 × 2 px role. | Parent owns shared 11 px navigation role. |

## Final host recapture and per-pair review (2026-10-21)

The host side was recaptured on the step-2 tree (`ccd0227`) with
`ASTROPLAN_MIGRATION_RENDERS` (6 variants passed, 72 PNGs,
`evidence/matched/flutter/render-run-2026-10-21.log`) and again after the
visual repairs below (the final PNGs in `evidence/matched/flutter/`). The
re-exported canonical fixture is **byte-for-byte equal in content** to the
committed `canonical-fixture.json` (recursive JSON comparison), so the browser
captures of 2026-10-20 remain the matched reference for the same inputs; they
were not recaptured. `gallery.py` regenerated the 48 root pairs and their
diagnostics (`gallery/manifest.json`).

Reviewed by eye, side by side, for every root in light 100 %, plus dark 100 %,
field 100 % and light 200 % samples (Tonight, Plan, Moon, Settings/Planning):

| Surface | Result against the approved Hybrid | Response |
| --- | --- | --- |
| Tonight | Same order and hierarchy (title, context, Your plan, verdict, Needed/Usable to the second, Open planner, The night ahead, preview time). The earlier ~45 px offset is now ~6 px. Fit verdict is the native 18 px heading with the native reason instead of the web's 13 px check line with an illustrative "example window" note; the Night row keeps the native wording "Dark (Sun below −18°): …" and the zone rule. | Kept: native wording carries the darkness limit and zone (ENGINEERING_GUARDRAILS time/zone rules, F17); the web note is browser-only. Recorded deviation D-01. |
| Plan | Status figures, context, Target and Rig rows match; capture list starts below the first screen because the rig's active **capability warnings** (NPF / Max sub when tracking is unknown) stay visible and the per-plan Tracking row follows. | Kept: TASK 8.6 / PD-11 keep active capability warnings in view; reference data is in the Target/Rig details disclosures. Deviation D-02. |
| Night / Moon / Weather | Composition matches; the context uses two lines ("Ljubljana" + the explicit zone rule) where the web writes "Ljubljana · Europe/Ljubljana". Moon calendar glyphs were **inverted** (New Moon drawn as a full disc). The Moon answer had no primary number. | Glyph geometry fixed and coloured with Hybrid's roles (lit = text-primary, shadow = surface-subtle, 0.7 outline = border-control); `moon_phase_painter_test.dart` fails on the old geometry. Moon answer now leads with the 24 px total (`nightMoon.moonFreeTotal`). The zone line is kept (time-zone rule), deviation D-03. |
| Logbook | Matches: visible search, inline filters, count, groups, rows, Record result. Native adds the overflow menu (exports, AstroBin) absent from web. | Native capability kept (Decision 5). |
| Library | Matches; "1 rigs" was ungrammatical. | Singular/plural fixed for rigs and targets. |
| Settings root and sections | Root matches. Planning sliders had the value beside a long help text and no range ends. Trailing app-bar actions sat 8–16 px closer to the edge than the web. | `_SliderTile` now puts the name and value on one line, the help below, the slider and its range ends (settings.css). App bars end on the 16 px page margin at roots and 8 px on details. |
| Dates | Native writes "Tue, Nov 10" / "Night of Tue, Nov 10"; web writes "10 Nov". | Existing app-wide `NightTimeFormatter` (device locale) kept; deviation D-04. |
| Host glyph tofu | `|δ|` in the NPF row renders as a box on the host only (no system fallback font in `flutter test`). | On Android the same string renders correctly (`native/run-2026-10-21/plan-light_100.png`): host-only, not a defect. |

After the independent review (ledger, "Independent review"): its F1 — the
Weather tab clipped at 200 % — was missed in this review and is now fixed; its
F2 (override labels at 200 %) and the block-editor field gap are fixed. The host
was recaptured once more on the final code (`render-run-2026-10-21-final.log`;
fixture again unchanged) and every root at 200 % was reviewed (light for six
roots, Weather dark, Settings field): no clipped label remains. The gallery now
records which pairs were reviewed by eye (20) and which were not individually
reviewed (52) in `evidence/matched/visual-review.json`. The block editor's composition (OPEN-01) was then adopted: the harness now
also captures `plan_editor` and `plan_editor_invalid` in every theme and scale,
paired with the browser references; light 100/200 %, dark 200 %, field 100 % and
the invalid state in light and dark were reviewed side by side and match the
web's order, hierarchy and controls, apart from the native differences D-08.

Later the same day the remaining adoptable web details were adopted and the
pairs regenerated (fixture again unchanged): Tonight's fit line and condition
rows (D-01), the one-line Night/Moon/Weather context (D-03), Settings groups
above the tabs with web-style sliders (D-05), Weather's clearest/cloudiest
line, span length and coverage, and the catalogue ID on Tonight (D-07).
Tonight, Weather and Planning light 100 % were reviewed again side by side.

Deviations D-01 to D-08 are listed in the migration ledger; D-01, D-03, D-05 and D-07 are now adopted.

Browser-only illustrative/demo notices are intentionally absent from production.
Native backup remains the full existing capability, while the prototype demonstrates
only a subset. Native Material glyph shapes and system insets are presentation
adaptations, not evidence of pixel identity. Calculated domain values, missing-data
states and existing actions remain the native authority.

Supplemental browser references include four Settings sections (24 matched host
pairs), weather charts, first-block editing and invalid exposure. Editor/chart
references were unmatched at this checkpoint; the editor is now paired (`plan_editor`,
`plan_editor_invalid`, final section) while the weather chart reference stays unmatched. Android
keyboard screenshots have different available content height and are not identical
frame comparisons. No native pass is claimed by this browser/host audit.

## Phone refinement: Logbook and Library, 2026-10-21

Owner scope: start with Logbook, Library and their contents, following the supplied
`CULMINA_RELEASE_WORKFLOW_UK.md`. Baseline: `develop` at `fd63b951`; the existing
untracked `evidence/baseline-2026-10-21/` folder was preserved. No commit or push.

Physical-device observation: Xiaomi 2407FPN8EG, 1220 × 2712 px, density 520
(approximately 375 dp wide), installed `io.github.buffur.culmina.dev` 1.0.0 (1),
last update 2026-10-21 19:04:52. No package update, data clearing, record deletion,
GPS request or external sharing was performed. Observed the Logbook list, expanded
filters, saved-entry detail, existing-result form, empty target progress and export
menu; Library root, rigs list/editor, targets list/editor and sites list/new-site
form. This is initial coverage, not acceptance of every nested action or state.

### First bounded task: rig form readability

Problem reproduced on the phone: the first floating label was clipped and paired
identity/optics fields were too narrow. The host reproduction measured the first
label 5.5 dp above the scroll clip. Changed only the rig editor's local layout:
16 dp dialog margins and aligned content, scaled padding above the first field,
and single-column identity/optics pairs when space or text scaling requires it.
The existing buttons, values, validators, save and discard behavior are retained.
No new palette, shared component contract or domain change.

Initial-cycle host comparison: [before](evidence/rig-editor-375-before.png) /
[after](evidence/rig-editor-375-after.png), dark theme, bundled Geist, 375 × 812 dp,
100% text, seeded example rig. These are host Flutter renders, not phone captures.
[Android render](evidence/rig-editor-375-android.png): isolated API 30 emulator,
375 × 834 dp including system UI, light theme; not a matched dark-theme pair.

Initial-cycle verification (superseded by the additional cycle below): scoped
analysis clean; format clean; encoding and
`git diff --check` pass. Equipment-area tests: **56 passed, 1 failed**
([log](evidence/rig-editor-375-tests.log)). The newly extended fit check fails at
200% for model `TestMake TestPhone`: needs 304.8 dp, has 300.3 dp. Other tested
100/130% identity cases and existing numeric-fit cases pass. No full suite run.
Debug Android build, emulator launch and Dart MCP hot reload succeeded; no runtime
errors reported. On the emulator, actual keyboard entry, Back, unsaved prompt,
Cancel retaining the draft, Discard, and reopening the unchanged stored model
were verified. The changed editor has not been installed or verified on the phone.

Initial-cycle status: **PARTIAL, NOT READY FOR ACCEPTANCE**. Initial implementation and two local
layout corrections are exhausted under workflow §4; no further code iteration
was started. Next required decision: authorize another bounded cycle for long
text-field readability at 200%, then complete that check. Before any phone update,
workflow §6 additionally requires agreement on the existing target package and an
accessible backup; neither has been established for this run. Owner acceptance
has not been given. No performance improvement is claimed.

### Additional cycle authorized by the owner, 2026-10-21

The owner explicitly allowed one further correction cycle. Rig name, Manufacturer
and Model now grow vertically and wrap their text. They retain the text keyboard
and Next action; the display does not insert newline characters into stored data.
Numeric inputs, calculation and persistence code are unchanged.

The fit regression now checks the actual rendered glyph bounds, horizontally and
vertically, for every word in identity and numeric-pair fields. Empty glyph results
also fail. This supports wrapping without dropping the visibility requirement.
The same check was run against a temporary copy of the pre-cycle single-line
editor with the same dialog geometry: it fails for the previously hidden model
and rig-name glyphs ([negative control](evidence/rig-editor-cycle2-regression.log)).
No assertion was removed to obtain a passing result.

Matched Flutter host comparison, phone metadata fixture, dark theme, bundled Geist,
375 × 812 dp, 200% text: [before](evidence/rig-model-200-before.png) /
[after](evidence/rig-model-200-after.png). The earlier 100% images above remain the
initial-cycle record. [Current Android render](evidence/rig-model-200-android.png)
is a separate API 30 emulator observation at 375 × 834 dp including system UI,
light theme, 200% text, with a seeded rig whose model was edited to the same long
string; it is not a matched host/device fixture comparison.

Final verification: **57 equipment-area tests passed**
([log](evidence/rig-editor-cycle2-tests.log)), including 100/130/200% identity and
numeric visibility, save/cancel/discard and existing creation/import paths. Scoped
analysis, format and encoding pass. Android debug build, emulator launch and Dart
MCP hot reload succeeded. Actual keyboard entry at 100%, changing to 200% with the
draft intact, Save and reopening the exact `TestMake TestPhone` value were verified
on the emulator. The emulator's original model and font/size settings were restored.
No Dart runtime errors were reported. No full suite or performance measurement.

Current task status: **OWNER ACCEPTED**. The owner accepted the rig editor and
explicitly authorized proceeding to Targets. The 200% long-text blocker is
resolved. The personal phone package was not updated. Any such update still
requires the target-package/accessible-backup agreement in workflow §6; no new
package, signing, schema or dependency change was made.

Owner priority correction, 2026-10-21: finish the design at **100% text first**;
larger text-scale fixes come last. Do not make 200% refinement the next task while
the ordinary-size Logbook/Library design remains unfinished. Targets was inspected
and its layout correction described, but no Targets implementation had been made
when the owner requested this status inventory.

### Current completion inventory

| Area | Work actually completed in this refinement | Remaining |
| --- | --- | --- |
| Rig editor | Wider local dialog, aligned padding, unclipped first label, responsive identity/optics pairs, wrapping long identity text; owner accepted; 57 targeted tests and emulator checks | Updated build has not been checked on the personal phone; this does not close the rigs list, Add rig or metadata-review flows |
| Targets | Editor action layout repaired at 100%; 34 targeted tests and emulator keyboard/Cancel/Save/planning-guard checks passed | Ready for owner acceptance; personal-phone update and other Targets design work remain pending |
| Logbook | Phone observation of list, filters, entry, result form, empty progress and export menu | No Logbook code fixes in this refinement; investigate duplicate status and empty comparison section, then remaining ordinary-size flows |
| Library root, lists and Sites | Phone observation of root, rigs/targets/sites lists, target editor and new-site form | No code changes to these surfaces in this refinement; ordinary-size design and nested-flow work remain |
| Performance | No optimization implemented or measured in this refinement | Treat only a reproduced slow scenario as a separate bounded task |

Overall: **Logbook + Library design is not resolved**. The rig editor is accepted;
the Targets editor action-layout task at 100% is ready for acceptance. This
inventory does not claim acceptance of other screens.

### Targets editor at 100%, 2026-10-21

Owner authorized this next task after accepting the rig editor and explicitly
prioritized normal text size. Reproduced the four-button vertical action stack at
375 dp: Save and Cancel centres differed by 48 dp. Applied the accepted rig's local
16 dp dialog/content alignment, separated catalog metadata from Name, and retained
wrapping names. Delete/Cancel/Save now share the footer; the existing Plan this
target callback is an outlined secondary action inside the scrollable content.
No calculation, validation, repository, save or plan-leaving logic changed.

Matched host comparison: [before](evidence/target-editor-100-before.png) /
[after](evidence/target-editor-100-after.png), same M1 fixture, 375 × 812 dp,
dark theme, Geist, **100% text**. Light appearance was also rendered and inspected.
[Android](evidence/target-editor-100-android.png) and
[actual keyboard](evidence/target-editor-100-keyboard.png) captures are separate
API 30 emulator observations at 375 × 834 dp including system UI, light, 100%.

Verification: **34 tests passed** ([log](evidence/target-editor-100-tests.log)):
target editing/search plus Library manage-mode actions. New normal-size layout
cases cover light/dark with 0/300 dp keyboard insets, reachable Plan this target,
compact footer and exact stored coordinates/metadata on unchanged Save. Scoped
analysis, formatting, encoding and diff whitespace checks pass. Android debug
build/launch and Dart MCP hot reload succeeded; no Dart runtime errors reported.
On the emulator, Cancel discarded a typed test suffix, Save reopened the original
entry, and Plan this target reached the existing unsaved-plan guard; cancelling
returned to Targets. Emulator size override was restored. Personal phone unchanged.

Status: **READY FOR OWNER ACCEPTANCE** for this bounded 100% editor task. Larger
text was deliberately not refined or claimed verified in this task. Root/list and
remaining nested-flow design work are not closed; no full suite, performance
measurement, commit or push. Unrelated local capture-block changes were preserved.

### Remaining scoped queue (not implemented)

- Targets editor: accept or correct the current 100% example before another
  independent layout task. Remaining Targets flows stay in the broader queue.
- Logbook detail: the observed Not done entry repeats that status; its Plan vs
  actual section has a heading and separators without comparison rows. Inspect
  the status/reconciliation conditions before changing either presentation.
- Remaining coverage includes search/clear and all filter pickers, nonempty target
  progress, other result outcomes, entry rename/copy/export previews, Add rig and
  metadata review, target creation/type cases, and site zone/darkness/map/GPS flows.
  Storage failures, delete/Undo, real import files and system sharing were not
  exercised on the personal phone. Do not infer completion from root screenshots.


### Targets correction and live phone debug, 2026-10-21

Owner requested a smaller title-to-catalog gap, distinct catalog colour, all four
buttons in one row, and a filled Cancel. This supersedes the previous scrollable
Plan placement. Title/content gap is reduced locally; catalog metadata uses
AppPalette.textTertiary. Plan returns to the footer as `Plan`, with the full
`Plan this target` tooltip. Local horizontal button padding preserves 48 dp
minimum touch height; Cancel uses the existing secondary-container colour pair.
Save, validation, exact coordinates and planning callbacks are unchanged.

Evidence: [phone at 100%](evidence/target-editor-100-cycle2-phone.png),
[phone keyboard](evidence/target-editor-100-cycle2-keyboard.png), and
[light host render](evidence/target-editor-100-cycle2-light.png). Actual phone:
1220 x 2712 px, density 520, approximately 375 dp wide, font_scale 1.0.
All four actions share a row above the keyboard; Cancel closes and the original
M1 editor reopens. Visual assessment: tighter hierarchy, quieter metadata,
readable button labels and a distinct primary Save. Larger-scale refinement
remains deferred; this is not acceptance of the entire Library or Logbook.

Verification: 34 targeted tests pass
([log](evidence/target-editor-100-cycle2-tests.log)), including light/dark footer
alignment with keyboard insets and exact unchanged saves. Light render passes;
scoped analysis reports no issues; formatting and diff whitespace checks pass.

Before updating the protected existing package, an app-created `.astroplan`
backup was saved in phone Downloads through local archiving, copied outside the
repository, and extracted. Both ZIP CRC checks pass, required JSON parses,
SQLite integrity_check is `ok` and user_version is 27. No restore was performed.
The installed APK was also retained outside the repository. Debug APK and the
installed APK have the same package `io.github.buffur.culmina.dev`, certificate
SHA-256, versionCode 1 and min/target SDK 24/36. A plain `adb install -r`
succeeded. The repository's application ID was not edited: a local, ignored
Gradle init script applies the existing device ID for this build only.
`flutter attach` is active on the personal phone; a hot reload succeeded.
The existing web reference server is running at http://127.0.0.1:4173/ (HTTP 200).
It remains a separate prototype, not a mirror of this Flutter correction.

Status: corrected 100% example awaits owner acceptance. Leave the phone debug
session and requested web preview running for live review. Do not start the
next independent Logbook task before this example is accepted.

Owner response: further Targets correction required; example is NOT accepted.
A focused clarification of the requested change is pending. Do not infer approval
or proceed to the independent Logbook task. Phone debug remains connected.


### Owner-requested full-width Targets footer, 2026-10-21

Owner identified the remaining defect: the compact actions were grouped against
the trailing edge. Replaced the content-width action group with one bounded row,
with four equal expanded cells and existing 8 dp gaps. The footer now spans the
same left/right edges as the form. Delete remains the established icon control;
Plan, tonal Cancel and Save fill their cells. No callbacks or form data changed.

[Physical-phone result at 100%](evidence/target-editor-100-full-width-phone.png).
Actual phone bounds: form x=104..1116 px; footer x=104..1116 px, four cells
approximately 233 px wide with 26 px gaps. All four actions remain in one row
with the real keyboard open. Hot reload succeeded and no runtime errors were
reported. The updated existing layout checks verify footer-to-form alignment
and equal Cancel/Save widths in light/dark with and without keyboard insets.
All 12 target-screen tests pass
([log](evidence/target-editor-100-full-width-tests.log)); formatting passes.
This correction awaits owner acceptance; the broader Logbook/Library work is
still incomplete. Phone debug and the requested preview remain running.

## Web studio stage: block 1 (Logbook and Library), 2026-10-21

Owner workflow change: finish the design in `design/home-lab/` first (current Hybrid, 100 % text,
375 dp primary, 412 dp layout control), accept it, then port it to Flutter separately. Flutter
visual work is paused; no Flutter, phone or full-suite run in this stage.

**Accepted by the owner (Logbook list, from the owner's sketches):**
- Search field without a visible label (kept for screen readers), with a filter icon and a search
  mark inside; the filter icon opens the filters and shows the active count. No Filters row.
- One continuous list, newest night first, grouped by month only; no Upcoming/Past sections.
- State as the entry's right column beside the title and rig lines, as far right as it goes; every
  state has a mark (Saved = empty circle) on one vertical line; "Not recorded" under it. Lower lines
  use the full width; no gap under the title.
- No chevron and no Record/Edit result buttons in the list: the entry opens its detail, where
  Record/Edit result stays the primary action. Tighter entry spacing.

Files: `logbook.js`, `logbook.css`, `workspace.js` (a `filter` icon); two studio checks now press the
filter icon and open the result from the detail. Studio checks: tabs browser/interactions, Hybrid
feedback and refinement pass. Not yet ported to Flutter.

**Accepted by the owner (Logbook entry detail and list count):**
- The entry count sits right on the first month's line ("October 2026 · 6 entries"); a hidden live
  region still announces it.
- Status header matches the list ("○ Saved", "⏱ Not recorded"); Not done is not repeated in the
  Recorded column ("None"). Planned/Recorded and the integration totals share one two-column grid.
- Fewer rules and tighter sections; disclosures end in a chevron (no ▶). Plan as saved uses compact
  label-left / value-right rows, values one step smaller (13); one column at 200 %. Empty Notes is
  one row. Export buttons are full-width secondary, stacked.
- Stacking gain disclosure: the Plan's relative √N curve (`planRelativeCurve`) per comparable light
  group, plan point 1.00× and the recorded point √(recorded / planned); relative only, not SNR.
- Every state shows Record/Edit result; before the night starts the button is disabled with its
  reason. Owner decision 2026-10-21: the F19 / AM-01 rule stays (no result before the night starts).

**Logbook accepted by the owner (2026-10-21), final rules added after the entry-detail record above:**
- List: no rule under the last entry (also in Library lists); one rule between Progress and the month
  row; search field 4 px wider than the content column on each side (also Library).
- Entry detail: "Not recorded" on the status line, right; Notes as a heading with "None recorded."
  below; tighter spacing (sections 8 + 8 px, block rows 6 px, no rule above the integration totals);
  pair labels 13 / values 15; Plan as saved rows 14/14 with the value column taking the remaining
  width; every section heading, disclosures included, uses the section h2 role (18/600); Export as
  two side-by-side buttons "Text summary" / "Full JSON" with a download icon (full names for screen
  readers); Delete follows Export without a rule.
- Studio checks after the final pass: tabs browser/interactions, Hybrid feedback/refinement and
  library refinement all pass. Not yet ported to Flutter.

**Library: NOT accepted (owner, 2026-10-21; an earlier acceptance was withdrawn).** First pass of the
Logbook rules applied to Library: search with a
search mark and no visible label (4 px wider than the column); list rows without chevrons (root
navigation rows keep theirs) and no rule under the last row; every disclosure ends in a chevron (no
▶), editors included; section head = heading left, count right (wraps when it does not fit); record
details in compact label/value rows with the value column taking the remaining width, values 13,
one column at 200 %; Edit (primary) and Delete (outlined) full width, stacked.

Owner follow-up: go through every interactive Library element with the Logbook rules (less spacing,
larger text, aligned placement; e.g. the rig editor's focal ratio / aperture pair and the footer).
Logbook is accepted; Library is in rework. Open owner questions, not blocking: the
Library root line "Progress by target lives in the Logbook."; list search autofocus; the Targets
caption "6 of 164 bundled objects · read-only" length. Next: finish Library, then fix the accepted
reference and port block 1 to Flutter as a separate task.

**Library rework (2026-10-22), accepted by the owner after one more pass.** Every Library screen and state was
captured and reviewed at 375 (412 control, dark spot check): root, the three lists and no-match
search, rig/target/site details with their disclosures, Add/Edit rig (with the photo walkthrough,
JSON import and More open), the invalid-field state, Add target, Add/Edit site (device position and
More open), the unsaved-changes and delete dialogs, Undo, and the empty and load-error scenarios.
Logbook rules applied: hints/captions 13, field labels 15, detail rows 14/14; one heading role
(18/600) for section headings, form legends and disclosures (nested disclosure 15/600); spacing cut
(form rows 12, sections 12, disclosures 6 px summary padding, list rows 12); no rule above Cancel /
Save; field pairs share label/input/hint rows (CSS subgrid), so paired inputs always line up;
standalone secondary buttons full width, review buttons equal and side by side. Details follow the
Logbook order: caption and note, Edit, the data, disclosures, Delete last; the record name repeated
under the title bar is visually hidden (kept for screen readers and focus). Studio checks: library
refinement, tabs browser/interactions, Hybrid feedback/refinement pass.

Final pass (owner note 2026-10-22): the detail header's two explanation lines share one size (14,
secondary); Edit has 12 px above and 8 below; Delete follows the last block 8 px apart (the shared
20 px action margin is cleared). All Library states were captured again at 375 and 412 (dark spot
check) and the five studio checks pass. **Block 1 (Logbook and Library) is accepted in the studio.**
Open owner questions (not blocking): the Library root line "Progress by target lives in the
Logbook."; list search autofocus; the Targets caption length. Next: fix the accepted reference
(commit on the owner's instruction), then port block 1 to Flutter as a separate task.

## Project type scale and Settings (owner goal, 2026-10-22), accepted by the owner

Measured every studio screen's visible text (412 dp, light, 100 %) by size/weight. The accepted
block-1 scale, now shared by Logbook, Library and Settings:
22/500 screen title · 18/600 section heading and every disclosure · 16/500 row title (16/600
primary button) · 15/600 sub-heading · 15/400 field label · 14/400 body (14/500 secondary buttons,
values) · 13/400 hint, caption and note. 12 px no longer appears on these three tabs (status bar
excepted); the Logbook entry's 20/500 status headline is its own role.

Alignment fixes: Logbook row titles 15 → 16 and h3 14 → 15/600; Library disclosure titles were
18/500 (an older selector won) → 18/600; Logbook notes and counts 12 → 13.

Settings, all states reviewed (root, Appearance, Planning with both disclosures, the unsaved-changes
dialog, Privacy, Backup & data, Restore result, About, load error; 375 and 412, dark spot check):
notes, hints, range ends and the save state 12 → 13; field labels (sliders, switches, units,
darkness limit, file input) 15/400; outputs 15; disclosures ("How these defaults apply", "Gates and
optional times", "What leaves the device", "Application backup") 18/600 with an end chevron, no ▶;
spacing cut (groups 28 → 12, fields 20 → 12, switch rows 10 px, About link rows keep 48 px targets
without extra padding); no rule above Cancel / Save; space after an open disclosure and after the
intro. Sliders keep their 48 px target (a 40 px trial failed the target checks and was reverted).

Studio checks: bridge, defaults, tabs browser/interactions, Hybrid feedback/refinement/continuity
and library refinement pass. check_hybrid_corrections cannot write its fixed evidence path inside
OneDrive here (Windows error -4094); run on a copy of design/home-lab outside OneDrive it passes
51/51 with no page or console errors.

Outside block 1 (not changed, owner decision): Tonight, Plan, Night and Weather use 12 px widely
(Weather 86 text runs, Plan 47) and their own heading sizes (25–29 px).
