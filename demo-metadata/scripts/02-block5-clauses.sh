#!/usr/bin/env bash
# =============================================================================
# 02-block5-clauses.sh
# -----------------------------------------------------------------------------
# Creates PRODUCT-LEVEL clauses and exclusions for the "Plan Empresarial"
# bundle in the segPymeEmpresarial portfolio (Seguros ALFA).
#
# IMPORTANT NOTE:
#   This script creates the CLAUSES at the product level (InsuranceClause +
#   InsuranceProductClause + VariableMap). Policy-level clauses
#   (InsurancePolicyProductClause) are created by 03-block2-policy.sh when
#   the policy POL-PYME-2026-0001 is materialized.
#
# Objects created:
#   1) InsuranceClause                (6 records: 3 Clause + 3 Exclusion)
#   2) InsuranceProductClause         (6 junctions to the Plan Empresarial bundle)
#   3) InsProductClauseVariableMap    (3 dynamic tokens)
#
# Rules:
#   - Idempotent: if records already exist, UPDATE instead of INSERT.
#   - All lookups are performed dynamically (Product2, InsuranceClause).
#   - Correct field: `Type` (NOT `ClauseType`).
#   - Prefix SF_DISABLE_LOG_FILE=true on every sf invocation.
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# Environment configuration
# -----------------------------------------------------------------------------
export SF_DISABLE_LOG_FILE=true

TARGET_ORG="${TARGET_ORG:-alfa-storm}"
BUNDLE_CODE="segPymeEmpresarial"    # ProductCode of the Product2 bundle "Plan Empresarial"

echo ">> Target org: ${TARGET_ORG}"
echo ">> Bundle code: ${BUNDLE_CODE}"

# -----------------------------------------------------------------------------
# Utilities
# -----------------------------------------------------------------------------

# Runs a SOQL query and returns the first value of the first column (or empty).
soql_first() {
  local query="$1"
  SF_DISABLE_LOG_FILE=true sf data query \
    --query "${query}" \
    --target-org "${TARGET_ORG}" \
    --json 2>/dev/null \
    | /usr/bin/python3 -c "
import json, sys
data = json.load(sys.stdin)
records = data.get('result', {}).get('records', [])
if not records:
    print('')
    sys.exit(0)
row = records[0]
# grab the first non-attributes column
for k, v in row.items():
    if k == 'attributes':
        continue
    print(v if v is not None else '')
    sys.exit(0)
print('')
"
}

# Escapes single quotes for SOQL.
soql_esc() {
  printf '%s' "$1" | sed "s/'/\\\\'/g"
}

# Generic INSERT or UPDATE by (SObject, unique-field, unique-value, KV pairs).
# Usage: upsert_by SObject UniqueField UniqueValue "Field1=Value1" "Field2=Value2" ...
upsert_by() {
  local sobject="$1"; shift
  local ukey="$1"; shift
  local uval="$1"; shift

  local existing_id
  existing_id=$(soql_first "SELECT Id FROM ${sobject} WHERE ${ukey}='$(soql_esc "${uval}")' LIMIT 1")

  # Build the -v args
  local -a flags=()
  local pair
  for pair in "$@"; do
    flags+=(-v "${pair}")
  done

  if [[ -n "${existing_id}" ]]; then
    echo "   -> UPDATE ${sobject} ${ukey}='${uval}' (Id=${existing_id})"
    SF_DISABLE_LOG_FILE=true sf data update record \
      --sobject "${sobject}" \
      --record-id "${existing_id}" \
      "${flags[@]}" \
      --target-org "${TARGET_ORG}" >/dev/null
    printf '%s' "${existing_id}"
  else
    echo "   -> INSERT ${sobject} ${ukey}='${uval}'"
    local json
    json=$(SF_DISABLE_LOG_FILE=true sf data create record \
      --sobject "${sobject}" \
      -v "${ukey}=$(printf '%s' "${uval}")" \
      "${flags[@]}" \
      --target-org "${TARGET_ORG}" \
      --json)
    printf '%s' "${json}" | /usr/bin/python3 -c "
import json, sys
d = json.load(sys.stdin)
print(d.get('result', {}).get('id', ''))
"
  fi
}

