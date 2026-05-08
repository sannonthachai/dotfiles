---
name: init-with-history
description: Like /init, but also mines the current conversation for design decisions, trade-offs, and "why" rationale that aren't visible in the code, and folds them into CLAUDE.md. Use when initializing CLAUDE.md after a session that involved non-trivial design choices the user wants preserved.
---

# init-with-history

Generate a `CLAUDE.md` that documents the project the same way `/init` does — **plus** a "Design Decisions" section pulled from the current conversation. The goal is to capture the *why* (trade-offs, rejected alternatives, version choices, workarounds) that would otherwise be lost once the chat ends.

## When to use

- Right after a session where you made non-obvious choices the user will want future Claude sessions to know.
- When initializing a fresh project that was just set up interactively.
- NOT for routine init on an existing well-documented repo — use plain `/init` for that.

## Procedure

### 1. Standard init analysis

Do everything the `/init` skill normally does:

- Survey top-level files and directories (`ls`, `Read` key files like `package.json`, `docker-compose.yml`, `requirements.txt`, `pyproject.toml`, `Makefile`, etc.).
- Identify language/stack, build/test commands, entrypoints, and conventions.
- Note any existing `README.md`, `CONTRIBUTING.md`, or comment headers that already explain things — don't duplicate, reference.

### 2. Mine the conversation for decisions

Re-read the current conversation from the start. Extract anything that fits these categories — **only if it isn't already obvious from the code**:

| Category | Examples |
|---|---|
| **Version / tooling choices** | "We picked pg17 because the dump's archive format 1.16 needed pg_dump 17+." |
| **Rejected alternatives** | "Considered amending the binary dump file to rename `easy_*`; rejected because pg_dump custom format is length-prefixed." |
| **Workarounds for external constraints** | "Schema must be created before data restore because the dump is data-only." |
| **Naming / renaming history** | "`easy_*` → `msteams_*` because the project is a Microsoft Teams chatbot." |
| **Known limitations / staleness risks** | "`app/db/` is a copy from another repo — re-sync if the source models change." |
| **Intentional omissions** | "`apscheduler_jobs` data is not restored because the app uses `replace_existing=True`." |
| **Operational gotchas** | "Port 5432 will conflict if host already runs Postgres." |
| **Secret / sensitive notes** | "`env.txt` contains live API keys — must be gitignored before push." |

Skip:
- Conversational filler ("let me check…", "done").
- Routine successful steps already documented by the script/comments.
- Anything a reader can derive from `git log` or by reading the file once.

### 3. Write CLAUDE.md

Structure:

```markdown
# <Project name>

<One-paragraph purpose — what this project IS and what it produces>

## Layout

<Directory tree with one-line annotations per file/dir>

## Common Commands

<Setup, run, test, teardown — the commands a new contributor needs>

## Design Decisions

<Bulleted list from step 2. Each bullet: the decision in one line, then a
short *why*. If a decision is load-bearing for the workflow, mark it with
⚠️ so future Claude doesn't accidentally undo it.>

## Known Limitations

<Staleness risks, conflicts, manual sync requirements>

## References

<Links to related repos, dashboards, dumps, external systems mentioned in the chat>
```

### 4. Confirm before writing

Show the user a draft of the **Design Decisions** section before writing the file. Conversation-mined content is the part most likely to be wrong or include things the user doesn't want recorded — get explicit approval. The other sections are derived from code and can be written without confirmation.

If `CLAUDE.md` already exists, ask whether to overwrite, append a "Design Decisions" section to the existing one, or write to a separate file.

## Output style

- Keep it tight. CLAUDE.md is loaded into every future conversation's context — every line costs tokens.
- Prefer specific facts over prose ("pg17, not pg16: dump archive format 1.16" beats "We had to upgrade Postgres because of compatibility issues").
- Link to files with paths: `app/db/init_db.py`, `setup.sh:42`.
- No emojis except the ⚠️ marker for load-bearing decisions.
