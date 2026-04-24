---
name: Dotfiles migration plan (Option B)
description: Future plan to migrate vim/tmux/zsh/git configs from brother's ~/.dotfiles into user's own ~/sannonthachai/dotfiles repo
type: project
originSessionId: 0cdae9f7-ec4d-4876-8af5-a2d84b5fdf54
---
Future plan: migrate the rest of the user's config from `~/.dotfiles/` (cloned from brother's `chanasit/dotfiles`) into the user's own repo at `~/sannonthachai/dotfiles/`.

Items to migrate (checklist also in the repo's README.md):
- `.vimrc` + `.vim/`
- `.tmux.conf` + `.tmux.conf.local`
- `.zshrc`
- `.gitconfig`
- `.config/nvim/`
- Install/symlink script (Makefile or `install.sh`)

**Why:** User wants full ownership of their dotfiles instead of relying on brother's repo. Agreed to do it in stages — Claude config first (Option A, done 2026-04-24), full migration later.

**How to apply:** When the user says they're ready for "Option B" or "migrate dotfiles", help them move files, update symlinks to point at the new repo, and update/retire the old `~/.dotfiles/` clone. Don't push to the user's brother's repo by accident.
