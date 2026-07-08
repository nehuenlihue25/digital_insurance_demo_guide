# Runbooks Seguros ALFA — Índice y Checklist Maestro

**Sustentación RFP Seguros ALFA sobre Salesforce Insurance on Core**
**Fecha:** jueves 2026-07-09
**Horario:** 8:00 a 14:00 hora Colombia (COT, UTC-5)
**Modalidad:** Teams virtual
**Ejecutor:** Luis Fabián Rodríguez (SE)
**Backup técnico:** Nehuen Lihue Lobo (Slack)
**Org demo:** `ins-qbranch-alfa` — https://storm-c90aab66569c63.my.salesforce.com

---

## 0. Cómo usar este documento

Este archivo es el **punto de partida**. Léelo primero, ejecuta el checklist, y solo entonces abre los 4 runbooks de bloque. Cada runbook de bloque asume que el checklist maestro ya fue ejecutado y que tienes la org abierta con las tabs correctas.

Orden recomendado para el miércoles 2026-07-08 en la noche:

1. Leer este INDICE completo (15 min).
2. Ejecutar la sección **Pre-demo checklist (miércoles noche)** (30 min).
3. Leer los 4 runbooks en orden: bloque1 → bloque2 → bloque3 → bloque6 (60-90 min).
4. Dormir. Volver el jueves 7:00 y ejecutar **Pre-demo checklist (jueves 7:00)** (30 min).
5. 7:45 abrir Teams, verificar audio, compartir pantalla.
6. 8:00 arrancar.

---

## 1. Agenda del día (2026-07-09)

| Hora | Duración | Bloque | Contenido | Runbook |
|------|----------|--------|-----------|---------|
| 8:00 - 8:15 | 15 min | Apertura | Presentación, contexto, alcance de la sustentación, qué se cumple y qué no | Este archivo |
| 8:15 - 8:45 | 30 min | **Bloque 1** | Configuración de producto Pyme modular y por planes | `RUNBOOK_BLOQUE_1.md` |
| 8:45 - 8:50 | 5 min | Transición | Preguntas rápidas sobre producto, transición a póliza | — |
| 8:50 - 9:20 | 30 min | **Bloque 2** | Ciclo completo de una póliza (incluye cláusulas — Bloque 5 original) | `RUNBOOK_BLOQUE_2.md` |
| 9:20 - 9:35 | 15 min | Receso café | — | — |
| 9:35 - 10:20 | 45 min | **Bloque 3** | Ciclo completo de siniestros | `RUNBOOK_BLOQUE_3.md` |
| 10:20 - 10:30 | 10 min | Transición | Cierre siniestros, arranque reportería | — |
| 10:30 - 11:00 | 30 min | **Bloque 6** | Reportería y tableros ejecutivos | `RUNBOOK_BLOQUE_6.md` |
| 11:00 - 11:15 | 15 min | Receso | — | — |
| 11:15 - 11:30 | 15 min | Alcance no cubierto | Declaración honesta de Bloque 4 (Reaseguros) y Bloque 5 original (Facturación) — posicionar roadmap | Este archivo |
| 11:30 - 13:00 | 90 min | **Q&A abierto** | Preguntas cliente sobre lo demostrado y consultas de negocio/técnicas | Este archivo |
| 13:00 - 13:30 | 30 min | Cierre | Próximos pasos, entregables post-demo, timeline de decisión | Este archivo |
| 13:30 - 14:00 | 30 min | Buffer | Reservado por si hay retraso o preguntas adicionales | — |

**Nota crítica:** el cliente insiste en el horario. Si un bloque se extiende, cortar Q&A intermedio y dejar todo para el bloque final de 90 minutos.

---

## 2. Pre-demo checklist (miércoles 2026-07-08 en la noche)

### 2.1 Acceso y sesión

