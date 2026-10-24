# Owner visual-QA observations

Established 2026-10-24 under the owner's adopted visual-QA protocol. This is an observation register, not project status or an automatic task queue. [PROGRESS](../../refinement/PROGRESS.md) remains the sole current handoff; [AGENTS](../../../AGENTS.md) owns scope and [V1–V8](../../VERIFICATION_POLICY.md) owns verification. The [Concept B 100% completion report](../CONCEPT_B_COMPLETION_100_2026_10_24.md) retains its original evidence and acceptance limits.

Default mode is **RECORD (ЗАНЕСТИ)**. Production correction requires **FIX (ВИПРАВ)** with named IDs or a bounded package. **INVESTIGATE (ДОСЛІДИ)** permits bounded alternatives for an unresolved choice, without adopting them. **STATUS (СТАТУС)** reports dispositions.

Use stable VQA IDs. Record type (`VISUAL`, `UX-HIERARCHY`, `BEHAVIOR`, `SCIENCE/DATA`, `NEW DESIGN DECISION`), impact-based priority, screen/state/theme/actual text scale/device/viewport dimensions (or `UNKNOWN`), problem description, observed/expected behavior, screenshot or other evidence reference, responsible Flutter component and confirmed callers, fact versus hypothesis, status and related CBA/TD IDs. The current target scale is 100% (1.0); do not assume an unverified capture uses it. Allowed statuses: `NEW`, `REPRODUCED`, `NEEDS OWNER CHOICE`, `FIXED IN CODE`, `VERIFIED`, `OWNER ACCEPTED`, `DEFERRED`. Distinguish in-progress work and pending owner acceptance in the entry without treating code fixes as acceptance. Check scientific/functional reports against calculations and source/model, not only pixels. Keep private screenshots, coordinates, records and metadata outside public Git; public fixtures must be synthetic or sanitized.

## Operational clarification — owner, 2026-10-24

**Priority is completing the accepted design throughout the app at 100% (1.0).** Triage reported spacing, unnecessary dividers/borders/visual groups, element placement/grouping, text hierarchy, inconsistent components/states and all other screenshot observations. This does not launch a whole-app audit or authorize automatic fixes. Begin 125%/150% adaptation only after the owner's visual acceptance of the completed 100% result and a separate next-stage instruction; full 200%/TalkBack QA remains later. Preserve existing accessibility tests, unrestricted text scaling and protection against new regressions. VQA-001 remains an open CI blocker; this priority clarification neither closes it nor authorizes its correction.

**Physical Android testing is authorized within this Owner Visual QA workflow.** For a justified observation-specific scenario, launch/navigate/scroll/interact; create, edit and delete clearly identified synthetic QA sites, targets, rigs/equipment, plans, Capture Blocks and Logbook entries; exercise save/edit/cancel/navigation/forms; and change test preferences, themes, dates and states needed for reproduction. Capture real Android screenshots, UI hierarchy, layout geometry, Flutter logs and diagnostics, and compare them with current Flutter source and the accepted design. No separate approval is needed for each such interaction or synthetic-record operation. This permission does not start any scenario automatically.

Preserve real personal records, settings and files. Identify records as synthetic QA data before any potentially destructive operation; retain their identity so cleanup affects only those records. Record initial settings before necessary reversible QA changes and restore personal configuration afterward. Clearing all app data, factory reset, deleting real records, overwriting personal files, restoring backup over real data, or changing system settings beyond necessary reversible QA checks requires separate permission. This clarification grants no APK installation/uninstallation, Git delivery or publication permission.

**The actual Android screen is the primary observation source for visual findings; host Flutter renders support precise comparison.** Before testing, verify the opened package is `io.github.buffur.culmina`, identify the intended source snapshot and confirm the running code matches it. Keep source, installed APK and running VM evidence distinct; successful hot reload alone does not establish freshness. Record the actual theme, text scale and viewport dimensions with the scenario. Unknown provenance stays unknown until verified; this documentation update performs no device check.

## Intake baseline

