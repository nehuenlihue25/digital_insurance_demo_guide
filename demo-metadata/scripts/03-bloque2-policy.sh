#!/usr/bin/env bash
# ============================================================================
# 03-bloque2-policy.sh
# ----------------------------------------------------------------------------
# Bloque 2 — Ciclo de Póliza (Seguros ALFA / Insurance on Core)
#
# Materializa la data transaccional del Bloque 2 sobre la org destino:
#   - 3 Accounts (Panadería La Espiga, Ferretería El Tornillo, Consultores
#     Andinos)
#   - 1 Opportunity para Panadería (RecordType SimpleOpportunity + Standard
#     Pricebook; ambos resueltos dinámicamente para no romper RCA)
#   - 1 InsurancePolicy POL-PYME-2026-0001 sobre Panadería
#   - 6 InsurancePolicyCoverage (RC, Incendio, Equipo, Robo, Rotura,
#     Sustracción) enlazadas dinámicamente a los Product2 Simple creados en
#     el script 02
#   - 2 InsurancePolicyTransaction (Emisión + Endoso)
#   - 6 InsurancePolicyProductClause materializados desde las
#     InsuranceProductClause del script 02 (5 AutoAdded + 1 Manual)
#
# Reglas cross-scripts:
#   - Prefix SF_DISABLE_LOG_FILE=true (sandbox — ver learnings/sf-cli-…)
#   - Idempotencia por Name / Code / TransactionNumber (upsert artesanal:
#     query → si existe SKIP, si no CREATE)
#   - Cero IDs hardcodeados: todo se resuelve dinámicamente por
#     Name / DeveloperName / Code
#   - Comentarios en español
#
# Uso:
#   ORG_ALIAS=ins-qbranch-alfa ./03-bloque2-policy.sh
#   o bien pasando el alias como primer argumento:
#   ./03-bloque2-policy.sh ins-qbranch-alfa
#
# Dependencias previas:
#   - Script 01 (org bootstrap / permset assignments) ejecutado
#   - Script 02 (producto Pyme + 6 coverages Product2 + 6
#     InsuranceProductClause) ejecutado — este script hace lookup por
#     ProductCode e InsuranceProductClause.Name
# ============================================================================

set -euo pipefail
export SF_DISABLE_LOG_FILE=true

# ---------------------------------------------------------------------------
# 0. Configuración
# ---------------------------------------------------------------------------
ORG_ALIAS="${1:-${ORG_ALIAS:-ins-qbranch-alfa}}"
SF="sf"
QUERY_FLAGS="--target-org $ORG_ALIAS --result-format csv"
CREATE_FLAGS="--target-org $ORG_ALIAS"

log()  { printf '\033[1;34m[03-bloque2]\033[0m %s\n' "$*" >&2; }
warn() { printf '\033[1;33m[03-bloque2 WARN]\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31m[03-bloque2 ERROR]\033[0m %s\n' "$*" >&2; exit 1; }

# Ejecuta una SOQL y devuelve la última línea (valor) o vacío si no hay match.
# Uso: VAL=$(soql_one "SELECT Id FROM X WHERE ...")
soql_one() {
  local q="$1"
  local out
  out=$($SF data query $QUERY_FLAGS --query "$q" 2>/dev/null | tail -n +2 | tr -d '"' | head -n1 || true)
  # Filtra header residual o "0 records"
  if [ -z "$out" ] || [ "$out" = "Id" ] || [[ "$out" == *"records"* ]]; then
    echo ""
  else
    echo "$out"
  fi
}

# Crea un record con -v "campo=valor …". Devuelve el Id creado.
sf_create() {
  local sobject="$1"; shift
  local values="$*"
  $SF data create record $CREATE_FLAGS -s "$sobject" -v "$values" --json \
    | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('result',{}).get('id',''))"
}

