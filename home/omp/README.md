# OMP configuration

`link.bash` selects the complete work or personal MCP profile and links it as
`~/.omp/agent/mcp.json`, OMP's native managed configuration. Disabled entries
remain visible as **inactive** in `/mcp list` and can be selected with
`/mcp enable <name>`.

Do not split managed inventory into `~/.omp/agent/.mcp.json`: OMP 18.10.1
discovers that file through its capability loader, which suppresses disabled
servers before they reach the runtime list. The linker backs up the legacy
dotfiles-owned `.mcp.json` symlink while preserving unrelated user files.

After changing profiles or links, run `/mcp reload`, then `/mcp list`.
Enabling a server does not authenticate it; use `/mcp reauth <name>` when OAuth
is required. Credentials stay in OMP's runtime auth storage, not dotfiles.

Shared instructions come from `home/shared/agent-instructions-core.md`.
Organisation and vault skills are selected through `skills.customDirectories`
in `config/config.yml`.
