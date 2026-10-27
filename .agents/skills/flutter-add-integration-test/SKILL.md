---
name: flutter-add-integration-test
description: "Extend Culmina integration tests using the existing host and driver routes, without adding Flutter Driver code to production main."
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Tue, 21 Apr 2026 18:29:20 GMT
---

Local Culmina route, 2026-10-27; upstream metadata is retained as provenance. Scope and verification remain in the linked canonical policies.

# Culmina integration tests

Use to extend a named existing flow under `integration_test/`. Inspect the selected test, `test_driver/` when relevant, and the current [CI documentation](../../../docs/CI.md) before selecting execution.

1. Reuse the existing `integration_test` and `flutter_test` SDK dependencies in `pubspec.yaml`.
2. Inspect the actual application/test entrypoint. The application source is `lib/main.dart`; there is no `lib/main_test.dart` in this checkout. Match the existing test's setup rather than inventing an entrypoint or a `MyApp` constructor.
3. Keep `IntegrationTestWidgetsFlutterBinding` initialization in the integration test where required by the existing setup. Preserve the prior local correction: standard native integration_test does not require a Flutter Driver extension in production `main.dart`.
4. Discover the available runtime tools and the actual app connection before relying on them. Do not assume a named tap, health or wait tool exists. Use observed widget state and focused interaction evidence when authorized.
5. Extend the existing flow with stable finders and assertions for the behavior under test. Preserve draft/saved distinctions, night/time semantics and owner data.
6. Select the actual host/device test route from the existing setup and [VERIFICATION_POLICY](../../../docs/VERIFICATION_POLICY.md). If the task needs unfamiliar CLI or framework behavior, check current documentation through [AI_WORKFLOW](../../../docs/AI_WORKFLOW.md).

Report the test file, entrypoint, input state, environment, result and limits. A static source review, host run, emulator/device run and owner acceptance are separate evidence.
