# Project: dotfiles

My personal dotfiles repository. Currently holds Claude Code configuration;
planned to expand into full vim/tmux/zsh/git dotfiles (see README.md).

## Layout

```
.claude/
├── CLAUDE.md        # global preferences, symlinked from ~/.claude/CLAUDE.md
└── memory/          # auto-memory (read/written by Claude Code via autoMemoryDirectory)
README.md
.gitignore
```

## Conventions

- `.claude/CLAUDE.md` — global preferences that apply across **all** projects.
  Edit this when updating how I want Claude to behave generally.
- `.claude/memory/*.md` — typed memory entries (user / feedback / project /
  reference). Managed by Claude's auto-memory system. Don't hand-edit unless
  you know what you're doing; Claude writes here during normal conversations.
- `README.md` — human-facing setup instructions for new machines.
- This file (`CLAUDE.md` at the repo root) — project-specific context for
  anyone working *in* this repo.

## Working in this repo

- Commit messages: short, imperative mood. Group related changes.
- Always push after committing so the other laptop stays in sync.
- When adding a new memory file under `.claude/memory/`, also add a one-line
  pointer in `.claude/memory/MEMORY.md` (the index file).

## Portability

Config must work on both Linux and macOS:
- No hard-coded `/home/...` or `/Users/...` paths in committed files.
- Use `~/` or `$HOME` in any paths the user runs manually.
- `autoMemoryDirectory` in `~/.claude/settings.json` points Claude Code here
  regardless of OS, avoiding the default cwd-derived memory path.

## Future (Option B)

See README.md's migration checklist. When migrating vim/tmux/zsh configs from
`~/.dotfiles/` (brother's repo) into this one, add an install script that
handles Linux/macOS differences.
