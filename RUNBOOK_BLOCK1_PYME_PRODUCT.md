# Runbook — Block 1: Modular, Plan-Based SMB Product Configuration

**Assigned duration**: 48 min *(catalog + configurator + Issue Policy + pricing + rules + publication, all live)* | **Presenter**: the presenting SE | **Org**: ins-qbranch-alfa
**Presentation date**: Thursday, 2026-07-09, 8:00 AM – 2:00 PM Colombia time (Teams)
**Block slot**: 8:00 – 8:48 (first block, opening of the demo). We tightened ~18 min from the closing open Q&A to make room for live quoting + rate configuration + underwriting rules + product publication.

> *Talk tracks in this runbook are sample scripts — deliver them in the client's language.*

---

> ⚠️ **The Salesforce IDs and Storm URLs below are from the original engagement — they will not match your org.** Before rehearsing this runbook against your own IDO, run:
>
> ```bash
> ./demo-metadata/scripts/00c-resolve-ids.sh <your-org-alias>
> ```
>
> That prints every ID and URL the runbook references, resolved against your org. Copy-paste them into a local copy of this runbook (or `source` the `--format=env` output to have them as shell variables). The Salesforce IDs in the FINS QBranch IDO **change every time the IDO is provisioned** — never hardcode them.


## 0. Pre-demo setup (do 15 min before)

### 0.1 Log in to the org

1. Open Chrome (or preferred browser) in a normal window — **NOT** incognito, so tabs stay open and pre-loaded.
2. Go to: `https://storm-c90aab66569c63.my.salesforce.com`
3. Log in with the standard ins-qbranch-alfa demo user. Confirm the user locale is `en_US` (standard labels render in English — contextualize verbally).
4. In the top-right corner, verify the user name appears and that we're in the correct app.

### 0.2 Tabs to pre-load (7 tabs, in this order left to right)

Open each URL in a new tab and leave them loaded. This avoids waiting for live loads in front of the client.

| # | Tab | URL |
|---|-----|-----|
| 1 | Plan Empresarial (Root bundle) | `https://storm-c90aab66569c63.my.salesforce.com/lightning/r/Product2/01tg8000003hS49AAE/view` |
| 2 | Coverage RC Extracontractual | `https://storm-c90aab66569c63.my.salesforce.com/lightning/r/Product2/01tg8000003hRmPAAU/view` |
| 3 | Coverage Incendio y Aliados | `https://storm-c90aab66569c63.my.salesforce.com/lightning/r/Product2/01tg8000003hRo1AAE/view` |
| 4 | Coverage Equipo Electrónico | `https://storm-c90aab66569c63.my.salesforce.com/lightning/r/Product2/01tg8000003hRpdAAE/view` |
| 5 | Classification Cobertura Pyme | `https://storm-c90aab66569c63.my.salesforce.com/lightning/r/ProductClassification/11Bg800000DRh4bEAD/view` |
| 6 | Attribute Suma Asegurada | `https://storm-c90aab66569c63.my.salesforce.com/lightning/r/AttributeDefinition/0tjg8000000DPYTAA4/view` |
| 7 | App Launcher — Product Catalog Management | `https://storm-c90aab66569c63.my.salesforce.com/lightning/page/home` (then open the app from there) |

### 0.3 Visual verification before sharing screen

On tab 1 (Plan Empresarial), confirm that:

- The record name is **Plan Empresarial**.
- There's a horizontal tab bar that includes these 9 tabs (the exact order Salesforce renders may vary slightly depending on page layout and window width): `Related`, `Details`, `Attributes`, `Attribute Scopes`, `Structure`, `Translations`, `Surcharges`, `Exclusions`, `Rules`.
- **Important about the tabs**: if the browser zoom is too high or the window isn't maximized, some tabs may be cut off and hidden behind a `>` icon (chevron / "More Tabs") at the end of the bar. Before sharing the screen:
  - Verify that **Structure** is visible directly on the bar (not hidden behind the `>`).
  - If Structure isn't visible, lower the zoom to 100% or maximize the window until it appears.
  - As an alternative, click the `>` to expand the hidden tabs and confirm Structure is there — but this isn't ideal for the demo (it breaks the visual flow).
- Click the `Structure` tab — it should show the hierarchical tree with:
  - **Plan Empresarial** (root)
    - **Coberturas** (Component Group)
      - the 6 Simple coverages
    - **Establecimiento** (Component Group)

If the `Structure` tree doesn't load within 5 seconds, refresh (Ctrl/Cmd + R) before the demo. **Do not** refresh live — it looks bad.

### 0.4 Kill distractions

- Close Slack, email, OS notifications.
- Set phone to silent.
- Browser zoom at **100–110%** (go to 125% only if the 9 tabs are still fully visible without collapsing behind the `>`). Prioritize visible tabs over font size.

### 0.5 Mental cheat sheet (print or keep on a sticky)

- Root bundle: **Plan Empresarial** (code: `segPymeEmpresarial`).
- 6 coverages: **RC Extracontractual, Incendio y Aliados, Equipo Electrónico, Robo y Asalto Interior, Rotura de Maquinaria, Sustracción de Dinero y Valores**.
- 2 Component Groups: **Coberturas** and **Establecimiento**.
- 2 Classifications: **Cobertura Pyme** and **Establecimiento Comercial**.
- 8 key Attributes: Suma Asegurada (picklist), Deducible, Actividad Económica, Rango Empleados, Metros Cuadrados Local, Porcentaje Coaseguro, Deducible Mínimo Evento, Sustancias Prohibidas.
- **48 total PADs** across the 6 coverages → **average 8 attributes per coverage**. If when opening a coverage's Attributes tab you see fewer than 6 or more than 12, something is off with that data — move on to another coverage.

---

## 1. Block context and objective (30 sec)

In this first block we'll demonstrate how Insurance on Core, via the Product Catalog Management module, lets you configure a **modular, plan-based** SMB product — no code, 100% standard configuration. We'll show the **Plan Empresarial** bundle with its 6 component coverages, how they're grouped by Component Groups, how they inherit attributes via Product Classifications, and how each coverage has its own technical attributes (sum insured, deductible, coinsurance, etc.). This gives ALFA the foundation to assemble any new commercial plan by reusing existing components, without duplicating the catalog.

---

## 2. Step-by-step click path

### Step 2.1 — Open the product catalog from App Launcher (2 min)

**Click / navigation:**

