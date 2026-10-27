---
name: flutter-setup-declarative-routing
description: "Change the existing Culmina router and shell while preserving navigation, draft guards and Back behavior."
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Tue, 21 Apr 2026 21:08:03 GMT
---

Local Culmina guidance; upstream metadata is retained as provenance. Follow [AGENTS](../../../AGENTS.md) for shared scope, source routes and checks.

# Culmina routing

Use for an authorized routing change. `go_router` is already declared in `pubspec.yaml`; the app already uses `MaterialApp.router` in `lib/main.dart`.

1. Inspect `lib/presentation/navigation/app_router.dart`, `app_shell.dart`, the affected destination and existing navigation tests.
2. Preserve existing shell branches, selected state, Back behavior and route-specific draft guards. Read the relevant product contract before changing how a destination is entered or left.
3. Extend the existing router rather than scaffolding a new app/router or installing another navigation package.
4. Verify unfamiliar `go_router` APIs against the resolved version using [AGENTS](../../../AGENTS.md).
5. Check the changed navigation and its affected callers under [AGENTS](../../../AGENTS.md). Platform deep-link configuration changes require that named platform scope and evidence.

Report entry/exit paths, preserved state, affected tests and runtime limits. Generic shell or deep-link examples do not establish Culmina's current route contract.
