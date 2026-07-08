# Runbook — Bloque 1: Configuración de Producto Pyme modular y por planes

**Duración asignada**: 48 min *(catálogo + configurador + Issue Policy + pricing + rules + publicación, todo en vivo)* | **Ejecutor**: Luis Fabián | **Org**: ins-qbranch-alfa
**Fecha sustentación**: jueves 2026-07-09, 8:00–14:00 hora Colombia (Teams)
**Slot del bloque**: 8:00 – 8:48 (primer bloque, apertura de la demo). Se apretaron ~18 min de la Q&A abierta del cierre para dar espacio a cotización en vivo + configuración de tarifas + reglas de suscripción + publicación del producto.

---

## 0. Setup pre-demo (hacer 15 min antes)

### 0.1 Login al org

1. Abrir Chrome (o el browser preferido) en modo ventana normal — **NO** incógnito, para que las tabs queden abiertas y precargadas.
2. Ir a: `https://storm-c90aab66569c63.my.salesforce.com`
3. Loguearse con el usuario demo estándar de ins-qbranch-alfa. Confirmar que el locale del usuario es `en_US` (los labels standard salen en inglés — se contextualiza verbalmente).
4. Verificar en la esquina superior derecha que el nombre del usuario aparece y que estamos en la app correcta.

### 0.2 Tabs a precargar (7 tabs, en este orden de izquierda a derecha)

Abrir cada URL en una tab nueva y dejarlas cargadas. Esto evita esperar cargas en vivo frente al cliente.

| # | Tab | URL |
|---|-----|-----|
| 1 | Plan Empresarial (Bundle raíz) | `https://storm-c90aab66569c63.my.salesforce.com/lightning/r/Product2/01tg8000003hS49AAE/view` |
| 2 | Cobertura RC Extracontractual | `https://storm-c90aab66569c63.my.salesforce.com/lightning/r/Product2/01tg8000003hRmPAAU/view` |
| 3 | Cobertura Incendio y Aliados | `https://storm-c90aab66569c63.my.salesforce.com/lightning/r/Product2/01tg8000003hRo1AAE/view` |
| 4 | Cobertura Equipo Electrónico | `https://storm-c90aab66569c63.my.salesforce.com/lightning/r/Product2/01tg8000003hRpdAAE/view` |
| 5 | Classification Cobertura Pyme | `https://storm-c90aab66569c63.my.salesforce.com/lightning/r/ProductClassification/11Bg800000DRh4bEAD/view` |
| 6 | Attribute Suma Asegurada | `https://storm-c90aab66569c63.my.salesforce.com/lightning/r/AttributeDefinition/0tjg8000000DPYTAA4/view` |
| 7 | App Launcher — Product Catalog Management | `https://storm-c90aab66569c63.my.salesforce.com/lightning/page/home` (y desde ahí abrir la app) |

### 0.3 Verificar visualmente antes de compartir pantalla

En la tab 1 (Plan Empresarial), confirmar que:

- El nombre del record es **Plan Empresarial**.
- Hay una barra de pestañas horizontales que incluye estas 9 pestañas (el orden exacto que renderiza Salesforce puede variar levemente según el page layout y el ancho de ventana): `Related`, `Details`, `Attributes`, `Attribute Scopes`, `Structure`, `Translations`, `Surcharges`, `Exclusions`, `Rules`.
- **Importante sobre las pestañas**: si el zoom del browser está muy alto o la ventana no está maximizada, algunas pestañas pueden quedar cortadas y aparecer detrás de un ícono `>` (chevron / "More Tabs") al final de la barra. Antes de compartir pantalla:
  - Verificar que **Structure** esté visible directamente en la barra (no oculto detrás del `>`).
  - Si Structure no se ve, bajar el zoom al 100% o maximizar la ventana hasta que aparezca.
  - Como alternativa, hacer click en el `>` para desplegar las pestañas ocultas y confirmar que Structure está ahí — pero no es lo ideal para la demo (rompe el flujo visual).
- Click en la pestaña `Structure` — debe mostrar el árbol jerárquico con:
  - **Plan Empresarial** (raíz)
    - **Coberturas** (Component Group)
      - las 6 coberturas Simple
    - **Establecimiento** (Component Group)

Si el árbol de `Structure` no carga en 5 segundos, hacer refresh (Ctrl/Cmd + R) antes de la demo. **No** hacer refresh en vivo — se ve mal.

### 0.4 Cerrar distractores

- Cerrar Slack, correo, notificaciones del sistema operativo.
- Poner el celular en silencio.
- Zoom del browser al **100–110%** (subir a 125% solo si con eso las 9 pestañas siguen todas visibles sin colapsar detrás del `>`). Priorizar tabs visibles sobre tamaño de letra.

### 0.5 Cheat sheet mental (imprimir o tener en post-it)

- Bundle raíz: **Plan Empresarial** (código: `segPymeEmpresarial`).
- 6 coberturas: **RC Extracontractual, Incendio y Aliados, Equipo Electrónico, Robo y Asalto Interior, Rotura de Maquinaria, Sustracción de Dinero y Valores**.
- 2 Component Groups: **Coberturas** y **Establecimiento**.
- 2 Classifications: **Cobertura Pyme** y **Establecimiento Comercial**.
- 8 Attributes clave: Suma Asegurada (picklist), Deducible, Actividad Económica, Rango Empleados, Metros Cuadrados Local, Porcentaje Coaseguro, Deducible Mínimo Evento, Sustancias Prohibidas.
- **48 PADs totales** entre las 6 coberturas → **8 atributos promedio por cobertura**. Si al abrir una cobertura en la pestaña Attributes ves menos de 6 o más de 12, algo está raro con esa data — pasar a otra cobertura.

---

## 1. Contexto y objetivo del bloque (30 seg)

En este primer bloque vamos a demostrar cómo Insurance on Core, sobre el módulo Product Catalog Management, permite configurar un producto Pyme **modular y por planes** — sin código, 100% en configuración estándar. Vamos a mostrar el bundle **Plan Empresarial** con sus 6 coberturas componentes, cómo se agrupan por Component Groups, cómo heredan atributos vía Product Classifications, y cómo cada cobertura tiene sus propios atributos técnicos (suma asegurada, deducible, coaseguro, etc.). Esto le da a ALFA la base para armar cualquier plan comercial nuevo reusando componentes existentes, sin duplicar catálogo.

---

## 2. Click path paso a paso

### Paso 2.1 — Abrir el catálogo de productos desde App Launcher (2 min)

**Click / navegación:**

1. Ir a la tab del browser donde tenés abierto Salesforce (tab 7 si venís del setup pre-demo, o cualquier tab con Lightning).
2. Click en el **App Launcher** — el ícono de los 9 puntos en la esquina superior izquierda (junto al logo de Salesforce).
3. En el buscador que aparece, escribir: `Product Catalog Management`.
4. Click en la app **Product Catalog Management** que aparece en los resultados.
5. Una vez dentro de la app, click en la pestaña **Products** (arriba, en la barra de navegación).
6. Verás en pantalla: una lista de productos (Product2) con columnas como Name, Product Code, Type, Active.

**Qué decir (talk track):**

