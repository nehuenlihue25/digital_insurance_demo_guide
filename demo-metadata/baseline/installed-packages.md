# Installed Packages — baseline

Managed packages present in a working FINS QBranch IDO. Not all of these are used by the demo directly — but their presence confirms the IDO type. Captured 2026-07-23.

## Packages present (partial list — top 30)

| Package Name | Namespace | Version |
|---|---|---|
| Data Tool | NXDO | 1.31 |
| EMC | EMC | 1.18 |
| Einstein Playground | einsteinplay | 1.35 |
| Marketing Cloud | et4ae5 | 260.0 |
| Pardot | pi | 5.9 |
| Sales Cloud | cdp_crm_dk1 | 1.4 |
| Sales Insights | OIQ | 1.0 |
| Quip | Quip | 2.8 |
| Quip Connected App | QuipConnected | 1.3 |
| Case Timer Unmanaged | (unmanaged) | 2.13 |
| CDPAdvertising | cdpactvstrgptnr | 3.31 |
| Content Standard Checklist Lightning Managed | aqi_ltng_mng | 1.7 |
| Assign Topics Unscoped | assigntopics | 1.2 |
| b2bmaIntegration | pi3 | 1.2 |
| DE Dashboard | (unmanaged) | 2.1 |
| Email Video Component | asj | 1.2 |
| Engagement_A4S | lex_engmnt | 1.0 |
| EngageReports | engage_reports | 1.33 |
| Incident Management Dashboard | imdashboard | 1.0 |
| Knowledge Dashboard | (unmanaged) | 1.17 |
| Launch Flow Modal | sf_flowmodal | 1.15 |
| Lightning Lead Inbox (Community) | (unmanaged) | 1.0 |
| Lightning Mass Delete | (unmanaged) | 1.0 |
| MarketingExternalAction | MktgExtAction | 1.1 |
| Mass Edit Related Lists | MERL | 1.9 |
| PardotEngagementHistoryDemo | (unmanaged) | 2.1 |
| Pulse for Salesforce - Standalone | P4SF_Standalone | 1.13 |
| qbrix-devops-tools-v2 | qbrix_devops | 0.1 |
| QLabs_Utilities | qbranch | 1.193 |

## What matters for this demo

None of these packages are **strictly required** for the runbooks to work — Digital Insurance itself is not a managed package, it's provided as native platform features enabled via PSLs. But two hints suggest you're on the right IDO type:

- **`QLabs_Utilities` (qbranch)** at v1.190+ — this is the Q-Branch demo toolkit. Its presence means "yes, this is a QBranch-lineage IDO", and it's a good proxy for the IDO name.
- **`Data Tool` (NXDO)** — used by the FINS scenario data loader; often referenced by the FINS_ISS_Demo_* Permission Sets.

If you don't see `qbranch` namespace in your org, you're likely on a different IDO type (SDO Financial Services, SDO Sales, etc.) — provision the correct one from STORM.

## Verifying in your own org

```bash
export SF_DISABLE_LOG_FILE=true
sf data query --target-org <alias> --use-tooling-api \
  --query "SELECT SubscriberPackage.Name, SubscriberPackage.NamespacePrefix FROM InstalledSubscriberPackage WHERE SubscriberPackage.NamespacePrefix IN ('qbranch','NXDO','EMC')"
```

If the result is empty, you're on the wrong IDO type.
