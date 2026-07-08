# Project: Digital Insurance (Insurance on Core) Demo Guide

This repository contains the complete documentation, automation scripts, and metadata packages for building a Salesforce Digital Insurance demo (SME/Pyme commercial line). It was built using a FINS QBranch - INS on Core IDO org.

## Key conventions (always follow these)

- **Never hardcode Salesforce IDs.** Resolve every ID dynamically via SOQL by Name, Code, or DeveloperName. IDs change between orgs.
- **Always prefix `sf` CLI commands with `export SF_DISABLE_LOG_FILE=true`** — or export it once at session start. Without this, sf CLI crashes attempting to write logs.
- **Use `--target-org <alias>`** on every sf command. The alias is set via `sf org login web --alias <short-name>`. Convention: short kebab-case like `ins-alfa`, `dins-acme`.
- **The required org is the IDO `FINS QBranch - INS on Core IDO`** — provision from STORM Slack app or Solutions Workspace. No other org type has the full stack pre-provisioned.

## Critical technical knowledge (avoid repeating mistakes)

### Fields that look writable but aren't
- `Product2.ProductClass` — auto-derived from RecordType (Coverage → Simple) or Type (Bundle → Bundle). Omit from INSERT payloads.
- `ProductRelatedComponent.ParentProductRole` / `ChildProductRole` — auto-derived from `ProductRelationshipTypeId`. Omit from INSERT.
- `Quote.AccountId` / `Quote.OpportunityId` — not updateable after creation.

### Object names that are commonly wrong
- ✅ `ClaimCovPaymentAdjustment` — NOT `ClaimCoveragePaymentAdjustment`
- ✅ `InsuranceClause.Type` field (values: Clause, Exclusion) — NOT `ClauseType`
- ❌ `ClaimAssessment`, `ClaimReserve`, `ClaimPayment`, `ClaimAdjuster` — these DO NOT EXIST as sObjects
- ❌ `InsurancePolicyVersion` — does not exist; versioning is data-driven via `PriorPolicyId` + `ChangeType` on InsurancePolicy

### Hidden validation rules
- `ClaimItem` requires `FaultDate` (error: "Complete this field" without saying which)
- `ClaimCoverage` requires `ClaimItemId` (error: "Enter a claim item")

### PADs do NOT auto-generate
Setting `Product2.BasedOnId = <ProductClassificationId>` does NOT create `ProductAttributeDefinition` records automatically. You must INSERT them manually (one per Product2 × ProductClassificationAttr).

### AttributePicklistValue.Code is GLOBALLY unique
Not scoped per picklist. Suffix codes to avoid collisions (e.g., `Un_MM_DME` for Deducible Mínimo Evento vs `Un_MM` in Deducible Pyme).

### RCA Quote requires TransactionType
Without `Quote.TransactionType` populated (use `AutoTransactionType` or `GroupInsuranceTransactionType`), the Product Configuration LWC throws `Cannot read properties null (reading 'groups')`.

### Opportunity RecordType for RCA
Must be `SimpleOpportunity` for the Revenue Cloud Advanced Quote flow to work.

## Metadata deploy workaround

`sf project deploy start` fails in Claude Code sandbox (blocked write to `~/.sfdx/` lock file). Use direct SOAP Metadata API deploy via curl instead:
1. Get access token: `sf org display --json --verbose`
2. Zip the MDAPI package
3. Base64 encode
4. POST to `{instance}/services/Soap/m/62.0` with deploy envelope
5. Poll `checkDeployStatus` with asyncId

See `demo-metadata/scripts/05-block6-deploy-reports.sh` for the full implementation.

## Structure reference

- `RUNBOOK_BLOCK{1,2,3,6}_*.md` — click-by-click demo guides with talk tracks
- `demo-metadata/scripts/` — idempotent shell scripts to build the demo data
- `demo-metadata/learnings/` — deep dives on gotchas, RCA setup, CLI quirks
- `demo-metadata/metadata/` — MDAPI packages for reports/dashboards/CRTs
- `demo-metadata/reference-ids.md` — ID snapshot for verification (never use in scripts)

## When researching Salesforce features

Use the Salesforce Docs MCP (`salesforce_docs_search` + `salesforce_docs_fetch`) for current documentation. Prefer release 260+ docs. Use `search_mode="hybrid"` when querying for specific API names or error strings.
