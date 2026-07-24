#!/usr/bin/env bash
# ============================================================================
# 00b-verify-baseline.sh
# ----------------------------------------------------------------------------
# Verifies that the target org matches the FINS QBranch IDO baseline
# documented in demo-metadata/baseline/*.md. This runs BEFORE any of the
# 01-05 scripts.
#
# What it checks:
#   - 35 required Permission Set Licenses assigned to the current user
#   - Critical Permission Sets assigned to the current user (FINS bundles,
#     Revenue Cloud, Contracts)
#   - Critical Record Types available (SimpleOpportunity, Coverage,
#     Commercial, FINS_InsurancePolicy_Property_Casualty)
#   - QBranch namespace package present (proxy for "correct IDO type")
#
# Exit codes:
#   0 -> All checks passed, safe to proceed
#   1 -> One or more critical items missing; DO NOT run the setup scripts
#
# Usage:
#   ./00b-verify-baseline.sh <org-alias>
#   ORG_ALIAS=<alias> ./00b-verify-baseline.sh
# ============================================================================

set -euo pipefail
export SF_DISABLE_LOG_FILE=true

ORG_ALIAS="${1:-${ORG_ALIAS:-}}"
if [[ -z "${ORG_ALIAS}" ]]; then
  echo "ERROR: pass the org alias as \$1 or export ORG_ALIAS=<alias>." >&2
  exit 1
fi

echo "=============================================================="
echo " Baseline verification against org alias '${ORG_ALIAS}'"
echo " (see demo-metadata/baseline/ for the full documented baseline)"
echo "=============================================================="

MISSING_PSL=0
MISSING_PS=0
MISSING_RT=0
MISSING_PKG=0

# ----------------------------------------------------------------------------
# Required PSLs (35 total — see baseline/permission-set-licenses.md)
# ----------------------------------------------------------------------------
REQUIRED_PSLS=(
  DigitalInsurancePolicyAdminUserPsl
  DigitalInsuranceProductAdminPsl
  DigitalInsuranceProductAdminRunTimePsl
  DigitalInsuranceClaimManagementAdmin
  DigitalInsuranceClaimManagementUser
  ClaimManagementAdmin
  ClaimMgmtPsl
  ClaimsManagementFoundationPsl
  ClaimFNOLPsl
  InsuranceClaimMgmtPsl
  FSCInsurancePsl
  FSCInsuranceRecordSummaryPsl
  InsurancePolicyAndClaimPsl
  InsuranceBrokeragePsl
  InsuranceGroupBenefitsPsl
  FSCFoundationsPsl
  FinancialServicesCloudExtensionPsl
  ClauseManagementUser
  ContractManagementUser
  RevenueLifecycleManagementUserPsl
  DynamicRevenueOrchestratorUserPsl
  IndustriesConfiguratorPsl
  CorePricingDesignTime
  CorePricingRunTime
  PennyPerfectPricingPsl
  PricingAndBillingPSL
  RatingDesignTimePsl
  RatingRunTimePsl
  ContextServiceAdminPsl
  ContextServiceRuntimePsl
  OmniStudioDesigner
  OmniStudioRuntime
  BREDesigner
  BRERuntime
  EinsteinForFinancialServicesPsl
  RevLifecycleMgmtBillingPsl
)

echo ""
echo "[1/4] Checking ${#REQUIRED_PSLS[@]} required Permission Set Licenses..."

ASSIGNED_PSLS="$(sf data query --target-org "${ORG_ALIAS}" --result-format csv \
  --query "SELECT PermissionSetLicense.DeveloperName FROM PermissionSetLicenseAssign WHERE AssigneeId IN (SELECT Id FROM User WHERE Username='$(sf org display --target-org "${ORG_ALIAS}" --json 2>/dev/null | python3 -c 'import sys,json,re;raw=sys.stdin.read();clean=re.sub(r"\x1b\[[0-9;]*[a-zA-Z]","",raw);print(json.loads(clean)["result"]["username"])')')" \
  2>/dev/null | tail -n +2 | tr -d '"')"

for psl in "${REQUIRED_PSLS[@]}"; do
  if echo "${ASSIGNED_PSLS}" | grep -qw "^${psl}$"; then
    printf "  \033[32mOK  \033[0m  %s\n" "${psl}"
  else
    printf "  \033[31mMISS\033[0m  %s\n" "${psl}"
    MISSING_PSL=$((MISSING_PSL + 1))
  fi
done

# ----------------------------------------------------------------------------
# Critical Permission Sets (subset — see baseline/permission-sets.md)
# ----------------------------------------------------------------------------
REQUIRED_PS=(
  FINS_Claims_Admin
  FINS_Claims_Misc
  FINS_ISS_INS_Demo_BrokerCRM
  FINS_ISS_Demo_INS_Service
  SDO_Revenue_Cloud_Base
  SDO_RLM_DRO
  Contracts_Object_Permissions
)

echo ""
echo "[2/4] Checking ${#REQUIRED_PS[@]} critical Permission Sets..."

