# Runbook — Block 3: Claims

**Duration**: 45 min | **Presenter**: the presenting SE | **Org**: ins-qbranch-alfa
**Demo date**: 2026-07-09 | **Client**: Seguros ALFA (Bogotá, Colombia)
**Instance**: https://storm-c90aab66569c63.my.salesforce.com

> **Note to Luis**: this runbook assumes you don't know Digital Insurance in depth. Each step tells you what to click and what you should see. The quoted talk track is a sample script — read it aloud in Spanish for actual delivery, adapting as needed. The org is in `en_US`, so many labels appear in English; contextualize verbally in Spanish (e.g., "Coverage Confirmed" = "Cobertura Confirmada").

---

## 0. Pre-demo setup (5 min before starting Block 3)

While the Block 2 presenter is wrapping up, prepare these browser tabs (Chrome, presentation-mode window, zoom 100%):

**Tab 1 — Main Claim (this is the "home" tab):**
```
https://storm-c90aab66569c63.my.salesforce.com/lightning/r/Claim/0Zkg80000000awLCAQ/view
```

**Tab 2 — ClaimCoverage Incendio (for Phase 5):**
```
https://storm-c90aab66569c63.my.salesforce.com/lightning/r/ClaimCoverage/0kPg80000000OITEA2/view
```

**Tab 3 — CCPD-01 Horno Pagado (for Phase 4):**
```
https://storm-c90aab66569c63.my.salesforce.com/lightning/r/ClaimCoveragePaymentDetail/0l2g80000000PfxAAE/view
```

**Tab 4 — CCPD-02 Lucro Cesante Pendiente Autoridad (for Phase 4):**
```
https://storm-c90aab66569c63.my.salesforce.com/lightning/r/ClaimCoveragePaymentDetail/0l2g80000000PhZAAU/view
```

**Tab 5 — Policy from Block 2 (for the cross-link in Phase 5):**
```
https://storm-c90aab66569c63.my.salesforce.com/lightning/o/InsurancePolicy/list
```
Filter by `POL-PYME-2026-0001` and open it — you'll use it to show the policy→claim link.

**Quick checklist before speaking:**
- [ ] You're logged in as the demo user (the same user that ran `04-block3-claim.sh` — the script sets `Claim.OwnerId` to whoever executed it). If a different user is logged in, switch the "My Claims" filter to "All Claims" so the claim still shows up.
- [ ] Tab 1 shows the Claim header with `SIN-PYME-2026-0001` and Status = **Coverage Confirmed**.
- [ ] Tab 2 shows the ClaimCoverage `CC-SIN-PYME-2026-0001-Incendio` with Loss Reserve = **45,000,000** and Expense Reserve = **5,000,000**.
- [ ] The **Insurance Agent Console** app is loaded in the App Launcher (the same one Block 2 already left open).
- [ ] Notifications/Slack/email silenced. "Do not disturb" mode on.

If something doesn't load: refresh (Cmd+R). If it still fails, go directly to the **5. General fallbacks** section at the end of the runbook.

---

## 1. Context and objective of the block (1 min)

**Sample talk track:**

> "Perfect, thank you [previous presenter's name]. With policy `POL-PYME-2026-0001` already issued in Block 2, now we're moving to what the policyholder actually experiences when something bad happens: the **claim**.
>
> Over the next 45 minutes I'll show you the end-to-end lifecycle of a real claim on Insurance on Core — the same platform you already saw. No system switching, no data duplication, no middleware integrations. The claim is directly linked to the policy we just issued.
>
> The case: **Panadería La Espiga SAS**, a Pyme customer in Bogotá, reports a fire on September 10, 2026. Initial estimated damage: 48 million pesos. We'll walk through:
>
> 1. How the claim was opened and its current status.
> 2. The participants involved — insured, adjuster and witness.
> 3. The damaged items the customer claimed.
> 4. The financial side: reserves, executed payments and payments awaiting authorization.
> 5. The direct link with the policy coverage.
> 6. How the lifecycle closes and what additional automation Agentforce can layer on top.
>
> Every data point you'll see is running on the product's standard model — there are no custom objects for this demo."

**Emphasis points:**
- "End-to-end on Insurance on Core" (repeat it, it's the RFP's core message).
- "No custom objects" — the client has already asked this several times in prior sessions.
- Don't promise Agentforce running live in this block; it's only mentioned at the close.

---

## 2. Step-by-step click path

### Phase 1 — Claim context (5-7 min)

