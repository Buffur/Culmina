# Assessment B — Hybrid only, analysis only

Independence: no Assessment A output was read. Hold this report until A is complete. No app, design, config, skill, memory or observation files changed. Writes are review evidence only.

## Scope and method

Concrete markup targets: design/home-lab/index.html, plan.html, conditions.html, workspace.html. Review URLs use http://localhost:4173/ and variant=blend exclusively; Home uses view=wide. Native destination is Android, but reviewed implementation is HTML. No Flutter/runtime/device claim.

CLI detector ran exactly once across all four markup entrypoints. Exit 2 (findings), JSON saved detector.json; no stderr. No CSS-only scan. Ignore file .impeccable/critique/ignore.md is absent. Target slug is parent setup responsibility; B did not persist a snapshot or read prior critique results.

Browser: first created fresh background IAB tab. Initial /design/home-lab/index.html returned 404 because existing server's root already is home-lab; corrected to /index.html. Native mutable preflight tried setting document.title then appending a script. It failed at title assignment: getter-only property in read-only evaluate. No script tag was appended. No overlay live-server was started, no visibility change or [Human] overlay claim. Native Home AX tree and screenshot inspected; temporary native tab closed.

Fallback: fresh headless Microsoft Edge Playwright browser/context, using bundled runtime; new empty storage isolated from owner's browser profile and 127.0.0.1 tab. Only localhost:4173 was used. All interaction mutations are disposable browser examples, never production data. Parent explicitly allowed this fallback. Screenshots and machine evidence saved here. Context/browser closed at end of each script. No remaining headless/playwright Edge process found in final process inspection. Existing port4173 server was never stopped. No helper live-server to clean up. No temp files outside this retained evidence folder.

59 screenshot states: 27 base view captures, 23 focus/state/200% captures, 8 supplementary captures and one calibration capture (supplement JSON was recreated after a hidden-disclosure locator timeout, its calibration PNG remains). Two additional continuity states in continuity.json. 27 base views: Home; Night/Moon/Weather; Plan, block/context/target/rig editors; Logbook root/detail/progress; Library root, three lists, rig/site detail+editor, catalogue detail; Settings root plus Appearance/Planning/Privacy/Backup/About. Supplement adds calibration builder, assumptions editor, new target/rig, invalid restore and restore review. Result editor plus save failure/retry were covered in focused states. This is representative state coverage across all prototype pages, not every combination of themes/scenarios and not a rerun of existing model/layout suites.

## Deterministic scan: 8 findings, 2 rules

| File | Rule | Count | Level |
|---|---|---:|---|
| index.html | overused-font / Inter | 1 | warning |
| plan.html | overused-font / Inter, Roboto | 2 | warning |
| conditions.html | overused-font / Inter, Roboto | 2 | warning |
| conditions.html | repeating-stripes-gradient | 1 | advisory |
| workspace.html | overused-font / Inter, Roboto | 2 | warning |

All detector locations are line 0: document-level matches, not valid source-line anchors. Full absolute paths and snippets are in detector.json. Totals: 7 warnings, 1 advisory. No browser console detector findings, because overlay could not run.

False positives / intentional choices:
- All 7 overused-font signals are contextual non-defects. They see font options/shared CSS/default stacks across the whole markup, not an isolated rendered blend surface. Actual native Hybrid Manrope is visible in Home and applied in workspace. Inter/Roboto comparison is explicitly pinned; popularity alone is not a design problem.
- Repeating-gradient stripes are semantic missing-cloud data markers, not decorative surface stripes. conditions.css .cloud-column .gap-mark uses the hatch; conditions.js:44 labels it Cloud value missing and distinguishes preceding-hour-only samples separately. Keep the unknown-data encoding unless an equally clear accessible alternative is demonstrated. No request to remove it.

## Concrete browser findings

### [P2] Bundled target title leaks `undefined`
Library > Targets > first catalogue object opens top appbar `Dumbbell Nebula (undefined)`, while the body correctly shows designation M27. Screenshot library-targets-detail.png and library-catalogue-detail.png. Source library.js:412 targetLabel assumes catalogId, while CATALOGUE records use id; library.js:514 applies targetLabel to both saved and bundled records. Data shape mismatch affects the catalogue title path, not only styling. Improvement: format bundled title from its actual designation and keep appbar/body identity consistent; do not change catalogue scope or add actions. Suggested command: harden.