- Source: `develop`, `47bc723b8698b859e57618f074ec56dccb380d3e`; live remote ref matched during intake. Working tree and index were clean before this documentation change; one worktree and no other active app-thread writer observed.
- Latest develop CI: [40111291219, attempt 1](https://github.com/Buffur/Culmina/actions/runs/40111291219), completed **failure**. Unit 0 and quality-gate fail; checks, unit 1/2 and both host jobs pass.
- At initial intake no owner screenshot had been submitted; the known CI blocker was recorded separately. The owner subsequently supplied the annotated geo/date image and explicitly authorized the bounded VQA-002–006 correction below. Initial unknown device/source inputs were verified for those scenarios, as recorded in the correction receipt.
- Historical CBA-02 remains partial at 200%; CBA-03/04/06 remain deferred. CBA-01/05 and CBA-07–10 retain their documented 100% correction scope and acceptance limits. Do not create new VQA tasks from historical findings without current evidence.

## VQA-001 — Tonight Candidates overflow at 200%

| Field | Observation |
| --- | --- |
| Status | **REPRODUCED — confirmed in matching remote CI; no fresh local/device reproduction**. Correction has not started. |
| Type / priority | `VISUAL` (accessibility) / **P1, technical baseline blocker**: breaks the existing accessibility test and CI quality gate. No data-loss or science error is established. |
| Screen / state | Tonight → Candidates, `/tonight/candidates`, populated synthetic accessibility fixture. |
| Theme / scale / environment | Light, Dark, Field; 200%; Flutter host CI runner, 412 logical px-wide test viewport; failing row constrained to 340 px. Physical device: `UNKNOWN`. |
| Observed | All three `every screen meets the guidelines: <theme>, 200 % text` cases fail with `A RenderFlex overflowed by 2.0 pixels on the right.` |
| Expected | Candidate content and target-selection action remain usable without overflow at the existing test scale; preserve complete accessible content, science/time meanings and existing tests. No text-scale cap. |
| Evidence | [Unit 0 job and logs](https://github.com/Buffur/Culmina/actions/runs/40111291219/job/120923445836), source SHA above; inspected 2026-10-24. No owner screenshot; no private media copied. |
| Confirmed component | [`_CandidateRow.build`, Row at line 420](../../../lib/presentation/screens/tonight/tonight_candidates_screen.dart); expanded title/caption, trailing usable duration and scaled chevron. |
| Confirmed caller / test | Same screen's lazy list builds `_CandidateRow` inside `DocumentSection` (lines 344–358). [`AppRouter.candidates`](../../../lib/presentation/navigation/app_router.dart) routes here. [`accessibility_test.dart`](../../../test/presentation/accessibility_test.dart), theme/scale loop at lines 375–383, includes this route. |
| Fact versus hypothesis | Failure, exact Row and input constraints are confirmed by CI logs/current source. The trailing duration/spacing/scaled icon competing for the reduced row width is a source-based hypothesis; a minimal fix and its affected render surface remain to be reproduced locally under FIX. |
| Related IDs | CBA-08 covers the Candidates 100% composition; its completion does not close this 200% failure. No existing TD ID was matched for this exact defect. CBA-02/03/04/06 remain separate. |
| Next permitted step | Await explicit `ВИПРАВ VQA-001` (or a bounded package including it). Then reproduce and correct only the affected layout, check relevant callers/tests and genuine renders; no new whole-app audit. |

The initial VQA-001 registration changed no production/test/device state. Its source and accessibility test remain unchanged by the later correction package below.

<a id="owner-correction-vqa-002-006"></a>

## Owner correction — VQA-002–006

The owner's explicit “take my observations and fix them” request authorizes this package; it is separate from default RECORD intake. All five entries are **VERIFIED within their targeted scope; owner visual acceptance pending**. [Correction, acceptance matrix and evidence receipt](GEO_DATE_FEEDBACK_2026_10_24.md).

Shared observation context: supplied annotated five-panel Android image, then physical canonical `io.github.buffur.culmina`; Dark, 100% / system scale 1.0, 1220×2712 px at DPR 3.25, about 375.38×834.46 logical dp before insets. Supporting synthetic host renders: Light/Dark/Field at 375×812 dp/1.0. Private Android evidence stays outside Git; the receipt identifies frame names and freshness limitations. No screenshot is assumed to prove source freshness by itself.

### VQA-002 — site list and detail grouping

- `VISUAL / UX-HIERARCHY`, P2. Screens: Sites chooser/Library list with saved rows; saved Site detail. Observed: annotated weak groups, broad gaps, detached delete action and redundant bottom rules. Expected: compact semantic Concept B groups and clear action/fact order.
- Fact: the initial phone VM was stale; the current baseline already contained DocumentSection groups. After verifying freshness, separate search/Add from results, omit final-row rules, and group Edit/Delete together; retain independent position/zone and optional facts. This is no claim that every marked gap was a source defect.
- Source: [`SitesScreen`](../../../lib/presentation/screens/sites/sites_screen.dart), [`SiteDetailScreen`](../../../lib/presentation/screens/sites/site_detail_screen.dart), optional divider flags in existing geo/Library row components. Evidence: `baseline-sites.png`, `after-detail.png`, `after-library-sites.png`, final synthetic three-theme frames; current source/VM match.
- Related: CBA-07 at 100%; CBA-02/03/04 deferred/partial large-text boundaries remain separate. Next: owner visual review; no automatic additional fix.

### VQA-003 — site editor hierarchy and optional copy

- `VISUAL / UX-HIERARCHY`, P2. Screen: new/edit Site, optional section closed/open, scrolled form. Observed: weak position/name/zone hierarchy and explanation detached from the values it describes. Expected: position → identity/zone → optional details, compact pairs at 100%, informative copy adjacent to its fields and reachable Save/Cancel.
- Implemented in [`SiteEditorScreen`](../../../lib/presentation/screens/sites/site_editor_screen.dart) and [`GeoPositionActions`](../../../lib/presentation/shared/geo_controls.dart): named groups, local spacing/pairs, no redundant optional top rule, save-effect note beside identity/zone and Bortle/SQM explanation before Notes. All fields, provenance, units, name-lookup guards and draft semantics remain.
- Evidence: `after-editor.png`, `after-more-top.png`, `after-more-bottom.png`; three-theme closed-editor host frames; site save/cancel/IME/large-text tests. Latest concise explanatory copy is verified in the final input snapshot; earlier optional-open captures retain the same layout with a longer equivalent interim sentence.
- Related: CBA-07, TD-121; no large-text/owner acceptance closure. Next: owner visual review.

### VQA-004 — excess calendar height at 100%

- `VISUAL`, P2. Screen: Tonight/shared night calendar, calendar/input/year modes. Observed: excessive header/footer gaps and a reserved empty week. Expected: a compact dialog sized to the actual month, while retaining civil evening-date selection and cancellation.
- Source: [`pickNight`](../../../lib/presentation/shared/context_line.dart) and [`NightPickerDialog`](../../../lib/presentation/shared/night_picker_dialog.dart). Actual week grid at 100%; native YearPicker and validated input; existing native larger-text composition retained. No text scaling limit added. Explicit semantic day labels and enabled tap actions are covered by a regression test.
- Evidence: supplied before image; `final-phone-calendar.png`; three-theme synthetic `home_nightsheet` frames; local-date, leap-day, bounds, input, year, semantic action and Home Cancel/blocks/fit tests. Calendar content is asserted below 500 dp high at the 375 dp fixture.
- Related: TD-120 shared-night caller; its other criteria remain separate. Next: owner visual review.

### VQA-005 — refuse an exact duplicate site position

- `BEHAVIOR`, P2. Screen/state: New Site save matching a synthetic saved latitude/longitude, including a different name. Previously no duplicate guard. Expected: no second record or selection change; temporary warning identifies the existing site and recovery, while retaining the draft.
- Source: transactional [`DriftLocationRepository`](../../../lib/data/repositories/drift_location_repository.dart), typed [`DuplicateSite`](../../../lib/domain/repositories/location_repository.dart), [`FailureText`](../../../lib/presentation/shared/failure_feedback.dart) and editor precision preservation. Exact numeric coordinate equality only; no fuzzy radius or rounding. Legacy duplicate records are preserved and remain editable at unchanged coordinates.
- Evidence: physical synthetic creation → duplicate refusal → close warning → discard duplicate → delete only the QA record; `qa-duplicate-warning.png`, `qa-dismiss-settled.png`, `qa-cleanup-complete.png`. Drift concurrent-insert, update refusal, self/legacy edit, nearby-position and editor precision/draft tests pass. No science calculation was substituted by a screenshot check.
- Related: geo flow TD-121 context; no prior TD ID matched for this defect. Next: owner review; no automatic cleanup of existing sites.

### VQA-006 — close and transition transient messages

- `BEHAVIOR / VISUAL`, P2. Surface: shared app transient warnings/success/Undo, physically sampled with duplicate-site and deletion feedback. Observed: owner's close/abrupt-transition complaint; source used immediate banner removal even though the current source already had a textual Dismiss action. Expected: a visible close control and smooth entrance/exit without losing Undo or reduced-motion behavior.
- Source: [`AppMessages`](../../../lib/presentation/shared/app_messages.dart), used by all production presentation transient-message callers. Explicit close icon, animated hide, independent action, guarded expired action; keep existing timeout/persistence outcomes and reserved layout space above content. Persistent correctness warnings are outside this transient-message correction.
- Evidence: physical close and deletion-Undo dismissal; animation/expiry/replacement, reduced motion, long actionable 200% warning/48 dp close, stored-record and capture-block Undo, backup feedback and red-only Field tests. Individual rare message-producing workflows were not all driven on the phone.
- Related: TD-081 motion context; no historical register disposition rewritten. Next: owner visual review.
