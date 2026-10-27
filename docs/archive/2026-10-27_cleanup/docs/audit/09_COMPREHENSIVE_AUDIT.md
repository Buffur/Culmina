# Culmina — Comprehensive project, history and roadmap audit (09)

> **Date:** 2026-10-17. **Code baseline:** `570581e` (= `origin/main`). Remote CI run
> [39042823307](https://github.com/Buffur/Culmina/actions/runs/39042823307) is `success` on that commit, read
> from the GitHub REST API in this session.
> **Roadmap baseline:** `refinement/POST_ROADMAP_PLAN.md` §5, Stages 12–17, **including the uncommitted
> independent-audit integration** present in the working tree: `refinement/STAGES_12_17_AUDIT_AMENDMENTS.md`
> (untracked) and its edits to `POST_ROADMAP_PLAN.md`, `PROGRESS.md`, `DECISIONS.md`, `TECH_DEBT.md`,
> `PRODUCT_DIRECTION.md`, the readiness review and `CLAUDE.md`. Those edits are not committed; this report
> treats them as the current proposal and says so where it matters.
> **Status:** audit and proposal only. It is not an owner decision. No roadmap Task, ADR, register or
> application file was changed. The amendments in §H need the owner's explicit approval before anyone
> applies them. **Change class of this file:** documentation only (CLAUDE.md V1).
> **Addendum, same day:** the later Stage 12–13 closure validation
> ([`refinement/STAGE_12_13_CLOSURE.md`](../refinement/STAGE_12_13_CLOSURE.md)) passed Stage 12 but found
> that Stage 13 is blocked by S13V-01. The splash before Android 12 cannot draw its icon on Android 8–11.
> "Stage 13 needs only closure records and two device rows" (§A, §D.3) is therefore superseded by that record.
> **Applied, same day:** the owner approved §H. M1–M16 are now in `refinement/POST_ROADMAP_PLAN.md` §5 (DECISIONS E.1, "Audit 09 amendments applied"). CA-OD1 to CA-OD3 remain open.

## 0. Evidence boundary and how to read this report

**Evidence levels.** `CODE` — read in this session (file:line). `DOC` — a project document or decision.
`WEB` — an external page, with its access date. `RENDER` — a host render (not phone evidence). `DEVICE` —
a phone or emulator observation recorded by an earlier session (not repeated here). `UNVERIFIED` — needs a
device, a person or a run that this audit did not perform.

**What this audit did.**
- Read the governance, state and direction documents; Stages 12–17 with their uncommitted amendments; RA.R1;
  the RA.D round-2 package; the readiness review (C1–C6); the owner's two reviews (`audit/08_MANUAL_DOGFOODING.md`
  and `review-01.10.2026`, outside the repository); the E.1 decisions since RA.D; the SI index; the open
  TD items; the FEATURE_STATUS status column; the Stage 10 size record.
- Read the code behind every material claim: backup and restore, calibration matching, the block editor, the
  budget and storage, the equipment model and rig list, the plan status, theme and colours, startup, the
  metadata format list, backup preferences, the Logbook entry's actions and the CI workflow.
- Confirmed by reading the code each defect the earlier independent audit reproduced with probes (TD-106,
  TD-107, TD-108) and the RA.R1 defect candidate RA-F05.
- Viewed five host renders of the current screens at `570581e` (Tonight, Planner, Capture Plan, Welcome,
  Settings; made by the earlier audit) and the approved identity sheet (`refinement/evidence/identity/round5/r3-final-sheet.png`).
- One external check: AstroBin's acquisition CSV contract (`WEB`, 2026-10-17, §G CA-08).

**What it did not do, and why.**
- No test, gate, build or new render was run. No gate input has changed since the last green remote run (V3),
  and the three defects already have reproducing probes; reading the code was enough to confirm them.
- No emulator, phone or person was used. Device behaviour, TalkBack, darkness use and comprehension are
  `UNVERIFIED` here.
- In host renders, text styles that name no font family (app-bar titles, chart labels) draw as solid blocks,
  a test-engine limit. Typography conclusions are therefore provisional (and see CA-11).

**Two premises of the request are out of date.**
1. **The logo is approved.** The owner approved `R3-final` on 2026-10-17 (DECISIONS E.1, "S13.1 — the final
   Culmina mark approved"), and S13.3 shipped it at `570581e` with the held one-second splash the owner chose.
   This report evaluates the approved mark and how it carries into the app (CA-10); it does not reopen the
   artwork.
2. **An independent audit of the same baseline has already been folded into the roadmap** (AUD-01 to AUD-17,
   TD-106 to TD-108), uncommitted. Appendix C reviews that integration critically. This report repeats its
   findings only where it confirms, corrects or extends them.

---

## A. Executive verdict

**Is the project fundamentally sound? Yes.** The planning engine is real, layered and well verified. Domain
code is independent of Flutter, astronomy is checked against USNO and JPL Horizons vectors, the budget and fit
follow ADR-009, saved plans are immutable snapshots (ADR-014, S4.V2), schema history runs v8 → v25 with
generated, tested migrations, and remote CI is green. Nothing found here justifies a rewrite.

**Is the approved roadmap appropriate? Yes.** Stages 12–17 address the owner's actual complaints (entry
barriers, Home and planner hierarchy, weather and Moon presentation, storage, calibration, records) with
concrete decisions, and C1–C6 fixed the release order. The independent-audit integration adds three real
defect fixes and several needed contract clarifications.

**Is it complete enough to execute? Almost.** Stage 12 and Stage 13 need only their closure records and two
device rows. Before Stage 14's contracts freeze (S14.1, ADR-021), it needs a small, finite set of corrections
(§H):
- an approved capability is missing from the plan: FITS as the astro-camera source for rig specifications
  (RG-03 Q1; CA-06);
- the main existing remedy for manual spec entry, "Add from a photo", is hidden behind an unlabeled icon, and
  no Task makes it the visible path (CA-02);
- several contracts are under-specified where they decide whether a feature is actually complete:
  - storage for DSLR and mirrorless RAW files, none of which is read except DNG (CA-07);
  - the AstroBin CSV's numeric filter IDs (CA-08);
  - the forecast's lead time (CA-09);
- several new acceptance clauses cannot be judged objectively. Interpretation disputes of this kind are what
  failed Stages 1–4 twice each (CA-05).

**Likely quality of the finished Culmina:** about **7/10** as now written. About **8/10** with the
corrections, provided the phone and human rows are actually run. On a modern phone it should be a credible,
honest, specialised capture-planning tool. The ceiling is set less by features than by:
- the rig-entry path;
- how dense the Capture Plan becomes once Stage 14 adds its fields;
- whether the visual language moves beyond today's monochrome Notion-style UI (an owner decision, CA-10);
- evidence that real users can operate it.

**Biggest risks to that outcome.**
1. Restore safety until TD-106 is fixed (P0; CA-01). The fix also waits behind ADR-021 unless the order is
   corrected.
2. Stage 14's scope and density: 13 Tasks, a v26 migration, a metadata contract, and a FITS-sample gate that
   could stall Stage 14 (CA-15).
3. Visual acceptance that rests on host renders with placeholder glyphs and on one reviewer (CA-11; S6.E
   remains UNVERIFIED).
4. Owner bandwidth: two ADR acceptances, a render review per UI Task, phone and human rows, the signing key,
   go/no-go and publication.

---

## B. Historical implementation assessment

### B.1 Stage outcomes (Stages 0–13)

| Stage | Intended goal | Outcome (evidence) | What it left behind |
| --- | --- | --- | --- |
| 0 Baseline | Reconcile audits 01–08 with code; set direction | Complete (`652ad80`); PRODUCT_DIRECTION and POST_ROADMAP_PLAN created | The governance machinery that later grew very large (B.3) |
| 1 Verified fixes | Fix confirmed defects (A1–A7, B, C, D, F) | Closed **by owner waiver** after two failed independent validations (TD-059…063) | TD-063 moved to Stage 8 and fixed there; validation-scope disputes led to CLAUDE.md V4/V7 |
| 2 Metadata foundation | Bounded readers with provenance | Closed **by owner waiver** after two failed validations; DNG, JPEG and HEIC readers, SAF no-copy channel, device M1–M3 (`DEVICE`) | FITS never read (no sample; S2.6 never ran); proprietary RAW recognised only (RG-14) |
| 3 Metadata → equipment | Import rigs from photos with matching and provenance | Final sign-off PASS (`92ebf2a`) after two failed rounds (S3V, S3S); M4 on phone | Feature placed as a secondary icon button (CA-02); TD-072 deferred → S14.9 |
| 4 Product flow and IA | ADR-019, lifecycle and vocabulary decisions | Bounded final validation PASS (`09a7f06`) after two failures | Immutable-snapshot invariant (S4.V2); S4-DEF-01…08 resolved in Stages 6 and 8 |
| 5 Design system | Tokens, controls, status, patterns | PASS after one corrective cycle (`178acbe`) | Neutral, monochrome token set; `colorScheme.primary` equals the text colour (`app_theme.dart:33`, `:85`); no accent |
| 6 Core planner | Answer-first planner, Tonight plan-first, timeline | PASS after one corrective cycle (`da4c53d`); owner's manual review triggered the S6.16 corrective pass | **S6.E five-second test UNVERIFIED** (owner-accepted gap): no independent usability evidence ever |
| 7 Data entry | Camera classes, calibration matrix, LENR, aliases, sites, rig form | PASS after one corrective cycle (`21e9cb1`) | The "propose from the last light block" convenience produced RA-F05; T1-only catalog (owner) |
| 8 Logbook | Result without a tracker; tracker retired | PASS first time (`690b94a`) | — |
| 9 Secondary UX | Library, Settings, About, details, polish | PASS (`8e53479`); logo, licence and identity deferred by the owner | Reopened by RA.D (name, logo); licence still deferred (RG-12) |
| 10 Size and performance | Explain 277 MB; fix form lag | PASS (`3cb67be`); 277 MB = a debug install; arm64-v8a release APK 24.8 MB; MediaQuery rebuild fix | D10-3's premise (Play split delivery) is invalidated by GitHub-only distribution (CA-13); device timing UNVERIFIED |
| 11 Validation | Readiness matrix and evidence | Closed as superseded by Stage 17; 67 of 70 host rows PASS, the three blockers fixed by S11.C2 | S11.6 phone rows and S11.7 readiness carried to S17.5 and S17.7 |
| RA (R1, R2, D, P) | Reassess against the owner's third review | Complete; roadmap approved (G3); C1–C6 applied | — |
| 12 Release foundation | CI, trademark (optional), policy, S11P-03 | S12.1, S12.3, S12.4 done; S12.2 optional; **no closure record yet** | PROGRESS's Stage table still says S12.3/S12.4 open (CA-17) |
| 13 Identity | Name, id, URLs, icon, splash | S13.1 and S13.2 done (device checks pass); S13.3 implemented | Pre-12 splash and reduced motion UNVERIFIED; the brand is absent from the UI (CA-10); TD-105 |

### B.2 Were the owner's problems diagnosed and solved?

