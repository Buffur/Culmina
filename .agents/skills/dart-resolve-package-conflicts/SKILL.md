---
name: dart-resolve-package-conflicts
description: "Diagnose a concrete Culmina dependency conflict while preserving intentional exact pins and lockfile integrity."
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Fri, 24 Apr 2026 15:11:14 GMT
---

Local Culmina guidance; upstream metadata is retained as provenance. Follow [AGENTS](../../../AGENTS.md) for shared scope, source routes and checks.

# Culmina dependency conflicts

Use for a reproduced dependency-resolution failure or a specifically authorized dependency change.

1. Capture the actual solver error. Inspect `pubspec.yaml`, `pubspec.lock` and the named packages' constraints before selecting a change.
2. Preserve intentional pins. The current app pins `flutter_timezone`, `file_picker` and `archive` exactly; do not convert them to caret constraints as a general cleanup.
3. Follow the dependency comments in `pubspec.yaml`: inventory with `flutter pub outdated` when relevant, use targeted upgrades, and inspect the resolved lockfile diff. Do not delete the lockfile or individual package blocks to force resolution.
4. Verify unfamiliar resolution flags or package compatibility through the Context7 documentation route in [AGENTS](../../../AGENTS.md). Installed versions and the lockfile remain the evidence for this checkout.
5. Apply the dependency checks in [AGENTS](../../../AGENTS.md) to the actual changed inputs and affected paths.

Report the conflict, selected constraint change, resulting resolution and any remaining compatibility evidence. An outdated-package inventory does not authorize blanket upgrades.
