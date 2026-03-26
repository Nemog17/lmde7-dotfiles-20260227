#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# install.sh: Bootstrap del entorno de desarrollo
# Uso en maquina nueva:
#   git clone https://github.com/Nemog17/lmde7-dotfiles-20260227.git ~/dotfiles && ~/dotfiles/install.sh
# ============================================================================

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# --- Colores ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo -e "${BOLD}========================================${NC}"
echo -e "${BOLD}  Dotfiles Installer${NC}"
echo -e "${BOLD}========================================${NC}"
echo -e "  Directorio: $DOTFILES_DIR"
echo ""

# --- Crear ~/.local/bin si no existe ---
mkdir -p "$HOME/.local/bin"

# --- Symlinks de bin/ ---
echo -e "${BLUE}[*]${NC} Creando symlinks..."
for script in "$DOTFILES_DIR"/bin/*; do
    name="$(basename "$script")"
    target="$HOME/.local/bin/$name"

    if [[ -L "$target" ]] && [[ "$(readlink -f "$target")" == "$(readlink -f "$script")" ]]; then
        echo -e "  ${GREEN}[ok]${NC} $name ya vinculado"
    else
        ln -sf "$script" "$target"
        echo -e "  ${GREEN}[+]${NC}  $name -> $target"
    fi
done

# --- Claude Code: CLAUDE.md + Agents ---
echo ""
echo -e "${BLUE}[*]${NC} Configurando Claude Code agents..."

mkdir -p "$HOME/.claude/agents"

# Copiar CLAUDE.md global
if [[ -f "$DOTFILES_DIR/claude/CLAUDE.md" ]]; then
    cp "$DOTFILES_DIR/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
    echo -e "  ${GREEN}[+]${NC}  CLAUDE.md -> ~/.claude/CLAUDE.md"
fi

# Copiar agentes
for agent in "$DOTFILES_DIR"/claude/agents/*.md; do
    name="$(basename "$agent")"
    cp "$agent" "$HOME/.claude/agents/$name"
    echo -e "  ${GREEN}[+]${NC}  Agent: $name"
done

# Copiar settings.json (con HUD, plugins, permisos)
if [[ -f "$DOTFILES_DIR/claude/settings/settings.json" ]]; then
    if [[ -f "$HOME/.claude/settings.json" ]]; then
        echo -e "  ${YELLOW}[!]${NC}  settings.json ya existe — backup en settings.json.bak"
        cp "$HOME/.claude/settings.json" "$HOME/.claude/settings.json.bak"
    fi
    cp "$DOTFILES_DIR/claude/settings/settings.json" "$HOME/.claude/settings.json"
    echo -e "  ${GREEN}[+]${NC}  settings.json (HUD, plugins, permisos)"
fi

# Copiar skills locales a ~/.claude/skills/
if [[ -d "$DOTFILES_DIR/claude/skills" ]]; then
    mkdir -p "$HOME/.claude/skills"
    for skill_dir in "$DOTFILES_DIR/claude/skills"/*/; do
        name="$(basename "$skill_dir")"
        cp -r "$skill_dir" "$HOME/.claude/skills/$name"
        echo -e "  ${GREEN}[+]${NC}  Skill: $name"
    done
fi

# --- Codex CLI config ---
echo ""
echo -e "${BLUE}[*]${NC} Configurando Codex CLI..."

if [[ -f "$DOTFILES_DIR/codex/config.toml" ]]; then
    if [[ -f "$HOME/.codex/config.toml" ]]; then
        echo -e "  ${YELLOW}[!]${NC}  ~/.codex/config.toml ya existe — no sobreescribiendo"
        echo -e "  ${BLUE}[i]${NC}  Revisa: $DOTFILES_DIR/codex/config.toml para los MCPs"
    else
        mkdir -p "$HOME/.codex"
        cp "$DOTFILES_DIR/codex/config.toml" "$HOME/.codex/config.toml"
        echo -e "  ${GREEN}[+]${NC}  ~/.codex/config.toml (MCPs: figma, swarm, sequential-thinking)"
    fi
