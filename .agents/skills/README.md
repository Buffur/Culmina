# AstroPlan Agent Skills

Updated 2026-10-17. This directory contains general Dart/Flutter recipes and other tool guidance; it is not an empty placeholder or the project's task queue.

- Read only a skill relevant to the approved Task. Availability is not a requirement to apply it.
- Follow the current architecture, dependencies, scope and canonical Verification Policy in CLAUDE.md over generic setup/test recipes.
- A recipe does not authorize new dependencies, changing navigation/state management, broad refactoring, or additional product scope.
- Do not load the whole skills directory into each session. Do not assume Claude Code automatically discovers this directory; reference a needed recipe explicitly.
- Project-specific procedures may also be added for an explicit owner request; keep their proposal/production boundaries clear.

## Culmina design skills (owner request, 2026-10-19)

Read [the workflow](../../docs/design/WORKFLOW.md), then only the relevant skill:

- [Semantic tokens and themes](culmina-design-tokens/SKILL.md)
- [Components by group](culmina-design-components/SKILL.md)
- [Typography and font specimens](culmina-design-typography/SKILL.md)
- [Spacing and shape](culmina-design-spacing/SKILL.md)
- [Product rules and technical debt](culmina-design-rules/SKILL.md)

The browser proposals are in `design/home-lab/`; their font/palette/layout choices are not automatic approval to change production UI.
