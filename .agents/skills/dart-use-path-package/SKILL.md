---
name: dart-use-path-package
description: "Use the existing path dependency for a concrete Culmina file-path task; optional examples are not production fixtures."
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Wed, 23 Sep 2026 22:10:00 GMT
---

Local Culmina route, 2026-10-27; upstream metadata is retained as provenance. Scope and verification remain in the linked canonical policies.

# Culmina filesystem paths

Use for a named filesystem-path issue. `path` is already declared in `pubspec.yaml`.

1. Inspect the affected file-operation source and its tests. Relevant application areas include `lib/data/backup/`, `lib/data/services/` and `lib/domain/services/`; select the actual caller rather than changing all of them.
2. Preserve platform-path versus URI meaning and the existing file-access abstraction. Keep owner paths and private samples out of logs and tracked fixtures.
3. Check unfamiliar `path` API behavior through [AI_WORKFLOW](../../../docs/AI_WORKFLOW.md); inspect the resolved package version before using new API syntax.
4. Verify the changed behavior under [VERIFICATION_POLICY](../../../docs/VERIFICATION_POLICY.md), including applicable persistence/backup round-trip evidence.

## Optional upstream examples

- [Cross-platform paths](examples/cross_platform_paths.dart)
- [Filesystem context](examples/file_system_context.dart)

These are generic examples, not production source or proven app fixtures. The filesystem-context example imports `package:file`, which is not a direct application dependency; do not install it merely to use this recipe.
