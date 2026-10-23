# Culmina Graphite UI — implementation handoff

Prepared: 2026-10-19. Inspected baseline: `8048cfa` (verify the actual checkout before implementation).

## 1. Purpose and authority

Implement the Graphite visual direction on Culmina's existing Flutter screens: Tonight/Home, Plan, and Night & Moon. Replace excessive card framing with compact sections, aligned values, small-radius controls and restrained light/dark palettes. Bring capture input into the first useful viewport without losing existing planning capabilities.

The owner rejected the earlier rounded-card concepts and the bright red demonstration. After reviewing references from Halide, PhotoPills and darktable, the owner accepted the Graphite prototype and requested a plan for another agent. This document is that plan; no application implementation has occurred in this handoff. Submitting the execution prompt in section 10 activates the bounded implementation work. Do not infer release, push or publication permission from this document.

Read `CLAUDE.md`, the current summary/next-action entries in `PROGRESS.md`, `PRODUCT_DIRECTION.md`, relevant `ENGINEERING_GUARDRAILS.md` sections, `.agents/rules/05-ui-design.md` and `docs/DESIGN_SYSTEM.md` first. Code is evidence of actual implementation: the progress file contains historical summary entries alongside later work. Do not restart completed F tasks based on an older summary.

This approved visual direction replaces the older card-heavy presentation for these screens. It does not replace the scientific, persistence, accessibility or data-provenance contracts. Record the bounded design amendment in the relevant design/decision documents during implementation, preserving historical decisions.

## 2. Portable reference package

All required visual references are in [evidence/graphite_ui](evidence/graphite_ui/README.md):

- [Interactive preview](evidence/graphite_ui/preview.html), a standalone wrapper of the accepted prototype.
- [Editable prototype source](evidence/graphite_ui/concept.html), an HTML fragment, not application code.
- [Plan, dark](evidence/graphite_ui/plan-dark.png).
- [Home, dark](evidence/graphite_ui/home-dark.png).
- [Night & Moon, dark](evidence/graphite_ui/night-dark.png).
- [Plan, light](evidence/graphite_ui/plan-light.png).

Treat the screenshots as visual references, not acceptance evidence for Flutter. The earlier `culmina-design-directions` concepts are rejected and must not be used as the target. The preview is for inspection only; do not introduce a WebView or embed this HTML into the app.

### Reference interpretation

| Accepted direction | Prototype simplification that must not become production behavior |
| --- | --- |
| Flat hierarchy, compact rows, nearly square fields/buttons | Only one Light block was demonstrated; production retains all blocks and types |
| Direct exposure/count editing and a nearby summary | HTML uses fake 8% overhead, 32 MB/frame and fixed window lengths; never port these formulas |
| Shared light/dark appearance across screens | Preview's theme icon is not authority to repurpose the existing field-mode button |
| Night bands and an inspection cursor | Fixed dates, Kyiv, M31 and sample intervals are fixtures only |
| Clear numeric alignment | HTML fonts, 11px labels and spacing are approximate; Flutter retains at least 12sp and accessibility scaling |
| Home, Plan, Night & Moon as separate screens | The outer three-tab preview switcher is not new app navigation |
| Illustrative Ukrainian text | Preserve the current application language and terminology; no localization project |
| Calm normal dark theme | The existing red field mode remains available, persisted and operational |

The owner explicitly clarified the screen/theme distinction: **Night & Moon is a content screen, not a theme**. All screens share the selected app appearance. Use the full name in design documentation and review material.

## 3. Scope and non-goals

In scope:

1. Shared visual tokens and control treatment supporting light and Graphite dark appearances.
2. Layout/hierarchy of Tonight/Home, Plan and Night & Moon.
3. Capture-block editing presentation needed to make exposure/count accessible without scrolling through target and rig specifications.
4. Existing night visualization presented as aligned interval lanes with an inspectable time cursor.
5. Regression checks on consumers of changed shared components/themes.

Retain the existing Provider/ViewModel/repository architecture, routes, persisted appearance settings, draft/save behavior, calibration policies, time abstractions, weather provenance, assumptions and scientific calculations.

Out of scope: branding/logo changes, dependency additions by default, database migrations, new weather providers, camera/mount control, planetarium features, scores, localization, a new design for every secondary screen, red field-mode palette redesign, release/signing/publication. Shared tokens may affect secondary screens; repair resulting regressions without opportunistically redesigning their workflows.

