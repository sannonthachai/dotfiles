---
name: project-ea-gitops-rbac
description: "EA gitops repo RBAC accounts — layout, ea-prd-rke2 namespace reality, and how to sync when the argocd CLI points elsewhere"
metadata: 
  node_type: memory
  type: project
  originSessionId: 0ebc05c9-4380-47c5-904d-575953fc8b83
  modified: 2026-08-14T05:08:32.515Z
---

EA gitops repo (`gitlab.energyabsolute.co.th/infrastructure/gitops`) holds cluster RBAC accounts under `kustomize/infra/rbac/<role>/`, deployed by manual-sync ArgoCD Applications in `argocd/`. First one: `tech-lead` read-only account, deployed 2026-08-14.

**ea-prd-rke2 namespace reality (2026-08-14):** the only application namespaces that exist are `ea-prod` and `power-support-prod`. The repo's manifests also reference `hr-master-prod`, `power-prod` and `datastore` — those were never deployed to this cluster, and RoleBindings targeting them fail the sync. Always `kubectl get ns` before writing namespaced RBAC from repo greps. No PostgreSQL runs here.

**Syncing when `argocd` CLI is logged into the wrong instance** (it points at `argocd-dev.dwl.internal`, the wallet cluster — see [[project-wallet-gitlab-pipeline]]): trigger a manual sync through the API server instead:

```sh
kubectl patch app <name> -n argocd --type merge \
  -p '{"operation":{"initiatedBy":{"username":"<user>"},"sync":{"revision":"main","syncStrategy":{"apply":{}}}}}'
```

**RBAC gotchas hit here:** RBAC has no deny, so "everything except secrets" must be enumerated — bind built-in `view` for namespaced resources (it already omits secrets and tracks upstream) plus an explicit ClusterRole for cluster-scoped kinds and CRD groups. `snapshot.storage.k8s.io` is a separate API group from `storage.k8s.io`. Namespace-scoped secret grants mean k9s/kubectl in all-namespaces mode is denied outright; set a default namespace on the context.

k8s 1.24+ mints no SA token Secret automatically — create a `kubernetes.io/service-account-token` Secret for a non-expiring token, and add `ignoreDifferences` on `/data` or every ArgoCD sync reports OutOfSync and wipes it.
