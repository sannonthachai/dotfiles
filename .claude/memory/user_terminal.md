---
name: terminal-emulator
description: "User runs WezTerm on macOS (MacBook, Apple Silicon) as their daily terminal — moved off Windows/WSL2"
metadata: 
  node_type: memory
  type: user
  originSessionId: 2dad2bd1-bdfa-4d5d-99eb-e4a461de3719
---

User's daily terminal is **WezTerm on macOS** (MacBook, Apple Silicon).

History: Alacritty (Windows/WSL2) → Windows Terminal → WezTerm (switched 2026-04-29) → migrated to macOS (2026-05-14).

Config lives in the dotfiles repo at `~/sannonthachai/dotfiles/.config/wezterm/wezterm.lua`. macOS-native — no WSL hop. Setup: gruvbox dark, JetBrainsMono Nerd Font 11pt (ligatures on), `Cmd-C/V` copy/paste, `Cmd +/-/0` font size, 10k scrollback. Tab bar hidden when single tab — tmux still handles multiplexing.

When suggesting terminal tips, assume WezTerm conventions (Lua config, built-in tabs/splits available but unused in favor of tmux) and macOS keybindings (Cmd, not Ctrl-Shift).

Related: [[user-environment]]
