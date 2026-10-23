---
paths:
  - ".agents/skills/**"
  - "tool/**"
---

# Culmina tooling recipe routing

Status: active, scoped Claude supplement (2026-10-24). [AGENTS](../../AGENTS.md) and [VERIFICATION_POLICY](../../docs/VERIFICATION_POLICY.md) govern scope and checks. Read only a relevant recipe; no tooling installation or product change follows from its availability.

- Preserve the local correction in `.agents/skills/flutter-add-integration-test/SKILL.md`: standard native integration_test uses its binding and flutter test; no Flutter Driver extension in production main.dart.
- Use one Context7 resolve/query route per documentation question; report a failed primary route before falling back.
- Discover the actual local SDK/tools and configured MCP route. Do not silently substitute a conflicting shared cache. Installed, connected and successfully exercised remain separate claims.
- Dated versions, absolute paths and one-machine observations were moved byte-for-byte to [the archive](../../docs/archive/governance-2026-10-24/README.md). Consult [AI_WORKFLOW](../../docs/AI_WORKFLOW.md) for portable procedure; verify dated references locally.