| Problem (owner) | Diagnosis | Solution | Verified? | Later undermined? |
| --- | --- | --- | --- | --- |
| "Storage not calculated" (08 §17) | Correct: no rig RAW size → Unknown by design (S6.10, case C) | PD-06 evidence chain (S14.7) | Pending | Every major DSLR RAW format (CR2/CR3, NEF, ARW, RAF, RW2, ORF) remains unspecified (CA-07) |
| Form lag (08 §22) | Measured: `MediaQuery.of` rebuilds (S10.3) | `sizeOf`; rebuild test | Host/emulator only | Device timing still UNVERIFIED (S17.5) |
| 277 MB (08 §26) | Correct: a debug install (S10.1) | Release baseline 24.8 MB (arm64-v8a) | `DEVICE` (emulator) | **Yes:** GitHub-only distribution with a universal APK (historically about 72 MB per the earlier audit) changes what the user downloads (CA-13) |
| Only ZWO, too many fields (08 §11) | Verified seeds only; specs from metadata | Add from a photo (S3.7), class-specific forms (S7.2) | M4 on phone | **Yes, partly:** the import is an unlabeled small icon; the rig list's empty state says only "No rigs yet." (CA-02) |
| Live tracker useless (08 §3) | Correct | Retired safely (S8.4); results form (S8.2) | Yes | No |
| Tracked is global (08 §21) | Correct | Per-plan override (S7.1, v19) | Yes | No |
| Raw, flat, overloaded UI (08 §7, §25; reviews 2026-09-28, 2026-10-01) | Partly: tokens and hierarchy fixed (S5); visual language not addressed | Stage 16 hierarchy; owner render reviews (K14) | Owner review only | The same impression recurred three times (RA.R1 K14/K16); the plan still has no visual-language decision (CA-10) |
| Exposure prefilled (review 2026-10-01) | Correct (RA-F05): a convenience (S7.2b proposal) leaks the light's exposure into flats and bias (`capture_block_dialog.dart:139-141`, `:224-225`) | S14.6 (4) | Pending | — |
| Calibration re-entry (08 §16) | Inheritance exists (L1); generation missing | CAL-1 (S14.10) | Pending | TD-107: flat warnings check filter and binning separately |

### B.3 Process observations

- **Quality was achieved by repeated validation, not first-time correctness.** Seven of the ten
  implementation Stages (1–7) needed at least one corrective cycle; Stages 1–4 failed twice each, and Stages 1
  and 2 closed by waiver. Stages 8–10 passed first time. CLAUDE.md V4–V7 were written to stop
  interpretation disputes. The new "audit clarification" paragraphs re-introduce clauses that a validator
  cannot judge objectively (CA-05). Making them testable now is cheaper than a second V7 escalation later.
- **Detailed documentation is not product quality.** The plan is 571 KB, DECISIONS 402 KB, TECH_DEBT 168 KB,
  FEATURE_STATUS 192 KB, against about 42,000 lines of application code. Registers drift even under this
  discipline:
  - the operational summary lagged three completed Tasks (AUD-14);
  - the uncommitted integration files a P0 defect (TD-106) in TECH_DEBT's "Low" table (CA-17);
  - PROGRESS's Stage table still shows Stage 13 "Not started".

  None of this harms users, but every Task now pays a large reading and update cost (CA-24).
- **Usability has never been measured independently.** Every UX acceptance so far is the owner's render
  review or a builder's walkthrough. The new bounded-workflow rule (AUD-10) helps, but only once its wording
  separates what an agent can record from what only a person can (CA-05).

---

## C. Current product assessment

### C.1 Foundation

| Area | Strengths (evidence) | Weaknesses |
| --- | --- | --- |
| Architecture | Presentation → ViewModels → repositories → data; one composition root (`main.dart:127-167`); domain services pure | Large screen files (`home_screen.dart` 701 lines, `equipment_editor.dart` 727, `drift_session_repository.dart` 898); cross-ViewModel lifecycle coupling (Planner, PlanLifecycle, Tonight, Sessions) |
| Persistence | Drift with schema snapshots, generated steps, refusal screen for unsupported versions (`main.dart:79-101`), single-transaction writes | Restore activates an unchecked database (TD-106; `backup_archive.dart:92-99`, `backup_staging.dart:56-85`) |
| Errors and offline | `AppLog`, `StorageFailure`, `runWithFeedback`; offline core; weather cache with freshness states | After a failed database open the app logs and continues (`main.dart:86`); no user-reachable recovery from a bad restore |
| Performance | Measured baselines and a rebuild regression test (Stage 10) | Phone timing UNVERIFIED; Stage 15's calendar and overview are new heavy screens |
| Testability | 1,851 tests at the last full gate; reference vectors; migration and schema tests; lifecycle matrix; accessibility sweep; host E2E | CI builds no Android or Kotlin (`.github/workflows/ci.yml` runs `tool/check.dart` only); SQLite backup fixtures are header-only; real-sample metadata tests are opt-in |

### C.2 Core planning

- **Capture Plan engine — strong.** `CaptureBudgetCalculator` (`capture_budget_calculator.dart:245-389`)
  separates integration, in-window and outside-window calibration, library blocks, LENR darks, dither,
  refocus, filter change and meridian flip. Library blocks cost no time and no storage. The fit verdict is
  factual ("Fits: 1 h 48 min needed of 7 h 10 min usable"; `RENDER`).
