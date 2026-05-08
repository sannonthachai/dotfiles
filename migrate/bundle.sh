#!/usr/bin/env bash
# bundle.sh — pack secrets/credentials into a single encrypted archive
# for migrating to a new machine. Run on the SOURCE machine.
#
# Output: $HOME/migration-bundle.tar.gz.gpg (symmetric, passphrase-protected).
# Pair with restore.sh on the destination machine.
#
# What's included (only if present):
#   ~/.ssh/                            (keys + config; known_hosts skipped)
#   ~/.kube/config, ~/.kube/test       (cluster contexts)
#   ~/.docker/config.json              (registry auth)
#   ~/.config/argocd/config            (argocd CLI auth)
#   ~/.terraform.d/credentials.tfrc.json
#   ~/.git-credentials                 (only if user opts in — prefer keychain)
#   ~/.hcloud/                         (Huawei Cloud CLI; opt-in)
#   gpg-secret.asc + gpg-trust.txt     (exported from gpg keyring)
#
# What's NOT included (regenerate on destination):
#   ~/.kube/cache, ~/.kube/http-cache, ~/.docker/buildx, ~/.docker/.token_seed*
#   ~/.terraform.d/checkpoint_*, ~/.ansible/{cp,tmp}, gpg sockets
#   gcloud (re-run `gcloud auth login`)

set -euo pipefail

OUT="${OUT:-$HOME/migration-bundle.tar.gz.gpg}"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

echo "==> Migration bundle"
echo "    work dir: $WORK"
echo "    output:   $OUT"
echo

# --- helper: copy a path into the staging dir, preserving perms, if it exists ---
include() {
  local src="$1"
  if [ ! -e "$src" ]; then
    echo "    skip (not present): $src"
    return
  fi
  local rel="${src#$HOME/}"
  local dest="$WORK/$rel"
  mkdir -p "$(dirname "$dest")"
  cp -a "$src" "$dest"
  echo "    included: $src"
}

# --- helper: yes/no prompt, default no ---
confirm() {
  local prompt="$1"
  read -r -p "$prompt [y/N] " ans
  [[ "$ans" =~ ^[Yy]$ ]]
}

# --- SSH ---
if [ -d "$HOME/.ssh" ]; then
  mkdir -p "$WORK/.ssh"
  # copy everything except known_hosts (host-specific, regenerates on use)
  for f in "$HOME/.ssh"/*; do
    [ -e "$f" ] || continue
    case "$(basename "$f")" in
      known_hosts|known_hosts.old) continue ;;
    esac
    cp -a "$f" "$WORK/.ssh/"
  done
  echo "    included: ~/.ssh/ (known_hosts skipped)"
fi

# --- kubeconfig ---
include "$HOME/.kube/config"
include "$HOME/.kube/test"

# --- docker registry auth ---
include "$HOME/.docker/config.json"

# --- argocd CLI ---
include "$HOME/.config/argocd/config"

# --- terraform credentials ---
include "$HOME/.terraform.d/credentials.tfrc.json"

# --- opt-in: git-credentials (plaintext tokens; macOS Keychain is preferred) ---
if [ -f "$HOME/.git-credentials" ]; then
  if confirm "Include ~/.git-credentials? (plaintext tokens — recommend re-auth via Keychain on macOS instead)"; then
    include "$HOME/.git-credentials"
  fi
fi

# --- opt-in: Huawei Cloud (rotate AK/SK instead of copying when possible) ---
if [ -d "$HOME/.hcloud" ]; then
  if confirm "Include ~/.hcloud/? (consider rotating AK/SK on the new machine instead)"; then
    include "$HOME/.hcloud"
  fi
fi

# --- GPG: export keys + ownertrust ---
if command -v gpg >/dev/null 2>&1 && gpg --list-secret-keys >/dev/null 2>&1; then
  if confirm "Export GPG secret keys + ownertrust into the bundle?"; then
    gpg --export-secret-keys --armor >"$WORK/gpg-secret.asc"
    gpg --export-ownertrust >"$WORK/gpg-trust.txt"
    chmod 600 "$WORK/gpg-secret.asc" "$WORK/gpg-trust.txt"
    echo "    included: gpg-secret.asc + gpg-trust.txt"
  fi
fi

# --- pack + encrypt ---
echo
echo "==> Packing and encrypting..."
echo "    You will be prompted for a passphrase. Use a strong one — this"
echo "    bundle contains plaintext credentials."
echo

# tar from $WORK (so paths inside the archive are relative, not absolute)
tar -C "$WORK" -czf - . | gpg --symmetric --cipher-algo AES256 --output "$OUT"

chmod 600 "$OUT"

echo
echo "==> Done."
echo "    Bundle: $OUT"
echo "    Size:   $(du -h "$OUT" | cut -f1)"
echo
echo "Transfer the bundle to the new machine via a secure channel (USB stick,"
echo "Syncthing, encrypted iCloud Drive, etc.), then run restore.sh there."
echo
echo "After successful restore on the destination, SHRED the source bundle:"
echo "    shred -u $OUT       (Linux)"
echo "    rm -P $OUT          (macOS)"
