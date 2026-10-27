> **Historical navigation copy — not active instructions.** Link destinations are rebased from `docs/design/HYBRID_SEVEN_REFINEMENTS_2026_10_20.md`. Content and acceptance statements retain their original date/scope. [Immutable original](../../../docs/design/HYBRID_SEVEN_REFINEMENTS_2026_10_20.md) · [Navigation index](../../../NAVIGATION.md). Original SHA-256: `53d29ca2ae7215ef6274a5b703a37237396abf8c8ac33144b5508b878749da9b`.

# Hybrid — seven focused refinements

Owner scope: implement the seven proposed improvements only for the original Hybrid (`variant=blend`), without adding features; use skills/subagents/CLI and finish with Claude design QA. This is browser-prototype work, not native Flutter adoption.

## Implementation and acceptance

| # | Delivered change | Authoritative evidence |
| --- | --- | --- |
| 1 | Plan explains when current Settings defaults differ from its saved budget, next to persistence status and separately from fit. Comparing the saved context avoids blaming a night-only change on Settings. Saved bytes are untouched. | `plan-clarity/checks.json`; `continuity/continuity-checks.json`; Plan 100%/200% captures |
| 2 | Assumption fields name the real source: Global default, Plan override, Saved budget or Example default. Pending Apply/reset sources are explicit. Percentage margins show their calculated duration; overrides show Fixed. A known fixed value remains visible when the custom window/fit is unknown. | `check_hybrid_plan_clarity.cjs`; seven browser groups, effective/pending/reset/unknown scenarios; summary and fourth-field captures |
| 3 | Progress has a short intro, combined results/date metadata, clear target/filter/settings hierarchy and a closed grouping explanation. All totals, compatibility groups and unrecorded sensitivity remain. | `logbook-settings-checks.json`; group text compared with Paper; three themes at 200%; opened-guide confirmation |
| 4 | Weather detail has one prominent freshness warning and precise hourly-sample coverage, retrieval time and age. Seven point samples are not mislabelled as seven hours. Home retains one compact Weather widget. | `conditions-results.json`; 15 groups including unavailable/partial/offline/no-dark; `feedback-home-checks.json`; Home widget capture |
| 5 | Hybrid names the evening with Night of 19 Oct and the following date with Ends 20 Oct. The Home chooser updates the following-date label while browsing and Cancel writes nothing. Zone/DST/UTC models and (+1) remain unchanged. | Conditions DST/month-end/reload checks; Plan night-only check; Home 100%/200% Cancel and month-end checks |
| 6 | Hybrid workspace feedback occupies a layout row below the scroll area and above navigation/gesture space. Long messages wrap without overlaying data/actions; a different destination clears old feedback. Existing inline errors and Retry remain. | `feedback-home-checks.json`: 3 themes × 2 scales, exact boundary geometry, actual download message; restore-failure/Retry checks |
| 7 | An identical settings file shows Already up to date and Close, with no Replace action/write. Equality is exact and key-order independent. Differing values, including differences hidden by rounded display, retain explicit restore, Cancel and failure/Retry. | `logbook-settings-checks.json`; reordered identical JSON and 5.1-vs-5-second cases; identical-file 200% capture |

All changed presentation is gated to Hybrid. Other variants retain their previous wording, assumption presentation, Progress explanation, restore action and floating feedback. Paper control comparisons cover these branches; shared asset query revisions change cache identity only.

## Scope and implementation choices

No new scientific calculations, provider, record type, persistent schema, navigation destination or native capability was added. Existing Apply sets all four assumption overrides; the UI now explains that behavior. Use global defaults still removes overrides. The reset preview retains the saved file-size fallback that Apply already used.

Data labels keep fit separate from persistence and known fixed assumptions separate from unknown windows. The seven hourly samples span a 7 h 30 min dark interval, so coverage describes samples rather than inventing an hours count. The field-mode secondary contrast exception remains explicit; screenshots are not accessibility certification.

Changes are in `design/home-lab/{app.js,styles.css,plan.js,plan.css,conditions.js,conditions.css,night-ui.js,logbook.js,logbook.css,settings.js,workspace.js,workspace.css}` plus cache-version references and focused verification scripts. Native application/database files were not changed.

## Verification

