---
name: project-huawei-iac-obs-vpn
description: huawei-iac repo — OBS/VPN access dead-ends + OBS backend write fix (checksum env vars)
metadata: 
  node_type: memory
  type: project
  originSessionId: b51e77f1-542b-4f3e-903a-c9176c66fdec
---

In the `huawei-iac` repo (`~/workspaces/wallet/huawei-iac`), region `ap-southeast-2` (Bangkok "landing zone" — OBS resolves to `obs.lz01/lz003.*`):

- **`terraform apply`/destroy/state-push need checksum env vars or state save fails** with `XAmzContentSHA256Mismatch: PutObject`. OBS is S3-compatible and rejects the AWS SDK's default integrity checksums. Fix: `export AWS_REQUEST_CHECKSUM_CALCULATION=when_required` and `AWS_RESPONSE_CHECKSUM_VALIDATION=when_required`. Reads (plan/refresh) work without them; only writes break. Affects all five accounts (`adm`, `dev`, `prod`, `sec`, `shared` — see [[project-huawei-iac-structure]]). On partial failure, state lands in `errored.tfstate` — recover via `terraform state push errored.tfstate` with the env vars set.

- **Run Terraform OFF-VPN.** On VPN, corporate DNS (`10.25.200.2/3`) resolves `*.myhuaweicloud.com` to internal `100.125.x.x` with no route → timeout. Off-VPN resolves to public IPs that are reachable.

- **Two ruled-out dead-ends for "VPN clients reach OBS privately" — do NOT retry:**
  1. No OBS VPC endpoint service in this region (0 gateway-type services in the catalog), so VPCEP-for-OBS is impossible.
  2. Private NAT Gateway + SNAT also impossible: OBS `100.125.0.0/16` is inside Huawei's reserved `100.64.0.0/10`; the VPC route table rejects any overlapping custom route (`VPC.2817 DestinationOverlapCidr`), so traffic never reaches the NAT gateway. Tried it 2026-05-29: gateway+transit IP created, SNAT rule + route failed, all cleaned up. There is no in-VPC private path; VPN users must use the public OBS endpoint.

- vpc-sec (`b349522e-…`) subnets: subnet-dmz `10.25.10.0/24`, subnet-vpn `10.25.200.0/24` (P2C VPN gateway `p2c-vpn-sec`, client CIDR `10.28.0.0/24`), subnet-reserve `10.25.11.0/24`, subnet-security `10.25.12.0/24`.

**Why:** non-obvious, region-specific Huawei behavior, learned by trial. **How to apply:** for this repo, set the checksum env vars before apply, run off-VPN, and don't propose VPCEP or NAT for OBS-over-VPN here.
