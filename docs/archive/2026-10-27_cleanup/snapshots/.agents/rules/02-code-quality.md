# Code Quality Rules

Status: active supplement to [AGENTS](../../AGENTS.md); verification is owned by [VERIFICATION_POLICY](../../docs/VERIFICATION_POLICY.md). Read only for the relevant task.

- Prefer small, coherent changes.
- Do not refactor unrelated code while implementing a feature.
- Do not revert user changes unless explicitly asked.
- Prefer existing project patterns over new abstractions.
- Avoid magic numbers; name and document constants when they carry domain
  meaning.
- Keep generated files in sync with their sources when their inputs change within authorized scope. Do not regenerate frozen reference snapshots to hide a diff.
