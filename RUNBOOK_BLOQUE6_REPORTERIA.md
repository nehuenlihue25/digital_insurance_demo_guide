# Runbook — Bloque 6: Reportería

**Duración asignada**: 30 min | **Ejecutor**: Luis Fabián | **Org**: ins-qbranch-alfa
**Instance URL**: https://storm-c90aab66569c63.my.salesforce.com

---

## 0. Setup pre-demo (hacer 15 min antes)

### 0.1 Login al org
1. Abrir Chrome (perfil limpio, sin extensiones que injecten CSS).
2. Ir a https://storm-c90aab66569c63.my.salesforce.com
3. Loguearse con el usuario de demo (mismo que se usó en bloques anteriores). Confirmar que el locale del usuario es `en_US` — los labels standard van a salir en inglés y hay que aclararlo verbalmente cuando aplique.
4. Verificar que la App activa sea "Insurance Console" o "Sales" (cualquiera que tenga Reports y Dashboards en el App Launcher — no importa el app específico porque vamos a navegar por el App Launcher).

### 0.2 Pre-cargar tabs (dejarlas abiertas en el orden en que se van a usar)

Abrir en pestañas separadas del navegador, en este orden exacto (de izquierda a derecha):

| # | Propósito | URL |
|---|---|---|
| 1 | Reports Home (folder view) | https://storm-c90aab66569c63.my.salesforce.com/lightning/o/Report/home?queryScope=mine |
| 2 | Dashboards Home | https://storm-c90aab66569c63.my.salesforce.com/lightning/o/Dashboard/home |
| 3 | Dashboard Producción Pyme 2026 | https://storm-c90aab66569c63.my.salesforce.com/lightning/r/Dashboard/01Zg8000001l9nFEAQ/view |
| 4 | Dashboard Renovaciones Pyme 2026 | https://storm-c90aab66569c63.my.salesforce.com/lightning/r/Dashboard/01Zg8000001l9nGEAQ/view |
| 5 | Dashboard Siniestralidad Pyme 2026 | https://storm-c90aab66569c63.my.salesforce.com/lightning/r/Dashboard/01Zg8000001l9nHEAQ/view |
| 6 | Report Loss Ratio Pyme | https://storm-c90aab66569c63.my.salesforce.com/lightning/r/Report/00Og80000045mGFEAY/view |
| 7 | Report Prima Emitida por Producto Pyme | https://storm-c90aab66569c63.my.salesforce.com/lightning/r/Report/00Og80000045mGKEAY/view |
| 8 | Report Pólizas Próximas a Vencer 90 Días | https://storm-c90aab66569c63.my.salesforce.com/lightning/r/Report/00Og80000045mGHEAY/view |
| 9 | Report Siniestros Pyme por Estado | https://storm-c90aab66569c63.my.salesforce.com/lightning/r/Report/00Og80000045mGMEAY/view |

### 0.3 Verificar que los 3 dashboards renderizan datos y validar composición de widgets

En cada tab de dashboard (3, 4, 5):

1. Confirmar que **cargan sin "No results to display"** en los widgets principales. Los dashboards corren contra los mismos objetos usados en los bloques anteriores: `Product2` / `ProductCategory` (Bloque 1), `InsurancePolicy` con sus campos `PremiumAmount` y `ExpirationDate` (Bloque 2), `Claim` con `ClaimCoverage`, `ClaimCoveragePaymentDetail` y sus reservas `LossReserveAmount` / `ExpenseReserveAmount` (Bloque 3).
2. Si algún widget muestra "No results", click **Refresh** (arriba a la derecha del dashboard) y esperar 10-15 segundos.
3. Confirmar que el timestamp "As of {fecha}" no sea de hace días — si lo es, click **Refresh** de nuevo.
4. **VALIDACIÓN CRÍTICA de composición de widgets** — antes de asumir la narrativa del Paso 2.9, verificar que los widgets descritos existen efectivamente en el dashboard:
   - **Producción Pyme 2026**: verificar que están los widgets Prima Emitida total, Prima por Producto, Prima por Plan, Cartera por Industria.
   - **Renovaciones Pyme 2026**: verificar Conteo de Pólizas a Vencer y Prima en Riesgo.
   - **Siniestralidad Pyme 2026**: verificar Loss Ratio por Producto, Reserva Total, Siniestros por Estado, Pagos Aprobados vs Pendientes.
5. **VALIDACIÓN de source reports linkeados** — click en el título de un widget cualquiera del dashboard de Siniestralidad. Si abre el report subyacente correctamente, el drill-down y el fallback 5.1 funcionan. Si NO abre (widget sin source report vinculado), anotarlo y no prometer drill-down en el talk track.
6. Si un widget no coincide con la narrativa, **ajustar el talk track del Paso 2.9** en vivo — no describir un widget que no está en pantalla.

### 0.4 Verificar folder de Reports
- En la tab 1 (Reports Home), click en **Folders** en el panel izquierdo.
- Confirmar que aparece el folder **"Seguros ALFA Pyme"**.
- Click en el folder — deben aparecer los **11 reports**. Si aparece menos, revisar que estemos con el usuario correcto y que el folder tenga permisos de lectura.

### 0.5 Zoom del browser
- Poner zoom al **90%** en Chrome (Cmd + `-` una vez desde 100%). Los dashboards con 6 widgets se ven completos sin scroll.

### 0.6 Preparar el App Launcher
- Cmd + Shift + . (o click en los 9 puntos arriba a la izquierda) para abrir App Launcher.
- Escribir "Reports" y "Dashboards" una vez cada una para confirmar que aparecen en los resultados (evita el titubeo en vivo).

### 0.7 Repaso de terminología alineada con Bloques 1-3

Antes de arrancar, memorizar los objetos y campos reales que se usaron en los bloques anteriores. Si el cliente pregunta "muéstrame ese campo en vivo", tenemos que estar en el objeto correcto:

