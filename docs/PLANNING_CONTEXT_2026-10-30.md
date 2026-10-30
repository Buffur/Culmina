# Culmina planning agent context

Prepared on 30 October 2026 for an agent that will plan subsequent work after inspecting the repository, external LLM UI references and existing Figma screens. The requested outcome is a plan; this handoff does not select a redesign or authorize implementing an experimental Figma variant.

## Workspace and current baseline

- Repository: `C:\Users\zalub\OneDrive\Desktop\Astro Planner\Astro-Planner`.
- Branch: `develop`.
- Inspected HEAD: `55d07528d4e6107bcd504bef632a869f2a85c434`.
- Working tree was clean before this analysis. This document is the only intended tracked addition; machine-local verification is under `build/planning-context-20261030/evidence.json`.
- Product name: Culmina; Dart package: `astroplan`; declared version: `1.0.0+2`; Dart constraint: `^3.13.3`. These are source declarations, not a check of the installed SDK.
- Android is the primary target. The product plans astrophotography and records results; it does not control acquisition hardware.

Read [AGENTS.md](../AGENTS.md) first. The five `.agents/skills/culmina-design-*` skills own project UI guidance. External reference apps and Figma experiments do not replace them. Use Context7 for an actual library/SDK/API question; a source inventory alone does not require external API documentation.

## Repository structure and source ownership

| Area | Owning paths and purpose |
| --- | --- |
| Composition | `lib/main.dart` initializes persistence/catalogs and composes dependencies; `lib/presentation/app_view_models.dart` supplies injected services and ViewModels. |
| Navigation | `lib/presentation/navigation/app_router.dart`, `app_shell.dart`: Tonight, Logbook, Library, Settings; Plan and detail/chooser flows open above the shell. |
| UI | `lib/presentation/screens/`, `shared/`, `widgets/`: actual screen composition, controls and scientific displays. |
| State | `lib/presentation/viewmodels/`: selected site/night/target/rig, working plan, saved lifecycle, forecast, analysis and recorded results. |
| Domain | `lib/domain/models/`, `repositories/`, `services/`: night identity, astronomical conditions, capture blocks, fit, budgets, storage and persistence contracts. |
| Data | `lib/data/`: Drift repositories, preferences, weather/platform adapters, backup and export. `lib/data/database/app_database.dart` currently declares schema 27. |
| Design implementation | `lib/core/theme/`: semantic palettes, Geist typography, spacing, radii, motion and buttons. Field Red also uses the root `ColorFiltered` in `lib/main.dart`. |
| Tests | `test/`, especially `test/presentation/`, plus `test/support/`; host/device flows are separated in `integration_test/` and `test_driver/`. |
| Tooling | `tool/check.dart`, `tool/check_instructions.py`, `tool/ci.py`, `.github/workflows/ci.yml`; old comparison utilities remain under `tool/design/`. |
| Supporting documentation | [Architecture](ARCHITECTURE.md), [product specification](PRODUCT_SPEC.md), [design system](DESIGN_SYSTEM.md), [agent tooling](AGENT_TOOLING.md). Verify behavior from callers/tests. |

### Screens most relevant to the existing Figma experiments

| Screen or concern | Source and state owners |
| --- | --- |
| Tonight | `lib/presentation/screens/tonight/tonight_home_screen.dart`; `TonightViewModel`, `StartupViewModel`, `SessionPlanViewModel`, `SiteViewModel`, `NightConditionsViewModel`, `CaptureAnalysisViewModel`. The current source branches between bootstrap error, loading, no-site and selected-site content. |
| Plan | `lib/presentation/screens/home/session_planner_route.dart` wraps `home_screen.dart`. The class named `HomeScreen` is the Plan UI, not the Tonight tab. Preserve router/lifecycle draft guards. |
| Capture Plan section | `lib/presentation/widgets/capture_plan_widget.dart`, `widgets/capture_plan/`, `widgets/planner_sections.dart`, `widgets/plan_status.dart`; `SessionPlanViewModel` and `CaptureAnalysisViewModel`. |
| Night, Moon, Weather | `lib/presentation/screens/details/night_moon_screen.dart`; `weather_detail_screen.dart` opens that shared browser with `initialPage: 2`. Night browsing is separate from changing the active plan. |
| Saved records and results | `screens/logbook/`, `screens/execution/results_screen.dart`; `SessionsViewModel`, `ResultsViewModel`, `PlanLifecycleViewModel`. |
| Library | `screens/library/`, `equipment/`, `target/`, `sites/`; chooser/manage intent and identity matter. |
| Shared presentation | `shared/document_section.dart`, `hybrid_parts.dart`, `context_line.dart`, `site_label.dart`, `plan_state.dart`, `plan_night_phrase.dart`, `night_time_formatter.dart`. Inspect real adopters before reusing a component. |

