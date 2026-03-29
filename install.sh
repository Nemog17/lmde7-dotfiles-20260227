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

# --- Validación de Dependencias ---
YELLOW='\033[0;33m'

_dep_version() {
    local cmd="$1"
    local v
    v=$("$cmd" --version 2>&1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
    [[ -z "$v" ]] && v=$("$cmd" -V 2>&1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
    echo "$v"
}

_MISSING=()
_OPTIONAL=()

_dep_row() {
    local label="$1" cmd="$2" optional="${3:-false}"
    if command -v "$cmd" &>/dev/null; then
        local v; v=$(_dep_version "$cmd")
        [[ -z "$v" ]] && v="instalado"
        printf "    ${GREEN}✓${NC} %-16s %s\n" "$label" "$v"
    elif [[ "$optional" == true ]]; then
        printf "    ${YELLOW}⚠${NC} %-16s %s\n" "$label" "no instalado (opcional)"
        _OPTIONAL+=("$cmd:$label")
    else
        printf "    ${BOLD}✗${NC} %-16s %s\n" "$label" "no instalado"
        _MISSING+=("$cmd:$label")
    fi
}

_docker_compose_row() {
    if docker compose version &>/dev/null 2>&1; then
        local v; v=$(docker compose version 2>&1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
        [[ -z "$v" ]] && v="instalado"
        printf "    ${GREEN}✓${NC} %-16s %s\n" "docker compose" "$v"
    else
        printf "    ${BOLD}✗${NC} %-16s %s\n" "docker compose" "no instalado"
        _MISSING+=("docker-compose:docker compose")
    fi
}

_install_one_dep() {
    local dep="$1" label="$2"
    echo -e "  ${BLUE}[*]${NC} Instalando ${label}..."
    case "$dep" in
        git)
            echo -e "      → Control de versiones. Base de todo el flujo de trabajo."
            sudo apt install -y git ;;
        curl)
            echo -e "      → Descarga archivos y herramientas desde la web."
            sudo apt install -y curl ;;
        jq)
            echo -e "      → Parser JSON. Requerido por hooks de RTK y scripts de automatización."
            sudo apt install -y jq ;;
        cargo)
            echo -e "      → Compilador Rust. Necesario para RTK, yazi y otras herramientas."
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
            # shellcheck source=/dev/null
            [[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env" ;;
        node)
            echo -e "      → Runtime JavaScript. Requerido por el frontend Vue.js."
            if command -v nvm &>/dev/null; then
                nvm install --lts
            else
                echo -e "      ${YELLOW}[!]${NC} nvm no encontrado — instalando via apt"
                sudo apt install -y nodejs npm
            fi ;;
        bun)
            echo -e "      → Bundler ultrarrápido. Reemplaza npm/vite en el frontend."
            curl -fsSL https://bun.sh/install | bash ;;
        php)
            echo -e "      → Runtime PHP. Requerido por el backend Laravel."
            sudo apt install -y php php-cli php-mbstring php-xml php-curl php-zip ;;
        composer)
            echo -e "      → Package manager PHP. Gestiona dependencias de Laravel."
            local _ecs _acs
            _ecs="$(php -r 'copy("https://composer.github.io/installer.sig", "php://stdout");')"
            php -r "copy('https://getcomposer.org/installer', '/tmp/composer-setup.php');"
            _acs="$(php -r "echo hash_file('sha384', '/tmp/composer-setup.php');")"
            if [[ "$_ecs" != "$_acs" ]]; then
                echo -e "      ${BOLD}✗${NC} Error: checksum de Composer inválido — abortando"
                rm -f /tmp/composer-setup.php
                return 1
            fi
            sudo php /tmp/composer-setup.php --quiet --install-dir=/usr/local/bin --filename=composer
            rm -f /tmp/composer-setup.php ;;
        docker)
            echo -e "      → Contenedores. Base del entorno local de desarrollo."
            sudo apt install -y docker.io docker-compose-plugin
            sudo usermod -aG docker "$USER"
            echo -e "      ${YELLOW}[!]${NC} Cierra sesión y vuelve a entrar para usar docker sin sudo" ;;
        docker-compose)
            echo -e "      → Orquestación de contenedores. Requerido para el entorno local."
            sudo apt install -y docker-compose-plugin ;;
        tmux)
            echo -e "      → Multiplexor de terminal. Sesiones persistentes y múltiples paneles."
            sudo apt install -y tmux ;;
        kitty)
            echo -e "      → Terminal GPU-acelerada. Mejor rendimiento para sesiones largas."
            curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin ;;
        lazygit)
            echo -e "      → UI de Git en terminal. Commits, diffs y rebases más visuales."
            local _lgv
            _lgv=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" \
                | grep -Po '"tag_name": "v\K[^"]*')
            curl -Lo /tmp/lazygit.tar.gz \
                "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${_lgv}_Linux_x86_64.tar.gz"
            tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
            sudo install /tmp/lazygit /usr/local/bin/lazygit
            rm -f /tmp/lazygit.tar.gz /tmp/lazygit ;;
        lazydocker)
            echo -e "      → UI de Docker en terminal. Monitorea contenedores y logs."
            local _ldv
            _ldv=$(curl -s "https://api.github.com/repos/jesseduffield/lazydocker/releases/latest" \
                | grep -Po '"tag_name": "v\K[^"]*')
            curl -Lo /tmp/lazydocker.tar.gz \
                "https://github.com/jesseduffield/lazydocker/releases/latest/download/lazydocker_${_ldv}_Linux_x86_64.tar.gz"
            tar xf /tmp/lazydocker.tar.gz -C /tmp lazydocker
            sudo install /tmp/lazydocker /usr/local/bin/lazydocker
            rm -f /tmp/lazydocker.tar.gz /tmp/lazydocker ;;
        yazi)
            echo -e "      → File manager en terminal. Navega el proyecto sin salir de la terminal."
            if command -v cargo &>/dev/null; then
                cargo install yazi-fm yazi-cli
            else
                echo -e "      ${YELLOW}[!]${NC} Requiere cargo — instala Rust primero"
                return 1
            fi ;;
        rtk)
            echo -e "      → Token optimizer. Reduce 60-90% de tokens en comandos de AI tools."
            if command -v cargo &>/dev/null; then
                cargo install rtk
            else
                echo -e "      ${YELLOW}[!]${NC} Requiere cargo — instala Rust primero"
                return 1
            fi ;;
    esac
    local _verify_cmd="$dep"
    [[ "$dep" == "docker-compose" ]] && _verify_cmd=""
    if [[ -n "$_verify_cmd" ]] && command -v "$_verify_cmd" &>/dev/null; then
        echo -e "  ${GREEN}✓${NC} ${label} instalado correctamente"
    else
        echo -e "  ${YELLOW}[!]${NC} ${label} puede necesitar reiniciar terminal para estar disponible"
    fi
    echo ""
}

