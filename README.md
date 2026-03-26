# Dotfiles — LMDE 7 Dev Environment

Configuracion completa de entorno de desarrollo para Linux Mint Debian Edition 7. Incluye workspace tmux, Claude Code con dev-team lean (5 persistentes + 3 on-demand), MCPs por plataforma (Claude/Codex/Gemini), y herramientas de desarrollo.

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
├── CLAUDE.md                   # Instrucciones globales + routing de agentes
├── claude.json.template        # MCPs globales de Claude Code (con placeholders)
├── settings/
│   └── settings.json           # Config completa: HUD, plugins, permisos, idioma
├── agents/
│   ├── pm.md                   # PM Agent — orquestador (solo con @pm)
│   ├── prompt-engineer.md      # Prompt Engineer — PRDs, specs, briefs (Opus)
│   ├── frontend.md             # Frontend — Vue.js, Tailwind, shadcn (Opus)
│   ├── backend.md              # Backend — Laravel 12, GraphQL, Actions (Sonnet)
│   ├── dba.md                  # DBA — PostgreSQL, Neon, multi-tenancy (Opus)
│   ├── devops.md               # DevOps — Cloudflare, CI/CD, Docker (Sonnet)
│   ├── fullstack.md            # Fullstack — features end-to-end (Opus, on-demand)
│   ├── codex-agent.md          # Codex Agent — consultor técnico via Codex CLI
│   ├── gemini-agent.md         # Gemini Agent — diseñador via Gemini CLI
│   └── ralphy.md               # Ralphy — CLI autónomo para tareas largas
├── skills/
│   ├── frontend-comms/         # Comunicacion entre componentes frontend
│   └── prompt-engineer/        # Ingenieria de prompts avanzada
└── teams/
    └── dev-team.md             # Configuracion del dev-team lean (5+3)
```

### Configs de Herramientas AI

```
codex/
└── config.toml     # MCPs de Codex CLI: figma (url), swarm, sequential-thinking

gemini/
└── settings.json   # MCPs de Gemini CLI: magic, figma (con placeholders de tokens)

ralphy/
└── config.yaml     # Template de config para proyectos Ralphy
```

## Arquitectura de agentes — Dev-Team Lean (5+3)

```
                    USUARIO
                      |
             Lead (Opus 4.6 1M)
           Staff Engineer + coord.
        /      |      |      |      \
  prompt-   codex   gemini  dba   devops
   eng     (Codex  (Gemini (Opus) (Sonnet)
  (Opus)    CLI)    CLI)

  On-demand (Agent tool, sin team_name):
  @fullstack (Opus)  @frontend (Opus)  @backend (Sonnet)  @pm (solo con @pm)

  CLI autonomo: ralphy (loop largo, tareas desatendidas)
```

### Persistentes (siempre activos en dev-team)

| Agente | Modelo | Rol | Herramientas |
|--------|--------|-----|-------------|
| **prompt-engineer** | Opus | Redactar PRDs, refinar specs, mejorar prompts | superpowers:brainstorming |
| **dba** | Opus | PostgreSQL, multi-tenancy, migraciones, indexes | Neon MCP |
| **devops** | Sonnet | Cloudflare, CI/CD, Docker, GitHub Actions | gh, wrangler, neonctl |
| **codex-agent** | Sonnet | Consultor técnico via Codex CLI — debugging, code review | agents-mcp |
| **gemini-agent** | Sonnet | Diseñador via Gemini CLI — prototipos UI, briefs | agents-mcp |

### On-demand (lanzar con Agent tool, descartar al terminar)

| Agente | Modelo | Cuándo usarlo |
|--------|--------|--------------|
| **fullstack** | Opus | Features end-to-end que cruzan backend + frontend |
| **frontend** | Opus | Tareas exclusivamente de UI: componentes, estilos, animaciones |
| **backend** | Sonnet | Tareas exclusivamente de backend: APIs, GraphQL, testing |
| **pm** | Opus | Solo si el usuario escribe `@pm` explícitamente |

### Regla DIFF vs WHOLE

El lead NUNCA pide reescribir archivos completos. Siempre delega con:
- Archivo exacto + número de línea
- Código actual vs código nuevo
- Razón del cambio

Los teammates usan el formato `📁📍🔍✏️💡` del CLAUDE.md.

### Orden de ejecución con dependencias

```
DBA (schema) → Backend (APIs) → Frontend (UI) → DevOps (deploy)
                    ↕                  ↕
              codex-agent         gemini-agent
           (consulta técnica)    (diseño previo)
