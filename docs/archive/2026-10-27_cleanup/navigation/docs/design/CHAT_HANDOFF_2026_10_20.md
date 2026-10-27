> **Historical navigation copy — not active instructions.** Link destinations are rebased from `docs/design/CHAT_HANDOFF_2026_10_20.md`. Content and acceptance statements retain their original date/scope. [Immutable original](../../../docs/design/CHAT_HANDOFF_2026_10_20.md) · [Navigation index](../../../NAVIGATION.md). Original SHA-256: `388873aaee696fc69f39159ed9ea4fee262042032cc9e655091ba53c8cab6ded`.

# Culmina development context handoff — 2026-10-20

**Latest continuation:** read [Hybrid continuation](HYBRID_CONTINUATION_2026_10_20.md) first. It records the completed seven refinements, subsequent whole-app 33/40 Claude / 31/40 independent assessment, unresolved owner choices and refreshed tool audit. The remainder of this file is historical.

**Later owner-authorized work, completed 2026-10-20:** compact Home Weather, smooth Dusk/Slate/Ink sky palettes and interactive Logbook/Library/Settings now extend this historical snapshot. Start from [the current source/decision map](ANDROID_TABS_2026_10_20.md) and [integrated completion evidence](../../../../../../design/home-lab/evidence/TABS_PREVIEW.md). Claude's partial Library/Settings writes were completed and browser-verified by the parent after a session limit. The earlier A–J evidence and constraints remain preserved; do not restart those interrupted workers or the old quality brief. Native adoption remains outside this prototype request.

## Reading contract and reliability

This transfers the practical context of the design/prototype conversation. It does not authorize a new implementation task, native adoption, roadmap execution, installation, commit or publication. Read this file first, then the relevant linked evidence; do not reload all historical audits.

Labels: **Verified** = checked in accessible files/tool output during handoff; **Recorded evidence** = existing test/browser/agent artifacts inspected, not rerun now; **User requirement** = explicit owner instruction; **Established direction** = owner preference recorded in the conversation and workflow; **Proposed** = unapproved option; **Pending/Unverified** = insufficient current proof.

Workspace: `C:/Users/zalub/OneDrive/Desktop/Astro Planner/Astro-Planner`. Shell: PowerShell. Chat language: Ukrainian. Persistent project documentation: English preferred. Date: 2026-10-20, Europe/Kyiv.

The supplied handoff attachment ends abruptly at the word `If` after its reliability section. All visible sections A–J and reliability requirements are covered here; do not invent the missing ending. Source: `C:/Users/zalub/.codex/attachments/fb062b5a-fdbc-4495-8536-b07cd712827a/Pasted text.txt`.

## A. Project overview

**Verified:** Culmina, formerly AstroPlan/Astro Planner, is a planning-first astrophotography organizer. Users choose a site, target and rig, construct a Capture Plan, understand integration/acquisition time, storage and opportunity fit, save it, then record results and organize equipment/history. Weather and Moon support planning. It is not a planetarium or a camera/telescope controller.

Two distinct work streams must not be conflated:

1. Production Flutter/Dart application under `lib/`, with its own approved finite roadmap and acceptance gates.
2. This conversation's isolated Android-format browser prototype under `design/home-lab/`, plus reusable design skills and research. The owner explicitly selected **Android prototype in the browser**, not implementation in Flutter.

**Verified stack:** `pubspec.yaml`: package `astroplan`, version `1.0.0+1`, Dart SDK constraint `^3.13.3`; Provider `^6.1.5+1`, go_router `^18.0.1`, Drift `^2.35.0`, timezone `^0.11.1`, HTTP `^1.6.0`, plus local preferences, geolocation/maps, sharing, archive/file tools. These are manifest constraints, not a new runtime/version check. Native database `AppDatabase.schemaVersion` is 26. No database was opened or reset for the handoff.

**User requirement:** finish existing functionality and clarify it; avoid speculative scope growth. Core planning/equipment/targets/history work offline. Unknown data must stay unknown; explicit units, provenance and correct night/time semantics matter.

## B. Requirements and product logic

**Verified in prototype source and recorded evidence:**

