---
name: dart-fix-runtime-errors
description: Diagnose and fix a specific Dart or Flutter runtime error from its exception, stack trace and reproducible behavior.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Fri, 24 Apr 2026 15:13:22 GMT
---
# Fixing Dart and Flutter runtime errors

1. Capture the exception, stack trace and reproduction conditions. If a Dart Tooling Daemon connection and runtime-error tool are available for the relevant active app, use them; otherwise use the available logs or a focused reproduction. Do not claim an active connection or a reproduction that was not observed.
2. Trace the failing frame through the actual caller and state. Use available language-server navigation where helpful; distinguish the cause from a downstream symptom. Inspect the relevant source contracts and AGENTS.md invariants and preserve data, lifecycle and error-handling contracts.
3. Make the smallest authorized correction. Do not change analyzer configuration, suppress diagnostics, or run repository-wide automated fixes as a substitute for diagnosis.
4. Reproduce the original scenario and run the affected checks described in AGENTS.md. If an appropriate app is connected, use hot reload or restart as applicable and recheck the error; a reload alone does not prove the affected behavior. Report unavailable runtime evidence and remaining uncertainty.

For static diagnostics rather than a runtime failure, use the `dart-run-static-analysis` skill when relevant.
