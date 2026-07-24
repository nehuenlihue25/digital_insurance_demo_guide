# Seguros ALFA Runbooks — Master Index and Checklist

**Seguros ALFA RFP presentation on Salesforce Insurance on Core**
**Date:** Thursday, 2026-07-09
**Time:** 8:00 AM – 2:00 PM Colombia time (COT, UTC-5)
**Format:** Teams (virtual)
**Presenter:** the presenting SE
**Technical backup:** (reach via team Slack)
**Demo org:** `ins-qbranch-alfa` — https://storm-c90aab66569c63.my.salesforce.com

---

> ⚠️ **The Salesforce IDs and Storm URLs below are from the original engagement — they will not match your org.** Before rehearsing this runbook against your own IDO, run:
>
> ```bash
> ./demo-metadata/scripts/00c-resolve-ids.sh <your-org-alias>
> ```
>
> That prints every ID and URL the runbook references, resolved against your org. Copy-paste them into a local copy of this runbook (or `source` the `--format=env` output to have them as shell variables). The Salesforce IDs in the FINS QBranch IDO **change every time the IDO is provisioned** — never hardcode them.


## 0. How to use this document

This file is the **starting point**. Read it first, run the checklist, and only then open the four block runbooks. Each block runbook assumes the master checklist has already been executed and that you have the org open with the correct tabs.

> ⚠️ **Org note (do not skip):** these runbooks are written for the IDO **`FINS QBranch - INS on Core IDO`**, provisioned from the **STORM app in Slack** or **Solutions Workspace**. It's the only org type where every PSL and setup dependency (Digital Insurance + Revenue Cloud Advanced + Product Configurator + OmniStudio + Context Service + Salesforce Pricing) is pre-provisioned. Using any other org means chasing license and setup gaps for hours before the click paths become executable.

Recommended order for Wednesday night, 2026-07-08:

1. Read this INDEX in full (15 min).
2. Execute the **Pre-demo checklist (Wednesday night)** section (30 min).
3. Read the four runbooks in order: block1 → block2 → block3 → block6 (60-90 min).
4. Sleep. Come back Thursday at 7:00 AM and run the **Pre-demo checklist (Thursday 7:00 AM)** (30 min).
5. 7:45 AM open Teams, verify audio, share screen.
6. 8:00 AM start.

---

## 1. Agenda for the day (2026-07-09)

| Time | Duration | Block | Content | Runbook |
|------|----------|-------|---------|---------|
| 8:00 - 8:15 | 15 min | Opening | Introductions, context, scope of the presentation, what's covered and what isn't | This file |
| 8:15 - 8:45 | 30 min | **Block 1** | Modular, plan-based SMB product configuration | `RUNBOOK_BLOCK1_PYME_PRODUCT.md` |
| 8:45 - 8:50 | 5 min | Transition | Quick product questions, transition to policy | — |
| 8:50 - 9:35 | 45 min | **Block 2** | Full policy lifecycle (issuance, endorsement, renewal, cancellation, payment methods, clauses) + architecture for cobranza/reintegros/archivos bancarios | `RUNBOOK_BLOCK2_POLICY_LIFECYCLE.md` |
| 9:20 - 9:35 | 15 min | Coffee break | — | — |
| 9:35 - 10:20 | 45 min | **Block 3** | Full claims lifecycle | `RUNBOOK_BLOCK3_CLAIMS.md` |
| 10:20 - 10:30 | 10 min | Transition | Close claims, start reporting | — |
| 10:30 - 11:00 | 30 min | **Block 6** | Reporting and executive dashboards | `RUNBOOK_BLOCK6_REPORTING.md` |
| 11:00 - 11:15 | 15 min | Break | — | — |
| 11:15 - 11:30 | 15 min | Scope not covered | Honest declaration on Block 4 (Reinsurance) and original Block 5 (Billing) — position roadmap | This file |
| 11:30 - 13:00 | 90 min | **Open Q&A** | Client questions about what was demonstrated plus business/technical questions | This file |
| 13:00 - 13:30 | 30 min | Close | Next steps, post-demo deliverables, decision timeline | This file |
| 13:30 - 14:00 | 30 min | Buffer | Reserved for delays or additional questions | — |

