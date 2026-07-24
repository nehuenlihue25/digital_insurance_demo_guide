# Seguro Pyme Integral — Build Specification (Block 1, Presentation 2026-07-09) — v2 (post-critique)

Reference model: Auto Gold (Product2 `01tg8000003K9biAAC`) in ins-qbranch-alfa.
Time-box: revised to **~5h** (was 4h; see §6). Everything user-facing is in Spanish.

**v2 changes:** required describes moved to Step 0; `Type` unchecked on coverages; `BasedOnId` on children moved behind an explicit describe; `ProductClassificationAttr` treated as a verified manual step, not magic; `DefaultValue` corrected to `Value`, not `Code`; `Sequence=null` on PRCs; `Rango*` picklists converted to Text; Sustancias Prohibidas switched to Multipicklist; `AttributeCategory.Type` and `ProductClassification.Status` described before creating.

---

## 1. Auto Gold teardown (reference model)

**Bundle hierarchy.** Auto Gold is a root `Product2` (`01tg8000003K9biAAC`) with `ProductClass=Bundle`, `Type=Bundle`, `Family=Miscellaneous`, `ProductCode=autoGold`, `BasedOnId=null`. Its structure is 2 levels: under the bundle there are 2 `ProductComponentGroup` ("Coverage" `0y7g80000008n28AAA` and "Auto" `0y7g80000008n23AAA`). The Coverage group contains 3 `ProductRelatedComponent` (PRC) pointing to Simple `Product2`: Rental Auto Coverage (`01tg8000003K9cqAAC`), Bodily Injury & Property Damage (`01tg8000003K9crAAC`), and Medical Payments (`01tg8000003K9csAAC`), all via `ProductRelationshipType` "Bundle to Bundle Component Relationship" (`0yog8000000DOkTAAW`). The Auto group contains 1 classification PRC → `ProductClassification` "Vehicle" (`11Bg800000BsmlPEAR`) via "Bundle to Product Classification Component Relationship" (`0yog8000000DOkUAAW`). Auto Silver (`01tg8000003K9bjAAC`) is structurally identical but: (a) 2 coverages instead of 3, (b) `IsDefaultComponent=true` on its PRCs, (c) groups with `Code` populated. Auto Silver is NOT based on Auto Gold (`BasedOnId=null`); they are peer bundles.

**Critical Product2 field convention (validated by inspection):**
- Root bundle: `Type='Bundle'` **and** `ProductClass='Bundle'` (both set with the same value).
- Simple child coverages: `Type=null` (not `Type='Simple'`!) and only `ProductClass='Simple'`. `Family=null`. This reflects what exists in the org — do not assume `'Simple'` is a valid picklist value in `Type`.
- Root bundle: `Family='Miscellaneous'`; children `Family=null`.
- `BasedOnId=null` on the root Bundle. Inspection **does not confirm** that Auto Gold sets `BasedOnId` on its child coverages — the classification→coverage linkage is materialized via `ProductClassificationAttr` + `ProductAttributeDefinition.ProductClassificationAttributeId`. Before assuming that setting `Product2.BasedOnId` auto-generates PADs, we need to verify (Step 0.b).

**PRC field conventions (validated):** `Sequence=null` **on all Auto Gold and Silver PRCs** — order is inferred from creation order. `MinQuantity=null`, `MaxQuantity=null`, `Quantity=1`, `IsQuantityEditable=false`, `IsComponentRequired=false`, `DoesBundlePriceIncludeChild=true`, `QuantityScaleMethod='Proportional'`. Additionally: `ParentProductRole='Bundle'` on all PRCs and `ChildProductRole` is either `'BundleComponent'` (for Product2 children) or `'ClassificationComponent'` (for the classification PRC). It is not confirmed whether these two roles auto-populate from `ProductRelationshipTypeId` or must be set explicitly — describe in Step 0.

**PCG (ProductComponentGroup):** `Sequence` is null on the Gold "Coverage" group; Silver has it populated. Not required.

**Attributes.** The root bundle has **zero PADs**. Attributes live on the 3 child coverages, all associated with the `ProductClassification` "Coverage" (`11Bg800000BsmlTEAR`) via `ProductClassificationAttr`. Total: 34 `ProductAttributeDefinition` (9 Rental, 13 BIPD, 12 Medical). All `DataType=Picklist`, grouped in 3 `AttributeCategory`: "Auto Term", "In-Network", "Out-Network". Reusable `AttributePicklist`: BIPDLimit, Limit, Deductible, Number Of Days, Copay, Coinsurance, Deductible Limit. Naming: `AttributeDefinition.Name` PascalCase-with-spaces ("Bodily Injury Per Accident Limit"), `Code` camelCase. **Critical defaults:** `ProductAttributeDefinition.DefaultValue` on Auto Gold is `'1000'`, `'1500'`, `'5'` — that is, it matches `AttributePicklistValue.Value`, **not** `.Code`. This is a fix vs. v1.

**Selling model & pricing.** `ProductSellingModelOption` PSMO-000000011 links Auto Gold to the `ProductSellingModel` "One Time" (`SellingModelType=OneTime`, `IsDefault=true` on the PSMO). Verified fields: PSMO uses `Product2Id` (not `ProductId`) and `ProductSellingModelId`. Base pricing: 1 `PricebookEntry` on the Standard Pricebook (`UnitPrice=450`). Rating via `ExpressionSet` "AutoGoldPricingProcedure" (`UsageType=DefaultPricing`, `InterfaceSourceType=PricingProcedure`) over `ExpressionSetDefinition`. **Note:** Gold ExpressionSet V1 is `IsActive=false`; the live one running is Silver V10. There is no Auto-specific `CalculationMatrix` — rating consumes the 10 standard Bre matrices.

**Rules & eligibility.** Auto Gold has **zero** `ProductQualification`. No ConstraintModel/ConstraintRule in the org. Rating rules live inside the ExpressionSet.

**Context & discovery.** 6 org-shared `ContextDefinition`, inherited from `__stdctx`. Auto Gold lives in the `ProductCategory` "Auto Insurance" of the `ProductCatalog` "Insurance Catalog", linked via `ProductCategoryProduct`.

**Runtime.** Auto Gold consumes generic OmniScripts (Insurance_CreateQuoteDCT_English_2, Auto_QuoteProposal_English_3), FlexCard CompRaterResults, Flow FINS_Issue_Insurance_Policy.

