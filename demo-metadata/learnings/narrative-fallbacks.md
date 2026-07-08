# Narrative Fallbacks — Seguros ALFA Demo

Pre-built talk tracks for specific situations that may come up during the 2026-07-09 demo. *(Sample scripts — deliver in the client's language.)*

## Talk track: "Prices show in USD, not COP"

> "The $ symbol on screen appears because this demo org has USD set as the default currency — it's a technical artifact of the environment. The numeric values you see (2,400,000, 800,000, etc.) are what ALFA would configure in Colombian pesos when setting the currency on their production org. The entire pricing procedure and rate matrices work identically regardless of the currency."

## Talk track: "Standard labels are in English"

> "The demo user's locale is set to en_US, which is why standard Salesforce labels (Product Code, Save & Exit, Related, etc.) appear in English. In ALFA's real implementation, the user is configured with locale es_CO and the entire interface is automatically translated to Spanish. All the business data you see on screen (product names, coverages, attributes, clauses, claims) is in Spanish because that's how we loaded it into the catalog — which is what matters."

## Talk track: "I don't see Reinsurance or Billing in the demo"

> "Correct — they're outside the scope of this presentation for two reasons. Reinsurance is a layer that integrates with specialized solutions — the Insurance on Core data model does not include reinsurance natively because it's a market where insurers rely on dedicated systems (Guy Carpenter, Cognalys, SICS). Billing and collections, similarly, integrate with the billing solution ALFA already has in production. Both are clear points on the architecture diagram, and we'll cover them in detail during the architecture session at the end."

## Talk track: "I don't see any Rules configured on Plan Empresarial"

> "Correct — we're showing the Rules engine that ships out of the box along with the 6 OOTB UnderwritingRuleGroups to illustrate the capability. In an actual ALFA implementation, the underwriting team configures the specific rules (economic activity validation, sum-insured limits per segment, approval rules by amount) on this same engine. Configuring 20-30 typical rules takes the business team about 2-3 weeks with architect support — it's already included in the implementation roadmap."

## Talk track: "The dashboards look basic / thin"

> "The dashboards you're seeing are basic tabular reports because they illustrate the data available to the reporting model. In ALFA's implementation, they combine with **CRM Analytics** — which is also part of this org's licenses — for temporal aggregation, drill-down by branch/product, KPI alerts and forecasting. In the architecture session we show how these standard reports transition to CRM Analytics dashboards with Einstein Discovery."

## Talk track: "There's no dynamic rating configuration"

> "What we're showing today is the OOTB pricing procedure — Insurance_Quote_Default_Pricing_Procedure. Digital Insurance PCM supports advanced pricing procedures via 3 declarative layers: (1) CalculationMatrix for rate cards by segment/region/activity, (2) ExpressionSet for conditional logic, (3) DecisionTable for coefficient tables. All of them are configured without code. An ALFA actuary with PCM training (~1 week) can model any commercial rate in their portfolio."

## Talk track: "Can I modify prices inline?"

> "Yes. Each Coverage has its UnitPrice on the PricebookEntry — modifiable declaratively. In addition, the pricing procedure calculates the final price in real time based on the attributes the agent configures (Suma Asegurada, Actividad Económica, etc.). A price change at the product level or in the formula propagates instantly to all future quotes. Already-issued policies keep their contractual price until renewal."

## Talk track: "How does this integrate with our legacy systems?"

> "Insurance on Core exposes standard REST and SOAP APIs over every object: Product2, InsurancePolicy, Claim, ClaimCoverage, InsurancePolicyTransaction. On top of that, there are Digital Insurance-specific endpoints (Insurance Rating API, Endorsement API, Claims Management API) for higher-volume integrations. For batch ETL against AS400 or an external core, we use MuleSoft or Data Loader depending on volume. In the architecture session we detail the integration model specific to ALFA's IT landscape."

## Talk track: "The claim view looks simplified. At ALFA we manage 20-30 steps"

> "Correct — we're showing the end-to-end cycle with 6 phases (FNOL, participants, items, coverage, reserves, payments) to give context. In ALFA's real implementation, the full workflow is modeled with Action Plans, milestones, SLAs, multi-level approvals and notifications. The Action Plan engine you see empty in this demo is where those 20-30 steps get configured. A typical ALFA claim case can be modeled in 2-3 days of configuration."

## Talk track: "Can the business team administer this catalog?"

> "Yes — it's a core promise of the module. A business role with Product Catalog Management permissions (PSL DigitalInsuranceProductAdmin) can: create new products, add/remove coverages, modify attributes and their ranges, change prices, activate/deactivate products by date, publish to catalogs and categories, and define underwriting rules. All without touching code, without depending on IT. The architecture team maintains the foundations (ProductClassification, generic AttributeDefinitions); the commercial team builds their commercial products on top of that."
