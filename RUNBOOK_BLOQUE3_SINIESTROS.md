# Runbook — Bloque 3: Siniestros

**Duración**: 45 min | **Ejecutor**: Luis Fabián | **Org**: ins-qbranch-alfa
**Fecha demo**: 2026-07-09 | **Cliente**: Seguros ALFA (Bogotá, Colombia)
**Instancia**: https://storm-c90aab66569c63.my.salesforce.com

> **Nota para Luis**: este runbook asume que NO conoces a fondo Digital Insurance. Cada paso te dice qué clicar y qué deberías ver. El talk track entre comillas es literal — puedes leerlo. La org está en `en_US`, así que muchos labels aparecen en inglés; contextualiza verbalmente en español (ej. "Coverage Confirmed" = "Cobertura Confirmada").

---

## 0. Setup pre-demo (5 min antes de arrancar Bloque 3)

Mientras el presentador de Bloque 2 está cerrando, prepara estas pestañas del navegador (Chrome, ventana en modo presentación, zoom 100%):

**Tab 1 — Claim principal (esta es la pestaña "hogar"):**
```
https://storm-c90aab66569c63.my.salesforce.com/lightning/r/Claim/0Zkg80000000awLCAQ/view
```

**Tab 2 — ClaimCoverage Incendio (para Fase 5):**
```
https://storm-c90aab66569c63.my.salesforce.com/lightning/r/ClaimCoverage/0kPg80000000OITEA2/view
```

**Tab 3 — CCPD-01 Horno Pagado (para Fase 4):**
```
https://storm-c90aab66569c63.my.salesforce.com/lightning/r/ClaimCoveragePaymentDetail/0l2g80000000PfxAAE/view
```

**Tab 4 — CCPD-02 Lucro Cesante Pendiente Autoridad (para Fase 4):**
```
https://storm-c90aab66569c63.my.salesforce.com/lightning/r/ClaimCoveragePaymentDetail/0l2g80000000PhZAAU/view
```

**Tab 5 — Póliza de Bloque 2 (para el link cruzado en Fase 5):**
```
https://storm-c90aab66569c63.my.salesforce.com/lightning/o/InsurancePolicy/list
```
Filtra por `POL-PYME-2026-0001` y ábrela — la usarás para mostrar el vínculo póliza→siniestro.

**Checklist rápido antes de hablar:**
- [ ] Estás logueado como **Nehuen Lihue Lobo** (o quien sea el owner del claim; si no, cambia el filtro "My Claims" a "All Claims").
- [ ] Tab 1 muestra el header del Claim con `SIN-PYME-2026-0001` y Status = **Coverage Confirmed**.
- [ ] Tab 2 muestra la ClaimCoverage `CC-SIN-PYME-2026-0001-Incendio` con Loss Reserve = **45,000,000** y Expense Reserve = **5,000,000**.
- [ ] En el App Launcher está cargada la app **Insurance Agent Console** (la misma que Bloque 2 ya dejó abierta).
- [ ] Notificaciones/Slack/correo silenciados. Modo "no molestar" activado.

Si algo no carga: refresca (Cmd+R). Si sigue mal, ve directo a la sección **5. Fallbacks generales** al final del runbook.

---

## 1. Contexto y objetivo del bloque (1 min)

**Talk track literal:**

> "Perfecto, gracias [nombre del presentador anterior]. Con la póliza `POL-PYME-2026-0001` ya emitida en Bloque 2, ahora vamos a lo que realmente vive el asegurado cuando pasa algo malo: el **siniestro**.
>
> En los próximos 45 minutos les voy a mostrar el ciclo end-to-end de un siniestro real sobre Insurance on Core — la misma plataforma que ya vieron. Sin cambiar de sistema, sin duplicar datos, sin integraciones intermedias. El siniestro está vinculado directamente a la póliza que acabamos de emitir.
>
> El caso: **Panadería La Espiga SAS**, cliente PYME en Bogotá, reporta un incendio el 10 de septiembre de 2026. Daño estimado inicial: 48 millones de pesos. Vamos a recorrer:
>
> 1. Cómo se abrió el siniestro y su estado actual.
> 2. Los participantes involucrados — asegurado, ajustador y testigo.
> 3. Los bienes afectados que reclamó el cliente.
> 4. La parte financiera: reservas, pagos ejecutados y pagos en autorización.
> 5. El vínculo directo con la cobertura de la póliza.
> 6. Cómo se cierra el ciclo y qué automatización adicional se puede sumar con Agentforce.
>
> Cada dato que vean está funcionando en el modelo estándar del producto — no hay objetos custom para esta demo."

**Puntos de énfasis:**
- "End-to-end sobre Insurance on Core" (repítelo, es el mensaje central del RFP).
- "Sin objetos custom" — la cliente ya preguntó esto varias veces en las sesiones previas.
- No prometas Agentforce funcionando en vivo en este bloque; solo se menciona al cierre.

---

## 2. Click path paso a paso

### Fase 1 — Contexto del siniestro (5-7 min)

**Objetivo**: que el cliente entienda qué siniestro estamos viendo, en qué estado está, y quién lo gestiona.

**Paso 1.1** — Ir a Tab 1 (Claim principal).

