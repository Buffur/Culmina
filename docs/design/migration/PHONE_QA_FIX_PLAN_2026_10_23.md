# Fix plan for the 2026-10-23 phone QA findings - implementation status

> Delivery update: the owner subsequently authorized committing and pushing this verified state to `develop`. See [Git delivery](PHONE_QA_FIXES_DELIVERY_2026_10_23.md); uncommitted-state statements below describe the earlier snapshots.

Source: [PHONE_QA_2026_10_23.md](PHONE_QA_2026_10_23.md) §6, findings QA-02 and QA-04–QA-09, build `35992c9`.
Reference: `design/home-lab/` at `86873ce` (computed styles re-read on 2026-10-23 with `webcap.cjs` dumps, values below).
Originally a planning-only proposal. The owner subsequently authorized P-1–P-6; implementation status and host evidence are recorded per item below. No changes are committed; phone re-checks remain pending.

## Finding re-check before planning

- **QA-09 is withdrawn.** The reference's computed fill of Library › Rigs › Add rig in Dark is `rgb(235,235,234)`,
  equal to Android. The `rgb(204,204,204)` read from the web screenshot was the button's hover state: Playwright's
  pointer stayed over it after the click that opened the list. No change is planned.
- QA-02 root cause confirmed in code (below); QA-04–QA-08 confirmed against computed styles.

## Tasks (authorized order)

### P-1 · QA-02 — Plan status line goes stale after the first edit of a saved plan

- Cause (verified by reading code): `SessionPlanViewModel._edited()` calls `notifyListeners()` **before**
  `CurrentSession.write`; the write replaces `_session` (a planned session returns to draft) but only calls
  `onWriteFailureChanged` when the failure state changes. `_SaveBar` (`home_screen.dart`) reads
  `PlanState.of(plan.activeSession)` and is not rebuilt after the write; the identity badge happened to rebuild
  through another listener. `_onSiteChanged` (unawaited write) has the same gap.
- Change: `CurrentSession` gets a second callback in the existing pattern (`onSessionChanged`), called after an
  autosave (`write`, also the site-change write) when the session's id, status or saved flag changed;
  `SessionPlanViewModel` wires it to `notifyListeners` (and clears it on dispose). Save, New, Open, revert and settle
  already notify through `PlanLifecycleViewModel` (`markChanged`), so they are not changed. Notify only on that change,
  not on every autosave, so the memoized budget/fit generation (trap 16) is not bumped per keystroke.
- **Status (2026-10-23): implemented on branch `fix/qa-02-save-status` (worktree, from `35992c9`), not committed;
  TD-114.** Tests: `current_session_state_test.dart`, `plan_save_status_test.dart` (red before the fix).
- Excluded: wording of the line, autosave serialisation, any repository or schema change.
- Tests: new regression — saved plan → edit a block → Apply → after the autosave settles the line reads
  "Changes are not saved yet." and the badge "Saved · changed"; same for a site change on a saved plan; Save returns
  both to "Saved". Rerun `current_session_*_test`, `plan_identity_actions_test`, `saved_plan_transition_test`,
  `unsaved_plan_prompt_test`, `autosave_failure_banner_test`, `planner_memoization_test`, host E2E `core_loop_test`.
- Class: shared behaviour (ViewModel + lifecycle service).

### P-2 · QA-04 — Filled (primary) button labels are 500, the reference is 600

- Reference: `.primary-button` 16 px / **600** (Save target, Save site, Save rig, Save, Add rig, Edit site,
  Add selected frames, Apply changes, Save plan); `.secondary-button` 14 px / 500 (matches today).
- Cause: `AppTheme` `filledButtonTheme.textStyle` = `bodyLarge` with `FontWeight.w500`. Save plan looks right only
  because `_SaveBar` overrides it with `AppTypography.itemTitle` (16/600).
- Change: the theme's filled-button weight to 600 (height kept 1.5); leave local overrides as they are.
- **Status (2026-10-23): implemented on branch `fix/qa-02-save-status` with P-1, not committed; TD-115.**
  Test: `controls_theme_test.dart` (primary 16/600, secondary 14/500 in every theme; red before the fix).
- Tests: `controls_theme_test` (assert 600), `confirmation_and_delete_patterns_test`, `equipment_editor_fit_test`
  (wider labels), `accessibility_test` (200 % wrap, all three themes), `design_system_gallery_test`,
  `field_primary_action_contrast_test`, and the files that match `FontWeight.w500` with filled buttons
  (`tonight_home_screen_test`, `forecast_nights_test`, `rig_creation_test`, `sites_screen_test`) — update only
  assertions that encode the old 500, never weaken others.
- Class: shared behaviour (theme).

### P-3 · QA-05 — "Unsaved changes" (plan) stacks three action rows

