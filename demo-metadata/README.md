# Demo Metadata — Seguros ALFA (Grupo Aval)

## Propósito
Toda la información necesaria para (1) replicar la demo Insurance on Core Pyme en otra org, y (2) evitar los mismos errores que se cometieron durante esta build.

## Contexto rápido
- Cliente: Seguros ALFA (Grupo Aval Colombia)
- Sustentación: 2026-07-09 (jueves) 8:00-14:00 hora Colombia
- Org: ins-qbranch-alfa (`storm.c90aab66569c63@salesforce.com`)
- Producto: **Seguro Pyme Integral** (bundle) con 4 default + 2 opcionales, 8 atributos por cobertura, 6 clauses en español
- Documentos operativos: PLAN_SEGUROS_ALFA_2026-07-09.md + SPEC_PYME_INTEGRAL_BLOQUE1.md + RUNBOOK_BLOQUE1..6.md + INDICE_RUNBOOKS.md (todos en el directorio parent)

## Estructura de esta carpeta

```
demo-metadata/
├── README.md                    ← este archivo
├── scripts/                     ← scripts sh para recrear la demo
│   ├── 00-prerequisites.sh      ← verificar org + PSLs + PS
│   ├── 01-bloque1-product.sh    ← crear catalog + product + coverages + attrs
│   ├── 02-bloque5-clauses.sh    ← crear InsuranceClauses + productClauses + variableMaps
│   ├── 03-bloque2-policy.sh     ← accounts + policy + coverages + transactions + policy clauses
│   ├── 04-bloque3-claim.sh      ← claim + participants + items + coverage + reserves + payments
│   └── 05-bloque6-deploy-reports.sh ← deploy reports+dashboards via SOAP MDAPI
├── metadata/
│   ├── reports-dashboards/      ← MDAPI package (11 reports + 3 dashboards)
│   └── custom-report-types/     ← MDAPI package (5 CRTs)
├── learnings/                   ← qué aprender para no repetir errores
│   ├── digital-insurance-gotchas.md
│   ├── sf-cli-sandbox-quirks.md
│   ├── rca-rlm-setup.md
│   ├── narrative-fallbacks.md
│   └── claude-code-lessons.md   ← específicamente para Claude Code
└── reference-ids.md             ← tabla de IDs actuales (referencia, no hardcodear en scripts)
```

## Cómo replicar en una org nueva

Prerequisitos:
- Org Digital Insurance con Revenue Cloud Advanced (RCA) provisionado — [ver `learnings/rca-rlm-setup.md`](learnings/rca-rlm-setup.md) para verificar
- User con PSLs Digital Insurance + RCA — [ver `scripts/00-prerequisites.sh`](scripts/00-prerequisites.sh)
- `sf` CLI autenticado; `export SF_DISABLE_LOG_FILE=true` en el shell
- Alias de la org en `sf org list`

Orden de ejecución:
```bash
export ORG=<alias-de-tu-org>
./scripts/00-prerequisites.sh $ORG
./scripts/01-bloque1-product.sh $ORG
./scripts/02-bloque5-clauses.sh $ORG
./scripts/03-bloque2-policy.sh $ORG
./scripts/04-bloque3-claim.sh $ORG
./scripts/05-bloque6-deploy-reports.sh $ORG
```

Cada script debe tardar 30-90 segundos. Total ~5-10 min de build.

## Steps que requieren UI (no automatizables)

- **Bloque 1 Pasos 2.8-2.14** (Quote → Configure → Issue Policy): requieren OmniScript CreateQuoteDCT2 + Product Configuration LWC en vivo. Ver RUNBOOK_BLOQUE1 sección "Fase 4" para el click path.
- **Layout de Insurance Policy** para mostrar Transactions y Policy Product Clauses en la Related tab: editar Page Layout en Setup UI (~5 min).
- **Locale del user demo** (opcional): cambiar a es_CO en Setup > Users si se quiere labels en español.

## Learnings clave (spoilers)

Ver `learnings/` completo, pero los 5 más críticos:

1. **`Product2.ProductClass` no es writable** — se autoderiva de `RecordType` (Coverage → Simple) o `Type` (Bundle → Bundle). No incluir en INSERT payload.
2. **`ProductRelatedComponent.ParentProductRole`/`ChildProductRole`** autoderivados de `ProductRelationshipTypeId`. Idem, no incluir.
3. **PADs NO se autogeneran** con `BasedOnId` — hay que crear `ProductAttributeDefinition` manualmente uno por (Product2 × ProductClassificationAttr).
4. **`InsuranceClause.Type` (no `ClauseType`)** — es error de doc típico.
5. **RCA Quote requiere `TransactionType` seteado** (AutoTransactionType o GroupInsuranceTransactionType); sin eso el Product Configuration LWC lanza `Cannot read properties null (reading 'groups')`.

## Contacto

Runbooks + este metadata son artefactos de la demo de Nehuen Lobo (@nlobo) para el proyecto Seguros ALFA — Grupo Aval.
