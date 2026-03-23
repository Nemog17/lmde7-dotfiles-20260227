# CLAUDE.md

No sé programar. Antes de tocar código, SIEMPRE explícame en español simple.

## Antes de empezar cualquier tarea
OBLIGATORIO: Antes de CUALQUIER cambio o feature (sin importar lo simple que parezca), usa `AskUserQuestionTool` para entrevistarme a detalle. Las preguntas NO deben ser obvias. Hazme preguntas con opciones claras sobre implementación técnica, UI y UX, preocupaciones y riesgos, tradeoffs y alternativas, datos y estado, rendimiento, seguridad, permisos, casos borde, etc. No escribas código hasta que yo confirme que estoy conforme. Después de mostrarme el formato de modificación, vuelve a usar `AskUserQuestionTool` para confirmar antes de aplicar el cambio.

## Archivo nuevo (no existe)
Dime qué archivo vas a crear, para qué sirve, y créalo.

## Archivo existente (modificación)
NUNCA reescribas el archivo completo. Antes de cada cambio, usa este formato:

```
📁 Archivo: [nombre]
📍 Ubicación: [línea o función]
🔍 Ahora dice: [código actual] → significa: [explicación simple]
✏️ Va a decir: [código nuevo] → significa: [explicación simple]
💡 Por qué: [razón del cambio]
```

## Agentes

### PM Agent (`pm`) — Orquestador
⚠️ **OBLIGATORIO PARA TODA TAREA SIN EXCEPCIÓN** ⚠️
SIEMPRE despachar el agente `pm` (subagent_type="pm") como PRIMER paso ante CUALQUIER solicitud del usuario. No importa si la tarea parece simple, si es un solo archivo, o si solo toca un dominio. PM SIEMPRE toma el mando.

El PM NO escribe código — planifica, delega al equipo (frontend, backend, dba, devops), revisa y reporta. Agentes externos (Codex, Gemini) solo bajo autorización explícita del usuario.

**Única excepción:** Tareas de configuración de Claude Code (hooks, settings, memoria) se pueden manejar directamente.

El agente está definido en `.claude/agents/pm.md` (proyecto) y `~/.claude/agents/pm.md` (global).

### Frontend (`frontend`)
OBLIGATORIO: Para CUALQUIER tarea relacionada con el frontend (componentes, vistas, estilos, responsive design, animaciones, UX, o cualquier archivo en `frontend/`), SIEMPRE despachar el agente `frontend` como subagent. No trabajar directamente en código frontend sin usar este agente.

El agente está definido en `.claude/agents/frontend.md` y tiene conocimiento especializado de Vue.js, Tailwind CSS, mobile-first design, y todas las herramientas del proyecto (skills, MCP servers, Context7).

### Backend (`backend`)
OBLIGATORIO: Para CUALQUIER tarea relacionada con el backend (modelos, migraciones, Actions, GraphQL, APIs, testing, queue jobs, policies, seeders, o cualquier archivo en `backend/`), SIEMPRE despachar el agente `backend` como subagent. No trabajar directamente en código backend sin usar este agente.

El agente está definido en `.claude/agents/backend.md` y tiene conocimiento especializado de Laravel 12, PostgreSQL (Neon), GraphQL (Lighthouse), Sanctum, Spatie, y todas las herramientas del proyecto (Neon MCP, Laravel Boost MCP, Context7).

### DevOps (`devops`)
OBLIGATORIO: Para CUALQUIER tarea de infraestructura, CI/CD, deploys, Cloudflare (Workers, Containers, Pages, R2), Neon (branches, DB), GitHub Actions, Docker, scripts de automatización, o archivos en `worker/`, `docker/`, `scripts/`, `.github/`, SIEMPRE despachar el agente `devops` como subagent.

El agente está definido en `.claude/agents/devops.md` y tiene conocimiento especializado de Cloudflare (Workers, Containers, Pages, R2, Wrangler), Neon PostgreSQL, GitHub Actions, Docker, y todas las herramientas CLI (gh, wrangler, neonctl, git).

### DBA (`dba`)
OBLIGATORIO: Para CUALQUIER tarea de base de datos — migraciones, queries, performance, indexes, schema design, multi-tenancy, Neon branches, seeders, factories, o diagnóstico de DB — SIEMPRE despachar el agente `dba` como subagent.

El agente está definido en `.claude/agents/dba.md` y tiene conocimiento especializado de PostgreSQL, multi-tenancy (BelongsToTenant), constraints complejos (EXCLUDE, CHECK, partial UNIQUE), indexes (composite, trgm, partial), Neon MCP, y referencia a `infra-secrets.md` para credenciales y config de conexión.

## Reglas

### Filosofía de Cambios

#### Cambios Pequeños y Enfocados
- **Un cambio lógico por commit** - Cada commit debe hacer exactamente una cosa
- Si una tarea se siente muy grande, divídela en subtareas
- Prefiere múltiples commits pequeños sobre uno grande
- Ejecuta ciclos de verificación después de cada cambio, no al final
- Los componentes nuevos que crees deben estar bien estructurados y organizados para que cualquier otra vista o módulo pueda reutilizarlos sin problema

**Calidad sobre velocidad. Pasos pequeños generan gran progreso.**

### Priorización de Tareas

Al elegir la siguiente tarea, prioriza en este orden:

