---
target: Hybrid full reassessment after refinements
total_score: 33
max_score: 40
na_heuristics: 
p0_count: 0
p1_count: 0
target_identity: "file:C:\\Users\\zalub\\OneDrive\\Desktop\\Astro Planner\\Astro-Planner\\design\\home-lab\\index.html"
target_fingerprint: "sha256:7ade6fa6c7b223e6d0f52f836b430660b8fc84773d7389a74d0eba80df6ce3de"
target_path: "C:\\Users\\zalub\\OneDrive\\Desktop\\Astro Planner\\Astro-Planner\\design\\home-lab\\index.html"
timestamp: 2026-10-20T15-11-56Z
slug: design-home-lab-index-html
---
# Hybrid full reassessment — 2026-10-20

Method: dual-agent (A: /root/full_review_a · B: /root/full_review_b), plus independent Claude CLI whole-prototype review.

Scope: current browser prototype `design/home-lab`, `variant=blend`, revision `20261020-hybrid6`. Assessment only; no application changes. This does not constitute native Flutter acceptance, usability research, scientific validation or accessibility certification.

## Current score

**33/40, Claude CLI whole-prototype assessment.** Previous Claude assessment was 32/40. Independent, unanchored assessment A returned **31/40**. These are separate expert judgments, not an averaged measurement. The one-point historical difference should not be presented as proven usability improvement.

| Nielsen heuristic | Claude | Independent A |
|---|---:|---:|
| Visibility of system status | 3 | 3 |
| Match to task and domain | 3 | 3 |
| User control and freedom | 4 | 3 |
| Consistency and standards | 3 | 3 |
| Error prevention | 3 | 4 |
| Recognition rather than recall | 3 | 3 |
| Flexibility and efficiency | 3 | 3 |
| Aesthetic and minimalist design | 3 | 3 |
| Error recovery | 4 | 3 |
| Help and documentation | 4 | 3 |
| **Total /40** | **33** | **31** |

## Findings and bounded next refinements

1. **P2 — Initial assumption consistency.** Settings displays 5 seconds between frames and a 15% margin before preferences are saved. The example Plan uses 7.5 seconds and a fixed 15-minute margin. Plan explicitly labels these Example default, so this is not established as a production calculation defect. However, Home's general statement that the budget uses current global defaults obscures the distinction. Align the initial values, or consistently identify the example-plan source in existing summaries. Evidence: `preview-bridge.js:20`, `plan.js:135`, `app.js:122`; B `settings-state-empty.png` and `fresh-plan-assumptions.png`. Suggested skill: impeccable clarify.
2. **P2 — Library root conceals the simulated load failure.** `rootView()` displays ordinary navigation/counts without checking `S.loadFailed`; `listView()` shows the error only after navigation. Expose the existing recovery message at the root and qualify or suppress counts whose load failed. Evidence: `library.js:570`, `library.js:593`, B `library-state-error.png`. This is a browser scenario finding, not proof of native data loss. Suggested skill: impeccable harden.
3. **P2 — Time-browser affordance.** The rail resembles a static chart; Night start resembles a label beside the displayed time although it is a button. Make the existing reset action visually distinct and add a short visible instruction for moving through time. Do not imply that the currently previewed time is the night boundary. Evidence: `night-ui.js:61`, A `night-light.png`, B `home-412-light-1-bottom.png`. Suggested skill: impeccable clarify.
4. **P2 — Partial forecast headline qualification.** The headline Cloud 19–35% in the dark precedes the 5/7 coverage note by several metrics. Qualify the range as known/sampled hours at the point of reading. Missing values are already preserved as unknown; this is information hierarchy, not a calculation defect. Evidence: `conditions.js:88`, A `weather-partial.png`. Suggested skill: impeccable clarify.
5. **P3 — Repeated explanatory text.** Library child-list disclaimers delay search, particularly at 200%; some unavailable-forecast and denied-location messages repeat. Consolidate each message and keep essential source/privacy/scientific qualifications close to the relevant decision. Evidence: B `qa-inner-target-editor-200.png`, `site-position-denied.png`, `weather-state-unknown.png`, A long-form captures. Suggested skill: impeccable distill.

