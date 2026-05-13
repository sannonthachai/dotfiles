#!/usr/bin/env bash
# pm-bundle.sh — bundle the password-store + GPG key needed by `pm`
# (bin/pm wraps `pass`, which encrypts each entry with your GPG key).
# Run on the SOURCE machine. Pair with pm-restore.sh on the destination.
#
# Output: $HOME/pm-bundle.tar.gz.gpg (symmetric, passphrase-protected).
#
# What's included:
#   ~/.password-store/                 (encrypted secrets)
#   gpg-secret.asc + gpg-trust.txt     (exported from gpg keyring)

set -euo pipefail

# gpg-agent needs to know which TTY to open pinentry on. Without this,
# the symmetric passphrase prompt can fail silently when stdin is a pipe.
export GPG_TTY="${GPG_TTY:-$(tty 2>/dev/null || true)}"

OUT="${OUT:-$HOME/pm-bundle.tar.gz.gpg}"
STORE_DIR="${PASSWORD_STORE_DIR:-$HOME/.password-store}"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

echo "==> pm bundle"
echo "    store:    $STORE_DIR"
echo "    work dir: $WORK"
echo "    output:   $OUT"
echo

# --- password-store ---
if [ ! -d "$STORE_DIR" ]; then
  echo "error: password store not found at $STORE_DIR" >&2
  echo "       set PASSWORD_STORE_DIR if it lives elsewhere" >&2
  exit 1
fi
mkdir -p "$WORK/.password-store"
cp -a "$STORE_DIR"/. "$WORK/.password-store/"
echo "    included: $STORE_DIR -> .password-store/"

# --- GPG secret key + ownertrust ---
if ! command -v gpg >/dev/null 2>&1; then
  echo "error: gpg not installed — cannot export the key that decrypts the store" >&2
  exit 1
fi
if ! gpg --list-secret-keys >/dev/null 2>&1 || \
   [ -z "$(gpg --list-secret-keys --with-colons | grep -c '^sec')" ]; then
  echo "error: no GPG secret keys found — pass cannot decrypt without one" >&2
  exit 1
fi
gpg --export-secret-keys --armor >"$WORK/gpg-secret.asc"
gpg --export-ownertrust >"$WORK/gpg-trust.txt"
chmod 600 "$WORK/gpg-secret.asc" "$WORK/gpg-trust.txt"
echo "    included: gpg-secret.asc + gpg-trust.txt"

# --- pack + encrypt ---
echo
echo "==> Packing and encrypting..."
echo "    You will be prompted for a passphrase. Use a strong one — this"
echo "    bundle contains your full password store + GPG private key."
echo

# Write tarball first, then encrypt as a separate step. Avoids stdin
# contention between tar and the pinentry prompt.
TAR="$WORK/bundle.tar.gz"
tar -C "$WORK" --exclude='./bundle.tar.gz' -czf "$TAR" .
gpg --symmetric --cipher-algo AES256 --output "$OUT" "$TAR"

chmod 600 "$OUT"

echo
echo "==> Done."
echo "    Bundle: $OUT"
echo "    Size:   $(du -h "$OUT" | cut -f1)"
echo
echo "Transfer the bundle to the new machine via a secure channel, then run"
echo "pm-restore.sh there."
echo
echo "After successful restore, SHRED the source bundle:"
echo "    shred -u $OUT       (Linux)"
echo "    rm -P $OUT          (macOS)"