| Concepto de negocio | sObject real | Campo real |
|---|---|---|
| Producto Pyme y sus planes | `Product2` + `ProductCategory` | `Name`, `ProductClass` |
| Póliza emitida | **`InsurancePolicy`** (no `PolicyContract`) | `PolicyName`, `PolicyNumber` |
| Prima de la póliza | `InsurancePolicy` | **`PremiumAmount`** (no `PolicyPremium`) |
| Fecha de vencimiento | `InsurancePolicy` | **`ExpirationDate`** (no `EndDate`) |
| Siniestro | **`Claim`** (no `InsuranceClaim`) | `ClaimNumber`, `Status` |
| Cobertura del siniestro | `ClaimCoverage` | `LossReserveAmount`, `ExpenseReserveAmount` |
| Pago aprobado del siniestro | **`ClaimCoveragePaymentDetail`** (no `ClaimPayment`) | **`AdjustedAmount`** (no `TotalPaidAmount`) |
| Cláusulas de la póliza (Bloque 5 integrado en 2) | `InsuranceClause` | `Type` (values Clause / Exclusion — NO `ClauseType`) |

**Regla de oro**: en los talk tracks, usar estos nombres. Si un talk track de este runbook usa un término, ese es el término correcto — no cambiarlo en vivo por memoria.

---

## 1. Contexto y objetivo del bloque (30 seg)

En este bloque cerramos la sustentación mostrando cómo Seguros ALFA obtiene **visibilidad operativa y de negocio en tiempo real** sobre todo lo que se construyó en los bloques anteriores: la producción de pólizas Pyme, las renovaciones que vienen y la siniestralidad. No hay integraciones externas, no hay BI adicional: son **reports y dashboards nativos de Salesforce** corriendo directo contra los objetos estándar de Insurance on Core (`Product2`, `InsurancePolicy`, `InsuranceClause`, `Claim`, `ClaimCoverage`, `ClaimCoveragePaymentDetail`). Es el mismo dato transaccional del Bloque 2 y del Bloque 3, ahora agregado para el equipo de suscripción, siniestros y gerencia.

Cerramos con el tablero de siniestralidad porque visualmente es el más impactante y el que responde directo a los KPIs de negocio.

---

## 2. Click path paso a paso

### Paso 2.1 — Entrada al folder de Reports (2 min)

**Click / navegación:**
1. Ir a la **tab 1** del browser (Reports Home) — URL ya pre-cargada: `/lightning/o/Report/home?queryScope=mine`.
2. En el panel izquierdo, click en **Folders** (o "Carpetas" si el tenant estuviera en español).
3. Scroll o búsqueda del folder **"Seguros ALFA Pyme"** — click en él.
4. Verás en pantalla: una lista de **11 reports** con columnas Name, Description, Folder, Format, Created By.

**Qué decir (talk track):**
> "Antes de mostrar los tableros, quiero que vean el punto de partida: todos los reports que armamos para el negocio Pyme están agrupados en una sola carpeta, 'Seguros ALFA Pyme'. Once reports que cubren cartera, coberturas, prima emitida, pólizas por estado, renovaciones próximas, siniestros y pagos, más los indicadores de negocio como Loss Ratio y Reserva Total Constituida. Todo esto es reporting nativo de Salesforce, no hay una herramienta adicional: es la misma plataforma donde se emite la póliza y se registra el siniestro."

**Puntos de énfasis:**
- Recalcar que son **11 reports agrupados** — visual claro de la lista.
- Mencionar que la carpeta se puede **compartir con perfiles/roles específicos** (suscripción ve unos, siniestros ve otros) — es control estándar de Salesforce.

**Si algo no aparece:**
- Si el folder no aparece en la lista, click en **All Folders** en lugar de "Created by Me" o "Shared with Me" en el filtro superior.
- Si aún así no aparece, ir directo con URL a un report: `/lightning/r/Report/00Og80000045mGDEAY/view` y explicar el folder verbalmente.

---

### Paso 2.2 — Abrir un report individual: Prima Emitida por Producto Pyme (3 min)

**Click / navegación:**
1. Desde la lista del folder, click en el report **"Prima Emitida por Producto Pyme"**.
   - Alternativa (más rápida si el listado se enredó): saltar a la **tab 7** del browser, URL directa `/lightning/r/Report/00Og80000045mGKEAY/view`.
2. El report abre en modo **View** (visualización, no edición).
3. Verás en pantalla: agrupación por Producto, columna con la sumatoria de `PremiumAmount`, y un total al pie.

**Qué decir (talk track):**
> "Este es un report simple pero fundamental para el área comercial: prima emitida agrupada por producto. Estos productos son exactamente los que armamos en el Bloque 1 — el Seguro Pyme Integral y sus planes Esencial, Empresarial y Corporativo. Cada peso de prima que ven acá está atado a una `InsurancePolicy` emitida en el Bloque 2, sumando el campo `PremiumAmount`. No hay copia de datos, no hay ETL, no hay warehouse: el report lee directo la póliza."

4. Click en el ícono de **Edit** (arriba derecha) para mostrar por 30 segundos el Report Builder.
5. Verás en pantalla: Report Builder con Groups, Columns, Filters visibles a la izquierda.

**Qué decir:**
> "Y así se ve el constructor. Un usuario funcional del equipo de datos o de negocio arma esto arrastrando campos. Filtros por fecha, por producto, por sucursal, por lo que necesiten. Sin código."

6. Click en **Close** (o botón X arriba a la derecha) para salir del builder sin guardar.

**Puntos de énfasis:**
- **Dato en vivo, no snapshot**: si emitieran una `InsurancePolicy` nueva ahora y refrescaran (botón Refresh), aparecería.
- **Self-service**: no es un desarrollo por ticket, es configuración de un power user.

**Si algo no aparece:**
- Si el report abre en blanco (0 rows), verificar que las pólizas del Bloque 2 tengan `PremiumAmount` poblado. Si no, pasar directo al siguiente report y mencionar "acá algunos productos aún no tienen prima consolidada porque son emisiones de prueba".

---

### Paso 2.3 — Report de Loss Ratio Pyme (3 min)

