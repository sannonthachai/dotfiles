---
name: feedback-ssh-controller-info-trigger
description: "In ssh-controller, \"check information.md\" means run the full new-host bootstrap into ./config"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 2fd59554-256c-4eb2-8192-432a2afd574b
---

In the `ssh-controller` project, when the user says "check information.md" (or similar — "look at information.md", "info in information.md"), treat it as a trigger to run the full new-host bootstrap automation documented in that project's CLAUDE.md: diff information.md against ./config, find the host(s) missing from ./config, append the Host block(s) using the site's identity file, verify password auth with sshpass, ssh-copy-id, and verify key-only login.

**Why:** User stated this directly on 2026-05-19 after a Dr2 host bootstrap. They use information.md as the input queue for hosts that need to be added to ./config — pointing at the file IS the request to add it.

**How to apply:** Don't ask "which host?" or "what details?" when the user references information.md in this repo. Read information.md and ./config, compute the diff, and proceed with the bootstrap flow in [[project CLAUDE.md]]. Still confirm before destructive ops, but adding a new Host block and running ssh-copy-id are pre-authorized by this workflow.
