# Digital Insurance (Insurance on Core) — Demo Guide

> End-to-end reference for building, running, and replicating a **Salesforce Insurance on Core / Digital Insurance** demo for the SME (Pyme) commercial line. Built from a real RFP engagement — Seguros ALFA (Grupo Aval, Colombia) — with Claude Code as the copilot.

This repo is designed to be **forked and adapted**. The concrete demo values (Seguros ALFA as the carrier, Grupo Aval as the parent group, Panadería La Espiga as the SME account) are placeholders — swap them for your own client.

## ⚠️ Required org — read this FIRST

**Deploy this demo on the IDO `FINS QBranch - INS on Core IDO`.** Do not use any other org — the whole guide assumes this IDO because it is the only one that ships with the full stack pre-provisioned (Digital Insurance + Revenue Cloud Advanced + Product Configurator + Advanced Configurator Designer + OmniStudio + Context Service + Salesforce Pricing + all the Permission Set Licenses). Any other Digital Insurance org will send you into hours of hunting down license and permission gaps before the scripts even start working.

Provision the IDO from either:

- **STORM app in Slack** — DM `@STORM` (or in the STORM channel) → request the IDO named `FINS QBranch - INS on Core IDO`
- **Solutions Workspace** — pick the same IDO from the SE catalog

Once your IDO is ready, continue to the **Toolchain setup** below and then to the **Quick start**.

## 🧰 Toolchain setup

You'll be driving this demo through Claude Code plus a couple of external tools. Install and wire them up once — everything after that becomes short prompts to Claude.

### 1. Salesforce CLI (`sf`)

Install the Salesforce CLI (v2, the `sf` command, not the deprecated `sfdx`):