**Click / navegación:**
1. Ir a la **tab 6** del browser: `/lightning/r/Report/00Og80000045mGFEAY/view`.
2. Verás en pantalla: report con columnas que combinan siniestros pagados y prima devengada, con una columna calculada de Loss Ratio (%).

**Qué decir (talk track):**
> "Este es uno de los reports más importantes para la mesa técnica y para la gerencia: Loss Ratio Pyme. Cruza siniestros contra prima. En una aseguradora este es el termómetro del portafolio — un producto con Loss Ratio arriba de 70% en Pyme normalmente prende alarmas. Y lo relevante para ALFA: este cálculo no requiere un job batch nocturno, no requiere que un analista arme un Excel — se calcula al momento con **row-level formulas** de Salesforce, sumando el `AdjustedAmount` de `ClaimCoveragePaymentDetail` (los pagos aprobados que vimos en el Bloque 3) sobre el `PremiumAmount` de `InsurancePolicy` (la prima emitida del Bloque 2)."

**Puntos de énfasis:**
- **Row-level formulas y summary formulas** son features standard de Reports — se pueden hacer cálculos como (Siniestros/Prima), diferencias, promedios, todo sin Apex.
- Este report **no lo tenemos con Description poblada** — si el cliente pregunta qué mide exactamente, explicar verbalmente usando la tabla del Anexo C.

**Si algo no aparece:**
- Si la columna de Loss Ratio muestra "0%" o vacío en varios rows, es porque esos productos aún no tienen siniestros. Explicar: "en la data de demo solo el flujo del Bloque 3 tiene pagos registrados en `ClaimCoveragePaymentDetail` — en producción todos los productos tendrían histórico".

---

### Paso 2.4 — Report de Pólizas Próximas a Vencer 90 Días (2 min)

**Click / navegación:**
1. Ir a la **tab 8** del browser: `/lightning/r/Report/00Og80000045mGHEAY/view`.
2. Verás en pantalla: listado de pólizas con `ExpirationDate` dentro de los próximos 90 días, agrupadas por producto o por mes.

**Qué decir (talk track):**
> "Este es el insumo operativo para el área de renovaciones. El filtro está armado sobre el campo `ExpirationDate` de `InsurancePolicy` con una fecha relativa — `ExpirationDate = NEXT 90 DAYS` — así que **no hay que actualizar el filtro nunca**. Cada día que un usuario abra este report, va a ver la ventana de renovación móvil. Y de acá se puede exportar a Excel, o mejor: se puede **suscribir** para que Salesforce se lo envíe por email todos los lunes."

3. Click en el ícono de **Subscribe** (arriba derecha, ícono de campana o "Subscribe") para mostrar el modal de suscripción por 15 segundos.
4. Verás en pantalla: modal con Frequency (Daily/Weekly/Monthly), Time, Recipients.
5. Click **Cancel** en el modal (no queremos crear la suscripción real).

**Qué decir:**
> "Frecuencia diaria, semanal o mensual, con condiciones — por ejemplo, 'mándamelo solo cuando el conteo pase de 50 pólizas'. Todo nativo."

**Puntos de énfasis:**
- **Fecha relativa** = report vivo, sin mantenimiento.
- **Suscripciones con condiciones** — el cliente casi siempre pregunta "y me lo puedo recibir automático" — la respuesta es sí.

**Si el cliente pide ver la fórmula del filtro en vivo:**
- Click en **Edit** del report → panel de Filters (izquierda) → mostrar el filtro `ExpirationDate equals NEXT 90 DAYS`.
- Cerrar sin guardar.

**Si algo no aparece:**
- Si el report devuelve 0 rows (nada vence en 90 días), aclarar: "en producción con cartera real esto siempre tendría cientos de rows — en la org de demo tenemos pocas pólizas de ejemplo, algunas ya fuera de la ventana". Y pasar al siguiente.

---

### Paso 2.5 — Report de Siniestros Pyme por Estado (2 min)

**Click / navegación:**
1. Ir a la **tab 9** del browser: `/lightning/r/Report/00Og80000045mGMEAY/view`.
2. Verás en pantalla: siniestros del objeto `Claim` agrupados por su `Status` (Submitted, Under Investigation, Approved, Closed, etc. — los del Bloque 3), con conteo y montos.

**Qué decir (talk track):**
> "Y para el área de siniestros, este es el pipeline: cuántos hay en cada etapa del ciclo que mostramos en el Bloque 3. Los estados que ven acá — Submitted, Under Investigation, Approved, Denied, Closed — son los del picklist estándar de `Claim.Status` que ya validaron. El equipo de siniestros trabaja este report todos los días para saber dónde tienen cuellos de botella."

**Puntos de énfasis:**
- **Trazabilidad directa al Bloque 3** — no es data separada, es el mismo objeto `Claim`.
- El equipo puede hacer **drill-down**: click en un grupo → muestra los siniestros individuales → click en uno → abre el record completo de `Claim`.

**Demostración de drill-down (opcional, si hay tiempo):**
1. Click en el número de conteo de cualquier grupo (por ejemplo "Under Investigation").
2. Verás la lista expandida de los siniestros individuales.
3. Click en un Claim Number cualquiera → abre el record de `Claim`.
4. Volver con back del browser.

**Si algo no aparece:**
- Si todos los siniestros están en el mismo estado, mencionar: "en la demo solo tenemos el flujo end-to-end del Bloque 3 con el siniestro SIN-PYME-2026-0001 — en producción verían la distribución real del portafolio".

---

### Paso 2.6 — Transición a Dashboards (30 seg)

**Click / navegación:**
1. Ir a la **tab 2** del browser: `/lightning/o/Dashboard/home`.
2. Click en **All Folders** en el panel izquierdo.
3. Click en la carpeta **"Seguros ALFA Pyme"**.
4. Verás en pantalla: **3 dashboards** — Producción Pyme 2026, Renovaciones Pyme 2026, Siniestralidad Pyme 2026.

**Qué decir (talk track):**
> "Los reports son la materia prima. Los dashboards son la vista consolidada — lo que la gerencia mira en la mañana. Armamos tres tableros que cubren los tres frentes del negocio Pyme: producción, renovaciones y siniestralidad. Vamos a recorrerlos."