Do not remove unsupported-in-the-prototype states or features. In particular preserve the monthly Moon calendar, twilight events, candidate selection, rig/target/site editing, calibration, metadata-assisted entry, fill-window action, saved snapshots, current-sky distinctions and dirty-plan protections.

## 4. Visual specification

### Tokens

These values reproduce the approved prototype and are starting values for the actual token roles. Validate contrast on the real rendered surfaces and adjust minimally where required. A subtle separator is not a sufficient border for an input control.

| Role | Graphite dark | Light |
| --- | --- | --- |
| Page background | `#202123` | `#F2F3F3` |
| Secondary surface | `#292B2E` | `#E8EAEB` |
| Primary text | `#D5D8DB` | `#30363A` |
| Secondary text | `#A0A6AD` | `#606970` |
| Decorative divider | `#3B3E42` | `#CED2D5` |
| Input surface | `#25272A` | `#F8F9F9` |
| Quiet accent | `#A0B1BA` | `#4D6572` |
| Main button fill | `#3A444B` | `#475B66` |
| Main button text | `#E1E5E7` | `#F2F4F5` |

- Inputs/buttons: use a shared 3dp radius (0–4dp is acceptable where Flutter behavior requires it). No capsule-style status labels or large rounded wrappers on the three target screens.
- Group most content using whitespace, headings and thin horizontal separators. Avoid a border/divider around every single element when alignment already groups it.
- Retain opaque dialogs and sheets; choose modest radii through existing tokens. Do not flatten overlays into an unreadable background.
- No decorative shadows, gradients, glowing accents or astronomy artwork.
- Use existing Roboto typography and app tokens. Use tabular numerals where supported for changing measurements; do not add a font dependency merely to mimic the web prototype's monospace.
- Keep labels at least 12sp; ordinary body text 14–16sp; control touch areas at least 48dp. Large text must reflow rather than shrink or truncate essential information.
- Preserve text/icon distinctions for status and chart lanes so color is not the only signal. Existing error/warning roles remain semantically distinct in normal themes.
- Preserve system/light/dark appearance selection and red field-mode behavior. The preview's sun/moon icon is only a demonstration switch; keep the existing production settings and field shortcut unless a separate change is explicitly authorized.

## 5. Implementation sequence

Each task includes implementation and its relevant verification. Do not wait for unrelated full-suite runs at every boundary. Apply `CLAUDE.md`'s verification policy to the cumulative final diff.

### GR-01 — Verify baseline and map shared effects

Dependencies: none.

- Inspect `git status`, branch, current HEAD and the active task ledger. Preserve user work; do not modify or stage unrelated `plans/prompt.md` (already untracked at handoff).
- Record existing render/test evidence and capture the three actual screens before changing them, with a reproducible fixture.
- Locate shared token/component consumers and choose which layout changes should be screen-local. Do not globally remove every `Card` or change semantic widget contracts to achieve a local layout.
- Read the existing capture editor's validation, apply/cancel, save, autosave and undo behavior before introducing inline fields.

Acceptance: a bounded file/behavior map and baseline screenshots exist; the plan is reconciled with actual code, without a broad repository re-audit.

### GR-02 — Theme tokens and shared presentation

Dependencies: GR-01.

Primary files:

- `lib/core/theme/app_colors.dart`, `app_palette.dart`, `app_theme.dart`, `app_radius.dart`, `app_typography.dart`, `app_button_styles.dart`.
- Relevant reusable widgets in `lib/presentation/shared/`: `info_row.dart`, `section_header.dart`, `collapsible_section.dart`, `context_line.dart`, `status_block.dart`.

Implement the palette and geometry in shared tokens, not scattered literal colors. Allow compact, unframed compositions without forcing all callers to change. Retain correct contrast for buttons, focus/selection and outlined input boundaries. Inspect field-mode filtering and startup restoration before changing shared colors.

Acceptance GR-A02: light and Graphite dark are consistent; labels/controls remain accessible; no new capsule/card treatment; field mode, its persistence and its no-flash behavior are intact.

### GR-03 — Plan hierarchy and capture editing

Dependencies: GR-02.

Primary files:

- `lib/presentation/screens/home/home_screen.dart` (this is the Plan screen despite its filename).
- `lib/presentation/widgets/capture_plan_widget.dart`, `planner_summary_card.dart`, `plan_status.dart`, `plan_tracking.dart`.
- `lib/presentation/widgets/capture_plan/capture_block_dialog.dart`, `capture_budget_summary.dart`, `capture_assumptions_panel.dart` and adjacent block helpers.