> "Antes de entrar al producto en sí, quiero mostrarles dónde vive todo. Insurance on Core nos entrega esta aplicación estándar — **Product Catalog Management** — que es donde el equipo de producto de ALFA va a modelar todo el catálogo de seguros: los planes, las coberturas, los atributos, las clasificaciones. Es una app nativa de Salesforce, no una customización nuestra. Todo lo que van a ver hoy se configura acá, sin código."

**Puntos de énfasis:**

- Recalcar "app estándar de Insurance on Core" — el cliente valora que no sea desarrollo custom.
- Mencionar que el mismo catálogo alimenta cotización, emisión y siniestros (adelanto al bloque 2).

**Si algo no aparece:**

- Si `Product Catalog Management` no aparece en App Launcher, escribir directamente `Products` — la tab de Products también está disponible desde la app Sales o Service. Pero es preferible la app dedicada.
- Si la lista de Products sale vacía, cambiar el list view a **All Products** desde el dropdown de list views (arriba a la izquierda del listado).

---

### Paso 2.2 — Abrir el Bundle Plan Empresarial y mostrar los campos clave (3 min)

**Click / navegación:**

1. En la lista de Products, buscar en el campo de búsqueda (arriba del listado): `Plan Empresarial`.
2. Click en el link del producto **Plan Empresarial**.
   - Alternativa rápida: si el buscador tarda, usar directamente la tab precargada 1 (URL `/lightning/r/Product2/01tg8000003hS49AAE/view`).
3. Ya estás en el record de **Plan Empresarial**.
4. Click en la pestaña **Details** (segunda pestaña, junto a Related).
5. Verás en pantalla:
   - **Product Name**: Plan Empresarial
   - **Product Code**: `segPymeEmpresarial`
   - **Type**: `Bundle`
   - **Family**: `Miscellaneous`
   - **Active**: ✓ (checked)
   - Nota interna (no en pantalla del user demo): a nivel API el campo `ProductClass` también está en `Bundle`, pero es un campo system-derived que no aparece en el Product Layout estándar — solo se ve en el layout "FINS Broker Product Layout".

**Qué decir (talk track):**

> "Este es el corazón del bloque: **Plan Empresarial**. Fíjense en el campo **Type = Bundle**. Eso le dice a la plataforma que este producto no se vende suelto — es un contenedor que agrupa coberturas. Es exactamente lo que ALFA pidió en el RFP: un plan comercial armable, modular, que empaqueta componentes reutilizables. El código `segPymeEmpresarial` es el identificador único global — con ese código lo consumen las APIs, los flujos de cotización, todo."

**Puntos de énfasis:**

- Insistir en que **Type=Bundle** es lo que habilita el comportamiento modular (la plataforma internamente marca `ProductClass=Bundle`, campo derivado no expuesto en el layout estándar).
- Mencionar que el `ProductCode` es único global — importante para integraciones (adelanto al bloque de integración conceptual).

**Si algo no aparece:**

- Si la pestaña `Details` no muestra los campos, hacer click en **Show More** o revisar que el page layout esté correcto (poco probable, pero si pasa, saltar a Structure y volver después).

---

### Paso 2.3 — Mostrar la estructura jerárquica: pestaña Structure (5 min) [MOMENTO CENTRAL DEL BLOQUE]

**Click / navegación:**

1. Estando en el record de Plan Empresarial, click en la pestaña **Structure**.
   - Si no ves la pestaña Structure directamente en la barra, hacer click en el ícono `>` al final de la barra de pestañas (More Tabs) y seleccionarla desde ahí. Idealmente esto ya se resolvió en el setup 0.3 ajustando zoom.
2. Esperar 2-3 segundos a que renderice el árbol.
3. Verás en pantalla: un árbol jerárquico con esta forma:
   ```
   Plan Empresarial (Bundle)
   ├── Coberturas (Component Group)
   │   ├── Responsabilidad Civil Extracontractual
   │   ├── Incendio y Aliados
   │   ├── Equipo Electrónico
   │   ├── Robo y Asalto Interior
   │   ├── Rotura de Maquinaria
   │   └── Sustracción de Dinero y Valores
   └── Establecimiento (Component Group)
   ```
4. Click en el ícono `>` o expandir cada Component Group si están colapsados.
5. Click en la cobertura **Responsabilidad Civil Extracontractual** dentro del árbol para expandirla — muestra que es un producto Simple.

**Qué decir (talk track):**

> "Acá está la evidencia funcional que ALFA pidió. Este árbol es 100% configuración — cero código. Vean cómo el **Plan Empresarial** contiene dos grupos de componentes: **Coberturas** — donde viven las 6 coberturas técnicas — y **Establecimiento**, que agrupa los datos del local del cliente. Cada cobertura es un producto independiente, con su propia vida, su propio código, sus propios atributos, sus propias reglas. Pero se orquestan bajo el bundle. Si mañana ALFA quiere lanzar un **Plan Pyme Básico** con solo 3 coberturas de estas 6, lo arma en minutos reutilizando los mismos componentes. No hay que duplicar nada."

**Puntos de énfasis:**

- Señalar con el cursor cada nivel de la jerarquía mientras se habla.
- **NO** clickear demasiado rápido — dejar que el árbol se lea.
- Enfatizar "reutilización" — es el diferencial vs. tener un producto plano y copiar.
- Si el cliente pregunta por el orden de las coberturas, mencionar que está gobernado por el campo `Sequence` en ProductRelatedComponent.

**Si algo no aparece:**

- Si el árbol tarda >5 segundos, hacer refresh de la página **una sola vez** y explicar: "Estamos en un org de storm compartido, a veces la primera carga es lenta."
- Si un Component Group aparece vacío, ir a la pestaña **Related** y buscar la related list **Product Related Components** — desde ahí se ven las 7 relaciones planas (6 coberturas + 1 Establecimiento).

---

### Paso 2.4 — Abrir una cobertura y mostrar sus atributos (5 min)

**Click / navegación:**

1. Desde el árbol de Structure, hacer click derecho en **Responsabilidad Civil Extracontractual** → "Abrir en pestaña nueva" — o, más simple, cambiar a la tab precargada 2 (URL `/lightning/r/Product2/01tg8000003hRmPAAU/view`).
2. Verás el record de la cobertura.
3. Click en la pestaña **Details** — mostrar:
   - **Product Name**: Responsabilidad Civil Extracontractual
   - **Product Code**: `rcExtracontractual`
   - **Type**: `(vacío)` — es una cobertura Simple, componente atómico que se vende solo empaquetado en un bundle. El sistema autoderiva `ProductClass=Simple`, aunque ese campo no está en el layout estándar.
   - **Active**: ✓
4. Click en la pestaña **Attributes**.
5. Verás una lista de atributos del producto. **Esperado: ~8 atributos por cobertura** (48 PADs totales / 6 coberturas). Los atributos típicos que deben aparecer son:
   - Suma Asegurada
   - Deducible
   - Actividad Económica
   - Rango de Empleados
   - Metros Cuadrados Local
   - Porcentaje Coaseguro
   - Deducible Mínimo por Evento
   - Sustancias Prohibidas
