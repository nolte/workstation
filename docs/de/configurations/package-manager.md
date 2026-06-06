---
title: Paketmanager (asdf)
audience: [workstation-operator]
content_mode: reference
track: user-docs
source_language: en
last_updated: 2026-06-01
---

# Paketmanager (asdf)

{%
   include-markdown "../../../README.md"
   start="<!--asdf-start-->"
   end="<!--asdf-end-->"
%}


Es wird eine feste Auswahl an Werkzeugen mit fixierten Versionen installiert. Die Versionen werden von [Renovate](https://docs.renovatebot.com/) aktuell gehalten.

```
{%
   include "../../../chezmoi_config/dot_tool-versions"
%}
```
*(`chezmoi_config/dot_tool-versions`)*

Die benötigten Plugins werden in [`chezmoi_config/run_onchange_before_install-add-plugins.sh`](https://github.com/nolte/workstation/blob/develop/chezmoi_config/run_onchange_before_install-add-plugins.sh) konfiguriert.
