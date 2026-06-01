---
title: Package manager (asdf)
audience: [workstation-operator]
content_mode: reference
track: user-docs
last_updated: 2026-06-01
---

# Package manager (asdf)

{%
   include-markdown "../../../README.md"
   start="<!--asdf-start-->"
   end="<!--asdf-end-->"
%}


Install a preselected combination of tools with pinned versions. The versions are kept up to date by [Renovate](https://docs.renovatebot.com/).

```
{%
   include "../../../chezmoi_config/dot_tool-versions"
%}
```
*(`chezmoi_config/dot_tool-versions`)*

Configure the required plugins in [`chezmoi_config/run_onchange_before_install-add-plugins.sh`](https://github.com/nolte/workstation/blob/develop/chezmoi_config/run_onchange_before_install-add-plugins.sh).
