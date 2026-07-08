#!/usr/bin/env bash
# ============================================================================
# 04-block3-claim.sh
# Block 3 of the Seguros ALFA RFP: creates claim SIN-PYME-2026-0001 with
# its full tree of related objects (participants, items, coverages,
# reserves, and payments).
#
# Project rules:
#   - Idempotency: each section queries before creating. If the record
#     already exists, its Id is reused.
#   - SF_DISABLE_LOG_FILE=true on every `sf` invocation (CLI feedback in
#     this environment; commands fail without it).
#   - IDs are NEVER hardcoded, they're always resolved via dynamic SOQL.
#   - Comments in English.
# ============================================================================

set -euo pipefail

# ----------------------------------------------------------------------------
# Configuration
# ----------------------------------------------------------------------------
TARGET_ORG="${TARGET_ORG:-storm-a80cc3fdb26547}"
SF="SF_DISABLE_LOG_FILE=true sf"

echo "=============================================================="
echo " Block 3 - Claim SIN-PYME-2026-0001"
echo " Target org: ${TARGET_ORG}"
echo "=============================================================="

# ----------------------------------------------------------------------------
# Helper: runs SOQL and returns the first Id found (or empty)
# ----------------------------------------------------------------------------
query_id() {
  local soql="$1"
  eval "${SF} data query --target-org \"${TARGET_ORG}\" --query \"${soql}\" --json" \
    | /usr/bin/python3 -c "import json,sys; r=json.load(sys.stdin)['result']['records']; print(r[0]['Id'] if r else '')"
}

# ----------------------------------------------------------------------------
# 1) INITIAL LOOKUPS
# ----------------------------------------------------------------------------
echo ""
echo ">>> [1/9] Initial lookups"

ACCOUNT_PANADERIA_ID=$(query_id "SELECT Id FROM Account WHERE Name = 'Panaderia La Espiga Dorada SAS' LIMIT 1")
[ -z "${ACCOUNT_PANADERIA_ID}" ] && { echo "ERROR: Panadería Account not found"; exit 1; }
echo "    Panadería Account:      ${ACCOUNT_PANADERIA_ID}"

OWNER_NEHUEN_ID=$(query_id "SELECT Id FROM User WHERE Name LIKE 'Nehuen%' AND IsActive = true LIMIT 1")
[ -z "${OWNER_NEHUEN_ID}" ] && { echo "ERROR: User Nehuen not found"; exit 1; }
echo "    Owner Nehuen:           ${OWNER_NEHUEN_ID}"

POLICY_ID=$(query_id "SELECT Id FROM InsurancePolicy WHERE Name = 'POL-PYME-2026-0001' LIMIT 1")
[ -z "${POLICY_ID}" ] && { echo "ERROR: Policy POL-PYME-2026-0001 not found"; exit 1; }
echo "    Policy PYME:            ${POLICY_ID}"

# InsurancePolicyCoverages: identified by their relationship to the policy
# and the coverage name. Assumes the CoverageType lookup already exists
# with the names 'Incendio' and 'Equipo Electronico'.
IPC_INCENDIO_ID=$(query_id "SELECT Id FROM InsurancePolicyCoverage WHERE InsurancePolicyId = '${POLICY_ID}' AND Name LIKE '%Incendio%' LIMIT 1")
[ -z "${IPC_INCENDIO_ID}" ] && { echo "ERROR: IPC Incendio not found"; exit 1; }
echo "    IPC Incendio:           ${IPC_INCENDIO_ID}"

IPC_EQUIPO_ID=$(query_id "SELECT Id FROM InsurancePolicyCoverage WHERE InsurancePolicyId = '${POLICY_ID}' AND Name LIKE '%Equipo%Electr%' LIMIT 1")
[ -z "${IPC_EQUIPO_ID}" ] && { echo "ERROR: IPC Equipo Electrónico not found"; exit 1; }
echo "    IPC Equipo Electrónico: ${IPC_EQUIPO_ID}"

# ----------------------------------------------------------------------------
# 2) CLAIM SIN-PYME-2026-0001
# ----------------------------------------------------------------------------
echo ""
echo ">>> [2/9] Claim SIN-PYME-2026-0001"

CLAIM_NAME="SIN-PYME-2026-0001"
CLAIM_ID=$(query_id "SELECT Id FROM Claim WHERE Name = '${CLAIM_NAME}' LIMIT 1")

