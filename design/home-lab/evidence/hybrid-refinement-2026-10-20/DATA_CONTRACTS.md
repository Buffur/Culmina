# Hybrid refinement: data contracts and product mapping

Source inspection and model checks, 2026-10-20. Browser integration remains the parent's verification responsibility. Only browser prototype files were edited.

## R1 implementation

- `preview-bridge.js` now exports immutable `initialPlanningPreferences`; `settings.js` clones that source for its initial Planning values. This removes two independently maintained copies of those defaults.
- `readPlanningPreferences(storage, {initialDefaults: true, plan})` opts into those values for a fresh Hybrid plan when no saved `budgetSnapshot` exists. Existing one-argument callers retain the old behavior, protecting other visual variants.
- Stored preferences continue to preview the current global budget. Explicit `plan.assumptions` retain priority. A saved `budgetSnapshot` remains the historical fallback when no Settings have been saved; the new initial values never rewrite it. All of these reads are mutation free.
- The native semantics are explicit: `PlanningPreferences.defaultPerFrameOverheadSeconds = 5.0`, `defaultFeasibilityMarginPercent = 15.0`; `setupMinutes == null` means **Not included**, not an observed zero. See `lib/domain/models/planning_preferences.dart` defaults, optional-overhead contract and `marginFraction`. `FitAnalyzer.analyze()` uses the share of available windows, not fixed minutes (`lib/domain/services/fit_analyzer.dart`).
- Fresh Hybrid fixture: 120 × (60 s + 5 s) = 7,800 s required; no setup contribution; 15% × 15,300 s usable = 2,295 s fit margin. A per-plan margin remains explicit fixed seconds/minutes. A custom site/target with no calculated window has no percentage-derived margin.

### Required parent integration

In `plan.js`, add `preferencesForPlan = () => readPlanningPreferences(localStore, {initialDefaults: variant === 'blend', plan})`; use it in `currentBudget()`, Hybrid margin presentation and the budget-source explanation. Existing `assumptionSource()` will classify fields supplied by that budget as Global default. Display the source as **Settings default** or equivalently truthful wording. Bytes per frame remains a theoretical example fallback; do not label the entire four-field budget as Settings-derived.

Keep Settings-change detection dependent on **stored** preferences (`budgetChanged()` and `budgetChangeReason()`); merely applying initial values must not invent a Settings-change notice. Explain setup null as **Not included** while retaining internal zero contribution for arithmetic. `currentAssumptions()`/Save must continue capturing the effective budget rather than storing preferences on a read.

In `app.js`, `previewEstimate` should use `readPlanningPreferences(localStore, {initialDefaults: state.variant === 'blend', plan: previewPlan})`. Keep `preferenceChanged` dependent on stored Settings. Home's source text must distinguish explicit overrides, current Settings defaults, and saved budget fallback; the time/astronomy window remains an example fixture.

## Focus (F2): unsupported numeric scale

Current native evidence:

- `lib/domain/models/capture_evidence.dart`, `FocusMode`: only `af` and `mf`. Its contract explicitly forbids a numeric focus value, control command, file inference, timing/calibration identity use.
- `lib/domain/models/capture_block.dart`: optional `FocusMode? focusMode` is the persisted block field; there is no focus-position or lens-position field.
- `lib/presentation/widgets/capture_plan/capture_block_dialog.dart`, Focus selector: Not recorded / AF / MF, with "A record only; the app does not control the camera."
- `lib/presentation/widgets/capture_plan/capture_assumptions_panel.dart`, `focusReminder`: words only, no value/control/calculation; scheduled refocus overhead is separate.
- `lib/data/repositories/shared_prefs_planner_state_repository.dart`, `drift_session_repository.dart`, `lib/data/export/session_manifest_codec.dart`: serialize the enum/name, not a numeric lens setting.

**Decision in this pass:** keep the existing honest MF mode record. A numeric MF scale is a separate product/model proposal requiring meaning, units, bounds and persistence approval. Adding a decorative scale now would falsely suggest camera control or measured focus. This condition does not block the other requested work.

## Compact native-to-Hybrid mapping

Implemented native routes/models below were inspected; route presence is source evidence, not device validation. Browser equivalents use isolated preview storage and labelled scientific fixtures.

| Function | Native evidence | Hybrid representation | Difference / action in this pass |
| --- | --- | --- | --- |
| Tonight and candidates | `app_router.dart`: `/tonight`, `/tonight/candidates`; `TonightHomeScreen` | `app.js` Home/candidates sheet | Existing scenario; improve grouped actions and honest budget source (parent). |
| Capture Plan and scoped editors | `/session/:id`, `/select/target`, `/select/rig`, `/select/site`; `capture_block.dart` | `plan.js`, `plan-model.js`: draft, Apply, Save, snapshots, blocks/assumptions | R1 source alignment; preserve draft versus saved, explicit overrides, ISO versus gain and unknown inputs. |
| Night and Moon | `/night`; `night_moon_screen.dart` | `conditions.js`, `night-model.js`, `night-ui.js` | Scientific results are example windows; keep viewed-night versus plan adoption and date/zone labels. |
| Weather | `/weather`; `weather_detail_screen.dart` | `conditions.js`: hourly fixture, unknown/stale/coverage | No live provider request; qualify partial range and use existing humidity data; Home stays compact (other worker). |
| Logbook, result and Progress | `/sessions`, `/sessions/:id`, `/session/:id/results`, `/sessions/progress` | `logbook.js` result/detail/progress | Planned versus recorded remains; add planning prerequisite link in empty state (parent). |
| Library management | `/library/rigs`, `/library/targets`, `/library/sites`; selectors in manage mode | `library.js` root/lists/forms/record selection snapshots | Existing manage-versus-plan selection distinction; root load recovery and source-sensitive copy (other worker). |
| Settings, About and backup | `/settings`, `/settings/about`, `/plan/settings`; Settings/backup sections | `settings.js`, `preview-backup.js` | Browser JSON backup is not native `.astroplan` DB backup. Preserve restore preview/no-op/stale/write-failure behavior. Shared initial assumptions implemented here. |
| Welcome | `/welcome`; firstLocation/onboarding contract | Existing Home welcome sheet | Existing route represented, access needs visible named action (parent). |
| Capture-file metadata import | `/equipment/import`; `metadata_import_screen.dart`; `CaptureMetadata` and readers | Existing Library reviewed metadata JSON flow | Native reads DNG/JPEG/HEIC/FITS headers, other RAW recognized without reading; actual image-header extraction is not implemented in browser. Reproduce supported pick/read/review/apply/missing/error sequence honestly using labelled sample data, separate from JSON backup (other worker owns F1). |
| Focus mode | `FocusMode` and block selector/persistence above | AF/MF optional descriptive record | Numeric lens scale unsupported; separate proposal, do not invent it. |

## Executed verification

`node --test design/home-lab/scripts/check_hybrid_defaults.mjs design/home-lab/scripts/check_bridge.mjs design/home-lab/scripts/check_plan.mjs design/home-lab/scripts/check_quality.mjs`

**38 tests passed, 0 failed.** Five new behavioral tests cover initial units/percentage/setup semantics, fresh Plan after changed Settings, explicit fixed-margin overrides, saved-snapshot preservation, mutation-free reads, unchanged original-variant fallback and unknown-window handling. Existing bridge tests cover current-global preview without rewriting saved plans, Library snapshots and backup refusal/rollback. No Flutter analyzer, native build, Android, TalkBack or real science/provider validation was run for this browser-only change.