ASSIGNED_PS="$(sf data query --target-org "${ORG_ALIAS}" --result-format csv \
  --query "SELECT PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId IN (SELECT Id FROM User WHERE Username='$(sf org display --target-org "${ORG_ALIAS}" --json 2>/dev/null | python3 -c 'import sys,json,re;raw=sys.stdin.read();clean=re.sub(r"\x1b\[[0-9;]*[a-zA-Z]","",raw);print(json.loads(clean)["result"]["username"])')')" \
  2>/dev/null | tail -n +2 | tr -d '"')"

for ps in "${REQUIRED_PS[@]}"; do
  if echo "${ASSIGNED_PS}" | grep -qw "^${ps}$"; then
    printf "  \033[32mOK  \033[0m  %s\n" "${ps}"
  else
    printf "  \033[31mMISS\033[0m  %s\n" "${ps}"
    MISSING_PS=$((MISSING_PS + 1))
  fi
done

# ----------------------------------------------------------------------------
# Critical Record Types
# ----------------------------------------------------------------------------
REQUIRED_RT=(
  "Product2:Commercial"
  "Product2:Coverage"
  "Opportunity:SimpleOpportunity"
  "InsurancePolicy:FINS_InsurancePolicy_Property_Casualty"
  "Account:SDO_Account_Simple"
)

echo ""
echo "[3/4] Checking ${#REQUIRED_RT[@]} critical Record Types..."

for rt in "${REQUIRED_RT[@]}"; do
  IFS=':' read -r sobject devname <<< "${rt}"
  COUNT="$(sf data query --target-org "${ORG_ALIAS}" --json \
    --query "SELECT Id FROM RecordType WHERE SObjectType='${sobject}' AND DeveloperName='${devname}' AND IsActive=true LIMIT 1" \
    2>/dev/null | python3 -c 'import sys,json,re;raw=sys.stdin.read();clean=re.sub(r"\x1b\[[0-9;]*[a-zA-Z]","",raw);print(len(json.loads(clean).get("result",{}).get("records",[])))' 2>/dev/null || echo 0)"
  if [[ "${COUNT}" == "1" ]]; then
    printf "  \033[32mOK  \033[0m  %s.%s\n" "${sobject}" "${devname}"
  else
    printf "  \033[31mMISS\033[0m  %s.%s\n" "${sobject}" "${devname}"
    MISSING_RT=$((MISSING_RT + 1))
  fi
done

# ----------------------------------------------------------------------------
# QBranch package (proxy for IDO type)
# ----------------------------------------------------------------------------
echo ""
echo "[4/4] Checking QBranch package (proxy for 'this is a QBranch IDO')..."
QB_COUNT="$(sf data query --target-org "${ORG_ALIAS}" --use-tooling-api --json \
  --query "SELECT Id FROM InstalledSubscriberPackage WHERE SubscriberPackage.NamespacePrefix='qbranch' LIMIT 1" \
  2>/dev/null | python3 -c 'import sys,json,re;raw=sys.stdin.read();clean=re.sub(r"\x1b\[[0-9;]*[a-zA-Z]","",raw);print(len(json.loads(clean).get("result",{}).get("records",[])))' 2>/dev/null || echo 0)"
if [[ "${QB_COUNT}" != "0" ]]; then
  printf "  \033[32mOK  \033[0m  qbranch package installed\n"
else
  printf "  \033[33mWARN\033[0m  qbranch package NOT installed — you may not be on a FINS QBranch IDO.\n"
  MISSING_PKG=$((MISSING_PKG + 1))
fi

# ----------------------------------------------------------------------------
# Summary
# ----------------------------------------------------------------------------
TOTAL=$((MISSING_PSL + MISSING_PS + MISSING_RT + MISSING_PKG))

echo ""
echo "=============================================================="
if [[ "${TOTAL}" -eq 0 ]]; then
  printf "  \033[32mBaseline OK\033[0m — all %d PSLs, %d PSs, %d Record Types and QBranch package present.\n" \
    "${#REQUIRED_PSLS[@]}" "${#REQUIRED_PS[@]}" "${#REQUIRED_RT[@]}"
  echo "  Safe to run 01-block1-product.sh and the rest."
  echo "=============================================================="
  exit 0
else
  printf "  \033[31mBaseline FAILED\033[0m — %d PSL missing, %d PS missing, %d RT missing, %d package warnings.\n" \
    "${MISSING_PSL}" "${MISSING_PS}" "${MISSING_RT}" "${MISSING_PKG}"
  echo ""
  echo "  Next steps:"
  echo "    - If PSs/PSLs are missing but the org is FINS QBranch IDO: assign them in Setup → your user → Permission Set (License) Assignments."
  echo "    - If the qbranch package is missing: you're not on the right IDO. Provision the FINS QBranch - INS on Core IDO from STORM."
  echo "    - See demo-metadata/baseline/*.md for the full lists and rationale."
  echo "=============================================================="
  exit 1
fi
