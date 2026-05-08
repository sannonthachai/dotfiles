---
name: Machine-migration scripts in dotfiles
description: Pointer to migrate/bundle.sh and migrate/restore.sh in the personal dotfiles repo for moving secrets/credentials between machines (e.g. WSL → macOS)
type: reference
originSessionId: 39afa9be-66f8-452f-afa5-9a3a6f74d59d
---
The personal dotfiles repo contains a `migrate/` directory with paired scripts for transferring credentials that can't live in git, when the user moves to a new machine (e.g. WSL → macOS).

- `migrate/bundle.sh` — runs on the SOURCE machine. Packs SSH keys, kubeconfigs, docker/argocd/terraform creds, and (opt-in) GPG keys + git-credentials + Huawei Cloud config into a single passphrase-encrypted tarball at `~/migration-bundle.tar.gz.gpg`.
- `migrate/restore.sh` — runs on the DESTINATION machine. Decrypts a local bundle file (default `~/migration-bundle.tar.gz.gpg`, or pass a path), restores into `$HOME` with overwrite prompts, fixes `~/.ssh` perms (700 dir, 600 keys, 644 .pub), imports GPG keys, and prints macOS-specific follow-ups (osxkeychain, Homebrew install list).
- `migrate/README.md` — full workflow docs and the in/out manifest.

The bundle is **not** auto-transferred — user must move the `.gpg` file via USB / Syncthing / scp / iCloud manually before running `restore.sh`. Pair with `install.sh` (which handles checked-in configs); `migrate/` handles the secrets that can't be in git.

**How to apply:**
- When the user asks about migrating machines, switching to macOS, or "what do I need to transfer", point them at `./migrate/bundle.sh` on the source and `./migrate/restore.sh` on the destination — don't re-derive the inventory from scratch.
- If they ask what's covered: the script's `include` calls and the README are the source of truth (read those, don't recall from memory). The scripts may evolve.
- Reminder to user after restore: shred the bundle on both machines (`shred -u` on Linux, `rm -P` on macOS) — `restore.sh` already prints this hint.
