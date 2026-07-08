# Digital Insurance PCM + RCA — Technical gotchas

A reference for the next SE/dev who has to build a Digital Insurance demo from scratch. Each gotcha covers: what it is, symptom, cause, fix.

## 1. sObject names — common traps

- **`ClaimCovPaymentAdjustment`** — NOT `ClaimCoveragePaymentAdjustment`. Yes, it's the symmetric sibling of `ClaimCovReserveAdjustment`.
- **`InsurancePolicyVersion` does not exist** in Digital Insurance PCM (at least in v67.0). Policy versioning is data-driven via the fields `PriorPolicyId`, `SourcePolicyId`, `ChangeType`, `ChangeSubtype` on Product2 itself.
- **`ClaimAssessment`, `ClaimReserve`, `ClaimPayment`, `ClaimAdjuster` DO NOT EXIST** — these are names invented by narrative. The real ones are:
  - Reserve: `ClaimCoverage` + `ClaimCoverageReserveDetail` + `ClaimCovReserveAdjustment`
  - Payment: `ClaimPaymentSummary` (header) + `ClaimCoveragePaymentDetail` (lines) + `ClaimCovPaymentAdjustment`
  - Adjuster: a person/role via `Claim.OwnerId` + Omni-Channel routing, NOT an sObject

## 2. Fields that claim to be writable but aren't (system-derived)

- **`Product2.ProductClass`** (nillable=false but createable=false, updateable=false, defaultedOnCreate=true) — auto-derived from `RecordType` (Coverage → Simple) or `Type` (Bundle → Bundle). Omit from payload.
- **`ProductRelatedComponent.ParentProductRole` and `ChildProductRole`** — nillable=false but auto-derived from `ProductRelationshipTypeId`. Omit from payload.
- **`Quote.AccountId` and `Quote.OpportunityId`** — cannot be changed after creation. Blocks updates via API (requires the "Quotes Without Opportunity" setting or similar).

## 3. Non-obvious uniqueness constraints

- **`AttributePicklistValue.Code` is GLOBALLY UNIQUE**, not scoped to the parent Picklist. A collision on "Un_MM" across different picklists breaks the INSERT. Suffix by picklist (e.g., `Un_MM_DME`).
- **`ProductComponentGroup.Code`** globally unique — same story, suffix with the plan name.
- **`AttributePicklistValue.Name`** is NOT unique (nillable=false but non-unique).

## 4. Objects with hidden validation rules

- **`ClaimItem`** requires `FaultDate` — a custom validation rule. The error "Complete this field" doesn't tell you which one. If insert fails, add `FaultDate=YYYY-MM-DDTHH:MM:SSZ`.
- **`ClaimCoverage`** requires `ClaimItemId` — validation rule "Enter a claim item". Without a link to a specific ClaimItem, it won't create. Fix: create the ClaimItems first, then create the ClaimCoverage with `ClaimItemId` pointing to one of them.
- **`Product2.SellOnlyWithOtherProducts` DOES NOT EXIST** in some Digital Insurance orgs — I assumed it did, it doesn't. Omit from payload; use `Type=null` + a Bundle relationship for the same semantics.

## 5. AttributeDefinition — available DataTypes

Valid values in release 260: `[Checkbox, Date, Datetime, Number, Text, Currency, Percent, Picklist]`. **There is NO `Multipicklist`** — to model "pick several", use a single Picklist with a dominant choice, or multiple Boolean attributes (clunky).

## 6. PADs are NOT auto-generated

Setting `Product2.BasedOnId = <ProductClassificationId>` does NOT trigger automatic creation of `ProductAttributeDefinition` records from that classification's `ProductClassificationAttr` records. You have to create them manually:
- 6 coverages × 8 attrs = 48 PADs
- Each one: Name, Product2Id, AttributeDefinitionId, ProductClassificationAttributeId, DefaultValue, Status=Active

Budget +30 min if this is your first time.

## 7. InsuranceClause — the field is Type, NOT ClauseType

When creating an InsuranceClause via API, the picklist field is `Type` with values `[Clause, Exclusion]`. Many docs say "ClauseType" — that's wrong. Verify with `sf sobject describe --sobject InsuranceClause`.

## 8. InsuranceProductClause.ProductPath

Required field, format = Product2 Id (not a slash-path like "/segPymeEmpresarial"). Set it to the Id of the root bundle.

## 9. InsProductClauseVariableMap.Attribute

Format: `{ProductCode}.Attribute.{DeveloperName}`
Example: `segPymeEmpresarial.Attribute.Porcentaje_Coaseguro`
The error Salesforce throws if you get it wrong is literally: "Use this format for the attribute: {ProductCode|"Quote"}.{"Attribute"|"Field"}.{DeveloperName|ApiName}".

## 10. Auto Gold conventions (verified)

- Root bundle Product2: Type=Bundle, ProductClass=Bundle (auto-derived), Family=Miscellaneous, RecordType=Commercial, ConfigureDuringSale=Allowed, BasedOnId=null
- Child coverages: Type=null (NOT 'Simple'!), ProductClass=Simple (auto), Family=null, RecordType=Coverage (NOT Commercial), BasedOnId=<Id of the "Coverage" ProductClassification>
- ProductAttributeDefinition.DefaultValue = AttributePicklistValue.Value (e.g., "1000"), NOT the .Code (e.g., "Cien_MM")
- ProductRelatedComponent.Sequence=null on all PRCs

## 11. RCA Quote — TransactionType is a critical field

`Quote.TransactionType` is a **picklist** with 2 active values: `AutoTransactionType` and `GroupInsuranceTransactionType`. Without one of these populated, the Product Configuration LWC throws `Cannot read properties null (reading 'groups')`. For Pyme (Commercial), use `AutoTransactionType` as a workaround — there is no "PymeTransactionType" value in the picklist.

## 12. Opportunity — RecordType 'SimpleOpportunity' for RCA

When creating an Opportunity that will hold an RCA Quote, the RecordType.DeveloperName must be `SimpleOpportunity` — this is the one Rachel Adams uses. Other RecordTypes break the Browse Catalogs → Configure LWC flow.

## 13. Pricebook2Id on Opportunity

Official docs say Opportunity needs Pricebook2Id populated for the LWC to work. In practice, Rachel Adams' Opp has Pricebook2Id=NULL and it works (the Quote manages its own Pricebook). But explicitly setting the Standard Pricebook on the Opp doesn't hurt and is a defensive move.
