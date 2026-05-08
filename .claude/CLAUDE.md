# Global Preferences

## About Me
- Role: Software engineer + DevOps
- Primary stacks: Go (Golang), TypeScript/JavaScript, SQL
- DevOps tools: Docker, Kubernetes, Terraform, Ansible, ArgoCD, K9s, GitHub Actions, GitLab CI, Jenkins
- Cloud: Huawei Cloud (primary)
- Environment: WSL2 on Windows (Ubuntu), zsh + oh-my-zsh with **powerlevel10k** theme
- Personal dotfiles: `~/sannonthachai/dotfiles` (github.com/sannonthachai/dotfiles) — source of truth for `.vimrc`, `.zshrc`, `.tmux.conf`, `.gitconfig`, nvim, alacritty, Claude Code. Home files are symlinks into the repo (managed via `install.sh`).

## Response Style
- Default: short and direct. Give me the answer or code, not a lecture.
- When I ask for details or "explain" / "teach me" — switch to teaching mode with full reasoning and trade-offs.
- Default to English. Only reply in Thai if I actually write in Thai script (ภาษาไทย). Thai-influenced English phrasing is still English — reply in English. Keep code, commands, and technical identifiers in English regardless.

## Workflow
- For simple/obvious tasks: just do it, no planning overhead.
- For non-trivial changes: explore related code first, then show a plan before writing code.
- If requirements are ambiguous: ask clarifying questions instead of guessing.
- Always ask before destructive actions (rm -rf, force push, dropping tables, deleting resources, `kubectl delete`, `terraform destroy`, etc.).

## Code Style
- Small, focused functions with early returns.
- Explicit error handling — no silent failures, handle every error.
- Go: idiomatic Go, `if err != nil` checks, no ignoring errors with `_`.
- TypeScript: strict typing, avoid `any`.
- Minimal comments — only when the WHY is non-obvious.

## DevOps Notes
- When writing Kubernetes manifests or Helm charts, assume ArgoCD will deploy them.
- For cloud-specific work, default to Huawei Cloud equivalents (CCE for Kubernetes, OBS for object storage, etc.) unless I say otherwise.

## Vim (learning)
I'm learning Vim — treat me as a Vim beginner/intermediate when explaining motions, operators, or idioms, even though my config is advanced.

**Config:** `~/sannonthachai/dotfiles/.vimrc` (symlinked to `~/.vimrc`)
**Plugin manager:** vim-plug
**Leader:** `,` (comma) — localleader also `,`
**Theme:** gruvbox dark (`background=dark`, `g:gruvbox_contrast_dark='medium'`)
**Clipboard:** `unnamedplus` (system clipboard shared)
**Mouse:** disabled — keyboard only

### Installed plugins

- **LSP/completion:** coc.nvim (extensions: coc-go, coc-tsserver, coc-pyright, coc-yaml, coc-sh, coc-html, coc-java, coc-markdownlint, coc-highlight, coc-prettier, @yaegassy/coc-black-formatter)
- **File tree:** NERDTree
- **Fuzzy finder:** fzf + fzf.vim (`Ctrl-p` files, `,b` buffers, `,/` ripgrep text, `,H` history)
- **Editing:** vim-surround, vim-repeat, vim-unimpaired, vim-commentary, vim-visual-multi, editorconfig-vim
- **Git:** fugitive, gitgutter
- **Terminal inside vim:** vim-floaterm (`,d` nnn, `,r` rg, `,g` git log, `,f` fzf)
- **Learning:** vim-which-key (popup for leader mappings)
- **Languages:** vim-terraform, vim-yaml, ansible-vim, vim-helm, plantuml-syntax, vim-terramate
- **Other:** indentLine, vim-airline (gruvbox theme), vim-tmux-navigator, open-browser.vim, bracey.vim, vim-instant-markdown, gruvbox

### Key mappings (besides plugin defaults)

- `Ctrl-p` → fuzzy files
- `,b` / `,/` / `,H` → buffers / ripgrep / history
- `,F` → format current file (Go: gofmt, sh: shfmt, terraform: `terraform fmt`; others via CoC `:Format`)
- `,1..,9`, `,0` → tab navigation (last tab)
- `Ctrl-n/t/f` → NERDTree open/toggle/find
- `Ctrl-h/j/k/l` → window/tmux pane nav (vim-tmux-navigator)
- CoC: `gd` def, `gr` refs, `K` hover, `,rn` rename, `,ac` code action, `,qf` quickfix, `,cl` code lens

### External tools Vim depends on
`rg` (`~/.local/bin/rg`), `fzf` (`~/.local/bin/fzf` → `~/.fzf/bin/fzf`), `black`, `prettier`, `terraform-ls` (`~/.local/bin/terraform-ls`), `gofmt`, `goimports`, `shfmt`.

### When suggesting Vim tips or workflows
- Prefer keyboard-driven solutions (no mouse).
- Use my existing plugins before suggesting new ones — check the list above first.
- When teaching a motion/command, show the key sequence and explain *why* it works (e.g., "`ciw` = change inner word — `c` operator + `iw` text object").
- I'm still learning — focus on a few high-impact tricks rather than advanced tricks dumped all at once.

## tmux
I use tmux daily for terminal multiplexing. My config is based on **oh-my-tmux** (gpakosz/.tmux) at `~/.tmux.conf`.

Key bindings I use most:
- Prefix: `C-b` (default) or `C-a` (GNU-Screen compatible alternate)
- Splits: prefix + `-` (horizontal), prefix + `_` (vertical)
- Pane nav: prefix + `h/j/k/l`
- Pane resize: prefix + `H/J/K/L`
- Window nav: prefix + `C-h` (prev), prefix + `C-l` (next), prefix + `Tab` (last)
- Copy mode: prefix + `Enter`, vi bindings (`v` select, `y` yank, `C-v` block select)
- Reload config: prefix + `r`
- Windows/panes start at index 1 (not 0)
- Mode keys: vi

Vim–tmux integration: I have `christoomey/vim-tmux-navigator` — `Ctrl-h/j/k/l` moves seamlessly between Vim splits and tmux panes.

When suggesting tmux tips:
- Assume the oh-my-tmux base (don't suggest conflicting default bindings).
- Prefer keyboard workflows — no mouse.

## Terminal
**Alacritty** on Windows (installed via winget, `C:\Program Files\Alacritty\`).
Config at `%APPDATA%\alacritty\alacritty.toml` — also mirrored in the personal
dotfiles repo at `.config/alacritty/alacritty.toml`.

- Launches `wsl.exe` directly into Ubuntu zsh
- Font: **JetBrainsMono Nerd Font** at 11pt (required for powerlevel10k icons)
- Theme: gruvbox dark (matches Vim)
- Clipboard: `Ctrl-Shift-C` / `Ctrl-Shift-V`; selection auto-copies
- Scrollback: 10000 lines
- Font size: `Ctrl-+` / `Ctrl--` / `Ctrl-0` reset

When suggesting terminal tips:
- Assume no tabs/splits in Alacritty itself — tmux handles that.
- Keep configs terminal-agnostic where possible (e.g., don't hard-code terminal-specific escapes).
