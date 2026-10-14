# OmO Native

`link.bash` seeds the unified config and links global instructions,
host-specific MCP profiles, and organisation skills. Runtime state and credentials stay outside
dotfiles. The native executable is installed separately at `~/.local/bin/omo`;
run `omo update` to update it.

## Canonical files

- Shared instructions: `home/shared/agent-instructions-core.md`.
- Initial OMO settings: `home/omo/config/omo.jsonc`.
- Active Native settings: `~/.omo/omo.jsonc` (regular file, deliberately not symlinked).
- Native MCP profiles: `home/omo/config/mcp.{work,personal}.json`.
- Organisation skills: `~/.local/share/onrunning/dev-tooling-config/skills`.

OpenCode V2 does not currently load the published OMO V1 plugin. Use `omo`
for OMO orchestration; OpenCode uses its native agents and Superpowers.
The local ECC hooks have been removed. Context-mode is connected as an OpenCode MCP, without its
V1 automatic capture/routing hooks.

## Native config while evaluating 5.1.30

Native's migration writer refuses a symlinked `~/.omo/omo.jsonc`, even when
an identical regular-file copy has no pending migrations. The advertised
`--omo-senpi-config-startup-disabled` flag did not suppress that startup warning
in the tested release.

While evaluating Native on the work machine, use a regular runtime config.
The linker seeds it only when absent; subsequent link runs preserve all app-side
edits. Shared `AGENTS.md`, MCP profiles, and skills remain linked as before.
There is no automatic synchronization of the runtime unified config back into
dotfiles: review and copy settings you want to retain to `home/omo/config/omo.jsonc`
deliberately. Revisit config synchronization before using Native on another machine.
Model-provider and MCP sign-in remain separate per runtime; never copy credentials
into this repository.

Update the organisation skill checkout with:

```sh
git -C ~/.local/share/onrunning/dev-tooling-config pull --ff-only
```

The Native/OMP MCP profiles are snapshots, not automatically synchronized
with the organisation registry. Refresh them deliberately when the registry
changes, preserving host enablement and environment-variable references.