**Lifecycle metadata.** `External_ID__c=product.36` (custom field), `StockKeepingUnit='Auto Gold'`, `RecordType=Commercial`, `ConfigureDuringSale=Allowed`, null dates.

---

## 2. Seguro Pyme Integral — architectural spec

### 2.1 Root Product2

| Field | Value | Note |
|---|---|---|
| `Name` | Plan Empresarial | |
| `ProductCode` | segPymeEmpresarial | camelCase |
| `Type` | Bundle | Verified as a valid picklist value on Auto Gold root |
| `ProductClass` | Bundle | |
| `Family` | Miscellaneous | |
| `IsActive` | true | |
| `ConfigureDuringSale` | Allowed | |
| `RecordType.DeveloperName` | Commercial | Verify it exists (Step 0.c) |
| `Description` | Seguro integral para pequeñas y medianas empresas — cobertura combinada de daños materiales, responsabilidad civil y sustracción. | |
| `StockKeepingUnit` | Plan Empresarial | |
| `External_ID__c` | product.pyme.001 | Custom field — only if Step 0.d confirms it exists |
| `BasedOnId` | null | Independent peer (Gold/Silver pattern) |
| `Product_Catalog__c` | omit | Null in Auto Gold |

### 2.2 Plan strategy (decision: 3 peer bundles, Gold/Silver pattern)

**Analysis.** Auto Gold and Auto Silver are independent peers (`BasedOnId=null` in both), share 2 coverages, and each one redefines its PRC with a different `IsDefaultComponent`. No super-bundle.

**Pyme decision.** 3 peer bundles (`Plan Esencial`, `Plan Empresarial`, `Plan Corporativo`), each `ProductClass=Bundle`, `BasedOnId=null`, sharing the same 6 Simple Product2. Differences per plan: (1) which coverages are included, (2) `IsDefaultComponent` on the PRC, (3) PAD `DefaultValue` via bundle context override (`OverriddenProductAttributeDefinitionId` / `OverrideContextId`).

For the time-box: build only **Plan Empresarial** completely; the other 2 are explained in the presentation as "same template, different PRC/defaults selection".

### 2.3 Coverages (6 shared Simple `Product2`)

