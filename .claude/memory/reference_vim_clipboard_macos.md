---
name: vim-clipboard-macos
description: "On macOS, vim needs clipboard=unnamed (not unnamedplus alone) AND Homebrew vim; Apple's /usr/bin/vim has broken clipboard despite reporting +clipboard"
metadata: 
  node_type: memory
  type: reference
  originSessionId: 2dad2bd1-bdfa-4d5d-99eb-e4a461de3719
---

Two-part gotcha confirmed on this Mac (2026-05-14):

1. **Apple's `/usr/bin/vim` reports `+clipboard` but doesn't write to NSPasteboard.** Yanks silently fail to reach the system clipboard. Fix: `brew install vim` and ensure `/opt/homebrew/bin` precedes `/usr/bin` in `$PATH` (already true here).

2. **`set clipboard=unnamedplus` alone does nothing on macOS** — `unnamedplus` is X11's CLIPBOARD selection (Linux only). On macOS the system pasteboard is the `*` register, controlled by `unnamed`. Use `set clipboard=unnamed,unnamedplus` for cross-platform (works on macOS via `unnamed`, on Linux via `unnamedplus`).

Current `.vimrc` line 117–119 uses the combined form. CLAUDE.md's "Clipboard: unnamedplus" line is stale wording — actual setting is `unnamed,unnamedplus`.

**How to apply:** if user reports "can't copy from vim" on macOS, check (a) `which vim` is brew, not `/usr/bin/vim`; (b) `set clipboard?` returns a value containing `unnamed` (not just `unnamedplus`). Same dotfiles will be deployed to WSL2/Ubuntu where `unnamedplus` is the working option — that's why both are kept.

Related: [[user-terminal]], [[dotfiles]]