1. Go to the browser tab where you have Salesforce open (tab 7 if coming from pre-demo setup, or any tab with Lightning).
2. Click the **App Launcher** — the nine-dot icon in the top-left corner (next to the Salesforce logo).
3. In the search box that appears, type: `Product Catalog Management`.
4. Click the **Product Catalog Management** app that appears in the results.
5. Once inside the app, click the **Products** tab (at the top, in the nav bar).
6. You'll see on screen: a list of products (Product2) with columns like Name, Product Code, Type, Active.

**What to say (talk track):**

> "Before diving into the product itself, I want to show you where all this lives. Insurance on Core ships this standard application — **Product Catalog Management** — which is where the ALFA product team models the entire insurance catalog: plans, coverages, attributes, classifications. It's a native Salesforce app, not a customization of ours. Everything you'll see today is configured here, without code."

**Emphasis points:**

- Reinforce "standard Insurance on Core app" — the client values that this isn't custom development.
- Mention that the same catalog feeds quoting, issuance, and claims (foreshadow Block 2).

**If something doesn't appear:**

- If `Product Catalog Management` doesn't appear in the App Launcher, type `Products` directly — the Products tab is also available from the Sales or Service app. But the dedicated app is preferred.
- If the Products list is empty, change the list view to **All Products** from the list views dropdown (top-left of the list).

---

### Step 2.2 — Open the Plan Empresarial Bundle and show the key fields (3 min)

**Click / navigation:**

1. In the Products list, use the search field (above the list) to look for: `Plan Empresarial`.
2. Click the **Plan Empresarial** product link.
   - Faster alternative: if search is slow, jump directly to pre-loaded tab 1 (URL `/lightning/r/Product2/01tg8000003hS49AAE/view`).