- Home: concept comparisons, plan summary, conditions/night/Moon/weather, candidate entry and navigation into Plan/Night/Moon/Weather. Lab controls are outside the phone.
- Plan: selected site/night/target/rig; camera-class-specific capture blocks; exposure/count/filter, supported sensitivity/WB/AF-MF fields; calibration proposals; estimates; details; persistent main Save; guarded draft/copy/adoption, failed-save/retry and Undo examples.
- Block editor: separate Android phone screen, Cancel and one Apply. Apply edits the working plan; main Save persists it. Do not merge these two operations.
- Night/Moon/Weather: viewed night is distinct from the active plan night. Browsing or opening a URL must not silently mutate saved plan context. Time cursor/calendar, conditional summaries and sample forecasts are fixtures, not live services.
- Target search: six explicitly identified objects from the real 164-object bundled catalogue, with designation/alias/prefix/name matching; no claim to a complete search backend. Typing a query neither selects a target nor dirties the plan.
- Rig: show only recorded equipment properties with provenance; absent fields say Not recorded. No guessed DSLR sensor/optics properties.
- WB: Auto, Daylight/Cloudy/Shade/Tungsten/Fluorescent/Flash, Kelvin, Custom. Numeric Kelvin/applicable tint are near Mode; Kelvin 1000–40000 and tint ±1000 are model sanity limits, not device capability limits. Custom is measured camera WB, not a Kelvin synonym. Offer editing only where the model supports it; preserve hidden legacy values and show them read-only where appropriate.
- AF/MF is descriptive recording. The model has no numeric lens-position or camera-control API. A graduated manual-focus slider would invent unsupported precision.
- Newly added Light/Flat filter fields start empty with a distinct placeholder. Preserve legitimately recorded existing filter values.
- Separate integration time, acquisition/session budget and storage; estimates retain explicit fixture assumptions. Comparable stacking groups must not be merged across incompatible settings/unknown sensitivity.

**Verified contract decisions recorded in source maps:** fixed 24 UTC-hour `SessionNight`, including DST; five-minute cursor and exclusive end; local labels keep dates/offsets. Weather coverage counts eligible hourly sample instants, not overlap-weighted elapsed time. Preceding-hour gust/precipitation has a separate overlap rule. Missing cloud is not clear sky; missing visibility is not zero. Do not infer seeing/transparency or a universal observing score.

Production feature inventory is broader than this lab (Library, Logbook/results, backup/export, Settings, metadata). Inspect `docs/FEATURE_STATUS.md`, current roadmap criteria and relevant implementations before changing them. The handoff does not certify all production functionality or authorize missing-feature expansion.

## C. Design decisions and approved direction

**User requirements / established direction:**

- Calm, restrained colour inspired by Notion and Google; preserve Hybrid Notion + Journal. Serif character is used selectively for the night heading, with readable functional body/data text.
- The example must strictly look and behave like an Android application. Browser hosting is delivery infrastructure, not a web-product design. Preserve one-column phone composition, Android app bars/navigation, independent scrolling content and reachable persistent actions; desktop lab controls may wrap outside the phone.
- Existing app is the **functional reference**. Do not copy its visual weaknesses or substitute an unrelated website/dashboard. Android conventions take precedence over Apple desktop/iOS-specific patterns.
- Remove borders/shadows/contrasting card fill from Hybrid Your plan summaries; use open spacing/grouping.
- Preserve all earlier research when adding sources. New Apple/Fluent/Spectrum references supplement rather than replace video/Notion/Google and other studied sources.
- Reusable design skills: Tokens, Components, Typography, Spacing & Shape, Rules & Technical Debt. Token roles require usage descriptions and light/dark/field mappings. Components are grouped by forms/navigation/data display. Examples in video notes are references, not binding product rules or invented debt exemptions.

**Verified prototype choices:** default Hybrid family includes original Hybrid plus Page/Soft/Desk; earlier concepts remain reachable (ten total recorded). Eleven locally licensed font candidates/specimens include Inter, Roboto, Source Serif 4, Manrope, IBM Plex Sans, Open Sans, Noto Sans, Source Sans 3, Geist, Onest and Golos Text. Font selectors/examples are comparisons, not an approved production-font migration. No proprietary SF Pro download or brand asset copying.

