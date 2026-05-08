---
name: Check for symlinks before rm -rf inside ~/.claude
description: Before any destructive operation under ~/.claude, verify whether the path (or any ancestor) is a symlink into the dotfiles repo, otherwise the deletion silently destroys repo content
type: feedback
originSessionId: 39afa9be-66f8-452f-afa5-9a3a6f74d59d
---
Before running `rm -rf` (or any destructive operation) on a path under `~/.claude/`, always check whether the path or one of its ancestor directories is a symlink into `~/sannonthachai/dotfiles/.claude/`. If it is, the operation will modify the repo, not just `$HOME`.

Specifically: `~/.claude/agents` and `~/.claude/skills` are **whole-directory symlinks** to `~/sannonthachai/dotfiles/.claude/agents` and `.../skills` (set up via `install.sh`). So `~/.claude/skills/init-with-history` and the repo path are literally the same inode — destroying one destroys both.

**Why:** During this session (2026-05-08), I ran `rm -rf ~/.claude/skills/init-with-history ~/.claude/skills/update-claude-md` thinking I was deleting only the home copies before re-creating them as symlinks. Because `~/.claude/skills` is itself a symlink to the repo, this `rm -rf` actually deleted the contents in the repo. `init-with-history` was recoverable from `git checkout` but `update-claude-md` was untracked and had to be reconstructed from incomplete fragments — the user lost their original procedure section.

**How to apply:**
- Before any destructive op under `~/.claude/`, run `readlink ~/.claude` and `readlink ~/.claude/<subdir>` to detect symlinks.
- Treat `~/.claude/agents/`, `~/.claude/skills/`, and `~/.claude/CLAUDE.md` as repo files. Edit, don't recreate. Never `rm -rf` them.
- For other repos with `install.sh`-style symlinking, apply the same caution: when destination dirs in `$HOME` are symlinks into the repo, "cleaning up the home side" silently means cleaning up the repo side.
- When in doubt, use `stat` to compare inodes between the home path and the repo path before deleting.
- If a destructive operation IS needed on a symlinked tree, first commit the current repo state so anything accidentally lost is recoverable via `git checkout`.