---

### Paso 2.7 — Dashboard Producción Pyme 2026 (4 min)

**Click / navegación:**
1. Click en **"Producción Pyme 2026"** desde la lista.
   - Alternativa (más rápida): **tab 3** del browser, URL directa `/lightning/r/Dashboard/01Zg8000001l9nFEAQ/view`.
2. Verás en pantalla: dashboard con widgets de Prima Emitida (agregando `PremiumAmount`), distribución por producto, distribución por plan, cartera por industria.

**Qué decir (talk track):**
> "Este es el tablero del área de suscripción. Arriba, la **prima emitida total** — la suma de `PremiumAmount` de todas las pólizas Pyme, el KPI principal. Al lado, el desglose por producto — lo mismo que vieron en el report anterior pero visual, en gráfico de barras o dona. Abajo, la cartera segmentada por industria del cliente, que le da al negocio la lectura de concentración de riesgo: qué tanto del portafolio está en manufactura, servicios, comercio, construcción."

3. **Hover** (pasar el mouse sin click) sobre una barra o segmento cualquiera del gráfico de Prima por Producto.
4. Verás en pantalla: tooltip con el valor exacto.

**Qué decir:**
> "Y si un ejecutivo quiere entrar al detalle, cada widget es clickeable — abre el report subyacente. Es el mismo dato del report que vimos hace un minuto, ahora agregado visualmente."

5. Click en cualquier widget (por ejemplo el de Prima Emitida por Producto).
6. Se abre el report en modo drill-down. Volver con back del browser.

**Puntos de énfasis:**
- **Filtros de dashboard**: si el dashboard tiene un filtro global arriba (por sucursal, por año, por producto), mostrarlo. Sin filtro no hay problema — mencionar que se pueden agregar filtros globales para que el mismo tablero le sirva a distintos ejecutivos.
- **Refresh manual y programado**: el dashboard se puede programar para que se refresque cada mañana a las 6 am, así llega actualizado a la primera reunión del día.

**Si algo no aparece:**
- Si un widget dice "No results", click **Refresh** arriba a la derecha del dashboard (ícono de flecha circular). Esperar. Si sigue vacío, seguir con los widgets que sí cargaron y mencionar: "este widget cruza data que en la demo aún no está poblada — en producción con carga real siempre tendría datos".

---

### Paso 2.8 — Dashboard Renovaciones Pyme 2026 (3 min)

**Click / navegación:**
1. Ir a la **tab 4** del browser: `/lightning/r/Dashboard/01Zg8000001l9nGEAQ/view`.
2. Verás en pantalla: dashboard con conteo de pólizas próximas a vencer (usando `InsurancePolicy.ExpirationDate`), distribución por mes, prima en riesgo de no renovación (agregando `PremiumAmount` de las pólizas que vencen).

**Qué decir (talk track):**
> "El tablero de renovaciones combina dos cosas: cuántas pólizas vencen en la ventana relevante — 30, 60, 90 días — usando `ExpirationDate` de `InsurancePolicy`, y cuánta prima está asociada, sumando `PremiumAmount` de esas mismas pólizas. La lectura clave para el negocio no es solo 'cuántas pólizas', sino 'cuánta prima está en riesgo de no renovarse'. Y eso lo tienen a la mano para armar campañas de retención, priorizar la gestión del corredor o de la fuerza propia."

3. Mostrar cómo el dashboard **cruza con el report** del Paso 2.4.
4. Click en el widget que representa el conteo por mes (o similar).
5. Se abre el report subyacente — es el mismo "Pólizas Pyme Próximas a Vencer 90 Días" que ya vimos.

**Qué decir:**
> "Y como les mencioné, esto está construido con fechas relativas — `NEXT 90 DAYS` — no fechas fijas. El primero de agosto van a ver exactamente la misma vista pero con la ventana corrida un mes. Cero mantenimiento."

**Puntos de énfasis:**
- **Prima en riesgo** es el ángulo de negocio, no el conteo puro.
- La conexión con el report ya visto refuerza que **todo es un solo modelo de datos**.

**Si algo no aparece:**
- Similar al anterior: refresh, y si no, seguir.

---

### Paso 2.9 — Dashboard Siniestralidad Pyme 2026 (5 min) — CIERRE FUERTE

**Nota previa para el SE**: la composición exacta de los 4 widgets descritos abajo debe validarse en el Setup 0.3 (paso 4). Si algún widget no está o tiene otro nombre, ajustar el talk track en vivo — no mencionar widgets que no están en pantalla.

**Click / navegación:**
1. Ir a la **tab 5** del browser: `/lightning/r/Dashboard/01Zg8000001l9nHEAQ/view`.
2. Verás en pantalla: el dashboard más completo — Loss Ratio por producto, Reserva Total Constituida, Siniestros por Estado (embudo), Pagos Aprobados vs Pendientes.

**Qué decir (talk track):**
> "Y cerramos con el tablero de siniestralidad. Este es probablemente el tablero más importante para la mesa técnica de Seguros ALFA, porque agrupa todo lo que el actuario y el líder de siniestros necesitan ver en una sola pantalla:
>
> — Uno: **Loss Ratio por producto**. La lectura de rentabilidad técnica. Los productos por debajo del target están en verde, los que se salen aparecen en rojo.
>
> — Dos: **Reserva Total Constituida**. Cuánto tienen provisionado del portafolio Pyme, sumando `LossReserveAmount` y `ExpenseReserveAmount` de `ClaimCoverage` — los mismos campos que validaron en el Bloque 3. Este es el dato que va directo a los cierres contables.
>
> — Tres: **Embudo de siniestros por estado**. Cuántos siniestros hay en cada etapa del ciclo que vieron en el Bloque 3, agrupando `Claim` por su campo `Status`.
>
> — Cuatro: **Pagos aprobados versus pendientes**. La foto de liquidez y de gestión operativa del área."

3. Ir widget por widget haciendo hover para mostrar los tooltips con valores exactos.