**Implemented recommendation, not native adoption:** returning users with a plan get the plan-first browser recommendation; a conditions-first comparison remains. The owner's question about plan before weather was not authorization to silently reorder Flutter Home. Production F17 order remains separately governed.

**Proposed/reviewable:** gain graph A time curve is the prototype default (`sqrt(T/T_plan)`, plan=1.00x); B compares `sqrt(N)` against each group's own frame; C shows cumulative block steps within a comparable group. `plan.html?gain=all` compares them. None predicts absolute SNR/image quality or makes cross-filter signal comparable. No production variant acceptance is implied.

## D. Architecture and implementation map

**Verified production structure:** `lib/core`, `lib/domain`, `lib/data`, `lib/presentation`; presentation → ViewModels → repositories → data/services. Existing state management is Provider, not Riverpod. Scientific logic remains independent of Flutter.

Key source paths:

- `lib/presentation/navigation/app_router.dart`: `AppRouter`, go_router routes, planner and selector/editor routes, conditions, welcome, results.
- `lib/presentation/navigation/app_shell.dart`: `AppShell`, Tonight/Logbook/Library/Settings tab shell.
- `lib/presentation/screens/tonight/tonight_home_screen.dart`: production Home functional reference.
- `lib/data/database/app_database.dart`: Drift schema and open/migration protections; schema version 26.
- `lib/domain/services/target_search.dart`: actual search matching contract.
- Capture evidence, block dialog, equipment seeder, SessionNight/resolver, weather summarizer and stacking-gain model: exact links/contracts are in [planning source map](PLANNING_SCREENS_2026_10_19.md) and [quality decisions](QUALITY_REFINEMENT_2026_10_20.md). Follow those references rather than guessing basenames/paths.

Browser files under `design/home-lab/`:

| Files | Responsibility |
| --- | --- |
| `index.html`, `app.js`, `styles.css` | Home concepts, lab controls, navigation and fixtures |
| `plan.html`, `plan.js`, `plan.css` | Plan/editor rendering, interaction and Android layout |
| `plan-model.js` | Plan/sample catalogue, parsing, validation, compatible groups, budget/gain and storage helpers |
| `conditions.html`, `conditions.js`, `conditions.css` | Night/Moon/Weather screens |
| `night-model.js`, `night-ui.js`, `night.css` | Shared viewed-night/cursor/calendar/weather/time-lane model and UI |
| `tokens.json`, `catalog.js`, `catalog.css`, `inventory.json` | Semantic roles, design-code catalogue and dated production-source snapshot |
| `fonts/`, `references.json` | Local licensed fonts and reference interpretation/provenance |
| `scripts/check_plan.mjs`, `check_night.mjs`, `check_quality.mjs` | Model/contract tests |
| `scripts/build_inventory.py`, `check_inventory.py` | Explicit snapshot regeneration and freshness checks |
| `scripts/serve_preview.py` | Loopback static server with no-store cache policy |

Browser localStorage is separate from Drift/application data. `planStorageKey` is `culmina-plan-preview-v1`; do not clear it casually. `localhost:4173` and `127.0.0.1:4173` have separate browser storage; use localhost for isolated tests and preserve the owner's 127.0.0.1 checkpoint.

**Recorded implementation detail:** quality entrypoints/imports use asset revision `20261020-quality2`; stale browser modules caused misleading initial checks after the interruption. Confirm current assets before diagnosing already-fixed behavior. The custom server sends `Cache-Control: no-store`.

## E. Development history and completed work

