---
name: dart-collect-coverage
description: "Collect and interpret coverage for an explicitly scoped Culmina Flutter test task; preserve existing behavioral assertions."
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Fri, 24 Apr 2026 15:14:32 GMT
---

Local Culmina route, 2026-10-27; upstream metadata is retained as provenance. Scope and verification remain in the linked canonical policies.

# Culmina coverage investigation

Use only for a named coverage question. Coverage collection does not replace the checks selected by [VERIFICATION_POLICY](../../../docs/VERIFICATION_POLICY.md).

1. Identify the behavior, source files and corresponding Flutter tests to measure.
2. Inspect the current Flutter test command/documentation through [AI_WORKFLOW](../../../docs/AI_WORKFLOW.md) before selecting coverage flags and output handling. The project uses `flutter_test`; a Dart-only runner is not its default test route.
3. Collect the bounded evidence and inspect whether the relevant source paths and branches were exercised. Record the selected tests and input state.
4. Missing coverage requires investigation of the test and fixture. Do not add coverage-ignore directives merely to improve a metric.

The app has no direct `coverage` dependency. Installing coverage tooling, changing CI, or excluding source from a metric requires the corresponding authorized task.