- macOS: `brew install --cask sf-cli`
- Windows / Linux: [install instructions](https://developer.salesforce.com/tools/salesforcecli)
- Verify: `sf --version`

Log in to your IDO and **give it a short, memorable alias**. Every script and every runbook step assumes an alias — never the raw `storm.xxx@salesforce.com` username. Convention we use across the repo: short kebab-case name of the demo target, e.g. `ins-alfa`, `dins-acme`, `alfa-demo`.

```bash
sf org login web --alias ins-alfa          # opens a browser, log in, alias saved
sf org list                                 # confirm the alias appears
sf config set target-org=ins-alfa           # optional: make it the default so
                                            # you can skip --target-org in ad-hoc queries
```

From here on, **every `sf` command in the scripts and runbooks uses `--target-org ins-alfa`** (or whatever alias you chose, exported as `$ORG`). If you skip the alias step, the scripts fail on the first query — they resolve targets by alias, not by username.

### 2. MCP servers for Claude Code

Model Context Protocol (MCP) servers expose external tools to Claude Code so it can query docs, drive orgs, and read team channels without leaving the chat. Two are essential for this repo; a third is optional:

**Essential — Salesforce Docs MCP** — lets Claude search and fetch Salesforce Help + Developer Documentation directly. Every design/debug conversation in this repo used it (`salesforce_docs_search`, `salesforce_docs_fetch`). Without it, Claude falls back to training data (stale). Install:

```bash
# From your Claude Code config (~/.claude/config.json or via the /config UI):
# add the MCP server named 'salesforce-docs'
# (see internal SE onboarding docs for the exact endpoint URL)
```

**Essential — `sf` CLI available in your PATH** — Claude Code drives the `sf` CLI through the built-in Bash tool. If Salesforce releases (or your team has) an official MCP wrapper for the CLI, install it too — Claude will auto-detect and use it in place of raw Bash. Either way, `sf` must be on your PATH.

**Optional — Slack MCP** — helpful if you want Claude to read your team channels (RFP threads, demo prep discussions, screenshots) and use them as context. Not required to run the scripts, but useful during the design phase (as we used it during the ALFA build).

### 3. Verify the toolchain

```bash
sf --version                                # >= 2.x
sf org list                                 # your IDO alias must show 'Connected'
sf data query --target-org <your-alias> \
   --query "SELECT COUNT() FROM Product2 WHERE Type='Bundle'"
```

If all three commands succeed, you're ready for the **Quick start** below.

## What's in this repo

### Operational documents (root)

- **[PROJECT_PLAN_ALFA_2026-07-09.md](PROJECT_PLAN_ALFA_2026-07-09.md)** — master project plan: context, locked decisions, timeline, org audit
- **[SPEC_PYME_INTEGRAL_BLOCK1.md](SPEC_PYME_INTEGRAL_BLOCK1.md)** — technical spec for the Pyme product (bundle + coverages + attributes + classifications), with a teardown of Auto Gold as the reference implementation
- **[RUNBOOKS_INDEX.md](RUNBOOKS_INDEX.md)** — master pre-demo checklist + day-of agenda + Q&A guide
- **[RUNBOOK_BLOCK1_PYME_PRODUCT.md](RUNBOOK_BLOCK1_PYME_PRODUCT.md)** — Block 1 (48 min): Product Catalog Management + Quote configuration LWC + Issue Policy — click-by-click with literal talk track
- **[RUNBOOK_BLOCK2_POLICY_LIFECYCLE.md](RUNBOOK_BLOCK2_POLICY_LIFECYCLE.md)** — Block 2 (45 min): policy lifecycle — issuance, endorsement, renewal, cancellation with pro-rated refund, clauses, payment methods on file, plus an architecture section covering recurring collection scheduling, retry logic, integration and bank file generation
- **[RUNBOOK_BLOCK3_CLAIMS.md](RUNBOOK_BLOCK3_CLAIMS.md)** — Block 3 (45 min): end-to-end claims with reserves and payments
- **[RUNBOOK_BLOCK6_REPORTING.md](RUNBOOK_BLOCK6_REPORTING.md)** — Block 6 (30 min): 3 dashboards + 11 Spanish-labeled reports

### Automation and knowledge (`demo-metadata/`)

- `scripts/` — 6 shell scripts that recreate the entire demo dataset in any Digital Insurance org in ~5–10 minutes
- `metadata/` — MDAPI packages ready to deploy (5 Custom Report Types + 3 dashboards + 11 reports)
- `learnings/` — 13 technical gotchas, 10 sf CLI quirks in sandbox, RCA/RLM setup guide, 10 talk tracks for uncomfortable questions, 10 meta-lessons for the next Claude Code session
- `reference-ids.md` — snapshot of the current IDs (reference only; scripts must resolve IDs dynamically)

## Quick start — Replicate the demo in your org

Prerequisites:
- **The `FINS QBranch - INS on Core IDO`** provisioned via STORM (Slack) or Solutions Workspace — see the ⚠️ section above
- `sf` CLI authenticated with an alias pointing at your IDO
- Your demo user assigned all the PSLs listed in `demo-metadata/learnings/rca-rlm-setup.md` (most are pre-provisioned in the IDO, but assignment to the user is manual)

```bash
export ORG=<your-org-alias>
cd demo-metadata/
./scripts/00-prerequisites.sh $ORG              # verify PSL/PS + connectivity
./scripts/01-block1-product.sh $ORG             # Pyme Integral bundle + 6 coverages + 48 PADs
./scripts/02-block5-clauses.sh $ORG             # 6 Spanish InsuranceClauses + variableMaps
./scripts/03-block2-policy.sh $ORG              # Accounts + POL-PYME + coverages + transactions
./scripts/04-block3-claim.sh $ORG               # SIN-PYME + participants + items + reserves + payments
./scripts/05-block6-deploy-reports.sh $ORG      # deploy reports + dashboards via SOAP MDAPI
```

Every script is idempotent, resolves IDs dynamically (never hardcoded), and prefixes `SF_DISABLE_LOG_FILE=true` so `sf` behaves in restricted shells.

Steps that **require the UI** (OmniScript `CreateQuoteDCT2`, Product Configuration LWC, Issue Policy wizard) are documented in the Block 1 runbook — they cannot be automated today.

## Using this repo with Claude Code

This repo was built with [Claude Code](https://claude.com/product/claude-code) as a pair-programming partner over a Digital Insurance org, and it is designed to be re-used the same way. If you have Claude Code installed:

1. Fork or clone this repo.
2. Open a terminal in the repo root and run `claude` to launch Claude Code inside it.
3. Claude will automatically load the **`CLAUDE.md`** file at the root of the repo — this gives it all the project conventions, critical technical knowledge (hidden validation rules, field naming traps, deploy workarounds), and the "never hardcode IDs" rule from the first prompt. No need to re-explain context each session.
4. Point Claude at whichever runbook or script you need. It reads the runbook and drives your org via the `sf` CLI and MCP tools.

### Example prompts

Copy any of these into Claude Code, adapt the bracketed bits, and hit enter:

- `Read this repo. Adapt the Block 1 runbook for a new client called [X] in the [Y] region — replace the Seguros ALFA references, keep the Pyme product structure. Do not translate the coverage names.`
- `Read demo-metadata/scripts/. Rewrite the scripts to build a similar product for [my LOB — Auto, Life, Health]. Preserve the pattern of catalog + coverages + attributes + PADs + clauses.`
- `Read demo-metadata/learnings/. Suggest 3 improvements to my current Digital Insurance demo based on the gotchas here.`
- `I'm getting error "Cannot read properties null (reading 'groups')" when opening a Quote — search demo-metadata/learnings/rca-rlm-setup.md for the diagnosis and give me a fix checklist.`
- `Extend the demo with a Block 7 for [feature X]. Follow the runbook template used by RUNBOOK_BLOCK6_REPORTING.md.`

### CLAUDE.md — project knowledge that persists

The **`CLAUDE.md`** file at the repo root is Claude Code's "project instructions" file — it's loaded automatically at the start of every session in this directory. It contains:
- Key conventions (dynamic ID lookups, `--alias` convention, required env vars)
- Every critical technical gotcha discovered during this build (hidden validation rules, auto-derived fields, naming traps)
- The SOAP deploy workaround for restricted environments
- Structure reference for navigating the repo

**If you learn something new** during your session (a new gotcha, a new field behavior, a setup quirk), update `CLAUDE.md` with it so the next session starts with that knowledge baked in. This is more reliable than auto-memory because it's version-controlled and portable across machines.

For the full narrative of meta-lessons on how the original build with Claude went — what worked, what to avoid — read [`demo-metadata/learnings/claude-code-lessons.md`](demo-metadata/learnings/claude-code-lessons.md).

### Recommended workflow

1. Start Claude with the **README + `demo-metadata/reference-ids.md`** as its initial context.
2. Ask Claude to read the **specific runbook** for the block you're working on (don't front-load all four — the runbooks are long).
3. Delegate the build steps to Claude with **ultracode enabled**, letting it drive `sf` CLI, MDAPI deploys, and REST inserts.
4. **Verify each block in the org UI** before moving to the next one. The runbooks list the exact tab / record / attribute to eyeball.

## The 5 most critical gotchas (spoilers)

1. **`Product2.ProductClass` is not writable** — it is auto-derived from `RecordType` (Coverage → Simple) or `Type` (Bundle → Bundle). Do not include it in the INSERT payload.
2. **`ProductRelatedComponent.ParentProductRole` / `ChildProductRole`** are auto-derived from `ProductRelationshipTypeId`. Same rule — don't include them.
3. **PADs are NOT auto-generated** with `BasedOnId` — you must create `ProductAttributeDefinition` records manually, one per (Product2 × ProductClassificationAttr). Six coverages × eight attributes = 48 records.
4. **`InsuranceClause.Type`** (not `ClauseType`, which many docs incorrectly show) — this catches almost everyone.
5. **RCA Quote requires `TransactionType` populated** + an Opportunity with `SimpleOpportunity` RecordType. Without both, the Product Configuration LWC throws `Cannot read properties null (reading 'groups')`.

Full list of 13 gotchas: [`demo-metadata/learnings/digital-insurance-gotchas.md`](demo-metadata/learnings/digital-insurance-gotchas.md).

## Case study context

The concrete names in this repo are the values from the original engagement:

- **Seguros ALFA** — the carrier (insurance company running the demo)
- **Grupo Aval** — the parent financial group in Colombia
- **Panadería La Espiga** — the SME account used across the policy and claim narrative
- **POL-PYME-2026-0001 / SIN-PYME-2026-0001** — demo policy and claim numbers
- **Colombia / COP** — geography and currency; amounts are labeled in Colombian Peso for narrative purposes

Adapt these to your own client. The runbooks call out where the names appear in talk tracks so you can substitute cleanly. Coverage names (Incendio, Terremoto, Sustracción, RC, Responsabilidad Civil Servidor Público, Lucro Cesante) are left in Spanish on purpose — they map to how the Colombian SME market talks about coverages, and translating them muddles the narrative.

## Contributing

Issues and PRs welcome. If you adapt the runbooks to another line of business (Auto, Life, Health, Group Benefits) or another geography, please open a PR under `demo-metadata/adaptations/<lob-or-country>/` so the next person doesn't reinvent it.

## Credits

Built with [Claude Code](https://claude.com/product/claude-code) by Nehuen Lobo (@nehuenlihue25) for the Seguros ALFA (Grupo Aval, Colombia) RFP engagement — presentation 2026-07-09.

## License

MIT (pending confirmation from the owner).
