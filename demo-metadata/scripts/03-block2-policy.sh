#!/usr/bin/env bash
# ============================================================================
# 03-block2-policy.sh
# ----------------------------------------------------------------------------
# Block 2 — Policy Lifecycle (Seguros ALFA / Insurance on Core)
#
# Materializes Block 2 transactional data on the target org:
#   - 3 Accounts (Panadería La Espiga, Ferretería El Tornillo, Consultores
#     Andinos)
#   - 1 Opportunity for Panadería (RecordType SimpleOpportunity + Standard
#     Pricebook; both resolved dynamically to avoid breaking RCA)
#   - 1 InsurancePolicy POL-PYME-2026-0001 for Panadería
#   - 6 InsurancePolicyCoverage records (RC, Incendio, Equipo, Robo, Rotura,
#     Sustracción) dynamically linked to the Simple Product2s created by
#     script 02
#   - 2 InsurancePolicyTransaction records (Issuance + Endorsement)
#   - 6 InsurancePolicyProductClause records materialized from the
#     InsuranceProductClause rows created by script 02 (5 AutoAdded + 1 Manual)
#
# Cross-script rules:
#   - Prefix SF_DISABLE_LOG_FILE=true (sandbox — see learnings/sf-cli-…)
#   - Idempotency by Name / Code / TransactionNumber (hand-rolled upsert:
#     query → if it exists SKIP, otherwise CREATE)
#   - No hardcoded IDs: everything is resolved dynamically by
#     Name / DeveloperName / Code
#   - Comments in English
#
# Usage:
#   ORG_ALIAS=ins-qbranch-alfa ./03-block2-policy.sh
#   or by passing the alias as the first argument:
#   ./03-block2-policy.sh ins-qbranch-alfa
#
# Prerequisites:
#   - Script 01 (org bootstrap / permset assignments) executed
#   - Script 02 (Pyme product + 6 coverage Product2s + 6
#     InsuranceProductClause rows) executed — this script looks them up by
#     ProductCode and InsuranceProductClause.Name
# ============================================================================

set -euo pipefail
export SF_DISABLE_LOG_FILE=true

# ---------------------------------------------------------------------------
# 0. Configuration
# ---------------------------------------------------------------------------
ORG_ALIAS="${1:-${ORG_ALIAS:-ins-qbranch-alfa}}"
SF="sf"
QUERY_FLAGS="--target-org $ORG_ALIAS --result-format csv"
CREATE_FLAGS="--target-org $ORG_ALIAS"

log()  { printf '\033[1;34m[03-block2]\033[0m %s\n' "$*" >&2; }
warn() { printf '\033[1;33m[03-block2 WARN]\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31m[03-block2 ERROR]\033[0m %s\n' "$*" >&2; exit 1; }

# Runs a SOQL query and returns the last line (value) or empty if no match.
# Usage: VAL=$(soql_one "SELECT Id FROM X WHERE ...")
soql_one() {
  local q="$1"
  local out
  out=$($SF data query $QUERY_FLAGS --query "$q" 2>/dev/null | tail -n +2 | tr -d '"' | head -n1 || true)
  # Filter out lingering header or "0 records"
  if [ -z "$out" ] || [ "$out" = "Id" ] || [[ "$out" == *"records"* ]]; then
    echo ""
  else
    echo "$out"
  fi
}

# Creates a record with -v "field=value …". Returns the created Id.
sf_create() {
  local sobject="$1"; shift
  local values="$*"
  $SF data create record $CREATE_FLAGS -s "$sobject" -v "$values" --json \
    | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('result',{}).get('id',''))"
}

# Hand-rolled upsert: if the SOQL returns an Id, return it; otherwise create and return.
# Usage: ID=$(ensure "InsurancePolicy" \
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
    log "  $label already exists (Id=$existing) — SKIP"
    echo "$existing"
    return 0
  fi
  log "  Creating $label…"
  local new_id
  new_id=$(sf_create "$sobject" "$create_values")
  if [ -z "$new_id" ]; then
    die "Could not create $label. Payload: $create_values"
  fi
  log "  $label created (Id=$new_id)"
  echo "$new_id"
}

