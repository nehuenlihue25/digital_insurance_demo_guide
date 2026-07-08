#!/usr/bin/env bash
# ============================================================================
# 00-prerequisites.sh
# ----------------------------------------------------------------------------
# Verifica que la org destino tenga TODO lo necesario ANTES de correr
# los scripts de setup de la demo Seguros ALFA (Insurance on Core + RCA + DIS).
#
# Uso:
#   ./00-prerequisites.sh <alias-org>
#   ORG=<alias-org> ./00-prerequisites.sh
#
# Exit codes:
#   0 -> Todo OK, se puede proceder con los siguientes scripts
#   1 -> Falta al menos un requisito crítico; NO correr los siguientes scripts
# ============================================================================

set -euo pipefail

# sf CLI escribe a un log file que puede fallar en este entorno; desactivamos.
export SF_DISABLE_LOG_FILE=true

# ---------- Resolución de la org destino ------------------------------------
# Acepta alias como $1 o como variable de entorno ORG.
ORG_ALIAS="${1:-${ORG:-}}"
if [[ -z "${ORG_ALIAS}" ]]; then
  echo "ERROR: debes pasar el alias de la org como \$1 o exportar ORG=<alias>." >&2
  echo "Ejemplo: ./00-prerequisites.sh mi-sandbox" >&2
  exit 1
fi

# ---------- Utilidades de output --------------------------------------------
# Colores ANSI (verde/rojo/amarillo/reset). Si la terminal no soporta, se ven vacíos.
GREEN=$'\033[0;32m'
RED=$'\033[0;31m'
YELLOW=$'\033[0;33m'
BOLD=$'\033[1m'
RESET=$'\033[0m'

# Contadores globales para el resumen final.
PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0
FAILED_CHECKS=()

pass() {
  # Marca un check como OK.
  echo "  ${GREEN}✓${RESET} $1"
  PASS_COUNT=$((PASS_COUNT + 1))
}

fail() {
  # Marca un check como CRÍTICO fallido.
  echo "  ${RED}✗${RESET} $1"
  FAIL_COUNT=$((FAIL_COUNT + 1))
  FAILED_CHECKS+=("$1")
}

warn() {
  # Advertencia: no bloquea pero conviene revisarla.
  echo "  ${YELLOW}!${RESET} $1"
  WARN_COUNT=$((WARN_COUNT + 1))
}

section() {
  # Encabezado de bloque de checks.
  echo ""
  echo "${BOLD}==> $1${RESET}"
}

# Wrapper para correr una query SOQL de forma silenciosa y devolver JSON.
# Si falla la query, retorna string vacío para que el caller decida.
soql() {
  local query="$1"
  sf data query --target-org "${ORG_ALIAS}" --query "${query}" --json 2>/dev/null || echo ""
}

# Wrapper para queries sobre la Tooling API (metadatos como PermissionSet,
# RecordType, AttributeDefinition, etc. cuando aplique).
soql_tooling() {
  local query="$1"
  sf data query --target-org "${ORG_ALIAS}" --use-tooling-api --query "${query}" --json 2>/dev/null || echo ""
}

# Extrae totalSize de un JSON de sf data query (0 si no parseable).
total_size() {
  local json="$1"
  echo "${json}" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('result',{}).get('totalSize',0))" 2>/dev/null || echo "0"
}

echo "${BOLD}Prerequisites check — Seguros ALFA demo${RESET}"
echo "Org alias: ${ORG_ALIAS}"
echo "Fecha:     $(date '+%Y-%m-%d %H:%M:%S')"

# ============================================================================
# CHECK 1: Conexión a la org
# ----------------------------------------------------------------------------
# Sin conexión no tiene sentido correr nada más; salimos temprano.
# ============================================================================
section "1. Conexión a la org"

