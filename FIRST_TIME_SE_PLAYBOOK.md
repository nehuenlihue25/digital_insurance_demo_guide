# First-Time SE Playbook — from zero to demo-ready

> This is the doc to open **first** if you've never touched this repo. It's designed to be run start-to-finish by a Solution Engineer who has never built a Digital Insurance demo before. Every step explains **why** it matters — not just what to click. If you get lost, the "Troubleshooting" pointer at the end of each phase tells you exactly which learning file to check.

---

## What you'll have when you finish

- An IDO configured and verified against the same baseline as the reference org (`demo-metadata/baseline/`)
- The full Pyme Integral product catalog + policy + claim data seeded
- 3 dashboards and 11 reports deployed and rendering correctly
- The 4 runbook blocks ready to rehearse
- Claude Code + the 3 MCPs wired so you can adapt the demo to your own client without re-reading the whole repo

**Expected total time**: 60–90 minutes on a fresh IDO. If you already have Claude Code + MCPs configured, closer to 45 minutes.

---

## Phase 0 — Prerequisites (10 min)

Set these up **once per machine**, not per demo. Skip any bullet you already have.

### 0.1 The IDO — non-negotiable

You need the `FINS QBranch - INS on Core IDO`. Any other Digital Insurance-flavored org will fail somewhere in the checks below.

- In Slack: DM `@STORM` → request `FINS QBranch - INS on Core IDO`. Provisioning takes ~10 minutes.
- Alternative: request the same IDO name from **Solutions Workspace** if you prefer the web UI.

**Why**: any other org (SDO Financial Services, SDO Sales, plain scratch org) doesn't have the ~35 Permission Set Licenses this demo depends on. You'll spend the next 4 hours chasing them from your account team, and that's if you know exactly which ones to ask for. The IDO ships with everything already Active — you just have to assign them to your user.

**Reference — what's inside the IDO**: the canonical index of every pre-installed OmniScript, DataRaptor, Flow and demo script in the FINS QBranch IDO lives in this Google Sheet (Salesforce SSO required): https://docs.google.com/spreadsheets/d/13AFoGgsHwyCBxdMj2w7QK5H5m9_poU9zDPM7N9oU1bc/edit?gid=1261614130#gid=1261614130. Cross-reference it whenever you're wondering "does the IDO already have an OmniScript / Flow / DataRaptor for X?" — cheaper than reinventing.

### 0.2 The `sf` CLI (v2)