1. **Decisiones de arquitectura y abstracciones base** - Primero la fundación
2. **Puntos de integración entre módulos** - Asegurar que los componentes conecten bien
3. **Incógnitas y trabajo exploratorio** - Reducir riesgos temprano
4. **Features estándar e implementación** - Construir sobre bases sólidas
5. **Polish, limpieza y wins rápidos** - Dejar lo fácil para el final

**Falla rápido en lo riesgoso. Guarda lo fácil para después.**

### Estándares de Calidad de Código

#### Código Conciso
Después de escribir cualquier archivo, pregúntate: *"¿Un ingeniero senior diría que esto está sobrecomplicado?"*

Si sí, **simplifica**.

#### Sin Sobre-Ingeniería
- Solo haz cambios que se pidieron directamente o que son claramente necesarios
- No agregues features más allá de lo que se pidió
- No refactorices código que no lo necesita
- Un bug fix no necesita limpiar el código alrededor
- Un feature simple no necesita configurabilidad extra

#### Código Limpio
- No llenes archivos solo por llenar
- No dejes código muerto - si no se usa, bórralo completamente
- Sé organizado, conciso y limpio en tu trabajo
- No dejes hacks de compatibilidad para código eliminado
- No dejes comentarios `// removed` ni re-exports de items borrados

#### Descomposición de Tareas
- Usa micro tareas - mientras más pequeña la tarea, mejor el código
- Divide trabajo complejo en unidades discretas y testeables
- Cada micro tarea debe poder completarse en una sesión enfocada

### Estructura del Proyecto
```
rentacar-modern/
├── backend/
│   ├── app/
│   │   ├── Actions/          (Analytics, Bookings, Cars, Customers, Invoices, etc.)
│   │   ├── Console/Commands/
│   │   ├── DataTransferObjects/
│   │   ├── Enums/
│   │   ├── Exceptions/
│   │   ├── GraphQL/          (Mutations, Queries, Resolvers, Validators)
│   │   ├── Http/             (Controllers, Middleware)
│   │   ├── Models/Concerns/
│   │   ├── Policies/
│   │   ├── Services/Messaging/
│   │   └── Support/          (Dashboard, Printing)
│   ├── config/
│   ├── database/             (factories, migrations, seeders)
│   ├── graphql/              (enums, inputs, mutations, queries, types)
│   ├── lang/es/
│   ├── resources/views/      (pdf, thermal)
│   ├── routes/
│   └── tests/                (Feature, Unit)
│
├── frontend/
│   ├── public/               (car-angles, images)
│   └── src/
│       ├── core/             (api, composables, i18n, stores)
│       ├── features/         (analytics, auth, bookings, brands, cars, customers)
│       ├── shared/           (components, composables, config, constants, types, utils)
│       └── views/            (analytics, auth, billing, bookings, brands, cars, customers, gallery, maintenance, settings)
│
├── worker/
├── docker/                   (backend, cloudflare)
├── docs/plans/
└── scripts/
```

### Estándares de Código
- Lenguaje: TypeScript (modo estricto)
- Linting: ESLint + eslint-plugin-vue + @vue/eslint-config-typescript
- Formato: Prettier (tabs, doble comilla, 100 chars, LF)
- PHP: Laravel Pint
- Ejecutar `bun run check` antes de commitear (eslint + prettier)
- Ejecutar `bun run format` para auto-formatear

### Testing
- Escribir tests para features nuevos
- Correr tests antes de commitear: `bun test`
- Asegurar que el linting pase: `bun run lint`
- Formatear código: `bun run format`

### Guía de Commits

1. Un cambio lógico por commit
2. Escribir mensajes de commit descriptivos
3. Formato de mensaje: `tipo: descripción breve`
   - `feat:` feature nuevo
   - `fix:` corrección de bug
   - `refactor:` reestructuración de código
   - `docs:` documentación
   - `test:` agregar/cambiar tests
   - `chore:` tareas de mantenimiento

### Deuda Técnica

Este código va a durar más que tú. Cada atajo que tomes se convierte en la carga de alguien más. Cada hack se acumula en deuda técnica que frena a todo el equipo.

No solo estás escribiendo código. Estás moldeando el futuro de este proyecto. Los patrones que establezcas serán copiados. Los atajos que tomes se repetirán.

**Lucha contra la entropía. Deja el código mejor de como lo encontraste.**

## Flujo de Trabajo Dev

### Deploy y monitoreo
OBLIGATORIO: Monitorear en background después de cada `git push` y cada `wrangler deploy`. Si falla, investigar de inmediato.
- **Push**: `gh run list --branch <branch> --limit 1` → `gh run watch <run_id> --exit-status`
- **Wrangler**: confirmar que está live (~15s para que el container esté disponible)
- **Fallo**: `gh run view <run_id> --log-failed`

**Deploy completo** (cuando el usuario lo pida):
1. `git add <archivos> && git commit && git push origin dev` → monitorear CI
2. `npx wrangler containers list --env dev` → `npx wrangler containers delete <id> --env dev` para `triprd-api-dev-triprdapi-dev` y `triprd-api-dev-triprdjobs-dev`
3. `npx wrangler deploy --env dev` → monitorear deploy

**IMPORTANTE**: Nunca eliminar los containers de producción (`triprd-api-triprdapi`, `triprd-api-triprdjobs`).
