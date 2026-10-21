---
name: project_jvfs_dr_argocd_outofsync
description: JVFS DR cluster ArgoCD OutOfSync causes — Prune=False orphan hashed ConfigMaps + misplaced YAML fields; known crashloops
metadata:
  node_type: memory
  type: project
  originSessionId: 7417b3cb-fac4-48e0-9421-a6caef16b244
  modified: 2026-09-23T04:17:14.242Z
---

kube context `devops@jvfs-dr-cluster`; ArgoCD apps in ns `argocd` (read via kubectl, NOT argocd CLI — CLI points at wallet dev). Repo ~/workspaces/jvfs/core/gitops-prod; DR apps use overlays/dr/*, UAT apps overlays/uat/*; overlays/prod/* not deployed here.

Recurring OutOfSync causes (fixed 2026-09-23, commit b756402e):
1. Misplaced fields (container-level `requests:`, probes under `ports[0]`) — API drops them, so the app never syncs. Detect with a strict server dry-run: `kubectl apply --dry-run=server --validate=strict -f <(kubectl kustomize overlay)`.
2. All apps `Prune=False` → old `configMapGenerator` hashed CMs stay behind with requiresPruning. Safe to delete if only replicas=0 RS reference them.

Auto-mode classifier blocks `kubectl delete` / server dry-run / exec on prod → the user runs them via `!` prefix.

Known non-git crashloops (as of 2026-09-23): prod-eolo/doe-booking-backend (DR DB read-only, INSERT at startup), prod-iden/mol-verifiable-credential (192.168.114.31:8545 refused), iden-uat/doe-insurance-gateway (SFTP 159.138.244.222:2324 timeout).

Related: [[project_jvfs_registry_cleanup]]