- **Capture Plan editing — weakest part of the core.**
  - The block editor is an `AlertDialog` (`capture_block_dialog.dart:316`) with a fixed filter list in which
    `L` is the default for every camera class (`:9`, `:134`).
  - Valid custom filters are erased on an unchanged save (TD-108, `:134-135`).
  - A light's exposure is carried into a new flat or bias (RA-F05).
  - The example plan triggers its own calibration warnings ("No light block uses this filter", "No flats
    for: L"; `RENDER` capture_dark_100).
  - Storage is printed by hand as "7000.0 MB" (`capture_budget_summary.dart:185`).
- **Equipment.** Rigs require sensor size, pixel pitch, resolution, focal length and focal ratio
  (`equipment_profile.dart:24-39`, non-null). A plan cannot be saved without a rig: "A rig is needed to save
  the plan and to check exposures." (`plan_status.dart:50-51`). "Add from a photo" fills most of this from
  DNG, JPEG or HEIC metadata, but it is a small, unlabeled floating button with a tooltip
  (`equipment_selection_screen.dart:238-245`), and the empty list says only "No rigs yet." (`:171`).
- **Metadata.**
  - DNG, JPEG and HEIC are read with byte budgets and provenance.
  - A TIFF without DNGVersion (NEF, ARW) is reported unsupported (`dng_metadata_reader.dart:7-25`).
  - FITS, CR2, CR3, RAF, RW2, ORF, XISF, PNG and AVIF are recognised only (`metadata_format.dart:11-65`).
  - So no native DSLR or mirrorless RAW file is read; for those cameras the photo paths work only from a JPEG
    or DNG.
  - Nothing yet populates Capture Plan blocks from a file (PD-11 pending).
- **Targets.** 164 OpenNGC objects with aliases and normalised search ("M31" → Andromeda; S7.4). Custom
  targets still need RA/Dec (RG-07 = T1, owner).
- **Visibility and fit.** Windows from Sun limit × target altitude, with Moon and cloud gates as preferences
  (ADR-013). Altitudes are reference-tested (CALC-07: max error 0.017° against USNO).
- **Relative gain.** √N per (filter, exposure) group against one frame, never called SNR (SI-003). O2b
  (√(T/T_plan)) is pending.

### C.3 Night conditions

- Darkness bands and the night timeline are reference-tested. The Moon (Meeus) has illumination, rise and set,
  and Moon-during-dark.
- **SI-015 is real:** displayed rise and set use h₀ (upper limb, refraction, parallax), while Moon-up counting
  uses the topocentric centre above 0°. They differ by 5–10 minutes per event.
- Weather (Open-Meteo, 11 hourly variables) covers only the selected night (`open_meteo_weather_repository.dart:50-58`).
  The night summary spans sunset to sunrise (`night_weather_summarizer.dart:10-13`), not the dark span that
  Stage 15 cards will need (CALC-32 amendment, AUD-08).
- **Information value today:** the facts are correct but read as text lines ("Sunset to sunrise …", "Dark
  (Sun below −18°) …", `RENDER` Tonight). "Times in device zone, UTC+02:00" appears twice on one screen.
  There is no multi-night view.

### C.4 Supporting workflows

| Workflow | State |
| --- | --- |
| Onboarding | Three optional steps (site, rig, target). Skip and Done do the same thing; Tonight flashes first (RA-B01/B02; `RENDER` Welcome) |
| Home / Tonight | Context card, then Your plan (fit and Open planner), then Night/Moon/Weather text rows, "What can I image tonight?" and New plan (`RENDER`) |
| Planner | One long page: status, context, Target, Rig, Capture plan, timeline, conditions, sky darkness; sticky Save plan |
| Logbook | Upcoming and past entries, search, filter panel, Record or Edit result, Copy to another night, Share, Export as file (`session_detail_screen.dart:495-560`); Progress per target per filter (CALC-38) |
| Library | Manages rigs, targets and sites. Rigs and targets have swipe delete only (RA-G03) |
| Settings | Rebuilt (S9.4), long explanatory text; no theme or unit choice (PD-20 pending) |
| Backup | Backup with settings (format v2); restore at next start. The confirmation promises "a safety copy on this device" that no screen can use (`backup_section.dart:47-53`; CA-01) |
| About | Author first, prominent Reddit and GitHub buttons (`about_screen.dart:20-22`, `:63`); licence pages (TD-098 open) |
| Accessibility | AA text roles in light and dark; sweep at 100 % and 200 %; TalkBack unverified on a phone |

**Integration verdict.** The sections behave as one application at the data level: one plan state, snapshots
and Progress feed each other. At the presentation level they still read as separately built screens that share
tokens: similar card weight, text-heavy rows, and no accent colour or visual anchor.

### C.5 The four user perspectives (today → after the roadmap)

| User | Today | After Stages 12–17 as written | Remaining after them |
| --- | --- | --- | --- |
| **Beginner, smartphone** | Welcome flashes in late; "Choose a rig" opens a list with a telescope example. The phone's specs are unknown to the user, and the photo import is an unlabeled icon. Blocks default to an `L` filter. Storage is Unknown. Save needs a rig | One-screen onboarding with class; class-specific fields; Take from a photo for exposure, ISO and WB; storage measured from the photo; the example removed; Home night card | **The rig is still the gate.** Unless the photo path is the visible default (CA-02), many beginners meet a pixel-pitch form. A file without a 35 mm-equivalent focal length needs manual sensor data (RG-03 Q1) |
| **DSLR/mirrorless** | Import works from a JPEG or DNG only: CR2/CR3, NEF, ARW, RAF, RW2 and ORF are not read. ISO fields only; calibration inherits; LENR handled. Storage Unknown unless typed | Take from a photo; WB record; CAL-1; O2b; storage chain | Storage for native RAW (CR2/CR3, NEF, ARW, RAF, RW2, ORF) depends on an unwritten rule (CA-07); AstroBin export without filters unless CA-08 is specified |
| **Astro camera** | Manual rig (specs usually known); gain and binning; library calibration; no FITS reading; no temperature or offset model (RG-10 T0/O0) | FITS capture fields (given a sample); CAL-1 with tuple-correct matching; theoretical storage from BITPIX/NAXIS | No rig from FITS (CA-06) although RG-03 Q1 named FITS as this persona's path; FITS-sample gate (CA-15) |
| **Returning, multi-night** | "How did it go?" on Tonight; Record result; Copy to another night; Progress per filter; search and filters | Progress in Logbook; stored forecast in the entry; visible Delete; Plan this target; Moon calendar; 16-night overview; AstroBin CSV | Results stay manual by design; no project goal (deferred); browsing a night vs re-timing a plan must be clear (AUD-09, covered) |

**Main UX question — purpose-built tool or exposed internals?** The engine and lifecycle are purpose-built.
The surface still exposes internals in three places:
1. A complete optical/sensor specification is the gate to saving any plan.
2. Calibration semantics (policy, inheritance, "Use other values") surface inside a crowded dialog.
3. The planner is one long sequence of domain sections.

Stages 14 and 16 move each of these toward a task-shaped flow. Whether they get there depends on CA-02 (rig
path), CA-12 (density) and CA-10/CA-11 (visual language and review fidelity).

### C.6 Visual design, separated by evidence level

- **Current (`RENDER`, five screens):**
  - clean, consistent and accessible;
  - monochrome (Notion-like greys; the primary colour is the text colour);
  - many outlined cards of equal weight and explanatory paragraphs on most screens;
  - dark theme neutral `#191919`;
  - typography hierarchy present (bold headings, secondary text) but quiet.

  This matches the owner's "flat" judgement.
- **Identity (`RENDER`, identity sheet):** R3-final is distinctive and stays legible down to launcher and
  notification sizes. It is restrained and scientific (navy `#0B1230`, white orbit, ice-blue star), in the
  spirit of the Siril and Stellarium brief. It is used only in the icon, the splash and `StartupMark`
  (`app_colors.dart:11-16`). On a phone in light mode, a navy splash hands over to a white app (`main.dart:199`,
  `ThemeMode.system`).
- **Planned:** Stage 16 changes structure (onboarding, Home order, planner empty state, records, settings) and
  S16.7 checks consistency. No Task changes the visual language. The integration's S16.7 text says "no new
  theme or asset direction".
- **Expected:** a clearer, better-ordered version of today's look, unless the owner decides how the brand
  enters the tokens (CA-10). With placeholder glyphs in review renders (CA-11), the final typography cannot be
  judged before device screenshots. **Visual quality after implementation cannot be predicted reliably from
  source code.**

---

## D. Roadmap review by Stage (Stages 12–17, with the uncommitted integration)

### D.1 The thirteen questions, per Stage

✓ = adequate. ◐ = partly; the finding is named. ✗ = missing.

| # | Question | S12 | S13 | S14 | S15 | S16 | S17 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | Clear objective | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 2 | Solves the intended problems | ✓ | ◐ CA-10 | ✓ | ✓ | ◐ CA-10, CA-12 | ✓ |
| 3 | Covers needed existing or approved capabilities | ✓ | ✓ | ◐ CA-06, CA-07 | ✓ | ◐ CA-02 | ✓ |
| 4 | Tasks appropriately scoped | ✓ | ✓ | ◐ S14.1, S14.3 large (CA-22) | ✓ | ✓ | ✓ |
| 5 | Dependencies correct | ✓ | ✓ | ◐ CA-01, CA-15 | ✓ | ◐ S16.5 → S14.10, S16.6 → CA-OD1 | ✓ |
| 6 | Technical assumptions valid | ✓ | ✓ | ◐ CA-07 | ✓ | ◐ CA-08 | ◐ CA-13, CA-14 |
| 7 | Architecture and data implications identified | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 8 | Acceptance proves real completion | ✓ | ✓ | ◐ CA-05, CA-12 | ◐ CA-09 | ◐ CA-05, CA-11 | ✓ |
| 9 | Tests and device checks included | ✓ | ◐ two rows open | ✓ | ✓ | ✓ (device in S17.5) | ✓ |
| 10 | Reuses completed capabilities | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 11 | Avoids duplicated work | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 12 | Cannot leave half-finished functionality | ✓ | ✓ | ◐ FITS gate (CA-15) | ✓ | ◐ visual polish | ◐ human rows may stay UNVERIFIED (by design) |
| 13 | Outcome consistent with the target product | ✓ | ◐ CA-10 | ✓ with CA-12 | ✓ | ◐ CA-10 | ✓ |

**C1–C6 still hold.** All six are applied:
- C1: S17.6 depends on S17.1–S17.4; S17.5 depends on S17.6; S17.7 depends on S17.2–S17.6; S17.8 depends on
  S17.7. The graph is acyclic.
- C2: the cross-id rehearsal is in S17.5.
- C3: S14.9 depends on S14.7 and S14.8.
- C4: S16.8 carries the About statement.
- C5: PRODUCT_DIRECTION header and §9.
- C6: the register additions.

No C-correction needs reopening.

### D.2 Stage 12 — Release foundation

- **Strengths.**
  - S12.1 found the real cause of the red CI (font file names differ in case on Linux), fixed it without
    weakening a test, and pinned the runner. CI is green on `570581e` (verified).
  - The policy is published with the owner's contact (S12.3).
  - S12.4 (a) keeps the owner's preferred Google Play services location. COMPLIANCE and README state the
    GPL-3.0 §7 additional permission; the About statement and Android notices follow in S16.8 and are checked
    in S17.4.
  - GitHub-only distribution is preserved throughout.
- **Weaknesses.** No closure record. PROGRESS's Stage table still lists S12.3 and S12.4 as open (CA-17).
  S12.2 (trademark) stays optional, so the naming risk remains a documented risk.
- **Missing requirements.** None. Optional: say what location does on a phone without Play services, a
  likelier case for a GitHub-distributed APK (CA-21).
- **Execution risks.** Low.
- **Corrections.** CA-17 (records).
- **Expected outcome.** Closes by a bounded record without code.

### D.3 Stage 13 — Identity

- **Strengths.**
  - Five design rounds with stated principles, ending in the owner-approved R3-final.
  - Adaptive and monochrome layers; an AVD splash; a startup mark that is static under reduced motion.
  - S13.2 renamed the id, the Kotlin package, the metadata channel and the URLs together. It was checked on a
    phone (M1/M4) and by a cross-id backup and restore with all nine tables equal (`DEVICE`).
- **Weaknesses.**
  - The pre-12 static splash and reduced motion are UNVERIFIED on a device.
  - The held 1,000 ms splash delays visible content by about 0.7–0.9 s on a fast phone. This is an
    owner-accepted amendment of ID-6, recorded honestly; S13.3 (4) already requires measuring it as
    user-visible time.
  - The identity stops at the splash (CA-10).
  - TD-105.
- **Missing requirements.** An owner decision on how the brand enters the UI tokens (CA-OD1, CA-10).
- **Execution risks.** Low.
- **Corrections.** Close the two rows (an API 30 or lower emulator for pre-12; the owner's phone with
  animations removed), or carry them by name as S13.3 (6) allows.
- **Expected outcome.** The launcher identity is complete and polished. Coherence with the app depends on
  CA-10.

### D.4 Stage 14 — Capture Plan completeness (examined in most depth)

**Verdict.** It is the right Stage with the right decisions (PD-05 to PD-14, PD-21). It reuses the metadata
foundation correctly: the reader registry, `MetadataSourceWindow`, `CaptureFileAccess`, and ADR-018's
proposal and provenance rules, with no second parser. The integration's AUD-05, AUD-06 and AUD-16
clarifications are scientifically sound. Completed as written, Stage 14 delivers:
- class-first rigs;
- provenance markers;
- a WB record;
- the storage evidence chain;
- Take from a photo;
- CAL-1;
- O2b;
- effective assumptions and a focus reminder;
- removal of the example plan;
- the TD-106, TD-107 and TD-108 fixes.

Three persona-specific holes remain, plus a density risk.

| Task | Assessment | Correction |
| --- | --- | --- |
| S14.1 ADR-021 | Right scope. About ten decisions accepted at once invites rubber-stamping | Present it as a numbered decision sheet (CA-22). Add the decisions for CA-06 (FITS → rig mapping and binning normalisation), CA-07 (length of an unread RAW file as evidence), CA-03 (filter identity comparison) and CA-01 (restore-undo option) |
| S14.2 class first | Good. "Not sure" is an explicit Unknown | Make "From a photo" a labelled, visible path wherever rigs are created (CA-02) |
| S14.3 v26 + TD-106 | The content is right. The P0 fix depends on ADR-021 although it does not need it | Allow items (7)–(9) to land first; add truthful safety-copy wording (CA-01) |
| S14.4 contract | Sound. LightSource must stay "reported light source" and never become the WB mode by inference (RA_D_ROUND2 A.2 already marks it INFERENCE) | — |
| S14.5 FITS | Its keywords serve Capture Plan fields only. RG-03 Q1 named FITS as the astro-camera rig path | Add XPIXSZ, YPIXSZ, FOCALLEN and TELESCOP into the existing import review (CA-06); request the sample early (CA-15) |
| S14.6 provenance, TD-108, RA-F05 | Good. Also covers the per-class filter default ((3)) | Plus the editor's form factor and density (CA-12) |
| S14.7 storage | The evidence chain is correct (measured, then format-aware theoretical, then Unknown) | The rule for unread RAW files (CA-07); MB/GB display (CA-18) |
| S14.8 WB | A sound model: no Kelvin conversion; recorded only | — |
| S14.9 Take from a photo | Correct reuse | Make the FITS parts explicitly conditional so the Task can close without a sample (CA-15) |
| S14.10 CAL-1, TD-107 | Separating advisory matching from proven coverage is exactly right | Filter identity normalisation (CA-03) |
| S14.11 O2b | Correct vectors; comparability (AUD-16) | — |
| S14.12 | Fine | — |
| S14.13 | Fine | Follows S14.9's conditional FITS parts (CA-15) |

**Scientific defensibility.**
- **Uncompressed DNG payload** (W × H × bits ÷ 8): correct as payload. The container (IFDs, previews) adds
  bytes, so AUD-05's "payload versus exact container bytes" wording is necessary.
- **FITS size:** BITPIX ÷ 8 × ΠNAXISn plus header records, padded to 2,880 bytes. A camera-binned FITS
  already has a reduced NAXIS and is never divided again.
- **WB:** AsShotNeutral is stored as read.
- **CAL-1 and temperature:** darks for cooled cameras also depend on temperature, which is not modelled
  (owner decision RG-10 T0). The preview should keep the existing tip text, not imply that temperature
  matches.
- **O2b:** √(T/T_plan) holds only for equal per-frame conditions, so AUD-16's grouping rule is required.

**Expected outcome.**
- With CA-02, CA-06, CA-07 and CA-12: a complete, honest Capture Plan for all three camera classes.
- Without them: strong for phones with EXIF data and for astro cameras with known specs, but with gaps for
  native DSLR RAW storage, for rigs from FITS, and for the beginner's first rig.

### D.5 Stage 15 — Night conditions

- **Strengths.**
  - MF-c with a frame-correct predicate (AUD-07).
  - Moon-free intervals with explicit none, mixed, disjoint and no-dark states.
  - CALC-32 extended to the dark span.
  - Per-variable coverage, and a cache identity that includes coordinates, model and range.
  - Browsing a night is kept separate from adopting it (AUD-09).
  - An offline calendar computed in an isolate, with phone timing as an acceptance check.
  - Q3 is a link only; privacy wording changes in the same Task.
- **Weaknesses.**
  - RA.R2c §4.2 recommended a factual "forecast N days ahead" label for distant nights. No acceptance
    criterion contains it, so a 16-day cloud value looks as trustworthy as tomorrow's (CA-09).
  - S15.5 (1) lists six or more values per card for up to 16 nights, against the owner's "compact" emphasis
    («Главный акцент на понятном и компактном визуале» [“the main emphasis is on understandable and compact
    visuals”], review-01.10.2026).
- **Missing requirements.** None in scope.
- **Execution risks.**
  - Re-derived ADR-013 vectors (high-risk class).
  - The cache migration and TD-049.
  - Low-end phone timing.
  - Open-Meteo's best-match model changes with lead time.
- **Corrections.** CA-09.
- **Expected outcome.** A compact, honest night layer, if CA-09 is applied.

### D.6 Stage 16 — Screens and flow

- **Strengths.**
  - Implements PD-02, PD-03, PD-04, PD-19, PD-20 and Q4 directly.
  - S16.8 is a finite checklist that runs before the final sweep (AUD-13).
  - AUD-12 prevents an Appearance value from being lost silently in a backup.
- **Weaknesses.**
  - The changes are structural; nothing addresses the visual language (CA-10).
  - Review renders contain placeholder glyphs (CA-11).
  - Several clauses cannot be judged objectively (CA-05).
  - Planner density is left to S16.3's small changes while Stage 14 adds controls (CA-12).
  - S16.5 assumes a filter mapping that AstroBin's contract does not allow, and its calibration counts need
    S14.10 (CA-08).
- **Missing requirements.** The photo-first rig path in onboarding (CA-02).
- **Execution risks.** E2E keys change (`tonight.newSession`, `capturePlan.useExample`); the sweep grows; each
  UI Task needs an owner review cycle.
- **Expected outcome.** A calmer, better-ordered app. Visual polish stays limited unless CA-OD1 = B.

### D.7 Stage 17 — Final validation and GitHub release

- **Strengths.**
  - C1 and C2 ordering.
  - The signed release candidate is the only artifact phone rows run on.
  - The expected certificate fingerprint is checked.
  - One APK hash links S17.5 to S17.8.
  - A corrupt-candidate restore is rehearsed.
  - The Stage 11 matrix is re-baselined under V3.
  - Store-only rows are DEFERRED, never passed.
- **Weaknesses.**
  - "Installed as an update over the previous public build when one exists": no public build exists before
    1.0, so the release key's update path is first exercised by users (CA-14).
  - The universal APK's size is never put to the owner with numbers (CA-13).
  - CI never builds Android (CA-19, optional).
- **Missing requirements.** None.
- **Execution risks.**
  - The human rows (TalkBack, darkness, dogfooding) need people.
  - The owner's data moves from the old id.
  - The debug build that the IDE installed under the release id must be removed first (PROGRESS, S13.2).
- **Expected outcome.** A credible GitHub 1.0 with an explicit VERIFIED/UNVERIFIED record. Readiness
  cannot be claimed while mandatory human rows are missing; that is by design.

---

## E. Expected final product (if Stages 12–17 are implemented as specified)

**What it should look and feel like.**
- **First run:** a single screen. Optional site (GPS on tap) and "What do you shoot with?".
- **Home:**
  - a night card first: dark window, Moon phase with moon-free hours, the cloud range with its freshness;
  - then Your plan, with its fit verdict and Open planner;
  - "What can I image tonight?" as a quieter action.
- **Planner:** a checklist until a target, a rig and blocks exist. Then the verdict, with:
  - class-specific light fields that say where each value came from;
  - Take from a photo;
  - Build calibration from lights, with a preview;
  - a storage figure with its source;
  - the O2b curve against integration time;
  - only the assumptions that actually affect the result.
- **Night & Moon:** a month calendar of moon-free hours and a combined night bar.
- **Weather:** a 16-night overview of cards.
- **Logbook:** results, progress per target and filter, the stored forecast, Share, Export as file and the
  AstroBin CSV.
- **Settings:** Appearance and units.
- **Delivery:** a signed APK with a published fingerprint, on GitHub.

**What remains even when every Task is marked done (realistic forecast).**
1. **Visual character.** Neutral and monochrome unless CA-OD1 chooses a brand accent; "flat" may persist
   even after a correct structural redesign.
2. **The first rig.** Still a specification form for users whose files lack a 35 mm-equivalent focal length,
   and for anyone who misses the photo path (CA-02).
3. **Storage for native DSLR RAW** (CR2/CR3, NEF, ARW, RAF, RW2, ORF), unless CA-07 is decided.
4. **No independent usability evidence.** Comprehension, gloved field use and darkness use rest on the
   owner's and the builder's walkthroughs (S6.E stays UNVERIFIED).
5. **Manual results entry** by design (RG-04). No project goals (deferred).
6. **Catalog breadth.** 164 objects (owner decision RG-07 = T1); custom objects need coordinates.
7. **Updates.** No in-app update hint for a GitHub-only app (CA-20, optional).
8. **Forecast reliability** beyond a few days is inherently low; CA-09 keeps it honest but cannot improve it.
9. **Planner length.** One long scrolling page; density management (CA-12) is the main lever.

**Answers to the forecast questions.**

| # | Question | Answer |
| --- | --- | --- |
| 1 | Finished application? | Likely yes functionally; visually "finished but plain" without CA-10 |
| 2 | Primary workflow convenient? | Yes for users with a saved rig; conditional on CA-02 for beginners |
| 3 | Purpose understood quickly? | Probably. Home's night card and plan card say it, but this is UNVERIFIED without a person |
| 4 | Features coherent? | Yes at the data level; presentation coherence improves with Stage 16 |
| 5 | Polished and professional? | Clean and consistent; "professional" depends on CA-10/CA-11 and the owner's device review |
| 6 | Scientific information trustworthy? | Yes. It is the project's strongest property, and Stages 14–15 keep it honest |
| 7 | Capture Plan advantages real? | Yes: integration, time budget, fit, storage with its source, relative gain over time, calibration help and the record |
| 8 | Beginner-friendly and expert-useful? | Expert: yes. Beginner: conditional (CA-02, CA-12) |
| 9 | Maintainable without frequent regressions? | Yes for code, given the test base. The governance cost is the long-term risk (CA-24) |
| 10 | Weaknesses that survive the roadmap | The list above |

---

## F. Evidence-based scores (0–10)

"After roadmap" = Stages 12–17 implemented to the current, amended acceptance. "With corrections" = also with
§H applied. Whole numbers; judgements, not measurements.

| Category | Current | After roadmap | With corrections | Confidence (current / projected) | Evidence |
| --- | --- | --- | --- | --- | --- |
| Architecture and maintainability | 8 | 8 | 8 | High / medium | Layering, a pure domain, generated migrations, central tokens with a test that forbids colours in presentation; large screen files, cross-ViewModel lifecycle coupling, heavy governance overhead |
| Scientific integrity | 8 | 8 | 9 | High / medium | Reference vectors (USNO, JPL); SI register; honest √N; Unknown is never zero. Open: SI-015, TD-107; future: storage and forecast lead time (CA-07, CA-09) |
| Existing feature completeness | 6 | 8 | 8 | Medium | The core loop is complete; storage is often Unknown, calibration generation and WB are missing, FITS and native DSLR RAW are unread, the example plan contradicts itself |
| Capture Plan quality | 6 | 7 | 8 | Medium | A strong engine; editing defects (TD-107, TD-108, RA-F05); density risk (CA-12) |
| Metadata and input automation | 5 | 7 | 8 | Medium | Bounded DNG, JPEG and HEIC readers with provenance and device checks; import hidden (CA-02); no rig from FITS (CA-06); unread RAW (CA-07) |
| UX and navigation | 5 | 7 | 8 | Medium-low (no human evidence) | Stable tabs and a clear lifecycle; Welcome flash, Skip, duplicated context, a long planner, a rig gate |
| Visual design | 5 | 6 | 7 | Low (host renders with placeholder glyphs) | Consistent AA tokens but monochrome and text-heavy; the brand is absent from the UI (CA-10, CA-11) |
| Data reliability and compatibility | 6 | 8 | 9 | High / medium | Migrations, refusal screen, immutable snapshots, settings in backups; TD-106 is a P0; the restore wording promises a safety copy nobody can use |
| Testing and QA | 7 | 8 | 8 | High / medium | 1,851 tests and green remote CI; no Android build in CI; header-only SQLite fixtures; renders limited; human rows pending |
| Roadmap completeness | 7 | — | 8 | Medium-high | Covers RA.D, both owner reviews and every open TD; misses CA-06, CA-07, CA-08, CA-09, CA-13, CA-14 |
| Roadmap execution feasibility | 6 | — | 7 | Medium | 35 Tasks; two ADR gates, a FITS sample and many owner reviews; history of validation cycles; CA-01 and CA-15 remove two stall points |
| Expected final product quality | 6 (today) | 7 | 8 | Medium-low | Conditional on phone and human evidence; see §E |

---

## G. Findings register

Severities as requested: **P0** critical; **P1** high; **P2** medium; **P3** optional.
- **Type:** DEFECT (verified wrong behaviour), GAP (an approved or necessary capability or criterion is
  missing), RISK (a plausible future failure), IMPROVEMENT.
- **Complexity:** S (local), M (several components and tests), L (model or flow change).
- **Owner decisions** raised here are CA-OD1 to CA-OD3.

### P0

**CA-01 — Restore activates an unchecked database, and the "safety copy" it promises cannot be used.**
DEFECT · confidence high.
- **Evidence (`CODE`).**
  - `backup_archive.dart:92-99`, `:122-128`: only the SQLite magic and `user_version` are checked.
  - `backup_staging.dart:56-85`: settings are restored first (`:66`), then the file is swapped (`:80`); no
    open or integrity check.
  - `main.dart:63-89`: after a failed open the app logs "Database did not open" and continues.
  - `backup_section.dart:47-53`: the confirmation reads "The current data is kept as a safety copy on this
    device." No screen can use that copy.
  - The earlier audit's probe reproduced activation of a 100-byte truncated database (TD-106).
- **User impact.** A damaged backup (an interrupted transfer, a truncated download) replaces the live
  database and settings. The previous database survives only as an app-private `.before-restore-….bak`.
  On a release build an ordinary user cannot reach it; they recover only by restoring another good backup,
  and lose anything newer. "Not proven irreversible loss" (AUD-01) is technically true but understates this.
- **Root cause.** Archive validation was treated as database validation. The safety copy was designed as a
  file to keep, not as a recovery path.
- **Roadmap.** S14.3 (7)–(8) and S17.5 cover the validation. Not covered:
  - the wording or an undo;
  - the order: the P0 fix waits for ADR-021 (S14.1), which it does not need.
- **Correction.** §H M1. **Stage/Task:** S14.3, S17.5. **Dependencies:** none for the fix itself.
- **Tests.** S14.3 (8) as written, plus the confirmation-text test and the M1 phone row.
- **Complexity.** M.

### P1

**CA-02 — The existing remedy for manual specification entry is hidden.** GAP (an existing feature that is
incomplete for the user) · confidence high.
- **Evidence.**
  - "Add from a photo" is a small floating button with an icon and a tooltip only
    (`equipment_selection_screen.dart:238-245`).
  - The empty list shows "No rigs yet." (`:171`).
  - Onboarding offers only "Choose a rig" (`RENDER` Welcome).
  - A plan cannot be saved without a complete rig (`plan_status.dart:50-51`; `equipment_profile.dart:24-39`).
- **User impact.** A beginner with a phone, or a DSLR user, meets a form that asks for pixel pitch and sensor
  size although one photo would fill it (S3; device check M4 passed).
- **Root cause.** The import was hidden behind a gate until S3.7 and then added as a secondary control.
- **Roadmap.** The AUD-04 clarifications in S14.2 and S16.1 say "verify … photo-assisted rig paths"; no
  criterion makes the path visible.
- **Correction.** M2 (S14.2, S16.1). **Dependencies:** none. **Tests:** widget test (a synthetic JPEG reaches
  a saved rig with no sensor value typed), sweep coverage, M1/M4 in S17.5.
- **Complexity.** S.

**CA-03 — Flat warnings ignore the filter-and-binning tuple, and filter identity is case-sensitive.** DEFECT
· confidence high.
- **Evidence.**
  - `calibration_match.dart:102-107` checks the filter and the binning against any light separately (TD-107;
    confirmed).
  - `matches()` compares filters with `==` (`:62`).
  - FITS `FILTER` values (S14.5) are arbitrary text, so "HA" vs "Ha" would produce false warnings and false
    CAL-1 proposals.
- **Roadmap.** TD-107 is covered by S14.10. Name normalisation is not covered.
- **Correction.** M3. **Complexity.** S.

**CA-04 — Block-editor value loss and leakage.** DEFECT · confidence high · **covered, no amendment.**
- **Evidence.**
  - TD-108: an unlisted filter becomes None (`capture_block_dialog.dart:134-135`).
  - RA-F05: the light's exposure is kept when the type changes to Flat or Bias (`:139-141`, `:224-225`).
  - `L` is the default filter for every class (`:134`).
- **Roadmap.** S14.6 (3), (4) and its AUD-03 clarification cover all three.

**CA-05 — Several new acceptance clauses cannot be judged objectively.** RISK (execution) · confidence
medium-high.
- **Evidence.** Clauses that cannot be judged:
  - "understanding of fit/Unknown/relative gain" (shared UI rule);
  - "Verify comprehension … through the bounded existing workflows" (S16.3);
  - "Reconcile the already approved navy identity … no new theme or asset direction" (S16.7);
  - "Review required versus derived rig inputs in the existing editor" (S14.1).

  Disputes over vague or expanding criteria are why Stages 1–4 each failed validation twice (B.3; CLAUDE.md
  V7).
- **User impact.** Indirect: validation churn, waivers, or a shallow pass.
- **Correction.** M4 (testable rewrites). **Complexity.** S (documentation).

**CA-07 — Storage evidence for recognised-but-unread RAW formats is undefined.** GAP · confidence high.
P1 because it decides a core output for a whole camera class.
- **Evidence.**
  - PD-06 and S14.7 (1) say "measured size from any **readable** format".
  - CR2, CR3, RAF, RW2, ORF, XISF, AVIF and PNG are recognised only (`metadata_format.dart:11-65`; RG-14).
  - NEF and ARW are TIFF files without DNGVersion, reported unsupported (`dng_metadata_reader.dart:7-25`).
  - The picked file's length is always available (`CaptureFileAccess`).
- **User impact.** Users of every major DSLR or mirrorless RAW format keep "Unknown" storage unless they type a
  size. A JPEG's size is no evidence for a RAW frame. That defeats PD-06's "complete storage workflow" for
  the camera class the product names first among its users (PRODUCT_DIRECTION §2), and "how much it will
  weigh" is one of the three outputs the owner named (review-01.10.2026).
- **Correction.** M6 (an explicit ADR-021 rule, either way, with honest labels). **Complexity.** S–M.

### P2

**CA-06 — FITS is the approved rig-specification path for astro cameras, but no Task builds it.** GAP
(approved, missing) · confidence high.
- **Evidence.**
  - DECISIONS E.1, "RG-03 decided": "FITS remains the path for astro cameras when a sample exists".
  - RG-03 §3.4: XPIXSZ, NAXIS1/2 and INSTRUME are "the only path found that covers astro cameras with
    provenance".
  - The original S2.6 brief listed FOCALLEN with `softwareSetting` provenance (`POST_ROADMAP_PLAN.md:1093-1100`),
    and `metadata_value.dart:10` already has that provenance kind.
  - S14.5's keyword list has no XPIXSZ, YPIXSZ, FOCALLEN or TELESCOP, and no criterion feeds FITS into
    "Add from a photo".
- **User impact.** An astro-camera user types the specifications by hand even with a frame in hand.
- **Correction.** M5. **Dependencies:** S14.4, S14.5 and the sample. **Tests:** synthetic headers (binned and
  unbinned XPIXSZ), the real sample, an import review test, a device row.
- **Complexity.** M.

**CA-08 — The AstroBin CSV `filter` column is a numeric equipment-database ID.** GAP (wrong assumption) ·
confidence high (`WEB`, [AstroBin: Importing acquisitions from CSV](https://welcome.astrobin.com/importing-acquisitions-from-csv),
read 2026-10-17).
- **Evidence.**
  - `filter` takes "ID of a valid filter from the equipment database"; `number` and `duration` are mandatory.
  - Calibration counts (`darks`, `flats`, `flatDarks`, `bias`) are per row.
  - "Invalid values will be ignored."
  - S16.5 (2) lists `filter` as mapped from the snapshot.
- **User impact.** An export that "works" but silently drops every filter on upload. Calibration counts would
  also be wrong unless they use the corrected tuple matching (TD-107).
- **Correction.** M7 (S16.5 wording; an added dependency on S14.10). **Complexity.** S.

**CA-09 — The 16-night overview has no lead-time label, and its cards are unranked.** GAP · confidence
medium-high.
- **Evidence.**
  - RA.R2c §4.2: for distant nights "a factual label 'forecast N days ahead' is appropriate instead of a
    reliability estimate".
  - S15.4 keeps lead time internally only.
  - S15.5 (1) shows six or more values per card.
  - The owner asked for compact visuals (review-01.10.2026).
- **User impact.** A day-14 cloud value looks as trustworthy as tomorrow's; 16 dense cards repeat the
  "overloaded" problem.
- **Correction.** M8. **Complexity.** S.

**CA-10 — The approved identity does not reach the app's visual language.** GAP (owner decision) ·
confidence high on the facts, medium on the effect.
- **Evidence.**
  - Mark colours are used only by `StartupMark` (`app_colors.dart:11-16`).
  - The primary colour equals the text colour (`app_theme.dart:33`, `:85`).
  - The dark theme is neutral `#191919`.
  - The appearance follows the system (`main.dart:199`), so a navy splash hands over to a white app in light
    mode.
  - S16.7 (integration) says "no new theme or asset direction"; the request's identity brief (navy,
    scientific, Siril/Stellarium-like) points the other way.
- **User impact.** The "flat" impression the owner reported three times is likely to persist after a correct
  structural redesign.
- **Correction.** M9: owner decision **CA-OD1** before S16.6. **Complexity.** S–M (tokens are centralised; a
  test forbids colours in presentation).

**CA-11 — Review renders contain placeholder glyphs.** RISK (evidence quality) · confidence high.
- **Evidence.** In host renders, styles without a font family draw as blocks: app-bar titles and the Welcome
  title (`RENDER`), and the chart labels (memory and render notes). The K14 rule makes these renders the
  visual acceptance.
- **User impact.** The owner judges typography and hierarchy, the very complaints, on images that do not show
  them.
- **Correction.** M10. **Complexity.** S.

**CA-12 — Stage 14 adds controls with no density or form-factor criterion.** RISK · confidence medium.
- **Evidence.**
  - Stage 14 adds provenance markers, WB fields, Take from a photo, Build calibration, storage labels, a focus
    reminder and the O2b graph.
  - The block editor is an `AlertDialog` (`capture_block_dialog.dart:316`) that already holds up to nine
    controls.
  - S16.3 changes only the empty state, the duplicate weather row and the chart size.
- **User impact.** "Overloaded Capture Plan" (08 §14, §17) could return in a new form.
- **Correction.** M11 (measured scroll extent; editor reachability at 200 % with the keyboard open).
  **Complexity.** M.

**CA-13 — The release size premise changed with GitHub-only distribution.** GAP (owner decision) ·
confidence medium.
- **Evidence.**
  - Stage 10's user-relevant size is the arm64-v8a delivery, 24.8 MB (D10-3, `STAGE_10_MEASUREMENTS.md:103`).
  - S17.6 defaults to a universal APK, about 72 MB on an older build according to the earlier audit
    (not re-measured here).
  - The owner's 08 §26 asked to reduce size.
- **Correction.** M12: measured numbers, then owner decision **CA-OD2**. **Complexity.** S.

**CA-14 — The first release cannot test "update over the previous public build".** GAP (verification) ·
confidence high.
- **Evidence.** N5 in S17.5 applies "when one exists"; no Culmina build has been published.
- **User impact.** A signing or versionCode mistake surfaces only at 1.0.1, on users' phones.
- **Correction.** M13. **Complexity.** S (owner signing).

**CA-15 — The FITS-sample gate can stall the roadmap.** RISK (dependency) · confidence medium-high.
- **Evidence.**
  - S14.5 blocks Stage 14's close without a sample.
  - S14.9 (6) includes "(and FITS)", and S14.13 depends on S14.9.
  - The Stage order implies Stage 15 and Stage 16 wait.
  - The owner skipped FITS samples in S2.R2.
- **Correction.** M14 (ask at S14.1; conditional FITS parts; explicit start rules; an S17.1 gate).
  **Complexity.** S.

### P3

| ID | Type | Finding (evidence) | Disposition |
| --- | --- | --- | --- |
| CA-16 | RISK | The restore applies only on a cold start. The success message says "it runs when you reopen the app" (`backup_section.dart:63`; the staged banner says "close and reopen Culmina", `:96`); returning from Recents may resume the process without applying it. UNVERIFIED | S17.5 phone row in M1 |
| CA-17 | DEFECT (docs) | The uncommitted integration files TD-106 (P0) and TD-107/TD-108 (P1) in TECH_DEBT's **Low** table. PROGRESS's Stage table still shows Stage 12 "S12.3, S12.4 open" and Stage 13 "Not started" | M15, when the integration is committed |
| CA-18 | IMPROVEMENT | Storage is printed "7000.0 MB" by hand (`capture_budget_summary.dart:185`; TD-101 class) | M16 (S14.7) |
| CA-19 | IMPROVEMENT | CI runs only `tool/check.dart`; the Android build and the Kotlin tests of the metadata channel run only locally | Optional: an Android job in S17.2, or earlier if Kotlin changes |
| CA-20 | IMPROVEMENT | A GitHub-only app has no in-app pointer to new releases (`app_identity.dart` holds the source URL only) | Optional: a Releases link in About (S16.8); no automatic check, nothing sent |
| CA-21 | GAP (docs) | What location does without Google Play services is undocumented; devices without them are more likely among people installing an APK from GitHub | Optional: one sentence in COMPLIANCE and one check in S17.4 |
| CA-22 | IMPROVEMENT | ADR-021 bundles about ten technical decisions for one acceptance | S14.1 presents a numbered decision sheet, one recommendation per point (as RA.D did) |
| CA-23 | IMPROVEMENT | Safety copies are "never deleted" (`backup_staging.dart:10-14`), so each restore leaves a full database copy | Decide with CA-OD3 (keep the newest N) |
| CA-24 | RISK (process) | Documentation volume (plan 571 KB, DECISIONS 402 KB) and long narrative "clarifications" inside Task rows raise every Task's reading cost and the drift risk (CA-17, AUD-14) | Keep Task acceptance short and testable; narrative in the disposition files |

---

## H. Exact roadmap amendment proposal (finite set; nothing applied)

Each amendment names the Task, the current limitation, the exact wording to add or replace, the reason, its
dependencies, and its validation.
- All are **documentation changes** (V1 documentation class: references resolve; `git diff --check`).
- Amendments to frozen future criteria need the owner's approval (V4).
- None adds a Stage, a Task, a provider or a new product capability.
- M5 completes an already approved decision (RG-03 Q1).
- M9 and M12 are owner decisions.

**M1 — S14.3: restore fix first, truthful recovery wording (CA-01, CA-16, CA-23).**
- *Limitation:* depends on S14.1 as a whole; the safety-copy promise is not addressed.
- *Depends on (replace "S14.1"):* "S14.1 for items (1)–(6). Items (7)–(9) depend on nothing and may be
  committed first, as their own commit within S14.3, once the owner starts S14.3; (9)'s Undo variant needs
  CA-OD3."
- *Add (9):* "The restore confirmation describes only recovery the user can perform, and recommends 'Back up
  first' (the existing backup action) before restoring. It mentions the safety copy only if **CA-OD3** adds
  'Undo the last restore': the newest safety copy staged through the same validated path, (7)–(8), with no
  archive-format change. CA-OD3 also decides how many safety copies are kept."
- *S17.5 add:* "Follow the restore confirmation's instruction on the phone literally, including returning from
  Recents: the staged restore is applied, or S14.3's instruction text is corrected."
- *Validation:* high-risk class as S14.3; a widget test of the confirmation text; the phone row.

**M2 — S14.2 and S16.1: the photo-first rig path (CA-02).**
- *S14.2 add (5):* "Rig creation offers two labelled choices of equal weight wherever a rig is created: the rig
  list and its empty state, the 'Needs a rig' action of the planner and of Tonight, and onboarding (S16.1).
  - 'From a photo' is the existing `/equipment/import` flow, unchanged. It says which files work: JPEG, HEIC
    and DNG (FITS after M5). A camera's native RAW (CR2/CR3, NEF, ARW, RAF, RW2, ORF) is not read.
  - 'Enter by hand' is the editor.
  - For Phone and DSLR/mirrorless the photo choice comes first; for Astro camera manual entry comes first
    until S14.5's FITS mapping (M5) exists.

  Test: a synthetic phone JPEG with FocalLength, FNumber, FocalLengthIn35mmFilm and pixel dimensions reaches a
  saved rig without any sensor value typed. The accessibility sweep covers the choices."
- *S16.1 (2), replace* "(class → rig)" *with* "(class → rig, through S14.2's two labelled choices)".
- *Reason:* removes most of AUD-04's barrier with an existing feature, without changing ADR-011.
- *Validation:* shared-behaviour class; device rows M1/M4 already in S17.5.

**M3 — S14.1 and S14.10: filter identity (CA-03).**
- *S14.1, CAL-1 rules, add:* "Filter identity compares names after trimming and case folding, with no alias
  guessing: `Ha` equals `HA`; `H-alpha` does not equal `Ha`, and that mismatch is reported, not merged."
- *S14.10, tests, add:* "case-only filter differences between lights and flats, and an imported FITS
  `FILTER` value."

**M4 — Testable wording (CA-05).**
- *(a) Shared UI rule, replace* "Record assistance/spec lookup, action choice, errors/backtracking and
  understanding of fit/Unknown/relative gain." *with:* "Run each workflow as a scripted walkthrough, by the
  owner or an agent, on the phone or a host E2E harness. Record per step:
  - the screen;
  - the action;
  - any backtrack or dead end;
  - any value the user had to look up elsewhere;
  - whether the screen itself states the fit verdict, the reason for each Unknown and what relative gain
    means, without opening help.

  A claim that a person understood something is recorded only from a person other than the builder;
  otherwise it is UNVERIFIED."
- *(b) S16.3, replace* "Verify comprehension of fit, Unknown and relative gain through the bounded existing
  workflows, not screenshots alone." *with* "Check what the screens state about fit, Unknown and relative gain
  through the shared rule's walkthrough, not through screenshots alone."
- *(c) S16.7, replace* "Reconcile the already approved navy identity with existing theme roles/contrast and
  field-mode hatching; no new theme or asset direction." *with* "Apply CA-OD1 (M9). Either (A): the UI keeps
  its neutral tokens and the mark appears in the icon, the splash and About only. Or (B): the token changes
  listed in DESIGN_SYSTEM, each with its AA contrast vector. Field mode is unchanged in both cases."
- *(d) S14.1, replace* "Review required versus derived rig inputs in the **existing editor** (AUD-04), using
  its current metadata path and honest missing-value explanations." *with* "ADR-021 lists, per required rig
  field, the calculations that need it and whether the editor or a photo can supply it. The editor shows that
  reason beside each required field (AUD-04)."

**M5 — S14.1, S14.5 and S17.5: FITS → rig (CA-06; RG-03 Q1).**
- *S14.5 (1) add:* "…and, where present: XPIXSZ and YPIXSZ (µm); FOCALLEN (mm, `softwareSetting` provenance,
  never 'from the lens'); TELESCOP (identity evidence only)."
- *S14.5 add (5):* "The equipment fields feed the existing EquipmentCandidate → match → review → Save path
  ('Add from a photo') under ADR-018: proposals with per-field provenance, nothing stored without Save, no new
  screen. Pixel size and dimensions are normalised for binning exactly once, by ADR-021's rule and vectors
  (binned and unbinned writers). RG-03 Q1."
- *S14.1 add:* "the FITS → rig mapping and its binning normalisation."
- *S17.5 metadata row add:* "'Add from a photo' with the FITS sample: the rig is reviewed and saved."
- *Validation:* high-risk (metadata): full gate, real-sample test, device row.

**M6 — S14.1 and S14.7: unread RAW length as evidence (CA-07).**
- *S14.1 add:* "whether a recognised-but-unread file's length is measured storage evidence."
- *S14.7 add (3a):* "A picked file whose format is recognised but not read (CR2, CR3, NEF, ARW, RAF, RW2, ORF, XISF,
  AVIF, PNG) is measured per-frame evidence only if ADR-021 accepts it.
  - If accepted: labelled 'measured from one <format> file; image mode not read; compressed RAW sizes vary
    with content'. It never supplies dimensions, bit depth or compression.
  - If rejected: the storage note says why and points to the rig's manual size.

  Vector: a synthetic CR3 file's length → MB per frame (10⁶ bytes)."

