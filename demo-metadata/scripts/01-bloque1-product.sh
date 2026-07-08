#!/usr/bin/env bash
# =============================================================================
# Bloque 1 - Product Catalog Management (PCM)
# Recrea toda la infraestructura PCM del RFP Seguros ALFA:
#   - 3 AttributeCategory
#   - 8 AttributePicklist + 34 AttributePicklistValue
#   - 8 AttributeDefinition
#   - 2 ProductClassification + 8 ProductClassificationAttr
#   - 6 Simple Coverages (Product2) + 48 ProductAttributeDefinition
#   - 1 Bundle Product2 "Plan Empresarial"
#   - 2 ProductComponentGroup + 7 ProductRelatedComponent
#   - 7 ProductSellingModelOption
#   - 7 PricebookEntry (precios COP)
#   - 1 ProductCategory + 1 ProductCategoryProduct
#
# Reglas:
#   - Idempotente: cada create verifica existencia previa por Name/Code
#   - Sin IDs hardcodeados: lookups dinámicos por atributo natural
#   - SF_DISABLE_LOG_FILE=true prefijado a cada llamada sf
# =============================================================================

# Prefijo obligatorio para que sf funcione en este entorno
export SF_DISABLE_LOG_FILE=true

# Contadores globales
CREATED=0
SKIPPED=0
FAILED=0

# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------

# Ejecuta un SOQL y devuelve el primer Id (o vacío si no hay match)
soql_first_id() {
  local query="$1"
  sf data query --query "$query" --json 2>/dev/null \
    | /usr/bin/python3 -c "import json,sys;d=json.load(sys.stdin);r=d.get('result',{}).get('records',[]);print(r[0]['Id'] if r else '')" 2>/dev/null
}

# Crea un record via sf data create record; si ya existe (id no vacío), skip.
# Args: sobject, existing_id, key_field=value_field pairs...
# Uso: create_if_missing "AttributeCategory" "$id" "Name=Términos Pyme" "Code=terminosPyme" "Status=Active"
create_if_missing() {
  local sobject="$1"
  local existing_id="$2"
  shift 2
  if [[ -n "$existing_id" ]]; then
    echo "  [skip] $sobject ya existe (Id=$existing_id)"
    SKIPPED=$((SKIPPED + 1))
    echo "$existing_id"
    return 0
  fi
  # Construir --values string
  local values=""
  for kv in "$@"; do
    values+=" $kv"
  done
  local out
  out=$(sf data create record --sobject "$sobject" --values "$values" --json 2>&1)
  local rc=$?
  if [[ $rc -ne 0 ]]; then
    echo "  [FAIL] No se pudo crear $sobject con valores:$values" >&2
    echo "$out" >&2
    FAILED=$((FAILED + 1))
    return 1
  fi
  local new_id
  new_id=$(echo "$out" | /usr/bin/python3 -c "import json,sys;d=json.load(sys.stdin);print(d.get('result',{}).get('id',''))" 2>/dev/null)
  if [[ -z "$new_id" ]]; then
    echo "  [FAIL] Create $sobject devolvió sin Id" >&2
    echo "$out" >&2
    FAILED=$((FAILED + 1))
    return 1
  fi
  echo "  [ok]  $sobject creado (Id=$new_id)"
  CREATED=$((CREATED + 1))
  echo "$new_id"
}

# Aborta si el último create crítico falló
must_have() {
  local id="$1"
  local desc="$2"
  if [[ -z "$id" ]]; then
    echo "ERROR CRÍTICO: falta $desc — abortando" >&2
    exit 1
  fi
}

# =============================================================================
# 1) AttributeCategory (3)
# =============================================================================
echo ""
echo "=== 1) AttributeCategory ==="

# 1.1 Términos Pyme
id=$(soql_first_id "SELECT Id FROM AttributeCategory WHERE Code='terminosPyme' LIMIT 1")
CAT_TERMINOS=$(create_if_missing "AttributeCategory" "$id" \
  "Name='Términos Pyme'" "Code=terminosPyme" "Status=Active")
