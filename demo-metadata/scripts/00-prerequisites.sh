#!/usr/bin/env bash
# ============================================================================
# 00-prerequisites.sh
# ----------------------------------------------------------------------------
# Verifies that the target org has EVERYTHING needed BEFORE running the setup
# scripts for the Seguros ALFA demo (Insurance on Core + RCA + DIS).
#
# Usage:
#   ./00-prerequisites.sh <org-alias>
#   ORG=<org-alias> ./00-prerequisites.sh
#
# Exit codes:
#   0 -> All good, safe to proceed with the following scripts
#   1 -> At least one critical prerequisite is missing; DO NOT run the next scripts
# ============================================================================

set -euo pipefail

# The sf CLI writes to a log file that can fail in this environment; disable it.
export SF_DISABLE_LOG_FILE=true

# ---------- Target org resolution -------------------------------------------
# Accepts alias as $1 or as the ORG environment variable.
ORG_ALIAS="${1:-${ORG:-}}"
if [[ -z "${ORG_ALIAS}" ]]; then
  echo "ERROR: you must pass the org alias as \$1 or export ORG=<alias>." >&2
  echo "Example: ./00-prerequisites.sh my-sandbox" >&2
  exit 1
fi

# ---------- Output utilities ------------------------------------------------
# ANSI colors (green/red/yellow/reset). If the terminal doesn't support them they render empty.
GREEN=$'\033[0;32m'
RED=$'\033[0;31m'
YELLOW=$'\033[0;33m'
BOLD=$'\033[1m'
RESET=$'\033[0m'

# Global counters for the final summary.
PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0
FAILED_CHECKS=()

pass() {
  # Marks a check as OK.
  echo "  ${GREEN}✓${RESET} $1"
  PASS_COUNT=$((PASS_COUNT + 1))
}

fail() {
  # Marks a check as CRITICAL failed.
  echo "  ${RED}✗${RESET} $1"
  FAIL_COUNT=$((FAIL_COUNT + 1))
  FAILED_CHECKS+=("$1")
}

warn() {
  # Warning: non-blocking but worth reviewing.
  echo "  ${YELLOW}!${RESET} $1"
  WARN_COUNT=$((WARN_COUNT + 1))
}

section() {
  # Section header for a group of checks.
  echo ""
  echo "${BOLD}==> $1${RESET}"
}

# Wrapper to run a SOQL query silently and return JSON.
# If the query fails, returns an empty string so the caller can decide.
soql() {
  local query="$1"
  sf data query --target-org "${ORG_ALIAS}" --query "${query}" --json 2>/dev/null || echo ""
}

# Wrapper for Tooling API queries (metadata like PermissionSet, RecordType,
# AttributeDefinition, etc. where applicable).
soql_tooling() {
  local query="$1"
  sf data query --target-org "${ORG_ALIAS}" --use-tooling-api --query "${query}" --json 2>/dev/null || echo ""
}

# Extracts totalSize from a sf data query JSON payload (0 if not parseable).
total_size() {
  local json="$1"
  echo "${json}" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('result',{}).get('totalSize',0))" 2>/dev/null || echo "0"
}

echo "${BOLD}Prerequisites check — Seguros ALFA demo${RESET}"
echo "Org alias: ${ORG_ALIAS}"
echo "Date:      $(date '+%Y-%m-%d %H:%M:%S')"

# ============================================================================
# CHECK 1: Org connection
# ----------------------------------------------------------------------------
# Without a connection there is no point running anything else; bail out early.
# ============================================================================
section "1. Org connection"

if ORG_INFO=$(sf org display --target-org "${ORG_ALIAS}" --json 2>/dev/null); then
  # Pull username and instance URL to give context in the log.
  USERNAME=$(echo "${ORG_INFO}" | python3 -c "import sys,json;print(json.load(sys.stdin)['result']['username'])" 2>/dev/null || echo "unknown")
  INSTANCE_URL=$(echo "${ORG_INFO}" | python3 -c "import sys,json;print(json.load(sys.stdin)['result']['instanceUrl'])" 2>/dev/null || echo "unknown")
  pass "Connected as ${USERNAME}"
  pass "Instance URL: ${INSTANCE_URL}"
