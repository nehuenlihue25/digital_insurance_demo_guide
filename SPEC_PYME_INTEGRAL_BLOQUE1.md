# Seguro Pyme Integral — Build Specification (Bloque 1, Sustentación 2026-07-09) — v2 (post-crítica)

Reference model: Auto Gold (Product2 `01tg8000003K9biAAC`) en ins-qbranch-alfa.
Time-box: revisado a **~5h** (era 4h; ver §6). Todo user-facing en español.

**Cambios v2:** describes obligatorios movidos al Paso 0; `Type` desmarcado en coverages; `BasedOnId` en hijas movido detrás de un describe explícito; `ProductClassificationAttr` como paso manual verificado, no como magia; `DefaultValue` corregido a `Value` no `Code`; `Sequence=null` en PRCs; `Rango*` picklists convertidos a Text; Sustancias Prohibidas a Multipicklist; describe de `AttributeCategory.Type` y `ProductClassification.Status` antes de crear.

---

## 1. Auto Gold teardown (reference model)

**Bundle hierarchy.** Auto Gold es un `Product2` raíz (`01tg8000003K9biAAC`) con `ProductClass=Bundle`, `Type=Bundle`, `Family=Miscellaneous`, `ProductCode=autoGold`, `BasedOnId=null`. Su estructura son 2 niveles: bajo el bundle hay 2 `ProductComponentGroup` ("Coverage" `0y7g80000008n28AAA` y "Auto" `0y7g80000008n23AAA`). El grupo Coverage contiene 3 `ProductRelatedComponent` (PRC) que apuntan a `Product2` Simple: Rental Auto Coverage (`01tg8000003K9cqAAC`), Bodily Injury & Property Damage (`01tg8000003K9crAAC`) y Medical Payments (`01tg8000003K9csAAC`), todos vía `ProductRelationshipType` "Bundle to Bundle Component Relationship" (`0yog8000000DOkTAAW`). El grupo Auto contiene 1 PRC clasificación → `ProductClassification` "Vehicle" (`11Bg800000BsmlPEAR`) vía "Bundle to Product Classification Component Relationship" (`0yog8000000DOkUAAW`). Auto Silver (`01tg8000003K9bjAAC`) es estructuralmente idéntico pero: (a) 2 coverages en vez de 3, (b) `IsDefaultComponent=true` en sus PRC, (c) grupos con `Code` poblado. Auto Silver NO está basado en Auto Gold (`BasedOnId=null`); son bundles peer.

**Field convention crítica en Product2 (validada por inspección):**
- Root bundle: `Type='Bundle'` **y** `ProductClass='Bundle'` (ambos seteados con el mismo valor).
- Coverage hijas Simple: `Type=null` (¡no `Type='Simple'`!) y solo `ProductClass='Simple'`. `Family=null`. Esto refleja lo que existe en el org — no asumir que `'Simple'` es picklist value válido en `Type`.
- Root bundle: `Family='Miscellaneous'`; hijas `Family=null`.
- `BasedOnId=null` en el root Bundle. La inspección **no confirma** que Auto Gold seteie `BasedOnId` en sus coverages hijas — el linkage classification→coverage se ve materializado vía `ProductClassificationAttr` + `ProductAttributeDefinition.ProductClassificationAttributeId`. Antes de asumir que setear `Product2.BasedOnId` genera PADs automáticamente, hay que verificar (Paso 0.b).

**PRC field conventions (validadas):** `Sequence=null` **en todos los PRCs** de Auto Gold y Silver — el orden se infiere del creation order. `MinQuantity=null`, `MaxQuantity=null`, `Quantity=1`, `IsQuantityEditable=false`, `IsComponentRequired=false`, `DoesBundlePriceIncludeChild=true`, `QuantityScaleMethod='Proportional'`. Además: `ParentProductRole='Bundle'` en todos los PRCs y `ChildProductRole` es `'BundleComponent'` (para hijas Product2) o `'ClassificationComponent'` (para el PRC classification). No está confirmado si estos dos roles auto-populan desde `ProductRelationshipTypeId` o si hay que setearlos explícitamente — describe en Paso 0.

**PCG (ProductComponentGroup):** `Sequence` es null en el grupo "Coverage" de Gold; Silver poblado. No es required.

**Attributes.** El bundle raíz tiene **cero PAD**. Los atributos viven en las 3 coverages hijas, todas asociadas a la `ProductClassification` "Coverage" (`11Bg800000BsmlTEAR`) vía `ProductClassificationAttr`. Total: 34 `ProductAttributeDefinition` (9 Rental, 13 BIPD, 12 Medical). Todos `DataType=Picklist`, agrupados en 3 `AttributeCategory`: "Auto Term", "In-Network", "Out-Network". `AttributePicklist` reutilizables: BIPDLimit, Limit, Deductible, Number Of Days, Copay, Coinsurance, Deductible Limit. Naming: `AttributeDefinition.Name` PascalCase-con-espacios ("Bodily Injury Per Accident Limit"), `Code` camelCase. **Defaults críticos:** `ProductAttributeDefinition.DefaultValue` en Auto Gold es `'1000'`, `'1500'`, `'5'` — es decir, coincide con `AttributePicklistValue.Value` **no** con `.Code`. Esto es un fix vs v1.

**Selling model & pricing.** `ProductSellingModelOption` PSMO-000000011 enlaza Auto Gold al `ProductSellingModel` "One Time" (`SellingModelType=OneTime`, `IsDefault=true` en el PSMO). Campos verificados: PSMO usa `Product2Id` (no `ProductId`) y `ProductSellingModelId`. Pricing base: 1 `PricebookEntry` en el Standard Pricebook (`UnitPrice=450`). Rating vía `ExpressionSet` "AutoGoldPricingProcedure" (`UsageType=DefaultPricing`, `InterfaceSourceType=PricingProcedure`) sobre `ExpressionSetDefinition`. **Ojo:** la version V1 de Gold está `IsActive=false`; la que corre viva es la de Silver V10. No existe `CalculationMatrix` Auto-específico — el rating consume las 10 matrices Bre estándar.

**Rules & eligibility.** Auto Gold tiene **cero** `ProductQualification`. No hay ConstraintModel/ConstraintRule en el org. Las reglas de rating viven dentro del ExpressionSet.

**Context & discovery.** 6 `ContextDefinition` compartidas a nivel org, heredadas de `__stdctx`. Auto Gold en la `ProductCategory` "Auto Insurance" del `ProductCatalog` "Insurance Catalog", enlazado vía `ProductCategoryProduct`.

**Runtime.** Auto Gold consume OmniScripts genéricos (Insurance_CreateQuoteDCT_English_2, Auto_QuoteProposal_English_3), FlexCard CompRaterResults, Flow FINS_Issue_Insurance_Policy.

**Lifecycle metadata.** `External_ID__c=product.36` (custom field), `StockKeepingUnit='Auto Gold'`, `RecordType=Commercial`, `ConfigureDuringSale=Allowed`, fechas null.

---

