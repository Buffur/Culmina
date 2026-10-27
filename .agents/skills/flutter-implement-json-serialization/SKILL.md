---
name: flutter-implement-json-serialization
description: Change manual JSON mapping for an existing Culmina model, provider cache or backup while preserving null, provenance and compatibility contracts.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Tue, 21 Apr 2026 21:44:50 GMT
---

# Culmina manual JSON serialization

Use for a named model, cache, backup or provider payload. Read [AGENTS](../../../AGENTS.md), the existing parser/serializer and its callers before changing schema or failure behavior.

Relevant routes include `lib/domain/models/`, `lib/data/database/json_map_converter.dart`, `lib/data/backup/` and `lib/data/repositories/`. Inspect the affected route rather than creating a parallel User/demo model or changing every serializer.

1. Preserve existing field names, nullable/Unknown semantics, units, UTC/time-zone meaning, versions and source/freshness metadata. Missing values must not become fabricated zeros.
2. Use `dart:convert` and the existing model's fromJson/toJson or map-converter convention. Validate decoded shape and field types at the boundary; preserve documented compatibility/default handling and distinguish malformed input from a legitimately absent field.
3. Keep endpoint status handling in the owning network adapter and preserve its actual error/cache contract. JSON work does not authorize a new HTTP request, provider or universal throw/null policy.
4. For persisted/backup data, inspect older supported inputs and round-trip tests before changing output. Keep validation and restore atomicity in their owning services.
5. Verify representative round trips, missing/optional fields, malformed values and supported older data with focused Flutter tests. Choose background parsing only when the affected payload/performance evidence calls for it, and confirm unfamiliar APIs through Context7.

Report the schema/caller, compatibility behavior, checks and remaining limits. Reuse existing dependencies and source structures.
