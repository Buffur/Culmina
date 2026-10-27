---
name: dart-add-unit-test
description: "Add focused Culmina Flutter or Dart unit tests using existing flutter_test imports and test/support fakes."
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Mon, 03 Aug 2026 21:51:24 GMT
---

Local Culmina route, 2026-10-27; upstream metadata is retained as provenance. Scope and verification remain in the linked canonical policies.

# Culmina unit tests

Use for a named behavior or regression in the existing Flutter test suite. Read the affected source and its existing tests before creating a fixture.

1. Use `package:flutter_test/flutter_test.dart`, as the current suite does; the project already declares `flutter_test`.
2. Place tests under the matching `test/` area with `_test.dart` suffix. Reuse the relevant handwritten fake or helper under `test/support/`; add a fake only for the dependency the behavior needs.
3. Exercise observable behavior and meaningful failure/Unknown cases. Preserve time, provenance and persistence contracts from the relevant guardrails.
4. Run the affected test file with `flutter test --no-pub test/<actual_file>_test.dart`, then apply [VERIFICATION_POLICY](../../../docs/VERIFICATION_POLICY.md) to the cumulative change.

Mockito is not a direct dependency. A generic mocking example does not authorize installing it or replacing existing fakes. Use the [mocking route](../dart-generate-test-mocks/SKILL.md) only when that choice is part of the task.
