---
name: project_jvfs_m5_ocr_shared_config
description: "JVFS — the Mac M5 OCR/ollama config is SHARED + fine-tuned by another team; don't change it unilaterally. Plus the flash-attn-off↔OOM tradeoff finding."
metadata: 
  node_type: memory
  type: feedback
  originSessionId: ef6bb45b-f61c-42d0-a1ee-3e9064da50bf
---

The Mac M5 (`10.30.13.139`, EA net; `ssh it@…` / `m5-home`) running the JVFS Typhoon-OCR + BGE stack is **shared with another team, who have fine-tuned its config** (the `com.ea.ollama` launchd plist: `OLLAMA_CONTEXT_LENGTH=8192`, num_ctx, etc.). **Do NOT change shared M5 config (the ollama plist, proxy settings) unilaterally** — only adjust JVFS's *own* knobs (e.g. `OCR_IMG_DIM` in `ingest-sharepoint-ocr.py`), and coordinate with the other team before touching anything shared.

**Why:** 2026-06-19 I applied CLAUDE.md's documented OCR-wedge fix (`OLLAMA_FLASH_ATTENTION=0` in the plist + bootout/bootstrap) before the user reminded me the other team had fine-tuned that config. The change was reverted in full (backup `.bak.20260619`, since removed; plist back to flash-attn `auto`).

**How to apply:** If a fix lives in shared M5 config, propose it and get the other team's sign-off first; don't edit/restart their services off your own initiative. If you already did, revert from the timestamped backup and restore original behavior (verify the runner spawns with `--flash-attn auto` again).

**Technical finding (verified, contradicts CLAUDE.md's guess):** On this 24GB M5 the wedge and an OOM are two horns of one dilemma —
- `OLLAMA_FLASH_ATTENTION=0` **IS effective in ollama 0.30.8** (NOT a no-op as CLAUDE.md feared): runner launches `--flash-attn off` → `flash_attn = disabled`. Eliminates the vision wedge (verified 15/15 sustained image reqs, no hang).
- BUT with flash-attn OFF the non-flash ViT self-attention materializes a full O(n²) buffer (~15.8 GiB) → **OOM segfault at img_dim 2200** (3.42 Mpx). Works only up to ~1792 long edge (2.27 Mpx).
- So flash-attn-off alone breaks production OCR at `img_dim 2200`; it'd need `img_dim ≤ ~1800` too — which the user declined (keep 2200). Real fix likely = ollama upgrade past 0.30.8 (do WITH the other team), or accept the wedge + the vision-aware watchdog. See CLAUDE.md "OCR model wedges" block.

Related: [[project_jvfs_sp_archive_migration]]
