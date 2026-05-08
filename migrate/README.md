# Migration scripts

Bundle and restore credentials/config that the dotfiles repo can't carry
(SSH keys, kubeconfig, GPG keys, etc.) when moving between machines.

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