else
  fail "Could not connect to org '${ORG_ALIAS}'. Run 'sf org login web -a ${ORG_ALIAS}' first."
  # No connection means there is no point continuing.
  echo ""
  echo "${RED}${BOLD}FATAL:${RESET} without a connection we cannot verify the rest. Aborting."
  exit 1
fi

# Look up the UserId of the connected user for PSL/PermissionSet checks.
USER_ID_JSON=$(soql "SELECT Id FROM User WHERE Username='${USERNAME}' LIMIT 1")
CURRENT_USER_ID=$(echo "${USER_ID_JSON}" | python3 -c "import sys,json;d=json.load(sys.stdin);print(d['result']['records'][0]['Id'])" 2>/dev/null || echo "")
if [[ -z "${CURRENT_USER_ID}" ]]; then
  fail "Could not resolve UserId for the active user — license/permset checks will be skipped."
else
  pass "Resolved UserId: ${CURRENT_USER_ID}"
fi

# ============================================================================
# CHECK 2: Permission Set Licenses (PSL) assigned to the active user
# ----------------------------------------------------------------------------
# PSLs enable RCA, Digital Insurance, Configurator and Core Pricing features.
# Without them, many objects and flows do not even appear.
# ============================================================================
section "2. Critical Permission Set Licenses assigned to the user"

# List of PSLs the demo requires. Exact DeveloperName values.
CRITICAL_PSLS=(
  "RevenueLifecycleManagementUserPsl"        # RCA runtime
  "IndustriesConfiguratorPsl"                # Advanced Configurator
  "DynamicRevenueOrchestratorUserPsl"        # DRO — revenue orchestrator
  "DigitalInsuranceClaimManagementUser"      # Digital Insurance Claims
  "ClaimManagementAdmin"                     # Claims admin
  "DigitalInsurancePolicyAdminUserPsl"       # DIS policy admin
  "CorePricingDesignTime"                    # Core Pricing design time
  "CorePricingRunTime"                       # Core Pricing runtime
)

if [[ -n "${CURRENT_USER_ID}" ]]; then
  # Pull ALL PSLs assigned to the user in a single query, then filter locally.
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
      pass "PSL assigned: ${psl}"
    else
      fail "PSL NOT assigned: ${psl} (assign with: sf org assign permsetlicense -n ${psl})"
    fi
  done
else
  fail "Skipping PSL checks — UserId missing."
fi

# ============================================================================
# CHECK 3: Critical Permission Sets
# ----------------------------------------------------------------------------
# PSLs enable the license, but many features additionally require a specific
# Permission Set assigned. We verify they exist in the org and are assigned
# to the user.
# ============================================================================
section "3. Critical Permission Sets assigned to the user"

CRITICAL_PERMSETS=(
  "AdvancedConfiguratorDesigner"          # Author Configurator rules
  "ProductConfigurationRulesDesigner"     # PCM rules
  "IndustriesConfiguratorPlatformApi"     # Configurator API
  "ProductCatalogManagementViewer"        # PCM viewer
  "ProductDiscoveryUser"                  # Product Discovery
  "ContextServiceRuntimePsl"              # Context Service runtime
  "StageManagementUser"                   # DRO stage management
  "BRERuntime"                            # Business Rules Engine
  "OmniStudioExecution"                   # OmniStudio runtime
)

if [[ -n "${CURRENT_USER_ID}" ]]; then
  # Pull assigned permsets a single time.
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
      pass "PermSet assigned: ${ps}"
    else
      # Before marking as failed, check whether it at least EXISTS in the org.
      # An unassigned PS is usually fixed with `sf org assign permset -n <name>`.
      EXISTS_JSON=$(soql "SELECT Id FROM PermissionSet WHERE Name='${ps}' LIMIT 1")
      EXISTS_COUNT=$(total_size "${EXISTS_JSON}")
      if [[ "${EXISTS_COUNT}" == "0" ]]; then
        fail "PermSet '${ps}' does NOT EXIST in the org (feature not enabled or different name)"
      else
        fail "PermSet '${ps}' exists but is NOT assigned (assign with: sf org assign permset -n ${ps})"
      fi
    fi
  done
else
  fail "Skipping PermissionSet checks — UserId missing."
fi