Default content order:

1. Plan-night/site context and truthful saved/changed state.
2. Compact selectable target and rig summaries, with visible missing-input/capability warnings.
3. Light blocks with exposure/count immediately discoverable and editable.
4. Calibration and contextual camera parameters.
5. Time/integration/storage/fit summary; relevant assumptions and links to supporting conditions.
6. Stable Save action using the current save lifecycle.

For a normal ready one-block fixture at 412×915 / 100% text, exposure/count must be reachable in the first viewport without first scrolling past specifications. At large text, prioritize reflow and reachability rather than forcing the same screenshot composition.

Support multiple Light blocks with compact rows and an expanded editor for the active block. Reuse existing commands, validation, camera-class policy, calibration inheritance and undo. Retain add/edit/delete/import paths; do not let the one-block mock dictate the data model.

Editing contract:

- Keep transient text separate from valid block values; empty/partial input never becomes a persisted zero or silently restores a stale value.
- Route valid edits through the existing block-update/domain path. A new local draft must have explicit apply/cancel or equivalent submit semantics using existing protections; do not create a second calculator for preview totals.
- Save must validate and resolve the active draft before calling the existing save operation. Invalid input focuses/explains the problem and prevents a false successful save.
- Navigating back, switching the active block or target/rig, and changing the night must not silently discard a local edit. Reuse existing dirty-state handling where possible.
- Do not multiply-write or recreate controllers on rebuild. Preserve cursor/focus while dependent values update.
- Keep ISO/WB/optional AF-MF visible according to the existing Phone/DSLR rules; Gain is only for the appropriate camera class. The astro-only mock is not authority to hide basic DSLR fields.

Fit remains factual: fits, tight, does not fit, no usable window, and missing inputs must remain distinct. For over-budget plans, explicitly show excess time; a clamped visual bar alone is misleading. Show individual usable intervals where appropriate; do not suggest all available time is one continuous interval. Preserve omitted/unknown overhead and storage assumptions.

Acceptance GR-A03: compact ready-state hierarchy; existing multi-block and camera-class behavior retained; genuine recalculation; no lost edits; stable honest Save; no hidden warnings or removed capabilities.

### GR-04 — Tonight/Home

Dependencies: GR-02; integrate GR-03 outputs when ready.

Primary files: `lib/presentation/screens/tonight/tonight_home_screen.dart`, relevant night/weather text and shared context/status components.

- Keep Home's title tied to the plan's selected night under the accepted `PlanNightPhrase` rule. Do not hardcode Tonight for a future plan. Preserve existing bottom navigation and route identities.
- Present site/night context, night facts, weather freshness/state and the current plan as flat sections.
- Remove repeated zone/interval prose while retaining a clearly available site time zone and next-day markers.
- Night & Moon and Weather remain reachable; the plan row leads to the existing planner; candidates and result-due prompts remain available.
- Show actual forecast values/freshness when known. The prototype's unavailable-weather state is one fixture, not a permanent design state.
- Any small night band must communicate actual interval placement, rather than a decorative fully filled bar.

Acceptance GR-A04: context and next action scan easily; night identity is truthful; no duplicate technical prose; forecasts/unknowns/results/candidate workflows are preserved.

### GR-05 — Night & Moon interval view

Dependencies: GR-02.

Primary files:

- `lib/presentation/screens/details/night_moon_screen.dart`.
- `lib/presentation/widgets/night_browser_sections.dart` (`NightBarSection` and painter), `sky_darkness_widget.dart`.
- Existing view state/data: `lib/presentation/viewmodels/night_browser_viewmodel.dart`, `lib/domain/services/night_view.dart`, shared `night_time_formatter.dart` and `twilight_bands.dart`.

Use aligned lanes on one time scale for darkness and Moon-above-horizon intervals. Add the target's usable window lane only from an authoritative existing computation for the displayed site/night/target/preferences. Do not relabel raw target visibility as usable imaging time, or reuse the plan night's windows while browsing another night. If the required result is unavailable, explicitly label it unavailable and preserve the rest of the view; document the limitation rather than inventing a calculation.

