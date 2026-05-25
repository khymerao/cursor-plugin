# Code review notes (cursor-plugin template)

Internal review after initial implementation. See commit `refactor: apply code review improvements`.

## Strengths

- Single template + component flags covers all plugin types without duplicate skeletons.
- `lib/common.sh` centralizes plugin name, paths, Python discovery, rsync excludes.
- `install-to-cursor.sh` enforces real copy (not symlink) — matches Cursor runtime.
- `validate.sh` catches common failures before install.
- Docs cover Cursor-specific constraints (Marketplace vs local, MCP absolute paths).

## Issues fixed

| Severity | Issue | Fix |
|----------|-------|-----|
| Critical | `$USE_SKILLS &&` ran command `1` | Use `[[ "$USE_SKILLS" -eq 1 ]]` |
| Important | `validate.sh` grep matched itself | Exclude self from placeholder scan |
| Important | `smoke-test-mcp.py` not executable | `chmod` in scaffold |
| Minor | Typo `SCaffold_AUTHOR_*` | `SCAFFOLD_AUTHOR_*` |
| Minor | Fragile MCP tool introspection | Load-module smoke test only |

## Recommended follow-ups

1. **`install-to-cursor.sh --dry-run`** — print rsync target without copying.
2. **`vendor/` rsync helper** — optional flag for plugins bundling external repos (dormouse pattern).
3. **GitHub Action** — run `scaffold.sh` + `validate.sh` on CI.
4. **`beforeSubmitPrompt` context** — revisit when Cursor merges `additional_context` per message.
5. **Node/Bun MCP variant** — second template under `template-mcp-node/` if needed.

## Plugin type guidance

| Type | Scaffold flags | Primary surface |
|------|----------------|-----------------|
| Agent guidance | `--no-mcp --no-hooks` | skills + rules |
| Tool integration | `--no-skills --no-rules --no-hooks` | MCP |
| Session automation | `--no-mcp` | hooks + rules |
| Full integration | (default) | all |

## Assessment

Template is ready for publishing. Run `./scaffold.sh` → `validate.sh` → `setup.sh` → `install-to-cursor.sh` for any new local plugin.
