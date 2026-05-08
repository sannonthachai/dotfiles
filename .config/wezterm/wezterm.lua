-- WezTerm config — launches WSL with zsh, gruvbox dark, JetBrainsMono Nerd Font
-- Docs: https://wezfurlong.org/wezterm/config/files.html

local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Shell: launch WSL Ubuntu directly into zsh in $HOME
config.default_prog = { 'wsl.exe', '--cd', '~' }

-- Start fullscreen (matches prior Alacritty `startup_mode = "Fullscreen"`)
wezterm.on('gui-startup', function(cmd)
  local _, _, window = wezterm.mux.spawn_window(cmd or {})
  window:gui_window():toggle_fullscreen()
end)

-- Window
config.initial_cols = 120
config.initial_rows = 32
config.window_decorations = 'RESIZE'
config.window_padding = { left = 8, right = 8, top = 8, bottom = 8 }
config.window_background_opacity = 1.0
config.adjust_window_size_when_changing_font_size = false

-- Font
config.font = wezterm.font('JetBrainsMono Nerd Font')
config.font_size = 11.0
config.harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' } -- ligatures on

-- Scrollback
config.scrollback_lines = 10000

-- Cursor
config.default_cursor_style = 'BlinkingBlock'
config.cursor_blink_rate = 500

-- Selection auto-copies (matches your Alacritty setup)
config.selection_word_boundary = ' \t\n{}[]()"\'`'

-- Tabs (you mostly use tmux, so keep tab bar minimal)
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true

-- Gruvbox dark color scheme (matches Vim)
config.colors = {
  foreground = '#ebdbb2',
  background = '#282828',
  cursor_bg = '#ebdbb2',
  cursor_fg = '#282828',
  cursor_border = '#ebdbb2',
  selection_fg = '#282828',
  selection_bg = '#d5c4a1',
  ansi = {
    '#282828', -- black
    '#cc241d', -- red
    '#98971a', -- green
    '#d79921', -- yellow
    '#458588', -- blue
    '#b16286', -- magenta
    '#689d6a', -- cyan
    '#a89984', -- white
  },
  brights = {
    '#928374',
    '#fb4934',
    '#b8bb26',
    '#fabd2f',
    '#83a598',
    '#d3869b',
    '#8ec07c',
    '#ebdbb2',
  },
}

-- Keybindings (match Alacritty: Ctrl-Shift-C/V copy/paste, Ctrl +/-/0 font size)
config.keys = {
  { key = 'C', mods = 'CTRL|SHIFT', action = wezterm.action.CopyTo 'Clipboard' },
  { key = 'V', mods = 'CTRL|SHIFT', action = wezterm.action.PasteFrom 'Clipboard' },
  { key = '=', mods = 'CTRL',       action = wezterm.action.IncreaseFontSize },
  { key = '-', mods = 'CTRL',       action = wezterm.action.DecreaseFontSize },
  { key = '0', mods = 'CTRL',       action = wezterm.action.ResetFontSize },
}

-- Don't beep
config.audible_bell = 'Disabled'

return config
