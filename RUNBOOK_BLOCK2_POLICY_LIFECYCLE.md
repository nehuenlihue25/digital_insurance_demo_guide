# Runbook — Block 2: Full policy lifecycle

**Duration**: 45 min | **Presenter**: the presenting SE | **Org**: ins-qbranch-alfa (https://storm-c90aab66569c63.my.salesforce.com)

> *All talk tracks below are sample scripts written in English for reference. Deliver them in the client's language (Spanish) on the day of the presentation.*

---

> ⚠️ **The Salesforce IDs and Storm URLs below are from the original engagement — they will not match your org.** Before rehearsing this runbook against your own IDO, run:
>
> ```bash
> ./demo-metadata/scripts/00c-resolve-ids.sh <your-org-alias>
> ```
>
> That prints every ID and URL the runbook references, resolved against your org. Copy-paste them into a local copy of this runbook (or `source` the `--format=env` output to have them as shell variables). The Salesforce IDs in the FINS QBranch IDO **change every time the IDO is provisioned** — never hardcode them.


## 0. Pre-demo setup (do 15 min before starting the block)

### 0.1 Login and session verification
1. Open Chrome (regular profile, NOT incognito — we need a persisted session and want to avoid re-login).
2. Go to `https://storm-c90aab66569c63.my.salesforce.com` and confirm you are already logged in as the demo user. If it prompts for login, authenticate with the credentials the technical lead shared over Slack.
3. In the top Salesforce bar, upper-left corner, verify that the App Launcher (9 dots) is visible and that the active app is **Insurance Agent Console**. If it isn't: click App Launcher → type "Insurance Agent Console" → click.

### 0.2 Critical coverage mapping check (2 min, must do)

**Why**: there is a known risk of confusion between the ID of the Incendio coverage and the Equipo Electrónico coverage. The transition to Block 3 (claims) points to a specific coverage; if Luis picks the wrong coverage live, the script's narrative coherence breaks. Before starting the demo, visually confirm the mapping:

| Expected coverage | Expected ID | Premium |
|---|---|---|
| Incendio y Aliados | 0cYg80000000KErEAM | 800,000 |
| Responsabilidad Civil Extracontractual | 0cYg80000000KDFEA2 | 600,000 |
| Robo y Asalto Interior | 0cYg80000000KI5EAM | 400,000 |
| Equipo Electrónico | 0cYg80000000KGTEA2 | 300,000 |
| Rotura de Maquinaria | 0cYg80000000KJhEAM | 200,000 |
| Sustracción de Dinero y Valores | 0cYg80000000KLJEA2 | 100,000 |

**Steps**:
1. Open in a temporary tab `https://storm-c90aab66569c63.my.salesforce.com/lightning/r/InsurancePolicyCoverage/0cYg80000000KErEAM/view` and confirm the Name is **Incendio y Aliados** and Premium = **800,000**.
2. Open `https://storm-c90aab66569c63.my.salesforce.com/lightning/r/InsurancePolicyCoverage/0cYg80000000KGTEA2/view` and confirm the Name is **Equipo Electrónico** and Premium = **300,000**.
3. If either of the two does NOT match the expected name: **notify the technical lead over Slack immediately** — the Block 3 runbook points to a specific coverage for the claim and we need to align before kickoff. The convention assumed in this runbook and in the transition to Block 3 is the one in the table above.

### 0.3 Browser tabs (open in this order, leave them all loaded)

Open 6 tabs and leave them ready. Order matters because during the demo Luis will hop between them with Ctrl+Tab.

| # | URL | Purpose |
|---|-----|---------|
| 1 | `https://storm-c90aab66569c63.my.salesforce.com/lightning/r/InsurancePolicy/0YTg80000000hJVGAY/view` | Policy POL-PYME-2026-0001 (main view) |
| 2 | `https://storm-c90aab66569c63.my.salesforce.com/lightning/r/Account/001g800000T9v3QAAR/view` | Account Panadería La Espiga SAS (insured) |
| 3 | `https://storm-c90aab66569c63.my.salesforce.com/lightning/r/InsurancePolicyCoverage/0cYg80000000KErEAM/view` | Coverage Incendio y Aliados (detail) |
| 4 | `https://storm-c90aab66569c63.my.salesforce.com/lightning/o/InsurancePolicyTransaction/list` | Transaction list (to jump to Issuance and Endorsement) |
| 5 | `https://storm-c90aab66569c63.my.salesforce.com/lightning/o/InsurancePolicyProductClause/list` | Policy clause list |
| 6 | `https://storm-c90aab66569c63.my.salesforce.com/lightning/r/InsurancePolicyProductClause/1VGg800000008QbGAI/view` | Manual clause Coaseguro 10% (for the InsuranceClauses moment) |

### 0.4 Pre-demo visual checks (3 min)

On tab 1 (POL-PYME-2026-0001) confirm:
- Header: **Status = In Force**, **PremiumAmount = 2,400,000**, **EffectiveDate = 2026-06-01**, **ExpirationDate = 2027-05-31**, **NameInsured = Panadería La Espiga SAS**.
- Sub-tabs visible above the detail section: **Policy Structure**, **Related**, **Details**.
- Click **Policy Structure**: you should see a tree with the policy name and, beneath it, 6 Coverages. If the tree takes time to load, refresh (Cmd+R).
- Click **Related**: the **Coverages** are listed (6 rows). **Note**: Transactions and Clauses do NOT appear here on the default layout — that is expected; see Gotcha #1 in section 5.

On tab 4 (InsurancePolicyTransaction list) confirm:
- The List View dropdown at the top left of the list **may default to "Recently Viewed"**, which returns an empty list if those records weren't opened in the current session. **Change it to "All"** (click the dropdown → "All"). Pin "All" as default with the pin/star if the UI allows, so it doesn't reset.
- With "All" selected, the 4 records should appear: **POL-PYME-2026-0001 — Emisión**, **POL-PYME-2026-0001 — Endoso 001 Incendio**, **POL-PYME-2026-0001 — Renovación 2027**, **POL-PYME-2026-0001 — Solicitud de Cancelación**.

On tab 5 (InsurancePolicyProductClause list) confirm:
- Same warning: change List View to **"All"** (default is often "Recently Viewed" and returns empty).
- With "All" selected, the 6 clauses should appear.

### 0.5 Demo customer preparation (important)
- The only issued policy is **POL-PYME-2026-0001** against **Panadería La Espiga SAS**. The other two RFP accounts (**Ferretería El Tornillo** and **Consultores Andinos**) exist as Accounts but **have no associated policy**. If the client asks about all 3 accounts together, the prepared answer is in section 3.

### 0.6 Zoom and window
- Browser zoom at 90% (Cmd + `-` once) so the full header + related list fits without horizontal scroll.
- Share the entire Chrome window, not a specific tab (so you can alt-tab between tabs without re-sharing).

---

## 1. Context and objective of the block (30 sec)

This block demonstrates the **full lifecycle of a Pyme policy** already issued on the platform: how it is structured against the insured account, how coverages break down with their limits, deductibles and premiums, how financial transactions (issuance, endorsement, renewal, cancellation) are persisted, how the clause engine automatically brings the product's clause set while allowing manual client-specific clauses, and how payment methods live as PCI-compliant standard sObjects. We close with an architectural framing that covers recurring collection scheduling, retry logic, integration and bank file generation — the pieces that go beyond the native Digital Insurance footprint and are addressed with RLM `PaymentSchedule` + Custom Metadata + MuleSoft. For ALFA, this is the functional evidence that the standard Salesforce Insurance model supports the end-to-end flow on native objects, with clear extension paths for everything else.

---

## 2. Step-by-step click path

### Step 2.1 — Starting point: Insurance Agent Console (1 min)

**Click / navigation:**
1. Bring tab 1 to the front (Chrome → tab with POL-PYME-2026-0001).
2. If for any reason you left it: App Launcher (9 dots top left) → type "Insurance Agent Console" → click. Then click the **Policies** tab in the app → click **POL-PYME-2026-0001**.
3. On screen you should see: policy header with Policy Name = **POL-PYME-2026-0001**, Status = **In Force**, three sub-tabs (Policy Structure / Related / Details).

**What to say (talk track):**
> "We're on the Insurance Agent Console, which is the standard Salesforce Insurance app for the user managing policies. What you see here is a Pyme Integral policy that has already been issued for one of the RFP target customers: **Panadería La Espiga SAS**, effective June 1, 2026 through May 31, 2027, annual premium of 2.4 million pesos. All the information I'll show over the next few minutes lives on standard objects of the Insurance data model — there is no custom development on top."

**Emphasis points:**
- Point at the header (Status In Force, Effective/Expiration dates, Premium).
- Mention "standard objects" — this is the differentiating message vs. the previous CRM.

**If something doesn't appear:**
- If the page shows "Insufficient Privileges" or stays blank: refresh with Cmd+R.
- If it still fails: go via App Launcher → Insurance Agent Console → Policies tab → search for "POL-PYME-2026-0001" in the list.

---

### Step 2.2 — Link to the insured account (2 min)

**Click / navigation:**
1. In the policy header, locate the **Name Insured** field. It's on the highlight row, next to Status and Effective Date.
2. Click the hyperlink **Panadería La Espiga SAS**. The account opens.
3. On screen: Account of type **Customer**, Industry = **Food & Beverage**, BillingCity = **Bogotá**.
4. Show the Account header for ~15 seconds. Scroll down to see the Related tabs.
5. Go back to the policy: click the browser's "back" arrow (or Ctrl+Tab to tab 1).

**What to say (talk track):**
> "The policy is linked by lookup to the insured, which is a standard Salesforce Account — the same Account used by sales, service and billing. This is key: **we don't duplicate the customer across modules**. The bakery is a small-and-medium business in the food sector in Bogotá, and any interaction it has with ALFA — a call to the contact center, a claims case, a renewal — shows up in a single 360 view of this Account."

**Emphasis points:**
- 360 view = one single customer record for the entire operation.
- Insurance reuses Account, Contact, Case, Opportunity — it does not create parallel entities.

**If something doesn't appear:**
- If the Name Insured hyperlink isn't clickable: use tab 2 directly (Account Panadería La Espiga SAS).

---

### Step 2.3 — Policy Structure: coverage tree (3 min)

**Click / navigation:**
1. Go back to tab 1 (POL-PYME-2026-0001).
2. Click the **Policy Structure** sub-tab — it's the first of the three tabs.
3. On screen: a hierarchical tree is displayed. Root node = POL-PYME-2026-0001. When expanded, 6 child nodes (Coverages) appear.
4. If the tree comes collapsed: click the ► arrow next to the policy name to expand it.
5. Visually walk through the 6 nodes, reading them out loud in this order (which is descending premium order):
   - Incendio y Aliados — **800,000**
   - Responsabilidad Civil Extracontractual — **600,000**
   - Robo y Asalto Interior — **400,000**
   - Equipo Electrónico — **300,000**
   - Rotura de Maquinaria — **200,000**
   - Sustracción de Dinero y Valores — **100,000**

**What to say (talk track):**
> "In Policy Structure we see the policy's anatomy: one policy grouping **six coverages**. This tree was built automatically when we issued the policy from the Pyme Integral product you saw in Block 1. Each child node is an `InsurancePolicyCoverage` — a standard object — with its own coverage limit, deductible and premium. **The sum of the six coverage premiums — 800 + 600 + 400 + 300 + 200 + 100 thousand — is exactly the 2.4 million peso policy premium**. It's a consistent, auditable model."

**Emphasis points:**
- "Built automatically" — product → policy traceability.
- The verified arithmetic (800+600+400+300+200+100 = 2,400) is an operational confidence argument. If Luis wants, he can read the sum out loud.

**If something doesn't appear:**
- If Policy Structure shows an infinite loading spinner: close the tab, reopen it with the direct URL (tab 1).
- If the tree shows the policy but no children: click the ► to expand; if it still won't expand, go via the Related tab (next step) to show the coverages there.

---

### Step 2.4 — Coverage detail: Incendio y Aliados (3 min)

**Click / navigation:**
1. In the Policy Structure tree, click the **Incendio y Aliados** coverage. The coverage detail opens.
   - Alternative: Ctrl+Tab to tab 3 (already open on this coverage — ID `0cYg80000000KErEAM`, confirmed in step 0.2).
2. On screen: `InsurancePolicyCoverage` detail page with the fields:
   - **Coverage Code**: incendioAliados
   - **Sum Insured / Limit**: 100,000,000
   - **Deductible**: 2,000,000
   - **Premium**: 800,000
3. Go back to Policy Structure and do the same with **Rotura de Maquinaria** (to show a coverage with different limit and deductible: 50M / 1M / 200k).

**What to say (talk track):**
> "Drilling into Incendio y Aliados we see the three numbers every underwriter and every claims operator always needs at hand: **coverage limit 100 million, deductible 2 million, annual premium 800 thousand**. Each coverage has its code — incendioAliados, roboAsalto, rcExtracontractual — which is the key that ties the policy to the master coverage catalog you saw in Block 1. When the underwriter builds a new plan, they aren't typing free text: they're selecting from this catalog, with controlled min/max limit and deductible rules."

**Emphasis points:**
- Coverage Code = business key, not free text.
- Consistency with Block 1: product → coverage template → InsurancePolicyCoverage.

**If something doesn't appear:**
- If clicking the node doesn't navigate: use tab 3 directly.
- If the Limit field appears as "SumInsured" or "InsuredValue" (data model variants): explain verbally "the English label is Sum Insured, at ALFA we label it as Límite Asegurado — it's configurable per profile".

---

### Step 2.5 — Transactions: Issuance and Endorsement (4 min)

**Click / navigation:**
1. Ctrl+Tab to tab 4 (`/lightning/o/InsurancePolicyTransaction/list`).
2. **Check the List View**: the dropdown at the top left of the list should say **"All"**. If it says **"Recently Viewed"** (frequent default), the list appears empty — click the dropdown → select **"All"**.
3. With "All" selected four rows are visible:
   - **POL-PYME-2026-0001 — Emisión**
   - **POL-PYME-2026-0001 — Endoso 001 Incendio**
   - **POL-PYME-2026-0001 — Renovación 2027** (covered in step 2.8)
   - **POL-PYME-2026-0001 — Solicitud de Cancelación** (covered in step 2.9)
4. Click the first: **POL-PYME-2026-0001 — Emisión**.
5. On screen: transaction detail with:
   - **Type**: Premium Payment
   - **Category**: Issuance
   - **Status**: Approved
   - Lookup to policy POL-PYME-2026-0001.
6. Go back with the browser arrow to the list. Click **POL-PYME-2026-0001 — Endoso 001 Incendio**.
7. On screen: detail with **Type = Endorsement**, **Category = Endorsement**, **Status = Approved**.

**What to say (talk track):**
> "Every event in a policy's lifetime — issuance, an endorsement, a cancellation, a renewal, a premium payment — is recorded as an **InsurancePolicyTransaction**. In this case we have four: the **original issuance** of the policy on June 1 categorized as Issuance, an **Endorsement 001** on the fire coverage categorized as Endorsement, a **planned renewal** for 2027 (Type=Renewal, we'll drill into it in a moment), and a **cancellation request** with a pro-rated refund (Type=Cancellation, we'll cover it too). All four transactions reference the policy via lookup. This gives ALFA complete audit: for any date in the lifecycle I can reconstruct what state the policy was in and why it changed."

**Emphasis points:**
- Transactional model = regulatory audit.
- Type + Category + Status = granular classification for reporting (useful for Block 6).

**If something doesn't appear:**
- If in the transaction detail the date fields are empty (EffectiveFromDate, TransactionEffectiveDate, PostedDate): **do NOT call it out**. Focus the narrative on Type/Category/Status. If the client specifically asks about dates, see Q&A in section 3.
- If TotalTransactionAmount shows 0: same treatment — don't draw attention to the field. In a real operation it would be populated from the billing system; for this demo the focus is transactional classification.
- If the list appears empty with "All" already selected: refresh (Cmd+R). If they still don't load, an alternative is to go to tab 1 (policy), Related tab, and explain that the default layout of the Insurance Agent Console doesn't expose this related list — but the data model supports it and a Lightning Record Page tweak is enough to display it there (see Gotcha #1).

---

### Step 2.6 — Clause set: AutoAdded vs Manual (5 min) — integrates Block 5 InsuranceClauses

**Click / navigation:**
1. Ctrl+Tab to tab 5 (`/lightning/o/InsurancePolicyProductClause/list`).
2. **Check the List View**: same as Transactions — if it says "Recently Viewed", change to **"All"**. With "All" the 6 clauses are visible.
3. On screen, the 6 rows:
   - Buena Fe (POL-PYME-2026-0001) — CreationMethod = AutoAdded
   - Actos Dolosos (POL-PYME-2026-0001) — AutoAdded
   - Guerra Terrorismo (POL-PYME-2026-0001) — AutoAdded
   - **Coaseguro 10% (POL-PYME-2026-0001) — Manual**
   - Actividades Extremas (POL-PYME-2026-0001) — AutoAdded
   - Deducible Mínimo (POL-PYME-2026-0001) — AutoAdded
4. Click **Buena Fe**. Show the detail: ClauseText with the insured's good-faith declaration. Go back.
5. Click **Coaseguro 10%** (or Ctrl+Tab to tab 6).
6. On screen: clause detail with **CreationMethod = Manual** clearly visible.

**What to say (talk track):**
> "This is the heart of the **clause engine** — what in some systems is a separate module, in Salesforce Insurance is native. When we issued the policy, the system **automatically copied five clauses** from the Pyme Integral product's template: Buena Fe, Actos Dolosos, Guerra y Terrorismo, Actividades Extremas and Deducible Mínimo. All are flagged with CreationMethod = AutoAdded, meaning they came from the product. And additionally, the underwriter **added a client-specific clause**, Coaseguro 10%, which you see with CreationMethod = Manual. This lets ALFA maintain a standard corporate clause set per product and, at the same time, negotiate specific exceptions per policy, with full traceability of what is standard and what was negotiated."

**Emphasis points:**
- 5 AutoAdded + 1 Manual = product/negotiation balance.
- The clause text (ClauseText) is persisted on the object — it isn't a pasted PDF, it's data.
- Regulatory audit: the Superintendencia can request at any time what clause set a policy had on a specific date, and this is the single source.

**If something doesn't appear:**
- If the list is slow: refresh. If it doesn't load, use tab 6 directly to at least show the Manual example.
- **IMPORTANT**: do NOT open the "Actividades Extremas" clause during the demo — its ClauseText contains the unresolved placeholder "Ninguna" ("Se excluyen operaciones con Ninguna salvo pacto..."). If the client specifically insists on that clause: mention that "the text you see is a template being refined; in production ALFA manages the final templates approved by legal".

---

### Step 2.7 — Consistency: back to the policy (2 min)

**Click / navigation:**
1. Go back to tab 1 (POL-PYME-2026-0001).
2. Click the **Details** sub-tab.
3. Show the full field block: Policy Name, Status, Policy Type = BOP (Business Owners), Effective Date, Expiration Date, Premium Amount, Name Insured.

**What to say (talk track):**
> "Closing the loop: the policy we started looking at a few minutes ago has behind it **one account, six coverages, four transactions, six clauses and two payment methods on file** — all on standard objects, all with native relationships, all queryable via SOQL or Salesforce reports. This is the point: **the full lifecycle of the policy lives in the core**, not in integrations or parallel custom tables. In a moment we'll show renewal, cancellation and the payment methods, and then we'll close with an architectural framing for the pieces that go beyond the native footprint."

**Emphasis points:**
- "In the core" — root message of ALFA's RFP (Insurance on Core).
- The same data feeds Block 3 (Claims) and Block 6 (Reporting), with no ETLs.

**If something doesn't appear:**
- If the Details tab doesn't show one of the fields: don't stop — they were already shown in the header in Step 2.1.

---

### Step 2.8 — Renewal (3 min)

**Click / navigation:**
1. Ctrl+Tab to tab 4 (`/lightning/o/InsurancePolicyTransaction/list`, "All").
2. With the 4 rows now visible, click **POL-PYME-2026-0001 — Renovación 2027**.
3. On screen: transaction detail with:
   - **Type**: Renewal
   - **Category**: Renewal
   - **Status**: Approved
   - **EffectiveDate**: 2027-06-01
   - **TransactionAmount**: 2,520,000 (a 5% increase over the original 2.4M for inflation)
   - **Description**: "Planned renewal for the 2027-2028 policy term…"
4. Ctrl+Tab back to tab 1 (POL-PYME-2026-0001) to keep the base policy in view.

**What to say (talk track):**
> "The renewal moment is also modeled as a transaction: **Type = Renewal, Category = Renewal**, effective June 1, 2027 with a **premium adjusted to 2.52 million pesos**, a 5% adjustment for inflation. In production, ALFA can trigger this transaction from a **scheduled Flow** — for example, 90 days before ExpirationDate the system automatically drafts the renewal transaction, kicks off an underwriting review if the profile has changed, and once approved, the transaction is confirmed. The original policy stays in force through May 31, 2027, and the renewal transaction defines the new term. In the audit trail, both terms live linked, referenceable side by side."

**Emphasis points:**
- Renewal = InsurancePolicyTransaction with Type=Renewal, native — not a custom module.
- Automatable via scheduled Flow + Approval Process (declarative, no code).
- Audit continuity: same policy, both terms linked.

**If something doesn't appear:**
- If the renewal transaction is not in the list: run script `03-block2-policy.sh` again (it's idempotent — creates it if missing).

---

### Step 2.9 — Cancellation (3 min)

**Click / navigation:**
1. Still on tab 4 (Transactions list "All"), click **POL-PYME-2026-0001 — Solicitud de Cancelación**.
2. On screen: transaction detail with:
   - **Type**: Cancellation
   - **Category**: Cancellation
   - **Status**: In Process (deliberately, so the demo can show the workflow moment)
   - **EffectiveDate**: 2026-12-01
   - **TransactionAmount**: **-1,200,000** (negative — pro-rated refund of unearned premium)
   - **Description**: "Customer-requested cancellation effective 2026-12-01 — pro-rated refund of unearned premium"
3. **Note (do not show live)**: the policy header still says Status = **In Force** — this is intentional for the demo. In production, once the cancellation is approved, the workflow flips `InsurancePolicy.Status = 'Cancelled'` and the `TerminatedDate` field. Here we keep the policy live so the rest of the demo (Block 3 claims) can still run.

**What to say (talk track):**
> "The cancellation flow is symmetric to the renewal. A customer request opens a **Cancellation transaction** — you see it here in Status = **In Process** because we simulate the approval moment. The transaction amount is **negative 1.2 million** — a pro-rated refund of unearned premium for the months from December to May that were paid in advance. Once the transaction goes to Approved status, a native Flow flips the policy's Status to Cancelled and sets the TerminatedDate. Native reversals — retention offers, reinstatement — are also modeled as transactions (Type = Reinstatement), so the entire lifecycle is on a single traceable timeline."

**Emphasis points:**
- Cancellation with **negative amount** = pro-rated refund, native financial calculation.
- Status "In Process" = supports approval workflows before the change takes effect.
- Reinstatement is another Type of the same object — same data model handles the reversal.

**If something doesn't appear:**
- If Status shows as "Approved" instead of "In Process": that's fine, the demo works either way — narrate as "already approved, ready to trigger the Status flip".

---

### Step 2.10 — Payment methods on file (2 min)

**Click / navigation:**
1. Ctrl+Tab to tab 2 (Account **Panadería La Espiga SAS**).
2. Click the **Related** tab of the account.
3. Scroll to find the **Card Payment Methods** related list (may be called Payment Methods depending on the org). Two records should appear:
   - **Visa **** 4242** — Corporate Visa, CreditCard, ExpiryMonth=12/2028, Active
   - **Mastercard **** 5555** — Backup Mastercard, DebitCard, ExpiryMonth=6/2027, Active
4. Click **Visa **** 4242** to open the detail.
5. On screen: `CardPaymentMethod` record with **AccountId** linked to Panadería, **CardCategory = CreditCard**, **CardLastFour = 4242** (tokenized, never the full PAN), **ProcessingMode = ExternalRecurring**.

**What to say (talk track):**
> "Payment methods live as standard sObjects — `CardPaymentMethod` for cards, `AlternativePaymentMethod` for digital wallets or bank accounts — associated to the Account. **The full card number is never persisted**: only the tokenized last four, in line with PCI-DSS. The insured can register multiple methods on file, and each active method is a candidate for the payment schedule associated to the policy. `ProcessingMode = ExternalRecurring` tells the system this method can be used for recurring premium charges, which is exactly the Pyme scenario — an annual policy with quarterly or monthly premium collection depending on the plan."

**Emphasis points:**
- Standard sObject, PCI-compliant (no PAN stored).
- Multiple methods per Account, each with a role (primary / backup).
- The link to the collection scheduling logic is via `PaymentAuthorizationAdjustment` / `PaymentScheduleItem` — see Section 6 for architecture.

**If something doesn't appear:**
- **If `CardPaymentMethod` is not enabled on the org**: the script skipped this section with a warning. In that case explain conceptually: "In this org the Payments module isn't provisioned, but the object is standard on any org with the Salesforce Payments PSL. It stores the tokenized method — never the full card number — linked to the Account".
- If the related list isn't on the Account layout: use the direct URL `/lightning/o/CardPaymentMethod/list` and filter by AccountId.

---

### Step 2.11 — Block close (30 sec)

**What to say (talk track):**
> "That closes the policy lifecycle. In 45 minutes we walked through issuance, coverage structure, endorsement transactions, planned renewal, cancellation with pro-rated refund, clause set with auto-added and manual clauses, and payment methods on file — all on standard objects. Everything you saw is queryable, auditable, and native. Before jumping to Claims, in the next 5 minutes I'll walk through **how the pieces that don't have native OOTB coverage — recurring collection schedules, retry logic, bank file generation — are addressed architecturally**. Then we open Block 3."

---

## 3. Anticipated client questions

| Likely question | Prepared answer |
|---|---|
| Why do I only see one policy if the RFP mentioned three accounts (Panadería, Ferretería, Consultores)? | "Good catch. The three accounts are created as Accounts in the org and are the ones in the RFI. For this presentation **we issued one end-to-end policy** against Panadería La Espiga so we could show you the full lifecycle with coherent data: coverages, transactions, clauses and linked claims. The other two accounts are ready to be the workshop exercise afterwards if you're interested, and the issuance process is exactly the same one you'll see applied on this one." |
| The Transactions don't show a date or amount — how does it work in production? | "The InsurancePolicyTransaction object has native fields for **TransactionEffectiveDate, EffectiveFromDate, PostedDate and TotalTransactionAmount**. In a production implementation these fields are populated from the issuance system or billing via standard integration. In this demo dataset we prioritized showing the **transactional classification** (Type = Premium Payment/Endorsement, Category = Issuance/Endorsement, Status), which is what enables regulatory traceability. Date and amount are standard object fields, ready to be populated." |
| How do you guarantee that if I edit a coverage, the total policy premium is recalculated? | "There are two paths, both out-of-the-box: (a) a **declarative Flow** that fires on after-update of InsurancePolicyCoverage and rolls up to the parent — this is the pattern we suggest because it's no-code; (b) a **rollup summary** if allowed on the object. In addition, for issuance and endorsement, the natural process is that a **Product Configurator** — Flow or Omniscript — rebuilds the premiums and creates a new InsurancePolicyTransaction of Endorsement, leaving an audit of the change." |
| Can I add a clause that's not in the product catalog? | "Yes. You saw Coaseguro 10% flagged as CreationMethod = **Manual**: that's exactly the case. The underwriter has permission to add ad-hoc clauses to a policy, and they're differentiated from AutoAdded for governance reporting. If the clause becomes recurring across many policies, you promote it to the product catalog (ProductClause) and from there it flows automatically into new issuances." |
| What about historical clause sets? If a clause changes in the product in 3 years, are active policies affected? | "No. Each InsurancePolicyProductClause is a **snapshot at the time of issuance** — the ClauseText is persisted on the policy's record. If tomorrow legal modifies the clause on the master product, that modification applies only to **new issuances**; already-issued policies keep the clause set effective on their issuance date. This is a typical regulatory requirement in Colombia and the standard model supports it." |
| Does issuance support group policies (multiple insureds under a single policy)? | "Yes, and it's a common question. The standard Salesforce Insurance model includes the **InsurancePolicyParticipant** object for multiple insureds/beneficiaries with differentiated roles (Named Insured, Additional Insured, Beneficiary, etc.). **In this demo dataset we didn't populate it** because the Pyme policy you're seeing has a single named insured, which is the bakery; the block's focus is end-to-end lifecycle on a single holder. If you're interested in the group policy scenario — group life, group health — we can put together a dedicated walkthrough in the follow-up workshop with data populated in InsurancePolicyParticipant. The object and its support are in the standard data model, no changes required." |
| How does this data connect to ALFA's current issuance system? | "Three options depending on the target state: (a) **MuleSoft** to connect the legacy issuance core via APIs — the pattern Salesforce recommends for the ALFA ecosystem; (b) **Data Cloud** if you also need to unify Customer 360 and federate calculations; (c) full migration to the core with **Financial Services Cloud + Insurance**, which is the RFI scenario. Any of the three respects the data model you're seeing." |
| Where do I see Transactions and Clauses from the policy? They don't show up in Related now. | "Correct, good eye. The **Lightning Record Page** of the Insurance Agent Console comes with a default layout that doesn't expose those two related lists — it's a UX decision of the standard template. With **Lightning App Builder** — clicks, not code — we add both related lists to the InsurancePolicy layout and they show up next to Coverages. It's a 5-minute task that in a real implementation we do in sprint 0." |

---

## 4. Transition to the next block

> "Perfect. We saw that the policy is live, with six coverages, four transactions (issuance, endorsement, renewal, cancellation request), six clauses and two payment methods on file. The natural next question is: what happens when a claim occurs against this policy? That's exactly **Block 3**: we'll open an incident against Panadería La Espiga and see the flow from FNOL to payment, triggered against one of the policy's coverages. Luis, switch to the next tab."

**Note to Luis (do not read out loud)**: in the original script the transition explicitly named the "fire coverage". The Block 3 runbook may point to Equipo Electrónico (an oven / equipment claim) instead of Incendio. To avoid contradictions live, this transition **does not name the specific coverage** — it just says "one of the coverages". Block 3 opens with the claim detail and names the correct coverage there. In step 0.2 the mapping must be confirmed before kickoff.

---

## 5. Architecture and extensions — beyond the native lifecycle

*This section is designed to answer the questions the presenting SE flagged that go beyond what Digital Insurance covers out of the box: recurring collection by payment method, per-sponsor scheduling parameters, retry logic, payment method updates, integration surface, mass file ingest, and bank file generation. Deliver these transparently — the platform doesn't ship all of them as OOTB features on Digital Insurance itself, but each has a clear, supported extension path.*

### 5.1 Native vs. extension map (share this table if the client asks)

| Requirement | Native in Digital Insurance | Extension path |
|---|---|---|
| Renewal | ✅ `InsurancePolicyTransaction.Type=Renewal` + optional scheduled Flow | — |
| Cancellation with pro-rated refund | ✅ `InsurancePolicyTransaction.Type=Cancellation` + negative amount | — |
| Endorsement (mid-term change) | ✅ `InsurancePolicyTransaction.Type=Endorsement` | — |
| Reinstatement | ✅ `Type=Reinstatement` / `Type=Reinstatement by Payment Schedule` | — |
| Payment methods on file (card, bank) | ✅ `CardPaymentMethod`, `AlternativePaymentMethod` (Salesforce Payments PSL) | — |
| Update / replace payment method | ✅ Standard record update on the payment method sObject | — |
| Recurring collection schedule by method (savings 2x/day, credit card 2x/week) | ⚠️ Not native to Digital Insurance | (a) **Salesforce Billing** (managed package, adds `BillingSchedule` + payment runs), (b) **Revenue Lifecycle Management** (`PaymentSchedule` + `PaymentScheduleItem` — see 5.2), (c) custom Apex batch + custom object per sponsor |
| Per-sponsor collection parameters | ⚠️ Not native | **Custom Metadata Types** with a "Sponsor" record type — declarative, no code, versionable per environment |
| Retry logic on payment failures | ⚠️ Partial (via gateway response) | `PaymentScheduleItem.PaymentRetryCount` + `NextPaymentRetryTime` (RLM) + custom Flow for retry policy — see 5.3 |
| Integration with the bank / gateway | ⚠️ Architecture — no OOTB | **MuleSoft** for API mediation, **Platform Events** for async choreography, **External Services** for point-to-point |
| Mass file ingest (payments received from bank) | ✅ Bulk API / Data Loader / Data Import Wizard | — |
| Mass bank file generation (payment order to bank) | ⚠️ Not native | Custom Apex + **Files** (`ContentVersion`) for text/XML/CSV, or **MuleSoft** for direct SFTP delivery |

### 5.2 Recurring collection scheduling (the "cobranza calendarizada" question)

Digital Insurance itself doesn't ship a collection scheduler that runs "savings account 2x/day, credit card 2x/week". That level of scheduling logic is in **Revenue Lifecycle Management (RLM)** — same license family the customer already has enabled for the Quote + Product Configurator in Block 1.

Model:

```
InsurancePolicy 1───n InsurancePolicyTransaction (Premium Payment)
                       │
                       └── links to a PaymentSchedule
                             │
                             └── PaymentScheduleItem (one per due date)
                                   ├── PaymentMethodId → CardPaymentMethod / AlternativePaymentMethod
                                   ├── NextPaymentRetryTime
                                   ├── PaymentRetryCount
                                   └── PaymentGatewayErrorCategory
```

Sponsor-specific rules (e.g., "corporate group X collects debit card holders on Mondays and Thursdays") are held in **Custom Metadata Types** with one record per Sponsor. A single Flow reads the CMT record for the sponsor, computes the next due date, and inserts `PaymentScheduleItem` rows. Because CMT is declarative, ALFA's ops team can maintain sponsor parameters without a developer, and the config travels between sandboxes/production via metadata deployments.

### 5.3 Retry logic

RLM's `PaymentScheduleItem` object comes with the retry fields already declared:

- `PaymentRetryCount` — increments on each failed attempt
- `NextPaymentRetryTime` — when the next attempt is scheduled
- `PaymentGatewayErrorCategory` — categorized reason for failure (`CardLimit`, `GatewayConnection`, `Security`, `ValidationFailure`, etc.)

The retry policy itself is declarative: a **Flow** that reads `PaymentGatewayErrorCategory` decides whether to retry (transient errors), route to a case for manual intervention (validation errors), or cancel the scheduled item and notify the customer (security / permanent errors). This is the pattern Salesforce recommends over hardcoding retry logic in Apex — the Flow surfaces the policy visually to the ops team.

### 5.4 Integration surface

| Integration pattern | When to use | Salesforce building block |
|---|---|---|
| Sync REST call to payment gateway | Low-volume, response-time-critical (charge a card) | **External Services** or Named Credentials + Apex callout |
| Async event delivery to legacy core | Fire-and-forget policy state changes | **Platform Events** or Change Data Capture |
| Batch daily file exchange with bank | Nightly settlement / reconciliation | **MuleSoft** for orchestration + SFTP, or Apex Scheduled + `ContentVersion` for the file |
| Federated customer data across systems | Unified 360 without full migration | **Data Cloud** |

For ALFA's target state, the recommended pattern is MuleSoft mediating the bank / gateway APIs, with Platform Events used to broadcast policy state changes to the legacy issuance system during transition.

### 5.5 Mass file ingest (payments coming FROM the bank)

Salesforce already supports this natively — no custom code needed for typical use cases:

- **Data Loader** or **Data Import Wizard** for one-shot imports
- **Bulk API 2.0** for automated pipelines (MuleSoft can call this)
- **Custom Metadata + Flow** to map bank-specific file formats to `InsurancePolicyTransaction` / `PaymentScheduleItem` records at ingest time

### 5.6 Mass file generation (payment orders TO the bank)

This is where custom code enters, but only lightly:

- A **Scheduled Apex** batch runs nightly, queries the `PaymentScheduleItem` records due that day, and writes them into a `ContentVersion` (Salesforce File) in the bank's expected format (typically CSV or an XML dialect like ISO 20022 pain.001).
- The file is either delivered via SFTP by MuleSoft, or pushed via a REST endpoint if the bank supports it.
- Every generated file is stored on the `Account` (or a dedicated `BankFileBatch__c` custom object) for traceability.

Typical build size: **1 Apex class + 1 Custom Metadata Type for the bank format + 1 Scheduled Flow trigger**. About 2-3 sprint days including tests.

### 5.7 Prepared answer if the client presses hard on cobranza

> "The full lifecycle up to the cancellation transaction lives on standard objects, native. The **recurring collection scheduling per method and per sponsor** is not part of the Digital Insurance native footprint — it's part of the Revenue Lifecycle Management license family, which the customer's IDO already has. So the architecture we recommend is: keep every event **on the policy transaction timeline** (Digital Insurance), delegate the **when-to-charge / how-to-retry** to RLM's `PaymentSchedule`, and hold sponsor-specific parameters in **Custom Metadata Types** so the ops team can change them without a release. If you want to see the concrete data model, we can drill in during the follow-up workshop."

---

## 6. General block fallbacks

### Gotcha #1 — Transactions/Clauses related list not visible on the default layout
- **Symptom**: on the InsurancePolicy Related tab only Coverages (6 rows) appear. No Transactions or Clauses.
- **Cause**: the Insurance Agent Console's Lightning Record Page comes with a default standard template layout.
- **Live Plan B**: use pre-opened tabs 4 and 5 (direct list views). Explain verbally that "in a real implementation you add the related list to the layout in 5 minutes with Lightning App Builder".
- **Do NOT try to fix it live** — it's a post-demo tweak, already on the improvements list.

### Gotcha #2 — Empty date/amount fields on Transactions
- **Symptom**: when opening POL-PYME-2026-0001 — Emisión, the TransactionEffectiveDate, EffectiveFromDate, PostedDate fields are empty and TotalTransactionAmount = 0.
- **Plan B**: don't draw attention to those fields; focus on Type/Category/Status. Pre-built answer in Q&A (second row of the table).

### Gotcha #3 — "Ninguna" placeholder in Actividades Extremas
- **Symptom**: if the "Actividades Extremas" clause is opened, the ClauseText contains "Se excluyen operaciones con Ninguna salvo pacto...".
- **Plan B**: don't open that clause in the standard flow (Step 2.6 says which clauses to open: Buena Fe and Coaseguro 10%). If the client specifically requests it: answer "the text is a template being refined; in production it's approved by legal".

### Gotcha #4 — English locale
- **Symptom**: standard Salesforce labels come out in English (Status, Effective Date, Premium Amount, etc.).
- **Plan B**: when an English label appears, say its Spanish equivalent in the narration ("Effective Date, i.e., Fecha de Inicio"). The client knows it's a user profile setting and not a product issue — mention it the first time it appears and move on. Do NOT start changing the user's language live.

### Gotcha #5 — Expired session
- **Symptom**: on click the login screen appears.
- **Plan B**: re-authenticate quickly. Meanwhile, keep narrating (architecture, data model) until the session returns. Never leave the screen silent for more than 15 seconds.

### Gotcha #6 — A component doesn't load (infinite loading)
- **Plan B**: refresh with Cmd+R. If it persists, close the tab and open with the direct URL (all URLs are in section 0.3).

### Gotcha #7 — Client asks "show me the 3 customers with policies"
- **Symptom**: question about the 3 RFP accounts.
- **Plan B**: pre-built answer in Q&A (first row). The honest "we issued one end-to-end policy to show the full cycle with coherent data" is stronger than improvising.

### Gotcha #8 — List View on "Recently Viewed" (empty list)
- **Symptom**: when opening tabs 4 (Transactions) or 5 (Clauses), the list appears empty even though the data exists.
- **Cause**: the default List View in Salesforce Lightning is often "Recently Viewed", which only shows records visited in the current session. If no one visited them, it appears empty.
- **Plan B**: click the List View dropdown at the top left → select **"All"**. Pin it with the star if the UI allows so it persists.
- **Prevention**: do this in the pre-demo setup (step 0.4) — don't hit this moment live.

### Gotcha #9 — Coverage mapping confusion (Incendio vs Equipo Electrónico)
- **Symptom**: Luis opens the coverage expecting "Incendio y Aliados" and gets "Equipo Electrónico" (or vice versa), breaking the narrative thread or the connection to Block 3.
- **Cause**: the IDs are long and visually similar (0cYg80000000KErEAM vs 0cYg80000000KGTEA2); if someone touched the data in the org or if the Block 3 runbook points to a different ID than assumed, there is a conflict.
- **Plan B**: in step 0.2 the mapping is confirmed before kickoff. If live Luis opens a coverage and the name does NOT match the expected, **don't force it** — say "let's look at another of the coverages" and navigate through Policy Structure to the one intended (by visible name, not by ID).
- **Prevention**: the transition to Block 3 (section 4) does NOT name the specific coverage, so Block 3 can name it correctly when it opens.

### Gotcha #10 — Client asks about group policies / InsurancePolicyParticipant
- **Symptom**: client asks whether the model supports multiple insureds/beneficiaries and wants to see it on screen.
- **Plan B**: Q&A has the prepared answer. **Be honest**: the InsurancePolicyParticipant object exists in the standard data model, but **there is no populated data in this org** to show it live. Don't invent navigation. Offer a dedicated walkthrough in the follow-up workshop.

---

## 7. Block success metrics

At the end of the block, the ALFA audience (technology + business) should leave with these seven convictions:

- [ ] The policy lives in a standard object (**InsurancePolicy**), not on a custom object.
- [ ] Coverages are modeled as child records (**InsurancePolicyCoverage**), with structured limit, deductible and premium — and the sum matches the policy premium (2,400,000 COP: 800+600+400+300+200+100).
- [ ] Every lifecycle event (issuance, endorsement, **renewal, cancellation**, payment) generates an **InsurancePolicyTransaction**, providing regulatory traceability.
- [ ] Renewal and cancellation are **not custom modules**: they are native `InsurancePolicyTransaction.Type` values with the same audit rules as the rest of the lifecycle.
- [ ] Payment methods live as PCI-compliant standard sObjects (**CardPaymentMethod**, **AlternativePaymentMethod**) — never storing the full PAN, always tokenized.
- [ ] The clause set is automatically copied from the product (AutoAdded) and admits negotiated per-policy clauses (Manual), with an immutable snapshot at the time of issuance.
- [ ] The entire lifecycle relies on **Account** as the single source of customer truth — enabling a 360 view with sales, service and claims.
- [ ] Requirements that go beyond the native footprint (recurring collection schedules, per-sponsor rules, retry logic, bank file generation) have a **clear, supported extension path**: RLM `PaymentSchedule` + Custom Metadata + MuleSoft — not a rebuild.

If any of the points isn't clear during the block, leverage the Q&A, section 5 (architecture) or the transition to Block 3 to reinforce it before moving on.

---

**End of Runbook — Block 2**
