---
name: brewfile-diff
description: Compare what's installed via Homebrew on this Mac against the Brewfile in the user's dotfiles repo. Reports formulae/casks/taps in one place but not the other and offers to reconcile (add to Brewfile, install missing, or ignore). Use when the user asks to "compare brew install with dotfiles", "check Brewfile drift", "sync Brewfile", or similar.
---

# brewfile-diff

Detect drift between what Homebrew has actually installed on the current macOS machine and what the user's dotfiles `Brewfile` declares as the source of truth. Then help the user reconcile the difference.

## When to use

- User asks: "compare brew install with my dotfiles", "what's missing from the Brewfile", "is my Brewfile up to date", "sync Brewfile".
- After a session that installed a new tool via `brew install` and the user wants to remember to capture it.
- Before reimaging / migrating to a new Mac — make sure Brewfile is complete.

Do NOT use:
- On Linux/WSL — Brewfile is macOS-only here.
- For installing new tools the user hasn't decided on yet — this skill is for reconciliation, not discovery.

## Gotcha: skill registration is session-scoped

Claude Code loads skills at session start. If this skill is created or edited mid-session, `/brewfile-diff` will fail with "Unknown skill" until a fresh session. The procedure below can still be followed manually in the current session — just read this file and execute the steps.

## Prerequisites

- macOS with Homebrew on `$PATH` (`/opt/homebrew/bin/brew` on Apple Silicon, `/usr/local/bin/brew` on Intel).
- Brewfile at `~/sannonthachai/dotfiles/Brewfile` (default). The user may pass a different path as the skill argument.

## Procedure

### 1. Locate the Brewfile

- Default: `~/sannonthachai/dotfiles/Brewfile`.
- If the user passes an argument, treat it as the path (e.g. `/brewfile-diff path/to/Brewfile`).
- If the file doesn't exist, stop and tell the user — offer to generate one with `brew bundle dump --file=...` if they'd like.

### 2. Collect the four lists

Run via Bash (in parallel where possible) and capture stdout:

```sh
# Installed (truth from the system)
brew leaves | sort                  # top-level formulae only — skips deps
brew list --cask 2>/dev/null | sort
brew tap | sort

# Declared (truth from dotfiles)
grep -E '^brew "'  Brewfile | sed 's/^brew "\([^"]*\)".*/\1/' | sort
grep -E '^cask "'  Brewfile | sed 's/^cask "\([^"]*\)".*/\1/' | sort
grep -E '^tap "'   Brewfile | sed 's/^tap "\([^"]*\)".*/\1/' | sort
```

Notes:
- Use `brew leaves`, NOT `brew list`, so transitive dependencies don't pollute the diff.
- Strip Brewfile entries down to just the package name — drop options like `link: false`, version pins, comments.
- Some tapped formulae are written as `tap/pkg` (e.g., `hudochenkov/sshpass/sshpass`). `brew leaves` reports them in that exact form, so direct comparison works without normalization.

### 3. Compute four diffs

For each of {formulae, casks, taps}, compute:

- **A → installed but NOT in Brewfile** (candidate to *add* — user installed something ad-hoc)
- **B → in Brewfile but NOT installed** (candidate to *install* on this machine, or *remove* from Brewfile if obsolete)

Use `comm -23` and `comm -13` against the sorted lists. Suppress empty sections in the report — show only categories that have differences.

### 4. Report findings

Present a compact table per category. Example:

```
=== FORMULAE: installed but not in Brewfile ===
- telnet
- hudochenkov/sshpass/sshpass

=== CASKS: in Brewfile but not installed ===
- openvpn-connect
```

If everything matches, say so explicitly ("Brewfile is in sync — no drift detected") and stop.

### 5. Triage with the user

For each entry, ask the user what to do. Common choices:

| Diff direction | Options to offer |
|---|---|
| Installed but missing from Brewfile | (a) add to Brewfile, (b) uninstall locally, (c) ignore |
| In Brewfile but not installed | (a) install now (`brew install` / `brew install --cask`), (b) remove from Brewfile, (c) ignore |

Batch related decisions ("all of these to add?") to reduce back-and-forth, but call out anything sensitive (corporate-licensed apps, GUI casks the user might not want to auto-install).

### 6. Apply the changes

For Brewfile edits:
- Use the `Edit` tool. Group new entries near related ones (CLI vs DevOps vs casks vs taps).
- Preserve the comment style of existing entries (one-line `# comment` after the package).
- If a new entry is from a tap, ALSO add the `tap "..."` line at the top section.

For installs:
- Run `brew install <pkg>` / `brew install --cask <pkg>` directly.
- If from a tap not yet present, `brew tap <tap>` first.

For removals: don't run `brew uninstall` without explicit per-package confirmation — uninstalling can affect dependent tools.

### 7. Verify and offer to commit

After edits, run `brew bundle check --file=<path>` to validate parseability. Then:
- Show the user the final `git diff Brewfile`.
- Suggest a commit message like: "Brewfile: add <pkg> (sync with installed packages)".
- Offer to commit + push (per the user's preference for keeping dotfiles in sync across machines).

## Output style

- Short. Tables for the diff, prose only when explaining a decision.
- Group changes when reporting: "Adding 3 formulae and 1 tap" beats four separate lines.
- When a tap-scoped formula like `hudochenkov/sshpass/sshpass` is involved, surface that fact — taps are easy to forget.
- Don't suggest installing GUI casks just because they're missing — ask first (the user may not want them on a particular machine).