**Verás:**
- Header con nombre `SIN-PYME-2026-0001`.
- Highlights panel con campos clave (Claim Type, Status, Severity, etc.).
- Debajo, las tabs: **Related**, **Details**, **Financials**, **Participants**, **Claim Team**, **Action Plan**.

**Talk track:**
> "Este es el siniestro `SIN-PYME-2026-0001`. Fíjense en el highlights panel — todos los datos que necesita el ajustador para arrancar la gestión están en la primera pantalla, sin scroll."

**Paso 1.2** — Click en tab **Details**.

**Verás campos:**
- **Claim Type**: `Fire/Smoke Damage`
- **Status**: `Coverage Confirmed`
- **Severity**: `High`
- **Loss Type**: `Partial Loss`
- **Estimated Amount**: `$48,000,000`
- **Loss Date**: `9/10/2026`
- **Owner**: `Nehuen Lihue Lobo`

**Talk track:**
> "Los campos que ven — `Claim Type`, `Status`, `Severity`, `Loss Type`, `Estimated Amount` — son todos del modelo estándar de Insurance on Core. En español serían: Tipo de Siniestro `Incendio/Daño por humo`, Estado `Cobertura Confirmada`, Severidad `Alta`, Tipo de Pérdida `Pérdida Parcial`, Monto Estimado `48 millones de pesos` y Fecha del Siniestro `10 de septiembre`.
>
> El estado `Coverage Confirmed` significa que ya pasamos la etapa inicial de FNOL — First Notice of Loss, aviso de siniestro — y validamos que la póliza cubre el evento. Estamos en la fase de ajuste."

**Puntos de énfasis:**
- El label en inglés lo lees, pero tradúcelo verbalmente al lado.
- "FNOL" — abrevia, ya lo dijiste una vez, después usa "aviso" en español.

**Fallback si Details no muestra todo:**
- Refresca la página (Cmd+R).
- Si aún falta, ve a la URL directa del Details layout — o bien navega vía **Setup → Object Manager → Claim → Page Layouts** para confirmar layout asignado (solo si es indispensable; evítalo en frente del cliente).

**Paso 1.3** — Explicar brevemente cómo llegó aquí el siniestro.

**Talk track:**
> "El asegurado puede reportar el siniestro por varios canales — el mismo modelo soporta FNOL desde:
> - Un portal de Experience Cloud si Seguros ALFA le da a sus clientes un self-service.
> - Un call center — el agente crea el Claim desde la Insurance Agent Console, la misma que estoy usando.
> - Integración vía API si tienen un canal digital externo, por ejemplo la app móvil de Aval.
> - Y, muy relevante para el RFP, desde un asistente conversacional Agentforce que hace intake por chat o WhatsApp. Al cierre les muestro esa parte."

**No hagas click en nada de esto** — es narrativa. No tenemos FNOL Agentforce configurado en la org.

---

### Fase 2 — Participants (7-10 min)

**Objetivo**: mostrar el modelo multi-rol y cómo el mismo Claim gestiona asegurado, ajustador, testigo — sin extensiones custom.

**Paso 2.1** — Desde el Claim, click en tab **Participants**.

**Verás**: una lista con 3 registros:
- `Claimant` — Panadería La Espiga SAS
- `Loss Adjuster` — Alan Reed
- `Witness` — Cuerpo de Bomberos de Bogotá

**Talk track:**
> "Aquí está algo clave del modelo estándar: cualquier persona o empresa que participa en el siniestro se registra como `ClaimParticipant` con un rol. No creamos objetos separados para asegurado, ajustador o testigo. Un mismo participante puede tener múltiples roles si es necesario, sin duplicar el registro."

**Paso 2.2** — Click en el primer participant, `Claimant`.

**Verás:**
- **Roles**: `Claimant`
- **Participant Account**: `Panadería La Espiga SAS` (link a la Account)

**Talk track:**
> "El Claimant es la Cuenta asegurada de Bloque 2 — la misma Panadería que emitimos la póliza. No hay que replicar datos: el CRM ya tiene la 360 del cliente, y el siniestro se conecta por referencia."

**Paso 2.3** — Click en el link **Panadería La Espiga SAS** para saltar a la Account. Muestra 3 segundos que existe la Account con sus datos comerciales. Luego click en el botón "Back" del navegador para volver al ClaimParticipant.

**Talk track (mientras vuelves):**
> "Fíjense: el equipo comercial ve al mismo cliente en la Account, y el equipo de siniestros lo ve como Claimant. Es la misma fuente de verdad."

**Paso 2.4** — Click en "Back" del navegador (o Tab 1 para volver al Claim) → tab **Participants** → click en `Loss Adjuster`.

**Verás:**
- **Roles**: `Loss Adjuster`
- **Participant Contact**: `Alan Reed`

**Talk track:**
> "El ajustador `Alan Reed` está registrado como Contact — puede ser interno de Seguros ALFA o un ajustador externo tercerizado. El modelo lo soporta indistintamente. Si es externo, se le puede dar acceso vía Experience Cloud a un portal de peritos para que suba fotos, actas y peritajes sin necesidad de licenciarlo en el core."