must_have "$CAT_TERMINOS" "AttributeCategory Términos Pyme"

# 1.2 Cobertura Base
id=$(soql_first_id "SELECT Id FROM AttributeCategory WHERE Code='coberturaBase' LIMIT 1")
CAT_BASE=$(create_if_missing "AttributeCategory" "$id" \
  "Name='Cobertura Base'" "Code=coberturaBase" "Status=Active")
must_have "$CAT_BASE" "AttributeCategory Cobertura Base"

# 1.3 Cobertura Adicional
id=$(soql_first_id "SELECT Id FROM AttributeCategory WHERE Code='coberturaAdicional' LIMIT 1")
CAT_ADIC=$(create_if_missing "AttributeCategory" "$id" \
  "Name='Cobertura Adicional'" "Code=coberturaAdicional" "Status=Active")
must_have "$CAT_ADIC" "AttributeCategory Cobertura Adicional"

# =============================================================================
# 2) AttributePicklist (8) + AttributePicklistValue (34)
# =============================================================================
# NOTA: AttributePicklistValue.Code es unique global — donde el mismo valor se
# reutiliza en otra picklist (p.ej. "Deducible Minimo Evento"), usamos sufijo
# _DME para evitar colisiones.
echo ""
echo "=== 2) AttributePicklist + AttributePicklistValue ==="

# Helper para crear una picklist y sus valores
# Args: pl_name pl_code datatype status value1|code1 value2|code2 ...
create_picklist_with_values() {
  local pl_name="$1"
  local pl_code="$2"
  local pl_dt="$3"
  shift 3
  local existing
  existing=$(soql_first_id "SELECT Id FROM AttributePicklist WHERE Name='$pl_name' LIMIT 1")
  local pl_id
  pl_id=$(create_if_missing "AttributePicklist" "$existing" \
    "Name='$pl_name'" "DataType=$pl_dt" "Status=Active")
  must_have "$pl_id" "AttributePicklist $pl_name"
  # Crear valores
  for entry in "$@"; do
    local value="${entry%%|*}"
    local code="${entry##*|}"
    local vid
    vid=$(soql_first_id "SELECT Id FROM AttributePicklistValue WHERE Code='$code' LIMIT 1")
    create_if_missing "AttributePicklistValue" "$vid" \
      "Name='$value'" "Value='$value'" "Code=$code" \
      "PicklistId=$pl_id" "Status=Active" > /dev/null
  done
  echo "$pl_id"
}

# 2.1 Suma Asegurada Pyme (Text) — 4 valores
PL_SUMA=$(create_picklist_with_values "Suma Asegurada Pyme" "sumaAseguradaPyme" "Text" \
  "50000000|SA_50M" "100000000|SA_100M" "200000000|SA_200M" "500000000|SA_500M")

# 2.2 Deducible Pyme (Text) — 4 valores
PL_DED=$(create_picklist_with_values "Deducible Pyme" "deduciblePyme" "Text" \
  "1%|DED_1" "3%|DED_3" "5%|DED_5" "10%|DED_10")

# 2.3 Actividad Económica (Text) — 6 valores
PL_ACT=$(create_picklist_with_values "Actividad Economica" "actividadEconomica" "Text" \
  "Comercio al por menor|ACT_COMERCIO" \
  "Servicios profesionales|ACT_SERVICIOS" \
  "Manufactura ligera|ACT_MANUFACTURA" \
  "Restaurantes y alimentos|ACT_RESTAURANTES" \
  "Tecnología|ACT_TECNOLOGIA" \
  "Salud y estética|ACT_SALUD")

# 2.4 Rango de Empleados (Text) — 4 valores
PL_EMP=$(create_picklist_with_values "Rango de Empleados" "rangoEmpleados" "Text" \
  "1-10|EMP_1_10" "11-25|EMP_11_25" "26-50|EMP_26_50" "51-100|EMP_51_100")

