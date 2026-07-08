#!/usr/bin/env bash
# =============================================================================
# 05-bloque6-deploy-reports.sh
# -----------------------------------------------------------------------------
# Bloque 6 del RFP Seguros ALFA - Deploy de Custom Report Types, Reports y
# Dashboards para la carpeta "Seguros ALFA Pyme".
#
# POR QUE NO USAMOS `sf project deploy start`:
#   El binario `sf` intenta escribir un lockfile en ~/.sfdx/ (por ej.
#   `~/.sfdx/stash.json.lock`) al arrancar cualquier comando de deploy.
#   El sandbox de este entorno bloquea escrituras fuera del cwd y $TMPDIR,
#   por lo que el comando falla con EACCES antes siquiera de contactar la org.
#   `sf data query` y `sf org display` funcionan porque son lecturas y toleran
#   `SF_DISABLE_LOG_FILE=true` sin tocar el stash.
#
#   Solucion: empaquetar el metadata en formato MDAPI y hablar directamente
#   con la Metadata API por SOAP (endpoint /services/Soap/m/62.0). Solo
#   necesitamos accessToken + instanceUrl, que se leen con `sf org display`.
#
# Prerequisitos:
#   - Alias/org autenticada (default DevHub o target-org).
#   - Metadata ya en formato MDAPI en:
#       ../metadata/custom-report-types/     (paquete CRTs)
#       ../metadata/reports-dashboards/      (paquete Reports + Dashboards)
#   - Python 3 (para parse JSON y XML) y zip disponibles en PATH.
# =============================================================================

set -euo pipefail

export SF_DISABLE_LOG_FILE=true

# -----------------------------------------------------------------------------
# Rutas
# -----------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
METADATA_DIR="$(cd "${SCRIPT_DIR}/../metadata" && pwd)"
CRT_DIR="${METADATA_DIR}/custom-report-types"
REPORTS_DIR="${METADATA_DIR}/reports-dashboards"

WORK_DIR="${TMPDIR:-/tmp}/alfa-mdapi-$$"
mkdir -p "${WORK_DIR}"
trap 'rm -rf "${WORK_DIR}"' EXIT

API_VERSION="62.0"
FOLDER_NAME="Seguros ALFA Pyme"
FOLDER_DEV_NAME="Seguros_ALFA_Pyme"

echo "=============================================================="
echo " Bloque 6 - Deploy Reports & Dashboards (MDAPI via SOAP)"
echo "=============================================================="

# -----------------------------------------------------------------------------
# Prerequisitos
# -----------------------------------------------------------------------------
if [[ ! -d "${CRT_DIR}" ]] || [[ ! -f "${CRT_DIR}/package.xml" ]]; then
  echo "ERROR: no se encontro paquete CRT en ${CRT_DIR}" >&2
  exit 1
fi
if [[ ! -d "${REPORTS_DIR}" ]] || [[ ! -f "${REPORTS_DIR}/package.xml" ]]; then
  echo "ERROR: no se encontro paquete Reports/Dashboards en ${REPORTS_DIR}" >&2
  exit 1
fi
for bin in zip python3 curl; do
  if ! command -v "${bin}" >/dev/null 2>&1; then
    echo "ERROR: binario requerido no encontrado: ${bin}" >&2
    exit 1
  fi
done

# -----------------------------------------------------------------------------
# Access token + instance URL (sf org display --verbose)
# -----------------------------------------------------------------------------
echo ""
echo "[auth] Obteniendo accessToken e instanceUrl via 'sf org display'..."
ORG_JSON="$(sf org display --json --verbose 2>/dev/null || true)"
if [[ -z "${ORG_JSON}" ]]; then
  echo "ERROR: 'sf org display --json --verbose' no devolvio nada." >&2
  echo "       Asegurate de tener una target-org autenticada." >&2
  exit 1
fi