- [ ] Login a la org `ins-qbranch-alfa` con el usuario demo (no admin, no personal).
- [ ] Verificar que el usuario está en locale `en_US` (los labels salen en inglés — dato importante para no sorprenderse en vivo). Menciónalo al cliente en la apertura: "los labels los verán en inglés porque es el standard de Salesforce, los datos están en español porque son cargados por nosotros".
- [ ] Confirmar que la sesión no expira: abrir Setup → Session Settings → verificar timeout ≥ 8 horas.
- [ ] Tener el usuario/contraseña anotados en un lugar accesible por si toca reingresar.
- [ ] Probar 2FA / SSO — que no salte MFA en medio de la demo.

### 2.2 Apps que deben estar accesibles

- [ ] **Product Catalog Management** (para Bloque 1) — App Launcher → los 9 puntos → buscar y abrir.
- [ ] **Insurance Agent Console** (para Bloques 2 y 3) — verificar que aparece en App Launcher.
- [ ] **Reports** y **Dashboards** (para Bloque 6) — accesibles como pestañas standard.
- [ ] Si alguna app no aparece, revisar App Permissions del perfil ANTES del jueves.

### 2.3 Verificación en vivo de cada bloque (hacerlo end-to-end)

**Bloque 1 — Producto:**
- [ ] Abrir https://storm-c90aab66569c63.my.salesforce.com/lightning/r/Product2/01tg8000003hS49AAE/view
- [ ] Confirmar que "Plan Empresarial" aparece con Type=Bundle.
- [ ] Click pestaña **Structure** y verificar árbol jerárquico Bundle → Component Groups (Coberturas, Establecimiento) → 6 coberturas.
- [ ] Click pestaña **Attributes** — verificar que se listan los 8 atributos.
- [ ] Abrir 1 cobertura hija (ej. Incendio y Aliados 01tg8000003hRo1AAE) y confirmar sus PADs.

**Bloque 2 — Póliza:**
- [ ] Abrir /lightning/r/InsurancePolicy/0YTg80000000hJVGAY/view — POL-PYME-2026-0001.
- [ ] Verificar header: Status=In Force, PremiumAmount=2.400.000, EffectiveDate=2026-06-01.
- [ ] Click **Policy Structure** — árbol Policy → 6 Coverages.
- [ ] Click **Related** — confirmar que Coverages aparecen (Transactions y Clauses NO aparecen aquí — es el gotcha conocido).
- [ ] Pre-abrir en tabs de fondo:
  - `/lightning/o/InsurancePolicyTransaction/list?filterName=Recent` (para mostrar las 2 transactions vía list view)
  - `/lightning/o/InsurancePolicyProductClause/list?filterName=Recent` (para mostrar las 6 clauses)
- [ ] Alternativa: abrir directo las 2 transactions y 6 clauses en tabs precargados.

**Bloque 3 — Siniestro:**
- [ ] Abrir /lightning/r/Claim/0Zkg80000000awLCAQ/view — SIN-PYME-2026-0001.
- [ ] Verificar Status=Coverage Confirmed, Severity=High, EstimatedAmount=48MM.
- [ ] Click pestañas: Details, Participants, Financials, Related — confirmar que cada una carga.
- [ ] Abrir ClaimCoverage CC-SIN-PYME-2026-0001-Incendio (0kPg80000000OITEA2) y verificar LossReserve=45MM + ExpenseReserve=5MM.
- [ ] Abrir CCPD-01 (0l2g80000000PfxAAE) — Paid 32MM.
- [ ] Abrir CCPD-02 (0l2g80000000PhZAAU) — Pending Authority, Draft.

**Bloque 6 — Reportería:**
- [ ] Abrir /lightning/r/Dashboard/01Zg8000001l9nFEAQ/view — Producción Pyme 2026.
- [ ] Click **Refresh** en el dashboard y esperar que carguen todos los widgets.
- [ ] Repetir para Renovaciones (01Zg8000001l9nGEAQ) y Siniestralidad (01Zg8000001l9nHEAQ).
- [ ] Reports app → Folder "Seguros ALFA Pyme" → confirmar los 11 reports listados.

