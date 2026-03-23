# Dotfiles — LMDE 7 Dev Environment

Configuracion completa de entorno de desarrollo para Linux Mint Debian Edition 7. Incluye workspace tmux, Claude Code con equipo de agentes AI, y herramientas de desarrollo.

## Quick Start

```bash
git clone https://github.com/Nemog17/lmde7-dotfiles-20260227.git ~/dotfiles
~/dotfiles/install.sh
```

En una nueva terminal:

```bash
cd tu-proyecto
setup-claude        # Instala skills, MCPs, agentes, HUD, CLIs
code                # Abre workspace tmux
```

## Que incluye

### Scripts (`bin/`)

| Script | Descripcion |
|--------|-------------|
| `code` | Workspace tmux: Claude Code + Yazi + Lazygit + Lazydocker (4 panes) |
| `setup-dev-env` | Instala entorno completo: tmux, Kitty, Claude Code + HUD, Yazi, Lazygit, Lazydocker |
| `setup-claude` | Instala skills, MCP servers, agentes, CLI tools y HUD en cualquier proyecto |
| `agents` | Ver y gestionar agentes (`agents list`, `agents info pm`, `agents project`) |
| `setup-rentacar` | Clona y levanta rentacar-modern con Docker |
| `migrate-vm` | Migra VMs (QEMU/libvirt) entre distros |

### Claude Code (`claude/`)

```
claude/
├── CLAUDE.md                 # Instrucciones globales + routing de agentes
├── settings/
│   └── settings.json         # Config completa: HUD, plugins, permisos, idioma
└── agents/
    ├── pm.md                 # PM Agent — orquestador (Opus, max effort)
    ├── frontend.md           # Frontend — Vue.js, Tailwind, mobile-first (Sonnet)
    ├── backend.md            # Backend — Laravel 12, GraphQL, Actions (Sonnet)
    ├── dba.md                # DBA — PostgreSQL, Neon, multi-tenancy (Sonnet)
    └── devops.md             # DevOps — Cloudflare, CI/CD, Docker (Sonnet)
```

## Arquitectura de agentes

```
                USUARIO
                  |
          🎯 PM AGENT (Opus)
             /    |    \     \
    🎨 Frontend ⚙️ Backend 🗄️ DBA 🚀 DevOps    Equipo interno (Sonnet)
       - - - - - - - - - - - - - - - -
       Codex            Gemini                   Externos (solo si autorizas)
       (refactors)      (prototipos)
```

### 🎯 PM Agent — El orquestador (OBLIGATORIO)

PM es el agente principal de TODA sesion. Se configura automaticamente via `"agent": "pm"` en settings.json + un hook `UserPromptSubmit` que refuerza la regla en cada prompt.

No escribe codigo. Planifica, delega, revisa y coordina. Se comunica con el usuario en espanol simple y con los agentes en tecnicismos precisos como un Staff Engineer.

**Paso cero**: Lee CLAUDE.md (proyecto + global) ANTES de cualquier otra cosa — nunca delega sin conocer las reglas.

**Identidad visual**: Siempre se identifica con banner `🎯 PM Agent` y reporta con citas del equipo (`> 🎨 Frontend Agent: ...`).

**Delegacion**: NUNCA lee archivos de codigo directamente. Delega toda investigacion al agente apropiado y sintetiza los reportes.

**Flujo**: Leer CLAUDE.md -> Analizar dominios -> Delegar investigacion -> Sintetizar reportes -> Planificar -> Ejecutar -> Revisar -> Reportar

**Orden de dependencias**: 🗄️ DBA (schema) -> ⚙️ Backend (APIs) -> 🎨 Frontend (UI) -> 🚀 DevOps (deploy)

### Agentes especializados

