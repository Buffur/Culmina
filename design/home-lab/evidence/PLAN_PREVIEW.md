# Home priority and Plan preview — verification, 2026-10-19

Scope: focused review of the main Hybrid against the new official sources, removing the Your plan edge, comparing Home priority and building a separate project-grounded Plan preview. [Review, source citations and project mapping](../../../docs/design/PLAN_CONCEPT_REVIEW_2026_10_19.md). This records browser evidence, not native adoption or production calculation equivalence.

## Requirement audit

| Requirement | Evidence | Result |
| --- | --- | --- |
| Use the new sources alongside earlier references | Six focused official pages successfully retrieved after mapping Apple HIG, Fluent 2 and Spectrum sites. Context7 official Apple/Fluent queries; official Spectrum site retrieved through Firecrawl when not resolved by Context7. [Source index](plan-source-index.json) and cited review separate guidance from our synthesis | PASS |
| Assess the main concept and recommend improvements | Review recommends task-first priority for an existing plan, open grouping, one primary action and progressive detail; empty/missing-input exceptions are explicit. Original Notion/Journal direction remains | PASS |
| Remove Your plan shadow/edge | Computed pre-change inspection identified a top border plus 6 px radius and no shadow. Current four-member Hybrid family: border 0, radius 0, shadow none, transparent fill; functional input/focus borders remain | PASS |
| Evaluate plan before weather | Actual Home DOM switches between plan-first and conditions-first; plan-first is default. Wide layout puts plan in leading column (x ≈ 289), conditions in secondary column (x ≈ 749), same top. Production Flutter order is unchanged | PASS |
| Reproduce a Plan page from the project | Separate `plan.html` opens through each concept's Open planner. Actual project source mapping covers fit/context/target/rig/blocks/estimates/Details/Save; no hardware-control Start or absolute-SNR feature | PASS |
| Make the preview interactions reviewable | Block Apply versus plan Save, validation, camera-class fields, failed-save retry, reload persistence, missing-input recovery, block Undo and unsaved-change guard exercised through UI | PASS for the recorded scenarios |
| Keep results accessible on smaller screens | Final 12 layout cases: desktop 1280×1000 and mobile 412×915, 100/200% text, three themes. Main/document widths equal scroll widths; Save bar stays inside viewport (subpixel tolerance 1 px) | PASS for these layouts |

## Executed checks

- `node --check` on app.js, plan.js, plan-model.js and catalog.js: PASS on the final files.
- `node design/home-lab/scripts/check_plan.mjs`: **11 tests passed**. Covers independent reference budgets, too-long plan, decimal/fractional exposure and subsecond formatting, calibration timing placement, comparable versus distinct/unknown groups, class-specific sensitivity, missing inputs, snapshot records, Kelvin/tint validation and unavailable/corrupt storage.
- `python design/home-lab/scripts/check_inventory.py --self-test`: PASS; all 21 exported original source files match hashes/full text; proposal role/geometry coverage remains consistent.
- Skill Creator validation: updated component/rules skills and the other three design entrypoints validated during closure. This does not itself prove agent behavior.
- Local source references, retrieved-source statuses, Markdown links/whitespace, JavaScript syntax, served-byte equality, encoding and `git diff --check`: checked during closure.

No Dart/application/test/dependency/build input was changed by this task. No new Flutter tests, analyzer run, build, CI, emulator or physical-device evidence is claimed. Previous native evidence remains separate from this browser page.

## Browser evidence and corrections

[Structured browser checks](plan-browser-checks.json) contain the following actual observations:

- Blank Frames shows an explicit validation error and keeps plan Save disabled during the block edit. Blank input stays blank; error text is a description rather than part of the input's accessible name.
- Applying 180 × 60 s changes integration to 3 h and window budget to 3 h 22 min 30 s under the visible fixture assumptions; state becomes Saved · changed.
- Back opens Unsaved changes; Cancel preserves the editor. The save-fails-once example preserves the changed state and exposes Retry save. Retry succeeds; reload restores 180 frames and Saved. The sample was then restored to 120 × 60 s for delivery.
- Typing 1/125 then switching DSLR to astro preserves the draft exposure, shows gain and hides ISO. It does not convert the old ISO record into gain.
- Removing the last light block produces Needs a block and a disabled Save. Undo restores the block and prior state. During another open block edit, Undo is disabled; cancelling that edit makes restoration available again.
- Missing forecast is explicitly unavailable and can be retried. With no site there is no night selector; Needs a site and a disabled Save remain visible until the site is supplied.
- The editor at width 412, text 200% and a constrained 520 px viewport has width = scroll width = 362 px; the Save bar remains within the viewport with an explicit Apply/Cancel reason. This is a constrained browser viewport check, not a physical soft-keyboard test.
- Final 12 layout measurements were repeated against the final loaded page after corrections. Document widths are 1270/402; main widths equal scroll widths. A fresh final Plan tab has no warning/error entries.
- Both Home order choices preserve all four flat Hybrid plan summaries. Main Home at mobile/200% in each theme has frame width = scroll width = 345 and document width = viewport width = 402.

The first interaction pass exposed the input accessible-name/blank-count issue; it was corrected. A later Undo disabled-state edit introduced a syntax error that prevented Plan loading; `node --check` and a new-tab browser load confirmed its repair. The affected remove/edit/cancel/Undo path was rerun, followed by final layout confirmation. Historical errors are not presented as successful final checks.

Captures:

- [Open Home with plan first](home-plan-first.jpg)
- [Plan desktop](plan-desktop.jpg)
- [Plan mobile at 200% text](plan-mobile-200.jpg)

Preview arithmetic uses explicit example window, overhead and file-size assumptions. Weather/astronomy, acquired calibration counts, production persistence and native accessibility are outside what these artifacts prove. All writes are confined to the lab's own sample key; no application database is used.
