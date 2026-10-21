---
name: project_jvfs_registry_cleanup
description: JVFS GitLab registry pruning — gitops-pinned tags are the keep set; GC alone frees nothing
metadata:
  type: project
---

Registry on `jvfs-gitlab` (192.168.12.101) was 63 GiB of /data's 136G/200G (2026-09-14).
Tooling in `~/workspaces/jvfs/etc/remove-unuse-image/`, driven by the
`remove-unuse-image` skill; full reference in that dir's CLAUDE.md.

**Why:** `gitlab-ctl registry-garbage-collect` reclaims zero bytes here — every blob is
referenced by a live tag (`blobs_to_delete=0`). Space only returns if tags are deleted
first. The safe keep set is whatever the sit/uat/prod gitops overlays pin, plus anything
newer; repos gitops never references (`front/*`) are left alone because they may be
deployed outside these repos.

**How to apply:** re-snapshot the registry every run (CI pushes constantly; a stale
snapshot deletes brand-new images). Chosen baseline is `max` = 621 tags, 31.5 GiB freed,
vs `min` = 302 tags, 14.6 GiB. Tag delete is project-scoped API only; the instance sits
behind Cloudflare, which 403s a default urllib User-Agent with `error code: 1010`. Host
has no passwordless sudo, so registry filesystem work goes through `docker exec gitlab`.
GC (`./gc.sh`) is part of the flow, not optional — tag deletion alone frees zero bytes — but it takes the registry read-only, so agree the window first. Related: [[project_ea_harbor_registry]],
[[reference_claude_skills]].
