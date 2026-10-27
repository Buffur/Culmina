---
name: flutter-apply-architecture-best-practices
description: "Review or change Culmina within its existing presentation, domain, data and core boundaries and screen-scoped ViewModels."
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Tue, 21 Apr 2026 20:11:20 GMT
---

Local Culmina route, 2026-10-27; upstream metadata is retained as provenance. Scope and verification remain in the linked canonical policies.

# Culmina architecture changes

Use within an authorized feature or refactor. [AGENTS](../../../AGENTS.md) owns the architecture constraints; read the relevant section of [ARCHITECTURE](../../../docs/ARCHITECTURE.md) and inspect actual callers.

## Existing source routes

- `lib/presentation/`: screens, widgets, navigation and ViewModels.
- `lib/domain/models/`, `lib/domain/repositories/`, `lib/domain/services/`: domain contracts and behavior.
- `lib/data/repositories/`, `lib/data/services/`: implementations and services; inspect other existing data subfolders for the target's responsibility.
- `lib/core/`: shared core/theme/utilities.
- `lib/main.dart`: inspect existing Provider wiring and application composition.

1. Extend the established presentation -> ViewModel -> repository interface -> implementation/service flow. Follow the actual target boundaries and keep calculations independent of Flutter.
2. Reuse existing models, dependencies and injection patterns. Do not scaffold a parallel `lib/ui/` tree or install Freezed, built_value or get_it from a generic example.
3. Identify affected callers before changing a shared contract. Preserve lifecycle, persistence and scientific guardrails relevant to that contract.
4. Apply [VERIFICATION_POLICY](../../../docs/VERIFICATION_POLICY.md) to the bounded cumulative diff and report affected behavior and remaining evidence.