# -----------------------------------------------------------------------------
# 0) Locate the "Plan Empresarial" Product2 bundle
# -----------------------------------------------------------------------------
echo ""
echo ">> [0/4] Locating Product2 bundle (Code='${BUNDLE_CODE}')..."
BUNDLE_ID=$(soql_first "SELECT Id FROM Product2 WHERE ProductCode='${BUNDLE_CODE}' LIMIT 1")

if [[ -z "${BUNDLE_ID}" ]]; then
  echo "ERROR: no Product2 found with ProductCode='${BUNDLE_CODE}'."
  echo "       Run the script that creates the Plan Empresarial bundle first."
  exit 1
fi
echo "   Bundle Product2 Id = ${BUNDLE_ID}"

# -----------------------------------------------------------------------------
# 1) Create the 6 InsuranceClause records (3 Clause + 3 Exclusion)
# -----------------------------------------------------------------------------
echo ""
echo ">> [1/4] Creating InsuranceClause (6 records)..."

EFFECTIVE_DATE="2026-01-01"
EXPIRATION_DATE="2030-12-31"

# ---- 1.1 Cláusula General de Buena Fe -------------------------------------
CLAUSE_1_NAME="Cláusula General de Buena Fe"
CLAUSE_1_CODE="buenaFe"
CLAUSE_1_TEXT="El Tomador y el Asegurado declaran que toda la información suministrada a Seguros ALFA al momento de la contratación, así como durante la vigencia del contrato, es veraz, completa y no reticente. La reticencia o inexactitud en dicha información faculta a la Compañía para declarar la nulidad relativa del contrato, conforme a los artículos 1058 y siguientes del Código de Comercio de Colombia."

echo " * ${CLAUSE_1_NAME}"
CLAUSE_1_ID=$(upsert_by "InsuranceClause" "Code" "${CLAUSE_1_CODE}" \
  "Name=${CLAUSE_1_NAME}" \
  "ApiName=Clausula_Buena_Fe" \
  "Type=Clause" \
  "CreationMethod=AutoAdded" \
  "ContentText=${CLAUSE_1_TEXT}" \
  "EffectiveDate=${EFFECTIVE_DATE}" \
  "ExpirationDate=${EXPIRATION_DATE}")

# ---- 1.2 Exclusión de Actos Dolosos ---------------------------------------
CLAUSE_2_NAME="Exclusión de Actos Dolosos"
CLAUSE_2_CODE="actosDolosos"
CLAUSE_2_TEXT="Quedan excluidos de la cobertura de esta póliza los siniestros originados de manera directa o indirecta en actos dolosos, culpa grave o mala fe imputables al Tomador, al Asegurado, al Beneficiario o a las personas por quienes éstos deban responder civilmente, de conformidad con lo dispuesto en el artículo 1055 del Código de Comercio."

echo " * ${CLAUSE_2_NAME}"
CLAUSE_2_ID=$(upsert_by "InsuranceClause" "Code" "${CLAUSE_2_CODE}" \
  "Name=${CLAUSE_2_NAME}" \
  "ApiName=Exclusion_Actos_Dolosos" \
  "Type=Exclusion" \
  "CreationMethod=AutoAdded" \
  "ContentText=${CLAUSE_2_TEXT}" \
  "EffectiveDate=${EFFECTIVE_DATE}" \
  "ExpirationDate=${EXPIRATION_DATE}")

# ---- 1.3 Exclusión Guerra y Terrorismo ------------------------------------
CLAUSE_3_NAME="Exclusión Guerra y Terrorismo"
CLAUSE_3_CODE="guerraTerrorismo"
CLAUSE_3_TEXT="La presente póliza no ampara pérdidas, daños o responsabilidades derivadas de guerra declarada o no, invasión, actos de enemigos extranjeros, hostilidades u operaciones bélicas, guerra civil, insurrección, rebelión, revolución, poder militar usurpado, ley marcial, actos de terrorismo, sabotaje, motín, huelga, conmoción civil o cualquier acto de personas que actúen por motivos políticos, religiosos o ideológicos."

