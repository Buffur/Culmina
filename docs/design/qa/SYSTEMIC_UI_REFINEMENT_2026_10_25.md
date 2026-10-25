# Systemic UI refinement — implementation and owner checkpoint

Date: 2026-10-25. Scope: the owner's systemic implementation goal, T2/T1/U1/U2/U3 and the subsequently approved U4-A/B/C; evidence cleanup precedes this continuation. [PROGRESS](../../refinement/PROGRESS.md) owns current state; [OWNER_INBOX](OWNER_INBOX.md) owns VQA dispositions; [reference library](../references/UI_REFERENCE_LIBRARY.md) retains the completed research. No U5/C1, navigation, theme/font, scientific, persistence or dependency change.

Final verification: **PASS for the authorized local implementation and bounded native evidence**. Implementation and inspected visual results are ready for owner review. Matching remote CI, comprehensive physical accessibility and owner acceptance remain pending; this is not product/release acceptance.

## Repository and delivery boundary

- Start: one clean worktree at `C:/Users/zalub/OneDrive/Desktop/Astro Planner/Astro-Planner`, branch `develop`, HEAD and fetched `origin/develop` both `91dd0b517fa46da93b032d552a04254a37b4efbb`; 0 ahead/0 behind, empty index, no pre-existing changes.
- Application baseline: `6b17c92229e5200d423afb1548020cfbc46291c4`; the intervening commits are documentation. Result: the same HEAD, intentional uncommitted application/test/documentation changes; no staging, commit, push, merge, publication, APK build/install/uninstall or data reset.
- Private evidence stays outside Git: `C:/Users/zalub/.codex/tmp/culmina-systemic-20261025/`. Manifests, logs, PNGs, geometry JSON and phone captures are there. Full VM Script copies were removed; correspondence hashes, exact Git blobs and minimal patches remain in source-copy-audit.json. No personal records, real coordinates, private images or decoded Figma material are added to the repository.

## Implemented changes

| Unit / IDs | Actual change and preserved contract |
| --- | --- |
| T2 / VQA-016 | [Hill test](../../../test/presentation/screens/library/library_manage_mode_test.dart) enters distinct synthetic coordinates and verifies the created record as well as unchanged active-site selection. [home_long](../../../test/support/hybrid_transfer_shots.dart) updates the actual existing synthetic site's ID at its unchanged coordinates and asserts the displayed name. Production duplicate-position protection and its tests are unchanged. |
| T1 / VQA-001 | [Candidates](../../../lib/presentation/screens/tonight/tonight_candidates_screen.dart) measures the trailing duration using its actual text style/scaler. When duration, gaps and chevron consume the row width, duration moves below the caption inside the bounded text column. Full title/caption/duration, row navigation, single-button semantics and unrestricted scaling remain. |
| U1 / VQA-007 | [Weather compact rows](../../../lib/presentation/widgets/weather_hybrid_view.dart) measure each full compound with its existing style/tabular figures and scaler. A compound wider than its allocated value column uses the existing stacked composition at full row width. Existing short-value alignment, fonts, all values/units, coverage, sources and gust timing remain. No global FactRows change. |
| U2 / VQA-008 | [Results](../../../lib/presentation/screens/execution/results_screen.dart) contributes the extra middle-section gap only when frames/reasons exist. Every actual adjacent section has one 16 dp gap. Outcomes, counts, notes, reasons, validation, Save/Cancel and IME behavior remain. |
| U3 / VQA-009 | [Target detail](../../../lib/presentation/screens/target/target_detail_screen.dart) separates Loading aliases, sanitized Unavailable + Retry, successful None recorded and populated aliases. Retry replaces only the alias future; current-name filtering, catalogue facts and attribution remain. Pending retry never displays retained error/data as a completed read. |
| U3 / VQA-010 | [Tonight](../../../lib/presentation/screens/tonight/tonight_home_screen.dart) qualifies retained measurements with `Refresh failed · cached forecast` and the existing failure wording. Malformed replies are not called offline. Coverage/age and numeric values remain; successful recovery clears the cue. |
| U3 / VQA-013 | [Plan Rig](../../../lib/presentation/screens/home/plan_rig_screen.dart) shows progress and Loading rigs; error offers Retry and neutral Add or manage rigs. Add rig requires a successful empty read. Initial-empty redirection is explicitly separate from retry loading; request identity rejects older reads. Staged choice survives failed rereads and applies only through Apply. |

