# Revenue Cloud Advanced (RCA) — Setup notes para Digital Insurance orgs

## Contexto

Este doc documenta la relación entre Digital Insurance (Insurance on Core) y Revenue Cloud Advanced (RCA), y cómo el Product Configuration LWC + Quote flow funcionan cuando ambos coexisten.

## PSLs críticas (todas Active en Q-Branch demo orgs)

### Umbrella
- `RevenueLifecycleManagementUserPsl` — Revenue Cloud User (35 seats)
- `IndustriesConfiguratorPsl` — Product Configuration User (51 seats)
- `DynamicRevenueOrchestratorUserPsl` — Fulfillment/DRO (40 seats)

### Pricing engine
- `CorePricingDesignTime` — Salesforce Pricing Design Time (547 seats)
- `CorePricingRunTime` — Salesforce Pricing Run Time (547 seats)
- `RevLifecycleMgmtBillingPsl` — Billing

### Digital Insurance específico
- `DigitalInsuranceClaimManagementAdmin` / User
- `DigitalInsurancePolicyAdminUserPsl` / CC / PC
- `ClaimManagementFoundationPsl`
- `ClaimMgmtPsl`
- Y unas 15 más de Digital Insurance específicas

### Permission Sets (además de las PSLs)
- `AdvancedConfiguratorDesigner` (Product Configuration Constraints Designer) — CORE de RCA para Constraint Rules Engine
- `ProductConfigurationRulesDesigner` — el legacy Rules Designer (BRE)
- `IndustriesConfiguratorPlatformApi` — Product Configurator
- `ProductCatalogManagementViewer`
- `ProductDiscoveryUser`, `ProductDiscoveryAdmin`
- `ContextServiceRuntimePsl` (PS)
- `StageManagementUser`
- `BRERuntime` — Rule Engine Runtime
- `OmniStudioExecution` / `OmniStudioUser`
- 3-4 más específicas por objeto

**IMPORTANTE**: si un usuario System Admin no ve un sObject RCA (`SalesTransactionType`, etc.) al hacer `sf sobject describe`, NO es que el objeto no exista — es que le falta una PSL/PS crítica. Asignar todas las de arriba y volver a chequear.

## sObjects que EXISTEN pero requieren permisos

- `SalesTransactionType` (0 records default — hay que crear al menos 1)
- `SalesTransactionDefinition`, `SalesTransactionDefinitionVersion` — puede que no estén en orgs con RCA "classic", pero sí en RCA v2/Advanced
- `ProductQuoteTemplate` — feature nueva, no en todas las orgs
- `ProcedurePlanDefinition` (7 templates OOTB)
- `ExpressionSetDefinition` (24 templates en orgs con Insurance completo)

## Quote runtime — flow correcto

1. **Opportunity** con RecordType=`SimpleOpportunity`, StageName='Proposal/Quote', AccountId poblado, Pricebook2Id opcional (mejor con Standard Pricebook explícito)
2. **OmniScript** `Insurance_CreateQuoteDCT2_English` (via Action Launcher en Account) → crea el Quote con estructura correcta
3. **Quote** hereda TransactionType (AutoTransactionType o GroupInsuranceTransactionType) — el OmniScript lo setea
4. **Browse Catalogs** en el Quote → picker por catalog → category → product bundle
5. **Configure** → Product Configuration LWC (`runtime_revenue_foundation:transactionLineTable`) renderiza attributes por classification
6. **Update Prices** → ejecuta pricing procedure
7. **Save & Exit** → QLIs creados con ParentQuoteLineItemId estructura (parent bundle + children coverages)
8. **Issue Policy** → wizard crea InsurancePolicy + coverages + transactions

## Error "Cannot read properties null (reading 'groups')"

Se dispara cuando el LWC transactionLineTable no puede resolver el "context" del Quote. Causas comunes ordenadas por probabilidad:

1. **Quote.TransactionType null** — setear `AutoTransactionType` o `GroupInsuranceTransactionType`
2. **RecordType de la Opportunity no es SimpleOpportunity** — cambiar via update
3. **Quote nunca fue saved** — según docs, requiere al menos 1 save antes de que el LWC funcione
4. **Faltan PSLs/PS al usuario** — asignar las 30+ listadas arriba
5. **Quote no fue creado via OmniScript sino manualmente por INSERT** — los QLIs y estructura no están completos. Recrear via OmniScript.
6. **Producto agregado via "Add Products" clásico en vez de Browse Catalogs** — Revenue Cloud excluye Add Products del flow RCA

## Setup checklist para nueva org

1. Enable Revenue Cloud Features (Setup > Revenue Settings)
2. Enable Salesforce Pricing (Setup > Salesforce Pricing Settings)
3. Configure Products at Runtime = ON
4. Transaction processing for quotes = ON, con Transaction Processing Type default
5. Clonar y activar un Pricing Procedure (Expression Set Templates)
6. Setear PricingRecipe.DefaultPricingProcedureId
7. Correr Sync Pricing Data
8. Crear al menos 1 SalesTransactionType linkeado al Pricing Procedure
9. Configurar FlexiPage Quote con LWC `runtime_revenue_foundation:transactionLineTable` + `transactionSummary` + `progressIndicator`
10. Asignar ProductConfigurationFlow a los productos bundle configurables (via ProductConfigFlowAssignment)
11. Asignar TODAS las PSLs y PS al usuario demo
12. Verificar Quote Line Group page layout asignado al perfil del usuario (Known Issue Spring '26)
