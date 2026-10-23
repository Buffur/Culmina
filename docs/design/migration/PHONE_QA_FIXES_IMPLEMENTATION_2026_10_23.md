# Phone QA fixes P-4 through P-6 - implementation report (2026-10-23)

> Delivery update: the owner subsequently authorized committing and pushing this verified state to `develop`. See [Git delivery](PHONE_QA_FIXES_DELIVERY_2026_10_23.md); uncommitted-state statements below describe the earlier snapshots.

Scope: [handoff](CODEX_HANDOFF_PHONE_QA_FIXES_2026_10_23.md), [fix plan](PHONE_QA_FIX_PLAN_2026_10_23.md).
Worktree: `C:/Users/zalub/AppData/Local/Temp/culqa`; branch `fix/qa-02-save-status`; HEAD `35992c93c6c4e43385694d101e2a9cfea406898d`.
All changes remain uncommitted. P-1 through P-3 were already present and were preserved.

## P-4 / QA-06 / TD-117

- Production: `lib/presentation/screens/details/night_moon_screen.dart` explicitly uses `AppPalette.textPrimary` for selected tab labels and `textSecondary` for unselected labels; selected weight is 600. Selected/unselected size 14, unselected weight 400 and the 2 px indicator are preserved.
- Test: `test/presentation/screens/details/night_moon_browse_test.dart`, three new tests check rendered styles after choosing each of Night, Moon and Weather in Light, Dark and Field.
- Red: all three tests failed before the fix on selected weight 500 versus 600. Green: the new tests and existing Night/Moon + accessibility regressions, **30 passed**.
- Checks: changed-file format PASS, analyze no issues, encoding PASS, diff whitespace PASS.
- Logs: [red](evidence/phone-qa-fixes-2026-10-23/p4-red.log), [green](evidence/phone-qa-fixes-2026-10-23/p4-green.log), [analysis](evidence/phone-qa-fixes-2026-10-23/p4-analyze.log).

## P-5 / QA-07 / TD-118

- Production: `lib/presentation/widgets/night_browser_sections.dart`, exact-times value uses `Expanded` instead of loose `Flexible`. Label, 8 px gap, right alignment and time data are unchanged.
- Test: `test/presentation/screens/details/night_moon_browse_test.dart`, Geist-loaded geometry at 375 dp and 100/200 percent text checks every exact-time value box against its row edge and the last painted glyph of each interval line against the column edge. The test uses a tall host viewport to lay out the complete disclosure; it does not assert 792 dp phone scrolling.
- Red: at 100 percent, the first interval ended at x=338.57 instead of x=355. The 200 percent case already passed because longer text filled the available width. Green: Night/Moon + accessibility regressions, **32 passed**, including both new scales and P-4.
- A draft glyph assertion initially included trailing-space selection boxes; corrected to measure the actual final glyph of each hard line before recording the red evidence. No existing assertion was removed or weakened. Analysis found a missing-braces lint in the new test; braces were added without changing behaviour, then analysis passed. P-6's full suite also covers the final test source.
- Checks: changed-file format PASS, analyze no issues, encoding PASS, diff whitespace PASS.
- Logs: [red](evidence/phone-qa-fixes-2026-10-23/p5-red.log), [green](evidence/phone-qa-fixes-2026-10-23/p5-green.log), [analysis](evidence/phone-qa-fixes-2026-10-23/p5-analyze.log).

## P-6 / QA-08 / TD-119

- Production: `lib/core/theme/hybrid_tokens.dart` adds `selectedHourFill`, `selectedHourText`, `selectedHourRule`, including constructor, three palettes, `copyWith` and `lerp`; `lib/presentation/widgets/weather_hybrid_view.dart` uses them only on the Weather B hour axis.
- Source verified in `design/home-lab/weather-radix.css` and `colors/radix/scales.css`: Light fill/text/rule `#c2e5ff / #113264 / #0d74ce`, Dark `#004074 / #c2e6ff / #70b8ff`. Field remains `#330000 / #ff0000 / #ff0000` (existing selection/primary/accent).
- Tests: `test/presentation/widgets/weather_hybrid_view_test.dart` pins all three colours and the 2 px rule before and after selecting another hour in all themes; the previous cell returns to its normal style. `test/core/theme/hybrid_tokens_test.dart` checks Field role equivalence, red/black and theme copying/interpolation. `test/presentation/accessibility_test.dart` adds a 4.5:1 selected-text contrast requirement in Light/Dark. The intentional Field secondary-text contrast exception is preserved.
- Red: Light and Dark failed on neutral fill instead of the reference blue; Field already passed. Targeted regressions: weather widgets, hybrid tokens, Field darkness and presentation style rules, **27 passed**.
- Full-suite and final static-check results are recorded in the completion section below. The full unit/widget suite was selected because a shared ThemeExtension changes across all palettes and interpolation, as the handoff requests. No claim of the full release gate or host E2E re-run is made.
- Logs: [red](evidence/phone-qa-fixes-2026-10-23/p6-red.log), [targeted](evidence/phone-qa-fixes-2026-10-23/p6-targeted.log).

