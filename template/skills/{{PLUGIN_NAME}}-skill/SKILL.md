---
name: {{PLUGIN_NAME}}-skill
description: >-
  Use when working with {{PLUGIN_DISPLAY_NAME}}. Replace this description with
  clear trigger conditions so Agent Decides can auto-select this skill.
disable-model-invocation: false
---

# {{PLUGIN_DISPLAY_NAME}} Skill

## When to use

- User asks about {{PLUGIN_DISPLAY_NAME}} functionality
- You need plugin-specific workflow guidance

## Workflow

1. Read the user request.
2. Follow project conventions.
3. Use MCP tools from this plugin when applicable.

## Notes

- Set `disable-model-invocation: true` to restrict skill to manual `/skill` invocation only.
- Keep descriptions specific — vague skills are rarely auto-selected.
