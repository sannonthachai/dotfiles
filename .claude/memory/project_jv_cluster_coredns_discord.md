---
name: project_jv_cluster_coredns_discord
description: jv-cluster (JVFS PROD rke2) Discord DNS bypass — internal DNS 192.168.11.1 sinkholes discord to 127.0.0.1; CoreDNS forwards discord zones to 8.8.8.8/1.1.1.1
metadata:
  node_type: memory
  type: project
  originSessionId: 92769c78-1a89-4857-b7b8-71b54b3a2611
  modified: 2026-10-20T07:32:36.079Z
---

Internal DNS `192.168.11.1` resolves discord.com/discordapp.com/discord.gg to `127.0.0.1` (sinkhole). Pods in JVFS clusters fail to reach Discord unless CoreDNS has a separate server block forwarding those zones to `8.8.8.8 1.1.1.1`.

- **jvfs-sit-cluster**: block added ~2026-10-12 via live `kubectl apply` of HelmChartConfig `rke2-coredns` (not file-backed).
- **jv-cluster (PROD)**: block added 2026-10-20 by editing `/var/lib/rancher/rke2/server/manifests/rke2-coredns-config.yaml` on **node 1 only** (jvfs-prod-k8s-1, 192.168.14.11). Nodes 2/3 never had that file — don't add it. Backup of old file: `/root/rke2-coredns-config.yaml.bak-20261020` on node 1. HelmChartConfig there is owned by Addon `rke2-coredns-config`, so kubectl edits get reverted — edit the file.

**Why:** jv-cluster services couldn't send to Discord while SIT could.

**How to apply:** If Discord breaks again or on new JVFS clusters, check `nslookup discord.com` in a pod for 127.0.0.1 first. SSH aliases `jvfs-prod-k8s-1..5` (ssh-controller config); 1-3 servers, 4-5 workers. Prod SSH is blocked by the auto-mode classifier and sudo needs a password plus a TTY, so the user runs node commands in a real terminal (not `!`). Keep commands short — long one-liners wrap when pasted and break. Discord bypass skips the corporate sinkhole; may need network/security sign-off.