No new asynchronous-state framework or package was introduced. Deterministic held reads live only in [test support](../../../test/support/held_library_reads.dart) and [focused regressions](../../../test/presentation/screens/library_async_states_test.dart).

## Retained T1/T2/U1/U2/U3 visual evidence

This section describes the preceding implementation snapshot and its immutable receipts. The continuation's current Git baseline, source cleanup and U4 inputs/results are recorded below; previous temporary reverse-patch/source-copy methods are not the reproduction workflow. Current after inputs use `u4-final-inputs.json`, with before source taken directly from the exact Git worktree.

Native Flutter host, bundled Geist, DPR1, 100% text, 375×812 dp; Weather additionally 412×812 dp. Light/Dark/Field fixtures use synthetic in-memory data and actual production widgets. Final state/proposal JSON records UTC capture time, source HEAD, input manifest, fixture success, actual visible screen types, theme, scale, viewport/DPR and layout/route errors. `final-render-inputs.json` fingerprints application, fonts, dependencies and tests; the final private receipt checks image hashes and relevant input stability.

The 19 October night is frozen synthetic fixture content, not the capture date. Flutter 3.47.4 / Dart 3.13.3 runs these checks. Figma/browser images are not used as native implementation proof.

Final fixture hardening: `home_long` finds the original synthetic Site by its exact fixture coordinates and explicitly selects the renamed fixture record, so a preceding temporary-position step does not require an active saved Site. `t2-sequence-final/` verifies temporary position → long name in all three themes. This isolated lookup/selection changed after `final-clean` capture; none of its 48 cases calls `home_long`. The prior fixture hash and minimal Git patch are retained in the cleanup audit, which preserves the original receipt and lookup/selection comparison; all remaining fixture text and application/font/dependency inputs match. Unaffected final captures are reused under V3 rather than recaptured for a newer timestamp.

| Comparison | Result / private artifact group |
| --- | --- |
| Candidates 100% | Light/Dark/Field before/after PNGs are byte-identical. `before-375/` → `after-375/`, `home_candidates`. The accessibility fixture's separate 200% failure is not extrapolated to the real-font 100% composition. |
| Weather 375 | Wind compound `9 km/h · gusts 18 km/h`: before x182.57, width156.43, height46, ending in orphan `h`; after x36, width160.86, height23, complete on one line. Coverage remains below it. `before-375/` → `after-375/`, `weather_b`, all three themes. |
| Weather 412 | The same wind compound already fits on one line and keeps its original two-column placement. `before-412/` → `after-412/`. Longer metric/imperial compounds are independently checked using actual line boxes at both widths in all three themes. |
| Results | Unselected and as-planned Outcome→Notes change from 32 to 16 dp. Partly and not-done keep 16 dp around their actual frame/reason groups. `results-before/` and `before-375/result` → `after-375/`, four outcomes × three themes. Footer and existing IME tests retain reachable actions. |
| Alias and PlanRig states | `states-before/` → `final-clean/`: pending/error/empty/populated are visibly distinct. Empty PlanRig is a successful empty retry after error; successful initial-empty navigation is separately tested. Earlier baseline images include the test host's debug banner; final clean captures remove only that host decoration. Relevant widget/state comparisons remain explicit. |
| Tonight failure | `home-failure-before-valid/` → `final-clean/home_wxfail-*`: same retained measurements, now qualified. The before caller uses its HEAD-equivalent source with the owned two-line cue temporarily absent and restored; the corrected fixture asserts the root ViewModel's failure before capture. |

