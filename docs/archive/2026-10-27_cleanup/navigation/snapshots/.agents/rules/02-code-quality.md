> **Historical navigation copy — not active instructions.** Link destinations are rebased from `.agents/rules/02-code-quality.md`. Content and acceptance statements retain their original date/scope. [Immutable original](../../../../snapshots/.agents/rules/02-code-quality.md) · [Navigation index](../../../../NAVIGATION.md). Original SHA-256: `5c87d63d70ccc3c7921211354e0e6925db1b316a2a9b8610a68cfaeb634e5081`.

# Code Quality Rules

Status: active supplement to [AGENTS](../../../../../../../AGENTS.md); verification is owned by [VERIFICATION_POLICY](../../../../../../VERIFICATION_POLICY.md). Read only for the relevant task.

- Prefer small, coherent changes.
- Do not refactor unrelated code while implementing a feature.
- Do not revert user changes unless explicitly asked.
- Prefer existing project patterns over new abstractions.
- Avoid magic numbers; name and document constants when they carry domain
  meaning.
- Keep generated files in sync with their sources when their inputs change within authorized scope. Do not regenerate frozen reference snapshots to hide a diff.
