---
name: project-jvfs-sp-archive-migration
description: "JVFS doc-control — bulk-copied the manual pre-app SharePoint archive (FTS-DCC-NEW site) into the app's JVFS-Documents library, remapped to YYYY/MM"
metadata: 
  node_type: memory
  type: project
  originSessionId: 7f63a30c-deda-402e-b4f5-f1e9edf99765
---

JVFS Document Control (`~/workspaces/jvfs/etc/document-control`). On 2026-06-16 migrated the manual pre-app document archive from a **separate** SharePoint site `FTS-DCC-NEW` into the app's `JVFS-Documents` library.

- **Source:** site `FTS-DCC-NEW` (drive `b!koo11Tm1l0GbDc8EoSfE0UuX7z3kNiFPr7ENemYdHIbSsr1UVrhiQ6oXwz2idMvN`), path `1.JVFS_ทะเบียนหนังสือเข้า-ออก/FTS-เอกสารเข้า-ออก (ปี <BE>)`, organised as Thai-month folders → doc-type subfolders (AN/DOC/LT/POA).
- **Tool:** `nuxt-app/scripts/copy-2568-to-jvfs-documents.py` (gitignored), `--be <BEyear>` + `--apply`. Server-side cross-drive Graph `copy` (no download), flattens doc-type subfolders into `JVFS-Documents/<CE>/<MM>/` (CE = BE−543), idempotent, skips non-month folders.
- **Done:** 2566→2023 (17 files), 2567→2024 (605), 2568→2025 (1105) ≈ 1.7k files / ~19 GB. Sources untouched (copy not move).
- ⚠️ Reachable because the SP app-only creds are **tenant-wide** (`Sites.ReadWrite.All`), so they reach ANY site in the `jvfuturesky` tenant, not just the app's configured one.
- ⚠️ Copied files are **NOT yet linked to register DB rows** (no `attachment_key`). Linking would be a follow-up via `nuxt-app/scripts/link-sharepoint-files.mjs` (parses doc_no from filename → fills attachment_key). The link backfill was applied 2026-06-16 → 273 rows linked, but that ran before this archive copy.

Full operational detail is in the project's `CLAUDE.md` (Files / SharePoint section).
