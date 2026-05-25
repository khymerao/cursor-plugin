# {{PLUGIN_DISPLAY_NAME}}

Local Cursor plugin generated from [cursor-plugin](https://github.com/khymerao/cursor-plugin).

## Setup

```bash
chmod +x scripts/*.sh
{{SETUP_BLOCK}}
./scripts/install-to-cursor.sh
```

Reload Cursor (**Developer: Reload Window**), then check **Settings → Plugins**.

## Components

{{COMPONENTS_LIST}}

## Verify

- Output → **Cursor Plugins**: `loadUserLocalPlugins (... 1 plugins loaded)`
- **Settings → Plugins** → {{PLUGIN_DISPLAY_NAME}}

See [Cursor local plugin docs](https://cursor.com/docs/plugins) and `docs/` in the cursor-plugin repo.