### 2.4 Tabs a dejar abiertas en el navegador (orden secuencial)

Sugerencia: usar un solo navegador con las tabs ordenadas de izquierda a derecha en el orden de la demo. Chrome/Edge con grupos de tabs por color:

**Grupo Bloque 1 (azul):**
1. Plan Empresarial Product2 view
2. Structure ya abierta si es posible
3. 1 cobertura hija (Incendio y Aliados) de respaldo

**Grupo Bloque 2 (verde):**
4. POL-PYME-2026-0001 InsurancePolicy view
5. Policy Structure tab
6. InsurancePolicyTransaction list view
7. InsurancePolicyProductClause list view
8. Clause "Coaseguro 10%" (1VGg800000008QbGAI) — la única manual, buena historia

**Grupo Bloque 3 (rojo):**
9. Claim SIN-PYME-2026-0001
10. ClaimCoverage CC-SIN-PYME-2026-0001-Incendio
11. ClaimCoveragePaymentDetail CCPD-01 (Paid)
12. ClaimCoveragePaymentDetail CCPD-02 (Draft)

**Grupo Bloque 6 (amarillo):**
13. Dashboard Producción Pyme 2026
14. Dashboard Renovaciones Pyme 2026
15. Dashboard Siniestralidad Pyme 2026
16. Reports folder "Seguros ALFA Pyme"

**Total: 16 tabs pre-cargadas.** No más — el navegador se pone lento y confunde.

### 2.5 Screenshots de respaldo

Para cada bloque, tener 3-5 screenshots pre-tomados en un folder local por si la org tiene lag o cae en medio de la demo. Formato sugerido:

- `~/demo-alfa/bloque1/01-plan-empresarial-structure.png`
- `~/demo-alfa/bloque1/02-cobertura-incendio-pads.png`
- `~/demo-alfa/bloque2/01-policy-header.png`
- `~/demo-alfa/bloque2/02-policy-structure.png`
- `~/demo-alfa/bloque2/03-transactions-list.png`
- `~/demo-alfa/bloque2/04-clauses-manual-vs-auto.png`
- `~/demo-alfa/bloque3/01-claim-header.png`
- `~/demo-alfa/bloque3/02-claim-participants.png`
- `~/demo-alfa/bloque3/03-claim-coverage-reservas.png`
- `~/demo-alfa/bloque3/04-payment-details.png`
- `~/demo-alfa/bloque6/01-dashboard-produccion.png`
- `~/demo-alfa/bloque6/02-dashboard-siniestralidad.png`
- `~/demo-alfa/bloque6/03-reports-folder.png`

Si algo falla en vivo: "Déjenme mostrarles una captura de esta misma pantalla que tomamos ayer, mientras recargamos".

### 2.6 Repaso de los 4 runbooks

- [ ] `RUNBOOK_BLOQUE_1.md` — leído completo y ejecutado paso a paso al menos una vez.
- [ ] `RUNBOOK_BLOQUE_2.md` — leído completo, especial atención al gotcha de Transactions/Clauses fuera del layout.
- [ ] `RUNBOOK_BLOQUE_3.md` — leído completo, entender la historia de reserva + un pago hecho + otro pendiente autoridad.
- [ ] `RUNBOOK_BLOQUE_6.md` — leído completo, saber refrescar dashboards.

### 2.7 Datos financieros de memoria (para no dudar en vivo)

Grabarse estos números:

- **Prima total póliza POL-PYME-2026-0001:** 2.400.000 COP
- **Desglose:** Incendio 800k + RC 600k + Robo 400k + Equipo 300k + Rotura 200k + Sustracción 100k = 2.400.000 ✓
- **Vigencia:** 2026-06-01 a 2027-05-31
- **Siniestro estimado:** 48.000.000 COP
- **Reserva total constituida:** 50.000.000 COP (45 pérdida directa + 5 lucro cesante)
- **Pagado a la fecha:** 32.000.000 COP (horno)
- **Pendiente autorización:** 8.000.000 COP (lucro cesante)