_install_missing_deps() {
    # Instalar cargo primero si hay deps que lo requieren
    local _has_cargo_dep=false
    for _e in "${_MISSING[@]}"; do
        [[ "${_e%%:*}" == "rtk" || "${_e%%:*}" == "yazi" ]] && _has_cargo_dep=true && break
    done

    for _e in "${_MISSING[@]}"; do
        if [[ "${_e%%:*}" == "cargo" ]]; then
            _install_one_dep "cargo" "Rust + Cargo" || true
            break
        fi
    done

    for _e in "${_MISSING[@]}"; do
        local _dep="${_e%%:*}"
        local _lbl="${_e#*:}"
        [[ "$_dep" == "cargo" ]] && continue
        _install_one_dep "$_dep" "$_lbl" || true
    done
}

echo ""
echo -e "${BOLD}========================================${NC}"
echo -e "${BOLD}  Validación de Dependencias${NC}"
echo -e "${BOLD}========================================${NC}"
echo ""

echo -e "  Sistema base:"
_dep_row "git"    git
_dep_row "curl"   curl
_dep_row "jq"     jq

echo ""
echo -e "  Lenguajes:"
_dep_row "cargo"    cargo
_dep_row "node"     node
_dep_row "bun"      bun
_dep_row "php"      php
_dep_row "composer" composer

echo ""
echo -e "  Contenedores:"
_dep_row "docker" docker
_docker_compose_row

echo ""
echo -e "  Terminal:"
_dep_row "tmux"       tmux
_dep_row "kitty"      kitty true
_dep_row "lazygit"    lazygit
_dep_row "lazydocker" lazydocker
_dep_row "yazi"       yazi

echo ""
echo -e "  AI Tools:"
_dep_row "rtk" rtk