All with `ProductClass=Simple`, `Type` **NOT set** (following Auto Gold: coverages have `Type=null`), `Family` not set (Gold has `Family=null` on children), `IsActive=true`, `SellOnlyWithOtherProducts=true`, `RecordType=Commercial` (same RT as the bundle, following Auto Gold — don't use 'Coverage Spec' until confirmed to exist in the org).

**`BasedOnId` on coverages: CONDITIONAL DECISION.** The inspection does not confirm that Auto Gold sets `BasedOnId` on its children — it only confirms the children are linked to the "Coverage" classification via `ProductClassificationAttr` + PADs with `ProductClassificationAttributeId` populated. Step 0.e runs a SOQL over Auto Gold children to read `BasedOnId`. Two branches:

- **Branch A (BasedOnId populated on Gold children):** set `Product2.BasedOnId = Id(ProductClassification 'Cobertura Pyme')` on the 6 coverages. PADs may or may not auto-generate — validate Step 5.
- **Branch B (BasedOnId null on Gold children):** leave `BasedOnId=null` on the 6 Pyme coverages and force the linkage via `ProductClassificationAttr` + PADs manually. **This is the default path in the spec because it is what inspection observed.**

| # | Name | ProductCode | External_ID__c |
|---|---|---|---|
| 1 | Responsabilidad Civil Extracontractual | rcExtracontractual | product.pyme.cov.01 |
| 2 | Incendio y Aliados | incendioAliados | product.pyme.cov.02 |
| 3 | Equipo Electrónico | equipoElectronico | product.pyme.cov.03 |
| 4 | Robo y Asalto Interior | roboAsalto | product.pyme.cov.04 |
| 5 | Rotura de Maquinaria | roturaMaquinaria | product.pyme.cov.05 |
| 6 | Sustracción de Dinero y Valores | sustraccionDinero | product.pyme.cov.06 |

### 2.4 ProductClassification hierarchy

| Name | Code | Use |
|---|---|---|
| Cobertura Pyme | coberturaPyme | Attribute-schema parent for the 6 coverages |
| Establecimiento Comercial | establecimientoComercial | Classification component (equivalent to "Vehicle") |

**Note:** The exact `ProductClassification` fields (existence of `Status`, `Code`) are verified in Step 0.f with describe. If `Status` does not exist, use `IsActive` (more common on the platform). If neither exists, omit the flag and rely on the default.

### 2.5 Attributes

Grouped in 3 `AttributeCategory`. **`AttributeCategory.Type`** — inspection did not confirm this field; Step 0.g validates with describe. If the `Type` field exists with value `'Product Attribute'`, set it; otherwise omit.

**AttributePicklist (fixes vs v1):**

| Picklist Name | DataType | Values (Code / Value / DisplayValue) | Default |
|---|---|---|---|
| SumaAseguradaPyme | Currency | Cincuenta_MM/50000000/COP 50,000,000; Cien_MM/100000000/COP 100,000,000; Doscientos_MM/200000000/COP 200,000,000; Quinientos_MM/500000000/COP 500,000,000; Mil_MM/1000000000/COP 1,000,000,000 | Cien_MM |
| DeduciblePyme | Currency | Un_MM/1000000; Dos_MM/2000000; Cinco_MM/5000000; Diez_MM/10000000 | Dos_MM |
| ActividadEconomica | Text | Comercio, Servicios, Manufactura, Tecnologia, Construccion, Alimentos (Code=Value=DisplayValue) | Comercio |
| PorcentajeCoaseguro | Percent | Diez/10; Quince/15; Veinte/20; Treinta/30 | Diez |
| **RangoEmpleados** | **Text** (was Number — fix) | Uno_Diez/"1-10 empleados"; Once_Cincuenta/"11-50 empleados"; CincuentaUno_Cien/"51-100 empleados"; Mas_Cien/"Más de 100 empleados" | Once_Cincuenta |
| **RangoMetrosCuadrados** | **Text** (was Number — fix) | Hasta_100/"Hasta 100 m²"; De_101_500/"101-500 m²"; De_501_1000/"501-1,000 m²"; Mas_1000/"Más de 1,000 m²" | De_101_500 |
| DeducibleMinimoEvento | Currency | Medio_MM/500000; Un_MM/1000000; Dos_MM/2000000 | Un_MM |
| SustanciasProhibidasPyme | Text | Ninguna, Explosivos, Inflamables_Alto_Riesgo, Sustancias_Toxicas | Ninguna |

**Range fix:** Ranges are semantically ranges, not point values. If sent as `Number=50` to rating when the user sees "11-50 empleados", the engine receives a misleading midpoint. `DataType=Text` with `Value=DisplayValue` is explicit and unambiguous. If rating later needs a numeric value, add a separate `numeroEmpleadosExacto` AttributeDefinition of type `Number`.

**AttributeDefinition (assigned to "Cobertura Pyme"):**

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

**Sustancias fix:** a company may have multiple prohibited substances — `DataType=Multipicklist` is the correct representation. Note: `AttributeDefinition.DataType='Multipicklist'` is a valid value per docs; requires `PicklistId` just like `Picklist`.

**`DefaultValue` on PADs (critical fix):** Auto Gold sets `DefaultValue='1000'` when `AttributePicklistValue.Value='1000'`. **Therefore**, `ProductAttributeDefinition.DefaultValue` on Pyme is set to the **Value**, not the Code:

- Suma Asegurada default → `DefaultValue='100000000'` (not `'Cien_MM'`)
- Deducible default → `DefaultValue='2000000'` (not `'Dos_MM'`)
- Actividad Económica default → `DefaultValue='Comercio'` (Value=Code here — coincidence OK)
- Rango de Empleados default → `DefaultValue='11-50 empleados'` (the Value, as text)
- Porcentaje de Coaseguro → `DefaultValue='10'`
- Sustancias Prohibidas → `DefaultValue='Ninguna'` (for Multipicklist can accept CSV but just Ninguna)

### 2.6 ProductRelatedComponent rows (for Plan Empresarial)

Auto Gold convention (validated): `Quantity=1`, `IsQuantityEditable=false`, `IsComponentRequired=false`, `DoesBundlePriceIncludeChild=true`, `QuantityScaleMethod=Proportional`, `MinQuantity=null`, `MaxQuantity=null`, **`Sequence=null`** (v2 fix — Auto Gold has Sequence=null on all its PRCs). Key difference vs Gold: `IsDefaultComponent=true` (Silver-style) on the core coverages.

`ParentProductRole` and `ChildProductRole` are **not set explicitly** on create; Step 0.h describes the object to confirm whether they auto-populate from `ProductRelationshipTypeId`. If they are required, add `ParentProductRole='Bundle'` and `ChildProductRole='BundleComponent'` (or `'ClassificationComponent'`).

**Group 1: "Coberturas"** (`ParentProductId`=Plan Empresarial, `Code='Coberturas Pyme Empresarial'`, `Sequence=null` for consistency with Gold — v2 note)

| ChildProduct | RelationshipType | IsDefaultComponent |
|---|---|---|
| Responsabilidad Civil Extracontractual | Bundle to Bundle Component Relationship | true |
| Incendio y Aliados | Bundle to Bundle Component Relationship | true |
| Equipo Electrónico | Bundle to Bundle Component Relationship | true |
| Robo y Asalto Interior | Bundle to Bundle Component Relationship | true |
| Rotura de Maquinaria | Bundle to Bundle Component Relationship | false (optional) |
| Sustracción de Dinero y Valores | Bundle to Bundle Component Relationship | false (optional) |

**Group 2: "Establecimiento"** (`Code='Establecimiento Pyme Empresarial'`)

| ChildClassification | RelationshipType |
|---|---|
| Establecimiento Comercial | Bundle to Product Classification Component Relationship |

### 2.7 ProductSellingModelOption

Reuse the existing `ProductSellingModel` "One Time". Create:
- 1 PSMO for Plan Empresarial → OneTime, `IsDefault=true`.
- 6 PSMO (one per coverage) → OneTime, `IsDefault=true`.

Total: 7 PSMO. Fields: `Product2Id`, `ProductSellingModelId`, `IsDefault`.

### 2.8 ProductCategory + ProductCategoryProduct

Reuse `ProductCatalog` "Insurance Catalog". Create `ProductCategory` "Seguros Pyme" (`Code=pymeIntegral`, `CatalogId=<lookup>`, `ParentCategoryId=null`) + `ProductCategoryProduct` for Plan Empresarial.

### 2.9 PricebookEntry

7 rows on the Standard Pricebook, `UseStandardPrice=false`, `IsActive=true`, `UnitPrice` (COP):

| Product | UnitPrice |
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

**Key v2 change:** Step 0 now includes **8 verification describes/queries** that resolve the ambiguities identified by the critique before touching the org.

**Tool convention:** `sf data create record` for <10 records per sObject; `sf data import tree` for picklists+values; SOQL by Name/Code/DeveloperName (never hardcoded Ids); prefix `SF_DISABLE_LOG_FILE=true`.

### Step 0 — Prerequisite verification (20 min — was 5)

**0.a OOTB relationship types and bases:**
```
SF_DISABLE_LOG_FILE=true sf data query -q "SELECT Id, Name FROM ProductRelationshipType WHERE Name IN ('Bundle to Bundle Component Relationship','Bundle to Product Classification Component Relationship')"
SF_DISABLE_LOG_FILE=true sf data query -q "SELECT Id FROM ProductSellingModel WHERE SellingModelType='OneTime' AND Status='Active'"
SF_DISABLE_LOG_FILE=true sf data query -q "SELECT Id FROM Pricebook2 WHERE IsStandard=true"
SF_DISABLE_LOG_FILE=true sf data query -q "SELECT Id FROM ProductCatalog WHERE Name='Insurance Catalog'"
```

**0.b Auto Gold coverage children — read `BasedOnId` and `Type`** (resolves CRITICAL critique #1 and #2):
```
SF_DISABLE_LOG_FILE=true sf data query -q "SELECT Id, Name, Type, ProductClass, Family, BasedOnId, RecordType.DeveloperName FROM Product2 WHERE Id IN ('01tg8000003K9cqAAC','01tg8000003K9crAAC','01tg8000003K9csAAC')"
```
If `BasedOnId` is null on all → confirm Branch B (leave null on Pyme coverages, force manual linkage). If populated → Branch A.
If `Type=null` on all → do NOT set `Type` on Pyme coverages.

**0.c RecordType Commercial:**
```
SF_DISABLE_LOG_FILE=true sf data query -q "SELECT Id, DeveloperName FROM RecordType WHERE SobjectType='Product2'"
```
If `Commercial` does not exist but `Coverage Spec` or another does, adjust the spec live. If the org has coexistence with the Insurance managed package (critique LOW #17), duplicate RTs with `SFA__` or similar namespaces will appear.

**0.d Custom fields on Product2:**
```
SF_DISABLE_LOG_FILE=true sf sobject describe --sobject Product2 --json | jq '.fields[] | select(.name | test("External_ID__c|Product_Catalog__c")) | .name'
```
If `External_ID__c` does not exist → omit from create (not a blocker).

**0.e Auto Gold PAD linkage — how it materializes** (resolves CRITICAL #3):
```
SF_DISABLE_LOG_FILE=true sf data query -q "SELECT Id, Product2Id, AttributeDefinitionId, ProductClassificationAttributeId, DefaultValue, Status FROM ProductAttributeDefinition WHERE Product2Id='01tg8000003K9crAAC' LIMIT 3"
```
Confirms that `ProductClassificationAttributeId` is populated and what format `DefaultValue` has (must be Value, not Code). **Additionally**, after Steps 4-5, a smoke test: create just 1 Pyme coverage, assign the classification via UI, and SOQL to see if PADs appear without manual creates. If they do NOT appear, schedule manual PAD creates for the 6 coverages × 8 attributes = 48 additional PADs (see Step 5.b).

**0.f Describe ProductClassification** (resolves MEDIUM #7):
```
SF_DISABLE_LOG_FILE=true sf sobject describe --sobject ProductClassification --json | jq '.fields[] | select(.name | test("Status|IsActive|Code")) | .name'
```
Adjust Step 4 according to which fields exist (`Status` vs `IsActive` vs none).

**0.g Describe AttributeCategory** (resolves MEDIUM #6):
```
SF_DISABLE_LOG_FILE=true sf sobject describe --sobject AttributeCategory --json | jq '.fields[] | .name'
```
If `Type` does not exist → omit from create in Step 1. If it exists but with different picklist values → adapt.

**0.h Describe ProductRelatedComponent** (resolves LOW #16):
```
SF_DISABLE_LOG_FILE=true sf sobject describe --sobject ProductRelatedComponent --json | jq '.fields[] | select(.name | test("ParentProductRole|ChildProductRole|Sequence")) | {name, nillable, picklistValues: .picklistValues}'
```
Determine whether `ParentProductRole`/`ChildProductRole` are `nillable`; if not, set them explicitly in Step 9.

**0.i Existence of InsuranceDefaultPricingProcedure** (LOW #13):
```
SF_DISABLE_LOG_FILE=true sf data query -q "SELECT ApiName, UsageType FROM ExpressionSet WHERE UsageType='DefaultPricing'"
```

**0.j Demo user locale** (LOW #14):
```
SF_DISABLE_LOG_FILE=true sf data query -q "SELECT Id, Username, LocaleSidKey, LanguageLocaleKey FROM User WHERE Username='<demo user>'"
```
If `en_US`, schedule locale change to `es_CO` before the presentation.

### Step 1 — AttributeCategory (3 records, 5 min)

With the result from 0.g:

```
# If Type exists:
sf data create record -s AttributeCategory -v "Name='Términos Pyme' Code=terminosPyme Type='Product Attribute'"
# If it doesn't exist:
sf data create record -s AttributeCategory -v "Name='Términos Pyme' Code=terminosPyme"
```
Repeat for "Cobertura Base" (`coberturaBase`) and "Cobertura Adicional" (`coberturaAdicional`).

### Step 2 — AttributePicklist + AttributePicklistValue (8 + ~40 values, 45 min — was 30)

`sf data import tree --plan attribute-picklists-plan.json`. Example SumaAseguradaPyme:

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

**RangoEmpleados** (v2 fix: `DataType=Text`, not `Number`):
```json
{"Name":"RangoEmpleados","DataType":"Text","Status":"Active",
 "AttributePicklistValues":{"records":[
  {"Name":"Once_Cincuenta","Code":"Once_Cincuenta","Value":"11-50 empleados","DisplayValue":"11-50 empleados","Status":"Active","IsDefault":true}
]}}
```

**SustanciasProhibidasPyme** — the picklist is plain Text; multi-select is declared on the `AttributeDefinition` (Step 3), not on the picklist.

Buffer +15 min vs v1 to resolve `referenceId` and sObject shape errors on the first pass.

### Step 3 — AttributeDefinition (8 records, 15 min)

Example:
```
sf data create record -s AttributeDefinition -v "Name='Suma Asegurada' Code=sumaAsegurada Label='Suma Asegurada' DeveloperName=SumaAsegurada DataType=Picklist IsActive=true PicklistId=<lookup SumaAseguradaPyme>"
```

v2 fix — Sustancias Prohibidas:
```
sf data create record -s AttributeDefinition -v "Name='Sustancias Prohibidas' Code=sustanciasProhibidas Label='Sustancias Prohibidas' DeveloperName=SustanciasProhibidas DataType=Multipicklist IsActive=true PicklistId=<lookup SustanciasProhibidasPyme>"
```

### Step 4 — ProductClassification (2 records, 5 min)

With the result from 0.f. If `Status` exists:
```
sf data create record -s ProductClassification -v "Name='Cobertura Pyme' Code=coberturaPyme Status=Active"
```
If only `IsActive`: `IsActive=true`. If neither: omit the flag.

### Step 5 — ProductClassificationAttr and PADs (20-40 min per Step 0.e)

**5.a Assign in UI**: Product Catalog Management → Cobertura Pyme → Attributes → Assign by Category. Select the 3 AttributeCategories. Generates 8 `ProductClassificationAttr`.

If Assign by Category is not available (critique LOW #12), individual Assign → 8 clicks. Log real time; if it exceeds 20 min, cut 2 attributes from scope (move Sustancias and Deducible Mínimo to "nice-to-have").

**5.b PAD auto vs manual**: after Step 6 (create coverages), verify with SOQL:
```
SF_DISABLE_LOG_FILE=true sf data query -q "SELECT COUNT(Id) FROM ProductAttributeDefinition WHERE Product2Id='<Id rcExtracontractual>'"
```
If it returns 8 → auto-generated, continue. If it returns 0 → **create 48 PADs manually** via `sf data import tree` (adds +30 min to the time-box, triggers the §6 cut plan). PAD template:
```
sf data create record -s ProductAttributeDefinition -v "Product2Id=<lookup> AttributeDefinitionId=<lookup> ProductClassificationAttributeId=<lookup> DefaultValue=100000000 Status=Active"
```
`DefaultValue` = **the picklist Value**, not the Code (fix critique MEDIUM #9).

### Step 6 — Product2 Simple coverages (6, 15 min)

With the result from 0.b. Branch B (recommended default):
```
sf data create record -s Product2 -v "Name='Responsabilidad Civil Extracontractual' ProductCode=rcExtracontractual ProductClass=Simple IsActive=true RecordTypeId=<lookup Commercial> StockKeepingUnit='Responsabilidad Civil Extracontractual' Description='Ampara la responsabilidad civil frente a terceros' SellOnlyWithOtherProducts=true"
```

**v2 note:** `Type` **NOT set** (Auto Gold coverages have `Type=null`). `Family` **NOT set**. `BasedOnId` **NOT set** in Branch B (linkage via ProductClassificationAttr + PAD).

If Step 0.b proves Branch A (`BasedOnId` populated on Gold children): add `BasedOnId=<lookup coberturaPyme>`.

Only add `External_ID__c=product.pyme.cov.01` if Step 0.d confirmed existence.

### Step 7 — Product2 root Bundle "Plan Empresarial" (1, 5 min)

```
sf data create record -s Product2 -v "Name='Plan Empresarial' ProductCode=segPymeEmpresarial Type=Bundle ProductClass=Bundle Family=Miscellaneous IsActive=true ConfigureDuringSale=Allowed RecordTypeId=<lookup Commercial> StockKeepingUnit='Plan Empresarial' Description='Bundle raíz del Seguro Pyme Integral - Plan Empresarial'"
```

### Step 8 — ProductComponentGroup (2, 5 min)

v2 fix — `Sequence=null` (following Auto Gold Coverage group):
```
sf data create record -s ProductComponentGroup -v "Name='Coberturas' Code='Coberturas Pyme Empresarial' ParentProductId=<lookup segPymeEmpresarial>"
sf data create record -s ProductComponentGroup -v "Name='Establecimiento' Code='Establecimiento Pyme Empresarial' ParentProductId=<lookup segPymeEmpresarial>"
```

### Step 9 — ProductRelatedComponent (7, 20 min)

v2 fix — `Sequence` not set. `ParentProductRole` and `ChildProductRole` per Step 0.h.

```
sf data create record -s ProductRelatedComponent -v "ParentProductId=<lookup segPymeEmpresarial> ChildProductId=<lookup rcExtracontractual> ProductComponentGroupId=<lookup Coberturas> ProductRelationshipTypeId=<lookup Bundle to Bundle Component Relationship> Quantity=1 IsQuantityEditable=false IsDefaultComponent=true IsComponentRequired=false DoesBundlePriceIncludeChild=true QuantityScaleMethod=Proportional"
```

If 0.h reveals that the role fields are not `nillable`, add:
```
ParentProductRole=Bundle ChildProductRole=BundleComponent
```
(or `ChildProductRole=ClassificationComponent` on the classification PRC).

Classification PRC:
```
sf data create record -s ProductRelatedComponent -v "ParentProductId=<lookup segPymeEmpresarial> ChildProductClassificationId=<lookup establecimientoComercial> ProductComponentGroupId=<lookup Establecimiento> ProductRelationshipTypeId=<lookup Bundle to Product Classification Component Relationship> Quantity=1"
```

### Step 10 — ProductSellingModelOption (7, 10 min)

```
sf data create record -s ProductSellingModelOption -v "Product2Id=<lookup segPymeEmpresarial> ProductSellingModelId=<lookup OneTime> IsDefault=true"
```
Repeat for the 6 coverages.

### Step 11 — PricebookEntry (7, 10 min)

```
sf data create record -s PricebookEntry -v "Product2Id=<lookup segPymeEmpresarial> Pricebook2Id=<lookup Standard> UnitPrice=2400000 IsActive=true UseStandardPrice=false"
```

### Step 12 — ProductCategory + ProductCategoryProduct (2, 5 min)

```
sf data create record -s ProductCategory -v "Name='Seguros Pyme' Code=pymeIntegral CatalogId=<lookup Insurance Catalog>"
sf data create record -s ProductCategoryProduct -v "ProductId=<lookup segPymeEmpresarial> ProductCategoryId=<lookup Seguros Pyme>"
```

### Step 13 — Verification (10 min)

```
SF_DISABLE_LOG_FILE=true sf data query -q "SELECT Id, Name, ProductClass, Type, (SELECT ChildProduct.Name, IsDefaultComponent FROM ProductRelatedComponents) FROM Product2 WHERE ProductCode='segPymeEmpresarial'"
SF_DISABLE_LOG_FILE=true sf data query -q "SELECT COUNT(Id) FROM ProductAttributeDefinition WHERE Product2Id IN (SELECT Id FROM Product2 WHERE ProductCode LIKE 'rc%' OR ProductCode LIKE 'incendio%' OR ProductCode='equipoElectronico' OR ProductCode='roboAsalto' OR ProductCode='roturaMaquinaria' OR ProductCode='sustraccionDinero')"
```
Expect 48 PADs (6 coverages × 8 attributes). If different, investigate.

**Realistic total records: ~90-140** depending on Step 5.b. **Revised time: 2:55-3:40.**

---

## 4. Rules and pricing — minimum viable

### Pricing

**Do NOT build a custom ExpressionSet + CalculationMatrix.** Rationale:

- Auto Gold ExpressionSet V1 is inactive — cloning and activating is error-prone within the time-box.
- Official docs confirm that a single `PricebookEntry.UnitPrice` is enough for a single-root-product demo; `InsuranceDefaultPricingProcedure` reads `List Price` automatically.
- The "Insurance on Core = declarative product config" story holds up with bundle + coverages + attributes + defaults + selling model + pricebook.

**MVP**: 7 `PricebookEntry`. If more than 30 min are left at the end AND Step 0.i confirmed the existence of `InsuranceDefaultPricingProcedure`, assign it to a new `ProcedurePlanDefinition` (`ProcessType=Insurance`, `ContextDefinition=InsuranceContext`). If Step 0.i does not find it, mention in the presentation as "next step post-MVP".

### Rules

**Do NOT build Product Configuration Rules or Constraint Rules.** Rationale:

- Auto Gold has zero `ProductQualification`.
- CRE is not available in the org.
- Product Configuration Rules require Rule Library + additional perm sets — risky.

**Rules MVP**: `AttributePicklistValue.IsDefault=true` + `ProductAttributeDefinition.DefaultValue` (using **the picklist Value**, not the Code — fix critique MEDIUM #9). Differentiation per plan via `IsDefaultComponent` on the PRC + `OverriddenProductAttributeDefinitionId` for different DefaultValue per bundle.

If the client asks "exclusions by economic activity?" — show the Rules tab of Product Modeler and explain that Attribute Rules (`Hide Attribute` when `actividadEconomica=Manufactura`) is 1 additional record that can be added later.

---

## 5. Runtime plug-in

### ContextDefinition

Reuse `InsuranceContext` — the same one Auto Gold uses. No v2 changes.

### OmniScript + LWC

Reuse `Insurance_CreateQuoteDCT_English_2`. Embeds the `industries_insurance_foundation:prodCfg` LWC. Wire: `contextId=%ContextId%`, `ratingInputs={"productCode":"segPymeEmpresarial","attributes":{...}}`, `ratingOptions={"pricingProcedure":"InsuranceDefaultPricingProcedure"}` (or empty if Step 0.i confirmed its absence), `transactionType="New Business"`.

**Locale note (critique LOW #14):** if the demo user is `en_US`, standard labels ("Product Code", "Unit Price") appear in English. Coordinate a change to `es_CO` with the org admin before the presentation (Step 0.j detects it).

### FlexCard / Lightning page

Reuse the `CompRaterResults` FlexCard. No new Lightning page. Demo from Insurance Console → New Quote → picker "Plan Empresarial".

### Flows

Reuse `FINS_Issue_Insurance_Policy`. Do not modify.

---

## 6. Effort breakdown vs budget (revised to 5h)

Critique LOW #12 flagged that 4h was optimistic. Honest estimate:

| # | Step | Est. | Cumulative |
|---|---|---|---|
| 0 | Verifications (10 describes/queries + analysis) | 20 min | 0:20 |
| 1 | AttributeCategory (3) | 5 min | 0:25 |
| 2 | AttributePicklist + Values (8+~40) via `sf data import tree` | 45 min | 1:10 |
| 3 | AttributeDefinition (8) | 15 min | 1:25 |
| 4 | ProductClassification (2) | 5 min | 1:30 |
| 5 | ProductClassificationAttr (8, UI) + PAD auto smoke test | 20 min | 1:50 |
| 5b | Manual PADs (48) — only if Step 5 smoke test fails | +30 min | (contingent) |
| 6 | Product2 Simple coverages (6) | 15 min | 2:05 |
| 7 | Root Product2 Bundle | 5 min | 2:10 |
| 8 | ProductComponentGroup (2) | 5 min | 2:15 |
| 9 | ProductRelatedComponent (7) | 20 min | 2:35 |
| 10 | ProductSellingModelOption (7) | 10 min | 2:45 |
| 11 | PricebookEntry (7) | 10 min | 2:55 |
| 12 | ProductCategory + link | 5 min | 3:00 |
| 13 | Verification Product Modeler + SOQL counts | 10 min | 3:10 |
| 14 | E2E smoke test in Insurance_CreateQuoteDCT | 25 min | 3:35 |
| 15 | Buffer for FK errors / describe mismatches / locale switch | 55 min | 4:30 |
| 16 | Document walkthrough for the presentation | 30 min | 5:00 |

**Realistic total: 5:00 with 55 min buffer.** If Step 5.b triggers manual PADs, buffer is consumed + 30 min → cut per the plan below.

### What to cut if we run tight

1. **First**: skip Step 12 (ProductCategory) — bundle queryable without a category. **-5 min.**
2. **Second**: reduce to 4 coverages (skip Rotura, Sustracción). **-20 min and -6 PADs.**
3. **Third**: skip Sustancias Prohibidas + Deducible Mínimo Evento (2 "extra" attributes). **-2 AttributeDefinitions, -12 PADs if manual, -5 min.**
4. **Fourth**: skip per-plan defaults (`OverrideContextId`) — use global defaults. **-15 min.**
5. **Do NOT cut**: PSMO, PricebookEntry, ProductClassification + core PADs (Suma, Deducible, Actividad, Rango Empleados).

Minimum floor: 3 coverages (RC, Incendio, Robo) + 1 plan + 4 attributes → the story holds.

---

## 7. Field-name and value cheat-sheet

v2 changes marked with **[v2]**.

| SObject | Field | Type | Pyme example | Notes |
|---|---|---|---|---|
| Product2 (root) | Name | String | Plan Empresarial | User-facing |
| Product2 (root) | ProductCode | String | segPymeEmpresarial | camelCase |
| Product2 (root) | Type | Picklist | Bundle | [v2] Valid for roots; **do NOT set** on Simple coverages |
| Product2 (root) | ProductClass | Picklist | Bundle | Picklist, NOT lookup |
| Product2 (root) | Family | Picklist | Miscellaneous | [v2] Only on root; **null** on coverages |
| Product2 (root) | IsActive | Boolean | true | |
| Product2 (root) | ConfigureDuringSale | Picklist | Allowed | |
| Product2 (root) | External_ID__c | String | product.pyme.001 | Custom — Step 0.d confirms existence |
| Product2 (root) | StockKeepingUnit | String | Plan Empresarial | |
| Product2 (root) | BasedOnId | Lookup | null (root bundle) | [v2] Peer pattern |
| Product2 (coverage) | Type | — | **omit** | [v2] Auto Gold coverages `Type=null` |
| Product2 (coverage) | Family | — | **omit** | [v2] Auto Gold coverages `Family=null` |
| Product2 (coverage) | ProductClass | Picklist | Simple | |
| Product2 (coverage) | BasedOnId | Lookup | [v2] **null by default** (Branch B) or classification Id (Branch A) | Step 0.b decides |
| Product2 (coverage) | SellOnlyWithOtherProducts | Boolean | true | |
| Product2 | RecordTypeId | Lookup | Commercial | Step 0.c verifies |
| ProductRelationshipType | Name | String | Bundle to Bundle Component Relationship / Bundle to Product Classification Component Relationship | OOTB |
| ProductComponentGroup | Name | String | Coberturas | |
| ProductComponentGroup | Code | String | Coberturas Pyme Empresarial | Silver-style |
| ProductComponentGroup | Sequence | Number | [v2] **null** | Gold pattern (was 1/2 in v1) |
| ProductComponentGroup | ParentProductId | Lookup | Id Plan Empresarial | |
| ProductRelatedComponent | Quantity | Number | 1 | |
| ProductRelatedComponent | IsQuantityEditable | Boolean | false | |
| ProductRelatedComponent | IsDefaultComponent | Boolean | true (Empresarial) / false (Esencial) | Differentiator |
| ProductRelatedComponent | IsComponentRequired | Boolean | false | |
| ProductRelatedComponent | DoesBundlePriceIncludeChild | Boolean | true | |
| ProductRelatedComponent | QuantityScaleMethod | Picklist | Proportional | |
| ProductRelatedComponent | Sequence | Number | [v2] **null** | Gold+Silver both null |
| ProductRelatedComponent | ParentProductRole | Picklist | [v2] Bundle (if Step 0.h non-nillable, else omit) | |
| ProductRelatedComponent | ChildProductRole | Picklist | [v2] BundleComponent or ClassificationComponent (per Step 0.h) | |
| ProductRelatedComponent | ChildProductId / ChildProductClassificationId | Lookup | Mutex | |
| ProductClassification | Name | String | Cobertura Pyme | |
| ProductClassification | Code | String | coberturaPyme | |
| ProductClassification | Status / IsActive | [v2] Per Step 0.f | Active / true | Verify which exists |
| AttributeCategory | Name | String | Términos Pyme | With accent |
| AttributeCategory | Code | String | terminosPyme | Without accent |
| AttributeCategory | Type | [v2] Per Step 0.g | Product Attribute (if exists) | |
| AttributeDefinition | Name/Label | String | Suma Asegurada | PascalCase with spaces |
| AttributeDefinition | Code | String | sumaAsegurada | camelCase |
| AttributeDefinition | DeveloperName | String | SumaAsegurada | No spaces, no accents |
| AttributeDefinition | DataType | Picklist | Picklist / **Multipicklist** (Sustancias) | [v2] Multipicklist for Sustancias |
| AttributeDefinition | PicklistId | Lookup | Id AttributePicklist | Required if DataType=Picklist/Multipicklist |
| AttributeDefinition | IsActive | Boolean | true | |
| AttributePicklist | Name | String | SumaAseguradaPyme | No spaces |
| AttributePicklist | DataType | Picklist | Currency / **Text** (Rangos) / Percentage | [v2] Rangos are Text |
| AttributePicklistValue | Code | String | Cien_MM | Token |
| AttributePicklistValue | Value | String | 100000000 | [v2] Rated value — what the rating engine consumes |
| AttributePicklistValue | DisplayValue | String | COP 100,000,000 | User-facing |
| AttributePicklistValue | IsDefault | Boolean | true (one per picklist) | |
| ProductAttributeDefinition | Product2Id | Lookup | Id coverage | |
| ProductAttributeDefinition | AttributeDefinitionId | Lookup | Id AttrDef | |
| ProductAttributeDefinition | ProductClassificationAttributeId | Lookup | Id PCA | Auto Gold always has it |
| ProductAttributeDefinition | DefaultValue | String | [v2] **100000000** (the Value, NOT Cien_MM/Code) | Fix critique MEDIUM #9 |
| ProductAttributeDefinition | Status | Picklist | Active | Default is Draft — set explicit |
| ProductSellingModel | SellingModelType | Picklist | OneTime | Reuse |
| ProductSellingModelOption | Product2Id | Lookup | Id Product2 | [v2] NOT `ProductId` |
| ProductSellingModelOption | ProductSellingModelId | Lookup | Id OneTime | |
| ProductSellingModelOption | IsDefault | Boolean | true | |
| PricebookEntry | Product2Id, Pricebook2Id, UnitPrice, IsActive, UseStandardPrice | — | — | UseStandardPrice=false when UnitPrice is custom |
| ProductCategory | Name, Code, CatalogId | — | Seguros Pyme, pymeIntegral, <lookup> | NOT `ProductCatalogId` |
| ProductCategoryProduct | ProductId, ProductCategoryId | — | Join table | NOT `CategoryProductAssignment` |
| ContextDefinition | DeveloperName | String | InsuranceContext | Reuse |

---

## 8. Risks and open questions

All critique items reflected. Each with its mitigation in Step 0 or in the flow.

1. **`Product2.Type` on coverages (CRITICAL critique #1)** — Auto Gold has `Type=null` on Simple children. v2 spec does NOT set `Type` on the 6 Pyme coverages; only `ProductClass=Simple`. Step 0.b verifies beforehand.

2. **`Product2.BasedOnId` on coverages (CRITICAL critique #2)** — Inspection does not confirm that Auto Gold sets it on children. v2 spec has **Branch B by default** (BasedOnId=null) and Branch A conditional on Step 0.b. Linkage via `ProductClassificationAttr` is the mechanism confirmed by inspection.

3. **PAD auto-generation (CRITICAL critique #3)** — v2 spec does not assume auto-gen. Step 5.b does a smoke test after creating the first coverage; if it returns 0 PADs, the cut plan and manual creates are scheduled (+30 min to time-box with buffer from §6).

4. **Rango* DataType (CRITICAL critique #4)** — Fix applied: `RangoEmpleados` and `RangoMetrosCuadrados` are now `AttributePicklist.DataType=Text`, `AttributePicklistValue.Value` is the readable string ("11-50 empleados"). Rating receives the string; if it later needs a numeric value, add a separate `numeroEmpleadosExacto` AttrDef.

5. **Sustancias Prohibidas (MEDIUM critique #5)** — Fix applied: `AttributeDefinition.DataType=Multipicklist`. Multiple substances possible.

6. **`AttributeCategory.Type` (MEDIUM critique #6)** — Step 0.g describes. If the field or picklist value does not exist, omit from create.

7. **`ProductClassification.Status/Code` (MEDIUM critique #7)** — Step 0.f describes. Spec adapts to `Status` / `IsActive` / omit.

8. **`Sequence` on PCG and PRC (MEDIUM critique #8)** — Fix applied: `Sequence=null` on all PRCs and on PCGs (Gold pattern). Cheat-sheet updated.

9. **`ProductAttributeDefinition.DefaultValue` (MEDIUM critique #9)** — Fix applied: use `AttributePicklistValue.Value`, NOT `.Code`. Example: `DefaultValue='100000000'` (not `'Cien_MM'`). Cheat-sheet §7 and §2.5 corrected.

10. **PSMO field naming (MEDIUM critique #10)** — Confirmed: `Product2Id`, `ProductSellingModelId`, `IsDefault`. Cheat-sheet flags this explicitly.

11. **English leaks (LOW critique #11)** — DeveloperName without accents ('SumaAsegurada') is intentional per Salesforce convention. User locale in Step 0.j.

12. **Optimistic time-box (LOW critique #12)** — Revised to 5h in §6, with 55 min buffer and Step 5.b contingent.

13. **`InsuranceDefaultPricingProcedure` (LOW critique #13)** — Step 0.i verifies before recommending; if not present, PricebookEntry-only is sufficient.

14. **Locale (LOW critique #14)** — Step 0.j reads the demo user locale; change to `es_CO` scheduled if it's `en_US`.

15. **PRC roles (LOW critique #16)** — Step 0.h describes whether `ParentProductRole`/`ChildProductRole` are nillable; spec sets them explicitly if not.

16. **Insurance Coexistence (LOW critique #17)** — Step 0.c lists all Product2 RTs; managed namespaces will show up with prefixes. If there's a collision with the managed package, adjust RT live.

17. **Sandbox refresh timing** — All lookups are by Name/Code/DeveloperName, resilient to refresh. Coordinate with the industry SE/team so no refresh happens between 2026-07-07 and 2026-07-08 AM.

18. **`sf` CLI**: `SF_DISABLE_LOG_FILE=true` as prefix or exported at the start of the session.
---

## Appendix — Step 0 executed (2026-07-07 10:52)

### Resolved references (by Name, never hardcoded)
- **ProductRelationshipType** "Bundle to Bundle Component Relationship" → resolved dynamically by Name
- **ProductRelationshipType** "Bundle to Product Classification Component Relationship" → dynamic resolve
- **ProductSellingModel** "One Time" (SellingModelType=OneTime, Status=Active) → dynamic resolve
- **Standard Price Book** (IsStandard=true)
- **ProductCatalog** "Insurance Catalog"
- **ProductClassification** "Coverage" (Code=coverage, Status=Active) — this is the one Auto Gold uses in `BasedOnId` of its coverages

### Auto Gold model — VALIDATIONS (with live SOQL)

| Field | Root "Auto Gold" | Child coverages |
|---|---|---|
| Type | Bundle | **null** |
| ProductClass | Bundle | Simple |
| Family | Miscellaneous | null |
| BasedOnId | null | **Id of ProductClassification "Coverage"** — BRANCH A confirmed |
| RecordType.DeveloperName | **Commercial** | **Coverage** (NOT Commercial!) |
| ConfigureDuringSale | Allowed | Allowed |

**Critical change vs v2 spec:** coverages must use **RecordType `Coverage`** (dedicated), not `Commercial`. The 12 available RecordTypes include Coverage, Commercial, InsuredItem, InsuredParty, Product, etc.

**Auto Gold PAD example:** `Name="Bodily Injury Per Accident Limit"`, `DefaultValue="1000"` (matches AttributePicklistValue.Value), `Status=Active`, `IsRequired=false`, `Sequence=null`. **PAD.Name = AttributeDefinition.Name** (same string).

**Auto Gold Coverage ProductClassificationAttr:** rows have `Status=Inactive` (side effect); `Name` = AttributeDefinition.Name (e.g., "Bodily Injury Per Accident Limit"). For Pyme, create with `Status=Active`.

### Corrections to the v2 spec

1. **Step 6 (Product2 coverages):**
   - `RecordType.DeveloperName = 'Coverage'` (not `Commercial`)
   - `BasedOnId = <lookup ProductClassification 'Cobertura Pyme'>` — **Branch A confirmed** (Auto Gold children DO have BasedOnId populated)
   - **Drop `SellOnlyWithOtherProducts=true`** — the field DOES NOT EXIST on Product2 in this org
   - `Type` is not set (validated — Auto Gold coverages have `Type=null`)

2. **Step 9 (ProductRelatedComponent):**
   - `ParentProductRole='Bundle'` and `ChildProductRole` **ARE REQUIRED** (`nillable=false`). Set explicitly.
   - Product2 children: `ChildProductRole='BundleComponent'`
   - Classification PRC: `ChildProductRole='ClassificationComponent'`
   - Validated picklist values: `ParentProductRole` accepts [Bundle, Set, AddOn, ProductRequest]; `ChildProductRole` accepts [BundleComponent, SetComponent, AddOnComponent, ClassificationComponent, ProductRequestComponent]

3. **Step 5 (ProductClassificationAttr):**
   - `Name` is required — use the same name as the `AttributeDefinition` (e.g., `Name='Suma Asegurada'`)
   - Create with `Status='Active'` (Auto Gold has Inactive as a side-effect, don't replicate)

4. **Step 4 (ProductClassification):**
   - `Code` is required (not nillable). `Status='Active'`. Picklist values: [Draft, Active, Inactive].

5. **Step 1 (AttributeCategory):**
   - `Type` field **does not exist** on AttributeCategory. Confirmed skip. Createable fields: Name, Code, Description, CurrencyIsoCode, External_Id__c.

6. **Step 8 (ProductComponentGroup):**
   - `Code` is **globally unique** — use "Coberturas Pyme Empresarial" and "Establecimiento Pyme Empresarial" (Silver-style with plan suffix)
   - `Sequence=null` OK (Auto Gold Coverage group has Sequence=null; Auto group Sequence=1 — not consistent, leave null)

7. **Pricing (Step 11):**
   - `InsuranceDefaultPricingProcedure` **does not exist** in the org — only group-specific ones (Group_Insurance_Default_Pricing_Procedure, GroupDental, GroupMedical, GroupVision). **Confirmed MVP = PricebookEntry only.**

8. **Locale — NEW STEP:**
   - the technical backup locale = `en_US`, currency = `USD`. **Before the presentation**, change to `es_CO` / `COP` (or accept verbal contextualization). Current decision: keep the demo in `en_US` to avoid breaking other blocks with currency switching; use Description/Name in Spanish, and accept Salesforce standard labels in English (Product Code, Unit Price, etc.). Explain in the presentation as "the end user would have locale es_CO".

### Product2 Type picklist verified
Valid values: **[Base, Bundle, Set]**. `Simple` is NOT a valid Type (though it is a valid ProductClass). Confirms that Simple coverages **do NOT set Type**.

### Available Product2 custom fields
- `External_ID__c` (string) — use for traceability
- `Product_Catalog__c` (picklist [Basic, Premium]) — **omit** (values don't apply to Pyme)
- `analyticsdemo_batch_id__c` (irrelevant)

### Time-box change
Step 0 took 20 min as estimated. No major surprises — v2 spec is viable with the 8 attached fixes. Time-box stays at 5h.

