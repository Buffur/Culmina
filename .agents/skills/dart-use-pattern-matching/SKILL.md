---
name: dart-use-pattern-matching
description: "Apply Dart patterns to a named Culmina refactor while preserving current domain cases and null semantics."
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Tue, 13 Oct 2026 19:45:00 GMT
---

Local Culmina route, 2026-10-27; upstream metadata is retained as provenance. Scope and verification remain in the linked canonical policies.

# Culmina pattern matching

Use for an authorized change whose target code benefits from pattern matching; this is not a repository-wide syntax migration.

1. Inspect the target's current nullability, exhaustive cases, error behavior and callers.
2. Preserve Unknown, provenance and scientific/data distinctions. A shorter match must preserve the same behavior for missing or unexpected input.
3. Use [AI_WORKFLOW](../../../docs/AI_WORKFLOW.md) to verify syntax/API details not established by the current source and SDK.
4. Run the targeted behavior checks and applicable analysis/format requirements from [VERIFICATION_POLICY](../../../docs/VERIFICATION_POLICY.md).

[JSON patterns](examples/json_patterns.dart) is an optional upstream example. Its presence does not establish application adoption or compilation in this checkout.