**Qué decir mientras se hace hover:**
> "El Loss Ratio se calcula al momento, contra la prima emitida — el `PremiumAmount` de `InsurancePolicy` — y los pagos hechos — el `AdjustedAmount` de `ClaimCoveragePaymentDetail`. La reserva total suma los campos `LossReserveAmount` y `ExpenseReserveAmount` de `ClaimCoverage` que ustedes validaron en el Bloque 3. El embudo de estados es exactamente el flujo Submitted → Under Investigation → Approved → Paid → Closed que mostramos, corriendo sobre `Claim.Status`. Y los pagos aprobados vs pendientes se apoyan en el objeto `ClaimCoveragePaymentDetail` con su estado de aprobación."

4. **Drill-down demostración**: click en el widget de Loss Ratio → abre el report Loss Ratio Pyme → volver. *(Precondición: en Setup 0.3 se validó que el widget tiene source report linkeado.)*
5. **Alternativa visual**: click en el widget de Siniestros por Estado → abre report de Siniestros por Estado → volver.

**Qué decir para cerrar:**
> "Todo esto — los 11 reports y los 3 dashboards — se construyó en cuestión de horas por un power user, sin desarrollo, y sin sacar la data de Salesforce. Y crece con ustedes: cada `InsurancePolicy` emitida, cada `Claim` registrado, cada `ClaimCoveragePaymentDetail` procesado aparece acá **al momento del refresh**. Sin ventanas de mantenimiento, sin dependencia del equipo de datos."

**Puntos de énfasis:**
- Este es el tablero **más denso** — el que le va a quedar grabado al comité.
- Insistir en la **trazabilidad**: cada número acá se puede pinchar y llegar al record fuente.
- Si sobran 30 segundos, click en un siniestro individual desde el embudo → mostrar que abre el record completo de `Claim` del Bloque 3.

**Si algo no aparece:**
- Si un widget está roto, seguir con los otros. **Nunca** pausar en un widget vacío — cambiar el foco a lo que sí funciona.
- Si el widget de Reserva Total muestra un número muy bajo o cero, aclarar: "en la demo solo el siniestro del Bloque 3 tiene `LossReserveAmount` y `ExpenseReserveAmount` poblados en su `ClaimCoverage` — en producción esta cifra reflejaría el portafolio completo".

---

### Paso 2.10 — Cierre del bloque (30 seg)

**Click / navegación:**
- Quedarse en el dashboard de Siniestralidad (tab 5) — es la imagen final que el cliente se lleva.

**Qué decir:**
> "Con esto cerramos los cuatro bloques que se acordaron para hoy: configuración de producto y coberturas — con Bloque 5 de Cláusulas integrado dentro del ciclo de emisión —, ciclo de póliza, siniestros y reportería. Todo sobre la misma plataforma, sin integraciones adicionales, con la data transaccional y analítica en el mismo motor. Quedamos atentos a las preguntas."

**Aclaración interna para el SE**: el scope original definía 5 bloques (1. Producto, 2. Póliza, 3. Siniestros, 5. Cláusulas, 6. Reportería) pero **Bloque 5 se integró explícitamente dentro de la emisión del Bloque 2**. Por eso hoy son 4 runbooks efectivos, no 5. Los Bloques 4 (Facturación y Recaudo) y el original de reaseguros están **fuera de scope** por decisión con GFT/Mario.

---

## 3. Preguntas anticipadas del cliente (durante o al final)