**Paso 2.5** — Volver al Claim (Tab 1) → tab **Participants** → click en `Witness`.

**Verás:**
- **Roles**: `Witness`
- **Participant Account**: `Cuerpo de Bomberos de Bogotá`

**Talk track:**
> "Y el testigo aquí es el Cuerpo de Bomberos, registrado como Account porque es una entidad. Podría ser también un Contact si fuera una persona natural. El modelo estándar acepta ambos — mismo campo `ParticipantAccount` o `ParticipantContact` según corresponda."

**Puntos de énfasis:**
- "Modelo estándar, sin objetos custom" — dilo aquí explícitamente.
- Multi-rol: puedes agregar más roles al mismo Contact (ej. testigo que después es beneficiario).

**Fallback si tab Participants no aparece:**
- Ve directo por URL: `/lightning/r/ClaimParticipant/0aSg8000000LNXtEAO/view` (Claimant), luego `/0aSg8000000LNb7EAG/view` (Adjuster), `/0aSg8000000LNcjEAG/view` (Witness).
- Si el layout está distinto, muestra los mismos IDs y explica que son ClaimParticipants con distintos roles.

---

### Fase 3 — Claim Items (7-10 min)

**Objetivo**: mostrar el detalle de los bienes reclamados y cómo cada item se conecta con una cobertura de la póliza.

**Paso 3.1** — Volver al Claim (Tab 1) → tab **Related** → scroll hasta la sección **Claim Items** (puede llamarse también "Related Claim Items" según layout).

**Verás 3 registros:**
- `Horno Industrial Rational SCC-102`
- `Estanteria Metalica`
- `Lucro Cesante 5 dias`

**Talk track:**
> "El siniestro tiene tres ítems reclamados. Cada uno es un `ClaimItem` — otra vez modelo estándar. Vamos uno por uno."

**Paso 3.2** — Click en `Horno Industrial Rational SCC-102`.

**Verás:**
- **Category**: `Damaged Property`
- **Fault Date**: `9/10/2026`
- **Insurance Policy Coverage**: link a `Incendio y Aliados` (la cobertura de la póliza de Bloque 2)

**Talk track:**
> "Este es el horno industrial que se quemó. La categoría `Damaged Property` — Propiedad Dañada — indica que es un bien físico afectado. Fíjense en el campo `Insurance Policy Coverage`: apunta directamente a la cobertura de Incendio y Aliados de la póliza que ya emitimos en Bloque 2. Esa es la trazabilidad end-to-end que buscan: el ítem del siniestro conoce exactamente qué cobertura de qué póliza lo respalda."

**Paso 3.3** — Volver al Claim (Tab 1) → tab **Related** → sección Claim Items → click en `Estanteria Metalica`.

**Verás:**
- **Category**: `Damaged Property`
- **Fault Date**: `9/10/2026`
- **Insurance Policy Coverage**: link a otra cobertura de la póliza

**Talk track:**
> "La estantería metálica también es propiedad dañada, misma fecha. Este ítem apunta a otra cobertura de la póliza — porque una póliza PYME de multirriesgo tiene múltiples coberturas, y cada ítem afectado se vincula a la que le corresponde."

**Paso 3.4** — Volver al Claim → sección Claim Items → click en `Lucro Cesante 5 dias`.

**Verás:**
- **Category**: `Damaged Property`
- **Fault Date**: `9/10/2026`

**Talk track:**
> "El tercer ítem es `Lucro Cesante 5 días`. La panadería estuvo cerrada 5 días mientras se reparaba el local. En términos de negocio, esto no es propiedad física — es un lucro cesante — pero para el modelo estándar lo registramos como ClaimItem con la cobertura de lucro cesante correspondiente. En una implementación productiva podríamos afinar los picklists de categoría para tener un valor `Business Interruption` explícito. Es configuración, no desarrollo."

**Puntos de énfasis:**
- Cada ClaimItem conoce su `InsurancePolicyCoverage` — es el link que garantiza que solo se pague lo que la póliza cubre.
- El picklist `Category` es configurable — si el cliente pregunta por qué "Damaged Property" en Lucro Cesante, tienes la respuesta.

**Fallback si no ves Claim Items en el tab Related:**
- URL directa a lista filtrada: `/lightning/o/ClaimItem/list` — filtra por `Claim = 0Zkg80000000awLCAQ`.
- URLs directas de cada item:
  - Horno: `/lightning/r/ClaimItem/0dqg80000000UpJAAU/view`
  - Estantería: `/lightning/r/ClaimItem/0dqg80000000UqvAAE/view`
  - Lucro Cesante: `/lightning/r/ClaimItem/0dqg80000000UsXAAU/view`

---

### Fase 4 — Financials: Reservas y Pagos (10-12 min)

**Objetivo**: mostrar la parte que el cliente más va a cuestionar — cómo se manejan reservas técnicas, autorizaciones de pago y el estado financiero del siniestro.

**Paso 4.1** — Volver al Claim (Tab 1) → tab **Financials**.

**Verás secciones:**
- **Claim Coverages** — con `CC-SIN-PYME-2026-0001-Incendio`
- **Payment Summary** — con `PaymentSummary-SIN-PYME-2026-0001`
- (Según layout) reservas y montos agregados

