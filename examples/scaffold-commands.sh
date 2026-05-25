# Example: skills + rules only (no MCP, no hooks)

./scaffold.sh docs-helper "Docs Helper" "Team documentation standards" \
  --no-mcp --no-hooks

# Example: MCP tools only

./scaffold.sh api-bridge "API Bridge" "Internal HTTP API" \
  --no-skills --no-rules --no-hooks

# Example: full stack (default)

./scaffold.sh my-suite "My Suite" "Skills, rules, hooks, and MCP"