### [P2] Conditions date changes lose keyboard focus
Moon page: keyboard focus Next night; Enter updates to 20 Oct–21 but active element becomes BODY. One Tab then lands Previous night, making repeated next-date browsing take an unintended backward traversal. Evidence moon-next-keyboard and moon-next-tab in focused-evidence.json; focus outline is clear when it is on a control. Source conditions.js:56 replaces all main markup; :57 calls render without restoring initiating control; :60 also recreates calendar/month/week buttons. Improvement: restore focus to equivalent date control or appropriate changed heading; preserve keyboard location when changing dates/weeks. Relevant to Sam/external keyboard and Android accessibility focus concepts, but not an actual Android TalkBack test. Suggested command: harden.

### [P2] Conditions URL and reload lose the viewed context
From URL `conditions.html?variant=blend&view=night`, click Weather then Next night. UI shows Weather, 20 Oct–21; URL still says view=night. Refresh reopens Night, 19 Oct–20. Reproduced once and saved continuity.json. Improvement: keep ephemeral viewed tab/night/cursor in current URL or isolated session state so interrupted viewing can resume without changing the saved plan. Keep adoption explicit. Source conditions.js:16–19 initialize from params; :57/:60 update only in memory. Suggested command: harden.

### [P2, composition recommendation] Long explanatory blocks delay the first editable setting at 200%
At 412×915 and text200, Settings > Planning initially shows only appbar, two long explanatory paragraphs and pinned Cancel/Save; no planning setting is initially visible. screenshot settings-planning-200.png. It is scrollable and does not overflow horizontally, so this is hierarchy/efficiency rather than a blocked form. The copy includes valuable distinctions; preserve their meaning but lead with an editable setting and put detailed preview/app differences in progressive disclosure or outside the phone. The disclaimer text belongs partly to the lab, and native-app transfer requires judgment. Source settings.js:469 onward. Suggested command: distill or clarify.

No P0/P1 supported by B's observed sample. These findings are bounded to the HTML prototype, not proof of production defects.

## Positive evidence and limits

- Root labels and order match: Tonight / Logbook / Library / Settings in Home and workspace, with a selected/current state. Detail/editor flows hide root nav and provide Back.
- Library list keyboard entry moves focus to search; subsequent Tab reaches Add rig with a 2px visible outline. Browser Back from rig detail returns to rig list and restores row focus. This is a positive, unlike Conditions date rerendering.
- No unlabelled input/select/textarea found in captured important forms (label association / aria-label / aria-labelledby inspection). This is not a full screen-reader audit.
- 200% text samples: Plan, Moon, Weather, Logbook, Settings roots plus Planning/Appearance have document and phone width412 at viewport412; no page-level horizontal overflow. Moon switches to week descriptions. Native/browser zoom200 was not tested: this is the lab's text-scale200 control, distinct from browser zoom.
- Weather's sideways hourly graph and full-table overflow are deliberate, keyboard-focusable regions with scroll instructions. Generic overflow counts must not be labelled broken layout. Hidden accessibility text also triggers naive scrollWidth probes and is not a visual defect.
- Error/recovery worked in samples: Logbook simulated load error -> Try again restores list and search focus; Library empty Sites has Add site, blank save shows inline errors and first-field focus; Weather Retry forecast restores covered ready data; result save failure preserves choice/input and Try again saves then returns row; malformed settings restore reports why unapplied and keeps settings; valid file shows review before replacement (replacement not executed).
- No pageerror events in 27 base views. Not a blanket claim of zero runtime bugs.
- Measured rendered Logbook text contrast samples: minimum light7.01, dark7.13; field secondary #AA0000 on black2.71. contrast.json has raw pairs. Field is an existing documented dark-adaptation exception (docs/DESIGN_SYSTEM.md section2; culmina-design-rules SKILL.md:40), so do not frame it as an accidental regression or demand general AA certification. Primary #FF0000 is a separate brighter role. Contrast sample covers Logbook text only and is not full-site AA evidence; hidden filter contents and off-viewport text are included in DOM sampling.
- Selected screenshots show 48px-or-larger main controls; no full target-size audit conducted. Do not claim all controls everywhere pass.

## Evidence index

- detector.json, detector-stderr.txt: single reusable deterministic scan.
- browser-evidence.json: 27 views, control/heading geometry, generic overflow probes, page errors.
- focused-evidence.json: 23 focus/state/recovery/scale states.
- supplement-evidence.json: assumptions/new forms/restore/theme states.
- continuity.json: exact tab/night before and after refresh.
- contrast.json: rendered text color pairs and computed ratios for Logbook light/dark/field.
- *.png: 59 retained screenshots; settings-backup.json is disposable isolated example export used only for restore-preview inspection.
- review.cjs, focused.cjs, supplement.cjs, continuity.cjs: evidence scripts, not installed into repo.

Cleanup: closed own IAB tab; closed all custom browser contexts; final headless/playwright process inspection empty. No detector helper started. Existing preview server left running. Evidence retained intentionally in this permitted folder.