**Talk track:**
> "En Financials vemos el corazón del control técnico y financiero del siniestro. Dos bloques: las **Coverages del siniestro** — que son los espejos financieros de las coberturas de la póliza — y el **Payment Summary**, que agrega los pagos ejecutados."

**Paso 4.2** — Click en la ClaimCoverage `CC-SIN-PYME-2026-0001-Incendio` (o cambia a Tab 2 que ya la tienes abierta).

**Verás campos:**
- **Internal Reserve Mode**: `CoverageReserve`
- **Loss Reserve Amount**: `$45,000,000`
- **Expense Reserve Amount**: `$5,000,000`
- **Total Claimed Amount**: `$40,000,000`
- **Total Adjusted Amount**: `$32,000,000`

**Talk track:**
> "Este es el registro `ClaimCoverage` — la vinculación entre este siniestro y la cobertura de Incendio y Aliados de la póliza. Aquí vive el control técnico:
>
> - **Reserva de pérdida**: 45 millones. Es lo que técnicamente el actuario/ajustador estima que va a costar la indemnización directa por los bienes dañados.
> - **Reserva de gasto**: 5 millones. Costos asociados — peritajes, honorarios, gastos de tramitación, lucro cesante.
> - **Total Reclamado**: 40 millones. Lo que el cliente pidió formalmente en su reclamación.
> - **Total Ajustado**: 32 millones. Lo que el ajustador dictaminó como procedente después del peritaje.
>
> El campo `Internal Reserve Mode = CoverageReserve` es importante: significa que la reserva se controla a nivel de la cobertura, no a nivel de cada ítem. Esto es coherente con la práctica actuarial de Seguros ALFA y con lo que la SFC exige para reportería técnica."

**Puntos de énfasis:**
- Reservas técnicas = tema regulatorio SFC. Cliente lo va a preguntar.
- La diferencia entre `Total Claimed` y `Total Adjusted` es el "gap" del ajuste — muy útil como métrica.

**Paso 4.3** — En la misma ClaimCoverage → tab **Related** → sección **Reserve Adjustments** (puede aparecer como "Claim Coverage Reserve Adjustments").

**Verás 2 registros:**
- `Reserva perdida directa Incendio` — Adjustment Amount `$45,000,000`
- `Reserva gasto lucro cesante` — Adjustment Amount `$5,000,000`

**Talk track:**
> "La reserva de la cobertura no es un número mágico — se compone de ajustes trazables. Aquí ven los dos movimientos que llevaron la reserva a 50 millones totales:
>
> - `Reserva perdida directa Incendio`: 45 millones. La justificación queda en el campo Reason — 'Reserva por pericia inicial: horno + estantería'.
> - `Reserva gasto lucro cesante`: 5 millones. Reason: 'Reserva por lucro cesante 5 días'.
>
> Cada movimiento de reserva queda con quién lo hizo, cuándo, y por qué. Esto es fundamental para auditoría interna y para el reporte a la Superintendencia Financiera. En el ciclo de vida real, si el peritaje afina el número, se hace otro `ClaimCovReserveAdjustment` — no se reescribe el número, se agrega un ajuste. Trazabilidad completa."

**Puntos de énfasis:**
- IBNR / reserva insuficiente / suficiencia técnica — el cliente puede preguntar. Respuesta rápida: se agregan más adjustments para reflejar cambios de estimación.
- El histórico de ajustes es la evidencia audit-ready.

**Paso 4.4** — Volver al Claim (Tab 1) → tab **Financials** → click en `PaymentSummary-SIN-PYME-2026-0001`.

**Verás:**
- **Payment Status**: `Pending Payment`
- **Payment Amount**: (vacío / null)

**Talk track:**
> "El `Claim Payment Summary` es el consolidado de pagos de este siniestro. Estado actual: `Pending Payment` — pagos pendientes de finalización.
>
> Un aclarativo técnico: el `Payment Amount` a nivel de summary se agrega según reglas de configuración; en esta demo lo dejamos abierto para mostrar el detalle real, que es lo interesante — los `Claim Coverage Payment Detail`."

> **Nota para Luis** — el `PaymentAmount` viene null a nivel del summary. Si el cliente lo nota y pregunta, di literal: "En producción se configura un rollup summary o un flow que agregue los CCPD con `PaymentStatus = Paid`. Aquí lo dejamos abierto para que ustedes vean el detalle transaccional, que es donde vive la verdad contable."

**Paso 4.5** — Cambiar a Tab 3 (CCPD-01 Horno Pagado) o navegar desde la ClaimCoverage → Related → **Payment Details**.

**Verás CCPD-01:**
- **Name**: `CCPD-01 Horno Pagado`
- **Type**: `Loss`
- **Status**: `Paid`
- **Payment Status**: `Paid`
- **Claimed Amount**: `$32,000,000`
- **Adjusted Amount**: `$32,000,000`

**Talk track:**
> "Este es un pago ya ejecutado. El horno industrial se ajustó en 32 millones y ya se pagó al asegurado. Tipo `Loss` — indemnización directa. Estado `Paid`. Es transacción cerrada."