## Documentation and evidence boundaries

- `docs/TECH_DEBT.md`: TD-117, TD-118, TD-119 index and details; open-or-partly-open index count 34 to 37, with phone re-check pending.
- `PHONE_QA_FIX_PLAN_2026_10_23.md`: per-task implementation status and verification; its final copy is also placed in the owner's main tree.
- `PHONE_QA_2026_10_23.md`: appended code-fix addendum; original physical-phone observations and verdict are retained.
- New text is English. A Windows Python default-encoding issue in newly inserted Markdown punctuation was repaired; all changed source/docs were explicitly checked as UTF-8, followed by the repository encoding check.
- No physical-phone action, new release build, install, native visual re-check, TalkBack run or owner acceptance occurred. QA-03 and QA-10 are outside this run. Existing browser reference files were read only.
- DTD discovery found only the owner's Android Studio daemon. A hot-reload call returned `No active app connection`; it was not connected to the owner's session or physical phone. Runtime reload is unverified; unit/widget rendering is the evidence here.
- No commit, push, merge, rebase, stash, reset or branch change. Owner changes in the main tree were not edited. Generated platform registrants remain untouched; `git diff --ignore-cr-at-eol --exit-code` on all seven generated files passed (content-identical).

## Suggested commit grouping for owner review

This is a file mapping only; no Git write action was performed. Shared files such as TECH_DEBT, the plan and `night_moon_browse_test.dart` require hunk selection if split into separate commits.

| Task | Application/test files |
| --- | --- |
| P-1 (pre-existing) | `lib/domain/services/current_session.dart`; `lib/presentation/viewmodels/session_plan_viewmodel.dart`; `test/domain/services/current_session_state_test.dart`; `test/presentation/screens/home/plan_save_status_test.dart` |
| P-2 (pre-existing) | `lib/core/theme/app_theme.dart`; `test/core/theme/controls_theme_test.dart`; `docs/DESIGN_SYSTEM.md` |
| P-3 (pre-existing) | `lib/presentation/shared/confirmation_patterns.dart`; `test/presentation/shared/unsaved_prompt_layout_test.dart` |
| P-4 | `lib/presentation/screens/details/night_moon_screen.dart`; tab-style tests in `test/presentation/screens/details/night_moon_browse_test.dart` |
| P-5 | `lib/presentation/widgets/night_browser_sections.dart`; exact-time geometry tests in `test/presentation/screens/details/night_moon_browse_test.dart` |
| P-6 | `lib/core/theme/hybrid_tokens.dart`; `lib/presentation/widgets/weather_hybrid_view.dart`; `test/core/theme/hybrid_tokens_test.dart`; `test/presentation/widgets/weather_hybrid_view_test.dart`; `test/presentation/accessibility_test.dart` |

Include the corresponding debt/plan/evidence documentation with each task as appropriate. Exclude all generated Linux/macOS/Windows registrant/CMake changes. Pre-existing QA images/logs and handoff documents are separately listed in the full inventory below for the owner to review.

## Completion

P-4, P-5 and P-6 are implemented with host verification complete. Full unit/widget suite on the cumulative P-1 through P-6 state: **2463 passed, 6 skipped, 0 failed** (exit 0). Final analysis: **no issues**. Format: **8 files, 0 changed**. Encoding and final diff whitespace: **PASS**. No application/test source changed after the passing full suite; subsequent work is documentation only.

[Full test log](evidence/phone-qa-fixes-2026-10-23/p6-full.log), [analysis](evidence/phone-qa-fixes-2026-10-23/p6-analyze.log), [final checks](evidence/phone-qa-fixes-2026-10-23/final-checks.log).

Physical-phone re-check, new release build and runtime hot reload remain unverified, with the scope/connection reasons above. This completes the authorized implementation run; it does not close phone acceptance or authorize Git delivery.

## All uncommitted files in this branch/worktree

Final snapshot, including this report and pre-existing P-1/P-2/P-3, handoff and QA evidence. `M` = tracked modification, `??` = untracked. No staging/commit was performed. The seven generated registrant/CMake files are line-ending-only and must be excluded from commits.