# Upsert artesanal: si la SOQL devuelve un Id lo retorna, si no crea y retorna.
# Uso: ID=$(ensure "InsurancePolicy" \
#          "SELECT Id FROM InsurancePolicy WHERE Name='POL-PYME-2026-0001'" \
#          "Name='POL-PYME-2026-0001' …")
ensure() {
  local sobject="$1"
  local find_query="$2"
  local create_values="$3"
  local label="${4:-$sobject}"

  local existing
  existing=$(soql_one "$find_query")
  if [ -n "$existing" ]; then
    log "  $label ya existe (Id=$existing) — SKIP"
    echo "$existing"
    return 0
  fi
  log "  Creando $label…"
  local new_id
  new_id=$(sf_create "$sobject" "$create_values")
  if [ -z "$new_id" ]; then
    die "No se pudo crear $label. Payload: $create_values"
  fi
  log "  $label creado (Id=$new_id)"
  echo "$new_id"
}

# ---------------------------------------------------------------------------
# 1. Preflight — validaciones de sesión y prerequisitos del script 02
# ---------------------------------------------------------------------------
log "Preflight: validando org $ORG_ALIAS"
$SF org display --target-org "$ORG_ALIAS" >/dev/null 2>&1 \
  || die "No hay sesión activa para $ORG_ALIAS. Ejecutar: sf org login web -a $ORG_ALIAS"

# Standard Pricebook — requerido por la Opportunity para no romper RCA
STD_PRICEBOOK_ID=$(soql_one "SELECT Id FROM Pricebook2 WHERE IsStandard=true LIMIT 1")
[ -n "$STD_PRICEBOOK_ID" ] || die "Standard Pricebook no encontrado en $ORG_ALIAS"
log "Standard Pricebook: $STD_PRICEBOOK_ID"

# RecordType SimpleOpportunity — crítico para el flujo RCA (ver gotchas #12)
OPP_RT_ID=$(soql_one \
  "SELECT Id FROM RecordType WHERE SObjectType='Opportunity' AND DeveloperName='SimpleOpportunity' LIMIT 1")
[ -n "$OPP_RT_ID" ] || die "RecordType Opportunity.SimpleOpportunity no existe — habilitar en Setup"
log "Opportunity RecordType SimpleOpportunity: $OPP_RT_ID"

# 6 Product2 Simple (coverages del script 02) — lookup por ProductCode
declare -A COV_PRODUCT_ID
for code in rcExtracontractual incendioAliados equipoElectronico roboAsalto roturaMaquinaria sustraccionDinero; do
  pid=$(soql_one "SELECT Id FROM Product2 WHERE ProductCode='$code' LIMIT 1")
  [ -n "$pid" ] || die "Product2 con ProductCode=$code no existe — correr script 02 primero"
  COV_PRODUCT_ID[$code]="$pid"
done
log "6 Product2 coverages resueltos: OK"

# 6 InsuranceProductClause del script 02 — lookup por Name
declare -A CLAUSE_ID
for cname in "Buena Fe" "Actos Dolosos" "Guerra y Terrorismo" "Actividades Extremas" "Deducible Mínimo" "Coaseguro 10%"; do
  # Escapar comillas simples en SOQL
  cname_esc=$(echo "$cname" | sed "s/'/\\\'/g")
  cid=$(soql_one "SELECT Id FROM InsuranceProductClause WHERE Name='$cname_esc' LIMIT 1")
  [ -n "$cid" ] || die "InsuranceProductClause '$cname' no existe — correr script 02 primero"
  CLAUSE_ID["$cname"]="$cid"
done
log "6 InsuranceProductClause resueltas: OK"

# ---------------------------------------------------------------------------
# 2. Accounts (3) — Panadería, Ferretería, Consultores
# ---------------------------------------------------------------------------
log "===== [2/6] Accounts ====="

ACC_PANADERIA_ID=$(ensure "Account" \
  "SELECT Id FROM Account WHERE Name='Panadería La Espiga SAS' LIMIT 1" \
  "Name='Panadería La Espiga SAS' Industry='Food & Beverage' BillingCity='Bogotá' BillingCountry='Colombia' NumberOfEmployees=42 AnnualRevenue=1800000000 Description='Cliente demo Bloque 2 — pyme del sector alimentos'" \
  "Account Panadería La Espiga SAS")