**Objective**: get the client to understand which claim we're looking at, its status, and who manages it.

**Step 1.1** — Go to Tab 1 (main Claim).

**You'll see:**
- Header with name `SIN-PYME-2026-0001`.
- Highlights panel with key fields (Claim Type, Status, Severity, etc.).
- Below, the tabs: **Related**, **Details**, **Financials**, **Participants**, **Claim Team**, **Action Plan**.

**Sample talk track:**
> "This is claim `SIN-PYME-2026-0001`. Notice the highlights panel — every data point the adjuster needs to start working the case is on the first screen, without scrolling."

**Step 1.2** — Click the **Details** tab.

**You'll see fields:**
- **Claim Type**: `Fire/Smoke Damage`
- **Status**: `Coverage Confirmed`
- **Severity**: `High`
- **Loss Type**: `Partial Loss`
- **Estimated Amount**: `$48,000,000`
- **Loss Date**: `9/10/2026`
- **Owner**: the demo user who ran `04-block3-claim.sh` (Claim.OwnerId is set dynamically to the current authenticated user)

**Sample talk track:**
> "The fields you see — `Claim Type`, `Status`, `Severity`, `Loss Type`, `Estimated Amount` — are all from the standard Insurance on Core model. In Spanish they'd be: Tipo de Siniestro `Incendio/Daño por humo`, Estado `Cobertura Confirmada`, Severidad `Alta`, Tipo de Pérdida `Pérdida Parcial`, Monto Estimado `48 million pesos` and Fecha del Siniestro `September 10`.
>
> The `Coverage Confirmed` status means we've already cleared the initial FNOL stage — First Notice of Loss — and validated that the policy covers the event. We're now in the adjustment phase."

**Emphasis points:**
- Read the English label, but translate it verbally on the side.
- "FNOL" — abbreviate; you've said it once, use "aviso" in Spanish afterwards.

**Fallback if Details doesn't show everything:**
- Refresh the page (Cmd+R).
- If still missing, go to the direct Details layout URL — or navigate via **Setup → Object Manager → Claim → Page Layouts** to confirm the assigned layout (only if indispensable; avoid doing this in front of the client).

**Step 1.3** — Briefly explain how the claim got here.

**Sample talk track:**
> "The insured can report the claim through several channels — the same model supports FNOL from:
> - An Experience Cloud portal, if Seguros ALFA offers self-service to its customers.
> - A contact center — the agent creates the Claim from the Insurance Agent Console, the same one I'm using.
> - API integration if you have an external digital channel, for example the Aval mobile app.
> - And, very relevant for the RFP, from an Agentforce conversational assistant that handles intake by chat or WhatsApp. I'll show that part at the close."

**Don't click on anything here** — this is narrative. We don't have Agentforce FNOL configured in the org.

---

### Phase 2 — Participants (7-10 min)

**Objective**: show the multi-role model and how a single Claim manages insured, adjuster and witness — without custom extensions.

**Step 2.1** — From the Claim, click the **Participants** tab.

**You'll see**: a list with 3 records:
- `Claimant` — Panadería La Espiga SAS
- `Loss Adjuster` — Alan Reed
- `Witness` — Cuerpo de Bomberos de Bogotá

**Sample talk track:**
> "Here's something key about the standard model: any person or company that participates in the claim is registered as a `ClaimParticipant` with a role. We don't create separate objects for insured, adjuster or witness. The same participant can hold multiple roles if needed, without duplicating the record."

**Step 2.2** — Click the first participant, `Claimant`.

**You'll see:**
- **Roles**: `Claimant`
- **Participant Account**: `Panadería La Espiga SAS` (link to the Account)

**Sample talk track:**
> "The Claimant is the insured Account from Block 2 — the same Panadería against which we issued the policy. No data replication: the CRM already has the customer 360, and the claim connects by reference."

**Step 2.3** — Click the **Panadería La Espiga SAS** link to jump to the Account. Show for 3 seconds that the Account exists with its commercial data. Then click the browser's "Back" button to return to the ClaimParticipant.

**Sample talk track (while going back):**
> "Notice this: the sales team sees the same customer as the Account, and the claims team sees it as Claimant. Same source of truth."

**Step 2.4** — Click "Back" in the browser (or Tab 1 to return to the Claim) → **Participants** tab → click `Loss Adjuster`.

**You'll see:**
- **Roles**: `Loss Adjuster`
- **Participant Contact**: `Alan Reed`

