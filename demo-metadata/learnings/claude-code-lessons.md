# Lessons for Claude Code — Digital Insurance demo builds

This document is "from me to me." If the next Claude Code (or myself in another session) builds a similar demo, read this first.

## Lesson 1: DO NOT assert diagnoses without hard evidence

**What I did wrong on this demo**: on two occasions I confidently declared that "RCA is not installed in the org," the first time when SalesTransactionDefinition returned INVALID_TYPE, the second time when SalesTransactionType had 0 records. Both times it was false: RCA WAS installed — the user simply lacked the required PSLs/PS.

**Rule**: when a sObject returns INVALID_TYPE or NOT_SUPPORTED, treat it as a HYPOTHESIS "not accessible to this user," not as CONFIRMATION "object does not exist." Verify with:
1. Query available PSLs in the org (not just the ones assigned to the user)
2. Cross-reference with other indicators (related fields on neighboring objects — e.g., Quote.CalculationStatus with 20+ RCA states is irrefutable evidence that RCA is there)
3. Assign ALL candidate PSLs to the user and re-query
4. Only declare "not installed" after confirming on the third attempt

## Lesson 2: sObject names are not intuitive

**What I did wrong**: I used `ClaimAssessment`, `ClaimReserve`, `ClaimPayment`, `ClaimAdjuster` in the initial spec — ALL made up. The real ones are different (see `digital-insurance-gotchas.md`).

**Rule**: before speccing anything, run `sf sobject list --sobject standard` filtering by prefix ("Claim", "Insurance", "Product") and work ONLY with what actually shows up. DO NOT extrapolate from patterns in other clouds (CG, generic FSC).

## Lesson 3: Required NON-WRITABLE fields are a pattern, not an exception

**What I did wrong**: Product2.ProductClass, ProductRelatedComponent.ParentProductRole and ChildProductRole, Quote.AccountId (post-create), Quote.OpportunityId (post-create), TransactionAmount vs "Amount" on InsurancePolicyTransaction... they all surprised me the first time.

**Rule**: when planning an INSERT/UPDATE, always run `sf sobject describe` first and filter by `createable=false OR updateable=false`. These fields do not belong in the payload even if the schema says `nillable=false`.

## Lesson 4: Sandbox constraints require SOAP workarounds

**What I did wrong**: I tried `sf project deploy start` 3-4 times hoping it would work. It always blocks on writes to `~/.sfdx/`. In the end we solved it with direct SOAP — which works perfectly, but figuring that out took time.

**Rule**: if the sandbox has write restrictions, DO NOT try tools that assume $HOME is writable. Go straight to the workaround:
- Deploy metadata → SOAP `services/Soap/m/62.0`
- Retrieve metadata → SOAP retrieve
- Auth refresh → do a manual web login outside the sandbox

## Lesson 5: Diagnostic workflows must be adversarial

**What I did wrong**: early workflows accepted optimistic conclusions ("plan build viable, all objects accessible") when in reality there were critical gaps. The critique passes were too soft.

**Rule**: for ultracode tasks, ALWAYS include an adversarial critique Phase that:
1. Verifies every claim in the spec against real data
2. Runs concrete tests (test INSERTs, LWC render tests)
3. Fails explicitly if anything doesn't line up
4. Prefers null results to speculative results

## Lesson 6: Sessions spread across the day have auth issues

**What happens to me**: between one session and the next, the access token expires. `sf org display` against a sandbox tries to refresh via `~/.sfdx/`, which is blocked. The fix is a manual re-login — but that breaks the flow.

**Rule**: if the session is going to run for more than 2 clock-hours, prompt the user to run `sf org login web` proactively at the start, even if the current token still works. I dedicate 1 tool call up front to verify auth freshness.

## Lesson 7: OmniScript + Product Config LWC is the canonical path, not INSERT via API

**What I did wrong**: I tried to build the Pyme Quote via `sf data create record --sobject QuoteLineItem` with a manual `ParentQuoteLineItemId` link. FAILED (ParentQuoteLineItemId is not directly writable). The only correct way to create a Quote with RCA structure is via the CreateQuoteDCT2 OmniScript → Browse Catalogs → Configure LWC.

**Rule**: for RCA / Digital Insurance demos:
1. Product2 + PADs + Coverages + Classifications CAN be created via API
2. Quotes WITH bundle+coverage STRUCTURE CANNOT. They require the OmniScript/LWC.
3. Document in the runbook that the runtime steps are UI-only and not automatable

## Lesson 8: Ultracode workflows speed up when there is real parallelism

**What I did right**: workflows with 3-8 parallel agents investigating orthogonal aspects (docs research + org queries + FlexiPage inspection) were 3-5x faster than doing it serially.

**What I did wrong**: some workflows had agents with identical or overlapping prompts — zero real parallelism, only overhead.

**Rule**: before launching a workflow, draw the diagram:
- 3+ orthogonal items that can run in parallel → workflow YES
- 1-2 dependent or small items → direct agent or direct Bash

## Lesson 9: Document fallbacks MANDATORILY

**What I did right on this demo**: every runbook has a "fallback" section in each Step. Live, this saved time when a click didn't load as expected.

**Rule**: every runbook step MUST have a 1-line "if X doesn't appear, do Y." Not optional.

## Lesson 10: Persistent memory for the next Claude

After this demo, I updated `~/.claude/projects/-Users-nlobo-claude-projects-Grupo-Aval-Insurance/memory/` with:
- `project_seguros_alfa.md` — project context
- `feedback_digital_insurance_product_config.md` — technical gotchas
- `feedback_no_hardcoded_ids.md` — dynamic-lookup rule
- `feedback_sf_cli_sandbox.md` — required env vars

The next Claude in this directory will read this automatically. THAT is the point of persistent memory.
