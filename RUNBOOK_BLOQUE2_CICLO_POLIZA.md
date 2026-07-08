# Runbook — Bloque 2: Ciclo completo de una póliza

**Duración asignada**: 30 min | **Ejecutor**: Luis Fabián Rodríguez | **Org**: ins-qbranch-alfa (https://storm-c90aab66569c63.my.salesforce.com)

---

## 0. Setup pre-demo (hacer 15 min antes de arrancar el bloque)

### 0.1 Login y verificación de sesión
1. Abrir Chrome (perfil habitual, NO incógnito — necesitamos sesión persistida y evitamos re-login).
2. Ir a `https://storm-c90aab66569c63.my.salesforce.com` y confirmar que ya estás logueado como el usuario demo. Si pide login, autenticar con las credenciales que Nicolás compartió por Slack.
3. En la barra superior de Salesforce, esquina superior izquierda, verificar que aparezca el App Launcher (9 puntos) y que la app activa sea **Insurance Agent Console**. Si no lo es: click en App Launcher → escribir "Insurance Agent Console" → click.

### 0.2 Verificación crítica de mapping de coverages (2 min, hacer SÍ o SÍ)

**Por qué**: hay un riesgo conocido de confusión entre el ID de la coverage de Incendio y la de Equipo Electrónico. La transición al Bloque 3 (siniestros) apunta a una coverage específica; si Luis se equivoca de coverage en vivo, se rompe la coherencia narrativa del guion. Antes de arrancar la demo, confirmar visualmente el mapping:

| Coverage esperada | ID esperado | Premium |
|---|---|---|
| Incendio y Aliados | 0cYg80000000KErEAM | 800.000 |
| Responsabilidad Civil Extracontractual | 0cYg80000000KDFEA2 | 600.000 |
| Robo y Asalto Interior | 0cYg80000000KI5EAM | 400.000 |
| Equipo Electrónico | 0cYg80000000KGTEA2 | 300.000 |
| Rotura de Maquinaria | 0cYg80000000KJhEAM | 200.000 |
| Sustracción de Dinero y Valores | 0cYg80000000KLJEA2 | 100.000 |

**Pasos**:
1. Abrir en una pestaña temporal `https://storm-c90aab66569c63.my.salesforce.com/lightning/r/InsurancePolicyCoverage/0cYg80000000KErEAM/view` y confirmar que el Name es **Incendio y Aliados** y Premium = **800.000**.
2. Abrir `https://storm-c90aab66569c63.my.salesforce.com/lightning/r/InsurancePolicyCoverage/0cYg80000000KGTEA2/view` y confirmar que el Name es **Equipo Electrónico** y Premium = **300.000**.
3. Si alguno de los dos NO coincide con el nombre esperado: **avisar a Nicolás por Slack inmediatamente** — el runbook del Bloque 3 apunta a una coverage específica para el siniestro y necesitamos alinear antes del arranque. La convención asumida en este runbook y en la transición al Bloque 3 es la de la tabla superior.

### 0.3 Tabs del navegador (abrir en este orden, dejar todas cargadas)

Abrir 6 pestañas y dejarlas listas. El orden importa porque durante la demo Luis va a saltar entre ellas con Ctrl+Tab.

| # | URL | Para qué |
|---|-----|----------|
| 1 | `https://storm-c90aab66569c63.my.salesforce.com/lightning/r/InsurancePolicy/0YTg80000000hJVGAY/view` | Póliza POL-PYME-2026-0001 (vista principal) |
| 2 | `https://storm-c90aab66569c63.my.salesforce.com/lightning/r/Account/001g800000T9v3QAAR/view` | Cuenta Panadería La Espiga SAS (asegurado) |
| 3 | `https://storm-c90aab66569c63.my.salesforce.com/lightning/r/InsurancePolicyCoverage/0cYg80000000KErEAM/view` | Coverage Incendio y Aliados (detalle) |
| 4 | `https://storm-c90aab66569c63.my.salesforce.com/lightning/o/InsurancePolicyTransaction/list` | Lista de transacciones (para saltar a Emisión y Endoso) |
| 5 | `https://storm-c90aab66569c63.my.salesforce.com/lightning/o/InsurancePolicyProductClause/list` | Lista de cláusulas de la póliza |
| 6 | `https://storm-c90aab66569c63.my.salesforce.com/lightning/r/InsurancePolicyProductClause/1VGg800000008QbGAI/view` | Cláusula manual Coaseguro 10% (para el momento de InsuranceClauses) |

### 0.4 Verificaciones visuales pre-demo (3 min)

En la pestaña 1 (POL-PYME-2026-0001) confirmar:
- Header: **Status = In Force**, **PremiumAmount = 2.400.000**, **EffectiveDate = 2026-06-01**, **ExpirationDate = 2027-05-31**, **NameInsured = Panadería La Espiga SAS**.
- Sub-tabs visibles arriba de la sección detalle: **Policy Structure**, **Related**, **Details**.
- Click en **Policy Structure**: se debe ver un árbol con el nombre de la póliza y debajo 6 Coverages. Si el árbol tarda en cargar, refrescar (Cmd+R).
- Click en **Related**: se ven las **Coverages** listadas (6 filas). **Ojo**: aquí NO aparecen Transactions ni Clauses en el layout default — eso es esperado, ver Gotcha #1 en la sección 5.

En la pestaña 4 (lista InsurancePolicyTransaction) confirmar:
- El dropdown de List View arriba a la izquierda de la lista **puede venir en "Recently Viewed"** por default, que devuelve la lista vacía si no se abrieron esos records en la sesión actual. **Cambiarlo a "All"** (click en el dropdown → "All"). Fijar "All" como default con el pin/estrella si el UI lo permite, para que no se resetee.
- Con "All" seleccionado, deben aparecer los 2 records: **POL-PYME-2026-0001 — Emisión** y **POL-PYME-2026-0001 — Endoso 001 Incendio**.

En la pestaña 5 (lista InsurancePolicyProductClause) confirmar:
- Misma advertencia: cambiar List View a **"All"** (por default suele estar en "Recently Viewed" y devuelve vacío).
- Con "All" seleccionado, deben aparecer las 6 cláusulas.

### 0.5 Preparación del cliente demo (importante)
- La única póliza emitida es **POL-PYME-2026-0001** contra **Panadería La Espiga SAS**. Las otras dos cuentas del RFP (**Ferretería El Tornillo** y **Consultores Andinos**) existen como Accounts pero **no tienen póliza asociada**. Si el cliente pregunta por las 3 cuentas juntas, la respuesta preparada está en la sección 3.

### 0.6 Zoom y ventana
- Zoom del browser al 90% (Cmd + `-` una vez) para que quepa el header completo + related list sin scroll horizontal.
- Compartir la ventana completa de Chrome, no una pestaña específica (así puede alt-tab entre pestañas sin re-compartir).

---

## 1. Contexto y objetivo del bloque (30 seg)

Este bloque muestra el **ciclo completo de vida de una póliza Pyme** ya emitida en la plataforma: cómo se estructura contra la cuenta del asegurado, cómo se descomponen las coberturas con sus límites, deducibles y primas, cómo se persisten las transacciones financieras (emisión y endoso) y cómo el motor de cláusulas trae automáticamente el clausulado del producto y permite agregar cláusulas manuales específicas del cliente. Para ALFA es la evidencia funcional de que el modelo estándar de Salesforce Insurance soporta el flujo end-to-end en objetos nativos, sin custom code.

---

## 2. Click path paso a paso

### Paso 2.1 — Punto de partida: Insurance Agent Console (1 min)

**Click / navegación:**
1. Traer al frente la pestaña 1 (Chrome → tab con POL-PYME-2026-0001).
2. Si por alguna razón se salió: App Launcher (9 puntos arriba a la izquierda) → escribir "Insurance Agent Console" → click. Luego click en la tab **Policies** de la app → click en **POL-PYME-2026-0001**.
3. En pantalla se debe ver: header de la póliza con Policy Name = **POL-PYME-2026-0001**, Status = **In Force**, tres sub-tabs (Policy Structure / Related / Details).

**Qué decir (talk track):**
> "Estamos parados en la Insurance Agent Console, que es la aplicación estándar de Salesforce Insurance para el usuario que gestiona pólizas. Lo que ven acá es una póliza Pyme Integral que ya fue emitida para uno de los clientes objetivo de la RFP: **Panadería La Espiga SAS**, vigencia 1 de junio 2026 al 31 de mayo 2027, prima anual de 2 millones 400 mil pesos. Toda la información que voy a mostrar en los próximos minutos vive en objetos estándar del data model de Insurance, no hay desarrollo custom por encima."

**Puntos de énfasis:**
- Señalar el header (Status In Force, Effective/Expiration dates, Premium).
- Mencionar "objetos estándar" — este es el mensaje diferencial vs. el CRM anterior.

**Si algo no aparece:**
- Si la página muestra "Insufficient Privileges" o queda en blanco: refrescar con Cmd+R.
- Si sigue fallando: ir por App Launcher → Insurance Agent Console → tab Policies → buscar "POL-PYME-2026-0001" en la lista.

---

### Paso 2.2 — Vínculo con la cuenta del asegurado (2 min)

**Click / navegación:**
1. En el header de la póliza, ubicar el campo **Name Insured** (Nombre del Asegurado). Está en la fila de campos highlight, junto a Status y Effective Date.
2. Click en el hipervínculo **Panadería La Espiga SAS**. Se abre la cuenta.
3. En pantalla: Account de tipo **Customer**, Industry = **Food & Beverage**, BillingCity = **Bogotá**.
4. Mostrar el header de la Account durante ~15 segundos. Bajar hasta ver los Related tabs.
5. Volver a la póliza: click en la flecha "atrás" del browser (o Ctrl+Tab a la pestaña 1).

**Qué decir (talk track):**
> "La póliza está vinculada por lookup al asegurado, que es una Account estándar de Salesforce — la misma Account que usa ventas, servicio y facturación. Esto es clave: **no duplicamos el cliente entre módulos**. La panadería es una PyME del sector alimentos en Bogotá, y cualquier interacción que tenga con ALFA — una llamada al call center, un caso de siniestros, una renovación — se ve en una sola vista 360 de esta Account."

**Puntos de énfasis:**
- Vista 360 = un solo registro cliente para toda la operación.
- Insurance reutiliza Account, Contact, Case, Opportunity — no crea entidades paralelas.

**Si algo no aparece:**
- Si el hipervínculo del Name Insured no está clickeable: usar directamente la pestaña 2 (Account Panadería La Espiga SAS).

---

### Paso 2.3 — Policy Structure: árbol de coberturas (3 min)

**Click / navegación:**
1. Volver a la pestaña 1 (POL-PYME-2026-0001).
2. Click en el sub-tab **Policy Structure** (Estructura de Póliza) — es el primero de los tres tabs.
3. En pantalla: se despliega un árbol jerárquico. Nodo raíz = POL-PYME-2026-0001. Al expandirlo, aparecen 6 nodos hijo (Coverages).
4. Si el árbol viene colapsado: click en la flecha ► al lado del nombre de la póliza para expandirlo.
5. Recorrer visualmente los 6 nodos leyéndolos en voz alta en este orden (que es el orden de prima descendente):
   - Incendio y Aliados — **800.000**
   - Responsabilidad Civil Extracontractual — **600.000**
   - Robo y Asalto Interior — **400.000**
   - Equipo Electrónico — **300.000**
   - Rotura de Maquinaria — **200.000**
   - Sustracción de Dinero y Valores — **100.000**

**Qué decir (talk track):**
> "En Policy Structure vemos la anatomía de la póliza: una póliza que agrupa **seis coberturas**. Este árbol se construyó automáticamente cuando emitimos la póliza a partir del producto Pyme Integral que vieron en el Bloque 1. Cada nodo hijo es un `InsurancePolicyCoverage` — un objeto estándar — con su propio límite asegurado, deducible y prima. **La suma de las primas de las seis coberturas — 800 + 600 + 400 + 300 + 200 + 100 mil — da exactamente los 2 millones 400 mil pesos de la póliza**. Es un modelo consistente y auditable."

**Puntos de énfasis:**
- "Se construyó automáticamente" — trazabilidad producto → póliza.
- La aritmética verificada (800+600+400+300+200+100 = 2.400) es un argumento de confianza operativa. Si Luis quiere, puede leer la suma en voz alta.

**Si algo no aparece:**
- Si Policy Structure muestra loading eterno: cerrar la pestaña, reabrir con la URL directa (pestaña 1).
- Si el árbol muestra la póliza pero sin hijos: click en el ► para expandir; si aún así no expande, ir por el tab Related (siguiente paso) para mostrar las coverages ahí.

---

### Paso 2.4 — Detalle de una cobertura: Incendio y Aliados (3 min)

**Click / navegación:**
1. En el árbol de Policy Structure, click en la cobertura **Incendio y Aliados**. Se abre el detalle de la coverage.
   - Alternativa: Ctrl+Tab a la pestaña 3 (ya está abierta con esta coverage — ID `0cYg80000000KErEAM`, confirmado en el paso 0.2).
2. En pantalla: página de detalle del `InsurancePolicyCoverage` con los campos:
   - **Coverage Code**: incendioAliados
   - **Sum Insured / Limit**: 100.000.000
   - **Deductible**: 2.000.000
   - **Premium**: 800.000
3. Volver al Policy Structure y hacer lo mismo con **Rotura de Maquinaria** (para mostrar una cobertura con límite y deducible distintos: 50M / 1M / 200k).

**Qué decir (talk track):**
> "Entrando al detalle de Incendio y Aliados vemos los tres números que un suscriptor y un operador de siniestros necesitan siempre a la mano: **límite asegurado 100 millones, deducible 2 millones, prima anual 800 mil**. Cada cobertura tiene su código —incendioAliados, roboAsalto, rcExtracontractual— que es la llave que amarra la póliza al catálogo maestro de coberturas que vieron en el Bloque 1. Cuando el suscriptor arma un nuevo plan, no está tipeando textos libres: está seleccionando de este catálogo, con reglas de límite y deducible mínimo/máximo controladas."

**Puntos de énfasis:**
- Coverage Code = llave de negocio, no un texto libre.
- Consistencia con Bloque 1: producto → coverage template → InsurancePolicyCoverage.

**Si algo no aparece:**
- Si al click en el nodo no navega: usar pestaña 3 directamente.
- Si el campo Limit aparece como "SumInsured" o "InsuredValue" (variantes del data model): explicar verbalmente "el label en inglés es Sum Insured, en ALFA lo etiquetamos como Límite Asegurado — es configurable por perfil".

---

### Paso 2.5 — Transacciones: Emisión y Endoso (4 min)

**Click / navegación:**
1. Ctrl+Tab a la pestaña 4 (`/lightning/o/InsurancePolicyTransaction/list`).
2. **Verificar el List View**: el dropdown arriba a la izquierda de la lista debe decir **"All"**. Si dice **"Recently Viewed"** (default frecuente), la lista aparece vacía — click en el dropdown → seleccionar **"All"**.
3. Con "All" seleccionado se ven dos filas:
   - **POL-PYME-2026-0001 — Emisión**
   - **POL-PYME-2026-0001 — Endoso 001 Incendio**
4. Click en la primera: **POL-PYME-2026-0001 — Emisión**.
5. En pantalla: detalle de la transacción con:
   - **Type**: Premium Payment
   - **Category**: Issuance
   - **Status**: Approved
   - Lookup a la póliza POL-PYME-2026-0001.
6. Volver con la flecha del browser a la lista. Click en **POL-PYME-2026-0001 — Endoso 001 Incendio**.
7. En pantalla: detalle con **Type = Endorsement**, **Category = Endorsement**, **Status = Approved**.

**Qué decir (talk track):**
> "Toda vida útil de una póliza — la emisión, un endoso, una cancelación, una renovación, un pago de prima — queda registrada como una **InsurancePolicyTransaction**. En este caso tenemos dos: la **emisión original** de la póliza el 1 de junio, categorizada como Issuance, y un **Endoso 001** sobre la cobertura de Incendio, categorizado como Endorsement. Ambas transacciones referencian la póliza por lookup. Esto le da a ALFA la auditoría completa: para cualquier fecha del ciclo puedo reconstruir qué estado tenía la póliza y por qué cambió."

**Puntos de énfasis:**
- Modelo transaccional = auditoría regulatoria.
- Type + Category + Status = clasificación granular para reportes (nos sirve para el Bloque 6).

**Si algo no aparece:**
- Si en el detalle de la transacción los campos de fecha están vacíos (EffectiveFromDate, TransactionEffectiveDate, PostedDate): **NO lo mencionar**. Enfocar la narrativa en Type/Category/Status. Si el cliente pregunta específicamente por fechas, ver Q&A en sección 3.
- Si TotalTransactionAmount aparece en 0: mismo tratamiento — no llamar la atención sobre el campo. Es un dato que en la operación real se poblaría desde el sistema de cobranza; para esta demo el foco es la clasificación transaccional.
- Si la lista aparece vacía con "All" ya seleccionado: refrescar (Cmd+R). Si aún así no cargan, alternativa es ir a la pestaña 1 (póliza), Related tab, y explicar que en el layout default de la Insurance Agent Console no está expuesta esta related list — pero el data model la soporta y basta un ajuste de Lightning Record Page para verla ahí (ver Gotcha #1).

---

### Paso 2.6 — Cláusulas del clausulado: AutoAdded vs Manual (5 min) — integra Bloque 5 InsuranceClauses

**Click / navegación:**
1. Ctrl+Tab a la pestaña 5 (`/lightning/o/InsurancePolicyProductClause/list`).
2. **Verificar el List View**: mismo tema que Transactions — si dice "Recently Viewed", cambiar a **"All"**. Con "All" se ven las 6 cláusulas.
3. En pantalla, las 6 filas:
   - Buena Fe (POL-PYME-2026-0001) — CreationMethod = AutoAdded
   - Actos Dolosos (POL-PYME-2026-0001) — AutoAdded
   - Guerra Terrorismo (POL-PYME-2026-0001) — AutoAdded
   - **Coaseguro 10% (POL-PYME-2026-0001) — Manual**
   - Actividades Extremas (POL-PYME-2026-0001) — AutoAdded
   - Deducible Mínimo (POL-PYME-2026-0001) — AutoAdded
4. Click en **Buena Fe**. Mostrar el detalle: ClauseText con la declaración de veracidad del asegurado. Volver.
5. Click en **Coaseguro 10%** (o Ctrl+Tab a la pestaña 6).
6. En pantalla: detalle de la cláusula con **CreationMethod = Manual** claramente visible.

**Qué decir (talk track):**
> "Este es el corazón del **motor de cláusulas** —lo que en algunos casos se maneja como un módulo aparte, en Salesforce Insurance es nativo—. Al emitir la póliza, el sistema **copió automáticamente cinco cláusulas** desde la plantilla del producto Pyme Integral: Buena Fe, Actos Dolosos, Guerra y Terrorismo, Actividades Extremas y Deducible Mínimo. Todas ellas están marcadas con CreationMethod = AutoAdded, es decir, vinieron del producto. Y adicionalmente, el suscriptor **agregó una cláusula específica para este cliente**, el Coaseguro del 10%, que ven con CreationMethod = Manual. Esto le permite a ALFA mantener un clausulado corporativo estándar por producto y a la vez negociar excepciones puntuales por póliza, con trazabilidad completa de qué es estándar y qué fue negociado."

**Puntos de énfasis:**
- 5 AutoAdded + 1 Manual = balance producto/negociación.
- El texto de la cláusula (ClauseText) queda persistido en el objeto — no es un PDF pegado, es data.
- Auditoría regulatoria: la Superintendencia puede pedir en cualquier momento qué clausulado tenía una póliza en una fecha específica y esto es la fuente única.

**Si algo no aparece:**
- Si la lista tarda: refrescar. Si no carga, usar la pestaña 6 directamente para mostrar al menos el ejemplo del Manual.
- **IMPORTANTE**: NO abrir la cláusula "Actividades Extremas" durante la demo — su ClauseText contiene el placeholder "Ninguna" no resuelto ("Se excluyen operaciones con Ninguna salvo pacto..."). Si el cliente insiste específicamente en esa cláusula: mencionar que "el texto que ven es una plantilla en refinamiento; en producción ALFA maneja las plantillas finales aprobadas por legal".

---

### Paso 2.7 — Consistencia: back to the policy (2 min)

**Click / navegación:**
1. Volver a la pestaña 1 (POL-PYME-2026-0001).
2. Click en el sub-tab **Details**.
3. Mostrar el bloque de campos completos: Policy Name, Status, Policy Type = BOP (Business Owners), Effective Date, Expiration Date, Premium Amount, Name Insured.

**Qué decir (talk track):**
> "Cerrando el ciclo: la póliza que empezamos viendo hace unos minutos tiene detrás **una cuenta, seis coberturas, dos transacciones y seis cláusulas** — todo en objetos estándar, todo con relaciones nativas, todo consultable por SOQL o por reportes de Salesforce. Este es el punto: **el ciclo de vida completo de la póliza vive en el core**, no en integraciones ni en tablas custom paralelas."

**Puntos de énfasis:**
- "En el core" — mensaje raíz del RFP de ALFA (Insurance on Core).
- El mismo dato lo consume el Bloque 3 (Siniestros) y el Bloque 6 (Reportería), sin ETLs.

**Si algo no aparece:**
- Si el tab Details no muestra alguno de los campos: no detenerse — ya se mostraron en el header en el Paso 2.1.

---

### Paso 2.8 — Cierre del bloque (30 seg)

**Qué decir (talk track):**
> "Con esto cerramos el ciclo de una póliza. En 30 minutos vimos emisión, estructura de coberturas, transacciones y clausulado —incluyendo el motor de cláusulas que en el guión original iba como Bloque 5 y aquí lo integramos por coherencia—. Cualquier pregunta antes de pasar a Siniestros, que es el siguiente bloque, con muchísimo gusto."

---

## 3. Preguntas anticipadas del cliente

| Pregunta probable | Respuesta preparada |
|---|---|
| ¿Por qué solo veo una póliza si el RFP mencionaba tres cuentas (Panadería, Ferretería, Consultores)? | "Buena observación. Las tres cuentas están creadas como Accounts en la org y son las que quedaron en el RFI. Para esta sustentación **emitimos una póliza end-to-end** contra Panadería La Espiga para poder mostrarles el ciclo completo con datos coherentes: coberturas, transacciones, cláusulas y siniestros vinculados. Las otras dos cuentas están listas para ser el ejercicio del taller posterior si es de su interés, y el proceso de emisión es exactamente el mismo que van a ver aplicado sobre esta." |
| ¿Las Transactions no muestran fecha ni monto — cómo funciona en producción? | "El objeto InsurancePolicyTransaction tiene campos nativos para **TransactionEffectiveDate, EffectiveFromDate, PostedDate y TotalTransactionAmount**. En una implementación productiva estos campos se pueblan desde el sistema de emisión o desde cobranzas vía integración estándar. En el dataset de esta demo priorizamos mostrar la **clasificación transaccional** (Type = Premium Payment/Endorsement, Category = Issuance/Endorsement, Status) que es la que habilita la trazabilidad regulatoria. La fecha y el monto son campos estándar del objeto, listos para poblarse." |
| ¿Cómo se garantiza que si edito una cobertura, la prima total de la póliza se recalcule? | "Hay dos caminos, ambos out-of-the-box: (a) un **Flow declarativo** que se dispara en el after-update de InsurancePolicyCoverage y suma en el padre — es el patrón que sugerimos porque es no-code; (b) un **rollup summary** si se permite en el objeto. Además, para emisión y endoso, el proceso natural es que un **Product Configurator** —Flow o Omniscript— sea el que reconstruye los premios y crea una nueva InsurancePolicyTransaction de Endorsement, dejando auditoría del cambio." |
| ¿Puedo agregar una cláusula que no esté en el catálogo del producto? | "Sí. Vieron el Coaseguro del 10% marcado como CreationMethod = **Manual**: ese es exactamente el caso. El suscriptor tiene permiso para añadir cláusulas ad hoc a una póliza, y quedan diferenciadas de las AutoAdded para reportes de gobernanza. Si además la cláusula se vuelve recurrente en muchas pólizas, se promueve al catálogo del producto (ProductClause) y desde ahí ya baja automáticamente a las nuevas emisiones." |
| ¿Y el clausulado histórico? ¿Si en 3 años cambia una cláusula en el producto, las pólizas vigentes se ven afectadas? | "No. Cada InsurancePolicyProductClause es un **snapshot al momento de la emisión** — el ClauseText queda persistido en el registro de la póliza. Si mañana legal modifica la cláusula en el producto maestro, esa modificación aplica solo a **nuevas emisiones**; las pólizas ya emitidas conservan el clausulado vigente al día de su emisión. Esto es un requerimiento regulatorio típico en Colombia y el modelo estándar lo soporta." |
| ¿La emisión soporta pólizas colectivas (varios asegurados bajo una misma póliza)? | "Sí, y es una pregunta común. El modelo estándar de Salesforce Insurance incluye el objeto **InsurancePolicyParticipant** para múltiples asegurados/beneficiarios con roles diferenciados (Named Insured, Additional Insured, Beneficiary, etc.). **En este dataset de demo no lo poblamos** porque la póliza Pyme que están viendo tiene un titular único que es la panadería; el foco del bloque es ciclo end-to-end sobre un titular. Si les interesa el escenario de póliza colectiva —vida grupo, salud grupo—, podemos armar un walkthrough dedicado en el taller posterior con datos poblados en InsurancePolicyParticipant. El objeto y su soporte están en el data model estándar, sin cambios." |
| ¿Cómo se conectan estos datos con el sistema de emisión actual de ALFA? | "Tres opciones dependiendo del target-state: (a) **MuleSoft** para conectar el core de emisión legacy vía APIs — es el patrón que Salesforce recomienda para el ecosistema ALFA; (b) **Data Cloud** si necesitan además unificar cliente 360 y federar cálculos; (c) migración completa al core con **Financial Services Cloud + Insurance**, que es el escenario del RFI. Cualquiera de las tres respeta el modelo de datos que están viendo." |
| ¿Dónde veo Transactions y Clauses desde la póliza? Ahora en Related no aparecen. | "Correcto, buen ojo. El **Lightning Record Page** de la Insurance Agent Console viene con un layout default que no expone esas dos related lists — es una decisión de UX del template estándar. Con **Lightning App Builder** —clicks, no código— agregamos ambas related lists al layout del InsurancePolicy y quedan visibles junto a Coverages. Es una tarea de 5 minutos que en la implementación real hacemos en el sprint 0." |

---

## 4. Transición al siguiente bloque

> "Perfecto. Vimos que la póliza está viva, con seis coberturas, dos transacciones y seis cláusulas. La pregunta natural que sigue es: ¿qué pasa cuando ocurre un siniestro contra esta póliza? Justo eso es el **Bloque 3**: vamos a abrir un incidente contra Panadería La Espiga y ver el flujo de FNOL hasta pago, disparado contra una de las coberturas de la póliza. Luis, cambio a la siguiente pestaña."

**Nota para Luis (no leer en voz alta)**: en el guion original la transición nombraba explícitamente "cobertura de Incendio". El runbook del Bloque 3 puede apuntar a Equipo Electrónico (siniestro tipo horno / equipo) en lugar de Incendio. Para evitar contradicciones en vivo, esta transición **no nombra la coverage específica** — solo dice "una de las coberturas". El Bloque 3 abre con el detalle del siniestro y ahí se nombra la coverage correcta. En el paso 0.2 se debe confirmar el mapping antes del arranque.

---

## 5. Fallbacks generales del bloque

### Gotcha #1 — Related list de Transactions/Clauses no visible en el layout default
- **Síntoma**: en el tab Related del InsurancePolicy solo aparecen las Coverages (6 filas). No hay Transactions ni Clauses.
- **Causa**: el Lightning Record Page de la Insurance Agent Console viene con un layout default de plantilla estándar.
- **Plan B en vivo**: usar las pestañas 4 y 5 pre-abiertas (list views directas). Explicar verbalmente que "en implementación real se agrega la related list al layout en 5 minutos con Lightning App Builder".
- **NO tratar de arreglarlo en vivo** — es un ajuste post-demo, ya está en la lista de mejoras.

### Gotcha #2 — Campos de fecha/monto vacíos en Transactions
- **Síntoma**: al abrir POL-PYME-2026-0001 — Emisión, los campos TransactionEffectiveDate, EffectiveFromDate, PostedDate están vacíos y TotalTransactionAmount = 0.
- **Plan B**: no llamar la atención sobre esos campos; enfocar en Type/Category/Status. Respuesta pre-armada en Q&A (segunda fila de la tabla).

### Gotcha #3 — Placeholder "Ninguna" en Actividades Extremas
- **Síntoma**: si se abre la cláusula "Actividades Extremas", el ClauseText contiene "Se excluyen operaciones con Ninguna salvo pacto...".
- **Plan B**: no abrir esa cláusula en el flujo estándar (Paso 2.6 dice qué cláusulas abrir: Buena Fe y Coaseguro 10%). Si el cliente pide específicamente esa: respuesta "el texto es una plantilla en refinamiento; en producción se aprueba por legal".

### Gotcha #4 — Locale en inglés
- **Síntoma**: labels standard de Salesforce salen en inglés (Status, Effective Date, Premium Amount, etc.).
- **Plan B**: cuando aparezca un label en inglés, decir en la narración su equivalente en español ("Effective Date, o sea Fecha de Inicio"). El cliente sabe que es un tema de perfil de usuario y no de producto — mencionarlo la primera vez que aparezca y ya. NO empezar a cambiar el idioma del usuario en vivo.

### Gotcha #5 — Sesión expirada
- **Síntoma**: al hacer click aparece pantalla de login.
- **Plan B**: re-autenticar rápidamente. Mientras tanto, seguir narrando (arquitectura, modelo de datos) hasta que vuelva la sesión. Nunca dejar el silencio en pantalla más de 15 segundos.

### Gotcha #6 — Un componente no carga (loading eterno)
- **Plan B**: refrescar con Cmd+R. Si insiste, cerrar la pestaña y abrir con la URL directa (todas las URLs están en la sección 0.3).

### Gotcha #7 — El cliente pide "muéstreme los 3 clientes con póliza"
- **Síntoma**: pregunta sobre las 3 cuentas del RFP.
- **Plan B**: respuesta pre-armada en Q&A (primera fila). La honestidad "emitimos una póliza end-to-end para mostrar el ciclo completo con datos coherentes" es más fuerte que improvisar.

### Gotcha #8 — List View en "Recently Viewed" (lista vacía)
- **Síntoma**: al abrir las pestañas 4 (Transactions) o 5 (Clauses), la lista aparece vacía aunque la data existe.
- **Causa**: el List View default en Salesforce Lightning suele ser "Recently Viewed", que solo muestra records visitados en la sesión actual. Si nadie los visitó, sale vacío.
- **Plan B**: click en el dropdown de List View arriba a la izquierda → seleccionar **"All"**. Fijarlo con pin/estrella si el UI lo permite para que persista.
- **Prevención**: hacerlo en el setup pre-demo (paso 0.4) — no llegar a este momento en vivo.

### Gotcha #9 — Confusión de mapping coverages (Incendio vs Equipo Electrónico)
- **Síntoma**: Luis abre la coverage esperando "Incendio y Aliados" y sale "Equipo Electrónico" (o viceversa), rompiendo el hilo narrativo o la conexión con Bloque 3.
- **Causa**: los IDs son largos y visualmente parecidos (0cYg80000000KErEAM vs 0cYg80000000KGTEA2); si alguien tocó los datos en la org o si el runbook del Bloque 3 apunta a un ID distinto al que se cree, hay conflicto.
- **Plan B**: en el paso 0.2 se confirma el mapping antes del arranque. Si en vivo Luis abre una coverage y el nombre NO coincide con lo esperado, **no forzar** — decir "vamos a mirar otra de las coberturas" y navegar por Policy Structure a la que sí quería (por nombre visible, no por ID).
- **Prevención**: la transición al Bloque 3 (sección 4) NO nombra la coverage específica, para que el Bloque 3 la nombre correctamente al abrirla.

### Gotcha #10 — Cliente pregunta por pólizas colectivas / InsurancePolicyParticipant
- **Síntoma**: cliente pregunta si el modelo soporta múltiples asegurados/beneficiarios y quiere verlo en pantalla.
- **Plan B**: Q&A tiene la respuesta preparada. **Ser honesto**: el objeto InsurancePolicyParticipant existe en el data model estándar, pero **no hay data poblada en esta org** para mostrarlo en vivo. No inventar navegación. Ofrecer walkthrough dedicado en el taller posterior.

---

## 6. Métricas de éxito del bloque

Al final del bloque, la audiencia de ALFA (tecnología + negocio) debe salir con estas cinco convicciones:

- [ ] La póliza vive en un objeto estándar (**InsurancePolicy**), no en un custom object.
- [ ] Las coberturas se modelan como registros hijo (**InsurancePolicyCoverage**), con límite, deducible y prima estructurados — y la suma coincide con la prima de la póliza (2.400.000 COP: 800+600+400+300+200+100).
- [ ] Cada evento del ciclo de vida (emisión, endoso, cancelación, renovación, pago) genera una **InsurancePolicyTransaction**, dando trazabilidad regulatoria.
- [ ] El clausulado se copia automáticamente desde el producto (AutoAdded) y admite cláusulas negociadas por póliza (Manual), con snapshot inmutable al momento de la emisión.
- [ ] Todo el ciclo se apoya en **Account** como fuente única del cliente — habilitando vista 360 con ventas, servicio y siniestros.

Si alguno de los cinco puntos no queda claro durante el bloque, aprovechar el Q&A o la transición al Bloque 3 para reforzarlo antes de avanzar.

---

**Fin del Runbook — Bloque 2**
