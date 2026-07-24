# Runbook — Block 6: Reporting

**Duration**: 30 min | **Presenter**: the presenting SE | **Org**: ins-qbranch-alfa
**Instance URL**: https://storm-c90aab66569c63.my.salesforce.com

> *All quoted talk tracks below are sample scripts — Spanish speakers should deliver them in the client's language.*

---

## 0. Pre-demo setup (do 15 min before)

### 0.1 Log in to the org
1. Open Chrome (clean profile, no extensions that inject CSS).
2. Go to https://storm-c90aab66569c63.my.salesforce.com
3. Log in with the demo user (same one used in previous blocks). Confirm the user locale is `en_US` — standard labels will render in English and this needs to be called out verbally when it comes up.
4. Verify the active App is "Insurance Console" or "Sales" (any app that has Reports and Dashboards in the App Launcher — the specific app doesn't matter because we'll navigate through the App Launcher).

### 0.2 Pre-load tabs (leave them open in the order they'll be used)

Open in separate browser tabs, in this exact order (left to right):

| # | Purpose | URL |
|---|---|---|
| 1 | Reports Home (folder view) | https://storm-c90aab66569c63.my.salesforce.com/lightning/o/Report/home?queryScope=mine |
| 2 | Dashboards Home | https://storm-c90aab66569c63.my.salesforce.com/lightning/o/Dashboard/home |
| 3 | Dashboard Producción Pyme 2026 | https://storm-c90aab66569c63.my.salesforce.com/lightning/r/Dashboard/01Zg8000001l9nFEAQ/view |
| 4 | Dashboard Renovaciones Pyme 2026 | https://storm-c90aab66569c63.my.salesforce.com/lightning/r/Dashboard/01Zg8000001l9nGEAQ/view |
| 5 | Dashboard Siniestralidad Pyme 2026 | https://storm-c90aab66569c63.my.salesforce.com/lightning/r/Dashboard/01Zg8000001l9nHEAQ/view |
| 6 | Report Loss Ratio Pyme | https://storm-c90aab66569c63.my.salesforce.com/lightning/r/Report/00Og80000045mGFEAY/view |
| 7 | Report Prima Emitida por Producto Pyme | https://storm-c90aab66569c63.my.salesforce.com/lightning/r/Report/00Og80000045mGKEAY/view |
| 8 | Report Pólizas Próximas a Vencer 90 Días | https://storm-c90aab66569c63.my.salesforce.com/lightning/r/Report/00Og80000045mGHEAY/view |
| 9 | Report Siniestros Pyme por Estado | https://storm-c90aab66569c63.my.salesforce.com/lightning/r/Report/00Og80000045mGMEAY/view |

### 0.3 Verify the 3 dashboards render data and validate widget composition

On each dashboard tab (3, 4, 5):

1. Confirm they **load without "No results to display"** in the main widgets. The dashboards run against the same objects used in the previous blocks: `Product2` / `ProductCategory` (Block 1), `InsurancePolicy` with its `PremiumAmount` and `ExpirationDate` fields (Block 2), `Claim` with `ClaimCoverage`, `ClaimCoveragePaymentDetail` and its reserves `LossReserveAmount` / `ExpenseReserveAmount` (Block 3).
2. If any widget shows "No results", click **Refresh** (top right of the dashboard) and wait 10-15 seconds.
3. Confirm the "As of {date}" timestamp isn't days old — if it is, click **Refresh** again.
4. **CRITICAL VALIDATION of widget composition** — before assuming the Step 2.9 narrative, verify that the widgets described actually exist in the dashboard:
   - **Producción Pyme 2026**: verify that the widgets for Total Premium Written, Premium by Product, Premium by Plan, and Portfolio by Industry are present.
   - **Renovaciones Pyme 2026**: verify Policy Count Expiring and Premium at Risk widgets.
   - **Siniestralidad Pyme 2026**: verify Loss Ratio by Product, Total Reserve, Claims by Status, and Approved vs Pending Payments.
5. **VALIDATION of linked source reports** — click on the title of any widget in the Siniestralidad dashboard. If the underlying report opens correctly, the drill-down and fallback 5.1 work. If it does NOT open (widget without a linked source report), note it and don't promise drill-down in the talk track.
6. If a widget doesn't match the narrative, **adjust the Step 2.9 talk track** live — don't describe a widget that isn't on screen.

### 0.4 Verify Reports folder
- On tab 1 (Reports Home), click **Folders** in the left panel.
- Confirm that the **"Seguros ALFA Pyme"** folder appears.
- Click on the folder — the **11 reports** should appear. If fewer show up, check that we're logged in as the right user and that the folder has read permissions.

### 0.5 Browser zoom
- Set zoom to **90%** in Chrome (Cmd + `-` once from 100%). Dashboards with 6 widgets fit fully without scrolling.

### 0.6 Prep the App Launcher
- Cmd + Shift + . (or click the 9 dots at the top left) to open the App Launcher.
- Type "Reports" and "Dashboards" once each to confirm they appear in the results (avoids hesitation during the live demo).

### 0.7 Terminology refresh aligned with Blocks 1-3

