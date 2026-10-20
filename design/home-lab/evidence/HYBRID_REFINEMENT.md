# Hybrid refinement completion evidence — 2026-10-19

Scope: owner-authorized repairs of F1–F4 from the video-guidance audit, current Notion/Apple study and new variants of Hybrid Notion + Journal. This supersedes the earlier extension record for changed lab inputs. Production application files and dependency files were not changed; one isolated native widget trial was added.

## Requirement audit

| Requirement | Authoritative evidence | Result |
| --- | --- | --- |
| Fix incomplete token semantics | Proposal JSON has 13 described roles and explicit foreground/background pairings; all 35 exported palette roles have specific usage text; field surface alias names the correct exception. Live Colours tab shows 13 role rows and 35 palette rows, including action pairing and chart meanings | PASS |
| Connect geometry to rendering | App consumes space/productionRadius/proposalRadius; intended CSS groups/plan samples use those variables. A real file-edit/reload probe changed lg 24→29 and Soft radius 14→17; computed gap/radius became 29/17. Final restored values are 24/14 | PASS |
| Detect stale source metadata | `check_inventory.py --self-test`: 21 source hashes/full texts match; semantics, geometry snapshot and variant coverage match. In-memory corrupt hash, missing source and missing role description are rejected | PASS |
| Document component properties/states progressively | Component skill links forms/navigation/data-display references separately. Maps identify actual APIs, slots, state ownership, selection semantics, adopters and tests. Referenced native source was inspected | PASS |
| Demonstrate skills on real components | `skill_application_test.dart` composes real ContextLine, PlanStateLabel, StatusBlock and controlled CollapsibleSection; [research document](../../../docs/design/NOTION_APPLE_STUDY_2026_10_19.md) traces the task through relevant skills, contracts and checks | PASS for this bounded trial |
| Analyse Notion and Apple fonts/design/elements | Live public-site visual inspection and computed styles in [observations](notion-apple-observations.json); official Notion product styling and Apple font documentation; component-level alternatives in the research document | PASS |
| Preserve and extend favourite Hybrid | Original preserved; Page (Inter), Soft (Onest), Desk (Manrope), all with Source Serif 4 night heading. Default family rail has four concepts; All concepts has ten | PASS |
| Provide reviewable working variants | Live server at `http://127.0.0.1:4173`, direct selection, horizontal rail and wide layouts; original scenarios and font controls remain available | PASS |

## Executed checks

- `flutter test --no-pub test/presentation/design_system/skill_application_test.dart`: **6 tests passed**, three themes × 100/200% text. Checks real instances, unknown/measured input, saved-state separation, theme token colours, callbacks, controlled disclosure and absence of layout exceptions at width 412.
- `flutter analyze --no-pub`: **No issues found**, 69.2 s, after the final Dart change.
- `dart format test/presentation/design_system/skill_application_test.dart`: formatted; final no-change format check recorded during closure.
- `dart run tool/check_encoding.dart`: PASS.
- `node --check` on app.js and catalog.js: PASS after final JavaScript changes.
- Final HTTP byte equality: all nine inspected page/module/style/data assets match the local files.
- `python design/home-lab/scripts/check_inventory.py --self-test`: PASS after restoring the temporary probe and after the checker geometry extension.
- Skill Creator `quick_validate.py`: all five skills valid. This is structural validation; the native trial supplies the separate application evidence.
- Markdown references, named local source/test paths, whitespace and `git diff --check`: checked during closure.

No application build, full suite, CI or physical-device validation is claimed. Unchanged legacy native tests were inspected where relevant but not rerun as fresh acceptance evidence. The browser source catalogue is still a deliberate snapshot: run its checker before relying on it and regenerate after relevant source edits.

## Browser evidence

- [Hybrid checks](hybrid-browser-checks.json): 12 responsive combinations, four family members × three themes at 412 × 915 and 200% text. Document width 402; frame/content widths and scroll widths all 345. No horizontal overflow.
- The same record contains 24 state checks, four members × six scenarios: ready, unavailable forecast, missing target, no site, loading, error. No-site hides the selected-night control and shows Needs a site; missing values do not become a Fits verdict.
- Native font family is Manrope / Inter / Onest / Manrope respectively; night headings are Source Serif 4. Golos Text override replaces the night heading as well.
- [All ten mobile layouts](hybrid-all-ten-mobile.json): all concepts at 200% text retain content width = scroll width = 345 and document width = viewport width = 402.
- [Final mobile navigation](hybrid-mobile-navigation.json): at 200% text the four labels reflow to two columns, each remains one line and no label clips. This corrects the word splitting seen during the initial screenshot pass.
- [Catalogue verification](hybrid-catalog-check.json): live role descriptions, field exception and specific scientific chart meanings present.
- [Token-edit probe](hybrid-geometry-probe.json): declared 29/17 renders as 29/17. The first attempt exposed cached JSON; all JSON fetches now use `cache: no-store`. Original proposal values were restored and rechecked in the browser.
- Desktop Desk at 1280 px uses actual columns approximately 389 / 448 px for conditions and plan; Page deliberately remains one readable content column in wide view. Mobile reflows to one column.
- Plan dialog opens from the actual Open planner button; Cancel closes without editing the fixture.
- [Family rail check](hybrid-rail-check.json): Next moves from 0 to 399.3 px and changes the visible range from 1–3 to 2–4 of four; keyboard ArrowLeft returns to 0 and range 1–3.
- Final browser warning/error log: empty.

Captures:

- [Page, Soft and Desk comparison](hybrid-family-desktop.jpg)
- [Desk wide layout](hybrid-desk-wide.jpg)
- [Soft dark at 200% text](hybrid-soft-mobile-200.jpg)

All astronomy/weather values are illustrative fixtures. These captures prove browser rendering, not scientific calculations, production routing, real forecasts, platform accessibility certification or universal agent reliability. No Figma synchronization or proprietary Notion/Apple token system is claimed.