echo " * ${CLAUSE_3_NAME}"
CLAUSE_3_ID=$(upsert_by "InsuranceClause" "Code" "${CLAUSE_3_CODE}" \
  "Name=${CLAUSE_3_NAME}" \
  "ApiName=Exclusion_Guerra_Terror" \
  "Type=Exclusion" \
  "CreationMethod=AutoAdded" \
  "ContentText=${CLAUSE_3_TEXT}" \
  "EffectiveDate=${EFFECTIVE_DATE}" \
  "ExpirationDate=${EXPIRATION_DATE}")

# ---- 1.4 Cláusula de Coaseguro (Manual, with token) -----------------------
CLAUSE_4_NAME="Cláusula de Coaseguro"
CLAUSE_4_CODE="coaseguro"
CLAUSE_4_TEXT="El Asegurado participará en cada siniestro amparado con un coaseguro obligatorio del {{porcentajeCoaseguro}}% del valor de la pérdida indemnizable, una vez aplicado el deducible correspondiente. Este porcentaje será retenido por Seguros ALFA al momento de liquidar la indemnización y no podrá ser objeto de subrogación contra terceros."

echo " * ${CLAUSE_4_NAME}"
CLAUSE_4_ID=$(upsert_by "InsuranceClause" "Code" "${CLAUSE_4_CODE}" \
  "Name=${CLAUSE_4_NAME}" \
  "ApiName=Clausula_Coaseguro" \
  "Type=Clause" \
  "CreationMethod=Manual" \
  "ContentText=${CLAUSE_4_TEXT}" \
  "EffectiveDate=${EFFECTIVE_DATE}" \
  "ExpirationDate=${EXPIRATION_DATE}")

# ---- 1.5 Exclusión Actividades Extremas (AutoAdded, with token) -----------
CLAUSE_5_NAME="Exclusión Actividades Extremas"
CLAUSE_5_CODE="actividadesExt"
CLAUSE_5_TEXT="Se excluyen expresamente de esta cobertura los siniestros ocurridos durante la práctica de actividades de alto riesgo, incluyendo pero no limitado a: paracaidismo, buceo profundo, alpinismo, motociclismo deportivo, automovilismo de competencia y cualquier actividad realizada bajo la influencia de {{sustanciasProhibidas}}. Se entiende por tales todas aquellas sustancias que alteren el estado de conciencia o la capacidad de reacción del Asegurado."

echo " * ${CLAUSE_5_NAME}"
CLAUSE_5_ID=$(upsert_by "InsuranceClause" "Code" "${CLAUSE_5_CODE}" \
  "Name=${CLAUSE_5_NAME}" \
  "ApiName=Exclusion_Actividades_Ext" \
  "Type=Exclusion" \
  "CreationMethod=AutoAdded" \
  "ContentText=${CLAUSE_5_TEXT}" \
  "EffectiveDate=${EFFECTIVE_DATE}" \
  "ExpirationDate=${EXPIRATION_DATE}")

# ---- 1.6 Cláusula de Deducible Mínimo (AutoAdded, with token) -------------
CLAUSE_6_NAME="Cláusula de Deducible Mínimo"
CLAUSE_6_CODE="deducibleMinPyme"
CLAUSE_6_TEXT="En cada siniestro amparado por esta póliza, el Asegurado asumirá por su cuenta un deducible mínimo equivalente a {{deducibleMinimo}} pesos colombianos (COP), el cual será descontado del valor de la indemnización antes de la aplicación de cualquier otro coaseguro o participación. En ningún caso Seguros ALFA responderá por pérdidas inferiores a este monto."

