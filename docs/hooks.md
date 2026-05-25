# Hooks reference

Cursor plugin hooks exchange JSON on stdin/stdout. Scripts run with `CURSOR_PLUGIN_ROOT` set.

## Supported events (common)

| Event | Use case | Output fields |
|-------|----------|---------------|
| `sessionStart` | Inject session context | `additional_context`, `env`, `continue`, `user_message` |
| `beforeSubmitPrompt` | Validate/block prompts | `continue`, `user_message` |
| `preToolUse` / `postToolUse` | Gate or enrich tool calls | `permission`, `updated_input`, `additional_context` |
| `stop` | Follow-up loops | `followup_message` |

Full list: Cursor create-hook skill / official hooks docs.

## Plugin hook path

In `hooks/hooks.json`:

```json
{
  "version": 1,
  "hooks": {
    "sessionStart": [
      { "command": "./hooks/session-start" }
    ]
  }
}
```

For Python hooks:

```json
{
  "command": "python3 \"${CURSOR_PLUGIN_ROOT}/hooks/my-hook.py\""
}
```

## sessionStart pattern (recommended)

Used by superpowers and dormouse-style plugins. Injects into `hooksAdditionalContext` for the composer session:

```bash
printf '{\n  "additional_context": "%s"\n}\n' "$escaped_json_string"
```

## beforeSubmitPrompt caveat

As of current Cursor builds, `beforeSubmitPrompt` **blocks** submissions (`continue: false`) but does **not** merge `additional_context` into agent requests. Use it for validation; use `sessionStart` + rules + skills for skill auto-invocation triggers.

## Best practices

1. Keep hooks **fast** — default timeout 60s; set lower when possible.
2. Always exit `0` on success; exit `2` to block (command hooks).
3. Make scripts executable: `chmod +x hooks/*`.
4. Fail open unless policy requires `failClosed: true`.
5. Test via **Output → Hooks** after reload.

## Example: conditional Python hook

See dormouse `hooks/cyrillic-prompt.py` — detects Unicode range and returns skill content (forward-compatible).
