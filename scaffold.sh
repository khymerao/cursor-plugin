#!/usr/bin/env bash
# Bootstrap a new local Cursor plugin from template/
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./scaffold.sh <plugin-name> [display-name] [description] [options]

Options (all enabled by default; pass --no-* to disable):
  --skills       Include skills/ and manifest entry
  --rules        Include rules/ and manifest entry
  --hooks        Include hooks/ and manifest entry
  --mcp          Include mcp/ server and manifest entry
  --no-skills    Omit skills
  --no-rules     Omit rules
  --no-hooks     Omit hooks
  --no-mcp       Omit MCP server

  --output-dir   Output directory (default: ../<plugin-name>)
  --author-name  Author name for plugin.json
  --author-email Author email for plugin.json

Examples:
  ./scaffold.sh my-tool "My Tool" "Does something useful"
  ./scaffold.sh api-bridge "API Bridge" "MCP bridge" --no-hooks --no-skills
  ./scaffold.sh lint-bot "Lint Bot" "Lint helper" --no-mcp
EOF
}

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE="$REPO_ROOT/template"

if [[ ! -d "$TEMPLATE" ]]; then
  echo "Missing template/ directory." >&2
  exit 1
fi

PLUGIN_NAME="${1:-}"
if [[ -z "$PLUGIN_NAME" || "$PLUGIN_NAME" == "-h" || "$PLUGIN_NAME" == "--help" ]]; then
  usage
  exit 0
fi
shift

DISPLAY_NAME="${1:-$PLUGIN_NAME}"
[[ $# -gt 0 ]] && shift
DESCRIPTION="${1:-Local Cursor plugin: $DISPLAY_NAME}"
[[ $# -gt 0 ]] && shift

AUTHOR_NAME="${SCAFFOLD_AUTHOR_NAME:-}"
AUTHOR_EMAIL="${SCAFFOLD_AUTHOR_EMAIL:-}"
OUTPUT_DIR=""
USE_SKILLS=1
USE_RULES=1
USE_HOOKS=1
USE_MCP=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skills) USE_SKILLS=1 ;;
    --rules) USE_RULES=1 ;;
    --hooks) USE_HOOKS=1 ;;
    --mcp) USE_MCP=1 ;;
    --no-skills) USE_SKILLS=0 ;;
    --no-rules) USE_RULES=0 ;;
    --no-hooks) USE_HOOKS=0 ;;
    --no-mcp) USE_MCP=0 ;;
    --output-dir)
      shift
      OUTPUT_DIR="${1:?--output-dir requires a path}"
      ;;
    --author-name)
      shift
      AUTHOR_NAME="${1:?--author-name requires a value}"
      ;;
    --author-email)
      shift
      AUTHOR_EMAIL="${1:?--author-email requires a value}"
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
  shift
done

if [[ ! "$PLUGIN_NAME" =~ ^[a-z][a-z0-9-]*$ ]]; then
  echo "Plugin name must be lowercase kebab-case (e.g. my-plugin)." >&2
  exit 1
fi

OUTPUT_DIR="${OUTPUT_DIR:-$(cd "$REPO_ROOT/.." && pwd)/$PLUGIN_NAME}"

if [[ -e "$OUTPUT_DIR" ]]; then
  echo "Output directory already exists: $OUTPUT_DIR" >&2
  exit 1
fi

PLUGIN_NAME_SNAKE="${PLUGIN_NAME//-/_}"

mkdir -p "$OUTPUT_DIR"
rsync -a \
  --exclude 'mcp/.venv' \
  "$TEMPLATE/" "$OUTPUT_DIR/"

# Rename placeholder skill directory
if [[ -d "$OUTPUT_DIR/skills/{{PLUGIN_NAME}}-skill" ]]; then
  mv "$OUTPUT_DIR/skills/{{PLUGIN_NAME}}-skill" "$OUTPUT_DIR/skills/${PLUGIN_NAME}-skill"
fi

substitute_file() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  python3 - "$file" <<PY
import pathlib, sys
path = pathlib.Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
repl = {
    "{{PLUGIN_NAME}}": "$PLUGIN_NAME",
    "{{PLUGIN_DISPLAY_NAME}}": """$DISPLAY_NAME""",
    "{{PLUGIN_DESCRIPTION}}": """$DESCRIPTION""",
    "{{PLUGIN_AUTHOR_NAME}}": """${AUTHOR_NAME:-Your Name}""",
    "{{PLUGIN_AUTHOR_EMAIL}}": """${AUTHOR_EMAIL:-you@example.com}""",
    "{{PLUGIN_NAME_SNAKE}}": "$PLUGIN_NAME_SNAKE",
    "{{COMPONENT_SKILLS}}": "$([ "$USE_SKILLS" -eq 1 ] && echo true || echo false)",
    "{{COMPONENT_RULES}}": "$([ "$USE_RULES" -eq 1 ] && echo true || echo false)",
    "{{COMPONENT_HOOKS}}": "$([ "$USE_HOOKS" -eq 1 ] && echo true || echo false)",
    "{{COMPONENT_MCP}}": "$([ "$USE_MCP" -eq 1 ] && echo true || echo false)",
}
for k, v in repl.items():
    text = text.replace(k, v)
