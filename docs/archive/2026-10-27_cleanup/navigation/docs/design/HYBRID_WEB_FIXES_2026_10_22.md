> **Historical navigation copy — not active instructions.** Link destinations are rebased from `docs/design/HYBRID_WEB_FIXES_2026_10_22.md`. Content and acceptance statements retain their original date/scope. [Immutable original](../../../docs/design/HYBRID_WEB_FIXES_2026_10_22.md) · [Navigation index](../../../NAVIGATION.md). Original SHA-256: `abe92d040748fea346d8acc81639d960450aa273ae0be72d9cad722ab3b354ad`.

# Hybrid web fixes and expanded QA — 2026-10-22

Scope: implement the preceding report's field-control correction and the owner's
photo annotations, prepare a fixed web candidate, then expand **web-only** QA.
The owner explicitly excluded Flutter/Android verification and design transfer.
Baseline: local `develop`, `a594837`, including the pre-existing dirty worktree.
No owner changes were reverted; no commit, push, dependency or native change was made.

## Latest timeline refinement — current candidate

The latest owner correction requires **black night**, with blue/cyan reserved for
daylight/twilight transitions. All Hybrid sky choices now use `#000000` for dark
time, including the red/black Field variant. Moon lanes and interval geometry
remain unchanged.

Two quiet outlined event shortcuts replace icon-only arrows: **Dark starts** and
**Dark ends**, with exact local times and next-day markers. At 200% they stack.
Without darkness they identify the timeline ends; clipped polar-dark intervals
identify the window edges rather than inventing sunrise/sunset. A clipped end's
displayed boundary stays exact while its accessible description explains the
last available five-minute preview sample.

Home navigation chevrons now share an 18×18 view size and 1.7px stroke. Timeline
endpoint labels wrap with a real gap when enlarged, rather than running together.

