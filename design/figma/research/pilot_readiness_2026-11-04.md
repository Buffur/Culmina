# Tonight and Plan: navigation research and baseline readiness

Date: 2026-11-04. Scope: After Dark design artifacts. This report combines read-only local reference/source inspection and current official icon sources. It is not a live-Figma audit or a native test. Navigation recommendations remain analysis; no automatic root-icon replacement is prescribed.

Subsequent explicit owner decision, 2026-11-04: Moon / Notebook Pen / Archive / Sliders Horizontal are adopted for the four root tabs, and the appearance control's visible Field caption is removed. The earlier recommendations below retain their research chronology; current implementation scope and verification are in [Navigation](../components/navigation.md) and [WORKFLOW](../WORKFLOW.md). Broader icon replacement is not implied.

## Decision and evidence boundary

The corrected Tonight and Plan are recorded as accepted composition baselines for further Dark mockups, alongside **After: Design System** for reusable components and states. The current task's scoped checks and owning contract/workflow updates are complete as reported below. Composition acceptance does not imply complete-library, native or release acceptance.

The root agent's final live readback, visual/playback review and local validation report the scoped results below. This researcher did not operate the live Figma UI; the following results are attributed to the root agent's current verification, not a second independent live audit.

### Final refinement evidence — root-agent live readback

- Current closed Longreads: Tonight **375 × 1367**, Plan **375 × 2580**. Both Night ahead containers have **8px bottom padding**. A full visible-screen descendant structural check reports zero flow/bounds findings. The two Exact times chevron clipping flags are SVG wrappers; subsequent visual inspection found no visible clipping. Both complete Longreads passed 100% visual review through eight overlapping views.
- All six pilot command labels and all 48 master Action labels are Geist SemiBold. All **188/188 original text contents and sizes** are preserved, with six intended pilot action-font changes.
- All **12 settled timeline swaps** pass the reported layout checks; opening adds **216px**. Tonight's labeled Field masters retain **48 × 48** targets, reciprocal links, a **20px Moon at x14/y4** and caption at **y26**. Fresh live Plan inspection found that its caption was already hidden; that composition is preserved through separate icon-only masters **`111:35739` / `111:35746`**, with the 20px Moon centered at **x14/y14** and reciprocal links. Both controls passed Off / On / Off web playback.
- The dedicated **nineteenth `actionLabel` style** is verified across all **48 Action states**, with no text-bounds issues. The original **18 styles** and **all 116 file variables** remain unchanged: After collection 94, proposal collection 16 and QA collection 6. The new style replaces unbound weight overrides.
- The adopted pilot board **`111:34801`** on After: Design System contains all four Field states across the labeled/icon-only compositions, local light primary actions, adopted root navigation and annotations. Its top, navigation and lower notes were visually reviewed; Hug sizing measures **843px** high. Tonight's existing Moon/Weather wrapper (**184px**) and Plan Conditions (**220px**) now Hug content; Conditions explicitly retains the previously visible **8px** lower inset. An actual Conditions Sky-disclosure swap grows the card **220 → 320px** and Plan root **2580 → 2680px**, then restores the exact closed state; the reported check passes.
- **55/68 protected fingerprints** match unchanged. The other **13**, covering three local action groups and ten dependent catalog families, exactly match their original baselines when both original font and text-style IDs are transiently restored. The new `actionLabel` was then reapplied. Final classification: **55 unchanged + 13 intentional action-dependent changes; zero unexpected changes**.
- Web playback: Tonight Exact times opened, selected **05:42**, then closed while retaining markers, readout and **No dark remaining**; root tabs reflowed. Plan opened Exact times, selected **00:17**, then closed while retaining markers and **5 h 25 min**; Conditions and Save reflowed. Fresh structural readback counts all **24 timeline CHANGE_TO links**.
- Composited pilot-action text contrast passes: Open planner and Save plan **16.559:1**, Tracking remedy **13.169:1**, and the other three commands **14.179:1**. Across all 48 catalog Action states, enabled text has a **4.882:1 minimum**. The disabled minimum **3.192:1** is recorded as an intentional inactive-control exception, not an enabled-text pass or complete accessibility acceptance.
- Final local gates pass: contract validation **263 local links / 94 tokens / 24 contracts / 14 external paths**; instruction validation **27 skills / 49 files / zero errors**; all **nine instruction unit tests**; and `git diff --check`. Owning modules, QA composition-baseline checkboxes and the current workflow status/fresh QA record are updated.
- Root-navigation icon alternatives remain analysis only. These results do not establish native, 200%, first-viewport or complete-library acceptance.