6. **Sanity check en vivo**: contar mentalmente los atributos. Si ves menos de 6 o más de 12, la data de esa cobertura está anómala — no te detengas, cambiá a otra cobertura desde una de las tabs precargadas (3 = Incendio, 4 = Equipo Electrónico).

**Qué decir (talk track):**

> "Entramos ahora a una cobertura individual — **Responsabilidad Civil Extracontractual**. Esta es una cobertura **Simple** — atómica, componente. Noten que el campo **Type** está vacío: eso es intencional, porque las coverages heredan su comportamiento del bundle padre. Internamente la plataforma la clasifica como `ProductClass=Simple`, que es lo que ata el catálogo modular. Es un componente vendible pero solo empaquetado en un bundle. En la pestaña **Attributes** vemos los atributos técnicos que capturan la parametrización de esta cobertura — aproximadamente 8 atributos: **Suma Asegurada**, **Deducible**, **Porcentaje de Coaseguro**, **Deducible Mínimo por Evento**, **Actividad Económica**, entre otros. Estos atributos son los que el asesor comercial o el motor de cotización va a completar cuando se emita la póliza — que es lo que vamos a ver en el bloque 2."

**Puntos de énfasis:**

- Mencionar que hay **48 Product Attribute Definitions** totales entre las 6 coberturas — **promedio 8 por cobertura**. Es un número redondo, fácil de recordar y de citar.
- Señalar que **Suma Asegurada** es de tipo **Picklist** — se manejan valores predefinidos, no numérico libre. Esto le da a ALFA control comercial sobre los tramos de suma asegurada.

**Si algo no aparece:**

- Si la pestaña `Attributes` sale vacía, ir a la pestaña `Related` y buscar la related list **Product Attribute Definitions**.
- Si hay attributes esperados que no aparecen, no detenerse — mencionar solo los que sí están y avanzar.
- Si el count total de atributos difiere significativamente de 8, no citar el número exacto en la demo — decir "varios atributos técnicos" y seguir.

---

### Paso 2.5 — Mostrar el detalle de un Attribute Definition (Suma Asegurada) (4 min)

**Click / navegación:**

1. En la pestaña Attributes de la cobertura, click en el link **Suma Asegurada** (la columna Attribute o Name).
   - Alternativa: cambiar a la tab precargada 6 (URL `/lightning/r/AttributeDefinition/0tjg8000000DPYTAA4/view`).
2. Ya estás en el record de la Attribute Definition **Suma_Asegurada**.
3. Mostrar los campos clave en Details:
   - **Developer Name**: `Suma_Asegurada`
   - **Data Type**: `Picklist`
   - **Picklist**: link al Picklist ID `0v5g8000000DSuXAAW`
4. Click en el link del Picklist para mostrar los valores predefinidos (tramos de suma asegurada — típicamente COP 50M, 100M, 250M, 500M, 1.000M, etc.).

**Qué decir (talk track):**

> "Los atributos no son campos custom sueltos — son objetos de primera clase en Salesforce, con su ciclo de vida, su gobierno, su reutilización. Esta **Suma Asegurada** es una Attribute Definition centralizada: se define **una vez** y se reusa en cuantas coberturas la necesiten. Y como es **Picklist**, ALFA controla comercialmente los tramos de valor asegurado disponibles — el asesor no puede meter cualquier número. Si mañana cambian los tramos, se cambia acá y se propaga a todas las coberturas que lo usan. Es la definición de gobierno de catálogo."

**Puntos de énfasis:**

- Enfatizar **"se define una vez, se reusa"** — patrón clásico de reutilización.
- Mencionar que hay otros DataTypes disponibles: Number, Text, Date, Boolean — no solo Picklist. Cada atributo elige el tipo apropiado.
- Si hay tiempo, abrir un atributo tipo Number (Deducible, ID `0tjg8000000DPa5AAG`) para contrastar.

**Si algo no aparece:**

- Si el link al Picklist no funciona, describir verbalmente: "El Picklist tiene N valores predefinidos configurados por el equipo de producto."
- No entrar a editar el picklist — solo mostrar.

---

### Paso 2.6 — Mostrar los Product Classifications (herencia de atributos) (4 min)

**Click / navegación:**

1. Cambiar a la tab precargada 5 (URL `/lightning/r/ProductClassification/11Bg800000DRh4bEAD/view`).
2. Verás el record **Cobertura Pyme** (Product Classification).
3. Mostrar los campos clave en Details:
   - **Name**: Cobertura Pyme
   - **Code**: `coberturaPyme`
   - **Status**: `Active`
4. Click en la pestaña **Related** (o desplazarse hacia abajo).
5. **Buscar la related list de atributos** — el label exacto no está pre-verificado en la org y puede aparecer con distintos nombres según la versión del managed package de Insurance on Core:
   - Candidatos posibles: `Product Classification Attributes`, `Classification Attributes`, `Attributes`, `Product Attribute Definitions` (esta última si la related list está compartida entre Product y Classification).
   - **Cómo actuar en vivo**: recorrer la lista de related lists con la vista (no leer los nombres uno por uno frente al cliente). Si ves una que contiene atributos, hacer click y mostrar. Si no encontrás ninguna evidente en 5 segundos, **saltar** a plan B (abajo).
6. Buscar la related list **Products** o **Products with this Classification** — mostrar los productos que usan esta clasificación (deberían aparecer varias de las 6 coberturas).

**Plan B (si no encontrás la related list de atributos en Cobertura Pyme):**

- No detenerse buscando. Frase puente: *"Los atributos que hereda esta clasificación son los mismos que ya vimos en la cobertura — Suma Asegurada, Deducible, Coaseguro, etc. La clasificación es el mecanismo de propagación, y ya lo vimos materializado en cada cobertura."*
- Volver a la tab de la cobertura RC Extracontractual (tab 2) → pestaña Attributes — usar esos 8 atributos como evidencia visual de la herencia.
- Alternativa: abrir la tab del Attribute Definition Suma Asegurada (tab 6) y explicar que ese mismo attribute está referenciado por la clasificación Cobertura Pyme y por eso aparece en las 6 coberturas.

**Qué decir (talk track):**

> "Este es un patrón de gobierno importantísimo. Las **Product Classifications** son plantillas de atributos: en vez de asignar los mismos 8 atributos manualmente a cada una de las 6 coberturas, definimos una clasificación **Cobertura Pyme** con esos atributos, y cada cobertura hereda automáticamente. Si mañana ALFA quiere agregar un nuevo atributo — por ejemplo, **Zona de Riesgo Sísmico** — lo agregan a la clasificación una sola vez, y las 6 coberturas lo reciben. Esto reduce drásticamente el mantenimiento del catálogo. Tenemos dos clasificaciones activas: **Cobertura Pyme** y **Establecimiento Comercial**, alineadas con los dos Component Groups que vimos en el árbol."

**Puntos de énfasis:**

- Herencia = menos mantenimiento.
- Cambio en un solo lugar propaga a N productos.
- Mostrar que Status = Active — hay ciclo de vida (Draft / Active / Obsolete).

**Si algo no aparece:**

