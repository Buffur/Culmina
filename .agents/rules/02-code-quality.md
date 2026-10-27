# Code quality supplement

Shared conventions are in [AGENTS](../../AGENTS.md); checks are in [VERIFICATION_POLICY](../../docs/VERIFICATION_POLICY.md).

- Name and document constants that carry domain meaning.
- Keep generated outputs aligned with changed source inputs within the authorized task. Preserve frozen reference snapshots; do not regenerate them to hide a diff.