echo " * ${CLAUSE_6_NAME}"
CLAUSE_6_ID=$(upsert_by "InsuranceClause" "Code" "${CLAUSE_6_CODE}" \
  "Name=${CLAUSE_6_NAME}" \
  "ApiName=Clausula_Deducible_Minimo" \
  "Type=Clause" \
  "CreationMethod=AutoAdded" \
  "ContentText=${CLAUSE_6_TEXT}" \
  "EffectiveDate=${EFFECTIVE_DATE}" \
  "ExpirationDate=${EXPIRATION_DATE}")

echo ""
echo "   InsuranceClause created/updated:"
echo "     1) buenaFe             = ${CLAUSE_1_ID}"
echo "     2) actosDolosos        = ${CLAUSE_2_ID}"
echo "     3) guerraTerrorismo    = ${CLAUSE_3_ID}"
echo "     4) coaseguro           = ${CLAUSE_4_ID}"
echo "     5) actividadesExt      = ${CLAUSE_5_ID}"
echo "     6) deducibleMinPyme    = ${CLAUSE_6_ID}"

# -----------------------------------------------------------------------------
# 2) InsuranceProductClause (Product2 <-> InsuranceClause junctions)
# -----------------------------------------------------------------------------
echo ""
echo ">> [2/4] Creating InsuranceProductClause (6 junctions to the bundle)..."

# Helper to upsert a junction (one row per (RootProductId, InsuranceClauseId)).
upsert_product_clause() {
  local clause_id="$1"
  local clause_code="$2"

  local existing_id
  existing_id=$(soql_first "SELECT Id FROM InsuranceProductClause WHERE RootProductId='${BUNDLE_ID}' AND InsuranceClauseId='${clause_id}' LIMIT 1")

  if [[ -n "${existing_id}" ]]; then
    echo "   -> UPDATE InsuranceProductClause (clause=${clause_code}, Id=${existing_id})"
    SF_DISABLE_LOG_FILE=true sf data update record \
      --sobject "InsuranceProductClause" \
      --record-id "${existing_id}" \
      -v "ProductPath=${BUNDLE_ID}" \
      -v "RootProductId=${BUNDLE_ID}" \
      -v "InsuranceClauseId=${clause_id}" \
      --target-org "${TARGET_ORG}" >/dev/null
    printf '%s' "${existing_id}"
  else
    echo "   -> INSERT InsuranceProductClause (clause=${clause_code})"
    local json
    json=$(SF_DISABLE_LOG_FILE=true sf data create record \
      --sobject "InsuranceProductClause" \
      -v "ProductPath=${BUNDLE_ID}" \
      -v "RootProductId=${BUNDLE_ID}" \
      -v "InsuranceClauseId=${clause_id}" \
      --target-org "${TARGET_ORG}" \
      --json)
    printf '%s' "${json}" | /usr/bin/python3 -c "
import json, sys
d = json.load(sys.stdin)
print(d.get('result', {}).get('id', ''))
"
  fi
}

IPC_1_ID=$(upsert_product_clause "${CLAUSE_1_ID}" "buenaFe")
IPC_2_ID=$(upsert_product_clause "${CLAUSE_2_ID}" "actosDolosos")
IPC_3_ID=$(upsert_product_clause "${CLAUSE_3_ID}" "guerraTerrorismo")
IPC_4_ID=$(upsert_product_clause "${CLAUSE_4_ID}" "coaseguro")
IPC_5_ID=$(upsert_product_clause "${CLAUSE_5_ID}" "actividadesExt")
IPC_6_ID=$(upsert_product_clause "${CLAUSE_6_ID}" "deducibleMinPyme")

echo ""
echo "   InsuranceProductClause created/updated:"
echo "     1) buenaFe             -> ${IPC_1_ID}"
echo "     2) actosDolosos        -> ${IPC_2_ID}"
echo "     3) guerraTerrorismo    -> ${IPC_3_ID}"
echo "     4) coaseguro           -> ${IPC_4_ID}"
echo "     5) actividadesExt      -> ${IPC_5_ID}"
echo "     6) deducibleMinPyme    -> ${IPC_6_ID}"