- Reference: `#leave-plan .leave-actions{display:flex;flex-wrap:wrap;justify-content:flex-end;gap:8px}` → Cancel and
  Discard on one row, "Save and leave" wrapping below, all end-aligned.
- Cause: `askUnsavedChanges` (non-library variant) passes three buttons to `AlertDialog.actions`; at 375 dp they do
  not fit one row and the `OverflowBar` stacks every button.
- Change: one actions child, a `Wrap(alignment: end, spacing: 8, runSpacing: 8)` of the same three buttons (keys and
  order unchanged; Discard keeps its destructive styling). The library variant is already as the reference.
- **Status (2026-10-23): implemented on branch `fix/qa-02-save-status` with P-1 and P-2, not committed; TD-116.**
  Test: `unsaved_prompt_layout_test.dart` (red before the fix at 375 dp).
- Tests: widget test at 375 × 792 that Cancel and Discard share a row and Save and leave is below and right-aligned;
  200 % text still wraps without overflow; `unsaved_plan_prompt_test`, `confirmation_and_delete_patterns_test`.
- Class: shared widget.

### P-4 · QA-06 — Night/Moon/Weather tabs: unselected labels use the primary colour

- Reference: selected 14 px / 600 `--text-primary` with a 2 px rule; unselected 14 px / 400 `--text-secondary`.
- Cause: `night_moon_screen.dart` `TabBar` sets no `labelColor`/`unselectedLabelColor` (Material defaults resolve to
  the primary text colour), and the selected weight is 500.
- Change: `labelColor: textPrimary`, `unselectedLabelColor: textSecondary`, selected weight 600; indicator unchanged.
  Field mode's secondary red stays below AA by the documented decision (ARCHITECTURE B16).
- **Status (2026-10-23): implemented on `fix/qa-02-save-status`, not committed; TD-117.**
  Rendered tab colours/weights are checked after each selection in all three themes; regression checks are recorded below.
- Tests: a widget assertion of both colours and weights; `night_moon_browse_test`, `accessibility_test`.
- Class: localized (one screen).

### P-5 · QA-07 — Night › Exact times: values do not reach the right edge

- Reference: values right-aligned to the content edge (interval and event values end at x = 356.4 of 375).
- Cause: the row helper in `night_browser_sections.dart` (`group`, ~line 454) is
  `Row[Expanded(label), 8, Flexible(Text(value, textAlign: right))]`; the loose `Flexible` sizes the value to its
  text, so it sits after the label's flex share (Sun events values even start mid-row).
- Change: give the value column a tight fit (`Expanded`) so `TextAlign.right` aligns to the edge; labels unchanged.
- **Status (2026-10-23): implemented on `fix/qa-02-save-status`, not committed; TD-118.**
  Geist geometry checks at 375 dp cover all exact-time values and each interval line at 100/200 percent text.
- Tests: geometry assertion that each value's right edge equals the row's right edge, one wrapped interval value
  ("… to …") included; `night_moon_browse_test`, `accessibility_test`.
- Class: localized.

### P-6 · QA-08 — Weather B selected hour uses the neutral selection fill

- Reference (`weather-radix.css`, Hybrid blend, Light and Dark): selected hour `background: --radix-blue5`,
  `color: --radix-blue12`, `border-bottom-color: --radix-blue11` — Light `#c2e5ff / #113264 / #0d74ce`, Dark
  `#004074 / #c2e6ff / #70b8ff`. Field is outside that selector: `--selection`, `--text-primary`, the accent rule
  (what Flutter shows today).
- Cause: `weather_hybrid_view.dart` hour axis uses `hybrid.selection`, `textPrimary`, `hybrid.accent`.
- Change: three new `HybridTokens` roles (selected-hour fill, text, rule) in all three palettes (trap 12: tokens, no
  literals in presentation; Field keeps red/black values), used by the hour axis only.
- **Status (2026-10-23): implemented on `fix/qa-02-save-status`, not committed; TD-119.**
  `selectedHourFill`, `selectedHourText`, `selectedHourRule` are used only by the Weather B hour axis; Field values are unchanged.
- Tests: `weather_hybrid_view_test` (selected cell colours per theme), `field_mode_darkness_test` (Field tokens still
  red/black), `presentation_style_rules_test`, contrast of blue12 on blue5 in `accessibility_test`.
- Class: shared (theme tokens) but one consumer.

## After the Tasks

1. Gate per CLAUDE.md V1 on the cumulative diff (targeted tests above, `flutter analyze --no-pub`, `dart format` on
   changed files, `dart run tool/check_encoding.dart`); the full gate is not required per Task.