Read current [workflow](../WORKFLOW.md), [target index](../TARGET_DESIGN_SYSTEM.md), [navigation](../components/navigation.md), [forms](../components/forms.md), [typography](../typography.md), [geometry](../spacing_and_border.md), [Tonight](../screens/tonight.md), [Plan](../screens/plan.md) and [QA](../qa_checklist.md). Historical F01 acceptance and its 93/514 visual regions do not validate this refinement. No native, screen-reader or 200% acceptance is established by this report.

## Reference evidence

The machine-local reference collection is:

```text
C:/Users/zalub/.codex/visualizations/2026/10/29/01a18540-fc19-7d30-a78c-581e611ffa11/android-ui-atlas/ui_atlas/
```

Paths below are relative to that exact collection, not repository-relative links. Read the original PNGs at full resolution; cropped UI/XML rectangles are observations, not recovered source tokens or padding rules.

| Exact local evidence | Observation and allowed use | Limit |
| --- | --- | --- |
| `notion.id/llm_ready/START_HERE.md`, `AI_DESIGN_SPEC.md` sections 2–4, `01_navigation_details.png` C01 S01 | Quiet selected/unselected hierarchy; visually inspected the original detail panel. | C01 is top navigation. C02 is Search / Ask AI / Compose, an action bar rather than bottom destination navigation. Do not copy its topology. |
| `com.twtapp/llm_ready/AI_DESIGN_SPEC.md`, `detail_01_components.png` C02 S01, `QA_REVIEW.md` | Actual five-destination bottom navigation: icon above label, shared optical baseline, stronger selected icon/label and persistent selection cue. Original detail panel visually inspected. | The 343.4 × 64dp rectangle is an observed XML union. Purple capsule, five destinations and underline are not Culmina targets. QA covers an offline captured slice, not current app behavior. |
| `com.cron.calendar/llm_ready/AI_DESIGN_SPEC.md` section 1 | Neutral selection can inform visual restraint. | Navigation is a drawer with layout modes; this is not a bottom-navigation reference. |
| [Reference mapping](../reference_mapping.md) | Defines the adopted Notion/Calendar transformations and their limits. | Astronomy, routing, data truth and action semantics belong to Culmina. |

## Bottom navigation analysis

Preserve **Tonight · Logbook · Library · Settings**, four equal flexible targets and visible labels. Plan remains above the shell. Keep the accepted small-radius neutral active rectangle, stronger selected label/icon and quieter inactive content. The rectangle plus label weight already gives a non-color selection cue; another check or underline would duplicate that cue and contradict the accepted local treatment.

The useful reference improvement is consistency: center each icon in the same slot; align label baselines; use one optical icon-to-label rhythm; retain readable inactive ink and a separate safe inset. Keep navigation quieter than the explicit Open planner / Save plan actions. Do not turn this into a floating creation/search bar or import the reference's five destinations, gradient capsule or saturated selection.

Current source facts: [AppShell](../../../lib/presentation/navigation/app_shell.dart) uses equal targets, 56px minimum button height, 19px icon size, 5px icon-to-label gap, selected weight 600 and inactive weight 400; large text changes the arrangement. These are production facts, not proof of live After geometry and not an instruction to overwrite After's chosen values. [HybridIcons](../../../lib/presentation/shared/hybrid_icon.dart) contains moon, book, archive-box-shaped `library` and slider-shaped `settings` geometry.

The adopted pilot board **`111:34801`** makes the current small-radius/no-check root-navigation composition explicit. Earlier catalog pill/check geometry is superseded for this baseline; any retained historical specimen must not silently become the source for new screens. A future state-specific audit should cover all four selections and their focus/pressed treatments rather than treating Tonight-selected as proof of every state.

## Official icon analogs

These official pages were checked live on 2026-11-04. The role recommendations are design judgments, not claims of measured user recognition. Keep the existing family unless a scoped replacement is adopted; the owner requested a moon replacement for Field, while root navigation remains research scope.