- Ejecutar Plan B (arriba) sin dudar. El mensaje conceptual de herencia es más importante que ver la related list exacta.
- Si la related list de Products no muestra las 6 coberturas, no detenerse — mencionar que la asignación está a nivel de cada producto en el campo `BasedOnId` o similar.

---

### Paso 2.7 — Cerrar el bloque volviendo al Bundle (2 min)

**Click / navegación:**

1. Volver a la tab 1 (Plan Empresarial).
2. Click en la pestaña **Structure** una vez más — dejar el árbol visible en pantalla.
3. Con el cursor, recorrer el árbol de arriba abajo: Bundle → Component Groups → Coberturas.

**Qué decir (talk track):**

> "Cerramos el bloque volviendo al inicio para que quede la imagen mental clara. Esto que ven — el árbol de Plan Empresarial con sus dos grupos y sus 6 coberturas modulares — es lo que ALFA va a operar en producción. Un equipo de producto puede armar un **Plan Pyme Premium**, **Plan Pyme Básico**, **Plan Retail**, **Plan Comercial Especial**, reusando estos mismos componentes en distintas combinaciones, con distintas reglas comerciales, sin tocar código y sin duplicar el catálogo. En el siguiente bloque vamos a tomar este bundle y llevarlo al ciclo real de una póliza: cotización, emisión, endoso y renovación."

**Puntos de énfasis:**

- Dejar la imagen del árbol en pantalla — visual memorable.
- Hacer puente al bloque 2 (ciclo póliza).

**Si algo no aparece:**

- Si el árbol tarda en cargar de nuevo, quedarse con la pestaña Details — el mensaje de cierre funciona igual.

---

### Paso 2.8 — Cotización desde Panadería La Espiga: OmniScript Create Quote (2 min)

**Objetivo:** salir del catálogo estático y mostrar el momento donde el agente arma una cotización para un cliente real. Este es el "runtime" del catálogo — donde la definición de producto que acabamos de ver se convierte en un Quote configurado.

**Click / navegación:**

1. Abrir en nueva tab: `https://storm-c90aab66569c63.lightning.force.com/lightning/r/Account/001g800000T9v3QAAR/view` (Account: Panadería La Espiga SAS).
2. En el header del record, click en el **Action Launcher** (icono de rayo o botón similar en la barra superior de acciones de la Account).
3. En el listado de acciones, buscar y click en **"Create Quote B2C Insurance 2"**.

**Verás:**

- Se abre un OmniScript con el header "Create Quote B2C Insurance 2".
- El OmniScript ya tiene precargado el AccountId de Panadería.

**Qué decir (talk track):**

> "Con el catálogo definido, ahora vamos al momento en que un agente de ALFA se sienta con un cliente y arma una cotización real. Estamos en la ficha de **Panadería La Espiga SAS** — nuestro cliente Pyme del sector alimentos, 42 empleados, tres establecimientos en Bogotá. Con un solo click en el Action Launcher lanzamos el flujo guiado **Create Quote B2C Insurance** que crea la cotización asociada a este cliente."

**Si algo no aparece:**

- Si el Action Launcher no está visible, usar el buscador global (Cmd+K / Ctrl+K) → escribir "Create Quote B2C Insurance 2" → Enter.
- Si el OmniScript pide inputs adicionales, aceptar los defaults.

---

### Paso 2.9 — Avanzar OmniScript y abrir la Quote (1 min)

**Click / navegación:**

1. En el OmniScript, click en **Next**.
2. En la siguiente pantalla, click en **View Quote**.
3. Se abre el record de la Quote recién creada: **"Panadería La Espiga SAS - Seguro Pyme Empresarial"**.

**Verás:**

- El header muestra el nombre de la Quote.
- Related lists / tabs muestran Quote Line Items (aún vacío en este punto).
- Un botón **Browse Catalogs** visible en la barra de acciones.

**Qué decir (talk track):**

> "El OmniScript ejecutó dos pasos: creó la Opportunity de contexto y la Quote ligada al cliente. Ya tenemos el contenedor de la cotización; ahora vamos a poblarla con productos del catálogo Pyme que acabamos de recorrer."

---

### Paso 2.10 — Browse Catalogs → seleccionar Plan Empresarial (2 min)

**Click / navegación:**

1. En la Quote, click en **Browse Catalogs**.
2. **Si Salesforce pide seleccionar Price Book**: elegir **"Standard Price Book"** y confirmar.
3. En el explorador de catálogos, se ve la lista de catalogs. Click en **Insurance Catalog**.
4. En las Categories, click en **Seguros Pyme**.
5. Se lista el bundle: click sobre **Plan Empresarial**.
6. Click en **Configure**.

**Verás:**

- Se abre el **Product Configuration LWC** con el título "Configure Plan Empresarial".
- Tabs **Coberturas** y **Establecimiento**.
- Bajo Coberturas, las 6 coverages con checkboxes; las 4 default vienen marcadas (Equipo Electrónico, Incendio y Aliados, Responsabilidad Civil Extracontractual, Robo y Asalto Interior); las 2 opcionales sin marcar (Rotura de Maquinaria, Sustracción de Dinero y Valores).
- Sidebar derecha con Summary por coverage.
- Toggles arriba: Product Validation ON, Instant Pricing OFF, Compact Mode OFF.

**Qué decir (talk track):**

> "Este es el **Product Configuration Lightning Web Component** — la interfaz que el agente usa día a día. Navegamos por el catálogo — Insurance Catalog, categoría Seguros Pyme — y elegimos el Plan Empresarial que definimos en bloques anteriores. Al hacer click en Configure, el runtime del catálogo materializa el bundle: ven las 4 coberturas que vienen por default para el Plan Empresarial — Responsabilidad Civil, Incendio, Equipo Electrónico y Robo — y las 2 opcionales que el agente puede activar según necesite el cliente: Rotura de Maquinaria y Sustracción de Dinero."

**Puntos de énfasis:**

- Destacar el checkbox: default vs opcional. Explicar que esa distinción viene del `IsDefaultComponent=true/false` en `ProductRelatedComponent` del catálogo.
- El precio de cada coverage viene del PricebookEntry — no está hardcodeado.

**Si algo no aparece:**

- Si el LWC no carga y muestra "Cannot read properties of null": la Opportunity subyacente no está apuntando al pricebook correcto — abandonar la Quote y usar `COT-PYME-2026-0001-Panaderia` (Id `0Q0g80000013EQrCAM`) pre-verificada como respaldo.

---

### Paso 2.11 — Configurar Equipo Electrónico y ver los 8 atributos heredados (2 min)

**Click / navegación:**

1. En el LWC de configuración del bundle, click en el nombre **Equipo Electrónico** (o click en el ícono de configuración de esa cobertura).
2. Se abre el detalle de configuración de esa coverage con breadcrumb `Plan Empresarial > Equipo Electrónico`.

**Verás:**

- Los 8 atributos poblados con defaults:
  - **Actividad Económica**: Comercio
  - **Deducible**: COP 2,000,000
  - **Deducible Mínimo por Evento**: COP 1,000,000
  - **Metros Cuadrados Local**: 101-500 m²
  - **Porcentaje de Coaseguro**: 10%
  - **Rango de Empleados**: 11-50 empleados
  - **Suma Asegurada**: COP 100,000,000
  - **Sustancias Prohibidas**: Ninguna
