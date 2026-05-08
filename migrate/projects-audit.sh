#!/usr/bin/env bash
# projects-audit.sh — classify everything under ~/workspaces/ and
# ~/sannonthachai/ into clean repos / dirty repos / non-git.
#
# Recurses through grouping directories (e.g. ~/workspaces/ea/ contains
# many nested repos), but stops descending once it finds a repo or a
# build-artifact directory.
#
# Output (TSV files at $OUT_DIR, default ~/.migration-audit):
#   clean-repos.tsv   rel-path<TAB>origin-url<TAB>branch
#   dirty-repos.tsv   rel-path<TAB>origin-url<TAB>branch<TAB>flags
#   non-git.tsv       rel-path<TAB>kind   (kind = "DIR <size>" or "FILE")
#   warnings.txt      free-form warnings
#
# Flags on dirty-repos:
#   wt        working tree dirty (git status --porcelain non-empty)
#   stash     repo has stash entries
#   unpushed  current branch has commits ahead of upstream
#   noupstrm  current branch has no configured upstream
#   noremote  no 'origin' remote configured (re-clone impossible)
#   detached  HEAD detached

set -euo pipefail

SCAN_ROOTS=( "$HOME/workspaces" "$HOME/sannonthachai" )
OUT_DIR="${OUT_DIR:-$HOME/.migration-audit}"

ARTIFACT_NAMES=(
  node_modules .terraform .terragrunt-cache .next vendor target dist build
  __pycache__ .venv venv .gradle .cache coverage tmp
)

mkdir -p "$OUT_DIR"
: >"$OUT_DIR/clean-repos.tsv"
: >"$OUT_DIR/dirty-repos.tsv"
: >"$OUT_DIR/non-git.tsv"
: >"$OUT_DIR/warnings.txt"

# --- Step 1: find every repo (parent of a .git dir) under the scan roots,
# pruning build-artifact subtrees. Sort longest-first for prefix matching.
echo "==> Locating repos..."
prune_args=()
for n in "${ARTIFACT_NAMES[@]}"; do
  prune_args+=( -name "$n" -o )
done
# drop trailing -o
unset 'prune_args[${#prune_args[@]}-1]'

REPOS_TMP="$(mktemp)"
trap 'rm -f "$REPOS_TMP"' EXIT

{
  for root in "${SCAN_ROOTS[@]}"; do
    if [ ! -d "$root" ]; then
      echo "scan root missing: $root" >>"$OUT_DIR/warnings.txt"
      continue
    fi
    find "$root" \( "${prune_args[@]}" \) -prune \
      -o -name .git \( -type d -o -type f \) -print 2>/dev/null || true
  done
} | while IFS= read -r gd; do
    dirname "$gd"
  done | sort -u >"$REPOS_TMP" || true

REPO_COUNT=$(wc -l <"$REPOS_TMP")
echo "    found $REPO_COUNT repos"

# Load repos into an associative array for O(1) lookup
declare -A IS_REPO
while IFS= read -r r; do
  [ -n "$r" ] && IS_REPO["$r"]=1
done <"$REPOS_TMP"

# Returns 0 if $1 has any repo strictly underneath it.
has_repo_under() {
  local prefix="$1/"
  # grep is faster than a bash loop for this many entries
  grep -q "^$prefix" "$REPOS_TMP"
}

# --- repo classification ---
classify_repo() {
  local d="$1"
  local rel="${d#$HOME/}"
  local url branch flags=""

  url="$(git -C "$d" remote get-url origin 2>/dev/null || true)"
  branch="$(git -C "$d" symbolic-ref --short HEAD 2>/dev/null || echo DETACHED)"
  [ "$branch" = DETACHED ] && flags="${flags:+$flags,}detached"

  [ -n "$(git -C "$d" status --porcelain 2>/dev/null)" ] && flags="${flags:+$flags,}wt"
  [ -n "$(git -C "$d" stash list 2>/dev/null)" ]         && flags="${flags:+$flags,}stash"

  if [ -z "$url" ]; then
    flags="${flags:+$flags,}noremote"
  elif [ "$branch" != DETACHED ]; then
    if git -C "$d" rev-parse "@{u}" >/dev/null 2>&1; then
      [ -n "$(git -C "$d" log '@{u}..HEAD' --oneline 2>/dev/null)" ] \
        && flags="${flags:+$flags,}unpushed"
    else
      flags="${flags:+$flags,}noupstrm"
    fi
  fi

  if [ -z "$flags" ]; then
    printf '%s\t%s\t%s\n' "$rel" "$url" "$branch" >>"$OUT_DIR/clean-repos.tsv"
  else
    printf '%s\t%s\t%s\t%s\n' "$rel" "$url" "$branch" "$flags" >>"$OUT_DIR/dirty-repos.tsv"
  fi
}

classify_non_git_dir() {
  local d="$1"
  local rel="${d#$HOME/}"
  local size
  size="$(du -sh "$d" 2>/dev/null | cut -f1)"
  printf '%s\tDIR %s\n' "$rel" "$size" >>"$OUT_DIR/non-git.tsv"
}

# --- Step 2: walk the tree top-down, descending only into intermediate
# directories that contain repos beneath them. Stop at repos and at
# leaf non-git dirs (which get tarred whole).
walk() {
  local dir="$1"
  local entry
  for entry in "$dir"/* "$dir"/.[!.]*; do
    [ -e "$entry" ] || continue
    local base="$(basename "$entry")"

    if [ -f "$entry" ]; then
      printf '%s\tFILE\n' "${entry#$HOME/}" >>"$OUT_DIR/non-git.tsv"
      continue
    fi

    [ -d "$entry" ] || continue

    # skip build-artifact dirs entirely
    for n in "${ARTIFACT_NAMES[@]}"; do
      if [ "$base" = "$n" ]; then
        continue 2
      fi
    done

    if [ -n "${IS_REPO[$entry]:-}" ]; then
      classify_repo "$entry"
    elif has_repo_under "$entry"; then
      walk "$entry"
    else
      classify_non_git_dir "$entry"
    fi
  done
}

echo "==> Walking and classifying..."
for root in "${SCAN_ROOTS[@]}"; do
  [ -d "$root" ] || continue
  walk "$root"
done

clean=$(wc -l <"$OUT_DIR/clean-repos.tsv")
dirty=$(wc -l <"$OUT_DIR/dirty-repos.tsv")
nong=$(wc -l <"$OUT_DIR/non-git.tsv")
warn=$(wc -l <"$OUT_DIR/warnings.txt")

echo
echo "==> Audit complete: $OUT_DIR/"
printf '    %4d clean repos\n'      "$clean"
printf '    %4d dirty repos\n'      "$dirty"
printf '    %4d non-git entries\n'  "$nong"
[ "$warn" -gt 0 ] && printf '    %4d warnings (see warnings.txt)\n' "$warn"
echo
echo "Review the TSVs, then run projects-bundle.sh to pack changes for transfer."
echo "Edit non-git.tsv first if you want to skip large directories."
