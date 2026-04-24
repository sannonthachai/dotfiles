# dotfiles

My personal dotfiles repository.

## What's in here

Claude Code configuration — global preferences and auto-memory so a fresh
install of Claude Code on any machine picks up my setup.

```
.claude/
├── CLAUDE.md              # global preferences (response style, stack, workflows)
└── memory/                # auto-memory entries (user profile, feedback, references)
.config/
└── alacritty/
    └── alacritty.toml     # Alacritty terminal config (gruvbox light, WSL shell)
```

### Alacritty config — platform paths

| OS | Location |
|---|---|
| Linux | `~/.config/alacritty/alacritty.toml` |
| macOS | `~/.config/alacritty/alacritty.toml` |
| Windows | `%APPDATA%\alacritty\alacritty.toml` |

On Linux/macOS, symlink: `ln -s ~/sannonthachai/dotfiles/.config/alacritty ~/.config/alacritty`

On Windows, copy the file to `%APPDATA%\alacritty\` (symlinks across WSL ↔ Windows need admin).

## Setup on a new laptop (Linux or macOS)

### 1. Install Claude Code

https://docs.claude.com/en/docs/claude-code/quickstart

Run `claude` once so `~/.claude/` is created.

### 2. Clone this repo

```bash
git clone git@github.com:sannonthachai/dotfiles.git ~/sannonthachai/dotfiles
```

### 3. Link CLAUDE.md

```bash
mkdir -p ~/.claude
ln -s ~/sannonthachai/dotfiles/.claude/CLAUDE.md ~/.claude/CLAUDE.md
```

### 4. Point Claude at the memory directory

Edit `~/.claude/settings.json` and add `autoMemoryDirectory`:

```json
{
  "effortLevel": "medium",
  "autoMemoryDirectory": "~/sannonthachai/dotfiles/.claude/memory"
}
```

This avoids a symlink and keeps the path portable across Linux (`/home/...`)
and macOS (`/Users/...`) — the default memory path is derived from the home
directory, but this override bypasses that.

### 5. Verify

Open Claude Code and run any prompt. Ask "what do you know about me?" — it
should recall my profile, preferences, and setup notes from this repo.

## Making changes

- Edit files directly in this repo, or edit via the symlink at
  `~/.claude/CLAUDE.md`. Both point at the same file.
- Memory files are written directly into `.claude/memory/` by Claude Code, so
  new memories show up as git changes here.
- Commit and push when you want to sync to other machines:

  ```bash
  cd ~/sannonthachai/dotfiles
  git add -A && git commit -m "update memory" && git push
  ```

## Planned (future): full dotfiles migration — "Option B"

Currently `~/.dotfiles/` is cloned from my brother's repo (`chanasit/dotfiles`)
and handles vim, tmux, zsh, git config, etc. Plan is to migrate those into this
repo so everything is owned by me:

- [ ] `.vimrc` + `.vim/` → move from `~/.dotfiles/.vimrc`
- [ ] `.tmux.conf` + `.tmux.conf.local` → move from `~/.dotfiles/`
- [ ] `.zshrc` → move from `~/.dotfiles/.zshrc`
- [ ] `.gitconfig` → move from `~/.dotfiles/.gitconfig`
- [ ] `.config/nvim/` → move from `~/.dotfiles/.config/nvim/`
- [ ] Install/symlink script (Makefile or `install.sh`) with Linux + macOS support
- [ ] Stop using `~/.dotfiles/` entirely

### Cross-platform considerations for Option B

- Package manager: `apt` on Linux vs `brew` on macOS — detect with `uname -s`
- Home path: `/home/<user>` vs `/Users/<user>` — avoid hard-coded absolute paths
- URL opener: `xdg-open` (Linux) vs `open` (macOS)
- Terraform-ls etc. — install via script rather than pinning a path in `coc-settings.json`