- Sidebar Summary muestra los mismos valores.

**Qué decir (talk track):**

> "Al configurar una cobertura — por ejemplo, Equipo Electrónico — vemos los 8 atributos que definimos en el Bloque 1. **Actividad Económica** ya viene con Comercio porque Panadería es del sector alimentos. **Suma Asegurada** default en 100 millones de pesos, **Deducible** 2 millones, **Rango de Empleados** 11-50, **Metros Cuadrados** 101-500 — todos con valores predefinidos por el equipo de producto. El agente puede ajustar cualquiera de estos según lo que el cliente necesite; los picklists garantizan que no se salga de los rangos comerciales autorizados. Lo importante: **estos 8 atributos son los mismos en las 6 coberturas** porque todas heredan de la ProductClassification 'Cobertura Pyme' — un solo lugar para gobernar el modelo de atributos."

**Puntos de énfasis:**

- No cambiar valores en vivo — dejar los defaults para no romper el flujo de pricing.
- Insistir en que la herencia via ClassificationAttr es lo que garantiza consistencia.

---

### Paso 2.12 — Volver, Update Prices y guardar la configuración (2 min)

**Click / navegación:**

1. Click en el breadcrumb **Plan Empresarial** (o botón "Return to Quote").
2. Click en **Update Prices**.
3. Esperar ~2 segundos: el mensaje "Prices don't reflect the latest selections" desaparece.
4. Verificar en el sidebar Summary: **Net Unit Price $2,400,000** y **Net Total Price $2,400,000**.
5. Click en **Save & Exit**.
6. Volver automáticamente a la Quote.

**Verás:**

- La Quote ahora tiene Quote Line Items poblados: el bundle raíz + las 4 coverages default hijas, con `ParentQuoteLineItemId` conectándolos.
- TotalPrice de la Quote: **2,400,000**.

**Qué decir (talk track):**

> "Update Prices ejecuta el **pricing procedure** en tiempo real — calcula la prima combinando los precios de las coverages activas: RC 600 mil, Incendio 800 mil, Equipo Electrónico 300 mil, Robo 400 mil = **2 millones 400 mil pesos anuales**. Salvamos la configuración y volvemos a la Quote. **Nota rápida**: el símbolo $ que ven es porque esta org demo está en dólar por default; en producción se configura la moneda de la org en pesos colombianos y todos los valores aparecen directamente con el símbolo de peso."

**Puntos de énfasis:**

- El pricing es declarativo — no hay Apex de rating custom.
- Los QuoteLineItems reflejan la estructura bundle+children del catálogo.

**Si algo no aparece:**

- Si Update Prices no cambia el total, refrescar la Quote (F5) — a veces el LWC necesita recargar.

---

### Paso 2.13 — Ver la Quote y ejecutar Issue Policy (2 min)

**Click / navegación:**

1. En la Quote, revisar la tab **Quote Line Items** o el related list — se ven las 5 líneas (Plan Empresarial parent + 4 coverages children).
2. En la barra de acciones de la Quote, click en **Issue Policy** (botón/action).

**Verás:**

- Se abre un wizard con formulario de "Issue Policy" pidiendo campos de la nueva póliza.

**Qué decir (talk track):**

> "Con la cotización aceptada por el cliente, ejecutamos **Issue Policy** — la acción que convierte el Quote en una póliza formal. Esto crea el registro InsurancePolicy con toda la estructura de coverages heredada del Quote, y dispara los transaction records de emisión que veremos en el bloque siguiente."

---

### Paso 2.14 — Wizard Issue Policy — completar campos (2 min)

**Click / navegación:**

1. En el wizard, completar los siguientes campos:
   - **Policy Name**: `POL-PYME-2026-0001`
   - **Policy Number**: `POL-PYME-2026-0001`
   - **Effective Start Date**: `06/01/2026`
   - **Effective End Date**: `05/31/2027`
   - **Policy Term**: `Annually`
2. Click en **Next**.
3. En el paso de pago: click en **Process Payment and Continue**.
4. Click en **Next** en la pantalla siguiente hasta finalizar el wizard.

**Verás:**

- Al terminar el wizard, aparece confirmación de póliza emitida.
- Se genera un registro InsurancePolicy con Name `POL-PYME-2026-0001` (o similar según el auto-numbering) y todos los coverages materializados.

**Qué decir (talk track):**

> "Completamos la información básica: nombre y número de póliza **POL-PYME-2026-0001** — la nomenclatura que ALFA acuerde con su equipo de suscripción —, vigencia anual del 1 de junio 2026 al 31 de mayo 2027, y término anual. Procesamos el pago inicial — en producción esto se integra con la pasarela real del cliente — y finalizamos. **La póliza está emitida**. En el próximo bloque vamos a explorar todo el ciclo de esta póliza: sus coverages, sus cláusulas contractuales, endoso midterm y cancelación."

**Puntos de énfasis:**

- El flujo completo Quote → Configure → Issue Policy tomó menos de 10 minutos en vivo, sin código.
- La póliza emitida es el input directo del Bloque 2.

**Si algo no aparece:**

- Si Issue Policy falla por conflicto con `POL-PYME-2026-0001` preexistente en la org, usar `POL-PYME-2026-0001-DEMO` como nombre alternativo — no rompe el hilo narrativo.
- Si el wizard se cuelga en algún paso, cerrar y usar la póliza pre-emitida `POL-PYME-2026-0001` (ya creada vía API para respaldo de Bloque 2 y 3) como fallback.

---

### Paso 2.15 — Configuración de Tarifas (Pricing) del Plan Empresarial (3 min)

**Objetivo:** cerrar el bucle del catálogo mostrando dónde vive la tarifa que ya se calculó en el paso 2.12 (los 2.4 MM). Aterrizar que el pricing es declarativo, no hardcodeado.

**Click / navegación:**

1. Volver a la tab 1 (Plan Empresarial, `01tg8000003hS49AAE`).
2. Click en la pestaña **Related** (o desplazarse hasta la related list).
3. Localizar la related list **Price Book Entries** (label en español puede ser "Entradas del catálogo de precios").
4. Click en la entrada del **Standard Price Book** (`01ug80000025X0bAAE`).
5. Verás:
   - **Product**: Plan Empresarial
   - **Price Book**: Standard Price Book
   - **List Price**: `$2,400,000`
   - **Active**: ✓

**Fallback si la related list no está en el layout:** navegar directo por URL a `https://storm-c90aab66569c63.my.salesforce.com/01ug80000025X0bAAE`.

**Qué decir (talk track):**

> "El precio de 2 millones 400 mil que vieron en la cotización no está hardcodeado en ninguna parte — vive acá, en una **PricebookEntry** del Standard Price Book. Insurance on Core trae de fábrica una **Insurance Quote Default Pricing Procedure** y **7 templates de rating** — Product Level, Quote Level, Member-Based, Summary-Based — que permiten modelar tarifas por edad, actividad económica, monto asegurado, número de empleados, todo declarativo vía **ExpressionSet**, sin código. Para el despliegue productivo de ALFA, aquí conectaríamos tablas tarifarias por segmento — Pyme Micro, Pequeña, Mediana — o por región usando Price Books adicionales."