**Paso 4.6** — Cambiar a Tab 4 (CCPD-02 Lucro Cesante Pendiente Autoridad).

**Verás CCPD-02:**
- **Name**: `CCPD-02 Lucro Cesante Pendiente Autoridad`
- **Type**: `Expense`
- **Status**: `Pending Authority`
- **Payment Status**: `Draft`
- **Claimed Amount**: `$8,000,000`
- **Adjusted Amount**: (vacío)

**Talk track:**
> "Y este segundo pago está en un estado muy común en siniestros PYME: `Pending Authority`. El asegurado reclamó 8 millones por lucro cesante — 5 días cerrado. El ajustador lo revisó pero el monto excede el nivel de autorización de su rol, entonces queda esperando aprobación de un supervisor.
>
> Fíjense que `Adjusted Amount` está vacío — porque hasta que la autoridad no autorice, el ajustador no fija el monto final. Esto se puede automatizar con un Flow de autorización: cuando el supervisor aprueba, el monto ajustado se completa y el pago pasa a `Approved for Payment`. Es lo que llamamos 'workflow de niveles de autoridad', y en Insurance on Core se hace con Flow o con Approval Process, sin custom code."

**Puntos de énfasis:**
- Un pago ejecutado + un pago en autorización = historia completa del workflow.
- El AdjustedAmount vacío es intencional pedagógicamente — muestra el estado real de un pago no aprobado.
- Menciona "sin custom code" — tema recurrente del cliente.

**Fallback si algún CCPD no se ve:**
- URL directas ya están en las tabs 3 y 4.
- Si el tab Financials no muestra Payment Summary o CCPDs, ve por URL:
  - PaymentSummary: `/lightning/r/ClaimPaymentSummary/0l8g80000001y5NAAQ/view`
  - CCPD-01: `/lightning/r/ClaimCoveragePaymentDetail/0l2g80000000PfxAAE/view`
  - CCPD-02: `/lightning/r/ClaimCoveragePaymentDetail/0l2g80000000PhZAAU/view`

---

### Fase 5 — Vínculo con la Póliza (Claim Coverage → Policy) (5-7 min)

**Objetivo**: cerrar el circuito visual entre siniestro y póliza — el "end-to-end" que el cliente ya escuchó dos veces y ahora tiene que ver.

**Paso 5.1** — Cambiar a Tab 2 (ClaimCoverage `CC-SIN-PYME-2026-0001-Incendio`).

**Verás** (además de las reservas ya mostradas):
- Campo **Insurance Policy Coverage**: link a la cobertura de Incendio y Aliados de la póliza.

**Talk track:**
> "Volvamos a la ClaimCoverage un momento. Fíjense en este campo — `Insurance Policy Coverage`. Es el link que ata este siniestro a la cobertura exacta de la póliza que Bloque 2 emitió."

**Paso 5.2** — Click en el link **Insurance Policy Coverage** (Incendio y Aliados).

**Verás**: la cobertura de la póliza `POL-PYME-2026-0001` con sus datos — Coverage Name, límites, deducibles, etc.

**Talk track:**
> "Estamos ahora en el registro de la cobertura, dentro de la póliza. Desde aquí puedo navegar a la póliza padre y confirmar que es la misma que emitieron en Bloque 2."

**Paso 5.3** — Click en el link **Policy Name** / **Insurance Policy** (el campo padre) para saltar a `POL-PYME-2026-0001`.

**Verás**: la póliza de Bloque 2 con sus datos.

**Talk track:**
> "Y aquí está la póliza. La misma que emitieron. Sin ETLs, sin sincronizaciones nocturnas, sin data lakes intermedios. Un solo modelo, una sola verdad: la póliza conoce sus siniestros y el siniestro conoce su póliza. Cuando ustedes reciban una consulta del asegurado, del regulador o del reasegurador, la respuesta está a un click."

**Paso 5.4** — Bonus opcional (si sobra tiempo, sino saltea): en la Póliza, tab **Related** → sección **Claims** — mostrar que `SIN-PYME-2026-0001` aparece listado.

**Talk track:**
> "Y para cerrar el círculo — desde la póliza veo todos sus siniestros. Hoy uno, mañana los que sean. Con Reports y CRM Analytics saco métricas de siniestralidad por póliza, por producto, por región, en tiempo real."

**Puntos de énfasis:**
- Este es EL momento del "end-to-end". Es más importante que las cifras.
- Repítelo verbalmente: "Un modelo, una fuente de verdad, un solo Salesforce."

**Fallback si el link `Insurance Policy Coverage` no aparece o rompe:**
- Ve directo a Tab 5 (lista de InsurancePolicy) y abre `POL-PYME-2026-0001`. Muestra la póliza y el tab Related → Claims.

---

### Fase 6 — Cierre narrativo + Agentforce (3-5 min)

**Objetivo**: cerrar el bloque, tender el puente a Bloque 6 (Reportería) y sembrar el mensaje de Agentforce sin ser un demo en vivo.

**Paso 6.1** — Volver a Tab 1 (Claim principal). Deja el highlights panel visible.

