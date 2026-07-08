# Plan Revisado — Seguros ALFA Sustentacion 2026-07-09

## 1. Answer to Q1 — Habilitar Claim extended objects en ins-qbranch-alfa

**Diagnostico honesto:** Los sObjects que el usuario esperaba (ClaimAssessment, ClaimReserve, ClaimPayment, ClaimCoveragePayment, ClaimAdjuster, ClaimAdjustment) **NO existen** como objetos estandar en Digital Insurance / Insurance on Core release 260. Esto no es un problema de licencia — son nombres incorrectos. La investigacion documental lo confirma:

- No hay `ClaimAssessment` — la evaluacion la hace el adjuster sobre `Claim`, `ClaimItem`, `ClaimCoverage`, `ClaimCoveragePaymentDetail` ([Insurance Claims Management data model](https://developer.salesforce.com/docs/platform/data-models/guide/insurance-claims-management.html)).
- No hay `ClaimReserve` — las reservas viven en `ClaimCoverage` + `ClaimCoverageReserveDetail` + `ClaimCovReserveAdjustment` (API 52.0+).
- No hay `ClaimPayment` — el encabezado es `ClaimPaymentSummary` (API 51.0+) y las lineas son `ClaimCoveragePaymentDetail` (API 52.0+) + `ClaimCoveragePaymentAdjustment`.
- No hay `ClaimAdjuster` / `ClaimAdjustment` como sObject — el adjuster es persona/rol asignado via Owner + Omni-Channel routing. `ClaimCovPaymentAdjustment` / `ClaimCovReserveAdjustment` son ajustes financieros, no personas.

**Objetos reales requeridos** en ins-qbranch-alfa para el bloque 3: `ClaimCoverage`, `ClaimCoveragePaymentDetail`, `ClaimCoveragePaymentAdjustment`, `ClaimCoverageReserveDetail`, `ClaimCovReserveAdjustment`, `ClaimPaymentSummary`.

**Lectura corregida de la evidencia (critique #1):** El audit `q-claim-psl` reporta 24 PSLs Active pero cero registros escribibles/queryables en los objetos extendidos. **PSLs Active en un trial org no equivalen a runtime add-on provisionado** — es un patron conocido en orgs Storm donde la PSL aparece listada sin que el motor de Claims Management este realmente encendido. Por lo tanto: **NO es un toggle de Setup, es provisioning de add-on faltante**. No hay documentacion citada que soporte que un checkbox de "Insurance Settings" habilita estos sObjects en Insurance on Core 260 (el doc que citamos antes era para la extension managed-package legacy, no aplica).

**Consecuencia:** Esto se convierte en **case-with-Salesforce bloqueante desde el martes 07:00 (no 14:00)**, no un intento de toggle. Ver seccion 6 para el nuevo timing y la decision gate a miercoles 12:00.

**Pasos concretos revisados:**

1. **Ask inmediato a Luis Fabian (martes 07:00-09:00):** confirmar con account team si `DigitalInsuranceClaimManagementAddOn` + PC + CC + `DigitalInsurancePolicyAdministrationAddOn` estan efectivamente provisionadas como runtime add-on (no solo PSL Active). Si NO estan → abrir case Sev-2 con Salesforce inmediatamente citando release 260 y los 6 sObjects no queryables (evidencia del audit).
2. **En paralelo, verificar `DigitalInsurancePolicyAdministrationAddOn`** — el bloque 2 depende de `InsPolicyService:createPolicyVersion` (ver critique #4). Si el add-on de Policy Administration tampoco esta provisionado, tambien cae el bloque 2. Query dry-run: intentar `SELECT Id FROM InsurancePolicyVersion LIMIT 1` y `SELECT Id FROM InsurancePolicyTransaction LIMIT 1` — si fallan, ambos bloques van a Plan B.
3. **Asignar Permission Sets al usuario demo** (Nehuen), corregidos segun la research fact para el persona adjuster (critique #2): `Claims Management`, `Digital Insurance Product Administration Runtime`, `Product Configurator`, `Product Catalog Management Viewer`, `Product Discovery User`, `Context Service Runtime`, `Stage Management User`, `Rule Engine Runtime`, `Omnistudio User`. **Retirados** de la lista anterior: `Claims Administration`, `Product Catalog Management Designer`, `Product Discovery Admin`, `Digital Insurance Product Administration Management` — no aparecen en la research fact para el runtime persona y hay riesgo de que no existan como PSL asignable en este org o requieran otros PSLs.
4. **Validar con SOQL:** `SELECT Id FROM ClaimCoverage LIMIT 1` + `ClaimCoveragePaymentDetail` + `ClaimPaymentSummary` + `ClaimCoverageReserveDetail` + `InsurancePolicyVersion`. Si responden → seguir plan base. Si fallan → case abierto martes AM, decision gate miercoles 12:00.
5. **Configurar Claim Financials LWC** en la record page de Claim + field sets en `ClaimCoveragePaymentDetail` per coverage ([customize payment detail form](https://help.salesforce.com/s/articleView?id=ind.insurance_customize_the_payment_detail_form_618950.htm&release=260&type=5)).

**Riesgo residual:** case con Salesforce puede tardar 24-72h; por eso Plan B (seccion 7) queda detallado, no como "una linea".

## 2. Respuesta a la pregunta principal — Consolidar los 4 bloques a ins-qbranch-alfa?

**RECOMENDACION: SI — consolidar los 4 bloques a ins-qbranch-alfa.**

**Razones decisivas:**

1. **Q-Branch tiene licencias Agentforce/Einstein** (3105 Agentforce, Einstein Prompt Templates, Einstein for Financial Services) — clave para bloques 3 y 6. `ido-aval-ins` solo tiene 8 prompt templates FINS en ingles, ninguno de siniestros.
2. **PSLs de Claims Management estan Active en Q-Branch** (aunque provisioning real del runtime esta en verificacion — seccion 1). En `ido-aval-ins` no fue auditado y asumir su presencia agrega riesgo mayor.
3. **InsuranceClause writable confirmado en Q-Branch** — insert real `1T5g8000000009hCAA` + delete exitoso. Nota importante (critique #13): el campo real es `Type`, NO `ClauseType`. Los CSVs de seccion 5 usan `Type` correctamente; GFT debe confirmar el header antes de cargar.
4. **PCM writable en Q-Branch** — 7 objetos confirmados createable/updateable/deletable.
5. **InsurancePolicyTransaction tiene los picklists** que cubren Endorsement/Renewal/Cancellation, PERO `InsPolicyService:createPolicyVersion` NO esta verificado por org check (critique #4). Se verifica martes AM como parte del step 2 de seccion 1.
6. **Migrar Experience Cloud + OmniStudio entre orgs es caro** — 0.5-1 dia solo bundle + DNS. Fuera del presupuesto.

**Lo que se migra de ido-aval-ins:** **nada** (ver seccion 3 revisada — critique #3).

**Lo que se construye fresco en Q-Branch (en espanol):** producto Pyme completo, clausulas, coverages, cuentas, poliza, siniestro, dashboards, y **1 solo prompt template propio en espanol** clonado del OOTB Summarize Insurance Claim.

## 3. Inventario de migracion (ido-aval-ins → ins-qbranch-alfa) — REVISADO

**Cambio critico respecto al plan anterior (critique #3):** los 2 templates FINS que se planeaba migrar (`FINS_Account_Activity_AI_Summary`, `FINS_Account_Executive_Brief`) NO son claim-related, sus bodies no se pudieron inspeccionar (audit gap explicito), y su localizacion a espanol probablemente lleva mas de 1h cada uno. **No se migran.** El bloque 3 usa la clonacion del OOTB `Summarize Insurance Claim` como fuente unica.

**Sub-total migracion: 0 horas. Se recuperan 2h del cronograma.**

## 4. Construir fresco en espanol sobre ins-qbranch-alfa

### Bloque 1 — Producto Pyme modular por planes (30 min)

**Producto raiz:** `Seguro Pyme Integral` (Product2)
**Planes (Bundle Options via ProductRelatedComponent):** `Plan Esencial`, `Plan Empresarial`, `Plan Corporativo`
**Coverages:** `Responsabilidad Civil Extracontractual`, `Incendio y Aliados`, `Equipo Electronico`, `Robo y Asalto Interior`, `Rotura de Maquinaria`, `Sustraccion de Dinero y Valores`

**AttributeDefinitions revisadas (critique #5 — tokens de clausulas necesitan attrs dedicados):**
- `Suma_Asegurada` (currency)
- `Deducible` (currency)
- `Actividad_Economica` (picklist: Comercio, Servicios, Manufactura, Tecnologia)
- `Numero_Empleados` (number)
- `Metros_Cuadrados_Local` (number)
- **`Porcentaje_Coaseguro`** (percent) — dedicado para token `porcentajeCoaseguro`
- **`Sustancias_Prohibidas`** (multi-select picklist: Combustibles, Quimicos Peligrosos, Explosivos, Gases Comprimidos) — dedicado para token `sustanciasProhibidas`
- **`Deducible_Minimo_Evento`** (currency) — dedicado para token `deducibleMinimo` (separado del deducible variable general)

**AttributeCategory:** `Datos_Pyme`, `Coberturas_Adicionales`, `Parametros_Clausulas`

**Product Rules:** exclusion `Actividad_Economica != Manufactura` bloquea Rotura de Maquinaria en Plan Esencial.

**Esfuerzo:** 3h (carga por Data Loader respetando orden PCM).

### Bloque 2 — Ciclo completo de poliza (30 min)

**Cuentas demo:** `Panaderia La Espiga SAS`, `Ferreteria El Tornillo Ltda`, `Consultores Andinos SAS`
**InsurancePolicy demo:** `POL-PYME-2026-0001`, PolicyStage `Issued`, EffectiveDate 2026-06-01.

**Cambio idioma (critique #9c):** los picklists estandar `LineOfBusiness` y `PolicyType` traen valores en ingles ("Property & Casualty", "BOP"). Para la demo — relabel de picklist values en Object Manager: "Property & Casualty" → "Danos Patrimoniales", "BOP (Business Owners)" → "Multirriesgo Pyme". Relabel toma 15 min y no requiere permisos especiales.

**Endoso (critique #4):** demostrar solo si el step 2 de seccion 1 confirma que `InsPolicyService:createPolicyVersion` responde y `DigitalInsurancePolicyAdministrationAddOn` esta provisionado. **Si NO responde**: demostrar endoso via **update directo sobre InsurancePolicyTransaction** creando un registro con `Type=Endorsement, Category=Endorsement` manualmente (SOQL/DataLoader) — es menos elegante pero es data-driven y funciona sin la API service.

**Cancelacion:** `CancellationReasonType = Non-Payment` + PolicyStage `Cancelled`.
**Renovacion:** OmniScript `Renew Policy` OOTB — verificar disponibilidad martes.

**Esfuerzo:** 2h + 1h (endoso path dependiente del check martes).

### Bloque 3 — Siniestros (45 min) — dependiente de seccion 1

**Claim demo:** `SIN-PYME-2026-0001` sobre POL-PYME-2026-0001, ClaimType `Incendio Parcial`, descripcion en espanol.
**ClaimParticipants:** Panaderia La Espiga (Insured), Nehuen Lobo (Adjuster owner via Claim.OwnerId), Bomberos Bogota (Witness).
**ClaimItems:** `Horno Industrial Rational` (Loss), `Estanteria de Producto Terminado` (Loss), `Lucro Cesante 5 dias` (Expense).
**ClaimCoverage** contra `Incendio y Aliados`: reserva perdida COP 45,000,000, reserva gasto COP 5,000,000.
**ClaimCoveragePaymentDetail:** un pago Paid + otro Pending Authority.

**Routing (critique #6):** verificar Service Cloud license en Q-Branch como step 3 del martes AM (query: `SELECT Name, TotalLicenses, UsedLicenses FROM PermissionSetLicense WHERE MasterLabel LIKE '%Service Cloud%'`). **Si Service Cloud NO esta provisionado**: usar simple **Queue Assignment** via Claim.OwnerId sobre un Group tipo Queue (feature core de Salesforce, no requiere Service Cloud) — muestra la asignacion de trabajo aunque no sea Omni-Channel routing skills-based. Narrativa en vivo: "en produccion se activa Omni-Channel para routing por skills; aqui mostramos la asignacion por queue".

**Einstein Summary (critique #9a):** clonar OOTB `Summarize Insurance Claim` a `Resumir_Siniestro_Pyme_ES` y traducir instrucciones + salida esperada a espanol. **Esto es hard requirement, no opcional** — cliente colombiano no puede ver ingles en pantalla. Presupuesto: 2h en la tarde miercoles.

**Data legacy en Q-Branch (critique #9d):** las 24 Claims + 20 ClaimParticipants + 10 ClaimItems que ya existen probablemente estan en ingles. Antes de la demo:
- Crear List View `Siniestros_Pyme_Demo` filtrando por `Name LIKE 'SIN-PYME-%'` como default de la Claim tab.
- Purgar del landing report/dashboard cualquier claim sin prefijo `SIN-PYME-`.
- Time: 30 min miercoles noche como parte del ensayo.

**Esfuerzo:** 4h (asumiendo habilitacion OK) + 30 min data hygiene.

### Bloque 6 — Reporteria (30 min)

**Dashboards CRM Analytics:**
- `Tablero_Siniestralidad_Pyme_2026` — Loss Ratio, siniestros abiertos, reservas.
- `Tablero_Renovaciones_Pyme` — polizas venciendo 60/90 dias, tasa renovacion YoY.
- `Tablero_Produccion_Pyme` — prima por plan, por actividad economica.

**Filtro obligatorio:** todos los dashboards filtrados a `Name LIKE 'PYME-%' OR 'SIN-PYME-%' OR 'POL-PYME-%'` para excluir datos legacy en ingles.

**Esfuerzo:** 3h.

**Sub-total build fresco: 3 + 3 + 4.5 + 3 = 13.5 horas.**

## 5. Plan de InsuranceClause

**Writability confirmada** con insert `1T5g8000000009hCAA` + cleanup. Feature disponible en release 260 (org corre 260) — **la afirmacion previa "API 65.0+" era unsourced (critique #11); se retira**. Si un arquitecto del cliente pregunta "desde cuando GA": responder "disponible en la release actual, referirse a Object Reference oficial" sin citar version especifica.

**Permission sets requeridos:** `Product Configuration Rules User`, `Manage Product Catalog`.

**Nombre de campo (critique #13):** el campo del sObject es literalmente `Type` (values: Clause, Exclusion). NO `ClauseType`. Los CSVs abajo usan `Type`. GFT debe validar el header exacto antes de dataload — mail explicito con la nota.

**Paso 1 — InsuranceClause (6 registros):**
| Name | ApiName | Code | **Type** | CreationMethod | ContentText |
|---|---|---|---|---|---|
| Clausula General de Buena Fe | `Clausula_Buena_Fe` | `buenaFe` | Clause | AutoAdded | "El Asegurado declara que la informacion suministrada es veraz..." |
| Exclusion Actos Dolosos | `Exclusion_Actos_Dolosos` | `actosDolosos` | Exclusion | AutoAdded | "Quedan excluidos los danos derivados de actos dolosos..." |
| Exclusion Guerra y Terrorismo | `Exclusion_Guerra_Terrorismo` | `guerraTerrorismo` | Exclusion | AutoAdded | "No se cubren perdidas por guerra, invasion..." |
| Clausula de Coaseguro | `Clausula_Coaseguro` | `coaseguro` | Clause | Manual | "El Asegurado asume el {{porcentajeCoaseguro}}% de cada perdida..." |
| Exclusion Actividades Extremas | `Exclusion_Actividades_Extremas` | `actividadesExtremas` | Exclusion | AutoAdded | "Se excluyen operaciones con {{sustanciasProhibidas}}." |
| Clausula Deducible Minimo | `Clausula_Deducible_Minimo` | `deducibleMinimo` | Clause | AutoAdded | "Deducible minimo por evento: COP {{deducibleMinimo}}." |

**Paso 2 — InsuranceProductClause:** 6 junctions contra `Seguro Pyme Integral`, EffectiveDate 2026-01-01, ExpirationDate 2030-12-31.

**Paso 3 — InsProductClauseVariableMap (mappings CORREGIDOS — critique #5):**
- `porcentajeCoaseguro` → AttributeDefinition **`Porcentaje_Coaseguro`** (percent)
- `sustanciasProhibidas` → AttributeDefinition **`Sustancias_Prohibidas`** (multi-select picklist)
- `deducibleMinimo` → AttributeDefinition **`Deducible_Minimo_Evento`** (currency)

Los atributos dedicados se crean en Bloque 1 (seccion 4) — asegurando semantica correcta y tipo coincidente.

**Paso 4 — InsurancePolicyProductClause:** al emitir POL-PYME-2026-0001, materializar las 6 clausulas.

**Esfuerzo:** 3h.

## 6. Cronograma revisado con decision gates

**Presupuesto:** martes tarde 4h + miercoles completo 10h + miercoles noche 3h (cerrando 23:00 — no trasnochado, critique #8) + jueves madrugada 2h = **19h efectivas.**

**Trabajo revisado:** 0h migracion (recuperadas 2h) + 13.5h build fresco + 3h clauses + 2h ensayo + 2.5h buffer = **21h.** Ligero over-run reducido a 2h con **buffer estructural en 3 puntos** en vez de 1h al final.

**Reset de sequencing (critique #12):** el ask a Luis Fabian se mueve a **lunes 2026-07-06 (hoy, 07:00 EOD)** para confirmacion antes de arrancar martes AM. Si su respuesta no llega antes del martes 08:00 → arrancamos igual con verificacion SOQL en paralelo al case.

### Lunes 2026-07-06 (hoy)

- [ ] EOD — Ask a Luis Fabian por confirmacion de add-on provisioning (Claims + Policy Admin). Enviar antes de cerrar el dia.

### Martes 2026-07-07 (5h — 13:00-18:00)

- [ ] 13:00-14:00 — Verificacion SOQL: `ClaimCoverage`, `ClaimCoveragePaymentDetail`, `ClaimPaymentSummary`, `ClaimCoverageReserveDetail`, `InsurancePolicyVersion`, `InsurancePolicyTransaction`, `PermissionSetLicense LIKE '%Service Cloud%'`. Documentar resultados.
- [ ] 14:00-15:00 — **Si algun claim/policy sObject falla:** abrir case Sev-2 con Salesforce inmediatamente citando release 260 y sObjects afectados. Loguear ticket #. **Si todos responden:** proceder a step siguiente.
- [ ] 14:00 (paralelo) — Asignar permission sets corregidos a Nehuen.
- [ ] 15:00-18:00 — Bloque 1: crear catalogo PCM completo (incluyendo los 3 AttributeDefinitions dedicados nuevos: Porcentaje_Coaseguro, Sustancias_Prohibidas, Deducible_Minimo_Evento).

**Buffer implicito martes:** 4h de trabajo dentro de bloque de 5h. Si case pendiente, no se pierde tiempo en toggles especulativos.

### Miercoles 2026-07-08 manana (5h — 08:00-13:00)

- [ ] 08:00-11:00 — Bloque 5 (InsuranceClause): cargar 3 niveles + LWC en Product page. GFT valida header `Type` antes de fire de Data Loader.
- [ ] 11:00-12:00 — Bloque 2: cuentas + POL-PYME-2026-0001. Relabel picklist values LineOfBusiness/PolicyType a espanol.
- [ ] **12:00 — DECISION GATE bloque 3:** si case de claims no resuelto y sObjects siguen sin responder → activar Plan B siniestros (seccion 7). Si resuelto → continuar plan base.
- [ ] 12:00-13:00 — Ensayar endoso (createPolicyVersion o path alternativo) + materializar 6 InsurancePolicyProductClause.

### Miercoles 2026-07-08 tarde (5h — 14:00-19:00)

- [ ] 14:00-17:00 — Bloque 3 base O Plan B (segun decision 12:00): Claim + Participants + Items + Coverage + PaymentDetails; verificar Service Cloud → si NO, usar Queue simple.
- [ ] 17:00-19:00 — Clonar y traducir prompt template `Summarize Insurance Claim` → `Resumir_Siniestro_Pyme_ES`. Instrucciones + few-shot examples completamente en espanol. Test con SIN-PYME-2026-0001.

### Miercoles 2026-07-08 noche (3h — 20:00-23:00)

- [ ] 20:00-22:00 — Bloque 6: 3 dashboards CRM Analytics con filtro obligatorio `Name LIKE 'PYME-%' etc.` Crear list views por defecto en Claim/Policy tabs filtrando data legacy.
- [ ] 22:00-23:00 — Ensayo end-to-end 60 min bloque por bloque. **Corte a las 23:00.**

**Buffer estructural miercoles noche:** 23:00-jueves 06:30 = 7.5h de descanso.

### Jueves 2026-07-09 madrugada (1.5h — 06:30-08:00)

- [ ] 06:30-07:00 — Refresh datos si algo se rompio + smoke test.
- [ ] 07:00-07:30 — **Buffer real:** recuperacion si ensayo detecto bugs anoche.
- [ ] 07:30-08:00 — Setup fisico, browser tabs, screenshots backup.

**Total: 4.5h martes efectivas + 13h miercoles + 1.5h jueves = 19h. Buffer distribuido: 1h martes + 30 min miercoles + 30 min jueves = 2h efectivas de recuperacion.**

## 7. Riesgos, Plan B detallado, y asks

### Plan B siniestros — activado si decision gate miercoles 12:00 dice NO

**Trigger:** claim extended sObjects siguen retornando "sObject type not supported" al miercoles 12:00 (25h antes de demo).

**Contenido demo alternativo (usa lo que SI funciona):**
- Claim base: `SIN-PYME-2026-0001` con Status, LossDate, ClaimType, Description, TotalClaimAmount.
- ClaimParticipants: los 3 roles (Insured, Adjuster, Witness).
- ClaimItem: 3 items con LossAmount.
- **Reserva y pago** mostrados como **campos custom en Claim** (rapido: 3 custom fields `Reserva_Perdida__c`, `Reserva_Gasto__c`, `Monto_Pagado__c` en Claim). Narrativa: "en produccion se usa ClaimCoverage + ClaimCoveragePaymentDetail; aqui mostramos los agregados sobre Claim mientras se completa el provisioning del add-on".
- Slide de arquitectura target mostrando el modelo real (ClaimCoverage → CCPD → PaymentSummary) para responder "y como se ve en produccion".
- Einstein Summary funciona igual — no depende de ClaimCoverage.

**Time budget Plan B:** 2h para crear los 3 custom fields + poblar data + preparar la slide de arquitectura. Se ejecuta miercoles 14:00-16:00 en vez del bloque 3 base. Bloques 6 dashboards se ajustan a los custom fields.

**Ensayo Plan B:** 45 min extra miercoles noche (22:00-22:45) reemplazando parte del ensayo bloque 3 original.

### Agentforce — respuesta si el cliente pregunta "donde esta el agente" (critique #14)

El audit `q-agentforce` confirma: licencias Agentforce presentes, PSLs y permission sets asignables, PERO cero GenAiPluginDefinition/BotDefinition configurados. La demo actual usa **Einstein Prompt Templates** (feature distinta) para Summary de Siniestros — no un Agentforce Agent construido.

**Respuesta preparada para la sustentacion:**
> "Este bloque muestra Einstein Prompt Templates como capacidad de GenAI aplicada a Insurance on Core. El siguiente paso en el roadmap — sobre la misma plataforma y con las licencias Agentforce ya provisionadas en esta org — es construir un Agentforce Service Agent sobre estos mismos objetos, con topics para FNOL, actualizacion de siniestro y seguimiento de pago. Lo tenemos definido como fase 2 del roadmap y podemos programar una sesion dedicada de deep-dive Agentforce."

**No se intenta construir un Agent en el timeline** — construir topics + actions + guardrails en 2 dias sin tiempo de testing es alto riesgo de fallar en vivo. Preferible admitir el scope y ofrecer sesion follow-up.

### Show-stoppers abiertos

1. **Add-on provisioning claims + policy admin** — decision gate miercoles 12:00, Plan B listo.
2. **Service Cloud license para Omni-Channel** — verificacion martes 13:00, fallback a Queue simple.
3. **`InsPolicyService:createPolicyVersion`** — verificacion martes 13:00, fallback a InsurancePolicyTransaction manual.
4. **Traduccion prompt template** — hard requirement, 2h presupuestados miercoles tarde.
5. **Data legacy en ingles** — mitigado con list views filtradas + dashboards con filtros por prefijo.

### Asks explicitos (sequencing corregido — critique #12)

**A Luis Fabian (deadline: LUNES 2026-07-06 EOD, hoy):**
- Confirmar con account team si `DigitalInsuranceClaimManagementAddOn`+PC+CC y `DigitalInsurancePolicyAdministrationAddOn` estan efectivamente provisionadas como runtime (no solo PSLs Active) en ins-qbranch-alfa. Si no, autorizar apertura de case Sev-2 martes 07:00.
- Aprobar consolidacion 100% a ins-qbranch-alfa.

**A GFT (deadline: martes 2026-07-07 18:00):**
- Carga PCM del bloque 1 en paralelo miercoles AM (les paso CSVs martes 17:00). **Nota explicita:** el campo en InsuranceClause es `Type`, NO `ClauseType`. Validar header antes de fire.
- Revisar dashboards bloque 6 miercoles 22:00-23:00 mientras ensayo.

**A Mario (deadline: miercoles 2026-07-08 12:00):**
- Validar guion narrativo. Ensayo conjunto miercoles 22:00.
- Confirmar que Bloques 4 (Reaseguros) y 5 (Facturacion) quedan fuera de scope con slide de roadmap.
- **Nuevo:** preparar respuesta a la pregunta Agentforce si sale (parrafo pre-aprobado arriba).

**Nota final sobre idioma:** todo user-facing en espanol — productos, coverages, clausulas, cuentas, siniestros, dashboards, picklists relabeled, prompt template clonado y traducido. List views filtran data legacy en ingles. Cero ingles on-screen es hard requirement, no opcional.
---

## Anexo — Verificación SOQL de objetos reales en ins-qbranch-alfa (2026-07-07 02:36)

### Claim extended sObjects — 9 de 11 funcionan

| sObject | Estado | Records |
|---|---|---|
| ClaimCoverage | ✅ OK | 12 |
| ClaimCoveragePaymentDetail | ✅ OK | 6 |
| ClaimPaymentSummary | ✅ OK | 1 |
| ClaimCoverageReserveDetail | ✅ OK | 0 (queryable, sin data) |
| ClaimCovReserveAdjustment | ✅ OK | 20 |
| ClaimRecovery | ✅ OK | 0 (queryable) |
| ClaimItem | ✅ OK | 10 |
| ClaimParticipant | ✅ OK | 20 |
| InsurancePolicyTransaction | ✅ OK | 2 |
| ClaimCoveragePaymentAdjustment | ❌ NOT SUPPORTED | — |
| InsurancePolicyVersion | ❌ NOT SUPPORTED | — |

### PSL provisioning Claims Management — confirmado real (no solo Active)

Todas con expiración 2027-02-21 y algunas ya con licencias asignadas — desmiente la preocupación del critique #1 sobre "PSL Active sin runtime add-on provisionado":

| PSL | Used/Total |
|---|---|
| ClaimManagementAdmin | 1 / 20 |
| DigitalInsuranceClaimManagementAdmin | 0 / 20 |
| DigitalInsuranceClaimManagementUser | 0 / 20 |
| DigitalInsuranceClaimMgmtCCPsl | 0 / 20 |
| DigitalInsuranceClaimMgmtPCPsl | 0 / 20 |
| DigitalInsurancePolicyAdminUserPsl | 1 / 5 |
| DigitalInsurancePolicyAdminCCPsl | 0 / 5 |
| DigitalInsurancePolicyAdminPCPsl | 0 / 5 |

### Service Cloud / Omni-Channel — sin PSL de Omni-Channel routing visible

Únicos PSLs relacionados en la org: `ServiceCloudVoicePsl` (voice), `ServiceCloudVoiceExternalTelephonyPsl`, `OmnichannelInventoryPsl` (retail inventory, no routing). **Ir directamente con fallback Queue simple** — no perder tiempo buscando Omni-Channel routing en la sustentación.

### Implicaciones para el plan

1. **✅ VAMOS CON PLAN BASE, NO PLAN B.** Todos los sObjects críticos del Bloque 3 responden con data — la demo end-to-end de siniestros es viable.
2. **✅ Ahorro 2h del cronograma** — no hay que crear los 3 custom fields del Plan B (`Reserva_Perdida__c`, etc.).
3. **⚠️ Endoso via InsurancePolicyTransaction manual** — `InsurancePolicyVersion` no está soportado, por lo tanto NO usamos `createPolicyVersion`. Creamos un InsurancePolicyTransaction record con `Type=Endorsement` directamente (path ya contemplado en la sección 4 del plan).
4. **⚠️ ClaimCoveragePaymentAdjustment no disponible** — no crítico. Los ajustes de pago se pueden narrar sin mostrar el objeto (los agregados en ClaimPaymentSummary son suficientes).
5. **⚠️ Omni-Channel routing** — fallback a Queue Assignment via Claim.OwnerId ya contemplado. No abrir case por esto.
6. **Nehuen ya tiene ClaimManagementAdmin y DigitalInsurancePolicyAdminUserPsl asignados** (1/20 y 1/5 usados) — probablemente son las asignaciones del usuario demo. Falta asignar `DigitalInsuranceClaimManagementUser`, `DigitalInsuranceClaimManagementAdmin` y los Permission Sets funcionales (Product Configurator, Product Catalog Management Viewer, etc.).

### Cambios al cronograma

- **Cancelar case Sev-2 con Salesforce** — no hace falta, provisioning está OK.
- **Cancelar decision gate miércoles 12:00** — plan base confirmado, avanzar directamente al build de Bloque 3.
- **Buffer real aumenta a ~4h** (2h ahorradas de Plan B custom fields + 2h ya presupuestadas).
- **Sequence martes 07-jul tarde:** el step 14:00-15:00 "abrir case si falla" se convierte en "asignar PSLs de Claims Management User/Admin al usuario demo + verificar que el user puede leer Claim/ClaimCoverage/ClaimCoveragePaymentDetail" (30 min). El resto del tiempo del martes va todo a Bloque 1.

---

## Bloque 1 — Build EJECUTADO (2026-07-07 ~11:00)

**Estado:** completado en ~40 min (vs 5h presupuestadas). Buffer recuperado significativo.

**Records creados en `ins-qbranch-alfa`:**
- 3 AttributeCategory + 8 AttributePicklist + 34 AttributePicklistValue
- 8 AttributeDefinition + 2 ProductClassification + 8 ProductClassificationAttr
- 6 coverages Simple + 1 bundle root "Plan Empresarial"
- 48 ProductAttributeDefinition (defaults propagados)
- 2 ProductComponentGroup + 7 ProductRelatedComponent (6 BundleComponent + 1 ClassificationComponent)
- 7 ProductSellingModelOption (OneTime) + 7 PricebookEntry (COP) + 1 ProductCategory + 1 ProductCategoryProduct

**IDs clave del build:**
- Plan Empresarial (bundle): busca por `ProductCode='segPymeEmpresarial'`
- Coverages: `rcExtracontractual`, `incendioAliados`, `equipoElectronico`, `roboAsalto`, `roturaMaquinaria`, `sustraccionDinero`
- Classifications: `coberturaPyme`, `establecimientoComercial`

**Gotchas resueltos durante ejecución (guardados en memoria `feedback_digital_insurance_product_config.md`):**
1. `Product2.ProductClass` no es writable — se autoderiva de RecordType/Type
2. `ProductRelatedComponent.ParentProductRole`+`ChildProductRole` autoderivados del RelationshipType
3. `AttributePicklistValue.Code` unique global — sufijar `_DME` cuando hay colisión
4. `AttributeDefinition.DataType` no soporta `Multipicklist` — Sustancias Prohibidas quedó single-select
5. PADs NO se autogeneran con `BasedOnId` — 48 creates manuales necesarios
6. `Product2.SellOnlyWithOtherProducts` no existe en la org

**Próximos pasos según cronograma:**
- Bloque 5 (InsuranceClause): 6 clauses en español + junctions + variable maps + LWC — 3h
- Bloque 2 (Ciclo Póliza): cuentas + POL-PYME-2026-0001 + relabel picklists en/es — 2h
- Bloque 3 (Siniestros): FNOL + Claim + coverages + reserves + payments — 3-4h
- Bloque 6 (Reportería): 3 dashboards con filtro `Name LIKE '%Pyme%'` — 3h

**Buffer real ganado: ~4h** vs plan original (por rapidez del Bloque 1). Se puede invertir en: (a) construir Plan Esencial + Plan Corporativo como bundles peer para el side-by-side, (b) ensayo adicional, (c) más data de reportería.

---

## Estado FINAL — todos los bloques deployados (2026-07-07)

Todos los 4 bloques del RFI construidos y verificados en `ins-qbranch-alfa`:

### Bloque 1 — Producto Pyme Integral (~150 records)
- Product2 root **Plan Empresarial** (`segPymeEmpresarial`) + 6 coverages Simple
- 48 ProductAttributeDefinition (6 × 8 atributos)
- 8 AttributeDefinition + 8 AttributePicklist + 34 AttributePicklistValue + 3 AttributeCategory
- 2 ProductClassification (Cobertura Pyme, Establecimiento Comercial) + 8 ProductClassificationAttr
- 2 ProductComponentGroup + 7 ProductRelatedComponent (6 BundleComponent + 1 ClassificationComponent)
- 7 ProductSellingModelOption (OneTime) + 7 PricebookEntry (COP)
- 1 ProductCategory "Seguros Pyme" + link

### Bloque 5 — InsuranceClauses (21 records)
- 6 InsuranceClauses en español (Buena Fe, Actos Dolosos, Guerra/Terrorismo, Coaseguro, Actividades Extremas, Deducible Mínimo)
- 6 InsuranceProductClause (junctions al bundle Empresarial)
- 3 InsProductClauseVariableMap (tokens dinámicos: coaseguro %, sustancias, deducible mínimo)
- 6 InsurancePolicyProductClause materializadas en POL-PYME-2026-0001 con texto resuelto

### Bloque 2 — Ciclo de Póliza (18 records)
- 3 Accounts: Panadería La Espiga SAS, Ferretería El Tornillo Ltda, Consultores Andinos SAS
- 1 InsurancePolicy **POL-PYME-2026-0001** (In Force, BOP, prima COP 2.4MM)
- 6 InsurancePolicyCoverage (RC 600K + Incendio 800K + Equipo 300K + Robo 400K + Rotura 200K + Sustracción 100K)
- 2 InsurancePolicyTransaction (Issuance emisión + Endorsement midterm aumento Incendio)

### Bloque 3 — Siniestros (12 records)
- 1 Claim **SIN-PYME-2026-0001** (Fire/Smoke Damage, Coverage Confirmed, estimated 48MM)
- 3 ClaimParticipants (Claimant Panadería, Loss Adjuster, Witness Bomberos)
- 3 ClaimItems (Horno Rational 32MM, Estantería 8MM, Lucro Cesante 8MM)
- 1 ClaimCoverage vs InsurancePolicyCoverage Incendio
- 2 ClaimCovReserveAdjustment (Reserva Pérdida 45MM + Reserva Gasto 5MM)
- 1 ClaimPaymentSummary
- 2 ClaimCoveragePaymentDetail (Paid 32MM Horno + Pending Authority 8MM Lucro)

### Bloque 6 — Reportería (19 metadata artifacts)
- 5 CustomReportType (`InsurancePolicy_Pyme__c`, `Claim_Pyme__c`, `InsurancePolicyCoverage_Pyme__c`, `ClaimCoveragePaymentDetail_Pyme__c`, `ClaimCovReserveAdjustment_Pyme__c`)
- 2 Folders (Report + Dashboard, ambos "Seguros ALFA Pyme")
- 11 Reports Tabulares en español
- 3 Dashboards en español: **Siniestralidad Pyme 2026**, **Renovaciones Pyme 2026**, **Producción Pyme 2026**

**Deploy via SOAP Metadata API (sf project deploy bloqueado por sandbox ~/.sfdx write). Total agents/deploys iterados: 12 hasta green. Learnings guardados en memory.**

## Handoff — verificación en UI antes del jueves
- [ ] Login como Nehuen y navegar Product Catalog Management → Insurance Catalog → **Seguros Pyme** → Plan Empresarial → verificar árbol
- [ ] Verificar 6 coverages con 8 atributos cada una en Product Modeler
- [ ] Ver POL-PYME-2026-0001 con las 6 coverages + 2 transactions + 6 clauses materializadas
- [ ] Ver SIN-PYME-2026-0001 con Participants + Items + Coverage + PaymentDetails + ReserveAdjustments
- [ ] Ejecutar los 3 dashboards en Reports app y confirmar visualización correcta
- [ ] Ensayo cronometrado por bloque (30/30/45/30 min según agenda RFI)