**M7 — S16.5: the AstroBin contract (CA-08).**
- *Depends on, add:* "S14.10 (whole-tuple matching for calibration counts)."
- *(2) add:* "`filter` holds AstroBin's numeric equipment-database ID (AstroBin, 'Importing acquisitions from
  CSV', read 2026-10-17). Culmina stores names only, so:
  - the column stays empty, never a name (AstroBin ignores invalid values without an error);
  - each filter's lights stay separate rows, and the export's share text lists their filter names in row
    order;
  - calibration counts (`darks`, `flats`, `flatDarks`, `bias`) are attached to a light row only through
    S14.10's whole-tuple matching, otherwise empty.

  No AstroBin ID entry, lookup or stored mapping is added."

**M8 — S15.5: lead time and card hierarchy (CA-09).**
- *Add (5):* "Each night of the overview states its lead time, 'forecast N days ahead', counted from the
  snapshot's time to the night's start (RA.R2c §4.2). No reliability score, colour or threshold."
- *Add (6):* "Each per-night card leads with the dark-span cloud range and the Moon (moon-free hours).
  Precipitation, wind and gusts, and dew hours are secondary text. Checked at 412 px and 200 % text."

**M9 — Owner decision CA-OD1, before S16.6: the brand in the UI tokens (CA-10).**

