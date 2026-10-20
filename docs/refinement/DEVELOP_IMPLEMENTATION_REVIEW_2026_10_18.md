# Develop implementation review — 2026-10-18

**Verdict: the final completion plan is not complete.** This is an interim implementation checkpoint, with a newly reproduced F01 data/settings recovery defect. It is not a release candidate or a completed finite implementation pass.

## Baseline and method

- Local develop fast-forwarded from `83d2f41` to **`e1b78ca1b5d4543ac92fd24dac22f8f4e3c1cdc9`**, matching origin/develop at review. Twelve new commits; no local work was overwritten.
- Contract: [FINAL_COMPLETION_ROADMAP](FINAL_COMPLETION_ROADMAP.md), P6-2026-10-18-08 / AM-05, 26 F tasks, 127 criteria and G1–G4. Current run ledger is [PROGRESS](PROGRESS.md), lines 55–85. Existing functionality is not being called absent merely because a finishing task is unimplemented.
- Checked current ledger/attention items, the implementation diff, affected source/test paths, six task evidence files, the proposed ADR sheets and the live GitHub CI result. This is bounded completion assessment, not a new global product audit or a certification that every criterion was executed.
- GitHub API confirms [CI 39146586823](https://github.com/Buffur/Culmina/actions/runs/39146586823) completed with success at `fe33b7b`. The only later change is PROGRESS Markdown, so that gate result is reusable under V3. It does not establish all plan criteria or device behavior.
- A focused new host probe exercises an uncovered rollback interruption using real temporary SQLite files and production restore/preferences functions with an in-memory SharedPreferences platform store. Flutter 3.47.4 / Dart 3.13.3, Windows host. No owner database, private sample, app install, backup activation on owner data, Android/emulator run or physical phone was involved.
- Application code and normal tests are unchanged by this review. The probe is in ignored build output; reproducible source and results are preserved below. No implementation fix, commit or push is part of this assessment.

## Completion accounting

**0/26 tasks fully VERIFIED; 8 tasks touched, including decision-only work; 18 tasks not started; 0/4 gates passed.** This is not an implementation percentage. F01, F02 and F24 have substantial code/test changes, but none closes all acceptance; F01 additionally fails the new invariant probe.

| Item | Assessed disposition | Evidence / missing requirement |
| --- | --- | --- |
| F01 | NEEDS ATTENTION; implementation present, confirmed defect | Pick/activation validation, restart, journal and outcome work exist. New rollback-resume case mixes old DB with backup settings, violating A3; U/visual/phone rows also pending |
| F02 | Implemented resources; acceptance pending | Static splash resource correction and host test; no Android compilation/API 26–30 launch; A2/A3 not observed |
| F03 | Decision preparation only | ADR-021 sheet PROPOSED; acceptance and v26 migration absent; production schema remains 25 |
| F04 | Not started | Extended typed metadata contract not implemented |
| F05 | Not started | Revised rig/manual/photo entry and invoking-plan selection not implemented |
| F06 | Not started | New basic capture hierarchy, WB/AF-MF records, fractional exposure, complete origin/guard/apply work absent |
| F07 | Not started | New compatible measured/theoretical storage contract absent |
| F08 | Not started | Reviewed photo-to-light-block workflow absent |
| F09 | Not started | Finishing calibration tuple/proposal and replacement-empty-state work absent |
| F10 | Not started | FITS reader and real-file flow absent; sample remains an attention item |
| F11 | Not started | Required primary relative-gain / Details presentation not delivered |
| F12 | Not started | Effective assumptions, grouped Settings return and agreed focus guidance work absent |
| F13 | Decision preparation only | ADR-022 sheet PROPOSED; new predicates/interval contract implementation not begun |
| F14 | Not started | New multi-night coverage and specified hourly visual experience not delivered; existing forecast UI remains |
| F15 | Not started | Moon calendar and read-only time slider absent |
| F16 | Not started | New one-screen optional onboarding absent |
| F17 | Not started | New Home hierarchy/title contract absent; current edits are position labels, not this task |
| F18 | Not started | New compact Planner/stable Save/full night-phrase work absent; Tonight for this target still rendered |
| F19 | Not started; independent work remains | Current-saved-night early-result rule still refuses before night end; new Logbook outcome/progress work absent |
| F20 | Not started | Recorded-acquisition AstroBin CSV contract not delivered |
| F21 | Partial | A6 place-name switch persistence covered by tests; A1–A5 appearance/units/planning-settings persistence still absent |
| F22 | Partial tests | A3 kill/legacy persistence tests added; no new route/process-restoration implementation, A1/A2 or v26 evidence |
| F23 | Partial | Municipality, draft GPS-name proposal, coordinate edit guard and unsaved-position label delivered/tested; notice alignment, U and live/device rows pending |
| F24 | Implemented; integration closure pending | All six bounded maintenance rows have code/tests; recheck affected inputs after unfinished dependencies. Does not close the other F tasks |
| F25 | Not started | No final changed-surface U renders/acceptance, accessibility sweep and completed W records |
| F26 | Not started | No qualified signed candidate, measured D6 choice, public signer/artifact/checksum qualification |
| G1 | Not started / prerequisites incomplete | Green host CI is one component, not completed pre-packaging qualification |
| G2 | Not started | No exact selected release APK phone qualification |
| G3 | Not started | No final finite evidence reconciliation and owner go/no-go |
| G4 | Not started | No authorized publication/verified tested download |

## Findings

### R1 — P1: interrupted rollback can restore the wrong preferences

Binding: **F01 A3 / CHK-F01.A3** and A5's truthful outcome. Source: [backup_staging.dart](../../lib/data/backup/backup_staging.dart), particularly `apply` lines 142–157, `_swap` lines 173–205 and `_rollBack` lines 223–251.

Reproduction at the reviewed commit:

1. Original real SQLite has site 1; the original persisted selection is site 1. A staged backup has site 2 and selected site 2.
2. Inject an activation I/O failure at the preferences step after the new DB moved in.
3. Rollback restores the old DB and its old preferences. Simulate process death immediately after `putBackPreferences`, before cleanup removes the forward-recovery journal and staged settings.
4. Invoke production `BackupStaging.apply` again, as startup would. It sees the journal and an existing live DB but no staged DB, assumes forward completion and reapplies the backup's settings.

**Observed:** `completedAfterInterruption`, database site **1**, selected-site setting **2**. This is neither the coherent old pair nor the coherent new pair required by A3. Other carried preferences can similarly belong to the wrong database. The reported completion also describes the wrong selected recovery state.

The ordinary-I/O-failure control passes. The interrupted-rollback invariant fails: **1 passed, 1 failed**. This is a simulated death boundary in a host test with production file operations, not a physical process-kill/device claim. The tests previously recorded as A3 PASS cover forward activation boundaries and uninterrupted rollback; they do not prove this case. A green CI does not negate it.

Required bounded correction: make recovery distinguish rollback from forward completion and make rollback itself restart-safe; preserve a coherent DB/preferences pair and truthful durable outcome. Add a regression for interruption during rollback and affected cleanup boundaries. Keep this within F01; no new feature or task is needed. This review does not implement the fix.

### R2 — P2: current handoff still contains contradictory pre-run status

[PROGRESS](PROGRESS.md) correctly records launch and partial implementation in lines 31 and 55–85, but still states no F task started in its amendment summary, Stage A not started at line 39, start command not submitted at line 100, and run prepared/not launched at line 108. The code-baseline/delivery description also still describes the preparation rather than the current code. The historical defect list still calls the original restore defect open although pick-time validation changed.

These are current operational sections rather than a clearly isolated historical appendix. A new session reading only the advertised current summary could restart work or misidentify the active blocker. Reconcile those statements to the run ledger and distinguish the original invalid-candidate fix from new R1. This assessment leaves operational claims unchanged and reports the contradiction explicitly.

### R3 — existing integration/resource/decision gaps remain real

- [ADR-021](ADR_021_DECISION_SHEET.md) and [ADR-022](ADR_022_DECISION_SHEET.md) are explicitly PROPOSED, not accepted or implemented. They explain substantial dependent work remaining; they are not completed implementation evidence.
- The run ledger says the cloud session lacked Android SDK access and Google downloads were denied (403), and normal GitHub push lacked permission. Those are reported environment constraints, not proof that local SDK/emulator work is impossible. They do not prevent host renders or independently eligible F19 work. The checkpoint itself names F19 A2/A5 as next and says the run continues; it is not a completed AM-05 finite pass.
- `pubspec.lock` still pins `material_ui` 1.3.0. The [primary pub.dev API](https://pub.dev/api/packages/material_ui/versions/1.3.0) independently returned `retracted: true` on 2026-10-18. Its release disposition remains open in the existing attention register; this is not evidence of a newly reproduced runtime/security bug or authorization to upgrade dependencies during review.
- No current U/owner-visual acceptance or release/device evidence is established by the six implementation README files. Existing app functions and earlier dated evidence remain distinct from these finishing requirements.

## Focused observation evidence and reproduction

- [Probe patch](evidence/finalization/develop_review_20261018/restore_probe.patch) reconstructs `build/finalization/develop_review_20261018/restore_probe_test.dart` when absent.
- [Host log](evidence/finalization/develop_review_20261018/restore_probe.log), normalized to UTF-8/LF and with local repository path spelling replaced by `<repo>`; no expectation/result was edited.
- [Observation metadata and SHA-256 hashes](evidence/finalization/develop_review_20261018/observations.json).

From repository root, using the pinned existing Flutter installation:

```powershell
# Apply only if the ignored probe file is not already present.
git apply docs/refinement/evidence/finalization/develop_review_20261018/restore_probe.patch
flutter test --no-pub --reporter expanded build/finalization/develop_review_20261018/restore_probe_test.dart
```

The current reviewed code is expected to exit **1**: the second case asserts the required coherent-pair invariant and exposes R1. A future fix must make the assertion pass, not change it to accept the mixed pair. Fixtures use only dedicated temporary directories and mocked preferences. The probe is an assessment artifact, not a permanent committed regression suite or an application fix.

## Conclusions and next allowed implementation work

1. Address R1 in existing F01 and update its A3/A5 evidence; do not describe restore recovery as fully accepted yet.
2. Reconcile the current handoff summary. Preserve the distinction between code present, tests passed, missing acceptance and actual completion.
3. Obtain the existing local ADR acceptances with concrete numbered choices. While pending, continue the already approved independent F19 A2/A5 work and collect actual-widget U renders for changed restore/site/privacy screens; do not wait solely for a physical phone.
4. Continue the original remaining F tasks, then finite G1/F26/G2/G3/G4 qualification. Use targeted changed-area tests and valid CI reuse under AM-05; do not restart global planning or run the entire suite merely for this review's documentation.

The honest current outcome is **partial implementation with attention items**, including a confirmed restore-recovery blocker. No completion percentage or release-readiness claim follows from the number of commits or a passing full test suite.