ACCESS_TOKEN="$(printf '%s' "${ORG_JSON}" | python3 -c 'import sys,json;d=json.load(sys.stdin);print(d["result"]["accessToken"])')"
INSTANCE_URL="$(printf '%s' "${ORG_JSON}" | python3 -c 'import sys,json;d=json.load(sys.stdin);print(d["result"]["instanceUrl"])')"

if [[ -z "${ACCESS_TOKEN}" ]] || [[ -z "${INSTANCE_URL}" ]]; then
  echo "ERROR: no se pudo extraer accessToken/instanceUrl del JSON." >&2
  exit 1
fi
echo "[auth]   instanceUrl = ${INSTANCE_URL}"
echo "[auth]   accessToken = ${ACCESS_TOKEN:0:12}...(truncado)"

SOAP_ENDPOINT="${INSTANCE_URL}/services/Soap/m/${API_VERSION}"

# -----------------------------------------------------------------------------
# Paso 1: crear Folders (Report y Dashboard) via sf data create record
# -----------------------------------------------------------------------------
echo ""
echo "[paso 1] Creando Folders '${FOLDER_NAME}' (Report + Dashboard) si no existen..."

ensure_folder() {
  local folder_type="$1"  # Report | Dashboard
  local existing
  existing="$(sf data query \
    --query "SELECT Id FROM Folder WHERE DeveloperName='${FOLDER_DEV_NAME}' AND Type='${folder_type}' LIMIT 1" \
    --json 2>/dev/null | \
    python3 -c 'import sys,json;d=json.load(sys.stdin);r=d.get("result",{}).get("records",[]);print(r[0]["Id"] if r else "")')"

  if [[ -n "${existing}" ]]; then
    echo "[paso 1]   Folder ${folder_type} ya existe: ${existing}"
    return 0
  fi

  echo "[paso 1]   Creando Folder ${folder_type}..."
  sf data create record --sobject Folder \
    --values "Name='${FOLDER_NAME}' DeveloperName=${FOLDER_DEV_NAME} Type=${folder_type} AccessType=Public" \
    >/dev/null
  echo "[paso 1]   Folder ${folder_type} creado."
}

ensure_folder "Report"
ensure_folder "Dashboard"