# 2.5 Metros Cuadrados Local (Text) — 4 valores
PL_M2=$(create_picklist_with_values "Metros Cuadrados Local" "metrosCuadradosLocal" "Text" \
  "Hasta 50 m²|M2_50" "51-150 m²|M2_150" "151-300 m²|M2_300" "Más de 300 m²|M2_300P")

# 2.6 Porcentaje Coaseguro (Text) — 4 valores
PL_COA=$(create_picklist_with_values "Porcentaje Coaseguro" "porcentajeCoaseguro" "Text" \
  "0%|COA_0" "10%|COA_10" "20%|COA_20" "30%|COA_30")

# 2.7 Deducible Minimo Evento (Text) — 4 valores — SUFIJO _DME por colisión global
PL_DME=$(create_picklist_with_values "Deducible Minimo Evento" "deducibleMinimoEvento" "Text" \
  "1%|DED_1_DME" "3%|DED_3_DME" "5%|DED_5_DME" "10%|DED_10_DME")

# 2.8 Sustancias Prohibidas (Text) — 4 valores
PL_SUS=$(create_picklist_with_values "Sustancias Prohibidas" "sustanciasProhibidas" "Text" \
  "Ninguna|SUS_NINGUNA" \
  "Solventes menores|SUS_SOLVENTES" \
  "Materiales inflamables|SUS_INFLAMABLES" \
  "Químicos industriales|SUS_QUIMICOS")

# =============================================================================
# 3) AttributeDefinition (8) — todas Picklist con DeveloperName snake_case
# =============================================================================
echo ""
echo "=== 3) AttributeDefinition ==="

# Helper: crea AttributeDefinition Picklist si no existe
# Args: label developer_name categoryId picklistId
create_attr_def() {
  local label="$1"
  local devname="$2"
  local cat_id="$3"
  local pl_id="$4"
  local existing
  existing=$(soql_first_id "SELECT Id FROM AttributeDefinition WHERE DeveloperName='$devname' LIMIT 1")
  create_if_missing "AttributeDefinition" "$existing" \
    "Label='$label'" "Name='$label'" "DeveloperName=$devname" \
    "DataType=Picklist" "PicklistId=$pl_id" \
    "AttributeCategoryId=$cat_id" "Status=Active"
}

AD_SUMA=$(create_attr_def       "Suma Asegurada"          "Suma_Asegurada"           "$CAT_TERMINOS" "$PL_SUMA")
AD_DED=$(create_attr_def        "Deducible"               "Deducible"                "$CAT_TERMINOS" "$PL_DED")
AD_ACT=$(create_attr_def        "Actividad Economica"     "Actividad_Economica"      "$CAT_TERMINOS" "$PL_ACT")
AD_EMP=$(create_attr_def        "Rango Empleados"         "Rango_Empleados"          "$CAT_TERMINOS" "$PL_EMP")
AD_M2=$(create_attr_def         "Metros Cuadrados Local"  "Metros_Cuadrados_Local"   "$CAT_TERMINOS" "$PL_M2")
AD_COA=$(create_attr_def        "Porcentaje Coaseguro"    "Porcentaje_Coaseguro"     "$CAT_BASE"     "$PL_COA")
AD_DME=$(create_attr_def        "Deducible Minimo Evento" "Deducible_Minimo_Evento"  "$CAT_BASE"     "$PL_DME")
AD_SUS=$(create_attr_def        "Sustancias Prohibidas"   "Sustancias_Prohibidas"    "$CAT_ADIC"    "$PL_SUS")

for id in "$AD_SUMA" "$AD_DED" "$AD_ACT" "$AD_EMP" "$AD_M2" "$AD_COA" "$AD_DME" "$AD_SUS"; do
  must_have "$id" "AttributeDefinition"
done

# =============================================================================
# 4) ProductClassification (2)
# =============================================================================
echo ""
echo "=== 4) ProductClassification ==="

