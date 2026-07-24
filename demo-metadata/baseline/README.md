# Baseline snapshot — what a working IDO looks like

This folder is a **reference snapshot** captured from a confirmed-working `FINS QBranch - INS on Core IDO` (release 262, API 67.0, 2026-07-23). Use it to verify your own IDO matches what the demo assumes, and to know exactly what to ask for if it doesn't.

> The IDO used to capture this snapshot (`ins-qbranch-alfa`) is a temporary Storm org and will eventually be recycled. That's why we captured this — the baseline is what survives. Never treat these files as "install instructions"; they're a verification checklist against your own freshly-provisioned IDO.

## Files

- **`permission-set-licenses.md`** — the 35 Permission Set Licenses that must be Active on the org and assigned to the demo user. Grouped by functional area (Digital Insurance core, Claims, FSC, RLM, Pricing, OmniStudio, etc.).
- **`permission-sets.md`** — the standard Permission Sets that come pre-provisioned in the IDO and must be assigned to the demo user (FINS Insurance role bundles + SDO base access).
- **`installed-packages.md`** — the managed packages installed in the IDO (Data Tool, EMC, Sales Cloud, Marketing Cloud, etc.). Presence of these confirms the IDO type.
- **`record-types.md`** — the standard Record Types available on Product2, Opportunity, InsurancePolicy, Claim, Account that the demo scripts and runbooks assume exist.

## How to use it

Before running any demo script:

1. Provision the IDO from STORM as documented in the root README.
2. Authenticate `sf` CLI against it with an alias.
3. Run `demo-metadata/scripts/00b-verify-baseline.sh <alias>` — this compares your live org against every entry in the baseline files and reports exactly which PSLs/PSs/packages/RecordTypes are missing.
4. Assign any missing PS/PSL to the demo user in Setup, then re-run the verify script until it prints all green.
5. Only then run `01-block1-product.sh` and the rest.

Skipping the baseline verify is the #1 cause of demo scripts failing halfway through — most errors surface as opaque messages (`"Insufficient Privileges"`, `"unknown field"`, `"cannot resolve reference"`) that trace back to a missing PSL assignment.

## Regenerating the baseline

If a future release changes the standard set of PSLs or packages in the IDO, regenerate the baseline against a freshly-provisioned IDO:

```bash
./demo-metadata/scripts/00c-capture-baseline.sh <alias>
```

*(This script is not in the repo yet — future improvement. For now the baseline is hand-curated from the queries used to build these files.)*
