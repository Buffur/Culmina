---
name: dart-build-cli-app
description: "Change existing Culmina Dart tools under tool/; inspect actual callers and contracts before using optional standalone CLI templates."
---

Local Culmina guidance; upstream metadata is retained as provenance. Follow [AGENTS](../../../AGENTS.md) for shared scope, source routes and checks.

# Culmina command-line tooling

Use only for an authorized Dart tooling task. Culmina is a Flutter application; its existing utilities live under `tool/`, rather than a separate `bin/` CLI package.

1. Inspect the utility being changed and its actual callers. `tool/check.dart` owns local verification orchestration; `tool/check_encoding.dart` and `tool/check_bundle.dart` have separate purposes.
2. Preserve argument parsing, exit status, output and subprocess contracts already used by those callers. Keep a focused tool change separate from application behavior.
3. Reuse existing dependencies. A generic CLI template is not permission to add `args`, `io`, `stack_trace` or executable mappings to this app.
4. For any API or CLI behavior not established by the existing utility, use the Context7 documentation route in [AGENTS](../../../AGENTS.md).
5. Executable tooling changes follow the affected-tool checks in [AGENTS](../../../AGENTS.md).

## Optional upstream examples

These are templates for a separately scoped CLI package, not runnable Culmina fixtures. Inspect their imports and provide their dependencies in that separate package before using them:

- [Single command](examples/single_command_tool.dart)
- [Command runner](examples/multi_command_runner.dart)
- [SDK discovery reference](references/aot_sdk_discovery.md)
- [Terminal and signals reference](references/signals_and_terminal.md)