if ORG_INFO=$(sf org display --target-org "${ORG_ALIAS}" --json 2>/dev/null); then
  # Extraemos username e instance URL para dar contexto en el log.
  USERNAME=$(echo "${ORG_INFO}" | python3 -c "import sys,json;print(json.load(sys.stdin)['result']['username'])" 2>/dev/null || echo "unknown")
  INSTANCE_URL=$(echo "${ORG_INFO}" | python3 -c "import sys,json;print(json.load(sys.stdin)['result']['instanceUrl'])" 2>/dev/null || echo "unknown")
  pass "Conectado como ${USERNAME}"
  pass "Instance URL: ${INSTANCE_URL}"
else
  fail "No se pudo conectar a la org '${ORG_ALIAS}'. Ejecuta 'sf org login web -a ${ORG_ALIAS}' primero."
  # Sin conexión, seguir es inútil.
  echo ""
  echo "${RED}${BOLD}FATAL:${RESET} sin conexión no podemos verificar el resto. Aborto."
  exit 1
fi

# Recuperamos el UserId del usuario conectado para los checks de PSL/PermissionSet.
USER_ID_JSON=$(soql "SELECT Id FROM User WHERE Username='${USERNAME}' LIMIT 1")
CURRENT_USER_ID=$(echo "${USER_ID_JSON}" | python3 -c "import sys,json;d=json.load(sys.stdin);print(d['result']['records'][0]['Id'])" 2>/dev/null || echo "")
if [[ -z "${CURRENT_USER_ID}" ]]; then
  fail "No pude recuperar UserId del usuario activo — checks de licencias/permsets abortarán."
else
  pass "UserId resuelto: ${CURRENT_USER_ID}"
fi

# ============================================================================
# CHECK 2: Permission Set Licenses (PSL) asignadas al usuario activo
# ----------------------------------------------------------------------------
# Las PSL habilitan features de RCA, Digital Insurance, Configurator y Core
# Pricing. Sin ellas, muchos objetos y flujos ni siquiera aparecen.
# ============================================================================
section "2. Permission Set Licenses críticas asignadas al usuario"

# Lista de PSLs que la demo requiere. Nombres exactos del DeveloperName.
CRITICAL_PSLS=(
  "RevenueLifecycleManagementUserPsl"        # RCA runtime
  "IndustriesConfiguratorPsl"                # Advanced Configurator
  "DynamicRevenueOrchestratorUserPsl"        # DRO — orquestador de revenue
  "DigitalInsuranceClaimManagementUser"      # Digital Insurance Claims
  "ClaimManagementAdmin"                     # Admin de Claims
  "DigitalInsurancePolicyAdminUserPsl"       # DIS policy admin
  "CorePricingDesignTime"                    # Core Pricing design
  "CorePricingRunTime"                       # Core Pricing runtime
)

