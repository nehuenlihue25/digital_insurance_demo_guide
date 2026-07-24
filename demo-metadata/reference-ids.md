# Reference IDs — historical snapshot from `ins-qbranch-alfa`

> ⚠️ **These IDs are a historical snapshot from ONE specific Storm org, captured 2026-07-08.** They will NOT match your org. Every automation script under `demo-metadata/scripts/` resolves IDs dynamically by Name / Code / DeveloperName; this file exists only as a debugging reference for the original build.
>
> **To get the equivalent IDs for YOUR org, run `./scripts/00c-resolve-ids.sh <your-alias>`** — it queries your live org and prints the equivalent table in a format you can copy-paste into your own working notes or `source` as shell variables.
>
> **Never copy an ID from this file into a script or a live command against your org** — every ID here will be wrong for any org that isn't the original one. This applies especially to the Storm URL, the User Id, Product2/Account/Policy/Claim/Dashboard IDs, and everything else.

## Org

| Item | Value |
|---|---|
| Org Id | 00Dg8000009T1MvEAK |
| Instance URL | https://storm-c90aab66569c63.my.salesforce.com |
| Demo username | storm.c90aab66569c63@salesforce.com |
| Alias | ins-qbranch-alfa |
| the technical backup (User Id) | 005g80000053bWPAAY |

## Block 1 — Products + Attributes + Classifications

### Product2
| Name | Code | Id | ProductClass (auto) |
|---|---|---|---|
| Plan Empresarial (bundle) | segPymeEmpresarial | 01tg8000003hS49AAE | Bundle |
| Responsabilidad Civil Extracontractual | rcExtracontractual | 01tg8000003hRmPAAU | Simple |
| Incendio y Aliados | incendioAliados | 01tg8000003hRo1AAE | Simple |
| Equipo Electronico | equipoElectronico | 01tg8000003hRpdAAE | Simple |
| Robo y Asalto Interior | roboAsalto | 01tg8000003hRrFAAU | Simple |
| Rotura de Maquinaria | roturaMaquinaria | 01tg8000003hRsrAAE | Simple |
| Sustraccion de Dinero y Valores | sustraccionDinero | 01tg8000003hNOjAAM | Simple |

### ProductClassification
| Name | Code | Id |
|---|---|---|
| Cobertura Pyme | coberturaPyme | 11Bg800000DRh4bEAD |
| Establecimiento Comercial | establecimientoComercial | 11Bg800000DRh6DEAT |

### AttributeDefinition (8)
| DeveloperName | Code | Id |
|---|---|---|
| Suma_Asegurada | SumaAsegurada | 0tjg8000000DPYTAA4 |
| Deducible | Deducible | 0tjg8000000DPa5AAG |
| Actividad_Economica | ActividadEconomica | 0tjg8000000DPbhAAG |
| Rango_Empleados | RangoEmpleados | 0tjg8000000DPdJAAW |
| Metros_Cuadrados_Local | MetrosCuadradosLocal | 0tjg8000000DPevAAG |
| Porcentaje_Coaseguro | PorcentajeCoaseguro | 0tjg8000000DPgXAAW |
| Deducible_Minimo_Evento | DeducibleMinimoEvento | 0tjg8000000DPi9AAG |
| Sustancias_Prohibidas | SustanciasProhibidas | 0tjg8000000DPjlAAG |

### ProductComponentGroup
| Name | Code | Id |
|---|---|---|
| Coberturas | Coberturas Pyme Empresarial | 0y7g80000009Z3NAAU |
| Establecimiento | Establecimiento Pyme Empresarial | 0y7g80000009Z3OAAU |

### ProductRelationshipType (OOTB)
| Name | Id |
|---|---|
| Bundle to Bundle Component Relationship | 0yog8000000DOkTAAW |
| Bundle to Product Classification Component Relationship | 0yog8000000DOkUAAW |

### ProductSellingModel
| Name | Type | Id |
|---|---|---|
| One Time | OneTime | 0jPg8000000BMJlEAO |

### Pricebook2
| Name | Id |
|---|---|
| Standard Price Book | 01sg8000002vuCPAAY |

### ProductCatalog
| Name | Id |
|---|---|
| Insurance Catalog | 0ZSg8000000D8pPGAS |

### ProductCategory
| Name | Code | Id |
|---|---|---|
| Seguros Pyme | pymeIntegral | 0ZGg8000000FLP7GAO |

## Block 2 — Accounts + Opportunity + Policy

