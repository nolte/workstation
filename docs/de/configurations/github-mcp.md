---
title: GitHub MCP server
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

Der Eintrag, den `chezmoi_config/modify_dot_claude.json` in `~/.claude.json` einfügt:

```json
{
  "type": "http",
  "url": "https://api.githubcopilot.com/mcp/",
  "headers": {
    "Authorization": "Bearer ${GITHUB_MCP_PAT}"
  }
}
```

Claude Code löst `${GITHUB_MCP_PAT}` beim Verbindungsaufbau aus der Umgebung auf. Prüfe die Verbindung mit `claude mcp list`; der `github`-Server sollte `✔ Connected` melden.
