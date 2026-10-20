# Dart MCP repair — 2026-10-20

## Result

Stable `dart_mcp_server` **1.2.1** now starts from an isolated, officially installed tool bundle. MCP initialization, tool listing (14 tools), root registration and read-only analysis of this project's `lib/main.dart` all pass. `analyze_files` returned **No errors** with `applyFixes: false`; direct `dart analyze lib/main.dart` also returned No issues found.

Runtime discovery was actually called: no running debug/DTD processes were found. `listConnectedApps` consequently reports no active app connection. No application was launched, so live widget/runtime-error/hot-reload behavior is not certified.

## Cause and repair

An existing **Claude Desktop** process owns Dart **3.13.2** and the shared `%LOCALAPPDATA%/Dart/install/app-bundles/dart_mcp_server/hosted/1.2.1` executable. The Flutter-bundled Dart **3.13.3** attempts to replace that bundle and fails on the Windows executable lock. The observed processes were Claude Desktop PID 13316, Dart launcher PID 25788 and server PID 26672. They were preserved throughout; no unrelated process was terminated.

The official SDK's install implementation uses `getDartDataHome('install')`; `DART_DATA_HOME` is an officially supported per-process override. The package's latest stable pub.dev release was rechecked as 1.2.1, with Dart constraint `^3.12.0`. The existing frozen SDK 3.13.3 is compatible.

The SDK installed its server through the normal `dart mcp-server` mechanism using **only a tool-specific installation data directory**:

```powershell
$env:DART_DATA_HOME = 'C:/Users/zalub/.codex/tools/dart-mcp-dart-3.13.3-data'
& 'C:/flutter/bin/cache/dart-sdk/bin/dart.exe' mcp-server --help
```

The previous process environment was restored afterward. No SDK, app dependency, shared cache or managed plugin cache was edited. The new tool cache is additional and isolated, not a replacement of the locked user's bundle.

## Recommended MCP configuration

Run the installed native tool directly to avoid concurrent SDK installer replacement attempts:

```json
{
  "command": "C:/Users/zalub/.codex/tools/dart-mcp-dart-3.13.3-data/install/app-bundles/dart_mcp_server/hosted/1.2.1/bundle/bin/dart_mcp_server.exe",
  "args": [
    "--dart-sdk", "C:/flutter/bin/cache/dart-sdk",
    "--flutter-sdk", "C:/flutter"
  ]
}
```

Do **not** set the isolated `DART_DATA_HOME` at runtime when using this direct binary. The default data home preserves discovery of IDE DTD processes; isolating the entire runtime data home would also isolate that discovery. Parent task owns integrating this configuration into agent clients. This child task did not edit global configs.

The direct bundle is pinned to the rechecked latest stable version. A future update should repeat the normal SDK installer in the same isolated cache, then update the path if the package version changes. Do not manually patch its installed files.

## Evidence and limits

- `backup.json`: timestamped backup location and preserved process identity. Shared 1.2.1 cache was copied before creating the isolated installation.
- `pub-latest.json`: official stable package metadata.
- `install-output.txt`: normal SDK installation output and supported flags.
- `health.json`: successful direct-binary MCP responses and runtime discovery.
- `tools-schemas.json`: actual loaded tool contracts.
- `direct-probe.py`: replayable read-only health probe, uses the current repository's `lib/` root and analyzes `main.dart`; leaves no server process behind.
- `initial-analysis-timeout.json`: preserved failed broader-root attempt. Startup/tool listing passed, but the first whole-workspace LSP wait exceeded 90 seconds. The successful bounded diagnostics do not establish a full-repository analyzer pass.

Global/desktop processes may need client restart to load parent task's new route. The bare `dart mcp-server` command with the original shared data home can still collide while the existing Desktop server holds it; the verified client route avoids that path.

Rollback: revert the parent's MCP configuration to its saved prior version. The isolated tool directory can then be removed when no client is using it; the original shared tool was never changed. Do not remove active/foreign caches or terminate Desktop to roll back.

## Official sources

- [Dart and Flutter AI setup](https://docs.flutter.dev/ai/get-started) — current MCP/tool guidance, retrieved through Context7 and primary sources.
- [Package metadata](https://pub.dev/api/packages/dart_mcp_server) — latest stable 1.2.1 and SDK constraint.
- [SDK install directories](https://github.com/dart-lang/sdk/blob/main/pkg/dartdev/lib/src/install/file_system.dart) — app-bundle layout and installation data home.
- [Dart data home](https://github.com/dart-lang/sdk/blob/main/pkg/dart_data_home/lib/dart_data_home.dart) — `DART_DATA_HOME` override.