Secondary observations: empty Logbook can link to its existing planning prerequisite; Welcome/setup's wordmark entry needs visible purpose; new-target copy should not imply that the new record already has stored values. These are refinements of existing routes and wording.

Do not expand Home weather information: the owner's compact-widget requirement remains authoritative. Claude's cloud-first Home suggestion is not adopted as a required change. Applying all four assumption fields as overrides is explicitly stated; changing that contract is not automatically required by this review. No promised score increment is attached to any fix.

## Page-by-page outcome

| Root | Current assessment |
|---|---|
| Tonight/Home | Clear primary planner action and compact weather; clarify assumption provenance and time reset; expose Welcome purpose. |
| Plan | Coherent editors, explicit apply/save and source labels; reconcile initial defaults with Settings and reduce repeated explanations. |
| Night | Explicit dates, interval and timezone; improve discoverability of time manipulation and reset. |
| Moon | Guide/calendar and large-text reflow are sound; inherits the time-browser affordance issue. |
| Weather | Honest unknown/stale/coverage states; qualify partial headline immediately and remove duplicated unavailable copy. |
| Logbook | Planned versus recorded and compact Progress disclosure are clear; empty state can point directly to existing planning. |
| Library | Clear rigs/targets/sites structure and metadata review; root load error and verbose pre-search copy remain weaknesses. |
| Settings | Clear sections and unchanged-restore review; reconcile unsaved defaults with the example Plan. |

## Strengths, specificity and personas

The restrained surfaces, domain units, open rows and selective serif summaries form a coherent astrophotography application rather than a generic dashboard. Preserve the shared editor grammar, draft/saved and planned/recorded distinctions, unknown values, reviewed metadata application and no-op restore behavior.

First-time users are most affected by the time rail, hidden Welcome purpose and empty Logbook next step. Experienced field users need immediate source/coverage qualification. Large-text users face extra scrolling from repeated text; selected 200% views reflow without measured horizontal overflow. Long target/filter choices are mitigated by search and collapsed disclosures; the necessary Moon dates are not themselves a complexity defect.

Detector B returned nine records: seven generic Inter/Roboto popularity warnings (selected Hybrid uses Manrope), missing-data hatching flagged as decorative texture (contextual false positive), and an inherited dialog border plus diffuse 64px shadow (style advisory, not an established defect). None establishes a functional or accessibility failure.

## Evidence and limitations

- A was frozen before the parent read B detector findings. Neither A nor Claude was supplied earlier scores.
- B captured 116 images. Matrix checks: 36 root combinations, 51 inner-view combinations, 12 Home combinations, nine palettes and nine states. These counts are combinations, not unique pages.
- All eight roots and child families were covered: Home sheets/Welcome; six Plan editors; Night guide; Moon guide/calendar; Weather guide/hourly/coming nights and incomplete states; Logbook detail/result/filter/progress/export; Library lists/details/editors, metadata review and position denial; all five Settings sections and restore review.
- Claude CLI completed successfully in 98 turns. Stream evidence contains reads for all 84 selected PNGs; its prose says 82, a counting discrepancy. Preserve the raw report; the selection and stream are the auditable source.
- Claude did not independently read previous functional test JSON; its comments relying on those are not fresh runtime evidence. Its lower Plan content assessment was source-based. A separately inspected Plan save error and restore error. Not every scenario/theme/editor combination was visually inspected.
- B supplementary 66 captures showed no enumerated horizontal-overflow or button/input/select geometry violations. This does not certify radio/checkbox/link hit areas, contrast, complete keyboard traversal or screen readers.
- All 30 application-source hashes still match the prior `hybrid6` manifest. Existing functional checks are unchanged-version supporting evidence, not re-executed tests in this assessment.
- Isolated headless Edge contexts protected owner browser data. No app edits were made. Native Back, IME, TalkBack, physical-device performance, production astronomy/weather and real persistence acceptance remain untested.

Evidence directory: `design/home-lab/evidence/hybrid-full-reassessment-2026-10-20/`.
Key artifacts: `a/ASSESSMENT_A.md`, `a/coverage.json`, `b/SCREENSHOT_MANIFEST.md`, `b/SCOPE.md`, `b/DETECTOR_INTERPRETATION.md`, `CLAUDE_FULL_QA.md`, `claude-result.json`, `claude-selected-images.json`, `claude-stream.jsonl`.
