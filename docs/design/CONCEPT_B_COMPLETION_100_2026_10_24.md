# Concept B — whole-app 100% completion

Status: **implemented and verified within the 100% scope; owner review pending**, 2026-10-24. This is the current owner's bounded A–E correction task, followed by one 100% consistency pass. It extends the [nine-screen contract](CONCEPT_B_IMPLEMENTATION_2026_10_24.md); it does not replace the [historical audit](audits/concept-b-app-2026-10-24/README.md).

## Scope and source

Base and unchanged HEAD: `develop`, `f0a5baa14a826784259ad79cd1f42e2607abf3a4`; upstream `origin/develop`. Preflight found one worktree, a clean index/worktree and no other observed implementation writer. A live `git ls-remote origin refs/heads/develop` matched that base. Three subagents reviewed source and actual renders read-only; this worktree had one writer. No commit, push, merge, build, install, restore, reset, export/share or owner-data edit was performed.

Primary geometry: actual production Flutter widgets/router and bundled fonts, 375×812 logical dp, DPR 1, text scaler 1.0. Existing `DocumentSection` supplies semantic `surfaceSubtle`, 16 dp padding and 8 dp radius; page gutters are 20 dp. Existing Geist roles, component actions and source-owned science/data calculations remain. Collection rows use joined section fragments inside their existing lazy lists. Editors retain one Form, all validation fields, fixed save/apply ownership and existing disclosures. Narrow sensor/optics/coordinate pairs stack instead of squeezing two controls into 303 dp.

The prior audit's sources were checked against the baseline; its findings remained applicable. New before renders retain the same production behavior apart from the geometry-neutral CI corrections. The first before invocation lacked its output directory and failed to write seven early frames; those frames reuse the immutable baseline audit, not fabricated new captures. Subsequent before frames and all successful after frames are separate artifacts. Historical audit bytes are unchanged.

## Finding dispositions

| ID | Disposition | Source and evidence | Remaining criterion |
| --- | --- | --- | --- |
| CBA-01 | FIXED | `main.dart` captures the active Field/Appearance at the confirmed restore boundary. `RestoringBackupApp` uses the Field theme and root filter, or the chosen Light/Dark/System mode. Four theme/Field combinations plus the existing locked restore screen test; final `restore_wait` Light/Dark/Field renders. | No destructive physical restore rehearsal; unsupported-database recovery has unknown persisted appearance and retains its separate safety exception. |
| CBA-02 | PARTIAL | Four detail callers no longer force a single title line. The 100% entry title includes its date; a long three-line rig name was inspected on the attached phone. | **Open at 200%**. Shared app-bar width issue CBA-03 and physical accessibility qualification remain. |
| CBA-03 | DEFERRED | Shared app-bar/Field-action measurement is unchanged. Historical reproduced evidence remains authoritative. | Separate 200% correction and render evidence. |
| CBA-04 | DEFERRED | Shared `FactRows` behavior is unchanged. Full 100% facts and units were inspected within new groups. | Separate 200% label/value reflow and evidence. |
| CBA-05 | FIXED | `CapturePlanWidget` inserts `AppSpacing.sm` between the existing block-list actions and optional Fill action. Actual final `plan_actions` geometry records the gap. Both actions/callbacks remain. | Owner visual acceptance. |
| CBA-06 | DEFERRED | Record-result footer is unchanged; its 100% adopted groups remain. | Separate 200% equal-height footer/IME correction. |
| CBA-07 | FIXED within 100% scope | All nine Library children below, source review, real-font renders and dependent Library/equipment/target/site tests. | Adaptive/physical accessibility and owner acceptance remain separate. |
| CBA-08 | FIXED within 100% scope | All seven Plan children below; draft Apply remains distinct from Save plan. | Adaptive/physical accessibility and owner acceptance remain separate. |
| CBA-09 | FIXED within 100% scope | Entry detail and Progress below; all comparison/provenance/export data retained. | Adaptive/physical accessibility and owner acceptance remain separate. |
| CBA-10 | FIXED within 100% scope | All five Settings children below; immediate settings remain immediate and Planning retains Save/Cancel. | Adaptive/physical accessibility and owner acceptance remain separate. |

## Child-page matrix

All rows are **FIXED at 100%** within the specified composition scope. Evidence links point to final Dark/100% production-widget frames; scrolled, IME, failure and theme samples are indexed in the machine-readable coverage and frame manifests. These are host Flutter renders, not photographs of a device.

