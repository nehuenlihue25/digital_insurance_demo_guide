#!/usr/bin/env bash
# =============================================================================
# 05-block6-deploy-reports.sh
# -----------------------------------------------------------------------------
# Block 6 of the Seguros ALFA RFP - Deploys Custom Report Types, Reports, and
# Dashboards for the "Seguros ALFA Pyme" folder.
#
# WHY WE DON'T USE `sf project deploy start`:
#   The `sf` binary tries to write a lockfile under ~/.sfdx/ (e.g.
#   `~/.sfdx/stash.json.lock`) when any deploy command starts up. The
#   sandbox in this environment blocks writes outside cwd and $TMPDIR, so
#   the command fails with EACCES before it even contacts the org.
#   `sf data query` and `sf org display` work because they're read-only and
#   tolerate `SF_DISABLE_LOG_FILE=true` without touching the stash.
#
#   Workaround: package the metadata as MDAPI and talk directly to the
#   Metadata API over SOAP (endpoint /services/Soap/m/62.0). We only need
#   accessToken + instanceUrl, which we read with `sf org display`.
#
# Prerequisites:
#   - An authenticated alias/org (default DevHub or target-org).
#   - Metadata already in MDAPI format at:
#       ../metadata/custom-report-types/     (CRT package)
#       ../metadata/reports-dashboards/      (Reports + Dashboards package)
#   - Python 3 (for JSON and XML parsing) and zip available on PATH.
# =============================================================================

set -euo pipefail

export SF_DISABLE_LOG_FILE=true

# -----------------------------------------------------------------------------
# Paths
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
echo " Block 6 - Deploy Reports & Dashboards (MDAPI via SOAP)"
echo "=============================================================="

# -----------------------------------------------------------------------------
# Prerequisites
# -----------------------------------------------------------------------------
if [[ ! -d "${CRT_DIR}" ]] || [[ ! -f "${CRT_DIR}/package.xml" ]]; then
  echo "ERROR: CRT package not found at ${CRT_DIR}" >&2
  exit 1
fi
if [[ ! -d "${REPORTS_DIR}" ]] || [[ ! -f "${REPORTS_DIR}/package.xml" ]]; then
  echo "ERROR: Reports/Dashboards package not found at ${REPORTS_DIR}" >&2
  exit 1
fi
for bin in zip python3 curl; do
  if ! command -v "${bin}" >/dev/null 2>&1; then
    echo "ERROR: required binary not found: ${bin}" >&2
    exit 1
  fi
done

# -----------------------------------------------------------------------------
# Access token + instance URL (sf org display --verbose)
# -----------------------------------------------------------------------------
echo ""
echo "[auth] Fetching accessToken and instanceUrl via 'sf org display'..."
ORG_JSON="$(sf org display --json --verbose 2>/dev/null || true)"
if [[ -z "${ORG_JSON}" ]]; then
  echo "ERROR: 'sf org display --json --verbose' returned nothing." >&2
  echo "       Make sure you have an authenticated target-org." >&2
  exit 1
fi

ACCESS_TOKEN="$(printf '%s' "${ORG_JSON}" | python3 -c 'import sys,json;d=json.load(sys.stdin);print(d["result"]["accessToken"])')"
INSTANCE_URL="$(printf '%s' "${ORG_JSON}" | python3 -c 'import sys,json;d=json.load(sys.stdin);print(d["result"]["instanceUrl"])')"

if [[ -z "${ACCESS_TOKEN}" ]] || [[ -z "${INSTANCE_URL}" ]]; then
  echo "ERROR: could not extract accessToken/instanceUrl from JSON." >&2
  exit 1
fi
echo "[auth]   instanceUrl = ${INSTANCE_URL}"
echo "[auth]   accessToken = ${ACCESS_TOKEN:0:12}...(truncated)"

SOAP_ENDPOINT="${INSTANCE_URL}/services/Soap/m/${API_VERSION}"

# -----------------------------------------------------------------------------
# Step 1: create Folders (Report and Dashboard) via sf data create record
# -----------------------------------------------------------------------------
echo ""
echo "[step 1] Creating '${FOLDER_NAME}' folders (Report + Dashboard) if they don't exist..."

ensure_folder() {
  local folder_type="$1"  # Report | Dashboard
  local existing
  existing="$(sf data query \
    --query "SELECT Id FROM Folder WHERE DeveloperName='${FOLDER_DEV_NAME}' AND Type='${folder_type}' LIMIT 1" \
    --json 2>/dev/null | \
    python3 -c 'import sys,json;d=json.load(sys.stdin);r=d.get("result",{}).get("records",[]);print(r[0]["Id"] if r else "")')"

  if [[ -n "${existing}" ]]; then
    echo "[step 1]   Folder ${folder_type} already exists: ${existing}"
    return 0
  fi

  echo "[step 1]   Creating Folder ${folder_type}..."
  sf data create record --sobject Folder \
    --values "Name='${FOLDER_NAME}' DeveloperName=${FOLDER_DEV_NAME} Type=${folder_type} AccessType=Public" \
    >/dev/null
  echo "[step 1]   Folder ${folder_type} created."
}

