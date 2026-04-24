---
name: Personal dotfiles repo
description: User's own dotfiles repo at ~/sannonthachai/dotfiles — currently holds Claude Code config; brother's repo at ~/.dotfiles still handles vim/tmux/zsh
type: reference
originSessionId: 0cdae9f7-ec4d-4876-8af5-a2d84b5fdf54
---
Personal dotfiles repo: `~/sannonthachai/dotfiles/` (git repo, branch `main`)

Currently contains:
- `.claude/CLAUDE.md` — symlinked to `~/.claude/CLAUDE.md`
- `.claude/projects/-home-chai/memory/` — symlinked to `~/.claude/projects/-home-chai/memory/`

**Also present:** `~/.dotfiles/` (cloned from `chanasit/dotfiles`, user's brother's repo). Still the source of truth for `.vimrc`, `.tmux.conf`, `.zshrc`, `.gitconfig`, `.config/nvim/`. When editing those files, edit at `~/.dotfiles/...` paths, not in the personal repo — they haven't been migrated yet.

No GitHub remote yet — user will push to their own GitHub account when ready.
