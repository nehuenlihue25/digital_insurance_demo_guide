# Digital Insurance (Insurance on Core) — Demo Guide

> Guía completa para armar, ejecutar y replicar una demo end-to-end de **Salesforce Insurance on Core / Digital Insurance** para el ramo Pyme (SME commercial insurance). Construida sobre el caso real del RFP de Seguros ALFA (Grupo Aval, Colombia) con Claude Code como copiloto.

## Qué encontrás acá

- **[PLAN_SEGUROS_ALFA_2026-07-09.md](PLAN_SEGUROS_ALFA_2026-07-09.md)** — plan maestro del proyecto: contexto, decisiones lockeadas, cronograma, verificación de la org
- **[SPEC_PYME_INTEGRAL_BLOQUE1.md](SPEC_PYME_INTEGRAL_BLOQUE1.md)** — spec técnica del producto Pyme (bundle + coverages + attributes + classifications), con teardown de Auto Gold como referencia
- **[INDICE_RUNBOOKS.md](INDICE_RUNBOOKS.md)** — pre-demo checklist maestro + agenda del día + guía Q&A
- **[RUNBOOK_BLOQUE1_PRODUCTO_PYME.md](RUNBOOK_BLOQUE1_PRODUCTO_PYME.md)** — Bloque 1 (48 min): Product Catalog Management + Quote configuration LWC + Issue Policy — click-by-click con talk track literal
- **[RUNBOOK_BLOQUE2_CICLO_POLIZA.md](RUNBOOK_BLOQUE2_CICLO_POLIZA.md)** — Bloque 2 (30 min): ciclo póliza, endoso, cláusulas
- **[RUNBOOK_BLOQUE3_SINIESTROS.md](RUNBOOK_BLOQUE3_SINIESTROS.md)** — Bloque 3 (45 min): siniestros end-to-end con reservas y pagos
- **[RUNBOOK_BLOQUE6_REPORTERIA.md](RUNBOOK_BLOQUE6_REPORTERIA.md)** — Bloque 6 (30 min): 3 dashboards + 11 reports en español
- **[demo-metadata/](demo-metadata/)** — replicación automática:
  - `scripts/` — 6 scripts sh que recrean toda la data en cualquier Digital Insurance org (~5-10 min)
  - `metadata/` — MDAPI packages listos para deploy (5 CRTs + 3 dashboards + 11 reports)
  - `learnings/` — 13 gotchas técnicos + 10 quirks del sf CLI en sandbox + setup RCA/RLM + 10 talk tracks para preguntas incómodas + 10 lecciones para el próximo Claude Code
  - `reference-ids.md` — tabla de referencia (con advertencia: no hardcodear)

## Replicar la demo en tu org

Prerequisitos:
- Org con **Digital Insurance + Revenue Cloud Advanced** habilitados
- `sf` CLI autenticado con el alias de tu org
- User con las PSLs Digital Insurance + RCA (ver `demo-metadata/learnings/rca-rlm-setup.md`)

```bash
export ORG=<alias-de-tu-org>
cd demo-metadata/
./scripts/00-prerequisites.sh $ORG    # verifica setup
./scripts/01-bloque1-product.sh $ORG  # bundle Pyme Integral + 6 coverages + 48 PADs
./scripts/02-bloque5-clauses.sh $ORG  # 6 InsuranceClauses en español + variableMaps
./scripts/03-bloque2-policy.sh $ORG   # Accounts + POL-PYME + coverages + transactions
./scripts/04-bloque3-claim.sh $ORG    # SIN-PYME + participants + items + reserves + payments
./scripts/05-bloque6-deploy-reports.sh $ORG  # deploy reports+dashboards via SOAP MDAPI
```

Los scripts son idempotentes, usan lookups dinámicos (nada de IDs hardcodeados) y prefijan `SF_DISABLE_LOG_FILE=true`.

Los pasos que **requieren UI** (OmniScript CreateQuoteDCT2, Product Configuration LWC, Issue Policy wizard) están documentados en el runbook Bloque 1 — no son automatizables.

## Los 5 gotchas más críticos (spoilers)

1. **`Product2.ProductClass` no es writable** — autoderivado de RecordType/Type
2. **`ProductRelatedComponent.Parent/ChildProductRole`** autoderivados de RelationshipType
3. **PADs NO se autogeneran** con `BasedOnId` — hay que crearlos manualmente (6 coverages × 8 attrs = 48 records)
4. **`InsuranceClause.Type`** (no `ClauseType` como muchos docs dicen)
5. **RCA Quote requiere `TransactionType`** poblado + Opportunity con RecordType `SimpleOpportunity` — sin eso el Product Configuration LWC lanza `Cannot read properties null (reading 'groups')`

Los 13 gotchas completos: [`demo-metadata/learnings/digital-insurance-gotchas.md`](demo-metadata/learnings/digital-insurance-gotchas.md)

## Créditos

Construido con [Claude Code](https://claude.com/product/claude-code) por Nehuen Lobo (@nehuenlihue25) para el proyecto Seguros ALFA (Grupo Aval, Colombia) — sustentación RFP 2026-07-09.

## Licencia

MIT (por definir según preferencia del owner)