**Critical note:** the client is strict on the schedule. If any block runs long, cut intermediate Q&A and save everything for the final 90-minute block.

---

## 2. Pre-demo checklist (Wednesday night, 2026-07-08)

### 2.1 Access and session

- [ ] Log in to the `ins-qbranch-alfa` org with the demo user (not admin, not personal).
- [ ] Verify the user is in `en_US` locale (labels render in English — important so nothing surprises us live). Mention this to the client during the opening: "labels will render in English because that's Salesforce standard; the data is in Spanish because we loaded it."
- [ ] Confirm the session doesn't expire: open Setup → Session Settings → verify timeout ≥ 8 hours.
- [ ] Keep username/password noted somewhere accessible in case a re-login is needed.
- [ ] Test 2FA / SSO — no MFA prompt should trigger mid-demo.

### 2.2 Apps that must be accessible

- [ ] **Product Catalog Management** (for Block 1) — App Launcher → nine-dot icon → search and open.
- [ ] **Insurance Agent Console** (for Blocks 2 and 3) — verify it appears in App Launcher.
- [ ] **Reports** and **Dashboards** (for Block 6) — accessible as standard tabs.
- [ ] If any app is missing, check App Permissions on the profile BEFORE Thursday.

### 2.3 Live verification of each block (end-to-end)

**Block 1 — Product:**
- [ ] Open https://storm-c90aab66569c63.my.salesforce.com/lightning/r/Product2/01tg8000003hS49AAE/view
- [ ] Confirm "Plan Empresarial" appears with Type=Bundle.
- [ ] Click the **Structure** tab and verify the hierarchical tree Bundle → Component Groups (Coberturas, Establecimiento) → 6 coverages.
- [ ] Click the **Attributes** tab — verify the 8 attributes are listed.
- [ ] Open one child coverage (e.g., Incendio y Aliados, 01tg8000003hRo1AAE) and confirm its PADs.

**Block 2 — Policy:**
- [ ] Open /lightning/r/InsurancePolicy/0YTg80000000hJVGAY/view — POL-PYME-2026-0001.
- [ ] Verify header: Status=In Force, PremiumAmount=2,400,000, EffectiveDate=2026-06-01.
- [ ] Click **Policy Structure** — tree Policy → 6 Coverages.
- [ ] Click **Related** — confirm Coverages appear (Transactions and Clauses do NOT appear here — this is the known gotcha).
- [ ] Pre-open in background tabs:
  - `/lightning/o/InsurancePolicyTransaction/list?filterName=Recent` (to show the 4 transactions via list view — issuance, endorsement, renewal, cancellation)
  - `/lightning/o/InsurancePolicyProductClause/list?filterName=Recent` (to show the 6 clauses)
- [ ] Alternative: open the 4 transactions and 6 clauses directly in pre-loaded tabs.

**Block 3 — Claim:**
- [ ] Open /lightning/r/Claim/0Zkg80000000awLCAQ/view — SIN-PYME-2026-0001.
- [ ] Verify Status=Coverage Confirmed, Severity=High, EstimatedAmount=48MM.
- [ ] Click the tabs: Details, Participants, Financials, Related — confirm each one loads.
- [ ] Open ClaimCoverage CC-SIN-PYME-2026-0001-Incendio (0kPg80000000OITEA2) and verify LossReserve=45MM + ExpenseReserve=5MM.
- [ ] Open CCPD-01 (0l2g80000000PfxAAE) — Paid 32MM.
- [ ] Open CCPD-02 (0l2g80000000PhZAAU) — Pending Authority, Draft.

**Block 6 — Reporting:**
- [ ] Open /lightning/r/Dashboard/01Zg8000001l9nFEAQ/view — Producción Pyme 2026.
- [ ] Click **Refresh** on the dashboard and wait for all widgets to load.
- [ ] Repeat for Renovaciones (01Zg8000001l9nGEAQ) and Siniestralidad (01Zg8000001l9nHEAQ).
- [ ] Reports app → Folder "Seguros ALFA Pyme" → confirm the 11 listed reports.