ACC_FERRETERIA_ID=$(ensure "Account" \
  "SELECT Id FROM Account WHERE Name='Ferretería El Tornillo Ltda' LIMIT 1" \
  "Name='Ferretería El Tornillo Ltda' Industry=Retail BillingCity='Medellín' BillingCountry='Colombia' NumberOfEmployees=18 AnnualRevenue=950000000 Description='Cliente demo Bloque 2 — pyme retail'" \
  "Account Ferretería El Tornillo Ltda")

ACC_CONSULTORES_ID=$(ensure "Account" \
  "SELECT Id FROM Account WHERE Name='Consultores Andinos SAS' LIMIT 1" \
  "Name='Consultores Andinos SAS' Industry=Consulting BillingCity='Bogotá' BillingCountry='Colombia' NumberOfEmployees=25 AnnualRevenue=1200000000 Description='Cliente demo Bloque 2 — pyme servicios profesionales'" \
  "Account Consultores Andinos SAS")

# ---------------------------------------------------------------------------
# 3. Opportunity para Panadería (RT SimpleOpportunity + Standard Pricebook)
# ---------------------------------------------------------------------------
log "===== [3/6] Opportunity ====="

OPP_NAME="Panadería La Espiga - Seguro Pyme Empresarial"
OPP_ID=$(ensure "Opportunity" \
  "SELECT Id FROM Opportunity WHERE Name='Panadería La Espiga - Seguro Pyme Empresarial' AND AccountId='$ACC_PANADERIA_ID' LIMIT 1" \
  "Name='$OPP_NAME' AccountId=$ACC_PANADERIA_ID CloseDate=2026-08-15 StageName='Proposal/Quote' Amount=2400000 RecordTypeId=$OPP_RT_ID Pricebook2Id=$STD_PRICEBOOK_ID Description='Oportunidad de emisión póliza Pyme Empresarial para Panadería La Espiga SAS'" \
  "Opportunity Panadería - Seguro Pyme Empresarial")

# ---------------------------------------------------------------------------
# 4. InsurancePolicy POL-PYME-2026-0001
# ---------------------------------------------------------------------------
log "===== [4/6] InsurancePolicy POL-PYME-2026-0001 ====="

POLICY_NAME_CODE="POL-PYME-2026-0001"
POLICY_ID=$(ensure "InsurancePolicy" \
  "SELECT Id FROM InsurancePolicy WHERE Name='$POLICY_NAME_CODE' LIMIT 1" \
  "Name='$POLICY_NAME_CODE' PolicyName='Seguro Pyme Integral - Plan Empresarial' NameInsuredId=$ACC_PANADERIA_ID PolicyType='BOP (Business Owners)' LineOfBusiness='Property & Casualty' Status='In Force' EffectiveDate=2026-06-01 ExpirationDate=2027-05-31 PremiumAmount=2400000 StandardPremiumAmount=2400000 TermPremiumAmount=2400000 TotalTermPremiumAmount=2400000 GrossWrittenPremium=2400000 PremiumFrequency=Annually PolicyTerm=Annually BillingType='Direct Billing'" \
  "InsurancePolicy $POLICY_NAME_CODE")

# ---------------------------------------------------------------------------
# 5. InsurancePolicyCoverage (6)
# ---------------------------------------------------------------------------
log "===== [5/6] InsurancePolicyCoverage (6) ====="

# create_coverage <code> <displayName> <limit> <deductible> <premium> <categoryGroup>
create_coverage() {
  local code="$1"
  local name="$2"
  local limit="$3"
  local deductible="$4"
  local premium="$5"
  local catGroup="$6"

  local product_id="${COV_PRODUCT_ID[$code]}"
  [ -n "$product_id" ] || die "Product2 para code=$code no resuelto (bug preflight)"

  ensure "InsurancePolicyCoverage" \
    "SELECT Id FROM InsurancePolicyCoverage WHERE InsurancePolicyId='$POLICY_ID' AND CoverageCode='$code' LIMIT 1" \
    "Name='$name' InsurancePolicyId=$POLICY_ID ProductId=$product_id CoverageCode=$code Category=Coverage CategoryGroup='$catGroup' LimitAmount=$limit DeductibleAmount=$deductible PremiumAmount=$premium StandardPremiumAmount=$premium TermPremiumAmount=$premium EffectiveDate=2026-06-01 ExpirationDate=2027-05-31 Status=Active" \
    "Coverage $name" >/dev/null
}