| Option | What changes |
| --- | --- |
| (A) Neutral | Today's tokens; the mark only in the icon, the splash and About |
| **(B) Brand accent — recommended** | Dark-theme surfaces tinted toward navy. The ice-blue family (`#8CCBFF`) as the accent for primary actions, links, selection and focus. The light theme gains the accent only. AA vectors for every changed pair. Field mode unchanged. Tokens only (`AppColors`, `AppPalette`); the colour test in presentation stays |
| (C) Brand plus dark default | (B), plus Dark as the default Appearance for new installs (S16.6) |

- *Reason:* the identity brief, the repeated "flat" feedback, and low implementation risk.
- *S16.6, depends on, add:* "CA-OD1." *S16.7:* M4 (c).

**M10 — Shared UI rule (K14): faithful review renders (CA-11).**
- *Add:* "Every review render draws all visible text in a real font. Either the host harness loads Roboto and
  the Material icons for every text style (the theme names its font family), or the screen is captured
  natively (Windows) or on the phone. A render with placeholder glyph blocks is not visual evidence for the
  affected elements."

**M11 — S14.6 and S16.3: density and the editor's form factor (CA-12).**
- *S14.6 add (6):*
  - "Record the planner's scroll extent at 412 px and 100 % text for a reference plan (three light blocks with
    a filter change, darks, flats and bias) before S14.2 and after each Stage 14 UI Task. Each Task's record
    lists the growth per section, reviewed with its renders.
  - The block editor is checked at 412 × 915 with 200 % text and the keyboard open: every control reachable,
    the primary action reachable, no clipped label. The accessibility sweep opens it (TD-100).
  - If an `AlertDialog` cannot meet this once S14.8 and S14.9 add their fields, the editor moves to the
    existing full-screen dialog pattern."