### 2.4 Tabs to keep open in the browser (sequential order)

Suggestion: use a single browser with tabs ordered left to right in the order of the demo. Chrome/Edge tab groups by color:

**Block 1 group (blue):**
1. Plan Empresarial Product2 view
2. Structure already open if possible
3. One child coverage (Incendio y Aliados) as backup

**Block 2 group (green):**
4. POL-PYME-2026-0001 InsurancePolicy view
5. Policy Structure tab
6. InsurancePolicyTransaction list view
7. InsurancePolicyProductClause list view
8. Clause "Coaseguro 10%" (1VGg800000008QbGAI) — the only manual one, good story

**Block 3 group (red):**
9. Claim SIN-PYME-2026-0001
10. ClaimCoverage CC-SIN-PYME-2026-0001-Incendio
11. ClaimCoveragePaymentDetail CCPD-01 (Paid)
12. ClaimCoveragePaymentDetail CCPD-02 (Draft)

**Block 6 group (yellow):**
13. Dashboard Producción Pyme 2026
14. Dashboard Renovaciones Pyme 2026
15. Dashboard Siniestralidad Pyme 2026
16. Reports folder "Seguros ALFA Pyme"

**Total: 16 pre-loaded tabs.** No more — the browser slows down and gets confusing.

### 2.5 Backup screenshots

For each block, keep 3-5 pre-captured screenshots in a local folder in case the org lags or drops mid-demo. Suggested format:

- `~/demo-alfa/block1/01-plan-empresarial-structure.png`
- `~/demo-alfa/block1/02-cobertura-incendio-pads.png`
- `~/demo-alfa/block2/01-policy-header.png`
- `~/demo-alfa/block2/02-policy-structure.png`
- `~/demo-alfa/block2/03-transactions-list.png`
- `~/demo-alfa/block2/04-clauses-manual-vs-auto.png`
- `~/demo-alfa/block3/01-claim-header.png`
- `~/demo-alfa/block3/02-claim-participants.png`
- `~/demo-alfa/block3/03-claim-coverage-reservas.png`
- `~/demo-alfa/block3/04-payment-details.png`
- `~/demo-alfa/block6/01-dashboard-produccion.png`
- `~/demo-alfa/block6/02-dashboard-siniestralidad.png`
- `~/demo-alfa/block6/03-reports-folder.png`

If something fails live: "Let me show you a screenshot of this same screen we captured yesterday while we reload."

### 2.6 Runbook review

- [ ] `RUNBOOK_BLOCK1_PYME_PRODUCT.md` — read in full and walked through step by step at least once.
- [ ] `RUNBOOK_BLOCK2_POLICY_LIFECYCLE.md` — read in full, paying special attention to the Transactions/Clauses layout gotcha.
- [ ] `RUNBOOK_BLOCK3_CLAIMS.md` — read in full, understand the story of reserve + one payment made + another pending authority.
- [ ] `RUNBOOK_BLOCK6_REPORTING.md` — read in full, know how to refresh dashboards.

### 2.7 Financial figures to memorize (so we don't hesitate live)

Commit these numbers to memory:

- **Total premium for POL-PYME-2026-0001:** 2,400,000 COP
- **Breakdown:** Incendio 800k + RC 600k + Robo 400k + Equipo 300k + Rotura 200k + Sustracción 100k = 2,400,000 ✓
- **Coverage period:** 2026-06-01 to 2027-05-31
- **Estimated claim amount:** 48,000,000 COP
- **Total reserve set:** 50,000,000 COP (45 direct loss + 5 business interruption)
- **Paid to date:** 32,000,000 COP (oven)
- **Pending authorization:** 8,000,000 COP (business interruption)

If the client asks "why is the reserve (50MM) larger than the estimate (48MM)?" — answer: "because the reserve includes adjustment expenses and contingency on top of the estimated direct damage — standard actuarial practice."

---

## 3. Pre-demo checklist (Thursday, 2026-07-09 at 7:00 AM)