ensure_folder "Report"
ensure_folder "Dashboard"

# -----------------------------------------------------------------------------
# Helper: deploy_mdapi_soap <zip_path> <label>
#   1. base64-encode the zip
#   2. build the SOAP envelope for met:deploy
#   3. POST via curl -> asyncId
#   4. Loop checkDeployStatus until done=true
#   5. Parse successes/failures and report
# -----------------------------------------------------------------------------
deploy_mdapi_soap() {
  local zip_path="$1"
  local label="$2"

  echo ""
  echo "[deploy:${label}] Zip to deploy: ${zip_path}"
  local zip_size
  zip_size="$(wc -c < "${zip_path}" | tr -d ' ')"
  echo "[deploy:${label}] Size: ${zip_size} bytes"

  # 1) base64 encode (single line, no newlines)
  local b64_file="${WORK_DIR}/${label}.b64"
  base64 < "${zip_path}" | tr -d '\n' > "${b64_file}"

  # 2) SOAP envelope with met:deploy
  #    Minimal DeployOptions: singlePackage=true, rollbackOnError=true.
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
  echo "[deploy:${label}] Sending SOAP deploy to ${SOAP_ENDPOINT}..."
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
    echo "ERROR: did not get an asyncId. Raw response:" >&2
    cat "${deploy_resp}" >&2
    return 1
  fi
  echo "[deploy:${label}] asyncId = ${async_id}"

  # 4) Poll checkDeployStatus until done=true
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
  local max_attempts=60   # ~ 60 * 5s = 5 minutes
  local done_flag="false"

  # Initial 10s wait per script contract
  echo "[deploy:${label}] Initial 10s wait before the first poll..."
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
    echo "ERROR: deploy did not finish after ${max_attempts} polls" >&2
    return 1
  fi

  # 5) Parse componentSuccesses / componentFailures and report
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
# Step 2: deploy CRTs first (the reports depend on them)
# -----------------------------------------------------------------------------
echo ""
echo "[step 2] Zipping and deploying Custom Report Types..."
CRT_ZIP="${WORK_DIR}/mdapi-crt.zip"
(
  cd "${CRT_DIR}"
  zip -qr "${CRT_ZIP}" . -x '*.DS_Store'
)
deploy_mdapi_soap "${CRT_ZIP}" "crt"

# -----------------------------------------------------------------------------
# Step 3: additional 10s wait before reports (buffer between deploys)
# -----------------------------------------------------------------------------
echo ""
echo "[step 3] Waiting 10s before deploying reports+dashboards..."
sleep 10

# -----------------------------------------------------------------------------
# Step 4: deploy Reports + Dashboards (same SOAP pattern)
# -----------------------------------------------------------------------------
echo ""
echo "[step 4] Zipping and deploying Reports + Dashboards..."
REPORTS_ZIP="${WORK_DIR}/mdapi-reports.zip"
(
  cd "${REPORTS_DIR}"
  zip -qr "${REPORTS_ZIP}" . -x '*.DS_Store'
)
deploy_mdapi_soap "${REPORTS_ZIP}" "reports"

# -----------------------------------------------------------------------------
# Step 5: wait 10s before verify
# -----------------------------------------------------------------------------
echo ""
echo "[step 5] Waiting 10s before verify..."
sleep 10

# -----------------------------------------------------------------------------
# Step 6: verify - COUNT of Report and Dashboard in the folder
# -----------------------------------------------------------------------------
echo ""
echo "[step 6] Verifying counts in folder '${FOLDER_DEV_NAME}'..."

REPORT_COUNT="$(sf data query \
  --query "SELECT COUNT(Id) c FROM Report WHERE FolderName='${FOLDER_NAME}'" \
  --json 2>/dev/null | \
  python3 -c 'import sys,json;d=json.load(sys.stdin);print(d["result"]["records"][0]["c"])')"

DASHBOARD_COUNT="$(sf data query \
  --query "SELECT COUNT(Id) c FROM Dashboard WHERE FolderName='${FOLDER_NAME}'" \
  --json 2>/dev/null | \
  python3 -c 'import sys,json;d=json.load(sys.stdin);print(d["result"]["records"][0]["c"])')"

echo "[step 6]   Reports    in '${FOLDER_NAME}': ${REPORT_COUNT}"
echo "[step 6]   Dashboards in '${FOLDER_NAME}': ${DASHBOARD_COUNT}"

echo ""
echo "=============================================================="
echo "Reports and Dashboards deployed. Verify in the Reports app -> Folder 'Seguros ALFA Pyme'"
echo "=============================================================="