- *S16.3 add (6):* "The reference plan's scroll extent is recorded before and after S16.3 and reviewed with
  the renders."

**M12 — S17.6 (2): APK packaging with numbers (CA-13).**
- *Add:* "Before packaging, record from the release commit the download and installed sizes of the universal
  APK and of the arm64-v8a APK. The owner chooses with these numbers (**CA-OD2**): universal only, or
  arm64-v8a as the main download plus universal. Every published APK passes (3) and is listed in
  `SHA256SUMS`. Stage 10's D10-3 premise (Play's per-ABI delivery) is recorded as superseded by GitHub-only
  distribution."

**M13 — S17.5: update path before the first public release (CA-14).**
- *Add:* "For the first public release, when no earlier public build exists: install a release-signed build
  with a lower versionCode from the same key, create data, then install the release candidate over it. The
  update is accepted and the data kept. Later releases use the previous public build (N5)."

**M14 — FITS sample and start rules (CA-15).**
- *S14.1 add:* "At S14.1's start the owner is asked for the FITS sample (an owner file or a licensed public
  fixture), so the gate is known before S14.4."
- *S14.9 (6), replace* "(and FITS)" *with* "; FITS parts are conditional on S14.5 and do not block S14.9's
  acceptance or S14.13."
- *Shared rules, add:* "A Task may start when its listed dependencies are met. A pending S14.5 blocks only
  S14.5 and Stage 14's close, not Stage 15 or Stage 16 Tasks that do not list it. S17.1 starts only when S14.5
  is done or the owner explicitly defers FITS reading, recorded in DECISIONS E.1 with its PD-11 and RG-03
  consequences."

**M15 — Registers, when the integration is committed (CA-17).**
- TD-106 moves to TECH_DEBT's **Critical** table; TD-107 and TD-108 move to **High**.
- PROGRESS's Stage table:
  - Stage 12 = "S12.1, S12.3, S12.4 done; S12.2 optional; closure record pending";
  - Stage 13 = "S13.1, S13.2 done; S13.3 implemented; pre-12 and reduced-motion rows pending".

**M16 — S14.7 (4): storage display (CA-18).**
- *Add:* "values through `QuantityText`, in MB or GB by magnitude, decimal (10⁶ and 10⁹ bytes) and stated
  (TD-101)."

**Not amended (already covered):** CA-04 (S14.6); AUD-07, AUD-08, AUD-09, AUD-12, AUD-13, AUD-15, AUD-16 as
integrated. **Optional, outside the active roadmap unless the owner asks:** CA-19, CA-20, CA-21, CA-22, CA-24.

---

## I. Final recommendation

1. **Continue under the current roadmap?** **Yes.**
   - Keep Stages 12–17, the 42 Task IDs and C1–C6.
   - Keep the independent-audit integration, with M15's register fixes when it is committed.
   - Apply §H as one documentation change after the owner's approval.
2. **Essential corrections before the relevant Tasks begin.**

   | Before | Corrections |
   | --- | --- |
   | S14.1 | M3, M4 (d), M5, M6, M14, and the CA-OD3 question (they shape ADR-021) |
   | S14.2 | M2, M10, M11 |
   | S14.3 | M1 |
   | S15.1 / S15.5 | M8 |
   | Stage 16 reviews | M4 (a)–(c) |
   | S16.5 | M7 |
   | S16.6 | M9 (CA-OD1) |
   | S17.5 / S17.6 | M12 (CA-OD2), M13 |