| Agente | Emoji | Modelo | Dominio | Herramientas |
|--------|-------|--------|---------|-------------|
| **PM** | 🎯 | Opus | Coordinacion, arquitectura | Swarmify MCP |
| **Frontend** | 🎨 | Sonnet | Vue.js 3, Tailwind, Basecoat, mobile-first | shadcn MCP, Vuetify MCP, Context7, skills (emil-design-eng, shadcn) |
| **Backend** | ⚙️ | Sonnet | Laravel 12, GraphQL (Lighthouse), Actions, Sanctum, Spatie | Laravel Boost MCP, Context7 |
| **DBA** | 🗄️ | Sonnet | PostgreSQL, multi-tenancy, migraciones, indexes, constraints | Neon MCP (branches, SQL, schemas) |
| **DevOps** | 🚀 | Sonnet | Cloudflare (Workers/Containers/Pages/R2), GitHub Actions, Docker | gh, wrangler, neonctl CLIs |

### Agentes externos (bajo autorizacion)

| Agente | Para que |
|--------|---------|
| **Codex CLI** | Refactorizar codigo, implementar features, resolver bugs |
| **Gemini CLI** | Prototipos de diseno, previsualizacion de UI en local |

## MCP Servers

| MCP | Funcion |
|-----|---------|
| **shadcn** | Buscar e instalar componentes de shadcn/ui |
| **Vuetify** | Referencia de componentes Vue |
| **Neon** | PostgreSQL serverless: branches, SQL, schemas, queries lentos |
| **Laravel Boost** | Inspeccion de modelos, rutas, schema Laravel |
| **Context7** | Documentacion actualizada de cualquier libreria |
| **Swarmify agents-mcp** | Orquestacion de agentes externos |

## Skills

| Skill | Funcion |
|-------|---------|
| **emil-design-eng** | Filosofia de diseno UI, animaciones, micro-interacciones (Emil Kowalski) |
| **shadcn** | Patrones shadcn/ui, theming OKLCH, componentes, CLI, registries |

## setup-claude — Menu interactivo

Detecta que ya esta instalado y solo instala lo que falta. Funciona en cualquier proyecto.

```
Skills:     1) emil-design-eng    2) shadcn
MCPs:       3) shadcn MCP         4) Swarmify agents-mcp    5) Context7
Agentes:    6) PM, Frontend, Backend, DBA, DevOps
CLIs:       7) gh                 8) wrangler               9) neonctl
HUD:        10) Claude HUD

Rapido:     a) todo    s) skills    m) MCPs    c) CLIs    q) salir
```

Siempre sincroniza `settings.json` al final (HUD, plugins, permisos, idioma).

## install.sh — Que hace

1. Crea symlinks de `bin/` a `~/.local/bin/`
2. Agrega `~/.local/bin` al PATH (`.bashrc` y `.zshrc`)
3. Copia `CLAUDE.md` y agentes a `~/.claude/`
4. Copia `settings.json` a `~/.claude/` (con backup si ya existe)
5. Menu: instalar entorno de desarrollo, VMs, o solo symlinks

## Workspace tmux (`code`)

```bash
code                    # Directorio actual
code ~/mi-proyecto      # Directorio especifico
```

```
┌──────────────────┬──────────────────┐
│                  │                  │
│   Claude Code    │      Yazi        │
│   (AI assistant) │  (file manager)  │
│                  │                  │
├──────────────────┼──────────────────┤
│                  │                  │
│    Lazygit       │   Lazydocker     │
│   (git TUI)      │  (Docker TUI)    │
│                  │                  │
└──────────────────┴──────────────────┘
```

Claude Code se lanza con: `--permission-mode plan --effort max`

## Configuracion de Claude Code (`settings.json`)

Se sincroniza automaticamente. Incluye:

- **Agent**: `pm` — PM arranca como agente principal en cada sesion
- **Hook**: `UserPromptSubmit` — inyecta 4 reglas obligatorias en cada prompt: (1) usar PM, (2) no trabajar directo en código, (3) usar AskUserQuestion, (4) PM NUNCA lee código — siempre delega a agentes en background
- **HUD**: Statusline con info de sesion, tokens, modelo, git
- **Plugins**: superpowers, frontend-design, feature-dev, context7, coderabbit, playwright, LSPs (TypeScript, PHP, Python), Figma, Notion, y mas
- **Idioma**: Espanol
- **Auto-memory**: Habilitado
- **Permisos**: Plan mode por defecto
