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

# --- oh-my-zsh + plugins/theme referenced by .zshrc ---
# Installed before symlinking .zshrc so the first `zsh` after install works.
ZSH_DIR="${ZSH:-$HOME/.oh-my-zsh}"
ZSH_CUSTOM="$ZSH_DIR/custom"

if [ ! -d "$ZSH_DIR" ]; then
  if command -v curl >/dev/null 2>&1; then
    echo "    installing oh-my-zsh"
    RUNZSH=no KEEP_ZSHRC=yes sh -c \
      "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
      "" --unattended --keep-zshrc
  else
    echo "    ! curl not found — skipping oh-my-zsh install"
  fi
else
  echo "    oh-my-zsh already installed: $ZSH_DIR"
fi

clone_if_missing() {
  local repo="$1" dest="$2"
  if [ -d "$dest" ]; then
    echo "    already present: $dest"
  else
    echo "    cloning $repo -> $dest"
    git clone --depth=1 "$repo" "$dest"
  fi
}

if [ -d "$ZSH_DIR" ]; then
  clone_if_missing https://github.com/romkatv/powerlevel10k.git \
    "$ZSH_CUSTOM/themes/powerlevel10k"
  clone_if_missing https://github.com/zsh-users/zsh-autosuggestions.git \
    "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
  clone_if_missing https://github.com/zdharma-continuum/fast-syntax-highlighting.git \
    "$ZSH_CUSTOM/plugins/fast-syntax-highlighting"
fi

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
# Install the Claude Code CLI if missing. Requires npm on $PATH.
if ! command -v claude >/dev/null 2>&1; then
  if command -v npm >/dev/null 2>&1; then
    echo "    installing Claude Code CLI via npm (@anthropic-ai/claude-code)"
    npm install -g @anthropic-ai/claude-code
  else
    echo "    ! npm not found — skipping Claude Code CLI install."
    echo "      Install Node.js/npm, then run: npm install -g @anthropic-ai/claude-code"
  fi
else
  echo "    claude already installed: $(command -v claude)"
fi

link .claude/CLAUDE.md "$HOME/.claude/CLAUDE.md"
# Memory directory is NOT symlinked — it's pointed to via autoMemoryDirectory
# in ~/.claude/settings.json. See README.md step 4.

# Subagents and skills are symlinked at the directory level so adding new
# agents/skills inside the repo automatically appears in $HOME without a re-run.
link .claude/agents "$HOME/.claude/agents"
link .claude/skills "$HOME/.claude/skills"

# --- Personal scripts (bin/) ---
link bin/rke2-cert-check "$HOME/bin/rke2-cert-check"

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