- [ ] Laptop charged to 100%. Power cable plugged in throughout the demo.
- [ ] Internet: wired connection preferred over WiFi. If no cable, mobile hotspot as backup.
- [ ] Close Slack, email, notifications — Do Not Disturb mode enabled on macOS.
- [ ] Fresh login to the org — avoid last night's sessions that may have expired.
- [ ] Re-open the 16 tabs from checklist 2.4.
- [ ] Refresh the 3 Block 6 dashboards (so we don't have to wait for refresh live).
- [ ] Verify browser zoom at 100% (or 110% if it looks small when screen-sharing).
- [ ] Hide the bookmarks bar for more vertical space.
- [ ] Have this INDEX file open on a secondary monitor or printed.
- [ ] Have the 4 runbooks open on the secondary monitor as well.
- [ ] Water bottle nearby.
- [ ] 7:45 AM open Teams, join the meeting, test audio and video.
- [ ] 7:50 AM share screen, verify the client sees the correct screen (not the secondary monitor).
- [ ] 7:55 AM greeting message, wait for client attendees to join.
- [ ] 8:00 AM start on time.

---

## 4. Context to present at the start (8:00 - 8:15)

### 4.1 Suggested opening line

*(sample script — deliver in the client's language)*

> "Good morning Seguros ALFA team. I'm the presenting SE, Solution Engineer at Salesforce. I'll be with you today for this technical presentation of the RFP, where we'll show you real functional evidence running on a Salesforce Insurance on Core org configured specifically for the SMB case you described. You won't see slides with screenshots — you'll see the product working live, with data, with flows, with business logic executing."

### 4.2 Locale clarification (important to do early)

> "One note before we begin: my demo user is in English because that's the Salesforce standard, and we didn't want to localize labels that you may later want to adjust your own way. You'll see terms like 'Insurance Policy', 'Claim', 'Coverage' — all the data we loaded (product names, coverages, clauses, claims) is in Spanish because that's the business data. When you receive your org, we'll define together what stays in English and what gets translated."

### 4.3 Scope of the presentation — what's covered and what isn't

> "In the RFP we originally defined 6 demonstration blocks. Today we're going to fulfill 4 of those blocks with complete functional demo, and I want to be transparent about the other 2 from the start."

**Blocks covered today with live demo:**

1. **Block 1 — Modular, plan-based SMB product configuration:** you'll see how a Bundle product with simple coverages, attributes, and classifications is configured.
2. **Block 2 — Full policy lifecycle:** quoting, issuance, endorsement, and contract clauses (includes what was originally Block 5 on InsuranceClauses).
3. **Block 3 — Claims:** intake, participants, damaged items, reserves, partial payments, authorization workflow.
4. **Block 6 — Reporting and dashboards:** 3 executive dashboards and 11 operational reports.

**Blocks NOT demonstrated today (honest declaration):**

5. **Block 4 — Reinsurance:** functionality present in Salesforce Insurance on Core, but not configured in this presentation org. Implementation roadmap in phase 2.
6. **Original Block 5 — Billing:** the Salesforce billing module (Revenue Cloud / Salesforce Billing) integrates with Insurance on Core but requires additional licensing. Covered as a target architecture component but not as a live demo today.

> "We prefer to be direct about this rather than improvise. At the end we have 90 minutes of open Q&A where we can dive into any block in detail, including the two we don't demonstrate today."

### 4.4 Structure of each block

> "Each block will follow the same structure: business context (what problem does it solve?), live functional demo (what does it look like running?), and technical architecture (how is it built underneath?). At the end of each block there are 3-5 minutes for specific questions; deeper questions we save for the Q&A at 11:30."

---

## 5. Runbook index

The 4 runbooks are the literal step-by-step guide to executing each block. the presenting SE: read them in full before Thursday.

| File | Block | Duration | 1-liner |
|------|-------|----------|---------|
| `RUNBOOK_BLOCK1_PYME_PRODUCT.md` | Block 1 — Product | 30 min | How to show Plan Empresarial (Bundle) with 6 Simple coverages, 8 attributes, 2 ProductClassifications, and 2 ProductComponentGroups; canonical path App Launcher → Product Catalog Management → Products → Plan Empresarial → Structure tab. |
| `RUNBOOK_BLOCK2_POLICY_LIFECYCLE.md` | Block 2 — Policy | 45 min | How to show POL-PYME-2026-0001 with its 6 coverages, 4 transactions (Issuance + Endorsement + Renewal 2027 + Cancellation Request), 6 clauses (5 auto + 1 manual Coaseguro 10%), and 2 CardPaymentMethods on file. Includes section 5 with the architecture for recurring collection scheduling, retry logic, integration and bank file generation (the pieces beyond native Digital Insurance). Also includes a workaround so Transactions and Clauses are visible despite the default layout not exposing them. |
| `RUNBOOK_BLOCK3_CLAIMS.md` | Block 3 — Claim | 45 min | How to show SIN-PYME-2026-0001 with 3 participants, 3 items, 1 ClaimCoverage with 50MM reserves, 2 payment details (32MM Paid + 8MM Pending Authority), and ClaimPaymentSummary in Pending Payment. |
| `RUNBOOK_BLOCK6_REPORTING.md` | Block 6 — Reporting | 30 min | How to show the 3 dashboards (Producción / Renovaciones / Siniestralidad Pyme 2026) and the 11 reports in the "Seguros ALFA Pyme" folder; which report closes the claims narrative connecting to Block 3. |

The runbooks live alongside this file in the technical backup's Grupo Aval Insurance project. Coordinate with him via Slack if you can't find them.

---

## 6. Open Q&A at the end (11:30 - 13:00, 90 min)

### 6.1 Suggested format

- 5 min intro: "we're opening the floor for questions on any block, on general architecture, or on features we didn't cover today."
- Client questions in the order they arrive.
- If nobody asks first, keep 2-3 pre-baked questions ready to prompt: "one question that usually comes up in similar implementations is X — is that something you're also interested in?"

### 6.2 How to pivot when the client asks about features not covered

**Anticipated frequent questions and model answers:**

**"How would Reinsurance work in Salesforce?"**
> "Salesforce Insurance on Core has the complete data model for Reinsurance: cession contracts, proportional and non-proportional treaties, retrocession, shared claims. In this presentation org it's not populated with data, but we can schedule a specific technical session next week where we show you the model activated in another org. the technical backup is the point of contact to coordinate that."

**"How does billing and collections integrate?"**
> "There are two paths: Salesforce Revenue Cloud (new, unified billing + subscriptions) which integrates natively with Insurance on Core, or integration with your current financial core (SAP, Oracle) via MuleSoft. Either route is supported. The choice depends on the core modernization roadmap you have defined — a topic for an architecture conversation with our Solutions team."

**"Can this integrate with our current core?"**
> "Yes, and there are 3 proven patterns: (1) Real-time bidirectional sync via MuleSoft or Platform Events for critical operations like issuance and claims; (2) Batch with file drops for less critical processes; (3) Data federation via Salesforce Connect if you don't want to replicate. Which one to use depends on the SLAs and on what's the system of record for each data domain."

**"Data Cloud / AI / Einstein?"**
> "Everything you saw today is ready to be connected to Data Cloud to consolidate data from other systems, and to Einstein / Agentforce for cases like dynamic pricing, fraud detection in claims, and underwriting assistants. We didn't demo it today because the RFP focus was core insurance, but it's on the same stack and doesn't require an additional migration. I can schedule a dedicated Agentforce for Insurance session if you're interested."

**"How much does it cost?"**
> "Commercial aspects of this component are handled by the account AE [name]. I'm here today in a technical role and I prefer not to give informal figures that might bias the decision. We can coordinate a commercial session with the AE this same week."

**"What if our challenge is X (feature not covered in the demo)?"**
> Standard response: "Great question. In the Salesforce Insurance on Core ecosystem, X is typically solved with [generic approach]. We don't have it configured in this presentation org because the focus was the end-to-end SMB cycle, but it's a known case and we have client references in the region who have it implemented. We can schedule a session focused on that case."

### 6.3 How to position the roadmap without committing to dates

- Never say "we'll have that ready in Q2" during a demo.
- Do say: "that's in the product today" or "that's on the public product roadmap — the Salesforce product team publishes the roadmap in the Trailblazer Community."
- If the client asks for a commitment: "I can take the question to the product team and come back with an official answer next week."

### 6.4 How to close the Q&A

- 12:55: "let's take 5 minutes to answer the last 2-3 questions and then move to closing and next steps."
- 13:00: "thank you for the questions. Before we say goodbye, I want to run through the next steps quickly."
- 13:00 - 13:30 close: deliverables (recording, complementary deck, architecture proposal), decision timeline the client proposes, next meeting.

---

## 7. Live crisis management

### 7.1 If the org doesn't load

1. Refresh (Cmd+R). If it takes >10 sec, don't wait.
2. "Let's lean on a screenshot for a moment while the platform responds" — pull a screenshot from the `~/demo-alfa/` folder.
3. Continue the narrative while it recovers.
4. If it's still down after 3 min: discreet Slack message to the technical backup and change block order (start with Block 6 dashboards which are cached).

### 7.2 If the client asks a question you can't answer

- "Excellent question. I'd rather validate it with the product team than improvise. I'm noting it down and I'll come back with an official answer this week."
- Write it down visibly in a notebook.
- Don't make things up. The client values honesty more than omniscience.

### 7.3 If the client insists on a block not covered (Reinsurance / Billing)

- Don't improvise a live demo. The org doesn't have that data.
- "I'd rather show it to you properly in a dedicated session next week than improvise here. the technical backup will coordinate the date."

### 7.4 If time is running short

- Block priority by RFP strategic importance: 2 > 3 > 1 > 6.
- If Block 1 runs long: cut at the attributes view, don't walk through all 8 in detail.
- If Block 2 runs long: show only 1 manual clause (Coaseguro 10%) and 1 transaction, not both.
- If Block 3 runs long: cut at payments, don't go into Action Plan or Claim Team.
- If Block 6 runs long: show only Siniestralidad Pyme 2026 (the most visual one) and skip the other 2.

---

## 8. Emergency contact

**the technical backup** — direct Slack DM throughout the demo.

the technical backup has admin access to the org and can:
- Execute SOQL live if data appears wrong.
- Regenerate records if something got corrupted.
- Confirm IDs, values, fields if in doubt.
- Respond via chat while the presenting SE keeps talking live.

**Rule:** during the demo, if something looks off, don't correct it in front of the client. Continue, and message the technical backup via Slack. He resolves in the background.

**Reminder:** the industry SE is on PTO. Don't contact her unless it's absolutely critical and the technical backup doesn't respond within 5 min.

---

## 9. After the demo (Thursday 13:30 - 14:00 and Friday)

### 9.1 Closing in the session

- Confirm next steps with concrete dates.
- Ask for quick feedback: "Which block had the most impact? What still needs deeper exploration?"
- Confirm follow-up recipients.

### 9.2 Follow-up Friday 2026-07-10

- Send by email: session recording (Teams generates it automatically).
- Send the 4 runbooks converted to PDF (optional, if the client requested them).
- Send pending questions with official answers.
- Confirm next meeting.

### 9.3 Internal post-mortem with the technical backup (Friday or Monday)

- What worked, what failed, what to improve for future presentations.
- Update the runbooks with lessons learned.
- Document new client questions that weren't anticipated.

---

## 10. Final 1-hour-out checklist (Thursday 7:00 - 8:00)

- [ ] Coffee / breakfast.
- [ ] Quick review of this INDEX (10 min).
- [ ] Quick review of the 4 runbooks (20 min, skim, don't read in full).
- [ ] All 16 tabs open and verified.
- [ ] Backup screenshots accessible.
- [ ] the technical backup confirmed on Slack as available.
- [ ] Teams open with the meeting room ready.
- [ ] Camera and microphone tested.
- [ ] Screen sharing configured.
- [ ] Smile. You've got this.

---

**Last updated:** 2026-07-07 .
**Next review:** Wednesday night, 2026-07-08 with the presenting SE.