**Sample talk track:**
> "The adjuster `Alan Reed` is registered as a Contact — he can be internal to Seguros ALFA or a third-party outsourced adjuster. The model supports either. If external, you can grant access via Experience Cloud to an adjuster portal so they upload photos, reports and appraisals without needing an internal core license."

**Step 2.5** — Back to the Claim (Tab 1) → **Participants** tab → click `Witness`.

**You'll see:**
- **Roles**: `Witness`
- **Participant Account**: `Cuerpo de Bomberos de Bogotá`

**Sample talk track:**
> "And the witness here is the Fire Department, registered as an Account because it's an entity. It could also be a Contact if it were a natural person. The standard model accepts both — same `ParticipantAccount` or `ParticipantContact` field as applicable."

**Emphasis points:**
- "Standard model, no custom objects" — say it explicitly here.
- Multi-role: you can add more roles to the same Contact (e.g., a witness who later becomes a beneficiary).

**Fallback if the Participants tab doesn't appear:**
- Go directly by URL: `/lightning/r/ClaimParticipant/0aSg8000000LNXtEAO/view` (Claimant), then `/0aSg8000000LNb7EAG/view` (Adjuster), `/0aSg8000000LNcjEAG/view` (Witness).
- If the layout is different, show the same IDs and explain they are ClaimParticipants with different roles.

---

### Phase 3 — Claim Items (7-10 min)

**Objective**: show the detail of the claimed items and how each item connects to a policy coverage.

**Step 3.1** — Back to the Claim (Tab 1) → **Related** tab → scroll to the **Claim Items** section (may also be labeled "Related Claim Items" depending on layout).

**You'll see 3 records:**
- `Horno Industrial Rational SCC-102`
- `Estanteria Metalica`
- `Lucro Cesante 5 dias`

**Sample talk track:**
> "The claim has three claimed items. Each one is a `ClaimItem` — again, the standard model. Let's go one by one."

**Step 3.2** — Click `Horno Industrial Rational SCC-102`.

**You'll see:**
- **Category**: `Damaged Property`
- **Fault Date**: `9/10/2026`
- **Insurance Policy Coverage**: link to `Incendio y Aliados` (the policy coverage from Block 2)

**Sample talk track:**
> "This is the industrial oven that burned. The `Damaged Property` category indicates it's a physical asset affected. Notice the `Insurance Policy Coverage` field: it points directly at the Incendio y Aliados coverage on the policy we already issued in Block 2. That's the end-to-end traceability you're looking for: the claim item knows exactly which coverage on which policy backs it."

**Step 3.3** — Back to the Claim (Tab 1) → **Related** tab → Claim Items section → click `Estanteria Metalica`.

**You'll see:**
- **Category**: `Damaged Property`
- **Fault Date**: `9/10/2026`
- **Insurance Policy Coverage**: link to another policy coverage

**Sample talk track:**
> "The metal shelving is also damaged property, same date. This item points to another coverage on the policy — because a multi-risk Pyme policy has multiple coverages, and each affected item is linked to the one that applies."

**Step 3.4** — Back to the Claim → Claim Items section → click `Lucro Cesante 5 dias`.

**You'll see:**
- **Category**: `Damaged Property`
- **Fault Date**: `9/10/2026`

**Sample talk track:**
> "The third item is `Lucro Cesante 5 días` (business interruption, 5 days). The bakery was closed 5 days while the premises were repaired. In business terms, this isn't physical property — it's lost profit — but for the standard model we register it as a ClaimItem with the corresponding business interruption coverage. In a production implementation we could tune the category picklists to have an explicit `Business Interruption` value. That's configuration, not development."

**Emphasis points:**
- Every ClaimItem knows its `InsurancePolicyCoverage` — that's the link guaranteeing that only what the policy covers gets paid.
- The `Category` picklist is configurable — if the client asks why "Damaged Property" on Lucro Cesante, you have the answer.

**Fallback if you don't see Claim Items in the Related tab:**
- Direct URL to filtered list: `/lightning/o/ClaimItem/list` — filter by `Claim = 0Zkg80000000awLCAQ`.
- Direct URLs for each item:
  - Oven: `/lightning/r/ClaimItem/0dqg80000000UpJAAU/view`
  - Shelving: `/lightning/r/ClaimItem/0dqg80000000UqvAAE/view`
  - Business Interruption: `/lightning/r/ClaimItem/0dqg80000000UsXAAU/view`

---

### Phase 4 — Financials: Reserves and Payments (10-12 min)

