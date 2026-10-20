# Final CLI review preparation — not executed

Prepared after the v27 override host checks. The parent agent must first confirm
stable final native/matched-data evidence and quality logs. This preparation
does not represent a completed independent review.

Prompt: `FINAL_CLAUDE_REVIEW_PROMPT.md` in this directory.

Before execution, capture the exact source state/diff (including the new
untracked files), final evidence paths and timestamp. The reviewer can read only
repository files and images through Read/Grep/Glob; it cannot independently run
tests or operate a device. Preserve stdout and invocation verbatim.

Verified installed CLI help and the completed preflight invocation are in
`baseline/claude-help.txt` and `baseline/claude-invocation.txt`. Normal read-only
permission mode is `manual`; no bypass flag.

Prepared PowerShell command, to run only after the integration-ready signal:

```powershell
Get-Content -LiteralPath 'docs/design/migration/evidence/FINAL_CLAUDE_REVIEW_PROMPT.md' -Raw |
  claude --print --permission-mode manual --permission-prompts none `
    --tools 'Read,Grep,Glob' --allowedTools 'Read,Grep,Glob' `
    --strict-mcp-config --no-session-persistence --output-format text |
  Tee-Object -FilePath 'docs/design/migration/evidence/final-claude-original-report.txt'
```

Record the actual exit code separately. A nonzero exit or unavailable tool does
not establish QA completion. Keep any original findings when recording fixes
and targeted follow-up results.
