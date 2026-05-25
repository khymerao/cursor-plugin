# Best practices

Lessons from production local plugins (including dormouse).

## Development workflow

```text
edit template or plugin → validate.sh → install-to-cursor.sh → Reload Window → test
```

Never symlink into `~/.cursor/plugins/local/`.

## Manifest

- Always set `"name"` (kebab-case) — used for install path and MCP key.
- Reference MCP explicitly: `"mcpServers": "./.mcp.json"`.
- Omit unused keys (scaffold does this) — cleaner Settings UI.

## Skills

- **`description`** is the auto-selection trigger — be specific, include WHEN terms.
- `disable-model-invocation: false` (default) — allow Agent Decides.
- `disable-model-invocation: true` — manual `/skill` or hook-driven only.
- One skill per workflow; split large skills into `reference.md`.

## Rules

- `alwaysApply: true` — global policy (use sparingly).
- `alwaysApply: false` — agent-requestable; good default.
- Rules complement skills; avoid duplicating full skill content in rules.

## MCP

- Python 3.11+ with FastMCP for stdio servers.
- Generate `.mcp.json` with **absolute paths** after venv exists.
- Include `"type": "stdio"` in MCP config.
- Add `scripts/smoke-test-mcp.py` or similar CI check.
- Use `mcp/post-setup.sh` for asset downloads / codegen — keep `setup.sh` generic.

## Hooks

- Prefer `sessionStart` for persistent session context.
- Use `beforeSubmitPrompt` only for blocking/validation until Cursor merges context.
- Use `${CURSOR_PLUGIN_ROOT}` for portable paths in plugin hooks.

## Security

- Do not commit `.mcp.json` (machine-specific paths).
- Do not commit `mcp/.venv/`.
- Avoid secrets in rules/skills — use env vars in MCP server.
- Review hook scripts that run on every prompt — no network unless necessary.

## Vendor dependencies

For plugins wrapping external repos:

```text
vendor/<lib>/     # copied at install time
mcp/post-setup.sh # install editable / prefetch assets
```

See dormouse `install-to-cursor.sh` for rsync-vendor pattern.

## Testing checklist

- [ ] `./scripts/validate.sh`
- [ ] `./scripts/install-to-cursor.sh`
- [ ] Reload Window
- [ ] Cursor Plugins log: 1 plugin loaded
- [ ] Skill visible in Agent Decides
- [ ] MCP tools callable (if enabled)
- [ ] Hooks fire (Output → Hooks)

## Universal scaffold flags

| Goal | Command |
|------|---------|
| Docs / standards only | `--no-mcp --no-hooks` |
| API tool only | `--no-skills --no-rules --no-hooks` |
| Policy automation | `--no-mcp` |
| Full stack | default (all components) |