- 79 model/contract checks passed: 14 Plan, 46 Night, 15 quality, 4 bridge/backup.
- Seven focused Plan groups; ten Home/feedback groups; 15 Conditions groups; three Logbook/Settings groups passed. Groups overlap and are not unique-screen counts.
- Six integration groups cover actual Library forms → Plan selection, global Settings → current budget → explicit save, reset inheritance, Home Cancel, backup dispatch and denied-storage fallback.
- Eleven existing tab interaction regression groups passed, with no browser page errors.
- Syntax, whitespace and inventory checks passed. The inventory verifies all 21 native source snapshots. Body hashes of unchanged model/bridge/backup files are compared with the previous delivery after normalizing cache revision strings.
- Tests use isolated Edge profiles on localhost. The owner's 127.0.0.1 storage was not automated or cleared.

Initial helper failures were corrected rather than hidden: a parent test used a nonexistent Progress selector and then assumed navigation did not restore Progress. The corrected helper uses the real selector and resets only its own isolated navigation context between independent cases. Agent helper fixes concerned a boolean `open` attribute and fixture seeding on a neutral document. These were harness problems, not product findings. Raw CLI transcripts and the bounded QA reports are retained.

The initial seven-change delivery was `20261020-hybrid5`. One bounded correction batch produced `20261020-hybrid6`: consistent Hybrid phone-dialog text scaling, separate following-date text to avoid select truncation, and the fixed-known/fit-unknown margin presentation. Focused confirmation checks exercise those changes; unrelated evidence is reused because its relevant inputs did not change.

## Skills and independent review

Applied Culmina rules/components/spacing/typography, the Impeccable plugin's polish/craft guidance and Playwright CLI. Three subagents implemented Plan, Conditions, and Logbook/Settings respectively; the parent implemented Home/feedback and integrated verification. Context7 supplied current Claude CLI documentation. Claude CLI 2.1.304 was restricted to Read, with no session persistence or external MCP tools.

AntiGravity CLI 1.4.3 reviewed supplied source without tools. Its known-fixed-margin/unknown-window observation led to the correction above. Two other claims were rejected against source: Apply already captures all four overrides, and settings validation accepts the exact plain-object schema while equality checks own keys. No unvalidated array/undefined payload reaches the reviewed branch.

The Impeccable plugin detector returned 44 contextual findings: 42 shared/comparison-font matches, the semantic missing-data hatch, and an existing base lab-dialog border/shadow advisory. These are not seven-refinement regressions. They do not justify replacing the pinned Manrope identity, removing unknown-data encoding or expanding this task into a lab redesign.

Claude's initial QA read 14 screenshots and five behavior reports, then inspected feedback CSS. It accepted the seven flows with explicit visual evidence gaps and found one P2: inconsistent Home chooser scaling at 200%. The correction measures paragraph, label, select and both buttons at 14 px / 28 px for 100% / 200%. Additional evidence shows the compact Home widget, fourth/example assumption field and opened Progress guide.

The final bounded confirmation read five new images and two behavior reports. Claude marked all seven criteria PASS, closed the original P2 and found no remaining P1/P2 in these corrections. Its remaining question about the example margin is resolved by `plan-model.js`: the fallback is 900 seconds, displayed as 15 minutes; it is not the global 15% preference. This focused review does not establish a new app-wide score; 32/40 remains the previous app-wide assessment, not a fresh score for this delivery.

Completion audit: all seven numbered requirements have both implementation and scoped verification evidence above; subagents, relevant skills, CLI review and the final Claude QA are complete. Final asset hashes are in `final-source-hashes.json`; `unchanged-contracts.json` verifies unchanged model/bridge/backup contracts after replacing the cache query revision. No required work remains inside this scope.

## Evidence and preview

- [Evidence directory](../../../../../../design/home-lab/evidence/hybrid-seven-2026-10-20)
- [Initial Claude QA](../../../../../../design/home-lab/evidence/hybrid-seven-2026-10-20/CLAUDE_QA.md)
- [Final Claude confirmation](../../../../../../design/home-lab/evidence/hybrid-seven-2026-10-20/CLAUDE_CONFIRMATION.md)
- [Current Hybrid](http://127.0.0.1:4173/index.html?variant=blend&view=wide#concepts)

Server: `python design/home-lab/scripts/serve_preview.py --port 4173`, loopback only, no-store responses. Started hidden for this task and intentionally left available for review. No commit, push or native acceptance is claimed.
