# Revised Plan — Seguros ALFA Presentation 2026-07-09

## 1. Answer to Q1 — Enabling Claim extended objects in ins-qbranch-alfa

**Honest diagnosis:** The sObjects the user expected (ClaimAssessment, ClaimReserve, ClaimPayment, ClaimCoveragePayment, ClaimAdjuster, ClaimAdjustment) **do NOT exist** as standard objects in Digital Insurance / Insurance on Core release 260. This is not a licensing problem — the names are simply incorrect. Documentation research confirms this:

- There is no `ClaimAssessment` — assessment is performed by the adjuster over `Claim`, `ClaimItem`, `ClaimCoverage`, `ClaimCoveragePaymentDetail` ([Insurance Claims Management data model](https://developer.salesforce.com/docs/platform/data-models/guide/insurance-claims-management.html)).
- There is no `ClaimReserve` — reserves live in `ClaimCoverage` + `ClaimCoverageReserveDetail` + `ClaimCovReserveAdjustment` (API 52.0+).
- There is no `ClaimPayment` — the header is `ClaimPaymentSummary` (API 51.0+) and the lines are `ClaimCoveragePaymentDetail` (API 52.0+) + `ClaimCoveragePaymentAdjustment`.
- There is no `ClaimAdjuster` / `ClaimAdjustment` as sObjects — the adjuster is a person/role assigned via Owner + Omni-Channel routing. `ClaimCovPaymentAdjustment` / `ClaimCovReserveAdjustment` are financial adjustments, not people.

**Real objects required** in ins-qbranch-alfa for block 3: `ClaimCoverage`, `ClaimCoveragePaymentDetail`, `ClaimCoveragePaymentAdjustment`, `ClaimCoverageReserveDetail`, `ClaimCovReserveAdjustment`, `ClaimPaymentSummary`.

**Corrected reading of the evidence (critique #1):** The `q-claim-psl` audit reports 24 Active PSLs but zero writeable/queryable records on the extended objects. **Active PSLs in a trial org do not equal a provisioned runtime add-on** — this is a known pattern in Storm orgs where the PSL appears listed without the Claims Management engine actually being turned on. Therefore: **this is NOT a Setup toggle, it's a missing add-on provisioning**. There is no cited documentation supporting the claim that an "Insurance Settings" checkbox enables these sObjects in Insurance on Core 260 (the doc we cited earlier was for the legacy managed-package extension and does not apply).

**Consequence:** This becomes a **blocking case-with-Salesforce starting Tuesday 07:00 (not 14:00)**, not a toggle attempt. See section 6 for the new timing and the decision gate on Wednesday 12:00.

**Revised concrete steps:**

1. **Immediate ask to the presenting SE (Tuesday 07:00-09:00):** confirm with the account team whether `DigitalInsuranceClaimManagementAddOn` + PC + CC + `DigitalInsurancePolicyAdministrationAddOn` are effectively provisioned as runtime add-ons (not just PSL Active). If NOT → open a Sev-2 case with Salesforce immediately citing release 260 and the 6 non-queryable sObjects (audit evidence).
2. **In parallel, verify `DigitalInsurancePolicyAdministrationAddOn`** — block 2 depends on `InsPolicyService:createPolicyVersion` (see critique #4). If the Policy Administration add-on is also not provisioned, block 2 falls too. Dry-run query: try `SELECT Id FROM InsurancePolicyVersion LIMIT 1` and `SELECT Id FROM InsurancePolicyTransaction LIMIT 1` — if they fail, both blocks go to Plan B.
3. **Assign Permission Sets to the demo user** , corrected per the research fact for the adjuster persona (critique #2): `Claims Management`, `Digital Insurance Product Administration Runtime`, `Product Configurator`, `Product Catalog Management Viewer`, `Product Discovery User`, `Context Service Runtime`, `Stage Management User`, `Rule Engine Runtime`, `Omnistudio User`. **Removed** from the previous list: `Claims Administration`, `Product Catalog Management Designer`, `Product Discovery Admin`, `Digital Insurance Product Administration Management` — they do not appear in the research fact for the runtime persona and there is risk they may not exist as assignable PSLs in this org or require additional PSLs.
4. **Validate with SOQL:** `SELECT Id FROM ClaimCoverage LIMIT 1` + `ClaimCoveragePaymentDetail` + `ClaimPaymentSummary` + `ClaimCoverageReserveDetail` + `InsurancePolicyVersion`. If they respond → continue with base plan. If they fail → case opened Tuesday AM, decision gate Wednesday 12:00.
5. **Configure Claim Financials LWC** on the Claim record page + field sets on `ClaimCoveragePaymentDetail` per coverage ([customize payment detail form](https://help.salesforce.com/s/articleView?id=ind.insurance_customize_the_payment_detail_form_618950.htm&release=260&type=5)).

**Residual risk:** a case with Salesforce can take 24-72h; hence Plan B (section 7) is spelled out in detail, not as "a one-liner".

## 2. Answer to the main question — Consolidate the 4 blocks into ins-qbranch-alfa?

**RECOMMENDATION: YES — consolidate all 4 blocks into ins-qbranch-alfa.**

**Decisive reasons:**

1. **Q-Branch has Agentforce/Einstein licenses** (3105 Agentforce, Einstein Prompt Templates, Einstein for Financial Services) — key for blocks 3 and 6. `ido-aval-ins` only has 8 FINS prompt templates in English, none for claims.
2. **Claims Management PSLs are Active in Q-Branch** (although real runtime provisioning is under verification — section 1). In `ido-aval-ins` this was not audited and assuming its presence adds greater risk.
3. **InsuranceClause writeability confirmed in Q-Branch** — real insert `1T5g8000000009hCAA` + successful delete. Important note (critique #13): the real field is `Type`, NOT `ClauseType`. The CSVs in section 5 correctly use `Type`; GFT must confirm the header before loading.
4. **PCM writeable in Q-Branch** — 7 objects confirmed createable/updateable/deletable.
5. **InsurancePolicyTransaction has the picklists** that cover Endorsement/Renewal/Cancellation, BUT `InsPolicyService:createPolicyVersion` is NOT verified by org check (critique #4). It will be verified Tuesday AM as part of step 2 in section 1.
6. **Migrating Experience Cloud + OmniStudio between orgs is expensive** — 0.5-1 day just for bundle + DNS. Out of budget.

**What gets migrated from ido-aval-ins:** **nothing** (see revised section 3 — critique #3).

**What gets built fresh in Q-Branch (in Spanish):** complete Pyme product, clauses, coverages, accounts, policy, claim, dashboards, and **1 single custom prompt template in Spanish** cloned from the OOTB Summarize Insurance Claim.

## 3. Migration inventory (ido-aval-ins → ins-qbranch-alfa) — REVISED

**Critical change vs. the prior plan (critique #3):** the 2 FINS templates originally planned for migration (`FINS_Account_Activity_AI_Summary`, `FINS_Account_Executive_Brief`) are NOT claim-related, their bodies could not be inspected (explicit audit gap), and localizing them to Spanish likely takes more than 1h each. **They will not be migrated.** Block 3 uses cloning of the OOTB `Summarize Insurance Claim` as the sole source.

**Migration sub-total: 0 hours. 2h are recovered from the timeline.**

## 4. Build fresh in Spanish on ins-qbranch-alfa

### Block 1 — Modular Pyme product by plans (30 min)

**Root product:** `Seguro Pyme Integral` (Product2)
**Plans (Bundle Options via ProductRelatedComponent):** `Plan Esencial`, `Plan Empresarial`, `Plan Corporativo`
**Coverages:** `Responsabilidad Civil Extracontractual`, `Incendio y Aliados`, `Equipo Electrónico`, `Robo y Asalto Interior`, `Rotura de Maquinaria`, `Sustracción de Dinero y Valores`

**Revised AttributeDefinitions (critique #5 — clause tokens need dedicated attrs):**
- `Suma_Asegurada` (currency)
- `Deducible` (currency)
- `Actividad_Economica` (picklist: Comercio, Servicios, Manufactura, Tecnologia)
- `Numero_Empleados` (number)
- `Metros_Cuadrados_Local` (number)
- **`Porcentaje_Coaseguro`** (percent) — dedicated for the `porcentajeCoaseguro` token
- **`Sustancias_Prohibidas`** (multi-select picklist: Combustibles, Quimicos Peligrosos, Explosivos, Gases Comprimidos) — dedicated for the `sustanciasProhibidas` token
- **`Deducible_Minimo_Evento`** (currency) — dedicated for the `deducibleMinimo` token (separate from the general variable deductible)

**AttributeCategory:** `Datos_Pyme`, `Coberturas_Adicionales`, `Parametros_Clausulas`

**Product Rules:** exclusion `Actividad_Economica != Manufactura` blocks Rotura de Maquinaria on Plan Esencial.

**Effort:** 3h (Data Loader load respecting PCM order).

### Block 2 — Full policy lifecycle (30 min)

**Demo accounts:** `Panaderia La Espiga SAS`, `Ferreteria El Tornillo Ltda`, `Consultores Andinos SAS`
**Demo InsurancePolicy:** `POL-PYME-2026-0001`, PolicyStage `Issued`, EffectiveDate 2026-06-01.

**Language change (critique #9c):** the standard `LineOfBusiness` and `PolicyType` picklists ship with English values ("Property & Casualty", "BOP"). For the demo — relabel picklist values in Object Manager: "Property & Casualty" → "Daños Patrimoniales", "BOP (Business Owners)" → "Multirriesgo Pyme". Relabel takes 15 min and requires no special permissions.

**Endorsement (critique #4):** demonstrate only if step 2 of section 1 confirms `InsPolicyService:createPolicyVersion` responds and `DigitalInsurancePolicyAdministrationAddOn` is provisioned. **If it does NOT respond**: demonstrate the endorsement via **direct update on InsurancePolicyTransaction**, creating a record with `Type=Endorsement, Category=Endorsement` manually (SOQL/DataLoader) — less elegant but data-driven and works without the API service.

**Cancellation:** `CancellationReasonType = Non-Payment` + PolicyStage `Cancelled`.
**Renewal:** OOTB `Renew Policy` OmniScript — verify availability Tuesday.

**Effort:** 2h + 1h (endorsement path contingent on Tuesday check).

### Block 3 — Claims (45 min) — dependent on section 1

**Demo Claim:** `SIN-PYME-2026-0001` on POL-PYME-2026-0001, ClaimType `Incendio Parcial`, description in Spanish.
**ClaimParticipants:** Panadería La Espiga (Insured), the technical backup (Adjuster owner via Claim.OwnerId), Bomberos Bogotá (Witness).
**ClaimItems:** `Horno Industrial Rational` (Loss), `Estantería de Producto Terminado` (Loss), `Lucro Cesante 5 días` (Expense).
**ClaimCoverage** against `Incendio y Aliados`: loss reserve COP 45,000,000, expense reserve COP 5,000,000.
**ClaimCoveragePaymentDetail:** one Paid payment + another Pending Authority.

**Routing (critique #6):** verify Service Cloud license in Q-Branch as Tuesday AM step 3 (query: `SELECT Name, TotalLicenses, UsedLicenses FROM PermissionSetLicense WHERE MasterLabel LIKE '%Service Cloud%'`). **If Service Cloud is NOT provisioned**: use a simple **Queue Assignment** via Claim.OwnerId over a Queue-type Group (core Salesforce feature, does not require Service Cloud) — shows work assignment even if not skills-based Omni-Channel routing. Live narrative: "in production Omni-Channel is enabled for skills-based routing; here we show queue-based assignment".

**Einstein Summary (critique #9a):** clone the OOTB `Summarize Insurance Claim` to `Resumir_Siniestro_Pyme_ES` and translate instructions + expected output to Spanish. **This is a hard requirement, not optional** — a Colombian client cannot see English on screen. Budget: 2h Wednesday afternoon.

**Legacy data in Q-Branch (critique #9d):** the 24 Claims + 20 ClaimParticipants + 10 ClaimItems that already exist are probably in English. Before the demo:
- Create a List View `Siniestros_Pyme_Demo` filtering by `Name LIKE 'SIN-PYME-%'` as default on the Claim tab.
- Purge from the landing report/dashboard any claim without the `SIN-PYME-` prefix.
- Time: 30 min Wednesday night as part of dress rehearsal.

**Effort:** 4h (assuming enablement OK) + 30 min data hygiene.

### Block 6 — Reporting (30 min)

**CRM Analytics dashboards:**
- `Tablero_Siniestralidad_Pyme_2026` — Loss Ratio, open claims, reserves.
- `Tablero_Renovaciones_Pyme` — policies expiring in 60/90 days, YoY renewal rate.
- `Tablero_Produccion_Pyme` — premium by plan, by economic activity.

**Mandatory filter:** all dashboards filtered by `Name LIKE 'PYME-%' OR 'SIN-PYME-%' OR 'POL-PYME-%'` to exclude legacy English data.

**Effort:** 3h.

**Fresh-build sub-total: 3 + 3 + 4.5 + 3 = 13.5 hours.**

## 5. InsuranceClause plan

**Writeability confirmed** with insert `1T5g8000000009hCAA` + cleanup. Feature available in release 260 (org runs 260) — **the previous claim of "API 65.0+" was unsourced (critique #11); it is retracted**. If a client architect asks "GA since when": answer "available in the current release, refer to the official Object Reference" without citing a specific version.

**Required permission sets:** `Product Configuration Rules User`, `Manage Product Catalog`.

**Field name (critique #13):** the sObject field is literally `Type` (values: Clause, Exclusion). NOT `ClauseType`. The CSVs below use `Type`. GFT must validate the exact header before dataload — send explicit email with the note.

**Step 1 — InsuranceClause (6 records):**
| Name | ApiName | Code | **Type** | CreationMethod | ContentText |
|---|---|---|---|---|---|
| Cláusula General de Buena Fe | `Clausula_Buena_Fe` | `buenaFe` | Clause | AutoAdded | "El Asegurado declara que la información suministrada es veraz..." |
| Exclusión Actos Dolosos | `Exclusion_Actos_Dolosos` | `actosDolosos` | Exclusion | AutoAdded | "Quedan excluidos los daños derivados de actos dolosos..." |
| Exclusión Guerra y Terrorismo | `Exclusion_Guerra_Terrorismo` | `guerraTerrorismo` | Exclusion | AutoAdded | "No se cubren pérdidas por guerra, invasión..." |
| Cláusula de Coaseguro | `Clausula_Coaseguro` | `coaseguro` | Clause | Manual | "El Asegurado asume el {{porcentajeCoaseguro}}% de cada pérdida..." |
| Exclusión Actividades Extremas | `Exclusion_Actividades_Extremas` | `actividadesExtremas` | Exclusion | AutoAdded | "Se excluyen operaciones con {{sustanciasProhibidas}}." |
| Cláusula Deducible Mínimo | `Clausula_Deducible_Minimo` | `deducibleMinimo` | Clause | AutoAdded | "Deducible mínimo por evento: COP {{deducibleMinimo}}." |

**Step 2 — InsuranceProductClause:** 6 junctions against `Seguro Pyme Integral`, EffectiveDate 2026-01-01, ExpirationDate 2030-12-31.

**Step 3 — InsProductClauseVariableMap (CORRECTED mappings — critique #5):**
- `porcentajeCoaseguro` → AttributeDefinition **`Porcentaje_Coaseguro`** (percent)
- `sustanciasProhibidas` → AttributeDefinition **`Sustancias_Prohibidas`** (multi-select picklist)
- `deducibleMinimo` → AttributeDefinition **`Deducible_Minimo_Evento`** (currency)

The dedicated attributes are created in Block 1 (section 4) — ensuring correct semantics and matching type.

**Step 4 — InsurancePolicyProductClause:** when POL-PYME-2026-0001 is issued, materialize the 6 clauses.

**Effort:** 3h.

## 6. Revised timeline with decision gates

**Budget:** Tuesday afternoon 4h + full Wednesday 10h + Wednesday night 3h (wrapping at 23:00 — not overnight, critique #8) + Thursday early morning 2h = **19h effective.**

**Revised work:** 0h migration (2h recovered) + 13.5h fresh build + 3h clauses + 2h rehearsal + 2.5h buffer = **21h.** Slight over-run reduced to 2h with **structural buffer at 3 points** instead of 1h at the end.

**Sequencing reset (critique #12):** the ask to the presenting SE moves to **Monday 2026-07-06 (today, 07:00 EOD)** for confirmation before starting Tuesday AM. If his response does not arrive before Tuesday 08:00 → we start anyway with SOQL verification in parallel to the case.

### Monday 2026-07-06 (today)

- [ ] EOD — Ask the presenting SE for confirmation of add-on provisioning (Claims + Policy Admin). Send before closing the day.

### Tuesday 2026-07-07 (5h — 13:00-18:00)

- [ ] 13:00-14:00 — SOQL verification: `ClaimCoverage`, `ClaimCoveragePaymentDetail`, `ClaimPaymentSummary`, `ClaimCoverageReserveDetail`, `InsurancePolicyVersion`, `InsurancePolicyTransaction`, `PermissionSetLicense LIKE '%Service Cloud%'`. Document results.
- [ ] 14:00-15:00 — **If any claim/policy sObject fails:** open a Sev-2 case with Salesforce immediately citing release 260 and affected sObjects. Log ticket #. **If all respond:** proceed to next step.
- [ ] 14:00 (in parallel) — Assign corrected permission sets to the technical backup.
- [ ] 15:00-18:00 — Block 1: create the complete PCM catalog (including the 3 new dedicated AttributeDefinitions: Porcentaje_Coaseguro, Sustancias_Prohibidas, Deducible_Minimo_Evento).

**Implicit Tuesday buffer:** 4h of work inside a 5h block. If the case is pending, no time is lost on speculative toggles.

### Wednesday 2026-07-08 morning (5h — 08:00-13:00)

- [ ] 08:00-11:00 — Block 5 (InsuranceClause): load 3 levels + LWC on Product page. GFT validates the `Type` header before firing Data Loader.
- [ ] 11:00-12:00 — Block 2: accounts + POL-PYME-2026-0001. Relabel LineOfBusiness/PolicyType picklist values to Spanish.
- [ ] **12:00 — DECISION GATE block 3:** if the claims case is not resolved and sObjects still do not respond → activate Plan B claims (section 7). If resolved → continue with the base plan.
- [ ] 12:00-13:00 — Rehearse endorsement (createPolicyVersion or alternative path) + materialize 6 InsurancePolicyProductClause.

### Wednesday 2026-07-08 afternoon (5h — 14:00-19:00)

- [ ] 14:00-17:00 — Base Block 3 OR Plan B (per 12:00 decision): Claim + Participants + Items + Coverage + PaymentDetails; verify Service Cloud → if NOT, use a simple Queue.
- [ ] 17:00-19:00 — Clone and translate the `Summarize Insurance Claim` prompt template → `Resumir_Siniestro_Pyme_ES`. Instructions + few-shot examples entirely in Spanish. Test with SIN-PYME-2026-0001.

### Wednesday 2026-07-08 night (3h — 20:00-23:00)

- [ ] 20:00-22:00 — Block 6: 3 CRM Analytics dashboards with mandatory filter `Name LIKE 'PYME-%' etc.` Create default list views on Claim/Policy tabs filtering legacy data.
- [ ] 22:00-23:00 — End-to-end rehearsal 60 min block by block. **Cutoff at 23:00.**

**Structural buffer Wednesday night:** 23:00-Thursday 06:30 = 7.5h rest.

### Thursday 2026-07-09 early morning (1.5h — 06:30-08:00)

- [ ] 06:30-07:00 — Refresh data if anything broke + smoke test.
- [ ] 07:00-07:30 — **Real buffer:** recovery if the rehearsal caught bugs last night.
- [ ] 07:30-08:00 — Physical setup, browser tabs, backup screenshots.

**Total: 4.5h Tuesday effective + 13h Wednesday + 1.5h Thursday = 19h. Distributed buffer: 1h Tuesday + 30 min Wednesday + 30 min Thursday = 2h effective recovery.**

## 7. Risks, detailed Plan B, and asks

### Plan B claims — activated if Wednesday 12:00 decision gate says NO

**Trigger:** claim extended sObjects still return "sObject type not supported" by Wednesday 12:00 (25h before the demo).

**Alternative demo content (uses what DOES work):**
- Base Claim: `SIN-PYME-2026-0001` with Status, LossDate, ClaimType, Description, TotalClaimAmount.
- ClaimParticipants: the 3 roles (Insured, Adjuster, Witness).
- ClaimItem: 3 items with LossAmount.
- **Reserve and payment** shown as **custom fields on Claim** (fast: 3 custom fields `Reserva_Perdida__c`, `Reserva_Gasto__c`, `Monto_Pagado__c` on Claim). Narrative: "in production ClaimCoverage + ClaimCoveragePaymentDetail are used; here we show aggregates on Claim while the add-on provisioning is being completed".
- Target-architecture slide showing the real model (ClaimCoverage → CCPD → PaymentSummary) to answer "and what does it look like in production".
- Einstein Summary works the same — does not depend on ClaimCoverage.

**Plan B time budget:** 2h to create the 3 custom fields + populate data + prepare the architecture slide. Runs Wednesday 14:00-16:00 instead of base Block 3. Block 6 dashboards adjust to the custom fields.

**Plan B rehearsal:** 45 min extra Wednesday night (22:00-22:45) replacing part of the original Block 3 rehearsal.

### Agentforce — response if the client asks "where is the agent" (critique #14)

The `q-agentforce` audit confirms: Agentforce licenses present, PSLs and permission sets assignable, BUT zero GenAiPluginDefinition/BotDefinition configured. The current demo uses **Einstein Prompt Templates** (a distinct feature) for Claim Summary — not a built Agentforce Agent.

**Prepared response for the presentation:**
> "This block shows Einstein Prompt Templates as a GenAI capability applied to Insurance on Core. The next step on the roadmap — on the same platform and with the Agentforce licenses already provisioned in this org — is to build an Agentforce Service Agent on top of these same objects, with topics for FNOL, claim update, and payment follow-up. We have this defined as phase 2 of the roadmap and can schedule a dedicated Agentforce deep-dive session."

**No Agent is attempted within the timeline** — building topics + actions + guardrails in 2 days with no testing time carries high risk of failing live. Better to admit the scope and offer a follow-up session.

### Open show-stoppers

1. **Claims + policy admin add-on provisioning** — decision gate Wednesday 12:00, Plan B ready.
2. **Service Cloud license for Omni-Channel** — verification Tuesday 13:00, fallback to simple Queue.
3. **`InsPolicyService:createPolicyVersion`** — verification Tuesday 13:00, fallback to manual InsurancePolicyTransaction.
4. **Prompt template translation** — hard requirement, 2h budgeted Wednesday afternoon.
5. **Legacy English data** — mitigated with filtered list views + dashboards with prefix filters.

### Explicit asks (corrected sequencing — critique #12)

**To the presenting SE (deadline: MONDAY 2026-07-06 EOD, today):**
- Confirm with the account team whether `DigitalInsuranceClaimManagementAddOn`+PC+CC and `DigitalInsurancePolicyAdministrationAddOn` are effectively provisioned as runtime (not just PSLs Active) in ins-qbranch-alfa. If not, authorize opening of a Sev-2 case Tuesday 07:00.
- Approve 100% consolidation to ins-qbranch-alfa.

**To GFT (deadline: Tuesday 2026-07-07 18:00):**
- PCM load for Block 1 in parallel Wednesday AM (I'll hand over CSVs Tuesday 17:00). **Explicit note:** the field in InsuranceClause is `Type`, NOT `ClauseType`. Validate the header before firing.
- Review Block 6 dashboards Wednesday 22:00-23:00 while I rehearse.

**To management (deadline: Wednesday 2026-07-08 12:00):**
- Validate the narrative script. Joint rehearsal Wednesday 22:00.
- Confirm that Blocks 4 (Reinsurance) and 5 (Billing) remain out of scope with a roadmap slide.
- **New:** prepare a response to the Agentforce question if it comes up (pre-approved paragraph above).

**Final note on language:** everything user-facing is in Spanish — products, coverages, clauses, accounts, claims, dashboards, relabeled picklists, prompt template cloned and translated. List views filter out legacy English data. Zero English on-screen is a hard requirement, not optional.
---

## Appendix — SOQL verification of real objects in ins-qbranch-alfa (2026-07-07 02:36)

### Claim extended sObjects — 9 of 11 work

| sObject | Status | Records |
|---|---|---|
| ClaimCoverage | OK | 12 |
| ClaimCoveragePaymentDetail | OK | 6 |
| ClaimPaymentSummary | OK | 1 |
| ClaimCoverageReserveDetail | OK | 0 (queryable, no data) |
| ClaimCovReserveAdjustment | OK | 20 |
| ClaimRecovery | OK | 0 (queryable) |
| ClaimItem | OK | 10 |
| ClaimParticipant | OK | 20 |
| InsurancePolicyTransaction | OK | 2 |
| ClaimCoveragePaymentAdjustment | NOT SUPPORTED | — |
| InsurancePolicyVersion | NOT SUPPORTED | — |

### Claims Management PSL provisioning — confirmed real (not just Active)

All with expiration 2027-02-21 and some already with licenses assigned — refutes the concern in critique #1 about "PSL Active without provisioned runtime add-on":

| PSL | Used/Total |
|---|---|
| ClaimManagementAdmin | 1 / 20 |
| DigitalInsuranceClaimManagementAdmin | 0 / 20 |
| DigitalInsuranceClaimManagementUser | 0 / 20 |
| DigitalInsuranceClaimMgmtCCPsl | 0 / 20 |
| DigitalInsuranceClaimMgmtPCPsl | 0 / 20 |
| DigitalInsurancePolicyAdminUserPsl | 1 / 5 |
| DigitalInsurancePolicyAdminCCPsl | 0 / 5 |
| DigitalInsurancePolicyAdminPCPsl | 0 / 5 |

### Service Cloud / Omni-Channel — no Omni-Channel routing PSL visible

The only related PSLs in the org: `ServiceCloudVoicePsl` (voice), `ServiceCloudVoiceExternalTelephonyPsl`, `OmnichannelInventoryPsl` (retail inventory, not routing). **Go directly with the simple Queue fallback** — don't waste time searching for Omni-Channel routing in the presentation.

### Implications for the plan

1. **GO WITH BASE PLAN, NOT PLAN B.** All critical Block 3 sObjects respond with data — end-to-end claims demo is viable.
2. **2h saved on the timeline** — no need to create the 3 Plan B custom fields (`Reserva_Perdida__c`, etc.).
3. **Endorsement via manual InsurancePolicyTransaction** — `InsurancePolicyVersion` is not supported, therefore we do NOT use `createPolicyVersion`. We create an InsurancePolicyTransaction record with `Type=Endorsement` directly (path already contemplated in section 4 of the plan).
4. **ClaimCoveragePaymentAdjustment not available** — not critical. Payment adjustments can be narrated without showing the object (the aggregates in ClaimPaymentSummary are sufficient).
5. **Omni-Channel routing** — fallback to Queue Assignment via Claim.OwnerId already contemplated. Don't open a case for this.
6. **the technical backup already has ClaimManagementAdmin and DigitalInsurancePolicyAdminUserPsl assigned** (1/20 and 1/5 used) — likely these are the demo user's assignments. Still need to assign `DigitalInsuranceClaimManagementUser`, `DigitalInsuranceClaimManagementAdmin`, and the functional Permission Sets (Product Configurator, Product Catalog Management Viewer, etc.).

### Changes to the timeline

- **Cancel Sev-2 case with Salesforce** — not needed, provisioning is OK.
- **Cancel Wednesday 12:00 decision gate** — base plan confirmed, move directly to Block 3 build.
- **Real buffer increases to ~4h** (2h saved from Plan B custom fields + 2h already budgeted).
- **Tuesday 07-Jul afternoon sequence:** the 14:00-15:00 "open case if it fails" step becomes "assign Claims Management User/Admin PSLs to the demo user + verify the user can read Claim/ClaimCoverage/ClaimCoveragePaymentDetail" (30 min). The rest of Tuesday's time goes entirely to Block 1.

---

## Block 1 — Build EXECUTED (2026-07-07 ~11:00)

**Status:** completed in ~40 min (vs 5h budgeted). Significant buffer recovered.

**Records created in `ins-qbranch-alfa`:**
- 3 AttributeCategory + 8 AttributePicklist + 34 AttributePicklistValue
- 8 AttributeDefinition + 2 ProductClassification + 8 ProductClassificationAttr
- 6 Simple coverages + 1 bundle root "Plan Empresarial"
- 48 ProductAttributeDefinition (propagated defaults)
- 2 ProductComponentGroup + 7 ProductRelatedComponent (6 BundleComponent + 1 ClassificationComponent)
- 7 ProductSellingModelOption (OneTime) + 7 PricebookEntry (COP) + 1 ProductCategory + 1 ProductCategoryProduct

**Key IDs from the build:**
- Plan Empresarial (bundle): look up by `ProductCode='segPymeEmpresarial'`
- Coverages: `rcExtracontractual`, `incendioAliados`, `equipoElectronico`, `roboAsalto`, `roturaMaquinaria`, `sustraccionDinero`
- Classifications: `coberturaPyme`, `establecimientoComercial`

**Gotchas resolved during execution (saved to memory `feedback_digital_insurance_product_config.md`):**
1. `Product2.ProductClass` is not writeable — auto-derived from RecordType/Type
2. `ProductRelatedComponent.ParentProductRole`+`ChildProductRole` auto-derived from the RelationshipType
3. `AttributePicklistValue.Code` is globally unique — suffix `_DME` when there's a collision
4. `AttributeDefinition.DataType` does not support `Multipicklist` — Sustancias Prohibidas ended up single-select
5. PADs are NOT auto-generated with `BasedOnId` — 48 manual creates required
6. `Product2.SellOnlyWithOtherProducts` does not exist in this org

**Next steps per timeline:**
- Block 5 (InsuranceClause): 6 Spanish clauses + junctions + variable maps + LWC — 3h
- Block 2 (Policy Lifecycle): accounts + POL-PYME-2026-0001 + relabel picklists en/es — 2h
- Block 3 (Claims): FNOL + Claim + coverages + reserves + payments — 3-4h
- Block 6 (Reporting): 3 dashboards with filter `Name LIKE '%Pyme%'` — 3h

**Real buffer gained: ~4h** vs the original plan (from Block 1 speed). Can be invested in: (a) building Plan Esencial + Plan Corporativo as peer bundles for the side-by-side, (b) additional rehearsal, (c) more reporting data.

---

## FINAL Status — all blocks deployed (2026-07-07)

All 4 RFI blocks built and verified in `ins-qbranch-alfa`:

### Block 1 — Seguro Pyme Integral Product (~150 records)
- Product2 root **Plan Empresarial** (`segPymeEmpresarial`) + 6 Simple coverages
- 48 ProductAttributeDefinition (6 × 8 attributes)
- 8 AttributeDefinition + 8 AttributePicklist + 34 AttributePicklistValue + 3 AttributeCategory
- 2 ProductClassification (Cobertura Pyme, Establecimiento Comercial) + 8 ProductClassificationAttr
- 2 ProductComponentGroup + 7 ProductRelatedComponent (6 BundleComponent + 1 ClassificationComponent)
- 7 ProductSellingModelOption (OneTime) + 7 PricebookEntry (COP)
- 1 ProductCategory "Seguros Pyme" + link

### Block 5 — InsuranceClauses (21 records)
- 6 InsuranceClauses in Spanish (Buena Fe, Actos Dolosos, Guerra/Terrorismo, Coaseguro, Actividades Extremas, Deducible Mínimo)
- 6 InsuranceProductClause (junctions to the Empresarial bundle)
- 3 InsProductClauseVariableMap (dynamic tokens: coinsurance %, sustancias, minimum deductible)
- 6 InsurancePolicyProductClause materialized on POL-PYME-2026-0001 with resolved text

### Block 2 — Policy Lifecycle (18 records)
- 3 Accounts: Panadería La Espiga SAS, Ferretería El Tornillo Ltda, Consultores Andinos SAS
- 1 InsurancePolicy **POL-PYME-2026-0001** (In Force, BOP, premium COP 2.4MM)
- 6 InsurancePolicyCoverage (RC 600K + Incendio 800K + Equipo 300K + Robo 400K + Rotura 200K + Sustracción 100K)
- 2 InsurancePolicyTransaction (Issuance issuance + Endorsement midterm Incendio increase)

### Block 3 — Claims (12 records)
- 1 Claim **SIN-PYME-2026-0001** (Fire/Smoke Damage, Coverage Confirmed, estimated 48MM)
- 3 ClaimParticipants (Claimant Panadería, Loss Adjuster, Witness Bomberos)
- 3 ClaimItems (Horno Rational 32MM, Estantería 8MM, Lucro Cesante 8MM)
- 1 ClaimCoverage vs InsurancePolicyCoverage Incendio
- 2 ClaimCovReserveAdjustment (Loss Reserve 45MM + Expense Reserve 5MM)
- 1 ClaimPaymentSummary
- 2 ClaimCoveragePaymentDetail (Paid 32MM Horno + Pending Authority 8MM Lucro)

### Block 6 — Reporting (19 metadata artifacts)
- 5 CustomReportType (`InsurancePolicy_Pyme__c`, `Claim_Pyme__c`, `InsurancePolicyCoverage_Pyme__c`, `ClaimCoveragePaymentDetail_Pyme__c`, `ClaimCovReserveAdjustment_Pyme__c`)
- 2 Folders (Report + Dashboard, both "Seguros ALFA Pyme")
- 11 Tabular Reports in Spanish
- 3 Dashboards in Spanish: **Siniestralidad Pyme 2026**, **Renovaciones Pyme 2026**, **Producción Pyme 2026**

**Deployed via SOAP Metadata API (sf project deploy blocked by sandbox ~/.sfdx write). Total agents/deploys iterated: 12 until green. Learnings saved to memory.**

## Handoff — UI verification before Thursday
- [ ] Log in as the technical backup and navigate Product Catalog Management → Insurance Catalog → **Seguros Pyme** → Plan Empresarial → verify the tree
- [ ] Verify 6 coverages with 8 attributes each in Product Modeler
- [ ] View POL-PYME-2026-0001 with the 6 coverages + 2 transactions + 6 materialized clauses
- [ ] View SIN-PYME-2026-0001 with Participants + Items + Coverage + PaymentDetails + ReserveAdjustments
- [ ] Run the 3 dashboards in the Reports app and confirm correct visualization
- [ ] Timed rehearsal block by block (30/30/45/30 min per RFI agenda)
