# Demo Metadata — Seguros ALFA (Grupo Aval)

## Purpose
Everything needed to (1) replicate the Insurance on Core Pyme demo in another org, and (2) avoid the same mistakes made during this build.

## ⚠️ Required org

**These scripts and metadata packages are designed for the `FINS QBranch - INS on Core IDO`.** That IDO is the only one that ships with the full stack pre-provisioned (Digital Insurance + Revenue Cloud Advanced + Product Configurator + OmniStudio + Context Service + Salesforce Pricing + all Permission Set Licenses). Provision it from the **STORM app in Slack** (`@STORM` → request `FINS QBranch - INS on Core IDO`) or from **Solutions Workspace**. Any other org will fail on the license/permission checks in `00-prerequisites.sh`.

## Tooling prerequisites (30-second summary)

- **`sf` CLI (v2)** installed and available on your PATH.
- **Aliased login to your IDO**: `sf org login web --alias <your-alias>` (use a short kebab-case name like `ins-alfa`). Every script here calls `--target-org "$ORG"`, so the alias is what makes them portable across orgs — never hardcode a username.
- **Salesforce Docs MCP** enabled in Claude Code if you're going to prompt Claude for design or debugging help while running the scripts (highly recommended). Without it, Claude can't consult live Salesforce docs.
- See the root README's **🧰 Toolchain setup** section for install commands.

## Quick context
- Client: Seguros ALFA (Grupo Aval Colombia)
- Presentation: 2026-07-09 (Thursday) 8:00 AM – 2:00 PM Colombia time
- Org: ins-qbranch-alfa (`storm.c90aab66569c63@salesforce.com`)
- Product: **Seguro Pyme Integral** (bundle) with 4 default + 2 optional coverages, 8 attributes per coverage, 6 clauses in Spanish
- Operational documents: PROJECT_PLAN_ALFA_2026-07-09.md + SPEC_PYME_INTEGRAL_BLOCK1.md + RUNBOOK_BLOCK{1,2,3,6}.md + RUNBOOKS_INDEX.md (all in the parent directory)

*Note: currency amounts in demo data are labeled in COP (Colombian Peso) but the underlying org shows them as raw numeric values — treat "COP 100,000,000" as the demo notation, not a converted USD figure.*

## Folder structure

```
demo-metadata/
├── README.md                    ← this file
├── scripts/                     ← shell scripts to recreate the demo
│   ├── 00-prerequisites.sh      ← verify org + PSLs + PS
│   ├── 01-block1-product.sh    ← create catalog + product + coverages + attrs
│   ├── 02-block5-clauses.sh    ← create InsuranceClauses + productClauses + variableMaps
│   ├── 03-block2-policy.sh     ← accounts + policy + coverages + 4 IPTs (issuance/endorsement/renewal/cancellation) + policy clauses + 2 CardPaymentMethods
│   ├── 04-block3-claim.sh      ← claim + participants + items + coverage + reserves + payments
│   └── 05-block6-deploy-reports.sh ← deploy reports+dashboards via SOAP MDAPI
├── metadata/
│   ├── reports-dashboards/      ← MDAPI package (11 reports + 3 dashboards)
│   └── custom-report-types/     ← MDAPI package (5 CRTs)
├── learnings/                   ← what to learn to avoid repeating mistakes
│   ├── digital-insurance-gotchas.md
│   ├── sf-cli-sandbox-quirks.md
│   ├── rca-rlm-setup.md
│   ├── narrative-fallbacks.md
│   └── claude-code-lessons.md   ← specifically for Claude Code
└── reference-ids.md             ← table of current IDs (reference, do not hardcode in scripts)
```

## How to replicate in a new org

Prerequisites:
- Digital Insurance org with Revenue Cloud Advanced (RCA) provisioned — [see `learnings/rca-rlm-setup.md`](learnings/rca-rlm-setup.md) to verify
- User with Digital Insurance + RCA PSLs — [see `scripts/00-prerequisites.sh`](scripts/00-prerequisites.sh)
- `sf` CLI authenticated; `export SF_DISABLE_LOG_FILE=true` in the shell
- Org alias present in `sf org list`

Execution order:
```bash
export ORG=<your-org-alias>
./scripts/00-prerequisites.sh $ORG
./scripts/01-block1-product.sh $ORG
./scripts/02-block5-clauses.sh $ORG
./scripts/03-block2-policy.sh $ORG
./scripts/04-block3-claim.sh $ORG
./scripts/05-block6-deploy-reports.sh $ORG
```

Each script should take 30-90 seconds. Total ~5-10 min of build time.

## Steps that require UI (not automatable)

- **Block 1 Steps 2.8-2.14** (Quote → Configure → Issue Policy): require OmniScript CreateQuoteDCT2 + the Product Configuration LWC live. See RUNBOOK_BLOCK1_PYME_PRODUCT section "Phase 4" for the click path.
- **Insurance Policy layout** to show Transactions and Policy Product Clauses on the Related tab: edit Page Layout in Setup UI (~5 min).
- **Demo user locale** (optional): change to es_CO in Setup > Users if you want Spanish labels.

## Key learnings (spoilers)

See the full `learnings/`, but the 5 most critical:

1. **`Product2.ProductClass` is not writable** — it's auto-derived from `RecordType` (Coverage → Simple) or `Type` (Bundle → Bundle). Do not include it in the INSERT payload.
2. **`ProductRelatedComponent.ParentProductRole`/`ChildProductRole`** are auto-derived from `ProductRelationshipTypeId`. Same rule, don't include them.
3. **PADs are NOT auto-generated** with `BasedOnId` — you must create `ProductAttributeDefinition` manually, one per (Product2 × ProductClassificationAttr).
4. **`InsuranceClause.Type` (not `ClauseType`)** — this is a common doc error.
5. **RCA Quote requires `TransactionType` set** (AutoTransactionType or GroupInsuranceTransactionType); without it the Product Configuration LWC throws `Cannot read properties null (reading 'groups')`.

## Contact

Runbooks + this metadata are artifacts of Nehuen Lobo's (@nlobo) demo for the Seguros ALFA — Grupo Aval project.