**Talk track:**
> "Hagamos un recuento rápido de los 45 minutos que acabamos de ver:
>
> - Un siniestro completo — `SIN-PYME-2026-0001` — desde el aviso hasta pagos ejecutados y pagos en autorización.
> - Tres participantes con roles diferenciados sobre el mismo modelo estándar.
> - Tres ítems reclamados, cada uno vinculado a la cobertura de la póliza que lo respalda.
> - Reservas técnicas trazables — 50 millones repartidos en 45 de pérdida directa y 5 de gasto — con evidencia por ajuste.
> - 32 millones ya pagados al asegurado, 8 millones en workflow de autorización.
> - Y todo esto sobre un único modelo estándar de Insurance on Core, vinculado directamente a la póliza de Bloque 2, sin objetos custom para el core del proceso."

**Paso 6.2** — Sembrar Agentforce (sin demo en vivo).

**Talk track:**
> "Un último punto antes de pasarle el turno a Bloque 6.
>
> Sobre este mismo modelo, ustedes pueden desplegar agentes conversacionales con **Agentforce** — la capa de agentes de Salesforce, GA desde hace más de un año — para automatizar tareas típicas de siniestros:
>
> - **FNOL asistido**: el asegurado reporta el siniestro por WhatsApp o portal, y el agente arma el Claim con los ítems, el tipo de siniestro y avisa al ajustador.
> - **Resumen ejecutivo del siniestro**: un agente lee todo el expediente — el Claim, participants, items, reservas, pagos — y genera un resumen en 3 líneas para el supervisor cuando pide el status. Sin abrir 6 tabs.
> - **Verificación de cobertura**: consulta la póliza, valida vigencia, exclusiones y límites, y responde 'sí cubre, con estos condicionales' o 'no cubre por esta cláusula'.
> - **Redacción de comunicaciones**: cartas al asegurado, actos de peritaje, notificaciones al reasegurador — generadas con prompts controlados.
>
> Todo esto no es futuro — es producto GA. Lo dejamos fuera del scope de esta demo para no mezclar mensajes, pero está listo para un piloto en la fase de habilitación."

**Paso 6.3** — Puente a Bloque 6 (Reportería).

**Talk track:**
> "Con eso cierro Bloque 3. El siguiente bloque que van a ver — Reportería — toma exactamente todos los datos que acabamos de mostrar aquí y los transforma en dashboards, KPIs y reportes regulatorios. Sin ETLs, sin cubos aparte: los mismos objetos que vieron, alimentando Reports y CRM Analytics en tiempo real.
>
> Le paso el turno a [nombre del presentador de Bloque 6]. Gracias."

**Puntos de énfasis:**
- No prometas Agentforce funcionando en la demo — si el cliente lo pide, di: "Con gusto lo agendamos como sesión dedicada en la fase de habilitación."
- El puente a Reportería es literal: los mismos datos, otra vista.

**Opcional — si sobran 2+ minutos y el cliente muestra interés técnico:**
- Ve a **Setup** → busca "Einstein GenAI" o "Permission Set Licenses" → muestra que el PSL Einstein GenAI está asignado o disponible en la org — solo como evidencia de que la plataforma está preparada.
- No entres en detalle. 30 segundos máximo.

---

## 3. Preguntas anticipadas (Q&A)

Estas son las preguntas que Seguros ALFA seguramente va a lanzar durante o después del bloque. Ten las respuestas listas, cortas, y con anclaje al modelo que acabas de mostrar.

### Q1 — ¿Cómo se detecta fraude en siniestros?

> "El modelo estándar captura todos los datos que un motor de fraude necesita — LossType, EstimatedAmount, historial del asegurado, participantes, patrones de fecha. Sobre eso, Einstein Discovery y CRM Analytics generan modelos predictivos de propensión a fraude sin que el equipo de siniestros tenga que hacer feature engineering manual. También se puede integrar con motores externos vía API — SAS, Shift Technology, etc. La flexibilidad está en que el dato está estructurado desde el día uno."

### Q2 — ¿El ajustador puede reasignar el siniestro a otro ajustador?

> "Sí. El campo `Owner` del Claim se puede cambiar manualmente o vía reglas — Case Assignment Rules o Flow. También hay routing por skills con Omni-Channel si Seguros ALFA quiere balancear carga entre ajustadores por especialidad, geografía o disponibilidad. Es configuración, no desarrollo."

### Q3 — ¿Pueden integrar peritos externos sin licenciarlos como usuarios internos?

> "Sí. Experience Cloud les da un portal externo con licencia Partner Community o Customer Community Plus. El perito ve solo los siniestros que se le asignaron, puede subir fotos, actas, informes, y su interacción queda registrada en el mismo modelo — como `ClaimParticipant` con rol `Loss Adjuster` y con acceso vía portal. Sin duplicar datos ni pagar licencia interna."

### Q4 — ¿Qué pasa si el siniestro excede el límite de la cobertura?

> "El modelo compara `Total Claimed` y `Total Adjusted` de la ClaimCoverage contra el `Limit Amount` de la Insurance Policy Coverage. Si excede, se puede configurar un Flow que alerte al supervisor, bloquee el pago automático, o dispare una revisión. En el layout se pueden mostrar los dos valores lado a lado. En una implementación productiva es lo primero que se cablea."

### Q5 — ¿Se puede automatizar el FNOL desde el asegurado?