- macOS: `brew install --cask sf-cli`
- Windows/Linux: [official installer](https://developer.salesforce.com/tools/salesforcecli)
- Verify: `sf --version` — must be v2.x

**Why**: every script in this repo is a `sf`-driven shell script. The old `sfdx` CLI won't work — the flag layout changed in v2.

### 0.3 Alias your IDO login

```bash
sf org login web --alias ins-alfa --instance-url https://<your-storm>.my.salesforce.com
```

Replace `ins-alfa` with whatever short kebab-case name you prefer. **Every script in this repo assumes an alias** — hardcoding your Storm username makes the whole thing non-portable.

**Why**: aliases decouple your automation from the underlying org URL. When your Storm expires and you get a new one, you just re-run `sf org login web --alias ins-alfa --instance-url <new-url>` and everything else keeps working.

### 0.4 Claude Code + the 3 MCPs

If you're going to use Claude Code as a copilot for this repo (highly recommended — the runbooks + gotchas + adaptation prompts are all designed for it), set up 3 MCPs:

1. **Salesforce Docs MCP** — Claude queries release 260+ docs directly. Config depends on your internal SE onboarding.
2. **OmniStudio MCP** — required for Block 1's Quote flow. **Do not use the `sfcli: true` path — it hangs.** Use the helper:
   ```bash
   cd <your project root>
   ./demo-metadata/scripts/setup-omnistudio-mcp.sh ins-alfa
   ```
   Then restart Claude Code once. Full write-up: [`demo-metadata/learnings/omnistudio-mcp-setup.md`](demo-metadata/learnings/omnistudio-mcp-setup.md).
3. **`sf` CLI on PATH** — Claude drives it through the built-in Bash tool. Nothing to configure beyond having `sf` available.

Optional: **Slack MCP** if you want Claude to read team channels for context.

**Troubleshooting Phase 0**: if any of the setups above fail, read the root README section 🧰 *Toolchain setup* end-to-end before continuing.

---

## Phase 1 — Verify the IDO matches the baseline (5 min)

**Do not skip this phase.** It's the fastest way to catch "wrong IDO type" or "you forgot to assign PSLs to your user" — both of which manifest 30 minutes later as opaque script failures if you don't check now.

```bash
export SF_DISABLE_LOG_FILE=true
cd demo-metadata/
./scripts/00b-verify-baseline.sh ins-alfa
```

The script checks 4 things against the reference baseline captured from a working IDO (see `demo-metadata/baseline/`):

1. **36 Permission Set Licenses** — assigned to your user (Digital Insurance, Claims, FSC, RLM, Pricing, OmniStudio, Context, BRE, Einstein for FS, Billing)
2. **7 critical Permission Sets** — FINS role bundles + Revenue Cloud + Contracts
3. **5 Record Types** — `SimpleOpportunity`, `Commercial`, `Coverage`, `FINS_InsurancePolicy_Property_Casualty`, `SDO_Account_Simple`
4. **QBranch namespace package** — proxy for "this is a QBranch IDO"

**Expected output**: everything green, exit 0, "Baseline OK — safe to run 01-block1-product.sh".

**If something's red**:
- **Missing PSL / PS** → open Setup → Users → your user → Permission Set (License) Assignments → Edit → add the missing ones. `demo-metadata/baseline/permission-sets.md` has a batch-assign CLI snippet if there are many.
- **Missing Record Type** → you're on the wrong IDO type. Re-provision `FINS QBranch - INS on Core IDO` from STORM.
- **qbranch package missing** → same as above — wrong IDO type.
- Re-run `00b-verify-baseline.sh` until it's all green.

**Why**: this is the single most valuable 5-minute investment. An early user of this repo spent 3 hours debugging the Quote flow on their first attempt because `SimpleOpportunity` wasn't assigned — the LWC threw `Cannot read properties null (reading 'groups')` and there was no way to trace it back to the missing PS without knowing.

**Troubleshooting Phase 1**: [`demo-metadata/baseline/README.md`](demo-metadata/baseline/README.md) explains each check + what "missing" means.

---

## Phase 2 — Basic prerequisites + build the product catalog (10 min)

Two scripts, run in order:

```bash
./scripts/00-prerequisites.sh ins-alfa
./scripts/01-block1-product.sh ins-alfa
```

### 2.1 What `00-prerequisites.sh` does

Sanity-checks: sObjects reachable, cross-verifies a subset of the baseline in a way that's runtime-checkable (some fields only appear when specific packages are healthy).

### 2.2 What `01-block1-product.sh` does

Creates the full Pyme Integral product catalog:
- 1 root Product2 bundle (`segPymeIntegral`, Type=Bundle, RecordType=Commercial)
- 6 child Coverage Product2s (Incendio, RC, Robo, Equipo Electrónico, Rotura, Sustracción — each with Type=null, RecordType=Coverage)
- Product classifications + attribute definitions + picklist values
- 48 ProductAttributeDefinition records (6 coverages × 8 attributes each — these do NOT auto-generate)
- ProductRelatedComponent records linking the bundle to the coverages

**Duration**: 3–4 minutes. Watch the output — it prints `[log]` lines for each phase and `[warn]` if something's ambiguous.

**Expected end state**: "Block 1 — product data ready" + a URL you can click to see the bundle in the org.

### 2.3 Ask Claude to explain the model (optional, useful for first-timers)

Open Claude Code in the repo root and prompt:

> Read `SPEC_PYME_INTEGRAL_BLOCK1.md` and explain to me why we split the product into a bundle + 6 coverages. Then quickly walk me through what `01-block1-product.sh` actually did in the org — I want to understand what I'm about to demo.

Claude will use the OmniStudio MCP (for the LWCs) + the Docs MCP (for the object model) + `sf data query` (for what's actually in the org) to give you a grounded answer.

**Troubleshooting Phase 2**: [`demo-metadata/learnings/digital-insurance-gotchas.md`](demo-metadata/learnings/digital-insurance-gotchas.md) sections 1-7. The most common failure is `AttributePicklistValue.Code duplicates value on record` — that's a global-uniqueness quirk documented in section 3.

---

## Phase 3 — Build the transactional data (10 min)

```bash
./scripts/02-block5-clauses.sh ins-alfa
./scripts/03-block2-policy.sh ins-alfa
./scripts/04-block3-claim.sh ins-alfa
```

Three scripts, run in order:

- **`02-block5-clauses.sh`** — creates the 6 InsuranceClauses (5 exclusions + 1 pattern clause), links them to the Pyme product via InsuranceProductClause, and populates the variable maps.
- **`03-block2-policy.sh`** — creates the 3 demo Accounts, 1 Opportunity (RecordType=SimpleOpportunity + Standard Pricebook), the POL-PYME-2026-0001 InsurancePolicy, 6 InsurancePolicyCoverage records, **4 InsurancePolicyTransaction records** (Issuance + Endorsement + Renewal 2027 + Cancellation Request), 6 InsurancePolicyProductClauses, and **2 CardPaymentMethod records** (Visa ****4242 + Mastercard ****5555).
- **`04-block3-claim.sh`** — creates the SIN-PYME-2026-0001 Claim, participants, items, ClaimCoverage, reserves and payments.

**Expected end state after each script**: the script prints a summary + a URL. Click through the URLs to visually confirm the data is there.

**Common trap**: the scripts are idempotent — if you re-run them, they update existing records instead of duplicating. But the InsurancePolicy Status stays `In Force` even after script 03 creates the Cancellation transaction. That's intentional (see the runbook Block 2 notes) — cancellation is Type='In Process' so Block 3 can still run.

**Troubleshooting Phase 3**: if a script fails mid-way, the error typically points to a specific missing thing — read the last 20 lines carefully. Common ones:
- `ClaimItem` requires `FaultDate` (see gotchas §4)
- `ClaimCoverage` requires `ClaimItemId` (see gotchas §4)
- Field naming trap on `Claim.PolicyId` — that field doesn't exist, it's `PolicyNumberId` (see gotchas §6)

---

## Phase 4 — Deploy reports + dashboards (5 min)

```bash
./scripts/05-block6-deploy-reports.sh ins-alfa
```

Deploys via SOAP MDAPI (`sf project deploy start` doesn't work in restricted environments — see [`demo-metadata/learnings/sf-cli-sandbox-quirks.md`](demo-metadata/learnings/sf-cli-sandbox-quirks.md)):

- 5 Custom Report Types (`InsurancePolicy_Pyme__c`, `InsurancePolicyCoverage_Pyme__c`, `Claim_Pyme__c`, `ClaimCoveragePaymentDetail_Pyme__c`, `ClaimCovReserveAdjustment_Pyme__c`)
- 11 reports (8 Summary + 3 Tabular row-limited)
- 3 dashboards (Producción, Renovaciones, Siniestralidad)

**Expected end state**: `status=Succeeded ok=5/5 errors=0` for the CRT deploy, `ok=14/14 errors=0` for the reports+dashboards deploy, and the folder verification prints "Reports in 'Seguros ALFA Pyme': 11" and "Dashboards: 3".

**Verify runtime**: open the org, navigate to the Reports tab → folder "Seguros ALFA Pyme". Every report should open and show data (or "No data" if the row set is empty — but no errors). Open each dashboard and refresh — the charts should render.

**Troubleshooting Phase 4**: field name traps are documented in [`demo-metadata/learnings/digital-insurance-gotchas.md`](demo-metadata/learnings/digital-insurance-gotchas.md) section 6. If a report fails at runtime with `This report cannot be used as the source for this component`, you're likely on an older release where the field names differ — bring the specific error to Claude Code and it can diff against the baseline.

---

## Phase 5 — Rehearse the 4 blocks (30–45 min)

> ⚠️ **Before you rehearse Block 1 — one non-negotiable rule about the Quote flow.**
>
> **Never create the Quote by clicking "New" on the Quotes tab.** The Product Configurator LWC will crash with `Cannot read properties null (reading 'groups')` because a hand-created Quote is missing three fields the LWC silently requires:
> - `Quote.TransactionType` = `AutoTransactionType` (looks optional in the UI, isn't)
> - Linked `Opportunity.RecordType` = `SimpleOpportunity`
> - `Opportunity.Pricebook2Id` = Standard Pricebook
>
> The demo flow starts from the **Account → Action Launcher → "Create Quote B2C Insurance 2"** OmniScript, which builds the Opportunity + Quote with all three fields set correctly in a single click. Any other entry point (Quotes tab, Opportunity related list, custom shortcut) skips this setup and the LWC breaks.
>
> In production, the same pattern applies — the OmniScript would look up an existing Opportunity (broker referral, prior quote request) or create a new one, then link the Quote with the right fields. We simplified the demo to one click. **Do not "improve" this by creating the Quote directly** — you'll spend hours debugging an LWC error with no useful stack trace.
>
> Full write-up: [`CLAUDE.md`](CLAUDE.md) section "RCA Quote requires TransactionType — never create Quote manually" and the Block 1 runbook, step 2.8.

Now walk through each runbook once, in order:

1. [`RUNBOOK_BLOCK1_PYME_PRODUCT.md`](RUNBOOK_BLOCK1_PYME_PRODUCT.md) — 48 min. Product Catalog + Quote flow + Issue Policy.
2. [`RUNBOOK_BLOCK2_POLICY_LIFECYCLE.md`](RUNBOOK_BLOCK2_POLICY_LIFECYCLE.md) — 45 min. Issuance, endorsement, renewal, cancellation, payment methods, clauses + architecture section for cobranza.
3. [`RUNBOOK_BLOCK3_CLAIMS.md`](RUNBOOK_BLOCK3_CLAIMS.md) — 45 min. FNOL → assessment → payment.
4. [`RUNBOOK_BLOCK6_REPORTING.md`](RUNBOOK_BLOCK6_REPORTING.md) — 30 min. Dashboards + reports.

Each runbook has:
- Pre-demo setup (tabs to open, list views to switch to `All`, coverage-ID mapping check)
- Step-by-step clicks with **literal talk track** (English samples; deliver in the customer's language)
- Anticipated Q&A with prepared answers
- Fallback plans for common runtime hiccups (list views defaulting to "Recently Viewed", fields not populated, etc.)

**Recommended rehearsal method**: read each block silently first, then run through it clicking in the org, then read the "Anticipated client questions" section aloud. Two full run-throughs is usually enough for the demo day.

**Use Claude Code to adapt on the fly**. Sample prompts:

> Read `RUNBOOK_BLOCK1_PYME_PRODUCT.md` step 3.2. My customer is in Peru so the pricing is in PEN not COP. Update the talk track and the numbers in the block, and tell me which fields I need to update in the org so the demo numbers reflect PEN.

> The client asked yesterday if we can show a group life scenario. Look at `demo-metadata/baseline/record-types.md` — do we have RecordTypes for that? If yes, propose a Block 2b runbook variant using InsurancePolicy record type EB.

---

## Phase 6 — Adapt to your client (variable time)

The demo values are placeholders. When you customize:

- **Customer name**: search-and-replace `Seguros ALFA` (the insurer) and `Panadería La Espiga SAS` (the insured) with your equivalents. Both appear in the runbooks (talk tracks + IDs) and in a few CSV-style loaders.
- **Line of business**: the coverage names (Incendio, RC, Robo, etc.) are Spanish and map to Colombian SME language. If your target is a different LOB (auto, life, health), keep the same architecture but swap the 6 coverages for your equivalents in the script `01-block1-product.sh`.
- **Currency**: the demo uses COP amounts (2,400,000 for the annual premium). Ask Claude to convert to your currency (MXN, PEN, USD, etc.) and update the scripts + talk tracks in one pass.
- **Clauses**: the 6 InsuranceClauses have Spanish clause text. If your client is Colombian, keep them. Otherwise, translate.

**A single Claude prompt can do most of this**:

> Read this repo. My client is ACME Insurance in Chile, they sell auto insurance in CLP. Adapt the entire demo: swap Seguros ALFA → ACME Insurance, Panadería La Espiga → a Chilean transport company called "Transportes del Sur SpA", the 6 Pyme coverages → the equivalent auto coverages in CLP, and the clause texts to reflect Chilean insurance law. Preserve the architecture (bundle + coverages + attributes + clauses + policy + claim + dashboards). Show me the plan first before making any changes.

---

## When you get stuck

1. **First check**: read the error message carefully — 90% of the time it points to a specific gotcha documented in `demo-metadata/learnings/digital-insurance-gotchas.md`.
2. **Second check**: search `CLAUDE.md` for the object or error string — it has the top 14 gotchas condensed.
3. **Third check**: ask Claude Code with full context. Sample prompt:

   > I'm on Phase 3 step 04-block3-claim.sh. It failed with this error: `<paste error>`. Read `demo-metadata/learnings/*.md`, cross-check against the org's actual schema via `sf sobject describe`, and tell me what's wrong + how to fix it.

4. **Last resort**: if you find a new gotcha, add it to `demo-metadata/learnings/digital-insurance-gotchas.md` and open a PR. The next SE will thank you.

---

## What NOT to do

- **Do not** try to run the scripts against a non-QBranch IDO "just to see what happens" — you'll get 30 minutes of red errors and no useful output. Fix the baseline first.
- **Do not** commit `.mcp.json` (contains access tokens) — it's in `.gitignore` for a reason.
- **Do not** hardcode any ID in a script — every ID in this repo is resolved dynamically at runtime. If you're tempted to hardcode, you're missing a lookup pattern.
- **Do not** skip Phase 1. Ever. Others have learned this the hard way; you don't have to.

---

**Ready?** Run Phase 0 setup, then jump to Phase 1. First time end-to-end is usually 60 minutes. Second time (once you have Claude Code + MCPs wired) is closer to 25.
