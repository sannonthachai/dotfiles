#!/usr/bin/env bash
# projects-bundle.sh — pack changes from ~/workspaces/ and ~/sannonthachai/
# into a single passphrase-encrypted bundle for transfer to a new machine.
#
# Reads the TSVs produced by projects-audit.sh.
# Output: ~/projects-bundle.tar.gz.gpg
#
# Bundle contents:
#   manifest/                     copy of the audit TSVs (used by restore)
#   dirty/<rel>/diff.patch        git diff HEAD (staged + unstaged)
#   dirty/<rel>/untracked.tgz     tar of untracked files (respects .gitignore)
#   dirty/<rel>/stash-N.patch     each stash as a patch
#   dirty/<rel>/full.tgz          (only when noremote flag) full repo, sans build artifacts
#   nongit/<rel>.tgz              non-git directory, sans build artifacts
#   nongit/<rel>                  loose files

set -euo pipefail

AUDIT_DIR="${AUDIT_DIR:-$HOME/.migration-audit}"
OUT="${OUT:-$HOME/projects-bundle.tar.gz.gpg}"

if [ ! -f "$AUDIT_DIR/dirty-repos.tsv" ]; then
  echo "error: audit not found at $AUDIT_DIR. Run projects-audit.sh first." >&2
  exit 1
fi

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

mkdir -p "$WORK/manifest" "$WORK/dirty" "$WORK/nongit"
cp "$AUDIT_DIR"/clean-repos.tsv "$AUDIT_DIR"/dirty-repos.tsv "$AUDIT_DIR"/non-git.tsv "$WORK/manifest/"

EXCLUDES=(
  --exclude='node_modules' --exclude='.next' --exclude='dist' --exclude='build'
  --exclude='target' --exclude='vendor' --exclude='.terraform'
  --exclude='.terragrunt-cache' --exclude='__pycache__' --exclude='.venv'
  --exclude='venv' --exclude='.gradle' --exclude='.cache' --exclude='coverage'
  --exclude='tmp' --exclude='*.log'
)

echo "==> Packing dirty repos..."
while IFS=$'\t' read -r rel url branch flags; do
  [ -n "$rel" ] || continue
  src="$HOME/$rel"
  dest="$WORK/dirty/$rel"
  mkdir -p "$dest"

  # If repo has no remote, bundle the whole tree (excluding build artifacts).
  if [[ ",$flags," == *,noremote,* ]]; then
    tar "${EXCLUDES[@]}" -C "$HOME" -czf "$dest/full.tgz" "$rel" 2>/dev/null || true
    echo "  full (no remote): $rel"
    continue
  fi

  # diff: staged + unstaged tracked changes
  git -C "$src" diff HEAD >"$dest/diff.patch" 2>/dev/null || true
  [ -s "$dest/diff.patch" ] || rm -f "$dest/diff.patch"

  # untracked files (respecting .gitignore)
  if [ -n "$(git -C "$src" ls-files --others --exclude-standard 2>/dev/null)" ]; then
    ( cd "$src" && git ls-files --others --exclude-standard -z \
        | tar --null -czf "$dest/untracked.tgz" -T - ) 2>/dev/null || true
  fi

  # each stash as a patch
  i=0
  while IFS= read -r _; do
    git -C "$src" stash show -p --binary "stash@{$i}" >"$dest/stash-$i.patch" 2>/dev/null || true
    [ -s "$dest/stash-$i.patch" ] || rm -f "$dest/stash-$i.patch"
    i=$((i+1))
  done < <(git -C "$src" stash list 2>/dev/null)

  echo "  diff/untracked/stash: $rel ($flags)"
done <"$AUDIT_DIR/dirty-repos.tsv"

echo "==> Packing non-git entries..."
while IFS=$'\t' read -r rel kind; do
  [ -n "$rel" ] || continue
  src="$HOME/$rel"
  if [ "$kind" = FILE ]; then
    dest="$WORK/nongit/$rel"
    mkdir -p "$(dirname "$dest")"
    cp -a "$src" "$dest"
    echo "  file: $rel"
  else
    dest="$WORK/nongit/$rel.tgz"
    mkdir -p "$(dirname "$dest")"
    tar "${EXCLUDES[@]}" -C "$HOME" -czf "$dest" "$rel" 2>/dev/null || true
    echo "  dir:  $rel  ($kind)"
  fi
done <"$AUDIT_DIR/non-git.tsv"

echo
echo "==> Encrypting (passphrase prompt next)..."
echo "    Use a strong passphrase — bundle contains uncommitted source code."
echo
tar -C "$WORK" -czf - . | gpg --symmetric --cipher-algo AES256 --output "$OUT"
chmod 600 "$OUT"

echo
echo "==> Done."
echo "    Bundle: $OUT"
echo "    Size:   $(du -h "$OUT" | cut -f1)"
echo
echo "Transfer to the new machine, then run projects-restore.sh there."
