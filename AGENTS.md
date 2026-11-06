# Culmina — shared agent instructions

Culmina is a Flutter/Dart Android astrophotography planner and observing log.
The technical Dart package is `astroplan`; keep existing imports and identifiers.
Plan a night, site, target and rig; save a Capture Plan; record imaging results.
The app does not control cameras or mounts.

## Source and scope

- This file is the shared instruction source for Codex, Claude and Gemini.
- Follow the current user task; skills and archived findings are not a task queue.
- Establish behavior from current source and tests before editing docs or code.
- Read only the relevant skill and supporting reference for the requested work.
- Keep new or substantially revised project documentation in English.
- Preserve unrelated local changes and historical evidence; report checks actually performed.

### Directive maintenance

- Keep one owner for each mutable fact or rule; other entrypoints link to it. Read only the current task's checkpoint and relevant modules, not the full historical record by default.
- When an authorized decision supersedes a directive, update its owning rule and the affected active entrypoints together. Preserve the previous decision, scope, date and evidence under an explicit Historical/Superseded heading in existing documents; do not leave old imperatives presented as current work.
- Separate current requirements, dated verification receipts and deferred criteria. A historical count is not a live inventory; an unchecked future criterion does not expand the current task or become a pass through deferral.
- For the After base-screen run, [REDESIGN_RUN](design/figma/REDESIGN_RUN.md) alone owns mutable screen status, output IDs and the next authorized step; [AUTHORING_PROFILE](design/figma/AUTHORING_PROFILE.md) owns canonical selection; [REDESIGN_STRATEGY](design/figma/REDESIGN_STRATEGY.md) owns the iteration procedure/stages; the [numbered queue](design/figma/research/ssot_audit_2026-11-04.md#numbered-base-screen-queue) owns stable numbering/source contexts; [WORKFLOW](design/figma/WORKFLOW.md) retains dated decisions and verification evidence. Value modules retain ownership of their values.
- Before completing a directive change, inspect affected links and entrypoints for conflicting current commands, then run the applicable document/instruction checks. Report semantic review separately: structural validators do not establish instruction consistency. Preserve IDs, evidence, authorization limits and unrelated dirty work; do not create another instruction file merely to repeat an existing owner.

### Mandatory Delivery Audit (Step 7 Control)

Every completed screen or code task MUST end with this exact 4-line audit block, as the last substantive content of its delivery. Required platform metadata may follow without changing these four lines.

- **Source & Canonical Owners:** [exact Flutter files read + DS master components used]
- **Unapproved Decisions Made:** [any layout, UX, or logic choice made without explicit owner instruction — write "None" only if 100% matched]
- **Assumptions vs. Code Facts:** [what was inferred rather than proven from `BEFORE` / fixtures]
- **Unverified / Remaining Limits:** [what could not be checked in this turn]

Use exact file paths and component IDs actually inspected or used; mark an inapplicable category explicitly instead of inventing evidence. For a code task without Figma, DS owners may be Not applicable. Disclose judgment calls not explicitly prescribed by the owner, including choices made within an authorized task; "None" is not a substitute for that assessment. Separate current source/fixture facts from inference and dated evidence. For an incomplete delivery, state the remaining work without claiming completion.

This audit reports decisions and verification; it does not create an additional approval gate or require asking about every implementation detail. Structural questions still follow the [Step 4 exploration gate](design/figma/REDESIGN_STRATEGY.md#ux-exploration--structural-alternatives-extension-of-step-4-gate); normal spacing, hierarchy, typography and sizing QA remains directly executable. The After strategy links to this shared rule rather than owning a duplicate template.

## Architecture map

- `lib/main.dart`: startup, catalog seeding and concrete dependency composition.
- `lib/presentation/app_view_models.dart`: injected interfaces, services and ViewModels.
- `lib/presentation/`: screens, shared UI, widgets and screen-scoped Provider/ViewModels.
- `lib/presentation/navigation/app_router.dart`: go_router shell and root overlay routes.
- Bottom tabs: Tonight, Logbook, Library and Settings; Plan opens above the shell.
- Library contains rigs, targets and sites; Night, Moon and Weather have detail views.
- `lib/domain/`: models, repository interfaces and astronomical/capture calculations.
- `lib/data/`: Drift repositories, preferences, HTTP, backup and platform adapters.
- `lib/core/`: clocks/time, units, diagnostics, configuration and theme tokens.
- `lib/data/database/app_database.dart`: native SQLite database, currently schema v27.
- `lib/data/database/schema_versions.dart` and `lib/data/database/generated_migrations/`: migrations.
- `drift_schemas/`: exported JSON snapshots; `build.yaml` configures Drift generation.
- `assets/catalog/catalog_v2.json`: bundled OpenNGC subset; filename is not catalog version.
- `test/`: core/data/domain/presentation regressions; `test/support/` contains shared fakes.
- `integration_test/` and `test_driver/`: host flows and separate Android capture routes.
- `tool/`: verification, CI partitioning, catalog generation and design helper scripts.
- `design/reference/`: consolidated design rules website, current application map, historical Atlas, shared assets and render evidence. Start at `design/reference/index.html`.
- `design/reference/atlas/index.html`: historical Visual Atlas; manifest, boards and captures accompany it. `.audit/atlas/index.html` redirects here.
- `.audit/` and `docs/archive/`: historical evidence; inspect as needed, preserve contents.
  `docs/archive/` is local and gitignored: source comments that cite `docs/DECISIONS.md`, `docs/refinement/`, `docs/design/` or `docs/TECH_DEBT.md` point there, not to tracked files.
- `.agents/skills/`: active project recipes; `.agents/rules/` holds compatibility pointers.

## Technical invariants

- Keep UI, ViewModels, domain interfaces/calculations and data implementations separated.
- Reuse Provider, repository injection and existing router/draft guards for focused changes.
- Keep catalogs, saved plans, calculations and Logbook useful offline.
- Forecast retrieval, map tiles and optional place-name lookup need network access.
- Preserve weather cache/freshness/error states and opt-in reverse-geocoding consent.
- Unknown is not zero: preserve missing values, units, provenance and partial observations.
- Never invent sensor specifications, catalog values, measurements or a quality score.
- Relative stacking gain is not absolute SNR; storage estimates retain their evidence kind.
- AF/MF and white balance are descriptive; do not invent numeric focus measurements.
- SessionNight is 24 hours from site mean solar noon in UTC; retain zone/DST display semantics.
- A placeholder location is not a selected site; preserve no-site and missing-input states.
- CaptureBudgetCalculator and FitAnalyzer share atomic events; keep timing assumptions aligned.
- Preserve draft, explicit Save plan, fit verdict and recorded-result distinctions.
- Preserve local records, supported migrations and backup/restore compatibility.
- Maintain Light, Dark and Field Red, including the root field color filter.
- Theme definitions live in `lib/core/theme/`; inspect semantic roles and actual callers.
- Use existing Geist typography, spacing, radii and reduced-motion handling for local UI fixes.
- Keep meaningful words, accessible actions, text scaling and reachable controls.

## Commands and verification

Run from the repository root with Flutter/Dart on PATH and resolved dependencies.
`pubspec.yaml` requires Dart `^3.13.3`; CI pins its SDK in `.github/workflows/ci.yml`.
Inspect the installed SDK and lockfile; do not upgrade dependencies as a bootstrap step.

```sh
flutter pub get
flutter run
flutter analyze --no-pub
flutter test --no-pub
flutter test --no-pub test/data/database/schema_migration_test.dart
dart run build_runner build
dart run drift_dev schema steps drift_schemas/ lib/data/database/schema_versions.dart
flutter build apk --debug
```

- Code generation changes files: run for changed database inputs and inspect the diff.
- Preserve older schema snapshots; test migrations against supported stored databases.
- Format changed Dart files; select tests from changed behavior and its callers.
- `dart run tool/check.dart --checks-only` runs encoding, formatting and analysis checks.
- `dart run tool/check.dart` also runs unit tests and each host-capable integration file.
- CI implementation/job selection live in `tool/ci.py` and `.github/workflows/ci.yml`.
- Run host integration files separately; Android-only capture tests need an Android device.
- For instruction-only edits, validate paths, frontmatter and diffs; app checks are optional.

Instruction tooling uses Python with `tool/requirements-instructions.txt`:
`python -m pip install -r tool/requirements-instructions.txt`, then
`python tool/check_instructions.py` and
`python -m unittest discover -s tool -p check_instructions_test.py -v`.
CI runs these in the changes job, including documentation-only changes.
The validator checks active skill YAML and local Markdown file references in
the root entrypoints, `.agents/` and `.claude/`; it does not check remote URLs,
heading anchors, code-span paths or agent behavior. Behavioral review cases and
their evidence requirements are in [skill evals](tool/skill_evals/README.md).

Native UI renders in PowerShell (synthetic fixtures; fresh evidence goes to build):

```powershell
New-Item -ItemType Directory -Path build/ui-renders -Force | Out-Null
$env:CULMINA_AUDIT_RENDERS = 'build/ui-renders'
$env:CULMINA_AUDIT_SHOTS = 'home,plan'
$env:CULMINA_AUDIT_THEMES = 'light,dark,field'
$env:CULMINA_AUDIT_SCALE = '1'
flutter test --no-pub test/presentation/design_system/concept_b_app_audit_renders_test.dart
Remove-Item Env:CULMINA_AUDIT_RENDERS, Env:CULMINA_AUDIT_SHOTS, Env:CULMINA_AUDIT_THEMES, Env:CULMINA_AUDIT_SCALE
```

The harness loads real fonts and uses in-memory state; inspect supported shot names.
The archived Atlas has 40 Dark/100%/375×812 captures with dated source provenance.
Check its manifest before reusing frames; archive presence does not prove current behavior.
Keep browser, Flutter host, Android/device, accessibility and owner acceptance evidence distinct.

For meaningful product-design refinement, use a brief
[decision record](.agents/skills/references/refinement-decision.md) in the existing
task or review: user problem, intended benefit, observable success, matched
before/after evidence, actual checks and the accept/revise/reject decision.
Scale the record to the change; this adds no separate approval gate.

## Active project skills

### Design authority and supporting tools

For explicitly authorized Culmina After/Figma exploration, the [After router](.agents/skills/culmina-figma-after/SKILL.md) and [target contract](design/figma/TARGET_DESIGN_SYSTEM.md) govern the requested After scope. Production skills below still describe current UI semantics and APIs, but do not constrain authorized After visual values or composition. This exception does not authorize Flutter migration or changes to BEFORE/shared dependencies; apply the current task's theme and stage limits.

The five `culmina-design-*` skills below are the only project design authorities
for all UI code: screens, shared and composed widgets, scientific displays,
dialogs, states and all three themes. Use the relevant skills during implementation;
their scope is not limited to the component gallery. AGENTS supplies shared
invariants; current source/callers and tests establish actual behavior.
References and `docs/DESIGN_SYSTEM.md` support these skills, not parallel policy.
Fill a design-guidance gap in the relevant Culmina skill instead of adopting an
external playbook or inventing another design authority.

Dart/Flutter skills remain technical helpers for architecture, routing, layout
diagnosis, previews and tests. Context7 supplies external API documentation.
Figma, image generation, visualization, browser/computer use and Sites remain
optional execution tools for a requested artifact, not sources of Culmina style.
Generic design/audit, brand and palette playbooks are archived for this project.
See [agent tooling](docs/AGENT_TOOLING.md) for retained helpers, archive and plugin evidence.
Installed or enabled plugins do not prove authentication, invocation or acceptance.

For Figma work, use **Web Figma + Scripter through native desktop/computer-use**.
The Figma MCP quota is exhausted (owner report, 2026-11-04); do not spend calls
on MCP discovery, access probes or retries unless the owner explicitly requests
a recheck. Follow the [Figma execution route](docs/AGENT_TOOLING.md#figma-execution-route).

The [skill index](.agents/skills/README.md) lists purposes, scopes and `.agents/skills/<name>/SKILL.md` entrypoints; each SKILL.md remains the execution authority for its task. Upstream metadata and lock hashes describe acquisition provenance, not current local hashes.

## Current external documentation

Use Context7 for library/framework/SDK/API/CLI questions, including unfamiliar flags.
Resolve the library ID first unless the user supplies an exact `/org/project` ID.
Choose an authoritative/version-matched result, then query one concept per call.
Use fetched docs with the installed SDK and actual callers; disclose failed lookups.
General code reasoning and source-only refactors need no library-documentation lookup.