# 1. Responsabilidad Civil Extracontractual
create_coverage "rcExtracontractual" "Responsabilidad Civil Extracontractual" \
  100000000 2000000 600000 "Section 2/Liab"

# 2. Incendio y Aliados
create_coverage "incendioAliados" "Incendio y Aliados" \
  100000000 2000000 800000 "Section-1 Property Coverage"

# 3. Equipo Electrónico
create_coverage "equipoElectronico" "Equipo Electrónico" \
  100000000 2000000 300000 "Section-1 Property Coverage"

# 4. Robo y Asalto Interior
create_coverage "roboAsalto" "Robo y Asalto Interior" \
  100000000 2000000 400000 "Section-1 Property Coverage"

# 5. Rotura de Maquinaria (límite y deducible reducidos)
create_coverage "roturaMaquinaria" "Rotura de Maquinaria" \
  50000000 1000000 200000 "Section-1 Property Coverage"

# 6. Sustracción de Dinero y Valores
create_coverage "sustraccionDinero" "Sustracción de Dinero y Valores" \
  30000000 500000 100000 "Section-1 Property Coverage"

# Suma total esperada = 600k+800k+300k+400k+200k+100k = 2.400.000 (coincide con
# PremiumAmount de la póliza — verificable en el runbook, Paso 2.3).

# ---------------------------------------------------------------------------
# 6. InsurancePolicyTransaction (2) — Emisión + Endoso
# ---------------------------------------------------------------------------
log "===== [6/6a] InsurancePolicyTransaction (2) ====="

# 1. Emisión original
TXN_EMISION_NUMBER="TXN-PYME-2026-0001-001"
ensure "InsurancePolicyTransaction" \
  "SELECT Id FROM InsurancePolicyTransaction WHERE TransactionNumber='$TXN_EMISION_NUMBER' LIMIT 1" \
  "Name='POL-PYME-2026-0001 — Emisión' TransactionNumber=$TXN_EMISION_NUMBER InsurancePolicyId=$POLICY_ID Type='Premium Payment' Category=Issuance Status=Approved TransactionAmount=2400000 EffectiveDate=2026-06-01 Description='Emisión inicial de la póliza POL-PYME-2026-0001'" \
  "Transaction Emisión $TXN_EMISION_NUMBER" >/dev/null

# 2. Endoso 001 (ajuste sobre Incendio, ejemplo del runbook)
TXN_ENDOSO_NUMBER="TXN-PYME-2026-0001-002"
ensure "InsurancePolicyTransaction" \
  "SELECT Id FROM InsurancePolicyTransaction WHERE TransactionNumber='$TXN_ENDOSO_NUMBER' LIMIT 1" \
  "Name='POL-PYME-2026-0001 — Endoso 001 Incendio' TransactionNumber=$TXN_ENDOSO_NUMBER InsurancePolicyId=$POLICY_ID Type=Endorsement Category=Endorsement Status=Approved TransactionAmount=180000 EffectiveDate=2026-07-01 Description='Endoso 001 sobre cobertura de Incendio — ajuste de suma asegurada'" \
  "Transaction Endoso $TXN_ENDOSO_NUMBER" >/dev/null

# ---------------------------------------------------------------------------
# 7. InsurancePolicyProductClause (6) — materialización sobre la póliza
# ---------------------------------------------------------------------------
log "===== [6/6b] InsurancePolicyProductClause (6) ====="

# Textos resueltos con los valores default de la póliza (10% Coaseguro,
# Ninguna sustancia prohibida, deducible mínimo COP 1.000.000). En una
# implementación real este merge lo haría el motor de cláusulas al emitir,
# tomando los valores de los PADs del bundle. Para la demo lo dejamos
# persistido explícito para no depender del engine.