if [ -z "${CLAIM_ID}" ]; then
  CLAIM_SUMMARY="Partial fire in the bakery's production area on September 10, 2026. Damage to the main industrial oven, metal dispatch shelving, and business interruption for 5 days of operational shutdown. Initial expert assessment confirms electrical origin (short circuit in the secondary panel). Bogotá Fire Department responded to the emergency."

  CLAIM_ID=$(eval "${SF} data create record --target-org \"${TARGET_ORG}\" --sobject Claim --values \"\
    Name='${CLAIM_NAME}' \
    PolicyNumberId='${POLICY_ID}' \
    AccountId='${ACCOUNT_PANADERIA_ID}' \
    OwnerId='${OWNER_NEHUEN_ID}' \
    ClaimType='Fire/Smoke Damage' \
    Status='Coverage Confirmed' \
    Severity='High' \
    LossType='Partial Loss' \
    ClaimReasonType='Accident' \
    LossDate=2026-09-10 \
    InitiationDate=2026-09-11 \
    EstimatedAmount=48000000 \
    Summary='${CLAIM_SUMMARY}'\" --json" \
    | /usr/bin/python3 -c "import json,sys; print(json.load(sys.stdin)['result']['id'])")
  echo "    Claim created:          ${CLAIM_ID}"
else
  echo "    Claim already exists:   ${CLAIM_ID}"
fi

# ----------------------------------------------------------------------------
# 3) ACCOUNT: BOGOTÁ FIRE DEPARTMENT
# ----------------------------------------------------------------------------
echo ""
echo ">>> [3/9] Account Cuerpo de Bomberos de Bogotá"

BOMBEROS_ID=$(query_id "SELECT Id FROM Account WHERE Name = 'Cuerpo de Bomberos de Bogota' LIMIT 1")

if [ -z "${BOMBEROS_ID}" ]; then
  BOMBEROS_ID=$(eval "${SF} data create record --target-org \"${TARGET_ORG}\" --sobject Account --values \"\
    Name='Cuerpo de Bomberos de Bogota' \
    Industry='Government' \
    Type='Other'\" --json" \
    | /usr/bin/python3 -c "import json,sys; print(json.load(sys.stdin)['result']['id'])")
  echo "    Bomberos created:       ${BOMBEROS_ID}"
else
  echo "    Bomberos already exists: ${BOMBEROS_ID}"
fi

# ----------------------------------------------------------------------------
# 4) CONTACT ALAN REED (senior adjuster)
# ----------------------------------------------------------------------------
echo ""
echo ">>> [4/9] Contact Alan Reed"

ALAN_ID=$(query_id "SELECT Id FROM Contact WHERE FirstName = 'Alan' AND LastName = 'Reed' LIMIT 1")

if [ -z "${ALAN_ID}" ]; then
  ALAN_ID=$(eval "${SF} data create record --target-org \"${TARGET_ORG}\" --sobject Contact --values \"\
    FirstName='Alan' \
    LastName='Reed' \
    Title='Ajustador Senior Ramo Patrimonial' \
    Email='alan.reed@seguros-alfa.demo' \
    AccountId='${ACCOUNT_PANADERIA_ID}'\" --json" \
    | /usr/bin/python3 -c "import json,sys; print(json.load(sys.stdin)['result']['id'])")
  echo "    Alan Reed created:      ${ALAN_ID}"
else
  echo "    Alan Reed already exists: ${ALAN_ID}"
fi

# ----------------------------------------------------------------------------
# 5) CLAIM PARTICIPANTS (3)
# ----------------------------------------------------------------------------
echo ""
echo ">>> [5/9] ClaimParticipants (3)"

create_participant() {
  local role="$1"
  local account_id="$2"
  local contact_id="$3"

  # Filter by Claim + Role + participant for idempotency
  local filter="ClaimId = '${CLAIM_ID}' AND Roles = '${role}'"
  if [ -n "${account_id}" ]; then
    filter="${filter} AND ParticipantAccountId = '${account_id}'"
  else
    filter="${filter} AND ParticipantContactId = '${contact_id}'"
  fi

  local existing_id
  existing_id=$(query_id "SELECT Id FROM ClaimParticipant WHERE ${filter} LIMIT 1")

  if [ -n "${existing_id}" ]; then
    echo "    Participant ${role} already exists: ${existing_id}"
    return
  fi

  local values="ClaimId='${CLAIM_ID}' Roles='${role}'"
  if [ -n "${account_id}" ]; then
    values="${values} ParticipantAccountId='${account_id}'"
  else
    values="${values} ParticipantContactId='${contact_id}'"
  fi

  local new_id
  new_id=$(eval "${SF} data create record --target-org \"${TARGET_ORG}\" --sobject ClaimParticipant --values \"${values}\" --json" \
    | /usr/bin/python3 -c "import json,sys; print(json.load(sys.stdin)['result']['id'])")
  echo "    Participant ${role} created: ${new_id}"
}