| # | Pregunta probable | Respuesta preparada |
|---|---|---|
| 1 | ¿Cuántos usuarios pueden acceder a estos reports y dashboards de forma concurrente? | Los reports y dashboards son features estándar incluidas en la licencia de Salesforce. La concurrencia depende del edition y del número de usuarios licenciados — con las licencias de Insurance on Core que están cotizando, todo el equipo funcional (suscripción, siniestros, gerencia) tiene acceso de lectura sin costo adicional. Solo aplican los governor limits de la plataforma que no impactan uso normal de reportería. |
| 2 | ¿Los reports soportan volúmenes grandes? Tenemos cientos de miles de pólizas Pyme. | Sí. Reports en Lightning corren sobre el motor de queries de Salesforce con optimizaciones nativas de indexación. Para volúmenes muy grandes o análisis histórico multi-año se puede complementar con **CRM Analytics** (antes Tableau CRM), que se conecta al mismo modelo y permite dashboards sobre decenas de millones de rows. En el scope de esta demo mostramos reporting nativo, pero la arquitectura escala hacia CRM Analytics sin migrar data. |
| 3 | ¿Puedo llevar esto a Power BI o Tableau externo? | Sí. Salesforce expone el modelo vía API REST y Bulk API, y hay conectores nativos certificados para **Tableau** (mismo grupo empresarial de Salesforce) y para Power BI vía OData/REST. También pueden hacer sync a un data lake propio con Data Cloud. Nada les impide llevar la data afuera; solo que **para el 80% de los KPIs operativos y ejecutivos**, con lo nativo se resuelve sin salir de la plataforma. |
| 4 | ¿Cómo controlan el acceso? Yo no quiero que un usuario de siniestros vea la prima total del portafolio. | Dos capas: **folder-level sharing** — cada folder de reports y dashboards se comparte con roles, perfiles o public groups específicos con permisos de View/Edit/Manage; y **field-level security** — si un campo como `PremiumAmount` está oculto para un perfil, no aparece en el report para ese usuario aunque el report técnicamente lo incluya. Además, los reports respetan **row-level security** (sharing rules) — un usuario solo ve los records a los que tiene acceso. |
| 5 | ¿El Loss Ratio se puede calcular por región, canal, corredor, ramo? | Sí. Es un tema de **agrupación** en el report — cualquier campo de `InsurancePolicy` o del Account (región, canal, corredor asignado, ramo, sucursal, ejecutivo comercial) se puede usar como grupo. Y con **summary formulas** se pueden derivar cálculos por grupo. Se construye en el Report Builder, sin código. |
| 6 | ¿Puedo programar que este dashboard se envíe por email cada lunes en la mañana? | Sí. Dashboards y reports soportan **suscripciones nativas**: frecuencia (diaria, semanal, mensual), horario, destinatarios (usuarios, grupos, roles), y **condiciones de envío** (por ejemplo, "solo mándalo si el Loss Ratio pasa de 65%"). El usuario lo configura desde el mismo dashboard con el botón Subscribe. |
| 7 | ¿Estos reports se pueden exportar a Excel o CSV? | Sí, exportación nativa a **Excel (.xlsx) y CSV** desde el botón Export del report, con dos modos: "Formatted Report" (respeta agrupaciones y subtotales) y "Details Only" (data cruda). También se puede programar entrega automática por email como adjunto. |
| 8 | ¿Y si quiero hacer un análisis ad-hoc que no está en estos 11 reports? | Cualquier usuario con el permiso "Create and Customize Reports" arma un report nuevo en el Report Builder — arrastra objetos, filtros, agrupaciones. Para análisis más exploratorios estilo pivot table o cross-object avanzado, se usa **CRM Analytics** que permite lenses interactivas. Nada se hace por ticket a IT para reportería estándar. |
| 9 | ¿Los dashboards se pueden embeber en la home page de Salesforce o en la Community de corredores? | Sí. Los dashboards se pueden agregar como **componente de Lightning App Page** en la home de cualquier usuario según su perfil, y también en **Experience Cloud** (portal de corredores) con las mismas reglas de sharing. Un corredor solo ve las pólizas de su cartera. |
| 10 | ¿Qué pasa si un usuario borra por error un report? | Los folders permiten controlar quién puede borrar (permiso Manage). Los reports borrados van al **Recycle Bin por 15 días** — cualquier admin los restaura con un click. Adicionalmente, para reports críticos se puede aplicar **el permiso "Report Manager"** que limita el delete a un grupo pequeño. |
| 11 | ¿Cuánto tomó construir los 11 reports y los 3 dashboards? | Los 11 reports y 3 dashboards se armaron en menos de un día por un solo recurso, sobre el modelo estándar de Insurance on Core que ustedes ya vieron en los bloques 1 al 3. **Cero código, cero integraciones**, solo configuración en el Report Builder y Dashboard Builder. |
| 12 | ¿Puedo tener alertas cuando algo se sale de un umbral? Ejemplo: Loss Ratio > 70%. | Sí, dos caminos: **Dashboard alerts** — se configuran directamente en el widget con umbral y notificación a destinatarios; y **Report subscriptions con condiciones** — la suscripción solo se envía si se cumple la condición. Para lógica más compleja, se puede usar Flow para monitorear el report y disparar acciones (crear una task, enviar email, generar un caso). |
| 13 | ¿La reserva del siniestro que vi en el dashboard usa fórmula actuarial? | Los campos `LossReserveAmount` y `ExpenseReserveAmount` del objeto `ClaimCoverage` (los que vieron en el Bloque 3) se pueden alimentar de varias formas: cálculo manual del ajustador, fórmula configurable en Salesforce con Flow sobre `ClaimCoverage`, o traído de un motor actuarial externo vía API — Insurance on Core también expone el objeto `ClaimCovReserveAdjustment` para dejar traza de cada movimiento de reserva. En la demo lo mostramos poblado manualmente. En producción, ALFA decide el modelo y se configura sin código en Flow o se integra al sistema actuarial. |
| 14 | Vi que los reports no tienen descripción — ¿qué mide cada uno exactamente? | Podemos poblar el campo Description antes de la implementación productiva. Mientras tanto, ver el **Anexo C** de este runbook con la definición de cada uno de los 11 reports (agrupación, filtros y campos fuente). *(Nota para el SE: si el cliente pregunta en vivo, ver Anexo C abajo.)* |

---

## 4. Transición al siguiente bloque

Este es el **último bloque** del scope acordado. Después de este, se cierra con Q&A general. Frase de cierre sugerida:

> "Con esto completamos los cuatro bloques que teníamos comprometidos para hoy — producto, ciclo de póliza con cláusulas integradas, siniestros y reportería. Como comentamos al inicio, los bloques de reaseguros y facturación y recaudo no formaron parte del alcance de esta sustentación — están en el roadmap de Insurance on Core y los podemos profundizar en una sesión posterior si les interesa. Abrimos ahora el espacio para preguntas generales sobre lo que vieron."

---

## 5. Fallbacks generales del bloque

### 5.1 Un dashboard no carga o muestra "No results" completo
1. Click **Refresh** arriba a la derecha del dashboard. Esperar 15 segundos.
2. Si sigue vacío, intentar el **drill-down al report subyacente** — click en el título del widget. **Precondición**: esto solo funciona si en el Setup 0.3 se validó que los widgets tienen source reports linkeados. Si en el setup se detectó que no lo tenían, **no intentar este paso en vivo** — saltar al 3.
3. Como último recurso, saltar al siguiente dashboard y comentar: "este tablero está teniendo un delay de refresh, en producción esto se programa para correr en la madrugada y llegar listo".

### 5.2 Un report abre en blanco (0 rows)
1. **No pausar**. Comentar: "en esta org de demo la data es acotada — este report en producción con la cartera real siempre traería resultados".
2. Saltar al siguiente report o dashboard.

### 5.3 El App Launcher no encuentra Reports o Dashboards
- Ir directo a las URLs pre-cargadas (tabs 1 y 2 del setup). Nunca depender de la navegación por App Launcher en vivo.

### 5.4 El browser tira un error o se cuelga
1. Refrescar la tab.
2. Si persiste, cerrar la tab y abrir la URL en una nueva desde el bookmark manager.
3. Como último recurso, compartir pantalla con **el ID del dashboard** y explicar verbalmente lo que se vería, usando el diseño que se validó en el setup.

### 5.5 El cliente pide filtrar por un valor específico en vivo
- Aceptar solo si el filtro está en el propio report (edit → filter → apply). **No** improvisar creando reports nuevos en vivo — comentar "esa vista específica la armamos y les compartimos captura o video posterior a esta sesión".