| Screen | Correction | Evidence | Residual question |
| --- | --- | --- | --- |
| Library — rigs list | Search/Add; continuous lazy results; photo help; empty/search states | [Rigs](migration/evidence/concept-b-completion-2026-10-24/final-dark-100/lib_rigs-dark-1.png) | Owner/adaptive review |
| Rig detail | Identity/actions; Camera; Optics; complete sources disclosure | [Rig](migration/evidence/concept-b-completion-2026-10-24/final-dark-100/lib_rig-dark-1.png) | CBA-02/04 at 200% |
| Rig editor | Identity; camera type/NR; sensor; optics/tracking; optional records | [Editor](migration/evidence/concept-b-completion-2026-10-24/final-dark-100/lib_rig_edit-dark-1.png) | Physical IME beyond sampled opening |
| Library — targets list | Search/Add; Your targets; continuous catalogue/source group | [Targets](migration/evidence/concept-b-completion-2026-10-24/final-dark-100/lib_targets-dark-1.png) | Owner/adaptive review |
| Target detail | Identity/edit; complete attributes/source; explanatory/actions group, both record kinds | [Target](migration/evidence/concept-b-completion-2026-10-24/final-dark-100/lib_target-dark-1.png) | CBA-02/04 at 200% |
| Target editor | Identity/type; J2000 position; optional size/magnitude | [Editor](migration/evidence/concept-b-completion-2026-10-24/final-dark-100/lib_target_new-dark-1.png) | Physical IME; catalogue precision retained by tests |
| Library/select — sites list | Saved/current/transient rows remain together; alternative-position group remains last | [Sites](migration/evidence/concept-b-completion-2026-10-24/final-dark-100/lib_sites-dark-1.png) | Native GPS/map/provider flows beyond this task |
| Site detail | Identity/edit; position/zone facts; optional details; existing delete | [Site](migration/evidence/concept-b-completion-2026-10-24/final-dark-100/lib_site-dark-1.png) | CBA-02/04 at 200% |
| Site editor | Position actions/coordinates; name/zone; optional details; save-effect copy | [Editor](migration/evidence/concept-b-completion-2026-10-24/final-dark-100/lib_site_edit-dark-1.png) | Physical GPS/name-provider rehearsal; guards unchanged |
| Plan — site and night | Joined site selection/manage group; independent date/zone/help group | [Context](migration/evidence/concept-b-completion-2026-10-24/final-dark-100/plan_context-dark-1.png) | Owner/adaptive review |
| Plan — rig | Joined selection/help/manage in populated, empty/loading/error branches | [Rig chooser](migration/evidence/concept-b-completion-2026-10-24/final-dark-100/plan_rig-dark-1.png) | Owner/adaptive review |
| Plan — target | Search/count/context; continuous lazy choice/manage group | [Target chooser](migration/evidence/concept-b-completion-2026-10-24/final-dark-100/plan_target-dark-1.png) | Owner/adaptive review |
| Capture Block editor | Context/frame/source; exposure/count/filter/sensitivity; conditional records; Details | [Block](migration/evidence/concept-b-completion-2026-10-24/final-dark-100/plan_editor-dark-1.png) | Physical IME/camera-class matrix beyond host tests |
| Plan assumptions | Timing fields together; theoretical storage separate; original reset/Apply | [Assumptions](migration/evidence/concept-b-completion-2026-10-24/final-dark-100/plan_asm-dark-1.png) | Owner/adaptive review |
| Calibration | References/context; one group per proposed frame type; existing warning/Apply | [Calibration](migration/evidence/concept-b-completion-2026-10-24/final-dark-100/plan_cal-dark-1.png) | Owner/adaptive review |
| Candidates | Context; full-width Sort/Type and existing filters; continuous lazy results | [Candidates](migration/evidence/concept-b-completion-2026-10-24/final-dark-100/home_candidates-dark-1.png) | Physical long-list/profile qualification |
| Logbook entry | Outcome/actions; planned/recorded; saved snapshot; notes/conditions; totals; export/manage | [Entry](migration/evidence/concept-b-completion-2026-10-24/final-dark-100/entry-dark-1.png) | CBA-02 at 200%; OS share/export not exercised |
| Progress | One complete group per target, retaining filter/rig comparison rows and guide | [Progress](migration/evidence/concept-b-completion-2026-10-24/final-dark-100/logbook_progress-dark-1.png) | Owner/adaptive review |
| Appearance | Theme/Field; Text size; Units; Weather view; persistence retry intact | [Appearance](migration/evidence/concept-b-completion-2026-10-24/final-dark-100/settings_appearance-dark-1.png) | CBA-03 at 200% |
| Planning settings | Budget/scope; imaging window; gates/optional times; guidance; staged footer intact | [Planning](migration/evidence/concept-b-completion-2026-10-24/final-dark-100/settings_planning-dark-1.png) | Owner/adaptive review |
| Privacy | Immediate place-name setting/retry; separate transfer disclosure | [Privacy](migration/evidence/concept-b-completion-2026-10-24/final-dark-100/settings_privacy-dark-1.png) | No live third-party request needed |
| Backup/Restore | Separate Back up and Restore groups; original notices/confirmations | [Backup](migration/evidence/concept-b-completion-2026-10-24/final-dark-100/settings_backup-dark-1.png) | Destructive restore/OS file workflows not exercised |
| About | Identity; continuous lazy source/notice section; privacy; licence/actions | [About](migration/evidence/concept-b-completion-2026-10-24/final-dark-100/settings_about-dark-1.png) | Native licence page retained as an exception |