```

## MCP Servers por Plataforma

### Claude Code (`~/.claude.json`)

| MCP | Tipo | Funcion |
|-----|------|---------|
| **Neon** | HTTP | PostgreSQL serverless: branches, SQL, schemas, queries lentos |
| **Context7** | HTTP | Documentacion actualizada de cualquier libreria |
| **Swarm** | stdio | Orquestacion de agentes externos (Codex, Gemini) |

Template en `dotfiles/claude/claude.json.template` (tokens como placeholders).

### Claude Code (proyecto `.mcp.json`)

| MCP | Funcion |
|-----|---------|
| **shadcn** | Buscar e instalar componentes de shadcn/ui |
| **Vuetify** | Referencia de componentes Vue |
| **Laravel Boost** | Inspeccion de modelos, rutas, schema Laravel |
| **agents-mcp** | Orquestacion de Codex CLI y Gemini CLI |

### Codex CLI (`~/.codex/config.toml`)

| MCP | Funcion |
|-----|---------|
| **figma** (url) | Acceso a disenos de Figma |
| **swarm** | Orquestacion de agentes via agents-mcp |
| **sequential-thinking** | Razonamiento estructurado en cadena |

### Gemini CLI (`~/.gemini/settings.json` global)

| MCP | Funcion |
|-----|---------|
| **magic** | Generar componentes UI desde texto (21st.dev) |
| **figma** | Acceso a disenos de Figma via token personal |

### Gemini CLI (proyecto `backend/.gemini/settings.json`)

| MCP | Funcion |
|-----|---------|
| **laravel-boost** | Inspeccion de modelos y rutas Laravel |
| **tailwindcss** | Referencia de clases Tailwind |
| **a11y** | Auditoria de accesibilidad (axe-core) |

## Skills

### Via npm (setup-claude los instala)

| Skill | Fuente | Funcion |
|-------|--------|---------|
| **emil-design-eng** | emilkowalski/skill | Diseno UI, animaciones, micro-interacciones |
| **shadcn** | shadcn/ui | Patrones shadcn/ui, theming OKLCH, componentes, CLI |
| **antigravity-awesome-skills** | antigravity | Coleccion de 93 skills para Claude, Codex y Gemini |
| **planetscale/database-skills** | PlanetScale | 4 skills de base de datos para Claude, Codex y Gemini |
| **skill-creator** | anthropics/skills | Crear y publicar skills propios |

### Locales (en `dotfiles/claude/skills/`)

| Skill | Funcion |
|-------|---------|
| **frontend-comms** | Comunicacion entre componentes frontend (eventos, props, stores) |
| **prompt-engineer** | Ingenieria de prompts avanzada, redaccion de PRDs y specs |

## setup-claude — Menu interactivo

Detecta que ya esta instalado y solo instala lo que falta. Funciona en cualquier proyecto.

```
Skills:       1) emil-design-eng      2) shadcn
MCPs:         3) shadcn MCP           4) Swarmify agents-mcp    5) Context7
Agentes:      6) equipo dev-team
CLIs:         7) gh    8) wrangler    9) neonctl
HUD:          10) Claude HUD

Skills extra: 11) antigravity-awesome-skills   12) planetscale/database-skills
              13) skill-creator (Anthropic)     14) frontend-comms (local)
              15) prompt-engineer (local)

CLIs extra:   16) ralphy-cli    17) @googleworkspace/cli

Configs:      18) Codex CLI MCPs    19) Gemini CLI MCPs    20) Ralphy template

AI CLIs:      21) Claude Code    22) Codex CLI    23) Gemini CLI

Tokens:       24) Configurar API keys interactivo (Magic, Figma, Neon, Context7)
Claude MCPs:  25) Configurar ~/.claude.json (Neon, Context7, Swarm)

Rapido:  a) todo   s) skills(1-15)   m) MCPs   c) CLIs(7-17)   ai) AI CLIs   q) salir
```

Siempre sincroniza `settings.json` al final (HUD, plugins, permisos, idioma).

### CLIs disponibles

| CLI | Paquete | Funcion |
|-----|---------|---------|
| **gh** | system | GitHub: PRs, issues, workflows, secrets |
| **wrangler** | wrangler | Cloudflare Workers, Pages, R2, Containers |
| **neonctl** | neonctl | Neon branches, SQL, connection strings |
| **ralphy-cli** | ralphy-cli | Gestion de proyectos con IA |
| **@googleworkspace/cli** | @googleworkspace/cli | Drive, Docs, Sheets desde terminal |
| **claude** | @anthropic-ai/claude-code | Claude Code CLI |
| **codex** | @openai/codex | Codex CLI |
| **gemini** | @google/gemini-cli | Gemini CLI |

## install.sh — Que hace

1. Crea symlinks de `bin/` a `~/.local/bin/`
2. Agrega `~/.local/bin` al PATH (`.bashrc` y `.zshrc`)
3. Copia `CLAUDE.md`, agentes y skills locales a `~/.claude/`
4. Copia `settings.json` a `~/.claude/` (con backup si ya existe)
5. Copia `claude.json.template` a `~/.claude.json` (solo si no existe — no sobreescribe MCPs existentes)
6. Copia `codex/config.toml` a `~/.codex/config.toml` (solo si no existe)
7. Copia `gemini/settings.json` a `~/.gemini/settings.json` (solo si no existe, con placeholders)
8. Muestra instrucciones para reemplazar tokens (Magic, Figma, Neon, Context7)
9. Menu: instalar entorno de desarrollo, VMs, o solo symlinks

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

- **Agent**: lead del dev-team (Staff Engineer) — coordina sin PM por defecto. PM solo con `@pm`
- **Hook**: `UserPromptSubmit` — inyecta reglas obligatorias: AskUserQuestion antes de cambios, no trabajar directo en código, usar DIFF no WHOLE
- **HUD**: Statusline con info de sesion, tokens, modelo, git
- **Plugins**: superpowers, frontend-design, feature-dev, context7, coderabbit, playwright, LSPs (TypeScript, PHP, Python), Figma, Notion, y mas
- **Idioma**: Espanol
- **Auto-memory**: Habilitado
- **Permisos**: Plan mode por defecto
