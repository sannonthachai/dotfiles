# dotfiles

My personal dotfiles — shell, editor, terminal, and Claude Code config.

## What's in here

```
.claude/
├── CLAUDE.md                          # Claude Code global preferences (symlinked to ~/.claude/CLAUDE.md)
└── memory/                            # Claude Code auto-memory (pointed at via autoMemoryDirectory)

.config/
├── alacritty/alacritty.toml           # Alacritty terminal (gruvbox dark, JetBrainsMono NF)
└── nvim/                              # Neovim (shares CoC config with vim)
    ├── init.vim
    └── coc-settings.json

.vimrc                                 # Vim config (plugins, keybindings, theme)
.zshrc                                 # zsh config (oh-my-zsh, powerlevel10k)
.tmux.conf                             # tmux (oh-my-tmux base)
.tmux.conf.local                       # tmux user overrides
.gitconfig                             # git settings
.editorconfig                          # editor-agnostic indent/EOL rules
install.sh                             # symlink everything into $HOME
CLAUDE.md                              # project-level context for working IN this repo
README.md                              # this file
```

## Setup on a new laptop (Linux or macOS)

### 1. Install prerequisites

Make sure these are installed first:

- git, zsh, tmux, vim or neovim
- [oh-my-zsh](https://ohmyz.sh/) and [powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [vim-plug](https://github.com/junegunn/vim-plug) (for Vim plugins)
- [fzf](https://github.com/junegunn/fzf) and [ripgrep](https://github.com/BurntSushi/ripgrep)
- Language tools you want: go, node/npm, python, terraform, etc.

### 2. Clone and run the installer

```bash
git clone git@github.com:sannonthachai/dotfiles.git ~/sannonthachai/dotfiles
cd ~/sannonthachai/dotfiles
./install.sh
```

Existing non-symlink files in `$HOME` are backed up to `*.bak` before being replaced with symlinks.

### 3. Point Claude Code at the memory directory

Edit `~/.claude/settings.json`:

```json
{
  "effortLevel": "medium",
  "autoMemoryDirectory": "~/sannonthachai/dotfiles/.claude/memory"
}
```

### 4. Install Vim plugins

```bash
vim +PlugInstall +qall
```

### 5. Reload tmux

```bash
tmux source-file ~/.tmux.conf
```

## Setup on Windows (for the Alacritty config)

Alacritty on Windows reads `%APPDATA%\alacritty\alacritty.toml`. The installer doesn't
handle Windows, so copy it manually:

```powershell
Copy-Item "\\wsl.localhost\Ubuntu\home\chai\sannonthachai\dotfiles\.config\alacritty\alacritty.toml" `
          "$env:APPDATA\alacritty\alacritty.toml"
```

## External tools my Vim config depends on

Install these and make sure they're on `$PATH`:

| Tool | Purpose |
|---|---|
| `fzf` | Fuzzy finder (`Ctrl-p`, `,b`, `,/`) |
| `rg` (ripgrep) | Text search backend for `,/` |
| `black` | Python formatter |
| `prettier` | JS/TS/YAML/MD/HTML/JSON formatter |
| `terraform-ls` | Terraform LSP (via CoC) |
| `gofmt`, `goimports` | Go formatters |
| `shfmt` | Shell script formatter |

## Making changes

- Edit files directly in this repo, or through symlinks (`~/.vimrc`, `~/.zshrc`, etc.)
- Commit and push when ready:

  ```bash
  cd ~/sannonthachai/dotfiles
  git add -A && git commit -m "your message" && git push
  ```

## Updating from remote

On another machine already set up:

```bash
cd ~/sannonthachai/dotfiles
git pull
```

Changes take effect immediately via symlinks. For Vim plugin additions, also run
`:PlugInstall` inside Vim.
