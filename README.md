# Dotfiles — LMDE 7 Dev Environment

Configuracion completa de entorno de desarrollo para Linux Mint Debian Edition 7.

## Quick Start

```bash
git clone https://github.com/Nemog17/lmde7-dotfiles-20260227.git ~/dotfiles
~/dotfiles/install.sh
```

## Que incluye

### Scripts (`bin/`)

| Script | Descripcion |
|--------|-------------|
| `code` | Abre un workspace tmux con 4 panes: Claude Code, Yazi, Lazygit, Lazydocker |
| `setup-dev-env` | Instala entorno de desarrollo completo (tmux, Kitty, Claude + HUD, Yazi, Lazygit, Lazydocker) |
| `setup-claude` | Instala skills, MCP servers, agentes y CLI tools en cualquier proyecto |
| `setup-rentacar` | Clona y levanta el proyecto rentacar-modern con Docker |
| `migrate-vm` | Migra VMs (QEMU/libvirt) entre distros |

### Claude Code (`claude/`)

Configuracion completa de Claude Code con equipo de agentes especializados:

```
claude/
├── CLAUDE.md              # Instrucciones globales (se copia a ~/.claude/)
└── agents/
    ├── pm.md              # PM Agent — orquestador (Opus)
    ├── frontend.md        # Frontend — Vue.js, Tailwind, mobile-first (Sonnet)
    ├── backend.md         # Backend — Laravel 12, GraphQL, Actions (Sonnet)
    ├── dba.md             # DBA — PostgreSQL, migraciones, Neon (Sonnet)
    └── devops.md          # DevOps — Cloudflare, CI/CD, Docker (Sonnet)
```

#### Estructura de agentes

```
              USUARIO
                |
            PM AGENT (Opus)
           /    |    \     \
     Frontend Backend DBA  DevOps     Equipo interno (Sonnet)
     - - - - - - - - - - - - - - -
     Codex          Gemini            Externos (solo si autorizas)
```

- **PM Agent**: No escribe codigo. Planifica, delega, revisa y coordina. Habla con el usuario en espanol simple y con los agentes en tecnicismos precisos.
- **Frontend**: Vue.js 3, Tailwind CSS, shadcn/Basecoat, mobile-first, Context7 para docs.
- **Backend**: Laravel 12, GraphQL (Lighthouse), Actions, Sanctum, Spatie, Neon MCP.
- **DBA**: PostgreSQL, multi-tenancy, EXCLUDE constraints, pg_trgm, materialized views, Neon branches.
- **DevOps**: Cloudflare Workers/Containers/Pages/R2, GitHub Actions, Docker, wrangler/gh/neonctl CLIs.

#### MCP Servers utilizados

- **shadcn MCP**: Buscar e instalar componentes de shadcn/ui
- **Vuetify MCP**: Referencia de componentes Vue
- **Neon MCP**: Gestion de PostgreSQL serverless (branches, SQL, schemas)
- **Laravel Boost MCP**: Inspeccion de modelos y rutas Laravel
- **Context7**: Documentacion actualizada de cualquier libreria
- **Swarmify Agents MCP**: Orquestacion de agentes externos (Codex, Gemini)

#### Skills instalados

- **emil-design-eng**: Filosofia de diseno UI, animaciones, micro-interacciones
- **shadcn**: Patrones y APIs de shadcn/ui, theming, OKLCH

## Instalacion

El script `install.sh` hace todo automaticamente:

1. Crea symlinks de `bin/` a `~/.local/bin/`
2. Agrega `~/.local/bin` al PATH
3. Copia `CLAUDE.md` y agentes a `~/.claude/`
4. Opcionalmente instala herramientas de desarrollo o VMs

## Uso del workspace

```bash
# Abrir workspace en el directorio actual
code

# Abrir workspace en un directorio especifico
code ~/rentacar-modern
```

Esto abre tmux con 4 panes:
- **Claude Code** (arriba izq) — AI assistant con agentes configurados
- **Yazi** (arriba der) — file manager
- **Lazygit** (abajo izq) — git TUI
- **Lazydocker** (abajo der) — Docker TUI
