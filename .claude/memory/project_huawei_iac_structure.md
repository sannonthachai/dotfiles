---
name: project-huawei-iac-structure
description: huawei-iac repo layout (5 accounts) + monitoring private DNS records are Terraform-managed in accounts/sec
metadata: 
  node_type: memory
  type: project
  originSessionId: 2f5f106b-3736-4fec-a00a-acbc48947f47
---

`huawei-iac` (`~/workspaces/wallet/huawei-iac`) is the Terraform IaC repo for Huawei Cloud, split across **5 isolated accounts** (`adm`, `dev`, `prod`, `sec`, `shared`) — each its own tenant with its own AK/SK and OBS-backed remote state. Run terraform from `accounts/<name>/` (not repo root): `terraform init -backend-config=backend.hcl` then plan/apply. Shared logic in `modules/` (dns, ecs, rds, iam-user, swr). Account roles: `adm`=bastion, `dev`/`prod`=PG17 RDS, `sec`=SFTP ECS + DNS records, `shared`=SonarQube/Druid/GitLab ECS + SWR.

**Key fact for the wallet-monitoring migration ([[project-huawei-iac-obs-vpn]] for the OBS/VPN gotchas):** the monitoring private DNS A-records — `argocd-monitoring`, `loki-monitoring`, `tempo-monitoring`, `prom-dev-monitoring` (all → `10.23.13.100`, zone `dwl.internal.`) — are **managed in `accounts/sec/terraform.tfvars`** via the `dns_records` map (data-source + `huaweicloud_dns_recordset` into the existing zone, not a new module). To add/change a monitoring hostname, edit that map and `terraform apply` — do NOT hand-create in the Huawei console.

**Why:** non-obvious — the records look console-created (Grafana migration uses them for Path B Traefik exposure) but are actually IaC. **How to apply:** when the monitoring work needs a new `*.dwl.internal` record (e.g. `grafana-monitoring`, `prom-prod-monitoring`), add it to the `sec` `dns_records` map. ⚠️ Huawei **security group** rules are NOT in this Terraform — those are still edited by hand in the console.
