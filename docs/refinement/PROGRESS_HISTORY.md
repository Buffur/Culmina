# AstroPlan — Refinement Progress: history

> **Historical record, not current state.** Moved verbatim from `PROGRESS.md` on 2026-09-27 by the
> governance correction, so that `PROGRESS.md` is a short handoff. Nothing here was rewritten. Newer
> entries are not added here as a matter of course: a Stage's validation detail lives in its
> `STAGE_N_*.md` report, and a Task's in its commit and the living registers. The current state,
> reusable evidence and next action are in `PROGRESS.md`. **Exception, 2026-09-27 (Stage 6
> planning):** the Stage 5, governance-correction and amendment entries were moved here verbatim,
> because some of their facts are recorded nowhere else.
> **Exception, 2026-09-28 (Stage 7 planning):** Stage 6's entries were moved here verbatim in the
> same way.
> **Exception, 2026-09-29 (Stage 8 planning):** Stage 7's entries were moved here verbatim in the
> same way.
> **Exception, 2026-10-18 (documentation cleanup):** every `PROGRESS.md` entry from Stage 8 planning to the
> Stage 12–13 closure, its superseded header and next action, its superseded evidence rows and its
> register copies were moved here verbatim (first section below).

## Moved at the documentation cleanup, 2026-10-18 (verbatim)

> Moved from `PROGRESS.md` on 2026-10-18 so that `PROGRESS.md` is a short handoff again. Nothing in this
> section was rewritten; only these headings were added. Where a statement here conflicts with the current
> `PROGRESS.md`, the current file wins: these entries are dated evidence, and their "Next" and "Next allowed
> action" lines are superseded (the S12.3/S12.4 and "Stage 11 remains open" items below were already done or
> superseded when they were moved: S12.3 and S12.4 done, Stage 11 closed as superseded by Stage 17 at G3).

### Header and "Current state" as of 2026-10-17 (superseded)

> The handoff contract for post-roadmap refinement: where work stands, what still binds it, what
> evidence can be reused, and the one next allowed action. Strategy lives in `POST_ROADMAP_PLAN.md`,
> direction in `PRODUCT_DIRECTION.md`, verification rules in `CLAUDE.md` ("Verification Policy"),
> and history in [`PROGRESS_HISTORY.md`](PROGRESS_HISTORY.md) and the `STAGE_N_*.md` reports.
> **Last updated:** 2026-10-17 (audit 09 amendments M1–M16 applied to Stages 12–17; Stage 12–13 closure recorded; documentation only).
> **Next:** the owner's choice for Stage 13's blocker S13V-01 / TD-109 (corrective S13.V1, recommended, or a carry to S16.8 and S17.5); then **S14.1** (ADR-021) on the owner's start instruction, with the FITS-sample request and the CA-OD3 question. S12.2 stays optional.

**Audit 09 applied and Stage 12–13 closure, 2026-10-17** (documentation only; at the owner's request «Можешь внести эти правки в план» [“apply these amendments to the plan”]):
- [`audit/09_COMPREHENSIVE_AUDIT.md`](../audit/09_COMPREHENSIVE_AUDIT.md) §H, M1–M16, written into the Stage 12–17 Tasks (`POST_ROADMAP_PLAN.md` §5, marked "Audit 09"; disposition table "Comprehensive audit 09 disposition"). No Stage or Task added or renumbered; C1–C6 and AUD-01–AUD-17 kept.
- Open owner decisions: CA-OD1 (the brand in the UI tokens, before S16.6), CA-OD2 (APK packaging, at S17.6), CA-OD3 (Undo the last restore, at S14.1).
- [`STAGE_12_13_CLOSURE.md`](STAGE_12_13_CLOSURE.md): **Stage 12 PASS, closed**; **Stage 13 BLOCKED** on S13V-01 (TD-109, the pre-12 splash). S13V-02 (reduced motion) and S13V-03 (final cold-start numbers) carried to S17.5. Run in the session that wrote audit 09 at the owner's request (not a fresh session, disclosed).
- Registers: TD-106 moved to Critical, TD-107/TD-108 to High, TD-109 added (High); RD-17's §8 row marked resolved.
- **Verification:** V1 documentation class: references and IDs checked, `git diff --check` clean. No application test, gate, build or device change.

**Audit integration, 2026-10-17:** [dispositions](STAGES_12_17_AUDIT_AMENDMENTS.md) record AUD-01–AUD-17 in the existing 42 Tasks. The owner's instruction is to finish existing functions; no new Stage, Task, provider, equipment mode or research cycle. AUD-01/02/03 remain open as TD-106/107/108. C1–C6 stay; S16.8 precedes the final S16.7 sweep. AUD-04 does not approve a partial-rig model; S14.1 first reviews the existing required-input contract.

#### Current state (table as of 2026-10-17)

| Item | State |
| --- | --- |
| Phase | Post-roadmap refinement: Stages 0–11 done or closed; **Culmina release roadmap, Stages 12–17** (`POST_ROADMAP_PLAN.md` §5, approved G3 2026-10-17) |
| Current Stage | **Stage 12 closed** (bounded closure PASS, [report](STAGE_12_13_CLOSURE.md)). **Stage 13 in validation, BLOCKED** on S13V-01 / TD-109 (the splash before Android 12). Stage 11 stays superseded by Stage 17 |
| Current Task | **None in progress.** Audit 09 amendments M1–M16 applied to the plan (documentation only); no application Task started; no defect is marked fixed |
| Next Task | The owner's choice for S13V-01 (corrective **S13.V1**, recommended, or a carry to S16.8 and S17.5); then **S14.1** (ADR-021), with the FITS-sample request and CA-OD3. S12.2 optional |
| Code baseline | **`570581e`**: Culmina identity and owner-approved held one-second splash. The independent audit read remote CI run [39042823307](https://github.com/Buffur/Culmina/actions/runs/39042823307) as successful at that commit on 2026-10-17; this documentation amendment neither re-runs nor newly claims that evidence. `Buffur/Culmina` is the source repository |
| Schema | **v25** (S8.6) |
| Toolchain | Flutter **3.47.4** (the CI's pinned version; Dart 3.13.3) at `C:\flutter` (checked 2026-10-17; the earlier `C:\tools\flutter-3.47.4` path no longer exists). Linux reproduction: WSL Ubuntu with the official 3.47.4 Linux archive at `~/ci/flutter` (S12.1) |

**Stages 12–13 implementation/evidence summary (2026-10-17):** the earlier grouped owner authorization covered these Tasks. Current status below supersedes the old header's email/logo prerequisites; it does not assert a formal Stage close or authorize Stage 14 implementation.
- **S12.3 — done:** repository `Buffur/Culmina`, Pages contact/policy and project index are published. HTTP 200 for project/privacy/source is recorded in S13.2 evidence and the independent audit at `570581e`. S15.4/S17.4 will check policy consistency with the already approved forecast change; no new contact or repository-rename action is pending.
- **S12.4 — decided (a)** (DECISIONS E.1): Play services location accepted; a GPL-3.0 §7 additional permission stated in `COMPLIANCE.md` and `README.md`; the About statement follows in S16.8 (C4). Options: [`research/S12.4_PLAY_SERVICES_LOCATION.md`](research/S12.4_PLAY_SERVICES_LOCATION.md). **S12.4 done.**
- **S12.2:** the owner's optional trademark check; not started.
- **S13.1 — done — R3-final approved:** round 1 (V1–V4) rejected; round 2 ([`evidence/identity/round2/`](evidence/identity/round2/README.md)) offered five concepts and the owner chose **C4 Orbit C** (DECISIONS E.1). Round 3 ([`evidence/identity/round3/`](evidence/identity/round3/README.md)): R1 Balanced, R2 Pure, R3 Ice star, R4 Crescent orbit. At the owner's request C5 Star trails was refined too ([`evidence/identity/round3-c5/`](evidence/identity/round3-c5/README.md): T1 Refined trails, T2 Bold trails, T3 Trails forming a C, T4 Comet heads). The owner kept C4 and asked to refine R1, R3 and R4 after studying logo principles: [`research/S13.1_LOGO_PRINCIPLES.md`](research/S13.1_LOGO_PRINCIPLES.md) and round 4 ([`evidence/identity/round4/`](evidence/identity/round4/README.md): R1, R3, R4, R4b with one construction, a curved sparkle and optical centring). The owner chose **R3** and noted it looks off-centre: confirmed (round 4 centred the ink centroid, moving the orbit 1.6 right and 2.4 up); round 5 ([`evidence/identity/round5/`](evidence/identity/round5/README.md)) centres the orbit, adds the splash-animation concept (720 ms AVD storyboard and draft) and the assessment. **S13.1 done:** the owner approved `R3-final` (orbit centred) and the splash-animation concept (DECISIONS E.1). Acceptance 4 is satisfied by the owner's recorded approval; no new artwork vote is pending.
- **S13.2 — done — code (`b29ec34`) and recorded device checks:** id `io.github.buffur.culmina`, label Culmina, Kotlin package and metadata channel renamed together, `AppIdentity` on the Buffur/Culmina URLs (TD-088 resolved), the restore confirmation shows the backup's date (TD-093 resolved); new tests (no earlier id anywhere; one channel name; a backup carries no application id); docs (trap 20, COMPLIANCE, RELEASE "Moving from Astro Planner", README, runbook, ARCHITECTURE, FEATURE_STATUS, TEST_PLAN). **Verification:** full gate PASS after the last code change (1,847 tests, 2 skips; host E2E 2 + 1; Flutter 3.47.4); Kotlin unit tests PASS (`:app:testDebugUnitTest`); debug APK badging `io.github.buffur.culmina`, label `Culmina`. **Device checks PASS (2026-10-17, [evidence](evidence/S13_2_DEVICE_CHECKS.md)):** M1/M4 "Add from a photo" with a DNG and a HEIC on `io.github.buffur.culmina.s2check`, rig saved; backup on the old-id test package → restore on the new-id one: all 9 tables equal, preferences restored; the restore confirmation shows the date (TD-093). Owner apps unchanged; test packages removed. Follow-ups: TD-105 (the confirmation names the current app; "1 sessions"); the owner's IDE installed a debug build under `io.github.buffur.culmina` (uninstall before a release APK). Pushed `d42f053..31ff9bf` (owner-authorized); CI run 39038933720 **success** and Pages build success on `31ff9bf`; `https://buffur.github.io/Culmina/`, `…/privacy/` and `https://github.com/Buffur/Culmina` answer 200 (criterion 7). **S13.2 done; S12.3 done.** The historical next Task S13.3 is now implemented (below).
- **S13.3 — launcher icon and splash:** the approved R3-final mark in `ic_launcher_foreground.xml` and `tool/make_launcher_icons.py` (legacy PNGs, `icon_512.png` regenerated), a separate one-colour `ic_launcher_monochrome.xml`, the animated splash `splash_icon_animated.xml` on Android 12+ (**1,000 ms, held until it has played**, by the owner's decision 2026-10-17 amending ID-6; the 380 ms interim is superseded); the mark fades on navy before the background fades, so it never shows over the app. **Verification of this last change** (owner, 2026-10-17: run only the tests related to the Task, not the full gate every time): `app_identity_test.dart` and `startup_mark_test.dart` PASS, release build and phone recording; the last full gate PASS was on `f89c7c3` (1,851 tests), the static icon before 12, and `StartupMark` on Tonight while startup loads (breathing star; still under reduced motion; no new package). The 272 → 290 ms first-frame comparison belongs to the earlier **non-held** splash; the final held second's visible-content delay is separate (about 1.0–1.2 s in the recorded observation), per the owner's choice. The audit later read remote CI on `570581e` as successful. [Evidence](evidence/S13_3_DEVICE_CHECKS.md). UNVERIFIED on a device: pre-12 splash, reduced motion. The `.s2check` test app is left installed for the owner's look.
- **Verification:** V1 documentation class for the Markdown; the SVG/HTML/PNG assets are outside every gate input (V3); `git diff --check` clean.

### "Current state" entries from Stage 8 planning to the Stage 12–13 closure (newest first)

**Language policy revised, 2026-10-17** (documentation and agent instructions only, at the owner's request): CLAUDE.md now prefers English (not an absolute rule; the user's explicit instruction wins) for new and substantially revised persistent documentation; conversational replies follow the ongoing conversation and the user's latest request, with no fixed default language (this replaces "replies stay in Russian by default" in the "Language correction" entry below, which stays as history); quotations and historical sources stay in their original language; no bulk translation; the application's UI language and the deferred localisation are unchanged. `POST_ROADMAP_PLAN.md`'s shared rule "All in English" now refers to the CLAUDE.md policy. No roadmap Task started.

**Roadmap readiness review, 2026-10-17** (documentation only; [report](STAGES_12_17_READINESS_REVIEW.md)): Stages 12–17 cover every RA.D decision and every finding of the owner's review. One order defect (G1: S17.5 and S17.6 depend on each other; no remote CI run on the release commit) and smaller gaps (G2: the cross-id, cross-schema backup rehearsal on the final build; G3: S14.9's dependencies on S14.7/S14.8; G4: S12.4 option (a)'s About change; G5: `PRODUCT_DIRECTION.md` still states superseded direction; G6: register omissions). Corrections C1–C6 **approved by the owner and applied** the same day (DECISIONS E.1, "Stages 12–17 readiness review corrections approved"): `POST_ROADMAP_PLAN.md` §5 (S14.1, S14.3, S14.7, S14.9, S16.8, S17.5, S17.6, traceability) and `PRODUCT_DIRECTION.md` §9. Next Task unchanged (S12.3 with S12.4; S13.1 is the unblocked alternative). No application checks run (V1 documentation class).

**Documentation correction, 2026-10-17:** CLAUDE.md condensed with V1–V8 retained; numbered traps moved to `docs/ENGINEERING_GUARDRAILS.md`; old full text archived. Duplicate approval in `.agents/rules/00-project-governance.md` corrected; optional skills and animation scope clarified. Product Reassessment scope added without approving UI implementation or closing Stage 11. Application checks were not run (V1 documentation class); reference/consistency checks and `git diff --check` passed; V1–V8 text preserved except for the relocated guardrails reference, all 22 trap numbers and nine review coverage groups retained. The pre-existing modified macOS plugin registrant is outside this Task; no new claim of full-gate evidence reuse is made for the working tree.

**RA.R1 complete, 2026-10-17:** read-only assessment of code at HEAD `b1df679` plus the existing working-tree documentation amendment; all nine review areas covered (RA-A through RA-I); the report is preserved in [`research/RA_R1_PHASE_A_ASSESSMENT.md`](research/RA_R1_PHASE_A_ASSESSMENT.md) (it replaces the earlier chat-only report). Six original reference images were recovered and viewed; the Moon concept project (Moonlit) was inspected too (its own code carries no licence: concept only); the prior generated prompt remains unavailable. Code findings: Welcome is pushed after the first Tonight frame (RA-B01; duration/device reproduction unverified); Home keeps an action-only toolbar (RA-D01); Open planner and New plan have distinct lifecycle effects (RA-D06). ADR-020 explains absent WB/focus, camera-class fields, previous-light proposals and calibration copying (RA-F05–RA-F10); weather already has wind/humidity in detail, but Home summarizes cloud/age (RA-E02). Core capture outputs and record-management surfaces exist; usability is not proven by source/tests. No app/test changes or runs, no fresh gate/phone/CI PASS, no new product decisions. Remaining research: minimum onboarding; Home priorities; compact night/weather presentation; camera parameter intent and proposal clarity; naming/logo/assets; record/settings discoverability. Reuse RG-10/RG-11 and S9.3 before new research. The old "device or emulator" owner-action wording below is historical drift: emulator evidence does not replace the outstanding physical-phone/human checks. Next RA.R2 only on request; do not start implementation. Documentation whitespace check passed; source/test evidence was inspected, not executed.

**Distribution aligned, 2026-10-17** (documentation only; DECISIONS E.1, "Distribution: GitHub Releases only"): Culmina ships as a signed APK on GitHub Releases. Deferred (store distribution): Play upload key and App Signing, the AAB and `check_bundle` as a release requirement, the Data Safety form, the store listing, the Play closed test, Play-only rules. Changed: S12.2 recommended, not a gate (S12.3 and S13.2 no longer wait for it); S13.1 drops the Play icon; S17.4 drops Data Safety; S17.5's N5 becomes "install the release APK and an update"; **S17.6 becomes GitHub release packaging** (release keystore, signed APK, an APK check, `RELEASE.md` with versioning, checksums, install and update instructions); **S17.8 added** (the owner publishes the GitHub Release). Unchanged: privacy, terms, licences (S11P-03 still open), signing, id and update compatibility, backup/restore, accessibility, device validation. `RELEASE.md`, `COMPLIANCE.md` and the identity plan carry deferral notes.

**S12.1 done, 2026-10-17** (TD-104 resolved; commit `461e38c`; remote CI run 39020770255 (https://github.com/Buffur/Astro-Planner/actions/runs/39020770255) PASS on `461e38c`, every step success, after the owner-authorized push `b1df679..461e38c`):
- **Cause, reproduced:** on Linux `equipment_editor_fit_test.dart`'s `setUpAll` could not find `roboto-regular.ttf`: the Flutter 3.47.4 Linux SDK names it `Roboto-Regular.ttf`, the Windows SDK `roboto-regular.ttf`, and only Windows names are case-insensitive. Reproduced in WSL (Ubuntu 26.04, the official 3.47.4 archive, sha256 checked, a fresh LF clone) with the CI's exact count "+1840 ~2 -1".
- **Fix:** `test/support/sdk_fonts.dart` (a case-insensitive lookup) used by the fit test and the opt-in render gallery; `.github/workflows/ci.yml` pins `ubuntu-24.04` and uses `actions/checkout@v5`.
- **Verification (high-risk class: tests and CI steps):** the full gate PASS on **Linux** (WSL, CI-equivalent) and on **Windows**: Encoding, Format, Analyze, 1,844 tests with 2 skips, host E2E 2 + 1. The failing test alone on Linux 4/4; the render gallery on Linux 15 images.
- **Remote:** the owner authorized the push of `main`; the GitHub Actions run on `461e38c` passed (run 39020770255 (https://github.com/Buffur/Astro-Planner/actions/runs/39020770255)). Acceptance 1–7 met; TD-104 and RD-17 closed.

**G3 approved, 2026-10-17** (documentation only): the owner approved the RA.P roadmap, Stages 12–17 (`POST_ROADMAP_PLAN.md` §5; DECISIONS E.1, "RA.P — the Culmina release roadmap approved (G3)"). Stage 11 is closed as superseded by Stage 17 (S11.6 → S17.5, S11.7 → S17.7). The Product Reassessment is complete. Nothing is implemented; S12.1 waits for the owner's start instruction.

**RA.D complete and RA.P proposed, 2026-10-17** (documentation only): the owner answered Q1–Q4 (scope kept, demoted; MF-c; no seeing/transparency provider, a link; the AstroBin CSV export included). RA.P adds **Stages 12–17** to `POST_ROADMAP_PLAN.md` §5 (release foundation; identity; Capture Plan completeness with ADR-021 and v26; night conditions with ADR-022; screens and flow; final validation folding in S11.6 and S11.7), each Task with dependencies, acceptance, its V1 class and stop conditions, and a traceability table for every RA.R1 finding and open TD item. **Awaiting the owner's approval (G3);** nothing is implemented. Starting Task after G3: **S12.1** (TD-104).

**RA.D round 2, 2026-10-17** (documentation only): the owner's release scope principle recorded (a complete release; essential Capture Plan work not deferred for effort); round 2A approved (PD-05 to PD-14, PD-21); PD-02, PD-03, PD-04, PD-16, PD-17, PD-19, PD-20 resolved from the owner's review direction; SI-015 recorded (two Moon-up definitions). Four questions open for the owner ([`research/RA_D_ROUND2_PACKAGE.md`](research/RA_D_ROUND2_PACKAGE.md) Part C: Q1 scope, Q2 Moon definition, Q3 seeing/transparency, Q4 AstroBin CSV). Next: the owner's answers, then RA.P.

**RA.D round 1 complete, 2026-10-17** (documentation only): ID-2 = B (Buffur; RD-01 decided), ID-3 = `io.github.buffur.culmina` (intended), ID-4 = `Buffur/Culmina` (intended), ID-5 = A + C hybrid direction (artwork not approved), ID-6 = S2 (DECISIONS E.1, "RA.D — round 1 identity"). Preparation in [`research/RA_D_IDENTITY_TRANSITION.md`](research/RA_D_IDENTITY_TRANSITION.md): id-migration acceptance criteria with backup and restore across ids, the repository and policy-URL checklist, the logo review step, and the release order (the formal "Culmina" trademark search before the id change). Nothing implemented: the app, id, icon, splash and repository are unchanged.

**RA.D round 1 started, 2026-10-17** (documentation only): **ID-1 decided — Culmina** (DECISIONS E.1, "RA.D — ID-1"), pending formal trademark clearance before store publication; a product-direction decision, no code, application id or repository change. ID-2 to ID-6 are presented to the owner; round 2 not started.

**Language correction, 2026-10-17** (documentation only, at the owner's request): CLAUDE.md now requires English for all persistent project documentation, with replies to the owner in Russian; the RA.R1 report, the RA.R2 plan, the R2a–R2e reports and the decision sheet were translated into English with their findings, IDs, numbers and references unchanged (structure compared against `8e267a6`); the owner's own Russian words are kept as quotes with English glosses. The decision sheet now names the source of each recommendation (R2e's ST2-lite and PD-11 differ from R2b's; ID-2/ID-3 come from R2e). No decision made.

**RA.R2 complete, 2026-10-17** (documentation only; V1 documentation class: links resolve, `git diff --check` clean; no gate): four research steps in parallel, each with dated primary sources and its decision-critical claims spot-checked by the main session (Open-Meteo terms, 7Timer ASTRO, N.I.N.A. row defaults, `com.twtapp` = Stargazing Hub, the Android splash limits, App Store name collisions, a sky-rate vector, the rig's stored fields and the Moon predicates in code). Findings: the capture-plan-before-the-night niche is unoccupied among the mobile planners found (inference from listings); absolute SNR cannot be estimated honestly from the stored inputs (O2, √N over integration time, recommended); the Moon-up predicate of CALC-29/33/43 (centre above 0°, airless) differs from the displayed rise/set (Meeus h₀) by 5–10 min per event (a candidate SI finding); a 16-night overview costs one Open-Meteo request per site; no seeing/transparency provider recommended for 1.0; renaming before the first upload recommended ("Astro Planner" is crowded), shortlist Culmina, AltArc, Astrarc, Arcwindow. No probes run and no screenshots supplied (the plan's §6 permissions were not given): RA-F05, RA-G03 and K12 go to RA.P as verify-then-fix. Next: RA.D.

**RA.R1 follow-up, 2026-10-17 (documentation only):** K2/K3 corrected here: the code is pushed (`origin/main` = `b1df679`) and the repository is public; every CI run failed (`836bbdf`: 1,730 passed, 1 failed; `718c19b` and `b1df679`: 1,840 passed, 1 failed; 2 skipped), recorded as **TD-104** (`TECH_DEBT.md`; the failing test needs the signed-in log; the local gate at S11.C2 stays valid evidence on its inputs, V3). The owner approved the RA.R2 plan (G0).

**S11.C2 done, 2026-09-30** (corrective; S11H-01 to S11H-03; V5):
- The rig editor's derived sensor size uses `AppPalette.textSecondary` and its note `textTertiary` (both
  AA), not the disabled colour and a half-transparent onSurface; "Altitude now" and "Max altitude in
  windows" go through `QuantityText.degrees` (the typographic minus, never "-0.0°"); the zone picker
  adds a check to the current zone (not colour alone; red on red in field mode).
- `stage11_host_fixes_test.dart` (4: the editor's contrast in light and dark, scrolled to the derived
  fields; the minus below the horizon; the check), each mutation-checked.
- **Verification:** shared presentation: the full gate after the change, **PASS** (1,844 tests, 2 skips;
  host E2E 2 + 1; Flutter 3.47.4).

**S11.2 done, 2026-09-30** ([evidence](evidence/STAGE_11_HOST_EVIDENCE.md); the gate at `9668a13` reused, V3):
- **70 HOST rows: 67 PASS**, each with its test, code location or validation citation; five probes run and
  deleted (a name and results through two kills and v24 → v25; the map with every tile failing; the
  editors and the filter panel in the sweep's audit, three themes at 100 % and 200 %; Roboto checks).
- **Blockers (V4 A, each against a frozen row):** **S11H-01** the rig editor's auto-calculated sensor size
  and its note fail AA contrast (2.66:1 and 2.81:1 in light; `disabledColor`, `onSurface.withAlpha(128)`;
  H1); **S11H-02** "Altitude now" formatted by hand (`home_screen.dart:128`): a hyphen-minus and a
  possible "-0.0°", not `QuantityText.degrees` (C8); **S11H-03** the zone picker marks the current zone by
  colour alone (`ListTile.selected`; red on red in field mode; H5). → **S11.C2**.
- Follow-ups: TD-100 (sweep coverage; the target editor's dropdown), TD-101 (hand-formatted quantities),
  TD-102 (probe-only checks), TD-103 (a `print`).
- Documentation drift corrected: `TEST_PLAN.md` (the lifecycle header, L2's button, L7's schema, the 15.3
  and 12.4 checklists, the E2E section) and CLAUDE.md traps 18 and 19.
- **Verification:** the documentation class (V1).

**S11.4 done, 2026-09-30** ([evidence](evidence/STAGE_11_PROVIDERS_COMPLIANCE.md); no blocker):
- **PASS:** N10 (target API 36; 16 KB pages), O5 (the providers' terms re-read), O7 (no secrets; HTTPS
  only; no cleartext), O8 (`COMPLIANCE.md` and the policy against the code, after three factual
  corrections to `COMPLIANCE.md`), Q2 (Play's rules, cited: a new personal account needs a closed test
  with at least 12 testers for 14 days before production; API 36 from 31 Aug 2026; 16 KB pages).
- **UNVERIFIED on this machine, carried to the phone (S11.6):** O1 Open-Meteo, O2 Nominatim, O3 OSM
  tiles, O4 the light-pollution link, G6 About's page loads: the emulator's HTTPS is intercepted by the
  host's antivirus ("Trust anchor … not found"); one host request each confirmed the request contract
  (O2: see TD-097).
- **PARTIAL:** O6 licences: the 114 runtime Dart packages are GPL-compatible and on the licence page;
  the Android libraries' notices are not (TD-098); **S11P-03: `geolocator_android` bundles Google Play
  services location (proprietary) in the GPL-3.0 app — an owner decision** (accept and state it, or use
  the platform location manager: a code change).
- **NOT MET (owner):** O9 the policy is unpublished (404) with `<CONTACT EMAIL>` (TD-088, RD-01).
- Follow-ups: TD-097 (`municipality`), TD-098 (notices), TD-099 (the policy's weather wording). The
  emulator's automatic time is back on.
- **Verification:** documentation and evidence only; `COMPLIANCE.md` restamped.

**S11.5 done, 2026-09-30** ([`STAGE_11_DEVICE_RUNBOOK.md`](STAGE_11_DEVICE_RUNBOOK.md); documentation only):
every PHONE, HUMAN and OWNER row of the matrix has an entry: how phone runs are done (`.s2check`, never
the owner's data); the agent rows for S11.6 (★ L10, M3, M4, E5–E7); the person rows (★ H6 TalkBack,
H7, I2/I3 darkness, A8–A10, ★ Q3 dogfooding); the owner actions (★ N4, N5, N7, N8, N9, O9, O10, O11,
Q5; N6, M6, P2, L7, M5). ★ marks the mandatory rows.
- **Verification:** the documentation class (V1).

**S11.C1 done, 2026-09-30** (corrective; S11F-01 / TD-092 resolved; V5):
- `LogbookScreen` re-reads its list whenever it comes back into view (its tickers enabled again: a tab
  switch, or the planner or another root page closing over it), besides the revision bump of S8.6.
  `logbook_comes_back_test.dart` (2: a plan saved while another tab is shown; a plan saved in the
  planner opened over the Logbook), mutation-checked (both fail without the change). Re-checked on the
  emulator with a release build: the saved plan appears at once.
- The gate also exposed a time-of-day failure: `integration_flow_test.dart`'s "Save twice" case used
  the wall clock and failed between dawn and noon (the night had ended, so the second Save made a copy,
  D8-1). Given a fixed evening clock; the wider sweep is **TD-096** (FOLLOW-UP).
- **Verification:** shared behaviour (the Logbook screen): the full gate after the last change,
  **PASS** (1,840 tests, 2 skips; host E2E 2 + 1; Flutter 3.47.4); the emulator re-check (V5: the
  original finding, its criterion, the correction's own tests).

**S11.3 done, 2026-09-30** (the emulator rows; [runs](evidence/STAGE_11_EMULATOR_RUNS.md); RUNTIME
VERIFIED, emulator, D11-1):
- **Passed:** L1 (fresh install offline), L2 (location denied, denied forever, services off), L3 (the
  data), L4 (a kill during the saved night: Tonight's result line, one copy), L5 (rotation, dark mode),
  L6 (a zone change after the night), L8 (a full disk, with notes), L9 (the core-loop E2E), B6 (2.4's
  Los Angeles evening), F13 (backup, reinstall, restore; a newer backup refused), F14 (Auto Backup
  through the local transport, release build), F15 (Share and Export), F16 (a newer database explained
  with no reset; a below-floor file reset with `.v7.bak` kept), G7 (identity; the splash not captured),
  J5 (offline with data), N2 (the whole session on the release build), N3 (the bundle check, failing
  only on the debug signer, as designed). `TEST_PLAN.md` records them.
- The E2E needed two test changes to run on a device (`1af00be`): the test's text input registered,
  the view-size override kept on the host.
- **Blocker S11F-01 = TD-092:** a saved plan is missing from an already-open Logbook until a restart
  → **S11.C1**. **Follow-ups:** TD-093 (the restore confirmation lacks the backup's date), TD-094 (the
  screen is not restored after a process death), TD-095 (the autosave banner after a successful Save);
  wording notes in the runs file.
- **Verification:** documentation of runs (the runs themselves are the evidence); no code changed in
  this commit.

**S11.1 done, 2026-09-30** (the validation matrix, [`STAGE_11_MATRIX.md`](STAGE_11_MATRIX.md); documentation only):
- 130 rows in 17 groups (A core answer … Q owner decisions and go/no-go), each with its source, the
  evidence level it needs, its environment (HOST, EMULATOR, PHONE, HUMAN, OWNER) and whether it is
  mandatory for beta readiness (D11-2): **28 mandatory**. 62 rows already hold evidence at their level
  (mostly TEST VERIFIED through the Stage 6–10 validations and S10.6's gate; M1–M3 DEVICE VERIFIED).
  No EMULATOR, PHONE, HUMAN or OWNER row has evidence yet.
- Coverage: every Appendix B item with Stage 11 as its destination and every Scope and "What it
  checks" bullet maps to rows or to a stated exclusion (16.5 per D11-6; the beta run itself; the
  retired tracker's device checks; the low-end phone kept as UNVERIFIED row M5).
- Drift noted for S11.2: `TEST_PLAN.md`'s lifecycle header ("no emulator"), L7's "v17" (the schema is
  v25), and the 15.3 and 12.4 checklists still walking the tracker.
- **Verification:** the documentation class (V1): references resolve; `git diff --check`.

**S10.C1, 2026-09-30** (a correction to Stage 10's record, found by S11.3's first emulator E2E attempt;
V6 (a): new evidence; [record](evidence/STAGE_10_MEASUREMENTS.md), "Correction: typing on a device"):
- In profile mode a test's typed text never reached the field (the framework drops the test's client
  id without asserts; on a device the real keyboard also overwrites it). Stage 10's profile rows that
  type recorded taps and animation only; they are superseded. The host counts, the focus step with the
  real keyboard, the ViewModel edits and the timings were unaffected.
- `perf_scenarios_test.dart` registers the test's text input after the focus step and asserts every
  typed text arrived. Two new runs: typing in the rig editor, the block dialog and the Logbook stays
  within the frame (build averages 1–3.5 ms); the search has 2–3 frames over per run (worst 19–30 ms).
- The emulator's second session is far faster than the first (seed 121 ms vs 1.7–2.5 s): numbers are
  comparable only within a session. ENG-12 re-checked within it: 815 ms without the transaction, 121–122
  ms with it (6.7×). Stage 10's conclusions stand.
- **Verification:** test code only: analyze clean; the suite passes on the host; two emulator runs in
  profile mode, plus one with the seed's transaction temporarily reverted (restored; `lib/` unchanged).

**Stage 11 planned, 2026-09-30** (documentation only; the plan's "Stage 11 — frozen Task sequence"):
- Inputs verified at `e6b6172` and on this machine: the emulator (Android 16, Google Play image, TalkBack
  installed, Backup Manager off, 4.8 GB free) can carry the E2E, most lifecycle rows, the refused
  database, backup and restore, permissions, offline, live providers and a release install as RUNTIME
  VERIFIED (emulator); the phone rows (Stage 10's phone runs, TalkBack, red mode in darkness) and the
  human rows (the walkthrough, comprehension, the go/no-go) wait for the phone and the owner.
  `TEST_PLAN.md`'s E2E text still describes the tracker (S11.2 corrects it).
- **Frozen:** S11.1 matrix → S11.2 host, S11.3 emulator, S11.4 providers and compliance → S11.5 phone and
  owner runbook → S11.6 phone runs (when connected) → S11.7 readiness record and final validation.
  Decisions D11-1 to D11-6 (E.1): evidence by environment; what is mandatory for readiness; the phone
  through `.s2check` only; **RD-15: no diagnostics export in the beta**; RD-17 stays the owner's; 16.5
  only on a release decision.
- **Verification:** the documentation class (V1). S10.6's gate is Stage 11's baseline (V3).

**Stage 10 closed, 2026-09-30** (validation PASS, [report](STAGE_10_VALIDATION.md), `08652ca`; fresh
independent session; S10.6's gate reused, V3; its own probes P1–P4 run and deleted):
- No V4 blocker. Four follow-ups, handled at once (the owner's standing request to fix every finding):
  - **S10V-01:** the suite's section step used a wrong key and skipped silently, and no exposure was
    edited. Fixed; one emulator run recorded (both within the frame).
  - **S10V-02:** the suite's header command gains `--no-dds`.
  - **S10V-03:** the two arm64 APK sizes differ by build command (`--target-platform` also packs
    other ABIs' plugin libraries, 209,032 bytes); D10-3's "what a phone receives" is the
    `--split-per-abi` proxy. Recorded in the evidence file.
  - **S10V-04:** "responsive on representative hardware" stays UNVERIFIED (D10-1). **Carried to
    Stage 11:** phone runs of `perf_scenarios_test.dart` (the rig editor's focus, the planner and
    timeline, the Logbook at 300 sessions, first-run seeding).
- Notes kept: large text not profiled (nothing changed); ENG-11 closed for the session list; at a
  future dependency upgrade check that `sqlite3_flutter_libs` 0.5.x does not return (N3); the gate
  runs no E2E step if `integration_test/` were empty (N4).
- **Verification (the follow-ups):** test code only: format and analyze clean; the suite passes on the
  host and ran on the emulator. The gate's other inputs are unchanged since S10.6's PASS.

**S10.7 done, 2026-09-30** (build and release options; [record](evidence/STAGE_10_MEASUREMENTS.md) §S10.7):
- Measured on an arm64 release APK: `--split-debug-info` −1.31 MB (−5.2 %), `--obfuscate` −0.20 MB
  more. **Not adopted:** the first makes release stack traces unreadable without a per-release symbols
  file (a release-procedure and RD-15 matter for the owner); the second hides nothing in an
  open-source app. `RELEASE.md` gains a "Size" section (the baseline and the option) and "Build notes"
  (the antivirus TLS and the cross-drive Kotlin workarounds). No build configuration changed.
- **Stage 10's size result:** the release baseline stands (24.8 MB per arm64 phone, 27.8 MB
  installed); no reduction claimed; the 277 MB was a debug install.
- **Verification:** the documentation class (V1): no build file changed; references resolve;
  `git diff --check`. S10.6's gate stays valid (V3).

**S10.6 done, 2026-09-30** (dependencies and assets; [record](evidence/STAGE_10_MEASUREMENTS.md) §S10.6):
- Every runtime dependency checked against its use: all used except **`sqlite3_flutter_libs
  0.6.0+eol`**, an empty end-of-life package (its README asks for removal after `sqlite3` 3.x; this app
  resolves 3.5.2, whose build hook supplies `libsqlite3.so`). **Removed** (RD-02's dependency part,
  D10-5). The arm64 APK's native libraries are unchanged without it (the APK −12 bytes, in
  `NOTICES.Z`); the scenario suite ran on the emulator on the new build.
- Assets: the catalog, its notice, the icon and splash, Material Icons (6 KiB) and `NOTICES.Z`; all
  referenced, 0.6 % of the APK; nothing to remove. `icon_512.png` is not shipped.
- **Verification:** dependencies and the lockfile (high-risk): the full gate after the change,
  **PASS** (1,838 tests, 2 skips; host E2E 2 + 1; Flutter 3.47.4); one emulator run.

**S10.5 done, 2026-09-30** (ENG-12 fixed; ENG-11 and the Logbook measured;
[record](evidence/STAGE_10_MEASUREMENTS.md) §S10.5):
- **ENG-12:** `TargetRepository.inOneTransaction`; `CatalogSeeder` seeds inside it: one commit instead
  of 164. Emulator: 11.9–14.8 s (four runs) → **1.7–2.5 s** (two runs) before the first frame. The
  per-row failure handling and retry (S1.2) are unchanged; `catalog_seeder_test.dart` passes unchanged;
  `catalog_seeder_transaction_test.dart` (mutation-checked) asserts one transaction.
- **ENG-11:** 300 sessions listed in 48–75 ms; no N+1 in today's code. **Closed as measured.** The
  Logbook at 300 sessions is practical (build averages 2.4–8.1 ms); no change.
- **Verification:** persistence (high-risk): the full gate after the change, **PASS** (1,838 tests,
  2 skips; host E2E 2 + 1; Flutter 3.47.4); two emulator runs of the scenarios.

**S10.4 done, 2026-09-30** (measured, no change needed; [record](evidence/STAGE_10_MEASUREMENTS.md) §S10.4):
the planner's edits, night and target changes and the detail screens build in 1.7–6.2 ms on average
on the emulator; the only overruns are a new screen's first frame. A temporary host probe (deleted)
showed no planner section rebuilding on keyboard frames, and one block edit rebuilding only the
sections that show the plan (1,268 elements). Trap 16's memoization holds; no cache added; sampling and
calculations untouched.
- **Verification:** the documentation class (V1); no code changed. S10.3's gate stays valid (V3).

**S10.3 done, 2026-09-30** (form lag, 08 §22; [record](evidence/STAGE_10_MEASUREMENTS.md) §S10.3):
- **Cause (verified):** the rig editor read the screen width with `MediaQuery.of`, so its whole form
  (about 600 elements) rebuilt on every frame of the keyboard opening. **Change:**
  `MediaQuery.sizeOf`. Host: 7,500 → 456 elements rebuilt while the keyboard opens, the form 12 → 0
  times. Emulator (indicative): the worst build frame while focusing 73/48 → 35/11 ms.
- Checked and kept (measured cheap): the derived sensor size and focal ratio rebuild the form once
  per keystroke; Flutter's `Form` rebuilds its fields on any change. The other editors have no such
  dependency. `media_query_aspects_test.dart` keeps `MediaQuery.of` out of `lib/`; the rebuild test
  asserts the counts (mutation-checked). CLAUDE.md trap 16 records the rule.
- A phone trace is Stage 11's; the owner's lag may also have come from a debug build (S10.1).
- **Verification:** one presentation file (localized): the full gate after the change, **PASS**
  (1,837 tests, 2 skips; host E2E core_loop 2 and perf_scenarios 1; Flutter 3.47.4).

**S10.2 done, 2026-09-30** (the performance scenarios and their baselines;
[`evidence/STAGE_10_MEASUREMENTS.md`](evidence/STAGE_10_MEASUREMENTS.md) §S10.2):
- `integration_test/perf_scenarios_test.dart` (the rig editor, the planner's edits, the detail screens,
  the Logbook with 300 sessions, first-run seeding, the list query, the candidates) with
  `test_driver/perf_driver.dart`: frame timings and elapsed times in profile mode on a device; a smoke
  test on the host inside the gate. `test/presentation/performance/rig_editor_rebuilds_test.dart`: the
  editor's rebuild counts on the host. `android/.gitignore` ignores Kotlin's `.kotlin/`.
- Two emulator runs (profile, indicative). **Verified:** (1) first-run catalog seeding takes 13–15 s
  before the first frame (ENG-12; 164 autocommit inserts) → S10.5; (2) the rig editor's whole form
  (about 600 elements) rebuilds on every frame of the keyboard opening (host: 12 of 12 frames; its
  `MediaQuery.of`) → S10.3. **Not bottlenecks:** ENG-11 (300 sessions listed in 48–52 ms), the
  candidates (313–501 ms), the planner's edits and changes, the detail screens. Raster times are
  high while the keyboard animates, but this emulator's GPU is emulated: not claimed without a device.
- **Verification:** test and tooling files only (the suite, the driver, a probe; `.gitignore`):
  format, encoding and analyze clean; both new tests pass on the host; the suite passed twice on the
  emulator. The full gate runs at S10.3's end, after its code change.
- *Correction (found by that gate, 2026-09-30):* with two files in one host E2E run, flutter-tester
  cannot start the second app ("The log reader failed unexpectedly"), so the gate failed from
  `c93ecd9`. `tool/check.dart` now runs each `integration_test` file as its own step; the full gate
  then passed (1,837 tests, 2 skips; host E2E: `core_loop_test.dart` 2, `perf_scenarios_test.dart` 1).

**S10.1 done, 2026-09-30** (the size baseline; measurement only, no code;
[`evidence/STAGE_10_MEASUREMENTS.md`](evidence/STAGE_10_MEASUREMENTS.md) §S10.1):
- Built at `8b62b87` on this machine and measured on the emulator (Android 16, x86_64). Release
  bundle 68.5 MB (three ABIs plus symbols Play keeps); **the arm64-v8a release APK 24.8 MB**; universal
  release APK 71.9 MB; debug APK 183.6 MB.
- The arm64 APK: the Flutter engine 47 %, compiled Dart 40 % (the app's own code 1.4 MiB), SQLite 7 %;
  assets 0.15 MiB. No asset, font or image is a material contributor.
- **Installed:** release **27.8 MB**; debug **314 MB** (184 MB app, 130 MB data: the debug build's
  extracted 118 MB JIT kernel and 11.6 MB snapshot; the database 0.1 MB).
- **The 277 MB (08 §26) is classified as consistent with a debug build's installed total**, not a
  release size; the exact figure stays the owner's unreproduced observation. No size target (none set);
  the release size is reasonable, so no reduction is claimed.
- Machine notes (nothing in the repository changed): Avast's HTTPS interception blocks the JBR's
  downloads (the first Gradle run used JDK 25 with the Windows trust store), and Kotlin's incremental
  compiler fails across drives (`-Pkotlin.incremental=false`).
- **Verification:** the documentation class (V1): references resolve; `git diff --check`. No gate
  input changed.

**Stage 10 planned, 2026-09-30** (documentation only; the plan's "Stage 10 — frozen Task sequence"):
- Inputs verified at `1aeee63` (§9.7). Most important: the 277 MB has no recorded build type (the only
  builds recorded on the owner's phone are debug); **an Android emulator now exists on this machine**
  (Android 16, x86_64, 2 GB); the rig editor rebuilds its whole dialog on each keystroke in seven of its fourteen fields (a candidate,
  not a verified cause); first-run seeding still inserts entry by entry (ENG-12).
- **Frozen:** S10.1 → S10.7, then the Stage 10 validation. Decisions D10-1 to D10-6 (DECISIONS E.1,
  "Stage 10 decisions (delegated by the owner)"): emulator numbers are indicative, device evidence stays
  Stage 11's; no new budgets; the user-relevant size is the arm64-v8a split and its install; one
  measurement record (`evidence/STAGE_10_MEASUREMENTS.md`).
- **Verification:** the documentation class (V1): references and IDs resolve; `git diff --check`.
  The TD-089–TD-091 gate (`0f09608`) is Stage 10's baseline (V3).

**Stage 9 closed, 2026-09-30** (the owner, in chat: "defer all three decisions, move on to Stage 10"):
- **S9.10** (the logo), **S9.11** (RG-12, the licence) and **S9.12** (RD-01, the identity) are
  **deferred by the owner**. Their research stays as prepared; nothing was built from them. Today's
  icon, GPL-3.0 and the `chacha12` identity stay as they are.
- The Stage's exit ("done or deferred by the owner; Stage 9 validation passes") is met: S9.1–S9.9
  PASS ([report](STAGE_9_VALIDATION.md)) and every finding fixed (TD-089 to TD-091).
- **Carried:** TD-088 (the 404 source and policy links) stays open with RD-01; both block a store
  upload, not refinement (Stage 11's release checks). RG-12 stays open for the owner.
- **Verification:** the documentation class (V1): references resolve; `git diff --check`.

**TD-089 to TD-091 fixed, 2026-09-29** (the Stage 9 validation's findings; the owner asked in chat
to fix every finding): TD-089's four checks are committed tests (the cloud gate against a forecast;
the cloud bar's unknown hour; no twilight bar without a sunset and a 59.9° N June night; the target's
delete and the site's cancelled swipe); **TD-090** (decided under D9-1): the Library's Sites hides the
position actions and adds sites without making them active, `/select/site` unchanged; **TD-091**: the
export's share text states its local time and offset. TD-088 stays for RD-01.
- The core-loop E2E now adds its first site where a site is chosen for planning (`/select/site`,
  Tonight's "Set site") instead of the Library, whose added sites no longer become active (trap 19;
  the gate's first run caught it).
- **Verification:** shared behaviour (the site list and editor, the exporter): the full gate after the
  last code change, **PASS** (1,833 tests, 2 skips; 2 host E2E; Flutter 3.47.4).

**Stage 9 validation of S9.1–S9.9, 2026-09-29: PASS** (fresh session, independent;
[report](STAGE_9_VALIDATION.md); verified at `8e53479`, application code as at `0a0c95e`):
- Every frozen item passes (scope, the Task rules, S9.1–S9.9's acceptance, D9-1 to D9-6, RD-07,
  RD-09, RD-11, the shared rules, traps 12–22); no V4 blocker. S9.10–S9.12 were prepared as their
  scope says and nothing depends on a guess. **The Stage stays open** until the owner decides or
  defers them.
- Findings (non-blocking, recorded, not fixed): **TD-089** (four acceptance checks established by
  probes, not committed tests), **TD-090** (the Library's Sites still has actions that change the
  active site), **TD-091** (an export's share text does not state its stamp's zone). Notes: the
  site's Delete sits in the row (RD-09 allows it); About's author shown as "Buffur" (optional owner
  confirmation).
- **Evidence:** the S9.9 gate reused (V3); five temporary probes (P1–P5) run and deleted.

**S9.10–S9.12 prepared, 2026-09-29** (owner gates; documentation only):
- **S9.10** (`research/S9.10_LOGO.md`): where the icon appears; five problems with today's execution
  (the star floats above the arc, three stroke weights, the themed icon is the colour drawing tinted,
  the mark sits high, error red); four alternatives that keep the concept (A corrected, B the window as
  an area, C minimal, D today's with its defects fixed), each checked against the 66 dp safe zone; a
  dedicated themed layer; a splash proposal that never delays startup. **The owner chooses.**
- **S9.11** (`research/S9.11_LICENCE.md`, RG-12): from the GPL FAQ, the Open Source Definition, the
  CC BY-SA 4.0 legal code and the PolyForm texts: GPL-3.0 meets "free" but not "no monetisation" or
  "no modification without permission", and no open-source licence can; the options (keep GPL; PolyForm
  Noncommercial; PolyForm Strict; all rights reserved), and what follows (earlier copies stay GPL, every
  copyright holder must agree, the catalog stays CC BY-SA 4.0, the dependencies are permissive). Not
  legal advice. **The owner decides.**
- **S9.12** (`research/S9.12_PROJECT_IDENTITY.md`, RD-01): the app's source and privacy-policy links
  (`chacha12`) return 404 while the public repository is `Buffur/Astro-Planner`; recorded as **TD-088**
  (a blocker for any store upload, not for Stage 9). Options C, B and B′. **The owner decides.**
- **Verification:** the documentation class (V1): references resolve; `git diff --check`.

**S9.9 done, 2026-09-29** (final visual consistency): the secondary screens use the text roles and
spacing tokens only (list titles `titleSmall`, "Saved sites" a header, every numeric inset a token;
12 became `md`). `secondary_consistency_test.dart` (2) keeps ad hoc styles out of the thirteen files;
the sweep covers them in every theme at 100 % and 200 %. No content changed. Also corrected: S9.8's
FEATURE_STATUS banner named F-42 for backups (F-42 is planned-versus-actual logging).
- **Verification:** shared behaviour (thirteen presentation files): the full gate after the last code
  change, **PASS** (1,825 tests, 2 skips; 2 host E2E; Flutter 3.47.4).

**S9.8 done, 2026-09-29** (D9-5; TD-081 resolved): feedback, messages and export polish.
- `showDone` after a rig, target or site saved, a name saved or removed, an export or backup file
  created, a restore prepared or cancelled (deletes since S9.1). None for settings (visible in place).
- **TD-081:** every message through `AppMessages.showMessage` with `AppMotion`'s style; none slides
  under reduced motion. A test keeps `showSnackBar` out of the rest of `lib/presentation`.
- File names in local time (`astroplan-entry-…`, `astroplan-logbook-…`, `astroplan-backup-…`), the
  backup's share text with its UTC offset; "Export all as file" a labelled item in the Logbook's menu.
- **Tests:** `app_messages_test.dart` (3; the reduced-motion case mutation-checked),
  `file_names_test.dart` (3), the new messages in the library, detail and backup tests; the Export
  all test goes through the menu.
- **Verification:** shared behaviour (every message, two data-layer file names): the full gate after
  the last code change, **PASS** (1,823 tests, 2 skips; 2 host E2E; Flutter 3.47.4).

**S9.7 done, 2026-09-29** (08 §13): sky darkness made readable.
- Each value first, its source and a readable date under it (`NightTimeFormatter.recordedDate`,
  "Aug 1, 2026"); "Unknown" with the way to set it; "Not saved" for a transient position. The map
  link names lightpollutionmap.app and what to do there, in the text roles. The site editor's captions
  use the same date. No inference, no conversion (trap 6).
- **Tests:** `sky_darkness_context_test.dart` updated deliberately (the new readings by key, no ISO
  date, the link's words); the formatter's date (+1); the planner and disclosure tests' link text.
- **Verification:** shared behaviour (the planner's sky detail, the site editor, a formatter): the
  full gate after the last code change, **PASS** (1,816 tests, 2 skips; 2 host E2E; Flutter
  3.47.4).

**S9.6 done, 2026-09-29** (the detail screens' secondary presentation; 08 §12): Weather and Night & Moon.
- Night & Moon: a twilight bar from sunset to sunrise (`TwilightBands`, pure, from the domain's
  crossings; bands shaded by depth), above the unchanged table of times, which is its text.
- Weather: a cloud-cover bar under each hour's number (unknown draws nothing); dew-risk hours marked
  by an icon as well as colour; "Tap to set location" gone where nothing can be tapped. Age, stale
  state, unknowns, units, attribution and the horizontal-visibility wording unchanged (ADR-012).
- **Tests:** `twilight_bands_test.dart` (5: a mid-latitude night, no astronomical darkness, no
  sunset, clipping, and the calculator's real night); `detail_screens_test.dart` +2 (cloud bars at
  40 %, the dew icon, no "Tap to set location"; the bar's seven bands). The sweep already opens both
  details with a full forecast.
- **Verification:** shared behaviour (two detail screens, a shared helper): the full gate after the
  last code change, **PASS** (1,815 tests, 2 skips; 2 host E2E; Flutter 3.47.4).

**S9.5 done, 2026-09-29** (08 §23; D9-4): About.
- An author block first: the app, its version, "Made by Buffur" (the owner's public handle from 08
  §23; the git history records two author names, so no personal name is inferred), Reddit as the
  prominent button and the GitHub profile. Then each data source's credit with its link (OpenNGC,
  openstreetmap.org/copyright, open-meteo.com, lightpollutionmap.app), privacy, the licence.
  Source-code and policy links unchanged pending RD-01. `pubspec.yaml`'s template description
  replaced. `COMPLIANCE.md` noted; the privacy policy needs no change (nothing new leaves the device).
- **Tests:** `about_screen_test.dart` +2 (the author block first with both links and the version;
  every source linked); two counts relaxed deliberately (the catalog's credit now appears in the
  notice and in its linked line).
- **Verification:** localized plus `pubspec.yaml` (a gate input): the full gate, **PASS** (1,808
  tests, 2 skips; 2 host E2E; Flutter 3.47.4).

**S9.4 done, 2026-09-29** (P9.3; RD-11 = S9; TD-050 resolved; D9-3): Settings rebuilt.
- "Settings", in RG-13's sections: Imaging window (minimum altitude, darkness limit, **Moon gate**,
  **cloud gate**), Fit and capture time (margin, time between frames now to the model's 120 s, the
  optional overheads with editable values), Guidance (NPF k, dew margin), Display, Privacy, Data,
  About; each row value-first with its consequence. No default and no meaning changed.
- Every setting write, Back up, preparing and cancelling a restore through `runWithFeedback`;
  Restore through `confirmDestructive`; a pick error through `showFailure`.
- **Tests:** `settings_rebuilt_test.dart` (5: the sections in order; the Moon gate at 0 % shrinks the
  usable time on a full-Moon night and both gates persist; 120 s reached; an overhead's steppers
  persist, change the budget and stop at the floor; a failed save says so); the sweep adds Settings
  with every gate and overhead on; titles and dialog keys updated deliberately in the navigation,
  settings and backup tests.
- **Verification:** shared behaviour (Settings, preferences feeding every planner value): the full
  gate after the last code change, **PASS** (1,806 tests, 2 skips; 2 host E2E; Flutter 3.47.4).

**S9.3 done, 2026-09-29** (RG-13 answered; documentation only): `research/S9.3_SETTINGS.md`.
- Every visible setting classed (A–F), with what it changes, its unit, range and default, the need
  (N.I.N.A. and PHD2 documentation for dithering, refocus and meridian-flip practice; CALC-17 for
  NPF; the twilight definitions), and where it belongs. The Moon and cloud gates are placed in
  Settings (RD-11 = S9). Decisions for S9.4 recorded in E.1 (D9-3).
- Found: the "Time between frames" slider stops at 60 s while the model allows 120 s (fixed in S9.4).
- **Verification:** the documentation class (V1): references resolve; `git diff --check`. The S9.2
  gate stays the baseline (V3).

**S9.2 done, 2026-09-29** (P9.2): secondary forms and the vocabulary completed.
- The rig, target and site editors: sentence-case titles and labels from `AppWords`, one primary
  `FilledButton` Save (the target editor's `ElevatedButton` replaced; the site editor's app-bar check
  replaced by "Save site" at its foot); `AppSpacing` in the lists and the site form; the site editor's
  ad hoc SnackBars through the new `showFailure`. "No equipment profiles found." → "No rigs yet."
- **The retired-terms baseline is empty**, and a test now requires it (P9.2's acceptance).
- **Tests:** `secondary_forms_test.dart` (3); labels updated deliberately in the rig, target, site,
  metadata, camera-class and noise-reduction tests and the E2E ("Save Changes" → "Save", "Target Name *"
  → "Name *", the site editor's Save by key `siteEditor.save`).
- **Verification:** shared behaviour (three editors, a shared helper): the full gate after the last
  code change, **PASS** (1,801 tests, 2 skips; 2 host E2E; Flutter 3.47.4).

**S9.1 done, 2026-09-29** (P9.1; RD-07, TD-053 resolved; D9-1, D9-2): the Library manages.
- `ListMode` (manage in the Library, choose from `/select/…`): a Library tap opens the rig, target or
  site and never changes the plan or the active site; choosing is unchanged. Titles by mode ("Rigs",
  "Choose a rig", …); no plan highlight in the Library; the Library tab describes itself.
- **Plan this target** in a target opened from the Library: the leave guard, a new plan with the
  target, "New plan for …", the planner.
- Rigs, targets and sites: a visible Delete (rig and target editors, the site row) and a swipe, both
  through `confirmDestructive` (one message shape), then "Rig deleted" etc. The ad hoc dialogs and raw
  `Dismissible`s are gone. Acceptance (4)'s "refusal for a rig in use" was dropped: no such refusal
  exists (saved plans keep their snapshots).
- **Tests:** `library_manage_mode_test.dart` (6; mutation-checked: with the Library routes in choose
  mode four fail); the sweep adds `/select/rig`, `/select/target`, `/select/site`; titles and tooltips
  updated deliberately in the navigation, Tonight, planner, metadata, target, sites and E2E tests
  ("Select Equipment" → "Choose a rig", "Select Target" → "Choose a target", "Edit" → "Edit rig" /
  "Edit target", the site dialog's wording).
- **Verification:** shared behaviour (three lists, the router, the editors): the full gate after the
  last code change, **PASS** (1,797 tests, 2 skips; 2 host E2E; Flutter 3.47.4).

**Stage 9 planned, 2026-09-29** (documentation only; the plan's "Stage 9 — frozen Task sequence"):
- Inputs verified against the code at `b378f16` (§9.7). Most important: the Library still chooses for
  the plan and the active site (TD-053); the Moon and cloud gates have no control anywhere (TD-050);
  About has no authorship; `AppIdentity` names `chacha12` while the remote is `Buffur` (RD-01); rigs,
  targets, sites and Restore confirm with ad hoc dialogs.
- **Frozen:** S9.1 → S9.9, then the Stage 9 validation. S9.10 (logo), S9.11 (licence, RG-12) and S9.12
  (identity, RD-01) are **owner gates**: the agent prepares them, the owner decides.
- Decisions D9-1 to D9-6 (E.1, "Stage 9 decisions (delegated by the owner)"); TD-074 deferred to
  after Stage 11 (D9-6).
- **Verification:** the documentation class (V1): references and IDs resolve; `git diff --check`.
  The TD-087 fix's gate is Stage 9's baseline (V3).

**TD-087 fixed, 2026-09-29** (S8V-03; tests only): the three Stage 8 acceptance checks the
validation established by probes are committed tests.
- S8.1 acceptance 6: `schema_migration_test.dart`'s v23 → v24 test adds a never-saved draft, a
  Saved and a Saved · changed plan with blocks.
- S8.4 acceptance 2: `live_runs_survive_test.dart` (new; the shape of the validation's P2).
- S8.2 and trap 17: the accessibility sweep opens the Saved plan's result form before its night
  ends, after it with no outcome chosen, and with Not done's reason chips (all three themes, 100 %
  and 200 %).
- **Verification:** test code only: the full gate after the change, **PASS** (1,791 tests, 2
  skips; 2 host E2E; Flutter 3.47.4).

**TD-086 fixed, 2026-09-29** (S8V-02; the owner asked in chat to fix every Stage 8 finding; I-4,
CALC-44, SI-008): the unreadable Saved · changed path.
- `ResultsViewModel.savedPlanUnreadable`: the form's review lists no planned blocks and shows the
  night and target as unknown, instead of the working row's (only Not done is offered, as before).
- CALC-44's fallback takes the later of the row's night key and the evening date the unreadable
  snapshot still names (`Session.unreadableSnapshotNight`, read by `DriftSessionRepository`): a
  working night moved earlier no longer lets Not done be recorded before the saved night can have
  ended. Only ever later; never shown. No schema change.
- **Tests:** `results_unreadable_plan_test.dart` (new), `drift_session_results_test.dart` +2; both
  mutation-checked (each fails without its half of the fix).
- **Verification:** high-risk (time and night semantics, CALC-44): the full gate after the change,
  **PASS** (1,790 tests, 2 skips; 2 host E2E; Flutter 3.47.4).

**TD-085 fixed, 2026-09-29** (S8V-01; the owner asked in chat; D8-2): Save no longer rewrites a
saved plan whose night ended since the last night check.
- `CurrentSession.save` takes the time (`PlanLifecycleViewModel.savePlan` passes the clock) and,
  inside its step of the autosave chain, never saves over a saved plan whose night has ended
  (CALC-44): a Saved one stays as it was and the plan is saved as a new one; a Saved · changed one is
  settled first (`settleSavedPlan`, as S8.3's transition does) and its copy is saved. The ended entry
  keeps its snapshot, blocks and night. No repository or schema change.
- A first attempt ran the night check (`followNight`) before Save; the gate's S1.12 race test
  (`save_start_race_test.dart`) caught that an edit tapped right after Save then landed before it,
  so the decision moved into the chain, where the snapshot and plan of the tap are kept.
- **Tests:** `saved_plan_transition_test.dart` +2 (P5's sequence for a Saved and a Saved · changed
  plan: after dawn, no tick, Save → the entry unchanged, a new saved plan from the working copy);
  both failed before the fix.
- **Verification:** shared behaviour (`CurrentSession` and a ViewModel's Save, used by the planner and the E2E):
  the full gate after the change, **PASS** (1,787 tests, 2 skips; 2 host E2E; Flutter 3.47.4).
  It does not reopen the Stage 8 PASS (V6): it resolves a recorded FOLLOW-UP.

**Stage 8 validation PASS, 2026-09-29** (a separate agent in the implementing session, without its context; [report](STAGE_8_VALIDATION.md)):
- Every frozen item passes (the Stage's constraints and exit, S8.1–S8.9's acceptance, D8-1 to D8-4,
  I-1 to I-10, the traps it touches). No V4 blocker; **Stage 8 closed**.
- Gate reused (V3): S8.9's full gate at `690b94a` (1,785 tests, 2 skips; 2 host E2E); the code diff
  since is empty. Fresh evidence: probes P1 (v23 → v25 keeps rows in every status), P2 (S8.4
  acceptance 2: an in-progress, a corrected completed and an abandoned run list, export, back up
  and record) and two mutations (P3: the TD-063 test fails without the re-read; P4: three S8.9 tests
  fail without the settings restore); all temporary and removed.
- Non-blocking findings recorded, not fixed: S8V-01 / **TD-085** (Save in the minute after a saved
  night ends rewrites its snapshot; reproduced by P5), S8V-02 / **TD-086** (the unreadable Saved ·
  changed path shows and times working state), S8V-03 / **TD-087** (three acceptance checks rest on
  the validation's probes, not committed tests).
- **Verification:** documentation class (V1): references and IDs resolve; `git diff --check`.

**S8.9 done, 2026-09-29** (TD-056 and ENG-14 resolved; I-10): preferences in the backup; stale ids.
- **Probe first:** ENG-14 reproduced on the host before any change: a staged restore applied as
  `main.dart` runs it left `activeLocationId` 7 and the plan ids in place (FAIL). The same probe,
  unchanged, passes after the change; it is now a committed test in `backup_restore_test.dart`.
- The archive is `format_version` 2: `preferences.json` (`BackupPreferences`) holds the planning
  preferences, the display preferences (field mode, section states), `activeLocationId` and
  `firstRunDone`, grouped by type; never the transient position, the catalog seed marker, the plan
  ids or the place-name opt-in. A version 2 file must carry readable settings; only carried keys
  are ever read from it. Staged beside the database and applied just before the swap (redone if a
  start is interrupted): the carried keys are replaced as a whole. A version 1 archive still
  restores; it keeps the device's settings but drops its active site. A restore and a confirmed
  reset clear `targetId`, `equipmentId` and `editedSessionId`; the reset drops the active site too.
- The repositories expose their keys (`keys`, `fieldModeKey`, `activeLocationIdKey`, `planIdKeys`,
  `doneKey`) so the backup never restates them. CLAUDE.md trap 5 notes it.
- Privacy: the backup stays a local file the user shares; the policy now says it holds the
  settings too. The Data Safety draft (`COMPLIANCE.md`) is unchanged: nothing leaves the device
  except where the user sends it.
- **Tests:** `backup_restore_test.dart` +7 (what is carried, by type; a round trip; the ENG-14
  probe; a version 1 archive restores; staging and cancel of the settings; a version 2 without or
  with bad settings refused; uncarried keys never applied) and the setup's in-memory preferences;
  `unsupported_database_test.dart`: a reset leaves no stale id. Mutation-checked: without the
  restore hook three tests fail.
- **Verification:** high-risk (backup format, persistence): the full gate after the last code
  change, **PASS** (1,785 tests, 2 skips; 2 host E2E; Flutter 3.47.4).
**S8.8 done, 2026-09-29** (TD-070 resolved; ADR-018 §5): per-field provenance in new snapshots.
- `SessionSnapshotBuilder` adds `rig.provenance`: each valued spec (`EquipmentSpec` name; the RAW
  size only when set) → `{source, confidence}` from `provenanceOf`, or null when unknown. The group
  pairs (S3.V7) stay; `v` stays 1; an older snapshot has no key and reads as stored. Nothing is
  recorded as `user` unless it was typed; an explicitly unknown field stays null. The export embeds
  snapshots as stored (manifest unchanged). No screen change.
- **Tests:** `session_snapshot_builder_test.dart` +3 (an imported rig's estimates and file values; a
  typed rig per field with one explicitly unknown field; a snapshot without the key still reads,
  `SavedPlanReader` included); the legacy case now pins every field null.
- **Verification:** high-risk (snapshot, provenance): the full gate after the last code change,
  **PASS** (1,778 tests, 2 skips; 2 host E2E; Flutter 3.47.4).
**S8.7 done, 2026-09-29** (P8.7; D8-4, I-6; 08 §24): the Logbook entry, Share and Export as file.
- The entry is a `DetailScaffold`: the identity (name, or target · night) with the site and zone;
  the result first (state, how it was reported, planned against actual, or when a result can be
  recorded); the name; the night, site, target and rig from the snapshot (budget words: Integration,
  Time needed, Total time); planned against actual per block; notes; conditions; then the actions
  its state allows (Open in planner before the night ends; Record result after it; Edit result with
  a result; Copy to another night for all but an old log), Share and Export as file. An old log
  offers Share and Export only. No tracker anywhere.
- Share (`EntryShareText`, pure; entry and list row): structured, only what the entry holds, never
  the notes or the coordinates. The download action is the one-entry manifest v2 export, kept and
  named Export as file. `SessionLog.toShareableText` removed with its two tests.
- The entry's retired terms are gone (the baseline lowered).
- **Tests:** `entry_share_text_test.dart` (3); Copy to another night (VM); the entry's actions by
  state; two detail assertions updated deliberately (the result summary repeats the integration;
  notes and conditions are two sections; Copy replaces ""Plan again (copy)"").
- **Verification:** shared behaviour (the entry, the list, a ViewModel): the full gate after the
  last code change, **PASS** (1,775 tests, 2 skips; 2 host E2E; Flutter 3.47.4).
**S8.6 done, 2026-09-29** (08 §24; P8.6): an optional plan name.
- Schema v25: `session_logs.name` (nullable). `SessionRepository.rename` (trimmed, up to 80
  characters, empty removes it; legacy refused; the plan, status and snapshot never change). Never
  asked at Save plan; set on the entry (""Name (optional)""); the Logbook shows it, else target ·
  night, and searches it; a working copy never takes it. Export key `name` (additive); the backup
  keeps it.
- Found on the way: the name dialog disposed its field while closing (fixed: the dialog owns it); the
  open Logbook did not re-read an entry changed elsewhere (fixed: `SessionsViewModel.revision`).
- **Tests:** the v25 migration group; `rename` and copy cases; the export round trip; the backup
  acceptance with a named plan; a UI test (set, list, search, remove). Pins v24 → v25 moved
  deliberately.
- **Verification:** high-risk (schema): the full gate after the last code change, **PASS** (1,773
  tests, 2 skips; 2 host E2E; Flutter 3.47.4).
**S8.5 done, 2026-09-29** (ADR-019 §2, §8, §10; UX-30; RD-07; I-9): the Logbook list.
- The tab and screen are Logbook; Upcoming (saved plans whose night has not ended) and Past; rows
  with the identity (target · night), `PlanStateLabel`, rig and site, planned against actual,
  Record result or Edit result. Search over the target, site and notes (in memory). Filters in one
  panel with a count, held by `SessionsViewModel` (survive navigation), combining with the search.
  Delete: swipe or the entry's visible Delete, after `confirmDestructive`. Progress by target moved
  from the Library to the Logbook (`/sessions/progress`). The list's retired terms are gone.
- `SessionsViewModel` moved to its own file (re-exported); `ProgressScreen` moved to the Logbook.
- **Tests:** `logbook_screen_test.dart` rewritten (5: listing and groups, search, the filter panel
  with search and persistence, delete cancel and confirm); the filter, legacy-row, tab-label and
  route tests updated deliberately (the chips, ""Sessions"", ""Legacy log"" and ""Planned"" are what
  S8.5 changes).
- **Verification:** shared behaviour (the router, a ViewModel, several screens): the full gate after
  the last code change, **PASS** (1,751 tests, 2 skips; 2 host E2E; Flutter 3.47.4).
**S8.4 done, 2026-09-29** (the owner's direction of 2026-09-27; ADR-016 §13): the live tracker retired.
- **The audit (A–E)** is in `ARCHITECTURE.md` (S8.4). Removed (A): the tracker screen and route, its
  ViewModel, the resume prompt, Start/Track live, Tonight's run card, the entry's Open tracker,
  keep-screen-on and the `wakelock_plus` dependency (no Dart use; the lockfile loses two packages),
  CALC-35 and CALC-36. Kept (B, C): the events, the fold and the counters' invariant, the
  repository's stored-run API, every stored run, the export and the backup; no migration.
- A run left in progress by an older version is offered on Tonight's line and in the Logbook and is
  recorded through the result form. **TD-063 resolved:** `openSession` re-reads the session; one
  deleted meanwhile opens as a copy (`stale_detail_open_test.dart`, fails on the old code).
  **TD-073 resolved** (the Start message left). **UX-13 and UX-26 closed.**
- Found and fixed on the way (S8.2's own acceptance, I-7): after a failed result write the form kept
  no choice; it now reloads only for a stale entry and otherwise keeps the input.
- **Tests (D, E):** retired with their reasons in the audit (the tracker's screen, prompt, outlook,
  estimate and running-time cases, Start-then-edit, the Track live menu case); lifecycle rows L4, L6,
  L8 replaced by the saved-night lifecycle; the E2E is Save → the night (a restart) → Tonight's line
  → result → export, and records a result across a DST change.
- **Verification:** a dependency change (high-risk): the full gate after the last code change,
  **PASS** (1,750 tests, 2 skips — fewer because the tracker's tests were retired; 2 host E2E;
  Flutter 3.47.4).
**S8.3 done, 2026-09-29** (ADR-019 §3.1, D1 delivered; D8-1, D8-2, I-3, I-8): the saved-plan
transition and Tonight's line.
- Once a saved plan's night has ended (CALC-44), it stays on its night with its snapshot, and the
  planner continues on one working copy, with the app open (`NightClock`) and at a restart
  (`CurrentSession.leaveEndedSavedPlan`): an untouched copy for Saved, a settlement for Saved ·
  changed (the edits in the copy, unsaved). The copy's night is the working night if still ahead,
  else tonight. Idempotent; a failure is logged and retried at the next check. A never-saved draft
  still rolls forward; a run keeps its copy rule. Opening an ended saved plan opens a copy.
- D8-2 tested: Save before the night ends replaces the snapshot, a changed night included.
- Tonight's line (`_ResultDue`): ""Last night: M42. How did it go?"" or the entry's date, from
  `SessionsViewModel.dueResult` (refreshed after each night check and each recorded result).
- **Tests:** `saved_plan_transition_test.dart` (8); two S6.4 rollover tests updated deliberately
  (their D1 ""saved plan stays current"" expectation is what S8.3 changes).
- **Verification:** time and night semantics (high-risk): the full gate after the last code change,
  **PASS** (1,789 tests, 2 skips; 2 host E2E; Flutter 3.47.4).
**S8.2 done, 2026-09-29** (ADR-019 §3.1, §4; UX-25 resolved; I-6, I-7): the result form.
- `/session/:id/results` is ""How did it go?"": the saved plan's review (snapshot night, target, site,
  rig, planned light blocks), Completed as planned · Partly (typed counts per light block) · Not done
  (optional reason), notes, conditions, Save result (`showDone`). Nothing preselected for a new
  result; a tracker run opens as Partly with its confirmed counts; an edit opens with its outcome.
- Back writes nothing; a stale form is refused and reloaded; a night not yet ended offers no result
  and says when it can. A Saved · changed entry is settled first (`CurrentSession.settle`); the
  planner keeps its edits on the copy with no prompt.
- The Logbook row and entry offer Record result (`ResultAction`, CALC-44) and Edit result. The
  tracker's Abandon became Not done in the form. `PlanState` shows Partly.
- **Tests:** `results_screen_test.dart` rewritten (11: run, checks, Not done, not yet, as planned,
  Partly with 0, Back, stale, Saved · changed, Record result, Edit result); the E2E's Finish step now
  saves through the form (""Result saved."").
- **Verification:** shared behaviour on the E2E path: the full gate after the last code change,
  **PASS** (1,781 tests, 2 skips; 2 host E2E; Flutter 3.47.4).
**S8.1 done, 2026-09-29** (ADR-019 §3.1, §4; D8-1, D8-3, I-1 to I-5, I-7): results without a run,
domain and data.
- **CALC-44** `SavedNightEnd`: a saved night ends at dawn at its snapshot's darkness limit, else at
  the night's end; without a readable snapshot, at the latest end of its night key.
- **Schema v24:** `session_logs.result_kind` and `not_done_reason`; `session_events` rebuilt to
  accept the `reported` kind (every event kept). `ExecutionMachine`: `reported` ends a run that
  never started.
- `SessionRepository.recordResult` (Completed as planned · Partly · Not done, for a Saved plan after
  its night, a run in progress and an edit of a result; stale forms refused) and `settleSavedPlan`
  (a Saved · changed plan → its saved entry plus a never-saved copy; idempotent).
- The export carries `result_kind`, `not_done_reason` and `reported` (manifest v2, additive).
- RD-13 built as notes on CALC-37/38. No screen changed (the form is S8.2).
- **Tests:** 17 repository tests (`drift_session_results_test.dart`), 2 machine tests, the v24
  migration group (16 schema tests and a data-preservation test), a manifest round trip. Deliberate
  changes: the backup and unsupported-database pins move from v23 to v24.
- **Verification:** high-risk (schema, persistence, a calculation): the full gate after the last code
  change, **PASS** (below).
**Stage 8 planned, 2026-09-29** (documentation only; the plan's "Stage 8 — frozen Task sequence"):
- **Verified against the code at `836bbdf` (§9.7).** Notable: a result can be recorded only through the
  tracker (`complete` accepts `inProgress` only); no Partly, Not done reason or name is stored; snapshot
  blocks have no ids and `capture_blocks` are re-inserted on every plan write, but a Saved row's blocks
  equal its snapshot's; saved plans keep a past night in the row while the planner shows tonight (D1);
  TD-063's mechanism is still present; the backup holds no preferences.
- **Decisions:** the owner delegated them to the agent in chat ("do not ask me; decide yourself").
  D8-1 (S4-DEF-02): a saved night ends at dawn at its snapshot's darkness limit, else at the night's end
  (CALC-44). D8-2 (S4-DEF-01): Save again before the night ends. D8-3 (RD-13): "Reported as planned";
  old estimates not relabelled. D8-4: Share without notes or coordinates. I-1 to I-10: the `reported`
  event, `result_kind` and `not_done_reason` (v24), results for legacy runs, settlement of Saved ·
  changed rows, unreadable snapshots, entry actions, stale forms, Tonight's line, the Logbook, the
  backup (DECISIONS E.1, "Stage 8 decisions").
- **Frozen:** S8.1 → S8.2 → S8.3 → S8.4 → S8.5 → S8.6 → S8.7 → S8.8 → S8.9 → Stage 8 validation. No
  gate is open.
- Stage 7's "Current state" entries moved verbatim to `PROGRESS_HISTORY.md`.
- **Verification:** the documentation class (V1): references and IDs resolve; `git diff --check`. No
  gate input changed, so S7.V2's gate is Stage 8's baseline (below).

**Before this:** Stage 7 closed on 2026-09-29 at `21e9cb1` ([report](STAGE_7_VALIDATION.md)); its
entries, from its planning to its closure, are in `PROGRESS_HISTORY.md`.

### Reusable validation evidence as of 2026-10-17 (superseded rows included)

Per `CLAUDE.md`, Verification Policy V3: reuse while the inputs are unchanged.

| Evidence | Ran at | Still valid because |
| --- | --- | --- |
| **Remote CI PASS** (run 39020770255 (https://github.com/Buffur/Astro-Planner/actions/runs/39020770255)): the workflow's gate on `ubuntu-24.04`, Flutter 3.47.4 | **`461e38c`** | The same inputs as the row below |
| **Full quality gate PASS on Linux and Windows** (S12.1): Encoding; Format; Analyze (no issues); 1,844 tests, 2 expected skips; host E2E `core_loop_test.dart` (2) and `perf_scenarios_test.dart` (1). Linux: WSL Ubuntu 26.04, Flutter 3.47.4 Linux archive (CI-equivalent, not a GitHub run) | **`461e38c`** | Ran after S12.1's last change; supersedes the S11.C2 row below. Reusable while `git diff --stat 461e38c HEAD -- . ':!docs' ':!CLAUDE.md' ':!README.md'` stays empty |
| **Full quality gate PASS** (S11.C2): Encoding; Format; Analyze (no issues); 1,844 tests, 2 expected skips; host E2E `core_loop_test.dart` (2) and `perf_scenarios_test.dart` (1) | **S11.C2's commit**, on Flutter 3.47.4 | Ran after S11.C2's last change; supersedes the S11.C1 row below. Reusable while `git diff --stat <S11.C2 commit> HEAD -- . ':!docs' ':!CLAUDE.md' ':!README.md'` stays empty |
| **Full quality gate PASS** (S11.C1): Encoding; Format; Analyze (no issues); 1,840 tests, 2 expected skips; host E2E `core_loop_test.dart` (2) and `perf_scenarios_test.dart` (1) | **S11.C1's commit**, on Flutter 3.47.4 | Ran after S11.C1's last change; supersedes the S10.6 row below. Reusable while `git diff --stat <S11.C1 commit> HEAD -- . ':!docs' ':!CLAUDE.md' ':!README.md'` stays empty |
| **Full quality gate PASS** (S10.6): Encoding; Format; Analyze (no issues); 1,838 tests, 2 expected skips; host E2E `core_loop_test.dart` (2) and `perf_scenarios_test.dart` (1) | **S10.6's commit** (the lockfile without `sqlite3_flutter_libs`), on Flutter 3.47.4 | Ran after S10.6's last change; supersedes the S10.5 row below. Reusable while `git diff --stat <S10.6 commit> HEAD -- . ':!docs' ':!CLAUDE.md' ':!README.md'` stays empty |
| **Full quality gate PASS** (S10.5): Encoding; Format; Analyze (no issues); 1,838 tests, 2 expected skips; host E2E `core_loop_test.dart` (2) and `perf_scenarios_test.dart` (1) | **S10.5's commit**, on Flutter 3.47.4 | Ran after S10.5's last code change; supersedes the S10.3 row below. Reusable while `git diff --stat <S10.5 commit> HEAD -- . ':!docs' ':!CLAUDE.md' ':!README.md'` stays empty |
| **Full quality gate PASS** (S10.3): Encoding; Format; Analyze (no issues); 1,837 tests, 2 expected skips; host E2E `core_loop_test.dart` (2) and `perf_scenarios_test.dart` (1), one step each | **S10.3's commit** (inputs as at `80dfadd` plus S10.3's editor change), on Flutter 3.47.4 | Ran after S10.3's last code change; supersedes the TD-089–TD-091 row below. Reusable while `git diff --stat <S10.3 commit> HEAD -- . ':!docs' ':!CLAUDE.md' ':!README.md'` stays empty |
| **Full quality gate PASS** (TD-089–TD-091): Encoding; Format; Analyze (no issues); 1,833 tests, 2 expected skips; 2 host E2E | **`0f09608`**, on Flutter 3.47.4 | The last code change before Stage 10; supersedes the S9.9 row below. Stage 10's baseline. Reusable while `git diff --stat 0f09608 HEAD -- . ':!docs' ':!CLAUDE.md' ':!README.md'` stays empty |
| **Full quality gate PASS** (S9.9): Encoding; Format; Analyze (no issues); 1,825 tests, 2 expected skips; 2 host E2E | **`0a0c95e`**, S9.9's final inputs, on Flutter 3.47.4 | Ran after S9.9's last code change, the last code change of S9.1–S9.9; supersedes S9.1–S9.8's gates and S8.9's below. Reused by the Stage 9 validation: `git diff --stat 0a0c95e HEAD -- . ':!docs' ':!CLAUDE.md' ':!README.md'` empty at `8e53479`. Reusable while that diff stays empty |
| **Stage 9 validation probes PASS**: P1 (target and site delete paths, "Target deleted"), P2 (the cloud gate's threshold changes the usable time), P3 (an unknown cloud hour draws no bar), P4 and P5 (Night & Moon without sunset, without astronomical darkness) | Stage 9 validation, application code `0a0c95e` | Temporary, deleted; application code unchanged since. TD-089 asks for them as committed tests |
| **Full quality gate PASS** (S8.9): Encoding; Format (463 files, 0 changed); Analyze (no issues); 1,785 tests, 2 expected skips; 2 host E2E | **`690b94a`**, S8.9's final inputs, on Flutter 3.47.4 | Ran after S8.9's last code change, the last code change of Stage 8; supersedes S8.1–S8.8's gates. Reused by the Stage 8 validation: `git diff --stat 690b94a HEAD -- . ':!docs' ':!CLAUDE.md' ':!README.md'` empty. Reusable while that diff stays empty. Supersedes S7.V2's gate at `d28f5a8` (1,734), kept below as Stage 7's closing evidence |
| **Full quality gate PASS**: Encoding; Format (461 files, 0 changed); Analyze (no issues); 1,734 tests, 2 expected skips (the local real samples; the opt-in S5.9 render test); 2 host E2E | **`d28f5a8`**, S7.V2's final inputs | Ran after S7.V2's last code change; covers both corrections. Reused by the V5 revalidation: `git diff --stat d28f5a8 HEAD -- . ':!docs' ':!CLAUDE.md' ':!README.md'` empty at `21e9cb1`. Supersedes S7.V1's gate at `46e7688` (1,719) and S7.6's at `d13fdab` (1,710) |
| **Stage 8 validation probes PASS**: P1 (v23 → v25 preservation, every status), P2 (S8.4 acceptance 2), P3 and P4 (mutations: the TD-063 and ENG-14 tests fail without their fixes) | Stage 8 validation at `690b94a` | Temporary, removed; application code unchanged since. P5 reproduced TD-085 (not a pass) |
| **Pinned catalog regeneration PASS**: 164 objects (109 Messier), output matches committed text after line-ending normalization | Stage 7 validation at `d13fdab` | Tool/asset unchanged; temporary source CSVs removed, original asset bytes restored |
| **Six Stage 7 probes PASS** (FAIL at `d13fdab`): the two patches applied unchanged to the `099531b` test files, run against the corrected `lib/` | V5 revalidation at `21e9cb1` | Application code unchanged since `d28f5a8`; the same cases are committed tests in the gate above. Six fresh probes (V5-P1..P6) also PASS; temporary, removed |
| Local real-sample metadata test PASS (DNG, JPEG, HEIC) | After S3.V4 (`2447962`) | Metadata code unchanged since; environment-dependent (the owner's sample folder) |
| Device checks M1–M4 PASS (owner's Xiaomi 14T Pro, `.s2check` build) | `79f392c`, `237c55f`, `2b045eb` | Device evidence; valid for the flows it covered until those flows change. S3V-08 and S2V-06's checks remain unverified |
| **Focused probe PASS after S6.V1** (was FAIL at the validation, application code `d7e1477`): `evidence/S6V_01_DELETE_UNDO_PROBE.patch` applied unchanged, run (`--plain-name "S6V probe"`), then removed; "4 blocks, last count 7, example badge false" | S6.V1's final inputs | The same inputs as the gate above. Its sequence is also a committed test now (`capture_blocks_undo_test.dart`) |

### Registers, owner actions, blockers, next action and carried items as of 2026-10-17 (superseded)

#### Open research gates

All defined in `POST_ROADMAP_PLAN.md` §7.

| ID | Topic | Stage | Status |
| --- | --- | --- | --- |
| RG-01 | Metadata formats, libraries, file selection and samples (resolves PD-21) | 2 | **Decided** 2026-09-26 (ADR-017), **amended** the same day (the owner's priorities, ADR-017 §13). JPEG and HEIC samples exist (S2.8, S2.9); FITS, PNG and proprietary RAW still need samples, and are out of Stage 2 |
| RG-02 | Metadata → equipment identity, derivability, matching, provenance and conflicts | 3 | **Decided** 2026-09-26 (S3.D; ADR-018), after S3.R1 (`research/RG-02_EQUIPMENT_IDENTITY.md`) |
| RG-03 | Sourcing equipment specifications (catalog or none; licence; the verified-seed policy) | 3 (7) | **Deferred by the owner** 2026-09-26 (S3.D, D2): no source in Stage 3. **Researched** 2026-09-29 (S7.R5, `research/RG-03_EQUIPMENT_SPECS.md`); **decided 2026-09-29: Q1** (no source; lensfun crop factors the candidate with RG-12, Stage 9) |
| RG-04 | Execution's role and how actuals are captured | 4 | **Decided** 2026-09-27 (S4.R2; E.1): B, the Logbook first and the tracker optional; G2 post-session results. Its optional tracker is **superseded** 2026-09-27 (the tracker leaves the target product; P8.4) |
| RG-05 | Home/Tonight hierarchy, drill-downs and a possible Analytics destination | 4 | **Decided** 2026-09-27 (S4.R4; E.1): Tonight plan-first with a context line; detail screens; no new tab |
| RG-06 | Basic/Advanced modes against progressive disclosure | 4 | **Decided** 2026-09-27 (S4.R4; E.1): progressive disclosure; no modes |
| RG-07 | Target catalog expansion, names and search | 7 | **Decided** 2026-09-29 (S7.R3; DECISIONS E.1, "RG-07 decided"): T1 only |
| RG-08 | Site elevation: an automatic source, optional, or dropped | 7 | **Decided** 2026-09-29 (S7.R4; DECISIONS E.1): E2, optional and Unknown by default |
| RG-09 | Bortle/SQM sources, whether SQM stays a field, and the light-pollution map provider | 7 | **Decided** 2026-09-29 (S7.R4; DECISIONS E.1): S3 (manual, optional, collapsed), M2 (lightpollutionmap.app) |
| RG-10 | Calibration-frame workflows and inheritance | 7 | **Decided** 2026-09-29 (S7.R2; DECISIONS E.1, "RG-10 decided"): L1, D1, T0, O0, N1, H1; ADR-020 |
| RG-11 | Capture parameters (ISO or gain, binning, white balance, focus, interval) and their labels | 7 | **Decided** 2026-09-29 (S7.R1; DECISIONS E.1, "RG-11 decided"): C1, B1, W1, F1, I1, P2; ADR-020 |
| RG-12 | Licence requirements against GPL-3.0 | 9 | **Researched** 2026-09-29 (S9.11, `research/S9.11_LICENCE.md`); **deferred by the owner** 2026-09-30 (GPL-3.0 stays; P9.5 waits for a decision) |
| RG-13 | Settings: real-world needs and where each setting belongs | 9 | **Answered** 2026-09-29 (S9.3, `research/S9.3_SETTINGS.md`; DECISIONS E.1, D9-3); built by S9.4 |
| RG-14 | Proprietary RAW compatibility and libraries (no ad hoc parsers) | 2 (S2.R3) | **Decided** 2026-09-26 (DECISIONS E.1): none in Stage 2; per-format adapters later, with samples; `ExifInterface` and LibRaw rejected |

#### Open owner decisions

All defined in `POST_ROADMAP_PLAN.md` §8.

| ID | Decision | Stage | Status |
| --- | --- | --- | --- |
| RD-01 | The GitHub account behind the app identity: `chacha12` or `Buffur` | Before any upload | **Decided 2026-10-17 (RA.D ID-2): B, Buffur** (DECISIONS E.1, "RA.D — round 1 identity"); intended id `io.github.buffur.culmina` and repository `Buffur/Culmina`; not implemented (TD-088 open until then) |
| RD-02 | The TASK 0.3 holdovers (ADK skill, `skills-lock.json`, `docs/archive/`, `sqlite3_flutter_libs`) | 1 / 10 | Open, except the dependency: **`sqlite3_flutter_libs` removed** by S10.6 (2026-09-30, under the owner's delegation, D10-5) |
| RD-03 | Wording rulings: the SCI-05 ISO label; the SCI-04 time-resolution caveat | 1 | **Resolved** 2026-09-25: a neutral label (S1.8); SCI-04 documented only (S1.13). DECISIONS E.1 |
| RD-04 | New-draft defaults and the example plan | 4 | **Decided** 2026-09-27 (S4.R3; E.1): nothing preselected on the first run; New keeps the site and rig; an empty plan with "Start from the example plan" |
| RD-05 | Drafts and "New session" semantics (Stage 1 may decide an interim safeguard) | 4 (1) | **Decided** 2026-09-27 (S4.R3; E.1): L1 (Draft internal; Save explicit), Y2, U1. The S1.6 interim stands until Stage 6 builds U1. **Clarified** 2026-09-27 (S4.V2; E.1, "S4R-01 and S4R-02 decided"): saved snapshots are immutable per night; results without Save plan; Stage 8 delivers the saved-plan transition at once |
| RD-06 | The planner's section order; integrity text one tap away | 4 | **Decided** 2026-09-27 (S4.R4; E.1): answer first, decision order; detail one tap away |
| RD-07 | The Library's role and pickers; where Progress lives | 4 | **Decided** 2026-09-27 (S4.R5; E.1): the Library manages; choosing in context; Progress in the Logbook |
| RD-08 | Tracking per rig or per session; the seeded rig's tracking | 7 (before Stage 6's capture-plan work, P6.8 = S6.9) | **Decided** 2026-09-28 (owner): **T3**, the rig's default with a per-plan override; the seeded rig stays unknown (DECISIONS E.1, "RD-08 decided"). Built in Stage 7 by **S7.1** (ungated) |
| RD-09 | Destructive interactions: confirm or undo | 5 | **Decided** 2026-09-27 (owner): **M + S1**, undo for edits inside a plan, confirm for stored records; a visible Delete with swipe as a shortcut (DECISIONS E.1, "RD-09 decided"; `IA_WIREFRAMES.md` §3 amended for plan edits). Built by S5.8 |
| RD-10 | Ordering Tonight's candidates without a score | 6 (S6.14) | **Decided** 2026-09-28 (owner): **O1**, usable time, then frame fill, then the name (DECISIONS E.1). Built by S6.14 |
| RD-11 | Where the Moon and cloud gate controls live (TD-050) | 6 or 9 (S6.15 or P9.3) | **Decided** 2026-09-28 (owner): **S9**, Stage 9's Settings (P9.3, with RG-13); S6.15 not built (DECISIONS E.1) |
| RD-12 | The resume prompt's Finish | 8 | **Lapsed** 2026-09-27: the resume prompt goes with the tracker (E.1, "Stages 6–11 amended after Stage 5"); P8.4's audit covers a run still in progress at the upgrade |
| RD-13 | Provenance of an accepted estimate | 8 | **Decided** 2026-09-29 (Stage 8 planning, delegated by the owner; E.1, "Stage 8 decisions", D8-3): "Reported as planned"; old estimates not relabelled. Built by S8.1 |
| RD-14 | Vocabulary (rig or equipment; Sessions or Logbook; window names) | 4 | **Decided** 2026-09-27 (S4.R5; E.1): Rig, Plan, Logbook; the glossary |
| RD-15 | A local diagnostics export for the beta | 11 | **Decided** 2026-09-30 (Stage 11 planning, delegated; E.1, D11-4): not for the beta; revisit if triage lacks information |
| RD-16 | When the metadata feature becomes visible (PD-06 gate) | 2 (3) | **Resolved** 2026-09-26 (S3.D, ADR-018 §7): visible at the end of Stage 3 (S3.7), as "Add from a photo" on the equipment screen. It stayed hidden throughout Stage 2 |
| RD-17 | Push the CI workflow to the remote and observe a first run | 1 (optional) / 11 | **Pushed by the owner** (observed 2026-10-17: `origin/main` = `b1df679`, PR #1 merged 2026-10-16). Three CI runs failed (TD-104); after S12.1 the owner-authorized push produced the first passing run, run 39020770255 (https://github.com/Buffur/Astro-Planner/actions/runs/39020770255). **Resolved 2026-10-17** |

Answered in part by Stage 0: the direction part of 07 §6 item 11 (the primary 1.0 user), in
`PRODUCT_DIRECTION.md` §2. Modes stay open as RG-06.

#### Owner actions outstanding

These block a release, not refinement. *Aligned 2026-10-17 (GitHub-only distribution): store items are deferred; the release is a signed APK on GitHub (S17.6, S17.8).*

- TASK 16.2 (now S17.6): create the **release** keystore and `android/key.properties` (no Play upload key); install the SDK cmdline-tools;
  build and check a signed release APK (S17.6; the AAB is deferred, store distribution).
- TASK 16.3: publish the privacy policy with the contact email filled in; confirm the URL is
  live (S12.3); ~~make the repository public~~ (public, observed 2026-10-17); the Data Safety form is **deferred** (store distribution).
- OD-07: a formal trademark search for "Culmina" (S12.2) — recommended, no longer a store gate; RD-01 is decided (B).
- A device or emulator for the device rows (`TEST_PLAN.md` L1–L8, and the other checks in
  `POST_ROADMAP_PLAN.md` Appendix B).
- Stage 3: say which cameras and optics you use besides the phone (a DSLR/mirrorless JPEG, or a
  FITS file, would let Stage 3 check those classes on real files). The phone is needed for S3.7's
  device check M4. *(M4 passed at `2b045eb`; the phone is now needed only for the optional S3V-08
  recheck and S2V-06's checks. Noted at the Stage 3 final sign-off.)*
  Samples for FITS, PNG, AVIF or RAW, when available, enable their readers later. The DNG,
  JPEG and HEIC samples stay outside Git.

#### Known blockers

- **Stage 1 (closed by waiver):** X2 is done (S1.V6, 2026-09-26). TD-063 is in Stage 8. W1 was
  decided with RD-05's U1, and S6.3 builds it.
- **Stage 2 (closed by waiver):** nothing blocks. The carried items are listed under "Next
  allowed action".
- **Stage 3 (closed by the final sign-off PASS, 2026-09-27):** nothing blocks. Carried: S3V-08
  (device recheck, `.s2check` only), TD-072 with S3F-01, S3F-02, TD-070's Stage 8 remainder.
  Equipment identity for dedicated astro cameras still needs a FITS sample (S2.6).
- **Stage 4:**
  - **closed 2026-09-27** (the final, bounded validation passed). Carried to Stages 6 and 8:
    S4-DEF-01 to S4-DEF-08;
  - S4.E stays optional; Stage 6 carries the five-second test as S6.E;
  - S4V-02's script correction: **done 2026-09-28** as S6.E's first step.
- **Stage 5 (closed 2026-09-27):** nothing blocks.
  - Carried: TD-073 (two messages with an action persist: the site prompt's in S6.13, the Start
    message's in P8.4); UX-39's field-mode card borders (Stage 11 darkness test); the stale CLAUDE.md test count (removed from permanent instructions on 2026-10-17).
  - Optional: the owner's review of the S5.9 images.
  - The adoption plan (`DESIGN_SYSTEM.md` §9) feeds Stages 6, 8 and 9.
- **Stage 6 (closed 2026-09-28):** nothing blocks. S6V-01 / TD-082 was resolved by S6.V1 and its
  V5 revalidation passed ([report](STAGE_6_VALIDATION.md)). Product gates decided: S4-DEF-04 (R),
  RD-08 (T3, the override built in Stage 7), RD-10 (O1), RD-11 (S9).
  - Carried: S6.E UNVERIFIED (the owner accepts the missing independent participant); the tracker
    until P8.4; TD-074 (allocated to Stage 9's planning at Stage 7 planning); TD-050 (Stage 9,
    P9.3); TD-081 (Stage 9 or 11); the validation's DEFERRED items (Stage 7's are now in its frozen
    sequence; Stage 8: saved-plan working copy and results, P8.1–P8.4, P8.7; Stage 9: richer detail
    screens).
- **Stage 7 (closed 2026-09-29):** nothing blocks. S7V-01 / TD-083 and S7V-02 / TD-084 were
  resolved by S7.V1/S7.V2 and the V5 revalidation passed ([report](STAGE_7_VALIDATION.md)).
  Carried: TD-074 (Stage 9 planning); RG-03 = Q1 with lensfun as the RG-12 candidate (Stage 9);
  the device and real-sample gaps listed under "Carried". All Stage 7 research
  and owner gates are decided; no new decision blocks these corrections. Other criteria retain PASS.
- **Stage 8 (closed 2026-09-29):** nothing blocks. Validation PASS ([report](STAGE_8_VALIDATION.md)).
  Carried: TD-085, TD-086, TD-087 (non-blocking follow-ups); the lifecycle device rows L1–L8 (Stage 11).
- **Stage 9 (closed 2026-09-30):** nothing blocks. S9.1–S9.9 PASS ([report](STAGE_9_VALIDATION.md));
  TD-089 to TD-091 fixed; S9.10–S9.12 deferred by the owner. Carried: TD-088 (with RD-01, before any
  upload), RG-12 (the owner), the logo (P9.4, the owner), TD-074 (after Stage 11, D9-6).
- **Device evidence:** M1 seekable providers and M2 non-backup/cancel paths were
  recorded at `79f392c`. Native streaming and real-backup preview cancellation
  remain unverified on-device. S2.V3 adds host JVM streaming tests; these do not
  upgrade device evidence. Stage 11 lifecycle rows remain open.
- **Release:** RD-01; the 16.2 upload key; the 16.3 policy. These do not block refinement.

#### Next allowed action

1. Each on its own start instruction: **S12.3** (the agent drafts the policy text with the owner's contact email; the owner renames the repository and publishes Pages) and **S12.4** (the owner's S11P-03 decision); **S12.2** (the owner's trademark search) is recommended before the rename but gates nothing (GitHub-only distribution). Then Stage 13. S12.1 is done. **RA.D**: record only the owner's answers on the [decision sheet](research/RA_D_DECISION_SHEET.md) in DECISIONS E.1 (with the ADR amendments they imply); then **RA.P** after G2. Do not start implementation; TD-104 needs the CI log from the owner.
2. **Stage 11 remains open:** S11.6 phone checks when connected; S11.7 readiness against the existing matrix and named baseline when requested. RA.P must carry all unresolved release checks and decide their scheduling after the product decisions; no previous PASS is reopened without V3/V6 grounds.
3. **Owner actions** remain: phone, signing/upload key, published privacy policy/contact, RD-01/TD-088, S11P-03, go/no-go and deferred identity/logo/provider gates. The reassessment does not silently resolve any of them.

**Carried:**
- Stage 10's phone runs (S10V-04): `integration_test/perf_scenarios_test.dart` on a physical
  phone in profile mode (Stage 11); until then "responsive on representative hardware" is UNVERIFIED;
- S4-DEF-04 decided (R) and built by S6.3; S4-DEF-01 to S4-DEF-03 and S4-DEF-05 to S4-DEF-08 decided
  at Stage 8 planning (E.1, "Stage 8 decisions") and built by S8.1–S8.7;
- S4V-02: done (S6.E step 1, 2026-09-28);
- S3V-08: a device recheck of the corrected Stage 3 flow (unverified; separate);
- TD-072 (S3S-03, deferred by the owner) with its S3F-01 addendum; S3F-02 (a note on TD-071, no
  Task proposed);
- TD-070: resolved (S8.8); snapshots saved before S8.8 keep their group pairs and are read as stored;
- W1 (decided with RD-05's U1): built by S6.3;
- TD-063: resolved (S8.4);
- TD-057 and TD-058: resolved (S6.4, S6.2);
- TD-074: allocated to Stage 9's planning (not data entry); the owner may pull it into Stage 7;
- RD-17 (pushed; CI red, TD-104);
- the S1.5 and S1.11 device checks (Stage 11);
- S2V-06's device checks (a non-seekable provider; a real backup's preview cancel): the next
  time the phone is connected, or Stage 11;
- the stale id-holding preferences after a reset: resolved with TD-056/ENG-14 (S8.9);
- TD-085, TD-086, TD-087: the Stage 8 validation's non-blocking follow-ups, for a later Task that
  touches the saved-plan boundary, the result form or these tests.

## Earlier "Current state" entries (newest first, up to Stage 8 planning)

*Moved verbatim from `PROGRESS.md` on 2026-09-29 at Stage 8 planning: Stage 7's entries, from its planning to its closure, and the "Before this" pointer that followed them. The Stage 6 batch follows them.*

**Stage 7 V5 revalidation, 2026-09-29: PASS; Stage 7 CLOSED** at `21e9cb1` ([report](STAGE_7_VALIDATION.md),
same chat at the owner's request, disclosed): the original six probes, replayed unchanged on the
validation-time test files against the corrected code, pass; six fresh adversarial probes pass;
the corrections' diffs change nothing else. S7.V2's gate reused (V3: only README changed since).
One observation, no finding. Documentation only.

**S7.V2 done, 2026-09-29** (`d28f5a8`; S7V-02 / TD-084 resolved): the site editor rebuilds its back guard
when name, elevation or notes start or stop differing from the opened form (a flip-only
listener), so Back (app bar or system) asks about an edit to any one field; a reverted edit and
a new site with only the device zone leave without asking. 15 new tests (13 fail on the
`d13fdab` editor). Verification: localized code change (one screen, local state), Task
completion under Stage 7's frozen rule: the full gate after the last code change, PASS (below).

**S7.V1 done, 2026-09-29** (`46e7688`; S7V-01 / TD-083 resolved): "Use other values" copies only what the
frame type still takes from its source (`CalibrationMatch.takesExposure`/`takesSensitivity`),
so a flat's or bias's exposure and a flat's ISO or gain stay the user's; a source change no
longer replaces a flat ISO/gain the user typed, cleared or re-kinded. The probe's three cases
plus six more are permanent tests (six fail on the `d13fdab` dialog). Verification: shared
behaviour, Task completion under Stage 7's frozen rule: the full gate after the last code
change, PASS (below). No schema, formula or vector change.

**Stage 7 independent validation, 2026-09-29: BLOCKED** at `d13fdab`
([report](STAGE_7_VALIDATION.md)): S7V-01 / TD-083 (calibration unlock/source changes overwrite
independent exposure or edited gain), S7V-02 / TD-084 (name/elevation/notes-only site edits leave
without the discard prompt). Six focused widget probes failed; retained as unapplied patches in
`evidence/`. Other frozen criteria PASS. S7.6's recorded gate reused (unchanged inputs); pinned
catalog regeneration matched. No application fixes. Corrections S7.V1 → S7.V2 → bounded V5
revalidation; each is a separate cycle. No new owner decision.

**S7.6 done, 2026-09-29** (UX-22; RG-03 = Q1): the rig form asks the pixel size once and keeps the
maximum exposure, the RAW size and the rotation one tap away in "More (optional)" (open when an import
pre-fills the RAW size); "Add rig"/"Edit rig", Save primary; nothing stored lost or reinterpreted.
Verification: shared behaviour (`CollapsibleSection` gains a controlled use; the editor several
screens open): the full gate after the last code change, PASS (below).

**RG-03 decided, 2026-09-29: Q1** (DECISIONS E.1): no equipment specification source; lensfun
crop factors recorded as the candidate to revisit with RG-12 in Stage 9. S7.6 has no source path.
Documentation only.

**S7.5 done, 2026-09-29** (RG-08 = E2, RG-09 = S3/M2, UX-21): the site editor gains "Use current
position" (GPS on the tap only; the fix fills the form until Save); elevation is optional and unknown
when empty (schema v23: nullable, every stored value kept); Bortle and SQM sit in a collapsed,
remembered "Sky darkness (optional)" section with the map link at the typed coordinates; the map is
lightpollutionmap.app (About, privacy policy, COMPLIANCE); back with changes asks Cancel · Discard ·
Save. Verification: high-risk (a migration): the full gate after the last code change, PASS (below).

**S7.4 done, 2026-09-29** (RG-07 = T1): search finds a bundled object by any common spelling of its
designation, by its NGC/IC, Caldwell and LBN aliases and by every OpenNGC common name, offline,
ordered by match kind then id, with no score. Catalog version 3 adds aliases and no object (every
`since` stays 2, so no deleted target returns); schema v22 adds `target_aliases`, rebuilt by the
seeder when its version differs. The candidates list is unchanged (host, median of 7: 53.4 ms before,
52.7 ms after; 164 targets). Verification: high-risk (a migration and the catalog): the full gate
after the last code change, PASS (below).

**S7.3b done, 2026-09-29** (ADR-020 §8; RG-10 = N1): a DSLR/mirrorless or Unknown rig can state
in-camera noise reduction (off by default, never inferred; schema v21). When on, each light is
followed by a dark of its exposure inside the light's fit event, counted as in-window calibration;
integration, imaging time and √N are unchanged; E8, E8b and E8c are reproduced to the millisecond;
E1–E7 unchanged. Phones and astro cameras keep a stored value and ignore it. The assumptions list
it, Budget details names the darks, a matching dark block is warned as "Darks twice", and the
snapshot records it. Verification: high-risk (a calculation and a migration): the full gate after
the last code change, PASS (below).

**S7.3a done, 2026-09-29** (ADR-020 §6–§7; RG-10 = L1, D1, H1): a new calibration block takes what
it must match from a chosen light (a flat, for a dark flat), shown with its origin, until "Use other
values"; calibration blocks follow the camera type's ISO/gain and binning like lights; rows warn in
words with a one-tap "Match the lights"/"Match the flats" and Undo, and name light filters without
flats; warnings never block, unknown never fails. The dark flat is a fifth frame type through the
store, the snapshot, the export and every screen. Tips: one line, "More", "Hide tips" remembered;
hiding them hides no warning. No schema change. The "darks twice" check waits for S7.3b's switch.
Verification: shared behaviour plus a stored enum value (the planner's dialog, the export): the full
gate after the last code change, PASS (below).

**S7.2b done, 2026-09-29** (ADR-020 §3–§5; RG-11 = C1, B1, W1, F1, I1, P2): a light block shows ISO
for phones and cameras, gain for astro cameras, the choice for Unknown; binning only for astro
cameras and Unknown; values a class hides are kept and named, never converted. A new light block
starts from the last one, marked as a proposal. "Time between frames" replaces "Per-frame
overhead" in Settings and the assumptions panel, with the no-double-count help; the budget is
unchanged. The block dialog's dropdowns now wrap at 200 % text. Verification: shared behaviour (the
planner's dialog, Settings): the full gate after the last code change, PASS (below).

**S7.2a done, 2026-09-29** (ADR-020 §2; RG-11 = C1): a rig has a camera type (Phone · DSLR or
mirrorless · Astro camera (colour) · Astro camera (mono) · Unknown), chosen in the rig editor, Unknown
by default and for the example rig; "Add from a photo" never proposes one, even from a saved rig with
the same camera; a new snapshot records it; the Library shows it once chosen. **Schema v20**
(`camera_modules.camera_class`). Deliberate test changes: the v19 pins move to v20; one editor test's
finder names the tracking dropdown. Verification: high-risk (schema): the full gate after the last
code change, PASS (below); every acceptance criterion checked.

**S7.1 done, 2026-09-29** (RD-08 = T3; the plan's "S7.1" for the detail): a plan can override its
rig's tracking for its night ("Tracking for this plan", under the rig; S6.9's button opens the same
choice). The guidance (CALC-31) reads the effective value; the rig and the example rig's Unknown are
never changed; Save records the value and its source; Discard restores it; Copy carries it; New plan
starts without it; the export carries it. **Schema v19** (`session_logs.tracking_override`). The
backup and unsupported-database tests pinned to v18 were moved to v19 deliberately. Verification: the
high-risk class (schema, snapshot, export): the full gate after the last code change, PASS (below);
every acceptance criterion checked.

**S7.R5 done, 2026-09-29** (RG-03 research; documentation only; `research/RG-03_EQUIPMENT_SPECS.md`):
- **No official API and no machine-readable maker data found;** maker pages are HTML (scraping is
  rejected).
- **Open datasets inspected** (downloaded to scratch, deleted): openMVG (MIT; 3,633 consumer cameras to
  about 2016; no EOS R, no astro cameras, no current phones; nominal small-sensor sizes); lensfun (CC
  BY-SA 3.0; current bodies, but a crop factor only); open-product-data (no licence found);
  pixel-pitch lists built by scraping (excluded).
- **Recommended Q1:** no source in Stage 7; lensfun's crop factor recorded as the candidate CALC-40
  input for DSLR and mirrorless files without f35, to revisit with RG-12 in Stage 9; FITS (S2.6) as
  the astro-camera path. One owner question (§8); nothing adopted.
- **Verification:** the documentation class.

**RG-08 and RG-09 decided, 2026-09-29 (the owner, in chat; DECISIONS E.1):** E2 (elevation optional,
Unknown by default; no automatic source), S3 (Bortle and SQM manual and optional in one collapsed
section, with a map link), M2 (the map link to lightpollutionmap.app). S7.5's rules are in the plan.
Documentation only.

**S7.R4 done, 2026-09-29** (RG-08 and RG-09 research; documentation only;
`research/RG-08_09_SITE_AUTOMATION.md`):
- **Elevation:** no calculation reads it; the forecast already receives Open-Meteo's 90 m terrain
  elevation (unread today); the Elevation API (Copernicus GLO-90, attribution required) could propose
  it; GPS gives ellipsoid height unless the device offers sea-level altitude. **Recommended E2**
  (optional, Unknown by default); E1 (a terrain-data proposal on tap) is the owner's preference.
- **Bortle and SQM:** no acceptable automatic source (the 2016 atlas is CC BY-NC, 2.9 GB and about
  2014 data; the map sites offer no data terms or API); both stay manual or unknown. **Recommended
  S3** (both optional in one collapsed section, with a link to look them up).
- **The map link:** lightpollutionmap.app (Stargazing Hub Team) documents a `?lat=&lng=&zoom=` link.
  **Recommended M2.**
- Three owner questions (§8); nothing decided. **Verification:** the documentation class.

**RG-07 decided, 2026-09-29 (the owner, in chat; DECISIONS E.1, "RG-07 decided"): T1 only.**
Searchable aliases from the pinned OpenNGC (Messier's NGC/IC numbers, common names, Caldwell, LBN)
in their own table, and a normalised search; no new objects and no online lookup. S7.4's rules are
in the plan. Documentation only.

**S7.R3 done, 2026-09-29** (RG-07 research; documentation only; `research/RG-07_TARGET_CATALOG.md`):
- **Counted in the pinned OpenNGC v20260501** (downloaded to scratch, deleted, nothing committed):
  13,371 objects; **only 151 have a common name**, so none of the catalog's 97 unnamed objects can
  be named from it; it does hold every Messier object's NGC/IC designation, Caldwell (105) and LBN
  (94) numbers and 16 extra common names. Sharpless, vdB and most Barnard and Abell objects are not
  in it.
- **Search today misses** "M 31", "Messier 31", "NGC 224" (M31) and "NGC7000"; the alias rules
  are written as testable examples (§6).
- **Growth costs** the candidates list: ~0.58 ms per target on the desktop VM (95 ms for 164), and
  thousands of faint galaxies would bury the showpieces.
- **Recommended:** T1 (aliases from the pinned OpenNGC in their own table, normalised search; no new
  objects, no network). More objects and an optional online lookup (CDS Sesame; per-dataset CDS
  licences; rate limits unknown) are the owner's choices. Three owner questions (§9); nothing
  decided.
- **Verification:** the documentation class (references resolve; `git diff --check`).

**S7.D done, 2026-09-29** (documentation only): **RG-10 decided** by the owner in chat, every
recommendation (L1, D1, T0, O0, N1, H1; DECISIONS E.1, "RG-10 decided"). **ADR-020 accepted:** the
camera class on the rig, the light-block fields by class, "Time between frames", proposals, the
calibration matrix and its match checks, dark flats, tips, and in-camera noise reduction as
in-window calibration with new vectors E8–E8c (amends ADR-009; ADR-011 gains two camera fields).
S7.2 split into **S7.2a** (the class on the rig) and **S7.2b** (the light-block form); S7.3 into
**S7.3a** (calibration blocks) and **S7.3b** (noise reduction in the budget and the fit).

**S7.R2 done, 2026-09-29** (RG-10 research; documentation only; `research/RG-10_CALIBRATION_WORKFLOWS.md`):
- **From the sources** (Siril read directly; DeepSkyStacker and Canon through search results;
  PixInsight and ZWO-community guidance secondary): darks match the lights' exposure, ISO or gain,
  binning and temperature; flats keep the optical train, focus and filter, with their own exposure
  (no target-level guidance); bias is the shortest exposure at the lights' ISO or gain, temperature
  unimportant, optional for every class (dark flats the alternative on some CMOS cameras); dark flats
  match the flats.
- **The matrix's calibration columns** (§4) keep every budget effect inside ADR-009's existing lines;
  "a dark needs only a count" holds for typed fields only if inheritance is built.
- **Recommended:** L1 (copy when created, a mismatch warning, a one-tap fix), D1 (a "Dark flat" frame
  type), T0, O0, **N1** (in-camera noise reduction as a rig switch, counted as in-window calibration;
  an ADR-009 amendment), H1 (hideable one-line tips). Six owner questions (§10); nothing decided.
- **Verification:** the documentation class (references resolve; `git diff --check`).

**RG-11 decided, 2026-09-29 (the owner, in chat; DECISIONS E.1, "RG-11 decided"):** every
recommendation of S7.R1: C1 (a camera class on the rig, Unknown by default, never inferred; the
example rig stays Unknown), B1 (binning for astro cameras only, a record), W1, F1, I1 (the per-frame
overhead relabelled "Time between frames"; no budget change), P2 (copy the previous light block).
C1 splits S7.2 at S7.D. Documentation only.

**S7.R1 done, 2026-09-29** (RG-11 research; documentation only; `research/RG-11_CAPTURE_PARAMETERS.md`):
- **Camera classes:** phone, DSLR/mirrorless, astro camera (colour), astro camera (mono), unknown;
  cooled and readout mode are modifiers. No metadata AstroPlan reads can tell the class.
- **Findings:** ISO (phones, cameras) and gain with offset (astro cameras) are different controls,
  never converted; their record is what calibration must match (RG-10). Binning is per exposure only
  on astro cameras; on a phone it is the rig's mode. White balance is metadata in RAW files and has
  no planning consequence. Focus has no planning value beyond ADR-009's refocus overhead. The
  interval is already modelled once, as the per-frame overhead, but its label invites a double count
  with the dither settle. **In-camera long-exposure noise reduction** can double a camera's time per
  frame and is not modelled (handed to RG-10).
- **Recommended:** C1 (a class on the rig, Unknown by default, never inferred), B1 (binning for astro
  cameras only, a record), W1, F1, I1 (relabel, no budget change), P2 (copy the previous light
  block). Six owner questions (§11); nothing decided.
- **Verification:** the documentation class (references resolve; `git diff --check`). No gate input
  changed.

**Stage 7 planned, 2026-09-28** (documentation only; the owner's prompt
`prompts/STAGE_7_PLANNING.md`; the plan's "Stage 7 — frozen Task sequence"):
- **Verified against the code at `4b0df38` (§9.7).** Notable:
  - no camera class exists in the model, so nothing can tell which capture parameters apply (RG-11);
  - elevation is required (`REAL NOT NULL`) yet read by no calculation, and no GPS altitude is read;
    Bortle and SQM are read by no calculation either;
  - the catalog build keeps only OpenNGC's first common name and stores no cross-identifier, and
    "M 31", "NGC7000" or "NGC 224" find nothing;
  - the site editor has no discard guard (UX-21 confirmed); the rig editor still shows the pixel size
    twice and asks for a rotation nothing reads (UX-22);
  - binning is read by no calculation; the interval is the global per-frame overhead;
  - `SessionPlanViewModel` is at the 300-line physical cap again.
- **Frozen:** S7.R1 (RG-11) → S7.R2 (RG-10) → S7.D (ADR-020) → S7.R3 (RG-07) → S7.R4 (RG-08,
  RG-09) → S7.R5 (RG-03) → S7.1 → S7.2 (light blocks) → S7.3 (calibration and the budget) → S7.4
  (targets) → S7.5 (sites) → S7.6 (rigs) → Stage 7 validation. The parameter matrix's shape is
  fixed; no cell is filled. Each gated Task keeps its frozen criteria; its decision adds only the
  rule it decided.
- **RD-08 = T3's placement: S7.1**, ungated, which may run at any point: the nullable
  `session_logs.tracking_override` (v19), the effective value passed to `CapabilityCalculator`, the
  planner's control, the snapshot's value and source, Copy, New, Open and Discard, the export key,
  and the tests.
- **Not triggered:** the storage-input area (S6.10 found case C). **Allocated, not decided:** TD-074
  to Stage 9's planning (not data entry).
- **RG-03** is researched again (S7.R5), as the owner's prompt asks; adoption stays the owner's.
- **No owner decision is needed now:** each gate's choices wait for its research.
- Stage 6's "Current state" entries moved verbatim to `PROGRESS_HISTORY.md`.
- **Verification:** the documentation class (V1): references and IDs resolve; `git diff --check`. No
  gate input changed, so S6.V1's gate is Stage 7's baseline (below).

**Before this:** Stage 6 closed on 2026-09-28 at `da4c53d` ([report](STAGE_6_VALIDATION.md)); its
entries, from its planning to its closure, are in `PROGRESS_HISTORY.md`. S6.E stays **UNVERIFIED —
no independent participant available**, a gap the owner accepted.

### Stage 6 and earlier (moved at Stage 7 planning)

*Moved verbatim from `PROGRESS.md` on 2026-09-28 at Stage 7 planning: Stage 6's entries, from its
planning to its closure, and the "Before this" pointer that followed them. The Stage 6 planning
batch follows them.*

**Stage 6 closed, 2026-09-28** ([report](STAGE_6_VALIDATION.md), "Revalidation of S6V-01 /
TD-082 (V5)"): the V5 revalidation passed at `da4c53d`. Run in the chat that wrote S6.V1, at the
owner's request, so **not independent** (disclosed). Scope: F1, S6.8's badge rule, S6.9's Delete +
Undo, stale recovery and S6.V1's regression surface; every other PASS stands (V6). Evidence: the
full gate and the recorded probe reused (V3); the five committed regression tests; four fresh
adversarial probes, all PASS (a target change keeps the badge; a reorder, a second delete and Copy
behave; temporary, not committed). No blocker; one observation (after a reorder the block returns
at its old index, as S6.9 specifies). S6.E stays **UNVERIFIED — no independent participant
available**, the gap the owner accepted. Verification: documentation class. The Stage 6 entries
below stay here until Stage 7 planning moves them verbatim to `PROGRESS_HISTORY.md`, as Stage 6
planning did for Stage 5's.

**S6.V1 done, 2026-09-28** (`da4c53d`; S6V-01 / TD-082 resolved; the owner's S6.V1 prompt; the plan's
"Stage 6 validation" table): a delete's Undo owns only the deleted block.
- **Root cause:** `_BlockListState._delete` kept the example badge as it was at the delete, and
  `restoreCaptureBlock` wrote it back unconditionally. Add shows no message of its own, so the
  delete's Undo stays up after it, and tapping it relabelled the edited plan as the untouched
  example. A plan replaced meanwhile (New, Copy, Open, Track live) would also have received the
  old block.
- **Fix:** Delete runs through `deleteBlockWithUndo` (`widgets/capture_plan/blocks_undo.dart`),
  which records the delete as S6.16's `BlocksEdit`, with the session read after its autosave.
  `SessionPlanViewModel.restoreCaptureBlock(index, block, deletion:)` puts the identical block
  back at its index and keeps every edit made since. It restores the badge only while
  `BlocksEdit.isCurrent` holds (nothing changed since the delete). When `BlocksEdit.inPlan` fails
  (the plan was replaced), it is refused with S6.16's "Not undone" message. No history, no schema
  or persistence change. The removal is still immediate; its Undo message now appears once the
  delete's autosave has finished, as S6.16's messages do.
- **Tests:** five in `capture_blocks_undo_test.dart` ("Delete with Undo owns only the deleted
  block (TD-082)"): the exact sequence; a block edited since; Undo at once restores the example
  with its badge; a replaced plan; a saved plan's snapshot unchanged. The first, second and fourth
  fail on the old code. The recorded probe (`evidence/S6V_01_DELETE_UNDO_PROBE.patch`, applied
  temporarily, then removed) passes. S6.9's and S6.16's tests are unchanged and pass.
- **Verification:** class shared behaviour (a ViewModel and a shared helper). The full gate ran
  once, after the last code change, because the Stage Exit's gate must hold on the final inputs:
  PASS (below). Every acceptance criterion of the prompt checked. Stage 6 is **not** closed.

**Stage 6 validation, 2026-09-28: BLOCKED** ([report](STAGE_6_VALIDATION.md)). S6V-01 /
TD-082 reproduced: Delete from the example → Add a block → old Undo preserves the new block
but falsely restores the example badge. S6.8's badge rule and stale recovery fail; the other
technical criteria pass. S6.16's full gate reused under V3 (no changed inputs); one fresh focused
probe fails on the uncovered sequence. No code or existing tests changed. The past Capture ends
observation agrees with the selected whole-night contract (classification A, report C1).
S6.E is **UNVERIFIED — no independent participant available**, explicitly accepted by the owner;
that gap does not block closure. Stage 7 remains unstarted.

**S6.E device refreshed, 2026-09-28, 22:52–22:55** (documentation only; details in
`evidence/STAGE_6_FIVE_SECOND_TEST.md`): the separate `.s2check` app is now a debug build of
`d7e1477` (S6.16), built in a detached worktree with the local application-id suffix (reverted,
never committed) and installed as an update. The owner's app was not touched (last update 22:44:13
before and after; that update came from an Android Studio `flutter run` session, not this setup). A
new saved test plan (Test site, M31, the example rig and plan, night of Mon, Sep 28) reads "Fits: 1 h
48 min needed of 8 h 35 min usable"; the owner's review plan stays in Sessions. Both test screens
render; no device defect prevents the test. TD-080's two target actions are approved by the owner as
built. The five questions still need an independent participant.

**S6.16 done, 2026-09-28** (the owner's corrective pass; DECISIONS E.1, "Stage 6 corrective pass
decided"): TD-075–TD-080 resolved; ADR-019 §6 amended and built (status → site and night → target →
rig → capture plan → "Tonight for this target" → conditions); the core screens' finish (Tonight's
page title, context card, "Your plan" heading, Open planner always primary, the target rows; the
planner's status card and section headings); Undo for Fill/Trim, a saved block edit and the example
plan (no global undo). TD-081 recorded (messages slide even with reduced motion; not fixed).
The `.s2check` build was refreshed from S6.16's commit afterwards (above). Verification: the full gate
after the last code change, PASS (below); every acceptance criterion checked.

**Owner decisions, 2026-09-28 (in the session prompt):** the corrective pass above, the planner's
order (ADR-019 §6 amended), the visual finish of Tonight and the planner in Stage 6 (Stage 9 keeps the
secondary screens), TD-079 as bounded recovery, TD-080's wording, and the five-second test's rule
(an independent participant, or UNVERIFIED and recorded by the validation; never the owner's review
or an agent). DECISIONS E.1, "Stage 6 corrective pass decided".

**Owner manual UX review, 2026-09-28** (HUMAN / OWNER MANUAL UX REVIEW, **not** a five-second
result; `evidence/STAGE_6_FIVE_SECOND_TEST.md`): 22 observations on the `.s2check` app, each
classified against this plan. No regression. **Current-stage issues** (small, Stage 6's own):
TD-075 (the status's reason vs a missing-input headline), TD-076 (the stacking-gain graph does not
label the planned point), TD-077 ("Your plan" heading in the button text role), TD-078 (Night &
Moon repeats its summary). **New bounded follow-ups:** TD-079 (no way back from Fill/Trim, a saved
block edit, the example plan), TD-080 (Tonight's two target actions look alike). **Owner
decisions raised:** the planner's order (would amend ADR-019 §6); who owns the visual finish of
Tonight and the planner. **Owned later, as planned:** Stage 7 (binning, ISO/gain, calibration
frames: RG-10, RG-11; elevation, Bortle, SQM: RG-08, RG-09), Stage 8 (results and the export action:
P8.1, P8.2, P8.7), Stage 9 (detail screens' presentation, typography consistency, Tonight's rows,
Settings: P9.3). **The five-second test stays UNVERIFIED.** Verification: documentation class.

**S6.E device first set up, 2026-09-28** (superseded by the refresh above): a `.s2check` build of
`f19aef7`'s code, used by the owner's review. Found while setting up: TD-075 (since resolved by
S6.16).

**S6.E step 1 done, 2026-09-28** (S4V-02 corrected; documentation only):
`research/S4.R1_FLOW_INVENTORY.md` §7's device rules now say that no test only looks (the plan
autosaves; Save plan and Track live store records), how to run Test A on the owner's app without
losing anything (Save plan, then ⋮ → New plan), and that Tests B and C belong on `.s2check`; Tests A–C
follow the current app (an empty new plan, Save plan and Track live in the planner, the timeline).
`evidence/STAGE_6_FIVE_SECOND_TEST.md` is prepared for the answers, not yet run. Verification: the
documentation class (references resolve; `git diff --check`).

**S6.14 done, 2026-09-28** (RD-10 = O1; UX-29): "What can I image tonight?" orders by usable time,
then frame fill (unknown last), then the name; the header names the order. Verification: the
Task's class, localized (targeted and candidates-screen tests, analyze, format, encoding), PASS;
every acceptance criterion checked.

**RD-10 and RD-11 decided, 2026-09-28 (the owner, in chat):** O1 (candidates by usable time, then
frame fill, then the name; the header names the order) and S9 (the Moon and cloud gate controls in
Stage 9's Settings, with RG-13; TD-050 stays open; S6.15 is not built). DECISIONS E.1, "RD-10 and
RD-11 decided".

**S6.13 done, 2026-09-28** (P6.6; UX-10, UX-11, UX-13, UX-17, UX-24; TD-054 resolved; TD-073's site
prompt decided; DEV-P9 resolved): Tonight leads with site ▾ · night ▾ (the night picker changes the
plan's night), the run card, Your plan with the planner's verdict, then the Night, Moon and Weather
rows and the secondary actions; no Start; the Dark row at the user's limit; the Moon row says what
the Moon does while it is dark (CALC-43). No compact timeline (recorded why). Verification: the full
gate after the last code change, PASS (below); every acceptance criterion checked.

**S6.12 done, 2026-09-28** (P6.11; UX-08): the altitude chart is evolved into the night and
opportunity timeline over one mapping: seamless bands with drawn edges (field mode), the windows,
the fit's end, whole-hour times in the device's 12/24-hour format, labels outside the plot at any
text size, a fuller text alternative, and a compact density for Tonight to consider. The inventory
is in ARCHITECTURE B4. Verification: the full gate after the last code change, PASS (below); every
acceptance criterion checked.

**S6.11 done, 2026-09-28** (P6.10; CALC-42): each light group has a compact graph of its relative
stacking gain from one frame to twice the planned count, the planned count marked; the figure and
the label stay (SI-003); a text alternative gives each group's value; the points come from the
domain. Verification: the full gate after the last code change, PASS (below); every acceptance
criterion checked.

**S6.10 done, 2026-09-28** (P6.9; 08 §17): Budget details' summary says "Time needed · Total time";
each row says what of it fits tonight, only from the fit's own outputs (TD-074 records what the fit
cannot answer); storage says what it rests on, or why it is unknown and how to supply it (the trace
re-verified: an unknown input, no defect); the status and the budget summary are briefly
highlighted when an edit changes them. No budget visual. Verification: the full gate after the last
code change, PASS (below); every acceptance criterion checked.

**S6.9 done, 2026-09-28** (P6.8; UX-09, UX-15 (1); 08 §14; RD-09; RD-08 = T3): each capture block's
row says what will be captured ("Ha · 60 s × 100 · 1 h 40 min"); one heading; Delete with Undo
that restores the identical block; a known tracking's exceedance keeps its warning and names the
tracking, while unknown tracking is a neutral missing input with a way to set it; Save is the
dialog's primary button; a changed row is briefly highlighted. The tracking used is the rig's
default until Stage 7 adds the plan's override. Verification: the full gate after the last code
change, PASS (below); every acceptance criterion checked.

**RD-08 decided, 2026-09-28 (the owner, in chat): T3.** Tracking is the rig's default with a
per-plan override; the plan changes the effective value without changing the rig; the snapshot keeps
the effective value; Unknown stays possible; the example rig's Unknown is never made a fact
(DECISIONS E.1, "RD-08 decided"; pointer under ADR-011 §5). Checked against the model first: the
rig's default and the snapshot's `tracking` exist; only the plan's override needs a new nullable
field, which Stage 7 builds with the planner's control. It unblocks S6.9, which shows the effective
tracking and moves nothing.

**S6.8 done, 2026-09-28** (P6.2, P6.1's New plan; RD-04; UX-24): nothing the user did not choose
looks chosen. A fresh install has no target, no rig and an empty capture plan with "Start from the
example plan"; New plan keeps the site and rig and asks for a target; a stored choice is still
restored; the shipped rig is labelled as an example where it is listed and chosen; the welcome page
marks nothing as done that the user did not do. Tests that relied on the old defaults choose their
plan explicitly (`PlannerHarness.choosePlan()`); the E2E chooses through the new path. **For the
owner:** "Example rig" is new wording beside RD-04's "Start from the example plan"; both are kept
out of `AppWords` (`DESIGN_SYSTEM.md` §7). Verification: the full gate after the last code change,
PASS (below); every acceptance criterion checked.

**S6.7 done, 2026-09-28** (P6.4; UX-05; ADR-019 §7): technical depth is one tap away behind
factual summaries, each section's state remembered: Budget details, the √N explanation,
Assumptions, the rig's Specifications and Sky darkness. The status, storage, the √N values, the
weather row, the capability warnings and every unknown stay visible; the status now shows the
integration in every state; the Conditions section names its zone once. The widened sweep (every
section open) found the Bortle badge failing tap-target and contrast checks, fixed here (a colour
swatch beside readable text, 48 dp). Verification: the full gate after the last code change, PASS
(below); every acceptance criterion checked.

**S6.6 done, 2026-09-28** (P6.3; UX-01 to UX-03, UX-07, UX-15 (3)): the planner answers first:
the status (verdict with time needed and usable time, reason, capture end, integration, fill or
trim), the context line (site ▾ · night ▾), then the target, the capture plan, the conditions and
the rig. No empty state: a missing site, target or rig is a neutral status with a way to choose.
**For the owner:** "Needs a site" and "Needs a rig" follow the glossary's "Needs a …" pattern but
are kept out of `AppWords` until you confirm them (`DESIGN_SYSTEM.md` §7). Verification: the full
gate after the last code change, PASS (below); every acceptance criterion checked.

**S6.5 done, 2026-09-28** (P6.5; UX-06, UX-10; TD-051 resolved; CALC-41): two detail screens above
the tabs, Night & Moon (`/night`: the dark span at the user's limit, the twilight names, the Moon,
the zone once) and Weather (`/weather`: the whole forecast, nothing lost), both on `DetailScaffold`
and in the sweep. The planner shows one factual row for each and keeps sky darkness; Tonight's
rows open the details. `tonightCandidates()` moved into `CandidatesViewModel` to keep
`NightConditionsViewModel` under the cap. Verification: the full gate after the last code change,
PASS (below); every acceptance criterion checked.

**S6.3 done, 2026-09-28** (P6.1's second half; U1, W1, V3, UX-12; S4-DEF-04 = R): leaving a plan
with unsaved changes asks Save · Discard · Cancel at New plan, Copy, Tonight's New and Open. Discard
deletes a never-saved plan and reverts a Saved · changed one to its snapshot (unchanged; nothing
deleted; refused with a message when the snapshot cannot be restored). An untouched never-saved draft
is deleted when replaced; a copy counts as unsaved; a site change on a saved plan is an edit. The
S1.6 guard is gone. Tests: 48 new or mapped (reader, repository, `CurrentSession`, the UI matrix);
four S6.2 tests changed deliberately (see the plan). Verification: the full gate after the last
code change, PASS (below); every acceptance criterion checked.

**S4-DEF-04 decided, 2026-09-28 (the owner, in chat): R.** Discard on a Saved · changed plan reverts it
to its saved snapshot; the snapshot is unchanged and nothing is deleted (DECISIONS E.1). It unblocks
S6.3.

**S6.4 done, 2026-09-28** (P6.7; TD-057 resolved): at the rollover (`NightClock` →
`PlanLifecycleViewModel.followNight`, every minute and on resume, before the forecast check) and at a
restart, a never-saved draft's night key is written through the autosave chain, not as an edit. A
picked night still ahead is kept; one no longer ahead rolls forward when tonight moves on, and a
past night picked meanwhile is not moved before then. A saved plan's row is never written (D1). The
planner notifies at a new night for any plan (S6.2's identity strip follows it), and the candidates
list re-evaluates. `night_rollover_test.dart` (8 tests). One existing test's steps are reordered
because it relied on the unwritten key (see the plan). Verification: the full gate after the last
code change, PASS (below); every acceptance criterion checked.

**S6.2 done, 2026-09-27** (P6.1's first half; TD-058 resolved; DEV-P9's first half): the planner is
titled "Plan", with a strip under its app bar showing the target, the night and the plan's state
(it wraps at 200 % text). ⋮ holds New plan, Copy to another night (`pickNight`) and, for a saved
plan, Track live (optional), which replaces the bottom bar's Start (interim until P8.4). Save plan
is the one primary button. Save, New plan, Copy and Open each say what happened (`showDone`).
`CurrentSession.startNew`/`adopt` run in the autosave chain; the new tests
(`current_session_chain_test.dart`, `plan_identity_actions_test.dart`) fail without the fix. Tests
and the E2E follow the renamed labels; two race tests make their edit through the ViewModel
because the closing menu covers the row (assertions unchanged). Tonight's Start and the S1.6 guard
stay until S6.13 and S6.3. Verification: the full gate after the last code change, PASS (below);
every acceptance criterion checked.

**S6.1 done, 2026-09-27** (P6.0; ENG-16 resolved): `SessionPlanViewModel` is split, with no behaviour
change. It keeps the plan's contents, edits, autosave and read-only state (220 lines). The new
`PlanLifecycleViewModel` restores, opens, starts new plans, copies, saves and starts runs (167
lines; a plain `Provider`, not a notifier). `AppViewModels` builds one `CurrentSession` for both.
Callers moved mechanically: `StartupViewModel`, `CaptureAnalysisViewModel` (Save and Start), four
screens and `PlannerHarness`. No test assertion changed. `CLAUDE.md` trap 11 and ARCHITECTURE B1/B4
updated. Verification: the full gate after the last code change, PASS (below); every acceptance
criterion checked.

**Stage 6 planned, 2026-09-27** (documentation only; the plan's "Stage 6 — frozen Task sequence"):
- **On the amended plan:** the owner started Stage 6 planning on the Stages 6–11 amendment
  (`783a723`), which closes the "owner reviews the amendment" step.
- **Verified against the code (§9.7):** the inputs of P6.0–P6.11, with their finding IDs. Notable:
  - `SessionPlanViewModel` is at 300 physical lines, exactly at the cap (ENG-16's "299" is stale);
  - the storage trace (P6.9) finds case (C), an unknown input: the seeded rig has no RAW size, and
    "Unknown" gives no reason. No calculation or wiring defect;
  - UX-08's 24-hour labels and labels over the curves, TD-051, TD-054, TD-057 and TD-058 are
    confirmed as recorded;
  - the core-loop E2E's first plan depends on the M42 default (S6.8 updates it).
- **Frozen:** S6.1–S6.14; S6.15 only if RD-11 chooses Stage 6; S6.E, the owner-run five-second
  test, with S4V-02's correction as its first step. P6.1 is split into S6.2 (the app bar, ⋮,
  feedback, TD-058) and S6.3 (Save · Discard · Cancel). No P-Task was dropped; the mapping is in the
  plan and in `DESIGN_SYSTEM.md` §9.
- **Gates, with options prepared (nothing decided):**
  - S4-DEF-04, Discard on Saved · changed: **R** revert to the saved plan (recommended) / K keep the
    changes with the entry. Blocks S6.3;
  - RD-08, tracking: T1 per rig / T2 per plan / **T3** the rig's default with a per-plan override
    (recommended). Blocks S6.9;
  - RD-10, the candidates' order: **O1** usable time, then frame fill (recommended) / O2 then the
    maximum altitude / O3 groups. Blocks S6.14;
  - RD-11, the gate controls: **S9** Settings in Stage 9 (recommended) / S6 now, as S6.15 / P the
    planner.
- **Allocated, not decided:** S4-DEF-01 (Save on Saved · changed) goes to Stage 8's planning, and
  Stage 6 keeps today's Save. The owner may move it back.
- **Verification:** the documentation class (V1): references and IDs resolve; `git diff --check`.
  No gate input changed, so Stage 5's closing gate is reused as Stage 6's baseline (below).
- The earlier entries (Stage 5, the governance correction, the Stages 6–11 amendment) moved verbatim
  to `PROGRESS_HISTORY.md`.

**Before this:** Stage 5 closed on 2026-09-27 at `178acbe` ([report](STAGE_5_VALIDATION.md)); its
adoption plan is `DESIGN_SYSTEM.md` §9. The Stages 6–11 amendment is DECISIONS E.1, "Stages 6–11
amended after Stage 5" (`783a723`). The Verification Policy is `CLAUDE.md`'s (V1–V8).

*Moved verbatim from `PROGRESS.md` on 2026-09-27 at Stage 6 planning: Stage 5's entries, the
governance correction and the Stages 6–11 amendment. Some of their facts (the owner's debug build,
the CI filter cleanup) are recorded nowhere else. The Stage 4 entries follow them.*

**Stages 6–11 amended after Stage 5, 2026-09-27** (planning and documentation only; the owner's
brief `prompts/AMEND_STAGES_6_11_AFTER_STAGE5.md`):
- **Amended, not replaced,** from the manual dogfooding (08) and the owner's post-Stage-5 UI/UX
  analysis:
  - new "Stages 6–11: shared rules" in the plan: one owner per responsibility, the answer-first
    hierarchy with a "never hidden" list, disclosure, visualisation, look, words, exclusions;
  - **Stage 6** gains P6.8 (the capture plan's blocks), P6.9 (outputs, "what fits", storage
    verified first), P6.10 (the √N graph) and P6.11 (the night and opportunity timeline). P6.1 and
    P6.3–P6.6 are clarified;
  - **Stage 7:** its areas and RG-07 to RG-11 gain their required outputs (the automation order;
    the calibration and capture-parameter matrices);
  - **Stage 8:** P8.4 becomes the tracker's safe retirement, P8.5 is split into the list and P8.7
    (the entry), and P8.6 (optional names) is kept;
  - **Stage 9** gains P9.3 (Settings), P9.4 (logo and splash) and P9.5 (licence);
  - **Stages 10 and 11** are clarified: measure first; one bounded final validation.
- **Superseded (the owner):** the dedicated tracker leaves the target product (DECISIONS E.1,
  "Stages 6–11 amended after Stage 5"; ADR-019 §2 and §4; RG-04's optional tracker;
  `PRODUCT_DIRECTION.md` §3–§4). Stage 8 retires it after a dependency audit, and nothing is
  deleted before that. RD-12 lapses; RD-13 narrows.
- **Clarified:** `PRODUCT_DIRECTION.md` §5.2 (what disclosure never hides).
- Stage 5 stays closed. No application code, test, tool or frozen Task changed. Verification: the
  documentation class (V1).

**Governance correction, 2026-09-27 (documentation, prompts and CI filter; the owner's request).**
- `CLAUDE.md` now holds the one canonical **Verification Policy** (V1–V8): verification by change
  class, broader-satisfies-narrower, evidence reuse, the frozen review surface and what may block,
  correction-scoped revalidation, PASS reopening, stop/convergence (two interpretation failures go
  to the owner), and what a fresh session reads.
- `.agents/rules/03-testing.md`, `CLAUDE.md` rules 13/16/17 and "Testing", and plan §9.1, §9.4 and
  §9.8 now refer to it instead of restating it. New prompts: `prompts/INDEPENDENT_STAGE_VALIDATION.md`
  and `prompts/CONTINUE_CURRENT_WORK.md` (neither existed before).
- CI skips the gate when only documentation changed (same paths as V1's documentation class).
- This file keeps only the handoff; the earlier entries are in `PROGRESS_HISTORY.md`, unchanged.
- No application code, test, tool, dependency, Stage scope or product decision changed.
- **Cleanup, 2026-09-27:** the M1/M2 device-check commit is `79f392c` (was misrecorded as
  `360fd8f`); the CI filter excludes only `docs/**.md` and `docs/**.patch` (not all of `docs/`), so
  any unknown file runs the gate; V1 now says a shared-behaviour Task ends with its affected
  regression checks and escalates to the full gate only when that set cannot be bounded or its
  Task/Stage gate requires it (high-risk Tasks still always end with the full gate). Verified by a
  YAML parse and a 22-case path simulation; the app gate was not rerun (no gate input changed).

**Stage 5** (plan: "Stage 5 — frozen Task sequence"; planned at `a354032`):
- **RD-09 decided** 2026-09-27 by the owner: M + S1 (`9640915`; DECISIONS E.1, "RD-09 decided").
- **S5.1 done** 2026-09-27 (`49344c9`): the text roles (`AppPalette.textPrimary`/`Secondary`/
  `Tertiary`/`Disabled`), the raised surface and border tokens, `AppTypography.scale`, `AppRadius`,
  the documented `AppSpacing`; the colour scheme follows the roles; the gallery test
  (`test/presentation/design_system/`); `docs/DESIGN_SYSTEM.md`; ARCHITECTURE B17. The first gate
  run caught a light-theme regression (black on the darker secondary in a selected segment,
  2.99:1), fixed with an explicit selected container and a guarding test. Verification: shared
  behaviour (the theme reaches every screen) and the Task's "gate green": the full gate after the
  last code change, PASS (below). Every acceptance criterion checked.
- **S5.2 done** 2026-09-27 (`6363727`): component themes for the controls (`AppTheme._withControls`):
  - one button hierarchy (primary filled, secondary outlined, tertiary text, destructive via
    `AppButtonStyles`, flat elevated = secondary), 48 dp, a 16 % pressed overlay;
  - a quiet field underline: `colorScheme.outline` = `AppPalette.controlBorder` (3:1). Material
    had drawn it black or white (08 §6); in field mode it is `#880000` (UX-39);
  - text-role labels and hints; dialogs, sheets, menus and light/dark messages themed; dark
    error `#F28B82` (AA on the raised surface);
  - `AppMotion` (reduced motion honoured); an icon set;
  - `FitText`'s neutral moved to `textSecondary`, since `outline` is no longer AA as text.

  The gallery now holds every control in its states and opens a dialog, a message and a menu. New
  `controls_theme_test.dart`. Verification: shared behaviour and the Task's "gate green": the full
  gate after the last code change, PASS (below). Every acceptance criterion checked.
- **S5.3 done** 2026-09-27 (`0343962`): the glossary's words once, in
  `lib/presentation/shared/app_words.dart` (`AppWords`), pinned to the glossary by
  `app_words_test.dart`. `retired_terms_test.dart` scans `lib/presentation`'s string literals
  (imports, `Key` values, comments and identifiers exempt) against an explicit baseline: 16
  occurrences in 8 files at `38925dd`. A new occurrence or a stale entry fails, and its own cases
  show both. No existing string was renamed. Verification: the Task's "gate green", the full gate
  after the last code change, PASS (below). Every acceptance criterion checked.
- **S5.4 done** 2026-09-27 (`3e9a487`):
  - **status and state tokens** in `AppPalette`, in the three themes (UX-16). `FitText.color`
    reads them, with the same values as before;
  - **`StatusBlock`** (`lib/presentation/shared/status_block.dart`): the verdict headline in the
    glossary's words ("Fits: … needed of … usable"; the word alone when a duration is unknown;
    Needs a target / a block neutral), the reason, key numbers and an action slot; plain values
    in;
  - **`PlanState`** (`plan_state.dart`): the pure mapping from stored status, `plannedAtUtc` and
    legacy (every combination tested; Partly waits for Stage 8), and `PlanStateLabel`;
  - both in the gallery; no screen changed.

  Verification: the Task's "gate green", the full gate after the last code change, PASS (below).
  Every acceptance criterion checked.
- **S5.5 done** 2026-09-27 (`2e8b95f`):
  - **`CollapsibleSection`:** a 48 dp header with the title, a factual summary that stays
    visible, and a turning chevron; the content opens below it. It is one semantics button with
    its expanded state, hint and tap action;
  - **remembered per section key:** `DisclosureViewModel` (in `AppViewModels`, loaded in
    `main.dart` before the first frame) stores it through `DisplayPreferencesRepository`
    (`section.<key>`; `guardStorage`). A broken store is logged and the section still works;
  - **tested:** restart restores the state, keys are independent, a broken store is handled,
    reduced motion is honoured, and the gallery includes it;
  - **a bug found and fixed:** the reduced-motion test showed that `AnimatedSize` with a zero
    duration throws a layout assertion. The section now leaves it out under reduced motion, and
    `DESIGN_SYSTEM.md` §6.2 records the rule.

  Verification: the full gate after the last `lib` change PASSED its tests (1,292, 1 skip) and
  host E2E, but Analyze flagged one deprecated matcher in the new test. That test file was fixed,
  then re-verified per V3: `flutter analyze` on the whole project, that file's tests, format and
  encoding, all clean. No other input changed. Every acceptance criterion checked.
- **S5.6 done** 2026-09-27 (`52631f6`):
  - **`ContextLine`** (`lib/presentation/shared/context_line.dart`): site ▾ · night ▾, each a 48 dp
    labelled button reporting its tap. The zone rule is shown once: the site's zone, or the
    labelled device zone. Without a site there is no night and no rule;
  - **`pickNight`:** the shared, themed date picker, returning a `CalendarDate` (null when
    cancelled). Its pixel test shows it red or black in field mode by its theme alone, without the
    app filter, plus a sanity run in light;
  - in the gallery; no screen changed.

  Verification: the Task's "gate green", the full gate after the last code change, PASS (below).
  Every acceptance criterion checked.
- **S5.7 done** 2026-09-27 (`c9f2deb`): `DetailScaffold` (`lib/presentation/shared/detail_scaffold.dart`):
  - a header with the title (a semantic header), its context and the zone rule exactly once, all
    wrapping at 200 % text. The title is in the page header because an app bar's cannot wrap; the
    app bar keeps back and the actions;
  - a summary card, then the sections separated by dividers;
  - the gallery sweeps a sample Night & Moon page on it (`pumpGalleryPage`), and a template test
    checks the order, the single zone rule and the wrapping.

  Verification: the Task's "gate green", the full gate after the last code change, PASS (below).
  Every acceptance criterion checked.
- **S5.8 done** 2026-09-27 (`99e60af`), per RD-09 = M + S1:
  - **confirmations** (`confirmation_patterns.dart`): `askUnsavedChanges` (Cancel · Discard ·
    Save; dismiss = Cancel) and `confirmDestructive` (true only on its verb);
  - **success** (`failure_feedback.dart`): `showDone`, beside `runWithFeedback`;
  - **deleting** (`delete_patterns.dart`): `showUndo` (exactly one outcome, undone or committed),
    `DeleteButton` (the visible Delete, S1), and `SwipeToDelete` (a swipe calls the same handler
    and the row springs back, 08 §20);
  - **tested:** every way out of each prompt; the undo outcomes on Undo, time-out, replacement
    and removal; the swipe; red or black in field mode without the app filter; all in the gallery;
  - **found:** Flutter keeps a message with an action on screen unless `persist: false`, so Undo
    would never have committed. `showUndo` sets it (tested), and two existing messages with
    actions are recorded as **TD-073** (not fixed);
  - no screen changed.

  Verification: the Task's "gate green", the full gate after the last code change, PASS (below).
  Every acceptance criterion checked.
- **S5.9 done** 2026-09-27 (`8a6c5d8`):
  - **the adoption plan:** `docs/DESIGN_SYSTEM.md` §9 maps each screen to the parts it adopts and
    the P-Task (P6.1–P6.6, the Stage 6 capture-plan work, P8.2, P8.4, P8.5, P9.1, P9.2, Stage 9
    Settings). Every Stage 5 part has at least one adopter, and every retired-terms baseline entry
    has its Stage (§9.3). The provisional Stage 6, 8 and 9 tables gain adoption notes, still not
    frozen;
  - **the rendered evidence:** 15 host-rendered images in `docs/refinement/evidence/stage5/`: the
    gallery in light, dark and field at 100 % and 200 %, plus the sample detail page, a
    confirmation and an undo message in each theme. Real fonts; field mode through the app's
    filter. See `evidence/STAGE_5_RENDERS.md`. They come from the opt-in
    `render_gallery_test.dart` (`ASTROPLAN_RENDER_GALLERY`; skipped in the gate), and the
    gallery's content now lives in `gallery_entries.dart`, shared by both tests;
  - **a render bug fixed before committing:** the first run kept a dialog open into the next
    image; each image now starts from an empty tree.

  Verification: test-only changes, and the Task's "gate green": the full gate after the last code
  change, PASS (below). Every acceptance criterion checked. The optional owner review of the
  images is non-blocking.
- **Stage 5 validation, 2026-09-27: FAIL at `8a6c5d8`, one narrow blocker**
  ([report](STAGE_5_VALIDATION.md); run in this chat at the owner's request, so **not independent**,
  disclosed).
  - Every frozen item passes except **S5V-01**: S5.5's "a test rebuilds the graph on the same
    store" has no committed graph-level test. The behaviour is correct (a probe through
    `PlannerHarness` passes).
  - Not blocking: TD-073 (predates Stage 5); UX-39's card borders in field mode (S5.2's documented
    choice); `CLAUDE.md`'s stale test count (outside Stage 5).
  - **The owner's question, answered in the report's §6.** The debug build looks unchanged
    because the new components are on no screen yet (by design; Stage 6 adopts them), and the
    theme changes are subtle: 1–10 % of pixels per screen in before/after renders
    (`evidence/stage5_before_after/`). Where to look is listed there. If even those are missing,
    the installed build predates `49344c9`.
- **S5.V1 done** 2026-09-27 (`178acbe`), S5V-01: `disclosure_viewmodel_test.dart` gains "a restart
  of the whole ViewModel graph on the same store keeps a section open". It builds two
  `PlannerHarness` graphs on one display store, the second loading as `main.dart` does. Test-only.
  Verification: the full gate after the change, PASS (below).
- **Revalidation of S5V-01 (V5), 2026-09-27: PASS** at `178acbe`. The test exists, goes through
  `AppViewModels`, and passes. The gate is reused (V3). **Stage 5 is closed**
  ([report §7](STAGE_5_VALIDATION.md)).
- **The owner's debug build, checked 2026-09-27 (read-only):**
  - the phone runs exactly the current build (installed-APK SHA-1 `8debc76c…` equals the local
    `app-debug.apk`, built after `178acbe`);
  - the build contains Stages 1, 3 and 5 (markers found in its Dart kernel);
  - the phone reports the app was first installed at 19:11 today, so earlier on-device data is not
    on it unless restored.

  Little looks different because Stages 1–5 changed little of the main screens' look. Stage 6
  does that.

---

**Final, bounded Stage 4 validation, 2026-09-27: PASS** at `09a7f06`
([report](STAGE_4_FINAL_VALIDATION.md)). **Stage 4 is closed.**
- **All seven frozen questions pass:**
  - research done;
  - every gate owner-decided;
  - ADR-019 faithful to each decision;
  - the addendum consistent;
  - S4.T maps §2–§10 to Stages 5–9;
  - no direct contradiction in the core flows;
  - no acceptance criterion unmet.
- **Not blocking:**
  - S4-DEF-01 to S4-DEF-08 (deferred to Stages 6 and 8);
  - S4V-02 (correct the S4.E script before Test A or C);
  - S4V-03 (unrun owner tests);
  - one observation: §10's list of retired terms is an excerpt of the normative glossary.
- **Independence, disclosed:** the owner asked for this validation in the session that wrote S4.V2
  and S4.V3; it was not a fresh session.
- **The code is unchanged** since `92ebf2a`, and the gate at `5ad69c4` (1,214 tests, 1 skip, 2
  host E2E) applies.

**S4.V3 complete, 2026-09-27 (documentation and governance only; the owner's instruction).**
- **The loop it stops:** each documentation validation derived more lifecycle policy, then
  validated it. The owner stopped that. S4.V2's five inferred rules (re-save, Discard on a saved
  entry, the working copy's night, "ended" as the SessionNight end, the live mode) are **not owner
  decisions**.
- **ADR-019 §3.1 now states only E2, R2 (with the owner's invariant) and D1.** The same reduction
  was applied to the ADR-014 pointer, §3's Discard line, D5, addendum §3.10, S4.R3 §13, TD-057,
  P6.1, P6.7 and P8.1–P8.3.
- **The open implementation cases** are S4-DEF-01 to S4-DEF-08, `DEFERRED / IMPLEMENTATION
  DECISION`, for Stage 6 or 8 (plan, S4.V3). They are not Stage 4 blockers.
- **The final Stage 4 validation is bounded to seven questions.** Only a direct contradiction with
  an approved decision or a Stage 4 acceptance criterion blocks. A pass closes Stage 4 and makes
  Stage 5 next.
- **The rule for future Stages:** the bounded-validation rule for analysis-and-decision Stages is
  in `CLAUDE.md` ("Validation Rules"), plan §9.8 and E.1.
- No application code or test changed.

**S4.V2 complete, 2026-09-27 (documentation only; the owner decided R2 + D1).**
- **The owner's invariant:** the plan snapshot is the immutable intent for its night; the result is
  the reported outcome for that snapshot; the working copy is independent. Recorded in E.1, "S4R-01
  and S4R-02 decided", and in ADR-019 §3.1 as revised.
- **S4R-01:**
  - the result flow is saved plan → Review saved plan (the snapshot) → report outcome → Save result;
  - there is no Save plan, and Not done is direct;
  - actuals go in the result record, never the snapshot;
  - no result before the saved night ends;
  - no guard about the working copy.
- **S4R-02:**
  - Stage 6 changes only never-saved drafts and working plans (P6.1, P6.7), and saved plans behave
    as today;
  - Stage 8 (P8.3) delivers the saved night and the independent working copy together.
- **S4R-03:** TD-057 is limited to never-saved drafts.
- **S4R-04:** ADR-019's status line records the S4.V1/S4.V2 amendments and their validation reports.
- **Derived rules**, listed in E.1 for the revalidation (the owner may override them):
  - "Save again" only for the same night before it ends; from Stage 8, a Save for another night or
    site creates a new plan;
  - Discard never deletes a saved entry;
  - the working copy keeps a working night that has not ended;
  - "ended" is the SessionNight end (the next mean solar noon);
  - the live Finish is unchanged.
- **Aligned:** the ADR-014 pointer, D5, addendum §3.7/§3.10, `PRODUCT_DIRECTION.md` §10, S4.R3 §13,
  RG-04 §14, and the plan's S4.V2 section and matrix (superseding S4.V1's), with P6.1, P6.7,
  P8.1–P8.3 and "Order across Stages".
- No application code or test changed; the gate result at `5ad69c4` still applies.
- S4V-02 (script setup, Tests A and C) is still open and non-blocking.

**Fresh-session Stage 4 revalidation, 2026-09-27: FAIL** at `5ad69c4`
([report](STAGE_4_REVALIDATION.md)). Validation only: no fix was made.
- **S4V-01 is resolved as reported.** Saved · changed is classified by save history and protected
  at startup and at a live rollover. The saved night comes from the snapshot (verified: it stores
  the night's bounds, zone and blocks). The documents agree on this protection.
- **S4R-01 (blocking):** §3.1's result path for Saved · changed is Review → Save → result, and the
  result "refers to the newly saved version". A Save snapshots the **working** night and site. So
  when a saved plan is moved to another night before its night ends (Save for N, move to N+1), the
  result is recorded against N+1, which has not happened. N gets no result, which contradicts E2's
  "stays on its night, awaiting its result". Also:
  - Review passes through U1's guard on tonight's continuation;
  - Not done waits for a Save.
- **S4R-02 (blocking):** the delivery boundary (P6.7 in Stage 6, with the continuation only in
  P8.3) makes Stages 6–7 resume last night's saved plan as current on its past night, or start a
  fresh plan (Y3, rejected). Either contradicts E2 and E.1's "Stage 8 implements E2's resume rule",
  and the interim is not stated anywhere.
- **Low:**
  - S4R-03: TD-057's direction ("write the plan at the rollover") ignores §3.1;
  - S4R-04: §3.1 was added after the owner accepted ADR-019, and the status line does not say so.
- **Neither blocking choice has a recorded owner approval;** E.1 records only the request to fix
  S4V-01. The owner's options: R1/R2/R3 for S4R-01, D1/D2/D3 for S4R-02 (the report's §"Proposed
  follow-up").
- **Carried:**
  - S4V-02 is still open. It now also covers Test A, whose step 1 changes the owner's current plan;
  - S4V-03 is unverified.
- **Gate re-run at `5ad69c4`: PASS** (Encoding; Format, 376 files, 0 changed; Analyze; 1,214
  tests, 1 expected skip; 2 host E2E). The code is unchanged since `92ebf2a`.

**S4.V1 complete, 2026-09-27 (documentation only; owner requested the fix).**
- **S4V-01 corrected, pending independent revalidation:** ADR-019 §3.1 protects both `planned`
  and `draft` + `plannedAtUtc` (Saved · changed) at startup and live rollover. It preserves
  saved context and working edits, defines the unsaved continuation, and distinguishes
  explicit historical review from automatic resume.
- Results for an edited saved entry require review and explicit Save, or Cancel. The result
  uses the explicitly saved version; a stale form must not mix working and snapshot values.
- Research, ADR-014's amendment pointer, D5, addendum and P6.7/P8.1–P8.3 are aligned.
  The plan's S4.V1 section carries a ten-case future acceptance matrix. P6.7 protects saved
  entries in place before Stage 8 adds continuations and the new result form.
- The validation **FAIL at `adb5d95`** remains historical (`STAGE_4_VALIDATION.md`); this
  correction is not an independent Stage PASS.
- **S4V-02, non-blocking:** the optional darkness script calls Test C read-only even though it
  starts and abandons a run. Correct the setup before running it.
- **S4V-03, unverified/non-blocking:** owner usability/darkness tests remain unrun, as permitted.
- No application code changed. Stage 5 stays blocked until Stage 4 passes.

**Historical completion record before validation:**
**S4.T done, 2026-09-27: every Stage 4 Task is done; Stage 4 is in validation.**
- **Provisional Tasks from ADR-019,** not frozen, were added to the Stage sections of
  `POST_ROADMAP_PLAN.md`:
  - **Stage 5**, P5.1–P5.6: the shared vocabulary with a retired-terms test; the collapsible
    section; the context line; the status block and state label; the detail-screen template; the
    confirmation and feedback patterns;
  - **Stage 6**, P6.0–P6.7: splitting `SessionPlanViewModel`; the lifecycle UI with Track live in
    ⋮; the defaults and first run; the planner's structure; disclosure; the detail screens; Tonight
    plan-first; TD-057. Also a five-second test as acceptance evidence;
  - **Stage 7:** none from ADR-019; RD-08 still comes before Stage 6's capture-plan work;
  - **Stage 8**, P8.1–P8.6: results without a run; the result form; the next-day rule and Tonight's
    line; the live mode as an option; the Logbook with Progress; an optional name;
  - **Stage 9**, P9.1–P9.2: the Library manages; the vocabulary completed.
- **The order across Stages:** keep a path to results at every step (Stage 6 moves Start into ⋮;
  it never removes it before Stage 8's result form). Progress leaves the Library only after it is in
  the Logbook.
- **§6.2's rows** for UX-01 to UX-14, UX-24, UX-25 and UX-26 point to ADR-019 and the P-Tasks.
  UX-27 is unchanged (Appendix C).
- Each Stage's own planning re-verifies, freezes and renumbers its Tasks (P-IDs are never reused).
- No code changed.

**S4.D done, 2026-09-27: ADR-019 accepted** (the owner, in chat).
- **ADR-019, "Product flow and information architecture"** (DECISIONS Part F), records the eight
  Stage 4 decisions as one design.
- **It amends:**
  - ADR-009 §2 (display only: the budget lines within Budget details);
  - ADR-014 §3 (results without a run; yesterday's saved plan is not resumed);
  - ADR-015 §2, the route map and §7 (the answer-first planner; the Night & Moon and Weather
    details; the Library manages);
  - ADR-016 (execution optional; post-session counts as events).

  Each amended ADR carries an "Amended by ADR-019" pointer.
- **`docs/IA_WIREFRAMES_ADDENDUM.md`:** low-fidelity Tonight, the planner, the unsaved-changes
  prompt, the Night & Moon and Weather details, the Logbook, the result form, the Library and the
  first run. `IA_WIREFRAMES.md` is unchanged.
- **DEV-P9** (DECISIONS Part B) records UX-04 and UX-11 until Stage 6 builds them.
- **ARCHITECTURE D5** points to the direction.
- **S4.R1 §9** answers every matrix question: Q1–Q22 and the UX findings. Q8, Q14, Q15 and Q21 go
  to other Stages per the plan.
- No code changed.

**RD-07 and RD-14 decided, 2026-09-27 (S4.R5 done). Every Stage 4 gate is now decided.** Research:
[`research/S4.R5_LIBRARY_AND_VOCABULARY.md`](research/S4.R5_LIBRARY_AND_VOCABULARY.md)
(`160ee37`). The owner chose the recommended option on each question (DECISIONS E.1, "RD-07 and
RD-14 decided"):
- **H1:**
  - the Library manages rigs, targets and sites, and a tap never changes the plan (TD-053, when
    built);
  - choosing happens in the planner, Tonight's context line and the first run;
  - "Plan this target";
  - Progress moves to the Logbook.
- **H2:** Rig.
- **H3:** Plan + Logbook.
- **H4:** the glossary as proposed:
  - the states and results;
  - "Dark" with its limit;
  - the budget: Integration · Imaging time · Time needed · Total time;
  - the verdict headline;
  - "Export as file";
  - "Name (optional)".
- Next: S4.D records all of it in ADR-019, with a wireframe addendum. No code changed.

**RG-05, RD-06 and RG-06 decided, 2026-09-27 (S4.R4 done).** Research:
[`research/RG-05_06_TONIGHT_AND_PLANNER.md`](research/RG-05_06_TONIGHT_AND_PLANNER.md)
(`8578ab8`). The owner chose the recommended option on each question (DECISIONS E.1, "RG-05, RD-06
and RG-06 decided"):
- **F1 = T1:** Tonight plan-first, under a site ▾ · night ▾ context line. The night picker (UX-11)
  changes the current plan's night.
- **F2 = D-b:** Night & Moon and Weather detail screens, from Tonight and the planner; no new tab.
- **F3 = P-1:** the planner answers first (the verdict, reason and key numbers), then follows the
  decision order: context → target and windows → capture plan → conditions summary → rig summary.
  This amends ADR-015 §2.
- **F4 = M0:** the budget breakdown, √N help, assumptions, every weather variable and the rig's rows
  one tap away, behind factual summaries; ADR-009 §2's "own line" within the budget details; no
  modes.
- **Evidence gap:** S4.E not run; Stage 6's acceptance is to include a five-second test.
- ADR-019 (S4.D) records the amendments. No code changed.

**RD-05 and RD-04 decided, 2026-09-27 (S4.R3 done).** Research:
[`research/S4.R3_SESSION_LIFECYCLE.md`](research/S4.R3_SESSION_LIFECYCLE.md) (`989a61e`). Verified
conflict: yesterday's saved plan is resumed and rolled forward to tonight, which RG-04 cannot keep.
The owner chose the recommended option on each question (DECISIONS E.1, "RD-05 and RD-04
decided"):
- **E1 = L1:** Draft is internal; the plan's state reads "Not saved", "Saved" or
  "Saved · changed"; Save stays explicit, and only saved plans enter the Logbook.
- **E2 = Y2:** a saved plan whose night has passed waits for its result; the planner continues on a
  copy for tonight.
- **E3 (RD-04):** nothing preselected on the first run; New keeps the site and rig and asks for the
  target; an empty capture plan with "Start from the example plan".
- **E4 = U1:** Save · Discard · Cancel; Discard deletes; a site change and a Duplicate count as
  unsaved (W1, V3).
- **Also decided:** the planner's app bar shows the target, night and state (UX-04); feedback after
  New, Duplicate and Open; no failing Start (UX-13); TD-057 and TD-058 fixed where this is built.
- **Supersedes:** TASK 11.4's "New = tonight + the example plan", and its roll-forward for saved
  plans; the S1.6 interim.
- ADR-019 (S4.D) amends ADR-014 §3. Stage 6 and Stage 8 implement. No code changed.

**RG-04 decided, 2026-09-27 (S4.R2 done).** The owner chose the recommended option on each
question (DECISIONS E.1, "RG-04 decided"):
- **D1 = B:** the Logbook first; the tracker optional, off the primary path.
- **D2 = G2:** "Completed as planned" in one tap; "Partly" with numbers per light block; "Not done"
  with a reason. Conditions stay optional.
- **D3:** "Not done" → `abandoned`, with a reason; "Partly" → `completed`.
- **D4:** a quiet "how did it go?" line on Tonight, plus the Logbook.
- ADR-019 (S4.D) records the ADR-014 and ADR-016 amendments; Stage 8 implements. Execution stays as
  built until then.
- `PRODUCT_DIRECTION.md` §4 notes the decision.

**S4.R2 research done, 2026-09-27 (documentation only):**
[`research/RG-04_EXECUTION_ROLE.md`](research/RG-04_EXECUTION_ROLE.md), at `e5fd240`. The owner
accepted S4.R1 and answered O1–O4 (recorded in S4.R1 §6.1). The key points: no practical reason
is seen for Start → Tracker → Results; the intended flow is plan → save → image → Logbook →
record; only Completed / Not completed was proposed; detailed actuals are options, not
requirements.
- **Evidence** is kept apart: current behaviour, roadmap intent, the owner's report and the audits.
- **Capabilities today, C1–C12:** everything valued after the session (results, planned vs actual,
  Progress) depends on counts, not on the tracker.
- **Verified:** there is no result without Start (ADR-014 §3; events only for a started run), and
  no UI to mark an unstarted plan "not done".
- **Options:**
  - what is recorded after a session: G1 outcome only; G2 outcome, with numbers only when needed;
    G3 full results;
  - Execution's role: A as built; B Logbook first, tracker optional; C Logbook only (hidden or
    removed); D simplified tracker.
- **Recommended:** B with G2. C (hidden) is the strong alternative if simplicity outweighs keeping
  the live mode.
- **Owner decisions pending:**
  - D1: the role;
  - D2: how much is recorded;
  - D3: "Not done" maps to abandoned, with a reason;
  - D4: a quiet "How did it go?" line on Tonight.
- No code changed.

**S4.R1 done, 2026-09-27 (research, documentation only):**
[`research/S4.R1_FLOW_INVENTORY.md`](research/S4.R1_FLOW_INVENTORY.md), at `2a26185`.
- The routes against the wireframes: 3 deviations recorded in ADR-015 §7, 1 by ADR-018 §7 (the
  import route), and the content deviations UX-04, UX-11 and the Sessions tab's missing "+" and
  grouping.
- Every session action, with its entry points, confirmation, feedback and effect. Notable:
  - New keeps the target and rig and resets the night and blocks;
  - after Start the planner continues on a copy, and Tonight offers that copy's Start;
  - **a result can be recorded only through Start**, so a plan logged after the night gets a run
    stamped "now", an estimate of about zero, and +1 per frame. This is an RG-04 input.
- Session states on each screen (the planner shows none; pure drafts are not listed).
- Taps per core task, re-measured from the code: 16 rows, 2 new (a result after the night: 6 taps
  plus 1 per frame; a rig from a photo: about 5).
- The question matrix: 22 questions from 08 (each with a home; 7 outside Stage 4) and 18 UX
  findings (all current, UX-12 mitigated by S1.6).
- Four owner clarifications (O1–O4; not decisions), and the S4.E script with a record table.
- No code changed; the gate result at `92ebf2a` still applies. Run in the same chat as Stage 4
  planning, at the owner's request.

**Stage 4 planning, 2026-09-27 (documentation only), at `126d97f`.** Stage 4 — Product Flow &
Information Architecture — is **in progress**. Its Task sequence is frozen
(`POST_ROADMAP_PLAN.md`, "Stage 4 — frozen Task sequence"; DECISIONS E.1, "Stage 3 closed;
Stage 4 planning decisions"). The owner chose the recommended option on each question:
- **the sequence:** S4.R1 → S4.R2 (RG-04) → S4.R3 (RD-05, RD-04) → S4.R4 (RG-05, RD-06, RG-06) →
  S4.R5 (RD-07, RD-14) → S4.D (ADR-019, wireframe addendum) → S4.T (provisional Tasks for
  Stages 5, 6, 8, 9) → a fresh-session Stage 4 validation;
- **owner-run quick tests (S4.E):** optional and non-blocking; S4.R1 writes the script;
- **decisions:** after each research step.

Every Stage 4 input was re-verified against the code (§9.7); none is stale (UX-04, UX-10, UX-11,
UX-12, UX-13, UX-14/TD-053, UX-25, RD-04, RD-14). Planned in the same chat as the Stage 3
sign-off, at the owner's request, not a fresh one. No code changed, so the gate result at
`92ebf2a` still applies.

**Stage 3 final sign-off, 2026-09-27: PASS** at `92ebf2a`, in a fresh session. See
[the report](STAGE_3_FINAL_SIGNOFF.md) and [probe evidence](evidence/STAGE_3_FINAL_SIGNOFF_PROBES.md).
Stage 3 is **closed**.
- **Freshly executed, all pass:**
  - the full gate (Encoding; Format, 376 files, 0 changed; Analyze; 1,214 tests, one expected
    skip; 2 host E2E);
  - the Stage 3 targeted suites (352 tests, one expected skip);
  - the four real samples (856 / 856 / 843 / 4,051 bytes, unchanged);
  - the four native JVM tests;
  - the archived probes P1–P10, R1, F1a, F2 and both P+; F1b and F3, which pinned S3S-01 and
    S3S-02, now fail as expected;
  - 13 new probes (G1–G6 for S3.V7, H1–H7 for S3.V8 and the paths next to it).
- **Resolved and re-verified:** S3V-01 to S3V-07, S3S-01, S3S-02.
- **Non-blocking, recorded, not fixed:** S3F-01 (a portrait-entered rig's sensor size is copied
  transposed; addendum to TD-072); S3F-02 (the RAW size is still copied across pixel counts; a
  note on TD-071, no Task proposed). S3S-03 (TD-072) stays deferred.
- **Unverified:** S3V-08 (device). No device interaction; M4 stays the recorded device evidence.
- No application code, test or dependency changed.

**S3.V8 done, 2026-09-27 (S3S-02; TD-071 and SI-014 resolved; owner option (a)).**
- "New rig with the camera specs of" a saved rig no longer copies its pixel size or sensor size
  when the file's pixel count differs from that rig's (compared orientation-free).
- Those fields stay empty, and Save waits for the user's pixel size; the sensor size follows from
  it. The editor says why, giving both pixel counts.
- The match, the equal-pixel-count copy and the file's own estimate are unchanged.
- **Next:** a fresh-session Stage 3 sign-off. It checks the original Stage 3 acceptance, every
  previous blocking finding (S3V-01 to S3V-06, S3S-01, S3S-02), and regressions around the
  corrected areas.

**S3.V7 done, 2026-09-27 (S3S-01, TD-070 partly resolved).** The owner approved S3.V7 and S3.V8
as separate Tasks, and deferred S3S-03 (DECISIONS E.1, "Stage 3 sign-off failed: corrective
Tasks").
- The rig editor now states a saved rig's provenance per spec. An imported rig's estimates read
  as estimated and its file values as from the file; a rig typed by hand reads as before.
- A new session snapshot records a group's provenance only when every spec shares it, else null.
  It never records an invented `user`.
- Per-field snapshot provenance, and snapshots already saved, are Stage 8's.
- **Next: S3.V8.** Then a fresh-session Stage 3 sign-off.

**Fresh-session Stage 3 sign-off, 2026-09-27: FAIL** at `74026ca`. Its code is identical to `d5e2b60`.
See [the sign-off report](STAGE_3_SIGNOFF_VALIDATION.md) and
[probe evidence](evidence/STAGE_3_SIGNOFF_PROBES.md).

- **Freshly executed, all pass:**
  - the full gate (1,195 tests, one expected skip, 2 host E2E);
  - the four real samples;
  - the four native JVM tests;
  - six new synthetic probes over real SQLite.
- **Blocking:**
  - **S3S-01 (TD-070):** the rig editor's provenance line and the session snapshot read only the
    group pairs, which an import saves as `user`/`reported`. An imported rig's CALC-40 estimates
    are therefore shown as "Camera specs: reported (user)".
  - **S3S-02 (TD-071, SI-014):** "New rig with the camera specs of …" copies the saved pitch and
    sensor size into a file of another pixel count. F3 stores half-consistent geometry, and the
    pixel scale is 2× off.
- **Non-blocking:** S3S-03 (TD-072), transposed size "conflicts" for a portrait-entered rig.
- **Unchanged:** everything the earlier reports checked still holds, and no application code
  changed. S3V-08 (device) stays unverified.

The repeat PASS below remains a record of what it checked. It did not exercise these paths.

**Repeat Stage 3 validation, 2026-09-27: PASS** at `d5e2b60`.
See [the repeat report](STAGE_3_REVALIDATION.md) and
[probe evidence](evidence/STAGE_3_REVALIDATION_PROBES.md). Freshly executed:
the full gate (1,195 tests, one expected skip, 2 host E2E), all ten archived
probes plus one additional camera-copy probe (11 pass), all four real metadata
samples, and all four native JVM tests. All prior blockers are resolved.
No application code changed in this validation. Fresh phone testing is not
claimed; S3V-08 and the previously carried device checks remain unverified.
The fresh-session validation requirement in §9.8 is not fulfilled by this
same-chat repeat. Formal Stage closure remains pending that check or an explicit
owner waiver; no waiver is inferred from the request to revalidate.

The failed validation below remains historical evidence; its findings were
corrected by S3.V1–S3.V6 and rechecked by the repeat report.

**Stage 3 validation, 2026-09-26: FAIL.** See [the report](STAGE_3_VALIDATION.md)
and [reproducible probes](evidence/STAGE_3_VALIDATION_PROBES.md). Baseline gate:
1,169 tests, one expected skip, 2 host E2E; four real metadata samples and four
native JVM tests pass. Independent probes reproduce stale-review data loss,
invented provenance, ineffective sensor conflict replacement, rounding of copied
saved values, and absurd dimensions accepted as known. Required real-database
review behavior tests are also missing. No application fixes were made. Stage 4
has not started. This was a validation-only follow-up in the existing chat;
the report discloses its earlier debug/exposure contributions and device limits.

Current visibility is **Add from a photo on Equipment in all build modes**;
the two debug/exposure amendments below are historical and superseded by S3.7.

*(Historical as to visibility and M4; superseded by S3.7 (`2b045eb`, 2026-09-26): the import is visible in every build as "Add from a photo" on the equipment screen, and the Settings viewer entry is removed. TD-066's formatting itself stands. Marked by S3.V5, S3V-07.)*
**Exposure formatting amendment, 2026-09-26 (owner, TD-066):** brought forward
from S3.7 after enabling the debug viewer. Shared `QuantityText.exposure` uses
integer reciprocal fractions within 0.5% relative error, with ≈ for approximation
(1e-12 tolerance for floating-point noise). Thus 0.04005 s → ≈1/25 s and
0.02 s → 1/50 s. Original metadata, raw rationals and calculations are unchanged.
The public workflow and M4 still belong to S3.7. Targeted formatter, metadata-row
and metadata-screen tests: 20 pass. Full quality gate passes: encoding, format,
analysis, 1,094 unit/widget tests (one expected local-sample skip) and 2 host E2E
tests. This run also includes the concurrent S3.2 tests present in the workspace.

*(Historical; superseded by S3.7 (`2b045eb`, 2026-09-26): the import is visible in every build as "Add from a photo" on the equipment screen, and the Settings viewer entry is removed. Marked by S3.V5, S3V-07.)*
**Debug access amendment, 2026-09-26 (owner):** Settings → Import metadata is
enabled in debug builds for Stage 3 development (`FeatureScope.metadataImport`
uses `kDebugMode`). Profile/release visibility and the planned Equipment
"Add from a photo" workflow still wait for S3.7 (ADR-018 §7). This does not
change the Stage 3 Task order or mark any import/persistence Task complete.
Verification: `dart run tool/check.dart` passes after updating the existing
visibility assertions: encoding, format, analysis, 1082 tests (1 expected
local-sample skip) and 2 host E2E tests. Hot restart/relaunch is required for
an already-running debug app to register the route.

| Item | State |
| --- | --- |
| Current strategic phase | **Post-roadmap refinement** (Stages 0–11, `POST_ROADMAP_PLAN.md`). The Master Development Roadmap is closed as a task queue; its open items are carried (`POST_ROADMAP_PLAN.md` Appendix B) |
| Current Stage | **Stage 5 — Design System Foundation: Not started** (planning is next). Stage 4 closed 2026-09-27: the final, bounded validation passed at `09a7f06` (`STAGE_4_FINAL_VALIDATION.md`) |
| Next Stage | Stage 6 — Core Planner Redesign: Not started |
| Current approved Task | None in progress |
| Next approved Task | None. Next: Stage 5 planning (verify the provisional P5.1–P5.6 against the code; RD-09; freeze the Task sequence). No implementation before that |
| Code baseline | S3.V8 (`92ebf2a`). Not pushed (S1.14) |
| Quality gate at the baseline | **Green at the Stage 4 revalidation**, 2026-09-27, re-run at `5ad69c4` on a clean tree (code unchanged since `92ebf2a`): Encoding, Format (376 files, 0 changed), Analyze, 1214 tests with 1 expected skip, 2 host E2E. Earlier, **green at the Stage 3 final sign-off**, 2026-09-27, re-run at `92ebf2a` on a clean tree: Encoding, Format (376 files, 0 changed), Analyze, 1214 tests with 1 expected skip, 2 host E2E. Earlier, **green after S3.V8**, 2026-09-27: Encoding, Format, Analyze, 1214 tests with 1 expected skip, 2 host E2E. Earlier, **green after S3.V7**, 2026-09-27: Encoding, Format, Analyze, 1208 tests with 1 expected skip, 2 host E2E. Earlier, **green after S3.V6**, 2026-09-27: Encoding, Format, Analyze, 1195 tests with 1 expected skip, 2 host E2E; archived probes P1–P10 pass. Earlier, **green after S3.V5**, 2026-09-27: Encoding, Format, Analyze, 1191 tests with 1 expected skip, 2 host E2E. Earlier, **green after S3.V4**, 2026-09-27: Encoding, Format, Analyze, 1186 tests with 1 expected skip, 2 host E2E; the local real-sample test passes. Earlier, **green after S3.V3**, 2026-09-27: Encoding, Format, Analyze, 1182 tests with 1 expected skip, 2 host E2E. Earlier, **green after S3.V2**, 2026-09-27: Encoding, Format, Analyze, 1177 tests with 1 expected skip, 2 host E2E. Earlier, **green after S3.V1**, 2026-09-26: Encoding, Format, Analyze, 1173 tests with 1 expected skip, 2 host E2E. Earlier, **green after S3.10**, 2026-09-26: Encoding, Format, Analyze, 1169 tests with 1 expected skip, 2 host E2E. Earlier, **green after S3.9**, 2026-09-26: Encoding, Format, Analyze, 1165 tests with 1 expected skip, 2 host E2E. Earlier, **green after S3.7**, 2026-09-26: Encoding, Format, Analyze, 1161 tests with 1 expected skip, 2 host E2E. Earlier, **green after S3.8**, 2026-09-26: Encoding, Format, Analyze, 1159 tests with 1 expected skip, 2 host E2E. Earlier, **green after S3.6**, 2026-09-26: Encoding, Format, Analyze, 1150 tests with 1 expected skip, 2 host E2E. Earlier, **green after S3.5**, 2026-09-26: Encoding, Format, Analyze, 1143 tests with 1 expected skip, 2 host E2E. Earlier, **green after S3.3**, 2026-09-26: Encoding, Format, Analyze, 1130 tests with 1 expected skip, 2 host E2E. Earlier, **green after S3.4**, 2026-09-26: Encoding, Format, Analyze, 1115 tests with 1 expected skip, 2 host E2E. Earlier, **green after S3.2**, 2026-09-26: Encoding, Format, Analyze, Test, E2E (host). The run included another session's uncommitted TD-066 edits (1094 tests); The committed state after both sessions has 1094 + 1 skip. Earlier, **green after S3.1**, 2026-09-26: Encoding, Format, Analyze; 1082 tests with 1 expected local-sample skip; 2 host E2E; the local real-sample test passes (DNG 856/856, JPEG 843, HEIC 4,051 bytes). Earlier: **green**, re-run at `0c4848b` on 2026-09-26 by the Stage 3 planning pass (same result; the local real-sample test also passes). First recorded after S2.V4, 2026-09-26: Encoding; Format (349 files, 0 changed); Analyze (no issues); 1068 tests with 1 expected local-sample skip; 2 host E2E; the local real-sample test passes (DNG 848/848, JPEG 843, HEIC 4,051 bytes); no Kotlin change since the native tests were re-run (4 pass) |
| Schema | **v18** (S3.4) |

## Completed Tasks

**Stage 5 planning (documentation only)**, 2026-09-27, this commit: S5.1–S5.9 frozen, with S5.8
gated on RD-09 (its options prepared). The inputs P5.1–P5.6, UX-16, UX-18, UX-34, UX-38, UX-39 and
08 §5–§8, §14, §20, §22 were re-verified at `38925dd`. Baseline gate PASS. No application or test
change.

**Final, bounded Stage 4 validation (validation and closeout only)**, 2026-09-27, this commit:
**PASS** at `09a7f06`, and Stage 4 is closed. The report is `STAGE_4_FINAL_VALIDATION.md`. No
application, test or design-document change.

**S4.V3 — bounded Stage 4 scope and validation rule**, 2026-09-27, `09a7f06`. Documentation and
governance only, on the owner's instruction:
- S4.V2's inferred rules are withdrawn, and are now S4-DEF-01 to S4-DEF-08;
- the final validation is bounded;
- the rule is recorded in `CLAUDE.md` and plan §9.8.

**S4.V2 — saved plans as immutable references**, 2026-09-27, `b9eed65`. Documentation only,
authorized by the owner's R2 + D1 decision with the saved-snapshot invariant. Resolves S4R-01 to
S4R-04 in the design documents; a fresh revalidation must confirm it. No application or test
changes.

**Stage 4 revalidation after S4.V1 (validation only)**, 2026-09-27, `750f0a7`: **FAIL** at
`5ad69c4`. `STAGE_4_REVALIDATION.md` holds S4R-01 to S4R-04, with S4.V2 proposed. The gate re-ran
green. No application, test or design-document change: only the report and this file.

**S4.V1 — saved-and-edited lifecycle clarification**, 2026-09-27, this correction commit.
Documentation only, authorized by the owner's request to fix S4V-01. ADR-019 §3.1 is normative;
research, architecture, wireframe addendum and future Task acceptance are aligned. No application
or test changes. Independent Stage 4 revalidation remains next.

**2026-09-26 — S2.V1–S2.V3 (this corrective commit):** owner-authorized fixes
for S2V-01/02/03; current-state documentation debt S2V-05 reconciled. See
`STAGE_2_CORRECTIONS.md` for implementation and complete verification results.
No visibility change; S2V-04 gates and device verification limits remain open.

| Stage | Task | Date | Commit | Result |
| --- | --- | --- | --- | --- |
| 0 | Stage 0 — Refinement Baseline (documentation only) | 2026-09-25 | `652ad80` | Created `PRODUCT_DIRECTION.md`, `POST_ROADMAP_PLAN.md` and `PROGRESS.md`; archived the Stage 0 prompt in `docs/refinement/prompts/`; committed the audit reports 01–08 and the owner's post-roadmap `CLAUDE.md` governance with them |
| 1 | Stage 1 planning (documentation only): every A–F candidate re-verified at `652ad80` (none stale); RD-03 resolved; RD-05 interim decided; RD-17 included; the Task sequence S1.1–S1.15 frozen | 2026-09-25 | `1ec6e7a` | `POST_ROADMAP_PLAN.md` §5 and §8; DECISIONS E.1 "Stage 1 planning decisions" |
| 1 | S1.1 — Open-Meteo user agent (A3) | 2026-09-25 | `6a90347` | Open-Meteo requests carry `AppIdentity.userAgent`; a `MockClient` test (fails without the fix). Resolves ENG-03 = RT-07. Gate green, 897 + 2 E2E. Found: `ARCHITECTURE.md:494` and F-29's body are stale, added to S1.15 |
| 1 | S1.2 — Seeding and preference failure paths (A2, E1, E3) | 2026-09-25 | `c449c03` | `CatalogSeeder` skips ids a catalog row already holds and leaves the version unrecorded when any other insert fails, so the next launch retries (3 tests, failing before the fix); `EquipmentSeeder` re-checked, already retries; the privacy preferences failure-path test. Resolves ENG-02 = RT-02, 01 §G.7. Gate green, 901 + 2 E2E |
| 1 | S1.3 — Forecast freshness over time, resume and rollover (A1, E2) | 2026-09-25 | `2007dc5` | `NightWeatherAvailable.at` and `NightWeather.isOutdated` (domain); `NightConditionsViewModel.checkClock()`/`resumed()`; a `NightClock` widget at the app root (one-minute tick, `AppLifecycleListener`); a snapshot re-ages first; summary/opportunity caches keyed on the snapshot. 7 tests, the 04/P1 steps (the snapshot test fails without the fix). Resolves ENG-01 = SCI-01 = RT-01. Found and recorded: TD-057 (the draft's night key and an open candidates list do not follow a rollover). Gate green, 908 + 2 E2E |
| 1 | S1.4 — Night key without a site (A4) | 2026-09-25 | `db2702f` | **Scope corrected with the owner:** the planned device-zone rule broke ADR-007 §6, so the key is the default night at the default position (`SessionNightResolver`), never the UTC Y/M/D (DECISIONS E.1; plan entry annotated). `SessionPlanViewModel` resolves one `_night` for both; `today` removed; the VM stays at its 300-line cap. The 04/P4 case as a test (fails before). Resolves ENG-05 = SCI-11 = RT-06. Gate green, 909 + 2 E2E |
| 1 | S1.5 — Unsupported-database recovery (A6) | 2026-09-25 | `07d55e2` | `main.dart` probes the database before building the graph (`refusedSchemaVersion`) and shows `UnsupportedDatabaseApp`: newer data is explained and **never reset** (ADR-008 §2; plan entry annotated), below-floor data can be reset after confirmation (`resetRefusedDatabase`: close, keep `.v<N>.bak`), then the bootstrap reruns. 10 tests (real files: unchanged until confirmed, `.bak` identical, fresh DB seeds 164; the screen: wording, Cancel, a failed reset, a11y at 200 % in light and dark). **Not host-testable:** the `main.dart` wiring itself (platform plugins) — a device check for Stage 11. Resolves TASK 3.2 UI half, RT-03, TD-047 (fully). Gate green, 919 + 2 E2E |
| 1 | S1.6 — Confirm before replacing an unsaved draft (A7, interim) | 2026-09-25 | `c0bfcb7` | `CurrentSession.hasUnsavedChanges` (edits since created/opened/saved; a site change is not an edit; a failed Save or Start keeps them; a resumed draft infers it from its content); `confirmLeavingUnsavedPlan` on the planner's "+" and Duplicate, Tonight's "New session" and "Open in planner" (another session only); the last two also through `runWithFeedback`. `SessionPlanViewModel` still 300 lines. 10 tests: the flag, and each button through the real app (Cancel keeps, Discard proceeds, an untouched draft never asks, the dialog accessible at 200 % in light and dark). RT-05/UX-12 mitigated; RD-05 still open for Stage 4. Gate green, 929 + 2 E2E |
| 1 | S1.7 — One format for durations and numbers (A5, C2) | 2026-09-25 | `20eff0e` | `QuantityText` in `lib/core/utils` (the domain's fit reasons use it too): durations rounded to the minute in one form, exposures without .0 (and no longer rounded to whole seconds in four screens), typographic minus, "3 %"; the three duration formatters delegate or are gone; `totalIntegrationTime` removed; RA/Dec in the session detail as h:m:s / d:m:s. 6 unit tests plus assertions in 4 widget tests (3 updated to the new strings). Resolves ENG-06, UX-19 (IA-independent part). Gate green, 935 + 2 E2E |
| 1 | S1.8 — Visible text defects and labels (C1, C4, B2, B7/SCI-05) | 2026-09-25 | `b03dda9` | Session detail: "f/5.6", "None recorded.", the night key as "Night span"; Settings' overhead note corrected; the candidates footer and frame fill (`CapabilityText.frameFillOf`); the add-block helper wraps; the sky card names both Bortle entry points; "ISO / gain (for your records)". 1 new test plus assertions in 5 widget tests (the candidates test now seeds the default rig so its rows carry a frame fill; the sky-card string updated). Resolves UX-20, UX-18 (IA-independent part), SCI-05, SCI-06. Gate green, 936 + 2 E2E |
| 1 | S1.9 — Fit status colours and the missing-input state (C3) | 2026-09-25 | `705b764` | `AppPalette.caution` in all three palettes (light #9A5B00, AA; dark orange 300; field the primary red) for "Tight"; `FitState.needsInput` (`FitAnalyzer.analyze(inputMissing:)`, set by the VM when the site or target is missing) drawn neutral; a real no-window night stays red. 7 tests (domain states, the VM with no site / no target / a never-rising target, colours and AA contrast in light and dark); the field red-only check covers the token. Resolves UX-16, UX-15(2). Gate green, 943 + 2 E2E |
| 1 | S1.10 — Weather strip at 200 % text; a forecast in the sweep (D1, D2) | 2026-09-25 | `642b235` | The sweep's weather fake serves a full forecast; with it the sweep failed on the old strip (94 px and 222 px overflows, demonstrated), and passes after the fix: no fixed 130 px height (`IntrinsicHeight` in a horizontal scroll), columns widen with the text size, an 8 px label–value gap. A test keeps the forecast on screen and checks the gap (fails before). Resolves UX-31, UX-32. Gate green, 944 + 2 E2E |
| 1 | S1.11 — Tracker controls expose a tap action (D3) | 2026-09-25 | `b0998c6` | **Verified first:** a semantics test showed `run.plus` (and the others) had no tap action and no enabled state. Fixed: the relabelling `Semantics` passes `onTap: onPressed` and `enabled`. The test checks all seven controls and that a semantics tap confirms a frame; fails before. Resolves UX-28 on the host; TalkBack remains a Stage 11 device check. Gate green, 945 + 2 E2E |
| 1 | S1.12 — Save/Start against the autosave chain (F) | 2026-09-25 | `b6fb6c3` | UI-driven test, no injected delays: Save then an edit **did not reproduce** (kept as a regression test); Start then an edit **reproduced** (the edit landed in the session being started). Fixed: Save and Start run inside the chain (`CurrentSession._inChain`). Found and recorded: TD-058 (New/Duplicate/Open, same pattern). Resolves ENG-08 = RT-04. Gate green, 947 + 2 E2E |
| 1 | S1.13 — Scientific labels and documentation (B1, B3, B4, B6, B7/SCI-04) | 2026-09-25 | `f179013` | SCI-02: "Chance of precipitation (preceding hour)" plus a note under the hour strip, CALC-32 corrected. SCI-09: night-level Moon illumination "at midnight" (Tonight, sky card, window annotations). SCI-03: documented in CALC-28/29 (no displayed text claimed they coincide). SCI-04: accepted as documented in SI-009 and CALC-08 (RD-03). B6: the CALC-01 to 06 tests cite Meeus or the definition, and CALC-03 gained a direct test. No calculation changed. Gate green, 948 + 2 E2E |
| 1 | S1.14 — Push CI and observe a first run (RD-17) | 2026-09-25 | `28aaa10` (documentation only) | **Deferred by the owner** when asked before the push. Checked: 155 commits ahead as a fast-forward; the remote is public; no secret file tracked; the workflow pins the local Flutter version. Nothing pushed; RD-17 open again (Stage 11 or on request) |
| 1 | S1.15 — Documentation drift (B5; SCI-10 docs) | 2026-09-25 | `4e653fb` | Corrected, each marked "corrected S1.15" with the old text kept: `optical_calculator.dart` comments (NPF shown; √N is noise, not signal); SI-001/002/003/008/009 statuses (index and sections); CALC-07, CALC-17, CALC-28 and, found here, CALC-13; DEV-P2 ("SNR" appears in four doc comments, none user-facing; DEV-P2 resolved) and the ADR-005 conformance row; F-29 (current state), F-46/F-49 summary rows, F-49 and TD-046 (a public remote exists, never pushed since `a1bcbd9`, S1.14 deferred), F-50's app id; TEST_PLAN L3; `ARCHITECTURE.md` external-services rows (Open-Meteo, Nominatim, OSM tiles) and, found here, the B9 cache note; `PROJECT_HANDOFF.md` header pointer to `docs/refinement/` and §0 marked historical; the `CLAUDE.md` device wording (owner-approved). Historical files untouched. No full re-audit was done. Gate green, 948 + 2 E2E |
| 1 | Independent Stage 1 validation (documentation and probe evidence only) | 2026-09-25 | `db94aaf` | Gate green (948 + 2 E2E), but six additional assertions reproduce TD-059–TD-062. Proposed S1.V1–S1.V4; no fixes or Stage 2 work. See `STAGE_1_VALIDATION.md` |
| 1 | S1.16 — Commit hashes in the registers (V1) and S1.17 — the field theme in the dialog's accessibility check (V2); V3 recorded under RD-05 | 2026-09-25 | `953c0d1` | Owner: "apply fixes for the remaining items to complete Stage 1". 37 `S1.x` stamps in `ARCHITECTURE.md`, `DATA_MODEL.md`, `FEATURE_STATUS.md` and `SCIENTIFIC_INTEGRITY.md`, TD-047, TD-057 and TD-058 cite their commits; the "Discard unsaved changes?" dialog is checked in the light, dark and field themes (contrast not in field, as in the sweep); V3 added to RD-05 (`POST_ROADMAP_PLAN.md` §8). Gate green, 949 + 2 E2E |
| 1 | S1.V1 — Recognize refusal through the production database connection (TD-059) | 2026-09-25 | `3067658` | `refusedSchemaVersion` unwraps `DriftRemoteException` (its `remoteCause` is the typed refusal on the same-group background isolate); the connection builder is shared (`openDatabaseConnection`). 5 tests through that connection; the refusal tests failed before the fix (the exception escaped). Gate green, 954 + 2 E2E |
| 1 | S1.V2 — Seed the replacement database after a confirmed reset (TD-060) | 2026-09-25 | `b34c9ad` | `confirmDatabaseReset` (refuse newer, forget only the catalog seed marker, keep the old file) replaces the bare rename in `main.dart`. 3 tests through the production connection, with and without the marker, other preferences kept; with the S1.5 behaviour the with-marker test gave 0 targets instead of 164. Stale id-holding preferences after a reset left with TD-056/ENG-14. Gate green, 957 + 2 E2E |
| 1 | S1.V3 — Keep the unsaved-plan safeguard across a restart (TD-061) | 2026-09-25 | `ed628f8` | `CurrentSession` remembers the edited session id through `PlannerStateRepository` (preference `editedSessionId`; no schema change; a site change still not an edit). 5 new tests plus a restart check on the failed-Save test: target-, rig-, night- and block-only edits protected after a restart (target, rig and night failed before), Save clears it, an untouched draft never asks. Cancel's navigation clarified (closes the dialog, stays put). Gate green, 962 + 2 E2E |
| 1 | S1.V4 — Reopening the current session keeps its live plan (TD-062) | 2026-09-25 | `ea65231` | `openSession` returns early for the current, editable session. The validation's probe as a UI test through the detail page, a Save and a restart (20 instead of 7 frames before the fix). A first version also skipped frozen sessions; two existing tests caught it and the guard was narrowed to editable sessions. Gate green, 963 + 2 E2E |
| 1 | Fast re-validation after S1.V1–S1.V4 (same session, owner's request; **not independent**) | 2026-09-26 | `c99bd7f` | At `ea65231`: gate green (963 + 2 E2E), clean tree. Throwaway probes: the reset as `main.dart` runs it with a leftover marker → 164 targets, 1 rig, `.bak` kept; edit → New → restart and edit → Start → restart leave nothing unsaved and the run untouched. One low finding **W1**: a Duplicate of an edited plan counts as saved in-session but unsaved after a restart, so New right after Duplicate replaces the copy without asking (the saved original remains; only the copy's night is lost). Proposed: record under RD-05, like V3. Stage 1 still needs an **independent** validation to close |
| 1 | Repeat independent Stage 1 validation (documentation and probe evidence only) | 2026-09-26 | `39392d9` | Fresh session at `c99bd7f`: gate green (963 + 2 E2E); S1.V1–S1.V4 and S1.16/S1.17 pass their acceptance; no test weakened; no scope drift. **Does not pass:** TD-063 was reproduced through the UI (a detail page loaded before Start reopens the running session as the planner's plan, and every autosave is then refused), and X2 (the registers still say S1.5/S1.6 are broken, and the S1.V stamps cite no commit). W1 confirmed. Proposed S1.V5 and S1.V6. See `STAGE_1_REVALIDATION.md` and `evidence/STAGE_1_REVALIDATION_PROBES.patch` |
| 1–2 | Stage 1 closed by the owner, and Stage 2 planning (documentation only) | 2026-09-26 | `565341b` | The owner said "lets go to stage 2" after the re-validation failed. Recorded as a waiver (DECISIONS E.1): TD-063 moved to Stage 8, X2 and W1 carried. Stage 2: TD-018's mechanisms were re-verified at `39392d9` (all still present); six planning-time findings were placed; S2.R1 is frozen and S2.1–S2.6 are provisional (`POST_ROADMAP_PLAN.md`) |
| 2 | S2.R1 — RG-01: formats, libraries, file selection, fixtures (research, documentation only) | 2026-09-26 | `d4b2be4` | The owner's two phone DNGs (Xiaomi, DNG 1.4, 25 MB each; kept outside the repository) were inspected. All their metadata sits in IFD0 within the first 6.7 KB. They have no GPS and no time offset, and the same Model for both cameras (input for RG-02). The prototype finds 0 of 5 capture fields in them (TD-064). Sources read: `exif` 3.3.0 (MIT; TIFF, JPEG and HEIC; no byte-budget API); `file_picker` 13.1.0 / `android_file_picker` 2.0.0 (copies every file whole into the cache; the extension filter drops unknown MIME types; TD-065); the FITS 4.0 standard (`CONTINUE` is standard, `''` escapes, `DATE-OBS` is UTC at the start); XISF 1.0 (focal length in metres, gain in e⁻/DN); N.I.N.A.'s documented keywords (FOCALLEN is user-entered). Recommended: DNG/TIFF now, FITS on a sample, in-house bounded readers, the `exif` and `image_picker` dependencies removed, no GPS or serials, header-only fixtures with consent, the feature hidden until Stage 3. Proposed ADR-017 |
| 2 | RG-01 decided by the owner; ADR-017; Stage 2 frozen (documentation only) | 2026-09-26 | `96454d8` | The owner approved the direction with constraints. Decided: DNG only, and FITS only with a real sample; bounded reads recognised by signature; the approved contract's fields only; Unknown and provenance kept; no GPS, serials or observer; no inferred zone; the owner's slices never committed (synthetic, sanitized fixtures; the real files stay local); the UI hidden in Stage 2; no Equipment writes; TD-065 is in scope. ADR-017 written (Part F), including the justified removal of `exif` and `image_picker` (both copy or read whole files; each has one use). Verified: `image_picker_android` 0.8.13+23 also copies every pick into the cache, and offers images only. Stage 3 evidence recorded (identical Model across the phone's cameras). S2.1–S2.6 frozen. New blocker: no Android device or emulator can run S2.4's native path |
| 2 | S2.1 — Bounded metadata source and format recognition | 2026-09-26 | `a25398c` | `lib/domain/metadata/`: `MetadataSource`, `BudgetedMetadataSource` (1 MiB per file, 64 KiB per read, a read log, refused reads cost nothing), typed `MetadataReadException`, and `MetadataFormatRecognizer` (TIFF, FITS, XISF and JPEG by signature, ≤ 16 bytes). `lib/data/metadata/file_metadata_source.dart`: positioned, serialized reads, with short reads typed. 17 tests: the budget, limits and ranges, wrapping and short reads; signatures and near misses; a real 4 GiB file recognised and read at both ends with ≤ 64 KiB read; the domain purity check, which fails on a domain `dart:io` import (demonstrated with a temporary file, removed) and allows only the prototype until S2.5. Gate green, 980 + 2 E2E |
| 2 | S2.2 — The metadata contract as typed values with provenance | 2026-09-26 | `b8d626a` | Pure Dart. `MetadataValue<T>`: `KnownValue` (value, raw text, origin with format, tag, location and provenance), `AbsentValue`, `UnparseableValue` and `AmbiguousValue`; `combine` keeps agreeing values and marks conflicts ambiguous. `CaptureMetadata` has the 11 contract fields, all absent by default. `MetadataReading`, with its unreadable reasons. `ExifValues`: exact rationals; the 35 mm equivalent kept separate (0 = absent); sensitivity with its kind (SensitivityType 1–3, otherwise unspecified; 0 and 65535 unparseable); capture time as local wall-clock plus an offset only if recorded, otherwise zone unknown with no instant. CALC-39 and an SI-004 note were added. The tests use synthetic timestamps only. 15 tests. Gate green, 995 + 2 E2E |
| 2 | S2.3 — DNG/TIFF reader, with synthetic fixtures and local real-sample validation | 2026-09-26 | `59c9f03` | `TiffMetadataReader`: IFD0 and the EXIF IFD, contract tags only; the GPS IFD, sub-IFDs, MakerNotes, serials and pixels are never followed. Bounds, entry, repeat and loop checks; one bad value makes only that field unparseable; no DNGVersion → unsupported. `CaptureMetadataReader` recognises, then dispatches; `MetadataFormat.dng` added. Synthetic fixture builder, including a sanitized layout like the phone files. 13 reader tests: phone-style, big-endian, EXIF-IFD with an offset, agreement and ambiguity, GPS and serials never read (read log), non-DNG, other formats, truncated, corrupt, budget, bad single values, every truncation up to 1,200 bytes plus 500 seeded corruptions. **Real samples (local, `ASTROPLAN_METADATA_SAMPLES`):** both owner DNGs gave every expected contract value, reading 848 bytes in 11 reads of about 25 MB each (values kept outside the repository). Gate green, 1008 + 1 skipped (the real-sample test) + 2 E2E |
| 2 | S2.4 — Android document access without a copy; picker cache ownership (TD-065) | 2026-09-26 | `26aff9a` | **Implemented, not accepted (device check pending).** `MetadataDocumentChannel.kt` (registered in `MainActivity`): `ACTION_OPEN_DOCUMENT` with no copy; positioned reads on the provider's descriptor; a sequential fallback within 1 MiB for descriptors that cannot seek; a background thread; no persistable grant. Domain `CaptureFileAccess`/`CaptureFile`; data `AndroidCaptureFileAccess` and `ContentUriMetadataSource` with typed failures. TD-065: `FileBackupService.pick` always clears the picker cache (it is injectable; a failed cleanup is logged). 8 tests (5 channel tests against a host stand-in, 3 cleanup tests). The debug APK builds (the Kotlin compiles). TEST_PLAN gains device rows M1 and M2, not run. Gate green, 1016 + 1 skipped + 2 E2E |
| 2 | S2.5 — The hidden import screen on the foundation; the prototype, `exif` and `image_picker` removed | 2026-09-26 | `a2f42a5` | **Implemented; device check M1 pending (with S2.4).** `MetadataImportViewModel` (domain `CaptureFileAccess` only) → `CaptureMetadataReader`; the screen shows every contract row with its unit and source, and unknown, unreadable or conflicting values as such (`metadata_text.dart`). `main.dart` wires Android only; elsewhere "not available". The prototype extractor, `ImageMetadata` and their 2 tests are removed (plus the purity test's allowance test); `exif` and `image_picker` were removed after a `grep` showed no other use (the lock lost 15 packages, nothing else changed; the desktop registrants lost `file_selector`). The gate stays hidden. Privacy and Data Safety were checked: no change (nothing leaves the device). 11 tests (6 screen tests, including a11y at 200 %; 5 wording tests). The debug APK builds. TD-018 and TD-064 resolved. Gate green, 1024 + 1 skipped + 2 E2E |
| 2 | Review of S2.1–S2.5 against the owner's format priorities (documentation only) | 2026-09-26 | `9f7310d` | The owner's direction: one common typed, provenance-aware contract for many formats; the priorities DNG, JPEG, HEIC/HEIF, FITS on a sample, PNG where meaningful, proprietary RAW through research only (no ad hoc parsers), XISF sample-driven; three distinct levels (recognition, extraction, equipment evidence); no decoders or RAW framework. Review (`STAGE_2_ARCHITECTURE_REVIEW.md`): the contract, values, provenance, bounds, privacy and no-write rules already fit; no defect. Gaps: G1 EXIF parsing fused with the DNG container (header at byte 0, format hardcoded); G2 closed dispatch; G3 recognition and extraction share one result; G4 HEIF, PNG, CR2, CR3, RAF, RW2 and ORF are not recognised; G5 EXIF conversions in the contract file; G6 no generic optics identity (for FITS). Recorded: DECISIONS E.1 and ADR-017 §13 (supersedes the §8 list); RG-14; S2.7, S2.8, S2.R2, S2.R3 frozen; S2.9 and S2.10 conditional; the Stage 2 exit amended |
| 2 | S2.7 — Layered recognition and a reusable EXIF extractor | 2026-09-26 | `9a0432b` | A refactor, closing review gaps G1–G5. `ExifStructure` (IFD0 + the EXIF IFD, the same rules), used on any source; `MetadataSourceWindow` for embedded structures; origins labelled by container; `DngMetadataReader` as a thin container; `MetadataFormatReader` with dispatch by registration; recognition (`reading.format`) kept apart from extraction (the subclass), with `nothingFound`, `recognized` and the format on unreadable readings; recognition-only HEIF, PNG, CR2, CR3, RAF, RW2 and ORF; `ExifValues` moved to `exif_values.dart`. **No DNG behaviour change:** every existing metadata test passes with its assertions unchanged (one import added), the synthetic read log is byte-identical to a baseline captured before the change, and the real samples still read 848 bytes. 10 new tests. Gate green, 1034 + 1 skipped + 2 E2E |
| 2 | S2.R2 — HEIC/HEIF metadata research (documentation only), and the owner's FITS/PNG skip | 2026-09-26 | `5cc23a8` | The owner supplied a phone HEIC and JPEG (outside the repository) and skipped FITS and PNG (DECISIONS E.1): S2.6 and S2.10 leave Stage 2, and both formats stay recognised only. HEIC findings (`research/S2.R2_HEIF_METADATA.md`): `meta` in the first 3.2 KB; the Exif item (linked to the primary by `iref cdsc`) sits at the **end** of the file (97 %), so random access is needed and a non-seekable provider hits the budget (typed); its payload skips a JPEG APP1 header through `exif_tiff_header_offset` = 10; the same EXIF structure as the JPEG, with `OffsetTimeOriginal` +03:00; no GPS, no serials. JPEG: APP1 Exif at byte 2, the metadata within 1.8 KB, SOS at 1.3 %. Stage 3 evidence: Model differs by format for the same phone (DNG `…/2407FPN8EG`, JPEG/HEIC `Xiaomi 14T Pro`); the offset is recorded in JPEG/HEIC, not DNG. Recommended: option A, an in-house box walker → `ExifStructure` (S2.9 defined in §7). Owner decision pending |
| 2 | S2.8 — JPEG reader | 2026-09-26 | `360fd8f` | `JpegMetadataReader`: a bounded marker walk (fill bytes; stops at SOS or EOI; a bad marker, a zero length, a second SOI or more than 128 segments is corrupt) → the APP1 `Exif` segment → the shared `ExifStructure` through a window (origins "APP1 …"); no scan data read; no Exif = "nothing found". Registered in `readers`. Synthetic `jpeg_fixture.dart`; 8 tests (phone-style values with the offset, bounded reads, the GPS IFD never followed, segments before Exif, no Exif, truncated and corrupt, a corrupt EXIF inside APP1, every third truncation plus 500 seeded corruptions). One earlier assertion ("JPEG is unsupported") became a HEIF case, since JPEG now has a reader. **Real sample (local):** the owner's phone JPEG gives every expected value, including a UTC time, reading 843 bytes of 4.7 MB; the DNGs are unchanged (848). Gate green, 1042 + 1 skipped + 2 E2E |
| 2 | Device checks M1 and M2 (S2.4 and S2.5 accepted) | 2026-09-26 | `79f392c` | On the owner's Xiaomi 14T Pro (Android 16, API 36), over USB, at `360fd8f`. A separate debug package (`…astroplanner.s2check`) was used; the gate flip and application id suffix were local and reverted, so the owner's installed app and data were untouched. **M1:** both DNGs and the phone JPEG, picked through the system picker, gave every expected value; the HEIC said "not supported yet"; the app cache stayed empty (4 KB) after every pick; a cancel changed nothing. **M2:** a 25 MB DNG through Restore was refused with its message, and the cache was empty right after; so was a cancelled restore. Not run: the non-seekable (cloud) path, which would need uploading owner files; a real backup's preview cancel. Found: TD-066 (a 1/100 s exposure prints as "0.009987236 s"). Afterwards the test package, the copied DNGs and the UI dump were removed from the phone. An Android device is now available, including for Stage 11's device rows |
| 2 | Independent Stage 2 validation (another session) and S2.V1–S2.V3 corrections | 2026-09-26 | `ffaff57` | Validation at `79f392c` **failed** (`STAGE_2_VALIDATION.md`): S2V-01 (a SHORT/LONG pointer reported as a value), S2V-02 (a short JPEG EXIF reported as nothing found), S2V-03 (non-seekable reads not charged cumulatively), S2V-04 (S2.9/S2.R3 open), S2V-05 (stale docs). The owner authorized S2.V1–S2.V3 (`STAGE_2_CORRECTIONS.md`): strict integer counts, the Exif id checked as soon as it fits, and streaming budgets charged natively (`MetadataSequentialReader`, 4 JVM tests). Gate green, 1052 + 1 skipped + 2 E2E (row added by S2.9, which found it recorded only in prose) |
| 2 | S2.9 — HEIC/HEIF reader | 2026-09-26 | `bb28452` | The owner approved S2.R2 §7 ("You can"). `HeifMetadataReader`: walks the top-level boxes by header only; reads `meta` once (≤ 64 KiB, else overBudget); parses `pitm`, `iinf`/`infe` (v2–3), `iloc` (v0–2; field sizes 0/4/8; construction methods 0 and 1; another file never followed) and `iref cdsc`, each bounded by its box; takes the Exif item linked to the primary item, else the only one, else combines all (conflicts ambiguous); honours `exif_tiff_header_offset` (Xiaomi's APP1 prefix) and hands the rest to the shared `ExifStructure` (origin "Exif item …"); refuses several extents or method 2 as corrupt; an extent or TIFF past its end is truncated, never "nothing found"; no image data is read. Registered in `readers`. Synthetic `heif_fixture.dart`; 10 tests (phone layout with the APP1 prefix, six variants, item choice, no Exif, truncated/corrupt/oversized cases, a truncation sweep proving a cut file never reads complete, 500 seeded corruptions). Two earlier cases that listed HEIF as reader-less now use CR3. **Real sample (local):** the owner's HEIC gives every expected value with its UTC offset, reading 4,051 bytes of 1.9 MB; DNG/JPEG unchanged (848, 848, 843). The device check M3 could not run (the phone disconnected; the local test package changes were reverted unused). Gate green, 1062 + 1 skipped + 2 E2E |
| 2 | Device check M3 (HEIC on the phone) | 2026-09-26 | `237c55f` | At `3a23391`, on the owner's Xiaomi 14T Pro (Android 16), through a separate `.s2check` debug package (local changes reverted before install; package removed afterwards): the HEIC gave every expected value with UTC+03:00; the JPEG, re-read under the S2.V3 channel protocol (`ffaff57`), was unchanged; the cache stayed empty. Observed, not caused by this check: the owner's own `io.github.chacha12.astroplanner` shows lastUpdateTime 2026-09-26 09:24:47 (it was 2026-09-25 16:18 earlier the same day); this session installed only `.s2check` |
| 2 | S2.R3 — RG-14: proprietary RAW compatibility and library research (documentation only) | 2026-09-26 | `e444bfa` | `research/S2.R3_RG14_PROPRIETARY_RAW.md`. Verified: AndroidX `ExifInterface` reads DNG, CR2, NEF, NRW, ARW, RW2, ORF, PEF, SRW and RAF (not CR3), with no documented read bound and its own GPS parsing; LibRaw is a decoder (LGPL-2.1/CDDL-1.0). Documented by reverse engineering: RAF's header points to an embedded JPEG holding the EXIF (libopenraw); CR3 keeps IFD0 and the EXIF IFD as TIFF structures in `moov`/`uuid` CMT1/CMT2, with GPS in CMT4 (lclevy). No proprietary RAW sample exists. Recommended: D (recognised only) to close Stage 2; A (container adapters over the shared extractor, one per format, only with a real sample: RAF, then CR2/NEF/ARW, ORF/RW2, CR3 last) afterwards; reject B (`ExifInterface`: unbounded and unprovable reads, a second path) and C (LibRaw: a decoder). Owner decision pending |
| 2 | RG-14 decided by the owner; Stage 2 ready for validation (documentation only) | 2026-09-26 | `5d8bdbb` | The owner chose the recommendation, when asked which "second scenario" was meant: no proprietary RAW in Stage 2 (D); afterwards, per-format adapters over the shared extractor, each only with a real sample (A, in the order RAF → CR2/NEF/ARW → ORF/RW2 → CR3); `ExifInterface` (B) and LibRaw (C) rejected. Stage 2 closes by the repeat independent validation, not a waiver (the owner's choice). The owner's RAW formats are still unknown. Recorded in DECISIONS E.1, ADR-017's status and the plan's post-Stage-2 list |

| 2 | Repeat independent Stage 2 validation (documentation and probe evidence only) | 2026-09-26 | `f137409` | A fresh session at `5d8bdbb`: the gate is green on the clean tree; the real samples pass (DNG 848/848, JPEG 843, HEIC 4,051 bytes); the native JVM tests were re-run (4 pass). S2V-01 to S2V-04 are resolved, and HEIF inherits the fixes (probes P2–P4). **Fails on S2R-01 (TD-067):** a crafted `iloc` with zero-size fields makes the HEIF reader allocate about 1.7 GB in 9–17 s from an 8 KB `meta`, on the UI isolate (probe P1). Low: S2R-02 (AVIF and sequence brands go to the HEIF reader without a sample, and a sequence-only file reads as "corrupt"), S2R-03 (stale F-45 and `TEST_PLAN.md` text), S2R-04 (HEIF test gaps). No code or test changed; the probes were deleted, and their code is in `evidence/STAGE_2_REVALIDATION_PROBES.md`. See `STAGE_2_REVALIDATION.md` |

| 2 | S2.V4 — Bound the HEIF `iloc` work; AVIF and HEIF sequences recognised only; HEIF test gaps | 2026-09-26 | `d8e792c` | The owner said "Do fix"; S2R-02 was taken as the recommended option (a) (DECISIONS E.1). **TD-067 resolved:** `maxExtents` = 16,384 over all items → `corrupt`. New `MetadataFormat.avif` and `heifSequence`, both recognised only and named in `MetadataText`. There are 6 new HEIF tests: the bound (fails on the old reader), the limit, GPS never read, S2V-01, S2V-02, and the brands. One assertion in `metadata_layers_test.dart` changed because of the ruling (`avif` and `msf1` were HEIF). The real samples are unchanged. Gate green (Encoding; Format (349 files, 0 changed); Analyze (no issues); 1068 tests with 1 expected local-sample skip; 2 host E2E). See `STAGE_2_CORRECTIONS.md` |
| 2 | S2.V5 — Documentation reconciliation (S2R-03) | 2026-09-26 | `435b3ce` | F-45's current-implementation and known-issues text, and `TEST_PLAN.md`'s "no device" note, are corrected with the old text quoted. Also updated: `ARCHITECTURE.md` B, ADR-017's note, E.1, TD-067, `POST_ROADMAP_PLAN.md` (the corrective-Task table) and this file |

| 1 | S1.V6 — Stage 1 registers brought up to date (X2; documentation only) | 2026-09-26 | `3dd2598` | Run at the owner's request ("wrap up the important issues" before Stage 3). The validation banners and notes that called S1.5 broken and S1.6 partial are marked superseded, with the old text kept: `FEATURE_STATUS.md` (banner, F-02, F-40), `ARCHITECTURE.md` (banner, B3, B4), `DATA_MODEL.md` (banner, B8) and `TECH_DEBT.md` (banners). TD-047 is closed again. The S1.V1–S1.V4 stamps (8) and TD-059–TD-062 cite `3067658`, `b34c9ad`, `ed628f8` and `ea65231` (each checked with `git log`). No code changed. TD-063 stays in Stage 8, and W1 stays with RD-05 |

| 2–3 | Stage 2 closed by the owner, and Stage 3 planning (documentation only) | 2026-09-26 | `0c4848b` | Asked to choose between a fresh-session validation and a waiver, the owner chose "Waive and go to Stage 3". Recorded as a waiver (E.1). Stage 3 planning at `3dd2598` verified nine facts (`POST_ROADMAP_PLAN.md`, "Verified at planning"). The key one: `EquipmentProfile` and its columns require sensor size, resolution, pixel pitch, focal length and focal ratio, and the metadata contract has no image dimensions, so an import cannot store a rig without invented values. Frozen: S3.R1 (RG-02), S3.R2 (RG-03), S3.D (decisions, ADR-018). Provisional: S3.1–S3.6 |

| 3 | Stage 3 second planning pass, including S3.R1 (RG-02) (documentation only) | 2026-09-26 | `4c46f8f` | From the owner's Stage 3 planning prompt. Verified the Stage 2 foundation at `0c4848b` (gate green; the local real samples pass; no stale claim, except this file's missing `0c4848b`). `research/RG-02_EQUIPMENT_IDENTITY.md`: field classification, derivability matrix, device classes, matching and conflict outcomes, provenance and confirmation, storage options, decisions D1–D4. A throwaway probe (deleted) found that the pixel dimensions are in all four samples (swapped in the portrait JPEG/HEIC) and that no focal-plane tags exist. Refined sequence S3.1–S3.9, provisional; recommended D1 = A1 (complete before saving, with an estimate offered) |

| 3 | S3.D — owner decisions D1–D4; ADR-018; Stage 3 frozen (documentation only) | 2026-09-26 | `792b295` | The owner chose the recommended option for each decision (asked in this session): **D1 = A1** (the import pre-fills the editor, a rig is saved only when complete, and the CALC-40 sensor/pixel estimate is offered as `estimated`); **D2**: RG-03 deferred (S3.R2 and S3.9 leave Stage 3); **D3**: visible at the end of Stage 3, as "Add from a photo" on the equipment screen (RD-16 resolved); **D4**: a DNG pick's file length as the estimated RAW size. ADR-018 accepted: it amends ADR-017 §2 with image dimensions and applies ADR-008 §6 per field to equipment (schema v18). DECISIONS E.1 "Stage 3 decisions (S3.D)". S3.1–S3.8 frozen |

| 3 | S3.1 — Image geometry in the metadata contract (ADR-018 §3) | 2026-09-26 | `60ec4db` | `CaptureMetadata.imageDimensions` (`ImageDimensions`, with long/short sides; orientation not interpreted). `ExifStructure` reads it: DNG from IFD0's main image only (`NewSubfileType` 0 or absent; `DefaultCropSize` when whole, else `ImageWidth`/`ImageLength`; sub-IFDs never followed); JPEG/HEIC from `PixelX/YDimension` combined with IFD0 (disagreement ambiguous). The hidden screen gains an "Image size" row. 14 new tests (`image_dimensions_test.dart`: the DNG rules, crop types, fallbacks, malformed values, a preview IFD0, the JPEG/HEIC rules, wrong-IFD tags, and GPS never read; `metadata_text_test.dart`: the row, and the row count now follows the contract, 11 → 12). **Local real samples:** the DNG crop sizes (checked against an independent Python walk, deleted), and the JPEG/HEIC portrait sizes, were added to `expected.json` outside Git and pass. Each DNG reads 856 bytes (+8). CALC-39, F-45, ARCHITECTURE B, ADR-017/018 status updated. Gate green, 1082 + 1 skip + 2 E2E |

| 3 | S3.2 — Equipment evidence and candidate, with CALC-40 (ADR-018 §4) | 2026-09-26 | **`7560df2`** (the content) and `e9a9d87` (empty) | **Where it landed:** the concurrent TD-066 session committed the shared index while S3.2's files were staged, so S3.2's code, tests and docs are in `7560df2` ("fix: format short exposures as shutter fractions"). `e9a9d87` carries the S3.2 message with no changes. No history was rewritten; the content was checked to be complete in HEAD. Pure domain code in `lib/domain/equipment_import/`, with no UI and no write. `EquipmentCandidate.fromReading`: per field, `ProposedField` (value, source `metadata:<format>` or `derived:calc-40/metadata:<format>`, `reported`/`estimated`, origins) or `UnknownField` (not in file, unreadable, conflicting, out of range, not estimable, never from metadata). Labels come from Make/Model; resolution uses the long side as the width; the aperture diameter, rotation, tracking and maximum exposure are never proposed; the RAW size waits for S3.8. It also carries a suggested name, `EquipmentEvidence` for S3.3, and `hasEnoughEvidence`. `SensorGeometryEstimate` is CALC-40, registered in `SCIENTIFIC_INTEGRITY.md`. As the ADR requires, there is no estimate when f₃₅ ≤ f, so full-frame bodies get none. 11 tests, with expected values computed independently. **Concurrent work noticed:** another session committed `23b962c` (the owner's debug-build metadata viewer) during this Task, and left TD-066 edits uncommitted; S3.2 commits only its own changes. Gate green |

| 3 | S3.4 — Per-field provenance and identity evidence, schema v18 (ADR-018 §5) | 2026-09-26 | `1af68e4` | 14 additive nullable columns: source/confidence pairs for resolution, pixel pitch, sensor size and RAW size, plus `metadata_make` and `metadata_model`, on `camera_modules`; pairs for focal length and focal ratio on `optical_rigs`. Nothing is back-filled. The Drift workflow was followed (v18 snapshot, generated verification and steps; `from17To18` against the step's shapes). Domain: `EquipmentSpec` and `SpecProvenance`; `EquipmentProfile.specProvenance`, `metadataMake/Model` and `provenanceOf` (own pair → group → unknown); `withEditProvenance` per field, which pins the group's old provenance on untouched specs when their group changes (a verified value stays verified), keeps given pairs, and keeps the identity. The repository maps the new columns. The manual editor is unchanged (its tests are not modified). 21 new tests: every version v8–v17 → v18 against the snapshot; v17 → v18 keeps values and group provenance with no own pairs; a legacy rig stays unknown; 8 domain rules; a repository round-trip through a manual edit. **Four existing tests changed** only because they hardcoded the current schema: the backup header now expects 18, and the "newer than the app" example is 19. Session snapshots keep only group provenance. Gate green, 1115 + 1 skip + 2 E2E |

| 3 | S3.3 — Matching saved rigs, with conflicts (ADR-018 §6) | 2026-09-26 | `0e5b93e` | `EquipmentMatcher` is pure domain code with no write. It gives six outcomes (`MatchKind`) with `MatchReason`s, per-field `FieldConflict`s (both provenances; `savedIsVerified`) and `fillable` unknown specs. The stored import identity wins over the labels; comparison is normalised; the prefix rule uses `/`, space, `-` and `_`; f and N use a 1 % tolerance. The capture mode differs when the pixel count differs, or when the file's f₃₅ is more than 10 % from the one the rig implies (f × 43.27 ÷ the sensor diagonal; recorded as an S3.3 implementation choice in ADR-018's note, with the "Pro Max" prefix limit and the no-model rule). 15 tests, one per scenario: none; same; likely (DNG vs JPEG); normalised labels; the stored identity over renamed labels; makes; two identical bodies (ambiguous); the other phone module; a telescope body; digital zoom; a full-resolution mode; the tolerance; verified vs legacy conflicts; the seeded camera. Gate green, 1130 + 1 skip + 2 E2E |

| 3 | S3.5 — A form model for the rig editor, and pre-fill | 2026-09-26 | `9675854` | The editor's value building moved into the pure `EquipmentDraft` (`presentation/shared/equipment_draft.dart`): `fromProfile` (Add/Edit, as before), `fromCandidate` (file values, the CALC-40 estimate, or a saved rig's camera specs as `cameraFrom`), and `build` (the Save logic, moved unchanged, plus per-field provenance: a pre-filled value keeps its origin only while its text is untouched). The dialog moved from the 791-line screen into `showEquipmentEditor` (`equipment_editor.dart`, 578 lines; the screen is now 218). It shows a note under each pre-filled field; D, tracking, rotation and maximum exposure are never pre-filled. The 10 existing editor tests pass unmodified. 13 new tests: 8 form-model tests and 5 widget tests (notes shown and cleared; saved untouched keeps its origin and identity; edited pixel size and derived sensor become the user's; Cancel writes nothing; missing values block Save). `phoneCandidate` in `test/support/metadata_candidates.dart`. No entry point yet (S3.6/S3.7). Gate green, 1143 + 1 skip + 2 E2E |

| 3 | S3.6 — The import review and confirmation flow (ADR-018 §2, §6) | 2026-09-26 | `f230e6b` | `MetadataImportViewModel` now takes the `EquipmentRepository`: after a read it builds the candidate, matches it, keeps the per-field "use the file's value" choices (off by default), and gives drafts (`newRigDraft(cameraFrom:)`, `rigDraft` via the new `EquipmentDraft.forRig`). The screen gains an Equipment card above the file's values: the outcome in plain words, the reasons, conflict switches, Open / New rig / New rig with a saved rig's camera specs. Every action goes through `showEquipmentEditor`, whose Save is the only write; the match refreshes after a save, and the planner rereads an edited rig. Wording is in `equipment_import_text.dart`. Fix: an untouched sensor field now compares with the rig's stored value, not the draft's first text (needed once a file value is taken). 7 review tests (a new rig only through Save, then matched; Cancel writes nothing; same rig keeps verified values by default and creates no duplicate; a taken value arrives with its origin; another module takes the saved camera; ambiguous; no evidence proposes nothing). The accessibility sweep now includes the review, with a file matching the seeded rig (light, dark, field; 100/200 %). `InMemoryEquipmentRepository` and `PlannerHarness(captureFiles:)` are in `test/support`. Still debug-only (S3.7). The owner's phone was connected but was not needed; nothing was installed. Gate green, 1150 + 1 skip + 2 E2E |

| 3 | S3.8 — Average RAW size from a DNG pick (ADR-018 §4, D4; C-13) | 2026-09-26 | `d21a326` | `EquipmentCandidate.fromReading(read, fileLengthBytes:)`; the ViewModel passes `MetadataSource.length` (the file is still never read whole). Only for a DNG: bytes ÷ 10⁶ = MB, `estimated`, source `metadata:dng:file-size`, `EquipmentLimits.rawFileSizeMB` bounds (outside is unknown, out of range). `rigDraft` pre-fills it on a matched rig that lacks one; the review says "Average RAW file size is unknown on this rig; the file suggests …". A saved value is only an ordinary conflict, kept by default. The editor note reads "Estimated from this one file's size (DNG)". 9 tests: DNG / JPEG / HEIC / no length / out of range; matcher fillable vs conflict; draft note; review fill-through-Save, keep-by-default, JPEG never. Gate green, 1159 + 1 skip + 2 E2E |

| 3 | S3.7 — Visibility, TD-066, the device check M4 (ADR-018 §7; RD-16) | 2026-09-26 | `2b045eb` | `FeatureScope.metadataImport` = true. `AppRouter.metadata` is the root route `/equipment/import` (was `/settings/metadata`, debug-only), and the Settings entry is removed. "Add from a photo" is a small button above "Add rig" on the equipment screen; the list and the planner's rig reload on return. The screen is retitled "Add from a photo", and its intro says nothing is saved until Save. Privacy policy and Data Safety notes gained a paragraph (nothing leaves the device; still "not collected"). TD-066 verified (host tests, and "≈1/50 s" on the device). Tests: a navigation test; Settings has no entry; the gate/route tests updated to the new route; 7 editor tests now tap "Add rig" by tooltip, since there are two buttons. **Device check M4 passed** on the owner's Xiaomi 14T Pro through a separate `.s2check` package (local build change reverted; uninstalled afterwards; the owner's app untouched, its install times 20:00/20:28 predate the check): a real DNG went through match → pre-filled editor (source notes, RAW size from one file, no D or tracking) → Save → "You already have this rig" → listed; the cache stayed 4 KB. **Found:** TD-068 (rounding conflicts on re-read; S3.9 proposed) and TD-069 (clipped sensor fields; Stage 5/7). Gate green, 1161 + 1 skip + 2 E2E |

| 3 | S3.9 — No rounding conflicts on re-reading an imported file (TD-068) | 2026-09-26 | `3f54432` | Owner: "fix the existing issues…" (E.1, "Stage 3 fixes before validation"). The candidate proposes estimates at the editor's stored precision, with one set of constants for both (`EquipmentCandidate.sensorDecimals`/`pixelPitchDecimals`/`rawSizeDecimals`: 0.01 mm, 0.001 µm, 0.1 MB); plausibility is checked before rounding (a 0.05 MB file stays out of range — caught by the existing test when a first version rounded first). Regression tests (`equipment_import_round_trip_test.dart`): a rig saved from a file through the real form model matches it with no differences (the M4 main DNG, the telephoto, a portrait JPEG), and a user-typed value is still a difference. All four failed before the fix. Five expectations updated to the rounded proposals (the unrounded CALC-40 values stay tested in the estimator's group). CALC-40 row noted; TD-068 resolved. Gate green, 1165 + 1 skip + 2 E2E |

| 3 | S3.10 — The editor readable on a phone (TD-069) | 2026-09-26 | `387e54b` | Owner-approved (E.1, "Stage 3 fixes before validation"). `equipment_editor_fit_test.dart` reproduces the device on a 375 dp view with Roboto loaded (the test font draws a full em per character): at 100 %, "9.89" needed 36 dp in an 18 dp box, exactly as on the phone. Fix: each W × H row's label moved above its fields. The same test at 130 % found the Tracking dropdown overflowing (present before Stage 3): now `isExpanded`. 4 tests (two drafts × 100/130 %); all failed before. Existing editor tests unchanged. Gate green, 1169 + 1 skip + 2 E2E |

| 3 | Independent Stage 3 validation (FAIL) | 2026-09-26 | `7f790df` | Committed as written by the owner's validation: S3V-01–S3V-06 blocking, S3V-07 non-blocking, S3V-08 unverified. Before committing, this session re-ran the archived probes at `387e54b`: 7 failures (P1–P5, P7, P8) and P6 passing, as reported |
| 3 | S3.V1 — A stale review never reverts newer rig edits (S3V-01) | 2026-09-26 | `62a79af` | Owner-approved (E.1, "Stage 3 validation failed: corrective Tasks"). The review is re-matched against the saved rigs when shown (post-frame) and right before Open or "New rig with the camera specs" (`currentMatchFor`). A "use the file's value" choice stores the saved value it was made against and is withdrawn if that value changed or the rig is gone; a deleted or no-longer-matching rig is not opened (a snackbar says so). 4 regression tests through real routes, real screens and SQLite (`metadata_import_stale_review_test.dart`): the validation's P8 sequence, a change while the review stays open, a withdrawn choice (then a fresh explicit choice does replace), and a deleted rig. All 4 failed before the fix. Gate green, 1173 + 1 skip + 2 E2E |

| 3 | S3.V2 — Untouched legacy values keep unknown provenance (S3V-02) | 2026-09-27 | `edbb2a7` | `SpecProvenance.unknown` (own pair, source `unknown`, no confidence) reads as unknown before any group fallback. It is pinned on untouched fields of an edited group whose old provenance was unknown, and kept for values copied from a legacy rig (it was dropped before, so the new rig's `user` group covered it). No schema change; ADR-018 implementation note. Regression tests through the real Drift repository with rereads (`equipment_provenance_persistence_test.dart`): the validation's P2 (edit one legacy field) and P1 (copy legacy camera specs) failed before the fix; a copied value then edited becomes the user's; a rig typed by hand stays wholly the user's (control). One existing test, which the validation named as encoding the defect (`equipment_provenance_test.dart`, untouched legacy field read as `user`), was corrected to the contract with a note. Gate green, 1177 + 1 skip + 2 E2E |

| 3 | S3.V3 — Numeric fidelity (S3V-03, S3V-04) | 2026-09-27 | `18873ad` | `PrefilledSpec.values` carries the exact numbers behind pre-filled texts; `EquipmentDraft.build` saves them while the texts are unchanged (before the stored-sensor rule and before parsing). Copied pixel and RAW sizes display unrounded; the sensor display stays at 2 decimals (display-only). Regression tests through the real Drift repository with rereads (`equipment_numeric_fidelity_test.dart`): the validation's P3 (a chosen file sensor size applies the file's value, and the difference disappears) and P4 (copied 9.894 mm, 2.414123 µm and 30.04 MB stay exact and verified) failed before the fix, with a copied-then-retyped case; controls: estimates stay rounded, and an untouched open-and-save of a saved rig stays exact. No existing test changed. Gate green, 1182 + 1 skip + 2 E2E |

| 3 | S3.V4 — Absurd image dimensions are unparseable (S3V-05) | 2026-09-27 | `2447962` | `ExifValues.dimensions` rejects a side over `maxImageSidePx` = 65,535 (JPEG's format limit; a metadata sanity bound, deliberately wider than `EquipmentLimits.resolutionPx`); the shared conversion covers DNG IFD0 and DefaultCropSize, JPEG and HEIC. 4 regression tests in `image_dimensions_test.dart`: the validation's P7 (4,294,967,295 × 4,294,967,295 JPEG EXIF), a DNG width and crop over the bound, a HEIC side over it, and the boundary (65,535 known, 65,536 not); all failed before the fix. CALC-39 and an ADR-018 note updated. The local real samples still give their expected dimensions. Gate green, 1186 + 1 skip + 2 E2E |

| 3 | S3.V5 — Real-database review coverage and stale wording (S3V-06, S3V-07) | 2026-09-27 | `51f53cf` | `metadata_import_review_db_test.dart` runs S3.6's acceptance through the real screens and routes with a real in-memory SQLite database (only the file picker is fake), counting rows in `devices`, `camera_modules` and `optical_rigs`. The cases: Cancel at every step writes nothing (picker, leaving the review, Cancel in each editor); a new rig is written once, only by Save, then matched, with no duplicate on Open and Save; a difference is kept by default, a verified value survives, and only an explicit choice replaces it; another module adds a rig with the saved camera specs; navigation and re-entry. These are acceptance tests for behaviour already fixed by S3.V1–S3.V3 (S3V-06 was a coverage gap), so they pass; nothing to reproduce first. The list-fake tests are kept. S3V-07: the debug-only visibility wording in ADR-018 §7, the two `PROGRESS.md` amendments and F-45's "current visibility" bullet are marked superseded by S3.7, with their text kept verbatim. **Archived probes re-run (`evidence/STAGE_3_VALIDATION_PROBES.md`, recreated then deleted): P1–P4 and P6–P10 pass; P5 still fails (45 → 30.04 MB).** P5 calls `vm.rigDraft(vm.match!.rigs.single)` on a match kept from before an external edit, with no refresh. S3.V1 closed the screen paths (refresh on entry and before Open; P8 passes) but not this ViewModel API. Recorded; not fixed here (outside S3.V5's scope). Gate green, 1191 + 1 skip + 2 E2E |

| 3 | S3.V6 — No stale drafts from the import ViewModel (S3V-01, ViewModel level) | 2026-09-27 | `d5e2b60` | Owner-approved after S3.V5's probe re-run found P5 failing. `rigDraft(rigId)` and `newRigDraftWithCameraOf(rigId)` are async and read the saved rigs again before building a draft (the match lookup is now private); they return null for a rig deleted or no longer matching. The synchronous `rigDraft(RigMatch)` and `newRigDraft(cameraFrom:)` are gone, so no caller can build from a stale match. The screen calls the new methods. `metadata_import_viewmodel_stale_test.dart` (real Drift): P5 restated against the new API, a fresh camera copy, a withdrawn choice, a deleted rig; it could not compile against the old API, and the archived P5 failed on it. **All archived probes re-run: P1–P10 pass** (P5 with its one call restated; the evidence file unchanged). Gate green, 1195 + 1 skip + 2 E2E |

| 3 | S3.V7 — Per-field provenance in the rig editor; no invented `user` in new snapshots (S3S-01, TD-070) | 2026-09-27 | `1166986` | Owner-approved with a Stage-boundary adjustment (E.1). `EquipmentProfile.groupProvenance` lists a group's valued specs with `provenanceOf` (the RAW size only when set); `sharedProvenance` is the one they all have, else null. The editor's provenance line (keyed `editor.provenance`) gives one phrase for a group that shares a provenance, else one per spec; it never shows the group pair alone. `SessionSnapshotBuilder` writes a group's source/confidence only when shared, else null (snapshot `"v": 1` and export unchanged). Regression tests first (they failed before the fix): `equipment_shared_provenance_test.dart` (6), `equipment_editor_provenance_test.dart` (4: imported, hand-typed unchanged, edited verified seed, edited legacy), and 3 snapshot cases in `session_snapshot_builder_test.dart`. Existing tests unchanged. Deferred to Stage 8: per-field snapshot provenance and snapshots already saved. Gate green, 1208 + 1 skip + 2 E2E |

| 3 | S3.V8 — No camera-spec copy across pixel counts (S3S-02, TD-071, SI-014) | 2026-09-27 | `92ebf2a`* | Owner-approved, option (a) (E.1). `EquipmentDraft.fromCandidate(c, cameraFrom:)` does not copy the saved rig's pixel size or sensor size when the file's pixel dimensions are known and differ from its resolution (`EquipmentMatcher.samePixelCount`, orientation-free, also used by the mode check). It records them in `withheldFromSavedRig`, and the editor shows `PrefillText.withheld` (keyed `editor.withheld`) while the pixel field is empty. Resolution and RAW size fallbacks, the file's own values and estimates, and the equal-count copy are unchanged. Regression tests first (they failed before the fix, the real-database one with the saved 1.25 µm copied): `equipment_camera_copy_mode_test.dart` (5), and one real-database case in `metadata_import_review_db_test.dart` (Save waits for the user's pixel size; then one new chain; the saved rig unchanged). `phoneCandidate` in `test/support` gained `dims` and `focalLengthMm` parameters (defaults unchanged). Existing tests unchanged. Gate green, 1214 + 1 skip + 2 E2E |

| 3 | Stage 3 final sign-off, fresh session (validation and closeout documentation only) | 2026-09-27 | `126d97f`\*\* | **PASS** at `92ebf2a`; Stage 3 closed. Gate green (1214 + 1 skip + 2 E2E); targeted Stage 3 suites 352 + 1 skip; real samples, 4 native JVM tests; archived probes re-run (F1b and F3 now fail, as their defects are fixed); 13 new probes. S3S-01 and S3S-02 resolved; S3F-01 (TD-072 addendum) and S3F-02 (TD-071 note) non-blocking; S3V-08 unverified. See `STAGE_3_FINAL_SIGNOFF.md` |

| 4 | Stage 4 planning (documentation only) | 2026-09-27 | `2a26185` | Every Stage 4 input re-verified at `126d97f` (none stale). Frozen: S4.R1–S4.R5, S4.D, S4.T; S4.E optional. Owner: the recommended option on each planning question (E.1, "Stage 3 closed; Stage 4 planning decisions"). `POST_ROADMAP_PLAN.md`, "Stage 4 — frozen Task sequence" |

| 4 | S4.R1 — Flow inventory and question matrix (research, documentation only) | 2026-09-27 | `e5fd240` | `research/S4.R1_FLOW_INVENTORY.md` at `2a26185`: routes against the wireframes, every session action, states per screen, 16 re-measured tap counts, a 22 + 18 row question matrix, owner clarifications O1–O4, the S4.E script. Key RG-04 input: a result can be recorded only through Start |

| 4 | S4.R2 — RG-04 research: Execution's role and post-session results (documentation only) | 2026-09-27 | `97ffab5` | `research/RG-04_EXECUTION_ROLE.md` at `e5fd240`: evidence kept apart; capabilities C1–C12; G1–G3 × A–D; recommended B + G2; D1–D4 for the owner. S4.R1 §6.1 records the owner's O1–O4 answers |

| 4 | RG-04 decided (the owner's D1–D4; documentation only) | 2026-09-27 | `abca03d` | D1 = B, D2 = G2, D3 and D4 as recommended (E.1, "RG-04 decided"). Recorded in the research's §12, `PRODUCT_DIRECTION.md` §4 and the RG register. ADR changes are left to S4.D |

| 4 | S4.R3 — Session lifecycle research (documentation only) | 2026-09-27 | `989a61e` | `research/S4.R3_SESSION_LIFECYCLE.md`: verified lifecycle, the roll-forward conflict with RG-04, options L0–L2, n1–n3, U1–U2, Y1–Y3, the defaults; low-fi flows |

| 4 | RD-05 and RD-04 decided (the owner's E1–E4; documentation only) | 2026-09-27 | `8600a39` | L1, Y2, no preselection with an empty plan and "Start from the example plan", U1 (E.1). Recorded in the research's §11, `PRODUCT_DIRECTION.md` §10 and the RD register |

| 4 | S4.R4 — Tonight and planner research (documentation only) | 2026-09-27 | `8578ab8` | `research/RG-05_06_TONIGHT_AND_PLANNER.md`: current structure, measurements, binding rules, a visible vs one-tap-away rule, options T1–T2, D-a–D-c, P-0–P-2, M0–M2, low-fi wireframes |

| 4 | RG-05, RD-06 and RG-06 decided (the owner's F1–F4; documentation only) | 2026-09-27 | `0506b04` | T1, D-b, P-1 (amends ADR-015 §2), M0 (ADR-009 §2's "own line" within the budget details); no modes (E.1). Recorded in the research's §11, `PRODUCT_DIRECTION.md` §10 and the registers |

| 4 | S4.R5 — Library and vocabulary research (documentation only) | 2026-09-27 | `160ee37` | `research/S4.R5_LIBRARY_AND_VOCABULARY.md`: the Library's current behaviour (TD-053), a string inventory, options LB1–LB3 and PR1–PR2, naming principles, a glossary |

| 4 | RD-07 and RD-14 decided (the owner's H1–H4; documentation only) | 2026-09-27 | `28857d8` | LB1 + PR2; Rig; Plan + Logbook; the glossary as proposed (E.1). Recorded in the research's §9, `PRODUCT_DIRECTION.md` §10 and the RD register. Every Stage 4 gate is decided |

| 4 | S4.D — ADR-019 and the wireframe addendum (decision record, documentation only) | 2026-09-27 | `f68e576` | ADR-019 accepted by the owner; it amends ADR-009 §2 (display), ADR-014 §3, ADR-015 §2/route map/§7, ADR-016. `docs/IA_WIREFRAMES_ADDENDUM.md`; DEV-P9 (UX-04, UX-11); ARCHITECTURE D5; S4.R1 §9 answers |

| 4 | S4.T — the decisions as provisional Tasks for Stages 5–9 (planning, documentation only) | 2026-09-27 | `adb5d95`\*\*\* | P5.1–P5.6, P6.0–P6.7, P8.1–P8.6 and P9.1–P9.2 (not frozen), with the order across Stages; §6.2 rows updated. Every Stage 4 Task is done |

\* A file cannot contain its own commit hash; S3.V8's (`92ebf2a`) was recorded by the Stage 3
final sign-off.
\*\* Likewise for the sign-off (`126d97f`), recorded by Stage 4 planning.
\*\*\* Likewise for S4.T (`adb5d95`), recorded by the Stage 4 revalidation.

## Relevant commits

- `becae04`: the last roadmap commit (TASK 16.3 documentation, 2026-09-24). Audits 01–07 were
  captured against it.
- `652ad80`: Stage 0, the refinement baseline.
- `1ec6e7a`: Stage 1 planning (the frozen sequence).
- `6a90347`: S1.1.
- `c449c03`: S1.2.
- `2007dc5`: S1.3.
- `db2702f`: S1.4.
- `07d55e2`: S1.5.
- `c0bfcb7`: S1.6.
- `20eff0e`: S1.7.
- `b03dda9`: S1.8.
- `705b764`: S1.9.
- `642b235`: S1.10.
- `b0998c6`: S1.11.
- `b6fb6c3`: S1.12.
- `f179013`: S1.13.
- `28aaa10`: S1.14 (deferred).
- `4e653fb`: S1.15.
- `723fd44`: same-session Stage 1 validation (preserved below).
- `db94aaf`: independent Stage 1 validation.
- `953c0d1`: S1.16 and S1.17.
- `3067658`, `b34c9ad`, `ed628f8`, `ea65231`: S1.V1–S1.V4.
- `c99bd7f`: the same-session re-check.
- `39392d9`: the repeat independent Stage 1 validation.
- The Stage 1 closure and Stage 2 planning: see the note under "Completed Tasks".

## Validation status

- **Stage 5 baseline**, 2026-09-27, at `38925dd`: the quality gate **PASS** (Encoding; Format,
  376 files, 0 changed; Analyze; 1,214 tests, 1 expected skip; 2 host E2E). The Stage 5 validation
  (fresh session, implementation model) comes after S5.9.
- **Final, bounded Stage 4 validation**, 2026-09-27, at `09a7f06`: **PASS**
  (`STAGE_4_FINAL_VALIDATION.md`). Stage 4 is closed.
  - The seven owner-frozen questions all pass.
  - Nothing blocks: the S4-DEF items are deferred, and S4V-02, S4V-03 and one observation are
    recorded.
  - Run in the authoring session at the owner's request (disclosed).
  - The code is unchanged since `92ebf2a`, and the gate at `5ad69c4` applies.

- **S4.V3 task self-review**, 2026-09-27. Documentation and governance only.
  - Searched the current documents (DECISIONS, ARCHITECTURE, the addendum, the plan,
    PRODUCT_DIRECTION, TECH_DEBT, the research notes) for S4.V2's inferred rules. They remain only
    in S4.V2's matrix, which is labelled superseded and non-normative. ADR-007's own solar-noon text
    is unrelated.
  - `git diff --check` passed. The code is unchanged, so the gate at `5ad69c4` still applies.
  - This is not a Stage validation.

- **S4.V2 task self-review**, 2026-09-27. Documentation only.
  - Every current document that stated S4.V1's Review → Save → result guard or its Stage 6/8 split
    was rewritten or marked superseded (searched: DECISIONS, ARCHITECTURE, the addendum, the plan,
    PRODUCT_DIRECTION, TECH_DEBT and the research notes).
  - The S4.V1 matrix and E.1 entry are kept, labelled superseded.
  - `git diff --check` passed.
  - The code is unchanged, so the gate at `5ad69c4` (1,214 tests, 1 skip, 2 host E2E) still
    applies.
  - This is not independent Stage revalidation.

- **Stage 4 revalidation (fresh session)**, 2026-09-27, at `5ad69c4`: **FAIL**
  (`STAGE_4_REVALIDATION.md`).
  - **Resolved:** S4V-01, as reported. The claims were checked against the code:
    - `updatePlan` keeps `plannedAtUtc` and the snapshot;
    - the snapshot stores the night's bounds, zone and blocks;
    - Save needs a site;
    - a night ends at the next mean solar noon.
  - **Blocking:**
    - S4R-01: a result for Saved · changed follows the re-saved working night or site;
    - S4R-02: the Stage 6/8 delivery split resumes last night's plan as current, against E2 and
      E.1.
  - **Low:** S4R-03 (TD-057's direction), S4R-04 (§3.1 has no acceptance record).
  - **Carried:** S4V-02 (now also Test A); S4V-03 unverified.
  - **Gate: PASS**, exit 0 (Encoding; Format, 376 files, 0 changed; Analyze; 1,214 tests, 1
    expected skip; 2 host E2E).
  - No probe; no code, test or design document changed.

- **S4.V1 task self-review**, 2026-09-27: the ten-case specification matrix covers saved states,
  startup/live rollover, snapshot/working-date differences, explicit review, result cancellation,
  stale edits and storage failure. Only documentation changed. Encoding and `git diff --check`
  **passed**. The existing-code full gate passed at `adb5d95` (1,214 tests,
  1 expected skip, 2 host E2E); no code changed since, so it is not rerun for this correction.
  This is not independent Stage revalidation.

- **Stage 4 independent validation**, 2026-09-27, at `adb5d95`: **FAIL**
  (`STAGE_4_VALIDATION.md`). One blocking specification gap (S4V-01); one optional-script issue
  (S4V-02); human/device usability unverified (S4V-03). No production changes since `92ebf2a`.
  - Full gate re-run: **PASS**, exit 0; Encoding; Format (376 files, 0 changed); Analyze (no
    issues); **1,214 tests, 1 expected local-sample skip; 2 host E2E**. Passing existing-code
    tests does not resolve the future lifecycle specification gap.

- **Stage 4 planning**, 2026-09-27, at `126d97f`: documentation only; every Stage 4 input
  re-verified against the code (none stale). No code changed, so the gate result at `92ebf2a`
  still applies.

- **Stage 3 final sign-off (fresh session)**, 2026-09-27, at `92ebf2a`: **PASS**
  (`STAGE_3_FINAL_SIGNOFF.md`). Stage 3 closed.
  - Passed: the gate (Encoding; Format, 376 files, 0 changed; Analyze; 1,214 tests, 1 expected
    skip; 2 host E2E); the targeted Stage 3 suites (352, 1 skip); the real samples; the 4 native
    JVM tests; every archived probe that asserts required behaviour; 13 new probes.
  - Resolved: S3V-01 to S3V-07, S3S-01, S3S-02.
  - Non-blocking: S3F-01, S3F-02; S3S-03 deferred.
  - Unverified: S3V-08 (device). Nothing is claimed as device verified.
  - Validation only: no application, test or dependency change; the probe files were removed.

- **Fresh-session Stage 3 sign-off**, 2026-09-27, at `74026ca`: **FAIL**
  (`STAGE_3_SIGNOFF_VALIDATION.md`).
  - Passed: the gate (Encoding; Format; Analyze; 1,195 tests, 1 expected skip; 2 host E2E); the
    real samples; the 4 native JVM tests; two positive probes.
  - Failed: S3S-01 and S3S-02 (blocking).
  - Low: S3S-03.
  - Validation only: no application, test or dependency change; the probe file was removed.

- **Stage 3 second planning pass**, 2026-09-26, at `0c4848b`: documentation only; the gate re-run
  green (Encoding; Format; Analyze; 1068 tests, 1 expected skip; 2 host E2E), and the local
  real-sample test passes (DNG 848/848, JPEG 843, HEIC 4,051 bytes).

- **Stage 2 closure**, 2026-09-26: by owner waiver after S2.V4/S2.V5, not by an independent
  pass (E.1). **Stage 3 planning**: documentation only, and the gate result at `d8e792c` still
  applies (no code changed since).

- **S2.V4/S2.V5 implementation verification**, 2026-09-26: Encoding; Format (349 files, 0 changed); Analyze (no issues); 1068 tests with 1 expected local-sample skip; 2 host E2E. The targeted metadata
  suites give 98 passed and 1 expected skip; the new bound tests fail on the old reader; the
  real samples are unchanged. This is self-verification, not independent Stage acceptance.

- **Repeat independent Stage 2 validation**, 2026-09-26, at `5d8bdbb`: **FAIL**
  (`STAGE_2_REVALIDATION.md`).
  - Passed:
    - the gate is green on the clean tree (Encoding; Format, 349 files, 0 changed; Analyze; 1062 tests, 1 expected local-sample skip; 2 host E2E);
    - the local real-sample test passes;
    - the 4 native JVM tests pass, re-run;
    - no test was weakened since `79f392c`.
  - Failed: S2R-01 (blocking, TD-067).
  - Low: S2R-02 (needs an owner ruling), S2R-03 and S2R-04.
  - No application, test or dependency change.

- **S2.V1–S2.V3 implementation verification**, 2026-09-26: full gate green
  (1052 tests, 1 expected skip, 2 host E2E); 4 native JVM tests pass; all three
  external samples pass unchanged; the two original failing semantic probes
  now pass. This supersedes the code failures below, not the independent Stage
  verdict or its unfinished research/decision gates.

- **Stage 2 independent validation**, 2026-09-26, at `79f392c`: **FAIL**.
  See `STAGE_2_VALIDATION.md` and `evidence/STAGE_2_VALIDATION_PROBES.md`.
  The full gate passes (1042 tests, 1 expected skip, 2 host E2E); the external
  real-sample test also passes (two DNGs and one JPEG). Two additional
  malformed-input acceptance probes fail (S2V-01 and S2V-02). S2V-03 records
  the non-seekable accounting/test gap; S2V-04 records the still-open S2.9
  disposition and S2.R3 gate. S2V-05 through S2V-08 distinguish documentation
  debt, unverified device paths, existing display debt and rejected concerns.
  No implementation or existing tests changed. The Stage remains in progress;
  proposed corrective Tasks in the report do not constitute owner approval.

- **Stage 0**, checked 2026-09-25 against the Stage 0 prompt's §22 review list:
  1. the three refinement documents were re-read;
  2. none claims metadata extraction is implemented (a gated prototype is recorded as
     non-production);
  3. metadata → equipment import is a separate Stage (3) after the metadata foundation (2);
  4. research hypotheses are gates (RG) or decisions (RD), not approved implementation;
  5. Execution is preserved as a supporting workflow, with its role pending Stage 4;
  6. the scientific-integrity principles are restated unchanged (`PRODUCT_DIRECTION.md` §6);
  7. no deferred or rejected feature became approved; each can return only through its gate
     and an owner decision (`PRODUCT_DIRECTION.md` §8);
  8. every section of 08 has a home (`POST_ROADMAP_PLAN.md` Appendix A);
  9. the Final Audit's confirmed engineering, scientific and runtime issues (07 §2, §3, §4.1)
     are all in Stage 1, RT-05/UX-12 as a decision checkpoint (`POST_ROADMAP_PLAN.md` §6.1);
  10. no application code changed (only `CLAUDE.md` and files under `docs/` are in the
      commit).

  The quality gate was green on the unchanged code.
- **Stage 1 planning**, 2026-09-25: every A–F candidate was re-verified against `652ad80`, and
  every mechanism still exists (none stale). Seven planning-time findings were placed into
  Tasks (`POST_ROADMAP_PLAN.md`, Stage 1 frozen sequence). Documentation only; no code
  changed, so the Stage 0 gate result still applies.
- **Stage 1 closure**, 2026-09-26: by owner decision after a failed validation (a waiver,
  not a pass; DECISIONS E.1).
- **S2.R1**, 2026-09-26: research only. Throwaway probes (scratchpad Python, and
  `tool/zz_probe_*.dart`) were deleted; no code, test or dependency changed. The gate result
  at `c99bd7f` still applies.
- **Stage 2 planning**, 2026-09-26, at `39392d9`: documentation only; TD-018 re-verified. The
  gate result at `c99bd7f` still applies (no code changed since).
- **Repeat independent Stage 1 validation**, 2026-09-26, against `c99bd7f`: **does not pass**.
  - The gate is green (963 tests, 2 E2E).
  - The first validation's six probes are regression tests now, and they pass.
  - S1.V1–S1.V4, S1.16 and S1.17 meet their acceptance.
  - Surviving: TD-063 (P2; a reopen from a detail page loaded before Start) and X2 (the
    registers were not updated after S1.V1–S1.V4). Low: W1, confirmed (for RD-05).
  - No application or test source was changed. The probes are kept as a patch, which was
    applied, ran (1 failure, 2 observations) and was reversed.
  - Details: `STAGE_1_REVALIDATION.md`.
- **Independent Stage 1 validation**, 2026-09-25, against `4e653fb`: **does not pass**.
  The baseline gate independently passed (948 + 2 E2E); six additional probes
  fail across TD-059–TD-062. S1.5 misses refusal through the production background
  connection, and retained preferences can suppress reset seeding. S1.6 loses
  protection after target/night-only edits followed by restart and on reopening
  stale detail data for the current session. See `STAGE_1_VALIDATION.md` for the
  acceptance matrix, reproduction patch, limitations and proposed S1.V1–S1.V4.
  No application/test source changed. The other session committed `723fd44`
  during this validation; its result below is preserved as prior evidence, but
  its passing verdict is superseded by these reproductions. Its three unknown
  probe files were created by this independent validation, removed by their
  author, and retained as `evidence/STAGE_1_VALIDATION_PROBES.patch`; no owner
  cleanup action remains. **Stages 2–11:** not started.
- **Stage 1 Tasks (prior implementation record):** S1.1–S1.13 and S1.15 reported
  done (gate green); S1.5/S1.6 now require follow-up. S1.14 deferred by the owner.
- **Stage 1 validation**, 2026-09-25, at `4e653fb`. **Not independent:** the owner asked for it
  in the implementing session instead of a fresh one (§9.1 step 11). It tried to disprove
  completion; no fix was made.
  - Evidence: a fresh gate on the clean tree (Encoding, Format, Analyze pass; 948 tests; E2E
    2); every A–F item traced to its Task, commit and tests; no test assertion removed
    (four were updated to changed wording, with the new wording asserted); `lib/domain` has
    no `DateTime.now()`; ViewModels within the 300-line cap (300, 297, 271); no colour
    literals, data imports or hard-coded app name in the new presentation files; every
    commit hash in this file exists and matches its Task; `CurrentSession`'s ordering
    re-read (a failed Save or Start keeps changes unsaved; later edits queue behind them).
  - Owner decisions during the Stage were respected: S1.4's corrected rule, S1.5's
    no-reset for newer databases (ADR-008 §2), S1.14's deferral.
  - **Verdict: passed.** Every A–D item is fixed with a regression test, documented, or
    moved with the owner's approval; the gate is green. Three low findings, none a
    regression or a failure of a Stage 1 item:
    - **V1 (docs convention):** the living registers cite no commit for Stage 1 work: 0 of 13
      `S1.x` stamps in `FEATURE_STATUS.md` (and the same in `ARCHITECTURE.md`), and TD-047's
      "FULLY RESOLVED (S1.5)" (`CLAUDE.md` asks for date and commit). The hashes are only in
      this file. **Proposed S1.16** (docs, S): backfill the hashes from "Completed Tasks".
    - **V2 (test coverage vs S1.6's acceptance):** the "Discard unsaved changes?" dialog is
      checked for tap targets, labels, contrast and overflow in light and dark only; S1.6
      named the sweep, which also covers the field theme. **Proposed S1.17** (test, S): add
      the field theme (without contrast, as in the sweep).
    - **V3 (behaviour consistency, S1.6):** confirmed by a throwaway probe (deleted). A site
      change on a saved plan turns the stored session into a draft ("Planned, unsaved
      changes", still listed, so nothing is lost), but it is not counted as an unsaved change
      while the app runs, so New does not ask; after a restart the same session counts as
      unsaved. Whether a site change edits a saved plan is a product question: **proposed:
      record it under RD-05 (Stage 4)** rather than fix it now.
  - Observations, no action proposed: `formatBudgetDuration` and `OpportunityText.duration`
    remain as one-line wrappers over `QuantityText.duration` (one rule, S1.7 met in
    substance); `WeatherText.ago` ("3 h ago") truncates, a relative-age phrase outside
    UX-19's scope; S1.2's E3 test covers the unreadable read, not a failed write, like the
    other preference repositories.
  - **Found during validation (not a Stage 1 finding):** three untracked files appeared in
    the working tree while it ran, `test/data/database/stage1_recovery_probe_test.dart`,
    `test/presentation/shared/stage1_reopen_probe_test.dart` and
    `test/presentation/viewmodels/stage1_restart_probe_test.dart` (copies of Stage 1 tests,
    written 19:38–19:39). This session did not create them; another local session
    ("Stage 0 refinement baseline") is the likely author. They were left untouched and not
    committed; the owner decides. **Stages 2–11:** not started.

## Superseded "Next allowed action" entries (newest first)

*Superseded by the Stage 5 planning (kept as written):*

**Stage 5 — Design System Foundation: Stage planning**, in a fresh chat where practical (§9.1).
- Read Stage 5's section and its provisional Tasks P5.1–P5.6 (from ADR-019).
- Re-verify them against the code (§9.7).
- Identify gates: RD-09 (confirm or undo for destructive actions) is Stage 5's.
- Freeze a Task sequence with scope, acceptance and validation.
- Update the documents, commit, and STOP before implementation.

**Carried:**
- S4-DEF-01 to S4-DEF-08 (Stages 6 and 8);
- S4V-02 (correct the S4.E script before Test A or C runs on the owner's install);
- the earlier carried items below.

*Superseded by the Stage 4 closure (kept as written):*

**The final, bounded, fresh-session Stage 4 validation** (plan, "S4.V3 — Bounded final
validation"; `CLAUDE.md`, "Validation Rules"; E.1, "Bounded validation for analysis and decision
Stages").

**It answers only whether:**
1. S4.R1–S4.R5 were completed;
2. every research gate required by Stage 4 has an explicit owner decision;
3. ADR-019 faithfully represents those approved decisions;
4. the wireframe addendum is consistent with ADR-019;
5. S4.T maps the approved design into the appropriate later implementation Stages;
6. the documents contain no direct contradiction that makes an approved core flow impossible;
7. no Stage 4 acceptance criterion remains unmet.

**Blocking and outcome:**
- **BLOCKING:** only a direct contradiction with an approved owner decision or an explicit Stage 4
  acceptance criterion.
- **Not blocking:** S4-DEF-01 to S4-DEF-08 and any other open implementation detail. These are
  `DEFERRED / IMPLEMENTATION DECISION`.
- **No new requirements:** the validation creates none.
- **If it passes:** close Stage 4 and set Stage 5 (Design System Foundation, planning) as the next
  allowed action.
- **If it fails:** name the exact decision or criterion contradicted, with evidence. Do not expand
  Stage 4.

S4.E remains optional. S4V-02 must be corrected before Test A or Test C runs on the owner's
install, but it does not block Stage 4.

*Superseded by S4.V3 (kept as written):*

**Fresh-session Stage 4 revalidation after S4.V2** (§9.8).
- **Check ADR-019 §3.1 as revised against the owner's invariant and R2 + D1** (E.1, "S4R-01 and
  S4R-02 decided"):
  - no path changes a saved snapshot, or moves it to another night, except "Save again" for the
    same night;
  - results are recorded against the snapshot without Save plan, and not before the night ends;
  - the working copy is never forced through a guard;
  - Stage 6 leaves saved plans as today, and Stage 8 delivers the saved night and the working copy
    together.
- **Challenge the derived rules** listed in that entry.
- **Check consistency:**
  - the ADR-014 pointer, D5, the addendum and the research notes;
  - P6.1, P6.7, P8.1–P8.3, the S4.V2 matrix, "Order across Stages" and TD-057.
- **Recheck Stage 4's exit criteria.**

Stage 5 stays blocked until Stage 4 passes. S4.E remains optional. Correct S4V-02 before Test A or
Test C runs on the owner's install.

*Superseded by S4.V2 (kept as written):*

**Owner decisions for the Stage 4 revalidation's blocking findings** (`STAGE_4_REVALIDATION.md`):
- **S4R-01, the result rule for Saved · changed:**
  - **R1:** always record for the saved night and the saved version, with the edits kept as an
    unsaved copy;
  - **R2 (recommended):** keep Review → Save, but pin the review to the saved night and site;
    never record a night that has not ended; Not done needs no Save; do not force Save or Discard
    on tonight's continuation;
  - **R3:** another rule.
- **S4R-02, the delivery order:**
  - **D1 (recommended; E.1's order):** P6.7 covers only never-saved drafts and the candidates
    list; saved plans keep today's behaviour until P8.3 delivers the protection and the
    continuation together;
  - **D2:** the continuation moves into Stage 6;
  - **D3:** accept the interim explicitly.

Then **S4.V2** (documentation only) aligns:
- ADR-019 §3.1 and its status line (S4R-04);
- addendum §3.10, S4.R3 §12, RG-04 §13, D5 and the ADR-014 pointer;
- P6.7, P8.1–P8.3, the S4.V1 matrix and "Order across Stages";
- TD-057 (S4R-03) and E.1.

After that, a **fresh-session Stage 4 revalidation**. Stage 5 stays blocked until Stage 4 passes.
S4.E remains optional. Correct S4V-02 before Test A or Test C runs on the owner's install: both
change persisted session state.

The separate S3V-08 device recheck, if the owner wants it, is its own action through `.s2check`,
never the owner's installed app.

**Carried open items:**
- S3V-08: a device recheck of the corrected Stage 3 flow (unverified; separate);
- TD-072 (S3S-03, deferred by the owner) with its S3F-01 addendum; S3F-02 (a note on TD-071, no
  Task proposed);
- TD-070's remainder (per-field snapshot provenance; snapshots saved before S3.V7): Stage 8;
- W1 (proposed input to RD-05);
- TD-063 (Stage 8);
- TD-057 and TD-058;
- RD-17 (the push is deferred);
- the S1.5 and S1.11 device checks (Stage 11);
- S2V-06's device checks (a non-seekable provider; a real backup's preview cancel): the next
  time the phone is connected, or Stage 11;
- TD-066 resolved 2026-09-26 (fractional exposure presentation; see amendment above);
- the stale id-holding preferences after a reset, `editedSessionId` included (with
  TD-056/ENG-14).

## Stage 0 notes

Thirteen discrepancies between the prompt, the documents and the repository are recorded in
`POST_ROADMAP_PLAN.md` §1.3. Among them:
- the prompt's location (item 1);
- undocumented manual device use (item 2);
- the `chacha12`/`Buffur` identity (item 3, RD-01);
- the licence requirements against PD-12 (item 4, RG-12).


## Governance reconciliation snapshot - 2026-10-24

Historical source: complete `PROGRESS.md` from `94cebfb6b2a3379f5991e61e1bd88f7120804601`, before the governance cleanup. SHA-256 of the original file: `bb194ed6b111c4f2d329933a5d35483be0eb4f5bf10c5a84821050ae5939a0c7`. The following original bytes are preserved verbatim, including contradictory and superseded status/next-action statements. They are evidence of dated records, never current instructions. Current state is in [PROGRESS.md](PROGRESS.md).

<!-- BEGIN VERBATIM PROGRESS 94cebfb -->

# Culmina — Refinement Progress

> The handoff contract for post-roadmap refinement: where work stands, what binds it, which evidence
> can be reused, and the next allowed action. Read it after [`CLAUDE.md`](../../CLAUDE.md); the
> documentation map is [`docs/README.md`](../README.md).
> - **Active execution queue:** [`FINAL_COMPLETION_ROADMAP.md`](FINAL_COMPLETION_ROADMAP.md), **approved by the owner 2026-10-18** (P8 base -02, owner amendments AM-01/AM-02/AM-03/AM-04/AM-05; current version P6-2026-10-18-08): Stages A–D, F01–F26, G1–G4.
> - **Registers and earlier plan:** [`POST_ROADMAP_PLAN.md`](POST_ROADMAP_PLAN.md) §7 (RG), §8 (RD), §9 (workflow rules); its §5 Stage 12–17 Task IDs are now the roadmap's aliases (its §4).
> - **Direction:** [`PRODUCT_DIRECTION.md`](PRODUCT_DIRECTION.md). **Decisions:** [`DECISIONS.md`](../DECISIONS.md) E.1 and the ADRs.
> - **Verification rules:** `CLAUDE.md`, "Verification Policy (canonical)".
> - **History:** [`PROGRESS_HISTORY.md`](PROGRESS_HISTORY.md) (every earlier entry, verbatim) and the `STAGE_N_*.md` reports.
>
> **Latest amendment:** AM-05 (2026-10-18): impossible-now items become NEEDS ATTENTION with reason/dependencies/resumption action, then independent work continues; final done/not-done report. Targeted tests per changed Task/dependencies; consolidated G1/F26 full checks. Version P6-2026-10-18-08; 26 tasks / 127 criteria, no F task started.
>
> **Earlier amendment:** AM-04 (2026-10-18): familiar exposure/ISO/WB and optional AF/MF, class-selected sensitivity and advanced astro binning, bound in F03/F06/F09/F12; recorded at P6-2026-10-18-07, 26 tasks / 127 criteria. Git preparation is authorized; no F task has started.
>
> **Prior amendment:** 2026-10-18, AM-03: four findings of the repeat Claude UI/UX review (FINALIZATION_REVIEW §34) accepted — CRUX-01–CRUX-04; 26 Tasks and 127 criteria. The owner then chose AM03-T = B (Home's title follows the plan's night; the tab stays “Tonight”): recorded at P6-2026-10-18-06; latest version is above. AM-01 and AM-02 remain incorporated; CRUX-05/06 stay proposals.
>
> **P8 baseline record:** 2026-10-18 (finalization workflow P8: the owner approved the final completion
> roadmap, version P6-2026-10-18-02, after P6 and the P7 check; documentation only, no application
> change, gate, build or device run. The same day's earlier cleanup moved the chronological entries to
> `PROGRESS_HISTORY.md`).

## Current state

| Item | State |
| --- | --- |
| Consolidation delivery, 2026-10-24 | Owner authorizes combining current design/geo with the latest rounded mark/full launch animation, preserving data, installing on the phone, cleaning obsolete local branches/checkouts after recovery backup, and pushing develop. Combined source preserves completed Hybrid/TD-120/TD-121, rounded identity and full Flutter gesture on verified origin/develop `2a43c899`; older identity base `744fe57` is superseded and archived. 2509 unit/widget tests, host core/performance E2E, final analyzer/format/encoding, seven-frame Android drive, hot reload and read-only phone verification passed. Canonical release update installed preserving visible plan state. [Consolidation report](../design/migration/CONSOLIDATED_DELIVERY_2026_10_24.md). Delivery source commit `8a21e7b` pushed to develop; canonical owner checkout aligned and clean, obsolete task/test worktrees and redundant branches removed after recovery archive. Owner visual acceptance pending; older rows below are dated history. |
| Current bounded owner package, 2026-10-23 | TD-121 screenshot follow-up implemented in isolated `culqa`:129 scoped tests,32 dependency tests,16 accessibility checks, focused all-theme100/200 renders and Android capture passed. Release update installed on phone; owner acceptance pending. [Latest report](../design/migration/GEO_OWNER_REFINEMENT_2026_10_23.md). TD-120 preserved. No commit/push; logo checkout untouched. |
| Build/design investigation, 2026-10-24 | Old About/Privacy traced to separate `io.github.buffur.culmina.s2check` identity-test app, not a geo source rollback. Current geo APK/source hashes intact; correct `io.github.buffur.culmina` opened and inspected on phone. Fresh9-frame host capture passed. [Report](../design/migration/DESIGN_BUILD_SELECTION_2026_10_24.md). No production changes, reinstall, merge or Git delivery. |
| Design parity follow-up (owner, 2026-10-21) | Completed on `develop`, audit baseline `1aceb65`; 12 documented gap groups repaired. Five Culmina skills and native Impeccable review, 84 matched pairs, independent Claude CLI review/re-review, passing full gate plus correction regressions, Android full flow (72 captures), final Settings verification (6 captures), normal debug APK/hot reload and actual site IME/Back check. [Report](../design/migration/DESIGN_PARITY_QA_2026_10_21.md). Owner authorized delivery to `origin/develop` on 2026-10-21; this entry accompanies the delivery commit. No physical-device, owner acceptance or roadmap-gate closure is claimed. |
| Phase | Final completion. P8 approved base P6-2026-10-18-02 (historical content SHA-256 `a68b6b898f670430a80acaac6240049cc05e584101bf75519f95c001e1cff954`). The owner explicitly authorized bounded AM-01/AM-02/AM-03/AM-04/AM-05; current active roadmap is **P6-2026-10-18-08** (DECISIONS E.1 AM-01–AM-05 and AM03-T; FINALIZATION_REVIEW §31/§33/§35/§36/§37/§40). Stage12 and earlier closure remain; old S-IDs remain aliases. No F implementation starts from this documentation instruction |
| AM-01 | Simple Capture Plan, visual night/weather, Plan block removal, grouped Settings, consented GPS/name and early manual results. Historical -03 had118 criteria; AM-02 then brought it to 122 and AM-03 to the current 127 |
| AM-02 | UX32-01–05 now accepted: stable Save, scoped block apply, newest-query search, honest settings retry/persistence, selected-night hierarchy (122 criteria at -04). The repeat Claude assessment ran on 2026-10-18 as FINALIZATION_REVIEW §34 (assessment only; UX32-03/04 reproduced on the host) |
| AM-05 | Targeted changed-behavior/dependency tests and named probes per Task; full checks at G1/F26. Record attention items and continue safe independent work; report every done/not-done item at the end |
| Goal run | **Launched 2026-10-18** by the owner ("виконай цей план" with the brief [`CLAUDE_FINAL_PLAN_GOAL_IMPLEMENTATION.md`](prompts/CLAUDE_FINAL_PLAN_GOAL_IMPLEMENTATION.md), as an ordinary coding instruction in a Claude Code cloud session; `/goal` not used). Authorized: F01–F26/G1–G4, task commits and ordinary pushes to origin/develop; not main, force-push, signing secrets, owner data or publication. One lead/writer. Ledger: "Run ledger" below |
| Emulator/render execution | Owner clarification 2026-10-18: agents independently use/provision isolated emulators and render actual production widgets during authorized implementation. Inventory: emulator/ADB available in SDK, WHPX usable, no AVD/system image or connected device found. No emulator app run performed. Absence of a phone does not block host/emulator implementation; explicitly physical G2 rows remain |
| AM-04 | Familiar camera parameter hierarchy and optional AF/MF descriptive recording; F03/F06/F09/F12 and SP05. No new task, gate, calculation, hardware control or automatic metadata inference |
| AM-03 | CRUX-01–04 accepted: one plan-night phrase for Planner/Home (F18 A6, F17 A5), honest place-name switch persistence (F21 A6), a position fix never overwrites edited coordinates (F23 A6), no “Current position” label for a remembered position (F23 A7). 26 F tasks / 127 criteria. AM03-T decided B: the tab stays “Tonight”, the page title follows the plan's night (F17 A5; version -06). CRUX-05/06 not selected |
| Current document fingerprint | AM-05, P6-2026-10-18-08, SHA-256 `6ab29ddda5fbea5097a03df04338a4062d5060e133e8c85a075dab7c88e6b6f9`; §20 UX SHA-256 `80dbab0a0f484a461b78d9bd809dc75912bea1534b84fc7a2530e8a586afb7f6`. Earlier fingerprints in FINALIZATION_REVIEW remain historical; no new app acceptance claim |
| How it was prepared | The owner-invoked finalization workflow (`CULMINA_FINALIZATION_WORKFLOW_AND_PROMPTS_UK.md`, held outside the repository), recorded in [`FINALIZATION_REVIEW.md`](FINALIZATION_REVIEW.md): P1–P5 (Codex) §1–§27; the owner's D1–D9/UX-S answers (D1–D5 and D7–D9 = A, D6 deferred to the measured F26 sizes, UX-S = A); P6 §28 (begun by Codex, completed by Claude after Codex's usage limit); P7 §29 (a fresh Claude session: READY FOR OWNER APPROVAL, no blockers, six non-blocking follow-ups); P8 §30 |
| Git delivery | Baseline `2b467b8fd1478b6f8f0fcd48e887a88bc819ad8e` committed and pushed normally to origin/develop on 2026-10-18. Remote main unchanged; local main remains `322edbd`. Canonical origin is https://github.com/Buffur/Culmina.git. The goal handoff is in the subsequent documentation commit (resolve actual hash from Git); no F implementation or publication |
| Hybrid migration | Owner brief 2026-10-20 (`docs/design/migration/OWNER_BRIEF_2026_10_20.md`): native adoption of the original Hybrid / Geist design. Status and evidence live in [`WEB_TO_FLUTTER_MIGRATION.md`](../design/WEB_TO_FLUTTER_MIGRATION.md): resumed and completed 2026-10-21 within the stated coverage (full gate, Android emulator drive, matched visual review, hot reload, independent Claude CLI review, its confirmed findings fixed); OPEN-01 (block-editor composition) done the same day; D-01/D-03/D-05/D-07 adopted and D-06 decided by the owner (red outline) the same day; no open decision; awaiting owner acceptance. Work is on branch `claude/owner-brief-2026-10-20-d413ba`, not yet merged into `develop` or pushed |
| UX-copy pass (owner, 2026-10-18) | Not a roadmap Task: the owner asked for the fixes of a UX-copy review of `lib/presentation`, except what F01/F12/F16/F17 cover and without glossary changes; committed on its own, without the uncommitted documentation cleanup. **Changed (wording only):** "session"/"location" left in the UI → plan, result, site, position; "Invalid" and the raw `Invalid site: …` → messages that say what to enter; the bootstrap failure names what failed; forecast loading/out-of-range wording shared in `WeatherText`; sentence case and frame types from `BlockText.type` in the block editor (the optional N2 of `docs/audit/10_UX_AUDIT.md`, otherwise optional F06 copy); "your" instead of "my"; candidates' "size in frame"; shorter Settings explanations (Off overheads still "left out", never zero); fallbacks. **Not changed:** `AppWords`, any stored value or calculation; "Moon gate"/"Cloud gate" (an owner decision); the plan labels "(no target)"/"(no rig)", which are written to the database. **Left to the roadmap:** the restore confirmation (F01), "Change in Planning Settings" (F12), Welcome (F16), the planner's no-site banner, its "Set site" button and "No night without a site", and Tonight's no-site prompt (the owner listed them as F17; they are planner/Home surfaces of F17/F18). Verification: see "Reusable validation evidence" |
| Current Stage | Roadmap **Stage A** (F01–F02) next, **not started**. Stage 12 closed (bounded closure PASS at `570581e`, [report](STAGE_12_13_CLOSURE.md)). Stage 13's open S13V-01 / TD-109 (the splash before Android 12) is now F02; S13V-02/03 are G2 rows. Stage 11 closed as superseded |
| Current Task | See "Run ledger". No task is VERIFIED while a mandatory device/owner row is open |
| Code baseline | `322edbd` (2026-10-18 UX-copy pass), now included in published develop baseline `2b467b8`; its earlier commits `b6e8c1e`/`1f10121` are documentation. Current schema/application inputs are unchanged by the preparation. The earlier apparent macOS registrant modification had no content diff and disappeared after staging |
| Remote | `Buffur/Culmina` (public). The Stage 12–13 closure read CI run [39042823307](https://github.com/Buffur/Culmina/actions/runs/39042823307) as `success` at `570581e` (GitHub REST API, 2026-10-17); not re-read since. Project page, privacy policy and source answered HTTP 200 (S13.2 evidence) |
| Schema | **v26** since F03 (`app_database.dart`, `schemaVersion`; 2026-10-18) |
| Toolchain | Flutter **3.47.4** (the CI's pinned version; Dart 3.13.3) at `C:\flutter`. Linux reproduction: WSL Ubuntu with the official 3.47.4 Linux archive at `~/ci/flutter` (S12.1). The 2026-10-18 run's cloud containers (two sessions): the same official archive at `/opt/flutter-sdk/flutter`, no Android SDK (`dl.google.com`, also the target of `maven.google.com`'s redirect, is refused by the network policy: 403, rechecked in the second session) |

**Stages 12–13, per Task** (detail in the [closure report](STAGE_12_13_CLOSURE.md) and `PROGRESS_HISTORY.md`):
- **S12.1 done** (`461e38c`; TD-104 and RD-17 resolved; remote CI passed after the owner-authorized push).
- **S12.2** optional (the owner's trademark check); not performed; not a gate.
- **S12.3 done:** repository renamed to `Buffur/Culmina`; Pages, the policy with the owner's contact, and the project index published (TD-099 resolved).
- **S12.4 decided (a)** (DECISIONS E.1): Play services location accepted with a GPL-3.0 §7 additional permission in `COMPLIANCE.md` and `README.md`; the About statement follows in S16.8 (C4).
- **S13.1 done:** the owner approved `R3-final` and the splash-animation concept ([`evidence/identity/round5/`](evidence/identity/round5/README.md)).
- **S13.2 done** (`b29ec34`): id `io.github.buffur.culmina`, label Culmina, channel and URLs renamed (TD-088, TD-093 resolved); device checks [PASS](evidence/S13_2_DEVICE_CHECKS.md). Follow-up TD-105.
- **S13.3 implemented** (`f89c7c3`, `570581e`): the R3-final launcher icon, the monochrome layer and the Android 12+ animated splash held for 1,000 ms (owner decision amending ID-6). [Evidence](evidence/S13_3_DEVICE_CHECKS.md). **Not met:** the static icon before Android 12 (S13V-01 / TD-109). **UNVERIFIED on a device:** reduced motion (S13V-02); final cold-start numbers (S13V-03); both carried to S17.5 (roadmap G2). S13V-01 is roadmap F02.

## Run ledger (full final-plan group, launched 2026-10-18)

States: IN PROGRESS · IMPLEMENTED-ACCEPTANCE-PENDING · VERIFIED · NEEDS ATTENTION · NOT STARTED.
Evidence: `evidence/finalization/<task>/README.md`. Commit hashes are recorded after the commit
exists (the row of the next task's commit carries the previous one).

| Task | State | Criteria | Verification (this run) | Carry / attention |
| --- | --- | --- | --- | --- |
| F01 (`8ad566d`; fix `2479bca`) | IMPLEMENTED-ACCEPTANCE-PENDING | A1–A3 PASS (TEST); A4/A5 host PASS, phone rows carried | 283 targeted tests + 23 source-rule tests, analyze clean, format/encoding ([evidence](evidence/finalization/F01/README.md)). CI run [39136907512](https://github.com/Buffur/Culmina/actions/runs/39136907512) at `52bf796` FAILED: the restoring screen's `EdgeInsets.all(24)` broke `secondary_consistency_test.dart` (1891 passed, 1 failed; not in F01's targeted set). Fixed by `2479bca` (spacing tokens); suite then green locally | REL-10 phone rehearsal (Recents during activation, literal outcome) at G2; U/visual in F25 |
| F02 | IMPLEMENTED; A2/A3 NEEDS ATTENTION | A1 PASS (TEST, fails on the old resources); A2/A3 not observable here | `app_identity_test.dart` ([evidence](evidence/finalization/F02/README.md)) | No Android SDK/emulator in this container (network policy refuses dl.google.com) |
| F03 (`55fef9b`) | IMPLEMENTED-ACCEPTANCE-PENDING | A1 PASS (OWNER: ADR-021 accepted); A2–A4 PASS (TEST: v26 migration, round trips, refusal); A5 NEEDS ATTENTION (no FITS sample) | [evidence](evidence/finalization/F03/README.md); full suite `+1968 ~2`, host E2E `core_loop` `+2` | FITS sample (F10 only) |
| F04 (`65233d8`, fix `33c6da5`) | IMPLEMENTED-ACCEPTANCE-PENDING | A1–A3 PASS (TEST); A4 synthetic PASS, real DNG/JPEG/HEIC run NEEDS ATTENTION (owner samples outside Git) | [evidence](evidence/finalization/F04/README.md); `+1134 ~1` affected areas | Owner runs `real_samples_test.dart` locally with `ASTROPLAN_METADATA_SAMPLES` |
| F05 (`c76bae6`) | IMPLEMENTED-ACCEPTANCE-PENDING | A1–A6 PASS (TEST: class-first panel, D8 from Tonight/planner/status/Welcome, Library save-only, Cancel, failed save, discard guard, missing-input reasons, cited example class); U/W at F25 | [evidence](evidence/finalization/F05/README.md); `+1353 ~2` affected areas, host E2E `core_loop` `+2`, `perf_scenarios` `+1`; density baseline recorded (3836 px at 412 px) | U renders and owner visual acceptance (F25); real phone JPEG (G2). F04 fix `33c6da5`: the review's rows for the F04 fields (a failure F04's targeted run missed) |
| F06 (`1c4ea3b`) | IMPLEMENTED-ACCEPTANCE-PENDING | A1–A7 PASS (TEST: custom filters, per-field origins through every plan operation, no leaked light exposure, WB/AF-MF records with unchanged calculations, fractional exposure, C13 sensitivity, discard guard, Add block/Apply changes); TD-108 resolved | [evidence](evidence/finalization/F06/README.md); whole unit/widget suite `+2064 ~2`, host E2E `core_loop` `+2`, `perf_scenarios` `+1`; density unchanged (3836 px) | U renders and owner visual acceptance (F25); block file proposals (F08) |
| F07 (`d70e425`) | IMPLEMENTED-ACCEPTANCE-PENDING | A1–A5 PASS (TEST: evidence order C8, never-rescaled measured files C9, theoretical DNG/FITS only from evidenced uncompressed formats C10, class never chooses, unread RAW by length C12, V1–V11, decimal MB/GB); SI-013 resolved | [evidence](evidence/finalization/F07/README.md); whole unit/widget suite `+2093 ~2`, host E2E `+2`/`+1` | FITS read branch (F10); U renders (F25) |
| F08 (`225e87a`) | IMPLEMENTED-ACCEPTANCE-PENDING | A1–A3 PASS (TEST: class-applicable inline proposal with file origins, nothing to the rig, deterministic repeat picks, guard, TD-072 resolved); A4 host PASS, device row G2, U/W F25 | [evidence](evidence/finalization/F08/README.md); whole unit/widget suite `+2111 ~2`, host E2E `+2`/`+1` | Phone DNG/JPEG/HEIC row (G2); FITS (F10) |
| F09 (`76e1211`) | IMPLEMENTED-ACCEPTANCE-PENDING | A1–A6 PASS (TEST: tuple warnings/coverage, strict C15 proof, CAL-1 preview with entered flat exposures and one Undo, LENR, empty-state next step replacing the example action, E2E migrated); TD-107 resolved | [evidence](evidence/finalization/F09/README.md); whole unit/widget suite `+2127 ~2`, host E2E `+2`/`+1`; density 3884 px (+48) | U renders (F25) |
| F10 (`5c18cfe`) | IMPLEMENTED; A3 NEEDS ATTENTION | A1, A2, A4 PASS (TEST, synthetic headers: record/END/budget/axis limits, floating BITPIX, conflicting exposure, FILTER as written, binning normalized once, labels advertise FITS); A3 host path PASS, real sample missing | [evidence](evidence/finalization/F10/README.md); whole unit/widget suite `+2141 ~2`, host E2E `+2`/`+1` | Real astro-camera FITS (owner); G1 blocked until A3 or owner deferral |
| F11 (`638823e`) | IMPLEMENTED-ACCEPTANCE-PENDING | A1–A3 PASS (TEST: R-O2-1/V12 vectors ±0.0001, C16 groups by normalized filter/exposure/recorded ISO or gain/binning, an unrecorded setting never joins another block, zero/no-plan/empty states, primary √N lines with their settings, O2b curves in collapsed Details with a text alternative) | [evidence](evidence/finalization/F11/README.md); whole unit/widget suite `+2148 ~2`, host E2E `+2`/`+1`; density 3708 px (−176) | U renders (F25) |
| F12 (`e3e955c`) | IMPLEMENTED-ACCEPTANCE-PENDING | A1–A4 PASS (TEST: effective assumption values with budget counts, every light block's fit from `maxFramesForBlock` with the others as planned, focus reminder with AF/MF invariance, "Change in Settings" over the plan with the global-scope notice and Back to the same plan/section, settings grouped basic/advanced/guidance); TD-074 part (1) resolved | [evidence](evidence/finalization/F12/README.md); whole unit/widget suite `+2154 ~2`, host E2E `+2`/`+1` | U renders (F25); TD-074 (2)–(4) FOLLOW-UP |
| F13 (`bdc9f6b`) | VERIFIED (host) | A1–A4 PASS (TEST/DOC: one Moon-up predicate, M1–M7, USNO, SI-015); A5 PASS (OWNER: ADR-022 N11/N12) | [evidence](evidence/finalization/F13/README.md); full suite `+1982 ~2`, host E2E `+2`/`+1` | Renders of the implemented D9 screens belong to F15/F17/F18 |
| F14 (`0ee2ee8`) | IMPLEMENTED-ACCEPTANCE-PENDING | A1–A6 PASS (TEST: dark-span slicing N6 with W1/W2, per-night coverage complete/partial/none/no dark and beyond N7, one horizon request, v2 site-cell cache with legacy keys deleted and a mutation-checked late-response race N8, lead time apart from age N9/W3, facts-first night card with hour selection, Details, seeing limitation and Clear Outside link, browse-only coming-night cards with D9 "Plan this night"); TD-049 resolved | [evidence](evidence/finalization/F14/README.md); whole unit/widget suite `+2170 ~2`, host E2E `+2`/`+1` | Live Open-Meteo evidence (G1); U renders (F25) |
| F15 (`189bdb9`) | IMPLEMENTED; A4 NEEDS ATTENTION | A1–A3, A5 PASS (TEST: one NightView for browsed and plan nights; a month calendar in an isolate with the N10 key; the shared bar with hatched Moon-up, legend and text alternative; the time slider with its readout, Now only inside the viewed night, DST zone names; "Viewing … · Your plan: …"; D9 "Plan this night"; site change and reopen keep the plan and the saved snapshot; a week list at large text); A4 host month ≈ 170 ms, phone timing missing | [evidence](evidence/finalization/F15/README.md); whole unit/widget suite `+2179 ~2 -3`, then the 3 a11y `/night` overflows fixed and the affected files `+27`; host E2E `+2`/`+1` | Phone calendar timing (G2); U renders (F25) |
| F16 (`e5ece27`) | IMPLEMENTED-ACCEPTANCE-PENDING | A1–A4 PASS (TEST: the first route from the flag before the first frame, mutation-checked; one Welcome page with purpose and permission, optional site and class-first rig steps, no target step or Skip; Start planning or back closes it for good; a rig typed there becomes the plan's and is shown, Cancel saves nothing; core loop and lifecycle start as main does) | [evidence](evidence/finalization/F16/README.md); whole unit/widget suite `+2184 ~2`, host E2E `+2`/`+1` | U renders (F25) |
| F17 (`278b169`) | IMPLEMENTED-ACCEPTANCE-PENDING | A1–A5 PASS (TEST: title and field mode in one header, context then the night card (dark interval, phase and moon-free time, dark-span cloud with coverage and age, no-dark and partial states) before Your plan; candidates secondary; Home New plan removed with the planner's guarded menu kept; the plan-night phrase in title, action and candidates screen with the tab still "Tonight") | [evidence](evidence/finalization/F17/README.md); whole unit/widget suite `+2181 ~2 -6` (the removed button's callers), then the updated prompt file `+28`; host E2E `+2`/`+1` | U renders (F25) |
| F18 (`3583075`) | IMPLEMENTED-ACCEPTANCE-PENDING | A1–A6 PASS (TEST: "Tonight for this target", its chart and window list are out of the plan, with the opportunity and fit still computed; the target appears once; Save plan always shown, disabled with "To save: …" and the direct action; a successful Save clears the autosave banner (TD-095); D9 flows shared; the plan-night phrase in every planner text with values unchanged, mutation-checked) | [evidence](evidence/finalization/F18/README.md); whole unit/widget suite `+2189 ~2`, host E2E `+2`/`+1`; density 3152 px (−556) | U renders (F25) |
| F19 (`a02a8fa`) | IMPLEMENTED-ACCEPTANCE-PENDING | A1–A5 PASS (TEST: Logbook cards say Result not recorded or Completed/Partly/Not done in words and an icon, with planned vs recorded integration and Record/Edit result; the current saved night can be reported early, a future one refused, by one rule in domain/repository/form/entry from the stored window's start (D8-1 eligibility amended by AM-01; transition still at dawn); a Saved · changed plan during its night resolves Save/Discard/Cancel first; the entry's forecast is the saved one with its age then; the plan's rig/target Delete with Cancel/dismissal/confirm end to end; mutation-checked) | [evidence](evidence/finalization/F19/README.md); whole unit/widget suite `+2200 ~2`, host E2E `+2`/`+1` | U renders (F25); W multi-night journey on a phone (G2) |
| F20 (`e478523`) | IMPLEMENTED-ACCEPTANCE-PENDING | A1–A4 PASS (TEST: recorded acquisitions only, every other entry listed with its reason; rows per night and light setting in date order; unknown blank, never 0; the filter column empty with names in row order in the preview and share text; Share CSV shares exactly the preview, Cancel nothing; calibration counts only from confirmed frames proving one row's whole C15 tuple; manifest unchanged; mutation-checked). Contract page unreachable here (network policy), its rules re-confirmed by search 2026-10-19 | [evidence](evidence/finalization/F20/README.md); whole unit/widget suite `+2207 ~2 -2` (retired term, fixed; affected `+39`), host E2E `+2`/`+1` | Live AstroBin import of the file (owner, G2/G3); U renders (F25) |
| F24 (`52bf796`, `1b07ce3`, `6215b50`) | CLOSED (2026-10-19 recheck after F01–F23) | A1–A6 PASS (TEST; rows rechecked against `658d8cf`: fixed clocks in every new test and the wall-clock rule, tiles-failing map, AppLog, `unawaited_futures`, startup/zone/test-gap rechecks, newest-query target search) | [evidence](evidence/finalization/F24/README.md); whole unit/widget suite `+2238 ~2` and host E2E `+2`/`+1` at the F22 gate (reused, V3) | — |
| F25 (`2dcb000`) | IMPLEMENTED; A4 NEEDS ATTENTION (owner) | A1 PASS (52 host renders with real glyphs at 412 × 915, light 100 / dark 200 / field 100 and the block editor with the keyboard; the a11y sweep extended to editors, dialogs, the filter panel, the AstroBin preview and the map picker, which found and fixed a target-editor overflow, the map attribution overflow and an unlabelled map); A2 PASS (bounded QuantityText source test, 14 bypasses removed; theme/field unchanged); A3 PASS functional (four W journeys, comprehension UNVERIFIED) | [evidence](evidence/finalization/F25/README.md); whole unit/widget suite `+2246 ~5` (the 3 opt-in render tests skipped, as designed), host E2E `+2`/`+1` | Owner visual acceptance (A4); device captures (G2) |
| G1 (`e13eccc`) | HOST ROWS PASS; NOT PASSED (prerequisites and environment rows open) | Frozen F/G row list; full gate PASS before and after the `material_ui` fix (`+2246 ~5`, E2E `+2`/`+1`); backup round trip VERIFIED (host); remote CI, native Android, emulator, live Open-Meteo/Nominatim/tiles and most About URLs UNVERIFIED (push 403, no SDK, network policy) | [evidence](evidence/finalization/G1/README.md) | F10 deferral or FITS sample, F25 A4 owner acceptance, owner push → CI, Android environment |
| F22 (`6215b50`, `658d8cf`) | IMPLEMENTED; A1 Android row NEEDS ATTENTION | A1–A3 PASS (HOST/TEST: the open route restored through Flutter state restoration into a new graph; a restored planner never re-adopts its route's plan; a deleted plan shows Tonight with the message; unrestorable route arguments go back to their list; a restored result form writes nothing until Save; kill and v24 → v25 → v26 result fields; mutation-checked); TD-094 resolved | [evidence](evidence/finalization/F22/README.md); whole unit/widget suite `+2238 ~2`, host E2E `+2`/`+1` | Android process-death run (no Android SDK here); U renders (F25) |
| F21 (`3a31019`, `0860c56`) | IMPLEMENTED-ACCEPTANCE-PENDING | A1–A6 PASS (TEST: every preference value through the backup, old files to defaults, unknown values to defaults; °C/°F, km/h/mph/m/s, m/ft through every display and share path with canonical storage; absolute vs difference temperature separately; D1 A: System default, Light/Dark applied and restored, field mode unchanged, no token change; shown vs stored settings with unsaved/Retry, ordered coalesced writes, interrupted-save report; A6 from 2026-10-18; mutation-checked) | [evidence](evidence/finalization/F21/README.md); whole unit/widget suite `+2232 ~2 -1` (a raw `TextStyle` in the new card, fixed to the text role; `secondary_consistency_test.dart` and the Settings folder `+32`), host E2E `+2`/`+1` | U renders (F25) |
| F23 (`4689a08`, `f25da48`, `fe33b7b`) | IMPLEMENTED; A2 NEEDS ATTENTION | A1, A3, A5, A6, A7 PASS (TEST; A3 one release blocker to G1); A4 PASS (no provider change; the changed pages' U renders in F25); A2 NEEDS ATTENTION (2026-10-19 retry: Gradle 9.3.1 reached Maven Central and the plugin portal, but AGP 9.1.0's artifacts redirect from maven.google.com to dl.google.com, which this environment refuses) | [evidence](evidence/finalization/F23/README.md) | A2 needs the resolved Android dependency list (an environment with dl.google.com or an Android SDK) |

## Pass checkpoint (2026-10-19, end of the second session's pass)

Disposition of the finite run: **PARTIAL_WITH_ATTENTION**. Every F task is implemented and
committed; the host quality gate passes (`dart run tool/check.dart`, G1); no safe eligible work
is left in this environment. What remains needs the owner, a device, an Android SDK or network
access this environment does not have (attention register below). This is not a claim that the
product is complete or released.

| Disposition | Items |
| --- | --- |
| Verified on the host | F13, F24 (closed) |
| Implemented; acceptance pending only on carried device/owner/U rows | F01, F05–F09, F11, F12, F14, F16–F21 |
| Implemented; a row NEEDS ATTENTION | F02 A2/A3 (no Android SDK), F03 A5 and F10 A3 (FITS sample), F04 A4 (owner samples), F15 A4 (phone timing), F22 A1 Android process death, F23 A2 (Android dependency graph), F25 A4 (owner visual acceptance) |
| G1 | Host rows run: the full gate passed, the retracted `material_ui` replaced; remote CI, native build, emulator and live providers UNVERIFIED (see the G1 evidence) |
| Not started — blocked | F26 (Android build, D6 measurement, owner signing), G2 (phone), G3 (owner go/no-go), G4 (publication authorization) |

**Re-audit (2026-10-19, owner's question "is everything in the plan really implemented?"):**
every F01–F25 row was read again against the code. 16 behaviour gaps were found and fixed, and
the untested or weakly tested clauses were covered, each mutation-checked
([`REAUDIT.md`](evidence/finalization/G1/REAUDIT.md); commits `9ac8d7b`…`fba6dc9`). The relevant
`STAGE_11_MATRIX.md` rows are dispositioned in
[`STAGE_11_ROWS.md`](evidence/finalization/G1/STAGE_11_ROWS.md), whose one failing host row (H2) is
fixed. Full gate on the final inputs: PASS (`+2336 ~5`, E2E `+2`/`+1`; G1 evidence). F25 renders:
96. The disposition is unchanged: **PARTIAL_WITH_ATTENTION**. The open rows are the owner,
device, Android and network rows listed above.

## Next allowed action

**Current bounded chat scope:** combined delivery `8a21e7b` is pushed and installed; local cleanup is complete. Stop for owner acceptance or a new bounded observation. Preserve TD-120/TD-121 and the completed Hybrid transfer; do not resume the broader roadmap.

The full final-plan run is in progress (launched 2026-10-18; see "Run ledger"). Continue the next
dependency-ready task of F01–F26/G1–G4 in the roadmap's order; record genuinely impossible-now
items in the attention register and continue independent work. A dated "Next" line in
`PROGRESS_HISTORY.md` or in an older report is not an instruction.

## Open owner decisions

Every RG and RD not listed here is decided, answered or lapsed: `POST_ROADMAP_PLAN.md` §7 and §8.

| ID | Decision | Needed before | Defined in |
| --- | --- | --- | --- |
| Start instruction | Full-plan launch command prepared, not yet submitted; alternatively a narrower named scope with Git/stop conditions | F01 | Roadmap §2, rule 1; prompts/CLAUDE_FINAL_PLAN_GOAL_IMPLEMENTATION.md |
| D6 (= CA-OD2) | APK packaging, chosen with the measured sizes (deferred there by the owner, 2026-10-18) | F26 (alias S17.6) | Roadmap §5; `POST_ROADMAP_PLAN.md` §5, "Shared rules for Stages 12–17" |
| ~~ADR-021, ADR-022 acceptance~~ | **Decided 2026-10-18**: both accepted in full (DECISIONS ADR-021, ADR-022) | — | Roadmap §5 and §8 |
| RD-02 | The TASK 0.3 holdovers: the ADK skill, `skills-lock.json`, `docs/archive/` (the dependency part done by S10.6) | Nothing (housekeeping outside the release) | `POST_ROADMAP_PLAN.md` §8 |
| RG-12 | Licence research, deferred by the owner on 2026-09-30: GPL-3.0 stays (the §7 additional permission of S12.4 is recorded) | Nothing scheduled | `POST_ROADMAP_PLAN.md` §7 |

## Attention register for the implementation run

The run is prepared, not launched: no actual task is classified as failed or skipped by this documentation update. During execution the lead records every genuinely incomplete/unverified item here, continues dependency-ready work and returns to an item only when its blocking input changes. Preserve severity and all mandatory criteria. The terminal report includes every F01–F26/G1–G4 disposition and distinguishes COMPLETE from PARTIAL_WITH_ATTENTION.

| Item / F-G-CHK | Implemented versus missing | Reason / attempt / evidence / severity | Affected dependencies | Resumption action / responsible input | State |
| --- | --- | --- | --- | --- | --- |
| Git push (all tasks) | Commits are made on local `develop` and reach origin only when the owner pushes them: the first session's four (through `52bf796`), and the second session's seven (`2479bca`–`fe33b7b`, handed over as a git bundle and pushed by the owner on 2026-10-18; origin/develop = `fe33b7b`, checked) | `git push -u origin develop` → HTTP 403 "Claude doesn't have GitHub access to Buffur/Culmina for your organization" (first session twice; second session twice, 2026-10-18). GitHub reads (CI runs, job logs) work. Severity: high (unpushed work is lost if the container is reclaimed; remote CI cannot run on it, and develop's CI stays red until `2479bca` is pushed) | Every task's push; G1/F26 remote CI | Owner reconnects GitHub (claude.ai/connect-github) and/or installs the Claude GitHub App on Buffur/Culmina; until then the owner pushes each session's commits (bundle) | OPEN (workaround in use) |
| F03 A1 → F04–F12 (dependent persistence/science) | ADR-021 decision sheet written with recommendations and vectors | Owner local acceptance required by roadmap §5 before dependent implementation; asked 2026-10-18 | F03 A2–A4, F04–F12, F16 (via F05), F18–F20 parts | Owner accepts (or amends numbered items of) `ADR_021_DECISION_SHEET.md` | **CLOSED 2026-10-18**: accepted in full (DECISIONS ADR-021) |
| F13 A1–A5 → F14/F15/F17/F18 night parts | ADR-022 decision sheet written | Owner local acceptance required (roadmap §5) | F13–F15, F17, F18 A3/A6 | Owner accepts `ADR_022_DECISION_SHEET.md` | **CLOSED 2026-10-18**: accepted in full (DECISIONS ADR-022) |
| F03 A5 / F10 A3 (FITS sample) | The FITS reader, native geometry, block proposal, storage evidence and labels are implemented and tested on synthetic headers (F10); the real-file run is missing | No real astro-camera FITS in the repository or this container. A web search (2026-10-18) found no licensed amateur sub-frame: forum headers have no reuse terms, and NASA/HEASARC samples are not camera frames | F03 A5, F10 A3, G1 (unless owner deferral), G2 REL-08 FITS row | Owner provides a local FITS sub-frame (kept out of Git) or names a licensed fixture; then run import, block proposal and storage on it | OPEN |
| F15 A4 (phone calendar timing) | Month computed off the UI isolate (`compute`), cached by N10 key; host ≈ 170 ms per month (31 nights, Ljubljana, Dec 2026) | No phone or emulator in this container | F15 close, G2 | Measure opening and paging the month on the phone against the runbook's timing criterion at G2 | OPEN |
| F23 A2 (Android notices) | The licence page lists the Dart packages; the native notices are not yet added | The Android libraries the build actually bundles (AndroidX, Kotlin coroutines, Play services location, their versions) come from Gradle's resolved dependency graph, which needs `dl.google.com`/`maven.google.com` (refused here, 403). A list guessed from plugin build files would not prove "match the build dependencies". Severity: medium (attribution completeness, release-relevant) | F23 close; G1 notices row | In an environment with the Android SDK: resolve `./gradlew :app:dependencies` (release runtime classpath), add the notices, compare against the licence page | OPEN (retried 2026-10-19: Gradle 9.3.1 resolved Maven Central/plugin portal, then AGP 9.1.0 from maven.google.com redirected to dl.google.com: refused) |
| TD-031 row 9 / G1 (`material_ui` retracted) | **Resolved on the host 2026-10-19 (G1):** `flutter pub upgrade material_ui` → 1.7.0, one package; full gate passes; the F25 renders are byte-identical | Android build with the new lock not run (no SDK) | F26 | The native row of G1 builds it | HOST DONE; native pending |
| F02 A2/A3; every native Android/emulator row (G1 REL-02, F26, F22 process death) | F02 resources fixed and host-tested; no native build, launch or capture | The container has no Android SDK and cannot get one: `dl.google.com` (SDK repository; `maven.google.com` redirects there) is refused by the network policy (403, 2026-10-18). Remote CI builds no Android. Severity: blocks F02 VERIFIED and native gate rows, not host implementation | F02 close; G1 REL-02; F26 | Run in an environment with the Android SDK (owner machine with the existing SDK, or a cloud environment whose network policy allows dl.google.com): API 26–30 emulator launch capture, Android 12+ animation-off observation | OPEN |
| F25 A4 (owner visual acceptance) | 96 host renders since the re-audit (52 before) with real glyphs (`evidence/finalization/F25/renders/`) and the earlier tasks' renders; the extended accessibility sweep passes | Acceptance is the owner's by definition (roadmap §2 U); an agent cannot give it. Severity: release gate | F25 close, G2/G3 sign-off | The owner reviews the renders (and a device later) and records acceptance or the concrete changes wanted | OPEN |

## Owner actions outstanding

These block the release, not documentation or planning.
- **Agents handle emulator/renders independently:** discover existing SDK tools even when missing from PATH; reuse/create an isolated AVD and provision minimal required tooling/image where permitted; generate actual-widget host renders and emulator captures. See the goal prompt's execution procedure. These are implementation/testing actions, not owner-only phone prerequisites.
- **A physical phone** for the carried device rows (G2, alias S17.5): S13V-02, S13V-03, the Stage 11
  matrix's phone and human rows (`STAGE_11_MATRIX.md`, `STAGE_11_DEVICE_RUNBOOK.md`), S2V-06, S3V-08
  and S10V-04's profile run. Emulator evidence does not replace a physical-phone or human check. An
  API 26–30 launch (emulator or device) is needed for F02 (S13V-01's correction).
- **A FITS sample** (F10, alias S14.5; requested at F03's start). Optional: a DSLR/mirrorless JPEG or RAW (useful for the DSLR
  workflow check) and PNG or AVIF samples. The owner's DNG, JPEG and HEIC samples stay outside Git.
- **The release keystore and `android/key.properties`** (owner-managed, trap 21; F26, alias S17.6). The Play
  upload key and the AAB are deferred (GitHub-only distribution).
- **Release-signed install / signature mismatch:** use an isolated clean profile where possible. Never automatically uninstall an owner app. Before any explicitly owner-authorized uninstall, verify an independent backup and complete the named rehearsal (F26 A5/G2). The historical `.s2check` package observation (S13V-04) is not current install/uninstall authorization.
- The owner's visual review of UI Tasks; ADR-021/022 local acceptance; D6 from actual measurements;
  the go/no-go (G3) and separate GitHub Release publication authorization (G4). When the owner submits
  the full-plan launch command, ordinary task commits and pushes to develop are authorized for that
  finite run; main, force-push, signing secrets and owner-data operations are not included.
- Optional: S12.2.

## Known blockers and open risks

- **S13V-01 / TD-109** (the static splash before Android 12): open, scheduled as F02.
- **Open release defects, scheduled and not fixed:** TD-106 (Critical: an invalid SQLite payload can
  become the live database) → F01 and G2 (aliases S14.3, S17.5); TD-107 and TD-108 (High) → F09 and
  F06 (aliases S14.10, S14.6). Every open item: `TECH_DEBT.md`, "Open items".
- **Evidence gaps:** S6.E UNVERIFIED (no independent participant; owner-accepted); "responsive on
  representative hardware" UNVERIFIED until S10V-04's phone run; the Stage 11 phone and human rows
  (S11.6) are carried into S17.5.

## Carried items

| Item | State | Destination |
| --- | --- | --- |
| S13V-02, S13V-03 | Reduced motion and final cold-start numbers, UNVERIFIED on a device | S17.5 (G2) |
| S11.6, S11.7 | The phone, human and owner rows of `STAGE_11_MATRIX.md`; readiness | S17.5, S17.7 (G2, G3) |
| S10V-04 | `integration_test/perf_scenarios_test.dart` on a physical phone, profile mode | Stage 11 matrix → S17.5 |
| S1.5, S1.11 device checks; S2V-06; S3V-08 | Device rechecks (an older build over a newer database; TalkBack; a non-seekable provider and a real backup's preview cancel; the corrected Stage 3 flow) | Stage 11 matrix → S17.5 |
| S6.E | The five-second test with an independent participant: UNVERIFIED, owner-accepted gap | Stays a recorded gap (proposal: W rule) |
| TD-072 (S3S-03, deferred by the owner) with S3F-01; S3F-02 (a note on TD-071) | Open | S14.9 (F08, F10) |
| TD-074 | Open | S14.12 (F12) |
| Other open TD items | Open | `POST_ROADMAP_PLAN.md` §5, "Open technical-debt items" |

## Reusable validation evidence

Per `CLAUDE.md`, Verification Policy V3: reuse while the relevant inputs are unchanged. Earlier rows
(S12.1's Linux and Windows gates back to Stage 7's probes) are kept in `PROGRESS_HISTORY.md` as the
closing evidence of their Stages; later gates supersede them.

| Evidence | Ran at | Still valid because |
| --- | --- | --- |
| **Current develop CI PASS**, run [39124553324](https://github.com/Buffur/Culmina/actions/runs/39124553324) | `2b467b8fd1478b6f8f0fcd48e887a88bc819ad8e` | GitHub REST API confirmed completed/success on 2026-10-18 after the baseline push. Reusable for goal-handoff commit `2134a2b` and this evidence-record commit: subsequent changes are Markdown only, with no application/test/dependency/tooling/platform change. Full-gate success is not F-task, device, visual or release acceptance |
| **Remote CI PASS**, run [39146586823](https://github.com/Buffur/Culmina/actions/runs/39146586823): the full gate on `ubuntu-24.04`, Flutter 3.47.4 — Encoding, Format, Analyze, Test (1,928 passed, 2 skipped), host E2E `core_loop` (2) and `perf_scenarios` (1) | **`fe33b7b`** (2026-10-18) | Read from the GitHub API and job log on 2026-10-18. Covers every code input to `fe33b7b`. Not an Android build (the CI builds none). The earlier run 39136907512 at `52bf796` failed on the F01 spacing regression fixed by `2479bca` |
| **Remote CI PASS**, run [39042823307](https://github.com/Buffur/Culmina/actions/runs/39042823307): the workflow's gate on `ubuntu-24.04`, Flutter 3.47.4 | **`570581e`** | Read by the Stage 12–13 closure. Covers `570581e` only: `322edbd` (the UX-copy pass) changed `lib/`, `test/` and `integration_test/`, so this historical run does not cover the current code; the local gate row below covers it. The earlier apparent macOS registrant modification had no content diff at delivery |
| **Local full quality gate PASS** (Windows, Flutter 3.47.4; 1,852 tests passed, 2 skipped; host E2E `core_loop_test.dart` and `perf_scenarios_test.dart` passed) | The UX-copy pass's code (run on the working tree just before its commit, 2026-10-18) | Its `lib/`, `test/` and `integration_test/` are what that commit holds; valid while they stay unchanged. Not a device, CI or visual check: the new wording is not yet seen on a phone or by the owner |
| **Local full quality gate PASS** (Windows; 1,851 tests) | `f89c7c3` (S13.3) | The last local full gate. `570581e` then changed the splash, verified by `app_identity_test.dart`, `startup_mark_test.dart`, a release build and a phone recording (the owner's targeted-test instruction); the CI row above covers `570581e` |
| **S13.2 device checks PASS** ([evidence](evidence/S13_2_DEVICE_CHECKS.md)): M1/M4 with a DNG and a HEIC on `io.github.buffur.culmina.s2check`; a backup made on the old id restored on the new id (9 tables equal, preferences restored) | `b29ec34` | Device evidence for those flows until they change |
| **S13.3 phone checks** ([evidence](evidence/S13_3_DEVICE_CHECKS.md)): the Android 12+ splash; first-frame median 272 → 290 ms (the non-held build) | `f89c7c3` | Valid for the first frame under V3 (closure report, S13.3 (4)); the held second's numbers are S13V-03 |
| Local real-sample metadata test PASS (DNG, JPEG, HEIC) | After S3.V4 (`2447962`) | Environment-dependent (the owner's sample folder). Valid while the metadata readers are unchanged; not re-checked at this cleanup |
| Device checks M1–M4 (the owner's Xiaomi 14T Pro, `.s2check`) | `79f392c`, `237c55f`, `2b045eb` | Valid for the flows covered until they change; M1/M4 repeated under the new id by S13.2 |

## Stage status

Vocabulary: Not started · Planning · In progress · In validation · Complete.

| Stage | Name | Status | Opened | Closed | Stage validation |
| --- | --- | --- | --- | --- | --- |
| 0 | Refinement Baseline | Complete | 2026-09-25 | 2026-09-25 | Self-review against the Stage 0 prompt's §22 checklist (`PROGRESS_HISTORY.md`, "Validation status"). The prompt asks for no separate validation session |
| 1 | Verified Fixes & Clean Baseline | Complete (owner waiver) | 2026-09-25 | 2026-09-26 | **Did not pass**: independent validation failed at `4e653fb` (TD-059–TD-062, fixed), then at `c99bd7f` (TD-063, X2). The owner closed the Stage anyway: TD-063 goes to Stage 8; X2 and W1 are carried |
| 2 | Metadata Foundation | Complete (owner waiver) | 2026-09-26 | 2026-09-26 | **Did not pass independently**: it failed at `79f392c` (fixed, `ffaff57`) and at `5d8bdbb` (S2R-01/TD-067; fixed by S2.V4/S2.V5, `d8e792c`/`435b3ce`). The owner then waived a third validation (E.1, "Stage 2 closed by the owner") |
| 3 | Metadata → Equipment / Device Import | Complete | 2026-09-26 | 2026-09-27 | **Fresh-session final sign-off PASS** at `92ebf2a` (`STAGE_3_FINAL_SIGNOFF.md`; S3F-01, S3F-02 non-blocking). Before that: FAIL at `387e54b`; a same-chat technical PASS at `d5e2b60` (`STAGE_3_REVALIDATION.md`); a fresh-session FAIL at `74026ca` (`STAGE_3_SIGNOFF_VALIDATION.md`, fixed by S3.V7/S3.V8). Device recheck S3V-08 unverified |
| 4 | Product Flow & Information Architecture | Complete | 2026-09-27 | 2026-09-27 | **Final, bounded validation PASS** at `09a7f06` (`STAGE_4_FINAL_VALIDATION.md`; the owner's seven questions; run in the authoring session at the owner's request, disclosed). Before that: **FAIL** at `adb5d95` (`STAGE_4_VALIDATION.md`, S4V-01), corrected by S4.V1. The fresh-session revalidation **FAILED** at `5ad69c4` (`STAGE_4_REVALIDATION.md`): S4R-01 and S4R-02 blocking, S4R-03 and S4R-04 low, all addressed by S4.V2 (the owner's R2 + D1). S4.V3 bounded the final validation, which then passed. S4V-02 is non-blocking and S4V-03 unverified |
| 5 | Design System Foundation | Complete | 2026-09-27 | 2026-09-27 | **FAIL** at `8a6c5d8` on one narrow blocker, S5V-01; S5.V1 (`178acbe`); **revalidation PASS** at `178acbe` ([report](STAGE_5_VALIDATION.md); same chat at the owner's request, disclosed) |
| 6 | Core Planner Redesign | Complete | 2026-09-27 | 2026-09-28 | **BLOCKED** at `6b50369` on one blocker, S6V-01 / TD-082; S6.V1 (`da4c53d`); **V5 revalidation PASS** at `da4c53d` ([report](STAGE_6_VALIDATION.md); same chat at the owner's request, disclosed). S6.E UNVERIFIED, a gap the owner accepted |
| 7 | Data Entry & Automation | Complete | 2026-09-28 | 2026-09-29 | **BLOCKED** at `d13fdab` (fresh-session independent validation): S7V-01 / TD-083 and S7V-02 / TD-084; S7.V1 (`46e7688`) and S7.V2 (`d28f5a8`); **V5 revalidation PASS** at `21e9cb1` ([report](STAGE_7_VALIDATION.md); same chat at the owner's request, disclosed) |
| 8 | Sessions / Execution / Actuals / Logbook | Complete | 2026-09-29 | 2026-09-29 | **PASS** at `690b94a` (fresh-session independent validation, [report](STAGE_8_VALIDATION.md)); no blocker; S8V-01 to S8V-03 recorded as TD-085 to TD-087 (non-blocking; fixed 2026-09-29) |
| 9 | Secondary UX & Product Polish | Complete | 2026-09-29 | 2026-09-30 | **S9.1–S9.9 PASS** at `8e53479` (fresh-session independent validation, [report](STAGE_9_VALIDATION.md)); no blocker; S9V-01 to S9V-03 recorded as TD-089 to TD-091 and fixed (`0f09608`). S9.10–S9.12 **deferred by the owner** 2026-09-30 (the logo and the identity were later decided by RA.D and S13.1; S9.11's licence question, RG-12, stays deferred) |
| 10 | Performance & Application Size | Complete | 2026-09-30 | 2026-09-30 | **PASS** at `3cb67be` (fresh-session independent validation, [report](STAGE_10_VALIDATION.md)); no blocker; S10V-01 to S10V-03 fixed, S10V-04 carried to Stage 11 |
| 11 | Full Validation & Beta Readiness | **Closed — superseded by Stage 17** (G3): S11.1–S11.5, S11.C1, S11.C2 done; S11.6 → S17.5, S11.7 → S17.7 | 2026-09-30 | 2026-10-17 | No readiness claimed; the final validation is S17.7 |
| 12 | Release foundation | Complete | 2026-10-17 | 2026-10-17 | **Bounded closure PASS** at `570581e` ([report](STAGE_12_13_CLOSURE.md)); S12.2 optional, not performed; S12V-01/02 follow-ups (both documentation, both since corrected: §8's RD-17 row and this table) |
| 13 | Identity: Culmina | Superseded by the approved roadmap (2026-10-18): S13V-01 / TD-109 → **F02**, S13V-02/03 → G2 | 2026-10-17 | — | S13.1, S13.2 PASS; S13.3 all but (2) before Android 12; reduced motion UNVERIFIED (S13V-02) ([report](STAGE_12_13_CLOSURE.md)) |
| 14–17 | Capture Plan, night conditions, screens, release | Superseded by the approved roadmap (2026-10-18) before starting; their Task IDs are aliases (roadmap §4) | — | — | — |

**Approved final completion roadmap** ([`FINAL_COMPLETION_ROADMAP.md`](FINAL_COMPLETION_ROADMAP.md), approved 2026-10-18): one row per roadmap Stage; Task completion rows go under "Current state".

| Roadmap Stage | Scope | Status | Tasks done |
| --- | --- | --- | --- |
| A | Protect existing data and startup: F01, F02 | In progress (run launched 2026-10-18); F01 implemented, acceptance pending | 0 / 2 verified |
| B | Capture Plan entry and calculations: F03–F12 | Not started | 0 / 10 |
| C | Night conditions, screens and saved records: F13–F25 | Not started | 0 / 13 |
| D | Qualify and deliver one signed GitHub release: G1, F26, G2, G3, G4 | Not started | 0 / 1 Task, 0 / 4 gates |

## How to update this file

- **Replace, don't append.** "Current state" and "Next allowed action" describe now. When they
  change, replace the old text; move anything worth keeping to `PROGRESS_HISTORY.md` verbatim. Do
  not keep superseded entries here.
- **At the end of every Task:** one line under "Current state" (Task, commit, finding IDs
  resolved, verification per the policy or the reused evidence); update the next Task; update any
  RG or RD it touched (resolved: date, and where the decision is written); update "Reusable
  validation evidence" if a check ran or its inputs changed.
- **At every Stage boundary:** update the Stage status table (dates, validation result in one
  line, with a link to the report); set the next allowed action; refresh "Known blockers" and
  "Carried items"; drop the closed Stage's detail from "Current state".
- **Registers live elsewhere:** RG and RD in `POST_ROADMAP_PLAN.md` §7–§8, TD in `TECH_DEBT.md`;
  this file lists only what is open and blocks or schedules work.
- **Validation results** go in the Stage's `STAGE_N_*.md` report; this file gets one line and the
  link. Record evidence reuse in one line (what, where it ran, why it still holds).
- Keep it short enough to read at the start of every session.

<!-- END VERBATIM PROGRESS 94cebfb -->


## Design-skills maintenance pre-fix snapshot — 2026-10-24

Source: `develop` HEAD `4ac20a9519d3444f2877c1ba5a61dd1f219b4659`, pre-existing dirty working tree before the owner's consolidated skills-maintenance task. Original PROGRESS bytes follow verbatim (SHA-256 `5dea0669ddf718e58a76d0a17e76bcd7268769bdd69ed86e757f90438bbeb0a0`). This snapshot includes the earlier uncommitted reconciliation, routing and validation handoffs; their permissions/next actions are inactive. Current status remains only in PROGRESS.md.

<!-- BEGIN verbatim maintenance pre-fix PROGRESS snapshot -->

# Culmina — current progress

Status: **current operational handoff**, reconciled 2026-10-24. Read [AGENTS](../../AGENTS.md) first. This file records state and the next allowed action; it does not activate historical scopes. Verification is governed only by [V1–V8](../VERIFICATION_POLICY.md).

## Current state

| Item | Current record and evidence boundary |
| --- | --- |
| Integration baseline | Documentation task base and unchanged HEAD: `develop` / `origin/develop` `4ac20a9519d3444f2877c1ba5a61dd1f219b4659`; one worktree at the owner checkout. Read-only `git ls-remote origin refs/heads/develop` on 2026-10-24 confirmed that exact remote head; local ahead/behind 0/0. The earlier governance cleanup is already delivered, not repeated. Application delivery remains `8a21e7b0a2018b223d8a1e4a73c4baa64167414f`. |
| Current authorized scope | Owner's separate 2026-10-24 validation-only behavioral probes of the updated Culmina design skills. Five fresh Codex CLI read-only sessions completed; permitted output is one concise report and this handoff. No application/skill/configuration/tooling edits, fixes, tests/analyzer/full gate, installation, auth/permission/settings/memory changes, commit/push/merge, build or device/data operations authorized. |
| Behavioral validation | **PARTIAL_WITH_ATTENTION**: [bounded report](../audit/CULMINA_DESIGN_SKILLS_BEHAVIOR_VALIDATION_2026_10_24.md). Natural selection of relevant skills and answer correctness passed in A–D; Git-only E read no design bodies. A/B fail the bounded-context criterion: observed full DESIGN_SYSTEM reads returned historical adoption/update sections. C/D/E pass. PBR-01 remains open for a separate narrowly authorized routing correction and A/B re-probe; no correction performed. Explicit-path controls NOT RUN because natural entrypoints were found; automatic activation/cross-client behavior is not claimed. |
| Routing/recipe result | [WORKFLOW modes](../design/WORKFLOW.md#work-modes) are the sole Explore / Implement-Fix / Review routing. [Skill router and three before/after routes](../../.agents/skills/README.md#reading-route-examples-before-and-after) lead to only relevant contracts/groups. Lab/font/browser history moved with provenance, equivalent links and legacy anchors to [optional history](../design/references/LAB_HISTORY.md); current native token mappings remain in [semantic map](../../.agents/skills/culmina-design-tokens/references/semantic-map.md). Layout diagnosis now follows axis/constraints/scroll owner and the real ParentData ancestor rule; adaptive/sidebar/grid/orientation and preview infrastructure require their named scope. Preview checks existing native fixtures, Culmina themes and actual SDK first. |
| Design-skill result | All three supplied findings reproduced at `4ac20a9` and corrected in [tokens](../../.agents/skills/culmina-design-tokens/SKILL.md), [navigation reference](../../.agents/skills/culmina-design-components/references/navigation.md), [spacing](../../.agents/skills/culmina-design-spacing/SKILL.md) and [DESIGN_SYSTEM](../DESIGN_SYSTEM.md). Definition/caller checks: HybridTokens + AppPalette/AppTheme → navigation, night-browser, Weather, fit/state displays; ContextLine → compact unframed Tonight, planner HybridPlanRow → PlanContextScreen; AppSpacing → Tonight/planner 20 px sides versus DetailScaffold 16 px. No token values or application behavior changed; no new implementation/decision conflict found in this bounded comparison. |
| Documentation verification | V1 on this validation's two-file Markdown change: report claims match completed JSONL tool calls/results; local references/anchors/paths/IDs, scope and `git diff --check` passed. Client `codex-cli 0.163.0`, fresh ephemeral read-only exec for each probe; five distinct thread IDs, terminal turn.completed and exit 0. Before-probe 16-file dirty-input SHA-256 `6dca672973371059fd48c103d1f346e719b9be78fc697f13a7b886afd26bd1aa`; unchanged 13-file routing-guidance SHA-256 `55fa5da65cc0394334d266fabbda9b454aff5c26e3ee75b41c010579c9d1ad94`. The report records the fingerprint recipe, frozen rubric and prompt/event aggregate. Live repository reads support routing/reasoning only; no runtime render, pixel/accessibility/device/owner/F/G PASS. |
| Cleanup delivery state | Documentation cleanup verified for owner review and the subsequent owner-authorized Git delivery: changed-document link/anchor/case/import checks, policy preservation, archive hashes, original-file scope comparison and `git diff --check` passed. Fresh Codex core-loading probe completed; independent source-snapshot review found no blocking documentation finding. Claude runtime review was access-blocked; Gemini/Antigravity runtime not tested. Details/limits: [cleanup report](../audit/AI_CONTEXT_CLEANUP_2026_10_24.md). No new application PASS. |
| Implemented and integrated | Completed Hybrid transfer; P-1–P-6 (TD-114–TD-119); TD-120/TD-121 Tonight/geo refinements; rounded refreshed-dark R3 identity and full Flutter launch gesture. Source map: [design/BASELINE](../design/BASELINE.md). [Consolidation delivery](../design/migration/CONSOLIDATED_DELIVERY_2026_10_24.md) records preservation and integration onto the current base. |
| Explicit owner acceptance | The owner confirmed the Hybrid transfer meets its bounded §9 contract: [transfer record](../design/migration/HYBRID_TRANSFER_STATUS.md), confirmation committed in `4f87c6c`. Its phone/performance/125–200%/store exclusions remain. ADR-021/ADR-022 were accepted 2026-10-18 in [DECISIONS](../DECISIONS.md). Neither fact accepts all later native changes or releases. |
| Acceptance still pending | Owner visual acceptance of P-1–P-6, TD-120/TD-121 and combined identity/current geo delivery remains as recorded. Emulator/host/physical observations do not substitute for the owner. See [TECH_DEBT](../TECH_DEBT.md) and consolidation's manual acceptance list. |
| Roadmap disposition | F01–F25 have historical implementation/evidence, with specific remaining criteria/findings. The finite pass ended **PARTIAL_WITH_ATTENTION**; the [independent 2026-10-19 review](DEVELOP_IMPLEMENTATION_REVIEW_2026_10_19.md) found incomplete F/G contracts. Later native deliveries do not automatically close them. F26 and G1–G4 are not claimed complete. The old broad launch is not active authorization in this cleanup. |
| Preservation | This validation began with 16 pre-existing dirty Markdown inputs (13 tracked modifications, three untracked references), empty index and unchanged develop HEAD `4ac20a9`. All original tracked/index diffs and file hashes matched after the five probes. Only the new audit report and this handoff were then changed; skills/application/test/tooling/configuration/assets/dependencies/frozen snapshots remain unchanged. Prior current-state entries are retained verbatim below; all carried owner/device/F/G criteria and historical evidence remain intact. Safe probe artifacts/manifests are retained locally outside Git; raw logs/private paths are excluded from the report. |

## Next allowed action

**Stop and wait for owner review or a separately authorized bounded task.** This validation is complete with PBR-01 open. A focused routing correction may address section-level DESIGN_SYSTEM loading and re-probe A/B only when authorized. Do not implement that fix, resume a roadmap, change skills/application code, run gates/builds/device/data operations or perform Git delivery from this handoff.

## Open questions and carried criteria

This is a current routing summary, not a newly adjudicated task register. Stable criteria, findings and original evidence remain in their canonical registers and the preserved history. Do not close an item by analogy with a newer passing test.

| IDs / surface | What remains / source for a future specifically authorized task |
| --- | --- |
| F01/F06/F10/F24 and review findings | The 2026-10-19 independent review records contradicted criteria and Windows failures at its dated baseline. Reproduce only relevant findings against current code before action; later implementation and passing suites do not prove their exact closure. [Review and criterion matrix](DEVELOP_IMPLEMENTATION_REVIEW_2026_10_19.md). |
| F03 A5 versus F10 A3; F04 A4 | F03's early sample/resource-recording criterion is distinct from F10's actual real-FITS workflow gate (as the independent review explains). Real metadata/device evidence needs the exact file/workflow and unchanged reader inputs. Private samples stay outside Git. No new real-file run is claimed here. |
| F02 A2/A3; S13V-01/TD-109; S13V-02/03 | Current launch/identity is integrated and API30/physical observations exist. The old “no SDK anywhere” explanation is obsolete; criterion-specific pre-12/12+, reduced-motion and timing qualification still needs explicit mapping to the final source/artifact/environment. Do not silently close historical device rows. |
| F15 A4; F22 A1; F23 A2 | Calendar phone timing, Android process death/restoration, resolved Android dependency notices: retain exact criteria and evidence gaps. An available SDK, emulator drive or host PASS alone is insufficient. |
| F25 A4, U/W; TD-114–TD-121 | Explicit owner visual acceptance, human comprehension, physical 200%/TalkBack and other unexercised rows remain separate from implemented/host/native evidence. Consult the named delivery reports for covered and excluded scenarios. |
| G1; F26 / D6; G2–G4 | Frozen integration/CI/provider, packaging/measurement, owner signing, physical/human rehearsal, go/no-go and publication conditions remain. The combined debug-signed owner test APK is not F26 release qualification. No gate closure or publication permission is inferred. |
| S1.5/S1.11, S2V-06, S3V-08, S10V-04, S11.6/S11.7 | Retained carried device/profile/human criteria: [STAGE_11_MATRIX](STAGE_11_MATRIX.md), [device runbook](STAGE_11_DEVICE_RUNBOOK.md) and historical dispositions. S6.E remains an owner-accepted **unverified** independent-participant gap, not a performed test. |
| TD-072/S3F-01/S3F-02; TD-074; other TD/SI | Use current [TECH_DEBT](../TECH_DEBT.md) / [SCIENTIFIC_INTEGRITY](../SCIENTIFIC_INTEGRITY.md) entries and exact partial-resolution boundaries, not old “open defects not fixed” lists. This cleanup changes no finding dispositions. |
| RD-02; RG-12; S12.2 | ADK skill / skills-lock / archive retention remains owner housekeeping, licence research remains deferred, trademark check remains optional. Preserve all material; none is deletion authority. [RG/RD registers](POST_ROADMAP_PLAN.md). |
| Original evidence / external overrides | Private historical backups/device captures were not assumed available or copied into Git. Uninspected managed/cloud overrides remain unknown. Local auto-memory contains dated continuation hints; repository sources take precedence within the applicable instruction hierarchy. |

## Reusable validation evidence

Apply [V3](../VERIFICATION_POLICY.md#v3) per result, relevant inputs and environment. No application checks run in this cleanup. Do not reuse old UI results for changed UI surfaces just because they passed once.

| Evidence | Input / applicability |
| --- | --- |
| [Combined delivery report](../design/migration/CONSOLIDATED_DELIVERY_2026_10_24.md) and [verification.json](../design/migration/evidence/consolidated-2026-10-24/verification.json) | Source `8a21e7b`; host suite/E2E plus final 16 regressions and final analysis/format/encoding, API30 seven-frame capture, normal launch/hot reload, scoped canonical-phone inspection. The report preserves the original analyzer failure; it does not label that whole invocation green. Application/test/build inputs from that source to this cleanup baseline are unchanged; only permitted Markdown changes follow. This is recorded evidence reuse, not a fresh application run or expanded acceptance. |
| [Hybrid transfer completion](../design/migration/HYBRID_TRANSFER_STATUS.md) | Its committed source, named pairs/Android captures and §9 owner's confirmation; later affected surfaces use their refinement reports. Exclusions stay explicit. |
| [P-1–P-6 delivery](../design/migration/PHONE_QA_FIXES_DELIVERY_2026_10_23.md), [TD-120](../design/migration/TONIGHT_CONTEXT_FIXES_2026_10_23.md), [TD-121](../design/migration/GEO_OWNER_REFINEMENT_2026_10_23.md) | Scoped host/native/physical observations on their recorded inputs. The consolidation states what remained unchanged; do not generalize to untested settings, owner acceptance or F/G gates. |
| Remote CI | Fresh GitHub connector read on 2026-10-24: run [40029616135](https://github.com/Buffur/Culmina/actions/runs/40029616135) completed/success at exact source `8a21e7b`. Build/test inputs from that source to this documentation cleanup are unchanged. This is observed existing CI evidence, not a new run or G1/F26/G2–G4 closure; the original consolidation “running” sentence remains historical. |

## Historical routing

The entire superseded PROGRESS at `94cebfb` is preserved verbatim with its SHA-256 in [PROGRESS_HISTORY](PROGRESS_HISTORY.md#governance-reconciliation-snapshot---2026-10-24): old run ledger, AM approvals/fingerprints, stages, blockers, Git/environment snapshots and contradictory next-action text. It preserves all IDs and provenance; its commands are inactive. [FINAL_COMPLETION_ROADMAP](FINAL_COMPLETION_ROADMAP.md) retains the frozen F/G/A/CHK contract and hash-bound annexes without edits; [POST_ROADMAP_PLAN](POST_ROADMAP_PLAN.md) retains RG/RD and earlier S-ID clauses.

<details>
<summary>Superseded operational entries from PROGRESS at 4ac20a9 (verbatim; inactive)</summary>

| Item | Current record and evidence boundary |
| --- | --- |
| Integration baseline | Before the owner-authorized cleanup delivery, `develop` and freshly fetched `origin/develop` were `94cebfb6b2a3379f5991e61e1bd88f7120804601`. The documentation successor is the cleanup commit containing this record; resolve its hash and remote delivery from Git. Application delivery: `8a21e7b0a2018b223d8a1e4a73c4baa64167414f`; only Markdown changed between that source and the baseline. GitHub default remains `main`; use explicit `develop` refs. Recheck this dated baseline at every new session. |
| Current authorized scope | Owner's 2026-10-24 documentation/governance cleanup: shared agent rules, current-state reconciliation, design source map, conservative historical routing and documentation verification. No application, tests, assets, platforms, dependencies, generators, web reference or CI changes. The owner subsequently authorized committing and pushing only these cleanup changes to develop after a fresh Git/scope check. No roadmap/new task, device installation/uninstall/data operation or global settings changes are authorized. |
| Preservation | Initial tree was clean: no staged/unstaged/untracked work, one worktree, develop ahead/behind 0/0, no unique unpublished commits across local branches. Local main's three commits ahead of origin/main are already reachable from develop. External original-file copies, SHA-256 tree/backup manifests and empty staged/unstaged patches were verified before editing. No bundle was needed for unique work. |

## Next allowed action

The owner authorized one commit and an ordinary push of this documentation cleanup to `develop`. Verify the staged paths/checks and actual remote delivery, then **stop and wait for owner review/acceptance or a new bounded task**. Do not resume F01–F26/G1–G4, redesign, build, install, commit or push from an older “next” line or delivery permission.

</details>


<details>
<summary>Superseded design-reconciliation handoff from the pre-routing working tree at 4ac20a9 (verbatim; inactive)</summary>

| Item | Current record and evidence boundary |
| --- | --- |
| Current authorized scope | Owner's 2026-10-24 bounded design-skill reconciliation: token mappings, ContextLine API/adoption and spacing semantics, directly related DESIGN_SYSTEM sections and this handoff only. Documentation work is complete; no commit, push, merge, build, install, device/data operations or roadmap continuation is authorized. |
| Documentation verification | V1 on the final five-file Markdown diff over `4ac20a9`: named paths/symbols, changed claims against definitions and actual callers, local references/anchors/case, cited IDs, allowed scope and `git diff --check` passed. Evidence is in this task's execution outputs (37 local links/anchors, 58 explicit paths, HT/TD IDs and source/caller checks); reconciled-document fingerprint is SHA-256 `fa857cf7113740db158c0294644cb58936b959f629d1ee14f633456066d2e790` (the four changed guidance documents, sorted path + NUL + LF text + NUL; excludes this handoff). Historical DESIGN_SYSTEM adoption/update sections and prior audit/evidence files remain unchanged. No Flutter tests/analyzer/full gate, frozen-inventory regeneration or fresh application/device/owner PASS. |
| Preservation | Initial tree/index were clean, one worktree, no unique unpublished local commits; sole writer for this task. Final unstaged changes are exactly five Markdown files: the three skill/reference files, DESIGN_SYSTEM and this PROGRESS handoff; no staged or untracked changes. Superseded operational entries from `4ac20a9` are retained verbatim below because history-file edits are outside this task. Existing owner/device/F/G acceptance rows and evidence limits remain. |

</details>


<details>
<summary>Superseded routing-task handoff from the pre-validation working tree at 4ac20a9 (verbatim; inactive)</summary>

| Item | Current record and evidence boundary |
| --- | --- |
| Current authorized scope | Owner's separate 2026-10-24 instruction-routing/recipe task: skill router, five Culmina design entrypoints/references, design WORKFLOW, three named Flutter recipes and this handoff. Work complete; no application change, SDK/plugin/dependency update, skills-lock edit, commit/push/merge, build or device/data operation authorized. |
| Documentation verification | V1 for this task's Markdown changes over the preserved pre-routing dirty state at `4ac20a9`: local links/anchors/case, named paths/IDs, eight entrypoints' frontmatter/schema/descriptions, retained upstream metadata, history/link/anchor preservation, source-based three-route walkthroughs, scope and `git diff --check` passed. Guidance fingerprint (13 files excluding this handoff; sorted path + NUL + LF text + NUL): SHA-256 `55fa5da65cc0394334d266fabbda9b454aff5c26e3ee75b41c010579c9d1ad94`. Evidence: this chat's execution outputs and [official-doc/SDK source record](../../.agents/skills/references/flutter-layout-preview-sources-2026-10-24.md). Upstream quick_validate.py could not run because PyYAML is absent in both available Python runtimes; independent validation checked the exact plain-scalar YAML form and schema without installation. Context7 plus precise official-API fallback and read-only Flutter 3.47.4 source inspection support technical text; no compiled/runtime preview, client auto-loading probe, application gate or new device/owner PASS is claimed. |
| Preservation | At this task's start, five prior uncommitted Markdown files were present and no staged/untracked work. Their bytes/patches and the recipe inputs were preserved with a verified manifest outside Git at `C:/Users/zalub/AppData/Local/Temp/culmina-routing-2026-10-24-0xd3x82o`. The prior DESIGN_SYSTEM and navigation-reference changes remain byte-for-byte intact; the corrected token map is preserved verbatim in its new reference. This task changes 11 existing Markdown files (including this handoff) and adds three necessary references: optional lab history, semantic mapping, shared dated Flutter API/SDK evidence. Cumulative working diff: 16 Markdown files; no unrelated/index changes. Prior operational entries remain verbatim below; carried owner/device/F/G criteria and historical evidence remain unchanged. |

## Next allowed action

**Stop and wait for owner review or another explicitly bounded task.** This documentation task is complete. The prior cleanup's Git delivery permission is historical; it authorizes no commit/push here. Do not begin application fixes, tests/builds, device/data operations or the next roadmap task.

</details>

## How to update this file

Replace current state/next action rather than stacking dated alternatives. Preserve superseded entries verbatim in PROGRESS_HISTORY with source/revision. Update only the task's relevant registers and record exact criteria/evidence, pending owner/device rows, input revision/reuse reason, next action and current permissions. Historical task authorization never silently restarts. Results go in their bounded report; this file keeps a short routing summary.

<!-- END verbatim maintenance pre-fix PROGRESS snapshot -->


## Design-skills delivery authorization — 2026-10-24

Superseded current rows/next action from the pre-delivery working tree at `4ac20a9`, retained verbatim. The owner subsequently authorized the reviewed Markdown package's commit and ordinary push to develop; this preserves the prior no-delivery boundary and does not authorize future work.

| Item | Current record and evidence boundary |
| --- | --- |
| Integration baseline | Unchanged `develop` HEAD `4ac20a9519d3444f2877c1ba5a61dd1f219b4659`, upstream `origin/develop`, local ahead/behind 0/0; one worktree. Remote freshness is limited to the earlier same-day read-only verification; no new fetch/delivery in this task. Application delivery remains `8a21e7b0a2018b223d8a1e4a73c4baa64167414f`. |
| Current authorized scope | Owner's consolidated bounded documentation/skills maintenance: five existing design skills/references, skill router/WORKFLOW, directly related active DESIGN_SYSTEM sections, three Flutter Markdown recipes and this handoff/history preservation. No application/test/tooling/configuration/assets/dependency/lockfile/frozen-reference edits, installation, Git delivery, builds or device/data operations. |

### Next allowed action (superseded)

**Stop and wait for owner review or another explicitly bounded task.** This maintenance cycle and its V1/independent probes are complete. No maintenance finding remains from this scope; existing owner/device/F/G criteria below are unchanged. No commit/push, new UI task, roadmap continuation, build/install or device/data operation is authorized.


## CI optimization pre-task snapshot - 2026-10-24

Source: `develop` at `56c4208e51b79a820955c2f3406a220efe1b359f`; original PROGRESS SHA-256 `a9822db86a7ce9d55832078087194fc34c38135b5c403a352ce60ce7a58328a0`. Preserved verbatim before the CI handoff update. Historical permissions and next actions below are inactive.

# Culmina — current progress

Status: **current operational handoff**, 2026-10-24. Read [AGENTS](../../AGENTS.md); [V1–V8](../VERIFICATION_POLICY.md) alone owns checks. This file records state, not an automatically active queue.

## Current state

| Item | Current record and evidence boundary |
| --- | --- |
| Integration baseline | Documentation-delivery base: `develop` HEAD `4ac20a9519d3444f2877c1ba5a61dd1f219b4659`, upstream `origin/develop`; fresh read-only remote-head verification on 2026-10-24 matched that exact SHA. The documentation successor is the commit containing this delivery record; resolve its hash and actual remote delivery from Git. Application delivery remains `8a21e7b0a2018b223d8a1e4a73c4baa64167414f`. |
| Current authorized scope | The maintenance cycle is complete. The owner subsequently requested delivery to develop on 2026-10-24, authorizing one coherent commit and ordinary push of the reviewed 19-file Markdown package after a fresh scope/Git check. This authorizes no application change, further task, build/install, device/data operation or future Git delivery. |
| Corrections | Earlier surface-sunken/Weather/sky/Moon/state mappings, compact unframed Tonight/planner distinction, 20px gutters and adopted typography/menu radius were verified and preserved. Added section-scoped contract routing for PBR-01 and the related-guidance maintenance rule. Corrected stale active component adoption/state/stacking-graph descriptions against native callers; preserved functional gradients/reduced motion. Sources: [WORKFLOW](../design/WORKFLOW.md#read-the-needed-contract), [DESIGN_SYSTEM](../DESIGN_SYSTEM.md), [component references](../../.agents/skills/culmina-design-components/SKILL.md). |
| Verification | **V1 PASS**: eight entrypoint frontmatters/schema/metadata; case-sensitive paths/symbols in three component references; source/caller consistency, preserved bytes/anchors and final scope; `git diff --check`. **Natural probes A/B/C/D/E PASS** in five distinct fresh Codex CLI 0.163.0 read-only ephemeral sessions: current Weather roles, compact Tonight + 20px gutter, local Plan roles, unbounded-flex diagnosis, Git-only negative routing. A/B returned section-scoped content without the historical appendix; PBR-01 is resolved for these reproduced cases. Explicit-path controls NOT RUN (not needed after natural routing succeeded); no automatic activation or cross-client guarantee. Final 17-file guidance SHA-256 `7cba80a430d658cdd4f0ddac00bf58f0c347506eccce4df97e9e31883380803e` (sorted path + NUL + LF UTF-8 text + NUL); pre-probe dirty snapshot `ee3aa1405989afbda48616bb9c3ee758f77a4d0366444fd2dc475eb8ca14b4a4`; prompt/event aggregate `69784c7536ad85e4b4ccbdb44aec18d29157253859be685438ee8c60fe7cc0b5`. Safe traces/rubric/snapshots remain local outside Git; no new audit. Same-day official Flutter sources were reused with unchanged installed SDK 3.47.4; preview/compile/client auto-loading and all application/device gates NOT RUN. Upstream quick_validate.py remains unavailable without PyYAML; independent exact-form/schema validation passed without installation. |
| Acceptance boundary | Hybrid transfer remains accepted only within its recorded §9 contract. P-1–P-6, TD-120/TD-121 and combined identity/geo owner visual acceptance, physical 200%/TalkBack and F/G/release conditions remain pending as recorded. Source/implemented state does not self-approve owner/device criteria. |
| Preservation | Preflight: 17 pre-existing dirty Markdown inputs, empty index, HEAD unchanged. Recoverable originals, patches and verified SHA-256 manifest were saved outside Git before edits. Earlier audit/evidence, lab history, native/app/reference bytes and unrelated work are preserved. The entire previous PROGRESS is now verbatim in [PROGRESS_HISTORY](PROGRESS_HISTORY.md#design-skills-maintenance-pre-fix-snapshot--2026-10-24), with its original-byte hash and inactive permissions. |

## Next allowed action

**Stop after the owner-authorized documentation commit/push and verification of the exact remote SHA.** Then wait for owner review or a new bounded task. Maintenance and its V1/independent probes are complete; carried owner/device/F/G criteria remain unchanged. This delivery permission does not activate another UI task, roadmap continuation, build/install or device/data operation.

## Open questions and carried criteria

This is a current routing summary, not a newly adjudicated task register. Stable criteria, findings and original evidence remain in their canonical registers and the preserved history. Do not close an item by analogy with a newer passing test.

| IDs / surface | What remains / source for a future specifically authorized task |
| --- | --- |
| F01/F06/F10/F24 and review findings | The 2026-10-19 independent review records contradicted criteria and Windows failures at its dated baseline. Reproduce only relevant findings against current code before action; later implementation and passing suites do not prove their exact closure. [Review and criterion matrix](DEVELOP_IMPLEMENTATION_REVIEW_2026_10_19.md). |
| F03 A5 versus F10 A3; F04 A4 | F03's early sample/resource-recording criterion is distinct from F10's actual real-FITS workflow gate (as the independent review explains). Real metadata/device evidence needs the exact file/workflow and unchanged reader inputs. Private samples stay outside Git. No new real-file run is claimed here. |
| F02 A2/A3; S13V-01/TD-109; S13V-02/03 | Current launch/identity is integrated and API30/physical observations exist. The old “no SDK anywhere” explanation is obsolete; criterion-specific pre-12/12+, reduced-motion and timing qualification still needs explicit mapping to the final source/artifact/environment. Do not silently close historical device rows. |
| F15 A4; F22 A1; F23 A2 | Calendar phone timing, Android process death/restoration, resolved Android dependency notices: retain exact criteria and evidence gaps. An available SDK, emulator drive or host PASS alone is insufficient. |
| F25 A4, U/W; TD-114–TD-121 | Explicit owner visual acceptance, human comprehension, physical 200%/TalkBack and other unexercised rows remain separate from implemented/host/native evidence. Consult the named delivery reports for covered and excluded scenarios. |
| G1; F26 / D6; G2–G4 | Frozen integration/CI/provider, packaging/measurement, owner signing, physical/human rehearsal, go/no-go and publication conditions remain. The combined debug-signed owner test APK is not F26 release qualification. No gate closure or publication permission is inferred. |
| S1.5/S1.11, S2V-06, S3V-08, S10V-04, S11.6/S11.7 | Retained carried device/profile/human criteria: [STAGE_11_MATRIX](STAGE_11_MATRIX.md), [device runbook](STAGE_11_DEVICE_RUNBOOK.md) and historical dispositions. S6.E remains an owner-accepted **unverified** independent-participant gap, not a performed test. |
| TD-072/S3F-01/S3F-02; TD-074; other TD/SI | Use current [TECH_DEBT](../TECH_DEBT.md) / [SCIENTIFIC_INTEGRITY](../SCIENTIFIC_INTEGRITY.md) entries and exact partial-resolution boundaries, not old “open defects not fixed” lists. This cleanup changes no finding dispositions. |
| RD-02; RG-12; S12.2 | ADK skill / skills-lock / archive retention remains owner housekeeping, licence research remains deferred, trademark check remains optional. Preserve all material; none is deletion authority. [RG/RD registers](POST_ROADMAP_PLAN.md). |
| Original evidence / external overrides | Private historical backups/device captures were not assumed available or copied into Git. Uninspected managed/cloud overrides remain unknown. Local auto-memory contains dated continuation hints; repository sources take precedence within the applicable instruction hierarchy. |

## Reusable validation evidence

Apply [V3](../VERIFICATION_POLICY.md#v3) per result, relevant inputs and environment. No application checks run in this cleanup. Do not reuse old UI results for changed UI surfaces just because they passed once.

| Evidence | Input / applicability |
| --- | --- |
| [Combined delivery report](../design/migration/CONSOLIDATED_DELIVERY_2026_10_24.md) and [verification.json](../design/migration/evidence/consolidated-2026-10-24/verification.json) | Source `8a21e7b`; host suite/E2E plus final 16 regressions and final analysis/format/encoding, API30 seven-frame capture, normal launch/hot reload, scoped canonical-phone inspection. The report preserves the original analyzer failure; it does not label that whole invocation green. Application/test/build inputs from that source to this cleanup baseline are unchanged; only permitted Markdown changes follow. This is recorded evidence reuse, not a fresh application run or expanded acceptance. |
| [Hybrid transfer completion](../design/migration/HYBRID_TRANSFER_STATUS.md) | Its committed source, named pairs/Android captures and §9 owner's confirmation; later affected surfaces use their refinement reports. Exclusions stay explicit. |
| [P-1–P-6 delivery](../design/migration/PHONE_QA_FIXES_DELIVERY_2026_10_23.md), [TD-120](../design/migration/TONIGHT_CONTEXT_FIXES_2026_10_23.md), [TD-121](../design/migration/GEO_OWNER_REFINEMENT_2026_10_23.md) | Scoped host/native/physical observations on their recorded inputs. The consolidation states what remained unchanged; do not generalize to untested settings, owner acceptance or F/G gates. |
| Remote CI | Fresh GitHub connector read on 2026-10-24: run [40029616135](https://github.com/Buffur/Culmina/actions/runs/40029616135) completed/success at exact source `8a21e7b`. Build/test inputs from that source to this documentation cleanup are unchanged. This is observed existing CI evidence, not a new run or G1/F26/G2–G4 closure; the original consolidation “running” sentence remains historical. |

## Historical routing

The [maintenance pre-fix snapshot](PROGRESS_HISTORY.md#design-skills-maintenance-pre-fix-snapshot--2026-10-24) preserves the previous handoff and its earlier nested records verbatim. Earlier governance/stage history and immutable audits/evidence retain their original bytes. Their old commands/permissions are inactive; [BASELINE](../design/BASELINE.md) maps accepted intent, implementation and evidence limits.

## How to update this file

Keep one short current handoff; preserve superseded status verbatim with source/revision in PROGRESS_HISTORY under AI_WORKFLOW. Update only invalidated claims/related registers, retain stable IDs and exact evidence/acceptance boundaries, then stop at the owner's task boundary.


## CI delivery pre-result handoff - 2026-10-24

Source: `develop` at `50f82eb6d54e2e389c56e85f047a79869d7dc6eb`; original PROGRESS SHA-256 `8ee335875f25d29b6ed0e1057713f8dc6ca2ac31ff465219757719f545165b66`. Preserved verbatim before recording the completed remote CI result. Superseded status and permissions below are inactive.

# Culmina — current progress

Status: **current operational handoff**, 2026-10-24. Read [AGENTS](../../AGENTS.md); [V1–V8](../VERIFICATION_POLICY.md) alone owns checks. This file records state, not an automatically active queue.

## Current state

| Item | Current record and evidence boundary |
| --- | --- |
| Integration baseline | `develop` / `origin/develop` at `56c4208e51b79a820955c2f3406a220efe1b359f`, verified by fresh remote-head read; preflight clean, empty index and one worktree. CI optimization is currently uncommitted. The earlier design-skills commit is already delivered. |
| Current authorized scope | Bounded CI/test-fixture optimization without application behavior or coverage changes. The owner separately authorized the prepared CI commit/push on 2026-10-24 and observation of its new run. This authorizes the bounded CI delivery and its final measurement/handoff, not app build/install or device/data operations. |
| Changes | SDK/pub cache; three measured file-balanced unit shards, independent static job and parallel per-file host E2E; complete machine streams/receipts and fail-closed stable `quality-gate`; V1 documentation classification including AGENTS/GEMINI/.claude rules. Android-only skipped host startups removed, device contracts unchanged. Accessibility settles pending IO instead of fixed repeated sleeps; all routes/themes/scales/assertions retained. [CI details](../CI.md). |
| Local verification | **PASS**: 2509 unit/widget + 6 SKIP across 285 files exactly once, host E2E 3 PASS in separate processes; exact unit file/name/outcome multiset equals baseline (SHA-256 `3caf5bdd9d52388f030328b5b85b22545ab057128b55aa162a99660dbbe04c44`). Static runner encoding/645-file unchanged format/analysis PASS; 8 Python tooling regressions, YAML/trigger/required-check semantics and scope checks PASS. One initial full baseline and final partitioned set; isolated accessibility before/after 16 PASS each, reporter 125.474s -> 73.847s. Final helper error-propagation review: targeted accessibility recheck 16 PASS, same names/outcomes. No native/device acceptance inferred. |
| Remote evidence / pending criterion | Existing CI #21 success at `4ac20a9`: job 778s / 12.967 runner-minutes; authenticated logs confirm unit 456.323s, host 199.282s including 50.227s in Android-only skipped startups. New changed-workflow green run and comparable wall-time/runner-minutes remain **PENDING newly authorized CI delivery/run**. No remote speedup/cache-hit claim yet. [Baseline JSON](../ci-baseline-2026-10-24.json). |
| Acceptance boundary | Hybrid transfer remains accepted only within its recorded §9 contract. P-1–P-6, TD-120/TD-121 and combined identity/geo owner visual acceptance, physical 200%/TalkBack and F/G/release conditions remain pending as recorded. Host/CI evidence does not self-approve owner/device criteria. |
| Preservation | Production code, assets, platform folders, dependency/lockfiles, integration fixtures, frozen evidence and all unrelated bytes unchanged. Original PROGRESS preserved verbatim with source/hash in [history](PROGRESS_HISTORY.md#ci-optimization-pre-task-snapshot---2026-10-24). Raw JSONL profiles/logs/receipts and preservation snapshot are outside Git in the session temporary `culmina-ci-2026-10-24` folder; no private samples/secrets inspected. |

## Next allowed action

**Commit/push the owner-authorized prepared CI change.** Then observe the actual new Actions run, compare wall-clock and summed job runner-minutes (including cold/warm cache outcomes), confirm inventory/outcomes and update this handoff. Until then this goal is locally verified but incomplete. No repeated full suite merely for a new commit/date; investigate actual changed-input failures if any. Stop after the bounded CI result/report; no roadmap/UI/device work follows.

## Open questions and carried criteria

This is a current routing summary, not a newly adjudicated task register. Stable criteria, findings and original evidence remain in their canonical registers and the preserved history. Do not close an item by analogy with a newer passing test.

| IDs / surface | What remains / source for a future specifically authorized task |
| --- | --- |
| F01/F06/F10/F24 and review findings | The 2026-10-19 independent review records contradicted criteria and Windows failures at its dated baseline. Reproduce only relevant findings against current code before action; later implementation and passing suites do not prove their exact closure. [Review and criterion matrix](DEVELOP_IMPLEMENTATION_REVIEW_2026_10_19.md). |
| F03 A5 versus F10 A3; F04 A4 | F03's early sample/resource-recording criterion is distinct from F10's actual real-FITS workflow gate (as the independent review explains). Real metadata/device evidence needs the exact file/workflow and unchanged reader inputs. Private samples stay outside Git. No new real-file run is claimed here. |
| F02 A2/A3; S13V-01/TD-109; S13V-02/03 | Current launch/identity is integrated and API30/physical observations exist. The old “no SDK anywhere” explanation is obsolete; criterion-specific pre-12/12+, reduced-motion and timing qualification still needs explicit mapping to the final source/artifact/environment. Do not silently close historical device rows. |
| F15 A4; F22 A1; F23 A2 | Calendar phone timing, Android process death/restoration, resolved Android dependency notices: retain exact criteria and evidence gaps. An available SDK, emulator drive or host PASS alone is insufficient. |
| F25 A4, U/W; TD-114–TD-121 | Explicit owner visual acceptance, human comprehension, physical 200%/TalkBack and other unexercised rows remain separate from implemented/host/native evidence. Consult the named delivery reports for covered and excluded scenarios. |
| G1; F26 / D6; G2–G4 | Frozen integration/CI/provider, packaging/measurement, owner signing, physical/human rehearsal, go/no-go and publication conditions remain. The combined debug-signed owner test APK is not F26 release qualification. No gate closure or publication permission is inferred. |
| S1.5/S1.11, S2V-06, S3V-08, S10V-04, S11.6/S11.7 | Retained carried device/profile/human criteria: [STAGE_11_MATRIX](STAGE_11_MATRIX.md), [device runbook](STAGE_11_DEVICE_RUNBOOK.md) and historical dispositions. S6.E remains an owner-accepted **unverified** independent-participant gap, not a performed test. |
| TD-072/S3F-01/S3F-02; TD-074; other TD/SI | Use current [TECH_DEBT](../TECH_DEBT.md) / [SCIENTIFIC_INTEGRITY](../SCIENTIFIC_INTEGRITY.md) entries and exact partial-resolution boundaries, not old “open defects not fixed” lists. This cleanup changes no finding dispositions. |
| RD-02; RG-12; S12.2 | ADK skill / skills-lock / archive retention remains owner housekeeping, licence research remains deferred, trademark check remains optional. Preserve all material; none is deletion authority. [RG/RD registers](POST_ROADMAP_PLAN.md). |
| Original evidence / external overrides | Private historical backups/device captures were not assumed available or copied into Git. Uninspected managed/cloud overrides remain unknown. Local auto-memory contains dated continuation hints; repository sources take precedence within the applicable instruction hierarchy. |

## Reusable validation evidence

Apply [V3](../VERIFICATION_POLICY.md#v3) per result, relevant inputs and environment. The CI task ran the complete host suite on its final relevant inputs. Device/owner evidence below retains its original scope; passing host tests do not approve those rows.

| Evidence | Input / applicability |
| --- | --- |
| [Combined delivery report](../design/migration/CONSOLIDATED_DELIVERY_2026_10_24.md) and [verification.json](../design/migration/evidence/consolidated-2026-10-24/verification.json) | Source `8a21e7b`; host suite/E2E plus final 16 regressions and final analysis/format/encoding, API30 seven-frame capture, normal launch/hot reload, scoped canonical-phone inspection. The report preserves the original analyzer failure; it does not label that whole invocation green. Application/test/build inputs from that source to this cleanup baseline are unchanged; only permitted Markdown changes follow. This is recorded evidence reuse, not a fresh application run or expanded acceptance. |
| [Hybrid transfer completion](../design/migration/HYBRID_TRANSFER_STATUS.md) | Its committed source, named pairs/Android captures and §9 owner's confirmation; later affected surfaces use their refinement reports. Exclusions stay explicit. |
| [P-1–P-6 delivery](../design/migration/PHONE_QA_FIXES_DELIVERY_2026_10_23.md), [TD-120](../design/migration/TONIGHT_CONTEXT_FIXES_2026_10_23.md), [TD-121](../design/migration/GEO_OWNER_REFINEMENT_2026_10_23.md) | Scoped host/native/physical observations on their recorded inputs. The consolidation states what remained unchanged; do not generalize to untested settings, owner acceptance or F/G gates. |
| Remote CI | Fresh GitHub connector read on 2026-10-24: run [40029616135](https://github.com/Buffur/Culmina/actions/runs/40029616135) completed/success at exact source `8a21e7b`. Build/test inputs from that source to this documentation cleanup are unchanged. This is observed existing CI evidence, not a new run or G1/F26/G2–G4 closure; the original consolidation “running” sentence remains historical. |

## Historical routing

The [CI pre-task snapshot](PROGRESS_HISTORY.md#ci-optimization-pre-task-snapshot---2026-10-24) preserves the complete previous operational handoff. The [maintenance pre-fix snapshot](PROGRESS_HISTORY.md#design-skills-maintenance-pre-fix-snapshot--2026-10-24) preserves the previous handoff and its earlier nested records verbatim. Earlier governance/stage history and immutable audits/evidence retain their original bytes. Their old commands/permissions are inactive; [BASELINE](../design/BASELINE.md) maps accepted intent, implementation and evidence limits.

## How to update this file

Keep one short current handoff; preserve superseded status verbatim with source/revision in PROGRESS_HISTORY under AI_WORKFLOW. Update only invalidated claims/related registers, retain stable IDs and exact evidence/acceptance boundaries, then stop at the owner's task boundary.


## Warm-cache shard comparison pre-task handoff - 2026-10-24

Source: `develop` at `c045898d93b5e43112895592ba1d7ddb6cd26615`. Canonical Git-blob PROGRESS SHA-256 `bc6b686aef6661ed35d62326afda876fe9ae803ded042b86b7a3522afd64a66b`; source preserved verbatim below. Earlier completed scope/delivery permissions do not authorize this new benchmark publication.

# Culmina — current progress

Status: **current operational handoff**, 2026-10-24. Read [AGENTS](../../AGENTS.md); [V1–V8](../VERIFICATION_POLICY.md) alone owns checks. This file records state, not an automatically active queue.

## Current state

| Item | Current record and evidence boundary |
| --- | --- |
| Integration baseline | CI implementation `50f82eb6d54e2e389c56e85f047a79869d7dc6eb` is committed and pushed to `develop`; exact remote SHA verified. Final documentation follows with unchanged application/test/tooling inputs. Original preflight was clean at `56c4208`, empty index, one worktree. |
| Current authorized scope | Bounded CI optimization and owner-authorized Git delivery are complete. The remaining final documentation commit/push and observation of its lightweight CI check are within this delivery; no future roadmap/UI/build/install/device/data or unrelated Git action is authorized. |
| Changes | SDK/pub cache; three measured file-balanced unit shards, independent static job and parallel per-file host E2E; complete machine streams/receipts and fail-closed stable `quality-gate`; V1 documentation classification includes AGENTS/GEMINI/.claude rules. Android-only skipped host startups removed, device contracts unchanged. Accessibility settles pending IO instead of fixed repeated sleeps; routes/themes/scales/assertions retained. [CI details and measurements](../CI.md). |
| Verification | **PASS locally and in actual remote CI #22**: 2509 unit/widget + 6 SKIP across 285 files exactly once, host E2E 3 PASS in separate processes. All six raw-report ZIP SHA-256 digests match GitHub; receipt profiles reconstructed from raw JSONL; exact unit file/name/outcome multiset equals baseline (SHA-256 `3caf5bdd9d52388f030328b5b85b22545ab057128b55aa162a99660dbbe04c44`). Encoding, unchanged format of 645 files, full analysis, 8 Python regressions, final helper 16-test recheck/targeted analysis, YAML/trigger/required-check and scope checks PASS. Isolated accessibility reporter 125.474s -> 73.847s; no native/device acceptance inferred. |
| Remote result / cost | [CI #22](https://github.com/Buffur/Culmina/actions/runs/40045313426) **success** on exact `50f82eb`. Compared with #21 at `4ac20a9`, workflow elapsed **782s -> 326s (-58.3%)**; summed job time **778s -> 1284s (12.967 -> 21.400 runner-minutes, +65.0%)**. All six SDK/pub restores were cold misses; both caches were saved, warm savings unmeasured. Same Ubuntu image and Flutter 3.47.4. Tradeoff is lower latency at higher cold runner usage, with unchanged coverage/behavior. Full metric definitions and durable machine summary: [CI](../CI.md#remote-result---2026-10-24). |
| Acceptance boundary | Hybrid transfer remains accepted only within its recorded section 9 contract. P-1 through P-6, TD-120/TD-121 and combined identity/geo owner visual acceptance, physical 200%/TalkBack and F/G/release conditions remain pending as recorded. This CI optimization closes none of those separate criteria. |
| Preservation | Production code, assets, platform folders, dependency/lockfiles, integration fixtures, frozen evidence and unrelated bytes unchanged. Prior complete handoffs preserved verbatim with source/hash in [history](PROGRESS_HISTORY.md#ci-delivery-pre-result-handoff---2026-10-24). Raw local/remote reports remain outside Git in temporary `culmina-ci-2026-10-24`; Actions artifacts expire 2026-11-07. No private samples/secrets inspected. |

## Next allowed action

**Stop after the final documentation commit/push, exact remote-SHA check and its lightweight documentation-only CI check.** The optimization, full remote run, preserved coverage and measured time/cost comparison are complete. No further full suite is required for unchanged test/build inputs. Warm-cache timing and an executed two-shard benchmark were not run and are not needed for this bounded delivery; neither has a measured saving claimed. Wait for the owner's next bounded task.

## Open questions and carried criteria

This is a current routing summary, not a newly adjudicated task register. Stable criteria, findings and original evidence remain in their canonical registers and the preserved history. Do not close an item by analogy with a newer passing test.

| IDs / surface | What remains / source for a future specifically authorized task |
| --- | --- |
| F01/F06/F10/F24 and review findings | The 2026-10-19 independent review records contradicted criteria and Windows failures at its dated baseline. Reproduce only relevant findings against current code before action; later implementation and passing suites do not prove their exact closure. [Review and criterion matrix](DEVELOP_IMPLEMENTATION_REVIEW_2026_10_19.md). |
| F03 A5 versus F10 A3; F04 A4 | F03's early sample/resource-recording criterion is distinct from F10's actual real-FITS workflow gate (as the independent review explains). Real metadata/device evidence needs the exact file/workflow and unchanged reader inputs. Private samples stay outside Git. No new real-file run is claimed here. |
| F02 A2/A3; S13V-01/TD-109; S13V-02/03 | Current launch/identity is integrated and API30/physical observations exist. The old “no SDK anywhere” explanation is obsolete; criterion-specific pre-12/12+, reduced-motion and timing qualification still needs explicit mapping to the final source/artifact/environment. Do not silently close historical device rows. |
| F15 A4; F22 A1; F23 A2 | Calendar phone timing, Android process death/restoration, resolved Android dependency notices: retain exact criteria and evidence gaps. An available SDK, emulator drive or host PASS alone is insufficient. |
| F25 A4, U/W; TD-114–TD-121 | Explicit owner visual acceptance, human comprehension, physical 200%/TalkBack and other unexercised rows remain separate from implemented/host/native evidence. Consult the named delivery reports for covered and excluded scenarios. |
| G1; F26 / D6; G2–G4 | Frozen integration/CI/provider, packaging/measurement, owner signing, physical/human rehearsal, go/no-go and publication conditions remain. The combined debug-signed owner test APK is not F26 release qualification. No gate closure or publication permission is inferred. |
| S1.5/S1.11, S2V-06, S3V-08, S10V-04, S11.6/S11.7 | Retained carried device/profile/human criteria: [STAGE_11_MATRIX](STAGE_11_MATRIX.md), [device runbook](STAGE_11_DEVICE_RUNBOOK.md) and historical dispositions. S6.E remains an owner-accepted **unverified** independent-participant gap, not a performed test. |
| TD-072/S3F-01/S3F-02; TD-074; other TD/SI | Use current [TECH_DEBT](../TECH_DEBT.md) / [SCIENTIFIC_INTEGRITY](../SCIENTIFIC_INTEGRITY.md) entries and exact partial-resolution boundaries, not old “open defects not fixed” lists. This cleanup changes no finding dispositions. |
| RD-02; RG-12; S12.2 | ADK skill / skills-lock / archive retention remains owner housekeeping, licence research remains deferred, trademark check remains optional. Preserve all material; none is deletion authority. [RG/RD registers](POST_ROADMAP_PLAN.md). |
| Original evidence / external overrides | Private historical backups/device captures were not assumed available or copied into Git. Uninspected managed/cloud overrides remain unknown. Local auto-memory contains dated continuation hints; repository sources take precedence within the applicable instruction hierarchy. |

## Reusable validation evidence

Apply [V3](../VERIFICATION_POLICY.md#v3) per result, relevant inputs and environment. The CI task ran the complete host suite on its final relevant inputs. Device/owner evidence below retains its original scope; passing host tests do not approve those rows.

| Evidence | Input / applicability |
| --- | --- |
| [Combined delivery report](../design/migration/CONSOLIDATED_DELIVERY_2026_10_24.md) and [verification.json](../design/migration/evidence/consolidated-2026-10-24/verification.json) | Source `8a21e7b`; host suite/E2E plus final 16 regressions and final analysis/format/encoding, API30 seven-frame capture, normal launch/hot reload, scoped canonical-phone inspection. The report preserves the original analyzer failure; it does not label that whole invocation green. Application/native inputs remain unchanged. The current CI task changes test/tooling inputs, so its new host/CI results above supersede this older host-gate result; native evidence retains its original coverage and acceptance limits. |
| [Hybrid transfer completion](../design/migration/HYBRID_TRANSFER_STATUS.md) | Its committed source, named pairs/Android captures and §9 owner's confirmation; later affected surfaces use their refinement reports. Exclusions stay explicit. |
| [P-1–P-6 delivery](../design/migration/PHONE_QA_FIXES_DELIVERY_2026_10_23.md), [TD-120](../design/migration/TONIGHT_CONTEXT_FIXES_2026_10_23.md), [TD-121](../design/migration/GEO_OWNER_REFINEMENT_2026_10_23.md) | Scoped host/native/physical observations on their recorded inputs. The consolidation states what remained unchanged; do not generalize to untested settings, owner acceptance or F/G gates. |
| Historical application CI | Fresh GitHub connector read on 2026-10-24: run [40029616135](https://github.com/Buffur/Culmina/actions/runs/40029616135) completed/success at exact source `8a21e7b`. Historical observed CI at its source; current changed test/tooling inputs are verified by #22 above. This older run is not the new CI result or G1/F26/G2-G4 closure; the original consolidation status remains historical. |

## Historical routing

The [remote-result pre-handoff snapshot](PROGRESS_HISTORY.md#ci-delivery-pre-result-handoff---2026-10-24) preserves the completed implementation handoff. The [CI pre-task snapshot](PROGRESS_HISTORY.md#ci-optimization-pre-task-snapshot---2026-10-24) preserves the complete previous operational handoff. The [maintenance pre-fix snapshot](PROGRESS_HISTORY.md#design-skills-maintenance-pre-fix-snapshot--2026-10-24) preserves the previous handoff and its earlier nested records verbatim. Earlier governance/stage history and immutable audits/evidence retain their original bytes. Their old commands/permissions are inactive; [BASELINE](../design/BASELINE.md) maps accepted intent, implementation and evidence limits.

## How to update this file

Keep one short current handoff; preserve superseded status verbatim with source/revision in PROGRESS_HISTORY under AI_WORKFLOW. Update only invalidated claims/related registers, retain stable IDs and exact evidence/acceptance boundaries, then stop at the owner's task boundary.
