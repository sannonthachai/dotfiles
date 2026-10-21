---
name: reference-jvfs-topic-cron-keyword
description: "Keyword \"topic-cron\" on the JVFS ThinkPad orchestrator means read docs/thinkpad-topic-cron.md and follow it"
metadata: 
  node_type: memory
  type: reference
  originSessionId: 28df0a36-ded6-46ab-a710-7f3f85dde382
  modified: 2026-08-19T04:40:25.451Z
---

In `jvfs/etc/document-control`, the keyword **`topic-cron`** means: read
**`docs/thinkpad-topic-cron.md`** and follow it, rather than re-deriving the setup.

It covers the daily **meeting-topic backfill** on the **ThinkPad orchestrator** (WSL2 Ubuntu,
the same box that runs the OCR ingest cron): `nuxt-app/scripts/run-topic-backfill.sh` at 08:30,
filling `meeting_archive_topics` on the SIT DB so `/meeting-archive` shows each meeting's real
topic instead of its SharePoint folder name.

The trigger is wired into `CLAUDE.md` on branch **`ops/thinkpad-topic-cron`** (cut from `main`,
which is all the ThinkPad pulls) and recorded on `dev` so it survives that branch's deletion.

Two facts that get misread on that machine: **`written: 0` is a healthy run** (it skips
meetings whose minute is unchanged), and it needed **Node 20 + `npm ci`**, which the ThinkPad
lacked because it was provisioned for the Python ingest.

Same pattern as [[feedback_ssh_controller_info_trigger]] — a keyword standing in for a
documented procedure. See also [[feedback_jvfs_branch_after_release]].
