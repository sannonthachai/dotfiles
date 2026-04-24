---
name: Personal dotfiles repo
description: User's dotfiles repo at ~/sannonthachai/dotfiles — single source of truth for all shell/editor/terminal/claude configs
type: reference
originSessionId: 0cdae9f7-ec4d-4876-8af5-a2d84b5fdf54
---

Personal dotfiles repo: `~/sannonthachai/dotfiles/` (git repo, branch `main`,
remote `git@github.com:sannonthachai/dotfiles.git`)

All home-directory config files are **symlinks into this repo**:
- `~/.vimrc`, `~/.zshrc`, `~/.tmux.conf`, `~/.tmux.conf.local`
- `~/.gitconfig`, `~/.editorconfig`
- `~/.config/nvim/init.vim`, `~/.config/nvim/coc-settings.json`
- `~/.config/alacritty/alacritty.toml`
- `~/.claude/CLAUDE.md`
- Claude memory → `autoMemoryDirectory` setting points to `~/sannonthachai/dotfiles/.claude/memory/`

**Setup on a new machine:** `git clone` + `./install.sh` + edit `~/.claude/settings.json` for `autoMemoryDirectory`. Full steps in repo's `README.md`.

**When editing these files:** edit in the repo (or via symlink — same thing). Changes are tracked by git.

The old `~/.dotfiles/` (cloned from user's brother's repo chanasit/dotfiles) is
no longer the source of truth — Option B migration completed 2026-04-24. That
clone can be deleted when the user is confident nothing else references it.
