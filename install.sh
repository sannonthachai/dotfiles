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

# --- Homebrew (macOS) + Brewfile ---
# Install Homebrew if missing, then apply the Brewfile (CLI tools + GUI casks).
# Brewfile is the source of truth for what gets installed on a new Mac; the
# per-tool `install_pkg` blocks below are kept as a safety net for Linux/WSL.
if [ "$OS" = "Darwin" ]; then
  if ! command -v brew >/dev/null 2>&1; then
    if command -v curl >/dev/null 2>&1; then
      echo "    installing Homebrew"
      NONINTERACTIVE=1 /bin/bash -c \
        "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      # Add brew to PATH for the rest of this script
      if [ -x /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
      elif [ -x /usr/local/bin/brew ]; then
        eval "$(/usr/local/bin/brew shellenv)"
      fi
    else
      echo "    ! curl not found — install Homebrew manually: https://brew.sh"
    fi
  else
    echo "    homebrew already installed: $(command -v brew)"
  fi

  if command -v brew >/dev/null 2>&1 && [ -f "$REPO_DIR/Brewfile" ]; then
    echo "    applying Brewfile (brew bundle)"
    brew bundle --file="$REPO_DIR/Brewfile" || \
      echo "    ! brew bundle had failures — continuing"
  fi
fi

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
link .zshrc                  "$HOME/.zshrc"
link .zsh/completions        "$HOME/.zsh/completions"
link .gitconfig      "$HOME/.gitconfig"
link .editorconfig   "$HOME/.editorconfig"

# --- Vim / Neovim ---
# fzf + ripgrep — required by .vimrc fuzzy/search mappings (Ctrl-p, ,/).
install_pkg() {
  local bin="$1" pkg="${2:-$1}"
  if command -v "$bin" >/dev/null 2>&1; then
    echo "    $bin already installed: $(command -v "$bin")"
    return
  fi
  case "$OS" in
    Darwin)
      if command -v brew >/dev/null 2>&1; then
        echo "    installing $pkg via brew"
        brew install "$pkg" || echo "    ! brew install $pkg failed — continuing"
      else
        echo "    ! brew not found — install Homebrew then: brew install $pkg"
      fi
      ;;
    Linux)
      if command -v apt-get >/dev/null 2>&1; then
        echo "    installing $pkg via apt-get"
        { sudo apt-get update && sudo apt-get install -y "$pkg"; } \
          || echo "    ! apt-get install $pkg failed — continuing"
      else
        echo "    ! apt-get not found — install $pkg with your package manager"
      fi
      ;;
    *)
      echo "    ! unknown OS $OS — install $pkg manually"
      ;;
  esac
}
install_pkg fzf
install_pkg rg ripgrep

# --- DevOps CLIs ---
install_pkg kubectl
install_pkg k9s
install_pkg helm
# terraform is gated behind hashicorp/tap on brew; plain `brew install terraform`
# still works via the homebrew-core formula but may warn — keep simple here.
install_pkg terraform

# --- Container runtime (macOS only) ---
# Colima = free Docker Desktop alternative. Provides the Linux VM; `docker`
# CLI talks to it. Start with `colima start` after install.
if [ "$OS" = "Darwin" ]; then
  install_pkg colima
  install_pkg docker
  install_pkg docker-compose
fi

# vim-plug — required by .vimrc (`call plug#begin(...)`).
install_plug() {
  local dest="$1"
  if [ -f "$dest" ]; then
    echo "    vim-plug already present: $dest"
    return
  fi
  if command -v curl >/dev/null 2>&1; then
    echo "    installing vim-plug -> $dest"
    curl -fLo "$dest" --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  else
    echo "    ! curl not found — install vim-plug manually: $dest"
  fi
}
install_plug "$HOME/.vim/autoload/plug.vim"
install_plug "$HOME/.local/share/nvim/site/autoload/plug.vim"

link .vimrc                              "$HOME/.vimrc"
link .config/nvim/init.vim               "$HOME/.config/nvim/init.vim"
link .config/nvim/coc-settings.json      "$HOME/.config/nvim/coc-settings.json"

# instant-markdown-d — Node.js daemon required by vim-instant-markdown.
# Without it, opening .md files in vim throws "Node.js server unavailable".
if ! command -v instant-markdown-d >/dev/null 2>&1; then
  if command -v npm >/dev/null 2>&1; then
    echo "    installing instant-markdown-d via npm"
    npm install -g instant-markdown-d
  else
    echo "    ! npm not found — skipping instant-markdown-d install."
    echo "      Install Node.js/npm, then run: npm install -g instant-markdown-d"
  fi
else
  echo "    instant-markdown-d already installed: $(command -v instant-markdown-d)"
fi

# --- tmux ---
if ! command -v tmux >/dev/null 2>&1; then
  case "$OS" in
    Darwin)
      if command -v brew >/dev/null 2>&1; then
        echo "    installing tmux via brew"
        brew install tmux
      else
        echo "    ! brew not found — install Homebrew then: brew install tmux"
      fi
      ;;
    Linux)
      if command -v apt-get >/dev/null 2>&1; then
        echo "    installing tmux via apt-get"
        sudo apt-get update && sudo apt-get install -y tmux
      else
        echo "    ! apt-get not found — install tmux with your package manager"
      fi
      ;;
    *)
      echo "    ! unknown OS $OS — install tmux manually"
      ;;
  esac
else
  echo "    tmux already installed: $(command -v tmux)"
fi

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
# RTK.md is referenced by CLAUDE.md via `@RTK.md` (resolves to ~/.claude/RTK.md).
# The rtk Bash hook in settings.json is NOT tracked — regenerate with `rtk init -g`.
link .claude/RTK.md "$HOME/.claude/RTK.md"
# Memory directory is NOT symlinked — it's pointed to via autoMemoryDirectory
# in ~/.claude/settings.json. See README.md step 4.

# Subagents and skills are symlinked at the directory level so adding new
# agents/skills inside the repo automatically appears in $HOME without a re-run.
link .claude/agents "$HOME/.claude/agents"
link .claude/skills "$HOME/.claude/skills"

# --- Personal scripts (bin/) ---
link bin/rke2-cert-check "$HOME/bin/rke2-cert-check"
link bin/pm              "$HOME/bin/pm"
link bin/genpass         "$HOME/bin/genpass"

# pm depends on pass + gpg
install_pkg pass
install_pkg gpg gnupg

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
