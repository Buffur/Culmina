# Independent Assessment A — current Hybrid full prototype

Date: 2026-10-20. Target: design/home-lab, variant=blend, eight roots and their task screens. Mode: Operate. Independent A by /root/full_review_a; no earlier critique, score or detector findings consumed. Read-only app/source review. Only evidence files written under this a/ directory.

## Verdict

The Hybrid has a coherent, restrained Android-oriented visual language. Typography, open rows, explicit units and selective serif summary headings are grounded in planning a night, rather than a generic dashboard. Existing functions are understandable and the main task path is clear. No blocking visual defect was established in this bounded pass. Remaining priorities are modest but useful: qualify incomplete weather summaries at the point of scanning, expose the time browser's interaction more clearly, and make empty/start guidance easier to find.

This is browser concept evidence, not native Android acceptance, scientific calculation validation, usability research or WCAG certification. Field secondary-text tradeoffs are an existing documented boundary and are not scored as a newly discovered global AA defect. Browser-native select/file/date widgets and known fixture limitations are out of scope.

## Ten Nielsen heuristic scores

Scale 0–4, higher is better. All ten apply.

| Heuristic | Score | Current evidence and reason |
|---|---:|---|
| Visibility of system status | 3 | Saved, fit, draft/application language, retry-save and forecast coverage are explicit. Partial forecast qualification is below the headline and other metrics. |
| Match with users' task/world | 3 | Night spans, units, target/rig context, planned versus recorded and moon-free dark suit astrophotography. The partial cloud range still reads more comprehensively than its sampled basis. |
| User control and freedom | 3 | Cancel/Apply/Save boundaries, Back, field toggle, restore review and cancel are visible; Library editing explicitly preserves saved snapshots. This pass does not establish every browser/native exit path. |
| Consistency and standards | 3 | Shared app bars, rows, disclosures, bottom navigation and persistent editor actions across all roots. The Home wordmark-as-Welcome entry is less discoverable than labeled workspace rows. |
| Error prevention | 4 | Particularly strong scoped design: metadata review before application, explicit coordinate permission request, guarded replacement review, unrecorded values kept distinct from zero, and clear plan/result separation. This rates observed prevention design, not exhaustive failure testing. |
| Recognition rather than recall | 3 | Good inline context, readable labels and target search. Timeline manipulation and the Welcome route are less evident from visible labels alone. |
| Flexibility and efficiency | 3 | Search, filters, progress grouping, direct task rows and large-text calendar reflow support repeat work. Empty Logbook asks users to navigate back to planning without a direct next-action link. |
| Aesthetic and minimalist design | 3 | Cohesive neutral hierarchy, few decorative cards, clear answer-first roots. Some long forms and dense explanatory text create a noticeable reading burden, though scientific meaning should be retained. |
| Error recognition/recovery | 3 | Clear retry actions and preserved-data messages for load/save/restore/metadata problems. Inspected failures are recoverable in wording; not every persistence failure was exercised end-to-end. |
| Help and documentation | 3 | Contextual disclosures explain assumptions, privacy, sources, unknowns and staged saving. Welcome is hidden behind the brand and time-browser guidance is collapsed below the visualization. |
| **Total** | **31/40** | **Good, coherent existing-function prototype; focused refinement remains.** |

## Priorities, ordered

1. **P2 — Qualify the partial Weather headline where the range is read.** Trigger: Weather → lab Forecast gaps. Screenshot `weather-partial.png` shows “Cloud 19–35% in the dark” followed by temperature, wind and rain before “Coverage: 5/7” and “Forecast gaps remain unknown.” The missing hours are correctly preserved in the underlying state; the weakness is hierarchy and wording, not a claim that they are calculated as clear. A quick scan can mistake the range for the entire dark interval. Reword the existing headline to identify sampled hours, or bring the gap qualification next to it. Source: conditions.js:88 and :93. Affects quick field decisions and novice interpretation.

2. **P2 — Make the Night time rail visibly actionable.** Trigger: open Night at 100%, default selected night. Screenshot `night-light.png` / `contact-light.png`: a thin vertical line and stacked bands look like a static graphic; the visible label is “Time,” while interaction explanation sits inside “Read the time browser.” The source does provide a range input and accessible “Preview time” name (night-ui.js:61); this is a visual discoverability concern, not missing functionality or a native slider complaint. Use the existing visible label/instruction to say that users can move through the night. Source: conditions.js:48. Affects first-time users who may read the initial daylight state as the only state shown.