Before starting, memorize the real objects and fields used in the previous blocks. If the client asks "show me that field live", we need to be on the correct object:

| Business concept | Actual sObject | Actual field |
|---|---|---|
| Pyme product and its plans | `Product2` + `ProductCategory` | `Name`, `ProductClass` |
| Issued policy | **`InsurancePolicy`** (not `PolicyContract`) | `PolicyName`, `PolicyNumber` |
| Policy premium | `InsurancePolicy` | **`PremiumAmount`** (not `PolicyPremium`) |
| Expiration date | `InsurancePolicy` | **`ExpirationDate`** (not `EndDate`) |
| Claim | **`Claim`** (not `InsuranceClaim`) | `ClaimNumber`, `Status` |
| Claim coverage | `ClaimCoverage` | `LossReserveAmount`, `ExpenseReserveAmount` |
| Approved claim payment | **`ClaimCoveragePaymentDetail`** (not `ClaimPayment`) | **`AdjustedAmount`** (not `TotalPaidAmount`) |
| Policy clauses (Block 5 integrated into 2) | `InsuranceClause` | `Type` (values Clause / Exclusion — NOT `ClauseType`) |

**Golden rule**: use these names in the talk tracks. If a talk track in this runbook uses a term, that's the correct term — don't swap it out live from memory.

---

## 1. Block context and objective (30 sec)

In this block we wrap the presentation by showing how Seguros ALFA gets **real-time operational and business visibility** over everything built in the previous blocks: Pyme policy production, upcoming renewals, and claims experience. There are no external integrations, no additional BI: these are **native Salesforce reports and dashboards** running directly against the standard Insurance on Core objects (`Product2`, `InsurancePolicy`, `InsuranceClause`, `Claim`, `ClaimCoverage`, `ClaimCoveragePaymentDetail`). It's the same transactional data from Block 2 and Block 3, now aggregated for the underwriting, claims, and management teams.

We close with the claims experience dashboard because visually it's the most impactful and it speaks directly to the business KPIs.

---

## 2. Step-by-step click path

### Step 2.1 — Entering the Reports folder (2 min)

**Click / navigation:**
1. Go to browser **tab 1** (Reports Home) — URL already pre-loaded: `/lightning/o/Report/home?queryScope=mine`.
2. In the left panel, click **Folders** (or "Carpetas" if the tenant were in Spanish).
3. Scroll or search for the **"Seguros ALFA Pyme"** folder — click on it.
4. You'll see on screen: a list of **11 reports** with Name, Description, Folder, Format, Created By columns.

**What to say (talk track):**
> "Before showing the dashboards, I want you to see the starting point: every report we built for the Pyme business is grouped in a single folder, 'Seguros ALFA Pyme'. Eleven reports covering portfolio, coverages, premium written, policies by status, upcoming renewals, claims and payments, plus the business indicators like Loss Ratio and Total Reserve. All of this is native Salesforce reporting — no additional tool: it's the same platform where the policy is issued and the claim is recorded."

**Emphasis points:**
- Stress that these are **11 grouped reports** — clear visual of the list.
- Mention that the folder can be **shared with specific profiles/roles** (underwriting sees some, claims sees others) — this is standard Salesforce access control.

**If something doesn't appear:**
- If the folder doesn't show in the list, click **All Folders** instead of "Created by Me" or "Shared with Me" in the top filter.
- If it still doesn't appear, go directly to a report by URL: `/lightning/r/Report/00Og80000045mGDEAY/view` and explain the folder verbally.

---

### Step 2.2 — Opening an individual report: Prima Emitida por Producto Pyme (3 min)

**Click / navigation:**
1. From the folder list, click the **"Prima Emitida por Producto Pyme"** report.
   - Alternative (faster if the list gets tangled): jump to browser **tab 7**, direct URL `/lightning/r/Report/00Og80000045mGKEAY/view`.
2. The report opens in **View** mode (not edit).
3. You'll see on screen: grouping by Product, a column with the sum of `PremiumAmount`, and a grand total at the bottom.

**What to say (talk track):**
> "This is a simple but foundational report for the sales area: premium written grouped by product. These products are exactly the ones we built in Block 1 — Seguro Pyme Integral and its Esencial, Empresarial, and Corporativo plans. Every peso of premium you see here is tied to an `InsurancePolicy` issued in Block 2, summing the `PremiumAmount` field. There's no data copy, no ETL, no warehouse: the report reads the policy directly."

4. Click the **Edit** icon (top right) to show the Report Builder for 30 seconds.
5. You'll see on screen: Report Builder with Groups, Columns, and Filters visible on the left.

**What to say:**
> "And this is what the builder looks like. A functional user from the data team or the business builds this by dragging fields. Filters by date, by product, by branch, by whatever they need. No code."

6. Click **Close** (or the X button at the top right) to exit the builder without saving.

**Emphasis points:**
- **Live data, not a snapshot**: if you issued a new `InsurancePolicy` right now and refreshed (Refresh button), it would show up.
- **Self-service**: this isn't a ticketed development, it's power-user configuration.

