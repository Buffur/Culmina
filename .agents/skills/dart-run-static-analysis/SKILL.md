---
name: dart-run-static-analysis
description: "Run scoped Culmina analysis using the existing configuration; automated fixes must fit the authorized change."
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Fri, 24 Apr 2026 15:09:34 GMT
---

Local Culmina guidance; upstream metadata is retained as provenance. Follow [AGENTS](../../../AGENTS.md) for shared scope, source routes and checks.

# Culmina static analysis

Use for static diagnostics in the authorized change. Preserve the local scope and automated-fix safeguards introduced before this cleanup.

1. Inspect the current `analysis_options.yaml` when relevant. It includes `package:flutter_lints/flutter.yaml`; existing exclusions and rules are repository configuration, not a generic template to replace.
2. Use available analyzer tools for diagnosis, or the repository's `flutter analyze --no-pub` command when analysis is required by [AGENTS](../../../AGENTS.md). Report the actual target and output.
3. Trace each relevant diagnostic through the affected caller. Fix the cause; do not suppress diagnostics merely to pass a check.
4. Automated fixes are optional. Preview their scope, review every proposed change, and apply only authorized corrections. If the tool cannot bound the apply, make selected corrections manually.
5. Do not enable rules, change dependencies/configuration, or run repository-wide fixes/formatting to generate more work. Format changed Dart files and run only the checks appropriate to the affected behavior.

For an exception or reproduced runtime failure, use [dart-fix-runtime-errors](../dart-fix-runtime-errors/SKILL.md). An available tool does not prove an active runtime connection.