> "Sí, por tres vías: (1) un OmniScript en Experience Cloud que guía al asegurado paso a paso y crea el Claim al final; (2) un agente de Agentforce por WhatsApp o chat que hace intake conversacional; (3) una API pública si Seguros ALFA quiere disparar el FNOL desde su app móvil o su web. Los tres flujos crean el mismo `Claim` estándar con los mismos ClaimParticipants y ClaimItems que vieron acá."

### Q6 — ¿Cómo se gestiona la reserva IBNR o los cambios de reserva a lo largo del tiempo?

> "El objeto `ClaimCovReserveAdjustment` permite múltiples ajustes sobre la misma ClaimCoverage. Cada vez que actuaría o el ajustador actualizan la estimación, se crea un nuevo Adjustment con su razón y quién lo hizo. La reserva total en la ClaimCoverage se recalcula automáticamente. Eso te da la trazabilidad histórica para IBNR y para reportería SFC. Si quieren, en la fase de implementación armamos un dashboard específico de evolución de reservas."

### Q7 — ¿Reaseguros?

> "Reaseguros está fuera del scope de esta demo, y honestamente fuera del core estándar de Insurance on Core hoy. Salesforce tiene partners como Duck Creek o Sapiens si el requerimiento es un motor de reaseguro cedente completo. Para tratados facultativos con cesión manual, se puede modelar sobre custom objects. Está en el roadmap del producto y lo podemos revisar en detalle en la fase de habilitación."

### Q8 — ¿Reportería regulatoria SFC Colombia?

> "Los datos que vieron — reservas, ajustes, pagos, tipología de siniestros, severidad — están estructurados en el modelo estándar de Salesforce, así que el pipeline hacia reportes SFC es directo. Bloque 6, que sigue ahora, muestra Reports nativos. Para reportes SFC específicos que requieren formatos regulatorios exactos, se combina con CRM Analytics o con una integración a la herramienta actuarial que ya usen. La ventaja: el dato es único, no hay que reconciliar entre CRM y motor de siniestros."

### Q9 (bonus, por si sale) — ¿Por qué solo hay una ClaimCoverage si hay 3 ClaimItems?

> "Buena observación. Los 3 ítems corresponden a la misma cobertura desde el punto de vista técnico — todos son daños derivados del incendio y del lucro cesante asociado. En la demo simplificamos a una ClaimCoverage para no cargar la pantalla con reservas duplicadas. En producción, si dos ítems corresponden a coberturas distintas de la póliza, se abren dos ClaimCoverages y cada una controla su reserva. Es directo, no requiere desarrollo."

### Q10 (bonus) — ¿Por qué el `Adjusted Amount` del pago pendiente está vacío?

> "A propósito. El monto ajustado se completa cuando la autoridad aprueba el pago. Hasta que no hay aprobación, el ajustador no fija el monto final — porque si la autoridad recorta o modifica, el ajustado refleja la decisión final. Es el comportamiento esperado del workflow de autorización."

---

## 4. Transición a Bloque 6 (Reportería)

Ya está incluida como Paso 6.3. Recapitulo el talk track para tenerlo a mano:

> "Con eso cierro Bloque 3. El siguiente bloque que van a ver — Reportería — toma exactamente todos los datos que acabamos de mostrar aquí y los transforma en dashboards, KPIs y reportes regulatorios. Sin ETLs, sin cubos aparte: los mismos objetos que vieron, alimentando Reports y CRM Analytics en tiempo real. Le paso el turno a [nombre]. Gracias."

**Handoff físico**: entrega el control de pantalla o el clicker. Si es Zoom/Meet, para de compartir para que el próximo presentador comparta lo suyo.

---

## 5. Fallbacks generales

Si algo falla en vivo, aquí están las salidas de emergencia sin perder ritmo.

### Fallback A — Tab Financials no muestra reservas ni CCPDs

- Ve directo a la ClaimCoverage (Tab 2 ya abierta): `/lightning/r/ClaimCoverage/0kPg80000000OITEA2/view`.
- Muestra los campos de reserva directamente en el layout del ClaimCoverage.
- En Related, muestra los Adjustments y los Payment Details desde ahí.

### Fallback B — Un tab del Claim no aparece (Participants, Financials, etc.)

- Navega por URL directa a los registros que necesitas (ver IDs en las secciones anteriores).
- Explica al cliente: "El layout se configura por perfil — en producción se ajusta al rol del usuario. Los datos están, el acceso es de configuración."

### Fallback C — ClaimItems no aparecen en Related

- Ve a `/lightning/o/ClaimItem/list` y filtra la view por `Claim.Name = SIN-PYME-2026-0001`.
- Alternativa: URL directa a cada item (IDs en Fase 3).

### Fallback D — El link Insurance Policy Coverage rompe

- Ve a Tab 5 (lista de InsurancePolicy).
- Abre `POL-PYME-2026-0001` y desde la póliza navega a Related → Claims → SIN-PYME-2026-0001.
- Mismo mensaje: end-to-end funciona, la navegación es bidireccional.

### Fallback E — El browser se pone lento o crashea