path.write_text(text, encoding="utf-8")
PY
}

while IFS= read -r -d '' f; do
  substitute_file "$f"
done < <(find "$OUTPUT_DIR" -type f \( \
  -name '*.json' -o -name '*.md' -o -name '*.mdc' -o -name '*.yaml' -o -name '*.yml' \
  -o -name '*.py' -o -name '*.sh' -o -name 'session-start' -o -name 'hooks.json' \
  \) -print0)

# Rename rule file if placeholder in filename remained
if [[ -f "$OUTPUT_DIR/rules/{{PLUGIN_NAME}}-usage.mdc" ]]; then
  mv "$OUTPUT_DIR/rules/{{PLUGIN_NAME}}-usage.mdc" "$OUTPUT_DIR/rules/${PLUGIN_NAME}-usage.mdc"
fi

# Strip disabled components
strip_manifest_key() {
  local key="$1"
  python3 - "$OUTPUT_DIR/.cursor-plugin/plugin.json" "$key" <<'PY'
import json, sys
path, key = sys.argv[1], sys.argv[2]
data = json.loads(open(path, encoding="utf-8").read())
data.pop(key, None)
open(path, "w", encoding="utf-8").write(json.dumps(data, indent=2, ensure_ascii=False) + "\n")
PY
}

[[ "$USE_SKILLS" -eq 0 ]] && rm -rf "$OUTPUT_DIR/skills" && strip_manifest_key skills
[[ "$USE_RULES" -eq 0 ]] && rm -rf "$OUTPUT_DIR/rules" && strip_manifest_key rules
[[ "$USE_HOOKS" -eq 0 ]] && rm -rf "$OUTPUT_DIR/hooks" && strip_manifest_key hooks
if [[ "$USE_MCP" -eq 0 ]]; then
  rm -rf "$OUTPUT_DIR/mcp"
  strip_manifest_key mcpServers
  rm -f "$OUTPUT_DIR/scripts/run-mcp-server.sh" "$OUTPUT_DIR/scripts/smoke-test-mcp.py"
fi

# README blocks
COMPONENTS_LIST=""
[[ "$USE_SKILLS" -eq 1 ]] && COMPONENTS_LIST="${COMPONENTS_LIST}\n- Skills (\`skills/\`)"
[[ "$USE_RULES" -eq 1 ]] && COMPONENTS_LIST="${COMPONENTS_LIST}\n- Rules (\`rules/\`)"
[[ "$USE_HOOKS" -eq 1 ]] && COMPONENTS_LIST="${COMPONENTS_LIST}\n- Hooks (\`hooks/\`)"
[[ "$USE_MCP" -eq 1 ]] && COMPONENTS_LIST="${COMPONENTS_LIST}\n- MCP server (\`mcp/\`)"

SETUP_BLOCK="./scripts/setup.sh    # MCP venv + .mcp.json"
if [[ "$USE_MCP" -eq 0 ]]; then
  SETUP_BLOCK="# (no MCP — skip setup.sh)"
fi

python3 - "$OUTPUT_DIR/README.md" <<PY
import pathlib, sys
path = pathlib.Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
text = text.replace("{{SETUP_BLOCK}}", """$SETUP_BLOCK""")
text = text.replace("{{COMPONENTS_LIST}}", """${COMPONENTS_LIST:-\n- (minimal plugin)}""")
path.write_text(text, encoding="utf-8")
PY

chmod +x "$OUTPUT_DIR/scripts/"*.sh 2>/dev/null || true
chmod +x "$OUTPUT_DIR/scripts/"*.py 2>/dev/null || true
chmod +x "$OUTPUT_DIR/hooks/"* 2>/dev/null || true
chmod +x "$OUTPUT_DIR/mcp/"*.sh 2>/dev/null || true

cat <<EOF

Scaffolded plugin: $DISPLAY_NAME
Location: $OUTPUT_DIR

Components:
  skills: $([ "$USE_SKILLS" -eq 1 ] && echo yes || echo no)
  rules:  $([ "$USE_RULES" -eq 1 ] && echo yes || echo no)
  hooks:  $([ "$USE_HOOKS" -eq 1 ] && echo yes || echo no)
  mcp:    $([ "$USE_MCP" -eq 1 ] && echo yes || echo no)

Next:
  cd "$OUTPUT_DIR"
  git init && git add . && git commit -m "chore: initial plugin scaffold"
  $([ "$USE_MCP" -eq 1 ] && echo "./scripts/setup.sh")
  ./scripts/install-to-cursor.sh

EOF
