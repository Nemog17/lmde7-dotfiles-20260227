#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# install.sh: Bootstrap del entorno de desarrollo
# Uso en maquina nueva:
#   git clone https://github.com/Nemog17/dotfiles.git ~/dotfiles && ~/dotfiles/install.sh
# ============================================================================

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Dotfiles dir: $DOTFILES_DIR"

# --- Crear ~/.local/bin si no existe ---
mkdir -p "$HOME/.local/bin"

# --- Symlinks de bin/ ---
for script in "$DOTFILES_DIR"/bin/*; do
    name="$(basename "$script")"
    target="$HOME/.local/bin/$name"

    if [[ -L "$target" ]] && [[ "$(readlink -f "$target")" == "$(readlink -f "$script")" ]]; then
        echo "[ok] $name ya vinculado"
    else
        ln -sf "$script" "$target"
        echo "[+]  $name -> $target"
    fi
done

# --- Ejecutar setup-dev-env ---
echo ""
echo "Ejecutando setup-dev-env..."
echo ""
exec "$DOTFILES_DIR/bin/setup-dev-env"
