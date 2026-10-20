---
name: culmina-design-rules
description: Apply Culmina product-specific UI decisions, scientific invariants and documented debt boundaries. Use before implementing or reviewing a Culmina design change.
---

# Culmina design rules and technical debt

Start with `docs/design/WORKFLOW.md`. Read the current task and referenced entries of `docs/DECISIONS.md`, `docs/TECH_DEBT.md` and `docs/ENGINEERING_GUARDRAILS.md`; never load historical reports as a second task queue.

## Product rules that change design decisions

- Planning first: understand the night, make a realistic Capture Plan, save it and record a result. No telescope control, camera operation or invented Astro Score.
- Answer first; details remain reachable. Basic camera parameters follow the selected camera class and approved AM-04 decisions; keep useful calculations behind clear disclosure.
- Production Home is a summary: selected place/night, conditions, any due result, the current plan and Open planner, then candidates. The owner's browser comparison may explore plan-first ordering; keep the prototype delta explicit. No unguarded New plan or Start control on Home.
- Use selected-night wording consistently. Remembered coordinates are not a live position; never label them Current position or silently overwrite edited inputs.
- Preserve explicit units, source/freshness and Unknown. A missing forecast is not 0% cloud; relative stacking gain is not absolute SNR.
- Fit (Fits / Tight / Doesn't fit / Needs input) and persistence (Saved / Saved · changed) are separate meanings. Use words and reasons, not green/red alone.
- Keep Save/Discard/Cancel and draft boundaries. Do not silently save while changing a theme or navigating a concept.
- Offline core remains meaningful. Simulated data in a concept must be visibly identified as an example.
- Owner concept preference (2026-10-19): a Notion/Paper base with Journal's The night ahead section; restrained colours. The lab now includes that Hybrid and other reference-based proposals in a horizontal gallery. The preference is not approval to change the production composition or fonts.

## Target platform and reference boundaries

The owner explicitly requires an **Android app** concept. The browser is only the preview host. Preserve the approved restrained Hybrid Notion + Journal direction; use the existing application for functions, data and workflows, not as a visual template. Android anatomy governs app bars, Back, Material controls, touch targets, scrolling, system/keyboard insets and text scaling. Keep lab controls outside the app viewport. A desktop browser must not turn the phone concept into a web dashboard. Prior Apple, Fluent and Spectrum research supplies transferable principles, not Android component styling. Browser captures do not prove native gestures, keyboard behavior or device acceptance.

## Debt handling

An example in a video or pasted screenshot is not Culmina policy. In particular, never create an exception for inaccessible buttons or freeze a defect because an example called it legacy.

Classify a real issue from the live register:

| Evidence | Action |
| --- | --- |
| Existing invariant or accepted exclusion | Preserve it and cite its decision |
| Documented temporary exception | Preserve its exact boundary, reason and remediation task; do not expand it |
| Regression or task criterion failure | Repair within the authorized task, applying CLAUDE.md verification |
| Adjacent unrelated defect | Record a precise finding; avoid opportunistic scope expansion |
| Style preference or new behavior | Mark proposal; do not invent acceptance approval |

Existing intentional exception: field-mode secondary text has a documented dark-adaptation tradeoff (`docs/DESIGN_SYSTEM.md` §2), not general AA evidence. Existing science and time contracts are not debt to simplify away.

## Handoff and review

Record: task/baseline; scenario; decisions and criteria; relevant components/tokens; changed files; checks/evidence; limitations; next allowed action. Reuse valid evidence under `CLAUDE.md` V3. Distinguish browser prototype, host widget, emulator and physical-device evidence. Review against frozen criteria; avoid repeated preference-driven audits.