```text
 M docs/DESIGN_SYSTEM.md
 M docs/TECH_DEBT.md
 M lib/core/theme/app_theme.dart
 M lib/core/theme/hybrid_tokens.dart
 M lib/domain/services/current_session.dart
 M lib/presentation/screens/details/night_moon_screen.dart
 M lib/presentation/shared/confirmation_patterns.dart
 M lib/presentation/viewmodels/session_plan_viewmodel.dart
 M lib/presentation/widgets/night_browser_sections.dart
 M lib/presentation/widgets/weather_hybrid_view.dart
 M linux/flutter/generated_plugin_registrant.cc
 M linux/flutter/generated_plugin_registrant.h
 M linux/flutter/generated_plugins.cmake
 M macos/Flutter/GeneratedPluginRegistrant.swift
 M test/core/theme/controls_theme_test.dart
 M test/core/theme/hybrid_tokens_test.dart
 M test/presentation/accessibility_test.dart
 M test/presentation/screens/details/night_moon_browse_test.dart
 M test/presentation/widgets/weather_hybrid_view_test.dart
 M windows/flutter/generated_plugin_registrant.cc
 M windows/flutter/generated_plugin_registrant.h
 M windows/flutter/generated_plugins.cmake
?? docs/design/migration/CODEX_HANDOFF_PHONE_QA_FIXES_2026_10_23.md
?? docs/design/migration/PHONE_QA_2026_10_23.md
?? docs/design/migration/PHONE_QA_FIXES_IMPLEMENTATION_2026_10_23.md
?? docs/design/migration/PHONE_QA_FIX_PLAN_2026_10_23.md
?? docs/design/migration/evidence/phone-qa-2026-10-23/appearance-light.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/dlg-button-zoom.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/entry-light.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/home-light-b.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/home-light.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/home-nightsheet-light.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/home-sitesheet-light.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/host-gate-35992c9.log
?? docs/design/migration/evidence/phone-qa-2026-10-23/lib-rig-light.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/lib-rigedit-light.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/lib-rignew-light.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/lib-rigunsaved-light.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/lib-site-light.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/lib-targetnew-light.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/library-light.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/logbook-filters-light.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/logbook-light.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/moon-browse-light.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/moon-light-b.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/moon-light.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/night-exact-light.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/night-light-b.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/night-light.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/plan-asm-light.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/plan-budget-light.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/plan-cal-light.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/plan-context-light.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/plan-editor-bottom-light.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/plan-editor-discard-light.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/plan-editor-light.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/plan-leave-dialog-light.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/plan-light-b.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/plan-light-c.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/plan-light.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/plan-menu-light.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/plan-rig-light.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/plan-target-light.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/result-light.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/settings-light.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/sheet-dark-a.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/sheet-dark-b.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/sheet-dark-c.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/sheet-dialogs-compare.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/sheet-field-a.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/sheet-field-b.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/sheet-hourly-zoom.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/sheet-lib-lists.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/sheet-moon-cal-dark-zoom.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/sheet-plan-saved-top.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/sheet-settings-all.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/sheet-site-edit-delete.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/weatherA-hourly-light.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/weatherA-light-b.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/weatherA-light.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/weatherB-light-b.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/weatherB-light.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/zoom-filled-button-edit-site.png
?? docs/design/migration/evidence/phone-qa-2026-10-23/zoom-filled-button-save-target.png
?? docs/design/migration/evidence/phone-qa-fixes-2026-10-23/final-checks.log
?? docs/design/migration/evidence/phone-qa-fixes-2026-10-23/p4-analyze.log
?? docs/design/migration/evidence/phone-qa-fixes-2026-10-23/p4-green.log
?? docs/design/migration/evidence/phone-qa-fixes-2026-10-23/p4-red.log
?? docs/design/migration/evidence/phone-qa-fixes-2026-10-23/p5-analyze.log
?? docs/design/migration/evidence/phone-qa-fixes-2026-10-23/p5-green.log
?? docs/design/migration/evidence/phone-qa-fixes-2026-10-23/p5-red.log
?? docs/design/migration/evidence/phone-qa-fixes-2026-10-23/p6-analyze.log
?? docs/design/migration/evidence/phone-qa-fixes-2026-10-23/p6-full.log
?? docs/design/migration/evidence/phone-qa-fixes-2026-10-23/p6-red.log
?? docs/design/migration/evidence/phone-qa-fixes-2026-10-23/p6-targeted.log
?? test/domain/services/current_session_state_test.dart
?? test/presentation/screens/home/plan_save_status_test.dart
?? test/presentation/shared/unsaved_prompt_layout_test.dart
```

## Subsequent owner-authorized device verification (2026-10-23)

A release/debug-signed APK was subsequently built, installed and checked on the physical phone: [phone re-check report](PHONE_QA_FIXES_PHONE_RECHECK_2026_10_23.md). The six fixes passed the exercised scope; the earlier no-phone/no-new-build statements describe the implementation run before this follow-up. No application/test source changed. The uncommitted-file inventory above is the earlier implementation snapshot and does not include this later phone report/evidence.