The first `home_wxfail` images are **excluded**: they refreshed the scoped Weather-detail ViewModel, not Tonight's root state. This fixture was corrected and re-executed. Initial U4 Sky attempts used a nested non-scrolling list and failed; only corrected successful captures count. `plan_b` stops above Sky and is not its visual proof; `final-clean/plan_c-*` shows the actual production caller. No failed or transition-time image is accepted merely because a PNG exists.

### Physical Android observation

Canonical opened package `io.github.buffur.culmina`; installed version 1.0.0/code 1, last update 2026-10-24. Existing APK retained; its artifact hash/build provenance was not reconstructed. System scale 1.0; VM MediaQuery scale 1.0, 375.38×834.46dp before insets, DPR 3.25,1220×2712px, System resolving to Dark. All six relevant baseline VM Script sources match HEAD after LF normalization. After hot reload all six final VM Script sources match the working source; successful reload alone is not the evidence.

`phone-weather-before-metrics.png` → `phone-weather-after-metrics.png` verifies the same cached wind/gust and temperature/dew-point ranges at the same scroll position, with complete units and full-width compounds. The initial charts preference was temporarily switched to rows, then restored. `phone-planrig-final.png` checks the populated chooser and reachable Apply; it was closed without selecting/applying. Tonight, System appearance, charts and scale were restored/confirmed; no personal record or file was changed. Runtime diagnostics were empty. These are sampled physical observations; held error/loading states remain deterministic host evidence.

## Verification and CI

