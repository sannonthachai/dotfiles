#!/usr/bin/env bash
# install.sh — symlink dotfiles from this repo into $HOME.
# Safe to re-run. Backs up existing non-symlink files to *.bak once.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS="$(uname -s)"

echo "==> Installing dotfiles from $REPO_DIR"
echo "    OS: $OS"
echo

# link SRC (relative to repo) -> DEST (absolute path)
link() {
  local src="$REPO_DIR/$1"
  local dest="$2"

  if [ ! -e "$src" ]; then
    echo "    ! source missing: $src — skipping"
    return
  fi

  mkdir -p "$(dirname "$dest")"

  if [ -L "$dest" ]; then
    rm "$dest"
  elif [ -e "$dest" ]; then
    echo "    backing up existing: $dest -> $dest.bak"
    mv "$dest" "$dest.bak"
  fi

  ln -s "$src" "$dest"
  echo "    linked: $dest -> $src"
}

# --- Shell / editor ---
link .zshrc          "$HOME/.zshrc"
link .gitconfig      "$HOME/.gitconfig"
link .editorconfig   "$HOME/.editorconfig"

# --- Vim / Neovim ---
link .vimrc                              "$HOME/.vimrc"
link .config/nvim/init.vim               "$HOME/.config/nvim/init.vim"
link .config/nvim/coc-settings.json      "$HOME/.config/nvim/coc-settings.json"

# --- tmux ---
link .tmux.conf        "$HOME/.tmux.conf"
link .tmux.conf.local  "$HOME/.tmux.conf.local"

# --- Claude Code ---
link .claude/CLAUDE.md "$HOME/.claude/CLAUDE.md"
# Memory directory is NOT symlinked — it's pointed to via autoMemoryDirectory
# in ~/.claude/settings.json. See README.md step 4.

# --- Alacritty ---
# On Linux/macOS, symlink into ~/.config/alacritty
# On Windows, users should copy manually to %APPDATA%\alacritty\
case "$OS" in
  Linux|Darwin)
    link .config/alacritty/alacritty.toml "$HOME/.config/alacritty/alacritty.toml"
    ;;
  *)
    echo "    skipping alacritty on $OS (copy .config/alacritty/alacritty.toml to %APPDATA%\\alacritty\\ manually)"
    ;;
esac

echo
echo "==> Done."
echo
echo "Next steps:"
echo "  1. Edit ~/.claude/settings.json and add:"
echo '       "autoMemoryDirectory": "~/sannonthachai/dotfiles/.claude/memory"'
echo "  2. Open Vim and run :PlugInstall"
echo "  3. For tmux, reload with: tmux source-file ~/.tmux.conf"
