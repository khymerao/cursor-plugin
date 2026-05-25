# Local install guide

How Cursor loads **local** plugins and how this template installs them.

## Install path

```text
~/.cursor/plugins/local/<plugin-name>/
  .cursor-plugin/plugin.json    # required manifest
  skills/ rules/ hooks/ mcp/    # optional components
  .mcp.json                     # generated; referenced by manifest
```

Set a custom base directory:

```bash
export CURSOR_LOCAL_PLUGINS_DIR="$HOME/.cursor/plugins/local"
./scripts/install-to-cursor.sh
```

## Why rsync, not symlink

Cursor's loader skips **symlinked** plugin directories (`lstat().isSymbolicLink()`). Official docs mention symlinks for dev iteration, but the runtime rejects them.

Always use:

```bash
./scripts/install-to-cursor.sh   # copies real files
```

Re-run after every change during development.

## Reload and verify

1. **Developer: Reload Window**
2. **Output → Cursor Plugins** — expect `loadUserLocalPlugins (... N plugins loaded)`
3. **Settings → Plugins** — plugin card visible
4. **Settings → Tools & MCP** — enable MCP server (if present)
5. **Settings → Hooks** — plugin hooks listed

## MCP config

`.mcp.json` is **gitignored** and regenerated with **absolute paths**:

```bash
./scripts/setup.sh                  # creates mcp/.venv
./scripts/generate-mcp-config.sh    # writes .mcp.json
```

Required shape:

```json
{
  "mcpServers": {
    "my-plugin": {
      "type": "stdio",
      "command": "/abs/path/to/mcp/.venv/bin/python",
      "args": ["/abs/path/to/mcp/server.py"]
    }
  }
}
```

Manifest must reference it explicitly:

```json
"mcpServers": "./.mcp.json"
```

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `0 plugins loaded` | Not a real directory; re-run install (no symlink) |
| Plugin missing in Settings | Invalid `plugin.json`; run `./scripts/validate.sh` |
| MCP not listed | Enable in Tools & MCP; check `.mcp.json` paths |
| Hooks silent | Check Output → Hooks; ensure scripts are executable |
| MCP crash on start | Run `./scripts/run-mcp-server.sh` in terminal |

## Marketplace vs local

| Method | Works for local? |
|--------|------------------|
| `/add-plugin name` | No — Marketplace only |
| `~/.cursor/plugins/local/` | Yes |
| Project `.cursor/mcp.json` | MCP only, no plugin UI |