fi

# --- Gemini CLI config ---
echo ""
echo -e "${BLUE}[*]${NC} Configurando Gemini CLI..."

if [[ -f "$DOTFILES_DIR/gemini/settings.json" ]]; then
    if [[ -f "$HOME/.gemini/settings.json" ]]; then
        echo -e "  ${YELLOW}[!]${NC}  ~/.gemini/settings.json ya existe — no sobreescribiendo"
        echo -e "  ${BLUE}[i]${NC}  Revisa: $DOTFILES_DIR/gemini/settings.json para los MCPs"
    else
        mkdir -p "$HOME/.gemini"
        cp "$DOTFILES_DIR/gemini/settings.json" "$HOME/.gemini/settings.json"
        echo -e "  ${GREEN}[+]${NC}  ~/.gemini/settings.json creado con placeholders"
        echo -e "  ${YELLOW}[!]${NC}  IMPORTANTE: Edita ~/.gemini/settings.json y reemplaza:"
        echo -e "             API_KEY_AQUI → tu API key de 21st.dev"
        echo -e "             TOKEN_AQUI   → tu Figma Personal Access Token"
    fi
fi

# --- PATH setup ---
line='export PATH="$HOME/.local/bin:$PATH"'
if ! grep -qF '.local/bin' "$HOME/.bashrc" 2>/dev/null; then
    echo "" >> "$HOME/.bashrc"
    echo "# Dev environment PATH" >> "$HOME/.bashrc"
    echo "$line" >> "$HOME/.bashrc"
    echo -e "  ${GREEN}[+]${NC}  PATH agregado a .bashrc"
fi
if [[ -f "$HOME/.zshrc" ]] && ! grep -qF '.local/bin' "$HOME/.zshrc" 2>/dev/null; then
    echo "" >> "$HOME/.zshrc"
    echo "# Dev environment PATH" >> "$HOME/.zshrc"
    echo "$line" >> "$HOME/.zshrc"
    echo -e "  ${GREEN}[+]${NC}  PATH agregado a .zshrc"
fi

# --- Menu de instalacion ---
echo ""
echo -e "${BOLD}Que quieres instalar?${NC}"
echo ""
echo "  1) Entorno de desarrollo completo (tmux, Kitty, Claude + HUD, Yazi, Lazygit, Lazydocker)"
echo "  2) Solo herramientas de VM (QEMU, libvirt, OVMF, swtpm)"
echo "  3) Todo (dev env + VMs)"
echo "  4) Nada (solo symlinks y PATH)"
echo ""
read -rp "Opcion [1-4]: " choice

case "$choice" in
    1)
        echo ""
        "$DOTFILES_DIR/bin/setup-dev-env"
        ;;
    2)
        echo ""
        "$DOTFILES_DIR/bin/migrate-vm" setup
        ;;
    3)
        echo ""
        "$DOTFILES_DIR/bin/setup-dev-env"
        echo ""
        "$DOTFILES_DIR/bin/migrate-vm" setup
        ;;
    4)
        echo ""
        echo -e "${GREEN}${BOLD}Symlinks creados. Los comandos estan disponibles en una nueva terminal:${NC}"
        echo "  setup-dev-env   - instalar entorno de desarrollo"
        echo "  setup-rentacar  - clonar y levantar rentacar-modern con Docker"
        echo "  setup-claude    - instalar skills, MCPs y agentes en un proyecto"
        echo "  code            - abrir workspace tmux"
        echo "  migrate-vm      - migrar VMs entre distros"
        ;;
    *)
        echo ""
        echo "Opcion invalida. Solo se crearon los symlinks."
        echo "Puedes ejecutar manualmente: setup-dev-env o migrate-vm setup"
        ;;
esac