Si el cliente pregunta "¿por qué la reserva (50MM) es mayor al estimado (48MM)?" — respuesta: "porque la reserva incluye gastos de ajuste y contingencia sobre el daño directo estimado, es práctica actuarial standard".

---

## 3. Pre-demo checklist (jueves 2026-07-09 a las 7:00)

- [ ] Cargar computadora al 100%. Cable de corriente conectado durante toda la demo.
- [ ] Conexión a internet: cable de red preferido sobre WiFi. Si no hay cable, hotspot móvil de respaldo.
- [ ] Cerrar Slack, correo, notificaciones — modo No Molestar activado en macOS.
- [ ] Login fresco a la org — evitar sesiones de la noche anterior que puedan haber expirado.
- [ ] Re-abrir las 16 tabs del checklist 2.4.
- [ ] Refrescar los 3 dashboards de Bloque 6 (para que en vivo no haya que esperar el refresh).
- [ ] Verificar zoom del navegador al 100% (o 110% si se ve chico compartiendo pantalla).
- [ ] Ocultar barra de bookmarks para tener más espacio vertical.
- [ ] Tener este archivo INDICE abierto en un monitor secundario o impreso.
- [ ] Tener los 4 runbooks abiertos también en el monitor secundario.
- [ ] Botella de agua al lado.
- [ ] 7:45 abrir Teams, unirse a la reunión, probar audio y video.
- [ ] 7:50 compartir pantalla, verificar que el cliente ve la pantalla correcta (no la del monitor secundario).
- [ ] 7:55 mensaje de saludo, esperar que ingresen los del cliente.
- [ ] 8:00 arrancar puntual.

---

## 4. Contexto para presentar al inicio (8:00 - 8:15)

### 4.1 Frase de apertura sugerida

> "Buenos días equipo Seguros ALFA. Soy Luis Fabián Rodríguez, Solution Engineer de Salesforce. Los acompaño hoy en esta sustentación técnica del RFP donde vamos a mostrarles evidencia funcional real, corriendo sobre una org de Salesforce Insurance on Core configurada específicamente para el caso Pyme que ustedes plantearon. No van a ver slides con capturas — van a ver el producto funcionando en vivo, con datos, con flujos, con lógica de negocio ejecutándose."

### 4.2 Aclaración de locale (importante hacerla temprano)

> "Un dato antes de empezar: mi usuario demo está en inglés porque es el standard de Salesforce y no queríamos localizar labels que después ustedes puedan querer ajustar a su manera. Verán términos como 'Insurance Policy', 'Claim', 'Coverage' — todos los datos que cargamos (nombres de productos, coberturas, cláusulas, siniestros) están en español porque son los datos de negocio. Cuando ustedes reciban su org, definimos juntos qué queda en inglés y qué se traduce."

### 4.3 Alcance de la sustentación — qué se cumple y qué no

> "En el RFP definimos originalmente 6 bloques de demostración. Hoy vamos a cumplir 4 de esos bloques con demo funcional completa, y quiero ser transparente sobre los otros 2 desde el inicio."

**Bloques que se cumplen hoy con demo en vivo:**

1. **Bloque 1 — Configuración de producto Pyme modular y por planes:** verán cómo se configura un producto Bundle con coberturas simples, atributos, y clasificaciones.
2. **Bloque 2 — Ciclo completo de una póliza:** cotización, emisión, endoso, y cláusulas contractuales (incluye lo que originalmente era el Bloque 5 sobre InsuranceClauses).
3. **Bloque 3 — Siniestros:** apertura, participantes, ítems dañados, reservas, pagos parciales, workflow de autorización.
4. **Bloque 6 — Reportería y tableros:** 3 dashboards ejecutivos y 11 reports operativos.

