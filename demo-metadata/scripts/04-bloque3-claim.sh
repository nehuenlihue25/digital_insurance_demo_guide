#!/usr/bin/env bash
# ============================================================================
# 04-bloque3-claim.sh
# Bloque 3 del RFP Seguros ALFA: creacion del siniestro SIN-PYME-2026-0001
# con todo el arbol de objetos relacionados (participantes, items, coberturas,
# reservas y pagos).
#
# Reglas del proyecto:
#   - Idempotencia: cada seccion consulta antes de crear. Si el registro ya
#     existe se reutiliza el Id.
#   - SF_DISABLE_LOG_FILE=true en cada invocacion de `sf` (feedback del CLI
#     en este entorno; sin esto los comandos fallan).
#   - IDs NUNCA se hardcodean, siempre se resuelven con SOQL dinamica.
#   - Comentarios en espaniol.
# ============================================================================

set -euo pipefail

# ----------------------------------------------------------------------------
# Configuracion
# ----------------------------------------------------------------------------
TARGET_ORG="${TARGET_ORG:-storm-a80cc3fdb26547}"
SF="SF_DISABLE_LOG_FILE=true sf"

echo "=============================================================="
echo " Bloque 3 - Siniestro SIN-PYME-2026-0001"
echo " Target org: ${TARGET_ORG}"
echo "=============================================================="

# ----------------------------------------------------------------------------
# Helper: ejecuta SOQL y devuelve el primer Id encontrado (o vacio)
# ----------------------------------------------------------------------------
query_id() {
  local soql="$1"
  eval "${SF} data query --target-org \"${TARGET_ORG}\" --query \"${soql}\" --json" \
    | /usr/bin/python3 -c "import json,sys; r=json.load(sys.stdin)['result']['records']; print(r[0]['Id'] if r else '')"
}

# ----------------------------------------------------------------------------
# 1) LOOKUPS INICIALES
# ----------------------------------------------------------------------------
echo ""
echo ">>> [1/9] Lookups iniciales"

ACCOUNT_PANADERIA_ID=$(query_id "SELECT Id FROM Account WHERE Name = 'Panaderia La Espiga Dorada SAS' LIMIT 1")
[ -z "${ACCOUNT_PANADERIA_ID}" ] && { echo "ERROR: Account Panaderia no encontrada"; exit 1; }
echo "    Account Panaderia:      ${ACCOUNT_PANADERIA_ID}"

OWNER_NEHUEN_ID=$(query_id "SELECT Id FROM User WHERE Name LIKE 'Nehuen%' AND IsActive = true LIMIT 1")
[ -z "${OWNER_NEHUEN_ID}" ] && { echo "ERROR: Usuario Nehuen no encontrado"; exit 1; }
echo "    Owner Nehuen:           ${OWNER_NEHUEN_ID}"

POLICY_ID=$(query_id "SELECT Id FROM InsurancePolicy WHERE Name = 'POL-PYME-2026-0001' LIMIT 1")
[ -z "${POLICY_ID}" ] && { echo "ERROR: Policy POL-PYME-2026-0001 no encontrada"; exit 1; }
echo "    Policy PYME:            ${POLICY_ID}"

# InsurancePolicyCoverages: se identifican por su relacion con la policy y
# el nombre del coverage. Se asume que el CoverageType lookup ya existe
# con nombres 'Incendio' y 'Equipo Electronico'.
IPC_INCENDIO_ID=$(query_id "SELECT Id FROM InsurancePolicyCoverage WHERE InsurancePolicyId = '${POLICY_ID}' AND Name LIKE '%Incendio%' LIMIT 1")
[ -z "${IPC_INCENDIO_ID}" ] && { echo "ERROR: IPC Incendio no encontrado"; exit 1; }
echo "    IPC Incendio:           ${IPC_INCENDIO_ID}"

IPC_EQUIPO_ID=$(query_id "SELECT Id FROM InsurancePolicyCoverage WHERE InsurancePolicyId = '${POLICY_ID}' AND Name LIKE '%Equipo%Electr%' LIMIT 1")
[ -z "${IPC_EQUIPO_ID}" ] && { echo "ERROR: IPC Equipo Electronico no encontrado"; exit 1; }
echo "    IPC Equipo Electronico: ${IPC_EQUIPO_ID}"

# ----------------------------------------------------------------------------
# 2) CLAIM SIN-PYME-2026-0001
# ----------------------------------------------------------------------------
echo ""
echo ">>> [2/9] Claim SIN-PYME-2026-0001"

CLAIM_NAME="SIN-PYME-2026-0001"
CLAIM_ID=$(query_id "SELECT Id FROM Claim WHERE Name = '${CLAIM_NAME}' LIMIT 1")

if [ -z "${CLAIM_ID}" ]; then
  CLAIM_SUMMARY="Incendio parcial en area de produccion de la panaderia el 10 de septiembre de 2026. Afectacion al horno industrial principal, estanteria metalica de despacho y lucro cesante por 5 dias de paralizacion operativa. Pericia inicial confirma origen electrico (corto en tablero secundario). Bomberos de Bogota atendio la emergencia."

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
  echo "    Claim creado:           ${CLAIM_ID}"
else
  echo "    Claim ya existe:        ${CLAIM_ID}"
fi

# ----------------------------------------------------------------------------
# 3) ACCOUNT BOMBEROS DE BOGOTA
# ----------------------------------------------------------------------------
echo ""
echo ">>> [3/9] Account Cuerpo de Bomberos de Bogota"

BOMBEROS_ID=$(query_id "SELECT Id FROM Account WHERE Name = 'Cuerpo de Bomberos de Bogota' LIMIT 1")