echo ""
_M=${#_MISSING[@]}
_O=${#_OPTIONAL[@]}

if [[ $_M -eq 0 && $_O -eq 0 ]]; then
    echo -e "  ${GREEN}${BOLD}Resultado: todas las dependencias están instaladas${NC}"
    echo ""
elif [[ $_M -eq 0 ]]; then
    echo -e "  ${YELLOW}Resultado: ${_O} opcional(es) sin instalar${NC}"
    echo ""
else
    _summary="${_M} dependencia(s) faltante(s)"
    [[ $_O -gt 0 ]] && _summary+=" + ${_O} opcional(es)"
    echo -e "  Resultado: ${_summary}"
    echo ""
    read -rp "  ¿Instalar las ${_M} dependencias faltantes? [S/n]: " _install_choice || true
    _install_choice="${_install_choice:-S}"
    echo ""
    if [[ "$_install_choice" =~ ^[SsYy] ]]; then
        _install_missing_deps
    else
        echo -e "  ${YELLOW}[!]${NC} Instalación omitida. Puede que estas cosas no funcionen:"
        for _e in "${_MISSING[@]}"; do
            echo -e "       - ${_e#*:}"
        done
        echo ""
    fi
fi

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

# --- RTK (Rust Token Killer) ---
echo ""
echo -e "${BLUE}[*]${NC} Configurando RTK (token savings para AI CLIs)..."

if command -v rtk &>/dev/null; then
    echo -e "  ${GREEN}[ok]${NC} rtk ya instalado: $(rtk --version 2>/dev/null | head -1)"
else
    if command -v cargo &>/dev/null; then
        echo -e "  ${BLUE}[*]${NC}  Instalando rtk via cargo..."
        cargo install rtk
        echo -e "  ${GREEN}[+]${NC}  rtk instalado"
    else
        echo -e "  ${YELLOW}[!]${NC}  rtk no instalado — requiere Rust/Cargo"
        echo -e "  ${BLUE}[i]${NC}  Instala Rust: https://rustup.rs/ y luego: cargo install rtk"
    fi
fi

# Symlink filters.toml → ~/.config/rtk/filters.toml
if [[ -f "$DOTFILES_DIR/rtk/filters.toml" ]]; then
    mkdir -p "$HOME/.config/rtk"
    if [[ -L "$HOME/.config/rtk/filters.toml" ]] && [[ "$(readlink -f "$HOME/.config/rtk/filters.toml")" == "$(readlink -f "$DOTFILES_DIR/rtk/filters.toml")" ]]; then
        echo -e "  ${GREEN}[ok]${NC} rtk/filters.toml ya vinculado"
    else
        ln -sf "$DOTFILES_DIR/rtk/filters.toml" "$HOME/.config/rtk/filters.toml"
        echo -e "  ${GREEN}[+]${NC}  rtk/filters.toml -> ~/.config/rtk/filters.toml"
    fi
fi

# Symlink hook → ~/.claude/hooks/rtk-rewrite.sh (requerido por settings.json)
if [[ -f "$DOTFILES_DIR/claude/hooks/rtk-rewrite.sh" ]]; then
    mkdir -p "$HOME/.claude/hooks"
    if [[ -L "$HOME/.claude/hooks/rtk-rewrite.sh" ]] && [[ "$(readlink -f "$HOME/.claude/hooks/rtk-rewrite.sh")" == "$(readlink -f "$DOTFILES_DIR/claude/hooks/rtk-rewrite.sh")" ]]; then
        echo -e "  ${GREEN}[ok]${NC} rtk-rewrite.sh ya vinculado"
    else
        ln -sf "$DOTFILES_DIR/claude/hooks/rtk-rewrite.sh" "$HOME/.claude/hooks/rtk-rewrite.sh"
        chmod +x "$DOTFILES_DIR/claude/hooks/rtk-rewrite.sh"
        echo -e "  ${GREEN}[+]${NC}  rtk-rewrite.sh -> ~/.claude/hooks/rtk-rewrite.sh"
    fi
fi

# Soporte para otras AI CLIs
echo -e "  ${BLUE}[i]${NC}  Claude Code: activo via hook PreToolUse (settings.json)"
echo -e "  ${BLUE}[i]${NC}  Codex CLI:   sin soporte de hooks — usar: rtk <cmd> manualmente"
echo -e "  ${BLUE}[i]${NC}  Gemini CLI:  sin soporte de hooks — usar: rtk <cmd> manualmente"

# --- Claude Code MCPs (~/.claude.json) ---
echo ""
echo -e "${BLUE}[*]${NC} Configurando Claude Code MCPs..."

if [[ -f "$DOTFILES_DIR/claude/claude.json.template" ]]; then
    if [[ -f "$HOME/.claude.json" ]]; then
        echo -e "  ${YELLOW}[!]${NC}  ~/.claude.json ya existe — no sobreescribiendo"
        echo -e "  ${BLUE}[i]${NC}  MCPs actuales: $(python3 -c "import json; d=json.load(open('$HOME/.claude.json')); print(', '.join(d.get('mcpServers', {}).keys()))" 2>/dev/null || echo 'ver archivo')"
    else
        cp "$DOTFILES_DIR/claude/claude.json.template" "$HOME/.claude.json"
        echo -e "  ${GREEN}[+]${NC}  ~/.claude.json creado con MCPs: Neon, Context7, Swarm"
        echo -e "  ${YELLOW}[!]${NC}  IMPORTANTE: Ejecuta setup-claude opcion 24 para configurar tokens"
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
