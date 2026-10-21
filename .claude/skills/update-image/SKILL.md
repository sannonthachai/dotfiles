---
name: update-image
description: Sync DOE deploy-request emails into the [DOE] Inventory sheet and bring migrate-docker-image/main.go up to the latest PROD image versions. Use when the user says "update image", "sync deploy emails", "fill the deploy sheet", "update projects variable", "latest prod version", or asks to record deploys / refresh the DR migration list.
---

# update-image

Three chained jobs. The user may ask for one, some, or all — confirm which before starting
if the request is vague.

1. **Read** deploy-request emails from the mailbox
2. **Fill** the `[DOE] Inventory` sheet with the new deploys
3. **Rebuild** the `projects` map in `migrate-docker-image/main.go` at latest PROD

Full reference, including every gotcha, lives in
`~/workspaces/jvfs/etc/update-image/CLAUDE.md`. **Read it first** — it is short and it
records failure modes that cost real time.

## Paths

| Thing | Path |
|---|---|
| Scripts + reference doc | `~/workspaces/jvfs/etc/update-image/` |
| Graph credentials | `~/workspaces/jvfs/etc/update-image/.env` |
| `projects` map | `~/workspaces/jvfs/etc/migrate-docker-image/main.go` |
| Path catalogue | `~/workspaces/jvfs/etc/migrate-docker-image/images.template.txt` |

Sheet `1JQtfbe-1QkOqpHt5AeJrpXDIDwjEd_wCDOOs9J4jm9I`, tab `UAT/PRD - Deploy`, gid `1178251234`.

## Scripts — use these, do not rewrite them

```sh
cd ~/workspaces/jvfs/etc/update-image
./fetch_emails.py --since <sheet's last date, YYYY-MM-DD> --out emails.json
./build_rows.py --in emails.json --out rows.tsv --copy --after '<sheet last datetime>'
./update_map.py --in emails.json --after '<sheet last datetime>'          # dry run, always
./update_map.py --in emails.json --after '<sheet last datetime>' --apply
```

## Checklist

- [ ] Read `update-image/CLAUDE.md`
- [ ] Find the sheet's real last dated row — live grid, **not** gviz (gviz nulls text dates)
- [ ] Pull deploy emails after that date via Graph app-only auth (the M365 connector
      cannot reach this mailbox)
- [ ] Parse each email's HTML table; skip `Re:` approvals
- [ ] Classify UAT vs PROD per the rules in the doc — version tags do not settle it
- [ ] Build TSV, show the user a summary and row count, **get confirmation before writing**
- [ ] `pbcopy` the TSV, click the target cell in Chrome, `Cmd+V`, verify the last row
- [ ] Rebuild the map with `update_map.py` — default **replace** mode wipes it and writes
      only this round's PROD deploys, so it reads as the migration worklist
- [ ] Resolve any new service's registry prefix from `images.template.txt`; ask if absent
- [ ] `gofmt -w main.go && go build ./...`

## Rules

- **PROD only** for the map. The DR registry mirrors production. A `-uat-N` tag on a PROD
  deploy is normal and still counts; a UAT-only deploy never does.
- **Confirm before writing to the sheet.** It is shared and others are in it.
- **One `projects` variable.** Do not leave commented-out historical blocks behind; git
  holds the history.
- **Replace, do not accumulate.** The map is this round's worklist. Services that did not
  move are dropped — `images.template.txt` remains the full catalogue of paths, so keep it
  current. `--mode merge` restores the old full-inventory behaviour on request.
- **Never guess a registry path.** Match `images.template.txt`, or ask.
- Preserve the existing misspelled keys (`mange-data`); match loosely, write the old key.
- Report counts at each step: rows written, services bumped, services skipped and why.

## Asking the user

Worth a question, because the answers change the output:

- Include rows where From == To? (default: skip)
- Add services that were deployed but are absent from the map? (default: ask, listing them)
- Registry prefix for a service that is in neither the map nor the template