## 2. Seguro Pyme Integral — architectural spec

### 2.1 Root Product2

| Campo | Valor | Nota |
|---|---|---|
| `Name` | Plan Empresarial | |
| `ProductCode` | segPymeEmpresarial | camelCase |
| `Type` | Bundle | Verificado como picklist value válido en Auto Gold root |
| `ProductClass` | Bundle | |
| `Family` | Miscellaneous | |
| `IsActive` | true | |
| `ConfigureDuringSale` | Allowed | |
| `RecordType.DeveloperName` | Commercial | Verificar existe (Paso 0.c) |
| `Description` | Seguro integral para pequeñas y medianas empresas — cobertura combinada de daños materiales, responsabilidad civil y sustracción. | |
| `StockKeepingUnit` | Plan Empresarial | |
| `External_ID__c` | product.pyme.001 | Custom field — sólo si Paso 0.d confirma que existe |
| `BasedOnId` | null | Peer independiente (patrón Gold/Silver) |
| `Product_Catalog__c` | omitir | Null en Auto Gold |

### 2.2 Estrategia de planes (decisión: 3 bundles peer, patrón Gold/Silver)

**Análisis.** Auto Gold y Auto Silver son peer independientes (`BasedOnId=null` en ambos), comparten 2 coverages y cada uno redefine su PRC con `IsDefaultComponent` distinto. No hay super-bundle.

**Decisión Pyme.** 3 bundles peer (`Plan Esencial`, `Plan Empresarial`, `Plan Corporativo`), cada uno `ProductClass=Bundle`, `BasedOnId=null`, compartiendo los mismos 6 Product2 Simple. Diferencias por plan: (1) qué coverages incluye, (2) `IsDefaultComponent` en el PRC, (3) `DefaultValue` de los PAD via override en bundle context (`OverriddenProductAttributeDefinitionId` / `OverrideContextId`).

Para el time-box: construir sólo **Plan Empresarial** completo; los otros 2 se explican en la sustentación como "misma plantilla, distinta selección de PRC/defaults".

### 2.3 Coverages (6 `Product2` Simple compartidos)

Todos con `ProductClass=Simple`, `Type` **NO seteado** (siguiendo Auto Gold: coverages tienen `Type=null`), `Family` no seteado (Gold tiene `Family=null` en hijas), `IsActive=true`, `SellOnlyWithOtherProducts=true`, `RecordType=Commercial` (mismo RT que el bundle, siguiendo Auto Gold — no usar 'Coverage Spec' hasta confirmar que existe en el org).

**`BasedOnId` en coverages: DECISIÓN CONDICIONAL.** La inspección no confirma que Auto Gold setee `BasedOnId` en sus hijas — sólo confirma que las hijas están linkeadas a la classification "Coverage" vía `ProductClassificationAttr` + PADs con `ProductClassificationAttributeId` poblado. Paso 0.e ejecuta una SOQL sobre Auto Gold hijas para leer `BasedOnId`. Dos ramas:

- **Rama A (BasedOnId poblado en Gold hijas):** setear `Product2.BasedOnId = Id(ProductClassification 'Cobertura Pyme')` en las 6 coverages. Los PADs pueden o no auto-generarse — validar Paso 5.
- **Rama B (BasedOnId null en Gold hijas):** dejar `BasedOnId=null` en las 6 coverages Pyme y forzar el linkage vía `ProductClassificationAttr` + PADs manualmente. **Este es el path por defecto de la spec porque es el path que la inspección observó.**

| # | Name | ProductCode | External_ID__c |
|---|---|---|---|
| 1 | Responsabilidad Civil Extracontractual | rcExtracontractual | product.pyme.cov.01 |
| 2 | Incendio y Aliados | incendioAliados | product.pyme.cov.02 |
| 3 | Equipo Electrónico | equipoElectronico | product.pyme.cov.03 |
| 4 | Robo y Asalto Interior | roboAsalto | product.pyme.cov.04 |
| 5 | Rotura de Maquinaria | roturaMaquinaria | product.pyme.cov.05 |
| 6 | Sustracción de Dinero y Valores | sustraccionDinero | product.pyme.cov.06 |

### 2.4 ProductClassification hierarchy

| Name | Code | Uso |
|---|---|---|
| Cobertura Pyme | coberturaPyme | Padre attribute-schema de las 6 coverages |
| Establecimiento Comercial | establecimientoComercial | Classification component (equivalente a "Vehicle") |

**Nota:** Los campos exactos de `ProductClassification` (existencia de `Status`, `Code`) se verifican en Paso 0.f con describe. Si `Status` no existe, usar `IsActive` (más común en la plataforma). Si ninguno existe, omitir el flag y confiar en el default.

### 2.5 Attributes

Agrupados en 3 `AttributeCategory`. **`AttributeCategory.Type`** — la inspección no confirmó este campo; Paso 0.g valida con describe. Si el campo `Type` existe con valor `'Product Attribute'`, setearlo; si no, omitir.

**AttributePicklist (fixes vs v1):**

| Picklist Name | DataType | Valores (Code / Value / DisplayValue) | Default |
|---|---|---|---|
| SumaAseguradaPyme | Currency | Cincuenta_MM/50000000/COP 50,000,000; Cien_MM/100000000/COP 100,000,000; Doscientos_MM/200000000/COP 200,000,000; Quinientos_MM/500000000/COP 500,000,000; Mil_MM/1000000000/COP 1,000,000,000 | Cien_MM |
| DeduciblePyme | Currency | Un_MM/1000000; Dos_MM/2000000; Cinco_MM/5000000; Diez_MM/10000000 | Dos_MM |
| ActividadEconomica | Text | Comercio, Servicios, Manufactura, Tecnologia, Construccion, Alimentos (Code=Value=DisplayValue) | Comercio |
| PorcentajeCoaseguro | Percent | Diez/10; Quince/15; Veinte/20; Treinta/30 | Diez |
| **RangoEmpleados** | **Text** (era Number — fix) | Uno_Diez/"1-10 empleados"; Once_Cincuenta/"11-50 empleados"; CincuentaUno_Cien/"51-100 empleados"; Mas_Cien/"Más de 100 empleados" | Once_Cincuenta |
| **RangoMetrosCuadrados** | **Text** (era Number — fix) | Hasta_100/"Hasta 100 m²"; De_101_500/"101-500 m²"; De_501_1000/"501-1,000 m²"; Mas_1000/"Más de 1,000 m²" | De_101_500 |
| DeducibleMinimoEvento | Currency | Medio_MM/500000; Un_MM/1000000; Dos_MM/2000000 | Un_MM |
| SustanciasProhibidasPyme | Text | Ninguna, Explosivos, Inflamables_Alto_Riesgo, Sustancias_Toxicas | Ninguna |

**Fix rangos:** Rangos son semánticamente rangos, no valores puntuales. Si se enviaran como `Number=50` a rating cuando el usuario ve "11-50 empleados", el motor recibe un midpoint engañoso. `DataType=Text` con `Value=DisplayValue` es explícito y sin ambigüedad. Si más adelante rating necesita numérico, se agrega un AttributeDefinition adicional `numeroEmpleadosExacto` de tipo `Number`.

