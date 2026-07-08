# sf CLI in a Sandbox Environment (Claude Code) — Quirks

This document is specifically for SEs/devs using Claude Code with sandbox restrictions enabled (denyWithinAllow over `~/.sfdx/` and `~/.sf/`).

## Quirk 1: SF_DISABLE_LOG_FILE=true is mandatory

Without this env var, sf CLI throws EPERM when trying to create the log file at `~/.sf/sf-YYYY-MM-DD.log`. Prefix every invocation:
```bash
export SF_DISABLE_LOG_FILE=true
sf data query --target-org $ORG --query "..."
```

Or set it in the project's `.envrc` / bashrc.

## Quirk 2: sf project deploy start DOES NOT work

Blocks with `EPERM: operation not permitted, mkdir '/Users/nlobo/.sfdx/<username>.json.lock'`. Sandbox denyWithinAllow blocks writes to `~/.sfdx/`.

**Workaround**: deploy directly via SOAP Metadata API with curl:
1. Get accessToken via `sf org display --json --verbose`
2. Zip the package
3. Base64 encode
4. Wrap in a SOAP envelope
5. POST to `{instance}/services/Soap/m/62.0` with SOAPAction: deploy
6. Poll checkDeployStatus with asyncId

See `../scripts/05-block6-deploy-reports.sh` for the full implementation.

## Quirk 3: Intermittent DomainNotFoundError

After >30 min idle, sf CLI starts returning `DomainNotFoundError` for all orgs. The fix is:
```bash
export SFDX_DISABLE_DNS_CHECK=true
```

## Quirk 4: Session expired mid-flow

If the Claude Code session + sandbox goes >30 min idle, the cached access token expires. `sf CLI` attempts a refresh which fails due to the `~/.sfdx/` write block. Fix: run `sf org login web` MANUALLY outside the sandbox (in another terminal), then re-enter Claude Code.

## Quirk 5: --json output structure

Some outputs are `{result: {...}}`, others are a direct array `[...]`. Examples:
- `sf org display --json`: `{result: {accessToken, instanceUrl, ...}}`
- `sf data query --json`: `{result: {records: [...], done: true, ...}}`
- Tooling API via direct curl: can be an error array `[{message, errorCode}]` or `{records: [...]}`

Always parse defensively with python:
```python
d = json.load(sys.stdin)
if isinstance(d, list): # error array or direct list
    ...
elif isinstance(d, dict):
    records = d.get('records') or d.get('result', {}).get('records', [])
```

## Quirk 6: sf data query --result-format csv tail parsing

`sf data query ... --result-format csv | tail -1` is idiomatic for grabbing 1 value. But when there are 0 records, tail returns the header or empty. Verify with:
```bash
if [ -z "$VAR" ] || [ "$VAR" = "Id" ]; then
  echo "No results found"; exit 1
fi
```

## Quirk 7: COUNT() queries via grep

`sf data query "SELECT COUNT() FROM X"` does not return a table with a "COUNT" column — it returns the message "Total number of records retrieved: N". Parse with:
```bash
COUNT=$(sf data query ... | grep -oE 'retrieved: [0-9]+' | tail -1 | grep -oE '[0-9]+')
```

## Quirk 8: Field aliases in SOQL

Salesforce SOQL only allows aliases in aggregate queries. `SELECT Id, Name coverage FROM X` fails with "only aggregate expressions use field aliasing". Fix: use the real field names or subselects.

## Quirk 9: sf CLI --api-version 63.0

To see RCA fields on Quote/QuoteLineItem (SegmentIdentifier, RevenueCloudPackagingFlag, etc.), force a high API version:
```bash
sf data query --api-version 63.0 --query "SELECT SegmentIdentifier FROM QuoteLineItem"
```
Without this, the default v50 API hides the fields.

## Quirk 10: Bash heredocs with vars

When writing SOAP envelopes with inline $TOKEN, $INST, use a regular heredoc (not <<'EOF'):
```bash
cat > /tmp/soap.xml <<EOF
<sessionId>$TOKEN</sessionId>
EOF
```
