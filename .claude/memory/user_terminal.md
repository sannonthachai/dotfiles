---
name: Terminal emulator
description: User uses WezTerm as their daily terminal on Windows/WSL2 (switched from Alacritty → Windows Terminal → WezTerm)
type: user
originSessionId: 9dc6070d-c368-45a3-a0a2-fc5274b36149
---
User now uses **WezTerm** as their terminal emulator on Windows, launching into WSL2 Ubuntu zsh.

History: Alacritty → Windows Terminal → WezTerm (switched 2026-04-29).

Config lives in the dotfiles repo at `~/sannonthachai/dotfiles/.config/wezterm/wezterm.lua`. On Windows, `%USERPROFILE%\.wezterm.lua` is a stub that `dofile`s the WSL path via `\\wsl.localhost\Ubuntu\...`.

Setup matches prior Alacritty config: gruvbox dark, JetBrainsMono Nerd Font 11pt (ligatures on), `Ctrl-Shift-C/V` copy/paste, `Ctrl +/-/0` font size, 10k scrollback, launches `wsl.exe --cd ~`. Tab bar hidden when single tab — tmux still handles multiplexing.

Stale references to update when next editing:
- `~/.claude/CLAUDE.md` "## Terminal" section still describes Alacritty.
- `~/sannonthachai/dotfiles/CLAUDE.md` Layout/Portability sections still mention `alacritty/` (the wezterm dir is not yet documented there).
- `.config/alacritty/alacritty.toml` still exists in the dotfiles repo.

When suggesting terminal tips, assume WezTerm conventions (Lua config, built-in tabs/splits available but unused in favor of tmux).
