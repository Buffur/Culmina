# Final Claude design-QA screenshot pack

Review the current original Hybrid (`variant=blend`) against `docs/design/HYBRID_REVIEW_2026_10_20.md`, its explicitly authorised scope, the functional/scientific boundaries and the evidence reports. This is an HTML Android prototype; no native acceptance claim. Report concrete defects/regressions separately from optional taste. Preserve Manrope/selective serif, Unknown, saved versus viewed state, read-only snapshots and red field-mode exception. Analysis only for final QA.

All filenames below are relative to this folder. `qa-root-*` and `qa-inner-*` were captured after the final `20261020-hybrid3` version bump. Root Home is a 412 px phone cropped from a 1280 px host; other phone captures use a 412 × 915 host. Text200% is the lab control.

## Start with all eight root views

| Surface | Capture |
| --- | --- |
| Tonight/Home | [qa-root-home.png](qa-root-home.png) |
| Plan | [qa-root-plan.png](qa-root-plan.png) |
| Night | [qa-root-night.png](qa-root-night.png) |
| Moon | [qa-root-moon.png](qa-root-moon.png) |
| Weather | [qa-root-weather.png](qa-root-weather.png) |
| Logbook | [qa-root-logbook.png](qa-root-logbook.png) |
| Library | [qa-root-library.png](qa-root-library.png) |
| Settings | [qa-root-settings.png](qa-root-settings.png) |

## Priority refinements and enlarged text

| Question | Useful captures |
| --- | --- |
| Does Moon lead with the exact answer and reach its calendar sooner? | [Moon200](qa-root-moon-200.png), [weekly calendar200](qa-child-moon-calendar-200.png) |
| Does Weather preserve numerical/unknown meanings with less trust repetition? | [Weather200](qa-root-weather-200.png), [hourly200](qa-child-weather-hourly-200.png), [dark](conditions-weather-dark.png) |
| Does Night retain the answer and reachable guides? | [Night root](qa-root-night.png), [field](conditions-night-field.png); inspect disclosed source content with `conditions.md` |
| Are Plan time scopes and Apply/Save distinct? | [Plan200](qa-root-plan-200.png), [block editor200](qa-child-block-editor-200.png), [global budget](plan-global-budget.png) |
| Are Logbook results ahead of the read-only snapshot? | [detail200](qa-inner-logbook-detail-200.png), [dark detail](logbook-detail-dark-200.png), [result editor200](qa-inner-result-editor-200.png), [progress200](qa-inner-progress-200.png) |
| Are the actual first Planning controls usable at 200%? | [first screen200](qa-child-settings-planning-first-200.png), [advanced scrolled200](qa-inner-settings-planning-200.png) |
| Are Home interactions phone-bound and consistent? | [site](qa-home-site.png), [date](qa-home-date.png), [candidates](qa-home-candidates.png) |
| Are full backup boundaries and confirmation clear? | [backup review light](backup-review-light-1.png), [backup review200](backup-review-light-2.png), [backup review dark200](backup-review-dark-2.png), [field200](backup-review-field-2.png) |
| Do managed Library records integrate only on explicit Plan selection? | [Plan Library context](plan-library-context.png), [Home context](home-library-context.png), `continuity-checks.json` |

## Remaining existing child surfaces at 200%

- Rigs: [list](qa-inner-rigs-list-200.png), [detail](qa-inner-rig-detail-200.png), [Add rig](qa-inner-rig-editor-200.png).
- Targets: [list](qa-inner-targets-list-200.png), [catalogue detail](qa-inner-target-detail-200.png), [Add target](qa-inner-target-editor-200.png).
- Sites: [list](qa-inner-sites-list-200.png), [detail](qa-inner-site-detail-200.png), [Add site](qa-inner-site-editor-200.png).
- Settings: [Appearance](qa-inner-settings-appearance-200.png), [Privacy](qa-inner-settings-privacy-200.png), [Backup](qa-inner-settings-backup-200.png), [About](qa-inner-settings-about-200.png).

Supporting evidence: `browser-matrix.json` (36 root/51 inner/12 Home/9 palette/9 state observations), `interactions.json` (11 contract groups), `conditions-browser.json`, `conditions-confirm.json`, `logbook-checks.json`, `backup-checks.json`, `continuity-checks.json`, `qa-resource-probe.json`, plus each worker's Markdown report. These are repeated themes/states and assertions, not unique-screen counts.

Resource caveat: browser enumeration recorded two `ERR_NO_BUFFER_SPACE` requests; both resources subsequently returned200 in a narrow probe. Initial parallel mount timeouts are preserved separately. No product defect was inferred from those host-resource observations.