2. Docs in the same change: `docs/TECH_DEBT.md` entries for the findings (next free IDs after TD-113) with the
   implementation state (not committed; add resolving hashes only after an actual commit); a short addendum to the phone QA report (the earlier transfer record stays unedited).
3. Rebuild `flutter build apk --release`, `adb -s <serial> install -r` over the current QA install (same debug key,
   data kept), and re-check on the phone only the affected surfaces: Plan status line after an edit (L/D), filled
   buttons in Library and dialogs, the plan "Unsaved changes" dialog, Night/Moon/Weather tabs, Exact times, Weather B
   selected hour (L/D/F). This needs the owner's phone permission for that run.

## Not in this plan

QA-03 (location dialog outcome) needs an owner-run manual check first; QA-10 (hourly value size) needs a measurement
before it is a defect; QA-01 is a device incident, not app work; the NOT EXERCISED rows of the report stay open.
Commits only on the owner's instruction.

## P-4 implementation verification (2026-10-23, host only)

- Red: three new rendered-tab tests failed on selected weight 500 versus 600. Green: `night_moon_browse_test` + `accessibility_test`: **30 passed**, including the three new tests.
- `flutter analyze --no-pub`: no issues; changed-file `dart format`: clean after formatting; encoding PASS; `git diff --check`: PASS.
- TD-117; no phone check or new release build. Logs: [P-4 red](evidence/phone-qa-fixes-2026-10-23/p4-red.log), [P-4 green](evidence/phone-qa-fixes-2026-10-23/p4-green.log), [analysis](evidence/phone-qa-fixes-2026-10-23/p4-analyze.log).

## P-5 implementation verification (2026-10-23, host only)

- Red: the new 375 dp/Geist geometry test failed at 100 percent (value right x=338.57, row right x=355); 200 percent already passed.
- Green: `night_moon_browse_test` + `accessibility_test`: **32 passed** (includes P-4 and both P-5 scales). Assertions also check the final painted glyph of each interval line, excluding whitespace selection boxes.
- Analysis initially reported one missing-braces lint in the test; braces added with no behavioural change. Repeated `flutter analyze --no-pub`: no issues. Format (0 further changes), encoding and `git diff --check`: PASS. The 32-test result remains applicable after this braces-only edit (V3); P-6 will also run the full suite.
- TD-118; no phone check or new release build. Logs: [P-5 red](evidence/phone-qa-fixes-2026-10-23/p5-red.log), [P-5 green](evidence/phone-qa-fixes-2026-10-23/p5-green.log), [analysis](evidence/phone-qa-fixes-2026-10-23/p5-analyze.log).

## P-6 implementation verification (2026-10-23, host only)

- Red: selected-hour widget tests failed on the neutral fill in Light/Dark; Field already passed.
- Green: weather widget, token, Field darkness and presentation-style regressions: **27 passed**.
- Full unit/widget suite on the cumulative P-1 through P-6 state: **2463 passed, 6 skipped, 0 failed**, exit 0. The full suite was selected for shared ThemeExtension/palette/interpolation impact, as requested by the handoff; it includes the new Light/Dark AA contrast tests and all P-4/P-5 regressions.
- `flutter analyze --no-pub`: no issues. Format on all eight Dart files changed by P-4 through P-6: 0 changes. Encoding PASS; final `git diff --check`: PASS after normalizing the documentation line endings. No application/test source changed after the full suite.
- TD-119. No phone operation, new release APK, install or native visual re-check. Hot reload was attempted but unavailable without an active app connection; only the owner's Android Studio DTD was discovered, left untouched.
- Logs: [P-6 red](evidence/phone-qa-fixes-2026-10-23/p6-red.log), [targeted](evidence/phone-qa-fixes-2026-10-23/p6-targeted.log), [full suite](evidence/phone-qa-fixes-2026-10-23/p6-full.log), [analysis](evidence/phone-qa-fixes-2026-10-23/p6-analyze.log), [final checks](evidence/phone-qa-fixes-2026-10-23/final-checks.log).
- Complete per-task file mapping and all uncommitted files: [implementation report](PHONE_QA_FIXES_IMPLEMENTATION_2026_10_23.md). Stop after P-6; commits and physical-phone verification await a separate owner instruction.

## Authorized physical-phone follow-up (2026-10-23)

The owner subsequently requested a release/debug-signed build and testing on the connected phone. **P-1 through P-6: PASS in the exercised physical-phone scope**, new APK built/installed over the existing package with matching debug certificate. [Detailed phone report, evidence and limits](PHONE_QA_FIXES_PHONE_RECHECK_2026_10_23.md). Initial data/settings were backed up and restored after testing. This supersedes the earlier pending phone/build statements for this scoped follow-up only; owner acceptance and the report's unexercised cases remain open. No source fix or commit was made in this follow-up.