| Milestone | Actual outcome / evidence |
| --- | --- |
| Video-guided design foundation | Five project skills, token descriptions, grouped component contracts, font specimens and isolated Home lab. [Workflow](../../../../../design/WORKFLOW.md), [video audit](VIDEO_GUIDANCE_AUDIT_2026_10_19.md) |
| Additional reference research | Notion/Google plus Linear/Things/Craft, then Notion/Apple study, official Apple HIG/Fluent2/Spectrum brief. [Reference research](../../../../../design/REFERENCE_RESEARCH.md), [study](NOTION_APPLE_STUDY_2026_10_19.md) |
| Hybrid refinement | Page/Soft/Desk, semantic token/spacing/radius application, source inventory, an isolated native skill application test. Existing test evidence is recorded, not rerun here. [Hybrid evidence](../../../../../../design/home-lab/evidence/HYBRID_REFINEMENT.md) |
| Plan page and priority review | Open Your plan presentation, plan-first comparison, separate editable Plan. [Review](PLAN_CONCEPT_REVIEW_2026_10_19.md), [Plan evidence](../../../../../../design/home-lab/evidence/PLAN_PREVIEW.md) |
| Android correction | Replaced web-like Plan composition with phone viewport, Android shell, separate editor and persistent actions. [Android evidence](../../../../../../design/home-lab/evidence/ANDROID_PREVIEW.md) |
| Complete planning prototype | Plan/Night/Moon/Weather and shared viewed-night flows; five successful CLI contributions reconciled with real source contracts. Recorded 60 model tests and 60 layout cases at that milestone. [P01–P12 evidence](../../../../../../design/home-lab/evidence/PLANNING_SCREENS.md) |
| Owner quality refinement | Smooth shared sky ramp, solid Moon lanes, better grouping/weather/fact grids, Moon focus, target search, truthful rig/WB/filter fields and three gain graphs. [Quality decisions](QUALITY_REFINEMENT_2026_10_20.md), [colour guidance](QUALITY_COLOR_GUIDANCE_2026_10_20.md) |
| Interruption recovery | Sonnet completed Home/conditions; Opus's partial Plan run and another review attempt hit limits. Parent completed integration. After renewed limits, fresh Opus read-only review completed. Failed attempts remain labelled failed/partial. [Current evidence](../../../../../../design/home-lab/evidence/QUALITY_REFINEMENT.md) |
| Review repairs | Stable target input preserves middle typing; Enter cannot apply old target; Astro shows kept WB/MF read-only; Moon disclosure stays open through rerender/text scale. Source review and browser evidence are distinct |
| Tool inventory | 8 enabled Claude plugins, 19 enabled Codex plugins, Graphify verified in Codex, successful Claude `engineering:documentation` Skill invocation; runtime/access caveats documented. [Capabilities](../AI_TOOL_CAPABILITIES_2026_10_20.md) |

**Recorded latest prototype evidence:** 72 model tests passed, 0 failed in `design/home-lab/evidence/quality-review-2026-10-20/model-tests.txt`; 48 conditions/Plan layout cases plus 12 Home cases, three themes, 100/200% text and phone/desktop host viewports. Current-asset matrix and interactions: `browser-evidence.json` in that directory. See current quality completion evidence for exact accepted cases, screenshots, source hashes and limitations. These tests were **not rerun for the documentation-only handoff**.

## F. Current issues and outstanding tasks

- **Verified now:** `http://127.0.0.1:4173/plan.html` refused connection during handoff. No server was started because this request is context transfer only. On a subsequent preview task, start the no-cache server using the command in J; do not assume the earlier PID/server is alive.
- **Pending owner review:** visual acceptance of the refined Android prototype and choice among optional graph/font/concept comparisons. Do not treat defaults as final production selection.
- **Unverified:** actual Android IME, TalkBack, predictive Back, native gestures/insets/device performance, live weather/ephemeris/provider/cache correctness. Browser measurements do not close these rows.
- **Known limits:** target catalogue is a six-item sample, forecasts/astronomy are labelled fixtures, rig optics may be illustrative, not real measurements. Do not silently turn these into backend integration work.
- **Access/tool blockers:** Claude Graphify needs authentication; Dart MCP fails `CONNECTION_CLOSED`; Context7 worked here in Codex but was not exposed to the tested Claude worker. Figma plugin enabled status is not authenticated file access.
- **Native roadmap:** separate existing attention rows remain. Read latest PROGRESS and review evidence for current F10/F22/F23/F25/G1/G2+ dispositions; do not transfer old environment limitations as freshly verified machine facts. Owner visual acceptance, physical/device evidence, external import/provider/CI/release rows are not closed by this lab.
- No currently interrupted prototype code-writing task remains identified in current completion evidence. Do not restart the completed quality brief automatically. Most useful next step is owner review/selection; implement only the next explicit bounded request.

## G. Decisions, rationale and corrected alternatives