# create_policy_clause <clauseName> <creationMethod> <clauseText>
create_policy_clause() {
  local clauseName="$1"
  local creationMethod="$2"   # AutoAdded | Manual
  local clauseText="$3"

  local clauseId="${CLAUSE_ID[$clauseName]}"
  [ -n "$clauseId" ] || die "InsuranceProductClause '$clauseName' no resuelta"

  ensure "InsurancePolicyProductClause" \
    "SELECT Id FROM InsurancePolicyProductClause WHERE InsurancePolicyId='$POLICY_ID' AND InsuranceProductClauseId='$clauseId' LIMIT 1" \
    "Name='$clauseName (POL-PYME-2026-0001)' InsurancePolicyId=$POLICY_ID InsuranceProductClauseId=$clauseId CreationMethod=$creationMethod ClauseText='$clauseText' EffectiveDate=2026-06-01 ExpirationDate=2027-05-31 Status=Active" \
    "PolicyClause $clauseName" >/dev/null
}

# Las 5 AutoAdded — vienen del clausulado estándar del producto Pyme.
create_policy_clause "Buena Fe" "AutoAdded" \
  "El tomador declara bajo gravedad de juramento que la información suministrada para la contratación de esta póliza es veraz y completa. La inexactitud u omisión de circunstancias que hayan influido en la aceptación del riesgo dará lugar a la nulidad relativa del contrato conforme al artículo 1058 del Código de Comercio."

create_policy_clause "Actos Dolosos" "AutoAdded" \
  "Quedan excluidas de cobertura las pérdidas o daños causados directa o indirectamente por actos dolosos, fraudulentos o intencionales del tomador, del asegurado, de sus representantes legales o de las personas por las cuales aquellos deban responder civilmente."

create_policy_clause "Guerra y Terrorismo" "AutoAdded" \
  "Se excluyen los daños derivados de guerra declarada o no, invasión, actos de enemigos extranjeros, hostilidades, guerra civil, rebelión, revolución, insurrección, poder militar usurpado, ley marcial, así como los daños causados por actos de terrorismo tal como se definen en las normas colombianas vigentes."

create_policy_clause "Actividades Extremas" "AutoAdded" \
  "Se excluyen operaciones con Ninguna salvo pacto expreso en el condicionado particular. Cualquier extensión de cobertura a actividades no declaradas requiere endoso previo y ajuste de prima."

create_policy_clause "Deducible Mínimo" "AutoAdded" \
  "En todo siniestro amparado por esta póliza el asegurado asumirá un deducible mínimo por evento de COP 1.000.000, sin perjuicio de los deducibles específicos pactados para cada cobertura, en cuyo caso aplicará el mayor de los dos."

# La cláusula Manual — negociada específicamente para este cliente.
create_policy_clause "Coaseguro 10%" "Manual" \
  "En todo siniestro amparado por esta póliza el asegurado participará con un 10% del valor de la indemnización a título de coaseguro obligatorio, porcentaje que se descontará del monto liquidado antes del pago. Esta cláusula fue negociada específicamente para POL-PYME-2026-0001 y sustituye el porcentaje default del producto."

# ---------------------------------------------------------------------------
# 8. Cierre y verificación de conteos
# ---------------------------------------------------------------------------
log "===== Verificación final ====="

count_cov=$(soql_one "SELECT COUNT(Id) c FROM InsurancePolicyCoverage WHERE InsurancePolicyId='$POLICY_ID'")
count_txn=$(soql_one "SELECT COUNT(Id) c FROM InsurancePolicyTransaction WHERE InsurancePolicyId='$POLICY_ID'")
count_cla=$(soql_one "SELECT COUNT(Id) c FROM InsurancePolicyProductClause WHERE InsurancePolicyId='$POLICY_ID'")

log "Póliza POL-PYME-2026-0001: coverages=$count_cov transactions=$count_txn clauses=$count_cla"

if [ "$count_cov" != "6" ] || [ "$count_txn" != "2" ] || [ "$count_cla" != "6" ]; then
  warn "Conteos no coinciden con lo esperado (6/2/6). Revisar output arriba."
fi

log "Bloque 2 — data lista. URL:"
INST_URL=$($SF org display --target-org "$ORG_ALIAS" --json 2>/dev/null \
  | python3 -c "import json,sys; print(json.load(sys.stdin)['result']['instanceUrl'])")
echo "  ${INST_URL}/lightning/r/InsurancePolicy/${POLICY_ID}/view"

log "Fin script 03-bloque2-policy.sh"