# -----------------------------------------------------------------------------
# Helper: deploy_mdapi_soap <zip_path> <etiqueta>
#   1. base64 encode del zip
#   2. envelope SOAP met:deploy
#   3. POST via curl -> asyncId
#   4. Loop checkDeployStatus hasta done=true
#   5. Parsear successes/failures y reportar
# -----------------------------------------------------------------------------
deploy_mdapi_soap() {
  local zip_path="$1"
  local label="$2"

  echo ""
  echo "[deploy:${label}] Zip a deployar: ${zip_path}"
  local zip_size
  zip_size="$(wc -c < "${zip_path}" | tr -d ' ')"
  echo "[deploy:${label}] Tamano: ${zip_size} bytes"

  # 1) base64 encode (single line, sin newlines)
  local b64_file="${WORK_DIR}/${label}.b64"
  base64 < "${zip_path}" | tr -d '\n' > "${b64_file}"

  # 2) SOAP envelope con met:deploy
  #    DeployOptions minimas: singlePackage=true, rollbackOnError=true.
  local deploy_envelope="${WORK_DIR}/${label}-deploy.xml"
  {
    printf '%s' '<?xml version="1.0" encoding="utf-8"?>'
    printf '%s' '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:met="http://soap.sforce.com/2006/04/metadata">'
    printf '%s' '<soapenv:Header><met:SessionHeader><met:sessionId>'
    printf '%s' "${ACCESS_TOKEN}"
    printf '%s' '</met:sessionId></met:SessionHeader></soapenv:Header>'
    printf '%s' '<soapenv:Body><met:deploy><met:ZipFile>'
    cat "${b64_file}"
    printf '%s' '</met:ZipFile><met:DeployOptions>'
    printf '%s' '<met:rollbackOnError>true</met:rollbackOnError>'
    printf '%s' '<met:singlePackage>true</met:singlePackage>'
    printf '%s' '</met:DeployOptions></met:deploy></soapenv:Body></soapenv:Envelope>'
  } > "${deploy_envelope}"

  # 3) POST -> asyncId
  echo "[deploy:${label}] Enviando SOAP deploy a ${SOAP_ENDPOINT}..."
  local deploy_resp="${WORK_DIR}/${label}-deploy-resp.xml"
  curl -sS -X POST "${SOAP_ENDPOINT}" \
    -H 'Content-Type: text/xml; charset=UTF-8' \
    -H 'SOAPAction: ""' \
    --data-binary "@${deploy_envelope}" \
    -o "${deploy_resp}"

  local async_id
  async_id="$(python3 -c '
import sys, re
data = open(sys.argv[1]).read()
m = re.search(r"<id>([^<]+)</id>", data)
if m:
    print(m.group(1))
else:
    fault = re.search(r"<faultstring>([^<]+)</faultstring>", data)
    if fault:
        sys.stderr.write("SOAP fault: " + fault.group(1) + "\n")
    sys.exit(2)
' "${deploy_resp}")"

  if [[ -z "${async_id}" ]]; then
    echo "ERROR: no se obtuvo asyncId. Respuesta cruda:" >&2
    cat "${deploy_resp}" >&2
    return 1
  fi
  echo "[deploy:${label}] asyncId = ${async_id}"

  # 4) Poll checkDeployStatus hasta done=true
  local status_envelope="${WORK_DIR}/${label}-status.xml"
  {
    printf '%s' '<?xml version="1.0" encoding="utf-8"?>'
    printf '%s' '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:met="http://soap.sforce.com/2006/04/metadata">'
    printf '%s' '<soapenv:Header><met:SessionHeader><met:sessionId>'
    printf '%s' "${ACCESS_TOKEN}"
    printf '%s' '</met:sessionId></met:SessionHeader></soapenv:Header>'
    printf '%s' '<soapenv:Body><met:checkDeployStatus><met:asyncProcessId>'
    printf '%s' "${async_id}"
    printf '%s' '</met:asyncProcessId><met:includeDetails>true</met:includeDetails></met:checkDeployStatus></soapenv:Body></soapenv:Envelope>'
  } > "${status_envelope}"

  local status_resp="${WORK_DIR}/${label}-status-resp.xml"
  local attempt=0
  local max_attempts=60   # ~ 60 * 5s = 5 minutos
  local done_flag="false"

  # Espera inicial de 10s segun contrato del script
  echo "[deploy:${label}] Espera inicial 10s antes de primer poll..."
  sleep 10

  while (( attempt < max_attempts )); do
    attempt=$(( attempt + 1 ))
    curl -sS -X POST "${SOAP_ENDPOINT}" \
      -H 'Content-Type: text/xml; charset=UTF-8' \
      -H 'SOAPAction: ""' \
      --data-binary "@${status_envelope}" \
      -o "${status_resp}"

    done_flag="$(python3 -c '
import sys, re
data = open(sys.argv[1]).read()
m = re.search(r"<done>([^<]+)</done>", data)
print(m.group(1) if m else "false")
' "${status_resp}")"

    local state
    state="$(python3 -c '
import sys, re
data = open(sys.argv[1]).read()
m = re.search(r"<status>([^<]+)</status>", data)
print(m.group(1) if m else "?")
' "${status_resp}")"

    echo "[deploy:${label}]   poll #${attempt}: done=${done_flag} status=${state}"

    if [[ "${done_flag}" == "true" ]]; then
      break
    fi
    sleep 5
  done

  if [[ "${done_flag}" != "true" ]]; then
    echo "ERROR: deploy no termino tras ${max_attempts} polls" >&2
    return 1
  fi

  # 5) Parsear componentSuccesses / componentFailures y reportar
  python3 - "${status_resp}" "${label}" <<'PY'
import sys, re
resp_path, label = sys.argv[1], sys.argv[2]
data = open(resp_path).read()

def one(tag):
    m = re.search(rf"<{tag}>([^<]+)</{tag}>", data)
    return m.group(1) if m else None

status = one("status") or "?"
num_ok = one("numberComponentsDeployed") or "0"
num_total = one("numberComponentsTotal") or "0"
num_err = one("numberComponentErrors") or "0"

print(f"[deploy:{label}] status={status} ok={num_ok}/{num_total} errors={num_err}")

# failures
fails = re.findall(r"<componentFailures>(.*?)</componentFailures>", data, re.S)
if fails:
    print(f"[deploy:{label}] --- componentFailures ---")
    for f in fails:
        name_m = re.search(r"<fullName>([^<]+)</fullName>", f)
        type_m = re.search(r"<componentType>([^<]+)</componentType>", f)
        prob_m = re.search(r"<problem>([^<]+)</problem>", f)
        print(f"  - [{type_m.group(1) if type_m else '?'}] {name_m.group(1) if name_m else '?'}: {prob_m.group(1) if prob_m else '?'}")

if status != "Succeeded":
    sys.exit(3)
PY
}

