#!/usr/bin/env bash
# restore.sh — decrypt and restore a migration bundle on the DESTINATION machine.
# Pair with bundle.sh on the source.
#
# Usage:
#   ./restore.sh [path/to/migration-bundle.tar.gz.gpg]
#
# Default bundle path: $HOME/migration-bundle.tar.gz.gpg

set -euo pipefail

BUNDLE="${1:-$HOME/migration-bundle.tar.gz.gpg}"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

if [ ! -f "$BUNDLE" ]; then
  echo "error: bundle not found at $BUNDLE" >&2
  echo "usage: $0 [path/to/migration-bundle.tar.gz.gpg]" >&2
  exit 1
fi

OS="$(uname -s)"
echo "==> Restoring migration bundle"
echo "    bundle:  $BUNDLE"
echo "    work:    $WORK"
echo "    OS:      $OS"
echo

# --- helper: yes/no prompt, default no ---
confirm() {
  local prompt="$1"
  read -r -p "$prompt [y/N] " ans
  [[ "$ans" =~ ^[Yy]$ ]]
}

# --- helper: install a file/dir if missing in $HOME, else prompt before overwrite ---
install_path() {
  local rel="$1"           # path relative to $HOME (e.g. .ssh, .kube/config)
  local src="$WORK/$rel"
  local dest="$HOME/$rel"

  if [ ! -e "$src" ]; then
    echo "    skip (not in bundle): $rel"
    return
  fi

  if [ -e "$dest" ]; then
    if ! confirm "    $dest exists — overwrite with bundle copy?"; then
      echo "    keeping existing: $dest"
      return
    fi
    mv "$dest" "$dest.bak.$(date +%s)"
  fi

  mkdir -p "$(dirname "$dest")"
  cp -a "$src" "$dest"
  echo "    restored: $dest"
}

# --- decrypt + extract ---
echo "==> Decrypting (you'll be prompted for the passphrase)..."
gpg --decrypt "$BUNDLE" | tar -C "$WORK" -xzf -
echo

# --- restore each path ---
echo "==> Restoring files into \$HOME..."

# SSH
install_path ".ssh"
# kubeconfig
install_path ".kube/config"
install_path ".kube/test"
# docker
install_path ".docker/config.json"
# argocd CLI
install_path ".config/argocd/config"
# terraform
install_path ".terraform.d/credentials.tfrc.json"
# git credentials (opt-in extras only present if bundled)
install_path ".git-credentials"
# Huawei Cloud (opt-in)
install_path ".hcloud"

# --- enforce SSH permissions ---
if [ -d "$HOME/.ssh" ]; then
  echo
  echo "==> Fixing ~/.ssh permissions..."
  chmod 700 "$HOME/.ssh"
  find "$HOME/.ssh" -type f -name '*.pub' -exec chmod 644 {} \;
  find "$HOME/.ssh" -type f ! -name '*.pub' ! -name 'known_hosts*' -exec chmod 600 {} \;
  [ -f "$HOME/.ssh/config" ] && chmod 600 "$HOME/.ssh/config"
  echo "    done."
fi

# --- GPG import ---
if [ -f "$WORK/gpg-secret.asc" ]; then
  echo
  echo "==> Importing GPG secret keys..."
  gpg --import "$WORK/gpg-secret.asc"
  if [ -f "$WORK/gpg-trust.txt" ]; then
    gpg --import-ownertrust "$WORK/gpg-trust.txt"
  fi
  echo "    done."
fi

# --- macOS-specific tips ---
if [ "$OS" = "Darwin" ]; then
  echo
  echo "==> macOS notes:"
  echo "    1. Switch git credential helper to Keychain (more secure than"
  echo "       ~/.git-credentials):"
  echo "         git config --global credential.helper osxkeychain"
  echo "         rm ~/.git-credentials   # after re-auth via 'git push'"
  echo
  echo "    2. Re-run cloud auth that wasn't bundled:"
  echo "         gcloud auth login"
  echo "         hcloud configure         # if Huawei Cloud creds were rotated"
  echo
  echo "    3. Tools to install (not in dotfiles):"
  echo "         brew install git zsh tmux vim neovim fzf ripgrep gnupg gh"
  echo "         brew install go node python kubectl helm terraform ansible argocd k9s"
  echo "         brew install --cask docker wezterm alacritty"
fi

echo
echo "==> Restore complete."
echo
echo "Once you've verified everything works (ssh, kubectl, git push, gpg --sign),"
echo "SHRED the bundle on this machine and the source:"
case "$OS" in
  Darwin) echo "    rm -P $BUNDLE" ;;
  *)      echo "    shred -u $BUNDLE" ;;
esac
