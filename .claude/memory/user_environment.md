---
name: user-environment
description: "Current dev machine is a MacBook (Apple Silicon, macOS) — replaces the prior WSL2-on-Windows setup. Shell, brew, and tool paths follow macOS conventions."
metadata: 
  node_type: memory
  type: user
  originSessionId: 2dad2bd1-bdfa-4d5d-99eb-e4a461de3719
---

**Current machine (as of 2026-05-14): MacBook on Apple Silicon (arm64), macOS.** Replaces the prior WSL2 / Ubuntu / Windows setup that older memories and the global CLAUDE.md still describe.

What this changes:
- **Homebrew prefix is `/opt/homebrew`** (Apple Silicon), not `/usr/local`. Tools live under `/opt/homebrew/bin`.
- **Use `brew`** as the primary package manager, not `apt`. Dotfiles `install.sh` now bootstraps brew + runs `brew bundle` against the repo's `Brewfile`.
- **Vim must be Homebrew vim** — Apple's `/usr/bin/vim` reports `+clipboard` but doesn't write to NSPasteboard. See [[vim-clipboard-macos]].
- **Shell is still zsh + oh-my-zsh + powerlevel10k**, but launched directly by Terminal/WezTerm (no WSL hop).
- **Clipboard:** `pbcopy` / `pbpaste` (not `xclip` / `wl-copy`).
- **SSH config** has aliases for two gitlab.com accounts (`gitlab-ea`, `gitlab-jvfs`), one self-hosted GitLab (`gitlab-jvfs-dr2` at 192.168.102.62:2424), and one VM (`jvfs-sit-skywalking`). Keys at `~/.ssh/id_ed25519_*`.

**How to apply:** when suggesting installs, default to `brew install` rather than `apt`. When pointing at config paths, use `/opt/homebrew/...` rather than `/usr/local/...`. The dotfiles repo itself is cross-platform — the `install.sh` flags handle macOS vs Linux — but user-facing commands should assume macOS now.

(Stale Windows/WSL2 references in `.claude/CLAUDE.md` and `[[user-terminal]]` were cleaned up on 2026-05-14.)

Related: [[vim-clipboard-macos]], [[dotfiles]]
