# Plugin types

Choose components when scaffolding. Each type maps to Cursor extension points.

## Component matrix

| Component | Cursor surface | Template path | Manifest key |
|-----------|----------------|---------------|--------------|
| Skills | Settings → Rules → Agent Decides | `skills/*/SKILL.md` | `"skills": "./skills/"` |
| Rules | Settings → Rules | `rules/*.mdc` | `"rules": "./rules/"` |
| Hooks | Settings → Hooks, Output → Hooks | `hooks/hooks.json` | `"hooks": "./hooks/hooks.json"` |
| MCP | Settings → Tools & MCP | `mcp/server.py`, `.mcp.json` | `"mcpServers": "./.mcp.json"` |

## Recommended combinations

### skills-rules (lightweight)

```bash
./scaffold.sh docs-helper "Docs Helper" "Writing guides" --no-mcp --no-hooks
```

Best for: agent guidance, coding standards, workflows with no runtime deps.

### mcp (tools-only)

```bash
./scaffold.sh data-api "Data API" "Query internal API" --no-skills --no-rules --no-hooks
```

Best for: exposing APIs, CLIs, databases to the agent via MCP tools.

### hooks (automation)

```bash
./scaffold.sh guardrails "Guardrails" "Policy checks" --no-mcp --no-skills
```

Best for: `sessionStart` context injection, `beforeSubmitPrompt` validation, `stop` follow-ups.

Hook output support varies by event — see [hooks.md](hooks.md).

### full (integration)

```bash
./scaffold.sh my-suite "My Suite" "Full integration"
```

Best for: skills + rules + hooks + MCP together (e.g. [dormouse-style plugins](https://github.com/ChuprinaDaria/dormouse)).

## Minimal manifest

For a rules-only plugin, scaffold strips unused keys. Minimum valid manifest:

```json
{
  "name": "my-plugin",
  "displayName": "My Plugin",
  "version": "0.1.0",
  "description": "...",
  "rules": "./rules/"
}
```

## Naming conventions

| Item | Convention | Example |
|------|------------|---------|
| Plugin `name` | kebab-case | `api-bridge` |
| Skill `name` | kebab-case | `api-bridge-skill` |
| MCP server key | same as plugin name | `api-bridge` |
| FastMCP name | same as plugin name | `FastMCP("api-bridge")` |
| Local install dir | same as plugin name | `~/.cursor/plugins/local/api-bridge` |
