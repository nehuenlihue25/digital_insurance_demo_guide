# sf CLI en Sandbox Environment (Claude Code) — Quirks

Este documento es específico para SEs/devs que usan Claude Code con sandbox restrictions habilitadas (denyWithinAllow sobre `~/.sfdx/` y `~/.sf/`).

## Quirk 1: SF_DISABLE_LOG_FILE=true es obligatorio

Sin este env var, sf CLI tira EPERM al intentar crear el log file en `~/.sf/sf-YYYY-MM-DD.log`. Prefijo cada invocación:
```bash
export SF_DISABLE_LOG_FILE=true
sf data query --target-org $ORG --query "..."
```

O poner en `.envrc` / bashrc del proyecto.

## Quirk 2: sf project deploy start NO funciona

Bloquea con `EPERM: operation not permitted, mkdir '/Users/nlobo/.sfdx/<username>.json.lock'`. Sandbox denyWithinAllow bloquea escrituras en `~/.sfdx/`.

**Workaround**: deploy via SOAP Metadata API directo con curl:
1. Get accessToken via `sf org display --json --verbose`
2. Zip el package
3. Base64 encode
4. Wrap en SOAP envelope
5. POST a `{instance}/services/Soap/m/62.0` con SOAPAction: deploy
6. Poll checkDeployStatus con asyncId

Ver `../scripts/05-bloque6-deploy-reports.sh` para implementación completa.

## Quirk 3: DomainNotFoundError intermitente

Después de idle >30 min, sf CLI empieza a devolver `DomainNotFoundError` para todos los orgs. El fix es:
```bash
export SFDX_DISABLE_DNS_CHECK=true
```

## Quirk 4: Session expired mid-flow

Si Claude Code sesión + sandbox toma >30 min de idle, el access token cachedo expira. `sf CLI` intenta refresh que falla por `~/.sfdx/` write block. Fix: hacer `sf org login web` MANUALMENTE fuera del sandbox (en otra terminal), reingresar Claude Code.

## Quirk 5: --json output structure

Algunos outputs son `{result: {...}}`, otros son array directo `[...]`. Ejemplos:
- `sf org display --json`: `{result: {accessToken, instanceUrl, ...}}`
- `sf data query --json`: `{result: {records: [...], done: true, ...}}`
- Tooling API vía curl directo: puede ser array de errores `[{message, errorCode}]` o `{records: [...]}`

Siempre parse con python defensive:
```python
d = json.load(sys.stdin)
if isinstance(d, list): # error array or direct list
    ...
elif isinstance(d, dict):
    records = d.get('records') or d.get('result', {}).get('records', [])
```

## Quirk 6: sf data query --result-format csv tail parsing

`sf data query ... --result-format csv | tail -1` es idiomático para agarrar 1 valor. Pero cuando hay 0 records, tail devuelve el header o vacío. Verificar con:
```bash
if [ -z "$VAR" ] || [ "$VAR" = "Id" ]; then
  echo "No results found"; exit 1
fi
```

## Quirk 7: COUNT() queries via grep

`sf data query "SELECT COUNT() FROM X"` no devuelve una tabla con column "COUNT" — devuelve el message "Total number of records retrieved: N". Parsear con:
```bash
COUNT=$(sf data query ... | grep -oE 'retrieved: [0-9]+' | tail -1 | grep -oE '[0-9]+')
```

## Quirk 8: Field aliases en SOQL

Salesforce SOQL solo permite aliases en aggregate queries. `SELECT Id, Name coverage FROM X` falla con "only aggregate expressions use field aliasing". Solución: usar los nombres reales de fields o subselects.

## Quirk 9: sf CLI --api-version 63.0

Para ver fields RCA en Quote/QuoteLineItem (SegmentIdentifier, RevenueCloudPackagingFlag, etc.), forzar API version alta:
```bash
sf data query --api-version 63.0 --query "SELECT SegmentIdentifier FROM QuoteLineItem"
```
Sin esto, API v50 default esconde los fields.

## Quirk 10: Bash heredocs con vars

Al escribir SOAP envelopes con $TOKEN, $INST inline, usar heredoc regular (no <<'EOF'):
```bash
cat > /tmp/soap.xml <<EOF
<sessionId>$TOKEN</sessionId>
EOF
```