**Puntos de énfasis:**

- El pricing es un objeto de primera clase, gobernable, versionable.
- Sin código: mencionar que hay 3 pricing procedures OOTB en la org (Insurance_Quote_Default_Pricing_Procedure, Default_Pricing, pricingProcedure) y 17 CalculationMatrix estructuras genéricas listas para poblarse.
- Puente al segmento: "Si ALFA quiere tarifas diferenciales por región o por tramos de suma asegurada, todo eso se resuelve sin desarrollo."

**Si algo no aparece:**

- No abrir Setup → Pricing Procedures en vivo (UI puede pedir contexto o dar error) — solo mencionar verbalmente.
- No mostrar CalculationMatrix vacías — se ve desconectado.
- Fallback final: quedarse en la PricebookEntry, es garantizada.

---

### Paso 2.16 — Reglas de Suscripción / Underwriting Rules (3 min)

**Objetivo:** mostrar que la capacidad de reglas de suscripción existe nativa, y narrar 1-2 ejemplos concretos que ALFA puede configurar sin código. No crear reglas en vivo.

**Click / navegación:**

1. Abrir **App Launcher** → buscar `Underwriting Rules` → click en la app (o navegar a la sección Underwriting Rules Builder desde Setup).
2. Se muestra el listado de **UnderwritingRuleGroups** — hay 6 groups OOTB atados a productos Auto (Gold/Silver/Claim). Ejemplos visibles:
   - **Quote Submission** (Auto Gold, Draft→Submitted) — 2 rules incluyendo "Validate state of license for SUV".
   - **Needs Review** (Auto Gold, Submitted→Needs Review) — regla con Discount > $100 dispara task flows.
   - **Quotes approved Broker profile** (Auto Gold) — combina UserProfile + DiscountValue.
   - **Incident Location Country** (Auto Claim Root, Initial→Open).
3. Click en **Quote Submission** para mostrar la estructura del group y sus rules internas.
4. Después, volver a la tab 1 (Plan Empresarial) → click en la pestaña **Rules** — se muestra vacío para Plan Empresarial, pero la capacidad está.

**Qué decir (talk track):**

> "ALFA nos preguntó por reglas de suscripción — cómo evita que un asesor emita una póliza con un riesgo no autorizado. Esta capacidad viene nativa en Insurance on Core: **Underwriting Rules** organizadas en **Rule Groups** por transición de estado del Quote o Claim — Draft→Submitted, Submitted→Approved, Submitted→Needs Review. Miren estos ejemplos que trae OOTB para Auto: si un vehículo SUV no tiene licencia en California, se bloquea el submit. Si el descuento supera $100, dispara un flow que crea la tarea para el suscriptor senior. Para el **Plan Empresarial** de ALFA, la Fase 2 de implementación configura reglas así: *'si Actividad Económica es Manufactura y Sustancias Prohibidas no es Ninguna → bloquear submit y enviar a UW manual'*, o *'si Suma Asegurada supera 500 millones COP → dispara flow que asigna revisión al equipo de riesgos'*. Todo declarativo, sin Apex."

**Puntos de énfasis:**

- Mencionar la separación clara: **UnderwritingRule** opera en transiciones de estado; **ProductConfigurationRule** opera durante la configuración del producto (defaults, hides, coverages requeridas — hay 9 rules Active para Auto Silver/Gold como referencia).
- El motor es **BusinessRuleEngine** — genérico, escala más allá de Insurance.
- Cerrar volviendo al tab Rules del Plan Empresarial: "Vacío hoy, poblado por ALFA en Fase 2."

**Si algo no aparece:**

- Si el Underwriting Rules Builder no carga (posible en org storm), fallback: mostrar los 9 **ProductConfigurationRule** desde App Launcher → quicksearch "Product Configuration Rules" (son más maduros y suelen cargar). Narrativa similar.
- Fallback secundario: abrir un UW Rule Group por URL directa — `https://storm-c90aab66569c63.my.salesforce.com/1KQg800000007xaGAA` (Quote Submission Auto Gold).
- **No crear reglas en vivo** — riesgo alto de dejar algo inconsistente. Todo lo mostrado es lectura.

---

### Paso 2.17 — Publicación del Producto (2 min)

**Objetivo:** cerrar la cadena mostrando cómo Plan Empresarial "está publicado" — activo, asignado a una categoría dentro de un catálogo comercial.

**Click / navegación:**

1. Volver a la tab 1 (Plan Empresarial).
2. Pestaña **Details** — confirmar visualmente **Active = ✓**.
3. Bajar al related list **Product Categories** (o navegar al ProductCategoryProduct `0ZRg8000000Fjw5GAC`).
4. Mostrar el registro: **Plan Empresarial → Seguros Pyme → Insurance Catalog**.
5. Opcional (30 seg): navegar al catálogo "Insurance Catalog" (`0ZSg8000000D8pPGAS`) → categoría "Seguros Pyme" (`0ZGg8000000FLP7GAO`) — se ve el producto listado.
6. Mencionar (sin necesariamente clickear) los campos de ventana temporal: **AvailabilityDate**, **DiscontinuedDate**, **EndOfLifeDate** (hoy vacíos = siempre disponible).

**Qué decir (talk track):**

> "Cerramos con la publicación. En Digital Insurance PCM el modelo es más ligero que otros catálogos — no hay un botón 'Publicar' formal con estados Draft/Released como en Comms Cloud. La publicación es declarativa y se materializa con tres controles nativos: **uno**, el flag `IsActive = true` en el producto; **dos**, un registro **ProductCategoryProduct** que ata el producto a una categoría dentro de un catálogo — en nuestro caso Plan Empresarial está publicado en la categoría **Seguros Pyme** del **Insurance Catalog**; **tres**, opcionalmente las fechas **AvailabilityDate**, **DiscontinuedDate**, **EndOfLifeDate** que dan control temporal — cuándo entra en vigor, cuándo se descontinúa, cuándo llega a fin de vida. Para gobernanza empresarial ALFA puede envolver esto en un **Approval Process** sobre Product2 antes de que `IsActive` pase a true, o usar Change Sets/DevOps para promover productos entre orgs — sandbox, UAT, producción."

**Puntos de énfasis:**

- El "publish" no es un flujo caja negra — son objetos estándar auditables (Product2, ProductCategory, ProductCategoryProduct, ProductCatalog).
- Si preguntan por versionamiento formal: aclarar que en Digital Insurance PCM el versionamiento vive a nivel de **InsurancePolicy** (endorsements, renewals) — no de Product2. NO mencionar LifecycleStatus/Draft/Released (eso es EPC/Comms Cloud, no aplica aquí).

**Si algo no aparece:**