3. You're now on the **Plan Empresarial** record.
4. Click the **Details** tab (second tab, next to Related).
5. You'll see on screen:
   - **Product Name**: Plan Empresarial
   - **Product Code**: `segPymeEmpresarial`
   - **Type**: `Bundle`
   - **Family**: `Miscellaneous`
   - **Active**: ✓ (checked)
   - Internal note (not on the demo user's screen): at the API level the `ProductClass` field is also set to `Bundle`, but this is a system-derived field that doesn't appear on the standard Product Layout — it's only visible on the "FINS Broker Product Layout".

**What to say (talk track):**

> "This is the heart of the block: **Plan Empresarial**. Notice the field **Type = Bundle**. That tells the platform this product isn't sold on its own — it's a container that groups coverages. This is exactly what ALFA asked for in the RFP: an assemblable, modular commercial plan that packages reusable components. The code `segPymeEmpresarial` is the global unique identifier — that's the code APIs, quoting flows, everything consumes."

**Emphasis points:**

- Stress that **Type=Bundle** is what enables modular behavior (the platform internally sets `ProductClass=Bundle`, a derived field not exposed on the standard layout).
- Mention that `ProductCode` is globally unique — important for integrations (foreshadow the conceptual integration block).

**If something doesn't appear:**

- If the `Details` tab doesn't show the fields, click **Show More** or check that the page layout is correct (unlikely, but if it happens, skip to Structure and come back later).

---

### Step 2.3 — Show the hierarchical structure: Structure tab (5 min) [CENTERPIECE OF THE BLOCK]

**Click / navigation:**

1. Still on the Plan Empresarial record, click the **Structure** tab.
   - If you don't see the Structure tab directly on the bar, click the `>` icon at the end of the tab bar (More Tabs) and select it from there. Ideally this was already resolved in setup 0.3 by adjusting zoom.
2. Wait 2-3 seconds for the tree to render.
3. You'll see on screen: a hierarchical tree in this shape:
   ```
   Plan Empresarial (Bundle)
   ├── Coberturas (Component Group)
   │   ├── Responsabilidad Civil Extracontractual
   │   ├── Incendio y Aliados
   │   ├── Equipo Electrónico
   │   ├── Robo y Asalto Interior
   │   ├── Rotura de Maquinaria
   │   └── Sustracción de Dinero y Valores
   └── Establecimiento (Component Group)
   ```
4. Click the `>` icon or expand each Component Group if they're collapsed.
5. Click the **Responsabilidad Civil Extracontractual** coverage within the tree to expand it — showing that it's a Simple product.

**What to say (talk track):**

> "Here is the functional evidence ALFA requested. This tree is 100% configuration — zero code. See how **Plan Empresarial** contains two component groups: **Coberturas** — where the 6 technical coverages live — and **Establecimiento**, which groups the customer's premises data. Each coverage is an independent product, with its own lifecycle, its own code, its own attributes, its own rules. But they're orchestrated under the bundle. If tomorrow ALFA wants to launch a **Plan Pyme Básico** with only 3 of these 6 coverages, they build it in minutes by reusing the same components. Nothing has to be duplicated."

**Emphasis points:**

- Point the cursor at each hierarchy level as you speak.
- **Don't** click too quickly — let the tree be read.
- Emphasize "reuse" — this is the differentiator vs. having a flat product and copying it.
- If the client asks about the order of the coverages, mention it's governed by the `Sequence` field on ProductRelatedComponent.

**If something doesn't appear:**

- If the tree takes >5 seconds, refresh the page **once** and explain: "We're on a shared storm org, sometimes the first load is slow."
- If a Component Group appears empty, go to the **Related** tab and look for the **Product Related Components** related list — from there you can see the 7 flat relationships (6 coverages + 1 Establecimiento).

---

### Step 2.4 — Open a coverage and show its attributes (5 min)

**Click / navigation:**

1. From the Structure tree, right-click **Responsabilidad Civil Extracontractual** → "Open in new tab" — or, simpler, switch to pre-loaded tab 2 (URL `/lightning/r/Product2/01tg8000003hRmPAAU/view`).
2. You'll see the coverage record.
3. Click the **Details** tab — show:
   - **Product Name**: Responsabilidad Civil Extracontractual
   - **Product Code**: `rcExtracontractual`
   - **Type**: `(empty)` — this is a Simple coverage, an atomic component that only sells when packaged in a bundle. The system auto-derives `ProductClass=Simple`, though that field isn't on the standard layout.
   - **Active**: ✓
4. Click the **Attributes** tab.
5. You'll see a list of product attributes. **Expected: ~8 attributes per coverage** (48 total PADs / 6 coverages). The typical attributes that should appear are:
   - Suma Asegurada
   - Deducible
   - Actividad Económica
   - Rango de Empleados
   - Metros Cuadrados Local
   - Porcentaje Coaseguro
   - Deducible Mínimo por Evento
   - Sustancias Prohibidas
6. **Live sanity check**: mentally count the attributes. If you see fewer than 6 or more than 12, the data on that coverage is anomalous — don't stop, switch to another coverage from the pre-loaded tabs (3 = Incendio, 4 = Equipo Electrónico).

**What to say (talk track):**

> "Now we go into an individual coverage — **Responsabilidad Civil Extracontractual**. This is a **Simple** coverage — atomic, a component. Notice the **Type** field is empty: that's intentional, because coverages inherit their behavior from the parent bundle. Internally the platform classifies it as `ProductClass=Simple`, which is what ties the modular catalog together. It's a sellable component but only packaged in a bundle. In the **Attributes** tab we see the technical attributes that capture this coverage's parameterization — approximately 8 attributes: **Suma Asegurada**, **Deducible**, **Porcentaje de Coaseguro**, **Deducible Mínimo por Evento**, **Actividad Económica**, among others. These are the attributes the commercial advisor or the quoting engine fills in when a policy is issued — which is what we'll see in Block 2."

**Emphasis points:**

- Mention that there are **48 total Product Attribute Definitions** across the 6 coverages — **average 8 per coverage**. It's a round number, easy to remember and to cite.
- Point out that **Suma Asegurada** is a **Picklist** type — predefined values, not free-form numeric. This gives ALFA commercial control over sum insured tiers.

**If something doesn't appear:**

- If the `Attributes` tab is empty, go to the `Related` tab and look for the **Product Attribute Definitions** related list.
- If some expected attributes are missing, don't stop — mention only the ones present and move on.
- If the total attribute count differs significantly from 8, don't cite the exact number in the demo — say "several technical attributes" and continue.

---

### Step 2.5 — Show the detail of an Attribute Definition (Suma Asegurada) (4 min)

**Click / navigation:**

1. On the coverage's Attributes tab, click the **Suma Asegurada** link (Attribute or Name column).
   - Alternative: switch to pre-loaded tab 6 (URL `/lightning/r/AttributeDefinition/0tjg8000000DPYTAA4/view`).
2. You're now on the **Suma_Asegurada** Attribute Definition record.
3. Show the key fields in Details:
   - **Developer Name**: `Suma_Asegurada`
   - **Data Type**: `Picklist`
   - **Picklist**: link to Picklist ID `0v5g8000000DSuXAAW`
4. Click the Picklist link to show the predefined values (sum insured tiers — typically COP 50M, 100M, 250M, 500M, 1,000M, etc.).

**What to say (talk track):**

> "Attributes aren't loose custom fields — they're first-class objects in Salesforce, with their own lifecycle, governance, and reuse. This **Suma Asegurada** is a centralized Attribute Definition: it's defined **once** and reused across as many coverages as need it. And because it's a **Picklist**, ALFA has commercial control over the available sum insured tiers — the advisor can't enter arbitrary values. If the tiers change tomorrow, you change it here and it propagates to all coverages that use it. That's the definition of catalog governance."

**Emphasis points:**

- Emphasize **"define once, reuse"** — a classic reuse pattern.
- Mention there are other DataTypes available: Number, Text, Date, Boolean — not just Picklist. Each attribute picks the appropriate type.
- If there's time, open a Number-type attribute (Deducible, ID `0tjg8000000DPa5AAG`) to contrast.

**If something doesn't appear:**

- If the Picklist link doesn't work, describe verbally: "The Picklist has N predefined values configured by the product team."
- Don't go into edit mode on the picklist — just show.

---

### Step 2.6 — Show the Product Classifications (attribute inheritance) (4 min)

**Click / navigation:**

1. Switch to pre-loaded tab 5 (URL `/lightning/r/ProductClassification/11Bg800000DRh4bEAD/view`).
2. You'll see the **Cobertura Pyme** (Product Classification) record.
3. Show the key fields in Details:
   - **Name**: Cobertura Pyme
   - **Code**: `coberturaPyme`
   - **Status**: `Active`
4. Click the **Related** tab (or scroll down).
5. **Look for the attributes related list** — the exact label isn't pre-verified in the org and can appear with different names depending on the Insurance on Core managed package version:
   - Possible candidates: `Product Classification Attributes`, `Classification Attributes`, `Attributes`, `Product Attribute Definitions` (the last if the related list is shared between Product and Classification).
   - **How to act live**: scan the list of related lists with your eyes (don't read the names one by one in front of the client). If you see one that contains attributes, click and show. If you can't find any obvious one in 5 seconds, **skip** to plan B (below).
6. Look for the **Products** or **Products with this Classification** related list — show the products using this classification (several of the 6 coverages should appear).

**Plan B (if you don't find the attributes related list on Cobertura Pyme):**

- Don't linger searching. Bridge phrase: *"The attributes this classification inherits are the same ones we already saw on the coverage — Suma Asegurada, Deducible, Coaseguro, etc. The classification is the propagation mechanism, and we already saw it materialized on each coverage."*
- Go back to the RC Extracontractual coverage tab (tab 2) → Attributes tab — use those 8 attributes as visual evidence of inheritance.
- Alternative: open the Suma Asegurada Attribute Definition tab (tab 6) and explain that this same attribute is referenced by the Cobertura Pyme classification, which is why it appears in all 6 coverages.

**What to say (talk track):**

> "This is a critical governance pattern. **Product Classifications** are attribute templates: instead of assigning the same 8 attributes manually to each of the 6 coverages, we define a **Cobertura Pyme** classification with those attributes, and each coverage inherits them automatically. If tomorrow ALFA wants to add a new attribute — for example, **Seismic Risk Zone** — they add it to the classification once, and the 6 coverages receive it. This dramatically reduces catalog maintenance. We have two active classifications: **Cobertura Pyme** and **Establecimiento Comercial**, aligned with the two Component Groups we saw in the tree."

**Emphasis points:**

- Inheritance = less maintenance.
- Change in one place propagates to N products.
- Show Status = Active — there's a lifecycle (Draft / Active / Obsolete).

**If something doesn't appear:**

- Execute Plan B (above) without hesitation. The conceptual message of inheritance matters more than seeing the exact related list.
- If the Products related list doesn't show the 6 coverages, don't stop — mention that the assignment is at the individual product level in the `BasedOnId` field or similar.

---

### Step 2.7 — Close the block returning to the Bundle (2 min)

**Click / navigation:**

1. Return to tab 1 (Plan Empresarial).
2. Click the **Structure** tab once more — leave the tree visible on screen.
3. With the cursor, walk through the tree top to bottom: Bundle → Component Groups → Coverages.

**What to say (talk track):**

> "We're closing the block by returning to the start so the mental picture stays clear. What you see here — the Plan Empresarial tree with its two groups and its 6 modular coverages — is what ALFA will operate in production. A product team can assemble a **Plan Pyme Premium**, **Plan Pyme Básico**, **Plan Retail**, **Plan Comercial Especial**, reusing these same components in different combinations, with different commercial rules, without touching code and without duplicating the catalog. In the next block we'll take this bundle and bring it into the real policy lifecycle: quoting, issuance, endorsement, and renewal."

**Emphasis points:**

- Leave the tree image on screen — a memorable visual.
- Bridge into Block 2 (policy lifecycle).

**If something doesn't appear:**

- If the tree takes long to reload, stay on the Details tab — the closing message works just the same.

---

### Step 2.8 — Quote from Panadería La Espiga: Create Quote OmniScript (2 min)

**Objective:** step out of the static catalog and show the moment the agent builds a quote for a real customer. This is the catalog's "runtime" — where the product definition we just reviewed becomes a configured Quote.

> ⚠️ **Do NOT create the Quote manually from the Quotes tab.** The Product Configurator LWC will crash with `Cannot read properties null (reading 'groups')` because a hand-created Quote is missing three pieces the LWC checks at load time:
>
> 1. **`Quote.TransactionType`** must be `AutoTransactionType` (or `GroupInsuranceTransactionType`) — the field looks optional in the UI but the LWC requires it.
> 2. **The linked Opportunity's RecordType** must be `SimpleOpportunity` — no other RT has the required pricebook/configurator bindings for this flow.
> 3. **The Opportunity's `Pricebook2Id`** must be the Standard Pricebook, resolved dynamically.
>
> The **OmniScript `Create Quote B2C Insurance 2`** (API name `CreateQuoteDCT2`) encapsulates all three: it creates the Opportunity with the right RT, links the Quote, and sets `TransactionType`. That's why the demo flow starts from the Account's Action Launcher — never from the Quotes tab directly.
>
> **Note on the "2" suffix.** The FINS QBranch IDO ships with the original OmniScript `CreateQuoteDCT` (label `Create Quote B2C Insurance`). In practice the original doesn't always activate cleanly on freshly-provisioned IDOs — a known intermittent issue with pre-installed OmniStudio components. The workaround used in this demo is to **duplicate the original**, rename the copy with a `2` suffix (`CreateQuoteDCT2` / `Create Quote B2C Insurance 2`), and activate the duplicate. Both scripts have identical logic; the duplicate is just a version that's guaranteed to be Active in your org. If you provision a new IDO and the original works fine, you can use it directly and adjust the runbook's talk track accordingly.
>
> In real life, the same OmniScript would first look up an existing Opportunity for the customer (or create one from a broker referral) and then create the linked Quote with the correct fields. In this demo we simplified it to "one click and both records are ready", but the underlying pattern is: **Opportunity first (with SimpleOpportunity RT + Standard Pricebook) → Quote linked to it (with TransactionType populated) → then Browse Catalogs**. Any deviation from this order breaks the LWC.
>
> Full technical detail: [`CLAUDE.md`](CLAUDE.md) sections "RCA Quote requires TransactionType" and "Opportunity RecordType for RCA".

**Click / navigation:**

1. Open in a new tab: `https://storm-c90aab66569c63.lightning.force.com/lightning/r/Account/001g800000T9v3QAAR/view` (Account: Panadería La Espiga SAS).
2. In the record header, click the **Action Launcher** (lightning-bolt icon or similar button on the Account's top actions bar).
3. In the list of actions, find and click **"Create Quote B2C Insurance 2"**.

**You'll see:**

- An OmniScript opens with the header "Create Quote B2C Insurance 2".
- The OmniScript is pre-populated with Panadería's AccountId.

**What to say (talk track):**

> "With the catalog defined, now we move to the moment where an ALFA agent sits down with a customer and builds a real quote. We're on the **Panadería La Espiga SAS** record — our SMB customer in the food sector, 42 employees, three premises in Bogotá. With a single click on the Action Launcher we launch the guided **Create Quote B2C Insurance** flow that creates the quote linked to this customer."

**If something doesn't appear:**

- If the Action Launcher isn't visible, use global search (Cmd+K / Ctrl+K) → type "Create Quote B2C Insurance 2" → Enter.
- If the OmniScript prompts for additional inputs, accept the defaults.

---

### Step 2.9 — Advance the OmniScript and open the Quote (1 min)

**Click / navigation:**

1. In the OmniScript, click **Next**.
2. On the next screen, click **View Quote**.
3. The newly created Quote record opens: **"Panadería La Espiga SAS - Seguro Pyme Empresarial"**.

**You'll see:**

- The header shows the Quote name.
- Related lists / tabs show Quote Line Items (still empty at this point).
- A **Browse Catalogs** button visible in the actions bar.

**What to say (talk track):**

> "The OmniScript executed two steps: created the context Opportunity and the Quote linked to the customer. We now have the quote container; next we'll populate it with products from the SMB catalog we just walked through."

---

### Step 2.10 — Browse Catalogs → select Plan Empresarial (2 min)

**Click / navigation:**

1. On the Quote, click **Browse Catalogs**.
2. **If Salesforce prompts to select a Price Book**: choose **"Standard Price Book"** and confirm.
3. In the catalog browser, you'll see the list of catalogs. Click **Insurance Catalog**.
4. Under Categories, click **Seguros Pyme**.
5. The bundle is listed: click on **Plan Empresarial**.
6. Click **Configure**.

**You'll see:**

- The **Product Configuration LWC** opens with the title "Configure Plan Empresarial".
- Tabs for **Coberturas** and **Establecimiento**.
- Under Coberturas, the 6 coverages with checkboxes; the 4 defaults come pre-checked (Equipo Electrónico, Incendio y Aliados, Responsabilidad Civil Extracontractual, Robo y Asalto Interior); the 2 optional ones unchecked (Rotura de Maquinaria, Sustracción de Dinero y Valores).
- Right sidebar with Summary per coverage.
- Top toggles: Product Validation ON, Instant Pricing OFF, Compact Mode OFF.

**What to say (talk track):**

> "This is the **Product Configuration Lightning Web Component** — the interface the agent uses every day. We navigate through the catalog — Insurance Catalog, Seguros Pyme category — and select the Plan Empresarial we defined in earlier blocks. When we click Configure, the catalog runtime materializes the bundle: you see the 4 coverages included by default with Plan Empresarial — Responsabilidad Civil, Incendio, Equipo Electrónico, and Robo — and the 2 optional ones the agent can activate as the customer needs: Rotura de Maquinaria and Sustracción de Dinero."

**Emphasis points:**

- Highlight the checkbox: default vs. optional. Explain this distinction comes from `IsDefaultComponent=true/false` on `ProductRelatedComponent` in the catalog.
- Each coverage's price comes from the PricebookEntry — it's not hardcoded.

**If something doesn't appear:**

- If the LWC fails to load and shows "Cannot read properties of null": the underlying Opportunity isn't pointing to the right pricebook — abandon the Quote and use `COT-PYME-2026-0001-Panaderia` (Id `0Q0g80000013EQrCAM`) pre-verified as backup.

---

### Step 2.11 — Configure Equipo Electrónico and see the 8 inherited attributes (2 min)

**Click / navigation:**

1. In the bundle configuration LWC, click the **Equipo Electrónico** name (or click that coverage's config icon).
2. The configuration detail for that coverage opens with the breadcrumb `Plan Empresarial > Equipo Electrónico`.

**You'll see:**

- The 8 attributes populated with defaults:
  - **Actividad Económica**: Comercio
  - **Deducible**: COP 2,000,000
  - **Deducible Mínimo por Evento**: COP 1,000,000
  - **Metros Cuadrados Local**: 101-500 m²
  - **Porcentaje de Coaseguro**: 10%
  - **Rango de Empleados**: 11-50 empleados
  - **Suma Asegurada**: COP 100,000,000
  - **Sustancias Prohibidas**: Ninguna
- Summary sidebar shows the same values.

**What to say (talk track):**

> "When we configure a coverage — Equipo Electrónico for example — we see the 8 attributes we defined in Block 1. **Actividad Económica** is already Comercio because Panadería is in the food sector. **Suma Asegurada** defaults to 100 million pesos, **Deducible** 2 million, **Rango de Empleados** 11-50, **Metros Cuadrados** 101-500 — all with predefined values from the product team. The agent can adjust any of these as the customer needs; the picklists guarantee they stay within the authorized commercial ranges. Key point: **these 8 attributes are the same across all 6 coverages** because they all inherit from the 'Cobertura Pyme' ProductClassification — one single place to govern the attribute model."

**Emphasis points:**

- Don't change values live — leave the defaults so pricing doesn't break.
- Insist that inheritance via ClassificationAttr is what guarantees consistency.

---

### Step 2.12 — Go back, Update Prices, and save the configuration (2 min)

**Click / navigation:**

1. Click the **Plan Empresarial** breadcrumb (or "Return to Quote" button).
2. Click **Update Prices**.
3. Wait ~2 seconds: the "Prices don't reflect the latest selections" message disappears.
4. Verify in the Summary sidebar: **Net Unit Price $2,400,000** and **Net Total Price $2,400,000**.
5. Click **Save & Exit**.
6. You return automatically to the Quote.

**You'll see:**

- The Quote now has populated Quote Line Items: the root bundle + the 4 default child coverages, with `ParentQuoteLineItemId` connecting them.
- Quote TotalPrice: **2,400,000**.

**What to say (talk track):**

> "Update Prices runs the **pricing procedure** in real time — it calculates the premium by combining the prices of the active coverages: RC 600k, Incendio 800k, Equipo Electrónico 300k, Robo 400k = **2,400,000 pesos annually**. We save the configuration and return to the Quote. **Quick note**: the $ symbol you see is because this demo org is in dollars by default; in production, the org's currency is configured in Colombian pesos and all values render directly with the peso symbol."

**Emphasis points:**

- Pricing is declarative — no custom rating Apex.
- QuoteLineItems reflect the bundle+children structure of the catalog.

**If something doesn't appear:**

- If Update Prices doesn't change the total, refresh the Quote (F5) — sometimes the LWC needs to reload.

---

### Step 2.13 — View the Quote and run Issue Policy (2 min)

**Click / navigation:**

1. On the Quote, review the **Quote Line Items** tab or the related list — you'll see 5 lines (Plan Empresarial parent + 4 child coverages).
2. In the Quote's actions bar, click **Issue Policy** (button/action).

**You'll see:**

- An "Issue Policy" wizard opens with a form requesting new policy fields.

**What to say (talk track):**

> "With the quote accepted by the customer, we run **Issue Policy** — the action that converts the Quote into a formal policy. This creates the InsurancePolicy record with the full coverage structure inherited from the Quote, and triggers the issuance transaction records we'll see in the next block."

---

### Step 2.14 — Issue Policy wizard — fill in fields (2 min)

**Click / navigation:**

1. In the wizard, fill in the following fields:
   - **Policy Name**: `POL-PYME-2026-0001`
   - **Policy Number**: `POL-PYME-2026-0001`
   - **Effective Start Date**: `06/01/2026`
   - **Effective End Date**: `05/31/2027`
   - **Policy Term**: `Annually`
2. Click **Next**.
3. On the payment step: click **Process Payment and Continue**.
4. Click **Next** on the following screen until the wizard finishes.

**You'll see:**

- When the wizard completes, a policy-issued confirmation appears.
- An InsurancePolicy record is created with Name `POL-PYME-2026-0001` (or similar based on auto-numbering) and all coverages materialized.

**What to say (talk track):**

> "We fill in the basic information: policy name and number **POL-PYME-2026-0001** — the naming ALFA agrees on with the underwriting team — annual coverage from June 1, 2026 to May 31, 2027, and annual term. We process the initial payment — in production this integrates with the customer's actual payment gateway — and finalize. **The policy is issued**. In the next block we'll explore the full lifecycle of this policy: its coverages, its contract clauses, midterm endorsement, and cancellation."

**Emphasis points:**

- The full Quote → Configure → Issue Policy flow took less than 10 minutes live, with no code.
- The issued policy is the direct input for Block 2.

**If something doesn't appear:**

- If Issue Policy fails due to conflict with a pre-existing `POL-PYME-2026-0001` in the org, use `POL-PYME-2026-0001-DEMO` as an alternate name — the narrative isn't affected.
- If the wizard hangs at some step, close it and use the pre-issued `POL-PYME-2026-0001` (already created via API to back up Blocks 2 and 3) as fallback.

---

### Step 2.15 — Plan Empresarial rate configuration (Pricing) (3 min)

**Objective:** close the catalog loop by showing where the rate we just calculated in step 2.12 (the 2.4 MM) lives. Land the point that pricing is declarative, not hardcoded.

**Click / navigation:**

1. Return to tab 1 (Plan Empresarial, `01tg8000003hS49AAE`).
2. Click the **Related** tab (or scroll down to the related list).
3. Locate the **Price Book Entries** related list (Spanish label might be "Entradas del catálogo de precios").
4. Click the **Standard Price Book** entry (`01ug80000025X0bAAE`).
5. You'll see:
   - **Product**: Plan Empresarial
   - **Price Book**: Standard Price Book
   - **List Price**: `$2,400,000`
   - **Active**: ✓

**Fallback if the related list isn't in the layout:** navigate directly via URL to `https://storm-c90aab66569c63.my.salesforce.com/01ug80000025X0bAAE`.

**What to say (talk track):**

> "The 2,400,000 price you saw in the quote isn't hardcoded anywhere — it lives here, in a **PricebookEntry** on the Standard Price Book. Insurance on Core ships an **Insurance Quote Default Pricing Procedure** out of the box, plus **7 rating templates** — Product Level, Quote Level, Member-Based, Summary-Based — that let you model rates by age, economic activity, sum insured, headcount, all declaratively via **ExpressionSet**, no code. For ALFA's production deployment, this is where we'd connect segment-based rate tables — Pyme Micro, Pequeña, Mediana — or region-based tables using additional Price Books."

**Emphasis points:**

- Pricing is a first-class object, governable, versionable.
- No code: mention there are 3 OOTB pricing procedures in the org (Insurance_Quote_Default_Pricing_Procedure, Default_Pricing, pricingProcedure) and 17 generic CalculationMatrix structures ready to be populated.
- Segment bridge: "If ALFA wants differential rates by region or by sum insured tiers, all of that is solved without development."

**If something doesn't appear:**

- Don't open Setup → Pricing Procedures live (the UI may ask for context or throw an error) — just mention it verbally.
- Don't show empty CalculationMatrix — it looks disjointed.
- Final fallback: stay on the PricebookEntry, it's guaranteed to work.

---

### Step 2.16 — Underwriting Rules (3 min)

**Objective:** show that native underwriting rules capability exists, and narrate 1-2 concrete examples ALFA can configure without code. Don't create rules live.

**Click / navigation:**

1. Open **App Launcher** → search `Underwriting Rules` → click the app (or navigate to the Underwriting Rules Builder section from Setup).
2. The list of **UnderwritingRuleGroups** appears — there are 6 OOTB groups tied to Auto products (Gold/Silver/Claim). Visible examples:
   - **Quote Submission** (Auto Gold, Draft→Submitted) — 2 rules including "Validate state of license for SUV".
   - **Needs Review** (Auto Gold, Submitted→Needs Review) — rule where Discount > $100 triggers task flows.
   - **Quotes approved Broker profile** (Auto Gold) — combines UserProfile + DiscountValue.
   - **Incident Location Country** (Auto Claim Root, Initial→Open).
3. Click **Quote Submission** to show the group structure and its internal rules.
4. Then return to tab 1 (Plan Empresarial) → click the **Rules** tab — it appears empty for Plan Empresarial, but the capability is there.

**What to say (talk track):**

> "ALFA asked us about underwriting rules — how do we prevent an advisor from issuing a policy with an unauthorized risk? This capability comes native in Insurance on Core: **Underwriting Rules** organized into **Rule Groups** by Quote or Claim state transition — Draft→Submitted, Submitted→Approved, Submitted→Needs Review. Look at these OOTB examples for Auto: if an SUV doesn't have a California license, the submit is blocked. If the discount exceeds $100, a flow fires that creates a task for the senior underwriter. For ALFA's **Plan Empresarial**, Phase 2 of the implementation configures rules like: *'if Actividad Económica is Manufactura and Sustancias Prohibidas is not Ninguna → block submit and send to manual UW'*, or *'if Suma Asegurada exceeds 500 million COP → fire a flow that assigns review to the risk team'*. All declarative, no Apex."

**Emphasis points:**

- Mention the clean separation: **UnderwritingRule** operates on state transitions; **ProductConfigurationRule** operates during product configuration (defaults, hides, required coverages — there are 9 Active rules for Auto Silver/Gold as reference).
- The engine is **BusinessRuleEngine** — generic, scales beyond Insurance.
- Close by returning to the Plan Empresarial Rules tab: "Empty today, populated by ALFA in Phase 2."

**If something doesn't appear:**

- If the Underwriting Rules Builder doesn't load (possible on the storm org), fallback: show the 9 **ProductConfigurationRule** from App Launcher → quicksearch "Product Configuration Rules" (they're more mature and usually load). Similar narrative.
- Secondary fallback: open a UW Rule Group via direct URL — `https://storm-c90aab66569c63.my.salesforce.com/1KQg800000007xaGAA` (Quote Submission Auto Gold).
- **Don't create rules live** — high risk of leaving something inconsistent. Everything shown is read-only.

---

### Step 2.17 — Product Publication (2 min)

**Objective:** close the chain by showing how Plan Empresarial "is published" — active, assigned to a category within a commercial catalog.

**Click / navigation:**

1. Return to tab 1 (Plan Empresarial).
2. **Details** tab — visually confirm **Active = ✓**.
3. Scroll down to the **Product Categories** related list (or navigate to the ProductCategoryProduct `0ZRg8000000Fjw5GAC`).
4. Show the record: **Plan Empresarial → Seguros Pyme → Insurance Catalog**.
5. Optional (30 sec): navigate to the "Insurance Catalog" catalog (`0ZSg8000000D8pPGAS`) → "Seguros Pyme" category (`0ZGg8000000FLP7GAO`) — the product appears listed.
6. Mention (without necessarily clicking) the temporal window fields: **AvailabilityDate**, **DiscontinuedDate**, **EndOfLifeDate** (empty today = always available).

**What to say (talk track):**

> "We close with publication. In Digital Insurance PCM the model is lighter than other catalogs — there isn't a formal 'Publish' button with Draft/Released states like in Comms Cloud. Publication is declarative and materialized via three native controls: **one**, the `IsActive = true` flag on the product; **two**, a **ProductCategoryProduct** record that ties the product to a category within a catalog — in our case Plan Empresarial is published in the **Seguros Pyme** category of the **Insurance Catalog**; **three**, optionally the **AvailabilityDate**, **DiscontinuedDate**, **EndOfLifeDate** fields that provide temporal control — when it becomes effective, when it's discontinued, when it reaches end of life. For enterprise governance ALFA can wrap this in an **Approval Process** on Product2 before `IsActive` flips to true, or use Change Sets/DevOps to promote products across orgs — sandbox, UAT, production."

**Emphasis points:**

- The "publish" isn't a black-box flow — these are standard, auditable objects (Product2, ProductCategory, ProductCategoryProduct, ProductCatalog).
- If asked about formal versioning: clarify that in Digital Insurance PCM, versioning lives at the **InsurancePolicy** level (endorsements, renewals) — not at Product2. DO NOT mention LifecycleStatus/Draft/Released (that's EPC/Comms Cloud, doesn't apply here).

**If something doesn't appear:**

- If the Product Categories related list isn't in the layout: quick SOQL in Dev Console `SELECT Product.Name, ProductCategory.Name, ProductCategory.Catalog.Name FROM ProductCategoryProduct WHERE Product.ProductCode='segPymeEmpresarial'` — returns the row and you narrate over that.
- If the client insists on a formal "Publish" button: respond that Digital Insurance PCM doesn't ship a discrete one; publication is the combination of IsActive + ProductCategoryProduct + effective dates, wrappable in an Approval Process if an approval workflow is required.

---

## 3. Anticipated client questions

| Likely question | Prepared answer |
|---|---|
| How much of this is standard configuration vs. customization? | 100% standard Insurance on Core configuration — Product Catalog Management is a native module. Everything you saw (Product2 of Bundle type, ProductClassification, ProductComponentGroup, AttributeDefinition, ProductRelatedComponent) are standard product objects. No Apex, no custom LWC, no custom fields that break upgrades. |
| Are ProductAttributeDefinitions generated automatically when a Classification is assigned? | The Classification propagates the list of available attributes to the product, but the **PADs** (Product Attribute Definitions) that set defaults, per-product values, and visibility are materialized explicitly on the product. In this org we have **48 PADs created across the 6 coverages — average 8 per coverage** — all active and ready. |
| How do you control that an advisor doesn't enter a sum insured outside the allowed range? | Three layers: (1) **Picklist** on the Suma Asegurada attribute — the advisor picks only predefined values; (2) **AttributeScopes** on the bundle — allowed values can be bounded per plan; (3) **Rules** — declarative rules that validate combinations. All without code. |
| Can we create a new plan without IT's help? | Yes. A business role with permissions over Product Catalog Management can: create a Product2 of Bundle type, associate ProductRelatedComponents with existing coverages, define Component Groups, and publish. That's the core promise of the module. |
| What if two plans use the same coverage with different rules? | The coverage lives once in the catalog (Simple product). Commercial differences (default sum insured, coinsurance, exclusions) are managed at the **ProductRelatedComponent** level — the link between bundle and component — or via **AttributeScopes** per plan. That's precisely reuse without duplication. |
| Do attributes support complex types (dates, references to other objects, hierarchies)? | Supported DataTypes include: Text, Number, Date, DateTime, Boolean, Picklist, Multipicklist, Currency, Percent. We model Suma Asegurada as Picklist for commercial control. Deducible can be Number. Actividad Económica is typically a Picklist with the CIIU catalog. There are no direct references to other objects via AttributeDefinition, but that's handled through standard Salesforce relationships where applicable. |
| How is the catalog versioned? What happens when a product that's already sold changes? | **[Conceptual answer — don't navigate to the fields live, they're not verified as populated in this org]** The Product2 model in Salesforce supports temporal versioning (fields like `ValidFrom` / `ValidTo` in the standard, and effective dating patterns from the managed package). Issued policies keep a reference to the product version in effect at issuance — this is visible in detail in Block 2 with InsurancePolicy and its coverages. Changes to a product don't impact already-issued policies until renewal. If the client asks to see the exact fields, say: *"In this demo org versioning is conceptual — for the ALFA project we detail it in the data architecture session, where we define the versioning and snapshotting policy."* |
| Can this catalog be exposed via API to an external portal or another core? | Yes. All the objects you saw (Product2, ProductClassification, ProductComponentGroup, AttributeDefinition, ProductRelatedComponent) have standard Salesforce REST and SOAP APIs. Additionally, Insurance on Core exposes catalog-specific endpoints. It can be synchronized with an external core or exposed to a commercial portal. |
| Maximum number of coverages a bundle supports? Any performance limits? | The limits are the standard Salesforce limits on relationships — thousands per product in practice. It's not a functional bottleneck. In this demo we have 7 ProductRelatedComponents under Plan Empresarial; we've seen implementations with 30-50 components without issues. |
| Can a business role also see the Structure tree, or only IT? | It's a standard tab on the Product2 object. It's controlled via profile / permission set — ALFA's product team will see it just as you do. No special setup needed. |
| Can the rate be configured by segment, region, or sum insured tier without code? | Yes. The base rate lives in **PricebookEntry** — a standard object. For differential rates, use **additional Price Books** by segment (Pyme Micro/Pequeña/Mediana) or **CalculationMatrix** for multi-dimensional rate matrices (age × activity × sum insured). Additionally, Insurance on Core ships the **Insurance Quote Default Pricing Procedure** and 7 rating templates (Product Level, Quote Level, Member-Based, Summary-Based) orchestrated via **ExpressionSet** — all declarative. |
| How do you block issuance if the risk doesn't meet criteria? Is there a native rules engine? | Yes. **Underwriting Rules** (BusinessRuleEngine motor) organized into Rule Groups by state transition (Draft→Submitted, Submitted→Approved, Submitted→Needs Review). Examples ALFA can model declaratively: "if Actividad = Manufactura and Sustancias Prohibidas ≠ Ninguna → block submit", "if Suma Asegurada > 500 MM COP → fire a flow that assigns review to the senior UW". Complementarily, **ProductConfigurationRule** exists for rules during configuration (defaults, hidden fields, required coverages). Both engines are native, no Apex. |
| How do you "publish" a product in Digital Insurance PCM? Is there a Draft/Released flow? | Digital Insurance PCM does not have Comms Cloud EPC's formal Draft/Released flow — the model is lighter and declarative: **(1)** `IsActive = true` on Product2, **(2)** a `ProductCategoryProduct` record that ties the product to a category within a catalog, **(3)** optionally the `AvailabilityDate`, `DiscontinuedDate`, `EndOfLifeDate` fields for temporal control. If ALFA needs a formal approval workflow, wrap it in an **Approval Process** on Product2 before `IsActive` flips to true. Formal versioning in Insurance lives at the **InsurancePolicy** level (endorsements, renewals), not at Product2. |

---

## 4. Transition to the next block

> "In this first block we saw the SMB catalog from its static definition through the moment it becomes a real policy: bundle modeling with its coverages and attributes, Quote configuration from the Panadería La Espiga account, and policy issuance **POL-PYME-2026-0001** via Issue Policy. In the next block we take this freshly-issued policy and explore the full lifecycle: the contract clauses that got materialized, midterm endorsement due to a sum insured increase, early renewal, and cancellation with pro-rata premium refund."

---

## 5. General block fallbacks

### 5.1 Structure tab doesn't load

- Refresh once (Ctrl/Cmd + R).
- If it persists: go to `Related` → `Product Related Components` — this shows the 7 flat relationships. Explain the hierarchy verbally: "Here you have the tree flattened, but the components are grouped by Component Group — Coberturas and Establecimiento."
- Last resort, show the Products list filtered by `Type = (empty)` and `SellOnlyWithOtherProducts = true` (visible in the standard list view) and describe the 6 coverages by their codes. Alternative via dev console/API: `SOQL: WHERE ProductClass = 'Simple'`.

### 5.2 An expected coverage doesn't appear

- Verify in the Products list that it has `IsActive=true`.
- If it doesn't appear, skip to another coverage and mention that the catalog has 6 active coverages, without dwelling on the missing one.

### 5.3 Salesforce slow or connection drops

- Explain: "This is a shared storm org, this is demo infrastructure. In production ALFA will have their own dedicated org with Salesforce SLAs."
- Meanwhile, switch to the architecture slide or show the catalog diagram drawn out.

### 5.4 Deep technical question I don't control

- Safe phrase: "Great question. I'm noting it and in the Q&A block at the end or in the next technical session I'll answer it at the level of detail it deserves — I want to give you the right answer, not an approximation."
- Write it in a side doc for follow-up.
- **Specific cases where NOT to improvise live**:
  - Product versioning (`ValidFrom` / `ValidTo` fields) — don't navigate to show them, they're not verified as populated. Answer conceptually (see Q&A) and offer a data architecture session.
  - Exact PAD counts per coverage if the live number differs from 8 — say "approximately 8, varies per coverage" rather than citing 48 total.

### 5.5 English locale causes confusion

- Preemptive from the start: "The demo user is in English, but all user-facing data — product, coverage, attribute names — is in Spanish. Salesforce supports label translation via Translation Workbench, and in production for ALFA it's configured in Colombian Spanish."

### 5.6 They ask about the 7th ProductRelatedComponent (expected 6, there are 7)

- Prepared answer: "Under the Plan Empresarial bundle there are 6 coverages plus the Establecimiento component — that's the 7th. Establecimiento captures the insured's premises data (square meters, economic activity, etc.) and that's why it's at the bundle level, not as a sellable coverage."

### 5.7 I can't find the attributes related list on Product Classification

- Related list labels on ProductClassification aren't pre-verified in this org and can vary by managed package version.
- **Quick Plan B**: don't search more than 5 seconds. Go back to the RC Extracontractual coverage (tab 2) → Attributes tab, and use those 8 attributes as visual evidence of inheritance. Phrase: *"The classification is the propagation mechanism; we already saw the attributes materialized on each coverage."*
- Reinforce the conceptual message (one classification → 6 coverages inherit) which is what matters, not the exact related list label.

### 5.8 The 9 bundle tabs don't fit on screen

- If Structure (or another key tab) is hidden behind the `>` (More Tabs):
  - Option A (better): lower the browser zoom to 100% and refresh.
  - Option B: click the `>` and select Structure from the dropdown menu — it works but breaks the visual flow.
- Ideally already resolved in setup 0.3. If it appears live, don't make a big deal — click `>`, select, and move on.

---

## 6. Block success metrics

At the end of the 30 minutes, ALFA should have seen and been convinced of:

- [ ] Product Catalog Management is a standard Insurance on Core module, not a customization.
- [ ] There's a real, functional bundle (**Plan Empresarial**) with 6 coverages and 2 Component Groups configured.
- [ ] The hierarchy is visible in the **Structure** tab — visual evidence, not a slide.
- [ ] Each coverage is an independent Simple product, reusable in other plans.
- [ ] There are ~8 key technical attributes per coverage (Suma Asegurada, Deducible, Coaseguro, etc.) modeled as reusable AttributeDefinitions — 48 total PADs.
- [ ] **Suma Asegurada** is a Picklist — commercial control over tiers, no code.
- [ ] Two active **Product Classifications** exist (Cobertura Pyme, Establecimiento Comercial) that centralize attributes and reduce maintenance.
- [ ] An ALFA product team can build new plans without depending on IT.
- [ ] The catalog has versioning (conceptual), governance, and standard Salesforce APIs.
- [ ] Everything shown feeds the policy lifecycle that will be seen in Block 2.

**Success signals in the room:**

- Client asks "how do you do X with this?" (not "does this do X?") — indicates they've bought the premise.
- Client asks to see a different plan or asks about edge cases — indicates engagement.
- Client takes notes or mentions absent colleagues — indicates perceived value.

**Warning signals:**

- Prolonged silence after step 2.3 (Structure) — means modularity didn't land. Repeat with different words.
- Repeated "is this custom?" questions — means they don't trust it's standard. Reinforce by showing the path from App Launcher to a standard object (Product2, AttributeDefinition).

---

**End of Runbook — Block 1.**

Target duration: 48 min. Suggested distribution:
- Mental setup + context: 1 min
- Step 2.1 (App Launcher): 2 min
- Step 2.2 (Bundle Details): 3 min
- Step 2.3 (Structure — centerpiece of the block): 5 min
- Step 2.4 (Coverage + Attributes): 5 min
- Step 2.5 (AttributeDefinition Suma Asegurada): 4 min
- Step 2.6 (Product Classifications): 4 min
- Step 2.7 (Catalog close + transition to runtime): 2 min
- Steps 2.8–2.14 (Quote + Configure + Issue Policy live): 13 min
- Step 2.15 (Pricing / PricebookEntry): 3 min
- Step 2.16 (Underwriting Rules): 3 min
- Step 2.17 (Product publication): 2 min
- Buffer for 1-2 live questions: 1 min
- **Total**: 48 min
