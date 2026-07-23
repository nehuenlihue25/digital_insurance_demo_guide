# OmniStudio MCP — setup notes

The OmniStudio MCP (`@salesforce/omnistudio-mcp`) lets Claude Code introspect and modify OmniScripts, DataRaptors, Integration Procedures and FlexCards in a Digital Insurance org. It's essential for Block 1 of this demo because the Quote flow is backed by OmniScript `CreateQuoteDCT2` and its supporting DataRaptors.

## The `sfcli: true` trap

The MCP has two authentication modes:

- **`sfcli: true`** (the default in the docs) — the MCP shells out to `sf org auth show-access-token` on startup.
- **`sfcli: false`** — the MCP reads `SF_ACCESS_TOKEN` and `SF_INSTANCE_URL` from its environment.

The `sfcli: true` path **does not work in practice** as of the current `sf` CLI:

- `sf org auth show-access-token` requires `--no-prompt` or `--json` to skip the interactive "Are you sure you want to display the access token?" confirmation.
- The MCP subprocess doesn't pass either flag.
- The subprocess has no TTY, so it hangs on the confirmation and eventually exits with code 2.
- **No environment variable bypasses this** — verified: the default org resolves cleanly (`sf org display` returns exit 0), so the problem is purely in the interactive confirmation of `show-access-token`.

## The `sfcli: false` path (recommended)

Skip the MCP's built-in auth and inject the access token via environment variables. The token is bounded by the org session and does not need to be re-generated between Claude Code sessions unless the org expires.

### Setting it up without exposing the token

The helper at [`demo-metadata/scripts/setup-omnistudio-mcp.sh`](../scripts/setup-omnistudio-mcp.sh) reads the token via `sf org display --json`, writes a `.mcp.json` in the current directory, and never prints the token to stdout. Usage:

```bash
cd <your project root>
./demo-metadata/scripts/setup-omnistudio-mcp.sh <org-alias>
```

The generated `.mcp.json` looks like this (with the token filled in):

```json
{
  "mcpServers": {
    "omnistudio-mcp": {
      "command": "npx",
      "args": ["-y", "@salesforce/omnistudio-mcp"],
      "env": {
        "SF_AUTOUPDATE_DISABLE": "true",
        "SF_DISABLE_LOG_FILE": "true",
        "SF_ACCESS_TOKEN": "00Dxxxx…",
        "SF_INSTANCE_URL": "https://your-org.my.salesforce.com"
      }
    }
  }
}
```

After running the helper, **restart Claude Code once** so the MCP subprocess picks up the new env vars.

### If you prefer to do it by hand

```bash
SF_TEMP_SHOW_SECRETS=true SF_DISABLE_LOG_FILE=true python3 - <<'PY'
import json, subprocess
r = json.loads(subprocess.check_output(
    ["sf","org","display","--target-org","<your-alias>","--verbose","--json"]))["result"]
cfg = {
  "mcpServers": {
    "omnistudio-mcp": {
      "command": "npx",
      "args": ["-y", "@salesforce/omnistudio-mcp"],
      "env": {
        "SF_AUTOUPDATE_DISABLE": "true",
        "SF_DISABLE_LOG_FILE": "true",
        "SF_ACCESS_TOKEN": r["accessToken"],
        "SF_INSTANCE_URL": r["instanceUrl"],
      }
    }
  }
}
open(".mcp.json","w").write(json.dumps(cfg, indent=2))
print("OK — token injected. instance:", r["instanceUrl"])
PY
```

## When to re-generate `.mcp.json`

The injected `SF_ACCESS_TOKEN` is the same token the CLI uses — bound to the org session. Regenerate when:

- The Storm org expires and you provision a new IDO
- You switch which alias points at the target org
- You get 401 responses from the MCP tools

For everyday work on the same org, one generation is enough.

## Related

- [[digital-insurance-gotchas]] section 6 — MDAPI validation traps for reports/CRTs
- [[sf-cli-sandbox-quirks]] — related quirks with `sf` CLI + sandbox environments
- [[claude-code-lessons]] — meta-lessons on Claude Code sessions
