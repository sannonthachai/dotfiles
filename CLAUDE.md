# Project: dotfiles

My personal dotfiles repository. Holds shell, editor, terminal, and Claude Code
config. See `README.md` for new-machine setup instructions.

## Layout

```
.claude/                     # Claude Code config (global CLAUDE.md + memory)
.config/
├── alacritty/               # terminal config (Windows: copy to %APPDATA%)
└── nvim/                    # neovim config (shares CoC settings with vim)
.vimrc .zshrc .tmux.conf .tmux.conf.local .gitconfig .editorconfig
install.sh                   # symlinks everything into $HOME (Linux/macOS)
README.md CLAUDE.md .gitignore
```

## Conventions

- **Edit here, not in `$HOME`** — home files are symlinks to this repo. Changes
  are tracked here and versioned automatically.
- **Commit messages:** short, imperative mood. Group related changes.
- **Push after commit** so the other laptop stays in sync.
- **No hardcoded paths** like `/home/chai/...` — use `~/`, `$HOME`, or rely on PATH.
- When adding a new memory file under `.claude/memory/`, also add a one-line
  pointer in `.claude/memory/MEMORY.md` (the index file).

## Portability

Config works on Linux, macOS, and Windows (for Alacritty/terminal config):

- Paths use `~/` or `$HOME` in shell, never hardcoded home.
- Alacritty: `.config/alacritty/alacritty.toml` symlinked on Linux/macOS via
  `install.sh`. On Windows, copy to `%APPDATA%\alacritty\` manually (WSL ↔
  Windows symlinks need admin privileges).
- Claude Code memory: `~/.claude/settings.json` has
  `autoMemoryDirectory = "~/sannonthachai/dotfiles/.claude/memory"` so the path
  is stable across OSes (not derived from cwd).
- Vim: plugin list + mappings are cross-platform. `coc-settings.json` uses
  `terraform-ls` (no absolute path) — expects it on `$PATH`.

## install.sh

Idempotent — safe to re-run. Backs up existing non-symlink `$HOME` files to
`*.bak` the first time it runs. Prefixes each operation with a clear log line.

When adding a new dotfile to the repo, also add a `link` call in `install.sh`
so new machines pick it up.
