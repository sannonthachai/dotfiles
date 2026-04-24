# Global Preferences

## About Me
- Role: Software engineer + DevOps
- Primary stacks: Go (Golang), TypeScript/JavaScript, SQL
- DevOps tools: Docker, Kubernetes, Terraform, Ansible, ArgoCD, K9s, GitHub Actions, GitLab CI, Jenkins
- Cloud: Huawei Cloud (primary)

## Response Style
- Default: short and direct. Give me the answer or code, not a lecture.
- When I ask for details or "explain" / "teach me" — switch to teaching mode with full reasoning and trade-offs.
- Match my language: reply in Thai if I write Thai, English if I write English. Keep code, commands, and technical identifiers in English regardless.

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

My setup (at `~/.dotfiles/.vimrc`):
- Plugin manager: vim-plug
- Leader key: `,` (comma) — localleader also `,`
- LSP/completion: CoC (`gd` def, `gr` refs, `K` hover, `<leader>rn` rename, `<leader>ac` code action, `<leader>qf` quickfix)
- File tree: NERDTree (`Ctrl-n`, `Ctrl-t` toggle, `Ctrl-f` find)
- Terminal: vim-floaterm (`<leader>d` nnn, `<leader>r` rg, `<leader>g` git log, `<leader>f` fzf)
- Git: fugitive + gitgutter
- Multi-cursor: vim-visual-multi (leader `\`, `<leader>a` select all)
- Theme: GitHub light, `background=light`
- Clipboard: `unnamedplus` (system clipboard shared)
- Mouse: disabled (keyboard-only)
- Tab nav: `<leader>1`..`<leader>9`, `<leader>0` = last tab
- Arrow keys via Ctrl-h/j/k/l in all modes

When suggesting Vim tips or workflows:
- Prefer keyboard-driven solutions (no mouse).
- Use my existing plugins before suggesting new ones.
- When teaching a motion/command, show the key sequence and explain *why* it works (e.g., "`ciw` = change inner word — `c` operator + `iw` text object").

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
