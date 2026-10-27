---
name: flutter-use-http-package
description: "Change an existing Culmina HTTP service or repository using its current injected interface and endpoint contract."
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Tue, 21 Apr 2026 21:36:42 GMT
---

Local Culmina guidance; upstream metadata is retained as provenance. Follow [AGENTS](../../../AGENTS.md) for shared scope, source routes and checks.

# Culmina HTTP work

Use for an authorized change to existing network behavior. `http` is already declared in `pubspec.yaml`.

1. Inspect the actual repository/service and injected client used by the affected call. Relevant source areas include `lib/data/repositories/` and `lib/data/services/`; do not add networking directly to a screen.
2. Preserve endpoint-specific success/error semantics, parsing, timeouts, cache/freshness/provenance and offline behavior. Unknown or stale data must retain its actual meaning.
3. Reuse the existing client and test fakes. Do not add dependencies or edit all platform permissions as a generic setup step.
4. For a new provider or external API, follow the scope and research requirements in [AGENTS](../../../AGENTS.md) and [AGENTS](../../../AGENTS.md). Verify unfamiliar `http` syntax through that documentation route.
5. Apply [AGENTS](../../../AGENTS.md) to the actual network/data behavior and affected callers.

Report the endpoint contract, affected states and evidence. A source review or fake response does not prove live-provider reliability.
