#!/usr/bin/env bash
# pm-restore.sh — restore a pm-bundle on the DESTINATION machine.
# Pair with pm-bundle.sh on the source.
#
# Usage:
#   ./pm-restore.sh [path/to/pm-bundle.tar.gz.gpg]
#
# Default bundle path: $HOME/pm-bundle.tar.gz.gpg

set -euo pipefail

BUNDLE="${1:-$HOME/pm-bundle.tar.gz.gpg}"
STORE_DIR="${PASSWORD_STORE_DIR:-$HOME/.password-store}"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

if [ ! -f "$BUNDLE" ]; then
  echo "error: bundle not found at $BUNDLE" >&2
  echo "usage: $0 [path/to/pm-bundle.tar.gz.gpg]" >&2
  exit 1
fi

OS="$(uname -s)"
echo "==> Restoring pm bundle"
echo "    bundle:  $BUNDLE"
echo "    store:   $STORE_DIR"
echo "    work:    $WORK"
echo "    OS:      $OS"
echo

confirm() {
  local prompt="$1"
  read -r -p "$prompt [y/N] " ans
  [[ "$ans" =~ ^[Yy]$ ]]
}

if ! command -v gpg >/dev/null 2>&1; then
  echo "error: gpg not installed — install gnupg first (brew install gnupg)" >&2
  exit 1
fi

echo "==> Decrypting (you'll be prompted for the passphrase)..."
gpg --decrypt "$BUNDLE" | tar -C "$WORK" -xzf -
echo

# --- GPG import first (pass needs the key before it can read the store) ---
if [ -f "$WORK/gpg-secret.asc" ]; then
  echo "==> Importing GPG secret keys..."
  gpg --import "$WORK/gpg-secret.asc"
  if [ -f "$WORK/gpg-trust.txt" ]; then
    gpg --import-ownertrust "$WORK/gpg-trust.txt"
  fi
  echo
fi

# --- password-store ---
if [ -d "$WORK/.password-store" ]; then
  if [ -e "$STORE_DIR" ]; then
    if ! confirm "$STORE_DIR exists — overwrite with bundle copy?"; then
      echo "    keeping existing: $STORE_DIR"
    else
      mv "$STORE_DIR" "$STORE_DIR.bak.$(date +%s)"
      mkdir -p "$STORE_DIR"
      cp -a "$WORK/.password-store/." "$STORE_DIR/"
      echo "    restored: $STORE_DIR"
    fi
  else
    mkdir -p "$STORE_DIR"
    cp -a "$WORK/.password-store/." "$STORE_DIR/"
    echo "    restored: $STORE_DIR"
  fi
fi

# --- sanity check ---
echo
echo "==> Verifying decryption..."
if command -v pass >/dev/null 2>&1; then
  FIRST="$(find "$STORE_DIR" -type f -name '*.gpg' 2>/dev/null | head -n1 || true)"
  if [ -n "$FIRST" ]; then
    REL="${FIRST#$STORE_DIR/}"
    REL="${REL%.gpg}"
    if pass show "$REL" >/dev/null 2>&1; then
      echo "    OK: decrypted '$REL'"
    else
      echo "    ! could not decrypt '$REL' — check that GPG agent is running"
      echo "      and that the imported key matches the one used to encrypt."
    fi
  else
    echo "    (no entries in store yet — nothing to verify)"
  fi
else
  echo "    pass not installed — run install.sh to set it up, then try: pm ls"
fi

echo
echo "==> Restore complete."
echo
echo "Try it:  pm ls"
echo
echo "Once verified, SHRED the bundle on both machines:"
case "$OS" in
  Darwin) echo "    rm -P $BUNDLE" ;;
  *)      echo "    shred -u $BUNDLE" ;;
esac