- Si la related list Product Categories no está en el layout: SOQL rápido en Dev Console `SELECT Product.Name, ProductCategory.Name, ProductCategory.Catalog.Name FROM ProductCategoryProduct WHERE Product.ProductCode='segPymeEmpresarial'` — devuelve la fila y se narra sobre eso.
- Si el cliente insiste en un botón "Publish" formal: responder que Digital Insurance PCM no lo trae discreto; la publicación es la combinación IsActive + ProductCategoryProduct + fechas efectivas, envolvible en Approval Process si se requiere workflow de aprobación.

---

## 3. Preguntas anticipadas del cliente

| Pregunta probable | Respuesta preparada |
|---|---|
| ¿Cuánto de esto es configuración estándar vs. customización? | 100% configuración estándar de Insurance on Core — Product Catalog Management es un módulo nativo. Todo lo que vieron (Product2 tipo Bundle, ProductClassification, ProductComponentGroup, AttributeDefinition, ProductRelatedComponent) son objetos estándar del producto. No hay Apex, no hay LWC custom, no hay campos custom que rompan actualizaciones. |
| ¿Los ProductAttributeDefinition se generan automáticamente al asignar una Classification? | La Classification propaga la lista de atributos disponibles al producto, pero los **PADs** (Product Attribute Definitions) que fijan defaults, valores por producto, y visibilidad, se materializan explícitamente en el producto. En esta org tenemos **48 PADs creados entre las 6 coberturas — promedio 8 por cobertura** — todos activos y listos. |
| ¿Cómo controlan que un asesor no meta una suma asegurada fuera de rango? | Tres capas: (1) **Picklist** en el atributo Suma Asegurada — el asesor solo elige valores predefinidos; (2) **AttributeScopes** en el bundle — se pueden acotar los valores permitidos por plan; (3) **Rules** — reglas declarativas que validan combinaciones. Todo sin código. |
| ¿Podemos crear un nuevo plan sin ayuda de IT? | Sí. Un rol de negocio con permisos sobre Product Catalog Management puede: crear un Product2 tipo Bundle, asociar ProductRelatedComponents a coberturas existentes, definir Component Groups, y publicar. Es la promesa central del módulo. |
| ¿Qué pasa si dos planes usan la misma cobertura pero con reglas distintas? | La cobertura queda una sola vez en el catálogo (Simple product). Las diferencias comerciales (suma asegurada default, coaseguro, exclusiones) se manejan a nivel de **ProductRelatedComponent** — el link entre bundle y componente — o vía **AttributeScopes** por plan. Esto es exactamente reutilización sin duplicación. |
| ¿Los atributos soportan tipos complejos (fechas, referencias a otros objetos, jerarquías)? | Los DataTypes soportados incluyen: Text, Number, Date, DateTime, Boolean, Picklist, Multipicklist, Currency, Percent. Suma Asegurada la modelamos Picklist para control comercial. Deducible puede ser Number. Actividad Económica típicamente Picklist con catálogo CIIU. No hay referencias directas a otros objetos vía AttributeDefinition, pero eso se maneja con relaciones estándar de Salesforce donde aplique. |
| ¿Cómo se versiona el catálogo? ¿Qué pasa cuando cambia un producto que ya está vendido? | **[Respuesta conceptual — no navegar a los campos en vivo, no están verificados poblados en esta org]** El modelo de Product2 en Salesforce soporta versionamiento temporal (campos como `ValidFrom` / `ValidTo` en el estándar, y patrones de "effective dating" del managed package). Las pólizas emitidas guardan referencia a la versión del producto vigente al momento de emisión — esto se ve en detalle en bloque 2 con InsurancePolicy y sus coverages. Cambios a un producto no impactan pólizas ya emitidas hasta su renovación. Si el cliente pide ver los campos exactamente, decir: *"En esta org demo el versionamiento está a nivel conceptual — para el proyecto ALFA lo detallamos en la sesión de arquitectura de datos, donde definimos la política de versionamiento y snapshotting."* |
| ¿Este catálogo se puede exponer vía API a un portal externo o a otro core? | Sí. Todos los objetos que vieron (Product2, ProductClassification, ProductComponentGroup, AttributeDefinition, ProductRelatedComponent) tienen APIs REST y SOAP estándar de Salesforce. Además, Insurance on Core expone endpoints específicos para catálogo. Se puede sincronizar con un core externo o exponer a un portal comercial. |
| ¿Cuántas coberturas máximo soporta un bundle? ¿Hay límites de performance? | Los límites son los estándar de Salesforce sobre relaciones — miles por producto en la práctica. No es un cuello de botella funcional. En este demo tenemos 7 ProductRelatedComponent bajo Plan Empresarial; hemos visto implementaciones con 30-50 componentes sin problemas. |
| ¿El árbol Structure lo puede ver también un rol de negocio o solo IT? | Es una pestaña estándar sobre el objeto Product2. Se controla vía permisos de perfil / permission set — el equipo de producto de ALFA lo verá igual que ustedes. No requiere setup especial. |
| ¿La tarifa se puede configurar por segmento, región o tramos de suma asegurada sin código? | Sí. La tarifa base vive en **PricebookEntry** — un objeto estándar. Para tarifas diferenciales se usan **Price Books adicionales** por segmento (Pyme Micro/Pequeña/Mediana) o **CalculationMatrix** para matrices tarifarias por múltiples dimensiones (edad × actividad × suma asegurada). Adicionalmente Insurance on Core trae la **Insurance Quote Default Pricing Procedure** y 7 templates de rating (Product Level, Quote Level, Member-Based, Summary-Based) que se orquestan vía **ExpressionSet** — todo declarativo. |
| ¿Cómo se bloquea la emisión si el riesgo no cumple criterios? ¿Hay motor de reglas nativo? | Sí. **Underwriting Rules** (motor BusinessRuleEngine) organizadas en Rule Groups por transición de estado (Draft→Submitted, Submitted→Approved, Submitted→Needs Review). Ejemplos que ALFA puede modelar declarativamente: "si Actividad = Manufactura y Sustancias Prohibidas ≠ Ninguna → bloquear submit", "si Suma Asegurada > 500 MM COP → dispara flow que asigna revisión al UW senior". Complementariamente hay **ProductConfigurationRule** para reglas durante la configuración (defaults, campos ocultos, coverages requeridas). Ambos motores son nativos, sin Apex. |
| ¿Cómo se "publica" un producto en Digital Insurance PCM? ¿Hay flujo Draft/Released? | Digital Insurance PCM no tiene el flujo formal Draft/Released de Comms Cloud EPC — el modelo es más ligero y declarativo: **(1)** `IsActive = true` en Product2, **(2)** un registro `ProductCategoryProduct` que ata el producto a una categoría dentro de un catálogo, **(3)** opcionalmente las fechas `AvailabilityDate`, `DiscontinuedDate`, `EndOfLifeDate` para control temporal. Si ALFA necesita workflow formal de aprobación, se envuelve en un **Approval Process** sobre Product2 antes de que `IsActive` pase a true. El versionamiento formal en Insurance vive a nivel de **InsurancePolicy** (endorsements, renewals), no a nivel de Product2. |

---

## 4. Transición al siguiente bloque

