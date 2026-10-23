# Testing rules

Status: active verification routing, reconciled 2026-10-24.

- Only [VERIFICATION_POLICY](../../docs/VERIFICATION_POLICY.md) decides required checks: V1 change class, V2 broader-check coverage, V3 reuse, V4 frozen acceptance, V5 corrective revalidation, V6 reopening, V7 stop/convergence, V8 fresh sessions.
- Add meaningful focused regressions when required for changed domain, repository, migration or critical UI behavior. Select by actual changed behavior/dependencies, not by a generic full-suite recipe.
- Markdown AGENTS/CLAUDE/GEMINI adapters and agent rules are documentation-only under V1. Executable tooling, CI and code examples are not exempt.
- Never claim a build, test, CI, real-file, device or owner check passed unless its required evidence exists. For reuse identify the run, inputs/environment and why they remain applicable.