- T2:88 tests PASS across Library management, Site screens and Site ViewModel, including duplicate refusal/precision protection. The corrected long-name render passes and its actual displayed state was inspected.
- Pilot:37 existing dependent tests PASS; expanded Weather/Results tests 41 PASS, including complete measurement line boxes in metric/imperial units, 375/412 and three themes, all four Results gaps, and existing Save/Cancel/IME scenarios.
- U3: deterministic alias/rig recovery, staged selection and both initial-empty redirects; Tonight current/stale cached failure, malformed response and recovery; existing rig-creation flows pass. Final bounded state/accessibility results are recorded below.
- Cumulative dependent run:135 tests PASS; its new state-test file initially failed to load because of an import placement mistake, subsequently corrected. Passing unchanged dependents are reused under V3/V5; all six focused state tests then passed in the final run below. Counts overlap across runs and are not additive. Intermediate harness/compiler failures remain in private logs and are not represented as passing commands.
- Final native render run:48/48 cases PASS, including24 alias/rig states, three correctly qualified Tonight failures,18 current/proposed U4 excerpts and three actual Plan Sky frames. Actual pixels and JSON state/geometry were reviewed, not only render counts.
- Final accessibility/state tests: **22 PASS** (all 16 existing accessibility tests plus six focused alias/rig tests). This includes all existing main-screen/editor/dialog/map 100%/200% theme scenarios; no accessibility test was removed or weakened. Map tile HTTP400 warnings did not fail these tests and establish no external-map acceptance. Final analyzer: **PASS, no issues**. All 13 changed/new Dart files pass format; encoding and whitespace pass.
- [Documentation CI40142758167](https://github.com/Buffur/Culmina/actions/runs/40142758167) at `91dd0b51`: SUCCESS, documentation-only. Last matching application-code [CI40131435587](https://github.com/Buffur/Culmina/actions/runs/40131435587) at `6b17c922`: FAILURE. No new matching remote CI exists for this uncommitted diff. Local reproduction/fixes do not change that remote result.

## Historical U4 proposal checkpoint

The prior native excerpts supported the owner's separate approval of A, B and C. Those images remain historical proposal evidence outside Git; the127-line reconstruction helper and its shot names are removed from current source. Actual implementation and full-screen evidence follow below. Figma Community inspection remains source-declaration PARTIAL_INSPECTION, without claimed editor rendering, interaction verification or asset adoption.

## Evidence cleanup and exact Git baseline

The continuation approved U4-A/B/C and requested simplifying comparisons first. All 14 full-source copies below were external to Git and unnecessary as render inputs. Each was read/compared against the exact Git source or then-current working source before removal. All were self-created; no owner/unrelated file was deleted.

| Removed external file | Lines | Original purpose; why the full file is unnecessary |
| --- | --- | --- |
| `phone-before-plan_rig_screen.dart` | 209 | Baseline VM audit; identical to the exact Git source. |
| `phone-before-results_screen.dart` | 1018 | Baseline VM audit; identical to the exact Git source. |
| `phone-before-target_detail_screen.dart` | 251 | Baseline VM audit; identical to the exact Git source. |
| `phone-before-tonight_candidates_screen.dart` | 465 | Baseline VM audit; identical to the exact Git source. |
| `phone-before-tonight_home_screen.dart` | 872 | Baseline VM audit; identical to the exact Git source. |
| `phone-before-weather_hybrid_view.dart` | 1597 | Baseline VM audit; identical to the exact Git source. |
| `phone-final-plan_rig_screen.dart` | 225 | Loaded-source audit; matching source is already in the working diff. |
| `phone-final-results_screen.dart` | 1020 | Loaded-source audit; matching source is already in the working diff. |
| `phone-final-target_detail_screen.dart` | 283 | Loaded-source audit; matching source is already in the working diff. |
| `phone-final-tonight_candidates_screen.dart` | 485 | Loaded-source audit; matching source is already in the working diff. |
| `phone-final-tonight_home_screen.dart` | 874 | Loaded-source audit; matching source is already in the working diff. |
| `phone-final-weather_hybrid_view.dart` | 1605 | Loaded-source audit; matching source is already in the working diff. |
| `phone-pilot-weather-source.dart` | 1605 | Duplicate of the final Weather audit source. |
| `final-render-hybrid-shots.dart` | 542 | Prior fixture comparison; exact Git plus a small patch preserves its useful difference. |

Total removed: **11,051 lines / 396,521 bytes**. `source-copy-audit.json` preserves each path, raw/normalized hash, source path, Git blob, match result, role and minimal patch where needed. Original PNGs, geometry, manifests and historical receipt remain. The historical verifier now checks those PNG hashes and the cleanup audit without requiring deleted source files. Runtime checks now compare VM/local strings in memory and save only correspondence metadata.

Git diff including untracked files: **+983/−104, 16 paths initially → +856/−104 after cleanup**. The 127-line reduction removes one-off U4 proposal reconstruction from the existing render harness. The separate 11,051 generated source-copy lines were never Git additions and are now zero. Final diff including newly approved U4 implementation, one new regression and this documentation: **+998/−142 across 22 paths**.

Before authority: **91dd0b517fa46da93b032d552a04254a37b4efbb**. A fresh detached temporary worktree at this exact commit used the existing audit renderer for `library,night_b,plan_c` in Light/Dark/Field at 375×812dp, DPR1, text 1.0: **9/9 PASS**. Every PNG is byte-identical to the corresponding validated historical `states-after/library-*`, `states-after/night_b-*` and `final-clean/plan_c-*` frame. Git blobs and pixel hashes are recorded in the audit/replay receipt; a screenshot filename alone is not provenance.

The temporary worktree was removed after verifying exact path, baseline HEAD and semantic cleanliness. Flutter refreshed generated registrant line-ending/index metadata only; those self-created checkout changes were normalized before removal, without force/reset. No baseline source was overlaid on the active worktree.

Reproduction uses private `reproduce-u4.ps1 -CaptureBaseline`: create exact detached Git worktree → offline setup from the existing lockfile → existing `concept_b_app_audit_renders_test.dart` → external images/logs → checked cleanup. Without that switch the helper captures the current working source with the same three shots. The executed after set additionally includes `plan_sky_open,night_reading_open,moon`. All temporary helpers, PNGs and generated evidence stay outside tracked application source. No historical/proposed widget reconstruction remains in the current harness.

## Approved U4 implementation and retained regressions

The owner approved all three choices; final owner visual acceptance remains separate.

| Unit | Exact production change and actual 100% Light/Dark/Field result |
| --- | --- |
| U4-A / VQA-011 | Only `library.sites` sets existing `SettingsRow.divider:false`; Rigs/Targets rules, counts, labels and navigation stay. Matched Library text sets are identical. |
| U4-B / VQA-011 | Local wrappers forward default-true topRule; only first Night `_ReadingDisclosure` disables it. Sibling Moon/Sun rules and timeline key stay. Night text sets are identical; Moon's separate reading caller keeps its previous default. |
| U4-C / VQA-012 | Planner passes `SkyDarknessWidget(embedded:true)`. The same disclosure/body loses only its outer Card/margin/inset; standalone defaults remain. Nested Card count 1→0, Sky heading x52→36dp. The shorter end-of-scroll group exposes more preceding content; this expected viewport shift is not a different fixture. Open state retains controls, Unknown, provenance and map link. |

**58 targeted tests PASS; 22 accessibility/state tests PASS; 18 actual after native renders PASS**, plus 9 exact-Git baseline renders. Counts overlap with earlier runs. Final checks: analyzer has no issues; all 18 changed/new Dart files pass format; encoding and whitespace pass. Actual full-screen pixels, open content and geometry were inspected; old proposal excerpts are historical only.

Four loaded U4 VM Script sources matched current source after reload using in-memory comparison; no new full source files were written. Canonical physical Android/System→Dark, scale 1.0,375.38×834.46dp/DPR 3.25: Library and expanded embedded Sky sampled read-only, then Tonight restored. No record, Bortle/SQM value, date or plan was edited/saved. Other themes/held errors are native-host evidence, not exhaustive physical/TalkBack or owner acceptance.

Permanent regression inventory:

- `library_manage_mode_test.dart`: Hill creation, exact synthetic coordinates and unchanged active Site. All existing duplicate-coordinate/precision and persistence tests retained.
- `hybrid_transfer_shots.dart`: valid long-name/transient sequence, root Tonight refresh failure, four Results states and a five-line open-Sky step, all through existing actual-widget infrastructure.
- `weather_hybrid_view_test.dart`: measurement line boxes at 375/412 in metric/imperial units and three themes; cached/malformed/recovery truth.
- `results_screen_test.dart`: 16 dp between present sections; original outcome/count/save/cancel/IME tests retained.
- `library_async_states_test.dart` and 35-line `held_library_reads.dart`: six deterministic pending/error/empty/populated/retry/staged-Apply/initial-empty tests; existing settled fixtures cannot create these held reads. Helpers also serve eight reusable visual states.
- `sky_darkness_context_test.dart`: three original standalone fact/provenance tests plus one embedded control/persistence regression proving Bortle does not overwrite independent SQM/source/date.
- Existing audit renderer retains reusable state injection and capture provenance. Only 127 proposal/reconstruction lines were removed. No necessary state-saving, persistence, behavior or accessibility test was removed for line count.

## Owner acceptance checklist and remaining limits

1. Review Weather at 100% in Light/Dark/Field: complete values/units, readable coverage and reachable hour controls.
2. Review all four Results states: consistent section gaps, existing fields/counts/reasons, Save/Cancel and keyboard access.
3. Review aliases and rigs through pending/error/empty/populated/recovery; verify that cached Tonight measurements visibly disclose refresh failure.
4. Review the implemented U4-A/B/C full-screen comparisons and confirm final 100% visual acceptance when satisfied. Approval to implement all three is already recorded.

Owner visual acceptance remains pending. Host accessibility tests do not establish physical 200%/TalkBack or human comprehension. There is no comprehensive 125%/150%/200% redesign, full repository/release gate, real-file/backup qualification or release acceptance here. U1 deliberately changes row placement when content needs more width; longer unseen content/scaling remains a regression risk rather than an asserted exhaustive design acceptance. Retry/navigation guards are covered by deterministic tests, not every device lifecycle permutation. Stop at this checkpoint.
