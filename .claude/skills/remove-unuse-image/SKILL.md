---
name: remove-unuse-image
description: Delete unused Docker images from the JVFS GitLab registry (jvfs-gitlab, 192.168.12.101) to reclaim disk, keeping every tag that the sit/uat/prod gitops overlays pin plus anything newer. Use when the user says "remove unuse image", "delete unused images", "registry disk full", "clean gitlab registry", "gitlab storage full", or asks to prune / garbage-collect the container registry.
---

# remove-unuse-image

Prune the JVFS GitLab registry without breaking any cluster.

Full reference, including every gotcha, lives in
`~/workspaces/jvfs/etc/remove-unuse-image/CLAUDE.md`. **Read it first** — it is
short and records failure modes that cost real time.

## The rule

1. Never delete a tag pinned by any gitops overlay (sit / uat / prod)
2. Never delete a tag newer than the pinned one
3. Never touch a repository gitops does not reference at all

## Flow — use these scripts, do not rewrite them

```sh
cd ~/workspaces/jvfs/etc/remove-unuse-image
set -a && . .env && set +a           # GITLAB_TOKEN, api scope

./dump_registry_tags.sh              # ALWAYS re-snapshot, never reuse an old one
./extract_gitops_images.py           # overlays -> gitops-images.tsv + report
./reconcile.py --mode max            # -> delete-candidates-max.txt
./build_keep_list.sh max             # -> keep-tags-max.tsv
./estimate.sh                        # GiB that GC would free

./delete_tags.py                     # dry run, always
./delete_tags.py --apply --limit 10  # canary, then check the CSV log
./delete_tags.py --apply             # full run

./gc.sh                              # frees the disk; registry READ-ONLY while it runs
```

GC is part of this flow, not an optional afterthought — deleting tags alone
frees zero bytes. Always run it, but **announce the read-only window and get a
go-ahead on timing first**; CI pushes fail while it runs.

## Checklist

- [ ] Read `remove-unuse-image/CLAUDE.md`
- [ ] Confirm VPN is up (`ssh jvfs-gitlab 'echo ok'`)
- [ ] Re-snapshot the registry — a stale snapshot deletes brand-new CI images
- [ ] Re-parse the overlays; both gitops repos may have moved on
- [ ] Run `reconcile.py` and report KEEP / DELETE / SKIPPED counts
- [ ] Show the reclaim estimate for the chosen mode **before** asking to proceed
- [ ] Dry run `delete_tags.py`, confirm all repository ids resolve
- [ ] **Get explicit confirmation** — tag deletion is irreversible
- [ ] Canary `--limit 10`, inspect the CSV log, then the full run
- [ ] Re-snapshot and confirm the registry tag count dropped by exactly N
- [ ] Confirm the GC window with the user, then run `./gc.sh`
- [ ] Report before/after registry size and `/data` usage

## Rules

- **Dry run first, every time.** `--apply` is never the first invocation.
- **Confirm before `--apply`.** Deleted tags cannot be restored; the image must
  be rebuilt and re-pushed by CI.
- **`max` is the chosen default** (aggressive, ~2x the reclaim of `min`) with
  unpinned repositories excluded. `min` keeps every cluster's rollback path.
  If the user has not said which, say which one you are using and why.
- **Never `--include-unpinned-repos` without asking.** Those repos (`front/*`
  and friends) may be deployed outside these gitops repos.
- **GC always runs — but never silently.** It is the only step that frees disk,
  so the job is not done without it. It takes the registry read-only and CI
  pushes fail, so state the window and wait for a go-ahead before starting it.
- Report counts at each step: tags kept, deleted, skipped and why.

## Asking the user

- Baseline mode: `max` (more space) or `min` (safer rollback path)?
- Include repositories absent from gitops? (default: no)
- When to run GC — it needs a quiet window. Ask *when*, not *whether*.

## Token

`GITLAB_TOKEN` lives in `~/workspaces/jvfs/etc/remove-unuse-image/.env`
(`chmod 600`, `api` scope). Never paste it into chat or echo it into a command
whose output is shown. `.env.example` documents the shape.
