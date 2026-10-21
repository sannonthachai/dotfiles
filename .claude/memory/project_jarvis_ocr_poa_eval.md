---
name: project-jarvis-ocr-poa-eval
description: Evaluating jarvis OCR API accuracy on Thai POA (หนังสือมอบอำนาจ) docs; baseline results + method from 2026-09-25
metadata:
  node_type: memory
  type: project
  originSessionId: b5c0f655-2e60-4de8-8948-e19d38dd92eb
  modified: 2026-09-25T10:46:55.287Z
---

Direction 2026-09-30: EA k8s/Spark/ocr-service dropped; dedicated RTX 3090 server hosts the OCR API; middleware + Postgres/MinIO all at JVFS (jv-cluster / jvfs-sit-cluster). Now designing the middleware (brainstorming → spec).

Context (2026-09-28): building OCR/doc-validation for WAMS to replace vendor Ztrus; work lives in ~/workspaces/jvfs/etc/wams-ocr (CLAUDE.md, docs/wams-ocr-spec.md, eval scripts + ground truth moved there from scratchpad).

Jarvis OCR API: POST https://jarvis.energyabsolute.co.th/admin/api/ocr (-F file=@...), poll GET /admin/api/ocr/<job_id> (`?text=1` = merged text). Model gemma-4-26B-A4B-it-FP8. Response JSON has raw control chars → `json.loads(..., strict=False)`. Key belongs to user ("WAMS OCR TESTING (JVFS)") — ask for it, never store it.

Baseline 2026-09-25, file JVFSO6909035-POA (41 pages, 860s): ID cards 12.5% field accuracy, 0/6 ID numbers fully correct; other pages ≈28% key fields (headers/doc no/dates 87%, names 19%, reg/ID numbers 0%, addresses 0%). 5 pages looped, 13 truncated. Model hallucinates plausible names/addresses and self-masks numbers ("0XXXXXXXXXX91").

Round 2 (2026-09-25, 4 files JVFS6807004/67090001/6801001/6905028, 78 pages, 396 fields): exact 33% (near 57%). docno 76%, date 72%, amount 92%, name/address/company 22%, ID numbers 0/69 (26 self-masked as "3 XXXX XXXXX X0 1", 6 wrong+fail checksum, 37 missing/garbled), handwritten 9% (A p1 fabricated whole companies/addresses). Same JV-contract page in 3 files → 3 different company names + juristic no. dropped a digit = non-deterministic. 19 truncated, 5 looped. 300dpi crops: non-ID 35%→55%. Scripts/truth now in wams-ocr/eval/.

Round 3 (DBD หนังสือรับรอง, 2 clean e-certs, 11 pages): fields 59% exact; p1 key facts: names 1/7, company 0/2, address 0/2, juristic no. 0/2 (masked), dates/amounts/counts ~100%. Objectives list char-recall only 59–64% even on clean digital pages (paraphrase/skip items); 2/4 pages of scanned objectives looped. Server prompt LEAKED in output (CERT2 p3): "Transcribe ALL text… Preserve EVERY digit exactly… Never guess" — no masking instruction, so ID masking is model behavior, not prompt.

Method: view PDF pages with Read (pages param, one page per call works reliably) as ground truth, score key fields per page; validate Thai ID/tax numbers with mod-11 checksum.

**Why:** user plans to OCR 3–5 more sample POA files to measure accuracy and find improvement points.
**How to apply:** reuse same scoring categories so results are comparable. OCR config is shared by another team; recommend changes, don't apply them unilaterally ([[project_jvfs_m5_ocr_shared_config]]).