**Objective**: show the part the client will challenge the most — how technical reserves, payment authorizations and the claim's financial status are handled.

**Step 4.1** — Back to the Claim (Tab 1) → **Financials** tab.

**You'll see sections:**
- **Claim Coverages** — with `CC-SIN-PYME-2026-0001-Incendio`
- **Payment Summary** — with `PaymentSummary-SIN-PYME-2026-0001`
- (Depending on layout) reserves and aggregated amounts

**Sample talk track:**
> "In Financials we see the heart of the claim's technical and financial control. Two blocks: the **Claim Coverages** — the financial mirrors of the policy coverages — and the **Payment Summary**, which aggregates executed payments."

**Step 4.2** — Click the ClaimCoverage `CC-SIN-PYME-2026-0001-Incendio` (or switch to Tab 2 where you already have it open).

**You'll see fields:**
- **Internal Reserve Mode**: `CoverageReserve`
- **Loss Reserve Amount**: `$45,000,000`
- **Expense Reserve Amount**: `$5,000,000`
- **Total Claimed Amount**: `$40,000,000`
- **Total Adjusted Amount**: `$32,000,000`

**Sample talk track:**
> "This is the `ClaimCoverage` record — the link between this claim and the Incendio y Aliados coverage on the policy. Technical control lives here:
>
> - **Loss reserve**: 45 million. What the actuary/adjuster technically estimates the direct indemnity for the damaged items will cost.
> - **Expense reserve**: 5 million. Related costs — appraisals, fees, handling expenses, business interruption.
> - **Total Claimed**: 40 million. What the customer formally requested in their claim.
> - **Total Adjusted**: 32 million. What the adjuster ruled as valid after the appraisal.
>
> The `Internal Reserve Mode = CoverageReserve` field is important: it means the reserve is controlled at the coverage level, not at each item level. This is consistent with Seguros ALFA's actuarial practice and with what the SFC requires for technical reporting."

**Emphasis points:**
- Technical reserves = SFC regulatory topic. The client will ask.
- The gap between `Total Claimed` and `Total Adjusted` is the adjustment "gap" — very useful as a metric.

**Step 4.3** — On the same ClaimCoverage → **Related** tab → **Reserve Adjustments** section (may appear as "Claim Coverage Reserve Adjustments").

**You'll see 2 records:**
- `Reserva perdida directa Incendio` — Adjustment Amount `$45,000,000`
- `Reserva gasto lucro cesante` — Adjustment Amount `$5,000,000`

**Sample talk track:**
> "The coverage reserve isn't a magic number — it's built from traceable adjustments. You can see the two movements that brought the reserve to a total of 50 million:
>
> - `Reserva perdida directa Incendio`: 45 million. Justification is in the Reason field — 'Reserve based on initial appraisal: oven + shelving'.
> - `Reserva gasto lucro cesante`: 5 million. Reason: 'Reserve for 5-day business interruption'.
>
> Every reserve movement is recorded with who did it, when, and why. This is fundamental for internal audit and reporting to the Superintendencia Financiera. In real lifecycle, if the appraisal refines the number, another `ClaimCovReserveAdjustment` is created — you don't rewrite the number, you add an adjustment. Complete traceability."

**Emphasis points:**
- IBNR / under-reserving / technical sufficiency — the client may ask. Quick answer: more adjustments are added to reflect estimation changes.
- The adjustment history is the audit-ready evidence.

**Step 4.4** — Back to the Claim (Tab 1) → **Financials** tab → click `PaymentSummary-SIN-PYME-2026-0001`.

**You'll see:**
- **Payment Status**: `Pending Payment`
- **Payment Amount**: (empty / null)

**Sample talk track:**
> "The `Claim Payment Summary` is the consolidated view of payments for this claim. Current status: `Pending Payment` — payments pending finalization.
>
> A technical note: `Payment Amount` at the summary level is aggregated per configuration rules; for this demo we left it open to show the actual detail, which is what's interesting — the `Claim Coverage Payment Detail`."

> **Note to Luis** — `PaymentAmount` comes null at the summary level. If the client notices and asks, say literally: "In production you configure a rollup summary or a flow that aggregates CCPDs with `PaymentStatus = Paid`. Here we left it open so you can see the transactional detail, which is where the accounting truth lives."

**Step 4.5** — Switch to Tab 3 (CCPD-01 Horno Pagado) or navigate from the ClaimCoverage → Related → **Payment Details**.

