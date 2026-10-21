---
name: feedback-jvfs-branch-after-release
description: "In jvfs/document-control, switch back to dev after a release — main is release-only and I twice committed feature work onto it"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 28df0a36-ded6-46ab-a710-7f3f85dde382
  modified: 2026-08-18T15:43:33.173Z
---

In `~/workspaces/jvfs/etc/document-control`, feature work is committed to **`dev`**;
`main` only ever advances by a fast-forward merge from `dev` at release time (`make release`
enforces being on `main`). After a deploy, the working branch is left on `main` — and I have
twice then committed the next feature straight onto `main` without noticing.

**Why:** `make release` has a release-branch guard, so the deploy flow always ends with
`git checkout main`. Nothing switches back, and `git commit` doesn't complain. Both times the
fix was a cherry-pick onto `dev` plus `git reset --hard origin/main` — recoverable, but it
rewrites a pushed branch, which is exactly the kind of history surgery worth avoiding.

**How to apply:** after `kubectl apply -k` completes, immediately `git checkout dev`. Before
any `git commit` in this repo, check `git branch --show-current` first. A `git push origin dev`
that reports "Everything up-to-date" right after committing is the tell that the commit landed
on the wrong branch.

Related: [[project_jvfs_sp_archive_migration]]