> "En este primer bloque vimos el catálogo Pyme desde su definición estática hasta el momento en que se convierte en una póliza real: modelado del bundle con sus coberturas y atributos, configuración del Quote desde la cuenta de Panadería La Espiga, y emisión de la póliza **POL-PYME-2026-0001** vía Issue Policy. En el próximo bloque tomamos esta póliza recién emitida y exploramos el ciclo completo de administración: las cláusulas contractuales que quedaron materializadas, endoso midterm por aumento de suma asegurada, renovación anticipada y cancelación con devolución de prima proporcional."

---

## 5. Fallbacks generales del bloque

### 5.1 No carga la pestaña Structure

- Refresh una sola vez (Ctrl/Cmd + R).
- Si persiste: ir a `Related` → `Product Related Components` — muestra las 7 relaciones planas. Explicar verbalmente la jerarquía: "El árbol acá lo tienen plano, pero los componentes están agrupados por Component Group — Coberturas y Establecimiento."
- Como último recurso, mostrar el listado de Products filtrando por `Type = (vacío)` y `SellOnlyWithOtherProducts = true` (visibles en la list view estándar) y describir las 6 coberturas con sus códigos. Alternativa vía dev console/API: `SOQL: WHERE ProductClass = 'Simple'`.

### 5.2 No aparece una cobertura esperada

- Verificar en la lista de Products si está con `IsActive=true`.
- Si no aparece, saltar a otra cobertura y mencionar que el catálogo tiene 6 coberturas activas, sin detenerse en la que falta.

### 5.3 Salesforce lento o cae la conexión

- Explicar: "Es un org de storm compartido, esto es la infra de demo. En producción ALFA tendrá su propio org dedicado con SLAs de Salesforce."
- Mientras tanto, pasar a slide de arquitectura o mostrar el diagrama del catálogo dibujado.

### 5.4 Pregunta técnica muy profunda que no controlo

- Frase segura: "Excelente pregunta. Tomo nota y en el bloque de Q&A al final o en la próxima sesión técnica se la resuelvo con el nivel de detalle que merece — quiero darle la respuesta correcta, no una aproximación."
- Anotar en un doc lateral para follow-up.
- **Casos específicos donde NO improvisar en vivo**:
  - Versionamiento de productos (campos `ValidFrom` / `ValidTo`) — no navegar a mostrarlos, no están verificados poblados. Responder conceptualmente (ver Q&A) y ofrecer sesión de arquitectura de datos.
  - Cifras exactas de PADs por cobertura si al abrir en vivo el número difiere de 8 — decir "aproximadamente 8, varía por cobertura" en vez de citar 48 total.

### 5.5 Locale en inglés genera confusión

- Preventivo desde el inicio: "El usuario demo está en inglés, pero todos los datos user-facing — nombres de productos, coberturas, atributos — están en español. Salesforce soporta traducción de labels vía Translation Workbench, y en producción para ALFA se configura en español de Colombia."

### 5.6 Preguntan por el 7mo ProductRelatedComponent (esperaban 6, hay 7)

- Respuesta preparada: "Bajo el bundle Plan Empresarial hay 6 coberturas más el componente Establecimiento — ese es el 7mo. Establecimiento captura los datos del local del asegurado (metros cuadrados, actividad económica, etc.) y por eso está a nivel de bundle, no como cobertura vendible."

### 5.7 No encuentro la related list de atributos en Product Classification

- Los labels de related lists en ProductClassification no están pre-verificados en esta org y pueden variar según versión del managed package.
- **Plan B rápido**: no buscar más de 5 segundos. Volver a la cobertura RC Extracontractual (tab 2) → pestaña Attributes, y usar esos 8 atributos como evidencia visual de la herencia. Frase: *"La clasificación es el mecanismo de propagación; los atributos ya los vimos materializados en cada cobertura."*
- Reforzar el mensaje conceptual (una clasificación → 6 coberturas heredan) que es lo que importa, no el label exacto de la related list.

### 5.8 Las 9 pestañas del bundle no caben en pantalla

- Si Structure (u otra pestaña clave) queda oculta detrás del `>` (More Tabs):
  - Opción A (mejor): bajar el zoom del browser a 100% y refrescar.
  - Opción B: hacer click en el `>` y seleccionar Structure desde el menú desplegable — funciona pero rompe el flujo visual.
- Idealmente ya está resuelto en el setup 0.3. Si aparece en vivo, no dramatizar — click en `>`, seleccionar y seguir.

---

## 6. Métricas de éxito del bloque

Al final de los 30 minutos, ALFA debería haber visto y quedar convencido de:

- [ ] Product Catalog Management es un módulo estándar de Insurance on Core, no una customización.
- [ ] Existe un bundle real y funcional (**Plan Empresarial**) con 6 coberturas y 2 Component Groups configurados.
- [ ] La jerarquía se ve en la pestaña **Structure** — evidencia visual, no slide.
- [ ] Cada cobertura es un producto Simple independiente, reutilizable en otros planes.
- [ ] Hay ~8 atributos técnicos clave por cobertura (Suma Asegurada, Deducible, Coaseguro, etc.) modelados como AttributeDefinition reusables — 48 PADs totales.
- [ ] **Suma Asegurada** es Picklist — control comercial sobre tramos, sin código.
- [ ] Existen 2 **Product Classifications** activas (Cobertura Pyme, Establecimiento Comercial) que centralizan atributos y reducen mantenimiento.
- [ ] Un equipo de producto de ALFA puede armar planes nuevos sin depender de IT.
- [ ] El catálogo tiene versionamiento (conceptual), gobierno, y APIs estándar de Salesforce.
- [ ] Todo lo mostrado alimenta el ciclo de póliza que se verá en el bloque 2.

**Señales de éxito en la sala:**

- Cliente hace preguntas de "cómo se hace X con esto" (no de "esto sirve para X") — indica que ya compró la premisa.
- Cliente pide ver un plan diferente o pregunta por casos edge — indica engagement.
- Cliente toma nota o menciona a colegas ausentes — indica valor percibido.

**Señales de alerta:**

- Silencio prolongado tras el paso 2.3 (Structure) — significa que la modularidad no quedó clara. Repetir con otras palabras.
- Preguntas repetidas sobre "¿esto es custom?" — significa que no confían en que es estándar. Reforzar mostrando el path desde App Launcher a un objeto estándar (Product2, AttributeDefinition).

---

**Fin del Runbook — Bloque 1.**

Duración objetivo: 48 min. Distribución sugerida:
- Setup mental + contexto: 1 min
- Paso 2.1 (App Launcher): 2 min
- Paso 2.2 (Bundle Details): 3 min
- Paso 2.3 (Structure — corazón del bloque): 5 min
- Paso 2.4 (Cobertura + Attributes): 5 min
- Paso 2.5 (AttributeDefinition Suma Asegurada): 4 min
- Paso 2.6 (Product Classifications): 4 min
- Paso 2.7 (Cierre catálogo + transición al runtime): 2 min
- Pasos 2.8–2.14 (Cotización + Configure + Issue Policy en vivo): 13 min
- Paso 2.15 (Pricing / PricebookEntry): 3 min
- Paso 2.16 (Underwriting Rules): 3 min
- Paso 2.17 (Publicación del producto): 2 min
- Buffer para 1-2 preguntas en vivo: 1 min
- **Total**: 48 min