**You'll see CCPD-01:**
- **Name**: `CCPD-01 Horno Pagado`
- **Type**: `Loss`
- **Status**: `Paid`
- **Payment Status**: `Paid`
- **Claimed Amount**: `$32,000,000`
- **Adjusted Amount**: `$32,000,000`

**Sample talk track:**
> "This is an executed payment. The industrial oven was adjusted to 32 million and has already been paid to the insured. Type `Loss` — direct indemnity. Status `Paid`. Closed transaction."

**Step 4.6** — Switch to Tab 4 (CCPD-02 Lucro Cesante Pendiente Autoridad).

**You'll see CCPD-02:**
- **Name**: `CCPD-02 Lucro Cesante Pendiente Autoridad`
- **Type**: `Expense`
- **Status**: `Pending Authority`
- **Payment Status**: `Draft`
- **Claimed Amount**: `$8,000,000`
- **Adjusted Amount**: (empty)

**Sample talk track:**
> "And this second payment is in a state very common in Pyme claims: `Pending Authority`. The insured claimed 8 million for business interruption — 5 days closed. The adjuster reviewed it but the amount exceeds their role's authorization level, so it's waiting for supervisor approval.
>
> Notice that `Adjusted Amount` is empty — because until the authority approves, the adjuster doesn't set the final amount. This can be automated with an authorization Flow: when the supervisor approves, the adjusted amount gets populated and the payment moves to `Approved for Payment`. That's what we call an 'authority-level workflow', and in Insurance on Core it's done with Flow or Approval Process, without custom code."

**Emphasis points:**
- One executed payment + one payment pending authorization = complete workflow story.
- Empty AdjustedAmount is pedagogically intentional — it shows the real state of a non-approved payment.
- Mention "no custom code" — recurring client theme.

**Fallback if any CCPD isn't visible:**
- Direct URLs are already on tabs 3 and 4.
- If the Financials tab doesn't show Payment Summary or CCPDs, go via URL:
  - PaymentSummary: `/lightning/r/ClaimPaymentSummary/0l8g80000001y5NAAQ/view`
  - CCPD-01: `/lightning/r/ClaimCoveragePaymentDetail/0l2g80000000PfxAAE/view`
  - CCPD-02: `/lightning/r/ClaimCoveragePaymentDetail/0l2g80000000PhZAAU/view`

---

### Phase 5 — Link to the Policy (Claim Coverage → Policy) (5-7 min)

**Objective**: visually close the loop between claim and policy — the "end-to-end" the client has already heard twice and now has to see.

**Step 5.1** — Switch to Tab 2 (ClaimCoverage `CC-SIN-PYME-2026-0001-Incendio`).

**You'll see** (in addition to the reserves already shown):
- Field **Insurance Policy Coverage**: link to the Incendio y Aliados coverage on the policy.

**Sample talk track:**
> "Let's go back to the ClaimCoverage for a moment. Notice this field — `Insurance Policy Coverage`. It's the link that ties this claim to the exact policy coverage that Block 2 issued."

**Step 5.2** — Click the **Insurance Policy Coverage** link (Incendio y Aliados).

**You'll see**: the coverage on policy `POL-PYME-2026-0001` with its data — Coverage Name, limits, deductibles, etc.

**Sample talk track:**
> "We're now on the coverage record, inside the policy. From here I can navigate to the parent policy and confirm it's the same one issued in Block 2."

**Step 5.3** — Click the **Policy Name** / **Insurance Policy** link (the parent field) to jump to `POL-PYME-2026-0001`.

**You'll see**: the Block 2 policy with its data.

**Sample talk track:**
> "And here is the policy. The same one you issued. No ETLs, no nightly syncs, no intermediate data lakes. One model, one truth: the policy knows its claims, and the claim knows its policy. When you get an inquiry from the insured, the regulator or the reinsurer, the answer is one click away."

**Step 5.4** — Optional bonus (if time allows, otherwise skip): on the Policy, **Related** tab → **Claims** section — show that `SIN-PYME-2026-0001` is listed.

**Sample talk track:**
> "And to close the loop — from the policy I see all its claims. Today one, tomorrow however many. With Reports and CRM Analytics I get loss-ratio metrics by policy, by product, by region, in real time."

**Emphasis points:**
- This is THE "end-to-end" moment. More important than the numbers.
- Say it out loud: "One model, one source of truth, one single Salesforce."

**Fallback if the `Insurance Policy Coverage` link doesn't appear or breaks:**
- Go directly to Tab 5 (InsurancePolicy list) and open `POL-PYME-2026-0001`. Show the policy and the Related tab → Claims.