Preserve the existing definition and boundaries of `SessionNight`. The prototype's 18:00–08:00 axis is not a replacement for the production time frame. Handle gaps/multiple intervals, no-darkness nights, Moon always above/below, missing target and zone/DST transitions correctly.

The cursor uses the existing view-model state and changes only inspected time. Its mark must not cross text labels. Keep accessible textual interval summaries; plot height must not be the only way to convey data. Preserve the month calendar, twilight events, thresholds, selected-vs-plan-night distinction, Now action and explicit Plan this night adoption flow with confirmation protections.

Acceptance GR-A05: lanes share a correct axis; all values use real model data for the viewed context; inspecting/browsing never mutates the plan; existing details remain reachable; no clipped labels or misleading intervals.

### GR-06 — Cross-screen regression and visual acceptance

Dependencies: GR-03, GR-04, GR-05.

Validate the actual Flutter implementation, not just the HTML. Use the current render harness and real fonts; add bounded fixtures where the current harness cannot exercise a changed state. Write new evidence to a new directory, not over F25 history or the approved concept package.

Required visual matrix for the three target screens:

- Light and dark at 100% and 200% text, baseline 412×915.
- Narrow width around 320dp; use a taller canvas/scrolling for enlarged text, not clipping.
- Active capture editor with keyboard inset; Save and error feedback remain reachable.
- Field-mode regression at 100%/200% text for changed screens and affected overlays.
- A wider layout smoke check to catch hardcoded mobile widths.

State checks: new/missing-input plan, ready one-block and multi-block plans, saved/changed state, failed save, unknown tracking/overhead/storage, fits/tight/overflow/no-window, current vs future night, forecast available/stale/missing, invalid edit and navigation with an unresolved edit. Exercise relevant inherited camera settings and calibration mismatch handling.

For shared theme changes, inspect representative secondary consumers (Settings, Logbook, Library, dialogs/sheets, site/rig editors) and run their existing applicable accessibility checks. Do not accept new contrast failures merely because those screens were not redesigned.

Acceptance GR-A06: all relevant functional and accessibility checks pass; real before/after screenshots demonstrate the approved visual hierarchy; HOST, EMULATOR and physical-device evidence are accurately labeled. A browser screenshot is never evidence of native behavior. Do not claim physical field comfort has been verified without that check.

### GR-07 — Documentation and final handoff

Dependencies: GR-06, with any genuine unavailable verification explicitly recorded.

Update `docs/DESIGN_SYSTEM.md` and only the decision/progress/status entries made inaccurate by the implementation. Explain changed hierarchy, theme roles and preserved field-mode behavior. Include changed files, tests/commands/results, screenshot locations, deviations and remaining limitations. Check off acceptance criteria with evidence, not just implementation assertions.

Do not publish, push or merge on the basis of this plan. Follow the execution session's explicit Git instructions; retain unrelated working-tree changes. If no safe work remains and a mandatory check is unavailable, return a partial result with the exact unmet criterion and resumption condition.

## 6. Verification starting points

Existing tests to select according to changed behavior, not a fixed blanket command:

| Area | Existing test paths |
| --- | --- |
| Theme/tokens/controls | `test/core/theme/design_tokens_test.dart`, `controls_theme_test.dart`, `app_theme_test.dart`; `test/presentation/theme/presentation_style_rules_test.dart`, `field_mode_darkness_test.dart` |
| Plan composition/disclosure | `test/presentation/screens/home/planner_structure_test.dart`, `planner_f18_test.dart`, `planner_disclosure_test.dart`, `planner_defaults_test.dart` |
| Blocks/budget | `test/presentation/widgets/capture_plan_widget_test.dart`, `capture_blocks_test.dart`, `block_settings_test.dart`, `capture_outputs_test.dart`, `capture_assumptions_test.dart`, `capture_plan_fill_test.dart`, `capture_blocks_undo_test.dart` |
| Save/draft invariants | `test/presentation/viewmodels/planner_capture_blocks_test.dart`, `planner_draft_session_test.dart`, `planner_session_save_test.dart` |
| Home/night | `test/presentation/screens/tonight/tonight_home_screen_test.dart`, `test/presentation/screens/details/night_moon_browse_test.dart`, `test/presentation/shared/context_line_test.dart` |
| Accessibility/renders | `test/presentation/accessibility_test.dart`, `test/presentation/design_system/u_renders_test.dart` |