**If something doesn't appear:**
- If the report opens empty (0 rows), verify that Block 2 policies have `PremiumAmount` populated. If not, move directly to the next report and mention "some products here don't yet have consolidated premium because they are test issuances."

---

### Step 2.3 — Loss Ratio Pyme report (3 min)

**Click / navigation:**
1. Go to browser **tab 6**: `/lightning/r/Report/00Og80000045mGFEAY/view`.
2. You'll see on screen: a report with columns combining claims paid and earned premium, with a calculated Loss Ratio (%) column.

**What to say (talk track):**
> "This is one of the most important reports for the technical desk and management: Loss Ratio Pyme. It crosses claims against premium. At an insurance carrier this is the portfolio thermometer — a product with Loss Ratio above 70% in Pyme usually raises red flags. And what's relevant for ALFA: this calculation doesn't need a nightly batch job, doesn't need an analyst pulling Excel — it's calculated on the fly with Salesforce **row-level formulas**, summing `ClaimCoveragePaymentDetail.AdjustedAmount` (the approved payments we saw in Block 3) over `InsurancePolicy.PremiumAmount` (the premium written from Block 2)."

**Emphasis points:**
- **Row-level formulas and summary formulas** are standard Reports features — you can compute things like (Claims/Premium), differences, averages, all without Apex.
- This report **does not have Description populated** — if the client asks what exactly it measures, explain verbally using the table in Appendix C.

**If something doesn't appear:**
- If the Loss Ratio column shows "0%" or blank on several rows, it's because those products don't yet have claims. Explain: "in the demo data, only the Block 3 flow has payments recorded in `ClaimCoveragePaymentDetail` — in production every product would have history."

---

### Step 2.4 — Pólizas Próximas a Vencer 90 Días report (2 min)

**Click / navigation:**
1. Go to browser **tab 8**: `/lightning/r/Report/00Og80000045mGHEAY/view`.
2. You'll see on screen: a list of policies with `ExpirationDate` within the next 90 days, grouped by product or by month.

**What to say (talk track):**
> "This is the operational input for the renewals team. The filter is built on the `InsurancePolicy.ExpirationDate` field with a relative date — `ExpirationDate = NEXT 90 DAYS` — so **you never have to update the filter**. Every day a user opens this report, they'll see the rolling renewal window. And from here you can export to Excel, or better: you can **subscribe** so Salesforce emails it every Monday."