Research: [PhotoPills' Planner Time Bar](https://www.photopills.com/user-guide)
describes a day/light band and navigation to events.
[vis-timeline background areas](https://visjs.github.io/vis-timeline/examples/timeline/items/backgroundAreas.html)
provide a ready-made interval component. For this small phone control the existing
native range plus explicit event buttons was retained; no dependency was installed.

[Current focused evidence](../../../../../../design/home-lab/evidence/night-controls-2026-10-22/checks.json):
54 Home/Night/Moon combinations, 18 final 200% rechecks, and 17 palette/edge cases
pass; 62 Night/quality model checks pass. Actual selected captures were viewed.
This focused check supersedes the earlier blue-night styling below; previous
archives and broad matrices remain dated evidence for their own source snapshots.

## Earlier photo follow-up — superseded timeline colour

The owner's subsequent clarification is **icon before the title, values and
captions at the section's left edge**. Home's three condition rows now follow
that alignment. The two timeline buttons now use shaft-and-boundary arrows,
retaining their exact start/end-dark-time actions and accessible time labels.

The owner explicitly replaced the neutral default timeline with a blue/cyan ramp:
Light `#C8EDFA → #83CDEA → #439ED6 → #2465AD → #153B75`;
Dark `#7DD3FC → #46B6E8 → #278CCB → #1D5EA8 → #12366B`.
Existing ordered gradient stops, darkness boundaries and Moon lanes remain;
Field retains its red/black palette. This supersedes the earlier black-night
decision for the default Hybrid sky, without changing calculations.

[Current source manifest and focused checks](../../../../../../design/home-lab/evidence/timeline-photo-2026-10-22/checks.json)
record 54 passing Home/Night/Moon cases: 375/412px × three themes × 100/125/200%.
They check left alignment, actual palette, no phone/main horizontal overflow,
both jump actions and the five-minute keyboard step. Selected renders were viewed;
no-dark and polar-dark were also captured. The 61 Night/quality model checks pass.

The earlier 1,980-case matrix and before/after archive below remain dated evidence
for the preceding package, not a claim that the entire matrix was rerun for this
small follow-up. Its frozen archive is preserved. Current clean renders and
top-level runtime hashes are in
`design/home-lab/evidence/timeline-photo-2026-10-22/`.

## Result and photo mapping

- **Photo 1:** removed the crossed-out Culmina/Welcome header from Hybrid Home.
  Field mode now sits beside the selected-night heading. Welcome & setup remains
  a named action after the Home content and opens the existing setup flow.
- **Photo 2:** retained the already implemented shared Night/Moon/Weather anatomy:
  20px leading icon, 10px gap, 16/600 title, 15/400 value, 13px caption and a
  separate trailing chevron. Ambiguous drawn lines were not interpreted as an
  instruction to remove every section boundary.
- **Photo 3:** retained the content-driven Moon answer: title and duration share
  a line when they fit and wrap without overlap otherwise. Calendar captions are
  12px; seven columns now retain at least 48px targets, and dates/phases align at
  the top of each row despite one- versus two-line duration captions.
- **Prior Plan remarks:** verified Site and night 16/600 above 15/400 values,
  Capture plan 20/600 above Light 16/600, leading Edit and equal capture actions.
  The earlier specificity and 200% Focus whole-word fixes remain in place.
- **P3 field controls:** real radio/checkbox inputs use red/black glyphs, with
  visible focus, native Arrow/Space behavior and persisted selection. Explicit
  forced-colors mode restores native system controls rather than hiding them.

Changes are in `design/home-lab/app.js`, `hybrid-refinement.css`, and the new
`scripts/check_hybrid_field_controls.cjs`. Model arithmetic and storage formats
are unchanged. Existing browser colour choices are retained in this package.

## Evidence

[Before/after gallery](../../../../../../design/home-lab/evidence/web-fixes-2026-10-22/index.html)
uses the same current fixtures, browser viewport and 820px frame height for each
pair. The before render routes HEAD's unchanged Home module and the preserved CSS
prefix from before this package; it does not checkout or alter the source tree.

[QA summary](../../../../../../design/home-lab/evidence/web-fixes-2026-10-22/qa-summary.json):

- 1,980 unique root/state/editor combinations: 375/412px × Light/Dark/Field ×
  100/125/200%. Phone widths are explicitly measured, separate from the studio.
  1,978 initial geometry checks passed. Two premature shell captures were
  rejected by the scale/font checks; both targeted, fully mounted repeats passed.
  This proves container geometry, not visual inspection of every captured pixel.
- Independent read-only review: 18 Home combinations; 36 ready/no-dark calendar
  combinations; native radio keyboard checks. Selected actual captures were viewed.
- New field regression: six width/scale cases pass real radio ArrowDown, checkbox
  Space/persistence and checked/unchecked forced-colors fallback. All 18 cropped
  normal-field glyph captures contain red/black pixels only.
- Six actual Library Save → Plan select cases preserve a long Ukrainian/English
  rig name without phone/main overflow, including 125% and 200% text.
- Sampled opaque text foreground/background pairs across eight roots in Light
  and Dark all pass; measured minimum 5.06:1. This is not a blanket icon/gradient
  or field-mode AA claim; the documented field-secondary exception remains.
- 75 existing model checks, 11 browser contract scenarios, five focused existing
  acceptance checks and the six new field cases pass. JS syntax, whitespace and
  the scoped Impeccable detector pass.

Initial broad runs against port 4173 had recurring transport failures, including
ERR_CONNECTION_REFUSED for CSS/JS. Those failures and early harness setup errors
are retained, not relabelled as passes. The completed matrix used a temporary
second instance of the existing preview handler on port 4183, with an increased
accept queue and the same source files. No source/config change was needed.
The underlying cause of port 4173 instability was not established.

AntiGravity was actually invoked with `gemini-3.8-flash-high`, effort `high`, plan
mode: exit 0 / SUCCESS, but its response was empty and `RunCommand` was denied.
That invocation supplies **no independent design verdict**. The usable independent
browser evidence comes from the High Codex reviewer; no permissions were widened.

## Fixed candidate and limits

[Source manifest](../../../../../../design/home-lab/evidence/web-fixes-2026-10-22/source-manifest.json)
records SHA-256 for 120 runtime/font files. An external portable runtime archive
was verified entry-by-entry against that manifest. It is a reproducible candidate
for owner review, not a claim of owner acceptance or Flutter adoption.

Raw matrices, targeted rechecks, contrast pairs, scripts, archive and reviewer
outputs are under
`C:/Users/zalub/.codex/visualizations/2026/10/21/01a160b5-4e44-7191-90f9-be213b3d40a3/web-fixes-20261022/`.

Verdict: the requested web package is implemented and ready for owner review.
No confirmed functional blocker remains within the measured scope. Native UI,
Android keyboard/Back, live astronomy/weather, real files and production database
behavior were not tested in this run. No further implementation or transfer starts
automatically.