# ---------------------------------------------------------------------------
# 1. Preflight — session and script-02 prerequisite checks
# ---------------------------------------------------------------------------
log "Preflight: validating org $ORG_ALIAS"
$SF org display --target-org "$ORG_ALIAS" >/dev/null 2>&1 \
  || die "No active session for $ORG_ALIAS. Run: sf org login web -a $ORG_ALIAS"

# Standard Pricebook — required by the Opportunity to keep RCA working
STD_PRICEBOOK_ID=$(soql_one "SELECT Id FROM Pricebook2 WHERE IsStandard=true LIMIT 1")
[ -n "$STD_PRICEBOOK_ID" ] || die "Standard Pricebook not found in $ORG_ALIAS"
log "Standard Pricebook: $STD_PRICEBOOK_ID"

# RecordType SimpleOpportunity — critical for the RCA flow (see gotchas #12)
OPP_RT_ID=$(soql_one \
  "SELECT Id FROM RecordType WHERE SObjectType='Opportunity' AND DeveloperName='SimpleOpportunity' LIMIT 1")
[ -n "$OPP_RT_ID" ] || die "RecordType Opportunity.SimpleOpportunity not found — enable it in Setup"
log "Opportunity RecordType SimpleOpportunity: $OPP_RT_ID"

# 6 Simple Product2s (coverages from script 02) — lookup by ProductCode
declare -A COV_PRODUCT_ID
for code in rcExtracontractual incendioAliados equipoElectronico roboAsalto roturaMaquinaria sustraccionDinero; do
  pid=$(soql_one "SELECT Id FROM Product2 WHERE ProductCode='$code' LIMIT 1")
  [ -n "$pid" ] || die "Product2 with ProductCode=$code not found — run script 02 first"
  COV_PRODUCT_ID[$code]="$pid"
done
log "6 Product2 coverages resolved: OK"

# 6 InsuranceProductClause rows from script 02 — lookup by Name
declare -A CLAUSE_ID
for cname in "Buena Fe" "Actos Dolosos" "Guerra y Terrorismo" "Actividades Extremas" "Deducible Mínimo" "Coaseguro 10%"; do
  # Escape single quotes for SOQL
  cname_esc=$(echo "$cname" | sed "s/'/\\\'/g")
  cid=$(soql_one "SELECT Id FROM InsuranceProductClause WHERE Name='$cname_esc' LIMIT 1")
  [ -n "$cid" ] || die "InsuranceProductClause '$cname' not found — run script 02 first"
  CLAUSE_ID["$cname"]="$cid"
done
log "6 InsuranceProductClause resolved: OK"

# ---------------------------------------------------------------------------
# 2. Accounts (3) — Panadería, Ferretería, Consultores
# ---------------------------------------------------------------------------
log "===== [2/6] Accounts ====="

ACC_PANADERIA_ID=$(ensure "Account" \
  "SELECT Id FROM Account WHERE Name='Panadería La Espiga SAS' LIMIT 1" \
  "Name='Panadería La Espiga SAS' Industry='Food & Beverage' BillingCity='Bogotá' BillingCountry='Colombia' NumberOfEmployees=42 AnnualRevenue=1800000000 Description='Block 2 demo customer — small business in the food sector'" \
  "Account Panadería La Espiga SAS")

ACC_FERRETERIA_ID=$(ensure "Account" \
  "SELECT Id FROM Account WHERE Name='Ferretería El Tornillo Ltda' LIMIT 1" \
  "Name='Ferretería El Tornillo Ltda' Industry=Retail BillingCity='Medellín' BillingCountry='Colombia' NumberOfEmployees=18 AnnualRevenue=950000000 Description='Block 2 demo customer — small business retail'" \
  "Account Ferretería El Tornillo Ltda")