id=$(soql_first_id "SELECT Id FROM ProductClassification WHERE Code='coberturaPyme' LIMIT 1")
PC_COB=$(create_if_missing "ProductClassification" "$id" \
  "Name='Cobertura Pyme'" "Code=coberturaPyme" "Status=Active")
must_have "$PC_COB" "ProductClassification Cobertura Pyme"

id=$(soql_first_id "SELECT Id FROM ProductClassification WHERE Code='establecimientoComercial' LIMIT 1")
PC_EST=$(create_if_missing "ProductClassification" "$id" \
  "Name='Establecimiento Comercial'" "Code=establecimientoComercial" "Status=Active")
must_have "$PC_EST" "ProductClassification Establecimiento Comercial"

# =============================================================================
# 5) ProductClassificationAttr (8) — DefaultValue = Picklist Value (no Code)
# =============================================================================
echo ""
echo "=== 5) ProductClassificationAttr ==="

# Helper: crea PCA con DefaultValue = value string
# Args: attribute_def_id classification_id default_value seq
create_pca() {
  local ad_id="$1"
  local pc_id="$2"
  local default="$3"
  local seq="$4"
  # Buscar existencia por combinación (AttributeDefinition + Classification)
  local existing
  existing=$(soql_first_id "SELECT Id FROM ProductClassificationAttr WHERE AttributeDefinitionId='$ad_id' AND ProductClassificationId='$pc_id' LIMIT 1")
  create_if_missing "ProductClassificationAttr" "$existing" \
    "AttributeDefinitionId=$ad_id" \
    "ProductClassificationId=$pc_id" \
    "DefaultValue='$default'" \
    "Sequence=$seq" \
    "Status=Active" > /dev/null
}

# Sobre Cobertura Pyme: 6 attrs (Suma, Deducible, Coaseguro, DME, Sustancias, Actividad)
create_pca "$AD_SUMA"  "$PC_COB" "100000000"                  1
create_pca "$AD_DED"   "$PC_COB" "3%"                         2
create_pca "$AD_COA"   "$PC_COB" "10%"                        3
create_pca "$AD_DME"   "$PC_COB" "3%"                         4
create_pca "$AD_SUS"   "$PC_COB" "Ninguna"                    5
create_pca "$AD_ACT"   "$PC_COB" "Servicios profesionales"    6

# Sobre Establecimiento Comercial: 2 attrs (Empleados, M2)
create_pca "$AD_EMP"   "$PC_EST" "11-25"                      1
create_pca "$AD_M2"    "$PC_EST" "51-150 m²"                  2

# =============================================================================
# 6) Product2 Simple Coverages (6) — con BasedOnId=Cobertura Pyme
# =============================================================================
# IMPORTANTE: NO setear ProductClass ni Type — se auto-derivan del
# ProductClassification enlazado por BasedOnId. Igual con RecordType Coverage.
echo ""
echo "=== 6) Product2 Simple Coverages ==="

# RecordType Coverage
RT_COVERAGE=$(soql_first_id "SELECT Id FROM RecordType WHERE SobjectType='Product2' AND DeveloperName='Coverage' LIMIT 1")
must_have "$RT_COVERAGE" "RecordType Coverage en Product2"

# Helper para Simple Coverage
create_coverage() {
  local name="$1"
  local code="$2"
  local existing
  existing=$(soql_first_id "SELECT Id FROM Product2 WHERE ProductCode='$code' LIMIT 1")
  create_if_missing "Product2" "$existing" \
    "Name='$name'" "ProductCode=$code" \
    "IsActive=true" \
    "BasedOnId=$PC_COB" \
    "RecordTypeId=$RT_COVERAGE"
}

