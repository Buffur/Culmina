# Synced graph-query MCP startup repair — 2026-10-20

## Result

The installed `graph-query-mcp@synced` **0.1.0** plugin now connects in Claude CLI. Its configured `fastmcp` executable was missing from PATH; no managed plugin file or global MCP configuration needed editing.

The actual `claude mcp get plugin:graph-query-mcp:graph-query` command now reports **Connected**. A separate protocol probe initialized the server, listed all seven graph tools and called `search_nodes` against an explicitly missing repository graph. The tool returned a clear Graph not found response, not a connection failure.

This local NetworkX vault-graph plugin is **not Graphify Cloud**. It does not build or index a repository. No repository `graph.json` was found and none was generated, uploaded or indexed. Productive graph queries remain conditional on an existing, owner-selected graph file; configuring this plugin is not evidence that the remote Graphify workspace has been fixed.

## Installed through normal tool management

Stable releases were checked against official PyPI metadata: FastMCP **4.1.2**, NetworkX **3.7**; the installed Python **3.14.7** satisfies their constraints. Used the existing `uv` tool manager and existing Python; no Python/Flutter/Dart SDK was upgraded.

FastMCP 4.1.2 is a meta-package; its executable belongs to `fastmcp-slim`. The correct supported installation was:

```powershell
uv tool install --python 'C:/Python314/python.exe' --with 'networkx==3.7' --with 'fastmcp==4.1.2' 'fastmcp-slim==4.1.2'
```

This registers `C:/Users/zalub/.local/bin/fastmcp.exe`, in the already-present PATH directory. The managed environment is `C:/Users/zalub/AppData/Roaming/uv/tools/fastmcp-slim`. The original plugin command, `fastmcp run ${CLAUDE_PLUGIN_ROOT}/server.py`, works unchanged.

An earlier scratch venv used to validate dependencies was removed after the managed tool installation succeeded. The unsuccessful meta-package-only `uv tool install fastmcp` attempt is retained in evidence; uv itself removed its incomplete tool entry. `uv tool list` now shows one FastMCP tool registration (`fastmcp-slim`) and its one `fastmcp` executable. The preexisting `graphifyy` tool was left untouched.

## Verification and limitations

- `fastmcp version`: FastMCP 4.1.2 / MCP 2.3.0 / Python 3.14.7.
- `health.json`: MCP initialization, seven tool schemas and explicit no-data response.
- `probe.py`: replayable read-only probe. It scopes graph paths to absent repository locations, avoiding unrelated personal vault contents.
- `requirements.lock.txt`: actual managed tool environment versions.
- `official-package-versions.json`: current stable package metadata and official source URLs.
- `tool-backup.json`: prior tool-list backup location. No previous `fastmcp` executable was overwritten.
- The reported `serverInfo.version` is the FastMCP framework version, not the synced plugin's own 0.1.0 version.

No graph dataset availability is claimed. Existing private/synced plugin version delivery remains managed by its original source; this repair installed its declared dependencies without patching its cache.

Rollback, if needed: `uv tool uninstall fastmcp-slim` removes the new managed environment and its registered executable. No app files or preexisting graph datasets were changed.

## Official sources

- [FastMCP package metadata](https://pypi.org/pypi/fastmcp/json)
- [NetworkX package metadata](https://pypi.org/pypi/networkx/json)
- [uv tool installation](https://docs.astral.sh/uv/guides/tools/)
- [Plugin publisher repository](https://github.com/adelaidasofia/graph-query-mcp)

The plugin's installed manifest/requirements and server source were read before execution. No code or scripts were fetched from an unrelated provider.