---

### Phase 6 — Narrative close + Agentforce (3-5 min)

**Objective**: close the block, bridge to Block 6 (Reporting) and plant the Agentforce message without a live demo.

**Step 6.1** — Back to Tab 1 (main Claim). Leave the highlights panel visible.

**Sample talk track:**
> "Let's do a quick recap of the 45 minutes we've just walked through:
>
> - A complete claim — `SIN-PYME-2026-0001` — from notice to executed payments and payments pending authorization.
> - Three participants with differentiated roles on the same standard model.
> - Three claimed items, each linked to the policy coverage backing it.
> - Traceable technical reserves — 50 million split into 45 in direct loss and 5 in expense — with per-adjustment evidence.
> - 32 million already paid to the insured, 8 million in authorization workflow.
> - And all of this on a single Insurance on Core standard model, linked directly to the Block 2 policy, with no custom objects for the core of the process."

**Step 6.2** — Plant Agentforce (without live demo).

**Sample talk track:**
> "One last point before handing over to Block 6.
>
> On this same model, you can deploy conversational agents with **Agentforce** — Salesforce's agent layer, GA for over a year — to automate typical claims tasks:
>
> - **Assisted FNOL**: the insured reports the claim via WhatsApp or portal, and the agent builds the Claim with the items, the claim type, and notifies the adjuster.
> - **Executive claim summary**: an agent reads the entire file — Claim, participants, items, reserves, payments — and generates a 3-line summary for the supervisor when they ask for status. Without opening 6 tabs.
> - **Coverage verification**: queries the policy, validates validity, exclusions and limits, and answers 'yes it covers, with these conditions' or 'no, does not cover due to this clause'.
> - **Communications drafting**: letters to the insured, appraisal records, notifications to the reinsurer — generated with controlled prompts.
>
> None of this is future work — it's GA product. We leave it out of scope for this demo to avoid mixing messages, but it's ready for a pilot in the enablement phase."

**Step 6.3** — Bridge to Block 6 (Reporting).

**Sample talk track:**
> "With that I close Block 3. The next block you're about to see — Reporting — takes exactly all the data we've just shown here and turns it into dashboards, KPIs and regulatory reports. No ETLs, no separate cubes: the same objects you saw, feeding Reports and CRM Analytics in real time.
>
> I'll hand over to [Block 6 presenter's name]. Thank you."

**Emphasis points:**
- Don't promise Agentforce running in the demo — if the client asks, say: "Happy to schedule a dedicated session in the enablement phase."
- The bridge to Reporting is literal: same data, another view.

**Optional — if 2+ minutes remain and the client shows technical interest:**
- Go to **Setup** → search "Einstein GenAI" or "Permission Set Licenses" → show that the Einstein GenAI PSL is assigned or available in the org — just as evidence that the platform is prepared.
- Don't drill in. 30 seconds maximum.

---

## 3. Anticipated questions (Q&A)

These are the questions Seguros ALFA is likely to raise during or after the block. Have the answers ready, short, and anchored to the model you just showed.

### Q1 — How is claims fraud detected?

> "The standard model captures every data point a fraud engine needs — LossType, EstimatedAmount, insured history, participants, date patterns. On top of that, Einstein Discovery and CRM Analytics generate predictive fraud propensity models without the claims team having to do manual feature engineering. You can also integrate with external engines via API — SAS, Shift Technology, etc. The flexibility is that the data is structured from day one."

### Q2 — Can the adjuster reassign the claim to another adjuster?

> "Yes. The Claim's `Owner` field can be changed manually or via rules — Case Assignment Rules or Flow. There's also skill-based routing with Omni-Channel if Seguros ALFA wants to balance load between adjusters by specialty, geography or availability. It's configuration, not development."

### Q3 — Can external adjusters be integrated without licensing them as internal users?

> "Yes. Experience Cloud gives you an external portal with a Partner Community or Customer Community Plus license. The adjuster only sees the claims assigned to them, can upload photos, records and reports, and their interaction is captured in the same model — as a `ClaimParticipant` with role `Loss Adjuster` and portal access. No data duplication or internal license cost."

### Q4 — What happens if the claim exceeds the coverage limit?

> "The model compares `Total Claimed` and `Total Adjusted` on the ClaimCoverage against the `Limit Amount` on the Insurance Policy Coverage. If it exceeds, a Flow can be configured to alert the supervisor, block the automatic payment, or trigger a review. The layout can display both values side by side. In a production implementation this is the first thing you wire in."

