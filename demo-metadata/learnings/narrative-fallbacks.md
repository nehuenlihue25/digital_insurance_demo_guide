# Narrative Fallbacks — Seguros ALFA Demo

Talk tracks pre-armados para situaciones específicas durante la demo del 2026-07-09.

## Talk track: "Los precios aparecen en USD, no COP"

> "El símbolo $ que aparece en pantalla es porque esta org demo tiene default currency USD — es un artefacto técnico del ambiente. Los valores numéricos que ven (2,400,000, 800,000, etc.) son los que ALFA configuraría en pesos colombianos al parametrizar la moneda de su org productiva. Todo el pricing procedure y las matrices tarifarias funcionan idénticamente sin importar la moneda."

## Talk track: "Los labels standard están en inglés"

> "El locale del usuario demo está en en_US por eso las etiquetas de Salesforce estándar (Product Code, Save & Exit, Related, etc.) salen en inglés. En la implementación real de ALFA, el usuario se configura con locale es_CO y toda la interfaz aparece traducida al español automáticamente. Todos los datos de negocio que ven en pantalla (nombres de productos, coverages, atributos, cláusulas, siniestros) están en español porque los cargamos así en el catálogo — que es lo que importa."

## Talk track: "No veo Reaseguros ni Facturación en la demo"

> "Correcto, están fuera del alcance de esta sustentación por dos razones. Reaseguros es una capa que se integra con soluciones especializadas — el modelo de datos de Insurance on Core no incluye reaseguros nativamente porque es un mercado donde las aseguradoras usan sistemas dedicados (Guy Carpenter, Cognalys, SICS). Facturación y recaudo, similar — se integra con la solución de billing que ALFA ya tenga en producción. Ambos son puntos claros en la arquitectura y los detallamos en la sesión de arquitectura al final."

## Talk track: "No veo Rules configurados sobre el Plan Empresarial"

> "Correcto — mostramos el motor de Rules disponible y los 6 UnderwritingRuleGroups OOTB para ilustrar la capacidad. En una implementación real de ALFA, el equipo de suscripción configura las reglas específicas (validación de actividad económica, límites de suma asegurada por segmento, reglas de aprobación por monto) sobre este mismo motor. Configurar 20-30 reglas típicas toma 2-3 semanas del equipo de negocio con acompañamiento del arquitecto — ya está incluido en el roadmap de implementación."

## Talk track: "Los dashboards se ven simples / pobres"

> "Los dashboards que están viendo son tabulares básicos porque ilustran los datos disponibles al modelo de reportería. En la implementación de ALFA se combinan con **CRM Analytics** — que también está en las licencias de esta org — para agregación temporal, drill-down por sucursal/producto, alertas de KPI y forecasting. En la sesión de arquitectura mostramos el paso de estos reports estándar a dashboards CRM Analytics con Einstein Discovery."

## Talk track: "Falta configuración de tarifas dinámicas"

> "Lo que mostramos hoy es el pricing procedure OOTB — Insurance_Quote_Default_Pricing_Procedure. Digital Insurance PCM soporta pricing procedures avanzadas via 3 capas declarativas: (1) CalculationMatrix para rate cards por segmento/región/actividad, (2) ExpressionSet para lógica condicional, (3) DecisionTable para tablas de coeficientes. Todas se configuran sin código. Un actuario de ALFA con capacitación PCM (~1 semana) puede modelar cualquier tarifa comercial de su portfolio."

## Talk track: "Puedo modificar precios en línea?"

> "Sí. Cada Coverage tiene su UnitPrice en el PricebookEntry — modificable declarativamente. Además, el pricing procedure calcula el precio final en tiempo real basado en los atributos que el agente configura (Suma Asegurada, Actividad Económica, etc.). Un cambio de precio a nivel producto o de la fórmula se propaga instantáneamente a todas las cotizaciones futuras. Las pólizas ya emitidas mantienen su precio contractual hasta renovación."

## Talk track: "Cómo se integra con nuestros sistemas legacy?"

> "Insurance on Core expone APIs REST y SOAP estándar sobre todos los objetos: Product2, InsurancePolicy, Claim, ClaimCoverage, InsurancePolicyTransaction. Además, hay endpoints específicos de Digital Insurance (Insurance Rating API, Endorsement API, Claims Management API) para integraciones de mayor volumen. Para ETL batch con AS400 o Core externo, se usa MuleSoft o Data Loader según volumen. En la sesión de arquitectura detallamos el modelo de integración específico para el paisaje IT de ALFA."

## Talk track: "El siniestro se ve simplificado. En ALFA gestionamos 20-30 pasos"

> "Correcto — mostramos el ciclo end-to-end con 6 fases (FNOL, participants, items, coverage, reservas, pagos) para dar contexto. En la implementación real de ALFA se modela el workflow completo con Action Plans, milestones, SLAs, aprobaciones multi-nivel y notificaciones. El motor de Action Plan que ven vacío en esta demo es donde se configuran esos 20-30 pasos. Un caso de siniestro típico de ALFA se puede modelar en 2-3 días de configuración."

## Talk track: "Este catálogo lo puede administrar el equipo de negocio?"

> "Sí, es una promesa central del módulo. Un rol de negocio con permisos sobre Product Catalog Management (PSL DigitalInsuranceProductAdmin) puede: crear nuevos productos, agregar/quitar coverages, modificar atributos y sus rangos, cambiar precios, activar/desactivar productos por fecha, publicar a catálogos y categorías, definir reglas de suscripción. Todo sin tocar código, sin depender de IT. El equipo de arquitectura mantiene los cimientos (ProductClassification, AttributeDefinition genéricas), el equipo comercial arma sus productos comerciales sobre eso."
