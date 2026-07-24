# Record Types — required baseline

Standard Record Types the demo scripts and runbooks assume exist on the base sObjects. Captured 2026-07-23 from a working FINS QBranch IDO.

## Product2

The demo builds a product hierarchy using these record types. All are shipped by Digital Insurance — no custom RTs required.

| DeveloperName | Label | Used for |
|---|---|---|
| `Commercial` | Commercial | Root bundle Product2 (`segPymeIntegral`) |
| `Coverage` | Coverage | The 6 child coverage Product2s |
| `Product` | Product | Generic Product2 (fallback) |
| `ClaimProduct` | Claim Product | Claims-side products |
| `ClaimDamage` | Claim Damage | Claim item — damage line |
| `ClaimInjury` | Claim Injury | Claim item — injury line |
| `Claim_Root_Product` | Claim Root Product | Root Claim Product2 |
| `InsuredItem` | InsuredItem | Insured items per policy participant |
| `InsuredParty` | InsuredParty | Named insured / additional insured |
| `FINS_Benefit` | Benefit | Group Benefits scenarios |
| `GroupCensusMember` | GroupCensusMember | Group Benefits census |
| `GroupSummary` | GroupSummary | Group Benefits summary |

**Key convention** — the Block 1 script uses `Commercial` for the bundle and `Coverage` for each child. This is the pattern from Auto Gold. Do not use `Product` (generic) for either — the LWCs behave differently.

## Opportunity

Block 1's quote flow requires a specific Opportunity RecordType so the Product Configuration LWC works.

| DeveloperName | Label | Used for |
|---|---|---|
| `SimpleOpportunity` | Simple Opportunity | **Required for RCA Quote flow** (see CLAUDE.md, gotcha #13) |
| `FINS_Commercial` | Commercial | Alternative for commercial policies |
| `FINS_BrokerCRM_BOR` | BrokerCRM - BOR | Broker CRM scenarios |
| `ChannelPartner` | Channel (Partner) | Channel partner opportunities |

**Non-negotiable**: use `SimpleOpportunity`. The other RTs don't have the correct pricebook + configurator bindings for the Pyme demo.

## InsurancePolicy

| DeveloperName | Label | Used for |
|---|---|---|
| `FINS_InsurancePolicy_Property_Casualty` | Property & Casualty | **The Pyme policy** — SME / Commercial line |
| `FINS_InsurancePolicy_EB` | Employee Benefits | Group life/health scenarios (out of scope for Pyme) |

## Account

| DeveloperName | Label | Used for |
|---|---|---|
| `SDO_Account_Simple` | Account | **The insured Account** (Panadería La Espiga in the demo) |
| `Business_Account` | Business Account | Alternative for business accounts |
| `FINS_Commercial_Account` | Commercial Account | FINS-specific commercial account |
| `Agency_Brokerage` | Agency/Brokerage | For broker distribution scenarios |
| `FINS_Brokerage_Client_BrokerCRM` | Brokerage Client | For BrokerCRM scenarios |
| `FINS_Carrier_Vendor` | Carrier/Vendor | For carrier/vendor accounts |
| `PersonAccount` | Person Account | Standard Person Account |
| `SDO_PersonAccounts` | Person Accounts | SDO Person Account variant |
| `SDO_Account_Partner` | Partner | Partner accounts |

## Claim

No custom RecordTypes are required — Block 3 uses the standard master RT. Verify via `sf sobject describe --sobject Claim` if in doubt.

## Verification query

```bash
export SF_DISABLE_LOG_FILE=true
sf data query --target-org <alias> --result-format csv \
  --query "SELECT SObjectType, DeveloperName, Name, IsActive FROM RecordType WHERE SObjectType IN ('Product2','Opportunity','InsurancePolicy','Account') AND IsActive=true ORDER BY SObjectType, DeveloperName"
```

Missing `SimpleOpportunity` is the most common cause of Block 1 quote flow failure — the LWC throws `Cannot read properties null (reading 'groups')` without it.
