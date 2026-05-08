#!/usr/bin/env bash
# projects-restore.sh — re-clone clean repos and re-apply dirty-repo changes
# from a bundle produced by projects-bundle.sh.
#
# Usage:
#   ./projects-restore.sh [path/to/projects-bundle.tar.gz.gpg]
#
# Default bundle path: $HOME/projects-bundle.tar.gz.gpg
#
# Requirements on this machine:
#   - git, gpg, tar
#   - SSH/HTTPS access to the same git remotes (run secrets-restore equivalent
#     first to install ~/.ssh keys and gh/git-credentials)

set -euo pipefail

BUNDLE="${1:-$HOME/projects-bundle.tar.gz.gpg}"
LOG="${HOME}/projects-restore.log"

if [ ! -f "$BUNDLE" ]; then
  echo "error: bundle not found at $BUNDLE" >&2
  exit 1
fi

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

echo "==> Decrypting bundle (passphrase prompt)..."
gpg --decrypt "$BUNDLE" | tar -C "$WORK" -xzf -

: >"$LOG"
note() { printf '%s\n' "$*" | tee -a "$LOG"; }

# 1. Clone clean repos into mirrored paths.
note "==> Cloning clean repos..."
while IFS=$'\t' read -r rel url branch; do
  [ -n "$rel" ] && [ -n "$url" ] || continue
  dest="$HOME/$rel"
  if [ -e "$dest" ]; then
    note "  exists, skip: $rel"
    continue
  fi
  mkdir -p "$(dirname "$dest")"
  if git clone --quiet "$url" "$dest"; then
    if [ "$branch" != DETACHED ] && [ -n "$branch" ]; then
      git -C "$dest" checkout --quiet "$branch" 2>/dev/null || \
        note "    WARN: branch $branch not found in $rel"
    fi
    note "  cloned: $rel"
  else
    note "  FAILED clone: $rel ($url)"
  fi
done <"$WORK/manifest/clean-repos.tsv"

# 2. Restore dirty repos: clone, then re-apply diff/untracked/stash, OR
#    extract full tree if the repo had no remote.
note "==> Restoring dirty repos..."
while IFS=$'\t' read -r rel url branch flags; do
  [ -n "$rel" ] || continue
  dest="$HOME/$rel"
  diffdir="$WORK/dirty/$rel"

  # No-remote case: the bundle has the full tree as full.tgz.
  if [ -f "$diffdir/full.tgz" ]; then
    if [ -e "$dest" ]; then
      note "  exists, skip (no-remote): $rel"
      continue
    fi
    mkdir -p "$(dirname "$dest")"
    tar -C "$HOME" -xzf "$diffdir/full.tgz"
    note "  full restored (no remote): $rel"
    continue
  fi

  # Cloneable case
  if [ ! -d "$dest" ]; then
    if [ -z "$url" ]; then
      note "  SKIP (no URL and no full.tgz): $rel"
      continue
    fi
    mkdir -p "$(dirname "$dest")"
    if ! git clone --quiet "$url" "$dest"; then
      note "  FAILED clone: $rel"
      continue
    fi
    [ "$branch" != DETACHED ] && [ -n "$branch" ] && \
      git -C "$dest" checkout --quiet "$branch" 2>/dev/null || true
  fi

  # Apply diff
  if [ -f "$diffdir/diff.patch" ]; then
    if git -C "$dest" apply --3way "$diffdir/diff.patch" 2>>"$LOG"; then
      note "  diff applied: $rel"
    else
      note "  WARN: diff failed for $rel — saved at $diffdir/diff.patch"
      cp "$diffdir/diff.patch" "$dest/.migration-failed-diff.patch"
    fi
  fi

  # Restore untracked files
  if [ -f "$diffdir/untracked.tgz" ]; then
    tar -C "$dest" -xzf "$diffdir/untracked.tgz" 2>>"$LOG" \
      && note "  untracked restored: $rel" \
      || note "  WARN: untracked extract failed: $rel"
  fi

  # Re-apply stashes (don't pop — push them onto the new stash list)
  for stash in "$diffdir"/stash-*.patch; do
    [ -f "$stash" ] || continue
    base="$(basename "$stash")"
    if git -C "$dest" apply --check "$stash" 2>/dev/null; then
      git -C "$dest" apply "$stash" \
        && git -C "$dest" stash push --quiet -m "restored from $base" \
        && note "  stash restored ($base): $rel"
    else
      note "  WARN: stash didn't apply ($base): $rel — saved at $stash"
      cp "$stash" "$dest/.migration-failed-$base"
    fi
  done
done <"$WORK/manifest/dirty-repos.tsv"

# 3. Restore non-git entries (dirs as tarballs, loose files as-is).
note "==> Restoring non-git entries..."
while IFS=$'\t' read -r rel kind; do
  [ -n "$rel" ] || continue
  dest="$HOME/$rel"
  if [ "$kind" = FILE ]; then
    if [ -e "$dest" ]; then
      note "  exists, skip: $rel"
      continue
    fi
    mkdir -p "$(dirname "$dest")"
    cp -a "$WORK/nongit/$rel" "$dest"
    note "  file restored: $rel"
  else
    if [ -e "$dest" ]; then
      note "  exists, skip: $rel"
      continue
    fi
    src="$WORK/nongit/$rel.tgz"
    if [ -f "$src" ]; then
      tar -C "$HOME" -xzf "$src"
      note "  dir restored: $rel"
    fi
  fi
done <"$WORK/manifest/non-git.tsv"

echo
echo "==> Restore complete. Log: $LOG"
echo
echo "Next steps:"
echo "  - Search the log for 'WARN' or 'FAILED' lines and resolve manually."
echo "  - Failed diffs/stashes are kept as .migration-failed-*.patch in the repo."
echo "  - Once verified, shred the bundle:"
case "$(uname -s)" in
  Darwin) echo "      rm -P $BUNDLE" ;;
  *)      echo "      shred -u $BUNDLE" ;;
esac
