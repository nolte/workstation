---
title: GitHub MCP
audience: [workstation-operator]
content_mode: reference
track: user-docs
source_language: en
last_updated: 2026-07-11
---

# GitHub MCP server

{%
   include-markdown "../../../README.md"
   start="<!--github-mcp-start-->"
   end="<!--github-mcp-end-->"
%}

The entry merged into `~/.claude.json` by `chezmoi_config/modify_dot_claude.json`:

```json
{
  "type": "http",
  "url": "https://api.githubcopilot.com/mcp/",
  "headers": {
    "Authorization": "Bearer ${GITHUB_MCP_PAT}"
  }
}
```

Claude Code expands `${GITHUB_MCP_PAT}` from the environment at connect time. Verify the connection with `claude mcp list`; the `github` server should report `✔ Connected`.
