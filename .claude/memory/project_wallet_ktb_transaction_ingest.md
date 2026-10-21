---
name: project-wallet-ktb-transaction-ingest
description: Wallet ktb-transaction-ingest CronJob (SFTP->OBS rclone) prod setup + SG gotcha
metadata: 
  node_type: memory
  type: project
  originSessionId: c9eab40f-1f70-40dc-8862-34ce975b4f5f
---

Wallet kustomize repo (gitlab.dwl.internal/infrastructure/gitops/kustomize): `ktb-transaction-ingest` CronJob copies KTB transaction files SFTP -> Huawei OBS via `rclone/rclone:1.69` (`rclone copy` with `--s3-no-check-bucket --ignore-checksum` for OBS quirks). Daily `0 2 * * *` Asia/Bangkok.

Layout: `base/ktb-transaction-ingest/` + `overlays/{dev,prod}/ktb-transaction-ingest/`. Base hardcodes DEV OBS secret name, so prod overlay `cronjob.yaml` patch must override `RCLONE_CONFIG_OBS_*` `secretKeyRef.name` to prod secret. Secrets via Vault (VaultStaticSecret, mount = namespace `wallet-dev`/`wallet-prod`): `sftp` -> `sftp-secret`, `obs-wallet-<env>-ktb-transaction` -> `...-secret`.

Prod (added 2026-07-15): SFTP `/home/ktbpayment/ktb/prod` (host 10.25.10.30) -> OBS bucket `wallet-prod-ktb-transaction` prefix `ktb/prod`.

Deploy = 1 ArgoCD Application per service named `<svc>-prod` in `argocd` ns on context HUAWEI-WALLET-PROD; NO app-of-apps and NO `automated` syncPolicy (manual/hook sync — trigger via `kubectl patch application ... operation`). App manifest lives outside the kustomize repo; mirror `s3-api-service-prod` (project default, repo kustomize.git@main, syncOptions CreateNamespace/ServerSideApply/ApplyOutOfSyncOnly).

**Why/gotcha:** SFTP egress needs SG rules on BOTH sides — CCE node **outbound** to SFTP host AND SFTP host **inbound** from CCE. Missing either = pod hangs in Running on rclone SFTP dial until activeDeadline. See [[project-huawei-iac-obs-vpn]] for OBS checksum/bucket quirks.
