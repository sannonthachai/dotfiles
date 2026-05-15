# dotfiles

My personal dotfiles — shell, editor, terminal, Brew packages, and Claude Code config. Primary target is **macOS (Apple Silicon)**; `install.sh` also works on Linux/WSL2 as a fallback.

## What's in here

```
Brewfile                       # Homebrew formulae + casks + taps (macOS source of truth)
install.sh                     # bootstraps everything; symlinks repo files into $HOME

.claude/
├── CLAUDE.md                  # Claude Code global preferences (symlinked to ~/.claude/CLAUDE.md)
├── memory/                    # auto-memory (pointed at via autoMemoryDirectory)
├── agents/                    # custom Claude Code subagents (symlinked as a directory)
└── skills/                    # custom Claude Code skills:
    ├── init-with-history/     #   init CLAUDE.md, mining conversation history
    ├── update-claude-md/      #   surgical updates to an existing CLAUDE.md
    └── brewfile-diff/         #   diff installed brew packages vs this Brewfile

.config/
├── wezterm/wezterm.lua        # primary terminal on macOS (gruvbox dark, JetBrainsMono NF)
├── alacritty/alacritty.toml   # legacy terminal config (kept for Windows/WSL machines)
└── nvim/                      # Neovim (shares CoC config with vim)

bin/                           # personal scripts on $PATH
├── rke2-cert-check            #   report RKE2 cert expiry on a remote node
└── pm                         #   project manager helper

migrate/                       # one-shot machine-migration bundles (secrets + projects)

.vimrc .zshrc .tmux.conf .tmux.conf.local .gitconfig .editorconfig
CLAUDE.md                      # project context for working IN this repo
README.md                      # this file
```

## Setup on a new MacBook

```bash
# 1. Clone
git clone git@github.com:sannonthachai/dotfiles.git ~/sannonthachai/dotfiles
cd ~/sannonthachai/dotfiles

# 2. Run the installer
./install.sh
```

`install.sh` is idempotent and handles:

- Bootstrapping **Homebrew** (if missing) and running `brew bundle` against the `Brewfile` (CLI tools + GUI casks).
- Cloning **oh-my-zsh**, **powerlevel10k**, `zsh-autosuggestions`, `fast-syntax-highlighting`.
- Installing **vim-plug** (vim + nvim).
- Installing **Claude Code CLI** and **instant-markdown-d** via npm.
- Symlinking every config file into `$HOME` (existing non-symlink files are backed up to `*.bak` the first time).
- Linking `bin/` scripts (`rke2-cert-check`, `pm`) into `~/bin/`.

### One-time post-install steps

1. **Point Claude Code at the memory directory** — edit `~/.claude/settings.json`:

   ```json
   {
     "autoMemoryDirectory": "~/sannonthachai/dotfiles/.claude/memory"
   }
   ```

2. **Install Vim plugins:**

   ```bash
   vim +PlugInstall +qall
   ```

3. **Reload tmux** (if a session is already running):

   ```bash
   tmux source-file ~/.tmux.conf
   ```

## Setup on Linux / WSL2

`install.sh` works on Linux too — it skips the Homebrew section and falls back to per-tool `install_pkg` calls (apt-based). Run the same `./install.sh`.

## Brewfile — keeping installed packages in sync

`Brewfile` is the source of truth for what should be installed on macOS. After installing something ad-hoc with `brew install`, capture it:

```bash
# Inside a Claude Code session
/brewfile-diff
```

The skill diffs `brew leaves`, `brew list --cask`, and `brew tap` against `Brewfile` and offers to reconcile. Or do it manually:

```bash
brew leaves                            # installed top-level formulae
brew list --cask                       # installed casks
brew bundle check --file=Brewfile      # what's declared but missing
brew bundle --file=Brewfile            # install everything declared
```

## External tools the Vim config depends on

The `Brewfile` (or apt fallback in `install.sh`) installs the binaries below. CoC extension formatters (`black`, `prettier`) are pulled in lazily when their CoC extension activates.

| Tool | Purpose |
|---|---|
| `fzf`, `rg` (ripgrep) | Fuzzy finder + text search (`Ctrl-p`, `,/`) |
| `gofmt`, `goimports` | Go formatters |
| `shfmt` | Shell script formatter |
| `terraform-ls` | Terraform LSP (via CoC; install manually if not present) |
| `black`, `prettier` | Python / JS-YAML-MD formatters (managed by CoC extensions) |

## Making changes

Edit files **in this repo** — `$HOME` files are symlinks back here. Then:

```bash
git add -A && git commit -m "your message" && git push
```

## Updating another machine

```bash
cd ~/sannonthachai/dotfiles
git pull
```

Changes take effect immediately via symlinks. For Vim plugin additions, also run `:PlugInstall`. For new Brewfile entries, run `brew bundle --file=Brewfile`.
