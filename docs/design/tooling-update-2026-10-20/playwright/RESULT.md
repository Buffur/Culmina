# Stable Playwright tooling update — 2026-10-20

Scope: development tools only. No Flutter/Dart SDK, app source, product behavior, `pubspec` or application dependency changes.

## Before / after

| Component | Before | After |
|---|---|---|
| CLI | @playwright/cli 0.1.22 through an unpinned npx cache | Same latest stable CLI, exact-pinned in a dedicated npm tool directory |
| Runtime / core actually resolved | 1.64.0-alpha-1790635538000 | **1.64.1 / 1.64.1** |
| Browser used for checks | System Edge or cached browser | Matching Chromium revision **1248**, Chrome for Testing **156.0.8078.4** by default |
| Skill Windows invocation | Unpinned bash/npx wrapper | Explicit pinned PowerShell launcher; preserved original wrapper/instructions |
| Five repository browser-check scripts | Arbitrary `playwright` resolution or caller-supplied cached module; hardcoded Edge in several scripts | Shared stable helper validates runtime 1.64.1 and chooses its matched browser; explicit environment overrides remain possible |

The official CLI 0.1.22 package still declares alpha runtime/core dependencies. The dedicated tool manifest uses standard **npm overrides** to resolve them to 1.64.1; no installed package/cache source was edited. Actual CLI and library smoke succeeded. This is verified local compatibility for the checked operations, not an upstream guarantee for every CLI command.

## Install and invocation

Tool directory: `C:/Users/zalub/.codex/tools/culmina-playwright/`.

- Exact versions and dependency integrity are locked in `package-lock.json`; copies are included beside this report.
- Installed with `npm install --prefix <tool-directory> --ignore-scripts --no-audit --no-fund`.
- Matching browser installed with `node <tool-directory>/node_modules/playwright/cli.js install chromium --no-remove`, using a dedicated `PLAYWRIGHT_BROWSERS_PATH=<tool-directory>/browsers`. Shared browser caches were not cleaned.
- Windows CLI entry: `C:/Users/zalub/.codex/skills/playwright/scripts/playwright_cli.ps1`, forwarding to `<tool-directory>/pwcli.ps1`.
- Library module: `<tool-directory>/node_modules/playwright`.
- Repository scripts load `design/home-lab/scripts/browser_toolchain.cjs`; `CULMINA_PLAYWRIGHT_TOOLS` can relocate the dedicated tool install. A wrong runtime version fails explicitly instead of silently using an alpha cache.
- Default browser executable: `<tool-directory>/browsers/chromium-1248/chrome-win64/chrome.exe`.
- `CULMINA_BROWSER` deliberately opts a library check into a system browser channel; that opt-in is distinct from the verified matching-browser default.

## Verification performed

1. Rechecked official npm latest tags: CLI **0.1.22**, runtime **1.64.1**. Read current Playwright and CLI docs through Context7.
2. `npm ls --all` resolves CLI dependencies to stable runtime/core1.64.1 with overrides; CLI `--version` returns0.1.22.
3. Pinned CLI session `culmina-tooling-stable-20261020` loaded Home from `localhost:4173`, captured a snapshot, clicked the existing Open planner button, read the resulting Plan title/Save plan control and captured a screenshot. Console reported zero errors/warnings. `run-code` confirmed Chromium156.0.8078.4.
4. Actual CLI daemon process command used `<tool-directory>/node_modules/playwright-core/lib/entry/cliDaemon.js`; its child executable was the dedicated Chromium1248 path above.
5. Shared repository helper independently launched the matching browser and repeated Home→Plan navigation in a fresh context, with zero page errors. Results are in `runtime-smoke.json`.
6. Browser session/context closed after checks. Owner in-app browser profile/storage were not used. No Save action or fixture record mutation was performed.

## Backup and changed files

Backup: `C:/Users/zalub/.codex/backups/culmina-tooling-20261020/playwright/` contains original local Playwright SKILL.md, bash wrapper and all five modified check scripts. Dedicated tool directory did not previously exist.

Changed local tools: new dedicated npm manifest/lock/install/browser directory and `pwcli.ps1`; local Playwright SKILL.md gained a separately labeled host-specific stable-route note; new skill `scripts/playwright_cli.ps1`.

Changed repository development tooling: new `browser_toolchain.cjs` and launch/import routing in `check_hybrid_continuity.cjs`, `check_hybrid_feedback.cjs`, `check_hybrid_plan_clarity.cjs`, `check_tabs_interactions.cjs`, `check_tabs_browser.cjs`. No full feature matrix was rerun; this task requires a short toolchain smoke, not another application audit.

Evidence: package manifests/lock, CLI snapshots/screenshot and `runtime-smoke.json` in this directory. Temporary CLI-generated `.playwright-cli` outputs from this task were copied here; no owner sessions were closed.

## Remaining limits

- CLI0.1.22 upstream alpha dependency declaration remains; the local override is documented and bounded-smoke verified. Future CLI updates must be checked with the runtime pin rather than installed into an opaque npx cache.
- Chromium is the matching browser installed/tested here. Firefox/WebKit were not required by the existing Culmina checks and were not installed or certified.
- Current active chats may retain the old Playwright skill text; a new chat sees the labeled pinned Windows route. The new launcher itself works immediately.

Official sources: [CLI package](https://registry.npmjs.org/@playwright/cli/latest), [runtime package](https://registry.npmjs.org/playwright/latest), [CLI docs](https://github.com/microsoft/playwright-cli), [browser installation](https://playwright.dev/docs/browsers).
