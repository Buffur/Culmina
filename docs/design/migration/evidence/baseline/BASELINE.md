# Migration baseline and native environment

Captured 2026-10-20, repository HEAD `8048cfa4e7fd5eadc99cba708a02f055ceddd53f`. Existing dirty/untracked owner work was preserved; see `git-status.txt`.

## Pre-edit functional baseline

- `flutter analyze --no-pub`: PASS, no issues, 109.6 seconds (`flutter-analyze.txt`).
- `flutter test --no-pub test/core/theme test/presentation/navigation test/presentation/screens/tonight test/presentation/widgets/tonight_opportunity_widget_test.dart --reporter expanded`: PASS, 94 tests, 17 seconds (`targeted-tests.txt`).
- These checks completed before production migration edits. They are HOST evidence, not Android acceptance.

## Early actual-widget renders

`ASTROPLAN_U_RENDERS=<absolute renders folder>; flutter test --no-pub test/presentation/design_system/u_renders_test.dart --plain-name "U renders: light_100" --reporter expanded`: PASS, one render scenario, 30 seconds (`renders.txt`, `renders/`).

IMPORTANT: Tonight changes started after the functional baseline and before this render. These are EARLY PARTIAL-MIGRATION HOST renders, not an untouched Tonight visual baseline. Plan and other screens had not yet been changed by their implementation agents. Capture is 412 x 915 logical pixels, light, 100% text, production app/router with controlled fixtures and SDK Roboto/Material fonts. Tile HTTP 400 warnings are preserved in the log; live map tiles were unavailable in this test environment. The complete U render fixture traverses real routes but does not prove device integration or web visual parity. The existing renderer must load Geist explicitly for final font-accurate captures.

## Verified toolchain

- Flutter 3.47.4, Dart 3.13.3 at `C:\flutter`; Claude Code 2.1.304 at `C:\Users\zalub\.local\bin\claude.exe`.
- Flutter connected devices: Windows desktop, Chrome, Edge. No connected Android device or configured AVD at discovery.
- Android SDK exists at `C:\Users\zalub\AppData\Local\Android\sdk` even though adb is absent from PATH.
- Installed Android 30 Google APIs x86_64 system image; SDK platforms 35, 36, 37.0; build tools 36.0.0; NDK 28.2.13676358; CMake 3.22.1. WHPX installed and usable. Original details: `android-inventory.txt`.
- Java: `C:\Program Files\Android\Android Studio\jbr\bin\java.exe`.
- SDK manager / AVD manager: SDK `cmdline-tools\review-20261019\bin\sdkmanager.bat` / `avdmanager.bat`. Emulator: SDK `emulator\emulator.exe`. ADB: SDK `platform-tools\adb.exe`.
- No emulator launched, SDK installed, device changed or Android build attempted during this baseline.

## Independent CLI preflight

Actual Claude CLI run completed successfully using `--permission-mode manual --permission-prompts none --tools Read,Grep,Glob --allowedTools Read,Grep,Glob --strict-mcp-config`. No permission bypass. `claude-help.txt`, `claude-prompt.txt`, `claude-invocation.txt`, `claude-original-report.txt` preserve invocation and original output.

This is preflight risk identification only, NOT the user's required final post-implementation QA. Its original report lists actual read coverage and limitations. Main risks: hidden routes/guards, draft vs saved state, night propagation, scientific unknown states, field mode, real font/accessibility metrics, host-vs-native evidence, and retained file/provider behavior.

## Existing verification tools for continuation

- `test/presentation/design_system/u_renders_test.dart`, env `ASTROPLAN_U_RENDERS`: production app/router/database host renders. Per-variant filter `--plain-name "U renders: light_100"` (also dark_200/field_100).
- `test/presentation/design_system/render_gallery_test.dart`, env `ASTROPLAN_RENDER_GALLERY`: shared component host sheets.
- `integration_test/core_loop_test.dart`: site, target, rig, night, plan, save, restart, result, log and export with real temporary SQLite and fake providers/platform sharing. `integration_test/perf_scenarios_test.dart` holds performance scenarios.
- `tool/check.dart` is the consolidated gate; do not run repeatedly after every screen. Select meaningful regressions according to CLAUDE.md canonical Verification Policy.

Skills read: flutter-add-widget-test and Context7 MCP. Current CLI documentation queried through Context7 `/websites/code_claude`; installed `claude --help` determined actual supported `manual` mode. Native rendering/device evidence must remain explicitly separate from HOST results.
