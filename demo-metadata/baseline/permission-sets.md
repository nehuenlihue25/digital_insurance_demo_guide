# Permission Sets — required baseline

The FINS QBranch IDO ships with a set of role-specific and demo-specific Permission Sets. These must be **assigned** to the demo user before running the scripts. Captured from a working IDO on 2026-07-23.

## FINS Insurance role bundles (essential — required for Block 1, 2 and 3)

| PS API Name | Label |
|---|---|
| `FINS_Claims_Admin` | FINS Claims Admin |
| `FINS_Claims_Misc` | FINS Claims Misc |
| `FINS_ISS_INS_Demo_BrokerCRM` | ISS Demo: INS BrokerCRM |
| `FINS_ISS_Demo_INS_Distribution_Management_CDM` | ISS Demo: INS Distribution Management (CDM) |
| `FINS_ISS_Demo_INS_Independent_Agent` | ISS Demo: INS Independent Agent |
| `FINS_ISS_Demo_INS_Service` | ISS Demo: INS Service |

The FINS Claims role bundles give visibility to the extended Claims data model (`ClaimCoverage`, `ClaimCovReserveAdjustment`, etc.) with the right layout permissions. The ISS Demo bundles give the demo-friendly Insurance Agent Console app + tabs.

## Revenue Cloud / RLM PS (required for Block 1 quote flow)

| PS API Name | Label |
|---|---|
| `SDO_Revenue_Cloud_Base` | Revenue Cloud Base Permissions |
| `SDO_RLM_DRO` | RLM DRO |

## OmniStudio + Analytics PS

| PS API Name | Label |
|---|---|
| `OmniAnalytics` | OmniAnalytics |
| `SDO_Analytics_Base_Permissions` | Analytics - Base Permissions |

## Contracts (required for InsurancePolicyProductClause)

| PS API Name | Label |
|---|---|
| `Contracts_Object_Permissions` | Contracts Object Permissions |

## SDO base bundles (optional but recommended — cleaner demo)

The IDO comes with a set of demo-friendly SDO_ permission sets that hide non-demo tabs and enable base access to standard apps. Not strictly required for the scripts to run, but the demo tabs look right when these are on.

| PS API Name | Label |
|---|---|
| `SDO_Admin_Base_Access` | Admin - Base Access |
| `SDO_Sales_All_Permissions` | Sales - All Permissions |
| `xDO_Sales_Base_Access` | Sales - Base Brix Access |
| `xDO_CMS_Mock_Base` | CMS Mock - Base Access |

## How the verify script uses this

`00b-verify-baseline.sh` queries `PermissionSetAssignment` for the demo user and reports which of the "essential" PS (the top three groups) are missing. It doesn't fail on missing SDO bundles — those are cosmetic.

## Assigning missing PS in one shot

If several are missing, assign them all in one CLI batch instead of clicking through Setup:

```bash
export SF_DISABLE_LOG_FILE=true
USER_ID=$(sf data query --target-org <alias> \
  --query "SELECT Id FROM User WHERE Username='<your-username>'" \
  --result-format csv | tail -n1)

for ps in FINS_Claims_Admin FINS_ISS_INS_Demo_BrokerCRM SDO_Revenue_Cloud_Base; do
  PS_ID=$(sf data query --target-org <alias> \
    --query "SELECT Id FROM PermissionSet WHERE Name='$ps'" \
    --result-format csv | tail -n1)
  sf data create record --sobject PermissionSetAssignment --target-org <alias> \
    --values "AssigneeId=$USER_ID PermissionSetId=$PS_ID"
done
```
