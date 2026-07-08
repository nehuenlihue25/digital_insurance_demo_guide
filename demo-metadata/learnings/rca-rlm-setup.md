# Revenue Cloud Advanced (RCA) — Setup notes for Digital Insurance orgs

## Context

This document covers the relationship between Digital Insurance (Insurance on Core) and Revenue Cloud Advanced (RCA), and how the Product Configuration LWC + Quote flow work when both coexist.

## Critical PSLs (all Active in Q-Branch demo orgs)

### Umbrella
- `RevenueLifecycleManagementUserPsl` — Revenue Cloud User (35 seats)
- `IndustriesConfiguratorPsl` — Product Configuration User (51 seats)
- `DynamicRevenueOrchestratorUserPsl` — Fulfillment/DRO (40 seats)

### Pricing engine
- `CorePricingDesignTime` — Salesforce Pricing Design Time (547 seats)
- `CorePricingRunTime` — Salesforce Pricing Run Time (547 seats)
- `RevLifecycleMgmtBillingPsl` — Billing

### Digital Insurance specific
- `DigitalInsuranceClaimManagementAdmin` / User
- `DigitalInsurancePolicyAdminUserPsl` / CC / PC
- `ClaimManagementFoundationPsl`
- `ClaimMgmtPsl`
- Plus ~15 more Digital Insurance specific ones

### Permission Sets (in addition to the PSLs)
- `AdvancedConfiguratorDesigner` (Product Configuration Constraints Designer) — CORE of RCA for the Constraint Rules Engine
- `ProductConfigurationRulesDesigner` — the legacy Rules Designer (BRE)
- `IndustriesConfiguratorPlatformApi` — Product Configurator
- `ProductCatalogManagementViewer`
- `ProductDiscoveryUser`, `ProductDiscoveryAdmin`
- `ContextServiceRuntimePsl` (PS)
- `StageManagementUser`
- `BRERuntime` — Rule Engine Runtime
- `OmniStudioExecution` / `OmniStudioUser`
- 3-4 more object-specific ones

**IMPORTANT**: if a System Admin user can't see an RCA sObject (`SalesTransactionType`, etc.) when running `sf sobject describe`, it's NOT that the object doesn't exist — the user is missing a critical PSL/PS. Assign all the ones above and re-check.

## sObjects that EXIST but require permissions

- `SalesTransactionType` (0 records by default — you have to create at least 1)
- `SalesTransactionDefinition`, `SalesTransactionDefinitionVersion` — may not be present in "classic" RCA orgs, but they are in RCA v2/Advanced
- `ProductQuoteTemplate` — new feature, not in all orgs
- `ProcedurePlanDefinition` (7 OOTB templates)
- `ExpressionSetDefinition` (24 templates in orgs with full Insurance)

## Quote runtime — the correct flow

1. **Opportunity** with RecordType=`SimpleOpportunity`, StageName='Proposal/Quote', AccountId populated, Pricebook2Id optional (better with an explicit Standard Pricebook)
2. **OmniScript** `Insurance_CreateQuoteDCT2_English` (via Action Launcher on the Account) → creates the Quote with the correct structure
3. **Quote** inherits TransactionType (AutoTransactionType or GroupInsuranceTransactionType) — the OmniScript sets it
4. **Browse Catalogs** on the Quote → picker by catalog → category → product bundle
5. **Configure** → Product Configuration LWC (`runtime_revenue_foundation:transactionLineTable`) renders attributes by classification
6. **Update Prices** → runs the pricing procedure
7. **Save & Exit** → QLIs created with a ParentQuoteLineItemId structure (parent bundle + child coverages)
8. **Issue Policy** → wizard creates InsurancePolicy + coverages + transactions

## Error "Cannot read properties null (reading 'groups')"

Fires when the transactionLineTable LWC can't resolve the Quote "context". Common causes, ordered by likelihood:

1. **Quote.TransactionType null** — set `AutoTransactionType` or `GroupInsuranceTransactionType`
2. **Opportunity RecordType is not SimpleOpportunity** — change via update
3. **Quote was never saved** — per docs, requires at least 1 save before the LWC will work
4. **User missing PSLs/PS** — assign the 30+ listed above
5. **Quote was not created via OmniScript but manually via INSERT** — QLIs and structure are incomplete. Recreate via OmniScript.
6. **Product added via classic "Add Products" instead of Browse Catalogs** — Revenue Cloud excludes Add Products from the RCA flow

## Setup checklist for a new org

1. Enable Revenue Cloud Features (Setup > Revenue Settings)
2. Enable Salesforce Pricing (Setup > Salesforce Pricing Settings)
3. Configure Products at Runtime = ON
4. Transaction processing for quotes = ON, with a default Transaction Processing Type
5. Clone and activate a Pricing Procedure (Expression Set Templates)
6. Set PricingRecipe.DefaultPricingProcedureId
7. Run Sync Pricing Data
8. Create at least 1 SalesTransactionType linked to the Pricing Procedure
9. Configure the Quote FlexiPage with LWCs `runtime_revenue_foundation:transactionLineTable` + `transactionSummary` + `progressIndicator`
10. Assign ProductConfigurationFlow to the configurable bundle products (via ProductConfigFlowAssignment)
11. Assign ALL the PSLs and PS to the demo user
12. Verify the Quote Line Group page layout is assigned to the user's profile (Known Issue Spring '26)
