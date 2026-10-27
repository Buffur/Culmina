# Culmina project skills

[AGENTS](../../AGENTS.md) is the shared entrypoint. Read only the skill relevant to the user task, then inspect its source and actual callers. Skill availability does not expand task scope.

## Active inventory

| Skill | Use when working on |
| --- | --- |
| [culmina-design-components](culmina-design-components/SKILL.md) | Choosing existing components and their states |
| [culmina-design-rules](culmina-design-rules/SKILL.md) | Preserving product, time, science and persistence meaning |
| [culmina-design-spacing](culmina-design-spacing/SKILL.md) | Local spacing, density, shape and motion |
| [culmina-design-tokens](culmina-design-tokens/SKILL.md) | Semantic colors across Light, Dark and Field Red |
| [culmina-design-typography](culmina-design-typography/SKILL.md) | Text roles, wrapping and readable measurements |
| [dart-add-unit-test](dart-add-unit-test/SKILL.md) | Focused behavior/regression tests with existing fakes |
| [dart-build-cli-app](dart-build-cli-app/SKILL.md) | Existing Dart utilities under tool/ |
| [dart-collect-coverage](dart-collect-coverage/SKILL.md) | A scoped test-coverage question |
| [dart-fix-runtime-errors](dart-fix-runtime-errors/SKILL.md) | Exception diagnosis from stack and reproduction |
| [dart-generate-test-mocks](dart-generate-test-mocks/SKILL.md) | Existing handwritten dependency fakes |
| [dart-resolve-package-conflicts](dart-resolve-package-conflicts/SKILL.md) | A solver conflict or named dependency change |
| [dart-run-static-analysis](dart-run-static-analysis/SKILL.md) | Scoped analyzer diagnostics |
| [dart-use-doc-examples](dart-use-doc-examples/SKILL.md) | Local external examples in Dart API docs |
| [dart-use-path-package](dart-use-path-package/SKILL.md) | Filesystem-path behavior with the existing path package |
| [dart-use-pattern-matching](dart-use-pattern-matching/SKILL.md) | A named behavior-preserving pattern refactor |
| [dart-use-primary-constructors](dart-use-primary-constructors/SKILL.md) | An explicitly requested constructor-syntax evaluation |
| [dart-write-documentation](dart-write-documentation/SKILL.md) | Dart API doc comments |
| [flutter-add-integration-test](flutter-add-integration-test/SKILL.md) | Existing integration_test/ host/device flows |
| [flutter-add-widget-preview](flutter-add-widget-preview/SKILL.md) | A named isolated preview task after checking render fixtures |
| [flutter-add-widget-test](flutter-add-widget-test/SKILL.md) | Rendered component state and interactions |
| [flutter-apply-architecture-best-practices](flutter-apply-architecture-best-practices/SKILL.md) | Existing presentation/domain/data/core boundaries |
| [flutter-build-responsive-layout](flutter-build-responsive-layout/SKILL.md) | A named adaptive-layout task across specified sizes |
| [flutter-fix-layout-issues](flutter-fix-layout-issues/SKILL.md) | Concrete overflow, unbounded constraints or ParentData errors |
| [flutter-implement-json-serialization](flutter-implement-json-serialization/SKILL.md) | Existing model/cache/backup JSON contracts |
| [flutter-setup-declarative-routing](flutter-setup-declarative-routing/SKILL.md) | Existing router, draft guards and Back/state |
| [flutter-use-http-package](flutter-use-http-package/SKILL.md) | Existing injected HTTP adapter/cache contracts |

## Sources and visual evidence

Read themes in `lib/core/theme/`, shared UI in `lib/presentation/shared/`, screens in `lib/presentation/screens/` and their tests. Native render fixtures are under `test/presentation/design_system/`; executable tooling is under `tool/`.

The historical Visual Atlas is under `.audit/atlas/`; inspect actual files and their recorded theme/size/scale/state. Preserve `.audit/` unchanged. The reserved `design/` directory is currently empty; it supplies no live browser prototype or token authority.

Static concepts, host Flutter renders, Android/device interaction and owner acceptance establish different things. Identify which evidence was actually obtained.

## Provenance and optional examples

`skills-lock.json` records upstream acquisition provenance for imported active skills. Local amendments mean upstream hashes do not assert current-file checksums; actual SKILL.md files define the installed inventory. The five Culmina design skills are local guidance.

Generic Dart examples and CLI references are optional templates, not application fixtures. Inspect their imports/dependencies before reuse; their presence does not authorize package installation or a parallel architecture.

Obsolete checks-package, FFI-assets, ffigen, localization and ADK recipes already reside under `docs/archive/2026-10-27_cleanup/.agents/skills/`. Their empty old directories are not active skills; archived recipes are not current project rules.
