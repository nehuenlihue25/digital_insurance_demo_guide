#!/usr/bin/env bash
# ============================================================================
# setup-omnistudio-mcp.sh
# ----------------------------------------------------------------------------
# Generates a `.mcp.json` at the current working directory (project root)
# with an OmniStudio MCP server config that uses SF_ACCESS_TOKEN and
# SF_INSTANCE_URL environment variables — the `sfcli: true` path is
# broken because `sf org auth show-access-token` blocks on an interactive
# confirmation the MCP subprocess can't answer.
#
# The token is read via `sf org display --json` and injected into
# `.mcp.json` in one shot — it never appears in stdout, in the shell
# prompt or in your history.
#
# Usage:
#   ./setup-omnistudio-mcp.sh <org-alias>
#   ORG_ALIAS=<alias> ./setup-omnistudio-mcp.sh
#
# After running:
#   Restart Claude Code once so the MCP subprocess picks up the new
#   env vars.
#
# When to re-run:
#   - Storm org expired → new IDO provisioned
#   - You switched which alias points at the target org
#   - MCP tools return 401
#
# See demo-metadata/learnings/omnistudio-mcp-setup.md for the full
# write-up.
# ============================================================================

set -euo pipefail

export SF_DISABLE_LOG_FILE=true
export SF_TEMP_SHOW_SECRETS=true

ORG_ALIAS="${1:-${ORG_ALIAS:-}}"
if [[ -z "${ORG_ALIAS}" ]]; then
  echo "ERROR: pass the org alias as \$1 or export ORG_ALIAS=<alias>." >&2
  echo "Example: ./setup-omnistudio-mcp.sh ins-alfa" >&2
  exit 1
fi

echo "[setup-omnistudio-mcp] Reading access token for org alias '${ORG_ALIAS}'..."

python3 - "$ORG_ALIAS" <<'PY'
import json, re, subprocess, sys
alias = sys.argv[1]
raw = subprocess.check_output(
    ["sf", "org", "display", "--target-org", alias, "--verbose", "--json"],
    text=True,
)
# Strip any ANSI escape sequences the CLI may inject
clean = re.sub(r"\x1b\[[0-9;]*[a-zA-Z]", "", raw)
data = json.loads(clean)
result = data.get("result", {})
token = result.get("accessToken")
instance = result.get("instanceUrl")
if not token or not instance:
    print("ERROR: could not read accessToken/instanceUrl from sf org display.", file=sys.stderr)
    print("Make sure SF_TEMP_SHOW_SECRETS=true is exported and the org is authenticated.", file=sys.stderr)
    sys.exit(1)

cfg = {
    "mcpServers": {
        "omnistudio-mcp": {
            "command": "npx",
            "args": ["-y", "@salesforce/omnistudio-mcp"],
            "env": {
                "SF_AUTOUPDATE_DISABLE": "true",
                "SF_DISABLE_LOG_FILE": "true",
                "SF_ACCESS_TOKEN": token,
                "SF_INSTANCE_URL": instance,
            },
        }
    }
}

with open(".mcp.json", "w") as f:
    json.dump(cfg, f, indent=2)
    f.write("\n")

print(f"OK — token injected into .mcp.json. instance: {instance}")
print("Next step: restart Claude Code once so the MCP subprocess picks up the new env vars.")
PY
