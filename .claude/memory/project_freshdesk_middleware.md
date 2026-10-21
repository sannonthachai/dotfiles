---
name: project-freshdesk-middleware
description: "Freshdesk rate-limit middleware (Go) deployed to jvfs-sit-cluster ns sit-freshdesk; real account limit is 100/min, sync budget 20/min"
metadata:
  node_type: memory
  type: project
  originSessionId: c4875f28-04fb-4bdf-a94d-b22b8abb7655
  modified: 2026-10-06T04:01:06.197Z
---

Freshdesk middleware POC (deployed 2026-10-06). Repo `~/workspaces/jvfs/etc/freshdesk-middleware-service` → gitlab `front/freshdesk-middleware-service`; CI (core/cicd iden/go) builds only on tag push `v0.x.x` → `192.168.12.101:5050/front/freshdesk-middleware-service`. GitOps `core/gitops` overlays/sit/freshdesk, ArgoCD app `sit-freshdesk` (applied manually, image-updater semver v0.x.x). DB `freshdesk_poc` on jvfs-sit-iden 192.168.11.81:5433 (container jvfs-postgres-postgres-1, shared with jvfs_docs). Vault SIT mount `freshdesk-sit`, policy `freshdesk-policy-ro`.

Gotchas:
- **Limits are bucketed**: tickets endpoints (list/view/conversations) 100/min = bottleneck (~0–30 remaining at peak); contacts 100/min (idle); overall 400/min (search, agents/me). Sync tickets budget 20/min, pause <30. Phase 2 backfill ≈ 17 days.
- `?email=`/`?requester_id=` list filters return ALL tickets (no 30-day default window).
- First client: iden/mol_eworkpermit_auth_api — Freshdesk URL + key hardcoded in appsettings.<env>.json (not gitops); override via env `Domain__FreshDesk_API`, key `FreshDeskCredential`.
- v0.2.0 (2026-10-06): contacts/requester + email= from DB, usage_minute + `middleware mark|report`, DB breaker. Baseline marked 2026-10-06 14:41 ICT; plan: switch auth-api after 5 working days (~13 Oct), report ~20 Oct (headline = minutes tickets remaining<30).
- Freshdesk `attachment_url` is S3-signed for 300 s → DB copies with attachments served only within 4 min (70% of auth-api fallbacks).
- 2026-10-08: signed-link fix (`/files/` on freshdesk-files-sit.futuresky.co.th, 8h TTL; spec 2026-10-08-signed-attachment-links-design.md) DEFERRED by manager: go to Production with current v0.2.3 behaviour first, measure real effect, then decide. Don't start the plan/implementation until the user brings Production data.
- List endpoint lacks `attachments`/`source_additional_info`; `include=description` costs 2 credits.
- An orphaned local `sync` session (laptop IP change) held the pg advisory lock and crash-looped the sync pod → `pg_terminate_backend`. Never run local `sync` against freshdesk_poc while the cluster one runs.
- Freshdesk webhook cannot reach `*.jvfs.local` → SIT relies on 60 s poll.
- testcontainers on this Mac (colima) needs DOCKER_HOST + TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE (see repo README).

- 2026-10-08: defect ICD_0001 (purged ticket still in ?email= list) fixed in v0.2.4 (deleted/spam poll, 2m on SIT) + v0.2.5/v0.2.6 one-off reconcile (`kubectl -n sit-freshdesk exec deploy/freshdesk-middleware-sync -- /middleware reconcile status`). Reconcile scan started 04:50 UTC, slow (~2 pages/min daytime); user wants a status check on the morning of 2026-10-09 (expect verify stage; report deleted count).

- 2026-10-09: user wants ONE summary report on the evening of 2026-10-09 covering: prod switch results (auth-api prod switched 2026-10-08 15:53 ICT; 09:00–10:53 tight minutes 76/63 → 6), reconcile done (22 purged tickets marked deleted), queue fix (v0.2.8), remaining 429s only at :11–:12 hourly + 00:11 burst from a consumer outside the middleware (DR auth-api ruled out). Details in the repo CLAUDE.md.

**Why:** context for future rollout/prod work. **How to apply:** check these before changing budgets, deploying, or running sync locally. Related: [[project-jvfs-registry-cleanup]]