if [ -z "${BOMBEROS_ID}" ]; then
  BOMBEROS_ID=$(eval "${SF} data create record --target-org \"${TARGET_ORG}\" --sobject Account --values \"\
    Name='Cuerpo de Bomberos de Bogota' \
    Industry='Government' \
    Type='Other'\" --json" \
    | /usr/bin/python3 -c "import json,sys; print(json.load(sys.stdin)['result']['id'])")
  echo "    Bomberos creado:        ${BOMBEROS_ID}"
else
  echo "    Bomberos ya existe:     ${BOMBEROS_ID}"
fi

# ----------------------------------------------------------------------------
# 4) CONTACT ALAN REED (ajustador senior)
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
  echo "    Alan Reed creado:       ${ALAN_ID}"
else
  echo "    Alan Reed ya existe:    ${ALAN_ID}"
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

  # Filtro por Claim + Role + participante para idempotencia
  local filter="ClaimId = '${CLAIM_ID}' AND Roles = '${role}'"
  if [ -n "${account_id}" ]; then
    filter="${filter} AND ParticipantAccountId = '${account_id}'"
  else
    filter="${filter} AND ParticipantContactId = '${contact_id}'"
  fi

  local existing_id
  existing_id=$(query_id "SELECT Id FROM ClaimParticipant WHERE ${filter} LIMIT 1")

  if [ -n "${existing_id}" ]; then
    echo "    Participant ${role} ya existe: ${existing_id}"
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
  echo "    Participant ${role} creado: ${new_id}"
}

# 5.1 Claimant = Panaderia
create_participant "Claimant" "${ACCOUNT_PANADERIA_ID}" ""

# 5.2 Loss Adjuster = Alan Reed (contact)
create_participant "Loss Adjuster" "" "${ALAN_ID}"

# 5.3 Witness = Bomberos
create_participant "Witness" "${BOMBEROS_ID}" ""

# ----------------------------------------------------------------------------
# 6) CLAIM ITEMS (3)
# ----------------------------------------------------------------------------
# =============================================================================
# ATENCION - VALIDATION RULE OCULTA:
#   FinancialServicesCloud aplica una validation rule sobre ClaimItem que
#   requiere FaultDate obligatorio. NO figura en la UI estandar como required.
#   Si se omite, el insert falla con "FaultDate is required" (error poco
#   descriptivo). Aqui se pasa siempre en formato ISO 8601 UTC.
# =============================================================================
echo ""
echo ">>> [6/9] ClaimItems (3) - FaultDate REQUERIDO por validation rule"

create_claim_item() {
  local name="$1"
  local ipc_id="$2"

  local existing_id
  existing_id=$(query_id "SELECT Id FROM ClaimItem WHERE ClaimId = '${CLAIM_ID}' AND Name = '${name}' LIMIT 1")

  if [ -n "${existing_id}" ]; then
    echo "    ClaimItem '${name}' ya existe: ${existing_id}"
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
  echo "    ClaimItem '${name}' creado: ${new_id}" >&2
  echo "${new_id}"
}

CI_HORNO_ID=$(create_claim_item "Horno Industrial Rational SCC-102" "${IPC_EQUIPO_ID}")
CI_ESTANTERIA_ID=$(create_claim_item "Estanteria Metalica" "${IPC_INCENDIO_ID}")
CI_LUCRO_ID=$(create_claim_item "Lucro Cesante 5 dias" "${IPC_INCENDIO_ID}")

# ----------------------------------------------------------------------------
# 7) CLAIM COVERAGE (1)
# ----------------------------------------------------------------------------
# =============================================================================
# ATENCION - VALIDATION RULE OCULTA:
#   ClaimCoverage requiere ClaimItemId obligatorio (validation rule custom
#   del vertical de siniestros). En la referencia estandar aparece como
#   opcional pero el insert falla si viene vacio. Se enlaza al item Horno
#   como representante principal de la cobertura.
# =============================================================================
echo ""
echo ">>> [7/9] ClaimCoverage - ClaimItemId REQUERIDO por validation rule"

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
  echo "    ClaimCoverage creado:   ${CC_ID}"
else
  echo "    ClaimCoverage existe:   ${CC_ID}"
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
    echo "    ReserveAdj '${name}' ya existe: ${existing_id}"
    return
  fi

  local new_id
  new_id=$(eval "${SF} data create record --target-org \"${TARGET_ORG}\" --sobject ClaimCovReserveAdjustment --values \"\
    Name='${name}' \
    ClaimCoverageId='${CC_ID}' \
    AdjustmentAmount=${amount}\" --json" \
    | /usr/bin/python3 -c "import json,sys; print(json.load(sys.stdin)['result']['id'])")
  echo "    ReserveAdj '${name}' creado: ${new_id}"
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
  echo "    PaymentSummary creado:  ${CPS_ID}"
else
  echo "    PaymentSummary existe:  ${CPS_ID}"
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
    echo "    CCPD '${name}' ya existe: ${existing_id}"
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
  echo "    CCPD '${name}' creado: ${new_id}"
}

# 9.1 Horno pagado (32M)
create_ccpd "CCPD-01 Horno Pagado" "Loss" "Paid" "Paid" "32000000" "32000000"

# 9.2 Lucro Cesante pendiente autoridad (8M) - flujo de aprobacion pendiente
create_ccpd "CCPD-02 Lucro Cesante Pendiente Autoridad" "Expense" "Pending Authority" "Draft" "8000000" "8000000"

# 9.3 Estanteria pagada (8M)
create_ccpd "CCPD-03 Estanteria Pagada" "Loss" "Paid" "Paid" "8000000" "8000000"

# ----------------------------------------------------------------------------
# FIN
# ----------------------------------------------------------------------------
echo ""
echo "=============================================================="
echo " Bloque 3 completado. Claim ${CLAIM_NAME} listo para demo."
echo "=============================================================="