For application changes use changed-file formatting, `flutter analyze --no-pub`, `dart run tool/check_encoding.dart`, targeted widget/unit regressions and `git diff --check` per `CLAUDE.md`. Broaden testing when shared effects or failures justify it. The full gate remains governed by the repository's final-gate policy; do not rerun it after every small visual adjustment.

Rendering example in PowerShell (use a new destination and verify the harness still supports this variable):

```powershell
$env:ASTROPLAN_U_RENDERS = 'docs/refinement/evidence/graphite_implementation/renders'
flutter test test/presentation/design_system/u_renders_test.dart
Remove-Item Env:ASTROPLAN_U_RENDERS
```

Existing layout tests may encode the old order. Update those expectations to the approved hierarchy while retaining or strengthening behavioral assertions. Never remove a data-safety test to make the redesign pass. Write meaningful regressions for edit flushing/validation, navigation with drafts, viewed-night isolation and status boundaries.

## 7. Final acceptance checklist

- [ ] GR-A01: baseline, shared effects and reference interpretation recorded.
- [ ] GR-A02: normal light/dark appearance follows the accepted direction; field mode and accessibility preserved.
- [ ] GR-A03: capture input leads the usable Plan viewport; multi-block/camera/calibration and save contracts preserved.
- [ ] GR-A04: compact Home with truthful night, weather and plan states; existing actions retained.
- [ ] GR-A05: readable real-data interval lanes and safe browsing; calendar/details retained.
- [ ] GR-A06: native renders, functional checks and affected shared-component regressions completed with honest environment labels.
- [ ] GR-A07: design/progress documentation and final evidence report updated; no unauthorized delivery action.

## 8. Known implementation decisions and boundaries

- Exact class extraction, component names and breakpoint details are normal implementation decisions; use existing abstractions where possible.
- The preview offers direct input but no explicit Apply control. Resolve production drafts through the existing validated editing workflow; correctness takes precedence over copying the mock's trivial state handling.
- Approved compact hierarchy supersedes the older answer-first placement for the ready-state Plan. Important failures/missing inputs still lead when they block a decision or action. Do not hide these just to match the fixture.
- Existing field-mode appearance was not approved for redesign. Preserve it in this work and report physical comfort separately; do not replace it with the rejected bright-red concept.
- Treat a new domain formula, provider, database change, feature removal or materially expanded workflow as a separate scope decision. Routine visual details and ordinary implementation fixes do not require another approval.

## 9. Reference provenance

The following public sources informed the visual direction, accessed during this conversation on 2026-10-19. Borrow principles, not vendor code, imagery or branding:

- [Halide](https://halide.cam/): camera-oriented parameter hierarchy and restrained mobile controls.
- [PhotoPills user guide](https://www.photopills.com/user-guide): compact time context and interactive night-time presentation.
- [darktable screenshots](https://www.darktable.org/about/screenshots/): neutral dark surfaces and rectangular information grouping.

The accepted Culmina reference package is original concept material created in this chat. The PNGs were captured from the HTML preview with a local headless browser, not from Flutter. Its interaction checks covered three screens at 320/736px, light/dark switching, recalculation, invalid input, fit overflow, local save feedback and time inspection. These checks establish prototype behavior only.

## 10. Copy-ready execution prompt

```text
Implement the approved Culmina Graphite UI described in
docs/refinement/GRAPHITE_UI_IMPLEMENTATION_PLAN.md, tasks GR-01 through GR-07.

Read CLAUDE.md and the current repository state first. Open the portable concept
package in docs/refinement/evidence/graphite_ui, including the actual PNGs.
Treat Graphite as the visual reference for Tonight/Home, Plan and Night & Moon.
Preserve the existing application language, routes, domain calculations,
camera-class rules, multi-block/calibration support, draft/save semantics,
night browsing/adoption behavior and persisted red field mode.

The HTML contains demo values and a simplified one-block editor. Do not copy its
formulas, hardcoded dates, browser state storage or preview navigation into Flutter.
Use existing tokens, ViewModels, validators and domain services.

Complete the finite GR task sequence with the documented acceptance criteria,
targeted tests, actual Flutter renders and a final evidence report. Continue safe
independent work when a check is unavailable; report the exact remaining gap.
Do not ask again about ordinary visual or implementation choices already covered
by the approved direction. Raise only material new scope/product decisions.

Preserve unrelated working-tree files. Do not commit, push, merge, publish, sign
or start unrelated roadmap work unless I explicitly authorize that in this session.
```