PROD_RC=$(create_coverage       "RC Extracontractual"         "rcExtracontractual")
PROD_INC=$(create_coverage      "Incendio y Aliados"          "incendioAliados")
PROD_EQ=$(create_coverage       "Equipo Electronico"          "equipoElectronico")
PROD_ROBO=$(create_coverage     "Robo y Asalto"               "roboAsalto")
PROD_ROT=$(create_coverage      "Rotura de Maquinaria"        "roturaMaquinaria")
PROD_SUST=$(create_coverage     "Sustraccion de Dinero"       "sustraccionDinero")

for id in "$PROD_RC" "$PROD_INC" "$PROD_EQ" "$PROD_ROBO" "$PROD_ROT" "$PROD_SUST"; do
  must_have "$id" "Product2 Simple Coverage"
done

# =============================================================================
# 7) ProductAttributeDefinition (48) — 6 coverages x 8 attrs
# =============================================================================
# NOTA: aunque la spec dice que se auto-generan a partir del ProductClassificationAttr,
# en la práctica NO ocurre. Se crean manualmente.
echo ""
echo "=== 7) ProductAttributeDefinition (manual, 48 registros) ==="

# Helper: crea PAD si no existe (Product2 + AttributeDefinition único)
create_pad() {
  local product_id="$1"
  local ad_id="$2"
  local seq="$3"
  local existing
  existing=$(soql_first_id "SELECT Id FROM ProductAttributeDefinition WHERE Product2Id='$product_id' AND AttributeDefinitionId='$ad_id' LIMIT 1")
  create_if_missing "ProductAttributeDefinition" "$existing" \
    "Product2Id=$product_id" \
    "AttributeDefinitionId=$ad_id" \
    "Sequence=$seq" \
    "Status=Active" > /dev/null
}

# Los 8 attrs por cada uno de los 6 coverages
ATTRS=("$AD_SUMA" "$AD_DED" "$AD_ACT" "$AD_EMP" "$AD_M2" "$AD_COA" "$AD_DME" "$AD_SUS")
COVERAGES=("$PROD_RC" "$PROD_INC" "$PROD_EQ" "$PROD_ROBO" "$PROD_ROT" "$PROD_SUST")

for cov in "${COVERAGES[@]}"; do
  seq=1
  for ad in "${ATTRS[@]}"; do
    create_pad "$cov" "$ad" "$seq"
    seq=$((seq + 1))
  done
done

# =============================================================================
# 8) Product2 Bundle "Plan Empresarial"
# =============================================================================
echo ""
echo "=== 8) Product2 Bundle (Plan Empresarial) ==="

# RecordType Commercial en Product2
RT_COMMERCIAL=$(soql_first_id "SELECT Id FROM RecordType WHERE SobjectType='Product2' AND DeveloperName='Commercial' LIMIT 1")
must_have "$RT_COMMERCIAL" "RecordType Commercial en Product2"

id=$(soql_first_id "SELECT Id FROM Product2 WHERE ProductCode='segPymeEmpresarial' LIMIT 1")
PROD_BUNDLE=$(create_if_missing "Product2" "$id" \
  "Name='Plan Empresarial'" "ProductCode=segPymeEmpresarial" \
  "IsActive=true" \
  "Type=Bundle" \
  "Family=Miscellaneous" \
  "ConfigureDuringSale=Allowed" \
  "RecordTypeId=$RT_COMMERCIAL")
must_have "$PROD_BUNDLE" "Product2 Bundle Plan Empresarial"

# =============================================================================
# 9) ProductComponentGroup (2) — Code unique global -> sufijo con plan
# =============================================================================
echo ""
echo "=== 9) ProductComponentGroup ==="

id=$(soql_first_id "SELECT Id FROM ProductComponentGroup WHERE Code='coberturas_segPymeEmpresarial' LIMIT 1")
PCG_COB=$(create_if_missing "ProductComponentGroup" "$id" \
  "Name='Coberturas'" "Code=coberturas_segPymeEmpresarial" \
  "ParentProductId=$PROD_BUNDLE" \
  "Sequence=1")
must_have "$PCG_COB" "ProductComponentGroup Coberturas"