### Q5 — Can FNOL be automated from the insured?

> "Yes, via three paths: (1) an OmniScript in Experience Cloud that guides the insured step by step and creates the Claim at the end; (2) an Agentforce agent via WhatsApp or chat that handles conversational intake; (3) a public API if Seguros ALFA wants to trigger FNOL from their mobile app or website. All three flows create the same standard `Claim` with the same ClaimParticipants and ClaimItems you saw here."

### Q6 — How is IBNR reserve managed, or reserve changes over time?

> "The `ClaimCovReserveAdjustment` object allows multiple adjustments on the same ClaimCoverage. Every time the actuary or the adjuster updates the estimate, a new Adjustment is created with its reason and who did it. The total reserve on the ClaimCoverage is automatically recalculated. That gives you historical traceability for IBNR and SFC reporting. If you'd like, in the implementation phase we can build a dedicated reserve-evolution dashboard."

### Q7 — Reinsurance?

> "Reinsurance is out of scope for this demo, and honestly out of the standard Insurance on Core core today. Salesforce has partners like Duck Creek or Sapiens if the requirement is a full ceding reinsurance engine. For facultative treaties with manual cession, you can model it on custom objects. It's on the product roadmap and we can review it in detail in the enablement phase."

### Q8 — Colombian SFC regulatory reporting?

> "The data you saw — reserves, adjustments, payments, claim typology, severity — is structured in the standard Salesforce model, so the pipeline to SFC reports is direct. Block 6, coming up next, shows native Reports. For specific SFC reports that require exact regulatory formats, you combine with CRM Analytics or an integration to the actuarial tool you already use. The advantage: the data is unique, no reconciliation needed between CRM and claims engine."

### Q9 (bonus, in case it comes up) — Why is there only one ClaimCoverage if there are 3 ClaimItems?

> "Good catch. The 3 items correspond to the same coverage from a technical standpoint — they're all damages derived from the fire and the associated business interruption. In the demo we simplified to one ClaimCoverage so we didn't clutter the screen with duplicated reserves. In production, if two items correspond to different policy coverages, you open two ClaimCoverages and each controls its own reserve. It's straightforward, no development required."

### Q10 (bonus) — Why is the `Adjusted Amount` on the pending payment empty?

> "On purpose. The adjusted amount is populated when the authority approves the payment. Until there's approval, the adjuster doesn't set the final amount — because if the authority reduces or modifies it, the adjusted value reflects the final decision. It's the expected behavior of the authorization workflow."

---

## 4. Transition to Block 6 (Reporting)

Already included as Step 6.3. Repeating the talk track for quick reference:

> "With that I close Block 3. The next block you're about to see — Reporting — takes exactly all the data we've just shown here and turns it into dashboards, KPIs and regulatory reports. No ETLs, no separate cubes: the same objects you saw, feeding Reports and CRM Analytics in real time. Handing over to [name]. Thank you."

**Physical handoff**: hand over screen control or the clicker. If on Zoom/Meet, stop sharing so the next presenter can share theirs.

---

## 5. General fallbacks

If something breaks live, here are the emergency exits without losing rhythm.

### Fallback A — Financials tab doesn't show reserves or CCPDs

- Go directly to the ClaimCoverage (Tab 2 already open): `/lightning/r/ClaimCoverage/0kPg80000000OITEA2/view`.
- Show the reserve fields directly on the ClaimCoverage layout.
- Under Related, show Adjustments and Payment Details from there.

### Fallback B — A Claim tab doesn't appear (Participants, Financials, etc.)

- Navigate by direct URL to the records you need (IDs in previous sections).
- Explain to the client: "The layout is configured per profile — in production it's tuned to the user's role. The data is there, access is configuration."

### Fallback C — ClaimItems don't appear in Related

- Go to `/lightning/o/ClaimItem/list` and filter the view by `Claim.Name = SIN-PYME-2026-0001`.
- Alternative: direct URL to each item (IDs in Phase 3).

### Fallback D — The Insurance Policy Coverage link breaks

- Go to Tab 5 (InsurancePolicy list).
- Open `POL-PYME-2026-0001` and from the policy navigate to Related → Claims → SIN-PYME-2026-0001.
- Same message: end-to-end works, navigation is bidirectional.

### Fallback E — The browser gets slow or crashes

