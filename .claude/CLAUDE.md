# Global Preferences

## About Me
- Role: Software engineer + DevOps
- Primary stacks: Go (Golang), TypeScript/JavaScript, SQL
- DevOps tools: Docker, Kubernetes, Terraform, Ansible, ArgoCD, K9s, GitHub Actions, GitLab CI, Jenkins
- Cloud: Huawei Cloud (primary)
- Environment: macOS on MacBook (Apple Silicon, brew at `/opt/homebrew`), zsh + oh-my-zsh with **powerlevel10k** theme. Previously: WSL2 on Windows (Ubuntu).
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

## Frontend
- When I ask to create a frontend service/app: **before writing code, propose a UI stack** (framework, CSS, component library, icons, forms, theme) with a one-line reason each, and ask me to confirm or pick an alternative.
- Also **check https://21st.dev/community/templates (filter: Free / Open-source) first** and suggest 2-3 free templates that fit the app type (admin/dashboard, landing, SaaS, portfolio, commerce). For each: name, stack, license note, why it fits. Fetch the page live each time — listings change. Only suggest paid ones if I ask. Components: https://21st.dev/components (shadcn-style, copy-paste).
- Free template sources to check after 21st.dev (pick by app type):
  - Admin / internal tools: https://ui.shadcn.com/blocks, https://github.com/satnaing/shadcn-admin, https://themeselection.com (Sneat free), https://flowbite.com
  - Landing / marketing: https://shadcnblocks.com, https://cruip.com, https://ui.aceternity.com, https://tailgrids.com, https://preline.co
  - SaaS starters: https://vercel.com/templates, https://github.com/shadcn-ui/taxonomy
  - Components (shadcn-compatible, copy-paste): https://magicui.design, https://originui.com, https://cult-ui.com, https://21st.dev/components
- Suggest ~3 templates total, each: name, URL, stack, license, why it fits. Check license (MIT preferred) before recommending for commercial use.
- Each suggestion must be a real, cloneable template with a live demo link (not a component library or block set). If the chosen template turns out unusable (paywalled, needs a hosted API key, dead repo), stop and propose 3 replacements — never fall back to a from-scratch build without asking.
- Verify each candidate by fetching its repo page before suggesting (license, stars, archived/deprecated status, backend requirement). Present in this format:
  1. **Name** (one-line fit note) / Repo URL / Demo URL / Stack + license + stars / Why it fits / Downside
  End with a "Dropped:" line naming rejected candidates and the reason (archived, non-MIT, needs hosted key, dev-stage).
- Known-good free commerce storefronts (re-verify before use): Shopco (github.com/mohammadoftadeh/next-ecommerce-shopco, shadcn, static data), Vercel Shop (github.com/vercel/shop, Next 16 + shadcn, needs Shopify), Spree Storefront (github.com/spree/storefront, needs Spree backend). Avoid: vercel/commerce (archived), medusajs/nextjs-starter-medusa (deprecated), yournextstore (needs hosted API key), saleor/storefront (FSL license).
- Default proposal: Next.js + TypeScript (strict) + Tailwind CSS + shadcn/ui + lucide-react + react-hook-form/zod + TanStack Query, dark mode via `next-themes`.
- Suggest alternatives when they fit better: Ant Design/MUI for data-heavy admin dashboards; Nuxt + Nuxt UI/PrimeVue for Vue; Astro + Tailwind for static sites; Go templates + HTMX + Tailwind/DaisyUI for minimal-JS apps with a Go backend.
- Ask first if unclear: app type (dashboard vs public site), framework preference, existing design system/brand.

## Vim (learning)
I'm learning Vim — treat me as a Vim beginner/intermediate when explaining motions, operators, or idioms, even though my config is advanced.

**Config:** `~/sannonthachai/dotfiles/.vimrc` (symlinked to `~/.vimrc`)
**Plugin manager:** vim-plug
**Leader:** `,` (comma) — localleader also `,`
**Theme:** gruvbox dark (`background=dark`, `g:gruvbox_contrast_dark='medium'`)
**Clipboard:** `unnamed,unnamedplus` (system clipboard shared — `unnamed` for macOS NSPasteboard, `unnamedplus` for Linux X11)
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
**WezTerm** on macOS (installed via brew cask). Config at
`~/sannonthachai/dotfiles/.config/wezterm/wezterm.lua`.

- Font: **JetBrainsMono Nerd Font** at 11pt (required for powerlevel10k icons)
- Theme: gruvbox dark (matches Vim)
- Clipboard: `Cmd-C` / `Cmd-V` (macOS standard); selection auto-copies
- Scrollback: 10000 lines
- Font size: `Cmd-+` / `Cmd--` / `Cmd-0` reset

History: Alacritty (Windows/WSL2) → Windows Terminal → WezTerm.

When suggesting terminal tips:
- Assume no tabs/splits in WezTerm itself — tmux handles that.
- Keep configs terminal-agnostic where possible (e.g., don't hard-code terminal-specific escapes).

@RTK.md