3. Click the **Subscribe** icon (top right, bell icon or "Subscribe") to show the subscription modal for 15 seconds.
4. You'll see on screen: modal with Frequency (Daily/Weekly/Monthly), Time, Recipients.
5. Click **Cancel** in the modal (we don't want to create the actual subscription).

**What to say:**
> "Daily, weekly, or monthly cadence, with conditions — for example, 'only send it when the count goes above 50 policies'. All native."

**Emphasis points:**
- **Relative date** = a living report, zero maintenance.
- **Subscriptions with conditions** — the client almost always asks "can I get it automatically" — the answer is yes.

**If the client asks to see the filter formula live:**
- Click **Edit** on the report → Filters panel (left) → show the filter `ExpirationDate equals NEXT 90 DAYS`.
- Close without saving.

**If something doesn't appear:**
- If the report returns 0 rows (nothing expires in 90 days), clarify: "in production with a real book of business, this would always have hundreds of rows — in the demo org we have a few example policies, some already outside the window." And move to the next.

---

### Step 2.5 — Siniestros Pyme por Estado report (2 min)

**Click / navigation:**
1. Go to browser **tab 9**: `/lightning/r/Report/00Og80000045mGMEAY/view`.
2. You'll see on screen: claims from the `Claim` object grouped by their `Status` (Submitted, Under Investigation, Approved, Closed, etc. — the ones from Block 3), with count and amounts.

**What to say (talk track):**
> "And for the claims area, this is the pipeline: how many claims are in each stage of the lifecycle we showed in Block 3. The statuses you see here — Submitted, Under Investigation, Approved, Denied, Closed — are from the standard `Claim.Status` picklist that you already validated. The claims team works this report daily to find where the bottlenecks are."

**Emphasis points:**
- **Direct traceability to Block 3** — this isn't separate data, it's the same `Claim` object.
- The team can **drill down**: click a group → shows individual claims → click one → opens the full `Claim` record.

**Drill-down demonstration (optional, if there's time):**
1. Click the count number of any group (for example "Under Investigation").
2. You'll see the expanded list of individual claims.
3. Click any Claim Number → opens the `Claim` record.
4. Use the browser back button to return.

**If something doesn't appear:**
- If all claims are in the same status, mention: "in the demo we only have the end-to-end flow from Block 3 with claim SIN-PYME-2026-0001 — in production you'd see the real portfolio distribution."

---

### Step 2.6 — Transition to Dashboards (30 sec)

**Click / navigation:**
1. Go to browser **tab 2**: `/lightning/o/Dashboard/home`.
2. Click **All Folders** in the left panel.
3. Click the **"Seguros ALFA Pyme"** folder.
4. You'll see on screen: **3 dashboards** — Producción Pyme 2026, Renovaciones Pyme 2026, Siniestralidad Pyme 2026.

**What to say (talk track):**
> "The reports are the raw material. The dashboards are the consolidated view — what management looks at in the morning. We built three dashboards covering the three business fronts for Pyme: production, renewals, and claims experience. Let's walk through them."

---

### Step 2.7 — Dashboard Producción Pyme 2026 (4 min)

**Click / navigation:**
1. Click **"Producción Pyme 2026"** from the list.
   - Alternative (faster): browser **tab 3**, direct URL `/lightning/r/Dashboard/01Zg8000001l9nFEAQ/view`.
2. You'll see on screen: dashboard with widgets for Premium Written (aggregating `PremiumAmount`), distribution by product, distribution by plan, and portfolio by industry.

**What to say (talk track):**
> "This is the dashboard for the underwriting area. At the top, **total premium written** — the sum of `PremiumAmount` across all Pyme policies, the primary KPI. Next to it, the breakdown by product — the same thing you saw in the previous report but visualized as bar or donut chart. Below, the portfolio segmented by customer industry, giving the business the risk concentration read: how much of the book is in manufacturing, services, retail, construction."

3. **Hover** (move the mouse without clicking) over any bar or segment in the Premium by Product chart.
4. You'll see on screen: tooltip with the exact value.

**What to say:**
> "And if an executive wants to dig into the detail, every widget is clickable — it opens the underlying report. It's the same data from the report we saw a minute ago, now aggregated visually."

5. Click any widget (for example Premium Written by Product).
6. The report opens in drill-down mode. Use the browser back button to return.

**Emphasis points:**
- **Dashboard filters**: if the dashboard has a global filter at the top (by branch, by year, by product), show it. No filter is not a problem — mention that global filters can be added so the same dashboard serves different executives.
- **Manual and scheduled refresh**: the dashboard can be scheduled to refresh every morning at 6 AM so it's fresh for the first meeting of the day.

**If something doesn't appear:**
- If a widget says "No results", click **Refresh** at the top right of the dashboard (circular arrow icon). Wait. If still empty, continue with the widgets that did load and mention: "this widget crosses data that isn't yet populated in the demo — in production with real data load it would always have data."

---

### Step 2.8 — Dashboard Renovaciones Pyme 2026 (3 min)

**Click / navigation:**
1. Go to browser **tab 4**: `/lightning/r/Dashboard/01Zg8000001l9nGEAQ/view`.
2. You'll see on screen: a dashboard with count of policies expiring soon (using `InsurancePolicy.ExpirationDate`), distribution by month, and premium at risk of non-renewal (aggregating `PremiumAmount` from expiring policies).

**What to say (talk track):**
> "The renewals dashboard combines two things: how many policies expire in the relevant window — 30, 60, 90 days — using `InsurancePolicy.ExpirationDate`, and how much premium is associated, summing `PremiumAmount` from those same policies. The key business read isn't just 'how many policies', but 'how much premium is at risk of not renewing'. That's what's needed to build retention campaigns, prioritize broker outreach, or direct the sales force."

3. Show how the dashboard **crosses over with the report** from Step 2.4.
4. Click the widget representing count by month (or similar).
5. The underlying report opens — it's the same "Pólizas Pyme Próximas a Vencer 90 Días" we already saw.

**What to say:**
> "And as I mentioned, this is built with relative dates — `NEXT 90 DAYS` — not fixed dates. On August 1st you'll see the exact same view but with the window shifted one month. Zero maintenance."

**Emphasis points:**
- **Premium at risk** is the business angle, not the raw count.
- The connection with the already-shown report reinforces that **it's all one data model**.

**If something doesn't appear:**
- Similar to the previous one: refresh, and if that doesn't help, move on.

---

### Step 2.9 — Dashboard Siniestralidad Pyme 2026 (5 min) — STRONG CLOSE

**Note for the SE**: the exact composition of the 4 widgets described below must be validated in Setup 0.3 (step 4). If any widget is missing or has a different name, adjust the talk track live — don't describe widgets that aren't on screen.

**Click / navigation:**
1. Go to browser **tab 5**: `/lightning/r/Dashboard/01Zg8000001l9nHEAQ/view`.
2. You'll see on screen: the most complete dashboard — Loss Ratio by product, Total Reserve, Claims by Status (funnel), Approved vs Pending Payments.

**What to say (talk track):**
> "And we close with the claims experience dashboard. This is probably the most important dashboard for Seguros ALFA's technical desk, because it consolidates everything the actuary and the claims lead need to see on a single screen:
>
> — One: **Loss Ratio by product**. The technical profitability read. Products below target show in green, those out of range appear in red.
>
> — Two: **Total Reserve**. How much is provisioned for the Pyme portfolio, summing `LossReserveAmount` and `ExpenseReserveAmount` from `ClaimCoverage` — the same fields you validated in Block 3. This is the number that goes straight into the accounting close.
>
> — Three: **Claims funnel by status**. How many claims are in each stage of the lifecycle you saw in Block 3, grouping `Claim` by its `Status` field.
>
> — Four: **Approved versus Pending Payments**. The liquidity and operational management snapshot for the area."

3. Move widget by widget, hovering to show tooltips with exact values.

**What to say while hovering:**
> "The Loss Ratio is calculated on the fly, against premium written — `InsurancePolicy.PremiumAmount` — and payments made — `ClaimCoveragePaymentDetail.AdjustedAmount`. Total Reserve sums the `LossReserveAmount` and `ExpenseReserveAmount` fields on `ClaimCoverage` that you validated in Block 3. The status funnel is exactly the Submitted → Under Investigation → Approved → Paid → Closed flow that we showed, running over `Claim.Status`. And approved vs pending payments sits on top of `ClaimCoveragePaymentDetail` and its approval status."

4. **Drill-down demonstration**: click the Loss Ratio widget → opens the Loss Ratio Pyme report → go back. *(Precondition: Setup 0.3 confirmed the widget has a linked source report.)*
5. **Visual alternative**: click the Claims by Status widget → opens the Siniestros por Estado report → go back.

**What to say to close:**
> "All of this — the 11 reports and the 3 dashboards — was built in a matter of hours by a power user, no development, and without moving data out of Salesforce. And it grows with you: every `InsurancePolicy` issued, every `Claim` logged, every `ClaimCoveragePaymentDetail` processed shows up here **the moment we refresh**. No maintenance windows, no dependency on the data team."

**Emphasis points:**
- This is the **densest** dashboard — the one that will stick with the committee.
- Insist on **traceability**: every number here can be clicked through to the source record.
- If there are 30 seconds to spare, click an individual claim from the funnel → show that it opens the full `Claim` record from Block 3.

**If something doesn't appear:**
- If a widget is broken, move on to the others. **Never** pause on an empty widget — shift focus to what does work.
- If the Total Reserve widget shows a very low number or zero, clarify: "in the demo only the Block 3 claim has `LossReserveAmount` and `ExpenseReserveAmount` populated in its `ClaimCoverage` — in production this figure would reflect the full portfolio."

---

### Step 2.10 — Block close (30 sec)

**Click / navigation:**
- Stay on the Siniestralidad dashboard (tab 5) — it's the final image the client walks away with.

**What to say:**
> "With that we close the four blocks that were agreed for today: product and coverage configuration — with Block 5 on Clauses integrated inside the issuance cycle — policy lifecycle, claims, and reporting. All on the same platform, no additional integrations, with transactional and analytical data on the same engine. We're happy to take questions."

**Internal note for the SE**: the original scope defined 5 blocks (1. Product, 2. Policy, 3. Claims, 5. Clauses, 6. Reporting) but **Block 5 was explicitly integrated into the Block 2 issuance flow**. That's why today we have 4 effective runbooks, not 5. Blocks 4 (Billing and Collections) and the original Reinsurance are **out of scope** per the decision with GFT/management.

---

## 3. Anticipated client questions (during or at the end)

| # | Likely question | Prepared answer |
|---|---|---|
| 1 | How many users can access these reports and dashboards concurrently? | Reports and dashboards are standard features included in the Salesforce license. Concurrency depends on the edition and the number of licensed users — with the Insurance on Core licenses you're quoting, the entire functional team (underwriting, claims, management) has read access at no additional cost. Only the platform's governor limits apply, and they don't impact normal reporting usage. |
| 2 | Do reports support large volumes? We have hundreds of thousands of Pyme policies. | Yes. Lightning Reports run on the Salesforce query engine with native indexing optimizations. For very large volumes or multi-year historical analysis, you can complement with **CRM Analytics** (formerly Tableau CRM), which connects to the same model and enables dashboards over tens of millions of rows. In this demo scope we show native reporting, but the architecture scales into CRM Analytics without migrating data. |
| 3 | Can I take this to external Power BI or Tableau? | Yes. Salesforce exposes the model via REST API and Bulk API, and there are certified native connectors for **Tableau** (same corporate group as Salesforce) and for Power BI via OData/REST. You can also sync to your own data lake with Data Cloud. Nothing stops you from taking data outside; but **for 80% of the operational and executive KPIs**, native tooling solves it without leaving the platform. |
| 4 | How do you control access? I don't want a claims user to see the total portfolio premium. | Two layers: **folder-level sharing** — each reports and dashboards folder is shared with specific roles, profiles, or public groups with View/Edit/Manage permissions; and **field-level security** — if a field like `PremiumAmount` is hidden for a profile, it doesn't appear in the report for that user, even if the report technically includes it. On top of that, reports honor **row-level security** (sharing rules) — a user only sees the records they have access to. |
| 5 | Can Loss Ratio be calculated by region, channel, broker, line of business? | Yes. It's a matter of **grouping** in the report — any field on `InsurancePolicy` or on the Account (region, channel, assigned broker, line of business, branch, commercial executive) can be used as a group. And with **summary formulas** you can derive calculations per group. It's built in the Report Builder, no code. |
| 6 | Can I schedule this dashboard to be emailed every Monday morning? | Yes. Dashboards and reports support **native subscriptions**: cadence (daily, weekly, monthly), time, recipients (users, groups, roles), and **send conditions** (for example, "only send if Loss Ratio goes above 65%"). The user configures it from the same dashboard with the Subscribe button. |
| 7 | Can these reports be exported to Excel or CSV? | Yes, native export to **Excel (.xlsx) and CSV** from the Export button on the report, with two modes: "Formatted Report" (respects groupings and subtotals) and "Details Only" (raw data). Automated email delivery as an attachment can also be scheduled. |
| 8 | And if I want to do ad-hoc analysis not in these 11 reports? | Any user with the "Create and Customize Reports" permission builds a new report in the Report Builder — drag objects, filters, groupings. For more exploratory analysis, pivot-table style or advanced cross-object, you use **CRM Analytics** which enables interactive lenses. No IT ticket is needed for standard reporting. |
| 9 | Can dashboards be embedded on the Salesforce home page or on the broker Community? | Yes. Dashboards can be added as a **Lightning App Page component** on any user's home based on their profile, and also in **Experience Cloud** (broker portal) with the same sharing rules. A broker only sees the policies in their book. |
| 10 | What happens if a user accidentally deletes a report? | Folders allow controlling who can delete (Manage permission). Deleted reports go to the **Recycle Bin for 15 days** — any admin restores them in one click. Additionally, for critical reports you can apply **the "Report Manager" permission** which limits delete to a small group. |
| 11 | How long did it take to build the 11 reports and 3 dashboards? | The 11 reports and 3 dashboards were built in less than a day by a single resource, on top of the standard Insurance on Core model you already saw in Blocks 1-3. **Zero code, zero integrations**, just configuration in Report Builder and Dashboard Builder. |
| 12 | Can I have alerts when something goes past a threshold? For example: Loss Ratio > 70%. | Yes, two paths: **Dashboard alerts** — configured directly on the widget with a threshold and notification to recipients; and **Report subscriptions with conditions** — the subscription only fires if the condition is met. For more complex logic, you can use Flow to monitor the report and trigger actions (create a task, send an email, generate a case). |
| 13 | Does the claim reserve I saw in the dashboard use an actuarial formula? | The `LossReserveAmount` and `ExpenseReserveAmount` fields on the `ClaimCoverage` object (the ones you saw in Block 3) can be fed in several ways: manual calculation by the adjuster, configurable Salesforce formula via Flow on `ClaimCoverage`, or fetched from an external actuarial engine via API — Insurance on Core also exposes the `ClaimCovReserveAdjustment` object to keep an audit trail of every reserve movement. In the demo we show it populated manually. In production, ALFA decides the model and configures it without code in Flow or integrates it into the actuarial system. |
| 14 | I noticed the reports don't have descriptions — what exactly does each one measure? | We can populate the Description field before productive implementation. In the meantime, see **Appendix C** of this runbook with the definition of each of the 11 reports (grouping, filters, and source fields). *(Note for the SE: if the client asks live, refer to Appendix C below.)* |

---

## 4. Transition to the next block

This is the **last block** of the agreed scope. After this, we close with general Q&A. Suggested closing phrase:

> "With that we complete the four blocks we committed to for today — product, policy lifecycle with integrated clauses, claims, and reporting. As we mentioned at the start, the Reinsurance and Billing and Collections blocks were not part of the scope for this presentation — they're on the Insurance on Core roadmap and we can go deeper in a follow-up session if you're interested. We now open the floor for general questions on what you saw."

---

## 5. General block fallbacks

### 5.1 A dashboard doesn't load or shows "No results" fully
1. Click **Refresh** at the top right of the dashboard. Wait 15 seconds.
2. If still empty, try the **drill-down to the underlying report** — click the widget title. **Precondition**: this only works if Setup 0.3 confirmed the widgets have linked source reports. If setup detected they didn't, **don't try this step live** — jump to 3.
3. As a last resort, jump to the next dashboard and comment: "this dashboard is having a refresh delay, in production this is scheduled to run overnight and arrive ready."

### 5.2 A report opens empty (0 rows)
1. **Don't pause**. Comment: "in this demo org the data is limited — this report in production with real book of business would always bring results."
2. Move to the next report or dashboard.

### 5.3 The App Launcher can't find Reports or Dashboards
- Go directly to the pre-loaded URLs (tabs 1 and 2 from setup). Never rely on App Launcher navigation live.

### 5.4 The browser throws an error or hangs
1. Refresh the tab.
2. If it persists, close the tab and open the URL in a new one from the bookmark manager.
3. As a last resort, share screen with the **dashboard ID** and explain verbally what would be visible, using the layout validated in setup.

### 5.5 The client asks to filter by a specific value live
- Only accept if the filter is on the report itself (edit → filter → apply). **Don't** improvise creating new reports live — comment "that specific view we'll build and share as a screenshot or video after this session."

### 5.6 The client asks about a report not in the 11 built
- Generic answer: "That exercise we're adding to the post-presentation work plan. The data structure is already there, it's just another report in the Report Builder on top of the objects you already saw — `InsurancePolicy`, `Claim`, `ClaimCoverage`, `ClaimCoveragePaymentDetail` — an hour of configuration."
- **Never** say "it can't be done" — 99% of the time, with the Insurance on Core model, it can.

### 5.7 Running out of time (less than 5 min left)
- Jump directly to **Step 2.9 (Dashboard Siniestralidad)** — it's the most impactful close.
- Walk through the 4 widgets in 3 minutes.
- Close with the Step 2.10 talk track.

### 5.8 The client asks about a specific field live ("show me that `PremiumAmount`")
- Exit the report → open an `InsurancePolicy` from Block 2 → show the field in the record detail.
- If the field has a different label in the UI (from a Block 1 relabel to Spanish), clarify: "the label may show translated but the API name is `PremiumAmount`."

---

## 6. Block success metrics

At the end of the block, the client should have clear:

- [ ] Salesforce has **native reporting and dashboards** — no external BI dependency for operational and executive KPIs.
- [ ] Reports run directly against the **Insurance on Core objects** seen in blocks 1-3 (`Product2`, `ProductCategory`, `InsurancePolicy`, `InsuranceClause`, `Claim`, `ClaimCoverage`, `ClaimCoveragePaymentDetail`) — no duplicated data or ETL.
- [ ] The business team can build and modify reports **without code and without an IT ticket** (self-service Report Builder).
- [ ] The **three operational fronts** are covered: production (underwriting), renewals (retention), claims experience (technical desk and claims).
- [ ] The **financial and actuarial KPIs** are covered: Total and per-product/plan Premium Written (`PremiumAmount`), Loss Ratio, Total Reserve (`LossReserveAmount` + `ExpenseReserveAmount`), Approved vs Pending Payments (`ClaimCoveragePaymentDetail.AdjustedAmount`).
- [ ] Dashboards support **drill-down** to the source record — full traceability from executive KPI to transactional data point.
- [ ] There is **granular access control** by folder, profile, field, and row (sharing).
- [ ] Reports and dashboards support **email subscription with frequency and conditions**.
- [ ] The platform **scales into CRM Analytics** for advanced analytics and into external tools (Tableau/Power BI) via API when needed.
- [ ] The package of **11 reports + 3 dashboards** was built in hours, not weeks — a clear time-to-value signal.

### Closing checklist for the presenting SE
- [ ] Leave the last screen on the **Siniestralidad Dashboard** (tab 5) — it's the final image projected during Q&A.
- [ ] Verbally confirm that the **4 effective scope blocks were delivered** (Block 1 Product, Block 2 Policy with Block 5 Clauses integrated, Block 3 Claims, Block 6 Reporting).
- [ ] Remind the client that **Reinsurance and Billing/Collections are out of today's scope** — don't let the impression form that they were forgotten.
- [ ] Open general Q&A.

---

## Appendix A — Full block inventory (quick reference)

### Dashboards (3)
| Title | ID | URL |
|---|---|---|
| Producción Pyme 2026 | 01Zg8000001l9nFEAQ | `/lightning/r/Dashboard/01Zg8000001l9nFEAQ/view` |
| Renovaciones Pyme 2026 | 01Zg8000001l9nGEAQ | `/lightning/r/Dashboard/01Zg8000001l9nGEAQ/view` |
| Siniestralidad Pyme 2026 | 01Zg8000001l9nHEAQ | `/lightning/r/Dashboard/01Zg8000001l9nHEAQ/view` |

### Reports (11) — Folder "Seguros ALFA Pyme"
| # | Title | ID | URL |
|---|---|---|---|
| 1 | Cartera Pyme por Industria del Cliente | 00Og80000045mGDEAY | `/lightning/r/Report/00Og80000045mGDEAY/view` |
| 2 | Coberturas Activas Pyme por Tipo | 00Og80000045mGEEAY | `/lightning/r/Report/00Og80000045mGEEAY/view` |
| 3 | Loss Ratio Pyme | 00Og80000045mGFEAY | `/lightning/r/Report/00Og80000045mGFEAY/view` |
| 4 | Pagos Aprobados vs Pendientes Pyme | 00Og80000045mGGEAY | `/lightning/r/Report/00Og80000045mGGEAY/view` |
| 5 | Prima Emitida por Plan Pyme | 00Og80000045mGJEAY | `/lightning/r/Report/00Og80000045mGJEAY/view` |
| 6 | Prima Emitida por Producto Pyme | 00Og80000045mGKEAY | `/lightning/r/Report/00Og80000045mGKEAY/view` |
| 7 | Pólizas Pyme por Status | 00Og80000045mGIEAY | `/lightning/r/Report/00Og80000045mGIEAY/view` |
| 8 | Pólizas Pyme Próximas a Vencer 90 Días | 00Og80000045mGHEAY | `/lightning/r/Report/00Og80000045mGHEAY/view` |
| 9 | Reserva Total Constituida Pyme | 00Og80000045mGLEAY | `/lightning/r/Report/00Og80000045mGLEAY/view` |
| 10 | Siniestros Pyme por Estado | 00Og80000045mGMEAY | `/lightning/r/Report/00Og80000045mGMEAY/view` |
| 11 | Total Prima Emitida Pyme | 00Og80000045mGNEAY | `/lightning/r/Report/00Og80000045mGNEAY/view` |

### Folders
| Type | Name | DeveloperName | ID |
|---|---|---|---|
| Report folder | Seguros ALFA Pyme | Seguros_ALFA_Pyme | 00lg8000003rGiXAAU |
| Dashboard folder | Seguros ALFA Pyme | Seguros_ALFA_Pyme | 00lg8000003rRd3AAE |

---

## Appendix B — Known gotchas

- The **11 reports have NO Description populated**. If the client asks "what does each one measure", explain verbally — use the **Appendix C** table for a quick live lookup. Consider populating Description before Thursday, July 9, 2026 (nice-to-have).
- The folder has **two entries** in the org (one for Reports, another for Dashboards) with the same DeveloperName. This is standard Salesforce behavior, not a bug — don't flag it as an issue if someone spots it in the technical detail.
- The folder is named **"Seguros ALFA Pyme" with spaces** in Name (visible in the UI) and **Seguros_ALFA_Pyme with underscores** in DeveloperName (for SOQL queries). When demoing, filter in the app using the Name with spaces.
- Dashboard IDs (`01Zg80...`) and report IDs (`00Og80...`) are **stable only in the `ins-qbranch-alfa` org** — if for some reason we had to replicate in another org, they must be re-queried via SOQL, never hardcoded.
- The demo user is on `en_US` — all **UI labels** (Reports, Dashboards, Subscribe, Refresh, Edit, Save, Filters, Group Rows, etc.) render in English. The **data and report/dashboard/folder names are in Spanish**. Briefly acknowledge this if a client attendee asks.
- **Terminology to preserve in talk tracks** (don't confuse with older names from commercial material): the policy sObject is `InsurancePolicy` (not `PolicyContract`), the premium is `PremiumAmount` (not `PolicyPremium`), the expiration date is `ExpirationDate` (not `EndDate`). The claim sObject is `Claim` (not `InsuranceClaim`). The approved claim payment is `ClaimCoveragePaymentDetail.AdjustedAmount` (not `ClaimPayment.TotalPaidAmount`). Reserves live on `ClaimCoverage.LossReserveAmount` and `ClaimCoverage.ExpenseReserveAmount` (not a generic `ReserveAmount` on the claim).

---

## Appendix C — Definition of the 11 reports (quick lookup for live Q&A)

Use: if the client asks "what does report X measure exactly", read from this table. All descriptions align with the actual objects and fields from Blocks 1-3.

| # | Report | What it measures | Main object | Key fields / grouping |
|---|---|---|---|---|
| 1 | Cartera Pyme por Industria del Cliente | Distribution of Pyme policies by the Account holder's industry — risk concentration read | `InsurancePolicy` + `Account` | Grouped by `Account.Industry`; policy count and sum of `PremiumAmount` |
| 2 | Coberturas Activas Pyme por Tipo | Count of active coverages by type (Responsabilidad Civil, Incendio, Robo, etc.) — the Block 1 catalog | `PolicyCoverage` over Pyme `InsurancePolicy` | Grouped by coverage type |
| 3 | Loss Ratio Pyme | Claims ratio: claim payments over premium written — technical profitability thermometer | Cross-object: `ClaimCoveragePaymentDetail` / `InsurancePolicy` | Row-level formula: SUM(`AdjustedAmount`) / SUM(`PremiumAmount`); grouped by product |
| 4 | Pagos Aprobados vs Pendientes Pyme | Distribution of claim payments by approval status — liquidity and operational management | `ClaimCoveragePaymentDetail` | Grouped by status; sum of `AdjustedAmount` |
| 5 | Prima Emitida por Plan Pyme | Premium sum by plan (Esencial / Empresarial / Corporativo) from Block 1 | `InsurancePolicy` | Grouped by Plan; sum of `PremiumAmount` |
| 6 | Prima Emitida por Producto Pyme | Premium sum by product (Seguro Pyme Integral and variants) | `InsurancePolicy` | Grouped by `Product2.Name`; sum of `PremiumAmount` |
| 7 | Pólizas Pyme por Status | Portfolio distribution by policy status (Active, Expired, Cancelled, etc.) | `InsurancePolicy` | Grouped by `Status`; policy count |
| 8 | Pólizas Pyme Próximas a Vencer 90 Días | Renewal pipeline: policies with `ExpirationDate` in the next 90 days | `InsurancePolicy` | Filter `ExpirationDate = NEXT 90 DAYS`; grouped by month or product |
| 9 | Reserva Total Constituida Pyme | Total provisioned reserve — data point for the accounting close | `ClaimCoverage` | Sum of `LossReserveAmount` + `ExpenseReserveAmount` |
| 10 | Siniestros Pyme por Estado | Claims funnel by stage of the Block 3 lifecycle (Submitted → Under Investigation → Approved → Paid → Closed) | `Claim` | Grouped by `Claim.Status`; count |
| 11 | Total Prima Emitida Pyme | Underwriting KPI: total premium sum for the Pyme portfolio | `InsurancePolicy` | Sum of `PremiumAmount`; ungrouped (master total) |

**Note**: any report can be re-grouped live by adding/removing groups from Edit → Groups. Demonstrable example if the client asks: open "Total Prima Emitida Pyme" → Edit → add `Account.Industry` as a group → Run → show the new view. Close without saving.