**Bloques que NO se demuestran hoy (declaración honesta):**

5. **Bloque 4 — Reaseguros:** funcionalidad presente en Salesforce Insurance on Core, pero no configurada en esta org de sustentación. Roadmap de implementación en fase 2.
6. **Bloque 5 original — Facturación:** el módulo de facturación de Salesforce (Revenue Cloud / Salesforce Billing) se integra con Insurance on Core pero requiere licenciamiento adicional. Se cubre como componente de la arquitectura objetivo pero no como demo funcional hoy.

> "Preferimos ser directos con esto en lugar de improvisar. Al final tenemos 90 minutos de Q&A abierto donde podemos entrar en detalle de cualquier bloque, incluidos los dos que no demostramos hoy."

### 4.4 Estructura de cada bloque

> "Cada bloque va a seguir la misma estructura: contexto de negocio (¿qué problema resuelve?), demo funcional en vivo (¿cómo se ve corriendo?), y arquitectura técnica (¿cómo está construido debajo?). Al final de cada bloque hay 3-5 minutos para preguntas puntuales; las preguntas más profundas las guardamos para el Q&A de las 11:30."

---

## 5. Índice de runbooks

Los 4 runbooks son la guía paso-a-paso literal para ejecutar cada bloque. Luis Fabián: leerlos completos antes del jueves.

| Archivo | Bloque | Duración | 1-liner |
|---------|--------|----------|---------|
| `RUNBOOK_BLOQUE_1.md` | Bloque 1 — Producto | 30 min | Cómo mostrar Plan Empresarial (Bundle) con 6 coberturas Simple, 8 atributos, 2 ProductClassifications, y 2 ProductComponentGroups; ruta canónica App Launcher → Product Catalog Management → Products → Plan Empresarial → pestaña Structure. |
| `RUNBOOK_BLOQUE_2.md` | Bloque 2 — Póliza | 30 min | Cómo mostrar POL-PYME-2026-0001 con sus 6 coverages, 2 transactions (Emisión + Endoso), 6 clauses (5 auto + 1 manual Coaseguro 10%); incluye workaround para que Transactions y Clauses se vean pese a que el layout default no las expone. |
| `RUNBOOK_BLOQUE_3.md` | Bloque 3 — Siniestro | 45 min | Cómo mostrar SIN-PYME-2026-0001 con 3 participants, 3 items, 1 ClaimCoverage con reservas de 50MM, 2 payment details (32MM Paid + 8MM Pending Authority), y ClaimPaymentSummary en Pending Payment. |
| `RUNBOOK_BLOQUE_6.md` | Bloque 6 — Reportería | 30 min | Cómo mostrar los 3 dashboards (Producción / Renovaciones / Siniestralidad Pyme 2026) y los 11 reports en folder "Seguros ALFA Pyme"; qué report cierra la narrativa de siniestros conectando con Bloque 3. |

Los runbooks están al mismo nivel que este archivo en el proyecto Grupo Aval Insurance de Nehuen. Coordinar con él por Slack si no los encuentras.

---

## 6. Q&A abierto al final (11:30 - 13:00, 90 min)

### 6.1 Formato sugerido

- 5 min introducción: "abrimos el espacio para preguntas de cualquier bloque, de arquitectura general, o de features que no cubrimos hoy".
- Preguntas del cliente en orden de llegada.
- Si nadie pregunta primero, tener 2-3 preguntas prefabricadas para lanzar: "una duda que suele salir en implementaciones similares es X — ¿es algo que también les interesa?".

### 6.2 Cómo pivotar cuando el cliente pregunta features no cubiertas

**Preguntas frecuentes anticipadas y respuesta modelo:**

