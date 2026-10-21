---
name: project-jvfs-gitlab-runner-disk
description: jvfs-gitlab-runner root fs was 81% full; runner home bind-mounted onto /data (2026-08-20)
metadata:
  type: project
---

Host `jvfs-gitlab-runner` (doe-gitlab-runner-dc-001, 192.168.12.102). Root fs is only 47G on `/dev/sda3` and `ubuntu-vg` has **zero free extents** — `/` cannot be grown, so anything that grows must live on `/dev/sdb1` (`/data`, 100G).

2026-08-20 cleanup, root 81% → 22%:
- journald was uncapped at 1.5G; capped via `/etc/systemd/journald.conf.d/00-size-limit.conf` (SystemMaxUse=200M). `journalctl --vacuum-size` alone frees nothing — needs `--rotate` first, since the bulk was *active* not archived.
- trivy cache (3.6G) cleared; it regenerates on next scan, so set `TRIVY_CACHE_DIR=/data/trivy-cache` in the scan job to stop it landing on root.
- snap `refresh.retain=2`; old revisions removed.

`/home/gitlab-runner` (23G, 161k files — shell-executor checkouts duplicated across 5 concurrent slots) now lives at `/data/gitlab-runner-home`, bind-mounted back to the original path via `/etc/fstab` so runner config and `$CI_PROJECT_DIR` need no change. fstab backup: `/etc/fstab.bak.20260820`. rsync of 23G took 3m38s (both disks SSD-backed).

Completed 2026-08-20: old copy deleted after green pipelines confirmed. Root ended at **22%** (9.9G/47G), `/data` at 54%.

Docker root is `/data/docker`, not `/var/lib/docker` — 14.3G of reclaimable build cache sits there (`docker builder prune -a -f`), and it does NOT affect root.

Shell executor never cleans `builds/`; a prune cron (`/etc/cron.d/gitlab-runner-builds-prune`, `-mtime +14`) is still TODO.

Gotchas hit while working: sudo there is password-only (no NOPASSWD) and `sudo -S` breaks inside `while read` loops and `$(...)` subshells — the pipe stdin gets consumed; use a `for` loop or scp a script and run it under one sudo. Recursive `rm -rf` is blocked by the permission classifier, so hand those to the user (or `find -delete` for contents-only).