3. **P3 — Give the empty Logbook an explicit route back to its prerequisite.** Trigger: Logbook → Empty. `logbook-empty.png` ends with “Nothing saved yet. Plans you save appear here…” and no action within that empty state, while Search, Filters and Progress by target remain above it. Bottom Tonight navigation exists, so this is an extra interpretation/navigation step rather than a dead end. Link the existing planning path from this explanation and let the empty-state instruction take precedence over empty tools. Source: logbook.js:617. Affects first-use users; no new feature is required.

4. **P3 — Welcome/setup is difficult to discover from its visible entry.** Trigger: Home → tap the small “culmina” wordmark. `home-phone-light.png` and `welcome.png` show that useful workflow/setup guidance is available, but its visible trigger looks like branding; the accessible name is already “Welcome and setup.” Make the existing entry's purpose discoverable in visible wording. Source: app.js:149 and :230. Affects users who want orientation after skipping first setup; screen-reader naming is better than visual discoverability here.

## Cognitive load and emotional journey

Home presents one dominant next action, Open planner; Library offers three meaningful groups; Settings splits five rows into two sections. These are strong choices. Above-four-option decisions occur in the six-result Plan target list (mitigated by search), the five camera classes (necessary distinctions, including Unknown), and the Moon date grid (necessary dates, with a readable list layout at 200%). These are not automatic defects. Expanded Logbook filters add several independent criteria and can fill the viewport before the records; collapsed defaults help.

A new user's likely valley is orientation: Welcome is unobvious and empty Logbook is explanatory rather than actionable. An experienced user's likely valley is reading many caveats/fields while reaching precise values. Save and restore endings are reassuring: actions distinguish applying a draft from saving it, checked restores explicitly say nothing has been restored yet, and failed saves say changes remain.

Persona flags: beginner — time-rail discoverability and empty-state next step; experienced field user — partial forecast headline can be over-read; large-text user — roots require more scrolling, but selected 200% screens reflow and Moon calendar becomes readable rows; data-conscious user — explicit location request and restore review are strengths. No physical-device, motor, screen-reader or real dark-adaptation claim is made.

## Strengths to preserve

- Domain honesty: unknown versus measured/recorded, planned versus recorded integration, example/source/freshness wording and snapshot boundaries remain explicit.
- Coherent navigation and editing: persistent commit actions, readable rows, search/filter/progress and distinct draft application make the prototype feel like one application.
- Deliberate large-text behavior: selected Plan, Logbook, Settings and Moon 200% views remain legible; the Moon calendar switches to a list rather than compressing seven enlarged columns.

## Coverage and limits

See `coverage.json`, `roots.json`, `deep.json`, `supplement.json`, screenshots and contact sheets. Root captures: all eight roots at light/dark/field, with Home corrected to device-level captures after initial screenshots showed lab chrome. Visually inspected contact sheets and individual screenshots include all non-Home roots/themes; Home light, Welcome field; selected 200% roots/calendar; key Weather unknown/partial/no-dark/no-site, Logbook empty/error, Settings error; all five Settings subsections; Logbook filters/progress/detail/result; rig detail/editor, site editor/location disclosure, catalogue target and custom-target editor; Plan block/target/rig/context; save-error; restore review/error; metadata disclosure/error.

Browser snapshots/DOM text also cover Night/Moon unknown/no-dark/partial/no-site and workspace empty/error/storage-error scenarios. Not every captured scenario was individually opened as pixels; coverage.json distinguishes capture from human-style visual inspection. Metadata successful review, device-position success/denial, calibration editor, assumption editor, every result outcome and every 200% editor were not exercised by A. No evidence is fabricated for those states.

Two inspection harness corrections were needed: initial Home screenshots showed lab chrome; resumed local editor/navigation state caused locator timeouts. Fresh isolated context captured the missing Plan views and custom target. These harness events are not app defects. A reads no detector output; assessment B belongs to the parent synthesis. Questions for owner are left to the parent; A proposes no implementation and requests no new feature scope.
