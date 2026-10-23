# Culmina tooling overrides

- Product rules and existing dependencies remain authoritative. This tooling maintenance authorizes no R1-R5, SDK, app or dependency changes.
- For integration_test, use `.agents/skills/flutter-add-integration-test/SKILL.md` as the corrected recipe. Standard native integration_test uses its binding and flutter test; no Flutter Driver extension in production main.dart. This overrides conflicting official/plugin recipe text.
- Official Claude Dart/Flutter plugin: dart-flutter@dart-flutter 1.0.7. The old synced duplicate and generic Flutter plugin are disabled to avoid overlapping prescriptions. Use fully qualified skill names.
- Impeccable: user skill 4.7.0; do not use the disabled Codex 4.3.1 plugin. Preserve Culmina decisions over generic detector opinions.
- Context7: use one resolve/query sequence via the context7 MCP. Never repeat the same lookup through a second connector unless the primary route failed.
- Dart MCP uses the isolated current-SDK cache configured in settings.local.json. For CLI health commands use `C:/Users/zalub/.codex/tools/culmina/claude.ps1`, which supplies the same scoped environment. No application debug process was running during verification.