ACC_CONSULTORES_ID=$(ensure "Account" \
  "SELECT Id FROM Account WHERE Name='Consultores Andinos SAS' LIMIT 1" \
  "Name='Consultores Andinos SAS' Industry=Consulting BillingCity='Bogotá' BillingCountry='Colombia' NumberOfEmployees=25 AnnualRevenue=1200000000 Description='Block 2 demo customer — small business professional services'" \
  "Account Consultores Andinos SAS")

# ---------------------------------------------------------------------------
# 3. Opportunity for Panadería (RT SimpleOpportunity + Standard Pricebook)
# ---------------------------------------------------------------------------
log "===== [3/6] Opportunity ====="

OPP_NAME="Panadería La Espiga - Seguro Pyme Empresarial"
OPP_ID=$(ensure "Opportunity" \
  "SELECT Id FROM Opportunity WHERE Name='Panadería La Espiga - Seguro Pyme Empresarial' AND AccountId='$ACC_PANADERIA_ID' LIMIT 1" \
  "Name='$OPP_NAME' AccountId=$ACC_PANADERIA_ID CloseDate=2026-08-15 StageName='Proposal/Quote' Amount=2400000 RecordTypeId=$OPP_RT_ID Pricebook2Id=$STD_PRICEBOOK_ID Description='Issuance opportunity for the Pyme Empresarial policy for Panadería La Espiga SAS'" \
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
  [ -n "$product_id" ] || die "Product2 for code=$code not resolved (preflight bug)"

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

# 5. Rotura de Maquinaria (reduced limit and deductible)
create_coverage "roturaMaquinaria" "Rotura de Maquinaria" \
  50000000 1000000 200000 "Section-1 Property Coverage"

# 6. Sustracción de Dinero y Valores
create_coverage "sustraccionDinero" "Sustracción de Dinero y Valores" \
  30000000 500000 100000 "Section-1 Property Coverage"

# Expected total = 600k+800k+300k+400k+200k+100k = 2,400,000 (matches the
# policy's PremiumAmount — verifiable in the runbook, Step 2.3).

# ---------------------------------------------------------------------------
# 6. InsurancePolicyTransaction (2) — Issuance + Endorsement
# ---------------------------------------------------------------------------
log "===== [6/6a] InsurancePolicyTransaction (2) ====="

# 1. Original issuance
TXN_EMISION_NUMBER="TXN-PYME-2026-0001-001"
ensure "InsurancePolicyTransaction" \
  "SELECT Id FROM InsurancePolicyTransaction WHERE TransactionNumber='$TXN_EMISION_NUMBER' LIMIT 1" \
  "Name='POL-PYME-2026-0001 — Emisión' TransactionNumber=$TXN_EMISION_NUMBER InsurancePolicyId=$POLICY_ID Type='Premium Payment' Category=Issuance Status=Approved TransactionAmount=2400000 EffectiveDate=2026-06-01 Description='Initial issuance of policy POL-PYME-2026-0001'" \
  "Transaction Issuance $TXN_EMISION_NUMBER" >/dev/null

# 2. Endorsement 001 (adjustment on Incendio, runbook example)
TXN_ENDOSO_NUMBER="TXN-PYME-2026-0001-002"
ensure "InsurancePolicyTransaction" \
  "SELECT Id FROM InsurancePolicyTransaction WHERE TransactionNumber='$TXN_ENDOSO_NUMBER' LIMIT 1" \
  "Name='POL-PYME-2026-0001 — Endoso 001 Incendio' TransactionNumber=$TXN_ENDOSO_NUMBER InsurancePolicyId=$POLICY_ID Type=Endorsement Category=Endorsement Status=Approved TransactionAmount=180000 EffectiveDate=2026-07-01 Description='Endorsement 001 on the Incendio coverage — Sum Insured adjustment'" \
  "Transaction Endorsement $TXN_ENDOSO_NUMBER" >/dev/null

# 3. Renewal (planned renewal for the next term — runbook step 2.8)
# Type='Renewal' generates a transaction amount for the renewed policy term
# without creating a new InsurancePolicy record. This models the "renewal
# intent" so the demo can walk through the renewal moment without breaking
# the current In Force policy that the rest of Block 2 and Block 3 rely on.
TXN_RENEWAL_NUMBER="TXN-PYME-2026-0001-003"
ensure "InsurancePolicyTransaction" \
  "SELECT Id FROM InsurancePolicyTransaction WHERE TransactionNumber='$TXN_RENEWAL_NUMBER' LIMIT 1" \
  "Name='POL-PYME-2026-0001 — Renovación 2027' TransactionNumber=$TXN_RENEWAL_NUMBER InsurancePolicyId=$POLICY_ID Type=Renewal Category=Renewal Status=Approved TransactionAmount=2520000 EffectiveDate=2027-06-01 Description='Planned renewal for the 2027-2028 policy term — premium adjusted +5% for inflation'" \
  "Transaction Renewal $TXN_RENEWAL_NUMBER" >/dev/null

# 4. Cancellation Request (customer requested mid-term cancellation — demo scenario)
# NOTE: this only creates the transaction record; it does NOT change
# InsurancePolicy.Status to 'Cancelled'. In production the workflow would
# flip the Policy status after cancellation approval; here we keep the
# policy In Force so the rest of the demo (Block 3 claims flow) still works.
TXN_CANCEL_NUMBER="TXN-PYME-2026-0001-004"
ensure "InsurancePolicyTransaction" \
  "SELECT Id FROM InsurancePolicyTransaction WHERE TransactionNumber='$TXN_CANCEL_NUMBER' LIMIT 1" \
  "Name='POL-PYME-2026-0001 — Solicitud de Cancelación' TransactionNumber=$TXN_CANCEL_NUMBER InsurancePolicyId=$POLICY_ID Type=Cancellation Category=Cancellation Status='In Process' TransactionAmount=-1200000 EffectiveDate=2026-12-01 Description='Customer-requested cancellation effective 2026-12-01 — pro-rated refund of unearned premium'" \
  "Transaction Cancellation Request $TXN_CANCEL_NUMBER" >/dev/null

# ---------------------------------------------------------------------------
# 6b. CardPaymentMethod (2) — payment methods on file for the insured
# ---------------------------------------------------------------------------
# Two illustrative payment methods so the runbook step 2.10 can show the
# 'payment methods on file' view. Standard sObject CardPaymentMethod; the
# schema requires an AccountId lookup (the insured Account) and does not
# store real card numbers (masked/tokenized only).
#
# Fields used:
#   AccountId          → the insured (Panadería La Espiga SAS)
#   ProcessingMode     → External | ExternalRecurring | Salesforce
#   Status             → Active | Inactive | New
#   CardCategory       → CreditCard | DebitCard
#   CardType           → Visa | MasterCard | Amex | Discover | Other
#   CardLastFour       → 4-char tokenized suffix (safe to display)
#   CardHolderName     → free text
#   ExpiryMonth / ExpiryYear
#
# If the CardPaymentMethod object is not enabled in the org (requires
# Salesforce Payments / Commerce license), this section is skipped with a
# warning rather than failing the whole script — Block 2 renewal + cancel
# already provide enough content for step 2.10 to reference conceptually.
log "===== [6b] CardPaymentMethod (2) ====="

if $SF sobject describe --sobject CardPaymentMethod --target-org "$ORG_ALIAS" --json >/dev/null 2>&1; then
  ensure "CardPaymentMethod" \
    "SELECT Id FROM CardPaymentMethod WHERE AccountId='$ACC_PANADERIA_ID' AND CardLastFour='4242' LIMIT 1" \
    "AccountId=$ACC_PANADERIA_ID ProcessingMode=ExternalRecurring Status=Active CardCategory=CreditCard CardType=Visa CardLastFour=4242 CardHolderName='Panadería La Espiga SAS' ExpiryMonth=12 ExpiryYear=2028 Nickname='Corporate Visa'" \
    "CardPaymentMethod Visa **** 4242" >/dev/null

  ensure "CardPaymentMethod" \
    "SELECT Id FROM CardPaymentMethod WHERE AccountId='$ACC_PANADERIA_ID' AND CardLastFour='5555' LIMIT 1" \
    "AccountId=$ACC_PANADERIA_ID ProcessingMode=ExternalRecurring Status=Active CardCategory=DebitCard CardType=MasterCard CardLastFour=5555 CardHolderName='Panadería La Espiga SAS' ExpiryMonth=6 ExpiryYear=2027 Nickname='Backup Mastercard'" \
    "CardPaymentMethod Mastercard **** 5555" >/dev/null
else
  warn "CardPaymentMethod sObject is not enabled on this org — skipping payment methods."
  warn "The runbook step 2.10 will be presented conceptually instead of showing records."
fi

# ---------------------------------------------------------------------------
# 7. InsurancePolicyProductClause (6) — materialization on the policy
# ---------------------------------------------------------------------------
log "===== [6/6b] InsurancePolicyProductClause (6) ====="

# Texts resolved with the policy default values (10% Coinsurance, no
# prohibited substances, minimum deductible COP 1,000,000). In a real
# implementation this merge would be performed by the clause engine at
# issuance time, pulling values from the bundle's PADs. For the demo we
# leave it explicitly persisted so we don't depend on the engine.

# create_policy_clause <clauseName> <creationMethod> <clauseText>
create_policy_clause() {
  local clauseName="$1"
  local creationMethod="$2"   # AutoAdded | Manual
  local clauseText="$3"

  local clauseId="${CLAUSE_ID[$clauseName]}"
  [ -n "$clauseId" ] || die "InsuranceProductClause '$clauseName' not resolved"

  ensure "InsurancePolicyProductClause" \
    "SELECT Id FROM InsurancePolicyProductClause WHERE InsurancePolicyId='$POLICY_ID' AND InsuranceProductClauseId='$clauseId' LIMIT 1" \
    "Name='$clauseName (POL-PYME-2026-0001)' InsurancePolicyId=$POLICY_ID InsuranceProductClauseId=$clauseId CreationMethod=$creationMethod ClauseText='$clauseText' EffectiveDate=2026-06-01 ExpirationDate=2027-05-31 Status=Active" \
    "PolicyClause $clauseName" >/dev/null
}

# The 5 AutoAdded — come from the standard Pyme product clause set.
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

# The Manual clause — negotiated specifically for this customer.
create_policy_clause "Coaseguro 10%" "Manual" \
  "En todo siniestro amparado por esta póliza el asegurado participará con un 10% del valor de la indemnización a título de coaseguro obligatorio, porcentaje que se descontará del monto liquidado antes del pago. Esta cláusula fue negociada específicamente para POL-PYME-2026-0001 y sustituye el porcentaje default del producto."

# ---------------------------------------------------------------------------
# 8. Wrap-up and count verification
# ---------------------------------------------------------------------------
log "===== Final verification ====="

count_cov=$(soql_one "SELECT COUNT(Id) c FROM InsurancePolicyCoverage WHERE InsurancePolicyId='$POLICY_ID'")
count_txn=$(soql_one "SELECT COUNT(Id) c FROM InsurancePolicyTransaction WHERE InsurancePolicyId='$POLICY_ID'")
count_cla=$(soql_one "SELECT COUNT(Id) c FROM InsurancePolicyProductClause WHERE InsurancePolicyId='$POLICY_ID'")

log "Policy POL-PYME-2026-0001: coverages=$count_cov transactions=$count_txn clauses=$count_cla"

if [ "$count_cov" != "6" ] || [ "$count_txn" != "4" ] || [ "$count_cla" != "6" ]; then
  warn "Counts don't match the expected values (6/4/6). Review the output above."
fi

log "Block 2 — data is ready. URL:"
INST_URL=$($SF org display --target-org "$ORG_ALIAS" --json 2>/dev/null \
  | python3 -c "import json,sys; print(json.load(sys.stdin)['result']['instanceUrl'])")
echo "  ${INST_URL}/lightning/r/InsurancePolicy/${POLICY_ID}/view"

log "End of script 03-block2-policy.sh"