id=$(soql_first_id "SELECT Id FROM ProductComponentGroup WHERE Code='establecimiento_segPymeEmpresarial' LIMIT 1")
PCG_EST=$(create_if_missing "ProductComponentGroup" "$id" \
  "Name='Establecimiento'" "Code=establecimiento_segPymeEmpresarial" \
  "ParentProductId=$PROD_BUNDLE" \
  "Sequence=2")
must_have "$PCG_EST" "ProductComponentGroup Establecimiento"

# =============================================================================
# 10) ProductRelatedComponent (7): 6 BundleComponent + 1 ClassificationComponent
# =============================================================================
# NOTA: NO setear ParentProductRole ni ChildProductRole — se auto-derivan a
# partir del RelationshipType.
echo ""
echo "=== 10) ProductRelatedComponent ==="

# ProductRelationshipType lookups
PRT_BUNDLE=$(soql_first_id "SELECT Id FROM ProductRelationshipType WHERE RelationshipType='Bundle to Bundle Component' LIMIT 1")
PRT_CLASS=$(soql_first_id "SELECT Id FROM ProductRelationshipType WHERE RelationshipType='Bundle to Classification Component' LIMIT 1")
must_have "$PRT_BUNDLE" "ProductRelationshipType Bundle-Component"
must_have "$PRT_CLASS"  "ProductRelationshipType Bundle-Classification"

# Helper para PRC hacia otro Product (BundleComponent)
create_prc_bundle() {
  local child_id="$1"
  local group_id="$2"
  local seq="$3"
  local min="$4"
  local max="$5"
  local qty="$6"
  local existing
  existing=$(soql_first_id "SELECT Id FROM ProductRelatedComponent WHERE ParentProductId='$PROD_BUNDLE' AND ChildProductId='$child_id' LIMIT 1")
  create_if_missing "ProductRelatedComponent" "$existing" \
    "ParentProductId=$PROD_BUNDLE" \
    "ChildProductId=$child_id" \
    "ProductComponentGroupId=$group_id" \
    "ProductRelationshipTypeId=$PRT_BUNDLE" \
    "Sequence=$seq" \
    "MinQuantity=$min" "MaxQuantity=$max" "Quantity=$qty" \
    "DoesBundlePriceIncludeChild=false" > /dev/null
}

# 6 coverages en grupo Coberturas
create_prc_bundle "$PROD_RC"   "$PCG_COB" 1 1 1 1
create_prc_bundle "$PROD_INC"  "$PCG_COB" 2 1 1 1
create_prc_bundle "$PROD_EQ"   "$PCG_COB" 3 0 1 1
create_prc_bundle "$PROD_ROBO" "$PCG_COB" 4 0 1 1
create_prc_bundle "$PROD_ROT"  "$PCG_COB" 5 0 1 1
create_prc_bundle "$PROD_SUST" "$PCG_COB" 6 0 1 1

# 1 ClassificationComponent hacia Establecimiento Comercial en grupo Establecimiento
existing=$(soql_first_id "SELECT Id FROM ProductRelatedComponent WHERE ParentProductId='$PROD_BUNDLE' AND ChildProductClassificationId='$PC_EST' LIMIT 1")
create_if_missing "ProductRelatedComponent" "$existing" \
  "ParentProductId=$PROD_BUNDLE" \
  "ChildProductClassificationId=$PC_EST" \
  "ProductComponentGroupId=$PCG_EST" \
  "ProductRelationshipTypeId=$PRT_CLASS" \
  "Sequence=1" \
  "MinQuantity=1" "MaxQuantity=1" "Quantity=1" > /dev/null

# =============================================================================
# 11) ProductSellingModelOption (7) — OneTime, IsDefault=true
# =============================================================================
echo ""
echo "=== 11) ProductSellingModelOption ==="

# Buscar ProductSellingModel OneTime
PSM_ONETIME=$(soql_first_id "SELECT Id FROM ProductSellingModel WHERE SellingModelType='OneTime' AND Status='Active' LIMIT 1")
must_have "$PSM_ONETIME" "ProductSellingModel OneTime"