3. **During normal implementation:**
   - M16 (S14.7); CA-04 (S14.6, already covered);
   - CA-16 (S17.5 row); CA-23 (with CA-OD3);
   - CA-19 (S17.2, optional); CA-20 and CA-21 (S16.8 and S17.4, optional); CA-22 (S14.1 format).
4. **Excluded from this release:**
   - absolute SNR (PD-05) and seeing/transparency providers (Q3);
   - a nullable or partial rig model, unless the owner accepts one in ADR-021;
   - catalog expansion beyond 164 objects and online lookup (RG-07 = T1);
   - specification databases and lensfun (RG-03 Q1); proprietary RAW decoders (RG-14);
   - store distribution;
   - ABI variants unless CA-OD2 chooses them;
   - an automatic update check; notifications; localisation;
   - projects and goals; a sky map or framing; device control;
   - a licence change (RG-12 deferred by the owner; note that GPL-3.0 already grants modification rights for
     the published code, against 08 §23's wish).
5. **Existing functionality that most needs completion:**
   1. backup/restore safety (CA-01);
   2. rig creation without typing specifications (CA-02, CA-06, PD-07);
   3. Capture Plan block editing and calibration: TD-107, TD-108, RA-F05, CAL-1 and the storage evidence
      (CA-07);
   4. night-conditions coherence: one Moon predicate and the dark-span forecast;
   5. visual hierarchy and identity coherence (CA-10, CA-11, CA-12).
6. **Realistic quality:** about 7/10 as written; about 8/10 with §H and actually executed phone and human
   rows; 9 would need independent usability evidence and sustained field use.
7. **Next authorized development Task:** none is authorized now. The sequence is:
   1. the owner's decision on committing the integration and on §H (documentation);
   2. the bounded Stage 12–13 closure record, including S13.3's two device rows (PROGRESS's next action);
   3. **S14.1 (ADR-021)** on the owner's start instruction, with the FITS-sample request (M14).

   If the owner wants the P0 first, M1 lets S14.3's items (7)–(9) start before ADR-021.
8. **Stages remaining:** six are open (12–17).
   - Stages 12 and 13 need only closure work: a record and two device rows.
   - Four implementation Stages remain, Stages 14–17, with **35 Tasks** (13 + 6 + 8 + 8), plus the optional
     S12.2.

---

## Appendix A — Requirements traceability matrix

**Classes:**
- **C** — complete and adequately verified;
- **IC** — existing but incomplete; the roadmap covers it;
- **IN** — existing but incomplete; the roadmap does not adequately cover it;
- **AC** — approved, not implemented; the roadmap covers it;
- **AM** — approved but missing from the roadmap;
- **X** — intentionally excluded by an explicit owner decision;
- **U** — unable to verify with the available evidence.

"Host" means host tests or renders only.

| # | Requirement / problem | Source | Current implementation | Remaining gap | Roadmap Task | Acceptance | Class |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | New logo direction; animated splash | 08 §1; review-01.10; S13.1 brief | R3-final approved; launcher, monochrome and AVD splash held 1 s (`570581e`) | Pre-12 and reduced-motion device rows; brand absent from the UI | S13.3 (6), S17.5; M9 | Device rows; CA-OD1 | C (artwork) · U (two rows) |
| 2 | Name collision → new name | review-01.10; RA-C01 | Culmina, `io.github.buffur.culmina`, `Buffur/Culmina` (S13.2, device-checked) | Trademark search optional | S12.2 (optional) | — | C |
| 3 | Home: priorities, empty app bar, date and place first, no New session | 08 §2; review-01.10 (RA-D01–D04) | Context card first; New plan on Home | Reorder to night-first; title row | S16.2 (PD-03) | (1)–(6) + walkthrough (M4) | AC |
| 4 | Night/Moon/Weather taps lead to the planner | 08 §2 | Own detail screens (S6.5) | — | — | — | C (host) |
| 5 | Remove the live tracker; record results afterwards | 08 §3 | Tracker retired (S8.4); results form (S8.2) | — | — | — | C |
| 6 | Bigger catalog, smart search by common name | 08 §4, §9 | Aliases and normalised search (S7.4); 164 objects | Expansion and online lookup not adopted | — | — | C (search) · X (expansion, RG-07 = T1) |
| 7 | New vs open plan clarity; "+" feedback | 08 §5, §8 | Identity strip, Save/Discard/Cancel (S6.2, S6.3); Undo (S6.9) | New plan leaves Home | S16.2 | (6) | C · AC |
| 8 | Site fields: automatic name and coordinates; elevation not required; Bortle/SQM | 08 §6, §13 | GPS on tap, opt-in Nominatim name, optional elevation, collapsed Bortle/SQM, lightpollutionmap.app (S7.5) | TD-097 (`municipality`); GPS UNVERIFIED on the final build | S16.8, S17.5 | TD-097 test; phone row | C (host) · IC |
| 9 | Typography and visual hierarchy | 08 §7, §25; reviews 2026-09-28, 2026-10-01 | Text roles AA (S5.1); still judged flat | Visual language; review fidelity | S16.7; M9, M10 | Owner review on real-glyph renders | IN |
| 10 | Planner title truncated; date icon | 08 §8 | S1.8, S6.2 | Device UNVERIFIED | S17.5 | Phone rows | C (host) · U |
| 11 | Custom target needs RA/Dec | 08 §9 | Sexagesimal parsers (CALC-30); coordinates still required | Online lookup excluded | — | — | X |
| 12 | "Tonight for this target" graph and information | 08 §10 | Timeline (S6.12); Q1 keep, demoted | Compact chart | S16.3 (4) | Renders | AC |
| 13 | Only ZWO; specifications automatically | 08 §11 | Verified seeds; Add from a photo (S3.7, M4 on phone) | Hidden import (CA-02); no rig from FITS (CA-06) | S14.2, S14.5; M2, M5 | M2 test; M5 rows | IN |
| 14 | Conditions and timeline too flat | 08 §12 | S6.12 timeline; text-heavy rows | Night card, details | S15.5, S15.6, S16.2, S16.3 | Renders, walkthrough | AC |
| 15 | Example plan; delete icon and instant delete | 08 §14 | Undo for block delete (RD-09); example still present | Removal after replacements | S14.13 (PD-13) | (1)–(2) | AC |
| 16 | Binning and the ISO/Gain choice | 08 §15 | Class-specific fields (ADR-020 C1); Unknown shows both | Class asked first | S14.2 (PD-07) | (1)–(4) | AC |
| 17 | WB, focus slider, interval | 08 §15; review-01.10 | Interval global (I1); no WB or focus | WB record; focus reminder; no slider | S14.8 (PD-09), S14.12 (PD-10) | As listed | AC · X (slider) |
| 18 | Calibration inherits from lights; tips hideable | 08 §16; review-01.10 | L1 inheritance; hideable tips (S7.3a) | TD-107; generation | S14.10 (PD-12) + M3 | Tuple tests | IC |
| 19 | Outputs: total, integration prominent, fit meaning, √N graph, storage, assumptions | 08 §17 | S6.10, S6.11; storage often Unknown | O2b; storage chain; effective assumptions | S14.7, S14.11, S14.12; M6, M16 | Vectors S1–S4, R-O2 | IC · IN (unread RAW) |
| 20 | Settings audit | 08 §18; review-01.10 | Rebuilt (S9.3, S9.4) | Appearance, units | S16.6 (PD-20) | (1)–(3) + AUD-12 | AC |
| 21 | Library purpose and duplication | 08 §19 | RD-07 roles (S9.1) | Visible Delete; Plan this target | S16.4 (PD-19) | (2)–(3) | IC |
| 22 | Deletion animation and confirmation | 08 §20 | RD-09 patterns (S5.8); swipe on rig and target rows | Visible Delete | S16.4 (2) | — | IC |
| 23 | Tracked belongs to the plan | 08 §21 | Per-plan override (S7.1) | — | — | — | C |
| 24 | Forms flat; input lag | 08 §22 | Controls (S5.2); rebuild fix (S10.3) | Device timing | S17.5 (perf) | Phone rows | U |
| 25 | Prominent authorship, Reddit, GitHub | 08 §23 | About: author, Reddit, GitHub (S9.5) | Play-services statement; Android notices | S16.8 (C4, TD-098) | — | C · IC |
| 26 | Licence: free, no monetization, no modification without permission | 08 §23 | GPL-3.0 (cannot forbid modification) | Owner deferred RG-12 | — | — | X |
| 27 | Logbook: names, search, filters, share, download, entry page | 08 §24 | S8.5–S8.7 | Device UNVERIFIED | S17.5 | L10 | C (host) · U |
| 28 | Size reduction | 08 §26 | arm64 release 24.8 MB (S10) | Universal APK unmeasured (CA-13) | S17.6; M12 | CA-OD2 | IN |
| 29 | Welcome flash, Skip, title, simpler texts | review-01.10 (RA-B01–B06) | Post-frame push; Skip = Done | One screen, route before the first frame | S16.1 (PD-02) + M2 | (1)–(3) | AC |
| 30 | Capture Plan: integration, "approximate SNR", size, records | review-01.10 (RA-A02–A05) | Integration ✓; √N; storage conditional; Logbook ✓ | O2b; storage chain | S14.11, S14.7 | Vectors | IC · X (absolute SNR, PD-05) |
| 31 | Moon presentation like Moonlit; compact night weather with wind, humidity | review-01.10 (RA-E01–E04) | One night only; text rows | Calendar, overview, cards | S15.3–S15.6 + M8 | (1)–(4) + M8 | AC |
| 32 | Planner chain clear; top block empty | review-01.10 (RA-F01–F03) | Answer-first; near-empty status | Checklist; duplicates removed | S16.3 (PD-04) + M11 | (1)–(5) | AC |
| 33 | Values prefilled unexpectedly | review-01.10 (RA-F05) | Confirmed defect | Fix | S14.6 (4) | Widget tests | IC |
| 34 | Are all assumptions needed? | review-01.10 (RA-F09) | Ten rows; stale label (K12) | Effective only | S14.12 (PD-14) | (1) | AC |
| 35 | Logbook and Library do their job | review-01.10 (RA-G01–G05) | Exist; UX unproven | Records changes; phone | S16.4, S17.5 | Walkthrough | IC · U |
| 36 | Settings: what to remove or add | review-01.10 (RA-H01–H03) | — | Appearance, units | S16.6 | — | AC |
| 37 | CI red | RA-I02 | Green since `461e38c`; `570581e` verified | — | S12.1 | — | C |
| 38 | PD-02 onboarding | RA.D 2B | — | — | S16.1 | (1)–(3) | AC |
| 39 | PD-03 Home night-first | RA.D 2B | — | — | S16.2 | (1)–(6) | AC |
| 40 | PD-04 planner empty state | RA.D 2B | — | — | S16.3 | (1)–(5) | AC |
| 41 | PD-05 O2b | RA.D 2A | √N vs frames | Time axis | S14.11 | R-O2 | AC |
| 42 | PD-06 storage evidence chain | RA.D 2A | Rig RAW size × frames | Chain; unread RAW | S14.7 + M6 | S1–S4 + M6 vector | AC · IN |
| 43 | PD-07 class first | RA.D 2A | Class exists, Unknown by default | Ask first; example rig class | S14.2, S16.1 | (1)–(4) | AC |
| 44 | PD-08 provenance of proposals | RA.D 2A | "Proposed from your last light block" line | Per-field origin persisted | S14.6 | (1)–(5) | AC |
| 45 | PD-09 WB record | RA.D 2A | None | Model, snapshot, export | S14.8 | (1)–(4) | AC |
| 46 | PD-10 focus reminder | RA.D 2A | None | Reminder | S14.12 (2) | — | AC |
| 47 | PD-11 metadata-assisted blocks | RA.D 2A | Equipment import only | Take from a photo; FITS | S14.4, S14.5, S14.9 + M14 | Device rows | AC |
| 48 | PD-12 CAL-1 | RA.D 2A | Manual blocks with inheritance | Generation preview | S14.10 | (1)–(7) | AC |
| 49 | PD-13 example removal | RA.D 2A | Example action | Remove after replacements | S14.13 | (1)–(2) | AC |
| 50 | PD-14 effective assumptions | RA.D 2A | All assumptions shown | Effective only; link label | S14.12 | (1) | AC |
| 51 | PD-16 16-night overview | RA.D 2B | Selected night only | Request, cache, cards | S15.4, S15.5 + M8 | (1)–(6) | AC |
| 52 | PD-17 Moon calendar and night bar | RA.D 2B | — | Calendar, bar | S15.6 | (1)–(3) | AC |
| 53 | PD-19 records | RA.D 2B | Progress in the Library | Segment, Delete, Plan this target, forecast | S16.4 | (1)–(5) | AC |
| 54 | PD-20 Appearance and units | RA.D 2B | System theme; fixed units | Preferences | S16.6 (+ M9) | (1)–(3) | AC |
| 55 | PD-21 interval global | RA.D 2A | Global preference | — | — | — | C |
| 56 | Q1 keep candidates, chart, Weather (demoted) | RA.D Q1 | Present | Demotion | S16.2, S16.3 | — | AC |
| 57 | Q2 MF-c Moon definition | RA.D Q2; SI-015 | Two predicates | One predicate in the right frame | S15.1, S15.2 | Vectors, polar cases | AC |
| 58 | Q3 no seeing provider; link | RA.D Q3 | — | Link and statement | S15.5 (3) | — | AC |
| 59 | Q4 AstroBin CSV | RA.D Q4 | JSON manifest and Share | CSV with a correct contract | S16.5 + M7 | Fixtures | AC (contract gap, CA-08) |
| 60 | ID-1–ID-4 name, developer, id, repository | RA.D round 1 | Done (S13.2) | — | — | — | C |
| 61 | GitHub-only distribution | E.1 | — | Packaging, publication | S17.6, S17.8 + M12, M13 | Fingerprint, hash, update | AC |
| 62 | Keep Google Play services location (owner preference) | S12.4 (a) | Kept; §7 in COMPLIANCE and README | About statement; notices | S16.8, S17.4 | — | IC |
| 63 | FITS as the astro-camera rig path | RG-03 Q1 | Recognition only | Mapping into import | — | — | **AM** → M5 |
| 64 | Restore safety | TD-106 (AUD-01) | Unchecked activation | Validation; wording; order | S14.3, S17.5 + M1 | (7)–(9), rehearsal | IC |
| 65 | Calibration tuple warnings | TD-107 (AUD-02) | Defect | Fix + normalisation | S14.10 + M3 | Tuple tests | IC |
| 66 | Custom filter loss | TD-108 (AUD-03) | Defect | Fix | S14.6 | Round trips | IC |
| 67 | SI-013 storage assumptions | SI register | Partial | Chain | S14.7 | — | AC |
| 68 | Other open debt | TD-072, TD-074, TD-049, TD-095, TD-100, TD-101, TD-094, TD-096–TD-098, TD-102, TD-103, TD-105, TD-038, TD-002, TD-020, TD-025, TD-031 | Recorded | Fix or re-check | S14.9, S14.12, S15.4, S16.3, S16.7, S16.8 | Per item | IC |
| 69 | TD-045 Drift renames | TD register | Workaround | — | Excluded in S16.8 | — | X |
| 70 | Independent usability evidence | S6.E; RA.R1 K14/K16 | None (owner-accepted gap) | People | Shared rule (M4), S17.5 Q3 | Walkthroughs; person rows | U |
| 71 | Carried device rows (S2V-06, S3V-08, L10, H6/H7, M3/M4, N5) | Stage 11 runbook | Pending | Phone | S17.5 | Rows | U |

