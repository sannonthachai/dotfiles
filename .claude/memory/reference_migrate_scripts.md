---
name: Machine-migration scripts in dotfiles
description: Pointer to migrate/{bundle,restore,projects-audit,projects-bundle,projects-restore}.sh in the personal dotfiles repo for moving secrets and projects between machines (e.g. WSL → macOS)
type: reference
originSessionId: 39afa9be-66f8-452f-afa5-9a3a6f74d59d
---

The personal dotfiles repo has a `migrate/` directory with two independent flows for moving to a new machine (e.g. WSL → macOS). Both produce passphrase-encrypted tarballs that the user transfers manually (USB / Syncthing / scp).

## Secrets flow (small bundle, credentials only)

- `migrate/bundle.sh` — SOURCE: packs SSH keys, kubeconfigs, docker/argocd/terraform creds, and (opt-in) GPG keys + git-credentials + Huawei Cloud config into `~/migration-bundle.tar.gz.gpg`.
- `migrate/restore.sh` — DESTINATION: decrypts (default `~/migration-bundle.tar.gz.gpg`), restores into `$HOME` with overwrite prompts, fixes `~/.ssh` perms (700/600/644), imports GPG keys, prints macOS-specific follow-ups (osxkeychain, Homebrew install list).

## Projects flow (~/workspaces/ + ~/sannonthachai/)

- `migrate/projects-audit.sh` — SOURCE: recursively walks the two scan roots, descending through grouping dirs (e.g. `workspaces/{ea,jvfs,tsb,wallet,ops}`) to find nested repos at any depth. Prunes build-artifact subtrees (node_modules, .terraform, vendor, target, dist, build, __pycache__, .venv, .gradle, .cache, etc.). Outputs three TSVs at `~/.migration-audit/`:
  - `clean-repos.tsv` — repos with no uncommitted changes; will be re-cloned on destination
  - `dirty-repos.tsv` — repos with `wt`/`stash`/`unpushed`/`noupstrm`/`noremote`/`detached` flags; bundled as diff + untracked + stash patches (or full tree if `noremote`)
  - `non-git.tsv` — non-git directories (tarred whole, with build excludes) and loose files
- `migrate/projects-bundle.sh` — SOURCE: reads the TSVs, packs into `~/projects-bundle.tar.gz.gpg`. The user is expected to edit non-git.tsv first to drop oversized dirs they don't want to carry.
- `migrate/projects-restore.sh` — DESTINATION: re-clones every clean repo at its mirrored path under `$HOME`, then re-applies bundled diffs/untracked/stashes for dirty repos. Failures saved as `.migration-failed-*.patch` in the repo for manual conflict resolution. Log at `~/projects-restore.log`.
- `migrate/README.md` — full workflow + caveats (e.g. dotfiles repo itself is in the audit and re-clones cleanly; do secrets → dotfiles install.sh → projects in that order on destination).

**Decisions baked into the projects flow** (so they survive the conversation):

- Mirror exact paths (`~/workspaces/...`, `~/sannonthachai/...`) on the destination, **not** macOS-conventional `~/Projects/`. Reason: avoids breaking hard-coded paths in user's scripts and notes.
- Dirty repos: bundle diff + untracked + stash, **not** full tree. Reason: 100s of MB → low single-digit MB per dirty repo. Trade-off: requires destination to clone latest from remote, so user should push WIP work before migrating when possible.

## Cross-cutting notes

- The bundles are NOT auto-transferred — user moves the `.gpg` files manually before running `*-restore.sh`.
- Pair with `install.sh` (handles checked-in configs); `migrate/` handles what can't be in git.
- Both restore scripts remind the user to shred the bundle (`shred -u` on Linux, `rm -P` on macOS) after verification.

**How to apply:**
- When the user asks about migrating machines / switching to macOS / "what do I need to transfer", point them at the appropriate `migrate/*` script — don't re-derive inventories from scratch.
- For "what's covered": read the script's helper calls and the README — they are the source of truth and may evolve.
- Order on destination: secrets-restore → dotfiles `install.sh` → projects-restore.
- The user is expected to edit `~/.migration-audit/non-git.tsv` to drop large non-essential dirs (logs caches, full GitLab clones, etc.) before running `projects-bundle.sh`.