### 5.6 El cliente pregunta por un report que no está en los 11 construidos
- Respuesta genérica: "Ese ejercicio lo agregamos al plan de trabajo post-sustentación. La estructura de datos ya está lista, es solo un report más en el Report Builder sobre los objetos que ya vieron — `InsurancePolicy`, `Claim`, `ClaimCoverage`, `ClaimCoveragePaymentDetail` — cuestión de una hora en configuración."
- **Nunca** decir "no se puede" — el 99% de los casos, con el modelo de Insurance on Core sí se puede.

### 5.7 Se acaba el tiempo (menos de 5 min disponibles)
- Saltar directo al **Paso 2.9 (Dashboard Siniestralidad)** — es el cierre más impactante.
- Recorrer los 4 widgets en 3 minutos.
- Cerrar con el talk track del Paso 2.10.

### 5.8 El cliente pregunta por un campo específico en vivo ("muéstrame ese `PremiumAmount`")
- Salir del report → abrir una `InsurancePolicy` del Bloque 2 → mostrar el campo en el record detail.
- Si el campo tiene otro label en UI (por relabel del Bloque 1 en español), aclararlo: "el label puede aparecer traducido pero el API name es `PremiumAmount`".

---

## 6. Métricas de éxito del bloque

Al terminar el bloque, el cliente debería tener claro:

- [ ] Salesforce tiene **reporting y dashboards nativos** — no hay dependencia de BI externo para KPIs operativos y ejecutivos.
- [ ] Los reports corren directo contra los **objetos de Insurance on Core** vistos en bloques 1-3 (`Product2`, `ProductCategory`, `InsurancePolicy`, `InsuranceClause`, `Claim`, `ClaimCoverage`, `ClaimCoveragePaymentDetail`) — no hay data duplicada ni ETL.
- [ ] El equipo de negocio puede armar y modificar reports **sin código y sin ticket a IT** (Report Builder self-service).
- [ ] Se cubren los **tres frentes operativos**: producción (suscripción), renovaciones (retención), siniestralidad (mesa técnica y siniestros).
- [ ] Se cubren los **KPIs financieros y actuariales**: Prima Emitida total y por producto/plan (`PremiumAmount`), Loss Ratio, Reserva Total Constituida (`LossReserveAmount` + `ExpenseReserveAmount`), Pagos Aprobados vs Pendientes (`AdjustedAmount` de `ClaimCoveragePaymentDetail`).
- [ ] Los dashboards soportan **drill-down** al record fuente — trazabilidad completa desde el KPI ejecutivo hasta el dato transaccional.
- [ ] Existe **control de acceso granular** por folder, perfil, campo y row (sharing).
- [ ] Los reports y dashboards se pueden **suscribir por email con frecuencia y condiciones**.
- [ ] La plataforma **escala hacia CRM Analytics** para análisis avanzados y hacia herramientas externas (Tableau/Power BI) vía API si se necesita.
- [ ] El paquete de **11 reports + 3 dashboards** se construyó en horas, no en semanas — señal clara de time-to-value.

### Checklist de cierre para Luis Fabián
- [ ] Dejar la última pantalla en el **Dashboard de Siniestralidad** (tab 5) — es la imagen final que queda proyectada durante el Q&A.
- [ ] Confirmar verbalmente que se **cumplieron los 4 bloques efectivos de scope** (Bloque 1 Producto, Bloque 2 Póliza con Bloque 5 Cláusulas integrado, Bloque 3 Siniestros, Bloque 6 Reportería).
- [ ] Recordar al cliente que **Reaseguros y Facturación/Recaudo están fuera del scope de hoy** — no dejar la percepción de que se olvidaron.
- [ ] Abrir Q&A general.

---

## Anexo A — Inventario completo del bloque (referencia rápida)

### Dashboards (3)
| Título | ID | URL |
|---|---|---|
| Producción Pyme 2026 | 01Zg8000001l9nFEAQ | `/lightning/r/Dashboard/01Zg8000001l9nFEAQ/view` |
| Renovaciones Pyme 2026 | 01Zg8000001l9nGEAQ | `/lightning/r/Dashboard/01Zg8000001l9nGEAQ/view` |
| Siniestralidad Pyme 2026 | 01Zg8000001l9nHEAQ | `/lightning/r/Dashboard/01Zg8000001l9nHEAQ/view` |

### Reports (11) — Folder "Seguros ALFA Pyme"
| # | Título | ID | URL |
|---|---|---|---|
| 1 | Cartera Pyme por Industria del Cliente | 00Og80000045mGDEAY | `/lightning/r/Report/00Og80000045mGDEAY/view` |
| 2 | Coberturas Activas Pyme por Tipo | 00Og80000045mGEEAY | `/lightning/r/Report/00Og80000045mGEEAY/view` |
| 3 | Loss Ratio Pyme | 00Og80000045mGFEAY | `/lightning/r/Report/00Og80000045mGFEAY/view` |
| 4 | Pagos Aprobados vs Pendientes Pyme | 00Og80000045mGGEAY | `/lightning/r/Report/00Og80000045mGGEAY/view` |
| 5 | Prima Emitida por Plan Pyme | 00Og80000045mGJEAY | `/lightning/r/Report/00Og80000045mGJEAY/view` |
| 6 | Prima Emitida por Producto Pyme | 00Og80000045mGKEAY | `/lightning/r/Report/00Og80000045mGKEAY/view` |
| 7 | Pólizas Pyme por Status | 00Og80000045mGIEAY | `/lightning/r/Report/00Og80000045mGIEAY/view` |
| 8 | Pólizas Pyme Próximas a Vencer 90 Días | 00Og80000045mGHEAY | `/lightning/r/Report/00Og80000045mGHEAY/view` |
| 9 | Reserva Total Constituida Pyme | 00Og80000045mGLEAY | `/lightning/r/Report/00Og80000045mGLEAY/view` |
| 10 | Siniestros Pyme por Estado | 00Og80000045mGMEAY | `/lightning/r/Report/00Og80000045mGMEAY/view` |
| 11 | Total Prima Emitida Pyme | 00Og80000045mGNEAY | `/lightning/r/Report/00Og80000045mGNEAY/view` |