**"¿Cómo funcionaría Reaseguros en Salesforce?"**
> "Salesforce Insurance on Core tiene el modelo de datos completo para Reaseguros: contratos de cesión, treaties proporcionales y no proporcionales, retrocesión, siniestros compartidos. En esta org de sustentación no está poblado con datos, pero podemos agendar una sesión técnica específica la próxima semana donde les mostramos el modelo activado en otra org. Nehuen queda como punto de contacto para coordinar eso."

**"¿Facturación y cobranza cómo se integra?"**
> "Hay dos caminos: Salesforce Revenue Cloud (nuevo, unificado billing + subscriptions) que se integra nativamente con Insurance on Core, o integración con el core financiero que ustedes tengan hoy (SAP, Oracle) vía MuleSoft. Cualquiera de las dos rutas es soportada. La elección depende del roadmap de modernización del core que ustedes tengan definido — tema para una conversación de arquitectura con nuestro equipo de Solutions."

**"¿Se puede integrar con nuestro core actual?"**
> "Sí, y hay 3 patrones probados: (1) Sync bidireccional en tiempo real vía MuleSoft o Platform Events para operaciones críticas como emisión y siniestros; (2) Batch con file drops si son procesos menos críticos; (3) Federación de datos vía Salesforce Connect si no quieren replicar. Cuál usar depende de los SLAs y de qué es sistema de registro para cada dominio de datos."

**"¿Data Cloud / IA / Einstein?"**
> "Todo lo que vieron hoy está listo para conectarse a Data Cloud para consolidar datos de otros sistemas, y a Einstein / Agentforce para casos como pricing dinámico, detección de fraude en siniestros, y asistentes de suscripción. No lo demostramos hoy porque el foco del RFP era core insurance, pero está en el mismo stack y no requiere migración adicional. Puedo agendar una sesión dedicada de Agentforce for Insurance si les interesa."

**"¿Cuánto cuesta?"**
> "El comercial de este componente lo maneja el AE de la cuenta [nombre]. Yo estoy hoy en rol técnico y prefiero no dar cifras informales que puedan sesgar la decisión. Podemos coordinar una sesión comercial con el AE esta misma semana."

**"¿Y si nuestro reto es X (feature no cubierta en la demo)?"**
> Respuesta estándar: "Buena pregunta. En el ecosistema Salesforce Insurance on Core, X se resuelve típicamente con [approach genérico]. No lo tenemos configurado en esta org de sustentación porque el foco fue el ciclo Pyme end-to-end, pero es un caso conocido y tenemos referencias de clientes en la región que lo tienen implementado. Podemos agendar una sesión focalizada en ese caso."

### 6.3 Cómo posicionar el roadmap sin comprometer fechas

- Nunca decir "eso lo tendremos listo en Q2" en un demo.
- Sí decir: "eso está en el producto hoy" o "eso está en roadmap público del producto — el equipo de producto de Salesforce publica el roadmap en Trailblazer Community".
- Si el cliente pide compromiso: "puedo llevar la pregunta al equipo de producto y traerles respuesta oficial la próxima semana".

### 6.4 Cómo cerrar el Q&A

- 12:55: "vamos a tomarnos 5 minutos para responder las últimas 2-3 preguntas y luego pasamos a cierre y próximos pasos".
- 13:00: "gracias por las preguntas. Antes de despedirnos, quiero pasar rápido por los próximos pasos".
- 13:00 - 13:30 cierre: entregables (grabación, deck complementario, propuesta de arquitectura), timeline de decisión que el cliente proponga, siguiente reunión.

---

## 7. Manejo de crisis en vivo

### 7.1 Si la org no carga

1. Refrescar (Cmd+R). Si tarda >10 seg, no esperar.
2. "Vamos a apoyarnos un momento en una captura mientras la plataforma responde" — sacar screenshot del folder `~/demo-alfa/`.
3. Continuar la narrativa mientras se recupera.
4. Si a los 3 min sigue caída: mensaje discreto por Slack a Nehuen y cambiar orden de bloques (empezar por Bloque 6 dashboards que están en caché).