- Cierra tabs de más y quédate con Tab 1 (Claim).
- Si Salesforce entero no responde: refresca (Cmd+R). Si sigue mal, vuelve a login desde `https://storm-c90aab66569c63.my.salesforce.com/`.
- Como última salida: usa el objeto Chatter del Claim y muestra los datos a través de campos del highlights panel + Details tab; salta Financials y ve directo al cierre narrativo.

### Fallback F — El cliente empuja un tema que no manejas

- No inventes. Frase para ganar tiempo: "Muy buena pregunta — para no darles una respuesta imprecisa, la anoto y en la sesión de aclaraciones les traigo el detalle con el equipo de producto."
- Anótala físicamente. Al final del día, revísala con Nehuen antes de responder.

### Fallback G — Timing corriendo (te quedan 10 min de los 45 y estás en Fase 3)

- Salta Fase 3 completa (Claim Items) — di: "Los ítems reclamados están en el tab Related, en una implementación productiva se pueden profundizar por categoría."
- Corta Fase 4 al mínimo: muestra solo la ClaimCoverage y un CCPD (el Paid). Salta Reserve Adjustments.
- Prioriza Fase 5 (vínculo con póliza) — es la más impactante narrativamente.
- Cierra con Paso 6.1 y 6.3, salta Agentforce (6.2).

### Fallback H — Timing sobrando (terminaste en 35 min)

- Fase 6.2 con más detalle sobre Agentforce.
- Muestra tab **Claim Team** — quiénes son los usuarios internos asignados al siniestro.
- Muestra tab **Action Plan** — checklist de tareas del proceso de gestión.
- Ve a Setup → Permission Set Licenses → Einstein GenAI, para mostrar habilitación.
- Abre el Claim en la app móvil de Salesforce (si tienes iPad/celular listo) — 30 segundos, impacto visual grande.

---

## 6. Métricas de éxito — checklist post-bloque

Al terminar Bloque 3, el cliente Seguros ALFA debería tener claro:

- [ ] El siniestro es un objeto estándar de Insurance on Core (`Claim`) vinculado a la póliza sin desarrollo custom.
- [ ] Multi-rol de participantes (asegurado, ajustador, testigo) sobre `ClaimParticipant` estándar.
- [ ] Los ítems reclamados (`ClaimItem`) se conectan a la cobertura de póliza (`InsurancePolicyCoverage`) que los respalda.
- [ ] Las reservas técnicas son trazables por ajustes (`ClaimCovReserveAdjustment`) — audit-ready.
- [ ] Los pagos tienen ciclo completo: reservado → autorizado → pagado, con workflow configurable.
- [ ] El vínculo `Claim ↔ InsurancePolicy` es directo y bidireccional — no hay ETL de por medio.
- [ ] El modelo alimenta reportería (Bloque 6) sin necesidad de duplicar datos.
- [ ] Agentforce puede sumarse sobre este modelo para automatizar FNOL, resúmenes, verificación de cobertura y comunicaciones — como capa opcional, GA.
- [ ] Todo lo mostrado está en la org de la demo, con IDs reales, sin objetos custom para el core del proceso de siniestros.

**Frase final para dejar en la sala** (opcional, si el momento lo pide):

> "Lo que vieron en 45 minutos no es una prueba de concepto — es la funcionalidad estándar del producto que Seguros ALFA compra el día uno. La conversación de implementación es sobre cómo lo adaptamos a los procesos específicos de Aval, no sobre qué falta construir."

---

## Anexo — Mapa rápido de IDs para copiar-pegar

| Registro | Objeto | ID |
|---|---|---|
| Claim SIN-PYME-2026-0001 | Claim | `0Zkg80000000awLCAQ` |
| Claimant Panadería La Espiga | ClaimParticipant | `0aSg8000000LNXtEAO` |
| Loss Adjuster Alan Reed | ClaimParticipant | `0aSg8000000LNb7EAG` |
| Witness Bomberos Bogotá | ClaimParticipant | `0aSg8000000LNcjEAG` |
| Horno Industrial | ClaimItem | `0dqg80000000UpJAAU` |
| Estantería Metálica | ClaimItem | `0dqg80000000UqvAAE` |
| Lucro Cesante 5 días | ClaimItem | `0dqg80000000UsXAAU` |
| ClaimCoverage Incendio | ClaimCoverage | `0kPg80000000OITEA2` |
| Reserva pérdida directa | ClaimCovReserveAdjustment | `0l7g800000002ppAAA` |
| Reserva gasto lucro cesante | ClaimCovReserveAdjustment | `0l7g800000002rRAAQ` |
| Payment Summary | ClaimPaymentSummary | `0l8g80000001y5NAAQ` |
| CCPD-01 Horno Pagado | ClaimCoveragePaymentDetail | `0l2g80000000PfxAAE` |
| CCPD-02 Lucro Cesante Pending | ClaimCoveragePaymentDetail | `0l2g80000000PhZAAU` |

**Instancia base**: `https://storm-c90aab66569c63.my.salesforce.com`

Cualquier registro se accede como: `{instancia}/lightning/r/{Objeto}/{Id}/view`

---

**Éxito, Luis. Respirá antes de empezar. El dato está, la historia está, el runbook está. Solo tenés que contarla.**