**AttributeDefinition (asignadas a "Cobertura Pyme"):**

| Name | Code | DataType | PicklistName | Category |
|---|---|---|---|---|
| Suma Asegurada | sumaAsegurada | Picklist | SumaAseguradaPyme | Términos Pyme |
| Deducible | deducible | Picklist | DeduciblePyme | Términos Pyme |
| Actividad Económica | actividadEconomica | Picklist | ActividadEconomica | Términos Pyme |
| Rango de Empleados | rangoEmpleados | Picklist | RangoEmpleados | Términos Pyme |
| Metros Cuadrados Local | metrosCuadradosLocal | Picklist | RangoMetrosCuadrados | Términos Pyme |
| Porcentaje de Coaseguro | porcentajeCoaseguro | Picklist | PorcentajeCoaseguro | Cobertura Base |
| **Sustancias Prohibidas** | **sustanciasProhibidas** | **Multipicklist** (fix) | SustanciasProhibidasPyme | Cobertura Adicional |
| Deducible Mínimo por Evento | deducibleMinimoEvento | Picklist | DeducibleMinimoEvento | Cobertura Base |

**Fix Sustancias:** una empresa puede tener múltiples sustancias prohibidas — `DataType=Multipicklist` es la representación correcta. Nota: `AttributeDefinition.DataType='Multipicklist'` es valor válido según docs; requiere `PicklistId` igual que `Picklist`.

**`DefaultValue` en PADs (fix crítico):** Auto Gold setea `DefaultValue='1000'` cuando `AttributePicklistValue.Value='1000'`. **Por tanto**, `ProductAttributeDefinition.DefaultValue` en Pyme se setea al **Value**, no al Code:

- Suma Asegurada default → `DefaultValue='100000000'` (no `'Cien_MM'`)
- Deducible default → `DefaultValue='2000000'` (no `'Dos_MM'`)
- Actividad Económica default → `DefaultValue='Comercio'` (Value=Code aquí — coincidencia OK)
- Rango de Empleados default → `DefaultValue='11-50 empleados'` (el Value, en texto)
- Porcentaje de Coaseguro → `DefaultValue='10'`
- Sustancias Prohibidas → `DefaultValue='Ninguna'` (para Multipicklist puede aceptar CSV pero Ninguna sola)

### 2.6 ProductRelatedComponent rows (para Plan Empresarial)

Convención Auto Gold (validada): `Quantity=1`, `IsQuantityEditable=false`, `IsComponentRequired=false`, `DoesBundlePriceIncludeChild=true`, `QuantityScaleMethod=Proportional`, `MinQuantity=null`, `MaxQuantity=null`, **`Sequence=null`** (fix v2 — Auto Gold tiene Sequence=null en todos sus PRCs). Diferencia clave con Gold: `IsDefaultComponent=true` (Silver-style) en las coverages core.

`ParentProductRole` y `ChildProductRole` **no se setean explícitamente** en el create; Paso 0.h describe el objeto para confirmar si auto-populan desde `ProductRelationshipTypeId`. Si son required, agregar `ParentProductRole='Bundle'` y `ChildProductRole='BundleComponent'` (o `'ClassificationComponent'`).

**Grupo 1: "Coberturas"** (`ParentProductId`=Plan Empresarial, `Code='Coberturas Pyme Empresarial'`, `Sequence=null` para consistencia con Gold — nota v2)

| ChildProduct | RelationshipType | IsDefaultComponent |
|---|---|---|
| Responsabilidad Civil Extracontractual | Bundle to Bundle Component Relationship | true |
| Incendio y Aliados | Bundle to Bundle Component Relationship | true |
| Equipo Electrónico | Bundle to Bundle Component Relationship | true |
| Robo y Asalto Interior | Bundle to Bundle Component Relationship | true |
| Rotura de Maquinaria | Bundle to Bundle Component Relationship | false (opcional) |
| Sustracción de Dinero y Valores | Bundle to Bundle Component Relationship | false (opcional) |

**Grupo 2: "Establecimiento"** (`Code='Establecimiento Pyme Empresarial'`)

| ChildClassification | RelationshipType |
|---|---|
| Establecimiento Comercial | Bundle to Product Classification Component Relationship |

### 2.7 ProductSellingModelOption

Reutilizar `ProductSellingModel` "One Time" existente. Crear:
- 1 PSMO para Plan Empresarial → OneTime, `IsDefault=true`.
- 6 PSMO (uno por coverage) → OneTime, `IsDefault=true`.

Total: 7 PSMO. Campos: `Product2Id`, `ProductSellingModelId`, `IsDefault`.

### 2.8 ProductCategory + ProductCategoryProduct

Reutilizar `ProductCatalog` "Insurance Catalog". Crear `ProductCategory` "Seguros Pyme" (`Code=pymeIntegral`, `CatalogId=<lookup>`, `ParentCategoryId=null`) + `ProductCategoryProduct` para Plan Empresarial.

### 2.9 PricebookEntry

7 rows en el Standard Pricebook, `UseStandardPrice=false`, `IsActive=true`, `UnitPrice` (COP):

| Producto | UnitPrice |
|---|---|
| Plan Empresarial | 2,400,000 |
| Responsabilidad Civil | 600,000 |
| Incendio y Aliados | 800,000 |
| Equipo Electrónico | 300,000 |
| Robo y Asalto | 400,000 |
| Rotura de Maquinaria | 200,000 |
| Sustracción de Dinero | 100,000 |

---

## 3. Ordered build script

**Cambio v2 clave:** Paso 0 ahora incluye **8 describes/queries de verificación** que resuelven las ambigüedades identificadas por la crítica antes de tocar el org.

**Convención tools:** `sf data create record` para <10 records por sObject; `sf data import tree` para picklists+valores; SOQL por Name/Code/DeveloperName (nunca Id hardcoded); prefix `SF_DISABLE_LOG_FILE=true`.

### Paso 0 — Verificación de prerequisitos (20 min — era 5)

**0.a Relationship types y bases OOTB:**
```
SF_DISABLE_LOG_FILE=true sf data query -q "SELECT Id, Name FROM ProductRelationshipType WHERE Name IN ('Bundle to Bundle Component Relationship','Bundle to Product Classification Component Relationship')"
SF_DISABLE_LOG_FILE=true sf data query -q "SELECT Id FROM ProductSellingModel WHERE SellingModelType='OneTime' AND Status='Active'"
SF_DISABLE_LOG_FILE=true sf data query -q "SELECT Id FROM Pricebook2 WHERE IsStandard=true"
SF_DISABLE_LOG_FILE=true sf data query -q "SELECT Id FROM ProductCatalog WHERE Name='Insurance Catalog'"
```