# ============================================================================
# CHECK 4: Accessibility of critical sObjects
# ----------------------------------------------------------------------------
# If an sObject is not queryable, either the feature is not enabled or the
# user lacks permissions. Either way it fails; investigate before running
# the scripts. Note: we use LIMIT 0 to avoid pulling data — just to validate
# that the query compiles.
# ============================================================================
section "4. Critical sObjects accessible"

CRITICAL_SOBJECTS=(
  "InsurancePolicy"                       # Base policy
  "Claim"                                 # Claim
  "ClaimCoverage"                         # Claim coverage
  "ClaimCoveragePaymentDetail"            # Payment detail per coverage
  "ClaimPaymentSummary"                   # Payment summary
  "ClaimCovReserveAdjustment"             # Reserve adjustments
  "InsurancePolicyTransaction"            # Policy transactions
  "InsuranceClause"                       # Master clauses
  "InsuranceProductClause"                # Clauses by product
  "InsurancePolicyProductClause"          # Clauses by policy
  "InsProductClauseVariableMap"           # Clause variable mapping
  "Product2"                              # Product (RCA/PCM base)
  "ProductClassification"                 # PCM classification
  "AttributeDefinition"                   # PCM attributes
  "ProductAttributeDefinition"            # Attribute per product
  "ProductComponentGroup"                 # Bundles / groups
  "ProductRelatedComponent"               # Bundle/child relationships
)

for obj in "${CRITICAL_SOBJECTS[@]}"; do
  # LIMIT 0 validates DDL/permission without touching data.
  if sf data query --target-org "${ORG_ALIAS}" --query "SELECT Id FROM ${obj} LIMIT 0" --json >/dev/null 2>&1; then
    pass "sObject accessible: ${obj}"
  else
    fail "sObject NOT accessible: ${obj} (feature not enabled or missing read permissions)"
  fi
done

# ============================================================================
# CHECK 5: Quote / QuoteLineItem fields for RCA runtime
# ----------------------------------------------------------------------------
# Quote.CalculationStatus having many values is a proxy for the RCA runtime
# being installed. QuoteLineItem.RevenueCloudPackagingFlag signals that the
# bundle packaging logic is available.
# ============================================================================
section "5. Quote / QuoteLineItem fields (RCA runtime proof)"

# Count values of the CalculationStatus picklist via Tooling API.
# The RCA runtime usually ships with 20+ values; an org without RCA has <5.
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
  pass "Quote.CalculationStatus has ${CS_COUNT} values (RCA runtime installed)"
elif [[ "${CS_COUNT}" -gt 0 ]]; then
  fail "Quote.CalculationStatus only has ${CS_COUNT} values (20+ expected). RCA runtime is likely NOT installed."
else
  fail "Could not read Quote.CalculationStatus — RCA runtime probably absent."
fi

# Verify that QuoteLineItem.RevenueCloudPackagingFlag exists.
QLI_FLAG_JSON=$(soql_tooling "SELECT Id FROM FieldDefinition WHERE EntityDefinition.QualifiedApiName='QuoteLineItem' AND QualifiedApiName='RevenueCloudPackagingFlag'")
QLI_FLAG_COUNT=$(total_size "${QLI_FLAG_JSON}")
if [[ "${QLI_FLAG_COUNT}" == "1" ]]; then
  pass "QuoteLineItem.RevenueCloudPackagingFlag exists (RCA packaging available)"
else
  fail "QuoteLineItem.RevenueCloudPackagingFlag does NOT exist (RCA packaging not enabled)"
fi

# ============================================================================
# CHECK 6: ProductSellingModel 'One Time'
# ----------------------------------------------------------------------------
# The SellingModel is required for Product2 in RCA. "One Time" is shipped by
# default in orgs with RCA enabled.
# ============================================================================
section "6. ProductSellingModel 'One Time'"

PSM_JSON=$(soql "SELECT Id, Name FROM ProductSellingModel WHERE Name='One Time' AND Status='Active' LIMIT 1")
PSM_COUNT=$(total_size "${PSM_JSON}")
if [[ "${PSM_COUNT}" -ge 1 ]]; then
  pass "ProductSellingModel 'One Time' exists and is active"
else
  fail "ProductSellingModel 'One Time' does NOT exist / is not active — create one before running the next scripts"
fi

