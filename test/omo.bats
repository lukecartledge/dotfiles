#!/usr/bin/env bats

load helpers/setup

@test "OpenCode keeps Superpowers without the retired ECC hooks" {
  [ ! -f "$REPO_ROOT/home/opencode/config/plugins/ecc-hooks/index.ts" ]
  [ ! -f "$REPO_ROOT/test/ecc-hooks.test.ts" ]
  run node -e '
    const fs = require("fs");
    const d = JSON.parse(fs.readFileSync(process.env.REPO_ROOT + "/home/opencode/config/opencode.json", "utf8"));
    if (!d.plugins.includes("superpowers@git+https://github.com/obra/superpowers.git")) throw Error("Superpowers missing");
    if (d.plugins.some(p => typeof p === "string" && p.includes("ecc"))) throw Error("ECC still configured");
  '
  [ "$status" -eq 0 ]
}

@test "OpenCode explicitly restores the former OMO search MCPs" {
  run node -e '
    const fs = require("fs");
    const d = JSON.parse(fs.readFileSync(process.env.REPO_ROOT + "/home/opencode/config/opencode.json", "utf8"));
    const urls = {context7: "https://mcp.context7.com/mcp", grep_app: "https://mcp.grep.app", websearch: "https://mcp.exa.ai/mcp?tools=web_search_exa"};
    const servers = d.mcp?.servers || d.mcp || {};
    for (const [name, url] of Object.entries(urls)) {
      const v = servers[name];
      if (!v || v.url !== url || v.disabled === true || v.oauth !== false) throw Error(name + " not restored");
    }
  '
  [ "$status" -eq 0 ]
}

@test "tmux config enables modified keys with CSI-u encoding" {
  run grep -E '^set -g extended-keys on$' "$REPO_ROOT/home/tmux/tmux.conf"
  [ "$status" -eq 0 ]
  run grep -E '^set -g extended-keys-format csi-u$' "$REPO_ROOT/home/tmux/tmux.conf"
  [ "$status" -eq 0 ]
}
