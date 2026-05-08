---
name: Custom Claude Code skills installed
description: Pointers to user-installed Claude Code skills (init-with-history, update-claude-md) and the session-load gotcha
type: reference
originSessionId: 39afa9be-66f8-452f-afa5-9a3a6f74d59d
---
User has custom Claude Code skills installed at `~/.claude/skills/` (also mirrored in the dotfiles repo at `~/sannonthachai/dotfiles/.claude/skills/`):

- **`init-with-history`** — like `/init`, but mines the current conversation for design decisions, trade-offs, and "why" rationale and folds them into a fresh `CLAUDE.md`. Use for first-time CLAUDE.md creation after a substantive session.
- **`update-claude-md`** — surgically updates an *existing* `CLAUDE.md` with new context (rotations, infra changes, gotchas, rejected alternatives) without rewriting unchanged sections. Default target is `./CLAUDE.md`; accepts a path arg.

**Gotcha — session-scoped skill loading:** Claude Code loads skills at session start. Any skill created or edited mid-session won't appear in `/skills` or as a slash command until the session is restarted. If `/update-claude-md` (or any newly-added skill) shows "Unknown skill", tell the user to restart, or follow the skill's procedure manually by reading its `SKILL.md` and executing the steps.

**How to apply:**
- After a session with non-trivial decisions, suggest `/update-claude-md` (existing project) or `/init-with-history` (no CLAUDE.md yet) — don't manually re-implement what these skills do.
- If a slash command for one of these is missing, check `~/.claude/skills/<name>/SKILL.md` exists on disk before assuming the skill isn't installed; the cause is likely the mid-session load gotcha, not a missing file.