### Accounts
| Name | Id |
|---|---|
| Panaderia La Espiga SAS | 001g800000T9v3QAAR |
| Ferreteria El Tornillo Ltda | 001g800000T9CVuAAN |
| Consultores Andinos SAS | 001g800000T9wFNAAZ |
| Cuerpo de Bomberos de Bogota | 001g800000TFRPuAAP |

### Opportunity
| Name | RecordType.DeveloperName | Id |
|---|---|---|
| Panaderia La Espiga - Seguro Pyme Empresarial | SimpleOpportunity | 006g8000004wldnAAA |

### Contact
| Name | Title | Id |
|---|---|---|
| Alan Reed | Ajustador Senior Ramo Patrimonial | 003g800000OA7SDAA1 |

### InsurancePolicy
| Name | Status | Id |
|---|---|---|
| POL-PYME-2026-0001 | In Force | 0YTg80000000hJVGAY |

### Quote (RCA-built asset)
| Name | Id | Notes |
|---|---|---|
| COT-PYME-2026-0001-Panaderia | 0Q0g80000013EQrCAM | Renamed from "Rachel Adams Auto Quote"; TransactionType=AutoTransactionType. AccountId still points to Rachel (not writable post-create) but the QLI structure is Plan Empresarial |

## Block 5 — InsuranceClauses

| Name | Code | Type | Id |
|---|---|---|---|
| Clausula General de Buena Fe | buenaFe | Clause | 1T5g800000000BJCAY |
| Exclusion de Actos Dolosos | actosDolosos | Exclusion | 1T5g800000000CvCAI |
| Exclusion Guerra y Terrorismo | guerraTerrorismo | Exclusion | 1T5g800000000EXCAY |
| Clausula de Coaseguro | coaseguro | Clause | 1T5g800000000G9CAI |
| Exclusion Actividades Extremas | actividadesExt | Exclusion | 1T5g800000000HlCAI |
| Clausula de Deducible Minimo | deducibleMinPyme | Clause | 1T5g800000000JNCAY |

## Block 3 — Claim + children

### Claim
| Name | Id |
|---|---|
| SIN-PYME-2026-0001 | 0Zkg80000000awLCAQ |

### ClaimCoverage
| Name | Id |
|---|---|
| CC-SIN-PYME-2026-0001-Incendio | 0kPg80000000OITEA2 |

### ClaimCovReserveAdjustment
| Name | Amount | Id |
|---|---|---|
| Reserva perdida directa Incendio | 45,000,000 | 0l7g800000002ppAAA |
| Reserva gasto lucro cesante | 5,000,000 | 0l7g800000002rRAAQ |

### ClaimCoveragePaymentDetail
| Name | Type | Status | Amount | Id |
|---|---|---|---|---|
| CCPD-01 Horno Pagado | Loss | Paid | 32,000,000 | 0l2g80000000PfxAAE |
| CCPD-02 Lucro Cesante Pendiente Autoridad | Expense | Pending Authority | 8,000,000 | 0l2g80000000PhZAAU |
| CCPD-03 Estanteria Pagada | Loss | Paid | 8,000,000 | 0l2g80000000Q2XAAU |

## Block 6 — Reports + Dashboards

### Folder
| Name | Type | Id |
|---|---|---|
| Seguros ALFA Pyme (Report) | Report | 00lg8000003rRd3AAE |
| Seguros ALFA Pyme (Dashboard) | Dashboard | 00lg8000003rGiXAAU |

### CustomReportType (5)
- InsurancePolicy_Pyme__c
- Claim_Pyme__c
- InsurancePolicyCoverage_Pyme__c
- ClaimCoveragePaymentDetail_Pyme__c
- ClaimCovReserveAdjustment_Pyme__c

### Reports (11)
The API names are `Cartera_Pyme_por_Industry`, `Coberturas_Activas_por_Tipo_Pyme`, `Loss_Ratio_Pyme`, `Pagos_Aprobados_vs_Pendientes_Pyme`, `Polizas_por_Status_Pyme`, `Polizas_Proximas_a_Vencer_Pyme`, `Prima_Emitida_por_Plan_Pyme`, `Prima_Emitida_por_Producto_Pyme`, `Reserva_Total_Pyme`, `Siniestros_por_Estado_Pyme`, `Total_Prima_Emitida_Pyme`. All in the Seguros_ALFA_Pyme folder.

### Dashboards (3)
- Tablero_Siniestralidad_Pyme_2026
- Tablero_Renovaciones_Pyme_2026
- Tablero_Produccion_Pyme_2026