# -----------------------------------------------------------------------------
# Paso 2: deploy CRTs primero (los reports dependen de ellos)
# -----------------------------------------------------------------------------
echo ""
echo "[paso 2] Zipeando y deployando Custom Report Types..."
CRT_ZIP="${WORK_DIR}/mdapi-crt.zip"
(
  cd "${CRT_DIR}"
  zip -qr "${CRT_ZIP}" . -x '*.DS_Store'
)
deploy_mdapi_soap "${CRT_ZIP}" "crt"

# -----------------------------------------------------------------------------
# Paso 3: espera adicional 10s antes de reports (buffer entre deploys)
# -----------------------------------------------------------------------------
echo ""
echo "[paso 3] Espera 10s antes de deploy de reports+dashboards..."
sleep 10

# -----------------------------------------------------------------------------
# Paso 4: deploy Reports + Dashboards (mismo patron SOAP)
# -----------------------------------------------------------------------------
echo ""
echo "[paso 4] Zipeando y deployando Reports + Dashboards..."
REPORTS_ZIP="${WORK_DIR}/mdapi-reports.zip"
(
  cd "${REPORTS_DIR}"
  zip -qr "${REPORTS_ZIP}" . -x '*.DS_Store'
)
deploy_mdapi_soap "${REPORTS_ZIP}" "reports"

# -----------------------------------------------------------------------------
# Paso 5: espera 10s antes de verify
# -----------------------------------------------------------------------------
echo ""
echo "[paso 5] Espera 10s antes de verify..."
sleep 10

# -----------------------------------------------------------------------------
# Paso 6: verify - COUNT de Report y Dashboard en el folder
# -----------------------------------------------------------------------------
echo ""
echo "[paso 6] Verificando cantidades en folder '${FOLDER_DEV_NAME}'..."

REPORT_COUNT="$(sf data query \
  --query "SELECT COUNT(Id) c FROM Report WHERE FolderName='${FOLDER_NAME}'" \
  --json 2>/dev/null | \
  python3 -c 'import sys,json;d=json.load(sys.stdin);print(d["result"]["records"][0]["c"])')"

DASHBOARD_COUNT="$(sf data query \
  --query "SELECT COUNT(Id) c FROM Dashboard WHERE FolderName='${FOLDER_NAME}'" \
  --json 2>/dev/null | \
  python3 -c 'import sys,json;d=json.load(sys.stdin);print(d["result"]["records"][0]["c"])')"

echo "[paso 6]   Reports    en '${FOLDER_NAME}': ${REPORT_COUNT}"
echo "[paso 6]   Dashboards en '${FOLDER_NAME}': ${DASHBOARD_COUNT}"

echo ""
echo "=============================================================="
echo "Reports y Dashboards deployados. Verificar en la app Reports -> Folder 'Seguros ALFA Pyme'"
echo "=============================================================="
