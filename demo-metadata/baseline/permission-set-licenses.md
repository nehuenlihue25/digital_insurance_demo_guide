# Permission Set Licenses — required baseline

35 PSLs must be **Active** on the IDO **and assigned** to the demo user. Captured from a working FINS QBranch IDO (release 262). Grouped by functional area so a new SE can request them from the account team if the target org isn't an IDO.

The `00b-verify-baseline.sh` script queries `PermissionSetLicenseAssign` and reports which ones are missing on your user.

## Digital Insurance core (5)

Without these, the whole `InsurancePolicy`, `InsurancePolicyCoverage`, `InsurancePolicyTransaction`, `Claim` object family is inaccessible.

| DeveloperName | Label |
|---|---|
| `DigitalInsurancePolicyAdminUserPsl` | Digital Insurance Policy Administration |
| `DigitalInsuranceProductAdminPsl` | Digital Insurance Product Administration |
| `DigitalInsuranceProductAdminRunTimePsl` | Digital Insurance Product administration run time |
| `DigitalInsuranceClaimManagementAdmin` | Digital Insurance Claims Administration |
| `DigitalInsuranceClaimManagementUser` | Digital Insurance Claims Management |

## Claims Management foundation (5)

Without these the Claims extended objects (`ClaimCoverage`, `ClaimCovReserveAdjustment`, `ClaimCoveragePaymentDetail`, `ClaimPaymentSummary`) don't respond and the Block 3 runbook can't execute.

| DeveloperName | Label |
|---|---|
| `ClaimManagementAdmin` | Claims Administration |
| `ClaimMgmtPsl` | Claims Management |
| `ClaimsManagementFoundationPsl` | Claims Management Foundation |
| `ClaimFNOLPsl` | Claims FNOL |
| `InsuranceClaimMgmtPsl` | Insurance Claim Management |

## FSC + Insurance foundation (7)

The base sObjects (Account, Contact, Case) and Insurance role bundles depend on these.

| DeveloperName | Label |
|---|---|
| `FSCInsurancePsl` | FSC Insurance |
| `FSCInsuranceRecordSummaryPsl` | FSC Insurance Record Summary |
| `InsurancePolicyAndClaimPsl` | Insurance Policy and Claims |
| `InsuranceBrokeragePsl` | Insurance Brokerage |
| `InsuranceGroupBenefitsPsl` | Insurance Group Benefits |
| `FSCFoundationsPsl` | Financial Services Cloud Foundations |
| `FinancialServicesCloudExtensionPsl` | Financial Services Cloud Extension |

## Clause + Contract management (2)

Required for `InsuranceClause`, `InsuranceProductClause`, `InsurancePolicyProductClause`.

| DeveloperName | Label |
|---|---|
| `ClauseManagementUser` | Clause Management User |
| `ContractManagementUser` | Contract LifeCycle Management User |

## Revenue Cloud Advanced / RLM (3)

Required for the Block 1 Quote flow (`OmniScript CreateQuoteDCT2` + Product Configuration LWC + Salesforce Pricing).

| DeveloperName | Label |
|---|---|
| `RevenueLifecycleManagementUserPsl` | Revenue Cloud User |
| `DynamicRevenueOrchestratorUserPsl` | Fulfillment User PSL |
| `IndustriesConfiguratorPsl` | Product Configuration User |

## Pricing engine (6)

Salesforce Pricing (Core + Penny Perfect + Rate Management) — required for the pricing procedures behind the quote.

| DeveloperName | Label |
|---|---|
| `CorePricingDesignTime` | Salesforce Pricing Design Time |
| `CorePricingRunTime` | Salesforce Pricing Run Time |
| `PennyPerfectPricingPsl` | Penny Perfect Pricing Psl |
| `PricingAndBillingPSL` | Manage Pricing and Billing |
| `RatingDesignTimePsl` | Rate Management Design Time |
| `RatingRunTimePsl` | Rate Management Run Time |

## Context Service (2)

Required for the Product Configuration LWC runtime.

| DeveloperName | Label |
|---|---|
| `ContextServiceAdminPsl` | Context Service Admin |
| `ContextServiceRuntimePsl` | Context Service Runtime |

## OmniStudio (2)

Required for the OmniScript-driven Quote flow.

| DeveloperName | Label |
|---|---|
| `OmniStudioDesigner` | OmniStudio |
| `OmniStudioRuntime` | OmniStudio User |

## Business Rules Engine (2)

Required for underwriting rules and pricing dependencies.

| DeveloperName | Label |
|---|---|
| `BREDesigner` | Business Rules Engine Designer |
| `BRERuntime` | Business Rules Engine Runtime |

## Einstein / AI (1)

Required for Block 3 claims summarization prompt template.

| DeveloperName | Label |
|---|---|
| `EinsteinForFinancialServicesPsl` | Einstein for Financial Services |

## Billing (1)

Required for the "Cobranza" architecture story in Block 2 (payment schedules, retry logic).

| DeveloperName | Label |
|---|---|
| `RevLifecycleMgmtBillingPsl` | Billing |

## What if some are missing on my IDO?

**If you're on the correct IDO** (`FINS QBranch - INS on Core IDO`) they'll all be Active but not necessarily assigned to your user. Assign the missing ones from Setup → Users → your user → Permission Set License Assignments → Edit Assignments.

**If PSLs are missing at the org level** (not just unassigned), you're not on the right IDO. Provision the correct one via STORM as described in the root README.