### 7.2 Si el cliente hace una pregunta que no sabes contestar

- "Excelente pregunta. Prefiero validarla con el equipo de producto en vez de improvisar. La anoto y te vuelvo con respuesta oficial esta semana."
- Anotarla literal en un cuaderno visible.
- No inventar. El cliente valora honestidad más que omnisciencia.

### 7.3 Si el cliente insiste en un bloque no cubierto (Reaseguros / Facturación)

- No improvisar demo en vivo. La org no tiene esa data.
- "Prefiero mostrártelo con calidad en una sesión dedicada la próxima semana en lugar de improvisar acá. Nehuen coordina la fecha."

### 7.4 Si el tiempo se corre

- Prioridad de bloques por importancia estratégica del RFP: 2 > 3 > 1 > 6.
- Si Bloque 1 se extiende: cortar en la vista de atributos, no mostrar los 8 en detalle.
- Si Bloque 2 se extiende: mostrar solo 1 clause manual (Coaseguro 10%) y 1 transaction, no las 2.
- Si Bloque 3 se extiende: cortar en pagos, no entrar a Action Plan ni Claim Team.
- Si Bloque 6 se extiende: mostrar solo Siniestralidad Pyme 2026 (el más visual) y saltar los otros 2.

---

## 8. Contacto de emergencia

**Nehuen Lihue Lobo** — Slack DM directo durante toda la demo.

Nehuen tiene acceso admin a la org y puede:
- Ejecutar SOQL en vivo si un dato aparece mal.
- Regenerar records si algo se corrompió.
- Confirmar IDs, valores, campos si dudas.
- Responder por chat mientras Luis Fabián sigue hablando en vivo.

**Regla:** durante la demo, si algo se ve raro, no lo corrijas frente al cliente. Continúa, y mensaje a Nehuen por Slack. Él resuelve en segundo plano.

**Recordatorio:** Laura está en PTO. No la contactes a menos que sea absolutamente crítico y Nehuen no responda en 5 min.

---

## 9. Después de la demo (jueves 13:30 - 14:00 y viernes)

### 9.1 Cierre en la sesión

- Confirmar próximos pasos con fechas concretas.
- Pedir feedback rápido: "¿Qué bloque les generó más impacto? ¿Qué queda por profundizar?".
- Confirmar destinatarios del follow-up.

### 9.2 Follow-up viernes 2026-07-10

- Enviar por correo: grabación de la sesión (Teams la genera automáticamente).
- Enviar los 4 runbooks convertidos a PDF (opcional, si el cliente los pidió).
- Enviar preguntas pendientes con respuestas oficiales.
- Confirmar próxima reunión.

### 9.3 Post-mortem interno con Nehuen (viernes o lunes)

- Qué funcionó, qué falló, qué mejorar para próximas sustentaciones.
- Actualizar los runbooks con lecciones aprendidas.
- Documentar preguntas nuevas del cliente que no estaban anticipadas.

---

## 10. Checklist final de 1 hora antes (jueves 7:00 - 8:00)

- [ ] Café / desayuno.
- [ ] Repaso rápido de este INDICE (10 min).
- [ ] Repaso rápido de los 4 runbooks (20 min, hojear no leer entero).
- [ ] Todas las 16 tabs abiertas y verificadas.
- [ ] Screenshots de respaldo accesibles.
- [ ] Nehuen confirmado en Slack como disponible.
- [ ] Teams abierto con la sala de la reunión lista.
- [ ] Cámara y micrófono probados.
- [ ] Pantalla compartida configurada.
- [ ] Sonrisa. Van a estar bien.

---

**Última actualización:** 2026-07-07 (Nehuen Lobo).
**Próxima revisión:** miércoles 2026-07-08 en la noche con Luis Fabián.
