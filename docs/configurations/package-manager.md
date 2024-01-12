# Package manager (asdf)

{%
   include-markdown "../../README.md"
   start="<!--asdf-start-->"
   end="<!--asdf-end-->"
%}


Install a preselected combination of tools with pinned versions. The Versions will be keep up to date from [Renovate](https://docs.renovatebot.com/).

```
{%
   include "../../chezmoi_config/dot_tool-versions"
%}
```
*(`../chezmoi_config/dot_tool-versions`)*

You can configure the Required Plugins at [`chezmoi_config/run_onchange_before_install-add-plugins.sh`](../chezmoi_config/run_onchange_before_install-add-plugins.sh).
