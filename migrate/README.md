# Migration scripts

Move credentials, config, and project work to a new machine.

Two independent flows live here:

- **Secrets** (`bundle.sh` + `restore.sh`) — SSH keys, kubeconfigs,
  Docker/ArgoCD/Terraform creds, optional GPG keys, optional Huawei Cloud
  config. Tiny bundle, encrypted with a passphrase.
- **Projects** (`projects-audit.sh` + `projects-bundle.sh` +
  `projects-restore.sh`) — everything under `~/workspaces/` and
  `~/sannonthachai/`. Clean repos are re-cloned on the new machine; only
  uncommitted changes (diffs, untracked files, stashes) and non-git
  directories travel in the bundle.

Run secrets first (so `~/.ssh` is in place), then projects (which clones
over SSH).

## Workflow

### On the source machine

```bash
./migrate/bundle.sh
```

Produces `~/migration-bundle.tar.gz.gpg` (symmetric, passphrase-protected).
Prompts before including sensitive opt-ins (`~/.git-credentials`, `~/.hcloud/`,
GPG keys).

### Transfer

Move the bundle over a secure channel — USB stick, Syncthing, encrypted
iCloud Drive, anything that isn't an unencrypted email/Slack message.

### On the destination machine

```bash
./migrate/restore.sh                                  # default location
./migrate/restore.sh /path/to/migration-bundle.tar.gz.gpg
```

Decrypts (asks for the passphrase), extracts into `$HOME` with prompts
before overwriting anything that already exists, and fixes `~/.ssh`
permissions automatically.

## What's in / what's out

Inside the bundle (when present):

- `~/.ssh/` (keys + config; `known_hosts` skipped — it regenerates)
- `~/.kube/config`, `~/.kube/test`
- `~/.docker/config.json`
- `~/.config/argocd/config`
- `~/.terraform.d/credentials.tfrc.json`
- `~/.git-credentials` (opt-in)
- `~/.hcloud/` (opt-in — prefer rotating AK/SK on the new machine)
- GPG secret keys + ownertrust (opt-in, exported via `gpg --export-secret-keys`)

NOT in the bundle (regenerate on the destination):

- `~/.kube/cache`, `~/.kube/http-cache`, `~/.docker/buildx`, `~/.docker/.token_seed*`
- `~/.terraform.d/checkpoint_*`, `~/.ansible/{cp,tmp}`
- gpg sockets (`S.gpg-agent*`)
- gcloud — re-run `gcloud auth login` on the destination
- Anything under `~/.cache/`, `~/.local/share/`

## After a successful restore

The bundle is plaintext credentials inside one passphrase. Shred it on
both machines once you've confirmed the new machine works:

```bash
# Linux
shred -u ~/migration-bundle.tar.gz.gpg

# macOS
rm -P ~/migration-bundle.tar.gz.gpg
```

## macOS-specific tips (printed by `restore.sh` automatically)

- Switch git credential helper to Keychain:
  `git config --global credential.helper osxkeychain` then re-auth via
  `git push`, then `rm ~/.git-credentials`.
- Tools not in the dotfiles repo:
  `brew install git zsh tmux vim neovim fzf ripgrep gnupg gh go node python kubectl helm terraform ansible argocd k9s`
  `brew install --cask docker wezterm alacritty`

---

# Projects flow

Move everything under `~/workspaces/` and `~/sannonthachai/` to a new
machine without copying gigabytes of `node_modules/`, `vendor/`,
`.terraform/`, etc.

## Workflow

### On the source machine

```bash
./migrate/projects-audit.sh
# → ~/.migration-audit/{clean-repos,dirty-repos,non-git}.tsv

# review and (optionally) edit the TSVs to skip large dirs you don't want
# to carry, then:

./migrate/projects-bundle.sh
# → ~/projects-bundle.tar.gz.gpg
```

`projects-audit.sh` classifies every immediate child of the scan roots:

- **clean-repos.tsv** — repos with no uncommitted changes, no stash, no
  unpushed commits, and a configured remote. These will be re-cloned on
  the Mac.
- **dirty-repos.tsv** — repos with any of: working-tree changes (`wt`),
  stash entries (`stash`), unpushed commits (`unpushed`), no upstream
  (`noupstrm`), no remote (`noremote`), or detached HEAD (`detached`).
  The bundle carries diffs/untracked/stashes (or the whole tree for
  `noremote` repos).
- **non-git.tsv** — directories that aren't git repos (tarred whole,
  excluding build artifacts) and loose files at the scan-root level.

### Transfer

Same as secrets — USB / Syncthing / scp.

### On the destination machine (after `restore.sh` for secrets)

```bash
./migrate/projects-restore.sh
```

Recreates the `~/workspaces/` and `~/sannonthachai/` layout exactly as on
the source:

1. Clones every clean repo to its mirrored path.
2. Clones each dirty repo, then re-applies its diff, untracked files,
   and stashes (each as a stash entry, not popped).
3. Extracts non-git tarballs and loose files in place.

Failures are logged to `~/projects-restore.log`. If a diff or stash
doesn't apply cleanly, it's preserved in the repo as
`.migration-failed-*.patch` for manual conflict resolution.

## What's NOT in the projects bundle

Excluded from non-git tarballs and from any "full repo" snapshots
(`noremote` case):

```
node_modules/  .next/  dist/  build/  target/  vendor/
.terraform/  .terragrunt-cache/  __pycache__/  .venv/  venv/
.gradle/  .cache/  coverage/  tmp/  *.log
```

Inside dirty repos, untracked files are filtered through `.gitignore`
(via `git ls-files --others --exclude-standard`), so ignored junk doesn't
travel either.

## Caveats

- **`~/sannonthachai/dotfiles` itself is in the audit.** That's fine — it
  re-clones on the Mac like any other repo. The dotfiles symlinks under
  `~/.claude/` only resolve once the repo is cloned and `install.sh` has
  run, so do the secrets flow → dotfiles clone+install.sh → projects
  flow in that order.
- **No-remote repos are bundled in full** (sans build artifacts). If
  you have a lot of these, the bundle gets big — push them somewhere
  before audit if size matters.
- **Diffs that include binary files** are bundled with `--binary`, but
  `git apply --3way` may still need conflict resolution if the
  destination repo has moved on remotely between snapshots. In practice
  you'll re-clone latest, so prefer pushing your work before migration
  whenever possible.
