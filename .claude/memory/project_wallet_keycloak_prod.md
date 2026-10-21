---
name: project_wallet_keycloak_prod
description: "Keycloak deploy on HUAWEI-WALLET-PROD — external RDS, manual ArgoCD app, HTTP internal issuer"
metadata: 
  node_type: memory
  type: project
  originSessionId: 5e096667-a3c8-4e7d-bc50-a45e6355ca99
---

Keycloak deployed to HUAWEI-WALLET-PROD (2026-07-15), ns `keycloak`, chart `keycloak/` (wrapper around codecentric/keycloakx 7.1.11, app 26.5.6), 1 replica, `args: ["start"]` (auto-build).

**DB:** external Huawei RDS `prd-keycloak-db.dwl.internal` (10.27.30.14):5432, db `db-pg-keycloak`, dedicated role `keycloak_prod` (LOGIN, owns db so owns `public` via pg15 `pg_database_owner` — `ALTER SCHEMA public OWNER` errors "must be owner" but is unnecessary/harmless). RDS `root` is admin, not raw superuser. Access RDS from laptop via port-forward `localhost:15432`.

**Issuer:** `KC_HOSTNAME=https://keycloak.divinewallet.co.th` (tag keycloak-v0.1.1; was http://keycloak.dwl.internal at v0.1.0). Prod envoy-gateway has https:443 listener with cert secret `divinewallet-co-th-cert-secret` (ns wallet-prod, wildcard `*.divinewallet.co.th`). keycloak route uses per-route `sectionNames: [http, https]` (routes template supports per-route override; other .dwl.internal routes stay http-only). Split-horizon: divinewallet.co.th resolves to internal gateway ELB `10.27.90.100`. Actual public DNS A record managed outside this repo (owner TBD).

**GitOps:** repo `gitlab.dwl.internal/infrastructure/gitops/tools.git` (this is `infrastucture/tools`). Prod apps pin an immutable **git tag** (not `prod` branch), e.g. keycloak = tag `keycloak-v0.1.0`; kafka = `kafka-v0.1.19`. ArgoCD Application manifests are NOT stored in the gitops repo — applied manually to `argocd` ns. keycloak-prod app: project `infra`, dest `https://kubernetes.default.svc`, path `keycloak`, valueFiles `[values.yaml, values-prod.yaml]`, manual sync, syncOptions CreateNamespace/ServerSideApply/ApplyOutOfSyncOnly/Prune.

**Secrets (manual, pre-sync, never in git):** `keycloak-db` (key `password` = keycloak_prod pw), `keycloak-admin` (key `admin-password`). Store actual values in Vault.

**Route:** `keycloak.dwl.internal` HTTPRoute added to `routes/values-prod.yaml` backendRef `keycloak-keycloakx-http:80`, but goes live only when `tools-routes-prod` app tag is bumped + re-synced. See [[project_wallet_ktb_transaction_ingest]] for the manual-sync per-svc app pattern.