# ============================================================================
# CHECK 7: Standard Pricebook
# ----------------------------------------------------------------------------
# Every Product2 linked to an Opportunity/Quote requires a PricebookEntry on
# the Standard Pricebook. If it is not active, the flows will fail.
# ============================================================================
section "7. Standard Pricebook active"

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
  pass "Standard Pricebook exists and is active"
elif [[ "${PB_COUNT}" -ge 1 ]]; then
  fail "Standard Pricebook exists but is NOT active (activate it from Setup > Price Books)"
else
  fail "Standard Pricebook NOT found"
fi

# ============================================================================
# CHECK 8: ProductCatalog 'Insurance Catalog'
# ----------------------------------------------------------------------------
# PCM requires at least one ProductCatalog to organize products. If it does
# not exist, we print instructions to create it (we do not create it here to
# avoid modifying state without authorization).
# ============================================================================
section "8. ProductCatalog 'Insurance Catalog'"

CAT_JSON=$(soql "SELECT Id, Name FROM ProductCatalog WHERE Name='Insurance Catalog' LIMIT 1")
CAT_COUNT=$(total_size "${CAT_JSON}")
if [[ "${CAT_COUNT}" -ge 1 ]]; then
  pass "ProductCatalog 'Insurance Catalog' exists"
else
  warn "ProductCatalog 'Insurance Catalog' does NOT exist. Create with:"
  warn "  sf data create record --sobject ProductCatalog --values \"Name='Insurance Catalog'\" --target-org ${ORG_ALIAS}"
fi

# ============================================================================
# CHECK 9: Product2 RecordTypes ('Commercial' and 'Coverage')
# ----------------------------------------------------------------------------
# The scripts that follow create products with these RecordTypes; if they do
# not exist, the inserts fail. We look up by DeveloperName (case-sensitive
# and stable).
# ============================================================================
section "9. Product2 RecordTypes"

for rt in "Commercial" "Coverage"; do
  RT_JSON=$(soql "SELECT Id FROM RecordType WHERE SobjectType='Product2' AND DeveloperName='${rt}' LIMIT 1")
  RT_COUNT=$(total_size "${RT_JSON}")
  if [[ "${RT_COUNT}" -ge 1 ]]; then
    pass "RecordType Product2.${rt} exists"
  else
    fail "RecordType Product2.${rt} does NOT exist (create it before running the next scripts)"
  fi
done

# ============================================================================
# CHECK 10: Opportunity RecordType 'SimpleOpportunity'
# ----------------------------------------------------------------------------
# Critical for RCA: quotes and revenue flows assume this RecordType. If it
# does not exist, orchestration breaks silently.
# ============================================================================
section "10. Opportunity RecordType 'SimpleOpportunity'"

OPP_RT_JSON=$(soql "SELECT Id FROM RecordType WHERE SobjectType='Opportunity' AND DeveloperName='SimpleOpportunity' LIMIT 1")
OPP_RT_COUNT=$(total_size "${OPP_RT_JSON}")
if [[ "${OPP_RT_COUNT}" -ge 1 ]]; then
  pass "RecordType Opportunity.SimpleOpportunity exists (RCA-ready)"
else
  fail "RecordType Opportunity.SimpleOpportunity does NOT exist — RCA will not work correctly"
fi

# ============================================================================
# Final summary
# ============================================================================
echo ""
echo "${BOLD}============================================================${RESET}"
echo "${BOLD}Summary${RESET}"
echo "${BOLD}============================================================${RESET}"
echo "  ${GREEN}Passed:${RESET}   ${PASS_COUNT}"
echo "  ${YELLOW}Warnings:${RESET} ${WARN_COUNT}"
echo "  ${RED}Failed:${RESET}   ${FAIL_COUNT}"

if [[ ${FAIL_COUNT} -gt 0 ]]; then
  echo ""
  echo "${RED}${BOLD}Failed checks:${RESET}"
  for f in "${FAILED_CHECKS[@]}"; do
    echo "  - ${f}"
  done
  echo ""
  echo "${RED}${BOLD}DO NOT run the next scripts until the failures are resolved.${RESET}"
  exit 1
fi

echo ""
echo "${GREEN}${BOLD}✓ Org ready. You can proceed with the next scripts.${RESET}"
exit 0