- Close extra tabs and stick with Tab 1 (Claim).
- If all of Salesforce isn't responding: refresh (Cmd+R). If still bad, log back in from `https://storm-c90aab66569c63.my.salesforce.com/`.
- Last resort: use the Claim's Chatter object and show the data through the highlights panel + Details tab; skip Financials and go straight to the narrative close.

### Fallback F — The client pushes on a topic you don't have

- Don't make it up. Time-buying phrase: "Great question — to avoid giving you an imprecise answer, I'll note it down and bring the detail back in the follow-up session with the product team."
- Note it down physically. At the end of the day, review it with the technical backup before responding.

### Fallback G — Running out of time (10 min left of 45 and you're in Phase 3)

- Skip Phase 3 entirely (Claim Items) — say: "The claimed items are in the Related tab; in a production implementation they can be profiled by category."
- Cut Phase 4 to the minimum: show only the ClaimCoverage and one CCPD (the Paid one). Skip Reserve Adjustments.
- Prioritize Phase 5 (policy link) — it's the most narratively impactful.
- Close with Step 6.1 and 6.3, skip Agentforce (6.2).

### Fallback H — Time to spare (finished in 35 min)

- Phase 6.2 with more detail on Agentforce.
- Show the **Claim Team** tab — which internal users are assigned to the claim.
- Show the **Action Plan** tab — checklist of tasks in the handling process.
- Go to Setup → Permission Set Licenses → Einstein GenAI, to show enablement.
- Open the Claim in the Salesforce mobile app (if you have an iPad/phone ready) — 30 seconds, big visual impact.

---

## 6. Success metrics — post-block checklist

At the end of Block 3, the Seguros ALFA client should have understood:

- [ ] The claim is a standard Insurance on Core object (`Claim`) linked to the policy without custom development.
- [ ] Multi-role participants (insured, adjuster, witness) on a standard `ClaimParticipant`.
- [ ] The claimed items (`ClaimItem`) connect to the backing policy coverage (`InsurancePolicyCoverage`).
- [ ] Technical reserves are traceable via adjustments (`ClaimCovReserveAdjustment`) — audit-ready.
- [ ] Payments have a full cycle: reserved → authorized → paid, with a configurable workflow.
- [ ] The `Claim ↔ InsurancePolicy` link is direct and bidirectional — no ETL in between.
- [ ] The model feeds reporting (Block 6) without needing to duplicate data.
- [ ] Agentforce can be layered on this model to automate FNOL, summaries, coverage verification and communications — as an optional layer, GA.
- [ ] Everything shown lives in the demo org, with real IDs, without custom objects for the core of the claims process.

**Closing sentence to leave in the room** (optional, if the moment calls for it):

> "What you saw in 45 minutes isn't a proof of concept — it's the standard product functionality Seguros ALFA buys on day one. The implementation conversation is about how we adapt it to Aval's specific processes, not about what still needs to be built."

---

## Appendix — Quick ID map for copy-paste

| Record | Object | ID |
|---|---|---|
| Claim SIN-PYME-2026-0001 | Claim | `0Zkg80000000awLCAQ` |
| Claimant Panadería La Espiga | ClaimParticipant | `0aSg8000000LNXtEAO` |
| Loss Adjuster Alan Reed | ClaimParticipant | `0aSg8000000LNb7EAG` |
| Witness Bomberos Bogotá | ClaimParticipant | `0aSg8000000LNcjEAG` |
| Horno Industrial | ClaimItem | `0dqg80000000UpJAAU` |
| Estantería Metálica | ClaimItem | `0dqg80000000UqvAAE` |
| Lucro Cesante 5 días | ClaimItem | `0dqg80000000UsXAAU` |
| ClaimCoverage Incendio | ClaimCoverage | `0kPg80000000OITEA2` |
| Reserva pérdida directa | ClaimCovReserveAdjustment | `0l7g800000002ppAAA` |
| Reserva gasto lucro cesante | ClaimCovReserveAdjustment | `0l7g800000002rRAAQ` |
| Payment Summary | ClaimPaymentSummary | `0l8g80000001y5NAAQ` |
| CCPD-01 Horno Pagado | ClaimCoveragePaymentDetail | `0l2g80000000PfxAAE` |
| CCPD-02 Lucro Cesante Pending | ClaimCoveragePaymentDetail | `0l2g80000000PhZAAU` |

**Base instance**: `https://storm-c90aab66569c63.my.salesforce.com`

Any record can be reached as: `{instance}/lightning/r/{Object}/{Id}/view`

---

**Good luck, Luis. Breathe before you start. The data is there, the story is there, the runbook is there. All you have to do is tell it.**
