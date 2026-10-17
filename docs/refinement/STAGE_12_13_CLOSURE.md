# Stages 12 and 13 — bounded closure validation

> **Date:** 2026-10-17. **Baseline:** `570581e` (= `origin/main`). Remote CI run
> [39042823307](https://github.com/Buffur/Culmina/actions/runs/39042823307) is `success` on that commit, read
> from the GitHub REST API on 2026-10-17.
> **Working tree:** uncommitted documentation from other work:
> - `refinement/STAGES_12_17_AUDIT_AMENDMENTS.md` and its edits to `POST_ROADMAP_PLAN.md`, `PROGRESS.md`,
>   `DECISIONS.md`, `TECH_DEBT.md`, `PRODUCT_DIRECTION.md`, the readiness review and `CLAUDE.md`;
> - `audit/09_COMPREHENSIVE_AUDIT.md`;
> - a modified macOS plugin registrant.
>
> None of these is judged or changed here. This record is the only file this validation adds.
> **Session (V8, disclosed):** run in the session that wrote audit 09, at the owner's request ("Do this task
> here"). This session built nothing in Stages 12 and 13; it is not a fresh session.
> **Procedure:** CLAUDE.md V1–V8. Validation only: nothing is fixed here (V7).

## 1. Frozen acceptance surface

Judged against the **committed** Task rows (`POST_ROADMAP_PLAN.md` at `570581e`, Stages 12 and 13) and the
committed owner decisions.

| ID | Criteria (source) |
| --- | --- |
| S12.1 | (1) failing test named; (2) root cause in TD-104; (3) fixed, nothing skipped or weakened; (4) `actions/checkout` off Node 20, runner pinned; (5) local full gate; (6) a passing remote run on `main`, read from GitHub; (7) TD-104 and RD-17 updated |
| S12.2 | Owner action, recommended, **not a gate** (GitHub-only distribution amendment). If skipped, the documented naming risk stays the record |
| S12.3 | (1) the policy text: TD-099's wording, the 16-night request (PD-16), links the user opens (Clear Outside), the owner's contact; (2) repository renamed, Pages on, policy, project and source URLs answer 200; (3) `Astro-Planner` never recreated |
| S12.4 | The owner chooses (a) or (b). (a) means stating it in COMPLIANCE and About; the About statement moved to S16.8 by readiness correction C4 |
| S13.1 | (1)–(4) as superseded by the owner's decisions (DECISIONS E.1: round 1 not approved; C4 Orbit C; R3; R3-final approved): review evidence with masks, small sizes and the themed icon; stored under `evidence/identity/`; approval recorded |
| S13.2 | Task (1)–(6), plus `RA_D_IDENTITY_TRANSITION.md` §3, criteria 1–10 |
| S13.3 | (1) the mark in `ic_launcher_foreground.xml` and `tool/make_launcher_icons.py`, a monochrome layer, legacy PNGs, `icon_512.png`; (2) an AVD splash on Android 12+ at most 1,000 ms — "no start delay" **amended by the owner** to a hold until it has played (DECISIONS E.1, 2026-10-17) — and **the static icon before 12**; (3) the Flutter mark only while loading, static without animations, nothing before the first frame; (4) cold start measured on the phone before and after; (5) no new package |
| Decisions | ID-1 to ID-6 as amended; GitHub-only distribution; S12.3 contact; S12.4 (a); S13.1 R3-final; S13.3 held splash |
| Traps | 20 (identity); 21 (signing: not touched); 22 (privacy) |

**Not in the surface:**
- The uncommitted integration's reworded S13.1 and S13.3 criteria. They are prospective; where useful they
  are noted below.
- Audit 09's proposed amendments, which concern Stages 14–17.

## 2. Evidence and judgments

**Fresh evidence (this validation, 2026-10-17):**
- the GitHub API: CI `success` on `570581e`;
- `curl`: `https://buffur.github.io/Culmina/`, `…/privacy/` and `https://github.com/Buffur/Culmina` answer
  **200**; `https://github.com/Buffur/Astro-Planner` redirects to `Buffur/Culmina`;
- source checks at `570581e`:
  - no `chacha12` or `astroplanner` in `lib/`, `android/`, `test/`, `integration_test/` or `tool/`;
  - the metadata channel is `io.github.buffur.culmina/metadata_document` on both sides
    (`android_capture_file_access.dart:15`, `MetadataDocumentChannel.kt:32`);
  - the launcher foreground's three paths and colours equal `round5/R3-final-colour.svg`'s;
  - the generator uses centre (54, 54), R 22 stroke 6 and R 13.2 stroke 2.4;
  - `pubspec.yaml` and `pubspec.lock` are unchanged since `b29ec34`;
- `adb`, read-only, on the owner's phone (SDK 36): package dates; animation scales 1.0; the phone was locked.

**No test, gate or build was run.** The gate's inputs are unchanged since the green remote run on `570581e`
(V3): `git status` shows no change under `lib/`, `test/`, `integration_test/`, `android/`, `tool/` or
`pubspec.*`. The modified macOS registrant has an empty content diff (line endings only). That CI runs
`tool/check.dart`, the full gate.

| Criterion | Judgment | Evidence |
| --- | --- | --- |
| S12.1 (1)–(3) | **PASS** | PROGRESS "S12.1 done": reproduced on Linux (the plan's fallback, the CI's exact count "+1840 ~2 -1"); cause: font file-name case; `test/support/sdk_fonts.dart`; no test skipped. TD-104 RESOLVED |
| S12.1 (4) | **PASS** | `.github/workflows/ci.yml`: `ubuntu-24.04`, `actions/checkout@v5` |
| S12.1 (5)–(6) | **PASS** | Local full gate (Linux and Windows, 1,844 tests) and run 39020770255 recorded; later runs on `31ff9bf` and `570581e` also `success` (fresh) |
| S12.1 (7) | **PASS** | TD-104 RESOLVED; RD-17 "Resolved 2026-10-17" in PROGRESS's decision table. The plan's §8 register row is stale (S12V-01, follow-up) |
| S12.2 | **Not performed (owner, optional)** | Not a gate. The naming risk stays documented (`RA_R2D_IDENTITY.md` §2–§3) |
| S12.3 (1) | **PASS** | `docs/privacy/index.md`: the saved-or-unsaved position "as precise as the app holds it" (TD-099); "the overview of the coming nights (up to 16 days ahead)"; Clear Outside under "Links you open yourself"; the contact. See S12V-03 |
| S12.3 (2)–(3) | **PASS** | Fresh `curl` (above); the old repository name redirects, so it was not recreated |
| S12.4 | **PASS** | DECISIONS E.1 "S12.4 … (a)"; COMPLIANCE §"Google Play services location" and README "License exception" carry the §7 permission. The About statement is S16.8's (C4) |
| S13.1 | **PASS** | E.1 "S13.1 — the final Culmina mark approved: R3-final". `round4/README.md` (masks, 48/32/24/16 px, the themed icon in light and dark); `round5/README.md` (centring, small sizes, themed icon, splash storyboard) |
| S13.2 §3.1–§3.2, Task (1) | **PASS** | One id in Gradle, the Kotlin package, `AppIdentity` and the manifest; `app_identity_test.dart` enforces it; no earlier id found (fresh search) |
| S13.2 §3.3, Task (2) | **PASS** | `evidence/S13_2_DEVICE_CHECKS.md`: "Add from a photo" with a DNG and a HEIC on `.s2check` (M1, M4) |
| S13.2 §3.4, Task (3) | **PASS** | Same evidence: all 9 tables equal across ids. The device seed lacked a result and a legacy run; `backup_restore_test.dart` covers those on the host |
| S13.2 §3.5, Task (4) | **PASS** | `RELEASE.md` "Moving from Astro Planner"; runbook "Identity (S13.2)" |
| S13.2 §3.6 | **PASS** | The existing refusal and upgrade tests (`backup_restore_test`, `unsupported_database_test`), in the green gate |
| S13.2 §3.7 | **PASS** | The user agent is `Culmina/1.0.0 (+https://buffur.github.io/Culmina/; …)`; that URL answers 200 (fresh) |
| S13.2 §3.8 | **PASS** | `io.github.buffur.culmina.s2check` installs beside the owner's apps (`DEVICE`; present on the phone today) |
| S13.2 §3.9 | **PASS** | Full gate PASS at `b29ec34` (1,847 tests); Kotlin unit tests PASS; device checks above |
| S13.2 §3.10 | **PASS** | No public build exists; the id changed before any release (the Play-specific ordering is deferred with store distribution) |
| S13.2 Task (5) | **PASS** | The confirmation shows "Made <date> … by …" (TD-093 RESOLVED; `DEVICE`). TD-105 (wording) remains open → S16.8 |
| S13.2 Task (6) | **PASS** | Trap 20 (`ENGINEERING_GUARDRAILS.md` item 20), COMPLIANCE, RELEASE, README (renamed; no earlier id or URL left), the runbook |
| S13.3 (1) | **PASS** | Paths and colours equal R3-final; `ic_launcher_monochrome.xml` wired (`mipmap-anydpi-v26/ic_launcher.xml`); PNGs and `icon_512.png` regenerated in `f89c7c3` |
| S13.3 (2), Android 12+ | **PASS** | `values-v31` and `values-night-v31`: `splash_icon_animated`, duration 1000; the AVD ends at 1,000 ms (`app_identity_test.dart:88-110`); `MainActivity` holds it via `setOnExitAnimationListener` and releases it at once when animators are off; recorded on the phone (`identity/s13_3_splash_frames_1s.png`) |
| S13.3 (2), before 12 | **BLOCKED — S13V-01** | See §3 |
| S13.3 (3) | **PASS** | `StartupMark` only when `startupVm.isLoading` (`tonight_home_screen.dart:72-74`); `startup_mark_test.dart` ("still when animations are off"; "announced as loading, with no progress value"). On the phone, startup finishes before the loading view draws (`DEVICE`), so the mark is host-evidenced |
| S13.3 (4) | **PASS, with a follow-up** | Before and after on the phone: median 272 → 290 ms (`evidence/S13_3_DEVICE_CHECKS.md`). That "after" was the 380 ms build. The final build changed only what happens after the first frame (the exit listener and the AVD timing), so the measurement stays valid under V3 (S13V-03) |
| S13.3 (5) | **PASS** | No dependency change |
| Reduced motion on a device | **UNVERIFIED** | Code and host tests cover it. Not observed: the phone's animation setting is the owner's, and the phone was locked (S13V-02) |

## 3. Findings

### S13V-01 — BLOCKER (V4 A): the pre-Android-12 splash cannot draw its icon on Android 8–11

- **Criterion.** S13.3 (2), "the static icon before 12" (also ID-6).
- **Evidence (`CODE`).**
  - `drawable/launch_background.xml` and `drawable-v21/launch_background.xml` draw
    `<bitmap android:gravity="center" android:src="@mipmap/ic_launcher" />` on the navy colour.
  - On API 26 and later, `@mipmap/ic_launcher` resolves to `mipmap-anydpi-v26/ic_launcher.xml`, an
    `<adaptive-icon>` (the anydpi qualifier wins over the density PNGs).
  - A `<bitmap>` needs a bitmap source. With an XML drawable it throws "`<bitmap> requires a valid 'src'
    attribute`": a known failure on Android 8+ once adaptive icons exist (`WEB`, 2026-10-17:
    [Big Nerd Ranch, "Splash screens the right way" (updated)](https://bignerdranch.com/blog/splash-screens-the-right-way)
    and its [forum thread on Android 8–9](https://forums.bignerdranch.com/t/splash-screens-the-right-way-issue-with-andoid-8-9-vector-drawable-launcher-icon/15950)).
  - `minSdk` is 24, so Android 8.0–11 (API 26–30) is in range. API 24–25 resolve the PNG and should draw.
  - Since the code was written (TASK 16.1, `92afaa4`), no device or emulator has run below Android 12. The
    Stage 11 emulator was API 36, and no system image is installed now.
- **Expected effect.** On Android 8–11 the system cannot build the starting window, so no navy splash and no
  icon appear before the first frame. A crash is not expected: `FlutterActivity` switches to `NormalTheme`
  before the app's own window is built (the manifest declares it), so only the system's starting window uses
  `LaunchTheme`. **Not reproduced on a device:** the effect is inferred, the mechanism is not.
- **Why a blocker.** It is evidence against a frozen S13.3 criterion. It is a defect present since TASK
  16.1, not a regression made by S13.3. `app_identity_test.dart` checks only that both files contain
  `@color/splash_background`.
- **Correction (corrective Task, not done here; for the owner's choice in §5).**
  - Draw the mark without a `<bitmap>` over an adaptive-icon mipmap: for example
    `<item android:drawable="@mipmap/ic_launcher" android:gravity="center"/>`, or a dedicated PNG generated
    by `tool/make_launcher_icons.py` (trap 20).
  - Add a host test that rejects `<bitmap android:src="@mipmap/…">` while `mipmap-anydpi-v26` exists.
  - Verify on an API 26–30 emulator, and API 24 or 25 if available.
  - Then a V5 revalidation of S13.3 (2) only.
- **Complexity.** S, plus an emulator system image (about 1 GB; downloading it needs the owner's
  permission).
- **Proposed register entry:** TD-109 (text in §6).

### S13V-02 — FOLLOW-UP: reduced motion not observed on a device

- `MainActivity` releases the splash at once when `ValueAnimator.areAnimatorsEnabled()` is false; the AVD's
  end state is platform behaviour; `StartupMark` is static (host test).
- Observing it needs the owner's own setting (Settings → Accessibility → Remove animations, or the animator
  scale in Developer options) on an unlocked phone. Validation does not change the owner's settings.
- The row stays UNVERIFIED and is carried by name to S17.5 ("the cold start and splash"). It can be checked
  sooner whenever the owner switches the setting.

### S13V-03 — FOLLOW-UP: no numbers for the final build's cold start

- The 290 ms "after" median was measured on the 380 ms build.
- The final build adds an exit listener and a 1,000 ms AVD; both act only after the app's first frame, so
  the first-frame time is not expected to change (V3 reasoning, not a measurement).
- The user-visible delay of the held second is recorded qualitatively: about 1.0–1.2 s to app content.
- Measure both numbers on the release candidate in S17.5. This is non-blocking because the frozen (4)
  ("before and after") was performed.

### S12V-01 — FOLLOW-UP (documentation): the RD-17 register row is stale

`POST_ROADMAP_PLAN.md` §8 still says RD-17 is "open again, for Stage 11 or an owner request", while PROGRESS's
decision table records "Resolved 2026-10-17" with run 39020770255. Correct the §8 row.

### S12V-02 — FOLLOW-UP (documentation): PROGRESS's Stage table lags

PROGRESS's Stage table (rows 12 and 13) still reads "S12.3, S12.4 open" and "Not started", including in the
uncommitted working tree. Proposed text is in §6. Audit 09 notes the same drift as CA-17.

### S12V-03 — OBSERVATION: the policy already describes Stage 15 data flows

The published policy describes the 16-night overview request and the Clear Outside link before the app has
them, as S12.3 (1) required. It over-describes and does not under-describe (trap 22's concern). S15.4, S15.5
and S17.4 re-check it against the code.

### S13V-04 — OBSERVATION: two installs to clean up before a release

- The IDE's debug build under `io.github.buffur.culmina` (installed 2026-10-17 14:09:45) cannot be updated by
  a release-signed APK; it must be uninstalled first (S17.5/S17.6; already noted in S13.2's evidence).
- The `.s2check` test package was left installed for the owner's look (installed 2026-10-17 17:53).

**Owner apps unchanged** (read this session): `io.github.chacha12.astroplanner` last updated 2026-09-30
11:48:37; `io.github.buffur.culmina` 2026-10-17 14:09:45; `com.astroplan.astroplan` present.

## 4. Verdict

- **Stage 12 — PASS.**
  - S12.1, S12.3 and S12.4 meet their criteria. S12.2 is an optional owner action, not performed; the naming
    risk stays documented.
  - Non-blocking follow-ups: S12V-01 and S12V-02. S12V-03 is an observation.
  - Stage 12 may be recorded as closed.
- **Stage 13 — BLOCKED on S13V-01** (S13.3 (2), the static icon before Android 12).
  - Every other S13.1, S13.2 and S13.3 criterion passes.
  - Follow-ups: S13V-02 (reduced motion, UNVERIFIED on a device) and S13V-03 (final cold-start numbers),
    both carried to S17.5. S13V-04 and TD-105 are recorded.

## 5. Owner decision needed for Stage 13

1. **(Recommended) Corrective Task S13.V1.**
   - Fix `launch_background.xml` as in S13V-01, with its host test.
   - Verify on an API 26–30 emulator. Downloading an API 30 system image (about 1 GB, Google's SDK
     repository, through `sdkmanager`) needs the owner's permission.
   - Then a V5 revalidation of S13.3 (2), and Stage 13 closes.
   - V1 class: platform assets and a test, so targeted tests (`app_identity_test.dart`) plus the gate's
     encoding, format and analyze steps; a full gate only if more changes.
2. **Carry it (owner waiver).** Close Stage 13 with S13V-01 recorded as TD-109, fixed in S16.8 and verified
   in S17.5. Users of Android 8–11 would have no splash until then; there is no public release yet.

## 6. Proposed record text (not applied: the files carry uncommitted work)

- **PROGRESS.md, header "Next":** "Stage 12 closed (bounded closure PASS,
  [STAGE_12_13_CLOSURE.md](STAGE_12_13_CLOSURE.md)). Stage 13 BLOCKED at closure on S13V-01 (the pre-12
  splash, Android 8–11); the owner chooses S13.V1 or a carry. Then S14.1 (ADR-021), on the owner's start
  instruction."
- **PROGRESS.md, Stage table:**
  - "12 | Release foundation | Complete | 2026-10-17 | 2026-10-17 | Bounded closure PASS at `570581e`
    (STAGE_12_13_CLOSURE.md); S12.2 optional, not performed; S12V-01/02 follow-ups";
  - "13 | Identity: Culmina | In validation: BLOCKED (S13V-01) | 2026-10-17 | — | S13.1, S13.2 PASS; S13.3
    all but (2) before Android 12; reduced motion UNVERIFIED (S13V-02)".
- **TECH_DEBT.md, new row (High):** "TD-109 | *(Found 2026-10-17, Stage 12–13 closure, S13V-01.)* **The splash
  before Android 12 cannot draw its icon on Android 8–11.** `launch_background.xml` (both copies) wraps
  `@mipmap/ic_launcher` in `<bitmap>`; on API 26+ that resolves to the adaptive-icon XML, which a `<bitmap>`
  cannot decode, so the system cannot build the starting window (no splash) | Users of Android 8–11 see no
  splash; S13.3 (2) unmet | Draw it with `<item android:drawable … android:gravity="center"/>` or a
  generated PNG; a test rejecting `<bitmap>` over adaptive mipmaps; verify on API 26–30 [S] | S13.3; ID-6;
  trap 20".
- **POST_ROADMAP_PLAN.md §8, RD-17:** add "**Resolved 2026-10-17** (S12.1; run 39020770255)".

## 7. Verification of this record

Documentation only (V1).
- References were checked against the files and lines named.
- `git diff --check` style: no trailing whitespace.
- The uncommitted work of other sessions was left untouched.
- No device setting was changed and no app was installed, launched or removed.
