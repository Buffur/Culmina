---
name: dart-generate-test-mocks
description: "Choose or extend Culmina handwritten test fakes for a scoped test task; a new mocking dependency requires its own authorized adoption."
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Fri, 24 Apr 2026 15:13:58 GMT
---

Local Culmina route, 2026-10-27; upstream metadata is retained as provenance. Scope and verification remain in the linked canonical policies.

# Culmina dependency fakes and mocks

Use when a test needs controlled behavior from an external dependency.

1. Inspect the production constructor/interface and existing tests. Reuse the matching handwritten fake under `test/support/` or the area's local fixture.
2. Model only the dependency behavior the test exercises, including the relevant asynchronous failure, stale completion or data-integrity case. Keep scientific inputs explicit.
3. Follow the suite's `flutter_test` conventions and run the affected existing test file under [VERIFICATION_POLICY](../../../docs/VERIFICATION_POLICY.md).

`mockito` is not a direct dependency. If the task explicitly adopts generated mocks, first assess why existing fakes are insufficient, verify current Mockito/build_runner documentation through [AI_WORKFLOW](../../../docs/AI_WORKFLOW.md), and bound the dependency and generation diff. Do not install a mocking package or generate repository-wide output as a default test step.