## Verification and limits

The local CI blockers are corrected without changing geometry: raw 16 dp padding in Night/Moon and Weather now uses `AppSpacing.md`, and the audit test is formatted. CI configuration and its three shards are unchanged. Remote run `40104867669` is the owner's reported failed baseline; no new remote run is claimed. Remote CI for this unpushed state is **pending**.

Final checks: **183 retained 100% frames** (131 Dark, 26 Light, 26 Field), zero route/layout exceptions; **270 dependent tests** plus **78 Logbook/Settings/About/consistency tests**, with the final **15-test Logbook recheck** after the helper correction. Analysis, changed-file format, encoding and whitespace pass. The measured Material buttons in the final receipts all retain at least 48×48 dp targets. The 36 screen-source files plus seven auxiliary sources have current dispositions in [coverage.csv](migration/evidence/concept-b-completion-2026-10-24/coverage.csv). This is proportional V1 shared-UI verification; no full G1/F26/release gate is claimed.

The one bounded consistency pass found an existing 100% truncation in Logbook's optional-name helper. A naturally wrapping helper widget now preserves the full text and existing Save/Cancel/counter; its [before](migration/evidence/concept-b-completion-2026-10-24/before-consistency/entry_name-dark-1.png) and [after](migration/evidence/concept-b-completion-2026-10-24/final-dark-100/entry_name-dark-1.png) are retained. Remaining exceeded-line flags belong only to the already accepted compact Home site context and text-field search hints, whose full accessible context/field labels remain. No further style exploration or open-ended polish followed. Existing TD acceptance statements are unaffected, so TECH_DEBT is unchanged; CBA IDs and deferred requirements remain explicit here and in PROGRESS.

Existing accessibility tests were kept. The Appearance geometry assertion now accounts for the newly required 16 dp inner inset on each side (340 dp inside a 412 dp page); it still checks full-width choices, complete labels and containment. An actual existing 200% test exposed new overflow in the NPF slider's endpoint labels at the reduced width; changing their Row to a wrapping layout retains both labels and avoids that regression. Passing these tests is not a full 200% audit or closure of CBA-02/03/04/06.

The connected Android phone was inspected through its resolved canonical `io.github.buffur.culmina/.MainActivity`, version 1.0.0+1, debuggable. At observation it reported physical 1220×2712 pixels, density 520 and system font scale 1.0 (about 375.4 dp window width before insets). Initial `flutter attach`/hot reload left the editor's old source loaded; VM Script inspection reproduced that mismatch. A successful hot restart loaded the current editor, Settings and main source markers, and final captures show the grouped editor and long record header. The final helper change was hot reloaded; runtime errors were empty. No build/install was performed: the updated running debug session is distinct from the unchanged installed APK, whose SHA-256 is in the receipt. Private captures stay outside Git; they are not sent to Figma/ImageGen or published. This is sampled physical UI/debug evidence, not exhaustive device acceptance, a newly built APK receipt, a real restore or TalkBack qualification.

No visual exploration was needed: accepted Concept B supplied the direction and the defects were concrete. Figma authentication succeeded in this client; no template/library adoption, paid API, credit purchase or external image upload was required. Maps, native dialogs/calendar, licence page, welcome/metadata cards, scientific graphics and sparse safety/error prompts retain their documented functional exceptions.

Final receipts, coverage, fingerprints and exact check counts are in [verification.json](migration/evidence/concept-b-completion-2026-10-24/verification.json). Complete only this 100% stage and its review. 125%/150% follow after owner review of this result; full 200%/TalkBack, owner acceptance and F/G/release criteria remain open. No automatic Git/device delivery or new roadmap follows.