# 5.1 Claimant = Panadería
create_participant "Claimant" "${ACCOUNT_PANADERIA_ID}" ""

# 5.2 Loss Adjuster = Alan Reed (contact)
create_participant "Loss Adjuster" "" "${ALAN_ID}"

# 5.3 Witness = Bomberos
create_participant "Witness" "${BOMBEROS_ID}" ""

# ----------------------------------------------------------------------------
# 6) CLAIM ITEMS (3)
# ----------------------------------------------------------------------------
# =============================================================================
# HEADS UP - HIDDEN VALIDATION RULE:
#   Financial Services Cloud enforces a validation rule on ClaimItem that
#   requires FaultDate. It does NOT appear as required in the standard UI.
#   Omitting it makes the insert fail with "FaultDate is required" (a poorly
#   descriptive error). We always pass it in ISO 8601 UTC format.
# =============================================================================
echo ""
echo ">>> [6/9] ClaimItems (3) - FaultDate REQUIRED by validation rule"

create_claim_item() {
  local name="$1"
  local ipc_id="$2"

  local existing_id
  existing_id=$(query_id "SELECT Id FROM ClaimItem WHERE ClaimId = '${CLAIM_ID}' AND Name = '${name}' LIMIT 1")

  if [ -n "${existing_id}" ]; then
    echo "    ClaimItem '${name}' already exists: ${existing_id}"
    echo "${existing_id}"
    return
  fi

  local new_id
  new_id=$(eval "${SF} data create record --target-org \"${TARGET_ORG}\" --sobject ClaimItem --values \"\
    Name='${name}' \
    ClaimId='${CLAIM_ID}' \
    Category='Damaged Property' \
    FaultDate=2026-09-10T14:30:00.000Z \
    InsurancePolicyCoverageId='${ipc_id}'\" --json" \
    | /usr/bin/python3 -c "import json,sys; print(json.load(sys.stdin)['result']['id'])")
  echo "    ClaimItem '${name}' created: ${new_id}" >&2
  echo "${new_id}"
}

CI_HORNO_ID=$(create_claim_item "Horno Industrial Rational SCC-102" "${IPC_EQUIPO_ID}")
CI_ESTANTERIA_ID=$(create_claim_item "Estanteria Metalica" "${IPC_INCENDIO_ID}")
CI_LUCRO_ID=$(create_claim_item "Lucro Cesante 5 dias" "${IPC_INCENDIO_ID}")

# ----------------------------------------------------------------------------
# 7) CLAIM COVERAGE (1)
# ----------------------------------------------------------------------------
# =============================================================================
# HEADS UP - HIDDEN VALIDATION RULE:
#   ClaimCoverage requires ClaimItemId (custom validation rule from the
#   claims vertical). In the standard reference it appears as optional, but
#   the insert fails if it comes in empty. We link it to the Horno item as
#   the primary representative of the coverage.
# =============================================================================
echo ""
echo ">>> [7/9] ClaimCoverage - ClaimItemId REQUIRED by validation rule"

CC_NAME="CC-SIN-PYME-2026-0001-Incendio"
CC_ID=$(query_id "SELECT Id FROM ClaimCoverage WHERE Name = '${CC_NAME}' LIMIT 1")

if [ -z "${CC_ID}" ]; then
  CC_ID=$(eval "${SF} data create record --target-org \"${TARGET_ORG}\" --sobject ClaimCoverage --values \"\
    Name='${CC_NAME}' \
    ClaimId='${CLAIM_ID}' \
    InsurancePolicyCoverageId='${IPC_INCENDIO_ID}' \
    ClaimItemId='${CI_HORNO_ID}' \
    InternalReserveMode='CoverageReserve' \
    Status='Coverage Confirmed' \
    LossReserveAmount=45000000 \
    ExpenseReserveAmount=5000000\" --json" \
    | /usr/bin/python3 -c "import json,sys; print(json.load(sys.stdin)['result']['id'])")
  echo "    ClaimCoverage created:  ${CC_ID}"