**0.b Auto Gold coverage children — leer `BasedOnId` y `Type`** (resuelve crítica CRITICAL #1 y #2):
```
SF_DISABLE_LOG_FILE=true sf data query -q "SELECT Id, Name, Type, ProductClass, Family, BasedOnId, RecordType.DeveloperName FROM Product2 WHERE Id IN ('01tg8000003K9cqAAC','01tg8000003K9crAAC','01tg8000003K9csAAC')"
```
Si `BasedOnId` es null en todas → confirmar Rama B (dejar null en Pyme coverages, forzar linkage manual). Si es poblado → Rama A.
Si `Type=null` en todas → NO setear `Type` en Pyme coverages.

**0.c RecordType Commercial:**
```
SF_DISABLE_LOG_FILE=true sf data query -q "SELECT Id, DeveloperName FROM RecordType WHERE SobjectType='Product2'"
```
Si `Commercial` no existe pero sí `Coverage Spec` u otro, ajustar spec en vivo. Si el org tiene coexistence con Insurance managed package (crítica LOW #17), aparecerán RTs duplicados con namespaces `SFA__` o similar.

**0.d Custom fields en Product2:**
```
SF_DISABLE_LOG_FILE=true sf sobject describe --sobject Product2 --json | jq '.fields[] | select(.name | test("External_ID__c|Product_Catalog__c")) | .name'
```
Si `External_ID__c` no existe → omitir del create (no es blocker).

**0.e Auto Gold PAD linkage — cómo se materializa** (resuelve CRITICAL #3):
```
SF_DISABLE_LOG_FILE=true sf data query -q "SELECT Id, Product2Id, AttributeDefinitionId, ProductClassificationAttributeId, DefaultValue, Status FROM ProductAttributeDefinition WHERE Product2Id='01tg8000003K9crAAC' LIMIT 3"
```
Confirma que `ProductClassificationAttributeId` está poblado y qué formato tiene `DefaultValue` (debe ser Value, no Code). **Además**, después del Paso 4-5, un smoke test: crear 1 sola coverage Pyme, asignar la classification vía UI, y hacer SOQL para ver si aparecen PADs sin creates manuales. Si NO aparecen, agendar creates manuales de PAD para las 6 coverages × 8 atributos = 48 PADs adicionales (ver Paso 5.b).

**0.f Describe ProductClassification** (resuelve MEDIUM #7):
```
SF_DISABLE_LOG_FILE=true sf sobject describe --sobject ProductClassification --json | jq '.fields[] | select(.name | test("Status|IsActive|Code")) | .name'
```
Ajustar Paso 4 según campos que existan (`Status` vs `IsActive` vs ninguno).

**0.g Describe AttributeCategory** (resuelve MEDIUM #6):
```
SF_DISABLE_LOG_FILE=true sf sobject describe --sobject AttributeCategory --json | jq '.fields[] | .name'
```
Si `Type` no existe → omitir del create en Paso 1. Si existe pero picklist values distintos → adaptar.

**0.h Describe ProductRelatedComponent** (resuelve LOW #16):
```
SF_DISABLE_LOG_FILE=true sf sobject describe --sobject ProductRelatedComponent --json | jq '.fields[] | select(.name | test("ParentProductRole|ChildProductRole|Sequence")) | {name, nillable, picklistValues: .picklistValues}'
```
Determinar si `ParentProductRole`/`ChildProductRole` son `nillable`; si no lo son, setearlos explícitamente en Paso 9.

**0.i Existencia de InsuranceDefaultPricingProcedure** (LOW #13):
```
SF_DISABLE_LOG_FILE=true sf data query -q "SELECT ApiName, UsageType FROM ExpressionSet WHERE UsageType='DefaultPricing'"
```

**0.j Locale del demo user** (LOW #14):
```
SF_DISABLE_LOG_FILE=true sf data query -q "SELECT Id, Username, LocaleSidKey, LanguageLocaleKey FROM User WHERE Username='<demo user>'"
```
Si `en_US`, agendar cambio de locale a `es_CO` antes de la sustentación.

### Paso 1 — AttributeCategory (3 records, 5 min)

Con el resultado de 0.g:

```
# Si Type existe:
sf data create record -s AttributeCategory -v "Name='Términos Pyme' Code=terminosPyme Type='Product Attribute'"
# Si no existe:
sf data create record -s AttributeCategory -v "Name='Términos Pyme' Code=terminosPyme"
```
Repetir para "Cobertura Base" (`coberturaBase`) y "Cobertura Adicional" (`coberturaAdicional`).

### Paso 2 — AttributePicklist + AttributePicklistValue (8 + ~40 valores, 45 min — era 30)

`sf data import tree --plan attribute-picklists-plan.json`. Ejemplo SumaAseguradaPyme:

```json
{
  "records": [{
    "attributes": {"type":"AttributePicklist","referenceId":"pl_sumaAseg"},
    "Name":"SumaAseguradaPyme","DataType":"Currency","Status":"Active",
    "AttributePicklistValues":{"records":[
      {"attributes":{"type":"AttributePicklistValue"},"Name":"Cien_MM","Code":"Cien_MM","Value":"100000000","DisplayValue":"COP 100,000,000","Status":"Active","IsDefault":true}
    ]}
  }]
}
```

**RangoEmpleados** (fix v2: `DataType=Text`, no `Number`):
```json
{"Name":"RangoEmpleados","DataType":"Text","Status":"Active",
 "AttributePicklistValues":{"records":[
  {"Name":"Once_Cincuenta","Code":"Once_Cincuenta","Value":"11-50 empleados","DisplayValue":"11-50 empleados","Status":"Active","IsDefault":true}
]}}
```

**SustanciasProhibidasPyme** — el picklist es Text plano; el multi-select se declara en el `AttributeDefinition` (Paso 3), no en el picklist.

Buffer +15 min vs v1 por resolver `referenceId` y errores de shape de sObject en primera pasada.

### Paso 3 — AttributeDefinition (8 records, 15 min)

Ejemplo:
```
sf data create record -s AttributeDefinition -v "Name='Suma Asegurada' Code=sumaAsegurada Label='Suma Asegurada' DeveloperName=SumaAsegurada DataType=Picklist IsActive=true PicklistId=<lookup SumaAseguradaPyme>"
```

Fix v2 — Sustancias Prohibidas:
```
sf data create record -s AttributeDefinition -v "Name='Sustancias Prohibidas' Code=sustanciasProhibidas Label='Sustancias Prohibidas' DeveloperName=SustanciasProhibidas DataType=Multipicklist IsActive=true PicklistId=<lookup SustanciasProhibidasPyme>"
```

### Paso 4 — ProductClassification (2 records, 5 min)

Con el resultado de 0.f. Si `Status` existe:
```
sf data create record -s ProductClassification -v "Name='Cobertura Pyme' Code=coberturaPyme Status=Active"
```
Si sólo `IsActive`: `IsActive=true`. Si ninguno: omitir el flag.

### Paso 5 — ProductClassificationAttr y PADs (20-40 min según Paso 0.e)

**5.a Assign en UI**: Product Catalog Management → Cobertura Pyme → Attributes → Assign by Category. Selecciona los 3 AttributeCategory. Genera 8 `ProductClassificationAttr`.

Si Assign by Category no está disponible (crítica LOW #12), Assign individual → 8 clicks. Registrar tiempo real; si excede 20 min, cortar 2 atributos del scope (mover Sustancias y Deducible Mínimo a "nice-to-have").

**5.b PAD auto vs manual**: después de Paso 6 (crear coverages), verificar con SOQL:
```
SF_DISABLE_LOG_FILE=true sf data query -q "SELECT COUNT(Id) FROM ProductAttributeDefinition WHERE Product2Id='<Id rcExtracontractual>'"
```
Si retorna 8 → auto-generado, seguir. Si retorna 0 → **crear 48 PADs manualmente** vía `sf data import tree` (agrega +30 min al time-box, dispara plan de corte del §6). Plantilla PAD:
```
sf data create record -s ProductAttributeDefinition -v "Product2Id=<lookup> AttributeDefinitionId=<lookup> ProductClassificationAttributeId=<lookup> DefaultValue=100000000 Status=Active"
```
`DefaultValue` = **el Value del picklist**, no el Code (fix crítica MEDIUM #9).

### Paso 6 — Product2 Simple coverages (6, 15 min)

Con resultado de 0.b. Rama B (recomendada por defecto):
```
sf data create record -s Product2 -v "Name='Responsabilidad Civil Extracontractual' ProductCode=rcExtracontractual ProductClass=Simple IsActive=true RecordTypeId=<lookup Commercial> StockKeepingUnit='Responsabilidad Civil Extracontractual' Description='Ampara la responsabilidad civil frente a terceros' SellOnlyWithOtherProducts=true"
```

**Nota v2:** `Type` **NO seteado** (Auto Gold coverages tienen `Type=null`). `Family` **NO seteado**. `BasedOnId` **NO seteado** en Rama B (linkage vía ProductClassificationAttr + PAD).

Si Paso 0.b probó Rama A (`BasedOnId` poblado en Gold hijas): añadir `BasedOnId=<lookup coberturaPyme>`.

Sólo agregar `External_ID__c=product.pyme.cov.01` si Paso 0.d confirmó existencia.

### Paso 7 — Product2 Bundle raíz "Plan Empresarial" (1, 5 min)

```
sf data create record -s Product2 -v "Name='Plan Empresarial' ProductCode=segPymeEmpresarial Type=Bundle ProductClass=Bundle Family=Miscellaneous IsActive=true ConfigureDuringSale=Allowed RecordTypeId=<lookup Commercial> StockKeepingUnit='Plan Empresarial' Description='Bundle raíz del Seguro Pyme Integral - Plan Empresarial'"
```

### Paso 8 — ProductComponentGroup (2, 5 min)

Fix v2 — `Sequence=null` (siguiendo Auto Gold Coverage group):
```
sf data create record -s ProductComponentGroup -v "Name='Coberturas' Code='Coberturas Pyme Empresarial' ParentProductId=<lookup segPymeEmpresarial>"
sf data create record -s ProductComponentGroup -v "Name='Establecimiento' Code='Establecimiento Pyme Empresarial' ParentProductId=<lookup segPymeEmpresarial>"
```

### Paso 9 — ProductRelatedComponent (7, 20 min)

Fix v2 — `Sequence` no seteado. `ParentProductRole` y `ChildProductRole` según Paso 0.h.

```
sf data create record -s ProductRelatedComponent -v "ParentProductId=<lookup segPymeEmpresarial> ChildProductId=<lookup rcExtracontractual> ProductComponentGroupId=<lookup Coberturas> ProductRelationshipTypeId=<lookup Bundle to Bundle Component Relationship> Quantity=1 IsQuantityEditable=false IsDefaultComponent=true IsComponentRequired=false DoesBundlePriceIncludeChild=true QuantityScaleMethod=Proportional"
```

Si 0.h reveló que los role fields no son `nillable`, agregar:
```
ParentProductRole=Bundle ChildProductRole=BundleComponent
```
(o `ChildProductRole=ClassificationComponent` en el PRC classification).

PRC classification:
```
sf data create record -s ProductRelatedComponent -v "ParentProductId=<lookup segPymeEmpresarial> ChildProductClassificationId=<lookup establecimientoComercial> ProductComponentGroupId=<lookup Establecimiento> ProductRelationshipTypeId=<lookup Bundle to Product Classification Component Relationship> Quantity=1"
```

### Paso 10 — ProductSellingModelOption (7, 10 min)

```
sf data create record -s ProductSellingModelOption -v "Product2Id=<lookup segPymeEmpresarial> ProductSellingModelId=<lookup OneTime> IsDefault=true"
```
Repetir para las 6 coverages.

### Paso 11 — PricebookEntry (7, 10 min)

```
sf data create record -s PricebookEntry -v "Product2Id=<lookup segPymeEmpresarial> Pricebook2Id=<lookup Standard> UnitPrice=2400000 IsActive=true UseStandardPrice=false"
```

### Paso 12 — ProductCategory + ProductCategoryProduct (2, 5 min)

```
sf data create record -s ProductCategory -v "Name='Seguros Pyme' Code=pymeIntegral CatalogId=<lookup Insurance Catalog>"
sf data create record -s ProductCategoryProduct -v "ProductId=<lookup segPymeEmpresarial> ProductCategoryId=<lookup Seguros Pyme>"
```

### Paso 13 — Verificación (10 min)

```
SF_DISABLE_LOG_FILE=true sf data query -q "SELECT Id, Name, ProductClass, Type, (SELECT ChildProduct.Name, IsDefaultComponent FROM ProductRelatedComponents) FROM Product2 WHERE ProductCode='segPymeEmpresarial'"
SF_DISABLE_LOG_FILE=true sf data query -q "SELECT COUNT(Id) FROM ProductAttributeDefinition WHERE Product2Id IN (SELECT Id FROM Product2 WHERE ProductCode LIKE 'rc%' OR ProductCode LIKE 'incendio%' OR ProductCode='equipoElectronico' OR ProductCode='roboAsalto' OR ProductCode='roturaMaquinaria' OR ProductCode='sustraccionDinero')"
```
Esperar 48 PADs (6 coverages × 8 atributos). Si difiere, investigar.

**Total records realista: ~90-140** según Paso 5.b. **Tiempo revisado: 2:55-3:40.**

---

## 4. Rules and pricing — minimum viable

### Pricing

**NO construir ExpressionSet + CalculationMatrix custom.** Justificación:

- Auto Gold V1 del ExpressionSet está inactivo — clonar y activar es propenso a error en time-box.
- Doc oficial confirma que una `PricebookEntry.UnitPrice` es suficiente para demo de single-root-product; `InsuranceDefaultPricingProcedure` lee `List Price` automáticamente.
- Historia "Insurance on Core = declarative product config" se sostiene con bundle + coverages + attributes + defaults + selling model + pricebook.

**MVP**: 7 `PricebookEntry`. Si sobra >30 min al final Y Paso 0.i confirmó existencia de `InsuranceDefaultPricingProcedure`, asignarla a un `ProcedurePlanDefinition` nuevo (`ProcessType=Insurance`, `ContextDefinition=InsuranceContext`). Si Paso 0.i no la encuentra, mencionar en la sustentación como "next step post-MVP".

### Reglas

**NO construir Product Configuration Rules ni Constraint Rules.** Justificación:

- Auto Gold tiene cero `ProductQualification`.
- CRE no disponible en el org.
- Product Configuration Rules requieren Rule Library + perm sets adicionales — riesgo.

**MVP reglas**: `AttributePicklistValue.IsDefault=true` + `ProductAttributeDefinition.DefaultValue` (usando **el Value del picklist**, no el Code — fix crítica MEDIUM #9). Diferenciación por plan vía `IsDefaultComponent` en PRC + `OverriddenProductAttributeDefinitionId` para DefaultValue distinto por bundle.

Si cliente pregunta "¿exclusiones por actividad económica?" — mostrar tab Rules del Product Modeler y explicar que Attribute Rules (`Hide Attribute` cuando `actividadEconomica=Manufactura`) es 1 record adicional agregable después.

---

## 5. Runtime plug-in

### ContextDefinition

Reutilizar `InsuranceContext` — la misma que usa Auto Gold. Sin cambios v2.

### OmniScript + LWC

Reutilizar `Insurance_CreateQuoteDCT_English_2`. Embebe el `industries_insurance_foundation:prodCfg` LWC. Wire: `contextId=%ContextId%`, `ratingInputs={"productCode":"segPymeEmpresarial","attributes":{...}}`, `ratingOptions={"pricingProcedure":"InsuranceDefaultPricingProcedure"}` (o vacío si Paso 0.i lo confirmó ausente), `transactionType="New Business"`.

**Locale note (crítica LOW #14):** si demo user es `en_US`, labels standard ("Product Code", "Unit Price") aparecen en inglés. Coordinar cambio a `es_CO` con admin del org antes de la sustentación (Paso 0.j lo detecta).

### FlexCard / Lightning page

Reutilizar `CompRaterResults` FlexCard. Sin Lightning page nueva. Demo desde Insurance Console → Nuevo Quote → picker "Plan Empresarial".

### Flows

Reutilizar `FINS_Issue_Insurance_Policy`. No modificar.

---

## 6. Effort breakdown vs budget (revisado a 5h)

Crítica LOW #12 flaggeó que 4h era optimista. Estimación honesta:

| # | Paso | Est. | Acumulado |
|---|---|---|---|
| 0 | Verificaciones (10 describes/queries + análisis) | 20 min | 0:20 |
| 1 | AttributeCategory (3) | 5 min | 0:25 |
| 2 | AttributePicklist + Values (8+~40) via `sf data import tree` | 45 min | 1:10 |
| 3 | AttributeDefinition (8) | 15 min | 1:25 |
| 4 | ProductClassification (2) | 5 min | 1:30 |
| 5 | ProductClassificationAttr (8, UI) + smoke test PAD auto | 20 min | 1:50 |
| 5b | PAD manuales (48) — sólo si Paso 5 smoke test falla | +30 min | (contingente) |
| 6 | Product2 Simple coverages (6) | 15 min | 2:05 |
| 7 | Product2 Bundle raíz | 5 min | 2:10 |
| 8 | ProductComponentGroup (2) | 5 min | 2:15 |
| 9 | ProductRelatedComponent (7) | 20 min | 2:35 |
| 10 | ProductSellingModelOption (7) | 10 min | 2:45 |
| 11 | PricebookEntry (7) | 10 min | 2:55 |
| 12 | ProductCategory + link | 5 min | 3:00 |
| 13 | Verificación Product Modeler + SOQL counts | 10 min | 3:10 |
| 14 | Smoke test E2E en Insurance_CreateQuoteDCT | 25 min | 3:35 |
| 15 | Buffer errores FK / describe mismatches / locale switch | 55 min | 4:30 |
| 16 | Documentar walkthrough para sustentación | 30 min | 5:00 |

**Total realista: 5:00 con 55 min buffer.** Si Paso 5.b dispara PADs manuales, buffer se consume + 30 min → recortar según plan de corte abajo.

### Qué cortar si vamos apretados

1. **Primero**: skip Paso 12 (ProductCategory) — bundle queryable sin categoría. **-5 min.**
2. **Segundo**: reducir a 4 coverages (skip Rotura, Sustracción). **-20 min y -6 PADs.**
3. **Tercero**: skip Sustancias Prohibidas + Deducible Mínimo Evento (2 atributos "extras"). **-2 AttributeDefinitions, -12 PADs si manuales, -5 min.**
4. **Cuarto**: skip defaults per-plan (`OverrideContextId`) — usar defaults globales. **-15 min.**
5. **NO cortar**: PSMO, PricebookEntry, ProductClassification + PADs core (Suma, Deducible, Actividad, Rango Empleados).

Piso mínimo: 3 coverages (RC, Incendio, Robo) + 1 plan + 4 atributos → la historia se sostiene.

---

## 7. Field-name and value cheat-sheet

Cambios v2 marcados con **⚡**.

| SObject | Field | Type | Ejemplo Pyme | Notas |
|---|---|---|---|---|
| Product2 (root) | Name | String | Plan Empresarial | User-facing |
| Product2 (root) | ProductCode | String | segPymeEmpresarial | camelCase |
| Product2 (root) | Type | Picklist | Bundle | ⚡ Válido para roots; **NO setear** en coverages Simple |
| Product2 (root) | ProductClass | Picklist | Bundle | Picklist, NO lookup |
| Product2 (root) | Family | Picklist | Miscellaneous | ⚡ Sólo en root; **null** en coverages |
| Product2 (root) | IsActive | Boolean | true | |
| Product2 (root) | ConfigureDuringSale | Picklist | Allowed | |
| Product2 (root) | External_ID__c | String | product.pyme.001 | Custom — Paso 0.d confirma existencia |
| Product2 (root) | StockKeepingUnit | String | Plan Empresarial | |
| Product2 (root) | BasedOnId | Lookup | null (bundle root) | ⚡ Peer pattern |
| Product2 (coverage) | Type | — | **omitir** | ⚡ Auto Gold coverages `Type=null` |
| Product2 (coverage) | Family | — | **omitir** | ⚡ Auto Gold coverages `Family=null` |
| Product2 (coverage) | ProductClass | Picklist | Simple | |
| Product2 (coverage) | BasedOnId | Lookup | ⚡ **null por defecto** (Rama B) o Id classification (Rama A) | Paso 0.b decide |
| Product2 (coverage) | SellOnlyWithOtherProducts | Boolean | true | |
| Product2 | RecordTypeId | Lookup | Commercial | Paso 0.c verifica |
| ProductRelationshipType | Name | String | Bundle to Bundle Component Relationship / Bundle to Product Classification Component Relationship | OOTB |
| ProductComponentGroup | Name | String | Coberturas | |
| ProductComponentGroup | Code | String | Coberturas Pyme Empresarial | Silver-style |
| ProductComponentGroup | Sequence | Number | ⚡ **null** | Gold pattern (era 1/2 en v1) |
| ProductComponentGroup | ParentProductId | Lookup | Id Plan Empresarial | |
| ProductRelatedComponent | Quantity | Number | 1 | |
| ProductRelatedComponent | IsQuantityEditable | Boolean | false | |
| ProductRelatedComponent | IsDefaultComponent | Boolean | true (Empresarial) / false (Esencial) | Diferenciador |
| ProductRelatedComponent | IsComponentRequired | Boolean | false | |
| ProductRelatedComponent | DoesBundlePriceIncludeChild | Boolean | true | |
| ProductRelatedComponent | QuantityScaleMethod | Picklist | Proportional | |
| ProductRelatedComponent | Sequence | Number | ⚡ **null** | Gold+Silver ambos null |
| ProductRelatedComponent | ParentProductRole | Picklist | ⚡ Bundle (si Paso 0.h no-nillable, si no omitir) | |
| ProductRelatedComponent | ChildProductRole | Picklist | ⚡ BundleComponent o ClassificationComponent (según Paso 0.h) | |
| ProductRelatedComponent | ChildProductId / ChildProductClassificationId | Lookup | Mutex | |
| ProductClassification | Name | String | Cobertura Pyme | |
| ProductClassification | Code | String | coberturaPyme | |
| ProductClassification | Status / IsActive | ⚡ Según Paso 0.f | Active / true | Verificar cuál existe |
| AttributeCategory | Name | String | Términos Pyme | Con acento |
| AttributeCategory | Code | String | terminosPyme | Sin acento |
| AttributeCategory | Type | ⚡ Según Paso 0.g | Product Attribute (si existe) | |
| AttributeDefinition | Name/Label | String | Suma Asegurada | PascalCase con espacios |
| AttributeDefinition | Code | String | sumaAsegurada | camelCase |
| AttributeDefinition | DeveloperName | String | SumaAsegurada | Sin espacios, sin acentos |
| AttributeDefinition | DataType | Picklist | Picklist / **Multipicklist** (Sustancias) | ⚡ Multipicklist para Sustancias |
| AttributeDefinition | PicklistId | Lookup | Id AttributePicklist | Required si DataType=Picklist/Multipicklist |
| AttributeDefinition | IsActive | Boolean | true | |
| AttributePicklist | Name | String | SumaAseguradaPyme | Sin espacios |
| AttributePicklist | DataType | Picklist | Currency / **Text** (Rangos) / Percentage | ⚡ Rangos son Text |
| AttributePicklistValue | Code | String | Cien_MM | Token |
| AttributePicklistValue | Value | String | 100000000 | ⚡ Valor rateado — lo que consume rating engine |
| AttributePicklistValue | DisplayValue | String | COP 100,000,000 | User-facing |
| AttributePicklistValue | IsDefault | Boolean | true (uno por picklist) | |
| ProductAttributeDefinition | Product2Id | Lookup | Id coverage | |
| ProductAttributeDefinition | AttributeDefinitionId | Lookup | Id AttrDef | |
| ProductAttributeDefinition | ProductClassificationAttributeId | Lookup | Id PCA | Auto Gold siempre lo tiene |
| ProductAttributeDefinition | DefaultValue | String | ⚡ **100000000** (el Value, NO Cien_MM/Code) | Fix crítica MEDIUM #9 |
| ProductAttributeDefinition | Status | Picklist | Active | Default es Draft — explícito |
| ProductSellingModel | SellingModelType | Picklist | OneTime | Reusar |
| ProductSellingModelOption | Product2Id | Lookup | Id Product2 | ⚡ NO `ProductId` |
| ProductSellingModelOption | ProductSellingModelId | Lookup | Id OneTime | |
| ProductSellingModelOption | IsDefault | Boolean | true | |
| PricebookEntry | Product2Id, Pricebook2Id, UnitPrice, IsActive, UseStandardPrice | — | — | UseStandardPrice=false cuando UnitPrice custom |
| ProductCategory | Name, Code, CatalogId | — | Seguros Pyme, pymeIntegral, <lookup> | NO `ProductCatalogId` |
| ProductCategoryProduct | ProductId, ProductCategoryId | — | Join table | NO `CategoryProductAssignment` |
| ContextDefinition | DeveloperName | String | InsuranceContext | Reusar |

---

## 8. Risks and open questions

Todos los items de la crítica reflejados. Cada uno con su mitigación en Paso 0 o en el flujo.

1. **`Product2.Type` en coverages (CRITICAL crítica #1)** — Auto Gold tiene `Type=null` en hijas Simple. Spec v2 NO setea `Type` en las 6 coverages Pyme; sólo `ProductClass=Simple`. Paso 0.b lo verifica antes.

2. **`Product2.BasedOnId` en coverages (CRITICAL crítica #2)** — La inspección no confirma que Auto Gold lo setee en hijas. Spec v2 tiene **Rama B por defecto** (BasedOnId=null) y Rama A condicional según Paso 0.b. Linkage vía `ProductClassificationAttr` es el mecanismo confirmado por inspección.

3. **PAD auto-generation (CRITICAL crítica #3)** — Spec v2 no asume auto-gen. Paso 5.b hace smoke test tras crear la primera coverage; si retorna 0 PADs, se agenda plan de corte y creates manuales (+30 min al time-box con buffer del §6).

4. **Rango* DataType (CRITICAL crítica #4)** — Fix aplicado: `RangoEmpleados` y `RangoMetrosCuadrados` ahora `AttributePicklist.DataType=Text`, `AttributePicklistValue.Value` es el string legible ("11-50 empleados"). Rating recibe el string; si en el futuro necesita numérico, se agrega un AttrDef `numeroEmpleadosExacto` separado.

5. **Sustancias Prohibidas (MEDIUM crítica #5)** — Fix aplicado: `AttributeDefinition.DataType=Multipicklist`. Múltiples sustancias posibles.

6. **`AttributeCategory.Type` (MEDIUM crítica #6)** — Paso 0.g describe. Si el campo o el picklist value no existen, se omite del create.

7. **`ProductClassification.Status/Code` (MEDIUM crítica #7)** — Paso 0.f describe. Spec adapta a `Status` / `IsActive` / omitir.

8. **`Sequence` en PCG y PRC (MEDIUM crítica #8)** — Fix aplicado: `Sequence=null` en todos los PRC y en los PCG (Gold pattern). Cheat-sheet actualizado.

9. **`ProductAttributeDefinition.DefaultValue` (MEDIUM crítica #9)** — Fix aplicado: usar `AttributePicklistValue.Value`, NO `.Code`. Ej.: `DefaultValue='100000000'` (no `'Cien_MM'`). Cheat-sheet §7 y §2.5 corregidos.

10. **PSMO field naming (MEDIUM crítica #10)** — Confirmado: `Product2Id`, `ProductSellingModelId`, `IsDefault`. Cheat-sheet marca explícito.

11. **English leaks (LOW crítica #11)** — DeveloperName sin acentos ('SumaAsegurada') es intencional por convención Salesforce. Locale del user en Paso 0.j.

12. **Time-box optimista (LOW crítica #12)** — Revisado a 5h en §6, con buffer 55 min y Paso 5.b contingente.

13. **`InsuranceDefaultPricingProcedure` (LOW crítica #13)** — Paso 0.i verifica antes de recomendarla; si no existe, PricebookEntry-only es suficiente.

14. **Locale (LOW crítica #14)** — Paso 0.j lee locale del demo user; cambio a `es_CO` agendado si es `en_US`.

15. **PRC roles (LOW crítica #16)** — Paso 0.h describe si `ParentProductRole`/`ChildProductRole` son nillable; spec setea explícitamente si no lo son.

16. **Insurance Coexistence (LOW crítica #17)** — Paso 0.c lista todos los RTs de Product2; namespaces gestionados aparecerán con prefijos. Si hay colisión con managed package, ajustar RT en vivo.

17. **Sandbox refresh timing** — Todos los lookups son por Name/Code/DeveloperName, resistentes a refresh. Coordinar con Laura/team que no se refresque entre 2026-07-07 y 2026-07-08 AM.

18. **`sf` CLI**: `SF_DISABLE_LOG_FILE=true` como prefix o exportado al inicio de sesión.
---

## Anexo — Paso 0 ejecutado (2026-07-07 10:52)

### Referencias resueltas (por Name, no hardcodear)
- **ProductRelationshipType** "Bundle to Bundle Component Relationship" → resuelve dinámico por Name
- **ProductRelationshipType** "Bundle to Product Classification Component Relationship" → resuelve dinámico
- **ProductSellingModel** "One Time" (SellingModelType=OneTime, Status=Active) → resuelve dinámico
- **Standard Price Book** (IsStandard=true)
- **ProductCatalog** "Insurance Catalog"
- **ProductClassification** "Coverage" (Code=coverage, Status=Active) — es la que Auto Gold usa en `BasedOnId` de sus coverages

### Auto Gold model — VALIDACIONES (con SOQL en vivo)

| Campo | Root "Auto Gold" | Coverages hijas |
|---|---|---|
| Type | Bundle | **null** |
| ProductClass | Bundle | Simple |
| Family | Miscellaneous | null |
| BasedOnId | null | **Id del ProductClassification "Coverage"** — RAMA A confirmada |
| RecordType.DeveloperName | **Commercial** | **Coverage** (¡NO Commercial\!) |
| ConfigureDuringSale | Allowed | Allowed |

**Cambio crítico vs spec v2:** las coverages deben usar **RecordType `Coverage`** (dedicado), no `Commercial`. Los 12 RecordTypes disponibles incluyen Coverage, Commercial, InsuredItem, InsuredParty, Product, etc.

**PADs Auto Gold ejemplo:** `Name="Bodily Injury Per Accident Limit"`, `DefaultValue="1000"` (matches AttributePicklistValue.Value), `Status=Active`, `IsRequired=false`, `Sequence=null`. **PAD.Name = AttributeDefinition.Name** (mismo string).

**ProductClassificationAttr Auto Gold Coverage:** rows tienen `Status=Inactive` (side effect); `Name` = AttributeDefinition.Name (e.g., "Bodily Injury Per Accident Limit"). Para Pyme crear con `Status=Active`.

### Correcciones a la spec v2

1. **Paso 6 (Product2 coverages):**
   - `RecordType.DeveloperName = 'Coverage'` (no `Commercial`)
   - `BasedOnId = <lookup ProductClassification 'Cobertura Pyme'>` — **Rama A confirmada** (Auto Gold hijas SÍ tienen BasedOnId poblado)
   - **Quitar `SellOnlyWithOtherProducts=true`** — el field NO EXISTE en Product2 en esta org
   - `Type` NO se setea (validado — coverages Auto Gold tienen `Type=null`)

2. **Paso 9 (ProductRelatedComponent):**
   - `ParentProductRole='Bundle'` y `ChildProductRole` **SON REQUIRED** (`nillable=false`). Setear explícito.
   - Product2 children: `ChildProductRole='BundleComponent'`
   - Classification PRC: `ChildProductRole='ClassificationComponent'`
   - Picklist values validados: `ParentProductRole` acepta [Bundle, Set, AddOn, ProductRequest]; `ChildProductRole` acepta [BundleComponent, SetComponent, AddOnComponent, ClassificationComponent, ProductRequestComponent]

3. **Paso 5 (ProductClassificationAttr):**
   - `Name` es required — usar el mismo nombre de la `AttributeDefinition` (ej. `Name='Suma Asegurada'`)
   - Crear con `Status='Active'` (Auto Gold tiene Inactive por side-effect, no replicar)

4. **Paso 4 (ProductClassification):**
   - `Code` es required (no nillable). `Status='Active'`. Picklist values: [Draft, Active, Inactive].

5. **Paso 1 (AttributeCategory):**
   - `Type` field **no existe** en AttributeCategory. Confirmed skip. Campos createable: Name, Code, Description, CurrencyIsoCode, External_Id__c.

6. **Paso 8 (ProductComponentGroup):**
   - `Code` es **unique globalmente** — usar "Coberturas Pyme Empresarial" y "Establecimiento Pyme Empresarial" (Silver-style con sufijo plan)
   - `Sequence=null` OK (Coverage group de Auto Gold tiene Sequence=null; Auto group Sequence=1 — no consistente, dejar null)

7. **Pricing (Paso 11):**
   - `InsuranceDefaultPricingProcedure` **NO existe** en la org — solo hay group-specific (Group_Insurance_Default_Pricing_Procedure, GroupDental, GroupMedical, GroupVision). **Confirmado MVP = PricebookEntry only.**

8. **Locale — NUEVO STEP:**
   - Nehuen locale = `en_US`, currency = `USD`. **Antes de la sustentación** cambiar a `es_CO` / `COP` (o aceptar la contextualización verbal). Decisión ahora: mantener demo en `en_US` para no romper otros bloques por currency switching; usar Description/Name en español, y aceptar labels standard de Salesforce en inglés (Product Code, Unit Price, etc.). Explicar en la sustentación como "el usuario final tendría locale es_CO".

### Product2 Type picklist verificado
Valores válidos: **[Base, Bundle, Set]**. `Simple` NO es Type válido (aunque sí ProductClass). Confirma que coverages Simple **NO setean Type**.

### Custom fields en Product2 disponibles
- `External_ID__c` (string) — usar para trazabilidad
- `Product_Catalog__c` (picklist [Basic, Premium]) — **omitir** (valores no aplican a Pyme)
- `analyticsdemo_batch_id__c` (irrelevante)

### Cambio de time-box
Paso 0 tomó 20 min como estimado. Sin sorpresas mayores — la spec v2 es viable con los 8 fixes anexados. Time-box sigue en 5h.