- Browser Android prototype, not Flutter or desktop web: explicit owner clarification corrected earlier web-like Plan.
- Keep existing app's functional contracts while refining its visual presentation: prevents fictitious capabilities.
- No numeric MF slider: model only records AF/MF. Preserve the intent of improving focus clarity without inventing control.
- No elapsed overlap-weighted weather coverage and no 25-hour civil-noon night: proposals contradicted actual sample-count and fixed-24-UTC contracts; source reconciliation prevailed.
- Actual clock for Now/retrieval age, with five-minute snapping; fixture timestamp is not current time. Historical/future nights use Night start.
- One Apply inside editor; main Plan owns Save. Duplicate disabled Save in the editor was removed.
- New filters empty; demonstration records may legitimately contain values. Preserve existing data rather than blanket-clearing it.
- Graph default A serves planning time allocation; B/C remain comparison options. No claim that the owner selected A for production.
- Generic plugin recipes do not authorize Riverpod migration, new debt exemptions, forced tests on trivial changes or automatic commit/publish.

## H. Research sources and external tools

Primary context: UI Collective [Design with AI](https://www.youtube.com/watch?v=r-MPiu0E4W4), owner-supplied notes for this and a second “AI + Design Systems: The Honest Truth…” video. Do not invent a second URL. The supplied notes, not a claim of watching every video frame, underlie the recorded research.

Official/reference links and interpretation are preserved in [WORKFLOW](../../../../../design/WORKFLOW.md), [REFERENCE_RESEARCH](../../../../../design/REFERENCE_RESEARCH.md), [NOTION_APPLE_STUDY](NOTION_APPLE_STUDY_2026_10_19.md), [DESIGN_SYSTEM_RESEARCH_BRIEF](../../../../../design/DESIGN_SYSTEM_RESEARCH_BRIEF.md) and `design/home-lab/references.json`. References include Notion/Notion Calendar, Material3 typography/components, Apple HIG, Fluent2 and Adobe Spectrum, plus Linear/Things/Craft. These supplement each other and do not replace Android platform conventions. The quality review also references Nikon's focus-ring/indicator behavior and W3C complex-chart guidance; follow links in the quality decisions.

Original owner attachment locations, for provenance or exact wording when the repository copy is insufficient:

| Attachment ID under `C:/Users/zalub/.codex/attachments/` | Content (`Pasted text.txt`) |
| --- | --- |
| `474d3710-4009-423b-a5d6-5774218d7ffa` | Initial video context |
| `081ac361-dffc-4d42-bf3c-92404cbe58f9` | Additional AI/design-systems context |
| `8707aef8-c6d9-494d-b6a5-5803d4efc9bd` | Apple/Fluent/Spectrum research brief |
| `afd129ab-586d-47b0-a6e6-b736e299d7dc` | Functional reference and tool orchestration |
| `ab59de2e-fcea-4b93-b00f-25ea7511b0c3` | Quality brief; durable copy at `design/home-lab/evidence/ai/quality-owner-brief.md` |

**Tools actually used:** Claude CLI research/implementation/testing/review runs (individual JSON reports in lab evidence/ai); Codex/browser checks; Context7 official Claude CLI documentation; Graphify repository listing in Codex; local inventories/manifests. Latest CLI skill probe succeeded with `engineering:documentation`, five turns, no permission denials. These are not evidence that every installed skill/tool works.

**Routing:** Culmina design skills first; one applicable Impeccable source for UI; focused Claude Design/Engineering review or compatible Audit Suite lens; local source/tests for truth; Graphify via Codex for indexed dependencies; Context7 resolve then query for current library/API/CLI docs, official sources as fallback; Firecrawl for relevant primary-source research. Use the [capability report](../AI_TOOL_CAPABILITIES_2026_10_20.md) for versions, duplicate names and exact access limitations.

**User preference:** use Claude/Antigravity/subagents when available limits and task size make delegation worthwhile; explicit earlier request emphasized CLI subagents to conserve chat limits. Do not delegate trivial work or duplicate audits merely to demonstrate usage. Gemini/Antigravity executables were not found on PATH in the inventory; desktop presence was not established. Claude Desktop was discussed, not demonstrated as a working automation channel.

## I. Working conventions and collaboration

- Continue with independent judgment inside the owner's scope; avoid unnecessary confirmations, unsupported assumptions and speculative expansion.
- Preserve earlier references and decisions across chats. Assess real implementation/models before designing controls. Report recommendation versus owner decision explicitly.
- Delegate bounded independent work with exact files, allowed writes, constraints, acceptance criteria and report format; inspect results and run appropriate checks. Do not call a limit-interrupted worker successful.
- When restricting Claude tools, allow `Skill` if skill invocation is needed; agent delegation tools only when nested delegation is intended. Fully qualify duplicate skill names. Installed/enabled does not mean loaded/authenticated/callable.
- Read selected skill instructions before using them. Do not blindly stack overlapping Superpowers/Engineering/full-audit workflows. Audit Suite React/Zustand/Tauri/Rust assumptions do not apply to Culmina automatically.
- Task Observer may propose improvements; no automatic memory/global-instruction/skill changes. Read-only workers must be told not to write observations or memory. Superpowers session hooks do not override the owner's task.
- Product authority: current owner scope → `CLAUDE.md`/current `PROGRESS.md` and approved decisions/roadmap → relevant rules → actual source/evidence. Source shows behavior; decisions define intended behavior. Record discrepancies instead of rewriting intent.
- Relevant rules under `.agents/rules/`; design skills under `.agents/skills/culmina-design-{rules,tokens,components,typography,spacing}/SKILL.md`. Hosts may need explicit file reads.
- Verification is proportional under CLAUDE.md canonical policy. Docs-only: resolve links/IDs, consistency, whitespace; no Flutter suite/analyzer/build needed. Prototype changes: relevant JS/model, interaction, layout and source-inventory checks. Native adoption follows its own task and actual widget/device criteria.
- Preserve local user data and all existing dirty/untracked files. No reset, cleanup, blanket storage reset, signing-secret access, new deployment or native implementation during context transfer.

## J. Current state and next allowed action

**Verified checkout:** branch `develop`, HEAD `8048cfa` (`docs: G1 gate on the re-audited code; PROGRESS records the re-audit`). The whole lab/design documentation and five design skills are untracked at handoff time. Modified tracked files include `.agents/skills/README.md`, `CLAUDE.md`, `docs/README.md`; other pre-existing untracked items include `.impeccable/`, refinement review/evidence files, `test/presentation/design_system/skill_application_test.dart` and `tool/__pycache__/`. No commit/reset/stash/push was made. Do not accidentally stage/delete unrelated material.

**Production status caution:** current PROGRESS says the F01–F26/G1–G4 roadmap was approved 2026-10-18 and launched; later ledger/pass-checkpoint rows record implemented work and remaining attention. Older “no F task started” lines in the same file are historical, not current state. Existing memory saying the roadmap is merely proposed is stale. Use current ledger and evidence before naming a native next task; this handoff does not launch that queue.

**Last completed task before handoff:** tool/skill/plugin inventory and routing report, including a successful read-only Claude Skill invocation. Latest prototype work was quality refinement with the recorded 72-test/current-asset browser evidence above.

**New chat initial action:** read this handoff, the capability report, current quality decisions/evidence and relevant CLAUDE scope. Briefly acknowledge actual status and wait for the owner's next bounded request. Do not restart an old audit, repeat completed tests, choose a production design, or begin implementation just because a handoff lists pending work.

For a subsequently authorized preview task, verify the port first; then, if needed, start a hidden independent server from the repository (PowerShell Start-Process must use `-WindowStyle Hidden`):

```powershell
python design/home-lab/scripts/serve_preview.py --port 4173
```

Useful preview URLs once serving:

- `http://127.0.0.1:4173/index.html?theme=light&scale=1&font=native&variant=blend&view=wide#concepts`
- `http://127.0.0.1:4173/plan.html?variant=blend&theme=light&scale=1`
- `http://127.0.0.1:4173/plan.html?gain=all`

Conditions links should be followed from Home/Plan to preserve the app's explicit viewed-night context. Prefer the custom no-cache server over the old `python -m http.server` command still present in historical readmes. Do not open/reset production databases to inspect this browser-only lab.

**Handoff verification:** current files, branch/status, source maps, manifests, persisted evidence and port response were inspected. No application code, token/design decision or configuration was changed, and no implementation/test suite was started for this transfer. The sole new repository artifact is this handoff document.