Plan source currently groups identity, fit status, site/night/target/rig inputs, Capture Plan and supporting analysis/conditions. Save plan remains an explicit persistence action. Retain original sections, values, states and actions when evaluating a visual refinement.

## Located LLM UI references

No directory literally named `LLM-Refrences` or `LLM-References` was found in the repository or the inspected Codex visualization tree. The matching existing collection is outside Git at:

```text
C:\Users\zalub\.codex\visualizations\2026\10\29\01a18540-fc19-7d30-a78c-581e611ffa11\android-ui-atlas
```

Call this directory `REFERENCE_ROOT` below. It is a machine-local dependency: do not assume another agent or machine has it, and do not silently copy or relocate the collection. Its `llm_ready_index.html` is the collection entry point; the previously used `http://127.0.0.1:8766/llm_ready_index.html` is a historical serving address, not a currently verified running server.

### Inventory from the current collection manifest

Pack paths are `REFERENCE_ROOT/ui_atlas/<package>/llm_ready/`.

| App | Package | Original states | Representatives | Clusters |
| --- | --- | ---: | ---: | ---: |
| Claude | `com.anthropic.claude` | 35 | 32 | 7 |
| Notion Calendar | `com.cron.calendar` | 21 | 18 | 5 |
| GitHub | `com.github.android` | 25 | 23 | 6 |
| Good To Stargaze | `com.goodtostargaze` | 39 | 35 | 8 |
| To Do | `com.microsoft.todos` | 39 | 31 | 8 |
| Weather | `com.miui.weather2` | 25 | 24 | 7 |
| Stargazing Hub | `com.twtapp` | 44 | 29 | 7 |
| Mi Fitness | `com.xiaomi.wearable` | 37 | 33 | 8 |
| School Planner | `daldev.android.gradehelper` | 31 | 28 | 7 |
| Obsidian | `md.obsidian` | 47 | 36 | 8 |
| Notion | `notion.id` | 44 | 29 | 7 |

The saved inventory totals 387 original states, 318 representatives and 78 clusters. Prefer these current manifest totals over earlier conversational counts.

### Reading order and related files

1. Read `REFERENCE_ROOT/README.md`, `QA_SUMMARY.md` and the selected pack's `START_HERE.md` and `AI_DESIGN_SPEC.md`.
2. Inspect `00_navigation_overview.png` where present, then full-resolution `cluster_*.png`, `00_ui_kit_anatomy.png` and native detail panels. Notion has its own three detail panels and does not use exactly the same file set as the other ten packs.
3. Use `selection_manifest.json` to map representative IDs to original states and aliases; use `component_measurements.json`, `color_palette.json`, `detail_panels.json` and `navigation_semantics.json` for qualified evidence.
4. `navigation.json` and `OBSERVED_WALK.md` describe recorded steps. They are not an exhaustive route model. A screen index is not necessarily a route or tab.
5. Read per-pack `QA_REVIEW.md` and, for the ten reviewed remaining packs, `QA_REVIEW.json` and `reviewed_artifact_hashes.json`. `source_integrity.json` and `artifact_audit.json` supply provenance and generated-pixel checks.
6. For original evidence, move one level up to `manifest.json`, `screens/*.png`, `hierarchies/<state>/window_dump.xml` and `layout.json`. The raw `index.html`, `master_atlas_board.png` and `design_system_summary.json` are earlier views of those captures, not substitutes for the reviewed interpretation.

Related collection tooling: `llm_postprocess.py`, `notion_reference.py`, `reviewed_reference.py`, `reviewed_profiles.json`, `verify_reviewed_rest.py`, `test_llm_postprocess.py`, `test_reviewed_reference.py`, `build/remaining_qa_revision/verification.json`. Capture tools such as `atlas_raw.py` and `collect_steps.py` exist, but no new device traversal is needed to consume the references. `verify_reviewed_rest.py` rewrites its saved verification JSON; do not run it merely to read historical evidence.

### How the references can inform planning

The UI Lab names an existing `Notion + Calendar` direction. The Notion anatomy sheet visually confirms restrained dark surfaces, grouped rows, disclosure, search/filter controls and compact action treatments. The Calendar overview demonstrates one/three-day structures, time rails and explicit empty-grid states. These can inform a scoped comparison; they do not establish Culmina requirements.

For potential weather/time presentation questions, the planner can inspect Stargazing Hub, Good To Stargaze and Weather. For lists, settings and progressive disclosure, the other packs offer additional observed examples. These are candidate uses, not a decision to combine styles or import whole navigation systems.

Important evidence limits:

- Pixel samples and XML rectangles are observations, not recovered source tokens, padding/margins or exact typography.
- School Planner is explicitly partial. Obsidian's captured empty vault does not demonstrate populated note editing. Empty calendar/timetable states do not prove event behavior.
- Stargazing Hub is `com.twtapp`; Good To Stargaze is a separate additional app.
- Deduplication preserves the originals; aliases are not permission to collapse meaningful modes or checked/selected states.
- Alternate themes and full navigation are not established just because one capture exists.
- The historical QA report records scoped full-initial/focused-final reviews, 13 tests and browser image checks. Those were not repeated as new visual acceptance during this analysis.

Current read-only SHA-256 checks matched all 1,247 protected inputs, including the preserved Notion output set, and all 251 files listed in the ten reviewed-output receipts. No reference regeneration or ADB capture occurred. The evidence JSON under `build/planning-context-20261030/` records this check.

## Figma file and live inspection

[Culmina current app screens](https://www.figma.com/design/OeDvjQ58cWoHOCSMd69GCG) is the active file; file key `OeDvjQ58cWoHOCSMd69GCG`. Browser authorization and editor access were available during inspection. The authenticated main team has a Full seat on Starter. Figma MCP identity/session calls worked, but `get_metadata` returned the Starter tool-call limit; use the browser for the currently available inspection route. Do not infer unavailable MCP read/write capability from successful login alone.

### Observed page structure

| Page | Observed role and entry point |
| --- | --- |
| Light current screens | Source-transfer scenarios; page `0:1`. Sample selected: `001 · home_blocks_source · Light · Longread`, [node 12:408668](https://www.figma.com/design/OeDvjQ58cWoHOCSMd69GCG?node-id=12-408668). |
| Dark current screens | Matching theme scenarios; page `3:2`. Sample selected: `001 · home_blocks_source · Dark · Longread`, [node 12:533069](https://www.figma.com/design/OeDvjQ58cWoHOCSMd69GCG?node-id=12-533069). |
| Field Red current screens | Field scenarios; page `3:3`; frame names use `Field`. Sample selected: [node 12:657470](https://www.figma.com/design/OeDvjQ58cWoHOCSMd69GCG?node-id=12-657470). |
| UI Lab Before and After | Experimental comparison page `22:242`, separate from the three source-transfer pages. |

The three selected source frames were visually inspected alongside their neighboring Tonight, Plan and Night longreads. They retain corresponding structure across Light, Dark and Field Red. The layer lists also expose named picker, plan-block, site-edit and saved-entry variants. This is sampled inspection, not a fresh audit/count of every live frame.

### UI Lab inventory and inspected screens

For each of Tonight, Capture Plan and Weather, the page contains `[BEFORE]`, `[CHECKLIST]`, `[AFTER] ... Notion + Calendar`, `[AFTER · QA FIX]` and `[VIEWPORT · QA FIX]` entries, plus `[00] Dark Design System Board`.

| Visually inspected viewport | Node | Observed content |
| --- | --- | --- |
| Tonight | [27:4471](https://www.figma.com/design/OeDvjQ58cWoHOCSMd69GCG?node-id=27-4471) | Night/date/site context; Your plan with saved state and fit information; Open planner; night summary/time preview; bottom navigation. |
| Capture Plan | [27:4610](https://www.figma.com/design/OeDvjQ58cWoHOCSMd69GCG?node-id=27-4610) | Plan title/date and saved state; fit/time explanation; site/night/target/rig rows; visible bottom Save plan action. Capture blocks continue below the viewport in the associated longread. |
| Weather | [27:4778](https://www.figma.com/design/OeDvjQ58cWoHOCSMd69GCG?node-id=27-4778) | Night/Moon/Weather tabs; site/night browser; cloud summary, coverage and updated-time text; Refresh forecast; appearance setting link; dark-time statistics. |

The earlier `[AFTER] Weather · Notion + Calendar` selection is [22:3824](https://www.figma.com/design/OeDvjQ58cWoHOCSMd69GCG?node-id=22-3824). The browser exposed editable frame properties, vertical auto layout and a `Canvas Bg` variable on that frame. This does not establish complete variable/component consistency across the file.

The viewport experiments emphasize the first screenful, grouped surfaces and action reachability. Any benefit beyond these visible properties remains a planning hypothesis. No owner acceptance, prototype interaction coverage, native accessibility result or production adoption is established by the names `AFTER`, `QA FIX` or a checklist. No Figma content was edited during this analysis; only page/selection/zoom/UI visibility changed.

## Repository artifacts related to Figma

Start with [design/reference/README.md](../design/reference/README.md) and [the consolidated reference entry point](../design/reference/index.html).

- `design/reference/design-rules-web/`: browser specimens, extracted catalog and copied source snapshots; inspect current implementation separately.
- `design/reference/app-map-20261028/`: source-linked application map and refreshed captures. Its manifest records historical HEAD `0e2130238f6d241cec270f65ff030d2ea67cf73f`, 63 captures, 42 nodes and 73 edges; it is not a live router scan.
- `design/reference/atlas/`: historical 40-frame atlas. Preserve captured-state and source provenance.
- `design/reference/figma-transfer-20261029/`: `.fig` backup, README, `verification.json`, `visual-verification.json`, `provenance.json`, `archive.json` and Plan/Weather/Rig comparison images.
- `docs/archive/2026-10-29_figma-transfer/`: ignored local intermediate/archive evidence; `archive.json` points to the complete retained file manifest. `build/figma-transfer-20261029/local-plugin/` is the recorded registered read-only plugin location, not a newly tested connection.

The transfer README records 576 editable application frames across three themes, including 300 Longreads, representing 28 concrete screen types. Those are saved transfer counts, not freshly recounted live Figma totals. The UI Lab exists separately and must not be assumed to be included in that backup or its parity evidence.

The transfer's source baseline is a working tree based on `e631de00b58a65b830023dd63f33a883abca4300`, including then-local changes and synthetic in-memory fixtures. Figma does not execute application calculations, persistence, arbitrary form input, forecast retrieval, native pickers or sharing.

### Verified source drift since transfer

Of 383 source files listed in transfer `provenance.json`, 380 currently match their saved SHA-256 and three differ:

- `lib/presentation/screens/home/home_screen.dart`;
- `test/presentation/screens/home/plan_identity_actions_test.dart`;
- `test/presentation/shared/plan_fact_layout_test.dart`.

Recent commits affecting these paths include `02ffa8c2` (planner context/identity layout), `45f28a8b` (identity date wrapping), `2fe6c96c` (test fixture encoding) and `55d07528` (date reflow assertion). Reconcile current Plan identity/context behavior before treating transferred frames as current implementation targets. Matching hashes prove file identity for the recorded set, not complete live Figma parity.

Some current source comments still mention old `docs/DECISIONS.md` and `docs/IA_WIREFRAMES.md` paths. Those files are now under `docs/archive/`; a comment pointing to an old location is not a current task or a reason to restore archived policy.

## Constraints the subsequent plan must preserve

- Preserve original blocks, information, actions, missing/error/loading states and object identity unless a specific change is requested.
- Separate fit verdict, working draft, explicit Save plan, saved record and reported acquisition result. Keep Back/Save/Discard/Cancel behavior and failure recovery.
- Unknown remains unknown. Keep units, provenance, forecast freshness/cache/failure distinctions and theoretical versus measured storage estimates.
- Relative stacking gain is not absolute SNR. AF/MF and white balance are descriptive. Do not invent sensor values or a quality score.
- SessionNight uses a 24-hour UTC window from site mean solar noon. Preserve site-zone/DST display and evening-date identity. A placeholder location is not a selected site.
- Keep offline catalogs, local plans/calculations/Logbook, migration and backup compatibility. Weather/maps/optional place-name lookup retain their network/consent boundaries.
- Preserve Light, Dark and Field Red, root field filtering, Geist roles, reachable labeled actions and text growth. References do not authorize a global palette, typography or navigation replacement.

## What the planning agent should produce

Use this context to propose a bounded next task rather than treating every historical artifact as a backlog. First establish the intended outcome: Figma-only refinement, reconciliation of design with source, or implementation of an explicitly selected direction. The current request establishes analysis and planning context, not that product decision.

The plan should identify:

1. The user problem, observable benefit and proposed scope; distinguish measured defects from visual hypotheses.
2. The exact baseline and candidate Figma nodes, relevant reference-pack states/components, current source callers and tests.
3. Differences requiring a decision: source drift, viewport versus complete longread, information/action preservation, theme/state coverage and static prototype behavior versus real application behavior.
4. A small implementation sequence if implementation is selected, with dependencies and acceptance criteria; keep unrelated cleanup separate.
5. Verification matched to scope: paired before/after host renders in three themes, narrow-phone/text-scaling checks where relevant, focused widget/domain tests for changed behavior, and explicit device/accessibility/prototype checks when those claims are needed.

Use the existing [refinement decision record](../.agents/skills/references/refinement-decision.md) proportionately. The available render entry point is `test/presentation/design_system/concept_b_app_audit_renders_test.dart`, with fixtures in `test/support/hybrid_transfer_fixture.dart` and `hybrid_transfer_shots.dart`. Inspect supported shot names and use fresh output under `build/`; commands are in AGENTS. Historical renders do not replace a current baseline.

No Flutter tests, analyzer, APK build, Android interaction, prototype click-flow audit or accessibility audit was run for this read-only context task. Current checks covered repository/source inspection, live Figma samples, reference-file inventory and saved-hash comparisons. Do not present the handoff as release or owner acceptance.
