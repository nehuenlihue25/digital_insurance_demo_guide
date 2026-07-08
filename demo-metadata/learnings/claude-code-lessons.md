# Lecciones para Claude Code — Digital Insurance demo builds

Este documento es "de mí para mí". Si el próximo Claude Code (o yo en otra sesión) construye una demo similar, leer esto primero.

## Lección 1: NO afirmar diagnósticos sin evidencia dura

**Qué hice mal en esta demo**: en dos momentos declaré con confianza que "RCA no está instalado en la org", primera vez cuando SalesTransactionDefinition dio INVALID_TYPE, segunda vez cuando SalesTransactionType tenía 0 records. Ambas veces era falso: RCA ESTABA instalado, sólo faltaban PSLs/PS al usuario.

**Regla**: cuando un sObject devuelve INVALID_TYPE o NOT_SUPPORTED, tratar como HIPÓTESIS "no accesible al usuario", no como CONFIRMACIÓN "objeto no existe". Verificar con:
1. Query PSLs disponibles en la org (no solo las asignadas al user)
2. Cross-reference con otros indicadores (fields relacionados en objetos vecinos — ej. Quote.CalculationStatus con 20+ estados RCA es evidence irrefutable que RCA está)
3. Asignar TODAS las PSLs candidatas al usuario y re-query
4. Solo declarar "no instalado" tras confirmar el tercer intento

## Lección 2: Los nombres de sObjects no son intuitivos

**Qué hice mal**: usé `ClaimAssessment`, `ClaimReserve`, `ClaimPayment`, `ClaimAdjuster` en el spec inicial — TODOS inventados. Los reales son diferentes (ver `digital-insurance-gotchas.md`).

**Regla**: antes de spec-ear, ejecutar `sf sobject list --sobject standard` filtrando por prefix ("Claim", "Insurance", "Product") y trabajar SOLO con los que aparezcan. NO extrapolar desde patrones de otras clouds (CG, FSC generic).

## Lección 3: Fields required NO WRITABLES son un patrón, no una excepción

**Qué hice mal**: Product2.ProductClass, ProductRelatedComponent.ParentProductRole y ChildProductRole, Quote.AccountId (post-create), Quote.OpportunityId (post-create), TransactionAmount vs "Amount" en InsurancePolicyTransaction... todos me dieron sorpresa la primera vez.

**Regla**: al planear un INSERT/UPDATE, siempre correr `sf sobject describe` primero y filtrar por `createable=false OR updateable=false`. Estos fields no van en el payload aunque el schema diga `nillable=false`.

## Lección 4: Sandbox constraints requieren workarounds SOAP

**Qué hice mal**: intenté 3-4 veces `sf project deploy start` esperando que funcionara. Siempre bloquea por `~/.sfdx/` write. Al final resolvimos con SOAP directo — que funciona perfecto pero descubrirlo tomó tiempo.

**Regla**: si el sandbox tiene write restrictions, NO intentar herramientas que asuman $HOME writable. Ir directo al workaround:
- Deploy metadata → SOAP `services/Soap/m/62.0`
- Retrieve metadata → SOAP retrieve
- Auth refresh → hacer login web manual fuera del sandbox

## Lección 5: Los workflow diagnósticos deben ser adversariales

**Qué hice mal**: workflows tempranos aceptaban conclusiones optimistas ("plan build viable, todos los objetos accesibles") cuando en realidad faltaban gaps críticos. Los critique passes eran muy suaves.

**Regla**: para task ultracode, incluir SIEMPRE una Phase de critique adversarial que:
1. Verifica cada claim del spec contra data real
2. Corre tests concretos (INSERT de prueba, LWC render test)
3. Falla explícitamente si algo no coincide
4. Prefiere resultados null a resultados speculativos

## Lección 6: Sesiones a lo largo del día tienen problemas de auth

**Qué me pasa**: entre sesión y sesión, el access token expira. `sf org display` con sandbox intenta refresh via `~/.sfdx/` que bloquea. La solución es re-login manual — pero eso rompe el flujo.

**Regla**: si la sesión va a durar >2h de reloj, hacer prompt al usuario para que haga `sf org login web` proactivamente al inicio, incluso si el token actual funciona. Le dedico 1 tool call al principio para verificar auth freshness.

## Lección 7: OmniScript + Product Config LWC es el path canónico, no INSERT via API

**Qué hice mal**: intenté construir el Quote Pyme via `sf data create record --sobject QuoteLineItem` con `ParentQuoteLineItemId` linking manual. FALLÓ (ParentQuoteLineItemId no es writable directo). La única forma correcta de crear un Quote con estructura RCA es via el OmniScript CreateQuoteDCT2 → Browse Catalogs → Configure LWC.

**Regla**: para demos RCA/Digital Insurance:
1. Los Product2 + PADs + Coverages + Classifications SÍ se crean via API
2. Los Quotes CON ESTRUCTURA de bundle+coverages NO. Requieren el OmniScript/LWC.
3. Documentar en el runbook que los pasos runtime son UI-only y no automatizables

## Lección 8: Ultracode workflows aceleran cuando hay paralelismo real

**Qué hice bien**: los workflows con 3-8 agentes paralelos investigando aspectos ortogonales (docs research + org queries + FlexiPage inspection) fueron 3-5x más rápidos que hacer serial.

**Qué hice mal**: algunos workflows tuvieron agentes con prompts idénticos o overlapping — cero paralelismo real, solo overhead.

**Regla**: antes de lanzar workflow, dibujar el diagrama:
- 3+ items ortogonales que se pueden hacer en paralelo → workflow YES
- 1-2 items dependientes o pequeños → agent directo o Bash directo

## Lección 9: Documentar fallbacks OBLIGATORIAMENTE

**Qué hice bien esta demo**: cada runbook tiene sección "fallback" en cada Paso. En vivo esto salvó tiempo cuando algún click no cargaba como esperado.

**Regla**: cada runbook step DEBE tener 1 línea "si no aparece X, hacer Y". No opcional.

## Lección 10: Memoria persistente para el próximo Claude

Después de esta demo, actualicé `~/.claude/projects/-Users-nlobo-claude-projects-Grupo-Aval-Insurance/memory/` con:
- `project_seguros_alfa.md` — contexto del proyecto
- `feedback_digital_insurance_product_config.md` — gotchas técnicos
- `feedback_no_hardcoded_ids.md` — regla de lookups dinámicos
- `feedback_sf_cli_sandbox.md` — env vars requeridos

El próximo Claude en este directorio va a leer esto automáticamente. ESE es el punto de la memoria persistente.