create_psmo() {
  local product_id="$1"
  local existing
  existing=$(soql_first_id "SELECT Id FROM ProductSellingModelOption WHERE Product2Id='$product_id' AND ProductSellingModelId='$PSM_ONETIME' LIMIT 1")
  create_if_missing "ProductSellingModelOption" "$existing" \
    "Product2Id=$product_id" \
    "ProductSellingModelId=$PSM_ONETIME" \
    "IsDefault=true" > /dev/null
}

create_psmo "$PROD_BUNDLE"
create_psmo "$PROD_RC"
create_psmo "$PROD_INC"
create_psmo "$PROD_EQ"
create_psmo "$PROD_ROBO"
create_psmo "$PROD_ROT"
create_psmo "$PROD_SUST"

# =============================================================================
# 12) PricebookEntry (7) — precios COP en Standard Price Book
# =============================================================================
echo ""
echo "=== 12) PricebookEntry (precios COP) ==="

# Standard Price Book
PB_STD=$(soql_first_id "SELECT Id FROM Pricebook2 WHERE IsStandard=true LIMIT 1")
must_have "$PB_STD" "Standard Pricebook2"

create_pbe() {
  local product_id="$1"
  local unit_price="$2"
  local existing
  existing=$(soql_first_id "SELECT Id FROM PricebookEntry WHERE Pricebook2Id='$PB_STD' AND Product2Id='$product_id' LIMIT 1")
  create_if_missing "PricebookEntry" "$existing" \
    "Pricebook2Id=$PB_STD" \
    "Product2Id=$product_id" \
    "UnitPrice=$unit_price" \
    "IsActive=true" > /dev/null
}

# Precios COP del RFP
create_pbe "$PROD_BUNDLE" 2400000
create_pbe "$PROD_RC"      600000
create_pbe "$PROD_INC"     800000
create_pbe "$PROD_EQ"      300000
create_pbe "$PROD_ROBO"    400000
create_pbe "$PROD_ROT"     200000
create_pbe "$PROD_SUST"    100000

# =============================================================================
# 13) ProductCategory "Seguros Pyme" + ProductCategoryProduct link
# =============================================================================
echo ""
echo "=== 13) ProductCategory + link al bundle ==="

# Buscar ProductCatalog default (assume 1 catalog activo). Es requerido.
CATALOG_ID=$(soql_first_id "SELECT Id FROM ProductCatalog WHERE IsActive=true ORDER BY CreatedDate ASC LIMIT 1")
must_have "$CATALOG_ID" "ProductCatalog activo"

id=$(soql_first_id "SELECT Id FROM ProductCategory WHERE Code='pymeIntegral' LIMIT 1")
CATEG_PYME=$(create_if_missing "ProductCategory" "$id" \
  "Name='Seguros Pyme'" "Code=pymeIntegral" \
  "CatalogId=$CATALOG_ID")
must_have "$CATEG_PYME" "ProductCategory Seguros Pyme"

# Link Bundle -> Category
existing=$(soql_first_id "SELECT Id FROM ProductCategoryProduct WHERE ProductCategoryId='$CATEG_PYME' AND ProductId='$PROD_BUNDLE' LIMIT 1")
create_if_missing "ProductCategoryProduct" "$existing" \
  "ProductCategoryId=$CATEG_PYME" \
  "ProductId=$PROD_BUNDLE" > /dev/null

# =============================================================================
# Resumen
# =============================================================================
echo ""
echo "============================================================"
echo "  RESUMEN BLOQUE 1 - PCM"
echo "============================================================"
echo "  Records creados:       $CREATED"
echo "  Records omitidos:      $SKIPPED  (ya existían)"
echo "  Creates fallidos:      $FAILED"
echo "============================================================"

if [[ $FAILED -gt 0 ]]; then
  exit 1
fi
exit 0
