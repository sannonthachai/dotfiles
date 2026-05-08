---
name: update-claude-md
description: Update an existing CLAUDE.md by mining the current conversation for new design decisions, gotchas, limitations, and "why" rationale that aren't already captured. Use after a session that produced non-trivial changes the user wants future Claude sessions to know. Unlike init-with-history, this preserves the existing file structure and only adds/edits relevant sections.
---

# update-claude-md

Surgically update an existing project `CLAUDE.md` with new context from the current conversation. Goal: capture the *why* behind decisions made this session (deployments, workarounds, rotations, version bumps, rejected alternatives) without rewriting unchanged sections or duplicating content.

## When to use

- After a session that introduced new operational steps, environment requirements, or design trade-offs.
- After credential rotations, infrastructure changes, or one-off fixes that future sessions need to know.
- NOT for fresh init (use `/init` or `/init-with-history`).
- NOT for routine code edits already explained by the diff/commit message.

## Gotcha: skill registration is session-scoped

Claude Code loads skills at session start. If this skill (or any skill) is
created or edited mid-session, `/update-claude-md` will fail with
"Unknown skill" until the user starts a new Claude Code session. The skill's
*instructions* can still be followed manually in the current session — just
read this file and execute the procedure — but the slash-command shortcut
won't be available.

If invoked and missing in the current session, tell the user: "This skill
was added mid-session and needs a Claude Code restart to register. I can
follow the procedure manually now, or you can restart and re-invoke."

## Procedure

### 1. Locate and read the target file

- Default target: `./CLAUDE.md` in the current working directory.
- If the user passes an argument, treat it as the path (e.g. `/update-claude-md path/to/CLAUDE.md`).
- If no `CLAUDE.md` exists at the target path, stop and suggest `/init` or `/init-with-history` instead — this skill is for updates only.
- Read the file fully so you understand its existing structure, headings, and what's already documented. The update must preserve the existing layout.

### 2. Mine the conversation for new context

Re-read the current conversation from the start. Extract anything that fits these categories — **only if it isn't already in CLAUDE.md AND isn't obvious from the code**:

| Category | Examples |
|---|---|
| **New design decisions / trade-offs** | "Switched from polling to webhooks because the polling cron caused rate-limit hits." |
| **Credential / config rotations** | "Rotated the GitLab PAT for argocd-image-updater on 2026-05-08; secret name `argocd/git-creds`." |
| **Infrastructure changes** | "Moved Postgres from container to managed RDS; connection string now in `DB_URL` env var." |
| **One-off fixes / workarounds** | "Pin `node_modules/foo` to 1.2.3; 1.2.4 broke SSR — see issue #234." |
| **Newly discovered gotchas** | "ArgoCD ApplicationSet won't pick up new clusters until the controller is restarted." |
| **Rejected alternatives** | "Considered Helm chart for service X; rejected because we need per-tenant overrides ArgoCD's Kustomize handles better." |
| **Operational notes** | "Health check at `/livez` not `/healthz` — k8s probes must use the new path." |

Skip:
- Conversational filler.
- Anything already documented in the existing CLAUDE.md (don't duplicate).
- Information derivable from `git log`, `git blame`, or by reading the code.
- Ephemeral debugging steps that don't generalize.

### 3. Decide where each item goes

For each item from step 2, choose one:

- **Append to an existing section** if the section's topic matches (e.g., a new credential note → existing "## Secrets" section).
- **Edit an existing line** if the new info corrects or supersedes something already there (mark superseded info — don't silently drop it if it's load-bearing).
- **Add a new section** only if the topic genuinely doesn't fit anywhere existing. Prefer appending.

Never reformat unchanged sections — minimize the diff.

### 4. Confirm before writing

Show the user a draft of the proposed changes as a diff or before/after snippets. Conversation-mined content is the part most likely to be wrong, stale, or include things the user doesn't want recorded — get explicit approval before editing the file.

If multiple items are independent, group related ones and confirm them together; ask separately about anything sensitive (credentials, internal URLs, customer names).

### 5. Write the update

Use the Edit tool to apply targeted edits to the existing CLAUDE.md. Do not rewrite the whole file. After writing:

- Show the user the final diff.
- Suggest a commit message focused on what was added (e.g., "Document GitLab PAT rotation for image-updater").

## Output style

- Match the existing CLAUDE.md's tone, heading depth, and bullet style.
- Prefer specific facts over prose ("Rotate `argocd/git-creds` PAT every 90 days; scope `write_repository`" beats "Remember to rotate the token periodically").
- Link to files with paths: `argocd/applications/sit-iden.yaml:12`.
- Mark load-bearing operational notes with ⚠️ so future Claude doesn't undo them.
- Keep it tight — CLAUDE.md loads into every future conversation, every line costs tokens.
