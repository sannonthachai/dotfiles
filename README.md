# dotfiles

My personal dotfiles repository.

## Current scope

Claude Code config:

- `.claude/CLAUDE.md` — global preferences (response style, stack, Vim/tmux setup)
- `.claude/projects/-home-chai/memory/` — auto-memory entries

These are symlinked from `~/.claude/` so Claude Code reads them from this repo.

## Setup on a new machine

```bash
git clone <this-repo> ~/sannonthachai/dotfiles
ln -s ~/sannonthachai/dotfiles/.claude/CLAUDE.md ~/.claude/CLAUDE.md
mkdir -p ~/.claude/projects/-home-chai
ln -s ~/sannonthachai/dotfiles/.claude/projects/-home-chai/memory ~/.claude/projects/-home-chai/memory
```

## Planned (future): full dotfiles migration

Currently `~/.dotfiles/` is cloned from my brother's repo (`chanasit/dotfiles`)
and handles vim, tmux, zsh, git config, etc. Plan is to migrate those into this
repo so everything is owned by me:

- [ ] `.vimrc` + `.vim/` → move from `~/.dotfiles/.vimrc`
- [ ] `.tmux.conf` + `.tmux.conf.local` → move from `~/.dotfiles/`
- [ ] `.zshrc` → move from `~/.dotfiles/.zshrc`
- [ ] `.gitconfig` → move from `~/.dotfiles/.gitconfig`
- [ ] `.config/nvim/` → move from `~/.dotfiles/.config/nvim/`
- [ ] Install/symlink script (Makefile or `install.sh`)
- [ ] Stop using `~/.dotfiles/` entirely