else
  echo "    ClaimCoverage exists:   ${CC_ID}"
fi

# ----------------------------------------------------------------------------
# 8) CLAIM COVERAGE RESERVE ADJUSTMENTS (2) + PAYMENT SUMMARY (1)
# ----------------------------------------------------------------------------
echo ""
echo ">>> [8/9] Reserve Adjustments (2) + PaymentSummary (1)"

create_reserve_adj() {
  local name="$1"
  local amount="$2"

  local existing_id
  existing_id=$(query_id "SELECT Id FROM ClaimCovReserveAdjustment WHERE Name = '${name}' AND ClaimCoverageId = '${CC_ID}' LIMIT 1")

  if [ -n "${existing_id}" ]; then
    echo "    ReserveAdj '${name}' already exists: ${existing_id}"
    return
  fi

  local new_id
  new_id=$(eval "${SF} data create record --target-org \"${TARGET_ORG}\" --sobject ClaimCovReserveAdjustment --values \"\
    Name='${name}' \
    ClaimCoverageId='${CC_ID}' \
    AdjustmentAmount=${amount}\" --json" \
    | /usr/bin/python3 -c "import json,sys; print(json.load(sys.stdin)['result']['id'])")
  echo "    ReserveAdj '${name}' created: ${new_id}"
}

create_reserve_adj "Reserva perdida directa Incendio" "45000000"
create_reserve_adj "Reserva gasto lucro cesante" "5000000"

# ClaimPaymentSummary (1)
CPS_ID=$(query_id "SELECT Id FROM ClaimPaymentSummary WHERE ClaimId = '${CLAIM_ID}' LIMIT 1")

if [ -z "${CPS_ID}" ]; then
  CPS_ID=$(eval "${SF} data create record --target-org \"${TARGET_ORG}\" --sobject ClaimPaymentSummary --values \"\
    ClaimId='${CLAIM_ID}' \
    PaymentStatus='Pending Payment'\" --json" \
    | /usr/bin/python3 -c "import json,sys; print(json.load(sys.stdin)['result']['id'])")
  echo "    PaymentSummary created: ${CPS_ID}"
else
  echo "    PaymentSummary exists:  ${CPS_ID}"
fi

# ----------------------------------------------------------------------------
# 9) CLAIM COVERAGE PAYMENT DETAILS (3)
# ----------------------------------------------------------------------------
echo ""
echo ">>> [9/9] ClaimCoveragePaymentDetail (3)"

create_ccpd() {
  local name="$1"
  local type="$2"
  local status="$3"
  local payment_status="$4"
  local claimed="$5"
  local adjusted="$6"

  local existing_id
  existing_id=$(query_id "SELECT Id FROM ClaimCoveragePaymentDetail WHERE Name = '${name}' AND ClaimCoverageId = '${CC_ID}' LIMIT 1")

  if [ -n "${existing_id}" ]; then
    echo "    CCPD '${name}' already exists: ${existing_id}"
    return
  fi

  local new_id
  new_id=$(eval "${SF} data create record --target-org \"${TARGET_ORG}\" --sobject ClaimCoveragePaymentDetail --values \"\
    Name='${name}' \
    ClaimCoverageId='${CC_ID}' \
    ClaimPaymentSummaryId='${CPS_ID}' \
    Type='${type}' \
    Status='${status}' \
    PaymentStatus='${payment_status}' \
    ClaimedAmount=${claimed} \
    AdjustedAmount=${adjusted}\" --json" \
    | /usr/bin/python3 -c "import json,sys; print(json.load(sys.stdin)['result']['id'])")
  echo "    CCPD '${name}' created: ${new_id}"
}

# 9.1 Horno paid (32M)
create_ccpd "CCPD-01 Horno Pagado" "Loss" "Paid" "Paid" "32000000" "32000000"

# 9.2 Business interruption pending authority (8M) - approval flow pending
create_ccpd "CCPD-02 Lucro Cesante Pendiente Autoridad" "Expense" "Pending Authority" "Draft" "8000000" "8000000"

# 9.3 Shelving paid (8M)
create_ccpd "CCPD-03 Estanteria Pagada" "Loss" "Paid" "Paid" "8000000" "8000000"

# ----------------------------------------------------------------------------
# END
# ----------------------------------------------------------------------------
echo ""
echo "=============================================================="
echo " Block 3 complete. Claim ${CLAIM_NAME} ready for the demo."
echo "=============================================================="
