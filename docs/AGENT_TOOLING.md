# Agent design authority and tooling

Verified on 2026-10-28. This file records routing and local configuration evidence;
it is not another design rule set. User instructions take precedence.

## Source order

1. [AGENTS](../AGENTS.md) is the shared entrypoint. CLAUDE.md and GEMINI.md redirect to it.
2. The five [Culmina design skills](../.agents/skills/README.md) are the only
   project design authorities: components, product rules, spacing/shape/motion,
   semantic tokens and typography. They cover every screen and UI component,
   including scientific displays, composed widgets, dialogs and states.
3. Inspect actual production definitions, callers and tests. A specimen or unused
   component is not evidence of adoption. Extend the relevant Culmina skill when
   guidance is missing rather than introducing another design playbook.
4. [DESIGN_SYSTEM](DESIGN_SYSTEM.md) and skill references index implementation.
   `.agents/rules/` and `.claude/rules/` are compatibility pointers, not parallel policy.
5. Use current native renders for appearance. Identify historical Atlas, host,
   browser, Android and owner evidence separately.

## Retained helpers

| Helper | Purpose and boundary |
| --- | --- |
| Local Dart/Flutter skills | Implementation, architecture, routing, diagnosis, preview and test mechanics; follow Culmina design decisions |
| Context7 | Current library/API documentation; it does not define product style |
| Figma: `figma`, `figma-use`, `figma-code-connect-components`, `figma-create-new-file`, `figma-generate-design`, `figma-generate-library`, `figma-implement-design` | Inspect, author or connect a specifically requested Figma artifact; reproduce adopted Culmina rules, never silently replace them |
| `imagegen` | Requested bitmap assets or visual studies; outputs are proposals until adopted |
| `visualize` | Explanatory maps and interactive visualizations; not Flutter evidence |
| `sites`, `sites-remix` | Requested standalone web artifacts; not production Flutter or token owners |
| Browser/computer use and Codex app tools | Inspect artifacts, interact with UI and manage task outputs |
| OpenAI Docs / Plugin Management | Explain or inspect the agent environment; not application design policy |

Helpers may have execution instructions for their tools. Their stylistic advice
does not override the five Culmina design skills. Their availability does not
authorize a redesign, package installation, remote publication or scope expansion.

## Archived external design playbooks

The new local archive is `docs/archive/2026-10-28_design-playbooks/`. Its manifest
records 22 complete ZIP bundles, original paths, archive hashes and every member
hash. Original global skills and plugin caches are preserved for other projects.
Older archives were not modified.

| Archived group | Bundles | Reason |
| --- | --- | --- |
| Impeccable standalone and plugin copy | 2 | Competing broad design/critique guidance and duplicate acquisition |
| Product Design `index`, `audit`, `design-qa`, `get-context`, `ideate`, `image-to-code`, `research`, `share`, `url-to-code`, `user-context` | 10 | Separate research/concept/prototype workflow, unnecessary for normal Culmina implementation |
| Palette/brand color recipes | 7 | `build-brand-palette`, `compose-ui-theme`, `direct-creative-palette`, `extract-image-palette`, `generate-design-tokens`, `harmonize-palette`, `plan-interior-palette`; not current Culmina color authority |
| `brand-identity` and external website `design` | 2 | Brand collection and website style extraction are outside current implementation |
| `figma-create-design-system-rules` | 1 | Generates another rule set; Culmina rules already have five local owners |

The host-specific `.codex/config.toml` adds 22 `skills.config` entries with
`enabled = false` for this trusted checkout. It is locally excluded from Git
because it contains installed absolute paths and versions. Global Codex/Claude
configuration and plugin installations were not changed. The source rules above
are versionable; the binary archive and host-specific overrides stay local.

Reload Codex before checking effective discovery. This existing chat already
contains the earlier skill catalogue. Configuration and TOML validation do not
prove a fresh runtime has applied the exclusions. Plugin updates can change
versioned paths, so recheck exclusions after updates. For Claude/Gemini the shared
AGENTS routing applies; the Codex override does not disable their global plugins.

## Plugin verification

Evidence is configuration, exposed tools and known calls in this task. It is not
an exhaustive usage history or a remote authentication audit.

| Layer | Observed state | What it establishes |
| --- | --- | --- |
| Repository | No existing repo plugin marketplace or MCP manifest; `.claude/settings.local.json` sets only `DART_DATA_HOME`; new `.codex/config.toml` only excludes skills | Agent integrations are supplied by host/user configuration, not app runtime dependencies |
| Codex user config | `dart-flutter@dart-flutter`, app/browser/computer-use, visualization and document plugins enabled; `impeccable@openai-curated-remote` explicitly false | Configured enablement; the disabled Impeccable entry did not cover the standalone skill |
| Codex MCP config | `context7`, `graphify`, `dart`, `figma`, `node_repl` configured | Configuration presence; authentication and successful calls are separate |
| Current task environment | Dart, Context7, Graphify, browser/computer-use, Codex app and other connector tools are exposed | Availability in this session, not proof each was invoked |
| This design-map work | Browser/computer-use verified the website; Codex app tools managed artifacts/goal; native fixtures ran through Flutter CLI | These paths were used; Flutter CLI rendering was not a Dart MCP invocation |
| Claude user config | `task-observer`, `superpowers`, `dart-flutter`, official `figma` enabled; duplicate synced Dart/Flutter/Figma entries false | Enabled settings and installation records; invocation not verified |

Do not claim all installed plugins are used, authenticated or needed. Figma and
Graphify were not live-tested in this check. No new plugin was installed or
uninstalled, and no permissions or credentials were changed.

Flutter platform plugins are a separate layer: `pubspec.yaml` and production
adapters use geolocation, file picking, sharing, local preferences, device time
zone, application paths and external URL launching. They remain unchanged.

Codex configuration semantics were checked against the official
[configuration reference](https://learn.chatgpt.com/docs/config-file/config-reference)
and [skill enablement documentation](https://learn.chatgpt.com/docs/build-skills).
