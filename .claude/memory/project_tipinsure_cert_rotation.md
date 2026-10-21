---
name: project-tipinsure-cert-rotation
description: Dhipaya *.tipinsure.com cert swap 2026-09-17 22:00 ICT; verify insurance-hospital-gateway after
metadata:
  type: project
---

**DONE — verified 2026-09-17 ~22:56 ICT. Swap succeeded, nothing needed on our side.** Full chain (4 certs)
served, new leaf matches the delivered files, `ssl_verify=0` from throwaway pods and from inside the real
gateway pods in both SIT and PROD. Next rotation due **before 2027-03-21**. Runbook with the reusable
checklist: `~/workspaces/jvfs/etc/update-cert-insurance/CLAUDE.md` — read it first.

Key points that are not obvious from the code:

- The JVFS consumer is `insurance-hospital-gateway` (`~/workspaces/jvfs/iden/blockfint/`), via
  `src/service/context.go:240 urlToObjectName()`. The tipinsure URL arrives as **caller-supplied request
  data** (`ins_doc` / `alien_check_doc`), so grepping the repo for "tipinsure" finds nothing. A grep miss
  does not mean the service is unrelated — this misled me once.
- Decision made: **do not** bundle the new cert into that image. It chains to public GlobalSign roots
  (Root R46 / Root R3), both already verified PRESENT in the running SIT and PROD pods. The hospital `.crt`
  files in that repo are a different case (chains the base store can't build).
- Residual risk is a short chain — Go does not do AIA chasing.

Environment: `apitkr.tipinsure.com` is unreachable from the MacBook (on and off VPN); test from inside a
cluster. `kubectl exec` into `sit-iden`/`prod-iden` is blocked by the auto-mode classifier — hand the user
the command to run with the `!` prefix.

See [[project_jvfs_sit_elk]] and [[feedback_symlink_safety]] for other JVFS-side gotchas.