# -----------------------------------------------------------------------------
# 3) InsProductClauseVariableMap (dynamic tokens)
# -----------------------------------------------------------------------------
echo ""
echo ">> [3/4] Creating InsProductClauseVariableMap (3 tokens)..."

# The Attribute field points to a product attribute using the convention:
#   <PortfolioCode>.Attribute.<Attribute_DeveloperName>
# For this bundle the portfolio is segPymeEmpresarial.

# Helper to upsert a variable-map. The logical key is
# (InsuranceProductClauseId, Token).
upsert_variable_map() {
  local ipc_id="$1"
  local token="$2"
  local attribute_path="$3"
  local data_type="$4"

  local existing_id
  existing_id=$(soql_first "SELECT Id FROM InsProductClauseVariableMap WHERE InsuranceProductClauseId='${ipc_id}' AND Token='$(soql_esc "${token}")' LIMIT 1")

  if [[ -n "${existing_id}" ]]; then
    echo "   -> UPDATE InsProductClauseVariableMap (token=${token}, Id=${existing_id})"
    SF_DISABLE_LOG_FILE=true sf data update record \
      --sobject "InsProductClauseVariableMap" \
      --record-id "${existing_id}" \
      -v "Token=${token}" \
      -v "Attribute=${attribute_path}" \
      -v "DataType=${data_type}" \
      -v "InsuranceProductClauseId=${ipc_id}" \
      --target-org "${TARGET_ORG}" >/dev/null
    printf '%s' "${existing_id}"
  else
    echo "   -> INSERT InsProductClauseVariableMap (token=${token})"
    local json
    json=$(SF_DISABLE_LOG_FILE=true sf data create record \
      --sobject "InsProductClauseVariableMap" \
      -v "Token=${token}" \
      -v "Attribute=${attribute_path}" \
      -v "DataType=${data_type}" \
      -v "InsuranceProductClauseId=${ipc_id}" \
      --target-org "${TARGET_ORG}" \
      --json)
    printf '%s' "${json}" | /usr/bin/python3 -c "
import json, sys
d = json.load(sys.stdin)
print(d.get('result', {}).get('id', ''))
"
  fi
}

# 3.1 porcentajeCoaseguro (Percent) -> Cláusula de Coaseguro
VMAP_1_ID=$(upsert_variable_map \
  "${IPC_4_ID}" \
  "porcentajeCoaseguro" \
  "segPymeEmpresarial.Attribute.Porcentaje_Coaseguro" \
  "Percent")

# 3.2 sustanciasProhibidas (Picklist) -> Exclusión Actividades Extremas
VMAP_2_ID=$(upsert_variable_map \
  "${IPC_5_ID}" \
  "sustanciasProhibidas" \
  "segPymeEmpresarial.Attribute.Sustancias_Prohibidas" \
  "Picklist")

# 3.3 deducibleMinimo (Currency) -> Cláusula de Deducible Mínimo
VMAP_3_ID=$(upsert_variable_map \
  "${IPC_6_ID}" \
  "deducibleMinimo" \
  "segPymeEmpresarial.Attribute.Deducible_Minimo_Evento" \
  "Currency")

echo ""
echo "   InsProductClauseVariableMap created/updated:"
echo "     1) porcentajeCoaseguro  -> ${VMAP_1_ID}"
echo "     2) sustanciasProhibidas -> ${VMAP_2_ID}"
echo "     3) deducibleMinimo      -> ${VMAP_3_ID}"

# -----------------------------------------------------------------------------
# 4) Final summary
# -----------------------------------------------------------------------------
echo ""
echo ">> [4/4] Block 5 (Product-level Clauses) completed successfully."
echo ""
echo "   Reminder: POLICY-LEVEL clauses (InsurancePolicyProductClause) are"
echo "   created in 03-block2-policy.sh, when policy POL-PYME-2026-0001 is"
echo "   materialized on top of this bundle."
echo ""
