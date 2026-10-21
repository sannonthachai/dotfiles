---
name: project-jvfs-sit-elk
description: jvfs-sit-elk ELK stack layout, access gotchas, and the latent-config-break failure mode
metadata:
  type: project
---

`jvfs-sit-elk` runs ELK 8.12.2 via docker compose at `/data/elk/docker-compose.yml` (containers `es`, `log`, `kib`). Logs from k8s filebeat land in `doe-%{+YYYY.MM.dd}` indices; syslog/minio goes to index `minio`.

Access gotchas:
- SSH user `ident-adm` is NOT in the `docker` group — every `docker` command needs sudo, and sudo needs a password (no NOPASSWD). ES/Logstash APIs on `localhost:9200` / `:9600` need no auth (`xpack.security.enabled: false`), so diagnose through curl first.
- `journalctl` is unreadable as `ident-adm` (not in `adm`/`systemd-journal`).

Failure mode seen 2026-08-20: logstash `command` is `-f /usr/share/logstash/modify`, a **directory** — Logstash concatenates every file in it, including `*_bak` and vim `.swp` leftovers. `input.conf` had been syntactically broken since Oct 2025 but stayed latent for 10 months because the container was never recreated. A `docker compose up -d` (unrelated edit adding json-file log rotation) recreated `log`, the parse error surfaced, and `restart: always` crash-looped it every ~40s with zero ingestion. Port 5044 still shows LISTEN via docker-proxy even while logstash is dead — check `curl localhost:9600` instead.

**Always run a config test before restarting logstash there**, and keep backups outside the pipeline dir (`/data/elk/logstash/_disabled/`).

Field `ts` is a mapping minefield: Go zap containers emit float epoch seconds (`1786433960.085`), etcd emits ISO strings. Fixed with index template `doe-ts` on `doe-*` mapping `ts` as date with `strict_date_optional_time||epoch_millis||epoch_second` + `ignore_malformed: true`. Note ES 8.12 will NOT let you update `format` on an existing date field — only `ignore_malformed` — so pre-existing indices need reindex or just the `ignore_malformed` flag.

See [[project-jvfs-gitlab-runner-disk]] for the other JVFS host maintenance notes.

**`logstash -t` does NOT compile `ruby` filter code.** A `ruby { code => ... }` block with broken syntax passes `bin/logstash -t -f <dir>` with "Configuration OK", then fails at pipeline register on real startup (`error in register ... SyntaxError`) and crash-loops. To actually validate, run the pipeline for real in a throwaway container on the compose network: `docker run --rm --network elk_monitor -v /tmp/lstest:/cfg logstash:8.12.2 bin/logstash -f /cfg` and grep for `Pipelines running` vs `error in register`.

Related trap: write the ruby `code` with SINGLE quotes in the logstash config and transfer the file via base64 (`base64 -i f | ssh host 'base64 -d > f'`). Building it with a shell heredoc through ssh leaks `\"` backslashes into the ruby body, which is exactly what produced the SyntaxError above.

Also: sudo credential caching over non-interactive ssh is unreliable there — pipe the password straight into the command that needs it (`printf '%s\n' PASS | ssh host 'read -r P; printf "%s\n" "$P" | sudo -S <cmd>'`) rather than doing `sudo -v` first and relying on the cache.
