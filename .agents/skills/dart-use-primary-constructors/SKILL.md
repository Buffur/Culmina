---
name: dart-use-primary-constructors
description: "Evaluate an explicitly requested Culmina constructor syntax migration against the resolved SDK; no automatic migration."
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Thu, 09 Jul 2026 23:13:25 GMT
---

Local Culmina route, 2026-10-27; upstream metadata is retained as provenance. Scope and verification remain in the linked canonical policies.

# Optional Dart constructor syntax

Use only when the current task specifically concerns constructor syntax. The application SDK constraint is recorded in `pubspec.yaml`; inspect the installed SDK rather than inferring it from skill metadata.

1. Read the affected model/service and its callers. Existing production classes do not require a constructor-style migration.
2. Verify the exact supported syntax and semantics through current official documentation using [AI_WORKFLOW](../../../docs/AI_WORKFLOW.md).
3. Preserve initialization order, validation, const behavior, factory/redirecting constructors and serialization contracts.
4. Keep any authorized conversion bounded. Follow [VERIFICATION_POLICY](../../../docs/VERIFICATION_POLICY.md) for behavior checks, analysis and changed-file formatting.

Do not enable language experiments, raise SDK constraints or refactor unrelated classes to satisfy this optional recipe.
