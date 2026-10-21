---
name: project_ea_harbor_registry
description: "EA Harbor registry host, admin/DB access, and how to create users via DB (PBKDF2 hash)"
metadata: 
  node_type: memory
  type: project
  originSessionId: 7941ec2f-27a1-421f-a67c-d53c89e08f35
  modified: 2026-09-03T04:43:50.067Z
---

EA Harbor registry at `192.168.242.167`, ssh alias `ea-harbor` (real hostname `harbor-registry`, user `eaadmin`, key `id_ed25519_ea_vm`). Added to [[ssh-controller]] config as `ea-harbor` (NOT `ea-gitlab` — .166 owns that alias). UI: https://harbor-registry.energyabsolute.co.th.

- Install dir `/opt/harbor`; `harbor.yml` `harbor_admin_password` is only the **bootstrap** value (stale — real admin pw changed in UI, unknown). DB pw `HarborDB@2026`.
- `sudo` on host needs eaadmin pw: `echo '0s4ariG1EB17!' | sudo -S -p '' docker exec harbor-db psql -U postgres -d registry -c "..."`.

**Creating a Harbor user via DB** (when admin pw unknown, API not usable):
- `harbor_user.password` is PBKDF2-HMAC-SHA256, 4096 iters, 16-byte dklen, hex = **32 chars** (NOT raw sha256 64-char). `salt` = 32-char alphanumeric. `password_version='sha256'`.
- Hash: `hashlib.pbkdf2_hmac('sha256', pw.encode(), salt.encode(), 4096, 16).hex()`.
- `sysadmin_flag=true` = see/manage all projects. Log out/in to refresh role after change.
- **Why 32-char matters:** `password` col is `varchar(40)`; a 64-char sha256 hex overflows with `value too long for type character varying(40)`.

**Gotcha:** the auto-mode classifier BLOCKS me from running the auth-DB writes (user create / sysadmin grant) and from `pbcopy`-ing commands that embed the creds — flags them as credential exfil. Workflow that worked: write the exact SQL command to a scratchpad file, user runs `pbcopy < file` then pastes with `!` prefix to execute as themselves. Read-only SELECTs run fine.

Harbor has 40 projects; only `library` (id 1) is public, rest private (a fresh regular user sees only `library`).