### Folders
| Tipo | Name | DeveloperName | ID |
|---|---|---|---|
| Report folder | Seguros ALFA Pyme | Seguros_ALFA_Pyme | 00lg8000003rGiXAAU |
| Dashboard folder | Seguros ALFA Pyme | Seguros_ALFA_Pyme | 00lg8000003rRd3AAE |

---

## Anexo B — Gotchas conocidos

- Los **11 reports NO tienen Description poblada**. Si el cliente pregunta "qué mide cada uno" hay que explicarlo verbalmente — usar la tabla del **Anexo C** para lookup rápido en vivo. Considerar poblar Description antes del jueves 2026-07-09 (nice-to-have).
- El folder tiene **dos entradas** en la org (una para Reports, otra para Dashboards) con el mismo DeveloperName. Es comportamiento estándar de Salesforce, no un error — no reportarlo como issue si alguien lo nota en el detalle técnico.
- El folder se llama **"Seguros ALFA Pyme" con espacios** en el Name (visible en la UI) y **Seguros_ALFA_Pyme con underscores** en el DeveloperName (para queries SOQL). Al hacer demo, filtrar en la app usando el Name con espacios.
- Los IDs de dashboard (`01Zg80...`) y report (`00Og80...`) son **estables solo en la org `ins-qbranch-alfa`** — si por alguna razón hubiera que replicar en otra org, hay que re-obtenerlos con SOQL, nunca hardcodear.
- Usuario de demo está en `en_US` — todos los **labels de UI** (Reports, Dashboards, Subscribe, Refresh, Edit, Save, Filters, Group Rows, etc.) salen en inglés. Los **datos y nombres de reports/dashboards/folder están en español**. Aclararlo brevemente si un asistente del cliente pregunta.
- **Terminología a preservar en talk tracks** (no confundir con nombres viejos de material comercial): el sObject de la póliza es `InsurancePolicy` (no `PolicyContract`), la prima es `PremiumAmount` (no `PolicyPremium`), la fecha de vencimiento es `ExpirationDate` (no `EndDate`). El sObject del siniestro es `Claim` (no `InsuranceClaim`). El pago aprobado del siniestro es `ClaimCoveragePaymentDetail.AdjustedAmount` (no `ClaimPayment.TotalPaidAmount`). Las reservas están en `ClaimCoverage.LossReserveAmount` y `ClaimCoverage.ExpenseReserveAmount` (no un genérico `ReserveAmount` en el siniestro).

---

## Anexo C — Definición de los 11 reports (lookup rápido para Q&A en vivo)

Uso: si el cliente pregunta "qué mide exactamente el report X", leer de esta tabla. Todas las descripciones están alineadas con los objetos y campos reales de los Bloques 1-3.

| # | Report | Qué mide | Objeto principal | Campos clave / agrupación |
|---|---|---|---|---|
| 1 | Cartera Pyme por Industria del Cliente | Distribución de pólizas Pyme por industria del Account titular — lectura de concentración de riesgo | `InsurancePolicy` + `Account` | Agrupado por `Account.Industry`; conteo de pólizas y suma de `PremiumAmount` |
| 2 | Coberturas Activas Pyme por Tipo | Conteo de coberturas activas por tipo (Responsabilidad Civil, Incendio, Robo, etc.) — el catálogo del Bloque 1 | `PolicyCoverage` sobre `InsurancePolicy` Pyme | Agrupado por tipo de cobertura |
| 3 | Loss Ratio Pyme | Ratio de siniestralidad: pagos de siniestros sobre prima emitida — termómetro de rentabilidad técnica | Cross-object: `ClaimCoveragePaymentDetail` / `InsurancePolicy` | Row-level formula: SUM(`AdjustedAmount`) / SUM(`PremiumAmount`); agrupado por producto |
| 4 | Pagos Aprobados vs Pendientes Pyme | Distribución de pagos de siniestros por estado de aprobación — liquidez y gestión operativa | `ClaimCoveragePaymentDetail` | Agrupado por estado; suma de `AdjustedAmount` |
| 5 | Prima Emitida por Plan Pyme | Suma de prima por plan (Esencial / Empresarial / Corporativo) del Bloque 1 | `InsurancePolicy` | Agrupado por Plan; suma de `PremiumAmount` |
| 6 | Prima Emitida por Producto Pyme | Suma de prima por producto (Seguro Pyme Integral y variantes) | `InsurancePolicy` | Agrupado por `Product2.Name`; suma de `PremiumAmount` |
| 7 | Pólizas Pyme por Status | Distribución del portafolio por estado de vigencia (Active, Expired, Cancelled, etc.) | `InsurancePolicy` | Agrupado por `Status`; conteo de pólizas |
| 8 | Pólizas Pyme Próximas a Vencer 90 Días | Pipeline de renovación: pólizas con `ExpirationDate` en los próximos 90 días | `InsurancePolicy` | Filtro `ExpirationDate = NEXT 90 DAYS`; agrupado por mes o producto |
| 9 | Reserva Total Constituida Pyme | Reserva provisionada total — dato para cierre contable | `ClaimCoverage` | Suma de `LossReserveAmount` + `ExpenseReserveAmount` |
| 10 | Siniestros Pyme por Estado | Embudo de siniestros por etapa del ciclo del Bloque 3 (Submitted → Under Investigation → Approved → Paid → Closed) | `Claim` | Agrupado por `Claim.Status`; conteo |
| 11 | Total Prima Emitida Pyme | KPI de suscripción: suma total de prima del portafolio Pyme | `InsurancePolicy` | Suma de `PremiumAmount`; sin agrupación (total maestro) |

**Nota**: cualquier report puede reagruparse en vivo agregando/removiendo grupos desde Edit → Groups. Ejemplo demostrable si el cliente lo pide: abrir "Total Prima Emitida Pyme" → Edit → agregar `Account.Industry` como grupo → Run → mostrar la nueva vista. Cerrar sin guardar.