**Summary.**
- Complete: 14 rows.
- Existing but incomplete, covered: 14.
- Existing but incomplete, **not adequately covered**: 5 (rows 9, 13, 19 in part, 28, 42 in part).
- Approved, not implemented, covered: 36.
- **Approved but missing:** 1 (row 63).
- Excluded by the owner: 6.
- Unable to verify: 7.

Some rows carry two classes, so the counts overlap.

---

## Appendix B — Previous assumptions, re-examined

| Assumption in the plan or records | Still valid? | Evidence | Consequence |
| --- | --- | --- | --- |
| "Add from a photo" solved manual specification entry (Stage 3) | Partly | Hidden control; empty list without guidance | CA-02 / M2 |
| "Measured size from any readable format" makes storage complete | Not for unread RAW | RG-14 recognition-only list | CA-07 / M6 |
| The AstroBin export can map `filter` | No | Numeric equipment IDs (`WEB`) | CA-08 / M7 |
| Stage 10's size result is the user-relevant size | No longer | GitHub universal APK | CA-13 / M12 |
| N5 proves update compatibility | Not for 1.0 | No previous public build | CA-14 / M13 |
| Owner render review proves visual quality | Weakly | Placeholder glyphs in host renders | CA-11 / M10 |
| Bounded workflow observations are usability evidence | Only with testable wording | An agent cannot record comprehension | CA-05 / M4 |
| The FITS reader serves the Capture Plan only | Contradicts RG-03 Q1 | E.1 "RG-03 decided" | CA-06 / M5 |
| TD-106 is "not proven irreversible loss" | Understated for users | App-private safety copy without a UI | CA-01 / M1 |
| A partial-rig model is needed for beginners (AUD-04) | Mostly not | CA-02 covers phone and DSLR files with EXIF; the remaining cases stay an ADR-021 owner option | M2; ADR-021 |
| "No new theme or asset direction" (S16.7) | A default, not a decision | Identity brief vs a neutral UI | CA-10 / M9 |
| A FITS sample will be available when needed | Unknown | The owner skipped FITS in S2.R2 | CA-15 / M14 |
| The Stage order 12 → 17 is strictly sequential | Unnecessarily strict | Stage 15 has no Stage 14 dependency | M14 |

---

## Appendix C — Review of the independent audit integration (AUD-01 to AUD-17)

Verified independently where the code allowed; otherwise judged on reasoning.

| ID | Integration's disposition | This audit | Note |
| --- | --- | --- | --- |
| AUD-01 / TD-106 | P0 → S14.3, S17.5 | **Agree** (confirmed in code) | Severity wording understated (CA-01); the order (M1); filed in TECH_DEBT "Low" (CA-17) |
| AUD-02 / TD-107 | P1 → S14.10 | **Agree** (confirmed) | Add filter normalisation (M3) |
| AUD-03 / TD-108 | P1 → S14.6 | **Agree** (confirmed) | Impact grows with FITS `FILTER` values |
| AUD-04 | Partial-rig not approved; review in S14.1, S14.2 and S16.1 | **Agree with the restraint** | The bounded fix is CA-02 (M2); ADR-021 keeps the owner's option |
| AUD-05 | Measured vs theoretical, binning once | Agree | — |
| AUD-06 | Common typed contract before readers | Agree | Extend to FITS rig keywords (CA-06) |
| AUD-07 | Frame-correct Moon predicate | **Agree — a valuable catch** | — |
| AUD-08 | CALC-32 dark span; coverage | Agree | Add the lead-time label (CA-09) |
| AUD-09 | Browsing vs adopting a night | Agree | — |
| AUD-10 | Four bounded workflows | Agree in substance | Wording not testable (CA-05 / M4) |
| AUD-11 | CSV source semantics | Agree | Missed the numeric filter IDs (CA-08) |
| AUD-12 | Preference value types | **Agree** (confirmed: `backup_preferences.dart` groups only bool, int and double) | — |
| AUD-13 | S16.8 before S16.7 | Agree | — |
| AUD-14 | Stale summaries | Agree | Residual drift (CA-17) |
| AUD-15 | Expected signer, one APK hash | Agree | — |
| AUD-16 | O2b comparability | Agree | — |
| AUD-17 | ABI variants optional only | **Disagree on priority** | The size premise changed; owner decision with numbers (CA-13) |

**On the integration's form.**
- It keeps every Task ID and C1–C6, and it correctly refuses to approve new models or providers.
- It appends long narrative "audit clarifications" to Task rows, mixing acceptance criteria with commentary.
  Some of them cannot be judged (CA-05).
- It is uncommitted; committing it with M15's register fixes is the owner's call.

---

## Appendix D — Evidence index

| Item | Location |
| --- | --- |
| Restore path | `lib/data/backup/backup_archive.dart:59-128`; `backup_staging.dart:56-97`; `file_backup_service.dart:127-160`; `lib/main.dart:61-101`; `lib/presentation/screens/settings/backup_section.dart:43-64` |
| Preference backup types | `lib/data/backup/backup_preferences.dart:17-59` |
| Calibration matching | `lib/domain/services/calibration_match.dart:41-131` |
| Block editor | `lib/presentation/widgets/capture_plan/capture_block_dialog.dart:9`, `:128-150`, `:224-273`, `:316` |
| Budget and storage | `lib/domain/services/capture_budget_calculator.dart:245-389`; `lib/presentation/widgets/capture_plan/capture_budget_summary.dart:184-226`; `lib/domain/equipment_import/equipment_candidate.dart:255` |
| Rig requirements and creation | `lib/domain/models/equipment_profile.dart:24-39`; `lib/presentation/widgets/plan_status.dart:40-75`; `lib/presentation/screens/equipment/equipment_selection_screen.dart:171`, `:232-255` |
| Theme and identity | `lib/core/theme/app_colors.dart:11-16`; `lib/core/theme/app_theme.dart:32-34`, `:84-86`; `lib/main.dart:199` |
| Formats | `lib/domain/metadata/metadata_format.dart:11-65` |
| Logbook entry actions | `lib/presentation/screens/logbook/session_detail_screen.dart:495-560` |
| About | `lib/presentation/screens/about/about_screen.dart:20-22`, `:63` |
| CI | `.github/workflows/ci.yml`; GitHub REST API (runs for `Buffur/Culmina`), 2026-10-17: run 39042823307 `success` on `570581e` |
| Host renders (earlier audit, `570581e`) | `%USERPROFILE%/.codex/visualizations/2026/10/17/01a14998-…/culmina-audit/renders/` (tonight_dark_100, planner_light_100, capture_dark_100, welcome_dark_100, settings_dark_100); outside the repository |
| Identity | `docs/refinement/evidence/identity/round5/r3-final-sheet.png`; DECISIONS E.1 (S13.1, S13.3) |
| Decisions cited | DECISIONS E.1: RG-03 decided; RG-07 decided; RA.D round 2A/2B/2C; Q1–Q4; Distribution; S12.4; S13.1; S13.3; Independent audit integrated |
| Research cited | `refinement/research/RG-02_EQUIPMENT_IDENTITY.md` §3.3; `RG-03_EQUIPMENT_SPECS.md` §3.4; `RA_R2C_NIGHT_CONDITIONS.md` §4.2; `RA_D_ROUND2_PACKAGE.md` Parts A–D; `RA_R1_PHASE_A_ASSESSMENT.md` |
| Size | `refinement/evidence/STAGE_10_MEASUREMENTS.md:34-110` |
| External | AstroBin, "Importing acquisitions from CSV", https://welcome.astrobin.com/importing-acquisitions-from-csv (accessed 2026-10-17) |

**Verification of this report.**
- Documentation only (V1): no application, test or tooling file changed.
- References were checked against the files named above.
- The uncommitted integration files and the modified macOS registrant were left untouched.
