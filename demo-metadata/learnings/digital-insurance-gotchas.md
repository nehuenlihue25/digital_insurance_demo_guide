# Digital Insurance PCM + RCA — Gotchas técnicos

Documento pensado para el próximo SE/dev que tenga que armar una demo Digital Insurance de cero. Cada gotcha con: qué es, síntoma, causa, fix.

## 1. Nombres de sObjects — traps comunes

- **`ClaimCovPaymentAdjustment`** — NO `ClaimCoveragePaymentAdjustment`. Sí, hermano simétrico de `ClaimCovReserveAdjustment`.
- **`InsurancePolicyVersion` no existe** en Digital Insurance PCM (v67.0 al menos). El versioning de póliza es data-driven vía campos `PriorPolicyId`, `SourcePolicyId`, `ChangeType`, `ChangeSubtype` en Product2 mismo.
- **`ClaimAssessment`, `ClaimReserve`, `ClaimPayment`, `ClaimAdjuster` NO EXISTEN** — nombres inventados por narrativa. Los reales:
  - Reserva: `ClaimCoverage` + `ClaimCoverageReserveDetail` + `ClaimCovReserveAdjustment`
  - Pago: `ClaimPaymentSummary` (header) + `ClaimCoveragePaymentDetail` (lines) + `ClaimCovPaymentAdjustment`
  - Adjuster: es persona/rol vía `Claim.OwnerId` + Omni-Channel routing, NO un sObject

## 2. Fields que dicen ser writable pero no lo son (system-derived)

- **`Product2.ProductClass`** (nillable=false pero createable=false updateable=false defaultedOnCreate=true) — se autoderiva de `RecordType` (Coverage → Simple) o `Type` (Bundle → Bundle). Omitir del payload.
- **`ProductRelatedComponent.ParentProductRole` y `ChildProductRole`** — nillable=false pero autoderivados de `ProductRelationshipTypeId`. Omitir del payload.
- **`Quote.AccountId` y `Quote.OpportunityId`** — no se pueden cambiar después de creación. Bloquea updates via API (requiere setting "Quotes Without Opportunity" o similar).

## 3. Uniqueness constraints no obvios

- **`AttributePicklistValue.Code` es UNIQUE GLOBAL**, no scoped al Picklist parent. Colisión de "Un_MM" entre distintos picklists rompe el INSERT. Sufijar por picklist (ej. `Un_MM_DME`).
- **`ProductComponentGroup.Code`** unique global — igual, sufijar con plan.
- **`AttributePicklistValue.Name`** NO unique (nillable=false pero non-unique).

## 4. Objetos con validation rules ocultas

- **`ClaimItem`** requiere `FaultDate` — validation rule custom. Error "Complete this field" sin decir cuál. Si falla al insertar, agregar `FaultDate=YYYY-MM-DDTHH:MM:SSZ`.
- **`ClaimCoverage`** requiere `ClaimItemId` — validation rule "Enter a claim item". Sin el link a un ClaimItem específico, no se crea. Solución: crear los ClaimItems primero, luego crear la ClaimCoverage con `ClaimItemId` de uno de ellos.
- **`Product2.SellOnlyWithOtherProducts` NO existe** en algunas orgs Digital Insurance — asumía que estaba, no está. Omitir del payload; usar `Type=null` + Bundle relationship para el mismo semanticismo.

## 5. AttributeDefinition — DataTypes disponibles

Valores válidos en release 260: `[Checkbox, Date, Datetime, Number, Text, Currency, Percent, Picklist]`. **NO existe `Multipicklist`** — para modelar "elegir varias" usar Picklist single + choice dominante, o múltiples Boolean attributes (clunky).

## 6. PADs NO se autogeneran

Setear `Product2.BasedOnId = <ProductClassificationId>` NO dispara creación automática de `ProductAttributeDefinition` a partir de los `ProductClassificationAttr` de esa classification. Hay que crearlos manualmente:
- 6 coverages × 8 attrs = 48 PADs
- Cada uno: Name, Product2Id, AttributeDefinitionId, ProductClassificationAttributeId, DefaultValue, Status=Active

Presupuestar +30 min si es primera vez.

## 7. InsuranceClause — campo es Type, NO ClauseType

Al crear InsuranceClause via API, el campo picklist es `Type` con valores `[Clause, Exclusion]`. Muchos docs escriben "ClauseType" — es incorrecto. Verificar con `sf sobject describe --sobject InsuranceClause`.

## 8. InsuranceProductClause.ProductPath

Campo required, formato = Product2 Id (no path con slashes tipo "/segPymeEmpresarial"). Setear al Id del bundle root.

## 9. InsProductClauseVariableMap.Attribute

Formato: `{ProductCode}.Attribute.{DeveloperName}`
Ejemplo: `segPymeEmpresarial.Attribute.Porcentaje_Coaseguro`
El error que Salesforce da si te equivocás es literal: "Use this format for the attribute: {ProductCode|"Quote"}.{"Attribute"|"Field"}.{DeveloperName|ApiName}".

## 10. Convenciones Auto Gold (verificado)

- Root bundle Product2: Type=Bundle, ProductClass=Bundle (autoderivado), Family=Miscellaneous, RecordType=Commercial, ConfigureDuringSale=Allowed, BasedOnId=null
- Coverages hijas: Type=null (NO 'Simple'!), ProductClass=Simple (auto), Family=null, RecordType=Coverage (NO Commercial), BasedOnId=<Id del ProductClassification "Coverage">
- ProductAttributeDefinition.DefaultValue = AttributePicklistValue.Value (ej. "1000"), NO el .Code (ej. "Cien_MM")
- ProductRelatedComponent.Sequence=null en todos los PRCs

## 11. RCA Quote — TransactionType field crítico

`Quote.TransactionType` es un **picklist** con 2 valores activos: `AutoTransactionType` y `GroupInsuranceTransactionType`. Sin uno de estos poblado, el Product Configuration LWC lanza `Cannot read properties null (reading 'groups')`. Para Pyme (Commercial) usar `AutoTransactionType` como workaround — no hay valor "PymeTransactionType" en el picklist.

## 12. Opportunity — RecordType 'SimpleOpportunity' para RCA

Al crear una Opportunity que va a tener un Quote RCA, el RecordType.DeveloperName debe ser `SimpleOpportunity` — es el que Rachel Adams usa. Otros RecordTypes rompen el flujo Browse Catalogs → Configure LWC.

## 13. Pricebook2Id en Opportunity

Docs oficiales dicen que Opportunity necesita Pricebook2Id poblado para el LWC funcionar. En la práctica Rachel Adams Opp tiene Pricebook2Id=NULL y funciona (el Quote gestiona su propio Pricebook). Pero setear el Standard Pricebook explícito en la Opp no hace daño y es defensivo.