if [[ -n "${CURRENT_USER_ID}" ]]; then
  # Traemos TODAS las PSL asignadas al usuario en una sola query y luego filtramos localmente.
  PSL_JSON=$(soql "SELECT PermissionSetLicense.DeveloperName FROM PermissionSetLicenseAssign WHERE AssigneeId='${CURRENT_USER_ID}'")
  ASSIGNED_PSLS=$(echo "${PSL_JSON}" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    for r in d.get('result',{}).get('records',[]):
        print(r['PermissionSetLicense']['DeveloperName'])
except Exception:
    pass
" 2>/dev/null || echo "")

  for psl in "${CRITICAL_PSLS[@]}"; do
    if echo "${ASSIGNED_PSLS}" | grep -qx "${psl}"; then
      pass "PSL asignada: ${psl}"
    else
      fail "PSL NO asignada: ${psl} (asigna con: sf org assign permsetlicense -n ${psl})"
    fi
  done
else
  fail "Skipping PSL checks — falta UserId."
fi

# ============================================================================
# CHECK 3: Permission Sets críticos
# ----------------------------------------------------------------------------
# Los PSL habilitan la licencia pero muchos features requieren además un
# Permission Set concreto asignado. Verificamos que existan en la org y que
# estén asignados al usuario.
# ============================================================================
section "3. Permission Sets críticos asignados al usuario"

CRITICAL_PERMSETS=(
  "AdvancedConfiguratorDesigner"          # Diseñar rules de Configurator
  "ProductConfigurationRulesDesigner"     # Rules de PCM
  "IndustriesConfiguratorPlatformApi"     # API del configurator
  "ProductCatalogManagementViewer"        # PCM viewer
  "ProductDiscoveryUser"                  # Product Discovery
  "ContextServiceRuntimePsl"              # Context Service runtime
  "StageManagementUser"                   # DRO stage management
  "BRERuntime"                            # Business Rules Engine
  "OmniStudioExecution"                   # OmniStudio runtime
)

if [[ -n "${CURRENT_USER_ID}" ]]; then
  # Traemos permsets asignados una sola vez.
  PS_JSON=$(soql "SELECT PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId='${CURRENT_USER_ID}'")
  ASSIGNED_PS=$(echo "${PS_JSON}" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    for r in d.get('result',{}).get('records',[]):
        print(r['PermissionSet']['Name'])
except Exception:
    pass
" 2>/dev/null || echo "")

  for ps in "${CRITICAL_PERMSETS[@]}"; do
    if echo "${ASSIGNED_PS}" | grep -qx "${ps}"; then
      pass "PermSet asignado: ${ps}"
    else
      # Antes de marcar fail, verificamos si al menos EXISTE en la org.
      # Un PS no asignado suele resolverse con `sf org assign permset -n <name>`.
      EXISTS_JSON=$(soql "SELECT Id FROM PermissionSet WHERE Name='${ps}' LIMIT 1")
      EXISTS_COUNT=$(total_size "${EXISTS_JSON}")
      if [[ "${EXISTS_COUNT}" == "0" ]]; then
        fail "PermSet '${ps}' NO EXISTE en la org (feature no habilitado o nombre distinto)"
      else
        fail "PermSet '${ps}' existe pero NO está asignado (asigna con: sf org assign permset -n ${ps})"
      fi
    fi
  done
else
  fail "Skipping PermissionSet checks — falta UserId."
fi

# ============================================================================
# CHECK 4: Accesibilidad de sObjects críticos
# ----------------------------------------------------------------------------
# Si un sObject no es queryable, o el feature no está habilitado, o el user
# no tiene permisos. Igual falla; hay que investigar antes de correr scripts.
# Nota: usamos LIMIT 0 para no traer data, solo validar que la query compila.
# ============================================================================
section "4. sObjects críticos accesibles"

CRITICAL_SOBJECTS=(
  "InsurancePolicy"                       # Póliza base
  "Claim"                                 # Siniestro
  "ClaimCoverage"                         # Cobertura del siniestro
  "ClaimCoveragePaymentDetail"            # Detalle de pago por cobertura
  "ClaimPaymentSummary"                   # Resumen de pagos
  "ClaimCovReserveAdjustment"             # Ajustes de reserva
  "InsurancePolicyTransaction"            # Transacciones sobre la póliza
  "InsuranceClause"                       # Cláusulas maestro
  "InsuranceProductClause"                # Cláusulas por producto
  "InsurancePolicyProductClause"          # Cláusulas por póliza
  "InsProductClauseVariableMap"           # Mapeo de variables de cláusula
  "Product2"                              # Producto (base RCA/PCM)
  "ProductClassification"                 # Clasificación PCM
  "AttributeDefinition"                   # Atributos PCM
  "ProductAttributeDefinition"            # Attr por producto
  "ProductComponentGroup"                 # Bundles/Groups
  "ProductRelatedComponent"               # Relaciones bundle/child
)

for obj in "${CRITICAL_SOBJECTS[@]}"; do
  # LIMIT 0 valida DDL/permiso sin tocar data.
  if sf data query --target-org "${ORG_ALIAS}" --query "SELECT Id FROM ${obj} LIMIT 0" --json >/dev/null 2>&1; then
    pass "sObject accesible: ${obj}"
  else
    fail "sObject NO accesible: ${obj} (feature no habilitado o sin permisos de lectura)"
  fi
done

# ============================================================================
# CHECK 5: Campos de Quote/QuoteLineItem para RCA runtime
# ----------------------------------------------------------------------------
# Quote.CalculationStatus con muchos valores es proxy de que el runtime RCA
# está instalado. QuoteLineItem.RevenueCloudPackagingFlag es señal de que la
# lógica de bundling packaging está disponible.
# ============================================================================
section "5. Campos de Quote/QuoteLineItem (proof de RCA runtime)"

# Contamos valores del picklist CalculationStatus vía Tooling API.
# El runtime RCA suele traer 20+ valores; una org sin RCA trae <5.
CS_JSON=$(soql_tooling "SELECT Metadata FROM FieldDefinition WHERE EntityDefinition.QualifiedApiName='Quote' AND QualifiedApiName='CalculationStatus'")
CS_COUNT=$(echo "${CS_JSON}" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    md = d['result']['records'][0]['Metadata']
    vals = md.get('valueSet',{}).get('valueSetDefinition',{}).get('value',[])
    print(len(vals))
except Exception:
    print(0)
" 2>/dev/null || echo "0")

if [[ "${CS_COUNT}" -ge 20 ]]; then
  pass "Quote.CalculationStatus tiene ${CS_COUNT} valores (RCA runtime instalado)"
elif [[ "${CS_COUNT}" -gt 0 ]]; then
  fail "Quote.CalculationStatus solo tiene ${CS_COUNT} valores (esperado 20+). RCA runtime probablemente NO instalado."
else
  fail "No pude leer Quote.CalculationStatus — RCA runtime posiblemente ausente."
fi

# Verificamos que QuoteLineItem.RevenueCloudPackagingFlag exista.
QLI_FLAG_JSON=$(soql_tooling "SELECT Id FROM FieldDefinition WHERE EntityDefinition.QualifiedApiName='QuoteLineItem' AND QualifiedApiName='RevenueCloudPackagingFlag'")
QLI_FLAG_COUNT=$(total_size "${QLI_FLAG_JSON}")
if [[ "${QLI_FLAG_COUNT}" == "1" ]]; then
  pass "QuoteLineItem.RevenueCloudPackagingFlag existe (packaging RCA disponible)"
else
  fail "QuoteLineItem.RevenueCloudPackagingFlag NO existe (RCA packaging no habilitado)"
fi

# ============================================================================
# CHECK 6: ProductSellingModel 'One Time'
# ----------------------------------------------------------------------------
# El SellingModel es requerido para product2 en RCA. "One Time" viene por default
# en orgs con RCA habilitado.
# ============================================================================
section "6. ProductSellingModel 'One Time'"

PSM_JSON=$(soql "SELECT Id, Name FROM ProductSellingModel WHERE Name='One Time' AND Status='Active' LIMIT 1")
PSM_COUNT=$(total_size "${PSM_JSON}")
if [[ "${PSM_COUNT}" -ge 1 ]]; then
  pass "ProductSellingModel 'One Time' existe y está activo"
else
  fail "ProductSellingModel 'One Time' NO existe/no está activo — crea uno antes de correr los siguientes scripts"
fi

# ============================================================================
# CHECK 7: Pricebook Standard
# ----------------------------------------------------------------------------
# Todo Product2 vinculado a Opportunity/Quote requiere PricebookEntry en el
# Standard Pricebook. Si no está activo, los flujos fallan.
# ============================================================================
section "7. Standard Pricebook activo"

PB_JSON=$(soql "SELECT Id, Name, IsActive FROM Pricebook2 WHERE IsStandard=true LIMIT 1")
PB_COUNT=$(total_size "${PB_JSON}")
PB_ACTIVE=$(echo "${PB_JSON}" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d['result']['records'][0].get('IsActive', False))
except Exception:
    print('False')
" 2>/dev/null || echo "False")

if [[ "${PB_COUNT}" -ge 1 && "${PB_ACTIVE}" == "True" ]]; then
  pass "Standard Pricebook existe y está activo"
elif [[ "${PB_COUNT}" -ge 1 ]]; then
  fail "Standard Pricebook existe pero NO está activo (actívalo desde Setup > Price Books)"
else
  fail "Standard Pricebook NO encontrado"
fi

# ============================================================================
# CHECK 8: ProductCatalog 'Insurance Catalog'
# ----------------------------------------------------------------------------
# PCM requiere al menos un ProductCatalog para organizar los productos.
# Si no existe, damos las instrucciones para crearlo (no lo creamos aquí para
# no modificar estado sin autorización).
# ============================================================================
section "8. ProductCatalog 'Insurance Catalog'"

CAT_JSON=$(soql "SELECT Id, Name FROM ProductCatalog WHERE Name='Insurance Catalog' LIMIT 1")
CAT_COUNT=$(total_size "${CAT_JSON}")
if [[ "${CAT_COUNT}" -ge 1 ]]; then
  pass "ProductCatalog 'Insurance Catalog' existe"
else
  warn "ProductCatalog 'Insurance Catalog' NO existe. Crear con:"
  warn "  sf data create record --sobject ProductCatalog --values \"Name='Insurance Catalog'\" --target-org ${ORG_ALIAS}"
fi

# ============================================================================
# CHECK 9: RecordTypes de Product2 ('Commercial' y 'Coverage')
# ----------------------------------------------------------------------------
# Los scripts que siguen crean productos con estos RecordTypes; si no existen,
# los inserts fallan. Buscamos por DeveloperName (case-sensitive, estable).
# ============================================================================
section "9. RecordTypes de Product2"

for rt in "Commercial" "Coverage"; do
  RT_JSON=$(soql "SELECT Id FROM RecordType WHERE SobjectType='Product2' AND DeveloperName='${rt}' LIMIT 1")
  RT_COUNT=$(total_size "${RT_JSON}")
  if [[ "${RT_COUNT}" -ge 1 ]]; then
    pass "RecordType Product2.${rt} existe"
  else
    fail "RecordType Product2.${rt} NO existe (créalo antes de correr los siguientes scripts)"
  fi
done

# ============================================================================
# CHECK 10: RecordType Opportunity 'SimpleOpportunity'
# ----------------------------------------------------------------------------
# Crítico para RCA: los quotes y flows de revenue asumen este RecordType.
# Si no existe, la orquestación se rompe silenciosamente.
# ============================================================================
section "10. RecordType Opportunity 'SimpleOpportunity'"

OPP_RT_JSON=$(soql "SELECT Id FROM RecordType WHERE SobjectType='Opportunity' AND DeveloperName='SimpleOpportunity' LIMIT 1")
OPP_RT_COUNT=$(total_size "${OPP_RT_JSON}")
if [[ "${OPP_RT_COUNT}" -ge 1 ]]; then
  pass "RecordType Opportunity.SimpleOpportunity existe (RCA-ready)"
else
  fail "RecordType Opportunity.SimpleOpportunity NO existe — RCA no funcionará correctamente"
fi

# ============================================================================
# Resumen final
# ============================================================================
echo ""
echo "${BOLD}============================================================${RESET}"
echo "${BOLD}Resumen${RESET}"
echo "${BOLD}============================================================${RESET}"
echo "  ${GREEN}Passed:${RESET}   ${PASS_COUNT}"
echo "  ${YELLOW}Warnings:${RESET} ${WARN_COUNT}"
echo "  ${RED}Failed:${RESET}   ${FAIL_COUNT}"

if [[ ${FAIL_COUNT} -gt 0 ]]; then
  echo ""
  echo "${RED}${BOLD}Checks fallidos:${RESET}"
  for f in "${FAILED_CHECKS[@]}"; do
    echo "  - ${f}"
  done
  echo ""
  echo "${RED}${BOLD}NO CORRAS los siguientes scripts hasta resolver los fallos.${RESET}"
  exit 1
fi

echo ""
echo "${GREEN}${BOLD}✓ Org lista. Puedes proceder con los siguientes scripts.${RESET}"
exit 0