| Role | Analog | Assessment |
| --- | --- | --- |
| Tonight | [Moon](https://lucide.dev/icons/moon) | Simple crescent and closest current identity. Preserve the written Tonight label. |
| Field | [Moon](https://lucide.dev/icons/moon) | The simplest owner-requested crescent at compact size. Preserve each live composition: Tonight retains Field caption; Plan's already-hidden caption stays hidden. Both retain explicit field-mode On/Off intent and a persistent non-color state cue. This is not proof of native semantics. |
| Field alternative | [Moon Star](https://lucide.dev/icons/moon-star) | Adds detail and stronger astronomical association; less suitable for a compact Field control. Not recommended over the simple Moon. |
| Logbook | [Notebook Pen](https://lucide.dev/icons/notebook-pen), alternative [Book Open](https://lucide.dev/icons/book-open) | Notebook Pen emphasizes recording; Book Open is simpler but reads as reading/browsing. Compare at actual size before adopting. |
| Library | [Archive](https://lucide.dev/icons/archive), semantic alternative [Library](https://lucide.dev/icons/library) | Archive is closest to the existing box glyph. Books communicate library but can become visually similar to Logbook. |
| Settings | [Sliders Horizontal](https://lucide.dev/icons/sliders-horizontal) | Closest current identity; introducing a cog has no demonstrated benefit here. |

[Lucide design language](https://lucide.dev/contribute/icons/design-principles) specifies a 24 × 24 grid, centered 2-unit strokes and round caps/joins. Culmina's local 1.8-unit Figma rendering is an adaptation; match the adopted local weight consistently instead of mixing unmodified imports. Center both the nominal icon slot and the visible crescent optically, without shrinking the 48px action target. Preserve icon provenance and applicable [Lucide license](https://lucide.dev/license) notices.

## Proposed precedence for new screens

1. Current owner decisions and Culmina product/scientific invariants remain authoritative.
2. Accepted, revision-labeled Tonight/Plan establish composition, hierarchy, local density and command emphasis for matching screen patterns.
3. The reconciled **After: Design System** provides reusable state/variant behavior, tokens, typography and controls. It must include adopted pilot deltas rather than requiring designers to rediscover scattered local overrides.
4. Owning contract modules specify the adopted values and exceptions; [workflow](../WORKFLOW.md) records actual evidence, limitations and acceptance. Earlier conflicting entries remain historical.
5. LLM-References inform visual grammar and alternatives. They do not override Culmina semantics or supply invented measurements.

This is a proposed explicit precedence statement for the current decision record. It does not authorize Flutter migration, Light/Field Red redesign, changes to BEFORE, or full-project construction in this research task.

## Readiness checklist

Checked items reflect the root agent's reported current evidence above. All current-task gates below are complete within their stated scope. Follow-up native/scaled-text work is explicitly separate from readiness to construct further Dark mockups.

- [x] Re-read both actual live Longreads and the affected Design System masters; record IDs and dimensions after settled layout.
- [x] Verify both Field compositions' centering, 48px targets, text/glyph bounds, reciprocal On/Off links and retained state cue. Preserve Plan's pre-existing hidden caption and Tonight's visible caption.
- [x] Check the complete Tonight and Plan at 100%, top to bottom: eight overlapping views; no visible clipping/overlap, including the two chevron SVG wrappers. Both Night ahead bottom insets remain 8px with settled open/closed reflow.
- [x] Confirm all 48 Action states and six pilot commands use the adopted SemiBold emphasis and dedicated `actionLabel`; text bounds pass. All 188 original text contents and sizes remain intact.
- [x] Re-measure composited action text contrast on actual adjacent surfaces: six pilot commands and all 48 catalog Action states; record the disabled-state exception separately. This scope is not a blanket indicator/accessibility audit.
- [x] Recheck twelve settled timeline variants (+216px open) and web playback in both contexts: synchronized markers/readouts, retained selection and following-content reflow.
- [x] Finish the fresh 24-link structural check and actual Conditions Sky-disclosure growth/restoration check.
- [x] Preserve protected baseline/resource evidence: 55 unchanged + 13 verified intentional action-dependent deltas, zero unexpected; original 18 styles and all 116 file variables unchanged. Keep original scientific words, Unknown, provenance, explicit Save and archives.
- [x] Provide reconciled visual specimens on adopted board `111:34801`: both Field compositions/states, light primary actions and adopted root navigation. Do not claim every historical catalog specimen was visually audited.
- [x] Update owning contracts, QA and workflow with Moon compositions, inset/Hug repairs, nineteenth `actionLabel`, RootTabs supersession, scoped evidence and accepted composition-baseline status for AFTER-DARK-1.2.
- [x] Run contract/instruction validation, all nine instruction unit tests and `git diff --check`; all pass with counts recorded above.
- [x] State remaining limits explicitly: first-viewport/safe-inset evidence, scaled-text scope, non-drag accessible reorder alternative, native accessibility and runtime behavior remain follow-up work. Native/200% acceptance does not follow from composition approval; these are not blockers for this task's incremental Dark-mockup readiness decision.

Readiness judgment: **ready for incremental Dark mockup construction using the accepted Tonight/Plan compositions and the adopted Design System board**. Current-task contrast, disclosure/link, documentation and local validation gates are complete. This does not mean every project screen, catalog state or historical specimen received visual review; state-inventory preservation and selected-state checks do not establish full-library visual acceptance. Earlier root pill/check geometry is superseded through the adopted board, while root-icon alternatives remain analysis only and no global icon-family replacement is adopted. New screens should reuse these composition baselines and reconciled states, extending the catalog only when actual content/state requires it. Native, 200%, first-viewport/safe-inset and accessible non-drag reorder work remain explicit follow-ups; Flutter implementation and native acceptance require separate work.
