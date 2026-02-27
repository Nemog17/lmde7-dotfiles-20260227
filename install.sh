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
echo "  1) Entorno de desarrollo completo (tmux, Kitty, Claude, Yazi, Lazygit, Lazydocker)"
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
        echo "  setup-dev-env  - instalar entorno de desarrollo"
        echo "  code           - abrir workspace tmux"
        echo "  migrate-vm     - migrar VMs entre distros"
        ;;
    *)
        echo ""
        echo "Opcion invalida. Solo se crearon los symlinks."
        echo "Puedes ejecutar manualmente: setup-dev-env o migrate-vm setup"
        ;;
esac
